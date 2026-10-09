## Build geographic instruments and the demand estimation input; retains the 7% sample.
## Geographic states are s, with s' the dummy index in the weight denominator.
## Presence: positive sales of an eligible national UPC-month in a state.
## Counts include all identified brands, including the focal brand, once each.
suppressPackageStartupMessages({library(data.table)})
source("smoke_firm_dir/code/fxns/1_paths.R")
load(file.path(SUPPORT_DIR, "demand_panel_firm_month.RData"))
load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))
u <- as.data.table(upc_month_t2)
u[, brand := trimws(brand)]
u <- unique(u[brand != "UNKNOWN" & units_sum > 0 & mL_sum > 0,
              .(year_month, upc12, brand)])
b <- as.data.table(readRDS(file.path(SUPPORT_DIR, "upc_month_store_breadth.rds")))
u <- merge(u, b[n_stores >= 3, .(year_month, upc12)], by=c("year_month","upc12"))
stopifnot(!anyDuplicated(u[, .(year_month, upc12)]))
cache <- file.path(SUPPORT_DIR, "brand_state_month_presence.rds")
if (file.exists(cache) && Sys.getenv("REBUILD_GEO_PRESENCE", "0") != "1") {
  presence <- readRDS(cache)
} else {
  raw_dir <- if (dir.exists(RAW_DIR)) RAW_DIR else "input"
  files <- list.files(raw_dir, pattern="^full_.*7467.*\\.RData$", full.names=TRUE)
  stopifnot(length(files)==11)
  presence <- rbindlist(lapply(files, function(path) {
    cache_path <- file.path(SUPPORT_DIR,"raw_attribute_month_cache",paste0(basename(path),".rds"))
    cached <- if(file.exists(cache_path)) readRDS(cache_path) else NULL
    info <- file.info(path)
    if(!is.null(cached$state_upc) && identical(cached$size,info$size) &&
       identical(cached$mtime,as.numeric(info$mtime))) {
      x <- merge(as.data.table(cached$state_upc),u,by=c("year_month","upc12"))
      ans <- unique(x[,.(year_month,brand,STATE)])
      cat(basename(path),nrow(ans),"presence rows from exact raw footprint cache\n")
      return(ans)
    }
    e <- new.env(); load(path, e)
    x <- as.data.table(e$rms_w_attr)
    x <- unique(x[prod_type == "ec" & units > 0,
                  .(year_month, upc12=sprintf("%012.0f", as.numeric(upc)),
                    STATE=sprintf("%02d", as.integer(fips_state_code)))])
    x <- merge(x, u, by=c("year_month","upc12"))
    ans <- unique(x[, .(year_month, brand, STATE)])
    cat(basename(path), nrow(ans), "presence rows\n"); flush.console()
    ans
  }))
  saveRDS(presence, cache)
}
read_pop <- function(file, years) {
  p <- fread(file.path(FIRM_DIR,"raw","census_pop",file))
  p <- melt(p[SEX==0 & ORIGIN==0], id.vars="STATE",
            measure.vars=paste0("POPESTIMATE",years), variable.name="year",value.name="pop")
  p[, .(pop=sum(pop)), by=.(STATE=sprintf("%02d",as.integer(STATE)),
                           year=as.integer(sub("POPESTIMATE","",year)))]
}
pop <- rbind(read_pop("sc-est2020int-alldata6.csv",2013:2019),
             read_pop("sc-est2023-alldata6.csv",2020:2023))
load(file.path(FIRM_DIR,"raw","ecig_taxes","ec_tax_cotti_per_mL.RData"))
tax <- as.data.table(closed_t)[,.(year_month,STATE=sprintf("%02d",as.integer(fips_state_code)),
                                 tau=real_tau_per_mL)]
presence[, year:=as.integer(substr(year_month,1,4))]
w <- merge(presence,pop,by=c("STATE","year"),all.x=TRUE)
w <- merge(w,tax,by=c("STATE","year_month"),all.x=TRUE)
stopifnot(!anyNA(w),!anyDuplicated(w[,.(year_month,brand,STATE)]))
geo <- w[,.(TaxIV_geo=sum(pop*tau)/sum(pop),n_states_operating=.N),by=.(year_month,brand)]
overlap <- merge(presence[,.(year_month,STATE,brand)],
                 presence[,.(year_month,STATE,competitor=brand)],
                 by=c("year_month","STATE"),allow.cartesian=TRUE)
counts <- overlap[,.(n_brands_overlap=uniqueN(competitor)),by=.(year_month,brand)]
geo <- merge(geo,counts,by=c("year_month","brand"))
d <- as.data.table(demand_im)
d[,year_month:=format(month,"%Y-%m")]
d <- merge(d,geo,by=c("year_month","brand"),all.x=TRUE)
stopifnot(nrow(d)==nrow(demand_im),!anyNA(d))
saveRDS(d, file.path(SUPPORT_DIR, "demand_instrument_candidates.rds"))
cat("Wrote demand_instrument_candidates.rds:", nrow(d), "rows\n")
