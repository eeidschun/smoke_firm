# Meeting notes: Erin and Marc
**Date:** November 10, 2026  
**Reference:** marc_mtg_2026-11-10_presentation, main presentation only  

## Scope and interpretation

- **Current model:** What Erin described as implemented, not necessarily the final specification.
- **Marc’s feedback:** His questions, reasoning, recommendations, and qualifications.
- **Agreed next step:** An explicit commitment or clearly accepted direction.
- **Possibility:** An option discussed but not definitively adopted.
- **Open question:** An issue not resolved in the meeting.

Routine acknowledgments are not treated as agreement. The unrelated exam interruption is excluded. No deadlines were assigned.

## Executive summary

Erin has solved a provisional dynamic entry/exit model built on estimated nested-logit demand and static Bertrand pricing. Marc supported continuing with the baseline rather than replacing every simplifying assumption immediately.

The main directions were:

1. Clarify the entry process, especially the distinction between a fixed roster of potential entrants and a continuing stream of new entrants. Follow Allan Collard-Wexler job market paper for motivation.
2. Inspect value functions and comparative responses to understand the model economically, beyond checking numerical convergence.
3. Refine estimation and broaden the state space.
4. Begin modeling endogenous nicotine choice or investment, which Marc suggested may be more important than the other refinements. Lets defer this to after I've done 1 - 3.
5. Connect the proposed FDA counterfactuals explicitly to nicotine, A, and unobserved demand quality, $\xi$. Lets defer this to after I've done 1 - 3.

The meeting did not settle a final entrant-arrival rule, transition specification, payoff distribution, calibration target set, or policy-counterfactual design.

---

## 1. Demand specification and estimates

### Current model

Erin selected a **provisional nested-logit specification** to carry into the supply model.

She described the selection process as:

1. Comparing instrument families according to how frequently they produced admissible estimates of σ.
2. Restricting attention to specifications with a negative price coefficient.
3. Choosing a reasonably sized σ rather than one extremely close to one. Some alternatives had σ around **0.98**.

Erin clarified that she:

- Dropped firm fixed effects.
- Retained “control, price,” in her description of the specification.
- Excluded the lagged-quality instrument.
- Tried Gandhi–Houde instruments, but that exercise did not resolve all the demand-estimation problems.

The constant in the demand equation was estimated.

### Marc’s feedback and reasoning

Marc stopped Erin from skipping the demand material because he wanted time to examine it. He asked whether the constant was also estimated, and Erin confirmed that it was.

### Decisions and agreed next steps

No new demand specification or instrument family was chosen during this meeting. The specification remains provisional.

### Open questions

- Previously unresolved demand-estimation issues remain unresolved.
- Plausible coefficient signs and an admissible σ were selection criteria, not a demonstration that identification problems had been solved.
- No specific new demand-estimation exercise or deadline was assigned.

---

## 2. Static Bertrand pricing and recovered profits

**Discussion anchor:** 04:25

### Current model

- Active modeled firms choose prices.
- Marginal costs are brand-specific and held constant over time in the supply exercise.
- The fringe has a fixed mean utility.
- Fringe market share can respond to incumbents’ prices, but the fringe does not solve a pricing best response.
- Erin solves the pricing equations using a manually implemented fixed-point procedure rather than a general nonlinear solver.

Numerical checks included:

- Different initial prices.
- Different damping factors.
- Comparisons of prices and recovered marginal costs.

### Marc’s feedback and reasoning

Marc clarified that:

- The damping procedure solves the **static pricing first-order conditions**.
- This is separate from solving the dynamic entry/exit problem.
- “Manual” describes the numerical solution procedure, not a distinct economic concept called a “manual markup.”

### Decisions and agreed next steps

The interpretation of the pricing solver was clarified. No alternative solver or change in competitive conduct was selected.

### Open questions

Erin distinguished numerical-convergence checks from broader checks of economic correctness. Convergence alone does not validate the demand estimates, recovered costs, or dynamic assumptions.

---

## 3. Five-brand roster, fringe treatment, and entrant identities

**Initial discussion anchor:** 06:59  
**Later clarification:** 41:33

### Current model

The modeled roster consists of:

- BLU
- MISTIC
- NJOY
- JUUL
- VUSE

Erin tracks these specific firms even when inactive or not yet entered.

Their identities matter because the model:

- Assigns brand-specific characteristics and marginal costs.
- Targets observed brand-specific entry timing.

Erin’s earlier interpretation allowed movement between the five-firm incumbent group and the fringe. She worried that tracking demoted firms through eventual shutdown would require following approximately **12 or 13 brands**, expanding the state space.

### Marc’s initial clarification: fixed named potential entrants

One valid construction is a fixed set of named potential entrants that can be active or inactive.

Under that construction:

- The modeled firms do not become fringe firms when inactive.
- An active firm can receive a scrap payoff upon becoming inactive.
- Re-entry can require another entry payment.

Marc accepted this as a possible modeling choice. However, he said he had originally been pushing toward a different entrant construction.

### Alternative: a continuing stream of new entrants

Marc also described a construction in which:

- Firms can exit permanently.
- New potential entrants continue to appear.
- Entrant identities need not be predetermined named brands.
- The number of modeled firms or firms making choices can be limited for computational tractability.

The discussion included both replacement of exiting firms and a one-new-potential-entrant-per-period framework. These should not be treated as a single fully specified rule.

### Fringe interpretation

At **41:33**, Marc clarified that a replacement firm need not already exist “in the fringe.”

The fringe can be represented as an **exogenous demand object**, rather than as individually tracked firms waiting for promotion into incumbent status.

### Literature references

The two approaches were discussed with reference to:

- **Allan Collard-Wexler’s job market paper:** A useful applied example for understanding modeling choices about entrants, exit, and scrap values.
- **Ericson–Pakes (1995):** The framework used in the discussion of a continuing stream of new potential entrants.

Marc recommended reading Collard-Wexler’s paper at **49:27**, emphasizing the clarity of its economic modeling. He did not require studying its solution method in depth as the immediate task.

### Decisions and agreed next steps

At **50:17**, Erin explicitly said she would revise this part of the model.

The agreed direction was to clarify the entry process. The discussion did not establish a complete final replacement rule or require abandoning brand-specific matching.

### Open questions

- Fixed identities versus newly generated entrant identities.
- Whether exit is permanent or re-entry is possible.
- How and when new potential entrants appear.
- The precise meaning and implementation of the five-firm cap.
- How entrant characteristics are generated outside the observed sample.
- Whether initial characteristics are known before entry or revealed after commitment.

---

## 4. Entry opportunities, waiting, and the number of entrants

**Key clarification:** 47:11

### Current question

Erin asked whether the entry value function should include the option to wait rather than enter immediately.

### Marc’s explanation

In the one-period potential-entrant construction:

- A potential entrant appears.
- It can enter now or decline.
- If it declines, it disappears.
- It does not retain an option to enter later.

At **47:11**, Marc explicitly corrected the idea of an accumulating pool of unsuccessful potential entrants.

“Infinite potential entrants” meant an **infinite stream over time**, not infinitely many potential entrants in a single period.

### Number of entrants per period

Marc noted that a one-potential-entrant-per-period model cannot produce more than one actual entrant in a period.

His qualification was:

- An occasional observed period with two entrants need not be fatal.
- If multiple entries occurred frequently, the restriction would deserve more attention.

### Decisions and agreed next steps

Erin indicated that she could amend the timing and entry treatment. The no-pool interpretation of the one-period entrant framework was explicitly clarified.

### Open questions

- Whether to adopt one potential entrant per period as the final specification.
- How the entrant-arrival process interacts with the cap.
- Whether the frequency of multiple observed entries warrants a richer arrival process.
- Whether the fixed-roster alternative retains a waiting option.

---

## 5. Nicotine and demand-shock states and transitions

**Discussion anchor:** 16:46  
**Expanded-support recommendation:** 50:33

### Current model

- Nicotine, **A**, is exogenous.
- Recovered unobserved demand quality, **ξ**, is exogenous.
- Each variable is discretized into three pooled quantile bins.
- Together they form a **3 × 3** quality-state grid.
- Each bin is represented by its **within-bin median**, not its mean.

Erin tried **4 × 4** and **5 × 5** grids but found sparse support.

Endogenous nicotine investment is an intended extension, not a feature of the solved baseline.

### Marc’s feedback and reasoning

Marc clarified that exogenous variables can still be state variables.

He initially regarded the coarse discretization and use of medians as reasonable starting choices.

Later, he recommended a richer state space, potentially including states outside the observed data. His reasoning was that the state space represents outcomes firms perceive could occur, not only outcomes observed in the sample.

### Decisions and agreed direction

The coarse grid was not treated as grounds for abandoning the baseline.

Erin later clarified that making the state space more granular does not require every state to be reached. Marc explicitly confirmed that interpretation.

### Open questions

- The final number and placement of grid points.
- The extent of support outside the observed data.
- How to construct credible transitions for sparse or unobserved states.
- The precise transition estimator and dependence structure.

No new transition estimator or independence assumption was explicitly selected in the meeting.

---

## 6. Marginal costs

**Discussion anchor:** 19:08

### Current model

The dynamic model uses each brand’s historical median recovered marginal cost as a constant.

Erin noted that:

- Historical recovered costs vary over time.
- One brand had negative recovered marginal costs in some months.
- The recovered costs depend on the provisional demand specification.
- Firms know their assigned costs, including at entry.

Erin raised the concern that an entrant has the same assigned marginal cost as a firm operating for ten years.

### Marc’s feedback and reasoning

Marc distinguished:

- An **exogenous decline in costs over time**, and
- **Learning by doing**, which would add a substantially more complicated mechanism.

He asked whether large cost differences across brands might reflect entry timing or differences in prices.

Erin clarified that JUUL and VUSE were the later entrants in the modeled roster.

### Decisions and agreed next steps

Erin indicated that she was comfortable setting the learning-by-doing concern aside for now.

There was no agreement to implement learning by doing, a cost trend, or a new cost-state process.

### Open questions

- Economic plausibility of cross-brand cost differences.
- Interpretation of negative recovered marginal costs.
- Sensitivity to demand specification.
- Whether time-varying costs are important for the intended policy question.

---

## 7. Fringe utility, market size, and fixed-cost identification

### Current model: fringe utility

Erin compared:

1. Fixing fringe mean utility, **$\delta$ F**, at its January 2013 value.
2. Fixing it at the sample median of monthly recovered fringe utilities.

Implied January monthly variable profits were highly sensitive to this choice.

Erin retained the January value because it appeared more plausible and allowed her to proceed with solving a baseline.

The comparison concerned **profits under alternative fixed fringe utilities**, not a comparison of utility values expressed in dollars.

### Marc’s questions

Marc asked whether the fringe firm had:

- A price.
- A quality level.

Erin did not know the answer during the meeting.

The intended demand-side treatment was clarified as an exogenous fringe mean utility without a pricing best response. However, the exact implementation of fringe price and quality still needs checking.

### Decisions and agreed next steps

No new rule for selecting δF was agreed.

Checking how fringe price and quality are represented is an unresolved implementation issue, not a decision to make the fringe optimize.

### Current model: market size

Market size is fixed at January 2013.

Erin mentioned varying market size using Census information as a possibility, but did not regard it as an immediate priority.

Marc did not explicitly assign this exercise.

### Current model: fixed costs and identification

Erin uses a common constant fixed cost.

She cited only two entering firms and limited scope to identify variation across brands or time. Marc briefly accepted the explanation but did not offer a separate identification argument.

### Open questions

- How to choose and validate the fixed fringe utility.
- Sensitivity of profits and dynamic estimates to δF.
- How fringe price and quality enter the implemented model.
- Whether market-size variation is consequential.
- Which dimensions of fixed-cost heterogeneity the data can identify.

---

## 8. Private payoff distributions and discounting

**Private-payoff discussion anchor:** 28:18  
**Discount-factor suggestion:** 31:06

### Current model

- Entry costs follow an **exponential distribution**, chosen for positive support.
- Net scrap values follow a **normal distribution**, allowing negative values if shutdown or liquidation is costly.
- Erin explicitly said she was not committed to these distributional choices.

### Marc’s feedback

Marc did not choose or explicitly endorse a replacement distribution.

At **31:06**, he suggested starting with **0.95** to make convergence faster and help Erin learn from the model more quickly.

This was a development and computational suggestion, not the selection of a final calibrated discount factor.

### Decisions and agreed next steps

No final payoff distribution or discount-factor calibration was agreed.

### Open questions

- Sensitivity to the chosen private-payoff distributions.
- How the payoff parameters are identified.
- Which discounting convention should be used when implementing the development exercise.

---

## 9. Entry/exit measurement in scanner data

**Discussion anchor:** 31:32  
**Marc’s assessment:** 34:06

### Current treatment

Erin described the working event definition as:

- Positive scanner sales indicate operation.
- Zero sales indicate non-operation.

She noted that:

- Entry can appear late because products take time to reach observed stores.
- Sales can continue after manufacturer exit because retailers still hold inventory.
- The industry continues beyond the sample, so not every brand has an observed exit.

### Erin’s proposal

Research actual shutdown dates and set subsequent scanner sales to zero when they represent sales after manufacturer shutdown.

### Marc’s reasoning

Marc emphasized that:

- Retailers can keep selling inventory after a manufacturer exits.
- Such sales are not necessarily manufacturer liquidation.
- Nielsen data are imperfect for measuring economic entry and exit.
- A difference of a couple of months in event timing can be a tolerable limitation at this stage.

### Decisions and agreed next steps

Marc did **not** explicitly instruct Erin to zero out post-shutdown sales.

The research-and-recoding exercise remains a possibility, not an agreed requirement.

### Open questions

- Whether to retain scanner-based event dates or incorporate external shutdown information.
- How to distinguish retail availability from manufacturer activity.
- Whether event-date sensitivity materially affects the results.

---

## 10. Coarse calibration, estimation targets, and scaling

**Target discussion anchor:** 35:34  
**“Counts as estimation” clarification:** 36:56

### Current exercise

Erin solved the model for coarse alternative parameter values, varying one parameter while holding others fixed.

She used examples of monthly fixed costs of:

- **$100,000**
- **$200,000**

She selected among alternatives using the **smallest deviation from entry/exit targets**.

Erin initially said “highest profit,” then explicitly corrected herself. Profit maximization across candidate parameter sets was not the calibration objective.

Erin had not examined fit closely because she expected the model to change substantially.

### Marc’s feedback

Marc said that choosing parameter values according to fit **counts as estimation**, even when the search is coarse.

This was not a claim that the parameters are precisely estimated or well identified.

### Calibration targets

Current targets concern entry and exit timing.

Erin asked whether market shares should also be targets. The question was not explicitly resolved.

### Nielsen coverage and monetary scaling

Erin proposed scaling a hypothetical **$15 million** scrap value by **30%** if Nielsen captured 30% of the relevant sales.

Marc responded tentatively and said the treatment needed to be more thorough.

This was **not** an endorsement of proportional scaling. The numbers were illustrative, not established parameter estimates.

### Decisions and agreed next steps

Refining estimation was identified as a next step, conditional on retaining this model.

### Open questions

- Final target set.
- Whether and how to include market shares.
- Parameter scaling given partial market coverage.
- Identification of entry, exit, and fixed-cost parameters.
- Robustness to provisional demand and supply assumptions.

---

## 11. Value-function diagnostics and model understanding

**Firm recommendation:** 51:06

### Marc’s recommendation

- Graph the value function against the state variables.
- Check whether its shape is economically plausible.
- Change exogenous inputs and inspect how the value function responds.

### Reasoning

Marc emphasized understanding whether the model moves in the expected directions.

The goal is not simply to find parameter values yielding a “better” value function. It is to understand the model’s behavior and verify economic logic in addition to numerical convergence.

### Agreed direction

Erin acknowledged the exercise and clarified her understanding.

### Action

**Erin:** Produce value-function plots and comparative-response checks.

No specific plotting design or deadline was assigned.

---

## 12. FDA policy questions and endogenous nicotine

**Policy-motivation discussion:** 52:23  
**Recovered-ξ suggestion:** 54:40  
**Investment-response question:** 55:23  
**Priority statement:** 56:24

### Erin’s proposed research questions

- Would nicotine trajectories have differed without FDA interventions?
- Could regulation have encouraged technological or marketing responses?
- Would JUUL have remained more dominant without particular interventions?

These were research questions and possible mechanisms, not established causal findings.

### Current model limitation

The solved baseline does not include endogenous nicotine choice.

Erin has intended to add endogenous A to study regulation.

### Marc’s feedback and reasoning

The central issue is how to map the policy intervention into the model.

Marc asked whether the effects of flavor restrictions and related changes should enter through:

- Nicotine, **A**, or
- Unobserved demand quality, **ξ**.

Erin associated the example with ξ, noting that nicotine content had not changed in that case.

### Suggested empirical exercise

Erin already recovers brand- and time-varying ξ but had not inspected it around FDA intervention.

Marc suggested examining that pattern at **54:40**.

A movement in recovered ξ would be informative, but the meeting did not establish a causal identification strategy for interpreting it as an FDA effect.

### Possible model extension

Keep ξ exogenous while making A endogenous.

Marc proposed asking:

> When FDA action reduces ξ, does JUUL invest more in A, or does its incentive to invest in A fall?

This was an open comparative-response question, not a prediction of either sign.

### Priority and agreed direction

At **56:24**, Marc said beginning to model endogenous A might be more important than the other three refinements.

Erin responded affirmatively.

### Open questions

- Nicotine investment or choice technology.
- Associated costs and dynamics.
- How regulation changes the model’s primitives.
- Whether the intervention acts through A, ξ, or both.
- Final counterfactual design and identification strategy.

---

## 13. Prospectus presentation

**Recommendations:** 56:58 and 57:22

### Explicitly accepted direction

- Focus on material where Erin wants feedback.
- Use **one slide** for the published paper with Larry.
- Spend most of the remaining time on this project.

### Possibility

Marc suggested that the second-year paper could receive approximately **two slides**. This was not a strict requirement.

### Action

**Erin:** Organize the prospectus presentation around the current project and the questions on which feedback is most useful.

---

## Decision and non-decision register

### Explicit commitments or clearly accepted directions

- Erin will revise and clarify the entry-process portion of the model.
- The one-period potential-entrant framework has no accumulating pool of unsuccessful entrants.
- A richer state space need not have every state reached in the sample.
- Value-function behavior should be inspected, not only convergence.
- Endogenous nicotine modeling is an important next direction.
- The prospectus should emphasize this project, with one slide for the published Larry paper.

### Recommendations or possibilities, not final specification choices

- Read Allan Collard-Wexler’s paper.
- Try 0.95 during development to speed convergence.
- Broaden state support, potentially outside the observed data.
- Inspect recovered ξ around FDA intervention.
- Keep ξ exogenous while making A endogenous.
- Consider a continuing stream of new potential entrants.
- Consider external shutdown information for event measurement.

### Not agreed in this meeting

- A final entrant-arrival rule or replacement mechanism.
- A final rule on permanent exit versus re-entry.
- Learning by doing.
- A new marginal-cost process.
- A replacement distribution for entry costs or scrap values.
- Mandatory zeroing of scanner sales after manufacturer shutdown.
- Proportional scaling of payoffs by Nielsen sales coverage.
- Adding market shares to the calibration targets.
- A final transition estimator.
- A final FDA counterfactual or a predicted sign of nicotine investment responses.

---

## Prioritized action list

Erin’s chosen work order is to complete entry-process revisions, value-function diagnostics, and estimation/state-support refinements first, then address endogenous nicotine and the associated FDA-policy questions. This updates the work order after the meeting; Marc emphasized endogenous nicotine as an important priority.

1. **Revise and pin down the entry process.**
   - Responsible: Erin.
   - Specify arrivals, the cap, waiting, disappearance, exit permanence, and characteristic revelation.
   - Keep the fringe separate from a pool of individually tracked prospective entrants.

2. **Inspect value functions and comparative responses.**
   - Responsible: Erin.
   - Plot values against state variables.
   - Change exogenous inputs and check economic plausibility.

3. **Refine estimation and broaden state support.**
   - Responsible: Erin.
   - Clarify targets, parameter scaling, and sensitivity.
   - Consider finer grids and support beyond observed states.
   - Do not assume that adding market-share targets was agreed.

4. **Read Allan Collard-Wexler’s paper and examine recovered ξ around FDA intervention.**
   - Responsible: Erin.
   - Use the paper to clarify entry/exit modeling choices.
   - Treat the ξ exercise as exploratory unless supported by an identification strategy.

5. **Focus the prospectus presentation on this project.**
   - Responsible: Erin.
   - One slide for the published Larry paper.
   - Brief coverage of the other work.
   - Emphasize questions where feedback is needed.

6. **Begin specifying endogenous nicotine choice or investment.**
   - Responsible: Erin.
   - Define how the policy question maps into A and ξ.
   - Treat the direction of the investment response as a question.

## Remaining implementation checks

These are unresolved substantive issues, not transcription uncertainties:

- Confirm how fringe price and quality are represented in the code.
- Specify the final entrant-arrival and replacement rules.
- Clarify discounting conventions before implementing the 0.95 development exercise.
- Decide how sparse and out-of-sample state transitions will be constructed.
- Establish monetary scaling and calibration targets appropriate to partial Nielsen coverage.

The previously flagged literature references and demand terminology have been resolved using Erin’s clarifications. The table-reading exchange and passages Erin marked unimportant do not require further manual transcription review for these notes.