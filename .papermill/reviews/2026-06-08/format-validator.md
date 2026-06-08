# Format Validator Report

**Paper**: Programmatic weak supervision as masked-cause inference
**Date**: 2026-06-08
**Confidence**: HIGH (clean rebuild from source)

## Build: CLEAN

`make paper` (full pdflatex; bibtex; pdflatex; pdflatex) exits 0 from a clean
state. Verification per the repo convention:

- `LC_ALL=C grep -ai undefined main.log | grep -vi "font shape" | wc -l` = **0**.
  No undefined references, no undefined citations, no undefined control sequences.
  (No "Font shape ... undefined" lines were present either; the filter was a
  no-op here.)
- "There were undefined references" / "Citation undefined" warnings: **none**.
- Multiply-defined labels: **none**.
- Literal `??` in the typeset PDF (`pdftotext`): **0**.
- Cross-reference resolution: all 22 cref/Cref targets map to defined labels (37);
  see citation-verifier.

## Page count

The clean build is **22 pages** (`pdfinfo`). The state file's last `build` block
records 18; the prior 2026-06-04 review recorded 20. The growth (18 -> 20 -> 22)
tracks the prior-review fixes and the added synthesis/seam material. Note also
that the state file's *first* `build` block reports 16 and a 12-page target, while
a *second* `build` block lower in the same file reports 18; the file has two
conflicting build blocks (a YAML duplicate-key situation), which should be
reconciled when the state file is next updated.

## F1. Length versus the stated 12-page target (PERSISTS from prior M2; venue-conditional)
`main.tex` line 3: "Conference-format draft (target: 12 pages incl. references)."
The CLAUDE.md and HANDOFF.md repeat the ~12-page conference target. The build is
22 pages including references.

- If a 12-page conference limit (e.g. AAAI-style) is binding, the paper is roughly
  double and not submittable as-is.
- The state file's ranked venue shortlist tells a different story: AISTATS
  (rank 1, "10 main + appendix unlimited"), NeurIPS (9 main + 10 appendix), ICML
  (9 main + refs), JMLR (no limit). Under the AISTATS/JMLR reading the current
  length is fine (proofs and the three-regime interpretation move to the
  appendix); under a hard 9-main-page NeurIPS/ICML reading, substantial
  compression is needed (the background primer and the three-regime interpretation
  are the natural cut candidates, with detail pushed to the cited extended
  manuscript).

**This is a venue decision, not a defect.** The recommendation: reconcile the
header comment with the actual target venue. The "12 pages" header is now
inconsistent with both the build and the state file's own shortlist, so at minimum
the header should be corrected to match whichever venue is chosen. Carried as the
one Major because, if the 12-page figure is real for some target, it is blocking.

## F2. Two trivial overfull hboxes (cosmetic; shared with prose-auditor)
- 6.62pt too wide, `sections/methodology.tex` lines 206-215 (near `rmk:l2-loss`).
  Mildly visible; a `\\` or minor rephrase clears it.
- 0.75pt too wide, `sections/translation.tex` lines 113-117. Below visual notice.
These are the same two boxes the prior review flagged; neither affects
readability. No underfull-vbox or float-placement warnings of concern.

## Production hygiene

- Figures: both `identifiability_recovery.pdf` and `goldset_complexity.pdf` are
  present, referenced, and placed; figure environments use `[t]`; captions match
  the panels.
- Hyperref: only cosmetic PDF-metadata warnings (do not affect typeset output).
- Theorem environments, cleveref names, and the `imsart`-independent `article`
  class all compile without class-level warnings.
- Conventions: no U+2014 (verified across main.tex, sections, refs.bib); no vanity
  counts in body; author block correct (Alexander Towell, SIUE, ORCID
  0000-0001-6443-9897).

## Verdict

Build is clean and submission-grade in production terms. The only format-side item
of consequence is the length-versus-stated-target inconsistency (F1), which is a
venue decision and a one-line header correction, not a build defect. The two
overfull boxes are cosmetic.
