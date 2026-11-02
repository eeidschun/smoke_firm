## Observed-market inversion, costs and variable profits. No pricing solve.
## Run from repo root: Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/2_recover_observed_market.R
source('smoke_firm_dir/code/fxns/1_paths.R')
source(file.path(CODE_DIR,'4_static_pricing_subgame','1_static_demand_functions.R'))
suppressPackageStartupMessages(library(data.table));setDTthreads(2)
parent<-file.path(OUT_DIR,'demand_estimation','sales_weighted_tax_2026-10-27','sales')
id<-'constant_available_B_noFE_p_it_volume_weighted_Annual'
out<-file.path(OUT_DIR,'static_pricing_subgame','observed_recovery_2026-10-27')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
inputs<-c(panel=file.path(parent,'candidate_panel.rds'),
 coefficients=file.path(parent,'original_48_grid','coefficients.csv'),
 specifications=file.path(parent,'original_48_grid','specifications.csv'),
 estimation_sample=file.path(parent,'original_48_grid','estimation_sample.rds'),
 market=file.path(SUPPORT_DIR,'demand_panel_firm_month.RData'))
hashes<-tools::md5sum(inputs)
# Avoid data.table name collision for the selected ID.
selected_id<-id
sp<-fread(inputs['specifications'])[id==selected_id]
stopifnot(nrow(sp)==1L,sp$n==528,sp$market=='constant',sp$controls=='B',!sp$firm_FE,
 sp$instrument_set=='Annual',sp$price_measure=='p_it_volume_weighted')
cc<-fread(inputs['coefficients'])[id==selected_id]
b<-setNames(cc$estimate,cc$term)
stopifnot(length(b)==4L,b['fit_price']<0,b['fit_ln_s_i_g']>0,b['fit_ln_s_i_g']<1)
alpha<-unname(b['fit_price']);sigma<-unname(b['fit_ln_s_i_g']);beta<-unname(b['a_it']);intercept<-unname(b['(Intercept)'])
d<-as.data.table(readRDS(inputs['panel']));d<-copy(d)
sample<-as.data.table(readRDS(inputs['estimation_sample']))
stopifnot(nrow(d)==540L,nrow(sample)==528L,!anyDuplicated(d[,.(brand,month)]))
d[,in_estimation_sample:=FALSE];d[sample,on=.(brand,month),in_estimation_sample:=TRUE]
stopifnot(sum(d$in_estimation_sample)==528)
e<-new.env();load(inputs['market'],e);m<-as.data.table(e$demand_mkt)
m<-m[,.(month,M=M_t_k_const,Q_inc=mL_inc,Q_F=mL_fringe,R_F=rev_fringe,a_F=a_Ft,p_F)]
stopifnot(nrow(m)==132L,!anyNA(m),all(m$Q_F>0),all(m$M>m$Q_inc+m$Q_F),all(m$p_F>0))
# Check complete observed roster before extracting estimation sample.
reconcile<-merge(d[,.(Q_inc_check=sum(mL)),by=month],m,by='month')
stopifnot(max(abs(reconcile$Q_inc_check/reconcile$Q_inc-1))<1e-10)
m[,`:=`(Q=Q_inc+Q_F,s_F=Q_F/M,s_g=(Q_inc+Q_F)/M,s_0=1-(Q_inc+Q_F)/M)]
m[,delta_F:=log(s_F/s_0)-sigma*log(s_F/s_g)]
m[,xi_F:=delta_F-intercept-beta*a_F-alpha*p_F]
stopifnot(max(abs(m$p_F*m$Q_F/m$R_F-1))<1e-10)
d<-merge(d,m,by='month',all.x=TRUE,suffixes=c('_legacy',''))
d[,`:=`(price=p_it_volume_weighted,q=mL,quality=a_it)]
d[,`:=`(share=q/M,within=q/Q)]
d[,y_chosen:=log(share/s_0)]
d[,delta:=y_chosen-sigma*log(within)]
d[,xi:=delta-intercept-beta*quality-alpha*price]
d[,nonprice_utility:=intercept+beta*quality+xi]
d[,markup:=static_markup(share,within,alpha,sigma)]
d[,mc:=price-markup]
d[,`:=`(variable_profit=(price-mc)*q,own_derivative=static_own_derivative(share,within,alpha,sigma),
 own_elasticity=alpha*price*(1/(1-sigma)-sigma*within/(1-sigma)-share),
 negative_mc=mc<0,recovery_scope=ifelse(in_estimation_sample,'estimation sample','out-of-estimation-sample inversion'))]
stopifnot(all(is.finite(d$xi)),all(is.finite(d$mc)),max(abs(d$price*d$q/d$revenue_real-1))<1e-10)
# Independently reproduce the chosen IV coefficients and structural residuals.
z<-d[in_estimation_sample==TRUE]
W<-cbind('(Intercept)'=1,a_it=z$quality)
X<-cbind(W,fit_price=z$price,fit_ln_s_i_g=log(z$within))
Z<-cbind(W,TaxIV_sales=z$TaxIV_sales,incumbent_annual=z$incumbent_annual)
stopifnot(qr(Z)$rank==ncol(Z))
ref<-qr.solve(qr.fitted(qr(Z),X),z$y_chosen)
coefficient_error<-max(abs(ref-b[colnames(X)]))
residual_error<-max(abs(z$xi-(z$y_chosen-as.vector(X%*%ref))))
stopifnot(coefficient_error<1e-8,residual_error<1e-8)
# Rebuild shares from utility, independently of observed ratios in cost recovery.
checks<-d[,{
 sh<-static_shares(price,nonprice_utility,first(delta_F),alpha,sigma)
 list(share_error=max(abs(sh$share-share)),fringe_error=abs(sh$fringe_share-first(s_F)),
 outside_error=abs(sh$outside_share-first(s_0)),mass_error=abs(sum(sh$share)+sh$fringe_share+sh$outside_share-1),
 relative_quantity_error=max(abs(M*sh$share/q-1)),
 max_scaled_FOC=max(abs(1+(price-mc)*own_derivative/share)),n_firms=.N)
},by=month]
stopifnot(max(checks$share_error)<1e-10,max(checks$fringe_error)<1e-10,max(checks$outside_error)<1e-10,
 max(checks$mass_error)<1e-12,max(checks$relative_quantity_error)<1e-10,max(checks$max_scaled_FOC)<1e-10)
cols<-c('brand','month','in_estimation_sample','recovery_scope','price','q','revenue_real','quality','M','Q',
 'share','within','s_0','s_g','delta','xi','nonprice_utility','markup','mc','negative_mc','own_elasticity','variable_profit')
fwrite(d[,..cols],file.path(out,'incumbent_recovery.csv'))
fwrite(m,file.path(out,'fringe_market_recovery.csv'))
fwrite(checks,file.path(out,'monthly_validation.csv'))
fwrite(cc,file.path(out,'selected_coefficients.csv'));fwrite(sp,file.path(out,'selected_specification.csv'))
fwrite(d[in_estimation_sample==FALSE,.(brand,month,recovery_scope)],file.path(out,'additional_roster_rows.csv'))
summary<-d[,.(n=.N,negative_mc=sum(negative_mc),min_price=min(price),median_price=median(price),
 min_mc=min(mc),median_mc=median(mc),max_mc=max(mc),median_markup=median(markup),max_markup=max(markup),
 total_revenue=sum(revenue_real),total_variable_profit=sum(variable_profit)),by=in_estimation_sample]
fwrite(summary,file.path(out,'summary_by_sample.csv'))
fwrite(d[,.(n=.N,negative_mc=sum(negative_mc),median_price=median(price),median_mc=median(mc),
 median_markup=median(markup),total_variable_profit=sum(variable_profit)),by=brand],file.path(out,'summary_by_brand.csv'))
fwrite(data.table(check=c('IV coefficient error','IV residual error'),error=c(coefficient_error,residual_error)),file.path(out,'demand_fit_validation.csv'))
saveRDS(list(id=selected_id,alpha=alpha,sigma=sigma,beta=beta,intercept=intercept,
 incumbents=d[,..cols],markets=m,validation=checks),file.path(out,'observed_market_inputs.rds'))
stopifnot(identical(hashes,tools::md5sum(inputs)))
fwrite(data.table(path=unname(inputs),md5=unname(hashes)),file.path(out,'input_hashes.csv'))
writeLines(c('Observed-market recovery, 2026-10-27.',paste('Chosen fit:',selected_id),
'Full precision saved coefficients; no re-estimation or canonical changes.',
'528 estimation rows, 540 observed incumbent rows. 12 BLU 2018 rows inverted outside fit sample to retain full competitors and observed share totals.',
'Brand acts as vertically integrated single-product retail pricing firm. Costs are effective integrated-channel costs.',
'Fringe utility calibrated from observed shares; fringe price is revenue/volume and quality is existing equal-UPC nicotine. Utility fixed within a static solve; fringe share can change.',
'Variable profit = (price - mc)*liquid volume. Fixed operating costs unspecified; net profit and dynamic value not yet computed.',
'Negative marginal costs are reported, never clipped. Interpretation and specification may need review.',
'Markup FOC and observed shares reproduce by construction: this is an implementation check, not independent evidence for demand or supply validity.',
'No price equilibrium or fixed point solved yet. Next step: manual damped pricing iteration with independent initializations, residuals, and unilateral deviation checks.'),file.path(out,'interpretation.txt'))
writeLines(capture.output(sessionInfo()),file.path(out,'session_info.txt'))
print(summary);print(checks[,lapply(.SD,max),.SDcols=c('share_error','fringe_error','outside_error','relative_quantity_error','max_scaled_FOC')])
