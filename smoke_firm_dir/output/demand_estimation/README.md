# Preliminary demand estimates

Both specifications use the same 7% incumbent sample, unweighted representative price, and geographic tax instrument.
They differ only in the national versus geographic all-brand count. Both regressors are jointly instrumented.
An intercept is included; no fixed effects or regression weights. Standard errors cluster by month (132 clusters).
These errors allow dependence within a month, not across months. No causal-validity conclusion follows from first-stage significance.

| Specification | Parameter | Estimate | Clustered SE | 95% CI |
|---|---|---:|---:|---|
| national_count | intercept | -0.50687 | 1.98687 | [-4.43737, 3.42362] |
| national_count | alpha | 0.21091 | 0.11686 | [-0.02028, 0.44210] |
| national_count | sigma | 3.42199 | 0.66482 | [2.10681, 4.73716] |
| national_count | beta_a | 0.00719 | 0.01323 | [-0.01898, 0.03337] |
| geographic_count | intercept | -0.05416 | 2.25095 | [-4.50707, 4.39876] |
| geographic_count | alpha | 0.20169 | 0.12244 | [-0.04053, 0.44391] |
| geographic_count | sigma | 3.63025 | 0.76862 | [2.10973, 5.15078] |
| geographic_count | beta_a | -0.00027 | 0.01581 | [-0.03155, 0.03100] |

Alpha is the negative of the estimated price coefficient; the model uses -alpha * price.
The intercept is estimated separately; xi_hat is y minus the intercept and all structural regressors evaluated at observed values.

## Model restrictions

- national_count: alpha > 0: TRUE; 0 <= sigma < 1: FALSE. Eligible for cost recovery on these checks: FALSE.
- geographic_count: alpha > 0: TRUE; 0 <= sigma < 1: FALSE. Eligible for cost recovery on these checks: FALSE.

Out-of-range estimates are retained and flagged, never clipped. No marginal-cost recovery or dynamic estimation is run.

## First-stage joint excluded-instrument tests

| Specification | Outcome | IID F | Month-clustered F | Partial R2 |
|---|---|---:|---:|---:|
| national_count | p_it | 41.573 | 62.934 | 0.1343 |
| national_count | ln_s_i_g | 6.975 | 54.999 | 0.0254 |
| geographic_count | p_it | 41.550 | 63.109 | 0.1342 |
| geographic_count | ln_s_i_g | 5.718 | 39.169 | 0.0209 |

The CSV additionally reports incremental tax and count tests. These are not conditional weak-identification tests for the two-endogenous-variable system.

- national_count Kleibergen-Paap diagnostic: Unavailable: requires numeric/complex matrix/vector arguments
- geographic_count Kleibergen-Paap diagnostic: Unavailable: requires numeric/complex matrix/vector arguments

The system is exactly identified, so there is no overidentification test. Exclusion remains an assumption.

## Residual diagnostics

See residuals_over_time.png and residual_summary_by_firm.csv / residual_summary_by_year.csv for trends and outliers.
The sample changes composition over time; annual residual averages also reflect that composition.
In the initial runs, firm residual paths show persistent differences and substantial time movement; they are not featureless noise.

## Verification

The estimator checks share identities, duplicate keys, finite inputs, common sample size, rank, structural residual reconstruction,
and agreement with an independent QR 2SLS solution and month-clustered sandwich covariance.

Implementation reference: https://lrberge.github.io/fixest/reference/feols.html
Diagnostic reference: https://lrberge.github.io/fixest/reference/fitstat.html
