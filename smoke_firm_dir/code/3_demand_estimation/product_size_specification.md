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
