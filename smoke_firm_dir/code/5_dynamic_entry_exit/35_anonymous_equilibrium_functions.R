anon_lookup_state <- function(g,state) {
 key<-paste0("s:",anon_state_key(state))
 if(!is.null(g$hash_lookup)) {
  if(exists(key,g$hash_lookup,inherits=FALSE))get(key,g$hash_lookup,inherits=FALSE) else NA_integer_
 } else unname(g$lookup[key])
}
# Exact small-game reference implementation. Source 32 and static helpers first.
# V[s,k] belongs to ONE tagged incumbent of type k, not total type-k value.
anon_game <- function(types,cap=5L) {
 g<-anon_enumerate(nrow(types$grid),cap)
 g$types<-types
 g$present<-matrix(FALSE,length(g$states),g$n_types)
 g$lookup<-setNames(seq_along(g$keys),paste0("s:",g$keys))
 g$hash_lookup<-list2env(as.list(g$lookup),hash=TRUE,parent=emptyenv())
 for(s in seq_along(g$states))g$present[s,unique(g$states[[s]])]<-TRUE
 g
}
anon_static_payoffs <- function(g,intercept,beta_a,alpha,sigma,delta_F,M,
                                verify_deviations=TRUE) {
 stopifnot(is.finite(M),M>0,is.finite(delta_F),alpha<0,sigma>=0,sigma<1)
 profit<-matrix(0,nrow(g$present),g$n_types);markets<-vector("list",nrow(profit))
 grid<-g$types$grid
 for(s in seq_along(g$states)) {
  ids<-g$states[[s]]
  if(!length(ids)) {
   # Demand with fringe alone (outside normalized to zero).
   markets[[s]]<-list(prices=numeric(),share=numeric(),
    fringe_share=plogis(delta_F),outside_share=plogis(-delta_F),scaled_foc=0)
   next
  }
  mc<-grid$mc[ids];v<-intercept+beta_a*grid$a[ids]+grid$xi[ids]
  fit<-manual_price_fixed_point(mc,v,delta_F,alpha,sigma,mc+1)
  if(!fit$converged)stop("Static pricing failed at state ",s)
  vp<-(fit$prices-mc)*M*fit$shares$share
  dev_error<-0
  if(verify_deviations) for(i in seq_along(ids)) {
   br<-manual_unilateral_best_response(i,fit$prices,mc,v,delta_F,alpha,sigma)
   dev_error<-max(dev_error,abs(br$price-fit$prices[i]))
  }
  if(dev_error>1e-7)stop("Unilateral pricing audit failed")
  for(k in unique(ids)) {
   stopifnot(diff(range(vp[ids==k]))<1e-7)
   profit[s,k]<-mean(vp[ids==k])
  }
  markets[[s]]<-list(prices=fit$prices,share=fit$shares$share,
   fringe_share=fit$shares$fringe_share,outside_share=fit$shares$outside_share,
   scaled_foc=fit$scaled_foc,deviation_price_error=dev_error)
 }
 list(profit=profit,markets=markets,delta_F=delta_F,M=M)
}
# Convolve independently drawn labeled outcomes, merging equal unordered multisets.
# Outcome 0 means absent, positive outcomes are next-period types.
anon_convolve <- function(distribution,outcome_probability) {
 result<-list()
 for(node in distribution)for(k in which(outcome_probability>0)) {
  outcome<-k-1L
  st<-sort(c(node$state,if(outcome>0)outcome else integer()))
  key<-paste0("s:",anon_state_key(st));wt<-node$prob*outcome_probability[k]
  if(is.null(result[[key]]))result[[key]]<-list(state=st,prob=wt)
  else result[[key]]$prob<-result[[key]]$prob+wt
 }
 result
}
anon_tagged_expectation <- function(V,g,others,own_next,continue_prob,entry_prob) {
 d<-list(list(state=integer(),prob=1))
 for(j in seq_along(others)) {
  q<-continue_prob[j]
  d<-anon_convolve(d,c(1-q,q*g$types$P[others[j],]))
 }
 if(entry_prob>0)d<-anon_convolve(d,c(1-entry_prob,entry_prob*g$types$G))
 total<-0
 for(node in d)for(k in which(own_next>0)) {
  state<-sort(c(node$state,k));s<-anon_lookup_state(g,state)
  if(is.na(s))stop("Successor exceeds cap or is missing")
  total<-total+node$prob*own_next[k]*V[s,k]
 }
 total
}
anon_best_response <- function(V,p,e,profits,g,beta,FC,mu_E,sigma_S,
                               expectation=anon_tagged_expectation) {
 stopifnot(beta>0,beta<1,FC>=0,mu_E>0,sigma_S>0,
  identical(dim(V),dim(g$present)),identical(dim(p),dim(V)),
  identical(dim(profits),dim(V)),length(e)==nrow(V),
  all(is.finite(c(V,p,e,profits))),all(p>=0&p<=1),all(e>=0&e<=1))
 nv<-np<-C<-matrix(0,nrow(V),ncol(V));B<-ne<-ev<-numeric(nrow(V))
 for(s in seq_along(g$states)) {
  st<-g$states[[s]];eligible<-length(st)<g$cap
  for(k in unique(st)) {
   # Remove exactly ONE own occurrence: identical rivals remain in the game.
   rivals<-st[-match(k,st)]
   C[s,k]<-beta*expectation(V,g,rivals,g$types$P[k,],
    p[s,rivals],if(eligible)e[s] else 0)
   nv[s,k]<-profits[s,k]-FC+normal_expected_max(C[s,k],sigma_S)
   np[s,k]<-pnorm(C[s,k]/sigma_S)
  }
  if(eligible) {
   # Entrant's MC/a/xi are unknown before commitment, direct G draw after it.
   B[s]<-beta*expectation(V,g,st,g$types$G,p[s,st],0)
   opt<-anon_entry_option(B[s],mu_E);ne[s]<-opt$probability;ev[s]<-opt$value
  }
 }
 list(V=nv,policy=np,entry_policy=ne,continuation=C,entry_value=B,candidate_value=ev)
}
anon_solve <- function(profits,g,beta=0.95^(1/12),FC,mu_E,sigma_S,
                       damping=.5,max_iter=4000L,value_tol=1e-6,policy_tol=1e-7,
                       warm_start=NULL,expectation=anon_tagged_expectation) {
 stopifnot(damping>0,damping<=1,max_iter>=1,value_tol>0,policy_tol>0)
 V<-matrix(0,nrow(profits),ncol(profits));p<-ifelse(g$present,.8,0)
 e<-ifelse(g$active_count<g$cap,.1,0)
 if(!is.null(warm_start)){V<-warm_start$V;p<-warm_start$policy;e<-warm_start$entry_policy}
 trace<-matrix(NA_real_,max_iter,3,dimnames=list(NULL,c("iteration","bellman","policy")))
 ok<-FALSE
 for(it in seq_len(max_iter)) {
  b<-anon_best_response(V,p,e,profits,g,beta,FC,mu_E,sigma_S,expectation)
  vr<-max(abs(b$V-V)/pmax(1,abs(V),abs(b$V)))
  pr<-max(abs(b$policy-p),abs(b$entry_policy-e))
  trace[it,]<-c(it,vr,pr)
  if(vr<value_tol && pr<policy_tol){ok<-TRUE;break}
  # Return the checked iterate if budget ends, not an unchecked final update.
  if(it==max_iter)break
  V<-(1-damping)*V+damping*b$V
  p<-(1-damping)*p+damping*b$policy;e<-(1-damping)*e+damping*b$entry_policy
 }
 list(V=V,policy=p,entry_policy=e,converged=ok,iterations=it,
  residuals=c(bellman=vr,policy=pr),last_best_response=b,trace=trace[seq_len(it),,drop=FALSE],
  parameters=list(beta=beta,FC=FC,mu_E=mu_E,sigma_S=sigma_S))
}
# Returns a dispatcher-compatible stationary solver with fixed game/payoff settings.
anon_stationary_factory <- function(g,intercept,beta_a,alpha,sigma,FC,mu_E,sigma_S,
                                    beta=0.95^(1/12),solver_control=list()) {
 force(g);force(intercept);force(beta_a);force(alpha);force(sigma)
 force(FC);force(mu_E);force(sigma_S);force(beta);force(solver_control)
 function(delta_F,M,warm_start=NULL) {
  pay<-anon_static_payoffs(g,intercept,beta_a,alpha,sigma,delta_F,M)
  fit<-do.call(anon_solve,c(list(profits=pay$profit,g=g,beta=beta,FC=FC,
   mu_E=mu_E,sigma_S=sigma_S,warm_start=warm_start),solver_control))
  fit$delta_F<-delta_F;fit$M<-M;fit$payoffs<-pay
  fit
 }
}