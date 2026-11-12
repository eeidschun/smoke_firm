source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input <- file.path(OUT_DIR,"static_pricing_subgame/observed_recovery_2026-10-27/incumbent_recovery.csv")
out <- file.path(OUT_DIR,"dynamic_entry_exit/independent_transitions_2026-11-03")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
hash <- tools::md5sum(input)
d <- fread(input)
d[, month_id := as.integer(format(as.Date(month),"%Y"))*12L+as.integer(format(as.Date(month),"%m"))]
setorder(d,brand,month_id)
stopifnot(!anyDuplicated(d[,.(brand,month_id)]))
d[, next_month_id := shift(month_id,type="lead"),by=brand]
d[, eligible := !is.na(next_month_id)&next_month_id==month_id+1L]
P <- list(); grids <- list(); counts <- list(); supports <- list()
for(v in c("quality","xi")) {
  x <- d[[v]]
  stopifnot(all(is.finite(x)))
  edges <- as.numeric(quantile(x,c(0,1/3,2/3,1),type=7))
  stopifnot(all(diff(edges)>0))
  b <- as.integer(cut(x,edges,include.lowest=TRUE,right=TRUE,labels=FALSE))
  d[,(paste0(v,"_state")) := b]
  z <- d[,.(brand,month,month_id,eligible,state=b,value=x)]
  z[,destination := shift(state,type="lead"),by=brand]
  tr <- z[eligible==TRUE]
  g <- z[,.(median=median(value),observations=.N,observed_min=min(value),observed_max=max(value)),by=state][order(state)]
  g[,`:=`(variable=v,lower_edge=edges[1:3],upper_edge=edges[2:4])]
  t <- merge(CJ(state=1:3,destination=1:3),tr[,.(transitions=.N),by=.(state,destination)],by=c("state","destination"),all.x=TRUE)
  t[is.na(transitions),transitions:=0L]
  t[,departures:=sum(transitions),by=state]
  stopifnot(all(t$departures>0))
  t[,probability:=transitions/departures]
  m <- matrix(t$probability,nrow=3,byrow=TRUE,dimnames=list(c("low","medium","high"),c("low","medium","high")))
  # Independent tabulation verifies orientation and exact empirical counts.
  raw <- table(factor(tr$state,levels=1:3),factor(tr$destination,levels=1:3))
  stopifnot(all(as.matrix(raw)==matrix(t$transitions,3,byrow=TRUE)),max(abs(rowSums(m)-1))<1e-12,sum(raw)==531L)
  previous <- fread(file.path(OUT_DIR,"dynamic_entry_exit/transition_bins_2026-11-03/transition_counts_probabilities.csv"))
  old <- previous[grid==paste0(if(v=="quality") "nicotine" else "xi","_quantile_3" )][order(state,destination)]
  stopifnot(identical(t$transitions,old$transitions))
  t[,variable:=v];counts[[v]]<-t;grids[[v]]<-g;P[[v]]<-m
  support <- merge(CJ(brand=unique(z$brand),state=1:3),tr[,.(departures=.N),by=.(brand,state)],by=c("brand","state"),all.x=TRUE)
  support[is.na(departures),departures:=0L];support[,variable:=v];supports[[v]]<-support
  fwrite(data.table(origin=rownames(m),as.data.table(m)),file.path(out,paste0(v,"_transition_matrix.csv")))
  cat("\n",v,"\n");print(g);print(m);print(t[,.(departures=unique(departures)),by=state])
}
# Joint-state index: nicotine varies fastest, matching exploration script.
grid <- CJ(xi_state=1:3,quality_state=1:3)
grid[,state:=.I]
grid[,`:=`(quality=grids$quality$median[quality_state],xi=grids$xi$median[xi_state])]
joint <- kronecker(P$xi,P$quality)
stopifnot(max(abs(rowSums(joint)-1))<1e-12)
for(i in 1:9) for(j in 1:9) stopifnot(abs(joint[i,j]-P$quality[grid$quality_state[i],grid$quality_state[j]]*P$xi[grid$xi_state[i],grid$xi_state[j]])<1e-12)
fwrite(rbindlist(grids),file.path(out,"bin_definitions_medians.csv"))
fwrite(rbindlist(counts),file.path(out,"transition_counts_probabilities.csv"))
fwrite(rbindlist(supports),file.path(out,"firm_marginal_origin_support.csv"))
fwrite(grid,file.path(out,"joint_state_grid.csv"))
fwrite(data.table(origin=1:9,as.data.table(joint)),file.path(out,"implied_joint_transition_matrix.csv"))
fwrite(d[,.(brand,month,in_estimation_sample,quality,xi,quality_state,xi_state,eligible)],file.path(out,"assigned_observations.csv"))
saveRDS(list(P_quality=P$quality,P_xi=P$xi,P_joint=joint,grid=grid,bins=rbindlist(grids),assumptions="Pooled, time-homogeneous, independent exogenous first-order processes; conditional on adjacent observed incumbent roster membership."),file.path(out,"transition_inputs.rds"))
stopifnot(identical(unname(hash),unname(tools::md5sum(input))))
fwrite(data.table(path=input,md5=unname(hash)),file.path(out,"input_hash.csv"))
writeLines(c("Rows = current state; columns = next-month state. States ordered low, medium, high.","Boundaries: pooled empirical terciles, R quantile type 7, over all 540 levels. Right-closed bins; first includes minimum.","Representatives: within-marginal-bin medians for both nicotine and xi, chosen for consistency.","Each matrix uses the same 531 adjacent calendar-month within-brand pairs. Includes 12 BLU 2018 inversion-only levels.","Unsmoothed empirical counts: no pseudo-counts, clipping, or inferred exits. Zeros are sample zeros, not demonstrated impossibilities.","These are roster-selected continuing observations, not independently verified economic continuation/exit data. Potential selection bias is unresolved.","Pooling, independence, first-order Markov structure and time homogeneity are maintained, not validated.","Fringe transitions, dependence across firms, costs, entry and exit remain unspecified.","Validation passed: independent count tabulation, agreement with prior marginal exploration, probability sums, joint-product indexing, unchanged source hash."),file.path(out,"README.txt"))
