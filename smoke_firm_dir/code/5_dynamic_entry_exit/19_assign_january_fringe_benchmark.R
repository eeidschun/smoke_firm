source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
root<-file.path(OUT_DIR,"dynamic_entry_exit")
input<-file.path(root,"fixed_focal_supply_2026-11-05/fixed_focal_supply_inputs.rds")
hash<-tools::md5sum(input);x<-readRDS(input)
initial_month<-min(x$markets$month)
value<-x$markets[month==initial_month,delta_F]
stopifnot(length(value)==1L,is.finite(value),format(initial_month,"%Y-%m")=="2013-01")
old_value<-x$delta_F_constant
x$delta_F_constant<-value
x$fringe_benchmark<-list(method="January 2013 calibrated total fringe utility held fixed",month=initial_month,previous_median=old_value)
out<-file.path(root,"january_fringe_benchmark_2026-11-06");dir.create(out,recursive=TRUE,showWarnings=FALSE)
saveRDS(x,file.path(out,"fixed_focal_supply_inputs.rds"))
fwrite(data.table(benchmark_month=initial_month,delta_F_constant=value,full_period_median=old_value),file.path(out,"constant_fringe_utility.csv"))
stopifnot(identical(unname(hash),unname(tools::md5sum(input))))
fwrite(data.table(path=input,md5=unname(hash)),file.path(out,"input_hash.csv"))
writeLines(c("Selected first-solver benchmark: January 2013 fixed-focal fringe utility held constant across states and time.","Supersedes full-period median for baseline; original median inputs preserved separately.","Fixed within pricing was a passive-fringe assumption; constancy across months is an additional simplification.","Share remains responsive to focal competition. No claim that early fringe remains representative through 2023.","All other input fields unchanged; no demand re-estimation or dynamic solve. Finite unique January utility and original hash checked."),file.path(out,"README.txt"))
print(data.table(january=value,previous_median=old_value),digits=12)
