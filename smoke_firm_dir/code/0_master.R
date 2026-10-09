## Explicit pipeline runner. Run from the repository root.
## No arguments = print the plan. Add --run to execute in separate R processes.
## --stage=all|build|preliminary|instruments|demand|firm_fe|ols|comparison|characteristics|size --mode=cached|rebuild
## Rebuild excludes external-only 1_build_data/1 and 1_build_data/7; their outputs must exist.
local({
  args <- commandArgs(trailingOnly = TRUE)
  valid <- grepl("^--(stage=(all|build|preliminary|instruments|demand|firm_fe|ols|comparison|characteristics|size)|mode=(cached|rebuild)|run|dry-run)$", args)
  if (any(!valid)) stop("Unknown argument: ", paste(args[!valid], collapse = ", "))
  option <- function(key, default) {
    x <- args[startsWith(args, paste0("--", key, "="))]
    if (length(x) > 1L) stop("Repeated option: ", key)
    if (length(x)) sub(paste0("^--", key, "="), "", x) else default
  }
  stage <- option("stage", "all")
  mode <- option("mode", "cached")
  execute <- "--run" %in% args && !"--dry-run" %in% args
  if (!dir.exists("smoke_firm_dir/code")) stop("Run 0_master.R from the repository root.")
  source("smoke_firm_dir/code/fxns/1_paths.R")
  build <- c("2_impute_missing_mL.R", "3_build_t2_panel_niccorr.R",
             "4_build_cart_counts_t2.R", "5_build_upc_month_niccorr.R",
             "6_build_upc_month_store_breadth.R", "8_build_firm_month_demand_panel.R",
             "9_build_geographic_instruments.R", "10_build_product_size.R")
  prelim <- c("1_decompose_t2.R", "2_hhi_concentration_t2.R", "3_tracked_volume_t2.R",
              "4_disposable_share_vs_cdc_t2.R", "5_disposable_share_cdc_standardized.R",
              "6_investment_proxy_t2.R", "7_brand_nicotine_trajectories_t2.R",
              "9_ecig_type_schematics.R", "10_ebe_diagnostics.R",
              "11_entry_wave_coverage_check.R", "12_supply_model_nicotine_state.R",
              "13_national_nicotine.R", "14_instrument_comparison.R")
  demand <- file.path("3_demand_estimation", c("1_estimate_nested_logit.R", "2_report_demand_results.R", "3_estimate_firm_fe.R", "4_ols_diagnostic.R", "6_product_size_comparison.R", "7_market_size_comparison.R", "5_specification_comparison.R"))
  if (mode == "cached") build <- tail(build, 2L)
  plan <- switch(stage,
    all = c(file.path("1_build_data", build), file.path("2_preliminary_analysis", prelim), demand),
    demand = demand,
    firm_fe = "3_demand_estimation/3_estimate_firm_fe.R",
    ols = "3_demand_estimation/4_ols_diagnostic.R",
    comparison = c("1_build_data/10_build_product_size.R", "3_demand_estimation/6_product_size_comparison.R", "3_demand_estimation/7_market_size_comparison.R", "3_demand_estimation/5_specification_comparison.R"),
    size = c("1_build_data/10_build_product_size.R", "3_demand_estimation/6_product_size_comparison.R", "3_demand_estimation/7_market_size_comparison.R", "3_demand_estimation/5_specification_comparison.R"),
    characteristics = "1_build_data/10_build_product_size.R",
    build = file.path("1_build_data", build),
    preliminary = file.path("2_preliminary_analysis", prelim),
    instruments = c("1_build_data/9_build_geographic_instruments.R",
                    "2_preliminary_analysis/14_instrument_comparison.R"))
  stopifnot(all(file.exists(file.path(CODE_DIR, plan))))
  cat("Mode:", mode, " Stage:", stage, if (execute) " EXECUTE\n" else " PLAN ONLY\n")
  cat(paste(seq_along(plan), plan, sep = ". "), sep = "\n")
  cat("\nExternal builders 1 and 7, audits, and archive are excluded. Redundant preliminary script 8 was deleted.\n")
  if (!execute) return(invisible(plan))

  # Inputs are checked before each script; earlier steps may produce them.
  panel <- "bt_month_t2_niccorr_from_full.RData"
  upc <- "upc_month_niccorr_from_full.RData"
  breadth <- "upc_month_store_breadth.rds"
  requirements <- list(
    "7_market_size_comparison.R" = c("demand_instrument_candidates.rds", "product_characteristics_firm_month.rds"),
    "6_product_size_comparison.R" = c("demand_instrument_candidates.rds", "product_characteristics_firm_month.rds"),
    "10_build_product_size.R" = c(upc, breadth, "demand_panel_firm_month.RData", "manual_product_size_corrections.csv", "manual_nic_corrections.csv"),
    "2_impute_missing_mL.R" = character(),
    "3_build_t2_panel_niccorr.R" = c("missing_mL_imputation_map.rds", "label_maps.RData", "manual_nic_corrections.csv"),
    "4_build_cart_counts_t2.R" = c("missing_mL_imputation_map.rds", "label_maps.RData", "manual_nic_corrections.csv"),
    "5_build_upc_month_niccorr.R" = c(panel, "missing_mL_imputation_map.rds", "label_maps.RData", "manual_nic_corrections.csv"),
    "6_build_upc_month_store_breadth.R" = character(),
    "8_build_firm_month_demand_panel.R" = c(upc, breadth, "avg_mL_by_hh_in_ncp.RData"),
    "9_build_geographic_instruments.R" = c(upc, breadth, "demand_panel_firm_month.RData"),
    "1_decompose_t2.R" = panel, "2_hhi_concentration_t2.R" = panel,
    "3_tracked_volume_t2.R" = panel, "4_disposable_share_vs_cdc_t2.R" = panel,
    "5_disposable_share_cdc_standardized.R" = character(),
    "6_investment_proxy_t2.R" = panel, "7_brand_nicotine_trajectories_t2.R" = panel,
    "9_ecig_type_schematics.R" = character(), "10_ebe_diagnostics.R" = c(panel, upc),
    "11_entry_wave_coverage_check.R" = c(panel, upc, "entry_wave_store_cache.rds"),
    "12_supply_model_nicotine_state.R" = c(upc, breadth),
    "13_national_nicotine.R" = c(upc, breadth),
    "14_instrument_comparison.R" = "demand_instrument_candidates.rds",
    "1_estimate_nested_logit.R" = "demand_instrument_candidates.rds",
    "2_report_demand_results.R" = character(),
    "3_estimate_firm_fe.R" = "demand_instrument_candidates.rds",
    "4_ols_diagnostic.R" = "demand_instrument_candidates.rds",
    "5_specification_comparison.R" = "demand_instrument_candidates.rds")
  require_files <- function(paths) {
    missing <- paths[!file.exists(paths)]
    if (length(missing)) stop("Missing required inputs:\n", paste(missing, collapse = "\n"))
  }
  rebuilding <- mode == "rebuild" && stage %in% c("all", "build")
  raw_needed <- rebuilding || (any(grepl("9_build_geographic", plan)) &&
    (!file.exists(file.path(SUPPORT_DIR, "brand_state_month_presence.rds")) ||
     Sys.getenv("REBUILD_GEO_PRESENCE", "0") == "1"))
  if (raw_needed && length(list.files(RAW_DIR, "^full_.*7467.*\\.RData$")) != 11L)
    stop("Expected 11 cleaned annual RMS files in ", RAW_DIR)
  if (any(grepl("[89]_build_", basename(plan)))) {
    require_files(file.path(FIRM_DIR, "raw", c("ecig_taxes/ec_tax_cotti_per_mL.RData",
      "census_pop/sc-est2020int-alldata6.csv", "census_pop/sc-est2023-alldata6.csv")))
  }
  if (rebuilding) {
    require_files(file.path(SUPPORT_DIR, c("avg_mL_by_hh_in_ncp.RData", "label_maps.RData", "manual_nic_corrections.csv")))
    backup <- tempfile("backup_master_", tmpdir = SUPPORT_DIR)
    dir.create(backup)
    files <- list.files(SUPPORT_DIR, pattern = "\\.(RData|rds|csv)$", full.names = TRUE)
    if (!all(file.copy(files, backup))) stop("Backup failed; no builders have run.")
    cat("Support-file backup:", backup, "\n")
    old_geo <- Sys.getenv("REBUILD_GEO_PRESENCE", unset = NA_character_)
    on.exit(if (is.na(old_geo)) Sys.unsetenv("REBUILD_GEO_PRESENCE") else
      Sys.setenv(REBUILD_GEO_PRESENCE = old_geo), add = TRUE)
    Sys.setenv(REBUILD_GEO_PRESENCE = "1")
  }
  rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
  for (script in plan) {
    name <- basename(script)
    require_files(file.path(SUPPORT_DIR, requirements[[name]]))
    if (name == "5_disposable_share_cdc_standardized.R")
      require_files(file.path(PRELIM_DIR, "p_and_n_decomp_t2/cart_counts_by_type_month.csv"))
    if (name == "2_report_demand_results.R")
      require_files(file.path(OUT_DIR, "demand_estimation", c("coefficients.csv",
        "first_stage_diagnostics.csv", "model_checks.csv", "residuals.csv", "demand_models.rds")))
    cat("\nRunning", script, "\n")
    status <- system2(rscript, c("--vanilla", shQuote(file.path(CODE_DIR, script))))
    if (status != 0L) stop(script, " failed (exit ", status, "); remaining steps were not run.")
  }
  cat("\nSelected pipeline completed.\n")
})
