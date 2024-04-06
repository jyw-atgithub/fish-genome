#! /bin/bash

#SBATCH --job-name=trimming
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=10G
source ~/.bashrc

raw="/dfs7/jje/jenyuw/Fish-project-hpc3/raw"
trimmed="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed"
nT=$SLURM_CPUS_PER_TASK

module load anaconda/2022.05
conda activate qc

zcat ${raw}/R251-C01.1-Reads.fastq.gz |chopper -l 540 --headcrop 20 --tailcrop 20 -t ${nT} |\
bgzip -@ ${nT} -c > ${trimmed}/C01_trimmed.fastq.gz

for r1 in ${raw}/*READ1-Sequences.txt.gz
do
name=$(basename $r1 _READ1-Sequences.txt.gz|cut -d "-" -f 4)
r2=`echo ${r1}|sed 's/READ1/READ2/g'`
fastp --verbose --detect_adapter_for_pe --overrepresentation_analysis --correction --cut_right --thread ${nT} \
--html ${trimmed}/${name}.html -i ${r1} -I ${r2} -o ${trimmed}/${name}.trimmed.r1.fastq.gz -O ${trimmed}/${name}.trimmed.r2.fastq.gz
done

conda deactivate
module unload anaconda/2022.05

