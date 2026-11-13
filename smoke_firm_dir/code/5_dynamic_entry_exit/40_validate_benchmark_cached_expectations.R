source("smoke_firm_dir/code/fxns/1_paths.R")
for(f in c("20_dynamic_solver_functions.R","32_anonymous_model_functions.R",
 "35_anonymous_equilibrium_functions.R","39_cached_anonymous_expectations.R"))
 source(file.path(CODE_DIR,"5_dynamic_entry_exit",f))
P<-matrix(c(.7,.3,.2,.8),2,byrow=TRUE)
t<-anon_types(1,c(0,1),0,1,c(.4,.6),1,P,matrix(1,1,1))
g<-anon_game(t,3L);N<-length(g$states);cc<-anon_cached_expectation_factory(g)
set.seed(20261112)
for(trial in 1:5) {
 V<-matrix(rnorm(N*2),N,2)*g$present
 p<-matrix(runif(N*2),N,2)*g$present;e<-runif(N)
 if(trial==2){p<-0*p;e[]<-0}
 if(trial==3){p<-1*g$present;e[]<-1}
 e[g$active_count==3]<-0
 profit<-matrix(2,N,2)*g$present
 ref<-anon_best_response(V,p,e,profit,g,.9,1,10,2)
 got<-anon_best_response(V,p,e,profit,g,.9,1,10,2,expectation=cc$expectation)
 for(name in names(ref))stopifnot(max(abs(ref[[name]]-got[[name]]))<1e-11)
}
# Same equilibrium under both exact expectation implementations.
ref<-anon_solve(profit,g,beta=.9,FC=1,mu_E=10,sigma_S=2)
got<-anon_solve(profit,g,beta=.9,FC=1,mu_E=10,sigma_S=2,expectation=cc$expectation)
stopifnot(ref$converged,got$converged,max(abs(ref$V-got$V))<1e-8,
 max(abs(ref$policy-got$policy))<1e-10,
 max(abs(ref$entry_policy-got$entry_policy))<1e-10)
# Resource guard and geometry binding fail explicitly.
tiny<-anon_cached_expectation_factory(g,max_entries=1)
stopifnot(inherits(try(anon_best_response(V,p,e,profit,g,.9,1,10,2,
 expectation=tiny$expectation),silent=TRUE),"try-error"))
other<-anon_game(t,2L)
stopifnot(inherits(try(cc$expectation(matrix(0,nrow(other$present),2),other,
 integer(),t$G,numeric(),0),silent=TRUE),"try-error"))
cat("PASS cached/reference updates with random and boundary policies; equilibrium agreement; cache guards.\n")
# Measure cold build and warm updates for the same 27-type, cap-two case as script 38.
mc<-readRDS(file.path(OUT_DIR,"dynamic_entry_exit/anonymous_mc_2026-11-12/entrant_mc_inputs.rds"))
P3<-.8*diag(3)+matrix(.2/3,3,3)
t<-anon_types(mc$mc,seq(0,1,length.out=3),seq(-.2,.2,length.out=3),mc$p_mc,
 rep(1/3,3),rep(1/3,3),P3,P3)
g<-anon_game(t,2L);cc<-anon_cached_expectation_factory(g,max_entries=2e6)
V<-matrix(sin(seq_len(nrow(g$present)*27))+10,nrow(g$present),27)*g$present;p<-ifelse(g$present,.8,0)
e<-ifelse(g$active_count<g$cap,.2,0);profit<-matrix(2,nrow(V),27)*g$present
rt<-system.time(ref<-anon_best_response(V,p,e,profit,g,.95^(1/12),1,10,2))[['elapsed']]
ct<-system.time(got<-anon_best_response(V,p,e,profit,g,.95^(1/12),1,10,2,
 expectation=cc$expectation))[['elapsed']]
for(name in names(ref))stopifnot(max(abs(ref[[name]]-got[[name]]))<1e-10)
wt<-rep(NA_real_,3)
for(i in 1:3)wt[i]<-system.time(anon_best_response(V,p,e,profit,g,.95^(1/12),1,10,2,
 expectation=cc$expectation))[['elapsed']]
s<-cc$stats()
result<-data.frame(types=27,cap=2,states=nrow(V),reference_seconds=rt,
 cold_cache_seconds=ct,warm_median_seconds=median(wt),speedup=rt/median(wt),
 cache_keys=s$keys,cache_entries=s$entries,cache_payload_bytes=s$payload_bytes)
out<-file.path(OUT_DIR,"dynamic_entry_exit/anonymous_benchmark_2026-11-12")
write.csv(result,file.path(out,"cached_timings.csv"),row.names=FALSE)
print(result);cat("PASS 27-type cached/reference agreement. No full-cap performance claim.\n")