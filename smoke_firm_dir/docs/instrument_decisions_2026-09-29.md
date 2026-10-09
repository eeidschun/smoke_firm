# Instrument discussion and revenue identity ? 2026-09-29

Geographic states are indexed by s; s' is the dummy index in the population-weight denominator. This notation refers to US states, not the dynamic economic state omega or market shares.

Let S_it be the set of geographic states in which firm i sells in month t. The requested tax instrument is:

$$Tax_{it}=\sum_{s\in S_{it}}\frac{Pop_{s,t}}{\sum_{s'\in S_{it}}Pop_{s',t}}\,tax_{s,t}.$$

Both tax rates and prices are real dollars per mL. Population observations are annual, applied to each month of the year. Presence in the comparison uses positive raw sales of UPC-months in the existing eligible national sample (positive units and mL, at least three stores nationally, UNKNOWN excluded). It does not impose three stores separately in each state.

The alternative count is the number of distinct identified brands with positive sales in at least one state in S_it. A brand present in several of these states is counted once. The focal firm is included, as it is in the current national count; excluding it subtracts one. All eligible brands are counted, including brands assigned to the demand fringe.

Compare national and geographic counts on the same 7% incumbent-month sample, controlling for nicotine and the tax instrument in both first stages. The initial comparison includes an intercept and nicotine, with no firm or time fixed effects. Report incremental count tests and joint excluded-instrument tests, with standard errors clustered by month and F-reference denominator degrees of freedom equal to the number of months minus one. These are diagnostic F tests, not a complete multi-endogenous-regressor weak-identification assessment; time dependence across months and exclusion restrictions require separate consideration. Contemporaneous sales footprints can be endogenous for both geographic instruments. Firms may share nearly identical footprints, leaving little firm variation.

## Revenue identity

With N eligible UPCs, q_u mL, and r_u revenue, the implemented price is p_bar = (1/N) sum_u (r_u/q_u). The expression supplied in the discussion omitted 1/N. Even including it, p_bar * sum_u q_u need not equal sum_u r_u. The revenue-recovering price is instead sum_u r_u / sum_u q_u, the volume-weighted average of UPC prices.

Example: UPC A sells 90 mL at $2/mL; B sells 10 mL at $4/mL. Observed revenue is $220. The simple-average price is $3/mL, yielding $300 when multiplied by 100 mL. The sum of prices without dividing by two is $6/mL, yielding $600. The volume-weighted price is $2.20/mL and reproduces $220 exactly.

## Demand roster remains undecided

The top-five or >7% rule selects individually modeled demand alternatives and the fringe complement. Neither rule requires restricting the instrument's count to these alternatives: the count can include all eligible active brands. The existing n_brands_3st already does this. Thus a top-five roster with an all-brand count is coherent as a construction, but does not by itself establish relevance or exclusion. Keep the 7% sample for a controlled instrument comparison until a roster decision is made.

The current PDFs describe the earlier national tax design. This dated note records the newer requested geographic design and its diagnostic implementation; it does not select the alternative count or change the demand roster.

## Completed comparison (refreshed after retail rebuild, 2026-10-08)

Run `Rscript smoke_firm_dir/code/2_preliminary_analysis/14_instrument_comparison.R` from the repository root. The first run scans the 11 annual detailed files (currently in root-level `input/`); later runs reuse the brand-state-month presence cache. Rebuild that cache if the eligible sample or raw data changes.

Outputs are in `output/prelim_analysis/instrument_comparison/`: `demand_instrument_candidates.csv` contains the recalculated `TaxIV_geo` and `n_brands_overlap` alongside the original instruments; `first_stage_month_clustered.csv` contains both first stages and incremental/joint F tests. The existing canonical demand panel is not overwritten by this comparison.

Incremental count F statistics for the within-nest-share first stage:

| Tax control | National all-brand count | Geographic union count |
|---|---:|---:|
| Original national tax | 80.18 | 49.44 |
| Revised geographic tax | 102.72 | 72.18 |

The geographic count equals the national count in 528/540 incumbent-months. Differences occur only for 21ST CENTURY SMOKE and LOGIC in 2013?2014. Thus this alternative adds little cross-firm variation here. Counts were independently verified by explicitly forming each firm-month's union of states and counting distinct brands. Geographic tax equals national tax for the observations covering all 51 jurisdictions (50 states plus DC).

For the revenue check, unweighted price times volume divided by actual revenue has minimum 0.570, median 1.352, maximum 2.861; none of 540 rows equals one within relative tolerance 1e-8. These results do not select the final count instrument, demand roster, or profit specification.

## Price decision ? 2026-10-01

Retain the UPC-unweighted representative price for now. The conference model, Section 3 (page 3), now includes the identity `p_bar * Q - R = sum_u (p_bar - p_u) * q_u`, which is generally nonzero, and notes the implication for later profit measurement.

## Pipeline layout update ? 2026-10-01

Run `Rscript smoke_firm_dir/code/0_master.R --stage=instruments --run` to build
the input and run the comparison in order. Construction is now in
`code/1_build_data/9_build_geographic_instruments.R`, with presence cached under
`input/` and the candidate panel saved as `input/demand_instrument_candidates.rds`.
`code/2_preliminary_analysis/14_instrument_comparison.R` only estimates the
first-stage diagnostics and exports the comparison CSVs. The original output
cache is retained for provenance. Diagnostic definitions are unchanged.
