# State-level price–tax diagnostic, 2026-10-12

The negative tax–price coefficient in SV3/SV4 does not persist in the state-level retail diagnostic. Every fitted state-level tax slope is positive, including the pooled regression without policy controls. Thus adding policy controls is not necessary to obtain a positive association at this level of aggregation. These results do not identify the cause of the negative conditional national firm-level coefficient.

| Price construction and controls | Tax slope | Two-way clustered SE |
|---|---:|---:|
| Equal-UPC state-month price, pooled | 0.937 | 0.090 |
| Equal-UPC state-month price, state FE | 0.779 | 0.184 |
| Equal-UPC state-month price, month FE | 0.924 | 0.077 |
| Equal-UPC state-month price, state + month FE | 0.713 | 0.162 |
| Revenue/volume state-month price, state + month FE | 0.986 | 0.190 |
| State-UPC-month price, UPC + state + month FE | 0.957 | 0.102 |
| State-UPC-month price, UPC-state pair + month FE | 0.835 | 0.163 |

The state-month comparisons have 6,443 observations and the UPC-level comparisons have 699,282 observations. Price and tax use real dollars per mL. All eligible brands, including fringe, are included, whereas the structural demand comparison uses incumbent firm-months and additional nicotine/size/variety controls. These are different samples and conditional relationships; the table is not a direct replication of SV3/SV4 or the earlier disaggregate paper.

Eligibility matches the national retail convention: known brand, positive units and corrected mL, at least three reporting stores nationally per UPC-month. Corrected pack mL was verified constant within every national UPC-month using the saved second volume moment. Applying that capacity to raw state sales reproduces canonical national UPC-month units, real revenue and corrected mL within relative tolerance 1e-8. No canonical data, NCP input, demand estimates, or market-size definition changed.

Standard errors are clustered by state and month. UPC-state fixed effects hold persistent product-location differences fixed but cannot remove changing store composition or time-varying product characteristics. The tax series is the existing closed-system tax series used in the firm-level instrument; applicability to open-system/refill products remains a limitation. No causal pass-through claim or exclusion validation follows from these associations.

SFA, licensing, self-service and minimum-age policy data were not found locally. That extension is pending the user's file location. The script accepts a complete e-cigarette-specific CSV through STATE_POLICY_CSV, with STATE (FIPS), year_month, SFA, lic, self_service_law and min_age. Missing policies are not imputed.

The next bridge should compare incumbent brand-state-month and national brand-month regressions with matched controls and samples, then isolate the influence of product weighting, geographic aggregation, and common time movements. Do not select structural controls solely to obtain a positive tax coefficient or admissible sigma.

Script: `code/2_preliminary_analysis/16_state_price_tax_diagnostic.R`.
Detailed results, models, diagnostic cache and reconciliation: `output/prelim_analysis/state_price_tax_diagnostic/`.
