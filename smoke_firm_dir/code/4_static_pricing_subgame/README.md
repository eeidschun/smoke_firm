# Static pricing subgame

Run scripts from the repository root. These scripts read the selected saved demand fit and built panels; no raw rebuild or canonical replacement.

1. `1_static_demand_functions.R`: sourced helpers for stable one-nest shares, own-price derivatives, and markups. Signed alpha is negative. Fringe total utility is a fixed input; its share responds to incumbent prices.
2. `2_recover_observed_market.R`: recover observed incumbent residuals, calibrated fringe utility, markups, marginal costs, and variable profits. Reproduce chosen coefficients by independent QR 2SLS, reconcile full market totals, and validate reconstructed shares and pricing FOC identities.
3. `3_validate_observed_recovery.R`: observed-market finite differences (own, cross, fringe response), sigma-zero limit, extreme utilities, parameter guards, unchanged input hashes.

```
Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/2_recover_observed_market.R
Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/3_validate_observed_recovery.R
```

Outputs: `output/static_pricing_subgame/observed_recovery_2026-10-27/`. Main handoff to the future manual solver: `observed_market_inputs.rds`; human-readable results: `incumbent_recovery.csv`, `fringe_market_recovery.csv`, and summaries/validation files. The manual equilibrium routines and runner are now scripts 4–6, described below.

Chosen fit: `constant_available_B_noFE_p_it_volume_weighted_Annual`, sales-weighted taxes, liquid-volume-weighted prices, no firm FE, nicotine only, constant intensity, exogenous current quality. Full-precision coefficients are read from saved estimates rather than copied/rounded.

The fitted sample is 528 rows; complete observed markets contain 540 rows. All 12 BLU 2018 incumbent rows excluded from matched demand estimation for missing device size are retained as competitors, explicitly flagged as out-of-estimation-sample inversion. No device size or demand residual is imputed: their observed shares identify total utility conditional on the chosen coefficients. This does not extend the estimation sample or refit demand. Strategic-firm counts can be six; no five-firm cap is imposed on observed replication.

Each brand is treated as a vertically integrated single-product pricing firm. Marginal costs are effective integrated-channel costs per mL, inclusive of whatever components are implicit in the observed retail price convention; no additional tax is mechanically subtracted. Variable profit is `(price - mc) * liquid volume`, before unspecified fixed operating costs. This is not manufacturer-specific profit or net operating profit. Fringe utility is calibrated from observed shares, with its existing revenue/volume price and equal-UPC quality used for residual decomposition.

Cost recovery assumes the observed prices satisfy the maintained interior pricing FOCs. Positive costs and exact observed-share reconstruction do not establish instrument validity or an independently validated supply model. All negative costs would be reported without clipping. Scripts 4–6 implement the manual damped iteration, independent starts, FOC/map residual checks and unilateral best-response verification. Failure is reported explicitly; no black-box solver is used.


## Manual pricing solution (October 28, 2026)

4. `4_manual_pricing_functions.R`: simultaneous damped markup iteration; explicit scalar bracketing/bisection for verification of unilateral optima. The bisection is a diagnostic with rivals fixed, not the multi-firm equilibrium algorithm.
5. `5_solve_observed_pricing.R`: 132 markets, four starts (cost + 0.1, +1, +5, heterogeneous cost increments), damping 0.25/0.5/1; all 1,584 attempts. Predeclared reference: cost+1, damping 0.5. Observed prices are used for comparison only, never for initial prices or stopping.
6. `6_validate_manual_pricing.R`: saved residuals, own-profit curvature, mass balance, synthetic permutation invariance, iteration-budget failure, sigma-zero unilateral optima and immutable recovery inputs.

```
Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/5_solve_observed_pricing.R
Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/6_validate_manual_pricing.R
```

Outputs: `output/static_pricing_subgame/manual_fixed_point_2026-10-28/`. All attempts converged to observed prices (largest discrepancy below 3e-10 real dollars/mL). Damping 0.5 required at most 36 iterations; no damping required as many as 1,335. The manually bisected unilateral best responses differ from reference solved prices by less than 1e-10; maximum apparent profit improvement is rounding-scale (under 5e-8 real dollars).

Step tolerance: 1e-10; un-damped map-residual tolerance: 1e-9; scaled FOC tolerance: 1e-8; iteration cap: 2,000. A run must satisfy all three convergence criteria. Saved traces include every iteration. No price/cost clipping, cost adjustment, re-estimation, future transition, or fixed operating cost is introduced.

For fixed rivals and price >= marginal cost, `A_i` increases with own price, so `g_i = 1 + alpha*(p_i-mc_i)*A_i` decreases strictly from 1 to negative values. Its unique zero maximizes own profit on that domain; below-cost profits are nonpositive and profit tends to zero at infinite price. This justifies the bisection-based global unilateral check for the maintained single-product passive-fringe model. It does not prove uniqueness of the joint multi-firm equilibrium, and replicating prices from inverted costs does not independently validate the supply assumptions.


## Visual audit

`7_audit_plots.R` creates the nine-page `audit/pricing_audit_plots.pdf` booklet, standalone PNG/PDF plots, profit-curve data, and a separately labeled 10% marginal-cost perturbation for the largest-volume firm in the latest month. Run from the repository root:

```
Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/7_audit_plots.R
```

The audit directory is inside `output/static_pricing_subgame/manual_fixed_point_2026-10-28/`. Existing pricing/recovery inputs remain unchanged. The cost-perturbation scenario is a numerical check with demand states held fixed, not a new empirical estimate.
