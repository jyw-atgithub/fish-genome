#!/bin/bash

repeat="/home/jenyuw/Fish-project/result/repeat"
purge_dups="/home/jenyuw/Fish-project/result/purge_dups"
final_genome="/home/jenyuw/Fish-project/result/final_genome"
ref="/home/jenyuw/Fish-project/reference"
annotation="/home/jenyuw/Fish-project/result/annotation"

##repeat modeling
#singularity build dfam-tetools.sif docker://dfam/tetools:latest
#singularity run dfam-tetools.sif
#singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest
#singularity run dfam-tetools-latest.sif --> Then, it enters the interactive mode
cd ${repeat}
singularity exec /home/jenyuw/Software/dfam-tetools-latest.sif BuildDatabase -name "C01_db" ${purge_dups}/C01.fl.ca.nd.pd/purged.fa
#singularity run -B /dfs7/jje/jenyuw/Fish-project-hpc3 dfam-tetools-latest.sif BuildDatabase -name "C01_db" /dfs7/jje/jenyuw/Fish-project-hpc3/purged.fa

singularity exec /home/jenyuw/Software/dfam-tetools-latest.sif RepeatModeler -database "C01_db" -threads 30 -LTRStruct \
 -recoverDir /home/jenyuw/Fish-project/result/repeat/RM_82009.SatJan132200052024
#singularity run -B /dfs7/jje/jenyuw/Fish-project-hpc3 dfam-tetools-latest.sif RepeatModeler -database "C01_db" -threads 60 -LTRStruct 


##repeat masking
##RepeatMasker v4.1.4 is also included in the singularity image
## we have the individually installed v4.1.6 but the configuration is not done yet
cd ${repeat}
singularity exec /home/jenyuw/Software/dfam-tetools-latest.sif RepeatMasker -gff -s \
-lib ${repeat}/C01_db-families.fa ${final_genome}/C01_final.fasta
#--> Then, the original fasta file is masked. Be careful!

##annotation

singularity exec /home/jenyuw/Software/galba.sif galba.pl --genome=${final_genome}/C01_final.fasta --species=Phytichthys_chirus \
--prot_seq=${ref}/GCF_016920845/protein.faa  --hints=${ref}/GCF_016920845/genomic2.gff \
--workingdir=${annotation} --threads 30 --crf