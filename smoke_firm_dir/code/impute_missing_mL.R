## ============================================================================
## Impute mL (liq_total_f) and nicotine yield (nic_yield_tot_f) for e-cigarette
## UPCs that have real sales but a MISSING liq_total_f, so they can re-enter the
## T2 panel and P_hom / N_hom instead of being silently dropped by the entry
## filter in decompose_p_and_n.R / build_t2_panel.R.
##
## Why this matters: the entry filter requires liq_total_f (mL/unit) non-NA, and
## that drops 4-20% of e-cig SALES UNITS per year (worst 2018-2020). num_cartridges
## / nic_yield / infl are ~always present; only mL is missing.
##
## METHOD
##   1. MANUAL_OVERRIDES (below): user-verified specs for specific product lines,
##      matched on product_descr/line text. Highest priority. Values are entered
##      as REAL-WORLD specs (mL per cartridge; raw concentration in mg/mL, e.g.
##      5% = 50). This is where new manual findings get added -- one row each.
##   2. Sibling imputation: for everything else, borrow from LABELED UPCs
##      (liq_total_f > 0) via a precision cascade:
##        UPC prefix11 > prefix10 > product-LINE + carts > prefix8 + carts >
##        line/prefix per-cartridge > brand (+carts). `line` is parsed from
##        product_descr, which is essential for brands (e.g. STAGBAR) whose
##        brand_descr_f is blank and that use orphan company prefixes.
##
## NICOTINE CONVENTION (important): the panel's N_hom uses nic_yield_tot_f, which
## in this data equals  YIELD_FACTOR * (nic_mg_per_ml * liq_total).  YIELD_FACTOR
## = 0.68 is an intentional, hard-coded nicotine-amount -> yield conversion for
## e-cigarettes taken from an external research paper. So:
##   * sibling-imputed nic_yield_tot_f is already in yield units (borrow as-is);
##   * a MANUAL raw concentration is converted:  nic_yield = carts * mL_cart *
##     nic_mg_per_ml * YIELD_FACTOR.
## The per-UPC `own` nic_yield on dropped rows is a contaminated placeholder
## (a 102 spike) and is used only as a last resort.
##
## OUTPUTS
##   pr/output/prelim_analysis/t2/upcs_missing_mL_imputed.csv  (review artifact)
##   pr/input/missing_mL_imputation_map.rds  (upc -> imputed mL/nic/type + factor)
##
## Reference/missing tables are cached at pr/input/t2_impute_cache.rds (built by
## a full pass over the raw files). Set rebuild_cache <- TRUE after inputs change.
## ============================================================================

suppressPackageStartupMessages({ library(tidyverse) })

## ---------------- config ----------------
## Overrides (YIELD_FACTOR, MANUAL_OVERRIDES, MANUAL_UPC_OVERRIDES, EXCLUDE_UPCS)
## live in the shared module so this script and build_t2_panel.R stay in sync.
source(file.path("pr", "upc_overrides.R"))

firm_dir     <- "pr"
raw_input_dir <- file.path("input")
input_dir    <- file.path(firm_dir, "input")
output_dir   <- file.path(firm_dir, "output", "prelim_analysis", "t2")
cache_path   <- file.path(input_dir, "t2_impute_cache.rds")
prev_csv     <- file.path(output_dir, "upcs_missing_mL_imputed.csv")
rebuild_cache <- FALSE

pad12   <- function(u) str_pad(as.character(u), 12, "left", "0")
cut_re  <- "(?i)\\s+(SMOKING ALT|SMOKING ALTRN|SMKNG|ANTISMOKING|ANTI-SMOKING|ELCT|ELECTRONIC|DIGITAL VAPOR|DGTL|E-CGRT|E CGRT).*$"
getline <- function(d) str_trim(str_replace(coalesce(d, ""), cut_re, ""))
modal_num <- function(v){ v <- v[!is.na(v)]; if(!length(v)) return(NA_real_)
                          as.numeric(names(sort(table(v), decreasing = TRUE))[1]) }

## ---------------- 1. reference + missing tables (cached full pass) ----------------
build_cache <- function() {
  files <- list.files(raw_input_dir, pattern = "^full_.*7467.*\\.RData$", full.names = TRUE)
  reftal <- tibble(); misstal <- tibble()
  for (f in files) {
    load(f)
    ec <- rms_w_attr %>% filter(prod_type == "ec", !is.na(units), units > 0) %>%
      mutate(upc = pad12(upc), line = getline(product_descr))
    reftal <- ec %>% filter(!is.na(liq_total_f), liq_total_f > 0) %>%
      group_by(upc, brand_descr_f, line, num_cartridges_f, liq_cart_f, liq_total_f,
               nic_mg_per_ml_f, nic_yield_tot_f) %>% summarise(u = sum(units), .groups = "drop") %>%
      bind_rows(reftal)
    misstal <- ec %>% filter(is.na(liq_total_f) | liq_total_f <= 0) %>%
      group_by(upc, brand_descr_f, line, num_cartridges_f, product_descr,
               nic_yield_tot_f) %>% summarise(u = sum(units), .groups = "drop") %>%
      bind_rows(misstal)
    rm(rms_w_attr, ec); gc(verbose = FALSE)
  }
  ref <- reftal %>% group_by(upc) %>% slice_max(u, n = 1, with_ties = FALSE) %>% ungroup() %>%
    mutate(pfx8 = substr(upc,1,8), pfx10 = substr(upc,1,10), pfx11 = substr(upc,1,11),
           brand = brand_descr_f, carts = num_cartridges_f)
  modal <- function(df, key) df %>% filter(!is.na(brand_descr_f)) %>%
    count(!!sym(key), brand_descr_f, wt = u) %>% group_by(!!sym(key)) %>%
    slice_max(n, n = 1, with_ties = FALSE) %>% ungroup() %>% transmute(!!sym(key) := !!sym(key), brand = brand_descr_f)
  list(ref = ref,
       pfx_brand  = modal(reftal %>% mutate(pfx8 = substr(upc,1,8)), "pfx8") %>% rename(pfx_brand = brand),
       line_brand = modal(reftal, "line") %>% rename(line_brand = brand),
       misstal    = misstal)
}

if (rebuild_cache || !file.exists(cache_path)) {
  cat("Building reference cache from raw files (full pass)...\n")
  cache <- build_cache(); saveRDS(cache, cache_path)
} else {
  cat("Loading reference cache from", cache_path, "\n")
  cache <- readRDS(cache_path)
}
ref <- cache$ref; pfx_brand <- cache$pfx_brand; line_brand <- cache$line_brand; misstal <- cache$misstal

## ---------------- 2. one dominant row per missing UPC ----------------
miss <- misstal %>% group_by(upc) %>%
  summarise(brand_raw    = first(na.omit(brand_descr_f)),
            line         = first(na.omit(line)),
            carts        = modal_num(num_cartridges_f),
            own_nicyield = suppressWarnings(median(nic_yield_tot_f, na.rm = TRUE)),
            units        = sum(u), .groups = "drop") %>%
  mutate(pfx8 = substr(upc,1,8), pfx10 = substr(upc,1,10), pfx11 = substr(upc,1,11),
         line = na_if(line, "")) %>%
  left_join(pfx_brand, by = "pfx8") %>% left_join(line_brand, by = "line") %>%
  mutate(first_word   = str_extract(line, "^[A-Z0-9&'-]+"),
         brand_filled = coalesce(na_if(brand_raw, ""), line_brand, pfx_brand, first_word),
         brand_source = case_when(!is.na(na_if(brand_raw,"")) ~ "raw", !is.na(line_brand) ~ "line",
                                  !is.na(pfx_brand) ~ "prefix", !is.na(first_word) ~ "line_firstword",
                                  TRUE ~ "unknown"))

## ---------------- 3. apply manual overrides ----------------
match_text <- toupper(paste(coalesce(miss$line,""), coalesce(miss$brand_raw,"")))
ov_idx <- rep(NA_integer_, nrow(miss))
for (i in seq_len(nrow(MANUAL_OVERRIDES))) {
  hit <- is.na(ov_idx) & str_detect(match_text, fixed(toupper(MANUAL_OVERRIDES$pattern[i])))
  ov_idx[hit] <- i
}
miss <- miss %>% mutate(
  ov = ov_idx,
  ov_carts = ifelse(!is.na(ov) & is.na(carts), 1, carts),                 # disposables default 1 cart
  man_liq_cart = ifelse(!is.na(ov), MANUAL_OVERRIDES$liq_cart_f[ov], NA_real_),
  man_nic_mgml = ifelse(!is.na(ov), MANUAL_OVERRIDES$nic_mg_per_ml[ov], NA_real_),
  man_brand    = ifelse(!is.na(ov), MANUAL_OVERRIDES$brand[ov], NA_character_),
  man_t2       = ifelse(!is.na(ov), MANUAL_OVERRIDES$t2_type[ov], NA_character_),
  brand_filled = coalesce(man_brand, brand_filled),
  brand_source = ifelse(!is.na(ov), "manual", brand_source))

## UPC-specific overrides (take precedence over line-pattern overrides)
miss <- miss %>%
  left_join(MANUAL_UPC_OVERRIDES %>% mutate(upc = pad12(upc)) %>%
              rename(ovu_liq_cart = liq_cart_f, ovu_carts = num_cartridges,
                     ovu_nic = nic_mg_per_ml, ovu_brand = brand, ovu_t2 = t2_type),
            by = "upc") %>%
  mutate(has_upc_ov  = !is.na(ovu_liq_cart),
         brand_filled = coalesce(ovu_brand, brand_filled),
         brand_source = ifelse(has_upc_ov, "manual_upc", brand_source))

## ---------------- 3b. ingest ChatGPT web-verified values (source-backed only) ----------------
## Reads the ChatGPT verification output (if present) and treats source-backed
## verified mL / nicotine / device-type as an override layer that sits BELOW the
## hand-entered MANUAL_* tables but ABOVE sibling imputation. Only rows assessed
## CONFIRMS / PARTIAL / CONTRADICTS with a non-empty source_url are used, and only
## the non-blank fields are taken (a PARTIAL row contributes whatever it verified).
verified_file <- file.path(output_dir, "verified_values_upc_neighbor_pass.csv")
if (file.exists(verified_file)) {
  gv <- read.csv(verified_file, colClasses = "character") %>%
    mutate(upc = pad12(upc),
           has_src = !is.na(source_url) & str_trim(source_url) != "") %>%
    filter(assessment %in% c("CONFIRMS","PARTIAL","CONTRADICTS"), has_src) %>%
    transmute(upc,
      gv_total  = suppressWarnings(as.numeric(verified_total_mL)),
      gv_mLcart = suppressWarnings(as.numeric(verified_mL_per_cartridge)),
      gv_carts  = suppressWarnings(as.numeric(verified_num_cartridges)),
      gv_nic_mgml = coalesce(suppressWarnings(as.numeric(verified_nic_mg_per_ml)),
                             suppressWarnings(as.numeric(verified_nic_pct)) * 10),
      gv_t2 = case_when(grepl("disposab", tolower(verified_device_type)) ~ "Disposable",
                        grepl("closed|pod|cartridge|cig-a", tolower(verified_device_type)) ~ "Closed pod",
                        grepl("open|tank|bottle|refill", tolower(verified_device_type)) ~ "Open refill",
                        TRUE ~ NA_character_),
      gv_conf = confidence) %>%
    group_by(upc) %>% slice(1) %>% ungroup()
  cat(sprintf("Ingesting %d source-backed verified rows from %s\n",
              nrow(gv), basename(verified_file)))
  miss <- miss %>% left_join(gv, by = "upc")
} else {
  miss <- miss %>% mutate(gv_total = NA_real_, gv_mLcart = NA_real_, gv_carts = NA_real_,
                          gv_nic_mgml = NA_real_, gv_t2 = NA_character_, gv_conf = NA_character_)
}

## ---------------- 4. sibling-imputation cascade (for non-override rows) ----------------
gs <- function(keys) ref %>% group_by(across(all_of(keys))) %>%
  summarise(mL = median(liq_total_f), mLlo = min(liq_total_f), mLhi = max(liq_total_f),
            mlc = median(liq_cart_f, na.rm = TRUE), ny = median(nic_yield_tot_f, na.rm = TRUE),
            n = n(), .groups = "drop")
G11 <- gs("pfx11"); G10 <- gs("pfx10"); GLc <- gs(c("line","carts")); G8c <- gs(c("pfx8","carts"))
GL  <- gs("line");  G8  <- gs("pfx8");  GBc <- gs(c("brand","carts")) %>% rename(brand_filled = brand)
GB  <- gs("brand") %>% rename(brand_filled = brand)
J <- function(d, G, keys, s) left_join(d, G %>% rename_with(~paste0(.x, s), -all_of(keys)), by = keys)

m <- miss %>% J(G11,"pfx11",".11") %>% J(G10,"pfx10",".10") %>% J(GLc,c("line","carts"),".Lc") %>%
  J(G8c,c("pfx8","carts"),".8c") %>% J(GL,"line",".L") %>% J(G8,"pfx8",".8") %>%
  J(GBc,c("brand_filled","carts"),".Bc") %>% J(GB,"brand_filled",".B") %>%
  mutate(gv_mL       = coalesce(gv_total, gv_mLcart * gv_carts, gv_mLcart * carts),
         gv_has_mL   = !is.na(gv_mL),
         gv_has_nic  = !is.na(gv_nic_mgml),
         is_excluded = upc %in% pad12(EXCLUDE_UPCS),
         is_hw = !is_excluded & !has_upc_ov & is.na(ov) & !gv_has_mL &
           ((!is.na(carts) & carts == 0) |
            grepl("DEVICE|BATTERY|CHARGER|\\bKIT\\b", toupper(coalesce(line, "")))))

m <- m %>% mutate(
  mL_rule = case_when(
    is_excluded ~ "excluded",
    has_upc_ov ~ "manual_upc",
    !is.na(ov) ~ "manual",
    gv_has_mL ~ "gpt_verified",
    is_hw ~ "hardware_exclude",
    !is.na(mL.11) ~ "prefix11", !is.na(mL.10) ~ "prefix10", !is.na(mL.Lc) ~ "line+carts",
    !is.na(mL.8c) ~ "prefix8+carts", !is.na(mlc.L) & !is.na(carts) ~ "line_percart",
    !is.na(mlc.8) & !is.na(carts) ~ "prefix8_percart", !is.na(mL.Bc) ~ "brand+carts",
    !is.na(mlc.B) & !is.na(carts) ~ "brand_percart", TRUE ~ "none"),
  mL_total_imputed = case_when(
    mL_rule == "excluded" ~ NA_real_,
    mL_rule == "manual_upc" ~ ovu_carts * ovu_liq_cart,
    mL_rule == "manual" ~ ov_carts * man_liq_cart,
    mL_rule == "gpt_verified" ~ gv_mL,
    mL_rule == "hardware_exclude" ~ NA_real_,
    mL_rule == "prefix11" ~ mL.11, mL_rule == "prefix10" ~ mL.10, mL_rule == "line+carts" ~ mL.Lc,
    mL_rule == "prefix8+carts" ~ mL.8c, mL_rule == "line_percart" ~ carts * mlc.L,
    mL_rule == "prefix8_percart" ~ carts * mlc.8, mL_rule == "brand+carts" ~ mL.Bc,
    mL_rule == "brand_percart" ~ carts * mlc.B, TRUE ~ NA_real_),
  mL_n_siblings = case_when(mL_rule=="prefix11"~n.11, mL_rule=="prefix10"~n.10, mL_rule=="line+carts"~n.Lc,
    mL_rule=="prefix8+carts"~n.8c, mL_rule=="line_percart"~n.L, mL_rule=="prefix8_percart"~n.8,
    mL_rule=="brand+carts"~n.Bc, mL_rule=="brand_percart"~n.B, TRUE ~ NA_integer_),
  mL_sibling_lo = case_when(mL_rule=="prefix11"~mLlo.11, mL_rule=="prefix10"~mLlo.10, mL_rule=="line+carts"~mLlo.Lc,
    mL_rule=="prefix8+carts"~mLlo.8c, mL_rule=="brand+carts"~mLlo.Bc, TRUE ~ NA_real_),
  mL_sibling_hi = case_when(mL_rule=="prefix11"~mLhi.11, mL_rule=="prefix10"~mLhi.10, mL_rule=="line+carts"~mLhi.Lc,
    mL_rule=="prefix8+carts"~mLhi.8c, mL_rule=="brand+carts"~mLhi.Bc, TRUE ~ NA_real_),
  nic_rule = case_when(
    is_excluded ~ "excluded",
    has_upc_ov & !is.na(ovu_nic) ~ "manual_upc",
    !is.na(ov) & !is.na(man_nic_mgml) ~ "manual",
    gv_has_nic ~ "gpt_verified",
    is_hw ~ "hardware_exclude",
    !is.na(ny.11) ~ "prefix11", !is.na(ny.10) ~ "prefix10", !is.na(ny.Lc) ~ "line+carts",
    !is.na(ny.8c) ~ "prefix8+carts", !is.na(ny.L) ~ "line", !is.na(ny.8) ~ "prefix8",
    !is.na(ny.Bc) ~ "brand+carts", !is.na(ny.B) ~ "brand",
    !is.na(own_nicyield) ~ "own(low-conf)", TRUE ~ "none"),
  nic_yield_tot_imputed = case_when(
    nic_rule == "excluded" ~ NA_real_,
    nic_rule == "manual_upc" ~ ovu_carts * ovu_liq_cart * ovu_nic * YIELD_FACTOR,
    nic_rule == "manual" ~ ov_carts * man_liq_cart * man_nic_mgml * YIELD_FACTOR,
    nic_rule == "gpt_verified" ~ mL_total_imputed * gv_nic_mgml * YIELD_FACTOR,
    nic_rule == "hardware_exclude" ~ NA_real_,
    nic_rule == "prefix11" ~ ny.11, nic_rule == "prefix10" ~ ny.10, nic_rule == "line+carts" ~ ny.Lc,
    nic_rule == "prefix8+carts" ~ ny.8c, nic_rule == "line" ~ ny.L, nic_rule == "prefix8" ~ ny.8,
    nic_rule == "brand+carts" ~ ny.Bc, nic_rule == "brand" ~ ny.B,
    nic_rule == "own(low-conf)" ~ own_nicyield, TRUE ~ NA_real_),
  t2_type_override = coalesce(ovu_t2, man_t2, gv_t2),
  implied_raw_mg_per_mL = round(nic_yield_tot_imputed / YIELD_FACTOR / mL_total_imputed, 1),
  review_flag = case_when(
    mL_rule == "excluded" ~ "excluded",
    mL_rule %in% c("manual","manual_upc") ~ "ok:manual",
    mL_rule == "gpt_verified" ~ paste0("ok:gpt-", tolower(coalesce(gv_conf, "?"))),
    !(mL_rule %in% c("prefix11","prefix10","line+carts","prefix8+carts","line_percart",
                     "prefix8_percart","brand+carts","brand_percart")) ~ "",
    !is.na(mL_sibling_lo) & !is.na(mL_sibling_hi) & mL_sibling_hi/pmax(mL_sibling_lo,.01) >= 2 ~ "CHECK:siblings_disagree",
    !is.na(mL_sibling_lo) & !is.na(mL_sibling_hi) & mL_sibling_lo != mL_sibling_hi ~ "minor:some_spread",
    mL_rule %in% c("line_percart","prefix8_percart","brand+carts","brand_percart") ~ "weak:coarse_match",
    !is.na(mL_n_siblings) & mL_n_siblings == 1 ~ "note:single_sibling", TRUE ~ "ok"))

## carry category from the prior CSV if present, else derive
prev <- if (file.exists(prev_csv))
  read.csv(prev_csv, colClasses = "character") %>% mutate(upc = pad12(upc)) %>%
    select(upc, category, product_descr) else tibble(upc = character(), category = character(), product_descr = character())

out <- m %>% left_join(prev, by = "upc") %>%
  mutate(category = ifelse(is_excluded, "non-e-liquid (exclude)",
                    coalesce(category, ifelse(is_hw, "hardware/device (exclude)", "e-liquid (impute mL)")))) %>%
  arrange(desc(units)) %>%
  transmute(category, upc, brand_filled, brand_source, line, product_descr,
            num_cartridges_f = coalesce(ovu_carts, carts), mL_total_imputed, mL_rule, mL_n_siblings,
            mL_sibling_lo, mL_sibling_hi, nic_yield_tot_imputed, nic_rule,
            implied_raw_mg_per_mL, t2_type_override, review_flag, total_units = units) %>%
  mutate(brand_filled = dplyr::recode(brand_filled, !!!setNames(BRAND_RENAME$to, BRAND_RENAME$from)))

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(out, prev_csv, row.names = FALSE)
saveRDS(list(map = m %>% select(upc, mL_total_imputed, mL_rule, nic_yield_tot_imputed,
                                nic_rule, t2_type_override),
             yield_factor = YIELD_FACTOR),
        file.path(input_dir, "missing_mL_imputation_map.rds"))

## ---------------- report ----------------
tot <- sum(out$total_units)
verified_rules <- c("manual","manual_upc","gpt_verified")
imp <- !(out$mL_rule %in% c("hardware_exclude","none"))
cat(sprintf("\nmL imputed: %.1f%% of dropped units (%d UPCs)\n",
            100*sum(out$total_units[imp])/tot, sum(imp)))

cat("\n=== source of each mL value (share of dropped units) ===\n")
out %>% mutate(bucket = case_when(mL_rule %in% verified_rules ~ "VERIFIED (manual/gpt)",
                                  mL_rule == "excluded" ~ "non-e-liquid (exclude)",
                                  mL_rule == "hardware_exclude" ~ "hardware (no mL)",
                                  mL_rule == "none" ~ "unresolved (no mL)",
                                  TRUE ~ "sibling-imputed (unverified)")) %>%
  group_by(bucket) %>% summarise(upcs = n(), units = round(sum(total_units)), .groups="drop") %>%
  mutate(unit_pct = round(100*units/tot,1)) %>% arrange(desc(units)) %>% as.data.frame() %>% print()

## ---- what still needs a manual check: unverified sibling imputations + unresolved,
## ranked by sales volume, with a priority on the least-trustworthy flags ----
todo <- out %>%
  filter(!category %in% c("hardware/device (exclude)", "non-e-liquid (exclude)"),
         !(mL_rule %in% verified_rules)) %>%
  mutate(check_priority = case_when(
           mL_rule == "none" ~ "1-no-value",
           review_flag == "CHECK:siblings_disagree" ~ "2-siblings-disagree",
           review_flag == "weak:coarse_match" ~ "3-weak-match",
           review_flag == "note:single_sibling" ~ "4-single-sibling",
           review_flag == "minor:some_spread" ~ "5-minor-spread",
           TRUE ~ "6-ok-ish")) %>%
  arrange(check_priority, desc(total_units))
todo_csv <- file.path(output_dir, "still_to_verify.csv")
write.csv(todo %>% select(check_priority, upc, brand_filled, line, product_descr,
                          num_cartridges_f, mL_total_imputed, mL_rule, implied_raw_mg_per_mL,
                          review_flag, total_units),
          todo_csv, row.names = FALSE)

cat(sprintf("\n=== STILL TO VERIFY: %d UPCs, %.0f units (%.1f%% of dropped) ===\n",
            nrow(todo), sum(todo$total_units), 100*sum(todo$total_units)/tot))
todo %>% group_by(check_priority) %>%
  summarise(upcs = n(), units = round(sum(as.numeric(total_units))), .groups="drop") %>%
  arrange(check_priority) %>% as.data.frame() %>% print()
cat("\ntop 15 still-to-verify by units:\n")
todo %>% head(15) %>% mutate(u = round(as.numeric(total_units))) %>%
  select(check_priority, upc, brand_filled, line, mL_total_imputed, implied_raw_mg_per_mL, u) %>%
  as.data.frame() %>% print()

cat("\nWrote", prev_csv, ",", todo_csv, ", and imputation map.\n")
