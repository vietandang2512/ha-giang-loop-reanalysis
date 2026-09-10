# 06_figures.R -- every figure in figures/ is produced here, none by hand.
# Run 03_content_types.R first (this script reads its saved classification).

source("R/00_prep.R")
s <- load_survey()
stopifnot(file.exists("results/content_typed.rds"))
d <- readRDS("results/content_typed.rds")

BLUE <- "#2a78d6"; ORANGE <- "#eb6834"
INK <- "#0b0b0b"; MUTED <- "#52514e"; SURFACE <- "#fcfcfb"; GRID <- "#e2e1dd"
# (palette checked with the data-viz validator: adjacent CVD dE 24.7, all checks pass)

open_png <- function(f, w = 1600, h = 1100)
  png(file.path("figures", f), width = w, height = h, res = 200, bg = SURFACE)

base_par <- function(mar = c(4, 11, 2, 2))
  par(mar = mar, oma = c(0, 0, 4, 0), family = "sans", col.axis = MUTED,
      col.lab = MUTED, fg = MUTED, las = 1, xaxs = "i")

# Titles are drawn in the outer margin so they anchor to the device edge and
# cannot be pushed off-canvas by a wide left margin.
chart_title <- function(main, sub) {
  mtext(main, side = 3, line = 1.6, adj = 0, outer = TRUE,
        col = INK, cex = 1.05, font = 2)
  mtext(sub, side = 3, line = 0.3, adj = 0, outer = TRUE, col = MUTED, cex = 0.75)
}

# --- Fig 1: what each kind of post shows ---------------------------------------------------
prof <- read.csv("results/03_content_types.csv", row.names = 1)
labels <- c(Harsh_Roads = "Dangerous roads", Villages_Temples = "Villages & temples",
            Rivers_Fields = "Rivers & rice fields", Culture = "Cultural practice",
            Locals = "Local residents", Tour_Group = "The tour group",
            Eating_Partying = "Eating & partying")
m <- as.matrix(prof)[rev(CODES), c("shows.people", "scenery.only")]
open_png("01_content_types.png")
base_par()
bp <- barplot(t(m), beside = TRUE, horiz = TRUE, xlim = c(0, 1),
              col = c(BLUE, ORANGE), border = SURFACE, space = c(0, 0.6),
              names.arg = rep("", nrow(m)), axes = FALSE)
abline(v = seq(0, 1, 0.25), col = GRID); box(bty = "n")
barplot(t(m), beside = TRUE, horiz = TRUE, xlim = c(0, 1), add = TRUE,
        col = c(BLUE, ORANGE), border = SURFACE, space = c(0, 0.6),
        names.arg = rep("", nrow(m)), axes = FALSE)
axis(1, at = seq(0, 1, 0.25), labels = paste0(seq(0, 100, 25), "%"),
     col = GRID, tick = FALSE)
text(-0.02, colMeans(bp), labels[rev(CODES)], adj = 1, xpd = NA, col = INK, cex = 0.85)
text(t(m) + 0.015, bp, sprintf("%.0f%%", 100 * t(m)), adj = 0, cex = 0.62, col = MUTED)
chart_title("Two kinds of Ha Giang post",
            "How often each theme appears (n = 100). A post \"shows people\" if it carries at least two of locals, culture, villages")
legend("bottomright", legend = c(sprintf("Shows people (n = %d)", sum(d$shows_people)),
                                 sprintf("Scenery only (n = %d)", sum(!d$shows_people))),
       fill = c(BLUE, ORANGE), border = SURFACE, bty = "n", cex = 0.78, text.col = INK)
dev.off()

# --- Fig 2: discovery vs publication -----------------------------------------
open_png("02_discovery_vs_publication.png", 1500, 1050)
base_par(c(4, 6, 2, 6))
found <- c(TikTok = sum(s$found_tiktok), Instagram = sum(s$found_instagram))
post  <- c(TikTok = sum(s$post_tiktok),  Instagram = sum(s$post_instagram))
plot(NA, xlim = c(0.82, 2.18), ylim = c(0, 60), axes = FALSE, xlab = "", ylab = "")
abline(h = seq(0, 60, 15), col = GRID)
for (i in seq_along(found)) {
  cl <- c(ORANGE, BLUE)[i]
  lines(c(1, 2), c(found[i], post[i]), col = cl, lwd = 3)
  points(c(1, 2), c(found[i], post[i]), pch = 19, cex = 1.5, col = cl)
  text(1 - 0.04, found[i], sprintf("%s  %d", names(found)[i], found[i]),
       adj = 1, col = INK, cex = 0.82, xpd = NA)
  text(2 + 0.04, post[i], sprintf("%d", post[i]), adj = 0, col = INK, cex = 0.82, xpd = NA)
}
axis(2, at = seq(0, 60, 15), col = GRID, tick = FALSE, cex.axis = 0.8)
mtext(c("found the Loop there", "post about it there"), side = 1, at = c(1, 2),
      line = 1, col = INK, cex = 0.85)
chart_title("TikTok recruits, Instagram archives",
            "Respondents (n = 61); paired within person, McNemar p < .001 on both platforms")
dev.off()

# --- Fig 3: experience vs representation -------------------------------------
open_png("03_representation_gap.png", 1500, 950)
base_par(c(4, 15, 2, 3))
vals <- c("Enjoyed meeting locals\n(survey, n = 61)" = mean(s$q_locals >= 4),
          "Posts showing locals\n(content, n = 100)" = mean(d$Locals))
bp <- barplot(rev(vals), horiz = TRUE, xlim = c(0, 1), col = c(ORANGE, BLUE),
              border = SURFACE, axes = FALSE, names.arg = rep("", 2), space = 0.45)
abline(v = seq(0, 1, 0.25), col = GRID)
barplot(rev(vals), horiz = TRUE, xlim = c(0, 1), col = c(ORANGE, BLUE), add = TRUE,
        border = SURFACE, axes = FALSE, names.arg = rep("", 2), space = 0.45)
axis(1, at = seq(0, 1, 0.25), labels = paste0(seq(0, 100, 25), "%"),
     col = GRID, tick = FALSE)
text(-0.02, bp, rev(names(vals)), adj = 1, xpd = NA, col = INK, cex = 0.82)
text(rev(vals) - 0.02, bp, sprintf("%.0f%%", 100 * rev(vals)), adj = 1,
     col = SURFACE, cex = 0.9, font = 2)
chart_title("Everyone enjoys the people; few posts show them",
            "Two different samples, so this is a descriptive gap, not a within-person test")
dev.off()

# --- Fig 4: the confound ------------------------------------------------------
open_png("04_confounding.png", 1500, 950)
base_par(c(4, 13, 2, 3))
m1 <- glm(Locals ~ Agency, data = d, family = binomial)
m2 <- glm(Locals ~ Agency + TikTok, data = d, family = binomial)
est <- sapply(list(m1, m2), function(m) coef(m)["Agency"])
se  <- sapply(list(m1, m2), function(m) summary(m)$coefficients["Agency", "Std. Error"])
lo <- exp(est - 1.96 * se); hi <- exp(est + 1.96 * se); or <- exp(est)
plot(NA, xlim = c(0.1, 2.2), ylim = c(0.5, 2.5), axes = FALSE, xlab = "", ylab = "", log = "x")
abline(v = 1, col = MUTED, lty = 2)
for (i in 1:2) {
  cl <- c(ORANGE, BLUE)[i]
  lines(c(lo[i], hi[i]), c(3 - i, 3 - i), col = cl, lwd = 3)
  points(or[i], 3 - i, pch = 19, cex = 1.6, col = cl)
  text(or[i], 3 - i + 0.22, sprintf("OR %.2f", or[i]), col = INK, cex = 0.8)
}
axis(1, at = c(0.1, 0.25, 0.5, 1, 2), labels = c("0.1", "0.25", "0.5", "1", "2"),
     col = GRID, tick = FALSE)
text(0.085, c(2, 1), c("Account type alone\n(what I did in 2025)",
                       "Account type + platform\n(this reanalysis)"),
     adj = 1, xpd = NA, col = INK, cex = 0.82)
chart_title("My original finding was platform, not account type",
            "Odds that an agency post depicts local residents, with 95% CI. p = .044 -> p = .098")
dev.off()

cat("Wrote", length(list.files("figures", "\\.png$")), "figures.\n")
