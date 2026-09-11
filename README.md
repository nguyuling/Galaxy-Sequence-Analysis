# Introduction to Galaxy and Sequence Analysis
This is a learning pathways from Galaxy Training and below are the tools and their respective documentation following the structure of the course.

## A short introduction to Galaxy

#### `FastQC & Falco`
To perform high throughput quality check
| Summary | Discription |
| --- | --- |
| Basic Statistics | Total sequences, total bases (per sequence), sequence length (eg. 150 or 200), %GC |
| Per base sequence quality | Distribution of base quality (shown in boxplot per 5 bases) across the sequence where 40-28 (green), 28-20 (yellow), 20-0 (red) |
| Per sequence quality scores | Line graph of base quality over the number of sequence |
| Per base sequence content | Content percentage of each type of base (A-G-T-C) per 5 bases across the sequence |
| Per sequence GC content | Distribution of GC content percentage of the sequences |
| Per base N content | Content percentage of unknown base per 5 bases across the sequence |
| Sequence Length Distribution | Distribution of length (bp) of the sequences |
| Sequence Duplication Levels | Percentage of sequnce duplication over duplication rate |
| Overrepresented sequences | Overreprented sequences |
| Adapter Content | Percentage of adapter content across the sequence |

#### `Filter by quality`
To filter low quality reads
| Parameter | Discription |
| --- | --- |
| Quality cutoff | Minimum quality per base in a sequence |
| Min percentage | Minimum percentage of bases in a sequence that meets the quality cutoff value |


## Galaxy Basics for Genomics

1. Define the pathname (repo/root, dataset and output files)

2. Left join file a and b
> bedtools intersect -a "$EXONS" -b "$SNPS" -wa -wb > "$INTERSECT"
- `-wa` write the record from exons (file a)
- `-wb` append the overlapping record from snps (file b) to the output file.

3. Group the column by exon ID, then count the number of snps per exon. 
```bash
datamash -s -g 4 countunique 10 < "$INTERSECT" > "$SNPS_COUNTS"
```
- `-s` sort the input by the grouping column exon id (required)
- `-g 4` group records based on the exon id (column 4)
- `countunique 10` count number of snps (column 10) per exon

4. Sort the exon snps count by number of snps in ascending order.
```bash
sort -k2,2rn "$SNPS_COUNTS" > "$SNPS_COUNTS_SORTED"
```
- `-k2,2` sort by key snps count (column 2)
- `r` reverse the sort order to descending
- `n` use numeric sorting

5. Filter the top 5 records of exon
```bash
head -n 5 "$SNPS_COUNTS_SORTED" > "$TOP5_EXONS_SNPS_COUNTS"
```
- `-n 5` extract top 5 lines of records 

6. Cross referencing
```bash
awk 'NR==FNR {ids[$1]; next} $4 in ids' "$TOP5_EXONS_SNPS_COUNTS" "$EXONS" > "$TOP5_EXONS"
```
- `NR==FNR` number of records (cumulative records across files) only equal to file number of records (reset to 1 when reading a new file) when reading file 1
- `ids[$1]` at file 1, take the exon id (column 1) as the key in a hash map
- `next` skip the rest of the file and move to next line, to avoid running the script on the rest of the columns
- `$4 in ids` once NR!=FNR when moving to file 2, check if the exon id (column 4) exists in hash map, if yes then write to output file

## Quality Control


## Mapping


## An Introduction to Genome Assembly


## Chloroplast Genome Assembly