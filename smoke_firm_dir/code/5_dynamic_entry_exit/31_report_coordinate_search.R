source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
out<-file.path(OUT_DIR,"dynamic_entry_exit/coordinate_search_2026-11-06")
r<-fread(file.path(out,"candidate_scores.csv"))
# The baseline reused the previously audited solution without new iterations.
validation_path<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06/dynamic_validation.csv")
v<-fread(validation_path)
r[is.na(value_residual),value_residual:=v[check=="scaled_Bellman_residual",value]]
r[is.na(policy_residual),policy_residual:=v[check=="policy_residual",value]]
fwrite(r,file.path(out,"candidate_scores.csv"))
p<-fread(file.path(out,"coordinate_path.csv"))
b<-fread(file.path(out,"baseline_monthly.csv"));s<-fread(file.path(out,"selected_monthly.csv"))
cb<-fread(file.path(out,"baseline_counts.csv"));cs<-fread(file.path(out,"selected_counts.csv"))
stopifnot(all(is.finite(r[converged==TRUE,loss])),all(s$active>=0&s$active<=1),all(cs$simulated>=0&cs$simulated<=5))
pdf(file.path(out,"coordinate_search_comparison.pdf"),width=11,height=8.5)
par(mfrow=c(2,1),mar=c(4,4,3,1),oma=c(0,0,2,0))
for(brandname in c("JUUL","VUSE")){
 a<-b[brand==brandname];z<-s[brand==brandname]
 plot(z$month,z$ever_entered,type="l",ylim=c(0,1),lwd=2,col="firebrick",xlab="",ylab="Fraction ever entered",main=brandname)
 lines(a$month,a$ever_entered,lwd=2,col="steelblue");lines(z$month,cummax(z$observed),type="s",lwd=2)
 legend("bottomright",c("Observed","Original trial","Coordinate selection"),col=c("black","steelblue","firebrick"),lwd=2,bty="n")
}
mtext("Entry timing: original and selected trial parameters",outer=TRUE,font=2)
par(mfrow=c(3,1),mar=c(3,4,2,1),oma=c(0,0,2,0))
for(brandname in c("BLU","MISTIC","NJOY")){
 a<-b[brand==brandname];z<-s[brand==brandname]
 plot(z$month,z$active,type="l",ylim=c(0,1),lwd=2,col="firebrick",xlab="",ylab="Survival probability",main=brandname)
 lines(a$month,a$active,lwd=2,col="steelblue");lines(z$month,z$observed,type="s",lwd=2)
}
mtext("Survival: black observed, blue original, red selected",outer=TRUE,font=2)
par(mfrow=c(1,1),mar=c(4,4,4,1))
plot(cs$month,cs$observed,type="s",ylim=c(0,5),lwd=2,xlab="",ylab="Active focal brands",main="Active-firm count")
lines(cb$month,cb$simulated,lwd=2,col="steelblue");lines(cs$month,cs$simulated,lwd=2,col="firebrick")
legend("bottomright",c("Observed","Original trial","Coordinate selection"),col=c("black","steelblue","firebrick"),lwd=2,bty="n")
mtext("January 2013 market size/fringe fixed; provisional calibration, not formal estimation",side=3,cex=.8)
plot(seq_len(nrow(r)),r$loss,pch=19,col=ifelse(r$converged,"steelblue","gray"),xlab="Unique candidate evaluated",ylab="Equally weighted MSE",main="Coarse coordinate-search candidates")
text(seq_len(nrow(r)),r$loss,labels=seq_len(nrow(r)),pos=3,cex=.8)
dev.off()
selected<-tail(p,1);original<-r[1]
writeLines(c("Provisional coordinate calibration results",paste("Original loss:",signif(original$loss,6)),paste("Selected loss:",signif(selected$loss,6)),paste("Relative loss reduction:",round(100*(1-selected$loss/original$loss),2),"percent"),paste("Selected FC:",selected$FC,"entry mean:",selected$mu_E,"scrap SD:",selected$sigma_S),paste("Unique candidates:",nrow(r),"converged:",sum(r$converged)),"Fixed January 2013 M/fringe; 2000 shared simulation paths. Selected on this loss and grid, not a global optimum or structural estimate.","Simulation sampling error, grid order, warm-start equilibrium branch, fixed primitives and retrospective focal selection limit interpretation."),file.path(out,"findings.txt"))
print(r[order(loss)]);print(selected)

metrics<-rbindlist(lapply(c("baseline","selected"),function(which){
 d<-if(which=="baseline")b else s
 rbindlist(lapply(unique(d$brand),function(bn){z<-d[brand==bn];entrydate<-if(bn%in%c("JUUL","VUSE"))min(z[observed==1,month])else as.Date(NA)
 data.table(version=which,brand=bn,entry_by_observed_month=if(is.na(entrydate))NA_real_ else z[month==entrydate,ever_entered],active_at_sample_end=tail(z$active,1))}))
}))
fwrite(metrics,file.path(out,"event_summary.csv"))

# Independent simulation seed/path count; not a held-out historical data sample.
validation<-rbindlist(lapply(c("baseline","selected"),function(version){
 folder<-if(version=="baseline")file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06/entry_exit_diagnostics")else file.path(out,"selected_entry_exit_diagnostics")
 d<-fread(file.path(folder,"brand_month_diagnostics.csv"));counts<-fread(file.path(folder,"active_firm_counts.csv"))
 e<-d[brand%in%c("JUUL","VUSE")];e[,observed_entry:=cummax(observed_active),by=brand]
 terms<-c(entry=mean((e$ever_entered_probability-e$observed_entry)^2),survival=mean((d[brand%in%c("BLU","MISTIC","NJOY"),active_probability-observed_active])^2),count=mean(((counts$mean_active-counts$observed_active)/5)^2))
 data.table(version=version,loss=mean(terms),entry=terms[1],survival=terms[2],count=terms[3])
}))
fwrite(validation,file.path(out,"independent_simulation_check.csv"));print(validation)
cat("\nInterpretation: FC and mean entry cost are grid-boundary choices. No precise optimum or economic zero-cost conclusion.\nThe $1m and $5m scrap cases tie on the search paths at selected FC/entry mean; retaining $5m is a tie convention, not identification.\nMonthly curve MSE can improve by retaining incumbents even while missing the rare late MISTIC exit. Alternative target weights/event likelihoods may change selection.\nLarger independent-simulation check (10,000 paths, separate seed) loss: original ",validation[version=="baseline",loss],", selected ",validation[version=="selected",loss],". This is simulation validation, not a held-out historical sample.\n",file=file.path(out,"findings.txt"),append=TRUE)

source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
x<-readRDS(file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06/static_payoff_cache.rds"))
g<-build_dynamic_geometry(x$P,x$G);code<-g$states;code[code>9]<-0
profit<-x$profits[as.integer(1+as.vector(code%*%10^(0:4))),,drop=FALSE]
sol<-readRDS(file.path(out,"selected_solution.rds"))
br<-do.call(dynamic_best_response,c(list(V=sol$V,policy=sol$policy,profits=profit,geometry=g),sol$parameters))
vr<-max(abs(br$V-sol$V)/pmax(1,abs(sol$V),abs(br$V)));pr<-max(abs(br$policy-sol$policy))
stopifnot(vr<1e-6,pr<1e-7)
fwrite(data.table(check=c("fresh_selected_scaled_Bellman_residual","fresh_selected_policy_residual"),value=c(vr,pr)),file.path(out,"selected_validation.csv"))
