# Session handoff — 2026-08-27 → 09-01

For a fresh Claude Code session on the other machine. Everything described below
is committed as `7c6ed19 "fringe firm analysis"` on `master` (pushed to
`origin` = `github.com/eeidschun/smoke_firm.git`); the working tree was otherwise
clean at end of session (this handoff file itself is the only new addition).

This session did three things:

1. Brought `CLAUDE.md` / `README_migration.md` up to date after the `pr/` →
   `smoke_firm_dir/` folder rename.
2. **Restructured `smoke_firm_dir/code/` into numbered subfolders and fixed every
   script's paths** (they were all broken by the earlier rename). This is the
   biggest change — read §3.
3. Produced two analysis notes for the EBE supply-side model:
   `08_27_2026_ecig_firm_dynamics_diagnostics_ai` (items 7.1/7.2/7.4/7.5) and
   `09_01_2026_ecig_2021_entry_wave_coverage_check_ai` (verifying the 2021
   entry-wave hypothesis before specifying the fringe arrival process).

---

## 1. Get set up on this machine

- `git pull` (should fast-forward to `7c6ed19` or later).
- **Raw data is not in git.** `smoke_firm_dir/raw/cleaned_RMS/full_*_7467_*.RData`
  (11 files, 2013–2023, store×week×UPC, ~2 GB) is gitignored. Either the Google
  Drive sync of `.../synced_to_GD/PhD/pr/smoke_firm/` carries it, or copy the
  folder from the other machine. The build/audit scripts (`build/2–5`,
  `manual_refinement/1–2, 7`) need it; the `analysis/` scripts do not (they read
  the committed panels).
- **Built panels ARE committed** (they're small): `input/bt_month_t2_niccorr_from_full.RData`
  (canonical brand×type×month), `input/upc_month_niccorr_from_full.RData`
  (brand×UPC×month), `input/entry_wave_store_cache.rds`.
- R environment used: **R 4.2.2**; `ggplot2 3.5.1`, `data.table 1.17.4`,
  `fixest 0.11.2`, `patchwork 1.3.0`, `dplyr 1.1.4`, `tidyverse`, `lubridate`,
  `readxl`, `zoo`. (Note: CLAUDE.md's "ggplot2 is 3.4.0, no `scale_linewidth_manual`"
  gotcha did **not** hold here — 3.5.1 was installed. Still safest to set fixed
  `linewidth=` outside `aes()`.)
- Reading the large raw files off the synced drive is **slow** (~1–2 min per
  file just to `load()`); a full raw pass is 10–20 min. `build/5` and the entry
  scripts use `data.table` and a first-stage collapse to keep memory sane; the
  older `dplyr`-based builders (`build/3`) use ~12 GB RAM and take ~20 min.

---

## 2. Documentation updated this session

- `CLAUDE.md` — code-folder layout, canonical raw location
  (`smoke_firm_dir/raw/cleaned_RMS/`, was repo-root `input/`), the new
  `upc_month_niccorr_from_full.RData` panel, gotcha script paths, `YIELD_FACTOR`
  path.
- `smoke_firm_dir/code/README.md` — **new**; the authoritative map of the code
  folder (run order, path constants, per-folder tables). Read this first when
  touching pipeline code.
- `smoke_firm_dir/handoff_files/MIGRATION_HANDOFF_2026-08-21.md` — added a
  2026-08-27 reorg note and rewrote the "Rebuild order" block with new paths.
- `README_migration.md` (repo root) — path references updated for the reorg.
- `.gitignore` — added `smoke_firm_dir/raw/cleaned_RMS/` and `full_*_7467_*.RData`.

---

## 3. Code reorganization (`smoke_firm_dir/code/`)

**Every script now runs from the repository root** and starts with:

```r
source("smoke_firm_dir/code/fxns/1_paths.R")
```

which defines `FIRM_DIR`, `CODE_DIR`, `FXN_DIR`, `SUPPORT_DIR` (= `input/`),
`OUT_DIR`, `PRELIM_DIR` (= `output/prelim_analysis/`), `RAW_DIR`
(= `raw/cleaned_RMS/`), and a helper `fxn("2_upc_overrides.R")`
(= `source(file.path(FXN_DIR, ...))`). Files are numbered by run order within
each subfolder.

```
code/
  README.md
  fxns/               1_paths.R  2_upc_overrides.R  3_t2_classify.R  4_event_lines_t2.R
  build/              1_clean_RMS_from_raw_to_most_detailed.R   (BU SCC only; output pre-supplied)
                      2_impute_missing_mL.R
                      3_build_t2_panel_niccorr.R                (writes the canonical panel)
                      4_build_cart_counts_t2.R
                      5_build_upc_month_niccorr.R               (writes upc_month_niccorr_from_full.RData)
  analysis/           1_decompose_t2.R … 9_ecig_type_schematics.R
                      10_ebe_diagnostics.R                      (08_27 note figures)
                      11_entry_wave_coverage_check.R            (09_01 note figures)
  manual_refinement/  1_nic_cartscale_fix.R … 6_vuse_nic_sanity.R   (VUSE/nicotine provenance, not re-run)
                      7_entry_wave_store_pass.R                 (raw store pass → input/entry_wave_store_cache.rds)
  archive/            1_build_t2_panel.R  2_decompose_p_and_n.R  3_decompose_p_and_n_t2.R   (pre-niccorr, superseded)
  code_from_demand_side/   (reference only, untouched)
```

**Verification done:** `build/3` was re-run end-to-end; the rebuilt canonical
panel matched the committed one to ~1e-11 (summation-order rounding only), and
the committed bytes were kept. All 10 `analysis/` scripts run clean on the new
layout.

**Naming note:** what was briefly `code/firm_dynamics_diagnostics.R` (mine) →
you renamed it `ebe_diagnostics.R` → it is now `analysis/10_ebe_diagnostics.R`.

---

## 4. Deliverable 1 — firm-dynamics diagnostics (08_27 note)

`smoke_firm_dir/output/marc_meeting_notes/08_27_2026_ecig_firm_dynamics_diagnostics_ai.md`
(+ `.pdf`). Figures/CSVs: `output/prelim_analysis/firm_dynamics_ebe/d1_…`–`d4_…`.
Code: `analysis/10_ebe_diagnostics.R` (needs `build/5` output).

Answers model-note items 7.1, 7.2, 7.4, 7.5 (7.3 and 7.6 deliberately deferred).
Monthly, national, `UNKNOWN` (~1.9% of mL) dropped from all firm statistics.

- **7.1 — does the cap of 5 bind?** No, not as a count of economically active
  firms. >5 brands hold >1% of national mL in 114/132 months; the >5% count is
  6–7 in the fragmented 2014–2018 era and 3 in the 2020–2023 duopoly. Fringe
  (below top-5) mL is 15–20% mid-decade, ~1% in 2020, ~6–9% after. → $\bar N=5$
  fine for a pod-era (2019+) calibration; for the full sample, raise $\bar N$ or
  add an explicit competitive fringe (which is what the 09_01 note follows up).
- **7.2 — entry/exit.** One-entrant-per-period holds through 2020 and breaks in
  2021 (see the 09_01 note — it's a coverage artifact). Of 6 meaningful top-5
  exits, 2 coincide with a dated corporate event (MarkTen, MISTIC), 4 look
  competitive. Big ownership shocks (BLU→Imperial, Altria→JUUL, Altria→NJOY)
  caused **no** exit near the event.
- **7.4 — learning-by-doing.** Pooled elasticity of real price/mL on cumulative
  own output is ≈ −0.02 (n.s.) once the market-wide trend is removed. Firm-by-firm:
  negative for all 8 cigalike-era brands, ≈ 0 for JUUL (+0.03), VUSE (−0.02),
  NJOY (−0.03). → if $a_{i,t}$ is a cost-reducing stock, it describes the
  cigalikes, not the pod leaders — consider a demand-side reading of $a_{i,t}$,
  or a cost channel identified off something other than price/mL.
- **7.5 — UPC-count dynamics + nicotine weighting.** UPC count is non-monotone in
  share (JUUL led with ≤25 SKUs; NJOY carries 66 and is #3); its biggest move is
  the Feb-2020 flavor-enforcement catalog cull. mL-sales-weighted vs
  UPC-unweighted delivered nicotine differ by ~3.9 mg/mL on average, 30–50% for
  VUSE/NJOY. → build the firm-level nicotine state from the **UPC-unweighted**
  series (Marc's instruction), keep the mL-weighted one only for the demand side.

---

## 5. Deliverable 2 — 2021 entry-wave coverage check (09_01 note)

`smoke_firm_dir/output/marc_meeting_notes/09_01_2026_ecig_2021_entry_wave_coverage_check_ai.md`
(+ `.pdf`). Figures: `output/prelim_analysis/firm_dynamics_ebe/entry_stores_vs_brands.png`,
`entry_trajectory_by_cohort.png`. Code: `manual_refinement/7_entry_wave_store_pass.R`
(raw pass → `input/entry_wave_store_cache.rds`) then
`analysis/11_entry_wave_coverage_check.R`.

**Question:** 27 brand-codes have a first tracked-sales month in calendar 2021
(vs 0–7/year otherwise). Is that real entry or an RMS coverage/taxonomy artifact?
It matters because a coverage artifact must be removed from the fringe's entry
margin, while real burst entry needs a burst-tolerant arrival process.

**Answer: almost entirely a data-visibility event, and NOT the "RMS added vape
shops" version.** Evidence:

1. **Trajectory.** 2021-cohort median brand records as much mL in its first RMS
   month as in a typical later month (ratio 1.00) vs 0.01 for clean genuine
   entrants (JUUL, VUSE, LEAP) and 0.21 for the 2022 cohort. Several come in
   *above* their eventual level (Bidi 9×, EPIC 21×). No diffusion ramp.
2. **Outlet coverage.** The RMS e-cig store panel did **not** expand — it
   collapsed ~50% at the Feb-2020 flavored-cartridge enforcement and kept
   shrinking. Dec-2020 → Jan-2021: stores 12,861 → 12,450 (down, ordinary
   churn), but distinct e-cig UPCs 224 → 336 (+50%), disposable brand-codes
   9 → 25, tracked units flat. The residual `UNKNOWN` brand bucket
   (~0.3–0.6M mL/mo) drops to **exactly 0.00** in Jan 2021. Same stores, finer
   brand resolution in the new Nielsen data delivery.
3. **Identity.** ~18 of 27 are products with documented pre-2021 market presence
   (Bidi Stick 2019, Puff Bar 2019, Hyde 2020, Stig 2018, HQD 2019, Air Bar 2020,
   Dinner Lady 2016, Von Erl 2015, …). Launch dates are secondary-source —
   verify before citing.
4. **Rebrand/reclassification.** UPC prefix `08526625` (the Puff Bar company) is
   split across `PUFF` / `KOMGE` / `MR VAPOR` / part of `HYPPE`. `PUUR VAPOR`
   carries `SAVAGE` UPCs (Savage then splits off as its own code in 2022).
   `VON ERL` shares a prefix with `BLU`. ≥4–6 of the 27 are code fragmentation.
5. **Timing.** Zero new codes in the 10 months after the Feb-2020 enforcement or
   the 4 months after the Sep-2020 PMTA deadline; then 15 in January 2021 —
   exactly the Nielsen extract seam (`nielsen_extracts/RMS` →
   `2021-Onward_Scanner_Data/...`, see `build/1`).

**For the fringe entry process:** don't feed the raw first-appearance series in.
Merge the code fragments; treat the 2021 cohort as one-time panel onboarding at
Jan 2021 (better: back-date into the fringe's *incumbent* stock from ~2020,
scaled to the CDC/IRI disposable-share benchmark the demand notes use). The
genuine arrival process — off 2013–2020 plus the 2022–2023 cohort — is a
low-rate Poisson process (~2–4 identified fringe brands/year), with no
regulatory-date jump once the artifact is removed. A burst-tolerant / regime-
switching arrival process is **not** warranted; the regulatory shocks act on the
fringe through *size/share*, not entry timing.

---

## 6. Where things stand / open items

- **Model context** lives in `smoke_firm_dir/meeting_notes_not_presented/08_27_2026-ai_attempt2_at_model_and_questions.md`
  (the current model write-up + the §7 diagnostics list). §7.3 (nicotine vs FDA
  event study) and §7.6 (ownership vs own-quality driver of turnover) are still
  deferred and were explicitly *not* done this session.
- **Next natural step** (per the user): actually specify the competitive fringe —
  its state, its arrival process (now informed by the 09_01 note), and how the
  regulatory shocks enter its aggregate state.
- **A companion data task** the 09_01 note recommends but did not do: build a
  "back-dated" fringe incumbent stock for 2019–2020 using the CDC/IRI disposable-
  share benchmark, so the fringe's share isn't under-counted before the panel
  caught up in 2021.
- **Data-quality items flagged for the model, not yet acted on:** the Feb-2020
  store-panel contraction is itself the enforcement's footprint in RMS; RMS
  brand-codes persist at trace volume long after a brand is a going concern
  (MISTIC "sells" through 2023); the mid-2019 open-refill clearance artifact; and
  modern-disposable channel undercoverage generally.
- **`build/1_clean_RMS_from_raw_to_most_detailed.R`** runs on the BU SCC against
  restricted Nielsen data and is provenance only — its output (`full_*` files) is
  the pre-supplied starting point.
