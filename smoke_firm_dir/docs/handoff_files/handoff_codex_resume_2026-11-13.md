# Resume handoff - anonymous e-cigarette supply model - November 13, 2026

## Start here: current result and next objective

The approved anonymous, replenishable strategic-firm model is implemented as an exact small-game reference solver. The full 27-type, five-active-firm geometry and static pricing are feasible. **The dynamic solve has NOT completed even one full Bellman update**, including a two-hour run. There is no dynamic residual sequence, no converged revised-model solution and no evidence yet about convergence/divergence of successive guesses.

The next objective is a more efficient expectation algorithm, verified against the exact small-game reference, so a full-state Bellman update can finish and we can measure successive value/policy residuals. Do not just restart the identical two-hour cache run or change approved economics to get a smaller problem. User explicitly wants to attempt solving, not only do endless preparatory benchmarks; computation should advance toward an actual full-state solve with measured progress.

Repository on this machine: `C:/Users/user/Desktop/Bitbucket/smoke_firm`. The chat's writable workspace was the sibling marriage-tax repo, so edits/launches in smoke_firm required tool escalation. Read `CLAUDE.md` before edits. Run scripts from smoke_firm repository root; source `smoke_firm_dir/code/fxns/1_paths.R`. Rscript is available (R 4.2.2). Startup emits locale warnings but tested scripts run. Git may require per-command `git -c safe.directory=C:/Users/user/Desktop/Bitbucket/smoke_firm ...`; do not modify global trust settings unnecessarily.

This handoff supersedes stale launch/feasibility statements in the accumulating November 12 implementation audit and meeting notes. The old November 11 handoff describes the preserved named-brand baseline, not the current approved revised specification. Do not reread all historical meeting material to infer decisions.

## Approved revised model

- Up to **five active anonymous strategic firms**. Once admitted, strategic status persists until endogenous permanent exit, regardless of market share. No demotion/promotion to/from fringe. Positions replenish with genuinely new firms. Lifetime simulation IDs are separate from equilibrium types.
- At the start of a month with fewer than five active strategic firms, one fresh candidate appears. It privately draws exponential sunk entry cost and enters or disappears with **zero waiting/continuation value**. No queue or persistent named potential entrants.
- Entry commitment and incumbent exit choices are **simultaneous**, explicitly confirmed by Erin in this session: neither observes realized counterpart actions before choosing.
- A committed entrant pays in t, draws its type after commitment, and first operates in t+1. Activate incoming entrants at the next boundary BEFORE counting active firms for the new candidate check. No persistent pending flag is needed under this convention. Five active at t with an exit => no candidate at t; a candidate at t+1 can first operate at t+2.
- Incumbents operate and pay FC, then observe private normal net-scrap draws and choose exit/continue. Scrap mean zero. Exiting identities never reenter.
- MC is firm-specific, public after revelation and fixed for life. Entry draws for MC, initial nicotine and initial xi are independent and revealed after commitment. MC is NOT known before committing. Existing known MCs are not integrated over; candidate and future entrant MC draws are.
- Nicotine and xi remain exogenous independent Markov processes, using retained existing transitions and three representatives each. No endogenous nicotine/FDA mechanisms yet.
- Monthly beta = `0.95^(1/12)` = approximately .9957347, never .95 monthly.
- Passive aggregate fringe has no pricing best response. Its total mean utility already bundles price/nicotine/residual quality. For historical work use observed monthly delta_F,t and solve each month's stationary infinite-horizon game assuming that current value persists forever; subsequent changes are unanticipated revisions. Do not change current profits while retaining stale continuation values. This does not add a fringe state dimension within a stationary solve.
- Market size remains January 2013 fixed. Its time variation has NOT been adopted.

## Approved empirical MC distribution (already constructed)

Use all nine firms in the ORIGINAL observed-market recovery, 540 firm-months. Compute each firm's historical median MC, then floor that median at zero. Weight firms equally (1/9), sort by floored median and put three consecutive firms in each group. Group means are support points; probabilities are 1/3 each. No median is negative, so zero floor currently changes nothing. Negative MC interpretation is deliberately deferred by Erin and Marc; do not reopen as a prerequisite.

| MC support, real dollars/mL (rounded) | Probability | Firms |
|---|---|---|
| 2.466626 | 1/3 | MISTIC, LOGIC, VUSE |
| 3.489738 | 1/3 | NJOY, MARKTEN, FINITI |
| 6.139296 | 1/3 | 21ST CENTURY SMOKE, JUUL, BLU |

Full precision and provenance: `output/dynamic_entry_exit/anonymous_mc_2026-11-12/entrant_mc_inputs.rds`, relative to smoke_firm_dir. Object contains `mc`, `p_mc`, support, firms and source hash. Script 37 constructs it. Extended five-firm MC recovery is a possible sensitivity sample, not pooled with original recovery. Support choice does not classify all nine observed brands as strategic or assign initial incumbents to MC types.

Three MC x three nicotine x three xi = **27 active types**. Anonymous multisets up to cap five give `choose(32,5)=201376` public configurations and **849555 occupied (state, tagged type) entries**. The old 121000-state count does not apply after the anonymous/MC revision.

## Key code: code/5_dynamic_entry_exit/

- 20_dynamic_solver_functions.R: preserved original named-roster solver; only normal expected-max helper is reused by revised code.
- 32_anonymous_model_functions.R: explicit type distributions, fixed-MC transitions, multiset enumeration, exponential one-shot entry option, pure lifetime-ID boundary transition, monthly fringe solve dispatcher.
- 33_validate_anonymous_model.R: type/timing/cap/IDs/entry/discount/dispatch tests.
- 34_audit_anonymous_inputs.R: read-only cost/fringe input audit.
- 35_anonymous_equilibrium_functions.R: exact tagged-type Bellman expectations, multiset convolution, manual damped fixed-point solver, manual static payoff builder, stationary factory. **This is the independent reference implementation.** Backend selectable through `expectation=`. Geometry now includes a hash lookup to avoid searching a 201k-element named vector for each successor.
- 36_validate_anonymous_equilibrium.R: independent labeled Cartesian enumeration, single-position scalar Bellman, static FOCs/bisection/profit perturbations, duplicates/symmetry, toy equilibrium, fringe re-solves.
- 37_construct_anonymous_mc_distribution.R: approved cost construction and tables.
- 38_benchmark_anonymous_solver.R: progressive synthetic size/pricing/update measurements.
- 39_cached_anonymous_expectations.R: exact policy-independent conditional-action successor cache. Stores successor value indices/weights, then recombines with current action probabilities. `on_full="stop"` default; two-hour run uses `on_full="clear"`. Clear/recompute is exact but can prevent reuse. Entry budget is NOT a process RAM cap.
- 40_validate_benchmark_cached_expectations.R: cached/reference agreement for random/endpoint policies and equilibria; 27-type cap-two timings. Running overwrites its benchmark CSV, so avoid gratuitous reruns.
- 41_attempt_full_anonymous_trial.R: full vectorized pricing and 60-second-update trial; --hash-retry selects separate output folder.
- 42_run_two_hour_anonymous_trial.R: separate two-hour background runner, progress logs, cache clearing, whole-iterate checkpoints. Not a partial-Bellman resume engine.
- 43_validate_cache_eviction.R: checks exact cache clearing vs reference.

Tests 33, 36, 40 and 43 have passed. Later changes to expectation backends must retain independent-reference and identical-type/multiplicity checks. No generic optimizer/root package was used; preserve manual numerical methods.

## Bellman conventions and numerical diagnostics

V[s,k] is the pre-draw value of ONE tagged incumbent of type k, not total value of all type-k firms. Remove exactly one own occurrence when integrating rivals. Duplicate firms have symmetric policies but independent private draws, and their multiplicity affects prices and transitions.

`C = beta E[V(next state, own next type) | own continuation]` integrates rivals' simultaneous exits, entrant acceptance where eligible, and independent continuing quality transitions.

`V_new = variable_profit - FC + C*pnorm(C/sigma_S) + sigma_S*dnorm(C/sigma_S)`; continuation probability is `pnorm(C/sigma_S)`.

Candidate B is discounted expected next operating value under initial independent G and incumbent exit policies, with no extra initial transition. Acceptance probability `1-exp(-max(B,0)/mu_E)`; expected candidate option value `D + mu_E*expm1(-D/mu_E)` with D=max(B,0). Decline value zero.

Solver compares full proposed updates before damping:
- scaled Bellman residual: max(abs(Vnew-V)/pmax(1,abs(V),abs(Vnew)));
- policy residual: max absolute change across incumbent continuation and candidate entry probabilities.

Damping .5 moves next guesses halfway toward the update. Tolerances 1e-6 value / 1e-7 policy. Need completed updates to measure these; none exist at full size. User understands a timed-out first update is not convergence failure/nonexistence.

## Full-size trial settings and saved static results

Trial only, NOT revised estimates: FC=100000/month, mean entry cost=100000000, scrap SD=5000000, beta=.95^(1/12). Demand coefficients/representatives/continuation transitions are retained empirical inputs. January fringe delta_F=-7.37101224733 and M approximately 2037193474.9118. Existing joint entrant-G marginals are multiplied independently for this computational trial; those marginal sources were a labeled trial choice, not a new approved calibration procedure.

Full geometry takes roughly 4.4-4.9 sec, object about 70 MB. Vectorized static pricing takes about 7.7-10.8 sec. Static FOC max 5.66e-12, mass checks passed, selected singleton/full states compared with independent manual scalar solver and unilateral bisection. **Do not repeatedly redo static pricing to diagnose dynamic expectations:** static_payoffs.rds already contains full `profits`, `types`, `delta_F`, `M`, settings. Reconstruct geometry with the identical enumeration before aligning rows; verify dimensions/order/type law.

## Two-hour run: FINAL outcome, not still running

Folder: `smoke_firm_dir/output/dynamic_entry_exit/anonymous_full_trial_two_hour_2026-11-12/`.

Final status: converged FALSE; phase stopped; failed_phase Bellman iteration; error `reached elapsed time limit`; **iterations_completed=0**. Script ran Nov 12 until its 7200-second budget. It did not crash from lack of RAM or reach a numerical convergence rejection.

Cache stats at stop:
- misses: 12710; hits: **0**;
- full-cache clear events: 15 (budget 5 million stored successor entries);
- final retained entries: 2501967, 207 keys, payload 31815256 bytes.

The 12710 figure is cache misses, including the interrupted construction; do not call it 12710 completed Bellman updates or percent completion. Traversal order and branch cost vary, so no reliable total-time extrapolation follows from it. Zero hits describes this first partial pass; it does not prove caching can never help. First-pass construction dominates and clearing discards future reuse.

Files:
- status.rds / status.txt: authoritative final result;
- run.log / stderr.log / progress.txt: progress and locale warnings;
- static_payoffs.rds: reusable completed static stage;
- resume_checkpoint.rds: **initial guesses only**, iteration 0, saved before the incomplete update;
- no trace.csv, no completed-iterate checkpoint.rds, no solution.rds.

**No partial successor cache or partially updated Bellman arrays were persisted.** The runner refuses to overwrite an existing status. Loading resume_checkpoint alone does not recover two hours of cache construction. Do not claim there is a useful advanced iterate to warm-start from.

Two earlier 60-second attempts remain in anonymous_full_trial_2026-11-12/ and anonymous_full_trial_hash_retry_2026-11-12/. Both completed static payoffs, zero Bellman updates. Hash fix improved throughput but did not solve full dynamic workload.

Small case success: two-type toy equilibrium converged in 251 updates, residuals approximately 2.60e-7 value and 9.87e-8 policy. 27-type CAP TWO warm cached updates took about .12-.13 sec vs 3.8-3.95 sec reference; cold build ~4.5 sec. Do not generalize this warm speedup to full cap five.

## Next work: computational, without changing economics

1. Inspect reference and cached expectation loops; profile/factor the explosion in action-conditioned quality successor construction, sorting/key generation and R object allocations. Hash lookup is already installed; do not present it as a new remedy.
2. Develop a more efficient exact or explicitly validated backend (e.g. shared/factored transition operations and compact multiset indexing), initially on small games. These are options to evaluate, not adopted methods. Do not silently prune probabilities, sample successors, coarsen types or introduce a new approximation.
3. Reuse the completed full profit table. Aim for one completed full-state update first; report wall time, memory, residuals and later changes across iterations. Continue toward a full stationary solve when feasible. Preserve dated run folders and record configuration/source inputs.
4. If partial work will take hours, persist reusable intermediate structures or resumable chunks and log completed state/tagged work, not just calls. Verify alignment and correctness before using persisted data.
5. No new long process has been authorized by the handoff itself; current user request was to write this handoff. A new session should infer subsequent work scope from its actual user instruction. Do not launch a duplicate based on stale PID files; read final status.

## Open empirical choices (not blockers for stationary full-state computation)

- January 2013 actual anonymous initial population and cost/quality assignments.
- Empirical strategic-set definition and fringe compatibility. Current fringe excludes the old five fixed focal brands throughout and includes LOGIC/others. It is not yet established as the correct partition for revised anonymous historical fitting.
- Replacement calibration moments/loss/weights. Old named JUUL/VUSE entry and BLU/MISTIC/NJOY survival objectives are not automatically transferable. Scanner first/last sales are not literal economic entry/shutdown; censoring matters.
- Coverage/monetary scaling and MC/demand sensitivity. Do not unilaterally rescale sunk/scrap costs.

These need resolution before historical simulation/fitting, not before solving values for every hypothetical state at one fixed environment.

## Documents and preservation

- User-supplied decision handoff: `C:/Users/user/Downloads/ec_supply_codex_handoff_2026-11-12.md` (contains approved/open distinctions, partly superseded by subsequent MC decisions above).
- Meeting note: `smoke_firm_dir/docs/meetings/marc_mtg_2026-11-16.md`, authoritative user-facing decision record. Naming rules in meetings/AGENTS.md. Supporting CSVs in meetings/tables.
- Older accumulating audit: `docs/handoff_files/anonymous_supply_implementation_2026-11-12.md` relative to smoke_firm_dir; read selective sections, with this handoff's final outcome taking precedence over its earlier launch status.
- Baseline named-roster code 20-31 and completed old outputs preserved. New code is 32-43; no commit/push performed. At handoff git showed README modified, new scripts/docs/tables/output directories untracked. Do not discard user changes or assume files are committed.
- Literature PDFs local only; do not add/push. Preserve canonical corrected panels and user-edited meeting presentation/transcription. No endogenous nicotine/FDA stage yet.

Quick checks from repository root:

```powershell
Get-Content smoke_firm_dir/output/dynamic_entry_exit/anonymous_full_trial_two_hour_2026-11-12/status.txt
Rscript --vanilla smoke_firm_dir/code/5_dynamic_entry_exit/33_validate_anonymous_model.R
Rscript --vanilla smoke_firm_dir/code/5_dynamic_entry_exit/36_validate_anonymous_equilibrium.R
Rscript --vanilla smoke_firm_dir/code/5_dynamic_entry_exit/43_validate_cache_eviction.R
```

No need to rerun tests merely to read this handoff; run relevant checks when implementation changes.