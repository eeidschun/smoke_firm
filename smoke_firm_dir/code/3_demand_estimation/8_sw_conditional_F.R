## Standalone Sanderson-Windmeijer diagnostics. Run from repository root.
## No data rebuild or demand-model/output replacement.
suppressPackageStartupMessages({library(data.table); library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
root <- file.path(OUT_DIR, "demand_estimation", "specification_comparison")
out <- file.path(root, "conditional_F")
dir.create(out, recursive=TRUE, showWarnings=FALSE)
files <- c(file.path(SUPPORT_DIR,"demand_instrument_candidates.rds"),
           file.path(root,"models.rds"),
           file.path(root,"product_size",c("models.rds","estimation_sample.rds")),
           file.path(root,"market_size","estimation_sample.rds"))
before <- tools::md5sum(files)
full <- as.data.table(readRDS(files[1])); setorder(full,brand,month)
matched <- as.data.table(readRDS(files[4]))
market <- as.data.table(readRDS(files[5]))
main_specs <- readRDS(files[2])$specifications[estimator=="Full IV"]
control_specs <- readRDS(files[3])$specifications
stopifnot(nrow(full)==540L,nrow(matched)==528L)
vars <- c("brand","month","p_it","ln_s_i_g","a_it","TaxIV_geo",
          "n_brands_3st","n_brands_overlap","avg_ml_per_ecig","log_upc_variety")
stopifnot(isTRUE(all.equal(as.data.frame(matched[,..vars]),
                          as.data.frame(market[,..vars]),check.attributes=FALSE)))

sw <- function(d,s,sample_name) {
  n <- nrow(d); G <- uniqueN(d$month)
  exog <- c("a_it",if(isTRUE(s$size_control)) "avg_ml_per_ecig",
            if(isTRUE(s$variety_control)) "log_upc_variety")
  iv <- c("TaxIV_geo",s$count)
  D <- if(s$firm_FE) model.matrix(~0+factor(brand),d) else matrix(1,n,1)
  W <- cbind(D,as.matrix(d[,..exog]))
  Z <- cbind(W,as.matrix(d[,..iv])); qz <- qr(Z)
  stopifnot(qz$rank==ncol(Z))
  # Orthogonal instrument basis improves numerical conditioning; Wald is invariant.
  Zr <- qr.resid(qr(W),as.matrix(d[,..iv]))
  H <- qr.Q(qr(Zr)); stopifnot(ncol(H)==2L)
  X <- as.matrix(d[,.(p_it,ln_s_i_g)])
  Xh <- qr.fitted(qz,X)
  correction <- G/(G-1)*(n-1)/(n-ncol(Z))
  rows <- lapply(1:2,function(j) {
    o <- 3-j
    # Conditional 2SLS of x_j on actual x_o and W, instrumenting x_o with Z.
    b <- qr.solve(cbind(W,Xh[,o]),X[,j])
    structural <- X[,j]-as.vector(cbind(W,X[,o]) %*% b)
    gamma <- as.vector(crossprod(H,structural))
    # SW adjustment uses v_j - delta*v_o, NOT x_j - delta*xhat_o.
    u <- qr.resid(qz,structural)
    scores <- rowsum(H*as.vector(u),as.character(d$month),reorder=FALSE)
    V0 <- crossprod(scores)
    Wald <- as.numeric(crossprod(gamma,solve(V0,gamma)))
    F <- Wald/correction # numerator df = excluded IVs - endog + 1 = 1
    Fiid <- sum(gamma^2)/(sum(u^2)/(n-ncol(Z)))
    # Independent formula-based conditional IV and full-design sandwich checks.
    f <- paste(colnames(X)[j],"~",paste(exog,collapse=" + "))
    if(s$firm_FE) f <- paste(f,"| brand")
    f <- paste(f,"|",colnames(X)[o],"~",paste(iv,collapse=" + "))
    reference <- feols(as.formula(f),data=as.data.frame(d))
    stopifnot(max(abs(resid(reference)-structural))<1e-7)
    fit <- lm(structural ~ Z - 1)
    ind <- (ncol(W)+1):ncol(Z)
    vv <- sandwich::vcovCL(fit,cluster=d$month,type="HC1",cadjust=TRUE)[ind,ind]
    bb <- coef(fit)[ind]
    Fref <- as.numeric(crossprod(bb,solve(vv,bb)))
    iidref <- sum(qr.fitted(qr(Zr),structural)^2)/
      (sum(resid(fit)^2)/df.residual(fit))
    stopifnot(abs(F-Fref)<1e-7,abs(Fiid-iidref)<1e-7)
    ordinary <- fread(file.path(root,if(sample_name=="Matched") "product_size" else "","first_stages.csv"))
    data.table(sample=sample_name,id=s$id,controls=if(sample_name=="Matched") s$group else "Baseline",
      firm_FE=s$firm_FE,count=s$count,outcome=colnames(X)[j],n=n,months=G,
      ordinary_F=ordinary[id==s$id & outcome==colnames(X)[j],F_month_clustered],
      SW_F_month_clustered=F,df1=1L,df2=G-1,
      p_value=pf(F,1,G-1,lower.tail=FALSE),SW_F_iid=Fiid,iid_df2=n-ncol(Z),
      cluster_correction=correction,conditional_delta=tail(b,1),
      validation_error=abs(F-Fref))
  })
  rbindlist(rows)
}
results <- rbindlist(c(lapply(seq_len(nrow(main_specs)),function(i) sw(full,main_specs[i],"Full")),
                      lapply(seq_len(nrow(control_specs)),function(i) sw(matched,control_specs[i],"Matched"))))
stopifnot(identical(before,tools::md5sum(files)),nrow(results)==40L)
fwrite(results,file.path(out,"conditional_F.csv"))
fwrite(data.table(path=names(before),md5=unname(before)),file.path(out,"input_hashes.csv"))
writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
lines <- c("# Sanderson-Windmeijer conditional F diagnostics","","Run date: 2026-10-08.","",
 "Price and within-nest log share are jointly endogenous. Geographic tax and the indicated brand count are the two excluded instruments. Tests condition on the other instrumented regressor, nicotine, the indicated controls, and firm FE where applicable. No month FE. Full sample: 540 rows; matched: 528 rows, excluding BLU 2018. Both have 132 month clusters.","",
 "| Sample | Model | Controls | Firm FE | Count | Ordinary F price | Ordinary F share | SW F price | SW F share |",
 "|---|---|---|---|---|---:|---:|---:|---:|")
for(sample0 in unique(results$sample)) for(id0 in unique(results[sample==sample0,id])) {
  r <- results[sample==sample0 & id==id0]
  lines <- c(lines,sprintf("| %s | %s | %s | %s | %s | %.2f | %.2f | %.2f | %.2f |",
    sample0,id0,r$controls[1],if(r$firm_FE[1]) "Yes" else "No",
    if(r$count[1]=="n_brands_3st") "National" else "Geographic",
    r$ordinary_F[1],r$ordinary_F[2],r$SW_F_month_clustered[1],r$SW_F_month_clustered[2]))
}
lines <- c(lines,"","## Method and validation","",
 "For each endogenous x_j, estimate its conditional 2SLS regression on the other actual endogenous regressor x_o and exogenous W, with instruments [W,Z]. Regress the resulting structural residual on [W,Z]. Form the Wald quadratic of the two excluded-instrument coefficients using month-clustered scores from this auxiliary regression. The residual used for covariance is v_j - delta*v_o (the SW variance adjustment). Divide the Wald by L-K+1 = 2-2+1 = 1, not by two.","",
 "The reported cluster covariance uses CR1 = G/(G-1) * (N-1)/(N-rank([W,Z])); explicit firm dummies count toward rank. F-reference df are (1,131). CSV p-values test zero conditional relevance/rank loss; they do not test adequate strength or exclusion. IID statistics and their residual df are provided separately, not substituted for the clustered results.","",
 "Implementation follows the SW block in ivreg2/ivreghdfe (conditional actual-regressor residuals, auxiliary excluded-IV Wald, reduced numerator df, and cluster correction). All 40 calculations pass independent fixest conditional-IV residual and sandwich::vcovCL full-design covariance checks plus an IID auxiliary-regression check. Input hashes are unchanged after the run. No demand fits or canonical inputs were overwritten.","",
 "Market-size alternatives change only the demand outcome/outside share. Their saved first-stage variables were checked identical to the matched sample, so all 48 market-size fits inherit the corresponding B/S/V/SV conditional statistics. Re-estimating these tests for each denominator would duplicate results.","",
 "## Interpretation","",
 "Full-sample M1-M4: conditional F ranges from 15.08 to 62.68; firm-FE models are the weakest (price 15.08-15.91, share 17.91-18.95). Matched B/S/V/SV models: 40.39-164.50. With both controls and firm FE, national-count price/share F are 81.38/79.57; geographic-count values are 82.31/78.38. These results do not show an obvious collapse in conditional relevance explaining sigma > 1. The large change between M3/M4 and B3/B4 also makes sample influence worth investigating; it does not establish why BLU 2018 matters.","",
 "A high ordinary first-stage F can coexist with a low SW conditional F if the instruments predict nearly the same combination of price and share. Small conditional statistics make separate alpha and sigma estimation vulnerable to weak identification. A large statistic does not establish instrument exclusion or validate the market-size construction. F=10 is only a rough descriptive benchmark here; IID Stock-Yogo critical values do not provide calibrated bias/size guarantees under month clustering. Month clustering does not address dependence across months. These tests alone cannot establish the cause of sigma > 1 or select a supply-side specification.","",
 "Sources: [Sanderson and Windmeijer (2016)](https://ifs.org.uk/journals/weak-instrument-f-test-linear-iv-models-multiple-endogenous-variables); [ivreg2/ivreghdfe source, SW block](https://github.com/sergiocorreia/ivreghdfe/blob/master/src/ivreghdfe.ado#L6038).","",
 "Reproduce from repository root: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/8_sw_conditional_F.R`.")
writeLines(lines,file.path(out,"README.md"))
print(results[,.(sample,id,outcome,ordinary_F,SW_F_month_clustered,p_value)])
