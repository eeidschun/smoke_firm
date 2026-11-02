## Independent matrix construction checks and matched-baseline reporting.
source('smoke_firm_dir/code/fxns/1_paths.R')
suppressPackageStartupMessages(library(data.table))
root<-file.path(OUT_DIR,'demand_estimation','gandhi_houde_extended_2026-11-02')
full<-as.data.table(readRDS(file.path(OUT_DIR,'demand_estimation','sales_weighted_tax_2026-10-27','sales','candidate_panel.rds')))
e<-new.env();load(file.path(SUPPORT_DIR,'demand_panel_firm_month.RData'),e)
fr<-as.data.table(e$demand_mkt)[,.(brand='__FRINGE__',month,a_it=a_Ft)]
chars<-list(nicotine='a_it',size='avg_ml_per_ecig',variety='log_upc_variety',nicotine_size=c('a_it','avg_ml_per_ecig'),nicotine_variety=c('a_it','log_upc_variety'),size_variety=c('avg_ml_per_ecig','log_upc_variety'),nicotine_size_variety=c('a_it','avg_ml_per_ecig','log_upc_variety'))
checks<-list()
for(folder in list.dirs(root,recursive=FALSE,full.names=TRUE)){
 variant<-basename(folder);band<-as.numeric(sub('.*_band_','',variant))
 iv<-fread(file.path(folder,'differentiation_instruments.csv'));iv[,month:=as.Date(month)]
 thresholds<-fread(file.path(folder,'thresholds_and_construction_checks.csv'))
 for(fam in unique(iv$family)){
  cs<-chars[[fam]]
  ok<-full[,.(ok=all(is.finite(as.matrix(.SD)))),by=month,.SDcols=cs]
  roster<-full[month%in%ok[ok==TRUE,month]]
  if(grepl('incumbents_fringe',variant))roster<-rbindlist(list(roster,fr),fill=TRUE)
  for(mo in unique(roster$month)){
   d<-roster[month==mo];setorder(d,brand)
   got<-iv[family==fam & month==mo];setorder(got,brand);stopifnot(identical(d$brand,got$brand))
   D<-lapply(cs,function(ch)outer(d[[ch]],d[[ch]],function(i,j)j-i))
   sd0<-vapply(cs,function(ch)thresholds[family==fam & characteristic==ch,pair_difference_sd],numeric(1))
   err<-0
   for(a in seq_along(cs)){
    mask<-abs(D[[a]])<band*sd0[a];diag(mask)<-FALSE
    err<-max(err,abs(rowSums(mask)-got[[paste0('GH_local_',cs[a])]]),abs(rowSums((D[[a]]/sd0[a])^2)-got[[paste0('GH_quad_',cs[a])]]))
    for(b in seq_along(cs)){
     err<-max(err,abs(rowSums(mask*(D[[b]]/sd0[b]))-got[[paste0('GH_li_',a,'_',b)]]))
     if(b>a)err<-max(err,abs(rowSums((D[[a]]/sd0[a])*(D[[b]]/sd0[b]))-got[[paste0('GH_qi_',a,'_',b)]]))
    }
   }
   stopifnot(err<1e-9)
   checks[[paste(variant,fam,mo)]]<-data.table(variant,family=fam,month=as.Date(mo,origin='1970-01-01'),max_error=err)
  }
 }
 v<-fread(file.path(folder,'validation.csv'));stopifnot(all(v$coefficient_error<1e-7),all(v$residual_error<1e-7))
}
fwrite(rbindlist(checks),file.path(root,'independent_instrument_validation.csv'))
s<-fread(file.path(root,'all_specifications.csv'))
# Fixed baseline independent of bandwidth/rival-pool choice on a given sample.
b<-s[instrument_set=='Baseline'];test<-b[,.(spread_alpha=max(alpha)-min(alpha),spread_sigma=max(sigma)-min(sigma)),by=.(family,controls,market)]
stopifnot(max(test$spread_alpha)<1e-10,max(test$spread_sigma)<1e-10)
fwrite(test,file.path(root,'baseline_invariance.csv'))
fwrite(s[family=='nicotine' & controls=='B' & market=='constant'],file.path(root,'chosen_specification_neighborhood.csv'))
h<-fread(file.path(root,'input_hashes.csv'));stopifnot(all(unname(tools::md5sum(h$path))==h$md5))
print(data.table(retained=nrow(s),qualifying=sum(s$qualifying),negative_alpha_qualifying=sum(s$joint),instrument_comparisons=nrow(rbindlist(checks)),max_instrument_error=max(rbindlist(checks)$max_error)))
