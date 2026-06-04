# Which loss is operationally correct for weak supervision? The deliverable is
# the probabilistic training labels P(Y | votes). We measure how the error in
# those labels (KL from the true posterior, averaged over the vote distribution)
# depends on the margin-estimation error, to decide whether the right success
# criterion is L2-total (=> linear r) or Linf-per-direction (=> log r).
#
# Naive-Bayes posterior log-odds for an example with vote pattern lambda:
#   logit P(Y=1|lambda) = logit(pi) + sum_{j: votes} s_j * atanh(a_j)
# where s_j = +1 if lambda_j=1 else -1, and atanh(a_j) is the per-LF log-odds
# weight (since acc_j=(1+a_j)/2 => log(acc/(1-acc)) = 2 atanh(a_j); the per-vote
# contribution is s_j * log(acc_j/(1-acc_j)) = 2 s_j atanh(a_j)). Constant
# factor 2 absorbed below.
#
# If we perturb a -> a + da, the logit perturbs by sum_j s_j * w'(a_j) da_j with
# w(a)=2 atanh(a), w'(a)=2/(1-a^2). The expected KL between perturbed and true
# posterior (over examples) is, to second order,
#   E[KL] ~ (1/2) E_lambda[ Var stuff ] ~ (1/2) sum_j beta_j p_j (1-p_j-ish)
#           * w'(a_j)^2 da_j^2  =  a POSITIVE-DEFINITE QUADRATIC FORM in da.
# => E[KL] = da^T G da for a diagonal-dominant PSD matrix G (a SUM over LFs).
# This is an L2-type (sum-of-squares) functional of da, NOT a max/Linf. So the
# operationally correct success criterion is total/L2, confirming the linear-r
# rate. We verify this empirically.

source("/home/spinoza/github/papers/weaksup-coarsening/scripts/sim.R")
set.seed(20260603)

m <- 10; cov <- rep(0.8,m); gap <- 0.20
acc <- rep(0.5+gap/2, m); a <- 2*acc-1; pi0 <- 0.5
sim <- sim_ws(200000, pi0, cov, acc)        # CI corpus to define the posterior

logit <- function(p) log(p/(1-p))
inv <- function(z) 1/(1+exp(-z))
# true posterior over the corpus
post_from_a <- function(L, a_vec, pi_v) {
  acc_v <- pmin(pmax((1+a_vec)/2,1e-6),1-1e-6)
  n<-nrow(L); z<-rep(logit(pi_v), n)
  for (j in seq_len(ncol(L))) { v<-L[,j]; ok<-!is.na(v)
    w <- ifelse(v[ok]==1L, log(acc_v[j]/(1-acc_v[j])), log((1-acc_v[j])/acc_v[j]))
    z[ok] <- z[ok] + w }
  inv(z)
}
mean_kl <- function(p, q) { p<-pmin(pmax(p,1e-9),1-1e-9); q<-pmin(pmax(q,1e-9),1-1e-9)
  mean(p*log(p/q) + (1-p)*log((1-p)/(1-q))) }

p_true <- post_from_a(sim$L, a, pi0)

# (1) KL vs ||da||_2^2 for RANDOM perturbations (should be ~ linear in ||da||^2,
#     i.e. quadratic form => slope ~1 on log-log of KL vs ||da||^2)
cat("=== KL(perturbed posterior || true) vs perturbation norm ===\n")
scales <- c(0.01,0.02,0.04,0.08,0.12,0.16)
resq <- data.frame(scale=scales, l2sq=NA, linf=NA, kl=NA)
for (i in seq_along(scales)) {
  sc <- scales[i]
  kls<-c(); l2s<-c(); lis<-c()
  for (rep in 1:40) {
    da <- rnorm(m); da <- da/sqrt(sum(da^2)) * sc   # ||da||_2 = sc
    p_pert <- post_from_a(sim$L, a+da, pi0)
    kls<-c(kls, mean_kl(p_true, p_pert)); l2s<-c(l2s, sum(da^2)); lis<-c(lis, max(abs(da)))
  }
  resq$kl[i]<-mean(kls); resq$l2sq[i]<-mean(l2s); resq$linf[i]<-mean(lis)
}
print(round(resq,5))
slope_kl_l2 <- coef(lm(log(kl)~log(l2sq), data=resq))[2]
cat(sprintf("  log-log slope KL vs ||da||_2^2 = %.3f (predict 1 => KL is an L2 quadratic form)\n", slope_kl_l2))

# (2) Compare: fix ||da||_2 (total) constant but redistribute -- KL should be
#     ~ invariant to whether error is concentrated (large Linf) or spread,
#     confirming it is the L2 norm, not Linf, that governs label quality.
cat("\n=== KL invariance to error SHAPE at fixed ||da||_2 (concentrated vs spread) ===\n")
sc <- 0.10
# concentrated: all error in one coordinate (large Linf, same L2)
# spread: equal error across all coords (small Linf, same L2)
kl_conc <- mean(replicate(40,{da<-rep(0,m);da[sample(m,1)]<-sample(c(-1,1),1)*sc;mean_kl(p_true,post_from_a(sim$L,a+da,pi0))}))
kl_spread <- mean(replicate(40,{da<-sample(c(-1,1),m,TRUE)*sc/sqrt(m);mean_kl(p_true,post_from_a(sim$L,a+da,pi0))}))
cat(sprintf("  ||da||_2=%.2f:  concentrated(Linf=%.2f) KL=%.5f   spread(Linf=%.2f) KL=%.5f\n",
            sc, sc, kl_conc, sc/sqrt(m), kl_spread))
cat(sprintf("  ratio concentrated/spread = %.2f (close to 1 => L2 governs, NOT Linf)\n", kl_conc/kl_spread))

cat("\nCONCLUSION: downstream label KL is an L2 (sum-over-LFs) quadratic form in\n")
cat("the margin error, roughly invariant to error shape at fixed L2 norm. So the\n")
cat("operationally-correct success criterion for 'restore the label model' is\n")
cat("the TOTAL/L2 one => the LINEAR-r rate Theta(r/gap^2) is the relevant rate.\n")
