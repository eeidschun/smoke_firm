source("smoke_firm_dir/code/fxns/1_paths.R")
paths<-c(file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27/incumbent_recovery.csv"),
 file.path(OUT_DIR,"dynamic_entry_exit/fixed_focal_supply_2026-11-05/focal_observed_recovery.csv"),
 file.path(OUT_DIR,"dynamic_entry_exit/fixed_focal_supply_2026-11-05/fringe_market_recovery.csv"))
for(path in paths) {
 cat("\nSOURCE:",path,"\n")
 if(!file.exists(path)){cat("MISSING\n");next}
 d<-read.csv(path)
 if("mc" %in% names(d))print(aggregate(mc~brand,d,function(x)
  c(n=length(x),min=min(x),median=median(x),max=max(x),negative=sum(x<0))))
 if("delta_F" %in% names(d) && !("brand" %in% names(d)))
  print(c(months=nrow(d),min=min(d$delta_F),max=max(d$delta_F),distinct=length(unique(d$delta_F))))
 cat("MD5:",unname(tools::md5sum(path)),"\n")
}