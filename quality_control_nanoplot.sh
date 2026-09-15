#!/bin/bash

set -e

REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality_control_nanoplot"
FASTQ_URL="https://zenodo.org/records/5730295/files/m64011_190830_220126.Q20.subsample.fastq.gz"
FASTQ_LOCAL="$REPO/m64011_190830_220126.Q20.subsample.fastq.gz"

# 1. download long reads summary
curl -L -o "$FASTQ_LOCAL" "$FASTQ_URL"

# 2. perform nanoplot on the long reads
NanoPlot \
    --fastq "$FASTQ_LOCAL" \
    -o "$REPO" \
    --include-js embedded \
    --no_static \
    --plots dot kde \
    --N50
# include-js embedded to produce single html instead of separate ones for each chart
# no_statis to not download all chart img
# plots bivariate format of the plots
# N50 shows the minimumm reads length where 50% of the total bps is >= that length 

# 3. clean up fastq, zip and log files
rm -rf \
    "$REPO"/*.fastq.gz \
    "$REPO"/*.log \
    "$REPO"/*.zip

find "$OUTPUT_DIR" -type f -name "*.html" ! -name "NanoPlot-report.html" -delete