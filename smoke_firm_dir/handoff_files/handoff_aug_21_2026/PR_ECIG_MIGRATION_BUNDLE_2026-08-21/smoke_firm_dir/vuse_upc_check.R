## Every VUSE UPC (2023) with cleaned nicotine + capacity, reconciled to the
## panel's ~17 mg/mL. KEY: the panel's nic_mg_per_mL is DELIVERED nicotine =
## label x 0.68 (transfer efficiency), computed from the cleaned nic_yield_tot_f.
## The raw label field (nic_mg_per_ml_f) is unreliable (mixed %/mg-per-mL units),
## which is why the pipeline uses nic_yield_tot_f instead.
rm(list = ls()); suppressPackageStartupMessages(library(tidyverse))
out_dir <- file.path("pr", "output", "prelim_analysis", "investment_proxy")
source(file.path("pr", "upc_overrides.R"))   # YIELD_FACTOR (0.68), EXCLUDE_UPCS
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")
excl <- pad12(EXCLUDE_UPCS)

load(file.path("pr", "input", "full_29_2023_7467_2023.RData"))  # rms_w_attr
v <- rms_w_attr %>%
  filter(prod_type == "ec", !is.na(units), units > 0, brand_descr_f == "VUSE",
         !is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f > 0) %>%   # same filter as panel
  mutate(upc12 = pad12(upc)) %>% filter(!upc12 %in% excl)

byupc <- v %>%
  group_by(upc12, flavor = flavor_f) %>%
  summarise(units_sold = sum(units),
            mL_sold = sum(units * liq_total_f),
            deliv_nic_mg = sum(units * nic_yield_tot_f),
            cap_mL_per_pkg = round(weighted.mean(liq_total_f, units), 2),
            mL_per_cart = round(weighted.mean(liq_cart_f, units), 2),
            n_carts = round(weighted.mean(num_cartridges_f, units), 1),
            raw_label = round(weighted.mean(nic_mg_per_ml_f, units, na.rm = TRUE), 1),
            .groups = "drop") %>%
  mutate(deliv_mg_per_mL = round(deliv_nic_mg / mL_sold, 1),      # cleaned delivered conc
         eff_label_mg_per_mL = round(deliv_mg_per_mL / YIELD_FACTOR, 1),  # implied label
         mL_share = round(100 * mL_sold / sum(mL_sold), 1)) %>%
  arrange(desc(mL_sold))

write_csv(byupc, file.path(out_dir, "vuse_upc_detail_2023.csv"))

cat("VUSE 2023:", nrow(byupc), "UPCs.  Top 15 by mL sold:\n\n")
byupc %>% transmute(mL_share, deliv_mg_per_mL, eff_label_mg_per_mL, cap_mL_per_pkg,
                    mL_per_cart, n_carts, flavor) %>%
  head(15) %>% as.data.frame() %>% print(row.names = FALSE)

deliv_w <- sum(byupc$deliv_nic_mg) / sum(byupc$mL_sold)
cat(sprintf("\nmL-weighted DELIVERED nicotine   = %.1f mg/mL   <- the panel/figure value\n", deliv_w))
cat(sprintf("implied mL-weighted LABEL (/0.68) = %.1f mg/mL\n", deliv_w / YIELD_FACTOR))

cat("\nDelivered-concentration buckets (mg/mL) and their mL share:\n")
byupc %>% mutate(band = cut(deliv_mg_per_mL, c(0,5,15,25,40,100))) %>%
  group_by(band) %>% summarise(mL_share = round(sum(mL_share), 1),
                               eff_label_range = paste0(min(eff_label_mg_per_mL),"-",max(eff_label_mg_per_mL)),
                               .groups = "drop") %>% as.data.frame() %>% print(row.names = FALSE)
