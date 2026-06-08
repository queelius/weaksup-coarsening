# Logic Checker Report

**Paper**: Programmatic weak supervision as masked-cause inference
**Date**: 2026-06-08
**Confidence**: HIGH (load-bearing claims re-derived numerically; proofs read line by line)

## Scope

Four theorems plus one corollary: T1 glass ceiling (`thm:glass-ceiling`), T2
conditional-independence identifiability (`thm:ci-identifiability`), T3 agreement
consistency (`thm:agreement-consistency`) with `cor:agreement-nb`, and T4 gold-set
sample complexity (`thm:goldset`). Background `thm:bg-id` is imported from
`towell2026masked` and used as a black box; its internal proof is out of scope.

## T1 glass ceiling: CORRECT, and the witness is exact

The accuracy-complement symmetry proof (`sections/identifiability.tex` 28-65) is
a clean relabeling argument: applying y -> 1-y inside the marginal-over-Y sum
\eqref{eq:id-jointvote} sends pi -> 1-pi and each alpha_j -> 1-alpha_j while
leaving coverage factors untouched, so (pi, alpha) and (1-pi, 1-alpha) are
observationally indistinguishable for every vote pattern.

**Independent numerical confirmation.** I enumerated all 3^5 = 243 vote patterns
for the validation DGP (alpha = (0.85,0.78,0.72,0.68,0.90), beta = 0.7, pi = 0.4)
and computed max|P_A(lambda) - P_B(lambda)| under solution A = (pi, alpha) and
solution B = (1-pi, 1-alpha): the result is **0.000e+00**, exactly zero, with
sum P_A = 1.000000. The "exactly zero (not small)" claim in T1 and in
`validation.tex` is verified. The Z/2 -> S_K multiclass generalization remark
(line 56-60) is the correct group-theoretic statement of the obstruction.

## T2 conditional-independence identifiability: CORRECT as a re-derivation

The sigma-encoding moment structure \eqref{eq:id-triplet}, E[sigma_j sigma_k] =
a_j a_k and E[sigma_j sigma_k sigma_l] = a_j a_k a_l, and the solve
\eqref{eq:id-solve}, a_j^2 = E[s_j s_k]E[s_j s_l]/E[s_k s_l], are the standard
triplet identities (Fu 2020), correctly stated. The triple product fixes the
common sign; the fixed-orientation assumption selects a_j > 0; the first moment
E[sigma_j] = a_j(2 pi - 1) then identifies pi; non-degeneracy keeps denominators
nonzero. All steps hold. The theorem is correctly framed as a re-derivation, not
a new claim. (See citation-verifier for the Allman-Matias-Rhodes foundational
attribution that should sit behind these identities.)

## T3 agreement consistency: CORRECT, and the seam is handled honestly

This is the paper's most delicate logical point and it is stated correctly. The
exponential-family moment-matching identity E_{theta-hat}[T] = T-bar holds for
any sufficient statistic T at an interior MLE; specializing T to the pairwise
agreement indicator gives \eqref{eq:agreement}. The theorem hypothesis explicitly
requires a parametrization whose sufficient statistics *include* pairwise
agreement indicators, and the text correctly notes (lines 161-166, 197-201) that
the standard naive-Bayes parametrization of data programming does **not** satisfy
this, providing `cor:agreement-nb` for the asymptotic n^{-1/2} naive-Bayes version
instead. This is exactly the synthesis "seam": the regime-(A) consistency identity
is exact only under a sufficiency-complete parametrization and asymptotic for the
naive-Bayes label model. The paper does not overclaim T3 as exact for naive-Bayes;
the distinction is drawn precisely. The `cor:agreement-nb` population formula
P{lambda_j = lambda_k} = alpha_j alpha_k + (1-alpha_j)(1-alpha_k) is correct
(numerically verified: empirical 0.64365 vs formula 0.64400 at alpha=(0.80,0.74),
difference 3.5e-4 Monte-Carlo noise).

## T4 gold-set sample complexity: CORRECT (re-verified; consistent with prior pass)

All load-bearing sub-claims hold:
- **Gold is a full-vector diagonal measurement**: xi_ij = 2*1{lambda_ij=Y_i}-1
  has mean a_j and variance 1-a_j^2 (since 4 alpha(1-alpha) = 1-(2alpha-1)^2);
  diagonal covariance Sigma/n_g with Sigma_jj = (1-a_j^2)/beta_j. Correct.
- **Reduction to r-dim Gaussian location**: agreement moments fix the (m-r)-dim
  identified subspace; gold supplies the r-dim degenerate component. Valid.
- **Upper bound (trace, linear in r)**: E||BB^T(xibar-a)||^2 = trace((1/n_g)
  B^T Sigma B) <= r/(n_g beta_min); Hanson-Wright tail sharpens to C(r +
  log(1/delta))/(n_g beta_min); no log r because the trace targets total L2
  directly. Correct, and this is the crux of the linear-in-r rate.
- **Lower bound (Gaussian-location minimax)**: minimax L2 risk >= c_0 r/n_g via
  the isotropic-prior Bayes envelope / Cramer-Rao floor; information-theoretic,
  binds every estimator. Correct.
- **KL = L2 quadratic form (`rmk:l2-loss`)**: logit posterior is linear in a, so
  a margin perturbation changes expected KL by a PSD quadratic form. **Numerically
  verified**: KL(t)/t^2 is constant to ratio 1.003 over t in {0.005..0.04},
  confirming the operative loss is L2. This justifies T4's success criterion.
- **`rmk:r-dependence` loss taxonomy**: L2 -> r/gap^2, Linf -> log r/gap^2 (union
  bound tight, matching max-of-r lower bound ~ sqrt(2 log r)), per-coord RMS ->
  1/gap^2. The three rates are for three losses, correctly stated as not competing.
- **`rmk:r-definition`**: rank(A - a-hat a-hat^T) = 2 d_free under pairwise
  dependence (2x2 block per pair), so r = d_free is half the residual-matrix rank.
  Correct and matches the simulation (deficit 6, d_free = 3).

## Blemishes (do not affect correctness)

### L1. c_0 symbol overload in the T4 proof (PERSISTS from prior review m1)
`sections/methodology.tex`: c_0 is the success-tolerance constant at lines 91,
102 (||a-hat - a|| <= c_0 gap), then **redefined** at line 172 as the
per-coordinate variance floor c_0 = (1-gap^2)/beta_max. The lower-bound
conversion at line 182, n_g >= (c_0/c_0^2) r/gap^2, has one symbol in two roles.
The arithmetic resolves to Omega(r/gap^2) regardless (variance-floor over
tolerance-squared), so the result is correct, but the expression "(c_0/c_0^2)" is
confusing on its face. **Fix**: rename the tolerance constant (e.g. c_tol) so the
conversion reads n_g >= (var_floor / c_tol^2) r/gap^2. Low effort, flagged twice
now.

### L2. Projected-covariance eigenvalue lower endpoint loosely stated (PERSISTS from prior m3)
Line 138 gives the eigenvalue interval lower endpoint as (1-gap^2)/beta_max. The
quantity (1-gap^2) is the *smallest-margin* (largest) per-coordinate variance, so
it belongs at the *upper* end of the per-coordinate variance range, not the lower
floor; the tight floor is (1 - max_j a_j^2)/beta_max. The conclusion "= Theta(1)"
is unaffected (both endpoints are Theta(1)). **Fix**: state the floor as
(1 - max_j a_j^2)/beta_max.

## Verdict

No critical logic issues. All four theorems and the corollary are correct at the
level of a conference proof sketch; the two genuinely-new pieces (the linear-in-r
L2 upper bound and the information-theoretic lower bound) are sound and were
re-derived. The only logic-side defects are the two persisting cosmetic blemishes
above (symbol overload, loose eigenvalue endpoint), neither of which changes any
stated rate. T3's exactness seam is handled with exemplary honesty.
