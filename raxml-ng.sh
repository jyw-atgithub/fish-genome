phylo="/dfs7/jje/jenyuw/Fish-project-hpc3/old/RAXML-NG"
msa="/dfs7/jje/jenyuw/Fish-project-hpc3/old/multiple-seq-alignments"

nT=$SLURM_CPUS_PER_TASK

#The gene sequences files needs to be manually check to merge incorrectly splited genes.
#The alignment files need to be renames and replace all the space by underscore.
#MSA is done with MEGA11
raxml-ng --check --msa ${msa}/chi_aligned.fas --model GTR+G --prefix ${phylo}/test

raxml-ng --all --msa ${msa}/chi_aligned.fas --prefix ${phylo}/chi \
--model "GTR+G" --tree "pars{25},rand{25}" --bs-trees 200 --threads ${nT} --seed 2 

# Trypsin (prss)
raxml-ng --check --msa ${msa}/less_prss_aligned.fas --model GTR+G --prefix ${phylo}/test
raxml-ng --all --msa ${msa}/less_prss_aligned.fas --prefix ${phylo}/prss \
--model "GTR+G" --tree "pars{25},rand{25}" --bs-trees 200 --threads ${nT} --seed 2 --redo

# Chymotrypsin (ctr & ctrl)
raxml-ng --check --msa ${msa}/ctr_aligned.fas --model GTR+G --prefix ${phylo}/test
raxml-ng --all --msa ${msa}/ctr_aligned.fas --prefix ${phylo}/ctr \
--model "GTR+G" --tree "pars{25},rand{25}" --bs-trees 200 --threads ${nT} --seed 2