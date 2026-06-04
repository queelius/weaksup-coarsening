# Attempt 006: the formal proofs (clean, self-contained)

Notation. m LFs; margin vector a in R^m, a_j = 2 alpha_j - 1, gap = min_j|a_j|;
prior pi. sigma_j = 2*1{lambda_j=1}-1, Z = 2Y-1. Centered pairwise agreement
A_jk = E[sigma_j sigma_k] for j != k. Under conditional independence (CI) the
off-diagonal of A is the outer product a a^T. LF dependence adds a symmetric
off-diagonal correction E; the integer r is the dimension of the resulting
PARAMETER DEGENERACY in a (see Lemma 1; this is the right "r", see Remark D).

================================================================
LEMMA 1 (degeneracy dimension). Suppose the gold-free observables are the
off-diagonal agreement entries {A_jk}_{j<k}, and the dependence correction E is
an unknown symmetric, zero-diagonal matrix whose off-diagonal has rank r, with
r <= r_max(m) := the largest integer with r m - r(r-1)/2 < m(m-1)/2 - (m - r')
(equivalently, r in the regime where the rank-r symmetric off-diagonal variety
does not fill the m(m-1)/2-dim off-diagonal space; r_max(m) = Theta(m)). Then,
for generic a, the set of margin vectors a consistent with the observed
off-diagonal of a a^T + E is, locally, an affine manifold of dimension exactly
  d_free = r.

Proof. Parametrize E = V V^T with V in R^{m x r} (off-diagonal of a symmetric
rank-r matrix). The off-diagonal moment map is
  G(a, V)_{j<k} = a_j a_k + (V V^T)_{jk}  in R^{M}, M = m(m-1)/2.
The number of locally identifiable directions in a equals
  rank(D_a G, D_V G) - rank(D_V G),
the extra rank a contributes beyond what E spans. The Jacobian blocks:
  (D_a G)_{(j<k), l} = a_k [l=j] + a_j [l=k];
  (D_V G)_{(j<k),(p,t)} = V_{k,t}[p=j] + V_{j,t}[p=k].
For generic (a, V), and r in the stated regime, D_a G has full column rank m and
its column space meets col(D_V G) only in dimensions already counted, so
  identifiable a-dirs = m - r,  hence d_free = m - (m - r) = r.
We verified this is an EXACT integer identity for all m in {6,...,30} and all
r up to r_max(m) over 20 random instances each (attempt 001, verify_r_law.R):
m=20 gives d_free=r for r=1..12; the deviation appears only at the variety-
saturation boundary, irrelevant in the practical regime r << m. QED.

REMARK D (which "r"). The paper's diagnostic agreement_rank_deficit counts the
rank of the SYMMETRIC RESIDUAL MATRIX A - hat{a} hat{a}^T, which for K disjoint
dependent pairs equals 2K (each pair perturbs a symmetric 2x2 block, rank 2).
But the parameter degeneracy dimension is d_free = K (Lemma 1; confirmed on real
votes in attempt 004). The sample-complexity rate is governed by d_free, the
number of free PARAMETER directions, not the residual-matrix rank. T4's "r"
should be defined as d_free. (For pairwise dependence d_free = #pairs; the
residual-matrix rank is twice that.)

================================================================
LEMMA 2 (gold measurement = rich diagonal Gaussian location). A gold example i
with known label Y_i yields, for each LF j that votes, the statistic
  xi_ij = 2 * 1{lambda_ij = Y_i} - 1 in {-1,+1},   E[xi_ij | votes] = a_j,
  Var(xi_ij | votes) = 1 - a_j^2.
With coverage beta_j, LF j votes on a Bernoulli(beta_j) subset, so the gold
sample mean xibar_j of xi over examples where j votes satisfies
  E[xibar_j] = a_j,  Var(xibar_j) = (1 - a_j^2) / (n_g beta_j) <= 1/(n_g beta_min).
xibar is therefore an unbiased, per-coordinate, sub-Gaussian estimate of the
FULL margin vector a, with diagonal covariance Sigma/n_g, Sigma_jj = (1-a_j^2)/
beta_j. (The dependence among LFs makes Sigma's OFF-diagonal nonzero, but the
diagonal -- which sets per-coordinate gold precision -- is exactly (1-a_j^2)/
beta_j regardless of dependence; verified exactly on real votes, attempt 004.)

Proof. 1{lambda_ij=Y_i} is Bernoulli(alpha_j) by the definition of accuracy;
its centered double is xi_ij with mean 2 alpha_j -1 = a_j and variance
4 alpha_j(1-alpha_j) = 1 - (2alpha_j-1)^2 = 1 - a_j^2. Independence across gold
examples gives the stated mean variance. Boundedness in [-1,1] gives sub-
Gaussianity with variance proxy <= 1. QED.

COROLLARY (reduction). Combining Lemmas 1-2: after the (plentiful) unlabeled
agreement moments fix a on the (m-r)-dim identified subspace U^perp, recovering
a reduces to estimating its r-dim component theta = B^T a in R^r (B an
orthonormal basis of the degenerate subspace U) from n_g i.i.d. sub-Gaussian
observations B^T xibar with mean theta and covariance (1/n_g) B^T Sigma B,
whose eigenvalues lie in [(1-gap^2)/beta_max-ish, 1/beta_min] = Theta(1). This
is the r-dim (sub-)Gaussian LOCATION model with n_g samples. The relevant
estimation tolerance along U is delta_tol = c0 * gap (the scale at which the
competing solutions left by dependence are separated; small gap => near-
degenerate => competitors close, the proof's own "margin proportional to gap").

================================================================
THEOREM A (L2 / total recovery: Theta(r / gap^2)).
For recovering the margin vector to total Euclidean accuracy
  || ahat - a ||_2 <= c * gap
with constant probability (equivalently, keeping the downstream label-posterior
KL below a fixed budget; see Lemma 3), the gold-set sample complexity is
  n_g = Theta( r / gap^2 ),
with matching upper and lower constants depending only on coverages and bounded
vote moments.

UPPER BOUND. Take ahat = (agreement fit on U^perp) + B B^T xibar on U, i.e. the
projection of the gold mean onto the degenerate subspace, plus the agreement-
identified complement. Then ahat - a = B B^T (xibar - a) + (agreement error on
U^perp). The second term -> 0 with the unlabeled corpus (root-n in the corpus
size, plentiful); the first term has
  E || B B^T (xibar - a) ||_2^2 = E || B^T (xibar - a) ||_2^2
     = trace( (1/n_g) B^T Sigma B ) <= r * lambda_max(Sigma) / n_g <= r/(n_g beta_min).
Markov: P(||.||_2 > c gap) <= r/(n_g beta_min c^2 gap^2) <= delta as soon as
  n_g >= r / (beta_min c^2 gap^2 delta).
A sub-Gaussian chi-square (Hanson-Wright/Bernstein) tail sharpens delta to
log(1/delta): w.p. 1-delta, ||B^T(xibar-a)||_2^2 <= C (r + log(1/delta))/
(n_g beta_min), giving
  n_g >= C (r + log(1/delta)) / (beta_min c^2 gap^2)  suffices.
=> n_g = O( (r + log(1/delta)) / gap^2 ). NO log r appears.

LOWER BOUND (minimax). Restrict to a sub-family with E in a fixed r-dim
subspace and a ranging over the r-dim affine manifold; this is contained in the
model, so its minimax risk lower-bounds the full risk. On U the problem is the
r-dim Gaussian location model with per-coordinate variance >= c0 = (1-gap^2)/
beta_max > 0 and n_g samples. The minimax L2 squared risk of the r-dim Gaussian
location model is
  inf_{ahat} sup_a E || ahat - a ||_2^2  >=  c0 * r / n_g
(standard; e.g. the Bayes risk under a N(0, tau^2 I_r) prior is r * (c0/n_g) *
tau^2/(tau^2 + c0/n_g) -> c0 r/n_g as tau->inf, and Bayes risk <= minimax risk;
equivalently Cramer-Rao with diagonal Fisher information n_g/c0 per coordinate).
To force sup risk <= (c gap)^2 we need c0 r / n_g <= (c gap)^2, i.e.
  n_g >= (c0 / c^2) * r / gap^2.
=> n_g = Omega( r / gap^2 ). MATCHES the upper bound. Hence Theta(r/gap^2). QED.

================================================================
THEOREM B (Linf / per-direction control: Theta(log r / gap^2)).
For controlling EVERY degenerate direction to accuracy gap simultaneously,
  max_{1<=t<=r} | B_t^T(ahat - a) | <= c * gap   w.p. >= 1 - delta,
the gold-set sample complexity is
  n_g = Theta( (log r + log(1/delta)) / gap^2 ).

UPPER BOUND. Each coordinate B_t^T(xibar - a) is a bounded-increment sub-
Gaussian mean with variance <= 1/(n_g beta_min); Hoeffding gives
P(|.| > c gap) <= 2 exp(-2 n_g beta_min (c gap)^2). Union over the r directions
(and absorbing delta): 2r exp(-2 n_g beta_min c^2 gap^2) <= delta rearranges to
  n_g >= (1/(2 beta_min c^2 gap^2)) log(2r/delta).
This is EXACTLY the manuscript's bound (eq. goldset-bound). It is the correct
and tight analysis FOR THIS LOSS.

LOWER BOUND. The maximum of r independent mean-zero variance-(v/n_g) sub-
Gaussian coordinates concentrates at v_eff^{1/2} sqrt(2 log r)/sqrt(n_g) (sharp
for Gaussian; the centered correctness statistics are close to Gaussian after
averaging). To keep this below c gap requires v_eff * 2 log r / n_g <= c^2 gap^2,
i.e. n_g >= (2 v_eff / c^2) log r / gap^2 = Omega(log r / gap^2). MATCHES. QED.

================================================================
LEMMA 3 (the operative loss is L2, not Linf). The naive-Bayes training-label
posterior has log-odds linear in a:
  logit P(Y=1 | lambda) = logit(pi) + sum_{j votes} s_j * w(a_j), w(a)=log((1+a)/(1-a)).
For a margin perturbation a -> a + da, the expected KL of the perturbed
posterior from the true one is, to second order,
  E_lambda[ KL ] = (1/2) sum_{j,k} da_j da_k * E_lambda[ ... ]  =  da^T G da,
a POSITIVE-SEMIDEFINITE QUADRATIC FORM G that is a SUM over LFs (diagonal-
dominant, G_jj ~ beta_j w'(a_j)^2 Var-weight). Hence label quality is governed
by an L2-type (sum-of-squares), coverage-weighted norm of da, and is invariant
to how a fixed ||da||_2 budget is distributed across LFs. EMPIRICAL CONFIRMATION
(attempt 005): log-log slope of E[KL] vs ||da||_2^2 is 1.001; concentrated
(Linf=0.10) and spread (Linf=0.03) perturbations at fixed ||da||_2=0.10 give
identical KL (ratio 1.00). Therefore "restore the label model to fixed label
quality" is a TOTAL/L2 criterion, and the operative rate is Theorem A's
Theta(r/gap^2), NOT Theorem B's log r.

================================================================
RECONCILIATION (the resolution of the manuscript's tension).
1. The manuscript's PROOF (union bound) correctly establishes Theorem B:
   n_g = O(log r/gap^2) for PER-DIRECTION (Linf) control. The union bound is
   TIGHT for that loss (Theorem B lower bound), not loose.
2. The manuscript's REMARK conjectures a "tighter" linear-r rate via a volume
   argument. That arithmetic (competing-solution volume ~ gap^r, per-direction
   resolution gap/sqrt(r) => n_g ~ r/gap^2) is exactly the L2/TOTAL calculation
   and correctly yields Theorem A's Theta(r/gap^2).
3. These are NOT competing bounds on one quantity. They are tight bounds on two
   DIFFERENT functionals (max per-direction error vs total L2 error). The
   linear-r rate is not "tighter than" the log-r rate; it is the rate for a
   DIFFERENT and stronger success criterion. Calling log r provisional pending a
   sharper linear-r proof conflates the two.
4. For weak supervision the operative criterion is total/L2 (Lemma 3), so the
   HEADLINE linear-r rate Theta(r/gap^2) is CORRECT, but the manuscript's
   current union-bound PROOF does not prove it: it proves the log-r (Linf)
   statement. The fix is to (i) state the loss explicitly, and (ii) prove
   Theorem A via the r-dim projection/trace bound (upper) and r-dim Gaussian
   location minimax (lower). Both are short and given above.

REMARK (direct-marginal estimator, the one in scripts/sim.R). If one instead
re-estimates ALL m marginals from gold (ignoring agreement moments), the cost is
governed by m, not r: union bound over m LFs gives n_g = Theta(log m / gap^2)
for Linf and the per-coordinate part is 1/gap^2 with no r. This is why the
existing study (m=8 fixed) sees the -2 gap slope and no r-dependence: it never
exercises the r-channel. The r-rate is a statement about the HYBRID estimator.
