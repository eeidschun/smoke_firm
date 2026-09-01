# Project Instructions

## Repositories

### smoke_firm

E-cigarette industry supply-side research (economics PhD project) using Nielsen
retail scanner data.

Structure:

- `smoke_firm_dir/raw/cleaned_RMS/` — cleaned annual Nielsen RMS files,
  `full_*_7467_*.RData` (one per year, 2013–2023), store × week × UPC. Source of
  truth for the e-cig category; do not edit by hand. The cleaning (from restricted
  raw Nielsen, on the BU SCC) can be trusted. Gitignored (~4 GB). An earlier
  version of the pipeline kept these at repo-root `input/`.
- `smoke_firm_dir/` — the active pipeline. All current scripts, notes, and results live
  here; treat this as the working copy.
  - `smoke_firm_dir/code/` — all R scripts, in subfolders, each file numbered by
    run order within its folder. `fxns/` — shared helpers sourced by everything
    (`1_paths.R` defines `FIRM_DIR`/`RAW_DIR`/`SUPPORT_DIR`/`OUT_DIR`/`PRELIM_DIR`;
    `2_upc_overrides.R`, `3_t2_classify.R`, `4_event_lines_t2.R`). `build/` — raw
    → panels (`3_build_t2_panel_niccorr.R` writes the canonical panel;
    `5_build_upc_month_niccorr.R` the UPC-month one; `1_clean_RMS…` runs on the BU
    SCC and its output is pre-supplied). `analysis/` — panel → meeting-note
    figures. `manual_refinement/` — one-off nicotine/VUSE audits whose findings are
    already baked into `input/manual_nic_corrections.csv` and `fxns/2_upc_overrides.R`;
    provenance, not re-run. `archive/` — superseded pre-niccorr builders/decomps.
    `code_from_demand_side/` — demand-side scripts kept for reference. Every script
    is run from the repo root and starts with
    `source("smoke_firm_dir/code/fxns/1_paths.R")`. See `code/README.md`.
  - `smoke_firm_dir/input/` — small support files: `manual_nic_corrections.csv`,
    `label_maps.RData`, imputation caches, and the built panels.
    `bt_month_t2_niccorr_from_full.RData` is the current corrected panel
    (brand × type × month). `upc_month_niccorr_from_full.RData` is the matching
    brand × UPC × month panel (built by `code/build/5_build_upc_month_niccorr.R`;
    collapses back to `bt_month_t2` exactly). `bt_month_t2_from_full-do_not_use_has_incorrect_nic.RData`
    is the old panel with the cartridge-scaling bug — kept only for old-vs-new
    comparison, never use it for new analysis.
  - `smoke_firm_dir/output/` — all figures, tables, and written notes (`personal_notes/`,
    `marc_meeting_notes/`, `ariel_meeting_notes/`) produced from the pipeline.
  - `smoke_firm_dir/handoff_files/` — migration and cleaning handoff docs.
    `MIGRATION_HANDOFF_2026-08-21.md` has the nicotine-correction methodology and
    the required script rebuild order — read it before rerunning or modifying the
    panel-building scripts. Also holds `MIGRATION_DOWNLOAD_MANIFEST_2026-08-21.md`,
    `HANDOFF_nicotine_cleaning_2026-08-10.md`, and `handoff_aug_21_2026/` (the
    original migration bundle and provenance screenshots from a prior Claude
    session — kept for audit trail only).
  - `smoke_firm_dir/raw/manual_added_upc/` — manually assembled UPC/label reference
    data, used by the cleaning scripts.
  - `smoke_firm_dir/raw/cleaned_RMS/` — the cleaned raw `full_*` files (see the
    top-level bullet); `RAW_DIR` in `fxns/1_paths.R`.
  - `smoke_firm_dir/literature/` — reference papers.
  - `smoke_firm_dir/meeting_notes_not_presented/` — draft meeting notes not yet
    presented.
- `archive/legacy_pre_claude/` — deprecated exploratory code/output from
  before this project was migrated to the current pipeline (including the old
  FDA exploration under `raw/fda/` and `output/prelim_analysis_fda/`). Reference
  only; do not build on it or treat it as current.

Key facts to carry forward:

- The corrected nicotine identity is `nic_yield_total = liquid_total_mL *
  clean_label_mg_per_mL * 0.68` (`YIELD_FACTOR` in `smoke_firm_dir/code/fxns/2_upc_overrides.R`).
  Cartridge count cancels from delivered concentration — never try to fix
  this via `nic_yield_per_cart_f`, which is itself mis-scaled.
- The corrected panel (`smoke_firm_dir/input/bt_month_t2_niccorr_from_full.RData`) was
  independently rebuilt from the raw `full_*` files and validated cell-by-cell
  against the documented national `N_hom` figures — the pipeline reproduces
  end to end (verified 2026-08-27, re-verified after the code reorg 2026-08-27).

Known gotchas:

- `code/build/3_build_t2_panel_niccorr.R` and `code/manual_refinement/2_upc_audit.R`
  both write to
  `smoke_firm_dir/output/prelim_analysis/investment_proxy/top5_upc_per_year.csv` with
  different, incompatible schemas. Whichever runs last wins. Run the panel
  builder before the audit script, and don't assume that file reflects the audit
  format unless `2_upc_audit.R` ran last.
- Installed `ggplot2` is 3.4.0, which does not have `scale_linewidth_manual()`
  despite it appearing in some online examples for this version. Map a fixed
  `linewidth` in `geom_line()` instead of via `aes()` when both branches use
  the same width.

## General Rules

- Confirm the target repo or folder before making edits if the request is
  ambiguous.
- Keep changes scoped to the user's request.
- Avoid unrelated cleanup.
- Before making substantial changes, inspect the relevant existing code and
  this file.
- Do not overwrite `smoke_firm_dir/input/bt_month_t2_niccorr_from_full.RData`, or any
  other canonical panel, without an explicit user decision and a backup.
