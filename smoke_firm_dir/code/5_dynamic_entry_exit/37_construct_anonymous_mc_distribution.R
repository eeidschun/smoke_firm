source("smoke_firm_dir/code/fxns/1_paths.R")
# Approved Nov 12: nine original-recovery firms, median then zero floor,
# equal firm weights, sorted groups of three, group means and 1/3 probabilities.
input<-file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27/incumbent_recovery.csv")
hash<-unname(tools::md5sum(input))
d<-read.csv(input,stringsAsFactors=FALSE)
stopifnot(all(c("brand","month","mc") %in% names(d)),
 all(is.finite(d$mc)),!anyNA(d$brand),!anyDuplicated(d[c("brand","month")]))
firms<-do.call(rbind,lapply(split(d,d$brand),function(z)data.frame(
 brand=z$brand[1],months=nrow(z),mc_median=median(z$mc))))
rownames(firms)<-NULL
stopifnot(nrow(firms)==9L,nrow(d)==540L)
firms$mc_floored<-pmax(0,firms$mc_median)
# Alphabetical tie break is deterministic; no boundary ties in current sample.
firms<-firms[order(firms$mc_floored,firms$brand),]
rownames(firms)<-NULL
firms$firm_weight<-1/nrow(firms)
firms$mc_bin<-rep(1:3,each=3)
support<-do.call(rbind,lapply(split(firms,firms$mc_bin),function(z)data.frame(
 mc_bin=z$mc_bin[1],mc=mean(z$mc_floored),probability=sum(z$firm_weight),
 firms=nrow(z),min_firm_mc=min(z$mc_floored),max_firm_mc=max(z$mc_floored))))
rownames(support)<-NULL
stopifnot(all(support$firms==3),all(support$mc>=0),all(diff(support$mc)>0),
 abs(sum(support$probability)-1)<1e-12,
 abs(sum(support$mc*support$probability)-mean(firms$mc_floored))<1e-12,
 identical(hash,unname(tools::md5sum(input))))
out<-file.path(OUT_DIR,"dynamic_entry_exit/anonymous_mc_2026-11-12")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
write.csv(firms,file.path(out,"firm_mc_assignments.csv"),row.names=FALSE)
write.csv(support,file.path(out,"mc_support.csv"),row.names=FALSE)
write.csv(data.frame(path=input,md5=hash),file.path(out,"input_hashes.csv"),row.names=FALSE)
saveRDS(list(mc=support$mc,p_mc=support$probability,support=support,firms=firms,
 source=input,source_md5=hash,decision_date="2026-11-12",
 method="Equal firm weights; within-firm median then floor at zero; sorted groups of three; group means",
 units="real dollars per mL; source recovery price units"),file.path(out,"entrant_mc_inputs.rds"))
# Supporting meeting tables use the meeting date and record Nov 12 origin in notes.
tables<-file.path(FIRM_DIR,"docs/meetings/tables")
dir.create(tables,recursive=TRUE,showWarnings=FALSE)
write.csv(firms,file.path(tables,"2026-11-16_mc_firm_assignments.csv"),row.names=FALSE)
write.csv(support,file.path(tables,"2026-11-16_mc_support.csv"),row.names=FALSE)
# Verify serialization, rather than only inspecting in-memory calculations.
saved<-readRDS(file.path(out,"entrant_mc_inputs.rds"))
stopifnot(identical(saved$mc,support$mc),identical(saved$p_mc,support$probability))
print(firms);print(support)
cat("PASS: 9 firms / 540 months, equal firm weights, floor after medians, three groups,\n",
 "probability mass, first-moment preservation, unchanged source hash and RDS roundtrip.\n")