## Standalone diagnostic; preserves all canonical inputs and demand fits.
suppressPackageStartupMessages({library(data.table); library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
setDTthreads(2)
out <- file.path(PRELIM_DIR,"state_price_tax_diagnostic")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
load(file.path(SUPPORT_DIR,"upc_month_niccorr_from_full.RData"))
u <- as.data.table(upc_month_t2)
# Confirm corrected pack volume is constant within every UPC-month, including T2 rows.
u <- u[,.(units=sum(units_sum),ml=sum(mL_sum),ml2=sum(mL_sq_times_unit_sum),
          revenue=sum(revenue_real),brand=first(brand)),by=.(year_month,upc12)]
stopifnot(max(abs(u$ml2/u$units-(u$ml/u$units)^2))<1e-7)
b <- as.data.table(readRDS(file.path(SUPPORT_DIR,"upc_month_store_breadth.rds")))
u <- merge(u[brand!="UNKNOWN" & units>0 & ml>0],b[n_stores>=3,.(year_month,upc12)],by=c("year_month","upc12"))
u[,pack_ml:=ml/units]
cache <- file.path(out,"state_upc_month.rds")
if(file.exists(cache)) {
  d <- readRDS(cache)
} else {
  files <- list.files(RAW_DIR,pattern="^full_.*7467.*\\.RData$",full.names=TRUE)
  stopifnot(length(files)==11)
  parts <- lapply(files,function(f) {
    cat("Reading",basename(f),"\n"); flush.console()
    e<-new.env(); load(f,e)
    x<-as.data.table(e$rms_w_attr)
    x<-x[prod_type=="ec" & units>0 & !is.na(infl_mult) & infl_mult>0,
       .(year_month,upc12=sprintf("%012.0f",as.numeric(upc)),
         STATE=sprintf("%02d",as.integer(fips_state_code)),units,
         revenue=units*price_d_prmult/infl_mult)]
    rm(e); gc(FALSE)
    x<-x[,.(state_units=sum(units),state_revenue=sum(revenue)),by=.(year_month,upc12,STATE)]
    x<-merge(x,u,by=c("year_month","upc12"))
    x[,state_ml:=state_units*pack_ml]
    cat("Collapsed",nrow(x),"eligible state UPC months\n"); flush.console()
    x
  })
  d<-rbindlist(parts)
  checks<-d[,.(units_state=sum(state_units),revenue_state=sum(state_revenue),ml_state=sum(state_ml)),by=.(year_month,upc12)]
  checks<-merge(checks,u,by=c("year_month","upc12"))
  stopifnot(max(abs(checks$units_state/checks$units-1))<1e-8,
            max(abs(checks$revenue_state/checks$revenue-1))<1e-8,
            max(abs(checks$ml_state/checks$ml-1))<1e-8)
  fwrite(checks,file.path(out,"national_reconciliation.csv"))
  saveRDS(d,cache)
}
load(file.path(FIRM_DIR,"raw","ecig_taxes","ec_tax_cotti_per_mL.RData"))
t<-as.data.table(closed_t)[,.(year_month,STATE=sprintf("%02d",as.integer(fips_state_code)),tax=real_tau_per_mL)]
stopifnot(!anyDuplicated(t[,.(year_month,STATE)]))
d<-merge(d,t,by=c("year_month","STATE"),all.x=TRUE)
stopifnot(!anyNA(d$tax),!anyDuplicated(d[,.(year_month,STATE,upc12)]))
d[,price:=state_revenue/state_ml]
stopifnot(all(is.finite(d$price)))
s<-d[,.(price=mean(price),price_volume=sum(state_revenue)/sum(state_ml),tax=first(tax),n_upcs=.N),by=.(STATE,year_month)]
saveRDS(s,file.path(out,"state_month.rds"))
# Optional policy CSV must contain STATE, year_month, SFA, lic, self_service_law, min_age.
policy_path<-Sys.getenv("STATE_POLICY_CSV","")
policy<-c("SFA","lic","self_service_law","min_age")
has_policy<-nzchar(policy_path)
if(has_policy) {
  p<-fread(policy_path,colClasses=c(STATE="character",year_month="character"))
  stopifnot(all(c("STATE","year_month",policy)%in%names(p)),!anyDuplicated(p[,.(STATE,year_month)]))
  p[,STATE:=sprintf("%02d",as.integer(STATE))]
  s<-merge(s,p[,c("STATE","year_month",policy),with=FALSE],by=c("STATE","year_month"),all.x=TRUE)
  d<-merge(d,p[,c("STATE","year_month",policy),with=FALSE],by=c("STATE","year_month"),all.x=TRUE)
  stopifnot(!anyNA(s[,..policy]),!anyNA(d[,..policy]))
}
models<-list()
for(y in c("price","price_volume")) {
  forms<-c(pooled=paste(y,"~ tax"),state_FE=paste(y,"~ tax | STATE"),
           month_FE=paste(y,"~ tax | year_month"),state_month_FE=paste(y,"~ tax | STATE + year_month"))
  if(has_policy) forms<-c(forms,policy=paste(y,"~ tax +",paste(policy,collapse=" + "),"| STATE + year_month"))
  for(nm in names(forms)) models[[paste(y,nm,sep="_")]]<-feols(as.formula(forms[[nm]]),s,vcov=~STATE+year_month)
}
models$upc_state_month_FE<-feols(price~tax|upc12+STATE+year_month,d,vcov=~STATE+year_month)
# UPC-state FE compare each UPC in the same geographic market over time.
models$upc_state_pair_month_FE<-feols(price~tax|upc12^STATE+year_month,d,vcov=~STATE+year_month)
if(has_policy) models$upc_state_policy<-feols(as.formula(paste("price ~ tax +",paste(policy,collapse=" + "),"| upc12^STATE + year_month")),d,vcov=~STATE+year_month)
results<-rbindlist(lapply(names(models),function(nm){m<-models[[nm]];ct<-coeftable(m);ci<-confint(m,"tax"); data.table(model=nm,n=nobs(m),tax_coef=ct["tax",1],se=ct["tax",2],p=ct["tax",4],lo=ci[1],hi=ci[2])}))
fwrite(results,file.path(out,"results.csv"));saveRDS(models,file.path(out,"models.rds"))
print(results)
lines<-c("# State-level price–tax diagnostic","",paste("Run date:",Sys.Date()),"",
"Eligible sample: known-brand UPC-months with positive units/volume and at least three stores nationally. All eligible brands, including fringe. State price is the equal-UPC-weight mean of real revenue/corrected mL. Volume-weighted price is a separate sensitivity check. All state-month FE comparisons use the same rows within each outcome.","",
"Corrected pack mL is constant within every national UPC-month, verified using the saved second volume moment. Raw state sales are multiplied by this corrected capacity. State units, real revenue, and corrected volume reconcile to the canonical national UPC-month panel. No canonical input or demand fit is overwritten.","",
"Tax uses the existing closed-system real-dollar/mL tax series, matching the current instrument construction. This may imperfectly represent refill/open-system products. State prices retain the existing retail price and inflation conventions. No new claim about statutory tax treatment is imposed.","",
"OLS associations; standard errors clustered by state and month. Two-way clustering does not permit arbitrary dependence across states across different months. UPC-state FE hold persistent product/location differences fixed but do not hold time-varying assortment or retail-store composition fixed. Singleton rows may be removed in UPC FE fits; their sample differs from state-month fits.","",
if(has_policy) "Policy controls supplied through STATE_POLICY_CSV; coverage required complete." else "Policy data were not found in the repository. SFA/licensing/self-service/minimum-age comparison remains pending; no values imputed.","",
"| Model | N | Tax slope | SE | 95% CI |","|---|---:|---:|---:|---|")
for(i in seq_len(nrow(results))) {r<-results[i];lines<-c(lines,sprintf("| %s | %d | %.4f | %.4f | [%.4f, %.4f] |",r$model,r$n,r$tax_coef,r$se,r$lo,r$hi))}
lines<-c(lines,"","These regressions diagnose variation and aggregation; they do not validate instrument exclusion or replace the structural nested logit. Full month FE are permitted here because the diagnostic outcome is price, rather than the single-nest inverted demand equation.","",
"Reproduce from repository root: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/16_state_price_tax_diagnostic.R`. Optional: set STATE_POLICY_CSV to a complete e-cigarette state-month policy CSV. Delete only this diagnostic's state_upc_month.rds cache if canonical retail inputs change.")
writeLines(lines,file.path(out,"README.md"))
