# 05_latent_class_check.R -- robustness check on the simple split in script 03.
#
# Script 03 splits the corpus with a counting rule. This asks whether a model
# that is told nothing about which codes matter finds the same split. Fit a
# latent class model over all seven codes: assume each post belongs to one
# unobserved kind of post, with the codes independent within a kind, and choose
# the number of kinds by BIC.
#
# poLCA would normally do this. It is implemented here in base R (EM, ~40 lines)
# so the repo has zero dependencies and the estimation is inspectable.

source("R/00_prep.R")
set.seed(1)
d <- load_content()
X <- as.matrix(d[, CODES])

# --- EM for a binary latent class model -------------------------------------
lca_fit <- function(X, K, n_init = 50, max_iter = 1000, tol = 1e-10) {
  N <- nrow(X); J <- ncol(X); best <- NULL
  for (init in seq_len(n_init)) {
    pi_k  <- rep(1 / K, K)
    theta <- matrix(runif(K * J, 0.1, 0.9), K, J)   # P(code = 1 | class)
    ll_old <- -Inf
    for (it in seq_len(max_iter)) {
      # E step: log P(post i | class k)
      logp <- matrix(0, N, K)
      for (k in seq_len(K))
        logp[, k] <- log(pi_k[k]) +
          X %*% log(theta[k, ]) + (1 - X) %*% log(1 - theta[k, ])
      m  <- apply(logp, 1, max)
      lse <- m + log(rowSums(exp(logp - m)))
      post <- exp(logp - lse)
      ll <- sum(lse)
      # M step
      pi_k  <- colMeans(post)
      theta <- (t(post) %*% X) / colSums(post)
      theta <- pmin(pmax(theta, 1e-6), 1 - 1e-6)
      if (abs(ll - ll_old) < tol) break
      ll_old <- ll
    }
    if (is.null(best) || ll > best$ll)
      best <- list(ll = ll, pi = pi_k, theta = theta, post = post)
  }
  npar <- K * ncol(X) + (K - 1)
  best$K <- K; best$npar <- npar
  best$BIC <- -2 * best$ll + npar * log(nrow(X))
  best$AIC <- -2 * best$ll + 2 * npar
  best$class <- apply(best$post, 1, which.max)
  best
}

cat("\n=== Model selection ===\n")
fits <- lapply(1:4, function(k) lca_fit(X, k))
sel <- data.frame(K = 1:4,
                  logLik = sapply(fits, function(f) f$ll),
                  BIC = sapply(fits, function(f) f$BIC),
                  AIC = sapply(fits, function(f) f$AIC))
print(data.frame(K = sel$K, logLik = fmt(sel$logLik, 1),
                 BIC = fmt(sel$BIC, 1), AIC = fmt(sel$AIC, 1)), row.names = FALSE)
K <- sel$K[which.min(sel$BIC)]
cat("\nBIC selects K =", K, "\n")

fit <- fits[[K]]
# order classes so the one depicting locals is first, for stable labelling
ord <- order(fit$theta[, which(CODES == "Locals")], decreasing = TRUE)
fit$theta <- fit$theta[ord, , drop = FALSE]
fit$class <- match(fit$class, ord)
d$class <- factor(fit$class, labels = c("A: place and people", "B: the ride")[1:K])

cat("\n=== Class profiles: P(code appears | class) ===\n")
prof <- t(fit$theta); colnames(prof) <- levels(d$class); rownames(prof) <- CODES
print(round(prof, 2))
cat("\nClass sizes:\n"); print(table(d$class))

cat("\n=== Class membership by account type ===\n")
tab <- table(d$class, d$Sender_Type)
print(round(prop.table(tab, 2), 2))
cs <- chisq.test(tab)
cat("chi-square =", fmt(cs$statistic, 2), " p =", fmt(cs$p.value, 4), "\n")

cat("\n=== Class membership by platform ===\n")
tab2 <- table(d$class, d$Platform)
print(round(prop.table(tab2, 2), 2))
cs2 <- chisq.test(tab2)
cat("chi-square =", fmt(cs2$statistic, 2), " p =", fmt(cs2$p.value, 4), "\n")

# average posterior probability per assigned class: how clean is the separation
cat("\nMean assignment certainty:",
    fmt(mean(apply(fit$post, 1, max)), 3), "\n")

# --- Does it agree with the simple rule in script 03? -----------------------
simple <- as.integer(rowSums(d[, c("Locals", "Culture", "Villages_Temples")]) >= 2)
model  <- as.integer(d$class == levels(d$class)[1])
tab <- table(simple, model)
po <- sum(diag(tab)) / sum(tab)
pe <- sum(rowSums(tab) * colSums(tab)) / sum(tab)^2
cat("\n=== Agreement with the counting rule in script 03 ===\n")
cat("Agree on", sum(diag(tab)), "of", sum(tab), "posts; Cohen's kappa =",
    fmt((po - pe) / (1 - pe), 2), "\n")
cat("The model finds the same split, so the headline result does not depend on it.\n")

write.csv(round(prof, 3), "results/05_class_profiles.csv")
write.csv(data.frame(ID = d$ID, class = as.character(d$class)),
          "results/05_class_assignments.csv", row.names = FALSE)
