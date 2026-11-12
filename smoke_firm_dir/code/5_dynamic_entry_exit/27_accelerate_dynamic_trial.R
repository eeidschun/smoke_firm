source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
library(data.table)
out<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06")
x<-readRDS(file.path(out,"static_payoff_cache.rds"));g<-build_dynamic_geometry(x$P,x$G)
codes<-g$states;codes[codes>9]<-0
id<-as.integer(1+as.vector(codes%*%(10^(0:4))))
profits<-x$profits[id,,drop=FALSE]
args<-commandArgs(trailingOnly=TRUE);alternative<-"--alternative" %in% args
prefix<-if(alternative)"alternative_" else ""
checkpoint<-if(alternative)"alternative_checkpoint.rds" else "iteration_checkpoint.rds"
old<-readRDS(file.path(out,checkpoint));V<-old$V;p<-old$policy
pars<-list(beta=.95^(1/12),FC=1e5,mu_E=1e8,sigma_S=5e6,entry_waiting=TRUE)
br<-function(V,p)do.call(dynamic_best_response,c(list(V=V,policy=p,profits=profits,geometry=g),pars))
metric<-function(b,V,p)c(value=max(abs(b$V-V)/pmax(1,abs(V),abs(b$V))),policy=max(abs(b$policy-p)))
Fhist<-list();Rhist<-list();trace<-list();accepted<-0L;converged<-FALSE;t0<-proc.time()[3];b<-br(V,p)
for(it in 1:2000L) {
 r<-metric(b,V,p)
 trace[[it]]<-c(iteration=old$iteration+it,scaled_bellman_residual=r[1],policy_residual=r[2],max_value=max(abs(V)))
 if(it%%20==0){cat(prefix,'accelerated iteration',it,':',format(r[1],digits=3),format(r[2],digits=3),'accepted',accepted,'\n');flush.console()}
 if(r[1]<1e-6 && r[2]<1e-7){converged<-TRUE;break}
 Fhist<-tail(c(Fhist,list(b$V)),4);Rhist<-tail(c(Rhist,list(b$V-V)),4)
 Vnext<-.3*V+.7*b$V;pnext<-.3*p+.7*b$policy
 candidate<-NULL
 if(length(Rhist)>=2) {
  R<-do.call(cbind,lapply(Rhist,as.vector));scale<-max(abs(R))
  if(scale>0) {
   Gram<-crossprod(R/scale)
   w<-tryCatch(solve(Gram+diag(1e-10*max(diag(Gram)),nrow(Gram)),rep(1,nrow(Gram))),error=function(e)NULL)
   if(!is.null(w) && abs(sum(w))>1e-12){w<-w/sum(w);if(max(abs(w))<1000)candidate<-Reduce('+',Map(function(F,c)F*c,Fhist,as.list(w)))}
  }
 }
 used<-FALSE
 if(!is.null(candidate) && all(is.finite(candidate))) {
  cb<-br(candidate,pnext);cr<-metric(cb,candidate,pnext)
  if(cr[1]<r[1] && cr[2]<max(10*r[2],1e-3)) {
   V<-candidate;p<-pnext;b<-cb;accepted<-accepted+1L;used<-TRUE
  }
 }
 if(!used){V<-Vnext;p<-pnext;b<-br(V,p)}
}
sol<-list(V=V,policy=p,converged=converged,iterations=old$iteration+it,trace=rbind(old$trace,do.call(rbind,trace)),last_best_response=b,parameters=pars,tolerances=list(value_tol=1e-6,policy_tol=1e-7,value_floor=1,damping=.7),brands=x$brands,state_dimensions=g$dims,acceleration=list(method="Manual depth-four residual-minimizing value extrapolation; policy damped .7; checked residual safeguard",accepted=accepted,warm_start_iteration=old$iteration),elapsed_seconds=proc.time()[3]-t0)
saveRDS(sol,file.path(out,if(alternative)"alternative_accelerated_solution.rds" else "dynamic_trial_solution.rds"))
fwrite(as.data.table(sol$trace),file.path(out,paste0(prefix,"accelerated_iteration_trace.csv")))
y<-readRDS(file.path(OUT_DIR,"dynamic_entry_exit/january_fringe_benchmark_2026-11-06/fixed_focal_supply_inputs.rds"))
initial<-y$initial_roster[match(x$brands[1:3],brand)]
state0<-c(initial$quality_state+3L*(initial$xi_state-1L),0,0)
idx<-which(rowSums(abs(sweep(g$states,2,state0,'-')))==0)
report<-data.table(brand=x$brands,state=state0,variable_profit=profits[idx,],value_before_draw=V[idx,],continue_or_enter_probability=p[idx,],discounted_continuation=b$continuation[idx,],entry_value=b$entry_value[idx,],waiting_value=b$waiting_value[idx,])
report[,entry_net_advantage:=entry_value-waiting_value]
fwrite(report,file.path(out,paste0(prefix,"initial_state_results.csv")))
cat('Converged',converged,'iterations since checkpoint',it,'accepted',accepted,'seconds',sol$elapsed_seconds,'\n');print(report)
