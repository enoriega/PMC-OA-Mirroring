#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=split_files
#SBATCH --account=enoriega
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --mail-type=ALL
#SBATCH -o split_files_job.out

apptainer run --cleanenv --bind /xdisk/enoriega/enoriega/pmc-flat/xml:/app/input --bind /xdisk/enoriega/enoriega/pmc-flat/xml_file_list/allfiles.txt:/app/file_list.txt --bind /xdisk/enoriega/enoriega/pmc-xml-split:/app/output --env HOST_INPUT_DIR=/xdisk/enoriega/enoriega/pmc-flat/xml pmc-split.sif