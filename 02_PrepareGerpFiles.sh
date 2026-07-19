#!/bin/bash
#SBATCH --partition=def
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

BIGWIGFILE=<PATH_BIGWIG> # The BigWigFile contains the GERP score of the closest relative of our target species for which such information is available. Download it here : ['https://ftp.ensembl.org/pub/current/compara/conservation_scores/92_mammals.gerp_conservation_score/']
BEDGRAPH=<PATH_BIGWIG_BED> # Turn the BigWigFile into a .bed file
BED_DATA=<PATH_DATASET_BED> # vcf turned into a bed, only with the positions. The total VCF is too heavy, we only use the coordinates from the target genome to make the link with GERP values from the closely related genome. Restrict the VCF to the positions that can be accurately polarized
BED_POL=<PATH_POLARIZATION_DATFRAME> # Bedfile with polarized alleles : Chrom, Pos-1, Pos, Ancestral Allele
ChainFile=<PATH_OUTPUT>.paf
Lifted_Coor=<PATH_LIFTED_COORDINATES_BED> # This is a .bed format
UnmappedCoor=<PATH_UNLIFTED_COORDINATES_BED> # Unmapped regions from the original coordinates, .bed format

# Command lines

$bigWigToBedGraph $BIGWIGFILE $BEDGRAPH ## Change the BIGWIG file into a .bed

$LiftOver $BED_DATA $ChainFile $Lifted_Coor $UnmappedCoor ## Lifts over the coordinates of the target genome on the GERP score genome. 

awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $5+1}' $Lifted_Coor > $Lifted_Coor.format.bed ## Correct format for the .bed

bedtools intersect -a $Lifted_Coor.format.bed -b $BEDGRAPH -wa -wb | cut -f4-10 > $Lifted_Coor.format.gerp.bed ## Get the GERP scores for the lifted over positions

bedtools intersect -a $BED_POL -b  $Lifted_Coor.format.gerp.bed -wa -wb  > $Lifted_Coor.format.gerp.final.bed ## Associate GERP scores and Ancestral allele in the target genome

