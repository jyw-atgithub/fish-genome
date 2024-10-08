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

bedtools bamtobed -split -i ${old}/C01_CELs-asm.bam > ${gene_seq}/C01_CELs-asm.bed
bedtools bamtobed  -i ${old}/C01_CELs-asm.bam > ${gene_seq}/C01_CELs-asm.nosplit.bed
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_CELs-asm.nosplit.bed > ${gene_seq}/C01_CELs.fasta
#If we do not use "-split" in bedtool, we will get the entire gene sequence.
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_CELs-asm.bed |\
seqkit rmdup |seqkit sort > ${gene_seq}/C01_CELs.cds.fasta
#If we use "-split" in bedtool, we will only get most of the aligned coding regions so we need to manually conjugate the segments of each one gene.

bedtools bamtobed -split -i ${old}/C01_chitinase-asm.bam > ${gene_seq}/C01_chitinase-asm.bed
bedtools bamtobed  -i ${old}/C01_chitinase-asm.bam > ${gene_seq}/C01_chitinase-asm.nosplit.bed
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_chitinase-asm.nosplit.bed > ${gene_seq}/C01_chitinase.fasta
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_chitinase-asm.bed |\
seqkit rmdup |seqkit sort > ${gene_seq}/C01_chitinase.cds.fasta

##Let's unify the coordinates, so we rely on the annotation results (gff file)