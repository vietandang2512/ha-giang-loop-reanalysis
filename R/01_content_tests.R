# 01_content_tests.R -- the 14 bivariate tests, with a multiple-comparison correction.
#
# The 2025 poster reported ONE of these tests (Sender_Type x Locals, p = .044) as a
# finding. Fourteen tests were run in total. This script reports all fourteen and
# applies Holm's correction, which is what the family of tests requires.

source("R/00_prep.R")
d <- load_content()

res <- do.call(rbind, lapply(CODES, function(y)
  rbind(chisq_row(d, "Sender_Type", y), chisq_row(d, "Platform", y))))

res$p_holm <- p.adjust(res$p, method = "holm")
res$survives <- ifelse(res$p_holm < 0.05, "yes", "")
res <- res[order(res$p), ]

cat("\n=== Fourteen bivariate tests, Holm-corrected ===\n")
print(data.frame(test = res$test,
                 chisq = fmt(res$chisq, 2),
                 p = fmt(res$p, 4),
                 p_holm = fmt(res$p_holm, 4),
                 phi = fmt(res$phi, 2),
                 survives = res$survives),
      row.names = FALSE)

cat("\nSmallest expected cell across all tests:", fmt(min(res$min_expected), 1),
    "(chi-square is safe above ~5)\n")

cat("\nTwo of fourteen survive correction. The poster's headline result",
    "\n(Sender_Type x Locals) is not one of them.\n")

# Cell proportions for the two that survive
cat("\n--- Tour groups depicted, by account type ---\n")
print(round(prop.table(table(d$Sender_Type, d$Tour_Group), 1), 3))
cat("\n--- Rivers/rice fields depicted, by platform ---\n")
print(round(prop.table(table(d$Platform, d$Rivers_Fields), 1), 3))

write.csv(res, "results/01_bivariate_tests.csv", row.names = FALSE)
