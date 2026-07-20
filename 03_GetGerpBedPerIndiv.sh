#!/bin/bash
#SBATCH --partition long
#SBATCH --nodes=1
#SBATCH -V
#SBATCH -o BedPerScaff_%a.o
#SBATCH -e BedPerScaff_%a.o
#SBATCH -J BedPerScaff
#SBATCH --time=50:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --array=1-N # With N chromosomes in the genome


## AUTHOR : Maël Le Gouellec
## USE : This script creates on .bed per individual and per Scaffold/Chromosome with the corresponding coordinates, GERP scores and genotypes

# Modules

module load bedtools/2.31.1
module load bcftools/1.16

#Variables

Scaff=${SLURM_ARRAY_TASK_ID} # Get the Scaffold/Chromosome number
IDpop=<ID_POP> # Population ID, used for writting the output of this script. If you have more than one pop in your VCF, use a general name and define populations later.
FinalBed=<PATH_FINAL_BED> # Final .bed with GERP scores obtained at the end of step 02, written in the same coordinates as the VCF
ListeIndivs=<PATH_LIST_INDIV> # .txt file with one individual name per row. CAUTION : They must be ordered just like in the VCF (first row == indiv in the first genotype column of the VCF, ...)
VCF_INPUT=<PATH_VCF> # VCF with the genotypes of all individuals. Includes "$Scaff".  Make sure it's bgzipped and indexed with 'tabix'
VCF_OUTPUT=<PATH_VCF_OUTPUT> #Same vcf filtered to keep only the positions for which we have a gerp score
Indiv_dir=<PATH_OUTPUT_INDIV> # Path to the directory where one folder per individual will be created

# Command lines

grep -w $Scaff $FinalBed > ${FinalBed}_${Scaff}.bed # Get one bed per scaffold/chromosome
gunzip ${VCF_dir}Bear_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered.vcf.gz
tabix ${VCF_dir}Marsican_Scaffold_${Scaff}_Flowqual_Noindels_Norepeat_DP_filtered.vcf.gz
bcftools view -R   ${FinalBed}_${Scaff}.bed $VCF_INPUT -Oz -o $VCF_OUTPUT
tabix  $VCF_OUTPUT

for Indiv in $(cat $ListeIndivs); do
        
        mkdir ${Indiv_dir}${Indiv}
        echo ${Indiv}
        i=$(cat -n $ListeIndivs | grep $Indiv | cut -f1) # Get the index of the individual in the VCF. It's why it's important that the list follows the same organization as the VCF.
        echo $i # CAUTION : Check if the the indiv and its index are matching
        
        zgrep -v '#'  $VCF_OUTPUT | \
                awk -v colIndiv="$i" 'BEGIN {OFS="\t"}{print $1,$2-1,$2,$3,$4,$5,substr($(colIndiv+9),1,1),substr($(colIndiv+9),3,1)}' | \ # Extract Chrom, Pos-1, Pos, ID, Ref, Alt, Genotype1~Indiv, Genotype2~Indiv 
                awk '$7 != "." && $8 != "."' | awk 'length($5)+length($6) == 2' > \  # Filter sites for which we have no missing data, INDELS and more than 2 alt (This should have been filtered already ! it's just an extra security)
                ${Indiv_dir}${Indiv}/Scaffold_${Scaff}_${Indiv}_${IDpop}.bed
                
        bedtools intersect -a ${FinalBed}_${Scaff}.bed  -b  ${Indiv_dir}${Indiv}/Scaffold_${Scaff}_${Indiv}_${IDpop}.bed -wa -wb | \ # Get the GERP scores for the .bed we obtained
        awk 'BEGIN {OFS="\t"}{print $13,$14,$15,$17,$18,$19,$20,$5,$12}' | \ # Selected columns : 'Scaff, Pos-1, Pos, Ref, Alt, Genotype1, Genotype2, Ancestral, Gerp score'
        awk 'BEGIN {OFS="\t"}{if ($4 != $8) {
                $6 = ($6 - 1)^2
                $7 = ($7 - 1)^2
                }print}' > \ # If the Ref != Ancestral, then in the genotype section 0 becomes 1 and 1 becomes 0. CAUTION : It's only true if we don't have more than 2 alleles at this position. Make sure your polarization framework excludes positions with more than 2 alleles for REF+Outgroups, or add a condition here '($5 == $8)'
        ${Indiv_dir}${Indiv}/Scaffold_${Scaff}_${Indiv}_${IDpop}_GERP.bed
        
done
