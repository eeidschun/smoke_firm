## ============================================================================
## Build the T2 (Closed pod / Disposable / Open refill) monthly panel and run
## the M3 validation.
##
## Mirrors the aggregation in decompose_p_and_n.R exactly (same row filter, same
## brand imputation cascade, same flow quantities) but replaces Nielsen's
## `product_type` with the T2 class from t2_classify.R. Output panel
## `bt_month_t2` has the SAME schema as `bt_month`, so decompose_p_and_n.R can
## consume it unchanged (point its load at bt_month_t2_from_full.RData).
##
##   Outputs (under pr/output/prelim_analysis/t2/):
##     bt_month_t2_from_full.RData   -- the panel (also copied to pr/input/)
##     t2_type_shares_by_year.csv    -- mL share of each T2 class per year
##     t2_validation.csv             -- the M3 validation report per year
## ============================================================================

rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

firm_dir   <- "pr"
raw_input_dir <- file.path("input")
support_input_dir <- file.path(firm_dir, "input")
output_dir <- file.path(firm_dir, "output", "prelim_analysis", "t2")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

source(file.path(firm_dir, "t2_classify.R"))
source(file.path(firm_dir, "upc_overrides.R"))   # YIELD_FACTOR, MANUAL_UPC_OVERRIDES, EXCLUDE_UPCS

pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")

## UPC-level corrections/fills applied to EVERY row (labeled or not): override
## table wins, then the missing-mL imputation map fills remaining gaps.
upc_ov <- MANUAL_UPC_OVERRIDES %>%
  mutate(upc12 = pad12(upc),
         ov_total    = liq_cart_f * num_cartridges,
         ov_carts    = num_cartridges,
         ov_nicyield = ifelse(!is.na(nic_mg_per_ml), ov_total * nic_mg_per_ml * YIELD_FACTOR, NA_real_),
         ov_t2       = t2_type) %>%
  select(upc12, ov_total, ov_carts, ov_nicyield, ov_t2)

impmap_path <- file.path(support_input_dir, "missing_mL_imputation_map.rds")
impmap_raw <- if (file.exists(impmap_path)) readRDS(impmap_path) else list(map = tibble(upc=character(), mL_total_imputed=numeric(), nic_yield_tot_imputed=numeric(), t2_type_override=character()))
impmap <- impmap_raw$map %>%
  mutate(upc12 = pad12(upc)) %>%
  select(upc12, map_mL = mL_total_imputed, map_nicyield = nic_yield_tot_imputed,
         map_t2 = t2_type_override)
exclude12 <- pad12(EXCLUDE_UPCS)
cat(sprintf("overrides: %d UPCs | imputation map: %d UPCs | excluded: %d UPCs\n",
            nrow(upc_ov), nrow(impmap), length(exclude12)))

ec_code <- "7467"
input_files <- list.files(raw_input_dir,
  pattern = paste0("^full_.*", ec_code, ".*\\.RData$"), full.names = TRUE)
stopifnot(length(input_files) > 0)

## Reuse the cached brand maps so `brand` matches the decompose panel exactly.
load(file.path(support_input_dir, "label_maps.RData"))   # label_maps
escape_re <- function(x) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
brand_prefix_regex <- paste0("^(",
  paste(escape_re(label_maps$brand_vocab), collapse = "|"), ")")

## ---- per-file: classify, validate, aggregate -------------------------------
panel_rows <- list()
valid_rows <- list()

aggregate_file <- function(f) {
  load(f)                                            # rms_w_attr
  yr <- str_extract(basename(f), "20\\d\\d")
  x <- rms_w_attr %>%
    filter(prod_type == "ec",
           !is.na(units), units > 0, !is.na(infl_mult), infl_mult > 0) %>%
    mutate(upc12 = pad12(upc)) %>%
    filter(!upc12 %in% exclude12) %>%                         # drop non-e-liquid (heated tobacco etc.)
    left_join(upc_ov, by = "upc12") %>%
    left_join(impmap, by = "upc12") %>%
    mutate(
      ## UPC override corrects labeled values; imputation map fills where still NA
      liq_total_f      = coalesce(ov_total, liq_total_f, map_mL),
      num_cartridges_f = coalesce(ov_carts, num_cartridges_f),
      nic_yield_tot_f  = coalesce(ov_nicyield, nic_yield_tot_f, map_nicyield),
      t2_override      = coalesce(ov_t2, map_t2)
    ) %>%
    ## num_cartridges_f no longer required non-NA (it isn't used in panel totals,
    ## only in classify_t2, which handles NA) so imputation-filled rows can enter.
    filter(!is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f > 0) %>%
    left_join(label_maps$upc_to_brand, by = "upc")
  mL <- x$units * x$liq_total_f; total_mL <- sum(mL)

  ## brand cascade (identical to decompose_p_and_n.R), then apply brand renames
  brand_from_descr <- str_extract(x$product_descr, brand_prefix_regex)
  brand_final <- coalesce(x$brand_descr_f, x$brand_upc, brand_from_descr)
  rn <- setNames(BRAND_RENAME$to, BRAND_RENAME$from)
  brand_final <- ifelse(!is.na(brand_final) & brand_final %in% names(rn),
                        unname(rn[brand_final]), brand_final)

  ## T2 type: UPC/line override wins, else the classifier
  cl      <- classify_t2(x, use_brand = TRUE)
  cl_nobr <- classify_t2(x, use_brand = FALSE)
  x$type  <- coalesce(x$t2_override, cl$type)
  x$mL    <- mL

  ## ---- validation rows for this year ----
  raw <- x$product_type
  wsum <- function(m) sum(mL[m], na.rm = TRUE)
  valid_rows[[f]] <<- tibble(
    year = yr,
    total_mL = total_mL,
    ## (1) confidence: share of mL assigned by each rule tier
    tier_carts2      = wsum(cl$tier == "carts>=2") / total_mL,
    tier_pod_kw      = wsum(cl$tier == "pod_keyword") / total_mL,
    tier_pod_brand   = wsum(cl$tier == "pod_brand") / total_mL,
    tier_disp_kwbr   = wsum(cl$tier == "disp_kw/brand") / total_mL,
    tier_single_unit = wsum(cl$tier == "single_unit(carts==1)") / total_mL,
    tier_open        = wsum(cl$tier %in% c("open_kw/brand","open_fingerprint")) / total_mL,
    tier_fallback    = wsum(cl$tier %in% c("fallback_size>=4","fallback_default")) / total_mL,
    ## (2) Nielsen consistency where a raw label exists
    raw_disp_mL      = wsum(!is.na(raw) & raw == "Disposable"),
    disp_recall      = wsum(!is.na(raw) & raw == "Disposable" & x$type == "Disposable") /
                       pmax(wsum(!is.na(raw) & raw == "Disposable"), 1),
    raw_refill_mL    = wsum(!is.na(raw) & raw == "Refill"),
    refill_noncontra = wsum(!is.na(raw) & raw == "Refill" &
                            x$type %in% c("Closed pod","Open refill")) /
                       pmax(wsum(!is.na(raw) & raw == "Refill"), 1),
    ## descriptive: how Nielsen "Refill" splits under T2 (no ground truth here)
    refill_to_closed = wsum(!is.na(raw) & raw == "Refill" & x$type == "Closed pod") /
                       pmax(wsum(!is.na(raw) & raw == "Refill"), 1),
    refill_to_open   = wsum(!is.na(raw) & raw == "Refill" & x$type == "Open refill") /
                       pmax(wsum(!is.na(raw) & raw == "Refill"), 1),
    ## (3) held-out: agreement of structure+keyword-only vs full classifier
    heldout_agree    = wsum(cl$type == cl_nobr$type) / total_mL
  )

  ## ---- aggregate to the panel (same flow schema as bt_month) ----
  panel_rows[[f]] <<- x %>%
    mutate(brand = coalesce(brand_final, "UNKNOWN")) %>%
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
  cat(sprintf("  %s done (total mL %.0f)\n", yr, total_mL))
  rm(rms_w_attr, x); gc(verbose = FALSE)
}

cat("Aggregating", length(input_files), "file(s) under T2 classification\n")
invisible(lapply(input_files, aggregate_file))

bt_month_t2 <- bind_rows(panel_rows) %>%
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
  group_by(month) %>% mutate(mL_share = mL_sum / sum(mL_sum)) %>% ungroup()

save(bt_month_t2, file = file.path(output_dir, "bt_month_t2_from_full.RData"))
save(bt_month_t2, file = file.path(input_dir,  "bt_month_t2_from_full.RData"))

## ---- type shares by year ----
type_shares <- bt_month_t2 %>%
  mutate(year = substr(year_month, 1, 4)) %>%
  group_by(year, type) %>% summarise(mL = sum(mL_sum), .groups = "drop") %>%
  group_by(year) %>% mutate(share = mL / sum(mL)) %>% ungroup() %>%
  select(year, type, share) %>%
  pivot_wider(names_from = type, values_from = share, values_fill = 0)
write.csv(type_shares, file.path(output_dir, "t2_type_shares_by_year.csv"), row.names = FALSE)

## ---- validation report ----
valid <- bind_rows(valid_rows) %>% arrange(year)
write.csv(valid, file.path(output_dir, "t2_validation.csv"), row.names = FALSE)

pct <- function(v) sprintf("%.1f", 100 * v)
cat("\n================= T2 TYPE SHARES BY YEAR (mL) =================\n")
type_shares %>% mutate(across(where(is.numeric), ~round(100 * .x, 1))) %>%
  as.data.frame() %>% print()

cat("\n================= M3 VALIDATION =================\n")
cat("\n(1) CONFIDENCE - share of mL assigned by each rule tier:\n")
valid %>% transmute(year,
  `carts>=2`=pct(tier_carts2), pod_kw=pct(tier_pod_kw), pod_brand=pct(tier_pod_brand),
  disp_kwbr=pct(tier_disp_kwbr), single=pct(tier_single_unit),
  open=pct(tier_open), fallback=pct(tier_fallback)) %>% as.data.frame() %>% print()

cat("\n(2) NIELSEN CONSISTENCY where a raw label exists (mL-weighted %):\n")
cat("    disp_recall      = P(T2=Disposable | Nielsen=Disposable)   [want high]\n")
cat("    refill_noncontra = P(T2 in {pod,open} | Nielsen=Refill)     [want high]\n")
valid %>% transmute(year,
  raw_disp_mL=round(raw_disp_mL), disp_recall=pct(disp_recall),
  raw_refill_mL=round(raw_refill_mL), refill_noncontra=pct(refill_noncontra),
  refill_to_closed=pct(refill_to_closed), refill_to_open=pct(refill_to_open)) %>%
  as.data.frame() %>% print()

cat("\n(3) HELD-OUT: agreement of structure+keyword-only vs full classifier\n")
cat("    (low agreement = heavy dependence on the hand-curated brand lists)\n")
valid %>% transmute(year, heldout_agree = pct(heldout_agree)) %>% as.data.frame() %>% print()

cat("\nDone. Panel + reports written under\n  ", output_dir, "\n")
