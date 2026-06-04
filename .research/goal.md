# Goal

Settle the true scaling of the gold-set sample complexity in Theorem T4
(`sections/methodology.tex`, `thm:goldset`) of the weaksup-coarsening paper.

T4 headline claim: n_g = O(r / gap^2) gold labels suffice to restore
identifiability of the label model, where r is the rank deficit induced by
LF dependence and gap is the LF accuracy margin.

The PROOF as written (union bound, Hoeffding per direction) only delivers
  n_g = O( log(r) / gap^2 ).
Remark `rmk:r-dependence` conjectures a packing/volume argument recovers the
linear O(r/gap^2) but states this is open.

TASKS:
(a) Sufficiency (upper bound): how many gold labels actually suffice, as a
    function of r and gap?  Theta(r/gap^2), Theta(log r/gap^2), or other?
(b) Necessity (lower bound): how many are information-theoretically required?
(c) Reconcile linear-r intuition vs log-r union bound; give matching Theta if
    attainable.

METHOD: simulation to pin the rate (r-sweep AND gap-sweep, varied
independently), then prove it (packing/Fano lower bound; concentration upper
bound).

DELIVERABLE: `.research/synthesis.md` with the true rate, proofs, simulation
evidence (fitted exponents), and the exact restatement T4 should adopt.

CONSTRAINTS: do NOT modify any manuscript .tex file. No em-dash (U+2014) in
any written file.

Eval: self-evaluation (no external eval script). Success = matching
upper+lower bounds with proof, OR clearly-evidenced rate from simulation plus
a rigorous one-sided bound and honest statement of what remains open.
