#!/usr/bin/env bash
# Runs the full analysis top to bottom. Base R only, no package installs.
set -e
for f in R/01_content_tests.R R/02_logistic_models.R R/03_content_types.R \
         R/04_survey.R R/06_figures.R R/07_latent_class_check.R; do
  echo; echo "### $f"; Rscript "$f"
done
