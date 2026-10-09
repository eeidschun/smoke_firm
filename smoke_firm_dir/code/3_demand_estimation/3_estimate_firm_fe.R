## Firm-FE alternatives, no month FE. Alpha is the signed price coefficient:
## y_it = mu_i + beta_a*a_it + alpha*p_it + sigma*ln_s_i_g + xi_it.
## Both endogenous variables jointly use geographic tax and one brand count.
## Keep historical no-FE outputs intact; save here under demand_estimation/firm_fe.
rm(list=ls())
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(OUT_DIR,"demand_estimation","firm_fe")
dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
input <- file.path(SUPPORT_DIR,"demand_instrument_candidates.rds")
d <- as.data.table(readRDS(input)); setorder(d,brand,month)
required <- c("month","brand","a_it","p_it","ln_s_i_g","y","TaxIV_geo",
              "n_brands_3st","n_brands_overlap","s_it","s_g","s_0")
stopifnot(all(required %in% names(d)),!anyNA(d[,..required]),
          !anyDuplicated(d[,.(brand,month)]))
for(v in setdiff(required,c("brand","month"))) stopifnot(all(is.finite(d[[v]])))
stopifnot(max(abs(d$y-log(d$s_it/d$s_0)))<1e-10,
          max(abs(d$ln_s_i_g-log(d$s_it/d$s_g)))<1e-10)
specs <- c(national_count="n_brands_3st",geographic_count="n_brands_overlap")
coefs <- diagnostics <- residuals <- effects <- checks <- models <- list()
G <- uniqueN(d$month); df <- G-1L; n <- nrow(d)
D <- model.matrix(~0+factor(brand),data=d)
for(spec in names(specs)) {
  count <- specs[[spec]]
  model <- feols(as.formula(paste("y ~ a_it | brand | p_it + ln_s_i_g ~ TaxIV_geo +",count)),
                  data=as.data.frame(d),vcov=~month,data.save=TRUE)
  terms <- c("fit_p_it","fit_ln_s_i_g","a_it")
  stopifnot(nobs(model)==n,length(coef(model))==3L)
  b <- coef(model)[terms]; ct <- coeftable(model)[terms,,drop=FALSE]
  # Independent dummy-variable 2SLS, rather than the package's absorbed-FE solve.
  X <- cbind(D,d$p_it,d$ln_s_i_g,d$a_it)
  Z <- cbind(D,d$a_it,d$TaxIV_geo,d[[count]])
  stopifnot(qr(Z)$rank==ncol(Z))
  Xhat <- qr.fitted(qr(Z),X);stopifnot(qr(Xhat)$rank==ncol(Xhat))
  independent <- qr.solve(Xhat,d$y)
  error <- max(abs(tail(independent,3)-b));stopifnot(error<1e-7)
  xi <- d$y-as.vector(X%*%independent)
  stopifnot(max(abs(xi-resid(model)))<1e-7)
  coefs[[spec]] <- data.table(specification=spec,parameter=c("alpha","sigma","beta_a"),
    estimate=as.numeric(b),std_error=ct[,2],p_value=ct[,4],
    ci_low=b-qt(.975,df)*ct[,2],ci_high=b+qt(.975,df)*ct[,2])
  checks[[spec]] <- data.table(specification=spec,n=n,months=G,firms=ncol(D),
    alpha=b[1],sigma=b[2],alpha_negative=b[1]<0,sigma_admissible=b[2]>=0 && b[2]<1,
    admissible_for_cost_recovery=b[1]<0 && b[2]>=0 && b[2]<1,independent_error=error)
  residuals[[spec]] <- data.table(specification=spec,month=d$month,brand=d$brand,
    y=d$y,fitted=d$y-xi,xi_hat=xi)
  fe <- fixef(model)$brand
  effects[[spec]] <- data.table(specification=spec,brand=names(fe),firm_intercept=as.numeric(fe))
  for(outcome in c("p_it","ln_s_i_g")) {
    fs <- feols(as.formula(paste(outcome,"~ a_it + TaxIV_geo +",count,"| brand")),
                data=as.data.frame(d),vcov=~month)
    for(test in c("excluded_joint","tax_incremental","count_incremental")) {
      tested <- switch(test,excluded_joint=c("TaxIV_geo",count),tax_incremental="TaxIV_geo",count_incremental=count)
      remain <- setdiff(c("a_it","TaxIV_geo",count),tested)
      restricted <- lm(reformulate(c("factor(brand)",remain),response=outcome),data=d)
      rss_r <- sum(resid(restricted)^2);rss_u<-sum(resid(fs)^2)
      bb<-coef(fs)[tested];vv<-vcov(fs)[tested,tested,drop=FALSE]
      F<-as.numeric(crossprod(bb,solve(vv,bb)))/length(tested)
      diagnostics[[length(diagnostics)+1L]] <- data.table(specification=spec,outcome,test,
        F_month_clustered=F,p_month_clustered=pf(F,length(tested),df,lower.tail=FALSE),
        df1=length(tested),df2=df,partial_R2=(rss_r-rss_u)/rss_r,
        F_iid=((rss_r-rss_u)/length(tested))/(rss_u/(n-ncol(D)-3)))
    }
  }
  models[[spec]]<-model
}
cc<-rbindlist(coefs);ck<-rbindlist(checks);ff<-rbindlist(diagnostics)
fwrite(cc,file.path(out_dir,"coefficients.csv"));fwrite(ck,file.path(out_dir,"model_checks.csv"))
fwrite(ff,file.path(out_dir,"first_stage_diagnostics.csv"))
fwrite(rbindlist(residuals),file.path(out_dir,"residuals.csv"))
fwrite(rbindlist(effects),file.path(out_dir,"firm_effects.csv"))
saveRDS(list(models=models,input_md5=unname(tools::md5sum(input)),specifications=specs,
             settings=list(firm_FE=TRUE,month_FE=FALSE,vcov="month",alpha="signed price coefficient")),
        file.path(out_dir,"models.rds"))
writeLines(capture.output(sessionInfo()),file.path(out_dir,"session_info.txt"))
report<-c("# Firm-fixed-effects demand estimates", "",
  "Equation: y_it = mu_i + beta_a*a_it + alpha*p_it + sigma*ln_s_i_g + xi_it.",
  "Alpha is the signed price coefficient (expected negative). Historical no-FE results report the opposite alpha convention.",
  "Both regressions use geographic tax and one of two alternative count instruments, jointly instrumenting price and within-nest share.",
  sprintf("Same sample: %d observations, %d firms, %d months. Firm FE, no month FE, no weights; standard errors cluster by month.",n,ncol(D),G),"",
  "| Specification | Parameter | Estimate | Clustered SE | 95% CI |","|---|---|---:|---:|---|")
for(i in seq_len(nrow(cc)))report<-c(report,sprintf("| %s | %s | %.5f | %.5f | [%.5f, %.5f] |",cc$specification[i],cc$parameter[i],cc$estimate[i],cc$std_error[i],cc$ci_low[i],cc$ci_high[i]))
report<-c(report,"","## First-stage joint excluded-instrument tests","",
  "| Specification | Outcome | Clustered F | IID F | Partial R2 |","|---|---|---:|---:|---:|")
jj<-ff[test=="excluded_joint"]
for(i in seq_len(nrow(jj)))report<-c(report,sprintf("| %s | %s | %.3f | %.3f | %.4f |",jj$specification[i],jj$outcome[i],jj$F_month_clustered[i],jj$F_iid[i],jj$partial_R2[i]))
report<-c(report,"","## Model checks","")
for(i in seq_len(nrow(ck)))report<-c(report,sprintf("- %s: alpha < 0: %s; 0 <= sigma < 1: %s; admissible for cost recovery on these checks: %s.",ck$specification[i],ck$alpha_negative[i],ck$sigma_admissible[i],ck$admissible_for_cost_recovery[i]))
report<-c(report,"","These first-stage tests are not a complete conditional weak-identification assessment with two endogenous regressors. They do not establish exclusion. Month clustering does not address dependence across months.",
  "The two excluded instruments exactly identify two endogenous regressors, so no overidentification test is available. No marginal-cost recovery is run.",
  "Coefficients and structural residuals were verified against an independent dummy-variable QR 2SLS calculation.",
  sprintf("National and geographic counts coincide in %d/%d observations; both include the focal firm and all eligible fringe brands.", sum(d$n_brands_3st == d$n_brands_overlap), nrow(d)))
writeLines(report,file.path(out_dir,"README.md"));print(cc);print(ck)
