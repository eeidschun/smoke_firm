# Dynamic Nicotine Choice by a Representative E-Cigarette Industry

## A supply-side extension that keeps the existing demand model unchanged

## Purpose of this note

This note develops a supply-side extension designed specifically for the existing household demand model.

The demand model is not changed. Each month, households continue to choose among:

1. a representative cigarette,
2. a representative e-cigarette, and
3. not smoking.

The supply extension asks:

> Given the demand behavior already estimated for the Nielsen-represented population, what incentive would the e-cigarette industry have to choose more or less nicotine today because nicotine consumption changes future e-cigarette retention, future cigarette use, and future abstention?

The model is not a brand-level or UPC-level oligopoly model. The consumer panel is too sparse for that. Instead, the supply side chooses an aggregate nicotine policy that shifts the household-alternative-month nicotine values used by the existing simulation.

A key advantage of this formulation is that it builds directly on the nicotine-imputation grid already used in the demand simulations. The supply side does not need to invent a separate household-level nicotine assignment mechanism from scratch.

---


# 1. Existing demand model in full

## 1.1 Choice set and representative products

Each month \(m\), consumer \(i\), located in state \(s(i)\), chooses one alternative

\[
j\in\mathbf J_{s(i)m}=\{0,e,c\},
\]

where:

- \(0\) is not smoking;
- \(e\) is the representative e-cigarette;
- \(c\) is the representative cigarette.

The cigarette alternative is a homogeneous pack of twenty cigarettes. The e-cigarette alternative is a state-month representative product constructed from heterogeneous products in the RMS data.

Consumers are assumed to be myopic. They choose the alternative that maximizes current utility, taking their current nicotine stock, prior smoking history, prices, laws, and demographics as given. They do not solve a forward-looking dynamic optimization problem.

This matters for the supply extension: the proposed supplier may be forward-looking even though consumers are myopic. Consumers respond to their current state; firms understand that current nicotine choices change consumers' future states.

## 1.2 Nested-logit utility

Alternatives \(c\) and \(e\) belong to a smoking nest, while \(0\) forms a singleton non-smoking nest.

Utility is

\[
U_{ijm}
=
V_{ijm}
+
\zeta_{ig(j)m}
+
\lambda_{g(j)}\epsilon_{ijm},
\]

with observable utility

\[
\begin{aligned}
V_{ijm}
&=
\mathbf L_{s(i)jm}'\beta^L
+
\beta^p p_{s(i)jm}
+
\mathbf S_{ijm}'\beta^S
+
\gamma_j^N N_{im}
+
\mathbf D_i'\gamma_j^D \\
&\quad
+
\gamma_j^{adc}adc_{im}
+
\gamma_j^{ade}ade_{im}
+
\xi_j
+
\sigma_j^{s(i)}
+
\alpha_j^{yr(m)}.
\end{aligned}
\]

The supply model treats the estimated demand parameters as fixed inputs.

## 1.3 What the household state \(x_{im}\) contains

For the supply discussion, it is useful to collect all history-dependent household variables into one object:

\[
x_{im}
=
\left(
N_{icm},
N_{iem},
j^*_{i,m-1},
j^*_{i,m-2},
\mathbf S_{im},
adc_{im},
ade_{im},
\mathbf D_i,
s(i)
\right).
\]

This includes:

- product-specific cigarette nicotine stock \(N_{icm}\);
- product-specific e-cigarette nicotine stock \(N_{iem}\);
- the two most recent choices;
- the four switching-cost indicators;
- cigarette and e-cigarette adoption indicators;
- fixed demographics;
- state.

Total nicotine stock is

\[
N_{im}=N_{icm}+N_{iem}.
\]

The notation \(x_{im}\) is only shorthand. It is not a new latent state estimated separately.

## 1.4 Switching costs

Let \(j^*_{i,m-1}\) denote the prior-period choice.

The four switching indicators are:

- cigarette to e-cigarette;
- e-cigarette to cigarette;
- cigarette to not smoking;
- e-cigarette to not smoking.

For \(a\in\{c,e\}\) and \(b\in\{c,e,0\}\), \(a\neq b\),

\[
s_{ijm}^{a\rightarrow b}
=
\mathbf 1
\left\{
j=b,\,
j^*_{i,m-1}=a
\right\}.
\]

No switching cost is defined when the prior choice was not smoking.

## 1.5 Adoption-history variables

The adoption indicators depend on the prior two choices:

\[
adc_{im}
=
\mathbf 1
\left\{
j^*_{i,m-1}=c
\text{ or }
j^*_{i,m-2}=c
\right\},
\]

and

\[
ade_{im}
=
\mathbf 1
\left\{
j^*_{i,m-1}=e
\text{ or }
j^*_{i,m-2}=e
\right\}.
\]

These variables are described as adoption costs in the current paper, although mechanically they are recent-use indicators whose coefficients determine how prior use affects current utility.

The cross-product coefficients are especially relevant for the supply model:

- \(\gamma_e^{adc}\) governs how recent cigarette use changes e-cigarette choice;
- \(\gamma_c^{ade}\) governs how recent e-cigarette use changes cigarette choice.

These coefficients help determine whether nicotine-induced persistence remains in e-cigarettes or leaks into cigarettes.

## 1.6 Product-specific nicotine stocks

Nicotine stock is tracked separately by product:

\[
N_{im}
=
N_{icm}+N_{iem}.
\]

For \(j\in\{c,e\}\),

\[
N_{ijm}
=
(1-\delta_j)N_{ij,m-1}
+
\mathbf 1
\left\{
type(u_{i,m-1})=j
\right\}
n_{u_{i,m-1}}.
\]

Here:

- \(\delta_j\) is the product-specific depreciation rate;
- \(u_{i,m-1}\) is the UPC consumed in the prior month;
- \(n_u\) is that UPC's nicotine yield.

Initial product-specific stocks are

\[
N_{ij0}=0.
\]

The no-smoking alternative has zero nicotine yield.

The representative RMS nicotine statistic is not used in this equation.

## 1.7 Household-state transition

After a simulated choice, the next household state is determined by the existing updating rules:

\[
x_{i,m+1}
=
g
\left(
x_{im},
y_{im},
\widetilde{\nu}_{iy_{im}m}
\right),
\]

where \(\widetilde{\nu}_{ijm}\) is the household-alternative-month nicotine value from the simulation grid.

The function \(g(\cdot)\):

1. depreciates cigarette and e-cigarette nicotine stocks separately;
2. adds nicotine only to the stock associated with the chosen product;
3. updates the two lagged choices;
4. reconstructs switching indicators;
5. reconstructs adoption indicators.

This more precise formulation matters for supply. A higher e-cigarette nicotine value initially raises \(N_{iem}\), but total stock \(N_{im}\) enters both cigarette and e-cigarette utility through alternative-specific coefficients \(\gamma_c^N\) and \(\gamma_e^N\). The eventual effect on category choice also depends on switching and adoption-history coefficients.

## 1.8 Demand probabilities used by supply

Given state \(x_{im}\), prices, laws, fixed effects, and estimated parameters, the nested-logit model provides

\[
P_{ijm}
=
\Pr(y_{im}=j\mid x_{im},p_{s(i)jm},L_{s(i)jm}).
\]

The supply module does not alter this probability formula. It affects future probabilities indirectly by changing the nicotine assigned after an e-cigarette choice, which changes \(x_{i,m+1}\).

---

# 2. Existing nicotine-consumption grid

## 2.1 Why the grid is necessary

Observed household choices and simulated household choices can diverge.

For example, a household may be observed purchasing:

- cigarettes in period 1, with observed nicotine \(n_1\);
- e-cigarettes in period 2, with observed nicotine \(n_2\).

If the simulation instead assigns cigarettes in both periods, cigarette nicotine for period 2 is not directly observed.

The same problem occurs when a household never purchases e-cigarettes in the observed data but is simulated to choose e-cigarettes.

The existing demand simulation solves this by constructing a nicotine-consumption value for each household-alternative-month triple.

Denote this grid by

\[
\widetilde{\nu}_{ijm}.
\]

It contains a nicotine amount for household \(i\), alternative \(j\), and month \(m\), whether or not that household actually chose that alternative in that month.

---

## 2.2 Current imputation procedure

The grid is constructed as follows.

### Step 1: Closest observed household period

For household \(i\) and alternative \(j\), assign nicotine consumption from the closest period in which household \(i\) is observed consuming \(j\).

Household-alternative pairs that are never observed remain missing.

### Step 2: State-month median

For remaining missing values, assign the median nicotine yield among other households in the same state and month consuming alternative \(j\).

Values remain missing when no household in the state is ever observed consuming \(j\).

### Step 3: Closest state

For still-missing entries, use the median from the closest state.

The closest state is defined using the estimated state fixed effect for alternative \(j\):

\[
\sigma_j^{s}.
\]

The donor state is the state whose alternative-specific fixed effect is closest to that of household \(i\)'s state.

### Step 4: Simulation update

During simulation, if household \(i\) chooses alternative \(j\) in month \(m\), nicotine stock is updated using

\[
\widetilde{\nu}_{ijm}.
\]

For no smoking,

\[
\widetilde{\nu}_{i0m}=0.
\]

---

## 2.3 Important implication for the supply model

The nicotine grid already provides the missing link between:

- an aggregate representative-product environment;
- simulated household choices;
- household-specific nicotine-stock updates.

Therefore, the supply side should not replace the grid with an unrelated draw from a new empirical distribution unless there is a specific reason to do so.

Instead, the supply-side nicotine choice should transform the existing grid.

This is cleaner because:

1. the grid is already used in the baseline demand simulation;
2. it preserves household, alternative, state, and time variation;
3. it handles simulated choices that differ from observed choices;
4. it keeps the supply extension aligned with the current demand code.

---

# 3. How the supply side modifies the nicotine grid

## 3.1 Aggregate nicotine shifter

Let the e-cigarette supply side choose

\[
a_m^N>0,
\]

an aggregate e-cigarette nicotine shifter in month \(m\).

The counterfactual e-cigarette nicotine grid becomes

\[
\widetilde{\nu}_{iem}^{\,cf}
=
a_m^N
\widetilde{\nu}_{iem}^{\,base}.
\]

Cigarette nicotine remains unchanged unless the counterfactual also modifies cigarettes:

\[
\widetilde{\nu}_{icm}^{\,cf}
=
\widetilde{\nu}_{icm}^{\,base}.
\]

No-smoking nicotine remains zero.

Interpretation:

- \(a_m^N=1\): baseline nicotine;
- \(a_m^N=0.8\): every e-cigarette nicotine value in the grid is reduced by 20%;
- \(a_m^N=1.2\): every e-cigarette nicotine value is increased by 20%.

This preserves the relative heterogeneity already built into the grid.

---

## 3.2 Representative nicotine as a target

If the supply choice is expressed in terms of representative RMS nicotine,

\[
\bar n_m^{e,cf},
\]

define

\[
a_m^N
=
\frac{
\bar n_m^{e,cf}
}{
\bar n_m^{e,base}
}.
\]

Then apply the resulting proportional shifter to all e-cigarette values in the household grid.

The representative nicotine series remains a supply-side aggregate target, not a direct demand input.

The causal chain is

\[
\text{representative nicotine choice}
\]

\[
\Downarrow
\]

\[
\text{proportional transformation of the e-cigarette nicotine grid}
\]

\[
\Downarrow
\]

\[
\text{household-specific nicotine-stock updates}
\]

\[
\Downarrow
\]

\[
\text{future cigarette, e-cigarette, and abstention probabilities}.
\]

---

## 3.3 Nicotine cap

A nicotine cap can be implemented directly on the grid.

If the cap applies to total household-level nicotine assigned for an e-cigarette choice,

\[
\widetilde{\nu}_{iem}^{\,cf}
=
\min
\left\{
\widetilde{\nu}_{iem}^{\,base},
\bar \nu
\right\}.
\]

If the policy instead caps nicotine concentration, the ideal implementation would apply the cap to the underlying UPC concentration before rebuilding household nicotine totals.

If only total nicotine is available in the simulation grid, top-coding total nicotine is a reduced-form approximation to the policy.

---

# 4. Model-fit simulations versus policy simulations

This distinction should be explicit because the current code uses different simulation designs for different purposes.

## 4.1 Model-fit simulation

For model fit:

- the horizon is \(M=36\) months;
- households must be observed for at least \(M+2\) periods;
- the first two observed months initialize state variables;
- observed periods 3 through 38 are compared with simulated periods 1 through 36;
- the demand estimation is rerun on the restricted sample;
- nicotine values are taken from the household-alternative-month grid;
- exogenous covariates evolve according to observed trajectories.

This exercise asks:

> Given realistic initial histories and observed covariate paths, does the estimated model reproduce subsequent household choices?

The supply side is not needed for this model-fit exercise.

---

## 4.2 Baseline long-run simulation

The baseline and policy simulations described in the current draft have a different purpose.

They:

- initialize switching costs, adoption costs, and nicotine stock at zero;
- interpret households as beginning without prior smoking history;
- hold most covariates fixed at initial values;
- remove observed year trends by replacing year fixed effects with an average;
- allow smoking-history variables to evolve endogenously;
- use a fixed nicotine amount for each household-alternative over the simulation horizon.

This exercise asks:

> How do smoking histories and nicotine intensity generate long-run choice paths in an otherwise stationary environment?

This setup is highly relevant for the proposed supply model because it isolates the dynamic channel.

However, one current feature should be reconsidered:

> The nicotine yield used for the entire simulation is fixed to the household's first simulated-period value from the grid.

That assumption is convenient for a demand-only baseline, but it prevents the nicotine environment from changing over time.

A supply model that chooses nicotine must instead allow the e-cigarette grid to be transformed period by period:

\[
\widetilde{\nu}_{iem}^{\,cf}
=
a_m^N
\widetilde{\nu}_{ie,1}^{\,base}
\]

if the baseline retains the first-period household value, or

\[
\widetilde{\nu}_{iem}^{\,cf}
=
a_m^N
\widetilde{\nu}_{iem}^{\,base}
\]

if the month-specific grid is retained.

The choice between these two depends on the intended counterfactual.

---

## 4.3 Two coherent supply-simulation environments

### Stationary environment

Use the household's fixed baseline nicotine value and let only the supply shifter change:

\[
\widetilde{\nu}_{iem}^{\,cf}
=
a_m^N
\widetilde{\nu}_{ie,1}^{\,base}.
\]

Advantages:

- isolates the supply-side nicotine mechanism;
- removes observed time trends and composition changes;
- fits the existing long-run baseline design.

Interpretation:

> How would a supplier choose nicotine in a stationary market serving households with these initial characteristics?

### Historical environment

Use the month-specific grid and observed covariate path:

\[
\widetilde{\nu}_{iem}^{\,cf}
=
a_m^N
\widetilde{\nu}_{iem}^{\,base}.
\]

Advantages:

- preserves observed changes in product attributes and industry conditions;
- allows the model to study the 2013--2023 path.

Interpretation:

> Conditional on the observed evolution of technology, regulation, and market structure, how would endogenous nicotine choices differ from the observed path?

The stationary version is easier and cleaner for the first supply exercise. The historical version is better for explaining the observed nicotine path.

---


# 4A. Implications of the more precise demand specification for supply

The detailed demand model changes several supply-side interpretations.

## 4A.1 Consumers are myopic, but the supplier may be forward-looking

Consumers do not internalize how current smoking affects their own future nicotine stock. The supplier, however, can understand the estimated transition process.

This creates a potential wedge:

> A supplier may value a nicotine increase because it changes future demand even though consumers choose myopically using only current utility.

This is one reason the dynamic supply extension may be economically interesting.

## 4A.2 Nicotine does not contemporaneously raise utility as a product characteristic

The current e-cigarette nicotine choice does not directly enter current utility. It changes nicotine stock only after consumption.

Therefore, in the minimal model, nicotine has:

- a current production or reformulation cost;
- little or no current demand benefit through the utility equation;
- a future demand benefit or cost through nicotine-stock accumulation.

Without some current benefit, dynamic benefit, regulatory constraint, or cost advantage, the supplier may optimally choose the lowest feasible nicotine level. The model must therefore be explicit about which observed force makes positive nicotine profitable.

Potential forces include:

- future e-cigarette retention;
- future cigarette profit under common ownership;
- an omitted current consumer valuation of strength;
- a relationship between nicotine and consumption quantity;
- technological constraints tying nicotine to other valued attributes.

The first implementation should check whether estimated future-demand effects alone are large enough to rationalize positive nicotine.

## 4A.3 Product-specific stock accounting should be preserved

Because the model has \(N_{icm}\) and \(N_{iem}\), the simulation should continue depreciating them separately.

An e-cigarette nicotine increase at month \(m\) raises the e-cigarette stock component first:

\[
N_{ie,m+1}
=
(1-\delta_e)N_{iem}
+
\widetilde{\nu}_{iem}^{cf}.
\]

It does not directly add to cigarette stock.

Total stock then enters future utility:

\[
N_{i,m+1}
=
N_{ic,m+1}+N_{ie,m+1}.
\]

## 4A.4 Switching and adoption channels are distinct from nicotine

A higher e-cigarette nicotine assignment affects future choice through nicotine stock.

An e-cigarette choice also independently changes:

- the lagged-choice state;
- e-cigarette adoption history;
- future switching costs.

The supply analysis should therefore decompose the effect of a nicotine change while holding the current simulated choice fixed when measuring the marginal nicotine channel. Otherwise, the nicotine effect may be mixed with the effect of inducing more e-cigarette choices.

A useful decomposition is:

1. **intensive nicotine effect:** increase nicotine conditional on the same current e-cigarette choices;
2. **extensive choice effect:** allow any price or product changes to alter who chooses e-cigarettes;
3. **history effect:** track how those different choices change switching and adoption states.

## 4A.5 The nested structure matters for leakage

Cigarettes and e-cigarettes share a smoking nest. Higher nicotine stock may increase the attractiveness of the smoking nest relative to abstention, while switching and adoption terms determine allocation within the smoking nest.

Thus a nicotine increase may primarily:

- reduce future abstention;
- then be divided between cigarettes and e-cigarettes according to relative utilities within the smoking nest.

This suggests reporting both:

\[
\Delta \Pr(c\text{ or }e)
\]

and the conditional allocation

\[
\Delta \Pr(e\mid c\text{ or }e).
\]

That decomposition is more informative than reporting only e-cigarette and cigarette share changes.

---

# 5. What the demand model can already do without supply

The existing demand model can already conduct valid mechanical counterfactuals.

## 5.1 Mechanical nicotine cap

Apply a cap to the e-cigarette nicotine grid and simulate forward.

This answers:

> How would consumers respond if nicotine were capped while firms made no other changes?

## 5.2 Mechanical price change

Set

\[
p_m^{e,cf}=0.9p_m^{e,base}.
\]

This answers:

> How would consumers respond to an exogenous 10% e-cigarette price reduction?

## 5.3 Why these exercises remain valuable

They are:

- transparent;
- directly tied to estimated demand;
- easy to interpret;
- free of extra supply assumptions.

A supply model should not replace them automatically.

---

# 6. What a supply side adds

The supply model asks:

> Once a policy changes incentives or constraints, how would the industry optimally change nicotine, price, capacity, or availability?

The gain is endogenous firm response.

## 6.1 Nicotine-cap response

Firms may:

- increase liquid capacity;
- change price;
- reformulate;
- withdraw products;
- change product format;
- choose nicotine exactly at or below the cap.

## 6.2 Price response

A supply model can determine whether a tax or cost shock is:

- passed through;
- absorbed in markups;
- offset through nicotine or capacity;
- associated with product withdrawal.

## 6.3 Dynamic nicotine choice

The most distinctive extension is that firms may value nicotine because it changes future demand.

Higher e-cigarette nicotine today may:

- increase future e-cigarette retention;
- increase future cigarette use;
- reduce future abstention.

The existing simulation can quantify all three channels.

---

# 7. Population state used by the supplier

Let

\[
\mu_m
\]

denote the distribution of household states \(x_{im}\) across the simulated population.

This is a genuine distribution.

In a finite simulation, it is represented by the collection of all household states.

It summarizes:

- cigarette users;
- e-cigarette users;
- abstainers;
- nicotine stocks;
- recent cigarette histories;
- recent e-cigarette histories.

The supplier cares about \(\mu_m\) because the profitability of nicotine depends on the current composition of consumers.

Let

\[
Z_m
\]

collect exogenous supply conditions such as:

- taxes;
- regulation;
- technology;
- HHI;
- dominant-brand era;
- input costs.

The full supply state is

\[
S_m=(\mu_m,Z_m).
\]

---

# 8. Supply choices and current profit

## 8.1 Minimal first model

Let the supplier choose only

\[
a_m^N,
\]

the e-cigarette nicotine-grid shifter.

Price is held fixed.

Current e-cigarette demand is produced by the existing choice model:

\[
Q_m^e
=
\frac{1}{I}
\sum_i
P_e(x_{im};p_m,Z_m,\widehat\theta_D).
\]

Current normalized profit is

\[
\pi_m^e
=
\left[
p_m^e
-
c_m^e(a_m^N;Z_m)
-
\tau_m^e
\right]
Q_m^e
-
F_m(a_m^N,a_{m-1}^N).
\]

A simple cost function is

\[
c_m^e(a)
=
c_{0m}
+
c_1a
+
\frac{c_2}{2}a^2,
\qquad c_2>0.
\]

Adjustment cost can be

\[
F_m(a_m,a_{m-1})
=
\frac{\psi}{2}(a_m-a_{m-1})^2.
\]

Because nicotine does not directly enter current utility as a product characteristic, the principal modeled demand benefit of a higher \(a_m^N\) appears in future periods through nicotine stock.

This creates an important discipline: the model should first calculate whether the estimated continuation-demand benefit is large enough to offset the assumed marginal cost of nicotine or reformulation. If not, the proposed supply mechanism alone cannot rationalize observed positive or rising nicotine without an additional current-period benefit, cost linkage, or constraint.

---

# 9. Population transition under a supply choice

Given \(a_m^N\):

1. calculate current choice probabilities;
2. simulate or integrate current choices;
3. assign nicotine using the existing household-alternative grid;
4. multiply e-cigarette nicotine by \(a_m^N\);
5. update household states using \(g(\cdot)\);
6. collect the resulting distribution \(\mu_{m+1}\).

Write this compactly as

\[
\mu_{m+1}
=
G
\left(
\mu_m,
p_m^e,
a_m^N,
Z_m;
\widehat{\theta}_D,
\widetilde{\nu}^{base}
\right).
\]

The function \(G(\cdot)\) is not a separately estimated behavioral equation. It means running the existing household simulation for one period under the candidate supply policy.

---

# 10. Dynamic supplier problem

## 10.1 Full internalization benchmark

A fully forward-looking representative supplier solves

\[
V_m(S_m)
=
\max_{a_m^N}
\left\{
\pi_m^e
+
\beta_F
\mathbb E
\left[
V_{m+1}(S_{m+1})
\right]
\right\},
\]

subject to the household transition generated by the demand model.

## 10.2 Partial future-demand capture

Introduce

\[
\kappa_m\in[0,1].
\]

Interpretation:

- \(\kappa_m=0\): current-profit-only supplier;
- \(\kappa_m=1\): full representative-industry internalization;
- intermediate values: partial capture of future category demand.

Then

\[
V_m(S_m)
=
\max_{a_m^N}
\left\{
\pi_m^e
+
\kappa_m\beta_F
\mathbb E
\left[
V_{m+1}(S_{m+1})
\right]
\right\}.
\]

A possible calibration is

\[
\kappa_m=g(HHI_m),
\]

with higher concentration implying greater expected capture of future e-cigarette demand.

HHI remains an observed conditioning variable rather than an endogenous model outcome.

---

# 11. Cigarette leakage and common ownership

Higher e-cigarette nicotine may increase future cigarette use.

Introduce

\[
\rho_m\in[0,1],
\]

where:

- \(\rho_m=0\): no cigarette-profit internalization;
- \(\rho_m=1\): full cigarette-profit internalization.

The supplier's profit stream can include

\[
\pi_m^e+\rho_m\pi_m^c.
\]

This permits comparison between:

- standalone e-cigarette firms;
- integrated tobacco firms.

The continuation value should be defined using ownership-weighted future profits to avoid double counting.

---

# 12. Concentration and capacity

A richer model separates total nicotine into

\[
n_m^e
=
\eta_m z_m m_m,
\]

where:

- \(z_m\) is nicotine concentration;
- \(m_m\) is liquid capacity;
- \(\eta_m\) is transfer efficiency.

The supply side can then choose concentration and capacity separately.

This is necessary to study:

- concentration caps;
- capacity responses;
- per-mL taxes;
- per-mg nicotine taxes;
- nicotine-salt technology;
- disposable technology.

The existing household nicotine grid would need to be rebuilt or decomposed into concentration and capacity components before applying these counterfactuals.

This should be a later extension.

---

# 13. Recommended first empirical exercise

Before solving a full supply problem, measure the dynamic demand effect of nicotine using the existing grid.

For selected starting months:

1. hold household states and current simulated choices fixed;
2. run the baseline state transition;
3. multiply nicotine assigned to current e-cigarette choosers by \(1+\epsilon\);
4. simulate future periods using the unchanged demand model;
5. compare outcomes;
6. repeat while allowing current choices to respond if a separate contemporaneous supply margin, such as price, also changes.

The first version isolates the intensive nicotine-stock channel. The second combines intensive and extensive responses.

Report

\[
\sum_{h=1}^{36}\Delta Q_{m+h}^e,
\]

\[
\sum_{h=1}^{36}\Delta Q_{m+h}^c,
\]

and

\[
\sum_{h=1}^{36}\Delta Q_{m+h}^0.
\]

This quantifies:

- e-cigarette retention;
- cigarette leakage;
- reduced abstention.

It establishes whether the dynamic supply incentive is economically important before imposing supply costs.

---

# 14. Tractable solver

## 14.1 Open-loop path optimization

Choose a path

\[
\mathbf a^N
=
(a_1^N,\ldots,a_M^N)
\]

to maximize discounted profit over the simulation horizon.

For each candidate path:

1. initialize household states;
2. simulate forward;
3. transform e-cigarette nicotine-grid values;
4. update states;
5. calculate profit;
6. sum discounted profit.

## 14.2 Low-dimensional parameterization

Rather than optimizing every month separately, parameterize the path by:

- a constant;
- several blocks;
- a spline;
- observed HHI and technology regimes.

For the stationary 36-month simulation, a constant \(a^N\) may be enough for the first exercise.

For the historical model, use regime-specific values.

## 14.3 Common random numbers

Use the same random draws across candidate supply policies so that differences in simulated profits reflect policy changes rather than simulation noise.

---

# 15. Calibration and identification

Potential supply parameters include:

- nicotine cost;
- reformulation cost;
- supplier discount factor;
- future-demand capture;
- ownership;
- technology-regime shifts.

These are unlikely to be point identified cleanly from the current data.

Recommended approach:

1. hold demand parameters fixed;
2. calibrate \(\beta_F\);
3. treat \(\kappa\) and \(\rho\) as sensitivity parameters;
4. calibrate cost curvature to selected nicotine moments;
5. report a range of results.

The initial contribution is the mechanism, not full identification of industry conduct.

---

# 16. Paired counterfactuals

For each major policy, report:

## Demand-only version

Mechanically alter the nicotine grid or price and hold firm behavior fixed.

## Supply-adjusted version

Allow the supplier to reoptimize nicotine and any permitted additional margins.

Define

\[
\text{Supply-response contribution}
=
\text{Supply-adjusted outcome}
-
\text{Demand-only outcome}.
\]

This makes the incremental value of the supply side explicit.

---

# 17. Recommended research sequence

## Step 1

Finalize and validate the nicotine grid used in the 36-month simulation.

## Step 2

Run demand-only nicotine-cap and price counterfactuals.

## Step 3

Estimate the forward effect of a small nicotine-grid perturbation.

## Step 4

Add a simple nicotine cost and solve for a constant optimal nicotine shifter.

## Step 5

Vary future-demand capture \(\kappa\).

## Step 6

Add common ownership \(\rho\).

## Step 7

Move from the stationary simulation to the historical 2013--2023 environment.

## Step 8

Split nicotine concentration and capacity.

## Step 9

Only then consider endogenous price.

---

# 18. Important limitations

1. The demand population is the Nielsen-represented population.

2. The supply-side choice shifts the existing nicotine grid; it does not predict exact UPC choices.

3. The imputation procedure is part of the supply-demand bridge and should be included in sensitivity analysis.

4. HHI and industry regimes are exogenous conditioning variables.

5. Brand-level strategic interaction is not modeled.

6. Modern disposables are underrepresented in RMS.

7. Supply parameters may be weakly identified.

8. The stationary baseline and historical model answer different questions.

9. Welfare analysis requires a normative treatment of addiction.

---

# 19. Bottom line

The existing nicotine grid materially improves the proposed supply extension.

The supply side no longer needs an abstract mapping from representative nicotine to household nicotine. It can operate directly on the same household-alternative-month nicotine values already used in the demand simulations.

The key objects are:

\[
x_{im},
\]

the state of household \(i\);

\[
g(\cdot),
\]

the existing state-update code;

\[
\widetilde{\nu}_{ijm},
\]

the imputed household-alternative-month nicotine grid;

\[
\mu_m,
\]

the distribution of household states;

and

\[
a_m^N,
\]

the supply-side shifter applied to the e-cigarette nicotine grid.

The cleanest first supply exercise is a stationary 36-month simulation in which the supplier chooses a constant or low-dimensional nicotine shifter, understands how it changes future household states, and trades those future demand effects against nicotine and reformulation costs.
