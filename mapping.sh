#!/bin/bash

set -e

REPO="/Volumes/T7/270916_mapping"
DATA_DIR="$REPO/1_Datasets"
MM10_DIR="/Volumes/T7/mouse_mm10"
ALIGNMENT_DIR="$REPO/2_Alignment"
FILTERED_DIR="$REPO/3_FilteredAlignment"

mkdir -p "$REPO" "$DATA_DIR" "$ALIGNMENT_DIR" "$FILTERED_DIR"

R1_URL="https://zenodo.org/record/1324070/files/wt_H3K4me3_read1.fastq.gz"
R2_URL="https://zenodo.org/record/1324070/files/wt_H3K4me3_read2.fastq.gz"
R1_LOCAL="$DATA_DIR/R1.fastq.gz"    
R2_LOCAL="$DATA_DIR/R2.fastq.gz"
ALIGNMENT="$ALIGNMENT_DIR/raw_alignment.bam"
ALIGNMENT_STATS="$ALIGNMENT_DIR/raw_alignment_stats.txt"
FILTERED="$FILTERED_DIR/filtered_alignment.bam"
FILTERED_STATS="$FILTERED_DIR/filtered_alignment_stats.txt"
MM10_FA_LOCAL="$MM10_DIR/mm10.fa.gz"
INDEX_PREFIX="$MM10_DIR/mm10_index"

echo "1. Downloading paired-end FASTQ reads..."
curl -L -C - --retry 5 --retry-connrefused -o "$R1_LOCAL" "$R1_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$R2_LOCAL" "$R2_URL"

echo "2. Building mm10 reference index (if not exist)..."
if [ ! -f "${INDEX_PREFIX}.1.bt2" ]; then
    echo "Index not found. Building Bowtie2 index in $MM10_DIR..."
    bowtie2-build "$MM10_FA_LOCAL" "$INDEX_PREFIX"
else
    echo "Reusing existing mm10 Bowtie2 index from $MM10_DIR..."
fi

echo "3. Mapping paired-end reads with Bowtie2..."
bowtie2 \
    -x "$INDEX_PREFIX" \
    -1 "$R1_LOCAL" \
    -2 "$R2_LOCAL" \
    --no-mixed \
    --no-discordant \
    | samtools view -bS - > "$ALIGNMENT"

echo "4. Generating stats for alignment BAM..."
samtools stats "$ALIGNMENT" > "$ALIGNMENT_STATS"

echo "5. Filtering the alignment BAM..."
samtools view -b -F 4 -F 8 -f 2 -q 30 "$ALIGNMENT" > "$FILTERED"

echo "6. Generating stats for the filtered alignment BAM..."
samtools stats "$FILTERED" > "$FILTERED_STATS"

echo "Completed genome mapping!"