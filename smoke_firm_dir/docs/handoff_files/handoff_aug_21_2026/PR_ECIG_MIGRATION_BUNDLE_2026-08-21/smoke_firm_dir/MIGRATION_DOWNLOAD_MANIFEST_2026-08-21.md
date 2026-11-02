# Download manifest — 2026-08-21

## Recommended: download one file

Download this bundle from the workspace root:

```text
PR_ECIG_MIGRATION_BUNDLE_2026-08-21.zip
```

It contains the `pr/` directory structure needed on the new computer, excluding the
eleven large raw `pr/input/full_*.RData` files that the user already has.

Bundle size: approximately 21 MB (210 files; roughly 26.5 MB uncompressed).

The bundle also contains the workspace-level `AGENTS.md` routing instructions.

## If downloading files individually

At minimum download these paths:

### Handoff and correction state

```text
pr/MIGRATION_HANDOFF_2026-08-21.md
pr/HANDOFF_nicotine_cleaning_2026-08-10.md
pr/input/manual_nic_corrections.csv
pr/input/label_maps.RData
pr/input/missing_mL_imputation_map.rds
pr/input/t2_impute_cache.rds
pr/input/bt_month_t2_niccorr_from_full.RData
pr/input/bt_month_t2_from_full.RData
```

### Rebuild and analysis code

```text
pr/build_t2_panel_niccorr.R
pr/upc_audit.R
pr/t2_classify.R
pr/upc_overrides.R
pr/impute_missing_mL.R
pr/build_cart_counts_t2.R
pr/decompose_t2.R
pr/hhi_concentration_t2.R
pr/tracked_volume_t2.R
pr/disposable_share_vs_cdc_t2.R
pr/disposable_share_cdc_standardized.R
pr/event_lines_t2.R
pr/investment_proxy_t2.R
pr/brand_nicotine_trajectories_t2.R
pr/rebuild_corrected_requested_figures.R
```

### Finished deliverable

```text
pr/output/marc_meeting_notes/08_10_2026_ecig_brand_dynamics_note_ai.md
pr/output/marc_meeting_notes/08_10_2026_ecig_brand_dynamics_note_ai.pdf
pr/output/marc_meeting_notes/closed_pod_sm.png
pr/output/marc_meeting_notes/disposable_sm.png
pr/output/marc_meeting_notes/open_refill_sm.png
```

### Current outputs

Download these directories in full if possible:

```text
pr/output/prelim_analysis/p_and_n_decomp_t2/
pr/output/prelim_analysis/investment_proxy/
pr/output/prelim_analysis/t2/
pr/output/marc_meeting_notes/
```

The single ZIP is preferred because it also preserves supporting scripts, diagnostics,
and other current notes with their relative paths.
