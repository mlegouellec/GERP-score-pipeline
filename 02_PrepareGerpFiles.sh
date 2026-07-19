#!/bin/bash
#SBATCH --partition=def
#SBATCH --qos=mesopsl1_def_long
#SBATCH --nodes=1
#SBATCH -V
#SBATCH -o Chain2bed.o
#SBATCH -e Chain2bed.e
#SBATCH -J Chain2bed
#SBATCH --time=50:00:00
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=10G

# Modules and functions
module load gcc/9.2.0
module load samtools/1.10
bigWigToBedGraph=<PATH_bigWigToBedGraph_FUNCTION> # Dowload it here : ['https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/']
LiftOver=<PATH_TRANSANNO_FUNCTION> # Dowload it here : ['https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/']

# Variables

BIGWIGFILE=<PATH_BIGWIG> # The BigWigFile contains the GERP score of the closest relative of our target species for which such information is available. Download : ['https://ftp.ensembl.org/pub/current/compara/conservation_scores/92_mammals.gerp_conservation_score/']
BEDGRAPH=<PATH_BIGWIG_BED> # Turn the BigWigFile into a .bed file
BED_DATA=<PATH_DATASET_BED> # polarized vcf turned into a bed, only with the positions. The total VCF is too heavy, we only use the coordinates from the target genome to make the link with GERP values from the closely related genome
ChainFile=
# Command lines

$bigWigToBedGraph $BIGWIGFILE $BEDGRAPH ## Change the BIGWIG file into a .bed

$LiftOver $BED_DATA $ChainFile ${IDQUERY}coor_polar_LiftedOver${IDREF}.bed ${IDQUERY}coor_polar_LiftedOver${IDREF}_UNMAPPED.bed
#Get Both coordinates in the bed
#awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $5+1}' ${IDQUERY}coor_polar_LiftedOver${IDREF}.bed > ${IDQUERY}coor_polar_LiftedOver${IDREF}_format.bed
#Get Gerp Score
bedtools intersect -a ${IDQUERY}coor_polar_LiftedOver${IDREF}_format.bed -b $BEDGRAPH -wa -wb | cut -f4-10 > ${IDQUERY}coor_polar_LiftedOver${IDREF}_GerpScor.bed
#Get Polar Values
bedtools intersect -a ${IDREF}on${IDQUERY}coor_polar.bed -b  ${IDQUERY}coor_polar_LiftedOver${IDREF}_GerpScor.bed -wa -wb  > ${IDQUERY}coor_polar_LiftedOver${IDREF}_GerpScor_final.bed

