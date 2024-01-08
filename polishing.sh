#!/bin/bash
trimmed="/home/jenyuw/Fish-project/result/trimmed"
assembly="/home/jenyuw/Fish-project/result/assembly"
aligned_bam="/home/jenyuw/Fish-project/result/aligned_bam"
polishing="/home/jenyuw/Fish-project/result/polishing"

nT=30
source ~/.bashrc

#P96 mapped to C01_flye the best

function polish_Ra {
# THREE input argumants:"path" tech rounds
# ${i} will be one of the assemblers
for k in $(ls $1 2> /dev/null)
do
echo "k is " "$k"
#pay attentino to the path everytime
name=$(echo $k | gawk -F "/" '{print $7}' | sed "s/_${i}//g")
echo $name
read=${trimmed}/${name}.trimmed.fastq.gz
read_type=$2
declare -A mapping_option=(["CLR"]="map-pb" ["hifi"]="asm20" ["ONT"]="map-ont")
if [[ $2 != "CLR" && $2 != "hifi" && $2 != "ONT" ]]
then
echo "The second argument can only be one of \"CLR, hifi, ONT\""
fi
round=$3
input=${k}
for ((count=1; count<=${round};count++))
do
echo "round $count"
echo "input is $input"
echo "the mapping option is ${mapping_option[$read_type]}"
minimap2 -x ${mapping_option[$read_type]} -t ${nT} -o ${aligned_bam}/${name}.trimmed-${i}.paf ${input} ${read}
echo "after manimap2"
racon -t ${nT} ${read} ${aligned_bam}/${name}.trimmed-${i}.paf ${input} >${polishing}/${name}.${i}.racon.fasta
echo "after racon"
if ((${count}!=${round}))
then
mv ${polishing}/${name}.${i}.racon.fasta ${polishing}/${name}.${i}.racontmp.fasta
input=${polishing}/${name}.${i}.racontmp.fasta
echo "round round round"
fi
done
rm ${aligned_bam}/${name}.trimmed-${i}.paf
rm ${polishing}/${name}.${i}.racontmp.fasta
done
}


file="/home/jenyuw/Fish-project/result/trimmed/C01.trimmed.fastq.gz"
name=$(basename ${file}|sed s/".trimmed.fastq.gz"//g)
read_type="CLR"

conda activate post-proc
assembler="canu flye nextdenovo-45"
for i in `echo $assembler`
do
    if [[ $i == "flye" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assembly}/${name}_${i}/assembly.fasta" "${read_type}" "3"
    elif [[ $i == "canu" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assembly}/${name}_${i}/*.contigs.fasta" "${read_type}" "3"
    elif [[ $i == "nextdenovo-45" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assembly}/${name}_${i}/03.ctg_graph/nd.asm.fasta" "${read_type}" "3"
    else
    echo "NO such assembler was used"
    fi
done
conda deactivate
echo "It is the end!!"

#on THOTH
nplib="/home/jenyuw/Software/NextPolish/lib"

function polish_Np {
    # THREE input argumants:"path" tech rounds
    # ${i} will be one of the assemblers
    for j in $(ls $1 2> /dev/null)
    do
        echo "polish_Np starts"
        name=`echo $j|gawk -F "/" '{print $7}'|gawk -F "." '{print $1}'`
        echo "name is $name"
        round=$3
        read=${trimmed}/${name}.trimmed.fastq.gz
        #pay attention to the read name, .fastq.gz or .fastq
        read_type=$2
        echo "the second argument is $2, is read_type $read_type"
        declare -A mapping_option=(["CLR"]='map-pb' ["hifi"]='asm20' ["ONT"]='map-ont')
        echo "The mapping option is ${mapping_option[$read_type]}"
        if [[ $2 != "CLR" && $2 != "hifi" && $2 != "ONT" ]]
        then
            echo "The second argument can only be one of \"CLR, hifi, ONT\""
        fi
        input=${j}
        for ((count=1; count<=${round};count++))
        do
            echo "round $count"
            echo "input is" $input
            minimap2 -a -x ${mapping_option[$read_type]} -t ${nT} ${input} ${read} |\
            samtools sort - -m 2g --threads ${nT} -o ${aligned_bam}/${name}.trimmed-${i}.sort.bam
            samtools index ${aligned_bam}/${name}.trimmed-${i}.sort.bam
            ls ${aligned_bam}/${name}.trimmed-${i}.sort.bam > ${polishing}/${count}.${i}.lgs.sort.bam.fofn
            # remember to give different names of reppeated used config or fofn files!!!
            # Nextpolish usually finish within 3 hours. It does not know whether the mapping result matches or not.
            python3 ${nplib}/nextpolish2.py -g ${input} -l ${polishing}/${count}.${i}.lgs.sort.bam.fofn \
            -r ${read_type} -p ${nT} -sp -o ${polishing}/${name}.${i}.nextpolish.fasta
            if ((${count}!=${round}));then
                mv ${polishing}/${name}.${i}.nextpolish.fasta ${polishing}/${name}.${i}.nextpolishtmp.fasta;
                input=${polishing}/${name}.${i}.nextpolishtmp.fasta;
            fi;
        done
        rm ${polishing}/${name}.${i}.nextpolishtmp.fasta
        rm ${aligned_bam}/${name}.trimmed-${i}.sort.bam
        rm ${aligned_bam}/${name}.trimmed-${i}.sort.bam.bai
        rm ${polishing}/${count}.${i}.lgs.sort.bam.fofn
    done
}

read_type="CLR"
assembler="canu flye nextdenovo-45"
for i in `echo $assembler`
do
    name=`echo ${i}|gawk -F "/" '{print $7}'|gawk -F "." '{print $1}'`
    if [[ $i == "flye" ]]
    then
    echo "Nextpolish $i now"
    polish_Np ${polishing}/C01.${i}.racon.fasta "${read_type}" "3"
    elif [[ $i == "canu" ]]
    then
    echo "Nestpolish $i now"
    polish_Np ${polishing}/C01.${i}.racon.fasta "${read_type}" "3"
    elif [[ $i == "nextdenovo-45" ]]
    then
    echo "Nextpolish $i now"
    polish_Np ${polishing}/C01.${i}.racon.fasta "${read_type}" "3"
    else
    echo "NO such assembler was used"
    fi
done
echo "It is the end!!"


trimmed="/home/jenyuw/Fish-project/result/trimmed"
assembly="/home/jenyuw/Fish-project/result/assembly"
aligned_bam="/home/jenyuw/Fish-project/result/aligned_bam"
polishing="/home/jenyuw/Fish-project/result/polishing"

nT=30

assembler="canu flye nextdenovo-45"
for i in `ls ${polishing}/*.nextpolish.fasta`
do
    name2=`echo ${i}|gawk -F "/" '{print $7}'|gawk -F "." '{print $1.$2}'`
    bash /home/jenyuw/Software/MaSuRCA-4.1.0/bin/polca.sh \
    -a $i \
    -r "${trimmed}/P96.trimmed.r1.fastq.gz ${trimmed}/P96.trimmed.r2.fastq.gz"
    -t ${nT} -m 4G
done