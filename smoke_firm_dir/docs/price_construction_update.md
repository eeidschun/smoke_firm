# Price construction and retail-volume rebuild ? 2026-10-07

## Advisor follow-up: 2026-10-20

The separate sales-weighted price uses **e-liquid mL weights**: `p_it_volume_weighted = sum_u(Q_u * p_u) / sum_u Q_u = firm real revenue / firm mL`. Existing `p_it` remains UPC-unweighted. Both measures are saved for all eligible brand-months in `input/price_measures_firm_month.rds`; the demand builder includes the additional column on future runs. Existing canonical panels and demand fits were not overwritten.

Across 540 incumbent firm-months, existing `p_it * mL` totals $7.16248 billion versus $4.75711 billion in observed real revenue: net overstatement $2.40537 billion (50.56%). The median signed firm-month gap is +35.17%; the middle half spans +2.33% to +61.25%; the full range is -42.98% to +186.06%. Summed absolute dollar gaps equal 52.53% of observed revenue. 419 observations overstate and 121 understate revenue. On the 528-row matched sample, net overstatement is 51.23%. These totals span 2013-2023 and refer to eligible scanner sales, not total industry revenue.

[Full comparison](../output/prelim_analysis/price_revenue_comparison/README.md) contains firm breakdowns, with annual detail and largest discrepancies in accompanying CSVs. Volume-weighted price times volume reproduces observed revenue for every eligible brand-month. Reconstructed original price, volume and revenue match the saved 540-row incumbent panel. Reproduce with `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/16_price_revenue_comparison.R`. This comparison does not select a replacement demand specification.

Firm-month price remains the UPC-unweighted mean of UPC-month prices in real dollars per mL:

`p_upc,t = sum(real revenue_upc,t) / sum(corrected mL sold_upc,t)`

`p_i,t = mean(p_upc,t across eligible UPCs belonging to firm i in month t)`

Collapse T2 rows to one brand ? UPC ? month before taking the ratio. Eligibility: UNKNOWN excluded, positive units and mL, and at least three reporting stores per UPC-month. Each eligible UPC has equal weight. The descriptive fringe price remains aggregate fringe revenue / mL.

Reviewed pack counts and capacities from input/manual_product_size_corrections.csv now feed the retail builders. The correction includes JUUL 081991301543 at one 0.7 mL pod, both reviewed MISTIC disposables at 1.5 mL, and Vuse Vibe at 1.9 mL per cartridge. The original JUUL UPC is retained under the user's approved information transfer. Nicotine quantities are recomputed using corrected liquid volume and existing clean concentration; the transfer factor remains 0.68.

Retail quantities, prices per mL, nicotine quantities, shares, annual incumbent eligibility, geographic instruments and downstream analyses are rebuilt. Raw revenue and unit observations are not edited. The separate NCP household purchasing-intensity input is unchanged by explicit user instruction.

Market size uses annual adult population (the July estimate held constant within each year) times either the annual mean, monthly value, or full-period mean of the saved household-weighted NCP monthly mL series. The annual-mean version remains the baseline.

The unweighted price times firm volume generally does not equal observed revenue: p_bar Q - R = sum_u (p_bar - p_u) q_u. Revenue per mL, R/Q, recovers revenue exactly. This remains a consideration for future profit measurement.

Reusable controls: average mL per cartridge/disposable (unweighted across eligible device UPCs) and log eligible UPC count. Refill bottles are excluded from device capacity but included in variety. Missing device size causes the full firm-month to be excluded from matched control comparisons; the unresolved BLU UPC is not imputed automatically. Current sample sizes and estimates are in output/demand_estimation/specification_comparison/README.md.

Implementation: code/1_build_data/8_build_firm_month_demand_panel.R and 10_build_product_size.R. Rebuild details and pre-rebuild backups are documented in retail_rebuild_2026-10-07.md.


## Outside-option interpretation

The current volume-based outside share is not a non-vaping adult rate. Household purchasing intensity times adult population and scanner sales coverage require further assessment; see [market-size definitions](market_size_and_outside_option.md) and the [current handoff](handoff_sigma_market_size_2026-10-08.md). No alternative denominator beyond the three existing variants has been adopted.
