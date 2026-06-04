# Attempt 002: sample complexity of pinning the r-dim degenerate family

## Reduction to an r-parameter sub-Gaussian sequence model

From Structural Fact 1 (attempt 001): the gold-free agreement moments confine
the margin vector a to an affine r-dimensional manifold M = a* + U, U a fixed
r-dim subspace of R^m (the "competing-solution directions"). Treat the
agreement moments as exact (the identifiability question; finite-n agreement
noise decays at n^{-1/2} in the unlabeled corpus size, which is plentiful, and
is orthogonal to the gold question).

GOLD MEASUREMENT MODEL. A gold example i with label Y_i yields, for each LF j
that votes, X_ij = 1{lambda_ij = Y_i} ~ Bernoulli(alpha_j). Define the centered
vote-vs-truth statistic
  xi_ij = 2 X_ij - 1   in {-1, +1},   E[xi_ij] = 2 alpha_j - 1 = a_j,
  Var(xi_ij) = 4 alpha_j (1 - alpha_j) = 1 - a_j^2 <= 1.
With coverage, LF j is observed on a Bernoulli(beta_j) subset; treat full
coverage beta_j = 1 first (coverage only rescales variance by 1/beta_j and
enters the constant, not the r/gap exponents; see rmk:marginal-dgps).

So each gold example gives a noisy observation of the FULL margin vector:
  xi_i = a + e_i,   E[e_i] = 0,   each coordinate bounded in [-2, 2],
  Cov(e_i) = Sigma,  Sigma_jj = 1 - a_j^2 in [1 - 1, 1] (<=1; = 1 - gap^2 .. 1).
xi_i is a bounded (hence sub-Gaussian) R^m random vector with mean a.

THE TARGET. We must estimate the position of a within M, i.e. recover the
r-dimensional component P_U(a - a0) for a known anchor a0 in M. Equivalently,
estimate theta in R^r where a = a0 + B theta, B an m x r matrix whose columns
are an orthonormal basis of U (B^T B = I_r). The natural estimator:
  thetahat = B^T (xibar - a0),   xibar = (1/n_g) sum_i xi_i,
  ahat = a0 + B thetahat = a0 + B B^T (xibar - a0) = a0 + P_U (xibar - a0).
(Project the empirical margin vector onto the degenerate subspace; the
agreement moments already fix the orthogonal complement.)

This is the projection of an r-dim sub-Gaussian mean. CLASSICAL.

## What does "restore identifiability to fixed accuracy" mean? (the loss)

The bound's exponent in r depends entirely on the loss. Two honest readings:

LOSS L2 (recover the model). Require the recovered margin vector to be correct
in Euclidean norm to a tolerance proportional to gap:
  || ahat - a ||_2 = || P_U(xibar - a) ||_2 <= c * gap.
This is "the label model is recovered to fixed relative accuracy" (each LF
margin good to O(gap) on average; equivalently downstream label posterior good
to a fixed KL). This is the reading that matches "estimate the r competing
coordinates".

LOSS Linf (recover every LF, simultaneously, with high prob). Require every
coordinate good: || ahat - a ||_inf <= c * gap. This is the union-bound reading
("each of r per-direction errors below c1 * gap").

These give DIFFERENT rates. This is the crux of the r vs log r confusion: the
manuscript's PROOF targets Linf-style per-direction control (=> log r via union
bound) while the REMARK's volume heuristic targets an L2-style joint-volume
control (=> linear r). They are answers to two different questions.

## UPPER BOUND (sufficiency)

### L2 loss: n_g = Theta(r / gap^2), NO log.

E || P_U(xibar - a) ||_2^2 = E || B^T (xibar - a) ||_2^2
  = sum_{t=1}^r Var( B_t^T xibar ) = (1/n_g) sum_{t=1}^r B_t^T Sigma B_t
  = (1/n_g) trace(B^T Sigma B) <= (1/n_g) * r * lambda_max(Sigma)
  <= r / n_g     (since Sigma_jj <= 1 and Sigma is a covariance of a bounded
                  vector; lambda_max(Sigma) <= ||Sigma||_op; for the diagonal-
                  dominant gold covariance lambda_max <= max_j sum_k |Sigma_jk|;
                  under conditional independence of gold draws given Y the gold
                  covariance is diag(1 - a_j^2) EXACTLY, so lambda_max <= 1).
By Markov, P( ||P_U(xibar - a)||_2 > c gap ) <= E||.||^2 / (c gap)^2
  <= r / (n_g c^2 gap^2). Setting this <= delta gives
      n_g >= r / (c^2 gap^2 delta).            (Markov; loose in delta)
A sub-Gaussian / chi-square concentration tightens delta to log(1/delta):
the projected error B^T(xibar - a) is a sum of n_g i.i.d. bounded r-vectors;
by a Hanson-Wright / Bernstein bound for the squared norm of an r-dim
sub-Gaussian average,
  P( ||P_U(xibar - a)||_2^2 > (1/n_g)(trace(B^T Sigma B) + 2 sqrt(t * ||.||_F^2)
        + 2 t ||.||_op) ) <= e^{-t}
giving, for ||P_U(xibar-a)||_2^2 <= C (r + log(1/delta)) / n_g w.p. 1 - delta.
Hence
  n_g >= C (r + log(1/delta)) / (c^2 gap^2)   suffices for L2 loss.    (*)
=> n_g = O( (r + log(1/delta)) / gap^2 ). The r enters LINEARLY; there is NO
log r. The log is only in 1/delta (the confidence), not in r.

### Linf loss: n_g = O( (log r' ) / gap^2 ) where r' = number of coordinates
to control. If we instead demand max-coordinate control over the r relevant
directions (or over all m LFs), each coordinate is a bounded mean, Hoeffding +
union bound over the number of controlled coordinates K gives
  n_g >= (1/(2 gap^2)) log(2K / delta),  K = m (all LFs) or K = r (directions).
=> n_g = O( log(K) / gap^2 ). THIS is the union-bound rate. With K = r it is
the manuscript's log r; with K = m it is log m (the direct-marginal estimator).

## LOWER BOUND (necessity)

### L2 loss: n_g = Omega(r / gap^2).  (matches the upper bound => Theta)

Information-theoretic / Fano + Assouad. We must distinguish points on the
r-dim manifold separated by gap-scale moves. Consider the r-dim sub-Gaussian
sequence model: observe n_g i.i.d. xi_i = a0 + B theta + e_i with theta in R^r,
per-coordinate noise variance v in [1 - gap^2 .. 1] (>= 1/2 for gap <= 1/sqrt2;
use v >= c0 > 0). Restricting to U-coordinates this is EXACTLY the r-dim
Gaussian-mean (location) model with n_g samples and noise covariance >= c0 I_r.

Assouad's lemma / the standard r-dim Gaussian location minimax bound: the
minimax L2 squared risk is
  inf_est sup_theta E || thetahat - theta ||_2^2  >=  c0' * r / n_g.
(Each of the r orthogonal directions is an independent 1-d location problem
with Fisher information n_g / v per coordinate; Cramer-Rao / van Trees gives
per-coordinate risk >= v / n_g, summing to r v / n_g.) To achieve
sup risk <= (c gap)^2 we therefore NEED
  c0' r / n_g <= (c gap)^2   =>   n_g >= (c0'/c^2) * r / gap^2.        (**)
=> n_g = Omega( r / gap^2 ) for L2 recovery to accuracy ~ gap. MATCHES (*).

Why the gap^2 and the r both appear and are tight: r independent location
coordinates, each must be pinned to absolute precision O(gap) (because the
competing solutions are separated by O(gap) per direction), each costs
Omega(1/gap^2) samples-worth of information, and the n_g samples supply
n_g units of information PER coordinate (rich measurement), so to give every
one of r coordinates Omega(1/gap^2) information you need... wait: rich
measurement gives n_g info to EACH coordinate simultaneously. Resolve this
carefully below; this is the subtle point.

### THE SUBTLE POINT: richness vs the r factor. Why is it still linear in r?

Each gold example gives ONE scalar per coordinate (one Bernoulli per LF), so
after n_g examples EACH coordinate has n_g Bernoulli draws => per-coordinate
variance v/n_g. To pin ONE coordinate to O(gap): need v/n_g <= gap^2, i.e.
n_g >= v/gap^2, INDEPENDENT of r. So for L2 with a FIXED per-coordinate
tolerance gap, richness wins and n_g = O(1/gap^2) suffices for the WHOLE
vector?? Let's check against (*): (*) said r/gap^2.

The resolution is the LOSS NORMALIZATION. Two inequivalent "accuracy ~ gap"
targets:
  (T-per) per-coordinate: |ahat_t - a_t| <= gap for the average/each coordinate.
          Then total L2^2 tolerance is r * gap^2, and n_g = O(1/gap^2) suffices
          (richness), with a log r only if you want the MAX coordinate (Linf).
  (T-tot) total: ||ahat - a||_2 <= gap (the WHOLE r-vector within gap). Then
          per-coordinate tolerance is gap/sqrt(r), and n_g = O(r/gap^2).

THIS IS EXACTLY THE REMARK'S CONFUSION, now made precise:
  rmk:r-dependence says "per-direction resolution gap/sqrt(r) suffices to
  separate a volume of size gap^r", giving n_g ~ r/gap^2. That is target
  (T-tot): controlling the JOINT r-vector to total norm gap forces each
  coordinate to gap/sqrt(r), costing (1/(gap/sqrt r)^2) = r/gap^2. CORRECT
  ARITHMETIC, but it is the answer to (T-tot), i.e. to requiring the whole
  model vector correct to total Euclidean norm gap, NOT to requiring each LF
  correct to gap.

So BOTH the remark and the union-bound proof are internally correct; they
answer different questions:
  - Union-bound proof, target (T-per)/Linf, K=r controlled directions:
        n_g = Theta( log r / gap^2 ).
  - Remark volume argument, target (T-tot) total-norm gap:
        n_g = Theta( r / gap^2 ).
They are NOT competing bounds on the same quantity; they are tight bounds on
two different quantities. The "conflict" dissolves once the loss is fixed.

## WHICH LOSS IS THE RIGHT ONE FOR "RESTORE IDENTIFIABILITY"?

Identifiability is qualitative (a equals a, full stop). "Restore identifiability
to fixed accuracy / consistent plug-in" is a statistical statement and needs a
loss. The operationally meaningful target for weak supervision is the
downstream training-label quality, i.e. the posterior P(Y | votes). That
posterior's error is controlled by the L2 (or weighted L2) error of a, NOT by
the worst single coordinate and NOT by an arbitrary total-norm-gap convention.
Concretely the log-odds of the naive-Bayes posterior is linear in a, so the KL
between the estimated and true posterior is ~ ||ahat - a||_2^2 (weighted by LF
coverages and vote frequencies). To keep the posterior KL below a FIXED
constant epsilon^2, the requirement is
  ||ahat - a||_2^2 <= epsilon^2  (a TOTAL-norm target, NOT per-coordinate),
which is target (T-tot)-like and gives n_g = Theta(r / gap^2 * (epsilon-scaling)).

BUT here the gap enters through HOW the competing solutions sit: the degenerate
directions are separated such that moving distance ~ gap along U flips the
model meaningfully; so the natural tolerance along U scales with gap, and the
total-norm target with tolerance ~ gap gives n_g = Theta(r/gap^2).

CONCLUSION (to be stress-tested by simulation): For recovering the label model
(the r-dim degenerate component) to a FIXED total accuracy on the natural gap
scale, the sample complexity is Theta(r / gap^2). The linear-in-r factor is
CORRECT for total/L2 recovery; the log r of the union bound is correct only for
the weaker per-direction/Linf control and is an artifact of the loss, not a
fundamental rate for restoring the model. Equivalently: the union bound is not
loose as a bound on what it bounds (max per-direction error), but it bounds the
wrong quantity for "restore the model".

NEXT: pressure-test with simulation. Vary r and gap INDEPENDENTLY, with the
HYBRID estimator and a TOTAL-norm (L2) recovery target, and fit exponents.
Predict: slope +1 in r (log-log), slope -2 in gap. Also test the Linf target;
predict slope ~ 0 (log r, i.e. nearly flat / very weak) in r.
