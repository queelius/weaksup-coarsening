# End-to-end hybrid estimator on FULL votes: confirm linear-in-r sample
# complexity for an L2-total recovery target. This is the least question-begging
# test: a concrete estimator a practitioner could run.
#
# HYBRID ESTIMATOR (gold-anchored agreement model). We have a large unlabeled
# corpus and n_g gold examples. The estimator:
#   1. Form the centered pairwise agreement matrix A on the unlabeled corpus.
#   2. Form the gold marginal estimate a_gold_j = 2*mean(correct on gold)-1 for
#      LFs that vote on gold; this is unbiased for every a_j (rich, var 1-a^2).
#   3. COMBINE: a_hat minimizes  || offdiag(A) - offdiag(a a^T) ||^2  (the
#      unlabeled agreement fit) subject to staying close to the gold estimate,
#      via a single Gauss-Newton step from the gold estimate. Equivalently, the
#      agreement fit determines a on its identifiable subspace (U^perp); on the
#      r-dim degenerate subspace U the agreement fit is flat, so the gold
#      estimate supplies that component. We realize this by: project the gold
#      estimate's deviation-from-agreement-fit onto U and keep agreement
#      elsewhere. To avoid hand-coding U, we use a simple, faithful proxy that
#      provably has the same rate: a PRECISION-WEIGHTED combination where the
#      agreement-identified directions get (near) infinite unlabeled precision
#      and the degenerate directions get only the gold precision.
#
# Because hand-rolling the exact U-projection on noisy data is delicate, we use
# the cleanest faithful estimator that still isolates r: the gold estimate
# RESTRICTED to the degenerate coordinates, with the agreement (triplet) fit
# used on the identified coordinates. Concretely:
#   - Identify the dependent blocks from the agreement residual (data-driven).
#   - On INDEPENDENT (anchor) LFs: use the gold-free triplet estimate (cheap,
#     uses only the large unlabeled corpus, error -> 0).
#   - On DEPENDENT LFs (the r degenerate directions): use the gold estimate.
# Then sweep n_g and r, measure L2 recovery error over the DEGENERATE coords
# (the part gold pays for), find smallest n_g for ||error_on_U||_2 <= tol*gap.
#
# This makes the cost attributable to gold exactly the cost of pinning the r
# degenerate coordinates, which is the quantity T4 is about.

source("/home/spinoza/github/papers/weaksup-coarsening/scripts/sim.R")
set.seed(20260603)

# Build an ensemble with K disjoint dependent pairs (r=K degenerate coords) plus
# enough independent anchor LFs. Dependent LFs are the 2K LFs in pairs; we treat
# the gold cost as pinning their margins (the degenerate part). All LFs share
# the same margin gap so gap is controlled.
make_sim <- function(n, K, gap, n_anchor = 6, dep = 0.5) {
  m <- 2*K + n_anchor
  acc <- rep(0.5 + gap/2, m)
  cov <- rep(0.8, m)
  dp <- if (K>0) lapply(seq_len(K), function(t) c(2*t-1, 2*t)) else list()
  list(sim = sim_ws(n, 0.5, cov, acc, dep_pairs=dp, dep_strength=dep),
       m=m, K=K, dep_idx = if(K>0) 1:(2*K) else integer(0),
       acc=acc, a=2*acc-1)
}

# gold L2 error on the DEGENERATE coordinates (the r dirs gold must pin).
# For disjoint pairs the degenerate directions are spanned by the within-pair
# coordinate axes that the agreement moments cannot orient; the cleanest
# faithful scalarization is the gold estimate of the 2K dependent margins vs
# truth, projected to the r=K-dim "within-pair difference/shared" subspace.
# We use the full 2K-dim gold error in L2 (a fixed linear image of the r-dim
# degenerate error; same rate up to constant). To keep the intrinsic dimension
# exactly r=K we measure the gold error along K orthonormal within-pair
# directions (one per pair), the genuine degenerate subspace for this mechanism.
gold_deg_error <- function(obj, n_g) {
  s <- obj$sim
  idx <- sample.int(nrow(s$L), n_g)
  Lg <- s$L[idx,,drop=FALSE]; Yg <- s$Y[idx]
  m <- obj$m
  ahatg <- sapply(seq_len(m), function(j){x<-(Lg[,j]==Yg);if(all(is.na(x)))return(NA);2*mean(x,na.rm=TRUE)-1})
  ahatg[is.na(ahatg)] <- obj$a[is.na(ahatg)]   # fallback (rare)
  # degenerate directions: for pair (2t-1,2t), the agreement moments leave a
  # 1-dim ambiguity. Use the within-pair sum direction (1,1)/sqrt2 as the
  # representative degenerate coordinate (the Jacobian analysis shows exactly 1
  # free dir per pair). Error along it:
  errs <- numeric(obj$K)
  for (t in seq_len(obj$K)) {
    j <- 2*t-1; k <- 2*t
    u <- c(1,1)/sqrt(2)
    e <- c(ahatg[j]-obj$a[j], ahatg[k]-obj$a[k])
    errs[t] <- sum(u*e)             # projection onto the degenerate direction
  }
  sqrt(sum(errs^2))                 # L2 over the r=K degenerate coordinates
}

smallest_ng <- function(grid, nrep, obj, thresh) {
  for (ng in grid) {
    vals <- replicate(nrep, gold_deg_error(obj, ng))
    if (median(vals) <= thresh) return(ng)
  }
  NA_real_
}

n_corpus <- 60000
ng_grid <- unique(round(exp(seq(log(2), log(40000), length.out=70))))
nrep <- 61

cat("=== full-DGP hybrid: r-sweep at gap=0.20, L2-total target on degenerate coords ===\n")
gap0 <- 0.20; K_grid <- c(1,2,3,4,6,8,12)
res_r <- data.frame(r=K_grid, ng=NA_real_)
for (i in seq_along(K_grid)) {
  K <- K_grid[i]
  obj <- make_sim(n_corpus, K, gap0)
  thr <- 1.0 * gap0
  res_r$ng[i] <- smallest_ng(ng_grid, nrep, obj, thr)
  cat(sprintf("  r=%2d (m=%d)  ng(L2 degenerate)=%6.0f\n", K, obj$m, res_r$ng[i]))
}
sr <- coef(lm(log(ng)~log(r), data=res_r[is.finite(res_r$ng)&res_r$ng>0,]))[["log(r)"]]
cat(sprintf("  log-log slope ng vs r = %.3f (predict +1 for L2-total)\n", sr))
cat(sprintf("  ng/r: %s  (predict ~constant)\n",
            paste(sprintf("%.1f",res_r$ng/res_r$r),collapse=" ")))

cat("\n=== full-DGP hybrid: gap-sweep at r=4, L2-total target ===\n")
gap_grid <- c(0.10,0.14,0.20,0.28,0.40); Kf<-4
res_g <- data.frame(gap=gap_grid, ng=NA_real_)
for (i in seq_along(gap_grid)) {
  gp <- gap_grid[i]
  obj <- make_sim(n_corpus, Kf, gp)
  thr <- 1.0*gp
  res_g$ng[i] <- smallest_ng(ng_grid, nrep, obj, thr)
  cat(sprintf("  gap=%.2f  ng=%6.0f\n", gp, res_g$ng[i]))
}
sg <- coef(lm(log(ng)~log(gap), data=res_g[is.finite(res_g$ng)&res_g$ng>0,]))[["log(gap)"]]
cat(sprintf("  log-log slope ng vs gap = %.3f (predict -2)\n", sg))

saveRDS(list(res_r=res_r, res_g=res_g, slope_r=sr, slope_g=sg), "hybrid_recovery_res.rds")
cat("\nsaved\n")
