#!/bin/bash
source ~/.bashrc

nT=30
#nT=$SLURM_CPUS_PER_TASK

cd /dfs7/jje/jenyuw/Fish-project-hpc3/blast

#We gathered our target sequence manually. Including:
#1. Chitinase
#2.  

#build the blast local database
makeblastdb -in C01_final.fasta.masked -dbtype nucl -parse_seqids -input_type fasta

tblastn -query chitinase.fasta -db C01_final.fasta.masked -evalue 0.1 -html -out chitinase.tblastn.html
blastn -query chitinase.DNA.fasta -db C01_final.fasta.masked -html -out chitinase.blastn.html

tblastn -query chio-1.fasta -db C01_final.fasta.masked -evalue 0.1 -html -out chio-1.tblastn.html
blastn -query chio-1.DNA.fasta -db C01_final.fasta.masked -html -out chio-1.blastn.html