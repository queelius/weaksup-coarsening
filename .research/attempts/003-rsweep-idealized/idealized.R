# Idealized r-sweep: test the reduction's predicted scalings directly.
#
# The reduction (attempts 001-002): after the gold-free agreement moments fix
# the margin vector a on the orthogonal complement of an r-dim subspace U, gold
# must pin the U-component. Gold gives xi_i = a* + e_i, one centered Bernoulli
# per LF (per-coordinate var 1 - a_j^2). The hybrid estimator is
#   ahat = a* + P_U(xibar - a*) on U,  exact on U^perp.
# Equivalently the error is e_U := P_U(xibar - a*), an r-dim projection of an
# m-dim sub-Gaussian mean.
#
# We sweep r and gap INDEPENDENTLY and find the smallest n_g whose median
# recovery error meets a tolerance proportional to gap, under two losses:
#   L2:  ||e_U||_2   <= tol_frac * gap
#   Linf:||e_U||_inf <= tol_frac * gap
# Predictions:
#   L2  : n_g ~ r / gap^2   => log-log slope +1 in r, -2 in gap.
#   Linf: n_g ~ log r / gap^2 => slope ~0 (very weak) in r, -2 in gap.

set.seed(20260603)

# One replicate: draw n_g gold vectors, return the U-projected error (L2 & Linf).
# a_star: length-m true margins. U_basis: m x r orthonormal columns (the
# degenerate subspace). Bernoulli error: xi_ij in {-1,+1}, P(=+1)=alpha_j=(1+a)/2.
gold_error <- function(n_g, a_star, U_basis, cov = 1) {
  m <- length(a_star)
  alpha <- (1 + a_star) / 2
  # n_g x m matrix of centered correctness votes; coverage thins observations.
  # Each entry: with prob cov observed as +-1 (Bernoulli(alpha)); else missing.
  # For simplicity use full coverage (cov=1) in the main sweep; coverage only
  # rescales variance by 1/cov (constant), not the exponents.
  X <- matrix(rbinom(n_g * m, 1, rep(alpha, each = n_g)), n_g, m)  # 1=correct
  xi <- 2 * X - 1                                                  # +-1
  if (cov < 1) {
    obs <- matrix(rbinom(n_g * m, 1, cov), n_g, m)
    # per-LF mean over observed entries; if an LF has 0 obs, treat error huge
    xbar <- sapply(seq_len(m), function(j) {
      o <- obs[, j] == 1
      if (sum(o) == 0) return(NA_real_)
      mean(xi[o, j])
    })
  } else {
    xbar <- colMeans(xi)
  }
  if (anyNA(xbar)) xbar[is.na(xbar)] <- 0
  # projection of (xbar - a_star) onto U
  d <- xbar - a_star
  eU <- U_basis %*% (t(U_basis) %*% d)   # P_U d, length m
  list(l2 = sqrt(sum(eU^2)), linf = max(abs(eU)))
}

# random orthonormal m x r basis for U
rand_U <- function(m, r) {
  if (r == 0) return(matrix(0, m, 0))
  M <- matrix(rnorm(m * r), m, r)
  qr.Q(qr(M))[, seq_len(r), drop = FALSE]
}

# smallest n_g (on grid) with median(metric) <= thresh over nrep reps
smallest_ng <- function(grid, nrep, a_star, U_basis, thresh, which = "l2", cov = 1) {
  for (ng in grid) {
    vals <- replicate(nrep, {
      e <- gold_error(ng, a_star, U_basis, cov = cov)
      if (which == "l2") e$l2 else e$linf
    })
    if (median(vals) <= thresh) return(ng)
  }
  NA_real_
}

# ---------------- r-sweep at fixed gap ----------------
cat("=== r-sweep (gap fixed) ===\n")
m_fixed   <- 60                 # enough LFs to allow large r in clean regime
gap_fixed <- 0.20
tol_frac  <- 1.0                # tolerance = tol_frac * gap
nrep      <- 81
r_grid    <- c(1, 2, 3, 4, 6, 8, 12, 16, 24, 32)
ng_grid   <- unique(round(exp(seq(log(2), log(60000), length.out = 60))))

a_star_fixed <- rep(gap_fixed, m_fixed)   # all margins = gap (sign +)

res_r <- data.frame(r = r_grid, ng_l2 = NA_real_, ng_linf = NA_real_)
for (i in seq_along(r_grid)) {
  r <- r_grid[i]
  # average over a few random U to reduce orientation noise
  ng_l2_vals <- c(); ng_linf_vals <- c()
  for (rep_u in 1:5) {
    U <- rand_U(m_fixed, r)
    thr <- tol_frac * gap_fixed
    ng_l2_vals   <- c(ng_l2_vals,   smallest_ng(ng_grid, nrep, a_star_fixed, U, thr, "l2"))
    ng_linf_vals <- c(ng_linf_vals, smallest_ng(ng_grid, nrep, a_star_fixed, U, thr, "linf"))
  }
  res_r$ng_l2[i]   <- median(ng_l2_vals,   na.rm = TRUE)
  res_r$ng_linf[i] <- median(ng_linf_vals, na.rm = TRUE)
  cat(sprintf("  r=%2d  ng(L2)=%6.0f  ng(Linf)=%6.0f\n", r, res_r$ng_l2[i], res_r$ng_linf[i]))
}

slope_r_l2   <- coef(lm(log(ng_l2)   ~ log(r), data = res_r))[["log(r)"]]
slope_r_linf <- coef(lm(log(ng_linf) ~ log(r), data = res_r))[["log(r)"]]
# also fit ng_linf vs log(r) linearly (predict slope ~ const => linear in log r)
fit_linf_logr <- lm(ng_linf ~ log(r), data = res_r)

cat(sprintf("\n  log-log slope of ng vs r:  L2 = %.3f (predict +1),  Linf = %.3f (predict ~0)\n",
            slope_r_l2, slope_r_linf))
cat(sprintf("  Linf vs log(r) linear fit: intercept=%.1f slope=%.1f R^2=%.3f (predict ng ~ a + b log r)\n",
            coef(fit_linf_logr)[1], coef(fit_linf_logr)[2], summary(fit_linf_logr)$r.squared))

# ---------------- gap-sweep at fixed r ----------------
cat("\n=== gap-sweep (r fixed) ===\n")
r_fix2   <- 8
gap_grid <- c(0.08, 0.10, 0.14, 0.20, 0.28, 0.40)
res_g <- data.frame(gap = gap_grid, ng_l2 = NA_real_, ng_linf = NA_real_)
for (i in seq_along(gap_grid)) {
  gp <- gap_grid[i]
  a_star <- rep(gp, m_fixed)
  ng_l2_vals <- c(); ng_linf_vals <- c()
  for (rep_u in 1:5) {
    U <- rand_U(m_fixed, r_fix2)
    thr <- tol_frac * gp
    ng_l2_vals   <- c(ng_l2_vals,   smallest_ng(ng_grid, nrep, a_star, U, thr, "l2"))
    ng_linf_vals <- c(ng_linf_vals, smallest_ng(ng_grid, nrep, a_star, U, thr, "linf"))
  }
  res_g$ng_l2[i]   <- median(ng_l2_vals, na.rm = TRUE)
  res_g$ng_linf[i] <- median(ng_linf_vals, na.rm = TRUE)
  cat(sprintf("  gap=%.2f  ng(L2)=%6.0f  ng(Linf)=%6.0f\n", gp, res_g$ng_l2[i], res_g$ng_linf[i]))
}
slope_g_l2   <- coef(lm(log(ng_l2)   ~ log(gap), data = res_g))[["log(gap)"]]
slope_g_linf <- coef(lm(log(ng_linf) ~ log(gap), data = res_g))[["log(gap)"]]
cat(sprintf("\n  log-log slope of ng vs gap:  L2 = %.3f (predict -2),  Linf = %.3f (predict -2)\n",
            slope_g_l2, slope_g_linf))

saveRDS(list(res_r = res_r, res_g = res_g,
             slope_r_l2 = slope_r_l2, slope_r_linf = slope_r_linf,
             slope_g_l2 = slope_g_l2, slope_g_linf = slope_g_linf,
             m = m_fixed, gap_fixed = gap_fixed, r_fix2 = r_fix2),
        "idealized_results.rds")
cat("\nsaved idealized_results.rds\n")
