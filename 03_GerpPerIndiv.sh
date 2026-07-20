#!/bin/bash
#SBATCH --partition long
#SBATCH --nodes=1
#SBATCH -V
#SBATCH -o BedPerScaff_%a.o
#SBATCH -e BedPerScaff_%a.o
#SBATCH -J Chain2bed
#SBATCH --time=50:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --array=1-N # With N chromosomes in the genome


## AUTHOR : Maël Le Gouellec
## USE : This script creates on .bed per individual and per Scaffold/Chromosome with the associated coordinates, GERP score and genotype

# Modules

module load bedtools/2.31.1
module load bcftools/1.16

#Variables

IDREF='Maritimus'
IDQUERY='ArcosArcos'
FinalBed='/shared/projects/ants_supergenes/GERP/Chain/ArcosArcoscoor_polar_LiftedOverMaritimus_GerpScor_final.bed'
ListeScaff='/shared/projects/ants_supergenes/GERP/ListeScaffsBrownBear.tsv'
ListeIndivs='/shared/projects/ants_supergenes/GERP/ListeIndivsMarsicanBear.tsv'
VCF_dir='/shared/projects/ants_supergenes/GERP/VCF/'
Indiv_dir='/shared/projects/ants_supergenes/GERP/VCF_perIndiv/'
cd $WD

Scaff=${SLURM_ARRAY_TASK_ID}
        #grep -w $Scaff $FinalBed > ${IDQUERY}_Polar_Gerp_${Scaff}.bed
        #gunzip ${VCF_dir}Bear_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered.vcf.gz
        #bgzip ${VCF_dir}Bear_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered.vcf.gz
        tabix ${VCF_dir}Marsican_Scaffold_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered.vcf.gz
        bcftools view -R  ${IDQUERY}_Polar_Gerp_Scaffold_${Scaff}.bed ${VCF_dir}Marsican_Scaffold_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered.vcf.gz -Oz -o ${VCF_dir}Marsican_Scaffold_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered_GerpPos.vcf.gz
        tabix ${VCF_dir}Marsican_Scaffold_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered_GerpPos.vcf.gz

for Indiv in $(cat $ListeIndivs); do
        mkdir ${Indiv_dir}${Indiv}
        echo ${Indiv}
        i=$(cat -n $ListeIndivs | grep $Indiv | cut -f1)
        echo $i
        zcat ${VCF_dir}Marsican_Scaffold_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered_GerpPos.vcf.gz | \
                awk -v colIndiv="$i" 'BEGIN {OFS="\t"}{print $1,$2-1,$2,$3,$4,$5,substr($(colIndiv+9),1,1),substr($(colIndiv+9),3,1)}' | \
                awk '$7 != "." && $8 != "."' | awk 'length($5)+length($6) == 2' > \
                ${Indiv_dir}${Indiv}/Scaffold_${Scaff}_${Indiv}_MarsicanBear.bed

done
