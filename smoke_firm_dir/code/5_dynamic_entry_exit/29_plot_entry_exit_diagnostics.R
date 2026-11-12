source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
out<-file.path(OUT_DIR,"dynamic_entry_exit/manual_dynamic_trial_2026-11-06")
x<-readRDS(file.path(out,"static_payoff_cache.rds"))
selected<-"--coordinate-selected" %in% commandArgs(trailingOnly=TRUE)
solpath<-if(selected)file.path(OUT_DIR,"dynamic_entry_exit/coordinate_search_2026-11-06/selected_solution.rds")else file.path(out,"dynamic_trial_solution.rds")
sol<-readRDS(solpath)
stopifnot(sol$converged)
if(is.null(sol$last_best_response)){
 source(file.path(CODE_DIR,"5_dynamic_entry_exit/20_dynamic_solver_functions.R"))
 geometry<-build_dynamic_geometry(x$P,x$G);code<-geometry$states;code[code>9]<-0
 profit<-x$profits[as.integer(1+as.vector(code%*%10^(0:4))),,drop=FALSE]
 sol$last_best_response<-do.call(dynamic_best_response,c(list(V=sol$V,policy=sol$policy,profits=profit,geometry=geometry),sol$parameters))
}
initial<-fread(file.path(out,"initial_state_results.csv"))$state
out<-if(selected)file.path(OUT_DIR,"dynamic_entry_exit/coordinate_search_2026-11-06/selected_entry_exit_diagnostics")else file.path(out,"entry_exit_diagnostics")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
N<-10000L;T<-132L;set.seed(11062026)
s<-matrix(rep(initial,each=N),N,5);payoffs<-matrix(0,N,5)
strides<-c(1,10,100,1000,11000);beta<-sol$parameters$beta
cP<-t(apply(x$P,1,cumsum));cG<-cumsum(x$G)
reports<-list();counts<-list()
dates<-seq(as.Date("2013-01-01"),by="month",length.out=T)
life<-fread(file.path(OUT_DIR,"dynamic_entry_exit/entry_exit_candidates_2026-11-04/incumbent_brand_lifecycles.csv"))
life<-life[match(x$brands,brand)]
first<-matrix(NA_integer_,N,5);first[,1:3]<-1L
last_exit<-matrix(NA_integer_,N,5)

for(t in 1:T) {
 id<-as.integer(1+as.vector(s%*%strides))
 static<-s;static[static>9]<-0
 staticid<-as.integer(1+as.vector(static%*%10^(0:4)))
 active<-s>=1 & s<=9
 eligible<-matrix(FALSE,N,5);eligible[,4:5]<-s[,4:5,drop=FALSE]==0
 cont<-matrix(FALSE,N,5);enter<-cont;exit<-cont
 for(i in 1:5) {
  a<-which(active[,i]);u<-which(eligible[,i])
  if(length(a)) {
   scrap<-rnorm(length(a),sd=sol$parameters$sigma_S)
   ex<-scrap>sol$last_best_response$continuation[id[a],i]
   exit[a,i]<-ex;cont[a,i]<-!ex
   payoffs[a,i]<-payoffs[a,i]+beta^(t-1)*(x$profits[staticid[a],i]-sol$parameters$FC+ifelse(ex,scrap,0))
  }
  if(length(u)) {
   cost<-rexp(length(u),rate=1/sol$parameters$mu_E)
   cutoff<-sol$last_best_response$entry_value[id[u],i]-sol$last_best_response$waiting_value[id[u],i]
   en<-cost<=cutoff;enter[u,i]<-en
   payoffs[u,i]<-payoffs[u,i]-beta^(t-1)*ifelse(en,cost,0)
  }
 }
 for(i in 1:5) {
  observed<-dates[t]>=as.Date(life$first_observed_sales[i]) && dates[t]<=as.Date(life$last_observed_sales[i])
  reports[[length(reports)+1L]]<-data.table(month=dates[t],brand=x$brands[i],
   active_probability=mean(active[,i]),ever_entered_probability=mean(!is.na(first[,i])),
   survival_probability=mean(is.na(last_exit[,i])),observed_active=as.integer(observed))
 }
 number<-rowSums(active)
 obsnum<-sum(dates[t]>=as.Date(life$first_observed_sales)&dates[t]<=as.Date(life$last_observed_sales))
 counts[[t]]<-data.table(month=dates[t],mean_active=mean(number),lower=unname(quantile(number,.025)),upper=unname(quantile(number,.975)),observed_active=obsnum)
 for(i in 1:5) {
  first[enter[,i],i]<-t+1L
  last_exit[exit[,i],i]<-t+1L
 }
 nexts<-s
 for(i in 1:5) {
  a<-which(cont[,i]);u<-which(enter[,i]);ex<-which(exit[,i])
  if(length(a))nexts[a,i]<-1L+rowSums(matrix(runif(length(a)),length(a),9)>cP[s[a,i],,drop=FALSE])
  if(length(u))nexts[u,i]<-1L+rowSums(matrix(runif(length(u)),length(u),9)>matrix(cG,length(u),9,byrow=TRUE))
  if(length(ex))nexts[ex,i]<-if(i<=3)0L else 10L
 }
 stopifnot(all(rowSums(nexts>=1 & nexts<=9)<=5),!any((s[,4:5,drop=FALSE]==10)&(nexts[,4:5,drop=FALSE]!=10)))
 s<-nexts
}

d<-rbindlist(reports);ct<-rbindlist(counts)
fwrite(d,file.path(out,"brand_month_diagnostics.csv"));fwrite(ct,file.path(out,"active_firm_counts.csv"))
events<-rbindlist(lapply(1:5,function(i){
 observed_entry<-if(i<=3)NA_integer_ else match(as.Date(life$first_observed_sales[i]),dates)
 observed_exit<-if(life$right_censored[i])NA_integer_ else match(as.Date(life$last_observed_sales[i]),dates)+1L
 data.table(brand=x$brands[i],observed_first_sales=life$first_observed_sales[i],observed_exit_month=if(is.na(observed_exit))NA_character_ else as.character(dates[observed_exit]),
  simulated_entry_by_observed_month=if(is.na(observed_entry))NA_real_ else mean(!is.na(first[,i])&first[,i]<=observed_entry),
  simulated_entry_in_observed_month=if(is.na(observed_entry))NA_real_ else mean(!is.na(first[,i])&first[,i]==observed_entry),
  simulated_exit_by_sample_end=mean(!is.na(last_exit[,i])&last_exit[,i]<=T))
}))
fwrite(events,file.path(out,"event_comparison.csv"))
pdf(file.path(out,"entry_exit_diagnostics.pdf"),width=11,height=8.5)
par(mfrow=c(2,1),mar=c(4,4,3,1),oma=c(0,0,3,0))
for(b in x$brands[4:5]) {
 z<-d[brand==b];obs<-as.Date(life[brand==b,first_observed_sales])
 plot(z$month,z$ever_entered_probability,type="l",lwd=2,col="steelblue",ylim=c(0,1),xlab="",ylab="Probability entered by month",main=b)
 lines(z$month,as.numeric(z$month>=obs),type="s",lwd=2,col="black");abline(v=as.numeric(obs),lty=3)
 legend("bottomright",c("Simulated fraction ever entered","Observed first-sales indicator"),col=c("steelblue","black"),lty=1,lwd=2,bty="n")
}
mtext("Entry timing: stationary trial, 10,000 paths",outer=TRUE,font=2)
par(mfrow=c(3,1),mar=c(3,4,2,1),oma=c(0,0,3,0))
for(b in x$brands[1:3]) {
 z<-d[brand==b]
 plot(z$month,z$survival_probability,type="l",lwd=2,col="steelblue",ylim=c(0,1),xlab="",ylab="Survival probability",main=b)
 lines(z$month,z$observed_active,type="s",lwd=2)
}
mtext("Initial-incumbent survival: blue simulated, black observed",outer=TRUE,font=2)
par(mfrow=c(3,2),mar=c(3,4,2,1),oma=c(0,0,3,0))
for(b in x$brands) {
 z<-d[brand==b]
 plot(z$month,z$active_probability,type="l",lwd=2,col="steelblue",ylim=c(0,1),xlab="",ylab="Active probability",main=b)
 lines(z$month,z$observed_active,type="s",lwd=2)
}
plot.new();text(.5,.6,"Blue: simulated active probability\nBlack: observed activity spell\nGaps within sales spells remain active.")
mtext("Brand activity: stationary trial versus scanner-event proxies",outer=TRUE,font=2)
par(mfrow=c(1,1),mar=c(4,4,4,1))
plot(ct$month,ct$mean_active,type="n",ylim=c(0,5),xlab="",ylab="Number of active focal brands",main="Active-firm count: stationary trial versus observed")
polygon(c(ct$month,rev(ct$month)),c(ct$lower,rev(ct$upper)),col="gray85",border=NA)
lines(ct$month,ct$mean_active,col="steelblue",lwd=2);lines(ct$month,ct$observed_active,type="s",lwd=2)
legend("bottomleft",c("Simulated mean","Simulated 95% path interval","Observed"),col=c("steelblue","gray75","black"),lty=1,lwd=c(2,8,2),bty="n")
mtext("January 2013 market size and fringe held fixed; trial parameters, not historical fit",side=3,cex=.8)
dev.off()
writeLines(c("Stationary baseline diagnostic, 10,000 independent paths, seed 11062026, January 2013--December 2023.",
 sprintf("FC=%g/month; exponential entry mean=%g; normal scrap mean=0, SD=%g; beta=%.12f.",sol$parameters$FC,sol$parameters$mu_E,sol$parameters$sigma_S,sol$parameters$beta),
 "January 2013 M and fringe held fixed throughout; historical annual market-size updates are NOT implemented here.",
 "Entry in month t means active in month t+1. Exit after month t removes the brand in t+1. Initial three brands are left censored.",
 "Observed activity spans first through last positive full-scanner sales; internal gaps are retained. Sample-end sales are right censored.",
 "Simulated 95% count intervals describe path variation, not parameter uncertainty. Probability curves have simulation sampling error.",
 "Only five fixed focal brands are counted; all others remain passive fringe. No estimation, uniqueness claim, or external validation."),file.path(out,"README.txt"))
print(events)
