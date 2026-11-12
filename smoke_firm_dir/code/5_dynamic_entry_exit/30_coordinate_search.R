# Coarse coordinate calibration, conditional on stationary January-2013 primitives.
source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
library(data.table)
base<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06")
out<-file.path(OUT_DIR,"dynamic_entry_exit/coordinate_search_2026-11-06")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
x<-readRDS(file.path(base,"static_payoff_cache.rds"));g<-build_dynamic_geometry(x$P,x$G)
codes<-g$states;codes[codes>9]<-0
profits<-x$profits[as.integer(1+as.vector(codes%*%10^(0:4))),,drop=FALSE]
initial<-fread(file.path(base,"initial_state_results.csv"))$state
life<-fread(file.path(OUT_DIR,"dynamic_entry_exit/entry_exit_candidates_2026-11-04/incumbent_brand_lifecycles.csv"))[match(x$brands,brand)]
dates<-seq(as.Date("2013-01-01"),by="month",length.out=132)
obs<-sapply(1:5,function(i)as.numeric(dates>=life$first_observed_sales[i]&dates<=life$last_observed_sales[i]))
obsentry<-sapply(4:5,function(i)as.numeric(dates>=life$first_observed_sales[i]))
N<-2000L;set.seed(6112026)
# Fixed-shape common random numbers: draws do not shift when eligibility changes.
Uexit<-array(runif(N*132*5),c(N,132,5));Uentry<-array(runif(N*132*5),c(N,132,5));Uquality<-array(runif(N*132*5),c(N,132,5))
cP<-t(apply(x$P,1,cumsum));cG<-cumsum(x$G)
score<-function(sol,save_prefix=NULL){
 s<-matrix(rep(initial,each=N),N,5);ever<-s>=1&s<=9
 active_mean<-entered_mean<-matrix(0,132,5);count_mean<-numeric(132)
 for(t in 1:132){
  active<-s>=1&s<=9;id<-as.integer(1+as.vector(s%*%c(1,10,100,1000,11000)))
  active_mean[t,]<-colMeans(active);entered_mean[t,]<-colMeans(ever);count_mean[t]<-mean(rowSums(active))
  for(i in 1:5){
   a<-which(active[,i]);u<-if(i>3)which(s[,i]==0) else integer()
   if(length(a)){
    # Equivalent to independent normal-scrap threshold draws.
    exit<-Uexit[a,t,i]>sol$policy[id[a],i]
    keep<-a[!exit];dead<-a[exit]
    if(length(keep))s[keep,i]<-1L+rowSums(matrix(Uquality[keep,t,i],length(keep),9)>cP[s[keep,i],,drop=FALSE])
    s[dead,i]<-if(i<=3)0L else 10L
   }
   if(length(u)){
    enter<-u[Uentry[u,t,i]<sol$policy[id[u],i]]
    if(length(enter)){s[enter,i]<-1L+rowSums(matrix(Uquality[enter,t,i],length(enter),9)>matrix(cG,length(enter),9,byrow=TRUE));ever[enter,i]<-TRUE}
   }
  }
 }
 # Equal weight to three groups, each on a [0,1] scale.
 components<-c(entry=mean((entered_mean[,4:5]-obsentry)^2),survival=mean((active_mean[,1:3]-obs[,1:3])^2),count=mean(((count_mean-rowSums(obs))/5)^2))
 if(!is.null(save_prefix)){
  fwrite(data.table(month=rep(dates,5),brand=rep(x$brands,each=132),active=as.vector(active_mean),ever_entered=as.vector(entered_mean),observed=as.vector(obs)),file.path(out,paste0(save_prefix,"_monthly.csv")))
  fwrite(data.table(month=dates,simulated=count_mean,observed=rowSums(obs)),file.path(out,paste0(save_prefix,"_counts.csv")))
 }
 c(loss=mean(components),components)
}
solve_candidate<-function(pars,start){
 V<-start$V;p<-start$policy;Fs<-Rs<-list();accepted<-0L
 br<-function(V,p)do.call(dynamic_best_response,c(list(V=V,policy=p,profits=profits,geometry=g),pars))
 metric<-function(b,V,p)c(max(abs(b$V-V)/pmax(1,abs(V),abs(b$V))),max(abs(b$policy-p)))
 b<-br(V,p);trace<-list();ok<-FALSE
 for(it in 1:4000){
  r<-metric(b,V,p);trace[[it]]<-c(iteration=it,value=r[1],policy=r[2])
  if(it%%100==0){cat(" iteration",it,"residuals",format(r,digits=3),"accepted",accepted,"\n");flush.console()}
  if(r[1]<1e-6 && r[2]<1e-7){ok<-TRUE;break}
  Fs<-tail(c(Fs,list(b$V)),4);Rs<-tail(c(Rs,list(b$V-V)),4)
  vn<-.3*V+.7*b$V;pn<-.3*p+.7*b$policy;candidate<-NULL;used<-FALSE
  if(length(Rs)>1){
   R<-do.call(cbind,lapply(Rs,as.vector));sc<-max(abs(R))
   if(sc>0){H<-crossprod(R/sc);w<-tryCatch(solve(H+diag(1e-10*max(diag(H)),nrow(H)),rep(1,nrow(H))),error=function(e)NULL)
    if(!is.null(w)&&abs(sum(w))>1e-12){w<-w/sum(w);if(max(abs(w))<1000)candidate<-Reduce('+',Map(function(F,c)F*c,Fs,as.list(w)))}}
  }
  if(!is.null(candidate)&&all(is.finite(candidate))){cb<-br(candidate,pn);cr<-metric(cb,candidate,pn)
   if(cr[1]<r[1]&&cr[2]<max(10*r[2],1e-3)){V<-candidate;p<-pn;b<-cb;used<-TRUE;accepted<-accepted+1L}}
  if(!used){V<-vn;p<-pn;b<-br(V,p)}
 }
 # Fresh residual evaluation before any candidate can be scored.
 b<-br(V,p);r<-metric(b,V,p);ok<-r[1]<1e-6&&r[2]<1e-7
 list(V=V,policy=p,parameters=pars,converged=ok,iterations=it,residual=r,trace=do.call(rbind,trace))
}
key<-function(p)paste(p$FC,p$mu_E,p$sigma_S,sep="_")
cache<-new.env();rows<-list();path<-list();baseline<-readRDS(file.path(base,"dynamic_trial_solution.rds"))
initial_score<-score(baseline,"baseline");assign(key(baseline$parameters),list(sol=baseline,fit=initial_score),cache)
best<-baseline;bestfit<-initial_score
rows[[1]]<-data.table(candidate_id=key(best$parameters),FC=best$parameters$FC,mu_E=best$parameters$mu_E,sigma_S=best$parameters$sigma_S,converged=TRUE,iterations=0,value_residual=NA_real_,policy_residual=NA_real_,loss=initial_score[1],entry=initial_score[2],survival=initial_score[3],count=initial_score[4])
grids<-list(FC=c(0,1e5,3e5),mu_E=c(3e7,1e8,3e8),sigma_S=c(1e6,5e6,1.5e7))
writeLines(c("Provisional stationary coordinate search; not formal estimation.","Two passes maximum, stop after a pass with no change. Order FC, mean entry cost, scrap SD.","Grids: FC={0,100000,300000}; mean entry={30000000,100000000,300000000}; scrap SD={1000000,5000000,15000000}.","Loss: equally weighted monthly mean squared errors for two entrant cumulative-entry curves, three initial incumbent survival curves, and active-count/5.","Observed first/last full-scanner sales define event spells; initial brands left censored, final-month sales right censored.","2000 common-random-number paths, seed6112026; January2013 M/fringe fixed. Monthly beta=.95^(1/12), net scrap mean=0.","Each candidate re-solves all121000 dynamic states. Nonconverged candidates are excluded. Warm starts may select equilibrium branches; no uniqueness/global optimum or identification claim.","Grid endpoint choices indicate sensitivity and do not establish a parameter bound."),file.path(out,"README.txt"))
for(pass in 1:2){
 oldkey<-key(best$parameters)
 for(coord in names(grids)){
  anchor<-best;choice<-best;choicefit<-bestfit
  for(value in grids[[coord]]){
   pars<-anchor$parameters;pars[[coord]]<-value;k<-key(pars)
   cat("Pass",pass,coord,value,"\n");flush.console()
   if(exists(k,cache,inherits=FALSE)){item<-get(k,cache);sol<-item$sol;fit<-item$fit}else{
    sol<-solve_candidate(pars,anchor);fit<-if(sol$converged)score(sol) else rep(Inf,4)
    assign(k,list(sol=sol,fit=fit),cache)
    rows[[length(rows)+1]]<-data.table(candidate_id=k,FC=pars$FC,mu_E=pars$mu_E,sigma_S=pars$sigma_S,converged=sol$converged,iterations=sol$iterations,value_residual=sol$residual[1],policy_residual=sol$residual[2],loss=fit[1],entry=fit[2],survival=fit[3],count=fit[4])
    fwrite(as.data.table(sol$trace),file.path(out,paste0("trace_",k,".csv")))
    fwrite(rbindlist(rows),file.path(out,"candidate_scores.csv"))
   }
   cat(" score",fit[1],"converged",sol$converged,"\n");flush.console()
   if(fit[1]<choicefit[1]){choice<-sol;choicefit<-fit}
  }
  best<-choice;bestfit<-choicefit
  path[[length(path)+1]]<-data.table(pass=pass,coordinate=coord,FC=best$parameters$FC,mu_E=best$parameters$mu_E,sigma_S=best$parameters$sigma_S,loss=bestfit[1])
  fwrite(rbindlist(path),file.path(out,"coordinate_path.csv"));saveRDS(best,file.path(out,"selected_solution.rds"))
 }
 if(key(best$parameters)==oldkey)break
}
fwrite(rbindlist(rows),file.path(out,"candidate_scores.csv"));score(best,"selected")
cat("SELECTED",key(best$parameters),"loss",bestfit,"baseline",initial_score,"\n")
