## Reusable product size and UPC-unweighted firm-month characteristics.
## Run from repository root. Extracts monthly raw attributes once (refreshes when raw files change), using corrected UPC panel,
## store breadth and reviewed size decisions; does not change sales quantities.
## Conflicting cached sizes remain missing unless explicitly corrected.
source("smoke_firm_dir/code/fxns/1_paths.R")
suppressPackageStartupMessages(library(dplyr))
source("smoke_firm_dir/code/fxns/2_upc_overrides.R")
pad <- function(x) sprintf("%012.0f", as.numeric(x))
positive <- function(x) ifelse(is.finite(x) & x > 0, x, NA_real_)
unique_value <- function(x) {
  v <- unique(round(positive(x[!is.na(x)]), 8)); v <- v[!is.na(v)]
  if (length(v) == 1L) v else NA_real_
}
attribute_path <- file.path(SUPPORT_DIR, "product_size_attribute_cache.rds")
raw_files <- sort(list.files(RAW_DIR, "^full_.*7467.*\\.RData$", full.names = TRUE))
stopifnot(length(raw_files) == 11L)
info <- file.info(raw_files)
signature <- data.frame(path = raw_files, size = info$size, mtime = as.numeric(info$mtime))
cache <- if (file.exists(attribute_path)) readRDS(attribute_path) else NULL
if (is.null(cache) || !identical(cache$signature, signature)) {
  parts <- lapply(raw_files, function(f) {
    e <- new.env(); load(f, envir = e)
    x <- data.table::as.data.table(e$rms_w_attr)
    z <- unique(x[prod_type == "ec" & !is.na(units) & units > 0,
      c("upc", "year_month", "num_cartridges_f", "liq_cart_f", "liq_total_f"), with = FALSE])
    cat("Size attributes:", basename(f), nrow(z), "rows\n")
    rm(x, e); gc(verbose = FALSE)
    as.data.frame(z)
  })
  cache <- list(signature = signature, data = bind_rows(parts))
  saveRDS(cache, attribute_path)
}
attributes <- cache$data %>% mutate(upc12 = pad(upc),
  month = as.Date(paste0(year_month, "-01")),
  size = coalesce(positive(liq_cart_f), positive(liq_total_f) / positive(num_cartridges_f))) %>%
  group_by(month, upc12) %>% summarise(cached_ml_per_cartridge = unique_value(size),
    cached_cartridges_per_pack = unique_value(num_cartridges_f),
    cached_size_conflict = n_distinct(round(size[is.finite(size)], 8)) > 1L,
    .groups = "drop")
stable_attributes <- cache$data %>% mutate(upc12 = pad(upc),
  size = coalesce(positive(liq_cart_f), positive(liq_total_f) / positive(num_cartridges_f))) %>%
  group_by(upc12) %>% summarise(stable_size = unique_value(size),
    stable_count = unique_value(num_cartridges_f), .groups = "drop")
manual <- read.csv(file.path(SUPPORT_DIR, "manual_product_size_corrections.csv"),
                   colClasses = c(upc12 = "character"))
stopifnot(!anyDuplicated(manual$upc12), all(manual$ml_per_cartridge > 0),
          all(manual$cartridges_per_pack > 0))
nic <- read.csv(file.path(SUPPORT_DIR, "manual_nic_corrections.csv"),
                colClasses = c(upc12 = "character")) %>%
  transmute(upc12 = pad(upc12), corrected_size = positive(true_mL_per_cart))
ov <- MANUAL_UPC_OVERRIDES %>% transmute(upc12 = pad(upc), override_size = positive(liq_cart_f))
load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))
breadth <- readRDS(file.path(SUPPORT_DIR, "upc_month_store_breadth.rds"))
upc <- upc_month_t2 %>% filter(brand != "UNKNOWN", units_sum > 0, mL_sum > 0) %>%
  group_by(month, brand, upc12) %>% summarise(
    panel_types = paste(sort(unique(type)), collapse = "; "),
    descriptions = paste(sort(unique(descr[!is.na(descr)])), collapse = "; "),
    panel_ml_per_pack = sum(mL_sum) / sum(units_sum), .groups = "drop") %>%
  left_join(breadth %>% select(month, upc12, n_stores), by = c("month", "upc12")) %>%
  left_join(attributes, by = c("month", "upc12")) %>%
  left_join(stable_attributes, by = "upc12") %>% left_join(nic, by = "upc12") %>%
  left_join(ov, by = "upc12") %>%
  left_join(manual %>% transmute(upc12, reviewed_size = ml_per_cartridge,
    reviewed_count = cartridges_per_pack, reviewed_type = product_type), by = "upc12") %>%
  mutate(user_family_size = case_when(brand == "JUUL" ~ 0.7,
      brand == "NJOY" & grepl("NJOY ACE", descriptions, ignore.case = TRUE) ~ 1.9,
      brand == "VUSE" & grepl("VUSE VIBE", descriptions, ignore.case = TRUE) ~ 1.9,
      TRUE ~ NA_real_),
    panel_derived_size = ifelse(!coalesce(cached_size_conflict, FALSE),
      panel_ml_per_pack / coalesce(cached_cartridges_per_pack, stable_count), NA_real_),
    stable_size_fallback = ifelse(!coalesce(cached_size_conflict, FALSE), stable_size, NA_real_),
    ml_per_cartridge = coalesce(reviewed_size, user_family_size, corrected_size, override_size, cached_ml_per_cartridge, stable_size_fallback, panel_derived_size),
    size_source = case_when(!is.na(reviewed_size) ~ "user_review",
      !is.na(user_family_size) ~ "user_confirmed_family",
      !is.na(corrected_size) ~ "manual_nic_correction",
      !is.na(override_size) ~ "manual_upc_override",
      !is.na(cached_ml_per_cartridge) ~ "consistent_cached_attribute",
      !is.na(stable_size_fallback) ~ "consistent_same_upc_other_months",
      !is.na(panel_derived_size) ~ "panel_pack_ml_divided_by_observed_count",
      TRUE ~ "unresolved"),
    size_type = coalesce(reviewed_type, panel_types),
    device_size_eligible = size_type %in% c("Closed pod", "Disposable"),
    eligible_3stores = !is.na(n_stores) & n_stores >= 3,
    reviewed_pack_ml = reviewed_size * reviewed_count,
    reviewed_pack_differs = !is.na(reviewed_pack_ml) & abs(reviewed_pack_ml - panel_ml_per_pack) > 1e-6)
stopifnot(!anyDuplicated(upc[c("month", "brand", "upc12")]))
## Device mean excludes bottles and unresolved/mixed classifications explicitly.
## Strict mean is NA if any eligible device UPC lacks a size; observed mean is
## provided separately with counts so incomplete coverage cannot go unnoticed.
firm <- upc %>% filter(eligible_3stores) %>% group_by(month, brand) %>% summarise(
  n_upcs = n(),
  n_upc_size_known = sum(!is.na(ml_per_cartridge)),
  avg_ml_per_product_unit_observed = if (n_upc_size_known > 0) mean(ml_per_cartridge, na.rm = TRUE) else NA_real_,
  avg_ml_per_product_unit = if (n_upc_size_known == n_upcs) avg_ml_per_product_unit_observed else NA_real_,
  n_device_upcs = sum(device_size_eligible),
  n_nondevice_or_mixed_upcs = sum(!device_size_eligible),
  n_device_size_known = sum(device_size_eligible & !is.na(ml_per_cartridge)),
  avg_ml_per_ecig_observed = if (n_device_size_known > 0)
    mean(ml_per_cartridge[device_size_eligible], na.rm = TRUE) else NA_real_,
  avg_ml_per_ecig = if (n_device_upcs > 0 & n_device_size_known == n_device_upcs)
    avg_ml_per_ecig_observed else NA_real_,
  device_size_coverage = if (n_device_upcs > 0) n_device_size_known / n_device_upcs else NA_real_,
  .groups = "drop")
stopifnot(!anyDuplicated(firm[c("month", "brand")]))
saveRDS(upc, file.path(SUPPORT_DIR, "product_size_upc_month.rds"))
firm <- firm %>% mutate(log_upc_variety = log(n_upcs))
saveRDS(firm, file.path(SUPPORT_DIR, "product_characteristics_firm_month.rds"))
out <- file.path(OUT_DIR, "demand_estimation", "product_size_review")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
load(file.path(SUPPORT_DIR, "demand_panel_firm_month.RData"))
coverage <- demand_im %>% select(month, brand) %>% left_join(firm, by = c("month", "brand"))
write.csv(coverage, file.path(out, "firm_month_size_coverage.csv"), row.names = FALSE)
write.csv(upc %>% filter(eligible_3stores) %>% semi_join(demand_im, by = c("month", "brand")) %>%
  filter(is.na(ml_per_cartridge) | !device_size_eligible) %>%
  distinct(brand, upc12, panel_types, size_type, size_source, cached_size_conflict),
  file.path(out, "remaining_size_coverage.csv"), row.names = FALSE)
write.csv(upc %>% filter(reviewed_pack_differs) %>%
  distinct(brand, upc12, panel_ml_per_pack, reviewed_pack_ml),
  file.path(out, "reviewed_pack_volume_differences.csv"), row.names = FALSE)
cat("Incumbent firm-months:", nrow(coverage), "complete device-size coverage:",
    sum(!is.na(coverage$avg_ml_per_ecig)), "\n")

missing_device <- upc %>% filter(eligible_3stores, device_size_eligible, is.na(ml_per_cartridge)) %>%
  semi_join(demand_im, by = c("month", "brand")) %>%
  group_by(brand, upc12) %>% summarise(first_month = min(month), last_month = max(month),
    n_months = n_distinct(month), .groups = "drop")
clues <- upc %>% semi_join(missing_device, by = c("brand", "upc12")) %>%
  group_by(brand, upc12) %>% summarise(
    descriptions = paste(unique(descriptions[nzchar(descriptions)]), collapse = "; "),
    panel_pack_ml_values = paste(sort(unique(panel_ml_per_pack)), collapse = "; "),
    observed_counts_other_months = paste(sort(unique(cached_cartridges_per_pack)), collapse = "; "),
    .groups = "drop")
write.csv(left_join(missing_device, clues, by = c("brand", "upc12")),
  file.path(out, "unresolved_device_sizes.csv"), row.names = FALSE)
