source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input<-file.path(OUT_DIR,"dynamic_entry_exit/entry_exit_candidates_2026-11-04/incumbent_brand_lifecycles.csv")
hash<-tools::md5sum(input);d<-fread(input)
# Candidate sample is nine brands ever in demand's incumbent roster, not all industry births.
start<-as.Date("2013-01-01");end<-as.Date("2023-12-01")
months<-seq(start,end,by="month")
initial<-d[first_incumbent==start,brand]
entries<-d[first_observed_sales>start,.(brand,activation_month=as.Date(first_observed_sales))]
entries[,decision_month:=as.Date(format(activation_month-1,"%Y-%m-01"))]
exits<-d[last_observed_sales<end,.(brand,last_sales=as.Date(last_observed_sales))]
exits[,first_inactive_month:=as.Date(format(last_sales+32,"%Y-%m-01"))]
# +32 days from month start always lands in the next month for these dates.
stopifnot(all(format(exits$first_inactive_month,"%Y-%m")!=format(exits$last_sales,"%Y-%m")))
# Unrestricted candidate history preserves every candidate birth to expose contradictions;
# capped replay follows only allowed births and does not queue blocked entrants automatically.
active_unrestricted<-initial;active_capped<-initial;rows<-list();events<-list()
for(m in seq_along(months)) {
 t<-months[m]
 birth_decisions<-entries[decision_month==t]
 shut<-exits[last_sales==t,brand]
 n0<-length(active_unrestricted);nc<-length(active_capped)
 if(nrow(birth_decisions)>0) {
   for(j in seq_len(nrow(birth_decisions))) events[[paste(m,j)]]<-data.table(brand=birth_decisions$brand[j],decision_month=t,activation_month=birth_decisions$activation_month[j],unrestricted_start_count=n0,capped_start_count=nc,eligible_unrestricted=n0<5L,eligible_capped=nc<5L,one_entrant_limit_ok=nrow(birth_decisions)<=1L)
 }
 allowed<-if(nc<5L && nrow(birth_decisions)==1L) birth_decisions$brand else character()
 rows[[m]]<-data.table(month=t,unrestricted_start_count=n0,capped_start_count=nc,unrestricted_roster=paste(sort(active_unrestricted),collapse="; "),capped_roster=paste(sort(active_capped),collapse="; "),entry_decisions=paste(birth_decisions$brand,collapse="; "),shutdown_decisions=paste(intersect(shut,active_unrestricted),collapse="; "),admitted_for_next_month=paste(allowed,collapse="; "))
 active_unrestricted<-union(setdiff(active_unrestricted,shut),birth_decisions$brand)
 active_capped<-union(setdiff(active_capped,shut),allowed)
 stopifnot(length(active_capped)<=5L)
}
a<-rbindlist(rows);ev<-rbindlist(events)
# Independent direct construction verifies starting roster for unrestricted history.
for(j in seq_len(nrow(a))) {
 t<-a$month[j]
 expected<-d[(brand %in% initial | first_observed_sales>start) & first_observed_sales<=t & last_observed_sales>=t,.N]
 stopifnot(a$unrestricted_start_count[j]==expected)
}
out<-file.path(OUT_DIR,"dynamic_entry_exit/event_cap_check_2026-11-04");dir.create(out,recursive=TRUE,showWarnings=FALSE)
fwrite(a,file.path(out,"monthly_roster_replay.csv"));fwrite(ev,file.path(out,"entry_capacity_checks.csv"));fwrite(exits,file.path(out,"candidate_shutdowns.csv"))
fwrite(d[first_observed_sales==start & !(brand %in% initial),.(brand,first_incumbent,reason="Already selling in initial fringe; later incumbency is not industry entry")],file.path(out,"excluded_fringe_promotions.csv"))
stopifnot(identical(unname(hash),unname(tools::md5sum(input))))
writeLines(c("Event-cap diagnostic only; no structural estimation sample selected, no event dates externally verified.","Restrict candidates to nine brands ever incumbent (>7%); initial firms are January 2013 demand roster. Does not count every birth in the scanner fringe.","First positive-sales month is activation; decision is preceding month. Last positive-sales month is exit decision; next month first inactive. Assumes no inventory run-off for this proxy.","Full candidate history is replayed without cap to expose conflicts. Separate capped replay blocks ineligible births; blocked candidates are not silently delayed or queued.","LOGIC and MISTIC are initial fringe survivors, not genuine post-start births.","At most one entry decision per month checked; same-month shutdown does not create current eligibility.","Checks passed: capped count <=5, independent unrestricted count reconciliation, unchanged source hash."),file.path(out,"README.txt"))
print(ev);print(exits);print(a[,.(max_unrestricted=max(unrestricted_start_count),max_capped=max(capped_start_count),months_over_cap=sum(unrestricted_start_count>5))])
