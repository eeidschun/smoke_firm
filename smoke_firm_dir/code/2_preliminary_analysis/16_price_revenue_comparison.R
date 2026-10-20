## Advisor request: revenue discrepancy and separate liquid-volume-weighted price.
## Read existing corrected panels; do not rebuild or overwrite canonical inputs.
suppressPackageStartupMessages(library(data.table))
source("smoke_firm_dir/code/fxns/1_paths.R")
paths <- file.path(SUPPORT_DIR,c("upc_month_niccorr_from_full.RData",
  "upc_month_store_breadth.rds","demand_panel_firm_month.RData",
  "product_characteristics_firm_month.rds"))
hashes <- tools::md5sum(paths)
e <- new.env();load(paths[1],envir=e)
u <- as.data.table(e$upc_month_t2)
u[,brand:=trimws(brand)]
u <- u[brand!="UNKNOWN" & units_sum>0 & mL_sum>0,
  .(volume_mL=sum(mL_sum),revenue_real=sum(revenue_real)),by=.(month,brand,upc12)]
breadth <- as.data.table(readRDS(paths[2]))
stopifnot(!anyDuplicated(breadth[,.(month,upc12)]))
u <- merge(u,breadth[,.(month,upc12,n_stores)],by=c("month","upc12"))
u <- u[n_stores>=3];u[,price:=revenue_real/volume_mL]
bm <- u[,.(mL=sum(volume_mL),revenue_real=sum(revenue_real),n_upcs=.N,
  p_it=mean(price),p_it_volume_weighted=weighted.mean(price,volume_mL)),by=.(brand,month)]
load(paths[3],envir=e);d <- as.data.table(e$demand_im)
check <- merge(d[,.(brand,month,mL_old=mL,revenue_old=revenue_real,price_old=p_it)],bm,by=c("brand","month"))
stopifnot(nrow(check)==540L,max(abs(check$p_it-check$price_old))<1e-8,
  max(abs(check$mL/check$mL_old-1))<1e-10,
  max(abs(check$revenue_real/check$revenue_old-1))<1e-10)
bm[,incumbent:=FALSE];bm[d,on=.(brand,month),incumbent:=TRUE]
sizes <- as.data.table(readRDS(paths[4]))
bm[,matched_sample:=FALSE]
bm[sizes[is.finite(avg_ml_per_ecig)],on=.(brand,month),matched_sample:=TRUE]
bm[,matched_sample:=matched_sample & incumbent]
stopifnot(sum(bm$matched_sample)==528L)
bm[,`:=`(year=as.integer(format(month,"%Y")),
  implied_revenue=p_it*mL,weighted_implied_revenue=p_it_volume_weighted*mL)]
bm[,`:=`(revenue_gap=implied_revenue-revenue_real,
  relative_gap_pct=100*(implied_revenue/revenue_real-1),
  price_ratio=p_it/p_it_volume_weighted)]
stopifnot(max(abs(bm$weighted_implied_revenue/bm$revenue_real-1))<1e-10)
summarize <- function(x) {
  r <- x$relative_gap_pct
  data.table(n=nrow(x),observed_revenue=sum(x$revenue_real),implied_revenue=sum(x$implied_revenue),
    net_gap=sum(x$revenue_gap),net_gap_pct=100*sum(x$revenue_gap)/sum(x$revenue_real),
    absolute_gap=sum(abs(x$revenue_gap)),absolute_gap_pct=100*sum(abs(x$revenue_gap))/sum(x$revenue_real),
    median_gap_pct=median(r),mean_gap_pct=mean(r),median_absolute_gap_pct=median(abs(r)),
    min_gap_pct=min(r),p25_gap_pct=quantile(r,.25),p75_gap_pct=quantile(r,.75),max_gap_pct=max(r),
    n_over=sum(r>1e-8),n_under=sum(r< -1e-8),
    pct_within_10=100*mean(abs(r)<=10),pct_within_25=100*mean(abs(r)<=25))
}
samples <- list(Incumbents=bm[incumbent==TRUE],Matched=bm[matched_sample==TRUE],All_eligible_brands=bm)
summary <- rbindlist(lapply(names(samples),function(nm)cbind(sample=nm,summarize(samples[[nm]]))))
byfirm <- bm[incumbent==TRUE,summarize(.SD),by=brand]
byyear <- bm[incumbent==TRUE,summarize(.SD),by=year]
out <- file.path(PRELIM_DIR,"price_revenue_comparison")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
fwrite(bm,file.path(out,"brand_month_prices_and_revenue.csv"))
saveRDS(bm,file.path(SUPPORT_DIR,"price_measures_firm_month.rds"))
fwrite(summary,file.path(out,"summary.csv"));fwrite(byfirm,file.path(out,"by_firm.csv"))
fwrite(byyear,file.path(out,"by_year.csv"))
fwrite(bm[incumbent==TRUE][order(-abs(relative_gap_pct))][1:20],file.path(out,"largest_relative_gaps.csv"))
fwrite(bm[incumbent==TRUE][order(-abs(revenue_gap))][1:20],file.path(out,"largest_dollar_gaps.csv"))
stopifnot(identical(hashes,tools::md5sum(paths)))
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,"input_hashes.csv"))
lines <- c("# Representative price and observed revenue: 2026-10-20","",
 "All prices and revenue use the existing real-dollar series. Eligible brand-UPC-months retain the current filters and corrected liquid volumes. T2 rows collapse before computing UPC price. Incumbency uses the saved annual roster; all eligible brands includes fringe brands individually.","",
 "The existing price p_it is the equal-UPC mean of R_u/Q_u. The separate sales-weighted price p_it_volume_weighted uses e-liquid mL weights: sum_u[(Q_u/sum Q_u)*(R_u/Q_u)] = sum R_u/sum Q_u. Thus its product with firm volume reproduces observed eligible retail revenue, up to floating-point rounding. This is a volume-weighted unit value, not a revenue-weighted mean or a fixed-product price index.","",
 "Signed percentage gap = 100*(p_it*Q/R - 1). Positive means overstatement. Aggregate net gap uses sums of revenues; absolute gap sums absolute firm-month dollar gaps before dividing by observed revenue. These differ because overstatements and understatements can cancel. Median/quantiles give each brand-month equal weight.","",
 "| Sample | N | Aggregate net gap % | Aggregate absolute gap % | Median signed gap % | Median absolute gap % | Min signed % | Max signed % |",
 "|---|---:|---:|---:|---:|---:|---:|---:|")
for(i in seq_len(nrow(summary))) {s<-summary[i];lines<-c(lines,sprintf("| %s | %d | %.2f | %.2f | %.2f | %.2f | %.2f | %.2f |",s$sample,s$n,s$net_gap_pct,s$absolute_gap_pct,s$median_gap_pct,s$median_absolute_gap_pct,s$min_gap_pct,s$max_gap_pct))}
lines <- c(lines,"","## Incumbent breakdown by firm","",
 "| Firm | Months | Net gap % | Absolute gap % | Median signed gap % |",
 "|---|---:|---:|---:|---:|")
for(i in seq_len(nrow(byfirm))) {s<-byfirm[i];lines<-c(lines,sprintf("| %s | %d | %.2f | %.2f | %.2f |",s$brand,s$n,s$net_gap_pct,s$absolute_gap_pct,s$median_gap_pct))}
lines <- c(lines,"",
 "The sidecar input/price_measures_firm_month.rds and detailed CSV retain both prices, volumes, observed/implied revenue, gaps, and sample indicators for every eligible brand-month. by_year.csv and the two largest-gap tables provide further detail. The canonical demand builder now includes the additional price column on future runs; it was not run for this analysis. Existing price, demand estimates, canonical panels and NCP inputs were not replaced. No new demand specification is selected.","",
 "Validation: reconstructed UPC-unweighted prices, volumes and revenues match all 540 saved incumbent rows; matched membership is 528 rows; weighted-price revenue identity holds for all eligible brand-months. Source hashes remained unchanged.","",
 "Reproduce: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/16_price_revenue_comparison.R`.")
writeLines(lines,file.path(out,"README.md"));print(summary);print(byfirm)

