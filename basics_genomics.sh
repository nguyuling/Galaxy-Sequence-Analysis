#!/bin/bash

# define file paths as variables
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis"
EXONS="$REPO/datasets/4104428/UCSC-hg38-chr22-Coding-Exons.bed"
SNPS="$REPO/datasets/4104428/UCSC-hg38-chr22-dbSNP153-Whole-Gene-SNPs.bed"
INTERSECT="$REPO/basics-genomics/exon_snps_intersect.bed"
SNPS_COUNTS="$REPO/basics-genomics/snps_counts_per_exon.bed"
SNPS_COUNTS_SORTED="$REPO/basics-genomics/snps_counts_per_exon_sorted.bed"
TOP5_EXONS_SNPS_COUNTS="$REPO/basics-genomics/top5_exons_snps_counts.bed"
TOP5_EXONS="$REPO/basics-genomics/top5_exons.bed"

# bedtools intersect
bedtools intersect \
  -a "$EXONS" \
  -b "$SNPS" \
  -wa -wb > "$INTERSECT"

# datamash: group by column 4, count unique values in column 10
datamash -s -g 4 countunique 10 < "$INTERSECT" > "$SNPS_COUNTS"

# sort: by column 2, descending (-r), fast numeric sort (-n)
sort -k2,2rn "$SNPS_COUNTS" > "$SNPS_COUNTS_SORTED"

# select first: top 5 rows
head -n 5 "$SNPS_COUNTS_SORTED" > "$TOP5_EXONS_SNPS_COUNTS"

# compare two datasets
awk 'NR==FNR {ids[$1]; next} $4 in ids' "$TOP5_EXONS_SNPS_COUNTS" "$EXONS" > "$TOP5_EXONS"
cat "$TOP5_EXONS"