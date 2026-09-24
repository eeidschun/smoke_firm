## ============================================================================
## Construct a_{i,t}: the UPC-unweighted average delivered nicotine (mg/mL)
## across each incumbent's active UPCs, monthly -- the quality-state input to
## the supply-side demand system (see the companion model note §3, and the
## solution appendix §1). Same UPC-unweighted convention as the 08_27_2026
## note's 7.5b (Marc's instruction: firm-level nicotine state is a property of
## the firm's posted line, not its realized sales mix, so no mL weighting).
##
## Distribution-breadth filter (as of 2026-09-22): UPC-months backed by fewer
## than N_STORES_MIN distinct reporting stores are dropped BEFORE both the
## top-5 roster ranking and the a_it average -- a plausible signature of a
## handful of stores clearing overstock/discontinued inventory rather than
## genuine active distribution, and the concern was that either construction
## could be skewed by it. Verified this session: at N=3, only ~0.01% of total
## mL is dropped (vs ~19% of UPC-months -- confirms these are a long tail of
## tiny-volume listings), and the filter changes ZERO firm-years in the top-5
## roster (roster_diff_vs_unfiltered.csv). It DOES visibly clean up the a_it
## reference trajectories for firms outside their incumbent years, especially
## post-2020 trace-volume noise (NICOTEK, MISTIC, LOGIC, MARKTEN) -- that's
## the operative reason to keep it, not the roster (which didn't need it).
## Threshold is a raw store COUNT, not a share of that month's active store
## panel: the question ("is this UPC genuinely stocked somewhere, or is a
## handful of stores just unloading it") is about absolute retail footprint,
## not about keeping pace with however large Nielsen's tracked panel happens
## to be that year -- see build/6's header for the fuller argument. Needs
## input/upc_month_store_breadth.rds from build/6 (raw-file scan, run once).
##
## Tracked-firm selection: the annual top-5 ranking (mL share among
## identified brands, UNKNOWN excluded, positive volume that year) is used
## ONLY to decide WHICH firms are worth tracking at all -- the tracked set is
## the union of every brand that was a top-5 leader in ANY year. Once
## selected, a_it is built across a tracked firm's FULL monthly history, not
## gated to just the specific years it happened to rank top-5 -- a firm's
## state should be a continuous series (it doesn't have gaps just because it
## temporarily fell out of the top 5), matching how the model's own Fa/Fxi
## transition kernels are estimated off each incumbent's realized history
## (solution appendix §3). is_top5_that_year flags which months fall inside
## the firm's own top-5 years, for reference only.
##
## a_{i,t} is UPC-level (collapsed across T2 type first, in case the same
## upc12 spans multiple type rows in a month): mg/mL = nic_mg_sum / mL_sum per
## UPC-month, then a plain mean across a brand's (or the fringe's pooled)
## active UPCs that month. A top-5 firm with zero active UPCs in some month
## (a temporary gap within its incumbent year) gets NA, not 0 -- 0 mg/mL would
## misleadingly imply a real zero-nicotine product line.
## ============================================================================
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(PRELIM_DIR, "supply_model_state")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
fxn("5_supply_model_state_fxns.R")   # build_top5_roster(), build_a_it_and_fringe(), plot_*()

N_STORES_MIN <- 3

## ---- load UPC-month panel, drop UNKNOWN (not a firm) ----------------------
load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))   # upc_month_t2
um_all <- upc_month_t2 %>%
  mutate(brand = str_trim(brand)) %>%
  filter(brand != "UNKNOWN", units_sum > 0, mL_sum > 0) %>%
  group_by(month, brand, upc12) %>%                       # collapse across T2 type
  summarise(mL_sum = sum(mL_sum), nic_mg_sum = sum(nic_mg_sum), .groups = "drop") %>%
  mutate(upc_mgml = nic_mg_sum / mL_sum, year = year(month))

## ---- distribution-breadth filter -------------------------------------------
breadth_path <- file.path(SUPPORT_DIR, "upc_month_store_breadth.rds")
stopifnot(file.exists(breadth_path))   # run build/6 first
breadth <- readRDS(breadth_path)

um_b <- um_all %>% left_join(breadth %>% select(month, upc12, n_stores, store_share),
                              by = c("month", "upc12"))
n_unmatched <- sum(is.na(um_b$n_stores))
cat(sprintf("\nUPC-months with no matching store-breadth row: %d / %d (%.2f%%) -- treated as failing the filter (dropped)\n",
            n_unmatched, nrow(um_b), 100 * n_unmatched / nrow(um_b)))
um_b <- um_b %>% mutate(n_stores = coalesce(n_stores, 0L))

cat("\n=== distribution-breadth filter sensitivity ===\n")
sens <- map_dfr(c(3, 5, 10, 20), function(N) {
  dropped <- um_b %>% filter(n_stores < N)
  tibble(N = N, upc_months_dropped = nrow(dropped),
         pct_upc_months = round(100 * nrow(dropped) / nrow(um_b), 2),
         mL_dropped = sum(dropped$mL_sum),
         pct_mL = round(100 * sum(dropped$mL_sum) / sum(um_b$mL_sum), 3))
})
print(as.data.frame(sens), row.names = FALSE)
write_csv(sens, file.path(out_dir, "breadth_filter_sensitivity.csv"))

um <- um_b %>% filter(n_stores >= N_STORES_MIN) %>% select(-n_stores, -store_share)
cat(sprintf("\napplying N_STORES_MIN = %d: %d / %d UPC-months kept (%.1f%% of original mL retained)\n",
            N_STORES_MIN, nrow(um), nrow(um_all), 100 * sum(um$mL_sum) / sum(um_all$mL_sum)))

## ---- annual top-5 roster (on filtered data) --------------------------------
rr <- build_top5_roster(um)
roster <- rr$roster
write_csv(roster, file.path(out_dir, "incumbent_roster_by_year.csv"))

cat("\n=== Top-5 incumbent roster by year (annual mL share, fixed for that year's months; N_stores >=",
    N_STORES_MIN, ") ===\n")
roster %>% mutate(share_yr = round(100 * share_yr, 1)) %>%
  arrange(year, rank) %>% as.data.frame() %>% print(row.names = FALSE)

## ---- provenance: does the filter change WHO is top-5, vs. the unfiltered roster? ----
roster_unfiltered <- build_top5_roster(um_all)$roster
all_years  <- sort(unique(c(roster_unfiltered$year, roster$year)))
all_brands <- sort(unique(c(roster_unfiltered$brand, roster$brand)))
cmp <- crossing(year = all_years, brand = all_brands) %>%
  left_join(roster_unfiltered %>% transmute(year, brand, top5_orig = TRUE, rank_orig = rank),
            by = c("year", "brand")) %>%
  left_join(roster %>% transmute(year, brand, top5_filtered = TRUE, rank_filtered = rank),
            by = c("year", "brand")) %>%
  mutate(top5_orig = coalesce(top5_orig, FALSE), top5_filtered = coalesce(top5_filtered, FALSE)) %>%
  filter(top5_orig | top5_filtered) %>%
  mutate(flip = top5_orig != top5_filtered,
         change = case_when(top5_orig & !top5_filtered ~ "DROPPED by filter",
                            !top5_orig & top5_filtered ~ "ADDED by filter",
                            TRUE ~ "unchanged")) %>%
  arrange(year, desc(flip), rank_orig)
write_csv(cmp, file.path(out_dir, "roster_diff_vs_unfiltered.csv"))
n_flip <- sum(cmp$flip)
cat(sprintf("\nroster impact of the breadth filter: %d / %d rostered firm-years flip top-5 status\n",
            n_flip, nrow(cmp)))
if (n_flip > 0) cmp %>% filter(flip) %>% as.data.frame() %>% print(row.names = FALSE)

## ---- a_it (tracked firms, full history) + a_Ft (fringe) --------------------
af <- build_a_it_and_fringe(um, roster)
a_it <- af$a_it; a_Ft <- af$a_Ft; tracked_firms <- af$tracked_firms

write_csv(a_it, file.path(out_dir, "a_it_incumbents_monthly.csv"))

n_na <- sum(is.na(a_it$a_it))
cat(sprintf("\n=== a_it tracked firms: %d firm-months (%d firms x full sample), %d (%.1f%%) with no active UPCs that month (NA) ===\n",
            nrow(a_it), length(tracked_firms), n_na, 100 * n_na / nrow(a_it)))
cat("a_it summary (mg/mL, non-NA):\n")
print(summary(a_it$a_it))

write_csv(a_Ft, file.path(out_dir, "a_Ft_fringe_monthly.csv"))

cat("\n=== a_Ft fringe: monthly summary ===\n")
print(summary(a_Ft$a_Ft))
cat(sprintf("median active fringe UPCs/month: %.1f ; median distinct fringe brands/month: %.1f\n",
            median(a_Ft$n_active_upcs), median(a_Ft$n_fringe_brands)))

## ---- combined long file for downstream estimation code --------------------
combined <- bind_rows(
  a_it %>% transmute(month, entity = brand, role = "incumbent", a = a_it, n_active_upcs),
  a_Ft %>% transmute(month, entity = "FRINGE", role = "fringe", a = a_Ft, n_active_upcs)
)
write_csv(combined, file.path(out_dir, "a_it_and_fringe_monthly.csv"))

## ---- diagnostic figures ------------------------------------------------------
p <- plot_a_it_single(a_it, a_Ft, tracked_firms,
  title = expression(a[it]*": UPC-unweighted average delivered nicotine, tracked firms vs. fringe"),
  subtitle = paste0("Distribution-breadth filtered (N_stores >= ", N_STORES_MIN, "). Bold/colored = that firm's actual top-5 (incumbent) years; ",
                    "thin grey = tracked but not top-5 that year. Dashed grey = fringe (pooled)."))
ggsave(file.path(out_dir, "a_it_and_fringe_trajectories.png"), p, width = 10, height = 6, dpi = 200, bg = "white")

p_facet <- plot_a_it_facets(a_it, a_Ft, roster,
  title = expression(a[it]*": tracked firms, one panel each"),
  subtitle = paste0("Distribution-breadth filtered (N_stores >= ", N_STORES_MIN, "). Blue/bold = that firm's actual top-5 (incumbent) years; ",
                    "thin grey = tracked but not top-5 that year; dashed grey = fringe (pooled), shown for reference in every panel"))
ggsave(file.path(out_dir, "a_it_facets_by_firm.png"), p_facet, width = 12, height = 9, dpi = 200, bg = "white")

cat("\nWrote: breadth_filter_sensitivity.csv, incumbent_roster_by_year.csv, roster_diff_vs_unfiltered.csv,",
    "a_it_incumbents_monthly.csv, a_Ft_fringe_monthly.csv, a_it_and_fringe_monthly.csv,",
    "a_it_and_fringe_trajectories.png, a_it_facets_by_firm.png\n  ->", out_dir, "\n")
