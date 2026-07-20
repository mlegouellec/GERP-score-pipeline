#!/bin/bash
#SBATCH --partition long
#SBATCH --nodes=1
#SBATCH -V
#SBATCH -o GerpPerIndiv_%a.o
#SBATCH -e GerpPerIndiv_%a.e
#SBATCH -J GerpPerIndiv
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-N # with N the total number of individuals


## AUTHOR : Maël Le Gouellec
## USE : This script uses the .bed for each individual to compute its Masked and Realized Load on the entire genome. It saves the total number of sites considered for later scaling.
##       The GERP-score threshold is set to 4 (four times fewer substitution at this site than the average across the phylogeny), but can be changed to any value of your choice

#Variables

Indice=${SLURM_ARRAY_TASK_ID} # Get the index of the individual from the array ID
ListeIndivs=<PATH_LIST_INDIV> # Same as step 03
Indiv_dir=<PATH_OUTPUT_INDIV> # Same as step 03

Indiv=$(cat -n $ListeIndivs | grep -w $Indice | cut -f2) # Get the Indiv in the list based on its index


#Full Gerp File per Indiv
cat ${Indiv_dir}/${Indiv}/*_GERP.bed > ${Indiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed

#Full Masked Load File per Indiv
awk '$6+$7 == 1' ${Indiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed > ${Indiv_dir}${Indiv}/MaskedLoadFile_${Indiv}.bed

#Full Realized Load File per Indiv
awk '$6+$7 == 2' ${Indiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed > ${Indiv_dir}${Indiv}/RealizedLoadFile_${Indiv}.bed

#Masked LOF Load File per Indiv
awk '$9 >= 4' ${Indiv_dir}${Indiv}/MaskedLoadFile_${Indiv}.bed > ${Indiv_dir}${Indiv}/MaskedLoad_TH4_${Indiv}.bed

#Realized LOF Load File per Indiv
awk '$9 >= 4' ${Indiv_dir}${Indiv}/RealizedLoadFile_${Indiv}.bed > ${Indiv_dir}${Indiv}/RealizedLoad_TH4_${Indiv}.bed

#Get the sum value per individual
wc -l ${Indiv_dir}${Indiv}/MaskedLoad_TH4_${Indiv}.bed > ${Indiv_dir}${Indiv}/${Indiv}_MaskedLoadTH4_count.tsv
wc -l ${Indiv_dir}${Indiv}/RealizedLoad_TH4_${Indiv}.bed > ${Indiv_dir}${Indiv}/${Indiv}_RealizedLoadTH4_count.tsv
wc -l ${Indiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed > ${Indiv_dir}${Indiv}/${Indiv}_TotSites_count.tsv
