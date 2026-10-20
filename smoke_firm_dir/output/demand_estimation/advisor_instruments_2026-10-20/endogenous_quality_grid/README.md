# Endogenous-quality results

Price, within-nest log share and current quality a_it are jointly endogenous. Every set includes geographic tax and lagged quality, plus at least one count. Lagged quality is intended to help identify current quality; 2SLS uses the full instrument set jointly for all three regressors rather than assigning one instrument mechanically to each. Size and variety, where included, remain exogenous.

All 432 fits use the same 524 observations/131 month clusters as the exogenous-quality common-lag comparisons. Four control groups, two FE choices, two prices, three market sizes, nine eligible instrument sets. Three excluded instruments = exactly identified; four = one overidentifying restriction; five = two. Tax plus lag alone has only two instruments and is not fitted because three endogenous regressors would be underidentified by the order condition.

All coefficient and structural-residual QR checks pass; SW statistics for all three endogenous variables use numerator df L-3+1 and pass independent conditional-IV residual and full-design sandwich checks. All original fits/inputs remain unchanged. No overidentification test or exclusion validity is claimed. Lag quality requires orthogonality to current demand errors despite possible persistence. These conventional estimates and intervals do not establish adequate identification.

Full results: [all_tables.md](all_tables.md).

Reproduce: `Rscript --vanilla smoke_firm_dir/code/3_demand_estimation/14_endogenous_quality_grid.R`.
