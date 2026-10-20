# Advisor meeting notes

Updated: 2026-10-20. Meeting date: TBD.

## 1. Checked how far representative price times volume is from observed revenue

The original representative price is the unweighted average of eligible UPC prices per mL. Compared this price times firm liquid volume with observed real revenue for the same eligible products.

Across 540 incumbent firm-months, January 2013-December 2023:

| Measure | Result |
|---|---:|
| Observed real revenue | $4.757 billion |
| Original representative price times volume | $7.162 billion |
| Aggregate overstatement | $2.405 billion (50.56%) |
| Median firm-month signed discrepancy | +35.17% |
| Middle 50% of signed discrepancies | +2.33% to +61.25% |
| Full range of signed discrepancies | -42.98% to +186.06% |

The original measure overstates revenue in 419 firm-months and understates it in 121. VUSE and JUUL contribute the largest dollar discrepancies. These revenue totals cover the full sample period and eligible scanner sales.

## 2. Constructed a volume-weighted representative price that recovers revenue

I constructed a separate representative price using e-liquid volume as the UPC weights:

`p_volume_weighted = sum_u(q_u * p_u) / sum_u(q_u) = firm real revenue / firm liquid volume`.

Multiplying this price by firm liquid volume recovers observed eligible revenue. 

## 3. Expanded demand instrument and price comparisons

The historical **48 specifications** were four control sets x two firm-FE choices x two original brand-count instruments x three market-size definitions. The new exercise also varies price definition, instrument composition, sample availability, and whether quality is endogenous. It is no longer a 48-model exercise.

**All results, rather than a selected subset, are included in the [meeting results appendix](demand_results_appendix.md).** Each table states the price, controls, firm FE and sample, lists the complete excluded instrument set, and reports alpha and sigma (clustered SE) for all three market sizes. Endogenous-quality tables also report the quality slope. The [specification index](demand_specification_index.csv) gives endogenous variables, excluded instruments, instrument count and overidentifying degrees of freedom for every run.

### What varies

- **Price:** original UPC-unweighted price versus e-liquid-volume-weighted price.
- **Controls:** nicotine only; plus device size; plus log UPC variety; or both product controls. Nicotine remains in demand in every specification, with its exogeneity assumption varied below.
- **Firm FE:** with or without; no month FE.
- **Market size:** annual, monthly or constant purchasing intensity, using the existing definitions.
- **Counts:** original national/geographic active-brand count (including fringe), annual incumbent count (>7% annual volume share), or monthly >7% count. New counts can replace an original count or supplement it; combinations are explicitly listed.
- **Lag quality:** previous calendar month's delivered nicotine, including pre-incumbency history when observed. Its role differs depending on whether current quality is treated as exogenous or endogenous.

Monthly sales by firms on the annual incumbent roster yield exactly the annual incumbent count here, because each roster member sells in all 12 months. The distinct monthly instrument instead reapplies the >7% threshold to each month's shares, without changing the demand roster.

### Two different quality assumptions

| Quality treatment | Jointly endogenous demand regressors | Example complete excluded instrument set | Identification |
|---|---|---|---|
| Exogenous | Price, within-nest log share | Tax + annual incumbent count | 2 instruments / 2 endogenous: exact |
| Exogenous | Price, within-nest log share | Tax + active-brand count + annual incumbent count | 3 / 2: one overidentifying restriction |
| Exogenous | Price, within-nest log share | Tax + annual incumbent count + lagged quality | 3 / 2: one overidentifying restriction |
| Endogenous | Price, within-nest log share, current quality | Tax + annual incumbent count + lagged quality | 3 / 3: exact |
| Endogenous | Price, within-nest log share, current quality | Tax + active-brand count + annual incumbent count + lagged quality | 4 / 3: one overidentifying restriction |

Tax in every row is geographic population-weighted tax. All excluded instruments enter jointly; lagged quality is intended to help identify current quality in the endogenous-quality specifications, rather than being assigned exclusively to it. Current quality is an included exogenous control only in the exogenous-quality specifications. Tax plus lagged quality alone has too few instruments for three endogenous regressors and was not estimated with endogenous quality.

### Scope and samples

| Quality assumption | Sample | Instrument sets | Other combinations | Fits |
|---|---|---:|---|---:|
| Exogenous | 528 complete-size rows / 132 months | 9 without lag | 4 controls x 2 FE x 2 prices x 3 market sizes | 432 |
| Exogenous | 524 common-lag rows / 131 months | 19, including nonlag baselines | Same | 912 |
| Endogenous | 524 common-lag rows / 131 months | 9 with lag and sufficient instrument count | Same | 432 |
| **Total** | | | | **1,776** |

These totals include deliberate sample-matched comparisons. The earlier 224 exploratory fits are not added to this total because they overlap and used a different sample rule for nicotine-only controls. All four control groups here retain the original complete-size sample rule. Common-lag models additionally exclude four January 2013 observations with no December 2012 quality. Existing BLU 2018 exclusions remain. Counts and market totals are constructed before these exclusions.

### Interpretation and checks

**357 of 1,776 runs have 0 < sigma < 1.** There are enough that families are more informative than a list in the main notes. These counts include deliberate sample-matched repetitions; they are not independent successes. The [complete qualifying-run list](sigma_between_zero_and_one.csv) records each specification, instrument list, identification status, sigma, SE and alpha. The [family breakdown](sigma_family_summary.md) includes denominators.

**The clearest pattern is the combination of volume-weighted price and an incumbent-count instrument, often without firm FE.** The qualifying runs are not confined to one control set, one market-size definition, lag-quality models, or endogenous-quality models.

| Price and firm FE family | Runs with 0 < sigma < 1 / all runs in family |
|---|---:|
| Volume-weighted price, no firm FE | 232 / 444 |
| Volume-weighted price, firm FE | 83 / 444 |
| Unweighted price, no firm FE | 35 / 444 |
| Unweighted price, firm FE | 7 / 444 |

- **Instruments:** 297 qualifying runs include annual incumbent count (possibly with monthly count, active-brand count or lag quality); 55 include monthly >7% count without annual count; the remaining 5 use tax + lagged quality alone. No tax + original active-brand-count set qualifies, even when supplemented only with lagged quality, under either quality treatment. Every qualifying run therefore uses an incumbent-count instrument or the weak tax-plus-lag-only set.
- **Lagged quality is not required:** 171 qualifying runs omit it and 186 include it. The five qualifying tax-plus-lag-only models belong to the previously flagged weak-instrument family and should not be treated as a resolution on the basis of their point estimates.
- **Quality treatment:** 260 / 1,344 exogenous-quality runs qualify; 97 / 432 endogenous-quality runs qualify. All endogenous-quality runs include lag quality by construction, so this is not evidence that lag quality itself causes admissibility.
- **Controls:** qualifying counts are 64 / 444 for nicotine only, 80 / 444 with size, 90 / 444 with log variety, and 123 / 444 with both. Neither size nor variety is universally required.
- **Market size:** 118 / 592 annual, 133 / 592 monthly, and 106 / 592 constant-intensity runs qualify. No market-size definition is universally required.

Of the 357 qualifying sigma estimates, **354 also have a negative price coefficient; 3 do not**. Admissibility here refers only to the sigma point estimate: it does not require its confidence interval to lie within (0,1), a positive quality coefficient, or strong instruments. The full results should be checked for those features before selecting a specification.

All original 48 baseline coefficients and covariance matrices reproduce. New fits pass independent QR coefficient and structural-residual checks. Conditional F calculations account for two or three endogenous regressors; all three first stages are exported for endogenous-quality models. Original inputs and fits remain unchanged.

Overidentification df count restrictions; no overidentification test has been run. Neither an admissible sigma nor additional instruments establish exclusion. Lagged quality may correlate with persistent demand shocks; share-threshold counts depend on observed sales. Conventional intervals are not weak-IV-robust. No model selected and no sigma clipping.
