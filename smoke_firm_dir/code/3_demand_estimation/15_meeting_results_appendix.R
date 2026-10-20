## Consolidated meeting appendix, without re-estimating models.
suppressPackageStartupMessages(library(data.table))
source("smoke_firm_dir/code/fxns/1_paths.R")
root<-file.path(OUT_DIR,"demand_estimation","advisor_instruments_2026-10-20")
meeting<-file.path(FIRM_DIR,"docs","meetings")
exo<-fread(file.path(root,"original_48_grid","specifications.csv"))
exo[,`:=`(quality="Exogenous",n_endogenous=2L,endogenous="price + ln_s_i_g",
 sample=ifelse(sample=="available","528 available","524 common lag"))]
endo<-fread(file.path(root,"endogenous_quality_grid","specifications.csv"))
endo[,sample:="524 common lag"]
sp<-rbindlist(list(exo,endo),use.names=TRUE,fill=TRUE)
sp[,identification:=ifelse(overidentification_df==0,"Exactly identified","Overidentified")]
stopifnot(nrow(sp)==1776L,all(sp$n_excluded-sp$n_endogenous==sp$overidentification_df))
fwrite(sp,file.path(meeting,"demand_specification_index.csv"))
header<-c("# Complete demand results for the next advisor meeting","","Updated: 2026-10-20.","",
 "These tables contain all 1,776 runs in the expanded comparison, not only selected admissible examples. The historical 48-model label applies only to the original design. The expanded totals include deliberate repeated sample comparisons, not 1,776 independent pieces of evidence. The earlier exploratory 224-fit run is documented separately and is not added to this total because of overlapping designs and a different nicotine-only sample rule.","",
 "## Design and identification","",
 "| Quality assumption | Sample | Count of instrument sets | Controls x FE x price x market size | Fits |",
 "|---|---|---:|---|---:|",
 "| Exogenous | 528 complete-size rows | 9 without lag | 4 x 2 x 2 x 3 | 432 |",
 "| Exogenous | 524 common-lag rows | 19, including nonlag baselines | 4 x 2 x 2 x 3 | 912 |",
 "| Endogenous | 524 common-lag rows | 9 with lag and enough instruments | 4 x 2 x 2 x 3 | 432 |","",
 "Quality exogenous: two endogenous regressors (price and within-nest log share). Two excluded instruments = exactly identified; three = one overidentifying restriction. Quality endogenous: three endogenous regressors (price, within-nest log share and a_it). Three instruments = exactly identified; four = one overidentifying restriction. All instruments enter jointly. The role intended for lagged quality is identification of current quality, but 2SLS does not assign instruments exclusively to individual regressors. Tax plus lag alone is not estimated with endogenous quality because two instruments cannot identify three endogenous regressors.","",
 "All rows explicitly list the complete excluded instrument set. Nicotine remains included in demand in both quality treatments; its slope is instrumented in the endogenous-quality section. Size and variety, when present, are treated as exogenous in both sections. No month FE; standard errors clustered by month. The sample, quality assumption and all other settings for each fit appear in [demand_specification_index.csv](demand_specification_index.csv).","",
 "Admissibility is descriptive, not a model-selection rule. Conventional SEs and intervals are not weak-IV-robust inference. Persistent unobserved demand shocks may invalidate lag quality; sales-share-based counts require an exclusion argument. Overidentification df describes the restrictions available; it does not report a test or establish instrument validity.","",
 "Source results and diagnostics: [exogenous quality](../../output/demand_estimation/advisor_instruments_2026-10-20/original_48_grid/README.md), [endogenous quality](../../output/demand_estimation/advisor_instruments_2026-10-20/endogenous_quality_grid/README.md). No existing canonical inputs or prior fits were replaced.","",
 "# Part A: Current quality treated as exogenous","" )
writeLines(c(header,readLines(file.path(root,"original_48_grid","all_tables.md")),"",
 "# Part B: Current quality treated as endogenous","",
 readLines(file.path(root,"endogenous_quality_grid","all_tables.md"))),file.path(meeting,"demand_results_appendix.md"))
print(sp[,.(fits=.N),by=.(quality,n_excluded,n_endogenous,overidentification_df)])
