## ============================================================================
## UPC x month corrected panel  (national, monthly)
##
## Same row-level transform as 3_build_t2_panel_niccorr.R -- cartridge-scaling fix,
## VUSE family label/liquid corrections, manual UPC overrides, mL imputation map,
## HeatStick / hardware exclusions, brand cascade, T2 type -- but aggregated to
## (year_month, brand, upc12, type) instead of (year_month, brand, type).
##
## Two-stage for memory: (1) data.table collapse of the store x week raw file to
## (upc, year_month, product-attributes) carrying unit/revenue sums; (2) apply the
## per-UPC corrections on that small table. Feeds the 7.5 diagnostics with a
## MONTHLY UPC count and a monthly UPC-unweighted nicotine series. Writes a NEW
## cache; does not touch the canonical bt_month_t2_niccorr panel.
##
## Validation: collapsing this panel over upc12 reproduces bt_month_t2.
## ============================================================================

rm(list = ls())
suppressPackageStartupMessages({ library(data.table); library(dplyr); library(tidyr); library(stringr) })

source("smoke_firm_dir/code/fxns/1_paths.R")
raw_input_dir <- RAW_DIR
support_dir   <- SUPPORT_DIR

fxn("3_t2_classify.R")
fxn("2_upc_overrides.R")       # YIELD_FACTOR, overrides, EXCLUDE
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")

upc_ov <- MANUAL_UPC_OVERRIDES %>%
  mutate(upc12 = pad12(upc),
         ov_total    = liq_cart_f * num_cartridges,
         ov_carts    = num_cartridges,
         ov_nicyield = ifelse(!is.na(nic_mg_per_ml), ov_total * nic_mg_per_ml * YIELD_FACTOR, NA_real_),
         ov_t2       = t2_type) %>%
  select(upc12, ov_total, ov_carts, ov_nicyield, ov_t2)

impmap_path <- file.path(support_dir, "missing_mL_imputation_map.rds")
impmap_raw  <- if (file.exists(impmap_path)) readRDS(impmap_path) else
  list(map = tibble(upc = character(), mL_total_imputed = numeric(),
                    nic_yield_tot_imputed = numeric(), t2_type_override = character()))
impmap <- impmap_raw$map %>% mutate(upc12 = pad12(upc)) %>%
  select(upc12, map_mL = mL_total_imputed, map_nicyield = nic_yield_tot_imputed,
         map_t2 = t2_type_override)

exclude12 <- pad12(EXCLUDE_UPCS)
load(file.path(support_dir, "label_maps.RData"))
escape_re <- function(x) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
brand_prefix_regex <- paste0("^(", paste(escape_re(label_maps$brand_vocab), collapse = "|"), ")")

mcorr <- readr::read_csv(file.path(support_dir, "manual_nic_corrections.csv"), show_col_types = FALSE) %>%
  mutate(upc12 = pad12(upc12))
exclude12 <- union(exclude12, mcorr %>% filter(exclude == 1) %>% pull(upc12))
corr_lab <- mcorr %>% filter(is.na(exclude) | exclude == 0) %>%
  select(upc12, clabel = true_label_mg_per_ml, cmlcart = true_mL_per_cart)

input_files <- list.files(raw_input_dir, pattern = "^full_.*7467.*\\.RData$", full.names = TRUE)
stopifnot(length(input_files) == 11)

## ---- stage 1: collapse each raw store x week file to upc x month x attributes ----
keep_cols <- c("upc", "year_month", "units", "price_d_prmult", "infl_mult",
               "brand_descr_f", "product_descr", "form_descr",
               "num_cartridges_f", "liq_total_f", "liq_cart_f",
               "nic_yield_tot_f", "nic_mg_per_ml_f")
grp <- c("upc", "year_month", "brand_descr_f", "product_descr", "form_descr",
         "num_cartridges_f", "liq_total_f", "liq_cart_f", "nic_yield_tot_f", "nic_mg_per_ml_f")

collapse_file <- function(f) {
  e <- new.env(); load(f, envir = e)
  DT <- as.data.table(e$rms_w_attr)[
    prod_type == "ec" & !is.na(units) & units > 0 & !is.na(infl_mult) & infl_mult > 0,
    ..keep_cols]
  rm(e); gc(verbose = FALSE)
  out <- DT[, .(units_sum   = sum(units),
                revenue_nom  = sum(units * price_d_prmult),
                revenue_real = sum(units * price_d_prmult / infl_mult)),
            by = grp]
  cat(str_extract(basename(f), "20\\d\\d"), "collapsed:", nrow(out), "upc-month rows\n")
  rm(DT); gc(verbose = FALSE)
  out
}
agg <- rbindlist(lapply(input_files, collapse_file))

## ---- stage 2: per-UPC corrections on the small collapsed table ----
x <- as_tibble(agg) %>%
  mutate(upc12 = pad12(upc)) %>%
  filter(!upc12 %in% exclude12) %>%
  left_join(upc_ov, by = "upc12") %>%
  left_join(impmap, by = "upc12") %>%
  mutate(liq_total_f      = coalesce(ov_total, liq_total_f, map_mL),
         num_cartridges_f = coalesce(ov_carts, num_cartridges_f),
         nic_yield_tot_f  = coalesce(ov_nicyield, nic_yield_tot_f, map_nicyield),
         t2_override      = coalesce(ov_t2, map_t2)) %>%
  filter(!is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f > 0) %>%
  left_join(label_maps$upc_to_brand, by = "upc")

bf <- coalesce(x$brand_descr_f, x$brand_upc, str_extract(x$product_descr, brand_prefix_regex))
rn <- setNames(BRAND_RENAME$to, BRAND_RENAME$from)
bf <- ifelse(!is.na(bf) & bf %in% names(rn), unname(rn[bf]), bf)
x$brand <- coalesce(bf, "UNKNOWN")
x$type  <- coalesce(x$t2_override, classify_t2(x, use_brand = TRUE)$type)

x <- x %>% left_join(corr_lab, by = "upc12") %>%
  mutate(descrU = toupper(product_descr),
         fam = case_when(brand == "VUSE" & grepl("CIRO", descrU) ~ "ciro",
                         brand == "VUSE" & grepl("VIBE", descrU) ~ "vibe",
                         brand == "VUSE" & grepl("SOLO", descrU) ~ "solo", TRUE ~ "other"),
         fam_mlcart = case_when(fam == "ciro" ~ 0.9, fam == "vibe" ~ 2.0, fam == "solo" ~ 0.5, TRUE ~ NA_real_),
         fam_label  = case_when(fam == "ciro" ~ 15,  fam == "vibe" ~ 30,  fam == "solo" ~ 48,  TRUE ~ NA_real_),
         liq_cart_corr = coalesce(cmlcart, fam_mlcart, liq_cart_f),
         liq_total_new = ifelse((!is.na(cmlcart) | !is.na(fam_mlcart)) & !is.na(num_cartridges_f),
                                liq_cart_corr * num_cartridges_f, liq_total_f),
         label_clean = coalesce(clabel, fam_label, nic_mg_per_ml_f),
         nic_new = coalesce(liq_total_new * label_clean * YIELD_FACTOR, nic_yield_tot_f))

upc_month_t2 <- x %>%
  group_by(year_month, brand, upc12, type) %>%
  summarise(descr        = first(product_descr),
            units_sum    = sum(units_sum),
            mL_sum       = sum(units_sum * liq_total_new),
            revenue_nom  = sum(revenue_nom),
            revenue_real = sum(revenue_real),
            nic_mg_sum   = sum(units_sum * nic_new),
            mL_sq_times_unit_sum = sum(units_sum * liq_total_new^2),
            label_mg_per_mL = weighted.mean(label_clean, units_sum, na.rm = TRUE),
            .groups = "drop") %>%
  mutate(month = as.Date(paste0(year_month, "-01")),
         deliv_mg_per_mL = nic_mg_sum / mL_sum)

save(upc_month_t2, file = file.path(support_dir, "upc_month_niccorr_from_full.RData"))
cat("\nwrote", file.path(support_dir, "upc_month_niccorr_from_full.RData"),
    " (", nrow(upc_month_t2), "rows,", n_distinct(upc_month_t2$upc12), "UPCs )\n")

## ---- validation against the canonical brand x type x month panel ----
load(file.path(support_dir, "bt_month_t2_niccorr_from_full.RData"))   # bt_month_t2
chk <- upc_month_t2 %>%
  group_by(year_month, brand, type) %>%
  summarise(mL_u = sum(mL_sum), nic_u = sum(nic_mg_sum), .groups = "drop") %>%
  full_join(select(bt_month_t2, year_month, brand, type, mL_sum, nic_mg_sum),
            by = c("year_month", "brand", "type")) %>%
  mutate(d_mL = abs(mL_u - mL_sum), d_nic = abs(nic_u - nic_mg_sum))
cat("\n=== validation vs bt_month_t2 ===\n")
cat("cells:", nrow(chk),
    "| rel mL err:", signif(sum(chk$d_mL, na.rm = TRUE) / sum(chk$mL_sum, na.rm = TRUE), 3),
    "| rel nic err:", signif(sum(chk$d_nic, na.rm = TRUE) / sum(chk$nic_mg_sum, na.rm = TRUE), 3),
    "| unmatched:", sum(is.na(chk$mL_u) | is.na(chk$mL_sum)), "\n")
