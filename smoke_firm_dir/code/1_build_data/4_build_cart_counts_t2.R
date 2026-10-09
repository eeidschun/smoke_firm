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
corr_lab <- mcorr %>% filter(is.na(exclude) | exclude == 0) %>%
  select(upc12, clabel = true_label_mg_per_ml, cmlcart = true_mL_per_cart)
load(file.path(support_input_dir, "label_maps.RData"))
escape_re <- function(x) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
brand_prefix_regex <- paste0("^(", paste(escape_re(label_maps$brand_vocab), collapse="|"), ")")

input_files <- list.files(raw_input_dir, pattern="^full_.*7467.*\\.RData$", full.names=TRUE)
rows <- list()
agg <- function(f) {
  load(f)
  # Exact pre-collapse: downstream quantities depend only on these attributes
  # and summed units. Avoid repeating joins over store-week observations.
  z <- data.table::as.data.table(rms_w_attr)
  keys <- c("upc", "year_month", "brand_descr_f", "product_descr", "form_descr",
            "num_cartridges_f", "liq_total_f", "liq_cart_f", "nic_yield_tot_f", "nic_mg_per_ml_f")
  rms_w_attr <- as.data.frame(z[prod_type == "ec" & !is.na(units) & units > 0 &
    !is.na(infl_mult) & infl_mult > 0, list(units = sum(units), revenue_nom = sum(units * price_d_prmult),
      revenue_real = sum(units * price_d_prmult / infl_mult)), by = keys])
  cache_dir <- file.path(SUPPORT_DIR, "raw_attribute_month_cache")
  dir.create(cache_dir, showWarnings=FALSE)
  info <- file.info(f)
  footprint <- z[prod_type == "ec", list(upc12=pad12(upc),year_month,store_code_uc)]
  by_upc <- footprint[,list(n_stores=data.table::uniqueN(store_code_uc)),by=c("upc12","year_month")]
  by_mo <- footprint[,list(n_stores_month_total=data.table::uniqueN(store_code_uc)),by="year_month"]
  state_upc <- unique(z[prod_type == "ec" & units > 0,
    list(year_month,upc12=pad12(upc),STATE=sprintf("%02d",as.integer(fips_state_code)))])
  saveRDS(list(size=info$size, mtime=as.numeric(info$mtime), data=rms_w_attr,
              by_upc=by_upc,by_mo=by_mo,state_upc=state_upc),
          file.path(cache_dir,paste0(basename(f),".rds")))
  rm(z,footprint,by_upc,by_mo,state_upc); gc(verbose=FALSE)
  rms_w_attr$prod_type <- "ec"; rms_w_attr$infl_mult <- 1
  x <- rms_w_attr %>%
    filter(prod_type=="ec", !is.na(units), units>0, !is.na(infl_mult), infl_mult>0) %>%
    mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% exclude12) %>%
    left_join(upc_ov, by="upc12") %>% left_join(impmap, by="upc12") %>%
    mutate(original_total = coalesce(liq_total_f, map_mL), original_nic = coalesce(nic_yield_tot_f, map_nicyield),
           liq_total_f = coalesce(ov_total, liq_total_f, map_mL),
           num_cartridges_f = coalesce(ov_carts, num_cartridges_f),
           nic_yield_tot_f = coalesce(ov_nicyield, nic_yield_tot_f, map_nicyield),
           t2_override = coalesce(ov_t2, map_t2)) %>%
    filter(!is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f>0)
  x <- x %>% left_join(label_maps$upc_to_brand, by="upc")
  bf <- coalesce(x$brand_descr_f, x$brand_upc, str_extract(x$product_descr, brand_prefix_regex))
  rn <- setNames(BRAND_RENAME$to, BRAND_RENAME$from)
  bf <- ifelse(!is.na(bf) & bf %in% names(rn), unname(rn[bf]), bf)
  x$brand <- coalesce(bf, "UNKNOWN")
  x$type  <- coalesce(x$t2_override, classify_t2(x, use_brand=TRUE)$type)
  x <- x %>% left_join(corr_lab, by="upc12") %>%
    left_join(reviewed_size %>% select(upc12, reviewed_ml = ml_per_cartridge), by="upc12") %>%
    mutate(descrU = toupper(product_descr),
           fam = case_when(brand=="VUSE" & grepl("CIRO",descrU) ~ "ciro",
                           brand=="VUSE" & grepl("VIBE",descrU) ~ "vibe",
                           brand=="VUSE" & grepl("SOLO",descrU) ~ "solo", TRUE ~ "other"),
           fam_mlcart = case_when(fam=="ciro"~0.9, fam=="vibe"~1.9, fam=="solo"~0.5, TRUE~NA_real_),
           fam_label  = case_when(fam=="ciro"~15,  fam=="vibe"~30,  fam=="solo"~48,  TRUE~NA_real_),
           user_family_ml = case_when(brand == "JUUL" ~ 0.7,
             brand == "NJOY" & grepl("ACE", descrU) ~ 1.9,
             fam == "vibe" ~ 1.9, TRUE ~ NA_real_),
           liq_cart_corr = coalesce(reviewed_ml, user_family_ml, cmlcart, fam_mlcart, liq_cart_f),
           liq_total_new = ifelse((!is.na(reviewed_ml) | !is.na(user_family_ml) | !is.na(cmlcart) | !is.na(fam_mlcart)) & !is.na(num_cartridges_f),
                                  liq_cart_corr*num_cartridges_f, liq_total_f),
           label_clean = coalesce(clabel, fam_label, nic_mg_per_ml_f),
           nic_new = coalesce(liq_total_new*label_clean*YIELD_FACTOR, ov_nicyield, original_nic * liq_total_new / original_total, nic_yield_tot_f),
           nic_old = nic_yield_tot_f)

  rows[[f]] <<- x %>%
    mutate(carts = coalesce(num_cartridges_f, 1)) %>%   # NA -> single unit
    group_by(year_month, type) %>%
    summarise(units_sum = sum(units),
              cart_sum  = sum(units * carts),               # total cartridges/pods
              units_na_cart = sum(units[is.na(num_cartridges_f)]),
              mL_sum = sum(units * liq_total_new),
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

load(file.path(support_input_dir, "bt_month_t2_niccorr_from_full.RData"))
check <- bt_month_t2 %>% group_by(year_month, type) %>%
  summarise(expected_units=sum(units_sum), expected_ml=sum(mL_sum), .groups="drop") %>%
  full_join(cc, by=c("year_month","type"))
stopifnot(!anyNA(check$expected_units), !anyNA(check$units_sum),
  max(abs(check$units_sum-check$expected_units)/pmax(1,abs(check$expected_units))) < 1e-8,
  max(abs(check$mL_sum-check$expected_ml)/pmax(1,abs(check$expected_ml))) < 1e-8)
