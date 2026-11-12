source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
library(data.table)
out<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06")
x<-readRDS(file.path(out,"static_payoff_cache.rds"))
g<-build_dynamic_geometry(x$P,x$G)
st<-g$states;codes<-st;codes[codes>9]<-0
static_id<-as.integer(1+as.vector(codes%*%(10^(0:4))))
profits<-x$profits[static_id,,drop=FALSE]
stopifnot(nrow(profits)==121000L)
settings<-list(beta=.95^(1/12),FC=1e5,mu_E=1e8,sigma_S=5e6,entry_waiting=TRUE)
# A fresh zero-value start; no automatic reuse of potentially stale checkpoints.
V0<-NULL;p0<-NULL
t0<-proc.time()[3]
sol<-do.call(manual_dynamic_solve,c(list(profits=profits,geometry=g,V0=V0,policy0=p0,damping=.7,max_iter=4000L,value_tol=1e-6,policy_tol=1e-7,checkpoint=file.path(out,"iteration_checkpoint.rds"),progress_every=25L),settings))
sol$elapsed_seconds<-proc.time()[3]-t0;sol$brands<-x$brands;sol$state_dimensions<-g$dims
saveRDS(sol,file.path(out,"dynamic_trial_solution.rds"))
fwrite(as.data.table(sol$trace),file.path(out,"iteration_trace.csv"))
# Lookup selected initial state from prepared fixed-focal January benchmark.
y<-readRDS(file.path(OUT_DIR,"dynamic_entry_exit/january_fringe_benchmark_2026-11-06/fixed_focal_supply_inputs.rds"))
initial<-y$initial_roster[match(x$brands[1:3],brand)]
state0<-c(initial$quality_state+3L*(initial$xi_state-1L),0,0)
idx<-which(rowSums(abs(sweep(st,2,state0,'-')))==0)
stopifnot(length(idx)==1L)
report<-data.table(brand=x$brands,state=state0,variable_profit=profits[idx,],value_before_draw=sol$V[idx,],continue_or_enter_probability=sol$policy[idx,],discounted_continuation=sol$last_best_response$continuation[idx,],entry_value=sol$last_best_response$entry_value[idx,],waiting_value=sol$last_best_response$waiting_value[idx,])
report[,entry_net_advantage:=entry_value-waiting_value]
fwrite(report,file.path(out,"initial_state_results.csv"))
writeLines(c(paste('Converged:',sol$converged),paste('Iterations:',sol$iterations),paste('Elapsed seconds:',sol$elapsed_seconds),'Trial parameters only, not estimates. Monthly beta=.95^(1/12); FC=$100k, mean entry cost=$100m, scrap SD=$5m, scrap mean zero.','Five fixed identities: BLU/MISTIC/NJOY initially active, JUUL/VUSE eligible. Independent quality transitions and private payoff draws.','Continuing named candidates retain the option to enter later: entry threshold = entry value minus discounted waiting value. This corrects the zero-outside-option anonymous-entry comparison for persistent identities.','No re-entry after shutdown. All inactive candidate statuses retained in state; no cap rationing necessary for five fixed identities.','This is 2013 stationary market size and January fringe only, not a simulated 2013-2023 fit.','Joint policy/value fixed point is not guaranteed to be a contraction; failure is reported. No global uniqueness claim.'),file.path(out,"trial_status.txt"))
print(report,digits=6);cat('Converged:',sol$converged,'iterations:',sol$iterations,'seconds:',sol$elapsed_seconds,'\n')
