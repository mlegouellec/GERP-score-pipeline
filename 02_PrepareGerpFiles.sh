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
TRANSANNO=<PATH_TRANSANNO_FUNCTION> # Dowload it here : ['https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/']

# Variables

BIGWIGFILE=<PATH_BIGWIG> # The BigWigFile contains the GERP score of the closest relative of our target species for which such information is available. Download : 
BEDGRAPH=<'PATH_BIGWIG_BED'> # Turn the BigWigFile into a .bed file
cd $WD

bigWigToBedGraph $BIGWIGFILE $BEDGRAPH

#$TRANSANNO chain-to-bed-vcf $CHAIN --output-query-bed ${IDQUERY}_coor.bed --query $REF --output-query-vcf REF_DIFF_RvQ.vcf.gz --output-reference-bed ${IDREF}_coor.bed --reference $QUERY --output-reference-vcf QUERY_DIFF_RvQ.vcf.gz

#cat ${IDREF}_coor.bed | awk '{print $1 "\t" $2 "\t" $3 "\t" $4}' | awk -F "\tchain_id:" '{print $1 "\t" $2}' | sed 's/;/\t/g' | sed 's/:/\t/g' | sed 's/-/\t/g' | awk '{print $5 "\t" $6 "\t" $7 "\t" $1 "\t" $2 "\t" $3}' > ${IDQUERY}on${IDREF}coor.bed

#cat ${IDQUERY}on${IDREF}coor.bed |cut -f4,5,6 > ${IDQUERY}on${IDREF}Sub.bed

#bedtools makewindows -b ${IDQUERY}on${IDREF}Sub.bed -w 1 > ${IDQUERY}on${IDREF}OnlyPerPosition.bed



#bedtools intersect -a $BEDGRAPH -b ${IDQUERY}on${IDREF}coor.bed -wa  > IntersectBigWig${IDQUERY}on${IDREF}.bed
