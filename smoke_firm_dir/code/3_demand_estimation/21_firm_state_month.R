## Geographic aggregation sensitivity. Run from repository root; canonical inputs preserved.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source('smoke_firm_dir/code/fxns/1_paths.R')
setDTthreads(2);setFixest_nthreads(2)
out<-file.path(OUT_DIR,'demand_estimation','firm_state_month_2026-10-26')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
paths<-c(file.path(PRELIM_DIR,'state_price_tax_diagnostic','state_upc_month.rds'),
 file.path(SUPPORT_DIR,c('upc_month_niccorr_from_full.RData','product_size_upc_month.rds','demand_panel_firm_month.RData')),
 file.path(FIRM_DIR,'raw','ecig_taxes','ec_tax_cotti_per_mL.RData'))
hashes<-tools::md5sum(paths)
x<-as.data.table(readRDS(paths[1]));x[,brand:=trimws(brand)]
e<-new.env();load(paths[2],e)
u<-as.data.table(e$upc_month_t2)[,.(nic=sum(nic_mg_sum)/sum(mL_sum),ml=sum(mL_sum),units=sum(units_sum),rev=sum(revenue_real)),by=.(year_month,upc12)]
check<-merge(x[,.(ml=sum(state_ml),units=sum(state_units),rev=sum(state_revenue)),by=.(year_month,upc12)],u,by=c('year_month','upc12'))
errs<-sapply(c('ml','units','rev'),function(z)max(abs(check[[paste0(z,'.x')]]/check[[paste0(z,'.y')]]-1)))
stopifnot(max(errs)<1e-8)
s<-as.data.table(readRDS(paths[3]));s[,year_month:=format(as.Date(month),'%Y-%m')]
x<-merge(x,u[,.(year_month,upc12,nic)],by=c('year_month','upc12'),all.x=TRUE)
x<-merge(x,s[,.(year_month,upc12,device_size_eligible,ml_per_cartridge)],by=c('year_month','upc12'),all.x=TRUE)
stopifnot(!anyNA(x$nic),!anyNA(x$device_size_eligible),!anyDuplicated(x[,.(STATE,year_month,upc12)]))
x[,price:=state_revenue/state_ml]
b<-x[,.(Q=sum(state_ml),revenue=sum(state_revenue),p_it=mean(price),p_volume=sum(state_revenue)/sum(state_ml),
 a_it=mean(nic),log_upc_variety=log(.N),n_device=sum(device_size_eligible),
 missing_size=sum(device_size_eligible & !is.finite(ml_per_cartridge)),
 avg_ml_per_ecig=if(any(device_size_eligible)&&all(is.finite(ml_per_cartridge[device_size_eligible])))mean(ml_per_cartridge[device_size_eligible])else NA_real_),
 by=.(STATE,year_month,brand)]
b[,month:=as.Date(paste0(year_month,'-01'))];b[,year:=as.integer(substr(year_month,1,4))]
# Same national annual demand roster; local presence required, no zero-share imputation.
load(paths[4],e);national<-as.data.table(e$demand_im);market<-as.data.table(e$demand_mkt)
roster<-unique(national[,.(brand,year)]);roster[,incumbent:=TRUE]
b<-merge(b,roster,by=c('brand','year'),all.x=TRUE)
b[is.na(incumbent),incumbent:=FALSE]
# State population; existing national intensity, no new NCP estimation.
readpop<-function(f,yrs){p<-fread(file.path(FIRM_DIR,'raw','census_pop',f));p<-p[SEX==0 & ORIGIN==0];
 melt(p,id.vars=c('STATE','AGE'),measure.vars=paste0('POPESTIMATE',yrs),variable.name='yr',value.name='pop')[,
 .(adults=sum(pop[AGE>=18])),by=.(STATE,year=as.integer(sub('POPESTIMATE','',yr)))]}
pop<-rbindlist(list(readpop('sc-est2020int-alldata6.csv',2013:2019),readpop('sc-est2023-alldata6.csv',2020:2023)))
pop[,STATE:=sprintf('%02d',as.integer(STATE))];pop[,weight:=adults/sum(adults),by=year]
load(paths[5],e);tax<-as.data.table(e$closed_t)[,.(year_month,STATE=sprintf('%02d',as.integer(fips_state_code)),tax=real_tau_per_mL)]
m<-b[,.(Q_total=sum(Q),active_count=.N,monthly_count=sum(Q/sum(Q)>.07)),by=.(STATE,year_month,month,year)]
m<-merge(m,pop[,.(STATE,year,weight)],by=c('STATE','year'),all.x=TRUE)
m<-merge(m,market[,.(month,M_t,M_t_k_monthly,M_t_k_const)],by='month',all.x=TRUE)
m<-merge(m,tax,by=c('STATE','year_month'),all.x=TRUE)
for(z in c('M_t','M_t_k_monthly','M_t_k_const'))set(m,j=z,value=m[[z]]*m$weight)
fwrite(m,file.path(out,'state_month_market_checks.csv'))
stopifnot(!anyNA(m),all(m$Q_total>0))
ac<-roster[,.(annual_count=.N),by=year]
b<-merge(b,m,by=c('STATE','year_month','month','year'));b<-merge(b,ac,by='year')
b[,idx:=year*12L+as.integer(substr(year_month,6,7))]
lag<-b[,.(STATE,brand,idx=idx+1L,a_lag1=a_it)]
b<-merge(b,lag,by=c('STATE','brand','idx'),all.x=TRUE)
b[,ln_share:=log(Q/Q_total)]
# Matched complete-size, complete-lag sample across all specifications and prices.
b[,valid_market:=Q_total<M_t & Q_total<M_t_k_monthly & Q_total<M_t_k_const]
saveRDS(b,file.path(out,'candidate_panel.rds'))
fwrite(b[incumbent==TRUE,.(rows=.N,missing_size=sum(!is.finite(avg_ml_per_ecig)),missing_lag=sum(!is.finite(a_lag1)),invalid_market=sum(!valid_market))],file.path(out,'sample_checks.csv'))
d<-b[incumbent==TRUE & is.finite(avg_ml_per_ecig) & is.finite(a_lag1) & valid_market]
stopifnot(nrow(d)>0,!anyDuplicated(d[,.(STATE,brand,month)]))
sets<-list(Active=c('tax','active_count'),Annual=c('tax','annual_count'),Monthly=c('tax','monthly_count'),
 Annual_Lag=c('tax','annual_count','a_lag1'),Monthly_Lag=c('tax','monthly_count','a_lag1'))
groups<-list(B=character(),S='avg_ml_per_ecig',V='log_upc_variety',SV=c('avg_ml_per_ecig','log_upc_variety'))
fes<-c(pooled='',brand_state='brand + STATE',brand_by_state='brand^STATE')
markets<-c(annual='M_t',monthly='M_t_k_monthly',constant='M_t_k_const')
cc<-sp<-fail<-list();models<-list()
for(g in names(groups))for(fe in names(fes))for(p in c('p_it','p_volume'))for(q in c('Exogenous','Endogenous'))for(iv in names(sets)){
 if(q=='Endogenous' && !'a_lag1'%in%sets[[iv]])next
 exog<-c(if(q=='Exogenous')'a_it',groups[[g]])
 endog<-c('price','ln_share',if(q=='Endogenous')'a_it')
 d[,price:=get(p)]
 for(mk in names(markets)){
  d[,y:=log(Q/get(markets[[mk]]))-log1p(-Q_total/get(markets[[mk]]))]
  id<-paste(g,fe,p,q,iv,mk,sep='_')
  f<-paste('y ~',if(length(exog))paste(exog,collapse=' + ')else '1')
  if(nzchar(fes[[fe]]))f<-paste(f,'|',fes[[fe]])
  f<-as.formula(paste(f,'|',paste(endog,collapse=' + '),'~',paste(sets[[iv]],collapse=' + ')))
  fit<-tryCatch(feols(f,d,vcov=~STATE+month,notes=FALSE),error=function(e)e)
  if(inherits(fit,'error')){fail[[id]]<-data.table(id,error=conditionMessage(fit));next}
  ct<-coeftable(fit)
  if(!all(paste0('fit_',endog)%in%rownames(ct))){fail[[id]]<-data.table(id,error='Endogenous regressor dropped');next}
  cc[[id]]<-data.table(id,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4])
  sp[[id]]<-data.table(id,controls=g,FE=fe,price=p,quality=q,instruments=paste(sets[[iv]],collapse=' + '),market=mk,n=nobs(fit),states=uniqueN(d$STATE),months=uniqueN(d$month),alpha=coef(fit)['fit_price'],sigma=coef(fit)['fit_ln_share'])
 }
 cat('Completed',g,fe,p,q,iv,'\n')
}
fwrite(rbindlist(cc),file.path(out,'coefficients.csv'));fwrite(rbindlist(sp),file.path(out,'specifications.csv'))
fwrite(if(length(fail))rbindlist(fail,fill=TRUE)else data.table(id=character(),error=character()),file.path(out,'failed_specifications.csv'))
# Full fitted objects are not retained; coefficients, SEs and diagnostics are exported above.
stopifnot(identical(hashes,tools::md5sum(paths)))
fwrite(data.table(path=paths,md5=unname(hashes)),file.path(out,'input_hashes.csv'))
writeLines(c('Firm-state-month nested-logit sensitivity, 2026-10-26.',
'National annual >7% roster retained. All eligible local brands enter inside-category totals, including fringe.',
'Local active count and monthly >7% count include focal brand. Annual count is national, matching original definition.',
'State taxes in real dollars/mL. Both equal-UPC price and revenue/volume price. Quality and strict device-size mean are equal-UPC over local assortment; variety is log local UPC count.',
'National eligibility requires three stores per UPC-month; no extra local store cutoff imposed.',
'Market size is existing national market size times state adult population share; maintains national NCP intensity. This is an assumption, not validated local demand capacity.',
'Matched complete-lag/size sample and positive outside shares under all three market variants. No imputation. State-specific calendar lag from all eligible local brand history.',
'Fixed effects: pooled, additive brand/state, brand-state pair; no state-month FE (single-nest identity). SE clustered by state and month.',
'This changes local assortment and instruments together with aggregation. Differences alone do not isolate aggregation as the cause. Instrument validity remains unestablished.',
'No canonical files or meeting Markdown changed.'),file.path(out,'interpretation.txt'))
print(rbindlist(sp)[,.(fits=.N,sigma_between_0_1=sum(sigma>0 & sigma<1),also_negative_alpha=sum(sigma>0 & sigma<1 & alpha<0)),by=.(price,quality)])
