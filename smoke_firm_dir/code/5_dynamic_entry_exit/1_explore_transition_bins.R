source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input_dir <- file.path(OUT_DIR, "static_pricing_subgame/observed_recovery_2026-10-27")
out <- file.path(OUT_DIR, "dynamic_entry_exit/transition_bins_2026-11-03")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
files <- file.path(input_dir, c("incumbent_recovery.csv", "fringe_market_recovery.csv"))
hashes <- tools::md5sum(files)
d <- fread(files[1]); f <- fread(files[2])
d[, month_id := as.integer(format(as.Date(month), "%Y"))*12L + as.integer(format(as.Date(month), "%m"))]
setorder(d, brand, month_id)
stopifnot(!anyDuplicated(d[, .(brand, month_id)]), all(is.finite(d$quality)), all(is.finite(d$xi)))
d[, next_month := shift(month_id, type="lead"), by=brand]
d[, consecutive := !is.na(next_month) & next_month == month_id+1L]
f[, month_id := as.integer(format(as.Date(month), "%Y"))*12L + as.integer(format(as.Date(month), "%m"))]
setorder(f, month_id)
f[, consecutive := shift(month_id, type="lead") == month_id+1L]
f[is.na(consecutive), consecutive := FALSE]
# All cuts use pooled levels, including terminal observations; this is descriptive,
# not an out-of-sample forecasting exercise. Duplicate quantiles collapse bins.
make_bins <- function(x, k, method) {
  edges <- if (method == "quantile") unique(as.numeric(quantile(x, seq(0,1,length.out=k+1), type=7))) else seq(min(x),max(x),length.out=k+1)
  if(length(edges)<2) return(list(bin=rep(1L,length(x)), edges=c(min(x),max(x)), k=1L))
  list(bin=as.integer(cut(x, edges, include.lowest=TRUE, labels=FALSE)), edges=edges, k=length(edges)-1L)
}
summary_rows <- list(); all_states <- list(); all_pairs <- list(); cuts <- list(); brands <- list()
run_grid <- function(dat, vars, ks, method, scope) {
  b <- lapply(seq_along(vars), function(j) make_bins(dat[[vars[j]]],ks[j],method))
  state <- b[[1]]$bin
  nstate <- b[[1]]$k
  if(length(vars)==2) {state <- state+(b[[2]]$bin-1L)*nstate; nstate <- nstate*b[[2]]$k}
  z <- copy(dat); z[, state := state]
  if("brand" %in% names(z)) z[, destination := shift(state,type="lead"),by=brand] else z[, destination := shift(state,type="lead")]
  tr <- z[consecutive == TRUE]
  id <- paste(scope, method, paste(ks,collapse="x"),sep="_")
  occ <- z[,.(observations=.N),by=state]
  departures <- tr[,.(departures=.N),by=state]
  states <- merge(data.table(state=seq_len(nstate)),occ,by="state",all.x=TRUE)
  states <- merge(states,departures,by="state",all.x=TRUE)
  states[is.na(observations),observations:=0L]; states[is.na(departures),departures:=0L]
  pairs <- merge(CJ(state=seq_len(nstate),destination=seq_len(nstate)),tr[,.(transitions=.N),by=.(state,destination)],by=c("state","destination"),all.x=TRUE)
  pairs[is.na(transitions),transitions:=0L]
  pairs <- merge(pairs,states[,.(state,departures)],by="state")
  pairs[, probability := fifelse(departures>0,transitions/departures,NA_real_)]
  supported <- states[departures>0,departures]
  summary_rows[[id]] <<- data.table(grid=id, scope=scope,method=method,requested_bins=paste(ks,collapse="x"),actual_states=nstate,observations=nrow(z),transitions=nrow(tr),occupied_states=sum(states$observations>0),origin_states=sum(states$departures>0),origins_ge_10=sum(states$departures>=10),origins_ge_20=sum(states$departures>=20),min_positive_departures=if(length(supported)) min(supported) else NA_integer_,median_positive_departures=if(length(supported)) median(supported) else NA_real_,zero_transition_cells=sum(pairs$transitions==0),total_transition_cells=nstate^2,stay_fraction=mean(tr$state==tr$destination))
  states[,grid:=id]; pairs[,grid:=id]
  all_states[[id]] <<- states; all_pairs[[id]] <<- pairs
  cuts[[id]] <<- rbindlist(lapply(seq_along(vars),function(j)data.table(grid=id,variable=vars[j],edge=seq_along(b[[j]]$edges)-1L,value=b[[j]]$edges)))
  if("brand" %in% names(z)) {
    tab <- merge(CJ(brand=unique(z$brand),state=seq_len(nstate)),tr[,.(departures=.N),by=.(brand,state)],by=c("brand","state"),all.x=TRUE)
    tab[is.na(departures),departures:=0L]; tab[,grid:=id]; brands[[id]] <<- tab
  }
  if(scope=="joint" && ks[1]==ks[2]) {
    mat <- matrix(pairs$probability[order(pairs$state,pairs$destination)],nrow=nstate,byrow=TRUE)
    image(seq_len(nstate),seq_len(nstate),mat, zlim=c(0,1),col=hcl.colors(30,"Blues",rev=TRUE),xlab="Origin joint state",ylab="Destination joint state", main=paste(method,paste(ks,collapse=" x "),"bins: transition probabilities"))
    mtext(paste(nrow(tr),"consecutive firm-month transitions; blank = no observations at origin"),cex=.7)
  }
}
pdf(file.path(out,"transition_bin_diagnostics.pdf"),width=9,height=7)
for(method in c("quantile","equal_width")) {
  for(k in 2:6) {
    run_grid(d,"quality",k,method,"nicotine")
    run_grid(d,"xi",k,method,"xi")
    run_grid(f,"delta_F",k,method,"fringe")
  }
  for(ka in 2:6) for(kx in 2:6) run_grid(d,c("quality","xi"),c(ka,kx),method,"joint")
}
dev.off()
s <- rbindlist(summary_rows)
fwrite(s,file.path(out,"grid_summary.csv"))
fwrite(rbindlist(all_states),file.path(out,"state_occupancy.csv"))
fwrite(rbindlist(all_pairs),file.path(out,"transition_counts_probabilities.csv"))
fwrite(rbindlist(cuts),file.path(out,"bin_edges.csv"))
fwrite(rbindlist(brands),file.path(out,"firm_origin_support.csv"))
fwrite(d[,.(observations=.N,consecutive_transitions=sum(consecutive),first_month=min(month),last_month=max(month),nonconsecutive_forward_links=sum(!is.na(next_month)&!consecutive)),by=brand],file.path(out,"sample_by_firm.csv"))
# Mechanical checks: levels and transition counts reconcile; supported rows sum to one.
pairs <- rbindlist(all_pairs)
stopifnot(all(abs(pairs[departures>0,.(p=sum(probability)),by=.(grid,state)]$p-1)<1e-12))
stopifnot(all(pairs[,.(n=sum(transitions)),by=grid]$n == s$transitions[match(pairs[,unique(grid)],s$grid)]))
stopifnot(identical(unname(hashes),unname(tools::md5sum(files))))
fwrite(data.table(path=files,md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Exploratory bin support, not a selected/estimated dynamic model.","Pooled cuts and transitions across brands; firm-specific origin counts reported separately.","Only adjacent calendar months within the same brand count as incumbent transitions.","Annual incumbent roster membership is not economic entry/exit; gaps and terminal observations are not exits.","BLU 2018 inversion-only rows are included, consistent with the full static roster.","Quantile binning can collapse repeated edges; actual state counts are reported.","Unobserved origin rows have NA probabilities, not invented absorbing states; empty cells are not structural zeros.","10/20 departures are descriptive support thresholds, not statistical validity criteria.","Fringe is diagnosed separately; no joint industry-state transition matrix or independence assumption is imposed.","No stationarity, Markov order, causal exogeneity, or pooling assumption is validated by occupancy.","All mechanical reconciliation checks passed; input hashes unchanged."),file.path(out,"README.txt"))
print(s[scope=="joint" & requested_bins %in% c("2x2","3x3","4x4","5x5","6x6")])
pdf(file.path(out,"joint_state_occupancy.pdf"),width=9,height=6)
z <- rbindlist(all_states)
for(k in 2:6) {
  a <- z[grid==paste0("joint_quantile_",k,"x",k)]
  barplot(a$departures,names.arg=a$state,xlab="Joint nicotine / demand-shock state",ylab="Consecutive monthly departures",main=paste(k,"x",k,"quantile bins: observations supporting each transition row"),col="steelblue")
  abline(h=c(10,20),lty=c(2,3))
}
dev.off()
