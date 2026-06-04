# Prose Auditor Report

**Date**: 2026-06-04
**Focus**: Writing quality, narrative arc, clarity, and notation consistency
across the rewritten Theorem T4 (`thm:goldset`) and the rest of the paper.
Specific charge: did the T4 rewrite leave prose seams, dangling references to the
old union-bound framing, or inconsistent notation (r vs d_free)?

## Headline verdict

The T4 rewrite is **prose-clean**. There are no dangling references to the old
union-bound framing of the headline rate, no orphaned notation, and the r vs
d_free distinction is introduced once and used consistently. The writing is
dense but disciplined: the abstract, introduction contribution list, methodology
theorem, and conclusion all state the same object (Theta(r/gap^2) for total/L2
recovery, with matching upper and minimax lower bounds), in the same words.

## Old-framing seam check (the specific charge)

A prior version evidently framed the linear-in-r rate via a union bound. The
rewrite replaced that with a trace-bound upper + Gaussian-minimax lower argument.
I checked every surviving occurrence of "union" and "log r":

- The only three "union" mentions remaining are *correct in the new framing*,
  not seams from the old one:
  - `methodology.tex` lines 223, 233: the union is over the r directions in the
    *L_inf* per-direction rate (`rmk:r-dependence`), where a union genuinely is
    the right tool, and the text explicitly states "the union bound is tight for
    the L_inf loss rather than loose."
  - `validation.tex` line 175: the union is over the m LFs for the
    *direct-marginal* estimator actually used in the simulation, correctly giving
    Theta(log m / gap^2) with m fixed.
- The headline L2 rate is explicitly *disconnected* from any union bound:
  methodology line 164 reads "No log r factor appears: the trace bound targets
  the total L2 error directly, not each direction separately." This is the exact
  sentence one wants to see; the rewrite closed the seam deliberately.
- `rmk:r-dependence` (the loss-taxonomy remark) reframes the old "r vs log r"
  tension as a loss-specification question rather than competing bounds on one
  quantity: "they are rates for different losses, not competing bounds on one
  quantity." This is a clarifying, well-written paragraph and is the prose payoff
  of the rewrite.

No dangling old-framing text remains.

## Notation consistency: r vs d_free

Consistent and well-controlled.
- `r = d_{\mathrm{free}}` is defined once, in `eq:meth-dfree` (methodology),
  with `rmk:r-definition` (Remark 6) as the canonical clarifier of r versus the
  residual-matrix rank (2 d_free).
- The literal token `d_{\mathrm{free}}` appears only in `methodology.tex` (4x,
  all at the definition and the residual-rank remark) and `validation.tex` (2x,
  where the diagnostic's "effective deficit 6 = 2 d_free, d_free = 3" is
  explained). Every other section uses `r`. This is exactly the right discipline:
  the heavyweight symbol appears only where the distinction is load-bearing.
- `rmk:r-definition` is referenced from both methodology and validation, so the
  reader meets one definition and is pointed back to it. The budgeting procedure
  (methodology step 3) restates "halve the count" with a back-reference. No drift.

## Narrative arc

The arc is strong and the spine is explicit: a single sentence
("singletons restore the rank that coarsening destroys") recurs as the through
-line from background (singletons restore rank in `thm:bg-id`) to T1 (the
obstruction) to T4 (the price), and the introduction's closing message
("gold-free weak supervision is not magic, it is a coarsening problem with a
precise identifiability boundary") is delivered and paid off. The three-regime
interpretation (r=0, small r, small gap) in methodology is a clean reader aid.

## Minor prose findings

1. **Symbol overload of c_0** (`methodology.tex` lines 172, 181-182). c_0 names
   both the per-coordinate variance floor (1-gap^2)/beta_max and the tolerance
   constant in (c_0 gap)^2; the conversion n_g >= (c_0/c_0^2) r/gap^2 then has
   one symbol doing two jobs. The arithmetic resolves correctly, but a reader
   tracking the constant will stumble. FIX: rename the tolerance constant (e.g.
   c_tol). Severity: minor. (This is the same blemish the logic-checker flagged
   from the math side; it reads as a prose/clarity defect to a referee.)

2. **"sixteen-fold" then a different ratio nearby** (`validation.tex` line 120):
   RMSE 0.0058 -> 0.096 is correctly called a sixteen-fold increase; fine, but
   the paragraph would read more cleanly if the gold-restoration numbers that
   follow (0.096 -> 0.017) were also given as a fold-change for parallelism.
   Severity: suggestion.

3. **Dense compound sentence** (`validation.tex` lines 24-31, the
   marginal-preserving DGP sentence) runs to roughly five clauses with three
   parenthetical estimator names. It is correct and even admirably precise, but
   a referee skimming will lose the thread. FIX: split after "what a gold-labeled
   example observes." Severity: minor.

4. **`rmk:l2-loss` is the crux but arrives mid-section.** The argument that L2 is
   the operative loss (because downstream KL is an L2 quadratic form) is what
   justifies the headline rate, yet it sits as Remark 7 after the theorem. This
   is a defensible structure, but one forward-pointer from the theorem statement
   to `rmk:l2-loss` (already present at line 93, "equivalently it should keep the
   downstream training-label posterior KL below a fixed budget
   (\cref{rmk:l2-loss})") handles it. No change needed; noting that the existing
   forward-reference is doing important work and should not be dropped.

## Cross-verification routed to novelty-assessor (per workflow)

I asked whether any unclear writing hides a weak contribution. The
novelty-assessor's return (on disk) concurs with my read: NO. The density is
real but the substance (T4 + the masked-cause framing) is present and clearly
differentiated; the one place framing could be mistaken for novelty (T1 as
"folklore made precise") is handled honestly in prose.

## Prose-auditor confidence

HIGH. The T4 rewrite is integrated cleanly into the surrounding prose; the
notation is consistent; the only defects are the c_0 overload (shared with the
logic-checker) and two readability splits. None affect correctness or the
argument's legibility to an expert reader.
