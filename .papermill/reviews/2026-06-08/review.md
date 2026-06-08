# Multi-Agent Review Report

**Date**: 2026-06-08
**Paper**: Programmatic weak supervision as masked-cause inference: identifiability of label models without gold data (Alexander Towell, SIUE)
**Recommendation**: minor-revision

## Summary

**Overall Assessment**: This is a sound, honestly positioned theory-with-simulation
paper that recasts programmatic weak supervision as masked-cause coarsening
inference and contributes one genuinely new quantitative result, the gold-set
sample-complexity bound Theta(r/gap^2) for total (L2) label-model recovery under
labeling-function (LF) dependence. All four theorems are correct, the build is
clean, the simulation is fully reproducible (every headline number reproduced from
results.rds), and the prior-art positioning is exemplary and does not overclaim. The
single substantive weakness is unchanged from the prior review: the headline
linear-in-r rate is proved but not exercised by the in-paper simulation. What has
changed is that the closing evidence (a complete r-sweep) now exists and reproduces
inside the repository, so the fix is a low-cost figure-port rather than new work.

**Strengths**:
1. All four theorems are correct (logic-checker, HIGH confidence). T1's
   accuracy-complement symmetry was independently confirmed exact (max difference
   0.000e+00 over all 243 vote patterns); T4's load-bearing pieces (trace upper
   bound, Gaussian-location minimax lower bound, KL = L2 quadratic form) were
   re-derived, with the KL = L2 claim verified numerically (KL(t)/t^2 constant to
   ratio 1.003).
2. The simulation is fully reproducible and faithfully reported: every number in
   validation.tex matches results.rds, including the gap log-log slope -2.0438
   (paper -2.04), the gold sweep, and the gap-scaling table (methodology-auditor).
3. T4 is genuine, minimax-tight, and information-theoretic in its lower bound, so
   it binds every estimator, not just the proposed hybrid one (logic-checker,
   methodology-auditor).
4. The T3 exactness "seam" is handled with exemplary honesty: the theorem states
   the consistency identity is exact only under a sufficiency-complete
   parametrization and provides cor:agreement-nb for the asymptotic n^{-1/2}
   naive-Bayes corner, rather than overclaiming exactness (logic-checker,
   prose-auditor).
5. Prior-art differentiation is honest: Dawid-Skene named "the clear ancestor," T2
   labeled a re-derivation, the candidate-set view credited to Yu-Ding-Bach (2022),
   and label-model identifiability explicitly disclaimed as the paper's invention
   (novelty-assessor, literature-context).
6. Clean build: 0 undefined citations, 0 broken cross-references, no U+2014, no
   vanity counts, only two cosmetic overfull boxes (format-validator,
   citation-verifier).

**Weaknesses**:
1. The headline linear-in-r rate is unvalidated in-paper: the in-paper simulation
   sweeps gap at fixed r with the direct-marginal estimator, whose cost is
   r-independent, confirming the 1/gap^2 factor but not the r-channel
   (methodology-auditor M1). The confirming r-sweep exists in
   `.research/attempts/003-rsweep-idealized/` and reproduces (L2 slope 1.17), but
   is deferred in-paper to a "Manuscript in preparation" that does not exist on disk.
2. Length (22 pages) versus the header-stated 12-page target; venue-conditional and
   inconsistent with the state file's own AISTATS/JMLR shortlist
   (format-validator F1).
3. Persisting presentational/citation defects from the prior review: c_0 names two
   constants in the T4 proof (logic-checker, prose-auditor), and the foundational
   Allman-Matias-Rhodes (2009) identifiability citation is still missing behind T2
   (citation-verifier, novelty-assessor, literature-context).

**Finding Counts**: Critical: 0 | Major: 2 | Minor: 6 | Suggestions: 4

## Critical Issues

None. The logic-checker certifies all four theorems correct and re-derived the T4
load-bearing claims; the methodology-auditor reproduced every validation number;
the build is clean. No finding rises to critical.

## Major Issues

### M1. Headline linear-in-r rate is proven but not validated in-paper; the closing evidence now exists in-repo (source: methodology-auditor; cross-verified by logic-checker)
- **Location**: `sections/validation.tex` 164-194 ("On the rank deficit" paragraph
  and the WRENCH sentence); the rate is foregrounded in the abstract (`main.tex`
  96-101), the introduction contribution list (`sections/introduction.tex`
  106-115), the T4 statement (`sections/methodology.tex` 82-113), and the
  conclusion (`sections/conclusion.tex` 19-22).
- **Quoted text**: "this study fixes the dependence structure and sweeps
  $\mathrm{gap}$, so it isolates the $1/\mathrm{gap}^2$ factor common to both
  estimators and does not exercise the $r$-channel (an $r$-sweep with the hybrid
  estimator is deferred to the longer manuscript)." And in `methodology.tex`:
  "the linear-in-$r$ rate is proved here but not yet validated by an $r$-sweep,
  which the longer manuscript supplies."
- **Problem**: The paper's one genuinely-new quantitative contribution is the
  linear-in-r L2 rate. The in-paper simulation uses the direct-marginal estimator
  (re-measures all m marginals from gold, discards agreement moments), whose cost
  is governed by gap and a union over m, not by r. So the simulation confirms two
  of T4's three predictions (gold restores identifiability; cost ~ 1/gap^2) and
  leaves the headline-defining third resting on the proof. This is evidentiary, not
  a correctness gap: the logic-checker verified the r-scaling proof. The new
  observation this review adds is that the confirming study already exists as a
  runnable script (`.research/attempts/003-rsweep-idealized/idealized2.R`) and
  reproduces: sweeping r in {1..64} at fixed gap, the L2-total criterion gives
  log-log slope 1.17 vs r (predicted +1; theory line n_g = 24*r tracks the data),
  the Linf criterion fits log r (R^2 0.986 > power-law 0.917), and per-coord RMS is
  flat (slope ~0). All three loss-dependent rates of rmk:r-dependence reproduce.
  The deferral target `towell2026weaksupcoarseningextended` is a bib entry typed
  "Manuscript in preparation (extended version of the present paper)" with no DOI
  and no directory on disk; the headline result's empirical confirmation is thus
  pointed at a phantom while the confirming script sits unported in this repo.
- **Suggestion**: Port one panel of `idealized2.R` into `validation.tex` as a
  figure of n_g vs r at fixed gap, overlaying the L2/Linf/RMS curves (the script
  already separates them). This converts the headline from "proved, validated
  elsewhere" to "proved and validated here" at near-zero cost and removes three of
  the four deferral phrasings. Present the slope honestly (1.17 over the finite
  grid; a fit for r >= 4 or a caption note on small-r curvature suffices). Failing
  the port, soften "confirmed in simulation" near the linear-r claim and stop
  citing a nonexistent manuscript as the home of the load-bearing evidence.
- **Cross-verified**: YES. Logic-checker confirms the r-scaling proof is correct
  (so this is evidentiary, not correctness); methodology-auditor reproduced the
  r-sweep script. The two specialists agree, and this review additionally
  reproduced the script directly.

### M2. Length versus the stated target, and the header is now internally inconsistent (source: format-validator)
- **Location**: `main.tex` line 3 header comment vs the built PDF and the state
  file's venue shortlist.
- **Quoted text**: "Conference-format draft (target: 12 pages incl. references)."
- **Problem**: The clean build is 22 pages including references. The 12-page header
  is inconsistent with both the build and the state file's own ranked shortlist,
  which lists AISTATS (10 main + unlimited appendix) as rank 1 and JMLR (no limit)
  as a long-form target. Under the AISTATS/JMLR reading the length is acceptable
  with proofs and the three-regime interpretation in an appendix; under a hard
  9-main-page NeurIPS/ICML reading it needs real compression. If any 12-page target
  is binding, the paper is roughly double and not submittable as-is.
- **Suggestion**: Reconcile the target venue and correct the header to match.
  Natural cut/appendix candidates if compression is needed: the background primer
  and the three-regime interpretation, with detail pushed to the (to-be-created)
  extended manuscript. The state file also carries two conflicting `build` blocks
  (16-page and 18-page) under a duplicate YAML key; reconcile when next updated.
- **Cross-verified**: N/A (a production/venue fact, not a reasoning claim).

## Minor Issues

### m1. c_0 names two different constants in the T4 proof (source: logic-checker AND prose-auditor; PERSISTS from prior m1)
- **Location**: `sections/methodology.tex` 91, 102 (tolerance constant) vs 172
  (variance floor) and 182 (conversion).
- **Quoted text**: line 172 "$\ge c_0 = (1 - \mathrm{gap}^2)/\beta_{\max} > 0$";
  line 182 "requires $n_g \ge (c_0/c_0^2)\, r/\mathrm{gap}^2$".
- **Problem**: c_0 is the success-tolerance constant at 91/102 (||a-hat - a|| <=
  c_0 gap) and the per-coordinate variance floor at 172; the conversion "(c_0/c_0^2)"
  has one symbol doing two jobs. The arithmetic still resolves to Omega(r/gap^2),
  so the result is correct.
- **Suggestion**: Rename the tolerance constant (e.g. c_tol) so the conversion
  reads n_g >= (var_floor / c_tol^2) r/gap^2. Flagged from both the math side
  (logic-checker) and the clarity side (prose-auditor); one defect, two lenses.

### m2. Missing foundational identifiability citation for T2 (source: citation-verifier, novelty-assessor, literature-context; PERSISTS from prior m2)
- **Location**: `sections/identifiability.tex` 91-131 (T2 proof);
  `sections/translation.tex` Dawid-Skene paragraph.
- **Problem**: T2's conditional-independence identifiability is a special case of
  Allman-Matias-Rhodes (2009, Annals of Statistics 37(6); DOI 10.1214/09-AOS689),
  built on Kruskal (1977). The attribution to Dawid-Skene / Ratner / Fu is honest
  but a statistics-literate referee at the stated venues will expect the
  foundational citation.
- **Suggestion**: Add Allman-Matias-Rhodes (2009) and optionally Kruskal (1977) to
  refs.bib and cite behind the triplet identities. Zero novelty cost (T2 is
  explicitly a re-derivation); pure strengthening.

### m3. Projected-covariance eigenvalue lower endpoint loosely stated (source: logic-checker; PERSISTS from prior m3)
- **Location**: `sections/methodology.tex` 138.
- **Problem**: The interval lower endpoint (1-gap^2)/beta_max uses the
  smallest-margin (largest) per-coordinate variance, which belongs at the upper end;
  the tight floor is (1 - max_j a_j^2)/beta_max. The "= Theta(1)" conclusion is
  unaffected.
- **Suggestion**: State the floor as (1 - max_j a_j^2)/beta_max.

### m4. Finite-corpus agreement noise not stated as a T4 hypothesis (source: methodology-auditor; PERSISTS from prior m4)
- **Location**: `sections/methodology.tex`, T4 statement and proof first line.
- **Problem**: The reduction treats the unlabeled agreement moments as exact, so
  gold error is the only modeled source; a joint finite-(corpus, gold) analysis
  would couple two error sources. Expected lower-order, but the assumption is
  implicit.
- **Suggestion**: Add "with the unlabeled corpus large enough that the
  agreement-identified subspace is fixed" to the theorem hypotheses.

### m5. Two trivial overfull hboxes (source: format-validator, prose-auditor; PERSISTS from prior m5)
- **Location**: `sections/methodology.tex` 206-215 (6.6pt, near rmk:l2-loss);
  `sections/translation.tex` 113-117 (0.75pt, invisible).
- **Suggestion**: A `\\` or minor rephrase clears the 6.6pt box; the 0.75pt one is
  below notice.

### m6. Four uncited bib entries plus two cosmetic bibtex field warnings (source: citation-verifier; partially PERSISTS from prior m6)
- **Location**: `refs.bib`.
- **Problem**: Four defined-but-uncited entries (`khetan2018learning`,
  `ratner2018snorkelfg`, `shin2021universalizing`, `tanno2019learning`) are dead
  weight (suppressed by plainnat, no build effect). Separately,
  `anandkumar2014tensor` is typed `@inproceedings` with journal fields and an empty
  booktitle (it is a JMLR article), and `ratner2019training` sets both
  volume/number, producing cosmetic warnings.
- **Suggestion**: Cite the four where relevant (khetan/tanno in the crowdsourcing
  sentence; shin in the Snorkel-ecosystem list) or delete them; retype
  anandkumar2014tensor as `@article` and drop one of volume/number where both set.

## Suggestions

1. Distinguish the imported synthesis corollary (T3, a corollary of
   `towell2026synthesis`) from the domain-specific new theory (T4, not derivable
   from the synthesis alone) with one sentence, so T4's novelty is not absorbed
   into "just another application" (novelty-assessor).
2. Add a one-sentence caveat in the budgeting procedure (`methodology.tex` 290-310)
   on the bound's validity under noisy plug-in (r-hat, gap-hat), since the pilot gap
   estimate is noisiest exactly in the expensive small-gap regime (methodology-auditor).
3. Surface the 1/beta_min dependence of the Theta(r/gap^2) constants in the
   discussion limitations list (methodology-auditor).
4. Split the five-clause marginal-preserving-DGP sentence in `validation.tex` 24-31
   after "what a gold-labeled example observes" (prose-auditor).

## Detailed Notes by Domain

### Logic and Proofs (logic-checker, HIGH confidence)
All four theorems and cor:agreement-nb are correct at conference-sketch rigor. T1's
relabeling symmetry is exact (243-pattern enumeration: max difference 0.000e+00).
T2's triplet identities and solve are correctly stated as a re-derivation of Fu
(2020). T3's moment-matching argument is valid and, crucially, its exactness seam is
handled honestly: the theorem requires a sufficiency-complete parametrization and
defers the naive-Bayes corner to an asymptotic corollary (population formula
verified numerically, difference 3.5e-4). T4 is sound throughout: gold is an
unbiased diagonal measurement of the whole margin vector; the trace bound gives the
linear-in-r L2 rate with no log r; the Gaussian-location minimax lower bound is
information-theoretic; the KL = L2 quadratic form (the justification for the L2
criterion) was numerically confirmed (KL(t)/t^2 constant to 1.003). The
loss-taxonomy remark correctly separates L2 (r/gap^2), Linf (log r/gap^2, union
bound tight), and RMS (1/gap^2). Two persisting cosmetic blemishes: c_0 symbol
overload (m1) and the loose eigenvalue endpoint (m3); neither changes any rate.

### Novelty and Contribution (novelty-assessor, HIGH confidence)
The fourfold contribution is clearly stated and honestly bounded across abstract,
intro, discussion, and conclusion. The genuine novelty is T4, the dependent-case
gold-set sample-complexity bound: prior work covers the r=0 corner (data
programming, FlyingSquid) and recovers the dependency graph (Varma 2019) but does
not price the gold data that restores a correlated ensemble; Yu et al. (2022)
identify up to label swapping but do not price the dependent case. The loss-dependent
refinement pre-empts the "isn't this just a union bound?" objection. T1 and the
unification/taxonomy are correctly positioned as sharpenings and scaffolding, not
discoveries. One series-paper risk: a referee may read the paper as a mechanical
instantiation of the synthesis; recommend distinguishing the imported corollary (T3)
from the new theory (T4).

### Methodology (methodology-auditor, HIGH confidence)
Reproducibility is excellent: every validation.tex number matches results.rds (gap
slope -2.0438 vs -2.04; bias 0.0058/0.0958; deficit 0/6; gold sweep and gap-scaling
exact). The DGP is marginal-preserving as claimed; the estimator set is appropriate.
The one substantive item is M1: the headline linear-in-r rate is unvalidated
in-paper because the in-paper estimator is r-independent, but the confirming r-sweep
exists in `.research/attempts/003-rsweep-idealized/` and reproduces (L2 slope 1.17,
Linf ~ log r, RMS flat). Porting one panel closes the gap. Minor items: state the
finite-corpus assumption in T4 (m4); caveat the plug-in budgeting; surface the
1/beta_min constant dependence.

### Writing and Presentation (prose-auditor, HIGH confidence)
Tight, well-structured, conference-appropriate; notation consistent; abstract a
faithful precis carrying the honesty caveats inline. Conventions honored (no U+2014,
no vanity counts). The translation table and per-condition C1/C2/C3 readings are
effective. Clarity defects: the c_0 overload reads as two constants (m1); the
five-clause DGP sentence is overloaded (suggestion 4); the repeated
deferral-to-extended-manuscript phrasing reads as a hedge in aggregate (a prose
symptom of M1, resolved by porting the panel). Two cosmetic overfull boxes (m5).

### Citations and References (citation-verifier, HIGH confidence)
Clean: 0 undefined citations (verified against main.aux), 0 broken cross-references,
21 typeset bibitems consistent with 34 citation keys. Load-bearing attributions
(Dawid-Skene, Ratner, Fu, Yu-Ding-Bach, Heitjan-Rubin, Gill et al., van der
Vaart, Wainwright, Varma) are correct. One substantive omission: Allman-Matias-Rhodes
(2009) behind T2 (m2). Four uncited entries and two cosmetic bibtex field warnings
(m6). The self-citation lineage resolves and is used substantively; the phantom
`towell2026weaksupcoarseningextended` is the deferral target flagged in M1.

### Formatting and Production (format-validator, HIGH confidence)
Build clean (exit 0; 0 undefined per the repo grep convention; 0 literal ?? in PDF;
no multiply-defined labels). 22 pages. Both figures present, referenced, placed. The
length-versus-12-page-header inconsistency (F1 = M2) is a venue decision and a
one-line header fix, not a defect. Two cosmetic overfull boxes (m5). The state file
carries two conflicting build blocks to reconcile.

## Literature Context Summary
Programmatic weak supervision's identifiability lineage runs Dawid-Skene (1979) ->
data programming (2016) -> FlyingSquid/triplet (2020), with dependency-structure
learning (Bach 2017; Varma 2019) and the candidate-set sibling Yu-Ding-Bach (2022).
The paper's framing (masked-cause / coarsening-at-random) appears original as a
framing, and T4 (the dependent-case gold budget keyed to rank deficit r and accuracy
margin gap) appears new to the weak-supervision literature; no prior gold-set
sample-complexity result for correlated LFs was located. The cited lineage is
current through 2022. The one concrete literature gap is the foundational
Allman-Matias-Rhodes (2009) latent-class identifiability citation behind T2, which a
theory-venue referee will expect. The WRENCH real-data comparison is absent and
deferred; this is venue-conditional (empirical venues will flag it, theory venues
likely will not).

## Review Metadata
- Agents used (lenses executed directly; Task sub-agent tool unavailable in this
  environment): literature-context (broad + targeted merged), logic-checker,
  novelty-assessor, methodology-auditor, prose-auditor, citation-verifier,
  format-validator.
- Independent numerical verifications performed by the area chair: T1 243-pattern
  symmetry (exact 0); T4 KL = L2 quadratic form (ratio 1.003); cor:agreement-nb
  population formula; full re-read of results.rds against every validation.tex
  number; execution of the deferred r-sweep (`idealized2.R`) confirming all three
  loss-dependent rates.
- Cross-verifications performed: 1 (M1 logic <-> methodology, agreeing the r-rate
  is correct-but-unvalidated-in-paper).
- Disagreements noted: 0.
- Relationship to prior reviews: consistent with 2026-06-04 (also minor-revision).
  M1 and M2 are carried forward; m1/m2/m3/m4/m5 and part of m6 persist unfixed. The
  material change is that the r-sweep evidence to close M1 now demonstrably exists
  in-repo and reproduces, downgrading the fix from "new work" to "port one panel."
