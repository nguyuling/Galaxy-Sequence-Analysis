#!/bin/bash

# define directory and file paths as variables
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis"
FASTQ="$REPO/datasets/582600/mutant_R1.fastq"
OUTPUT_DIR="$REPO/intro"
FASTQ_FILTERED="$OUTPUT_DIR/mutant_R1_filtered.fastq"

# 1. perform qc on the sequence
fastqc "$FASTQ" --outdir="$OUTPUT_DIR"
falco -o "$OUTPUT_DIR" "$FASTQ"

# 2. filter low-quality reads
fastq_quality_filter -q 35 -p 80 -Q33 -v -i "$FASTQ" -o "$FASTQ_FILTERED"