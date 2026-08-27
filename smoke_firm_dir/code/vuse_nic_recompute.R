## Recompute VUSE delivered nicotine with cleaned labels.
## concentration = clean_label * 0.68 (cart-scaling cancels). label priority:
##   user_new (per-UPC)  >  Ciro rule (=15)  >  prior xlsx  >  raw nic_mg_per_ml_f
rm(list = ls()); suppressPackageStartupMessages(library(tidyverse))
out_dir <- file.path("pr", "output", "prelim_analysis", "investment_proxy")
source(file.path("pr", "upc_overrides.R"))          # YIELD_FACTOR (0.68), EXCLUDE_UPCS
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")
excl <- pad12(EXCLUDE_UPCS)

## user's Aug-9 per-UPC corrections (% -> mg/mL: 5->50, 2.4->24, 1.8->18, 1.5->15)
user_new <- tribble(~upc, ~label,
  "084920502345", 50, "84920502354", 50, "84920502346", 50,
  "084920502342", 24, "84920502351", 24,
  "84920501967", 18, "84920501968", 18,
  "84920502885", 50, "84920501992", 24, "84920501935", 50,
  "84920501516", 15, "84920501791", 24, "84920501631", 50) %>%
  mutate(upc12 = pad12(upc)) %>% select(upc12, unew = label)

prior <- readxl::read_excel("pr/output/prelim_analysis/t2/manually_corrected_vuse.xlsx") %>%
  transmute(upc12 = pad12(upc12), uprior = nic_mg_per_ml_manual_aug_8) %>% filter(!is.na(uprior))

files <- list.files("input", pattern = "^full_.*7467.*\\.RData$", full.names = TRUE)
rows <- list()
for (f in files) {
  load(f); yr <- as.integer(str_extract(basename(f), "20\\d\\d"))
  v <- rms_w_attr %>%
    filter(prod_type == "ec", !is.na(units), units > 0, brand_descr_f == "VUSE",
           !is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f > 0) %>%
    mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% excl) %>%
    left_join(user_new, by = "upc12") %>% left_join(prior, by = "upc12") %>%
    mutate(is_ciro = grepl("CIRO", product_descr, ignore.case = TRUE),
           is_vibe = grepl("VIBE", product_descr, ignore.case = TRUE),
           is_solo = grepl("SOLO", product_descr, ignore.case = TRUE),
           label_clean = coalesce(unew,
                                  if_else(is_ciro, 15, NA_real_),
                                  if_else(is_vibe, 30, NA_real_),
                                  if_else(is_solo, 48, NA_real_),
                                  uprior, nic_mg_per_ml_f),
           src = case_when(!is.na(unew) ~ "user", is_ciro ~ "ciro", is_vibe ~ "vibe",
                           is_solo ~ "solo", !is.na(uprior) ~ "prior", TRUE ~ "raw(Alto)"),
           mL = units * liq_total_f,
           deliv_old = units * nic_yield_tot_f,
           deliv_new = units * liq_total_f * label_clean * YIELD_FACTOR)
  rows[[f]] <- v %>% group_by(year = yr) %>%
    summarise(mL = sum(mL), deliv_old = sum(deliv_old), deliv_new = sum(deliv_new),
              pct_raw = round(100 * sum(mL[src == "raw(Alto)"], na.rm = TRUE) / sum(mL), 0),
              .groups = "drop")
  rm(rms_w_attr, v); gc(verbose = FALSE); cat(yr, "done\n")
}
res <- bind_rows(rows) %>% arrange(year) %>%
  mutate(nic_old = round(deliv_old / mL, 1), nic_new = round(deliv_new / mL, 1))
cat("\n=== VUSE delivered nicotine (mg/mL): OLD (buggy) vs RECOMPUTED (clean labels) ===\n")
res %>% select(year, nic_old, nic_new, pct_mL_still_raw_Alto = pct_raw) %>%
  as.data.frame() %>% print(row.names = FALSE)
write_csv(res, file.path(out_dir, "vuse_nic_recomputed_by_year.csv"))
