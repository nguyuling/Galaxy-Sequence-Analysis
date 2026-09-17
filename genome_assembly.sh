#!/bin/bash

set -e

REPO="/Volumes/T7/270917_genome_assembly"
DATA_DIR="$REPO/1_Datasets"
FASTQC_DIR="$REPO/2_FastQC"
MULTIQC_DIR="$REPO/3_MultiQC"
SEQKIT_DIR="$REPO/4_Seqkit_InterleavePairedEnd"
VELVET_DIR="$REPO/5_Velvet_GenAssembly"
SPADES_DIR="$REPO/5_Spades_GenAssembly"
QUAST_DIR="$REPO/6_Quast_AssemblyAssessment"
mkdir -p "$REPO" "$DATA_DIR" "$FASTQC_DIR" "$MULTIQC_DIR" "$SEQKIT_DIR" "$VELVET_DIR" "$SPADES_DIR" "$QUAST_DIR"

R1_URL="https://zenodo.org/record/582600/files/mutant_R1.fastq"
R2_URL="https://zenodo.org/record/582600/files/mutant_R2.fastq"
WT_URL="https://zenodo.org/record/582600/files/wildtype.fna"
R1_LOCAL="$DATA_DIR/R1.fastq"
R2_LOCAL="$DATA_DIR/R2.fastq"
WT_LOCAL="$DATA_DIR/wildtype.fna"
INTERLACED_MUTANT="$SEQKIT_DIR/interlaced_mutant.fastq"

echo "1. Downloading the datasets..."
curl -L -C - --retry 5 --retry-connrefused -o "$R1_LOCAL" "$R1_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$R2_LOCAL" "$R2_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$WT_LOCAL" "$WT_URL"

echo "2. Running FastQC on the paired-end reads..."
fastqc -o "$FASTQC_DIR" "$R1_LOCAL" "$R2_LOCAL"

echo "3. Running MultiQC on the paired-end reads' FastQC raw data..."
multiqc "$FASTQC_DIR" -o "$MULTIQC_DIR" -n "multiqc_report.html"

echo "4. Combining paired-end FASTQ files into an interleaving file..."
python3 -c '
import sys
r1_path = "'"$R1_LOCAL"'"
r2_path = "'"$R2_LOCAL"'"
out_path = "'"$INTERLACED_MUTANT"'"

with open(r1_path) as f1, open(r2_path) as f2, open(out_path, "w") as out:
    while True:
        r1_lines = [f1.readline() for _ in range(4)]
        r2_lines = [f2.readline() for _ in range(4)]
        if not r1_lines[0] or not r2_lines[0]:
            break
        out.writelines(r1_lines + r2_lines)
'

echo "5. Assembling genome from short reads..."
velveth "$VELVET_DIR" 29 -fastq -shortPaired "$INTERLACED_MUTANT"
velvetg "$VELVET_DIR" -clean yes

echo "5. Combining paired-end FASTQ files into an interleaving file..."
spades.py \
    -1 "$R1_LOCAL" \
    -2 "$R2_LOCAL" \
    -o "$SPADES_DIR"

echo "6. Assessing quality of genome assembly..."
quast.py \
    "$VELVET_DIR/contigs.fa" \
    "$SPADES_DIR/contigs.fasta" \
    -r "$WT_LOCAL" \
    -o "$QUAST_DIR" \
    -t 1

echo "Completed Genome Assembly!"