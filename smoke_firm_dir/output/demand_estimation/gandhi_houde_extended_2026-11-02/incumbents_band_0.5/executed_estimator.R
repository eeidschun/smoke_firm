## Exploratory GH-style brand-level differentiation IVs; no meeting-note changes.
source('smoke_firm_dir/code/fxns/1_paths.R')
suppressPackageStartupMessages({library(data.table);library(fixest)})
setDTthreads(2);setFixest_nthreads(1)
out<-"/Users/erineidschun/Desktop/synced_to_GD/PhD/pr/smoke_firm/smoke_firm_dir/output/demand_estimation/gandhi_houde_extended_2026-11-02/incumbents_band_0.5"
dir.create(out,recursive=TRUE,showWarnings=FALSE)
input<-file.path(OUT_DIR,'demand_estimation','sales_weighted_tax_2026-10-27','sales','candidate_panel.rds')
hash<-tools::md5sum(input);full<-as.data.table(readRDS(input))
# Full incumbent roster first, before exclusions from the estimating sample.
stopifnot(nrow(full)==540L,!anyDuplicated(full[,.(brand,month)]))
characteristics<-list(nicotine='a_it',size='avg_ml_per_ecig',variety='log_upc_variety',nicotine_size=c('a_it','avg_ml_per_ecig'),nicotine_variety=c('a_it','log_upc_variety'),size_variety=c('avg_ml_per_ecig','log_upc_variety'),nicotine_size_variety=c('a_it','avg_ml_per_ecig','log_upc_variety'))
cc<-specs<-firsts<-valid<-counts<-instruments<-thresholds<-issues<-list()
markets<-c(annual='M_t',monthly='M_t_k_monthly',constant='M_t_k_const')
for(family in names(characteristics)){
 chars<-characteristics[[family]]
 complete<-full[,.(complete=all(is.finite(as.matrix(.SD)))),by=month,.SDcols=chars]
 roster<-copy(full[month%in%complete[complete==TRUE,month]])
 # Directed within-market pair differences, excluding the focal brand itself.
 pairs<-merge(roster[,c('month','brand',chars),with=FALSE],
 roster[,c('month','brand',chars),with=FALSE],by='month',suffixes=c('_i','_j'),allow.cartesian=TRUE)[brand_i!=brand_j]
 local<-quadratic<-character()
 for(ch in chars){
  delta<-pairs[[paste0(ch,'_j')]]-pairs[[paste0(ch,'_i')]]
  threshold<-sd(delta);stopifnot(is.finite(threshold),threshold>0)
  localname<-paste0('GH_local_',ch);quadname<-paste0('GH_quad_',ch)
  pairs[,temporary_local:=as.integer(abs(delta)<0.5*threshold)]
  pairs[,temporary_quad:=(delta/threshold)^2]
  ag<-pairs[,.(local=sum(temporary_local),quadratic=sum(temporary_quad)),by=.(brand=brand_i,month)]
  setnames(ag,c('local','quadratic'),c(localname,quadname));roster<-merge(roster,ag,by=c('brand','month'))
  # Independent explicit-loop construction check (including self exclusion).
  err<-0
  for(mo in unique(roster$month)){
   r<-roster[month==mo]
   for(i in seq_len(nrow(r))){dif<-r[[ch]]-r[[ch]][i];dif<-dif[-i]
    err<-max(err,abs(sum(abs(dif)<0.5*threshold)-r[[localname]][i]),abs(sum((dif/threshold)^2)-r[[quadname]][i]))
   }
  }
  stopifnot(err<1e-9)
  thresholds[[paste(family,ch)]]<-data.table(family,characteristic=ch,pair_difference_sd=threshold,pairs=nrow(pairs),construction_error=err)
  local<-c(local,localname);quadratic<-c(quadratic,quadname)
 }
 li<-qi<-character()
 for(aa in seq_along(chars))for(bb in seq_along(chars)){
  ca<-chars[aa];cb<-chars[bb]
  da<-pairs[[paste0(ca,'_j')]]-pairs[[paste0(ca,'_i')]]
  db<-pairs[[paste0(cb,'_j')]]-pairs[[paste0(cb,'_i')]]
  sa<-sd(da);sb<-sd(db)
  nl<-paste0('GH_li_',aa,'_',bb)
  pairs[,temporary:=(abs(da)<0.5*sa)*(db/sb)]
  ag<-pairs[,.(value=sum(temporary)),by=.(brand=brand_i,month)];setnames(ag,'value',nl)
  roster<-merge(roster,ag,by=c('brand','month'));li<-c(li,nl)
  if(bb>aa){nq<-paste0('GH_qi_',aa,'_',bb)
   pairs[,temporary:=(da/sa)*(db/sb)]
   ag<-pairs[,.(value=sum(temporary)),by=.(brand=brand_i,month)];setnames(ag,'value',nq)
   roster<-merge(roster,ag,by=c('brand','month'));qi<-c(qi,nq)
  }
 }
 instruments[[family]]<-roster[,c('brand','month',local,quadratic,li,qi),with=FALSE][,family:=family]

 # Retain original complete-size estimation convention even for nicotine-only B.
 d<-roster[is.finite(avg_ml_per_ecig)&is.finite(log_upc_variety)]
 counts[[family]]<-data.table(family,roster_rows=nrow(roster),estimation_rows=nrow(d),months=uniqueN(d$month),excluded_months=uniqueN(full$month)-uniqueN(roster$month))
 groups<-list(B=character(),S='avg_ml_per_ecig',V='log_upc_variety',SV=c('avg_ml_per_ecig','log_upc_variety'))
 groups<-Filter(function(g)all(setdiff(chars,'a_it')%in%g),groups)
 sets<-list(Baseline=c('TaxIV_sales','incumbent_annual'),Tax_Local=c('TaxIV_sales',local),
 Tax_Quadratic=c('TaxIV_sales',quadratic),Tax_Both=c('TaxIV_sales',local,quadratic),
 Local_only=local,Quadratic_only=quadratic,Both_only=c(local,quadratic),
 Baseline_Local=c('TaxIV_sales','incumbent_annual',local),Baseline_Quadratic=c('TaxIV_sales','incumbent_annual',quadratic),
 Baseline_Both=c('TaxIV_sales','incumbent_annual',local,quadratic))
 sets$Tax_Local_Interactions<-c('TaxIV_sales',local,li)
 sets$Tax_Quadratic_Interactions<-c('TaxIV_sales',quadratic,qi)
 sets$Baseline_Local_Interactions<-c('TaxIV_sales','incumbent_annual',local,li)
 sets$Baseline_Quadratic_Interactions<-c('TaxIV_sales','incumbent_annual',quadratic,qi)
 sets$Tax_Monthly_Local<-c('TaxIV_sales','incumbent_monthly',local)
 sets$Tax_Monthly_Quadratic<-c('TaxIV_sales','incumbent_monthly',quadratic)
 for(group in names(groups))for(set in names(sets)){
 
  if(set%in%c('Tax_Quadratic_Interactions','Baseline_Quadratic_Interactions') && !length(qi))next
  exog<-c('a_it',groups[[group]]);iv<-sets[[set]];L<-length(iv)
  design<-paste(family,group,set,sep='_');n<-nrow(d);G<-uniqueN(d$month)
  W<-cbind(1,as.matrix(d[,..exog]));Z<-cbind(W,as.matrix(d[,..iv]));X<-cbind(W,price=d$p_it_volume_weighted,ln_s_i_g=d$ln_s_i_g)
  if(L<2 || qr(Z)$rank<ncol(Z) || qr(qr.fitted(qr(Z),X))$rank<ncol(X)){
   issues[[design]]<-data.table(design,reason=if(L<2)'fewer than two excluded instruments'else'rank deficient design',n_excluded=L)
   next
  }
  qz<-qr(Z);Xh<-qr.fitted(qz,X);xx<-tail(seq_len(ncol(X)),2)
  H<-qr.Q(qr(qr.resid(qr(W),as.matrix(d[,..iv]))));correction<-G/(G-1)*(n-1)/(n-ncol(Z))
  for(j in 1:2){
   yj<-X[,xx[j]];other<-Xh[,xx[3-j]]
   bc<-qr.solve(cbind(W,other),yj);r<-yj-as.vector(cbind(W,X[,xx[3-j]])%*%bc)
   u<-qr.resid(qz,r);gamma<-crossprod(H,r)
   scores<-rowsum(H*as.vector(u),as.character(d$month),reorder=FALSE)
   sw<-tryCatch(as.numeric(crossprod(gamma,solve(crossprod(scores),gamma)))/correction/(L-1),error=function(e)NA_real_)
   aux<-lm(r~Z-1);ind<-(ncol(W)+1):ncol(Z)
   bb<-coef(aux)[ind];vv<-sandwich::vcovCL(aux,cluster=d$month,type='HC1',cadjust=TRUE)[ind,ind]
   swref<-tryCatch(as.numeric(crossprod(bb,solve(vv,bb)))/(L-1),error=function(e)NA_real_);if(is.finite(sw)&&is.finite(swref))stopifnot(abs(sw-swref)<1e-5)
   d[,price:=p_it_volume_weighted];outcome<-c('price','ln_s_i_g')[j]
   fm<-feols(as.formula(paste(outcome,'~',paste(c(exog,iv),collapse=' + '))),d,vcov=~month,notes=FALSE)
   ct<-coeftable(fm)
   firsts[[paste(design,j)]]<-data.table(design,outcome,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],SW_F=sw,SW_df1=L-1,SW_df2=G-1,validation_error=abs(sw-swref))
  }
  for(market in names(markets)){
   d[,y_gh:=log(mL/get(markets[[market]]))-log1p(-(s_g*M_t)/get(markets[[market]]))]
   stopifnot(all(is.finite(d$y_gh)))
   f<-as.formula(paste('y_gh ~',paste(exog,collapse=' + '),'| price + ln_s_i_g ~',paste(iv,collapse=' + ')))
   fit<-feols(f,d,vcov=~month,notes=FALSE);ref<-qr.solve(Xh,d$y_gh)
   terms<-c('(Intercept)',exog,'fit_price','fit_ln_s_i_g')
   err<-max(abs(coef(fit)[terms]-ref));re<-max(abs(resid(fit)-(d$y_gh-as.vector(X%*%ref))))
   if(!is.finite(err)||err>=1e-7||re>=1e-7){issues[[paste(market,design)]]<-data.table(design,market,reason='numerically unstable: independent QR comparison fails',n_excluded=L,coefficient_error=err,residual_error=re,alpha=coef(fit)['fit_price'],sigma=coef(fit)['fit_ln_s_i_g'],projected_condition_number=kappa(Xh));next}
   stopifnot(nobs(fit)==n)
   id<-paste(market,design,sep='_');ct<-coeftable(fit)
   cc[[id]]<-data.table(id,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],ci_low=ct[,1]-qt(.975,G-1)*ct[,2],ci_high=ct[,1]+qt(.975,G-1)*ct[,2])
   specs[[id]]<-data.table(id,design,family,controls=group,instrument_set=set,market,n,months=G,n_excluded=L,overid_df=L-2,
    excluded_instruments=paste(iv,collapse=' + '),alpha=coef(fit)['fit_price'],sigma=coef(fit)['fit_ln_s_i_g'],quality=coef(fit)['a_it'])
   valid[[id]]<-data.table(id,coefficient_error=err,residual_error=re)
  }
 }
}
s<-rbindlist(specs);s[,`:=`(qualifying=sigma>0 & sigma<1,joint=sigma>0 & sigma<1 & alpha<0)]
fwrite(s,file.path(out,'specifications.csv'));fwrite(rbindlist(cc),file.path(out,'coefficients.csv'))
fwrite(rbindlist(firsts),file.path(out,'first_stages.csv'));fwrite(rbindlist(valid),file.path(out,'validation.csv'))
fwrite(rbindlist(issues,fill=TRUE),file.path(out,'skipped_designs.csv'));fwrite(rbindlist(counts),file.path(out,'sample_coverage.csv'))
fwrite(rbindlist(thresholds),file.path(out,'thresholds_and_construction_checks.csv'))
fwrite(rbindlist(instruments,fill=TRUE),file.path(out,'differentiation_instruments.csv'))
fwrite(s[,.(fits=.N,qualifying=sum(qualifying),also_negative_alpha=sum(joint),mean_qualifying=if(any(qualifying))mean(sigma[qualifying])else NA_real_,median_qualifying=if(any(qualifying))median(sigma[qualifying])else NA_real_),by=.(family,instrument_set)],file.path(out,'family_summary.csv'))
# Matched changes versus baseline, within characteristic-family/control/market.
base<-s[instrument_set=='Baseline',.(family,controls,market,baseline_alpha=alpha,baseline_sigma=sigma)]
fwrite(merge(s,base,by=c('family','controls','market'))[,`:=`(alpha_change=alpha-baseline_alpha,sigma_change=sigma-baseline_sigma)],file.path(out,'matched_comparison.csv'))
stopifnot(identical(hash,tools::md5sum(input)))
fwrite(data.table(path=input,md5=unname(hash)),file.path(out,'input_hashes.csv'))
writeLines(c('Exploratory GH-style differentiation IVs, November 2, 2026. No meeting notes modified.',
'Sources: https://www.nber.org/papers/w26375 ; https://pyblp.readthedocs.io/en/stable/_api/pyblp.build_differentiation_instruments.html',
'Hand-constructed local counts and squared-distance sums; no PyBLP estimator used. Market = month, alternative = national incumbent brand.',
'Rivals are all other incumbent brands in the original annual roster, before estimation exclusions. Aggregate fringe not included in characteristic distances; fringe volume remains in demand shares. Brand treated as single-product independent pricing firm; actual parent ownership not encoded.',
'Local instrument counts rival brands with absolute characteristic difference strictly below pooled SD of ordered within-market pair differences, excluding self. SD computed once per characteristic/coverage family across all eligible months.',
'Quadratic instrument sums squared differences divided by that same SD squared; scaling changes units only. No interactions or predicted-price instruments.',
'Own-firm differentiation sums are zero under one-product-per-brand and are not included.',
'Characteristics: nicotine; nicotine+size; nicotine+size+log variety. All treated as exogenous; no current/lag quality endogenous models. Own corresponding characteristics included as controls.',
'If any incumbent lacks a characteristic, exclude the entire month for that characteristic family. In particular size families drop all 2018, not just BLU. No incomplete rival sets or imputation.',
'Volume-weighted prices, sales-weighted taxes where present, no firm or month FE, month-clustered SEs. Original annual/monthly/constant market sizes, roster, and quantity totals retained. Original 528-row complete-size rule retained before further complete-market exclusions.',
'Baseline tax+annual incumbent count refit on every matched sample. Differentiation instruments tested alone, replacing count while retaining tax, and supplementing baseline. Underidentified/rank-deficient sets explicitly skipped.',
'Instrument validity requires exogeneity of product positioning and relevant rival characteristics conditional on controls. GH does not fix endogenous nicotine/assortment or sales-weighted tax automatically. Admissible sigma is not model validation.',
'Every retained fit passes explicit QR coefficient/residual checks; unstable estimates are logged in skipped_designs.csv; conditional SW F checked by full-design clustered sandwich. No overidentification tests or weak-IV-robust inference. No full fitted objects saved or supply specification replaced.'),file.path(out,'interpretation.txt'))
print(s[,.(fits=.N,qualifying=sum(qualifying),also_negative_alpha=sum(joint)),by=.(family,instrument_set)])


