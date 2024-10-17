#!/bin/bash

anno="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"
bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
g_seq="/dfs7/jje/jenyuw/Fish-project-hpc3/old/gene_sequences"
cd ${anno}
##Use IGV to view the genome, gene-assembly bam file and the braker.gtf file. Find the gene and neighnoring genes. Put the names into "seq_names.txt"

#Retrive the full sequence of genes from AP. We do not have it's CDS sequence. 
printf "" >${anno}/AP_chitinase_neighbors.gff
while read line
do
grep ${line} ${anno}/AP_renamed.gff|grep "mRNA" >> ${anno}/AP_chitinase_neighbors.gff
done < ${anno}/AP_seq_names.txt
seqkit subseq --gtf ${anno}/AP_chitinase_neighbors.gff  ${bl}/AP_genome.fasta >${anno}/AP_chitinase_neighbors.fasta

#Extract the CDS sequence from PC. 
seqkit grep -n -f ${anno}/PC_seq_names.txt  ${anno}/braker.codingseq > ${anno}/PC_chitinase_neighbors.fasta




#blastx -remote -db refseq_protein -html -outfmt 7 -query need_to_blast.fasta -out function_blastx.out
##Because "blastx -remote" is not compatible with "-taxids", so we have 2 solutions:
##1. Download the refseq_protein database and use it locally
##2. upload the need_to_blast.fasta to NCBI blastx online service

##Search Condition: limit the search in Actinopterygi (taxid:7898)
update_blastdb.pl --decompress refseq_protein #only needed once
##To enable filtering by taxid, we need a file called "taxonomy4blast.sqlite3"
wget https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz #only needed once

## Real blastx locally
for i in ${anno}/AP_chitinase_neighbors.fasta #${anno}/PC_chitinase_neighbors.fasta
do
blastx -db ${anno}/refseq_database/refseq_protein -best_hit_score_edge 0.1 -taxids 7898 -num_threads $SLURM_CPUS_PER_TASK \
-max_target_seqs 10 -html -outfmt "7 ssciname sblastname stitle std" \
-query ${i} -out ${i/.fasta/}_blastx.out
done


#blastdbcmd -db ./refseq_database/refseq_protein -entry XP_034391422.1 -outfmt "%t"

bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"
minimap2 --cs -a -x asm20 -t $SLURM_CPUS_PER_TASK ${bl}/C01_final.fasta.masked ${bl}/AP_genome.fasta | samtools view -bS - |\
samtools sort -o ${old}/AP-to-PC_genome.bam
samtools index ${old}/AP-to-PC_genome.bam
minimap2 --cs -a -x asm20 -t $SLURM_CPUS_PER_TASK ${bl}/C01_final.fasta.masked ${bl}/CV_genome.fasta | samtools view -bS - |\
samtools sort -o ${old}/CV-to-PC_genome.bam
samtools index ${old}/CV-to-PC_genome.bam

