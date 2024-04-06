#! /bin/bash

#SBATCH --job-name=flye
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G
source ~/.bashrc

trimmed="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed"
assemble="/dfs7/jje/jenyuw/Fish-project-hpc3/results/assembly"
nT=$SLURM_CPUS_PER_TASK

module load python/3.10.2
flye --threads ${nT} \
--pacbio-raw ${trimmed}/C01_trimmed.fastq.gz \
--out-dir ${assemble}/C01_flye
module unload python/3.10.2
