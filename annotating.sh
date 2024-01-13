#!/bin/bash

repeat="/home/jenyuw/Fish-project/result/repeat"
purge_dups="/home/jenyuw/Fish-project/result/purge_dups"

##repeat modeling
#singularity build dfam-tetools.sif docker://dfam/tetools:latest
#singularity run dfam-tetools.sif
#singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest
#singularity run dfam-tetools-latest.sif --> Then, it enters the interactive mode

singularity exec /home/jenyuw/Software/dfam-tetools-latest.sif RepeatModeler -database \ -threads 30 

##repeat masking

##annotation

singularity exec galba.sif galba.pl --genome=genome.fa --species=speciesname --prot_seq=proteins.fa --hints=hints.gff \
--species=sname --threads 30 --workingdir=/path/to/wd/ --crf  