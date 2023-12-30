#!/bin/bash

## On Thoth
conda activate assemble
nohup flye --threads 30 \
--pacbio-raw /home/jenyuw/Fish-project/result/trimmed/C01_trimmed.fastq.gz \
--out-dir /home/jenyuw/Fish-project/result/assembly/C01_flye &
conda deactivate


## On Thoth
source ~/.bashrc
trimmed="/home/jenyuw/Fish-project/result/trimmed"
assemble="/home/jenyuw/Fish-project/result/assembly"

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
workdir = ${assemble}/${name}_nextdenovo-45

[correct_option]
read_cutoff = 1k
genome_size = 630m
seed_depth = 45
seed_cutoff = 0
sort_options = -m 100g -t 4
minimap2_options_raw = -t 4
pa_correction = 4
correction_options = -p 4 -max_lq_length 10k

[assemble_option]
minimap2_options_cns = -t 4 -k17 -w17
minimap2_options_map = -t 4
nextgraph_options = -A
" >${assemble}/run.cfg

ls ${trimmed}/C01_trimmed.fastq.gz > ${assemble}/input.fofn
nextDenovo ${assemble}/run.cfg



## On Hydra
trimmed="/home/jenyuw/Fish-project-Hy/result/trimmed"
assemble="/home/jenyuw/Fish-project-Hy/result/assembly"

conda activate assemble
canu -p C01 -d ${assemble}/C01_canu \
genomeSize=547m \
maxInputCoverage=90 \
minReadLength=500 \
minOverlapLength=500 \
maxThreads=60 \
correctedErrorRate=0.035 utgOvlErrorRate=0.065 trimReadsCoverage=2 trimReadsOverlap=500 \
stopOnLowCoverage=2 minInputCoverage=3 \
useGrid=false \
-raw -pacbio ${trimmed}/C01_trimmed.fastq.gz
conda deactivate