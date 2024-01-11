#!/bin/bash
source ~/.bashrc

assembly="/home/jenyuw/Fish-project/result/assembly"
polishing="/home/jenyuw/Fish-project/result/polishing"
trimmed="/home/jenyuw/Fish-project/result/trimmed"
merqury_out="/home/jenyuw/Fish-project/result/merqury_out"
purge_dups="/home/jenyuw/Fish-project/result/purge_dups"
compleasm_out="/home/jenyuw/Fish-project/result/compleasm_out"
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

for i in `ls ${polishing}/C01.*.nextpolish.fasta.PolcaCorrected.fa`
do
name2=$(basename $i ".nextpolish.fasta.PolcaCorrected.fa")
busco -f -i $i -o ${name2}-polca-busco -m genome -l actinopterygii_odb10 -c ${nT}
done

#The final patched and purged assembly
busco -f -i /home/jenyuw/Fish-project/result/purge_dups/C01.fl.ca.nd.pd/purged.fa \
-o pd2-busco -m genome -l actinopterygii_odb10 -c 30

conda deactivate


##Compleasm


#this only need to be run once
#python3 /home/jenyuw/Software/compleasm_kit/compleasm.py download actinopterygii_odb10

python3 /home/jenyuw/Software/compleasm_kit/compleasm.py run -a /home/jenyuw/Fish-project/result/purge_dups/C01.fl.ca.nd.pd/purged.fa \
-o ${compleasm_out}/C01_3_pdpa -t ${nT} \
-l actinopterygii_odb10 -L "/home/jenyuw/Software/compleasm_kit/mb_downloads/"

##Merqury

#sh /home/jenyuw/Software/merqury/best_k.sh 135000000
#k=23.3272 ==> 23

meryl k=23 count ${trimmed}/P96.trimmed.r*.fastq.gz output ${merqury_out}/P96.meryl

cd /home/jenyuw/Fish-project/result/merqury_out
##Do NOT use "sh ......"
bash /home/jenyuw/Software/merqury/merqury.sh /home/jenyuw/Fish-project/result/merqury_out/P96.meryl \
/home/jenyuw/Fish-project/result/purge_dups/C01.fl.ca.nd.pd/purged.fa C01_3_papd