# Anonymous supply revision: implementation audit - November 12, 2026

## Decisions and timing

Authority: approved changes in ec_supply_codex_handoff_2026-11-12.md supplied by Erin. Open choices remain open. Erin additionally confirmed simultaneous entry commitment and incumbent exit choices in this session: neither observes the other's realized decision.

Boundary convention implements the approved one-month lag: entrants committed in t become active at the t+1 boundary before counting active firms or checking candidate eligibility. A current candidate is allowed only when that start count is below five. Incumbents operate in t, then exit or continue; a candidate's accepted commitment creates operation only in t+1. Since survivors <= current active count and commitments <= one, next active count <= five. No commitment survives a boundary as pending, so no persistent pending flag is needed. This is a state convention implementing the approved timing, not an added waiting/capacity rule.

Candidate decline pays zero and carries no waiting value. Entrants draw MC, nicotine and xi independently after commitment; initial types activate directly without an extra transition. MC then remains fixed. Unique monotonically increasing simulation lifetime IDs are separate from anonymous equilibrium types; IDs must be carried with next_id across every simulated month.

## Module map and implemented foundation

- Old 20_dynamic_solver_functions.R: named-firm tensor geometry, never-entered/dead states, waiting-value calculation. Preserved unchanged; cannot represent replenishable anonymous population by just toggling entry_waiting.
- Old 21_prepare_dynamic_payoffs.R: brand-specific MCs and five named slots. New payoff builder must use anonymous types and multiplicities with existing static demand/manual pricing functions.
- New 32_anonymous_model_functions.R: configurable MC/nicotine/xi types; independent entrant distribution; lifetime MC transition restriction; sorted multiset enumeration; one-shot exponential entry option; discounted entry value integration; pure simulation boundary transition; monthly permanent-fringe stationary-solver dispatcher with exact repeated-value reuse and warm starts.
- New 33_validate_anonymous_model.R: executable tests of these primitives, including exhaustive exit/entry patterns for all active counts zero through five, delayed replacement after full-market exit, no ID reuse, no extra initial transition, entry payoff quadrature, monthly discounting, and repeated-fringe dispatch/failure rejection. Synthetic inputs are tests, not adopted empirical bins.
- New 34_audit_anonymous_inputs.R: read-only MC/fringe coverage and source-hash audit.
- Old 29-31 diagnostics/calibration: named-brand targets cannot become the new loss without a separate decision. No new calibration run.

Update after authorization of steps 1-2: 35_anonymous_equilibrium_functions.R now implements the tagged-type Bellman operator, exact aggregated successor expectations, manual damped equilibrium iteration, per-state static pricing/payoffs, and a stationary-solver factory connected to fringe dispatch. 36_validate_anonymous_equilibrium.R validates these on synthetic small games. This is a small-game reference solver, not a production-scale cached implementation; empirical simulation and economic plots remain unimplemented. No 132-month historical solve has been run. The transition helper still accepts externally supplied actions/draws.

## Input audit findings

Original observed-market MC recovery covers nine firms and 540 firm-months, all positive: 21ST CENTURY SMOKE, BLU, FINITI, JUUL, LOGIC, MARKTEN, MISTIC, NJOY, VUSE. Thus coverage extends beyond the old five. The extended fixed-focal recovery covers five firms and includes ten negative MISTIC monthly inversions. These are different empirical samples; do not pool duplicate observations or silently choose a sample/discard negatives. Positive MC support is required by the new helper's current static-pricing-compatible interface; empirical treatment is still undecided.

The fixed-focal fringe file contains 132 distinct monthly utility values, so exact reuse alone does not reduce the historical solve count. It excludes the five old focal brands throughout and includes LOGIC and other brands. This removes the old annual-classification switching but still ties the empirical decomposition to that fixed set. A strategic-set mapping decision is required before claiming anonymous firms and this fringe form a consistent empirical partition.

Old entrant G is joint empirical nicotine/xi, whereas the new approved law is independent initial marginals. The old G cannot be reused unchanged. Existing independent continuation transitions can be retained. Their independence does not imply independence from aggregate shocks empirically.

## Architecture and performance

Represent public state by a multiset of active types, and firm value/policy by (state, focal type). Retain multiplicity when identical types compete; a tagged incumbent must be distinguished in expectations without creating persistent named slots. Use fresh candidate entry value with zero decline continuation. Integrate rivals' simultaneous independent actions conditional on state, quality transitions, and entrant initial draws. Normal scrap/FC accounting follows the existing pre-draw value convention.

For K active types and cap five, public-state count is choose(K+5,5). The unapproved illustrative K=27 gives 201,376 public configurations. Values additionally require focal-type incidence bookkeeping. This replaces the old 121,000-state representation; that old count applied before the anonymous population/MC revision. A dense public-state transition matrix would require about 324 GB in doubles alone, so use sparse/on-demand successor aggregation and profile toy cases first. No defensible runtime estimate yet. Current primitives do not allocate that dense matrix.

Monthly fringe remains a parameter per stationary solve; M remains January 2013. For every payoff parameter candidate, solve each observed fringe benchmark with its own continuation values, using warm starts. Do not interpolate or reuse old continuations as substitutes for solves without validating and approving an approximation. No expensive baseline work rerun.

## Decisions needed before empirical runs

1. MC recovery sample, negative/outlier treatment, representative per firm, weighting, bin count and probabilities.
2. Empirical strategic-set mapping and compatible fringe construction.
3. January 2013 active population and MC/quality assignments.
4. Replacement calibration moments and weights (after diagnostics), with scanner appearance versus economic entry distinguished.

Tagged-type Bellman expectations and the manual static payoff builder are now implemented and tested. Next work: profile and optimize successor aggregation/static caching before a full-scale run, resolve empirical input choices, then diagnostics before calibration. No endogenous nicotine or FDA mechanism is adopted.

## Verification

33_validate_anonymous_model.R passes under R 4.2.2. Input audit runs successfully; source datasets were read only. R emits host locale startup warnings but completes both scripts. Existing baseline scripts/results and meeting source text are preserved. No commit, push, or literature changes.
## Steps 1-2 completed: exact reference equilibrium and pricing

Values and continuation probabilities are stored by public multiset and tagged incumbent type. Removing the tagged firm removes exactly one occurrence; identical rivals retain their multiplicities and independent private exit draws. Conditional on simultaneous choices, continuing firms transition with P; at most one candidate enters with independent initial G. Incumbent continuation integrates over candidate entry, while candidate entry value integrates incumbent exits without conditioning on their realized choices. Decline has zero continuation. Current operating profit minus FC is outside the normal expected-max exit option; entry costs are paid now against discounted next-period operating values. The entrant receives no current operating profit or extra initial quality transition.

State expectations convolve independent labeled outcomes and merge equal successor multisets. This avoids a dense global transition matrix, but rebuilding these distributions at each iteration is expensive. The implementation prioritizes exact small-game verification; a production-scale runtime claim would be premature. Static markets preserve duplicate products: profit is per firm, not multiplied by the number of identical types. Zero strategic firms is handled explicitly with a fringe-only/outside demand split.

The stationary factory re-solves pricing and Bellman values for each fringe benchmark; the existing dispatcher reuses only exactly repeated benchmarks and uses preceding solutions solely as warm starts. Tests use two distinct fringe values and verify each solution against its own Bellman operator.

Validation: independent labeled Cartesian enumeration of incumbent continuation and entry values in all two-type states with cap three; an independently iterated single-position scalar Bellman solution; duplicate-type symmetry and label permutation; static FOCs, unilateral bisection and direct profit perturbations; full toy-game convergence and fresh residual checks; failed-iteration-budget reporting; actual monthly stationary re-solves and baseline primitive regression tests. The two-type game converged in 251 iterations, scaled Bellman residual 2.596408e-7 and policy residual 9.868091e-8. These are numerical checks on synthetic games, not empirical fit or identification evidence.

Run from repository root:

```powershell
Rscript --vanilla smoke_firm_dir/code/5_dynamic_entry_exit/33_validate_anonymous_model.R
Rscript --vanilla smoke_firm_dir/code/5_dynamic_entry_exit/36_validate_anonymous_equilibrium.R
```

Source dependencies for 35: old 20 (normal expected-max helper), new 32, static 1 and 4. Test 36 sources these explicitly. No empirical bins, cost distributions, initial conditions or calibration objective have been selected. Baseline code/results are unchanged.
## Empirical MC decision implemented

Erin approved the proposed construction on November 12: all nine original-recovery firms, one within-firm median each, floor medians at zero, equal firm weights, sorted groups of three, support at group means. Script 37_construct_anonymous_mc_distribution.R saves full-precision mc/p_mc and provenance to output/dynamic_entry_exit/anonymous_mc_2026-11-12/entrant_mc_inputs.rds, with firm assignments, support and source hash CSVs. Support is approximately 2.466626, 3.489738, 6.139296 real dollars/mL, each with probability 1/3. No medians are negative; flooring has no effect. This resolves the earlier MC sample/discretization questions for the baseline; January incumbent assignment and strategic/fringe mapping remain open. No old input or result was replaced. November 16 meeting notes contain supporting tables and the approved method. Construction invariants and saved input roundtrip pass.
## Performance benchmark completed

38_benchmark_anonymous_solver.R measures synthetic small games with the approved empirical MC support: (types,cap)=(3,3),(9,2),(27,1),(27,2). At 27 types/cap two: 406 states, audited static pricing 3.75 seconds and one Bellman update 3.75 seconds on this host. Full cap-five runtime is unmeasured; successor branching prevents reliable state-count-only extrapolation. Timings and memory counts saved in output/dynamic_entry_exit/anonymous_benchmark_2026-11-12/ and summarized in the November 16 meeting notes. All update probability/finiteness/cap invariants passed. Next computational work: cached/faster successor expectations validated against exact reference. No empirical initial-state, mapping or calibration choice was made by the benchmark.
## Exact conditional-transition caching (November 12 update)

39_cached_anonymous_expectations.R adds a selectable exact expectation backend. It caches successor value indices and quality-transition weights conditional on rivals' entry/exit actions, then recombines these terms using the current policies. No probabilities are pruned and no economic assumptions change. Cache keys preserve rival multiplicities, own next-type probabilities, and candidate availability. The cache is bound to a geometry/type law and has an explicit entry budget; exceeding that budget fails rather than silently approximating. Budget limits stored support entries, not every transient allocation or total process memory.

The reference solver remains the default. Use `cached <- anon_cached_expectation_factory(g)` and pass `expectation=cached$expectation` to anon_solve; a stationary factory can receive that setting through solver_control. The same cache can be reused across fringe/payoff benchmarks with unchanged geometry/type laws. Values and policies are recomputed; only conditional transition structure is reused.

40_validate_benchmark_cached_expectations.R passes cached/reference agreement for random and boundary policies, duplicate types, candidate/no-candidate cases, complete small-game equilibria, geometry mismatch and cache-budget failure. A 27-type/cap-two comparison uses nonconstant values across firm types and configurations, including distinct MC types. The pre-existing independent-enumeration suite also passed after the backend interface change.

Measured 27-type/cap-two update: reference 3.80 seconds; cold cache build/update 4.47 seconds; median of three warm updates 0.13 seconds (29.2x speedup). Stored payload 2,441,136 bytes, 79,731 successor entries and 784 keys. These are single-host timings, not full-scale estimates. Results: output/dynamic_entry_exit/anonymous_benchmark_2026-11-12/cached_timings.csv. Script 40 reproduces them.

Full 27-type/cap-five cache construction has not been attempted. Conditional branches grow with active count; this cache may require further factorization, sparse incidence storage or bounded reuse to run at full scale. Next computational step is to measure larger-cap cache size/build time under resource limits. Initial historical population and empirical strategic/fringe mapping remain unresolved.
## Full five-firm stationary solve attempt

Attempted November 12, 2026, with all 27 types and cap five. Trial payoff settings are FC=100,000/month, mean sunk entry cost=100,000,000 and normal net-scrap SD=5,000,000 with mean zero. Monthly beta=0.95^(1/12). These reuse original trial scales, not revised estimates. MC uses the approved distribution; nicotine/xi representatives and continuing transitions use existing empirical inputs. For this numerical trial only, independent initial nicotine/xi draws use the marginal probabilities of the old empirical joint G. No historical initial incumbent assignment is required to solve the full state space. January 2013 market size and fixed-focal fringe utility are held constant within this trial.

The complete geometry contains **201,376 public configurations** and **849,555 occupied tagged-type entries**. Geometry took 4.4-4.9 seconds and about 70 MB in R. A vectorized manual pricing implementation completed all configurations in 7.7-10.8 seconds. Maximum static FOC residual was 5.66e-12; mass checks passed. Selected singleton and full markets were checked against the existing independent scalar fixed-point and unilateral bisection routines. Static profits are saved for reuse.

**The dynamic game did not converge: neither attempt completed its first Bellman update within the imposed 60-second update limit.** No dynamic residual or converged solution is available. This is a bounded computational attempt, not evidence that no equilibrium exists or that a longer run cannot finish.

The first attempt revealed linear named-vector state lookup as a bottleneck. A hash lookup was added, and the independent-enumeration and cached/reference suites passed. On retry, the partial cache reached 293 completed keys, 667,770 successor entries and about 10.5 MB payload before the same time limit (versus 27 keys in the first attempt). This improves construction throughput but does not establish feasibility of caching every full-state successor distribution. The 2,000,000-entry cache budget was not the stopping condition in either attempt.

Reproduce with code/5_dynamic_entry_exit/41_attempt_full_anonymous_trial.R. The original run is saved in output/dynamic_entry_exit/anonymous_full_trial_2026-11-12/; the hash-lookup retry uses --hash-retry and saves separately in anonymous_full_trial_hash_retry_2026-11-12/. Both include status.rds/status.txt, static_payoffs.rds and trial settings. The script refuses to overwrite an existing trial status. No solution.rds is written for these failed attempts. No dynamic checkpoint exists because no full update completed. Old baseline outputs are preserved.

The identified remaining bottleneck is full-cap conditional successor-cache construction. Next computational work should reduce/factor that construction or use an explicit longer resource budget; it is not necessary to change the approved three MC types to diagnose this bottleneck.
### Two-hour solve authorized and launched

Erin authorized a two-hour background attempt on November 12. Runner 42_run_two_hour_anonymous_trial.R retains the same economic trial settings and exact expectations, replaces the 60-second limit with a total 7,200-second budget, and allows exact cache eviction at a 5,000,000-successor-entry budget. Evicted terms are recomputed, not approximated. Cache payload is bounded by entries; this is not a total process-memory cap. Test 43 verifies eviction against the exact reference, including repeated updates.

Separate output folder: output/dynamic_entry_exit/anonymous_full_trial_two_hour_2026-11-12/. Inspect run.log, stderr.log, progress.txt and status.txt/status.rds. A resume_checkpoint.rds is saved before each Bellman update; checked completed iterates also write checkpoint.rds and trace.csv. Only convergence writes solution.rds. Status remains nonconverged while running. Initial static stages are recomputed and validated in this separate run; prior attempts remain untouched.

The background process has been launched; completion and convergence are not yet known. The script stops at convergence, the time budget or an explicit error. A stopped process or exhausted time budget does not imply economic nonexistence. Follow-up should inspect status and logs before launching another attempt; do not launch duplicates.