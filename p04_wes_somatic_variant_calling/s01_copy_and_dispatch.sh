#!/bin/bash

# s01_copy_and_dispatch.sh
# Wes lane alignment pipeline
# Copy source files and dispatch samples to nodes
# Ellie Fewings, 06Oct17

# Stop at any errors
set -e

# Read parameters
job_file="${1}"
scripts_folder="${2}"
pipeline_log="${3}"

# Update pipeline log
echo "Started s01_copy_and_dispatch: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"

# ================= Copy source files to cluster ================= #

# Progress report to the job log
echo "Started copying source files to cluster"
echo ""

# Set parameters
source "${scripts_folder}/a01_read_config.sh"
echo "Read settings"
echo ""

# Copy files
mkdir -p "${library_folder}/bams_tmp"

# Suspend stopping at errors
set +e

rsync -thrve "ssh -x" "${source_server}:${source_folder}/" "${library_folder}/bams_tmp" 
exit_code="${?}"

# Stop if copying failed
if [ "${exit_code}" != "0" ] 
then
    echo ""
    echo "Failed getting source data from NAS"
    echo "Script terminated"
    echo ""
    exit
fi

# Restore stopping at errors
set -e

# Completion message to the job log
echo ""
echo "Completed copying source files to cluster: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# ================= Dispatch samples to nodes for processing ================= #

# Make folders on cluster
mkdir -p "${vcf_folder}"

# Progress update 
echo "Made working folders on cluster"
echo ""

# Suspend stopping at errors
set +e

# Set time and account for pipeline submissions
slurm_time="--time=${time_variant_calling}"
slurm_account="--account=${account}"

# Split files into chromosomes
while read sample tumour normal
do
  if [ "${sample}" != "sample" ]
  then
  echo "${sample}"
  for n in {1..20}; do
    # Start pipeline on a separate node
    sbatch "${slurm_time}" "${slurm_account}" \
           "${scripts_folder}/s02_somatic_variant_calling.sb.sh" \
           "${sample}" \
           "chr${n}" \
	         "${tumour}" \
		       "${normal}" \
           "${job_file}" \
           "${logs_folder}" \
           "${scripts_folder}" \
           "${pipeline_log}"
    done    
  fi
done < "${tnfile}"

echo ""

# Progress update 
echo "Submitted all samples: $(date +%d%b%Y_%H:%M:%S)"
echo ""

echo "Completed s01_copy_and_dispatch: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"