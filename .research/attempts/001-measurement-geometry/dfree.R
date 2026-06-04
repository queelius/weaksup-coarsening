# Compute d_free: the dimension of the parameter degeneracy in `a` left by
# the gold-free agreement moments, given that E lives in a known r-dimensional
# subspace S of symmetric, zero-diagonal m x m matrices.
#
# Setup. Gold-free observation: the off-diagonal of A = a a^T + E, with E in S.
# An estimator that does NOT use gold must recover a from these off-diagonal
# entries. The set of (a, E) consistent with a given off-diagonal observation
# is a manifold; we want the dimension of its projection onto a-space near the
# truth (the number of free real directions in a that gold must pin).
#
# Local (Jacobian) computation. Consider the map from unknowns (a, c) to the
# off-diagonal moments, where c in R^r are the coordinates of E in a basis
# {B_1,...,B_r} of S (each B_t a symmetric zero-diagonal m x m matrix):
#   F(a, c)_{jk} = (a a^T)_{jk} + sum_t c_t (B_t)_{jk},   j < k.
# Stack the j<k entries into a vector of length M = m(m-1)/2.
# The truth (a*, c*) is a solution. The degenerate directions in a are those
# da such that there exists dc with DF (da, dc) = 0, i.e. the change in a can be
# absorbed by a change in E in S. Equivalently:
#   d_free = dim { da : (d(a a^T)/da)[da]  in  column-space(S restricted to
#                                                off-diag) }.
# We compute it as: nullity of the moment Jacobian restricted to a, AFTER
# quotienting out E. Concretely:
#   J_a  = d/da of off-diag(a a^T)   (M x m)
#   J_c  = d/dc of off-diag(E)        (M x r), columns = off-diag(B_t)
#   The combined Jacobian J = [J_a | J_c] (M x (m+r)).
#   The number of identifiable a-directions = rank(J) - rank(J_c)   (extra rank
#       that a contributes beyond what E alone spans).
#   d_free (unidentified a-directions) = m - (rank(J) - rank(J_c)).
#
# Intuition check: if S = 0 (r=0), J_c empty, identifiable a-dirs = rank(J_a).
# For generic a, off-diag(a a^T) Jacobian in a has rank m (m>=3), so d_free=0
# EXCEPT the global-sign / scaling degeneracy. Actually the T1 sign flip is a
# DISCRETE symmetry (a -> -a), not a continuous one, so locally d_free should
# be 0 for r=0, m>=3. Good: matches T2 (identifiable up to discrete flip).

set.seed(1)

# off-diagonal vectorizer for symmetric m x m (upper triangle j<k)
offdiag_vec <- function(M) {
  m <- nrow(M); idx <- which(upper.tri(M)); M[idx]
}
upper_idx <- function(m) which(upper.tri(matrix(0, m, m)))

# Jacobian of off-diag(a a^T) wrt a: entry (row for pair (j,k), col l)
#   d (a_j a_k) / d a_l = a_k [l=j] + a_j [l=k]
Ja_offdiag <- function(a) {
  m <- length(a)
  pairs <- which(upper.tri(matrix(0, m, m)), arr.ind = TRUE)  # rows j<k? check
  # upper.tri TRUE for row<col, so arr.ind col1=row(j), col2=col(k), j<k
  M <- nrow(pairs)
  J <- matrix(0, M, m)
  for (p in seq_len(M)) {
    j <- pairs[p, 1]; k <- pairs[p, 2]
    J[p, j] <- J[p, j] + a[k]
    J[p, k] <- J[p, k] + a[j]
  }
  J
}

# Build a basis of S for the "shared latent factor on disjoint pairs" mechanism
# used in sim.R: each dependent pair (j,k) contributes a single rank-1-ish
# symmetric perturbation supported on entries (j,k),(k,j). In the Gaussian
# copula construction the induced E off-diagonal is nonzero ONLY on the
# dependent pair entries. So each dependent pair => ONE basis matrix B_t with
# 1 on (j,k) and (k,j). Thus r = number of dependent pairs, and S has one
# generator per pair.
basis_pairs <- function(m, dep_pairs) {
  lapply(dep_pairs, function(pr) {
    B <- matrix(0, m, m); B[pr[1], pr[2]] <- 1; B[pr[2], pr[1]] <- 1; B
  })
}

# General "block / shared-factor" mechanism where a group of LFs shares ONE
# latent factor: E restricted to that group's off-diagonal is rank-one
# (u u^T off-diag for the group). A group of size s contributes basis matrices
# spanning the symmetric off-diagonal patterns reachable by varying the group's
# loadings. For a single shared scalar factor with fixed loadings, that is ONE
# generator; for free loadings it is s generators (the gradient wrt each
# loading). We will test both.

count_dims <- function(a, S_list) {
  Ja <- Ja_offdiag(a)
  if (length(S_list) == 0) {
    Jc <- matrix(0, nrow(Ja), 0)
  } else {
    Jc <- sapply(S_list, offdiag_vec)
    if (is.null(dim(Jc))) Jc <- matrix(Jc, ncol = 1)
  }
  rank_tol <- 1e-9
  rk <- function(X) if (ncol(X) == 0 || nrow(X) == 0) 0L else sum(svd(X)$d > rank_tol * max(1, svd(X)$d[1]))
  rA  <- rk(Ja)
  rC  <- rk(Jc)
  rAC <- rk(cbind(Ja, Jc))
  ident_a <- rAC - rC           # a-directions identifiable beyond E
  d_free  <- length(a) - ident_a
  list(m = length(a), r = ncol(Jc), rank_Ja = rA, rank_Jc = rC,
       rank_full = rAC, identifiable_a_dirs = ident_a, d_free = d_free)
}

cat("=== r=0 control (CI), m=3..8, generic a ===\n")
for (m in 3:8) {
  a <- runif(m, 0.3, 0.9)
  print(unlist(count_dims(a, list())))
}

cat("\n=== disjoint dependent PAIRS (sim.R mechanism), m=8 ===\n")
cat("each pair => 1 basis matrix; r = #pairs. Watch d_free vs r.\n")
a8 <- runif(8, 0.3, 0.9)
for (np in 0:4) {
  dp <- list(c(1,2), c(3,4), c(5,6), c(7,8))[seq_len(np)]
  S <- basis_pairs(8, dp)
  res <- count_dims(a8, S)
  cat(sprintf("  #pairs=%d  r=%d  rank_Ja=%d rank_Jc=%d rank_full=%d  ident_a=%d  d_free=%d\n",
              np, res$r, res$rank_Ja, res$rank_Jc, res$rank_full,
              res$identifiable_a_dirs, res$d_free))
}

cat("\n=== larger m, many disjoint pairs: does d_free track r? ===\n")
for (m in c(10, 20, 40)) {
  a <- runif(m, 0.3, 0.9)
  dp <- lapply(seq(1, m-1, by = 2), function(j) c(j, j+1))  # m/2 disjoint pairs
  S <- basis_pairs(m, dp)
  res <- count_dims(a, S)
  cat(sprintf("  m=%d  r(#pairs)=%d  ident_a=%d  d_free=%d\n",
              m, res$r, res$identifiable_a_dirs, res$d_free))
}

cat("\n=== generic r-dim subspace S (random symmetric off-diag) ===\n")
cat("E in a RANDOM r-dim subspace (not pair-structured). d_free vs r.\n")
random_S <- function(m, r) {
  lapply(seq_len(r), function(t) {
    B <- matrix(rnorm(m*m), m, m); B <- (B + t(B))/2; diag(B) <- 0; B
  })
}
for (m in c(8, 12, 20)) {
  a <- runif(m, 0.3, 0.9)
  cat(sprintf("  m=%d:\n", m))
  for (r in 0:min(m+2, 8)) {
    S <- random_S(m, r)
    res <- count_dims(a, S)
    cat(sprintf("    r=%d  ident_a=%d  d_free=%d\n", r, res$identifiable_a_dirs, res$d_free))
  }
}
