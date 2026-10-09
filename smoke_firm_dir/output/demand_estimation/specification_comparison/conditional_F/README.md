# Sanderson-Windmeijer conditional F diagnostics

Run date: 2026-10-08.

Price and within-nest log share are jointly endogenous. Geographic tax and the indicated brand count are the two excluded instruments. Tests condition on the other instrumented regressor, nicotine, the indicated controls, and firm FE where applicable. No month FE. Full sample: 540 rows; matched: 528 rows, excluding BLU 2018. Both have 132 month clusters.

| Sample | Model | Controls | Firm FE | Count | Ordinary F price | Ordinary F share | SW F price | SW F share |
|---|---|---|---|---|---:|---:|---:|---:|
| Full | M1 | Baseline | No | National | 62.93 | 55.00 | 55.79 | 62.68 |
| Full | M2 | Baseline | No | Geographic | 63.11 | 39.17 | 58.65 | 49.08 |
| Full | M3 | Baseline | Yes | National | 36.32 | 48.63 | 15.91 | 18.95 |
| Full | M4 | Baseline | Yes | Geographic | 36.81 | 37.91 | 15.08 | 17.91 |
| Matched | B1 | Baseline | No | National | 74.35 | 73.52 | 164.50 | 140.61 |
| Matched | B2 | Baseline | No | Geographic | 74.60 | 51.21 | 138.17 | 105.27 |
| Matched | B3 | Baseline | Yes | National | 35.30 | 84.50 | 75.88 | 92.09 |
| Matched | B4 | Baseline | Yes | Geographic | 35.78 | 70.46 | 77.36 | 91.82 |
| Matched | S1 | Size | No | National | 68.21 | 53.86 | 97.39 | 129.33 |
| Matched | S2 | Size | No | Geographic | 68.72 | 36.58 | 92.99 | 93.31 |
| Matched | S3 | Size | Yes | National | 34.95 | 70.61 | 76.35 | 100.63 |
| Matched | S4 | Size | Yes | Geographic | 35.28 | 67.22 | 76.42 | 105.18 |
| Matched | V1 | Variety | No | National | 84.32 | 52.10 | 45.99 | 50.14 |
| Matched | V2 | Variety | No | Geographic | 82.61 | 40.79 | 43.38 | 40.39 |
| Matched | V3 | Variety | Yes | National | 36.67 | 67.65 | 81.03 | 70.47 |
| Matched | V4 | Variety | Yes | Geographic | 36.94 | 57.27 | 82.51 | 67.62 |
| Matched | SV1 | Size and variety | No | National | 69.77 | 34.15 | 86.99 | 53.55 |
| Matched | SV2 | Size and variety | No | Geographic | 69.73 | 27.61 | 77.77 | 40.95 |
| Matched | SV3 | Size and variety | Yes | National | 36.50 | 60.12 | 81.38 | 79.57 |
| Matched | SV4 | Size and variety | Yes | Geographic | 36.83 | 55.49 | 82.31 | 78.38 |

## Method and validation

For each endogenous x_j, estimate its conditional 2SLS regression on the other actual endogenous regressor x_o and exogenous W, with instruments [W,Z]. Regress the resulting structural residual on [W,Z]. Form the Wald quadratic of the two excluded-instrument coefficients using month-clustered scores from this auxiliary regression. The residual used for covariance is v_j - delta*v_o (the SW variance adjustment). Divide the Wald by L-K+1 = 2-2+1 = 1, not by two.

The reported cluster covariance uses CR1 = G/(G-1) * (N-1)/(N-rank([W,Z])); explicit firm dummies count toward rank. F-reference df are (1,131). CSV p-values test zero conditional relevance/rank loss; they do not test adequate strength or exclusion. IID statistics and their residual df are provided separately, not substituted for the clustered results.

Implementation follows the SW block in ivreg2/ivreghdfe (conditional actual-regressor residuals, auxiliary excluded-IV Wald, reduced numerator df, and cluster correction). All 40 calculations pass independent fixest conditional-IV residual and sandwich::vcovCL full-design covariance checks plus an IID auxiliary-regression check. Input hashes are unchanged after the run. No demand fits or canonical inputs were overwritten.

Market-size alternatives change only the demand outcome/outside share. Their saved first-stage variables were checked identical to the matched sample, so all 48 market-size fits inherit the corresponding B/S/V/SV conditional statistics. Re-estimating these tests for each denominator would duplicate results.

## Interpretation

Full-sample M1-M4: conditional F ranges from 15.08 to 62.68; firm-FE models are the weakest (price 15.08-15.91, share 17.91-18.95). Matched B/S/V/SV models: 40.39-164.50. With both controls and firm FE, national-count price/share F are 81.38/79.57; geographic-count values are 82.31/78.38. These results do not show an obvious collapse in conditional relevance explaining sigma > 1. The large change between M3/M4 and B3/B4 also makes sample influence worth investigating; it does not establish why BLU 2018 matters.

A high ordinary first-stage F can coexist with a low SW conditional F if the instruments predict nearly the same combination of price and share. Small conditional statistics make separate alpha and sigma estimation vulnerable to weak identification. A large statistic does not establish instrument exclusion or validate the market-size construction. F=10 is only a rough descriptive benchmark here; IID Stock-Yogo critical values do not provide calibrated bias/size guarantees under month clustering. Month clustering does not address dependence across months. These tests alone cannot establish the cause of sigma > 1 or select a supply-side specification.

Sources: [Sanderson and Windmeijer (2016)](https://ifs.org.uk/journals/weak-instrument-f-test-linear-iv-models-multiple-endogenous-variables); [ivreg2/ivreghdfe source, SW block](https://github.com/sergiocorreia/ivreghdfe/blob/master/src/ivreghdfe.ado#L6038).

Reproduce from repository root: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/8_sw_conditional_F.R`.
