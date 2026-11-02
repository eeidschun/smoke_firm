# Migration handoff — e-cigarette T2 panel and nicotine correction

Date: 2026-08-21

## Purpose

This handoff preserves the e-cigarette T2 panel work completed on the old computer,
especially the corrected nicotine layer. The new computer is expected to begin with
only `main.R`, `code_from_demand_side/`, and the eleven raw annual
`input/full_*7467*.RData` files. Copy the migration bundle into the same project root
so that all paths continue to begin with `pr/`.

## First action on the new computer

1. Unzip `PR_ECIG_MIGRATION_BUNDLE_2026-08-21.zip` in the project root.
2. Put the eleven raw annual files in `pr/input/` if they are not already there.
3. Confirm that this file exists:
   `pr/input/bt_month_t2_niccorr_from_full.RData`.
4. Treat that `*_niccorr_*` panel as the current analysis panel.

Do **not** accidentally use `pr/input/bt_month_t2_from_full.RData` for nicotine
analysis. It is the old canonical panel and still contains the cartridge-scaling bug.
It is retained only for comparison. Do not overwrite it unless the user explicitly
decides to promote the corrected panel to canonical and makes a backup first.

## Core correction

The old panel understated delivered nicotine for many multi-cartridge packs because
one cartridge's nicotine yield was divided by the whole pack's liquid volume. The
robust identity is:

```text
nic_yield_total = liquid_total_mL * clean_label_mg_per_mL * 0.68
```

`0.68` is `YIELD_FACTOR`, the assumed transfer efficiency. Cartridge count cancels
from delivered concentration. Do not attempt to repair this using
`nic_yield_per_cart_f`; that field is itself mis-scaled.

The master manual correction table is:

```text
pr/input/manual_nic_corrections.csv
```

It includes label fixes across brands, liquid-per-cartridge fixes, and two hardware
exclusions. VUSE Ciro/Vibe/Solo family rules are applied in the corrected builder.

## Current authoritative files

### Required rebuild inputs and support files

- `pr/input/manual_nic_corrections.csv` — master manual corrections.
- `pr/input/label_maps.RData` — UPC/brand label maps.
- `pr/input/missing_mL_imputation_map.rds` — reusable missing-mL map.
- `pr/input/t2_impute_cache.rds` — imputation cache retained for reproducibility.
- `pr/input/bt_month_t2_niccorr_from_full.RData` — current corrected panel.
- `pr/input/bt_month_t2_from_full.RData` — old buggy panel, comparison only.

### Core source files

- `pr/build_t2_panel_niccorr.R` — rebuilds the corrected panel from all raw years,
  prints national and brand-year old→new `N_hom`, and writes impact/audit outputs.
- `pr/upc_audit.R` — all-corrections top-five and implausible UPC audit.
- `pr/t2_classify.R` — T2 classification rules.
- `pr/upc_overrides.R` — UPC overrides, exclusions, and `YIELD_FACTOR`.
- `pr/impute_missing_mL.R` — builds missing-mL support data if needed.
- `pr/build_cart_counts_t2.R` — builds standardized cartridge-count diagnostics.

### Current corrected-panel analysis scripts

These scripts have been changed to load
`bt_month_t2_niccorr_from_full.RData` directly:

- `pr/decompose_t2.R`
- `pr/hhi_concentration_t2.R`
- `pr/tracked_volume_t2.R`
- `pr/disposable_share_vs_cdc_t2.R`
- `pr/investment_proxy_t2.R`
- `pr/brand_nicotine_trajectories_t2.R`
- `pr/rebuild_corrected_requested_figures.R`

`pr/disposable_share_cdc_standardized.R` consumes
`output/prelim_analysis/p_and_n_decomp_t2/cart_counts_by_type_month.csv`, which is
rebuilt by `build_cart_counts_t2.R`.

## Rebuild order

> **2026-08-27 reorg.** `pr/` is now `smoke_firm_dir/`, and `code/` is split into
> `fxns/ build/ analysis/ manual_refinement/ archive/` with each file numbered by
> run order. Raw `full_*` files live in `smoke_firm_dir/raw/cleaned_RMS/`. Every
> script is run from the repo root and self-locates via
> `source("smoke_firm_dir/code/fxns/1_paths.R")`. See `smoke_firm_dir/code/README.md`
> for the full map. The commands below are updated to the new paths.

Run from the repository root (the folder containing `smoke_firm_dir/`). Required R
packages: `tidyverse`, `lubridate`, `readxl`, `data.table`, `fixest`, `patchwork`.

```bash
Rscript smoke_firm_dir/code/build/3_build_t2_panel_niccorr.R      # canonical panel
Rscript smoke_firm_dir/code/build/4_build_cart_counts_t2.R
Rscript smoke_firm_dir/code/build/5_build_upc_month_niccorr.R     # UPC-month panel
Rscript smoke_firm_dir/code/manual_refinement/2_upc_audit.R       # optional audit
Rscript smoke_firm_dir/code/analysis/1_decompose_t2.R
Rscript smoke_firm_dir/code/analysis/2_hhi_concentration_t2.R
Rscript smoke_firm_dir/code/analysis/3_tracked_volume_t2.R
Rscript smoke_firm_dir/code/analysis/4_disposable_share_vs_cdc_t2.R
Rscript smoke_firm_dir/code/analysis/5_disposable_share_cdc_standardized.R
Rscript smoke_firm_dir/code/analysis/6_investment_proxy_t2.R
Rscript smoke_firm_dir/code/analysis/7_brand_nicotine_trajectories_t2.R
Rscript smoke_firm_dir/code/analysis/8_rebuild_corrected_requested_figures.R
Rscript smoke_firm_dir/code/analysis/9_ecig_type_schematics.R
Rscript smoke_firm_dir/code/analysis/10_ebe_diagnostics.R
```

`build/3`, `build/4`, `build/5` and `manual_refinement/2` read all eleven raw files
and take several minutes each. The `analysis/` scripts run quickly from the built
panels. `build/2_impute_missing_mL.R` only needs re-running if the imputation logic
changes — the map it writes (`input/missing_mL_imputation_map.rds`) is committed.
`build/1_clean_RMS_from_raw_to_most_detailed.R` runs on the BU SCC only; its output
is the pre-supplied `full_*` set.

## Latest validated results

The corrected panel passed these checks:

- 4,889 rows.
- 132 months, January 2013 through December 2023.
- No duplicate `(month, brand, type)` keys.
- No non-finite `nic_mg_per_mL` or `N_hom_cell` values.
- Monthly mL shares sum to one.

National `N_hom` (mg per homogeneous e-cig), old→corrected:

| Year | Old | Corrected | Change |
|---:|---:|---:|---:|
| 2013 | 46.8 | 49.4 | +2.6 |
| 2014 | 59.7 | 61.3 | +1.7 |
| 2015 | 87.1 | 87.8 | +0.7 |
| 2016 | 105.6 | 105.7 | +0.0 |
| 2017 | 108.6 | 108.6 | +0.0 |
| 2018 | 93.0 | 92.6 | -0.4 |
| 2019 | 108.8 | 108.7 | -0.1 |
| 2020 | 93.7 | 94.2 | +0.5 |
| 2021 | 102.4 | 122.9 | +20.5 |
| 2022 | 104.6 | 132.7 | +28.1 |
| 2023 | 114.5 | 143.4 | +28.9 |

The large late-period movement is overwhelmingly VUSE. Corrected VUSE `N_hom` is
approximately 88.2→148.5 in 2021, 85.6→155.8 in 2022, and 101.6→163.7 in 2023.

## Interpretation to carry forward

Retract any statement that VUSE won while offering unusually low nicotine. That result
was caused by the scaling bug. Corrected, VUSE Alto is a high-nicotine pod: roughly
41 mg/mL label / 28 mg/mL delivered on a brand-volume-weighted basis, compared with
roughly 50 / 34 for JUUL.

The current explanation for VUSE's rise is:

1. Reynolds/BAT convenience and gas-station distribution, shelf placement, and trade
   marketing.
2. VUSE Alto arrived as JUUL entered regulatory and legal trouble and absorbed demand
   that JUUL shed.
3. Regulatory authorization supported retailer/distributor confidence.
4. NJOY had capable hardware but lacked BAT-scale capital and distribution until its
   2023 acquisition by Altria.

The post-2021 rise in `N_hom` is mainly a size/pack and product-mix story. Corrected
nicotine concentration is broadly flat to slightly declining while average mL per
homogeneous product rises.

## Remaining audit issue

The current audit file is:

```text
pr/output/prelim_analysis/investment_proxy/top5_upc_per_year.csv
```

The nine NJOY/LOGIC low-label flags are 10 mL refill bottles and appear legitimate.
Three FINITI UPCs remain unresolved and should be manually checked against exact product
packaging or an authoritative exact-UPC source:

- `085962600202`
- `085962600203`
- `085962600273`

They are small 1–1.75 mL products recorded at 8 mg/mL. Some public FINITI listings show
1.6% nicotine, but no exact-UPC support was found; therefore no correction was applied.
Do not change them merely by analogy to another FINITI product.

## Finished note and latest figures

The latest brand-dynamics note is in the requested Marc folder:

- `pr/output/marc_meeting_notes/08_10_2026_ecig_brand_dynamics_note_ai.md`
- `pr/output/marc_meeting_notes/08_10_2026_ecig_brand_dynamics_note_ai.pdf`

It contains an explicit August 10 revision notice and the corrected VUSE storyline.
The PDF was rendered with the VS Code `Markdown PDF` extension/Headless Chrome, not
Pandoc.

Important corrected figures are under:

```text
pr/output/prelim_analysis/p_and_n_decomp_t2/
```

In particular:

- `national_monthly_series_by_type.png`
- `national_monthly_series_by_type_no_open.png`
- `national_monthly_series_nicotine.png`
- `N_hom_by_type.png`
- `hhi_over_time.png`
- `concentration_by_year.png`
- `nic_mg_per_mL_by_top_brand_over_time.png`
- `N_hom_by_top_brand_over_time.png`
- `top_brand_nicotine_by_year.csv`

The two top-brand nicotine figures include every named brand that appears in any annual
top-five bar, exclude `UNKNOWN`/`Other`, and show years when national mL share is at
least 0.1%.

## Scope and preservation warnings

- The raw `full_*.RData` files are intentionally excluded from the migration bundle
  because the user already has them. They must be placed in `pr/input/`.
- Preserve directory structure; scripts use relative `pr/...` paths.
- Do not hardcode the old computer's absolute path.
- Do not delete or overwrite the old canonical panel until the corrected panel has
  been independently backed up.
- The migration bundle includes diagnostic/legacy scripts as context, but the core
  scripts listed above are the maintained path.

## Related historical handoff

`pr/HANDOFF_nicotine_cleaning_2026-08-10.md` documents the original diagnosis and
earlier state. This migration handoff supersedes it where they differ.
