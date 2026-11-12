source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
root<-file.path(OUT_DIR,"dynamic_entry_exit")
files<-c(file.path(root,"top5_admission_roster_2026-11-04/all_positive_sales_monthly_volume_ranks.csv"),file.path(root,"entry_exit_candidates_2026-11-04/incumbent_brand_lifecycles.csv"))
hashes<-tools::md5sum(files);sales<-fread(files[1]);life<-fread(files[2])
months<-seq(as.Date("2013-01-01"),as.Date("2023-12-01"),by="month")
initial<-life[first_incumbent==min(months),brand]
entries<-life[first_observed_sales>min(months),.(brand,activation_month=as.Date(first_observed_sales))]
entries[,decision_month:=as.Date(format(activation_month-1,"%Y-%m-01"))]
panel<-merge(CJ(month=months,brand=life$brand),sales[,.(month,brand,mL)],by=c("month","brand"),all.x=TRUE)
panel[is.na(mL),mL:=0]
panel<-merge(panel,life[,.(brand,first_observed_sales)],by="brand")
panel[,calendar_index:=match(month,months)]
setorder(panel,brand,month)
results<-list();events<-list();summaries<-list()
for(method in c("last_above","three_low")) for(floor in c(0,100,1000,5000,10000,25000,50000,100000)) {
  id<-paste(method,floor,sep="_")
  ex<-panel[,{
    relevant<-which(month>=first(first_observed_sales))
    low<-mL<=floor
    if(method=="last_above") {
      above<-relevant[mL[relevant]>floor]
      inactive<-if(length(above)) max(above)+1L else min(relevant)
      decision<-inactive-1L
    } else {
      hit<-relevant[relevant>=3L & low[relevant] & shift(low,1L,fill=FALSE)[relevant] & shift(low,2L,fill=FALSE)[relevant]]
      # A decision requires three low months since actual first sales.
      hit<-hit[hit>=min(relevant)+2L]
      decision<-if(length(hit)) min(hit) else length(months)+1L
      inactive<-decision+1L
    }
    list(first_inactive=if(inactive<=length(months)) months[inactive] else as.Date(NA),decision_month_exit=if(decision>=1 && decision<=length(months)) months[decision] else as.Date(NA),later_above_floor_months=if(inactive<=length(months))sum(mL[seq.int(inactive,length(months))]>floor) else 0L)
  },by=brand]
  ex[,`:=`(rule=id,method=method,floor_mL=floor)]
  results[[id]]<-ex
  for(j in seq_len(nrow(entries))) {
    ent<-entries[j];t<-ent$decision_month
    # Candidate unrestricted history; do not silently discard previous blocked births.
    admitted<-union(initial,entries[activation_month<=t,brand])
    live<-ex[brand %in% admitted & (is.na(first_inactive)|first_inactive>t),brand]
    drop<-setdiff(admitted,live)
    events[[paste(id,j)]]<-data.table(rule=id,method=method,floor_mL=floor,entrant=ent$brand,decision_month=t,activation_month=ent$activation_month,active_start=length(live),entry_eligible=length(live)<5L,already_exited=paste(sort(drop),collapse="; "))
  }
}
exits<-rbindlist(results);checks<-rbindlist(events)
out<-file.path(root,"low_sales_exit_sensitivity_2026-11-04");dir.create(out,recursive=TRUE,showWarnings=FALSE)
fwrite(checks,file.path(out,"candidate_entry_capacity.csv"));fwrite(exits,file.path(out,"candidate_exit_dates.csv"))
pre<-panel[brand %in% initial & month<as.Date("2015-10-01"),.(min_monthly_mL=min(mL),first_mL=first(mL),last_mL=last(mL)),by=brand]
fwrite(pre,file.path(out,"initial_firms_pre_juul_sales.csv"))
stopifnot(nrow(checks)==48L,identical(unname(hashes),unname(tools::md5sum(files))))
# Zero terminal rule must reproduce previous cap diagnostic.
old<-fread(file.path(root,"event_cap_check_2026-11-04/entry_capacity_checks.csv"))
stopifnot(identical(checks[rule=="last_above_0"]$active_start,old$unrestricted_start_count[match(checks[rule=="last_above_0"]$entrant,old$brand)]))
writeLines(c("Sensitivity exercise only; no selected exit definition or dynamic model inputs replaced.","Positive/zero scanner sales universe; monthly volume in mL. Thresholds illustrative, not economically justified shutdown cutoffs.","last_above: inactive beginning month after final sales strictly above cutoff. Uses full future sample and keeps temporary dips active.","three_low: exit decision at end of first three consecutive months at or below cutoff after first sales; inactive next month. Report subsequent rebounds above cutoff.","Initial four demand incumbents and actual first-sales candidate entries unchanged. Unrestricted past candidate births retained to reveal capacity conflicts.","Eligibility is based on count at decision month start, not operating start month. Same-month exits do not free current entry eligibility.","Post-threshold exit means modeled economic inactivity despite positive observed sales; remaining sales and fringe treatment require separate interpretation.","Zero terminal baseline reconciles with prior audit. Source hashes unchanged."),file.path(out,"README.txt"))
print(checks[method=="last_above",.(floor_mL,entrant,active_start,already_exited)])
print(checks[method=="three_low" & entrant=="JUUL",.(floor_mL,active_start,already_exited)])
print(pre)
