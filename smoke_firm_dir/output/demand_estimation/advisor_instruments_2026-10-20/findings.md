# Findings: advisor instrument comparisons

Focal comparison: both controls and firm FE, 524 firm-months and 131 month clusters. Common sample excludes January 2013 (four incumbent observations lack December 2012 quality), plus the existing BLU 2018 size exclusions. Tax is retained throughout. Entries are sigma (month-clustered SE). All first-stage coefficients, price coefficients, intervals and broader comparisons are in the CSVs.

| Instrument set beyond tax | Sigma: unweighted price | Sigma: volume-weighted price | Share SW F: unweighted | Share SW F: volume weighted |
|---|---:|---:|---:|---:|
| National | 2.231 (0.197) | 2.247 (0.262) | 78.12 | 72.98 |
| Geographic | 2.272 (0.205) | 2.324 (0.287) | 75.93 | 65.31 |
| Annual | 1.130 (0.168) | 0.162 (0.376) | 167.10 | 31.63 |
| Monthly | 1.310 (0.196) | -0.118 (0.675) | 85.87 | 7.30 |
| Lag | 0.871 (3.401) | 1.356 (1.108) | 0.10 | 0.65 |
| Annual_Lag | 1.130 (0.168) | 0.213 (0.357) | 85.25 | 17.77 |
| Monthly_Lag | 1.310 (0.196) | 0.069 (0.605) | 43.33 | 4.21 |

Annual count with volume-weighted price gives alpha -0.489 (SE 0.137) and sigma 0.162 (SE 0.376; conventional 95% CI -0.582 to 0.907). Annual count plus lag gives sigma 0.213 (SE 0.357). The monthly count alone gives sigma -0.118 (SE 0.675), below the maintained lower bound, while monthly plus lag gives 0.069 (SE 0.605). These are sensitivity results, not a selected model. Conventional confidence intervals are not weak-IV-robust confidence sets.

Adding an incumbent count to an existing brand-count baseline generally leaves focal sigma above one: annual additions give 1.229/1.201 (unweighted national/geographic) and 1.202/1.155 (volume weighted); monthly additions give 1.666/1.649 and 1.876/1.904. Replacing the original count and adding a new count impose different moment conditions and need not deliver similar estimates.

Lag alone means tax plus lagged a_it, with neither brand count nor incumbent count. It has very low conditional share F (0.10 unweighted, 0.65 weighted), so the unweighted admissible sigma point estimate is uninformative as a resolution. Lagged quality validity requires considering persistence in unobserved demand; annual and monthly threshold counts also require an exclusion argument because they depend on observed sales shares. No overidentification/exclusion test is reported by this comparison.

Annual-roster monthly counts are exactly duplicate annual counts. The distinct Monthly specification recomputes the >7% threshold using each month's eligible volume, without changing demand alternatives. Monthly counts range 3-7; annual counts range 3-6. This construction is explicitly separate from changing the demand roster.

Validation: saved SV3/SV4 baseline coefficients and covariance matrices reproduce; all 224 new fits pass QR coefficient checks; all 76 focal conditional F statistics pass independent conditional-IV residual/full-design sandwich checks. Source hashes are unchanged. See README.md for instrument definitions and reproduction commands.
