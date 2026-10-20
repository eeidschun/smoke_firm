suppressPackageStartupMessages(library(data.table))
source("smoke_firm_dir/code/fxns/1_paths.R")
meeting<-file.path(FIRM_DIR,"docs","meetings")
root<-file.path(OUT_DIR,"demand_estimation","advisor_instruments_2026-10-20")
sp<-fread(file.path(meeting,"demand_specification_index.csv"))
cc<-rbindlist(lapply(c("original_48_grid","endogenous_quality_grid"),function(folder)fread(file.path(root,folder,"coefficients.csv"))),fill=TRUE)
sig<-cc[term=="fit_ln_s_i_g",.(id,sigma=estimate,sigma_se=std_error)]
alpha<-cc[term=="fit_price",.(id,alpha=estimate)]
x<-merge(merge(sp,sig,by="id"),alpha,by="id")
stopifnot(nrow(x)==1776L,!anyDuplicated(x$id))
x[,admissible:=sigma>0 & sigma<1]
x[,lag_quality:=grepl("a_lag1",excluded_instruments,fixed=TRUE)]
fwrite(x[admissible==TRUE],file.path(meeting,"sigma_between_zero_and_one.csv"))
summ<-function(keys)x[,.(total=.N,admissible=sum(admissible),pct=100*mean(admissible)),by=keys]
print(summ(c("quality","price_measure","firm_FE")))
print(summ(c("quality","instrument_set")))
print(summ(c("quality","controls")))
print(summ(c("quality","market")))
print(summ(c("quality","lag_quality")))
print(x[admissible==TRUE,.(n=.N,negative_alpha=sum(alpha<0),min_sigma=min(sigma),max_sigma=max(sigma))])
fwrite(summ(c("quality","price_measure","firm_FE","instrument_set")),file.path(meeting,"sigma_family_counts.csv"))
lines<-c("# Families with 0 < sigma < 1","",
 paste0(sum(x$admissible)," of ",nrow(x)," runs have a point estimate strictly between zero and one. Counts include deliberate sample-matched repetitions. They are descriptive, not independent evidence or a validity test."))
for(keys in list(c("quality","price_measure","firm_FE"),c("quality","instrument_set"),c("quality","controls"),c("quality","market"))) {
 tab<-summ(keys)
 lines<-c(lines,"",paste("##",paste(keys,collapse=" / ")),"",
 paste0("| ",paste(c(keys,"Admissible / total","Percent"),collapse=" | ")," |"),
 paste0("|",paste(rep("---",length(keys)+2),collapse="|"),"|"))
 for(i in seq_len(nrow(tab)))lines<-c(lines,paste0("| ",paste(c(unlist(tab[i,..keys]),paste0(tab$admissible[i]," / ",tab$total[i]),sprintf("%.1f%%",tab$pct[i])),collapse=" | ")," |"))
}
writeLines(lines,file.path(meeting,"sigma_family_summary.md"))
good<-x[admissible==TRUE]
stopifnot(nrow(good)==357L)
annual<-grepl("incumbent_annual",good$excluded_instruments,fixed=TRUE)
monthly<-grepl("incumbent_monthly",good$excluded_instruments,fixed=TRUE)
stopifnot(sum(annual)==297L,sum(!annual & monthly)==55L,sum(!annual & !monthly)==5L)
section<-c("### Interpretation and checks","",
 "**357 of 1,776 runs have 0 < sigma < 1.** There are enough that families are more informative than a list in the main notes. These counts include deliberate sample-matched repetitions; they are not independent successes. The [complete qualifying-run list](sigma_between_zero_and_one.csv) records each specification, instrument list, identification status, sigma, SE and alpha. The [family breakdown](sigma_family_summary.md) includes denominators.","",
 "**The clearest pattern is the combination of volume-weighted price and an incumbent-count instrument, often without firm FE.** The qualifying runs are not confined to one control set, one market-size definition, lag-quality models, or endogenous-quality models.","",
 "| Price and firm FE family | Runs with 0 < sigma < 1 / all runs in family |",
 "|---|---:|",
 "| Volume-weighted price, no firm FE | 232 / 444 |",
 "| Volume-weighted price, firm FE | 83 / 444 |",
 "| Unweighted price, no firm FE | 35 / 444 |",
 "| Unweighted price, firm FE | 7 / 444 |","",
 "- **Instruments:** 297 qualifying runs include annual incumbent count (possibly with monthly count, active-brand count or lag quality); 55 include monthly >7% count without annual count; the remaining 5 use tax + lagged quality alone. No tax + original active-brand-count set qualifies, even when supplemented only with lagged quality, under either quality treatment. Every qualifying run therefore uses an incumbent-count instrument or the weak tax-plus-lag-only set.",
 "- **Lagged quality is not required:** 171 qualifying runs omit it and 186 include it. The five qualifying tax-plus-lag-only models belong to the previously flagged weak-instrument family and should not be treated as a resolution on the basis of their point estimates.",
 "- **Quality treatment:** 260 / 1,344 exogenous-quality runs qualify; 97 / 432 endogenous-quality runs qualify. All endogenous-quality runs include lag quality by construction, so this is not evidence that lag quality itself causes admissibility.",
 "- **Controls:** qualifying counts are 64 / 444 for nicotine only, 80 / 444 with size, 90 / 444 with log variety, and 123 / 444 with both. Neither size nor variety is universally required.",
 "- **Market size:** 118 / 592 annual, 133 / 592 monthly, and 106 / 592 constant-intensity runs qualify. No market-size definition is universally required.","",
 "Of the 357 qualifying sigma estimates, **354 also have a negative price coefficient; 3 do not**. Admissibility here refers only to the sigma point estimate: it does not require its confidence interval to lie within (0,1), a positive quality coefficient, or strong instruments. The full results should be checked for those features before selecting a specification.","",
 "All original 48 baseline coefficients and covariance matrices reproduce. New fits pass independent QR coefficient and structural-residual checks. Conditional F calculations account for two or three endogenous regressors; all three first stages are exported for endogenous-quality models. Original inputs and fits remain unchanged.","",
 "Overidentification df count restrictions; no overidentification test has been run. Neither an admissible sigma nor additional instruments establish exclusion. Lagged quality may correlate with persistent demand shocks; share-threshold counts depend on observed sales. Conventional intervals are not weak-IV-robust. No model selected and no sigma clipping.")
path<-file.path(meeting,"advisor_meeting_work_log.md")
old<-readLines(path,warn=FALSE)
start<-which(old=="### Interpretation and checks")
stopifnot(length(start)==1L)
writeLines(c(old[seq_len(start-1L)],section),path)
