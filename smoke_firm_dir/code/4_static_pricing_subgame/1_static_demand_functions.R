## Transparent demand primitives, signed alpha < 0. No equilibrium solver.
static_logsumexp <- function(x) {
  stopifnot(length(x)>0L,all(is.finite(x)))
  z<-max(x);z+log(sum(exp(x-z)))
}
static_shares <- function(prices,nonprice_utility,fringe_utility,alpha,sigma) {
  stopifnot(length(prices)==length(nonprice_utility),length(prices)>0L,
    all(is.finite(prices)),all(is.finite(nonprice_utility)),
    length(fringe_utility)==1L,is.finite(fringe_utility),
    length(alpha)==1L,is.finite(alpha),alpha<0,
    length(sigma)==1L,is.finite(sigma),sigma>=0,sigma<1)
  delta<-c(nonprice_utility+alpha*prices,fringe_utility)
  logD<-static_logsumexp(delta/(1-sigma))
  log_conditional<-delta/(1-sigma)-logD
  inclusive<-(1-sigma)*logD
  # Stable log logistic, retaining log outside probability for extreme states.
  log_nest<-if(inclusive>=0)-log1p(exp(-inclusive))else inclusive-log1p(exp(inclusive))
  log_outside<-if(inclusive>=0)-inclusive-log1p(exp(-inclusive))else -log1p(exp(inclusive))
  log_share<-log_conditional+log_nest
  n<-length(prices)
  list(share=exp(log_share[seq_len(n)]),within=exp(log_conditional[seq_len(n)]),
    fringe_share=exp(tail(log_share,1)),fringe_within=exp(tail(log_conditional,1)),
    nest_share=exp(log_nest),outside_share=exp(log_outside),
    log_share=log_share[seq_len(n)],log_fringe_share=tail(log_share,1),
    log_outside=log_outside,logD=logD)
}
static_own_derivative <- function(share,within,alpha,sigma) {
  stopifnot(alpha<0,sigma>=0,sigma<1)
  alpha*share*(1/(1-sigma)-sigma*within/(1-sigma)-share)
}
static_markup <- function(share,within,alpha,sigma) {
  derivative<-static_own_derivative(share,within,alpha,sigma)
  stopifnot(all(is.finite(derivative)),all(derivative<0),all(share>0))
  -share/derivative
}
