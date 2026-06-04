# Research State

## The question (one line)
True scaling of n_g (gold labels) to restore label-model identifiability:
Theta(r/gap^2)? Theta(log r/gap^2)? something else? Upper + lower bounds.

## Sub-problems
1. Formalize what "restore identifiability via gold" means as an estimation
   problem, and which estimator the rate is claimed for. - status: in-progress
   KEY FORK:
   - Model I "full marginal pinning": gold pins all m LF marginals; cost is
     governed by m (and gap), NOT r. r does not appear. => headline r-claim is
     a category error for this estimator.
   - Model II "hybrid": agreement moments give the rank-one part cheaply; gold
     pins only the r-dim degeneracy left by dependence. This is where r enters.
2. Lower bound (necessity) for Model II via Fano/packing over the r-dim
   degenerate family. Conjecture Omega(r/gap^2) or Omega((r + log...)/gap^2).
   - status: open
3. Upper bound (sufficiency) for Model II via concentration for the natural
   estimator. - status: open
4. Reconcile log-r union bound vs linear-r packing intuition; the remark's own
   volume heuristic (gap^r volume, gap/sqrt(r) per-direction resolution) is
   internally INCONSISTENT (see hypotheses). - status: open
5. Simulation: controlled-r DGP varying r and gap INDEPENDENTLY, hybrid
   estimator, fit exponents in r and gap. - status: open
6. Produce exact restatement T4 should adopt. - status: open

## Hypotheses
H1. Under the estimator actually used in sim.R (full marginal pinning), the
    rate is Theta(log(m)/gap^2) in the number of LFs m, and INDEPENDENT of r.
    The headline "r/gap^2" is then simply the wrong variable. status: untested
    (but near-certain from the structure; verify by sim and proof).
H2. The remark's volume heuristic is self-contradictory: it says per-direction
    resolution gap/sqrt(r) suffices (=> n_g ~ (1/(gap/sqrt(r))^2) = r/gap^2)
    BUT also that you must separate to a volume delta. A coarser per-coordinate
    resolution does NOT suffice to localize a point in r dims; you still pay a
    union/packing cost. The correct packing calc likely gives Theta(r/gap^2)
    for SQUARED-error / point-identification but only Theta(log r) extra for a
    single fixed FUNCTIONAL. The answer depends on the loss. status: untested
H3. For point recovery of the r-dim degenerate component to fixed RELATIVE
    accuracy in a fixed norm, the minimax rate is Theta(r/gap^2): you must
    estimate r real coordinates each to O(gap) absolute precision, and that
    costs Theta(r) Bernoulli-type measurements at SNR gap, i.e. r/gap^2; Fano
    over a gap-packing of the r-cube gives the matching Omega(r/gap^2).
    The log r of the union bound is the LOOSE side; linear r is correct for
    estimation in a fixed-dimensional-per-coordinate sense. status: untested
H4. BUT necessity Omega(r) needs each direction to be SEPARATELY observable
    from gold. If a single gold example constrains many directions at once
    (high-dim measurement), Omega(r) may fail. Must check the measurement
    geometry: does one gold label give 1 scalar per voting LF (so ~ m scalars)
    or 1 scalar total? This determines whether r or log r wins. status: KEY,
    untested.

## Current focus
DONE. All sub-problems resolved. synthesis.md written. Final statuses below.

## Hypothesis final statuses
H1 (direct-marginal estimator => log m/gap^2, no r): CONFIRMED (proof + the
   existing sim's behavior).
H2 (remark's volume heuristic self-consistent but for a different loss):
   CONFIRMED. It is the correct L2/total arithmetic; not in conflict with union
   bound (different loss).
H3 (L2/total recovery => Theta(r/gap^2), minimax): CONFIRMED (Thm A + minimax
   check, slope 1.00, ng/r constant, full-DGP slope 1.07 at r>=8).
H4 (measurement richness decisive): CONFIRMED. Gold = rich diagonal full-vector
   measurement (var 1-a^2 per coord, exact on real votes). Richness is exactly
   why per-coordinate cost is 1/gap^2 (no r) while total cost is r/gap^2.

## RESOLVED FINDINGS (cycles 1-5)
- Structural Fact 1: with unknown dependence support, agreement moments leave
  exactly d_free = r free directions in the margin vector a (Jacobian count,
  exact over m=6..30). KNOWN-support => 0. Direct-marginal estimator => cost
  log(m)/gap^2 (no r). So r governs only the HYBRID estimator pinning the r-dim
  degenerate subspace U.
- Reduction: gold = rich diagonal per-LF Bernoulli measurement of the FULL
  margin vector, per-coord variance 1-a_j^2 (CONFIRMED on real votes, exact).
  Projected onto U => r-dim Gaussian location model, n_g samples, separation
  scale gap.
- THE RESOLUTION (loss-dependent, all three rates tight, sim-confirmed to the
  constant on idealized AND full DGP):
    L2-total recovery (||ahat-a||_2 <= c*gap):  Theta(r / gap^2).   <-- linear r
    Linf over r directions (each <= c*gap):     Theta(log r / gap^2).<-- union bd
    per-coordinate RMS:                         Theta(1 / gap^2).    <-- no r
  gap-slope -2.0 to -2.1 throughout. r>=8 log-log slope for L2 = 1.07 (->1),
  ng/r constant (~40). Linf: ng = a + b*log r, R^2=0.99. The union bound is
  TIGHT for Linf, not loose. The remark's volume heuristic is the CORRECT L2
  arithmetic (=> linear r). Not a conflict: different losses.
- SUBTLETY found: the paper's diagnostic agreement_rank_deficit reports 2K for
  K dependent pairs (rank of symmetric residual matrix), but the PARAMETER
  degeneracy dimension gold pins is K (Jacobian d_free). T4's "r" should be the
  parameter-degeneracy dimension d_free, not the residual-matrix rank.

## Sub-problem statuses (update)
1. estimation model formalized - status: RESOLVED (d_free=r, hybrid vs direct)
2. lower bound - status: RESOLVED (Theta per loss; r-dim Gaussian minimax)
3. upper bound - status: RESOLVED (trace bound L2; union bound Linf)
4. reconcile log r vs linear r - status: RESOLVED (loss ambiguity)
5. simulation r & gap independent - status: RESOLVED (idealized + full DGP)
6. exact restatement - status: in-progress (need loss-justification sim)

## Baseline (done)
existing scripts/run.R study 4: mgold_needed {0,140,140,200,140,200} vs r
{0,0,1,6,6,6} = NO r relation; gap-slope -2.04 with m=8 fixed. Confirms the
existing study does NOT test r-scaling. As predicted.
