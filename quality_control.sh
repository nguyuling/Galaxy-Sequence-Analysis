#!/bin/bash

# define directory
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis"
DATASET_DIR="$REPO/datasets"
OUTPUT_DIR="$REPO/quality-control"

# define fastq dataset (raw & processed)
FASTQ="$DATASET_DIR/3977236/A3_R1.fastq"
FASTQ_TRIMMED="$DATASET_DIR/3977236/A3_R1_trimmed.fastq"
FASTQ_1="$DATASET_DIR/461178/GSM461178_R1.fastq"
FASTQ_2="$DATASET_DIR/461178/GSM461178_R2.fastq"
FASTQ_1_TRIMMED="$DATASET_DIR/461178/GSM461178_R1_trimmed.fastq"
FASTQ_2_TRIMMED="$DATASET_DIR/461178/GSM461178_R2_trimmed.fastq"

# define single-end fastq output file
FASTQE="$OUTPUT_DIR/A3_R1_fastqe.fastsanger"
FASTQE_TRIMMED="$OUTPUT_DIR/A3_R1_trimmed.fastsanger"
FASTQ_CUTADAPT="$OUTPUT_DIR/A3_R1_cutadapt_report.txt"

# define paired-end fastq output file
FASTQC_1="$OUTPUT_DIR/GSM461178_R1_fastqc.zip"
FASTQC_2="$OUTPUT_DIR/GSM461178_R2_fastqc.zip"
MULTIQC="$OUTPUT_DIR/GSM461178_multiqc.html"
MULTIQC_CUTADAPT="$OUTPUT_DIR/GSM461178_cutadapt.txt"

# 1. perform qc on single-end fastq
fastqe "$FASTQ" --output "$FASTQE"
# fastqe represent the quality score in emoji (instead of ASCII code), output file in .fastsanger
fastqc "$FASTQ" --outdir="$OUTPUT_DIR"
# standard fastqc report

# 2. trim and filter single-end fastq
cutadapt \
    -a CTGTCTCTTATACACATCT \
    -q 20 \
    -m 20 \
    -o "$FASTQ_TRIMMED" \
    "$FASTQ" > "$FASTQ_CUTADAPT"
# -a adapter sequence
# -q quality cutoff for 3' end
# -m minimum read length
# perform qc on the trimmed sequenceOUTPUT_DIR
# fastqe "$FASTQ_TRIMMED" --output "$FASTQE_TRIMMED"

# 3. multi qc on paired-end fastq
fastqc -o "$OUTPUT_DIR" "$FASTQ_1" "$FASTQ_2"
# fastqc on both forward and reverse sequences to generate raw data file
multiqc "$OUTPUT_DIR" -o "$OUTPUT_DIR" -n "$MULTIQC"
# multiqc on the raw data output of both sequences

# 4. Trim and filter paired-end fastq
cutadapt \
    -q 20 \
    -m 20 \
    -o "$FASTQ_1_TRIMMED" \
    -p "$FASTQ_2_TRIMMED" \
    "$FASTQ_1" "$FASTQ_2" > "$MULTIQC_CUTADAPT"