#!/bin/bash

set -e

REPO="/Volumes/T7/270918_quality_control_nanoplot"
DATA_DIR="$REPO/1_Dataset"
NANOPLOT_DIR="$REPO/2_Nanoplot"

mkdir -p "$REPO" "$DATA_DIR" "$NANOPLOT_DIR"

FASTQ_URL="https://zenodo.org/records/5730295/files/m64011_190830_220126.Q20.subsample.fastq.gz"
FASTQ_LOCAL="$DATA_DIR/m64011_190830_220126.Q20.subsample.fastq.gz"

echo "1. Downloading FASTQ long reads..."
curl -L -C - --retry 5 --retry-connrefused -o "$FASTQ_LOCAL" "$FASTQ_URL"

echo "2. Perform nanoplot on the long reads..."
NanoPlot \
    --fastq "$FASTQ_LOCAL" \
    -o "$NANOPLOT_DIR" \
    --include-js embedded \
    --plots dot kde \
    --N50
# include-js embedded to produce single html instead of separate ones for each chart
# no_statis to not download all chart img
# plots bivariate format of the plots
# N50 shows the minimumm reads length where 50% of the total bps is >= that length 

echo "Completed quality control on nanopore long reads!"