## Diagnostic only: force constant outside share; never update Markdown.
## Optional command-line outside shares, e.g. Rscript --vanilla <script> 0.90 0.80
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
root<-file.path(OUT_DIR,"demand_estimation","specification_comparison","market_size")
paths<-file.path(root,c("estimation_sample.rds","models.rds","coefficients.csv"))
hashes<-tools::md5sum(paths)
d<-as.data.table(readRDS(paths[1]));saved<-readRDS(paths[2])
specs<-as.data.table(saved$specifications);old<-fread(paths[3])
args<-commandArgs(trailingOnly=TRUE)
outside<-if(length(args))as.numeric(args)else c(.90,.80)
stopifnot(all(is.finite(outside)),all(outside>0 & outside<1),!anyDuplicated(outside),nrow(d)==528L,nrow(specs)==48L)
out<-file.path(OUT_DIR,"demand_estimation","forced_outside_share")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
ccs<-cks<-models<-list()
for(s0 in outside) {
 dd<-copy(d);Q<-dd$s_g*dd$M_t
 # Impose s_0 = s0, preserving quantities and within-nest shares:
 # M_new=Q/(1-s0); s_i_new=(q_i/Q)*(1-s0).
 dd[,`:=`(M_forced=Q/(1-s0),outside_forced=s0,
  y_forced=ln_s_i_g+log((1-s0)/s0))]
 stopifnot(max(abs(dd$y_forced-log(dd$mL/(dd$M_forced-Q))))<1e-10)
 for(i in seq_len(nrow(specs))) {
  s<-specs[i];exog<-c("a_it",if(s$size_control)"avg_ml_per_ecig",if(s$variety_control)"log_upc_variety")
  iv<-c("TaxIV_geo",s$count)
  f<-paste("y_forced ~",paste(exog,collapse=" + "));if(s$firm_FE)f<-paste(f,"| brand")
  f<-as.formula(paste(f,"| p_it + ln_s_i_g ~",paste(iv,collapse=" + ")))
  m<-feols(f,data=as.data.frame(dd),vcov=~month)
  ct<-coeftable(m);id<-paste(format(s0,trim=TRUE),s$id,sep="_")
  W<-cbind(if(s$firm_FE)model.matrix(~0+factor(brand),dd)else matrix(1,nrow(dd),1),as.matrix(dd[,..exog]))
  X<-cbind(W,as.matrix(dd[,.(p_it,ln_s_i_g)]));Z<-cbind(W,as.matrix(dd[,..iv]))
  ref<-qr.solve(qr.fitted(qr(Z),X),dd$y_forced)
  error<-max(abs(tail(ref,2)-coef(m)[c("fit_p_it","fit_ln_s_i_g")]))
  # A constant outside share makes y = within-nest log share + constant.
  stopifnot(error<1e-7,abs(coef(m)["fit_ln_s_i_g"]-1)<1e-7,
   abs(coef(m)["fit_p_it"])<1e-7,max(abs(resid(m)))<1e-7)
  ccs[[id]]<-data.table(id,original_id=s$id,base_id=s$base_id,original_market=s$market,
   forced_outside_share=s0,group=s$group,firm_FE=s$firm_FE,count=s$count,
   term=rownames(ct),estimate=ct[,1],std_error=ct[,2],n=nobs(m),months=uniqueN(dd$month))
  cks[[id]]<-data.table(id,original_id=s$id,base_id=s$base_id,original_market=s$market,
   forced_outside_share=s0,alpha=coef(m)["fit_p_it"],sigma=coef(m)["fit_ln_s_i_g"],
   original_sigma=old[id==s$id & parameter=="sigma",estimate],QR_error=error,
   max_abs_residual=max(abs(resid(m))))
  models[[id]]<-m
 }
 monthly<-unique(dd[,.(month,M_forced,outside_forced)])
 fwrite(monthly,file.path(out,paste0("market_size_outside_",format(s0,trim=TRUE),".csv")))
}
cc<-rbindlist(ccs);ck<-rbindlist(cks)
tag<-paste(format(outside,trim=TRUE),collapse="_")
fwrite(cc,file.path(out,paste0("coefficients_",tag,".csv")))
fwrite(ck,file.path(out,paste0("comparison_",tag,".csv")))
saveRDS(list(models=models,specifications=specs,outside_shares=outside),file.path(out,paste0("models_",tag,".rds")))
stopifnot(identical(hashes,tools::md5sum(paths)))
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,paste0("input_hashes_",tag,".csv")))
writeLines(c("Diagnostic: outside share fixed at the specified level in every month; liquid quantities and within-nest shares held fixed.",
 "Market size is Q_t/(1-s0). The three original market-size labels duplicate the same forced outcome.",
 "This forces y=ln_s_i_g+log((1-s0)/s0), so sigma=1 and all other slopes=0 algebraically (intercept/firm FE absorb the constant).",
 "Near-zero residuals and standard errors reflect the identity, not empirical precision. This cannot test a monotonic economic response of sigma to outside share.",
 "To preserve monthly variation, a separate exercise could rescale an existing M_t to a specified mean outside share, rather than fix every month's outside share.",
 "No Markdown files or canonical inputs were modified."),file.path(out,paste0("interpretation_",tag,".txt")))
print(ck[,.(runs=.N,min_sigma=min(sigma),max_sigma=max(sigma),max_abs_alpha=max(abs(alpha))),by=forced_outside_share])
