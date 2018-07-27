#!/bin/bash

# a01_read_config.sh
# Parse congig file for wes lane alignment pipeline
# Ellie Fewings, 06Oct17

# Function for reading parameters
function get_parameter()
{
	local parameter="${1}"
  local line
	line=$(awk -v p="${parameter}" 'BEGIN { FS=":" } $1 == p {print $2}' "${job_file}") 
	echo ${line} # return value
}

# === Data location and analysis settings === # 

source_server=$(get_parameter "Data server") # e.g. admin@mgqnap2.medschl.cam.ac.uk
source_folder=$(get_parameter "Data location") # e.g. /share/lib/

results_folder=$(get_parameter "Project location") # e.g. /share/lib/

project=$(get_parameter "Project") # e.g. project1
library=$(get_parameter "Library") # e.g. library1
tnfile=$(get_parameter "Tumour normal file") # e.g. /share/ellie/tnfile.txt

# =============== HPC settings ============== #

working_folder=$(get_parameter "working_folder") # e.g. /scratch/medgen/users/alexey

account=$(get_parameter "Account to use on HPC") # e.g. TISCHKOWITZ-SL2

time_copy_in=$(get_parameter "Max time requested for copying source files (hrs.min.sec)") # e.g. 00.30.00
time_copy_in=${time_copy_in//./:} # substitute dots to colons 

time_variant_calling=$(get_parameter "Max time requested for variant calling (hrs.min.sec)") # e.g. 02.00.00
time_variant_calling=${time_variant_calling//./:} # substitute dots to colons
 
time_move_out=$(get_parameter "Max time requested for moving results out of HPC (hrs.min.sec)") # e.g. 00.30.00
time_move_out=${time_move_out//./:} # substitute dots to colons

# ============ Standard settings ============ #

scripts_folder=$(get_parameter "scripts_folder") # e.g. /scratch/medgen/scripts/wes_lane_alignment

# ----------- Tools ---------- #

tools_folder=$(get_parameter "tools_folder") # e.g. /scratch/medgen/tools

java=$(get_parameter "java") # e.g. java/jre1.8.0_40/bin/java
java="${tools_folder}/${java}"

gatk=$(get_parameter "gatk") # e.g. "gatk/gatk-3.7-0/GenomeAnalysisTK.jar"
gatk="${tools_folder}/${gatk}"

samtools=$(get_parameter "samtools") # e.g. samtools/samtools-1.2/bin/samtools
samtools="${tools_folder}/${samtools}"

bcftools=$(get_parameter "bcftools") # e.g. bcftools/bcftools-1.3.1/bin/bcftools
bcftools="${tools_folder}/${bcftools}"


# ----------- Resources ---------- #

resources_folder=$(get_parameter "resources_folder") # e.g. /scratch/medgen/resources

ref_genome=$(get_parameter "ref_genome") # e.g. gatk_bundle/b37/decompressed/human_g1k_v37.fasta
ref_genome="${resources_folder}/${ref_genome}"

targets_intervals=$(get_parameter "targets_intervals") 
# e.g. illumina_nextera/nexterarapidcapture_exome_targetedregions_v1.2.b37.intervals
targets_intervals="${resources_folder}/${targets_intervals}"

# ----------- Working folders ---------- #

project_folder="${working_folder}/${project}" # e.g. project1
library_folder="${project_folder}/${library}" # e.g. library1

logs_folder=$(get_parameter "logs_folder") # e.g. f00_logs
logs_folder="${library_folder}/${logs_folder}"

vcf_folder=$(get_parameter "vcf_folder") # e.g. f01_vcfs
vcf_folder="${library_folder}/${vcf_folder}"


