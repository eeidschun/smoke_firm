## Advisor comparison: full IV, OLS and partial IV, each with/without firm FE.
## No additional controls. Alpha is the signed price coefficient throughout.
rm(list=ls())
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
input<-file.path(SUPPORT_DIR,"demand_instrument_candidates.rds")
d<-as.data.table(readRDS(input));setorder(d,brand,month)
needed<-c("brand","month","y","a_it","p_it","ln_s_i_g","TaxIV_geo","n_brands_3st","n_brands_overlap")
stopifnot(!anyNA(d[,..needed]),!anyDuplicated(d[,.(brand,month)]))
for(v in setdiff(needed,c("brand","month")))stopifnot(all(is.finite(d[[v]])))
out_dir<-file.path(OUT_DIR,"demand_estimation","specification_comparison")
dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
specs<-data.table(id=c("M1","M2","M3","M4","M5","M6","D1","D2","D3","D4","D5","D6"),
 group=c(rep("Main",6),rep("Partial IV",6)),
 estimator=c(rep("Full IV",4),rep("OLS",2),rep("Share-only IV",4),rep("Price-only IV",2)),
 firm_FE=c(FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,TRUE,TRUE,FALSE,TRUE),
 count=c("n_brands_3st","n_brands_overlap","n_brands_3st","n_brands_overlap",NA,NA,
         "n_brands_3st","n_brands_overlap","n_brands_3st","n_brands_overlap",NA,NA))
coef_rows<-test_rows<-check_rows<-list();models<-list()
G<-uniqueN(d$month);n<-nrow(d)
for(i in seq_len(nrow(specs))) {
 s<-specs[i];endog<-switch(s$estimator,"Full IV"=c("p_it","ln_s_i_g"),"OLS"=character(),
   "Share-only IV"="ln_s_i_g","Price-only IV"="p_it")
 iv<-switch(s$estimator,"Full IV"=c("TaxIV_geo",s$count),"OLS"=character(),
   "Share-only IV"=s$count,"Price-only IV"="TaxIV_geo")
 exog<-setdiff(c("a_it","p_it","ln_s_i_g"),endog)
 fml<-paste("y ~",paste(exog,collapse=" + "))
 if(s$firm_FE)fml<-paste(fml,"| brand")
 if(length(endog))fml<-paste(fml,"|",paste(endog,collapse=" + "),"~",paste(iv,collapse=" + "))
 m<-feols(as.formula(fml),data=as.data.frame(d),vcov=~month,data.save=TRUE)
 stopifnot(nobs(m)==n)
 D<-if(s$firm_FE)model.matrix(~0+factor(brand),d) else matrix(1,n,1)
 X<-cbind(D,as.matrix(d[,.(p_it,ln_s_i_g,a_it)]))
 Z<-cbind(D,as.matrix(d[,c(exog,iv),with=FALSE]))
 stopifnot(qr(Z)$rank==ncol(Z))
 Xhat<-qr.fitted(qr(Z),X);stopifnot(qr(Xhat)$rank==ncol(Xhat))
 reference<-qr.solve(Xhat,d$y)
 terms<-c("p_it","ln_s_i_g","a_it");terms[terms %in% endog]<-paste0("fit_",terms[terms %in% endog])
 b<-coef(m)[terms];ct<-coeftable(m)[terms,,drop=FALSE]
 stopifnot(max(abs(b-tail(reference,3)))<1e-7,
   max(abs(resid(m)-(d$y-as.vector(X%*%reference))))<1e-7)
 coef_rows[[i]]<-data.table(id=s$id,parameter=c("alpha","sigma","beta_a"),estimate=b,
   std_error=ct[,2],p_value=ct[,4],ci_low=b-qt(.975,G-1)*ct[,2],ci_high=b+qt(.975,G-1)*ct[,2])
 check_rows[[i]]<-data.table(id=s$id,n=n,months=G,alpha_negative=b[1]<0,
   sigma_admissible=b[2]>=0 && b[2]<1,coefficient_check_error=max(abs(b-tail(reference,3))))
 specs[i,`:=`(endogenous=if(length(endog))paste(endog,collapse=", ") else "None",
   excluded_IVs=if(length(iv))paste(iv,collapse=", ") else "None")]
 for(y in endog) {
   form<-paste(y,"~",paste(c(exog,iv),collapse=" + "));if(s$firm_FE)form<-paste(form,"| brand")
   fs<-feols(as.formula(form),data=as.data.frame(d),vcov=~month)
   bb<-coef(fs)[iv];vv<-vcov(fs)[iv,iv,drop=FALSE]
   F<-as.numeric(crossprod(bb,solve(vv,bb)))/length(iv)
   reduced<-lm(reformulate(c(if(s$firm_FE)"factor(brand)",exog),response=y),data=d)
   r<-sum(resid(reduced)^2);u<-sum(resid(fs)^2)
   test_rows[[length(test_rows)+1]]<-data.table(id=s$id,outcome=y,F_month_clustered=F,
     df1=length(iv),df2=G-1,p_value=pf(F,length(iv),G-1,lower.tail=FALSE),
     partial_R2=(r-u)/r,F_iid=((r-u)/length(iv))/(u/(n-ncol(Z))))
 }
 models[[s$id]]<-m
}
cc<-rbindlist(coef_rows);tt<-rbindlist(test_rows);ck<-rbindlist(check_rows)
fwrite(specs,file.path(out_dir,"specifications.csv"));fwrite(cc,file.path(out_dir,"coefficients.csv"))
fwrite(tt,file.path(out_dir,"first_stages.csv"));fwrite(ck,file.path(out_dir,"model_checks.csv"))
saveRDS(list(models=models,specifications=specs,input_md5=unname(tools::md5sum(input))),file.path(out_dir,"models.rds"))
writeLines(capture.output(sessionInfo()),file.path(out_dir,"session_info.txt"))
cell<-function(model_id,param){x<-cc[id==model_id & parameter==param];sprintf("%.3f (%.3f)",x$estimate,x$std_error)}
fcell<-function(model_id,y){x<-tt[id==model_id & outcome==y];if(nrow(x))sprintf("%.2f",x$F_month_clustered) else "--"}
lines<-c("# Demand specification comparison", "",
 "The original Main and Partial IV tables use the same 7% incumbent sample and UPC-unweighted representative price, without additional controls or month FE. The product-size tables below use a separately reported complete-case sample.",
 sprintf("N = %d; %d month clusters. Coefficients shown with month-clustered standard errors in parentheses.",n,G),
 "Alpha is the signed price slope in +alpha * price (expected negative). Nicotine enters uninstrumented in every model.",
 "National count includes all eligible brands nationwide. Geographic count is the distinct-brand union over states where the focal firm sells.",
 "Tax means the geographic population-weighted tax. In full IV, tax and count jointly instrument both endogenous regressors.","")
for(table_group in c("Main","Partial IV")) {
 ss<-specs[group==table_group];ids<-ss$id;stopifnot(length(ids)==6L)
 lines<-c(lines,paste0("## ",table_group),"",paste0("| | ",paste(ids,collapse=" | ")," |"),
   paste0("|---|",paste(rep("---:",length(ids)),collapse="|"),"|"))
 row<-function(label,values)paste0("| ",label," | ",paste(values,collapse=" | ")," |")
 lines<-c(lines,row("Estimator",ss$estimator),row("Firm FE",ifelse(ss$firm_FE,"Yes","No")),
  row("Count IV",ifelse(is.na(ss$count),"--",ifelse(ss$count=="n_brands_3st","National","Geographic"))),
  row("Tax IV",ifelse(ss$estimator %in% c("Full IV","Price-only IV"),"Yes","No")),
  row("alpha: price",vapply(ids,cell,character(1),param="alpha")),
  row("beta_a: nicotine",vapply(ids,cell,character(1),param="beta_a")),
  row("sigma: nesting",vapply(ids,cell,character(1),param="sigma")),
  row("N",rep(n,length(ids))),row("Price first-stage F",vapply(ids,fcell,character(1),y="p_it")),
  row("Share first-stage F",vapply(ids,fcell,character(1),y="ln_s_i_g")),
  row("sigma in [0,1)",vapply(ids,function(model_id)if(ck[id==model_id,sigma_admissible])"Yes" else "No",character(1))),"")
}
lines<-c(lines,"## Interpretation and assumptions","",
 "- Partial-IV models are diagnostics: share-only IV treats price as exogenous; price-only IV treats within-nest share as exogenous. Their first stages include that untreated regressor as a control.",
 "- OLS treats both regressors as exogenous; an admissible OLS sigma does not validate that assumption.",
 "- First-stage F entries are joint tests of the excluded instruments using month-clustered covariance. They are not conditional weak-identification tests for the two-endogenous-regressor models. The CSV also includes IID F and partial R2.",
 "- Month clustering allows within-month dependence, not serial dependence across months. No model here tests or establishes exclusion. All IV specifications are exactly identified.",
 "- Full-IV sigma estimates remain outside [0,1); estimates are neither constrained nor clipped. No model is automatically selected for cost recovery.",
 "- Each model was checked against an independent explicit-dummy QR OLS/2SLS calculation and structural-residual reconstruction.",
 "- Product size has been constructed as a reusable characteristic; none of the estimates above include it. Size and variety specifications appear below.")
lines <- c(lines, "", readLines("smoke_firm_dir/code/3_demand_estimation/product_size_specification.md", warn = FALSE))
market_note <- file.path(out_dir,"market_size","README.md")
if(file.exists(market_note)) lines <- c(lines,"",readLines(market_note,warn=FALSE))
writeLines(lines,file.path(out_dir,"README.md"))
# A standalone HTML table for opening in a browser or printing for an advisor.
html<-c('<!doctype html><html><head><meta charset="utf-8"><title>Demand specification comparison</title>',
 '<style>body{font:15px Arial;margin:35px;color:#222}table{border-collapse:collapse;width:100%;margin-bottom:25px}th,td{padding:9px;border-bottom:1px solid #ddd;text-align:right}th:first-child,td:first-child{text-align:left}h1{font-size:24px}h2{font-size:19px}@media print{body{margin:10px;font-size:10px}h2{break-after:avoid}table{break-inside:avoid}}</style></head><body>')
in_table<-FALSE
for(line in lines) {
 if(startsWith(line,"|")) {
  if(grepl("^\\|---",line))next
  if(!in_table){html<-c(html,"<table>");in_table<-TRUE}
  cells<-trimws(strsplit(sub("\\|$","",sub("^\\|","",line)),"|",fixed=TRUE)[[1]])
  html<-c(html,paste0("<tr>",paste0("<td>",cells,"</td>",collapse=""),"</tr>"))
 } else {
  if(in_table){html<-c(html,"</table>");in_table<-FALSE}
  if(startsWith(line,"# "))html<-c(html,paste0("<h1>",substring(line,3),"</h1>")) else
  if(startsWith(line,"### "))html<-c(html,paste0("<h3>",substring(line,5),"</h3>")) else
  if(startsWith(line,"## "))html<-c(html,paste0("<h2>",substring(line,4),"</h2>")) else
  if(nzchar(line))html<-c(html,paste0("<p>",line,"</p>"))
 }
}
if(in_table)html<-c(html,"</table>")
writeLines(c(html,"</body></html>"),file.path(out_dir,"comparison.html"))
print(merge(specs,ck,by="id"));cat("Wrote advisor comparison to",out_dir,"\n")
