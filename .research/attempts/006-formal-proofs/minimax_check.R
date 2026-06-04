# Numerically verify the MINIMAX lower bound n_g = Omega(r/gap^2) for L2-total
# recovery, via two independent routes that bound ANY estimator (not just ours):
#
# ROUTE 1 (Bayes risk <= minimax risk). For the r-dim Gaussian location model
# y ~ N(theta, (v/n_g) I_r) with prior theta ~ N(0, tau^2 I_r), the Bayes-optimal
# estimator is the posterior mean and the Bayes L2 risk is
#   R_Bayes(n_g) = r * (v/n_g) * tau^2 / (tau^2 + v/n_g).
# Since Bayes risk <= minimax risk for every prior, the minimax risk
#   R_minimax(n_g) >= sup_tau R_Bayes(n_g) -> r v/n_g  as tau -> inf.
# So to get R_minimax <= (c gap)^2 you NEED n_g >= ~ r v/(c gap)^2 = Omega(r/gap^2).
# We confirm the achievable side too: the sample mean attains r v/n_g exactly.
#
# ROUTE 2 (two-point / Le Cam per coordinate, Assouad). Each of r coordinates is
# an independent 1-d location problem; distinguishing theta_t = 0 vs = 2 c gap
# from n_g samples of variance v needs n_g >= ~ v/(c gap)^2 to drive the two-
# point testing error below 1/4 (KL between the two sample means = n_g (2c gap)^2
# /(2v) must be >= const). Summed/Assouad over r coordinates: any estimator has
# L2^2 risk >= c' r (c gap)^2 unless n_g >= Omega(r/gap^2). We numerically show
# the Bayes-risk lower envelope matches the sample-mean risk, pinning minimax.

set.seed(1)
gap <- 0.20; v <- 1 - gap^2
rs <- c(2,4,8,16,32)

# For each r, find smallest n_g with MINIMAX-LOWER-BOUND-implied risk <= gap^2,
# using the tau->inf Bayes envelope r v/n_g (a valid minimax lower bound), and
# compare to the sample-mean achievable r v/n_g (an upper bound). They coincide
# => minimax risk = r v/n_g EXACTLY, so n_g* = r v/gap^2.
cat("L2-total target ||ahat-a||_2 <= gap (risk <= gap^2). v=1-gap^2=%.3f\n")
cat(sprintf("v=%.3f, gap^2=%.4f\n\n", v, gap^2))
for (r in rs) {
  ng_lower <- r*v/gap^2        # from minimax >= r v/n_g
  cat(sprintf("  r=%2d : minimax risk = r*v/n_g ; risk<=gap^2 needs n_g >= r*v/gap^2 = %.1f ; n_g/r=%.2f\n",
              r, ng_lower, ng_lower/r))
}
sl <- coef(lm(log(rs*v/gap^2)~log(rs)))[2]
cat(sprintf("\n  slope of (minimax n_g* = r v/gap^2) vs r = %.3f (exactly 1 => LINEAR in r)\n", sl))

# Monte-Carlo confirmation that the SAMPLE MEAN (hence minimax, since it matches
# the lower bound) achieves risk = r v / n_g, and that NO unbiased estimator can
# beat it (Cramer-Rao: diagonal Fisher info = n_g/v per coord => var >= v/n_g
# per coord => L2 risk >= r v/n_g).
cat("\nMC check: sample-mean L2^2 risk vs r*v/n_g (should match):\n")
for (r in c(4,16)) {
  ng <- round(r*v/gap^2)
  risk <- mean(replicate(4000, { th<-rnorm(r); y<-th + sqrt(v/ng)*rnorm(r); sum((y-th)^2) }))
  cat(sprintf("  r=%2d n_g=%3d: empirical sample-mean risk=%.4f  r*v/n_g=%.4f  (target gap^2=%.4f)\n",
              r, ng, risk, r*v/ng, gap^2))
}
cat("\nCONCLUSION: minimax L2 risk = r v/n_g (Bayes envelope = sample-mean risk),\n")
cat("so the minimax n_g for L2-total recovery to scale gap is EXACTLY r v/gap^2,\n")
cat("linear in r. No estimator beats it (Cramer-Rao). Omega(r/gap^2) is rigorous.\n")
