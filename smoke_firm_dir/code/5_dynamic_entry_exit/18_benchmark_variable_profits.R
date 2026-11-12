source("smoke_firm_dir/code/fxns/1_paths.R")
source(file.path(CODE_DIR,"4_static_pricing_subgame/1_static_demand_functions.R"))
source(file.path(CODE_DIR,"4_static_pricing_subgame/4_manual_pricing_functions.R"))
library(data.table);setDTthreads(2)
root<-file.path(OUT_DIR,"dynamic_entry_exit")
files<-c(file.path(root,"fixed_focal_supply_2026-11-05/fixed_focal_supply_inputs.rds"),file.path(root,"entrant_quality_2026-11-04/entrant_initial_state_distribution.csv"),file.path(root,"historical_market_sizes_2026-11-04/annual_market_sizes.csv"))
hashes<-tools::md5sum(files);x<-readRDS(files[1]);g<-fread(files[2]);markets<-fread(files[3])
january_mode<-"--january-fringe" %in% commandArgs(trailingOnly=TRUE)
if(january_mode) x$delta_F_constant<-x$markets[month==min(x$markets$month),delta_F]
base<-copy(x$initial_roster);setorder(base,brand)
stopifnot(identical(base$brand,c("BLU","MISTIC","NJOY")),nrow(g)==9L,abs(sum(g$probability)-1)<1e-12)
costs<-x$constant_costs
annual_beta<-.95;beta<-annual_beta^(1/12)
out<-file.path(root,if(january_mode) "benchmark_profits_january_fringe_2026-11-06" else "benchmark_profits_2026-11-05");dir.create(out,recursive=TRUE,showWarnings=FALSE)
scenarios<-rbindlist(list(data.table(roster="initial_three",juul_state=NA_integer_,vuse_state=NA_integer_,weight=1),data.table(roster="plus_JUUL",juul_state=g$state,vuse_state=NA_integer_,weight=g$probability),data.table(roster="plus_VUSE",juul_state=NA_integer_,vuse_state=g$state,weight=g$probability),CJ(juul_state=g$state,vuse_state=g$state)[,`:=`(roster="plus_both",weight=g$probability[match(juul_state,g$state)]*g$probability[match(vuse_state,g$state)])]),fill=TRUE)
scenarios[,scenario:=seq_len(.N)]
stopifnot(all(abs(scenarios[,.(w=sum(weight)),by=roster]$w-1)<1e-12))
results<-list();checks<-list()
for(yr in c(2013L,2023L)) for(k in seq_len(nrow(scenarios))) {
 sc<-scenarios[k];z<-base[,.(brand,quality=quality_representative,xi=xi_representative,mc_constant)]
 for(b in c("JUUL","VUSE")) {
   state_id<-if(b=="JUUL")sc$juul_state else sc$vuse_state
   if(!is.na(state_id)) {
     q<-g[state==state_id]
     z<-rbind(z,data.table(brand=b,quality=q$quality,xi=q$xi,mc_constant=costs[brand==b,mc_constant]))
   }
 }
 setorder(z,brand);v<-x$intercept+x$beta_a*z$quality+z$xi
 sol<-manual_price_fixed_point(z$mc_constant,v,x$delta_F_constant,x$alpha,x$sigma,z$mc_constant+1)
 alt<-manual_price_fixed_point(z$mc_constant,v,x$delta_F_constant,x$alpha,x$sigma,z$mc_constant+.1)
 stopifnot(sol$converged,alt$converged,max(abs(sol$prices-alt$prices))<1e-8)
 M<-markets[year==yr,M]
 z[,`:=`(price=sol$prices,share=sol$shares$share,quantity_mL=M*sol$shares$share,variable_profit=(sol$prices-mc_constant)*M*sol$shares$share,year=yr,scenario=sc$scenario,roster=sc$roster,scenario_weight=sc$weight,juul_state=sc$juul_state,vuse_state=sc$vuse_state)]
 gains<-numeric(nrow(z))
 for(i in seq_len(nrow(z))) {
   br<-manual_unilateral_best_response(i,sol$prices,z$mc_constant,v,x$delta_F_constant,x$alpha,x$sigma)
   gains[i]<-br$profit_per_market-(sol$prices[i]-z$mc_constant[i])*sol$shares$share[i]
 }
 stopifnot(max(gains)<1e-12,abs(sum(sol$shares$share)+sol$shares$fringe_share+sol$shares$outside_share-1)<1e-12)
 checks[[paste(yr,k)]]<-data.table(year=yr,scenario=sc$scenario,converged=sol$converged,iterations=sol$iterations,start_price_difference=max(abs(sol$prices-alt$prices)),scaled_foc=sol$scaled_foc,max_profit_gain_per_market=max(gains))
 results[[paste(yr,k)]]<-z
}
d<-rbindlist(results);validation<-rbindlist(checks)
s<-d[,.(expected_variable_profit=sum(scenario_weight*variable_profit),min_variable_profit=min(variable_profit),max_variable_profit=max(variable_profit),expected_price=sum(scenario_weight*price),expected_quantity_mL=sum(scenario_weight*quantity_mL)),by=.(year,roster,brand)]
s[,`:=`(annualized_variable_profit=12*expected_variable_profit,frozen_state_PV=expected_variable_profit/(1-beta))]
fwrite(d,file.path(out,"scenario_firm_profits.csv"));fwrite(s,file.path(out,"weighted_profit_summary.csv"));fwrite(validation,file.path(out,"pricing_validation.csv"));fwrite(scenarios,file.path(out,"scenario_definitions.csv"))
# Scale suggestions only: generic common parameter grid, not brand-specific parameters.
P<-median(s[year==2013 & roster=="initial_three",expected_variable_profit])
A<-median(s[year==2013 & roster %in% c("plus_JUUL","plus_VUSE") & brand %in% c("JUUL","VUSE"),annualized_variable_profit])
scales<-rbindlist(list(data.table(parameter="FC",multiplier=c(.1,.5,1),dollar_value=P*c(.1,.5,1),reference="Median initial-incumbent monthly variable profit"),data.table(parameter="mu_E",multiplier=c(.5,2,5),dollar_value=A*c(.5,2,5),reference="Median entrant annualized expected variable profit when entering alone"),data.table(parameter="sigma_S",multiplier=c(.5,2,5),dollar_value=12*P*c(.5,2,5),reference="Annualized median initial-incumbent variable profit")))
fwrite(scales,file.path(out,"illustrative_trial_scales.csv"))
stopifnot(identical(unname(hashes),unname(tools::md5sum(files))))
fwrite(data.table(path=files,md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Static dollar-scale exercise, not dynamic continuation values or parameter estimates.",paste("January 2013 BLU/MISTIC/NJOY binned states held fixed; retained within-firm median MC; fixed fringe benchmark:",if(january_mode) "January 2013" else "full-period median"),"100 roster/entry-state scenarios at each of 2013 and 2023 M; two starts each =400 manual solves. No incumbent exits or monthly quality transitions simulated.","Entrant state weights use selected G_e. For both entrants, independent initial draws across brands are assumed for this diagnostic; this is not an equilibrium entry selection prediction.","Zero-probability G_e cells included for stress checks but receive no weight. Entrants have assigned JUUL/VUSE costs.","Profits exclude FC, sunk entry cost and scrap. Annualized amounts are 12 times monthly profits, not simulated annual profits.","Frozen-state PV is a scale diagnostic only; it is not an entry/continuation value and ignores quality, roster changes and FC.","2023 calculations change M only; they are not historical 2023 market predictions.","Suggested trial scales have not been selected. Common parameters may imply very different brand outcomes; entry-cost means do not mechanically guarantee delay.","All solves pass convergence, independent-start agreement, mass and unilateral best-response checks; source hashes unchanged."),file.path(out,"README.txt"))
print(s[year==2013,.(roster,brand,expected_variable_profit,expected_price)],digits=5)
cat('Proposed scale grid (unselected):\n');print(scales,digits=5)
# Attribution of large profit changes at the initial market. All contrasts retain M_2013.
raw<-x$observed_focal[month==min(x$observed_focal$month)];setorder(raw,brand)
M0<-markets[year==2013,M];f0<-x$markets[month==min(x$markets$month),delta_F]
regimes<-data.table(regime=c("observed_states_monthly_MC_monthly_fringe","observed_states_constant_MC_monthly_fringe","binned_states_constant_MC_monthly_fringe","observed_states_constant_MC_constant_fringe","binned_states_constant_MC_constant_fringe"),binned=c(FALSE,FALSE,TRUE,FALSE,TRUE),constant_MC=c(FALSE,TRUE,TRUE,TRUE,TRUE),constant_fringe=c(FALSE,FALSE,FALSE,TRUE,TRUE))
contrast<-list()
for(k in seq_len(nrow(regimes))) {
 r<-regimes[k];mc<-if(r$constant_MC)base$mc_constant else raw$mc
 a<-if(r$binned)base$quality_representative else raw$quality
 xi<-if(r$binned)base$xi_representative else raw$xi
 f<-if(r$constant_fringe)median(x$markets$delta_F) else f0
 v<-x$intercept+x$beta_a*a+xi
 sol<-manual_price_fixed_point(mc,v,f,x$alpha,x$sigma,mc+1)
 stopifnot(sol$converged)
 if(k==1)stopifnot(max(abs(sol$prices-raw$price))<1e-8)
 contrast[[k]]<-data.table(regime=r$regime,brand=raw$brand,price=sol$prices,variable_profit=(sol$prices-mc)*M0*sol$shares$share,quantity_mL=M0*sol$shares$share,fringe_utility=f)
}
contrast<-rbindlist(contrast);fwrite(contrast,file.path(out,"initial_profit_assumption_comparison.csv"))
print(contrast[,.(regime,brand,variable_profit)],digits=5)
