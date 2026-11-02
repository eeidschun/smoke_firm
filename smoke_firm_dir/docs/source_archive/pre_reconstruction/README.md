# Original supply PDFs

These are the unmodified originals preserved before the October 27, 2026 reconstruction. Keep them: the conference-model LaTeX includes a cropped copy of the original page-one figure.

Editable sources now live at `docs/ec_supply_conference_model.tex` and `docs/ec_supply_solution_appendix.tex`. Run `bash smoke_firm_dir/docs/build_supply_documents.sh` from the repository root to rebuild both current PDFs using XeLaTeX.

The reconstruction consolidates duplicate/overlapping text rather than preserving the original page layout. Changes made explicitly in the reconstructed documents:

- Signed demand slope: `+ alpha * price`, alpha negative; corresponding share derivatives, markups, cost inversion, and fixed-point equations updated.
- Demand intercept retained, with marginal costs denoted `mc` to avoid confusing them with the intercept `c`.
- Passive fringe utility includes price and unobserved quality; total utility is calibrated from observed shares and held fixed within a static price solve.
- Current provisional demand specification distinguished from historical equal-UPC/population-weighted-tax diagnostics.
- Manual damped markup iteration described as successive substitution, not an exact best response; convergence and Nash checks distinguished.
- Original contradictions about the five-firm cap versus six observed incumbents, fixed versus private entry/exit costs, and the below-CR3 residual explicitly flagged. Dynamic monotonicity and policy-evaluation claims qualified rather than assumed.
- Original historical concentration table, chart, diagnostic discussion, proposed dynamic equations, transition construction, and draft references retained in clean form; historical claims are not newly estimated or bibliographically verified.

Checks: both sources compiled twice without LaTeX warnings or overfull boxes; all twelve rendered pages inspected. Own/cross price derivatives checked by central finite differences at sigma = 0, 0.3, 0.869475559477503, and 0.95 (maximum absolute error below 3e-10). Inversion including fringe and markup FOC identities checked numerically. No supply equilibrium solver or cost-recovery exercise has been implemented by this document reconstruction.
