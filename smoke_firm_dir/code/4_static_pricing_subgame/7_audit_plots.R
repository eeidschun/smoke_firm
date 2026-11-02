## Plot saved pricing diagnostics and one separately labeled numerical stress test.
source('smoke_firm_dir/code/fxns/1_paths.R')
source(file.path(CODE_DIR,'4_static_pricing_subgame','1_static_demand_functions.R'))
source(file.path(CODE_DIR,'4_static_pricing_subgame','4_manual_pricing_functions.R'))
suppressPackageStartupMessages({library(data.table);library(ggplot2)})
setDTthreads(2)
parent<-file.path(OUT_DIR,'static_pricing_subgame','manual_fixed_point_2026-10-28')
out<-file.path(parent,'audit');dir.create(out,recursive=TRUE,showWarnings=FALSE)
paths<-c(file.path(parent,c('monthly_price_solutions.csv','solver_runs.csv','iteration_traces.csv')),
 file.path(OUT_DIR,'static_pricing_subgame','observed_recovery_2026-10-27','observed_market_inputs.rds'))
hashes<-tools::md5sum(paths)
s<-fread(paths[1]);runs<-fread(paths[2]);trace<-fread(paths[3]);z<-readRDS(paths[4])
for(d in list(s,runs,trace))d[,month:=as.Date(month)]
x<-as.data.table(z$incumbents);markets<-as.data.table(z$markets)
plots<-list()
keep<-function(name,p,width=12,height=8){
 p<-p+theme_bw(base_size=11)+theme(legend.position='bottom',plot.title.position='plot')
 ggsave(file.path(out,paste0(name,'.pdf')),p,width=width,height=height)
 ggsave(file.path(out,paste0(name,'.png')),p,width=width,height=height,dpi=160)
 plots[[name]]<<-p
}
a<-melt(s,id.vars=c('brand','month'),measure.vars=c('observed_price','solved_price'),variable.name='series',value.name='price')
keep('01_observed_vs_solved_prices',ggplot(a,aes(month,price,color=series,linetype=series))+
 geom_line(linewidth=.65)+facet_wrap(~brand,ncol=3)+
 scale_color_manual(values=c(observed_price='grey35',solved_price='#D55E00'))+
 scale_linetype_manual(values=c(observed_price='solid',solved_price='dashed'))+
 labs(title='Observed and solved retail prices',subtitle='Lines overlap by construction: costs were inverted from observed prices.',x=NULL,y='Real dollars per mL',color=NULL,linetype=NULL))
s[,price_error:=solved_price-observed_price]
keep('02_price_replication_errors',ggplot(s,aes(month,price_error))+
 geom_hline(yintercept=0,color='grey65')+geom_line(color='#0072B2')+facet_wrap(~brand,ncol=3)+
 labs(title='Solved minus observed price',subtitle='Separate error axis exposes differences hidden by overlapping price lines.',x=NULL,y='Price error (real dollars/mL)'))
a<-melt(s,id.vars=c('brand','month'),measure.vars=c('observed_price','mc','solved_markup'),variable.name='series',value.name='value')
keep('03_price_cost_markup',ggplot(a,aes(month,value,color=series,linetype=series))+
 geom_line(linewidth=.65)+facet_wrap(~brand,ncol=3)+
 scale_color_manual(values=c(observed_price='black',mc='#0072B2',solved_markup='#D55E00'))+
 labs(title='Price, recovered marginal cost, and markup',subtitle='Integrated-channel costs; profits exclude unspecified fixed operating costs.',x=NULL,y='Real dollars per mL',color=NULL,linetype=NULL))
slow<-runs[which.max(iterations),month]
dates<-sort(unique(s$month));selected<-sort(unique(c(dates[1],dates[ceiling(length(dates)/2)],slow)))
fwrite(data.table(month=selected,selection=ifelse(selected==slow,'slowest observed solve',ifelse(selected==dates[1],'first month','middle month'))),file.path(out,'selected_audit_months.csv'))
t<-trace[start=='cost_plus_1' & month%in%selected]
t<-melt(t,id.vars=c('month','damping','iteration'),measure.vars=c('price_residual','scaled_foc'),variable.name='diagnostic',value.name='residual')
keep('04_convergence_selected_months',ggplot(t,aes(iteration,pmax(residual,1e-16),color=factor(damping)))+
 geom_line(linewidth=.6)+scale_y_log10()+facet_grid(diagnostic~month)+
 labs(title='Convergence from marginal cost + $1/mL',subtitle='First, middle, and slowest month. Full undamped iteration path retained.',x='Iteration',y='Residual (log scale)',color='Damping'),14,7)
keep('05_iterations_all_starts',ggplot(runs,aes(month,iterations,color=start))+
 geom_line(linewidth=.5)+scale_y_log10()+facet_wrap(~damping,ncol=1)+
 labs(title='Iteration counts across every starting vector',subtitle='All 1,584 attempts converged; log scale highlights undamped slowdowns.',x=NULL,y='Iterations (log scale)',color='Starting vector'),12,8)
# Profit curves vary only one firm's price, keeping all rivals at their solved prices.
curves<-markers<-list()
for(month0 in selected){
 d<-x[month==month0];setorder(d,brand);base<-s[month==month0];setorder(base,brand)
 f<-markets[month==month0,delta_F];p<-base$solved_price
 for(i in seq_len(nrow(d))){
  br<-manual_unilateral_best_response(i,p,d$mc,d$nonprice_utility,f,z$alpha,z$sigma)
  grid<-sort(unique(c(seq(d$mc[i],d$mc[i]+max(3,5*(p[i]-d$mc[i])),length.out=301),p[i],br$price)))
  profit<-vapply(grid,function(q){trial<-p;trial[i]<-q
   sh<-static_shares(trial,d$nonprice_utility,f,z$alpha,z$sigma)
   (q-d$mc[i])*d$M[i]*sh$share[i]},numeric(1))
  key<-paste(month0,i)
  curves[[key]]<-data.table(month=as.Date(month0,origin='1970-01-01'),brand=d$brand[i],price=grid,profit)
  markers[[key]]<-data.table(month=as.Date(month0,origin='1970-01-01'),brand=d$brand[i],solved_price=p[i],best_response=br$price,mc=d$mc[i])
 }
}
curves<-rbindlist(curves);markers<-rbindlist(markers)
fwrite(curves,file.path(out,'unilateral_profit_curve_values.csv'));fwrite(markers,file.path(out,'unilateral_profit_curve_markers.csv'))
for(month0 in selected){
 date<-as.Date(month0,origin='1970-01-01')
 keep(paste0('06_profit_curves_',date),ggplot(curves[month==date],aes(price,profit/1e6))+
 geom_line(color='#0072B2')+geom_vline(data=markers[month==date],aes(xintercept=solved_price),color='#D55E00',linetype='dashed')+
 geom_vline(data=markers[month==date],aes(xintercept=best_response),color='black',linetype='dotted')+
 facet_wrap(~brand,scales='free',ncol=3)+labs(title=paste('Unilateral variable-profit curves:',date),
 subtitle='Rivals fixed. Orange dashed: solved price; black dotted: manually bisected best response (overlap).',
 x='Own price (real dollars/mL)',y='Monthly variable profit (million real dollars)'),12,8)
}
# Numerical counterfactual, not a new empirical specification: largest-volume firm
# in latest observed month receives +10% effective marginal cost.
month0<-max(x$month);d<-x[month==month0];setorder(d,brand)
base<-s[month==month0];setorder(base,brand);f<-markets[month==month0,delta_F]
target<-which.max(d$q);newmc<-d$mc;newmc[target]<-1.1*newmc[target]
fits<-lapply(c(.1,1,5),function(add)manual_price_fixed_point(newmc,d$nonprice_utility,f,z$alpha,z$sigma,newmc+add,damping=.5))
stopifnot(all(vapply(fits,function(a)a$converged,logical(1))))
fit<-fits[[2]];stopifnot(max(vapply(fits,function(a)max(abs(a$prices-fit$prices)),numeric(1)))<1e-7)
br<-lapply(seq_len(nrow(d)),function(i)manual_unilateral_best_response(i,fit$prices,newmc,d$nonprice_utility,f,z$alpha,z$sigma))
stopifnot(max(abs(vapply(br,function(b)b$price,numeric(1))-fit$prices))<1e-7)
cf<-data.table(month=month0,brand=d$brand,treated=seq_len(nrow(d))==target,base_mc=d$mc,new_mc=newmc,
 base_price=base$solved_price,new_price=fit$prices,price_change=fit$prices-base$solved_price,
 mc_change=newmc-d$mc,base_share=base$solved_share,new_share=fit$shares$share,
 pass_through=ifelse(seq_len(nrow(d))==target,(fit$prices-base$solved_price)/(newmc-d$mc),NA_real_))
fwrite(cf,file.path(out,'numerical_cost_perturbation.csv'))
keep('07_numerical_cost_perturbation',ggplot(cf,aes(brand,price_change,fill=treated))+
 geom_col()+geom_hline(yintercept=0)+scale_fill_manual(values=c('FALSE'='grey65','TRUE'='#D55E00'))+
 labs(title=paste('Numerical cost perturbation:',d$brand[target],format(month0,'%Y-%m')),
 subtitle='Largest-volume firm in latest month: effective marginal cost +10%; demand states and fringe utility fixed.',
 x=NULL,y='Equilibrium price change (real dollars/mL)',fill='Cost increased'),10,6)
pdf(file.path(out,'pricing_audit_plots.pdf'),width=13,height=9,onefile=TRUE)
for(p in plots)print(p)
dev.off()
stopifnot(identical(hashes,tools::md5sum(paths)))
fwrite(data.table(path=paths,md5=unname(hashes)),file.path(out,'input_hashes.csv'))
writeLines(c('# Pricing audit plots','',
'Run: Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/7_audit_plots.R','',
'Open pricing_audit_plots.pdf for the complete booklet. Each figure also has standalone PDF and PNG versions.','',
'01: observed vs solved firm prices. Exact overlap is expected from inverted costs; it is not empirical validation.',
'02: price-error time series on a separate numerical-error axis.',
'03: price, recovered effective marginal cost, and markup. Integrated-channel objects, not separately observed production costs.',
'04: map and FOC residuals for first, middle and slowest month, cost+1 initialization, all damping values.',
'05: iteration counts for every start and damping across all 132 months.',
'06: unilateral profit curves for every incumbent in selected months. Rivals fixed; solved price and manually bisected optimum should coincide. The plotted grid is illustrative; bisection checks use the full above-cost domain via bracketing.',
'07: separate numerical counterfactual, not a fitted result. Largest-volume firm in latest month gets a 10% cost increase. Three starting vectors converge to the same solution, with manually verified unilateral best responses.',
'CSV files give curve points, selected markets, markers and cost-perturbation results. Existing recovery and equilibrium inputs unchanged.'),file.path(out,'README.md'))
print(cf)
