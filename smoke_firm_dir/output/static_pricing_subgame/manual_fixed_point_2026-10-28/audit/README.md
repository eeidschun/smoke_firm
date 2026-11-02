# Pricing audit plots

Run: Rscript --vanilla smoke_firm_dir/code/4_static_pricing_subgame/7_audit_plots.R

Open pricing_audit_plots.pdf for the complete booklet. Each figure also has standalone PDF and PNG versions.

01: observed vs solved firm prices. Exact overlap is expected from inverted costs; it is not empirical validation.
02: price-error time series on a separate numerical-error axis.
03: price, recovered effective marginal cost, and markup. Integrated-channel objects, not separately observed production costs.
04: map and FOC residuals for first, middle and slowest month, cost+1 initialization, all damping values.
05: iteration counts for every start and damping across all 132 months.
06: unilateral profit curves for every incumbent in selected months. Rivals fixed; solved price and manually bisected optimum should coincide. The plotted grid is illustrative; bisection checks use the full above-cost domain via bracketing.
07: separate numerical counterfactual, not a fitted result. Largest-volume firm in latest month gets a 10% cost increase. Three starting vectors converge to the same solution, with manually verified unilateral best responses.
CSV files give curve points, selected markets, markers and cost-perturbation results. Existing recovery and equilibrium inputs unchanged.
