# Research Log

## Goal
Settle the true scaling of gold-set sample complexity in T4 (thm:goldset):
is it Theta(r/gap^2), Theta(log r/gap^2), or something else? Upper bound
(sufficiency), lower bound (necessity), reconcile, restate T4.

## Eval
Self-evaluation. No external eval script. Success = matching bounds + proof,
or evidenced rate + one-sided rigorous bound + honest open statement.

---

### Cycle 0 (2026-06-03) DECOMPOSE + read source
**Phase:** DECOMPOSE
**Activity:** Read the exact statements: methodology.tex (thm:goldset, its
proof sketch, rmk:r-dependence, rmk:marginal-dgps), identifiability.tex (T1
glass ceiling, T2 CI identifiability, T3 agreement consistency), background.tex
(thm:bg-id: identifiable iff augmented candidate-set matrix full column rank),
validation.tex (the 4 studies), and scripts/sim.R + scripts/run.R.

**Key structural observations:**

1. The model. A = a a^T + E, off-diagonal, A_jk = E[sigma_j sigma_k] centered
   pairwise agreements, sigma_j = 2*1{lambda_j=1}-1 in {-1,+1}. Under CI the
   off-diagonal of A is rank one (outer product of margin vector a, a_j =
   2*alpha_j - 1). Dependence adds E with rank(E) = r. gap = min_j |a_j|.

2. Gold labels. A gold example is a singleton: it directly observes
   1{lambda_ij != Y_i}, an unbiased Bernoulli(1 - alpha_j) for each voting LF.
   So gold labels estimate the MARGINAL accuracies alpha_j directly,
   independent of dependence structure (rmk:marginal-dgps).

3. THE CENTRAL TENSION / a key realization:
   The proof's "resolving rank-deficit directions" step is hand-wavy. The
   gold-augmented estimator in sim.R (fit_label_model_gold) just estimates each
   alpha_j as a Bernoulli mean from the gold examples where LF j votes. That
   estimator's error has NOTHING to do with r: it is m independent Bernoulli
   means, each needs O(1/gap^2 * log(m/delta)) for precision ~ gap. The r does
   not appear because once you know ALL marginals alpha_j exactly, the model is
   fully pinned regardless of E (you do not even need agreement moments
   anymore). So under THIS estimator the cost is O(log(m)/gap^2), with m the
   number of LFs, and r is irrelevant.

   => The existing sim study 4d sweeps gap with m=8 FIXED and never varies r.
   It cannot and does not test r-scaling. The remark admits this.

4. So the real question depends critically on the ESTIMATION MODEL / what
   "restore identifiability" means and what role gold plays:
   - Model I (full marginal pinning): gold pins ALL m marginals. Cost depends
     on m (number of LFs needing a gold vote), not r. ~ log(m)/gap^2 by union
     bound over m LFs, and Omega(1/gap^2) necessary, with an m or log m factor.
     r does not enter. This makes the headline r-claim simply MISSPECIFIED.
   - Model II (gold pins only the r lost directions, agreement moments supply
     the rest): this is what the proof's "resolve r directions" language and
     the packing remark gesture at. Here the question is genuinely about r.
     Need to formalize: a hybrid estimator that uses cheap agreement moments
     for the rank-one part and gold ONLY to fix the r-dim degeneracy.

**Decision:** The honest resolution requires formalizing Model II precisely as
an estimation problem and deriving its minimax rate in (r, gap). Plan:
  (i) Build the clean linear-algebraic statement of the degeneracy: the
      gold-free moments determine the model up to an r-dimensional family;
      gold labels are linear(ish) measurements that must pin a point in that
      family to accuracy ~ gap.
  (ii) Lower bound via Fano/packing over the r-dim family.
  (iii) Upper bound via concentration for the natural estimator.
  (iv) Simulation: vary r and gap INDEPENDENTLY under a controlled-r DGP,
       using the HYBRID estimator (not the full-marginal estimator), fit
       exponents.
Next: write state.md, then formalize Model II.

---

### Cycle 1 (2026-06-03) Measurement geometry + structural fact
**Phase:** HYPOTHESIZE + ATTEMPT (proof/linear-algebra)
**Hypothesis:** The dimension of the parameter family gold must pin equals r
(not 0, not m), but only for the HYBRID estimator; the direct-marginal
estimator's cost is log(m)/gap^2 independent of r.
**Modality:** symbolic/numeric Jacobian rank of the off-diagonal moment map.
**Attempt:** attempts/001-measurement-geometry/ (dfree.R, dfree2.R, verify_r_law.R)
**Result:** PASS, decisive. With dependence support UNKNOWN, the agreement
moments leave exactly an r-dimensional family of the margin vector a
undetermined: a_unident_dim = r EXACTLY (verified over m in {6..30}, 20 seeds,
exact integer match), in the regime r <= r_max(m) ~ m - sqrt(2m) (algebraic-
variety saturation). With support KNOWN it is 0. The direct-marginal estimator
re-measures all m marginals => log(m)/gap^2, independent of r. So r is the
right dimension only for the hybrid estimator pinning the r-dim degenerate
subspace U.
**Baseline run:** existing scripts/run.R study 4 confirms r is NOT tested: the
"mgold_needed by dependence strength" table shows mgold {0,140,140,200,140,200}
against r {0,0,1,6,6,6}: no monotone relation. The gap sweep (slope -2.04)
holds m=8 fixed: pure 1/gap^2 Bernoulli, no r.

### Cycle 2 (2026-06-03) Sample complexity: reduction + bounds + THE resolution
**Phase:** ATTEMPT (proof) + REFLECT
**Hypothesis:** The r-vs-log r conflict is a LOSS-specification ambiguity, not
a gap in the analysis. L2/total recovery to scale gap => Theta(r/gap^2);
Linf/per-direction control => Theta(log r/gap^2); both are tight for their loss.
**Modality:** reduction to r-dim sub-Gaussian sequence model + minimax bounds.
**Attempt:** attempts/002-sample-complexity-proof/ (proof.md, lower_bound.md)
**Result (analytical):**
  - Reduction: gold gives xi_i = a + e_i (one Bernoulli/voting LF), a noisy
    observation of the FULL margin vector; project onto U (the r-dim degenerate
    subspace) => r-dim Gaussian location model, per-coord noise Theta(1),
    n_g samples. Separation scale along U = Theta(gap).
  - LOSS L2 (total, ||ahat-a||_2 <= c*gap): UPPER E||P_U(xibar-a)||^2 =
    trace(B^T Sigma B)/n_g <= r/n_g => n_g = O((r+log(1/delta))/gap^2). LOWER
    r-dim Gaussian location minimax risk >= c0 r/n_g => n_g = Omega(r/gap^2).
    => Theta(r/gap^2). The union-bound log r is NOT needed and NOT present.
  - LOSS Linf (per-direction, every coord <= gap w.p. 1-delta): UPPER union
    bound = manuscript's exact bound => O((log r + log(1/delta))/gap^2). LOWER
    max of r Gaussians ~ sigma sqrt(2 log r) => Omega(log r/gap^2). The union
    bound is TIGHT for this loss, not loose.
  - RECONCILIATION: the remark's volume heuristic (per-direction resolution
    gap/sqrt(r), volume gap^r) is the CORRECT arithmetic for the L2/total loss
    and yields linear r. The union-bound proof is the CORRECT analysis for the
    Linf loss and yields log r. They bound DIFFERENT functionals; not in
    conflict. The manuscript's error is presenting them as competing bounds on
    one quantity and calling linear-r a "tighter" pending result; it is not
    tighter, it is a different (harder, total/joint) success criterion.
**Reflection:** Decision on which T4 should state hinges on the operationally
correct loss for weak supervision. The training-label posterior log-odds is a
SUM over LFs (linear in a), so downstream label KL ~ ||ahat-a||_2^2 (a TOTAL
target). => linear r is the operationally-correct rate, but the CURRENT PROOF
proves the log-r (Linf) statement, a weaker-loss claim. Must confirm by
simulation: (i) hybrid estimator, total target => slope +1 in r; (ii) per-
direction target => slope ~0 (log r); (iii) slope -2 in gap for both. Also will
confirm downstream-KL ~ ||.||_2^2 to justify the loss choice. NEXT: build
controlled-r DGP + hybrid estimator + r-sweep and gap-sweep.

### Cycle 3 (2026-06-03) Idealized r-sweep + gap-sweep: rates confirmed
**Phase:** ATTEMPT (simulation) + EVALUATE
**Hypothesis:** rates are loss-dependent: L2-total Theta(r/gap^2),
Linf-over-r-directions Theta(log r/gap^2), per-coord-RMS Theta(1/gap^2).
**Modality:** simulation (Bernoulli gold reduction) + exact Gaussian surrogate.
**Attempt:** attempts/003-rsweep-idealized/ (idealized.R, idealized2.R, confirm_constants.R)
**Result:** ALL THREE rates confirmed to the constant.
  gap-sweep (both losses): slope -2.02 to -2.06 => 1/gap^2. CONFIRMED.
  r-sweep, three intrinsic-coordinate metrics:
   A L2-total: n_g/r -> 24.00 = v/gap^2 (v=1-gap^2); log-log slope ->1.02 (r>=16).
     EXACT match to n_g = v*median(chi2_r)/gap^2 ~ r*v/gap^2. => Theta(r/gap^2).
   B Linf over r dirs: n_g = -0.83 + 37.3 log(r), R^2=0.993; per-doubling
     increment ~ const (logarithm), -> 2v/gap^2 * log2. => Theta(log r/gap^2);
     the union bound is TIGHT here.
   C per-coord RMS: n_g -> 24 = v/gap^2, FLAT in r. => Theta(1/gap^2).
**Eval (self):** The r-vs-log r question is definitively a LOSS question. All
three rates are real and tight for their respective loss. Closed-form constants
match simulation exactly. Strong progress.
**Reflection:** Must now confirm the REDUCTION is faithful to the full vote DGP
(dependent blocks, real triplet/agreement estimation, genuine hybrid estimator),
not an artifact of the idealized surrogate. Then decide which loss T4 should
adopt via the downstream-posterior-KL argument. NEXT: full-pipeline hybrid sim.

### Cycle 4 (2026-06-03) Faithfulness on full DGP + loss justification
**Phase:** ATTEMPT (simulation) + EVALUATE
**Hypothesis:** (a) the r-dim Gaussian reduction is faithful to full votes;
(b) the operationally-correct loss is L2-total (=> linear r).
**Modality:** simulation on full vote DGP.
**Attempts:** 004-full-pipeline/{faithful.R,hybrid_recovery.R,large_r.R},
005-loss-justification/posterior_kl.R
**Results:**
  FAITHFULNESS (004):
   - gold per-LF empirical variance = 1-a_j^2 EXACTLY on real votes (rich
     diagonal measurement confirmed).
   - degeneracy dimension gold pins = #dependent blocks (Jacobian d_free),
     while the paper's diagnostic agreement_rank_deficit reports 2*#blocks (rank
     of symmetric residual matrix). IMPORTANT distinction for the restatement.
   - full-DGP hybrid recovery, L2-total target: gap-slope -2.14; r-sweep ng/r
     -> ~40 constant, r>=8 log-log slope 1.07 (->1). ng = const*median(chi2_r)
     /gap^2 ~ r/gap^2. CONFIRMS Theta(r/gap^2) on real votes. The small-r slope
     excess is exactly the median(chi2_r)/r<1 finite-r artifact (matches the
     idealized run identically).
  LOSS (005):
   - downstream label KL vs ||da||_2^2: log-log slope 1.001 => KL is an L2
     quadratic form in margin error.
   - KL is INVARIANT to error shape at fixed ||da||_2 (concentrated Linf=0.10 vs
     spread Linf=0.03 give identical KL, ratio 1.00). => L2 governs label
     quality, NOT Linf. So the operationally-correct criterion is L2-total =>
     the LINEAR-r rate is the relevant one.
**Eval (self):** Question essentially SETTLED. Matching Theta(r/gap^2) for the
operationally-correct (L2/total) loss, with both bounds and full-DGP sim
confirmation. The log r is tight but for an operationally-irrelevant (Linf)
loss. Reconciliation complete.
**Reflection:** Final tasks: (i) tighten lower bound to a clean MINIMAX
statement (r-dim Gaussian location minimax risk = r*v/n_g; verify via Bayes
risk numerically); (ii) write formal proofs; (iii) synthesis + exact T4
restatement. NEXT: minimax lower-bound writeup + numeric Bayes-risk check.

### Cycle 5 (2026-06-03) Formal proofs + minimax lower bound verified
**Phase:** ATTEMPT (proof) + EVALUATE
**Hypothesis:** Theta(r/gap^2) for L2 is a genuine MINIMAX rate (no estimator
beats it), not just our estimator's rate.
**Modality:** proof writeup + numeric Bayes-risk/Cramer-Rao verification.
**Attempt:** 006-formal-proofs/{proofs.md, minimax_check.R}
**Result:** Lemmas 1-3 + Theorems A,B written cleanly and self-contained.
Minimax check: Bayes-risk envelope (tau->inf) = r*v/n_g = sample-mean risk
(MC-confirmed: r=4 ng=96 risk 0.0404; r=16 ng=384 risk 0.0402; target gap^2
0.04). Cramer-Rao gives the same. => minimax L2 risk EXACTLY r*v/n_g, so
minimax n_g = r*v/gap^2, slope 1.000 in r. Omega(r/gap^2) is information-
theoretic, not estimator-specific.
**Eval (self):** GOAL ACHIEVED. Matching Theta characterizations with proof for
all three losses; reduction proven + faithful on real votes; minimax lower
bound rigorous; loss justification settles the operative rate; tension fully
reconciled. Exit criterion (matching upper+lower bounds with proof) met.
**Reflection:** Write consolidated reproduction script -> findings/, then
synthesis.md with exact T4 restatement options. NEXT: synthesis.

### Cycle 6 (2026-06-03) CONCLUDE: synthesis written
**Phase:** CONCLUDE
**Activity:** Consolidated all findings into synthesis.md; copied proofs.md and
loss_taxonomy.md and reproduce.R into findings/; reproduce.R reruns clean and
regenerates every headline number in one pass.
**Outcome:** GOAL ACHIEVED. The r-vs-log r tension is a LOSS ambiguity. Matching
Theta bounds (with proof) for all three losses; the operative (L2/total) loss
gives Theta(r/gap^2) [MINIMAX], so the headline linear-r is CORRECT but the
current union-bound proof proves the log-r (Linf) statement instead. Recommended
restatement R0+R1 (define r as parameter-degeneracy dim = half the residual rank
for pairwise dependence; keep linear r; replace union bound with the trace-bound
upper + Gaussian-location-minimax lower; delete the "pending tighter argument"
framing). Alternatives R2 (weaken to log r) and R3 (reconciliation note) given.
Conclusion: see synthesis.md.
