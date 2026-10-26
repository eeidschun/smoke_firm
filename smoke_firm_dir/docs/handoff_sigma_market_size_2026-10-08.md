# Handoff: out-of-bounds nesting parameter and market-size investigation

Updated: 2026-10-08. Start here for the current demand-estimation work.

## Objective and current position

We are trying to understand why nested-logit IV/2SLS estimates give sigma > 1, outside the maintained admissible range 0 <= sigma < 1. We have not solved this problem and have not selected a demand specification for supply-side cost recovery. Do not constrain or clip sigma merely to produce admissible costs.

We have tried firm fixed effects, alternative count instruments, OLS/partial-IV diagnostics, and additional firm-month product characteristics. A retail-volume consistency rebuild is complete. We are now examining the economic meaning and construction of market size M_t and the outside option, not simply searching for another regressor.

The annual, monthly and constant-intensity market-size alternatives have ALREADY been estimated. The open question is whether the denominator and observed retail numerator represent compatible populations, units and coverage. No replacement market-size definition has been approved.

## Demand specification and sample

The comparison reports use the signed price coefficient:

`log(s_it / s_0t) = intercept + alpha*p_it + beta_a*a_it + sigma*log(s_it/s_gt) + optional controls + optional firm FE + error_it`.

Alpha is expected to be negative. Some older standalone code/theoretical PDFs use -alpha*p; do not compare those alpha labels without checking the convention.

- Data: national firm-month observations, January 2013-December 2023; 132 month clusters.
- Eligible UPC-months: known brand, positive units and mL, at least three reporting stores. Multiple T2 rows collapse to one brand-UPC-month before unweighted averaging.
- Incumbents: annual mL share >7%, with roster held fixed within the year; other eligible brands form the fringe. Rebuild did not change the roster.
- Price: simple average across eligible UPCs of real revenue / mL sold. It is not firm aggregate revenue / firm mL; representative price times firm mL need not recover observed revenue.
- Nicotine a_it: UPC-unweighted delivered mg/mL; delivered nicotine quantities use corrected liquid volume, clean nicotine concentration and the existing 0.68 transfer factor.
- Baseline sample: 540 incumbent firm-months.
- Matched control/market-size sample: 528 firm-months. All 12 BLU observations in 2018 are excluded because UPC 088796900752 has unresolved size. The user could not verify it and explicitly approved proceeding without resolving it. We drop the entire affected firm-month, not the UPC from its price/share construction, and do not substitute an incomplete-UPC size mean.
- No month FE. With a single e-cigarette nest, y_it = log(s_it/s_gt) + log(s_gt/s_0t); full month FE absorb the common term and create a degeneracy for estimating this relationship. This is not just an ordinary omitted-FE comparison.
- Standard errors are clustered by month; this does not address serial dependence across months.

Price and within-nest log share are jointly instrumented by (1) geographic population-weighted excise tax over states where the firm sells, and (2) either the national eligible active-brand count or the distinct-brand count in the union of the firm's operating states. Counts include the focal brand and fringe brands; they count brands, not UPCs. The two counts coincide in 528/540 observations. Joint first-stage F statistics do not establish conditional strength for each endogenous regressor or instrument exclusion.

## Specifications already run

The combined comparison retains full-IV, OLS and partial-IV diagnostics, with/without firm FE. Partial IV includes share-only and price-only instrumentation; untreated regressors are assumed exogenous in those diagnostics.

Reusable product controls were added:

1. `avg_ml_per_ecig`: equal-UPC-weight mean mL per cartridge/disposable, using eligible device UPCs. Refill bottles and mixed types are excluded from this capacity mean. It is missing when any included device UPC has unresolved size. The observed-only mean and coverage counts are saved separately and are not silently substituted.
2. `log_upc_variety = log(n_upcs)`: log number of all distinct eligible firm-month UPCs, including bottles. This differs from the brand-count instruments.

The matched-sample comparison contains 16 full-IV models: B1-B4 (baseline), S1-S4 (size), V1-V4 (variety), SV1-SV4 (both). Within each group: national/no FE, geographic/no FE, national/firm FE, geographic/firm FE. All use the same 528 rows, even variety-only models. Nicotine, size and variety are treated as exogenous; endogenous assortment choice remains a concern.

Latest rebuilt full-sample full-IV sigma: 3.422, 3.630, 4.024, 4.159 (M1-M4). OLS gives 0.975 without firm FE and 0.911 with firm FE; admissible OLS estimates do not prove that the instruments are the problem. Removing BLU's 2018 rows materially changes estimates even before adding controls. Compare controls against matched-sample baselines, not the original 540-row estimates.

## Retail corrections and rebuild completed

The user reviewed 17 initially flagged UPCs. Decisions are permanent inputs in `input/manual_product_size_corrections.csv`, not just review-output annotations. Key corrections include JUUL 081991301543 as one 0.7 mL pod (retain this original UPC; user approved transfer of cited product information), MISTIC 085570400806 and 085570400807 as one 1.5 mL disposable each, and Vuse Vibe at 1.9 mL per cartridge. User-confirmed family capacities also include JUUL 0.7 mL and NJOY Ace 1.9 mL.

The reviewed corrections now feed retail volume, nicotine quantities, UPC and brand panels, unweighted prices, shares, incumbent selection, geographic instruments, preliminary analyses and demand estimates. They are no longer pending an upstream rebuild.

Relative to the snapshot: retail mL fell 0.763746%, nicotine quantity fell 0.212733%, and units plus nominal/real revenue totals were unchanged. The NCP file and all three M_t series were unchanged. All reviewed pack-volume identities agree with the rebuilt panel.

Backup: `backups/retail_rebuild_2026-10-07/` contains pre-rebuild inputs, output, docs and code. See `docs/retail_rebuild_2026-10-07.md` and `output/demand_estimation/retail_rebuild_2026-10-07/` for the audit. The raw rebuild completed during an interrupted conversation; the final comparison stage, market-size fits, audit and PDF refresh completed on 2026-10-08. Do not redo the expensive raw rebuild merely to resume this investigation.

## Current focus: M_t and the outside option

See [market-size definitions](market_size_and_outside_option.md) for formulas and interpretation.

Let Q_t be total eligible retail mL, including incumbents and fringe; A_y is annual adult population (July estimate held fixed for all months in the year). Let k_t be the saved NCP projection-weighted average monthly mL purchased per e-cigarette-purchasing household. It is conditional on household purchase, not an average over all households or all adults.

- `M_t`: annual arithmetic mean of k_t times A_y. Despite the t index, constant within the year.
- `M_t_k_monthly`: monthly k_t times A_y.
- `M_t_k_const`: full-period arithmetic mean of k_t times A_y.
- For each version: s_gt = Q_t/M_t; s_0t = 1-Q_t/M_t; s_it = q_it/M_t.
- Therefore y_it = log(q_it/(M_t-Q_t)), while s_it/s_gt = q_it/Q_t is unchanged by M_t.

All 16 matched-sample specifications were repeated under the three variants (48 models). They hold the sample, within-nest shares, prices, controls and instruments fixed. All outside shares are positive and all 48 sigma estimates remain above one.

With BOTH size and variety plus firm FE:

| Market size | Sigma, national IV | Sigma, geographic IV |
|---|---:|---:|
| Annual baseline | 2.186 | 2.227 |
| Monthly intensity | 2.067 | 2.096 |
| Constant intensity | 2.683 | 2.748 |

We plotted M_t, Q_t and outside shares inline in chat. At the user's request, no plot files or plot code were saved. Outside shares are approximately 98.91%-99.93% across alternatives. Eligible retail sales jump around 2018; annual/monthly market size jumps around 2022. These are descriptive observations, not established causal explanations.

The current outside share represents residual potential VOLUME under the assumed denominator. It is not directly the percentage of adults who do not vape, nor the fraction of all US purchases that are not e-cigarettes. k_t is per purchasing HOUSEHOLD but multiplied by ADULTS; observed sales are scanner-covered eligible retail sales. The household/person and coverage alignment need examination. A person-level participation model would require compatible person-choice quantities; changing M_t alone would not make mL shares into adult participation shares.

## Next work and constraints

1. Continue discussing the economic choice unit: adult participation versus consumption/purchase opportunities. Clarify whether retail sales and the proposed potential market cover compatible populations and channels.
2. Examine the origins of the 2018 retail-sales and 2022 NCP-intensity changes; do not label them behavior or data artifacts without evidence.
3. Decide what alternative denominator, if any, is justified before implementing it. Do not select M_t solely because sigma moves toward the admissible range.
4. Later diagnostics still open: leave-one-firm/year-out influence checks (especially BLU 2018), broader joint weak-identification diagnostics/robust inference, and representative-price/firm-aggregation sensitivity. Sanderson-Windmeijer conditional first-stage F tests are now completed; see below.

## Sanderson-Windmeijer conditional F completed 2026-10-08

Standalone diagnostics cover both endogenous regressors in M1-M4 and all 16 matched B/S/V/SV models, retaining existing samples, controls, instruments and firm FE. Month-clustered SW F uses numerator df 1, denominator df 131, and explicitly documented CR1 covariance correction. Full results, IID counterparts, p-values, validation and hashes: [conditional F report](../output/demand_estimation/specification_comparison/conditional_F/README.md).

- M1 price/share: 55.79/62.68; M2: 58.65/49.08; M3: 15.91/18.95; M4: 15.08/17.91.
- Matched conditional F range: 40.39-164.50. SV3 price/share: 81.38/79.57; SV4: 82.31/78.38.
- All 48 market-size fits inherit their corresponding matched-model conditional F because first-stage variables are identical, verified against saved samples.
- These results do not reveal an obvious collapse in conditional relevance explaining sigma > 1. They do not establish instrument exclusion, compatible market-size units/coverage, or calibrated weak-IV bias/size guarantees. IID Stock-Yogo critical values do not directly apply to month-clustered tests; p-values test zero conditional relevance, not sufficient strength.
- Independent fixest conditional-IV residual checks, full-design sandwich covariance checks and IID auxiliary-regression checks passed for all 40 tests. Canonical inputs and saved demand fits were unchanged. Reproduce: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/8_sw_conditional_F.R`.

User instruction: do NOT rebuild or correct the separate NCP household-based input for this retail rebuild. Preserve that decision unless the user explicitly revisits it. The inline-only plotting instruction applied to those plots; the user now explicitly requested this saved handoff and documentation update.

## SV3/SV4 first stages and reduced forms shared 2026-10-08

The IV investigation remains open at the user's request. [Coefficient tables](../output/demand_estimation/specification_comparison/sv_first_stages_reduced_form/README.md) show price and within-nest-share first stages alongside reduced forms for baseline annual-market-size y, all with both controls, firm FE, 528 rows and month clustering. CSV includes standard errors, p-values and confidence intervals; a separate CSV decomposes each excluded instrument's reduced-form coefficient into alpha times its price coefficient plus sigma times its share coefficient.

Both specifications associate tax negatively with price and positively with within-nest share and y; count is negatively associated with all three outcomes. These are conditional associations, not established causal effects. Tax's negative price first-stage coefficient warrants scrutiny. Saved alpha is approximately -0.00503 in SV3 and +0.00418 in SV4, while sigma is 2.18644/2.22679. Consequently, the reduced-form instrument coefficients are numerically accounted for almost entirely by the share contribution. This is an exact-identification identity, not an exclusion test or proof of the cause of sigma > 1. First stages reproduce saved coefficients/covariances and all six regressions pass explicit-dummy QR slope checks. Inputs and saved demand fits were unchanged.

### Odd tax–price sign: sensitivity to nicotine and capacity (2026-10-12)

Standalone price-first-stage diagnostics hold the 528 matched incumbent firm-months, geographic population-weighted tax, national brand count, firm FE and month-clustered standard errors fixed. There are no month FE. Varying the included characteristics shows that the negative tax coefficient depends strongly on conditioning on nicotine or capacity:

| Included characteristics | Tax coefficient | Month-clustered SE |
|---|---:|---:|
| None: exclude nicotine, capacity and variety | +0.84379 | 0.29271 |
| Variety only: exclude nicotine and capacity together | +0.77509 | 0.28492 |
| Nicotine only | -1.43218 | 0.33995 |
| Capacity only | -1.10000 | 0.28167 |
| Nicotine and capacity, no variety | -1.67242 | 0.34956 |
| Nicotine and variety: exclude capacity only | -1.41189 | 0.33129 |
| Capacity and variety: exclude nicotine only | -1.08758 | 0.28047 |
| Nicotine, capacity and variety: current SV3 | -1.69852 | 0.33985 |

Excluding nicotine and capacity **together** reverses the current negative association. Adding either characteristic **separately** to the otherwise basic first stage also reverses the positive association to negative. Excluding only one from SV3 does **not** reverse the sign, because the remaining characteristic still produces a negative conditional coefficient. This distinction matters when describing the diagnostic.

The reversal identifies sensitivity to conditioning; it does not establish that nicotine or capacity is endogenous, that the tax instrument satisfies exclusion, or that omitting these demand attributes is appropriate. Firms' choices of nicotine and capacity in response to unobserved demand provide an economic reason to question exogeneity, but correlation among tax, prices and observed characteristics can also produce a reversal with exogenous controls. Common changes over time and product composition remain possible explanations. No structural demand specification has been changed or selected on the basis of these results.

In standard 2SLS, included structural demand controls also enter both first stages. Treating nicotine and/or capacity as endogenous would require joint instrumentation with price and within-nest share, sufficient additional excluded instruments, and assessment of relevance and exclusion. The current two excluded instruments are insufficient to identify three or four endogenous regressors without additional restrictions.

Results: [matched aggregation/conditioning diagnostic](../output/prelim_analysis/state_price_tax_diagnostic/aggregation_bridge/README.md), with exact coefficients in `results.csv`. Script: `code/2_preliminary_analysis/18_aggregation_price_tax_bridge.R`. Current national prices, geographic tax and SV3/SV4 price-first-stage coefficients were independently reproduced. Canonical inputs, saved demand fits and NCP data were unchanged.

## Where to resume

- Current results: `output/demand_estimation/specification_comparison/README.md`, `comparison.html`, `README.pdf`.
- Detailed controls: `specification_comparison/product_size/`; market alternatives: `specification_comparison/market_size/`. Both contain coefficients, first stages, model checks, model objects, samples and exclusions.
- `code/1_build_data/7_build_Mt_numerator.R`: explains NCP k_t construction; external source file is not supplied. Do not run it for routine updates.
- `code/1_build_data/8_build_firm_month_demand_panel.R`: market-size and demand-share definitions.
- `code/1_build_data/10_build_product_size.R`: reusable product size/variety and coverage.
- `code/3_demand_estimation/6_product_size_comparison.R`: 16 matched models.
- `code/3_demand_estimation/7_market_size_comparison.R`: 48 market-size fits.
- `code/3_demand_estimation/5_specification_comparison.R`: combined Markdown/HTML report.
- `code/2_preliminary_analysis/15_retail_rebuild_audit.R`: dated rebuild audit.

From repository root, `Rscript --vanilla smoke_firm_dir/code/0_master.R --stage=comparison --run` refreshes characteristics, control fits, market variants and Markdown/HTML. This does not itself regenerate the PDF; the last PDF refresh used the workspace-local PDF helper in the dated backup. No-argument master is a dry-run plan. Canonical inputs require a backup before a new rebuild. Independent QR 2SLS, aggregation, share/price, pack-size and unchanged-NCP checks passed for the current outputs.
