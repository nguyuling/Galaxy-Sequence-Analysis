#!/bin/bash

set -e

REPO="/Volumes/T7/270918_quality_control_fastqc"
DATA_DIR="$REPO/1_Dataset"
FASTQC_DIR="$REPO/2_FastQC"
FASTQE_DIR="$REPO/3_FastQE"
CUTADAPT_DIR="$REPO/4_CutAdapt_TrimShortRead"

FASTQ_URL="https://zenodo.org/record/3977236/files/female_oral2.fastq-4143.gz"
FASTQ_LOCAL="$DATA_DIR/A3_R1.fastq-4143.gz"
FASTQ_TRIMMED="$DATA_DIR/A3_R1_trimmed.fastq"
FASTQE="$FASTQE_DIR/A3_R1_fastqe.fastsanger"
FASTQE_TRIMMED="$FASTQE_DIR/A3_R1_trimmed.fastsanger"
FASTQ_CUTADAPT="$CUTADAPT_DIR/A3_R1_cutadapt_report.txt"

mkdir -p "$REPO" "$DATA_DIR" "$FASTQC_DIR" "$FASTQE_DIR" "$CUTADAPT_DIR"

echo "1. Downloading the FASTQ dataset..."
curl -L -C - --retry 5 --retry-connrefused -o "$FASTQ_LOCAL" "$FASTQ_URL"

echo "2. Performing FASTQC on the short read..."
fastqc "$FASTQ_LOCAL" -o "$FASTQC_DIR"

echo "3. Performing FASTQE on the short read..."
fastqe "$FASTQ_LOCAL" --output "$FASTQE"

echo "4. Trimming and filtering the short read..."
cutadapt \
    -a CTGTCTCTTATACACATCT \
    -q 20 \
    -m 20 \
    -o "$FASTQ_TRIMMED" \
    "$FASTQ_LOCAL" > "$FASTQ_CUTADAPT"
# -a adapter sequence
# -q quality cutoff for 3' end
# -m minimum read length

echo "5. Performing FASTQE on the trimmed FASTQ..."
fastqe "$FASTQ_TRIMMED" --output "$FASTQE_TRIMMED"

echo "Completed quality control on single-end short read!"