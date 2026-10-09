# Demand specification comparison

The original Main and Partial IV tables use the same 7% incumbent sample and UPC-unweighted representative price, without additional controls or month FE. The product-size tables below use a separately reported complete-case sample.
N = 540; 132 month clusters. Coefficients shown with month-clustered standard errors in parentheses.
Alpha is the signed price slope in +alpha * price (expected negative). Nicotine enters uninstrumented in every model.
National count includes all eligible brands nationwide. Geographic count is the distinct-brand union over states where the focal firm sells.
Tax means the geographic population-weighted tax. In full IV, tax and count jointly instrument both endogenous regressors.

## Main

| | M1 | M2 | M3 | M4 | M5 | M6 |
|---|---:|---:|---:|---:|---:|---:|
| Estimator | Full IV | Full IV | Full IV | Full IV | OLS | OLS |
| Firm FE | No | No | Yes | Yes | No | Yes |
| Count IV | National | Geographic | National | Geographic | -- | -- |
| Tax IV | Yes | Yes | Yes | Yes | No | No |
| alpha: price | -0.211 (0.117) | -0.202 (0.122) | -0.339 (0.220) | -0.332 (0.225) | -0.035 (0.007) | -0.046 (0.016) |
| beta_a: nicotine | 0.007 (0.013) | -0.000 (0.016) | 0.037 (0.010) | 0.035 (0.011) | 0.055 (0.003) | 0.057 (0.005) |
| sigma: nesting | 3.422 (0.665) | 3.630 (0.769) | 4.024 (1.087) | 4.159 (1.162) | 0.975 (0.057) | 0.911 (0.052) |
| N | 540 | 540 | 540 | 540 | 540 | 540 |
| Price first-stage F | 62.93 | 63.11 | 36.32 | 36.81 | -- | -- |
| Share first-stage F | 55.00 | 39.17 | 48.63 | 37.91 | -- | -- |
| sigma in [0,1) | No | No | No | No | Yes | Yes |

## Partial IV

| | D1 | D2 | D3 | D4 | D5 | D6 |
|---|---:|---:|---:|---:|---:|---:|
| Estimator | Share-only IV | Share-only IV | Share-only IV | Share-only IV | Price-only IV | Price-only IV |
| Firm FE | No | No | Yes | Yes | No | Yes |
| Count IV | National | Geographic | National | Geographic | -- | -- |
| Tax IV | No | No | No | No | Yes | Yes |
| alpha: price | -0.461 (0.642) | -1.349 (6.524) | -0.263 (0.103) | -0.292 (0.131) | -0.303 (0.056) | -0.490 (0.109) |
| beta_a: nicotine | -0.025 (0.117) | -0.193 (1.216) | 0.038 (0.010) | 0.035 (0.011) | 0.082 (0.008) | 0.089 (0.012) |
| sigma: nesting | 5.699 (7.026) | 15.538 (71.921) | 3.536 (1.165) | 3.883 (1.520) | 1.345 (0.058) | 1.130 (0.062) |
| N | 540 | 540 | 540 | 540 | 540 | 540 |
| Price first-stage F | -- | -- | -- | -- | 62.57 | 37.91 |
| Share first-stage F | 0.46 | 0.04 | 8.06 | 5.45 | -- | -- |
| sigma in [0,1) | No | No | No | No | No | No |

## Interpretation and assumptions

- Partial-IV models are diagnostics: share-only IV treats price as exogenous; price-only IV treats within-nest share as exogenous. Their first stages include that untreated regressor as a control.
- OLS treats both regressors as exogenous; an admissible OLS sigma does not validate that assumption.
- First-stage F entries are joint tests of the excluded instruments using month-clustered covariance. They are not conditional weak-identification tests for the two-endogenous-regressor models. The CSV also includes IID F and partial R2.
- Month clustering allows within-month dependence, not serial dependence across months. No model here tests or establishes exclusion. All IV specifications are exactly identified.
- Full-IV sigma estimates remain outside [0,1); estimates are neither constrained nor clipped. No model is automatically selected for cost recovery.
- Each model was checked against an independent explicit-dummy QR OLS/2SLS calculation and structural-residual reconstruction.
- Product size has been constructed as a reusable characteristic; none of the estimates above include it. Size and variety specifications appear below.

## Product size and UPC variety: common complete-case sample

All sixteen models use N = 528 and 132 month clusters. Excluded firm-months are listed in excluded_firm_months.csv; unresolved BLU UPC 088796900752 is not filled automatically. No incomplete-UPC mean is substituted; the entire firm-month is excluded. Existing shares, prices, market totals and instruments are retained.

Size is the unweighted mean mL per cartridge/disposable over eligible device UPCs. Bottles and mixed types are excluded from that mean. Variety is log(n_upcs), counting all distinct eligible UPCs (positive sales and at least three stores), including bottles. Nicotine, size and variety are treated as exogenous controls; endogenous assortment choice remains a concern. Price and within-nest log share are jointly instrumented by geographic tax and the indicated count. No month FE. Standard errors are clustered by month.

### Baseline

|  | B1 | B2 | B3 | B4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.113 (0.065) | -0.103 (0.069) | -0.002 (0.070) | 0.005 (0.071) |
| beta_a | 0.013 (0.010) | 0.007 (0.011) | 0.036 (0.007) | 0.035 (0.007) |
| beta_size | -- | -- | -- | -- |
| beta_variety | -- | -- | -- | -- |
| sigma | 2.887 (0.356) | 3.036 (0.408) | 2.384 (0.231) | 2.409 (0.234) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 74.35 | 74.60 | 35.30 | 35.78 |
| ln_s_i_g first-stage F | 73.52 | 51.21 | 84.50 | 70.46 |

### Size

|  | S1 | S2 | S3 | S4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.115 (0.081) | -0.100 (0.085) | -0.024 (0.075) | -0.015 (0.076) |
| beta_a | 0.012 (0.009) | 0.008 (0.010) | 0.015 (0.009) | 0.015 (0.009) |
| beta_size | -0.018 (0.146) | 0.024 (0.155) | -0.214 (0.091) | -0.208 (0.091) |
| beta_variety | -- | -- | -- | -- |
| sigma | 2.880 (0.340) | 3.045 (0.400) | 2.267 (0.190) | 2.299 (0.195) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 68.21 | 68.72 | 34.95 | 35.28 |
| ln_s_i_g first-stage F | 53.86 | 36.58 | 70.61 | 67.22 |

### Variety

|  | V1 | V2 | V3 | V4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.189 (0.095) | -0.187 (0.100) | 0.011 (0.065) | 0.019 (0.066) |
| beta_a | 0.006 (0.014) | 0.001 (0.015) | 0.040 (0.007) | 0.039 (0.007) |
| beta_size | -- | -- | -- | -- |
| beta_variety | -0.483 (0.182) | -0.523 (0.202) | 0.134 (0.103) | 0.130 (0.106) |
| sigma | 3.316 (0.563) | 3.487 (0.641) | 2.315 (0.236) | 2.347 (0.241) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 84.32 | 82.61 | 36.67 | 36.94 |
| ln_s_i_g first-stage F | 52.10 | 40.79 | 67.65 | 57.27 |

### Size and variety

|  | SV1 | SV2 | SV3 | SV4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.189 (0.095) | -0.187 (0.101) | -0.005 (0.067) | 0.004 (0.068) |
| beta_a | 0.006 (0.013) | 0.001 (0.015) | 0.022 (0.009) | 0.021 (0.009) |
| beta_size | -0.033 (0.166) | 0.003 (0.175) | -0.201 (0.084) | -0.194 (0.085) |
| beta_variety | -0.459 (0.185) | -0.525 (0.213) | 0.173 (0.099) | 0.167 (0.102) |
| sigma | 3.281 (0.528) | 3.491 (0.623) | 2.186 (0.192) | 2.227 (0.198) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 69.77 | 69.73 | 36.50 | 36.83 |
| ln_s_i_g first-stage F | 34.15 | 27.61 | 60.12 | 55.49 |

First-stage F values are joint month-clustered tests of excluded instruments, not conditional weak-identification statistics. Size exogeneity is an assumption. Reviewed retail pack-volume corrections are propagated through the rebuilt sales panel; the NCP market-size input is unchanged. All coefficients and structural residuals passed an independent explicit-dummy QR 2SLS check.

Compare S, V and SV against B with the same instrument and fixed effects to isolate control effects. All sixteen columns retain the same sample, including variety-only models that do not require size themselves.

Detailed models, coefficients, first stages, checks, estimation sample and excluded firm-months are saved under specification_comparison/product_size/.

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
