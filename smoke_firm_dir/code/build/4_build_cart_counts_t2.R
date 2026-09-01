## Cartridge counts by T2 type x month, using the EXACT build_t2_panel pipeline
## (same overrides, imputation, brand cascade, classify_t2), so units match the
## canonical panel. Purpose: a CDC-comparable "standardized unit" diagnostic
## (1 unit = 5 prefilled cartridges = 1 disposable = 1 e-liquid bottle).
## Does NOT overwrite bt_month_t2. Output: cart_counts_by_type_month.csv
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

source("smoke_firm_dir/code/fxns/1_paths.R")
raw_input_dir <- RAW_DIR
support_input_dir <- SUPPORT_DIR
out_dir   <- file.path(PRELIM_DIR, "p_and_n_decomp_t2")
fxn("3_t2_classify.R")
fxn("2_upc_overrides.R")
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")

upc_ov <- MANUAL_UPC_OVERRIDES %>%
  mutate(upc12 = pad12(upc), ov_total = liq_cart_f * num_cartridges,
         ov_carts = num_cartridges,
         ov_nicyield = ifelse(!is.na(nic_mg_per_ml), ov_total * nic_mg_per_ml * YIELD_FACTOR, NA_real_),
         ov_t2 = t2_type) %>%
  select(upc12, ov_total, ov_carts, ov_nicyield, ov_t2)
impmap_path <- file.path(support_input_dir, "missing_mL_imputation_map.rds")
impmap_raw <- if (file.exists(impmap_path)) readRDS(impmap_path) else list(map = tibble(upc=character(), mL_total_imputed=numeric(), nic_yield_tot_imputed=numeric(), t2_type_override=character()))
impmap <- impmap_raw$map %>%
  mutate(upc12 = pad12(upc)) %>%
  select(upc12, map_mL = mL_total_imputed, map_nicyield = nic_yield_tot_imputed,
         map_t2 = t2_type_override)
exclude12 <- pad12(EXCLUDE_UPCS)
mcorr <- read_csv(file.path(support_input_dir, "manual_nic_corrections.csv"), show_col_types = FALSE) %>%
  mutate(upc12 = pad12(upc12))
exclude12 <- union(exclude12, mcorr %>% filter(exclude == 1) %>% pull(upc12))
load(file.path(support_input_dir, "label_maps.RData"))
escape_re <- function(x) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
brand_prefix_regex <- paste0("^(", paste(escape_re(label_maps$brand_vocab), collapse="|"), ")")

input_files <- list.files(raw_input_dir, pattern="^full_.*7467.*\\.RData$", full.names=TRUE)
rows <- list()
agg <- function(f) {
  load(f)
  x <- rms_w_attr %>%
    filter(prod_type=="ec", !is.na(units), units>0, !is.na(infl_mult), infl_mult>0) %>%
    mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% exclude12) %>%
    left_join(upc_ov, by="upc12") %>% left_join(impmap, by="upc12") %>%
    mutate(liq_total_f = coalesce(ov_total, liq_total_f, map_mL),
           num_cartridges_f = coalesce(ov_carts, num_cartridges_f),
           nic_yield_tot_f = coalesce(ov_nicyield, nic_yield_tot_f, map_nicyield),
           t2_override = coalesce(ov_t2, map_t2)) %>%
    filter(!is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f>0)
  cl <- classify_t2(x, use_brand=TRUE)
  x$type <- coalesce(x$t2_override, cl$type)
  rows[[f]] <<- x %>%
    mutate(carts = coalesce(num_cartridges_f, 1)) %>%   # NA -> single unit
    group_by(year_month, type) %>%
    summarise(units_sum = sum(units),
              cart_sum  = sum(units * carts),               # total cartridges/pods
              units_na_cart = sum(units[is.na(num_cartridges_f)]),
              mL_sum = sum(units * liq_total_f),
              .groups="drop")
  cat(str_extract(basename(f), "20\\d\\d"), "done\n")
  rm(rms_w_attr, x); gc(verbose=FALSE)
}
invisible(lapply(input_files, agg))

cc <- bind_rows(rows) %>% group_by(year_month, type) %>%
  summarise(across(everything(), sum), .groups="drop")
write_csv(cc, file.path(out_dir, "cart_counts_by_type_month.csv"))
cat("\nWrote cart_counts_by_type_month.csv (", nrow(cc), "rows )\n")
cc %>% mutate(year=substr(year_month,1,4)) %>% group_by(year,type) %>%
  summarise(units=sum(units_sum), carts=sum(cart_sum),
            na_cart_pct=round(100*sum(units_na_cart)/sum(units_sum),1), .groups="drop") %>%
  filter(year %in% c("2013","2020","2022","2023")) %>% as.data.frame() %>% print(row.names=FALSE)
