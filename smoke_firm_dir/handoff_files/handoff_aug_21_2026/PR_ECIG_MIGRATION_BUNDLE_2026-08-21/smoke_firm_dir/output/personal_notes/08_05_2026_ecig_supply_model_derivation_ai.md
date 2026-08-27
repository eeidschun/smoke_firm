---
title: "Supply-Side Model for the Representative E-Cigarette"
subtitle: "Specification, derivation from the nested-logit demand, and solution algorithms"
date: "2026"
geometry: margin=1in
fontsize: 11pt
---

This note specifies the supply side that pairs with the panel nested-logit demand
model, derives every object from the demand primitives, and gives explicit steps to
(i) estimate marginal cost and (ii) solve counterfactuals. The recommended
specification is a **homogeneous-good industry pricing relation** with the
**competitive / constant-marginal-cost** case imposed; the general conduct-parameter
model is carried through so the competitive case is visible as a restriction.

## 1. Environment and notation

Markets are state-month pairs $(s,m)$; write the subscript $ms$. In each market there
is a single **representative e-cigarette** sold at price $p_{ms}$ — the mL-sales-weighted
index $p_{ms}=(\text{avg price/mL})_{ms}\times(\text{avg capacity})_{ms}$ from the
demand model. Let

- $\tau_{ms}$ — the specific excise tax per representative e-cigarette (built with the
  same weights as $p_{ms}$; "analogous formula for the tax instrument" in your slides);
- $c_{ms}$ — marginal cost per representative e-cigarette (net of tax), assumed
  constant in quantity within a market;
- $N_{ms}$ — the representative nicotine content (the mL-weighted $N_{\text{hom}}$);
- $M_{ms}$ — market size (number of agents), taken as given by the pricing decision.

The e-cigarette is produced by many firms/SKUs; we do **not** model them individually.
Instead a scalar **conduct parameter** $\theta\in[0,1]$ indexes industry pricing, so a
single homogeneous-good relation summarizes supply.

## 2. Demand elasticity of the representative e-cigarette

The pricing relation needs the own-price response of e-cigarette demand, which comes
entirely from your estimated demand. Your nests are $g\in\{\text{Not-smoke},
\text{Smoke}\}$ with $\text{Smoke}=\{c,e\}$ (cigarette, e-cigarette) and nest scale
$\lambda\equiv\lambda_{\text{Smoke}}\in(0,1]$ ($\hat\lambda=0.624$). With representative
utility $V_{j,ms}=\beta^p p_{j,ms}+\dots$ and common price coefficient $\beta^p<0$, the
choice probability factors as

$$
s_{e,ms}=\underbrace{\frac{\exp(V_{e}/\lambda)}{\sum_{k\in\text{Smoke}}\exp(V_{k}/\lambda)}}_{\displaystyle P_{e\mid S}}
\cdot
\underbrace{\frac{\exp(IV_{S})}{\sum_{g}\exp(IV_{g})}}_{\displaystyle P_{S}},
\qquad
IV_{S}=\lambda\ln\!\!\sum_{k\in\text{Smoke}}\!\!\exp(V_{k}/\lambda).
$$

**Derivation of the own-price semi-elasticity.** Because $\partial V_e/\partial
p_e=\beta^p$,

$$
\frac{\partial \ln P_{e\mid S}}{\partial p_e}=\frac{\beta^p}{\lambda}\,(1-P_{e\mid S}),
\qquad
\frac{\partial IV_S}{\partial p_e}=\beta^p P_{e\mid S},
\qquad
\frac{\partial \ln P_S}{\partial p_e}=\beta^p P_{e\mid S}\,(1-P_S).
$$

Adding the two log-derivatives ($\ln s_e=\ln P_{e\mid S}+\ln P_S$) gives the key object

$$
\boxed{\;D_{ms}\equiv\frac{\partial \ln s_{e,ms}}{\partial p_{ms}}
=\beta^p\underbrace{\Big[\tfrac{1}{\lambda}\big(1-P_{e\mid S}\big)+P_{e\mid S}\big(1-P_S\big)\Big]}_{\displaystyle A_{ms}>0}\; }<0,
$$

and the own-price **elasticity** $\eta_{ms}=p_{ms}\,D_{ms}=\beta^p p_{ms}A_{ms}$. All of
$P_{e\mid S},P_S,\lambda,\beta^p$ come from your estimates, so $D_{ms}$ and $\eta_{ms}$
are computed market-by-market with no new parameters. (As $\lambda\to1$ this collapses
to simple logit, $A=1-s_e$; smaller $\lambda$ raises the within-nest term, i.e.
cigarettes are the closest substitute.)

## 3. The pricing (supply) relation

Aggregate e-cigarette quantity is $Q_{ms}=M_{ms}\,s_{e,ms}$. With constant marginal
cost and a specific tax remitted by sellers, the homogeneous-good conduct FOC is

$$
p_{ms}-\big(c_{ms}+\tau_{ms}\big)=-\,\theta\,\frac{Q_{ms}}{\partial Q_{ms}/\partial p_{ms}}
=-\,\frac{\theta}{D_{ms}}
=\frac{\theta}{|\beta^p|\,A_{ms}}\;\ge 0 .
$$

$M_{ms}$ cancels; the markup depends only on demand objects and $\theta$. Special cases:

| Conduct | $\theta$ | Pricing relation |
|---|---|---|
| Perfect competition / price-taking | $0$ | $p_{ms}=c_{ms}+\tau_{ms}$ |
| Symmetric $n$-firm Cournot | $1/n$ | $p_{ms}=c_{ms}+\tau_{ms}+\dfrac{1}{n\,|\beta^p|A_{ms}}$ |
| Monopoly / perfect collusion | $1$ | $p_{ms}=c_{ms}+\tau_{ms}+\dfrac{1}{|\beta^p|A_{ms}}$ |

The cigarette side is symmetric, with its own $A^{c}_{ms}$ (using $P_{c\mid S}$) and
$\theta^{c}$. Under $\theta=0$ the two sides decouple (each price equals its own
cost+tax), which sidesteps cross-price strategic interactions between cigarettes and
e-cigarettes even though they share a nest.

## 4. Marginal-cost specification

Model net-of-tax marginal cost as

$$
c_{ms}= \mathbf{w}_{ms}'\gamma \;+\; \gamma_N\,N_{ms}\;+\;\phi_s+\psi_{\text{year}}\;+\;\omega_{ms},
$$

where $\mathbf{w}_{ms}$ are input-cost shifters (e.g. wholesale/PPI hardware and
propylene-glycol/nicotine input proxies, import price indices), $N_{ms}$ is the
representative nicotine content (higher delivered nicotine is costlier and, post-2016,
technologically gated by salts), $\phi_s,\psi_{\text{year}}$ absorb region/time cost
levels, and $\omega_{ms}$ is the structural cost shock. Nicotine enters **cost**, not a
firm choice: in your model nicotine acts dynamically through the stock $N_{im}$ and the
representative content is a market aggregate, so a nicotine FOC would require a
differentiated-products setup you have avoided.

## 5. Pass-through, and why impose competition

Differentiate the pricing relation in $\tau$, noting $A_{ms}$ depends on $\tau$ only
through $p$:

$$
\rho_{ms}\equiv\frac{\mathrm d p_{ms}}{\mathrm d\tau_{ms}}
=\frac{1}{\,1-\dfrac{\theta}{|\beta^p|}\dfrac{\mathrm d}{\mathrm d p}\!\left(\dfrac{1}{A_{ms}}\right)}.
$$

At $\theta=0$, $\rho=1$ (full pass-through) exactly. For $\theta>0$ pass-through departs
from one by a term proportional to demand curvature $\tfrac{\mathrm d}{\mathrm dp}(1/A)$.
Your own references estimate near-unit pass-through — Cotti et al. (2022) put e-cig
pass-through at $0.90$–$1.01$ and He et al. (2023) put cigarette pass-through at
$1.00$–$1.10$ — which is the empirical signature of $\theta\approx0$ with roughly
constant marginal cost.

**Identification of conduct.** Separating $\theta$ from $c$ requires *demand rotators*
(instruments that shift the slope of demand). Your only excluded price instrument is
the excise tax, which you already use to instrument price in the demand second stage;
a tax shifts cost and, through price, the demand level, but does not cleanly rotate the
demand slope, so $\theta$ is weakly identified (Corts 1999). Given (i) the pass-through
evidence and (ii) this identification limit, **impose $\theta=0$** (or a single constant
markup) rather than estimate $\theta$.

## 6. Estimation steps (recover the cost function)

1. **Demand objects.** From the estimated demand, compute $P_{e\mid S,ms}$,
   $P_{S,ms}$, $s_{e,ms}$, and $A_{ms}=\tfrac1\lambda(1-P_{e\mid S})+P_{e\mid S}(1-P_S)$;
   form $D_{ms}=\beta^pA_{ms}$ and $\eta_{ms}=p_{ms}D_{ms}$ at every $(s,m)$.
2. **Impose conduct.** Set $\theta=0$: implied net-of-tax marginal cost is
   $\hat c_{ms}=p_{ms}-\tau_{ms}$. (Constant-markup variant: $\hat c_{ms}=p_{ms}-\tau_{ms}-\mu$,
   with $\mu$ a single scalar estimated in step 3.)
3. **Cost regression.** Regress $\hat c_{ms}$ on $\mathbf w_{ms},N_{ms}$, and fixed
   effects to recover $\gamma,\gamma_N$ and the residual $\omega_{ms}$. If instead you
   *estimate* a constant markup or $\theta$, do so by GMM using cost instruments
   $\mathbf w_{ms}$ (and, for $\theta$, any credible demand rotator), stacking the
   demand and supply moments; bootstrap as in your demand step.
4. **Validate.** Compute model pass-through $\rho_{ms}$ (Section 5) and check it against
   $0.90$–$1.10$. Under imposed $\theta=0$ it equals $1$ by construction; the test is
   whether a constant-MC cost function *fits* $\hat c_{ms}$ (small, cost-shifter-driven
   $\omega$), which is the substantive assumption.

Repeat 1–4 for cigarettes with $A^c_{ms}$ if a cigarette cost function is needed for
counterfactuals.

## 7. Solving counterfactuals

Prices are static (per-period) in each simulated month, so at each month of your
forward simulation use the scenario's equilibrium price, then let the dynamic states
(nicotine stock $N_{im}$, switching and adoption costs) evolve exactly as in your
baseline.

**(a) Tax change $\tau\to\tau'$ under $\theta=0$.** Marginal cost is invariant, so
$p'_{ms}=\hat c_{ms}+\tau'_{ms}=p_{ms}+(\tau'_{ms}-\tau_{ms})$ — full pass-through,
analytic, no fixed point. Feed $p'_{ms}$ into the choice probabilities and re-simulate.

**(b) General $\theta>0$ (if you report it as a robustness case).** Price solves a
fixed point because the markup depends on shares, which depend on price:
$$
p^{(t+1)}_{ms}= \hat c_{ms}+\tau_{ms}+\frac{\theta}{|\beta^p|\,A_{ms}\!\big(p^{(t)}_{e},p^{(t)}_{c}\big)},
$$
and symmetrically for $p^{c}$. Iterate both prices to convergence (a contraction for
$\theta$ not too large); then re-simulate demand. Under $\theta=0$ this reduces to (a).

**(c) E-cigarette ban.** Remove $e$ from the choice set (nest Smoke $=\{c\}$).
Cigarette marginal cost is unchanged, so under $\theta^c=0$ the cigarette price is
**unchanged** at $\hat c^c_{ms}+\tau^c_{ms}$; recompute shares over $\{c,\text{not
smoke}\}$ and simulate. This is why your fixed-price ban result is robust under the
pricing model the pass-through evidence supports. If instead $\theta^c>0$, removing the
substitute $e$ raises cigarette demand and hence the cigarette markup/price via (b),
which **attenuates** the induced switch to cigarettes — so your competitive result is
an upper bound on the ban-induced increase in cigarette use, and the near-unit
cigarette pass-through argues that the attenuation is small.

## 8. Assumptions and limitations

- **Constant marginal cost** in quantity within a market (supported by near-unit
  pass-through); rules out short-run capacity/upward-sloping supply.
- **Static (per-period) pricing**: no dynamic/forward-looking firm behavior, even
  though demand is dynamic; defensible for a competitive, low-margin index good.
- **Homogeneous good**: the representative e-cigarette is pod-weighted and disposables
  are undercovered in tracked retail (see companion note); the supply relation
  describes that tracked market, consistent with the household panel.
- **Conduct imposed, not tested**: $\theta$ is set to the competitive value on the
  strength of external pass-through evidence rather than identified in-sample.
