# ChatGPT prompt — verify imputed e-cigarette specs

Paste everything below the line into ChatGPT (use a model with web browsing enabled),
and attach `imputed_values_to_verify.csv`.

---

You are helping verify product specifications for e-cigarette / vape products sold in
U.S. retail stores. I have a CSV (`imputed_values_to_verify.csv`) where some values
were **estimated** and I need you to check them against real-world sources using web search.

## Your task
For each row, identify the actual product from `brand_filled` + `product_line` +
`product_descr` (the `upc` is included for reference, but UPC-number searches are often
unreliable — search by brand and product name instead). Then use web search
(manufacturer sites, retailer product pages, FDA/PMTA filings, reputable vape retailers)
to find and verify these attributes:

1. **mL per cartridge/pod/device** (the e-liquid volume of one cartridge, pod, or disposable)
2. **number of cartridges/pods per package**
3. **total mL per package** (= mL per cartridge × number per package)
4. **nicotine strength** — report BOTH as a percentage and as mg/mL (5% = 50 mg/mL,
   2.4% = 24 mg/mL, etc.)
5. **brand** (confirm or correct `brand_filled`)
6. **device type**, using EXACTLY one of these three categories:
   - `Disposable` = a single, all-in-one unit (battery + e-liquid sealed together),
     used until empty then thrown away (e.g. Breeze, Hyppe, Loon, Esco Bar, Bidi Stick).
   - `Closed pod` = a pre-filled sealed pod or cartridge that attaches to a REUSABLE
     battery you keep (e.g. VUSE Alto, JUUL, NJOY Ace, Logic).
   - `Open refill` = bottled e-liquid or a refillable tank the user fills themselves.

## Compare to my estimates
Each row has my estimated values in the `imputed_*` columns. Judge each row:
- `CONFIRMS` — your findings match my estimates (within ~10% on mL and nicotine).
- `CONTRADICTS` — your findings clearly differ; give the corrected values.
- `PARTIAL` — some fields match, others differ.
- `UNVERIFIABLE` — you could not find a reliable source. **Do NOT guess** — mark it
  UNVERIFIABLE rather than inventing a value.

## Rules
- Only report a value you found in a real source. Never fabricate specs or URLs.
- For every `CONFIRMS`, `CONTRADICTS`, or `PARTIAL`, include at least one `source_url`.
- Keep `row_id` and `upc` EXACTLY as given (treat `upc` as text; preserve leading zeros).
- Do not drop, merge, or reorder rows. Return one output row per input row.
- Work in priority order: do `priority = 1-CHECK` first, then by `total_units` descending.
  If you can't finish all 630 rows, finish the highest-volume ones and mark the rest
  `UNVERIFIABLE` with note "not yet reviewed".

## Output
Produce a downloadable CSV file named **`verified_values.csv`** with EXACTLY these
columns, in this order:

`row_id, upc, verified_brand, verified_device_type, verified_mL_per_cartridge,
verified_num_cartridges, verified_total_mL, verified_nic_pct, verified_nic_mg_per_ml,
assessment, confidence, source_url, notes`

- `verified_device_type`: one of Disposable / Closed pod / Open refill / Unknown.
- `verified_nic_pct` in percent (number only, e.g. `5`); `verified_nic_mg_per_ml` in mg/mL (e.g. `50`).
- `assessment`: CONFIRMS / CONTRADICTS / PARTIAL / UNVERIFIABLE.
- `confidence`: High / Medium / Low.
- `source_url`: one or more URLs, separated by `;`.
- Leave a cell blank (empty) if unknown. Output valid CSV (quote fields containing commas).
