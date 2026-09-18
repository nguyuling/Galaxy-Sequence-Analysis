#!/bin/bash

set -e

REPO="/Volumes/T7/270918_quality_control_multiqc"
FASTQ_DIR="$REPO/1_Datasets"
FASTQC_DIR="$REPO/2_FASTQC"
MULTIQC_DIR="$REPO/3_MultiQC"
CUTADAPT_DIR="$REPO/4_CutAdapt_TrimShortReads"
FASTQ_TRIMMED_DIR="$REPO/5_FASTQC_Trimmed"
MULTIQC_TRIMMED_DIR="$REPO/6_MultiQC_Trimmed"

mkdir -p "$REPO" "$FASTQ_DIR" "$FASTQC_DIR" "$CUTADAPT_DIR" "$FASTQ_TRIMMED_DIR" "$MULTIQC_DIR"

R1_URL="https://zenodo.org/record/61771/files/GSM461178_untreat_paired_subset_1.fastq"
R2_URL="https://zenodo.org/record/61771/files/GSM461178_untreat_paired_subset_2.fastq"
R1_LOCAL="$FASTQ_DIR/R1.fastq"
R2_LOCAL="$FASTQ_DIR/R2.fastq"
R1_TRIMMED="$FASTQ_DIR/R1_trimmed.fastq"
R2_TRIMMED="$FASTQ_DIR/R2_trimmed.fastq"
CUTADAPT_REPORT="$CUTADAPT_DIR/cutadapt_report.txt"

echo "1. Downloading FASTQ paired-end short reads..."
curl -L -C - --retry 5 --retry-connrefused -o "$R1_LOCAL" "$R1_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$R2_LOCAL" "$R2_URL"

echo "2. Performing FASTQC on the paired-end short reads to aggregate the FASTQCs..."
fastqc -o "$FASTQC_DIR" "$R1_LOCAL" "$R2_LOCAL"

echo "3. Performing MultiQC on the reads..."
multiqc "$FASTQ_DIR" -o "$MULTIQC_DIR" -n "multiqc_report_trimmed.html"

echo "4. Trimming and filtering the reads..."
cutadapt \
    -q 20 \
    -m 20 \
    -o "$R1_TRIMMED" \
    -p "$R2_TRIMMED" \
    "$R1_LOCAL" "$R2_LOCAL" > "$CUTADAPT_REPORT"

echo "5. Performing FASTQC on the trimmed paired-end short reads..."
fastqc -o "$FASTQ_TRIMMED_DIR" "$R1_TRIMMED" "$R2_TRIMMED"

echo "6. Performing MultiQC on the trimmed short reads to aggregate the FASTQCs..."
multiqc "$FASTQ_TRIMMED_DIR" -o "$MULTIQC_TRIMMED_DIR" -n "multiqc_report_trimmed.html"

echo "Completed quality control on paired-end short reads!"