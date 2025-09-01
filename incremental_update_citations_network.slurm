#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=incremental_update_citations
#SBATCH --account=enoriega
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=16gb
#SBATCH --time=12:00:00
#SBATCH --mail-type=ALL
#SBATCH -o incremental_update_citations.out

apptainer run --cleanenv --bind /xdisk/enoriega/enoriega/pmc-citations:/input --bind /xdisk/enoriega/enoriega/citation_network:/output --env CONN_STRING="sqlite:////output/citation_network.db" pmc-citations.sif /bin/sh /app/incremental_populate_db.sh