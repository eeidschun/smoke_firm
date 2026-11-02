## Manual fixed-point replication of observed monthly incumbent pricing.
source('smoke_firm_dir/code/fxns/1_paths.R')
source(file.path(CODE_DIR,'4_static_pricing_subgame','1_static_demand_functions.R'))
source(file.path(CODE_DIR,'4_static_pricing_subgame','4_manual_pricing_functions.R'))
suppressPackageStartupMessages(library(data.table));setDTthreads(2)
input<-file.path(OUT_DIR,'static_pricing_subgame','observed_recovery_2026-10-27','observed_market_inputs.rds')
input_hash<-tools::md5sum(input);z<-readRDS(input)
d<-as.data.table(z$incumbents);markets<-as.data.table(z$markets)
out<-file.path(OUT_DIR,'static_pricing_subgame','manual_fixed_point_2026-10-28')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
alpha<-z$alpha;sigma<-z$sigma
runs<-traces<-solutions<-deviations<-list();saved<-list()
for(month0 in unique(d$month)){
 x<-d[month==month0];setorder(x,brand);f<-markets[month==month0,delta_F]
 mc<-x$mc;v<-x$nonprice_utility;n<-nrow(x)
 starts<-list(cost_plus_0.1=mc+.1,cost_plus_1=mc+1,cost_plus_5=mc+5,
              heterogeneous=mc+.2+2*seq_len(n)/n)
 monthly<-list()
 for(start in names(starts))for(damping in c(.25,.5,1)){
  key<-paste(month0,start,damping,sep='_')
  fit<-manual_price_fixed_point(mc,v,f,alpha,sigma,starts[[start]],damping)
  runs[[key]]<-data.table(month=as.Date(month0,origin='1970-01-01'),start,damping,n_firms=n,
   converged=fit$converged,iterations=fit$iterations,max_step=fit$step,
   price_residual=fit$price_residual,scaled_foc=fit$scaled_foc,
   observed_price_error=max(abs(fit$prices-x$price)))
  # Trace every step for transparent convergence/cycling diagnostics.
  traces[[key]]<-cbind(data.table(month=as.Date(month0,origin='1970-01-01'),start,damping),as.data.table(fit$trace))
  monthly[[paste(start,damping)]]<-fit
 }
 # A fixed, predeclared reference run, not selected by closeness to observations.
 reference<-monthly[['cost_plus_1 0.5']]
 stopifnot(reference$converged)
 p<-reference$prices;s<-reference$shares
 solutions[[as.character(month0)]]<-data.table(brand=x$brand,month=x$month,
  in_estimation_sample=x$in_estimation_sample,observed_price=x$price,solved_price=p,mc,
  solved_markup=p-mc,observed_share=x$share,solved_share=s$share,
  solved_q=x$M*s$share,observed_q=x$q,
  solved_variable_profit=(p-mc)*x$M*s$share,observed_variable_profit=x$variable_profit,
  fringe_share=s$fringe_share,outside_share=s$outside_share)
 for(i in seq_len(n)){
  br<-manual_unilateral_best_response(i,p,mc,v,f,alpha,sigma)
  current<-(p[i]-mc[i])*s$share[i]*x$M[i]
  gain<-br$profit_per_market*x$M[i]-current
  deviations[[paste(month0,i)]]<-data.table(brand=x$brand[i],month=x$month[i],solved_price=p[i],
   best_response_price=br$price,best_response_price_gap=abs(br$price-p[i]),
   current_variable_profit=current,best_response_variable_profit=br$profit_per_market*x$M[i],
   profit_gain=gain,relative_profit_gain=gain/max(1,abs(current)),best_response_foc=br$foc)
 }
 saved[[as.character(month0)]]<-monthly
 cat('Completed',as.character(as.Date(month0,origin='1970-01-01')),'\n')
}
r<-rbindlist(runs);s<-rbindlist(solutions);dev<-rbindlist(deviations)
fwrite(r,file.path(out,'solver_runs.csv'));fwrite(rbindlist(traces),file.path(out,'iteration_traces.csv'))
fwrite(s,file.path(out,'monthly_price_solutions.csv'));fwrite(dev,file.path(out,'unilateral_deviation_checks.csv'))
summary<-r[,.(runs=.N,converged=sum(converged),max_iterations=max(iterations),
 max_converged_price_residual=if(any(converged))max(price_residual[converged])else NA_real_,
 max_converged_observed_price_error=if(any(converged))max(observed_price_error[converged])else NA_real_),by=.(start,damping)]
fwrite(summary,file.path(out,'convergence_summary.csv'))
saveRDS(list(chosen_fit=z$id,alpha,sigma,runs=r,solutions=s,deviations=dev,by_month=saved),file.path(out,'pricing_results.rds'))
stopifnot(nrow(r)==132*12,nrow(s)==540,nrow(dev)==540,
 max(abs(s$solved_price-s$observed_price))<1e-7,max(abs(s$solved_q/s$observed_q-1))<1e-7,
 max(dev$best_response_price_gap)<1e-7,max(dev$relative_profit_gain)<1e-9,
 identical(input_hash,tools::md5sum(input)))
fwrite(data.table(path=input,md5=unname(input_hash)),file.path(out,'input_hashes.csv'))
writeLines(c('Manual monthly pricing fixed point, 2026-10-28.',
'132 observed monthly markets; full 540 incumbent rows including flagged 12 out-of-demand-sample BLU 2018 observations.',
'4 independent starting vectors x 3 damping values = 1584 attempts. No observed prices used to initialize or select reference solution.',
'Reference fixed in advance: cost+1 start, damping 0.5. Costs and nonprice utility fixed; passive fringe utility fixed but its share varies.',
'No black-box optimization/root/equilibrium solver. Simultaneous damped markup substitution with step, map-residual and scaled-FOC stopping checks.',
'Unilateral best responses checked using explicitly coded bracketing/bisection, with rivals held fixed.',
'For pi>=mc, g=1+alpha*(pi-mc)*A is strictly decreasing because A>0 and dA/dpi>0. Unique zero maximizes single-product variable profit; below-cost profits <=0 and profit tends to zero at infinity.',
'Deviation check supports numerical Nash optimality under this maintained one-product-per-brand passive-fringe game. It is not a proof of uniqueness of the multi-firm equilibrium.',
'Observed-price replication follows from inverted costs/demand; it validates numerical implementation, not demand identification or empirical supply validity.',
'No fixed operating costs, transitions, investment, entry/exit or manufacturer/retailer separation introduced. All original recovery inputs unchanged.'),file.path(out,'interpretation.txt'))
writeLines(capture.output(sessionInfo()),file.path(out,'session_info.txt'))
print(summary);print(dev[,.(max_price_gap=max(best_response_price_gap),max_profit_gain=max(profit_gain),max_relative_gain=max(relative_profit_gain))])
