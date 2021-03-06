#!/bin/bash

# a02_report_settings.sh
# Report settings for wes somatic variant calling pipeline
# Ellie Fewings, 06Oct17

pipeline_info=$(grep "^#" "${job_file}")
pipeline_info=${pipeline_info//"# "/}

echo "------------------- Pipeline summary -----------------"
echo ""
echo "${pipeline_info}"
echo ""
echo "--------- Data location and analysis settings --------"
echo ""
echo "source_server: ${source_server}"
echo "source_folder: ${source_folder}"
echo ""
echo "results_folder: ${results_folder}"
echo ""
echo "project: ${project}"
echo "library: ${library}"
echo "Tumour normal file: ${tnfile}"
echo ""
echo "------------------- HPC settings ---------------------"
echo ""
echo "working_folder: ${working_folder}"
echo ""
echo "account: ${account}"
echo ""
echo "time_copy_in: ${time_copy_in}"
echo "time_variant_calling: ${time_variant_calling}"
echo "time_move_out: ${time_move_out}"
echo ""
echo "----------------- Standard settings ------------------"
echo ""
echo "scripts_folder: ${scripts_folder}"
echo ""
echo "Tools"
echo "-----"
echo ""
echo "tools_folder: ${tools_folder}"
echo ""
echo "java: ${java}"
echo "gatk: ${gatk}"
echo "" 
echo "samtools: ${samtools}"
echo "bcftools: ${bcftools}"
echo ""
echo "Resources" 
echo "---------"
echo ""
echo "resources_folder: ${resources_folder}"
echo ""
echo "ref_genome: ${ref_genome}"
echo ""
echo "targets_intervals: ${targets_intervals}"
echo ""
echo "Working folders"
echo "---------------"
echo ""
echo "project_folder: ${project_folder}"
echo "library_folder: ${library_folder}"
echo "logs_folder: ${logs_folder}"
echo "vcf_folder: ${vcf_folder}"
echo "" 
