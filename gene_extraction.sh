#!/bin/bash

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
gene_seq="/dfs7/jje/jenyuw/Fish-project-hpc3/old/gene_sequences"
bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
anno="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"

#######Let's unify the coordinates, so we rely on the annotation results (gff file)#######

##Retrive only the Chitinase genes from AP and PC, for phylogeny.
seqkit grep -w 0 -p jg22439.t1,jg22449.t1,jg22450.t1,jg10722.t1,jg14608.t1,jg14609.t1,jg15508.t1,jg15509.t1,jg15510.t1,jg15511.t1 \
${anno}/AP_augustus.hints.codingseq >${gene_seq}/AP_chitinase.fasta

seqkit grep -w 0 -p g20404.t1,g20409.t1,g20410.t1,g16524.t1,g14866.t1,g14867.t1,g10378.t1 \
${anno}/braker.codingseq > ${gene_seq}/PC_chitinase.fasta

##Different chitinase gene set, by blast all
seqkit grep -w 0 -p jg10722.t1,jg12213.t1,jg14608.t1,jg14609.t1,jg15508.t1,jg15509.t1,jg15510.t1,jg15511.t1,jg22439.t1,jg22443.t1,jg22444.t1,jg22447.t1,jg22448.t1,jg22449.t1,jg22450.t1 ${anno}/AP_augustus.hints.codingseq >${gene_seq}/AP_chitinase_2.fasta

seqkit grep -w 0 -p g20404.t1,g20409.t1,g20410.t1,g16524.t1,g14866.t1,g14867.t1,g10374.t1,g10375.t1,g10376.t1,g10377.t1,g10378.t1 ${anno}/braker.codingseq > ${gene_seq}/PC_chitinase_2.fasta

##Merge all sequences of a gene from all species. It will be used for phylogeny.
cat ${bl}/query/chitinase_salmon.fasta  ${bl}/query/chitinase_sticlkeback.fasta ${gene_seq}/AP_chitinase.fasta ${gene_seq}/PC_chitinase.fasta > ${gene_seq}/all_chitinase.fasta

#similar tricks on pepsinogen genes
seqkit grep -p jg14418.t1,jg14423.t1,jg5382.t1,jg27196.t1 ${anno}/AP_augustus.hints.codingseq >${gene_seq}/AP_pepsinogen.fasta #the sequence of jg14418 & jg14423 are merged, because it looks like an annotation error.
seqkit grep -p g20032.t1,g4760.t1,g15024.t1 ${anno}/braker.codingseq >${gene_seq}/PC_pepsinogen.fasta

##Extract the CDS sequence of lipase (CEL)
#PC
seqkit grep -w 0 -p g17563.t1,g17564.t1,g19849.t1 ${anno}/braker.codingseq >${gene_seq}/PC_CEL.fasta
#AP
seqkit grep -w 0 -p jg5889.t1,jg5890.t1,jg5891.t1,jg22915.t1 ${anno}/AP_augustus.hints.codingseq >${gene_seq}/AP_CEL.fasta

##Extract the CDS sequence of amylase2 (amy2)
#PC
seqkit grep -w 0 -p "g4512.t1" ${anno}/braker.codingseq >${gene_seq}/PC_amy2.fasta
#AP
seqkit grep -w 0 -p "jg8309.t1" ${anno}/AP_augustus.hints.codingseq >${gene_seq}/AP_amy2.fasta
#CV
seqkit grep -w 0 -p "g11333.t1,g11334.t1,g11335.t1" ${anno}/CV_braker.codingseq >${gene_seq}/CV_amy2.fasta




##Extract the CDS sequence of possible anapep in PC
seqkit grep -w 0 -p g11134.t1,g11206.t1,g11207.t1,g12581.t1,g12662.t1,g12662.t2,g13180.t1,g14890.t1,g18432.t1,g18433.t1,g4207.t1 ${anno}/braker.codingseq >${gene_seq}/PC_possible-anapep.fasta
##Actual anapep in PC
seqkit grep -w 0 -p "g11134.t1,g11206.t1,g11207.t1,g18432.t1,g18433.t1" ${anno}/braker.codingseq >${gene_seq}/PC_anapep.fasta
##in AP ##jg25411 and jg25410 were merged manually
seqkit grep -w 0 -p "jg11917.t1,jg22992.t1,jg22991.t1,jg25412.t1,jg25411.t1,jg25410.t1" ${anno}/AP_augustus.hints.codingseq >${gene_seq}/AP_anapep.fasta
##in CV
seqkit grep -w 0 -p "g19645.t1,g2854.t1,g2855.t1,g19387.t1,g19388.t1" ${anno}/CV_braker.codingseq >${gene_seq}/CV_anapep.fasta



##The following method is less effecent and less accurate.
: <<'SKIP'
asm="/dfs7/jje/jenyuw/Fish-project-hpc3/old/C01_final.fasta"
old="/dfs7/jje/jenyuw/Fish-project-hpc3/old"

#Extract the coordinate of CEL&CEL-like genes
minimap2 -a --cs -x splice:hq -uf -t ${nT} ${asm} ${old}/blast/CEL-like.fasta ${old}/blast/CEsterLipase.fasta| samtools view -bS - |samtools sort -@ ${nT} -o ${old}/C01_CELs-asm.bam
samtools index -@ ${nT} ${old}/C01_CELs-asm.bam

bedtools bamtobed -split -i ${old}/C01_CELs-asm.bam > ${gene_seq}/C01_CELs-asm.bed
bedtools bamtobed  -i ${old}/C01_CELs-asm.bam > ${gene_seq}/C01_CELs-asm.nosplit.bed
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_CELs-asm.nosplit.bed > ${gene_seq}/C01_CELs.fasta
#If we do not use "-split" in bedtool, we will get the entire gene sequence.
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_CELs-asm.bed |\
seqkit rmdup |seqkit sort > ${gene_seq}/C01_CELs.cds.fasta
#If we use "-split" in bedtool, we will only get most of the aligned coding regions so we need to manually conjugate the segments of each one gene.

bedtools bamtobed -split -i ${old}/C01_chitinase-asm.bam > ${gene_seq}/C01_chitinase-asm.bed
bedtools bamtobed  -i ${old}/C01_chitinase-asm.bam > ${gene_seq}/C01_chitinase-asm.nosplit.bed
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_chitinase-asm.nosplit.bed > ${gene_seq}/C01_chitinase.fasta
bedtools getfasta -fi ${asm} -bed ${gene_seq}/C01_chitinase-asm.bed |\
seqkit rmdup |seqkit sort > ${gene_seq}/C01_chitinase.cds.fasta
SKIP