#!/bin/bash
#SBATCH --job-name=recon
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=36
#SBATCH --mem-per-cpu=10G


trimmed="/dfs7/jje/jenyuw/Fish-project-hpc3/results/trimmed"
assemble="/dfs7/jje/jenyuw/Fish-project-hpc3/results/assembly"
aligned_bam="/dfs7/jje/jenyuw/Fish-project-hpc3/results/aligned_bam"
polishing="/dfs7/jje/jenyuw/Fish-project-hpc3/results/polishing"

nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

#P96 mapped to C01_flye the best

function polish_Ra {
# THREE input argumants:"path" tech rounds
# ${i} will be one of the assemblers
for k in $(ls $1 2> /dev/null)
do
echo "k is " "$k"
#pay attentino to the path everytime
name=$(echo $k | gawk -F "/" '{print $8}' | sed "s/_${i}//g")
echo $name
read=${trimmed}/${name}_trimmed.fastq.gz
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


file="${trimmed}/C01_trimmed.fastq.gz"
name=$(basename ${file}|sed s/"_trimmed.fastq.gz"//g)
read_type="CLR"
times="2"

module load anaconda/2022.05
conda activate post-proc
assembler="canu flye nextdenovo-45"
for i in `echo $assembler`
do
    if [[ $i == "flye" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assemble}/${name}_${i}/assembly.fasta" "${read_type}" "${times}"
    elif [[ $i == "canu" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assemble}/${name}_${i}/*.contigs.fasta" "${read_type}" "${times}"
    elif [[ $i == "nextdenovo-45" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assemble}/${name}_${i}/03.ctg_graph/nd.asm.fasta" "${read_type}" "${times}"
    else
    echo "NO such assembler was used"
    fi
done
conda deactivate
echo "It is the end!!"
