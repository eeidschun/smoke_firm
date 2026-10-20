## Read completed grid results and render all specifications explicitly.
suppressPackageStartupMessages(library(data.table))
source("smoke_firm_dir/code/fxns/1_paths.R")
out<-file.path(OUT_DIR,"demand_estimation","advisor_instruments_2026-10-20","original_48_grid")
cc<-fread(file.path(out,"coefficients.csv"));sp<-fread(file.path(out,"specifications.csv"))
sets<-readRDS(file.path(out,"models.rds"))$instrument_sets
labels<-c(TaxIV_geo="Geographic tax",n_brands_3st="National active-brand count",
 n_brands_overlap="Geographic active-brand count",incumbent_annual="Annual incumbent count",
 incumbent_monthly="Monthly >7% count",a_lag1="One-month-lagged quality")
lines<-c("# All instrument and market-size comparison tables","",
 "Each row gives the COMPLETE excluded instrument set, jointly instrumenting price and within-nest log share. Current quality a_it is always an exogenous control. Sections identify additional controls, price, firm FE and sample. No month FE. Alpha is the signed price coefficient (expected negative). Each market-size cell is estimate (month-clustered SE). B = nicotine only, S = plus size, V = plus log UPC variety, SV = both. Available sample: 528 rows/132 months; common-lag sample: 524 rows/131 months. Annual/monthly/constant columns refer to MARKET SIZE, independently of instrument names.","",
 "The 48 original specifications are reproduced as the available-sample/unweighted-price rows with either of the original active-brand counts across all four control groups, both FE choices and three market sizes. The other rows extend that design. Monthly >7% count redefines the threshold for the instrument only; demand roster remains annual. See README.md and CSVs for diagnostics and validation.")
for(sample0 in c("available","common_lag"))for(price0 in c("p_it","p_it_volume_weighted"))for(control0 in c("B","S","V","SV"))for(fe0 in c(FALSE,TRUE)) {
 ss<-sp[sample==sample0 & price_measure==price0 & controls==control0 & firm_FE==fe0]
 lines<-c(lines,"",paste("##",sample0,"/",if(price0=="p_it")"Unweighted price" else "Volume-weighted price","/",control0,"/",if(fe0)"Firm FE" else "No firm FE"),"",
 "| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |",
 "|---|---:|---:|---:|---:|---:|---:|---:|")
 for(set0 in unique(ss$instrument_set)) {
  cells<-character()
  for(term0 in c("fit_price","fit_ln_s_i_g")) for(market0 in c("annual","monthly","constant")) {
   id0<-ss[instrument_set==set0 & market==market0,id]
   x<-cc[id==id0 & term==term0]
   stopifnot(nrow(x)==1L)
   cells<-c(cells,sprintf("%.3f (%.3f)",x$estimate,x$std_error))
  }
  lines<-c(lines,paste0("| ",paste(labels[sets[[set0]]],collapse=" + ")," | ",length(sets[[set0]])," | ",paste(cells,collapse=" | ")," |"))
 }
}
writeLines(lines,file.path(out,"all_tables.md"))
focus<-cc[sample=="common_lag" & controls=="SV" & firm_FE==TRUE &
 instrument_set %in% c("National","Geographic","Annual","Monthly","Lag","Annual_Lag","Monthly_Lag") & term=="fit_ln_s_i_g"]
print(dcast(focus,price_measure+instrument_set~market,value.var="estimate"))
