#!/bin/bash

set -e

REPO="/Volumes/T7/270918_quality_control_pycoqc"
SUMMARY_DIR="$REPO/1_Summary"
PYCOQC_DIR="$REPO/2_PycoQC"

mkdir -p "$REPO" "$SUMMARY_DIR" "$PYCOQC_DIR"

SUMMARY_URL="https://zenodo.org/records/5730295/files/sequencing_summary.txt"
SUMMARY_LOCAL="$SUMMARY_DIR/sequencing_summary.txt"
PYCOQC_BIN="$HOME/.venvs/pycoqc_env/bin/pycoQC"
PYCOQC_REPORT="$PYCOQC_DIR/pycoqc_report.html"

echo "1. Downloading nanopore long read's summary..."
curl -L -C - --retry 5 --retry-connrefused -o "$SUMMARY_LOCAL" "$SUMMARY_URL"

echo "2. Performing PycoQC on the summary..."
"$PYCOQC_BIN" \
    -f "$SUMMARY_LOCAL" \
    -o "$PYCOQC_REPORT"

echo "Completed quality control on nanopore long read's summary!"