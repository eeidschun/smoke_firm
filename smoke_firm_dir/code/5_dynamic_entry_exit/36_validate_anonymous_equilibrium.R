source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
source(file.path(CODE_DIR,"5_dynamic_entry_exit/32_anonymous_model_functions.R"))
source(file.path(CODE_DIR,"4_static_pricing_subgame/1_static_demand_functions.R"))
source(file.path(CODE_DIR,"4_static_pricing_subgame/4_manual_pricing_functions.R"))
source(file.path(CODE_DIR,"5_dynamic_entry_exit/35_anonymous_equilibrium_functions.R"))
# Synthetic two-quality, one-MC game; neither bins nor payoff scales are empirical choices.
P<-matrix(c(.7,.3,.2,.8),2,byrow=TRUE)
t<-anon_types(1,c(0,1),0,1,c(.4,.6),1,P,matrix(1,1,1))
g<-anon_game(t,cap=3L);N<-length(g$states)
V<-matrix(seq_len(N*2)/9,N,2)*g$present
p<-matrix(seq(.2,.8,length.out=N*2),N,2)*g$present
e<-seq(.1,.7,length.out=N);e[g$active_count==3]<-0
profits<-matrix(2,N,2)*g$present
b<-anon_best_response(V,p,e,profits,g,.9,.3,5,2)
# Independent labeled Cartesian-product reference: no multiset convolution.
ref<-function(st,tag=NULL) {
 entrant<-is.null(tag)
 if(entrant) {
  if(length(st)==g$cap)return(0)
  own<-t$G;rivals<-st;ep<-0
 } else {
  own<-t$P[st[tag],];rivals<-st[-tag];ep<-if(length(st)<g$cap)e[s] else 0
 }
 laws<-lapply(rivals,function(k)c(1-p[s,k],p[s,k]*t$P[k,]))
 laws<-c(laws,list(c(1-ep,ep*t$G)),list(c(0,own)))
 draws<-as.matrix(expand.grid(rep(list(0:2),length(laws))))
 ans<-0
 for(row in seq_len(nrow(draws))) {
  z<-draws[row,];wt<-prod(vapply(seq_along(laws),function(j)laws[[j]][z[j]+1],numeric(1)))
  if(wt==0)next
  state<-sort(z[z>0]);idx<-which(vapply(g$states,function(x)identical(as.integer(x),as.integer(state)),logical(1)))
  ans<-ans+wt*V[idx,tail(z,1)]
 }
 .9*ans
}
for(s in seq_len(N)) {
 st<-g$states[[s]]
 for(j in seq_along(st))stopifnot(abs(b$continuation[s,st[j]]-ref(st,j))<1e-12)
 stopifnot(abs(b$entry_value[s]-ref(st))<1e-12)
}
cat("PASS independent labeled enumeration: duplicate types, rivals' entry/exits, quality transitions.\n")
# Explicit one-type single-position model: no competitor when own firm continues.
one<-anon_types(1,0,0,1,1,1,matrix(1,1,1),matrix(1,1,1))
h<-anon_game(one,1L)
W<-matrix(c(0,10),2,1);q<-matrix(c(0,.7),2,1)
z<-anon_best_response(W,q,c(.2,0),matrix(c(0,3),2,1),h,.9,1,5,2)
stopifnot(abs(z$continuation[2,1]-9)<1e-12,
 abs(z$entry_value[1]-9)<1e-12,z$entry_policy[2]==0,
 abs(z$V[2,1]-(2+normal_expected_max(9,2)))<1e-12)
# Independent scalar value iteration gives a reference equilibrium value.
v<-0
for(it in 1:10000){nextv<-2+normal_expected_max(.9*v,2);if(abs(nextv-v)<1e-12)break;v<-nextv}
fit<-anon_solve(matrix(c(0,3),2,1),h,beta=.9,FC=1,mu_E=5,sigma_S=2,
 value_tol=1e-10,policy_tol=1e-10)
stopifnot(fit$converged,abs(fit$V[2,1]-v)<1e-7,
 abs(fit$entry_policy[1]-(-expm1(-.9*v/5)))<1e-8)
cat("PASS single-position independent scalar solution.\n")
# Static payoff checks include full duplicate-type markets and fringe-only state.
a<-anon_static_payoffs(g,-2,.2,-.5,.4,-2,100)
stopifnot(all(is.finite(a$profit)),all(a$profit>=0))
for(s in seq_len(N)) {
 m<-a$markets[[s]]
 stopifnot(abs(sum(m$share)+m$fringe_share+m$outside_share-1)<1e-12,m$scaled_foc<1e-8)
 if(length(g$states[[s]])) {
  ids<-g$states[[s]]
  # Reversing labeled firms must reverse outputs, not change economics.
  mc<-t$grid$mc[rev(ids)];u<--2+.2*t$grid$a[rev(ids)]+t$grid$xi[rev(ids)]
  alt<-manual_price_fixed_point(mc,u,-2,-.5,.4,mc+2)
  stopifnot(alt$converged,max(abs(alt$prices-rev(m$prices)))<1e-8)
  for(i in seq_along(ids)) {
   vp<-(m$prices[i]-t$grid$mc[ids[i]])*100*m$share[i]
   stopifnot(abs(vp-a$profit[s,ids[i]])<1e-8)
   # Direct price perturbations provide a separate profit-max check.
   for(shift in c(-.05,.05)) {
    trial<-m$prices;trial[i]<-trial[i]+shift
    sh<-static_shares(trial,-2+.2*t$grid$a[ids]+t$grid$xi[ids],-2,-.5,.4)
    stopifnot((trial[i]-t$grid$mc[ids[i]])*100*sh$share[i]<=vp+1e-9)
   }
  }
 }
}
cat("PASS static FOCs, unilateral bisection, perturbations, symmetry, mass and per-firm profits.\n")
# End-to-end two-type toy equilibrium and failed-solve reporting.
fit<-anon_solve(a$profit,g,beta=.9,FC=1,mu_E=10,sigma_S=2,max_iter=3000)
stopifnot(fit$converged)
fresh<-anon_best_response(fit$V,fit$policy,fit$entry_policy,a$profit,g,.9,1,10,2)
stopifnot(max(abs(fresh$V-fit$V)/pmax(1,abs(fresh$V),abs(fit$V)))<1e-6,
 max(abs(fresh$policy-fit$policy),abs(fresh$entry_policy-fit$entry_policy))<1e-7)
failed<-anon_solve(a$profit,g,beta=.9,FC=1,mu_E=10,sigma_S=2,max_iter=1)
stopifnot(!failed$converged)
cat("PASS end-to-end toy equilibrium; fresh residuals:",fit$residuals,"iterations:",fit$iterations,"\n")
# Actual (not mocked) stationary re-solves under permanent-current-fringe beliefs.
stationary<-anon_stationary_factory(h,-2,.2,-.5,.4,FC=1,mu_E=10,sigma_S=2,
 beta=.9,solver_control=list(max_iter=3000))
monthly<-anon_fringe_solutions(c(-2,-1,-2),100,stationary)
stopifnot(length(monthly$solutions)==2,identical(monthly$month_solution,c(1L,2L,1L)),
 all(vapply(monthly$solutions,function(x)x$converged,logical(1))),
 abs(monthly$solutions[[1]]$V[2,1]-monthly$solutions[[2]]$V[2,1])>1e-4)
for(j in 1:2) {
 sol<-monthly$solutions[[j]]
 check<-anon_best_response(sol$V,sol$policy,sol$entry_policy,sol$payoffs$profit,h,.9,1,10,2)
 stopifnot(max(abs(check$V-sol$V)/pmax(1,abs(check$V),abs(sol$V)))<1e-6)
}
cat("PASS actual monthly fringe re-solves with own continuation values, exact reuse, warm starts.\n")