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