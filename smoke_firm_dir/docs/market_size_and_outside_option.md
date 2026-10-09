# Current market size and outside-option construction

Status: 2026-10-08. The investigation is motivated by IV nesting estimates above one; none of the three existing market-size alternatives resolves that issue. See [current handoff](handoff_sigma_market_size_2026-10-08.md).

Let q_it be firm i's eligible mL and Q_t = sum_i q_it + q_Ft include incumbents and fringe. Let A_y be the US adult population July estimate, used for every month of year y. Let H_t be NCP e-cigarette-purchasing households with usable volume observations, v_ht their monthly purchased mL, and w_ht their projection weights. The saved household-weighted series is:

`k_t = sum_{h in H_t}(w_ht * v_ht) / sum_{h in H_t} w_ht`.

This is conditional on purchasing; it is not mean consumption over all adults. The external builder first sums usable e-cigarette purchase volume within household-weight-month after removing exact duplicate selected purchase rows.

| Saved variable | Market size |
|---|---|
| `M_t` (baseline) | `A_y * mean(k_tau over months tau in year y)` |
| `M_t_k_monthly` | `A_y * k_t` |
| `M_t_k_const` | `A_y * mean(k_tau over all 132 months)` |

The annual and full-period means are arithmetic means of the monthly projection-weighted series, not separately pooled household estimates. Baseline M_t is constant within each calendar year. Constant-intensity M_t still varies between years through population.

For any version:

`inside share s_gt = Q_t / M_t`

`outside share s_0t = 1 - Q_t / M_t`

`firm share s_it = q_it / M_t`

`dependent variable log(s_it/s_0t) = log(q_it/(M_t-Q_t))`

`within-nest share s_it/s_gt = q_it/Q_t`.

Thus M_t changes the outside share and dependent variable, but not within-nest shares. The implemented market-size comparisons recompute these quantities on a common 528-row sample; excluded firm-months are still included in the underlying market totals where eligible. Sample exclusion does not redefine the market.

## Interpretation under review

The current outside share is a residual potential-volume share. It is not an observed non-vaping rate or the share of all US purchases that are not e-cigarettes. Household purchasing intensity is multiplied by adult population, and the numerator is eligible scanner retail volume. Compatibility of household/person units and retail coverage remains unresolved. Adult participation and consumption-opportunity interpretations require different quantity definitions; a denominator substitution alone cannot turn mL shares into people shares.

Inline plots showed outside shares around 98.91%-99.93%, an eligible-sales increase around 2018 and a market-size increase around 2022 for annual/monthly intensity. The plots and plotting code were deliberately not saved. These patterns motivate investigation, not an automatic rescaling of M_t.

All three existing alternatives have already been estimated. With size, variety and firm FE, sigma is 2.186/2.227 (annual), 2.067/2.096 (monthly), and 2.683/2.748 (constant), for national/geographic count IVs. Full results: [comparison](../output/demand_estimation/specification_comparison/README.md).

The separate NCP input was left unchanged by explicit user instruction. No replacement market-size definition is yet approved. Assess economic comparability before changing the denominator; do not optimize it to obtain an admissible sigma.
