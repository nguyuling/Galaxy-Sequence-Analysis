#!/bin/bash
set -e

# define directory
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality-control-fastqc"

# define remote URL and local dataset path
FASTQ_URL="https://zenodo.org/record/3977236/files/female_oral2.fastq-4143.gz"
FASTQ_LOCAL="$REPO/female_oral2.fastq-4143.gz"

# define output files
FASTQ_TRIMMED="$REPO/A3_R1_trimmed.fastq"
FASTQE="$REPO/A3_R1_fastqe.fastsanger"
FASTQE_TRIMMED="$REPO/A3_R1_trimmed.fastsanger"
FASTQ_CUTADAPT="$REPO/A3_R1_cutadapt_report.txt"

# 1. download dataset locally
curl -L -o "$FASTQ_LOCAL" "$FASTQ_URL"

# 2. perform qc on raw short reads
fastqe "$FASTQ_LOCAL" --output "$FASTQE"
fastqc "$FASTQ_LOCAL" --outdir="$REPO"

# 3. trim and filter short reads
cutadapt \
    -a CTGTCTCTTATACACATCT \
    -q 20 \
    -m 20 \
    -o "$FASTQ_TRIMMED" \
    "$FASTQ_LOCAL" > "$FASTQ_CUTADAPT"
# -a adapter sequence
# -q quality cutoff for 3' end
# -m minimum read length

# 4. perform qc on trimmed reads
fastqe "$FASTQ_TRIMMED" --output "$FASTQE_TRIMMED"

# 5. clean up downloaded fastq
rm -f "$FASTQ_LOCAL" "$FASTQ_TRIMMED"