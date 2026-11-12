source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
files<-c(file.path(OUT_DIR,"dynamic_entry_exit/top5_admission_roster_2026-11-04/all_positive_sales_monthly_volume_ranks.csv"),file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27/incumbent_recovery.csv"))
hashes<-tools::md5sum(files)
sales<-fread(files[1]);inc<-fread(files[2])
sales[,month_id:=as.integer(format(as.Date(month),"%Y"))*12L+as.integer(format(as.Date(month),"%m"))]
setorder(sales,brand,month_id)
first_sample<-min(sales$month);last_sample<-max(sales$month)
roster<-inc[,.(first_incumbent=min(month),last_incumbent=max(month),incumbent_months=.N),by=brand]
d<-merge(sales,roster,by="brand");setorder(d,brand,month_id)
d[,gap_months:=month_id-shift(month_id)-1L,by=brand]
s<-d[,{
 peak<-max(mL);lastinc<-first(last_incumbent)
 list(first_observed_sales=first(month),last_observed_sales=last(month),sales_months=.N,left_censored=first(month)==first_sample,right_censored=last(month)==last_sample,first_incumbent=first(first_incumbent),last_incumbent=lastinc,incumbent_months=first(incumbent_months),months_selling_before_incumbency=sum(month<first(first_incumbent)),months_selling_after_incumbency=sum(month>lastinc),internal_missing_months=sum(pmax(gap_months,0),na.rm=TRUE),peak_monthly_mL=peak,last_month_mL=last(mL),last_mL_fraction_of_peak=last(mL)/peak,post_incumbency_mL=sum(mL[month>lastinc]))
},by=brand][order(first_incumbent,brand)]
s[,entry_evidence:=fifelse(left_censored,"Already observed at sample start; birth unknown","First observed scanner sales only; verify commercial launch")]
s[,exit_evidence:=fifelse(right_censored,"Sales at sample end; shutdown not observed","Sales disappear before sample end; verify cessation vs coverage/run-off")]
out<-file.path(OUT_DIR,"dynamic_entry_exit/entry_exit_candidates_2026-11-04");dir.create(out,recursive=TRUE,showWarnings=FALSE)
fwrite(s,file.path(out,"incumbent_brand_lifecycles.csv"))
fwrite(d,file.path(out,"brand_month_sales_histories.csv"))
annual<-d[,.(annual_mL=sum(mL),positive_sales_months=.N),by=.(brand,year=as.integer(format(as.Date(month),"%Y")))]
fwrite(annual,file.path(out,"annual_sales_by_brand.csv"))
fwrite(d[gap_months>0,.(brand,next_observed_month=month,missing_months=gap_months)],file.path(out,"sales_gaps.csv"))
stopifnot(nrow(s)==9L,!anyDuplicated(d[,.(brand,month)]),all(s$incumbent_months<=s$sales_months),identical(unname(hashes),unname(tools::md5sum(files))))
fwrite(data.table(path=files,md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Candidate events only; no economic entry/exit event is assigned or verified.","All identified positive-volume sales regardless of store breadth; only nine brands ever in >7% annual demand roster are summarized.","First/last scanner sales may reflect coverage, launch, inventory run-off or brand transitions. Sample endpoints are censoring, not events.","No parent-company merger/acquisition consolidation or external verification performed. Sales ranks are not used as entry/exit events.","Underlying source rankings were built by script 10 from canonical UPC-month data; no canonical data altered.","All nine lifecycles reconcile; no duplicate brand-months; source hashes unchanged."),file.path(out,"README.txt"))
print(s[,.(brand,first_observed_sales,first_incumbent,last_incumbent,last_observed_sales,months_selling_before_incumbency,months_selling_after_incumbency,internal_missing_months)])
