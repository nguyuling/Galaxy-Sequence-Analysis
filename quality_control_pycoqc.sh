REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality_control_pycoqc"
SUMMARY="$REPO/sequencing_summary.txt"

pycoQC \
    -f "$SUMMARY" \
    -o "$REPO/pycoqc_report.html"
