## Independent residualized QR checks and focused first-stage diagnostics.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source('smoke_firm_dir/code/fxns/1_paths.R');setFixest_nthreads(2)
out<-file.path(OUT_DIR,'demand_estimation','firm_state_month_2026-10-26')
b<-as.data.table(readRDS(file.path(out,'candidate_panel.rds')))
b[,valid_market:=Q_total<M_t & Q_total<M_t_k_monthly & Q_total<M_t_k_const]
d<-b[incumbent==TRUE & is.finite(avg_ml_per_ecig) & is.finite(a_lag1) & valid_market]
sp<-fread(file.path(out,'specifications.csv'));cc<-fread(file.path(out,'coefficients.csv'))
checks<-stages<-list()
for(i in which(sp$controls=='SV' & sp$market=='annual')){
 s<-sp[i];iv<-strsplit(s$instruments,' + ',fixed=TRUE)[[1]]
 ex<-c(if(s$quality=='Exogenous')'a_it','avg_ml_per_ecig','log_upc_variety')
 en<-c('price','ln_share',if(s$quality=='Endogenous')'a_it')
 d[,price:=get(s$price)];d[,y:=log(Q/M_t)-log1p(-Q_total/M_t)]
 cols<-c('y',ex,en,iv);mat<-as.matrix(d[,..cols])
 if(s$FE=='pooled') mat<-sweep(mat,2,colMeans(mat))
 if(s$FE=='brand_state')mat<-demean(mat,f=list(d$brand,d$STATE),tol=1e-10)
 if(s$FE=='brand_by_state')mat<-demean(mat,f=list(interaction(d$brand,d$STATE)),tol=1e-10)
 colnames(mat)<-cols
 X<-mat[,c(ex,en),drop=FALSE];Z<-mat[,c(ex,iv),drop=FALSE]
 stopifnot(qr(Z)$rank==ncol(Z))
 ref<-qr.solve(qr.fitted(qr(Z),X),mat[,'y'])
 actual<-cc[id==s$id & term%in%c(ex,paste0('fit_',en))]
 mapped<-c(ex,paste0('fit_',en));err<-max(abs(ref-actual$estimate[match(mapped,actual$term)]))
 checks[[s$id]]<-data.table(id=s$id,QR_slope_error=err)
 stopifnot(err<1e-6)
 fe<-switch(s$FE,pooled='',brand_state='brand + STATE',brand_by_state='brand^STATE')
 for(z in en){f<-paste(z,'~',paste(c(ex,iv),collapse=' + '));if(nzchar(fe))f<-paste(f,'|',fe)
  m<-feols(as.formula(f),d,vcov=~STATE+month,notes=FALSE);ct<-coeftable(m)
  stages[[paste(s$id,z)]]<-data.table(id=s$id,outcome=z,term=rownames(ct),estimate=ct[,1],std_error=ct[,2],p_value=ct[,4])
 }
}
fwrite(rbindlist(checks),file.path(out,'validation.csv'))
fwrite(rbindlist(stages),file.path(out,'first_stages_SV_annual.csv'))
summary<-sp[,.(fits=.N,strict_admissible=sum(sigma>0 & sigma<1),admissible_negative_alpha=sum(sigma>0 & sigma<1 & alpha<0)),by=.(price,quality)]
fwrite(summary,file.path(out,'summary.csv'));print(summary)
print(sp[controls=='SV' & FE=='brand_state' & market=='annual',.(price,quality,instruments,alpha,sigma,n)])
cat('Max QR error:',max(rbindlist(checks)$QR_slope_error),'\n')
