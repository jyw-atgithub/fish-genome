raw="/home/jenyuw/Fish-project/raw"
kmer="/home/jenyuw/Fish-project/result/kmer"
trimmed="/home/jenyuw/Fish-project/result/trimmed"

cd /home/jenyuw/Fish-project/result/kmer
kmc -k27 -m50  -t24 ${raw}/R251-C01.1-Reads.fastq.gz C01 ${kmer}
kmc_tools transform C01 histogram C01.histo

kmc -k27 -m50  -t6 ${raw}/nR040-L2-G6-P94-CAATCGAA-GCACACGC-READ1-Sequences.txt.gz P94_1 ${kmer}
kmc_tools transform P94_1 histogram P94_1.histo
kmc -k27 -m50  -t6 ${raw}/nR040-L2-G6-P94-CAATCGAA-GCACACGC-READ2-Sequences.txt.gz P94_2 ${kmer}
kmc_tools transform P94_2 histogram P94_2.histo

kmc -k27 -m50  -t6 ${raw}/nR040-L2-G6-P95-AAGTACAG-GTCACGTC-READ1-Sequences.txt.gz P95_1 ${kmer}
kmc_tools transform P95_1 histogram P95_1.histo
kmc -k27 -m50  -t6 ${raw}/nR040-L2-G6-P95-AAGTACAG-GTCACGTC-READ2-Sequences.txt.gz P95_2 ${kmer}
kmc_tools transform P95_2 histogram P95_2.histo

kmc -k27 -m50  -t6 ${raw}/nR040-L2-G6-P96-CCGTGCCA-GCAGCTCC-READ1-Sequences.txt.gz P96_1 ${kmer}
kmc_tools transform P96_1 histogram P96_1.histo
kmc -k27 -m50  -t6 ${raw}/nR040-L2-G6-P96-CCGTGCCA-GCAGCTCC-READ2-Sequences.txt.gz P96_2 ${kmer}
kmc_tools transform P96_2 histogram P96_2.histo

kmc -k27 -m50  -t6 ${raw}/nR168-L4-G2-P01-AATCCGTT-AGCATATT-READ1-Sequences.txt.gz P01_1 ${kmer}
kmc_tools transform P01_1 histogram P01_1.histo
kmc -k27 -m50  -t6 ${raw}/nR168-L4-G2-P01-AATCCGTT-AGCATATT-READ2-Sequences.txt.gz P01_2 ${kmer}
kmc_tools transform P01_2 histogram P01_2.histo

kmc -k27 -m50 -t24 -fa /home/jenyuw/Fish-project/result/trimmed/C01.canu_trimmed.fasta canu_C01 /home/jenyuw/Fish-project/result/kmer/
kmc_tools transform canu_C01 histogram canu_C01.histo




#result
#http://genomescope.org/genomescope2.0/analysis.php?code=God37WkMwjRA6hk5ypTD

conda activate qc
zcat ${raw}/R251-C01.1-Reads.fastq.gz|chopper -l 530 --headcrop 15 --tailcrop 15 -t 30|\
bgzip -@ 30 -c > ${trimmed}/C01_trimmed.fastq.gz
conda deactivate
