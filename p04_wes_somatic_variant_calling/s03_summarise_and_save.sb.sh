#!/bin/bash

## s03_summarise_and_save.sb.sh
## Collect and plot summary metrics for wes lane variant calling
## Move data from HPC to NAS
## SLURM submission script
## Ellie Fewings, 03May18

#SBATCH -J summarise_and_save
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mail-type=ALL
#SBATCH --no-requeue
#SBATCH -p skylake

##SBATCH --qos=INTR
##SBATCH --time=01:00:00
##SBATCH -A TISCHKOWITZ-SL3

## Modules section (required, do not remove)
. /etc/profile.d/modules.sh
module purge
module load rhel7/default-peta4 

## Set initial working folder
cd "${SLURM_SUBMIT_DIR}"

## Read parameters
job_file="${1}"
logs_folder="${2}"
scripts_folder="${3}"
pipeline_log="${4}"

## Report settings and run the job
echo ""
echo "Job name: ${SLURM_JOB_NAME}"
echo "Allocated node: $(hostname)"
echo ""
echo "Initial working folder:"
echo "${SLURM_SUBMIT_DIR}"
echo ""
echo " ------------------ Output ------------------ "
echo ""

## Do the job
log="${logs_folder}/s03_summarise_and_save.log"
"${scripts_folder}/s03_summarise_and_save.sh" \
         "${job_file}" \
         "${logs_folder}" \
         "${scripts_folder}" \
         "${pipeline_log}" \ &> "${log}"
