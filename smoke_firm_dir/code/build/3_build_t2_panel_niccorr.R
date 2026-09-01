## Corrected-nicotine T2 panel: mirrors archive/1_build_t2_panel.R but (1) recomputes
## delivered nicotine as liq_total * clean_label * 0.68 (fixes cart-scaling),
## (2) cleans VUSE labels (user per-UPC + Ciro/Vibe/Solo family rules + prior),
## (3) corrects liq_cart for VUSE Ciro(0.9)/Vibe(2.0)/Solo(0.5).
## Writes the canonical panel (input/bt_month_t2_niccorr_from_full.RData) + impact
## report + top-UPC-per-year audit (item 3).
rm(list = ls()); suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })
source("smoke_firm_dir/code/fxns/1_paths.R")
raw_input_dir <- RAW_DIR
support_input_dir <- SUPPORT_DIR
out_dir  <- file.path(PRELIM_DIR, "investment_proxy")
t2_dir   <- file.path(PRELIM_DIR, "t2")
fxn("3_t2_classify.R")
fxn("2_upc_overrides.R")     # YIELD_FACTOR (0.68), overrides, EXCLUDE
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")

upc_ov <- MANUAL_UPC_OVERRIDES %>%
  mutate(upc12 = pad12(upc), ov_total = liq_cart_f * num_cartridges, ov_carts = num_cartridges,
         ov_nicyield = ifelse(!is.na(nic_mg_per_ml), ov_total * nic_mg_per_ml * YIELD_FACTOR, NA_real_),
         ov_t2 = t2_type) %>% select(upc12, ov_total, ov_carts, ov_nicyield, ov_t2)
impmap_path <- file.path(support_input_dir, "missing_mL_imputation_map.rds")
impmap_raw <- if (file.exists(impmap_path)) readRDS(impmap_path) else list(map = tibble(upc=character(), mL_total_imputed=numeric(), nic_yield_tot_imputed=numeric(), t2_type_override=character()))
impmap <- impmap_raw$map %>% mutate(upc12 = pad12(upc)) %>%
    select(upc12, map_mL = mL_total_imputed, map_nicyield = nic_yield_tot_imputed, map_t2 = t2_type_override)
exclude12 <- pad12(EXCLUDE_UPCS)
load(file.path(support_input_dir, "label_maps.RData"))
escape_re <- function(x) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
brand_prefix_regex <- paste0("^(", paste(escape_re(label_maps$brand_vocab), collapse="|"), ")")

## master manual corrections (all brands): label, mL/cart, hardware exclusions
mcorr <- read_csv(file.path(support_input_dir, "manual_nic_corrections.csv"), show_col_types = FALSE) %>%
  mutate(upc12 = pad12(upc12))
exclude12 <- union(exclude12, mcorr %>% filter(exclude == 1) %>% pull(upc12))
corr_lab <- mcorr %>% filter(is.na(exclude) | exclude == 0) %>%
  select(upc12, clabel = true_label_mg_per_ml, cmlcart = true_mL_per_cart)

input_files <- list.files(raw_input_dir, pattern=paste0("^full_.*7467.*\\.RData$"), full.names=TRUE)
panel_rows <- list(); diag_rows <- list(); upc_rows <- list()
aggregate_file <- function(f) {
  load(f); yr <- as.integer(str_extract(basename(f), "20\\d\\d"))
  x <- rms_w_attr %>%
    filter(prod_type=="ec", !is.na(units), units>0, !is.na(infl_mult), infl_mult>0) %>%
    mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% exclude12) %>%
    left_join(upc_ov, by="upc12") %>% left_join(impmap, by="upc12") %>%
    mutate(liq_total_f = coalesce(ov_total, liq_total_f, map_mL),
           num_cartridges_f = coalesce(ov_carts, num_cartridges_f),
           nic_yield_tot_f = coalesce(ov_nicyield, nic_yield_tot_f, map_nicyield),
           t2_override = coalesce(ov_t2, map_t2)) %>%
    filter(!is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f>0) %>%
    left_join(label_maps$upc_to_brand, by="upc")
  bf <- coalesce(x$brand_descr_f, x$brand_upc, str_extract(x$product_descr, brand_prefix_regex))
  rn <- setNames(BRAND_RENAME$to, BRAND_RENAME$from)
  bf <- ifelse(!is.na(bf) & bf %in% names(rn), unname(rn[bf]), bf)
  x$brand <- coalesce(bf, "UNKNOWN")
  x$type  <- coalesce(x$t2_override, classify_t2(x, use_brand=TRUE)$type)
  x <- x %>% left_join(corr_lab, by="upc12") %>%
    mutate(descrU = toupper(product_descr),
           fam = case_when(brand=="VUSE" & grepl("CIRO",descrU) ~ "ciro",
                           brand=="VUSE" & grepl("VIBE",descrU) ~ "vibe",
                           brand=="VUSE" & grepl("SOLO",descrU) ~ "solo", TRUE ~ "other"),
           fam_mlcart = case_when(fam=="ciro"~0.9, fam=="vibe"~2.0, fam=="solo"~0.5, TRUE~NA_real_),
           fam_label  = case_when(fam=="ciro"~15,  fam=="vibe"~30,  fam=="solo"~48,  TRUE~NA_real_),
           liq_cart_corr = coalesce(cmlcart, fam_mlcart, liq_cart_f),
           liq_total_new = ifelse((!is.na(cmlcart) | !is.na(fam_mlcart)) & !is.na(num_cartridges_f),
                                  liq_cart_corr*num_cartridges_f, liq_total_f),
           label_clean = coalesce(clabel, fam_label, nic_mg_per_ml_f),
           nic_new = coalesce(liq_total_new*label_clean*YIELD_FACTOR, nic_yield_tot_f),
           nic_old = nic_yield_tot_f)
  ## corrected panel (uses liq_total_new, nic_new)
  panel_rows[[f]] <<- x %>% group_by(year_month, brand, type) %>%
    summarise(units_sum=sum(units), mL_sum=sum(units*liq_total_new),
              revenue_nom=sum(units*price_d_prmult), revenue_real=sum(units*price_d_prmult/infl_mult),
              nic_mg_sum=sum(units*nic_new), mL_sq_times_unit_sum=sum(units*liq_total_new^2), .groups="drop")
  ## impact diagnostic (old vs new), by brand-year
  diag_rows[[f]] <<- x %>% group_by(year=yr, brand) %>%
    summarise(mL_old=sum(units*liq_total_f), mL_new=sum(units*liq_total_new),
              mL_sq_old=sum(units*liq_total_f^2), mL_sq_new=sum(units*liq_total_new^2),
              nic_old=sum(units*nic_old), nic_new=sum(units*nic_new), .groups="drop")
  ## top-UPC-per-year audit
  upc_rows[[f]] <<- x %>% group_by(year=yr, upc12, brand) %>%
    summarise(descr=first(product_descr), mL=sum(units*liq_total_new),
              label_mg_per_mL=round(weighted.mean(label_clean, units, na.rm=TRUE),1),
              deliv_new=round(sum(units*nic_new)/sum(units*liq_total_new),1),
              deliv_old=round(sum(units*nic_old)/sum(units*liq_total_f),1), .groups="drop")
  cat(yr, "done\n"); rm(rms_w_attr, x); gc(verbose=FALSE)
}
invisible(lapply(input_files, aggregate_file))

## ---- corrected panel ----
bt_month_t2 <- bind_rows(panel_rows) %>% group_by(year_month, brand, type) %>%
  summarise(across(everything(), sum), .groups="drop") %>%
  mutate(month=as.Date(paste0(year_month,"-01")), price_per_mL=revenue_real/mL_sum,
         nic_mg_per_mL=nic_mg_sum/mL_sum, avg_mL_per_ecig=mL_sq_times_unit_sum/mL_sum,
         P_hom_cell=price_per_mL*avg_mL_per_ecig, N_hom_cell=nic_mg_per_mL*avg_mL_per_ecig) %>%
  group_by(month) %>% mutate(mL_share=mL_sum/sum(mL_sum)) %>% ungroup()
save(bt_month_t2, file=file.path(support_input_dir,"bt_month_t2_niccorr_from_full.RData"))
cat("\nwrote corrected panel: input/bt_month_t2_niccorr_from_full.RData\n")

## ---- impact: national N_hom old vs new ----
diag <- bind_rows(diag_rows)
impact_metrics <- function(d) d %>%
  mutate(nic_mg_per_mL_old=nic_old/mL_old, nic_mg_per_mL_new=nic_new/mL_new,
         avg_mL_per_ecig_old=mL_sq_old/mL_old, avg_mL_per_ecig_new=mL_sq_new/mL_new,
         N_hom_old=nic_mg_per_mL_old*avg_mL_per_ecig_old,
         N_hom_new=nic_mg_per_mL_new*avg_mL_per_ecig_new,
         N_hom_change=N_hom_new-N_hom_old,
         mL_change_pct=100*(mL_new-mL_old)/mL_old)
natl <- diag %>% group_by(year) %>%
  summarise(across(c(mL_old, mL_new, mL_sq_old, mL_sq_new, nic_old, nic_new), sum),
            .groups="drop") %>% impact_metrics()
cat("\n=== NATIONAL N_hom (mg per homogeneous e-cig): old vs new ===\n")
natl %>% transmute(year, old=round(N_hom_old,1), new=round(N_hom_new,1),
                   change=round(N_hom_change,1), mL_change_pct=round(mL_change_pct,2)) %>%
  as.data.frame() %>% print(row.names=FALSE)
cat("\n=== NATIONAL pooled delivered nicotine concentration (mg/mL): old vs new ===\n")
natl %>% transmute(year, old=round(nic_mg_per_mL_old,1), new=round(nic_mg_per_mL_new,1)) %>%
  as.data.frame() %>% print(row.names=FALSE)
write_csv(natl, file.path(out_dir,"niccorr_national_old_vs_new.csv"))
by_brand_year <- diag %>% impact_metrics()
cat("\n=== per-brand N_hom old->new (2019-2023; leading brands) ===\n")
by_brand_year %>% filter(year>=2019, brand %in% c("VUSE","JUUL","NJOY","BLU","MISTIC","LOGIC")) %>%
  transmute(year, brand, chg=paste0(round(N_hom_old,1),"->",round(N_hom_new,1))) %>%
  pivot_wider(names_from=brand, values_from=chg) %>%
  as.data.frame() %>% print(row.names=FALSE)
cat("\n=== all material brand-year N_hom changes (absolute change >= 0.05 mg) ===\n")
by_brand_year %>% filter(abs(N_hom_change) >= 0.05) %>%
  transmute(year, brand, old=round(N_hom_old,1), new=round(N_hom_new,1),
            change=round(N_hom_change,1)) %>%
  arrange(year, desc(abs(change))) %>% as.data.frame() %>% print(row.names=FALSE)
write_csv(by_brand_year, file.path(out_dir,"niccorr_by_brand_year.csv"))

## ---- item 3: top UPC per year across all brands ----
upc <- bind_rows(upc_rows) %>% group_by(year) %>% mutate(mL_share=round(100*mL/sum(mL),1)) %>%
  arrange(year, desc(mL)) %>% ungroup()
top1 <- upc %>% group_by(year) %>% slice_max(mL, n=1) %>% ungroup()
cat("\n=== ITEM 3: highest-market-share UPC each year (check nicotine) ===\n")
top1 %>% transmute(year, brand, mL_share, label_mg_per_mL, deliv_new, deliv_old,
                   descr=substr(descr,1,44)) %>% as.data.frame() %>% print(row.names=FALSE)
write_csv(upc %>% group_by(year) %>% slice_max(mL, n=5) %>% ungroup(),
          file.path(out_dir,"top5_upc_per_year.csv"))
cat("\nwrote top5_upc_per_year.csv (top-5 UPCs/yr with label + delivered nic)\n")
