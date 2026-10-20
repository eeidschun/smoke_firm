## Additional instruments, both price measures, common samples. No rebuild.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
out<-file.path(OUT_DIR,"demand_estimation","advisor_instruments_2026-10-20")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
inputs<-file.path(SUPPORT_DIR,c("demand_instrument_candidates.rds","upc_month_niccorr_from_full.RData",
 "upc_month_store_breadth.rds","product_characteristics_firm_month.rds","price_measures_firm_month.rds"))
hashes<-tools::md5sum(inputs)
d<-as.data.table(readRDS(inputs[1]));e<-new.env();load(inputs[2],envir=e)
u<-as.data.table(e$upc_month_t2);u[,brand:=trimws(brand)]
u<-u[brand!="UNKNOWN" & units_sum>0 & mL_sum>0,
 .(Q=sum(mL_sum),nic=sum(nic_mg_sum)),by=.(brand,month,upc12)]
b<-as.data.table(readRDS(inputs[3]));u<-merge(u,b[,.(month,upc12,n_stores)],by=c("month","upc12"))[n_stores>=3]
bm<-u[,.(Q=sum(Q),a_check=mean(nic/Q)),by=.(brand,month)]
bm[,year:=as.integer(format(month,"%Y"))]
annual<-bm[,.(Q=sum(Q)),by=.(year,brand)][,share:=Q/sum(Q),by=year]
roster<-annual[share>.07,.(brand,year)]
ac<-roster[,.(incumbent_annual=.N),by=year]
bm[,share_month:=Q/sum(Q),by=month]
mc<-bm[,.(incumbent_monthly=sum(share_month>.07)),by=month]
idx<-function(x)as.integer(format(x,"%Y"))*12L+as.integer(format(x,"%m"))
lag<-bm[,.(brand,month_index=idx(month)+1L,a_lag1=a_check)]
d[,month_index:=idx(month)]
d<-merge(d,lag,by=c("brand","month_index"),all.x=TRUE)
d<-merge(d,bm[,.(brand,month,a_check)],by=c("brand","month"),all.x=TRUE)
stopifnot(max(abs(d$a_it-d$a_check))<1e-8)
d<-merge(d,ac,by="year");d<-merge(d,mc,by="month")
stopifnot(all(d$incumbent_annual==d$n_incumbents))
active_roster<-d[,.(annual_roster_active_monthly=uniqueN(brand)),by=month]
stopifnot(all(merge(active_roster,unique(d[,.(month,incumbent_annual)]),by="month")[,annual_roster_active_monthly==incumbent_annual]))
sizes<-as.data.table(readRDS(inputs[4]))
d<-merge(d,sizes[,.(brand,month,avg_ml_per_ecig,log_upc_variety)],by=c("brand","month"),all.x=TRUE)
prices<-as.data.table(readRDS(inputs[5]))
d<-merge(d,prices[,.(brand,month,p_it_volume_weighted)],by=c("brand","month"),all.x=TRUE)
setorder(d,brand,month)
counts<-merge(unique(d[,.(year,month,incumbent_annual,incumbent_monthly)]),active_roster,by="month")
fwrite(counts,file.path(out,"incumbent_counts.csv"))
fwrite(d[!is.finite(a_lag1),.(brand,month)],file.path(out,"missing_lag.csv"))
sets<-list(National=c("TaxIV_geo","n_brands_3st"),Geographic=c("TaxIV_geo","n_brands_overlap"),
 Annual=c("TaxIV_geo","incumbent_annual"),Monthly=c("TaxIV_geo","incumbent_monthly"),
 Lag=c("TaxIV_geo","a_lag1"))
for(base in c("National","Geographic")) for(add in c("incumbent_annual","incumbent_monthly","a_lag1"))
 sets[[paste(base,add,sep="+")]]<-c(sets[[base]],add)
sets$Annual_Lag<-c("TaxIV_geo","incumbent_annual","a_lag1")
sets$Monthly_Lag<-c("TaxIV_geo","incumbent_monthly","a_lag1")
for(base in c("National","Geographic")) for(cnt in c("incumbent_annual","incumbent_monthly"))
 sets[[paste(base,cnt,"lag",sep="+")]]<-c(sets[[base]],cnt,"a_lag1")
sets$Annual_Monthly<-c("TaxIV_geo","incumbent_annual","incumbent_monthly")
sets$Annual_Monthly_Lag<-c(sets$Annual_Monthly,"a_lag1")
coefrows<-fsrows<-checkrows<-list();models<-list();samples<-list()
for(control in c(FALSE,TRUE)) for(fe in c(FALSE,TRUE)) for(sample0 in c("available","common_lag")) {
 dd<-copy(d)
 if(control)dd<-dd[is.finite(avg_ml_per_ecig)&is.finite(log_upc_variety)]
 if(sample0=="common_lag")dd<-dd[is.finite(a_lag1)]
 samples[[paste(control,fe,sample0,sep="_")]]<-dd[,.(brand,month)]
 for(price0 in c("p_it","p_it_volume_weighted")) for(set0 in names(sets)) {
 iv<-sets[[set0]]
 # Lag sets only on the common-lag sample; nonlag sets also fit full available sample.
 if(sample0=="available" && "a_lag1" %in% iv)next
 dd[,price:=get(price0)]
 exog<-c("a_it",if(control)c("avg_ml_per_ecig","log_upc_variety"))
 id<-paste(if(control)"SV" else "B",if(fe)"FE" else "noFE",sample0,price0,set0,sep="_")
 W<-cbind(if(fe)model.matrix(~0+factor(brand),dd)else matrix(1,nrow(dd),1),as.matrix(dd[,..exog]))
 Z<-cbind(W,as.matrix(dd[,..iv]));stopifnot(qr(Z)$rank==ncol(Z))
 f<-paste("y ~",paste(exog,collapse=" + "));if(fe)f<-paste(f,"| brand")
 f<-paste(f,"| price + ln_s_i_g ~",paste(iv,collapse=" + "))
 m<-feols(as.formula(f),data=as.data.frame(dd),vcov=~month,data.save=TRUE)
 n<-nrow(dd);G<-uniqueN(dd$month);ct<-coeftable(m)
 X<-cbind(W,as.matrix(dd[,.(price,ln_s_i_g)]));Xh<-qr.fitted(qr(Z),X)
 ref<-tail(qr.solve(Xh,dd$y),2)
 err<-max(abs(coef(m)[c("fit_price","fit_ln_s_i_g")]-ref));stopifnot(err<1e-7)
 coefrows[[id]]<-data.table(id,controls=control,firm_FE=fe,sample=sample0,price_measure=price0,instrument_set=set0,
  term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],
  ci_low=ct[,1]-qt(.975,G-1)*ct[,2],ci_high=ct[,1]+qt(.975,G-1)*ct[,2],n,months=G)
 # SW conditional auxiliary Wald; L-2+1 numerator df, CR1 month covariance.
 H<-qr.Q(qr(qr.resid(qr(W),as.matrix(dd[,..iv]))))
 correction<-G/(G-1)*(n-1)/(n-ncol(Z));L<-length(iv)
 for(j in 1:2) {
  o<-3-j;xx<-as.matrix(dd[,.(price,ln_s_i_g)]);xh<-qr.fitted(qr(Z),xx)
  bc<-qr.solve(cbind(W,xh[,o]),xx[,j])
  r<-xx[,j]-as.vector(cbind(W,xx[,o])%*%bc);v<-qr.resid(qr(Z),r)
  gamma<-crossprod(H,r);scores<-rowsum(H*as.vector(v),as.character(dd$month),reorder=FALSE)
  sw<-as.numeric(crossprod(gamma,solve(crossprod(scores),gamma)))/correction/(L-1)
  ff<-paste(colnames(xx)[j],"~",paste(c(exog,iv),collapse=" + "));if(fe)ff<-paste(ff,"| brand")
  first<-feols(as.formula(ff),data=as.data.frame(dd),vcov=~month)
  ft<-coeftable(first)
  fsrows[[paste(id,j)]]<-data.table(id,outcome=colnames(xx)[j],term=rownames(ft),
   estimate=ft[,1],std_error=ft[,2],p_value=ft[,4],SW_F=sw,SW_df1=L-1,SW_df2=G-1)
 }
 checkrows[[id]]<-data.table(id,n,months=G,n_excluded=L,overidentification_df=L-2,
  alpha=ref[1],sigma=ref[2],sigma_admissible=ref[2]>=0 & ref[2]<1,alpha_negative=ref[1]<0,QR_error=err)
 models[[id]]<-m
 }}
cc<-rbindlist(coefrows);fs<-rbindlist(fsrows);checks<-rbindlist(checkrows)
fwrite(cc,file.path(out,"coefficients.csv"));fwrite(fs,file.path(out,"first_stage_coefficients.csv"))
fwrite(checks,file.path(out,"model_checks.csv"));saveRDS(list(models=models,samples=samples,instrument_sets=sets),file.path(out,"models.rds"))
saveRDS(d,file.path(out,"candidate_panel.rds"))
stopifnot(identical(hashes,tools::md5sum(inputs)))
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
focus<-cc[controls==TRUE & firm_FE==TRUE & sample=="common_lag" & term %in% c("fit_price","fit_ln_s_i_g")]
table<-dcast(focus,instrument_set~price_measure+term,value.var="estimate")
lines<-c("# Advisor instrument comparisons: 2026-10-20","",
 "Both price measures; baseline nicotine-only and size-plus-variety controls; with/without firm FE. Geographic tax is retained in every instrument set. Annual baseline market size, unchanged demand roster/shares. Month-clustered standard errors; no month FE. No sigma clipping or model selection.","",
 "Annual count: brands with annual eligible liquid-volume share strictly above 7%. Monthly count: brands with monthly eligible liquid-volume share strictly above 7%, recomputed each month. Monthly threshold membership is used only for the instrument, not the demand roster. Counting active members of the existing annual roster monthly instead produces exactly the annual count; this duplicate is not added as a separate instrument. Counts include the focal brand if it qualifies.","",
 "Lag quality: previous calendar month's firm-level a_it, from all eligible UPCs including pre-incumbency months, not the previous observed incumbent row. No lag imputation. Current a_it remains an exogenous control. Missing-lag rows and all count series are exported. Existing nonlag baselines run on available samples AND common-lag samples, allowing sample effects to be separated from instrument effects. Both prices use identical observations in each comparison.","",
 "Instrument sets replace the original count with annual count, monthly count or lag; add each to national/geographic baselines; combine count and lag; and include annual and monthly together. Canonical inputs/old fits remain unchanged. All fits pass explicit-dummy QR 2SLS slope checks. First-stage CSV contains coefficients, clustered SEs and SW conditional F (reduced numerator df L-1, explicit-dummy CR1 correction). Conditional F is descriptive; it does not establish exclusion or calibrated weak-IV bias control.","",
 "Economic validity remains unresolved: contemporaneous counts depend on quantities and threshold crossing; lag quality can correlate with persistent unobserved demand shocks. Adding instruments is not evidence of validity. No exclusion claim follows from admissible sigma.","",
 "## Both controls plus firm FE, common-lag sample","",
 "| Instrument set | Alpha unweighted | Sigma unweighted | Alpha volume weighted | Sigma volume weighted |",
 "|---|---:|---:|---:|---:|")
for(i in seq_len(nrow(table))) {s<-table[i];lines<-c(lines,sprintf("| %s | %.4f | %.4f | %.4f | %.4f |",s$instrument_set,s$p_it_fit_price,s$p_it_fit_ln_s_i_g,s$p_it_volume_weighted_fit_price,s$p_it_volume_weighted_fit_ln_s_i_g))}
lines<-c(lines,"",paste("Total models:",length(models)),"",
 "Reproduce: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/10_advisor_instruments.R`.")
writeLines(lines,file.path(out,"README.md"));print(table);print(checks[,.(models=.N,admissible=sum(sigma_admissible),admissible_negative_alpha=sum(sigma_admissible & alpha_negative))])
