## Product-size full-IV comparison, with matched-sample baselines.
rm(list=ls())
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
input <- file.path(SUPPORT_DIR,"demand_instrument_candidates.rds")
size_input <- file.path(SUPPORT_DIR,"product_characteristics_firm_month.rds")
d <- as.data.table(readRDS(input))
a <- as.data.table(readRDS(size_input))
stopifnot(!anyDuplicated(a[,.(brand,month)]),!anyDuplicated(d[,.(brand,month)]))
d <- merge(d,a[,.(brand,month,avg_ml_per_ecig,n_upcs,log_upc_variety,n_device_upcs,n_device_size_known)],by=c("brand","month"),all.x=TRUE)
out_dir <- file.path(OUT_DIR,"demand_estimation","specification_comparison","market_size")
dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
fwrite(d[!is.finite(avg_ml_per_ecig),.(brand,month,n_device_upcs,n_device_size_known)],file.path(out_dir,"excluded_firm_months.csv"))
d <- d[is.finite(avg_ml_per_ecig)];setorder(d,brand,month)
needed<-c("y","a_it","p_it","ln_s_i_g","TaxIV_geo","n_brands_3st","n_brands_overlap","avg_ml_per_ecig","log_upc_variety")
stopifnot(all(vapply(d[,..needed],function(x)all(is.finite(x)),logical(1))))
specs<-data.table(id=c(paste0("B",1:4),paste0("S",1:4),paste0("V",1:4),paste0("SV",1:4)),
 estimator="Full IV",firm_FE=rep(c(FALSE,FALSE,TRUE,TRUE),4),
 count=rep(c("n_brands_3st","n_brands_overlap"),8),
 group=rep(c("Baseline","Size","Variety","Size and variety"),each=4),
 size_control=rep(c(FALSE,TRUE,FALSE,TRUE),each=4),
 variety_control=rep(c(FALSE,FALSE,TRUE,TRUE),each=4))
markets <- c(annual="M_t",monthly="M_t_k_monthly",constant="M_t_k_const")
base_specs <- copy(specs)
specs <- rbindlist(lapply(names(markets),function(v) {
 x<-copy(base_specs);x[,`:=`(base_id=id,market=v,id=paste(v,id,sep="_"))];x
}))
d_base <- copy(d)
market_checks <- rbindlist(lapply(names(markets),function(v) {
 M<-d_base[[markets[[v]]]];total<-d_base$s_g*d_base$M_t
 stopifnot(all(is.finite(M)),all(M>total),all(d_base$mL>0))
 data.table(market=v,n=nrow(d_base),min_M=min(M),max_M=max(M),
 min_outside_share=min(1-total/M),max_outside_share=max(1-total/M))
}))
fwrite(market_checks,file.path(out_dir,"market_size_checks.csv"))
coef_rows<-test_rows<-check_rows<-list();models<-list()
G<-uniqueN(d$month);n<-nrow(d)
for(i in seq_len(nrow(specs))) {
 s<-specs[i]
 d<-copy(d_base);M<-d[[markets[[s$market]]]];total<-d$s_g*d$M_t
 d[,y:=log(mL/M)-log1p(-total/M)]
 stopifnot(max(abs(d$ln_s_i_g-log(d$mL/total)))<1e-10)
 endog<-switch(s$estimator,"Full IV"=c("p_it","ln_s_i_g"),"OLS"=character(),
   "Share-only IV"="ln_s_i_g","Price-only IV"="p_it")
 iv<-switch(s$estimator,"Full IV"=c("TaxIV_geo",s$count),"OLS"=character(),
   "Share-only IV"=s$count,"Price-only IV"="TaxIV_geo")
 exog<-setdiff(c("a_it",if(s$size_control) "avg_ml_per_ecig",if(s$variety_control) "log_upc_variety","p_it","ln_s_i_g"),endog)
 fml<-paste("y ~",paste(exog,collapse=" + "))
 if(s$firm_FE)fml<-paste(fml,"| brand")
 if(length(endog))fml<-paste(fml,"|",paste(endog,collapse=" + "),"~",paste(iv,collapse=" + "))
 m<-feols(as.formula(fml),data=as.data.frame(d),vcov=~month,data.save=TRUE)
 stopifnot(nobs(m)==n)
 D<-if(s$firm_FE)model.matrix(~0+factor(brand),d) else matrix(1,n,1)
 X<-cbind(D,as.matrix(d[,c("p_it","ln_s_i_g","a_it",if(s$size_control) "avg_ml_per_ecig",if(s$variety_control) "log_upc_variety"),with=FALSE]))
 Z<-cbind(D,as.matrix(d[,c(exog,iv),with=FALSE]))
 stopifnot(qr(Z)$rank==ncol(Z))
 Xhat<-qr.fitted(qr(Z),X);stopifnot(qr(Xhat)$rank==ncol(Xhat))
 reference<-qr.solve(Xhat,d$y)
 terms<-c("p_it","ln_s_i_g","a_it",if(s$size_control) "avg_ml_per_ecig",if(s$variety_control) "log_upc_variety");terms[terms %in% endog]<-paste0("fit_",terms[terms %in% endog])
 b<-coef(m)[terms];ct<-coeftable(m)[terms,,drop=FALSE]
 stopifnot(max(abs(b-tail(reference,length(terms))))<1e-7,
   max(abs(resid(m)-(d$y-as.vector(X%*%reference))))<1e-7)
 coef_rows[[i]]<-data.table(id=s$id,parameter=c("alpha","sigma","beta_a",if(s$size_control) "beta_size",if(s$variety_control) "beta_variety"),estimate=b,
   std_error=ct[,2],p_value=ct[,4],ci_low=b-qt(.975,G-1)*ct[,2],ci_high=b+qt(.975,G-1)*ct[,2])
 check_rows[[i]]<-data.table(id=s$id,n=n,months=G,alpha_negative=b[1]<0,
   sigma_admissible=b[2]>=0 && b[2]<1,coefficient_check_error=max(abs(b-tail(reference,length(terms)))))
 specs[i,`:=`(endogenous=if(length(endog))paste(endog,collapse=", ") else "None",
   excluded_IVs=if(length(iv))paste(iv,collapse=", ") else "None")]
 for(y in endog) {
   form<-paste(y,"~",paste(c(exog,iv),collapse=" + "));if(s$firm_FE)form<-paste(form,"| brand")
   fs<-feols(as.formula(form),data=as.data.frame(d),vcov=~month)
   bb<-coef(fs)[iv];vv<-vcov(fs)[iv,iv,drop=FALSE]
   F<-as.numeric(crossprod(bb,solve(vv,bb)))/length(iv)
   reduced<-lm(reformulate(c(if(s$firm_FE)"factor(brand)",exog),response=y),data=d)
   r<-sum(resid(reduced)^2);u<-sum(resid(fs)^2)
   test_rows[[length(test_rows)+1]]<-data.table(id=s$id,outcome=y,F_month_clustered=F,
     df1=length(iv),df2=G-1,p_value=pf(F,length(iv),G-1,lower.tail=FALSE),
     partial_R2=(r-u)/r,F_iid=((r-u)/length(iv))/(u/(n-ncol(Z))))
 }
 models[[s$id]]<-m
}
cc<-rbindlist(coef_rows);tt<-rbindlist(test_rows);ck<-rbindlist(check_rows)
fwrite(specs,file.path(out_dir,"specifications.csv"));fwrite(cc,file.path(out_dir,"coefficients.csv"))
fwrite(tt,file.path(out_dir,"first_stages.csv"));fwrite(ck,file.path(out_dir,"model_checks.csv"))
saveRDS(list(models=models,specifications=specs,input_md5=unname(tools::md5sum(input))),file.path(out_dir,"models.rds"))
writeLines(capture.output(sessionInfo()),file.path(out_dir,"session_info.txt"))
saveRDS(d_base,file.path(out_dir,"estimation_sample.rds"))
writeLines(c(paste(names(tools::md5sum(c(input,size_input))),tools::md5sum(c(input,size_input)))),file.path(out_dir,"input_hashes.txt"))
cell<-function(market0,id0,param){x<-cc[id==paste(market0,id0,sep="_") & parameter==param];sprintf("%.3f",x$estimate)}
lines<-c("## Market-size sensitivity (NCP inputs unchanged)","",
 sprintf("All 48 specifications use the same %d complete-size firm-month observations and %d month clusters. The four baseline, size-only, variety-only and combined specifications are each estimated under three market-size constructions. See excluded_firm_months.csv for exclusions.",n,G),"",
 "Annual: the within-year arithmetic mean of household-weighted monthly NCP purchasing intensity times that year's July adult population. Monthly: each month's household-weighted purchasing intensity times the same annual adult population. Constant: the full-period arithmetic mean of the monthly intensity series times annual adult population. No NCP input was rebuilt.","",
 "For each alternative, s_it = firm mL / M_t and s_0t = 1 - total market mL / M_t are recomputed. The within-nest share, prices, nicotine, controls, roster and instruments remain fixed. This isolates the market-size construction; coefficients use signed alpha and month-clustered standard errors (see CSVs). All outside shares were checked positive.","",
 "| Model | Controls | Firm FE | Count IV | Sigma annual | Sigma monthly | Sigma constant | Alpha annual | Alpha monthly | Alpha constant |",
 "|---|---|---|---|---:|---:|---:|---:|---:|---:|")
for(i in seq_len(nrow(base_specs))) {
 s<-base_specs[i]
 values<-c(s$id,s$group,if(s$firm_FE)"Yes" else "No",if(s$count=="n_brands_3st")"National" else "Geographic",
 vapply(names(markets),cell,character(1),id0=s$id,param="sigma"),
 vapply(names(markets),cell,character(1),id0=s$id,param="alpha"))
 lines<-c(lines,paste0("| ",paste(values,collapse=" | ")," |"))
}
lines<-c(lines,"","All 48 models passed independent QR 2SLS coefficient and structural-residual checks. Size and variety exogeneity remain maintained assumptions. Full coefficients, clustered standard errors, first stages and admissibility checks are saved in specification_comparison/market_size/.")
writeLines(lines,file.path(out_dir,"README.md"))
cat("Completed market-size sensitivity:",nrow(specs),"models on",n,"observations.\n")
