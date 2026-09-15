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
Low-quality reads can be filtered by the base quality score (q) and percentage of bases in a sequence that has >= q.

## Galaxy Basics for Genomics
Given datasets containing a list of exons (protein coding region) in chromosome 22 and a list of SNPs (single nucleotide polymorphisms) known to exist in the same chromosome, find the top 5 exons that has the most number of SNPs.

0. Define pathname

1. Find intersection between the list of exons and SNPs

2. Group by exon ID, then count the number of snps per exon

3. Sort the exon SNPs count by number of snps in ascending order

4. Filter only the top 5 exons

5. Cross referencing to recover the exons' data 

| Chromosome | Starting base pair | Ending base pair | Exon ID | No. of SNPs |
| --- | --- | --- | --- | --- |
| chr22	| 46256560 | 46263322 | ENST00000253255.7_cds_0_0_chr22_46256561_r | 27 |
| chr22	| 50546243 | 50549951 | ENST00000648057.3_cds_0_0_chr22_50546244_f | 26 |
| chr22	| 31712082 | 31717291 | ENST00000327423.11_cds_5_0_chr22_31712083_r | 20 |
| chr22	| 22514001 | 22515630 | ENST00000302097.3_cds_0_0_chr22_22514002_r | 14 |
| chr22	| 49883662 | 49887178 | ENST00000216268.6_cds_1_0_chr22_49883663_f | 13 |

## Quality Control
1. Single-end short reads fastq
- using **`fastqe`** generates max / mean / min quality score of each base position across all sequences in **emoji** instead of usual score in ASCII code.
- using **`fastqc`** to generate quality report
- using **`cutadapt`** to trim adapters and filter out the low-quality base pairs

2. Paired-end short reads fastq
- using **`fastqc`** to generate qc raw data of both forward and reverse sequence, usually qc(forward) > qc(reverse)
- using **`multiqc`** to generate qc report using the raw data files above
- using **`cutadapt`** to trim adapters (forward and reverse have different adapters), trimmed fastq of both fastq have to be of the same bps for each sequence.

3. Long reads fastq
- using **`nanoplot`** to generate qc report of the reads

4. Nanopore reads 
- long sequence produced by changes in electrical current through microscopic pores.
- using **`pycoqc`** to generate qc report

## Mapping


## An Introduction to Genome Assembly


## Chloroplast Genome Assembly