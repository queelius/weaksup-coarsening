# Programmatic-weak-supervision simulation: data-generating process,
# estimators, and diagnostics. Sourced by run.R.
#
# DGP: binary true label Y in {0,1}, n examples, class prior pi;
#      m labeling functions (LFs). LF j has coverage cov_j (probability
#      it does not abstain) and accuracy acc_j (when it votes, emits Y
#      with probability acc_j, else 1-Y). Conditional independence: LF
#      votes independent given Y. Dependence: a configurable set of LF
#      pairs share a latent noise bit.
#
# Vote encoding in the returned matrix L (n x m):
#   0, 1   a vote for that label
#   NA     abstention
#
# All estimators operate on agreement statistics or on gold labels, so
# they are agnostic to absolute sample size beyond Monte-Carlo noise.

suppressPackageStartupMessages({
    invisible(NULL)  # base R only, no external deps
})

# =================================================================
# SECTION 1: data-generating process
# =================================================================

#' Generate weak-supervision votes.
#'
#' @param n        number of examples.
#' @param pi       class prior P(Y = 1).
#' @param cov      length-m vector of LF coverages (P(not abstain)).
#' @param acc      length-m vector of LF accuracies (P(vote = Y | vote)).
#' @param dep_pairs optional list of integer pairs c(j, k); each pair
#'                  shares latent error structure that correlates the
#'                  two LFs' mistakes (a C2 violation: errors are no
#'                  longer conditionally independent given Y). The
#'                  construction is marginal-preserving: each LF keeps
#'                  its accuracy acc_j, so a gold-labeled example still
#'                  observes acc_j directly; only the pairwise error
#'                  correlation changes.
#' @param dep_strength latent-correlation parameter in [0, 1); 0 is
#'                  conditional independence, larger values inject
#'                  stronger positively-correlated LF error.
#' @return list with Y (length n), L (n x m vote matrix; NA = abstain),
#'         and the ground-truth parameters.
#'
#' Dependence mechanism. Each LF j has a latent Gaussian score
#' g_j ~ N(0, 1); LF j votes correctly iff g_j <= qnorm(acc_j), which
#' makes the marginal correctness probability exactly acc_j. For an
#' independent LF, g_j is its own standard normal. For a dependent
#' pair (j, k), the two scores share a common latent factor:
#'   g_j = sqrt(rho) * u + sqrt(1 - rho) * e_j,
#'   g_k = sqrt(rho) * u + sqrt(1 - rho) * e_k,
#' with u, e_j, e_k independent N(0, 1) and rho = dep_strength. The
#' marginal of each g is still N(0, 1), so acc_j and acc_k are
#' unchanged, but Corr(g_j, g_k) = rho couples the two LFs' errors.
#' This breaks the rank-one structure E[sigma_j sigma_k] = a_j a_k
#' that the triplet identity (T2) relies on, while leaving the
#' marginal accuracies (what gold labels measure) intact.
sim_ws <- function(n, pi, cov, acc, dep_pairs = list(), dep_strength = 0) {
    m <- length(cov)
    stopifnot(length(acc) == m)
    Y <- rbinom(n, size = 1, prob = pi)

    # Latent Gaussian scores, one per LF. Start independent.
    g <- matrix(rnorm(n * m), nrow = n, ncol = m)

    # Dependent pairs: replace each member's score by a shared-factor
    # mixture. Marginals stay N(0, 1); the pair becomes correlated.
    if (length(dep_pairs) > 0 && dep_strength > 0) {
        rho <- dep_strength
        for (pr in dep_pairs) {
            j <- pr[1]; k <- pr[2]
            u <- rnorm(n)
            e_j <- rnorm(n); e_k <- rnorm(n)
            g[, j] <- sqrt(rho) * u + sqrt(1 - rho) * e_j
            g[, k] <- sqrt(rho) * u + sqrt(1 - rho) * e_k
        }
    }

    # LF j votes correctly iff its score is below the acc_j quantile;
    # P(g_j <= qnorm(acc_j)) = acc_j exactly (marginal-preserving).
    thresh <- qnorm(acc)                       # length m
    correct <- sweep(g, 2, thresh, FUN = "<=") # n x m logical
    vote <- ifelse(correct, Y, 1L - Y)

    # Coverage: abstain with probability 1 - cov_j (independent of Y).
    votes_on <- matrix(rbinom(n * m, 1, rep(cov, each = n)), nrow = n, ncol = m)
    L <- ifelse(votes_on == 1L, vote, NA_integer_)

    list(Y = Y, L = L, pi_true = pi, cov_true = cov, acc_true = acc,
         dep_pairs = dep_pairs, dep_strength = dep_strength)
}

# =================================================================
# SECTION 2: estimators
# =================================================================

# --- agreement statistics -----------------------------------------

#' Centered pairwise agreement E[sigma_j sigma_k] on examples where
#' both LFs vote. sigma = 2*vote - 1 in {-1, +1}.
#' Returns an m x m matrix; diagonal set to NA.
pairwise_agreement <- function(L) {
    m <- ncol(L)
    sigma <- 2 * L - 1                      # n x m, NA where abstain
    A <- matrix(NA_real_, m, m)
    for (j in seq_len(m)) {
        for (k in seq_len(m)) {
            if (j == k) next
            ok <- !is.na(sigma[, j]) & !is.na(sigma[, k])
            if (sum(ok) > 0) A[j, k] <- mean(sigma[ok, j] * sigma[ok, k])
        }
    }
    A
}

#' Centered triple agreement E[sigma_j sigma_k sigma_l] on examples
#' where all three vote.
triple_agreement <- function(L, j, k, l) {
    sigma <- 2 * L - 1
    ok <- !is.na(sigma[, j]) & !is.na(sigma[, k]) & !is.na(sigma[, l])
    if (sum(ok) == 0) return(NA_real_)
    mean(sigma[ok, j] * sigma[ok, k] * sigma[ok, l])
}

# --- (a) gold-free label model: triplet method --------------------

#' Recover LF accuracy margins a_j = 2*acc_j - 1 by the closed-form
#' triplet method (Fu et al. 2020) for >= 3 conditionally independent
#' LFs. For each LF j, pick two helper LFs k, l and solve
#'   a_j^2 = (A_jk * A_jl) / A_kl.
#' The triple product fixes the common sign; better_than_random = TRUE
#' selects the positive root (LF orientation assumption).
#'
#' Returns list: acc (length m), pi, a (margins).
fit_label_model_goldfree <- function(L, better_than_random = TRUE) {
    m <- ncol(L)
    stopifnot(m >= 3)
    A <- pairwise_agreement(L)

    a2 <- numeric(m)
    for (j in seq_len(m)) {
        helpers <- setdiff(seq_len(m), j)[1:2]
        k <- helpers[1]; l <- helpers[2]
        denom <- A[k, l]
        a2[j] <- if (is.na(denom) || abs(denom) < 1e-9) NA_real_
                 else (A[j, k] * A[j, l]) / denom
    }
    a_mag <- sqrt(pmax(a2, 0))

    # Sign: use a reference triple to fix orientation. With three LFs
    # and all margins positive, A_jk > 0; the triple product sign
    # then disambiguates. Under better_than_random we take a_j > 0.
    if (better_than_random) {
        a <- a_mag
    } else {
        # Pick signs from the sign of pairwise agreements relative to
        # LF 1 (an arbitrary anchor); this admits the global flip.
        s <- rep(1, m)
        for (j in 2:m) s[j] <- sign(A[1, j])
        a <- s * a_mag
    }

    acc <- (1 + a) / 2

    # Class prior from first moment: E[sigma_j] = a_j * (2*pi - 1).
    sigma <- 2 * L - 1
    mean_sigma <- colMeans(sigma, na.rm = TRUE)
    # 2*pi - 1 estimated per LF, then averaged over LFs with |a| large.
    use <- which(abs(a) > 0.05 & is.finite(a))
    if (length(use) > 0) {
        z <- mean(mean_sigma[use] / a[use])
        pi_hat <- (z + 1) / 2
        pi_hat <- min(max(pi_hat, 0), 1)
    } else {
        pi_hat <- 0.5
    }

    list(acc = acc, pi = pi_hat, a = a, A = A)
}

#' Posterior P(Y = 1 | votes) for one example given a fitted model.
#' Naive-Bayes aggregation over LFs that voted.
posterior_Y <- function(L, fit) {
    m <- ncol(L)
    acc <- pmin(pmax(fit$acc, 1e-3), 1 - 1e-3)
    pri <- min(max(fit$pi, 1e-3), 1 - 1e-3)
    post <- numeric(nrow(L))
    for (i in seq_len(nrow(L))) {
        log1 <- log(pri); log0 <- log(1 - pri)
        for (j in seq_len(m)) {
            v <- L[i, j]
            if (is.na(v)) next
            # P(vote = v | Y = 1): acc if v==1 else 1-acc.
            log1 <- log1 + log(if (v == 1L) acc[j] else 1 - acc[j])
            log0 <- log0 + log(if (v == 0L) acc[j] else 1 - acc[j])
        }
        mx <- max(log1, log0)
        post[i] <- exp(log1 - mx) / (exp(log1 - mx) + exp(log0 - mx))
    }
    post
}

# --- (b) gold-augmented label model -------------------------------

#' Estimate LF accuracies directly from m_gold gold-labeled examples,
#' then estimate the class prior from the gold labels. LFs that
#' abstain on every gold example fall back to the gold-free estimate.
#'
#' @param L_gold    m_gold x m vote matrix on gold examples.
#' @param Y_gold    length m_gold true labels.
#' @param fallback  a gold-free fit for LFs unobserved on the gold set.
fit_label_model_gold <- function(L_gold, Y_gold, fallback = NULL) {
    m <- ncol(L_gold)
    acc <- numeric(m)
    for (j in seq_len(m)) {
        v <- L_gold[, j]
        ok <- !is.na(v)
        if (sum(ok) >= 1) {
            acc[j] <- mean(v[ok] == Y_gold[ok])
        } else if (!is.null(fallback)) {
            acc[j] <- fallback$acc[j]
        } else {
            acc[j] <- 0.5
        }
    }
    pi_hat <- mean(Y_gold)
    list(acc = acc, pi = pi_hat)
}

#' Combine gold-augmented accuracy estimates with the gold-free fit.
#' Gold pins accuracies; the combined model uses the gold accuracies
#' and the gold prior.
fit_label_model_combined <- function(L_all, L_gold, Y_gold) {
    gf <- fit_label_model_goldfree(L_all, better_than_random = TRUE)
    fit_label_model_gold(L_gold, Y_gold, fallback = gf)
}

# --- (c) oracle ---------------------------------------------------

#' Oracle: knows the true label. Used as the recovery ceiling.
fit_label_model_oracle <- function(sim) {
    m <- ncol(sim$L)
    acc <- numeric(m)
    for (j in seq_len(m)) {
        v <- sim$L[, j]; ok <- !is.na(v)
        acc[j] <- if (sum(ok) > 0) mean(v[ok] == sim$Y[ok]) else 0.5
    }
    list(acc = acc, pi = mean(sim$Y))
}

# =================================================================
# SECTION 3: diagnostics
# =================================================================

#' True-label recovery accuracy: fraction of examples whose
#' MAP label from the posterior matches the true label.
recovery_accuracy <- function(post, Y) {
    yhat <- as.integer(post >= 0.5)
    mean(yhat == Y)
}

#' RMSE of estimated LF accuracies against the truth.
acc_rmse <- function(acc_hat, acc_true) {
    sqrt(mean((acc_hat - acc_true)^2))
}

#' Agreement-rate residual (Theorem T3 diagnostic): for a fitted
#' model, the gap between model-implied and empirical pairwise
#' agreement rates, on the raw {0,1} vote scale.
#'
#' Model-implied agreement of LFs j, k (both vote), marginalizing Y:
#'   sum_y P(Y=y) [ acc_j*acc_k + (1-acc_j)*(1-acc_k) ]   (j,k agree
#'   when both correct or both wrong; independent given Y).
#' Empirical agreement: fraction of both-vote examples with equal vote.
agreement_residual <- function(L, fit) {
    m <- ncol(L)
    acc <- pmin(pmax(fit$acc, 1e-6), 1 - 1e-6)
    resids <- c()
    for (j in seq_len(m - 1)) {
        for (k in (j + 1):m) {
            ok <- !is.na(L[, j]) & !is.na(L[, k])
            if (sum(ok) == 0) next
            emp <- mean(L[ok, j] == L[ok, k])
            # Independent-given-Y model agreement (prior-free: agree
            # iff both correct or both wrong).
            model <- acc[j] * acc[k] + (1 - acc[j]) * (1 - acc[k])
            resids <- c(resids, emp - model)
        }
    }
    list(max_abs = max(abs(resids)), median_abs = median(abs(resids)),
         mean_abs = mean(abs(resids)), residuals = resids)
}

#' Rank deficit of the centered pairwise agreement matrix relative to
#' the rank-one (conditionally independent) structure A_jk = a_j a_k.
#'
#' Under conditional independence the OFF-DIAGONAL of the centered
#' agreement matrix A is exactly the outer product a a^T. We estimate
#' the margin vector a from the triplet relation
#'   a_j^2 = (A_jk A_jl) / A_kl
#' (averaged over helper pairs), reconstruct the rank-one model
#' a a^T, and measure the residual on the off-diagonal. With perfectly
#' conditionally independent LFs the residual is Monte-Carlo noise and
#' the effective deficit is 0; LF dependence leaves a structured
#' residual whose effective rank is the deficit r of Theorem T4.
#'
#' @return list with the estimated margins, the off-diagonal residual
#'         matrix, its Frobenius norm relative to A, and the count of
#'         residual singular values above tol * (largest sv of A).
agreement_rank_deficit <- function(L, tol = 0.10) {
    A <- pairwise_agreement(L)
    m <- nrow(A)

    # Estimate the margin vector a from the triplet identity.
    a2 <- numeric(m)
    for (j in seq_len(m)) {
        helpers <- setdiff(seq_len(m), j)
        vals <- c()
        # average over all helper pairs for stability
        for (idx in seq_len(length(helpers) - 1)) {
            for (idx2 in (idx + 1):length(helpers)) {
                k <- helpers[idx]; l <- helpers[idx2]
                d <- A[k, l]
                if (!is.na(d) && abs(d) > 1e-6) {
                    vals <- c(vals, (A[j, k] * A[j, l]) / d)
                }
            }
        }
        a2[j] <- if (length(vals)) median(vals) else NA_real_
    }
    a_hat <- sqrt(pmax(a2, 0))

    # Rank-one model on the off-diagonal, residual = A - a a^T there.
    model <- outer(a_hat, a_hat)
    resid <- A - model
    diag(resid) <- 0
    resid[is.na(resid)] <- 0
    resid_sym <- (resid + t(resid)) / 2

    sv_resid <- svd(resid_sym, nu = 0, nv = 0)$d
    A_scale <- {
        A0 <- A; diag(A0) <- 0; A0[is.na(A0)] <- 0
        max(svd((A0 + t(A0)) / 2, nu = 0, nv = 0)$d)
    }
    eff_deficit <- sum(sv_resid > tol * A_scale)
    resid_fro <- sqrt(sum(resid_sym^2))

    list(margins = a_hat, residual = resid_sym,
         singular_values = sv_resid, resid_fro = resid_fro,
         resid_rel = resid_fro / max(A_scale, 1e-12),
         eff_deficit = eff_deficit)
}
