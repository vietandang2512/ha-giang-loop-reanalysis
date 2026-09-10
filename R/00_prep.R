# 00_prep.R -- load and recode both datasets. Sourced by every other script.
# Base R only: no packages, so `Rscript R/0X_*.R` runs on any machine with R.

CODES <- c("Harsh_Roads", "Villages_Temples", "Rivers_Fields",
           "Culture", "Locals", "Tour_Group", "Eating_Partying")

load_content <- function(path = "data/content_coding.csv") {
  d <- read.csv(path, stringsAsFactors = FALSE)
  for (v in CODES) d[[v]] <- as.integer(d[[v]] == "Yes")
  # Sender_Type = who owns the account that posted. NOT how the traveller travelled.
  # Tour_Group  = whether a group of riders is visible IN the post.
  # These are different things; the 2025 poster conflated them. See data/codebook.md.
  d$Agency <- as.integer(d$Sender_Type == "Agency")
  d$TikTok <- as.integer(d$Platform == "TikTok")
  d$n_themes <- rowSums(d[, CODES])
  d
}

load_survey <- function(path = "data/survey_responses.csv") {
  d <- read.csv(path, stringsAsFactors = FALSE)
  # multi-select fields are comma-joined strings; expand to indicators
  has <- function(col, pat) as.integer(grepl(pat, d[[col]], ignore.case = TRUE))
  d$found_tiktok    <- has("found_via", "TikTok")
  d$found_instagram <- has("found_via", "Instagram")
  d$found_wom       <- has("found_via", "Recommendations")
  d$found_social    <- as.integer(d$found_tiktok == 1 | d$found_instagram == 1)
  d$post_tiktok     <- has("upload_platforms", "TikTok")
  d$post_instagram  <- has("upload_platforms", "Instagram")
  d$motiv_scenery   <- has("motivation", "Scenery")
  d$motiv_culture   <- has("motivation", "culture|Socialis")
  d
}

# Cramer's V / phi for a 2x2 or larger table
cramers_v <- function(tab) {
  cs <- suppressWarnings(chisq.test(tab, correct = FALSE))
  sqrt(as.numeric(cs$statistic) / (sum(tab) * (min(dim(tab)) - 1)))
}

# tidy one-line chi-square without continuity correction
chisq_row <- function(d, group, outcome) {
  tab <- table(d[[group]], d[[outcome]])
  cs <- suppressWarnings(chisq.test(tab, correct = FALSE))
  data.frame(test = paste(group, "x", outcome),
             chisq = as.numeric(cs$statistic),
             p = cs$p.value,
             phi = cramers_v(tab),
             min_expected = min(cs$expected),
             stringsAsFactors = FALSE)
}

fmt <- function(x, k = 3) formatC(x, format = "f", digits = k)
