#!/usr/bin/env bash
# Runs the full analysis top to bottom. Base R only, no package installs.
set -e
for f in R/0[1-4]*.R R/05_reliability.R R/06_figures.R; do
  echo; echo "### $f"; Rscript "$f"
done
