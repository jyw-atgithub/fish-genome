#! /bin/bash

#SBATCH --job-name=canu
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=36
#SBATCH --mem-per-cpu=10G
#SBATCH --time=7-00:00:00
source ~/.bashrc

trimmed="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed"
assemble="/dfs7/jje/jenyuw/Fish-project-hpc3/results/assembly"
nT=$SLURM_CPUS_PER_TASK
#canu binary has been put in the $PATH
canu -p C01 -d ${assemble}/C01_canu \
genomeSize=600m \
maxInputCoverage=90 \
minReadLength=500 \
minOverlapLength=500 \
maxThreads=${nT} \
correctedErrorRate=0.035 utgOvlErrorRate=0.065 trimReadsCoverage=2 trimReadsOverlap=500 \
stopOnLowCoverage=2 minInputCoverage=3 \
useGrid=false \
-raw -pacbio ${trimmed}/C01_trimmed.fastq.gz
