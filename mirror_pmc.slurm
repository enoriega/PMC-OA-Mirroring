#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=mirror_pmc
#SBATCH --account=enoriega
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=48:00:00
#SBATCH --mail-type=ALL
#SBATCH -o mirror_pmc_job.out

apptainer run --cleanenv --bind /xdisk/enoriega/enoriega/pmc-mirrored:/app --env PARALLEL_TRANSFERS=4 pmc-mirror.sif