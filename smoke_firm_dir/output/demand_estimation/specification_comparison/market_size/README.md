## Market-size sensitivity (NCP inputs unchanged)

All 48 specifications use the same 528 complete-size firm-month observations and 132 month clusters. The four baseline, size-only, variety-only and combined specifications are each estimated under three market-size constructions. See excluded_firm_months.csv for exclusions.

Annual: the within-year arithmetic mean of household-weighted monthly NCP purchasing intensity times that year's July adult population. Monthly: each month's household-weighted purchasing intensity times the same annual adult population. Constant: the full-period arithmetic mean of the monthly intensity series times annual adult population. No NCP input was rebuilt.

For each alternative, s_it = firm mL / M_t and s_0t = 1 - total market mL / M_t are recomputed. The within-nest share, prices, nicotine, controls, roster and instruments remain fixed. This isolates the market-size construction; coefficients use signed alpha and month-clustered standard errors (see CSVs). All outside shares were checked positive.

| Model | Controls | Firm FE | Count IV | Sigma annual | Sigma monthly | Sigma constant | Alpha annual | Alpha monthly | Alpha constant |
|---|---|---|---|---:|---:|---:|---:|---:|---:|
| B1 | Baseline | No | National | 2.887 | 2.773 | 3.103 | -0.113 | -0.105 | -0.302 |
| B2 | Baseline | No | Geographic | 3.036 | 2.902 | 3.296 | -0.103 | -0.097 | -0.289 |
| B3 | Baseline | Yes | National | 2.384 | 2.255 | 2.952 | -0.002 | 0.008 | -0.294 |
| B4 | Baseline | Yes | Geographic | 2.409 | 2.271 | 2.999 | 0.005 | 0.012 | -0.281 |
| S1 | Size | No | National | 2.880 | 2.771 | 2.916 | -0.115 | -0.106 | -0.359 |
| S2 | Size | No | Geographic | 3.045 | 2.914 | 3.144 | -0.100 | -0.093 | -0.338 |
| S3 | Size | Yes | National | 2.267 | 2.160 | 2.641 | -0.024 | -0.010 | -0.351 |
| S4 | Size | Yes | Geographic | 2.299 | 2.181 | 2.705 | -0.015 | -0.004 | -0.334 |
| V1 | Variety | No | National | 3.316 | 3.142 | 3.979 | -0.189 | -0.171 | -0.458 |
| V2 | Variety | No | Geographic | 3.487 | 3.291 | 4.192 | -0.187 | -0.169 | -0.455 |
| V3 | Variety | Yes | National | 2.315 | 2.169 | 3.054 | 0.011 | 0.025 | -0.314 |
| V4 | Variety | Yes | Geographic | 2.347 | 2.191 | 3.099 | 0.019 | 0.030 | -0.303 |
| SV1 | Size and variety | No | National | 3.281 | 3.123 | 3.469 | -0.189 | -0.171 | -0.462 |
| SV2 | Size and variety | No | Geographic | 3.491 | 3.304 | 3.759 | -0.187 | -0.169 | -0.457 |
| SV3 | Size and variety | Yes | National | 2.186 | 2.067 | 2.683 | -0.005 | 0.012 | -0.361 |
| SV4 | Size and variety | Yes | Geographic | 2.227 | 2.096 | 2.748 | 0.004 | 0.019 | -0.346 |

All 48 models passed independent QR 2SLS coefficient and structural-residual checks. Size and variety exogeneity remain maintained assumptions. Full coefficients, clustered standard errors, first stages and admissibility checks are saved in specification_comparison/market_size/.
