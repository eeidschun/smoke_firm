# Manual finite-state dynamic game helpers. No equilibrium/optimization packages.
# Dimension 1 varies fastest. Action 1 = continue (active) or enter (eligible).
tensor_expectation <- function(values, dims, kernels) {
 a<-array(values,dims)
 for(k in seq_along(dims)) {
  perm<-c(k,setdiff(seq_along(dims),k));b<-aperm(a,perm)
  b<-kernels[[k]]%*%matrix(b,nrow=dims[k])
  newdims<-dims;newdims[k]<-nrow(kernels[[k]])
  a<-aperm(array(b,newdims[perm]),order(perm));dims<-newdims
 }
 as.vector(a)
}
normal_expected_max <- function(C,sd) C*pnorm(C/sd)+sd*dnorm(C/sd)
exponential_entry_option <- function(B,W,mean_cost) {
 D<-pmax(B-W,0)
 list(probability=-expm1(-D/mean_cost),value=W+D+mean_cost*expm1(-D/mean_cost))
}
build_dynamic_geometry <- function(P,G,n_initial=3L,n_entrants=2L) {
 nq<-nrow(P);n<-n_initial+n_entrants
 dims<-c(rep(nq+1L,n_initial),rep(nq+2L,n_entrants))
 st<-as.matrix(expand.grid(lapply(dims,function(k)0:(k-1L))))
 active<-st>=1L & st<=nq
 eligible<-matrix(FALSE,nrow(st),n)
 if(n_entrants>0)eligible[,(n_initial+1L):n]<-st[,(n_initial+1L):n,drop=FALSE]==0
 kernels<-lapply(seq_len(n),function(i){
  m<-diag(dims[i]);m[2:(nq+1),]<-0;m[2:(nq+1),2:(nq+1)]<-P
  if(i>n_initial)m<-rbind(m,c(0,G,0))
  m
 })
 edims<-vapply(kernels,nrow,integer(1));strides<-cumprod(c(1L,head(edims,-1)))
 maps<-matrix(0L,nrow(st),2^n)
 masks<-as.matrix(expand.grid(rep(list(0:1),n)))
 for(j in seq_len(nrow(masks))) {
  nextindex<-st
  for(i in seq_len(n)) {
   if(masks[j,i]==0L) nextindex[active[,i],i]<-if(i<=n_initial)0L else nq+1L
   if(masks[j,i]==1L) nextindex[eligible[,i],i]<-nq+2L
  }
  maps[,j]<-as.integer(1+as.vector(nextindex%*%strides))
 }
 list(states=st,active=active,eligible=eligible,dims=dims,kernels=kernels,masks=masks,maps=maps,nq=nq,n=n)
}
dynamic_best_response <- function(V,policy,profits,geometry,beta,FC,mu_E,sigma_S,entry_waiting=TRUE) {
 g<-geometry;nv<-matrix(0,nrow(V),g$n);np<-nv;Csave<-nv;Bsave<-nv;Wsave<-nv
 for(i in seq_len(g$n)) {
  e<-tensor_expectation(V[,i],g$dims,g$kernels)
  C<-numeric(nrow(V));W<-C
  for(j in which(g$masks[,i]==1L)) {
   wt<-rep(1,nrow(V))
   for(k in setdiff(seq_len(g$n),i))wt<-wt*if(g$masks[j,k])policy[,k] else (1-policy[,k])
   C<-C+wt*e[g$maps[,j]]
   # Matching mask differing only in own action.
   jj<-j-2^(i-1L)
   W<-W+wt*e[g$maps[,jj]]
  }
  C<-beta*C;W<-beta*W
  a<-g$active[,i];u<-g$eligible[,i]
  nv[a,i]<-profits[a,i]-FC+normal_expected_max(C[a],sigma_S)
  np[a,i]<-pnorm(C[a]/sigma_S)
  if(any(u)) {
   outside<-if(entry_waiting)W[u] else rep(0,sum(u))
   opt<-exponential_entry_option(C[u],outside,mu_E)
   nv[u,i]<-opt$value;np[u,i]<-opt$probability
  }
  Csave[,i]<-ifelse(a,C,0);Bsave[,i]<-ifelse(u,C,0);Wsave[,i]<-ifelse(u,W,0)
 }
 list(V=nv,policy=np,continuation=Csave,entry_value=Bsave,waiting_value=Wsave)
}
manual_dynamic_solve <- function(profits,geometry,beta,FC,mu_E,sigma_S,entry_waiting=TRUE,
 V0=NULL,policy0=NULL,damping=.5,value_tol=1e-6,policy_tol=1e-7,max_iter=4000L,
 value_floor=1,checkpoint=NULL,progress_every=25L) {
 stopifnot(beta>0,beta<1,FC>=0,mu_E>0,sigma_S>0,damping>0,damping<=1)
 V<-if(is.null(V0))matrix(0,nrow(profits),ncol(profits)) else V0
 p<-if(is.null(policy0))ifelse(geometry$active,.95,ifelse(geometry$eligible,.01,0)) else policy0
 trace<-list();ok<-FALSE
 for(it in seq_len(max_iter)) {
  b<-dynamic_best_response(V,p,profits,geometry,beta,FC,mu_E,sigma_S,entry_waiting)
  vr<-max(abs(b$V-V)/pmax(value_floor,abs(V),abs(b$V)))
  pr<-max(abs(b$policy-p))
  trace[[it]]<-c(iteration=it,scaled_bellman_residual=vr,policy_residual=pr,max_value=max(abs(V)))
  if(it%%progress_every==0L) {
   cat(sprintf("iteration %d: scaled Bellman %.3g, policy %.3g\n",it,vr,pr));flush.console()
   if(!is.null(checkpoint))saveRDS(list(V=V,policy=p,iteration=it,trace=do.call(rbind,trace)),checkpoint)
  }
  if(vr<value_tol && pr<policy_tol){ok<-TRUE;break}
  V<-(1-damping)*V+damping*b$V
  p<-(1-damping)*p+damping*b$policy
  stopifnot(all(is.finite(V)),all(is.finite(p)),all(p>=0),all(p<=1))
 }
 list(V=V,policy=p,converged=ok,iterations=it,trace=do.call(rbind,trace),last_best_response=b,
 parameters=list(beta=beta,FC=FC,mu_E=mu_E,sigma_S=sigma_S,entry_waiting=entry_waiting),
 tolerances=list(value_tol=value_tol,policy_tol=policy_tol,value_floor=value_floor,damping=damping))
}
