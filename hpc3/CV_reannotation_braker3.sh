#!/bin/bash

#SBATCH --job-name=CV_Braker3
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --cpus-per-task=36
#SBATCH --mem-per-cpu=9G

old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
annotation="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"
input_genome="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation/CV_re-annotation/CV_genome.fasta"
CV_re="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation/CV_re-annotation"
nT=$SLURM_CPUS_PER_TASK

cd ${CV_re}

source ~/.bashrc

module load anaconda/2022.05
conda activate qc

for i in ${CV_re}/*_1.fastq.gz
do
I=${i//"_1"/"_2"}
name=`basename $i _1.fastq.gz`
echo -e $i "\n" $I
fastp --detect_adapter_for_pe --overrepresentation_analysis --correction --cut_right --thread ${nT} \
-i ${i} -I ${I} \
--html ${CV_re}/${name}.html  -o ${CV_re}/${name}.r1.trimmed.fastq -O ${CV_re}/${name}.r2.trimmed.fastq
done
conda deactivate

echo "QC done"

hisat2-build -p ${nT} ${input_genome} CV_genome.fasta

read1="CV_heart_SRX2837937.r1.trimmed.fastq"
read2="CV_heart_SRX2837937.r2.trimmed.fastq"
hisat2 -p ${nT} --qc-filter --summary-file ${CV_re}/hisat2-summary.txt -x ${input_genome} -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G -o ${CV_re}/CV_heart.sort.bam
samtools index -@ ${nT} ${CV_re}/CV_heart.sort.bam

read1="CV_liver_SRX2837934.r1.trimmed.fastq"
read2="CV_liver_SRX2837934.r2.trimmed.fastq"
hisat2 -p ${nT} --qc-filter --summary-file ${CV_re}/hisat2-summary.txt -x ${input_genome} -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G  -o ${CV_re}/CV_liver.sort.bam
samtools index -@ ${nT} ${CV_re}/CV_liver.sort.bam

read1="CV_PI_SRX2837931.r1.trimmed.fastq"
read2="CV_PI_SRX2837931.r2.trimmed.fastq"
hisat2 -p ${nT} --qc-filter --summary-file ${CV_re}/hisat2-summary.txt -x ${input_genome} -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G  -o ${CV_re}/CV_PI.sort.bam
samtools index -@ ${nT} ${CV_re}/CV_PI.sort.bam

samtools merge -f -@ ${nT} -o ${CV_re}/CV_mRNA.sort.bam ${annotation}/CV_{PI,heart,liver}.sort.bam

echo "Mapping done"

module load singularity/3.11.3
#protein file from here: https://bioinf.uni-greifswald.de/bioinf/partitioned_odb11/
#curl 'https://data.orthodb.org/current/fasta?species=7898' -L -o fish.orthoDB.fasta #failed
#curl 'https://data.orthodb.org/current/fasta?id=32204at9721&species=9721' -L -o data.fs
singularity exec ${old}/braker3.sif braker.pl --workingdir=${CV_re}/ \
--genome=${input_genome} --bam=${CV_re}/CV_mRNA.sort.bam \
--prot_seq=${annotation}/Vertebrata.fa --threads ${nT}

module unload singularity/3.11.3