#!/bin/bash

trimmed="/home/jenyuw/Fish-project/result/trimmed"
purge_dups="/home/jenyuw/Fish-project/result/purge_dups"
scaffold="/home/jenyuw/Fish-project/result/scaffold"
polishing="/home/jenyuw/Fish-project/result/polishing"
source ~/.bashrc
#scaffolding and gap filling


conda activate ntLink
#because of too many dependencies, anaconda is more convenient
cp ${purge_dups}/C01.fl.ca.nd.pd/purged.fa ${scaffold}/C01.fa
ntLink_rounds run_rounds_gaps target=${scaffold}/C01.fa reads=${trimmed}/C01.trimmed.fastq.gz rounds=4 \
k=24 w=250 t=5 soft_mask=True
#max thread is 5
##Current output is ${scaffold}/C01.fa.k24.w250.z1000.ntLink.gap_fill.4rounds.fa
conda deactivate

#For Linux 64, Open MPI is built with CUDA awareness but this support is disabled by default.
#To enable it, please set the environment variable OMPI_MCA_opal_cuda_support=true before launching your MPI processes.

##Another method, SAMBA
bash /home/jenyuw/Software/MaSuRCA-4.1.0/bin/samba.sh \
-r ${scaffold}/C01.fa -q ${trimmed}/C01.trimmed.fastq.gz \
-t 20 -d pbclr -m 3000
##Current output is ${scaffold}/C01.fa.scaffolds.fa

#Polish again with short reads

scfd1="${scaffold}/C01.fa.k24.w250.z1000.ntLink.ntLink.ntLink.gap_fill.fa.k24.w250.z1000.ntLink.scaffolds.gap_fill.fa"
scfd2="${scaffold}/C01.fa.scaffolds.fa"
cp $scfd1 ${polishing}/C01.fa.k24.w250.z1000.ntLink.ntLink.ntLink.gap_fill.fa.k24.w250.z1000.ntLink.scaffolds.gap_fill.fa
cp $scfd2 ${polishing}/C01.fa.scaffolds.fa
scfd1="${polishing}/C01.fa.k24.w250.z1000.ntLink.ntLink.ntLink.gap_fill.fa.k24.w250.z1000.ntLink.scaffolds.gap_fill.fa"
scfd2="${polishing}/C01.fa.scaffolds.fa"

for i in $scfd1 $scfd2
do
bash /home/jenyuw/Software/MaSuRCA-4.1.0/bin/polca.sh \
-a $i \
-r "${trimmed}/P96.trimmed.r1.fastq.gz ${trimmed}/P96.trimmed.r2.fastq.gz" \
-t ${nT} -m 4G
done