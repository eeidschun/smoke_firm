# Project Instructions

## Repositories

### smoke_firm

E-cigarette industry supply-side research (economics PhD project) using Nielsen
retail scanner data.

Structure:

- `input/` — raw annual Nielsen RMS files, `full_*_7467_*.RData` (one per year,
  2013–2023). Source of truth for the e-cig category; do not edit by hand.
  Excluded from git via `.gitignore` (~2 GB).
- `pr/` — the active pipeline. All current scripts, notes, and results live
  here; treat this as the working copy.
  - `pr/input/` — small support files: `manual_nic_corrections.csv`,
    `label_maps.RData`, imputation caches, and the built panels.
    `bt_month_t2_niccorr_from_full.RData` is the current corrected panel.
    `bt_month_t2_from_full.RData` is the old panel with the cartridge-scaling
    bug — kept only for old-vs-new comparison, never use it for new analysis.
  - `pr/output/` — all figures, tables, and written notes (`personal_notes/`,
    `marc_meeting_notes/`, `ariel_meeting_notes/`) produced from the pipeline.
  - `pr/MIGRATION_HANDOFF_2026-08-21.md` has the nicotine-correction
    methodology and the required script rebuild order — read it before
    rerunning or modifying the panel-building scripts.
- `archive/legacy_pre_claude/` — deprecated exploratory code/output from
  before this project was migrated to the current pipeline. Reference only;
  do not build on it or treat it as current.
- `raw/manual_added_upc/` — manually assembled UPC/label reference data, used
  by the cleaning scripts. Other `raw/` subfolders (e.g. FDA exploration) are
  not part of the current research.
- `handoff_aug_21_2026/` — the original migration bundle and provenance
  screenshots from a prior Claude session. Kept for audit trail only.

Key facts to carry forward:

- The corrected nicotine identity is `nic_yield_total = liquid_total_mL *
  clean_label_mg_per_mL * 0.68` (`YIELD_FACTOR` in `pr/upc_overrides.R`).
  Cartridge count cancels from delivered concentration — never try to fix
  this via `nic_yield_per_cart_f`, which is itself mis-scaled.
- The corrected panel (`pr/input/bt_month_t2_niccorr_from_full.RData`) was
  independently rebuilt from the raw `input/` files and validated cell-by-cell
  against the documented national `N_hom` figures — the pipeline reproduces
  end to end (verified 2026-08-27).

Known gotchas:

- `pr/build_t2_panel_niccorr.R` and `pr/upc_audit.R` both write to
  `pr/output/prelim_analysis/investment_proxy/top5_upc_per_year.csv` with
  different, incompatible schemas. Whichever runs last wins. Run the panel
  builder before the audit script (per the handoff's rebuild order), and
  don't assume that file reflects the audit format unless `upc_audit.R` ran
  last.
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
- Do not overwrite `pr/input/bt_month_t2_niccorr_from_full.RData`, or any
  other canonical panel, without an explicit user decision and a backup.
