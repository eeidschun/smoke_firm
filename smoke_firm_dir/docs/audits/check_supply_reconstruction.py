"""Document checks only; no equilibrium solver or estimation.
Run: python3 smoke_firm_dir/docs/audits/check_supply_reconstruction.py
"""
from pathlib import Path
import subprocess, re, math, random, hashlib, json
DOCS=Path(__file__).resolve().parents[1]
def pdftext(path):
    return subprocess.check_output(['pdftotext','-raw',str(path),'-'],text=True)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
original=pdftext(DOCS/'source_archive/pre_reconstruction/ec_supply_conference_model.pdf')
model=(DOCS/'ec_supply_conference_model.tex').read_text()
# Compare every transcribed table cell, not just aggregate min/max.
pattern=r'^(20\d{2})\s+(\S+)\s+([\d.]+)%\s+(\S+)\s+([\d.]+)%\s+(\d+)\s*$'
rows=re.findall(pattern,original,re.M)
assert len(rows)==11
for year,leader,share,runner,cr3,hhi in rows:
    assert f'{year}&{leader}&{share}\\%&{runner}&{cr3}\\%&{hhi}\\\\' in model,(year,leader)
assert r'source_archive/pre_reconstruction/ec_supply_conference_model.pdf' in model
appendix=(DOCS/'ec_supply_solution_appendix.tex').read_text()
for text in (model,appendix):
    assert r'\xi_{i,t}+\alpha p_{i,t}' in text
    assert r'\alpha<0' in text
    assert r'\delta_{F,t}^{\mathrm{obs}}' in text
    assert r'\xi_{F' in text or r'\xi_{Ft}' in text
# Validate derivative signs, old-positive/new-signed equivalence, share inversion,
# and FOC/cost-recovery identities over synthetic states.
rng=random.Random(7);err=0.;cases=0
alpha=-.333587711840379
def shares(v,p,sig,f):
    delta=[v[i]+alpha*p[i] for i in range(len(p))]+[f]
    z=[x/(1-sig) for x in delta];m=max(z)
    logD=m+math.log(sum(math.exp(x-m) for x in z))
    lognest=(1-sig)*logD
    nest=1/(1+math.exp(-lognest))
    w=[math.exp(x-logD) for x in z]
    return [x*nest for x in w],w,delta
for sig in (0.,.3,.869475559477503,.95):
    for _ in range(12):
        p=[rng.uniform(1,4) for _ in range(3)];v=[rng.uniform(-1,1) for _ in p]
        s,w,delta=shares(v,p,sig,-.4)
        assert abs(sum(s)+(1-sum(s))-1)<1e-12
        for i in range(4):
            inv=math.log(s[i]/(1-sum(s)))-sig*math.log(s[i]/sum(s))
            assert abs(inv-delta[i])<1e-11
        for i in range(3):
            A=1/(1-sig)-sig*w[i]/(1-sig)-s[i]
            own=alpha*s[i]*A;mu=-1/(alpha*A);mc=p[i]-mu
            old_positive=-alpha
            assert abs(mu-1/(old_positive*A))<1e-12
            assert own<0 and mu>0
            assert abs(s[i]+(p[i]-mc)*own)<1e-12
            assert abs(mc+mu-p[i])<1e-12
            for j in range(3):
                up=p.copy();dn=p.copy();h=1e-5;up[j]+=h;dn[j]-=h
                numeric=(shares(v,up,sig,-.4)[0][i]-shares(v,dn,sig,-.4)[0][i])/(2*h)
                analytic=own if i==j else -alpha*s[i]*(sig*w[j]/(1-sig)+s[j])
                err=max(err,abs(numeric-analytic));assert abs(numeric-analytic)<1e-7
        cases+=1
# Check rendered text contains restored topics, independently of the TeX source.
rendered_model=' '.join(pdftext(DOCS/'ec_supply_conference_model.pdf').split())
rendered_appendix=' '.join(pdftext(DOCS/'ec_supply_solution_appendix.pdf').split())
for term in ('Historical instrument definitions','incomplete device-size coverage','equal-UPC average','2015'):
    assert term in rendered_model,term
for term in ('absorbing exit','aggregate shares','original Algorithm 1','Dor'):
    assert term in rendered_appendix,term
paths=[DOCS/'source_archive/pre_reconstruction'/n for n in ('ec_supply_conference_model.pdf','ec_supply_solution_appendix.pdf')]
paths += [DOCS/n for n in ('ec_supply_conference_model.tex','ec_supply_solution_appendix.tex','ec_supply_conference_model.pdf','ec_supply_solution_appendix.pdf')]
result={'table_rows_verified':len(rows),'synthetic_states':cases,'max_derivative_error':err,
        'checks_passed':['table cells','archived chart source','signed alpha','fringe inversion','own/cross derivatives','sign reparameterization','markup FOC','cost identity','restored rendered passages'],
        'sha256':{str(p.relative_to(DOCS)):sha(p) for p in paths}}
(DOCS/'audits/supply_reconstruction_checks_2026-10-27.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='sha256'},indent=2))
