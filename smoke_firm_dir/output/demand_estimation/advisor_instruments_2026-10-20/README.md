# Advisor instrument comparisons: 2026-10-20

Both price measures; baseline nicotine-only and size-plus-variety controls; with/without firm FE. Geographic tax is retained in every instrument set. Annual baseline market size, unchanged demand roster/shares. Month-clustered standard errors; no month FE. No sigma clipping or model selection.

Annual count: brands with annual eligible liquid-volume share strictly above 7%. Monthly count: brands with monthly eligible liquid-volume share strictly above 7%, recomputed each month. Monthly threshold membership is used only for the instrument, not the demand roster. Counting active members of the existing annual roster monthly instead produces exactly the annual count; this duplicate is not added as a separate instrument. Counts include the focal brand if it qualifies.

Lag quality: previous calendar month's firm-level a_it, from all eligible UPCs including pre-incumbency months, not the previous observed incumbent row. No lag imputation. Current a_it remains an exogenous control. Missing-lag rows and all count series are exported. Existing nonlag baselines run on available samples AND common-lag samples, allowing sample effects to be separated from instrument effects. Both prices use identical observations in each comparison.

Instrument sets replace the original count with annual count, monthly count or lag; add each to national/geographic baselines; combine count and lag; and include annual and monthly together. Canonical inputs/old fits remain unchanged. All fits pass explicit-dummy QR 2SLS slope checks. First-stage CSV contains coefficients, clustered SEs and SW conditional F (reduced numerator df L-1, explicit-dummy CR1 correction). Conditional F is descriptive; it does not establish exclusion or calibrated weak-IV bias control.

Economic validity remains unresolved: contemporaneous counts depend on quantities and threshold crossing; lag quality can correlate with persistent unobserved demand shocks. Adding instruments is not evidence of validity. No exclusion claim follows from admissible sigma.

## Both controls plus firm FE, common-lag sample

| Instrument set | Alpha unweighted | Sigma unweighted | Alpha volume weighted | Sigma volume weighted |
|---|---:|---:|---:|---:|
| Annual | -0.2473 | 1.1298 | -0.4888 | 0.1624 |
| Annual_Lag | -0.2484 | 1.1304 | -0.4581 | 0.2131 |
| Annual_Monthly | -0.2442 | 1.1465 | -0.4471 | 0.2209 |
| Annual_Monthly_Lag | -0.2450 | 1.1469 | -0.4275 | 0.2547 |
| Geographic | 0.0145 | 2.2722 | 0.0275 | 2.3241 |
| Geographic+a_lag1 | 0.0118 | 2.2840 | 0.0127 | 2.3122 |
| Geographic+incumbent_annual | -0.0252 | 1.2012 | -0.0129 | 1.1545 |
| Geographic+incumbent_annual+lag | -0.0311 | 1.2097 | -0.0410 | 1.1176 |
| Geographic+incumbent_monthly | -0.0029 | 1.6492 | 0.1403 | 1.9036 |
| Geographic+incumbent_monthly+lag | -0.0079 | 1.6586 | 0.1127 | 1.8590 |
| Lag | -0.3067 | 0.8710 | -0.2037 | 1.3560 |
| Monthly | -0.2061 | 1.3099 | -0.5559 | -0.1183 |
| Monthly_Lag | -0.2082 | 1.3095 | -0.4845 | 0.0686 |
| National | 0.0050 | 2.2307 | 0.0091 | 2.2471 |
| National+a_lag1 | 0.0023 | 2.2421 | -0.0039 | 2.2387 |
| National+incumbent_annual | -0.0317 | 1.2287 | 0.0083 | 1.2024 |
| National+incumbent_annual+lag | -0.0377 | 1.2378 | -0.0193 | 1.1679 |
| National+incumbent_monthly | -0.0118 | 1.6655 | 0.1293 | 1.8765 |
| National+incumbent_monthly+lag | -0.0167 | 1.6754 | 0.1048 | 1.8404 |

Total models: 224

Reproduce: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/10_advisor_instruments.R`.
