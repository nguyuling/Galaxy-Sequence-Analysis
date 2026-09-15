#!/bin/bash

set -e

REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality_control_pycoqc"
SUMMARY_URL="https://zenodo.org/records/5730295/files/sequencing_summary.txt"
SUMMARY_LOCAL="$REPO/sequencing_summary.txt"
PYCOQC_BIN="$HOME/.venvs/pycoqc_env/bin/pycoQC"
PYCOQC_REPORT="$REPO/pycoqc_report.html"

# 1. download summary
curl -L -C - --retry 5 --retry-connrefused -o "$SUMMARY_LOCAL" "$SUMMARY_URL"

# 2. perform pycoqc on the summary 
"$PYCOQC_BIN" \
    -f "$SUMMARY_LOCAL" \
    -o "$PYCOQC_REPORT"

# 3. remove summary file
rm -f "$SUMMARY_LOCAL"