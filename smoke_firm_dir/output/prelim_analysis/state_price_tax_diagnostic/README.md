# State-level price–tax diagnostic

Run date: 2026-10-12

Eligible sample: known-brand UPC-months with positive units/volume and at least three stores nationally. All eligible brands, including fringe. State price is the equal-UPC-weight mean of real revenue/corrected mL. Volume-weighted price is a separate sensitivity check. All state-month FE comparisons use the same rows within each outcome.

Corrected pack mL is constant within every national UPC-month, verified using the saved second volume moment. Raw state sales are multiplied by this corrected capacity. State units, real revenue, and corrected volume reconcile to the canonical national UPC-month panel. No canonical input or demand fit is overwritten.

Tax uses the existing closed-system real-dollar/mL tax series, matching the current instrument construction. This may imperfectly represent refill/open-system products. State prices retain the existing retail price and inflation conventions. No new claim about statutory tax treatment is imposed.

OLS associations; standard errors clustered by state and month. Two-way clustering does not permit arbitrary dependence across states across different months. UPC-state FE hold persistent product/location differences fixed but do not hold time-varying assortment or retail-store composition fixed. Singleton rows may be removed in UPC FE fits; their sample differs from state-month fits.

Policy data were not found in the repository. SFA/licensing/self-service/minimum-age comparison remains pending; no values imputed.

| Model | N | Tax slope | SE | 95% CI |
|---|---:|---:|---:|---|
| price_pooled | 6443 | 0.9365 | 0.0903 | [0.7553, 1.1178] |
| price_state_FE | 6443 | 0.7789 | 0.1835 | [0.4103, 1.1475] |
| price_month_FE | 6443 | 0.9242 | 0.0775 | [0.7686, 1.0798] |
| price_state_month_FE | 6443 | 0.7130 | 0.1619 | [0.3877, 1.0383] |
| price_volume_pooled | 6443 | 0.7301 | 0.1179 | [0.4933, 0.9669] |
| price_volume_state_FE | 6443 | 0.5974 | 0.2089 | [0.1779, 1.0169] |
| price_volume_month_FE | 6443 | 0.8714 | 0.1460 | [0.5780, 1.1647] |
| price_volume_state_month_FE | 6443 | 0.9859 | 0.1897 | [0.6048, 1.3670] |
| upc_state_month_FE | 699282 | 0.9568 | 0.1018 | [0.7524, 1.1613] |
| upc_state_pair_month_FE | 699282 | 0.8348 | 0.1632 | [0.5071, 1.1625] |

These regressions diagnose variation and aggregation; they do not validate instrument exclusion or replace the structural nested logit. Full month FE are permitted here because the diagnostic outcome is price, rather than the single-nest inverted demand equation.

Reproduce from repository root: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/16_state_price_tax_diagnostic.R`. Optional: set STATE_POLICY_CSV to a complete e-cigarette state-month policy CSV. Delete only this diagnostic's state_upc_month.rds cache if canonical retail inputs change.
