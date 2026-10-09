## Current focus: sigma and market size

Start with the [2026-10-08 handoff](handoff_sigma_market_size_2026-10-08.md). IV sigma remains above one after adding size/variety, rebuilding retail inputs, and testing three market sizes. We are now examining the definition of M_t and the economic meaning of the outside option; see [formulas and interpretation](market_size_and_outside_option.md). No new denominator is approved.

[Sanderson-Windmeijer conditional F diagnostics](../output/demand_estimation/specification_comparison/conditional_F/README.md) were completed on 2026-10-08 for M1-M4 and all matched control models. They do not show an obvious collapse in conditional relevance; exclusion and market-size compatibility remain unresolved.

# Model documentation

Working copies of the uploaded handoff materials, saved on 2026-09-29.

- [Price construction update](price_construction_update.md): current UPC-unweighted firm-month price definition.
- [Build prompts](mpe_build_prompts.md) and [handoff notes](handoff_notes.md): original text with the current price specification inserted at the top.
- [Model note](ec_supply_conference_model.pdf): price construction and a brief observed-revenue caveat are embedded directly in Section 3 (Demand), page 3. The added cover page has been removed.
- [Solution appendix](ec_supply_solution_appendix.pdf): price construction and the revenue caveat are embedded in Section 1 (Demand system), page 1.
- [Talk](ec_supply_conference_talk.pdf): the Demand slide (9/13) includes the UPC price calculation, equal weighting across UPCs, and a brief revenue caveat.

All three PDFs now incorporate the price revision directly, without added cover pages. Original equations and other content are preserved; unrelated modeling issues have not been comprehensively revised. Editable original PDF sources were not supplied.
- [Claude conversation](claude_conversation_2026-09-24.txt): verbatim historical transcript, not current instructions.

The live pipeline is under `smoke_firm_dir/`. The current market-size baseline uses the annual mean of household-weighted NCP monthly mL times US adult population. The original Downloads files are preserved.

- [Instrument discussion and revenue identity](instrument_decisions_2026-09-29.md): geographic tax weights, alternative active-brand count, roster distinction, and the price/revenue algebra.


## Retail rebuild completed 2026-10-08

[Rebuild audit](retail_rebuild_2026-10-07.md) records before/after totals, the preserved 2026-10-07 snapshot, and validation. Retail volumes and nicotine quantities were corrected; revenue, unit totals and the separate NCP input are unchanged. The model PDFs embed the current retail construction in their demand sections. The [comparison report](../output/demand_estimation/specification_comparison/README.md) includes refreshed estimates and all three market-size alternatives. The original conversation transcript remains historical.
