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

## 3\. Why the state space is a problem, and what EBE buys you

With N̄ \= 5 potential active firms and a 2\-dimensional state per firm (a\_i, ξ\_i), the industry state is a point in a space with up to 10 dimensions (5 × 2), and a firm's best response in a standard Markov Perfect Equilibrium must be optimal against the *entire* vector of rivals' states — not just an average or a rank. Pakes–McGuire (2001)'s recurrent\-states trick shrinks the region over which you compute the value function, but it doesn't shrink the *dimension* of what a firm has to condition on to form a best response, and simulating enough paths to nail down a 10\-dimensional recurrent set well is exactly where this stops being fast, per your conversation with Pakes.

Fershtman & Pakes (2012) 's Experience\-Based Equilibrium relaxes the equilibrium concept along two margins simultaneously: (i) firms' value functions and policies only have to be *correct on states reached with positive probability along the equilibrium path* (the "experienced" states), not everywhere a full MPE requires consistency; and (ii) firms are not required to track or best\-respond to every rival's exact state — they can condition on their own state plus a coarser summary of the industry (their own history of interactions, or an aggregate/type\-level description of rivals) rather than the full state vector, which is the piece that actually attacks the dimensionality problem rather than just the region\-of\-computation problem. That combination is why it's the natural next step after "Pakes–McGuire already does the recurrent\-states trick and it's still too slow" — worth re\-reading the paper's formal definition before committing to a specific implementation, since there's more than one way to define "coarser summary of rivals" and the choice matters for what you can identify.

## 4\. Stage 1 — conference version: exogenous state, static pricing, dynamic entry/exit

**Timing, each period t.** (i) Nature draws each active incumbent's (a\_i,t, ξ\_i,t) and, if there is a potential entrant this period, its (a\_e,t, ξ\_e,t), from the exogenous Markov processes below. (ii) Given the current set of active firms and their states, firms play a static Bertrand\-Nash pricing game; demand comes from the representative\-good nested logit already used on the demand side (products \= {representative cigarette, representative e\-cigarette, not smoking}, or a firm\-differentiated version of it if the pricing subgame needs firm\-level shares rather than the market\-level `P_hom`/`N_hom` aggregate — this is a design choice, see §6). (iii) Static\-stage profits realize. (iv) Each active incumbent decides continue vs. exit; the single potential entrant decides enter vs. stay out, paying a sunk entry cost if it enters. (v) States evolve exogenously into t\+1 for continuing/entering firms.

**States and law of motion (exogenous).** Firm i's state ω\_i,t \= (a\_i,t, ξ\_i,t). Both evolve as first\-order Markov processes estimated directly off the data — no firm decision affects them in this stage:

```
a_i,t+1 ~ F_a( · | a_i,t )        [accumulated-quality/cost proxy — e.g., firm's UPC-weighted N_hom or mg/mL trajectory]
ξ_i,t+1 ~ F_ξ( · | ξ_i,t )        [residual quality/cost shock]
```

**Static pricing subgame.** Given ω\_t \= (ω\_1,t, ..., ω\_n,t) for the n ≤ 5 active firms, each firm sets price p\_i,t to maximize static profit

```
π_i(ω_t) = max_{p_i}  ( p_i − c(ω_i,t) ) · q_i(p_t, ω_t)  −  F
```

where q\_i is the demand\-system share/quantity for firm i given the full price vector and state vector, c(ω\_i,t) is marginal cost as a function of the firm's own state (this is where "nicotine cost" and/or accumulated\-experience cost reduction enters), and F is a fixed per\-period operating cost. This is a standard static Bertrand\-Nash equilibrium in prices, solved period\-by\-period given ω\_t — no dynamic programming needed for this stage.

**Dynamic entry/exit.** Let π\_i\*(ω\_t) denote the equilibrium static profit from the pricing subgame. An incumbent's value function:

```
V_i(ω_i,t, ω_-i,t) = π_i*(ω_t) + max{ φ_i ,                                          [exit: take scrap value φ_i]
                                       β · E[ V_i(ω_i,t+1, ω_-i,t+1) | ω_t, continue ] }   [continue]
```

and the potential entrant compares its expected discounted value of entering, net of a sunk entry cost κ\_e, against staying out (value 0). Equilibrium is a fixed point in exit/entry cutoff rules (functions of ω\_t) and the value function, computed via the standard Pakes–McGuire iteration — because there's no investment choice, this fixed point is considerably cheaper to compute than the full model: no probability\-of\-innovation function to solve for, and the exogenous state processes can be estimated off the data first and then plugged in, rather than solved jointly.

**What Stage 1 needs, minimally:** (a) the two exogenous Markov transition kernels F\_a, F\_ξ estimated from firm\-level state series; (b) the static demand system and marginal\-cost function c(·); (c) enough entry/exit events in the data to identify the scrap\-value and entry\-cost distributions (or at least bound them / calibrate to match observed entry/exit hazard rates — §7.2).

## 5\. Stage 2 — full model: endogenous investment, EBE

Same market, timing, and demand/pricing block as Stage 1, but a\_i,t is now endogenous. Before the static pricing subgame each period, active firms simultaneously choose investment x\_i,t ≥ 0 (dollars). Following the Ericson–Pakes / Pakes–McGuire investment technology Marc's notes point to: investment maps through an effectiveness function ν(x\_i) into the *probability* of a discrete, binary "innovation" (one\-rung improvement in a\_i):

```
a_i,t+1 = a_i,t + 1{success}  ,     Pr(success | x_i,t) = ν(x_i,t)  ,   ν increasing, concave, ν(0) = 0
```

ξ\_i,t continues to evolve exogenously as in Stage 1 (subject to resolving the Reading\-A/B ambiguity in §2). The incumbent's Bellman equation now has an investment choice nested inside it:

```
V_i(ω_i,t, ω_-i,t) = π_i*(ω_t) − x_i,t
                       + max{ φ_i ,
                               β · Σ_{a_i,t+1} Pr(a_i,t+1 | x_i,t) · E[ V_i(ω_i,t+1, ω_-i,t+1) | ξ transitions, ω_-i evolution ] }
```

solved for the optimal x\_i,t jointly with the exit cutoff, and the entrant's problem gains an analogous investment\-into\-the\-market\-with\-an\-initial\-state decision.

**EBE implementation, concretely, means two departures from a textbook Pakes–McGuire solve:** (i) the value function and policy functions (investment, exit) are only pinned down and iterated on states that actually recur along simulated equilibrium play, rather than a pre\-specified grid over the full 10\-dimensional space (this part is already present in Pakes–McGuire 2001, and EBE inherits it); (ii) firms condition on their *own* state plus a lower\-dimensional description of rivals — e.g., the current market leader's state, the number of active rivals, and/or a moment of the rival\-state distribution — rather than the full (ω\_1,...,ω\_5) vector, with equilibrium beliefs only required to be correct for states reached with positive probability. Which summary statistic to use for "rivals" is a modeling choice that should track something empirically visible in the data (§7 below is partly aimed at figuring out what that should be — e.g., if leadership turnover tracks *ownership/distribution* rather than *own quality trajectory* per the brand\-dynamics note, the right rival\-summary may be "which rival is Big\-Tobacco\-owned," not a moment of the quality distribution).

## 6\. Open choices to confirm before this is final

- **ξ interpretation (Reading A vs. B, §2).** Two\-minute question for Marc.
- **Firm\-level vs. market\-level demand for the pricing subgame.** The demand paper's `P_hom`/`N_hom` are market\-level, mL\-weighted aggregates across whichever brands are active — useful for the *demand* estimation but not directly a firm\-differentiated demand system. Stage 1's static pricing subgame needs firm\-level shares (a firm\-differentiated nested logit, or some other discrete\-choice structure over the ≤5 active brands \+ outside good). Since the paper is explicitly not reusing demand\-side estimates, this likely means re\-specifying (not re\-estimating) a firm\-level demand block for the supply paper — worth deciding early since it constrains what marginal\-cost function is identified from the pricing FOCs.
- **What "cost of nicotine" is a cost *of*.** Cost per mg of nicotine delivered, cost per mL of e\-liquid, or cost per unit sold? The regulatory\-cost story (deeming rule, cartridge enforcement) most naturally hits cost\-per\-mg\-of\-a\-given\-formulation (compliance, testing, reformulation costs), which is different from a scale/experience cost that falls with cumulative units produced (Benkard channel). These could both be operative but enter the cost function differently, and distinguishing them is exactly what §7.3–7.4 are for.
- **Is ξ firm\-idiosyncratic or a common/aggregate regulatory shock?** FDA actions hit (nearly) every firm's nicotine\-delivery cost at the same calendar date. A firm\-specific Markov ξ\_i is the EP95\-standard specification, but if the real driver is a common regulatory state s\_t (with heterogeneous *exposure* by firm — e.g., salt\-nicotine pods hit harder than cigalikes), that's a meaningfully different — and probably better\-identified — object. §7.3 is designed to distinguish these.
- **Product\-offering\-set weighting details (§2).** Unweighted average across a firm's active UPCs, or weighted by UPC count in some other way? Worth trying both and checking whether it matters for the resulting state series.

## 7\. Statistics to produce before locking the model down

These are aimed at turning §6's open choices into decisions, using the same Nielsen RMS panel underlying both notes. A few are already partly answered by the two `08_05_2026` notes — flagged below — the rest are new cuts of the same data.

**7\.1 — How many firms really compete, and does the cap bind?**
Monthly count of brands with any positive tracked mL, and separately with share above a materiality threshold (say 1% and 5%). The brand\-composition figure in the dynamics note already shows the top\-5\-plus\-"Other" split by year; the ask here is the same cut at monthly frequency, to see how often more than 5 brands simultaneously clear a 1% threshold, and how stable the "Other" bucket's aggregate share is. This is the direct evidence for whether N̄ \= 5 is a genuine cap or just a convenient top\-5 display choice, and whether "Other" should be modeled as a competitive fringe sitting outside the dynamic game entirely.

**7\.2 — Entry/exit hazard rates and the one\-entrant\-per\-period assumption.**
For the full (not just top\-5) brand list: how many genuinely new brand\-codes appear per month, market\-wide (not just into the top ranks) — this tests "only one potential entrant." Separately, among brands that ever reach the top\-5, the distribution of tenure (months held) and of "age at exit," to calibrate/bound scrap values and entry costs, and to check whether exit looks more like a sharp state\-dependent cutoff (consistent with the model) or is dominated by corporate events (divestiture, discontinuation) that look more like exogenous ownership shocks than an endogenous exit decision — the dynamics note's own brand table (BLU divested 2015, MarkTen discontinued 2018, MISTIC wound down \~2020) suggests the latter may be common here, which matters for how much of "exit" the model should even try to endogenize versus treat as an exogenous ownership\-change process.

**7\.3 — Does firm\-level nicotine content respond to FDA events? (tests the "nicotine as regulatory cost" story)**
An event\-study, firm\-by\-firm (not the pooled `N_hom`/`nic_mg_per_mL` series already in the notes), around the four dated events in the dynamics note's timeline (Jan/Feb 2020 enforcement, Sep 2020 PMTA deadline, and the earlier 2016 deeming rule / nicotine\-salts regulatory changes Marc's note references): does mg/mL or N\_hom, computed per\-firm on the product\-offering\-set weighting from §2, actually move at those dates, and does the move look common\-across\-firms (supporting a shared regulatory state s\_t) or firm/product\-type\-specific (supporting firm\-idiosyncratic ξ\_i, with salt\-pod firms differentially exposed vs. cigalike/disposable firms)? This is the direct test of the "put nicotine in as a cost" hypothesis and of the ξ\-idiosyncratic\-vs\-common question in §6.

**7\.4 — Is there a learning\-by\-doing cost signature? (tests the Benkard channel)**
Regress firm\-level price or price/mL on firm cumulative units/mL sold to date, with period fixed effects, to look for the classic learning\-curve signature (price/cost falling in cumulative own output, holding the market\-wide period effect fixed) independent of the nicotine\-regulation story in 7.3. If this shows up cleanly for some firms and not others, that's informative about which firms the "accumulated experience decreases cost" mechanism actually describes.

**7\.5 — Product\-offering\-set (UPC count) dynamics.**
Firm\-level active\-UPC count over time, and whether UPC\-count growth *leads* share/leadership gains (consistent with "investment" as product\-line expansion preceding demand payoff) or moves contemporaneously/lags (consistent with UPC count being a response to already\-realized demand rather than a state variable). Also a direct check of whether the §2 measurement choice (UPC\-weighted nicotine vs. mL\-sales\-weighted) actually produces a materially different firm\-level nicotine series — if it doesn't matter much in practice, that simplifies the write\-up.

**7\.6 — Ownership/distribution vs. own\-quality trajectory as the driver of turnover.**
This one is worth flagging even though it's not explicitly in Marc's notes: the dynamics note's own read of the data (p.4) is that brand leadership turnover is "largely a story of corporate ownership and distribution... not of standalone product quality," and specifically attributes VUSE's win over NJOY mostly to BAT's distribution scale rather than product differences. If that's right, a model where the state driving entry/exit/leadership is *own accumulated quality/cost* (the Ericson–Pakes/Benkard mechanism this whole note is building) may be missing the dominant force in this particular industry. Worth a direct check: does a firm's jump in share around an ownership\-change event (Reynolds→BAT 2017, Altria stake in JUUL Dec 2018, Altria→NJOY 2023) look larger than what its own nicotine/cost/UPC trajectory would predict? If ownership events dominate, the model in §5 may want a distribution\-access or parent\-capital state variable (possibly a simple indicator: "Big\-Tobacco\-owned or not," which is close to the rival\-summary\-statistic EBE already wants in §5) alongside or instead of a pure own\-quality state — worth raising with Marc and Pakes directly, since it bears on whether the mechanism this model is built around is the right one for e\-cigarettes specifically, as opposed to a setting like semiconductors or aircraft where it was originally used.
