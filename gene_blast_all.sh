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

## Blast all genes. This take days.
##Search Condition: limit the search in Actinopterygi (taxid:7898)
blastx -db ${anno}/refseq_database/refseq_protein -best_hit_score_edge 0.1 -taxids 7898 -num_threads $SLURM_CPUS_PER_TASK \
-max_target_seqs 5 -outfmt "7 ssciname sblastname stitle std" -query ${anno}/braker.codingseq -out ${anno}/PC_all_blastx.txt

blastx -db ${anno}/refseq_database/refseq_protein -best_hit_score_edge 0.1 -taxids 7898 -num_threads $SLURM_CPUS_PER_TASK \
-max_target_seqs 5 -outfmt "7 ssciname sblastname stitle std" -query ${anno}/AP_augustus.hints.codingseq -out ${anno}/AP_all_blastx.txt

blastx -db ${anno}/refseq_database/refseq_protein -best_hit_score_edge 0.1 -taxids 7898 -num_threads $SLURM_CPUS_PER_TASK \
-max_target_seqs 10 -outfmt "7 ssciname sblastname stitle std" -query ${anno}/CV_braker.codingseq -out ${anno}/CV_all_blastx.txt

##Parsing the blastx output. Match the query name and the subject title.
for i in  ${anno}/AP_all_blastx.txt ${anno}/PC_all_blastx.txt
do
cat ${i} | grep -w -e "# Query" -e "bony fishes" -e "# 0 hits found" |grep --no-group-separator -A 1 "# Query"|\
gawk -F "\t" '/#/ {print $0} !/#/ {print $3} '|sed -e "s/\[.*\]//g" |sed 's/# Query: //g;s/# 0 hits found/No match/g' |\
gawk 'NR % 2 == 1 {printf $1}; NR % 2 == 0 {print "\t" $0}' > ${i/_all_blastx.txt/}_blastx_names.tsv
done
#Use printf in gawk to avoid newline in the output

##Give the sequences names according to matched ID and subject title.
#Remove extra newlines (unwrap) in the fasta file with seqkit
seqkit seq -w 0 ${anno}/braker.codingseq > ${anno}/braker.codingseq.tmp
printf "" >${anno}/PC_named.codingseq
##This is a slow method. A faster way is make a table containing the ID and sequence, then join the table with the *_blastx_names.tsv
while read line
do
target=`echo ${line}|gawk '{print $1}'`
echo ${target}
cat ${anno}/braker.codingseq.tmp|grep -A 1 "^>${target}" |sed s@"^>${target}"@">${line}"@g|sed 's/\t/ /g'  >> PC_named.codingseq
done <${anno}/PC_blastx_names.tsv

seqkit seq -w 0 ${anno}/AP_augustus.hints.codingseq > ${anno}/AP_augustus.hints.codingseq.tmp
printf "" >${anno}/AP_named.codingseq
while read line
do
target=`echo ${line}|gawk '{print $1}'`
echo ${target}
cat ${anno}/AP_augustus.hints.codingseq.tmp |grep -A 1 "^>${target}" |sed s@"^>${target}"@">${line}"@g|sed 's/\t/ /g'  >> AP_named.codingseq
done <${anno}/AP_blastx_names.tsv

##Another way to find our target genes
##The results are written in "Gene_list.md"
##This is the current best way.
grep -w "lipase" PC_all_blastx.txt |grep -w -E "ester|bile" |less -S
grep -w chitinase ${anno}/AP_all_blastx.txt |gawk -F "\t" ' $6 > 50 {print $4}'|sort -h|uniq|less -S
grep -w "pepsin" PC_all_blastx.txt |less -S
grep -w "aminopeptidase" PC_all_blastx.txt| grep -E -v "methionine|endoplasmic|xaa-Pro|puromycin|leucyl|glutamyl|cytosol|aspartyl" |cut -f 4 |sort -h | uniq -c|less -S

#"trypsinogen" has not been view
grep -w "trypsin" PC_all_blastx.txt| grep -v "inhibitor" |cut -f 4 |sort -h | uniq -c|less -S


grep "chymotrypsin" PC_all_blastx.txt|grep -v "elastase" |less -S