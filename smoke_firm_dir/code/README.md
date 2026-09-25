# `code/` — layout, data flow and run order

This folder holds every R script in the supply-side e-cigarette pipeline. The
pipeline takes Nielsen RMS scanner data (store × week × UPC, 2013–2023, product
module 7467), corrects each product's nicotine content, and collapses the data
into national panels. It then builds the descriptive series, concentration
measures, firm-dynamics diagnostics and supply-model state variables used in
the meeting notes.

Before re-running or changing anything in `build/`, read
`smoke_firm_dir/handoff_files/MIGRATION_HANDOFF_2026-08-21.md`. It documents the
nicotine-correction method and the required rebuild order.

## Contents

- [Running a script](#running-a-script)
- [Data flow at a glance](#data-flow-at-a-glance)
- [Key conventions](#key-conventions)
- [The built panels](#the-built-panels)
- [`fxns/` — shared helpers](#fxns--shared-helpers)
- [`build/` — raw → panels](#build--raw--panels)
- [`analysis/` — panels → figures and tables](#analysis--panels--figures-and-tables)
- [`manual_refinement/` — one-off audits](#manual_refinement--one-off-audits-provenance-not-re-run)
- [`archive/` and `code_from_demand_side/`](#archive--superseded)
- [Full rebuild order](#full-rebuild-order)
- [Gotchas](#gotchas)

## Running a script

Every script is **run from the repository root** (the folder that contains
`smoke_firm_dir/`) and starts with

```r
source("smoke_firm_dir/code/fxns/1_paths.R")
```

which defines the path constants used everywhere:

| constant | value |
|---|---|
| `FIRM_DIR` | `smoke_firm_dir/` |
| `RAW_DIR` | `smoke_firm_dir/raw/cleaned_RMS/` — the `full_*_7467_*.RData` store×week×UPC files (gitignored, ~4 GB) |
| `SUPPORT_DIR` | `smoke_firm_dir/input/` — support files + built panels |
| `OUT_DIR` | `smoke_firm_dir/output/` |
| `PRELIM_DIR` | `smoke_firm_dir/output/prelim_analysis/` |
| `CODE_DIR` / `FXN_DIR` | `smoke_firm_dir/code/`, `smoke_firm_dir/code/fxns/` |

`fxn("2_upc_overrides.R")` is shorthand for
`source(file.path(FXN_DIR, "2_upc_overrides.R"))`.

From a terminal:

```sh
Rscript smoke_firm_dir/code/analysis/13_national_nicotine.R
```

Files are numbered by run order **within** each folder.

## Data flow at a glance

```
restricted Nielsen RMS (BU SCC)
   │  build/1  (runs on the SCC only)
   ▼
RAW_DIR/full_<yr>_7467_<yr>.RData      store × week × UPC, one file per year
   │
   ├─ build/2 ──► input/missing_mL_imputation_map.rds   (mL imputation, committed)
   │
   ├─ build/3 ──► input/bt_month_t2_niccorr_from_full.RData   brand × type × month  ◄── CANONICAL
   ├─ build/4 ──► output/.../cart_counts_by_type_month.csv
   ├─ build/5 ──► input/upc_month_niccorr_from_full.RData     brand × UPC × type × month
   └─ build/6 ──► input/upc_month_store_breadth.rds          UPC × month store counts
                     │
   NCP (demand side) ─ build/7 ──► input/avg_mL_by_hh_in_ncp.RData   k_t for M_t
   5 + 6 + 7 + taxes + Census ─ build/8 ──► input/demand_panel_firm_month.RData   Stage 1 sample
                     │
                     ▼
              analysis/1–13  ──►  output/prelim_analysis/<topic>/  (figures, CSVs)
```

The panel-level analyses (1–9) need only the canonical panel. The firm-level
work (10–13) also needs the UPC-month panel, and 12–13 need the store-breadth
file as well.

## Key conventions

These hold across the pipeline. A script that departs from one says so in
its header.

- **Delivered nicotine.** `nic_yield_total = liquid_total_mL × clean_label_mg_per_mL × 0.68`
  (`YIELD_FACTOR` in `fxns/2`). The cartridge count cancels out of delivered
  concentration. Never try to fix nicotine through `nic_yield_per_cart_f`,
  because it is itself mis-scaled. This is the cartridge-scaling bug that the
  `niccorr` panels fix.
- **Product types (T2).** `classify_t2()` in `fxns/3` puts each UPC into
  **Closed pod**, **Disposable** or **Open refill**. Open refill mixes 10–30 mL
  bottles with 0.7 mL pods, so anything averaged over size is usually reported
  within type, or pooled only across pod and disposable.
- **Homogeneous-good objects (the demand-side regressors).**
  `P_hom = (price/mL) × (avg mL per e-cig)` and
  `N_hom = (nic mg/mL) × (avg mL per e-cig)`, where
  `avg mL per e-cig = Σ units·mL² / Σ units·mL`. Both are mL-weighted.
- **Two weightings for nicotine.**
  - **mL-weighted** (`Σ nic_mg / Σ mL`): the demand side and the national
    descriptive series (`analysis/1`, `7`, `13`).
  - **UPC-unweighted** (plain mean of per-UPC mg/mL): the **supply-side firm
    state** `a_it` / `a_Ft` (`analysis/12`). This was Marc's instruction: a
    firm's nicotine state belongs to its posted product line, not its sales mix.
- **`UNKNOWN` brand.** A catch-all for unattributed UPCs, about 0.4% of mL. It
  is kept in the canonical panel but dropped from anything firm-level, because
  it is not a firm.
- **Distribution-breadth filter.** UPC-months sold in fewer than
  `N_STORES_MIN = 3` distinct stores are dropped in `analysis/12` and `13`.
  These are mostly a few stores clearing old stock: about 19% of UPC-months
  but only about 0.01% of mL. The threshold is a raw store count, not a share
  of the month's store panel. `build/6` explains why.
- **Prices.** `revenue_real` is deflated by CPI. `revenue_nom` is nominal.
- **Timeline events.** `fxns/4` holds the standard event markers (EVALI, the
  JUUL flavour pull, FDA flavoured-cartridge enforcement, the PMTA deadline).
  Scripts that need a different event define it locally; for example,
  `analysis/13` uses the Sep 2018 FDA "epidemic" letters.

## The built panels

All are in `input/` (`SUPPORT_DIR`).

| file | grain | key columns | built by |
|---|---|---|---|
| **`bt_month_t2_niccorr_from_full.RData`** → `bt_month_t2` | brand × T2 type × month (2013-01 … 2023-12, ~4.9k rows) | `units_sum`, `mL_sum`, `revenue_nom`, `revenue_real`, `nic_mg_sum`, `mL_sq_times_unit_sum`, plus cell ratios `price_per_mL`, `nic_mg_per_mL`, `avg_mL_per_ecig`, `P_hom_cell`, `N_hom_cell`, `mL_share` | `build/3` |
| `upc_month_niccorr_from_full.RData` → `upc_month_t2` | brand × UPC × T2 type × month (~43k rows) | same sums as above, plus `upc12`, `descr`, `label_mg_per_mL`, `deliv_mg_per_mL` | `build/5` |
| `upc_month_store_breadth.rds` | UPC × month | `n_stores`, `n_stores_month_total`, `store_share` | `build/6` |
| `missing_mL_imputation_map.rds`, `t2_impute_cache.rds` | UPC | imputed mL and nicotine for UPCs with a missing `liq_total_f` | `build/2` |
| `manual_nic_corrections.csv`, `label_maps.RData` | UPC / label | hand-verified nicotine corrections and label maps | by hand / `manual_refinement/` |
| `entry_wave_store_cache.rds` | store × month | store coverage for the 2021 entry-wave check | `manual_refinement/7` |

The canonical panel was rebuilt from the raw `full_*` files and validated cell
by cell against the documented national `N_hom` figures (2026-08-27). The
UPC-month panel collapses back to it exactly.

**Do not use** `bt_month_t2_from_full-do_not_use_has_incorrect_nic.RData`. It
still has the cartridge-scaling bug and is kept only for old-vs-new comparison.
Never overwrite a canonical panel without an explicit decision and a backup
(`input/backup_*` holds past ones).

## `fxns/` — shared helpers

These are sourced by other scripts. Their numbering is only for consistency;
order doesn't matter.

| file | provides |
|---|---|
| `1_paths.R` | the path constants above, and `fxn()` |
| `2_upc_overrides.R` | `YIELD_FACTOR` (0.68), `MANUAL_UPC_OVERRIDES`, `MANUAL_OVERRIDES`, `EXCLUDE_UPCS` (HeatSticks, hardware), `BRAND_RENAME` |
| `3_t2_classify.R` | `classify_t2()` — the Closed pod / Disposable / Open refill classifier |
| `4_event_lines_t2.R` | `events`, `event_layers(ymax)` (single panel: lines + numbered markers), `event_vlines()` (faceted: lines only), `event_caption` |
| `5_supply_model_state_fxns.R` | `build_share_roster()` (annual incumbents: mL share among identified brands > `INCUMBENT_SHARE_MIN` = 7%), `build_top5_roster()` (the earlier annual top-5 roster, kept for comparison), `build_a_it_and_fringe()` (tracked-firm `a_it` over each firm's full history, plus the pooled fringe `a_Ft`), `compute_top5_runs()`, `plot_a_it_single()`, `plot_a_it_facets()`. Used by `analysis/12`. Kept separate so the roster and `a_it` logic can run on filtered or unfiltered input unchanged |

## `build/` — raw → panels

| # | file | reads | writes |
|---|---|---|---|
| 1 | `clean_RMS_from_raw_to_most_detailed.R` | restricted Nielsen (BU SCC only) | `full_*_7467_*.RData` — **already supplied** in `RAW_DIR`; not run locally. SCC paths won't resolve here |
| 2 | `impute_missing_mL.R` | `RAW_DIR/full_*`, `fxns/2` | `input/missing_mL_imputation_map.rds`, `input/t2_impute_cache.rds`, verification CSVs. Without it, a missing `liq_total_f` drops 4–20% of e-cig units per year, worst in 2018–2020 |
| 3 | `build_t2_panel_niccorr.R` | `RAW_DIR/full_*`, imputation map, `input/label_maps.RData`, `input/manual_nic_corrections.csv`, `fxns/2,3` | **`input/bt_month_t2_niccorr_from_full.RData`** (the canonical panel), impact CSVs (`niccorr_by_brand_year.csv`, `niccorr_national_old_vs_new.csv`) and `investment_proxy/top5_upc_per_year.csv` |
| 4 | `build_cart_counts_t2.R` | same inputs as 3 | `p_and_n_decomp_t2/cart_counts_by_type_month.csv`: cartridge counts on the CDC-standardised unit (1 unit = 5 cartridges = 1 disposable = 1 bottle). Does not touch the panel |
| 5 | `build_upc_month_niccorr.R` | `RAW_DIR/full_*`, imputation map, `fxns/2,3`, the canonical panel (for validation) | `input/upc_month_niccorr_from_full.RData`: the same row-level corrections as 3, kept at UPC level |
| 6 | `build_upc_month_store_breadth.R` | `RAW_DIR/full_*` | `input/upc_month_store_breadth.rds`: distinct stores selling each UPC each month, as a raw count and as a share of that month's e-cig store panel. Feeds the breadth filter in `analysis/12` and `13` |
| 7 | `build_Mt_numerator.R` | the demand-side Nielsen Consumer Panel purchase file (**not in this repo**; set `NCP_CPS_PATH`) | `input/avg_mL_by_hh_in_ncp.RData`: mean monthly e-liquid mL per e-cig-buying household, simple and projection-weighted. This is `k_t` in the market size `M_t = k_t × US adults`. **Already supplied**; not runnable here |
| 8 | `build_firm_month_demand_panel.R` | `build/5`, `build/6`, `build/7` outputs, `raw/ecig_taxes/ec_tax_cotti_per_mL.RData`, `raw/census_pop/sc-est20*-alldata6.csv` | `input/demand_panel_firm_month.RData`: the Stage 1 nested-logit sample. `demand_im` has one row per incumbent × month (7% rule) with price (real $/mL), `a_it`, shares, eq. 7's LHS and within-nest term, and the instruments. `demand_mkt` has one row per month with fringe and outside shares, `M_t` and its robustness variants, `TaxIV_t` (population-weighted state tax, real $/mL), active-firm counts and `a_Ft` |

Steps 2–6 each read all 11 raw files and take several minutes. Step 2 only needs
re-running when the imputation logic changes; the map it writes is committed.

## `analysis/` — panels → figures and tables

Each script loads built panels and writes to `output/prelim_analysis/<dir>/`.
They are independent of each other except where noted. The numbering follows
the historical rebuild order, not dependency.

| # | file | output dir | what it produces | needs |
|---|---|---|---|---|
| 1 | `decompose_t2.R` | `p_and_n_decomp_t2/` | `P_hom` / `N_hom` within each T2 type and pooled: annual series, channel decompositions (2013→23, 2018→23), within-type brand drivers, and the national monthly series figures (`national_monthly_series_by_type*.png`, `…_nicotine.png`) | canonical panel |
| 2 | `hhi_concentration_t2.R` | `p_and_n_decomp_t2/` | mL-weighted brand HHI (`hhi_over_time.png`, `hhi_monthly.csv`); annual top-5 composition bars with ★ on the leader (`concentration_by_year.png`); a monthly version re-ranked each month, labelled where the leader changes (`concentration_by_month.png`) | canonical panel |
| 3 | `tracked_volume_t2.R` | `p_and_n_decomp_t2/` | tracked RMS unit volume by type and pooled (`tracked_units_by_type.png`, `tracked_units_pooled.png`) | canonical panel |
| 4 | `disposable_share_vs_cdc_t2.R` | `p_and_n_decomp_t2/` | RMS disposable share of pod+disposable units against the CDC/IRI benchmark (Ali et al., MMWR 2023) | canonical panel |
| 5 | `disposable_share_cdc_standardized.R` | `p_and_n_decomp_t2/` | the same comparison on CDC's standardised unit, to separate differences in unit definition from gaps in channel coverage | `build/4` output |
| 6 | `investment_proxy_t2.R` | `investment_proxy/` | for brands ever in the top 6: type mix and nicotine against market share (`typemix_by_brand.png`, `share_vs_nicotine_by_brand.png`, `ever_top6_brand_year_panel.csv`) | canonical panel |
| 7 | `brand_nicotine_trajectories_t2.R` | `p_and_n_decomp_t2/` | corrected mg/mL and `N_hom` trajectories for every brand that appears in the annual top-5 chart | canonical panel |
| 8 | `rebuild_corrected_requested_figures.R` | `p_and_n_decomp_t2/` | rebuilds the national-series-by-type, HHI and annual-composition figures from the corrected panel. **Overwrites some of 1's and 2's figures** (see Gotchas) | canonical panel |
| 9 | `ecig_type_schematics.R` | `p_and_n_decomp_t2/` | labelled drawings of the three T2 form factors (not to scale) | — |
| 10 | `ebe_diagnostics.R` | `firm_dynamics_ebe/` | firm-dynamics diagnostics for the EBE model, items 7.1/7.2/7.4/7.5 of the 08_27_2026 note: active-firm counts, first appearance, top-5 tenure, learning regressions, mL- vs UPC-weighted nicotine | canonical + UPC-month panels |
| 11 | `entry_wave_coverage_check.R` | `firm_dynamics_ebe/` | the 09_01_2026 note: the 2021 burst of new brands comes from changes in RMS store coverage and product classification, not from real entry | `input/entry_wave_store_cache.rds` from `manual_refinement/7` |
| 12 | `supply_model_nicotine_state.R` | `supply_model_state/` | **supply-model state variables.** Incumbents are firms with annual mL share > 7%, fixed for the year (3–6 per year). `a_it` is the UPC-unweighted mean delivered mg/mL for every firm ever an incumbent, over its full monthly history, with an `is_incumbent_that_year` flag. `a_Ft` is the pooled fringe, where fringe means everyone outside that year's incumbents. Also writes the annual roster, `roster_7pct_vs_top5.csv` (firm-years that moved when the roster switched from top-5 to 7%, 2026-09-25), breadth-filter sensitivity, `roster_diff_vs_unfiltered.csv` (the filter changes 0 roster firm-years) and two trajectory figures | `build/5`, `build/6`, `fxns/5` |
| 13 | `national_nicotine.R` | `p_and_n_decomp_t2/` | national monthly mg/mL, mL-weighted and pooled across types, on the same subset as 12 (≥3 stores, no UNKNOWN), with the Sep 2018 FDA letters marked (`national_monthly_nicotine.png/.csv`). Within 0.25 mg/mL of the unfiltered pooled line from 1 | `build/5`, `build/6` |

## `manual_refinement/` — one-off audits (provenance, not re-run)

`1`–`6` are the VUSE / cartridge-scaling nicotine investigation. Their
conclusions are already built into `input/manual_nic_corrections.csv`,
`input/missing_mL_imputation_map.rds` and `fxns/2_upc_overrides.R`, so the live
pipeline does not depend on them. `7` is the raw store-coverage pass for the
2021 entry-wave check. It writes `input/entry_wave_store_cache.rds` for
`analysis/11`.

| # | file | purpose |
|---|---|---|
| 1 | `nic_cartscale_fix.R` | first diagnosis of the cartridge-scaling bug |
| 2 | `upc_audit.R` | top-UPC audit (see Gotchas: shares an output file with `build/3`) |
| 3–6 | `vuse_upc_check.R`, `vuse_nic_recompute.R`, `vuse_nic_corrected.R`, `vuse_nic_sanity.R` | VUSE label and liquid corrections (Ciro 0.9 / Vibe 2.0 / Solo 0.5 mL) |
| 7 | `entry_wave_store_pass.R` | store-coverage cache for `analysis/11` |

## `archive/` — superseded

Versions from before the nicotine correction, kept for old-vs-new comparison
only. Don't build on them.

`1_build_t2_panel.R` (builds the "do-not-use, has incorrect nic" panel),
`2_decompose_p_and_n.R`, `3_decompose_p_and_n_t2.R`.

## `code_from_demand_side/` — reference

Demand-side cleaning and figure scripts carried over from the companion paper.
Not part of this pipeline.

## Full rebuild order

Start from the raw `full_*` files already in `RAW_DIR`:

1. `build/2`, only if the imputation logic changed. The committed map is
   otherwise enough.
2. `build/3`: the canonical panel. **Back up the existing one first.**
3. `build/4`, `build/5`, `build/6`, in any order.
4. `analysis/1`–`13`. Run `8` before `2` if you want 2's ★ composition chart
   to survive (see Gotchas).
5. Only if the audit format of `investment_proxy/top5_upc_per_year.csv` is
   needed: `manual_refinement/2` after `build/3`.

## Gotchas

- **Raw-file location.** `RAW_DIR` points to `smoke_firm_dir/raw/cleaned_RMS/`.
  An earlier layout kept the `full_*` files in repo-root `input/`. If a build
  script can't find them, check which location they are actually in.
- **`top5_upc_per_year.csv` has two writers.** `build/3` and
  `manual_refinement/2_upc_audit.R` both write
  `investment_proxy/top5_upc_per_year.csv`, with different, incompatible
  schemas. Whichever runs last wins.
- **`analysis/8` overwrites `analysis/1` and `2`.** It rewrites
  `national_monthly_series_by_type*.png`, `hhi_over_time.png` and
  `concentration_by_year.png`. Its composition chart still puts the ★ inside
  the text label (the older approach that `analysis/2` replaced), so run 2
  after 8 to keep 2's version.
- **ggplot2 is 3.4.0 locally.** Don't rely on `scale_linewidth_manual()`. When
  every series uses the same width, set a fixed `linewidth` in `geom_line()`
  instead of mapping it in `aes()`. `analysis/8` still uses the mapped form.
- **PNG writes on Windows.** `ggsave` fails with "agg could not write to the
  given file" if the PNG is open in a viewer. Close it and re-run.
- **RMS is not the whole national market.** Kilts RMS covers few convenience
  stores, so 2013–2016 brand shares understate convenience-heavy brands. For
  example, NJOY has about 9% of 2013 mL in RMS against about 24% of dollars in
  Nielsen Convenience Track + All Outlets Combined. The RMS e-cig store panel
  also swings from about 12k to 29k stores over the sample. See
  `output/personal_notes/09_24_2026_rms_coverage_and_incumbent_threshold_note_ai.md`.
