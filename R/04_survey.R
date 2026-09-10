# 04_survey.R -- what travellers say, and what they post.

source("R/00_prep.R")
s <- load_survey()
cat("n =", nrow(s), "\n")

# --- Discovery vs publication ------------------------------------------------
# Each respondent reports where they FOUND the Loop and where they POST about it.
# Those are two measurements on the same person, so the comparison is paired:
# McNemar, not a two-sample test.
cat("\n=== Where people find the Loop vs where they post about it ===\n")
for (p in list(c("TikTok", "found_tiktok", "post_tiktok"),
               c("Instagram", "found_instagram", "post_instagram"))) {
  tab <- table(factor(s[[p[2]]], 0:1), factor(s[[p[3]]], 0:1))
  # discordant counts are small (3 and 25), so use the exact binomial form of
  # McNemar's rather than the chi-square approximation
  b <- tab[1, 2]; c_ <- tab[2, 1]
  mt <- binom.test(b, b + c_, 0.5)
  cat(sprintf("%-10s found by %2d, posted to by %2d | discordant %d/%d | p = %s\n",
              p[1], sum(s[[p[2]]]), sum(s[[p[3]]]),
              b, c_, format.pval(mt$p.value, digits = 3)))
}
cat("\nOf the", sum(s$found_tiktok), "who found the Loop on TikTok,",
    sum(s$found_tiktok & s$post_tiktok), "post to TikTok.\n")
cat("TikTok recruits; Instagram archives. The 'double loop' runs on two platforms,\n",
    "and per script 02 those platforms carry systematically different imagery.\n")

# --- Experience vs representation -------------------------------------------
cat("\n=== Representation gap ===\n")
cat("Rated 'I enjoyed interactions with locals, staff and easyriders' >= 4:",
    sum(s$q_locals >= 4), "of", nrow(s), "\n")
cat("Named scenery as a motivation:", sum(s$motiv_scenery), "\n")
cat("Named culture or socialising as a motivation:", sum(s$motiv_culture), "\n")
if (file.exists("results/content_with_class.rds")) {
  d <- readRDS("results/content_with_class.rds")
  cat("Posts depicting locals:", sum(d$Locals), "of", nrow(d),
      sprintf(" (%.0f%%)\n", 100 * mean(d$Locals)))
  cat("-> Universal enjoyment of the human side; it appears in a minority of posts.\n")
}

# --- The null the poster reported, and how fragile it is ---------------------
cat("\n=== Perceived accuracy of social-media portrayal, by discovery channel ===\n")
t1 <- t.test(q_accurate ~ found_wom, data = s)
cat("Poster's split (friends/family vs other):",
    sprintf("%.2f vs %.2f, p = %s\n", rev(t1$estimate)[1], rev(t1$estimate)[2],
            fmt(t1$p.value, 3)))
t2 <- t.test(q_accurate ~ found_social, data = s)
d_hedge <- diff(rev(t2$estimate)) /
  sqrt(mean(tapply(s$q_accurate, s$found_social, var)))
cat("Social-media discovery vs other:",
    sprintf("%.2f vs %.2f, p = %s, d = %.2f\n", rev(t2$estimate)[1], rev(t2$estimate)[2],
            fmt(t2$p.value, 3), abs(d_hedge)))
cat("The null holds for one split and not the other. Report it as one specific\n",
    "comparison, not as 'discovery channel does not matter'.\n")

# --- Return intent: an honest negative ---------------------------------------
cat("\n=== Return intent ===\n")
print(table(s$q_return))
preds <- c("q_accurate", "q_locals", "q_price", "q_stay", "q_danger",
           "q_highlight", "q_recommend")
cors <- sapply(preds, function(v) cor(s[[v]], s$q_return))
print(round(cors, 2))
cat("Nothing measured predicts return intent (max |r| =", fmt(max(abs(cors)), 2), ").\n")
cat(sum(s$q_return == 3), "of", nrow(s), "are neutral. A place nearly everyone\n",
    "recommends and few plan to revisit is worth a sentence in the conclusions.\n")

# --- Known data-collection artefact -----------------------------------------
cat("\n=== Note on the partying item ===\n")
cat("Answered by", sum(!is.na(s$q_party)), "of", nrow(s),
    "respondents. It was added to the form mid-collection on",
    min(s$timestamp[!is.na(s$q_party)]), "\n")
cat("This is a question-timing artefact, not self-selection. Do not interpret\n",
    "the item as if all 61 respondents chose whether to answer it.\n")
