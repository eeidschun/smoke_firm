# Policy-independent conditional transition cache. Exact, no probability pruning.
# Cache keys encode ordered rivals, own next-type law, and candidate possibility.
# A cache is bound to ONE geometry/type law. Reuse across policies/fringe/payoffs.
anon_cached_expectation_factory <- function(game,max_entries=2e6,on_full=c("stop","clear")) {
 on_full<-match.arg(on_full);evictions<-0L
 force(game);stopifnot(max_entries>0,is.finite(max_entries))
 cache<-new.env(parent=emptyenv());entries<-0;hits<-0;misses<-0
 evaluate<-function(V,g,others,own_next,continue_prob,entry_prob) {
  # identity checks prevent accidentally using cached indices for another game.
  stopifnot(identical(g$states,game$states),identical(g$types,game$types),
   identical(dim(V),dim(game$present)))
  candidate<-entry_prob>0
  key<-paste(paste(others,collapse=","),paste(format(own_next,digits=17),collapse=","),
             candidate,sep="|")
  if(exists(key,cache,inherits=FALSE)) {obj<-get(key,cache);hits<<-hits+1}
  else {
   misses<<-misses+1
   n<-length(others)+as.integer(candidate)
   masks<-as.matrix(expand.grid(rep(list(0:1),n)))
   if(n==0)masks<-matrix(integer(),nrow=1,ncol=0)
   terms<-vector("list",nrow(masks));used<-0
   for(row in seq_len(nrow(masks))) {
    d<-list(list(state=integer(),prob=1))
    for(j in seq_along(others)) {
     law<-if(masks[row,j]==1)c(0,g$types$P[others[j],]) else c(1,rep(0,g$n_types))
     d<-anon_convolve(d,law)
    }
    if(candidate && masks[row,n]==1)d<-anon_convolve(d,c(0,g$types$G))
    idx<-integer();wt<-numeric()
    for(node in d)for(k in which(own_next>0)) {
     state<-sort(c(node$state,k))
     s<-anon_lookup_state(g,state)
     if(is.na(s))stop("Cached successor outside geometry")
     idx<-c(idx,s+(k-1L)*nrow(V));wt<-c(wt,node$prob*own_next[k])
    }
    stopifnot(abs(sum(wt)-1)<1e-10)
    used<-used+length(idx)
    if(used>max_entries)stop("Single conditional object exceeds cache budget")
    if(entries+used>max_entries) {
     if(on_full=="stop")stop("Conditional cache entry budget exceeded; use smaller game or a new backend")
     rm(list=ls(cache),envir=cache);entries<<-0;evictions<<-evictions+1L
    }
    terms[[row]]<-list(index=idx,weight=wt)
   }
   obj<-list(masks=masks,terms=terms);assign(key,obj,cache);entries<<-entries+used
  }
  q<-c(continue_prob,if(candidate)entry_prob else numeric())
  total<-0
  for(row in seq_len(nrow(obj$masks))) {
   action_weight<-prod(ifelse(obj$masks[row,]==1,q,1-q))
   if(action_weight>0) {
    term<-obj$terms[[row]]
    total<-total+action_weight*sum(term$weight*V[term$index])
   }
  }
  total
 }
 stats<-function()list(evictions=evictions,keys=length(ls(cache)),entries=entries,hits=hits,misses=misses,
  payload_bytes=sum(vapply(as.list(cache),function(x)as.numeric(object.size(x)),numeric(1))))
 list(expectation=evaluate,stats=stats)
}