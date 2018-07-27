#!/bin/bash

# a00_start_pipeline.sh
# Start wes variant calling
# Ellie Fewings, 06Oct17

## Read parameter
job_file="${1}"
scripts_folder="${2}"

# Read job's settings
source "${scripts_folder}/a01_read_config.sh"

# Start lane pipeline log
mkdir -p "${logs_folder}"
pipeline_log="${logs_folder}/a00_pipeline_${project}_${library}.log"

echo "WES somatic variant calling" > "${pipeline_log}"
echo "Started: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"

echo "====================== Settings ======================" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"

source "${scripts_folder}/a02_report_settings.sh" >> "${pipeline_log}"

echo "=================== Pipeline steps ===================" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"


# Submit the first step to the queue
slurm_time="--time=${time_copy_in}"
slurm_account="--account=${account}"

sbatch "${slurm_time}" "${slurm_account}" \
  "${scripts_folder}/s01_copy_and_dispatch.sb.sh" \
  "${job_file}" \
  "${logs_folder}" \
  "${scripts_folder}" \
  "${pipeline_log}"

# Update pipeline log
echo "Submitted s01_copy_and_dispatch: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
