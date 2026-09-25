## ============================================================================
## Stage 1 demand panel: incumbent x month rows for the nested-logit 2SLS
## (solution appendix §1, eq. 7), plus one market x month row carrying the
## fringe, outside option, market size and instruments.
##
## Sample: the same UPC-month subset as analysis/12 -- UNKNOWN dropped,
## units > 0, mL > 0, UPC-months in >= N_STORES_MIN = 3 stores.
##
##   incumbents  annual mL share among identified brands > 7%, fixed for all
##               12 months of that year (fxns/5 build_share_roster()).
##   fringe      every other identified brand that month, one aggregate row.
##   p_it        real $/mL = sum(revenue_real) / sum(mL) over the firm's UPCs.
##   a_it, a_Ft  UPC-unweighted mean delivered mg/mL (fxns/5, same as analysis/12).
##   M_t         k_t * US adult (18+) population, in mL. k_t = mean monthly mL
##               per e-cig-buying household in NCP (build/7), projection-
##               weighted. Baseline k_t is that year's average of the monthly
##               series; M_t_k_monthly and M_t_k_const are robustness variants.
##               Adult population is the July estimate for the year, used for
##               every month of that year.
##   shares      s_it = mL_it / M_t, s_Ft = fringe mL / M_t, s_gt = sum_i s_it +
##               s_Ft, s_0t = 1 - s_gt (appendix §1 step 1).
##   TaxIV_t     sum_s (Pop_s / Pop_US) * tax_st, real $/mL (Cotti et al.
##               conversion), weights from total state population that year.
##   n_firms_*   active-firm counts, the candidate instruments for
##               ln(s_it / s_gt). Several definitions are kept so analysis/14
##               can compare them; n_brands_3st is the baseline.
##
## Inputs: input/upc_month_niccorr_from_full.RData (build/5),
##         input/upc_month_store_breadth.rds (build/6),
##         input/avg_mL_by_hh_in_ncp.RData (build/7),
##         raw/ecig_taxes/ec_tax_cotti_per_mL.RData,
##         raw/census_pop/sc-est2020int-alldata6.csv (2013-2019),
##         raw/census_pop/sc-est2023-alldata6.csv (2020-2023).
##         Use alldata6 (race alone, mutually exclusive); alldata5 is race
##         alone-or-in-combination and double-counts.
## Output: input/demand_panel_firm_month.RData with
##         demand_im  (incumbent x month) and demand_mkt (month).
## ============================================================================
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

source("smoke_firm_dir/code/fxns/1_paths.R")
fxn("5_supply_model_state_fxns.R")   # build_share_roster(), build_a_it_and_fringe()

N_STORES_MIN <- 3
census_dir <- file.path(FIRM_DIR, "raw", "census_pop")

## ---- UPC-month sample (same filters as analysis/12) ------------------------
load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))   # upc_month_t2
breadth <- readRDS(file.path(SUPPORT_DIR, "upc_month_store_breadth.rds"))

um <- upc_month_t2 %>%
  mutate(brand = str_trim(brand)) %>%
  filter(brand != "UNKNOWN", units_sum > 0, mL_sum > 0) %>%
  group_by(month, brand, upc12) %>%                       # collapse across T2 type
  summarise(mL_sum = sum(mL_sum), nic_mg_sum = sum(nic_mg_sum),
            revenue_real = sum(revenue_real), .groups = "drop") %>%
  left_join(breadth %>% select(month, upc12, n_stores), by = c("month", "upc12")) %>%
  mutate(n_stores = coalesce(n_stores, 0L),
         upc_mgml = nic_mg_sum / mL_sum, year = year(month))
um_3 <- um %>% filter(n_stores >= N_STORES_MIN)

## ---- incumbent roster and nicotine states ----------------------------------
roster <- build_share_roster(um_3)$roster
af     <- build_a_it_and_fringe(um_3, roster)

## ---- brand-month volumes and prices ----------------------------------------
bm <- um_3 %>%
  group_by(month, year, brand) %>%
  summarise(mL = sum(mL_sum), revenue_real = sum(revenue_real), .groups = "drop") %>%
  left_join(roster %>% transmute(year, brand, incumbent = TRUE), by = c("year", "brand")) %>%
  mutate(incumbent = coalesce(incumbent, FALSE))

## ---- market size M_t -------------------------------------------------------
read_pop <- function(f, yrs) {
  read.csv(file.path(census_dir, f), colClasses = c(STATE = "character")) %>%
    filter(SEX == 0, ORIGIN == 0) %>%                       # totals; sum over RACE
    select(STATE, AGE, all_of(paste0("POPESTIMATE", yrs))) %>%
    pivot_longer(starts_with("POPESTIMATE"), names_to = "year",
                 names_prefix = "POPESTIMATE", values_to = "pop") %>%
    mutate(year = as.integer(year)) %>%
    group_by(STATE, year) %>%
    summarise(pop18 = sum(pop[AGE >= 18]), pop = sum(pop), .groups = "drop")
}
pop_state <- bind_rows(read_pop("sc-est2020int-alldata6.csv", 2013:2019),
                       read_pop("sc-est2023-alldata6.csv",    2020:2023))
stopifnot(all(count(pop_state, year)$n == 51))
pop_us <- pop_state %>% group_by(year) %>%
  summarise(pop_us = sum(pop), adults_us = sum(pop18), .groups = "drop")

load(file.path(SUPPORT_DIR, "avg_mL_by_hh_in_ncp.RData"))   # M_t_long
k <- M_t_long %>% filter(name == "hh_wt_avg_mL") %>%
  transmute(month = as.Date(paste0(year_month, "-01")), k_monthly = value) %>%
  mutate(year = year(month)) %>%
  group_by(year) %>% mutate(k_annual = mean(k_monthly)) %>% ungroup() %>%
  mutate(k_const = mean(k_monthly))

## ---- price instrument TaxIV_t ----------------------------------------------
load(file.path(FIRM_DIR, "raw", "ecig_taxes", "ec_tax_cotti_per_mL.RData"))   # closed_t
tax <- closed_t %>%
  transmute(month = as.Date(paste0(year_month, "-01")),
            STATE = str_pad(fips_state_code, 2, "left", "0"),
            tau = real_tau_per_mL) %>%
  mutate(year = year(month))
tax_w <- tax %>%
  left_join(pop_state %>% select(STATE, year, pop), by = c("STATE", "year")) %>%
  left_join(pop_us %>% select(year, pop_us), by = "year")
stopifnot(!anyNA(tax_w$pop))
tax_iv <- tax_w %>% group_by(month) %>%
  summarise(TaxIV = sum(pop / pop_us * tau), n_states = n(),
            n_states_taxed = sum(tau > 0), .groups = "drop")
stopifnot(all(tax_iv$n_states == 51))

## ---- active-firm counts (candidate instruments for ln(s_it / s_gt)) --------
n_firms <- um %>%
  group_by(month) %>%
  summarise(n_brands_3st  = n_distinct(brand[n_stores >= 3]),
            n_brands_20st = n_distinct(brand[n_stores >= 20]),
            n_brands_any  = n_distinct(brand), .groups = "drop") %>%
  left_join(count(roster, year, name = "n_incumbents") %>%
              right_join(tibble(month = unique(um$month)) %>% mutate(year = year(month)), by = "year") %>%
              select(month, n_incumbents), by = "month")

## ---- market x month table --------------------------------------------------
demand_mkt <- bm %>%
  group_by(month, year) %>%
  summarise(mL_inc = sum(mL[incumbent]), mL_fringe = sum(mL[!incumbent]),
            rev_fringe = sum(revenue_real[!incumbent]),
            n_fringe_brands = sum(!incumbent), .groups = "drop") %>%
  left_join(k, by = c("month", "year")) %>%
  left_join(pop_us, by = "year") %>%
  mutate(M_t           = k_annual  * adults_us,
         M_t_k_monthly = k_monthly * adults_us,
         M_t_k_const   = k_const   * adults_us,
         s_F  = mL_fringe / M_t,
         s_g  = (mL_inc + mL_fringe) / M_t,
         s_0  = 1 - s_g,
         p_F  = rev_fringe / mL_fringe) %>%
  left_join(tax_iv, by = "month") %>%
  left_join(n_firms, by = "month") %>%
  left_join(af$a_Ft %>% select(month, a_Ft), by = "month") %>%
  arrange(month)

## ---- incumbent x month table (the regression sample) -----------------------
demand_im <- bm %>%
  filter(incumbent) %>%
  left_join(demand_mkt %>% select(month, M_t, M_t_k_monthly, M_t_k_const, s_g, s_0,
                                  mL_inc, mL_fringe, TaxIV, starts_with("n_")),
            by = "month") %>%
  left_join(af$a_it %>% select(month, brand, a_it), by = c("month", "brand")) %>%
  mutate(p_it   = revenue_real / mL,
         s_it   = mL / M_t,
         s_i_g  = s_it / s_g,                                # within-nest share
         y      = log(s_it) - log(s_0),                      # eq. 7 LHS
         ln_s_i_g = log(s_i_g)) %>%                          # eq. 7 within-nest regressor
  select(month, year, brand, mL, revenue_real, p_it, a_it, s_it, s_i_g, s_g, s_0,
         y, ln_s_i_g, TaxIV, starts_with("n_"), M_t, M_t_k_monthly, M_t_k_const) %>%
  arrange(brand, month)

## ---- checks ----------------------------------------------------------------
cat("\n=== incumbents per year (7% rule) ===\n")
print(count(roster, year, name = "n_incumbents") %>% as.data.frame(), row.names = FALSE)

# every incumbent should sell in every month of its incumbent year
exp_rows <- roster %>% select(year, brand) %>%
  inner_join(tibble(month = sort(unique(um$month))) %>% mutate(year = year(month)),
             by = "year", relationship = "many-to-many")
missing_im <- anti_join(exp_rows, demand_im, by = c("month", "brand"))
cat(sprintf("\nincumbent-months expected %d, present %d, missing (zero sales) %d\n",
            nrow(exp_rows), nrow(demand_im), nrow(missing_im)))
if (nrow(missing_im) > 0) print(as.data.frame(missing_im), row.names = FALSE)

stopifnot(nrow(demand_mkt) == 132, !anyNA(demand_mkt$TaxIV), !anyNA(demand_mkt$M_t),
          all(demand_mkt$s_0 > 0 & demand_mkt$s_0 < 1))
cat(sprintf("a_it NA among incumbent-months: %d\n", sum(is.na(demand_im$a_it))))

cat("\n=== market by year ===\n")
demand_mkt %>% group_by(year) %>%
  summarise(k_annual = first(k_annual), adults_M = first(adults_us) / 1e6,
            M_t_bn_mL = mean(M_t) / 1e9, s_g_pct = 100 * mean(s_g),
            s_F_over_s_g = mean(s_F / s_g), TaxIV = mean(TaxIV),
            n_brands_3st = mean(n_brands_3st), n_incumbents = first(n_incumbents)) %>%
  mutate(across(where(is.double), ~ signif(.x, 4))) %>%
  as.data.frame() %>% print(row.names = FALSE)

cat("\n=== incumbent prices and within-nest shares, by firm ===\n")
demand_im %>% group_by(brand) %>%
  summarise(years = paste(range(year), collapse = "-"), n = n(),
            p_mean = mean(p_it), p_min = min(p_it), p_max = max(p_it),
            s_i_g_mean = mean(s_i_g), a_mean = mean(a_it, na.rm = TRUE)) %>%
  mutate(across(where(is.double), ~ signif(.x, 3))) %>%
  arrange(years) %>% as.data.frame() %>% print(row.names = FALSE)

save(demand_im, demand_mkt, file = file.path(SUPPORT_DIR, "demand_panel_firm_month.RData"))
cat("\nWrote", file.path(SUPPORT_DIR, "demand_panel_firm_month.RData"),
    sprintf("(demand_im: %d rows, demand_mkt: %d rows)\n", nrow(demand_im), nrow(demand_mkt)))
