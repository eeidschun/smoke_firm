# Anonymous revision primitives; old fixed-roster solver is unchanged.
# Helpers accept explicit distributions: no empirical MC discretization defaults.
anon_probability <- function(x) {
 stopifnot(is.numeric(x),length(x)>0L,all(is.finite(x)),all(x>=0),abs(sum(x)-1)<1e-10)
 invisible(TRUE)
}
anon_types <- function(mc,a,xi,p_mc,p_a,p_xi,P_a,P_xi) {
 lapply(list(p_mc,p_a,p_xi),anon_probability)
 stopifnot(length(mc)==length(p_mc),length(a)==length(p_a),length(xi)==length(p_xi),
  all(is.finite(c(mc,a,xi))),all(mc>0),
  identical(dim(P_a),c(length(a),length(a))),identical(dim(P_xi),c(length(xi),length(xi))))
 apply(P_a,1,anon_probability);apply(P_xi,1,anon_probability)
 grid<-expand.grid(mc_bin=seq_along(mc),a_bin=seq_along(a),xi_bin=seq_along(xi))
 grid$mc<-mc[grid$mc_bin];grid$a<-a[grid$a_bin];grid$xi<-xi[grid$xi_bin]
 G<-p_mc[grid$mc_bin]*p_a[grid$a_bin]*p_xi[grid$xi_bin]
 P<-matrix(0,nrow(grid),nrow(grid))
 for(i in seq_len(nrow(grid))) P[i,]<-(grid$mc_bin==grid$mc_bin[i])*
  P_a[grid$a_bin[i],grid$a_bin]*P_xi[grid$xi_bin[i],grid$xi_bin]
 stopifnot(max(abs(rowSums(P)-1))<1e-10)
 list(grid=grid,G=G,P=P)
}
# Sorted multiset preserves multiplicity, removes arbitrary slot labels.
anon_state_key <- function(types) paste(sort(as.integer(types)),collapse=",")
anon_enumerate <- function(n_types,cap=5L) {
 stopifnot(n_types>=1L,cap>=1L,n_types==as.integer(n_types),cap==as.integer(cap))
 states<-list(integer())
 visit<-function(prefix,lower) {
  if(length(prefix)==cap)return(invisible(NULL))
  for(k in seq.int(lower,n_types)) {
   next_state<-c(prefix,k);states[[length(states)+1L]]<<-next_state
   visit(next_state,k)
  }
 }
 visit(integer(),1L)
 stopifnot(length(states)==choose(n_types+cap,cap))
 list(states=states,keys=vapply(states,anon_state_key,character(1)),
  active_count=lengths(states),n_types=n_types,cap=cap)
}
anon_entry_option <- function(B,mean_cost) {
 stopifnot(all(is.finite(B)),length(mean_cost)==1L,is.finite(mean_cost),mean_cost>0)
 D<-pmax(B,0)
 list(probability=-expm1(-D/mean_cost),value=D+mean_cost*expm1(-D/mean_cost),waiting_value=0)
}
anon_entry_value <- function(next_values,G,beta=0.95^(1/12)) {
 anon_probability(G)
 stopifnot(length(next_values)==length(G),all(is.finite(next_values)),beta>0,beta<1)
 # next_values already integrate rivals' simultaneous exits and transitions.
 beta*sum(G*next_values)
}
# Boundary convention: incoming commitments are activated before this function's
# current population is counted. One commitment at most, all active at next boundary.
# Pure transition: decisions/draws supplied explicitly for reproducible tests.
anon_step <- function(population,continue,accept,entrant_type,next_types,next_id,
                      n_types,cap=5L) {
 stopifnot(is.data.frame(population),all(c("id","type") %in% names(population)),
  !anyDuplicated(population$id),nrow(population)<=cap,
  all(population$type %in% seq_len(n_types)),
  is.logical(continue),length(continue)==nrow(population),!anyNA(continue),
  is.logical(accept),length(accept)==1L,!is.na(accept),
  length(next_types)==nrow(population),all(next_types %in% seq_len(n_types)),
  length(next_id)==1L,is.finite(next_id),next_id>=1,
  all(population$id<next_id))
 eligible<-nrow(population)<cap
 if(accept && !eligible)stop("No candidate at cap, even if incumbents exit this month")
 survivors<-population[continue,c("id","type"),drop=FALSE]
 survivors$type<-as.integer(next_types[continue])
 exited<-population$id[!continue]
 entrant_id<-integer()
 if(accept) {
  stopifnot(length(entrant_type)==1L,entrant_type %in% seq_len(n_types))
  entrant_id<-next_id
  survivors<-rbind(survivors,data.frame(id=next_id,type=as.integer(entrant_type)))
  next_id<-next_id+1L
 }
 stopifnot(nrow(survivors)<=cap,!anyDuplicated(survivors$id))
 list(next_population=survivors,next_id=next_id,exited_ids=exited,
      entrant_id=entrant_id,candidate_eligible=eligible,
      current_operating_ids=population$id,next_key=anon_state_key(survivors$type))
}
# Callback contract: a solve must be a stationary solution for its supplied fringe
# benchmark, with M fixed. No interpolation or old continuation-value substitution.
anon_fringe_solutions <- function(delta_F,M,solve_stationary,initial=NULL) {
 stopifnot(length(delta_F)>0L,all(is.finite(delta_F)),length(M)==1L,is.finite(M),M>0)
 benchmarks<-unique(delta_F);solutions<-vector("list",length(benchmarks));warm<-initial
 for(k in seq_along(benchmarks)) {
  fit<-solve_stationary(delta_F=benchmarks[k],M=M,warm_start=warm)
  if(!isTRUE(fit$converged))stop("Stationary solve failed at fringe benchmark ",k)
  stopifnot(identical(fit$delta_F,benchmarks[k]),identical(fit$M,M))
  solutions[[k]]<-fit;warm<-fit
 }
 list(benchmarks=benchmarks,month_solution=match(delta_F,benchmarks),solutions=solutions,
      forecast="current fringe utility permanent",M=M)
}
