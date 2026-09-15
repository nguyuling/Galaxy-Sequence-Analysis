#!/bin/bash

set -e

# define directory
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality-control-multiqc"
mkdir -p "$REPO"

# define fastq dataset URLs and local target paths
FASTQ_1_URL="https://zenodo.org/record/61771/files/GSM461178_untreat_paired_subset_1.fastq"
FASTQ_2_URL="https://zenodo.org/record/61771/files/GSM461178_untreat_paired_subset_2.fastq"
FASTQ_1_LOCAL="$REPO/R1.fastq"
FASTQ_2_LOCAL="$REPO/R2.fastq"
FASTQ_1_TRIMMED="$REPO/R1_trimmed.fastq"
FASTQ_2_TRIMMED="$REPO/R2_trimmed.fastq"

# output files
CUTADAPT_REPORT="$REPO/cutadapt_report.txt"

# 1. download datasets
curl -L -o "$FASTQ_1_LOCAL" "$FASTQ_1_URL"
curl -L -o "$FASTQ_2_LOCAL" "$FASTQ_2_URL"

# 2. perform FastQC on raw paired-end reads
fastqc -o "$REPO" "$FASTQ_1_LOCAL" "$FASTQ_2_LOCAL"

# 3. trim and filter paired-end short reads with Cutadapt
cutadapt \
    -q 20 \
    -m 20 \
    -o "$FASTQ_1_TRIMMED" \
    -p "$FASTQ_2_TRIMMED" \
    "$FASTQ_1_LOCAL" "$FASTQ_2_LOCAL" > "$CUTADAPT_REPORT"

# 4. perform fastqc on trimmed reads
fastqc -o "$REPO" "$FASTQ_1_TRIMMED" "$FASTQ_2_TRIMMED"

# 5. perform multiqc to aggregate all fastqc and cutadapt logs into a single report
multiqc "$REPO" -o "$REPO" -n "multiqc_report.html"

# 6. clean up fastq, zip files
rm -rf \
    "$REPO/multiqc_report_data" \
    "$REPO"/*.fastq \
    "$REPO"/*.zip