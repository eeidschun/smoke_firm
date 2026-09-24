## ============================================================================
## Distinct-store breadth per UPC x month, from the raw store x week x UPC
## files. Not in any existing built panel (upc_month_niccorr_from_full.RData
## has units/mL/nicotine but no store-count) -- needed to screen out UPC-months
## driven by a handful of stores clearing overstock rather than genuine active
## distribution, before it feeds the top-5 roster or a_it (see
## analysis/12_supply_model_nicotine_state.R).
##
## Writes both the raw count (n_stores) and a share-of-that-month's-active-ec-
## panel version (store_share), since the total store panel size itself moves
## a lot over 2013-2023 (see the 09_01_2026 entry-wave note) -- store_share is
## there for reference/robustness checks, but n_stores (a raw floor) is what
## the filtering script actually uses by default: the question "is this UPC
## genuinely stocked somewhere" is about absolute retail footprint, not about
## keeping pace with however large Nielsen's tracked panel happens to be that
## year.
## ============================================================================
rm(list = ls())
suppressPackageStartupMessages({ library(data.table); library(stringr) })
source("smoke_firm_dir/code/fxns/1_paths.R")
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")

input_files <- list.files(RAW_DIR, pattern = "^full_.*7467.*\\.RData$", full.names = TRUE)
stopifnot(length(input_files) == 11)

collapse_file <- function(f) {
  e <- new.env(); load(f, envir = e)
  DT <- as.data.table(e$rms_w_attr)[prod_type == "ec", .(upc, year_month, store_code_uc)]
  rm(e); gc(verbose = FALSE)
  DT[, upc12 := pad12(upc)]
  by_upc <- DT[, .(n_stores = uniqueN(store_code_uc)), by = .(upc12, year_month)]
  by_mo  <- DT[, .(n_stores_month_total = uniqueN(store_code_uc)), by = year_month]
  cat(str_extract(basename(f), "20\\d\\d"), "done:", nrow(by_upc), "upc-month rows\n")
  rm(DT); gc(verbose = FALSE)
  list(by_upc = by_upc, by_mo = by_mo)
}

res <- lapply(input_files, collapse_file)
upc_breadth <- rbindlist(lapply(res, `[[`, "by_upc"))
mo_totals   <- unique(rbindlist(lapply(res, `[[`, "by_mo")))

upc_breadth <- merge(upc_breadth, mo_totals, by = "year_month")
upc_breadth[, store_share := n_stores / n_stores_month_total]
upc_breadth[, month := as.Date(paste0(year_month, "-01"))]
setcolorder(upc_breadth, c("month", "year_month", "upc12", "n_stores",
                            "n_stores_month_total", "store_share"))

saveRDS(upc_breadth, file.path(SUPPORT_DIR, "upc_month_store_breadth.rds"))
cat("\nwrote", file.path(SUPPORT_DIR, "upc_month_store_breadth.rds"),
    "(", nrow(upc_breadth), "upc-month rows,", uniqueN(upc_breadth$upc12), "distinct UPCs )\n")

cat("\n=== sensitivity: UPC-months dropped at various n_stores thresholds ===\n")
for (N in c(3, 5, 10, 20)) {
  n_drop <- sum(upc_breadth$n_stores < N)
  cat(sprintf("N=%2d: %6d / %6d UPC-months dropped (%.1f%%)\n",
              N, n_drop, nrow(upc_breadth), 100 * n_drop / nrow(upc_breadth)))
}
