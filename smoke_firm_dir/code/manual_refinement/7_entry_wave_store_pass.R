## ============================================================================
## Raw store-coverage pass for the 2021 entry-wave investigation
## (feeds the 09_01_2026 coverage-vs-entry note, §3 and §7).
##
## For each raw store x week x UPC file: distinct RMS stores selling e-cigs and
## disposables per month, distinct e-cig UPCs per month, e-cig units per month;
## store-id sets for the 2020-2021 seam; and per-UPC store/state footprint for
## the 2021-2022 first-appearance cohorts. Writes a small cache to input/.
##
## Reads all 11 raw files (~10-15 min). Provenance / one-off; not on the
## standard rebuild path.
## ============================================================================
rm(list = ls())
suppressPackageStartupMessages({ library(data.table); library(dplyr); library(stringr) })
source("smoke_firm_dir/code/fxns/1_paths.R")
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")

load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))          # upc_month_t2
umt <- as.data.table(upc_month_t2)[, .(upc12, brand = str_trim(brand), type, month)]
utype  <- umt[, .N, by = .(upc12, type)][order(-N), .SD[1], by = upc12][, .(upc12, type)]
ubrand <- umt[, .N, by = .(upc12, brand)][order(-N), .SD[1], by = upc12][, .(upc12, brand)]

first_mo <- umt[, .(first = min(month)), by = brand]
cohort_brands <- first_mo[format(first, "%Y") %in% c("2021", "2022"), brand]
target_upc <- ubrand[brand %in% cohort_brands, upc12]

files <- list.files(RAW_DIR, pattern = "^full_.*7467.*\\.RData$", full.names = TRUE)
keep <- c("store_code_uc", "upc", "year_month", "units", "fips_state_descr")
seam_ym <- sprintf("20%02d-%02d", rep(c(20, 21), c(7, 6)), c(6:12, 1:6))

stores_ym <- list(); target_detail <- list(); store_ids <- list()
for (f in files) {
  e <- new.env(); load(f, envir = e)
  DT <- as.data.table(e$rms_w_attr)[e$rms_w_attr$prod_type == "ec", ..keep]
  rm(e); gc(FALSE)
  DT[, upc12 := pad12(upc)]
  DT <- merge(DT, utype, by = "upc12", all.x = TRUE)
  DT[is.na(type), type := "unclassified"]

  stores_ym[[f]] <- DT[, .(n_store_ec   = uniqueN(store_code_uc),
                           n_store_disp = uniqueN(store_code_uc[type == "Disposable"]),
                           n_upc_ec     = uniqueN(upc12),
                           units_ec     = sum(units)), by = year_month]
  store_ids[[f]] <- DT[year_month %in% seam_ym,
                       .(store_code_uc = unique(store_code_uc)), by = year_month]
  target_detail[[f]] <- DT[upc12 %in% target_upc,
                           .(n_store = uniqueN(store_code_uc), units = sum(units),
                             n_states = uniqueN(fips_state_descr)),
                           by = .(year_month, upc12)]
  cat(str_extract(basename(f), "20\\d\\d"), "done\n"); rm(DT); gc(FALSE)
}

cache <- list(stores_ym    = rbindlist(stores_ym)[order(year_month)],
              target_detail = rbindlist(target_detail),
              store_ids    = rbindlist(store_ids),
              ubrand = ubrand, utype = utype)
saveRDS(cache, file.path(SUPPORT_DIR, "entry_wave_store_cache.rds"))
cat("\nwrote", file.path(SUPPORT_DIR, "entry_wave_store_cache.rds"), "\n")

s20 <- cache$store_ids[year_month == "2020-12", store_code_uc]
s21 <- cache$store_ids[year_month == "2021-01", store_code_uc]
cat(sprintf("stores 2020-12: %d ; 2021-01: %d ; both: %d ; only-Jan21: %d ; only-Dec20: %d\n",
            length(s20), length(s21), length(intersect(s20, s21)),
            length(setdiff(s21, s20)), length(setdiff(s20, s21))))
