## SV3/SV4 first-stage and reduced-form coefficients; no rebuild.
suppressPackageStartupMessages({library(data.table);library(fixest)})
source("smoke_firm_dir/code/fxns/1_paths.R")
base <- file.path(OUT_DIR,"demand_estimation","specification_comparison")
inputs <- file.path(base,"product_size",c("models.rds","estimation_sample.rds"))
hashes <- tools::md5sum(inputs)
saved <- readRDS(inputs[1]); d <- as.data.table(readRDS(inputs[2]))
specs <- saved$specifications[id %in% c("SV3","SV4")]
out <- file.path(base,"sv_first_stages_reduced_form")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
rows <- list(); models <- list(); identities <- list()
controls <- c("a_it","avg_ml_per_ecig","log_upc_variety")
for(i in seq_len(nrow(specs))) {
  s <- specs[i]; rhs <- c(controls,"TaxIV_geo",s$count)
  Z <- cbind(model.matrix(~0+factor(brand),d),as.matrix(d[,..rhs]))
  for(y0 in c("p_it","ln_s_i_g","y")) {
    m <- feols(as.formula(paste(y0,"~",paste(rhs,collapse=" + "),"| brand")),
               data=as.data.frame(d),vcov=~month,data.save=TRUE)
    ct <- coeftable(m); ref <- tail(qr.solve(Z,d[[y0]]),length(rhs))
    stopifnot(nobs(m)==528L,max(abs(coef(m)[rhs]-ref))<1e-8)
    if(y0!="y") {
      old <- saved$models[[s$id]]$iv_first_stage[[y0]]
      stopifnot(max(abs(coef(old)[rhs]-coef(m)[rhs]))<1e-8,
                max(abs(vcov(old)[rhs,rhs]-vcov(m)[rhs,rhs]))<1e-8)
    }
    key <- paste(s$id,y0,sep="_");models[[key]] <- m
    rows[[key]] <- data.table(id=s$id,outcome=y0,term=rownames(ct),estimate=ct[,1],
      std_error=ct[,2],t_stat=ct[,3],p_value=ct[,4],
      ci_low=ct[,1]-qt(.975,131)*ct[,2],ci_high=ct[,1]+qt(.975,131)*ct[,2],n=nobs(m),months=uniqueN(d$month))
  }
  iv <- c("TaxIV_geo",s$count)
  pi <- cbind(coef(models[[paste0(s$id,"_p_it")]])[iv],
              coef(models[[paste0(s$id,"_ln_s_i_g")]])[iv])
  reduced <- coef(models[[paste0(s$id,"_y")]])[iv]
  b <- coef(saved$models[[s$id]])[c("fit_p_it","fit_ln_s_i_g")]
  stopifnot(max(abs(reduced-as.vector(pi %*% b)))<1e-8)
  identities[[s$id]] <- data.table(id=s$id,term=iv,reduced_form=reduced,
    price_contribution=pi[,1]*b[1],share_contribution=pi[,2]*b[2],
    alpha=b[1],sigma=b[2],reconstruction_error=reduced-as.vector(pi %*% b))
}
cc <- rbindlist(rows); identity <- rbindlist(identities)
stopifnot(identical(hashes,tools::md5sum(inputs)))
fwrite(cc,file.path(out,"coefficients.csv"));fwrite(identity,file.path(out,"iv_reduced_form_identity.csv"))
saveRDS(models,file.path(out,"models.rds"))
fwrite(data.table(path=names(hashes),md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(capture.output(sessionInfo()),file.path(out,"session_info.txt"))
labels <- c(TaxIV_geo="Geographic tax",a_it="Nicotine",avg_ml_per_ecig="Device size (mL)",log_upc_variety="Log UPC variety")
lines <- c("# SV3 and SV4: first stages and reduced forms","",
 "All six regressions use the saved 528-row matched sample, 132 month clusters, nicotine, device size, log UPC variety, and firm FE. No month FE. SV3 uses national brand count; SV4 uses geographic union brand count. Tax is geographic population-weighted real dollars per mL in both models. Brand count is in levels. Entries are coefficients (month-clustered standard errors), using the existing fixest covariance conventions. CSV includes t statistics, p-values and 95% confidence intervals with 131 reference df. Firm FE are absorbed; no common intercept is displayed.","",
 "Price first stage: p_it on tax, count and controls. Share first stage: log(s_it/s_gt) on the same regressors. Reduced form: y = log(s_it/s_0t) on the same regressors, using the annual baseline market size. Price and share are not included in the reduced form.")
for(id0 in specs$id) {
  lines <- c(lines,"",paste("##",id0),"",
    "| Regressor | Price first stage | Within-nest share first stage | Demand reduced form |",
    "|---|---:|---:|---:|")
  terms <- c("TaxIV_geo",specs[id==id0,count],controls)
  for(term0 in terms) {
    label <- if(term0 %in% names(labels)) labels[[term0]] else if(term0=="n_brands_3st") "National brand count" else "Geographic brand count"
    cells <- vapply(c("p_it","ln_s_i_g","y"),function(y0) {
      r <- cc[id==id0 & term==term0 & outcome==y0]
      sprintf("%.5f (%.5f)",r$estimate,r$std_error)
    },character(1))
    lines <- c(lines,paste0("| ",label," | ",paste(cells,collapse=" | ")," |"))
  }
}
lines <- c(lines,"","## Exact-identification relationship","",
 "For each excluded instrument z, its reduced-form coefficient obeys rho_z = alpha*pi_price,z + sigma*pi_share,z. This identity was checked against the saved IV estimates; decomposition is in iv_reduced_form_identity.csv. It helps read the first stages and outcome association jointly, but it is an algebraic relationship rather than an exclusion test.","",
 "All slope coefficients passed explicit-firm-dummy QR checks. Both first stages in each specification reproduce saved IV first-stage coefficients and covariance matrices. Saved inputs and demand fits retain their original hashes. No specification is selected and the IV investigation remains open.","",
 "Reproduce: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/9_sv_first_stages_reduced_form.R`.")
writeLines(lines,file.path(out,"README.md"))
cat(paste(lines,collapse="\n"),"\n");print(identity)
