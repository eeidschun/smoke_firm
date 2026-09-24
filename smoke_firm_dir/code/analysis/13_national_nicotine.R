## ============================================================================
## National monthly delivered nicotine concentration (mg/mL), pooled across
## product types -- the nic_mg_per_mL panel of
## national_monthly_series_by_type.png as a single pooled line, built on the
## same subsetting as analysis/12_supply_model_nicotine_state.R:
##   - UPC-month panel (upc_month_niccorr_from_full.RData), UNKNOWN brand
##     dropped, units_sum > 0 and mL_sum > 0
##   - distribution-breadth filter: UPC-months with < N_STORES_MIN distinct
##     reporting stores dropped (UPC-months with no store-breadth row are
##     treated as failing, as in analysis/12)
## mL-weighted, same definition as analysis/1_decompose_t2.R:
##   nic_mg_per_mL = sum(nic_mg) / sum(mL)
##
## Needs input/upc_month_store_breadth.rds from build/6.
## Output: output/prelim_analysis/p_and_n_decomp_t2/national_monthly_nicotine.{csv,png}
## ============================================================================
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(PRELIM_DIR, "p_and_n_decomp_t2")

N_STORES_MIN <- 3
FDA_2018 <- tibble(date = as.Date("2018-09-01"),
                   label = "FDA youth-vaping 'epidemic' letters (Sep 2018)")

## ---- UPC-month panel, same subsetting as analysis/12 -------------------------
load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))   # upc_month_t2
um_all <- upc_month_t2 %>%
  mutate(brand = str_trim(brand)) %>%
  filter(brand != "UNKNOWN", units_sum > 0, mL_sum > 0) %>%
  group_by(month, brand, upc12) %>%                       # collapse across type rows
  summarise(mL_sum = sum(mL_sum), nic_mg_sum = sum(nic_mg_sum), .groups = "drop")

breadth_path <- file.path(SUPPORT_DIR, "upc_month_store_breadth.rds")
stopifnot(file.exists(breadth_path))   # run build/6 first
breadth <- readRDS(breadth_path)

um <- um_all %>%
  left_join(breadth %>% select(month, upc12, n_stores), by = c("month", "upc12")) %>%
  mutate(n_stores = coalesce(n_stores, 0L)) %>%
  filter(n_stores >= N_STORES_MIN)
cat(sprintf("N_STORES_MIN = %d: %d / %d UPC-months kept (%.2f%% of mL retained)\n",
            N_STORES_MIN, nrow(um), nrow(um_all), 100 * sum(um$mL_sum) / sum(um_all$mL_sum)))

## ---- pooled national monthly series (mL-weighted) -----------------------------
natl <- um %>%
  group_by(month) %>%
  summarise(nic_mg_per_mL = sum(nic_mg_sum) / sum(mL_sum),
            n_active_upcs = n(), mL_sum = sum(mL_sum), .groups = "drop")
write_csv(natl %>% mutate(nic_mg_per_mL = round(nic_mg_per_mL, 3), mL_sum = round(mL_sum)),
          file.path(out_dir, "national_monthly_nicotine.csv"))

## ---- figure --------------------------------------------------------------------
p <- ggplot(natl, aes(month, nic_mg_per_mL)) +
  geom_vline(data = FDA_2018, aes(xintercept = date),
             linetype = "dashed", color = "grey45", linewidth = 0.4) +
  geom_line(linewidth = 0.9, color = "#e31a1c") +
  labs(title = "Nicotine Concentration (mg/mL)", subtitle = "mL-weighted",
       x = NULL, y = "Nicotine Concentration (mg/mL)",
       caption = paste("Dashed line:", FDA_2018$label)) +
  theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        axis.text = element_text(size = 14),
        plot.caption = element_text(hjust = 0, size = 12, color = "grey40"))
ggsave(file.path(out_dir, "national_monthly_nicotine.png"), p,
       width = 10, height = 6, dpi = 200, bg = "white")

cat("Wrote national_monthly_nicotine.csv / .png ->", out_dir, "\n")
