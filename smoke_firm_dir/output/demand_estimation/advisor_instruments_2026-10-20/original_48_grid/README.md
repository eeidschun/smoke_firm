# Expanded original 48-specification grid

Run: 2026-10-20.

The earlier 48 models were four control sets (B: nicotine only; S: plus size; V: plus log UPC variety; SV: both), two firm-FE choices, two original count instruments, and three market sizes. All four control groups retain the original common complete-size sample (528 rows), including B and V. This differs from the separate earlier advisor run, which allowed B to use 540 rows.

This extension runs both prices and all 19 advisor instrument sets, with annual/monthly/constant market sizes. Nonlag sets run on all 528 available rows and again on the 524-row common-lag sample; sets containing lag quality use only the latter. Both price measures use identical observations. Current nicotine is always exogenous; price and within-nest log share are jointly endogenous. Geographic tax is always an excluded instrument. Firm FE where indicated; no month FE; month-clustered standard errors. No canonical input, roster or saved original estimate is replaced.

Full instrument names and numbers are explicit in specifications.csv. Annual/monthly counts and lag construction are documented in ../README.md. Monthly means the monthly >7% threshold, not the duplicate monthly count of annual-roster sellers. Counts are constructed before sample exclusions; excluded firms remain part of underlying market totals.

Total models: 1344 ; unique first-stage designs: 448 .

Validation: all original 48 baseline coefficients and covariance matrices reproduce. Every new fit passes explicit-dummy QR coefficient and structural-residual checks. Every first-stage design's two SW conditional F calculations pass full-design sandwich checks. First stages do not depend on market size and are exported once per design; join by design_id. Hashes of source files remain unchanged.

## Reading the results

sigma_tables.csv gives sigma (clustered SE) by control set, FE, price, sample and complete instrument-set label, with market sizes side by side. coefficients.csv includes alpha, all controls, p-values and conventional confidence intervals. first_stage_coefficients.csv contains individual instrument/control coefficients, ordinary joint F and conditional SW F. Summary counts are descriptive, not a model-selection rule. No exclusion or overidentification test is claimed; conventional intervals are not weak-IV-robust.

## Both controls plus firm FE: common-lag sample

| Price | Complete excluded instrument set | Sigma annual | Sigma monthly | Sigma constant |
|---|---|---:|---:|---:|
| Unweighted | TaxIV_geo + incumbent_annual | 1.130 (0.168) | 1.093 (0.166) | 1.915 (0.211) |
| Unweighted | TaxIV_geo + incumbent_annual + a_lag1 | 1.130 (0.168) | 1.094 (0.166) | 1.914 (0.211) |
| Unweighted | TaxIV_geo + incumbent_annual + incumbent_monthly | 1.146 (0.165) | 1.093 (0.164) | 1.941 (0.205) |
| Unweighted | TaxIV_geo + incumbent_annual + incumbent_monthly + a_lag1 | 1.147 (0.166) | 1.094 (0.165) | 1.939 (0.204) |
| Unweighted | TaxIV_geo + n_brands_overlap | 2.272 (0.205) | 2.136 (0.224) | 2.790 (0.267) |
| Unweighted | TaxIV_geo + n_brands_overlap + a_lag1 | 2.284 (0.202) | 2.149 (0.221) | 2.793 (0.266) |
| Unweighted | TaxIV_geo + n_brands_overlap + incumbent_annual | 1.201 (0.139) | 1.158 (0.151) | 1.970 (0.165) |
| Unweighted | TaxIV_geo + n_brands_overlap + incumbent_annual + a_lag1 | 1.210 (0.140) | 1.167 (0.151) | 1.974 (0.166) |
| Unweighted | TaxIV_geo + n_brands_overlap + incumbent_monthly | 1.649 (0.153) | 1.464 (0.166) | 2.400 (0.193) |
| Unweighted | TaxIV_geo + n_brands_overlap + incumbent_monthly + a_lag1 | 1.659 (0.153) | 1.474 (0.165) | 2.404 (0.193) |
| Unweighted | TaxIV_geo + a_lag1 | 0.871 (3.401) | 0.572 (4.046) | 2.532 (2.594) |
| Unweighted | TaxIV_geo + incumbent_monthly | 1.310 (0.196) | 1.098 (0.204) | 2.188 (0.254) |
| Unweighted | TaxIV_geo + incumbent_monthly + a_lag1 | 1.310 (0.196) | 1.097 (0.204) | 2.188 (0.253) |
| Unweighted | TaxIV_geo + n_brands_3st | 2.231 (0.197) | 2.106 (0.217) | 2.722 (0.259) |
| Unweighted | TaxIV_geo + n_brands_3st + a_lag1 | 2.242 (0.195) | 2.119 (0.213) | 2.724 (0.258) |
| Unweighted | TaxIV_geo + n_brands_3st + incumbent_annual | 1.229 (0.138) | 1.184 (0.149) | 1.988 (0.167) |
| Unweighted | TaxIV_geo + n_brands_3st + incumbent_annual + a_lag1 | 1.238 (0.139) | 1.193 (0.149) | 1.992 (0.168) |
| Unweighted | TaxIV_geo + n_brands_3st + incumbent_monthly | 1.666 (0.148) | 1.487 (0.162) | 2.394 (0.191) |
| Unweighted | TaxIV_geo + n_brands_3st + incumbent_monthly + a_lag1 | 1.675 (0.149) | 1.498 (0.162) | 2.397 (0.191) |
| Volume weighted | TaxIV_geo + incumbent_annual | 0.162 (0.376) | 0.267 (0.380) | -0.201 (0.616) |
| Volume weighted | TaxIV_geo + incumbent_annual + a_lag1 | 0.213 (0.357) | 0.302 (0.358) | -0.058 (0.568) |
| Volume weighted | TaxIV_geo + incumbent_annual + incumbent_monthly | 0.221 (0.359) | 0.398 (0.341) | -0.007 (0.566) |
| Volume weighted | TaxIV_geo + incumbent_annual + incumbent_monthly + a_lag1 | 0.255 (0.343) | 0.409 (0.326) | 0.084 (0.530) |
| Volume weighted | TaxIV_geo + n_brands_overlap | 2.324 (0.287) | 2.236 (0.315) | 1.573 (0.341) |
| Volume weighted | TaxIV_geo + n_brands_overlap + a_lag1 | 2.312 (0.279) | 2.222 (0.307) | 1.593 (0.329) |
| Volume weighted | TaxIV_geo + n_brands_overlap + incumbent_annual | 1.155 (0.238) | 1.171 (0.259) | 0.613 (0.351) |
| Volume weighted | TaxIV_geo + n_brands_overlap + incumbent_annual + a_lag1 | 1.118 (0.227) | 1.132 (0.248) | 0.632 (0.343) |
| Volume weighted | TaxIV_geo + n_brands_overlap + incumbent_monthly | 1.904 (0.274) | 1.790 (0.304) | 1.108 (0.262) |
| Volume weighted | TaxIV_geo + n_brands_overlap + incumbent_monthly + a_lag1 | 1.859 (0.256) | 1.740 (0.288) | 1.116 (0.256) |
| Volume weighted | TaxIV_geo + a_lag1 | 1.356 (1.108) | 1.095 (1.277) | 3.164 (3.258) |
| Volume weighted | TaxIV_geo + incumbent_monthly | -0.118 (0.675) | -0.358 (0.745) | -1.129 (1.128) |
| Volume weighted | TaxIV_geo + incumbent_monthly + a_lag1 | 0.069 (0.605) | -0.174 (0.670) | -0.585 (0.911) |
| Volume weighted | TaxIV_geo + n_brands_3st | 2.247 (0.262) | 2.175 (0.290) | 1.554 (0.325) |
| Volume weighted | TaxIV_geo + n_brands_3st + a_lag1 | 2.239 (0.256) | 2.165 (0.285) | 1.569 (0.314) |
| Volume weighted | TaxIV_geo + n_brands_3st + incumbent_annual | 1.202 (0.228) | 1.219 (0.250) | 0.674 (0.328) |
| Volume weighted | TaxIV_geo + n_brands_3st + incumbent_annual + a_lag1 | 1.168 (0.218) | 1.183 (0.240) | 0.689 (0.322) |
| Volume weighted | TaxIV_geo + n_brands_3st + incumbent_monthly | 1.876 (0.252) | 1.779 (0.285) | 1.133 (0.247) |
| Volume weighted | TaxIV_geo + n_brands_3st + incumbent_monthly + a_lag1 | 1.840 (0.238) | 1.738 (0.272) | 1.139 (0.243) |

Reproduce: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/12_advisor_48_grid.R`.

All tables with complete instrument lists and counts: [all_tables.md](all_tables.md). Recreate tables with: Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/13_advisor_grid_tables.R
