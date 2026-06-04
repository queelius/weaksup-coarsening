---
schema_version: 1
paper:
  title: "Programmatic weak supervision as masked-cause inference: identifiability of label models without gold data"
  short_title: "Weaksup coarsening"
  paper_type: theory-with-simulation
  stage: v0.2-post-review
  series: masked-data coarsening framework (paper 4 of 5)
  series_siblings:
    - scrna-coarsening (zero inflation; precursor application)
    - spatial-coarsening (cell-type deconvolution)
    - dp-coarsening (differential privacy)
    - phenotype-coarsening (EHR phenotyping)
authors:
  - name: Alexander Towell
    email: lex@metafunctor.com
    orcid: 0000-0001-6443-9897
    affiliation: Department of Computer Science, Southern Illinois University Edwardsville
    corresponding: true
target_venues:
  ranked_shortlist:
    - rank: 1
      venue: AISTATS
      fit_score: 9/10
      rationale: "Best fit. Identifiability under moment-method estimators, masked-data, and unification across statistical-learning settings are all squarely in AISTATS scope. Page limit (10+refs+appendix) accommodates current 16-page draft with no compression. Audience already familiar with EM, mixture models, and identifiability."
      page_budget: 10 main + appendix unlimited
      review_timeline: "October submit, February decision (annual)"
      acceptance_rate: ~32%
    - rank: 2
      venue: NeurIPS
      fit_score: 8/10
      rationale: "Theory track is a strong fit for the four theorems and the masked-cause unification. Snorkel/data-programming papers (Ratner et al.) historically appeared at NeurIPS. The sample-complexity bound (T4) is a clean NeurIPS-style result."
      page_budget: 9 main + 10 references/appendix
      review_timeline: "May submit, September decision"
      acceptance_rate: ~26%
      caveat: "Conference draft compression: trim to ~9 main pages."
    - rank: 3
      venue: ICML
      fit_score: 8/10
      rationale: "Same fit profile as NeurIPS. Triplet method (Fu 2020), Snorkel multi-task originated at ICML / its workshops. The dependent-case sample complexity is novel theory."
      page_budget: 9 main + references
      review_timeline: "January submit, May decision"
      acceptance_rate: ~28%
    - rank: 4
      venue: JMLR
      fit_score: 9/10 (long form)
      rationale: "Journal venue with no page limit; ideal for fully-self-contained proofs of T1 and T4. Slower review (~6-12 months). Best target after a conference attempt or for an extended version with multiclass theorems."
      page_budget: "no limit"
      review_timeline: "rolling, 6-12 months"
  secondary:
    - VLDB (data programming and Snorkel originated here; engineering audience; less theoretical)
    - KDD (applied weak supervision audience; would benefit from real-data WRENCH study)
    - AAAI (broad AI venue; multiclass extension would strengthen fit; 7-page limit tight)
    - UAI (probabilistic modeling community; good fit for the identifiability framing)
  submission_strategy:
    primary_attempt: "AISTATS (best fit and most generous page budget for the current draft)"
    backup_if_rejected: "NeurIPS or ICML next cycle with compression to 9 main pages"
    long_form: "JMLR after multiclass extension and WRENCH study are added"
  open_questions:
    - "Is a real-data WRENCH study required for top-tier acceptance? The current draft is honest about its absence; reviewers may flag it for empirical venues (KDD/VLDB) but theoretical venues (AISTATS/NeurIPS theory track) may accept the simulation-only validation."
  notes: "Conference-format draft (currently 16 pages incl. references)."
thesis:
  central_claim: "Programmatic weak supervision (data programming, Snorkel) is an instance of masked-cause inference. The true label is the latent cause, LF votes form a candidate structure, an abstention is a non-informative candidate set, and a gold example is a singleton candidate set. Without gold and without a structural assumption on LF dependence, the label model is non-identifiable. The gold-set sample complexity to restore identifiability under LF dependence is O(r / gap^2), where r is the dependence rank deficit and gap is the accuracy margin."
  one_sentence_thesis: "Programmatic weak supervision is masked-cause inference, and that framing produces a glass-ceiling obstruction (accuracy-complement symmetry), a re-derivation of the conditionally-independent identifiability result, and a new O(r/gap^2) gold-set sample-complexity bound for the dependent case."
  novelty_boundary:
    - "Novel: masked-cause unification of label-model estimation with reliability identifiability"
    - "Novel: C1-C2-C3 taxonomy applied to LF ensembles, with each condition translated to a checkable LF property"
    - "Novel: explicit accuracy-complement symmetry construction (T1), making the gold-free obstruction precise rather than folklore"
    - "Novel: T4 sample-complexity bound for the dependent case, with empirical confirmation (log-log slope -2.04)"
    - "NOT novel: identifiability under conditional independence (Dawid-Skene 1979; Ratner 2016; Fu 2020). T2 is a re-derivation in masked-cause language."
    - "NOT novel: agreement-matching diagnostics (folklore in EM literature). T3 is the masked-cause statement of this fact."
  contributions:
    - "Bridge from programmatic weak supervision to masked-cause inference; LF votes as candidate-set coarsening"
    - "C1-C2-C3 classification of LF ensembles in coarsening-at-random terms"
    - "T1 glass ceiling: explicit accuracy-complement symmetry showing gold-free non-identifiability"
    - "T2 identifiability under conditional independence: re-derivation of Dawid-Skene / data-programming / triplet result"
    - "T3 agreement consistency: fitted model reproduces empirical pairwise LF agreement at interior MLE"
    - "T4 gold-set sample complexity: O(r/gap^2) bound for the dependent case (the genuinely new result)"
    - "Base-R simulation validating all four theorems; the log-log slope -2.04 matches the 1/gap^2 prediction"
prior_art:
  ancestor: "Dawid-Skene (1979) Maximum Likelihood Estimation of Observer Error Rates Using EM"
  established_results:
    - "Ratner et al. 2016: data programming, moment-based identifiability under conditional independence"
    - "Fu et al. 2020: triplet method, closed-form recovery from third-order moments"
    - "Ratner et al. 2019: Snorkel DryBell, multi-task with known dependency graph"
    - "Karger-Oh-Shah 2011: iterative learning for reliable crowdsourcing"
  honesty_note: "We do NOT claim to invent label-model identifiability. The contribution is narrower: the masked-cause unification, the C1-C2-C3 classification, the explicit glass-ceiling construction, and the gold-set sample-complexity theorem for the dependent case."
  candidates_to_survey:
    - Bach et al. on data programming (LF dependency learning, label-model variants)
    - Varma and Re on Snorkel DryBell deployment paper
    - Ratner, De Sa, Wu, et al. theoretical analysis of data programming
    - Khetan, Lipton, Anandkumar on learning from noisy singly-labeled
    - Tanno et al. on rater noise (neural)
    - Wang and Poon on weak supervision survey
    - Robinson et al. on flying squid extensions
build:
  paper_command: "make paper"
  simulation_command: "Rscript scripts/run.R"
  figures_command: "Rscript scripts/figures.R"
  current_pdf_pages: 16
  current_build_status: "clean; only hyperref PDF metadata warnings (cosmetic, do not affect typeset output)"
  simulation_status: "results.rds present; reproducible with seed 20260521"
files:
  main: main.tex
  sections:
    - sections/introduction.tex
    - sections/background.tex
    - sections/translation.tex
    - sections/identifiability.tex
    - sections/methodology.tex
    - sections/validation.tex
    - sections/discussion.tex
    - sections/conclusion.tex
  bibliography: refs.bib
  figures:
    - figures/identifiability_recovery.pdf
    - figures/goldset_complexity.pdf
  scripts:
    - scripts/sim.R
    - scripts/run.R
    - scripts/figures.R
theorems:
  - id: T1
    name: glass-ceiling
    label: thm:glass-ceiling
    location: sections/identifiability.tex
    status: proof sketch (cites towell2026masked Theorem 8)
    needs: self-contained appendix proof recommended
  - id: T2
    name: conditional-independence-identifiability
    label: thm:ci-identifiability
    location: sections/identifiability.tex
    status: proof sketch (re-derives Fu 2020 triplet result)
    needs: clear positioning as re-derivation
  - id: T3
    name: agreement-consistency
    label: thm:agreement-consistency
    location: sections/identifiability.tex
    status: proof sketch (cites towell2026scrnacoarsening Section 3)
  - id: T4
    name: gold-set-sample-complexity
    label: thm:goldset
    location: sections/methodology.tex
    status: proof sketch (cites towell2026masked Section 7)
    needs: self-contained appendix proof recommended (this is the genuinely new result)
simulation:
  empirical_validations:
    - T1: accuracy-complement symmetry exact to floating-point precision
    - T2: gold-free RMSE 0.046 (n=500) -> 0.0044 (n=50000); log-log slope -0.53; recovery accuracy 0.871 vs oracle 0.872
    - T3: gold-free agreement residual max 3.0e-3 at n=5e5 (Monte-Carlo noise over finite-n sweep)
    - T4: gold-free RMSE 0.0058 (independent) -> 0.096 (dependent rho=0.5); gold sweep restores to 0.017 at m_gold=800; log-log slope -2.04 confirms 1/gap^2
review_history:
  - review_id: 2026-05-22-001
    type: multi-agent editorial (logic, methodology, prose, novelty, citation, format)
    critical_findings_fixed:
      - "C1: T1 binary specificity stated; multiclass symmetric-group remark added"
      - "C2: T4 proof made explicit (Hoeffding with beta_min, union bound over r directions, constant c made traceable)"
      - "C3: external citation to towell2026masked Theorem 8 replaced with in-paper cref{thm:bg-id}"
    important_findings_fixed:
      - "I1: abstract emphasizes T4 as the genuinely new result"
      - "I2: orientation assumption flagged in T2 commentary"
      - "I3: marginal-preserving DGP genericity statement added to validation"
      - "I4: budgeting procedure as a 4-step enumerated list in methodology"
      - "I5: series-context lead paragraph in discussion"
      - "I6: interior MLE defined parenthetically in T3"
    polish_done:
      - "P2: augmented candidate-set matrix added to translation table"
build:
  paper_command: "make paper"
  simulation_command: "Rscript scripts/run.R"
  figures_command: "Rscript scripts/figures.R"
  current_pdf_pages: 18
  current_build_status: "clean; one 0.75pt overfull hbox (cosmetic); no undefined refs or citations"
  simulation_status: "reproduced 2026-05-22; gap log-log slope -2.044 (matches -2 prediction)"
next_action: "Optional: real-data WRENCH study; multiclass T1-T4 theorem statements; conference-page-budget compression (~18 -> ~10 pages) when targeting NeurIPS/ICML."
last_updated: 2026-05-22
