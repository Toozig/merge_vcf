#!/bin/bash

# Script Name: genomic_operations.sh

# Description:
# This Bash script performs genomic operations using the specified input files.
# It utilizes the 'bcftools' utility to merge samples, annotate regions, and create
# a Variant Call Format (VCF) file containing specific samples.

# Load necessary modules
module load hurcs bcftools

# Function to check exit code and exit if not 0
check_exit_code() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Usage message
usage() {
    echo "Usage: $0 <samplesPathFile> <regionFile> <refGenome> <sampleMetadata> <outputFile> [sampleIDs]"
    echo ""
    echo "Description:"
    echo "  This script performs some operation using the specified input files."
    echo "  If <sampleIDs> is not provided, all proband IDs will be used."
    echo ""
    echo "Arguments:"
    echo "  <samplesPathFile>   Path to the samples file."
    echo "  <regionFile>        Path to the region file."
    echo "  <refGenome>         Path to the reference genome file."
    echo "  <sampleMetadata>    Path to the sample metadata file."
    echo "  <outputFile>        Path to the output VCF file."
    echo "  [sampleIDs]         Optional. Comma-separated list of sample IDs."
    echo "                      If not provided, all proband IDs will be used."
    echo ""
    echo "Example:"
    echo "  $0 samples.txt regions.bed reference.fa metadata.csv output.vcf"
    echo "  $0 samples.txt regions.bed reference.fa metadata.csv output.vcf ID1,ID2,ID3"
    exit 1
}

# Check if the number of arguments is correct
if [ "$#" -lt 5 ] || [ "$#" -gt 6 ]; then
    usage
fi

# Assign input arguments to variables
samplesPathFile=$1
regionFile=$2
refGenome=$3
sampleMetadata=$4
outputFile=$5

# If sampleIDs is provided, use it; otherwise, set it to all proband IDs
if [ "$#" -eq 6 ]; then
    sampleIDs=$6
else
    # Logic to get all proband IDs as a default
    sampleIDs=$(awk '$3 == 0 {ids = ids $1 ","} END {sub(/,$/, "", ids); print ids}' "$sampleMetadata")
fi

# Temporary files
tmp_file=tmp.vcf.gz
norm_tmp_file=norm_tmp.vcf.gz

# Merge all the samples, norm them into single variant per row
bcftools merge -0 -l $samplesPathFile -m none -R $regionFile -Oz -o $tmp_file
bcftools norm -m -any -f $refGenome $tmp_file | bgzip > $norm_tmp_file
rm -f $tmp_file 

# Annotation
annotated_tmp=annotated_tmp.vcf.gz
region_header='data/read_only/layers_data/headers/interval_ID.header'
region_format='CHROM,FROM,TO,INTERVAL_ID'
bcftools annotate -a $regionFile -h $region_header -c $region_format -Oz -o $annotated_tmp $norm_tmp_file

# Check the exit code of the last command
check_exit_code "bcftools merge samples and annotations"
rm -f $norm_tmp_file

# Make VCF of only probands
bcftools view -s $sampleIDs -Oz -o $outputFile $annotated_tmp

# Clean up temporary files
rm -f $annotated_tmp

# End of script
