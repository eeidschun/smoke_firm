source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
library(data.table)
out<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06")
x<-readRDS(file.path(out,"static_payoff_cache.rds"));g<-build_dynamic_geometry(x$P,x$G)
codes<-g$states;codes[codes>9]<-0
id<-as.integer(1+as.vector(codes%*%(10^(0:4))))
profits<-x$profits[id,,drop=FALSE]
V0<-ifelse(g$active|g$eligible,-1e6,0);p0<-ifelse(g$active|g$eligible,.5,0)
t0<-proc.time()[3]
sol<-manual_dynamic_solve(profits,g,.95^(1/12),1e5,1e8,5e6,entry_waiting=TRUE,V0=V0,policy0=p0,damping=1,max_iter=4000L,checkpoint=file.path(out,"alternative_checkpoint.rds"),progress_every=50L)
sol$elapsed_seconds<-proc.time()[3]-t0
saveRDS(sol,file.path(out,"alternative_start_solution.rds"))
fwrite(as.data.table(sol$trace),file.path(out,"alternative_iteration_trace.csv"))
cat('Alternative start converged:',sol$converged,'iterations:',sol$iterations,'elapsed:',sol$elapsed_seconds,'\n')
