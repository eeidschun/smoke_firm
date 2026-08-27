---
title: "A Modest Supply Side for the Homogeneous-Good E-Cigarette Demand Model"
subtitle: "Companion note to *Dual Dynamics of U.S. Cigarette & E-Cigarette Demand* — the price/nicotine series, the open-refill and disposable-coverage caveats, tracked volume, market concentration, and a parsimonious supply relation"
date: "2026"
geometry: margin=1in
fontsize: 11pt
---

## 1. How these objects map to the demand model

In the panel nested logit, agents in a state-month market choose among
$\mathcal{J} = \{\text{representative cigarette},\ \text{representative
e-cigarette},\ \text{not smoking}\}$, and the representative e-cigarette price is

$$
p_{ms} = \big(\text{avg.\ price per mL}\big)_{ms} \times \big(\text{avg.\ e-liquid
capacity}\big)_{ms},
$$

with both averages taken under **mL (e-liquid) sales weights**. That is exactly the
object denoted $P_{\text{hom}}$. Writing $u_i$ for units and $m_i$ for
mL per unit of product $i$,

$$
p_{ms} = \Big(\tfrac{\text{revenue}}{\text{mL sold}}\Big)\times \bar m,
\qquad
\bar m = \frac{\sum_i u_i m_i^2}{\sum_i u_i m_i},
$$

where $\bar m$ is average product size **weighted by mL sold** (the $m_i^2$ is not a
second squaring — it is the algebra of weighting each size $m_i$ by its own mL sales
$u_i m_i$). The representative e-cigarette's nicotine content — the nicotine *flow*
$n_{ij,m}$, built as $\text{mg/mL}\times\text{mL}\times\text{units}\times 0.68$
transfer efficiency and feeding the stock $N_{im}$ — is the analogous
mL-weighted object, $N_{\text{hom}}$.

**Why this matters for the paper:** the descriptive series below *are* the
demand-side regressors ($p_{ms}$ and the representative-e-cig nicotine that drives
$N_{im}$). Anything unusual in them — the mid-2019 blip, the pod-weighting — is
already inside the estimation inputs. The series are shown in §2, split by product
form factor; the disposable-coverage comparison appears in §6, and the supply relation
that closes the model is developed in §9.

## 2. What drives $p_{ms}$ and the representative nicotine, period by period

![National monthly series by form factor (pooled = dashed red).](../prelim_analysis/p_and_n_decomp_t2/national_monthly_series_by_type.png)

**2013–2015 (cigalikes).** blu/NJOY/Logic cigalikes and bottled juice dominate
tracked retail; price per mL falls (~\$8→\$5) as bulk-juice competition intensifies;
nicotine is modest, so $p_{ms}$ is high-ish but the representative nicotine flow is
low.

**2016–2017 (nicotine salts).** JUUL commercializes salts, making ~5% nicotine
palatable in 0.7 mL pods. The representative concentration climbs steeply while
average capacity $\bar m$ falls as small pods displace cartridges; the nicotine flow
into $N_{im}$ rises.

**2018–2019 (JUUL, and one caveat for $p_{ms}$).** JUUL becomes the largest brand by
mL; representative concentration peaks (~34 mg/mL, 2019–20). Two notes for the
inputs: (i) the fall-2019 EVALI scare temporarily depressed e-cig demand; and (ii) a
**spurious mid-2019 bump** in the *pooled* $p_{ms}$ and nicotine is a two-month
liquidation of discontinued 30 mL open-refill bottles (Mistic/HAUS, Cosmic Fog) whose
recorded price fell from ~\$25 to ~\$2.69 (verified in the raw Nielsen price field).
Because those bottles are large in mL, the mL-weighted $\bar m$ jumps (~3.7→5.2),
lifting $p_{ms}$ **even though price per mL and the average unit price both fell**. It
is real in the data but a *composition/weighting* effect; it is state-specific and
small, but it enters the state-month $p_{ms}$ where open refill had share.

**2020 (regulation splits the market).** The Feb 2020 FDA enforcement priority on
flavored *cartridge* ENDS exempted disposables; flavored volume migrates to
disposables; pod nicotine plateaus (see the timeline in §4).

**2021–2023 (modern disposables).** Within closed pods, price is stable and nicotine
keeps rising, now more via capacity than concentration; within disposables, nicotine
surges via *size* (5–6 mL units). But see §6 — disposables are a minority of the
tracked volume, so $p_{ms}$ remains pod-dominated.

The pooled endpoint decomposition (2013→2023) is robust to all data corrections:
$\Delta p_{\text{hom}}\approx-\$5.7$ (price/mL $-13.7$, size $+15.4$) and
$\Delta N_{\text{hom}}\approx+80$ mg (concentration $+37$, size $+23$).

## 3. The same series excluding open refill

The pooled series in §2 include all three product types, and open refill is the
noisiest of them: it is a thin sliver of tracked volume (bottled e-liquid and open
tanks, sold largely through channels the scanner panel captures poorly), so a single
clearance event or a few large-bottle SKUs can swing its mL-weighted averages — the
mid-2019 artifact is exactly such an episode. Because the firm-relevant "closed"
products are the closed pods and disposables, it is useful to view the series with
open refill fully excluded. In this view the pooled line is **pod + disposable only**.

![National monthly e-cig series — closed pod and disposable, open refill fully excluded (pooled = dashed red, pod + disposable).](../prelim_analysis/p_and_n_decomp_t2/national_monthly_series_by_type_no_open.png)

A note on brand composition first. In the *all-types* market (§8 concentration table),
MISTIC is the market leader in 2015–2017 (~21–26% of all mL). But MISTIC is ~75–88%
**open refill** — bottled juice — so it is largely absent from the pod+disposable
series shown here. Excluding open refill, the closed-product leaders through 2017 are
the cigalike incumbents: BLU (61%→26% of pod+disposable mL, 2013→2017), then LOGIC
rising to second (14→20%), with 21st Century Smoke, FINITI, and NJOY filling in. This
is why the closed-product narrative names Logic rather than MISTIC — MISTIC's mid-decade
"leadership" is a bottled-juice phenomenon that the supply-relevant closed series does
not see.

Period by period, for the pod+disposable pooled series ($P_{\text{hom}}$ in real \$,
$N_{\text{hom}}$ in mg):

- **2013–2015 (cigalike closed pods + old disposables).** BLU-led cigalikes dominate;
  price/mL falls from ~\$7.0 to ~\$5.1, nicotine is modest (~13→15 mg/mL), capacity
  $\bar m$ is ~3.9–4.7 mL. $P_{\text{hom}}$ eases ~27→24, $N_{\text{hom}}$ rises ~49→68.
- **2016–2017 (salts begin, pods shrink).** LOGIC climbs to second; nicotine
  concentration rises (14.6→19.4 mg/mL) while capacity falls (4.7→3.3 mL) as small pods
  displace big cartridges. $P_{\text{hom}}$ ~24→20; $N_{\text{hom}}$ dips slightly
  (~68→64) because capacity falls a touch faster than concentration climbs.
- **2018–2019 (JUUL).** JUUL takes 51% then 44% of pod+disposable mL; concentration
  jumps (19.4→28.9 mg/mL) and capacity collapses to ~2.8–3.0 mL (0.7 mL JUUL pods);
  $N_{\text{hom}}$ 64→86. Crucially, with open refill excluded there is **no mid-2019
  bump** — the spurious pooled-series blip in §2 was entirely an open-refill clearance
  artifact, and it vanishes here. This is the clearest demonstration of why the no-open
  view matters.
- **2020 (regulation splits the market).** JUUL still leads (34%) but VUSE closes to
  28%; nicotine plateaus (~29 mg/mL), capacity begins rising again; $N_{\text{hom}}$
  ~93. See the timeline in §4.
- **2021–2023 (VUSE/JUUL duopoly, modern disposables).** VUSE leads (44%→55%), JUUL
  second; capacity rises sharply (3.2→5.0 mL) as 5–6 mL modern disposables grow;
  concentration eases (29→23 mg/mL) but $N_{\text{hom}}$ keeps climbing (93→115) because
  size rises faster than concentration falls; price/mL settles near \$4.4 and
  $P_{\text{hom}}$ recovers ~16→22.

The endpoint decomposition is robust to excluding open refill: 2013→2023,
$\Delta P_{\text{hom}}\approx-\$5.2$ (vs $-\$5.7$ pooled-with-open) and
$\Delta N_{\text{hom}}\approx+66$ mg (vs $+80$ pooled-with-open) — the same sign and
story, with the smaller $N$ change reflecting that large, high-nicotine open-refill
bottles inflate the pooled endpoint.

## 4. Timeline of regulatory and market events

The following events provide context for the 2019–2020 shifts in the series above; the
numbered dashed lines in the tracked-volume and disposable-share figures mark them.

- Fall 2019: the EVALI outbreak (peaked August–September 2019), linked mostly to
  illicit THC/vitamin-E-acetate products rather than nicotine pods, temporarily
  depressed nicotine e-cigarette demand.
- September 2019: the administration announced its intent to clear flavored
  e-cigarettes from the market; JUUL voluntarily pulled its fruit and mint flavors in
  November 2019.
- January 2, 2020: the FDA finalized its "Enforcement Priorities for ENDS" guidance.
- February 6, 2020: the enforcement priorities took effect, prioritizing action against
  flavored (other than tobacco and menthol) prefilled cartridge / pod ENDS. Open-system
  e-liquids and disposables were not covered, so flavored disposables (Puff Bar, later
  Elf Bar) were exempt and flavored volume migrated to them.
- September 9, 2020: the premarket tobacco application (PMTA) deadline — products had to
  have submitted applications to remain legally marketed. Many modern disposables are
  imports without granted PMTAs, which is part of why they sell through channels the
  scanner panel captures poorly.

## 5. Tracked sales volume (units)

The trends above work in shares and in price/nicotine intensities; the figures below
give the underlying denominator — total tracked unit sales — so the shares can be read
in context. Units are packages/cartridges as scanned (see §7, the unit-definition
caveat, regarding cross-source comparisons).

![Tracked e-cigarette unit sales by product type (RMS), monthly, millions of units. Dashed vertical lines (numbered 1–4) mark the timeline events listed in the figure note.](../prelim_analysis/p_and_n_decomp_t2/tracked_units_by_type.png)

Two features stand out: the ~2018 step up in closed-pod units (the JUUL takeoff), and
the post-2020 re-emergence of disposables. Open refill is small throughout and falls to
near zero after 2020.

![Tracked e-cigarette unit sales, pooled: all three types vs pod + disposable only. Dashed vertical lines (numbered 1–4) mark the timeline events listed in the figure note.](../prelim_analysis/p_and_n_decomp_t2/tracked_units_pooled.png)

Pooling confirms that open refill contributes little to tracked *unit* volume: the
all-three-types line and the pod+disposable-only line nearly coincide, especially after
2019. This is the volume counterpart to the mL-weighting point in §6 — the tracked
market is overwhelmingly a closed-product (pod, then pod+disposable) market by units.

## 6. Disposables are under-represented in RMS — implication for $p_{ms}$

The representative $p_{ms}$ is mL-weighted and therefore pod-dominated, partly because
disposables are a small share of *tracked* volume: ~24% of units and ~17% of mL even
in 2023. Benchmarking against the CDC/IRI all-outlet series shows the gap.

![Disposable share of unit sales: RMS vs CDC/IRI all-outlet benchmark. Dashed vertical lines (numbered 1–4) mark the timeline events listed in the figure note.](../prelim_analysis/p_and_n_decomp_t2/disposable_share_vs_CDC_benchmark.png)

: Disposable share of unit sales (disposable / (pod + disposable)).

| | Jan 2020 | Dec 2022 |
|---|---:|---:|
| CDC/IRI (all-outlet) | 24.7% | 51.8% |
| RMS (this dataset)   | 7.4%  | 21.3% |

The CDC MMWR (IRI retail-scanner data) reports the disposable unit share rising from
**24.7% to 51.8%** over Jan-2020→Dec-2022 — disposables became the market majority —
while the RMS series shows the same *direction and timing* at ~30–40% of the *level*.
The gap is a post-2020, **modern-disposable** phenomenon: those brands (Puff Bar, Elf
Bar, Breeze, Lost Mary) sell heavily through vape shops, specialty/convenience, and
online, and are largely **imports without granted PMTAs** — sales channels scanner
panels capture poorly (and even IRI excludes vape shops/online).

**For the paper this is a scope statement, not a flaw.** The representative
e-cigarette is the *tracked-retail, pod-weighted* e-cigarette, and the household
panel purchases come from the same tracked universe, so demand and the price index are
internally consistent. Two points are worth stating: (i) that the representative e-cig
is pod-weighted and disposables are a lower bound; and (ii) that this connects to the
"Moving Forward" idea of capturing the changing e-cig landscape (number of
brands/products) — the disposable wave is exactly the heterogeneity RMS misses.

## 7. The low RMS disposable share: unit-definition vs. channel coverage

The RMS disposable share in §6 sits well below the CDC/IRI benchmark. Two things could
drive that: (i) a *unit-definition* difference — the CDC/IRI series standardizes
**1 unit = 5 prefilled cartridges = 1 disposable device = 1 e-liquid bottle** (Ali et
al. 2023), whereas the §6 RMS series counts raw scanner packages, so a multi-pod pack
counts as one "unit" against one disposable; and (ii) genuine *channel* undercoverage.
The figure isolates (i) by recomputing the RMS disposable share under CDC's standardized
unit — closed-pod cartridges ÷ 5, one unit per disposable and per e-liquid bottle — and
including e-liquid in the denominator to match CDC's three categories. This
standardization is a comparability diagnostic only; it is **not** used in the demand or
supply model, which keep the raw series.

![Disposable share under raw package counts vs. CDC's standardized unit, against the CDC/IRI benchmarks. Dashed vertical lines (numbered 1–4) mark the timeline events listed in the figure note.](../prelim_analysis/p_and_n_decomp_t2/disposable_share_cdc_standardized.png)

The standardized definition raises the RMS disposable share materially — from 7.4% to
14.3% in January 2020, and from 21.3% to 30.6% in December 2022 — closing roughly 30–40%
of the gap to the CDC/IRI points (24.7% and 51.8%). The residual gap (14.3 vs 24.7;
30.6 vs 51.8) is what channel coverage explains: IRI captures convenience/gas/dollar/
military outlets that carry disposables heavily, and both IRI and RMS exclude vape shops
and online, where modern disposables concentrate. So the low RMS disposable share
reflects two compounding causes — the unit convention and outlet coverage — and even the
standardized RMS share remains a lower bound on the true all-channel figure. (Cartridge
counts here are recovered from the always-populated pack structure; disposables and
bottles are one unit each.)

## 8. Market concentration over time — and what it implies for conduct

The homogeneous-good series average over whichever brands sell in a given state-month,
so the concentration of that underlying brand set is itself a supply-relevant object.
The figure plots the monthly Herfindahl–Hirschman index (HHI) of national brand mL
shares — mL-weighted to match $P_{\text{hom}}$/$N_{\text{hom}}$ — on the 0–10,000 scale
with the DOJ moderately-/highly-concentrated reference lines (1,500 and 2,500). Two
series are shown: all brands (the residual **UNKNOWN** bucket treated as one "brand,"
which understates fragmentation) and identified brands only (UNKNOWN dropped, shares
renormalized).

![National e-cigarette market concentration (HHI, mL-weighted).](../prelim_analysis/p_and_n_decomp_t2/hhi_over_time.png)

The concentration path is **U-shaped**:

- **2013 (BLU era).** BLU holds ~56% of tracked mL; HHI ~3,500–4,000 — highly concentrated.
- **2014–2017 (fragmentation).** MISTIC/NJOY/LOGIC and bottled-juice brands proliferate;
  no brand exceeds ~26% and HHI falls to ~1,400–1,600, near the moderately-concentrated floor.
- **2018–2020 (JUUL).** JUUL re-concentrates the market; HHI back above 2,500, leader share ~47% (2018).
- **2021–2023 (VUSE/JUUL duopoly).** VUSE overtakes JUUL; the top two hold ~88% of tracked
  mL (CR3 ≈ 87%) and HHI climbs to ~3,550 by 2023 — highly concentrated again.

![Annual e-cigarette brand composition (mL-weighted): top-5 brands shown individually, ★ marks the leader (CR1), everything else pooled as "Other".](../prelim_analysis/p_and_n_decomp_t2/concentration_by_year.png)

: Annual concentration, mL-weighted brand shares (national).

| Year | Leader | Leader share | Runner-up | CR3 | HHI |
|---|---|---:|---|---:|---:|
| 2013 | BLU    | 56.0% | FINITI | 78.3% | 3519 |
| 2014 | BLU    | 35.0% | FINITI | 61.8% | 1869 |
| 2015 | MISTIC | 24.0% | BLU    | 55.5% | 1430 |
| 2016 | MISTIC | 25.9% | BLU    | 61.3% | 1564 |
| 2017 | MISTIC | 20.8% | BLU    | 56.0% | 1430 |
| 2018 | JUUL   | 46.9% | VUSE   | 67.7% | 2612 |
| 2019 | JUUL   | 42.3% | NJOY   | 77.0% | 2609 |
| 2020 | JUUL   | 33.7% | VUSE   | 87.3% | 2639 |
| 2021 | VUSE   | 43.7% | JUUL   | 87.7% | 2966 |
| 2022 | VUSE   | 50.5% | JUUL   | 87.9% | 3338 |
| 2023 | VUSE   | 54.8% | JUUL   | 86.8% | 3553 |

**Implication for the supply side (structure vs. conduct).** For most of the sample the
tracked market is *highly* concentrated — a single dominant brand (BLU, then JUUL) and,
by 2021–2023, a VUSE/JUUL duopoly with HHI ~3,500. Taken at face value, that structure
is **not** obviously a price-taking, competitive market, so the competitive /
constant-marginal-cost closure recommended in §9 cannot be justified on *structural*
grounds. That is precisely why the recommendation leans on **observed near-unit tax
pass-through** rather than on the HHI: pass-through is firm *behavior*, and — given the
demand curvature the logit implies — full pass-through of a *specific* tax maps to
$\theta\approx 0$, whereas a structural HHI is silent about conduct. Two takeaways: (i)
the concentration series is the reason to *test* conduct through pass-through rather
than *assume* competition; and (ii) because structure points toward market power,
imposing $\theta=0$ is a genuine assumption, worth a robustness check that either bounds
$\theta$ or re-runs the ban counterfactual under a positive constant markup (§9(e)
already sketches why a positive markup would make the "modest increase" an upper bound).

One data caveat mirrors §6: this HHI is computed on **tracked-retail mL**, where modern
disposables (Puff Bar, Elf Bar, Breeze, Lost Mary) are undercovered. Because those
brands sell through channels the scanner panel captures poorly, the true post-2020
market is likely *less* concentrated than the pod-dominated series shows — the
2021–2023 HHI is an upper bound on all-channels concentration, even as it accurately
describes the tracked-retail universe the demand model uses.

## 9. A modest supply side that fits the model

**Purpose.** A 40-page supply model is not needed. A one- to two-equation supply
side (a) *closes* the model so counterfactual **prices can respond**, (b) is
**disciplined by observed tax pass-through**, and (c) demonstrates the e-cigarette
ban result is **robust** to price responses. Three design choices follow from the
setup.

**(a) Match the product; avoid BLP.** The demand model puts the e-cigarette in as one
homogeneous representative good at the state-month level. The supply side should be a
**homogeneous-good pricing relation at the state-month level**. A differentiated
products (BLP) pricing system over pods/disposables/brands is inconsistent with a
homogeneous demand object and is unnecessary.

**(b) Framework: a conduct (markup) pricing relation.** The natural counterpart is the
conduct-parameter / conjectural-variations relation (Bresnahan 1982; Lau 1982) — the
homogeneous-good tool within the broader New Empirical IO program (to be precise: NEIO
is the research program; the conduct relation is the specific model). For the
representative e-cigarette with own-price elasticity $\eta_{ms}$ implied by the
demand estimates,

$$
p_{ms} = MC_{ms}(w_{ms},\, \tau_{ms},\, N_{ms}) \;-\; \theta\,\frac{p_{ms}}{\eta_{ms}},
$$

where $\tau_{ms}$ is the excise tax, $w_{ms}$ input-cost shifters, $N_{ms}$ the
representative nicotine content, and $\theta\in[0,1]$ nests competition ($\theta=0$,
$p=MC$) through monopoly ($\theta=1$).

**(c) Recommendation: *impose* the competitive / constant-marginal-cost case rather
than estimate $\theta$.** Two reasons, both grounded in the paper's own materials:

- Cotti et al. (2022) put e-cig
  tax pass-through at 0.90–1.01 and He et al. (2023) put cigarette pass-through at
  1.00–1.10. Full pass-through of a specific tax is the signature of competitive /
  constant-MC pricing; it is hard to reconcile with substantial market power plus the
  demand curvature the logit implies. So the data point to $\theta\approx 0$.
- *Identification.* Separating conduct $\theta$ from marginal cost requires **demand
  rotators** — instruments that change the *slope* of demand. The only excluded price
  instrument is the excise tax, which is *already* used to instrument price in the
  demand second stage; a tax shifts both cost and (through price) demand level, so it
  cannot also credibly identify conduct (cf. Corts 1999). Imposing the
  competitive/full-pass-through case is therefore both more defensible and more
  parsimonious than estimating a weakly-identified $\theta$.

Concretely: set $p_{ms} = c_{ms} + \tau_{ms}$ (or $c_{ms}+\tau_{ms}+$ a constant
markup), with $c_{ms}$ a marginal-cost function of input prices and the representative
nicotine content $N_{ms}$; back out $c_{ms}$ from observed prices and taxes; validate
against the published pass-through. This adds essentially one equation.

**(d) Nicotine belongs in cost, not a firm FOC.** In the model nicotine enters
*dynamically* through the addiction stock $N_{im}$, and the representative nicotine is
a mL-weighted market aggregate rather than a single firm's static choice variable.
Nicotine should therefore enter **marginal cost** (higher delivered nicotine is
costlier and, post-2016, technologically gated by salts) and be treated as a slowly
evolving characteristic — *not* a structural nicotine first-order condition. A
firm-level nicotine-choice model would require a differentiated-products setup that has
been deliberately avoided.

**(e) Why this is worth a paragraph in the paper — the ban counterfactual.** The
e-cigarette ban raises cigarette demand by removing a substitute. With **fixed
prices** (the current counterfactual) the result is a *modest* increase in cigarette
smoking. Adding the competitive/constant-MC supply side leaves cigarette marginal cost
— and hence the cigarette price — **unchanged** when e-cigarettes are banned, so the
fixed-price ban result is *robust* under the pricing model the pass-through evidence
supports. The contrast is informative: *if* cigarette firms had market power, the
demand increase would raise cigarette prices and **attenuate** the switch to
cigarettes, making the "modest increase" an upper bound. Near-unit cigarette
pass-through (He et al. 2023) argues against that, so the competitive closure both
validates the result and tells the reader why. For **tax** counterfactuals the same
supply relation delivers the price response directly.

## 10. Summary and what would sharpen this

- The $p_{ms}$ and representative nicotine are mL-weighted homogeneous objects; the
  pooled series carry one small mid-2019 open-refill artifact worth a footnote, and
  are pod-weighted because disposables are undercovered in tracked retail (a scope
  statement, consistent with the household panel).
- Tracked-market concentration is **U-shaped** (HHI ~3,500 under BLU in 2013, down to
  ~1,400–1,600 in 2015–2017, back to ~3,500 under the VUSE/JUUL duopoly by 2023). Because
  the market is highly concentrated for most of the sample, the competitive closure rests
  on *observed pass-through*, not structure — and imposing $\theta=0$ is an assumption
  worth a robustness check.
- Pair the homogeneous-good demand with a **homogeneous-good, state-month pricing
  relation**; **impose competitive / constant-MC with full tax pass-through**
  (justified by Cotti et al. 2022 and He et al. 2023), rather than estimate a
  weakly-identified conduct parameter; put nicotine in marginal cost. Avoid BLP and
  avoid a demand/supply product mismatch (no pod-only supply under all-e-cig demand).
- The supply side's payoff is concrete and modest: it disciplines price/tax
  counterfactuals and demonstrates the e-cigarette-ban result is robust to price
  responses.

Making the supply moments exact requires: (i) the implied own-price elasticity of
the representative e-cigarette from the nested-logit estimates (given $\hat\beta^p$,
$\hat\lambda=0.624$, and the shares); (ii) a decision on whether the supply side is
wanted purely for *counterfactual price response* or also to *estimate* marginal cost;
and (iii) whether cigarettes and e-cigarettes should share a cost/pass-through
specification or be separate. With those, the exact estimating/closing equations can
be written to slot into the GMM.
