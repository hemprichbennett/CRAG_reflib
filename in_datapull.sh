#!/bin/bash

#SBATCH --time=15:00:00
#SBATCH --job-name=boldpull
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=8G
#SBATCH --partition=medium
#SBATCH --output=out.txt # the name of the output files
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.hemprich-bennett@zoo.ox.ac.uk



source activate $DATA/CRAG_reflib
nextflow bold_datapull.nf -profile cluster

