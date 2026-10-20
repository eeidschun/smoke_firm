## Rescale each existing market size to a target mean monthly outside share.
## Diagnostic only; no Markdown or canonical input changes.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
root<-file.path(OUT_DIR,"demand_estimation","specification_comparison","market_size")
paths<-file.path(root,c("estimation_sample.rds","models.rds","coefficients.csv"))
hashes<-tools::md5sum(paths)
d<-as.data.table(readRDS(paths[1]));saved<-readRDS(paths[2]);specs<-as.data.table(saved$specifications)
old<-fread(paths[3]);markets<-c(annual="M_t",monthly="M_t_k_monthly",constant="M_t_k_const")
args<-commandArgs(trailingOnly=TRUE);targets<-if(length(args))as.numeric(args)else c(.9,.8)
stopifnot(all(is.finite(targets)),all(targets>0 & targets<1),!anyDuplicated(targets),nrow(d)==528L,nrow(specs)==48L)
out<-file.path(OUT_DIR,"demand_estimation","average_outside_share")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
# One observation per calendar month: do not weight months by incumbent count.
month<-unique(d[,.(month,Q=s_g*M_t,M_t,M_t_k_monthly,M_t_k_const)])
stopifnot(nrow(month)==132L,!anyDuplicated(month$month))
calibration<-series<-list()
for(target in targets)for(market0 in names(markets)) {
 M<-month[[markets[[market0]]]];inside<-month$Q/M
 # mean(1-Q/(c*M)) = target => c = mean(Q/M)/(1-target).
 scale<-mean(inside)/(1-target);outside<-1-inside/scale
 stopifnot(abs(mean(outside)-target)<1e-12,all(outside>0 & outside<1))
 key<-paste(target,market0,sep="_")
 calibration[[key]]<-data.table(target,market=market0,scale_factor=scale,
  mean_original_outside=mean(1-inside),mean_new_outside=mean(outside),
  min_new_outside=min(outside),max_new_outside=max(outside),months=length(outside))
 series[[key]]<-data.table(target,market=market0,month=month$month,Q=month$Q,
  original_M=M,rescaled_M=scale*M,original_outside=1-inside,rescaled_outside=outside)
}
cal<-rbindlist(calibration);ts<-rbindlist(series)
coefs<-checks<-models<-list()
for(target0 in targets)for(i in seq_len(nrow(specs))) {
 s<-specs[i];dd<-copy(d)
 scale<-cal[target==target0 & market==s$market,scale_factor]
 M<-dd[[markets[[s$market]]]]*scale;Q<-dd$s_g*dd$M_t
 dd[,y_new:=log(mL/M)-log1p(-Q/M)]
 stopifnot(max(abs(dd$y_new-(dd$ln_s_i_g+log(Q/(M-Q)))))<1e-10)
 exog<-c("a_it",if(s$size_control)"avg_ml_per_ecig",if(s$variety_control)"log_upc_variety")
 iv<-c("TaxIV_geo",s$count)
 f<-paste("y_new ~",paste(exog,collapse=" + "));if(s$firm_FE)f<-paste(f,"| brand")
 f<-as.formula(paste(f,"| p_it + ln_s_i_g ~",paste(iv,collapse=" + ")))
 m<-feols(f,data=as.data.frame(dd),vcov=~month)
 W<-cbind(if(s$firm_FE)model.matrix(~0+factor(brand),dd)else matrix(1,nrow(dd),1),as.matrix(dd[,..exog]))
 X<-cbind(W,as.matrix(dd[,.(p_it,ln_s_i_g)]));Z<-cbind(W,as.matrix(dd[,..iv]))
 ref<-qr.solve(qr.fitted(qr(Z),X),dd$y_new)
 terms<-c(exog,"fit_p_it","fit_ln_s_i_g")
 error<-max(abs(coef(m)[terms]-tail(ref,length(terms))))
 re<-max(abs(resid(m)-(dd$y_new-as.vector(X%*%ref))))
 stopifnot(error<1e-7,re<1e-7,nobs(m)==528L)
 ct<-coeftable(m);id<-paste(target0,s$id,sep="_")
 coefs[[id]]<-data.table(id,original_id=s$id,base_id=s$base_id,market=s$market,target=target0,
  group=s$group,firm_FE=s$firm_FE,count=s$count,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],
  p_value=ct[,4],ci_low=ct[,1]-qt(.975,131)*ct[,2],ci_high=ct[,1]+qt(.975,131)*ct[,2],n=nobs(m),months=132L)
 old_sigma<-old[id==s$id & parameter=="sigma",estimate]
 old_alpha<-old[id==s$id & parameter=="alpha",estimate]
 checks[[id]]<-data.table(id,original_id=s$id,base_id=s$base_id,market=s$market,target=target0,
  group=s$group,firm_FE=s$firm_FE,count=s$count,scale_factor=scale,
  original_sigma=old_sigma,sigma=coef(m)["fit_ln_s_i_g"],sigma_se=ct["fit_ln_s_i_g",2],
  change_sigma=coef(m)["fit_ln_s_i_g"]-old_sigma,
  original_alpha=old_alpha,alpha=coef(m)["fit_p_it"],coefficient_error=error,residual_error=re)
 models[[id]]<-m
}
cc<-rbindlist(coefs);ck<-rbindlist(checks)
tag<-paste(format(targets,trim=TRUE),collapse="_")
fwrite(cc,file.path(out,paste0("coefficients_",tag,".csv")))
fwrite(ck,file.path(out,paste0("comparison_",tag,".csv")))
fwrite(cal,file.path(out,paste0("calibration_",tag,".csv")))
fwrite(ts,file.path(out,paste0("monthly_series_",tag,".csv")))
saveRDS(list(models=models,specifications=specs,targets=targets),file.path(out,paste0("models_",tag,".rds")))
stopifnot(identical(hashes,tools::md5sum(paths)),nrow(ck)==48L*length(targets))
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,paste0("input_hashes_",tag,".csv")))
writeLines(c("Mean outside-share sensitivity; no Markdown modified.",
 "Each original market-size series is multiplied by c=mean_month(Q/M)/(1-target), with equal weight on each of the 132 calendar months.",
 "Original monthly market-size shape and all liquid quantities are retained; outside shares vary monthly. Annual M remains constant within each year, as before.",
 "The original 48 designs use UPC-unweighted price, current quality exogenous, original tax and national/geographic brand-count instruments, four control groups, with/without firm FE. All use the same 528 rows. No month FE; SE clustered by month.",
 "Only M, outside shares and the dependent variable change. Within-nest share, instruments, controls, sample and prices are fixed, so first stages are unchanged.",
 "All target means, positivity, independent QR coefficients/residuals and unchanged source hashes passed checks. These are diagnostic scalings, not economically approved market definitions.",
 "Reproduce or toggle: Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/18_average_outside_share.R 0.90 0.80"),
 file.path(out,paste0("interpretation_",tag,".txt")))
print(cal)
print(ck[,.(runs=.N,lower_sigma=sum(change_sigma< -1e-8),min_change=min(change_sigma),max_change=max(change_sigma),
 min_sigma=min(sigma),max_sigma=max(sigma)),by=.(target,market)])
print(ck[base_id %in% c("SV3","SV4"),.(base_id,market,target,original_sigma,sigma,sigma_se,change_sigma)])
