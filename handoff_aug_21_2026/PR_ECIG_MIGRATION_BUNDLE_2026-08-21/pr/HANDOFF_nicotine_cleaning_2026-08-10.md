# Handoff — e-cigarette nicotine data-cleaning (2026-08-10)

## 0. Purpose (why this cleaning exists)

The T2 e-cigarette panel (state-month × brand × T2 product-type, built from Nielsen RMS)
is being cleaned so it can serve as a **data input to a supply-side model** (the model
itself is out of scope here — this handoff is only about producing a trustworthy input).
The specific object being repaired is the **nicotine layer** (`N_hom` and delivered
`nic_mg_per_mL`). Market shares, the price index (`P_hom`), and all brand-dynamics
results are already sound; only nicotine was affected by a data bug.

---

## 1. The bug, and the fix (read this first)

**Bug.** For many multi-cartridge packs, the recorded delivered nicotine
(`nic_yield_tot_f`) holds roughly **one cartridge's** yield while the liquid volume
(`liq_total_f`) is the **whole pack** → delivered concentration is understated by ~the
cartridge count. Worst case: VUSE 4-count Alto pods read **~16–17 mg/mL in 2021–2023**
when the truth is **~28**.

**Fix (the key identity).** Delivered concentration = `label × 0.68` (0.68 =
`YIELD_FACTOR`, the transfer efficiency). Cartridge count and per-cart mL **cancel**, so
the robust recompute is:

```
nic_yield_tot_f  :=  liq_total × clean_label × 0.68
```

- This eliminates the cart-scaling bug entirely.
- It requires a **clean label**. The raw `nic_mg_per_ml_f` is corrupted for a subset of
  UPCs (mixed %/mg-per-mL units, e.g. "1.8" meaning 1.8% = 18 mg/mL; some missing; some
  capacity errors). Cleaning happens via `input/manual_nic_corrections.csv` (below).
- **Do NOT** use the derived `nic_yield_per_cart_f` field to "fix" this — it is itself
  mis-scaled (it overshoots JUUL to ~48 and undershoots NJOY to ~19). Use
  `liq_total × label × 0.68` only.

**Blast radius.** Only nicotine (`N_hom`, `nic_mg_per_mL`). **Unaffected:** mL shares,
concentration *ranking*, brand-dynamics, and `P_hom` (price) — these use `liq_total` /
price, which are fine. (One small exception: the Ciro/Vibe/Solo `liq_cart` fixes nudge
`avg_mL_per_ecig`, which is a term in both `P_hom` and `N_hom`, but the mL/share impact
measured <0.02%.)

**Retraction to carry forward:** an earlier claim that "VUSE won at unusually low
nicotine" was an artifact of this bug and is **false**. Corrected, VUSE is a
high-nicotine pod (~28 delivered / ~41 label), close to JUUL (~34 / 50). VUSE's rise is a
JUUL-collapse + Vuse Alto + convenience-retail story (trade-press sourced), not a
nicotine story.

---

## 2. What has already been done

- Diagnosed the bug; confirmed the fix mechanism.
- **VUSE fully re-labeled** (all high-volume SKUs + Ciro/Vibe/Solo family rules).
- **Audited other brands:** JUUL is fine (50/30 split is legit) except UPC
  `84004820296` (recorded 120@0.17 in 2021, missing 2020, correct 30@0.7 in 2022–23 —
  this one UPC caused the JUUL-2021 anomaly). MISTIC's low nicotine is **legitimate**
  (it's open-refill bottled juice at ~18–24 label, not a pod bug). Only tiny pod
  stragglers remain (LOGIC ~13.3, NJOY Ace 2023 ~12.6) — negligible volume.
- Built the **master corrections file** `input/manual_nic_corrections.csv` (21 label
  fixes across VUSE/BLU/JUUL/HAUS + 2 hardware exclusions), plus Ciro=15 / Vibe=30 /
  Solo=48 family rules applied in the build script.
- **Generalized the corrected-panel builder** (`build_t2_panel_niccorr.R`) to read that
  file and apply corrections across all brands + exclusions + `liq_cart` fixes.
- Wrote the corrected panel to a **new** file
  `input/bt_month_t2_niccorr_from_full.RData` (canonical panel left untouched).
- Regenerated the `investment_proxy` figures on the corrected panel (VUSE line now ~28).

**Measured impact of the correction (from the last build):**
- VUSE delivered nic 2021–23: `~16–17 → ~28`.
- National pooled delivered nic 2021–23: `~23–25 → ~29–31` (was understated ~6 mg/mL).
- All other top brands essentially unchanged (JUUL/NJOY/BLU/LOGIC/MISTIC).

---

## 3. Directory map

### Scripts (`pr/*.R`)
Core pipeline (build order):
- `clean_RMS_from_raw_to_most_detailed.R` — raw RMS → detailed (has the Cotti tax merge,
  state panel; heavy).
- `t2_classify.R` — the T2 taxonomy classifier (Closed pod / Disposable / Open refill).
- `upc_overrides.R` — manual UPC overrides, `YIELD_FACTOR = 0.68`, `EXCLUDE_UPCS`.
- `impute_missing_mL.R` — mL imputation.
- `build_t2_panel.R` — builds the **canonical** panel `bt_month_t2_from_full.RData`.
- **`build_t2_panel_niccorr.R`** — the corrected build: reads
  `manual_nic_corrections.csv`, applies fixes, writes `bt_month_t2_niccorr_from_full.RData`
  + prints old→new impact + top-UPC audit. **This is the one to re-run.**

Figures / analysis (consume a panel; produce the CSVs+PNGs the notes reference):
- `decompose_t2.R` — within-type `P_hom`/`N_hom` series → `national_monthly_series_by_type*`,
  `N_hom_by_type`, nicotine excerpt, etc.
- `decompose_p_and_n_t2.R` — pooled homogeneous-good decomposition.
- `hhi_concentration_t2.R` — HHI + annual brand concentration.
- `tracked_volume_t2.R` — tracked unit-sales figures (+ event lines).
- `disposable_share_vs_cdc_t2.R`, `disposable_share_cdc_standardized.R` — RMS vs CDC/IRI.
- `investment_proxy_t2.R` — ever-top-6 brand share vs nicotine / type-mix.
- `ecig_type_schematics.R`, `event_lines_t2.R` — helper figures / shared event-line layer.

Audit & diagnostics (safe to archive/delete once cleaning is committed):
- `upc_audit.R` — top-UPC-per-year + implausible-UPC audit (writes `all_upc_by_year.csv`,
  `top5_upc_per_year.csv`).
- `vuse_upc_check.R`, `vuse_nic_recompute.R`, `vuse_nic_corrected.R`, `vuse_nic_sanity.R`,
  `nic_cartscale_fix.R`, `build_cart_counts_t2.R` — one-off VUSE/nicotine investigations.

### Inputs (`pr/input/`)
- `full_*.RData` ×11 (2013–2023 raw RMS) — the source; each 60–380 MB.
- `bt_month_t2_from_full.RData` — **CANONICAL panel (still has buggy nicotine).**
- `bt_month_t2_niccorr_from_full.RData` — **corrected panel (nicotine fixed).**
- `manual_nic_corrections.csv` — **master corrections; extend this as more UPCs are audited.**
  Columns: `upc12, brand, true_label_mg_per_ml, true_mL_per_cart, exclude, descr, note`.
- `label_maps.RData`, `missing_mL_imputation_map.rds`, `t2_impute_cache.rds` — build support.

### Outputs (`pr/output/`)
- `prelim_analysis/p_and_n_decomp_t2/` — the figures + CSVs the **notes** embed.
- `prelim_analysis/investment_proxy/` — audit tables + investment figures. Notably
  `all_upc_by_year.csv` (per-UPC audit table, no raw pass needed to re-filter),
  `top5_upc_per_year.csv`, `niccorr_*` impact CSVs, `vuse_*` diagnostics.
- `prelim_analysis/t2/` — T2 build intermediates + `manually_corrected_vuse.xlsx`
  (the original VUSE lookup that seeded the corrections).
- `marc_meeting_notes/` — Prof. Marc (summary-stats note; Markov notes).
- `ariel_meeting_notes/` — Prof. Ariel (brand-dynamics note).
- `personal_notes/` — supply-side drafts (kept separate; not professor-facing).
- `archive/` — old pre-T2 run (superseded).

---

## 4. TODO — the remaining work

### Steps 1–3 — finish the corrected panel (re-run after any final corrections)
1. **Rebuild the corrected panel** (reads all corrections):
   ```
   Rscript pr/build_t2_panel_niccorr.R
   ```
   → writes `input/bt_month_t2_niccorr_from_full.RData` (~3 min, reads all raw).
2. **Review the printed impact** — national + per-brand old→new delivered nicotine
   (also saved to `output/prelim_analysis/investment_proxy/niccorr_*`). Sanity-check that
   only intended brands moved.
3. **Refresh the UPC audit**:
   ```
   Rscript pr/upc_audit.R
   ```
   Eyeball any remaining `implausible` rows (use the `mL_per_cart` column: ~10 mL/cart =
   legit low-nic bottle; ≤~2 mL/cart + low label = suspicious pod). Add any real pod
   errors to `manual_nic_corrections.csv` and repeat 1–3.

### Then — commit over the canonical panel and regenerate the notes (the intended goal)
4. **Commit corrected → canonical** (back up first; no version control here):
   ```
   cp input/bt_month_t2_from_full.RData input/bt_month_t2_from_full.BACKUP_2026-08-10.RData
   cp input/bt_month_t2_niccorr_from_full.RData input/bt_month_t2_from_full.RData
   ```
   This makes corrected nicotine the default for every downstream script — and the panel
   that will feed the supply-side model.
5. **Regenerate all figures on the corrected panel** (they load
   `bt_month_t2_from_full.RData`, so after step 4 they use corrected nicotine):
   ```
   Rscript pr/decompose_t2.R
   Rscript pr/decompose_p_and_n_t2.R
   Rscript pr/hhi_concentration_t2.R
   Rscript pr/tracked_volume_t2.R
   Rscript pr/disposable_share_vs_cdc_t2.R
   Rscript pr/disposable_share_cdc_standardized.R
   Rscript pr/investment_proxy_t2.R
   ```
   NOTE: `investment_proxy_t2.R` currently loads the `*_niccorr_*` file directly — after
   step 4, edit its `load(...)` line back to `bt_month_t2_from_full.RData` so everything
   reads one canonical source.
6. **Regenerate the notes in `marc_meeting_notes/` and `ariel_meeting_notes/`.** The notes
   embed the figures in `../prelim_analysis/p_and_n_decomp_t2/`, so step 5 refreshes their
   charts automatically; then **re-render the note PDFs** (whatever markdown→PDF renderer
   you used — it honors inline `<style>`/`<img>`, so not pandoc). Only the
   nicotine/`N_hom` charts change; mL-share and `P_hom` charts are unchanged.

---

## 5. Open decisions / optional
- **HAUS → MISTIC brand mapping.** HAUS bottles (e.g. `85570400806/807`) currently
  classify as brand `UNKNOWN`; their nicotine label is fixed, but if HAUS should count
  under MISTIC's share, add a brand mapping (separate from the nicotine fix).
- **Tiny pod stragglers** (LOGIC ~13.3, NJOY Ace 2023 ~12.6) — add to corrections if you
  want them exact; volume is negligible.
- **JUUL nicotine convention = 50 mg/mL for 5%** (confirmed; the earlier "59" was a typo).
- Consider adding a plausibility flag in the build that lists any post-recompute UPC whose
  implied label is outside {sensible set} so future audits are automatic.

---

## 6. One-line status
Corrections captured and the corrected panel builds cleanly to a **new** file; nothing
canonical has been overwritten yet. Remaining work = run steps 1–3, then commit (step 4)
and regenerate figures + notes (steps 5–6).
