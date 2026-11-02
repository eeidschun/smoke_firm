## Jointly instrument price, within-nest share and current quality.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
parent<-"/Users/erineidschun/Desktop/synced_to_GD/PhD/pr/smoke_firm/smoke_firm_dir/output/demand_estimation/sales_weighted_tax_2026-10-27/sales"
out<-file.path(parent,"endogenous_quality_grid");dir.create(out,recursive=TRUE,showWarnings=FALSE)
inputs<-file.path(parent,c("candidate_panel.rds","instrument_sets.rds"));hashes<-tools::md5sum(inputs)
d<-as.data.table(readRDS(inputs[1]))
d<-d[is.finite(avg_ml_per_ecig)&is.finite(log_upc_variety)&is.finite(a_lag1)]
sets0<-readRDS(inputs[2])$instrument_sets
sets<-Filter(function(iv)"a_lag1" %in% iv & length(iv)>=3L,sets0)
stopifnot(nrow(d)==524L,length(sets)==9L)
markets<-c(annual="M_t",monthly="M_t_k_monthly",constant="M_t_k_const")
groups<-list(B=character(),S="avg_ml_per_ecig",V="log_upc_variety",SV=c("avg_ml_per_ecig","log_upc_variety"))
ccs<-sps<-cks<-fss<-models<-list()
for(group0 in names(groups))for(fe in c(FALSE,TRUE))for(price0 in c("p_it","p_it_volume_weighted")) {
 dd<-copy(d);dd[,price:=get(price0)];n<-nrow(dd);G<-uniqueN(dd$month)
 W<-cbind(if(fe)model.matrix(~0+factor(brand),dd)else matrix(1,n,1),
  if(length(groups[[group0]]))as.matrix(dd[,groups[[group0]],with=FALSE]))
 xx<-as.matrix(dd[,.(price,ln_s_i_g,a_it)]);X<-cbind(W,xx)
 for(set0 in names(sets)) {
  iv<-sets[[set0]];L<-length(iv);K<-3L
  design<-paste(group0,if(fe)"FE" else "noFE",price0,set0,sep="_")
  Z<-cbind(W,as.matrix(dd[,..iv]));qz<-qr(Z);stopifnot(qz$rank==ncol(Z))
  xh<-qr.fitted(qz,xx);Xh<-qr.fitted(qz,X);stopifnot(qr(Xh)$rank==ncol(Xh))
  H<-qr.Q(qr(qr.resid(qr(W),as.matrix(dd[,..iv]))))
  correction<-G/(G-1)*(n-1)/(n-ncol(Z))
  for(j in 1:K) {
   other<-setdiff(1:K,j);bc<-qr.solve(cbind(W,xh[,other,drop=FALSE]),xx[,j])
   r<-xx[,j]-as.vector(cbind(W,xx[,other,drop=FALSE])%*%bc);u<-qr.resid(qz,r)
   gamma<-crossprod(H,r);scores<-rowsum(H*as.vector(u),as.character(dd$month),reorder=FALSE)
   sw<-as.numeric(crossprod(gamma,solve(crossprod(scores),gamma)))/correction/(L-K+1)
   aux<-lm(r~Z-1);ind<-(ncol(W)+1):ncol(Z)
   bb<-coef(aux)[ind];vv<-sandwich::vcovCL(aux,cluster=dd$month,type="HC1",cadjust=TRUE)[ind,ind]
   swref<-as.numeric(crossprod(bb,solve(vv,bb)))/(L-K+1)
   cf<-paste(colnames(xx)[j],"~",if(length(groups[[group0]]))paste(groups[[group0]],collapse=" + ")else"1")
   if(fe)cf<-paste(cf,"| brand")
   cm<-feols(as.formula(paste(cf,"|",paste(colnames(xx)[other],collapse=" + "),"~",paste(iv,collapse=" + "))),data=as.data.frame(dd))
   stopifnot(abs(sw-swref)<1e-6,max(abs(resid(cm)-r))<1e-7)
   ff<-paste(colnames(xx)[j],"~",paste(c(groups[[group0]],iv),collapse=" + "));if(fe)ff<-paste(ff,"| brand")
   first<-feols(as.formula(ff),data=as.data.frame(dd),vcov=~month);ct<-coeftable(first)
   fss[[paste(design,j)]]<-data.table(design_id=design,outcome=colnames(xx)[j],term=rownames(ct),
    estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],SW_F=sw,SW_df1=L-K+1,SW_df2=G-1,
    validation_error=abs(sw-swref))
  }
  for(market0 in names(markets)) {
   M<-dd[[markets[[market0]]]];Q<-dd$s_g*dd$M_t;stopifnot(all(M>Q))
   dd[,y_new:=log(mL/M)-log1p(-Q/M)]
   f<-paste("y_new ~",if(length(groups[[group0]]))paste(groups[[group0]],collapse=" + ")else"1")
   if(fe)f<-paste(f,"| brand")
   f<-as.formula(paste(f,"| price + ln_s_i_g + a_it ~",paste(iv,collapse=" + ")))
   m<-feols(f,data=as.data.frame(dd),vcov=~month)
   ref<-qr.solve(Xh,dd$y_new);terms<-c(groups[[group0]],"fit_price","fit_ln_s_i_g","fit_a_it")
   error<-max(abs(coef(m)[terms]-tail(ref,length(terms))))
   re<-max(abs(resid(m)-(dd$y_new-as.vector(X%*%ref))))
   stopifnot(error<1e-7,re<1e-7,nobs(m)==n)
   id<-paste(market0,design,sep="_");ct<-coeftable(m)
   ccs[[id]]<-data.table(id,design_id=design,controls=group0,firm_FE=fe,price_measure=price0,
    instrument_set=set0,market=market0,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],
    ci_low=ct[,1]-qt(.975,G-1)*ct[,2],ci_high=ct[,1]+qt(.975,G-1)*ct[,2],n,months=G)
   sps[[id]]<-data.table(id,design_id=design,controls=group0,firm_FE=fe,price_measure=price0,instrument_set=set0,
    market=market0,quality="Endogenous",endogenous="price + ln_s_i_g + a_it",
    excluded_instruments=paste(iv,collapse=" + "),n_excluded=L,n_endogenous=K,overidentification_df=L-K,n,months=G)
   cks[[id]]<-data.table(id,coefficient_error=error,residual_error=re)
   # Full fitted object not retained.
  }
 }
 cat("Completed",group0,"FE",fe,price0,"; models",length(models),"\n")
}
cc<-rbindlist(ccs);sp<-rbindlist(sps)
fwrite(cc,file.path(out,"coefficients.csv"));fwrite(sp,file.path(out,"specifications.csv"))
fwrite(rbindlist(cks),file.path(out,"model_checks.csv"));fwrite(rbindlist(fss),file.path(out,"first_stage_coefficients.csv"))
# Full fitted objects not saved; instrument sets are in parent/instrument_sets.rds.
stopifnot(identical(hashes,tools::md5sum(inputs)),nrow(sp)==432L)
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
labels<-c(TaxIV_geo="Geographic tax",n_brands_3st="National active-brand count",n_brands_overlap="Geographic active-brand count",
 incumbent_annual="Annual incumbent count",incumbent_monthly="Monthly >7% count",a_lag1="Lagged quality")

