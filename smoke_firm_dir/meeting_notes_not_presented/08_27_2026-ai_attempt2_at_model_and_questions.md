# E\-cigarette Supply\-Side Model

Working notes: decoding Rysman's comments, a two\-stage model write\-up, and a diagnostics list · draft

## 1\. What this note does

Marc's comments in *EC\_supply.pdf* read like a whiteboard session, not a spec — that's normal, but it means the first job is translation, not modeling. Section 2 walks through his bullets and says what I think each one means, and flags the two or three spots that are genuinely ambiguous and worth a two\-minute confirmation with him rather than guessing. Sections 3–5 write down an actual model in two stages, matching the plan he sketched: a tractable static\-pricing/dynamic\-entry\-exit version for the internal conference, and the full dynamic\-investment version — in Fershtman–Pakes Experience\-Based Equilibrium (EBE) form, per Pakes's recommendation — for the paper itself. Section 6 lists the open choices. Section 7 is a diagnostics list: statistics worth pulling from the Nielsen RMS panel *before* locking down functional forms, several of which are close to things already computed in the two `08_05_2026` notes.

Citations to Ericson–Pakes (1995), Pakes–McGuire (1994, 2001), Benkard (2000, 2004), and Fershtman–Pakes (2012) are characterized from memory at the level of "what the paper does" — worth confirming exact notation and the formal EBE definition against the originals before it goes in a draft.

## 2\. Decoding Rysman's notes

**"Measure of quality... See it as ξ in BLP... how much production you've done \+ ξ... static nested logit... as you pick more quality it decreases costs... learn and forget."**

This is the learning\-by\-doing frame, closest to Benkard's aircraft\-productivity papers rather than pure Ericson–Pakes. A firm's "quality" state is *accumulated production experience* — a stock that rises with output and (per "forget") depreciates over time absent continued production — plus an exogenous shock ξ layered on top, playing the role BLP's ξ plays in demand: the part of quality the econometrician doesn't observe but the firm and consumers do. The "as you pick more quality it decreases costs" line is the mechanism: experience doesn't just shift demand, it lowers marginal cost. That's a specific and testable claim (§7.4 below).

**"If multiple quality levels... ξ cost of nicotine delivery... which do you have to invest in... endogenous in that investment does not affect it... ξ exogenous via Markov, just to match the data... need to track ξ of rivals."**

This bullet is the one place I can't fully resolve without asking him. Two readings:

- *Reading A:* there are two separate state variables — an endogenous one (accumulated experience/investment, which the firm controls) and ξ specifically as *cost of nicotine delivery*, which is exogenous and evolves via a Markov chain calibrated to match the observed nicotine series, not derived from a deeper primitive. "Investment does not affect it" would then describe ξ, not the endogenous state — i.e., firms invest in the *other* state variable, and ξ moves on its own (plausibly driven by industry\-wide technology diffusion or regulation, not firm\-specific R&D).
- *Reading B:* it's a note\-to\-self debating whether ξ itself should be made endogenous (investable) or left exogenous, and he's leaning exogenous for tractability — "just to match the data" reads like a modeling\-convenience justification, similar to how demand papers treat BLP's ξ as an exogenous nuisance parameter recovered residually rather than something with a structural law of motion.

The two stage\-model write\-up below goes with Reading A because it's the version that's actually solvable and matches the rest of the note ("write down a model" §2 explicitly separates "investment in cost or investment in ξ" as a choice, implying ξ is not the investment target by default). Worth a two\-line confirmation either way.

**"Max of 5 firms... everybody can exit... only one potential entrant... solve Bellman and best response... Pakes and McGuire solve this all... focus updating of value function on states that firms go to."**

This is off\-the\-shelf Ericson–Pakes (1995) / Pakes–McGuire (1994): a symmetric Markov Perfect Equilibrium computed by iterating between a value function and a policy (investment/exit/entry) function until both converge, with the industry capped at a maximum number of active incumbents plus a single potential entrant per period (so entry is a scalar 0/1 decision each period, not a queue). "Focus updating of value function on states that firms go to" is specifically Pakes–McGuire (2001)'s adaptive algorithm: instead of solving the value function on the *entire* state space (which is what makes the naive EP95 algorithm intractable as the number of state variables grows), simulate play, and only refine the value function at states that actually get visited along simulated paths. That algorithm is *itself* a response to the curse of dimensionality — and per your conversation with Pakes, apparently not enough of one here, hence EBE (§4).

**"Cost of nicotine per unit — maybe JUUL invested in cost of nicotine. Does nicotine decrease when the FDA makes changes?... put nicotine in as a cost... N\_hom or mg/mL... do not do by sales\-weight, maybe by product offering set (\# UPCs)."**

Two distinct ideas here, worth keeping separate:

1. A *substantive* hypothesis: nicotine\-delivery technology is the thing firms invest in (salts vs. freebase, pod engineering), and regulatory shocks (2016 deeming rule, the 2019–20 flavor/cartridge enforcement) act as **cost shifters** on nicotine delivery — i.e., regulation doesn't just change legality/demand, it raises the marginal cost of delivering a given nicotine concentration. This is testable directly (§7.3).
2. A *measurement* instruction: when you construct a firm\-level nicotine/quality variable for the supply model, don't build it the way the demand\-side notes build the market\-level object — the summary\-stats note's `N_hom` is deliberately **mL\-sales\-weighted** (`§1` of that note: "both averages taken under mL sales weights"). That's correct for a demand\-side regressor, but wrong for a *supply\-side state variable*, because sales weighting bakes in the current period's realized demand — exactly the endogenous outcome the supply model is trying to explain. Marc's suggestion is to instead weight by the firm's product\-offering set (number of active UPCs), which is a predetermined stock decision, not a contemporaneous sales outcome. Concretely: for firm i in month t, average nicotine content (or mg/mL) across i's active UPCs, unweighted or UPC\-count\-weighted, not mL\-weighted.

**"Write down a model... investment in cost or ξ... is it draws?... ignore product type... 5 firms × 1 endogenous quality measure × 1 ξ measure... Benkard... Ericson\-Pakes does continuous investment → Probability(draw) → 0/1 binary investment."**

This is the state\-space spec for the full model: each of up to 5 active firms carries a two\-dimensional state (one endogenous quality/cost state, one exogenous ξ), "ignore product type" means treat each firm as selling a single representative product (consistent with how the demand notes already collapse pod/disposable/open\-refill into one `P_hom`/`N_hom` object — good, the two papers stay measurement\-compatible even though the estimated *models* are disconnected). "Ericson\-Pakes does continuous investment → Probability(draw) → 0/1 binary investment" is describing the classic EP95 investment technology precisely: the firm chooses a continuous dollar amount x\_i, which maps through an investment\-effectiveness function into the *probability* that a discrete, binary innovation occurs (state moves up one rung) next period — investment buys better odds, not a guaranteed or continuous outcome.

**"For upcoming internal conference: cost and quality exogenous, static price, endogenous quantity. Firms pick entry, exit, price — dynamic. Cap in market."**

This is the two\-stage plan made explicit: a near\-term, tractable version (no investment channel at all — cost and quality states move exogenously) for the conference, and the full investment model as the eventual target. Sections 4–5 write both down.

## 2\.5 What the Aug 8 meeting adds

A second set of notes (the Aug 8 meeting, which predates the Aug 10 notes decoded above) fills in the demand block for the pricing subgame and settles the investment\-technology question:

**Demand.** "Nested logit: ecigarette in one branch, outside option in another branch... mean utility \= quality (integer)... construct the state space from mean utility." This is firm\-level demand, not the market\-level `P_hom`/`N_hom` aggregate — each active firm's product sits inside the e\-cigarette nest (competing against the other active firms' products and against the outside\-option nest), and firm i's mean utility is tied directly to its own state a\_i,t, which is itself constructed by discretizing a continuous mean\-utility index recovered from the data into an integer grid — the standard way to turn a demand\-side quality index into an Ericson–Pakes\-style discrete state. That resolves the firm\-level\-vs\-market\-level open question from §6 in the direction you'd already landed on: `P_hom`/`N_hom` were summary\-stats objects for the demand paper, not a instruction to use market\-level demand here.

**Investment is binary, not continuous.** "Each firm makes a choice to invest or not. When you enter, pay a fixed cost. If you invest, this is a forward\-looking decision." This is a real content update relative to the Aug 10 "Ericson–Pakes does continuous investment → Probability(draw)" bullet: rather than a continuous dollar choice x\_i mapped through a probability\-of\-success function, the investment decision itself is discrete — invest (d\_i,t \= 1) or don't (d\_i,t \= 0) — with, presumably, a fixed cost paid conditional on investing and a probability of success conditional on having invested. §5 below is updated to this specification.

**A worked example, and it matches the data you already have.** "Suppose BLU did not invest, and others did. Mistic was a potential entrant in 2013. In period 2, 21st Century Smoke exited... if I invest, they know if other firms invest, I'll leave." This is the strategic mechanism the Bellman equation in §5 is built to capture: firm i's continuation value depends on the *joint* distribution of rivals' states, because rivals' own optimal investment and exit decisions respond to what i does (and, in equilibrium, i's decision responds to correctly anticipating theirs). It's also a nice sanity check against the brand\-dynamics note's own entry/exit table: MISTIC does enter and rise to the overall market lead by 2015–2017 (open\-refill/bottled\-juice niche), and 21st Century Smoke does exit the top ranks by \~2015 — the example tracks the actual 2013–2015 turnover documented there.

## 3\. Why the state space is a problem, and what EBE buys you

With N̄ \= 5 potential active firms and a 2\-dimensional state per firm (a\_i, ξ\_i), the industry state is a point in a space with up to 10 dimensions (5 × 2), and a firm's best response in a standard Markov Perfect Equilibrium must be optimal against the *entire* vector of rivals' states — not just an average or a rank. Pakes–McGuire (2001)'s recurrent\-states trick shrinks the region over which you compute the value function, but it doesn't shrink the *dimension* of what a firm has to condition on to form a best response, and simulating enough paths to nail down a 10\-dimensional recurrent set well is exactly where this stops being fast, per your conversation with Pakes.

Fershtman & Pakes (2012) 's Experience\-Based Equilibrium relaxes the equilibrium concept along two margins simultaneously: (i) firms' value functions and policies only have to be *correct on states reached with positive probability along the equilibrium path* (the "experienced" states), not everywhere a full MPE requires consistency; and (ii) firms are not required to track or best\-respond to every rival's exact state — they can condition on their own state plus a coarser summary of the industry (their own history of interactions, or an aggregate/type\-level description of rivals) rather than the full state vector, which is the piece that actually attacks the dimensionality problem rather than just the region\-of\-computation problem. That combination is why it's the natural next step after "Pakes–McGuire already does the recurrent\-states trick and it's still too slow" — worth re\-reading the paper's formal definition before committing to a specific implementation, since there's more than one way to define "coarser summary of rivals" and the choice matters for what you can identify.

## 4\. Stage 1 — conference version: exogenous state, static pricing, dynamic entry/exit

**Timing, each period t.** (i) Nature draws each active incumbent's (a\_i,t, ξ\_i,t) and, if there is a potential entrant this period, its (a\_e,t, ξ\_e,t), from the exogenous Markov processes below — ξ is firm\-and\-time indexed, ξ\_i,t, per §6. (ii) Given the current set of active firms and their states, firms play a static Bertrand\-Nash pricing game in a firm\-level nested logit: each active firm's product sits in an "e\-cigarette" nest (nest parameter σ) against a single outside\-option nest, and firm i's mean utility is δ\_i,t \= a\_i,t − α·p\_i,t (state enters mean utility directly, as an integer quality index; price enters the usual way). (iii) Static\-stage profits realize. (iv) Each active incumbent decides continue vs. exit; the single potential entrant decides enter vs. stay out, paying a fixed entry cost if it enters. (v) States evolve exogenously into t\+1 for continuing/entering firms.

**States and law of motion (exogenous).** Firm i's state ω\_i,t \= (a\_i,t, ξ\_i,t). Both evolve as first\-order Markov processes estimated directly off the data — no firm decision affects them in this stage:

```
a_i,t+1 ~ F_a( · | a_i,t )        [accumulated-quality/cost proxy — e.g., firm's UPC-weighted N_hom or mg/mL trajectory, discretized]
ξ_i,t+1 ~ F_ξ( · | ξ_i,t )        [firm-specific residual quality/cost shock]
```

**Static pricing subgame.** Given ω\_t \= (ω\_1,t, ..., ω\_n,t) for the n ≤ 5 active firms, each firm sets price p\_i,t to maximize static profit

```
π_i(ω_t) = max_{p_i}  ( p_i − c(ω_i,t) ) · q_i(p_t, ω_t)  −  F
```

where q\_i is firm i's nested\-logit share of the market (a function of the full price vector and the state vector through mean utility δ\_i,t \= a\_i,t − α·p\_i,t), c(ω\_i,t) is marginal cost as a function of the firm's own state (this is where "nicotine cost" and/or accumulated\-experience cost reduction enters — see §6 on the still\-open functional form), and F is a fixed per\-period operating cost. This is a standard static Bertrand\-Nash equilibrium in prices, solved period\-by\-period given ω\_t — no dynamic programming needed for this stage.

**Dynamic entry/exit.** Let π\_i\*(ω\_t) denote the equilibrium static profit from the pricing subgame. An incumbent's value function:

```
V_i(ω_i,t, ω_-i,t) = π_i*(ω_t) + max{ φ_i ,                                          [exit: take scrap value φ_i]
                                       β · E[ V_i(ω_i,t+1, ω_-i,t+1) | ω_t, continue ] }   [continue]
```

and the potential entrant compares its expected discounted value of entering, net of a sunk entry cost κ\_e, against staying out (value 0). Equilibrium is a fixed point in exit/entry cutoff rules (functions of ω\_t) and the value function, computed via the standard Pakes–McGuire iteration — because there's no investment choice, this fixed point is considerably cheaper to compute than the full model: no probability\-of\-innovation function to solve for, and the exogenous state processes can be estimated off the data first and then plugged in, rather than solved jointly.

**What Stage 1 needs, minimally:** (a) the firm\-level nested\-logit demand system — the mean\-utility\-to\-state mapping and the nest parameter σ; (b) the two exogenous Markov transition kernels F\_a, F\_ξ estimated from firm\-level state series; (c) the marginal\-cost function c(·); (d) enough entry/exit events in the data to identify the scrap\-value and entry\-cost distributions (or at least bound them / calibrate to match observed entry/exit hazard rates — §7.2).

## 5\. Stage 2 — full model: endogenous investment, EBE

Same market, timing, and demand/pricing block as Stage 1, but a\_i,t is now endogenous, and the investment technology is the **binary** version confirmed at the Aug 8 meeting (§2.5), not the continuous\-dollar version originally sketched. Before the static pricing subgame each period, each active firm chooses d\_i,t ∈ {0, 1} — invest or don't — paying a fixed investment cost κ\_inv if d\_i,t \= 1. Conditional on investing, the firm succeeds (moves up one quality rung) with probability ρ; conditional on not investing, the state can depreciate with probability φ, which is the "forget" half of "learn and forget":

```
a_i,t+1 = a_i,t + 1{success}·d_i,t − 1{forget}·(1 − d_i,t)
Pr(success | d_i,t = 1) = ρ            Pr(forget | d_i,t = 0) = φ
```

(ρ and φ could each be made state\-dependent, e.g. ρ(a\_i,t), if the data support it — start with scalars.) ξ\_i,t continues to evolve exogenously as in Stage 1, firm\-and\-time\-indexed. The incumbent's Bellman equation now has a discrete investment choice nested inside it:

```
V_i(ω_i,t, ω_-i,t) = π_i*(ω_t) − κ_inv · d_i,t
                       + max{ φ_i ,
                               β · Σ_{a_i,t+1} Pr(a_i,t+1 | d_i,t) · E[ V_i(ω_i,t+1, ω_-i,t+1) | ξ transitions, ω_-i evolution ] }
```

solved for the optimal d\_i,t ∈ {0,1} jointly with the exit cutoff (a discrete choice between two continuation branches, rather than a first\-order condition over a continuous x\_i — mechanically simpler than the EP95 continuous\-investment version), and the entrant's problem gains an analogous invest\-into\-the\-market\-with\-an\-initial\-state decision.

**Why this is still a curse\-of\-dimensionality problem, and what EBE buys you.** Binary investment doesn't shrink the state space — it's still up to 5 firms × (a\_i, ξ\_i), i.e. up to 10 dimensions — it only simplifies each firm's *within\-period* optimization from a continuous first\-order condition to a two\-way comparison. The dimensionality problem EBE is solving is about what a firm has to condition on to form its continuation value, not how it chooses investment. Concretely, EBE implementation means two departures from a textbook Pakes–McGuire solve: (i) the value function and policy functions (invest, exit) are only pinned down and iterated on states that actually recur along simulated equilibrium play, rather than a pre\-specified grid over the full state space (already present in Pakes–McGuire 2001, and EBE inherits it); (ii) firms condition on their *own* state plus a lower\-dimensional description of rivals — e.g., the current market leader's state, the number of active rivals, and/or a moment of the rival\-state distribution — rather than the full (ω\_1,...,ω\_5) vector, with equilibrium beliefs only required to be correct for states reached with positive probability. Which summary statistic to use for "rivals" is a modeling choice that should track something empirically visible in the data (§7.6, deferred for now, was aimed at this).

**The Aug 8 worked example, formally.** "If I invest, they know if other firms invest, I'll leave" is exactly a statement about off\-diagonal terms in this value function: firm i's exit decision (the max{φ\_i, ...} branch) depends on ω\_\-i,t, and specifically on whether rivals invested. In the 2013–2015 episode Marc used as the example, that's consistent with BLU not investing while rivals (MISTIC entering, others upgrading) did, and 21st Century Smoke exiting on the resulting trajectory — the kind of transition path an EBE solve would need to have in its recurrent set.

## 6\. Open choices — status

**Resolved.**

- **ξ interpretation:** Reading A (§2) — ξ\_i,t is a firm\-and\-time\-indexed exogenous state, separate from the endogenous accumulated\-quality state a\_i,t, evolving via its own Markov process estimated to match the data. Not itself a target of investment.
- **Firm\-level vs. market\-level demand for the pricing subgame:** firm\-level nested logit, confirmed by the Aug 8 meeting notes (§2.5) — `P_hom`/`N_hom` were demand\-paper summary\-stat constructs only, not a market\-level\-demand instruction for this model. Mean utility for firm i is tied directly to its integer state a\_i,t.
- **Investment technology:** binary invest/don't\-invest (d\_i,t ∈ {0,1}) with a fixed investment cost and a success probability, not EP95's continuous\-dollar/probability\-function version (§2.5, §5).

**Still open.**

- **What "cost of nicotine" is a cost *of*, functionally.** Not needed for Stage 1 (cost is exogenous there — whatever functional relationship exists between nicotine content and marginal cost is absorbed into the estimated F\_a/marginal\-cost mapping, not specified structurally). Becomes load\-bearing only in Stage 2, once investment is supposed to be lowering *something specific*. Two candidate specifications, and the choice should be made from evidence, not asserted: (a) a smooth cost that scales in the unit's nicotine content, c\_i,t \= c\_0 \+ γ·N\_i,t — appropriate if compliance/reformulation cost rises continuously with how much nicotine a product delivers; (b) a threshold/step cost tied to regulatory *category* rather than nicotine *level*, c\_i,t \= c\_0 \+ γ\_t·1{exposed formulation}, which is arguably the better fit to what the regulatory timeline in the brand\-dynamics note actually describes — the Feb 2020 enforcement targeted flavored prefilled cartridge/pod ENDS specifically (a product\-form category), not a nicotine\-content threshold per se, and open\-system/disposables were exempt regardless of their nicotine level. §7.3 (deferred — see §7) is the direct test: does firm\-level nicotine content move at the regulatory event dates, and does the move look like it scales with nicotine level (supports (a)) or jump discretely by product\-form exposure (supports (b))? Deferred along with 7.3 itself, per your call not to need this for the conference version.
- **Product\-offering\-set weighting details.** Unweighted average across a firm's active UPCs, or weighted by UPC count some other way? §7.5 (below) is designed to check whether this choice actually moves the resulting firm\-level nicotine series enough to matter.

## 6\.5 Frequency

Weekly RMS data exists but is likely too noisy for state transitions that are naturally lower\-frequency (a firm doesn't really re\-decide entry/exit/investment week to week). Monthly is the right default here — it's also what both `08_05_2026` notes already use for `P_hom`/`N_hom`/nicotine construction, so the supply\-side diagnostics below stay on the same calendar grid as the demand\-side series without extra reconciliation work. Worth revisiting only if a specific diagnostic (e.g., dating an entry/exit event more precisely, §7.2) turns out to need finer resolution than a monthly bucket gives.

## 7\. Statistics to produce before locking the model down

These are aimed at turning §6's open choices into decisions, using the same Nielsen RMS panel underlying both notes, at monthly frequency (§6.5). A few are already partly answered by the two `08_05_2026` notes — flagged below — the rest are new cuts of the same data. 7.1, 7.2, 7.4, and 7.5 are queued up as a standalone data\-request prompt (given separately) since they don't depend on resolving anything still open; 7.3 and 7.6 are deferred (see each item).

**7\.1 — How many firms really compete, and does the cap bind?**
Monthly count of brands with any positive tracked mL, and separately with share above a materiality threshold (say 1% and 5%). The brand\-composition figure in the dynamics note already shows the top\-5\-plus\-"Other" split by year; the ask here is the same cut at monthly frequency, to see how often more than 5 brands simultaneously clear a 1% threshold, and how stable the "Other" bucket's aggregate share is. This is the direct evidence for whether N̄ \= 5 is a genuine cap or just a convenient top\-5 display choice, and whether "Other" should be modeled as a competitive fringe sitting outside the dynamic game entirely.

**7\.2 — Entry/exit hazard rates and the one\-entrant\-per\-period assumption.**
For the full (not just top\-5) brand list: how many genuinely new brand\-codes appear per month, market\-wide (not just into the top ranks) — this tests "only one potential entrant." Separately, among brands that ever reach the top\-5, the distribution of tenure (months held) and of "age at exit," to calibrate/bound scrap values and entry costs, and to check whether exit looks more like a sharp state\-dependent cutoff (consistent with the model) or is dominated by corporate events (divestiture, discontinuation) that look more like exogenous ownership shocks than an endogenous exit decision — the dynamics note's own brand table (BLU divested 2015, MarkTen discontinued 2018, MISTIC wound down \~2020) suggests the latter may be common here.

**7\.3 — Does firm\-level nicotine content respond to FDA events? *(deferred — not needed for the Stage 1 conference model; revisit for Stage 2)***
Cost and quality are exogenous inputs in Stage 1, so nothing about *why* nicotine content moves is load\-bearing yet — you only need the observed series, not a mechanism. This becomes necessary once Stage 2 needs a specific cost functional form (§6). When you get there: an event\-study, firm\-by\-firm (not the pooled `N_hom`/`nic_mg_per_mL` series already in the notes), around the dated regulatory events in the dynamics note's timeline, checking both whether nicotine moves at those dates and whether the move scales with nicotine level (smooth cost story) or jumps by product\-form exposure (threshold/category cost story) — see §6 for the two candidate cost specifications this is meant to distinguish.

**7\.4 — Is there a learning\-by\-doing cost signature? (tests the Benkard channel)**
Regress firm\-level price or price/mL on firm cumulative units/mL sold to date, with period fixed effects, to look for the classic learning\-curve signature (price/cost falling in cumulative own output, holding the market\-wide period effect fixed) independent of the nicotine\-regulation story in 7.3. If this shows up cleanly for some firms and not others, that's informative about which firms the "accumulated experience decreases cost" mechanism actually describes.

**7\.5 — Product\-offering\-set (UPC count) dynamics.**
Firm\-level active\-UPC count over time, and whether UPC\-count growth *leads* share/leadership gains (consistent with "investment" as product\-line expansion preceding demand payoff) or moves contemporaneously/lags (consistent with UPC count being a response to already\-realized demand rather than a state variable). Also a direct check of whether the §2 measurement choice (UPC\-weighted nicotine vs. mL\-sales\-weighted) actually produces a materially different firm\-level nicotine series — if it doesn't matter much in practice, that simplifies the write\-up.

**7\.6 — Ownership/distribution vs. own\-quality trajectory as the driver of turnover. *(deferred)***
Punted for now. Flagged here only so it isn't lost: the dynamics note's own read of the data is that brand leadership turnover looks largely like a corporate\-ownership/distribution story rather than a standalone\-product\-quality story, which — if right — bears on whether the accumulated\-quality state this model is built around is the dominant force generating entry/exit/leadership in e\-cigarettes specifically. Worth returning to once the Stage 1 model is running.
