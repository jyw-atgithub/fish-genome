#!/bin/bash
source ~/.bashrc
bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"

nT=$SLURM_CPUS_PER_TASK

cd /dfs7/jje/jenyuw/Fish-project-hpc3/old/blast
#We gathered our target sequence manually. Including:
#1. Chitinase
#2.  

#build the blast local database
makeblastdb -in C01_final.fasta.masked -dbtype nucl -parse_seqids -input_type fasta
#this is Cebidichthys violaceus (monkeyface prickleback)
makeblastdb -in CV_genome.fasta  -dbtype nucl -parse_seqids -input_type fasta
#This is high cockscomb (Anoplarchus purpurescens)
makeblastdb -in AP_genome.fasta -dbtype nucl -parse_seqids -input_type fasta


#tblastn -query chitinase.fasta -db C01_final.fasta.masked -evalue 0.1 -html -out chitinase.tblastn.html
#blastn -query chitinase.DNA.fasta -db C01_final.fasta.masked -html -out chitinase.blastn.html
#tblastn -query chio-1.fasta -db C01_final.fasta.masked -evalue 0.1 -html -out chio-1.tblastn.html
#blastn -query chio-1.DNA.fasta -db C01_final.fasta.masked -html -out chio-1.blastn.html

##Use mRNA DNA sequence, tblastn or blastn with whole segment of gene is not very specific
## trying different output formats
#blastn -query chi-A.mRNA.fasta -db C01_final.fasta.masked -html -out chi-A.blastn.html #html is not easy to read
#blastn -query chi-A.mRNA.fasta -db C01_final.fasta.masked -outfmt 3 -out chi-A.blastn.out
#blastn -query chi-A.mRNA.fasta -db C01_final.fasta.masked -outfmt 1 -out chi-A.blastn.out

for i in ${bl}/query/*.fasta
do
name=$(basename ${i} .fasta)
blastn -query ${i} -db ${bl}/C01_final.fasta.masked -outfmt 7 -out ${bl}/output/${name}_PC.blastn.out
blastn -query ${i} -db ${bl}/CV_genome.fasta -outfmt 7 -out ${bl}/output/${name}_CV.blastn.out
blastn -query ${i} -db ${bl}/AP_genome.fasta -outfmt 7 -out ${bl}/output/${name}_AP.blastn.out
done

#blastn -query CEsterLipase.fasta -db ${bl}/C01_final.fasta.masked -outfmt 7 -out ${bl}/CEsterLipase.blastn.out
#blastn -query chymotrypsin_new.fasta -db ${bl}/C01_final.fasta.masked -outfmt 7 -out ${bl}/chymotrypsin_new.blastn.out
#blastn -query anpep.fasta -db ${bl}/C01_final.fasta.masked -outfmt 7 -out ${bl}/anpep.blastn.out