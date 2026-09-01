## ARCHIVED / SUPERSEDED. Loads the PRE-nicotine-correction panel
## `bt_month_t2_from_full.RData` (the "do-not-use, has incorrect nic" panel).
## Live equivalent: analysis/1_decompose_t2.R on the corrected panel.
##
## Recreate ALL archive/2_decompose_p_and_n.R outputs, but on the T2 panel
## (bt_month_t2, built by archive/1_build_t2_panel.R: overrides, exclusions,
## imputation, HAUS->MISTIC, etc.). This is the POOLED "homogeneous e-cigarette" view
## (national, not within-type). Output goes to p_and_n_decomp_t2 alongside the
## within-type outputs from decompose_t2.R.
##
## Only the panel source changes: instead of rebuilding bt_month from raw, we
## load bt_month_t2 and rename it bt_month; everything downstream is identical
## to decompose_p_and_n.R.

rm(list = ls())
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
})

source("smoke_firm_dir/code/fxns/1_paths.R")
input_dir  <- SUPPORT_DIR
output_dir <- file.path(PRELIM_DIR, "p_and_n_decomp_t2")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

## ---------- 1. Load the corrected T2 panel (same schema as bt_month) ----------
load(file.path(input_dir, "bt_month_t2_from_full.RData"))  # bt_month_t2
bt_month <- bt_month_t2
stopifnot(all(c("year_month","brand","type","units_sum","mL_sum","revenue_real",
                "nic_mg_sum","mL_sq_times_unit_sum","month","P_hom_cell","N_hom_cell",
                "mL_share") %in% names(bt_month)))
cat("Loaded T2 panel:", nrow(bt_month), "cells,",
    n_distinct(bt_month$month), "months\n")

## ---------- 2. National monthly panel ----------
## Same flow-based approach: sum flows, then form ratios. This guarantees
## national avg = mL-weighted mean of cell values.

national_month <- bt_month %>%
  group_by(month) %>%
  summarise(
    units_sum    = sum(units_sum),
    mL_sum       = sum(mL_sum),
    revenue_real = sum(revenue_real),
    nic_mg_sum   = sum(nic_mg_sum),
    mL_sq_x_u    = sum(mL_sq_times_unit_sum),
    .groups = "drop"
  ) %>%
  mutate(
    price_per_mL    = revenue_real / mL_sum,
    nic_mg_per_mL   = nic_mg_sum   / mL_sum,
    avg_mL_per_ecig = mL_sq_x_u    / mL_sum,
    P_hom           = price_per_mL  * avg_mL_per_ecig,
    N_hom           = nic_mg_per_mL * avg_mL_per_ecig
  )

## ---------- 3. Helper: rebuild a panel at any grouping ----------
build_panel <- function(bt_month, group_cols) {
  bt_month %>%
    group_by(month, across(all_of(group_cols))) %>%
    summarise(
      mL_sum       = sum(mL_sum),
      revenue_real = sum(revenue_real),
      nic_mg_sum   = sum(nic_mg_sum),
      mL_sq_x_u    = sum(mL_sq_times_unit_sum),
      .groups = "drop"
    ) %>%
    mutate(
      price_per_mL    = revenue_real / mL_sum,
      nic_mg_per_mL   = nic_mg_sum   / mL_sum,
      avg_mL_per_ecig = mL_sq_x_u    / mL_sum,
      P_hom_cell      = price_per_mL  * avg_mL_per_ecig,
      N_hom_cell      = nic_mg_per_mL * avg_mL_per_ecig
    ) %>%
    group_by(month) %>%
    mutate(mL_share = mL_sum / sum(mL_sum)) %>%
    ungroup()
}

## ---------- 4. Decomposition helpers ----------
decomp_product <- function(a0, a1, b0, b1) {
  tibble(
    a_channel      = (a1 - a0) * b0,
    b_channel      = a0 * (b1 - b0),
    interaction    = (a1 - a0) * (b1 - b0),
    total          = a1 * b1 - a0 * b0
  )
}

p_hom_channels <- function(natl, base, comp) {
  b <- natl %>% filter(month == base)
  c <- natl %>% filter(month == comp)
  decomp_product(b$price_per_mL, c$price_per_mL,
                 b$avg_mL_per_ecig, c$avg_mL_per_ecig) %>%
    rename(price_per_mL_channel = a_channel,
           size_channel         = b_channel) %>%
    mutate(base = base, comp = comp,
           P_hom_base = b$P_hom, P_hom_comp = c$P_hom)
}

n_hom_channels <- function(natl, base, comp) {
  b <- natl %>% filter(month == base)
  c <- natl %>% filter(month == comp)
  decomp_product(b$nic_mg_per_mL, c$nic_mg_per_mL,
                 b$avg_mL_per_ecig, c$avg_mL_per_ecig) %>%
    rename(nic_per_mL_channel = a_channel,
           size_channel       = b_channel) %>%
    mutate(base = base, comp = comp,
           N_hom_base = b$N_hom, N_hom_comp = c$N_hom)
}

decomp_shares <- function(df, base, comp, key_cols, x_col) {
  b <- df %>% filter(month == base) %>%
    select(all_of(key_cols), s0 = mL_share, x0 = all_of(x_col))
  c <- df %>% filter(month == comp) %>%
    select(all_of(key_cols), s1 = mL_share, x1 = all_of(x_col))
  full_join(b, c, by = key_cols) %>%
    mutate(across(c(s0, s1, x0, x1), ~replace_na(.x, 0))) %>%
    mutate(
      within      = s0 * (x1 - x0),
      composition = (s1 - s0) * x0,
      interaction = (s1 - s0) * (x1 - x0),
      total       = within + composition + interaction,
      base_month  = base,
      comp_month  = comp
    )
}

## ---------- 5. Run decompositions between two dates ----------
compare_dates <- function(bt_month, natl, base, comp) {
  bt_panel    <- build_panel(bt_month, c("brand", "type"))
  brand_panel <- build_panel(bt_month, "brand")
  type_panel  <- build_panel(bt_month, "type")

  measures <- c("price_per_mL", "avg_mL_per_ecig", "nic_mg_per_mL",
                "P_hom_cell", "N_hom_cell")
  panels   <- list(bt = bt_panel, brand = brand_panel, type = type_panel)
  keys     <- list(bt = c("brand", "type"), brand = "brand", type = "type")

  decomp <- list()
  for (m in measures) {
    decomp[[m]] <- list()
    for (lvl in names(panels)) {
      decomp[[m]][[lvl]] <- decomp_shares(panels[[lvl]], base, comp,
                                          keys[[lvl]], m)
    }
  }

  list(
    p_hom_channels = p_hom_channels(natl, base, comp),
    n_hom_channels = n_hom_channels(natl, base, comp),
    decomp         = decomp,
    panels         = panels
  )
}

available_months <- sort(unique(national_month$month))
cat("Months available:", length(available_months), "\n")
cat("  first:", format(min(available_months)), "  last:", format(max(available_months)), "\n")

base_month <- min(available_months)
comp_month <- max(available_months)

cat("\nDecomposing", format(base_month), "->", format(comp_month), "\n")
res <- compare_dates(bt_month, national_month, base_month, comp_month)

## ---------- 6. Summary printing + CSV output ----------
save_csv <- function(df, name) {
  write.csv(df, file.path(output_dir, paste0(name, ".csv")), row.names = FALSE)
}

top_drivers <- function(df, n = 30) {
  df %>% arrange(desc(abs(total))) %>% head(n)
}

save_csv(res$p_hom_channels, "p_hom_channels")
save_csv(res$n_hom_channels, "n_hom_channels")

for (m in names(res$decomp)) {
  for (lvl in names(res$decomp[[m]])) {
    save_csv(res$decomp[[m]][[lvl]],
             paste0("decomp_", m, "_by_", lvl))
    save_csv(top_drivers(res$decomp[[m]][[lvl]], 30),
             paste0("top_drivers_", m, "_by_", lvl))
  }
}

cat("\n=== Delta P_hom (real $), price/mL vs size channels ===\n")
print(res$p_hom_channels)
cat("\n=== Delta N_hom (mg per e-cig), nic/mL vs size channels ===\n")
print(res$n_hom_channels)
cat("\n=== P_hom (real $) at the two endpoints ===\n")
print(national_month %>% filter(month %in% c(base_month, comp_month)) %>%
        select(month, price_per_mL, avg_mL_per_ecig, P_hom,
               nic_mg_per_mL, N_hom))
cat("\n=== Delta(avg price/mL), decomposed by type ===\n")
print(res$decomp$price_per_mL$type %>%
        select(type, s0, s1, x0, x1, within, composition, interaction, total))
cat("\n=== Delta(avg mL/ecig), decomposed by type ===\n")
print(res$decomp$avg_mL_per_ecig$type %>%
        select(type, s0, s1, x0, x1, within, composition, interaction, total))
cat("\n=== Delta(avg nic mg/mL), decomposed by type ===\n")
print(res$decomp$nic_mg_per_mL$type %>%
        select(type, s0, s1, x0, x1, within, composition, interaction, total))
cat("\n=== Top 15 (brand, type) contributors to Delta P_hom_cell ===\n")
print(top_drivers(res$decomp$P_hom_cell$bt, 15) %>%
        select(brand, type, s0, s1, x0, x1, within, composition, interaction, total))
cat("\n=== Top 15 (brand, type) contributors to Delta N_hom_cell ===\n")
print(top_drivers(res$decomp$N_hom_cell$bt, 15) %>%
        select(brand, type, s0, s1, x0, x1, within, composition, interaction, total))
cat("\n=== Top 15 brand contributors to Delta P_hom_cell ===\n")
print(top_drivers(res$decomp$P_hom_cell$brand, 15) %>%
        select(brand, s0, s1, x0, x1, within, composition, interaction, total))

totals_by_measure_level <- map_dfr(
  names(res$decomp),
  function(m) {
    map_dfr(names(res$decomp[[m]]), function(lvl) {
      d <- res$decomp[[m]][[lvl]]
      tibble(
        measure     = m,
        level       = lvl,
        within      = sum(d$within,      na.rm = TRUE),
        composition = sum(d$composition, na.rm = TRUE),
        interaction = sum(d$interaction, na.rm = TRUE),
        total       = sum(d$total,       na.rm = TRUE)
      )
    })
  }
)
save_csv(totals_by_measure_level, "summary_totals_by_measure_and_level")
cat("\n=== Summary: within/composition/interaction totals for each measure x level ===\n")
print(totals_by_measure_level, n = 100)

## ---------- 7. Plots ----------
save_plot <- function(gg, name, w = 8, h = 5) {
  ggsave(file.path(output_dir, paste0(name, ".png")), gg, width = w, height = h)
}

plot_natl <- national_month %>%
  select(month, price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom) %>%
  pivot_longer(-month, names_to = "series", values_to = "value") %>%
  mutate(series = factor(series,
                         levels = c("price_per_mL", "avg_mL_per_ecig", "P_hom",
                                    "nic_mg_per_mL", "N_hom"))) %>%
  ggplot(aes(month, value, color = series)) +
  geom_line(linewidth = 1) +
  facet_wrap(~series, scales = "free_y") +
  labs(title = "National monthly e-cigarette series (real $, mg, mL) - T2 corrected",
       x = NULL, y = NULL) +
  theme(legend.position = "none")
save_plot(plot_natl, "national_monthly_series", w = 10, h = 6)

type_panel <- build_panel(bt_month, "type")
save_plot(
  ggplot(type_panel, aes(month, mL_share, color = type)) +
    geom_line(linewidth = 1) +
    labs(title = "mL share by product type", y = "mL share", x = NULL),
  "type_shares"
)
save_plot(
  ggplot(type_panel, aes(month, price_per_mL, color = type)) +
    geom_line(linewidth = 1) +
    labs(title = "Price per mL by product type (real $)", y = "$/mL", x = NULL),
  "type_price_per_mL"
)
save_plot(
  ggplot(type_panel, aes(month, avg_mL_per_ecig, color = type)) +
    geom_line(linewidth = 1) +
    labs(title = "Average mL per e-cigarette by product type",
         y = "mL/e-cig", x = NULL),
  "type_avg_mL_per_ecig"
)

brand_panel <- build_panel(bt_month, "brand")
top_brands <- brand_panel %>%
  group_by(brand) %>%
  summarise(total_mL = sum(mL_sum), .groups = "drop") %>%
  slice_max(total_mL, n = 8) %>%
  pull(brand)

save_plot(
  ggplot(brand_panel %>% filter(brand %in% top_brands),
         aes(month, mL_share, color = brand)) +
    geom_line(linewidth = 1) +
    labs(title = "mL share by top brands", y = "mL share", x = NULL),
  "top_brand_shares"
)
save_plot(
  ggplot(brand_panel %>% filter(brand %in% top_brands),
         aes(month, price_per_mL, color = brand)) +
    geom_line(linewidth = 1) +
    labs(title = "Price per mL by top brands (real $)", y = "$/mL", x = NULL),
  "top_brand_price_per_mL"
)

p_ch_long <- res$p_hom_channels %>%
  select(price_per_mL_channel, size_channel, interaction, total) %>%
  pivot_longer(everything(), names_to = "component", values_to = "value")
save_plot(
  ggplot(p_ch_long, aes(component, value, fill = component)) +
    geom_col() +
    geom_text(aes(label = round(value, 3)), vjust = -0.4) +
    labs(title = sprintf("Delta P_hom decomposition: %s -> %s",
                         format(base_month), format(comp_month)),
         x = NULL, y = "real $ per homogeneous e-cig") +
    theme(legend.position = "none"),
  "p_hom_channels_bar", w = 7, h = 5
)

n_ch_long <- res$n_hom_channels %>%
  select(nic_per_mL_channel, size_channel, interaction, total) %>%
  pivot_longer(everything(), names_to = "component", values_to = "value")
save_plot(
  ggplot(n_ch_long, aes(component, value, fill = component)) +
    geom_col() +
    geom_text(aes(label = round(value, 2)), vjust = -0.4) +
    labs(title = sprintf("Delta N_hom decomposition: %s -> %s",
                         format(base_month), format(comp_month)),
         x = NULL, y = "mg nicotine per homogeneous e-cig") +
    theme(legend.position = "none"),
  "n_hom_channels_bar", w = 7, h = 5
)

save_plot(
  totals_by_measure_level %>%
    pivot_longer(c(within, composition, interaction),
                 names_to = "component", values_to = "value") %>%
    ggplot(aes(component, value, fill = component)) +
    geom_col() +
    facet_grid(measure ~ level, scales = "free_y") +
    labs(title = sprintf("Within / composition / interaction: %s -> %s",
                         format(base_month), format(comp_month)),
         x = NULL, y = NULL) +
    theme(axis.text.x = element_text(angle = 30, hjust = 1),
          legend.position = "none"),
  "summary_totals_grid", w = 10, h = 12
)

cat("\nDone. Tables and plots written under\n  ", output_dir, "\n")
