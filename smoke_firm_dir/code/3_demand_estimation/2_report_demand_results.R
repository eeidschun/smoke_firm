## Read saved estimates; produce comparison report and residual diagnostics.
rm(list=ls())
suppressPackageStartupMessages({library(data.table); library(ggplot2)})
source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(OUT_DIR,"demand_estimation")
cc <- fread(file.path(out_dir,"coefficients.csv"))
fs <- fread(file.path(out_dir,"first_stage_diagnostics.csv"))
ck <- fread(file.path(out_dir,"model_checks.csv"))
rr <- fread(file.path(out_dir,"residuals.csv"))
rr[,month:=as.Date(month)]
bundle <- readRDS(file.path(out_dir,"demand_models.rds"))
summary <- rr[,.(mean=mean(xi_hat),sd=sd(xi_hat),min=min(xi_hat),
                 p05=quantile(xi_hat,.05),median=median(xi_hat),
                 p95=quantile(xi_hat,.95),max=max(xi_hat)),by=.(specification,brand)]
fwrite(summary,file.path(out_dir,"residual_summary_by_firm.csv"))
annual <- rr[,.(mean_xi=mean(xi_hat),sd_xi=sd(xi_hat)),by=.(specification,year)]
fwrite(annual,file.path(out_dir,"residual_summary_by_year.csv"))
plot <- ggplot(rr,aes(month,xi_hat,color=brand))+geom_line(linewidth=.4)+
  geom_hline(yintercept=0,linetype="dotted")+facet_wrap(~specification,ncol=1)+
  theme_minimal()+labs(x=NULL,y="Structural demand residual",color="Brand")
ggsave(file.path(out_dir,"residuals_over_time.png"),plot,width=11,height=7,dpi=150,bg="white")
lines <- c("# Preliminary demand estimates", "",
  "Both specifications use the same 7% incumbent sample, unweighted representative price, and geographic tax instrument.",
  "They differ only in the national versus geographic all-brand count. Both regressors are jointly instrumented.",
  sprintf("An intercept is included; no fixed effects or regression weights. Standard errors cluster by month (%d clusters).", uniqueN(rr$month)),
  "These errors allow dependence within a month, not across months. No causal-validity conclusion follows from first-stage significance.", "",
  "| Specification | Parameter | Estimate | Clustered SE | 95% CI |",
  "|---|---|---:|---:|---|")
for(i in seq_len(nrow(cc))) lines <- c(lines,sprintf("| %s | %s | %.5f | %.5f | [%.5f, %.5f] |",
  cc$specification[i],cc$parameter[i],cc$estimate[i],cc$std_error[i],cc$ci_low[i],cc$ci_high[i]))
lines <- c(lines,"","Alpha is the negative of the estimated price coefficient; the model uses -alpha * price.",
  "The intercept is estimated separately; xi_hat is y minus the intercept and all structural regressors evaluated at observed values.","",
  "## Model restrictions", "")
for(i in seq_len(nrow(ck))) lines <- c(lines,sprintf("- %s: alpha > 0: %s; 0 <= sigma < 1: %s. Eligible for cost recovery on these checks: %s.",
  ck$specification[i],ck$alpha_positive[i],ck$sigma_admissible[i],ck$admissible_for_cost_recovery[i]))
lines <- c(lines,"","Out-of-range estimates are retained and flagged, never clipped. No marginal-cost recovery or dynamic estimation is run.","",
  "## First-stage joint excluded-instrument tests", "",
  "| Specification | Outcome | IID F | Month-clustered F | Partial R2 |",
  "|---|---|---:|---:|---:|")
jj <- fs[test=="excluded_joint"]
for(i in seq_len(nrow(jj))) lines<-c(lines,sprintf("| %s | %s | %.3f | %.3f | %.4f |",
  jj$specification[i],jj$outcome[i],jj$F_iid[i],jj$F_month_clustered[i],jj$partial_R2[i]))
lines<-c(lines,"","The CSV additionally reports incremental tax and count tests. These are not conditional weak-identification tests for the two-endogenous-variable system.","")
for(spec in names(bundle$identification)) lines<-c(lines,paste0("- ",spec," Kleibergen-Paap diagnostic: ",bundle$identification[[spec]]$status))
lines<-c(lines,"","The system is exactly identified, so there is no overidentification test. Exclusion remains an assumption.","",
  "## Residual diagnostics", "",
  "See residuals_over_time.png and residual_summary_by_firm.csv / residual_summary_by_year.csv for trends and outliers.",
  "The sample changes composition over time; annual residual averages also reflect that composition.",
  "In the initial runs, firm residual paths show persistent differences and substantial time movement; they are not featureless noise.","",
  "## Verification", "",
  "The estimator checks share identities, duplicate keys, finite inputs, common sample size, rank, structural residual reconstruction,",
  "and agreement with an independent QR 2SLS solution and month-clustered sandwich covariance.","",
  "Implementation reference: https://lrberge.github.io/fixest/reference/feols.html",
  "Diagnostic reference: https://lrberge.github.io/fixest/reference/fitstat.html")
writeLines(lines,file.path(out_dir,"README.md"))
cat("Wrote demand comparison report and residual diagnostics to",out_dir,"\n")
