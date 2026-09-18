#!/bin/bash

REPO="/Volumes/T7/270918_basics_of_genomics"
DATA_DIR="$REPO/1_Datasets"
BEDTOOLS_DIR="$REPO/2_Bedtools_FindIntersection"
DATAMESH_DIR="$REPO/3_Datamesh_GroupByExonID"
SORT_DIR="$REPO/4_Sort"

mkdir "$REPO" "$DATA_DIR" "$BEDTOOLS_DIR" "$DATAMESH_DIR" "$SORT_DIR"

EXONS_URL="https://zenodo.org/record/4104428/files/UCSC-hg38-chr22-Coding-Exons.bed"
SNPS_URL="https://zenodo.org/record/4104428/files/UCSC-hg38-chr22-dbSNP153-Whole-Gene-SNPs.bed"
EXONS_LOCAL="$DATA_DIR/exons.bed"
SNPS_LOCAL="$DATA_DIR/snps.bed"
INTERSECT="$BEDTOOLS_DIR/exon_snps_intersect.bed"
SNPS_COUNTS="$DATAMESH_DIR/snps_counts_per_exon.bed"
SNPS_COUNTS_SORTED="$SORT_DIR/snps_counts_per_exon_sorted.bed"
TOP5_EXONS_SNPS_COUNTS="$SORT_DIR/top5_exons_snps_counts.bed"
TOP5_EXONS="$SORT_DIR/top5_exons.bed"

echo "1. Downloading exons and SNPs datasets..."
curl -L -C - --retry 5 --retry-connrefused -o "$EXONS_LOCAL" "$EXONS_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$SNPS_LOCAL" "$SNPS_URL"

echo "2. Finding intersection between exons and SNPs..."
bedtools intersect -a "$EXONS_LOCAL" -b "$SNPS_LOCAL" -wa -wb > "$INTERSECT"
# -wa write the record from exons (file a)
# -wb append the overlapping record from snps (file b) to the output file.

echo "3. Grouping by exon ID, then counting unique SNPs of each exon ID..."
datamash -s -g 4 countunique 10 < "$INTERSECT" > "$SNPS_COUNTS"
# -s sort the input by the grouping column exon id (required)
# -g 4 group records based on the exon id (column 4)
# countunique 10 count number of snps (column 10) per exon

echo "4. Sorting by SNPs count in descending order..."
sort -k2,2rn "$SNPS_COUNTS" > "$SNPS_COUNTS_SORTED"
# -k2,2 sort by key snps count (column 2)
# r reverse the sort order to descending
# n use numeric sorting

echo "5. Selecting top 5 exons with most SNPs..."
head -n 5 "$SNPS_COUNTS_SORTED" > "$TOP5_EXONS_SNPS_COUNTS"
# -n 5 extract top 5 lines of records

echo "6. Recovering exons' data in other columns..."
awk 'NR==FNR {ids[$1]; next} $4 in ids' "$TOP5_EXONS_SNPS_COUNTS" "$EXONS_LOCAL" > "$TOP5_EXONS"
cat "$TOP5_EXONS"
# NR==FNR number of records (cumulative records across files) only equal to file number of records (reset to 1 when reading a new file) when reading file 1
# ids[$1] at file 1, take the exon id (column 1) as the key in a hash map
# next skip the rest of the file and move to next line, to avoid running the script on the rest of the columns
# $4 in ids` once NR!=FNR when moving to file 2, check if the exon id (column 4) exists in hash map, if yes then write to output file

echo "Completed searching for top 5 exons with most SNPs in Chromosome 22!"