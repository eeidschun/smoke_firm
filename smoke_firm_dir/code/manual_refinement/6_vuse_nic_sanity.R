## Sanity check on the VUSE 2020->2021 nicotine drop: per-UPC, per-year VUSE
## detail (2019-2023) with the delivered nic_mg_per_mL actually used (manual
## corrections applied), effective label, capacity, mL share, and description.
rm(list = ls()); suppressPackageStartupMessages(library(tidyverse))
source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(PRELIM_DIR, "investment_proxy")
fxn("2_upc_overrides.R")          # YIELD_FACTOR, EXCLUDE_UPCS
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")
excl <- pad12(EXCLUDE_UPCS)
corr <- readxl::read_excel(file.path(PRELIM_DIR, "t2", "manually_corrected_vuse.xlsx")) %>%
  transmute(upc12 = pad12(upc12), manual = nic_mg_per_ml_manual_aug_8) %>% filter(!is.na(manual))

yrs <- 2019:2023
files <- file.path(RAW_DIR, sprintf("full_%s_%d_7467_%d.RData",
                 c("21","24","25","27","29"), yrs, yrs))   # code_year_7467_year
rows <- list()
for (i in seq_along(files)) {
  load(files[i]); yr <- yrs[i]
  v <- rms_w_attr %>%
    filter(prod_type == "ec", !is.na(units), units > 0, brand_descr_f == "VUSE",
           !is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f > 0) %>%
    mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% excl) %>%
    left_join(corr, by = "upc12") %>%
    mutate(deliv = ifelse(!is.na(manual), units * liq_total_f * manual * YIELD_FACTOR,
                          units * nic_yield_tot_f),
           mL = units * liq_total_f, corrected = !is.na(manual))
  rows[[i]] <- v %>% group_by(upc12) %>%
    summarise(year = yr, corrected = any(corrected),
              descr = first(product_descr), flavor = first(flavor_f),
              cap = round(weighted.mean(liq_total_f, units), 2),
              mL_sold = sum(mL), deliv = sum(deliv), .groups = "drop")
  rm(rms_w_attr, v); gc(verbose = FALSE); cat(yr, "done\n")
}
d <- bind_rows(rows) %>% group_by(year) %>%
  mutate(deliv_mg_per_mL = round(deliv / mL_sold, 1),
         eff_label = round(deliv_mg_per_mL / YIELD_FACTOR, 1),
         mL_share = round(100 * mL_sold / sum(mL_sold), 1)) %>% ungroup()
write_csv(d %>% select(year, upc12, corrected, eff_label, deliv_mg_per_mL, cap, mL_share, flavor, descr),
          file.path(out_dir, "vuse_upc_by_year_2019_2023.csv"))

for (y in c(2020, 2021)) {
  cat(sprintf("\n===== VUSE %d: top UPCs by mL share  (year weighted delivered = %.1f mg/mL) =====\n",
              y, with(filter(d, year == y), sum(deliv)/sum(mL_sold))))
  d %>% filter(year == y) %>% arrange(desc(mL_share)) %>% head(12) %>%
    transmute(mL_share, deliv_mg_per_mL, eff_label, cap, corrected,
              flavor, descr = substr(descr, 1, 46)) %>%
    as.data.frame() %>% print(row.names = FALSE)
}
