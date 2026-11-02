## Manual pricing routines; source after 1_static_demand_functions.R.
## No optim/root/equilibrium package calls.
manual_price_metrics <- function(p,mc,v,f,alpha,sigma) {
 s<-static_shares(p,v,f,alpha,sigma)
 A<-1/(1-sigma)-sigma*s$within/(1-sigma)-s$share
 target<-mc-1/(alpha*A)
 list(shares=s,target=target,price_residual=max(abs(p-target)),
      scaled_foc=max(abs(1+(p-mc)*alpha*A)))
}
manual_price_fixed_point <- function(mc,v,f,alpha,sigma,p0,damping=.5,
 max_iter=2000L,step_tol=1e-10,price_tol=1e-9,foc_tol=1e-8) {
 stopifnot(length(mc)==length(v),length(p0)==length(mc),all(is.finite(mc)),
 all(is.finite(p0)),all(p0>=mc),damping>0,damping<=1,max_iter>0)
 p<-p0;trace<-vector('list',max_iter)
 for(k in seq_len(max_iter)) {
  old<-manual_price_metrics(p,mc,v,f,alpha,sigma)
  nextp<-(1-damping)*p+damping*old$target
  if(any(!is.finite(nextp)))stop('Nonfinite fixed-point update')
  step<-max(abs(nextp-p));p<-nextp
  now<-manual_price_metrics(p,mc,v,f,alpha,sigma)
  trace[[k]]<-c(iteration=k,max_step=step,price_residual=now$price_residual,scaled_foc=now$scaled_foc)
  if(step<step_tol && now$price_residual<price_tol && now$scaled_foc<foc_tol)break
 }
 list(prices=p,converged=step<step_tol && now$price_residual<price_tol && now$scaled_foc<foc_tol,
 iterations=k,step=step,price_residual=now$price_residual,scaled_foc=now$scaled_foc,
 shares=now$shares,trace=do.call(rbind,trace[seq_len(k)]))
}
manual_unilateral_best_response <- function(i,p,mc,v,f,alpha,sigma,tol=1e-11,max_iter=200L) {
 # With rivals fixed, A_i'(p_i)>0 for alpha<0 and 0<=sigma<1.
 # g_i=1+alpha*(p_i-mc_i)*A_i decreases strictly on p_i>=mc_i.
 # g_i(mc_i)=1; g_i tends to -infinity. Unique root is global maximum:
 # profit below cost <=0, positive at root, tends to 0 as price -> infinity.
 g<-function(q){trial<-p;trial[i]<-q;s<-static_shares(trial,v,f,alpha,sigma)
  A<-1/(1-sigma)-sigma*s$within[i]/(1-sigma)-s$share[i]
  1+alpha*(q-mc[i])*A}
 lower<-mc[i];upper<-mc[i]+max(1,abs(p[i]-mc[i]));expansions<-0L
 while(g(upper)>0 && expansions<60L){upper<-mc[i]+2*(upper-mc[i]);expansions<-expansions+1L}
 stopifnot(g(lower)>0,g(upper)<=0)
 for(k in seq_len(max_iter)){
  middle<-(lower+upper)/2
  if(g(middle)>0)lower<-middle else upper<-middle
  if(upper-lower<tol)break
 }
 stopifnot(upper-lower<tol)
 q<-(lower+upper)/2;trial<-p;trial[i]<-q
 shares<-static_shares(trial,v,f,alpha,sigma)
 list(price=q,profit_per_market=(q-mc[i])*shares$share[i],foc=g(q),iterations=k,expansions=expansions)
}
