#!/bin/bash

set -e

REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/mapping"
R1_URL="https://zenodo.org/record/1324070/files/wt_H3K4me3_read1.fastq.gz"
R2_URL="https://zenodo.org/record/1324070/files/wt_H3K4me3_read2.fastq.gz"
R1_LOCAL="$REPO/R1.fastq.gz"    
R2_LOCAL="$REPO/R2.fastq.gz"
RAW_BAM="$REPO/aligned.bam"
FILTERED_BAM="$REPO/filtered.bam"
RAW_STATS="$REPO/raw_alignment_stats.txt"
FILTERED_STATS="$REPO/filtered_alignment_stats.txt"
INDEX_PREFIX="$REPO/mm10_index"
MM10_FA_URL="https://hgdownload.soe.ucsc.edu/goldenPath/mm10/chromosomes/chr19.fa.gz"
MM10_FA_LOCAL="$REPO/mm10_chr19.fa.gz"

# 1. download r1 and r2 datasets
echo "Downloading raw paired FASTQ reads..."
curl -L -C - --retry 5 --retry-connrefused -o "$R1_LOCAL" "$R1_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$R2_LOCAL" "$R2_URL"

# 2. prepare mm10 reference index
echo "Download mus musculus mm10..."
if [ ! -f "${INDEX_PREFIX}.1.bt2" ]; then
    echo "Downloading and indexing mm10 reference..."
    curl -L -C - --retry 5 -o "$MM10_FA_LOCAL" "$MM10_FA_URL"
    bowtie2-build "$MM10_FA_LOCAL" "$INDEX_PREFIX"
    rm -f "$MM10_FA_LOCAL"
fi

# 3. run bowtie2 mapping on paired reads
echo "Mapping paired-end reads with Bowtie2..."
bowtie2 \
    -x "$INDEX_PREFIX" \
    -1 "$R1_LOCAL" \
    -2 "$R2_LOCAL" \
    --no-mixed \
    --no-discordant \
    | samtools view -bS - > "$RAW_BAM"

# 4. inspect raw BAM alignment
samtools stats "$RAW_BAM" > "$RAW_STATS"

# 5. filter bam to keep only properly paired and mapped reads (SAM flag 0x2 / -q 30)
samtools view -b -F 4 -F 8 -f 2 -q 30 "$RAW_BAM" > "$FILTERED_BAM"

# 6. use samtools stats to inspect filtered BAM
echo "Generating stats for filtered BAM..."

# 7. clean up fastq and bam files
rm -f \
    "$REPO"/*.fastq.gz \
    "$REPO"/*.bam \
    "$REPO"/*.bt2