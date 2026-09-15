REPO="/Users/nguyuling/Galaxy-Sequence-Analysis/quality_control_nanoplot"
LONG_READS="$REPO/m64011_190830_220126.Q20.subsample.fastq"

NanoPlot \
  --fastq "$LONG_READS" \
  -o "$REPO" \
  --include-js embedded \
  --no_static \
  --plots dot kde \
  --N50
# include-js embedded to produce single html instead of separate ones for each chart
# no_statis to not download all chart img
# plots bivariate format of the plots
# N50 shows the minimumm reads length where 50% of the total bps is >= that length 
find "$REPO" -type f -name "*.html" ! -name "NanoPlot-report.html" -delete

fastqc "$LONG_READS" --outdir="$REPO"