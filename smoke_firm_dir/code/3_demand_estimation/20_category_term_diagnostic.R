## Reduced-form category term vs first stages. No Markdown updates.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
root<-file.path(OUT_DIR,"demand_estimation")
base<-file.path(root,"specification_comparison","market_size")
tiny<-file.path(root,"bounded_outside_share","0.5_1.5")
paths<-c(file.path(base,c("estimation_sample.rds","models.rds","coefficients.csv")),
 file.path(tiny,c("monthly_series.csv","comparison.csv")))
hashes<-tools::md5sum(paths);d<-as.data.table(readRDS(paths[1]))
saved<-readRDS(paths[2]);sp<-as.data.table(saved$specifications)
baseline<-fread(paths[3]);tiny_series<-fread(paths[4]);tiny_coef<-fread(paths[5])
markets<-c(annual="M_t",monthly="M_t_k_monthly",constant="M_t_k_const")
out<-file.path(root,"category_term_diagnostic");dir.create(out,recursive=TRUE,showWarnings=FALSE)
coeffs<-identities<-tests<-checks<-models<-list()
for(scenario0 in c("original","outside_0.5_1.5"))for(i in seq_len(nrow(sp))) {
 s<-sp[i];dd<-copy(d);Q<-dd$s_g*dd$M_t
 if(scenario0=="original") {
  outside<-1-Q/dd[[markets[[s$market]]]]
 } else {
  t<-tiny_series[market==s$market];outside<-t$new_outside[match(dd$month,t$month)]
 }
 dd[,category_term:=log1p(-outside)-log(outside)]
 dd[,demand_y:=ln_s_i_g+category_term]
 exog<-c("a_it",if(s$size_control)"avg_ml_per_ecig",if(s$variety_control)"log_upc_variety")
 iv<-c("TaxIV_geo",s$count);rhs<-c(exog,iv)
 W<-cbind(if(s$firm_FE)model.matrix(~0+factor(brand),dd)else matrix(1,nrow(dd),1),as.matrix(dd[,..exog]))
 Z<-cbind(W,as.matrix(dd[,..iv]));id<-paste(scenario0,s$id,sep="_")
 fits<-list()
 for(outcome0 in c("p_it","ln_s_i_g","category_term","demand_y")) {
  f<-paste(outcome0,"~",paste(rhs,collapse=" + "));if(s$firm_FE)f<-paste(f,"| brand")
  m<-feols(as.formula(f),data=as.data.frame(dd),vcov=~month)
  ct<-coeftable(m);ref<-tail(qr.solve(Z,dd[[outcome0]]),length(rhs))
  stopifnot(nobs(m)==528L,max(abs(coef(m)[rhs]-ref))<1e-8)
  fits[[outcome0]]<-m;models[[paste(id,outcome0)]]<-m
  coeffs[[paste(id,outcome0)]]<-data.table(id,scenario=scenario0,original_id=s$id,base_id=s$base_id,
   market=s$market,group=s$group,firm_FE=s$firm_FE,count=s$count,outcome=outcome0,
   term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4],
   ci_low=ct[,1]-qt(.975,131)*ct[,2],ci_high=ct[,1]+qt(.975,131)*ct[,2],n=nobs(m),months=132L)
  bb<-coef(m)[iv];vv<-vcov(m)[iv,iv]
  F<-as.numeric(crossprod(bb,solve(vv,bb)))/2
  tests[[paste(id,outcome0)]]<-data.table(id,outcome=outcome0,joint_F=F,df1=2L,df2=131L,
   p_value=pf(F,2,131,lower.tail=FALSE))
 }
 pi<-cbind(price=coef(fits$p_it)[iv],share=coef(fits$ln_s_i_g)[iv])
 rho<-coef(fits$category_term)[iv]
 solution<-solve(pi,rho);alpha<-solution[1];delta<-solution[2]
 expected_sigma<-if(scenario0=="original")baseline[id==s$id & parameter=="sigma",estimate]else tiny_coef[original_id==s$id,sigma]
 expected_alpha<-if(scenario0=="original")baseline[id==s$id & parameter=="alpha",estimate]else tiny_coef[original_id==s$id,alpha]
 stopifnot(abs(delta+1-expected_sigma)<1e-7,abs(alpha-expected_alpha)<1e-7,
  max(abs(coef(fits$demand_y)[rhs]-coef(fits$ln_s_i_g)[rhs]-coef(fits$category_term)[rhs]))<1e-8)
 # Exact-ID mapping: delta = row 2 of inverse(pi) times rho.
 weight<-solve(pi)[2,]
 identities[[id]]<-data.table(id,scenario=scenario0,original_id=s$id,base_id=s$base_id,market=s$market,
  group=s$group,firm_FE=s$firm_FE,count=s$count,instrument=iv,
  price_first_stage=pi[,1],share_first_stage=pi[,2],category_reduced_form=rho,
  alpha,sigma=delta+1,sigma_minus_one=delta,
  price_contribution=alpha*pi[,1],share_contribution=delta*pi[,2],
  delta_weight=weight,contribution_to_sigma_minus_one=weight*rho,
  identity_error=rho-alpha*pi[,1]-delta*pi[,2])
 checks[[id]]<-data.table(id,sigma_error=abs(delta+1-expected_sigma),alpha_error=abs(alpha-expected_alpha))
}
cc<-rbindlist(coeffs);ii<-rbindlist(identities)
fwrite(cc,file.path(out,"reduced_forms_and_first_stages.csv"))
fwrite(ii,file.path(out,"instrument_decomposition.csv"))
fwrite(rbindlist(tests),file.path(out,"joint_instrument_tests.csv"))
fwrite(rbindlist(checks),file.path(out,"validation.csv"))
saveRDS(models,file.path(out,"models.rds"))
stopifnot(identical(hashes,tools::md5sum(paths)))
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Category-term diagnostic. Original 48 models and the 48 outside-share 0.5-1.5% models.",
 "c_t=log((1-s0_t)/s0_t); y_it=ln_s_i_g+c_t. Four regressions per design: price, within-nest log share, category term, demand outcome on identical instruments/controls/FE.",
 "528 firm-month observations, 132 month clusters; original UPC-unweighted price and exogenous current quality. No month FE. Each first stage/regression is conditional on the specified controls and firm FE, not a raw monthly correlation.",
 "Two excluded IVs and two endogenous regressors: rho_category = alpha*pi_price + (sigma-1)*pi_share exactly. Exported inverse-matrix weights show each IV's algebraic contribution to sigma-1, not causal attribution or an independent instrument-validity test.",
 "The category term is common across firms in a month. Firm-month regressions weight months by their observed number of incumbent rows and retain firm controls/FE to match demand estimation; they are not equally weighted regressions of 132 monthly observations.",
 "Positive/negative reduced-form signs are conditional associations. A demand-relevant instrument can legitimately predict category demand via price; the diagnostic alone cannot distinguish that channel from exclusion violations or misspecified outside shares.",
 "All auxiliary slopes pass explicit-dummy QR checks. Reconstructed alpha/sigma match saved original/tiny-outside fits. Reduced-form outcome=share+category identity and unchanged source hashes verified. No Markdown changes.",
 "Reproduce: Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/20_category_term_diagnostic.R"),file.path(out,"interpretation.txt"))
print(cc[base_id %in% c("SV3","SV4") & market=="annual" & term %in% c("TaxIV_geo","n_brands_3st","n_brands_overlap"),
 .(scenario,base_id,outcome,term,estimate,std_error,p_value)])
print(ii[base_id %in% c("SV3","SV4") & market=="annual",.(scenario,base_id,instrument,alpha,sigma,
 category_reduced_form,price_contribution,share_contribution,contribution_to_sigma_minus_one)])
