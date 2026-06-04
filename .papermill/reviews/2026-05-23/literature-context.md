# Literature Context Packet (merged scout output)

## Direct competitors and identifiability prior art

### Dawid and Skene 1979 (J. R. Stat. Soc. C)
The clear ancestor. Estimates per-rater confusion matrices and class prior by EM from rater votes alone. Multiclass-native, no closed-form identifiability theorem but a working maximum-likelihood algorithm whose convergence properties have been studied extensively. The paper correctly cites this as the ancestor.

### Ratner et al. 2016, NeurIPS (data programming)
Introduced the term labeling function and the factor-graph label model. Proved generalization-error bounds for the end-to-end (label-model plus downstream) pipeline. The identifiability argument is a moment-matching condition under conditional independence; not as crisp as Dawid-Skene. The paper correctly cites this.

### Fu et al. 2020, ICML (FlyingSquid, triplet method)
The closed-form triplet-method derivation that the paper's T2 re-derives. Recovers per-LF accuracies and class prior from third-order agreement moments under conditional independence of LFs given the latent label. The paper is honest that T2 is a re-derivation.

### Ratner et al. 2019 AAAI, also Ratner et al. 2020 JMLR (Snorkel MeTaL)
Extends the moment-based approach to structured dependence with a KNOWN dependency graph. The paper cites these correctly.

### Bach et al. 2017 ICML (learning the dependency structure)
Studies recovery of the LF dependency graph from data. The paper's T4, which assumes r is given, sidesteps this; the discussion section flags it as future work, which is accurate.

### Zhang et al. 2021 NeurIPS Datasets & Benchmarks (WRENCH)
Comprehensive benchmark for weak supervision: real LF-vote matrices, multiple label-model baselines (MV, Dawid-Skene, MeTaL, FlyingSquid). The paper cites this and acknowledges the absence of a WRENCH-benchmark study honestly.

### Karger, Oh, Shah 2011 NeurIPS (iterative crowdsourcing)
Iterative message-passing estimator for crowdsourcing. The paper cites this as a parallel solver for the same masked-cause problem.

### Zhang, Chen, Zhou, Jordan 2016 JMLR (spectral methods meet EM for crowdsourcing)
Spectral initialization for the Dawid-Skene EM, with finite-sample guarantees. Closely related to the moment-based identifiability the paper invokes for T2. The paper cites this.

### Anandkumar, Ge, Hsu, Kakade, Telgarsky 2014 JMLR (tensor decompositions for latent variable models)
The low-rank tensor methods underlying both the triplet method and the spectral methods. The paper cites this.

## Sample-complexity results in this space

The most relevant existing sample-complexity results for weak-supervision label models:

1. Ratner et al. 2016 (data programming): generalization bound for the END-TO-END pipeline (label model plus downstream classifier), bounded in terms of LF accuracies and conditional-independence assumption. Not a label-model-only identifiability sample complexity.

2. Fu et al. 2020 (FlyingSquid): under the triplet method, finite-sample bounds on accuracy estimation. These are O(1/eps^2) in agreement-rate accuracy but are formulated for the CONDITIONALLY INDEPENDENT case (r = 0 in the paper's notation).

3. Khetan, Lipton, Anandkumar 2018 ICLR (learning from noisy singly-labeled data): sample-complexity for the singly-labeled (no agreement structure) regime. Tangentially related; not a direct competitor to T4.

4. Tanno et al. 2019 CVPR (regularized annotator-confusion): regularization scheme for neural rater models; empirical and does not produce a clean identifiability theorem.

5. Ratner et al. 2020 JMLR (Snorkel MeTaL): the structured-dependence case has implicit sample-complexity statements through the convex optimization analysis, but not in the explicit O(r/gap^2) form the paper claims.

To the scouts' knowledge there is no published O(r/gap^2) gold-set sample-complexity theorem for the dependent-LF label-model setting. The novelty of T4 appears genuine.

## DGP for LF dependence: choices in the literature

The most common dependence-DGP choices in the Snorkel/weak-supervision literature are:

1. Explicit shared latent factor (Snorkel MeTaL Bach et al. 2017): a known factor graph with explicit shared parent. The paper's Gaussian-copula construction is a smooth instantiation of this.

2. Logistic shared-noise (Ratner et al. 2016): a latent logit with shared error.

3. Naive Bayes with correlated noise (Karger-Oh-Shah crowdsourcing): pairwise error correlation parameter.

4. Direct injection of pairwise agreement perturbations (Fu et al. 2020 simulation studies): adds a correction matrix E directly to the agreement matrix.

The paper's Gaussian-copula construction is mathematically equivalent in expectation to option 1 with a particular link, and the marginal-preserving property is the key technical desideratum. The choice is well-motivated but the paper would benefit from a paragraph explicitly stating why a Gaussian copula over a logistic shared-noise or factor-graph dependence; the empirical slope confirms the bound under THIS construction, and the paper notes other marginal-preserving constructions are expected to give the same scaling. The reviewer at AISTATS or ICML may want to see this argument made more carefully, or a sensitivity analysis across at least one alternative DGP.

## Venue-fit context

- AISTATS (October submit, February decision): identifiability under moment-method estimators is on-mission. The 10-page main + unlimited appendix budget fits the current draft after light compression of the discussion. Audience already familiar with EM, mixture models, coarsening-at-random.
- NeurIPS, ICML: 9 main + appendix budget requires more aggressive compression. Both are strong fits for the theory contribution.
- JMLR: best for the fully self-contained appendix and the multiclass extension.
- VLDB, KDD: would expect a WRENCH benchmark study; currently absent.
- UAI: also a strong fit; probabilistic modeling community appreciates the C1-C2-C3 vocabulary.
