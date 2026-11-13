source("smoke_firm_dir/code/fxns/1_paths.R")
for(f in c("20_dynamic_solver_functions.R","32_anonymous_model_functions.R",
 "35_anonymous_equilibrium_functions.R","39_cached_anonymous_expectations.R"))
 source(file.path(CODE_DIR,"5_dynamic_entry_exit",f))
t<-anon_types(1,c(0,1),0,1,c(.4,.6),1,matrix(.5,2,2),matrix(1,1,1))
g<-anon_game(t,3L);N<-length(g$states)
V<-matrix(seq_len(N*2)/9,N,2)*g$present;p<-ifelse(g$present,.8,0)
e<-ifelse(g$active_count<3,.1,0);profit<-matrix(2,N,2)*g$present
cache<-anon_cached_expectation_factory(g,max_entries=100,on_full="clear")
ref<-anon_best_response(V,p,e,profit,g,.9,1,10,2)
for(i in 1:3) {
 got<-anon_best_response(V,p,e,profit,g,.9,1,10,2,expectation=cache$expectation)
 for(name in names(ref))stopifnot(max(abs(got[[name]]-ref[[name]]))<1e-11)
}
stopifnot(cache$stats()$evictions>0,cache$stats()$entries<=100)
invisible(parse(file.path(CODE_DIR,"5_dynamic_entry_exit/42_run_two_hour_anonymous_trial.R")))
cat("PASS exact bounded-cache eviction and two-hour runner syntax.\n")