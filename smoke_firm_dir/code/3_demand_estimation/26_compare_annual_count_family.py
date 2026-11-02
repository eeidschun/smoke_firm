"""Compare all 24 saved Annual-instrument, weighted-price, no-FE fits."""
from pathlib import Path
import csv
root=Path('smoke_firm_dir');meeting=root/'docs/meetings';tables=meeting/'tables'
saved=root/'output/demand_estimation/sales_weighted_tax_2026-10-27/sales/original_48_grid'
def read(name):
    with (saved/name).open() as f:return list(csv.DictReader(f))
def write(name,rows):
    with (tables/name).open('w') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
sp=[r for r in read('specifications.csv') if r['firm_FE']=='FALSE' and r['price_measure']=='p_it_volume_weighted' and r['instrument_set']=='Annual']
assert len(sp)==24
sp.sort(key=lambda r:(r['sample'],['B','S','V','SV'].index(r['controls']),['annual','monthly','constant'].index(r['market'])))
ids={r['id'] for r in sp};designs={r['design_id'] for r in sp}
cc=[r for r in read('coefficients.csv') if r['id'] in ids];fs=[r for r in read('first_stage_coefficients.csv') if r['design_id'] in designs]
c={(r['id'],r['term']):r for r in cc};f={(r['design_id'],r['outcome'],r['term']):r for r in fs}
wide=[]
for r in sp:
    row=dict(r)
    for label,term in [('alpha','fit_price'),('sigma','fit_ln_s_i_g'),('quality','a_it')]:
        for col in ['estimate','std_error','ci_low','ci_high']:row[f'{label}_{col}']=c[r['id'],term][col]
    for outcome in ['price','ln_s_i_g']:
        row[f'{outcome}_SW_F']=f[r['design_id'],outcome,'TaxIV_geo']['SW_F']
    row['negative_alpha']=float(row['alpha_estimate'])<0
    row['alpha_CI_below_zero']=float(row['alpha_ci_high'])<0
    row['sigma_CI_inside_0_1']=float(row['sigma_ci_low'])>0 and float(row['sigma_ci_high'])<1
    wide.append(row)
write('2026-10-27_annual_count_all24_comparison.csv',wide)
write('2026-10-27_annual_count_all24_coefficients.csv',cc)
write('2026-10-27_annual_count_all24_first_stages.csv',fs)
cell=lambda id,term:f"{float(c[id,term]['estimate']):.4f} ({float(c[id,term]['std_error']):.4f})"
text='''## 2. Compare all 24 specifications in the annual-incumbent-count family

### Question and reason for shortlisting

Compare all candidates within **volume-weighted prices + no firm FE + sales-weighted tax + annual incumbent count**, before choosing a provisional national demand specification for supply-side work. **This family was shortlisted because it is one of the most successful families by the frequency of admissible sigma point estimates:** 24/24 qualify and 20/24 also have negative alpha. Other families tie on sigma qualification. This criterion does not establish instrument validity or select a final specification.

The earlier illustration focused prematurely on both product controls. The full choice set is **four control groups × three market sizes × two samples = 24**. There are 12 substantive control/market combinations; the second sample checks sensitivity to dropping four rows.

### Common specification

- National incumbent firm-month observations; price is real revenue / eligible liquid volume.
- Price and within-nest log share jointly endogenous. Excluded instruments: brand-specific current liquid-volume-weighted state tax and annual national incumbent count (>7% annual volume share).
- Current nicotine quality is included and treated as exogenous in all runs. B: nicotine only; S: plus mean device size; V: plus log UPC variety; SV: both.
- Intercept, no firm FE, no month FE; SEs clustered by month. Exactly identified (two excluded instruments / two endogenous regressors).
- Available sample: 528 complete-size rows / 132 months. Common-lag sample: 524 rows / 131 months. No lagged-quality instrument is used in these 24 runs; the smaller sample is a comparability check only. All control groups retain the same complete-size sample rule.
- Annual, monthly, and constant intensity use the existing market-size definitions.

### All 24 estimates

Entries are coefficient (month-clustered SE). Quality is current delivered nicotine. Every sigma point estimate below lies in (0,1).

'''
for sample,title in [('available','Available sample: 528 rows'),('common_lag','Common-lag sample: 524 rows')]:
    text+=f'**{title}**\n\n| Controls | Market intensity | Price alpha (SE) | Sigma (SE) | Quality (SE) |\n|----------|------------------|----------------:|-----------:|-------------:|\n'
    for r in sp:
        if r['sample']!=sample:continue
        text+='| '+r['controls']+' | '+r['market']+' | '+' | '.join(cell(r['id'],t) for t in ['fit_price','fit_ln_s_i_g','a_it'])+' |\n'
    text+='\n'
neg=sum(r['negative_alpha'] for r in wide);signeg=sum(r['alpha_CI_below_zero'] for r in wide);inside=sum(r['sigma_CI_inside_0_1'] for r in wide)
text+=f'''### Patterns and qualifications

- **Sigma:** all 24 point estimates qualify, ranging from {min(float(r['sigma_estimate']) for r in wide):.3f} to {max(float(r['sigma_estimate']) for r in wide):.3f}. However, **{inside}/24 conventional 95% intervals lie wholly within (0,1)**; all extend above 1.
- **Price:** {neg}/24 alpha estimates are negative. The four positive estimates are the monthly-intensity V and SV runs in both samples. Only {signeg}/24 price intervals are entirely below zero: the eight constant-intensity runs and the available-sample B/annual run. All other annual/monthly price intervals include zero; B/annual loses that exclusion of zero on the common-lag sample.
- **Variety control:** with annual or monthly intensity, including log UPC variety (V or SV) shifts alpha toward zero or slightly positive. Without variety (B or S), these price estimates are more negative, but remain imprecise. This sensitivity does not by itself justify dropping variety.
- **Market size:** constant intensity gives substantially more negative alpha in every control group (approximately −0.32 to −0.40). Do not adopt this market-size assumption solely to obtain the desired price sign.
- **Quality:** every quality point estimate is positive; all 24 conventional 95% quality intervals are above zero.
- **Sample sensitivity:** the smaller sample leaves the main sign patterns unchanged. The B/annual price interval narrowly excludes zero in the available sample but includes it in the smaller sample. The smaller sample contains no additional lag instrument and is not independent evidence.

### First-stage diagnostics by control group and sample

First stages are identical across the three market sizes within a control/sample combination. Tax coefficients are estimate (SE); F values below are SW conditional F for each endogenous regressor. Full instrument and control coefficients, ordinary joint F, and conditional-F details are exported.

| Sample | Controls | Tax → price (SE) | Price SW F | Share SW F |
|----------------|----------|---------------------:|-----------:|-----------:|
'''
for r in sp:
    if r['market']!='annual':continue
    z=f[r['design_id'],'price','TaxIV_geo'];share=f[r['design_id'],'ln_s_i_g','TaxIV_geo']
    text+=f"| {r['sample']} | {r['controls']} | {float(z['estimate']):.3f} ({float(z['std_error']):.3f}) | {float(z['SW_F']):.2f} | {float(share['SW_F']):.2f} |\n"
text+='''
Tax–price slopes remain negative in all eight designs. Conditional F does not establish instrument exclusion or calibrated weak-IV-robust inference. Exact identification leaves no overidentifying restrictions to test. Both sales-based tax weights and sales-share-threshold counts require an exclusion argument.

### Interpretation and next decision

No final specification has been selected. For annual-intensity market size, B and S deserve comparison with V and SV because their price slopes are less close to zero; all remain uncertain. Constant-intensity candidates have more clearly negative price slopes, but require substantive support for their denominator. We should choose the controls and market-size assumption explicitly before attempting supply-side recovery, rather than choose solely by admissible sigma or significance. All saved estimates and canonical inputs remain unchanged.

### Files

[All 24 specifications with confidence intervals and diagnostics](tables/2026-10-27_annual_count_all24_comparison.csv), [all coefficients](tables/2026-10-27_annual_count_all24_coefficients.csv), and [complete first stages](tables/2026-10-27_annual_count_all24_first_stages.csv). These supersede the six-run illustration as the main shortlist comparison. Extraction script: `code/3_demand_estimation/26_compare_annual_count_family.py`; no regressions were rerun.

'''
assert neg==20 and signeg==9 and inside==0
assert all(float(r['sigma_ci_high'])>1 and float(r['quality_ci_low'])>0 for r in wide)
p=meeting/'marc_mtg_TBD.md';s=p.read_text();a=s.index('## 2. ');b=s.index('## Questions for Marc',a)
p.write_text(s[:a]+text+s[b:])
print('Compared all 24; Section 2 updated. Negative alpha:',neg,'; alpha CI below zero:',signeg,'; sigma CI fully admissible:',inside)
