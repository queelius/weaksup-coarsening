# Generate PDF figures for the validation section.
# Reads results.rds, writes figures/identifiability_recovery.pdf and
# figures/goldset_complexity.pdf.
#
# Usage:
#   cd papers/weaksup-coarsening
#   Rscript scripts/figures.R

script_dir <- local({
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) == 1L) {
        dirname(normalizePath(sub("^--file=", "", file_arg)))
    } else {
        normalizePath(".")
    }
})

proj_root <- normalizePath(file.path(script_dir, ".."))
results <- readRDS(file.path(proj_root, "results.rds"))
fig_dir <- file.path(proj_root, "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# -----------------------------------------------------------------
# Figure 1: identifiability under conditional independence (T2)
# Panel A: gold-free LF-accuracy RMSE vs n (root-n consistency).
# Panel B: true-label recovery accuracy vs n, with oracle ceiling.
# -----------------------------------------------------------------

exp2 <- results$exp2_ci_identifiability
s2 <- exp2$summary

pdf(file.path(fig_dir, "identifiability_recovery.pdf"),
    width = 7, height = 3.2)
op <- par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.2, 1), mgp = c(2.4, 0.8, 0))

# Panel A: acc RMSE vs n on log-log axes
plot(s2$n, s2$acc_rmse, type = "b", pch = 19, col = "steelblue4",
     lwd = 2, log = "xy",
     xlab = "examples n", ylab = "LF-accuracy RMSE",
     main = "A. Gold-free recovery (T2)", cex.main = 0.95)
# root-n reference, anchored at the first point
n_ref <- s2$n
y_ref <- s2$acc_rmse[1] * sqrt(s2$n[1] / n_ref)
lines(n_ref, y_ref, lty = 2, col = "grey40", lwd = 1.5)
legend("topright", bty = "n", cex = 0.8,
       legend = c("gold-free triplet MoM",
                  sprintf("root-n ref (fit slope %.2f)",
                          exp2$rmse_loglog_slope)),
       col = c("steelblue4", "grey40"), lty = c(1, 2),
       lwd = c(2, 1.5), pch = c(19, NA))

# Panel B: recovery accuracy vs n with oracle ceiling
plot(s2$n, s2$recovery_acc, type = "b", pch = 19, col = "firebrick",
     lwd = 2, log = "x",
     ylim = range(c(s2$recovery_acc, exp2$oracle_recovery)) +
            c(-0.01, 0.01),
     xlab = "examples n", ylab = "true-label recovery accuracy",
     main = "B. Recovery vs oracle", cex.main = 0.95)
abline(h = exp2$oracle_recovery, lty = 3, col = "grey30", lwd = 1.5)
legend("bottomright", bty = "n", cex = 0.8,
       legend = c("gold-free label model", "oracle ceiling"),
       col = c("firebrick", "grey30"), lty = c(1, 3),
       lwd = c(2, 1.5), pch = c(19, NA))

par(op)
dev.off()
cat("Wrote", file.path(fig_dir, "identifiability_recovery.pdf"), "\n")

# -----------------------------------------------------------------
# Figure 2: gold-set sample complexity (T4)
# Panel A: acc RMSE vs gold-set size m_gold under fixed dependence.
# Panel B: m_gold needed vs accuracy margin (gap), log-log, with the
#          1/gap^2 reference line.
# -----------------------------------------------------------------

exp4 <- results$exp4_goldset_complexity
sweep <- exp4$sweep
gapd <- exp4$gap_scaling

pdf(file.path(fig_dir, "goldset_complexity.pdf"),
    width = 7, height = 3.2)
op <- par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.2, 1), mgp = c(2.4, 0.8, 0))

# Panel A: acc RMSE vs m_gold. m_gold = 0 is the gold-free point;
# plot it at a small positive abscissa for the log axis.
mg <- sweep$m_gold
mg_plot <- ifelse(mg == 0, 5, mg)
plot(mg_plot, sweep$acc_rmse, type = "b", pch = 19, col = "steelblue4",
     lwd = 2, log = "xy",
     xlab = "gold-labeled examples (m_gold; leftmost = gold-free)",
     ylab = "LF-accuracy RMSE",
     main = "A. Gold restores identifiability (T4)", cex.main = 0.92)
abline(h = exp4$bias_indep, lty = 3, col = "grey30", lwd = 1.5)
points(mg_plot[1], sweep$acc_rmse[1], pch = 1, cex = 1.8,
       col = "firebrick", lwd = 2)
legend("topright", bty = "n", cex = 0.78,
       legend = c("gold-augmented label model",
                  "gold-free (dependent LFs)",
                  "no-dependence floor"),
       col = c("steelblue4", "firebrick", "grey30"),
       lty = c(1, NA, 3), lwd = c(2, 2, 1.5), pch = c(19, 1, NA))

# Panel B: m_gold needed vs gap, log-log, with 1/gap^2 reference
ok <- !is.na(gapd$mgold_needed) & gapd$mgold_needed > 0
gp <- gapd$gap[ok]; mn <- gapd$mgold_needed[ok]
plot(gp, mn, type = "b", pch = 19, col = "firebrick", lwd = 2,
     log = "xy",
     xlab = "LF accuracy margin (gap)",
     ylab = "gold-labeled examples needed",
     main = "B. Sample complexity scales 1/gap^2", cex.main = 0.92)
# 1/gap^2 reference anchored at the first point
y_ref <- mn[1] * (gp[1] / gp)^2
lines(gp, y_ref, lty = 2, col = "grey40", lwd = 1.5)
legend("topright", bty = "n", cex = 0.78,
       legend = c("m_gold needed",
                  sprintf("1/gap^2 ref (fit slope %.2f)",
                          exp4$gap_loglog_slope)),
       col = c("firebrick", "grey40"), lty = c(1, 2),
       lwd = c(2, 1.5), pch = c(19, NA))

par(op)
dev.off()
cat("Wrote", file.path(fig_dir, "goldset_complexity.pdf"), "\n")
