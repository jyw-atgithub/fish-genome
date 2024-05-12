#!/bin/bash
source ~/.bashrc

#nT=30
nT=$SLURM_CPUS_PER_TASK

#cd /dfs7/jje/jenyuw/Fish-project-hpc3/blast
cd /dfs7/jje/jenyuw/Fish-project-hpc3/old/blast
#We gathered our target sequence manually. Including:
#1. Chitinase
#2.  

#build the blast local database
makeblastdb -in C01_final.fasta.masked -dbtype nucl -parse_seqids -input_type fasta

#tblastn -query chitinase.fasta -db C01_final.fasta.masked -evalue 0.1 -html -out chitinase.tblastn.html
#blastn -query chitinase.DNA.fasta -db C01_final.fasta.masked -html -out chitinase.blastn.html
#tblastn -query chio-1.fasta -db C01_final.fasta.masked -evalue 0.1 -html -out chio-1.tblastn.html
#blastn -query chio-1.DNA.fasta -db C01_final.fasta.masked -html -out chio-1.blastn.html

##Use mRNA DNA sequence, tblastn or blastn with whole segment of gene is not very specific
## trying different output formats
#blastn -query chi-A.mRNA.fasta -db C01_final.fasta.masked -html -out chi-A.blastn.html #html is not easy to read
#blastn -query chi-A.mRNA.fasta -db C01_final.fasta.masked -outfmt 3 -out chi-A.blastn.out
#blastn -query chi-A.mRNA.fasta -db C01_final.fasta.masked -outfmt 1 -out chi-A.blastn.out

blastn -query CHI-A.fasta -db C01_final.fasta.masked -outfmt 7 -out CHI-A.blastn.out
blastn -query CHID1.fasta -db C01_final.fasta.masked -outfmt 7 -out CHID1.blastn.out
blastn -query CHIO-I.fasta -db C01_final.fasta.masked -outfmt 7 -out CHIO-I.blastn.out
blastn -query CHIO-II.fasta -db C01_final.fasta.masked -outfmt 7 -out CHIO-II.blastn.out
blastn -query CHS.fasta -db C01_final.fasta.masked -outfmt 7 -out CHS.blastn.out