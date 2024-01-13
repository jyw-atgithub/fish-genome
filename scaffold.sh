#!/bin/bash

trimmed="/home/jenyuw/Fish-project/result/trimmed"
purge_dups="/home/jenyuw/Fish-project/result/purge_dups"
scaffold="/home/jenyuw/Fish-project/result/scaffold"

#scaffolding and gap filling


conda activate ntLink
#because of too many dependencies, anaconda is more convenient
nohup ntLink_rounds run_rounds_gaps target=${purge_dups}/C01.fl.ca.nd.pd/purged.fa reads=${trimmed}/C01.trimmed.fastq.gz rounds=4 \
k=24 w=250 t=5 soft_mask=True > ${scaffold}/ntLink.out &
#max thread is 5
conda deactivate

#For Linux 64, Open MPI is built with CUDA awareness but this support is disabled by default.
#To enable it, please set the environment variable OMPI_MCA_opal_cuda_support=true before launching your MPI processes.