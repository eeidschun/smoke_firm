## Independent finite-difference checks of implemented demand primitives.
source('smoke_firm_dir/code/fxns/1_paths.R')
source(file.path(CODE_DIR,'4_static_pricing_subgame','1_static_demand_functions.R'))
suppressPackageStartupMessages(library(data.table))
out<-file.path(OUT_DIR,'static_pricing_subgame','observed_recovery_2026-10-27')
z<-readRDS(file.path(out,'observed_market_inputs.rds'))
d<-as.data.table(z$incumbents);m<-as.data.table(z$markets)
errors<-list()
for(month0 in unique(d$month)){
 x<-d[month==month0];f<-m[month==month0,delta_F];h<-1e-5
 s<-static_shares(x$price,x$nonprice_utility,f,z$alpha,z$sigma)
 for(j in seq_len(nrow(x))){
  up<-down<-x$price;up[j]<-up[j]+h;down[j]<-down[j]-h
  su<-static_shares(up,x$nonprice_utility,f,z$alpha,z$sigma)
  sd<-static_shares(down,x$nonprice_utility,f,z$alpha,z$sigma)
  numeric<-(su$share-sd$share)/(2*h)
  analytic<--z$alpha*s$share*(z$sigma*s$within[j]/(1-z$sigma)+s$share[j])
  analytic[j]<-static_own_derivative(s$share[j],s$within[j],z$alpha,z$sigma)
  fringe_analytic<--z$alpha*s$fringe_share*(z$sigma*s$within[j]/(1-z$sigma)+s$share[j])
  errors[[paste(month0,j)]]<-data.table(month=as.Date(month0,origin='1970-01-01'),brand=x$brand[j],
    derivative_error=max(abs(numeric-analytic)),
    fringe_derivative_error=abs((su$fringe_share-sd$fringe_share)/(2*h)-fringe_analytic))
 }
}
checks<-rbindlist(errors);stopifnot(nrow(checks)==540,max(checks$derivative_error)<1e-7,max(checks$fringe_derivative_error)<1e-7)
# Multinomial-logit limiting case and stable extremes.
p<-c(2,3);v<-c(1,.5);a<--.4;f<--.2
s<-static_shares(p,v,f,a,0);manual<-exp(c(v+a*p,f));manual<-manual/(1+sum(manual))
stopifnot(max(abs(c(s$share,s$fringe_share)-manual))<1e-12,
 max(abs(static_own_derivative(s$share,s$within,a,0)-a*s$share*(1-s$share)))<1e-12)
for(vv in list(c(1000,999),c(-1000,-999))){
 s<-static_shares(p,vv,mean(vv),a,.95)
 stopifnot(all(is.finite(s$log_share)),is.finite(s$log_outside),
 abs(sum(s$share)+s$fringe_share+s$outside_share-1)<1e-10)
}
stopifnot(inherits(try(static_shares(p,v,f,.4,.8),silent=TRUE),'try-error'),
 inherits(try(static_shares(p,v,f,-.4,1),silent=TRUE),'try-error'))
hashes<-fread(file.path(out,'input_hashes.csv'))
stopifnot(all(unname(tools::md5sum(hashes$path))==hashes$md5))
fwrite(checks,file.path(out,'finite_difference_validation.csv'))
writeLines(c('540 observed incumbent own/cross derivative perturbations passed, including passive-fringe response.',
'Multinomial-logit limiting case, extreme-utility stability, parameter guards, and unchanged source hashes passed.'),file.path(out,'validation.txt'))
print(checks[,.(perturbations=.N,max_derivative_error=max(derivative_error),max_fringe_derivative_error=max(fringe_derivative_error))])
