# `code/` — layout and run order

Every script is **run from the repository root** (the folder that contains
`smoke_firm_dir/`) and starts with

```r
source("smoke_firm_dir/code/fxns/1_paths.R")
```

which defines the path constants used everywhere:

| constant | value |
|---|---|
| `FIRM_DIR` | `smoke_firm_dir/` |
| `RAW_DIR` | `smoke_firm_dir/raw/cleaned_RMS/` — the `full_*_7467_*.RData` store×week×UPC files (gitignored) |
| `SUPPORT_DIR` | `smoke_firm_dir/input/` — support files + built panels |
| `OUT_DIR` | `smoke_firm_dir/output/` |
| `PRELIM_DIR` | `smoke_firm_dir/output/prelim_analysis/` |
| `FXN_DIR` | `smoke_firm_dir/code/fxns/` |

`fxn("2_upc_overrides.R")` is shorthand for `source(file.path(FXN_DIR, "2_upc_overrides.R"))`.

Files are numbered by run order **within** each folder.

## `fxns/` — shared, sourced by others (order irrelevant, numbered for consistency)

| file | provides |
|---|---|
| `1_paths.R` | the path constants above |
| `2_upc_overrides.R` | `YIELD_FACTOR` (0.68), `MANUAL_UPC_OVERRIDES`, `MANUAL_OVERRIDES`, `EXCLUDE_UPCS`, `BRAND_RENAME` |
| `3_t2_classify.R` | `classify_t2()` — Closed pod / Disposable / Open refill classifier |
| `4_event_lines_t2.R` | `events`, `event_layers()`, `event_vlines()`, `event_caption` for the timeline annotations |

## `build/` — raw → panels

| # | file | reads | writes |
|---|---|---|---|
| 1 | `clean_RMS_from_raw_to_most_detailed.R` | restricted Nielsen (BU SCC only) | `full_*_7467_*.RData` — **already supplied** in `RAW_DIR`; not run locally |
| 2 | `impute_missing_mL.R` | `RAW_DIR/full_*`, `fxns/2` | `input/missing_mL_imputation_map.rds`, `input/t2_impute_cache.rds`, verification CSVs |
| 3 | `build_t2_panel_niccorr.R` | `RAW_DIR/full_*`, imputation map, `input/label_maps.RData`, `input/manual_nic_corrections.csv`, `fxns/2,3` | **`input/bt_month_t2_niccorr_from_full.RData`** (the canonical panel) + impact CSVs |
| 4 | `build_cart_counts_t2.R` | same raw inputs | `output/prelim_analysis/p_and_n_decomp_t2/cart_counts_by_type_month.csv` |
| 5 | `build_upc_month_niccorr.R` | `RAW_DIR/full_*`, imputation map, `fxns/2,3`, the canonical panel (validation) | `input/upc_month_niccorr_from_full.RData` (brand×UPC×month; collapses back to the canonical panel exactly) |

Steps 2–5 each read all 11 raw files and take several minutes. Step 2 only needs
re-running when the imputation logic changes; the map it writes is committed.

## `analysis/` — panel → meeting-note figures

Each loads a built panel and writes to `output/prelim_analysis/…`. Independent of
each other except where noted; the numbering follows the historical rebuild order.

| # | file | main output dir |
|---|---|---|
| 1 | `decompose_t2.R` | `p_and_n_decomp_t2/` |
| 2 | `hhi_concentration_t2.R` | `p_and_n_decomp_t2/` |
| 3 | `tracked_volume_t2.R` | `p_and_n_decomp_t2/` |
| 4 | `disposable_share_vs_cdc_t2.R` | `p_and_n_decomp_t2/` |
| 5 | `disposable_share_cdc_standardized.R` | `p_and_n_decomp_t2/` — needs `cart_counts_by_type_month.csv` from `build/4` |
| 6 | `investment_proxy_t2.R` | `investment_proxy/` |
| 7 | `brand_nicotine_trajectories_t2.R` | `p_and_n_decomp_t2/` |
| 8 | `rebuild_corrected_requested_figures.R` | `p_and_n_decomp_t2/` |
| 9 | `ecig_type_schematics.R` | `p_and_n_decomp_t2/` |
| 10 | `ebe_diagnostics.R` | `firm_dynamics_ebe/` — needs `upc_month_niccorr_from_full.RData` from `build/5`; the 08_27_2026 firm-dynamics note (items 7.1/7.2/7.4/7.5) |
| 11 | `entry_wave_coverage_check.R` | `firm_dynamics_ebe/` — needs `input/entry_wave_store_cache.rds` from `manual_refinement/7`; the 09_01_2026 coverage-vs-entry note |

## `manual_refinement/` — one-off audits (provenance, not re-run)

`1`–`6` are the VUSE / cartridge-scaling nicotine investigation; their conclusions
are already baked into `input/manual_nic_corrections.csv`,
`input/missing_mL_imputation_map.rds`, and `fxns/2_upc_overrides.R`, so the live
pipeline does not depend on them. `7` is the raw store-coverage pass for the 2021
entry-wave check (writes `input/entry_wave_store_cache.rds` for `analysis/11`).

`1_nic_cartscale_fix.R`, `2_upc_audit.R`, `3_vuse_upc_check.R`,
`4_vuse_nic_recompute.R`, `5_vuse_nic_corrected.R`, `6_vuse_nic_sanity.R`,
`7_entry_wave_store_pass.R`.

## `archive/` — superseded

Pre-nicotine-correction versions, kept for old-vs-new comparison only.

`1_build_t2_panel.R` (builds the "do-not-use, has incorrect nic" panel),
`2_decompose_p_and_n.R`, `3_decompose_p_and_n_t2.R`.

## `code_from_demand_side/` — reference

Demand-side cleaning/figure scripts carried over from the companion paper. Not
part of this pipeline.
