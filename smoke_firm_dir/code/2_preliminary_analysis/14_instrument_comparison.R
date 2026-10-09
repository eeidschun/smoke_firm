## First-stage diagnostics only. Inputs are built by 1_build_data/9.
suppressPackageStartupMessages({library(data.table); library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(PRELIM_DIR, "instrument_comparison")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
d <- as.data.table(readRDS(file.path(SUPPORT_DIR, "demand_instrument_candidates.rds")))
fwrite(d, file.path(out_dir, "demand_instrument_candidates.csv"))
results <- list()
for (tax_name in c("TaxIV","TaxIV_geo")) for (count_name in c("n_brands_3st","n_brands_overlap")) {
  for (outcome in c("p_it","ln_s_i_g")) {
    formula <- reformulate(c("a_it",tax_name,count_name),response=outcome)
    fit <- feols(formula,data=d,vcov=~month)
    for (test in c("count_incremental","excluded_joint")) {
      pattern <- if(test=="count_incremental") paste0("^",count_name,"$") else
        paste0("^(",tax_name,"|",count_name,")$")
      wt <- wald(fit,keep=pattern,print=FALSE)
      cluster_df <- uniqueN(d$month)-1L
      results[[length(results)+1]] <- data.table(tax=tax_name,count=count_name,outcome,test,
        F=wt$stat,p=pf(wt$stat,wt$df1,cluster_df,lower.tail=FALSE),
        df1=wt$df1,df2=cluster_df,n=nrow(d))
    }
  }
}
res <- rbindlist(results); fwrite(res,file.path(out_dir,"first_stage_month_clustered.csv"));print(res)
cat("Geographic versus national counts equal:",sum(d$n_brands_overlap==d$n_brands_3st),"of",nrow(d),"\n")
cat("State coverage range:",range(d$n_states_operating),"\n")
cat("Revenue ratio (unweighted price * volume / revenue):\n")
print(quantile(d$p_it*d$mL/d$revenue_real,c(0,.25,.5,.75,1)))
