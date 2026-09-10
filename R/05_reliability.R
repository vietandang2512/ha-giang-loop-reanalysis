# 05_reliability.R -- intercoder reliability. THIS IS NOT DONE YET.
#
# The 100 posts were coded by one person with no reliability check. Everything in
# scripts 01-03 rests on that coding. Until this script has real input, the content
# findings are provisional and the README says so.
#
# How to complete it:
#   1. Run this script. It writes data/recode_sample.csv: 20 post IDs, blank columns.
#   2. Recode those 20 posts from the original media WITHOUT looking at the first pass.
#   3. Fill the blanks in, save, run this script again. It computes Cohen's kappa.
#
# This is self-recode reliability (one coder, two occasions), which measures
# consistency, not agreement between independent coders. Label it that way.

source("R/00_prep.R")
set.seed(20250910)
d <- load_content()
path <- "data/recode_sample.csv"

if (!file.exists(path)) {
  ids <- sort(sample(d$ID, 20))
  blank <- data.frame(ID = ids)
  for (v in CODES) blank[[v]] <- NA_character_
  write.csv(blank, path, row.names = FALSE)
  cat("Wrote", path, "with", length(ids), "posts to recode.\n")
  cat("Fill in Yes/No for each code, then re-run this script.\n")
  quit(save = "no")
}

r <- read.csv(path, stringsAsFactors = FALSE)
if (any(is.na(r[, CODES]) | r[, CODES] == "")) {
  cat(path, "exists but is not filled in yet. Nothing to compute.\n")
  quit(save = "no")
}

kappa2 <- function(a, b) {
  tab <- table(factor(a, 0:1), factor(b, 0:1))
  po <- sum(diag(tab)) / sum(tab)
  pe <- sum(rowSums(tab) * colSums(tab)) / sum(tab)^2
  (po - pe) / (1 - pe)
}

orig <- d[match(r$ID, d$ID), ]
ks <- sapply(CODES, function(v)
  kappa2(orig[[v]], as.integer(r[[v]] == "Yes")))

cat("\n=== Cohen's kappa, first pass vs blind recode (n = 20) ===\n")
print(round(ks, 2))
cat("\nOverall (mean):", fmt(mean(ks), 2), "\n")
cat("Convention: >.80 strong, .60-.80 acceptable, <.60 revise the codebook.\n")
write.csv(data.frame(code = CODES, kappa = round(ks, 3)),
          "results/05_reliability.csv", row.names = FALSE)
