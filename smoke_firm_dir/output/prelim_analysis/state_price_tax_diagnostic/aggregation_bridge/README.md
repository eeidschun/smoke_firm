# Matched incumbent aggregation bridge

All national comparisons retain exactly the 528 SV3/SV4 incumbent firm-months. Current national representative price and geographic population-weighted tax are independently reconstructed and agree within 1e-8/1e-10. SV3/SV4 price-stage tax slopes reproduced within 1e-5.

National fits use firm FE, national brand count, nicotine, capacity and log variety unless named without_product_controls. SV4 substitutes geographic count. National errors clustered by month. Alternative price averages first compute equal-UPC local prices, then average states using equal, population, or mL-sales weights. p_volume is aggregate revenue/volume. tax_sales uses contemporaneous mL weights and is diagnostic only; it is not an approved instrument.

State fits retain precisely those firm-months but expand them across observed operating states. Default weights 1/number of operating states give each firm-month total weight one; the unweighted fit is explicit. State errors clustered by state and month. Controls remain national firm-month attributes, not local product attributes. Count_only retains brand count and FE but drops all three product controls. Brand count is absorbed when month FE are included. All state comparisons use the same state rows. Full month FE are valid for this price diagnostic, not a proposed structural demand specification. N_controls rows include exactly the named controls, brand count and firm FE.

The remaining national/state differences include local versus pooled UPC assortment, geographic averaging, and unit of regression observation. Sign changes cannot alone prove instrument validity, causality, or the cause of sigma > 1. No canonical inputs, demand fits, or NCP data changed.

| Model | N | Tax slope | SE | 95% CI |
|---|---:|---:|---:|---|
| N_current_SV3 | 528 | -1.6985 | 0.3399 | [-2.3708, -1.0262] |
| N_current_SV4 | 528 | -1.6954 | 0.3420 | [-2.3719, -1.0190] |
| N_current_without_product_controls | 528 | 0.8438 | 0.2927 | [0.2647, 1.4228] |
| N_controls_a_it | 528 | -1.4322 | 0.3399 | [-2.1047, -0.7597] |
| N_controls_avg_ml_per_ecig | 528 | -1.1000 | 0.2817 | [-1.6572, -0.5428] |
| N_controls_a_it_avg_ml_per_ecig | 528 | -1.6724 | 0.3496 | [-2.3639, -0.9809] |
| N_controls_log_upc_variety | 528 | 0.7751 | 0.2849 | [0.2115, 1.3387] |
| N_controls_a_it_log_upc_variety | 528 | -1.4119 | 0.3313 | [-2.0673, -0.7565] |
| N_controls_avg_ml_per_ecig_log_upc_variety | 528 | -1.0876 | 0.2805 | [-1.6424, -0.5327] |
| N_p_it_tax_pop | 528 | -1.6985 | 0.3399 | [-2.3708, -1.0262] |
| N_p_it_tax_equal | 528 | -1.3947 | 0.4508 | [-2.2865, -0.5029] |
| N_p_it_tax_sales | 528 | -1.6662 | 0.7891 | [-3.2271, -0.1052] |
| N_p_state_equal_tax_pop | 528 | -0.7594 | 0.4631 | [-1.6755, 0.1566] |
| N_p_state_equal_tax_equal | 528 | -2.5660 | 0.5468 | [-3.6476, -1.4843] |
| N_p_state_equal_tax_sales | 528 | -1.8402 | 1.0354 | [-3.8884, 0.2080] |
| N_p_state_pop_tax_pop | 528 | -0.7580 | 0.4719 | [-1.6916, 0.1755] |
| N_p_state_pop_tax_equal | 528 | -2.5465 | 0.5344 | [-3.6037, -1.4894] |
| N_p_state_pop_tax_sales | 528 | -1.8717 | 1.0594 | [-3.9675, 0.2241] |
| N_p_state_sales_tax_pop | 528 | -0.9193 | 0.4199 | [-1.7499, -0.0886] |
| N_p_state_sales_tax_equal | 528 | -2.4169 | 0.5216 | [-3.4487, -1.3852] |
| N_p_state_sales_tax_sales | 528 | -2.1207 | 1.0058 | [-4.1104, -0.1310] |
| N_p_volume_tax_pop | 528 | -2.2452 | 0.4344 | [-3.1046, -1.3858] |
| N_p_volume_tax_equal | 528 | -4.0770 | 0.2853 | [-4.6414, -3.5126] |
| N_p_volume_tax_sales | 528 | -2.7712 | 0.6865 | [-4.1292, -1.4132] |
| S_brand_count_only | 25044 | 0.9176 | 0.0716 | [0.7737, 1.0615] |
| S_brand_controls | 25044 | 0.9227 | 0.0717 | [0.7788, 1.0667] |
| S_brand_STATE_count_only | 25044 | 0.6354 | 0.1596 | [0.3149, 0.9560] |
| S_brand_STATE_controls | 25044 | 0.6406 | 0.1567 | [0.3259, 0.9554] |
| S_brand_STATE_year_month_count_only | 25044 | 0.8394 | 0.1503 | [0.5375, 1.1414] |
| S_brand_STATE_year_month_controls | 25044 | 0.8409 | 0.1485 | [0.5426, 1.1393] |
| S_state_FE_unweighted | 25044 | 0.6336 | 0.1580 | [0.3163, 0.9509] |
| S_state_month_FE_volume_price | 25044 | 0.8871 | 0.1067 | [0.6728, 1.1015] |

Reproduce: `Rscript --vanilla smoke_firm_dir/code/2_preliminary_analysis/18_aggregation_price_tax_bridge.R`.
