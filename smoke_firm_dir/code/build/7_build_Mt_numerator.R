## ============================================================================
## M_t numerator: average monthly e-liquid mL per e-cig-buying household (NCP)
##
## Market size is M_t = k_t * US adult population; this script builds k_t.
## For each month: sum liq_total_f (already includes units bought) within
## household-month, then average across buying households -- simple mean and
## projection-weighted (wt) mean. Output is long: one row per year_month x name.
##
## Input is the demand-side Nielsen Consumer Panel purchase file, which is NOT in
## this repo -- set NCP_CPS_PATH to wherever it lives on your machine.
## ============================================================================

rm(list = ls())
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(ggplot2) })

source("smoke_firm_dir/code/fxns/1_paths.R")

NCP_CPS_PATH <- "input/NCP/cps_2013-2023.RData"   # demand-side file; edit to your local path
if (!file.exists(NCP_CPS_PATH))
  stop("7_build_Mt_numerator.R: demand-side file not found at ", NCP_CPS_PATH,
       " -- set NCP_CPS_PATH.", call. = FALSE)
load(NCP_CPS_PATH)   # -> cps_yr_all

cps_ec = cps_yr_all %>% filter(ec) %>% select(household_code, upc, trip_code_uc, wt, year_month, liq_total_f)
cps_ec = cps_ec %>% filter(!is.na(liq_total_f))
cps_ec = cps_ec %>% distinct()   # guards against earlier duplicated rows; cps is one row per trip x upc

cps_ec = cps_ec %>% group_by(household_code, wt, year_month) %>% summarise(liq_total_f_in_month_for_hh = sum(liq_total_f)) %>% ungroup()

M_t = cps_ec %>% group_by(year_month) %>% summarise(simple_avg_mL = mean(liq_total_f_in_month_for_hh),
                                              hh_wt_avg_mL = weighted.mean(liq_total_f_in_month_for_hh, wt)) %>% ungroup()

M_t_long = M_t %>% pivot_longer(cols = c(simple_avg_mL, hh_wt_avg_mL))

M_t_long <- M_t_long %>%
  mutate(date = as.Date(paste0(year_month, "-01")))

ggplot(M_t_long, aes(x = date, y = value, color = name)) +
  geom_line() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")

save(M_t_long, file = file.path(SUPPORT_DIR, "avg_mL_by_hh_in_ncp.RData"))
