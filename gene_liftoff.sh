#!/bin/bash
bl="/dfs7/jje/jenyuw/Fish-project-hpc3/old/blast"
anno="/dfs7/jje/jenyuw/Fish-project-hpc3/old/annotation"
#change the sequence names of assembly from NCBI to fit the original gff
#JBFTZD010000001.1 Anoplarchus purpurescens isolate Ap_1_San_Simeon_UCI contig_149, whole genome shotgun sequence
#only keep contig_*
#(...) would capture the characters specified inside of the parens
#\1 inserts the contents of the first capture group which is what matches between the first set of parentheses.
#the sed command was generated by Copilot first and corrected manually.
cd ${bl}
cat ${bl}/GCA_041002825.1_ASM4100282v1_genomic.fna | sed -E s/'>.*contig_([0-9]+),.*'/'>contig_\1'/g > ${bl}/AP_genome.fasta
#the gff has some nonoverlapping sequence names with the fasta file because the assembly was pruned by NCBI
grep "^>" ${bl}/AP_genome.fasta|tr -d ">" >name_infasta.txt #486 contigs
gawk '{print $1}' ${anno}/AP_renamed.gff|sort | uniq >name_ingff.txt #326 contigs
cat name_infasta.txt name_ingff.txt|sort | uniq >name_Union.txt #489 names
cat name_Union.txt name_infasta.txt|sort | uniq -u >name_only_gff.txt #results: contig_2416, contig_3098, contig_3099

#remove the redundant part of sequence names and gene names in the gff file
#The file "AP_braker.gff" came from Donovan
cd ${anno}
cat ${anno}/AP_braker.gff | sed -E s/'^(scaffold|contig|Backbone)_([0-9]+).*arrow_1'/'contig_\2'/g |\
sed s/"file_1_file_1_"//g |\
grep -v -E "contig_2416|contig_3098|contig_3099" >${anno}/AP_renamed.gff


#change the sequence names of CV assembly from NCBI to fit the original gff
sed -E s/'.*Seg([0-9]+)_quiver_quiver_pilon,.*'/'>Seg\1|quiver|quiver|pilon'/g GCA008087265.1_genome.fna >${bl}/CV_genome.fasta

##Lift the gene annotation from AP to P.chirus
##incomplete
module load anaconda/2024.06
conda activate liftoff
liftoff -p 8 -g ${anno}/AP_renamed.gff -o ${anno}/AP_lifted_PC.gff -u ${anno}/AP_unmapped_features.txt ${bl}/C01_final.fasta.masked ${bl}/AP_genome.fasta
##Lift the gene annotation from CV to P.chirus
##use our new annotation (all in CV_re-annotation)
#the genome sequence names were also changes
liftoff -p 8 -g ${anno}/CV_braker.gtf -o ${anno}/CV_lifted_PC.gtf -u ${anno}/CV_unmapped_features.txt ${bl}/C01_final.fasta.masked ${bl}/CV_genome.rename.fasta
##gene IDs are changed from "g????" to "gene_????" Super weird
conda deactivate
module unload anaconda/2024.06

##Now, do similar work on CV genome
##Installation of AGAT by conda, micromamba and maunally all failed. So switch to singularity.
#module load perl/5.30.0 R/4.3.3
#module load anaconda/2024.06
#module load singularity/3.11.3
#singularity pull docker://quay.io/biocontainers/agat:1.4.1--pl5321hdfd78af_0
#singularity run /pub/jenyuw/Software/agat_1.4.1--pl5321hdfd78af_0.sif
###Singulariy also FAILED.


#####
##### A newer program called "LiftOn" is available
#####

module load python/3.10.2
#git clone https://github.com/Kuanhao-Chao/LiftOn
#cd LiftOn
#python3 setup.py install --user
lifton -t 8 -D \
-g ${anno}/CV_braker.gtf \
-o ${anno}/CV_lifted-lift-on_PC.gtf \
-u ${anno}/CV_unmapped_features-lift-on.txt \
${bl}/C01_final.fasta.masked ${bl}/CV_genome.rename.fasta

lifton -t 8 -D -g CV_braker.gtf ${bl}/C01_final.fasta.masked CV_genome.rename.fasta
##NOT Working so far