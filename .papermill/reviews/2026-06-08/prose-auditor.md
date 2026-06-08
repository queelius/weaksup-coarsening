# Prose Auditor Report

**Paper**: Programmatic weak supervision as masked-cause inference
**Date**: 2026-06-08
**Confidence**: HIGH

## Overall

The writing is tight, well-organized, and conference-appropriate. The narrative
arc is clean: bottleneck -> identifiability question -> masked-cause bridge ->
four theorems -> simulation -> honest limitations. The eight-section structure
(intro, background primer, translation, identifiability, methodology, validation,
discussion, conclusion) maps one-to-one onto the logical development. Notation is
consistent across sections: alpha (accuracy), beta (coverage), pi (prior), a_j =
2 alpha_j - 1 (margin), sigma (centered vote), r (degeneracy dimension), gap. The
abstract is a faithful, complete precis of the contribution and even encodes the
honesty caveat (linear-in-r "proved but not yet exercised by an r-sweep") and the
prior-art attribution inline.

The prose honors the enforced conventions: no U+2014 em-dashes anywhere
(verified), no vanity counts in the body, author identity correct.

## Strengths

- The translation table (`tab:translation`) is an effective single-glance map
  from masked-data to weak-supervision vocabulary, including the augmented
  candidate-set matrix row added in a prior revision.
- The per-condition C1/C2/C3 readings (`translation.tex` 100-119) are concrete and
  give checkable LF-level statements rather than abstractions.
- The "What this paper adds" paragraph (`discussion.tex` 69-94) is a model of
  honest contribution delineation.
- The three-regime interpretation (`methodology.tex` 258-310) translates the bound
  into practitioner guidance well.
- T3's exactness seam is explained in plain language (a model can match every
  agreement rate and still carry biased accuracies), which is the right intuition.

## Findings

### p1. c_0 reads as two different constants in the T4 proof (PERSISTS from prior m1; shared with logic-checker)
`sections/methodology.tex`: c_0 is the success-tolerance constant at lines 91/102,
then the per-coordinate variance floor at line 172, and the conversion at line 182
"(c_0/c_0^2)" visibly uses the same symbol for both. Even granting the arithmetic
is correct, a reader hits a symbol that means two things within one proof. This is
a clarity defect independent of the math. **Fix**: rename the tolerance constant
(c_tol) at lines 91/102/164/181-182/217/235. Same underlying defect the
logic-checker flags from the correctness side.

### p2. The marginal-preserving-DGP sentence in validation is overloaded (PERSISTS, prior suggestion 3)
`sections/validation.tex` 24-31 is one sentence carrying five clauses (the
construction breaks rank-one structure; cites the remark; the proof uses only
marginals; lists three dependence mechanisms; the slope confirms it). It parses,
but it is the densest sentence in the paper. **Fix**: split after "what a
gold-labeled example observes" so the mechanism list starts a fresh sentence.

### p3. The deferral-to-extended-manuscript phrasing recurs and reads as a hedge
The phrase "deferred to / supplied by the longer manuscript
\citep{towell2026weaksupcoarseningextended}" appears in `validation.tex` (twice),
`methodology.tex`, and the WRENCH sentence. Repeated deferral of the headline
empirical confirmation to an unpublished manuscript reads, in aggregate, as a
hedge around the paper's main claim. This is partly a content issue (see
methodology-auditor M1: the r-sweep evidence exists in-repo and could be ported)
and partly prose: if the panel is ported, the validation.tex deferral phrasings
collapse into one forward-reference for WRENCH only, which reads far cleaner.

### p4. "load-bearing external contribution" appears in two places with slightly different scope
`main.tex` abstract line 97 ("the dependent-case bound is the load-bearing
external contribution") and `methodology.tex` 312 ("This dependent-case budget is
the load-bearing external contribution of the paper relative to the candidate-set
and weak-supervision literature"). Both are fine; the abstract version is terse
enough to be slightly cryptic on first read ("external" to what?). Minor; consider
"the load-bearing new contribution relative to prior weak-supervision work" in the
abstract for self-containedness.

### p5. Two trivial overfull hboxes (cosmetic; shared with format-validator)
6.6pt near `rmk:l2-loss` (`methodology.tex` 206-215) and 0.75pt in `translation.tex`
113-117. The first is mildly visible; a `\\` or minor rephrase clears it. The
second is below notice.

## Notation/consistency audit: clean

No undefined symbols on first use; theorem/corollary cross-references all resolve
(cleveref, 0 broken); figure callouts (Fig A/B panels) match the captions; the
interior-MLE definition is given parenthetically in T3 as the prior review
requested. No notation collisions other than the c_0 overload above.

## Verdict

Presentation is strong and submission-quality in structure and style. The one
clarity defect that matters is the persisting c_0 overload (flagged twice now,
trivial to fix). The recurring deferral phrasing is a prose symptom of the
underlying evidentiary gap (the r-sweep), and porting that panel would clean up
both at once.
