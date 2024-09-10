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
blast="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
#mapping raw reads to the assembly
minimap2 -a --cs -x map-pb -t ${nT} ${asm} ${read} | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_trimmed-asm.bam
samtools index -@ ${nT} ${old}/C01_trimmed-asm.bam
#mapping target genes to the assembly
minimap2 -a --cs -x splice:hq -uf -t ${nT} ${asm} /dfs7/jje/jenyuw/Fish-project-hpc3/old/blast/*.fasta| samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_target-asm-1.bam
samtools index -@ ${nT} ${old}/C01_target-asm-1.bam
minimap2 -a --cs -x asm20 -uf -t ${nT} ${asm} /dfs7/jje/jenyuw/Fish-project-hpc3/old/blast/*.fasta| samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_target-asm-2.bam
samtools index -@ ${nT} ${old}/C01_target-asm-2.bam

#try to find the anapep genes
minimap2 -a --cs -x asm20 -uf -t ${nT} ${asm} /dfs7/jje/jenyuw/Fish-project-hpc3/old/blast/chitinase_sticlkeback.fasta| samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_chitinase-asm.bam
samtools index -@ ${nT} ${old}/C01_chitinase-asm.bam
#dnadiff ${asm} ${old}/blast/anpep.fasta

minimap2 -a --cs -x asm20 -uf -t ${nT} ${asm} ${blast}/chitinase_sticlkeback.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_chitinase-asm.bam
samtools index -@ ${nT} ${old}/C01_chitinase-asm.bam
minimap2 -a --cs -x asm20 -uf -t ${nT} ${blast}/APGenomeomicsbox.fa ${blast}/chitinase_sticlkeback.fasta | samtools view -bS - |\
samtools sort -@ ${nT} -o ${old}/C01_chitinase-AP.bam
samtools index -@ ${nT} ${old}/C01_chitinase-AP.bam
minimap2 -a --cs -x asm20 -uf -t ${nT} ${blast}/GCA008087265.1_genome.fna ${blast}/chitinase_sticlkeback.fasta | samtools view -bS - |samtools sort -@ ${nT} -o ${old}/C01_chitinase-CV.bam
samtools index -@ ${nT} ${old}/C01_chitinase-CV.bam