# Run experiments for weaksup-coarsening validation.
#
# Outputs results to results.rds at the project root.
# Console summary printed at the end.
#
# Usage:
#   cd papers/weaksup-coarsening
#   Rscript scripts/run.R
#
# Four studies, one per theorem:
#   Study 1 (T1): glass ceiling. Exhibit the accuracy-complement
#                 symmetry; the gold-free model admits two solutions
#                 without the better-than-random assumption.
#   Study 2 (T2): identifiability under conditional independence.
#                 Gold-free recovery of acc_j and Y; RMSE decreases
#                 as n grows.
#   Study 3 (T3): agreement consistency. Fitted model reproduces the
#                 empirical pairwise agreement rates; residual ~ 0.
#   Study 4 (T4): gold-set sample complexity. Inject LF dependence;
#                 the gold-free model becomes biased; sweep m_gold;
#                 show identifiability restored and m_gold scaling
#                 with dependence strength.

# -----------------------------------------------------------------
# Setup
# -----------------------------------------------------------------

script_dir <- local({
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) == 1L) {
        d <- dirname(normalizePath(sub("^--file=", "", file_arg)))
    } else if (file.exists("scripts/sim.R")) {
        d <- normalizePath("scripts")
    } else {
        d <- normalizePath(".")
    }
    d
})
source(file.path(script_dir, "sim.R"))

set.seed(20260521)

# -----------------------------------------------------------------
# Study 1 (T1): glass ceiling, accuracy-complement symmetry
# -----------------------------------------------------------------

cat("[1/4] Glass ceiling: accuracy-complement symmetry...\n")

# Five conditionally independent LFs, all better than random.
m1   <- 5
cov1 <- rep(0.7, m1)
acc1 <- c(0.85, 0.78, 0.72, 0.68, 0.90)
pi1  <- 0.4

sim1 <- sim_ws(n = 200000, pi = pi1, cov = cov1, acc = acc1)

# The two label-model solutions related by the global flip:
#   solution A: (pi, acc)
#   solution B: (1 - pi, 1 - acc)
sol_A <- list(acc = acc1,     pi = pi1)
sol_B <- list(acc = 1 - acc1, pi = 1 - pi1)

# Empirical joint vote-pattern distribution, and the distribution
# implied by each solution. If the two solutions are observationally
# identical, both match the empirical distribution equally well.
# Enumerate all 3^m vote patterns (0, 1, abstain) and compare
# probabilities. m1 = 5 -> 243 patterns.
vote_levels <- list(0L, 1L, NA)
patterns <- expand.grid(rep(list(0:2), m1))   # 0,1,2 -> 0,1,abstain

pattern_prob_model <- function(pat_row, sol, cov) {
    # pat_row: integer vector length m, entries in {0,1,2}.
    m <- length(pat_row)
    acc <- sol$acc; pri <- sol$pi
    tot <- 0
    for (y in c(0L, 1L)) {
        py <- if (y == 1L) pri else 1 - pri
        contrib <- py
        for (j in seq_len(m)) {
            e <- pat_row[j]
            if (e == 2L) {
                contrib <- contrib * (1 - cov[j])
            } else {
                v <- e            # 0 or 1
                p_correct <- if (v == y) acc[j] else 1 - acc[j]
                contrib <- contrib * cov[j] * p_correct
            }
        }
        tot <- tot + contrib
    }
    tot
}

pattern_prob_emp <- function(pat_row, L) {
    m <- ncol(L)
    match_all <- rep(TRUE, nrow(L))
    for (j in seq_len(m)) {
        e <- pat_row[j]
        col <- L[, j]
        if (e == 2L) {
            match_all <- match_all & is.na(col)
        } else {
            match_all <- match_all & (!is.na(col) & col == e)
        }
    }
    mean(match_all)
}

n_pat <- nrow(patterns)
prob_emp <- numeric(n_pat)
prob_A   <- numeric(n_pat)
prob_B   <- numeric(n_pat)
for (r in seq_len(n_pat)) {
    pr <- as.integer(patterns[r, ])
    prob_emp[r] <- pattern_prob_emp(pr, sim1$L)
    prob_A[r]   <- pattern_prob_model(pr, sol_A, cov1)
    prob_B[r]   <- pattern_prob_model(pr, sol_B, cov1)
}

# T1 claim: solution A and solution B produce IDENTICAL pattern
# probabilities (the symmetry is exact, not approximate).
sym_max_diff <- max(abs(prob_A - prob_B))
# Both match the empirical distribution to Monte-Carlo error.
fit_A_l1 <- sum(abs(prob_A - prob_emp))
fit_B_l1 <- sum(abs(prob_B - prob_emp))

# A gold-free fit without the orientation assumption cannot choose
# between the two; with the assumption it picks A. Demonstrate that
# the unsigned triplet recovery yields |a_j| only.
gf1 <- fit_label_model_goldfree(sim1$L, better_than_random = TRUE)

exp1 <- list(
    m = m1, n = 200000, pi_true = pi1, acc_true = acc1,
    sol_A = sol_A, sol_B = sol_B,
    symmetry_max_pattern_prob_diff = sym_max_diff,
    fit_A_l1_to_empirical = fit_A_l1,
    fit_B_l1_to_empirical = fit_B_l1,
    goldfree_acc = gf1$acc, goldfree_pi = gf1$pi
)

cat(sprintf("    max |P_A - P_B| over 3^m vote patterns = %.3e\n",
            sym_max_diff))
cat(sprintf("    L1 fit to empirical: solution A = %.4f, solution B = %.4f\n",
            fit_A_l1, fit_B_l1))

# -----------------------------------------------------------------
# Study 2 (T2): identifiability under conditional independence
# -----------------------------------------------------------------

cat("[2/4] Identifiability under conditional independence...\n")

m2   <- 5
cov2 <- c(0.6, 0.7, 0.8, 0.65, 0.75)
acc2 <- c(0.82, 0.75, 0.70, 0.88, 0.66)
pi2  <- 0.45

n_grid <- c(500, 1000, 2000, 5000, 10000, 20000, 50000)
n_rep2 <- 30

exp2_raw <- data.frame(
    n = rep(n_grid, each = n_rep2),
    rep = rep(seq_len(n_rep2), times = length(n_grid)),
    acc_rmse = NA_real_,
    pi_abs_err = NA_real_,
    recovery_acc = NA_real_
)

for (i in seq_len(nrow(exp2_raw))) {
    n_i <- exp2_raw$n[i]
    sim2 <- sim_ws(n = n_i, pi = pi2, cov = cov2, acc = acc2)
    fit2 <- fit_label_model_goldfree(sim2$L, better_than_random = TRUE)
    post2 <- posterior_Y(sim2$L, fit2)
    exp2_raw$acc_rmse[i]     <- acc_rmse(fit2$acc, acc2)
    exp2_raw$pi_abs_err[i]   <- abs(fit2$pi - pi2)
    exp2_raw$recovery_acc[i] <- recovery_accuracy(post2, sim2$Y)
}

exp2_summary <- aggregate(
    cbind(acc_rmse, pi_abs_err, recovery_acc) ~ n,
    data = exp2_raw, FUN = median
)

# Oracle recovery ceiling at the largest n (knows true Y).
sim2_big <- sim_ws(n = 50000, pi = pi2, cov = cov2, acc = acc2)
oracle2  <- fit_label_model_oracle(sim2_big)
post2_or <- posterior_Y(sim2_big$L, oracle2)
exp2_oracle_recovery <- recovery_accuracy(post2_or, sim2_big$Y)

# Log-log slope of acc RMSE vs n (root-n consistency -> slope ~ -0.5).
slope2 <- coef(lm(log(acc_rmse) ~ log(n), data = exp2_summary))[["log(n)"]]

exp2 <- list(
    m = m2, pi_true = pi2, acc_true = acc2, cov_true = cov2,
    summary = exp2_summary, raw = exp2_raw,
    oracle_recovery = exp2_oracle_recovery,
    rmse_loglog_slope = slope2
)

cat(sprintf("    acc RMSE: %.4f at n=500 -> %.4f at n=50000\n",
            exp2_summary$acc_rmse[1],
            exp2_summary$acc_rmse[nrow(exp2_summary)]))
cat(sprintf("    log-log slope of acc RMSE vs n = %.3f (root-n: -0.5)\n",
            slope2))

# -----------------------------------------------------------------
# Study 3 (T3): agreement consistency
# -----------------------------------------------------------------

cat("[3/4] Agreement consistency...\n")

m3   <- 5
cov3 <- rep(0.75, m3)
acc3 <- c(0.80, 0.74, 0.71, 0.86, 0.69)
pi3  <- 0.5

# Noiseless control: feed population agreement rates by using a very
# large n; the gold-free (correctly specified) fit should reproduce
# the empirical pairwise agreement rates to Monte-Carlo precision.
sim3_big <- sim_ws(n = 500000, pi = pi3, cov = cov3, acc = acc3)
fit3_big <- fit_label_model_goldfree(sim3_big$L, better_than_random = TRUE)
resid3_big <- agreement_residual(sim3_big$L, fit3_big)

# Oracle fit (true accuracies) residual: this is the structural
# agreement-consistency check, free of estimation error.
oracle3 <- fit_label_model_oracle(sim3_big)
resid3_oracle <- agreement_residual(sim3_big$L, oracle3)

# Finite-n sweep: residual should shrink as Monte-Carlo noise.
n_grid3 <- c(500, 1000, 5000, 20000, 100000)
n_rep3 <- 25
exp3_raw <- data.frame(
    n = rep(n_grid3, each = n_rep3),
    rep = rep(seq_len(n_rep3), times = length(n_grid3)),
    max_abs = NA_real_, median_abs = NA_real_
)
for (i in seq_len(nrow(exp3_raw))) {
    n_i <- exp3_raw$n[i]
    sim3 <- sim_ws(n = n_i, pi = pi3, cov = cov3, acc = acc3)
    fit3 <- fit_label_model_goldfree(sim3$L, better_than_random = TRUE)
    rr <- agreement_residual(sim3$L, fit3)
    exp3_raw$max_abs[i]    <- rr$max_abs
    exp3_raw$median_abs[i] <- rr$median_abs
}
exp3_summary <- aggregate(
    cbind(max_abs, median_abs) ~ n, data = exp3_raw, FUN = median
)

exp3 <- list(
    m = m3, pi_true = pi3, acc_true = acc3,
    big_n = 500000,
    goldfree_resid_max = resid3_big$max_abs,
    goldfree_resid_median = resid3_big$median_abs,
    oracle_resid_max = resid3_oracle$max_abs,
    oracle_resid_median = resid3_oracle$median_abs,
    summary = exp3_summary, raw = exp3_raw
)

cat(sprintf("    gold-free fit, n=5e5: max agreement residual = %.3e\n",
            resid3_big$max_abs))
cat(sprintf("    oracle fit,    n=5e5: max agreement residual = %.3e\n",
            resid3_oracle$max_abs))

# -----------------------------------------------------------------
# Study 4 (T4): gold-set sample complexity under LF dependence
# -----------------------------------------------------------------

cat("[4/4] Gold-set sample complexity under LF dependence...\n")

# Eight LFs with modest accuracy margins (closer to random voting, so
# dependence-induced bias is pronounced). Three dependent pairs among
# the first six LFs; LFs 7 and 8 are independent anchors.
m4   <- 8
cov4 <- rep(0.8, m4)
acc4 <- c(0.72, 0.70, 0.71, 0.69, 0.73, 0.68, 0.80, 0.78)
pi4  <- 0.5
n4   <- 20000

dep_pairs4 <- list(c(1L, 2L), c(3L, 4L), c(5L, 6L))
dep_main   <- 0.50          # dependence strength for the headline run

# 4a: confirm the gold-free model is biased once dependence is on.
sim4_indep <- sim_ws(n4, pi4, cov4, acc4)
sim4_dep   <- sim_ws(n4, pi4, cov4, acc4,
                     dep_pairs = dep_pairs4, dep_strength = dep_main)

gf4_indep <- fit_label_model_goldfree(sim4_indep$L, better_than_random = TRUE)
gf4_dep   <- fit_label_model_goldfree(sim4_dep$L,   better_than_random = TRUE)

bias_indep <- acc_rmse(gf4_indep$acc, acc4)
bias_dep   <- acc_rmse(gf4_dep$acc,   acc4)

# Rank deficit of the dependent agreement matrix vs the rank-one
# (conditionally independent) structure A_jk = a_j a_k.
deficit_indep <- agreement_rank_deficit(sim4_indep$L, tol = 0.10)
deficit_dep   <- agreement_rank_deficit(sim4_dep$L,   tol = 0.10)

cat(sprintf("    gold-free acc RMSE: independent = %.4f, dependent = %.4f\n",
            bias_indep, bias_dep))
cat(sprintf("    agreement rank deficit (eff): independent = %d, dependent = %d\n",
            deficit_indep$eff_deficit, deficit_dep$eff_deficit))

# 4b: sweep gold-set size m_gold; show identifiability restored.
mgold_grid <- c(0, 10, 25, 50, 100, 200, 400, 800)
n_rep4 <- 40

exp4_raw <- data.frame(
    m_gold = rep(mgold_grid, each = n_rep4),
    rep = rep(seq_len(n_rep4), times = length(mgold_grid)),
    acc_rmse = NA_real_,
    recovery_acc = NA_real_
)

for (i in seq_len(nrow(exp4_raw))) {
    mg <- exp4_raw$m_gold[i]
    sim4 <- sim_ws(n4, pi4, cov4, acc4,
                   dep_pairs = dep_pairs4, dep_strength = dep_main)
    if (mg == 0L) {
        fit4 <- fit_label_model_goldfree(sim4$L, better_than_random = TRUE)
    } else {
        gold_idx <- sample.int(n4, mg)
        L_gold <- sim4$L[gold_idx, , drop = FALSE]
        Y_gold <- sim4$Y[gold_idx]
        fit4 <- fit_label_model_combined(sim4$L, L_gold, Y_gold)
    }
    post4 <- posterior_Y(sim4$L, fit4)
    exp4_raw$acc_rmse[i]     <- acc_rmse(fit4$acc, acc4)
    exp4_raw$recovery_acc[i] <- recovery_accuracy(post4, sim4$Y)
}
exp4_sweep <- aggregate(
    cbind(acc_rmse, recovery_acc) ~ m_gold,
    data = exp4_raw, FUN = median
)

# 4c: m_gold needed scales with dependence strength. For each
# dependence strength, record the effective rank deficit and the
# relative residual of the rank-one fit (a continuous deficit
# measure), then find the smallest m_gold on the grid whose median
# acc RMSE falls below a target tolerance.
dep_strengths <- c(0.10, 0.20, 0.30, 0.40, 0.50, 0.60)
target_rmse <- 0.04
n_rep4c <- 30
exp4_scaling <- data.frame(
    dep_strength = dep_strengths,
    eff_deficit = NA_real_,
    resid_rel = NA_real_,
    goldfree_rmse = NA_real_,
    mgold_needed = NA_real_
)
mgold_grid_c <- c(0, 10, 20, 30, 40, 50, 60, 80, 100, 140, 200, 300,
                   400, 600, 800, 1200, 1600)

for (d in seq_along(dep_strengths)) {
    ds <- dep_strengths[d]
    # effective rank deficit and gold-free bias at this strength
    sim_d <- sim_ws(n4, pi4, cov4, acc4,
                    dep_pairs = dep_pairs4, dep_strength = ds)
    diag_d <- agreement_rank_deficit(sim_d$L, tol = 0.10)
    exp4_scaling$eff_deficit[d] <- diag_d$eff_deficit
    exp4_scaling$resid_rel[d]   <- diag_d$resid_rel
    gf_d <- fit_label_model_goldfree(sim_d$L, better_than_random = TRUE)
    exp4_scaling$goldfree_rmse[d] <- acc_rmse(gf_d$acc, acc4)
    # smallest m_gold meeting the target
    needed <- NA_real_
    for (mg in mgold_grid_c) {
        rmses <- numeric(n_rep4c)
        for (r in seq_len(n_rep4c)) {
            sim4 <- sim_ws(n4, pi4, cov4, acc4,
                           dep_pairs = dep_pairs4, dep_strength = ds)
            if (mg == 0L) {
                fit4 <- fit_label_model_goldfree(sim4$L,
                                                 better_than_random = TRUE)
            } else {
                gold_idx <- sample.int(n4, mg)
                fit4 <- fit_label_model_combined(
                    sim4$L, sim4$L[gold_idx, , drop = FALSE],
                    sim4$Y[gold_idx])
            }
            rmses[r] <- acc_rmse(fit4$acc, acc4)
        }
        if (median(rmses) <= target_rmse) { needed <- mg; break }
    }
    exp4_scaling$mgold_needed[d] <- needed
}

# 4d: accuracy-margin (gap) scaling. The gold-set bound is
# O(r / gap^2). The 1/gap^2 factor arises because resolving the
# near-degenerate label-model solutions (the orientation ambiguity
# of T1, and the dependence-induced degeneracy of T4) requires the
# gold-set accuracy estimate to separate solutions whose parameter
# gap is itself proportional to the accuracy margin. We therefore
# require the gold-set estimation error to fall below a gap-
# proportional threshold, target_frac * gap, and record the
# m_gold needed. Hold the dependence structure fixed; vary the
# margin. LF accuracies are set to 0.5 + gap/2 so the centered
# margin is exactly gap.
gap_grid <- c(0.10, 0.14, 0.20, 0.28, 0.40)
n_rep4d <- 40
target_frac <- 0.5         # required precision: SE <= target_frac * gap
exp4_gap <- data.frame(
    gap = gap_grid,
    target_se = target_frac * gap_grid,
    mgold_needed = rep(NA_real_, length(gap_grid))
)
mgold_grid_d <- c(5, 8, 12, 18, 25, 35, 50, 70, 100, 140, 200, 280,
                  400, 560, 800, 1200, 1800, 2600, 4000)

for (g in seq_along(gap_grid)) {
    gp <- gap_grid[g]
    acc_g <- rep(0.5 + gp / 2, m4)        # every LF has margin gp
    thr <- target_frac * gp               # gap-proportional threshold
    needed <- NA_real_
    for (mg in mgold_grid_d) {
        ses <- numeric(n_rep4d)
        for (r in seq_len(n_rep4d)) {
            sim_g <- sim_ws(n4, pi4, cov4, acc_g,
                            dep_pairs = dep_pairs4, dep_strength = 0.50)
            gold_idx <- sample.int(n4, mg)
            fit_g <- fit_label_model_gold(
                sim_g$L[gold_idx, , drop = FALSE], sim_g$Y[gold_idx])
            ses[r] <- acc_rmse(fit_g$acc, acc_g)
        }
        if (median(ses) <= thr) { needed <- mg; break }
    }
    exp4_gap$mgold_needed[g] <- needed
}
# Log-log slope of m_gold needed vs gap (theory: -2, since 1/gap^2).
gap_ok <- !is.na(exp4_gap$mgold_needed) & exp4_gap$mgold_needed > 0
exp4_gap_slope <- if (sum(gap_ok) >= 2) {
    coef(lm(log(mgold_needed) ~ log(gap),
            data = exp4_gap[gap_ok, ]))[["log(gap)"]]
} else NA_real_

exp4 <- list(
    m = m4, pi_true = pi4, acc_true = acc4, n = n4,
    dep_pairs = dep_pairs4,
    bias_indep = bias_indep, bias_dep = bias_dep,
    deficit_indep = deficit_indep$eff_deficit,
    deficit_dep = deficit_dep$eff_deficit,
    sweep = exp4_sweep,
    raw = exp4_raw,
    scaling = exp4_scaling,
    target_rmse = target_rmse,
    gap_scaling = exp4_gap,
    gap_loglog_slope = exp4_gap_slope,
    gap_target_frac = target_frac
)

cat("    m_gold needed by dependence strength:\n")
print(exp4_scaling)
cat("    m_gold needed by accuracy margin (gap):\n")
print(exp4_gap)
cat(sprintf("    log-log slope of m_gold vs gap = %.3f (theory: -2)\n",
            exp4_gap_slope))

# -----------------------------------------------------------------
# Save and summarize
# -----------------------------------------------------------------

results <- list(
    seed = 20260521,
    timestamp = Sys.time(),
    exp1_glass_ceiling = exp1,
    exp2_ci_identifiability = exp2,
    exp3_agreement_consistency = exp3,
    exp4_goldset_complexity = exp4
)

saveRDS(results, file = file.path(script_dir, "..", "results.rds"))

cat("\n========== SUMMARY ==========\n")

cat("\nStudy 1 (T1) glass ceiling, accuracy-complement symmetry:\n")
cat(sprintf("  max |P_A - P_B| over all vote patterns = %.3e\n",
            exp1$symmetry_max_pattern_prob_diff))
cat(sprintf("  L1 fit to empirical: A = %.4f, B = %.4f (near-equal => symmetry)\n",
            exp1$fit_A_l1_to_empirical, exp1$fit_B_l1_to_empirical))
cat("  gold-free triplet recovers |a_j| only; orientation needs an assumption.\n")

cat("\nStudy 2 (T2) identifiability under conditional independence:\n")
print(exp2$summary)
cat(sprintf("  oracle recovery accuracy (ceiling)  = %.4f\n",
            exp2$oracle_recovery))
cat(sprintf("  log-log slope of acc RMSE vs n      = %.3f\n",
            exp2$rmse_loglog_slope))

cat("\nStudy 3 (T3) agreement consistency:\n")
cat(sprintf("  gold-free fit (n=5e5): max residual = %.3e, median = %.3e\n",
            exp3$goldfree_resid_max, exp3$goldfree_resid_median))
cat(sprintf("  oracle fit    (n=5e5): max residual = %.3e, median = %.3e\n",
            exp3$oracle_resid_max, exp3$oracle_resid_median))
cat("  finite-n residual sweep (median over replicates):\n")
print(exp3$summary)

cat("\nStudy 4 (T4) gold-set sample complexity:\n")
cat(sprintf("  gold-free acc RMSE: independent = %.4f, dependent = %.4f\n",
            exp4$bias_indep, exp4$bias_dep))
cat(sprintf("  agreement rank deficit: independent = %d, dependent = %d\n",
            exp4$deficit_indep, exp4$deficit_dep))
cat("  gold-set sweep (median over replicates):\n")
print(exp4$sweep)
cat(sprintf("  m_gold needed to reach acc RMSE <= %.2f, by dependence strength:\n",
            exp4$target_rmse))
print(exp4$scaling)
cat(sprintf("  m_gold needed to reach SE <= %.2f * gap, by accuracy margin:\n",
            exp4$gap_target_frac))
print(exp4$gap_scaling)
cat(sprintf("  log-log slope of m_gold vs gap = %.3f (theory: -2 for 1/gap^2)\n",
            exp4$gap_loglog_slope))

cat("\nResults saved to results.rds\n")
