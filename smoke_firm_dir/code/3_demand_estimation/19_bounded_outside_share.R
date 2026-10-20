## Diagnostic bounded outside-share paths; no Markdown or canonical updates.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
root<-file.path(OUT_DIR,"demand_estimation","specification_comparison","market_size")
paths<-file.path(root,c("estimation_sample.rds","models.rds","coefficients.csv"))
hashes<-tools::md5sum(paths);d<-as.data.table(readRDS(paths[1]))
saved<-readRDS(paths[2]);specs<-as.data.table(saved$specifications);old<-fread(paths[3])
markets<-c(annual="M_t",monthly="M_t_k_monthly",constant="M_t_k_const")
args<-commandArgs(trailingOnly=TRUE)
if(length(args)) {
 bounds<-as.numeric(args)
 stopifnot(length(bounds)%%2==0,all(is.finite(bounds)))
 bounds<-matrix(bounds,ncol=2,byrow=TRUE)
 bands<-data.table(lower=bounds[,1],upper=bounds[,2])
 bands[,band:=paste0(format(100*lower,trim=TRUE,scientific=FALSE),"_",format(100*upper,trim=TRUE,scientific=FALSE))]
} else bands<-data.table(band=c("80_90","60_70"),lower=c(.8,.6),upper=c(.9,.7))
stopifnot(all(bands$lower>0),all(bands$upper<1),all(bands$upper>bands$lower+.002),!anyDuplicated(bands$band))
margin<-.001 # 0.1 percentage point inside each endpoint
out<-file.path(OUT_DIR,"demand_estimation","bounded_outside_share")
if(length(args))out<-file.path(out,paste(bands$band,collapse="__"))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
month<-unique(d[,.(month,Q=s_g*M_t,M_t,M_t_k_monthly,M_t_k_const)])
stopifnot(nrow(month)==132L,nrow(d)==528L,nrow(specs)==48L)
series<-list()
for(i in 1:nrow(bands))for(market0 in names(markets)) {
 b<-bands[i];M<-month[[markets[[market0]]]];s0<-1-month$Q/M
 # Affine map preserves ordering and relative spacing of original outside shares.
 z<-(s0-min(s0))/diff(range(s0))
 new<-b$lower+margin+(b$upper-b$lower-2*margin)*z
 stopifnot(all(new>b$lower & new<b$upper),cor(s0,new)>1-1e-12)
 series[[paste(b$band,market0)]]<-data.table(band=b$band,market=market0,month=month$month,
  lower=b$lower,upper=b$upper,Q=month$Q,original_M=M,original_outside=s0,
  new_outside=new,new_M=month$Q/(1-new))
}
ts<-rbindlist(series);ccs<-cks<-models<-list()
for(band0 in bands$band)for(i in 1:nrow(specs)) {
 s<-specs[i];t<-ts[band==band0 & market==s$market]
 dd<-merge(copy(d),t[,.(month,new_outside,new_M)],by="month",all.x=TRUE)
 setorder(dd,brand,month)
 dd[,y_new:=ln_s_i_g+log((1-new_outside)/new_outside)]
 Q<-dd$s_g*dd$M_t
 stopifnot(max(abs(dd$y_new-log(dd$mL/(dd$new_M-Q))))<1e-10)
 exog<-c("a_it",if(s$size_control)"avg_ml_per_ecig",if(s$variety_control)"log_upc_variety")
 iv<-c("TaxIV_geo",s$count)
 f<-paste("y_new ~",paste(exog,collapse=" + "));if(s$firm_FE)f<-paste(f,"| brand")
 m<-feols(as.formula(paste(f,"| p_it + ln_s_i_g ~",paste(iv,collapse=" + "))),data=as.data.frame(dd),vcov=~month)
 W<-cbind(if(s$firm_FE)model.matrix(~0+factor(brand),dd)else matrix(1,nrow(dd),1),as.matrix(dd[,..exog]))
 X<-cbind(W,as.matrix(dd[,.(p_it,ln_s_i_g)]));Z<-cbind(W,as.matrix(dd[,..iv]))
 ref<-qr.solve(qr.fitted(qr(Z),X),dd$y_new);terms<-c(exog,"fit_p_it","fit_ln_s_i_g")
 error<-max(abs(coef(m)[terms]-tail(ref,length(terms))))
 re<-max(abs(resid(m)-(dd$y_new-as.vector(X%*%ref))))
 stopifnot(error<1e-7,re<1e-7,nobs(m)==528L)
 ct<-coeftable(m);id<-paste(band0,s$id,sep="_")
 ccs[[id]]<-data.table(id,band=band0,original_id=s$id,base_id=s$base_id,market=s$market,
  group=s$group,firm_FE=s$firm_FE,count=s$count,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],
  p_value=ct[,4],ci_low=ct[,1]-qt(.975,131)*ct[,2],ci_high=ct[,1]+qt(.975,131)*ct[,2],n=nobs(m),months=132L)
 baseline<-old[id==s$id & parameter=="sigma",estimate]
 cks[[id]]<-data.table(id,band=band0,original_id=s$id,base_id=s$base_id,market=s$market,
  group=s$group,firm_FE=s$firm_FE,count=s$count,original_sigma=baseline,
  sigma=coef(m)["fit_ln_s_i_g"],sigma_se=ct["fit_ln_s_i_g",2],
  change_sigma=coef(m)["fit_ln_s_i_g"]-baseline,alpha=coef(m)["fit_p_it"],
  coefficient_error=error,residual_error=re)
 models[[id]]<-m
}
cc<-rbindlist(ccs);ck<-rbindlist(cks)
cal<-ts[,.(min_outside=min(new_outside),mean_outside=mean(new_outside),max_outside=max(new_outside)),by=.(band,market)]
fwrite(cc,file.path(out,"coefficients.csv"));fwrite(ck,file.path(out,"comparison.csv"))
fwrite(ts,file.path(out,"monthly_series.csv"));fwrite(cal,file.path(out,"outside_share_checks.csv"))
saveRDS(list(models=models,specifications=specs,bands=bands,margin=margin),file.path(out,"models.rds"))
stopifnot(identical(hashes,tools::md5sum(paths)),nrow(ck)==48L*nrow(bands))
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Bounded outside-share sensitivity: 48 original designs per band, 96 fits.",
 "Original outside share s0_t=1-Q_t/M_t is affine-mapped by its min/max into [lower+0.001,upper-0.001].",
 "Paths span lower+0.1 percentage point to upper-0.1 percentage point, strictly inside each requested band. See outside_share_checks.csv for bounds. Original month ranking and relative spacing are preserved. Means are not forced to band midpoints.",
 "New M_t=Q_t/(1-new_s0_t). Unlike constant scaling of M, this alters its temporal shape; even the annual-baseline variant now has monthly M variation.",
 "This is a chosen diagnostic transformation, not an economically justified denominator. Sigma is freely estimated. Compressing outside-share variation also moves y toward within-nest log share plus a constant; sigma closer to one is not by itself evidence of correction.",
 "All fits use original UPC-unweighted price, current quality exogenous, geographic tax and original national/geographic active-brand count instruments, four control groups, with/without firm FE, 528 rows, 132 month clusters. No month FE.",
 "Shares, price, controls and instruments otherwise unchanged. Outside bounds, QR slope/residual checks and unchanged input hashes verified. No Markdown changes."),file.path(out,"interpretation.txt"))
print(cal)
print(ck[,.(runs=.N,lower_than_original=sum(change_sigma<0),min_sigma=min(sigma),max_sigma=max(sigma)),by=.(band,market)])
print(ck[base_id %in% c("SV3","SV4"),.(base_id,market,band,original_sigma,sigma,sigma_se)])
