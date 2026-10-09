## OLS diagnostic of the inverted nested-logit equation. Both price and
## within-nest share are uninstrumented. Same firm FE, sample and month
## clustering as script 3; alpha is the signed price coefficient.
rm(list=ls())
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
input <- file.path(SUPPORT_DIR,"demand_instrument_candidates.rds")
d <- as.data.table(readRDS(input));setorder(d,brand,month)
cols <- c("brand","month","y","a_it","p_it","ln_s_i_g")
stopifnot(!anyNA(d[,..cols]),!anyDuplicated(d[,.(brand,month)]))
model <- feols(y~a_it+p_it+ln_s_i_g|brand,data=as.data.frame(d),vcov=~month,data.save=TRUE)
stopifnot(nobs(model)==nrow(d))
# Independent explicit-dummy OLS check of absorbed-FE coefficients/residuals.
reference <- lm(y~0+factor(brand)+a_it+p_it+ln_s_i_g,data=d)
terms <- c("p_it","ln_s_i_g","a_it")
stopifnot(max(abs(coef(model)[terms]-coef(reference)[terms]))<1e-9,
          max(abs(resid(model)-resid(reference)))<1e-9)
ct <- coeftable(model)[terms,,drop=FALSE];ci<-confint(model)[terms,,drop=FALSE]
cc <- data.table(specification="OLS_firm_FE",parameter=c("alpha","sigma","beta_a"),
  estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],ci_low=ci[,1],ci_high=ci[,2])
out_dir<-file.path(OUT_DIR,"demand_estimation","ols_diagnostic")
dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
fwrite(cc,file.path(out_dir,"coefficients.csv"))
fwrite(data.table(month=d$month,brand=d$brand,y=d$y,xi_hat=resid(model)),file.path(out_dir,"residuals.csv"))
saveRDS(list(model=model,input_md5=unname(tools::md5sum(input))),file.path(out_dir,"model.rds"))
writeLines(capture.output(sessionInfo()),file.path(out_dir,"session_info.txt"))
lines<-c("# OLS diagnostic: firm FE, no month FE", "",
  sprintf("%d observations; %d firms; %d month clusters. Both price and within-nest share are uninstrumented.",nrow(d),uniqueN(d$brand),uniqueN(d$month)),
  "Alpha is the signed price coefficient. There is only one OLS specification: the count instruments are not used.","",
  "| Parameter | Estimate | Clustered SE | 95% CI |","|---|---:|---:|---|")
for(i in seq_len(nrow(cc)))lines<-c(lines,sprintf("| %s | %.5f | %.5f | [%.5f, %.5f] |",cc$parameter[i],cc$estimate[i],cc$std_error[i],cc$ci_low[i],cc$ci_high[i]))
lines<-c(lines,"","The point estimate of sigma is inside [0,1), but its 95% confidence interval includes 1.",
  "The prior firm-FE IV sigma estimates are 3.85986 (national count) and 3.94210 (geographic count).",
  "This contrast motivates investigation of the identifying variation and joint instrument strength; it does not establish instrument invalidity. OLS may be biased by endogeneity of both regressors.",
  "The dependent variable also equals within-nest log share plus log(s_g/s_0), so an OLS slope near one is not independent validation of the structural specification.",
  "Coefficients and residuals were verified with an independent explicit-firm-dummy OLS regression. No cost recovery is performed.")
writeLines(lines,file.path(out_dir,"README.md"));print(cc)
