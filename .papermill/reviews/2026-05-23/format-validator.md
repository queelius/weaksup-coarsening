# Format and Build Validation

## Build status

The LaTeX build is clean. main.pdf is 18 pages (379536 bytes). main.log reports:
- Output written on main.pdf (18 pages, 379536 bytes)
- One Overfull \hbox (0.75pt too wide) in introduction paragraph lines 111-115 (cosmetic; below typical reviewer detection threshold).
- Four hyperref "Token not allowed in a PDF string (Unicode)" warnings (cosmetic; PDF metadata only).
- No undefined references.
- No undefined citations.
- No missing labels.

## Class file and packages

Document class: article 11pt letterpaper. Packages: amsmath, amsthm, amssymb, mathtools, bm, graphicx, float, booktabs, enumitem with shortlabels option, geometry with 1in margin, microtype, hyperref with colorlinks, natbib, cleveref.

These are all standard. No deprecated package usage. natbib is the right choice for the plainnat bibliographystyle.

Theorem environments: theorem, proposition, lemma, corollary (plain style); definition, condition (definition style); remark (remark style). All shared counter under theorem. cleveref names registered for condition. Clean.

## Venue-format readiness

The paper currently uses article 11pt with 1in margins. Target venue formats:

- AISTATS: typically requires aistats2026.sty (or yearly variant) with 10-page main + appendix budget. The current article-class draft will need a class-file swap and rerun.
- NeurIPS / ICML: NeurIPS uses neurips_2025.sty (or yearly); ICML uses icml2026.sty. 9 main + references + appendix budget. Class swap needed.
- VLDB: uses acmart class with sigmodconf option. Different formatting; requires non-trivial conversion.
- JMLR: jmlr2e.sty; no page limit.

None of the venue-specific class files are present in the repo. For AISTATS as the primary target, recommend adding aistats2026.sty (when released) and producing an aistats-formatted variant.

## Figure and table integrity

Two figures, both PDF, both in figures/:
- identifiability_recovery.pdf: cited as fig:identifiability in validation.tex. CORRECT.
- goldset_complexity.pdf: cited as fig:goldset in validation.tex. CORRECT.

One table:
- tab:translation in translation.tex. Centered, small font, p{0.56\linewidth} column for the long text. Correctly captioned and labeled.

## Label and cross-reference integrity

All \cref and \Cref calls resolve. Spot checks:
- thm:bg-id (background) referenced in identifiability.tex and methodology.tex.
- thm:glass-ceiling, thm:ci-identifiability, thm:agreement-consistency, thm:goldset all defined and referenced.
- sec:translation, sec:identifiability, sec:methodology, sec:validation, sec:discussion, sec:conclusion all defined and referenced.
- cond:c1, cond:c2, cond:c3 defined and referenced.
- eq:bg-joint, eq:bg-c1c2c3, eq:id-jointvote, eq:id-triplet, eq:id-solve, eq:agreement, eq:meth-decomp, eq:meth-gap, eq:goldset-bound all referenced.
- fig:identifiability, fig:goldset both referenced.

No dangling cross-references.

## Bibliography format

bibliographystyle plainnat. refs.bib uses standard BibTeX entries with curly-brace protection for technical terms (Snorkel, FlyingSquid, MeTaL, DryBell, etc.). Author names are correctly diacritic-encoded ({R\'e} for Re, etc.).

## Em-dash audit

No U+2014 em-dashes detected in any .tex file. All double-hyphens (--) are LaTeX en-dashes for ranges or compound terms (e.g., "Dawid--Skene", "C1--C2--C3", "log--log"). This is conventional and intentional.

## Vanity counts

The state file flagged a "16 pages" mention in HANDOFF.md and CLAUDE.md; the paper itself (the .tex files) does not use page counts as filler. The README.md is internal documentation and is not part of the camera-ready paper.

## hyperref warnings

Four "Token not allowed in a PDF string (Unicode)" warnings from hyperref. These come from \cref or theorem-name rendering inside PDF bookmarks or metadata. They are cosmetic and do not affect the typeset paper. They would be fixed by adding \texorpdfstring{...}{...} wrappers around math in headings, but this is low-priority polish.

## Margin and spacing

1in margins is standard for an article-class draft. AISTATS/NeurIPS/ICML class files will override the margins to their venue-specific values.

The 0.75pt overfull hbox at lines 111-115 of introduction.tex is in the bridge subsection paragraph. Inspection shows the paragraph contains a long "labeling function" hyphenation that microtype could not optimize away. Recommendation: hyphenate "label" + "ing" or rephrase a sentence. Cosmetic only.

## Reproducibility artifacts in repo

- Makefile: present, with paper, sim, figures, clean targets. Verified by README and CLAUDE.md.
- scripts/sim.R, scripts/run.R, scripts/figures.R: present.
- results.rds: present (output of last simulation run, seed 20260521).
- figures/identifiability_recovery.pdf, figures/goldset_complexity.pdf: present.

All build and simulation artifacts are reproducible from the repo.

## Summary

- Build clean at 18 pages with one cosmetic overfull hbox.
- All cross-references and citations resolve.
- Bibliography format clean.
- Em-dash and vanity-count conventions held.
- Venue-format class file swap needed before AISTATS / NeurIPS / ICML / VLDB / JMLR submission.
- Hyperref PDF-metadata warnings are cosmetic.
