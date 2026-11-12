source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
P<-matrix(c(.8,.2,.3,.7),2,byrow=TRUE);G<-c(.4,.6)
g<-build_dynamic_geometry(P,G,n_initial=1L,n_entrants=1L)
N<-nrow(g$states)
V<-matrix(seq_len(N*2)/7,N,2);V[!g$active & !g$eligible]<-0
p<-ifelse(g$active,.8,ifelse(g$eligible,.25,0));profits<-ifelse(g$active,2,0)
b<-dynamic_best_response(V,p,profits,g,.9,.3,5,2,TRUE)
# Exact enumeration of next states and rivals' independent actions.
reference<-function(row,i,own_action) {
 total<-0
 for(j in 1:2) {
  actions<-rep(NA_integer_,2);actions[i]<-own_action;actions[3-i]<-j-1L
  wt<-if(j==2)p[row,3-i] else 1-p[row,3-i]
  prob<-rep(1,N)
  for(k in 1:2) {
   state<-g$states[row,k];pr<-numeric(g$dims[k])
   if(g$active[row,k]) {
     if(actions[k])pr[2:3]<-P[state,] else pr[if(k==1)1 else 4]<-1
   } else if(g$eligible[row,k] && actions[k])pr[2:3]<-G else pr[state+1]<-1
   prob<-prob*pr[g$states[,k]+1L]
  }
  stopifnot(abs(sum(prob)-1)<1e-12)
  total<-total+wt*sum(prob*V[,i])
 }
 .9*total
}
for(r in 1:N)for(i in 1:2) {
 C<-reference(r,i,1);W<-reference(r,i,0)
 if(g$active[r,i])stopifnot(abs(b$continuation[r,i]-C)<1e-12)
 if(g$eligible[r,i])stopifnot(abs(b$entry_value[r,i]-C)<1e-12,abs(b$waiting_value[r,i]-W)<1e-12)
}
for(C in c(-5,0,3)) {
 num<-integrate(function(z)pmax(z,C)*dnorm(z,sd=2),-Inf,Inf,rel.tol=1e-9)$value
 stopifnot(abs(num-normal_expected_max(C,2))<1e-7)
}
for(B in c(-2,3,10))for(W in c(0,4)) {
 o<-exponential_entry_option(B,W,5)
 num<-integrate(function(x)pmax(W,B-x)*dexp(x,rate=1/5),0,Inf,rel.tol=1e-9)$value
 stopifnot(abs(num-o$value)<1e-7)
}
# One active firm's deterministic quality process: exact no-operating-profit value.
g1<-build_dynamic_geometry(matrix(1,1,1),1,n_initial=1L,n_entrants=0L)
sol<-manual_dynamic_solve(matrix(0,2,1),g1,.9,0,5,2,max_iter=2000,progress_every=2000)
stopifnot(sol$converged)
C<-.9*sol$V[2,1]
stopifnot(abs(sol$V[2,1]-normal_expected_max(C,2))<1e-5)
fail<-manual_dynamic_solve(profits,g,.9,.3,5,2,max_iter=1,progress_every=2)
stopifnot(!fail$converged)
cat('Passed brute-force transition/conditioning, normal/exponential integration, one-firm fixed point and failure-reporting tests.\n')
