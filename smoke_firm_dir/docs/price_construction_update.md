# Price construction and retail-volume rebuild ? 2026-10-07

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
