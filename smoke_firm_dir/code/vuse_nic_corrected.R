## Recompute VUSE delivered nicotine (mL-weighted) by year, applying the manual
## label corrections (nic_mg_per_ml_manual_aug_8) wherever present. Delivered =
## label x 0.68 (YIELD_FACTOR). Compares old vs corrected.
rm(list = ls()); suppressPackageStartupMessages(library(tidyverse))
source(file.path("pr", "upc_overrides.R"))          # YIELD_FACTOR (0.68), EXCLUDE_UPCS
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")
excl <- pad12(EXCLUDE_UPCS)

corr <- readxl::read_excel("pr/output/prelim_analysis/t2/manually_corrected_vuse.xlsx") %>%
  transmute(upc12 = pad12(upc12), manual = nic_mg_per_ml_manual_aug_8) %>%
  filter(!is.na(manual))

files <- list.files("input", pattern = "^full_.*7467.*\\.RData$", full.names = TRUE)
rows <- list()
for (f in files) {
  load(f)  # rms_w_attr
  v <- rms_w_attr %>%
    filter(prod_type == "ec", !is.na(units), units > 0, brand_descr_f == "VUSE",
           !is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f > 0) %>%
    mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% excl) %>%
    left_join(corr, by = "upc12") %>%
    mutate(mL = units * liq_total_f,
           deliv_old = units * nic_yield_tot_f,
           deliv_new = ifelse(!is.na(manual), units * liq_total_f * manual * YIELD_FACTOR,
                              units * nic_yield_tot_f),
           corrected_mL = ifelse(!is.na(manual), mL, 0))
  rows[[f]] <- v %>% mutate(year = as.integer(substr(year_month, 1, 4))) %>%
    group_by(year) %>%
    summarise(mL = sum(mL), deliv_old = sum(deliv_old), deliv_new = sum(deliv_new),
              corrected_mL = sum(corrected_mL), .groups = "drop")
  rm(rms_w_attr, v); gc(verbose = FALSE)
  cat(str_extract(basename(f), "20\\d\\d"), "done\n")
}

res <- bind_rows(rows) %>% group_by(year) %>% summarise(across(everything(), sum), .groups = "drop") %>%
  mutate(nic_old = round(deliv_old / mL, 1),
         nic_new = round(deliv_new / mL, 1),
         pct_mL_corrected = round(100 * corrected_mL / mL, 1))
cat("\n=== VUSE delivered nicotine (mg/mL), old vs corrected, by year ===\n")
res %>% select(year, nic_old, nic_new, pct_mL_corrected) %>% as.data.frame() %>% print(row.names = FALSE)
write_csv(res, "pr/output/prelim_analysis/investment_proxy/vuse_nic_corrected_by_year.csv")
