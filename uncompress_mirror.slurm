#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=uncompress_mirror
#SBATCH --account=enoriega
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --time=48:00:00
#SBATCH --mail-type=ALL
#SBATCH -o uncompress_mirror_job.out

apptainer run --cleanenv --bind /xdisk/enoriega/enoriega/pmc-mirrored/mirror:/app/input --bind /xdisk/enoriega/enoriega/pmc-flat:/app/output --env PARALLEL_JOBS=10 pmc-uncompress.sif