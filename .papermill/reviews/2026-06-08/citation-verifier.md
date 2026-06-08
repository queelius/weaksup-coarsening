# Citation Verifier Report

**Paper**: Programmatic weak supervision as masked-cause inference
**Date**: 2026-06-08
**Confidence**: HIGH (resolved against main.aux / main.bbl ground truth)

## Citation integrity: CLEAN

- **Undefined citations: 0.** Every `\citation` key in `main.aux` (34 unique) is
  defined in `refs.bib`. `comm -13 defined cited` is empty: no cited-but-undefined
  key exists. The build log shows no "Citation ... undefined" warning.
- **Broken cross-references: 0.** All 22 `\cref`/`\Cref` targets resolve to a
  defined `\label` (37 labels); no `??` appears in the typeset PDF.
- **Bibliography typesets correctly.** 21 `\bibitem`s in `main.bbl` (plainnat only
  emits cited entries), consistent with the 34 `\citation` keys after natbib
  deduplication.

## Attribution accuracy: spot-checked, sound

Load-bearing attributions are correct:
- Dawid-Skene (1979) -> ancestor; correct (JRSS-C 28(1), DOI 10.2307/2346806).
- Ratner et al. (2016) -> data programming, NeurIPS 29; correct.
- Fu et al. (2020) -> triplet method / FlyingSquid, ICML; correct, and T2's
  moment identities are properly credited to it.
- Yu, Ding, Bach (2022) -> candidate-subset gold-free identifiability up to label
  swapping, AISTATS PMLR 151; correct, and the "up to label swapping" scope is
  accurately represented.
- Heitjan-Rubin (1991), Gill-van der Laan-Robins (1997) -> C1-C2-C3 coarsening
  conditions; correct.
- van der Vaart (1998), Wainwright (2019) -> minimax / concentration machinery
  behind T4; appropriate and correctly placed.
- Varma et al. (2019) -> dependency-structure learning; the paper's framing of T4
  as complementary (pricing gold vs recovering the graph) is accurate.

## Findings

### c1. Missing foundational identifiability citation: Allman-Matias-Rhodes (2009) (PERSISTS from prior m2)
**Location**: `sections/identifiability.tex` 91-131 (T2 proof);
`sections/translation.tex` Dawid-Skene paragraph.
**Issue**: T2's conditional-independence identifiability is a special case of the
canonical Allman, Matias, Rhodes (2009, *Annals of Statistics* 37(6), 3099-3132,
DOI 10.1214/09-AOS689) latent-class identifiability theorem, built on Kruskal
(1977) three-way array uniqueness. The paper attributes T2 to
Dawid-Skene / Ratner / Fu, which is honest but incomplete: a statistics-literate
referee at the stated venues (AISTATS, NeurIPS theory, JMLR) will expect the
foundational citation behind the triplet identities.
**Fix**: add Allman-Matias-Rhodes (2009) (DOI verifiable via Crossref) and
optionally Kruskal (1977) to `refs.bib` and cite behind \eqref{eq:id-triplet}.
Zero novelty cost; pure strengthening.

### c2. Four defined-but-uncited bib entries (dead weight, harmless)
`comm -23 defined cited` yields exactly four entries present in `refs.bib` but
never cited in the body:
- `khetan2018learning` (Khetan-Lipton-Anandkumar, ICLR 2018)
- `ratner2018snorkelfg` (Ratner et al., Stanford CS tech report)
- `shin2021universalizing` (Shin et al., ICLR 2022)
- `tanno2019learning` (Tanno et al., CVPR 2019)
These do not appear in the typeset bibliography (plainnat suppresses uncited
entries), so they cause no build defect. They are residue from the prior-art
survey. **Fix (optional)**: either cite them where relevant (khetan2018learning and
tanno2019learning are natural in the crowdsourcing/rater-noise sentence of the
discussion; shin2021universalizing fits the Snorkel-ecosystem list) or delete them
to keep `refs.bib` lean. Lowest priority.

### c3. Cosmetic bibtex field warnings (PERSISTS from prior m6)
**Location**: `refs.bib`. `anandkumar2014tensor` is typed `@inproceedings` but
carries journal-style `volume`/`number` and an empty `booktitle`; it is in fact a
JMLR article. `ratner2019training` sets both `volume` and `number`. These produce
cosmetic bibtex warnings only and do not affect typeset output.
**Fix**: retype `anandkumar2014tensor` as `@article` (JMLR 15(1), 2014); drop one
of volume/number where both are set. Purely hygienic.

## Note on the self-citation lineage

The framework-series self-citations (`towell2026masked`, `towell2026synthesis`,
`towell2026scrnacoarsening`, `towell2026spatialcoarsening`, `towell2026mdrelax`)
resolve and are used substantively (T1/T4 import `towell2026masked`'s apparatus;
T3 is a corollary of `towell2026synthesis`). The CLAUDE.md convention is to cite
these by Zenodo concept DOI; the entries carry version DOIs, which is acceptable
but the repo-level convention prefers concept DOIs so cites track the latest
version. `towell2026weaksupcoarseningextended` is typed "Manuscript in preparation"
with no DOI and is cited as the home of the deferred r-sweep and WRENCH study; see
methodology-auditor M1 for why leaning the headline result on this phantom is a
weak posture.

## Verdict

Citation machinery is clean (0 undefined, 0 broken). The one substantive item is
the persisting Allman-Matias-Rhodes (2009) omission behind T2, which a referee
will expect. The four uncited entries and the two bibtex field warnings are
hygiene, not defects.
