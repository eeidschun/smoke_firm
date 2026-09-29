# Build prompts for Claude in VS Code — MPE solve, "Today" stage

## Price construction update ? 2026-09-29

Firm-month price is the **UPC-unweighted mean of UPC-month prices in real dollars per mL**:

`p_upc,t = sum(real revenue_upc,t) / sum(mL sold_upc,t)`

`p_i,t = mean(p_upc,t across eligible UPCs belonging to firm i in month t)`

Collapse multiple T2 rows to one brand ? UPC ? month observation before taking the ratio. Use the existing sample: UNKNOWN excluded, positive units and mL, and at least three reporting stores per UPC-month. Each eligible UPC receives equal weight within its firm-month, matching the across-UPC weighting convention for nicotine state `a_i,t`.

This replaces the firm's aggregate revenue/mL price in `code/build/8_build_firm_month_demand_panel.R`. Quantities, revenue totals, shares, market size, and the population-weighted national tax instrument retain their existing construction. The saved descriptive fringe `p_F` remains aggregate fringe revenue/mL; it is not a price regressor or strategic price in the current model.

The product-line average price times total firm mL generally does not equal observed revenue. Consequently, model revenue/profit based on this representative price should not be described as an accounting reconstruction of scanner revenue.


Ground truth for every stage below is the three PDFs already in the repo: the conference model note (`ec_supply_conference_model.pdf`), the solution appendix (`ec_supply_solution_appendix.pdf`), and the talk deck (for high-level framing only). The solution appendix has every equation, numbered; the model note has the prose motivation. Tell Claude in VS Code to implement exactly what's in these documents — notation is `q` = quantity, `s` = market share, `M_t` = market size (`q_{i,t} = M_t · s_i(p_t,ω_t)`) — not to re-derive the model from a generic BLP template, since small notational drift (e.g. reusing `q` for share) is exactly what we just spent several turns cleaning up.

Run these one stage at a time, in order. Don't hand over the whole list at once — verify each stage's sanity checks before moving to the next. If a stage fails or looks wrong, that's cheaper to catch immediately than after three more stages are built on top of it.

---

## Stage 0 — Orientation (run first, before writing anything)

```
Before writing any new code, look at the current state of this repository.
Summarize: (1) what data construction and diagnostics are already implemented
(especially anything building a_{i,t}, prices, quantities/shares, or firm
entry/exit records), (2) what language/framework/tooling is in use, (3) what
data files exist and their structure (column names, panel dimensions,
date range). Don't write or modify any code yet — just report back so we can
plan the next steps against what's actually here.
```

## Stage 1 — Demand estimation (Berry inversion / IV-2SLS)

References: solution appendix §1 "Demand system," eqs. (1)–(4) for shares, eq. (7) for the estimating equation. Model note §3 for the mean-utility specification.

```
Implement the demand-side estimation described in ec_supply_solution_appendix.pdf
§1 "Demand system" and ec_supply_conference_model.pdf §3.

1. Incumbent/fringe classification: a firm counts as an incumbent for
   calendar year Y iff its annual market share (annual mL sold among
   identified brands / total annual mL among identified brands, same
   filtering as the existing roster construction: UPC-months with at
   least 3 stores, UNKNOWN brand excluded) exceeds 7%. This
   classification is fixed for all 12 months of year Y even though the
   logit itself is estimated at monthly frequency — a firm does not
   flicker between incumbent and fringe within a year. Firms below 7%
   for year Y are folded into the fringe aggregate for that year
   instead. Recompute this annually and report the resulting incumbent
   count by year — it should range roughly 3-6 firms/year per
   diagnostics already run outside this repo; flag it if your numbers
   look different.

2. From the firm-month panel, construct s_{i,t} (incumbent shares, per
   the classification in step 1), s_{F,t} (fringe share, one aggregate
   row per period), s_{0,t} = 1 - sum_i s_{i,t} - s_{F,t} (outside
   option), and s_{g,t} = sum_i s_{i,t} + s_{F,t} (total nest share) —
   per appendix step 1.

3. Construct the price instrument before building the estimating
   equation, since it requires an external data merge and should be
   checked on its own before it feeds into a regression:
   a. State-month e-liquid excise tax rates ($/mL) — already available
      from earlier work on this project.
   b. Census state population figures (a single recent year is fine as
      weights, or year-varying if it's easy to pull — either is
      defensible since these are aggregation weights, not the object
      of interest, unlike the firm-sales weights in the earlier
      shift-share design this replaced).
   c. Compute the national, population-weighted tax series:
        TaxIV_t = sum_s (Pop_s / Pop_US) * tax_{s,t}
      This is ONE value per month t — it does not vary by firm i.
   d. Merge TaxIV_t onto the firm-month panel by month: every firm
      active in month t gets the same TaxIV_t value (this is
      intentional, not a bug — the instrument is at the national-month
      level, not firm-month). Confirm no months are missing a value
      after the merge before moving on.

4. Build the estimating equation (appendix eq. 7):
   ln(s_{i,t}) - ln(s_{0,t}) = beta_a * a_{i,t} - alpha * p_{i,t}
       + sigma * ln(s_{i,t}/s_{g,t}) + xi_{i,t}
   estimated on incumbents only.

5. p_{i,t} and ln(s_{i,t}/s_{g,t}) are both endogenous (correlated with
   xi_{i,t} — firms price higher and capture more within-nest share exactly
   when their unobserved quality xi_{i,t} is high) and need to be
   instrumented. a_{i,t} enters uninstrumented (treated as uncorrelated with
   xi_{i,t}).

   Instrument for p_{i,t}: TaxIV_t, built in step 3 (per Marc Rysman's
   guidance — NOT a firm-specific shift-share design).

   Instrument for ln(s_{i,t}/s_{g,t}) — the number of firms active in the
   market that period (per Marc's guidance). More active rivals mechanically
   compress a firm's within-nest share without being correlated with that
   firm's own xi_{i,t}.

6. Run the 2SLS regression. Report beta_a_hat, alpha_hat, sigma_hat, and
   save xi_hat_{i,t} (the regression residual) per firm-period. Report the
   first-stage F-stat for each instrumented regressor specifically — since
   TaxIV_t varies only by t (not by firm), check that it still has power
   after any time fixed effects included in the first stage; if
   time effects are needed to control for other period-level trends, the
   tax instrument's identifying variation could get absorbed by them, so
   flag this explicitly rather than silently reporting a weak F-stat.

Sanity checks to report: the incumbent count by year from step 1 (should be
roughly 3-6 firms/year), sigma_hat in [0,1), alpha_hat negative (price
coefficient), first-stage F-stats for the instrumented regressors, and a
scatter or summary of xi_hat_{i,t} to check it doesn't have an obvious trend
or outlier problem.
```

## Stage 2 — Marginal cost recovery

References: appendix §2 eq. (8)–(9), and the FOC-inversion algebra (c = p + s_i/(∂s_i/∂p_i)).

```
Using the demand estimates from Stage 1, recover marginal cost at every
observed (i,t) by inverting the static pricing first-order condition
(ec_supply_solution_appendix.pdf §2, eq. 9, solved for c instead of p):

c_hat(omega_{i,t}) = p_{i,t} - 1 / ( alpha_hat *
    [ 1/(1-sigma_hat) - sigma_hat/(1-sigma_hat) * s_{i|g,t} - s_{i,t} ] )

using the observed p_{i,t} and the shares/conditional shares implied by the
Stage-1 estimates.

Then fit c_hat as a function of the state (e.g. a flexible regression of
c_hat on a_{i,t}, or on a_{i,t} and firm/period controls if the fit is poor)
so you have a cost function c(omega) defined over the whole state grid, not
just the observed points — this is the function that later stages evaluate
at off-sample states.

Sanity checks: c_hat < p_{i,t} for essentially all observations (positive
markup — flag any where it isn't), c_hat should be positive and in a
plausible range given input costs for this product category, and check
whether the fitted c(omega) tracks c_hat reasonably well in-sample (R^2 or
residual plot).
```

## Stage 3 — State space discretization and transitions

References: appendix §3, eq. (transition), and the F_a/F_ξ construction steps.

```
Implement the state space and transition-kernel construction from
ec_supply_solution_appendix.pdf §3 "State space and transition."

1. Put a_{i,t} and xi_hat_{i,t} (from Stage 1) each on a finite grid.
   a_{i,t} is already close to discrete by construction; xi_hat_{i,t} is a
   continuous residual and needs to be binned (evenly-spaced or quantile
   bins — tell me which you'd like, or propose both and show me the
   resulting grid sizes).
2. Restrict to (i,t) -> (i,t+1) pairs where firm i is active in both
   periods (continuing incumbents only).
3. Pool across firms and estimate F_a and F_xi as empirical first-order
   Markov transition matrices (appendix eq. for F_a; repeat identically for
   xi).
4. Estimate G_e(.), the entrant's initial-state distribution, from the
   observed states of firms in the period they enter.

Report the resulting grid sizes for a and xi, and flag any grid cells with
very few observed transitions (thin-data cells the later dynamic solve will
be sensitive to).
```

## Stage 4 — Exit scrap value and entry cost distributions

This is the one part of the model that isn't fully pinned down yet — you'll need to make (or confirm) a decision before Claude can code it.

```
I need to specify phi_i (exit scrap value) and x_e (sunk entry cost) as
private, i.i.d.-per-period draws, identified from entry/exit hazard rates
in the data — net of the ownership-shock carve-out (MarkTen/MISTIC exits
excluded as exogenous corporate decisions, not equilibrium exit).

Before writing estimation code: propose 2-3 standard parametric families
used in the Pakes-McGuire / Ericson-Pakes literature for phi_i and x_e
(e.g. shifted exponential, uniform, log-normal), and for each, sketch how
its parameters would be identified from observed exit/entry hazard rates
conditional on state. I'll pick one before you implement it.
```

## Stage 5 — Static pricing subgame solver

References: appendix §2 eq. (9)–(10), and the worked example (two incumbents + fringe).

```
Implement a solver for the static pricing subgame from
ec_supply_solution_appendix.pdf §2, "Static pricing subgame":

Given a state omega_t (active firms' (a,xi), the fringe's a_F, and cost
c(omega_{i,t}) from Stage 2), solve the n_t simultaneous FOCs (eq. 9) for
the equilibrium price vector p*(omega_t), using the fixed-point iteration
(eq. 10) as the first-pass method, with a fallback to Newton's method on
the stacked FOC system if the fixed point doesn't converge or converges
slowly (per the note after eq. 10). The fringe is not an extra unknown —
its mean utility delta_{F,t} = beta_a_hat * a_{F,t} is exogenous and enters
the D_{g,t} denominator directly.

Return p*(omega_t) and the implied static profit pi_i*(omega_t) for every
active firm.

Validate against the worked two-incument-plus-fringe example in the
appendix (§2) as a unit test, and separately validate by evaluating the
solver at observed historical states and checking how closely p*(omega_t)
matches the actually-observed p_{i,t} — this is your main check that
Stages 1-2 and this solver are mutually consistent.
```

## Stage 6 — Dynamic program: MPE via nested fixed point

References: appendix §4 "Dynamic entry and exit," Algorithm 1; model note §5.

```
Implement Algorithm 1 from ec_supply_solution_appendix.pdf §4 — the nested
fixed point for the Markov Perfect Equilibrium:

Given: static profits {pi_i*(omega)} over the state grid (from Stage 5),
and the primitives F_a, F_xi (Stage 3), G_e (Stage 3), phi_i, x_e
distributions (Stage 4), beta (discount factor — confirm the value/monthly
rate to use before running).

Outer loop: guess exit rule lambda^exit and entry rule lambda^entry.
Inner loop: given those rules, iterate the Bellman equation
    V_i(omega) <- pi_i*(omega) + max{ phi_i, beta * E[V_i(omega') | omega,
        lambda^exit, lambda^entry] }
to convergence (this is a contraction since beta < 1 — should converge
reliably; flag it if it doesn't).
Update lambda^exit from the converged V_i (exit iff phi_i exceeds the
continuation value) and lambda^entry from the entry condition
(beta * E[V_e(omega_{e,0},.)] - x_e >= 0).
Repeat the outer loop until both policies stop changing (no general
convergence guarantee here per the appendix note — if it doesn't settle,
report the oscillation pattern rather than forcing an arbitrary stopping
point).

Restrict the inner loop to the Pakes-McGuire (2001) "recurrent states" set
(states actually reached under simulated play) rather than the full grid,
to keep this tractable — this is the same technique flagged in the
appendix as what keeps Stage-1 (exogenous-state) solves feasible even
though the full grid is large.
```

## Stage 7 — Full outer algorithm

References: appendix §5, Algorithm 2.

```
Tie Stages 5-6 together per Algorithm 2 in ec_supply_solution_appendix.pdf
§5: for every state on the grid, solve the static pricing system (Stage 5)
to get p*(omega) and pi_i*(omega); feed {pi_i*(omega)} into the Stage-6
nested fixed point to get the converged value functions and exit/entry
rules; then simulate the model forward (or compute its implied moments
directly) for whatever estimation routine will ultimately match this to
the data.

Report solve time and where the bottleneck is (the appendix flags Stage 5,
the pricing fixed point at every grid state, as the most likely runtime
bottleneck — confirm or correct that).
```

---

### Before you start

One thing still needs a decision from you before Stage 1 can actually run:
- **phi_i / x_e distributional family** (Stage 4) — flagged in the appendix as not yet locked in. Have Claude propose options against the literature before it writes estimation code for this piece.

Instruments for Stage 1 are now specified (population-weighted national excise tax for price, count of active firms for the within-nest share) — this design needs only state-month tax rates and Census state population figures, not firm-by-state sales data, so there's no geographic-detail prerequisite to check before handing Stage 1 over.

The incumbent/fringe classification is also now specified (annual market share > 7%, fixed per calendar year, decoupled from the N̄ = 5 dynamic-game cap) — settled after checking that this cutoff keeps every firm's incumbent spell unbroken in the data (unlike 10%+, where NJOY drops out and returns in 2018). One open item this doesn't resolve: whether a future threshold-crossing should be treated as dynamic entry/exit for Stage 4/6 purposes — flagged as a question for Marc, not yet needed for Stage 1.

Everything else in Stages 1-3 and 5-7 is fully specified in the documents and should be safe to hand over directly.
