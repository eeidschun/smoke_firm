## Validate saved solves, own-profit curvature, edge behavior, and invariance.
source('smoke_firm_dir/code/fxns/1_paths.R')
source(file.path(CODE_DIR,'4_static_pricing_subgame','1_static_demand_functions.R'))
source(file.path(CODE_DIR,'4_static_pricing_subgame','4_manual_pricing_functions.R'))
suppressPackageStartupMessages(library(data.table))
out<-file.path(OUT_DIR,'static_pricing_subgame','manual_fixed_point_2026-10-28')
r<-readRDS(file.path(out,'pricing_results.rds'));s<-as.data.table(r$solutions);runs<-as.data.table(r$runs)
z<-readRDS(file.path(OUT_DIR,'static_pricing_subgame','observed_recovery_2026-10-27','observed_market_inputs.rds'))
x<-as.data.table(z$incumbents);m<-as.data.table(z$markets)
stopifnot(nrow(runs)==1584,all(runs$converged),nrow(s)==540,all(s$solved_price>s$mc),
 max(runs$observed_price_error)<1e-7,all(runs$price_residual<1e-9),all(runs$scaled_foc<1e-8))
curvature<-list()
for(month0 in unique(x$month)){
 d<-x[month==month0];setorder(d,brand);f<-m[month==month0,delta_F]
 sol<-s[month==month0];setorder(sol,brand);p<-sol$solved_price
 sh<-static_shares(p,d$nonprice_utility,f,z$alpha,z$sigma)
 wprime<-z$alpha/(1-z$sigma)*sh$within*(1-sh$within)
 sprime<-static_own_derivative(sh$share,sh$within,z$alpha,z$sigma)
 Aprime<--z$sigma/(1-z$sigma)*wprime-sprime
 A<-1/(1-z$sigma)-z$sigma*sh$within/(1-z$sigma)-sh$share
 gprime<-z$alpha*(A+(p-d$mc)*Aprime)
 curvature[[as.character(month0)]]<-data.table(brand=d$brand,month=d$month,A_prime=Aprime,FOC_factor_slope=gprime)
 stopifnot(all(Aprime>0),all(gprime<0),abs(sum(sh$share)+sh$fringe_share+sh$outside_share-1)<1e-12)
}
c<-rbindlist(curvature);fwrite(c,file.path(out,'own_profit_curvature_checks.csv'))
# Synthetic game: permutation invariance and explicit failure on a too-small budget.
mc<-c(1,1.5);v<-c(-1,-.5);f<--2;a<--.4;sig<-.6
fit<-manual_price_fixed_point(mc,v,f,a,sig,mc+1)
perm<-manual_price_fixed_point(rev(mc),rev(v),f,a,sig,rev(mc)+1)
stopifnot(fit$converged,perm$converged,max(abs(fit$prices-rev(perm$prices)))<1e-10)
short<-manual_price_fixed_point(mc,v,f,a,sig,mc+5,max_iter=1)
stopifnot(!short$converged,short$iterations==1)
# Sigma-zero case: equilibrium remains consistent with manually bisected own optima.
fit0<-manual_price_fixed_point(mc,v,f,a,0,mc+2)
stopifnot(fit0$converged)
for(i in 1:2){
 br<-manual_unilateral_best_response(i,fit0$prices,mc,v,f,a,0)
 stopifnot(abs(br$price-fit0$prices[i])<1e-8)
}
h<-fread(file.path(out,'input_hashes.csv'));stopifnot(all(unname(tools::md5sum(h$path))==h$md5))
fwrite(data.table(check=c('all_runs_converged','observed_price_replication','positive_markups','mass_balance',
 'negative_own_profit_FOC_slope','permutation_invariance','iteration_limit_failure','sigma_zero_best_responses','input_hashes_unchanged'),passed=TRUE),file.path(out,'validation_summary.csv'))
writeLines(c('Saved solves and all 540 own-profit slope checks pass.',
'Permutation invariance, explicit iteration-budget failure, sigma-zero best responses, and immutable inputs pass.',
'No black-box optimizer or root finder used.'),file.path(out,'validation.txt'))
print(runs[,.(runs=.N,min_iterations=min(iterations),median_iterations=median(iterations),max_iterations=max(iterations)),by=damping])
