# SV3 and SV4: first stages and reduced forms

All six regressions use the saved 528-row matched sample, 132 month clusters, nicotine, device size, log UPC variety, and firm FE. No month FE. SV3 uses national brand count; SV4 uses geographic union brand count. Tax is geographic population-weighted real dollars per mL in both models. Brand count is in levels. Entries are coefficients (month-clustered standard errors), using the existing fixest covariance conventions. CSV includes t statistics, p-values and 95% confidence intervals with 131 reference df. Firm FE are absorbed; no common intercept is displayed.

Price first stage: p_it on tax, count and controls. Share first stage: log(s_it/s_gt) on the same regressors. Reduced form: y = log(s_it/s_0t) on the same regressors, using the annual baseline market size. Price and share are not included in the reduced form.

## SV3

| Regressor | Price first stage | Within-nest share first stage | Demand reduced form |
|---|---:|---:|---:|
| Geographic tax | -1.69852 (0.33985) | 0.75910 (0.13625) | 1.66828 (0.24426) |
| National brand count | -0.09273 (0.01599) | -0.02368 (0.00243) | -0.05131 (0.00438) |
| Nicotine | 0.06344 (0.01895) | 0.01200 (0.00768) | 0.04742 (0.01112) |
| Device size (mL) | -0.81780 (0.08512) | 0.10051 (0.04155) | 0.02310 (0.06031) |
| Log UPC variety | 0.04594 (0.12432) | 0.13623 (0.05498) | 0.47068 (0.07631) |

## SV4

| Regressor | Price first stage | Within-nest share first stage | Demand reduced form |
|---|---:|---:|---:|
| Geographic tax | -1.69543 (0.34195) | 0.74823 (0.13440) | 1.65907 (0.24193) |
| Geographic brand count | -0.09216 (0.01579) | -0.02214 (0.00245) | -0.04969 (0.00429) |
| Nicotine | 0.06295 (0.01899) | 0.01159 (0.00763) | 0.04688 (0.01105) |
| Device size (mL) | -0.83156 (0.08670) | 0.09479 (0.04032) | 0.01342 (0.05905) |
| Log UPC variety | 0.07129 (0.12289) | 0.14252 (0.05682) | 0.48453 (0.07916) |

## Exact-identification relationship

For each excluded instrument z, its reduced-form coefficient obeys rho_z = alpha*pi_price,z + sigma*pi_share,z. This identity was checked against the saved IV estimates; decomposition is in iv_reduced_form_identity.csv. It helps read the first stages and outcome association jointly, but it is an algebraic relationship rather than an exclusion test.

All slope coefficients passed explicit-firm-dummy QR checks. Both first stages in each specification reproduce saved IV first-stage coefficients and covariance matrices. Saved inputs and demand fits retain their original hashes. No specification is selected and the IV investigation remains open.

Reproduce: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/9_sv_first_stages_reduced_form.R`.
