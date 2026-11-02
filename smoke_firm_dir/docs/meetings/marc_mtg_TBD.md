# Marc meeting notes

Meeting date: TBD. Created: 2026-10-27.

## Starting point

Follow-up to the [October 26 meeting](marc_mtg_2026-10-26.md), Section 5. Proceed provisionally with liquid-volume-weighted prices and without firm fixed effects. The agreed direction is to select a national firm-month demand specification with a reasonable sigma to continue to the supply side, while returning later to the negative price–tax relationship. Gandhi–Houde instruments are a possible future exercise; tax weighting remains to be specified.

Exercise 1 completed October 27, 2026. Add subsequent sections as exercises are agreed and completed.

## 1. Sales-weighted tax instruments in the national firm-month grid

### Question

Does replacing geographic population weights with sales weights in the tax instrument change which specification families have 0 < sigma < 1?

### Specification and changes

The previous tax instrument was population-weighted over each brand's operating states, rather than an unweighted UPC average. The new instrument is `Tax_sales_it = sum_s(q_ist * tax_st) / sum_s(q_ist)`, where q is the brand's same-month eligible liquid volume in each state. This uses liquid-volume weights, not revenue or package-count weights. Taxes retain their existing real-dollar/mL definition and closed-system tax series.

Reran **1,776 specifications with each tax definition**: 1,344 with exogenous quality and 432 with endogenous quality. The exogenous-quality grid includes the original 48 designs. Four control groups (B: nicotine; S: plus device size; V: plus log UPC variety; SV: both), with/without firm FE, both price measures, three market sizes, and the original advisor instrument sets are retained. Nonlag sets run on 528 complete-size rows and again on the 524-row common-lag sample; lag sets and endogenous-quality models use 524 rows. Standard errors remain clustered by month, with no month FE. Only the tax instrument changes within each matched comparison.

### Findings

**Sales-weighted taxes increase admissible sigma point estimates from 357/1,776 (20.1%) to 707/1,776 (39.8%). However, admissible sigma combined with negative alpha increases only from 354 to 374 (19.9% to 21.1% of all runs).** Of the new 707 qualifying runs, 333 have nonnegative alpha. The sigma improvement therefore does not imply a comparable improvement in economically plausible demand slopes.

| Price / firm FE | Population tax: qualifying / total | Sales tax: qualifying / total | Sales tax: also negative alpha |
|-------------------------------|----------------------:|----------------------:|----------------------:|
| Volume weighted, no firm FE | 232 / 444 (52.3%) | 235 / 444 (52.9%) | 149 / 444 |
| Volume weighted, firm FE | 83 / 444 (18.7%) | 174 / 444 (39.2%) | 167 / 444 |
| Equal-UPC, no firm FE | 35 / 444 (7.9%) | 142 / 444 (32.0%) | 16 / 444 |
| Equal-UPC, firm FE | 7 / 444 (1.6%) | 156 / 444 (35.1%) | 42 / 444 |

Within the advisor's provisional direction of **volume-weighted prices and no firm FE**:

- Tax + annual incumbent count gives qualifying sigma in **24/24** runs, with negative alpha in **20/24**. Tax + annual and monthly incumbent counts also gives **24/24**, with negative alpha in **20/24**.
- Tax + annual count + lag quality gives **24/24**, with negative alpha in **16/24**. Adding monthly count to this set gives **24/24**, with negative alpha in **20/24**.
- Tax + monthly incumbent count gives **21/24**, with negative alpha in **17/24**. Tax + monthly count + lag gives **16/24**, with negative alpha in **12/24**.
- Adding annual count to the original national or geographic active-brand-count sets gives **24/24** qualifying sigma, but only **8/24** and **11/24**, respectively, also have negative alpha.
- Tax + either original active-brand count alone still gives **0/24** qualifying sigma in this price/FE family. Across the entire grid, the original 48 designs also have **0/48** qualifying sigma with the new tax weights.

These 24-run instrument families combine control groups, market sizes, and the applicable sample/quality comparisons; they are not independent replications. All listed instrument sets include tax. See the [focused instrument-family table](tables/2026-10-27_sales_price_no_FE_instrument_families.csv) for every set.

Other patterns across the sales-tax grid:

- **Controls:** SV has 203/444 qualifying runs; V 192/444; S 160/444; B 152/444. Requiring negative alpha gives 97, 81, 104, and 92, respectively, so the ranking changes.
- **Market size:** monthly intensity gives 305/592 qualifying runs, annual 231/592, constant intensity 171/592. Requiring negative alpha gives 98, 105, and 171. Monthly intensity's larger sigma count does not carry over to the joint sign criterion.
- **Quality:** exogenous-quality models qualify in 517/1,344 runs (291 also negative alpha); endogenous-quality models in 190/432 (83 also negative alpha).
- **Lag quality is not required:** 360/864 nonlag runs and 347/912 lag runs qualify.
- **Matched transitions:** 374 specifications move into (0,1), 24 move out, 333 stay inside, and 1,045 stay outside.

### Sigma levels among qualifying runs

Among the **707 sales-tax runs with 0 < sigma < 1**, mean sigma is **0.780** and median sigma is **0.831**. Under the original population tax weights, the corresponding values were **0.573** and **0.616** among 357 qualifying runs. Each specification receives equal weight, including deliberate sample-matched repetitions; these are conditional descriptive summaries, not pooled estimates.

**Price and fixed effects — sales-weighted taxes**

| Family | Qualifying runs | Mean sigma | Median sigma |
|----------------------------------------|----------:|----------:|----------:|
| Equal-UPC, firm FE | 156 | 0.791 | 0.798 |
| Volume weighted, firm FE | 174 | 0.641 | 0.744 |
| Equal-UPC, no firm FE | 142 | 0.786 | 0.826 |
| Volume weighted, no firm FE | 235 | 0.871 | 0.880 |

**Instrument sets — sales-weighted taxes**

| Family | Qualifying runs | Mean sigma | Median sigma |
|----------------------------------------|----------:|----------:|----------:|
| Annual | 63 | 0.748 | 0.813 |
| Annual_Monthly | 64 | 0.750 | 0.816 |
| Geographic | 0 | — | — |
| Geographic+incumbent_annual | 64 | 0.772 | 0.798 |
| Geographic+incumbent_monthly | 29 | 0.844 | 0.855 |
| Monthly | 52 | 0.769 | 0.844 |
| National | 0 | — | — |
| National+incumbent_annual | 64 | 0.792 | 0.839 |
| National+incumbent_monthly | 24 | 0.859 | 0.883 |
| Annual_Lag | 63 | 0.780 | 0.838 |
| Annual_Monthly_Lag | 65 | 0.769 | 0.839 |
| Geographic+a_lag1 | 0 | — | — |
| Geographic+incumbent_annual+lag | 63 | 0.770 | 0.799 |
| Geographic+incumbent_monthly+lag | 27 | 0.819 | 0.830 |
| Lag | 1 | 0.076 | 0.076 |
| Monthly_Lag | 45 | 0.785 | 0.859 |
| National+a_lag1 | 0 | — | — |
| National+incumbent_annual+lag | 59 | 0.774 | 0.814 |
| National+incumbent_monthly+lag | 24 | 0.839 | 0.865 |

**Controls — sales-weighted taxes**

| Family | Qualifying runs | Mean sigma | Median sigma |
|----------------------------------------|----------:|----------:|----------:|
| Nicotine only | 152 | 0.809 | 0.863 |
| Nicotine + size + log variety | 203 | 0.762 | 0.806 |
| Nicotine + size | 160 | 0.788 | 0.847 |
| Nicotine + log variety | 192 | 0.769 | 0.828 |

**Market size — sales-weighted taxes**

| Family | Qualifying runs | Mean sigma | Median sigma |
|----------------------------------------|----------:|----------:|----------:|
| Annual intensity | 231 | 0.807 | 0.832 |
| Constant intensity | 171 | 0.682 | 0.805 |
| Monthly intensity | 305 | 0.814 | 0.839 |

**Quality treatment — sales-weighted taxes**

| Family | Qualifying runs | Mean sigma | Median sigma |
|----------------------------------------|----------:|----------:|----------:|
| Exogenous | 517 | 0.782 | 0.831 |
| Endogenous | 190 | 0.775 | 0.830 |

Instrument labels above all include tax: Annual/Monthly denote incumbent counts; National/Geographic denote the original active-brand counts; Lag denotes previous-calendar-month quality. Combinations list the additional instruments. Zero qualifying runs have no conditional mean or median.

For the provisional volume-weighted-price/no-FE direction, the 235 qualifying runs have **mean 0.871 and median 0.880**. This summary includes positive price slopes; the CSV also reports mean/median among qualifying runs with negative alpha separately. The [focused instrument-family table](tables/2026-10-27_sales_price_no_FE_instrument_families.csv) now includes mean and median sigma for each instrument set within that price/FE family.

### Interpretation and next steps

Annual-incumbent-count instruments remain a prominent qualifying family, particularly with volume-weighted prices. Under the provisional no-FE direction, tax + annual count (with or without monthly count) warrants closer examination of coefficients, uncertainty, and identification. It is not yet a selected supply-side specification.

Sales weighting does not resolve the original tax + active-brand-count-only models. Many newly admissible sigma estimates have the wrong price sign. Current sales weights can correlate with demand shocks and quantity measurement error; these results do not establish exclusion validity. Strict qualification concerns the sigma point estimate only, not its confidence interval, quality coefficient, or instrument strength. Repeated sample comparisons inflate neither independent evidence nor confidence in a family. No sigma clipping or canonical replacement was performed.

### Files and checks

The population-weighted rerun reproduces the historical **357 qualifying / 354 negative-alpha** totals. All 48 saved original baseline coefficients and covariances reproduce (maximum discrepancies below 8e-11). All 3,552 fits pass independent QR coefficient and structural-residual checks (maximum discrepancies below 6e-9); conditional-F validation is retained for two or three endogenous regressors. All coefficient SEs are finite. State sales reconcile to saved national brand-month volume and revenue within 1e-8 relative tolerance; tax weights sum to one and weighted tax lies within operating-state tax bounds. Source hashes are unchanged.

- [Complete family breakdown](marc_mtg_2026-10-27_sales_tax_family_summary.md).
- [Family counts](tables/2026-10-27_tax_weight_family_counts.csv), [all specification results](tables/2026-10-27_tax_weight_specification_index.csv), [qualifying sales-tax runs](tables/2026-10-27_sales_tax_sigma_between_zero_and_one.csv), and [matched comparison](tables/2026-10-27_tax_weight_paired_comparison.csv).
- Detailed coefficients, first stages, conditional F, models, checks, weights, and input hashes: `output/demand_estimation/sales_weighted_tax_2026-10-27/`. `TaxIV_geo` is retained as the internal variable name; each mode directory identifies the weighting definition.
- Scripts: `code/3_demand_estimation/23_sales_weighted_tax.R` and `24_sales_tax_family_report.R`. Existing inputs, NCP data, and prior results are preserved.

## 2. Compare all 24 specifications in the annual-incumbent-count family

### Question and reason for shortlisting

Compare all candidates within **volume-weighted prices + no firm FE + sales-weighted tax + annual incumbent count**, before choosing a provisional national demand specification for supply-side work. **This family was shortlisted because it is one of the most successful families by the frequency of admissible sigma point estimates:** 24/24 qualify and 20/24 also have negative alpha. Other families tie on sigma qualification. This criterion does not establish instrument validity or select a final specification.

The earlier illustration focused prematurely on both product controls. The full choice set is **four control groups × three market sizes × two samples = 24**. There are 12 substantive control/market combinations; the second sample checks sensitivity to dropping four rows.

### Common specification

- National incumbent firm-month observations; price is real revenue / eligible liquid volume.
- Price and within-nest log share jointly endogenous. Excluded instruments: brand-specific current liquid-volume-weighted state tax and annual national incumbent count (>7% annual volume share).
- Current nicotine quality is included and treated as exogenous in all runs. B: nicotine only; S: plus mean device size; V: plus log UPC variety; SV: both.
- Intercept, no firm FE, no month FE; SEs clustered by month. Exactly identified (two excluded instruments / two endogenous regressors).
- Available sample: 528 complete-size rows / 132 months. Common-lag sample: 524 rows / 131 months. No lagged-quality instrument is used in these 24 runs; the smaller sample is a comparability check only. All control groups retain the same complete-size sample rule.
- Annual, monthly, and constant intensity use the existing market-size definitions.

### All 24 estimates

Entries are coefficient (month-clustered SE). Quality is current delivered nicotine. Every sigma point estimate below lies in (0,1).

**Available sample: 528 rows**

| Controls | Market intensity | Price alpha (SE) | Sigma (SE) | Quality (SE) |
|----------|------------------|----------------:|-----------:|-------------:|
| B | annual | -0.0701 (0.0341) | 0.8374 (0.2212) | 0.0606 (0.0081) |
| B | monthly | -0.0584 (0.0384) | 0.8609 (0.2351) | 0.0588 (0.0089) |
| **B — chosen** | **constant** | **−0.3336 (0.0391)** | **0.8695 (0.2373)** | **0.1100 (0.0092)** |
| S | annual | -0.0807 (0.0411) | 0.8182 (0.2326) | 0.0570 (0.0063) |
| S | monthly | -0.0659 (0.0459) | 0.8475 (0.2475) | 0.0562 (0.0068) |
| S | constant | -0.3906 (0.0540) | 0.7671 (0.2535) | 0.0908 (0.0072) |
| V | annual | -0.0025 (0.0389) | 0.8039 (0.1792) | 0.0608 (0.0064) |
| V | monthly | 0.0107 (0.0426) | 0.8267 (0.1945) | 0.0589 (0.0073) |
| V | constant | -0.3237 (0.0409) | 0.8646 (0.2383) | 0.1100 (0.0090) |
| SV | annual | -0.0044 (0.0393) | 0.7842 (0.1830) | 0.0577 (0.0049) |
| SV | monthly | 0.0095 (0.0434) | 0.8139 (0.2012) | 0.0569 (0.0056) |
| SV | constant | -0.3352 (0.0394) | 0.7424 (0.2251) | 0.0913 (0.0065) |

**Common-lag sample: 524 rows**

| Controls | Market intensity | Price alpha (SE) | Sigma (SE) | Quality (SE) |
|----------|------------------|----------------:|-----------:|-------------:|
| B | annual | -0.0676 (0.0349) | 0.8594 (0.2251) | 0.0596 (0.0083) |
| B | monthly | -0.0559 (0.0394) | 0.8832 (0.2396) | 0.0577 (0.0092) |
| B | constant | -0.3367 (0.0398) | 0.8452 (0.2392) | 0.1112 (0.0094) |
| S | annual | -0.0780 (0.0421) | 0.8422 (0.2361) | 0.0561 (0.0064) |
| S | monthly | -0.0630 (0.0472) | 0.8715 (0.2516) | 0.0553 (0.0070) |
| S | constant | -0.3954 (0.0552) | 0.7479 (0.2570) | 0.0914 (0.0074) |
| V | annual | -0.0019 (0.0390) | 0.8192 (0.1830) | 0.0601 (0.0066) |
| V | monthly | 0.0115 (0.0429) | 0.8420 (0.1990) | 0.0582 (0.0075) |
| V | constant | -0.3237 (0.0410) | 0.8372 (0.2395) | 0.1113 (0.0092) |
| SV | annual | -0.0040 (0.0397) | 0.8008 (0.1871) | 0.0572 (0.0051) |
| SV | monthly | 0.0102 (0.0438) | 0.8306 (0.2060) | 0.0564 (0.0059) |
| SV | constant | -0.3375 (0.0399) | 0.7156 (0.2267) | 0.0923 (0.0067) |

### Patterns and qualifications

- **Sigma:** all 24 point estimates qualify, ranging from 0.716 to 0.883. However, **0/24 conventional 95% intervals lie wholly within (0,1)**; all extend above 1.
- **Price:** 20/24 alpha estimates are negative. The four positive estimates are the monthly-intensity V and SV runs in both samples. Only 9/24 price intervals are entirely below zero: the eight constant-intensity runs and the available-sample B/annual run. All other annual/monthly price intervals include zero; B/annual loses that exclusion of zero on the common-lag sample.
- **Variety control:** with annual or monthly intensity, including log UPC variety (V or SV) shifts alpha toward zero or slightly positive. Without variety (B or S), these price estimates are more negative, but remain imprecise. This sensitivity does not by itself justify dropping variety.
- **Market size:** constant intensity gives substantially more negative alpha in every control group (approximately −0.32 to −0.40). Do not adopt this market-size assumption solely to obtain the desired price sign.
- **Quality:** every quality point estimate is positive; all 24 conventional 95% quality intervals are above zero.
- **Sample sensitivity:** the smaller sample leaves the main sign patterns unchanged. The B/annual price interval narrowly excludes zero in the available sample but includes it in the smaller sample. The smaller sample contains no additional lag instrument and is not independent evidence.

### First-stage diagnostics by control group and sample

First stages are identical across the three market sizes within a control/sample combination. Tax coefficients are estimate (SE); F values below are SW conditional F for each endogenous regressor. Full instrument and control coefficients, ordinary joint F, and conditional-F details are exported.

| Sample | Controls | Tax → price (SE) | Price SW F | Share SW F |
|----------------|----------|---------------------:|-----------:|-----------:|
| available | B | -7.505 (1.372) | 79.90 | 172.85 |
| available | S | -6.137 (1.377) | 49.37 | 129.34 |
| available | V | -6.660 (1.325) | 59.21 | 136.30 |
| available | SV | -6.006 (1.342) | 60.58 | 90.20 |
| common_lag | B | -7.178 (1.362) | 74.57 | 165.06 |
| common_lag | S | -5.860 (1.366) | 46.56 | 122.89 |
| common_lag | V | -6.455 (1.323) | 57.13 | 129.24 |
| common_lag | SV | -5.778 (1.337) | 57.91 | 84.59 |

Tax–price slopes remain negative in all eight designs. Conditional F does not establish instrument exclusion or calibrated weak-IV-robust inference. Exact identification leaves no overidentifying restrictions to test. Both sales-based tax weights and sales-share-threshold counts require an exclusion argument.

### Chosen provisional specification and rationale

**Chosen for the next stage: nicotine-only (B), constant-intensity market size, available sample (528 observations / 132 months), volume-weighted prices, no firm FE, and sales-weighted tax + annual incumbent count instruments.** The corresponding row is bold above.

This specification was chosen because **alpha is negative and not too small in magnitude: −0.334 (SE 0.039)**, and it belongs to one of the most consistently successful families by admissible sigma: **24/24 family runs have 0 < sigma < 1, and 20/24 also have negative alpha**. Thus 20/24 is the count satisfying both the sigma and price-sign criteria, not the sigma-only count. The chosen sigma is **0.869 (SE 0.237)** and the quality slope is **0.110 (SE 0.009)**. This is a pragmatic provisional choice following the advisor discussion, not evidence that this specification or market-size assumption is uniquely correct.

### Nested-logit equation for the chosen specification

Using the notation in the [previous presented troubleshooting notes](../presented/sigma_troubleshooting_marc_2026-10-14.md):

$$
\log(s_{it}/s_{0t})
= c + \alpha p_{it} + \beta_a a_{it}
+ \sigma\log(s_{it}/s_{gt}) + \xi_{it}.
$$

$i$ indexes national incumbent brands and $t$ months. $p_{it}$ is the liquid-volume-weighted real price per mL, $a_{it}$ is delivered nicotine concentration, and $\xi_{it}$ is the unobserved demand term. Intercept $c$ is included.

The shares use constant-intensity market size:

$$
M_t=\bar{k}\,\mathrm{Adults}_t,\qquad
s_{it}=q_{it}/M_t,\qquad
s_{gt}=Q_t/M_t,\qquad
s_{0t}=1-Q_t/M_t,
$$

where $q_{it}$ is eligible brand liquid volume, $Q_t$ sums eligible incumbent and fringe volumes, and $\bar{k}$ is the full-period mean of the monthly NCP purchasing-household consumption-intensity series. Constant intensity does not mean constant market size: adult population varies over time.

The estimated equation, with coefficients rounded, is:

$$
\log(s_{it}/s_{0t})
= -6.8938 - 0.3336\,p_{it} + 0.1100\,a_{it}
+ 0.8695\log(s_{it}/s_{gt}) + \widehat{\xi}_{it}.
$$

Price and within-nest log share are jointly instrumented by **sales-weighted state tax and annual national incumbent count**. Current quality is treated as exogenous. The two excluded instruments identify the two endogenous regressors exactly; standard errors are clustered by month.

The negative conditional tax–price relationship remains unresolved. $\sigma$'s conventional 95% interval extends above 1, and the constant-intensity market-size assumption still requires substantive support.

### Files

[All 24 specifications with confidence intervals and diagnostics](tables/2026-10-27_annual_count_all24_comparison.csv), [all coefficients](tables/2026-10-27_annual_count_all24_coefficients.csv), and [complete first stages](tables/2026-10-27_annual_count_all24_first_stages.csv). These supersede the six-run illustration as the main shortlist comparison. Extraction script: `code/3_demand_estimation/26_compare_annual_count_family.py`; no regressions were rerun.

For next time, attempt Gandhi–Houde instruments, given no firm FE.

## 3. Supply-side setup: cost recovery and fringe demand

### Decisions before coding

Start by recovering demand residuals and marginal costs at observed prices, then implement the static pricing fixed point manually and test observed-market replication. Do not use packaged black-box equilibrium solvers. The planned code folder is `code/4_static_pricing_subgame/`. Treat each brand as a vertically integrated pricing firm, as agreed: it chooses its representative retail price and receives the corresponding retail revenue. Recovered marginal costs are effective integrated-channel costs; operating profits are integrated-channel profits, rather than separately identified manufacturer profits. No separate wholesale-price or retailer-margin stage is modeled. This is the initial approximation for the static subgame and must remain explicit when interpreting later entry/exit results.

### Fringe utility includes unobserved quality

**Decision: allow fringe mean utility to include unobserved quality, rather than restricting it to measured nicotine quality alone.** In the signed-alpha convention, the full mean utility is

$$
\delta_{F,t}=c+\beta_a a_{F,t}+\alpha p_{F,t}+\xi_{F,t},\qquad \alpha<0.
$$

The fringe is one aggregate alternative in the same e-cigarette nest. For the initial observed-market replication, calibrate its mean utility from observed shares:

$$
\delta_{F,t}^{\mathrm{obs}}
=\log(s_{F,t}/s_{0t})
-\sigma\log(s_{F,t}/s_{gt}).
$$

Given consistently defined observed fringe price and quality, recover the implied unobserved component as

$$
\xi_{F,t}=\delta_{F,t}^{\mathrm{obs}}-c-\beta_a a_{F,t}-\alpha p_{F,t}.
$$

For the first static solve, it is sufficient to use calibrated total fringe utility; separating price, quality, and the residual requires consistent fringe aggregates. Calibration matches the observed aggregate share but does not estimate a separate fringe demand equation or validate the assumed aggregation.

Fringe utility may vary across months. Hold it fixed within each month's incumbent pricing game: the fringe remains passive, with no strategic price choice. Its share nevertheless responds to incumbent prices through the demand denominator. This changes the PDF restriction $\delta_{F,t}=\beta_a a_{F,t}$; it does not require a strategic fringe.

Current quality and demand shocks are held fixed during each static solve. Their Markov transitions are deferred until the dynamic continuation-value/entry-exit stage; no new transition assumptions have been selected here.

### Revised supply documents

Reconstructed editable LaTeX sources for the [conference model](../ec_supply_conference_model.tex) and [solution appendix](../ec_supply_solution_appendix.tex), and regenerated their PDFs. Both now use signed alpha in `+ alpha * price`, include the demand intercept and calibrated fringe residual, and update derivatives, markups, cost recovery, and manual fixed-point equations consistently. Original PDFs are preserved in `docs/source_archive/pre_reconstruction/`; the model retains its original chart and historical concentration table. Unresolved dynamic-cap and private-cost assumptions are flagged explicitly. Algebra and rendered pages were checked; no pricing solver was implemented. Rebuild with `bash smoke_firm_dir/docs/build_supply_documents.sh`.

### Reconstruction audit completed

A section-by-section audit compared both reconstructed supply documents with their archived originals. It restored historical tax/count definitions, missing-size exclusions, absorbing exit, the ownership-exit sample statement, and explicit dynamic iteration details that had been compressed. The concentration table matches all 11 original rows, and the chart uses the original PDF figure. Intended changes (signed alpha, calibrated fringe utility, current provisional specification) and corrections to contradictory draft statements are documented separately in the [audit record](../audits/supply_pdf_reconstruction_audit_2026-10-27.md). Both PDFs were regenerated and checked. These remain revised reconstructions rather than verbatim copies; the original PDFs remain unchanged.

### Observed-market recovery completed

Implemented the first supply-side recovery step in `code/4_static_pricing_subgame/`, reading the full-precision chosen demand coefficients. No price fixed point has been solved yet.

The demand fit uses **528 observations**, but complete observed markets have **540 incumbent firm-month rows across 132 months**. Keep the 12 BLU 2018 rows excluded for missing device size as competitors; invert their observed shares using the chosen parameters and flag them as outside the estimation sample. This preserves observed inside volumes and the full competitive roster without refitting demand or imputing size. Their residuals are out-of-estimation-sample inversions, not residuals from rows used in IV estimation.

For each incumbent, recover

$$
\widehat\xi_{it}=\log(s_{it}/s_{0t})-\widehat c-\widehat\alpha p_{it}
-\widehat\beta_a a_{it}-\widehat\sigma\log(s_{it}/s_{gt}),
$$

$$
A_{it}=\frac{1}{1-\widehat\sigma}-\frac{\widehat\sigma}{1-\widehat\sigma}s_{i\mid g,t}-s_{it},\qquad
\widehat\mu_{it}=-\frac{1}{\widehat\alpha A_{it}},\qquad
\widehat{mc}_{it}=p_{it}-\widehat\mu_{it}.
$$

Variable profit is $(p_{it}-\widehat{mc}_{it})q_{it}$, before unspecified fixed operating costs. No extra tax is subtracted from recovered costs; their interpretation follows the observed retail-price convention. The fringe's existing price is real fringe revenue / fringe volume, and its quality is the existing equal-UPC delivered-nicotine measure. Calibrate total fringe utility from shares and recover its residual decomposition as agreed above; no fringe pricing FOC or fringe cost is inferred.

**Initial findings:** no negative marginal costs among all 540 rows. On the **528-row estimation sample**:

| Quantity | Result |
|----------------------------------------|----------------------:|
| Median retail price | $4.161/mL |
| Median recovered markup | $0.459/mL |
| Median effective marginal cost | $3.701/mL |
| Marginal-cost range | $0.651–$9.398/mL |
| Total variable profit, 2013–2023 sample | $535.33 million |

The extra 12 BLU rows contribute $3.84 million in variable profit, giving **$539.16 million across the full 540-row observed roster**. These are totals across eligible observed sales over the full period, not annual profit, manufacturer profit, or profit net of fixed costs. Medians are computed separately, so median price need not equal median cost plus median markup.

**Checks:** independently reproduced the chosen IV coefficients and residuals using QR 2SLS. Full incumbent volumes and revenue reconcile to saved panels. Reconstructed incumbent/fringe/outside shares match observed shares to numerical precision; maximum relative quantity error is below 2e-14. Scaled observed-price FOCs are below 2e-15. Finite-difference demand checks pass for all 540 incumbent price perturbations, including cross-price and passive-fringe responses (maximum derivative discrepancy below 2e-12). The sigma-zero logit limit, extreme-utility stability, parameter guards, and unchanged input hashes also pass.

These identities validate implementation consistency, not demand identification or the assumption that observed prices are an equilibrium. The next step is the **manual damped pricing fixed point** from separate initial prices, followed by residual and unilateral-deviation checks.

Code: `1_static_demand_functions.R`, `2_recover_observed_market.R`, and `3_validate_observed_recovery.R` under `code/4_static_pricing_subgame/`. Outputs: [incumbent recovery](../../output/static_pricing_subgame/observed_recovery_2026-10-27/incumbent_recovery.csv), [fringe/market recovery](../../output/static_pricing_subgame/observed_recovery_2026-10-27/fringe_market_recovery.csv), and [interpretation](../../output/static_pricing_subgame/observed_recovery_2026-10-27/interpretation.txt). Solver-ready monthly inputs are saved as `observed_market_inputs.rds` in that output directory. Canonical panels and demand fits are unchanged.

## 4. Manual static pricing fixed point: observed-market replication

Completed October 28, 2026. Use the recovered October 27 costs and demand states from Section 3, with the full 540 incumbent rows in 132 monthly markets. Brands are vertically integrated single-product pricing firms. Incumbent quality, residuals, marginal costs, roster, and fringe total utility are fixed within each market; all incumbent and fringe shares are recomputed at each trial price vector.

### Algorithm

Implement simultaneous damped markup substitution directly, without an equilibrium/root/optimization package:

$$
T_i(p)=\widehat{mc}_i-\frac{1}{\widehat\alpha A_i(p)},\qquad
p_i^{(k+1)}=(1-\lambda)p_i^{(k)}+\lambda T_i(p^{(k)}),
$$

$$
A_i(p)=\frac{1}{1-\widehat\sigma}
-\frac{\widehat\sigma}{1-\widehat\sigma}s_{i\mid g}(p)-s_i(p).
$$

Four starting vectors: marginal cost + $0.10/mL, +$1/mL, +$5/mL, and heterogeneous positive cost increments. Cross these with damping values 0.25, 0.5 and 1: **12 attempts per month, 1,584 attempts total**. No observed price vector is used as a starting vector or convergence target. The reference solution is fixed in advance as cost+$1 with damping 0.5.

Require all three: maximum price step < 1e-10, maximum undamped map residual < 1e-9, and maximum scaled FOC residual < 1e-8. Cap at 2,000 iterations and report nonconvergence explicitly. The scaled FOC is `1 + (price - mc) * alpha * A`, avoiding dependence of the stopping rule on the volume units. Save every iteration's diagnostics. This is a markup fixed point, not an exact best-response iteration.

### Results

**All 1,584 attempts converged to the same observed-price solution within numerical tolerance.** The largest observed-price discrepancy across all starts/damping values is below **3e-10 real dollars/mL**. The predeclared reference solutions differ from observed prices by less than 1e-10.

| Damping | Attempts / converged | Median iterations | Maximum iterations |
|----------------|---------------------:|------------------:|-------------------:|
| 0.25 | 528 / 528 | 73 | 82 |
| 0.50 | 528 / 528 | 32 | 36 |
| 1.00 (undamped) | 528 / 528 | 57 | 1,335 |

Damping 0.5 is the practical starting choice for these observed markets; it is not a general convergence guarantee for counterfactual markets.

### Unilateral profit-deviation checks

For every one of the 540 reference incumbent solutions, hold rivals' prices fixed and find its best own price by **manually coded bracketing and bisection** on the own-profit FOC. This is separate from the multi-firm fixed-point solve.

For own price at or above marginal cost, `A_i > 0` and its own-price derivative is positive. Since alpha < 0, `g_i = 1 + alpha*(p_i-mc_i)*A_i` is strictly decreasing: it starts at 1 at cost and becomes negative at sufficiently high price. Its unique zero maximizes own variable profit; below-cost profits are nonpositive and profit tends to zero at infinite price. Thus the manually bracketed root checks the global unilateral optimum under the maintained single-product demand model.

The largest best-response price gap is **9.81e-11 dollars/mL**. The maximum apparent profit gain is **4.48e-8 real dollars** (relative gain below **1.35e-14**), consistent with rounding error. Own-profit FOC slopes are negative for all 540 solutions. These checks support numerical Nash optimality for the maintained game; they do not establish uniqueness of the joint equilibrium.

### Interpretation

This confirms that the manual algorithm can reproduce the observed-month equilibrium implied by the recovered demand states and marginal costs. Because costs were inverted from those observed prices, replication is an implementation check, not independent evidence that demand, integrated-channel conduct, instruments, or costs are empirically correct. No Markov process, fixed operating cost, entry/exit decision, or investment is required for this step. No counterfactual has been run, and no observed inputs or demand estimates were replaced.

### Files and checks

Scripts 4–6 in `code/4_static_pricing_subgame/` implement and validate this step. Additional checks cover permutation invariance, the sigma-zero logit case, explicit failure under an insufficient iteration budget, probability mass balance, and unchanged recovery-input hashes; all pass.

Outputs: [convergence summary](../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/convergence_summary.csv), [all solver attempts](../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/solver_runs.csv), [monthly price solutions](../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/monthly_price_solutions.csv), [unilateral deviation checks](../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/unilateral_deviation_checks.csv), and [interpretation](../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/interpretation.txt). Full traces and RDS results are in the same directory.

### Visual audit and numerical cost perturbation

Created an [audit plot booklet](../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/audit/pricing_audit_plots.pdf) with observed/solved firm prices, separate replication-error time series, price/cost/markup series, convergence residuals for the first/middle/slowest months, iteration counts across all runs, and unilateral profit curves for every incumbent in those selected months. Each plot also has standalone PDF/PNG files and supporting curve CSVs in the same `audit/` folder. The profit maxima coincide with the solved prices. Script: `code/4_static_pricing_subgame/7_audit_plots.R`.

A separate numerical counterfactual raises VUSE's recovered marginal cost by 10% in December 2023 (the largest-volume firm in the latest observed month). Its cost increases by $0.3344/mL and solved price by $0.2155/mL, implying 64.4% pass-through in this scenario. JUUL's price rises by $0.0191/mL and NJOY's by $0.0146/mL; their costs are unchanged. VUSE's share falls while its rivals' shares increase. Three independent starting vectors converge to the same counterfactual solution, and manually bisected unilateral best responses agree. This checks behavior away from the inverted observed-price vector; it is not estimated causal tax/cost pass-through or independent empirical validation. Original recovery and pricing results remain unchanged.

## Questions for Marc

[Add questions as the exercises develop.]

## Meeting discussion and agreed next steps

[Populate after the meeting.]
