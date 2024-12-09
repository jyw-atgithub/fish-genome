#!/bin/bash

#SBATCH --job-name=busco
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=6G
source ~/.bashrc

bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
cd /dfs7/jje/jenyuw/Fish-project-hpc3/old/busco_out
newgrp jje
module load anaconda/2024.06
conda activate BUSCO
busco -i ${bl}/C01_final.fasta.masked -m genome -l actinopterygii_odb10 -c 16 -o C01_P_chirus