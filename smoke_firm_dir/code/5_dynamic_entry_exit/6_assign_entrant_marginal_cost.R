source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input <- file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27/incumbent_recovery.csv")
out <- file.path(OUT_DIR,"dynamic_entry_exit/constant_marginal_costs_2026-11-03")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
hash <- tools::md5sum(input)
d <- fread(input)
d[,month_id:=as.integer(format(as.Date(month),"%Y"))*12L+as.integer(format(as.Date(month),"%m"))]
stopifnot(!anyDuplicated(d[,.(brand,month_id)]),all(is.finite(d$mc)),all(is.finite(d$q)),all(d$q>0))
firsts <- d[,.(first_id=min(month_id),first_month=min(month)),by=brand]
firsts[,eligible:=first_id>min(d$month_id)]
z <- merge(d,firsts[eligible==TRUE],by="brand")
z <- z[month_id>=first_id & month_id<first_id+12L]
# First twelve calendar months after the first observed incumbent month,
# not the first twelve records across arbitrary gaps.
s <- z[,.(first_incumbent_month=first(first_month),months=.N,liquid_volume_mL=sum(q),weighted_mc=sum(q*mc)/sum(q)),by=brand][order(brand)]
stopifnot(nrow(s)>0,all(s$months==12L))
value <- sum(z$q*z$mc)/sum(z$q)
s[,volume_weight:=liquid_volume_mL/sum(liquid_volume_mL)]
stopifnot(abs(sum(s$volume_weight)-1)<1e-12,abs(sum(s$volume_weight*s$weighted_mc)-value)<1e-12)
fwrite(s,file.path(out,"entrant_calibration_by_firm.csv"))
fwrite(z[,.(brand,month,q,mc)],file.path(out,"entrant_calibration_observations.csv"))
fwrite(data.table(entrant_mc=value,qualifying_firms=nrow(s),observations=nrow(z),total_volume_mL=sum(z$q)),file.path(out,"entrant_constant_marginal_cost.csv"))
saveRDS(list(entrant_mc=value,qualifying_firms=s,definition="Pooled liquid-volume-weighted mean MC over first twelve calendar incumbent months; first incumbent observation strictly after sample start."),file.path(out,"entrant_cost_inputs.rds"))
stopifnot(identical(unname(hash),unname(tools::md5sum(input))))
writeLines(c("Entrant MC is fixed across time and entrant initial quality states.","Liquid-volume weighting (mL), not revenue weights; larger qualifying firms receive more influence.","First observed incumbent month is a roster classification, not verified economic entry. Sample-start incumbents excluded.","Calibrated from successful expansions and maintained demand/Bertrand assumptions, not an upper bound or identification of potential-entrant technology.","Existing incumbent median constants remain unchanged; this is a separate entrant calibration.","Checks passed: unique source firm-months, complete twelve-month windows, weight sums and weighted-mean reconciliation, unchanged source hash."),file.path(out,"entrant_calibration_README.txt"))
print(s);print(value)
