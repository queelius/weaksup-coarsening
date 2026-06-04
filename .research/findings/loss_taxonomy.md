# Lower bound, done carefully. Three losses, three rates.

The reduced problem (attempt 001 + 002): n_g i.i.d. observations
  xi_i = a* + e_i in R^m,  E e_i = 0,  Cov(e_i) = Sigma, Sigma_jj = 1 - a*_j^2,
and a* is known to lie on an affine r-dim manifold M = a0 + U (U = col(B),
B^T B = I_r). Estimate a* (equivalently theta* = B^T(a* - a0) in R^r). The
per-coordinate noise variance is in [1 - gap^2, 1], i.e. Theta(1); WLOG set it
to a constant v in [1/2, 1] for gap <= 1/sqrt(2). Projecting onto U:
  zhat := B^T xibar - B^T a0 ~ approx N(theta*, (1/n_g) B^T Sigma B),
and B^T Sigma B has eigenvalues in [c0, 1], c0 >= 1/2. So this is the
r-dimensional Gaussian location model with n_g samples and noise ~ I_r * Theta(1).
(Sub-Gaussian, not exactly Gaussian, but the Gaussian is the right model for
both the achievable rate and the local-asymptotic minimax lower bound; the
bounded vote vectors are sub-Gaussian with the same variance proxy.)

Call sigma_n^2 = Theta(1/n_g) the per-coordinate variance of zhat.

## The separation scale s := gap

WHY the relevant tolerance scale is gap. Two solutions a, a' on M that differ
by a move along U correspond to different label models. The move that matters
(that changes the qualitative model, e.g. flips an LF from informative to
near-chance, or flips orientation of a near-degenerate direction) has size
proportional to gap, because the degenerate directions are precisely the ones
the agreement moments leave open and those sit at separation ~ gap (the proof's
"competing solutions separated by a margin proportional to gap"; small gap =>
near-degenerate => competitors close). So the estimation tolerance along each
U-direction that constitutes "restored identifiability" is delta_tol = c * gap.

## LOSS 1: total / L2 ("recover the whole r-vector to total norm ~ gap")
Target: || zhat - theta* ||_2 <= s = gap (whole degenerate component correct).

Lower bound (standard r-dim Gaussian location, e.g. Tsybakov Ch.2, or direct
chi-square): for the minimax L2 risk,
  inf sup E||zhat - theta||_2^2 >= c0 * r * sigma_n^2 = Theta(r / n_g).
To force this <= s^2 = gap^2 we need n_g >= Theta(r / gap^2).
Matching upper bound: E||zhat - theta||_2^2 = r sigma_n^2 = Theta(r/n_g) <= gap^2
iff n_g >= Theta(r/gap^2). => Theta(r/gap^2). CLEAN.

## LOSS 2: per-coordinate / Linf ("every direction correct to gap")
Target: || zhat - theta* ||_inf <= s = gap (each coordinate correct).

Upper: union bound over r coords, each Gaussian/Hoeffding:
  P(|zhat_t - theta_t| > gap) <= 2 exp(-gap^2 / (2 sigma_n^2)) = 2 exp(-c n_g gap^2).
Union over r: need 2r exp(-c n_g gap^2) <= delta => n_g >= (1/(c gap^2)) log(2r/delta).
=> n_g = O(log r / gap^2). (THE MANUSCRIPT'S BOUND, exactly.)
Lower: to control the MAX of r coordinates to gap with the SAME failure prob,
the max of r independent N(0, sigma_n^2) is ~ sigma_n sqrt(2 log r); to keep it
below gap need sigma_n sqrt(2 log r) <= gap => sigma_n^2 <= gap^2/(2 log r)
=> n_g >= Theta(log r / gap^2). => Theta(log r / gap^2). CLEAN, and the union
bound is TIGHT here (not loose!). The log r is real for THIS loss.

## LOSS 3: identification / testing ("with prob >= 1-delta pick the right model
among the competing solutions")
This is the natural reading of "the model is identifiable ... with probability
at least 1-delta". Model it as: there is a finite/discrete set of competing
solutions on M (the genuine ambiguities dependence leaves), pairwise separated
by ~ gap along distinct U-directions, and we must select the truth w.p. 1-delta.
If there are N competitors arranged as a 2^r-type hypercube (one binary
ambiguity per degenerate direction, the natural "which side of each degenerate
direction" picture), then:
  - selecting ALL r binary coordinates correctly (Linf-testing) needs each
    test to err w.p. <= delta/r => n_g = Theta(log(r/delta)/gap^2) = log r rate.
  - the FANO bound over the full 2^r hypercube for the joint 0/1 (any-coordinate
    wrong = failure) gives: to have error < 1/2 need n_g * (KL per sample) >~ r,
    i.e. n_g * gap^2 >~ r => n_g = Omega(r/gap^2) for VANISHING joint error.
So even the identification reading splits: per-direction testing => log r;
joint exact identification of all r binary ambiguities => linear r.

## THE UNIFYING STATEMENT

Let k = number of degenerate directions that must be SIMULTANEOUSLY resolved to
fixed total confidence, and let the loss be:
  - SUM of squared errors / total L2 to scale gap  =>  Theta(r / gap^2).
  - JOINT correct resolution of all r binary ambiguities (Hamming-0)  =>
    Theta(r / gap^2)  (Fano over 2^r hypercube; you pay per bit of the r bits).
  - MAX per-direction error to gap with conf 1-delta (Linf)  =>
    Theta((log r + log(1/delta)) / gap^2)  (union bound, TIGHT).

KEY REALIZATION about the manuscript's own two arguments:
  (i) The PROOF's union bound targets Linf with K=r controlled directions and
      gets log r. For the Linf loss this is TIGHT, not loose.
  (ii) The REMARK conjectures linear r via a volume argument; that is the
      correct rate for the TOTAL / Hamming-joint loss. The remark's heuristic
      arithmetic (gap/sqrt(r) per direction, volume gap^r) is the L2/total
      calculation and is CORRECT for that loss.
The two are not in conflict; they bound different functionals. The manuscript
errs only in PRESENTING them as competing bounds on one quantity and in calling
the union-bound rate provisional pending a "tighter" linear-r argument. Linear
r is not tighter; it is a different (and HARDER) success criterion.

## WHICH ONE SHOULD T4 STATE? (decision, to be confirmed by downstream-KL sim)

For weak supervision the deliverable is the training labels P(Y|votes). Their
quality is a SUM over LFs (the log-posterior is sum_j of per-LF log-likelihood
contributions, each linear in a_j up to coverage weights). So the natural,
operationally-correct success criterion is the TOTAL/L2 one: keep
sum_j w_j (ahat_j - a_j)^2 below a fixed budget. Under that criterion:
  n_g = Theta( r / gap^2 ).
=> THE HEADLINE LINEAR-r RATE IS CORRECT, but the CURRENT PROOF does not prove
it (the union bound proves the log r Linf statement, a different and weaker-loss
claim presented as if it were the same). The fix: replace the per-direction
union bound by the r-dim projection (trace) bound for the L2 loss, which gives
linear r directly, AND state the loss explicitly.

Equivalent honest alternative: KEEP the union-bound proof but WEAKEN the stated
loss to per-direction (Linf) control, in which case the correct rate is log r
and the headline should say log r.

The remaining task: confirm by simulation that, for a TOTAL-recovery target,
n_g scales LINEARLY in r (slope 1 in log-log), and for a per-direction target
it scales as log r (slope ~ 0). And confirm slope -2 in gap for both.
EOF
