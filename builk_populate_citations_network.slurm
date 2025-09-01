#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=bulk_populate_citations
#SBATCH --account=enoriega
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --constraint=hi_mem
#SBATCH --mem=82G
#SBATCH --time=12:00:00
#SBATCH --mail-type=ALL
#SBATCH -o bulk_populate_citations.out

# Run this on PUMA for better high memory availability

apptainer run --cleanenv --bind /xdisk/enoriega/enoriega/pmc-citations:/input --bind /xdisk/enoriega/enoriega/citation_network:/output --env CONN_STRING="sqlite:////output/citation_network.db" pmc-citations.sif /bin/sh /app/bulk_populate_db.sh