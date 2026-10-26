# Nested-logit demand: troubleshooting sigma above one

**October 14, 2026**

## 1. Problem and decisions needed

The IV nesting parameter exceeds one in the baseline demand equation:

$$\log(s_{it}/s_{0t})=c+\alpha p_{it}+\beta_a a_{it}+\sigma\log(s_{it}/s_{gt})+\xi_{it}.$$

Here $i$ indexes incumbent brands and $t$ indexes months. $s_{it}$ is the brand's share of potential market volume, $s_{0t}$ is the outside share, and $s_{gt}$ is total e-cigarette share, including incumbents and fringe. $p_{it}$ is real price per mL, $a_{it}$ is delivered nicotine concentration, and $\xi_{it}$ captures unobserved demand attributes. The signed price coefficient $\alpha$ is expected to be negative; the maintained nesting range is $0\leq\sigma<1$.

Retail corrections, firm fixed effects, additional product controls, and alternative market-size constructions have not resolved the out-of-range estimate.

Potential threats: (i) outside option; (ii) exclusion violation; (iii) conditioning on nicotine or capacity reverses the national tax–price association; and (iv) aggregation, common changes over time, or endogenous characteristics may explain that sensitivity.

## 2. Market, observations, and variables

The demand market is national e-cigarette retail sales in a calendar month, January 2013–December 2023. All individually modeled incumbent brands and the aggregate fringe are in one e-cigarette nest; the outside alternative is a singleton.

Eligible UPC-months have a known brand, positive units and liquid volume, and at least three reporting stores nationally in the month. Eligible non-incumbent brands are pooled into fringe volume. Fringe sales enter total e-cigarette volume and the share denominators, but the fringe is not a separate $i$ to be estimated in the demand regression.

An incumbent is a brand with **annual eligible liquid-volume share above 7%**, with its assignment fixed within the year. This demand roster is distinct from the dynamic model's proposed cap of five firms: that will come into play in the supply side. The full estimation sample contains 540 incumbent brand-months. For comparisons involving capacity, BLU's capacity measure is unresolved in all 12 months of 2018. These observations are omitted from the matched estimation sample, leaving 528 observations. All matched specifications use these same 528 rows, including specifications without capacity. BLU remains an incumbent, and its eligible sales remain in total e-cigarette volume when constructing every other brand's shares.

Price and nicotine concentration are averaged over all eligible UPCs, including bottles and mixed product types. Capacity uses only eligible cartridge/pod and disposable UPCs with a defined per-device capacity. Thus the capacity average can cover a narrower assortment than price and nicotine.

| Variable        | Construction                                                    |
|-----------------|-----------------------------------------------------------------|
| $q_{it}$ | Incumbent brand's eligible liquid volume, mL |
| $Q_t$ | Total eligible liquid mL across incumbents and fringe |
| $p_{it}$ | unweighted UPC mean of UPC-month real revenue divided by corrected mL |
| $a_{it}$ | unweighted-UPC delivered nicotine, mg/mL, using the existing 0.68 transfer factor |
| Capacity | unweighted-UPC mean mL per cartridge/disposable; excludes bottles and mixed types |
| Variety | Log number of distinct eligible UPCs, including bottles |

**Representative price times firm volume generally does not equal observed revenue.** This matters for later profit measurement.

## 3. Estimating equation and maintained assumptions

$$\log(s_{it}/s_{0t})=c+\alpha p_{it}+\beta_a a_{it}+\sigma\log(s_{it}/s_{gt})+\gamma_C C_{it}+\gamma_V V_{it}+\mu_i+\xi_{it}.$$

Capacity, variety and firm effects appear only where specified in alternative attempts. Nicotine is included in every structural demand specification reported below. Nicotine, capacity and variety are treated as exogenous; **this remains an assumption.**

IV instruments endogenous **price and within-nest log share** with the two excluded instruments defined below. Both instruments enter both first stages.

All structural fits use month-clustered standard errors (132 clusters). I don't include month FE, because with one inside nest,

$$\log(s_{it}/s_{0t})=\log(s_{it}/s_{gt})+\log(s_{gt}/s_{0t}).$$

Full month effects absorb the second term and create a degeneracy for identifying the intended demand relationship. Month clustering does not address serial dependence across months.

## 4. Instrument definitions

### Instrument 1 — State-population-weighted tax

Let $S_{it}$ be the set of states where brand $i$ has positive sales of a nationally eligible UPC in month $t$. The instrument is

$$T_{it}=\sum_{s\in S_{it}}\frac{P_{s,y(t)}}{\sum_{r\in S_{it}}P_{r,y(t)}}\tau_{st}.$$

Here $P$ is annual state population and $\tau_{st}$ is the saved closed-system excise-tax rate in real dollars per mL in state $s$. The weights are population weights. Store eligibility is imposed nationally; three stores in each state are not required. Both tax changes and changes in a firm's sales footprint can change this instrument. This **may be endogenous**, and the closed-system tax may imperfectly represent open-system/refill products.

### Instrument 2, alternative A — National active-brand count

$N_t^{national}$ is the number of **distinct eligible active brands anywhere in the US in month $t$**. A brand qualifies through its eligible positive-sales UPCs; a brand with many UPCs counts once. This count includes the focal brand, other incumbents, and fringe brands (for ex can include 10 fringe brands). It is not the incumbent count, UPC count, number of states, or number of parent companies. It is common across focal firms within a month.

### Instrument 2, alternative B — Active-brand count across the firm’s operating states

$N_{it}^{geo}$ counts distinct eligible brands with positive sales in at least one state in $S_{it}$, the union of states where focal brand $i$ operates. Each competitor counts once across that union. This also includes the focal brand and fringe brands. It does not require that a competitor operate in every focal-firm state.

**$N_t^{national} = N_{it}^{geo}$ in 528 of the 540 firm-months**, meaning that in those observations, every nationally eligible brand sells in at least one state where the focal firm $i$ sells.

*The baseline specifications use Instrument 1 together with Instrument 2A. Alternative specifications replace 2A with 2B while retaining the same tax instrument. In the tables below, “national” and “geographic” refer to these two brand-count alternatives.*

## 5. Market size and outside option

Let $A_y$ be annual US adult population (July estimate held fixed within year). NCP supplies monthly purchasing intensity

$$k_t=\frac{\sum_{h\in H_t}w_{ht}v_{ht}}{\sum_{h\in H_t}w_{ht}},$$

where $H_t$ contains e-cigarette-purchasing households with usable volume, $v_{ht}$ is monthly purchased mL, and $w_{ht}$ is the projection weight. Thus $k_t$ is **conditional on household purchase**, not an average over all households or all adults.

| Attempted definitions    | Potential volume $M_t$                                   |
|--------------------------|---------------------------------------------------------|
| Annual baseline | Adult population times arithmetic mean of monthly $k_t$ within year |
| Monthly intensity | Adult population times current month's $k_t$ |
| Constant intensity | Adult population times arithmetic mean of $k_t$ over all 132 months |

Constant intensity still permits annual changes in population. 

$$s_{it}=q_{it}/M_t,\qquad s_{gt}=Q_t/M_t,\qquad s_{0t}=1-Q_t/M_t.$$

$$\log(s_{it}/s_{0t})=\log\!\left(\frac{q_{it}}{M_t-Q_t}\right),\qquad s_{it}/s_{gt}=q_{it}/Q_t.$$

Changing $M_t$ changes the demand outcome and outside share, but not within-nest share.  All outside shares are positive, approximately 98.91%–99.93% across alternatives.

**Interpretation unresolved:** the denominator multiplies purchasing-household intensity by adults, while the numerator is scanner-covered eligible retail volume. Household/person units and channel coverage may need alignment. The outside share is residual potential volume, not the fraction of adults who do not vape. Changing the denominator alone cannot convert mL shares to adult participation shares. No alternative denominator is approved merely because it yields a smaller sigma.

## 6. Complete structural specification inventory

I tried 60 distinct structural specifications: 12 full-sample models plus 48 matched-sample (due to BLU issue) market-size models.

### 12 Full-sample baseline: M1–M6 and D1–D6

All use 540 observations, annual baseline market size, nicotine, no capacity or variety. M1–M4 are full IV. M5/M6 are OLS. D1–D4 instrument share only and treat price as exogenous; D5/D6 instrument price only and treat share as exogenous. The untreated endogenous candidate enters the other regressor's first stage as an ordinary control.

| Model | Estimator | Firm FE | Excluded instruments | Alpha | Sigma |
|---|---|---|---|---:|---:|
| M1 | Full IV | No | Tax + national count | -0.211 | 3.422 |
| M2 | Full IV | No | Tax + geographic count | -0.202 | 3.630 |
| M3 | Full IV | Yes | Tax + national count | -0.339 | 4.024 |
| M4 | Full IV | Yes | Tax + geographic count | -0.332 | 4.159 |
| M5 | OLS | No | None | -0.035 | 0.975 |
| M6 | OLS | Yes | None | -0.046 | 0.911 |
| D1 | Share-only IV | No | National count | -0.461 | 5.699 |
| D2 | Share-only IV | No | Geographic count | -1.349 | 15.538 |
| D3 | Share-only IV | Yes | National count | -0.263 | 3.536 |
| D4 | Share-only IV | Yes | Geographic count | -0.292 | 3.883 |
| D5 | Price-only IV | No | Tax | -0.303 | 1.345 |
| D6 | Price-only IV | Yes | Tax | -0.490 | 1.130 |

Some partial-IV first stages are very weak: share-only IV excluded-count F statistics range from 0.04 to 8.06. Without firm fixed effects, the share-only IV first-stage F statistics are particularly low: 0.46 with national count (D1) and 0.04 with geographic count (D2); adding firm fixed effects raises them to 8.06 (D3) and 5.45 (D4), respectively. This is a different diagnostic from conditional strength in full IV.

### Matched full-IV specifications: B, S, V, SV

All use 528 observations and include nicotine. B adds neither control; S adds capacity; V adds log UPC variety; SV adds both. Each family has four instrument/FE settings:

| Suffix | Count instrument | Firm FE |
|---|---|---|
| 1 | National | No |
| 2 | Geographic | No |
| 3 | National | Yes |
| 4 | Geographic | Yes |

Every one of B1–B4, S1–S4, V1–V4 and SV1–SV4 is estimated under annual, monthly and constant intensity market definitions: 16 × 3 = 48 specifications. The tables below enumerate all 48 and show sigma and signed alpha.
### Sigma: all market-size variants

| Model | Controls | FE | Count | Annual | Monthly | Constant |
|---|---|---|---|---:|---:|---:|
| B1 | Baseline | No | National | 2.887 | 2.773 | 3.103 |
| B2 | Baseline | No | Geographic | 3.036 | 2.902 | 3.296 |
| B3 | Baseline | Yes | National | 2.384 | 2.255 | 2.952 |
| B4 | Baseline | Yes | Geographic | 2.409 | 2.271 | 2.999 |
| S1 | Size | No | National | 2.880 | 2.771 | 2.916 |
| S2 | Size | No | Geographic | 3.045 | 2.914 | 3.144 |
| S3 | Size | Yes | National | 2.267 | 2.160 | 2.641 |
| S4 | Size | Yes | Geographic | 2.299 | 2.181 | 2.705 |
| V1 | Variety | No | National | 3.316 | 3.142 | 3.979 |
| V2 | Variety | No | Geographic | 3.487 | 3.291 | 4.192 |
| V3 | Variety | Yes | National | 2.315 | 2.169 | 3.054 |
| V4 | Variety | Yes | Geographic | 2.347 | 2.191 | 3.099 |
| SV1 | Size and variety | No | National | 3.281 | 3.123 | 3.469 |
| SV2 | Size and variety | No | Geographic | 3.491 | 3.304 | 3.759 |
| SV3 | Size and variety | Yes | National | 2.186 | 2.067 | 2.683 |
| SV4 | Size and variety | Yes | Geographic | 2.227 | 2.096 | 2.748 |

### Signed alpha: all market-size variants

| Model | Controls | FE | Count | Annual | Monthly | Constant |
|---|---|---|---|---:|---:|---:|
| B1 | Baseline | No | National | -0.113 | -0.105 | -0.302 |
| B2 | Baseline | No | Geographic | -0.103 | -0.097 | -0.289 |
| B3 | Baseline | Yes | National | -0.002 | 0.008 | -0.294 |
| B4 | Baseline | Yes | Geographic | 0.005 | 0.012 | -0.281 |
| S1 | Size | No | National | -0.115 | -0.106 | -0.359 |
| S2 | Size | No | Geographic | -0.100 | -0.093 | -0.338 |
| S3 | Size | Yes | National | -0.024 | -0.010 | -0.351 |
| S4 | Size | Yes | Geographic | -0.015 | -0.004 | -0.334 |
| V1 | Variety | No | National | -0.189 | -0.171 | -0.458 |
| V2 | Variety | No | Geographic | -0.187 | -0.169 | -0.455 |
| V3 | Variety | Yes | National | 0.011 | 0.025 | -0.314 |
| V4 | Variety | Yes | Geographic | 0.019 | 0.030 | -0.303 |
| SV1 | Size and variety | No | National | -0.189 | -0.171 | -0.462 |
| SV2 | Size and variety | No | Geographic | -0.187 | -0.169 | -0.457 |
| SV3 | Size and variety | Yes | National | -0.005 | 0.012 | -0.361 |
| SV4 | Size and variety | Yes | Geographic | 0.004 | 0.019 | -0.346 |

## 7. Instrument-strength assessment

Sanderson–Windmeijer conditional F diagnostics were computed for price and within-nest share in M1–M4 and all 16 matched settings, accounting for the other endogenous regressor. Their first-stage data do not change with market size, so the same matched diagnostics apply to all 48 fits.

| Full-IV model | Price conditional F | Share conditional F |
|---|---:|---:|
| M1 | 55.79 | 62.68 |
| M2 | 58.65 | 49.08 |
| M3 | 15.91 | 18.95 |
| M4 | 15.08 | 17.91 |
| B3 | 75.88 | 92.09 |
| B4 | 77.36 | 91.82 |
| SV3 | 81.38 | 79.57 |
| SV4 | 82.31 | 78.38 |

Across all matched settings, the month-clustered Sanderson–Windmeijer conditional first-stage F statistics range from 40.39 to 164.50. There is no obvious collapse of conditional relevance in the matched full-IV fits. **The change from M3/M4 to B3/B4 highlights influence of the excluded BLU 2018 observations even before adding controls.** Serial dependence and weak-IV-robust inference remain open.

## 8. Odd tax–price sign and conditioning on characteristics

On the same 528 observations, with geographic tax, national count and firm FE, the price-first-stage tax slope changes as follows. **These are price-regression diagnostics**, not additional structural demand fits.

| Included characteristics | Tax slope | Month-clustered SE |
|---|---:|---:|
| None | +0.84379 | 0.29271 |
| Variety only | +0.77509 | 0.28492 |
| Nicotine only | -1.43218 | 0.33995 |
| Capacity only | -1.10000 | 0.28167 |
| Nicotine + capacity | -1.67242 | 0.34956 |
| Nicotine + variety | -1.41189 | 0.33129 |
| Capacity + variety | -1.08758 | 0.28047 |
| Nicotine + capacity + variety (SV3) | -1.69852 | 0.33985 |

Removing nicotine and capacity **together** reverses the negative sign. Adding either **separately** to the otherwise basic first stage produces a negative slope. Removing only one from SV3 leaves it negative.

Nicotine and capacity may reflect firms' responses to unobserved demand, but correlated exogenous attributes, common changes over time and product composition can also produce sign reversals. Removing a core demand attribute solely to make tax positive would not establish a valid specification. Treating these attributes as endogenous would require additional excluded instruments and joint identification.

For SV3, tax coefficients in the price first stage, share first stage and outcome reduced form are -1.69852, +0.75910 and +1.66828. $\alpha$ is approximately -0.00503 and $\sigma$ 2.18644.

## 9. Aggregation diagnostics and checks already completed

The original state-level diagnostic uses all eligible brands: 6,443 state-months and 699,282 UPC-state-months. Tax slopes are positive for equal-UPC state prices with no FE, state FE, month FE, or both. With both state and month FE, the slope is +0.713; with UPC-state pair and month FE, +0.835.

The tighter matched bridge retains exactly the 528 SV3/SV4 incumbent firm-months and expands them to 25,044 operating-state observations. State regressions retain national firm-month nicotine/capacity/variety controls. Default observation weights give each firm-month total weight one across states.

| Matched local price regression | Tax slope | SE |
|---|---:|---:|
| Firm FE + count + characteristics | +0.923 | 0.072 |
| Firm + state FE + count + characteristics | +0.641 | 0.157 |
| Firm + state + month FE + characteristics | +0.841 | 0.149 |
| Unweighted rows, firm + state FE + controls | +0.634 | 0.158 |
| Volume-price sensitivity, firm + state + month FE | +0.887 | 0.107 |

State errors are clustered by state and month. National count is absorbed by month FE in the diagnostic. These price regressions can include month FE without the structural single-nest demand degeneracy.

National sensitivity fits cross five price constructions (current pooled-UPC price; equal-, population-, or sales-weighted local equal-UPC prices; aggregate revenue/volume) with three tax weights (population, equal-state, current mL sales). All 15 combinations retain 528 rows, national count, the three characteristics and firm FE. All tax slopes are negative.

## 10. Questions for discussion

1. Should the economic choice unit be adult participation or volume/purchase opportunities? What denominator and scanner-coverage adjustment are defensible?
2. What supports exclusion for geographic tax and active-brand count given endogenous entry, footprints and product choice?
3. Does nicotine/capacity conditioning remove confounding or create identification problems through endogenous characteristics? What additional instruments could credibly identify them if so?
4. Should demand be modeled geographically or at a less aggregated product level? What is lost by the representative firm price and fringe aggregation?
5. Which next diagnostic is most informative: leave-firm/year-out influence, time-pattern analysis, serial-dependence-robust strength, or weak-IV-robust joint inference for price and sigma?

\newpage

## Appendix A. Full coefficients and standard errors for annual models

Entries below reproduce the saved comparison tables. Alpha is signed; parentheses are month-clustered standard errors. Ordinary first-stage F values shown here are joint excluded-instrument tests, not the conditional F statistics in Section 7.

### Full-sample main models

| | M1 | M2 | M3 | M4 | M5 | M6 |
|---|---:|---:|---:|---:|---:|---:|
| Estimator | Full IV | Full IV | Full IV | Full IV | OLS | OLS |
| Firm FE | No | No | Yes | Yes | No | Yes |
| Count IV | National | Geographic | National | Geographic | -- | -- |
| Tax IV | Yes | Yes | Yes | Yes | No | No |
| alpha: price | -0.211 (0.117) | -0.202 (0.122) | -0.339 (0.220) | -0.332 (0.225) | -0.035 (0.007) | -0.046 (0.016) |
| beta_a: nicotine | 0.007 (0.013) | -0.000 (0.016) | 0.037 (0.010) | 0.035 (0.011) | 0.055 (0.003) | 0.057 (0.005) |
| sigma: nesting | 3.422 (0.665) | 3.630 (0.769) | 4.024 (1.087) | 4.159 (1.162) | 0.975 (0.057) | 0.911 (0.052) |
| N | 540 | 540 | 540 | 540 | 540 | 540 |
| Price first-stage F | 62.93 | 63.11 | 36.32 | 36.81 | -- | -- |
| Share first-stage F | 55.00 | 39.17 | 48.63 | 37.91 | -- | -- |
| sigma in [0,1) | No | No | No | No | Yes | Yes |

### Partial IV

| | D1 | D2 | D3 | D4 | D5 | D6 |
|---|---:|---:|---:|---:|---:|---:|
| Estimator | Share-only IV | Share-only IV | Share-only IV | Share-only IV | Price-only IV | Price-only IV |
| Firm FE | No | No | Yes | Yes | No | Yes |
| Count IV | National | Geographic | National | Geographic | -- | -- |
| Tax IV | No | No | No | No | Yes | Yes |
| alpha: price | -0.461 (0.642) | -1.349 (6.524) | -0.263 (0.103) | -0.292 (0.131) | -0.303 (0.056) | -0.490 (0.109) |
| beta_a: nicotine | -0.025 (0.117) | -0.193 (1.216) | 0.038 (0.010) | 0.035 (0.011) | 0.082 (0.008) | 0.089 (0.012) |
| sigma: nesting | 5.699 (7.026) | 15.538 (71.921) | 3.536 (1.165) | 3.883 (1.520) | 1.345 (0.058) | 1.130 (0.062) |
| N | 540 | 540 | 540 | 540 | 540 | 540 |
| Price first-stage F | -- | -- | -- | -- | 62.57 | 37.91 |
| Share first-stage F | 0.46 | 0.04 | 8.06 | 5.45 | -- | -- |
| sigma in [0,1) | No | No | No | No | No | No |


### Matched baseline

|  | B1 | B2 | B3 | B4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.113 (0.065) | -0.103 (0.069) | -0.002 (0.070) | 0.005 (0.071) |
| beta_a | 0.013 (0.010) | 0.007 (0.011) | 0.036 (0.007) | 0.035 (0.007) |
| beta_size | -- | -- | -- | -- |
| beta_variety | -- | -- | -- | -- |
| sigma | 2.887 (0.356) | 3.036 (0.408) | 2.384 (0.231) | 2.409 (0.234) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 74.35 | 74.60 | 35.30 | 35.78 |
| ln_s_i_g first-stage F | 73.52 | 51.21 | 84.50 | 70.46 |

### Size

|  | S1 | S2 | S3 | S4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.115 (0.081) | -0.100 (0.085) | -0.024 (0.075) | -0.015 (0.076) |
| beta_a | 0.012 (0.009) | 0.008 (0.010) | 0.015 (0.009) | 0.015 (0.009) |
| beta_size | -0.018 (0.146) | 0.024 (0.155) | -0.214 (0.091) | -0.208 (0.091) |
| beta_variety | -- | -- | -- | -- |
| sigma | 2.880 (0.340) | 3.045 (0.400) | 2.267 (0.190) | 2.299 (0.195) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 68.21 | 68.72 | 34.95 | 35.28 |
| ln_s_i_g first-stage F | 53.86 | 36.58 | 70.61 | 67.22 |

### Variety

|  | V1 | V2 | V3 | V4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.189 (0.095) | -0.187 (0.100) | 0.011 (0.065) | 0.019 (0.066) |
| beta_a | 0.006 (0.014) | 0.001 (0.015) | 0.040 (0.007) | 0.039 (0.007) |
| beta_size | -- | -- | -- | -- |
| beta_variety | -0.483 (0.182) | -0.523 (0.202) | 0.134 (0.103) | 0.130 (0.106) |
| sigma | 3.316 (0.563) | 3.487 (0.641) | 2.315 (0.236) | 2.347 (0.241) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 84.32 | 82.61 | 36.67 | 36.94 |
| ln_s_i_g first-stage F | 52.10 | 40.79 | 67.65 | 57.27 |

### Size and variety

|  | SV1 | SV2 | SV3 | SV4 |
|---|---:|---:|---:|---:|
| Firm FE | No | No | Yes | Yes |
| Count IV | National | Geographic | National | Geographic |
| alpha | -0.189 (0.095) | -0.187 (0.101) | -0.005 (0.067) | 0.004 (0.068) |
| beta_a | 0.006 (0.013) | 0.001 (0.015) | 0.022 (0.009) | 0.021 (0.009) |
| beta_size | -0.033 (0.166) | 0.003 (0.175) | -0.201 (0.084) | -0.194 (0.085) |
| beta_variety | -0.459 (0.185) | -0.525 (0.213) | 0.173 (0.099) | 0.167 (0.102) |
| sigma | 3.281 (0.528) | 3.491 (0.623) | 2.186 (0.192) | 2.227 (0.198) |
| N | 528 | 528 | 528 | 528 |
| p_it first-stage F | 69.77 | 69.73 | 36.50 | 36.83 |
| ln_s_i_g first-stage F | 34.15 | 27.61 | 60.12 | 55.49 |


## Appendix B. Diagnostic specification inventory and saved results

The following tables list every saved matched bridge price regression (including duplicate benchmark constructions for reconciliation) and the broad state-level diagnostic. They are auxiliary OLS fits, not additional nested-logit estimates. N is the observation count.

### Matched bridge

| Diagnostic | N | Tax slope | SE |
|---|---:|---:|---:|
| N current SV3 | 528 | -1.6985 | 0.3399 |
| N current SV4 | 528 | -1.6954 | 0.3420 |
| N current without product controls | 528 | 0.8438 | 0.2927 |
| N controls a it | 528 | -1.4322 | 0.3399 |
| N controls avg ml per ecig | 528 | -1.1000 | 0.2817 |
| N controls a it avg ml per ecig | 528 | -1.6724 | 0.3496 |
| N controls log upc variety | 528 | 0.7751 | 0.2849 |
| N controls a it log upc variety | 528 | -1.4119 | 0.3313 |
| N controls avg ml per ecig log upc variety | 528 | -1.0876 | 0.2805 |
| N p it tax pop | 528 | -1.6985 | 0.3399 |
| N p it tax equal | 528 | -1.3947 | 0.4508 |
| N p it tax sales | 528 | -1.6662 | 0.7891 |
| N p state equal tax pop | 528 | -0.7594 | 0.4631 |
| N p state equal tax equal | 528 | -2.5660 | 0.5468 |
| N p state equal tax sales | 528 | -1.8402 | 1.0354 |
| N p state pop tax pop | 528 | -0.7580 | 0.4719 |
| N p state pop tax equal | 528 | -2.5465 | 0.5344 |
| N p state pop tax sales | 528 | -1.8717 | 1.0594 |
| N p state sales tax pop | 528 | -0.9193 | 0.4199 |
| N p state sales tax equal | 528 | -2.4169 | 0.5216 |
| N p state sales tax sales | 528 | -2.1207 | 1.0058 |
| N p volume tax pop | 528 | -2.2452 | 0.4344 |
| N p volume tax equal | 528 | -4.0770 | 0.2853 |
| N p volume tax sales | 528 | -2.7712 | 0.6865 |
| S brand count only | 25044 | 0.9176 | 0.0716 |
| S brand controls | 25044 | 0.9227 | 0.0717 |
| S brand STATE count only | 25044 | 0.6354 | 0.1596 |
| S brand STATE controls | 25044 | 0.6406 | 0.1567 |
| S brand STATE year month count only | 25044 | 0.8394 | 0.1503 |
| S brand STATE year month controls | 25044 | 0.8409 | 0.1485 |
| S state FE unweighted | 25044 | 0.6336 | 0.1580 |
| S state month FE volume price | 25044 | 0.8871 | 0.1067 |

### Broad state diagnostic

| Diagnostic | N | Tax slope | SE |
|---|---:|---:|---:|
| price pooled | 6443 | 0.9365 | 0.0903 |
| price state FE | 6443 | 0.7789 | 0.1835 |
| price month FE | 6443 | 0.9242 | 0.0775 |
| price state month FE | 6443 | 0.7130 | 0.1619 |
| price volume pooled | 6443 | 0.7301 | 0.1179 |
| price volume state FE | 6443 | 0.5974 | 0.2089 |
| price volume month FE | 6443 | 0.8714 | 0.1460 |
| price volume state month FE | 6443 | 0.9859 | 0.1897 |
| upc state month FE | 699282 | 0.9568 | 0.1018 |
| upc state pair month FE | 699282 | 0.8348 | 0.1632 |

### Additional completed checks

- All 40 conditional-F tests (20 settings × two regressors), including independent covariance/residual checks; market-size first-stage invariance verified.
- SV3/SV4: two first stages and one outcome reduced form each, with exact-identification coefficient decomposition.
- Retail rebuild audit, pack-volume identities, aggregation checks, independent QR OLS/2SLS coefficient and residual checks.
- An auxiliary policy-overlap exercise used 192 observed e-cigarette state-months in eight states. It crossed two price constructions, four FE settings (none/state/month/both), and policy inclusion/exclusion: 16 OLS fits. Limited coverage and absorbed policies prevent generalization to the full panel; this exercise did not change structural controls.

### Reproducibility locations

Paths below are relative to `smoke_firm_dir/`.

- Structural estimates and standard errors: `output/demand_estimation/specification_comparison/README.md` and its `product_size/` and `market_size/` subdirectories.
- Conditional instrument strength: the comparison directory's `conditional_F/`.
- First stages and reduced forms: the comparison directory's `sv_first_stages_reduced_form/`.
- State-level diagnostics and matched bridge: `output/prelim_analysis/state_price_tax_diagnostic/`, including `aggregation_bridge/` and `policy_overlap/`.
- Diagnostic scripts: `code/2_preliminary_analysis/16_state_price_tax_diagnostic.R`, `17_state_policy_price_tax_diagnostic.R`, and `18_aggregation_price_tax_bridge.R`.

This meeting note summarizes existing saved estimates; no models were re-estimated to prepare it.
