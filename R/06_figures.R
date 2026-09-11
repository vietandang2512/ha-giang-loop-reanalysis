# 06_figures.R -- every figure in figures/ is produced here, none by hand.
# Run 03_content_types.R first (this script reads its saved classification).
#
# Figure titles state what is plotted, not what it means. The interpretation
# belongs in the README text beside them.

source("R/00_prep.R")
s <- load_survey()
stopifnot(file.exists("results/content_typed.rds"))
d <- readRDS("results/content_typed.rds")

BLUE <- "#2a78d6"; ORANGE <- "#eb6834"
INK <- "#0b0b0b"; MUTED <- "#52514e"; SURFACE <- "#fcfcfb"; GRID <- "#e2e1dd"
# (palette checked with the data-viz validator: adjacent CVD dE 24.7, all checks pass)

open_png <- function(f, w = 1600, h = 1000)
  png(file.path("figures", f), width = w, height = h, res = 200, bg = SURFACE)

base_par <- function(mar = c(4.5, 11, 2, 2))
  par(mar = mar, oma = c(0, 0, 3.6, 0), family = "sans", col.axis = MUTED,
      col.lab = MUTED, fg = MUTED, las = 1, xaxs = "i")

# Title and source note are drawn in the outer margin so they anchor to the
# device edge and cannot be pushed off-canvas by a wide left margin.
fig_title <- function(n, title, note) {
  mtext(sprintf("Figure %d.  %s", n, title), side = 3, line = 1.5, adj = 0,
        outer = TRUE, col = INK, cex = 0.95, font = 2)
  mtext(note, side = 3, line = 0.4, adj = 0, outer = TRUE, col = MUTED, cex = 0.7)
}
axis_label <- function(text, side = 1, line = 2.6)
  mtext(text, side = side, line = line, col = MUTED, cex = 0.78, las = 0)

# --- Figure 1: theme prevalence by post type ---------------------------------
prof <- read.csv("results/03_content_types.csv", row.names = 1)
labels <- c(Harsh_Roads = "Dangerous roads", Villages_Temples = "Villages & temples",
            Rivers_Fields = "Rivers & rice fields", Culture = "Cultural practice",
            Locals = "Local residents", Tour_Group = "The tour group",
            Eating_Partying = "Eating & partying")
m <- as.matrix(prof)[rev(CODES), c("shows.people", "scenery.only")]
open_png("01_content_types.png", 1600, 1050)
base_par()
bp <- barplot(t(m), beside = TRUE, horiz = TRUE, xlim = c(0, 1),
              col = c(BLUE, ORANGE), border = SURFACE, space = c(0, 0.6),
              names.arg = rep("", nrow(m)), axes = FALSE)
abline(v = seq(0, 1, 0.25), col = GRID)
barplot(t(m), beside = TRUE, horiz = TRUE, xlim = c(0, 1), add = TRUE,
        col = c(BLUE, ORANGE), border = SURFACE, space = c(0, 0.6),
        names.arg = rep("", nrow(m)), axes = FALSE)
axis(1, at = seq(0, 1, 0.25), labels = paste0(seq(0, 100, 25), "%"),
     col = GRID, tick = FALSE, cex.axis = 0.8)
text(-0.02, colMeans(bp), labels[rev(CODES)], adj = 1, xpd = NA, col = INK, cex = 0.82)
text(t(m) + 0.015, bp, sprintf("%.0f%%", 100 * t(m)), adj = 0, cex = 0.6, col = MUTED)
axis_label("Share of posts in which the theme appears")
fig_title(1, "Theme prevalence by post type",
          sprintf("100 coded posts. A post shows people if it carries at least two of local residents, cultural practice, villages and temples."))
legend("topright", legend = c(sprintf("Shows people (n = %d)", sum(d$shows_people)),
                                 sprintf("Scenery only (n = %d)", sum(!d$shows_people))),
       fill = c(BLUE, ORANGE), border = SURFACE, bty = "n", cex = 0.75, text.col = INK)
dev.off()

# --- Figure 2: discovery platform vs publication platform --------------------
open_png("02_discovery_vs_publication.png", 1500, 950)
base_par(c(4.5, 6.5, 2, 6))
found <- c(TikTok = sum(s$found_tiktok), Instagram = sum(s$found_instagram))
post  <- c(TikTok = sum(s$post_tiktok),  Instagram = sum(s$post_instagram))
plot(NA, xlim = c(0.82, 2.18), ylim = c(0, 60), axes = FALSE, xlab = "", ylab = "")
abline(h = seq(0, 60, 15), col = GRID)
for (i in seq_along(found)) {
  cl <- c(ORANGE, BLUE)[i]
  lines(c(1, 2), c(found[i], post[i]), col = cl, lwd = 3)
  points(c(1, 2), c(found[i], post[i]), pch = 19, cex = 1.4, col = cl)
  text(1 - 0.04, found[i], sprintf("%s  %d", names(found)[i], found[i]),
       adj = 1, col = INK, cex = 0.8, xpd = NA)
  text(2 + 0.04, post[i], sprintf("%d", post[i]), adj = 0, col = INK, cex = 0.8, xpd = NA)
}
axis(2, at = seq(0, 60, 15), col = GRID, tick = FALSE, cex.axis = 0.8)
mtext(c("Found the Loop there", "Post about it there"), side = 1, at = c(1, 2),
      line = 1, col = INK, cex = 0.82)
axis_label("Respondents", side = 2, line = 3.2)
fig_title(2, "Platform of discovery and platform of publication",
          "61 survey respondents, each reporting both. Exact McNemar test, p = 2.7e-05 (TikTok) and 3.5e-13 (Instagram).")
dev.off()

# --- Figure 3: reported experience vs coded depiction ------------------------
open_png("03_representation_gap.png", 1500, 700)
base_par(c(4.5, 15, 2, 3))
vals <- c("Enjoyed meeting locals\n(survey, n = 61)" = mean(s$q_locals >= 4),
          "Depict local residents\n(posts, n = 100)" = mean(d$Locals))
bp <- barplot(rev(vals), horiz = TRUE, xlim = c(0, 1), col = c(ORANGE, BLUE),
              border = SURFACE, axes = FALSE, names.arg = rep("", 2), space = 0.5)
abline(v = seq(0, 1, 0.25), col = GRID)
barplot(rev(vals), horiz = TRUE, xlim = c(0, 1), col = c(ORANGE, BLUE), add = TRUE,
        border = SURFACE, axes = FALSE, names.arg = rep("", 2), space = 0.5)
axis(1, at = seq(0, 1, 0.25), labels = paste0(seq(0, 100, 25), "%"),
     col = GRID, tick = FALSE, cex.axis = 0.8)
text(-0.02, bp, rev(names(vals)), adj = 1, xpd = NA, col = INK, cex = 0.8)
text(rev(vals) - 0.02, bp, sprintf("%.0f%%", 100 * rev(vals)), adj = 1,
     col = SURFACE, cex = 0.85, font = 2)
axis_label("Share of respondents, or of posts")
fig_title(3, "Reported enjoyment of local interaction, and depiction of locals in posts",
          "Two separate samples, so the comparison is descriptive. Survey item rated 4 or 5 on a five-point scale.")
dev.off()

# --- Figure 4: account type with and without platform in the model -----------
open_png("04_confounding.png", 1500, 700)
base_par(c(4.5, 13, 2, 3))
m1 <- glm(Locals ~ Agency, data = d, family = binomial)
m2 <- glm(Locals ~ Agency + TikTok, data = d, family = binomial)
est <- sapply(list(m1, m2), function(m) coef(m)["Agency"])
se  <- sapply(list(m1, m2), function(m) summary(m)$coefficients["Agency", "Std. Error"])
pv  <- sapply(list(m1, m2), function(m) summary(m)$coefficients["Agency", "Pr(>|z|)"])
lo <- exp(est - 1.96 * se); hi <- exp(est + 1.96 * se); or <- exp(est)
plot(NA, xlim = c(0.12, 2.4), ylim = c(0.6, 2.4), axes = FALSE,
     xlab = "", ylab = "", log = "x")
abline(v = 1, col = MUTED, lty = 2)
for (i in 1:2) {
  cl <- c(ORANGE, BLUE)[i]; y <- 3 - i
  lines(c(lo[i], hi[i]), c(y, y), col = cl, lwd = 3)
  points(or[i], y, pch = 19, cex = 1.5, col = cl)
  text(or[i], y + 0.2, sprintf("OR %.2f   p = %.3f", or[i], pv[i]), col = INK, cex = 0.75)
}
axis(1, at = c(0.125, 0.25, 0.5, 1, 2), labels = c("0.125", "0.25", "0.5", "1", "2"),
     col = GRID, tick = FALSE, cex.axis = 0.8)
text(0.105, c(2, 1), c("Account type only", "Account type + platform"),
     adj = 1, xpd = NA, col = INK, cex = 0.8)
axis_label("Odds ratio, operator account vs traveller account (log scale)")
fig_title(4, "Effect of account type on depicting local residents",
          "Logistic regression on 100 coded posts. Points are odds ratios, bars are 95% confidence intervals.")
dev.off()

cat("Wrote", length(list.files("figures", "\\.png$")), "figures.\n")
