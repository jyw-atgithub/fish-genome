#!/bin/bash
source ~/.bashrc

assembly="/home/jenyuw/Fish-project/result/assembly"
polishing="/home/jenyuw/Fish-project/result/polishing"
trimmed="/home/jenyuw/Fish-project/result/trimmed"
merqury_out="/home/jenyuw/Fish-project/result/merqury_out"
purge_dups="/home/jenyuw/Fish-project/result/purge_dups"
compleasm_out="/home/jenyuw/Fish-project/result/compleasm_out"
scaffold="/home/jenyuw/Fish-project/result/scaffold"
merqury="/home/jenyuw/Software/merqury"
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

#The scaffolds
busco -f -i ${scaffold}/C01.fa.scaffolds.fa \
-o C01_3_samba-busco -m genome -l actinopterygii_odb10 -c 2
#BUSCO --> S:97.8%,D:1.1%
busco -f -i ${scaffold}/C01.fa.k24.w250.z1000.ntLink.gap_fill.4rounds.fa \
-o C01_3_ntLink_4-busco -m genome -l actinopterygii_odb10 -c 2
#BUSCO --> 
conda deactivate


##Compleasm


#this only need to be run once
#python3 /home/jenyuw/Software/compleasm_kit/compleasm.py download actinopterygii_odb10

python3 /home/jenyuw/Software/compleasm_kit/compleasm.py run -a /home/jenyuw/Fish-project/result/purge_dups/C01.fl.ca.nd.pd/purged.fa \
-o ${compleasm_out}/C01_3_pdpa -t ${nT} \
-l actinopterygii_odb10 -L "/home/jenyuw/Software/compleasm_kit/mb_downloads/"
nT=2

python3 /home/jenyuw/Software/compleasm_kit/compleasm.py run -a ${scaffold}/C01.fa.scaffolds.fa \
-o ${compleasm_out}/C01_3_samba -t ${nT} \
-l actinopterygii_odb10 -L "/home/jenyuw/Software/compleasm_kit/mb_downloads/"
#read 599086489 bases in 183 contigs --> S:99.20%, 3611; D:0.49%, 18

python3 /home/jenyuw/Software/compleasm_kit/compleasm.py run -a ${scaffold}/C01.fa.k24.w250.z1000.ntLink.gap_fill.4rounds.fa \
-o ${compleasm_out}/C01_3_ntLink_4 -t ${nT} \
-l actinopterygii_odb10 -L "/home/jenyuw/Software/compleasm_kit/mb_downloads/"
#read 597291837 bases in 112 contigs -->S:99.26%, 3613; D:0.47%, 17

python3 /home/jenyuw/Software/compleasm_kit/compleasm.py run -a ${polishing}/C01.fa.scaffolds.fa.PolcaCorrected.fa \
-o ${compleasm_out}/C01_3_samba_polca -t ${nT} \
-l actinopterygii_odb10 -L "/home/jenyuw/Software/compleasm_kit/mb_downloads/"
#read 599045612 bases in 183 contigs --> S:99.23%, 3612; D:0.47%, 17

python3 /home/jenyuw/Software/compleasm_kit/compleasm.py run -a ${polishing}/C01.fa.k24.w250.z1000.ntLink.ntLink.ntLink.gap_fill.fa.k24.w250.z1000.ntLink.scaffolds.gap_fill.fa.PolcaCorrected.fa \
-o ${compleasm_out}/C01_3_ntLink_4_polca -t ${nT} \
-l actinopterygii_odb10 -L "/home/jenyuw/Software/compleasm_kit/mb_downloads/"
#read 597236490 bases in 112 contigs --> S:99.26%, 3613 D:0.47%, 17

##Merqury
#bash /home/jenyuw/Software/merqury/best_k.sh 135000000
#k=23.3272 ==> 23
meryl k=23 count ${trimmed}/P96.trimmed.r*.fastq.gz output ${merqury_out}/P96.meryl

cd /home/jenyuw/Fish-project/result/merqury_out
##Do NOT use "sh ......"
bash ${merqury}/merqury.sh /home/jenyuw/Fish-project/result/merqury_out/P96.meryl \
/home/jenyuw/Fish-project/result/purge_dups/C01.fl.ca.nd.pd/purged.fa C01_3_papd

asm1="${scaffold}/C01.fa.k24.w250.z1000.ntLink.ntLink.ntLink.gap_fill.fa.k24.w250.z1000.ntLink.scaffolds.gap_fill.fa"
bash ${merqury}/merqury.sh /home/jenyuw/Fish-project/result/merqury_out/P96.meryl $asm1 "C01_3_ntLink_4"

asm2="${scaffold}/C01.fa.scaffolds.fa"
bash ${merqury}/merqury.sh /home/jenyuw/Fish-project/result/merqury_out/P96.meryl $asm2 "C01_3_samba"

asm3="${polishing}/C01.fa.k24.w250.z1000.ntLink.ntLink.ntLink.gap_fill.fa.k24.w250.z1000.ntLink.scaffolds.gap_fill.fa.PolcaCorrected.fa"
bash ${merqury}/merqury.sh /home/jenyuw/Fish-project/result/merqury_out/P96.meryl $asm3 "C01_3_ntLink_4_polca"

asm4="${polishing}/C01.fa.scaffolds.fa.PolcaCorrected.fa"
bash ${merqury}/merqury.sh /home/jenyuw/Fish-project/result/merqury_out/P96.meryl $asm4 "C01_3_samba_polca"