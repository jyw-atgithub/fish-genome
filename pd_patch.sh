#!/bin/bash
trimmed="/home/jenyuw/Fish-project/result/trimmed"
polishing="/home/jenyuw/Fish-project/result/polishing"
purge_dups="/home/jenyuw/Fish-project/result/purge_dups"
patched="/home/jenyuw/Fish-project/result/patched"
pd_scripts="/home/jenyuw/Software/purge_dups/scripts"
pd_bin="/home/jenyuw/Software/purge_dups/bin"

nT=16
source ~/.bashrc

function purge {
    # $1 is number of threads
    # $2 is mapping option, 'map-pb', 'map-hifi' or 'map-ont'
    # $3 is primary assembly
    # $4 is the trimmed reads
    # $5 is the prefix
    #prefix=`basename $3 | gawk -F "." '{print $1 "." $2 "." $3}'`
    prefix=$5
    echo "the prefix is ${prefix}"
    mkdir ${purge_dups}/${prefix}
    cd ${purge_dups}/${prefix}

    minimap2 -t $1 -x $2 $3 $4 | pigz -p $1 -c - > ${prefix}.paf.gz
    ${pd_bin}/pbcstat ${prefix}.paf.gz
    ${pd_bin}/calcuts PB.stat > cutoffs 2>calcults.log
    ${pd_bin}/split_fa $3 > ${prefix}.split
    minimap2 -t $1 -x asm5 -DP ${prefix}.split ${prefix}.split |pigz -p $1 -c - > ${prefix}.split.self.paf.gz
    ${pd_bin}/purge_dups -2 -T cutoffs -c PB.base.cov ${prefix}.split.self.paf.gz > dups.bed 2> purge_dups.log

    ${pd_bin}/get_seqs -e dups.bed $3
}

purge ${nT} "map-pb" ${polishing}/C01.flye.nextpolish.fasta.PolcaCorrected.fa ${trimmed}/C01.trimmed.fastq.gz C01.flye.pd

##Nucmer alignment may take 6 to 7 hours with 32 threads.
##
ragtag.py patch -w -o ${patched}/C01_1 --aligner 'nucmer' \
--nucmer-params '--maxmatch -l 100 -c 500 -t 32' \
${purge_dups}/C01.flye.pd/purged.fa \
${polishing}/C01.canu.nextpolish.fasta.PolcaCorrected.fa


purge ${nT} "map-pb" ${patched}/C01_1/ragtag.patch.fasta ${trimmed}/C01.trimmed.fastq.gz C01.flye.canu.pd

ragtag.py patch -w -o ${patched}/C01_2 --aligner 'nucmer' \
--nucmer-params '--maxmatch -l 100 -c 500 -t 32' \
${purge_dups}/C01.flye.canu.pd/purged.fa \
${polishing}/C01.nextdenovo-45.nextpolish.fasta.PolcaCorrected.fa

purge ${nT} "map-pb" ${patched}/C01_2/ragtag.patch.fasta ${trimmed}/C01.trimmed.fastq.gz C01.fl.ca.nd.pd