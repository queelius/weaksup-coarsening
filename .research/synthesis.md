# Research Synthesis: the true gold-set sample complexity in T4

## Goal

Settle the true scaling of the gold-set sample complexity in Theorem T4
(`sections/methodology.tex`, `thm:goldset`): given a rank deficit r induced by
labeling-function (LF) dependence and an accuracy margin gap, how many gold
labels n_g are needed to restore identifiability of the label model? The
headline claims n_g = O(r / gap^2) (linear in r); the written proof (Hoeffding
per direction + union bound) delivers only O(log r / gap^2). Determine the true
rate, with matching upper and lower bounds if attainable.

## Outcome

SETTLED, with matching Theta bounds and proofs, confirmed by simulation on both
an exact reduction and the full vote-generating process. The central finding is
that the "r vs log r" tension is NOT a gap in the analysis; it is a
LOSS-SPECIFICATION ambiguity. There are three natural success criteria, and the
rate is different and TIGHT for each:

| Success criterion (loss)                              | Sample complexity        |
|-------------------------------------------------------|--------------------------|
| Total / L2: recover the model, ||ahat - a||_2 <= c*gap | Theta( r / gap^2 )       |
| Per-direction / Linf: every degenerate direction <= c*gap | Theta( log r / gap^2 ) |
| Per-coordinate RMS: ||ahat - a||_2 / sqrt(r) <= c*gap  | Theta( 1 / gap^2 )       |

For weak supervision the OPERATIVE criterion is the total/L2 one (the downstream
training-label posterior KL is an L2 quadratic form in the margin error; proven
and verified), so:

  THE HEADLINE LINEAR-r RATE n_g = Theta(r / gap^2) IS CORRECT,
  BUT THE CURRENT PROOF DOES NOT PROVE IT. The union-bound proof correctly
  establishes the log-r rate, which is the tight rate for a DIFFERENT and weaker
  (per-direction / Linf) success criterion, not the model-recovery criterion the
  headline is about.

Both the headline and the written proof are individually correct statements;
the manuscript errs only in presenting them as competing bounds on one quantity
and in calling linear-r a "tighter" result that is merely conjectured. Linear-r
is not tighter than log-r; it is the rate for a stronger (total) loss. The fix
is a one-paragraph change of loss + a short two-part proof (given below).

## Key Findings

1. THE DEGENERACY GOLD MUST PIN IS r-DIMENSIONAL (Lemma 1, `findings/proofs.md`,
   reproduced by `findings/reproduce.R` part 1, code in
   `attempts/001-measurement-geometry/`).
   When the dependence support is unknown (the realistic case, and the meaning
   of "dependence destroyed r identifying directions"), the gold-free agreement
   moments determine the margin vector a up to an affine family of dimension
   EXACTLY r, for r in the practical regime r << m. Verified as an exact integer
   identity (m = 6..30, 20 random instances each) via the rank of the
   off-diagonal moment-map Jacobian. If the support were KNOWN the degeneracy
   would be 0; it is the unknown support that creates the r free directions.

   SUBTLETY (affects the restatement): the paper's diagnostic
   `agreement_rank_deficit` reports the rank of the symmetric residual matrix
   A - hat a hat a^T, which for K disjoint dependent PAIRS equals 2K. But the
   PARAMETER-degeneracy dimension gold must pin is K, not 2K. The rate is
   governed by the parameter-degeneracy dimension. T4's "r" should be defined as
   this parameter-degeneracy dimension d_free, which for pairwise dependence is
   half the residual-matrix rank.

2. GOLD IS A RICH, DIAGONAL, FULL-VECTOR MEASUREMENT (Lemma 2). A gold example
   yields, for each voting LF j, an unbiased Bernoulli draw of the margin a_j
   with per-coordinate variance exactly 1 - a_j^2 (verified to two decimals on
   real votes, `reproduce.R` part 2). So n_g gold examples give a noisy
   observation of the WHOLE margin vector with diagonal covariance ~ (1/n_g)
   diag(1 - a_j^2). Projecting onto the r-dim degenerate subspace reduces the
   problem to the r-dimensional sub-Gaussian LOCATION model with n_g samples and
   per-coordinate noise Theta(1); the relevant tolerance scale along the
   degenerate directions is Theta(gap). This reduction is the crux and is
   faithful to the full DGP.

3. MATCHING Theta BOUNDS (Theorems A and B, `findings/proofs.md`).
   - Theorem A (total / L2): UPPER via the trace bound E||P_U(xibar-a)||_2^2 =
     trace(B^T Sigma B)/n_g <= r/(n_g beta_min); LOWER via the r-dim Gaussian
     location MINIMAX risk >= c0 r/n_g. Both give n_g = Theta(r/gap^2). The
     lower bound is information-theoretic (Bayes-risk envelope = sample-mean
     risk = r v/n_g, also Cramer-Rao); no estimator beats it. Verified
     numerically: minimax risk = r v/n_g to 3 digits (`reproduce.R` part 5).
   - Theorem B (per-direction / Linf): UPPER is EXACTLY the manuscript's union
     bound, n_g >= (1/(2 c1^2 beta_min gap^2)) log(2r/delta); LOWER via the
     maximum of r sub-Gaussian coordinates ~ sqrt(2 log r). Both give
     Theta(log r/gap^2). The union bound is TIGHT for this loss, not loose.

4. THE OPERATIVE LOSS IS L2, SO LINEAR-r IS THE RELEVANT RATE (Lemma 3,
   `attempts/005-loss-justification/`). The naive-Bayes posterior log-odds is
   linear in a, so the expected KL of the estimated training labels from the
   true posterior is a positive-definite quadratic form in the margin error,
   i.e. a coverage-weighted L2 (sum-over-LFs) norm. Empirically: E[KL] vs
   ||da||_2^2 has log-log slope 1.001, and E[KL] is invariant to whether a fixed
   ||da||_2 budget is concentrated (large Linf) or spread (small Linf), ratio
   1.01. Label quality is governed by the L2 norm, not the worst single LF.
   Hence "restore the label model to fixed label quality" is the total/L2
   criterion and the operative rate is Theta(r/gap^2).

5. THE EXISTING VALIDATION DOES NOT TEST r (and the manuscript says so). The
   study sweeps gap with m = 8 LFs fixed and uses the direct-marginal estimator
   (`fit_label_model_gold`), which re-measures all m marginals and whose cost is
   Theta(log m / gap^2), INDEPENDENT of r. Its "m_gold needed by dependence
   strength" table is {0,140,140,200,140,200} against effective deficit
   {0,0,1,6,6,6}: no monotone relation. The -2.04 gap slope it reports is the
   pure 1/gap^2 Bernoulli rate with no r in play. The r-channel is exercised
   only by a HYBRID estimator (agreement moments for the rank-one part, gold for
   the r degenerate directions); the new simulations here build exactly that and
   confirm n_g/r -> constant with log-log slope -> 1.

6. SIMULATION EVIDENCE (fitted exponents).
   Exact reduction (`attempts/003`, `reproduce.R`):
     L2:   n_g/r -> 24.00 = v/gap^2 exactly; log-log slope vs r = 1.02-1.04
           (r >= 16); slope vs gap = -2.06.  => Theta(r/gap^2).
     Linf: n_g = a + b*log(r), R^2 = 0.99; per-doubling increment ~ const.
           => Theta(log r/gap^2).
     RMS:  n_g flat in r at 24 = v/gap^2.  => Theta(1/gap^2).
   Full vote DGP, genuine hybrid estimator (`attempts/004`):
     L2 (total recovery of the degenerate coordinates): gap slope -2.14;
     n_g/r -> ~40 constant; r>=8 log-log slope 1.07. The small-r excess is the
     median(chi^2_r)/r < 1 finite-r artifact (identical in the exact reduction),
     not super-linearity.  => Theta(r/gap^2) confirmed on real votes.

## Failed / discarded approaches

- Assuming the rate is about the residual-matrix rank (2K for K pairs): wrong
  object. The rate tracks the parameter-degeneracy dimension d_free = K.
- Assuming gold "pins r directions one at a time" (the union-bound mental
  model): this is the Linf loss and gives log r; it is correct but answers the
  wrong question for model recovery.
- Trying to make the existing direct-marginal estimator exhibit an r-dependence:
  it cannot; its cost is governed by m, not r. The r-rate requires the hybrid
  estimator.
- An early local Jacobian computation with KNOWN dependence support gave
  d_free = 0 (a is identified even with dependence if you know which pairs are
  dependent). Correct but not the operative scenario; the unknown-support count
  d_free = r is what the bound is about. Documented to forestall confusion.

## Open questions

- Constants and coverage. The Theta constants carry a 1/beta_min coverage factor
  and the (1 - a_j^2) variance; the analysis treats coverage as entering only
  the constant, which the marginal-preserving construction supports, but a fully
  explicit constant as a function of the coverage profile is not worked out.
- Beyond pairwise / low-rank E. Lemma 1's d_free = r holds in the regime
  r <= r_max(m) = Theta(m); the variety-saturation boundary for highly
  structured high-rank E is not characterized (irrelevant in practice, r << m).
- Multiclass. The whole analysis is binary (a in R^m). The K-class case
  replaces the margin vector by a tensor and the symmetric group acts; the
  reduction should generalize (degenerate subspace dimension scales with the
  number of confounded class-pairs) but is not carried out here.
- Finite-corpus agreement noise. The reduction treats the unlabeled agreement
  moments as exact (corpus plentiful). A joint finite-(corpus, gold) analysis
  would couple the two error sources; expected to be a lower-order correction.

## Recommendations: the exact restatement T4 should adopt

The honest and useful fix has three parts. Any of the three framings below is
defensible; framing (R1) is recommended because it keeps the headline (which is
correct) and supplies the missing proof.

R0 (PRECONDITION, do this regardless). Define r as the PARAMETER-DEGENERACY
   dimension d_free: the dimension of the affine family of margin vectors
   consistent with the gold-free agreement moments (equivalently, the corank of
   the off-diagonal moment-map Jacobian when the dependence correction E ranges
   over its unknown low-rank support). State that for pairwise dependence this
   equals the NUMBER of dependent pairs, which is HALF the rank of the symmetric
   agreement-residual matrix reported by the rank-one-fit diagnostic. (Without
   this, "r" is ambiguous by a factor of 2.)

R1 (RECOMMENDED: keep linear r, supply the proof, state the loss). Replace the
   "resolving the rank-deficit directions" paragraph and `rmk:r-dependence` with:
   - State the success criterion explicitly as TOTAL/L2 model recovery:
     || hat a - a ||_2 <= c * gap (equivalently, downstream label-posterior KL
     below a fixed budget; the posterior log-odds is linear in a, so its KL is a
     coverage-weighted L2 quadratic form in the margin error).
   - Prove the upper bound by the r-dim PROJECTION/TRACE bound (Theorem A
     upper): the gold mean projected onto the r-dim degenerate subspace has
     expected squared error trace(B^T Sigma B)/n_g <= r/(n_g beta_min); a chi-
     square tail gives n_g = O((r + log(1/delta))/gap^2). This is where the
     LINEAR r comes from, and it is short.
   - Prove the lower bound by the r-dim Gaussian-location MINIMAX risk
     (Theorem A lower): minimax L2 risk >= c0 r/n_g (Bayes envelope / Cramer-
     Rao), so n_g = Omega(r/gap^2). Together: n_g = Theta(r/gap^2).
   - DELETE the claim that the union bound only gives log r "pending a tighter
     argument." The union bound gives log r because it targets the Linf loss;
     for the L2 loss the trace bound gives linear r directly. They are different
     losses, not loose-vs-tight.
   Suggested theorem statement:
     "Under [decomposition] with parameter-degeneracy dimension r and margin
      gap, the hybrid (agreement-moment plus gold) estimator recovers the label
      model to total accuracy || hat a - a ||_2 <= c gap with probability
      1 - delta provided n_g >= C (r + log(1/delta)) / gap^2, and this is
      minimax optimal in r and gap: n_g = Omega(r / gap^2) is necessary."

R2 (ALTERNATIVE: weaken the headline to log r, keep the existing proof). If the
   authors prefer to keep the union-bound proof verbatim, then the correct
   headline is the PER-DIRECTION statement: with n_g = O(log r / gap^2) gold
   labels, every degenerate direction is resolved to accuracy gap with
   probability 1 - delta. State plainly that this is Linf/per-direction control,
   not total model recovery; for total recovery the requirement is Theta(r/gap^2)
   (cite R1). This is fully honest but gives up the (correct and stronger)
   linear-r headline, so it is less attractive.

R3 (FRAMING NOTE for the remark / discussion, regardless of R1 vs R2). State the
   reconciliation explicitly: the union bound (log r) and the volume/packing
   argument (linear r) are TIGHT bounds on DIFFERENT functionals (max per-
   direction error vs total L2 error), not competing bounds on one quantity. The
   remark's own volume heuristic (competing-solution volume ~ gap^r, per-
   direction resolution gap/sqrt(r), hence n_g ~ r/gap^2) is the correct L2/total
   calculation; present it as the proof of the linear-r rate for the total loss,
   not as a conjecture.

VALIDATION TO ADD (optional but strong). The current study does not vary r.
Add the r-sweep with a hybrid estimator and a total-recovery target (code:
`.research/findings/reproduce.R`, `.research/attempts/004-full-pipeline/`):
report n_g/r -> constant and log-log slope -> 1 in r, alongside the existing
-2 gap slope. Optionally add the Linf-target sweep showing the log r rate, to
make the loss-dependence concrete.

## Where everything lives

- Proofs (self-contained): `.research/findings/proofs.md`
  (Lemmas 1-3, Theorems A and B, reconciliation, direct-marginal remark).
- Loss taxonomy / three-rate derivation: `.research/findings/loss_taxonomy.md`.
- One-shot reproduction of all headline numbers: `.research/findings/reproduce.R`
  (run: `Rscript .research/findings/reproduce.R`).
- Working attempts: `.research/attempts/001-measurement-geometry/` (d_free = r),
  `002-sample-complexity-proof/` (reduction + bounds), `003-rsweep-idealized/`
  (exact-reduction r/gap sweeps + constants), `004-full-pipeline/` (faithfulness
  on real votes + hybrid recovery), `005-loss-justification/` (label KL is L2),
  `006-formal-proofs/` (proofs + minimax check).
- No manuscript .tex file was modified.
