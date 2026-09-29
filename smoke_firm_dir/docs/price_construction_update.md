## Price construction update ? 2026-09-29

Firm-month price is the **UPC-unweighted mean of UPC-month prices in real dollars per mL**:

`p_upc,t = sum(real revenue_upc,t) / sum(mL sold_upc,t)`

`p_i,t = mean(p_upc,t across eligible UPCs belonging to firm i in month t)`

Collapse multiple T2 rows to one brand ? UPC ? month observation before taking the ratio. Use the existing sample: UNKNOWN excluded, positive units and mL, and at least three reporting stores per UPC-month. Each eligible UPC receives equal weight within its firm-month, matching the across-UPC weighting convention for nicotine state `a_i,t`.

This replaces the firm's aggregate revenue/mL price in `code/build/8_build_firm_month_demand_panel.R`. Quantities, revenue totals, shares, market size, and the population-weighted national tax instrument retain their existing construction. The saved descriptive fringe `p_F` remains aggregate fringe revenue/mL; it is not a price regressor or strategic price in the current model.

The product-line average price times total firm mL generally does not equal observed revenue. Consequently, model revenue/profit based on this representative price should not be described as an accounting reconstruction of scanner revenue.

