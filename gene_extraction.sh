#!/bin/bash

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
asm="/dfs7/jje/jenyuw/Fish-project-hpc3/old/C01_final.fasta"
gene_seq="/dfs7/jje/jenyuw/Fish-project-hpc3/old/gene_sequences"
read="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed/C01_trimmed.fastq.gz"

#Extract the coordinate of CEL&CEL-like genes
minimap2 -a --cs -x splice:hq -uf -t ${nT} ${asm} ${old}/blast/CEL-like.fasta ${old}/blast/CEsterLipase.fasta| samtools view -bS - |samtools sort -@ ${nT} -o ${old}/C01_CELs-asm.bam
samtools index -@ ${nT} ${old}/C01_CELs-asm.bam

bedtools bamtobed -i ${old}/C01_CELs-asm.bam > ${gene_seq}/C01_CELs-asm.bed
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_CELs-asm.bed > ${gene_seq}/C01_CELs.fasta