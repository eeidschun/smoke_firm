**Migration Summary**:
- The migration bundle `handoff_aug_21_2026/PR_ECIG_MIGRATION_BUNDLE_2026-08-21/pr/` contains the authoritative corrected T2 panel scripts and documentation.
- I copied the core R scripts and handoff notes (text files only) into top-level `pr/` for convenience.

**What I DID (non-destructive)**:
- Created `hand_off_archive/` to hold the original bundle.
- Created `pr/` at repo root and copied key text scripts and handoff docs there.
- Did NOT move or modify any binary files (`*.RData`, `*.rds`) — those remain in the original bundle under `handoff_aug_21_2026/.../pr/input/`.

**Next recommended manual steps (because RData/rds are binary)**:
1. Move `handoff_aug_21_2026/PR_ECIG_MIGRATION_BUNDLE_2026-08-21/pr/input/*` -> `pr/input/` (user action; large binaries).
2. After step 1, run the corrected-panel rebuild:

```bash
Rscript pr/build_t2_panel_niccorr.R
Rscript pr/upc_audit.R
Rscript pr/decompose_t2.R
```

3. Review `pr/output/prelim_analysis/investment_proxy/niccorr_*` and `pr/output/prelim_analysis/p_and_n_decomp_t2/` figures.

**If you want, I can:**
- Move the binary files for you (I can copy the metadata/text files now; moving RData binaries requires user confirmation because of size and potential duplication).
- Produce a script to copy/verify checksums for binary files before deleting originals.

No canonical panel was overwritten. If you want me to continue (copy binaries, archive duplicates, or delete old files), tell me which of those to execute.

## Short handoff note for the next Claude run

This repo is a cleaned-up migration of the old e-cigarette supply-side work. The authoritative raw data live in `input/` as `full_*7467*.RData`; the handoff support artifacts (`manual_nic_corrections.csv`, `label_maps.RData`, imputation cache, etc.) live in `pr/input/`. The legacy exploratory work and old pre-Claude script folders were archived under `archive/legacy_pre_claude/`, so the active workflow is now the `pr/` pipeline plus the repo-root raw data.

Key facts to preserve:
- The corrected nicotine work is the relevant branch; the old canonical panel in `pr/input/bt_month_t2_from_full.RData` is still a comparison object, not the final corrected one.
- The corrected script target is `pr/build_t2_panel_niccorr.R`, which should read raw files from `input/` and support files from `pr/input/`.
- The key corrections are the cartridge-scaling fix and the nicotine yield identity `liq_total * clean_label * 0.68`.
- Do not overwrite the old canonical panel until the corrected panel is validated and the outputs are checked.
- The current priority is to reproduce the pre-Claude corrected-panel and audit outputs from the real raw annual files and then regenerate the downstream analysis figures.