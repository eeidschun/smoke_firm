## Extend the earlier 48-model design to both prices and advisor instruments.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
parent<-"/Users/erineidschun/Desktop/synced_to_GD/PhD/pr/smoke_firm/smoke_firm_dir/output/demand_estimation/sales_weighted_tax_2026-10-27/sales"
out<-file.path(parent,"original_48_grid");dir.create(out,recursive=TRUE,showWarnings=FALSE)
inputs<-c(file.path(parent,c("candidate_panel.rds","instrument_sets.rds")),
 file.path(OUT_DIR,"demand_estimation","specification_comparison","market_size","models.rds"))
hashes<-tools::md5sum(inputs)
d<-as.data.table(readRDS(inputs[1]));sets<-readRDS(inputs[2])$instrument_sets
old<-readRDS(inputs[3])$models
# Every control group retains complete-size rows, as in the original 48 fits.
d<-d[is.finite(avg_ml_per_ecig)&is.finite(log_upc_variety)]
stopifnot(nrow(d)==528L)
markets<-c(annual="M_t",monthly="M_t_k_monthly",constant="M_t_k_const")
groups<-list(B=character(),S="avg_ml_per_ecig",V="log_upc_variety",SV=c("avg_ml_per_ecig","log_upc_variety"))
coefs<-checks<-firsts<-specs<-list();models<-list();validation<-list()
for(sample0 in c("available","common_lag")) for(group0 in names(groups)) for(fe in c(FALSE,TRUE)) {
 dd<-copy(d);if(sample0=="common_lag")dd<-dd[is.finite(a_lag1)]
 n<-nrow(dd);G<-uniqueN(dd$month)
 exog<-c("a_it",groups[[group0]])
 W<-cbind(if(fe)model.matrix(~0+factor(brand),dd)else matrix(1,n,1),as.matrix(dd[,..exog]))
 for(price0 in c("p_it","p_it_volume_weighted")) for(set0 in names(sets)) {
  iv<-sets[[set0]];if(sample0=="available" && "a_lag1" %in% iv)next
  dd[,price:=get(price0)]
  design<-paste(sample0,group0,if(fe)"FE" else "noFE",price0,set0,sep="_")
  Z<-cbind(W,as.matrix(dd[,..iv]));qz<-qr(Z);stopifnot(qz$rank==ncol(Z))
  xx<-as.matrix(dd[,.(price,ln_s_i_g)]);xh<-qr.fitted(qz,xx)
  X<-cbind(W,xx);Xh<-qr.fitted(qz,X);stopifnot(qr(Xh)$rank==ncol(Xh))
  H<-qr.Q(qr(qr.resid(qr(W),as.matrix(dd[,..iv]))))
  L<-length(iv);correction<-G/(G-1)*(n-1)/(n-ncol(Z))
  for(j in 1:2) {
   o<-3-j;bc<-qr.solve(cbind(W,xh[,o]),xx[,j])
   r<-xx[,j]-as.vector(cbind(W,xx[,o])%*%bc);u<-qr.resid(qz,r)
   gamma<-crossprod(H,r);scores<-rowsum(H*as.vector(u),as.character(dd$month),reorder=FALSE)
   sw<-as.numeric(crossprod(gamma,solve(crossprod(scores),gamma)))/correction/(L-1)
   # Full-design sandwich calculation checks the conditional F independently.
   auxiliary<-lm(r~Z-1);ind<-(ncol(W)+1):ncol(Z)
   bb<-coef(auxiliary)[ind];vv<-sandwich::vcovCL(auxiliary,cluster=dd$month,type="HC1",cadjust=TRUE)[ind,ind]
   swref<-as.numeric(crossprod(bb,solve(vv,bb)))/(L-1)
   stopifnot(abs(sw-swref)<1e-6)
   f<-paste(colnames(xx)[j],"~",paste(c(exog,iv),collapse=" + "));if(fe)f<-paste(f,"| brand")
   m1<-feols(as.formula(f),data=as.data.frame(dd),vcov=~month);ct<-coeftable(m1)
   joint<-as.numeric(crossprod(coef(m1)[iv],solve(vcov(m1)[iv,iv],coef(m1)[iv])))/L
   firsts[[paste(design,j)]]<-data.table(design_id=design,sample=sample0,controls=group0,firm_FE=fe,price_measure=price0,instrument_set=set0,
    outcome=colnames(xx)[j],term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],
    ordinary_F=joint,SW_F=sw,SW_df1=L-1,SW_df2=G-1,n,months=G,validation_error=abs(sw-swref))
  }
  f<-paste("y_grid ~",paste(exog,collapse=" + "));if(fe)f<-paste(f,"| brand")
  f<-as.formula(paste(f,"| price + ln_s_i_g ~",paste(iv,collapse=" + ")))
  for(market0 in names(markets)) {
   M<-dd[[markets[[market0]]]];Q<-dd$s_g*dd$M_t
   stopifnot(all(M>Q),all(dd$mL>0),max(abs(log(dd$mL/Q)-dd$ln_s_i_g))<1e-10)
   dd[,y_grid:=log(mL/M)-log1p(-Q/M)]
   if(market0=="annual")stopifnot(max(abs(dd$y_grid-dd$y))<1e-10)
   id<-paste(market0,design,sep="_")
   m<-feols(f,data=as.data.frame(dd),vcov=~month,data.save=TRUE)
   reference<-qr.solve(Xh,dd$y_grid)
   terms<-c(exog,"fit_price","fit_ln_s_i_g")
   error<-max(abs(coef(m)[terms]-tail(reference,length(terms))))
   rerror<-max(abs(resid(m)-(dd$y_grid-as.vector(X%*%reference))))
   stopifnot(error<1e-7,rerror<1e-7,nobs(m)==n)
   ct<-coeftable(m);alpha<-coef(m)["fit_price"];sigma<-coef(m)["fit_ln_s_i_g"]
   coefs[[id]]<-data.table(id,design_id=design,market=market0,sample=sample0,controls=group0,firm_FE=fe,
    price_measure=price0,instrument_set=set0,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],
    ci_low=ct[,1]-qt(.975,G-1)*ct[,2],ci_high=ct[,1]+qt(.975,G-1)*ct[,2],n,months=G)
   checks[[id]]<-data.table(id,alpha,sigma,alpha_negative=alpha<0,sigma_admissible=sigma>=0&sigma<1,
    coefficient_error=error,residual_error=rerror)
   specs[[id]]<-data.table(id,design_id=design,market=market0,sample=sample0,controls=group0,firm_FE=fe,
    price_measure=price0,instrument_set=set0,excluded_instruments=paste(iv,collapse=" + "),
    n_excluded=L,overidentification_df=L-2,n,months=G)
   if(FALSE) {
    num<-if(fe)3L else 1L;if(set0=="Geographic")num<-num+1L
    oldid<-paste(market0,paste0(group0,num),sep="_")
    prev<-old[[oldid]];pb<-coef(prev);names(pb)[names(pb)=="fit_p_it"]<-"fit_price"
    pe<-max(abs(coef(m)[names(pb)]-pb))
    v0<-vcov(prev);nm<-rownames(v0);nm[nm=="fit_p_it"]<-"fit_price"
    ve<-max(abs(vcov(m)[nm,nm]-v0))
    stopifnot(pe<1e-8,ve<1e-8)
    validation[[id]]<-data.table(id,original_id=oldid,coefficient_error=pe,covariance_error=ve)
   }
   # Full fitted object not retained.
  }
 }
 cat("Completed",sample0,group0,"FE",fe,"; cumulative models",length(models),"\n")
}
cc<-rbindlist(coefs);fs<-rbindlist(firsts);sp<-rbindlist(specs);ck<-rbindlist(checks)
fwrite(cc,file.path(out,"coefficients.csv"));fwrite(fs,file.path(out,"first_stage_coefficients.csv"))
fwrite(sp,file.path(out,"specifications.csv"));fwrite(ck,file.path(out,"model_checks.csv"))
fwrite(rbindlist(validation),file.path(out,"original_48_validation.csv"))
# Full fitted objects not saved; instrument sets are in parent/instrument_sets.rds.
saveRDS(d,file.path(out,"estimation_sample.rds"))
stopifnot(identical(hashes,tools::md5sum(inputs)),length(validation)==0L)
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
summary<-merge(sp,ck,by="id")[,.(models=.N,admissible_sigma=sum(sigma_admissible),
 admissible_and_negative_alpha=sum(sigma_admissible & alpha_negative)),by=.(sample,market,price_measure)]
fwrite(summary,file.path(out,"summary_counts.csv"))
sig<-cc[term=="fit_ln_s_i_g"];sig[,cell:=sprintf("%.3f (%.3f)",estimate,std_error)]
wide<-dcast(sig,sample+controls+firm_FE+price_measure+instrument_set~market,value.var="cell")
fwrite(wide,file.path(out,"sigma_tables.csv"))

