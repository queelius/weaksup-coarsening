# Attempt 001: the measurement geometry of gold labels

GOAL: decide whether gold labels are "rich" measurements (each gold example
yields one scalar per voting LF, ~ m scalars) or "poor" (few scalars per gold
example). This decides r vs log r, because:
  - rich, point-recovery loss => Theta(r/gap^2) plausible (estimate r coords)
  - the union bound over r directions => log r (loose if rich)

## The estimation target

Label model margin vector a in R^m, a_j = 2 alpha_j - 1, gap = min_j |a_j|.
Prior pi recovered from first moments once a known. So target is a.

## Two data channels

CHANNEL 1 (gold-free agreement moments). Observe off-diagonal of
  A = a a^T + E,   rank(E) = r,   (off-diagonal only; diagonal not used).
We do NOT get to see a a^T and E separately; we see their sum on off-diag.

CHANNEL 2 (gold labels). n_g i.i.d. gold examples. On a gold example i with
true label Y_i, for each LF j that votes we observe the Bernoulli indicator
  X_ij = 1{ lambda_ij = Y_i },   E[X_ij] = alpha_j = (1 + a_j)/2.
So gold gives DIRECT unbiased Bernoulli draws of each marginal alpha_j, hence
of each a_j, with per-LF variance alpha_j(1-alpha_j) <= 1/4, attenuated by
coverage beta_j (LF votes on a fraction beta_j of gold examples).

CRITICAL FACT: one gold example yields ONE scalar per VOTING LF. With m LFs
and coverage beta, a gold example yields ~ beta*m independent scalars, one per
LF. Over n_g gold examples, LF j gets ~ n_g*beta_j Bernoulli draws of a_j.

=> Gold is a RICH, COORDINATE-WISE measurement of a. It does NOT measure
"directions of E"; it measures the coordinates a_j directly. Each a_j is its
own independent Bernoulli-mean estimation problem.

## CONSEQUENCE 1: the role of r collapses under direct marginal estimation

If the estimator simply sets a_j = 2*alphahat_j - 1 from gold (the estimator
in fit_label_model_gold), then:
  - Channel 1 (agreement moments, hence E and r) is NOT USED AT ALL.
  - To get every a_j to precision eps with confidence 1-delta, need (union
    over m LFs, Hoeffding):  n_g >= (1/(2 beta_min eps^2)) log(2m/delta).
  - With eps ~ c*gap:  n_g = Theta( log(m) / gap^2 ),  NO r.

This is the rate the sim ACTUALLY exhibits (m=8 fixed, slope -2 in gap).
The "r" in the headline is a category error for this estimator: the cost is
governed by m (number of LFs you must re-measure) and gap, not by rank(E).

## CONSEQUENCE 2: but is full re-measurement necessary? The HYBRID estimator

The remark's intent (and the only way r can be the governing quantity) is a
HYBRID estimator that uses cheap agreement moments for most of a and spends
gold only on the part agreement moments cannot resolve. Question: what is the
dimension of the unresolved part, and does it equal r?

Linear-algebra of the degeneracy. Suppose (idealized) we know the support /
structure of E: dependence couples a known set of LF pairs, and E is supported
on an r-dimensional subspace S of symmetric off-diagonal patterns. The
gold-free equations are: find a and E in S with
  (a a^T + E)_{jk} = A_{jk}^{obs}  for all j != k.
Without knowing E, a is under-determined. HOW under-determined (how many free
real parameters in a given the moments)?  Need to compute the dimension of the
solution manifold {a : exists E in S, a a^T + E matches off-diag A^obs}.

This is the quantity that gold must pin. Call it d_free. If d_free = Theta(r),
the hybrid estimator pays Theta(r/gap^2) (estimate d_free coords). If d_free is
O(1) or grows slower, the story changes.

PLAN: compute d_free as a function of r and the dependence pattern, both
symbolically (Jacobian rank of the moment map) and numerically.

## Why this matters for r vs log r

- The union bound (log r) counts r SCALAR confidence events, each "resolve
  direction k". But resolving r real coordinates to precision gap by direct
  estimation is r independent estimation problems, total cost ~ r * (1/gap^2)
  PER COORDINATE, NOT (1/gap^2)*log r. The union bound's log r is the cost of
  the SIMULTANEOUS confidence, not the cost of the information. Information-
  theoretically, estimating r independent gap-scale coordinates from gold needs
  ~ r/gap^2 TOTAL gold-derived scalars. If each gold example gives O(1) scalars
  toward these coordinates, n_g = Theta(r/gap^2). If each gold example gives
  O(r) relevant scalars (rich), n_g could be as low as Theta((1/gap^2) * (1 +
  (log r)/?)). THE MEASUREMENT RICHNESS PER GOLD EXAMPLE IS DECISIVE.

NEXT: formalize "scalars per gold example toward the degenerate coordinates"
and compute d_free.

## RESULT (Structural Fact 1): d_free = r

Computed the Jacobian rank of the off-diagonal moment map G(a, V) =
off-diag(a a^T + V V^T), where E = V V^T ranges over symmetric off-diagonal
matrices of rank r with UNKNOWN support. The number of free (unidentified)
directions in a left by the agreement moments is:

    a_unident_dim = r   EXACTLY,  for r up to a saturation boundary r_max(m).

Verified across m in {6,8,10,12,16,20,30}, 20 random seeds each, exact integer
match. Boundary r_max(m): 6->2, 8->3, 10->5, 12->6, 16->9, 20->12, 30->12+.
This is the algebraic-variety saturation (rank-r symmetric variety dimension
rm - r(r-1)/2 approaching M = m(m-1)/2); in the realistic regime r << m we are
always in the clean d_free = r regime.

INTERPRETATION. This is the rigorous content of "dependence destroys r
identifying directions" (methodology.tex) and "the r-dimensional space of
competing solutions" (rmk:r-dependence). The KNOWN-support count was 0
(dfree.R); the realistic UNKNOWN-support count is exactly r. So r genuinely is
the right dimension of the thing gold must pin, PROVIDED the estimator is the
HYBRID one (agreement moments + gold), not the direct-marginal one.

CONTRAST WITH DIRECT-MARGINAL ESTIMATOR (sim.R's fit_label_model_gold):
that estimator re-measures all m marginals, so its cost is log(m)/gap^2 and is
independent of r. The paper's headline names r; that is only meaningful for the
HYBRID estimator. So the question "is it r or log r" must be asked of the
hybrid estimator pinning an r-dim family.

NEXT: sample complexity of pinning an r-dim family with gold. Gold provides one
Bernoulli per voting LF per example => a FULL m-vector observation each example
=> a full r-dim observation of the projection onto the degenerate subspace.
This RICHNESS is decisive. Set up as multivariate mean estimation and derive
minimax lower (Fano/packing) and upper (concentration) bounds.
