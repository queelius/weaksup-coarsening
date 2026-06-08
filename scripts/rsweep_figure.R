# Idealized r-sweep: required gold-set size n_g versus the degeneracy
# dimension r at fixed accuracy margin gap, for the three loss criteria of
# rmk:r-dependence. Writes figures/rsweep_complexity.pdf and saves the swept
# table to rsweep_results.rds.
#
# This is the in-paper validation of the headline linear-in-r rate of
# thm:goldset. It is a base-R idealized study (no external data): it draws
# gold correctness vectors directly from the per-LF marginals and measures the
# smallest n_g at which each loss criterion is met along the r degenerate
# directions.
#
# The degenerate component is theta = B^T(a - a0) in R^r (B = orthonormal basis
# of the degenerate subspace U). Gold estimator: thetahat = B^T(xibar - a0).
# Error vector in R^r:
#   eps = thetahat - theta = B^T(xibar - a*),  approx N(0, (1/n_g) B^T Sigma B),
# with B^T Sigma B approx (1 - gap^2) I_r (Sigma = diag(1 - a_j^2), a_j = +-gap).
#
# THREE clean metrics on the r-dim error eps (the three losses of the remark):
#   (A) L2 total:        ||eps||_2   <= tol*gap  (whole r-vector) => r/gap^2
#   (B) Linf intrinsic:  ||eps||_inf <= tol*gap  (each of r coords)=> log r/gap^2
#   (C) L2 per-coord:    ||eps||_2/sqrt(r) <= tol*gap (RMS/coord) => 1/gap^2 (no r)
#
# Usage:
#   cd papers/weaksup-coarsening
#   Rscript scripts/rsweep_figure.R

set.seed(20260603)

script_dir <- local({
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) == 1L) {
        dirname(normalizePath(sub("^--file=", "", file_arg)))
    } else {
        normalizePath(".")
    }
})
proj_root <- normalizePath(file.path(script_dir, ".."))
fig_dir <- file.path(proj_root, "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# error vector eps in R^r for one replicate
eps_vec <- function(n_g, a_star, B) {
    m <- length(a_star)
    alpha <- (1 + a_star) / 2
    X <- matrix(rbinom(n_g * m, 1, rep(alpha, each = n_g)), n_g, m)
    xi <- 2 * X - 1
    xbar <- colMeans(xi)
    as.numeric(t(B) %*% (xbar - a_star)) # length r
}
rand_U <- function(m, r) {
    M <- matrix(rnorm(m * r), m, r)
    qr.Q(qr(M))[, seq_len(r), drop = FALSE]
}
metric <- function(eps, which) {
    r <- length(eps)
    switch(which,
        l2     = sqrt(sum(eps^2)),
        linf   = max(abs(eps)),
        l2perc = sqrt(sum(eps^2) / r))
}
smallest_ng <- function(grid, nrep, a_star, B, thresh, which) {
    for (ng in grid) {
        vals <- replicate(nrep, metric(eps_vec(ng, a_star, B), which))
        if (median(vals) <= thresh) return(ng)
    }
    NA_real_
}

m_fixed <- 80
gap_fixed <- 0.20
tol <- 1.0
nrep <- 101
r_grid <- c(1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64)
ng_grid <- unique(round(exp(seq(log(2), log(2e5), length.out = 80))))

cat("=== r-sweep, three loss criteria, gap fixed = 0.20 ===\n")
res <- data.frame(r = r_grid, ngA_l2 = NA, ngB_linf = NA, ngC_l2perc = NA)
for (i in seq_along(r_grid)) {
    r <- r_grid[i]
    a_star <- rep(gap_fixed, m_fixed)
    thr <- tol * gap_fixed
    vA <- c(); vB <- c(); vC <- c()
    for (ru in 1:7) {
        B <- rand_U(m_fixed, r)
        vA <- c(vA, smallest_ng(ng_grid, nrep, a_star, B, thr, "l2"))
        vB <- c(vB, smallest_ng(ng_grid, nrep, a_star, B, thr, "linf"))
        vC <- c(vC, smallest_ng(ng_grid, nrep, a_star, B, thr, "l2perc"))
    }
    res$ngA_l2[i] <- median(vA, na.rm = TRUE)
    res$ngB_linf[i] <- median(vB, na.rm = TRUE)
    res$ngC_l2perc[i] <- median(vC, na.rm = TRUE)
    cat(sprintf("  r=%2d  A:ng(L2tot)=%6.0f  B:ng(Linf)=%6.0f  C:ng(L2/sqrt r)=%6.0f\n",
                r, res$ngA_l2[i], res$ngB_linf[i], res$ngC_l2perc[i]))
}

# Loss-dependent rate fits (the three predictions of rmk:r-dependence).
sA <- coef(lm(log(ngA_l2) ~ log(r), data = res))[["log(r)"]]
sC <- coef(lm(log(ngC_l2perc) ~ log(r), data = res))[["log(r)"]]
fB <- lm(ngB_linf ~ log(r), data = res)               # Linf: linear in log r
r2B_loglog <- summary(lm(log(ngB_linf) ~ log(r), data = res))$r.squared
r2B_linlog <- summary(fB)$r.squared

# Theory line for the L2 criterion: E||eps||^2 = r*v/n_g <= gap^2
#   => n_g = (v/gap^2) * r, with v = 1 - gap^2.
vth <- 1 - gap_fixed^2
slopeA_theory <- vth / gap_fixed^2

cat(sprintf("\n  log-log slope vs r:  A(L2tot)=%.3f [predict +1]  C(L2/sqrt r)=%.3f [predict 0]\n",
            sA, sC))
cat(sprintf("  B(Linf) log-log R^2 (power law)=%.3f  vs  linear-in-log(r) R^2=%.3f\n",
            r2B_loglog, r2B_linlog))
cat(sprintf("  theory A: n_g = (v/gap^2) r = %.1f * r\n", slopeA_theory))

saveRDS(res, file.path(proj_root, "rsweep_results.rds"))

# -----------------------------------------------------------------
# Figure: n_g needed vs r for the three loss criteria, log-log.
# Panel A overlays the proven L2 theory line n_g = (v/gap^2) r (slope 1).
# Panel B contrasts Linf (grows as log r) and per-coord RMS (flat in r).
# -----------------------------------------------------------------
pdf(file.path(fig_dir, "rsweep_complexity.pdf"), width = 7, height = 3.2)
op <- par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.2, 1), mgp = c(2.4, 0.8, 0))

# Panel A: L2 total recovery, the operative criterion. Linear in r.
plot(res$r, res$ngA_l2, type = "b", pch = 19, col = "steelblue4", lwd = 2,
     log = "xy",
     xlab = "degeneracy dimension r",
     ylab = expression("gold examples needed " * (n[g])),
     main = "A. Total (L2) recovery", cex.main = 0.95)
lines(res$r, slopeA_theory * res$r, lty = 2, col = "grey40", lwd = 1.5)
legend("topleft", bty = "n", cex = 0.78,
       legend = c("simulation (L2 total)",
                  sprintf("theory n_g=(v/gap^2) r (fit slope %.2f)", sA)),
       col = c("steelblue4", "grey40"), lty = c(1, 2),
       lwd = c(2, 1.5), pch = c(19, NA))

# Panel B: the other two criteria. Linf ~ log r; per-coord RMS flat.
ylim_b <- range(c(res$ngB_linf, res$ngC_l2perc))
plot(res$r, res$ngB_linf, type = "b", pch = 19, col = "firebrick", lwd = 2,
     log = "x", ylim = ylim_b,
     xlab = "degeneracy dimension r",
     ylab = expression("gold examples needed " * (n[g])),
     main = "B. Per-direction and per-coordinate",
     cex.main = 0.92)
lines(res$r, coef(fB)[1] + coef(fB)[2] * log(res$r),
      lty = 2, col = "grey40", lwd = 1.5)
points(res$r, res$ngC_l2perc, type = "b", pch = 17, col = "darkgreen", lwd = 2)
legend("topleft", bty = "n", cex = 0.74,
       legend = c(expression(L[infinity] * " per-direction"),
                  sprintf("a + b log r (R^2=%.3f)", r2B_linlog),
                  "per-coordinate RMS (flat)"),
       col = c("firebrick", "grey40", "darkgreen"),
       lty = c(1, 2, 1), lwd = c(2, 1.5, 2), pch = c(19, NA, 17))

par(op)
dev.off()
cat("Wrote", file.path(fig_dir, "rsweep_complexity.pdf"), "\n")
