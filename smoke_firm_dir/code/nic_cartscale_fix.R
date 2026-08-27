## Diagnose + fix the multi-cartridge nicotine under-scaling bug.
## Hypothesis: nic_yield_tot_f = ONE cartridge's yield for some multi-count packs,
## while liq_total_f = full pack -> delivered per mL understated ~num_cartridges x.
## Fix: delivered per pack = nic_yield_per_cart_f * num_cartridges_f (per-cart basis,
## immune to the bug); plus VUSE manual label corrections where present.
rm(list = ls()); suppressPackageStartupMessages(library(tidyverse))
out_dir <- file.path("pr", "output", "prelim_analysis", "investment_proxy")
source(file.path("pr", "upc_overrides.R"))          # YIELD_FACTOR, EXCLUDE_UPCS
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")
excl <- pad12(EXCLUDE_UPCS)
vcorr <- readxl::read_excel("pr/output/prelim_analysis/t2/manually_corrected_vuse.xlsx") %>%
  transmute(upc12 = pad12(upc12), manual = nic_mg_per_ml_manual_aug_8) %>% filter(!is.na(manual))

top_brands <- c("VUSE","JUUL","NJOY","BLU","MISTIC","LOGIC","MARKTEN","FINITI")
files <- list.files("input", pattern = "^full_.*7467.*\\.RData$", full.names = TRUE)
by_brand <- list(); by_natl <- list(); verify <- list()
for (f in files) {
  load(f); yr <- as.integer(str_extract(basename(f), "20\\d\\d"))
  x <- rms_w_attr %>%
    filter(prod_type == "ec", !is.na(units), units > 0,
           !is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f > 0) %>%
    mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% excl) %>%
    left_join(vcorr, by = "upc12") %>%
    mutate(per_cart_total = nic_yield_per_cart_f * num_cartridges_f,
           deliv_old  = nic_yield_tot_f,
           deliv_fix  = case_when(!is.na(manual) ~ liq_total_f * manual * YIELD_FACTOR,
                                  !is.na(per_cart_total) ~ per_cart_total,
                                  TRUE ~ nic_yield_tot_f),
           mL = units * liq_total_f,
           bug = !is.na(per_cart_total) & nic_yield_tot_f < 0.9 * per_cart_total)
  ## (a) verification: ratio of recorded total to per-cart*count, VUSE multi-packs
  verify[[f]] <- x %>% filter(brand_descr_f == "VUSE", !is.na(per_cart_total), num_cartridges_f >= 2) %>%
    summarise(year = yr, vuse_multipack_mL = sum(mL),
              med_ratio_tot_over_percartxN = round(median(nic_yield_tot_f / per_cart_total), 3),
              .groups = "drop")
  ## (c)/(d) brand x year old vs fixed
  by_brand[[f]] <- x %>% filter(brand_descr_f %in% top_brands) %>%
    group_by(brand = brand_descr_f) %>%
    summarise(year = yr, mL = sum(mL),
              nic_old = sum(units * deliv_old), nic_fix = sum(units * deliv_fix),
              bug_mL = sum(mL[bug]), .groups = "drop")
  ## national aggregate (all ec)
  by_natl[[f]] <- x %>% summarise(year = yr, mL = sum(mL),
              nic_old = sum(units * deliv_old), nic_fix = sum(units * deliv_fix),
              bug_mL = sum(mL[bug]), .groups = "drop")
  rm(rms_w_attr, x); gc(verbose = FALSE); cat(yr, "done\n")
}

cat("\n=== (a) VERIFY: VUSE multi-pack ratio  nic_yield_tot_f / (per_cart x num_cart) ===\n")
cat("    (1.0 = correct; ~1/N = bug where total holds only one cartridge)\n")
bind_rows(verify) %>% arrange(year) %>% as.data.frame() %>% print(row.names = FALSE)

brand <- bind_rows(by_brand) %>%
  mutate(nic_old = round(nic_old/mL,1), nic_fix = round(nic_fix/mL,1),
         pct_mL_bug = round(100*bug_mL/mL,0))
write_csv(brand, file.path(out_dir, "nic_old_vs_fixed_by_brand_year.csv"))

cat("\n=== (c) VUSE: delivered nic old vs FIXED, by year ===\n")
brand %>% filter(brand=="VUSE") %>% select(year, nic_old, nic_fix, pct_mL_bug) %>%
  as.data.frame() %>% print(row.names=FALSE)

cat("\n=== (d) top brands: nic_old -> nic_fix (pct of mL bugged), 2020-2023 ===\n")
brand %>% filter(year>=2020) %>%
  transmute(year, brand, chg = paste0(nic_old, "->", nic_fix, " (", pct_mL_bug, "%)")) %>%
  pivot_wider(names_from=brand, values_from=chg) %>% as.data.frame() %>% print(row.names=FALSE)

natl <- bind_rows(by_natl) %>% mutate(nic_old=round(nic_old/mL,1), nic_fix=round(nic_fix/mL,1),
                                      pct_mL_bug=round(100*bug_mL/mL,0)) %>% arrange(year)
cat("\n=== national pooled delivered nic (all brands): old vs fixed ===\n")
natl %>% select(year, nic_old, nic_fix, pct_mL_bug) %>% as.data.frame() %>% print(row.names=FALSE)
write_csv(natl, file.path(out_dir, "nic_old_vs_fixed_national.csv"))
