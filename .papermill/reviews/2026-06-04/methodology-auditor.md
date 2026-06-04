# Methodology Auditor Report

**Date**: 2026-06-04
**Focus**: Statistical rigor of T4, reproducibility of the simulation, and
whether the experimental design supports the claims (cross-verification of the
logic-checker's T4 verdict from the methodology side).

## Cross-verification of T4 (reproducing the reasoning)

Per the editor's routing (logic issues -> methodology-auditor for independent
reproduction), I rebuilt the four load-bearing computations from scratch in R
without sourcing the author's research helpers (`/tmp/t4_independent_check.R`,
`/tmp/t4_check2.R`). All reproduced:

| Claim | Predicted | Reproduced | Verdict |
|-------|-----------|------------|---------|
| Gold per-coord variance | 1 - a_j^2 | 0.806 vs 0.806 (alpha=0.72) | CONFIRMED |
| Minimax L2 risk | r*v/n_g, slope 1 in r | 1.000 slope; risk matches to <2% | CONFIRMED |
| Downstream KL is L2 form | slope 1 in ||da||^2 | 1.001; shape-ratio 1.02 | CONFIRMED |
| d_free = r | for r << m | exact m=20 r<=13, m=30 r<=21 | CONFIRMED |
| residual rank = 2*d_free | 2K for K pairs | exact K=1..4 | CONFIRMED |

The trace upper bound and the Gaussian-minimax lower bound are therefore
methodologically sound, and the lower bound is information-theoretic (it equals
the Bayes-risk envelope and the Cramer-Rao floor, both of which bind every
estimator). I concur with the logic-checker: the rewritten T4 is correct.

## Reproducibility of the paper's own simulation

- Build: `make paper` produces a clean 20-page PDF; only cosmetic bibtex field
  warnings. CONFIRMED.
- The validation section reports `scripts/run.R` with seed 20260521 sourcing
  `scripts/sim.R`, base R only, results in `results.rds`. The repository
  contains `results.rds` and `idealized_results.rds`. I did not re-run the full
  study end to end, but the DGP described (latent-Gaussian-threshold construction
  with a shared factor of weight rho for dependent pairs, marginal-preserving) is
  exactly the construction my independent checks used, and the reported numbers
  are internally consistent with the theory.

## The validation's honesty about what it does and does not test (important)

The validation section is unusually and commendably explicit that the existing
study does NOT exercise the r-channel of T4:

- Lines 171-184 state that the simulation uses the *direct-marginal* estimator
  (re-measure all m marginal accuracies from gold, discard agreement moments),
  whose cost is governed by m, not r (a union over m LFs gives
  Theta(log m / gap^2) with m=8 fixed). The linear-in-r rate Theta(r/gap^2)
  pertains instead to the *hybrid* estimator (agreement moments for the
  identified subspace, gold only for the r degenerate directions).
- The study "fixes the dependence structure and sweeps gap, so it isolates the
  1/gap^2 factor common to both estimators and does not exercise the r-channel."
- An r-sweep with the hybrid estimator is explicitly "deferred to the longer
  manuscript" (towell2026weaksupcoarseningextended).

This is the correct disclosure. It means the simulation confirms TWO of T4's
predictions (gold restores identifiability; cost scales as 1/gap^2, slope -2.04)
and does NOT empirically confirm the THIRD and headline-defining prediction (the
linear-in-r scaling of the operative L2 rate). The linear-r claim rests on the
proof (which I verified) plus the author's own research-directory simulations
(`.research/attempts/003,004`), which are NOT in the paper.

### Finding M1 (MAJOR): the headline linear-in-r rate is unvalidated in-paper.
- **Location**: `sections/validation.tex` lines 171-184; T4 abstract/intro/
  conclusion all foreground Theta(r/gap^2).
- **Problem**: The paper's single new quantitative contribution is the
  linear-in-r dependence, but the in-paper simulation deliberately does not test
  it (it sweeps gap at fixed r with an estimator whose cost is r-independent). A
  referee who reads only the paper sees the 1/gap^2 slope confirmed and the
  linear-r slope asserted. The proof is sound, so this is not a correctness
  problem; it is an evidentiary gap for the headline.
- **Suggestion**: The author already has the r-sweep with a hybrid estimator in
  `.research/attempts/004` (reported n_g/r -> constant, log-log slope -> 1 in r).
  Porting even a single panel of that into `validation.tex` (a figure of n_g vs r
  with slope ~1, alongside the existing gap panel) would close the gap and is
  low-cost. Without it, the paper should soften "confirmed in simulation" near
  the linear-r claim to "confirmed for the gap factor; the r-scaling is
  established by the proof and validated in the extended version."
- **Cross-verified**: by logic-checker (the proof of the r-scaling is correct),
  so this is an evidentiary, not a correctness, finding.

## Statistical-rigor notes

1. **Constants and coverage** (minor). The Theta constants carry a 1/beta_min
   coverage factor and the (1-a_j^2) variance; the proof treats coverage as
   entering only the constant. The marginal-preserving construction
   (`rmk:marginal-dgps`) supports this, but a fully explicit constant as a
   function of the coverage profile is not worked out. Acceptable for a
   conference paper; worth a sentence acknowledging it (the discussion's
   limitations list could add it).

2. **Finite-corpus agreement noise** (minor). The reduction treats the unlabeled
   agreement moments as exact (corpus plentiful), so the gold error is the only
   source. A joint finite-(corpus, gold) analysis would couple two error sources.
   The author's notes expect this to be a lower-order correction; the paper does
   not state the assumption explicitly in T4. FIX: add "with the unlabeled corpus
   large enough that the agreement-identified subspace is fixed" to the theorem
   hypotheses or the proof's first line.

3. **Plug-in r and gap in the budgeting procedure** (minor). The four-step
   budgeting rule (methodology lines 290-310) uses plug-in (rhat, gaphat) from a
   pilot fit. The bound's validity under plug-in error is not analyzed (the pilot
   gap estimate is itself noisy at small gap, exactly the expensive regime). This
   is a practical caveat worth one sentence; it does not affect the theorem.

## Methodology-auditor confidence

HIGH on the T4 proof (independently reproduced). MEDIUM-HIGH on the empirical
package: the simulation is reproducible and honest, but finding M1 (the headline
r-scaling is not tested in-paper) is the main methodological weakness and is
straightforward to fix from material the author already has.
