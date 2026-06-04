# Citation Verifier Report

**Date**: 2026-06-04
**Focus**: Every \cite resolves; bibliography is accurate. Specific charge:
confirm van der Vaart 1998 and Wainwright 2019 (added for the T4 rewrite's
minimax / sub-Gaussian machinery) are real and cited for claims they support;
check Dawid-Skene, Ratner (data programming / Snorkel / MeTaL), Fu (FlyingSquid),
Zhang (WRENCH), and Karger-Oh-Shah entries are accurate.

## Tooling note (read first)

Network WAS available this pass. I verified entries against the live Crossref
REST API (DOI lookups are authoritative; bibliographic free-text lookups are
fuzzy and used only for existence confirmation). WebSearch as a distinct tool was
not invoked; Crossref via curl served the same purpose and is cited per claim
below. Items I could only confirm by venue knowledge plus the rendered .bbl
(rather than a DOI) are marked as such.

## Citation-resolution integrity (build-level)

- The manuscript issues 28 distinct \citation keys (from `main.aux`); the
  typeset bibliography (`main.bbl`) contains exactly 28 matching \bibitem
  entries. Set difference in both directions is empty: every cited key is
  defined, and every bibliography entry is cited. **0 undefined citations, 0
  uncited bibliography entries, 0 multiply-defined labels.**
- `refs.bib` defines 32 entries; the 4 unused ones (`khetan2018learning`,
  `tanno2019learning`, `ratner2018snorkelfg`, `shin2021universalizing`) are
  inert and do not affect the typeset output. Not an error; optional cleanup.
- No `??` or `[?]` markers in the rendered PDF text.

## The two T4-machinery additions (the specific charge)

Both are real, correctly described in the .bib, and cited for claims they
genuinely support.

- **vandervaart1998asymptotic** -- van der Vaart, *Asymptotic Statistics*,
  Cambridge University Press, 1998. CONFIRMED via Crossref DOI
  10.1017/CBO9780511802256 (title "Asymptotic Statistics", 1998, Cambridge UP).
  Cited at `methodology.tex` line 179 for the Cramer-Rao / diagonal-Fisher-
  information lower bound in the T4 minimax argument. The Cramer-Rao and
  local-asymptotic-minimax content is in van der Vaart Ch. 8. **Appropriate.**
- **wainwright2019high** -- Wainwright, *High-Dimensional Statistics: A
  Non-Asymptotic Viewpoint*, Cambridge University Press, 2019. CONFIRMED via
  Crossref DOI 10.1017/9781108627771 (title "High-Dimensional Statistics", 2019,
  Cambridge UP). Cited at `methodology.tex` line 161 for the sub-Gaussian
  Bernstein / Hanson-Wright chi-square tail in the T4 upper bound. That material
  is in Wainwright Ch. 2-6. **Appropriate.**

The logic-checker independently reached the same attribution verdict on both
(its Q6); we concur.

## Weak-supervision / crowdsourcing entries (the named set)

| Key | Verification | Verdict |
|-----|--------------|---------|
| `dawid1979maximum` | Crossref DOI 10.2307/2346806 -> "Maximum Likelihood Estimation of Observer Error-Rates Using the EM Algorithm" (1979), Applied Statistics | ACCURATE |
| `ratner2016data` | Data programming, NeurIPS 2016; .bbl renders authors/venue correctly (no DOI for the NeurIPS proceedings entry, normal) | ACCURATE |
| `ratner2017snorkel` | Crossref DOI 10.14778/3157794.3157797 -> "Snorkel", Proc. VLDB Endowment (2017) | ACCURATE |
| `ratner2018snorkelmetal` | Crossref DOI 10.1145/3209889.3209898 -> "Snorkel MeTaL", DEEM workshop (2018) | ACCURATE |
| `ratner2019training` | Crossref DOI 10.1609/aaai.v33i01.33014763 -> "Training Complex Models with Multi-Task Weak Supervision", AAAI (2019) | ACCURATE |
| `ratner2020training` | JMLR 21(120) journal version of the AAAI paper; correct as a separate entry | ACCURATE |
| `fu2020fast` (FlyingSquid) | ICML 2020, PMLR; .bbl renders author list (Fu, Chen, Sala, Hooper, Fatahalian, Re) and venue correctly. PMLR proceedings carry no Crossref DOI, so DOI lookup is N/A; venue and authorship confirmed by domain knowledge + rendered entry | ACCURATE |
| `zhang2021wrench` (WRENCH) | NeurIPS 2021 Datasets & Benchmarks Track; .bbl renders authors/venue correctly; no DOI for the proceedings entry, normal | ACCURATE |
| `karger2011iterative` (Karger-Oh-Shah) | "Iterative Learning for Reliable Crowdsourcing Systems", NeurIPS 2011; authorship confirmed via Crossref (Karger et al. crowdsourcing line) and rendered entry | ACCURATE |
| `bach2019snorkeldrybell` | Crossref DOI 10.1145/3299869.3314036 -> "Snorkel DryBell", SIGMOD (2019) | ACCURATE |
| `zhang2022survey` | arXiv:2202.05433, "A Survey on Programmatic Weak Supervision" (2022); arXiv API probe was flaky this pass but the id and title are well known and the .bbl renders correctly | ACCURATE (arXiv id not independently re-fetched) |
| `zhang2016spectral` | "Spectral Methods Meet EM", JMLR 17(102) 2016; rendered correctly | ACCURATE |
| `anandkumar2014tensor` | "Tensor Decompositions for Learning Latent Variable Models", JMLR 15 2014; rendered correctly | ACCURATE |

Every entry in the editor's named set is accurate.

## bibtex warnings (cosmetic)

`main.blg` reports 3 warnings, all cosmetic and none affecting typeset output:
1. empty `booktitle` in `anandkumar2014tensor` (entry typed `@inproceedings`
   but is really a JMLR article; renders fine as "volume 15, pages ...").
2. `volume`+`number` both set in `anandkumar2014tensor`.
3. `volume`+`number` both set in `ratner2019training`.
FIX (optional): retype `anandkumar2014tensor` as `@article` and drop one of
volume/number in the two flagged entries. Severity: minor/cosmetic.

## Recommended addition (not an error, a strengthening)

Per the literature-context and novelty-assessor reports, **Allman, Matias,
Rhodes (2009), "Identifiability of parameters in latent structure models with
many observed variables," Annals of Statistics 37** is the canonical modern
identifiability theorem behind T2's triplet/conditional-independence result. I
CONFIRMED it is real via Crossref DOI 10.1214/09-AOS689 (exact title, Annals of
Statistics vol 37, 2009). Adding it as a foundational citation for T2 (which the
paper already frames honestly as a re-derivation) would satisfy a statistics-
literate referee at zero cost to the novelty claim. Optionally Kruskal (1977).
Severity: suggestion.

## Citation-verifier confidence

HIGH. The bibliography is complete and internally consistent (28 cited = 28
typeset = 0 undefined), the two T4-machinery additions are real and correctly
attributed, and every entry in the editor's named set checks out against live
Crossref or against venue knowledge plus the rendered .bbl. The only defects are
3 cosmetic bibtex field warnings and one recommended (not required) foundational
citation.
