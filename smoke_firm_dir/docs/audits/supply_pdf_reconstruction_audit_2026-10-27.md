# Supply-document reconstruction audit

Audit date: October 27, 2026.

## Conclusion and scope

The current documents are **revised reconstructions, not exact transcriptions or facsimiles**. The section-by-section audit accounts for the original model's eight sections, concentration table and chart, and the appendix's scope, demand/pricing systems, transition construction, dynamic equations, both algorithms, worked examples, and notation. Some explanatory passages were compressed in the first reconstruction. Historical definitions and algorithm details identified below have now been restored explicitly; intentional equation/model changes and draft corrections are listed separately.

No additional substantive omission was identified after those restorations. That is a manual content-audit conclusion, not a claim of verbatim equivalence or proof that the model's empirical or dynamic assumptions are valid. Text under overlapping PDF layers can be duplicated or incomplete in extraction; rendered pages and the full extracted text were used together. Historical claims have not been independently re-estimated, and bibliographic attributions have not been externally verified.

## Compared files

- Original [conference model](../source_archive/pre_reconstruction/ec_supply_conference_model.pdf) → current [LaTeX](../ec_supply_conference_model.tex) and [PDF](../ec_supply_conference_model.pdf).
- Original [solution appendix](../source_archive/pre_reconstruction/ec_supply_solution_appendix.pdf) → current [LaTeX](../ec_supply_solution_appendix.tex) and [PDF](../ec_supply_solution_appendix.pdf).
- Rebuild: `bash smoke_firm_dir/docs/build_supply_documents.sh`.
- Reproducible checks: [check_supply_reconstruction.py](check_supply_reconstruction.py); [results and SHA-256 fingerprints](supply_reconstruction_checks_2026-10-27.json).

Original PDFs are unchanged. Their page counts are six (model) and seven (appendix). The audited revised PDFs are also six and seven pages, respectively; matching page counts does not imply matching pagination or text.

## Conference model: content inventory

| Original location / content | Current location | Audit disposition |
|---|---|---|
| Title, author, draft purpose | Title and opening paragraphs | Preserved; reconstruction date/provenance added. |
| §1: small-N market, concentration and turnover motivation | §1 | Preserved in substance; causal language qualified as motivation rather than identification. |
| Figure 1: annual composition, labels, leader stars, legend | Figure 1 | Same chart embedded directly from archived original page 1; cropped around the chart, with a fresh caption. No redrawing or data regeneration. |
| Table 1: 2013–2023 leader, share, runner-up, CR3, HHI | Table 1 | All 11 rows / 66 cells checked against original extracted table and preserved. |
| CR3 residual narrative and August 27 diagnostic reference | §1, third motivating pattern | Historical numeric claims now explicitly preserved as disputed claims, rather than silently dropped. Original narrative conflicts with its table; see corrections below. |
| U-shaped HHI, innovation/FDA interpretation | §1, after table | Values and timing retained; interpretation identified as hypothesis, not a causal result. Original DOJ classification language not adopted as a verified regulatory statement. |
| §2: players, monthly timing, one entrant, proposed five-firm cap | §2 | Timing and entrant retained. Cap distinguished from empirical 3–6 incumbent roster; unresolved contradiction flagged. |
| Exogenous quality/residual Markov proposal and fringe process | §§2, 6 | Incumbent law retained as proposed dynamics. Historical fringe-quality-only state superseded by revised fringe utility; dynamic fringe law left unresolved. Historical 2021 panel correction claim retained as requiring a builder-status check in §7. |
| §3: free quality coefficient, mean utility, common nest, outside option | §3 | Preserved with signed alpha, demand intercept, explicit share equations and inversion. |
| October 7 price/volume overlay: eligibility and equal-UPC pricing | §3, historical retail construction | Preserved, including the exact price-times-volume discrepancy identity and unchanged NCP input. |
| Historical tax formula, active-brand count definitions, FE and clustering | §3, historical instrument definitions and exclusions | **Restored during audit:** population-weight formula; national versus union-of-operating-states counts; focal/fringe inclusion; historical FE comparison, no month FE, clustering, distinction from annual incumbent count. |
| Capacity/variety diagnostics and incomplete-size exclusions | Same paragraph | **Restored during audit:** explicit device-size and variety constructions and missing-size sample exclusion/reporting rule. |
| §4: static firm profit, quantity, simultaneous pricing, market-size cancellation | §4 | Preserved; signed-alpha markup formula and qualifications added. Passive fringe replaces ambiguity about a possibly pricing fringe. |
| §5: Bellman, exit/entry comparisons and indicator notation | §5 | Retained. Fixed-cost/private-draw inconsistency explicitly flagged; no new information structure chosen. |
| Rivals' exits/entry affect own continuation value | §5 | Preserved; deterministic versus probabilistic policies distinguished. |
| MarkTen/MISTIC ownership exits carved out of identification sample | §5, exit sample | **Restored during audit:** explicit statement of original carve-out and proposed identifying sample, labeled historical and subject to confirmation; not replaced by an undisclosed new sample decision. |
| §6: passive fringe, no Bellman equation, quality-only utility | §6 | Passive role preserved. Utility restriction intentionally replaced by full calibrated utility, following user decision. |
| §7: investment, regulation through investment costs, EBE motivation | §7 | Preserved; no investment implemented or new transition assumptions adopted. |
| Dropped learning-cost interpretation | §7 | Historical cohort distinction and price/cost identification limitation retained. |
| Share-threshold entry/exit question; NJOY gap at 10%; six-firm years | §§2, 7 | Core question and NJOY 7.6% diagnostic retained. Contradictory “five never binds” claim flagged, not repeated as fact. |
| Strategic fringe extension | §7 | Preserved as deferred extension. |
| Legacy-brand bias and proposed post-exit correction | §§6, 7 | Magnitudes, threshold, pre/post separation, and not-implemented status retained. **Restored during audit:** equal-UPC fringe-quality definition and original report that other tracked post-exit effects were negligible. |
| Functional nicotine costs / ownership versus quality | §7 | Preserved as unresolved questions. |
| §8 references | §8 | Original named framework references retained; original Ericson–Pakes 1994/1995 inconsistency identified for later bibliographic checking. |

## Solution appendix: content inventory

| Original location / content | Current location | Audit disposition |
|---|---|---|
| Scope: three solved objects and outer algorithm | Scope and §§1–5 | Preserved; static decisions separated from future dynamics. |
| §1 equations (1)–(4): conditional share, denominator, inclusive value, nest and unconditional shares | Current equations (2)–(4) | Algebraically preserved; outside share made explicit. |
| Mean utility and quality coefficient interpretation | Current equation (1) and demand text | Signed alpha and intercept added consistently. Distinction between observed quality and residual preserved. |
| Equations (5)–(6): own/cross price derivatives | Current equations (5)–(6) | Signs transformed consistently under alpha_new = −alpha_old; numerically checked. |
| Multinomial-logit limiting check at sigma = 0 | Immediately after derivatives | Preserved under new sign convention. |
| Aggregate-data estimation explanation, inversion versus consumer-level likelihood | §1, demand estimation | **Restored during audit:** why aggregate shares motivate inversion/IV rather than direct use of consumer-choice likelihood on aggregate observations. |
| Estimation steps and original equation (7) | Current equation (7), steps 1–3 | Share construction, joint IV estimation, quality treatment, residual recovery preserved. Intercept and signed alpha updated. |
| Original fringe-only-quality step / no exact fringe fit | Current equation (8), step 4 | Explicitly superseded by user-approved fringe utility calibration. Fringe remains excluded from incumbent regression, not from share totals. |
| Aggregate residual versus individual taste disturbance | §1, following estimation steps | Core distinction preserved. Original shorthand describing IID individual errors is not reproduced as an additional nested-logit assumption; no new consumer-level error model selected. |
| Retail construction overlay, capacity/variety and market-size diagnostics | §1, price construction | Historical convention retained and distinguished from current provisional calibration. Full detailed exclusions/formula are in companion model §3. |
| §2 equation (8): profit maximization and quantity | Current equation (9) | Preserved; marginal costs renamed `mc` to distinguish from demand intercept `c`. |
| Equation (9): simultaneous markup FOCs | Current equations (10)–(11) | Same economic FOC after alpha reparameterization, with intermediate `A_i` definition. |
| Equation (10): price fixed-point iteration | Current equation (13) | Original undamped iteration recovered at damping = 1; damping and residual/deviation checks added. “Best response” wording corrected to markup substitution. |
| Fallback Newton / Morrow–Skerlos discussion | §2, following manual iteration | Retained as historical alternatives; automatic/package fallback not adopted, consistent with user request. |
| Two-incumbent + fringe worked system | §2, two-incumbent example | Denominator, conditional/nest/firm shares and two price FOCs retained explicitly. Price-dependent incumbent utilities corrected; fixed inputs are non-price utility components. |
| §3 state grid, equation (11), entrant initial state | Current equation (14), §3 | Retained as proposed extension; revised full state includes fringe utility and needed shifters. No literal integer-valued-quality requirement imposed. |
| Permanent/absorbing exit and entrant becomes incumbent | §3 opening | **Restored during audit:** absorbing economic exit and subsequent incumbent value explicitly stated; threshold reclassification distinguished. |
| Five transition-estimation steps; equation (12) | §3 steps and current equation (15) | Grid, continuing pairs, pooled counts, row normalization, sparse cells retained. Calendar-month matching and eligible-successor denominator clarified. |
| Original fringe transition `F_F` from measured quality | §3 | Historical approach now insufficient with richer fringe utility; need revised fringe law explicitly noted rather than choosing one. |
| §4 equation (13): Bellman | Current equation (16) | Preserved under labeled fixed/known-cost interpretation; private draws left unresolved. |
| Equations (14)–(16): exit indicator, entry comparison, entry indicator | Current equations (17)–(18) and accompanying text | Comparisons preserved; claim of automatic monotonic cutoff in each state coordinate qualified. Entrant initial draw and incumbent value interpretation retained. |
| Naming rationale avoiding eta-prime, chi, sigma | §4 | **Restored during audit:** named draft notation rationale (including Doraszelski–Pakes–Satterthwaite), marked as unverified bibliographic attribution. |
| Algorithm 1: nested policy/value iteration | §4 policy/value fixed point and explicit-iteration paragraph | **Restored during audit:** explicit Bellman update over next-state sum, initialization, inner absolute sup-norm tolerance, policy updates and outer stopping rule. Own continuation conditioning clarified; no guarantee of outer convergence. |
| Inner contraction / recurrent-state computational motivation | Same subsection | Preserved with bounded-payoff/kernel assumptions; EBE motivation retained. |
| Two-incumbent roster transition worked example | §4 worked roster example | Both continue/no entry and exit-plus-entry cases retained, with product kernels. Fringe/exogenous-input transitions and private-cost roster probabilities explicitly qualified. |
| §5 Algorithm 2: static solve → dynamic solve → simulation/moments | §5 | All steps retained as numbered prose. |
| Caching static prices/profits across dynamic parameter changes | §5 | Retained; unchanged grid/current pricing inputs required. |
| Original notation table | Notation | All main objects mapped; `mc` distinguishes cost, alpha sign explicit, full-state/fringe components expanded. Old quality-only fringe and cap shorthand intentionally qualified. |

## Changes that are intentional, not transcription matches

1. **Authorized sign change:** all mean utility and inversion equations use `+ alpha * price` with alpha negative. Own derivative becomes `alpha*s_i*A_i`; cross derivative becomes `−alpha*s_i*[sigma*s_j|g/(1−sigma)+s_j]`; markup becomes `−1/(alpha*A_i)`. This is a reparameterization of the original positive price sensitivity, not a different demand response.
2. **Authorized fringe change:** include fringe price/unobserved quality, recover total fringe utility by inversion, hold utility fixed within a month. Its share still changes as incumbent prices change. The original quality-only fringe law is not silently retained in dynamics.
3. **Current calibration added:** demand intercept and chosen nicotine-only, sales-weighted-price/tax, no-FE, constant-intensity estimates. These were not in the original PDF. Historical equal-UPC and population-weighted-tax construction remains labeled historical.
4. **Manual numerical approach clarified:** damped markup iteration and diagnostics added; no black-box equilibrium solver implemented. Successive substitution is not an exact best-response mapping, and convergence is not proof of Nash equilibrium.
5. **Editorial mathematical corrections, explicitly flagged:** fixed incumbent utility versus price-dependent utility in the two-firm example; market-size cancellation conditional on utility inputs; proper absolute stopping norms; fixed-policy evaluation versus optimal own Bellman response; unsupported state-coordinate monotonicity. These are not new estimated results.
6. **Original contradictions retained as unresolved issues:** five-firm cap versus six incumbents; known costs versus private draws; residual-below-CR3 narrative versus concentration table. In particular, the original says “most years,” not “always”; that wording was corrected during this audit. No dynamic information structure or cap resolution was chosen.
7. **Historical assertions qualified:** ownership exits, fringe-quality correction status, causal turnover explanations, old legal concentration labels, and bibliography have not been independently verified. Their factual content is preserved where relevant as historical claims; stronger unsupported interpretations are not presented as established findings.

## Checks and limits

- Compared unique extracted passages with each reconstructed section; removed duplicate layers were not counted as omitted content.
- Checked all 11 concentration-table rows / 66 cells against the original PDF text.
- Chart is embedded from the original archived page, preserving the original image/labels rather than recreating it. Visually checked the crop and caption.
- Checked own/cross price derivatives numerically in 48 synthetic states at sigma = 0, 0.3, 0.869475559477503, and 0.95; maximum absolute derivative error was below 2.4e-10. Checked old/new sign equivalence, share inversion including fringe, markup FOC, and cost-recovery identity.
- Recompiled sources twice to resolve equation/figure references and checked the final rendered PDFs. The section and equation numbering is a reconstruction, not the old pagination.
- These checks do not estimate costs, solve a pricing equilibrium, validate instruments, establish economic equilibrium uniqueness, verify references, or choose future Markov laws. They establish content traceability and consistency of the revised demand/pricing algebra.

## Subsequent decision: vertically integrated pricing

After this audit, the user chose to model each brand as a vertically integrated firm choosing retail prices. Both current sources and PDFs now explicitly interpret recovered costs and profits as integrated-channel objects, with no separate wholesale/retailer stage. This supersedes the earlier unresolved vertical interpretation; archived originals remain unchanged.
