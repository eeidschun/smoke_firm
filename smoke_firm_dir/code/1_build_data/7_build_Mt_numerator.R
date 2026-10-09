## ============================================================================
## M_t numerator: average monthly e-liquid mL per e-cig-buying household (NCP)
##
## Market size is M_t = k_t * US adult population; this script builds k_t.
## For each month: sum liq_total_f (already includes units bought) within
## household-month, then average across buying households -- simple mean and
## projection-weighted (wt) mean. Output is long: one row per year_month x name.
##
## EXTERNAL INPUT AND WHERE TO PLACE IT
## Run from the repository root. The default NCP_CPS_PATH below expects:
##   <repository root>/input/NCP/cps_2013-2023.RData
## This is root-level input/, NOT smoke_firm_dir/input/. Place the externally
## prepared demand-side NCP purchase file there, or edit NCP_CPS_PATH below
## to its actual absolute path. The source purchase file is not supplied here.
##
## The .RData must contain cps_yr_all with these columns:
##   ec              logical e-cigarette purchase flag
##   household_code  household identifier
##   upc             UPC identifier
##   trip_code_uc    trip identifier (purchase grain is one row per trip x UPC)
##   wt              household projection weight
##   year_month      month formatted YYYY-MM, covering 2013-01 through 2023-12
##   liq_total_f     purchased mL, already multiplied by units bought
## Earlier exact duplicate rows are removed by distinct(); missing mL rows
## are excluded. No RMS, tax, or Census input is needed by this script.
##
## OUTPUT
## Writes M_t_long (year_month, name, value, date) to:
##   <repository root>/smoke_firm_dir/input/avg_mL_by_hh_in_ncp.RData
## This output is already supplied, so 0_master.R uses it and deliberately
## excludes this external-input builder. Back up the saved output before
## manually rerunning this script.
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
