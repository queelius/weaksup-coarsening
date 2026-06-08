# Hand-off: weaksup-coarsening paper

**Last touched**: 2026-05-21. Initial scaffold v0.1 at `main.pdf`.
Conference-format draft, builds clean (16 pages), em-dash free. The
base-R simulation runs and `validation.tex` reports its actual
numbers.

This is the fourth paper in the masked-cause framework series, after
`~/github/coarsening/papers/masked-causes-in-series-systems/` (foundational),
`~/github/coarsening/papers/scrna-coarsening/` (first application), and
`~/github/coarsening/papers/spatial-coarsening/` (second application, and the
structural template for this repo).

---

## 1. What this paper is

**Working title**: *Programmatic weak supervision as masked-cause
inference: identifiability of label models without gold data.*

**Central claim**: programmatic weak supervision (data programming,
Snorkel) trains classifiers from multiple noisy labeling functions
(LFs) instead of hand-labeled data. The central question, when the
true labels can be recovered from LF votes alone, is the masked-data
identifiability problem from reliability statistics. The true label
is the latent cause; the labels consistent with the LF votes are the
candidate set; an LF abstention is a non-informative (full) candidate
set; a confident LF vote is a narrowed candidate set; a gold-labeled
example is a singleton candidate set. The C1--C2--C3 conditions
classify LF ensembles, and the framework gives the precise conditions
under which a gold-free pipeline is identifiable.

**Why this exists**: the gold-free promise of weak supervision rests
on an identifiability claim that the literature has answered in
pieces (Dawid--Skene EM, data-programming moments, the triplet
method). The masked-cause framework unifies them, classifies LF
ensembles by the coarsening-at-random conditions, and adds a
sample-complexity result for the dependent case.

**Conference target**: 12-page format (AAAI / IJCAI / AISTATS / UAI).
The current draft is 16 pages including references; light compression
or a venue with a slightly higher limit fits it.

---

## 2. Current state

### Paper scaffold (`papers/weaksup-coarsening/`)
- `main.tex`: top-level, same preamble and 11pt/1in format as
  `spatial-coarsening`
- `sections/` (all substantive):
  - `introduction.tex` (motivation + bridge + contributions list)
  - `background.tex` (masked-cause primer, C1--C2--C3)
  - `translation.tex` (bridge + translation table, booktabs)
  - `identifiability.tex` (T1 glass ceiling, T2 conditional
    independence, T3 agreement consistency)
  - `methodology.tex` (T4 gold-set sample complexity)
  - `validation.tex` (simulation results with actual numbers)
  - `discussion.tex` (prior-art positioning, limitations)
  - `conclusion.tex`
- `refs.bib`: foundational coarsening references (Heitjan--Rubin,
  Gill--van der Laan--Robins), the framework series (Towell 2026
  manuscripts), and weak-supervision references (Dawid--Skene 1979,
  Ratner 2016/2017/2019, Fu 2020, Zhang 2021, Karger--Oh--Shah 2011)
- `Makefile`, `README.md`, `CLAUDE.md`
- **Status**: builds clean, 16 pages, em-dash free, no undefined
  references or citations.

### Theorems stated
1. **T1 glass ceiling** (`\cref{thm:glass-ceiling}`): without gold
   labels and without a structural assumption on LF dependence,
   `(accuracies, prior)` are non-identifiable; the obstruction is the
   exact accuracy-complement symmetry `(pi, alpha) <-> (1-pi, 1-alpha)`.
2. **T2 identifiability under conditional independence**
   (`\cref{thm:ci-identifiability}`): three or more conditionally
   independent LFs of non-degenerate accuracy identify the model from
   second- and third-order agreement moments. Re-derives the
   Dawid--Skene / data-programming / triplet result.
3. **T3 agreement consistency** (`\cref{thm:agreement-consistency}`):
   the fitted label model reproduces the empirical pairwise LF
   agreement rates exactly at an interior MLE.
4. **T4 gold-set sample complexity** (`\cref{thm:goldset}`): under LF
   dependence with rank deficit `r`, restoring identifiability needs
   `O(r / gap^2)` gold-labeled examples.

### Simulation (base R, `scripts/`)
- `sim.R`: DGP (binary `Y`, `m` LFs with coverage/accuracy;
  marginal-preserving Gaussian-copula dependence for LF pairs),
  estimators (gold-free triplet method of moments, gold-augmented,
  oracle), diagnostics (recovery accuracy, accuracy RMSE, agreement
  residual, rank-one agreement-fit deficit).
- `run.R`: four studies, one per theorem; saves `results.rds`,
  seed `20260521`.
- `figures.R`: two figures (`identifiability_recovery.pdf`,
  `goldset_complexity.pdf`).

### Simulation results (in `validation.tex`)
- **T1**: the accuracy-complement symmetry is exact: maximum
  difference in vote-pattern probability between the two solutions is
  0 to floating-point precision; both fit the empirical distribution
  equally well (L1 distance 0.0257 each).
- **T2**: gold-free accuracy RMSE falls from 0.046 (n=500) to 0.0044
  (n=50,000), log-log slope -0.53 (root-n); recovery accuracy 0.871
  matches the oracle ceiling 0.872.
- **T3**: gold-free agreement residual 3.0e-3 max at n=5e5, shrinks
  as Monte-Carlo noise over a finite-n sweep.
- **T4**: gold-free accuracy RMSE rises from 0.0058 (independent) to
  0.096 (dependent, rho=0.5); the gold sweep restores RMSE
  monotonically (0.096 -> 0.017 at m_gold=800); m_gold needed scales
  as 1/gap^2 with fitted log-log slope -2.04.

---

## 3. What's left

### Tier 1: needed for submission
- [ ] **Sibling Zenodo deposit (user-action)**. Deposit each of the
  five sibling papers (`masked-causes-in-series-systems`,
  `scrna-coarsening`, `spatial-coarsening`, `dp-coarsening`,
  `weaksup-coarsening`, `phenotype-coarsening`) to Zenodo with
  versioned DOIs. Once DOIs are issued, update each sibling's bib
  entry across all five papers (replace `journal = {Manuscript in
  preparation}` with the Zenodo `doi` and `url` fields). This is a
  user-action: requires Zenodo authentication and metadata choice.
- [ ] **Tighter theorem proofs**. Current proofs are sketches that
  cite the framework series for shared apparatus. T1 (the
  accuracy-complement construction) and T4 (the concentration
  argument) should be self-contained in an appendix.
- [ ] **Real-data study on WRENCH** (Zhang et al. 2021): run the
  gold-free and gold-augmented label models on real LF-vote matrices,
  compare against Snorkel and FlyingSquid. `validation.tex` currently
  states this is left to the longer manuscript.
- [ ] **Page budget**: 16 pages now; trim or pick a venue limit
  that fits.

### Tier 2: would strengthen
- [ ] **Multiclass theorems**. The framework extends to a categorical
  latent cause directly (Dawid--Skene is natively multiclass); write
  out the multiclass T1--T4 statements.
- [ ] **Isolate the linear-in-r factor of T4 empirically**. The
  current gold-augmented estimator measures marginal accuracies
  directly, so its budget is gap-dominated; an estimator that also
  reconstructs the dependence structure would expose the `r` factor.
  `validation.tex` reports this honestly as a known limitation.
- [ ] **Data-driven dependency-graph recovery**: T4 assumes `r` is a
  property of the ensemble but `r` is estimated.

### Tier 3: polish
- [ ] Conceptual figure of the bridge (LF votes -> candidate set).
- [ ] A C1-violation detection diagnostic (confidently-wrong LFs).

---

## 4. Companion repos and the citation pattern

`~/github/coarsening/papers/spatial-coarsening/` is the structural template:
same preamble, same Makefile targets, same 8-section breakdown, same
README/CLAUDE/HANDOFF format. `~/github/coarsening/papers/scrna-coarsening/` is
the prose-voice reference (how C1/C2/C3 are framed, how the
glass-ceiling and cell-total-consistency theorems are written).

The framework is shared, so several theorems cite the series rather
than re-deriving:
- T2 cites the triplet identifiability of `fu2020fast` and the
  masked-cause identifiability of `towell2026masked`.
- T3 (agreement consistency) parallels the cell-total-consistency
  proof of `towell2026scrnacoarsening` Section 3.
- T4's concentration apparatus cites `towell2026masked` Section 7 and
  the singleton-restores-rank results of the scrna and spatial
  papers.

Keep this citation pattern when expanding.

---

## 5. Prior-art honesty (do not regress on this)

Label-model identifiability is established prior work. Dawid--Skene
(1979) is the clear ancestor; data programming (Ratner 2016) and
FlyingSquid (Fu 2020) proved moment-based identifiability for
conditionally independent LFs. The paper does NOT claim to invent
label-model identifiability. `discussion.tex` has a dedicated
subsection ("Relation to prior work on label-model identifiability")
that names Dawid--Skene as the ancestor and states the four-part
contribution narrowly: the masked-cause unification, the C1--C2--C3
classification, the explicit glass-ceiling construction, and the
gold-set sample-complexity theorem for the dependent case. Any
expansion must preserve this framing.

---

## 6. Conventions

- **No em-dashes** anywhere (soul plugin hook).
- **No vanity counts** in the writeup (state the work, not the page
  or reference count; also enforced by the soul hook).
- LaTeX, not Quarto/RMarkdown.
- Author: Alexander Towell, lex@metafunctor.com, SIUE Department of
  Computer Science, ORCID 0000-0001-6443-9897.
- Citations: Towell 2026 manuscripts in preparation for
  masked-causes, mdrelax, scrna-coarsening, spatial-coarsening.

---

## 7. Quick-start commands

```bash
# Build the paper
cd ~/github/coarsening/papers/weaksup-coarsening
make paper

# Run the simulation
Rscript scripts/run.R       # writes results.rds
Rscript scripts/figures.R   # writes figures/*.pdf
```

---

## 8. Status checklist

- [x] Scaffold: substantive sections in all parts, builds clean
- [x] Theorem statements (T1 glass ceiling, T2 conditional
  independence, T3 agreement consistency, T4 gold-set complexity)
- [x] References for primary citations
- [x] Simulation code (base R) and an actual run
- [x] `validation.tex` reports the actual simulation numbers
- [x] Two figures generated
- [ ] Theorem proofs (currently sketches)
- [ ] Real-data WRENCH study
- [ ] Comparison with Snorkel / FlyingSquid
- [ ] Multiclass theorems
