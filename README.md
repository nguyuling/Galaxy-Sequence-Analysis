# Introduction to Galaxy and Sequence Analysis
This is a learning pathways from Galaxy Training and below are the tools and their respective documentation following the structure of the course.

## A short introduction to Galaxy
Given 12480 short sequence reads (in .fastq), generate a sequence quality report and filter out low quality reads

1. Quality report
- using `fastqc` and/or `falco` to perform high throughput quality check
- the contents of the report are as follow:

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

2. Filter low quality reads 
```bash
fastq_quality_filter -q 35 -p 80 -Q33 -v -i "$FASTQ" -o "$FASTQ_FILTERED"
```
- `-q 35` 35 is the minimum quality score required of each base in a sequence 
- `-p 80` At least 80% of the bases in a sequence must have quality >= -q or else the sequence is filtered out as low-quality read
- `-Q33` specifies Sanger Phred+33 quality score encoding


## Galaxy Basics for Genomics
Given datasets containing a list of exons (protein coding region) in chromosome 22 and a list of SNPs (single nucleotide polymorphisms) known to exist in the same chromosome, find the top 5 exons that has the most number of SNPs.

0. Define pathname
```bash
EXONS="$REPO/datasets/4104428/UCSC-hg38-chr22-Coding-Exons.bed"
SNPS="$REPO/datasets/4104428/UCSC-hg38-chr22-dbSNP153-Whole-Gene-SNPs.bed"

INTERSECT="$REPO/basics-genomics/exon_snps_intersect.bed"
SNPS_COUNTS="$REPO/basics-genomics/snps_counts_per_exon.bed"
SNPS_COUNTS_SORTED="$REPO/basics-genomics/snps_counts_per_exon_sorted.bed"
TOP5_EXONS_SNPS_COUNTS="$REPO/basics-genomics/top5_exons_snps_counts.bed"
TOP5_EXONS="$REPO/basics-genomics/top5_exons.bed"
```

1. Find intersection between the list of exons and SNPs
```bash
bedtools intersect -a "$EXONS" -b "$SNPS" -wa -wb > "$INTERSECT"
```

2. Group by exon ID, then count the number of snps per exon
```bash
datamash -s -g 4 countunique 10 < "$INTERSECT" > "$SNPS_COUNTS"
```

3. Sort the exon SNPs count by number of snps in ascending order
```bash
sort -k2,2rn "$SNPS_COUNTS" > "$SNPS_COUNTS_SORTED"
```

4. Filter only the top 5 exons
```bash
head -n 5 "$SNPS_COUNTS_SORTED" > "$TOP5_EXONS_SNPS_COUNTS"
``` 

5. Cross referencing to recover the exons' data 
```bash
awk 'NR==FNR {ids[$1]; next} $4 in ids' "$TOP5_EXONS_SNPS_COUNTS" "$EXONS" > "$TOP5_EXONS"
```

| Chromosome | Starting base pair | Ending base pair | Exon ID | No. of SNPs |
| --- | --- | --- | --- | --- |
| chr22	| 46256560 | 46263322 | ENST00000253255.7_cds_0_0_chr22_46256561_r | 27 |
| chr22	| 50546243 | 50549951 | ENST00000648057.3_cds_0_0_chr22_50546244_f | 26 |
| chr22	| 31712082 | 31717291 | ENST00000327423.11_cds_5_0_chr22_31712083_r | 20 |
| chr22	| 22514001 | 22515630 | ENST00000302097.3_cds_0_0_chr22_22514002_r | 14 |
| chr22	| 49883662 | 49887178 | ENST00000216268.6_cds_1_0_chr22_49883663_f | 13 |

## Quality Control


## Mapping


## An Introduction to Genome Assembly


## Chloroplast Genome Assembly