#!/bin/bash

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
asm="/dfs7/jje/jenyuw/Fish-project-hpc3/old/C01_final.fasta"
gene_seq="/dfs7/jje/jenyuw/Fish-project-hpc3/old/gene_sequences"
bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
read="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed/C01_trimmed.fastq.gz"

####Let's unify the coordinates, so we rely on the annotation results (gff file)####

##Retrive only the Chitinase genes from AP and PC, for phylogeny.
#the content of AP_seq_names.txt is modified accordingly. #BAD PRACTICE THOUGH
printf "" >${anno}/AP_chitinase.gff
while read line
do
grep ${line} ${anno}/AP_renamed.gff|grep "mRNA" >> ${anno}/AP_chitinase.gff
done < ${anno}/AP_seq_names.txt
seqkit subseq --gtf ${anno}/AP_chitinase.gff  ${bl}/AP_genome.fasta >${gene_seq}/AP_chitinase.fasta

#Extract the CDS sequence of only the chitinase gene from PC.
#the content of pc_seq_names.txt is modified accordingly. #BAD PRACTICE THOUGH
seqkit grep -n -f ${anno}/PC_seq_names.txt  ${anno}/braker.codingseq > ${gene_seq}/PC_chitinase.fasta

##Merge all sequences of a gene from all species. It will be used for phylogeny.
cat ${bl}/query/chitinase_salmon.fasta  ${bl}/query/chitinase_sticlkeback.fasta ${gene_seq}/AP_chitinase.fasta ${gene_seq}/PC_chitinase.fasta > ${gene_seq}/all_chitinase.fasta

#similar tricks on pepsinogen genes
seqkit grep -p GENE_19548,GENE_19552,GENE_20663,GENE_26753 ${anno}/AP_Genomeomicsbox.fasta >${anno}/AP_pepsinogen.fasta #the sequence of GENE_19548 & GENE_19552 are merged, because it looks like an annotation error.
seqkit grep -p g20032.t1,g4760.t1,g10524.t1 ${anno}/braker.codingseq >${anno}/PC_pepsinogen.fasta


 

##The following method is less effecent
: <<'SKIP'
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
SKIP