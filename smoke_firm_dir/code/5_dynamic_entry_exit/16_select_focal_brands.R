source("smoke_firm_dir/code/fxns/1_paths.R")
library(data.table)
input_dir<-file.path(OUT_DIR,"dynamic_entry_exit/top5_admission_roster_2026-11-04")
files<-file.path(input_dir,c("demand_eligible_monthly_volume_ranks.csv","all_positive_sales_monthly_volume_ranks.csv"))
hashes<-tools::md5sum(files)
out<-file.path(OUT_DIR,"dynamic_entry_exit/focal_brand_selection_2026-11-05")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
results<-list()
for(j in seq_along(files)) {
 scope<-c("demand_eligible","all_positive_sales")[j]
 d<-fread(files[j]);d[,year:=as.integer(format(as.Date(month),"%Y"))]
 stopifnot(uniqueN(d$month)==132L,!anyDuplicated(d[,.(brand,month)]),all(d$mL>0))
 totals<-d[,.(total_mL=sum(mL)),by=brand];setorder(totals,-total_mL,brand)
 totals[,`:=`(cumulative_rank=.I,share=total_mL/sum(total_mL))]
 annual<-d[,.(annual_mL=sum(mL)),by=.(year,brand)];setorder(annual,year,-annual_mL,brand)
 annual[,`:=`(annual_rank=seq_len(.N),annual_share=annual_mL/sum(annual_mL)),by=year]
 leaders<-annual[annual_rank==1]
 top5<-totals[1:5,brand];selected<-union(top5,leaders$brand)
 chosen<-totals[brand %in% selected]
 chosen[,`:=`(in_cumulative_top5=brand %in% top5,annual_leader_years=vapply(brand,function(b)paste(leaders[brand==b,year],collapse="; "),character(1)))]
 coverage<-d[,.(focal_mL=sum(mL[brand %in% selected]),total_mL=sum(mL)),by=year][order(year)]
 coverage[,focal_share:=focal_mL/total_mL]
 fwrite(totals,file.path(out,paste0(scope,"_cumulative_rankings.csv")))
 fwrite(leaders,file.path(out,paste0(scope,"_annual_leaders.csv")))
 fwrite(chosen,file.path(out,paste0(scope,"_selected_union.csv")))
 fwrite(coverage,file.path(out,paste0(scope,"_annual_coverage.csv")))
 fwrite(annual,file.path(out,paste0(scope,"_annual_rankings.csv")))
 results[[scope]]<-data.table(sample=scope,union_count=length(selected),top5=paste(top5,collapse="; "),added_annual_leaders=paste(setdiff(leaders$brand,top5),collapse="; "),cumulative_union_share=sum(chosen$share))
 cat('\n',scope,'\n');print(chosen);print(leaders[,.(year,brand,annual_share)]);print(coverage[,.(year,focal_share)])
}
fwrite(rbindlist(results),file.path(out,"summary.csv"))
stopifnot(identical(unname(hashes),unname(tools::md5sum(files))))
fwrite(data.table(path=files,md5=unname(hashes)),file.path(out,"input_hashes.csv"))
writeLines(c("Selection diagnostic, not a new implemented dynamic model.","Rule: top five brands by cumulative 2013-2023 national liquid volume, union annual volume leader for each year.","Main universe matches demand filters (identified positive-sales UPC-months in >=3 stores). Sensitivity uses all identified positive-volume sales.","Tie rule: alphabetical brand order after equal volume; annual rankings saved for review. Brands, not ultimate-parent firms.","Uses full-sample information to select identities; descriptive retrospective restriction, not a forecast of future leaders.","No demand re-estimation, fringe reconstruction or replacement of current dynamic inputs performed.","Checks passed: 132 unique months, positive volume, unique brand-months and unchanged source hashes."),file.path(out,"README.txt"))
print(rbindlist(results))
