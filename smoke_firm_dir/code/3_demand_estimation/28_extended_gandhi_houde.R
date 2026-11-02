## Extended GH sensitivity, using the audited first-pass estimator in isolated environments.
source('smoke_firm_dir/code/fxns/1_paths.R')
suppressPackageStartupMessages(library(data.table))
root<-file.path(OUT_DIR,'demand_estimation','gandhi_houde_extended_2026-11-02')
dir.create(root,recursive=TRUE,showWarnings=FALSE)
source_path<-file.path(CODE_DIR,'3_demand_estimation','27_gandhi_houde_exercise.R')
template<-paste(readLines(source_path),collapse='\n')
cut<-regexpr('# Reproduce matched full-coverage baselines',template,fixed=TRUE)[1]
if(cut>0)template<-substr(template,1,cut-1)
inputs<-c(source_path,file.path(OUT_DIR,'demand_estimation','sales_weighted_tax_2026-10-27','sales','candidate_panel.rds'),file.path(SUPPORT_DIR,'demand_panel_firm_month.RData'))
hashes<-tools::md5sum(inputs)
for(pool in c('incumbents','incumbents_fringe'))for(band in c(.5,1,2)){
 label<-paste0(pool,'_band_',band);path0<-file.path(root,label)
 txt<-sub("out<-file.path(OUT_DIR,'demand_estimation','gandhi_houde_2026-11-02')",paste0('out<-',encodeString(path0,quote='"')),template,fixed=TRUE)
 old<-"characteristics<-list(nicotine='a_it',nicotine_size=c('a_it','avg_ml_per_ecig'),\n nicotine_size_variety=c('a_it','avg_ml_per_ecig','log_upc_variety'))"
 new<-"characteristics<-list(nicotine='a_it',size='avg_ml_per_ecig',variety='log_upc_variety',nicotine_size=c('a_it','avg_ml_per_ecig'),nicotine_variety=c('a_it','log_upc_variety'),size_variety=c('avg_ml_per_ecig','log_upc_variety'),nicotine_size_variety=c('a_it','avg_ml_per_ecig','log_upc_variety'))"
 if(pool=='incumbents_fringe')new<-"characteristics<-list(nicotine='a_it')"
 stopifnot(grepl(old,txt,fixed=TRUE));txt<-sub(old,new,txt,fixed=TRUE)
 if(pool=='incumbents_fringe'){
  marker<-"# Full incumbent roster first, before exclusions from the estimating sample."
  add<-paste0(marker,"\ne<-new.env();load(file.path(SUPPORT_DIR,'demand_panel_firm_month.RData'),e)\nfr<-as.data.table(e$demand_mkt)[,.(brand='__FRINGE__',month,a_it=a_Ft)]\n")
  txt<-sub(marker,add,txt,fixed=TRUE)
  txt<-sub("roster<-copy(full[month%in%complete[complete==TRUE,month]])","roster<-rbindlist(list(copy(full[month%in%complete[complete==TRUE,month]]),fr),fill=TRUE)",txt,fixed=TRUE)
 }
 txt<-sub('abs(delta)<threshold',paste0('abs(delta)<',band,'*threshold'),txt,fixed=TRUE)
 txt<-sub('sum(abs(dif)<threshold)',paste0('sum(abs(dif)<',band,'*threshold)'),txt,fixed=TRUE)
 # Interactions use standardized signed differences; scalar rescaling preserves IV span.
 marker<-"instruments[[family]]<-roster[,c('brand','month',local,quadratic),with=FALSE][,family:=family]"
 interactions<-r"{li<-qi<-character()
 for(aa in seq_along(chars))for(bb in seq_along(chars)){
  ca<-chars[aa];cb<-chars[bb]
  da<-pairs[[paste0(ca,'_j')]]-pairs[[paste0(ca,'_i')]]
  db<-pairs[[paste0(cb,'_j')]]-pairs[[paste0(cb,'_i')]]
  sa<-sd(da);sb<-sd(db)
  nl<-paste0('GH_li_',aa,'_',bb)
  pairs[,temporary:=(abs(da)<BAND*sa)*(db/sb)]
  ag<-pairs[,.(value=sum(temporary)),by=.(brand=brand_i,month)];setnames(ag,'value',nl)
  roster<-merge(roster,ag,by=c('brand','month'));li<-c(li,nl)
  if(bb>aa){nq<-paste0('GH_qi_',aa,'_',bb)
   pairs[,temporary:=(da/sa)*(db/sb)]
   ag<-pairs[,.(value=sum(temporary)),by=.(brand=brand_i,month)];setnames(ag,'value',nq)
   roster<-merge(roster,ag,by=c('brand','month'));qi<-c(qi,nq)
  }
 }
 instruments[[family]]<-roster[,c('brand','month',local,quadratic,li,qi),with=FALSE][,family:=family]
}"
 interactions<-gsub('BAND',as.character(band),interactions,fixed=TRUE)
 txt<-sub(marker,interactions,txt,fixed=TRUE)
 a<-regexpr('groups<-switch(family,',txt,fixed=TRUE)[1];b<-regexpr("sets<-list(Baseline=",txt,fixed=TRUE)[1]
 stopifnot(a>0,b>a)
 txt<-paste0(substr(txt,1,a-1),r"{groups<-list(B=character(),S='avg_ml_per_ecig',V='log_upc_variety',SV=c('avg_ml_per_ecig','log_upc_variety'))
 groups<-Filter(function(g)all(setdiff(chars,'a_it')%in%g),groups)
 }",substr(txt,b,nchar(txt)))
 marker<-"for(group in names(groups))for(set in names(sets)){"
 add<-r"{sets$Tax_Local_Interactions<-c('TaxIV_sales',local,li)
 sets$Tax_Quadratic_Interactions<-c('TaxIV_sales',quadratic,qi)
 sets$Baseline_Local_Interactions<-c('TaxIV_sales','incumbent_annual',local,li)
 sets$Baseline_Quadratic_Interactions<-c('TaxIV_sales','incumbent_annual',quadratic,qi)
 sets$Tax_Monthly_Local<-c('TaxIV_sales','incumbent_monthly',local)
 sets$Tax_Monthly_Quadratic<-c('TaxIV_sales','incumbent_monthly',quadratic)
 for(group in names(groups))for(set in names(sets)){
 }"
 txt<-sub(marker,add,txt,fixed=TRUE)
 # Quadratic-only versions do not depend on bandwidth but are deliberately repeated;
 # report design counts as sensitivities, not independent successes.
 # Skip redundant sets that differ only by absence of cross interactions in one dimension.
 txt<-sub("exog<-c('a_it',groups[[group]])", "if(set%in%c('Tax_Quadratic_Interactions','Baseline_Quadratic_Interactions') && !length(qi))next\n  exog<-c('a_it',groups[[group]])",txt,fixed=TRUE)
 # Guard singular conditional-F covariance without inventing generalized-inverse tests.
 txt<-sub('sw<-as.numeric(crossprod(gamma,solve(crossprod(scores),gamma)))/correction/(L-1)',
 "sw<-tryCatch(as.numeric(crossprod(gamma,solve(crossprod(scores),gamma)))/correction/(L-1),error=function(e)NA_real_)",txt,fixed=TRUE)
 txt<-sub("swref<-as.numeric(crossprod(bb,solve(vv,bb)))/(L-1);stopifnot(abs(sw-swref)<1e-5)",
 "swref<-tryCatch(as.numeric(crossprod(bb,solve(vv,bb)))/(L-1),error=function(e)NA_real_);if(is.finite(sw)&&is.finite(swref))stopifnot(abs(sw-swref)<1e-5)",txt,fixed=TRUE)
 txt<-sub("'No meeting notes", "'No meeting notes",txt,fixed=TRUE)
 dir.create(path0,recursive=TRUE,showWarnings=FALSE)
 writeLines(txt,file.path(path0,'executed_estimator.R'))
 env<-new.env(parent=globalenv());eval(parse(text=txt),env)
 writeLines(c(paste('Extended GH variant:',label),'See ../interpretation.txt for the expanded design and assumptions. Bandwidth-invariant fits are deliberate repetitions. All source estimates and checks are in this directory.'),file.path(path0,'interpretation.txt'))
 cat('FINISHED VARIANT',label,'\n')
}
all<-list();skip<-list();fs<-list()
for(folder in list.dirs(root,recursive=FALSE,full.names=TRUE)){
 name<-basename(folder);s<-fread(file.path(folder,'specifications.csv'));s[,variant:=name]
 s[,`:=`(pool=ifelse(grepl('incumbents_fringe',name),'incumbents_fringe','incumbents'),bandwidth=as.numeric(sub('.*_band_','',name)))]
 all[[name]]<-s
 v<-fread(file.path(folder,'skipped_designs.csv'));v[,variant:=name];skip[[name]]<-v
 f<-fread(file.path(folder,'first_stages.csv'));f[,variant:=name];fs[[name]]<-f
}
s<-rbindlist(all,fill=TRUE);f<-rbindlist(fs,fill=TRUE)
fwide<-unique(dcast(unique(f[,.(variant,design,outcome,SW_F)]),variant+design~outcome,value.var='SW_F'))
setnames(fwide,c('price','ln_s_i_g'),c('price_SW_F','share_SW_F'))
s<-merge(s,fwide,by=c('variant','design'),all.x=TRUE)
fwrite(s,file.path(root,'all_specifications.csv'));fwrite(rbindlist(skip,fill=TRUE),file.path(root,'skipped_designs.csv'))
base<-s[instrument_set=='Baseline',.(variant,family,controls,market,baseline_alpha=alpha,baseline_sigma=sigma)]
comparison<-merge(s,base,by=c('variant','family','controls','market'))
comparison[,`:=`(alpha_change=alpha-baseline_alpha,sigma_change=sigma-baseline_sigma)]
fwrite(comparison,file.path(root,'matched_comparison.csv'))
fwrite(s[,.(fits=.N,qualifying=sum(qualifying),also_negative_alpha=sum(joint),mean_sigma=if(any(qualifying))mean(sigma[qualifying])else NA_real_),by=.(pool,bandwidth,family,instrument_set)],file.path(root,'family_summary.csv'))
stopifnot(identical(hashes,tools::md5sum(inputs)))
fwrite(data.table(path=inputs,md5=unname(hashes)),file.path(root,'input_hashes.csv'))
writeLines(c('Extended GH-style trial November 2, 2026.',
'Incumbent pools: all seven nonempty combinations of nicotine, size, log variety; controls include all own characteristics used in IVs. Nicotine rivals also tested with an observed aggregate fringe alternative.',
'Local bandwidth 0.5, 1, 2 times pooled SD of ordered within-month characteristic differences; strict inequality. Quadratic sums normalized by SD squared.',
'Local signed-difference interactions and cross-characteristic quadratic interactions added, plus monthly-count combinations. One-product-per-brand, no ownership portfolio split.',
'Volume-weighted price; no firm or month FE; exogenous current characteristics; sales-weighted tax where present; existing three market sizes. No endogenous-quality or predicted-price instruments.',
'Months with missing rival characteristics dropped whole; original complete-size estimation rule retained. Baseline refit within each exact variant/characteristic/control/market sample. Bandwidth-invariant specifications repeated deliberately and not independent evidence.',
'Numerically unstable, underidentified and rank-deficient designs logged separately. Conditional F unavailable if clustered moment covariance singular; no generalized-inverse F invented.',
'Source construction: https://pyblp.readthedocs.io/en/stable/_api/pyblp.build_differentiation_instruments.html ; GH paper https://www.nber.org/papers/w26375 . Hand-coded IVs, no PyBLP estimator.',
'No full fitted objects, no supply specification change, no new raw rebuild. Characteristic and sales-tax exogeneity are maintained assumptions, not validated by admissible sigma.'),file.path(root,'interpretation.txt'))
print(s[,.(fits=.N,qualifying=sum(qualifying),joint=sum(joint)),by=.(pool,bandwidth)])
