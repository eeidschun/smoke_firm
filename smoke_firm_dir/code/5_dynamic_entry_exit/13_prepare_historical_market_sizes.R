source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input<-file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27/fringe_market_recovery.csv")
hash<-tools::md5sum(input)
d<-fread(input)[,.(month,M)];setorder(d,month)
d[,year:=as.integer(format(as.Date(month),"%Y"))]
stopifnot(nrow(d)==132L,!anyDuplicated(d$month),all(is.finite(d$M)),all(d$M>0))
a<-d[,.(M=first(M),months=.N,distinct_M=uniqueN(M)),by=year]
stopifnot(nrow(a)==11L,all(a$months==12L),all(a$distinct_M==1L))
d[,market_size_id:=match(M,unique(M))]
out<-file.path(OUT_DIR,"dynamic_entry_exit/historical_market_sizes_2026-11-04");dir.create(out,recursive=TRUE,showWarnings=FALSE)
fwrite(d,file.path(out,"monthly_market_size_path.csv"));fwrite(a,file.path(out,"annual_market_sizes.csv"))
saveRDS(list(monthly_path=d,annual_market_sizes=a,expectation="At each date firms expect current observed M to remain fixed forever; historical changes treated as unanticipated revisions.",solution_rule="Solve stationary equilibrium conditional on each distinct M and common trial payoff parameters; evaluate date-specific policies along observed M path."),file.path(out,"historical_market_size_inputs.rds"))
stopifnot(identical(unname(hash),unname(tools::md5sum(input))))
fwrite(data.table(path=input,md5=unname(hash)),file.path(out,"input_hash.csv"))
writeLines(c("Selected historical fitting design: January 2013 initialization, 132 observed monthly M values in 2013-2023.","M matches selected demand definition; constant within year. Eleven distinct annual values.","Firms perceive current M as permanent; realized year changes are unanticipated belief revisions, not a correctly anticipated stochastic process or perfect foresight.","Requires stationary policy/value solutions conditional on M for every trial payoff vector; cache keys must include parameters and all changing model inputs.","Only market-size inputs prepared. No dynamic equilibrium solved; no payoff parameters estimated. Prior December-only benchmark preserved.","Checks passed: unique months, 12 months/year, positive finite M, within-year constancy and unchanged source hash."),file.path(out,"README.txt"))
print(a)
