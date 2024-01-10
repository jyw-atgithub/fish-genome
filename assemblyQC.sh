#!/bin/bash
source ~/.bashrc

assembly="/home/jenyuw/Fish-project/result/assembly"
polishing="/home/jenyuw/Fish-project/result/polishing"
nT=30

conda activate busco
for i in flye canu nextdenovo-45
do
    if [[ $i == "flye" ]]
    then
    busco -f -i "${assembly}/C01_${i}/assembly.fasta" -o C01-${i}-busco -m genome -l actinopterygii_odb10 -c ${nT}
    elif [[ $i == "canu" ]]
    then
    busco -f -i `ls ${assembly}/C01_${i}/*.contigs.fasta` -o C01-${i}-busco -m genome -l actinopterygii_odb10 -c ${nT}
    elif [[ $i == "nextdenovo-45" ]]
    then
    busco -f -i "${assembly}//C01_${i}/03.ctg_graph/nd.asm.fasta" -o C01-${i}-busco -m genome -l actinopterygii_odb10 -c ${nT}
    else
    echo "NO such assembler was used"
    fi
done

for i in `ls ${polishing}/C01.*.racon.fasta`
do
name2=$(basename $i ".racon.fasta")
busco -f -i $i -o ${name2}-racon-busco -m genome -l actinopterygii_odb10 -c ${nT}
done


conda deactivate


busco -f -i /home/jenyuw/Fish-project/result/purge_dups/C01.flye.canu.pd/purged.fa \
-o pd2-busco -m genome -l actinopterygii_odb10 -c 30