#!/bin/bash
#SBATCH --job-name=nextPolish
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=36
#SBATCH --mem-per-cpu=10G
#SBATCH --time=7-00:00:00

nplib="/pub/jenyuw/Software/NextPolish/lib"
trimmed="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed"
assemble="/dfs7/jje/jenyuw/Fish-project-hpc3/results/assembly"
aligned_bam="/dfs7/jje/jenyuw/Fish-project-hpc3/results/aligned_bam"
polishing="/dfs7/jje/jenyuw/Fish-project-hpc3/results/polishing"

nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

function polish_Np {
    # FOUR input argumants:"path" tech rounds name
    # ${i} will be one of the assemblers
    for j in $(ls $1 2> /dev/null)
    do
        echo "polish_Np starts"
        round=$3
        name=$4
        read=${trimmed}/${name}_trimmed.fastq.gz
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
    if [[ $i == "flye" ]]
    then
    echo "Nextpolish $i now"
    name=`echo ${polishing}/C01.${i}.racon.fasta|gawk -F "/" '{print $8}'|gawk -F "." '{print $1}'`
    echo "name is $name"
    polish_Np ${polishing}/C01.${i}.racon.fasta "${read_type}" "3" ${name}
    elif [[ $i == "canu" ]]
    then
    echo "Nestpolish $i now"
    name=`echo ${polishing}/C01.${i}.racon.fasta|gawk -F "/" '{print $8}'|gawk -F "." '{print $1}'`
    echo "name is $name"
    polish_Np ${polishing}/C01.${i}.racon.fasta "${read_type}" "3" ${name}
    elif [[ $i == "nextdenovo-45" ]]
    then
    echo "Nextpolish $i now"
    name=`echo ${polishing}/C01.${i}.racon.fasta|gawk -F "/" '{print $8}'|gawk -F "." '{print $1}'`
    echo "name is $name"
    polish_Np ${polishing}/C01.${i}.racon.fasta "${read_type}" "3" ${name}
    else
    echo "NO such assembler was used"
    fi
done
echo "It is the end!!"