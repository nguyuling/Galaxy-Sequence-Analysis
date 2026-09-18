#!/bin/bash

set -e

REPO="/Volumes/T7/270917_chloroplast_genome_assembly"
DATA_DIR="$REPO/1_Datasets"
FASTQC_DIR="$REPO/2_FastQC"
NANOPLOT_DIR="$REPO/2_Nanoplot_NanoporeReadsQC"
FLYE_DIR="$REPO/3_Flye_NanoporeAssembly"
BWA_DIR="$REPO/4_Map_ShortReadMappingToAssembly"
PILON_DIR="$REPO/5_Pilon_AssemblyPolishing"
STATS_DIR="$REPO/6_SeqkitStats_AssemblyStats"

mkdir -p "$REPO" "$DATA_DIR" "$FASTQC_DIR" "$NANOPLOT_DIR" "$FLYE_DIR" "$BWA_DIR" "$PILON_DIR" "$STATS_DIR"

FASTQ_ILLUMINA_URL="https://zenodo.org/record/3567224/files/sweet-potato-chloroplast-illumina-reduced.fastq"
FASTQ_NANOPORE_URL="https://zenodo.org/record/3567224/files/sweet-potato-chloroplast-nanopore-reduced.fastq"
FASTQ_ILLUMINA_LOCAL="$DATA_DIR/sweet-potato-chloroplast-illumina-reduced.fastq"
FASTQ_NANOPORE_LOCAL="$DATA_DIR/sweet-potato-chloroplast-nanopore-reduced.fastq"
ASSEMBLY_FASTA="$FLYE_DIR/assembly.fasta"
MAPPED_BAM="$BWA_DIR/sweet-potato-chloroplast-illumina.bam"
POLISHED_FASTA="$PILON_DIR/assembly-polished.fasta"
ASSEMBLY_POLISHED_STATS="$STATS_DIR/assemblies_stats.txt"

echo "1. Downloading the datasets..."
curl -L -C - --retry 5 --retry-connrefused -o "$FASTQ_ILLUMINA_LOCAL" "$FASTQ_ILLUMINA_URL"
curl -L -C - --retry 5 --retry-connrefused -o "$FASTQ_NANOPORE_LOCAL" "$FASTQ_NANOPORE_URL"

echo "2. Checking illumina read quality..."
fastqc "$FASTQ_ILLUMINA_LOCAL" -o "$FASTQC_DIR"

echo "2. Checking nanopore read quality..."
NanoPlot \
    --fastq "$FASTQ_NANOPORE_LOCAL" \
    -o "$NANOPLOT_DIR" \
    --no_static \
    --N50

echo "3. Assembling nanopore long reads..."
flye \
    --nano-raw "$FASTQ_NANOPORE_LOCAL" \
    -o "$FLYE_DIR" \
    --genome-size 160k \
    --threads 4

echo "3. Creating index of Flye assembly..."
bwa index "$ASSEMBLY_FASTA"
# indexinng produce .amb .ann .bwt .pac .sa files in the same dir as the assembly fasta 

echo "4. Mapping illumina reads to the Flye assembly..."
bwa mem -t 4 "$ASSEMBLY_FASTA" "$FASTQ_ILLUMINA_LOCAL" | \
    samtools view -bS - | \
    samtools sort -o "$MAPPED_BAM" -

echo "4. Creating index of mapped bam..."
samtools index "$MAPPED_BAM"

echo "5. Polishing the nanopore assembly..."
pilon \
    --genome "$ASSEMBLY_FASTA" \
    --bam "$MAPPED_BAM" \
    --outdir "$PILON_DIR" \
    --output "assembly-polished" \
    --changes

echo "6. Obtaining stats of both assembly fasta and polished fasta..."
seqkit stats "$ASSEMBLY_FASTA" "$POLISHED_FASTA" -o "$ASSEMBLY_POLISHED_STATS"