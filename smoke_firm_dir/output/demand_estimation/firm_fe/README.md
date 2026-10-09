# Firm-fixed-effects demand estimates

Equation: y_it = mu_i + beta_a*a_it + alpha*p_it + sigma*ln_s_i_g + xi_it.
Alpha is the signed price coefficient (expected negative). Historical no-FE results report the opposite alpha convention.
Both regressions use geographic tax and one of two alternative count instruments, jointly instrumenting price and within-nest share.
Same sample: 540 observations, 9 firms, 132 months. Firm FE, no month FE, no weights; standard errors cluster by month.

| Specification | Parameter | Estimate | Clustered SE | 95% CI |
|---|---|---:|---:|---|
| national_count | alpha | -0.33871 | 0.21952 | [-0.77297, 0.09555] |
| national_count | sigma | 4.02380 | 1.08723 | [1.87299, 6.17461] |
| national_count | beta_a | 0.03724 | 0.01041 | [0.01665, 0.05784] |
| geographic_count | alpha | -0.33164 | 0.22537 | [-0.77747, 0.11419] |
| geographic_count | sigma | 4.15871 | 1.16221 | [1.85957, 6.45784] |
| geographic_count | beta_a | 0.03481 | 0.01091 | [0.01323, 0.05639] |

## First-stage joint excluded-instrument tests

| Specification | Outcome | Clustered F | IID F | Partial R2 |
|---|---|---:|---:|---:|
| national_count | p_it | 36.325 | 68.631 | 0.2063 |
| national_count | ln_s_i_g | 48.630 | 8.725 | 0.0320 |
| geographic_count | p_it | 36.814 | 67.395 | 0.2034 |
| geographic_count | ln_s_i_g | 37.907 | 7.594 | 0.0280 |

## Model checks

- national_count: alpha < 0: TRUE; 0 <= sigma < 1: FALSE; admissible for cost recovery on these checks: FALSE.
- geographic_count: alpha < 0: TRUE; 0 <= sigma < 1: FALSE; admissible for cost recovery on these checks: FALSE.

These first-stage tests are not a complete conditional weak-identification assessment with two endogenous regressors. They do not establish exclusion. Month clustering does not address dependence across months.
The two excluded instruments exactly identify two endogenous regressors, so no overidentification test is available. No marginal-cost recovery is run.
Coefficients and structural residuals were verified against an independent dummy-variable QR 2SLS calculation.
National and geographic counts coincide in 528/540 observations; both include the focal firm and all eligible fringe brands.
