## Compare policies on exactly their observed support; no extrapolation.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
out<-file.path(PRELIM_DIR,"state_price_tax_diagnostic","policy_overlap")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
path<-file.path(FIRM_DIR,"raw","demand_side_first_stage_data","mypricedt.RData")
e<-new.env();load(path,e);p<-as.data.table(e$mypricedt)[alt=="ecigarette"]
codes<-c(CA="06",IL="17",FL="12",TX="48",VA="51",KY="21",MO="29",MA="25")
p[,STATE:=unname(codes[store_state_descr])]
pol<-c("SFA","lic","self_service_law","min_age")
stopifnot(!anyNA(p$STATE),!anyDuplicated(p[,.(STATE,year_month)]),!anyNA(p[,..pol]))
for(v in pol)set(p,j=v,value=as.integer(p[[v]]))
s<-readRDS(file.path(PRELIM_DIR,"state_price_tax_diagnostic","state_month.rds"))
d<-merge(s,p[,c("STATE","year_month",pol),with=FALSE],by=c("STATE","year_month"))
stopifnot(nrow(d)==nrow(p),nrow(d)==192L)
fwrite(d,file.path(out,"estimation_sample.csv"))
models<-list()
for(y in c("price","price_volume"))for(fe in c("pooled","state","month","state_month"))for(control in c(FALSE,TRUE)){
  rhs<-if(control)paste("tax +",paste(pol,collapse=" + ")) else "tax"
  fixed<-switch(fe,pooled="",state=" | STATE",month=" | year_month",state_month=" | STATE + year_month")
  nm<-paste(y,fe,if(control)"policies" else "baseline",sep="_")
  models[[nm]]<-feols(as.formula(paste(y,"~",rhs,fixed)),d,vcov=~STATE+year_month)
}
r<-rbindlist(lapply(names(models),function(nm){m<-models[[nm]];ct<-coeftable(m);ci<-confint(m,"tax");data.table(model=nm,n=nobs(m),tax=ct["tax",1],se=ct["tax",2],p=ct["tax",4],lo=ci[1],hi=ci[2],dropped=paste(m$collin.var,collapse=", "))}))
fwrite(r,file.path(out,"results.csv"));saveRDS(models,file.path(out,"models.rds"))
fwrite(rbindlist(lapply(names(models),function(nm){ct<-as.data.table(coeftable(models[[nm]]),keep.rownames="term");ct[,model:=nm];ct})),file.path(out,"all_coefficients.csv"))
lines<-c("# Policy overlap diagnostic","","Source: raw/demand_side_first_stage_data/mypricedt.RData, object mypricedt. Only alt=ecigarette is used. Policy values are observed, not carried forward or imputed.","",
"192 observations in eight states and 59 distinct months, spanning March 2018–November 2023, with irregular coverage. Current retail price and tax (real dollars/mL) are matched to those exact state-months. The old price is per count and is not substituted. The source contains no tau_per_ct_real, so the old regression cannot be reproduced as supplied.","",
"All comparisons use the same 192 rows. Errors clustered by state and month; only eight state clusters, so conventional p-values and intervals require caution. fixest reported a non-positive-semidefinite covariance adjustment during fitting. These are descriptive sensitivity checks. min_age is constant TRUE and is absorbed. Other policies may be absorbed by fixed effects; dropped variables are listed below. No canonical input or demand fit changed.","",
"| Model | Tax slope | SE | 95% CI | Dropped |","|---|---:|---:|---|---|")
for(i in seq_len(nrow(r))){z<-r[i];lines<-c(lines,sprintf("| %s | %.4f | %.4f | [%.4f, %.4f] | %s |",z$model,z$tax,z$se,z$lo,z$hi,z$dropped))}
lines<-c(lines,"","Run: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/17_state_policy_price_tax_diagnostic.R`. Complete 2013–2023 policy coverage remains unavailable. These results do not establish the cause of the negative national firm-level tax coefficient.")
writeLines(lines,file.path(out,"README.md"));print(r)
