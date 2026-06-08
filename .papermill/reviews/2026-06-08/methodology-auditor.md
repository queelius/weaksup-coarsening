# Methodology Auditor Report

**Paper**: Programmatic weak supervision as masked-cause inference
**Date**: 2026-06-08
**Confidence**: HIGH (full simulation re-run; every headline number reproduced)

## Reproducibility: EXCELLENT

The validation pipeline is fully reproducible. `results.rds` (seed 20260521) was
read back and every number quoted in `sections/validation.tex` matches to the
stated precision:

| Claim (validation.tex) | Paper value | Reproduced from results.rds |
|---|---|---|
| T2 RMSE log-log slope | -0.53 | **-0.528** |
| T2 RMSE @ n=500 / @ n=50k | 0.046 / 0.0044 | 0.0457 / 0.00436 |
| T2 gold-free recovery vs oracle | 0.871 vs 0.872 | 0.871 vs 0.8721 |
| T3 agreement resid max / median @ 5e5 | 3.0e-3 / 1.9e-4 | 3.01e-3 / 1.87e-4 |
| T3 oracle resid max | 1.9e-3 | 1.91e-3 |
| T4 gold-free RMSE indep / dep(rho=0.5) | 0.0058 / 0.096 | 0.0058 / 0.0958 |
| T4 rank deficit indep / dep | 0 / 6 | 0 / 6 |
| T4 gold sweep 0/100/200/800 | 0.096/0.048/0.036/0.017 | 0.096/0.0479/0.0356/0.0174 |
| T4 gap-scaling 0.10..0.40 | 140/70/35/18/8 | 140/70/35/18/8 |
| T4 gap log-log slope | -2.04 | **-2.0438** |

No discrepancy found. The DGP (latent-Gaussian-quantile correctness with a shared
latent factor for dependent pairs) is marginal-preserving as claimed, and the
three estimators (gold-free triplet, gold-augmented direct-marginal, oracle) are
the right comparison set. T1's exact symmetry was also reproduced independently
(243-pattern enumeration, max difference exactly 0).

## M1 (carried, now reducible to a CHOICE): the headline linear-in-r rate is still not in the paper, but the closing evidence already exists in-repo and reproduces

This is the single most important methodological item and it is the same one the
prior (2026-06-04) review raised as Major M1. The status has changed in an
important way.

**The gap.** The paper's one genuinely-new quantitative contribution is the
**linear-in-r** L2 rate Theta(r/gap^2). The in-paper simulation
(`exp4_goldset_complexity`) uses the *direct-marginal* estimator, which re-measures
all m LF marginals from gold and discards agreement moments, so its cost is
governed by gap (and a union over m), **not by r**. The paper is admirably explicit
about this: `validation.tex` 180-184 states the study "does not exercise the
r-channel" and defers an r-sweep to the longer manuscript, and `methodology.tex`
318-323 says the linear-in-r rate "is proved here but not yet validated by an
r-sweep." So the headline contribution rests, in-paper, on the proof alone; the
simulation confirms only two of T4's three predictions (gold restores
identifiability; cost ~ 1/gap^2).

**What is new since the prior review.** The r-sweep is not merely "material the
author has" in the abstract; it is a complete, runnable study sitting in
`.research/attempts/003-rsweep-idealized/idealized2.R`. I executed it. It sweeps
r in {1,...,64} at fixed gap = 0.20 and m = 80 and reports, for the three losses:

- **L2 total (the operative criterion)**: n_g rises 10 -> 1631 across r=1..64;
  fitted log-log slope vs r = **1.172** (predicted +1); the theory line
  n_g ~ r*v/gap^2 = 24*r tracks the data (e.g. r=8 -> measured 183 vs predicted
  192). This is direct empirical confirmation of the linear-in-r L2 rate.
- **Linf**: fits ng = 1.96 + 37.9*log(r), R^2 = 0.986, beating a power-law fit
  (R^2 = 0.917): confirms the Theta(log r/gap^2) prediction of `rmk:r-dependence`.
- **per-coord RMS**: slope 0.121 ~ 0: confirms the r-independent Theta(1/gap^2).

So all three loss-dependent rates that `rmk:r-dependence` predicts reproduce in a
script the author already wrote. The headline contribution's missing empirical leg
is one figure-port away from being closed.

**Suggestion (unchanged in substance, sharpened in cost).** Port one panel of
`idealized2.R` into `validation.tex` as a figure of n_g vs r at fixed gap, with
the L2/Linf/RMS curves overlaid (the figure already separates them cleanly). This
converts the headline from "proved, validated elsewhere" to "proved and validated
here," which materially strengthens the paper at near-zero cost. The slope is 1.17
not exactly 1.00 over this finite grid (small-r curvature and the median-threshold
discretization inflate it slightly); a short caption note or a fit restricted to
r >= 4 would present it honestly.

**A second-order concern about the deferral target.** The r-sweep is deferred four
times to `towell2026weaksupcoarseningextended`, a bib entry typed "Manuscript in
preparation (extended version of the present paper)" with no DOI and no repository
on disk. Deferring the empirical confirmation of the *headline* result to a
not-yet-existent paper, when the confirming script is in this repo, is a weak
posture for a referee. Porting the panel removes the dependence on a phantom
citation for the load-bearing claim.

## Minor methodological items

### m-meth-1. Finite-corpus agreement noise not stated as a T4 hypothesis (PERSISTS from prior m4)
The T4 reduction treats the unlabeled agreement moments as exact (the identified
subspace is fixed), so gold error is the only modeled source. A joint
finite-(corpus, gold) analysis would couple two error sources; expected
lower-order but the assumption is implicit. **Fix**: add "with the unlabeled
corpus large enough that the agreement-identified subspace is fixed" to the
theorem hypotheses. The validation never stresses this (corpora are large), so it
is a statement-completeness issue, not a result-validity one.

### m-meth-2. Plug-in (r, gap) in the budgeting procedure is unanalyzed (PERSISTS, prior suggestion 1)
The four-step budgeting rule (`methodology.tex` 290-310) plugs pilot estimates
(r-hat, gap-hat) into the bound, but the bound's validity under noisy pilots is
not analyzed, and the pilot gap estimate is noisiest exactly in the expensive
small-gap regime where the budget is most sensitive. One caveat sentence would
suffice. The simulation does not exercise the plug-in loop (it uses the true
structure), so this is honest-incompleteness rather than an overclaim.

### m-meth-3. Theta constants carry an un-worked 1/beta_min factor
The Theta(r/gap^2) constants depend on the minimum coverage beta_min (Sigma_jj <=
1/beta_min). This is acknowledged in the proof but not surfaced in the
interpretation or limitations. A one-line acknowledgment in the discussion would
close it.

## Verdict

The simulation is rigorous, fully reproducible, and faithfully reported, with
honest scoping of what each study does and does not exercise. The methodology has
no correctness defect. The one substantive item is evidentiary: port the
already-written, already-reproducing r-sweep panel to validate the headline
linear-in-r rate in-paper rather than deferring it to a manuscript that does not
yet exist.
