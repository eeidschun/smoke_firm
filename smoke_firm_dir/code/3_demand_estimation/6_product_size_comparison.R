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
out_dir <- file.path(OUT_DIR,"demand_estimation","specification_comparison","product_size")
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
coef_rows<-test_rows<-check_rows<-list();models<-list()
G<-uniqueN(d$month);n<-nrow(d)
for(i in seq_len(nrow(specs))) {
 s<-specs[i];endog<-switch(s$estimator,"Full IV"=c("p_it","ln_s_i_g"),"OLS"=character(),
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
saveRDS(d,file.path(out_dir,"estimation_sample.rds"))
writeLines(c(paste(names(tools::md5sum(c(input,size_input))),tools::md5sum(c(input,size_input)))),file.path(out_dir,"input_hashes.txt"))
cell<-function(id0,param){x<-cc[id==id0 & parameter==param];if(!nrow(x))return("--");sprintf("%.3f (%.3f)",x$estimate,x$std_error)}
row<-function(label,values)paste0("| ",label," | ",paste(values,collapse=" | ")," |")
lines<-c("## Product size and UPC variety: common complete-case sample","",
 sprintf("All sixteen models use N = %d and %d month clusters. Excluded firm-months are listed in excluded_firm_months.csv; unresolved BLU UPC 088796900752 is not filled automatically. No incomplete-UPC mean is substituted; the entire firm-month is excluded. Existing shares, prices, market totals and instruments are retained.",n,G),"",
 "Size is the unweighted mean mL per cartridge/disposable over eligible device UPCs. Bottles and mixed types are excluded from that mean. Variety is log(n_upcs), counting all distinct eligible UPCs (positive sales and at least three stores), including bottles. Nicotine, size and variety are treated as exogenous controls; endogenous assortment choice remains a concern. Price and within-nest log share are jointly instrumented by geographic tax and the indicated count. No month FE. Standard errors are clustered by month.","")
for(group0 in unique(specs$group)){
 ss<-specs[group==group0];ids<-ss$id
 lines<-c(lines,paste("###",group0),"",
 row("",ids),"|---|---:|---:|---:|---:|",
 row("Firm FE",ifelse(ss$firm_FE,"Yes","No")),row("Count IV",ifelse(ss$count=="n_brands_3st","National","Geographic")))
 for(param in c("alpha","beta_a","beta_size","beta_variety","sigma"))lines<-c(lines,row(param,vapply(ids,cell,character(1),param=param)))
 lines<-c(lines,row("N",rep(n,4)))
 for(outcome0 in c("p_it","ln_s_i_g"))lines<-c(lines,row(paste(outcome0,"first-stage F"),vapply(ids,function(id0)sprintf("%.2f",tt[id==id0 & outcome==outcome0,F_month_clustered]),character(1))))
 lines<-c(lines,"")
}
lines<-c(lines,"First-stage F values are joint month-clustered tests of excluded instruments, not conditional weak-identification statistics. Size exogeneity is an assumption. Reviewed retail pack-volume corrections are propagated through the rebuilt sales panel; the NCP market-size input is unchanged. All coefficients and structural residuals passed an independent explicit-dummy QR 2SLS check.","",
 "Compare S, V and SV against B with the same instrument and fixed effects to isolate control effects. All sixteen columns retain the same sample, including variety-only models that do not require size themselves.", "",
 "Detailed models, coefficients, first stages, checks, estimation sample and excluded firm-months are saved under specification_comparison/product_size/.")
writeLines(lines,file.path(out_dir,"README.md"))
writeLines(lines,"smoke_firm_dir/code/3_demand_estimation/product_size_specification.md")
print(cc[parameter %in% c("alpha","sigma","beta_size")])
