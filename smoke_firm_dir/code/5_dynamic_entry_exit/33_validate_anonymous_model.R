source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/32_anonymous_model_functions.R"))
fails<-function(expr)stopifnot(inherits(try(force(expr),silent=TRUE),"try-error"))
P<-matrix(c(.8,.2,.1,.9),2,byrow=TRUE)
t<-anon_types(c(1,4),c(10,20),c(-1,1),c(.3,.7),c(.4,.6),c(.2,.8),P,P)
stopifnot(abs(sum(t$G)-1)<1e-12)
for(i in 1:8)for(j in 1:8) {
 stopifnot(t$P[i,j]==if(t$grid$mc_bin[i]==t$grid$mc_bin[j])
  P[t$grid$a_bin[i],t$grid$a_bin[j]]*P[t$grid$xi_bin[i],t$grid$xi_bin[j]] else 0)
 stopifnot(t$G[j]==c(.3,.7)[t$grid$mc_bin[j]]*c(.4,.6)[t$grid$a_bin[j]]*c(.2,.8)[t$grid$xi_bin[j]])
}
g<-anon_enumerate(2,5)
stopifnot(length(g$states)==21,!anyDuplicated(g$keys),
 anon_state_key(c(2,1,1))==anon_state_key(c(1,2,1)),
 anon_state_key(c(1,1))!=anon_state_key(1))
# Exhaustively check all start counts, exits, and permissible entry decisions.
for(n in 0:5)for(mask in 0:(2^n-1))for(accept in c(FALSE,TRUE)) {
 pop<-data.frame(id=seq_len(n),type=rep(1L,n))
 keep<-as.logical(as.integer(intToBits(mask))[seq_len(n)])
 if(n==5 && accept) {
  fails(anon_step(pop,keep,accept,2L,rep(1L,n),n+1L,8L));next
 }
 z<-anon_step(pop,keep,accept,2L,rep(1L,n),n+1L,8L)
 stopifnot(nrow(z$next_population)==sum(keep)+as.integer(accept),
  nrow(z$next_population)<=5,!any(z$exited_ids %in% z$next_population$id),
  identical(z$current_operating_ids,pop$id),z$candidate_eligible==(n<5))
 if(accept)stopifnot(z$next_population$type[nrow(z$next_population)]==2L)
}
# Full market exits: replacement may commit only next month, operates the month after.
pop<-data.frame(id=1:5,type=rep(1L,5))
z<-anon_step(pop,c(FALSE,TRUE,TRUE,TRUE,TRUE),FALSE,NULL,rep(1L,5),6L,8L)
y<-anon_step(z$next_population,rep(TRUE,4),TRUE,2L,rep(1L,4),z$next_id,8L)
stopifnot(!(6L %in% y$current_operating_ids),6L %in% y$next_population$id,
 !(1L %in% y$next_population$id),y$next_id==7L)
beta<-0.95^(1/12)
stopifnot(abs(beta^12-.95)<1e-12,anon_entry_option(-1,10)$probability==0,
 anon_entry_option(2,10)$waiting_value==0,
 abs(anon_entry_value(1:8,t$G,beta)-beta*sum((1:8)*t$G))<1e-12)
# Independent numerical integration of the one-shot entry expected payoff.
B<-7;mu<-3
ref<-integrate(function(x)(B-x)*dexp(x,rate=1/mu),0,B)$value
stopifnot(abs(anon_entry_option(B,mu)$value-ref)<1e-10)
calls<-0L
mock<-function(delta_F,M,warm_start) {
 calls<<-calls+1L
 list(converged=TRUE,delta_F=delta_F,M=M)
}
f<-anon_fringe_solutions(c(-7,-6,-7),100,mock)
stopifnot(calls==2L,identical(f$month_solution,c(1L,2L,1L)))
fails(anon_fringe_solutions(-7,100,function(...)list(converged=FALSE)))
cat("PASS: anonymous types, MC persistence, independent entry draws, multiset states,\n",
 "exhaustive cap/exit/entry timing, lifetime IDs, entry integration, discounting, fringe dispatch.\n")
