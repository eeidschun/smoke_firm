# Retail rebuild started 2026-10-07; validated 2026-10-08

Reviewed retail pack counts and volumes are now applied upstream. The NCP household input and all three saved market-size series are byte-for-byte / numerically unchanged, respectively.

Pre-rebuild snapshot: C:\Users\user\Desktop\Bitbucket\smoke_firm\smoke_firm_dir/backups/retail_rebuild_2026-10-07

## Changes and validation

Demand sample: 540 before, 540 after. Matched product-control sample: 528. Incumbent year-brand roster changes: 0.

| Metric | Before | After | Change (%) |
|---|---:|---:|---:|
| units_sum | 354342440.000 | 354342440.000 | 0.000000 |
| revenue_nom | 4663576580.070 | 4663576580.070 | 0.000000 |
| revenue_real | 5315095511.089 | 5315095511.089 | 0.000000 |
| mL_sum | 1062329892.992 | 1054216392.603 | -0.763746 |
| nic_mg_sum | 28947622176.245 | 28886040955.129 | -0.212733 |

Checks passed: reviewed pack-volume identities; UPC-to-brand totals (units, revenue, volume, nicotine); unweighted price and nicotine calculations; unchanged NCP file and market-size series; independent 2SLS checks for 16 control models and 48 market-size variants; annual market-size results reproduce the corresponding baseline fits.

The three NCP constructions use annual-mean, monthly, or full-period-mean household purchasing intensity, each multiplied by that year's July adult population. Market sensitivity changes outside shares and the dependent variable while holding the sample, within-nest shares, prices, controls and instruments fixed.

Current estimates: [comparison report](../output/demand_estimation/specification_comparison/README.md). Detailed rebuild differences: output/demand_estimation/retail_rebuild_2026-10-07/. Historical conversation transcripts and the dated snapshot retain their original content.
