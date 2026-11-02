Sequential pricing audit, November 2, 2026.
Same monthly economic game and recovered states as original simultaneous solver. No changes to demand, costs, fringe, or economic move timing.
132 months x four starts x two firm orders x three configurations = 3168 attempts. Orders: alphabetical brand names and reverse. Markup damping .5/1; exact sequential best responses damping1.
Gauss-Seidel markup recalculates a single coordinate using the newest vector. Sequential best response finds each coordinate profit maximum by manual bisection. After each FULL sweep all FOCs and map residuals are recomputed together.
All three original tolerances and iteration cap2000 retained. Final unilateral best-response checks apply to every converged run, not just a reference start. No black-box solvers or full fitted models.
Full-sweep counts do not measure equal computational effort: best responses require inner bisection work. Firm update and bisection-iteration counts are exported.
Agreement across tested orders/starts/methods supports numerical robustness, not a proof of joint equilibrium uniqueness or empirical validity.
Additional unit checks: explicit one-sweep Gauss-Seidel path, iteration-budget failure, one-firm equivalence, consistent relabeling/order invariance, unchanged original inputs.
