#!/bin/bash

cd /dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation
##Use IGV to view the genome, gene-assembly bam file and the braker.gtf file. Find the gene and neighnoring genes. Put the names into "seq_names.txt"

seqkit grep -n -f seq_names.txt  braker.codingseq > need_to_blast.fasta

#blastx -remote -db refseq_protein -html -outfmt 7 -query need_to_blast.fasta -out function_blastx.out
##Because "blastx -remote" is not compatible with "-taxids", so we have 2 solutions:
##1. Download the refseq_protein database and use it locally
##2. upload the need_to_blast.fasta to NCBI blastx online service

##Search Condition: limit the search in Actinopterygi (taxid:7898)
update_blastdb.pl --decompress refseq_protein


