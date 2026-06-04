# Logic Checker Report

**Date**: 2026-06-04
**Focus**: Rigorous verification of the rewritten Theorem T4 (gold-set sample
complexity), plus consistency of T1, T2, T3 with the rewrite.

## Headline verdict on T4

The rewritten T4 (`thm:goldset`, `sections/methodology.tex`) is **rigorous and
correct** at the level of a proof sketch appropriate for a conference paper. The
six specific questions posed by the editor are answered below; each load-bearing
claim was checked against the text and four were independently re-derived in R
(`/tmp/t4_independent_check.R`, `/tmp/t4_check2.R`).

### Q1. Is the reduction to an r-dimensional Gaussian-location model valid?
YES. The reduction has two parts, both sound:
- *Gold as a full-vector diagonal measurement* (proof part 1): for a gold
  example with known label, xi_ij = 2*1{vote correct} - 1 has E[xi_ij]=a_j and
  Var=1-a_j^2 because 1{vote correct} ~ Bernoulli(alpha_j) and
  4 alpha(1-alpha) = 1-(2alpha-1)^2. CONFIRMED exactly in simulation (CHECK 2:
  alpha=0.72 gives empirical Var 0.806 vs 1-a^2=0.806). The gold mean is an
  unbiased sub-Gaussian estimate of the WHOLE margin vector with diagonal
  covariance Sigma/n_g, Sigma_jj=(1-a_j^2)/beta_j. Dependence enters only the
  off-diagonal of Sigma; the per-coordinate precision is dependence-free. Correct.
- *Projection onto the r-dim degenerate subspace* (proof part 2): the unlabeled
  agreement moments fix a on the (m-r)-dim identified subspace; gold must supply
  the r-dim component theta = B^T a. The projected problem is the r-dim
  sub-Gaussian location model with covariance (1/n_g) B^T Sigma B, eigenvalues
  Theta(1). Valid.

### Q2. Does the trace bound give the Theta(r/gap^2) UPPER bound for L2?
YES. E||B B^T(xibar - a)||_2^2 = trace((1/n_g) B^T Sigma B) <= r/(n_g beta_min)
(eq:trace-bound). The trace of the projected covariance is the source of the
linear-in-r factor: each of the r degenerate coordinates contributes
Theta(1/n_g). A Hanson-Wright / Bernstein chi-square tail (cited to Wainwright
2019) sharpens to C(r + log(1/delta))/(n_g beta_min); forcing this below
(c_0 gap)^2 gives eq:goldset-bound. No log r appears because the trace bound
targets total L2 directly. CONFIRMED in simulation (CHECK 2C: empirical
E||B^T(xibar-a)||^2 matches trace(B^T Sigma B)/n_g to ~2% and is bounded by
r/n_g for r in {2,8,16}). Correct and tight.

### Q3. Is the Gaussian-location-minimax LOWER bound sound and information-theoretic?
YES. The argument embeds the r-dim Gaussian location model (per-coordinate
variance >= c_0 = (1-gap^2)/beta_max) as a sub-family, so its minimax risk
lower-bounds the full risk. The minimax L2 squared risk of the r-dim Gaussian
location model is >= c_0 r/n_g, justified three independent ways: (i) the Bayes
risk under N(0, tau^2 I_r) tends to c_0 r/n_g as tau -> inf and Bayes <= minimax;
(ii) Cramer-Rao with diagonal Fisher information n_g/c_0 per coordinate (cited to
van der Vaart 1998); (iii) [my own cross-check] Assouad/Le Cam per coordinate.
This binds EVERY estimator, not just the hybrid one, so it is genuinely
information-theoretic, not estimator-specific. CONFIRMED in simulation (CHECK 3:
sample-mean risk = r*v/n_g to <2%, slope of n_g* vs r is exactly 1.000). Correct.

### Q4. Is the claim that downstream KL is an L2 quadratic form correct?
YES. The naive-Bayes posterior log-odds is linear in a (logit pi + sum_j s_j
w(a_j), w(a)=log((1+a)/(1-a))), so a margin perturbation da changes the expected
posterior KL by a PSD quadratic form da^T G da, a coverage-weighted sum over LFs
(`rmk:l2-loss`). Label quality is therefore governed by the L2 margin error and
is invariant to how a fixed ||da||_2 is spread across LFs. CONFIRMED in
simulation (CHECK 4: log-log slope of KL vs ||da||_2^2 is 1.001; concentrated vs
spread perturbations at fixed L2 give KL ratio 1.02). This is the crux
justification for L2 being the operative loss, and it holds. Correct.

### Q5. Is the d_free vs 2*d_free distinction stated correctly and consistently?
YES. `rmk:r-definition` (Remark 6) defines r = d_free as the parameter-degeneracy
dimension and states that the symmetric agreement-residual matrix has rank
2*d_free under pairwise dependence (rank(A - ahat ahat^T) = 2 d_free), so a
practitioner reading r off the residual-matrix rank must halve it. CONFIRMED:
(a) the d_free = r identity via the moment-map Jacobian holds for r in the
practical regime r << m (CHECK 1: exact for m=20 up to r=13, m=30 up to r=21;
the saturation boundary grows as Theta(m), and the manuscript explicitly
restricts to r << m); (b) the residual-matrix rank = 2K = 2 d_free for K disjoint
dependent pairs (CHECK 1D / CHECK 2D: exact for K=1..4). The validation section
(lines 168-171) now states the diagnostic's "effective deficit 6" is the
residual-matrix rank 2 d_free with d_free = 3, one per dependent pair. The
distinction is stated correctly and consistently in the theorem, the remark, the
budgeting procedure (step 3: "halve the count"), and the validation. This was the
conflation flagged in the prior (2026-05-22) review; it is now fixed.

### Q6. Are van der Vaart 1998 and Wainwright 2019 cited for claims they support?
YES. Wainwright 2019 is cited (line 161) for the sub-Gaussian / Hanson-Wright
chi-square tail used in the upper bound; that result is in Wainwright Ch. 2-6.
van der Vaart 1998 is cited (line 179) for the Cramer-Rao / local-asymptotic
minimax lower bound; that is van der Vaart Ch. 8 (and the LAM theorem). Both
attributions are appropriate. APPROPRIATE.

## Consistency of T1, T2, T3 with the T4 rewrite

- **T1 (glass ceiling, `thm:glass-ceiling`)**: SOUND. The accuracy-complement
  symmetry proof is a clean, explicit construction: relabeling y -> 1-y inside
  eq:id-jointvote maps (pi, alpha) to (1-pi, 1-alpha) leaving every joint vote
  probability unchanged. The algebra is correct and verifiable by inspection.
  The binary Z/2 vs multiclass S_K remark is correct. Consistent with T4: T1
  establishes the gold-free obstruction that T4 then prices. No conflict.
- **T2 (CI identifiability, `thm:ci-identifiability`)**: SOUND. The triplet
  identities eq:id-triplet (E[sigma_j sigma_k]=a_j a_k etc.) under conditional
  independence, and the recovery eq:id-solve (a_j^2 = E[s_j s_k]E[s_j s_l]/
  E[s_k s_l]), are the standard FlyingSquid algebra and are correct. Honestly
  framed as a re-derivation. Consistent with T4's r=0 corner (when r=0 no gold is
  needed, recovering T2). No conflict. (See novelty/citation reports for the
  Allman-Matias-Rhodes suggestion.)
- **T3 (agreement consistency, `thm:agreement-consistency`)**: SOUND, and the
  rewrite from the prior review is careful. The exact identity holds only for a
  regular exponential family whose sufficient statistics include the pairwise
  agreement indicators; the theorem explicitly states the standard naive-Bayes
  parametrization does NOT satisfy this and relegates the naive-Bayes case to an
  asymptotic corollary (`cor:agreement-nb`). This is the correct and honest
  scoping of a moment-matching argument. Consistent with T4. No conflict.

## Minor logical blemishes (do not affect correctness)

1. **Symbol overload of c_0** (line 172 vs 181-182). c_0 is used both as the
   per-coordinate variance floor (1-gap^2)/beta_max (line 172) AND as the
   tolerance constant in (c_0 gap)^2 (line 181). The conversion on line 182,
   n_g >= (c_0/c_0^2) r/gap^2, is then written with a single symbol doing two
   jobs; the arithmetic still resolves to Omega(r/gap^2), so the RESULT is
   correct, but the doubled use is confusing. FIX: rename the tolerance constant
   (e.g. c_tol) so the conversion reads n_g >= (var_floor / c_tol^2) r/gap^2.
   Severity: minor.

2. **Eigenvalue interval typo-adjacent** (proof part 2, line 138): the projected
   covariance eigenvalues are stated to lie in
   [(1-gap^2)/beta_max, 1/beta_min] = Theta(1). The lower endpoint should use the
   per-coordinate variance (1-a_j^2) <= 1-gap^2 only if gap = min|a_j| is the
   SMALLEST margin (so 1-gap^2 is the LARGEST variance, an upper not lower bound).
   The interval direction is slightly loose: the floor (1-max_j a_j^2)/beta_max
   is the correct lower endpoint. The conclusion "= Theta(1)" is unaffected
   because both endpoints are Theta(1). Severity: minor (cosmetic; does not
   change the rate).

## Logic-checker confidence

HIGH on the T4 verdict. The proof's structure (Lemma-1 degeneracy reduction,
Lemma-2 gold measurement, trace upper bound, Gaussian-minimax lower bound,
L2-loss justification) is internally complete and every quantitative claim I
could test reproduced. The two blemishes above are presentational, not
mathematical. The proof is a sketch (as labeled) that cites towell2026masked
Sec. 7 for the full regularity apparatus; for a conference venue this is
acceptable, and a self-contained appendix proof would only strengthen it.
