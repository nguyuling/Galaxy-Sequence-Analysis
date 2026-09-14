#!/bin/bash

# 1. define file paths as variables
REPO="/Users/nguyuling/Galaxy-Sequence-Analysis"
EXONS="$REPO/datasets/4104428/UCSC-hg38-chr22-Coding-Exons.bed"
SNPS="$REPO/datasets/4104428/UCSC-hg38-chr22-dbSNP153-Whole-Gene-SNPs.bed"
INTERSECT="$REPO/basics-genomics/exon_snps_intersect.bed"
SNPS_COUNTS="$REPO/basics-genomics/snps_counts_per_exon.bed"
SNPS_COUNTS_SORTED="$REPO/basics-genomics/snps_counts_per_exon_sorted.bed"
TOP5_EXONS_SNPS_COUNTS="$REPO/basics-genomics/top5_exons_snps_counts.bed"
TOP5_EXONS="$REPO/basics-genomics/top5_exons.bed"

# 2. bedtools intersect: find intersection between exons and snps
bedtools intersect -a "$EXONS" -b "$SNPS" -wa -wb > "$INTERSECT"
# -wa write the record from exons (file a)
# -wb append the overlapping record from snps (file b) to the output file.

# 3. datamash: group by column 4, count unique values in column 10
datamash -s -g 4 countunique 10 < "$INTERSECT" > "$SNPS_COUNTS"
# -s sort the input by the grouping column exon id (required)
# -g 4 group records based on the exon id (column 4)
# countunique 10 count number of snps (column 10) per exon

# 4. sort: by column 2, descending (-r), fast numeric sort (-n)
sort -k2,2rn "$SNPS_COUNTS" > "$SNPS_COUNTS_SORTED"
# -k2,2 sort by key snps count (column 2)
# r reverse the sort order to descending
# n use numeric sorting

# 5. select first: top 5 rows
head -n 5 "$SNPS_COUNTS_SORTED" > "$TOP5_EXONS_SNPS_COUNTS"
# -n 5 extract top 5 lines of records

# 6. compare two datasets
awk 'NR==FNR {ids[$1]; next} $4 in ids' "$TOP5_EXONS_SNPS_COUNTS" "$EXONS" > "$TOP5_EXONS"
cat "$TOP5_EXONS"
# NR==FNR number of records (cumulative records across files) only equal to file number of records (reset to 1 when reading a new file) when reading file 1
# ids[$1] at file 1, take the exon id (column 1) as the key in a hash map
# next skip the rest of the file and move to next line, to avoid running the script on the rest of the columns
# $4 in ids` once NR!=FNR when moving to file 2, check if the exon id (column 4) exists in hash map, if yes then write to output file