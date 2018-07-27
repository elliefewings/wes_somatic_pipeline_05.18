#!/bin/bash

# s03_summarise_and_save.sh
# save results of wes lane alignment and QC
# Ellie Fewings, 06Oct17

# Stop at any errors
set -e

# Read parameters
job_file="${1}"
logs_folder="${2}"
scripts_folder="${3}"
pipeline_log="${4}"

# Update pipeline log
echo "Make: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"

# ------------------------------------------------- #
#         Set environment and start job log         #
# ------------------------------------------------- #

echo "Saving results for wes lane alignment and QC"
echo "Started: $(date +%d%b%Y_%H:%M:%S)"
echo ""

source "${scripts_folder}/a01_read_config.sh"
echo "Read settings"
echo ""

# ------- Save results to NAS ------- #

# Progress report
echo "Started saving results to NAS"

# Suspend stopping at errors
set +e

# Prepare environment for rsync
results_folder="${results_folder}/${project}/${library}/${project}_${library}_raw_vcf"
ssh -x "${source_server}" "mkdir -p ${results_folder}"

# Clean up
rm -r "${library_folder}/bams_tmp"

# Copy results
rsync -thrve "ssh -x" "${library_folder}" "${source_server}:${results_folder}/"
exit_code="${?}"

# Stop if copying failed
if [ "${exit_code}" != "0" ] 
then
  echo ""
  echo "Failed copying results to NAS"
  echo "Script terminated"
  echo ""
  exit
fi

# Restore stopping at errors
set -e

# Progress messages
echo ""
echo "Completed saving results to NAS: $(date +%d%b%Y_%H:%M:%S)"
echo ""
echo "Completed all tasks"
echo ""

echo "Saved results to NAS: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"
echo "Done all pipeline tasks" >> "${pipeline_log}"
echo "" >> "${pipeline_log}"

# Remove bulk results from cluster 
#rm -fr "${source_fastq_folder}"
#rm -fr "${bam_folder}"
