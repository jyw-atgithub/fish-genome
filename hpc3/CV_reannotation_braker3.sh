#!/bin/bash

#SBATCH --job-name=CV_Braker3
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --cpus-per-task=36
#SBATCH --mem-per-cpu=9G

old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
annotation="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"
input_genome="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation/CV_re-annotation/CV_genome.rename.fasta"
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
#Do not use gzip files for hisat2.
hisat2-build -p ${nT} ${input_genome} CV_genome_rename.fasta


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

samtools merge -f -@ ${nT} -o ${CV_re}/CV_mRNA.sort.bam ${CV_re}/CV_{PI,heart,liver}.sort.bam

echo "Mapping done"

module load singularity/3.11.3
#protein file from here: https://bioinf.uni-greifswald.de/bioinf/partitioned_odb11/
#curl 'https://data.orthodb.org/current/fasta?species=7898' -L -o fish.orthoDB.fasta #failed
#curl 'https://data.orthodb.org/current/fasta?id=32204at9721&species=9721' -L -o data.fs
singularity exec ${old}/braker3.sif braker.pl --workingdir=${CV_re}/ \
--genome=${input_genome} --bam=${CV_re}/CV_mRNA.sort.bam \
--prot_seq=${annotation}/Vertebrata.fa --threads ${nT}

module unload singularity/3.11.3


###OMG, pepsin gene, PGA1 is missing!! But, WTF all the neighboring genes are there!!!  SAD~~~~~~ ARR~~~~~~~~
##Include more RNAseq data:
##Pyloric Caeca (SRR5579838) Middle Intestine (SRR5579840)
#cd $TMPDIR
#prefetch -p SRR5579838 SRR5579840
#ID="SRR5579838"
#fasterq-dump -p ./$ID/$ID.sra -e $SLURM_NTASKS --temp $TMPDIR --disk-limit-tmp 500G
#ID="SRR5579840"
#fasterq-dump -p ./$ID/$ID.sra -e $SLURM_NTASKS --temp $TMPDIR --disk-limit-tmp 500G
#bgzip -k -@ 20 -c SRR5579838_1.fastq >${CV_re}/CV_pyloric_SRR5579838_1.fastq.gz
#bgzip -k -@ 20 -c SRR5579838_2.fastq >${CV_re}/CV_pyloric_SRR5579838_2.fastq.gz
#bgzip -k -@ 20 -c SRR5579840_1.fastq >${CV_re}/CV_MI_SRR5579840_1.fastq.gz
#bgzip -k -@ 20 -c SRR5579840_2.fastq >${CV_re}/CV_MI_SRR5579840_2.fastq.gz

source ~/.bashrc
module load anaconda/2022.05
conda activate qc

for i in ${CV_re}/CV_pyloric_SRR5579838_1.fastq.gz ${CV_re}/CV_MI_SRR5579840_1.fastq.gz
do
I=${i//"_1"/"_2"}
name=`basename $i _1.fastq.gz`
echo -e $i "\n" $I
fastp --detect_adapter_for_pe --overrepresentation_analysis --correction --cut_right --thread ${nT} \
-i ${i} -I ${I} \
-o ${CV_re}/${name}.r1.trimmed.fastq -O ${CV_re}/${name}.r2.trimmed.fastq
done
conda deactivate


old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
annotation="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"
input_genome="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation/CV_re-annotation/CV_genome.rename.fasta"
CV_re="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation/CV_re-annotation"
nT=$SLURM_CPUS_PER_TASK

read1="CV_pyloric_SRR5579838.r1.trimmed.fastq"
read2="CV_pyloric_SRR5579838.r2.trimmed.fastq"
hisat2 -p ${nT} --qc-filter --summary-file ${CV_re}/hisat2-summary.txt -x ${input_genome} -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G -o ${CV_re}/CV_pyloric.sort.bam
samtools index -@ ${nT} ${CV_re}/CV_pyloric.sort.bam

read1="CV_MI_SRR5579840.r1.trimmed.fastq"
read2="CV_MI_SRR5579840.r2.trimmed.fastq"
hisat2 -p ${nT} --qc-filter --summary-file ${CV_re}/hisat2-summary.txt -x ${input_genome} -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G -o ${CV_re}/CV_MI.sort.bam
samtools index -@ ${nT} ${CV_re}/CV_MI.sort.bam

samtools merge -f -@ ${nT} -o ${CV_re}/CV_mRNA.sort.bam ${CV_re}/CV_{PI,heart,liver,pyloric,MI}.sort.bam
samtools index -@ ${nT} ${CV_re}/CV_mRNA.sort.bam

echo "Mapping done"

module load singularity/3.11.3
#protein file from here: https://bioinf.uni-greifswald.de/bioinf/partitioned_odb11/
#curl 'https://data.orthodb.org/current/fasta?species=7898' -L -o fish.orthoDB.fasta #failed
#curl 'https://data.orthodb.org/current/fasta?id=32204at9721&species=9721' -L -o data.fs
singularity exec ${old}/braker3.sif braker.pl --workingdir=${CV_re}/ --gff3 \
--genome=${input_genome} --bam=${CV_re}/CV_mRNA.sort.bam \
--prot_seq=${annotation}/Vertebrata.fa --threads ${nT}

module unload singularity/3.11.3