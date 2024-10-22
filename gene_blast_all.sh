#!/bin/bash
#SBATCH --job-name=blastx
#SBATCH -A jje_lab
#SBATCH --constraint=nvme
#SBATCH --array=1
#SBATCH --cpus-per-task=48
#SBATCH -t 7-00:00:00   # 7 days
#SBATCH --mail-type=fail,end
#SBATCH --mail-user="jenyuw@uci.edu"

anno="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"
cd ${anno}

## Blast all genes
blastx -db ${anno}/refseq_database/refseq_protein -best_hit_score_edge 0.1 -taxids 7898 -num_threads $SLURM_CPUS_PER_TASK \
-max_target_seqs 5 -outfmt "7 ssciname sblastname stitle std" -query ${anno}/braker.codingseq -out ${anno}/PC_all_blastx.txt

blastx -db ${anno}/refseq_database/refseq_protein -best_hit_score_edge 0.1 -taxids 7898 -num_threads $SLURM_CPUS_PER_TASK \
-max_target_seqs 5 -outfmt "7 ssciname sblastname stitle std" -query ${anno}/AP_Genomeomicsbox.fasta -out ${anno}/AP_all_blastx.txt