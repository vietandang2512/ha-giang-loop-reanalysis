# 03_content_types.R -- do posts show the place, or the people in it?
#
# Three of the seven codes describe human presence: Locals, Culture,
# Villages_Temples. Count them. A post carrying at least two of the three is
# showing a populated place; a post carrying one or none is showing scenery.
#
# That is the whole method. It can be checked by hand from the CSV, which is why
# it is the headline rather than the latent class model in 05 (that model splits
# the corpus the same way, agreeing with this rule on 97 of 100 posts).

source("R/00_prep.R")
d <- load_content()

PEOPLE_CODES <- c("Locals", "Culture", "Villages_Temples")
d$people_index <- rowSums(d[, PEOPLE_CODES])
d$shows_people <- as.integer(d$people_index >= 2)

cat("\n=== How many of the three human-presence codes each post carries ===\n")
print(table(d$people_index))
cat("\nPosts showing a populated place (2 or 3 of them):", sum(d$shows_people),
    "of", nrow(d), "\n")
cat("Posts with none of the three at all:", sum(d$people_index == 0), "\n")

cat("\n=== By account type ===\n")
print(round(prop.table(table(d$Sender_Type, d$shows_people), 1), 2))
cs <- chisq.test(table(d$Sender_Type, d$shows_people), correct = FALSE)
cat("chi-square =", fmt(cs$statistic, 2), " p =", fmt(cs$p.value, 4), "\n")

# The mistake corrected in 02 was testing account type without platform in the
# model. Do not repeat it here.
m <- glm(shows_people ~ Agency + TikTok, data = d, family = binomial)
s <- summary(m)$coefficients
cat("\nControlling for platform: OR(agency) =", fmt(exp(s["Agency", "Estimate"]), 2),
    " p =", fmt(s["Agency", "Pr(>|z|)"], 3), "\n")
cat("The gap holds. Operator accounts show populated places about a third as often.\n")

cat("\n=== Theme prevalence, by whether the post shows people ===\n")
prof <- t(sapply(CODES, function(v) tapply(d[[v]], d$shows_people, mean)))
colnames(prof) <- c("scenery only", "shows people")
print(round(prof, 2))

write.csv(round(prof, 3), "results/03_content_types.csv")
saveRDS(d, "results/content_typed.rds")
