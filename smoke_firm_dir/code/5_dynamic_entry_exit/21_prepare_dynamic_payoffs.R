source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table);setDTthreads(2)
root<-file.path(OUT_DIR,"dynamic_entry_exit")
files<-c(file.path(root,"january_fringe_benchmark_2026-11-06/fixed_focal_supply_inputs.rds"),file.path(root,"independent_transitions_2026-11-03/transition_inputs.rds"),file.path(root,"entrant_quality_2026-11-04/entrant_initial_state_distribution.csv"))
hashes<-tools::md5sum(files);x<-readRDS(files[1]);tr<-readRDS(files[2]);G<-fread(files[3])[order(state)]
brands<-c("BLU","MISTIC","NJOY","JUUL","VUSE")
cost<-x$constant_costs$mc_constant[match(brands,x$constant_costs$brand)]
grid<-tr$grid[order(state)]
s<-as.matrix(expand.grid(rep(list(0:9),5)))
a<-s>0;p<-matrix(0,nrow(s),5);v<-p
for(i in 1:5) {p[a[,i],i]<-cost[i]+1;v[a[,i],i]<-x$intercept+x$beta_a*grid$quality[s[a[,i],i]]+grid$xi[s[a[,i],i]]}
# Fully explicit vectorized damped markup iteration across independent static markets.
shares<-function(p) {
 u<-(v+x$alpha*p)/(1-x$sigma);u[!a]<- -Inf
 uf<-x$delta_F_constant/(1-x$sigma)
 mx<-pmax(uf,u[,1],u[,2],u[,3],u[,4],u[,5])
 w<-exp(u-mx);wf<-exp(uf-mx);den<-rowSums(w)+wf
 within<-w/den;inclusive<-(1-x$sigma)*(mx+log(den));sg<-plogis(inclusive)
 list(share=within*sg,within=within,fringe=wf/den*sg,outside=plogis(-inclusive))
}
for(it in 1:2000) {
 sh<-shares(p);A<-1/(1-x$sigma)-x$sigma/(1-x$sigma)*sh$within-sh$share
 target<-sweep(-1/(x$alpha*A),2,cost,'+');target[!a]<-0
 pp<-.5*p+.5*target;step<-max(abs(pp-p));p<-pp
 if(step<1e-11)break
}
sh<-shares(p);A<-1/(1-x$sigma)-x$sigma/(1-x$sigma)*sh$within-sh$share
target<-sweep(-1/(x$alpha*A),2,cost,'+');target[!a]<-0
M<-x$markets[month==min(x$markets$month),M]
profit<-sweep(p,2,cost,'-')*sh$share*M;profit[!a]<-0
foc<-1+sweep(p,2,cost,'-')*x$alpha*A
stopifnot(it<2000,max(abs(target-p))<1e-9,max(abs(foc[a]))<1e-8,max(abs(rowSums(sh$share)+sh$fringe+sh$outside-1))<1e-12)
source(file.path(CODE_DIR,"4_static_pricing_subgame/1_static_demand_functions.R"));source(file.path(CODE_DIR,"4_static_pricing_subgame/4_manual_pricing_functions.R"))
# Deterministic independent scalar checks over sparse/full/extreme markets.
ids<-unique(c(1L,2L,10L,100L,10000L,100000L,seq(1500L,98500L,length.out=40)))
errs<-numeric()
for(r in ids) {
 on<-which(a[r,]);if(!length(on))next
 q<-manual_price_fixed_point(cost[on],v[r,on],x$delta_F_constant,x$alpha,x$sigma,cost[on]+.1)
 stopifnot(q$converged);errs<-c(errs,max(abs(q$prices-p[r,on])))
 for(ii in seq_along(on)) {br<-manual_unilateral_best_response(ii,p[r,on],cost[on],v[r,on],x$delta_F_constant,x$alpha,x$sigma);stopifnot(abs(br$price-p[r,on[ii]])<1e-8)}
}
stopifnot(max(errs)<1e-8,identical(unname(hashes),unname(tools::md5sum(files))))
out<-file.path(root,"manual_dynamic_trial_2026-11-06");dir.create(out,recursive=TRUE,showWarnings=FALSE)
saveRDS(list(states=s,prices=p,profits=profit,brands=brands,costs=cost,M=M,fringe=x$delta_F_constant,P=tr$P_joint,G=G$probability,quality_grid=grid,static_iterations=it),file.path(out,"static_payoff_cache.rds"))
fwrite(data.table(check=c("static_markets","iterations","map_residual","scaled_FOC","independent_price_error"),value=c(nrow(s),it,max(abs(target-p)),max(abs(foc[a])),max(errs))),file.path(out,"static_validation.csv"))
fwrite(data.table(path=files,md5=unname(hashes)),file.path(out,"input_hashes.csv"))
cat('Prepared',nrow(s),'static markets in',it,'iterations; independent max error',max(errs),'\n')
