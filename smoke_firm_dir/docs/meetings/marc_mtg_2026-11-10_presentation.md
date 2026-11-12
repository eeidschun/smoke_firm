---
fontsize: 11pt
geometry: margin=0.75in
colorlinks: true
header-includes:
  - \usepackage[dvipsnames]{xcolor}
  - \usepackage{pdfpages}
  - \renewcommand{\arraystretch}{1.08}
  - \hypersetup{linkcolor=MidnightBlue,urlcolor=MidnightBlue}
---

# Marc meeting: baseline supply model

**November 10, 2026**

## 1. Overall

- Selected a provisional national firm-month nested-logit specification with negative price slope and fine $\sigma$
- Used this specification to implement fixed point Bertrand pricing. Audited this
- Built an initial forward-looking entry/exit game with many restrictions including exogenous nicotine and demand shocks, five fixed brand identities, and private entry/scrap draws.
- Solved the dynamic game and did small calibration exercise (adjust one parameter at a time) on FC, sunk entry cost, scrap value standard deviation

**Focus: how to ease restrictions in entry/exit game**

### Current baseline at a glance

| Component | Implemented version |
|:---------------------------------|:-----------------------------------------------------------------|
| Individually modeled brands | BLU, MISTIC, NJOY, JUUL, VUSE |
| Other brands | Passive aggregate fringe, including LOGIC |
| Initial date | January 2013; BLU, MISTIC, NJOY active |
| Quality | Three nicotine bins × three demand-shock bins |
| Industry evolution | JUUL/VUSE entry; absorbing exit; no fringe promotion |
| Completed solves | Stationary January 2013 market size and fringe benchmark |
| Payoff calibration | Common fixed cost; exponential entry cost; normal net scrap |

### Reading guide

Pages 2–3: demand and pricing. Pages 4–6: roster, state, cost, and fringe restrictions. Pages 7–8: timing, private payoffs, and event definitions. Page 9: calibration and fit. Page 10: discussion priorities and brief audit summary.

Detailed checks and figures follow in the appendix. The [full working notes](marc_mtg_2026-11-10.pdf) retain the specification tables and decision history. This document describes the implemented baseline rather than superseded anonymous-slot proposals, and adds the subsequent coordinate-calibration results.

\clearpage

## 2. Demand carried into the supply model

$$
\log(s_{it}/s_{0t})=c+\alpha p_{it}+\beta_a a_{it}
+\sigma\log(s_{it}/s_{gt})+\xi_{it}.
$$

| Element | Selected specification |
|:---------------------------------|:-----------------------------------------------------------------|
| Price | Liquid-volume-weighted real dollars per mL |
| Control | Delivered nicotine concentration $a_{it}$ |
| Excluded instruments | Sales-weighted state tax + annual incumbent count |
| Endogenous variables | Price and within-nest log share |
| Market-size definition | Constant consumption intensity × adult population |
| Sample / uncertainty | 528 observations, 132 months; month-clustered SE |

$$
\widehat\alpha=-0.334\;(0.039),\quad
\widehat\beta_a=0.110\;(0.009),\quad
\widehat\sigma=0.869\;(0.237).
$$

Demand estimation retains the annual greater-than-7% incumbent classification.

### Why this provisional specification?

- Its instrument family has admissible $\sigma$ in **24/24** runs; **20/24** also have negative $\alpha$.
- Expanded Gandhi–Houde constructions give some admissible alternatives and smaller SEs, but was not smoking gun.

### Unresolved restrictions

Instrument exclusion, the negative conditional tax–price relationship, and market-size validity remain unresolved. Sigma's conventional 95% interval extends above one.

\clearpage

## 3. Static Bertrand pricing and recovered profits

Each active brand chooses its own price holding rivals' prices and nonprice states fixed:

$$
\pi_i(p,\Omega)=(p_i-mc_i)M s_i(p,\Omega)-FC.
$$

Here $\Omega$ is the public industry state: which focal brands are active, each active brand's nicotine and $\xi$ bins, and whether JUUL/VUSE have never entered or have permanently exited. Costs, fringe utility, market size, and demand coefficients are fixed inputs in this stationary baseline. Private entry-cost and scrap draws are not part of $\Omega$.

Define $A_i(p)=\frac{1-\sigma s_{i\mid g}(p)}{1-\sigma}-s_i(p)$

The manual markup fixed point and scaled FOC are

$$
p_i=mc_i-\frac{1}{\alpha A_i(p)},\qquad
1+\alpha(p_i-mc_i)A_i(p)=0.
$$

Demand residuals are inverted from observed shares; historical MC is inverted from observed-price FOCs. At simulated states, static pricing supplies variable profit $(p_i-mc_i)Ms_i$, before subtracting dynamic fixed cost. [Step-by-step explanation in Appendix G](#appendix-g-from-observed-shares-to-simulated-profits).

### Assumptions

- Constant mc
- Fringe is a passive competitor - hold their mean utility $\delta_F$ fixed. Do not separately solve for a fringe price or let it respond to incumbents.

### Audit summary

Checked different starting prices and damping; observed versus solved prices; price, MC, and markup graphs; convergence/FOC residuals; profit curves; simultaneous versus sequential updates. See Appendix A/D.

\clearpage

**Moving to dynamic supply**

## 4. Key restrictions: predetermined incumbent roster

**Track BLU, MISTIC, NJOY, JUUL, and VUSE individually.** This is the union of the four highest cumulative-volume brands and annual sales leaders over 2013–2023. LOGIC is placed in the fringe to limit to five.

I did this to bound the state space. It does not allow for industry turnover. I continue modeling each selected brand individually while it operates, regardless of market share.

If I continually admit the top-five, this leads to 12-13 brands.

### Question

Unclear how to maintain the five-firm cap while allowing rising fringe firms to join, whether or not I need to model in an incumbent's value function that they could be demoted to fringe? Or having promotion in fringe value function? Scrap value, as of now, is paid on actual shut down. 

\clearpage

## 5. Key restrictions: quality states and transitions

Nicotine $a$ and recovered demand shock $\xi$ each have three pooled quantile bins, represented by **within-bin medians**:

$$
\Pr(a',\xi'\mid a,\xi)=P_a(a'\mid a)P_\xi(\xi'\mid\xi).
$$

| Assumptions | Reason / alternative deferred |
|:---------------------------------|:-----------------------------------------------------------------|
| Exogenous nicotine and $\xi$ | Omits quality investment |
| 3 × 3 quantile bins | Nine occupied cells, each with at least 27 departures. Finer grids have thin rows; equally spaced 3×3 leaves two cells empty. |
| Within-bin medians for both variables | Consistent representative values; Within-cell means are an alternative. |
| Pooled transition matrices across brands | Short histories and incomplete joint-state support make firm-specific estimation difficult; MARKTEN has 11 consecutive transitions overall. Pooling does not prove common behavior. |
| Separate independent $a$ and $\xi$ processes | Follows initial plan; 12 free probabilities rather than 72 for unrestricted joint nine-state transitions.  Fewer probabilities to estimate|

### Data support and persistence

The exercise uses 540 incumbent-roster observations and 531 adjacent-month pairs. Nicotine monthly stay probabilities are about **97%, 94%, 98%**; $\xi$ persistence is **85%, 74%, 89%**. Roster selection may affect transition estimates.

Representative nicotine values: 10.396, 15.396, 29.606. Representative $\xi$: −0.685, −0.039, 0.743. Full matrices and bin-support comparisons are in Appendix B.


\clearpage

## 6. Key restrictions: costs, fringe, and market size

| Baseline restriction | Evidence / reason alternatives deferred |
|:---------------------------------|:-----------------------------------------------------------------|
| Constant brand-specific MC | Historical within-brand median avoids an additional cost state/process. Not empirically supported. |
| Brand-specific MC upon entry | JUUL/VUSE use their assigned medians, known before entry and retained afterward. |
| Constant January 2013 fringe total utility | We must tell firms what fringe competition looks like in future. Using the median fringe utility from full sample made the fringe much more attractive relative to incumbents (implausible) |
| Constant January 2013 market size  | Avoids solving changing market sizes for this trial. |
| Common constant $FC$ | Hard to estimate because in this version, we only have two entry events among the five brands|

### Assigned MC: real dollars per mL

| BLU | MISTIC | NJOY | JUUL | VUSE |
|-------------------:|-------------------:|-------------------:|-------------------:|-------------------:|
| 7.653 | 1.017 | 3.320 | 6.887 | 3.293 |

IN some months, MISTIC observations imply negative MC. Cost figures are in Appendix C.

### Fringe constant period choice matters

| January monthly variable profit | Median fringe utility | January fringe utility |
|:-----------------------------------------|----------------------------:|----------------------------:|
| BLU | $54 | $142,325 |
| MISTIC | $331 | $714,728 |
| NJOY | $130 | $327,198 |



\clearpage

## 7. Dynamic timing and the option to wait

### Monthly sequence

1. Observe public state: active identities and quality states, plus fixed cost/demand primitives.
2. Active firms play the static pricing game and earn profit minus $FC$.
3. Active firms privately observe scrap draws; never-entered candidates privately observe entry costs. Exit/entry decisions are simultaneous.
4. Exit pays scrap now and removes the brand next month. Entry cost is paid now; initial quality is revealed after commitment, with operations next month.
5. Continuing qualities transition independently. A new entrant receives its initial draw without an extra transition before first operation.



\clearpage

## 8. Key restrictions: private payoffs and observed events

| Baseline restriction | Reason / qualification |
|:---------------------------------|:-----------------------------------------------------------------|
| Exponential entry cost, common mean $\mu_E$ | One positive-support parameter; SD equals mean.  |
| Normal net scrap: mean zero, SD $\sigma_S$ | Allows liquidation gains or shutdown costs; only dispersion is free. |
| Normalize mean net scrap to zero | Restricts payoff location alongside operating/entry-cost levels. Does not prove identification or claim observed mean liquidation is zero. |
| Fresh independent private draws across firms/months | No persistent private type or learning state. Draws reveal no future public shocks. |
| Annual discount 0.95 | Fixed, not estimated; monthly $\beta=0.95^{1/12}\approx0.995735$. |
| Common entrant initial-state distribution | Liquid-volume weights from newly qualifying incumbents' first incumbent-year windows, aligned with the original entrant-MC exercise. Successful incumbents are imperfect newborn-firm proxies. |
| Initial quality revealed after commitment | Integrate over quality before entering; a privately observed poor initial draw cannot explain delay in this version. |
| January 2013 initialization | BLU/MISTIC/NJOY already active; births left-censored. JUUL/VUSE eligible but never entered. |

### First event definitions

- Entry: first positive scanner sales after sample start; compare active operation with that month.
- Exit: first month after final positive sales, if before sample end.
- Internal gaps followed by resumed sales remain within an active spell.
- Sales in December 2023 are right-censored, not an exit.

Scanner events can differ from commercial entry/shutdown because of rollout, inventory runoff, or coverage. These remain provisional proxies.

The focal sample has two post-initial entries and one uncensored exit proxy: MISTIC in November 2023.

\clearpage

## 9. Coarse calibration and current fit

Two coordinate passes held other parameters fixed while varying each coordinate. All nine distinct candidates met dynamic convergence tolerances.

| Parameter | Tested values | Original | Selected |
|:-----------------------------|:---------------------------------|-----------------:|-----------------:|
| Monthly $FC$ | $0; $100,000; $300,000 | $100,000 | **$0** |
| Entry mean $\mu_E$ | $30m; $100m; $300m | $100m | **$300m** |
| Scrap SD $\sigma_S$ | $1m; $5m; $15m | $5m | **$5m** |

Mean scrap stays zero; annual discounting stays 0.95.

### Fit criterion

Use 2,000 common-random-number paths over 132 months. The loss equally weights monthly mean-squared errors for:

1. JUUL/VUSE cumulative-entry curves against observed entry indicators.
2. BLU/MISTIC/NJOY survival curves against observed spells.
3. Mean active-firm count divided by five against its observed counterpart.

Loss falls from **0.0537 to 0.0215 (60%)**. A separate 10,000-path simulation check gives **0.0539 to 0.0211**, supporting improvement beyond the search draws. It is not held-out historical validation.

### Improvement and remaining misses

- BLU simulated exit by 2023 falls from about **70.9% to 0.01%**, closer to its continued observed sales.
- Entry remains early: about **82.5% of JUULs** and **83.6% of VUSEs** enter by their respective observed first-sales months in the larger check.
- The selected model still misses MISTIC's late observed exit.

### Interpretation

**Provisional calibration, not structural estimates.** Fixed cost and entry cost hit grid boundaries. No interior or global optimum is established. Scrap SD $1m/$5m gives tied search outcomes; retaining $5m is a convention. Monthly curve loss rewards long survival spells and can underweight a rare late exit; different weights or an event likelihood could change rankings.

The original baseline is preserved. Fit plots are in Appendix E. [Candidate scores](../../output/dynamic_entry_exit/coordinate_search_2026-11-06/candidate_scores.csv) include residuals and loss components.

\clearpage

## 10. Discussion priorities and audit overview

### Questions

1. **Which restriction should change first?** Fringe utility has a large profit effect; constant MC conflicts with recovered time series. Should either vary before payoff estimation?
2. **Is fixed five-brand scope adequate initially?** It retains major brands but excludes fringe promotion, new identities, and unrestricted turnover.
3. **Are the event targets informative enough?** Two entries and one late exit proxy may not identify three payoff parameters. Revise event measurement, objective weights, or parameterization?
4. **How should market size evolve?** Annual historical updates with current size perceived as permanent were discussed; completed calibration still holds January 2013 size fixed.
5. **What fit standard comes next?** Entry timing, survival, and active counts are current targets. Prices/shares can be additional diagnostics conditional on demand and quality assumptions.

### Audits completed; See appendix

| Exercise | Brief checks |
|:---------------------------------|:-----------------------------------------------------------------|
| Observed-market Bertrand game | Starting prices/damping; observed versus solved prices; price/MC/markup graphs; FOC residuals; unilateral profit maxima; numerical cost shock. |
| Alternative pricing algorithms | Simultaneous/sequential markup updates; sequential manual best responses; firm orders and initial vectors. |
| Fixed-focal inputs / grid | Reconciliation, share inversion, observed-price replication, all-grid pricing, selected unilateral deviations. |
| Dynamic game | Bellman/probability residuals; explicit versus tensor transitions; original-trial alternate starts; simulated discounted payoffs. |
| Coordinate calibration | Re-solve every candidate; exclude failed solves; fresh selected residuals; separate larger simulation check. |

### Established and still open

The baseline is computationally operational. Static checks support numerical Nash pricing; dynamic checks support the tested value/policy fixed points. They do **not** prove uniqueness, validate demand or instrument exclusion, identify payoff parameters, or establish economically zero fixed cost.

**Proposed stopping point:** discuss restrictions and remaining fit failures before refining the grid or undertaking formal estimation. The results identify useful sensitivities rather than settle the final specification.

\clearpage
\setcounter{page}{1}
\renewcommand{\thepage}{A-\arabic{page}}

# Appendix A. Numerical audits and interpretation

## Static pricing

- Original recovery: 540 firm-months. All 1,584 simultaneous start/damping attempts converge; maximum price differences below $3\times10^{-10}$/mL.
- Manually bisected unilateral best responses cover all 540 original firm-months; no profitable deviation beyond rounding under the maintained game.
- Sequential markup: 2,112 attempts. Sequential best responses: 1,056. Across 3,168 attempts, maximum difference from simultaneous prices below $1.75\times10^{-10}$/mL.
- December 2023 VUSE MC +10% raises its price about $0.216$/mL and rivals' prices slightly. This is numerical sensitivity, not estimated causal tax pass-through.
- Fixed-focal reconstruction passes 264 two-start observed-market checks. Dynamic payoff cache solves 100,000 roster/quality configurations; selected independent scalar price checks differ by at most approximately $9.9\times10^{-11}$/mL.

Positive costs in the original 540-row recovery do not imply every later fixed-focal inversion is positive. Ten added MISTIC rows imply negative monthly MC; its dynamic constant cost stays positive.

## Dynamic checks

- Original trial: scaled Bellman residual $9.97\times10^{-7}$; probability residual $2.67\times10^{-8}$.
- Selected calibration, fresh check: $1.14\times10^{-7}$ and $7.76\times10^{-8}$.
- Selected-state explicit enumeration agrees with tensor calculations to relative error below $4.6\times10^{-15}$ in the original trial.
- Two original starts converge; maximum scaled value difference $3.99\times10^{-6}$ and probability difference $3.59\times10^{-7}$. Every calibration point was not independently audited from multiple starts.
- Original-trial 5,000-path discounted cash flows, including terminal continuation values, lie within 1.50 Monte Carlo SE of computed values. This checks accounting conditional on terminal values.

Bellman scaling divides by the maximum of one dollar and compared value magnitudes; tolerance is not an absolute dollar error guarantee. Manual damped iteration uses residual-safeguarded extrapolation, without packaged equilibrium solvers. Numerical robustness does not prove equilibrium uniqueness or economic validity.

[Full static booklet](../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/audit/pricing_audit_plots_with_sequential.pdf). [Dynamic validation](../../output/dynamic_entry_exit/manual_dynamic_trial_2026-11-06/dynamic_validation.csv). [Selected validation](../../output/dynamic_entry_exit/coordinate_search_2026-11-06/selected_validation.csv).

\clearpage

# Appendix B. State support and transition inputs

| Bins per variable | Occupied cells | Minimum departures | Cells with at least 20 departures |
|:-----------------------------|---------------------------------:|-----------------:|-----------------:|
| 2 × 2 | 4/4 | 122 | 4/4 |
| **3 × 3** | **9/9** | **27** | **9/9** |
| 4 × 4 | 16/16 | 6 | 12/16 |
| 5 × 5 | 24/25 | 1 | 11/25 |
| 6 × 6 | 36/36 | 1 | 9/36 |

Departures support a row, not every destination probability. Twenty is a descriptive threshold, not statistical adequacy.

### Nicotine transition matrix

| Current / next | Low | Middle | High | Departures |
|:---------------------------|-----------------:|-----------------:|-----------------:|-----------------:|
| Low | 0.9657 | 0.0343 | 0.0000 | 175 |
| Middle | 0.0335 | 0.9385 | 0.0279 | 179 |
| High | 0.0000 | 0.0169 | 0.9831 | 177 |

### Demand-shock transition matrix

| Current / next | Low | Middle | High | Departures |
|:---------------------------|-----------------:|-----------------:|-----------------:|-----------------:|
| Low | 0.8483 | 0.1517 | 0.0000 | 178 |
| Middle | 0.1412 | 0.7401 | 0.1186 | 177 |
| High | 0.0057 | 0.1023 | 0.8920 | 176 |

### Identification and selection qualifications

Mean-zero net scrap restricts payoff location without proving remaining identification. A shifted exponential generally leaves the adopted zero-origin family; a general payoff-shift equivalence should not be claimed as exact within this fully restricted model. Persistent candidates' option to wait must also be retained.

Transitions are estimated on incumbent-roster observations, but fixed-focal supply includes additional months. Full-sample focal selection, entrant-state calibration from successful incumbents, and scanner-event proxies are separate measurement/selection concerns.

[Full transition inputs](../../output/dynamic_entry_exit/independent_transitions_2026-11-03/README.txt). [Alternative nicotine grids](../../output/dynamic_entry_exit/nicotine_grid_comparison_2026-11-03/nicotine_grid_comparison.pdf).

\clearpage

# Appendix C. Recovered marginal-cost figures

Four pages: cost time series/medians; deviations from medians; costs versus nicotine; observed prices versus costs. These cover the original 540-row incumbent recovery, not all added fixed-focal observations. BLU 2018 inversion-only rows are marked.

[Return to cost/fringe restrictions](#key-restrictions-costs-fringe-and-market-size).

\includepdf[pages=-,landscape=true,fitpaper=true,pagecommand={\thispagestyle{plain}}]{../../output/dynamic_entry_exit/marginal_cost_audit_2026-11-03/recovered_marginal_cost_audit.pdf}

\clearpage

# Appendix D. Selected static pricing audits

Next three pages: price/MC/markup time series; convergence from MC + $1/mL; unilateral profit curves in a difficult month. These support pages 3 and 10 without independently validating demand.

\includepdf[pages={3,4,8},landscape=true,fitpaper=true,pagecommand={\thispagestyle{plain}}]{../../output/static_pricing_subgame/manual_fixed_point_2026-10-28/audit/pricing_audit_plots.pdf}

\clearpage

# Appendix E. Coordinate-calibration fit plots

Four pages: cumulative entry, survival, active counts, and candidate losses. Black is observed, blue original trial, red selected calibration in time-series plots. Search uses 2,000 common-random-number paths; the separate larger check uses 10,000.

[Candidate scores](../../output/dynamic_entry_exit/coordinate_search_2026-11-06/candidate_scores.csv). [Parameter path](../../output/dynamic_entry_exit/coordinate_search_2026-11-06/coordinate_path.csv). [Larger simulation check](../../output/dynamic_entry_exit/coordinate_search_2026-11-06/independent_simulation_check.csv).

\includepdf[pages=-,landscape=true,fitpaper=true,pagecommand={\thispagestyle{plain}}]{../../output/dynamic_entry_exit/coordinate_search_2026-11-06/coordinate_search_comparison.pdf}

\clearpage

# Appendix F. Original dynamic-trial convergence

Iteration traces before coordinate calibration. Iterations are computational updates, not calendar months. Appendix A separately reports fresh residuals for the selected calibration.

\includepdf[pages=-,landscape=true,fitpaper=true,pagecommand={\thispagestyle{plain}}]{../../output/dynamic_entry_exit/manual_dynamic_trial_2026-11-06/dynamic_convergence.pdf}

\clearpage

# Appendix G. From observed shares to simulated profits

**Inverting means solving an equation backward to recover an unobserved quantity.** Historical recovery and simulated pricing are separate steps.

## Step 1: Recover unobserved demand quality

Insert observed shares, prices, and nicotine into the estimated demand equation and solve for its remaining term:

$$
\widehat\xi_{it}=\log(s_{it}/s_{0t})-\widehat c
-\widehat\alpha p_{it}-\widehat\beta_a a_{it}
-\widehat\sigma\log(s_{it}/s_{gt}).
$$

This is the demand residual: the part of mean utility not explained by the included price and nicotine terms. Using this recovered residual makes the fitted demand system reproduce observed shares. It does not independently validate the demand specification.

## Step 2: Recover historical marginal cost

Assume the observed price maximizes the specified firm's profit, holding rivals' prices fixed. Rearrange the pricing FOC:

$$
s_{it}+(p_{it}-mc_{it})\frac{\partial s_{it}}{\partial p_{it}}=0
\quad\Longrightarrow\quad
mc_{it}=p_{it}+\frac{s_{it}}{\partial s_{it}/\partial p_{it}}.
$$

The own-price derivative comes from estimated demand. It is negative, so implied marginal cost is below price. Historical MC is recovered separately for each brand-month. The current dynamic baseline then assigns each brand its historical median cost, held constant across simulated months and states.

## Step 3: Calculate profits at a simulated state

A simulated state specifies the active roster and each active brand's nicotine and $\xi$ bins. With their representative qualities, assigned costs, and fringe benchmark, solve the pricing game for equilibrium prices $p_i^*$ and shares $s_i^*$.

Quantity is $q_i^*=Ms_i^*$. Therefore,

$$
\underbrace{(p_i^*-mc_i)Ms_i^*}_{\text{monthly variable profit}}
\; -\; FC
\;=\;\text{monthly operating profit}.
$$

This operating profit enters the continuation/exit problem. Entry costs and scrap payoffs enter separately at the timing specified on page 7. Simulated prices are solved using assigned costs; they are not imposed to equal observed historical prices.

[Return to static pricing and recovered profits](#static-bertrand-pricing-and-recovered-profits).
