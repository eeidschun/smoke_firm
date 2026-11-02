"""Extract saved candidate estimates and populate Section 2; no re-estimation."""
from pathlib import Path
import csv
root = Path('smoke_firm_dir')
saved = root / 'output/demand_estimation/sales_weighted_tax_2026-10-27/sales/original_48_grid'
meeting = root / 'docs/meetings'
def read(name):
    with (saved / name).open() as f:
        return list(csv.DictReader(f))
def write(name, rows):
    with (meeting / 'tables' / name).open('w') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
sp = [r for r in read('specifications.csv') if r['controls']=='SV' and r['firm_FE']=='FALSE' and r['price_measure']=='p_it_volume_weighted' and r['instrument_set']=='Annual']
assert len(sp)==6
ids={r['id'] for r in sp}; designs={r['design_id'] for r in sp}
coefs=[r for r in read('coefficients.csv') if r['id'] in ids]
first=[r for r in read('first_stage_coefficients.csv') if r['design_id'] in designs]
write('2026-10-27_annual_count_shortlist_specifications.csv',sp)
write('2026-10-27_annual_count_shortlist_coefficients.csv',coefs)
write('2026-10-27_annual_count_shortlist_first_stages.csv',first)
lookup={(r['id'],r['term']):r for r in coefs}
def cell(id, term):
    r=lookup[id,term]
    return f"{float(r['estimate']):.4f} ({float(r['std_error']):.4f})"
primary={r['market']:r for r in sp if r['sample']=='available'}
assert len(primary)==3
text='''## 2. Provisional candidate from a consistently qualifying family

### Question and reason for shortlisting

Inspect a concrete national firm-month specification before provisionally choosing demand parameters for supply-side work. **This candidate was shortlisted because it belongs to one of the most successful families by the frequency of admissible sigma point estimates:** volume-weighted prices, no firm FE, sales-weighted taxes, and tax + annual incumbent count. That instrument family has 0 < sigma < 1 in 24/24 runs, with negative alpha in 20/24. It is tied with other families on sigma qualification; it was not selected by a formal model-ranking criterion. Both device-size and variety controls are included as a starting candidate, not because this particular control combination has been established as best.

### Exact specification

- **Unit and price:** national incumbent firm-month; firm real revenue / eligible liquid volume.
- **Endogenous regressors:** price and within-nest log share, jointly instrumented.
- **Excluded instruments:** sales-weighted state tax and annual national incumbent count (>7% annual eligible liquid-volume share). Exactly identified: two excluded instruments for two endogenous regressors.
- **Included exogenous controls:** current nicotine quality, mean device size, and log UPC variety; intercept included.
- **Fixed effects:** none; no month FE. SEs clustered by month.
- **Primary sample:** 528 complete-size observations / 132 months. No lag instrument, so no lag-availability exclusion is needed. The corresponding 524-row / 131-month common-lag versions are exported as sample-sensitivity comparisons.
- **Initial market size:** annual-intensity baseline, compared below with monthly and constant intensity. All three use the existing population and NCP definitions.

### Estimates across market-size variants

Entries are coefficient (month-clustered SE), on the same 528-row sample.

| Parameter | Annual intensity | Monthly intensity | Constant intensity |
|------------------------------|-----------------:|-----------------:|-----------------:|
'''
for title,term in [('Price alpha','fit_price'),('Sigma','fit_ln_s_i_g'),('Nicotine quality','a_it'),('Device size','avg_ml_per_ecig'),('Log UPC variety','log_upc_variety'),('Intercept','(Intercept)')]:
    text+='| '+title+' | '+' | '.join(cell(primary[m]['id'],term) for m in ('annual','monthly','constant'))+' |\n'
a=primary['annual']['id'];sig=lookup[a,'fit_ln_s_i_g'];alpha=lookup[a,'fit_price']
text+='''
All three sigma point estimates qualify, but their conventional 95% intervals extend above 1. The annual baseline's interval is '''+f"**{float(sig['ci_low']):.3f} to {float(sig['ci_high']):.3f}**"+'''. Its price coefficient is negative but very close to zero and imprecise (95% interval '''+f"{float(alpha['ci_low']):.3f} to {float(alpha['ci_high']):.3f}"+'''). The monthly-intensity price coefficient is positive. The constant-intensity variant has a clearly negative price coefficient, but changes to market size require a substantive rationale; it has not been adopted simply because of that sign.

### First-stage diagnostics

First stages are identical across the three market sizes because only the demand outcome changes. Full-sample estimates:

| Diagnostic | Price first stage | Within-nest log-share first stage |
|----------------------------------------------|---------------------:|---------------------:|
'''
first0={(r['outcome'],r['term']):r for r in first if r['design_id']==primary['annual']['design_id']}
for title,term in [('Sales-weighted tax coefficient (SE)','TaxIV_geo'),('Annual incumbent count coefficient (SE)','incumbent_annual')]:
    vals=[f"{float(first0[o,term]['estimate']):.4f} ({float(first0[o,term]['std_error']):.4f})" for o in ('price','ln_s_i_g')]
    text+='| '+title+' | '+' | '.join(vals)+' |\n'
for title,col in [('Joint excluded-instrument F','ordinary_F'),('SW conditional F','SW_F')]:
    text+='| '+title+' | '+' | '.join(f"{float(first0[o,'TaxIV_geo'][col]):.2f}" for o in ('price','ln_s_i_g'))+' |\n'
text+='''
The conditional tax–price coefficient remains negative. This is within the issue the advisor agreed to revisit later. Conditional F values are descriptive diagnostics, not proof of exclusion validity or weak-IV-robust inference. Exact identification leaves no overidentifying restrictions to test. Current sales-based tax weights and the annual sales-share threshold still need an exclusion argument.

### Interpretation and next decision

**This is a shortlist candidate, not a final supply-side selection.** Its annual-baseline sigma is admissible, and the quality slope is positive, but the near-zero price slope is a material concern for supply-side markups and cost recovery. Do not proceed automatically to cost recovery from this candidate; discuss whether to compare other controls, instruments, or market-size assumptions next. No parameters or canonical models have been replaced.

The common-lag sample gives annual alpha −0.0040 (SE 0.0397) and sigma 0.8008 (SE 0.1871), so dropping the four rows does not remove the main concern.

### Files

Extracted [specifications](tables/2026-10-27_annual_count_shortlist_specifications.csv), [all coefficients and confidence intervals](tables/2026-10-27_annual_count_shortlist_coefficients.csv), and [first stages and diagnostics](tables/2026-10-27_annual_count_shortlist_first_stages.csv) contain all six saved fits and both sample versions. Extraction script: `code/3_demand_estimation/25_shortlist_annual_count.py`; no models were re-estimated.

'''
p=meeting/'marc_mtg_TBD.md';s=p.read_text()
if '## 2. Provisional candidate' in s:
    start=s.index('## 2. Provisional candidate');end=s.index('## Questions for Marc',start);s=s[:start]+s[end:]
assert s.count('## Questions for Marc')==1
p.write_text(s.replace('## Questions for Marc',text+'## Questions for Marc'))
print('Section 2 and three candidate tables written.')
