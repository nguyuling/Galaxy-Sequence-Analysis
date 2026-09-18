#!/bin/bash

set -e

REPO="/Volumes/T7/270916_intro"
DATA_DIR="$REPO/1_Dataset"
FASTQC_DIR="$REPO/2_FASTQC"
FALCO_DIR="$REPO/3_FALCO"
QUALITY_FILTER_DIR="$REPO/4_QualityFilter"

mkdir -p "$REPO" "$DATA_DIR" "$FASTQC_DIR" "$FALCO_DIR" "$QUALITY_FILTER_DIR"

FASTQ_URL="https://zenodo.org/record/582600/files/mutant_R1.fastq"
FASTQ_LOCAL="$DATA_DIR/mutant_R1.fastq"
FASTQ_FILTERED="$QUALITY_FILTER_DIR/mutant_R1_filtered.fastq"

echo "1. Downloading FASTQ dataset..."
curl -L -C - --retry 5 --retry-connrefused -o "$FASTQ_LOCAL" "$FASTQ_URL"

echo "2. Performing FASTQC on the FASTQ..."
fastqc "$FASTQ_LOCAL" -o "$FASTQC_DIR"

echo "3. Performing FASTCO on the FASTQ..."
falco -o "$FALCO_DIR" "$FASTQ_LOCAL"

echo "4. Filtering low-quality reads..."
fastp \
    -i "$FASTQ_LOCAL" \
    -o "$FASTQ_FILTERED" \
    -q 35 \
    -u 20 \
    -h "$QUALITY_FILTER_DIR/fastp_report.html"
# fastq_quality_filter -q 35 -p 80 -Q33 -v -i "$FASTQ_LOCAL" -o "$FASTQ_FILTERED"
# -q 35 is the minimum quality score required of each base in a sequence
# -u 20 means at least 80% of the bases in a sequence must have quality >= -q or else the sequence is filtered out as low-quality read

echo "Completed basic QC analysis and filtering of short reads FASTQ!"