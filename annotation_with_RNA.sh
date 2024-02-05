#!/bin/bash

ref="/home/jenyuw/Fish-project/reference"
raw="/home/jenyuw/Fish-project/raw"
trimmed="/home/jenyuw/Fish-project/result/trimmed"
aligned_bam="/home/jenyuw/Fish-project/result/aligned_bam"
repeat="/home/jenyuw/Fish-project/result/repeat"
final_genome="/home/jenyuw/Fish-project/result/final_genome"
annotation="/home/jenyuw/Fish-project/result/annotation"
nT=30

: <<'SKIP'
#sequence processing
conda activate everything
for i in `ls ${raw}/Pc29_*_raw_files/*READ1-Sequences.txt*`
do
I=${i//"READ1"/"READ2"}
name=`echo ${i} |gawk -F "/" '{print $6}'|sed s/_raw_files//g`
echo $i
echo $I
fastp --detect_adapter_for_pe --overrepresentation_analysis --correction --cut_right --thread $nT \
-i ${i} -I ${I} \
--html ${trimmed}/${name}.html  -o ${trimmed}/${name}.r1.trimmed.fastq -O ${trimmed}/${name}.r2.trimmed.fastq
done
conda deactivate
#still use the soft masked genome
cd ${final_genome}
#indexing once
#hisat2-build -p ${nT} ${final_genome}/C01_final.fasta.masked C01_final.fasta.masked

read1=`ls ${trimmed}/Pc29_*.r1.trimmed.fastq|tr "\n" ","`
read2=`ls ${trimmed}/Pc29_*.r2.trimmed.fastq|tr "\n" ","`

hisat2 -p ${nT} --summary-file ${aligned_bam}/hisat2-summary.txt -x ${final_genome}/C01_final.fasta.masked -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G -o ${aligned_bam}/Pc29.all.sort.bam
samtools index ${aligned_bam}/Pc29.all.sort.bam
SKIP

singularity exec /home/jenyuw/Software/braker3.sif braker.pl --workingdir=${annotation}/braker \
--genome=${final_genome}/C01_final.fasta.masked --bam=${aligned_bam}/Pc29.all.sort.bam \
--prot_seq=${ref}/Vertebrata.fa.gz --threads ${nT}