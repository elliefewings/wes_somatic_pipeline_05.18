#!/bin/bash

## s02_somatic_variant_calling.sb.sh
## Wes sample variant calling
## SLURM submission script
## Ellie Fewings, 03May18

#SBATCH -J somatic_variant_calling
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mail-type=ALL
#SBATCH --no-requeue
#SBATCH -p skylake


## Modules section (required, do not remove)
. /etc/profile.d/modules.sh
module purge
module load rhel7/default-peta4 

## Set initial working folder
cd "${SLURM_SUBMIT_DIR}"

## Read parameters
sample="${1}"
chrom="${2}"
tumour="${3}"
normal="${4}"
job_file="${5}"
logs_folder="${6}"
scripts_folder="${7}"
pipeline_log="${8}"

## Report settings and run the job
echo ""
echo "Job name: ${SLURM_JOB_NAME}"
echo "Allocated node: $(hostname)"
echo ""
echo "Initial working folder:"
echo "${SLURM_SUBMIT_DIR}"
echo ""
echo "Sample: ${sample}"
echo ""
echo " ------------------ Output ------------------ "
echo ""

# Log file
sample_log="${logs_folder}/s02_somatic_variant_calling_${sample}_${chrom}.log"

#Run job
"${scripts_folder}/s02_somatic_variant_calling.sh" \
  "${sample}" \
  "${chrom}" \
	"${tumour}" \
  "${normal}" \
  "${job_file}" \
  "${logs_folder}" \
  "${scripts_folder}" \
  "${pipeline_log}" &> "${sample_log}"

