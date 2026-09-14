#!/bin/bash

# define directory
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality-control-fastqc"

# define fastq dataset (raw & processed)
FASTQ="$REPO/A3_R1.fastq"
FASTQ_TRIMMED="$REPO/A3_R1_trimmed.fastq"

# define single-end fastq output file
FASTQE="$REPO/A3_R1_fastqe.fastsanger"
FASTQE_TRIMMED="$REPO/A3_R1_trimmed.fastsanger"
FASTQ_CUTADAPT="$REPO/A3_R1_cutadapt_report.txt"

# 1. perform qc on single-end short reads
fastqe "$FASTQ" --output "$FASTQE"
# fastqe represent the quality score in emoji (instead of ASCII code), output file in .fastsanger
fastqc "$FASTQ" --outdir="$REPO"
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
fastqe "$FASTQ_TRIMMED" --output "$FASTQE_TRIMMED"
# perform fastqe again on the trimmed fastq
