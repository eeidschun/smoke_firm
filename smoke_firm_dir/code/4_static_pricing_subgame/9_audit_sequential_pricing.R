## Compare sequential markup/best-response methods against saved simultaneous solves.
source('smoke_firm_dir/code/fxns/1_paths.R')
for(script in c('1_static_demand_functions.R','4_manual_pricing_functions.R','8_sequential_pricing_functions.R'))source(file.path(CODE_DIR,'4_static_pricing_subgame',script))
suppressPackageStartupMessages({library(data.table);library(ggplot2)});setDTthreads(2)
parent<-file.path(OUT_DIR,'static_pricing_subgame','manual_fixed_point_2026-10-28')
out<-file.path(parent,'audit','sequential_checks_2026-11-02');dir.create(out,recursive=TRUE,showWarnings=FALSE)
inputs<-c(file.path(OUT_DIR,'static_pricing_subgame','observed_recovery_2026-10-27','observed_market_inputs.rds'),file.path(parent,'monthly_price_solutions.csv'))
hashes<-tools::md5sum(inputs);z<-readRDS(inputs[1]);ref<-fread(inputs[2]);ref[,month:=as.Date(month)]
x<-as.data.table(z$incumbents);m<-as.data.table(z$markets)
runs<-traces<-solutions<-list();num<-0L
configs<-data.table(method=c('markup','markup','best_response'),damping=c(.5,1,1))
for(mo in unique(x$month)){
 d<-x[month==mo];setorder(d,brand);base<-ref[month==mo];setorder(base,brand)
 stopifnot(identical(d$brand,base$brand));n<-nrow(d);f<-m[month==mo,delta_F]
 starts<-list(cost_plus_0.1=d$mc+.1,cost_plus_1=d$mc+1,cost_plus_5=d$mc+5,heterogeneous=d$mc+.2+2*seq_len(n)/n)
 orders<-list(alphabetical=seq_len(n),reverse=rev(seq_len(n)))
 for(start in names(starts))for(ordername in names(orders))for(j in seq_len(nrow(configs))){
  method<-configs$method[j];damping<-configs$damping[j];num<-num+1L
  fit<-manual_sequential_prices(d$mc,d$nonprice_utility,f,z$alpha,z$sigma,starts[[start]],method,orders[[ordername]],damping)
  # Independent unilateral check at final price vector, not just within-sweep FOCs.
  br<-if(fit$converged)lapply(seq_len(n),function(i)manual_unilateral_best_response(i,fit$prices,d$mc,d$nonprice_utility,f,z$alpha,z$sigma))else NULL
  gap<-gain<-NA_real_
  if(length(br)){
   gap<-max(abs(vapply(br,function(a)a$price,numeric(1))-fit$prices))
   current<-(fit$prices-d$mc)*d$M*fit$shares$share
   profit<-vapply(br,function(a)a$profit_per_market,numeric(1))*d$M
   gain<-max((profit-current)/pmax(1,abs(current)))
  }
  meta<-data.table(run_id=num,month=as.Date(mo,origin='1970-01-01'),method,damping,start,order=ordername,n_firms=n)
  runs[[num]]<-cbind(meta,data.table(converged=fit$converged,sweeps=fit$sweeps,firm_updates=fit$firm_updates,
   bisection_iterations=fit$bisection_iterations,max_step=fit$step,price_residual=fit$price_residual,scaled_foc=fit$scaled_foc,
   max_gap_simultaneous=max(abs(fit$prices-base$solved_price)),max_gap_observed=max(abs(fit$prices-d$price)),
   best_response_gap=gap,max_relative_profit_gain=gain))
  traces[[num]]<-cbind(meta,as.data.table(fit$trace))
  # Save all final vectors so cross-method agreement can be checked externally.
  solutions[[num]]<-data.table(run_id=num,month=as.Date(mo,origin='1970-01-01'),brand=d$brand,method,damping,start,order=ordername,
   solved_price=fit$prices,simultaneous_price=base$solved_price,observed_price=d$price,converged=fit$converged)
 }
 cat('Completed month',as.character(as.Date(mo,origin='1970-01-01')),'; runs',num,'\n')
}
r<-rbindlist(runs);t<-rbindlist(traces);s<-rbindlist(solutions)
fwrite(r,file.path(out,'solver_runs.csv'));fwrite(t,file.path(out,'sweep_traces.csv'));fwrite(s,file.path(out,'final_prices_all_runs.csv'))
summary<-r[,.(runs=.N,converged=sum(converged),median_sweeps=median(sweeps),max_sweeps=max(sweeps),
 max_gap_simultaneous=max(max_gap_simultaneous),max_price_residual=max(price_residual),max_scaled_foc=max(scaled_foc),
 max_best_response_gap=max(best_response_gap),max_relative_profit_gain=max(max_relative_profit_gain)),by=.(method,damping,order)]
fwrite(summary,file.path(out,'comparison_summary.csv'))
stopifnot(nrow(r)==3168,all(r$converged),max(r$max_gap_simultaneous)<1e-7,
 max(r$best_response_gap)<1e-7,max(r$max_relative_profit_gain)<1e-9)
# Unit checks: one sweep actually uses newly updated prices.
mc<-c(1,1.5);v<-c(-1,-.5);f<--2;a<--.4;sig<-.6;p0<-mc+5
expected<-p0
for(i in 1:2)expected[i]<-manual_price_metrics(expected,mc,v,f,a,sig)$target[i]
one<-manual_sequential_prices(mc,v,f,a,sig,p0,'markup',1:2,1,max_sweeps=1)
stopifnot(max(abs(one$prices-expected))<1e-12,!one$converged)
# One-firm sequential markup equals simultaneous markup with same damping.
seq1<-manual_sequential_prices(1,-1,-2,a,sig,4,'markup',1L,.5)
sim1<-manual_price_fixed_point(1,-1,-2,a,sig,4,.5)
stopifnot(seq1$converged,sim1$converged,abs(seq1$prices-sim1$prices)<1e-12)
# Relabel firms and reverse their order consistently: same numerical path/result.
a1<-manual_sequential_prices(mc,v,f,a,sig,p0,'best_response',1:2)
a2<-manual_sequential_prices(rev(mc),rev(v),f,a,sig,rev(p0),'best_response',2:1)
stopifnot(a1$converged,a2$converged,max(abs(a1$prices-rev(a2$prices)))<1e-9)
# Plot distribution of full-sweep counts (each sweep updates every firm once).
r[,algorithm:=paste(method,'damping',damping)]
p1<-ggplot(r,aes(algorithm,sweeps,fill=order))+geom_boxplot(outlier.size=.5)+scale_y_log10()+
 labs(title='Sequential algorithms: convergence across all months and starts',subtitle='A sweep updates all firms once; best responses also require inner bisection steps.',x=NULL,y='Full sweeps (log scale)',fill='Firm order')+theme_bw()+theme(legend.position='bottom')
p2<-ggplot(r,aes(month,pmax(max_gap_simultaneous,1e-16),color=order))+geom_point(size=.5,alpha=.4)+scale_y_log10()+facet_wrap(~algorithm)+
 labs(title='Sequential minus simultaneous solution: maximum price gap',subtitle='Each point is a month / starting-price vector. Numerical agreement does not prove uniqueness.',x=NULL,y='Maximum absolute price gap (real dollars/mL)',color='Firm order')+theme_bw()+theme(legend.position='bottom')
selected<-sort(unique(c(min(x$month),r[which.max(sweeps),month],as.Date('2013-02-01'))))
q<-t[start=='cost_plus_1' & month%in%selected];q[,algorithm:=paste(method,'damping',damping)]
p3<-ggplot(q,aes(sweep,pmax(price_residual,1e-16),color=algorithm,linetype=order))+geom_line()+scale_y_log10()+facet_wrap(~month,scales='free_x')+
 labs(title='Sequential convergence from marginal cost + $1/mL',subtitle='Residuals evaluated after complete sweeps, with all firms checked at the same final vector.',x='Full sweep',y='Undamped map residual (log scale)',color='Algorithm',linetype='Order')+theme_bw()+theme(legend.position='bottom')
plots<-list(iteration_comparison=p1,solution_agreement=p2,convergence_selected_months=p3)
for(name in names(plots)){
 ggsave(file.path(out,paste0(name,'.pdf')),plots[[name]],width=12,height=7)
 ggsave(file.path(out,paste0(name,'.png')),plots[[name]],width=12,height=7,dpi=150)
}
pdf(file.path(out,'sequential_pricing_audit.pdf'),width=12,height=8);for(p in plots)print(p);dev.off()
# Combine with the original audit booklet when Poppler's PDF utility is available.
if(nzchar(Sys.which('pdfunite'))){
 base_book<-file.path(parent,'audit','pricing_audit_plots.pdf')
 if(file.exists(base_book)){
  result<-system2(Sys.which('pdfunite'),shQuote(c(base_book,file.path(out,'sequential_pricing_audit.pdf'),file.path(parent,'audit','pricing_audit_plots_with_sequential.pdf'))))
  stopifnot(result==0)
 }
}
stopifnot(identical(hashes,tools::md5sum(inputs)))
fwrite(data.table(path=inputs,md5=unname(hashes)),file.path(out,'input_hashes.csv'))
writeLines(c('Sequential pricing audit, November 2, 2026.',
'Same monthly economic game and recovered states as original simultaneous solver. No changes to demand, costs, fringe, or economic move timing.',
'132 months x four starts x two firm orders x three configurations = 3168 attempts. Orders: alphabetical brand names and reverse. Markup damping .5/1; exact sequential best responses damping1.',
'Gauss-Seidel markup recalculates a single coordinate using the newest vector. Sequential best response finds each coordinate profit maximum by manual bisection. After each FULL sweep all FOCs and map residuals are recomputed together.',
'All three original tolerances and iteration cap2000 retained. Final unilateral best-response checks apply to every converged run, not just a reference start. No black-box solvers or full fitted models.',
'Full-sweep counts do not measure equal computational effort: best responses require inner bisection work. Firm update and bisection-iteration counts are exported.',
'Agreement across tested orders/starts/methods supports numerical robustness, not a proof of joint equilibrium uniqueness or empirical validity.',
'Additional unit checks: explicit one-sweep Gauss-Seidel path, iteration-budget failure, one-firm equivalence, consistent relabeling/order invariance, unchanged original inputs.'),file.path(out,'README.txt'))
writeLines(capture.output(sessionInfo()),file.path(out,'session_info.txt'))
print(summary)
