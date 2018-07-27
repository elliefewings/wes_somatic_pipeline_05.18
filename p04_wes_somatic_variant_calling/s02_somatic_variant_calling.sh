#!/bin/bash

# s02_align_and_qc_pe.sh
# Wes sample alignment and QC
# Ellie Fewings, 06Oct17

# Stop at any errors
set -e

# Read parameters
sample="${1}"
chrom="${2}"
tumour="${3}"
normal="${4}"
job_file="${5}"
logs_folder="${6}"
scripts_folder="${7}"
pipeline_log="${8}"

#Add extra tools
tabix="/rds/project/erf33/rds-erf33-medgen/tools/htslib/htslib-1.3.1/bin/tabix"
bgzip="/rds/project/erf33/rds-erf33-medgen/tools/htslib/htslib-1.3.1/bin/bgzip"

# Update pipeline log
echo "Started ${sample}_${chrom}: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"

# Progress report to the job log
echo "WES sample variant calling"
echo "Started: $(date +%d%b%Y_%H:%M:%S)"
echo ""
echo "sample: ${sample} ${chrom}"
echo ""

echo "====================== Settings ======================"
echo ""

source "${scripts_folder}/a01_read_config.sh"
source "${scripts_folder}/a02_report_settings.sh"

echo "====================================================="
echo ""

# ------- Variant calling ------- #

#Get intervals file for chromosome

targets="/rds/project/erf33/rds-erf33-medgen/resources/illumina_nextera/intervals_chunks/nexterarapidcapture_exome_targetedregions_v1.2.b37.${chrom}.intervals"

#Set output
sample_dir="${vcf_folder}/${sample}_vcfs"
vcf_out="${sample_dir}/${sample}_${chrom}_tmp.vcf"

mkdir -p "${sample_dir}"

#Run variant calling
"${java}" -jar "${gatk}" \
  -T MuTect2 \
  -R "${ref_genome}" \
  -L "${targets}" -ip 10 \
  -maxAltAlleles 6 \
  -stand_call_conf 30 \
  --tumor_lod 4 \
  -A DepthPerAlleleBySample \
  -A BaseQualitySumPerAlleleBySample \
  -nda \
  -I:tumor "${library_folder}/bams_tmp/${tumour}" \
  -I:normal "${library_folder}/bams_tmp/${normal}" \
  -nct 15 \
  -o "${vcf_out}"
  
#Change VCF name once complete
vcf_raw="${sample_dir}/${sample}_${chrom}_raw.vcf"

mv "${vcf_out}" "${vcf_raw}"
mv "${vcf_out}.idx" "${vcf_raw}.idx"
  
#Check if variant calling is finished for that sample and combine vcfs

if [ $(ls ${sample_dir}/*_raw.vcf -1 | wc -l) == "20" ]  
then
  "${java}" -cp "${gatk}" org.broadinstitute.gatk.tools.CatVariants \
    -R "${ref_genome}" \
    -V "${sample_dir}/${sample}_chr1_raw.vcf" \
    -V "${sample_dir}/${sample}_chr2_raw.vcf" \
    -V "${sample_dir}/${sample}_chr3_raw.vcf" \
    -V "${sample_dir}/${sample}_chr4_raw.vcf" \
    -V "${sample_dir}/${sample}_chr5_raw.vcf" \
    -V "${sample_dir}/${sample}_chr6_raw.vcf" \
    -V "${sample_dir}/${sample}_chr7_raw.vcf" \
    -V "${sample_dir}/${sample}_chr8_raw.vcf" \
    -V "${sample_dir}/${sample}_chr9_raw.vcf" \
    -V "${sample_dir}/${sample}_chr10_raw.vcf" \
    -V "${sample_dir}/${sample}_chr11_raw.vcf" \
    -V "${sample_dir}/${sample}_chr12_raw.vcf" \
    -V "${sample_dir}/${sample}_chr13_raw.vcf" \
    -V "${sample_dir}/${sample}_chr14_raw.vcf" \
    -V "${sample_dir}/${sample}_chr15_raw.vcf" \
    -V "${sample_dir}/${sample}_chr16_raw.vcf" \
    -V "${sample_dir}/${sample}_chr17_raw.vcf" \
    -V "${sample_dir}/${sample}_chr18_raw.vcf" \
    -V "${sample_dir}/${sample}_chr19_raw.vcf" \
    -V "${sample_dir}/${sample}_chr20_raw.vcf" \
    -out "${vcf_folder}/${sample}_raw.vcf"
  
  #Create rename file for columns
  rename="${sample_dir}/rename.txt"
  echo "${sample}_T" >> "${rename}"
  echo "${sample}_N" >> "${rename}"
  
  #rename columns in file
  ${bcftools} annotate -x FORMAT/QSS -o "${vcf_folder}/${sample}_raw_qss.vcf" "${vcf_folder}/${sample}_raw.vcf"
  ${bcftools} reheader -s "${sample_dir}/rename.txt" -o "${vcf_folder}/${sample}_raw.vcf" "${vcf_folder}/${sample}_raw_qss.vcf"
  
  #Zip and index
  ${bgzip} "${vcf_folder}/${sample}_raw.vcf"    
  ${tabix} "${vcf_folder}/${sample}_raw.vcf.gz"

  #Remove tmp qss file created as annotate truncates when rewriting over itself
  rm "${vcf_folder}/${sample}_raw_qss.vcf"
  rm "${vcf_folder}/${sample}_raw.vcf.idx"
  
  
  # ------- Start summarise and save if all samples finished ------- #
  
  # Set time and account for pipeline submissions
  slurm_time="--time=${time_move_out}"
  slurm_account="--account=${account}"
  
  # Check samples
  while read sample tumour normal
  do
  echo ${sample}
    if [ -e "${vcf_folder}/${sample}_raw.vcf.gz" ]
    then 
      check="ok"
      echo "${vcf_folder}/${sample}_raw.vcf.gz" >> ${vcf_folder}/sample.list
    else
      check="nok"
      break
    fi
  done < "${tnfile}"
  
  if [ "${check}" == "ok" ] 
  then 
    echo "Completed all samples: $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
    echo "Creating combined VCF $(date +%d%b%Y_%H:%M:%S)" >> "${pipeline_log}"
    
    ${bcftools} merge -l ${vcf_folder}/sample.list >> "${library_folder}/${library}_raw.vcf"
    
    sbatch "${slurm_time}" "${slurm_account}" \
       "${scripts_folder}/s03_summarise_and_save.sb.sh" \
       "${job_file}" \
       "${logs_folder}" \
       "${scripts_folder}" \
       "${pipeline_log}"
  
    # Report to pipeline log
    echo "Submitted job to save results to NAS" >> "${pipeline_log}"
    echo "" >> "${pipeline_log}"
  
    echo ""  
  
  fi
  
fi   
# ------- Completion ------- #

# Update sample log
echo "Completed sample pipeline: $(date +%d%b%Y_%H:%M:%S)"
echo ""
