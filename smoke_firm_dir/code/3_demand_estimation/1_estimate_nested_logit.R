## Two exploratory nested-logit IV/2SLS specifications, identical sample.
## y = intercept + beta_a*a_it - alpha*p_it + sigma*ln_s_i_g + xi_it.
## Both endogenous regressors jointly use TaxIV_geo and the selected count.
## Baseline: intercept, no fixed effects, no regression weights; month-clustered
## inference. This does not address dependence across months or prove exclusion.
## Input: input/demand_instrument_candidates.rds (build/9).
## Outputs: output/demand_estimation/; canonical inputs are never overwritten.
rm(list = ls())
suppressPackageStartupMessages({library(data.table); library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(OUT_DIR, "demand_estimation")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
input <- file.path(SUPPORT_DIR, "demand_instrument_candidates.rds")
d <- as.data.table(readRDS(input))
needed <- c("month", "year", "brand", "y", "p_it", "a_it", "ln_s_i_g",
            "s_it", "s_g", "s_0", "TaxIV_geo", "n_brands_3st", "n_brands_overlap")
stopifnot(all(needed %in% names(d)), !anyNA(d[, ..needed]),
          !anyDuplicated(d[, .(month, brand)]))
numeric_cols <- setdiff(needed, c("month", "brand"))
stopifnot(all(vapply(d[, ..numeric_cols], function(x) all(is.finite(x)), logical(1))),
          all(d$s_it > 0 & d$s_it < d$s_g), all(d$s_0 > 0 & d$s_0 < 1),
          max(abs(d$s_0 + d$s_g - 1)) < 1e-10,
          max(abs(d$y - (log(d$s_it)-log(d$s_0)))) < 1e-10,
          max(abs(d$ln_s_i_g - log(d$s_it/d$s_g))) < 1e-10)
setorder(d, brand, month)
specs <- c(national_count="n_brands_3st", geographic_count="n_brands_overlap")
models <- coefficients <- first_stages <- residuals <- checks <- identification <- list()
cluster_df <- uniqueN(d$month)-1L
for (spec in names(specs)) {
  count <- specs[[spec]]
  formula <- as.formula(paste("y ~ a_it | p_it + ln_s_i_g ~ TaxIV_geo +", count))
  model <- feols(formula, data=as.data.frame(d), vcov=~month, data.save=TRUE)
  stopifnot(nobs(model)==nrow(d), length(coef(model))==4L)
  # Independent QR-based 2SLS calculation checks instrument placement, signs,
  # coefficient ordering and the use of observed (not first-stage fitted) X.
  X <- cbind(1, d$p_it, d$ln_s_i_g, d$a_it)
  Z <- cbind(1, d$a_it, d$TaxIV_geo, d[[count]])
  stopifnot(qr(Z)$rank==ncol(Z))
  Xhat <- qr.fitted(qr(Z), X)
  stopifnot(qr(Xhat)$rank==ncol(Xhat))
  independent <- qr.solve(Xhat, d$y)
  terms <- c("(Intercept)", "fit_p_it", "fit_ln_s_i_g", "a_it")
  b <- coef(model)[terms]
  stopifnot(max(abs(b-independent)) < 1e-7)
  xi <- d$y-as.vector(X %*% b)
  stopifnot(max(abs(xi-resid(model))) < 1e-8)
  # Check the clustered sandwich independently, using structural IV residuals.
  bread <- solve(crossprod(Xhat))
  scores <- rowsum(Xhat * xi, group=d$month)
  G <- uniqueN(d$month); n <- nrow(d); K <- ncol(X)
  sandwich <- bread %*% crossprod(scores) %*% bread * G/(G-1) * (n-1)/(n-K)
  stopifnot(max(abs(sandwich-vcov(model)[terms,terms])) < 1e-7)
  ct <- coeftable(model)[terms,,drop=FALSE]
  coef_rows <- data.table(specification=spec, parameter=c("intercept","alpha","sigma","beta_a"),
    estimate=c(b[1],-b[2],b[3],b[4]), std_error=ct[,2], p_value=ct[,4])
  coef_rows[, `:=`(ci_low=estimate-qt(.975,cluster_df)*std_error,
                   ci_high=estimate+qt(.975,cluster_df)*std_error)]
  coefficients[[spec]] <- coef_rows
  checks[[spec]] <- data.table(specification=spec, n=n, months=G, firms=uniqueN(d$brand),
    alpha=-b[2], sigma=b[3], alpha_positive=-b[2]>0,
    sigma_admissible=b[3]>=0 & b[3]<1,
    admissible_for_cost_recovery=(-b[2]>0 && b[3]>=0 && b[3]<1),
    qr_coefficient_error=max(abs(b-independent)), sandwich_error=max(abs(sandwich-vcov(model)[terms,terms])))
  residuals[[spec]] <- data.table(specification=spec, month=d$month, year=d$year,
    brand=d$brand, y=d$y, fitted_structural=d$y-xi, xi_hat=xi)
  for (outcome in c("p_it", "ln_s_i_g")) {
    fs <- feols(reformulate(c("a_it","TaxIV_geo",count),response=outcome),
                data=as.data.frame(d), vcov=~month)
    for (test in c("excluded_joint","tax_incremental","count_incremental")) {
      tested <- switch(test, excluded_joint=c("TaxIV_geo",count),
                       tax_incremental="TaxIV_geo",count_incremental=count)
      remaining <- setdiff(c("a_it","TaxIV_geo",count),tested)
      restricted <- lm(reformulate(remaining,response=outcome),data=d)
      rss_r <- sum(resid(restricted)^2); rss_u <- sum(resid(fs)^2)
      f_iid <- ((rss_r-rss_u)/length(tested))/(rss_u/(n-4))
      bb <- coef(fs)[tested]; vv <- vcov(fs)[tested,tested,drop=FALSE]
      f_cluster <- as.numeric(crossprod(bb,solve(vv,bb)))/length(tested)
      first_stages[[length(first_stages)+1]] <- data.table(specification=spec,outcome,test,
        F_iid=f_iid, F_month_clustered=f_cluster,
        p_month_clustered=pf(f_cluster,length(tested),cluster_df,lower.tail=FALSE),
        df1=length(tested),df2_cluster=cluster_df,partial_R2=(rss_r-rss_u)/rss_r)
    }
  }
  # Record package limitations explicitly; do not substitute another statistic.
  kp <- tryCatch(fitstat(model,"kpr",verbose=FALSE),error=function(e)e)
  identification[[spec]] <- list(kleibergen_paap=if(inherits(kp,"error")) NULL else kp,
    status=if(inherits(kp,"error")) paste("Unavailable:",conditionMessage(kp)) else "Computed by fixest",
    overidentification="Not available: exactly identified (2 excluded IVs, 2 endogenous regressors).")
  models[[spec]] <- model
}
fwrite(rbindlist(coefficients),file.path(out_dir,"coefficients.csv"))
fwrite(rbindlist(first_stages),file.path(out_dir,"first_stage_diagnostics.csv"))
fwrite(rbindlist(residuals),file.path(out_dir,"residuals.csv"))
fwrite(rbindlist(checks),file.path(out_dir,"model_checks.csv"))
fwrite(unique(d[,.(year,brand)])[,.(n_incumbents=.N),by=year][order(year)],
       file.path(out_dir,"incumbents_by_year.csv"))
saveRDS(list(models=models, identification=identification, specifications=specs,
             input_md5=unname(tools::md5sum(input)),input=input,
             settings=list(intercept=TRUE,fixed_effects=FALSE,weights=FALSE,vcov="month cluster")),
        file.path(out_dir,"demand_models.rds"))
writeLines(capture.output(sessionInfo()),file.path(out_dir,"session_info.txt"))
print(rbindlist(coefficients)); print(rbindlist(checks))
if (any(!rbindlist(checks)$admissible_for_cost_recovery))
  warning("An estimated model fails alpha/sigma restrictions. Do not use it for cost recovery; estimates were not clipped.")
