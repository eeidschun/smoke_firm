source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input <- file.path(OUT_DIR,"dynamic_entry_exit/independent_transitions_2026-11-03/assigned_observations.csv")
out <- file.path(OUT_DIR,"dynamic_entry_exit/nicotine_grid_comparison_2026-11-03")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
hash <- tools::md5sum(input)
d <- fread(input);setorder(d,brand,month)
d[,next_a:=shift(quality,type="lead"),by=brand]
# Compare pooled terciles against higher-cutoff grids and finer quantiles.
choices <- list(terciles=as.numeric(quantile(d$quality,c(1/3,2/3),type=7)),higher_15_30=c(15,30),higher_20_30=c(20,30),quartiles=as.numeric(quantile(d$quality,c(.25,.5,.75),type=7)),quintiles=as.numeric(quantile(d$quality,seq(.2,.8,.2),type=7)))
summaries<-list();states<-list();pairs<-list();firms<-list()
pdf(file.path(out,"nicotine_grid_comparison.pdf"),width=10,height=7)
for(id in names(choices)) {
  cuts <- choices[[id]];k<-length(cuts)+1L
  z<-copy(d);z[,state:=as.integer(cut(quality,c(-Inf,cuts,Inf),right=TRUE))]
  z[,destination:=shift(state,type="lead"),by=brand]
  g<-z[,.(observations=.N,median=median(quality),min=min(quality),max=max(quality)),by=state][order(state)]
  z<-merge(z,g[,.(state,representative=median)],by="state",sort=FALSE)
  t<-z[eligible==TRUE]
  counts<-merge(CJ(state=1:k,destination=1:k),t[,.(transitions=.N),by=.(state,destination)],by=c("state","destination"),all.x=TRUE)
  counts[is.na(transitions),transitions:=0L];counts[,departures:=sum(transitions),by=state]
  counts[,probability:=fifelse(departures>0,transitions/departures,NA_real_)]
  g<-merge(g,unique(counts[,.(state,departures)]),by="state")
  g[,`:=`(lower=c(min(d$quality),cuts),upper=c(cuts,max(d$quality)),candidate=id)]
  summaries[[id]]<-data.table(candidate=id,bins=k,cutoffs=paste(round(cuts,4),collapse=", "),min_observations=min(g$observations),min_departures=min(g$departures),crossings=sum(t$state!=t$destination),crossing_fraction=mean(t$state!=t$destination),crossing_firms=uniqueN(t[state!=destination,brand]),median_abs_representation_error=median(abs(z$quality-z$representative)),mean_abs_representation_error=mean(abs(z$quality-z$representative)))
  fb<-t[,.(transitions=.N,crossings=sum(state!=destination)),by=brand];fb[,candidate:=id]
  counts[,candidate:=id];states[[id]]<-g;pairs[[id]]<-counts;firms[[id]]<-fb
  stopifnot(sum(counts$transitions)==531,all(abs(counts[departures>0,.(p=sum(probability)),by=state]$p-1)<1e-12))
  par(mfrow=c(2,1),mar=c(4,4,3,1))
  hist(d$quality,breaks=40,col="grey85",main=paste(id,"- nicotine distribution and boundaries"),xlab="Delivered nicotine concentration")
  abline(v=cuts,col="firebrick",lwd=2);abline(v=g$median,col="steelblue",lty=2)
  barplot(g$departures,names.arg=g$state,col="steelblue",xlab="Nicotine state",ylab="Observed monthly departures",main=paste("Crossings:",sum(t$state!=t$destination),"of 531; minimum row support:",min(g$departures)))
}
dev.off()
fwrite(rbindlist(summaries),file.path(out,"candidate_summary.csv"))
fwrite(rbindlist(states),file.path(out,"state_definitions.csv"))
fwrite(rbindlist(pairs),file.path(out,"transition_counts_probabilities.csv"))
fwrite(rbindlist(firms),file.path(out,"crossings_by_firm.csv"))
stopifnot(identical(unname(hash),unname(tools::md5sum(input))))
writeLines(c("Sensitivity exercise; no alternative is selected or replaces the baseline matrices.","Higher cutoffs (15,30) and (20,30) are illustrative round values in delivered nicotine concentration units, not regulatory/label categories.","All comparisons use identical 540 observations and 531 consecutive within-brand transitions; pooled right-closed bins and within-bin medians.","Representation error measures absolute observed nicotine minus its bin median, not profit approximation error or forecast accuracy.","Finer grids have more representative values, so reduced in-sample error is not independent evidence of better dynamic fit.","Crossings are sensitive to boundary placement; more crossings are not intrinsically better. Roster selection, pooling and transition assumptions remain unresolved.","Checks passed: transition totals, probability row sums, unchanged source hash."),file.path(out,"README.txt"))
print(rbindlist(summaries))
