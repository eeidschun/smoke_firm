## Matched incumbent sample aggregation diagnostic; no structural changes.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
out<-file.path(PRELIM_DIR,"state_price_tax_diagnostic","aggregation_bridge")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
base<-as.data.table(readRDS(file.path(OUT_DIR,"demand_estimation/specification_comparison/product_size/estimation_sample.rds")))
stopifnot(nrow(base)==528,!anyDuplicated(base[,.(brand,year_month)]))
x<-as.data.table(readRDS(file.path(PRELIM_DIR,"state_price_tax_diagnostic/state_upc_month.rds")))
x<-merge(x,base[,.(brand,year_month)],by=c("brand","year_month"))
# Reconstruct current national price by pooling revenue and volume within UPC first.
up<-x[,.(p=sum(state_revenue)/sum(state_ml)),by=.(brand,year_month,upc12)]
chk<-merge(up[,.(rebuilt=mean(p)),by=.(brand,year_month)],base,by=c("brand","year_month"))
stopifnot(nrow(chk)==528,max(abs(chk$rebuilt-chk$p_it))<1e-8)
s<-x[,.(p_local=mean(state_revenue/state_ml),p_volume=sum(state_revenue)/sum(state_ml),
         state_ml=sum(state_ml),state_revenue=sum(state_revenue),n_local_upcs=.N),by=.(brand,year_month,STATE)]
load(file.path(FIRM_DIR,"raw/ecig_taxes/ec_tax_cotti_per_mL.RData"))
t<-as.data.table(closed_t)[,.(year_month,STATE=sprintf("%02d",as.integer(fips_state_code)),tax=real_tau_per_mL)]
s<-merge(s,t,by=c("year_month","STATE"),all.x=TRUE)
readpop<-function(file,years){p<-fread(file.path(FIRM_DIR,"raw/census_pop",file));p<-melt(p[SEX==0 & ORIGIN==0],id.vars="STATE",measure.vars=paste0("POPESTIMATE",years),variable.name="year",value.name="pop");p[,.(pop=sum(pop)),by=.(STATE=sprintf("%02d",as.integer(STATE)),year=as.integer(sub("POPESTIMATE","",year)))]}
pop<-rbind(readpop("sc-est2020int-alldata6.csv",2013:2019),readpop("sc-est2023-alldata6.csv",2020:2023))
s[,year:=as.integer(substr(year_month,1,4))];s<-merge(s,pop,by=c("STATE","year"),all.x=TRUE)
s<-merge(s,base[,.(brand,year_month,a_it,avg_ml_per_ecig,log_upc_variety,n_brands_3st,n_brands_overlap)],by=c("brand","year_month"))
stopifnot(!anyNA(s))
s[,equal_firm_month_weight:=1/.N,by=.(brand,year_month)]
n<-s[,.(p_state_equal=mean(p_local),p_state_pop=weighted.mean(p_local,pop),
         p_state_sales=weighted.mean(p_local,state_ml),
         p_volume=sum(state_revenue)/sum(state_ml),tax_pop=weighted.mean(tax,pop),
         tax_equal=mean(tax),tax_sales=weighted.mean(tax,state_ml)),by=.(brand,year_month)]
n<-merge(n,base,by=c("brand","year_month"))
stopifnot(nrow(n)==528,max(abs(n$tax_pop-n$TaxIV_geo))<1e-10,max(abs(n$p_volume-n$revenue_real/n$mL))<1e-8)
models<-list();meta<-list()
add<-function(name,y,tax,data,controls=TRUE,fe="brand",weights=NULL,level="national"){
  rhs<-paste(tax,"+ n_brands_3st",if(controls)"+ a_it + avg_ml_per_ecig + log_upc_variety" else "")
  f<-as.formula(paste(y,"~",rhs,"|",fe))
  models[[name]]<<-feols(f,data,weights=weights,vcov=if(level=="national")~year_month else ~STATE+year_month)
  meta[[name]]<<-list(tax=tax,level=level)
}
add("N_current_SV3","p_it","TaxIV_geo",n)
add("N_current_SV4","p_it","TaxIV_geo",transform(n,n_brands_3st=n_brands_overlap))
add("N_current_without_product_controls","p_it","TaxIV_geo",n,FALSE)
for(mask in 1:6){
  vars<-c("a_it","avg_ml_per_ecig","log_upc_variety")[as.logical(intToBits(mask)[1:3])]
  nm<-paste("N_controls",paste(vars,collapse="_"),sep="_")
  models[[nm]]<-feols(as.formula(paste("p_it ~ TaxIV_geo + n_brands_3st +",paste(vars,collapse=" + "),"| brand")),n,vcov=~year_month)
  meta[[nm]]<-list(tax="TaxIV_geo",level="national")
}
for(y in c("p_it","p_state_equal","p_state_pop","p_state_sales","p_volume"))for(tax in c("tax_pop","tax_equal","tax_sales"))add(paste("N",y,tax,sep="_"),y,tax,n)
for(fe in c("brand","brand + STATE","brand + STATE + year_month"))for(control in c(FALSE,TRUE)){
  nm<-paste("S",gsub(" + ","_",fe,fixed=TRUE),if(control)"controls" else "count_only",sep="_")
  add(nm,"p_local","tax",s,control,fe,~equal_firm_month_weight,"state")
}
add("S_state_FE_unweighted","p_local","tax",s,TRUE,"brand + STATE",NULL,"state")
add("S_state_month_FE_volume_price","p_volume","tax",s,TRUE,"brand + STATE + year_month",~equal_firm_month_weight,"state")
r<-rbindlist(lapply(names(models),function(nm){m<-models[[nm]];v<-meta[[nm]]$tax;ct<-coeftable(m);ci<-confint(m,v);data.table(model=nm,level=meta[[nm]]$level,n=nobs(m),tax_coef=ct[v,1],se=ct[v,2],lo=ci[1],hi=ci[2])}))
stopifnot(abs(r[model=="N_current_SV3",tax_coef]+1.69852)<1e-5,abs(r[model=="N_current_SV4",tax_coef]+1.69543)<1e-5)
fwrite(r,file.path(out,"results.csv"));saveRDS(models,file.path(out,"models.rds"));saveRDS(s,file.path(out,"state_sample.rds"));fwrite(n,file.path(out,"national_sample.csv"))
fwrite(chk[,.(brand,year_month,rebuilt,p_it,error=rebuilt-p_it)],file.path(out,"price_reconciliation.csv"))
lines<-c("# Matched incumbent aggregation bridge","","All national comparisons retain exactly the 528 SV3/SV4 incumbent firm-months. Current national representative price and geographic population-weighted tax are independently reconstructed and agree within 1e-8/1e-10. SV3/SV4 price-stage tax slopes reproduced within 1e-5.","",
"National fits use firm FE, national brand count, nicotine, capacity and log variety unless named without_product_controls. SV4 substitutes geographic count. National errors clustered by month. Alternative price averages first compute equal-UPC local prices, then average states using equal, population, or mL-sales weights. p_volume is aggregate revenue/volume. tax_sales uses contemporaneous mL weights and is diagnostic only; it is not an approved instrument.","",
"State fits retain precisely those firm-months but expand them across observed operating states. Default weights 1/number of operating states give each firm-month total weight one; the unweighted fit is explicit. State errors clustered by state and month. Controls remain national firm-month attributes, not local product attributes. Count_only retains brand count and FE but drops all three product controls. Brand count is absorbed when month FE are included. All state comparisons use the same state rows. Full month FE are valid for this price diagnostic, not a proposed structural demand specification. N_controls rows include exactly the named controls, brand count and firm FE.","",
"The remaining national/state differences include local versus pooled UPC assortment, geographic averaging, and unit of regression observation. Sign changes cannot alone prove instrument validity, causality, or the cause of sigma > 1. No canonical inputs, demand fits, or NCP data changed.","",
"| Model | N | Tax slope | SE | 95% CI |","|---|---:|---:|---:|---|")
for(i in seq_len(nrow(r))){z<-r[i];lines<-c(lines,sprintf("| %s | %d | %.4f | %.4f | [%.4f, %.4f] |",z$model,z$n,z$tax_coef,z$se,z$lo,z$hi))}
writeLines(c(lines,"","Reproduce: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/18_aggregation_price_tax_bridge.R`."),file.path(out,"README.md"));print(r)
