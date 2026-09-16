#!/bin/bash

set -e

# Harddrive paths
HARD_DRIVE="/Volumes/T7"
DATA_DIR="$HARD_DRIVE/mapping"
MM10_DIR="$HARD_DRIVE/mouse_mm10"
mkdir -p "$DATA_DIR"

# input and output paths on hard drive
R1_URL="https://zenodo.org/record/1324070/files/wt_H3K4me3_read1.fastq.gz"
R2_URL="https://zenodo.org/record/1324070/files/wt_H3K4me3_read2.fastq.gz"
R1_LOCAL="$DATA_DIR/R1.fastq.gz"    
R2_LOCAL="$DATA_DIR/R2.fastq.gz"
RAW_BAM="$DATA_DIR/raw_alignment.bam"
FILTERED_BAM="$DATA_DIR/filtered_alignment.bam"
RAW_STATS="$DATA_DIR/raw_alignment_stats.txt"
FILTERED_STATS="$DATA_DIR/filtered_alignment_stats.txt"
MM10_FA_LOCAL="$MM10_DIR/mm10.fa.gz"
INDEX_PREFIX="$MM10_DIR/mm10_index"

# 1. download raw fastq datasets
echo "1. Downloading raw paired FASTQ reads..."
curl -L -C - --retry 5 --retry-connrefused -o "$R1_LOCAL" "$R1_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$R2_LOCAL" "$R2_URL"

# 2. check and build mm10 reference index (if not exist)
if [ ! -f "${INDEX_PREFIX}.1.bt2" ]; then
    echo "2. Index not found. Building Bowtie2 index in $MM10_DIR..."
    bowtie2-build "$MM10_FA_LOCAL" "$INDEX_PREFIX"
else
    echo "2. Reusing existing mm10 Bowtie2 index from $MM10_DIR..."
fi

# 3. map paired-end reads using bowtie2 and stream output to bam
echo "3. Mapping paired-end reads with Bowtie2..."
bowtie2 \
    -x "$INDEX_PREFIX" \
    -1 "$R1_LOCAL" \
    -2 "$R2_LOCAL" \
    --no-mixed \
    --no-discordant \
    | samtools view -bS - > "$RAW_BAM"

# 4. generate stats for raw bam alignment
echo "4. Generating stats for raw BAM..."
samtools stats "$RAW_BAM" > "$RAW_STATS"

# 5. filter bam file for properly paired and high-quality mapped reads
echo "5. Filtering BAM file..."
samtools view -b -F 4 -F 8 -f 2 -q 30 "$RAW_BAM" > "$FILTERED_BAM"

# 6. generate stats for filtered bam alignment
echo "6. Generating stats for filtered BAM..."
samtools stats "$FILTERED_BAM" > "$FILTERED_STATS"

# 7. clean up temporary fastq files
echo "7. Cleaning up raw FASTQ files..."
rm -f "$R1_LOCAL" "$R2_LOCAL"

echo "Pipeline finished! Output summary stats generated on T7."