#!/bin/bash

#SBATCH --job-name=validation
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=10G

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
asm="/dfs7/jje/jenyuw/Fish-project-hpc3/old/C01_final.fasta"
read="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed/C01_trimmed.fastq.gz"
bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
blquery="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast/query"

####Double check the precense or absence of "pag1" in CV genome.
#remember to use "-parse_seqids" so the output sam file contains the right ID.
makeblastdb -parse_seqids -in ${bl}/CV_genome.rename.fasta -dbtype nucl -input_type fasta -blastdb_version 5
makeblastdb -parse_seqids -in ${blquery}/pepsin.fasta -dbtype nucl -input_type fasta -blastdb_version 5
blastn -outfmt "17 SR" -query ${blquery}/pepsin.fasta -db ${bl}/CV_genome.rename.fasta -num_threads ${nT} -out ${bl}/CV_pepsin.blastn.sam
samtools view -b ${bl}/CV_pepsin.blastn.sam |samtools sort > ${bl}/CV_pepsin.blastn.bam
samtools index ${bl}/CV_pepsin.blastn.bam
##With IGV, we see the pga1 gene of XM_040176656 (three-spined stickleback) and XM_037464105 (P. pungitius) are aligned between "g8860" and "g8859" in Cebidichthys violaceus genome.
##--> Then, try to chck it with PseudoChecker2.0
pc="/dfs7/jje/jenyuw/Fish-project-hpc3/old/pseudochecker"
module load singularity/3.11.3
micromamba activate AGAT




####The following minimap2 alignment were only performed on some genes. We found not all real genes were mapped to the assembly.

#mapping raw reads to the assembly
minimap2 -a --cs -x map-pb -t ${nT} ${asm} ${read} | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_trimmed-asm.bam
samtools index -@ ${nT} ${old}/C01_trimmed-asm.bam
#mapping target genes to the assembly, testing two parameters
minimap2 -a --cs -x splice:hq -uf -t ${nT} ${asm} /dfs7/jje/jenyuw/Fish-project-hpc3/old/blast/*.fasta| samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_target-asm-1.bam
samtools index -@ ${nT} ${old}/C01_target-asm-1.bam
minimap2 -a --cs -x asm20 -uf -t ${nT} ${asm} /dfs7/jje/jenyuw/Fish-project-hpc3/old/blast/*.fasta| samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_target-asm-2.bam
samtools index -@ ${nT} ${old}/C01_target-asm-2.bam

#try to find the anapep genes
minimap2 -a --cs -x asm20 -uf -t ${nT} ${asm} ${bl}/chitinase_sticlkeback.fasta| samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_chitinase-asm.bam
samtools index -@ ${nT} ${old}/C01_chitinase-asm.bam
#dnadiff ${asm} ${old}/blast/anpep.fasta

#try to find the chitinase genes
minimap2 -a --cs -x asm20 -u f -t ${nT} ${asm} ${bl}/query/chitinase_sticlkeback.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/gene_mapping/chitinase-asm.bam
samtools index -@ ${nT} ${old}/gene_mapping/chitinase-asm.bam
minimap2 -a --cs -x asm20 -u f -t ${nT} ${bl}/AP_genome.fasta ${bl}/query/chitinase_sticlkeback.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/gene_mapping/chitinase-AP.bam
samtools index -@ ${nT} ${old}/gene_mapping/chitinase-AP.bam
minimap2 -a --cs -x asm20 -u f -t ${nT} ${bl}/CV_genome.fasta ${bl}/query/chitinase_sticlkeback.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/gene_mapping/chitinase-CV.bam
samtools index -@ ${nT} ${old}/gene_mapping/chitinase-CV.bam

#try to find the pepsinogen genes
minimap2 -a --cs -x splice:hq -u f -t ${nT} ${asm} ${bl}/query/pepsin.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/gene_mapping/pepsinogen-asm.bam
samtools index -@ ${nT} ${old}/gene_mapping/pepsinogen-asm.bam
minimap2 -a --cs -x splice:hq -u f -t ${nT} ${bl}/AP_genome.fasta ${bl}/query/pepsin.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/gene_mapping/pepsinogen-AP.bam
samtools index -@ ${nT} ${old}/gene_mapping/pepsinogen-AP.bam

#try to find the carboxyl ester lipase genes
minimap2 -a --cs -x splice:hq -u f -t ${nT} ${asm} ${bl}/query/CEsterLipase.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/gene_mapping/CEsterLipase-asm.bam
samtools index -@ ${nT} ${old}/gene_mapping/CEsterLipase-asm.bam
minimap2 -a --cs -x splice:hq -u f -t ${nT} ${bl}/AP_genome.fasta ${bl}/query/CEsterLipase.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/gene_mapping/CEsterLipase-AP.bam
samtools index -@ ${nT} ${old}/gene_mapping/CEsterLipase-AP.bam