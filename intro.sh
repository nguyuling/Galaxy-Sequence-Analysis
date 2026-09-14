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
# -q 35 is the minimum quality score required of each base in a sequence 
# -p 80 At least 80% of the bases in a sequence must have quality >= -q or else the sequence is filtered out as low-quality read
# -Q33 specifies Sanger Phred+33 quality score encoding