#!/bin/bash

raw="/home/jenyuw/Fish-project/raw"
trimmed="/home/jenyuw/Fish-project/result/trimmed"
assembly="/home/jenyuw/Fish-project/result/assembly"
aligned_bam="/home/jenyuw/Fish-project/result/aligned_bam"
nT=24
source ~/.bashrc
#We were trying to figure out which illumina sequence really belong to P. chirus.

conda activate everything
for i in $raw/*READ1-Sequences.txt.gz
do
name=$(basename $i _READ1-Sequences.txt.gz|cut -d "-" -f 4)
r2=`echo $i|sed 's/READ1/READ2/g'`
fastp --verbose --detect_adapter_for_pe --overrepresentation_analysis --correction --cut_right --thread ${nT} \
--html ${trimmed}/$series.html -i ${i} -I ${r2} -o ${trimmed}/${name}.trimmed.r1.fastq.gz -O ${trimmed}/${name}.trimmed.r2.fastq.gz
done
conda deactivate

for i in P94 P95 P96
do
bwa-mem2 index ${assembly}/C01_flye/assembly.fasta
r1="${trimmed}/${i}.trimmed.r1.fastq.gz"
r2="${trimmed}/${i}.trimmed.r2.fastq.gz"
bwa-mem2 mem -t ${nT} ${assembly}/C01_flye/assembly.fasta $r1 $r2 |samtools view -S -b -h |\
samtools sort -@ ${nT} -o ${aligned_bam}/${i}.flye.sort.bam
samtools index ${aligned_bam}/${i}.flye.sort.bam
done