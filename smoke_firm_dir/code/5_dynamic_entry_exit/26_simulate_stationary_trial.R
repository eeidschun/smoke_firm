source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
out<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06")
x<-readRDS(file.path(out,"static_payoff_cache.rds"));sol<-readRDS(file.path(out,"dynamic_trial_solution.rds"))
stopifnot(sol$converged)
initial<-fread(file.path(out,"initial_state_results.csv"))$state
N<-5000L;T<-120L;set.seed(11062026)
s<-matrix(rep(initial,each=N),N,5);payoffs<-matrix(0,N,5)
strides<-c(1,10,100,1000,11000);beta<-sol$parameters$beta
cP<-t(apply(x$P,1,cumsum));cG<-cumsum(x$G)
reports<-list()
for(t in 1:T) {
 id<-as.integer(1+as.vector(s%*%strides))
 static<-s;static[static>9]<-0
 staticid<-as.integer(1+as.vector(static%*%10^(0:4)))
 active<-s>=1 & s<=9
 eligible<-matrix(FALSE,N,5);eligible[,4:5]<-s[,4:5,drop=FALSE]==0
 cont<-matrix(FALSE,N,5);enter<-cont;exit<-cont
 for(i in 1:5) {
  a<-which(active[,i]);u<-which(eligible[,i])
  if(length(a)) {
   scrap<-rnorm(length(a),sd=sol$parameters$sigma_S)
   ex<-scrap>sol$last_best_response$continuation[id[a],i]
   exit[a,i]<-ex;cont[a,i]<-!ex
   payoffs[a,i]<-payoffs[a,i]+beta^(t-1)*(x$profits[staticid[a],i]-sol$parameters$FC+ifelse(ex,scrap,0))
  }
  if(length(u)) {
   cost<-rexp(length(u),rate=1/sol$parameters$mu_E)
   cutoff<-sol$last_best_response$entry_value[id[u],i]-sol$last_best_response$waiting_value[id[u],i]
   en<-cost<=cutoff;enter[u,i]<-en
   payoffs[u,i]<-payoffs[u,i]-beta^(t-1)*ifelse(en,cost,0)
  }
 }
 reports[[t]]<-data.table(month_index=t,mean_active=mean(rowSums(active)),mean_entries=mean(rowSums(enter)),mean_exits=mean(rowSums(exit)))
 nexts<-s
 for(i in 1:5) {
  a<-which(cont[,i]);u<-which(enter[,i]);ex<-which(exit[,i])
  if(length(a))nexts[a,i]<-1L+rowSums(matrix(runif(length(a)),length(a),9)>cP[s[a,i],,drop=FALSE])
  if(length(u))nexts[u,i]<-1L+rowSums(matrix(runif(length(u)),length(u),9)>matrix(cG,length(u),9,byrow=TRUE))
  if(length(ex))nexts[ex,i]<-if(i<=3)0L else 10L
 }
 stopifnot(all(rowSums(nexts>=1 & nexts<=9)<=5),!any((s[,4:5,drop=FALSE]==10)&(nexts[,4:5,drop=FALSE]!=10)))
 s<-nexts
}
id<-as.integer(1+as.vector(s%*%strides))
for(i in 1:5)payoffs[,i]<-payoffs[,i]+beta^T*sol$V[id,i]
idx0<-1+sum(initial*strides)
summary<-data.table(brand=x$brands,value=sol$V[idx0,],MC_mean=colMeans(payoffs),MC_SE=apply(payoffs,2,sd)/sqrt(N))
summary[,z_score:=(MC_mean-value)/MC_SE]
stopifnot(all(abs(summary$z_score)<6))
fwrite(summary,file.path(out,"simulation_value_audit.csv"));fwrite(rbindlist(reports),file.path(out,"stationary_simulation_summary.csv"))
writeLines(c("5000 simulated paths, 120 months, seed 11062026. Constant 2013 market size and fringe; not a historical path fit.","Draw actual normal scrap and exponential entry costs; compare to equilibrium thresholds. Independent quality/entry-state draws.","Discount realized profits/scrap/entry costs and bootstrap terminal value with solved V. This checks accounting/policy simulation, not independent infinite-horizon identification.","All simulated value comparisons within six Monte Carlo standard errors; roster bound and no-reentry invariants pass."),file.path(out,"simulation_README.txt"))
print(summary)
