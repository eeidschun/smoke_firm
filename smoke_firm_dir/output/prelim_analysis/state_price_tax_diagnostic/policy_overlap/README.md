# Policy overlap diagnostic

Source: raw/demand_side_first_stage_data/mypricedt.RData, object mypricedt. Only alt=ecigarette is used. Policy values are observed, not carried forward or imputed.

192 observations in eight states and 59 distinct months, spanning March 2018–November 2023, with irregular coverage. Current retail price and tax (real dollars/mL) are matched to those exact state-months. The old price is per count and is not substituted. The source contains no tau_per_ct_real, so the old regression cannot be reproduced as supplied.

All comparisons use the same 192 rows. Errors clustered by state and month; only eight state clusters, so conventional p-values and intervals require caution. fixest reported a non-positive-semidefinite covariance adjustment during fitting. These are descriptive sensitivity checks. min_age is constant TRUE and is absorbed. Other policies may be absorbed by fixed effects; dropped variables are listed below. No canonical input or demand fit changed.

| Model | Tax slope | SE | 95% CI | Dropped |
|---|---:|---:|---|---|
| price_pooled_baseline | 0.8473 | 0.0310 | [0.7740, 0.9206] |  |
| price_pooled_policies | 0.6792 | 0.0821 | [0.4851, 0.8734] | min_age |
| price_state_baseline | 0.3412 | 0.7112 | [-1.3406, 2.0229] |  |
| price_state_policies | 0.3412 | 0.7131 | [-1.3450, 2.0273] | lic, self_service_law, min_age |
| price_month_baseline | 0.8853 | 0.0385 | [0.7942, 0.9764] |  |
| price_month_policies | 0.8095 | 0.1424 | [0.4729, 1.1462] | min_age |
| price_state_month_baseline | 0.1861 | 0.5600 | [-1.1380, 1.5102] |  |
| price_state_month_policies | 0.1099 | 0.5050 | [-1.0843, 1.3041] | lic, self_service_law, min_age |
| price_volume_pooled_baseline | 0.8040 | 0.4052 | [-0.1542, 1.7622] |  |
| price_volume_pooled_policies | -0.3343 | 0.2661 | [-0.9636, 0.2949] | min_age |
| price_volume_state_baseline | -1.6380 | 0.7123 | [-3.3224, 0.0464] |  |
| price_volume_state_policies | -1.6380 | 0.7142 | [-3.3269, 0.0508] | lic, self_service_law, min_age |
| price_volume_month_baseline | 1.5203 | 0.0601 | [1.3782, 1.6625] |  |
| price_volume_month_policies | 1.3334 | 0.3956 | [0.3979, 2.2688] | min_age |
| price_volume_state_month_baseline | -0.9362 | 0.3524 | [-1.7696, -0.1029] |  |
| price_volume_state_month_policies | -0.9678 | 0.3499 | [-1.7951, -0.1404] | lic, self_service_law, min_age |

Run: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/17_state_policy_price_tax_diagnostic.R`. Complete 2013–2023 policy coverage remains unavailable. These results do not establish the cause of the negative national firm-level tax coefficient.
