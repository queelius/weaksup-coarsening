# Methodology Audit

## Simulation design

The base-R simulation (scripts/sim.R, scripts/run.R) implements four studies, one per theorem. Seed 20260521; reproducible. The DGP is documented and well-commented.

### DGP choices

The simulated DGP is a binary classification task with:
- Class prior pi.
- m LFs with per-LF coverage beta_j (independent of label) and accuracy alpha_j.
- Conditional independence in the default case (independent Gaussian scores per LF).
- Pairwise dependence via a shared-latent-factor Gaussian copula: g_j = sqrt(rho) u + sqrt(1-rho) e_j and g_k = sqrt(rho) u + sqrt(1-rho) e_k.

The marginal-preserving property of the Gaussian copula is the key technical feature: each LF retains its accuracy alpha_j exactly, so gold labels still pin LF accuracies directly. This is the right choice for SEPARATING the dependence-induced bias (which T4 quantifies) from accuracy estimation under the gold-augmented estimator (which has standard Bernoulli sample complexity).

CRITICAL FINDING (severity: major). The Gaussian-copula DGP is a specific construction. The Snorkel/data-programming literature standard dependence-DGP choices include:
- Logistic shared-noise.
- Pairwise-conditional-Markov (factor-graph) structure.
- Naive-Bayes with correlated noise.

The paper notes (validation.tex lines 25-30) that "other marginal-preserving dependence mechanisms (e.g., logistic shared-noise) would be expected to give the same scaling." This is an UNDEFENDED CLAIM. The 1/gap^2 scaling is a property of the BOUND, not of the dependence-generating mechanism, as the paper correctly states. But to make this convincing, the paper should either:

(a) Add a brief auxiliary simulation under a SECOND marginal-preserving DGP (e.g., logistic shared noise or a direct E-matrix perturbation) and confirm the slope is robust to the dependence mechanism. This would substantially strengthen the empirical claim. A small auxiliary study (one figure, two paragraphs) would suffice.

(b) Provide a theoretical argument that any marginal-preserving dependence with a fixed pair-correlation gives the same bound. The proof of T4 uses only the marginal accuracy (Bernoulli variance), so the argument is: for any DGP that preserves marginals, the gold-augmented estimator sees the same per-LF Bernoulli draws, so the bound is unchanged. State this explicitly.

Either fix would address the gap. Option (a) is the AISTATS / NeurIPS reviewer's expected response; option (b) is theoretically cleaner.

### Validation of T1 (glass ceiling)

Study 1 (run.R lines 47-145): five conditionally independent LFs, enumerate all 3^5 = 243 vote patterns, compute prob under solution A and solution B, report max |P_A - P_B|. The result is 0 to floating-point precision (run.R line 123 sym_max_diff confirms this). This is a STRONG validation: not asymptotic, not approximate, exactly the symmetry the theorem claims.

NOTE: the L1 fit to empirical is 0.0257 for both solutions, the Monte-Carlo noise of the empirical distribution at n = 200000. This is correctly attributed.

### Validation of T2 (conditional independence)

Study 2 (run.R lines 147-204): n grid from 500 to 50000, 30 replicates per setting. Reports the log-log slope of acc RMSE vs n. Result: -0.53, consistent with the n^{-1/2} rate of a method-of-moments estimator. Recovery accuracy 0.871 matches oracle 0.872.

This is a clean validation. The choice of triplet method (closed-form on agreement moments) is appropriate; the EM alternative would give the same identifiability but with more numerical optimization complexity.

ONE MINOR CONCERN (severity: minor). The "recovery accuracy 0.871 matches the oracle ceiling 0.872" statement is empirically true but should report the variability (replicate IQR or standard error) so the reader can see that the difference is within Monte-Carlo noise. The replicate raw data is available (exp2$raw) but the summary collapses to medians.

### Validation of T3 (agreement consistency)

Study 3 (run.R lines 206-262): n = 500000 with five conditionally independent LFs. Gold-free fit has max agreement residual 3.0e-3; oracle fit has 1.9e-3. Finite-n sweep confirms the residual scales as n^{-1/2}.

GAP (related to logic-checker T3 finding): the simulation validates that the model REPRODUCES empirical pairwise agreement rates at large n. It does not validate the specific sufficient-statistic claim of T3 (which holds only for an extended parametrization). The simulation is consistent with T3 but does not isolate the structural property the theorem asserts.

### Validation of T4 (gold-set sample complexity)

Study 4 (run.R lines 264-454): four sub-studies (4a-4d).
- 4a: gold-free model is biased under dependence (RMSE 0.0058 vs 0.096, a 16x increase). Correct demonstration.
- 4b: gold sweep at fixed dependence rho = 0.5: RMSE falls monotonically from 0.096 to 0.017 at m_gold = 800. Correct demonstration.
- 4c: m_gold required to hit a TARGET RMSE 0.04 grows with dependence strength. Mostly demonstrative.
- 4d: gap scaling. Hold dependence fixed, vary gap, fit log-log slope. Result: -2.04, matching the 1/gap^2 prediction.

CRITICAL CONCERN (severity: major, links to logic-checker T4 critique). The validation confirms the 1/gap^2 part of the bound but NOT the linear-in-r part. The paper acknowledges this (validation.tex lines 162-174):

> The simple gold-augmented estimator used here measures marginal LF accuracies directly, so its budget is governed by the gap term of (5); isolating the linear-in-r factor empirically would require an estimator that also reconstructs the dependence structure, which we leave to the longer manuscript.

This is HONEST but means the headline contribution is HALF-CONFIRMED empirically. The reviewer reading the result will note: "The bound is O(r/gap^2), the simulation confirms the 1/gap^2, the r factor is empirically untouched, and the proof's argument for the r factor is hand-waved." This will land badly without one of the following fixes:

1. Provide the rank-deficit estimator and demonstrate the linear-in-r scaling in a brief auxiliary study.
2. Weaken the bound to O(log r / gap^2) (what the union bound actually delivers) and have both proof and simulation confirm exactly that.
3. Strengthen the proof with the packing/volume argument that produces the linear-in-r factor.

Of these, option 2 is the lowest-effort and the safest for the conference draft. Option 1 is the strongest for a journal version.

### Sub-study 4d (gap scaling) methodological choice

The gap-scaling sub-study (run.R lines 386-426) sets every LF's accuracy to 0.5 + gap/2 so all margins equal gap exactly. This isolates the gap dependence cleanly. The TARGET PRECISION is target_frac * gap = 0.5 * gap, which is a GAP-PROPORTIONAL precision (consistent with the "fraction of gap" tolerance in the proof). The choice is principled.

The fitted log-log slope of -2.04 (run.R line 432) is derived from 5 grid points (gap_grid = 0.10, 0.14, 0.20, 0.28, 0.40). Five points is enough for a slope estimate but the precision is wider than the two-decimal reporting suggests. The paper reports -2.04; a 5-point linear fit typically has slope uncertainty of order 0.1 to 0.2. Reporting "slope -2.04 (95% CI [-2.2, -1.9])" or similar would be more honest. The simulation script does not compute this CI.

Minor finding (severity: minor): report the slope uncertainty.

### Sub-study 4c (m_gold needed scaling with dependence strength)

This sub-study (run.R lines 336-384) tabulates m_gold_needed for varying dep_strength. From the printed run output (state.md): "m_gold needed by dependence strength" varies but a fitted scaling is not extracted. This is presented as descriptive rather than confirmatory. Fine for the conference draft, but the corresponding figure (figures/goldset_complexity.pdf panel B) shows the gap-scaling result, not the dependence-scaling result. The paper says "(B) The number of gold-labeled examples needed scales as 1/gap^2 in the LF accuracy margin" so the figure caption is correct. The dependence-scaling result is in the text but not in a figure.

## Reproducibility

The seed (20260521) and the script structure are clean. The DGP, estimators, and diagnostics are all in scripts/sim.R; the experiment runner is scripts/run.R. The figures script reads results.rds. A reviewer can reproduce the entire validation with a single Rscript invocation.

The base-R-only choice (no dependencies) makes the simulation maximally portable. Good.

## Comparison to Snorkel / FlyingSquid implementations

The paper acknowledges (validation.tex line 176-181) that the head-to-head comparison on WRENCH is "left to the longer manuscript." This is reasonable for a theory paper but a SUBMISSION VENUE LIKE KDD OR VLDB will demand it. For AISTATS / NeurIPS / ICML the absence is acceptable; for the secondary KDD / VLDB targets, the paper would need a real-data study.

The state file's open question is well-posed: "Is a real-data WRENCH study required for top-tier acceptance? The current draft is honest about its absence; reviewers may flag it for empirical venues but theoretical venues may accept the simulation-only validation."

## Summary

- DGP choice (Gaussian copula) is well-motivated but the "other marginal-preserving DGPs would give the same scaling" claim is undefended. Add either an auxiliary simulation or a theoretical argument (major).
- Validation of T1 is exact and convincing.
- Validation of T2 confirms n^{-1/2} consistency.
- Validation of T3 is consistent with the theorem but does not isolate the structural property (linked to logic-checker T3 finding).
- Validation of T4 confirms the 1/gap^2 part but not the linear-in-r part; this is acknowledged but reads as a half-confirmation of the headline contribution (major).
- Slope -2.04 should be reported with uncertainty (minor).
- Seed and reproducibility are clean.
- WRENCH benchmark absent; acceptable for theory venues, required for empirical venues.
