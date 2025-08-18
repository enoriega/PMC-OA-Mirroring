#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=citation_metadata
#SBATCH --account=enoriega
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --mail-type=ALL
#SBATCH -o citation_metadata.out

apptainer run --cleanenv --bind /xdisk/enoriega/enoriega/pmc-xml-split:/input --bind /xdisk/enoriega/enoriega/pmc-citations:/output  pmc-citations.sif