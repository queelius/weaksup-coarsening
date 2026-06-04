# Confirm the constants and clean rates with a Gaussian surrogate (exact, fast)
# so we can use very fine n_g resolution and many reps. The reduction says the
# r-dim error eps ~ N(0, (v/n_g) I_r), v = 1 - gap^2. We verify:
#  (A) L2 total: smallest n_g with median||eps||_2 <= gap is r*v/gap^2 * 1/med_chi2_factor
#  (B) Linf:     smallest n_g with median max_t|eps_t| <= gap grows as log r
#  (C) per-coord RMS: flat in r at v/gap^2.
# Using the Gaussian model directly removes Bernoulli discreteness and grid
# coarseness; then we cross-check against the Bernoulli sim's constants.

set.seed(1)

# For metric, the median over reps of the metric as a function of n_g is
# monotone decreasing; solve median(metric)=gap exactly via the known
# distribution where possible, else by fine Monte Carlo + interpolation.

# Exact-ish: eps_t = sqrt(v/n_g) Z_t, Z ~ N(0,1) iid (t=1..r).
#  ||eps||_2^2 = (v/n_g) * chi2_r.  median ||eps||_2 = sqrt(v/n_g * median(chi2_r)).
#    set = gap => n_g = v * median(chi2_r) / gap^2.
#  ||eps||_inf = sqrt(v/n_g) * max|Z_t|. median(max|Z|_r) =: Mr.
#    set = gap => n_g = v * Mr^2 / gap^2.
#  RMS = sqrt(v/n_g * chi2_r / r). median = sqrt(v/n_g * median(chi2_r)/r).
#    set = gap => n_g = v * median(chi2_r)/r / gap^2  -> flat as median(chi2_r)/r ->1.

v <- 1 - 0.20^2; gap <- 0.20
rs <- c(1,2,3,4,6,8,12,16,24,32,48,64,96,128)
medchi2 <- qchisq(0.5, df = rs)                 # median of chi2_r
# median of max_t |Z_t| over r std normals, by MC
medmax <- sapply(rs, function(r) median(replicate(20000, max(abs(rnorm(r))))))

ngA <- v * medchi2 / gap^2
ngB <- v * medmax^2 / gap^2
ngC <- v * (medchi2/rs) / gap^2

df <- data.frame(r=rs, ngA=ngA, ngB=ngB, ngC=ngC,
                 ngA_over_r = ngA/rs, medmax2=medmax^2)
print(round(df,2))

cat("\n--- A: n_g/r should approach a CONSTANT (=> linear in r) ---\n")
cat(sprintf("  n_g(A)/r at r=4,16,64,128 = %.2f, %.2f, %.2f, %.2f  (-> %.2f = v/gap^2)\n",
            ngA[rs==4]/4, ngA[rs==16]/16, ngA[rs==64]/64, ngA[rs==128]/128, v/gap^2))
sA <- coef(lm(log(ngA)~log(rs)))[2]
cat(sprintf("  log-log slope of n_g(A) vs r over full range = %.3f (-> 1 as r grows)\n", sA))
sA_big <- coef(lm(log(ngA[rs>=16])~log(rs[rs>=16])))[2]
cat(sprintf("  log-log slope of n_g(A) vs r for r>=16 = %.3f (predict 1)\n", sA_big))

cat("\n--- B: n_g(B) should be LINEAR in log r (=> log r rate) ---\n")
fB <- lm(ngB ~ log(rs))
cat(sprintf("  n_g(B) = %.2f + %.2f*log(r),  R^2 = %.4f\n", coef(fB)[1], coef(fB)[2], summary(fB)$r.squared))
cat(sprintf("  predicted slope b = v/gap^2 * (d/dlog r of Mr^2). Mr^2 ~ 2 log r for large r,\n"))
cat(sprintf("    so b -> 2v/gap^2 = %.2f; fitted b = %.2f\n", 2*v/gap^2, coef(fB)[2]))
# ratio test: n_g(B) at r and 2r differ by ~ constant (log) not by factor
cat("  consecutive differences n_g(B)[2r]-n_g(B)[r] (should be ~ constant):\n")
for (r in c(4,8,16,32,64)) {
  a <- ngB[rs==r]; b <- ngB[rs==2*r]
  if (length(a)&&length(b)) cat(sprintf("    r=%d->2r: diff=%.2f\n", r, b-a))
}

cat("\n--- C: n_g(C) flat (-> v/gap^2 = ", round(v/gap^2,2), ") ---\n", sep="")
cat(sprintf("  n_g(C) at r=1,8,64,128 = %.2f, %.2f, %.2f, %.2f\n",
            ngC[rs==1], ngC[rs==8], ngC[rs==64], ngC[rs==128]))

cat("\nCONCLUSION: A is Theta(r/gap^2); B is Theta(log r / gap^2); C is Theta(1/gap^2).\n")
