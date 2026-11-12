source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"4_static_pricing_subgame/1_static_demand_functions.R"))
source(file.path(CODE_DIR,"4_static_pricing_subgame/4_manual_pricing_functions.R"))
library(data.table);setDTthreads(2)
root<-file.path(OUT_DIR,"dynamic_entry_exit")
oldroot<-file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27")
files<-c(file.path(SUPPORT_DIR,"upc_month_niccorr_from_full.RData"),file.path(SUPPORT_DIR,"upc_month_store_breadth.rds"),file.path(oldroot,"fringe_market_recovery.csv"),file.path(oldroot,"selected_coefficients.csv"),file.path(root,"focal_brand_selection_2026-11-05/selected_five_focal_brands.csv"),file.path(oldroot,"incumbent_recovery.csv"),file.path(root,"independent_transitions_2026-11-03/bin_definitions_medians.csv"),file.path(root,"constant_marginal_costs_2026-11-03/incumbent_constant_marginal_costs.csv"))
hashes<-tools::md5sum(files);e<-new.env();load(files[1],e)
u<-as.data.table(e$upc_month_t2);u[,brand:=trimws(brand)]
u<-u[brand!="UNKNOWN" & units_sum>0 & mL_sum>0,.(q=sum(mL_sum),nic=sum(nic_mg_sum),revenue_real=sum(revenue_real)),by=.(brand,month,upc12)]
b<-as.data.table(readRDS(files[2]))[,.(month,upc12,n_stores)]
stopifnot(!anyDuplicated(b[,.(month,upc12)]))
u<-merge(u,b,by=c("month","upc12"),all.x=TRUE);u<-u[!is.na(n_stores)&n_stores>=3]
u[,upc_quality:=nic/q]
focal<-fread(files[5])$brand;stopifnot(length(focal)==5L,!("LOGIC" %in% focal))
coef<-fread(files[4]);cfs<-setNames(coef$estimate,coef$term)
alpha<-unname(cfs['fit_price']);sigma<-unname(cfs['fit_ln_s_i_g']);beta_a<-unname(cfs['a_it']);intercept<-unname(cfs['(Intercept)'])
d<-u[brand %in% focal,.(q=sum(q),revenue_real=sum(revenue_real),quality=mean(upc_quality),upcs=.N),by=.(brand,month)]
d[,price:=revenue_real/q]
f<-u[!(brand %in% focal),.(Q_F=sum(q),R_F=sum(revenue_real),a_F=mean(upc_quality),fringe_brands=uniqueN(brand)),by=month]
f[,p_F:=R_F/Q_F]
oldm<-fread(files[3]);m<-merge(f,oldm[,.(month,M,Q)],by="month")
m<-merge(m,d[,.(Q_focal=sum(q)),by=month],by="month")
stopifnot(nrow(m)==132L,max(abs(m$Q_focal+m$Q_F-m$Q)/m$Q)<1e-10,all(m$Q_F>0))
m[,`:=`(s_F=Q_F/M,s_g=Q/M,s_0=1-Q/M)]
m[,delta_F:=log(s_F/s_0)-sigma*log(s_F/s_g)]
m[,xi_F:=delta_F-intercept-beta_a*a_F-alpha*p_F]
d<-merge(d,m[,.(month,M,Q,s_g,s_0,delta_F)],by="month")
d[,`:=`(share=q/M,within=q/Q)]
d[,delta:=log(share/s_0)-sigma*log(within)]
d[,`:=`(xi=delta-intercept-beta_a*quality-alpha*price,nonprice_utility=delta-alpha*price)]
d[,markup:=static_markup(share,within,alpha,sigma)]
d[,`:=`(mc=price-markup,variable_profit=markup*q)]
old<-fread(files[6]);d<-merge(d,old[,.(brand,month,old_xi=xi,old_mc=mc,in_estimation_sample)],by=c("brand","month"),all.x=TRUE)
d[,in_original_roster:=!is.na(old_xi)]
stopifnot(all(is.finite(d$quality)),all(is.finite(d$mc)),max(abs(d[in_original_roster==TRUE,xi-old_xi]))<1e-10,max(abs(d[in_original_roster==TRUE,mc-old_mc]))<1e-10)
bins<-fread(files[7])
for(v in c("quality","xi")) {
 edges<-bins[variable==v][order(state)]
 cuts<-c(-Inf,edges$upper_edge[1:2],Inf)
 st<-as.integer(cut(d[[v]],cuts,right=TRUE))
 d[,(paste0(v,"_state")):=st]
 d[,(paste0(v,"_representative")):=edges$median[st]]
 d[,(paste0(v,"_outside_old_range")):=d[[v]]<edges$lower_edge[1]|d[[v]]>edges$upper_edge[3]]
}
validation<-list()
for(t in sort(unique(d$month))) {
 z<-d[month==t];sh<-static_shares(z$price,z$nonprice_utility,z$delta_F[1],alpha,sigma)
 target_f<-m[month==t,s_F]
 for(start in c(.1,1)) {
  sol<-manual_price_fixed_point(z$mc,z$nonprice_utility,z$delta_F[1],alpha,sigma,z$mc+start)
  stopifnot(sol$converged)
  validation[[paste(t,start)]]<-data.table(month=as.IDate(t),start_increment=start,n_firms=nrow(z),iterations=sol$iterations,max_price_error=max(abs(sol$prices-z$price)),max_share_error=max(abs(sh$share-z$share)),fringe_share_error=abs(sh$fringe_share-target_f))
 }
}
checks<-rbindlist(validation)
stopifnot(max(checks$max_price_error)<1e-8,max(checks$max_share_error)<1e-12,max(checks$fringe_share_error)<1e-12)
out<-file.path(root,"fixed_focal_supply_2026-11-05");dir.create(out,recursive=TRUE,showWarnings=FALSE)
setorder(d,brand,month);setorder(m,month)
fwrite(d,file.path(out,"focal_observed_recovery.csv"));fwrite(m,file.path(out,"fringe_market_recovery.csv"));fwrite(checks,file.path(out,"pricing_validation.csv"))
summ<-d[,.(observed_months=.N,first_sales=min(month),last_sales=max(month),outside_original_roster=sum(!in_original_roster),negative_costs=sum(mc<0),median_full_history_mc=median(mc),quality_outside_old_bins=sum(quality_outside_old_range),xi_outside_old_bins=sum(xi_outside_old_range)),by=brand]
fwrite(summ,file.path(out,"brand_coverage_summary.csv"))
# Expose missing focal cells without treating zero sales as positive or imputing xi.
coverage<-merge(CJ(brand=focal,month=m$month),d[,.(brand,month,q)],by=c("brand","month"),all.x=TRUE)
coverage[,observed_eligible_sales:=!is.na(q)]
fwrite(coverage,file.path(out,"focal_month_coverage.csv"))
fringe_value<-median(m$delta_F)
fwrite(data.table(delta_F_constant=fringe_value,old_roster_constant=median(oldm$delta_F),months=132),file.path(out,"constant_fringe_utility.csv"))
# Keep previously selected incumbent cost values, do not silently change the estimator window.
fixed_costs<-fread(files[8])[brand %in% focal]
fwrite(fixed_costs,file.path(out,"focal_constant_costs_retained.csv"))
initial<-merge(d[month==min(m$month)],fixed_costs[,.(brand,mc_constant)],by="brand",all.x=TRUE)
fwrite(initial[,.(brand,month,quality,xi,quality_state,xi_state,quality_representative,xi_representative,mc_constant)],file.path(out,"initial_roster.csv"))
saveRDS(list(focal_brands=focal,alpha=alpha,sigma=sigma,beta_a=beta_a,intercept=intercept,observed_focal=d,markets=m,delta_F_constant=fringe_value,initial_roster=initial,constant_costs=fixed_costs,missing_focal_cells=coverage[observed_eligible_sales==FALSE]),file.path(out,"fixed_focal_supply_inputs.rds"))
stopifnot(identical(unname(hashes),unname(tools::md5sum(files))))
fwrite(data.table(path=files,md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Fixed identities: BLU, JUUL, MISTIC, NJOY, VUSE. All remaining brands including LOGIC contribute to passive fringe.","Selected demand coefficients unchanged; eligible identified positive-sales UPC-months in >=3 stores; UPC-unweighted nicotine and revenue/mL prices.","Outside-original-roster residuals recovered by share inversion, not new estimation or independent validation. Within-nest denominator retains whole category volume.","Observed MC recomputed only for diagnostics; original-roster xi and MC reconcile exactly. Previously chosen constant incumbent costs retained.","New constant fringe utility is median of recalibrated fixed-composition residual-fringe utilities, superseding the old changing-roster median for this supply scope.","Original bin cutoffs/medians retained; outside-range values flagged, mapped to endpoint bins with infinite outer cutoffs. No transitions or entrant proxies re-estimated here.","Missing eligible focal observations are explicitly reported; no interpolation, zero-price or xi imputation. Inactivity vs gaps must be resolved before fitting.","264 manual observed-price solves converge from two cost-offset starts. This is conditional replication, not a dynamic solve or model validation.","Entrant identity/cost mapping and dynamic state construction remain pending; canonical inputs and previous audits unchanged."),file.path(out,"README.txt"))
print(summ);cat('New fringe median:',fringe_value,'; initial firms:',paste(initial$brand,collapse=', '),'\n');print(checks[,.(max_price_error=max(max_price_error),max_share_error=max(max_share_error),max_fringe_error=max(fringe_share_error))])
