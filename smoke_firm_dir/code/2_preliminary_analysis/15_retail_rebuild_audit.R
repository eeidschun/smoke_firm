## Audit the authorized 2026-10-07 rebuild against its preserved snapshot.
source("smoke_firm_dir/code/fxns/1_paths.R")
suppressPackageStartupMessages(library(dplyr))
backup <- file.path(FIRM_DIR,"backups","retail_rebuild_2026-10-07")
read_object <- function(path,name) {e<-new.env();load(path,e);e[[name]]}
old <- read_object(file.path(backup,"input/upc_month_niccorr_from_full.RData"),"upc_month_t2")
new <- read_object(file.path(SUPPORT_DIR,"upc_month_niccorr_from_full.RData"),"upc_month_t2")
bt <- read_object(file.path(SUPPORT_DIR,"bt_month_t2_niccorr_from_full.RData"),"bt_month_t2")
out <- file.path(OUT_DIR,"demand_estimation","retail_rebuild_2026-10-07")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
metrics<-c("units_sum","revenue_nom","revenue_real","mL_sum","nic_mg_sum")
totals<-data.frame(metric=metrics,old=vapply(old[metrics],sum,numeric(1)),new=vapply(new[metrics],sum,numeric(1)))
totals$change_pct<-100*(totals$new/totals$old-1)
write.csv(totals,file.path(out,"national_totals.csv"),row.names=FALSE)
# UPC aggregation must equal the independently rebuilt canonical brand panel.
ch<-new %>% group_by(month,brand,type) %>% summarise(across(all_of(metrics),sum),.groups="drop") %>%
 full_join(bt %>% select(month,brand,type,all_of(metrics)),by=c("month","brand","type"),suffix=c("_upc","_brand"))
for(v in metrics)stopifnot(!anyNA(ch[[paste0(v,"_upc")]]),!anyNA(ch[[paste0(v,"_brand")]]),
 max(abs(ch[[paste0(v,"_upc")]]-ch[[paste0(v,"_brand")]])/pmax(1,abs(ch[[paste0(v,"_brand")]])))<1e-8)
collapse <- function(x)x %>% group_by(month,brand,upc12) %>% summarise(across(all_of(metrics),sum),.groups="drop")
n<-collapse(new);o<-collapse(old)
u<-full_join(o,n,by=c("month","brand","upc12"),suffix=c("_old","_new")) %>%
 mutate(mL_change=mL_sum_new-mL_sum_old,nic_change=nic_mg_sum_new-nic_mg_sum_old)
write.csv(u %>% filter(is.na(mL_change)|abs(mL_change)>1e-6|abs(nic_change)>1e-6),file.path(out,"changed_upc_months.csv"),row.names=FALSE)
manual<-read.csv(file.path(SUPPORT_DIR,"manual_product_size_corrections.csv"),colClasses=c(upc12="character"))
r<-n %>% inner_join(manual,by="upc12") %>% mutate(observed_pack_ml=mL_sum/units_sum,expected_pack_ml=cartridges_per_pack*ml_per_cartridge)
stopifnot(max(abs(r$observed_pack_ml-r$expected_pack_ml))<1e-8)
write.csv(r %>% distinct(brand,upc12,observed_pack_ml,expected_pack_ml),file.path(out,"reviewed_pack_identity.csv"),row.names=FALSE)
d<-read_object(file.path(SUPPORT_DIR,"demand_panel_firm_month.RData"),"demand_im")
dold<-read_object(file.path(backup,"input/demand_panel_firm_month.RData"),"demand_im")
roster<-full_join(dold %>% distinct(year,brand) %>% mutate(before=TRUE),d %>% distinct(year,brand) %>% mutate(after=TRUE),by=c("year","brand"))
write.csv(roster,file.path(out,"incumbent_roster.csv"),row.names=FALSE)
write.csv(full_join(dold,d,by=c("month","brand"),suffix=c("_old","_new")),file.path(out,"demand_before_after.csv"),row.names=FALSE)
breadth<-readRDS(file.path(SUPPORT_DIR,"upc_month_store_breadth.rds"))
prices<-n %>% filter(brand!="UNKNOWN",units_sum>0,mL_sum>0) %>% semi_join(breadth %>% filter(n_stores>=3),by=c("month","upc12")) %>%
 group_by(month,brand) %>% summarise(expected_price=mean(revenue_real/mL_sum),expected_nic=mean(nic_mg_sum/mL_sum),.groups="drop")
p<-inner_join(d,prices,by=c("month","brand"));stopifnot(nrow(p)==nrow(d),max(abs(p$p_it-p$expected_price))<1e-8,max(abs(p$a_it-p$expected_nic))<1e-8)
oldm<-read_object(file.path(backup,"input/demand_panel_firm_month.RData"),"demand_mkt")
newm<-read_object(file.path(SUPPORT_DIR,"demand_panel_firm_month.RData"),"demand_mkt")
m<-inner_join(oldm,newm,by="month",suffix=c("_old","_new"))
for(v in c("M_t","M_t_k_monthly","M_t_k_const"))stopifnot(max(abs(m[[paste0(v,"_old")]]-m[[paste0(v,"_new")]]))<1e-6)
stopifnot(identical(unname(tools::md5sum(file.path(backup,"input/avg_mL_by_hh_in_ncp.RData"))),unname(tools::md5sum(file.path(SUPPORT_DIR,"avg_mL_by_hh_in_ncp.RData")))))
controls<-read.csv(file.path(OUT_DIR,"demand_estimation/specification_comparison/product_size/model_checks.csv"))
market<-read.csv(file.path(OUT_DIR,"demand_estimation/specification_comparison/market_size/model_checks.csv"))
stopifnot(nrow(controls)==16,nrow(market)==48,all(controls$coefficient_check_error<1e-7),all(market$coefficient_check_error<1e-7))
a<-read.csv(file.path(OUT_DIR,"demand_estimation/specification_comparison/product_size/coefficients.csv"))
b<-read.csv(file.path(OUT_DIR,"demand_estimation/specification_comparison/market_size/coefficients.csv")) %>% filter(startsWith(id,"annual_")) %>% mutate(id=sub("annual_","",id))
t<-inner_join(a,b,by=c("id","parameter"),suffix=c("_base","_market"));stopifnot(nrow(t)==nrow(a),max(abs(t$estimate_base-t$estimate_market))<1e-7)
lines<-c("# Retail rebuild started 2026-10-07; validated 2026-10-08","",
 "Reviewed retail pack counts and volumes are now applied upstream. The NCP household input and all three saved market-size series are byte-for-byte / numerically unchanged, respectively.","",
 paste("Pre-rebuild snapshot:",backup),"",
 "## Changes and validation","",
 sprintf("Demand sample: %d before, %d after. Matched product-control sample: %d. Incumbent year-brand roster changes: %d.",nrow(dold),nrow(d),controls$n[1],sum(is.na(roster$before)|is.na(roster$after))),"",
 "| Metric | Before | After | Change (%) |","|---|---:|---:|---:|")
for(i in seq_len(nrow(totals)))lines<-c(lines,sprintf("| %s | %.3f | %.3f | %.6f |",totals$metric[i],totals$old[i],totals$new[i],totals$change_pct[i]))
lines<-c(lines,"","Checks passed: reviewed pack-volume identities; UPC-to-brand totals (units, revenue, volume, nicotine); unweighted price and nicotine calculations; unchanged NCP file and market-size series; independent 2SLS checks for 16 control models and 48 market-size variants; annual market-size results reproduce the corresponding baseline fits.","",
 "The three NCP constructions use annual-mean, monthly, or full-period-mean household purchasing intensity, each multiplied by that year's July adult population. Market sensitivity changes outside shares and the dependent variable while holding the sample, within-nest shares, prices, controls and instruments fixed.","",
 "Current estimates: [comparison report](../output/demand_estimation/specification_comparison/README.md). Detailed rebuild differences: output/demand_estimation/retail_rebuild_2026-10-07/. Historical conversation transcripts and the dated snapshot retain their original content.")
writeLines(lines,file.path(FIRM_DIR,"docs/retail_rebuild_2026-10-07.md"))
print(totals);cat("Rebuild audit passed.\n")
