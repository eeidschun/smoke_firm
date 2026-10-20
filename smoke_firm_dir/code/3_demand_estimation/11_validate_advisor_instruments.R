suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
root<-file.path(OUT_DIR,"demand_estimation")
out<-file.path(root,"advisor_instruments_2026-10-20")
cc<-fread(file.path(out,"coefficients.csv"));fs<-fread(file.path(out,"first_stage_coefficients.csv"))
saved<-readRDS(file.path(out,"models.rds"));d<-as.data.table(readRDS(file.path(out,"candidate_panel.rds")))
old<-readRDS(file.path(root,"specification_comparison","product_size","models.rds"))$models
for(k in c("SV3","SV4")) {
 id<-paste("SV_FE_available_p_it",if(k=="SV3")"National" else "Geographic",sep="_")
 stopifnot(max(abs(unname(coef(saved$models[[id]]))-unname(coef(old[[k]]))))<1e-8,
           max(abs(unname(vcov(saved$models[[id]]))-unname(vcov(old[[k]]))))<1e-8)
}
focus<-cc[controls==TRUE & firm_FE==TRUE & sample=="common_lag"]
errors<-list()
for(id0 in unique(focus$id)) {
 info<-focus[id==id0][1];dd<-d[is.finite(avg_ml_per_ecig)&is.finite(log_upc_variety)&is.finite(a_lag1)]
 iv<-saved$instrument_sets[[info$instrument_set]];dd[,price:=get(info$price_measure)]
 exog<-c("a_it","avg_ml_per_ecig","log_upc_variety")
 W<-cbind(model.matrix(~0+factor(brand),dd),as.matrix(dd[,..exog]));Z<-cbind(W,as.matrix(dd[,..iv]))
 for(y0 in c("price","ln_s_i_g")) {
  other<-if(y0=="price")"ln_s_i_g" else "price"
  f<-as.formula(paste(y0,"~",paste(exog,collapse=" + "),"| brand |",other,"~",paste(iv,collapse=" + ")))
  m<-feols(f,data=as.data.frame(dd));r<-resid(m)
  fit<-lm(r~Z-1);ind<-(ncol(W)+1):ncol(Z)
  b<-coef(fit)[ind];v<-sandwich::vcovCL(fit,cluster=dd$month,type="HC1",cadjust=TRUE)[ind,ind]
  reference<-as.numeric(crossprod(b,solve(v,b)))/(length(iv)-1)
  expected<-unique(fs[id==id0 & outcome==y0,SW_F])
  stopifnot(length(expected)==1L,abs(reference-expected)<1e-6)
  errors[[paste(id0,y0)]]<-data.table(id=id0,outcome=y0,SW_check_error=abs(reference-expected))
 }
}
fwrite(rbindlist(errors),file.path(out,"validation.csv"))
selection<-focus[instrument_set %in% c("National","Geographic","Annual","Monthly","Lag","Annual_Lag","Monthly_Lag") & term=="fit_ln_s_i_g"]
print(merge(selection[,.(id,price_measure,instrument_set,sigma=estimate,se=std_error,n,months)],
 unique(fs[outcome=="ln_s_i_g",.(id,SW_F)]),by="id"))
print(fread(file.path(out,"incumbent_counts.csv"))[,.(annual=unique(incumbent_annual),monthly_min=min(incumbent_monthly),monthly_max=max(incumbent_monthly)),by=year])
print(fread(file.path(out,"missing_lag.csv")))
writeLines(c("Baseline SV3/SV4 coefficients and covariance matrices reproduce saved fits.",
 "All 76 focal-model conditional F statistics pass independent fixest conditional-IV and full-design sandwich::vcovCL checks.",
 "All 224 models passed independent explicit-dummy QR slope checks in the estimation script."),file.path(out,"validation.txt"))
lines<-c("# Findings: advisor instrument comparisons","",
 "Focal comparison: both controls and firm FE, 524 firm-months and 131 month clusters. Common sample excludes January 2013 (four incumbent observations lack December 2012 quality), plus the existing BLU 2018 size exclusions. Tax is retained throughout. Entries are sigma (month-clustered SE). All first-stage coefficients, price coefficients, intervals and broader comparisons are in the CSVs.","",
 "| Instrument set beyond tax | Sigma: unweighted price | Sigma: volume-weighted price | Share SW F: unweighted | Share SW F: volume weighted |",
 "|---|---:|---:|---:|---:|")
for(set0 in c("National","Geographic","Annual","Monthly","Lag","Annual_Lag","Monthly_Lag")) {
 rows<-selection[instrument_set==set0]
 a<-rows[price_measure=="p_it"];b<-rows[price_measure=="p_it_volume_weighted"]
 fa<-unique(fs[id==a$id & outcome=="ln_s_i_g",SW_F]);fb<-unique(fs[id==b$id & outcome=="ln_s_i_g",SW_F])
 lines<-c(lines,sprintf("| %s | %.3f (%.3f) | %.3f (%.3f) | %.2f | %.2f |",set0,a$estimate,a$std_error,b$estimate,b$std_error,fa,fb))
}
lines<-c(lines,"",
 "Annual count with volume-weighted price gives alpha -0.489 (SE 0.137) and sigma 0.162 (SE 0.376; conventional 95% CI -0.582 to 0.907). Annual count plus lag gives sigma 0.213 (SE 0.357). The monthly count alone gives sigma -0.118 (SE 0.675), below the maintained lower bound, while monthly plus lag gives 0.069 (SE 0.605). These are sensitivity results, not a selected model. Conventional confidence intervals are not weak-IV-robust confidence sets.","",
 "Adding an incumbent count to an existing brand-count baseline generally leaves focal sigma above one: annual additions give 1.229/1.201 (unweighted national/geographic) and 1.202/1.155 (volume weighted); monthly additions give 1.666/1.649 and 1.876/1.904. Replacing the original count and adding a new count impose different moment conditions and need not deliver similar estimates.","",
 "Lag alone means tax plus lagged a_it, with neither brand count nor incumbent count. It has very low conditional share F (0.10 unweighted, 0.65 weighted), so the unweighted admissible sigma point estimate is uninformative as a resolution. Lagged quality validity requires considering persistence in unobserved demand; annual and monthly threshold counts also require an exclusion argument because they depend on observed sales shares. No overidentification/exclusion test is reported by this comparison.","",
 "Annual-roster monthly counts are exactly duplicate annual counts. The distinct Monthly specification recomputes the >7% threshold using each month's eligible volume, without changing demand alternatives. Monthly counts range 3-7; annual counts range 3-6. This construction is explicitly separate from changing the demand roster.","",
 "Validation: saved SV3/SV4 baseline coefficients and covariance matrices reproduce; all 224 new fits pass QR coefficient checks; all 76 focal conditional F statistics pass independent conditional-IV residual/full-design sandwich checks. Source hashes are unchanged. See README.md for instrument definitions and reproduction commands.")
writeLines(lines,file.path(out,"findings.md"))
