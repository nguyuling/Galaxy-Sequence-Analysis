#!/bin/bash

# define directory
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality-control-multiqc"

# define fastq dataset (raw & processed)
FASTQ_1="$REPO/GSM461178_R1.fastq"
FASTQ_2="$REPO/GSM461178_R2.fastq"
FASTQ_1_TRIMMED="$REPO/GSM461178_R1_trimmed.fastq"
FASTQ_2_TRIMMED="$REPO/GSM461178_R1_trimmed.fastq"

# define paired-end fastq output file
FASTQC_1="$REPO/GSM461178_R1_fastqc.zip"
FASTQC_2="$REPO/GSM461178_R2_fastqc.zip"
MULTIQC_REPORT="$REPO/GSM461178_multiqc_report.html"
CUTADAPT_REPORT="$REPO/GSM461178_cutadapt_report.txt"

# 1. perform multi qc on paired-end fastq
fastqc -o "$REPO" "$FASTQ_1" "$FASTQ_2"
# fastqc on both forward and reverse sequences to generate raw data file
multiqc "$REPO" -o "$REPO" -n "$MULTIQC_REPORT"
# multiqc on the raw data output of both sequences

# 2. trim and filter paired-end short reads
cutadapt \
    -q 20 \
    -m 20 \
    -o "$FASTQ_1_TRIMMED" \
    -p "$FASTQ_2_TRIMMED" \
    "$FASTQ_1" "$FASTQ_2" > "$MULTIQC_CUTADAPT"