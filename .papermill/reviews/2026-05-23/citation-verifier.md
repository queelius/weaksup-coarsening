# Citation Verification

## Bibliography size and use

refs.bib has 29 entries. In-text cite calls in the section files: 66 occurrences (excluding bibstyle / bibliography lines).

## Cited entries (used in text)

Foundational coarsening references:
- heitjan1991ignorability: used in introduction, background.
- gill1997coarsening: used in introduction, background.

Framework series (Towell 2026):
- towell2026masked: used in background, identifiability, methodology, discussion (foundational citation, multiple appearances). CORRECT.
- towell2026mdrelax: used in discussion, conclusion. CORRECT.
- towell2026scrnacoarsening: used in background, identifiability, methodology, discussion. CORRECT.
- towell2026spatialcoarsening: used in background, methodology, discussion. CORRECT.
- towell2026dpcoarsening: used in introduction, discussion. CORRECT.
- towell2026phenotypecoarsening: used in introduction, discussion. CORRECT.
- towell2026weaksupcoarsening: used in validation. SELF-REFERENCE to "the longer manuscript" of THIS paper, which is a circular cite. The intent appears to be "the journal version of this paper"; the cite key is misleading because it has the same title as the current paper. Recommend changing the entry to title "Programmatic weak supervision as masked-cause inference: identifiability of label models without gold data (extended version)" or similar to make the relationship clear.

Programmatic weak supervision and crowdsourcing:
- dawid1979maximum: used in introduction, translation, identifiability, discussion, conclusion. CORRECT.
- ratner2016data: used in introduction, translation, identifiability, discussion. CORRECT.
- ratner2017snorkel: used in introduction, translation, validation. CORRECT.
- ratner2019training: used in introduction, translation, discussion. CORRECT.
- fu2020fast: used in introduction, translation, identifiability, validation, discussion. CORRECT.
- zhang2021wrench: used in validation. CORRECT.
- karger2011iterative: used in translation, discussion. CORRECT.
- bach2017learning: used in discussion. CORRECT.
- varma2019snorkeldrybell: used in discussion. CITE-KEY MISLEADING: the entry's first author is Bach, not Varma. The Snorkel DryBell paper from SIGMOD 2019 is indeed first-authored by Bach. Recommend renaming the cite key to bach2019snorkeldrybell to match authorship.
- ratner2018snorkelmetal: used in discussion. CORRECT.
- sala2019multiresolution: used in discussion. CORRECT.
- zhang2022survey: used in discussion. CORRECT.
- ratner2020training: used in discussion. CORRECT (the JMLR version of ratner2019training, both cited together).
- zhang2016spectral: used in discussion. CORRECT.
- anandkumar2014tensor: used in discussion. CORRECT.
- boecking2021interactive: used in discussion. CORRECT.

## Uncited entries (in refs.bib but not in text)

- khetan2018learning (Khetan-Lipton-Anandkumar 2018 ICLR on noisy singly-labeled). UNCITED.
- tanno2019learning (Tanno et al. 2019 CVPR on regularized annotator confusion). UNCITED.
- ratner2018snorkelfg (Ratner et al. 2018 Stanford Tech Report on factor graphs). UNCITED.
- shin2021universalizing (Shin et al. 2022 ICLR on universalizing weak supervision). UNCITED.

These four are candidates for either removal or use. shin2021universalizing is the most natural to add: it generalizes the moment-method label-model framework, fitting the paper's discussion section.

Note: natbib does NOT flag uncited entries as errors, so the build is clean. But a reviewer scanning the bib file may wonder why these are present.

## Citation key naming consistency

Mostly consistent ({firstauthor}{year}{shortid} pattern). Two anomalies:
- varma2019snorkeldrybell: see above; should be bach2019snorkeldrybell.
- ratner2020training: this is the JMLR version of ratner2019training (which is the AAAI version). Both are by the same author group with the same title. Citing both alongside each other (discussion line 36: "the multi-task extension {ratner2019training,ratner2020training}") is appropriate but somewhat redundant. A combined "{ratner2019training}" with a journal-version note would suffice.

## Year and venue accuracy spot checks

- dawid1979maximum, JRSS C 1979: CORRECT (DOI 10.2307/2346806).
- ratner2016data, NeurIPS 2016 vol 29 pages 3567-3575: VERIFIED (the data programming NeurIPS paper).
- ratner2017snorkel, VLDB 2017 volume 11 number 3 pages 269-282 DOI 10.14778/3157794.3157797: VERIFIED. Note: ratner2017 was actually published in VLDB 2018 (Proceedings of the VLDB Endowment volume 11 number 3 for the November 2017 issue). The "year 2017" is the canonical attribution. Acceptable.
- fu2020fast, ICML 2020 pages 3280-3291: VERIFIED.
- zhang2021wrench, NeurIPS 2021 Datasets and Benchmarks: VERIFIED.
- karger2011iterative, NeurIPS 2011 volume 24 pages 1953-1961: VERIFIED.
- ratner2019training, AAAI 2019 volume 33: VERIFIED.
- bach2017learning, ICML 2017 pages 273-282: VERIFIED.
- heitjan1991ignorability, Annals of Statistics 1991: VERIFIED.
- gill1997coarsening, Seattle Symposium 1997: VERIFIED.
- anandkumar2014tensor, JMLR 2014 volume 15: VERIFIED.

The Towell 2026 manuscripts are in preparation and cannot be externally verified; the cite entries are placeholder entries which is acceptable for a framework series in preparation.

## Missing references that could strengthen the paper

The paper does not cite any of the following, all of which are relevant:

1. Khetan, Lipton, Anandkumar 2018 ICLR (already in bib but uncited) on sample complexity for noisy singly-labeled. Worth a sentence in the discussion as the singly-labeled-regime cousin of the weak-supervision sample complexity.

2. Halpern, Horng, Sontag 2016 (and follow-ups) on anchor-words and the identifiability of latent-class crowdsourcing models. Closely related to T2 / T3.

3. Joglekar, Garcia-Molina, Parameswaran 2013 on confidence intervals for crowd workers. Sample-complexity-flavored, parallels T4.

4. Shin et al. 2022 ICLR (already in bib but uncited) on universalizing weak supervision: generalizes Snorkel beyond classification. Worth a discussion sentence as a generalization extension that the masked-cause framework should subsume.

5. Yu, Liang, Re 2024 (or similar recent work) on weak-supervision sample complexity. Worth checking for any direct competitor to T4. (Scout's note: no direct competitor in the recent literature to the scouts' knowledge.)

These are SUGGESTIONS not blockers. The current bibliography is adequate for the paper's contribution scope.

## Self-citation density

The Towell 2026 framework series accounts for 6 of 29 bib entries (21%) and a substantial fraction of in-text cite-calls. As noted in the novelty assessor, this reads as advertising for a conference draft. Either consolidate the framework-series mentions or move them to a footnote.

## Summary

- Bibliography is well-curated; 25 of 29 entries are cited; 4 uncited entries can be either incorporated or removed.
- One cite-key naming inconsistency (varma2019snorkeldrybell should be bach2019snorkeldrybell).
- One self-circular reference (towell2026weaksupcoarsening cited as "the longer manuscript" within the paper of the same title; clarify).
- Spot-checked venue and year metadata is accurate.
- Suggested additions (Khetan/Lipton, Halpern/Sontag, Shin et al.) are not blockers but would strengthen the discussion.
