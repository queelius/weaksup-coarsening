# Idealized r-sweep v2: distinguish INTRINSIC-coordinate metrics carefully.
#
# The degenerate component is theta = B^T(a - a0) in R^r (B = orthonormal basis
# of U). Gold estimator: thetahat = B^T(xibar - a0). Error vector in R^r:
#   eps = thetahat - theta = B^T(xibar - a*),  approx N(0, (1/n_g) B^T Sigma B),
# with B^T Sigma B approx (1 - gap^2) I_r (Sigma = diag(1 - a_j^2), a_j = +-gap).
# So eps is r i.i.d.-ish N(0, v/n_g), v = 1 - gap^2 ~ 1.
#
# THREE clean metrics on the r-dim error eps:
#   (A) L2 total:        ||eps||_2   <= tol*gap   (whole r-vector)  => predict r/gap^2
#   (B) Linf intrinsic:  ||eps||_inf <= tol*gap   (each of r coords)=> predict log r/gap^2
#   (C) L2 per-coord:    ||eps||_2/sqrt(r) <= tol*gap (RMS per coord)=> predict 1/gap^2 (no r)
#
# This is the apples-to-apples test of the proof. Metric (A) is total/L2,
# Metric (B) is the union-bound (Linf over the r directions), Metric (C) is the
# per-coordinate normalization.

set.seed(20260603)

# error vector eps in R^r for one replicate
eps_vec <- function(n_g, a_star, B) {
  m <- length(a_star); r <- ncol(B)
  alpha <- (1 + a_star) / 2
  X <- matrix(rbinom(n_g * m, 1, rep(alpha, each = n_g)), n_g, m)
  xi <- 2 * X - 1
  xbar <- colMeans(xi)
  as.numeric(t(B) %*% (xbar - a_star))     # length r
}
rand_U <- function(m, r) { M <- matrix(rnorm(m*r), m, r); qr.Q(qr(M))[, seq_len(r), drop=FALSE] }

metric <- function(eps, which) {
  r <- length(eps)
  switch(which,
    l2      = sqrt(sum(eps^2)),
    linf    = max(abs(eps)),
    l2perc  = sqrt(sum(eps^2)/r))
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
r_grid <- c(1,2,3,4,6,8,12,16,24,32,48,64)
ng_grid <- unique(round(exp(seq(log(2), log(2e5), length.out = 80))))

cat("=== r-sweep, three metrics, gap fixed = 0.20 ===\n")
res <- data.frame(r=r_grid, ngA_l2=NA, ngB_linf=NA, ngC_l2perc=NA)
for (i in seq_along(r_grid)) {
  r <- r_grid[i]; a_star <- rep(gap_fixed, m_fixed); thr <- tol*gap_fixed
  vA<-c(); vB<-c(); vC<-c()
  for (ru in 1:7) {
    B <- rand_U(m_fixed, r)
    vA <- c(vA, smallest_ng(ng_grid, nrep, a_star, B, thr, "l2"))
    vB <- c(vB, smallest_ng(ng_grid, nrep, a_star, B, thr, "linf"))
    vC <- c(vC, smallest_ng(ng_grid, nrep, a_star, B, thr, "l2perc"))
  }
  res$ngA_l2[i]<-median(vA,na.rm=TRUE); res$ngB_linf[i]<-median(vB,na.rm=TRUE); res$ngC_l2perc[i]<-median(vC,na.rm=TRUE)
  cat(sprintf("  r=%2d  A:ng(L2tot)=%6.0f  B:ng(Linf)=%6.0f  C:ng(L2/sqrt r)=%6.0f\n",
              r, res$ngA_l2[i], res$ngB_linf[i], res$ngC_l2perc[i]))
}

# Fits
sA <- coef(lm(log(ngA_l2)~log(r), data=res))[["log(r)"]]
sB <- coef(lm(log(ngB_linf)~log(r), data=res))[["log(r)"]]
sC <- coef(lm(log(ngC_l2perc)~log(r), data=res))[["log(r)"]]
# For B, also fit linear in log r (the union-bound prediction ng = c*log(2r)/gap^2)
fB <- lm(ngB_linf ~ log(r), data=res)
# For C, slope should be ~0
cat(sprintf("\n  log-log slope vs r:  A(L2tot)=%.3f [predict +1]   B(Linf)=%.3f [predict ~0, log r]   C(L2/sqrt r)=%.3f [predict 0]\n",
            sA, sB, sC))
cat(sprintf("  B linear-in-log(r) fit: ng = %.2f + %.2f*log(r),  R^2=%.3f\n",
            coef(fB)[1], coef(fB)[2], summary(fB)$r.squared))
cat(sprintf("  B log-log fit R^2 (power law)=%.3f vs B lin-log(r) R^2=%.3f (higher R^2 => better model)\n",
            summary(lm(log(ngB_linf)~log(r),data=res))$r.squared, summary(fB)$r.squared))

# Predicted constants from theory:
# A (L2 total <= gap): E||eps||^2 = r*v/n_g <= gap^2 => n_g = r*v/gap^2, v=1-gap^2
# Using MEDIAN not mean and threshold on median, constant is similar order.
vth <- 1 - gap_fixed^2
cat(sprintf("\n  theory A: n_g ~ r*v/gap^2 = r*%.3f/%.3f = %.1f * r  (e.g. r=8 -> %.0f)\n",
            vth, gap_fixed^2, vth/gap_fixed^2, 8*vth/gap_fixed^2))
cat(sprintf("  theory B: n_g ~ v*2 log(2r)/gap^2 (median ~ v*qchisq factor); grows as log r\n"))

saveRDS(res, "idealized2_res.rds")
cat("\nsaved\n")
