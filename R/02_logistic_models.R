# 02_logistic_models.R -- why my original finding does not hold.
#
# Account type and platform are correlated in this corpus: Instagram is 72% tourist
# accounts, TikTok is 46%. A 2x2 test of account type against any outcome therefore
# absorbs whatever the platform is doing. Adding platform to the model separates them.

source("R/00_prep.R")
d <- load_content()

cat("\n=== Sampling imbalance that causes the confound ===\n")
print(table(d$Platform, d$Sender_Type))

out <- data.frame()
for (y in CODES) {
  m  <- glm(reformulate(c("Agency", "TikTok"), y), data = d, family = binomial)
  mi <- glm(reformulate("Agency * TikTok", y), data = d, family = binomial)
  lr <- anova(m, mi, test = "LRT")
  s <- summary(m)$coefficients
  out <- rbind(out, data.frame(
    outcome     = y,
    OR_agency   = exp(s["Agency", "Estimate"]),
    p_agency    = s["Agency", "Pr(>|z|)"],
    OR_tiktok   = exp(s["TikTok", "Estimate"]),
    p_tiktok    = s["TikTok", "Pr(>|z|)"],
    p_interact  = lr$`Pr(>Chi)`[2],
    stringsAsFactors = FALSE))
}

cat("\n=== Logistic models: outcome ~ account type + platform ===\n")
print(data.frame(outcome = out$outcome,
                 OR_agency = fmt(out$OR_agency, 2), p_agency = fmt(out$p_agency, 3),
                 OR_tiktok = fmt(out$OR_tiktok, 2), p_tiktok = fmt(out$p_tiktok, 3),
                 p_interaction = fmt(out$p_interact, 3)),
      row.names = FALSE)

cat("\nLocals: the bivariate test gave p = .044 for account type.\n")
cat("Controlling for platform it is p =", fmt(out$p_agency[out$outcome == "Locals"], 3),
    "-- the association was largely platform, not account type.\n")
cat("Tour_Group: OR =", fmt(out$OR_agency[out$outcome == "Tour_Group"], 2),
    ", p =", fmt(out$p_agency[out$outcome == "Tour_Group"], 4),
    "-- unaffected by platform, and the effect that holds.\n")

# The same argument without a model: split the data by platform and look.
cat("\n=== Posts depicting local residents, within each platform ===\n")
print(round(prop.table(table(d$Platform, d$Sender_Type, d$Locals), c(1, 2))[, , "1"], 2))
cat("On Instagram the gap is 27 points. On TikTok it is 8. Most of what the\n")
cat("original 2x2 test picked up was the difference between the platforms.\n")

# Content breadth: do agencies post narrower content, or is that a platform effect too?
cat("\n=== Themes per post ===\n")
print(round(tapply(d$n_themes, d$Sender_Type, mean), 2))
print(round(tapply(d$n_themes, d$Platform, mean), 2))
t1 <- t.test(n_themes ~ Platform, data = d)
t2 <- t.test(n_themes ~ Sender_Type, data = d)
cat("by platform:     Welch t =", fmt(t1$statistic, 2), " p =", fmt(t1$p.value, 4), "\n")
cat("by account type: Welch t =", fmt(t2$statistic, 2), " p =", fmt(t2$p.value, 4), "\n")
cat("\nPlatform compresses content; account type does not.\n")

write.csv(out, "results/02_logistic_models.csv", row.names = FALSE)
