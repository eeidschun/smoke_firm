# Handoff: advisor follow-up, price aggregation, instruments and outside option

Updated: 2026-10-20. This records the current conversation and supplements [the 2026-10-08 handoff](../handoff_sigma_market_size_2026-10-08.md). Start with both before resuming demand work.

## Current objective and status

Understand nested-logit IV sigma > 1 and prepare a record for the next advisor meeting. No demand specification has been selected for supply-side cost recovery. Do not constrain or clip sigma to obtain admissibility. A number of new price/instrument specifications have admissible point estimates, but this does not establish instrument validity or a suitable demand specification.

The latest completed work is a category-term reduced-form diagnostic. It explains the coefficient relationships behind sigma > 1 but does not identify the underlying economic/statistical cause. The user has not authorized a new market-size definition or a raw-data rebuild.

## Essential conventions and constraints

- Demand: `y_it = alpha*p_it + beta_a*a_it + sigma*ln_s_i_g + controls + firm FE + error`, with an intercept where appropriate. Signed alpha is expected negative; maintained sigma range is `0 <= sigma < 1`.
- Current original price `p_it` is the equal-UPC mean of real revenue/mL. A separate volume-weighted price has now been constructed; it has not replaced the original canonical price.
- Baseline original sample: 540 incumbent firm-months. Original matched 48-model grid: 528 rows, excluding all BLU 2018 rows for unresolved device size. No incomplete-UPC mean or size imputation.
- Original grid: B (nicotine only), S (+ device size), V (+ log UPC variety), SV (both); national/geographic active-brand count; with/without firm FE; annual/monthly/constant-intensity market size. All control groups in this grid use the same 528 rows.
- Original instruments: geographic population-weighted tax and national or geographic active-brand count. Counts include fringe and focal brands. Tax was held fixed when changing price aggregation.
- Month-clustered standard errors, no month FE. Full month FE would create the documented single-nest degeneracy, not a routine omitted-FE comparison. Month clustering does not address dependence across months.
- Reviewed retail volume corrections are already rebuilt and validated. Do not repeat the expensive raw rebuild. Preserve the separate NCP household input by explicit user instruction.
- The user asked to leave Markdown files unchanged while experimenting with outside shares. All outside-option experiments and the category-term diagnostic respected this: results are CSV/RDS/TXT, not inserted into meeting notes. This handoff is explicitly authorized.
- The current meeting document is [advisor_meeting_work_log.md](../meetings/advisor_meeting_work_log.md). It is for the NEXT meeting; do not repopulate it with all earlier investigations already discussed with the advisor. Its current content covers the new price and instrument work. The new outside-option work is only in this handoff and its result files so far.

## 1. Quantified price-times-volume versus observed revenue

Advisor asked how far the original representative price times firm volume is from revenue.

Reconstructed eligible UPC-month prices and firm totals from existing corrected panels, preserving filters (known brand, positive units/mL, at least three reporting stores; collapse T2 rows before UPC pricing). Reconstruction matches saved incumbent price, volume and revenue for all 540 rows.

| Measure | 540 incumbent firm-months, 2013-2023 |
|---|---:|
| Observed real revenue | $4.757 billion |
| Original representative price times volume | $7.162 billion |
| Net overstatement | $2.405 billion / 50.56% |
| Sum absolute dollar gaps / observed revenue | 52.53% |
| Median signed firm-month gap | +35.17% |
| Middle 50% of signed gaps | +2.33% to +61.25% |
| Full range | -42.98% to +186.06% |
| Overstating / understating observations | 419 / 121 |

VUSE and JUUL contribute the largest dollar gaps. Matched 528-row net overstatement: 51.23%. Totals span the full period and refer to eligible scanner sales, not annual or total-industry revenue.

Constructed `p_it_volume_weighted = sum_u(q_u*p_u)/sum_u(q_u) = firm real revenue/firm mL`, using liquid-volume weights, not revenue or package-count weights. It recovers observed eligible revenue to numerical precision for every eligible brand-month.

- Script: `code/2_preliminary_analysis/16_price_revenue_comparison.R`.
- Both prices and gaps: `input/price_measures_firm_month.rds` and `output/prelim_analysis/price_revenue_comparison/brand_month_prices_and_revenue.csv`.
- Summary, firm/year breakdowns, largest discrepancies: `output/prelim_analysis/price_revenue_comparison/`.
- The canonical demand builder `code/1_build_data/8_build_firm_month_demand_panel.R` now includes the additional price column on FUTURE runs. It was not run for this comparison; existing canonical panel was not overwritten.

Important discussion: revenue recovery is an accounting property, not proof of a superior demand price. The user's original objection to volume weights is that realized sales enter both the share outcome and price construction. Demand-driven UPC composition and shared quantity measurement error are concerns. The unweighted price removes firm sales-share weights but still uses UPC revenue/mL. More admissible sigma under volume weighting does not settle this objection.

The user asked whether volume-weighted price requires volume-weighted tax. Answer: no automatic requirement; the variables serve different purposes. Current tax remains population-weighted over operating states to isolate price-definition sensitivity. Contemporaneous sales-weighted tax could introduce endogenous weights. No alternative tax series was constructed.

## 2. Advisor-requested instruments and quality treatment

New proposed instruments:

1. Annual incumbent count: annual eligible mL share strictly >7%; counts range 3-6.
2. Monthly count: brands with eligible monthly mL share strictly >7%; range 3-7. This changes only the instrument, NOT the annual demand roster.
3. One-calendar-month lag of quality, confirmed by user to mean `a_it` (UPC-unweighted delivered nicotine mg/mL). Build from eligible UPC history, including pre-incumbency months, not previous observed incumbent row. No imputation.

Critical clarification: counting active sellers from the EXISTING ANNUAL incumbent roster each month produces exactly the annual count here, since all annual incumbents sell in all 12 months. This duplicate is NOT the original all-active-brand count, which includes fringe. Do not conflate those series. The monthly threshold alternative is an explicitly separate construction.

User confirmed running BOTH price measures on comparable samples. Tested replacements for active-brand count and additions to national/geographic count sets, plus combinations; geographic tax retained throughout. There are 19 exogenous-quality instrument sets. Full names are in result specifications/index files.

Quality treatment matters:

| Treatment | Joint endogenous regressors | Example excluded set | Over-ID df |
|---|---|---|---:|
| Exogenous quality | Price, within-nest share | Tax + incumbent count | 0 |
| Exogenous quality | Price, within-nest share | Tax + active-brand count + incumbent count | 1 |
| Exogenous quality | Price, within-nest share | Tax + incumbent count + lag quality | 1 |
| Endogenous quality | Price, within-nest share, current quality | Tax + incumbent count + lag quality | 0 |
| Endogenous quality | Price, within-nest share, current quality | Tax + active-brand count + incumbent count + lag quality | 1 |

All instruments enter jointly, not assigned exclusively to particular regressors. Tax + lag alone is underidentified for three endogenous regressors and was not fitted with endogenous quality. Current quality remains in demand in every specification. Size and variety remain exogenous where included. No overidentification tests have been run; df only count restrictions. Lag quality may correlate with persistent demand shocks, and contemporaneous share-threshold counts require an exclusion argument.

### Run coverage and files

- Initial advisor comparison: 224 fits, B and SV only, annual market size, two prices, with/without FE; B used the larger available sample. Script `10_advisor_instruments.R`; validation `11_validate_advisor_instruments.R`. Results `output/demand_estimation/advisor_instruments_2026-10-20/`.
- Expanded original design: 1,344 exogenous-quality fits. Four control sets x two FE choices x two prices x three market sizes. Nine nonlag sets on 528 rows give 432 fits; all 19 sets on the 524-row common-lag sample give 912. Script `12_advisor_48_grid.R`; table rendering `13_advisor_grid_tables.R`; results subfolder `original_48_grid/`.
- Endogenous quality: 432 fits, nine sufficiently identified lag-containing sets on 524 rows, same four controls/two FE/two prices/three market sizes. Script `14_endogenous_quality_grid.R`; results subfolder `endogenous_quality_grid/`.
- Combined expanded grid: 1,776 fits. Do not add the earlier 224 to this total; overlapping designs and different sample conventions make that misleading.
- Common-lag sample drops four January 2013 incumbent rows lacking December 2012 quality, in addition to existing BLU 2018 size exclusions: 524 rows, 131 months.
- Meeting appendix/index: `docs/meetings/demand_results_appendix.md`, `demand_specification_index.csv`; generated by `15_meeting_results_appendix.R`.
- Every row explicitly identifies price, controls, FE, market size, full excluded instrument list and identification status. Tables show clustered SEs. No need to infer instrument sets from abbreviated labels.
- Original 48 baseline coefficients/covariances reproduce. All new fits passed explicit-dummy QR slope/residual checks; SW conditional F checks use two or three endogenous regressors as appropriate. All original inputs/fits preserved.

### Qualifying sigma families

User requested families of runs with STRICT `0 < sigma < 1` rather than selected illustrative rows. `16_admissible_families.R` generates the meeting interpretation section and `sigma_between_zero_and_one.csv`, `sigma_family_counts.csv`, `sigma_family_summary.md` under `docs/meetings/`.

357 of 1,776 runs qualify; 354 also have negative alpha. These counts include deliberate sample-matched repetitions, not independent evidence.

| Price / FE | Qualifying / total |
|---|---:|
| Volume weighted, no firm FE | 232 / 444 |
| Volume weighted, firm FE | 83 / 444 |
| Unweighted, no firm FE | 35 / 444 |
| Unweighted, firm FE | 7 / 444 |

- 297 include annual incumbent count (possibly with other instruments), 55 monthly count without annual count, remaining 5 tax + lag only. The five lag-only runs belong to a weak-instrument family; do not interpret their admissible point estimates as a resolution.
- No original tax + active-brand-count-only model qualifies, even when supplemented only with lag quality, under either quality treatment.
- 171 qualifying runs omit lag; 186 include it. Lag is not necessary.
- Quality exogenous: 260/1,344; endogenous: 97/432. Lag is included by construction in all endogenous-quality runs.
- Controls B/S/V/SV: 64/80/90/123 qualifying, each out of 444.
- Market size annual/monthly/constant: 118/133/106 qualifying, each out of 592.
- Admissibility refers only to the point estimate; it does not require intervals inside (0,1), a positive quality slope, or adequate identification.

Example, both controls + FE + annual market size + common-lag sample: tax + annual count + lag gives weighted-price sigma 0.213 (SE 0.357) with quality exogenous, versus 0.140 (SE 0.398) with quality endogenous. The latter quality slope is -0.0406 (SE 0.0303), also requiring scrutiny.

## 3. Outside-option sensitivity: original 48 models only

Advisor requested manually reducing outside share to see whether sigma falls. These exercises deliberately return to the ORIGINAL 48 designs: UPC-unweighted price, current quality exogenous, original geographic tax and national/geographic ACTIVE-BRAND counts, four control groups, with/without FE, three original market-size variants. They do NOT cover all 1,776 expanded fits.

All retain original 528 rows, 132 month clusters, liquid quantities, within-nest shares, controls and instruments. First stages unchanged. Only market size, outside shares and demand outcome change. No denominator is adopted as an economically justified replacement. User requested no Markdown changes during these toggles.

### A. Fixed outside share every month: 90% and 80%

`17_forced_outside_share.R`; results `output/demand_estimation/forced_outside_share/`.

Set `M_new=Q/(1-s0)`. All 48 sigma estimates equal 1 at either level, other slopes zero up to rounding. This is mechanical:

`y = ln_s_i_g + log((1-s0)/s0)`.

When s0 is constant, its term is an intercept. Tiny residuals/SEs reflect an identity, not precision. Three original market labels duplicate identical forced outcomes. This exercise cannot test an economic monotonicity claim.

### B. Scale each M series to mean outside share of 90% or 80%

`18_average_outside_share.R`; results `output/demand_estimation/average_outside_share/`.

Multiply each existing M by `c=mean_month(Q/M)/(1-target)`, weighting 132 MONTHS equally, not firm-month rows. Preserves M's relative temporal shape. Every month's outside share remains positive, but may be far from its mean.

ALL 48 sigma estimates increase at both targets: changes +0.101 to +0.285 (90%), +0.227 to +0.675 (80%). Example SV3 annual: 2.186 -> 2.298 -> 2.442. Annual outside shares range 71.0-97.1% at 90% mean and 42.0-94.1% at 80% mean. Thus reducing mean outside share by constant scaling does not lower sigma here.

### C. Map outside shares into strict bands, preserving ordering

`19_bounded_outside_share.R` accepts bound pairs, e.g.:

`Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/19_bounded_outside_share.R 0.10 0.20 0.03 0.05`

For each original market-size series independently, map original outside share affinely by its min/max into `[lower+0.001, upper-0.001]`; margin is 0.1 percentage point. This preserves month ranking and relative spacing of OUTSIDE SHARES, not M's original temporal shape. Recompute M as Q/(1-new outside share); even the annual-baseline variant now has monthly M variation. This is a chosen diagnostic transformation, not uniquely implied by the requested bounds. Means are not forced to band midpoints.

| Requested band | Actual bounds | Sigma range across original 48 | Below 1 |
|---|---|---:|---:|
| 80-90% | 80.1-89.9% | 1.289-1.890 | 0 |
| 60-70% | 60.1-69.9% | 1.144-1.460 | 0 |
| 30-40% | 30.1-39.9% | 1.135-1.442 | 0 |
| 10-20% | 10.1-19.9% | 1.219-1.753 | 0 |
| 3-5% | 3.1-4.9% | 1.136-1.463 | 0 |
| 0.5-1.5% | 0.6-1.4% | 1.216-1.770 | 0 |

Original first two bands: `output/demand_estimation/bounded_outside_share/`. Further invocations use subfolders `60_70__30_40/`, `10_20__3_5/`, and `0.5_1.5/`. Each has comparison, coefficients, monthly series, bound checks, hashes, models and TXT interpretation. A first invocation rounded the decimal band name to `0_2`; that duplicate is superseded by the correctly labeled `0.5_1.5/` results. Script labeling was fixed to retain decimal percentages.

ALL band-mapped estimates are lower than their original estimates but remain above 1. Moving the band downward is not monotonic; band width also matters. Compressing outside-share variation moves y toward within-nest log share plus a constant, so sigma approaching 1 is not itself evidence of corrected market definition. Preserve this qualification.

### Theory clarified with the user

A negligible outside-share LEVEL does not imply sigma below 1. With a constant outside share at ANY level, sigma=1 mechanically in this linear relationship. A tiny but varying outside share retains variation in `log((1-s0)/s0)`.

The outside option permits leaving the modeled category; a large outside share does not itself force within-category switching. Sigma governs substitution concentration within the nest under the maintained model. These exercises changed constructed denominators while holding purchases fixed; they did not simulate consumer switching. Earlier language suggesting that lowering outside share should generally lower sigma was explicitly corrected as too strong. None of these exercises validates market size or rules out market-definition misspecification.

## 4. Latest diagnostic: category term vs instruments and first stages

User asked what else could cause sigma >1 despite tiny outside shares. Proposed possible instrument/exclusion issues, outside-share TIMING, product aggregation, influential firms/years, and restrictive demand structure. None established. Suggested a category-term diagnostic, and user authorized running it.

Completed `code/3_demand_estimation/20_category_term_diagnostic.R`.

Results: `output/demand_estimation/category_term_diagnostic/`:

- `reduced_forms_and_first_stages.csv`: price, share, category-term and demand reduced-form regressions for every original 48 design AND the corresponding 48 tiny-outside-share designs (96 designs, 384 auxiliary regressions).
- `instrument_decomposition.csv`: instrument coefficient identity and inverse-first-stage weights mapping into sigma-1.
- `joint_instrument_tests.csv`, `validation.csv`, `models.rds`, `input_hashes.csv`, `interpretation.txt`.

Define `c_t=log((1-s0_t)/s0_t)`. Then:

`c_t = alpha*p_it + (sigma-1)*ln_s_i_g + beta_a*a_it + controls + FE + error`.

Each auxiliary regression uses the SAME instruments, controls, FE, sample and clustering as its demand specification. The category term is common within month, but these are firm-month regressions matching demand; months are implicitly weighted by their observed incumbent row counts, not equally weighted standalone 132-row monthly regressions.

In ALL 48 original and ALL 48 tiny-outside designs, tax's category-term coefficient is positive and the count coefficient negative.

### SV3 (both controls, firm FE, national count), original annual M

| Instrument | Price first stage (SE) | Share first stage (SE) | Category-term reduced form (SE) |
|---|---:|---:|---:|
| Geographic tax | -1.69852 (0.33985) | +0.75910 (0.13625) | +0.90918 (0.17369) |
| National active-brand count | -0.09273 (0.01599) | -0.02368 (0.00243) | -0.02763 (0.00486) |

The exact-ID identity for each instrument z is:

`rho_category,z = alpha*pi_price,z + (sigma-1)*pi_share,z`.

SV3 alpha=-0.00503, sigma=2.18644. Tax equation:

`0.90918 = (-0.00503)*(-1.69852) + (2.18644-1)*(0.75910)`

`= 0.00855 + 0.90063`.

With jointly estimated alpha near zero, `sigma-1` is roughly 0.909/0.759=1.20. Exact solution uses BOTH tax and count equations; tax alone does not determine sigma. The count equation has the same sign alignment with share. SV4 is similar: alpha=+0.00418, sigma=2.22679; category tax coefficient +0.91084 and count coefficient -0.02755.

Under the tiny outside-share transformation, SV3 category tax coefficient shrinks to +0.13095 (SE 0.05555), count to -0.01056 (SE 0.00189). Sigma=1.27199 and alpha=+0.04446 (wrong price sign). Signs remain aligned with share. SV4 sigma=1.28211, alpha=+0.04677.

### Latest user question and answer

User: Does tax predicting the category term so highly make sigma huge?

Answer: PARTLY, but the relevant issue is prediction relative to the price/share first stages and the simultaneous count moment. In SV3 most of tax's positive category-term association is assigned to positive sigma-1 rather than price. This is algebraic accounting, not proof of causal tax effects or exclusion failure. A valid tax instrument can legitimately affect category demand via price. The diagnostic cannot distinguish that channel from exclusion violations, omitted demand factors or incorrectly constructed category timing. The negative tax-price first stage remains a concrete concern.

All auxiliary slopes passed independent explicit-dummy QR checks; reconstructed alpha/sigma match saved original and tiny-outside fits; reduced-form y=share+category identity and unchanged source hashes passed. No Markdown meeting updates were made for this diagnostic.

## Where to go next (not yet done)

- User has not yet requested the next diagnostic after the category-term explanation.
- Leave-one-firm/year-out influence checks, especially BLU 2018, remain open.
- Investigate the negative conditional tax-price relationship, instrument exclusion, common demand trends and retail coverage changes; do not label a cause without evidence.
- Origins of 2018 retail-sales and 2022 NCP-intensity changes remain unresolved.
- Weak-IV-robust inference and overidentification tests remain unperformed. Conditional F is not proof of exclusion or calibrated weak-IV bias/size control.
- Do not interpret sigma admissibility as a model-selection criterion. Price aggregation, quality treatment, instruments, category term and market coverage remain substantive choices.
- If asked to update meeting notes with outside-option work, include BOTH failed mean-rescaling and bounded-path exercises and distinguish level from temporal-variation changes. Otherwise preserve the no-Markdown instruction for toggling experiments.

## Repository and execution

Run scripts from repository root with `Rscript --vanilla smoke_firm_dir/code/...`. All new analysis reads built panels; no new raw rebuild needed. Canonical replacements require a backup first.

On 2026-10-09, user requested staging/commit/push. Commit `0846286` (231 changed files) was pushed to origin/master; local backup directories were added to .gitignore and retained on disk. The October 20 analyses/docs are subsequent work; no new commit/push was requested or performed for them. Do not assume a clean worktree.

Git may require per-command `-c safe.directory=C:/Users/user/Desktop/Bitbucket/smoke_firm` due workspace ownership. Do not change global safe.directory automatically. Original expanded-grid `models.rds` is large; review generated artifact sizes before any future commit/push.
