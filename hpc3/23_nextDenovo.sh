#!/bin/bash

#SBATCH --job-name=nextDenovo
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G

source ~/.bashrc
trimmed="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed"
assemble="/dfs7/jje/jenyuw/Fish-project-hpc3/results/assembly"
nT=$SLURM_CPUS_PER_TASK

echo -e "
job_type = local
job_prefix = nextDenovo
task = all
rewrite = yes
deltmp = yes

parallel_jobs =8 #M gb memory, between M/64~M/32
input_type = raw
read_type = clr # clr, ont, hifi
input_fofn = ${assemble}/input.fofn
workdir = ${assemble}/C01_nextdenovo-45

[correct_option]
read_cutoff = 1k
genome_size = 600m
seed_depth = 45
seed_cutoff = 0
sort_options = -m 50g -t 4
minimap2_options_raw = -t 4
pa_correction = 4
correction_options = -p 4

[assemble_option]
minimap2_options_cns = -t 4 -k17 -w17
minimap2_options_map = -t 4
nextgraph_options = -a 1 -q 10
" >${assemble}/run.cfg

ls ${trimmed}/C01_trimmed.fastq.gz > ${assemble}/input.fofn
nextDenovo ${assemble}/run.cfg