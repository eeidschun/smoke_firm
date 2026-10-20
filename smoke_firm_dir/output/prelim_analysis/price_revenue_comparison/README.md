# Representative price and observed revenue: 2026-10-20

All prices and revenue use the existing real-dollar series. Eligible brand-UPC-months retain the current filters and corrected liquid volumes. T2 rows collapse before computing UPC price. Incumbency uses the saved annual roster; all eligible brands includes fringe brands individually.

The existing price p_it is the equal-UPC mean of R_u/Q_u. The separate sales-weighted price p_it_volume_weighted uses e-liquid mL weights: sum_u[(Q_u/sum Q_u)*(R_u/Q_u)] = sum R_u/sum Q_u. Thus its product with firm volume reproduces observed eligible retail revenue, up to floating-point rounding. This is a volume-weighted unit value, not a revenue-weighted mean or a fixed-product price index.

Signed percentage gap = 100*(p_it*Q/R - 1). Positive means overstatement. Aggregate net gap uses sums of revenues; absolute gap sums absolute firm-month dollar gaps before dividing by observed revenue. These differ because overstatements and understatements can cancel. Median/quantiles give each brand-month equal weight.

| Sample | N | Aggregate net gap % | Aggregate absolute gap % | Median signed gap % | Median absolute gap % | Min signed % | Max signed % |
|---|---:|---:|---:|---:|---:|---:|---:|
| Incumbents | 540 | 50.56 | 52.53 | 35.17 | 36.23 | -42.98 | 186.06 |
| Matched | 528 | 51.23 | 53.20 | 36.18 | 37.13 | -42.98 | 186.06 |
| All_eligible_brands | 2434 | 46.85 | 48.96 | 6.94 | 12.86 | -42.98 | 610.48 |

## Incumbent breakdown by firm

| Firm | Months | Net gap % | Absolute gap % | Median signed gap % |
|---|---:|---:|---:|---:|
| 21ST CENTURY SMOKE | 24 | 71.92 | 71.92 | 69.34 |
| NJOY | 132 | 31.54 | 42.15 | 1.20 |
| BLU | 72 | 17.80 | 22.95 | 5.04 |
| FINITI | 48 | 19.42 | 23.37 | 16.85 |
| MISTIC | 48 | 77.97 | 77.97 | 60.24 |
| LOGIC | 60 | 39.28 | 40.54 | 36.33 |
| MARKTEN | 12 | 16.62 | 16.62 | 15.58 |
| JUUL | 72 | 42.03 | 42.03 | 45.34 |
| VUSE | 72 | 86.51 | 86.67 | 67.12 |

The sidecar input/price_measures_firm_month.rds and detailed CSV retain both prices, volumes, observed/implied revenue, gaps, and sample indicators for every eligible brand-month. by_year.csv and the two largest-gap tables provide further detail. The canonical demand builder now includes the additional price column on future runs; it was not run for this analysis. Existing price, demand estimates, canonical panels and NCP inputs were not replaced. No new demand specification is selected.

Validation: reconstructed UPC-unweighted prices, volumes and revenues match all 540 saved incumbent rows; matched membership is 528 rows; weighted-price revenue identity holds for all eligible brand-months. Source hashes remained unchanged.

Reproduce: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/16_price_revenue_comparison.R`.
