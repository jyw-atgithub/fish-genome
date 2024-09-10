#!/bin/bash
#SBATCH --job-name=Braker3
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=9G
source ~/.bashrc

old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
annotation="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"
final_genome="${annotation}/C01_final.fasta.masked"
nT=$SLURM_CPUS_PER_TASK

cd /dfs7/jje/jenyuw/Fish-project-hpc3/old
#module load singularity/3.11.3
#singularity build braker3.sif docker://teambraker/braker3:latest

# We used Pc29_MI and Pc29_PC RNAseq sequences, four files in total. 
module load anaconda/2022.05
conda activate qc
for i in ${annotation}/Pc29*.READ1.fastq.gz
do
I=${i//"READ1"/"READ2"}
name=`basename $i .READ1.fastq.gz`
echo -e $i "\n" $I
fastp --detect_adapter_for_pe --overrepresentation_analysis --correction --cut_right --thread ${nT} \
-i ${i} -I ${I} \
--html ${annotation}/${name}.html  -o ${annotation}/${name}.r1.trimmed.fastq -O ${annotation}/${name}.r2.trimmed.fastq
done
conda deactivate

#indexing once
hisat2-build -p ${nT} ${final_genome} C01_final.fasta.masked
# we did the alignment separately because of OOM error
read1="${annotation}/Pc29_MI.r1.trimmed.fastq"
read2="${annotation}/Pc29_MI.r2.trimmed.fastq"
hisat2 -p ${nT} --qc-filter --summary-file ${annotation}/hisat2-summary.txt -x ${final_genome} -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G -o ${annotation}/Pc29.MI.sort.bam
samtools index -@ ${nT} ${annotation}/Pc29.MI.sort.bam

read1="${annotation}/Pc29_PC.r1.trimmed.fastq"
read2="${annotation}/Pc29_PC.r2.trimmed.fastq"
hisat2 -p ${nT} --qc-filter --summary-file ${annotation}/hisat2-summary.txt -x ${final_genome} -1 ${read1} -2 ${read2} |\
samtools view -b -S -h -@ ${nT} - | samtools sort -@ ${nT} -m 4G -o ${annotation}/Pc29.PC.sort.bam
samtools index -@ ${nT} ${annotation}/Pc29.PC.sort.bam

samtools merge -f -@ ${nT} -o ${annotation}/Pc29.all.sort.bam ${annotation}/Pc29.{MI,PC}.sort.bam

module load singularity/3.11.3
#protein file from here: https://bioinf.uni-greifswald.de/bioinf/partitioned_odb11/
#curl 'https://data.orthodb.org/current/fasta?species=7898' -L -o fish.orthoDB.fasta #failed
#curl 'https://data.orthodb.org/current/fasta?id=32204at9721&species=9721' -L -o data.fs
singularity exec ${old}/braker3.sif braker.pl --workingdir=${annotation}/ \
--genome=${final_genome} --bam=${annotation}/Pc29.all.sort.bam \
--prot_seq=${annotation}/Vertebrata.fa --threads ${nT}

module unload singularity/3.11.3