# Demand estimation

Run from the repository root:

```sh
Rscript smoke_firm_dir/code/0_master.R --stage=demand --run
```

Build the input first if necessary with `--stage=instruments --run`. The demand
stage reads `input/demand_instrument_candidates.rds`; it never rebuilds or
replaces canonical inputs. The full `all` stage now ends with demand estimation.

1. `1_estimate_nested_logit.R`: estimates two joint IV/2SLS regressions using
   `fixest::feols`, with `y = intercept + beta_a*a_it - alpha*p_it + sigma*ln_s_i_g + xi`.
   Price and within-nest share are both endogenous. Both versions use
   `TaxIV_geo`; the second excluded instrument is `n_brands_3st` or
   `n_brands_overlap`. Both versions use the same 7% incumbent sample and
   UPC-unweighted representative price. The baseline includes an intercept,
   no fixed effects and no regression weights. Inference clusters by month.
2. `2_report_demand_results.R`: writes the comparison report, residual time plot,
   and residual summaries by firm and year.

Outputs live in `output/demand_estimation/`: `coefficients.csv`,
`first_stage_diagnostics.csv`, `model_checks.csv`, `residuals.csv`,
`incumbents_by_year.csv`, `demand_models.rds`, `session_info.txt`, and the report
and residual diagnostics. Coefficients include clustered SEs and 95% intervals.
Residuals are structural residuals evaluated at observed endogenous regressors;
the intercept is estimated separately. The saved bundle records the input MD5.

The estimator validates share identities, keys, finite inputs, rank and common
sample size. Coefficients and clustered covariance are independently checked
against QR-based 2SLS and a structural-residual sandwich calculation.

First-stage outputs distinguish IID F tests, month-clustered Wald F tests,
partial R2, joint excluded-instrument tests and incremental tests. These are
not a complete weak-identification assessment with two endogenous regressors.
The installed fixest 0.12.0 errors on its Kleibergen-Paap diagnostic for this
specification; the saved report explicitly records that limitation. Exactly
identified specifications have no overidentification test. Month clustering
does not address serial dependence across months, and exclusion is assumed.

Estimates are not constrained or clipped. Any alpha <= 0 or sigma outside
[0,1) is flagged as ineligible for subsequent cost recovery. The first runs
produce sigma above one in both specifications; these are exploratory estimates,
not approved inputs for the pricing or dynamic model. No cost recovery is run.

References: [feols](https://lrberge.github.io/fixest/reference/feols.html),
[fitstat](https://lrberge.github.io/fixest/reference/fitstat.html).

## Firm fixed effects (2026-10-06)

`3_estimate_firm_fe.R` estimates both count alternatives with firm FE and no
month FE. It reports **alpha as the signed price coefficient**, expected negative,
in `y = mu_i + beta_a*a_it + alpha*p_it + sigma*ln_s_i_g + xi_it`.
The historical no-FE estimates above retain their original opposite-alpha
reporting convention; compare actual price slopes when comparing the results.

Run only these specifications with:

```sh
Rscript smoke_firm_dir/code/0_master.R --stage=firm_fe --run
```

The full demand stage also runs script 3. Outputs are isolated under
`output/demand_estimation/firm_fe/`: coefficients and confidence intervals,
first-stage joint/incremental tests, structural residuals, firm effects, fitted
models, model checks, session information, and a comparison README. The common
sample contains 540 observations. An independent dummy-variable 2SLS calculation
verifies the absorbed-FE estimates and structural residuals. The first runs
produce sigma 3.86 and 3.94; neither passes the nested-logit parameter restriction.

## OLS diagnostic

`4_ols_diagnostic.R` estimates the same firm-FE equation with both price and
within-nest share uninstrumented. Run `Rscript smoke_firm_dir/code/0_master.R
--stage=ols --run` (on one line). Outputs are under
`output/demand_estimation/ols_diagnostic/`. The full demand stage includes it.
This is a comparison diagnostic, not a replacement for IV or a test of exclusion.

## Advisor specification tables (no additional controls)

`5_specification_comparison.R` estimates twelve models on a common sample:
four full-IV versions (two counts, with/without firm FE), OLS with/without firm
FE, four share-only IV versions, and price-only IV with/without firm FE.
Share-only uses the chosen count; price-only uses geographic tax. The untreated
regressor is assumed exogenous and included in the first stage. No month FE or
new product controls are included. Alpha is the signed price slope throughout.

Run `Rscript smoke_firm_dir/code/0_master.R --stage=comparison --run`.
The full demand stage also produces these tables. Outputs under
`output/demand_estimation/specification_comparison/` include `comparison.html`
(browser/print), `README.md` (main and diagnostic tables), coefficient CSV with
95% intervals, specification manifest, first stages, checks and fitted models.
Existing historical results are preserved. Every model is independently checked
using explicit-dummy QR estimation. First-stage F statistics are not a test of
instrument exclusion or a complete joint weak-identification assessment.


## Reusable product size

Run `Rscript --vanilla smoke_firm_dir/code/0_master.R --stage=characteristics --run`.
Build step `1_build_data/10_build_product_size.R` also runs in the regular build/all stages.
It extracts monthly raw size attributes into a cache refreshed when raw-file sizes or modification times change.
User-reviewed decisions live in `input/manual_product_size_corrections.csv`, independent of review outputs.
Priority: reviewed size, user-confirmed family sizes (JUUL 0.7 mL, NJOY Ace 1.9 mL, Vuse Vibe 1.9 mL), existing manual nicotine size correction, explicit UPC override, then unambiguous raw monthly size (direct per-cartridge field or pack mL/count).
Conflicting raw sizes remain missing. Missing cartridge counts are never silently set to one.

Reusable outputs:
- `input/product_size_upc_month.rds`: UPC-month size, provenance, classification and pack-volume discrepancy flags.
- `input/product_characteristics_firm_month.rds`: brand-month means and coverage; join by `brand, month`.

`avg_ml_per_ecig` gives each eligible UPC one vote, restricting to closed pods and disposables sold in at least three stores. It is NA when any included device UPC has unknown size. `avg_ml_per_ecig_observed` averages only observed sizes and must be read with `device_size_coverage`. Bottle and mixed-type UPC counts are reported separately; bottles are not interpreted as devices. These outputs cover all eligible brands, not only incumbents.

Coverage and unresolved records appear in `output/demand_estimation/product_size_review/`. This build adds characteristics without changing canonical sales, prices, shares, or regression specifications. Reviewed pack-volume decisions also feed the retail builders as of the 2026-10-07 rebuild; discrepancy output is retained as a validation check.

`avg_ml_per_product_unit` is also provided across all eligible UPCs (including bottles), with its observed-only counterpart and `n_upc_size_known`. This broader measure mixes cartridge/device capacity and bottle size and should not be labeled per-e-cigarette volume.

When the raw per-cartridge size is missing but a unique positive monthly cartridge count exists, panel pack mL divided by that count is the final fallback (explicitly labeled in `size_source`). Conflicting raw size values block that fallback.

A missing monthly size can also use an unambiguous size of the exact same UPC in other months, before the pack/count fallback. That fallback can use a count consistent across all raw observations when the current month has none. Conflicting counts across months are not transferred.


## Estimating the size control

`6_product_size_comparison.R` estimates sixteen full-IV models: baseline, size only, log UPC variety only, and both controls, each with national/geographic count instruments and with/without firm FE. Run the build and both comparison reports with `Rscript --vanilla smoke_firm_dir/code/0_master.R --stage=size --run`.
The combined report (script 5) runs after script 6 to include its results. The regular demand stage expects the characteristic input to exist; build/all stages create it.

All sixteen models exclude firm-months with missing `avg_ml_per_ecig`, currently BLU January-December 2018, leaving 528 observations. No incomplete-UPC average is substituted, and existing market shares and instruments are not recomputed after sample exclusion. Exact exclusions are saved in `output/demand_estimation/specification_comparison/product_size/excluded_firm_months.csv`. Original 540-row tables are retained separately. Size is treated as exogenous; this is an assumption, not a finding from the diagnostics.

UPC variety is `log_upc_variety = log(n_upcs)`, produced by build 10. The count includes all distinct eligible firm-month UPCs, including bottles, and uses positive sales plus the three-store rule. This differs from the brand-count instruments. All sixteen control comparisons use the same complete-size sample; size and variety are treated as exogenous. Results are included in both the combined Markdown and HTML reports.


## Retail rebuild and market-size sensitivity (2026-10-07)

Reviewed UPC sizes and counts are applied upstream to retail volume, nicotine quantities and demand inputs. NCP household inputs are unchanged. `7_market_size_comparison.R` repeats all sixteen matched-sample control specifications under annual, monthly and constant NCP purchasing intensity, holding annual adult population and the estimation sample fixed across variants. It recalculates outside shares and the dependent variable; within-nest shares and instruments are unchanged by the choice of market size. Script 5 incorporates this output into the combined report. Re-run through `0_master.R --stage=comparison --run`.


## Current investigation (2026-10-08)

IV sigma is still out of bounds. Size and log UPC variety, the retail correction rebuild, and annual/monthly/constant M_t sensitivity are completed. The next focus is the economic definition of M_t and the outside option, including household/person units and scanner coverage. See [handoff](../../docs/handoff_sigma_market_size_2026-10-08.md) and [market-size formulas](../../docs/market_size_and_outside_option.md). Preserve the NCP input; no new market-size definition has been approved.
