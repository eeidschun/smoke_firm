source("smoke_firm_dir/code/fxns/1_paths.R")
for(f in c("20_dynamic_solver_functions.R","32_anonymous_model_functions.R",
 "35_anonymous_equilibrium_functions.R","39_cached_anonymous_expectations.R"))
 source(file.path(CODE_DIR,"5_dynamic_entry_exit",f))
source(file.path(CODE_DIR,"4_static_pricing_subgame/1_static_demand_functions.R"))
source(file.path(CODE_DIR,"4_static_pricing_subgame/4_manual_pricing_functions.R"))
root<-file.path(OUT_DIR,"dynamic_entry_exit")
suffix<-if("--hash-retry" %in% commandArgs(TRUE))"anonymous_full_trial_hash_retry_2026-11-12" else "anonymous_full_trial_2026-11-12"
out<-file.path(root,"anonymous_full_trial_two_hour_2026-11-12")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
if(file.exists(file.path(out,"status.rds")))stop("Existing trial status: preserve prior attempt")
status<-list(converged=FALSE,phase="inputs",started=as.character(Sys.time()))
persist<-function(){saveRDS(status,file.path(out,"status.rds"));writeLines(capture.output(str(status)),file.path(out,"status.txt"))}
settings<-list(beta=.95^(1/12),FC=1e5,mu_E=1e8,sigma_S=5e6,
 damping=.5,max_iter=4000L,value_tol=1e-6,policy_tol=1e-7,
 bellman_update_limit_seconds=60,cache_max_entries=2e6)
settings$bellman_update_limit_seconds<-7200
settings$cache_max_entries<-5e6
status$settings<-settings
run_start<-proc.time()[3]
tryCatch({
 mc<-readRDS(file.path(root,"anonymous_mc_2026-11-12/entrant_mc_inputs.rds"))
 x<-readRDS(file.path(root,"january_fringe_benchmark_2026-11-06/fixed_focal_supply_inputs.rds"))
 tr<-readRDS(file.path(root,"independent_transitions_2026-11-03/transition_inputs.rds"))
 initial<-read.csv(file.path(root,"entrant_quality_2026-11-04/entrant_initial_state_distribution.csv"))
 pa<-as.numeric(tapply(initial$probability,initial$quality_state,sum))
 px<-as.numeric(tapply(initial$probability,initial$xi_state,sum))
 grid<-as.data.frame(tr$grid)
 a<-grid$quality[match(1:3,grid$quality_state)];xi<-grid$xi[match(1:3,grid$xi_state)]
 types<-anon_types(mc$mc,a,xi,mc$p_mc,pa,px,tr$P_quality,tr$P_xi)
 status$phase<-"geometry";persist();cat("Building 27-type cap-five geometry\n");flush.console()
 t0<-proc.time()[3];g<-anon_game(types,5L)
 status$geometry_seconds<-unname(proc.time()[3]-t0)
 status$states<-length(g$states);status$tagged_values<-sum(g$present)
 status$geometry_bytes<-as.numeric(object.size(g))
 stopifnot(status$states==201376L)
 delta_F<-x$delta_F_constant;M<-as.data.frame(x$markets)$M[1]
 status$delta_F<-delta_F;status$M<-M;status$phase<-"static pricing";persist()
 cat("Vectorized pricing for",status$states,"states\n");flush.console()
 t0<-proc.time()[3];N<-length(g$states);cap<-5L
 slots<-matrix(0L,N,cap)
 for(s in seq_len(N))if(length(g$states[[s]]))slots[s,seq_along(g$states[[s]])]<-g$states[[s]]
 active<-slots>0;cost<-matrix(0,N,cap);v<-cost
 cost[active]<-types$grid$mc[slots[active]]
 v[active]<-x$intercept+x$beta_a*types$grid$a[slots[active]]+types$grid$xi[slots[active]]
 alpha<-x$alpha;sigma<-x$sigma
 shares<-function(p) {
  u<-(v+alpha*p)/(1-sigma);u[!active]<- -Inf
  uf<-delta_F/(1-sigma)
  mx<-Reduce(pmax,c(list(rep(uf,N)),lapply(seq_len(cap),function(i)u[,i])))
  w<-exp(u-mx);wf<-exp(uf-mx);den<-rowSums(w)+wf
  within<-w/den;sg<-plogis((1-sigma)*(mx+log(den)))
  list(share=within*sg,within=within,fringe=wf/den*sg,outside=1-sg)
 }
 p<-cost+active
 for(it in 1:2000) {
  sh<-shares(p);A<-1/(1-sigma)-sigma*sh$within/(1-sigma)-sh$share
  target<-cost-1/(alpha*A);target[!active]<-0
  pp<-.5*p+.5*target;step<-max(abs(pp-p));p<-pp
  if(step<1e-11)break
 }
 sh<-shares(p);A<-1/(1-sigma)-sigma*sh$within/(1-sigma)-sh$share
 foc<-1+(p-cost)*alpha*A
 stopifnot(it<2000,max(abs(foc[active]))<1e-8,
  max(abs(rowSums(sh$share)+sh$fringe+sh$outside-1))<1e-12)
 profit_slots<-(p-cost)*M*sh$share
 profits<-matrix(0,N,g$n_types)
 for(i in seq_len(cap)) {
  rows<-which(active[,i]);profits[cbind(rows,slots[rows,i])]<-profit_slots[rows,i]
 }
 # Compare vectorized implementation to the independent manual scalar solver.
 sample<-unique(c(which(g$active_count==0),which(g$active_count==1)[c(1,27)],
  which(g$active_count==5)[round(seq(1,sum(g$active_count==5),length.out=12))]))
 for(s in sample) {
  ids<-g$states[[s]];if(!length(ids))next
  fit<-manual_price_fixed_point(types$grid$mc[ids],
   x$intercept+x$beta_a*types$grid$a[ids]+types$grid$xi[ids],delta_F,alpha,sigma,types$grid$mc[ids]+1)
  stopifnot(fit$converged,max(abs(fit$prices-p[s,seq_along(ids)]))<1e-8)
  for(i in seq_along(ids)) {
   br<-manual_unilateral_best_response(i,fit$prices,types$grid$mc[ids],
    x$intercept+x$beta_a*types$grid$a[ids]+types$grid$xi[ids],delta_F,alpha,sigma)
   stopifnot(abs(br$price-fit$prices[i])<1e-7)
  }
 }
 status$pricing_seconds<-unname(proc.time()[3]-t0);status$max_static_foc<-max(abs(foc[active]))
 saveRDS(list(profits=profits,types=types,delta_F=delta_F,M=M,settings=settings,
  method="Anonymous cap-five vectorized static pricing; trial parameters, not fitted"),file.path(out,"static_payoffs.rds"))
 rm(slots,active,cost,v,p,pp,target,sh,A,foc,profit_slots);gc()
 V<-matrix(0,N,g$n_types);pol<-ifelse(g$present,.8,0);e<-ifelse(g$active_count<5,.1,0)
 cache<-anon_cached_expectation_factory(g,max_entries=settings$cache_max_entries,on_full="clear")
 last_progress<-proc.time()[3];expectation_calls<-0L
 monitored_expectation<-function(...) {
  result<-cache$expectation(...);expectation_calls<<-expectation_calls+1L
  if(proc.time()[3]-last_progress>30) {
   writeLines(c(paste("Iteration",iter),paste("Expectation calls",expectation_calls),
    paste("Elapsed seconds",round(proc.time()[3]-run_start,1))),file.path(out,"progress.txt"))
   cat("PROGRESS iteration",iter,"calls",expectation_calls,"elapsed",round(proc.time()[3]-run_start),"seconds\n");flush.console()
   last_progress<<-proc.time()[3]
  }
  result
 }
 status$phase<-"Bellman iteration";status$iterations_completed<-0L;persist()
 trace<-list()
 for(iter in seq_len(settings$max_iter)) {
  remaining<-7200-(proc.time()[3]-run_start)
  if(remaining<=0)stop("Two-hour total wall-time budget reached")
  saveRDS(list(V=V,policy=pol,entry_policy=e,iteration=iter-1L,converged=FALSE,
   settings=settings),file.path(out,"resume_checkpoint.rds"))
  cat("Bellman iteration",iter,"remaining seconds",round(remaining),"\n");flush.console()
  t0<-proc.time()[3]
  setTimeLimit(elapsed=remaining,transient=TRUE)
  b<-anon_best_response(V,pol,e,profits,g,settings$beta,settings$FC,
   settings$mu_E,settings$sigma_S,expectation=monitored_expectation)
  setTimeLimit(cpu=Inf,elapsed=Inf,transient=FALSE)
  vr<-max(abs(b$V-V)/pmax(1,abs(V),abs(b$V)))
  pr<-max(abs(b$policy-pol),abs(b$entry_policy-e))
  trace[[iter]]<-c(iteration=iter,bellman=vr,policy=pr,seconds=proc.time()[3]-t0)
  write.csv(do.call(rbind,trace),file.path(out,"trace.csv"),row.names=FALSE)
  status$iterations_completed<-iter;status$residuals<-c(bellman=vr,policy=pr)
  saveRDS(list(V=V,policy=pol,entry_policy=e,iteration=iter,residuals=status$residuals,
   converged=FALSE,settings=settings),file.path(out,"checkpoint.rds"))
  if(vr<settings$value_tol && pr<settings$policy_tol) {
   status$converged<-TRUE;break
  }
  if(iter<settings$max_iter) {
   V<-.5*V+.5*b$V;pol<-.5*pol+.5*b$policy;e<-.5*e+.5*b$entry_policy
  }
 }
 status$cache<-cache$stats();status$phase<-"finished";persist()
 if(status$converged)saveRDS(list(V=V,policy=pol,entry_policy=e,status=status),file.path(out,"solution.rds"))
},error=function(err) {
 setTimeLimit(cpu=Inf,elapsed=Inf,transient=FALSE)
 status$error<<-conditionMessage(err)
 if(exists("cache"))status$cache<<-cache$stats()
 status$failed_phase<<-status$phase;status$phase<<-"stopped";persist()
 cat("ATTEMPT STOPPED:",status$error,"\n");flush.console()
})
writeLines(c("Trial only, not estimation. FC=100k/month, mean entry cost=100m, scrap SD=5m.",
 "Approved empirical MC support; retained empirical quality transitions.",
 "Trial independent initial quality draws use marginals of existing joint G; no new joint fit.",
 "January market size and fixed-focal fringe held constant; no historical initialization required.",
 "No failed or incomplete iterate is a converged solution."),file.path(out,"README.txt"))
print(status)