# Interpretation (A): the dependence SUPPORT is UNKNOWN. We must recover a
# while E is an UNKNOWN sparse symmetric off-diagonal matrix of rank r (or
# support size s). Now the degeneracy can be real: many (a, E) pairs reproduce
# the same off-diagonal A.
#
# The cleanest formalization. The data programming / triplet method assumes
# E = 0 and reads a off the rank-one structure. If E is allowed to be an
# arbitrary symmetric off-diagonal matrix of rank <= r with UNKNOWN support,
# how many a are consistent with a given off-diagonal observation O = a* a*^T +
# E*?  i.e. solve for (a, E): off-diag(a a^T + E) = off-diag(O), rank(E) <= r.
#
# DIMENSION COUNT (global, not local). Unknowns: a in R^m (m params) plus E a
# symmetric rank-<=r off-diagonal matrix. A symmetric m x m rank-<=r matrix has
# dimension r*m - r(r-1)/2 (the variety of rank-<=r symmetric matrices). But E
# must be zero-diagonal: that is m linear constraints. Equations: M = m(m-1)/2
# off-diagonal matches.
#
# Naive parameter count for the solution set dimension:
#   dim(unknowns) = m + [ r*m - r(r-1)/2 ]   (a, then rank<=r symmetric E)
#   minus zero-diagonal constraints on E: - m   (approx, generically independent)
#   minus equations: - m(m-1)/2
# => expected solution dim
#   d = m + r*m - r(r-1)/2 - m - m(m-1)/2
#     = r*m - r(r-1)/2 - m(m-1)/2.
# This is the dim of the joint (a,E) solution set. The part we care about is its
# projection to a. We compute the JOINT Jacobian rank numerically at a true
# (a*, E*), with E* a generic symmetric rank-r zero-diagonal matrix, and report
# the nullity (joint solution dim) AND the a-projection dim.

set.seed(7)

upper_idx <- function(m) which(upper.tri(matrix(0, m, m)))
offdiag_vec <- function(M) M[upper.tri(M)]

# Build E* = sum_{t=1}^r lambda_t v_t v_t^T then zero the diagonal? Zeroing the
# diagonal breaks exact rank r. Instead use a symmetric rank-r matrix and treat
# "rank deficit r" as rank of the OFF-DIAGONAL residual. To stay faithful to the
# paper's diagnostic (rank of A - a a^T off-diagonal), we let E* be an arbitrary
# symmetric matrix whose OFF-DIAGONAL has rank r. Simplest: E* off-diagonal =
# sum_t v_t v_t^T off-diagonal, diagonal irrelevant (we only ever look at
# off-diagonal). So parametrize E by a symmetric matrix B and only its
# off-diagonal enters; rank-r off-diagonal means B = sum_{t<=r} v_t v_t^T.
#
# Joint unknown vector: theta = (a in R^m, V in R^{m x r}) with E = V V^T.
# Map G(theta) = off-diag(a a^T + V V^T) in R^M, M = m(m-1)/2.
# Jacobian wrt a: as before (a_k on col j, a_j on col k).
# Jacobian wrt V (entry V_{p,t}): d/dV_{p,t} of (V V^T)_{jk}
#   = [j=p] V_{k,t} + [k=p] V_{j,t}.

Ja_offdiag <- function(a) {
  m <- length(a); pr <- which(upper.tri(matrix(0,m,m)), arr.ind=TRUE)
  J <- matrix(0, nrow(pr), m)
  for (i in seq_len(nrow(pr))) { j<-pr[i,1]; k<-pr[i,2]; J[i,j]<-J[i,j]+a[k]; J[i,k]<-J[i,k]+a[j] }
  J
}
JV_offdiag <- function(V) {
  m <- nrow(V); r <- ncol(V); pr <- which(upper.tri(matrix(0,m,m)), arr.ind=TRUE)
  M <- nrow(pr); J <- matrix(0, M, m*r)
  colidx <- function(p,t) (t-1)*m + p
  for (i in seq_len(M)) {
    j<-pr[i,1]; k<-pr[i,2]
    for (t in seq_len(r)) {
      J[i, colidx(j,t)] <- J[i, colidx(j,t)] + V[k,t]
      J[i, colidx(k,t)] <- J[i, colidx(k,t)] + V[j,t]
    }
  }
  J
}
rk <- function(X, tol=1e-8) { if (length(X)==0 || nrow(X)==0 || ncol(X)==0) return(0L); s<-svd(X)$d; sum(s > tol*max(1,s[1])) }

joint_dims <- function(m, r) {
  a <- runif(m, 0.3, 0.9)
  V <- matrix(rnorm(m*r), m, r)
  if (r == 0) {
    J <- Ja_offdiag(a); nunk <- m
    rJ <- rk(J)
    return(list(m=m, r=r, M=m*(m-1)/2, n_unknowns=nunk, rank_J=rJ,
                joint_soln_dim=nunk-rJ, a_proj_dim_unident = m - rJ))
  }
  Ja <- Ja_offdiag(a); JV <- JV_offdiag(V)
  J <- cbind(Ja, JV)
  M <- m*(m-1)/2
  nunk <- m + m*r
  rJ <- rk(J)
  # a-directions identifiable = rank(J) - rank(JV) (extra rank a adds beyond E)
  rJV <- rk(JV)
  ident_a <- rJ - rJV
  list(m=m, r=r, M=M, n_unknowns=nunk, rank_J=rJ, rank_JV=rJV,
       joint_soln_dim = nunk - rJ,         # dim of (a,E) solution set
       a_unident_dim = m - ident_a)        # free directions in a (what gold pins)
}

cat("=== UNKNOWN-support E of off-diagonal rank r: joint identifiability ===\n")
cat("a_unident_dim = number of free a-directions gold must pin.\n\n")
for (m in c(6, 8, 12, 20)) {
  cat(sprintf("m=%d (M=%d off-diag eqns):\n", m, m*(m-1)/2))
  for (r in 0:min(m-1, 10)) {
    d <- joint_dims(m, r)
    cat(sprintf("  r=%2d  n_unk=%3d rank_J=%3d  joint_soln_dim=%3d  a_unident_dim=%2d\n",
                r, d$n_unknowns, d$rank_J, d$joint_soln_dim, d$a_unident_dim))
  }
  cat("\n")
}
