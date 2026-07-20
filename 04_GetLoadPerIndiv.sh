#!/bin/bash
#SBATCH --partition long
#SBATCH --nodes=1
#SBATCH -V
#SBATCH -o GerpPerIndiv.o
#SBATCH -e GerpPerIndiv.e
#SBATCH -J GerpPerIndiv
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-N # with N the total number of individuals

#Variables
Indice=${SLURM_ARRAY_TASK_ID}

ListeIndivs='/shared/projects/ants_supergenes/GERP/ListeIndivsMarsicanBear.tsv'
BedVCFGerp_dir='/shared/projects/ants_supergenes/GERP/VCF_perIndiv/'
GerpPerIndiv_dir='/shared/projects/ants_supergenes/GERP/Gerp_perIndiv/'

Indiv=$(cat -n $ListeIndivs | grep -w $Indice | cut -f2)

#for Indiv in $(cat $ListeIndivs); do
        mkdir ${GerpPerIndiv_dir}${Indiv}
        #Full Gerp File per Indiv
        cat ${BedVCFGerp_dir}/${Indiv}/*_Gerp.bed > ${GerpPerIndiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed

        #Full Masked Load File per Indiv
        awk '$6+$7 == 1' ${GerpPerIndiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed > ${GerpPerIndiv_dir}${Indiv}/MaskedLoadFile_${Indiv}.bed
        #Full Realized Load File per Indiv
        awk '$6+$7 == 2' ${GerpPerIndiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed > ${GerpPerIndiv_dir}${Indiv}/RealizedLoadFile_${Indiv}.bed
        #Masked LOF Load File per Indiv
        awk '$9 >= 4' ${GerpPerIndiv_dir}${Indiv}/MaskedLoadFile_${Indiv}.bed > ${GerpPerIndiv_dir}${Indiv}/MaskedLoad_TH4_${Indiv}.bed
        #Realized LOF Load File per Indiv
        awk '$9 >= 4' ${GerpPerIndiv_dir}${Indiv}/RealizedLoadFile_${Indiv}.bed > ${GerpPerIndiv_dir}${Indiv}/RealizedLoad_TH4_${Indiv}.bed

        #Get the sum value per individual
        wc -l ${GerpPerIndiv_dir}${Indiv}/MaskedLoad_TH4_${Indiv}.bed > ${GerpPerIndiv_dir}${Indiv}/${Indiv}_MaskedLoadTH4_count.tsv
        wc -l ${GerpPerIndiv_dir}${Indiv}/RealizedLoad_TH4_${Indiv}.bed > ${GerpPerIndiv_dir}${Indiv}/${Indiv}_RealizedLoadTH4_count.tsv
        wc -l ${GerpPerIndiv_dir}${Indiv}/FullGerpFile_${Indiv}.bed > ${GerpPerIndiv_dir}${Indiv}/${Indiv}_TotSites_count.tsv
#done
