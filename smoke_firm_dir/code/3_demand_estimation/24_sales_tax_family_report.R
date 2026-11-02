## Summarize matched tax-weight grids without estimating models.
suppressPackageStartupMessages(library(data.table))
source('smoke_firm_dir/code/fxns/1_paths.R')
root<-file.path(OUT_DIR,'demand_estimation','sales_weighted_tax_2026-10-27')
meeting<-file.path(FIRM_DIR,'docs','meetings');tables<-file.path(meeting,'tables')
dir.create(tables,recursive=TRUE,showWarnings=FALSE)
all<-list()
for(mode in c('population','sales'))for(folder in c('original_48_grid','endogenous_quality_grid')){
 p<-file.path(root,mode,folder);s<-fread(file.path(p,'specifications.csv'));c<-fread(file.path(p,'coefficients.csv'))
 s[,quality:=if(folder=='original_48_grid')'Exogenous'else'Endogenous']
 s<-merge(s,c[term=='fit_ln_s_i_g',.(id,sigma=estimate,sigma_se=std_error)],by='id')
 s<-merge(s,c[term=='fit_price',.(id,alpha=estimate,alpha_se=std_error)],by='id')
 s[,`:=`(tax_weights=mode,admissible=sigma>0 & sigma<1,lag_quality=grepl('a_lag1',excluded_instruments,fixed=TRUE))]
 s[,admissible_negative_alpha:=admissible & alpha<0]
 all[[paste(mode,folder)]]<-s
}
x<-rbindlist(all,fill=TRUE);stopifnot(nrow(x)==3552,!anyDuplicated(x[,.(tax_weights,id)]))
old<-x[tax_weights=='population'];new<-x[tax_weights=='sales']
stopifnot(sum(old$admissible)==357L,sum(old$admissible_negative_alpha)==354L)
paired<-merge(old,new,by='id',suffixes=c('_population','_sales'))
stopifnot(nrow(paired)==1776,all(paired$n_population==paired$n_sales),all(paired$months_population==paired$months_sales))
fwrite(x,file.path(tables,'2026-10-27_tax_weight_specification_index.csv'))
fwrite(new[admissible==TRUE],file.path(tables,'2026-10-27_sales_tax_sigma_between_zero_and_one.csv'))
fwrite(paired,file.path(tables,'2026-10-27_tax_weight_paired_comparison.csv'))
groups<-list(overall=character(),price_FE=c('price_measure','firm_FE'),quality='quality',instrument='instrument_set',controls='controls',market='market',lag='lag_quality',
 price_FE_instrument=c('price_measure','firm_FE','instrument_set'),price_FE_controls=c('price_measure','firm_FE','controls'),
 quality_price_FE=c('quality','price_measure','firm_FE'))
counts<-list();lines<-c('# Tax weighting: admissible-sigma families','','Analysis date: 2026-10-27. Meeting date: TBD.','',
'Each tax definition has 1,776 national firm-month fits (1,344 exogenous-quality and 432 endogenous-quality), including the original 48 designs. Strict qualification is 0 < sigma < 1. Samples, prices, controls and other instruments are matched. Sales means brand-specific current liquid-volume weights across states; population means the existing geographic population weights. Means and medians use only qualifying runs, with equal weight per specification; a dash means no qualifying runs. Counts include repeated sample comparisons and do not establish instrument validity.','')
for(name in names(groups)){
 keys<-c('tax_weights',groups[[name]])
 t<-x[,.(total=.N,qualifying=sum(admissible),qualifying_negative_alpha=sum(admissible_negative_alpha),pct=100*mean(admissible),mean_sigma=if(any(admissible))mean(sigma[admissible])else NA_real_,median_sigma=if(any(admissible))median(sigma[admissible])else NA_real_,mean_sigma_negative_alpha=if(any(admissible_negative_alpha))mean(sigma[admissible_negative_alpha])else NA_real_,median_sigma_negative_alpha=if(any(admissible_negative_alpha))median(sigma[admissible_negative_alpha])else NA_real_),by=keys]
 counts[[name]]<-copy(t)[,family:=name]
 lines<-c(lines,paste('##',name),'',paste0('| ',paste(c(keys,'Qualifying / total','Percent','Also negative alpha','Mean sigma','Median sigma'),collapse=' | '),' |'),
 paste0('|',paste(rep('---',length(keys)+5),collapse='|'),'|'))
 for(i in seq_len(nrow(t)))lines<-c(lines,paste0('| ',paste(c(unlist(t[i,..keys]),paste0(t$qualifying[i],' / ',t$total[i]),sprintf('%.1f%%',t$pct[i]),t$qualifying_negative_alpha[i],if(is.na(t$mean_sigma[i]))'—'else sprintf('%.3f',t$mean_sigma[i]),if(is.na(t$median_sigma[i]))'—'else sprintf('%.3f',t$median_sigma[i])),collapse=' | '),' |'))
 lines<-c(lines,'')
}
fwrite(rbindlist(counts,fill=TRUE),file.path(tables,'2026-10-27_tax_weight_family_counts.csv'))
writeLines(lines,file.path(meeting,'marc_mtg_2026-10-27_sales_tax_family_summary.md'))
transition<-paired[,.(runs=.N),by=.(population_admissible=admissible_population,sales_admissible=admissible_sales)]
fwrite(transition,file.path(tables,'2026-10-27_tax_weight_transitions.csv'))
# Focus on agreed provisional family: sales-weighted price, no firm FE.
focus<-new[price_measure=='p_it_volume_weighted' & firm_FE==FALSE,
 .(total=.N,qualifying=sum(admissible),also_negative_alpha=sum(admissible_negative_alpha),pct=100*mean(admissible),mean_sigma=if(any(admissible))mean(sigma[admissible])else NA_real_,median_sigma=if(any(admissible))median(sigma[admissible])else NA_real_),by=instrument_set][order(-pct)]
fwrite(focus,file.path(tables,'2026-10-27_sales_price_no_FE_instrument_families.csv'))
print(x[,.(total=.N,qualifying=sum(admissible),also_negative_alpha=sum(admissible_negative_alpha)),by=.(tax_weights,price_measure,firm_FE)])
print(transition);print(focus)
