source("smoke_firm_dir/code/fxns/1_paths.R")
for(f in c("5_dynamic_entry_exit/20_dynamic_solver_functions.R",
 "5_dynamic_entry_exit/32_anonymous_model_functions.R",
 "4_static_pricing_subgame/1_static_demand_functions.R",
 "4_static_pricing_subgame/4_manual_pricing_functions.R",
 "5_dynamic_entry_exit/35_anonymous_equilibrium_functions.R"))source(file.path(CODE_DIR,f))
mc<-readRDS(file.path(OUT_DIR,"dynamic_entry_exit/anonymous_mc_2026-11-12/entrant_mc_inputs.rds"))
out<-file.path(OUT_DIR,"dynamic_entry_exit/anonymous_benchmark_2026-11-12")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
# Synthetic quality grids, transitions, static coefficients and payoff scales:
# timings only, no adoption of empirical initialization or calibration parameters.
cases<-data.frame(n_a=c(1,3,3,3),n_xi=c(1,1,3,3),cap=c(3,2,1,2))
results<-list()
for(j in seq_len(nrow(cases))) {
 z<-cases[j,];na<-z$n_a;nx<-z$n_xi
 transition<-function(n).8*diag(n)+matrix(.2/n,n,n)
 t<-anon_types(mc$mc,seq(0,1,length.out=na),seq(-.2,.2,length.out=nx),
  mc$p_mc,rep(1/na,na),rep(1/nx,nx),transition(na),transition(nx))
 cat("START types",nrow(t$grid),"cap",z$cap,"\n");flush.console()
 gt<-system.time(g<-anon_game(t,z$cap))[['elapsed']]
 pt<-system.time(pay<-anon_static_payoffs(g,-2,.2,-.5,.4,-2,100,
  verify_deviations=TRUE))[['elapsed']]
 V<-matrix(10,nrow(g$present),g$n_types)*g$present
 p<-ifelse(g$present,.8,0);e<-ifelse(g$active_count<g$cap,.2,0)
 bt<-system.time(b<-anon_best_response(V,p,e,pay$profit,g,.95^(1/12),1,10,2))[['elapsed']]
 stopifnot(all(is.finite(b$V)),all(b$policy>=0&b$policy<=1),
  all(b$entry_policy>=0&b$entry_policy<=1),all(b$entry_policy[g$active_count==g$cap]==0))
 results[[j]]<-data.frame(types=g$n_types,cap=g$cap,states=length(g$states),
  tagged_values=sum(g$present),geometry_seconds=gt,pricing_seconds=pt,
  one_bellman_seconds=bt,geometry_bytes=as.numeric(object.size(g)))
 print(results[[j]]);flush.console()
 write.csv(do.call(rbind,results),file.path(out,"timings.csv"),row.names=FALSE)
}
# Counts and minimum numeric payload only, not runtime extrapolation.
K<-27;cap<-5;states<-choose(K+cap,cap)
tagged<-K*choose(K+cap-1,cap-1)
write.csv(data.frame(types=K,cap=cap,states=states,tagged_values=tagged,
 dense_one_value_array_bytes=8*states*K,
 dense_transition_bytes=8*states^2),file.path(out,"full_size_counts.csv"),row.names=FALSE)
writeLines(c("Timing exercise only; all quality/payoff settings synthetic except approved MC support.",
 "No full equilibrium convergence measured; one Bellman update starts at nonzero V.",
 "Pricing includes unilateral checks. No full-scale runtime inferred from smaller caps.",
 paste("R:",R.version.string),paste("Date:","2026-11-12")),file.path(out,"README.txt"))
cat("PASS benchmark invariants; timings saved to",out,"\n")