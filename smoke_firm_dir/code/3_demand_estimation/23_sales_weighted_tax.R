## Matched national-grid sensitivity to brand-state liquid-volume tax weights.
## Run from repository root. Existing canonical inputs/results are read only.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source('smoke_firm_dir/code/fxns/1_paths.R')
setDTthreads(2);setFixest_nthreads(1)
base<-file.path(OUT_DIR,'demand_estimation','advisor_instruments_2026-10-20')
runout<-file.path(OUT_DIR,'demand_estimation','sales_weighted_tax_2026-10-27')
dir.create(runout,recursive=TRUE,showWarnings=FALSE)
paths<-c(file.path(base,'candidate_panel.rds'),file.path(PRELIM_DIR,'state_price_tax_diagnostic','state_upc_month.rds'),
 file.path(FIRM_DIR,'raw','ecig_taxes','ec_tax_cotti_per_mL.RData'),
 file.path(CODE_DIR,'3_demand_estimation',c('12_advisor_48_grid.R','14_endogenous_quality_grid.R')),
 file.path(OUT_DIR,'demand_estimation','specification_comparison','market_size','models.rds'))
hashes<-tools::md5sum(paths)
d<-as.data.table(readRDS(paths[1]));x<-as.data.table(readRDS(paths[2]));x[,brand:=trimws(brand)]
e<-new.env();load(paths[3],e)
tax<-as.data.table(e$closed_t)[,.(year_month,STATE=sprintf('%02d',as.integer(fips_state_code)),tau=real_tau_per_mL)]
stopifnot(!anyDuplicated(tax[,.(year_month,STATE)]),!anyDuplicated(x[,.(year_month,STATE,upc12)]))
x<-x[,.(volume=sum(state_ml),revenue=sum(state_revenue)),by=.(year_month,brand,STATE)]
x<-merge(x,tax,by=c('year_month','STATE'),all.x=TRUE)
stopifnot(!anyNA(x),all(x$volume>0))
x[,weight:=volume/sum(volume),by=.(brand,year_month)]
agg<-x[,.(TaxIV_sales=sum(weight*tau),state_volume=sum(volume),state_revenue=sum(revenue),weight_sum=sum(weight),
 min_tau=min(tau),max_tau=max(tau)),by=.(brand,year_month)]
d<-merge(d,agg,by=c('brand','year_month'),all.x=TRUE)
stopifnot(nrow(d)==540,!anyNA(d$TaxIV_sales),max(abs(d$state_volume/d$mL-1))<1e-8,
 max(abs(d$state_revenue/d$revenue_real-1))<1e-8,max(abs(d$weight_sum-1))<1e-12,
 all(d$TaxIV_sales>=d$min_tau-1e-12 & d$TaxIV_sales<=d$max_tau+1e-12))
fwrite(d[,.(brand,month,TaxIV_population=TaxIV_geo,TaxIV_sales,mL,state_volume,weight_sum)],file.path(runout,'tax_comparison.csv'))
fwrite(x,file.path(runout,'brand_state_month_weights.csv'))
sets<-list(National=c('TaxIV_geo','n_brands_3st'),Geographic=c('TaxIV_geo','n_brands_overlap'),
 Annual=c('TaxIV_geo','incumbent_annual'),Monthly=c('TaxIV_geo','incumbent_monthly'),Lag=c('TaxIV_geo','a_lag1'))
for(b in c('National','Geographic'))for(a in c('incumbent_annual','incumbent_monthly','a_lag1'))sets[[paste(b,a,sep='+')]]<-c(sets[[b]],a)
sets$Annual_Lag<-c('TaxIV_geo','incumbent_annual','a_lag1');sets$Monthly_Lag<-c('TaxIV_geo','incumbent_monthly','a_lag1')
for(b in c('National','Geographic'))for(a in c('incumbent_annual','incumbent_monthly'))sets[[paste(b,a,'lag',sep='+')]]<-c(sets[[b]],a,'a_lag1')
sets$Annual_Monthly<-c('TaxIV_geo','incumbent_annual','incumbent_monthly');sets$Annual_Monthly_Lag<-c(sets$Annual_Monthly,'a_lag1')
stopifnot(length(sets)==19)
# Reuse audited estimation/conditional-F implementations, with isolated paths.
# TaxIV_geo remains the internal regressor name; mode metadata identifies its weights.
for(mode in c('population','sales')){
 parent0<-file.path(runout,mode);dir.create(parent0,recursive=TRUE,showWarnings=FALSE)
 panel<-copy(d);if(mode=='sales')panel[,TaxIV_geo:=TaxIV_sales]
 saveRDS(panel,file.path(parent0,'candidate_panel.rds'));saveRDS(list(instrument_sets=sets),file.path(parent0,'instrument_sets.rds'))
 for(script in c('12_advisor_48_grid.R','14_endogenous_quality_grid.R')){
  txt<-paste(readLines(file.path(CODE_DIR,'3_demand_estimation',script)),collapse='\n')
  txt<-sub('parent<-file.path(OUT_DIR,"demand_estimation","advisor_instruments_2026-10-20")',paste0('parent<-',encodeString(parent0,quote='"')),txt,fixed=TRUE)
  txt<-gsub('c("candidate_panel.rds","models.rds")','c("candidate_panel.rds","instrument_sets.rds")',txt,fixed=TRUE)
  # population mode reproduces the 48 saved baseline models/covariances;
  # sales mode validates all 1344 fits by QR but is intentionally different.
  if(mode=='sales' && script=='12_advisor_48_grid.R'){
   txt<-sub('if(sample0=="available" && price0=="p_it" && set0 %in% c("National","Geographic"))','if(FALSE)',txt,fixed=TRUE)
   txt<-sub('length(validation)==48L','length(validation)==0L',txt,fixed=TRUE)
  }
  # Old README prose describes original October 20 runs; omit it for this sensitivity.
  cut<-regexpr('lines<-c(',txt,fixed=TRUE)[1]
  if(cut>0)txt<-substr(txt,1,cut-1)
  # Retain coefficient/SE/diagnostic tables, not large full fitted-object lists.
  txt<-gsub('   models[[id]]<-m','   # Full fitted object not retained.',txt,fixed=TRUE)
  txt<-gsub('saveRDS(list(models=models,instrument_sets=sets),file.path(out,"models.rds"))',
    '# Full fitted objects not saved; instrument sets are in parent/instrument_sets.rds.',txt,fixed=TRUE)
  generated<-file.path(parent0,paste0('executed_',script));writeLines(txt,generated)
  env<-new.env(parent=globalenv());eval(parse(text=txt),envir=env)
 }
}
stopifnot(identical(hashes,tools::md5sum(paths)))
fwrite(data.table(path=paths,md5=unname(hashes)),file.path(runout,'input_hashes.csv'))
writeLines(c('Tax-weight sensitivity: 2026-10-27.',
'Population: existing population weights over each brand-month operating states.',
'Sales: same-month brand-specific eligible liquid-volume shares across states; not revenue/package weights or a simple UPC average.',
'Both prices, controls B/S/V/SV, with/without firm FE, three market sizes, 19 exogenous-quality instrument sets and 9 identified endogenous-quality sets.',
'Per mode: 1344 exogenous-quality + 432 endogenous-quality = 1776 fits. Exogenous-quality grid includes original 48 designs.',
'All original samples, market sizes, prices, quality and other instruments unchanged. TaxIV_geo is internal name in each mode; weights differ by mode.',
'Population original48 validation checks against saved canonical estimates/covariances. Every fit has independent QR slope/residual checks; conditional F checks retained.',
'Sales weights can correlate with demand shocks and quantity measurement error. Admissible sigma is not evidence of exclusion or a model-selection criterion.',
'Existing panels, NCP input, raw data and original results not overwritten.'),file.path(runout,'interpretation.txt'))
