## ARCHIVED / SUPERSEDED by analysis/1_decompose_t2.R (and, for the pre-niccorr
## T2 version, archive/3_decompose_p_and_n_t2.R). This is the original,
## product_type-based decomposition that also builds label_maps.RData. Kept for
## reference; not part of the current pipeline.
##
## Decompose changes in the "homogeneous e-cigarette" price and nicotine yield.
##
## The homogeneous e-cig is:
##   P_hom = (avg price per mL) * (avg mL per e-cig)
##   N_hom = (avg nic mg per mL) * (avg mL per e-cig)
## with both averages taken as mL-weighted means across products.
##
## We want to know how much of the change from period 0 to period 1 came from:
##   (a) a change in price/mL vs. a change in average size (mL per e-cig)
##       -> "channel" decomposition of P_hom
##   (b) shifts in the mL-share of individual (brand, type) cells
##       -> within / composition / interaction decomposition
##   (c) same as (b) collapsed to brand only or type only
##
## Input files are the UPC-store-week panels written by clean_RMS_from_raw_to_most_detailed.R,
## which already carry `infl_mult` for deflation to the peg year (2023 in the current cpi_data).
## `price_d_prmult` is nominal; real price = price_d_prmult / infl_mult.

rm(list = ls())

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
})

## ---------- config ----------
source("smoke_firm_dir/code/fxns/1_paths.R")
input_dir  <- SUPPORT_DIR
raw_dir    <- RAW_DIR
output_dir <- file.path(PRELIM_DIR, "p_and_n_decomp")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

ec_code <- "7467"

## Set TRUE to rebuild the UPC/form label maps from scratch. Set FALSE to reuse
## the cached maps at `pr/input/label_maps.RData`. When any input file is
## added/replaced you must set this to TRUE for one run.
rebuild_label_maps <- FALSE

form_type_majority  <- 0.70  # min mL-share needed to accept form_descr -> type
brand_type_majority <- 0.95  # stricter threshold for brand -> type (brand is broad)

input_files <- list.files(
  raw_dir,
  pattern = paste0("^full_.*", ec_code, ".*\\.RData$"),
  full.names = TRUE
)
stopifnot(length(input_files) > 0)

## ---------- 1a. Build label-imputation maps (pass 1) ----------
## Nielsen leaves brand and product_type NA on many rows, especially in
## 2022-2023 (~33-41% of mL had NA product_type in earlier tests). To keep
## those rows in the aggregate AND still get useful (brand, type) labels for
## the decomposition, we build three lookup tables from the labeled rows and
## apply them as a cascade during aggregation:
##
##   (1) upc_to_brand : mL-weighted mode brand per UPC (across all labeled rows)
##   (2) upc_to_type  : mL-weighted mode product_type per UPC
##   (3) form_to_type : mL-weighted mode product_type per form_descr, kept only
##                      when the mode has >= form_type_majority share
##
##   (4) brand_to_type: mL-weighted mode product_type per brand, kept only when
##                      the mode has >= brand_type_majority share (95% by default).
##                      Diagnostic showed VUSE (99% Refill in labeled data) is
##                      ~76% of the residual UNKNOWN mL in 2022-2023, so this
##                      one map closes most of the remaining gap.
##
## We also keep the set of observed brand strings so we can prefix-match
## `product_descr` for UPCs that have no labeled row anywhere. Longest brand
## wins (so "21ST CENTURY SMOKE" beats "21ST", etc.).

map_cache_path <- file.path(input_dir, "label_maps.RData")

build_label_maps <- function(files) {
  ## Accumulate mL by (upc, brand), (upc, product_type), (form_descr, product_type)
  ## from labeled rows only, one file at a time.
  brand_upc_tally  <- tibble()
  type_upc_tally   <- tibble()
  form_type_tally  <- tibble()
  brand_type_tally <- tibble()
  brand_vocab      <- character(0)

  for (f in files) {
    cat("  scan for labels:", basename(f), "\n")
    load(f)
    x <- rms_w_attr %>%
      filter(prod_type == "ec",
             !is.na(liq_total_f), liq_total_f > 0,
             !is.na(units), units > 0) %>%
      mutate(mL = units * liq_total_f)

    brand_upc_tally <- x %>%
      filter(!is.na(brand_descr_f)) %>%
      group_by(upc, brand_descr_f) %>%
      summarise(mL = sum(mL), .groups = "drop") %>%
      bind_rows(brand_upc_tally) %>%
      group_by(upc, brand_descr_f) %>%
      summarise(mL = sum(mL), .groups = "drop")

    type_upc_tally <- x %>%
      filter(!is.na(product_type)) %>%
      group_by(upc, product_type) %>%
      summarise(mL = sum(mL), .groups = "drop") %>%
      bind_rows(type_upc_tally) %>%
      group_by(upc, product_type) %>%
      summarise(mL = sum(mL), .groups = "drop")

    form_type_tally <- x %>%
      filter(!is.na(product_type), !is.na(form_descr)) %>%
      group_by(form_descr, product_type) %>%
      summarise(mL = sum(mL), .groups = "drop") %>%
      bind_rows(form_type_tally) %>%
      group_by(form_descr, product_type) %>%
      summarise(mL = sum(mL), .groups = "drop")

    brand_type_tally <- x %>%
      filter(!is.na(product_type), !is.na(brand_descr_f)) %>%
      group_by(brand_descr_f, product_type) %>%
      summarise(mL = sum(mL), .groups = "drop") %>%
      bind_rows(brand_type_tally) %>%
      group_by(brand_descr_f, product_type) %>%
      summarise(mL = sum(mL), .groups = "drop")

    brand_vocab <- union(brand_vocab,
                         unique(x$brand_descr_f[!is.na(x$brand_descr_f)]))
    rm(x, rms_w_attr); gc(verbose = FALSE)
  }

  ## Reduce to modes
  upc_to_brand <- brand_upc_tally %>%
    group_by(upc) %>%
    slice_max(mL, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    select(upc, brand_upc = brand_descr_f)

  upc_to_type <- type_upc_tally %>%
    group_by(upc) %>%
    slice_max(mL, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    select(upc, type_upc = product_type)

  form_to_type <- form_type_tally %>%
    group_by(form_descr) %>%
    mutate(share = mL / sum(mL)) %>%
    slice_max(mL, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    filter(share >= form_type_majority) %>%
    select(form_descr, type_form = product_type, form_type_share = share)

  brand_to_type <- brand_type_tally %>%
    group_by(brand_descr_f) %>%
    mutate(share = mL / sum(mL)) %>%
    slice_max(mL, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    filter(share >= brand_type_majority) %>%
    select(brand = brand_descr_f, type_brand = product_type,
           brand_type_share = share)

  ## Sort brand vocabulary longest-first (so prefix regex is greedy on longest)
  brand_vocab <- brand_vocab[order(nchar(brand_vocab), decreasing = TRUE)]

  list(upc_to_brand  = upc_to_brand,
       upc_to_type   = upc_to_type,
       form_to_type  = form_to_type,
       brand_to_type = brand_to_type,
       brand_vocab   = brand_vocab)
}

if (rebuild_label_maps || !file.exists(map_cache_path)) {
  cat("Building label-imputation maps from", length(input_files), "file(s)\n")
  label_maps <- build_label_maps(input_files)
  save(label_maps, file = map_cache_path)
} else {
  cat("Loading cached label maps from", map_cache_path, "\n")
  load(map_cache_path)
}

cat(sprintf("  UPC->brand   entries: %d\n", nrow(label_maps$upc_to_brand)))
cat(sprintf("  UPC->type    entries: %d\n", nrow(label_maps$upc_to_type)))
cat(sprintf("  form->type   accepted (>=%d%%): %d\n",
            round(100 * form_type_majority), nrow(label_maps$form_to_type)))
cat(sprintf("  brand->type  accepted (>=%d%%): %d\n",
            round(100 * brand_type_majority), nrow(label_maps$brand_to_type)))
cat(sprintf("  brand vocabulary size: %d\n", length(label_maps$brand_vocab)))

## Prefix regex for `product_descr` -> brand matching. Escape brand strings
## (some contain characters like "&" or ".") and anchor at start; longest brand
## wins because we sorted longest-first in build_label_maps.
escape_re <- function(x) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
brand_prefix_regex <- paste0("^(",
                             paste(escape_re(label_maps$brand_vocab), collapse = "|"),
                             ")")

## ---------- 1b. Load & pre-aggregate each input file (pass 2) ----------
## Each raw file is very large (millions of UPC-store-week rows); we roll each
## file up to (year_month x brand x type) with additive "flow" quantities so
## the combined panel stays small and every downstream weighted average is
## just a ratio of two sums.
##
## The reference filter (RMS_clean_to_get_my_original_figures.R) keeps rows
## with nic_yield_tot_f, num_cartridges_f, and liq_total_f non-NA. We match
## that, then apply the imputation cascade:
##   brand = raw brand -> upc_to_brand -> prefix-match product_descr -> UNKNOWN
##   type  = raw type  -> upc_to_type  -> form_to_type[form_descr]
##                                     -> brand_to_type[brand_final] -> UNKNOWN
## Coverage stats are logged per file.

aggregate_file <- function(f) {
  load(f)  # loads rms_w_attr
  x <- rms_w_attr %>%
    filter(prod_type == "ec",
           !is.na(nic_yield_tot_f),
           !is.na(num_cartridges_f),
           !is.na(liq_total_f), liq_total_f > 0,
           !is.na(units),       units > 0,
           !is.na(infl_mult),   infl_mult > 0) %>%
    left_join(label_maps$upc_to_brand, by = "upc") %>%
    left_join(label_maps$upc_to_type,  by = "upc") %>%
    left_join(label_maps$form_to_type, by = "form_descr")

  brand_from_descr <- str_extract(x$product_descr, brand_prefix_regex)

  ## Cascade for brand first (its output feeds the brand->type join below)
  mL <- x$units * x$liq_total_f
  total_mL <- sum(mL)

  brand_final <- coalesce(x$brand_descr_f, x$brand_upc, brand_from_descr)

  ## Now brand->type as the LAST type fallback (below upc_to_type and form_to_type)
  b2t <- label_maps$brand_to_type
  type_brand <- b2t$type_brand[match(brand_final, b2t$brand)]

  type_final  <- coalesce(x$product_type, x$type_upc, x$type_form, type_brand)

  cov <- function(v_before, v_after) {
    c(before = sum(mL * !is.na(v_before)) / total_mL,
      after  = sum(mL * !is.na(v_after))  / total_mL)
  }
  bcov <- cov(x$brand_descr_f, brand_final)
  tcov <- cov(x$product_type,  type_final)
  cat(sprintf("  %-38s  brand mL cov %.3f -> %.3f   type mL cov %.3f -> %.3f\n",
              basename(f), bcov["before"], bcov["after"],
              tcov["before"], tcov["after"]))

  x %>%
    mutate(brand = coalesce(brand_final, "UNKNOWN"),
           type  = coalesce(type_final,  "UNKNOWN")) %>%
    group_by(year_month, brand, type) %>%
    summarise(
      units_sum            = sum(units),
      mL_sum               = sum(units * liq_total_f),
      revenue_nom          = sum(units * price_d_prmult),
      revenue_real         = sum(units * price_d_prmult / infl_mult),
      nic_mg_sum           = sum(units * nic_yield_tot_f),
      mL_sq_times_unit_sum = sum(units * liq_total_f^2),
      .groups = "drop"
    )
}

cat("Aggregating", length(input_files), "input file(s)\n")

bt_month <- map_dfr(input_files, aggregate_file)

## Collapse duplicates in case any (year_month, brand, type) shows up in more
## than one input file (defensive; safe to run when partitions are clean).
bt_month <- bt_month %>%
  group_by(year_month, brand, type) %>%
  summarise(across(everything(), sum), .groups = "drop") %>%
  mutate(
    month           = as.Date(paste0(year_month, "-01")),
    price_per_mL    = revenue_real / mL_sum,
    nic_mg_per_mL   = nic_mg_sum   / mL_sum,
    avg_mL_per_ecig = mL_sq_times_unit_sum / mL_sum,
    P_hom_cell      = price_per_mL  * avg_mL_per_ecig,
    N_hom_cell      = nic_mg_per_mL * avg_mL_per_ecig
  ) %>%
  group_by(month) %>%
  mutate(mL_share = mL_sum / sum(mL_sum)) %>%
  ungroup()

save(bt_month, file = file.path(input_dir, "bt_month_from_full.RData"))

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
## Aggregates (brand, type) cells up to whatever grouping columns we pass in,
## then rebuilds ratios and within-month shares. Used to switch between
## (brand,type), brand-only, type-only views.

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

## Product decomposition for P_hom = a * b:
##   Delta(a*b) = Delta a * b0 + a0 * Delta b + Delta a * Delta b
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

## Share-weighted average decomposition for X_nat = sum_i s_i * x_i:
##   Delta X_nat = sum_i s0_i (x1_i - x0_i)     [within]
##               + sum_i (s1_i - s0_i) x0_i     [composition]
##               + sum_i (s1_i - s0_i)(x1_i - x0_i)  [interaction]
##
## df must expose {key_cols}, month, mL_share, and the column named in x_col.

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

  ## nested list: decomp[[measure]][[level]] -> tibble of cell contributions
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

## Pick base/comp months from what we actually have. The subset only has
## 2016 and 2021, so default to Jan-2016 -> Dec-2021 (or the latest month).
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

## Roll a cell-level decomp into a top-drivers table (largest |total| first)
top_drivers <- function(df, n = 30) {
  df %>% arrange(desc(abs(total))) %>% head(n)
}

## Channel decompositions
save_csv(res$p_hom_channels, "p_hom_channels")
save_csv(res$n_hom_channels, "n_hom_channels")

## Full and top-drivers tables at each grouping x measure
for (m in names(res$decomp)) {
  for (lvl in names(res$decomp[[m]])) {
    save_csv(res$decomp[[m]][[lvl]],
             paste0("decomp_", m, "_by_", lvl))
    save_csv(top_drivers(res$decomp[[m]][[lvl]], 30),
             paste0("top_drivers_", m, "_by_", lvl))
  }
}

## Console summary
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

## Aggregate contributions (sum of within/composition/interaction across cells,
## for each measure, at each grouping level)
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
  ggsave(file.path(output_dir, paste0(name, ".png")), gg,
         width = w, height = h)
}

## National monthly series (facet)
plot_natl <- national_month %>%
  select(month, price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom) %>%
  pivot_longer(-month, names_to = "series", values_to = "value") %>%
  mutate(series = factor(series,
                         levels = c("price_per_mL", "avg_mL_per_ecig", "P_hom",
                                    "nic_mg_per_mL", "N_hom"))) %>%
  ggplot(aes(month, value, color = series)) +
  geom_line(linewidth = 1) +
  facet_wrap(~series, scales = "free_y") +
  labs(title = "National monthly e-cigarette series (real $, mg, mL)",
       x = NULL, y = NULL) +
  theme(legend.position = "none")
save_plot(plot_natl, "national_monthly_series", w = 10, h = 6)

## Type share over time
type_panel <- build_panel(bt_month, "type")
save_plot(
  ggplot(type_panel, aes(month, mL_share, color = type)) +
    geom_line(linewidth = 1) +
    labs(title = "mL share by product type", y = "mL share", x = NULL),
  "type_shares"
)

## Type price_per_mL and mL/ecig over time
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

## Top 8 brands by total mL over the panel
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

## Channel bar charts (endpoint-to-endpoint)
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

## Waterfall-ish: sum of within/composition/interaction across each measure x level
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
