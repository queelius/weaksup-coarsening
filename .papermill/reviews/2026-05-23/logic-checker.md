# Logic and Proof Audit

## T1 (glass ceiling / accuracy-complement symmetry)

The construction (identifiability.tex lines 28 to 65) is a clean, complete proof of the SYMMETRIC-VOTE-MODEL case. The relabeling argument y maps to 1-y inside the marginalization is correct: every joint vote probability under (pi, alpha) equals the corresponding probability under (1-pi, 1-alpha) when the LF noise model is the standard symmetric confusion. The multiclass remark (binary Z/2 case extends to the symmetric group S_K) is correct in principle.

Minor logical concern (severity: minor). The phrase "absent a structural assumption on LF dependence or LF orientation" is slightly imprecise. The construction uses ONLY the symmetric accuracy model. The glass ceiling holds for ANY LF dependence structure that respects the symmetric label-noise model. Stating "absent an external orientation constraint" would be more precise; LF dependence is irrelevant to the existence of this particular symmetry. The current phrasing could mislead a reader into thinking that some LF dependence patterns avoid the symmetry, which is false.

Suggestion: rewrite line 21-23 as "Without gold-labeled examples and without an external orientation constraint (e.g., 'every LF is better than random'), the pair (alpha, pi) is non-identifiable from the distribution of LF votes."

## T2 (identifiability under conditional independence)

The proof (identifiability.tex lines 95 to 126) correctly derives the triplet identities and recovers a_j^2, then explains how the better-than-random assumption selects the positive root. The sequence of moment equations is correct. One small gap: the proof asserts "the triple product fixes the common sign" without showing how. Specifically, with all a_j > 0 the triple product E[sigma_j sigma_k sigma_l] = a_j a_k a_l > 0, but with one sign flip the triple product flips sign too. So the triple product fixes the PARITY of sign flips, not the absolute sign of each a_j. The better-than-random assumption is what fixes the absolute sign. The proof says this in effect but the parity-versus-absolute-sign distinction would clarify a confusing point for a careful reader.

Suggestion: in the sentence "the triple product fixes the common sign," replace with "the triple product fixes the parity of the sign pattern (sign(a_j a_k a_l) is observed); the better-than-random assumption then resolves each individual sign to positive."

The "non-degenerate accuracy" condition (alpha_j != 1/2) is correctly stated as the keep-denominator-nonzero condition.

The orientation-assumption commentary added in the prior pass is good (lines 133-141): explicitly flags that "LF written backward" is a real failure mode.

## T3 (agreement consistency)

The proof (identifiability.tex lines 169 to 184) is a sketch that points to towell2026scrnacoarsening Section 3 for the moment-matching argument. The argument as stated is correct in outline: exponential-family score, pairwise agreement indicator as sufficient statistic, stationarity condition equals empirical mean equals model expectation.

CRITICAL FINDING (severity: major). The theorem statement assumes a parametrization "that includes the pairwise LF agreement indicators as sufficient statistics." But the standard data-programming or Snorkel naive-Bayes label model is parametrized by PER-LF ACCURACIES (alpha_1, ..., alpha_m) and the CLASS PRIOR pi. The pairwise agreement indicators are not automatically sufficient statistics for this parametrization; they are sufficient statistics only for a particular EXPONENTIAL-FAMILY EXTENSION where each pairwise agreement gets its own parameter. The theorem as stated is mathematically correct but DOES NOT APPLY to the standard naive-Bayes label model unless extended.

The proof script (sim.R lines 276-293) computes the agreement_residual for the naive-Bayes-with-fitted-accuracies model. The simulation shows the residual is small but this is BECAUSE the model is correctly specified and large-n, not because of T3. T3 as stated holds only for the exponential-family parametrization; the simulation does not directly validate T3 for the model actually used.

Suggestion: either (a) restate T3 as "for any label-model parametrization whose log-likelihood has the pairwise agreement indicators among its sufficient statistics, including the conditionally-independent naive-Bayes parametrization extended with explicit pairwise agreement parameters" or (b) prove the corresponding sufficient-statistic property for the NAIVE-BAYES parametrization, showing that at the MLE the pairwise-agreement constraint is implied. Option (b) is feasible: in the naive-Bayes parametrization with parameters (alpha, pi), the score of the marginal log-likelihood includes a term whose stationarity matches model and empirical pairwise agreement under conditional independence, but ONLY because the joint vote distribution factors. The statement should be more careful. As written, T3 is a SUFFICIENT-CONDITION theorem for a specific extended parametrization.

This is the most important new logic concern beyond the prior pass.

## T4 (gold-set sample complexity)

The proof (methodology.tex lines 77 to 117) was rewritten in the prior pass to include explicit Hoeffding plus union bound plus traceable constants. The argument now reads:

- Each gold-pinned per-LF accuracy estimate is a Bernoulli mean with variance 1/(4 n_g beta_min). Correct.
- Hoeffding gives Prob(|hat_alpha_j - alpha_j| > epsilon) <= 2 exp(-2 n_g beta_min epsilon^2). The factor beta_min in the exponent comes from the effective sample size n_g beta_j on which the empirical mean is taken; correct.
- Union bound over r directions to get the rank-deficit-r factor. Correct.
- The (c_1 gap) substitution sets the per-direction tolerance to a constant fraction of the gap, propagating the gap^2 inverse.

CRITICAL FINDING (severity: critical, but possibly resolvable by clarification). The argument that "the per-direction error budget itself shrinks with r" is the load-bearing step for the LINEAR-IN-r factor, and it is HAND-WAVED. The proof writes "$r$ factor enters when the per-direction error budget itself shrinks with $r$" but does NOT justify why the budget should shrink linearly in r. The plain union bound gives log(r/delta) inside the exponent, which propagates to a log(r)/gap^2 dependence, not linear-in-r.

The transition from log(r) to linear r requires either (a) a more refined geometric argument about the volume of competing solutions in an r-dimensional subspace (the volume scales as gap^r, so resolving each direction to gap/r precision is needed to disambiguate by a volume-counting argument), or (b) a packing-number argument that explicitly produces the r factor.

The cited apparatus in "[Section 7]{towell2026masked}" is not in-paper and not verifiable from the manuscript. Given that T4 is the headline new result, this gap matters. Two acceptable fixes:

1. Replace "linear in r" with "logarithmic in r" in the bound statement, matching what the union bound actually delivers. The O(log r / gap^2) bound is still a real contribution, just less dramatic than O(r / gap^2).

2. Provide the volume / packing argument that actually delivers the linear-in-r factor. A sketch: the r-dimensional subspace of competing solutions has volume scaling as gap^r in parameter space; resolving the parameter to a fraction gap/sqrt(r) per direction is necessary to distinguish solutions whose pairwise distance is gap. The Hoeffding bound for SE = gap/sqrt(r) gives n_g >= r/gap^2 (per direction), and union bound over r directions adds log(r) but the squared improvement absorbs it.

A note on the simulation. The empirical study (validation.tex Section "Sample complexity scales as 1/gap^2") fixes the dependence structure and varies the gap, fitting the log-log slope -2.04 to the m_gold-versus-gap data. This confirms the 1/gap^2 part. It does NOT confirm the linear-in-r part. The paper acknowledges this honestly in the "On the rank deficit" paragraph (validation.tex lines 162-174): "isolating the linear-in-r factor empirically would require an estimator that also reconstructs the dependence structure, which we leave to the longer manuscript." This is correct but reinforces that the r factor is currently unsupported by both proof and simulation. A reviewer at AISTATS/NeurIPS/ICML may ask "what is the actual asymptotic dependence on r" and the paper should be prepared with a tight answer.

Suggested fix that is least invasive: state T4 with the O(log r / gap^2) bound that the union bound actually delivers, and note that under a stricter notion of identifiability (resolving the joint r-dimensional solution to a volume of size delta) the bound becomes O(r / gap^2). The simulation confirms the gap part either way.

## bg-id (background identifiability theorem)

The in-paper Theorem 1 (background.tex lines 61-66) states: "theta is identifiable iff the augmented candidate-set matrix has full column rank m." This is now properly stated in-paper (replacing the external citation per prior pass). The "iff" is strong: it claims FULL COLUMN RANK is BOTH NECESSARY AND SUFFICIENT for identifiability. The "sufficient" direction is the usual identifiability result; the "necessary" direction requires that no other coarsening mechanism could produce identifiability when the candidate-set matrix is rank-deficient. The necessary direction is more delicate.

Suggestion: weaken to "theta is identifiable when the augmented candidate-set matrix has full column rank m; conversely, rank deficiency in the candidate-set matrix corresponds to non-identified directions in the parameter space, under the C1-C2-C3 regularity conditions." Or cite a specific reference for the iff statement.

## Summary

- T1: proof is sound; one phrasing imprecision (minor).
- T2: proof is sound; one parity-versus-absolute-sign clarification needed (minor).
- T3: theorem statement is correct only for an extended parametrization; the standard naive-Bayes case needs either restatement or a separate argument (major).
- T4: union bound delivers log(r)/gap^2; the linear-in-r factor is hand-waved; the simulation only confirms the gap part (critical, but easily fixed by relaxing the stated bound).
- bg-id: "iff" is strong; weaken or cite (minor).
