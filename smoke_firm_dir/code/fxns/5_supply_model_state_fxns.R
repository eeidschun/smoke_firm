## ============================================================================
## Shared construction + plotting functions for the a_it / fringe / top-5
## incumbent roster pipeline, used by analysis/12. Factored out so the same
## logic runs on both the store-breadth-filtered and unfiltered UPC-month
## panels (analysis/12 builds the unfiltered roster only for comparison),
## instead of risking drift between two hand-copied versions.
##
## Input contract: `um`, a UPC-month table already collapsed to one row per
## (month, brand, upc12) with columns mL_sum, nic_mg_sum,
## upc_mgml = nic_mg_sum / mL_sum, year = year(month), UNKNOWN already
## dropped -- see either caller's "load UPC-month panel" block.
## ============================================================================
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })
fxn("4_event_lines_t2.R")   # events, event_vlines(), event_caption

N_BAR_DEFAULT <- 5

## ---- top-5 roster: ranked once per year on realized mL share --------------
build_top5_roster <- function(um, N_BAR = N_BAR_DEFAULT) {
  brand_yr <- um %>%
    group_by(year, brand) %>%
    summarise(mL = sum(mL_sum), .groups = "drop") %>%
    group_by(year) %>%
    mutate(share = mL / sum(mL)) %>%
    arrange(year, desc(share)) %>%
    mutate(rank = row_number()) %>%
    ungroup()
  roster <- brand_yr %>% filter(rank <= N_BAR) %>%
    select(year, brand, rank, share_yr = share)
  list(brand_yr = brand_yr, roster = roster)
}

## ---- a_it (tracked firms, full history) + a_Ft (fringe, pooled) -----------
build_a_it_and_fringe <- function(um, roster) {
  tracked_firms <- roster %>% distinct(brand) %>% pull(brand)
  um_tracked <- um %>% filter(brand %in% tracked_firms)

  a_it_raw <- um_tracked %>%
    group_by(month, brand) %>%
    summarise(a_it = mean(upc_mgml), n_active_upcs = n(), .groups = "drop")

  full_grid <- tidyr::crossing(brand = tracked_firms,
                                month = seq(min(um$month), max(um$month), by = "month"))
  a_it <- full_grid %>%
    mutate(year = year(month)) %>%
    left_join(a_it_raw, by = c("month", "brand")) %>%
    left_join(roster %>% select(year, brand, rank), by = c("year", "brand")) %>%
    select(-year) %>%
    mutate(is_top5_that_year = !is.na(rank)) %>%
    select(-rank) %>%
    arrange(brand, month)

  ## fringe = complement of roster (that YEAR's top-5), not of tracked_firms:
  ## a tracked firm still has UPCs in years it wasn't top-5 (e.g. BLU in
  ## 2021), and that volume is properly fringe in those years. Gating on
  ## tracked_firms instead would silently drop it from both series.
  fringe_upcs <- um %>% anti_join(roster, by = c("year", "brand"))
  a_Ft <- fringe_upcs %>%
    group_by(month) %>%
    summarise(a_Ft = mean(upc_mgml), n_active_upcs = n(),
              n_fringe_brands = n_distinct(brand), .groups = "drop")

  list(a_it = a_it, a_Ft = a_Ft, tracked_firms = tracked_firms)
}

## ---- contiguous top-5 "on" runs, for plotting (a firm can have >1 run) -----
compute_top5_runs <- function(a_it) {
  mo_idx <- function(m) as.integer(format(m, "%Y")) * 12L + as.integer(format(m, "%m"))
  a_it %>%
    filter(is_top5_that_year) %>%
    arrange(brand, month) %>%
    group_by(brand) %>%
    mutate(run_id = cumsum(c(1L, diff(mo_idx(month))) > 1L)) %>%
    ungroup() %>%
    mutate(series_run = paste(brand, run_id))
}

## ---- plots ------------------------------------------------------------------
.a_it_theme <- function() theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())

## Two geom_line layers per firm (not one aesthetic mapping) so the line
## stays continuous across TRUE/FALSE transitions instead of breaking: a
## thin/faded/grey layer over every month (group = brand only), overlaid with
## a bold/colored layer restricted to is_top5_that_year==TRUE runs (grouped
## by brand + run so non-contiguous top-5 spells render as separate segments).
plot_a_it_single <- function(a_it, a_Ft, tracked_firms, title, subtitle) {
  top5_runs <- compute_top5_runs(a_it)
  ggplot() +
    event_vlines() +
    geom_line(data = a_Ft, aes(month, a_Ft),
              linewidth = 1, linetype = "dashed", color = "grey30") +
    geom_line(data = a_it, aes(month, a_it, group = brand),
              color = "grey75", linewidth = 0.35, alpha = 0.8) +
    geom_line(data = top5_runs, aes(month, a_it, color = brand, group = series_run),
              linewidth = 1.05) +
    scale_color_manual(values = setNames(scales::hue_pal()(length(tracked_firms)), tracked_firms)) +
    labs(title = title, subtitle = subtitle,
         x = NULL, y = "delivered nicotine (mg/mL)", color = NULL, caption = event_caption) +
    .a_it_theme() +
    theme(plot.caption = element_text(hjust = 0, size = 8, color = "grey40"))
}

## One panel per firm; fringe repeated as a light reference in every panel
## (achieved by leaving `brand` out of that layer's data, so ggplot draws it
## once per facet). Single consistent highlight color -- brand color-coding
## is redundant once each firm has its own facet strip label.
plot_a_it_facets <- function(a_it, a_Ft, roster, title, subtitle) {
  top5_runs <- compute_top5_runs(a_it)
  firm_order <- roster %>% group_by(brand) %>%
    summarise(first_year = min(year), .groups = "drop") %>%
    arrange(first_year) %>% pull(brand)
  a_it_f      <- a_it      %>% mutate(brand = factor(brand, levels = firm_order))
  top5_runs_f <- top5_runs %>% mutate(brand = factor(brand, levels = firm_order))

  ggplot() +
    event_vlines() +
    geom_line(data = a_Ft, aes(month, a_Ft),
              linewidth = 0.6, linetype = "dashed", color = "grey55") +
    geom_line(data = a_it_f, aes(month, a_it, group = brand),
              color = "grey75", linewidth = 0.35, alpha = 0.9) +
    geom_line(data = top5_runs_f, aes(month, a_it, group = series_run),
              color = "#1f78b4", linewidth = 0.9) +
    facet_wrap(~brand, scales = "free_y", ncol = 4) +
    labs(title = title, subtitle = subtitle,
         x = NULL, y = "delivered nicotine (mg/mL)", caption = event_caption) +
    .a_it_theme() +
    theme(plot.caption = element_text(hjust = 0, size = 8, color = "grey40"),
          legend.position = "none", strip.text = element_text(face = "bold"))
}
