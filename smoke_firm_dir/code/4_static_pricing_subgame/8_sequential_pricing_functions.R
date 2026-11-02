## Sequential algorithms for the same simultaneous-move economic game.
## Source demand functions and 4_manual_pricing_functions.R first.
manual_sequential_prices <- function(mc,v,f,alpha,sigma,p0,
 method=c('markup','best_response'),order=seq_along(mc),damping=1,
 max_sweeps=2000L,step_tol=1e-10,price_tol=1e-9,foc_tol=1e-8) {
 method<-match.arg(method)
 stopifnot(length(mc)==length(v),length(p0)==length(mc),all(is.finite(p0)),
 all(p0>=mc),identical(sort(as.integer(order)),seq_along(mc)),
 damping>0,damping<=1,max_sweeps>0)
 p<-p0;trace<-vector('list',max_sweeps);bisection_iterations<-0L
 for(k in seq_len(max_sweeps)){
  before<-p
  for(i in order){
   if(method=='markup'){
    # Recompute using latest prices, including prior updates in this sweep.
    target<-manual_price_metrics(p,mc,v,f,alpha,sigma)$target[i]
   }else{
    br<-manual_unilateral_best_response(i,p,mc,v,f,alpha,sigma)
    target<-br$price;bisection_iterations<-bisection_iterations+br$iterations
   }
   p[i]<-(1-damping)*p[i]+damping*target
  }
  # Check ALL firms together after full sweep: later updates can undo earlier FOCs.
  step<-max(abs(p-before));met<-manual_price_metrics(p,mc,v,f,alpha,sigma)
  trace[[k]]<-c(sweep=k,max_step=step,price_residual=met$price_residual,scaled_foc=met$scaled_foc)
  if(step<step_tol && met$price_residual<price_tol && met$scaled_foc<foc_tol)break
 }
 list(prices=p,converged=step<step_tol && met$price_residual<price_tol && met$scaled_foc<foc_tol,
 sweeps=k,firm_updates=k*length(mc),bisection_iterations=bisection_iterations,
 price_residual=met$price_residual,scaled_foc=met$scaled_foc,step=step,shares=met$shares,
 trace=do.call(rbind,trace[seq_len(k)]))
}
