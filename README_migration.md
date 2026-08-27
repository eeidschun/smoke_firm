> **Layout note (2026-08-27):** the repo was reorganized after this log was
> first written. Everything the active project needs now lives under
> `smoke_firm_dir/`: R scripts in `smoke_firm_dir/code/`, support files and built
> panels in `smoke_firm_dir/input/`, results in `smoke_firm_dir/output/`, and all
> handoff docs (including the original migration bundle and screenshots) in
> `smoke_firm_dir/handoff_files/`. Paths below have been updated to match.

**Migration Summary**:
- The migration bundle `smoke_firm_dir/handoff_files/handoff_aug_21_2026/PR_ECIG_MIGRATION_BUNDLE_2026-08-21/smoke_firm_dir/` contains the authoritative corrected T2 panel scripts and documentation.
- The core R scripts were copied into `smoke_firm_dir/code/` and the handoff notes into `smoke_firm_dir/handoff_files/`.

**What was done (non-destructive)**:
- Kept the original bundle intact under `smoke_firm_dir/handoff_files/handoff_aug_21_2026/`.
- Moved the working scripts, support files, and outputs into `smoke_firm_dir/` (`code/`, `input/`, `output/`).
- The built panels and imputation caches now live in `smoke_firm_dir/input/` (`bt_month_t2_niccorr_from_full.RData` is the current corrected panel).

**Corrected-panel rebuild:**

```bash
Rscript smoke_firm_dir/code/build_t2_panel_niccorr.R
Rscript smoke_firm_dir/code/upc_audit.R
Rscript smoke_firm_dir/code/decompose_t2.R
```

Then review `smoke_firm_dir/output/prelim_analysis/investment_proxy/niccorr_*` and `smoke_firm_dir/output/prelim_analysis/p_and_n_decomp_t2/` figures.

No canonical panel was overwritten during the migration.

## Short handoff note for the next Claude run

This repo is a cleaned-up migration of the old e-cigarette supply-side work. The authoritative raw data live in `input/` as `full_*7467*.RData`; the handoff support artifacts (`manual_nic_corrections.csv`, `label_maps.RData`, imputation cache, etc.) live in `smoke_firm_dir/input/`. The legacy exploratory work and old pre-Claude script folders were archived under `archive/legacy_pre_claude/`, so the active workflow is now the `smoke_firm_dir/` pipeline (scripts in `smoke_firm_dir/code/`) plus the repo-root raw data.

Key facts to preserve:
- The corrected nicotine work is the relevant branch; the old canonical panel in `smoke_firm_dir/input/bt_month_t2_from_full-do_not_use_has_incorrect_nic.RData` is still a comparison object, not the final corrected one.
- The corrected script target is `smoke_firm_dir/code/build_t2_panel_niccorr.R`, which should read raw files from `input/` and support files from `smoke_firm_dir/input/`.
- The key corrections are the cartridge-scaling fix and the nicotine yield identity `liq_total * clean_label * 0.68`.
- Do not overwrite the old canonical panel until the corrected panel is validated and the outputs are checked.
- The current priority is to reproduce the pre-Claude corrected-panel and audit outputs from the real raw annual files and then regenerate the downstream analysis figures.