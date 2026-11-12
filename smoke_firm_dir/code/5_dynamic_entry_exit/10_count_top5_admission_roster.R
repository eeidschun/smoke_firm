source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
setDTthreads(2)
files<-file.path(SUPPORT_DIR,c("upc_month_niccorr_from_full.RData","upc_month_store_breadth.rds","demand_panel_firm_month.RData"))
hashes<-tools::md5sum(files)
e<-new.env();load(files[1],e);u<-as.data.table(e$upc_month_t2)
u[,brand:=trimws(brand)]
u<-u[brand!="UNKNOWN" & units_sum>0 & mL_sum>0]
u<-u[,.(mL=sum(mL_sum)),by=.(month,brand,upc12)]
b<-as.data.table(readRDS(files[2]))[,.(month,upc12,n_stores)]
stopifnot(!anyDuplicated(b[,.(month,upc12)]))
u<-merge(u,b,by=c("month","upc12"),all.x=TRUE);u[is.na(n_stores),n_stores:=0L]
# Eligible volume exactly matches current demand universe; unfiltered volume is sensitivity.
eligible<-u[n_stores>=3,.(mL=sum(mL)),by=.(month,brand)]
all_sales<-u[,.(mL=sum(mL)),by=.(month,brand)]
load(files[3],e);market<-as.data.table(e$demand_mkt)
check<-merge(eligible[,.(total=sum(mL)),by=month],market[,.(month,total_expected=mL_inc+mL_fringe)],by="month")
stopifnot(nrow(check)==132L,max(abs(check$total-check$total_expected)/check$total_expected)<1e-10)
out<-file.path(OUT_DIR,"dynamic_entry_exit/top5_admission_roster_2026-11-04")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
summaries<-list()
pdf(file.path(out,"tracked_roster_counts.pdf"),width=10,height=6)
for(scope in c("demand_eligible","all_positive_sales")) {
 d<-copy(if(scope=="demand_eligible")eligible else all_sales)
 # Resolve any exact volume tie alphabetically; report boundary ties.
 setorder(d,month,-mL,brand);d[,rank:=seq_len(.N),by=month]
 tops<-d[rank<=5]
 admits<-tops[,.(admitted=min(month)),by=brand]
 lasts<-all_sales[,.(last_positive_sales=max(month)),by=brand]
 admits<-merge(admits,lasts,by="brand",all.x=TRUE)
 setorder(admits,admitted,brand)
 months<-sort(unique(d$month))
 panel<-CJ(month=months,brand=admits$brand)
 panel<-merge(panel,admits,by="brand")
 panel<-merge(panel,d[,.(brand,month,mL,rank)],by=c("brand","month"),all.x=TRUE)
 panel[,`:=`(ever_admitted=month>=admitted,retained_to_last_sale=month>=admitted & month<=last_positive_sales)]
 counts<-panel[,.(cumulative_admitted=sum(ever_admitted),retained_last_sale_proxy=sum(retained_to_last_sale),admitted_with_sales_this_month=sum(ever_admitted & !is.na(mL)),new_admissions=sum(admitted==month),current_top5=paste(brand[!is.na(rank)&rank<=5][order(rank[!is.na(rank)&rank<=5])],collapse="; ")),by=month][order(month)]
 # No unverified shutdown declared; last sale inclusive, right-censoring at sample end.
 admits[,right_censored:=last_positive_sales==max(months)]
 counts[,year:=as.integer(format(as.Date(month),"%Y"))]
 annual<-counts[,.(min_cumulative=min(cumulative_admitted),max_cumulative=max(cumulative_admitted),min_last_sale_proxy=min(retained_last_sale_proxy),max_last_sale_proxy=max(retained_last_sale_proxy)),by=year]
 ties<-d[,.(boundary_tie=if(.N>=6)mL[5]==mL[6] else FALSE),by=month]
 stopifnot(all(counts$cumulative_admitted>=counts$retained_last_sale_proxy),all(counts$retained_last_sale_proxy>=counts$admitted_with_sales_this_month),all(diff(counts$cumulative_admitted)>=0),counts$cumulative_admitted[1]==5L)
 summary<-data.table(sample=scope,total_admitted=nrow(admits),max_cumulative=max(counts$cumulative_admitted),max_last_sale_proxy=max(counts$retained_last_sale_proxy),months_proxy_above5=sum(counts$retained_last_sale_proxy>5),months_proxy_above6=sum(counts$retained_last_sale_proxy>6),months_proxy_above7=sum(counts$retained_last_sale_proxy>7),final_last_sale_proxy=tail(counts$retained_last_sale_proxy,1),boundary_ties=sum(ties$boundary_tie))
 summaries[[scope]]<-summary
 fwrite(counts,file.path(out,paste0(scope,"_monthly_counts.csv")))
 fwrite(annual,file.path(out,paste0(scope,"_annual_ranges.csv")))
 fwrite(admits,file.path(out,paste0(scope,"_admitted_brands.csv")))
 fwrite(panel,file.path(out,paste0(scope,"_brand_month_tracking.csv")))
 fwrite(d,file.path(out,paste0(scope,"_monthly_volume_ranks.csv")))
 plot(as.Date(counts$month),counts$cumulative_admitted,type="s",lwd=2,col="grey45",ylim=c(0,max(counts$cumulative_admitted)+1),xlab="Month",ylab="Number of individually tracked brands",main=paste("Top-five volume admission, permanent tracking:",scope))
 lines(as.Date(counts$month),counts$retained_last_sale_proxy,type="s",col="steelblue",lwd=2)
 abline(h=5,lty=2);legend("topleft",c("Never remove admitted brands","Remove after last observed positive-volume sale (proxy)","Five-brand reference"),col=c("grey45","steelblue","black"),lty=c(1,1,2),lwd=c(2,2,1),cex=.8,bty="n")
 print(summary);print(annual);print(admits)
}
dev.off()
fwrite(rbindlist(summaries),file.path(out,"summary.csv"))
stopifnot(identical(unname(hashes),unname(tools::md5sum(files))))
fwrite(data.table(path=files,md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Monthly top-five ranks use national liquid-volume mL; exact ties resolved alphabetically (ties reported).",
"Main universe matches demand filters: identified brands, positive units and mL, UPC-month coverage >=3 stores. No 7% filter applied to rank brands.",
"Sensitivity ranks all identified positive-volume UPC sales regardless of store breadth.",
"Begin January 2013 with five top-volume brands; admit a brand on first subsequent top-five appearance. Falling in rank never removes it.",
"Report (1) all admitted brands retained forever and (2) retained through last observed positive mL sales in full positive-sales universe, allowing temporary zero/filtered-sales gaps.",
"Last observed sales are not verified shutdown; retail coverage, inventory run-off and sample end censoring affect interpretation. No acquisition/consolidation treatment applied.",
"Units here are brands, consistent with demand, not ultimate parent firms. Current data end December 2023.",
"Descriptive count only: no cap, promotion model, fringe decomposition, demand refit or meeting-note changes made.",
"Validation passed: eligible market volumes reconcile with demand totals, roster inequalities, monotonic cumulative admissions and unchanged source hashes."),file.path(out,"README.txt"))
