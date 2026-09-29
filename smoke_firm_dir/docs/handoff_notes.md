# Handoff notes for a new Claude session (VS Code) — e-cig dynamic oligopoly supply model

## Price construction update ? 2026-09-29

Firm-month price is the **UPC-unweighted mean of UPC-month prices in real dollars per mL**:

`p_upc,t = sum(real revenue_upc,t) / sum(mL sold_upc,t)`

`p_i,t = mean(p_upc,t across eligible UPCs belonging to firm i in month t)`

Collapse multiple T2 rows to one brand ? UPC ? month observation before taking the ratio. Use the existing sample: UNKNOWN excluded, positive units and mL, and at least three reporting stores per UPC-month. Each eligible UPC receives equal weight within its firm-month, matching the across-UPC weighting convention for nicotine state `a_i,t`.

This replaces the firm's aggregate revenue/mL price in `code/build/8_build_firm_month_demand_panel.R`. Quantities, revenue totals, shares, market size, and the population-weighted national tax instrument retain their existing construction. The saved descriptive fringe `p_F` remains aggregate fringe revenue/mL; it is not a price regressor or strategic price in the current model.

The product-line average price times total firm mL generally does not equal observed revenue. Consequently, model revenue/profit based on this representative price should not be described as an accounting reconstruction of scanner revenue.


Paste this file's content (or attach it) into the new session before running Stage 0 of `mpe_build_prompts.md`. It captures decisions made outside the repo that Claude in VS Code has no way to know about otherwise.

## What this project is

A dynamic-oligopoly supply-side model of the US e-cigarette industry (advisor: Marc Rysman; consulting: Ariel Pakes). Firm-level nested logit demand, a static Bertrand-Nash pricing subgame solved each period, and a dynamic entry/exit Markov Perfect Equilibrium solved via nested fixed point (Pakes-McGuire style). The two ground-truth PDFs are the solution appendix (every equation, numbered) and the conference model note (prose motivation, notation, and the "what this version leaves for later" open questions). `mpe_build_prompts.md` translates both into staged build instructions.

## PDFs to upload to the new session

Upload all three, in this order of importance:

1. **`ec_supply_solution_appendix.pdf`** — ground truth for every equation. Claude in VS Code should implement exactly what's in here, not re-derive from a generic BLP/Pakes-McGuire template.
2. **`ec_supply_conference_model.pdf`** — prose motivation, the demand/pricing/dynamic-game setup in words, and the "Questions for Marc" section (open modeling questions — see below, some now resolved since that PDF was last generated... actually it's current as of today, so it already reflects everything below).
3. **`ec_supply_conference_talk.pdf`** — talk deck, for high-level framing only. Lowest priority; skip it if you want to keep the upload light, nothing in Stage 0-7 depends on it.

Use the lowercase filenames (`ec_supply_*`) — if you see capitalized duplicates (`EC_Supply_*`) sitting anywhere, those are stale early drafts, not current.

## Settled modeling choices (confirmed, safe to build against)

- **Incumbent/fringe classification.** A firm is a full incumbent in the nested logit for calendar year Y iff its annual market share (annual mL sold among identified brands ÷ total annual mL among identified brands, same filtering as the roster construction: ≥3 stores, UNKNOWN excluded) exceeds **7%**. This assignment is fixed per calendar year even though the logit itself runs at monthly frequency. Chosen over 10%/15% specifically because 7% keeps every firm's incumbent spell unbroken in the data (no firm exits and returns) — at 10%+, NJOY drops out in 2018 and comes back, which would raise a harder question about whether that reclassification counts as dynamic entry/exit.
- **Decoupled from N̄=5.** The 7% rule governs the demand-side incumbent/fringe split. N̄=5 governs only the dynamic entry/exit game (up to 5 active firms in the MPE state space). These don't conflict in the data — the annual incumbent count under the 7% rule ranges 3-6/year, so it isn't even bounded by 5, but that's fine since the two objects serve different parts of the model.
- **Instruments (Stage 1).** Price is instrumented with a population-weighted **national** excise-tax series: `TaxIV_t = sum_s (Pop_s/Pop_US) * tax_{s,t}`, built from state-month e-liquid excise tax rates and Census state population weights — one value per month, same value applied to every firm that month. (This replaced an earlier firm-specific shift-share design; population weighting was Marc's direct guidance, not a fallback.) The within-nest-share regressor `ln(s_i,t/s_g,t)` is instrumented with the count of active firms in the market that period (also Marc's guidance). Both are written into `mpe_build_prompts.md` Stage 1 as explicit build steps already.

## Still open — flagged, not blocking Stage 1-3

- **Does crossing the 7% line count as dynamic entry/exit?** I.e., does a future threshold-crossing trigger the λ^exit/λ^entry comparison against φ_i/x_e, or is entry/exit reserved for a firm genuinely starting/stopping sales? This is moot for the historical panel under the 7% cutoff (no crossings occur), but it will matter once Stage 4/6 need a rule for handling any future or out-of-sample crossing. Logged as a question for Marc in the model note; no action needed from Claude in VS Code until Stage 4.
- **φ_i / x_e distributional family (Stage 4).** Explicitly deferred — the build-prompts file already tells Claude to propose 2-3 standard families (shifted exponential, uniform, log-normal) against the Pakes-McGuire/Ericson-Pakes literature before writing estimation code, and you pick one.
- **Legacy-brand bias in a_{F,t}.** A correction is derived (exclude a firm's post-exit UPCs from the fringe average once its deviation from that month's fringe mean exceeds ~10%, applied only post-incumbency) but not yet implemented. Not needed for Stage 1-3; relevant once the fringe state a_{F,t} construction is actually coded.
- **RMS coverage vs. outside benchmarks.** Separate, deferred data-quality question (RMS scanner data appears to undercount convenience-channel sales relative to Nielsen Convenience Track / All Outlets Combined benchmarks, especially pre-2017) — doesn't gate anything in the current build-prompts stages, just documented so it doesn't get lost.

## How to run the handoff

Paste this file's content as your first message (or just summarize the settled-choices section above), then follow `mpe_build_prompts.md` starting with Stage 0 — orientation only, no code yet. Run one stage at a time, verify each stage's sanity checks before moving to the next, per that file's own instructions.
