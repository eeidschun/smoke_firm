source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input <- file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27/incumbent_recovery.csv")
out <- file.path(OUT_DIR,"dynamic_entry_exit/marginal_cost_audit_2026-11-03")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
hash<-tools::md5sum(input)
d<-fread(input);d[,date:=as.Date(month)]
d[,time:=as.integer(format(date,"%Y"))*12L+as.integer(format(date,"%m"))]
setorder(d,brand,time)
stopifnot(!anyDuplicated(d[,.(brand,time)]),all(is.finite(d$mc)),all(d$mc>0))
d[,`:=`(lag_mc=shift(mc),lag_time=shift(time)),by=brand]
d[,delta_mc:=fifelse(time==lag_time+1L,mc-lag_mc,NA_real_)]
s <- d[,{
  trend<-lm(mc~time)
  list(months=.N,mean_mc=mean(mc),median_mc=median(mc),sd_mc=sd(mc),cv=sd(mc)/mean(mc),min_mc=min(mc),max_mc=max(mc),first_mc=first(mc),last_mc=last(mc),annual_linear_slope=unname(coef(trend)[2])*12,trend_R2=summary(trend)$r.squared,median_abs_monthly_change=median(abs(delta_mc),na.rm=TRUE),cor_mc_nicotine=cor(mc,quality),inversion_only_rows=sum(!in_estimation_sample))
},by=brand]
fwrite(s,file.path(out,"firm_cost_summary.csv"))
# Descriptive decompositions on both full and fitted rosters; no causal interpretation.
models<-list(); decomposition<-list()
for(scope in c("full_roster","estimation_rows")) {
 z<-if(scope=="full_roster") copy(d) else d[in_estimation_sample==TRUE]
 fits<-list(firm=lm(mc~factor(brand),data=z),firm_month=lm(mc~factor(brand)+factor(month),data=z),firm_nicotine=lm(mc~factor(brand)+quality,data=z),firm_specific_linear_trends=lm(mc~factor(brand)*time,data=z))
 ss<-sum((z$mc-mean(z$mc))^2)
 for(n in names(fits)) decomposition[[paste(scope,n)]]<-data.table(sample=scope,model=n,rows=nrow(z),parameters=fits[[n]]$rank,R2=1-sum(resid(fits[[n]])^2)/ss,residual_RMSE=sqrt(mean(resid(fits[[n]])^2)),nicotine_slope=if(n=="firm_nicotine")unname(coef(fits[[n]])['quality']) else NA_real_)
}
fwrite(rbindlist(decomposition),file.path(out,"descriptive_decomposition.csv"))
# Cross-firm correlations of adjacent monthly changes, restricted to overlapping dates.
w<-dcast(d[!is.na(delta_mc)],month~brand,value.var="delta_mc")
cc<-list()
for(i in 2:(ncol(w)-1)) for(j in (i+1):ncol(w)) {
 ok<-complete.cases(w[[i]],w[[j]])
 cc[[paste(i,j)]]<-data.table(firm_1=names(w)[i],firm_2=names(w)[j],overlapping_changes=sum(ok),correlation=if(sum(ok)>=3 && sd(w[[i]][ok])>0 && sd(w[[j]][ok])>0) cor(w[[i]][ok],w[[j]][ok]) else NA_real_)
}
fwrite(rbindlist(cc),file.path(out,"pairwise_monthly_change_correlations.csv"))
fwrite(d[,.(brand,month,mc,price,markup,quality,xi,in_estimation_sample,delta_mc)],file.path(out,"cost_series.csv"))
pdf(file.path(out,"recovered_marginal_cost_audit.pdf"),width=11,height=8.5)
par(mfrow=c(3,3),mar=c(3,4,3,1),oma=c(0,0,3,0))
for(b in unique(d$brand)) {
 z<-d[brand==b];plot(z$date,z$mc,type="l",col="steelblue",lwd=2,xlab="",ylab="Real dollars / mL",main=b)
 abline(h=median(z$mc),lty=2,col="grey40")
 points(z[in_estimation_sample==FALSE,date],z[in_estimation_sample==FALSE,mc],col="firebrick",pch=16)
}
mtext("Recovered marginal costs; dashed = firm median; red = inversion-only BLU 2018",outer=TRUE,cex=1.1)
par(mfrow=c(3,3),mar=c(3,4,3,1),oma=c(0,0,3,0))
for(b in unique(d$brand)) {
 z<-d[brand==b];plot(z$date,z$mc/median(z$mc),type="l",col="steelblue",lwd=2,xlab="",ylab="MC / firm median",main=b,ylim=range(d[,mc/median(mc),by=brand]$V1))
 abline(h=1,lty=2,col="grey40")
}
mtext("Relative cost variation (common vertical scale)",outer=TRUE,cex=1.1)
par(mfrow=c(3,3),mar=c(4,4,3,1),oma=c(0,0,3,0))
for(b in unique(d$brand)) {
 z<-d[brand==b];plot(z$quality,z$mc,pch=16,col=adjustcolor("steelblue",alpha.f=.5),xlab="Delivered nicotine concentration",ylab="Real dollars / mL",main=b)
}
mtext("Nicotine versus recovered MC: descriptive, not a cost technology estimate",outer=TRUE,cex=1.1)
par(mfrow=c(3,3),mar=c(3,4,3,1),oma=c(0,0,3,0))
for(b in unique(d$brand)) {
 z<-d[brand==b];plot(z$date,z$price,type="l",lwd=2,col="grey40",xlab="",ylab="Real dollars / mL",main=b,ylim=range(c(z$price,z$mc)))
 lines(z$date,z$mc,col="steelblue",lwd=2)
}
mtext("Observed price (grey) and recovered marginal cost (blue)",outer=TRUE,cex=1.1)
dev.off()
stopifnot(identical(unname(hash),unname(tools::md5sum(input))))
writeLines(c("Exploratory cost audit; no dynamic cost rule selected or meeting notes modified.","MC is observed retail price minus demand-implied Bertrand markup, not independently measured manufacturer costs.","All 540 roster observations included; BLU 2018 inversion-only rows explicitly marked. Decompositions also use 528 estimation rows.","Slopes and R-squared are descriptive; serial dependence, endogenous recovered costs and demand uncertainty prevent causal interpretation.","Month effects may absorb trends, demand misspecification, compositional changes and genuine common costs; improved fit alone does not identify cost shocks.","Monthly changes and cross-firm correlations use only adjacent calendar months; inspect pairwise overlap counts.","Firm costs and entrant cost assignment remain undecided. Input hash unchanged."),file.path(out,"README.txt"))
print(s,digits=3);print(rbindlist(decomposition),digits=3)
