#!/bin/bash
#SBATCH --partition long
#SBATCH --nodes=1
#SBATCH -V
#SBATCH -o Alignment.o
#SBATCH -e 01_Alignment.e
#SBATCH -J 01_Alignment
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G

## AUTHOR : Maël Le Gouellec
## USE : This script uses MINIMAP to align a target genome, the one on which the fastqs were mapped, on the closest related species in the 

# Variables definition

RefGenome=<PATH_REFERENCE_GENOME>  #.fa, .fna, .fa.gz or .fna.gz
GerpGenome=<PATH_GERP_GENOME> #.fa, .fna, .fa.gz or .fna.gz
outdir=<PATH_OUTPUT> # .paf format


# Load packages

## For instruction on how to use minimap2, refer to 'https://github.com/lh3/minimap2'
MINIMAP=<PATH_MINIMAP2_FUNCTION> #Or just load the module, depending on how you installed minimap2
TRANSANNO=<PATH_TRANSANNO_FUNCTION> #Get it at 'https://github.com/informationsea/transanno'

# Run minimap

$MINIMAP -cx asm5 $GerpGenome $RefGenome > ${outdir}
#-cx asm5 allows to align sequences with ~0.1% divergence or less (closely related species). Adapt this argument to the divergence time between your genomes

# Convert .paf into .chain

$TRANSANNO minimap2chain $outdir --output ${outdir}.chain


