source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
library(data.table)
out<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06")
x<-readRDS(file.path(out,"static_payoff_cache.rds"));sol<-readRDS(file.path(out,"dynamic_trial_solution.rds"))
g<-build_dynamic_geometry(x$P,x$G);s<-g$states;codes<-s;codes[codes>9]<-0
id<-as.integer(1+as.vector(codes%*%(10^(0:4))))
profits<-x$profits[id,,drop=FALSE]
b<-do.call(dynamic_best_response,c(list(V=sol$V,policy=sol$policy,profits=profits,geometry=g),sol$parameters))
vr<-max(abs(b$V-sol$V)/pmax(1,abs(b$V),abs(sol$V)))
pr<-max(abs(b$policy-sol$policy))
stopifnot(sol$converged,vr<sol$tolerances$value_tol,pr<sol$tolerances$policy_tol,all(sol$policy>=0),all(sol$policy<=1))
# Independent explicit next-state probabilities at selected states, with rivals' current policies.
initial<-fread(file.path(out,"initial_state_results.csv"))$state
ids<-unique(c(which(rowSums(abs(sweep(s,2,initial,'-')))==0),1L,nrow(s)))
errors<-list()
for(r in ids)for(i in 1:5) {
 if(!g$active[r,i] && !g$eligible[r,i])next
 for(action in 0:1) {
  joint<-rep(1,nrow(s))
  for(k in 1:5) {
   st<-s[r,k];prob<-numeric(g$dims[k]);pk<-if(k==i)action else sol$policy[r,k]
   if(g$active[r,k]) {
    prob[2:10]<-pk*x$P[st,]
    prob[if(k<=3)1 else 11]<-1-pk
   } else if(g$eligible[r,k]) {
    prob[1]<-1-pk;prob[2:10]<-pk*x$G
   } else prob[st+1]<-1
   joint<-joint*prob[s[,k]+1]
  }
  stopifnot(abs(sum(joint)-1)<1e-12)
  explicit<-sol$parameters$beta*sum(joint*sol$V[,i])
  reference<-if(action)if(g$active[r,i])b$continuation[r,i] else b$entry_value[r,i] else if(g$eligible[r,i])b$waiting_value[r,i] else 0
  er<-abs(explicit-reference)/max(1,abs(explicit),abs(reference))
  stopifnot(er<1e-12)
  errors[[paste(r,i,action)]]<-data.table(state_row=r,firm=x$brands[i],own_action=action,relative_error=er)
 }
}
fwrite(rbindlist(errors),file.path(out,"explicit_transition_audit.csv"))
fwrite(data.table(check=c("scaled_Bellman_residual","policy_residual","max_explicit_transition_error","active_firm_count_max"),value=c(vr,pr,max(rbindlist(errors)$relative_error),max(rowSums(g$active)))),file.path(out,"dynamic_validation.csv"))
pdf(file.path(out,"dynamic_convergence.pdf"),width=9,height=6)
matplot(sol$trace[,1],pmax(sol$trace[,2:3],1e-16),type="l",log="y",lty=1:2,col=c("steelblue","firebrick"),xlab="Manual joint value/policy iteration",ylab="Residual",main="2013 dynamic trial: convergence diagnostics")
legend("topright",c("Scaled Bellman residual","Policy probability residual"),col=c("steelblue","firebrick"),lty=1:2,bty="n")
dev.off()
cat('All-state Bellman/policy checks and selected explicit transition enumeration passed.\n')
