# Handoff: online discussion of Collard-Wexler's published paper

Prepared November 11, 2026 for Erin. Purpose: understand entry/exit modeling before returning to the existing Codex implementation. Discuss and decide first; do not silently treat alternatives as adopted specifications.

## Upload checklist

Paths are relative to the repository root. Upload these four files:

1. **This handoff.**
2. **Published paper:** `smoke_firm_dir/literature/Econometrica - 2013 - Collard‐Wexler - Demand Fluctuations in the Ready‐Mix Concrete Industry.pdf` — Econometrica 81(3), May 2013, 1003–1037, DOI 10.3982/ECTA6877. Use this published copy rather than an earlier job-market draft. The other similarly titled local PDF is a duplicate downloaded from the author's site; no need to upload both.
3. **Advisor discussion:** `smoke_firm_dir/docs/meetings/marc_mtg_2026-11-10_transcription_notes.md` — structured notes, not a verbatim transcript. Distinguishes recommendations from settled decisions.
4. **Current model:** `smoke_firm_dir/docs/meetings/marc_mtg_2026-11-10_presentation.md` — latest user-edited source, more authoritative than an older generated PDF. Its appendix G explains cost/demand inversion. Alternatively upload its matching PDF for easier visual reading, but avoid unnecessary duplicates.

Optional, only if needed: `smoke_firm_dir/docs/ec_supply_conference_model.pdf` for original model intentions. It predates later changes; the presentation describes the implemented baseline. The 38-page full meeting log and solution appendix are not needed initially. No scanner data, code, or RDS files are needed for this discussion.

## Prompt to begin the online session

I am Erin, an economics PhD student modeling the e-cigarette industry. Please read the attached published Collard-Wexler paper and my model/advisor notes. Help me dissect its economic setup, especially incumbents, potential entrants, exit, waiting, the firm cap, and whether inactive positions represent persistent firms or new candidates. Explain one issue at a time with page/equation/footnote references. Separate what the paper explicitly states, your interpretation, and adaptations you propose for my model. Do not assume the paper's setup is identical to either my current model or my advisor's one-period-entrant example. Do not start coding or select new assumptions on my behalf. Start with how potential entrants are defined and counted.

## My priorities and confirmed choices

1. Clarify/revise entry, exit, roster, and fringe treatment.
2. Inspect value functions and responses to exogenous inputs.
3. Refine estimation and broaden state support.

Endogenous nicotine and FDA-counterfactual work are deferred until after these steps, although Marc emphasized their importance. Annual discount factor remains **0.95**, converted to monthly `0.95^(1/12)` ≈ 0.995735. Do not change to 0.95 monthly. This is discounting, not depreciation. Later user decisions override stale unresolved items in the transcription notes.

## Implemented baseline: enough context for the paper discussion

- National monthly nested-logit demand; volume-weighted price/tax, nicotine control, no firm/month FE. Price and within-nest log share instrumented with sales-weighted tax and annual incumbent count. Alpha ≈ −0.334, sigma ≈ 0.869, nicotine slope ≈ 0.110. Demand remains provisional; instrument exclusion and negative conditional tax–price relationship are unresolved.
- Demand's annual >7% incumbent classification is separate from the supply roster.
- Five fixed focal brands: BLU, MISTIC, NJOY, JUUL, VUSE. BLU/MISTIC/NJOY active January 2013; JUUL/VUSE eligible from then, initially never entered. All other brands, including LOGIC, remain passive fringe.
- A focal brand remains individually modeled even when small. No fringe promotion, no new identities replacing exited brands, and no reentry after shutdown. This is not the current top-five roster.
- Static simultaneous Bertrand prices solved manually. Current operating profit = `(p−mc) M s − FC`. Retail brand is treated as integrated single-product pricing firm; current prices do not change future states.
- Brand-specific constant MC = historical incumbent-period median. MC: BLU 7.653, MISTIC 1.017, NJOY 3.320, JUUL 6.887, VUSE 3.293 real dollars/mL. Historical MC varies, with some additional MISTIC inversions negative.
- Passive fringe total mean utility (price/characteristics/unobserved quality bundled together) fixed at January 2013 value ≈ −7.371. No fringe pricing FOC or separate fringe-firm value function. Share still responds to focal prices/qualities. January 2013 market size is also fixed in completed solves.
- Exogenous nicotine and xi: three pooled quantile bins each, within-bin medians. Two pooled 3×3 transition matrices; independent between processes and across brands. Nine active quality combinations. No nicotine investment yet.
- Active firms earn current operating profit, then observe private scrap draws and choose exit/continue. Candidates observe entry costs and choose simultaneously with incumbent exit. Entry costs paid now; entrants operate next month; initial quality drawn after commitment from a common empirical distribution calibrated from newly qualifying incumbents. That sample is not genuine newborn firms.
- Normal net scrap mean zero, SD sigma_S; exponential entry cost mean mu_E; independent fresh draws. Common constant FC. Initial candidates retain waiting options: enter if cost ≤ discounted active-entry value B minus discounted waiting value W. Exited firms cannot return.
- Full model: 121,000 dynamic states; manually solved value/policy fixed point. Numerical checks do not establish uniqueness, empirical validity, or identification.

## Fit exercise and limits

Two coordinate passes, nine converged combinations. Equal-weight monthly MSE groups: JUUL/VUSE entry CDFs, initial-three survival curves, active count divided by five. 2,000 common-random-number paths; separate 10,000-path simulation check.

Original trial: FC $100k/month, entry mean $100m, scrap SD $5m. Selected: **FC $0, entry mean $300m, scrap SD $5m**. Loss falls about 60%; FC/entry choices are grid endpoints and scrap SD $1m/$5m tie on search paths. Selection improves BLU survival, but entry stays early and MISTIC's late exit is missed. Marc correctly noted that parameter selection by fit counts as estimation; coarse fit does not establish precision/identification.

Observed events proxy scanner spells: first positive sales = entry; first month after final positive sales before sample end = exit; internal gaps retained, sample-end sales right-censored. Two entries and one late exit among focal brands. Historical 2013–2023 comparisons have no held-out period.

## Published passages already checked; verify their interpretation

- **Section 4, pp. 1013–1014:** maximum ten plants; market state includes current/past size and market demand. Counties ever exceeding the cap are excluded. Players choose out/small/medium/large, rather than a top-ten rank rule.
- **Section 5.1, p. 1016, equation (8), footnote 29:** state-change costs; exit cost normalized to zero; acknowledges difficulty jointly identifying fixed, entry, and exit costs. Private action-specific logit shocks differ from our exponential/normal payoff draws.
- **P. 1035, footnote 56:** a potential entrant declining entry has zero continuation value. **Footnote 57:** potential entrants mechanically number ten minus incumbents.
- Reconcile the fixed-N notation and Bellman equations with those footnotes before asserting persistent named candidates, reentry, or replacement identities. Our current waiting option should not be attributed to this paper merely because N is fixed.
- This is not a model of demoting low-ranked incumbents into a passive aggregate fringe. Its operating-profit function is reduced form, not our structural nested-logit Bertrand calculation.

Marc separately described a stream of one-period candidates: decline and disappear, no accumulating pool. One candidate per month was an example, **not a final adopted rule and not the same entrant count as this paper**. No final new arrival/cap/reentry rule has been chosen.

## Questions to work through sequentially

1. What exactly is an incumbent, inactive position, entrant, and exiter in the paper? Is identity retained, and where does the continuation value terminate?
2. How does the cap constrain candidate arrivals, simultaneous entry/exit, and the number operating next period?
3. How do payoff shocks, timing, and exit normalization differ from our setup? Which differences matter for waiting and identification?
4. Can we keep an exogenous passive demand fringe while generating genuinely new strategic entrants? What economics would that omit?
5. If anonymous/new entrants replace named brands, how should cost/quality types be assigned, and should targets become aggregate or type-specific rather than exact JUUL/VUSE dates?
6. Which changes are essential now versus optional extensions? Distinguish a modeling choice from a theorem or data necessity.

## Bring back to Codex

Before ending the online discussion, request a concise decision memo with: (a) agreed rules versus unresolved alternatives; (b) precise timing and Bellman/entry equations; (c) arrivals, cap, exit permanence, waiting and initial-state information; (d) entrant cost/quality types and treatment of fringe; (e) estimation targets affected; (f) published page/equation/footnote references; (g) implementation changes and tests, without assuming code was already changed. Paste/save that memo for the fresh Codex session. Preserve annual discounting and the deferred endogenous-nicotine priority.
