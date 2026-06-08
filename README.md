# weaksup-coarsening

Paper: **Programmatic weak supervision as masked-cause inference: identifiability of label models without gold data.**

Conference-format draft (target ~12 pages including references).

## Overview

Programmatic weak supervision (data programming, Snorkel) trains
classifiers from multiple noisy labeling functions (LFs) instead of
hand-labeled data. The central question, when the true labels can be
recovered from LF votes alone, is the masked-data identifiability
problem from reliability statistics: the true label is the latent
cause, the labels consistent with the LF votes are the candidate set,
an LF abstention is a non-informative candidate set, a confident vote
is a narrowed candidate set, and a gold-labeled example is a singleton
candidate set.

This is the fourth application of the masked-cause framework, after
series-system reliability (`papers/masked-causes-in-series-systems/`),
scRNA-seq zero inflation (`papers/scrna-coarsening/`), and
spatial-transcriptomics deconvolution (`papers/spatial-coarsening/`).

## Build

```bash
make paper      # produces main.pdf
make clean
```

Requires LaTeX with `natbib` and `cleveref`.

## Simulation

```bash
make sim        # runs scripts/run.R, writes results.rds
make figures    # runs scripts/figures.R, writes figures/*.pdf
Rscript scripts/run.R     # direct invocation
```

The simulation is base R only (no external packages).

## Structure

- `main.tex`: top-level with preamble + section includes
- `sections/`: 8 section files, designed for ~12 pages total
  - `introduction.tex`
  - `background.tex` (masked-cause primer)
  - `translation.tex` (the bridge + translation table)
  - `identifiability.tex` (T1 glass ceiling, T2 conditional
    independence, T3 agreement consistency)
  - `methodology.tex` (T4 gold-set sample complexity)
  - `validation.tex` (simulation results)
  - `discussion.tex` (prior-art positioning, limitations)
  - `conclusion.tex`
- `refs.bib`: bibliography
- `figures/`: generated PDF figures
- `scripts/`: `sim.R` (DGP + estimators + diagnostics), `run.R`
  (four studies, saves `results.rds`), `figures.R`

## Theorems

- T1 (`identifiability.tex`): glass ceiling. Without gold labels and
  without a structural assumption on LF dependence, the LF accuracies
  and class prior are non-identifiable; the obstruction is an exact
  accuracy-complement symmetry.
- T2 (`identifiability.tex`): identifiability under conditional
  independence. Three or more conditionally independent LFs of
  non-degenerate accuracy identify the model from agreement moments.
  Re-derives the Dawid--Skene / data-programming / triplet result.
- T3 (`identifiability.tex`): agreement consistency. The fitted label
  model reproduces empirical pairwise LF agreement rates exactly at an
  interior MLE.
- T4 (`methodology.tex`): gold-set sample complexity. Under LF
  dependence with rank deficit `r`, restoring identifiability needs
  `O(r / gap^2)` gold-labeled examples.

## Status

**Reviewed 2026-06-08 (papermill multi-agent): minor-revision.** No critical issues; all four theorems are sound and reproduce. Top remaining item: port the already-reproducing r-sweep panel (in .research/) into validation.tex as a figure of sample size versus the rank-deficit dimension r.

Initial scaffold (May 2026). All sections have substantive content.
The simulation runs and `validation.tex` reports its actual numbers.
Theorem proofs are sketches that cite the framework series for shared
apparatus. See `HANDOFF.md`.

## Conventions

- **No em-dash characters** (soul plugin hook enforces this).
- LaTeX, not Quarto/RMarkdown.
- Author: Alexander Towell, lex@metafunctor.com, SIUE Department of
  Computer Science.
- Citations: Towell 2026 (manuscript in preparation) for the
  masked-causes, scrna-coarsening, and spatial-coarsening papers.

## Prior-art note

Label-model identifiability is established prior work. Dawid--Skene
(1979) is the foundational EM-for-rater-error-rates paper; data
programming (Ratner 2016) and FlyingSquid (Fu 2020) proved
moment-based identifiability for conditionally independent LFs. This
paper does not claim to invent label-model identifiability. The
contribution is the masked-cause unification, the C1--C2--C3
classification of LF ensembles, the explicit glass-ceiling
construction, and the gold-set sample-complexity theorem for the
dependent case.

## Conference targets

12-page conference venues:
- AAAI / IJCAI (weak supervision, applied ML)
- AISTATS (10 pages + references)
- ICML / NeurIPS (8 pages + references; would need compression)
- UAI (identifiability and probabilistic modeling)
