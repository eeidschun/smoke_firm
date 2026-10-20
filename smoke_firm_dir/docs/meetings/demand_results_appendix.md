# Complete demand results for the next advisor meeting

Updated: 2026-10-20.

These tables contain all 1,776 runs in the expanded comparison, not only selected admissible examples. The historical 48-model label applies only to the original design. The expanded totals include deliberate repeated sample comparisons, not 1,776 independent pieces of evidence. The earlier exploratory 224-fit run is documented separately and is not added to this total because of overlapping designs and a different nicotine-only sample rule.

## Design and identification

| Quality assumption | Sample | Count of instrument sets | Controls x FE x price x market size | Fits |
|---|---|---:|---|---:|
| Exogenous | 528 complete-size rows | 9 without lag | 4 x 2 x 2 x 3 | 432 |
| Exogenous | 524 common-lag rows | 19, including nonlag baselines | 4 x 2 x 2 x 3 | 912 |
| Endogenous | 524 common-lag rows | 9 with lag and enough instruments | 4 x 2 x 2 x 3 | 432 |

Quality exogenous: two endogenous regressors (price and within-nest log share). Two excluded instruments = exactly identified; three = one overidentifying restriction. Quality endogenous: three endogenous regressors (price, within-nest log share and a_it). Three instruments = exactly identified; four = one overidentifying restriction. All instruments enter jointly. The role intended for lagged quality is identification of current quality, but 2SLS does not assign instruments exclusively to individual regressors. Tax plus lag alone is not estimated with endogenous quality because two instruments cannot identify three endogenous regressors.

All rows explicitly list the complete excluded instrument set. Nicotine remains included in demand in both quality treatments; its slope is instrumented in the endogenous-quality section. Size and variety, when present, are treated as exogenous in both sections. No month FE; standard errors clustered by month. The sample, quality assumption and all other settings for each fit appear in [demand_specification_index.csv](demand_specification_index.csv).

Admissibility is descriptive, not a model-selection rule. Conventional SEs and intervals are not weak-IV-robust inference. Persistent unobserved demand shocks may invalidate lag quality; sales-share-based counts require an exclusion argument. Overidentification df describes the restrictions available; it does not report a test or establish instrument validity.

Source results and diagnostics: [exogenous quality](../../output/demand_estimation/advisor_instruments_2026-10-20/original_48_grid/README.md), [endogenous quality](../../output/demand_estimation/advisor_instruments_2026-10-20/endogenous_quality_grid/README.md). No existing canonical inputs or prior fits were replaced.

# Part A: Current quality treated as exogenous

# All instrument and market-size comparison tables

Each row gives the COMPLETE excluded instrument set, jointly instrumenting price and within-nest log share. Current quality a_it is always an exogenous control. Sections identify additional controls, price, firm FE and sample. No month FE. Alpha is the signed price coefficient (expected negative). Each market-size cell is estimate (month-clustered SE). B = nicotine only, S = plus size, V = plus log UPC variety, SV = both. Available sample: 528 rows/132 months; common-lag sample: 524 rows/131 months. Annual/monthly/constant columns refer to MARKET SIZE, independently of instrument names.

The 48 original specifications are reproduced as the available-sample/unweighted-price rows with either of the original active-brand counts across all four control groups, both FE choices and three market sizes. The other rows extend that design. Monthly >7% count redefines the threshold for the instrument only; demand roster remains annual. See README.md and CSVs for diagnostics and validation.

## available / Unweighted price / B / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.113 (0.065) | -0.105 (0.065) | -0.302 (0.063) | 2.887 (0.356) | 2.773 (0.364) | 3.103 (0.446) |
| Geographic tax + Geographic active-brand count | 2 | -0.103 (0.069) | -0.097 (0.067) | -0.289 (0.067) | 3.036 (0.408) | 2.902 (0.413) | 3.296 (0.512) |
| Geographic tax + Annual incumbent count | 2 | -0.231 (0.033) | -0.217 (0.036) | -0.390 (0.052) | 1.062 (0.187) | 1.055 (0.187) | 1.742 (0.228) |
| Geographic tax + Monthly >7% count | 2 | -0.219 (0.037) | -0.217 (0.037) | -0.355 (0.067) | 1.256 (0.263) | 1.049 (0.261) | 2.286 (0.361) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.142 (0.032) | -0.133 (0.034) | -0.323 (0.043) | 1.281 (0.179) | 1.261 (0.180) | 1.905 (0.202) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.134 (0.046) | -0.128 (0.045) | -0.312 (0.058) | 1.963 (0.204) | 1.796 (0.207) | 2.640 (0.275) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.139 (0.031) | -0.130 (0.033) | -0.317 (0.043) | 1.225 (0.183) | 1.208 (0.184) | 1.871 (0.204) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.129 (0.045) | -0.124 (0.043) | -0.304 (0.058) | 1.912 (0.221) | 1.732 (0.221) | 2.658 (0.295) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.229 (0.032) | -0.217 (0.036) | -0.383 (0.051) | 1.047 (0.188) | 1.056 (0.189) | 1.698 (0.232) |

## available / Unweighted price / B / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.002 (0.070) | 0.008 (0.073) | -0.294 (0.075) | 2.384 (0.231) | 2.255 (0.244) | 2.952 (0.340) |
| Geographic tax + Geographic active-brand count | 2 | 0.005 (0.071) | 0.012 (0.074) | -0.281 (0.077) | 2.409 (0.234) | 2.271 (0.248) | 2.999 (0.342) |
| Geographic tax + Annual incumbent count | 2 | -0.320 (0.093) | -0.284 (0.098) | -0.575 (0.130) | 1.217 (0.180) | 1.185 (0.170) | 1.922 (0.237) |
| Geographic tax + Monthly >7% count | 2 | -0.271 (0.091) | -0.283 (0.094) | -0.465 (0.136) | 1.395 (0.217) | 1.189 (0.222) | 2.325 (0.279) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.009 (0.053) | 0.002 (0.058) | -0.300 (0.056) | 1.254 (0.133) | 1.219 (0.142) | 1.954 (0.163) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.015 (0.059) | -0.006 (0.062) | -0.302 (0.069) | 1.768 (0.151) | 1.591 (0.159) | 2.562 (0.218) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.010 (0.053) | -0.001 (0.058) | -0.294 (0.057) | 1.230 (0.135) | 1.197 (0.144) | 1.933 (0.162) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.011 (0.059) | -0.005 (0.062) | -0.291 (0.069) | 1.744 (0.154) | 1.561 (0.161) | 2.557 (0.218) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.305 (0.087) | -0.283 (0.094) | -0.540 (0.121) | 1.216 (0.176) | 1.185 (0.170) | 1.919 (0.228) |

## available / Unweighted price / S / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.115 (0.081) | -0.106 (0.081) | -0.359 (0.070) | 2.880 (0.340) | 2.771 (0.353) | 2.916 (0.374) |
| Geographic tax + Geographic active-brand count | 2 | -0.100 (0.085) | -0.093 (0.084) | -0.338 (0.076) | 3.045 (0.400) | 2.914 (0.409) | 3.144 (0.448) |
| Geographic tax + Annual incumbent count | 2 | -0.274 (0.036) | -0.256 (0.040) | -0.458 (0.053) | 1.102 (0.171) | 1.091 (0.174) | 1.805 (0.181) |
| Geographic tax + Monthly >7% count | 2 | -0.269 (0.040) | -0.270 (0.041) | -0.429 (0.069) | 1.149 (0.246) | 0.939 (0.248) | 2.129 (0.306) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.200 (0.039) | -0.187 (0.043) | -0.412 (0.051) | 1.285 (0.170) | 1.264 (0.172) | 1.920 (0.171) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.163 (0.057) | -0.157 (0.055) | -0.381 (0.064) | 1.895 (0.208) | 1.728 (0.212) | 2.469 (0.233) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.193 (0.038) | -0.180 (0.041) | -0.402 (0.050) | 1.232 (0.173) | 1.214 (0.175) | 1.895 (0.172) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.155 (0.056) | -0.151 (0.054) | -0.368 (0.066) | 1.850 (0.226) | 1.669 (0.227) | 2.505 (0.258) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.274 (0.036) | -0.254 (0.041) | -0.461 (0.053) | 1.098 (0.172) | 1.104 (0.176) | 1.777 (0.187) |

## available / Unweighted price / S / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.024 (0.075) | -0.010 (0.079) | -0.351 (0.073) | 2.267 (0.190) | 2.160 (0.204) | 2.641 (0.259) |
| Geographic tax + Geographic active-brand count | 2 | -0.015 (0.076) | -0.004 (0.079) | -0.334 (0.075) | 2.299 (0.195) | 2.181 (0.210) | 2.705 (0.261) |
| Geographic tax + Annual incumbent count | 2 | -0.301 (0.080) | -0.267 (0.087) | -0.542 (0.104) | 1.213 (0.173) | 1.182 (0.167) | 1.915 (0.197) |
| Geographic tax + Monthly >7% count | 2 | -0.278 (0.082) | -0.289 (0.087) | -0.475 (0.109) | 1.302 (0.206) | 1.100 (0.211) | 2.168 (0.242) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.080 (0.062) | -0.062 (0.066) | -0.390 (0.068) | 1.346 (0.130) | 1.304 (0.136) | 2.006 (0.155) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.054 (0.066) | -0.043 (0.069) | -0.366 (0.071) | 1.746 (0.135) | 1.588 (0.143) | 2.386 (0.183) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.076 (0.061) | -0.060 (0.066) | -0.378 (0.067) | 1.314 (0.133) | 1.274 (0.139) | 1.988 (0.154) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.047 (0.066) | -0.038 (0.068) | -0.351 (0.071) | 1.722 (0.139) | 1.556 (0.147) | 2.395 (0.183) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.299 (0.079) | -0.269 (0.086) | -0.536 (0.102) | 1.217 (0.172) | 1.178 (0.167) | 1.926 (0.193) |

## available / Unweighted price / V / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.189 (0.095) | -0.171 (0.093) | -0.458 (0.107) | 3.316 (0.563) | 3.142 (0.565) | 3.979 (0.746) |
| Geographic tax + Geographic active-brand count | 2 | -0.187 (0.100) | -0.169 (0.097) | -0.455 (0.113) | 3.487 (0.641) | 3.291 (0.637) | 4.192 (0.848) |
| Geographic tax + Annual incumbent count | 2 | -0.225 (0.041) | -0.204 (0.044) | -0.488 (0.060) | 1.042 (0.226) | 1.016 (0.223) | 2.045 (0.317) |
| Geographic tax + Monthly >7% count | 2 | -0.221 (0.044) | -0.204 (0.044) | -0.481 (0.071) | 1.261 (0.294) | 1.024 (0.289) | 2.518 (0.427) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.100 (0.035) | -0.088 (0.036) | -0.382 (0.044) | 1.086 (0.210) | 1.058 (0.214) | 2.083 (0.278) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.127 (0.047) | -0.107 (0.045) | -0.414 (0.065) | 1.807 (0.269) | 1.588 (0.268) | 2.907 (0.376) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.096 (0.034) | -0.084 (0.036) | -0.375 (0.043) | 1.034 (0.209) | 1.008 (0.214) | 2.038 (0.277) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.119 (0.045) | -0.100 (0.043) | -0.404 (0.063) | 1.740 (0.280) | 1.513 (0.277) | 2.878 (0.387) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.223 (0.041) | -0.204 (0.044) | -0.486 (0.059) | 1.036 (0.226) | 1.016 (0.224) | 2.032 (0.319) |

## available / Unweighted price / V / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.011 (0.065) | 0.025 (0.068) | -0.314 (0.077) | 2.315 (0.236) | 2.169 (0.255) | 3.054 (0.343) |
| Geographic tax + Geographic active-brand count | 2 | 0.019 (0.066) | 0.030 (0.068) | -0.303 (0.078) | 2.347 (0.241) | 2.191 (0.260) | 3.099 (0.349) |
| Geographic tax + Annual incumbent count | 2 | -0.271 (0.083) | -0.232 (0.088) | -0.583 (0.123) | 1.139 (0.179) | 1.101 (0.173) | 1.935 (0.251) |
| Geographic tax + Monthly >7% count | 2 | -0.214 (0.083) | -0.215 (0.087) | -0.487 (0.121) | 1.378 (0.208) | 1.169 (0.216) | 2.332 (0.287) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.032 (0.045) | 0.044 (0.049) | -0.294 (0.051) | 1.119 (0.140) | 1.083 (0.154) | 1.916 (0.175) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.018 (0.051) | 0.032 (0.054) | -0.309 (0.064) | 1.637 (0.165) | 1.445 (0.177) | 2.531 (0.225) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | 0.033 (0.045) | 0.043 (0.049) | -0.289 (0.051) | 1.101 (0.140) | 1.067 (0.154) | 1.898 (0.175) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.023 (0.051) | 0.035 (0.053) | -0.300 (0.064) | 1.620 (0.168) | 1.424 (0.179) | 2.523 (0.225) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.252 (0.079) | -0.226 (0.085) | -0.550 (0.113) | 1.148 (0.173) | 1.104 (0.171) | 1.950 (0.237) |

## available / Unweighted price / SV / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.189 (0.095) | -0.171 (0.093) | -0.462 (0.087) | 3.281 (0.528) | 3.123 (0.540) | 3.469 (0.581) |
| Geographic tax + Geographic active-brand count | 2 | -0.187 (0.101) | -0.169 (0.099) | -0.457 (0.096) | 3.491 (0.623) | 3.304 (0.625) | 3.759 (0.703) |
| Geographic tax + Annual incumbent count | 2 | -0.222 (0.036) | -0.202 (0.038) | -0.484 (0.046) | 0.948 (0.205) | 0.931 (0.211) | 1.881 (0.259) |
| Geographic tax + Monthly >7% count | 2 | -0.220 (0.037) | -0.203 (0.038) | -0.479 (0.053) | 1.076 (0.270) | 0.841 (0.274) | 2.204 (0.363) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.150 (0.035) | -0.134 (0.037) | -0.435 (0.042) | 1.057 (0.207) | 1.033 (0.213) | 1.955 (0.249) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.153 (0.045) | -0.134 (0.044) | -0.441 (0.056) | 1.684 (0.277) | 1.470 (0.278) | 2.552 (0.329) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.139 (0.034) | -0.125 (0.036) | -0.423 (0.041) | 1.003 (0.205) | 0.982 (0.213) | 1.922 (0.248) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.142 (0.044) | -0.124 (0.042) | -0.429 (0.055) | 1.624 (0.288) | 1.400 (0.287) | 2.557 (0.347) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.223 (0.036) | -0.201 (0.038) | -0.487 (0.047) | 0.946 (0.205) | 0.932 (0.212) | 1.875 (0.262) |

## available / Unweighted price / SV / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.005 (0.067) | 0.012 (0.070) | -0.361 (0.071) | 2.186 (0.192) | 2.067 (0.210) | 2.683 (0.256) |
| Geographic tax + Geographic active-brand count | 2 | 0.004 (0.068) | 0.019 (0.071) | -0.346 (0.072) | 2.227 (0.198) | 2.096 (0.217) | 2.748 (0.263) |
| Geographic tax + Annual incumbent count | 2 | -0.247 (0.069) | -0.211 (0.075) | -0.538 (0.094) | 1.125 (0.165) | 1.089 (0.163) | 1.907 (0.206) |
| Geographic tax + Monthly >7% count | 2 | -0.209 (0.072) | -0.211 (0.078) | -0.478 (0.094) | 1.293 (0.188) | 1.091 (0.197) | 2.169 (0.245) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.038 (0.051) | -0.018 (0.055) | -0.384 (0.061) | 1.221 (0.136) | 1.177 (0.146) | 1.978 (0.164) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.020 (0.056) | -0.004 (0.059) | -0.369 (0.066) | 1.633 (0.145) | 1.462 (0.158) | 2.364 (0.189) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.031 (0.050) | -0.014 (0.055) | -0.373 (0.060) | 1.194 (0.136) | 1.153 (0.148) | 1.961 (0.163) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.011 (0.055) | 0.002 (0.058) | -0.355 (0.065) | 1.617 (0.149) | 1.439 (0.161) | 2.370 (0.190) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.243 (0.068) | -0.211 (0.075) | -0.531 (0.092) | 1.140 (0.162) | 1.089 (0.161) | 1.932 (0.199) |

## available / Volume-weighted price / B / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.122 (0.065) | -0.114 (0.065) | -0.328 (0.053) | 2.559 (0.282) | 2.467 (0.301) | 2.227 (0.304) |
| Geographic tax + Geographic active-brand count | 2 | -0.115 (0.070) | -0.108 (0.069) | -0.324 (0.056) | 2.680 (0.323) | 2.568 (0.341) | 2.298 (0.340) |
| Geographic tax + Annual incumbent count | 2 | -0.249 (0.027) | -0.234 (0.031) | -0.420 (0.039) | 0.427 (0.227) | 0.459 (0.240) | 0.670 (0.271) |
| Geographic tax + Monthly >7% count | 2 | -0.264 (0.035) | -0.262 (0.042) | -0.428 (0.045) | 0.185 (0.336) | -0.016 (0.369) | 0.548 (0.410) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.157 (0.028) | -0.147 (0.031) | -0.353 (0.034) | 0.882 (0.230) | 0.888 (0.236) | 1.002 (0.245) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.118 (0.038) | -0.109 (0.038) | -0.324 (0.036) | 1.527 (0.269) | 1.388 (0.277) | 1.497 (0.272) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.168 (0.027) | -0.158 (0.031) | -0.362 (0.035) | 0.805 (0.233) | 0.812 (0.239) | 0.943 (0.254) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.124 (0.038) | -0.118 (0.038) | -0.330 (0.038) | 1.437 (0.295) | 1.280 (0.301) | 1.426 (0.300) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.241 (0.026) | -0.219 (0.029) | -0.417 (0.039) | 0.454 (0.228) | 0.512 (0.241) | 0.684 (0.269) |

## available / Volume-weighted price / B / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.004 (0.123) | 0.014 (0.129) | -0.514 (0.129) | 2.378 (0.224) | 2.274 (0.247) | 2.223 (0.291) |
| Geographic tax + Geographic active-brand count | 2 | 0.009 (0.131) | 0.022 (0.136) | -0.512 (0.133) | 2.422 (0.239) | 2.304 (0.263) | 2.231 (0.306) |
| Geographic tax + Annual incumbent count | 2 | -0.701 (0.231) | -0.621 (0.232) | -1.259 (0.358) | -0.070 (0.614) | 0.044 (0.587) | -0.390 (0.944) |
| Geographic tax + Monthly >7% count | 2 | -0.810 (0.365) | -0.844 (0.396) | -1.387 (0.552) | -0.454 (1.080) | -0.737 (1.152) | -0.842 (1.658) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.112 (0.091) | 0.119 (0.101) | -0.391 (0.063) | 1.378 (0.222) | 1.363 (0.242) | 1.156 (0.236) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.134 (0.095) | 0.160 (0.104) | -0.366 (0.072) | 1.924 (0.231) | 1.792 (0.256) | 1.732 (0.206) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | 0.091 (0.096) | 0.097 (0.106) | -0.426 (0.072) | 1.334 (0.234) | 1.318 (0.253) | 1.087 (0.267) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.140 (0.102) | 0.162 (0.110) | -0.372 (0.076) | 1.935 (0.250) | 1.790 (0.274) | 1.711 (0.223) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.655 (0.221) | -0.527 (0.212) | -1.204 (0.345) | -0.002 (0.590) | 0.183 (0.540) | -0.309 (0.904) |

## available / Volume-weighted price / S / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.120 (0.079) | -0.111 (0.079) | -0.375 (0.054) | 2.573 (0.320) | 2.489 (0.340) | 1.958 (0.304) |
| Geographic tax + Geographic active-brand count | 2 | -0.109 (0.086) | -0.102 (0.085) | -0.370 (0.058) | 2.715 (0.376) | 2.607 (0.394) | 2.029 (0.347) |
| Geographic tax + Annual incumbent count | 2 | -0.287 (0.030) | -0.268 (0.034) | -0.480 (0.039) | 0.364 (0.222) | 0.401 (0.241) | 0.570 (0.240) |
| Geographic tax + Monthly >7% count | 2 | -0.329 (0.058) | -0.329 (0.069) | -0.524 (0.059) | -0.193 (0.409) | -0.404 (0.477) | -0.008 (0.417) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.209 (0.031) | -0.195 (0.035) | -0.431 (0.035) | 0.747 (0.237) | 0.763 (0.246) | 0.811 (0.232) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.129 (0.046) | -0.120 (0.046) | -0.382 (0.035) | 1.461 (0.315) | 1.326 (0.322) | 1.168 (0.265) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.221 (0.030) | -0.207 (0.034) | -0.439 (0.036) | 0.668 (0.237) | 0.687 (0.247) | 0.759 (0.236) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.140 (0.047) | -0.133 (0.046) | -0.391 (0.037) | 1.345 (0.344) | 1.189 (0.350) | 1.069 (0.290) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.260 (0.028) | -0.230 (0.032) | -0.452 (0.037) | 0.449 (0.229) | 0.524 (0.247) | 0.658 (0.242) |

## available / Volume-weighted price / S / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.043 (0.137) | -0.018 (0.145) | -0.647 (0.129) | 2.199 (0.248) | 2.132 (0.269) | 1.623 (0.301) |
| Geographic tax + Geographic active-brand count | 2 | -0.029 (0.145) | -0.008 (0.152) | -0.644 (0.134) | 2.251 (0.270) | 2.169 (0.292) | 1.637 (0.322) |
| Geographic tax + Annual incumbent count | 2 | -0.638 (0.189) | -0.566 (0.194) | -1.149 (0.272) | 0.039 (0.486) | 0.139 (0.478) | -0.199 (0.707) |
| Geographic tax + Monthly >7% count | 2 | -0.848 (0.383) | -0.881 (0.423) | -1.451 (0.549) | -0.722 (1.082) | -1.002 (1.185) | -1.293 (1.601) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.038 (0.105) | -0.013 (0.115) | -0.643 (0.102) | 1.216 (0.246) | 1.225 (0.262) | 0.794 (0.314) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.097 (0.109) | 0.133 (0.119) | -0.507 (0.078) | 1.856 (0.256) | 1.764 (0.283) | 1.280 (0.230) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.070 (0.110) | -0.046 (0.120) | -0.678 (0.115) | 1.146 (0.262) | 1.155 (0.275) | 0.720 (0.347) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.102 (0.116) | 0.132 (0.126) | -0.514 (0.082) | 1.863 (0.279) | 1.755 (0.304) | 1.254 (0.250) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.533 (0.163) | -0.409 (0.163) | -0.998 (0.233) | 0.192 (0.449) | 0.369 (0.427) | 0.021 (0.633) |

## available / Volume-weighted price / V / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.163 (0.066) | -0.148 (0.066) | -0.395 (0.057) | 2.661 (0.351) | 2.550 (0.366) | 2.394 (0.377) |
| Geographic tax + Geographic active-brand count | 2 | -0.162 (0.069) | -0.147 (0.068) | -0.395 (0.058) | 2.762 (0.389) | 2.635 (0.401) | 2.423 (0.405) |
| Geographic tax + Annual incumbent count | 2 | -0.192 (0.028) | -0.175 (0.030) | -0.417 (0.033) | 0.409 (0.206) | 0.440 (0.221) | 0.669 (0.275) |
| Geographic tax + Monthly >7% count | 2 | -0.193 (0.029) | -0.178 (0.032) | -0.419 (0.034) | 0.365 (0.282) | 0.198 (0.306) | 0.571 (0.352) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.107 (0.026) | -0.095 (0.028) | -0.352 (0.027) | 0.791 (0.214) | 0.799 (0.222) | 0.962 (0.257) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.095 (0.030) | -0.078 (0.030) | -0.341 (0.027) | 1.331 (0.270) | 1.187 (0.277) | 1.338 (0.282) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.116 (0.027) | -0.104 (0.028) | -0.361 (0.028) | 0.742 (0.215) | 0.751 (0.223) | 0.918 (0.262) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.100 (0.030) | -0.083 (0.030) | -0.347 (0.027) | 1.268 (0.283) | 1.116 (0.289) | 1.269 (0.295) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.190 (0.027) | -0.165 (0.029) | -0.413 (0.034) | 0.411 (0.205) | 0.450 (0.218) | 0.673 (0.275) |

## available / Volume-weighted price / V / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.019 (0.111) | 0.042 (0.116) | -0.532 (0.126) | 2.344 (0.223) | 2.232 (0.250) | 2.249 (0.312) |
| Geographic tax + Geographic active-brand count | 2 | 0.033 (0.118) | 0.053 (0.122) | -0.532 (0.129) | 2.399 (0.238) | 2.276 (0.265) | 2.249 (0.325) |
| Geographic tax + Annual incumbent count | 2 | -0.546 (0.171) | -0.466 (0.176) | -1.172 (0.283) | 0.101 (0.475) | 0.215 (0.458) | -0.295 (0.816) |
| Geographic tax + Monthly >7% count | 2 | -0.534 (0.223) | -0.537 (0.237) | -1.216 (0.368) | 0.150 (0.694) | -0.068 (0.726) | -0.467 (1.195) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.151 (0.077) | 0.161 (0.086) | -0.382 (0.061) | 1.331 (0.196) | 1.321 (0.220) | 1.101 (0.238) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.147 (0.083) | 0.177 (0.091) | -0.373 (0.069) | 1.842 (0.215) | 1.706 (0.240) | 1.628 (0.217) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | 0.140 (0.081) | 0.149 (0.090) | -0.414 (0.067) | 1.309 (0.203) | 1.298 (0.227) | 1.042 (0.262) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.157 (0.088) | 0.182 (0.096) | -0.382 (0.072) | 1.862 (0.230) | 1.716 (0.253) | 1.600 (0.231) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.552 (0.174) | -0.433 (0.170) | -1.152 (0.292) | 0.094 (0.480) | 0.255 (0.439) | -0.270 (0.814) |

## available / Volume-weighted price / SV / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.163 (0.068) | -0.147 (0.068) | -0.397 (0.045) | 2.685 (0.425) | 2.584 (0.440) | 2.016 (0.373) |
| Geographic tax + Geographic active-brand count | 2 | -0.162 (0.071) | -0.146 (0.071) | -0.397 (0.046) | 2.804 (0.473) | 2.683 (0.482) | 2.075 (0.405) |
| Geographic tax + Annual incumbent count | 2 | -0.190 (0.027) | -0.173 (0.028) | -0.414 (0.029) | 0.338 (0.181) | 0.376 (0.207) | 0.553 (0.223) |
| Geographic tax + Monthly >7% count | 2 | -0.192 (0.029) | -0.177 (0.033) | -0.417 (0.033) | 0.200 (0.252) | 0.032 (0.296) | 0.297 (0.290) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.140 (0.025) | -0.126 (0.027) | -0.383 (0.026) | 0.630 (0.206) | 0.651 (0.221) | 0.735 (0.226) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.114 (0.028) | -0.097 (0.028) | -0.363 (0.024) | 1.147 (0.298) | 1.005 (0.306) | 0.952 (0.266) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.145 (0.025) | -0.131 (0.027) | -0.386 (0.026) | 0.591 (0.204) | 0.613 (0.220) | 0.709 (0.226) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.117 (0.027) | -0.101 (0.028) | -0.366 (0.024) | 1.082 (0.304) | 0.931 (0.313) | 0.899 (0.272) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.184 (0.025) | -0.157 (0.026) | -0.402 (0.028) | 0.349 (0.181) | 0.402 (0.206) | 0.572 (0.223) |

## available / Volume-weighted price / SV / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.009 (0.118) | 0.021 (0.125) | -0.635 (0.118) | 2.172 (0.235) | 2.102 (0.259) | 1.613 (0.306) |
| Geographic tax + Geographic active-brand count | 2 | 0.008 (0.124) | 0.034 (0.131) | -0.630 (0.120) | 2.240 (0.255) | 2.156 (0.279) | 1.632 (0.320) |
| Geographic tax + Annual incumbent count | 2 | -0.479 (0.133) | -0.409 (0.141) | -1.041 (0.205) | 0.208 (0.363) | 0.306 (0.365) | -0.084 (0.591) |
| Geographic tax + Monthly >7% count | 2 | -0.515 (0.193) | -0.519 (0.211) | -1.177 (0.307) | 0.060 (0.586) | -0.154 (0.639) | -0.651 (0.975) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.011 (0.085) | 0.039 (0.095) | -0.618 (0.089) | 1.189 (0.210) | 1.203 (0.229) | 0.763 (0.303) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.100 (0.093) | 0.138 (0.102) | -0.517 (0.074) | 1.766 (0.229) | 1.670 (0.255) | 1.179 (0.239) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.008 (0.088) | 0.020 (0.098) | -0.643 (0.096) | 1.148 (0.219) | 1.162 (0.237) | 0.710 (0.324) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.109 (0.097) | 0.141 (0.106) | -0.524 (0.077) | 1.784 (0.246) | 1.673 (0.270) | 1.155 (0.252) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.458 (0.125) | -0.345 (0.127) | -0.961 (0.196) | 0.234 (0.357) | 0.386 (0.341) | 0.014 (0.566) |

## common_lag / Unweighted price / B / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.106 (0.068) | -0.099 (0.067) | -0.302 (0.065) | 2.936 (0.363) | 2.820 (0.371) | 3.108 (0.447) |
| Geographic tax + Geographic active-brand count | 2 | -0.096 (0.071) | -0.090 (0.070) | -0.289 (0.069) | 3.091 (0.418) | 2.955 (0.424) | 3.307 (0.515) |
| Geographic tax + Annual incumbent count | 2 | -0.232 (0.034) | -0.217 (0.037) | -0.395 (0.054) | 1.065 (0.189) | 1.058 (0.189) | 1.729 (0.232) |
| Geographic tax + Monthly >7% count | 2 | -0.218 (0.039) | -0.217 (0.039) | -0.360 (0.069) | 1.269 (0.272) | 1.056 (0.269) | 2.257 (0.373) |
| Geographic tax + One-month-lagged quality | 2 | -0.163 (0.064) | -0.156 (0.062) | -0.286 (0.122) | 2.097 (0.465) | 1.977 (0.500) | 3.349 (1.151) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.139 (0.033) | -0.130 (0.035) | -0.327 (0.045) | 1.301 (0.181) | 1.280 (0.182) | 1.902 (0.205) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.129 (0.048) | -0.123 (0.046) | -0.314 (0.059) | 1.995 (0.208) | 1.825 (0.211) | 2.628 (0.278) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.111 (0.067) | -0.104 (0.067) | -0.301 (0.067) | 2.871 (0.330) | 2.755 (0.337) | 3.127 (0.421) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.136 (0.032) | -0.128 (0.034) | -0.321 (0.044) | 1.244 (0.184) | 1.225 (0.186) | 1.868 (0.207) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.124 (0.046) | -0.119 (0.045) | -0.305 (0.059) | 1.948 (0.226) | 1.763 (0.226) | 2.648 (0.300) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.102 (0.070) | -0.096 (0.069) | -0.289 (0.071) | 3.000 (0.370) | 2.865 (0.375) | 3.311 (0.476) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.226 (0.034) | -0.212 (0.037) | -0.386 (0.054) | 1.087 (0.187) | 1.078 (0.187) | 1.764 (0.227) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.212 (0.040) | -0.210 (0.039) | -0.351 (0.070) | 1.322 (0.267) | 1.115 (0.264) | 2.326 (0.360) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.136 (0.033) | -0.128 (0.035) | -0.321 (0.045) | 1.313 (0.180) | 1.291 (0.180) | 1.928 (0.202) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.128 (0.048) | -0.122 (0.046) | -0.311 (0.060) | 1.999 (0.205) | 1.831 (0.207) | 2.657 (0.271) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.133 (0.032) | -0.125 (0.034) | -0.314 (0.044) | 1.258 (0.184) | 1.237 (0.185) | 1.895 (0.204) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.123 (0.047) | -0.118 (0.045) | -0.302 (0.060) | 1.953 (0.222) | 1.772 (0.221) | 2.679 (0.291) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.230 (0.033) | -0.217 (0.037) | -0.390 (0.052) | 1.051 (0.190) | 1.058 (0.191) | 1.692 (0.236) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.224 (0.033) | -0.212 (0.037) | -0.382 (0.052) | 1.073 (0.188) | 1.078 (0.189) | 1.727 (0.231) |

## common_lag / Unweighted price / B / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.012 (0.072) | 0.021 (0.075) | -0.289 (0.076) | 2.417 (0.235) | 2.286 (0.248) | 2.976 (0.344) |
| Geographic tax + Geographic active-brand count | 2 | 0.020 (0.073) | 0.026 (0.076) | -0.275 (0.079) | 2.444 (0.239) | 2.303 (0.253) | 3.025 (0.346) |
| Geographic tax + Annual incumbent count | 2 | -0.318 (0.095) | -0.282 (0.100) | -0.581 (0.135) | 1.223 (0.181) | 1.191 (0.171) | 1.920 (0.242) |
| Geographic tax + Monthly >7% count | 2 | -0.264 (0.096) | -0.278 (0.099) | -0.468 (0.143) | 1.418 (0.221) | 1.205 (0.226) | 2.328 (0.288) |
| Geographic tax + One-month-lagged quality | 2 | -0.524 (1.613) | -0.462 (1.468) | -1.402 (3.545) | 0.480 (5.788) | 0.540 (5.278) | -1.046 (12.731) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.003 (0.054) | 0.013 (0.059) | -0.297 (0.058) | 1.266 (0.134) | 1.230 (0.144) | 1.957 (0.164) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.002 (0.060) | 0.007 (0.064) | -0.298 (0.070) | 1.799 (0.150) | 1.618 (0.158) | 2.575 (0.218) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | 0.013 (0.072) | 0.022 (0.075) | -0.287 (0.076) | 2.414 (0.236) | 2.283 (0.249) | 2.969 (0.343) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | 0.002 (0.054) | 0.010 (0.059) | -0.291 (0.058) | 1.241 (0.136) | 1.207 (0.146) | 1.936 (0.163) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.003 (0.060) | 0.008 (0.063) | -0.286 (0.071) | 1.776 (0.153) | 1.588 (0.160) | 2.571 (0.219) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | 0.020 (0.073) | 0.027 (0.076) | -0.274 (0.078) | 2.440 (0.240) | 2.300 (0.254) | 3.017 (0.346) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.319 (0.095) | -0.282 (0.100) | -0.584 (0.134) | 1.221 (0.180) | 1.189 (0.171) | 1.911 (0.242) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.266 (0.094) | -0.279 (0.097) | -0.474 (0.140) | 1.412 (0.218) | 1.200 (0.224) | 2.305 (0.285) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.004 (0.054) | 0.014 (0.059) | -0.295 (0.057) | 1.260 (0.133) | 1.224 (0.143) | 1.946 (0.162) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.001 (0.061) | 0.007 (0.064) | -0.296 (0.070) | 1.790 (0.149) | 1.609 (0.157) | 2.559 (0.216) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.002 (0.054) | 0.010 (0.059) | -0.290 (0.058) | 1.235 (0.135) | 1.202 (0.145) | 1.924 (0.161) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.004 (0.060) | 0.009 (0.063) | -0.285 (0.070) | 1.766 (0.152) | 1.578 (0.159) | 2.553 (0.216) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.304 (0.090) | -0.281 (0.097) | -0.550 (0.127) | 1.224 (0.177) | 1.191 (0.171) | 1.921 (0.232) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.304 (0.090) | -0.281 (0.097) | -0.553 (0.126) | 1.222 (0.176) | 1.189 (0.170) | 1.914 (0.232) |

## common_lag / Unweighted price / S / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.108 (0.084) | -0.099 (0.084) | -0.360 (0.071) | 2.931 (0.348) | 2.819 (0.361) | 2.934 (0.376) |
| Geographic tax + Geographic active-brand count | 2 | -0.093 (0.089) | -0.086 (0.087) | -0.339 (0.078) | 3.100 (0.411) | 2.967 (0.420) | 3.167 (0.452) |
| Geographic tax + Annual incumbent count | 2 | -0.273 (0.037) | -0.255 (0.041) | -0.462 (0.055) | 1.115 (0.171) | 1.104 (0.175) | 1.810 (0.183) |
| Geographic tax + Monthly >7% count | 2 | -0.266 (0.042) | -0.267 (0.043) | -0.432 (0.071) | 1.189 (0.249) | 0.974 (0.251) | 2.135 (0.313) |
| Geographic tax + One-month-lagged quality | 2 | -0.196 (0.081) | -0.187 (0.081) | -0.342 (0.151) | 1.964 (0.574) | 1.851 (0.610) | 3.125 (1.165) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.197 (0.041) | -0.183 (0.044) | -0.415 (0.052) | 1.312 (0.170) | 1.290 (0.172) | 1.932 (0.172) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.157 (0.059) | -0.151 (0.057) | -0.382 (0.066) | 1.938 (0.209) | 1.767 (0.213) | 2.479 (0.236) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.115 (0.084) | -0.106 (0.083) | -0.358 (0.074) | 2.859 (0.313) | 2.748 (0.324) | 2.948 (0.353) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.189 (0.039) | -0.176 (0.043) | -0.404 (0.051) | 1.259 (0.173) | 1.239 (0.176) | 1.908 (0.173) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.149 (0.058) | -0.145 (0.056) | -0.369 (0.068) | 1.897 (0.228) | 1.711 (0.228) | 2.517 (0.263) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.101 (0.087) | -0.094 (0.086) | -0.339 (0.080) | 3.003 (0.360) | 2.871 (0.369) | 3.163 (0.416) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.269 (0.037) | -0.252 (0.041) | -0.456 (0.055) | 1.130 (0.172) | 1.117 (0.175) | 1.833 (0.183) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.260 (0.043) | -0.260 (0.044) | -0.425 (0.073) | 1.233 (0.251) | 1.023 (0.251) | 2.191 (0.309) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.194 (0.041) | -0.181 (0.044) | -0.410 (0.053) | 1.324 (0.170) | 1.301 (0.172) | 1.953 (0.172) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.157 (0.059) | -0.151 (0.057) | -0.379 (0.067) | 1.942 (0.208) | 1.774 (0.211) | 2.505 (0.232) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.186 (0.040) | -0.174 (0.043) | -0.400 (0.052) | 1.271 (0.173) | 1.249 (0.176) | 1.929 (0.173) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.148 (0.058) | -0.144 (0.056) | -0.366 (0.069) | 1.901 (0.225) | 1.719 (0.225) | 2.544 (0.258) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.274 (0.037) | -0.253 (0.042) | -0.465 (0.054) | 1.110 (0.172) | 1.113 (0.176) | 1.786 (0.188) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.270 (0.037) | -0.250 (0.042) | -0.460 (0.055) | 1.124 (0.173) | 1.126 (0.176) | 1.809 (0.188) |

## common_lag / Unweighted price / S / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.009 (0.077) | 0.005 (0.081) | -0.346 (0.074) | 2.304 (0.194) | 2.195 (0.208) | 2.665 (0.262) |
| Geographic tax + Geographic active-brand count | 2 | 0.000 (0.078) | 0.011 (0.081) | -0.328 (0.076) | 2.338 (0.199) | 2.217 (0.214) | 2.731 (0.264) |
| Geographic tax + Annual incumbent count | 2 | -0.297 (0.082) | -0.263 (0.089) | -0.544 (0.107) | 1.224 (0.173) | 1.192 (0.168) | 1.921 (0.199) |
| Geographic tax + Monthly >7% count | 2 | -0.268 (0.085) | -0.281 (0.091) | -0.474 (0.114) | 1.334 (0.207) | 1.126 (0.212) | 2.186 (0.247) |
| Geographic tax + One-month-lagged quality | 2 | -0.108 (0.219) | -0.100 (0.236) | -0.443 (0.323) | 1.932 (0.989) | 1.804 (1.044) | 2.299 (1.340) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.069 (0.063) | -0.052 (0.068) | -0.387 (0.070) | 1.361 (0.130) | 1.319 (0.137) | 2.015 (0.155) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.040 (0.068) | -0.030 (0.071) | -0.361 (0.073) | 1.782 (0.132) | 1.619 (0.141) | 2.407 (0.182) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.010 (0.075) | 0.003 (0.079) | -0.347 (0.073) | 2.306 (0.192) | 2.197 (0.206) | 2.667 (0.260) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.065 (0.062) | -0.049 (0.067) | -0.375 (0.069) | 1.328 (0.133) | 1.287 (0.140) | 1.997 (0.154) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.033 (0.067) | -0.025 (0.070) | -0.346 (0.073) | 1.760 (0.136) | 1.588 (0.145) | 2.417 (0.183) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.001 (0.076) | 0.009 (0.080) | -0.329 (0.075) | 2.340 (0.198) | 2.219 (0.213) | 2.734 (0.263) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.292 (0.080) | -0.259 (0.087) | -0.541 (0.103) | 1.225 (0.172) | 1.192 (0.167) | 1.922 (0.198) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.262 (0.082) | -0.274 (0.088) | -0.472 (0.108) | 1.341 (0.202) | 1.134 (0.207) | 2.187 (0.244) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.072 (0.061) | -0.054 (0.067) | -0.390 (0.068) | 1.362 (0.131) | 1.320 (0.137) | 2.017 (0.156) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.043 (0.066) | -0.033 (0.069) | -0.363 (0.072) | 1.783 (0.132) | 1.620 (0.141) | 2.408 (0.182) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.067 (0.060) | -0.052 (0.066) | -0.378 (0.068) | 1.328 (0.134) | 1.288 (0.140) | 1.997 (0.154) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.036 (0.065) | -0.028 (0.068) | -0.348 (0.072) | 1.760 (0.136) | 1.589 (0.145) | 2.417 (0.183) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.295 (0.081) | -0.265 (0.088) | -0.539 (0.105) | 1.230 (0.172) | 1.189 (0.167) | 1.934 (0.195) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.289 (0.080) | -0.260 (0.086) | -0.536 (0.102) | 1.230 (0.170) | 1.189 (0.166) | 1.935 (0.194) |

## common_lag / Unweighted price / V / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.186 (0.099) | -0.168 (0.097) | -0.457 (0.111) | 3.434 (0.595) | 3.251 (0.598) | 4.072 (0.777) |
| Geographic tax + Geographic active-brand count | 2 | -0.183 (0.105) | -0.165 (0.102) | -0.453 (0.117) | 3.619 (0.683) | 3.412 (0.678) | 4.299 (0.889) |
| Geographic tax + Annual incumbent count | 2 | -0.225 (0.042) | -0.205 (0.044) | -0.490 (0.061) | 1.043 (0.231) | 1.016 (0.228) | 2.040 (0.328) |
| Geographic tax + Monthly >7% count | 2 | -0.221 (0.044) | -0.204 (0.044) | -0.482 (0.072) | 1.277 (0.311) | 1.027 (0.305) | 2.531 (0.455) |
| Geographic tax + One-month-lagged quality | 2 | -0.208 (0.062) | -0.189 (0.063) | -0.471 (0.093) | 2.059 (0.486) | 1.949 (0.505) | 3.198 (0.946) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.097 (0.035) | -0.085 (0.036) | -0.381 (0.044) | 1.095 (0.213) | 1.064 (0.218) | 2.084 (0.285) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.125 (0.048) | -0.105 (0.046) | -0.413 (0.067) | 1.864 (0.281) | 1.632 (0.280) | 2.950 (0.395) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.182 (0.091) | -0.164 (0.090) | -0.454 (0.105) | 3.215 (0.480) | 3.044 (0.484) | 3.933 (0.663) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.093 (0.034) | -0.082 (0.036) | -0.374 (0.043) | 1.040 (0.213) | 1.013 (0.218) | 2.037 (0.285) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.117 (0.046) | -0.098 (0.044) | -0.403 (0.065) | 1.795 (0.293) | 1.555 (0.290) | 2.922 (0.408) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.178 (0.095) | -0.161 (0.092) | -0.449 (0.109) | 3.335 (0.528) | 3.145 (0.527) | 4.098 (0.733) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.222 (0.042) | -0.202 (0.045) | -0.486 (0.062) | 1.080 (0.226) | 1.050 (0.222) | 2.081 (0.318) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.218 (0.046) | -0.201 (0.045) | -0.479 (0.074) | 1.347 (0.299) | 1.110 (0.294) | 2.591 (0.431) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.096 (0.035) | -0.084 (0.037) | -0.379 (0.045) | 1.120 (0.211) | 1.088 (0.215) | 2.116 (0.279) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.125 (0.048) | -0.105 (0.046) | -0.413 (0.067) | 1.868 (0.271) | 1.645 (0.269) | 2.961 (0.379) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.091 (0.035) | -0.080 (0.036) | -0.372 (0.044) | 1.068 (0.210) | 1.039 (0.215) | 2.071 (0.279) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.117 (0.046) | -0.098 (0.044) | -0.403 (0.065) | 1.804 (0.282) | 1.574 (0.279) | 2.935 (0.390) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.224 (0.041) | -0.205 (0.044) | -0.488 (0.060) | 1.037 (0.231) | 1.016 (0.228) | 2.026 (0.330) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.221 (0.042) | -0.201 (0.045) | -0.484 (0.061) | 1.073 (0.226) | 1.049 (0.223) | 2.067 (0.320) |

## common_lag / Unweighted price / V / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.021 (0.068) | 0.034 (0.070) | -0.308 (0.079) | 2.359 (0.243) | 2.207 (0.262) | 3.099 (0.347) |
| Geographic tax + Geographic active-brand count | 2 | 0.029 (0.069) | 0.040 (0.071) | -0.297 (0.080) | 2.391 (0.249) | 2.230 (0.268) | 3.145 (0.354) |
| Geographic tax + Annual incumbent count | 2 | -0.272 (0.084) | -0.232 (0.090) | -0.589 (0.127) | 1.140 (0.183) | 1.101 (0.176) | 1.934 (0.259) |
| Geographic tax + Monthly >7% count | 2 | -0.212 (0.087) | -0.216 (0.090) | -0.491 (0.127) | 1.389 (0.217) | 1.170 (0.225) | 2.341 (0.300) |
| Geographic tax + One-month-lagged quality | 2 | -2.051 (24.204) | -2.015 (24.049) | -2.968 (30.702) | -6.243 (100.192) | -6.296 (99.564) | -7.942 (127.135) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.039 (0.045) | 0.050 (0.050) | -0.291 (0.052) | 1.123 (0.143) | 1.086 (0.157) | 1.919 (0.178) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.026 (0.053) | 0.039 (0.055) | -0.304 (0.066) | 1.667 (0.169) | 1.467 (0.181) | 2.558 (0.228) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | 0.021 (0.068) | 0.034 (0.070) | -0.308 (0.079) | 2.367 (0.242) | 2.215 (0.262) | 3.109 (0.348) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | 0.040 (0.045) | 0.049 (0.050) | -0.287 (0.052) | 1.105 (0.144) | 1.070 (0.158) | 1.900 (0.178) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.032 (0.052) | 0.042 (0.055) | -0.295 (0.065) | 1.649 (0.172) | 1.445 (0.183) | 2.550 (0.229) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | 0.029 (0.069) | 0.040 (0.071) | -0.297 (0.081) | 2.400 (0.248) | 2.238 (0.267) | 3.155 (0.356) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.275 (0.084) | -0.235 (0.089) | -0.592 (0.127) | 1.139 (0.183) | 1.100 (0.177) | 1.933 (0.260) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.216 (0.086) | -0.219 (0.089) | -0.495 (0.126) | 1.385 (0.217) | 1.166 (0.225) | 2.335 (0.300) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.039 (0.045) | 0.050 (0.050) | -0.291 (0.052) | 1.122 (0.143) | 1.085 (0.157) | 1.916 (0.178) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.026 (0.053) | 0.039 (0.055) | -0.305 (0.066) | 1.666 (0.169) | 1.466 (0.181) | 2.557 (0.228) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.040 (0.045) | 0.049 (0.050) | -0.286 (0.052) | 1.103 (0.144) | 1.068 (0.158) | 1.898 (0.177) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.032 (0.052) | 0.042 (0.055) | -0.295 (0.065) | 1.648 (0.172) | 1.444 (0.183) | 2.548 (0.229) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.255 (0.081) | -0.227 (0.087) | -0.560 (0.118) | 1.150 (0.177) | 1.104 (0.174) | 1.951 (0.245) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.257 (0.080) | -0.230 (0.087) | -0.563 (0.118) | 1.149 (0.178) | 1.103 (0.175) | 1.950 (0.246) |

## common_lag / Unweighted price / SV / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.186 (0.100) | -0.168 (0.098) | -0.462 (0.091) | 3.406 (0.562) | 3.238 (0.575) | 3.554 (0.607) |
| Geographic tax + Geographic active-brand count | 2 | -0.183 (0.107) | -0.165 (0.104) | -0.457 (0.100) | 3.630 (0.669) | 3.432 (0.671) | 3.862 (0.742) |
| Geographic tax + Annual incumbent count | 2 | -0.223 (0.036) | -0.203 (0.039) | -0.487 (0.047) | 0.958 (0.209) | 0.939 (0.215) | 1.890 (0.267) |
| Geographic tax + Monthly >7% count | 2 | -0.221 (0.037) | -0.204 (0.039) | -0.482 (0.054) | 1.103 (0.285) | 0.854 (0.287) | 2.230 (0.388) |
| Geographic tax + One-month-lagged quality | 2 | -0.208 (0.056) | -0.189 (0.057) | -0.471 (0.077) | 1.947 (0.532) | 1.848 (0.549) | 2.953 (0.946) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.149 (0.036) | -0.133 (0.038) | -0.436 (0.043) | 1.074 (0.211) | 1.048 (0.217) | 1.968 (0.256) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.152 (0.047) | -0.133 (0.045) | -0.442 (0.058) | 1.748 (0.290) | 1.522 (0.291) | 2.601 (0.350) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.185 (0.091) | -0.167 (0.090) | -0.461 (0.087) | 3.155 (0.442) | 2.999 (0.452) | 3.450 (0.522) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.138 (0.035) | -0.123 (0.037) | -0.424 (0.042) | 1.018 (0.209) | 0.995 (0.217) | 1.934 (0.255) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.141 (0.045) | -0.122 (0.043) | -0.430 (0.057) | 1.687 (0.303) | 1.450 (0.301) | 2.607 (0.370) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.181 (0.095) | -0.163 (0.093) | -0.456 (0.094) | 3.301 (0.499) | 3.122 (0.503) | 3.684 (0.608) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.221 (0.036) | -0.201 (0.039) | -0.484 (0.047) | 0.993 (0.208) | 0.971 (0.213) | 1.928 (0.264) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.218 (0.038) | -0.201 (0.039) | -0.479 (0.056) | 1.180 (0.282) | 0.945 (0.283) | 2.297 (0.374) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.148 (0.036) | -0.132 (0.038) | -0.434 (0.044) | 1.104 (0.209) | 1.076 (0.215) | 2.003 (0.253) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.152 (0.048) | -0.132 (0.046) | -0.441 (0.059) | 1.763 (0.281) | 1.547 (0.280) | 2.628 (0.337) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.136 (0.035) | -0.122 (0.037) | -0.422 (0.042) | 1.050 (0.208) | 1.024 (0.215) | 1.969 (0.252) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.140 (0.046) | -0.122 (0.044) | -0.429 (0.057) | 1.706 (0.292) | 1.480 (0.290) | 2.634 (0.355) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.225 (0.036) | -0.202 (0.039) | -0.491 (0.047) | 0.955 (0.209) | 0.941 (0.216) | 1.883 (0.270) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.223 (0.036) | -0.200 (0.039) | -0.488 (0.048) | 0.991 (0.208) | 0.973 (0.213) | 1.921 (0.266) |

## common_lag / Unweighted price / SV / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.005 (0.070) | 0.021 (0.073) | -0.356 (0.074) | 2.231 (0.197) | 2.106 (0.217) | 2.722 (0.259) |
| Geographic tax + Geographic active-brand count | 2 | 0.015 (0.071) | 0.028 (0.073) | -0.340 (0.075) | 2.272 (0.205) | 2.136 (0.224) | 2.790 (0.267) |
| Geographic tax + Annual incumbent count | 2 | -0.247 (0.070) | -0.211 (0.076) | -0.541 (0.097) | 1.130 (0.168) | 1.093 (0.166) | 1.915 (0.211) |
| Geographic tax + Monthly >7% count | 2 | -0.206 (0.075) | -0.210 (0.080) | -0.479 (0.098) | 1.310 (0.196) | 1.098 (0.204) | 2.188 (0.254) |
| Geographic tax + One-month-lagged quality | 2 | -0.307 (0.776) | -0.330 (0.924) | -0.400 (0.570) | 0.871 (3.401) | 0.572 (4.046) | 2.532 (2.594) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.032 (0.052) | -0.013 (0.057) | -0.383 (0.063) | 1.229 (0.138) | 1.184 (0.149) | 1.988 (0.167) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.012 (0.058) | 0.003 (0.060) | -0.366 (0.068) | 1.666 (0.148) | 1.487 (0.162) | 2.394 (0.191) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | 0.002 (0.068) | 0.018 (0.072) | -0.357 (0.073) | 2.242 (0.195) | 2.119 (0.213) | 2.724 (0.258) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.025 (0.051) | -0.008 (0.056) | -0.371 (0.061) | 1.201 (0.139) | 1.158 (0.151) | 1.970 (0.165) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.003 (0.057) | 0.009 (0.059) | -0.351 (0.067) | 1.649 (0.153) | 1.464 (0.166) | 2.400 (0.193) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | 0.012 (0.069) | 0.025 (0.072) | -0.341 (0.074) | 2.284 (0.202) | 2.149 (0.221) | 2.793 (0.266) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.248 (0.068) | -0.213 (0.074) | -0.539 (0.094) | 1.130 (0.168) | 1.094 (0.166) | 1.914 (0.211) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.208 (0.072) | -0.213 (0.077) | -0.477 (0.095) | 1.310 (0.196) | 1.097 (0.204) | 2.188 (0.253) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.038 (0.050) | -0.019 (0.055) | -0.386 (0.062) | 1.238 (0.139) | 1.193 (0.149) | 1.992 (0.168) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.017 (0.056) | -0.003 (0.059) | -0.367 (0.067) | 1.675 (0.149) | 1.498 (0.162) | 2.397 (0.191) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.031 (0.050) | -0.014 (0.055) | -0.374 (0.061) | 1.210 (0.140) | 1.167 (0.151) | 1.974 (0.166) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.008 (0.055) | 0.004 (0.058) | -0.353 (0.066) | 1.659 (0.153) | 1.474 (0.165) | 2.404 (0.193) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.244 (0.070) | -0.211 (0.076) | -0.536 (0.096) | 1.146 (0.165) | 1.093 (0.164) | 1.941 (0.205) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.245 (0.068) | -0.213 (0.074) | -0.533 (0.093) | 1.147 (0.166) | 1.094 (0.165) | 1.939 (0.204) |

## common_lag / Volume-weighted price / B / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.117 (0.068) | -0.109 (0.068) | -0.332 (0.054) | 2.613 (0.292) | 2.519 (0.313) | 2.190 (0.303) |
| Geographic tax + Geographic active-brand count | 2 | -0.109 (0.074) | -0.102 (0.073) | -0.328 (0.057) | 2.745 (0.337) | 2.629 (0.358) | 2.261 (0.341) |
| Geographic tax + Annual incumbent count | 2 | -0.251 (0.028) | -0.235 (0.032) | -0.428 (0.040) | 0.418 (0.230) | 0.451 (0.244) | 0.626 (0.273) |
| Geographic tax + Monthly >7% count | 2 | -0.268 (0.038) | -0.267 (0.046) | -0.442 (0.046) | 0.141 (0.355) | -0.069 (0.395) | 0.396 (0.406) |
| Geographic tax + One-month-lagged quality | 2 | -0.146 (0.063) | -0.140 (0.061) | -0.258 (0.130) | 2.129 (0.500) | 2.007 (0.536) | 3.406 (1.456) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.158 (0.029) | -0.148 (0.032) | -0.362 (0.035) | 0.895 (0.236) | 0.901 (0.242) | 0.966 (0.250) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.111 (0.040) | -0.103 (0.040) | -0.328 (0.036) | 1.571 (0.282) | 1.428 (0.291) | 1.434 (0.277) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.122 (0.067) | -0.114 (0.067) | -0.320 (0.058) | 2.564 (0.269) | 2.467 (0.285) | 2.315 (0.301) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.170 (0.029) | -0.160 (0.032) | -0.371 (0.036) | 0.814 (0.239) | 0.822 (0.246) | 0.904 (0.258) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.118 (0.041) | -0.112 (0.041) | -0.335 (0.038) | 1.481 (0.311) | 1.320 (0.319) | 1.356 (0.306) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.116 (0.072) | -0.109 (0.070) | -0.315 (0.062) | 2.667 (0.303) | 2.551 (0.317) | 2.405 (0.339) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.233 (0.027) | -0.219 (0.031) | -0.399 (0.038) | 0.495 (0.230) | 0.521 (0.241) | 0.751 (0.270) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.232 (0.033) | -0.230 (0.038) | -0.388 (0.042) | 0.421 (0.337) | 0.224 (0.362) | 0.819 (0.397) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.148 (0.029) | -0.139 (0.032) | -0.340 (0.033) | 0.937 (0.235) | 0.938 (0.239) | 1.055 (0.245) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.107 (0.040) | -0.099 (0.039) | -0.308 (0.036) | 1.600 (0.274) | 1.458 (0.281) | 1.570 (0.270) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.159 (0.029) | -0.149 (0.032) | -0.348 (0.034) | 0.863 (0.238) | 0.866 (0.242) | 1.001 (0.254) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.112 (0.040) | -0.106 (0.039) | -0.312 (0.038) | 1.523 (0.301) | 1.365 (0.305) | 1.519 (0.297) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.241 (0.027) | -0.216 (0.030) | -0.419 (0.039) | 0.451 (0.230) | 0.512 (0.244) | 0.653 (0.271) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.224 (0.026) | -0.202 (0.029) | -0.392 (0.037) | 0.522 (0.230) | 0.575 (0.241) | 0.771 (0.269) |

## common_lag / Volume-weighted price / B / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.022 (0.132) | 0.039 (0.139) | -0.528 (0.136) | 2.450 (0.234) | 2.345 (0.261) | 2.194 (0.299) |
| Geographic tax + Geographic active-brand count | 2 | 0.037 (0.141) | 0.050 (0.148) | -0.526 (0.142) | 2.503 (0.253) | 2.382 (0.281) | 2.199 (0.317) |
| Geographic tax + Annual incumbent count | 2 | -0.729 (0.250) | -0.645 (0.250) | -1.330 (0.393) | -0.148 (0.660) | -0.022 (0.632) | -0.582 (1.029) |
| Geographic tax + Monthly >7% count | 2 | -0.934 (0.480) | -0.981 (0.525) | -1.652 (0.736) | -0.856 (1.416) | -1.185 (1.529) | -1.696 (2.188) |
| Geographic tax + One-month-lagged quality | 2 | -0.310 (0.289) | -0.273 (0.316) | -0.829 (0.421) | 1.301 (1.081) | 1.264 (1.167) | 1.151 (1.474) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.139 (0.097) | 0.146 (0.108) | -0.403 (0.068) | 1.447 (0.235) | 1.431 (0.259) | 1.122 (0.248) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.175 (0.102) | 0.203 (0.112) | -0.347 (0.073) | 2.055 (0.237) | 1.923 (0.270) | 1.729 (0.206) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | 0.014 (0.126) | 0.032 (0.134) | -0.535 (0.134) | 2.440 (0.231) | 2.335 (0.259) | 2.184 (0.298) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | 0.116 (0.103) | 0.122 (0.114) | -0.443 (0.079) | 1.399 (0.249) | 1.381 (0.272) | 1.041 (0.284) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.187 (0.110) | 0.209 (0.120) | -0.352 (0.077) | 2.081 (0.261) | 1.935 (0.293) | 1.711 (0.224) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | 0.028 (0.135) | 0.041 (0.142) | -0.534 (0.139) | 2.488 (0.248) | 2.369 (0.277) | 2.187 (0.316) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.690 (0.238) | -0.611 (0.237) | -1.284 (0.361) | -0.076 (0.617) | 0.041 (0.592) | -0.497 (0.955) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.788 (0.398) | -0.816 (0.434) | -1.460 (0.561) | -0.473 (1.138) | -0.750 (1.224) | -1.191 (1.672) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.129 (0.092) | 0.136 (0.104) | -0.412 (0.068) | 1.428 (0.227) | 1.412 (0.252) | 1.103 (0.246) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.166 (0.099) | 0.194 (0.109) | -0.357 (0.073) | 2.031 (0.229) | 1.899 (0.263) | 1.704 (0.204) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.105 (0.097) | 0.111 (0.110) | -0.454 (0.078) | 1.377 (0.239) | 1.361 (0.263) | 1.021 (0.281) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.176 (0.106) | 0.198 (0.116) | -0.363 (0.077) | 2.051 (0.250) | 1.905 (0.283) | 1.682 (0.220) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.629 (0.222) | -0.481 (0.209) | -1.174 (0.348) | 0.009 (0.594) | 0.235 (0.536) | -0.336 (0.910) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.608 (0.214) | -0.468 (0.202) | -1.151 (0.329) | 0.051 (0.565) | 0.261 (0.512) | -0.291 (0.864) |

## common_lag / Volume-weighted price / S / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.114 (0.082) | -0.105 (0.082) | -0.381 (0.055) | 2.626 (0.332) | 2.539 (0.354) | 1.920 (0.304) |
| Geographic tax + Geographic active-brand count | 2 | -0.103 (0.090) | -0.095 (0.089) | -0.376 (0.059) | 2.778 (0.393) | 2.667 (0.413) | 1.988 (0.348) |
| Geographic tax + Annual incumbent count | 2 | -0.287 (0.031) | -0.269 (0.035) | -0.487 (0.039) | 0.365 (0.225) | 0.403 (0.244) | 0.540 (0.241) |
| Geographic tax + Monthly >7% count | 2 | -0.332 (0.062) | -0.333 (0.074) | -0.539 (0.065) | -0.214 (0.438) | -0.433 (0.514) | -0.145 (0.441) |
| Geographic tax + One-month-lagged quality | 2 | -0.155 (0.075) | -0.149 (0.073) | -0.272 (0.160) | 2.090 (0.547) | 1.971 (0.585) | 3.346 (1.565) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.210 (0.032) | -0.195 (0.036) | -0.439 (0.036) | 0.765 (0.242) | 0.781 (0.251) | 0.785 (0.233) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.122 (0.049) | -0.113 (0.049) | -0.387 (0.035) | 1.510 (0.327) | 1.371 (0.337) | 1.109 (0.266) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.121 (0.081) | -0.113 (0.080) | -0.362 (0.060) | 2.564 (0.306) | 2.474 (0.321) | 2.083 (0.307) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.223 (0.032) | -0.208 (0.036) | -0.448 (0.037) | 0.684 (0.241) | 0.702 (0.252) | 0.731 (0.238) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.133 (0.049) | -0.127 (0.049) | -0.398 (0.036) | 1.397 (0.360) | 1.236 (0.367) | 1.004 (0.292) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.113 (0.087) | -0.106 (0.085) | -0.355 (0.065) | 2.681 (0.351) | 2.569 (0.363) | 2.179 (0.353) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.269 (0.030) | -0.252 (0.034) | -0.457 (0.037) | 0.436 (0.228) | 0.467 (0.244) | 0.656 (0.246) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.281 (0.046) | -0.279 (0.054) | -0.461 (0.044) | 0.160 (0.376) | -0.044 (0.424) | 0.421 (0.370) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.197 (0.033) | -0.184 (0.036) | -0.414 (0.035) | 0.816 (0.242) | 0.827 (0.249) | 0.881 (0.235) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.116 (0.048) | -0.107 (0.047) | -0.358 (0.036) | 1.549 (0.317) | 1.412 (0.322) | 1.293 (0.267) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.208 (0.032) | -0.195 (0.036) | -0.421 (0.035) | 0.740 (0.243) | 0.753 (0.251) | 0.834 (0.240) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.125 (0.048) | -0.118 (0.047) | -0.365 (0.037) | 1.454 (0.347) | 1.297 (0.349) | 1.227 (0.294) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.258 (0.029) | -0.226 (0.032) | -0.451 (0.037) | 0.454 (0.230) | 0.530 (0.248) | 0.645 (0.243) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.243 (0.028) | -0.213 (0.031) | -0.428 (0.036) | 0.512 (0.232) | 0.580 (0.247) | 0.742 (0.247) |

## common_lag / Volume-weighted price / S / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.017 (0.147) | 0.009 (0.157) | -0.667 (0.137) | 2.277 (0.267) | 2.210 (0.292) | 1.573 (0.317) |
| Geographic tax + Geographic active-brand count | 2 | 0.001 (0.158) | 0.022 (0.166) | -0.664 (0.142) | 2.339 (0.294) | 2.254 (0.320) | 1.583 (0.341) |
| Geographic tax + Annual incumbent count | 2 | -0.655 (0.201) | -0.580 (0.206) | -1.199 (0.293) | -0.007 (0.512) | 0.101 (0.505) | -0.333 (0.753) |
| Geographic tax + Monthly >7% count | 2 | -0.959 (0.505) | -1.007 (0.561) | -1.696 (0.748) | -1.095 (1.436) | -1.424 (1.588) | -2.111 (2.153) |
| Geographic tax + One-month-lagged quality | 2 | -0.083 (0.192) | -0.077 (0.196) | -0.341 (0.471) | 2.040 (0.868) | 1.903 (0.876) | 2.739 (1.772) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.023 (0.112) | 0.003 (0.124) | -0.672 (0.112) | 1.260 (0.263) | 1.270 (0.282) | 0.724 (0.334) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.145 (0.118) | 0.183 (0.129) | -0.490 (0.078) | 2.000 (0.270) | 1.911 (0.305) | 1.270 (0.230) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.024 (0.127) | 0.000 (0.137) | -0.633 (0.123) | 2.269 (0.252) | 2.199 (0.279) | 1.612 (0.297) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.060 (0.118) | -0.035 (0.130) | -0.714 (0.127) | 1.181 (0.281) | 1.191 (0.298) | 0.637 (0.372) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.156 (0.127) | 0.187 (0.138) | -0.497 (0.082) | 2.026 (0.299) | 1.919 (0.332) | 1.246 (0.251) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.009 (0.134) | 0.010 (0.143) | -0.627 (0.126) | 2.326 (0.272) | 2.239 (0.301) | 1.634 (0.317) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.543 (0.184) | -0.482 (0.185) | -1.032 (0.239) | 0.186 (0.445) | 0.271 (0.440) | -0.043 (0.624) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.562 (0.308) | -0.585 (0.342) | -1.082 (0.361) | -0.027 (0.846) | -0.291 (0.934) | -0.459 (1.047) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.042 (0.098) | -0.017 (0.110) | -0.648 (0.103) | 1.234 (0.243) | 1.243 (0.262) | 0.759 (0.314) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.119 (0.103) | 0.154 (0.115) | -0.483 (0.073) | 1.954 (0.245) | 1.860 (0.281) | 1.284 (0.217) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.076 (0.103) | -0.051 (0.114) | -0.681 (0.116) | 1.157 (0.258) | 1.166 (0.275) | 0.685 (0.346) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.126 (0.109) | 0.154 (0.121) | -0.488 (0.077) | 1.967 (0.265) | 1.854 (0.301) | 1.263 (0.234) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.505 (0.161) | -0.370 (0.160) | -0.954 (0.228) | 0.225 (0.450) | 0.425 (0.426) | 0.044 (0.625) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.447 (0.150) | -0.331 (0.147) | -0.870 (0.197) | 0.330 (0.405) | 0.496 (0.386) | 0.198 (0.549) |

## common_lag / Volume-weighted price / V / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.161 (0.069) | -0.146 (0.069) | -0.396 (0.057) | 2.744 (0.376) | 2.627 (0.394) | 2.378 (0.389) |
| Geographic tax + Geographic active-brand count | 2 | -0.160 (0.072) | -0.145 (0.071) | -0.396 (0.058) | 2.855 (0.421) | 2.720 (0.434) | 2.407 (0.420) |
| Geographic tax + Annual incumbent count | 2 | -0.193 (0.029) | -0.175 (0.030) | -0.420 (0.034) | 0.392 (0.208) | 0.424 (0.224) | 0.622 (0.279) |
| Geographic tax + Monthly >7% count | 2 | -0.194 (0.030) | -0.179 (0.033) | -0.422 (0.036) | 0.318 (0.292) | 0.141 (0.320) | 0.443 (0.350) |
| Geographic tax + One-month-lagged quality | 2 | -0.170 (0.053) | -0.154 (0.052) | -0.384 (0.085) | 2.112 (0.489) | 1.997 (0.521) | 3.318 (1.359) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.111 (0.027) | -0.098 (0.029) | -0.358 (0.027) | 0.792 (0.220) | 0.799 (0.229) | 0.921 (0.264) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.094 (0.031) | -0.077 (0.031) | -0.343 (0.027) | 1.367 (0.289) | 1.216 (0.297) | 1.279 (0.294) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.165 (0.067) | -0.149 (0.066) | -0.391 (0.061) | 2.658 (0.333) | 2.541 (0.344) | 2.506 (0.389) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.120 (0.027) | -0.107 (0.029) | -0.367 (0.029) | 0.738 (0.221) | 0.747 (0.230) | 0.873 (0.268) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.099 (0.031) | -0.082 (0.031) | -0.348 (0.027) | 1.300 (0.303) | 1.139 (0.310) | 1.203 (0.307) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.164 (0.069) | -0.149 (0.068) | -0.391 (0.062) | 2.738 (0.362) | 2.606 (0.369) | 2.551 (0.418) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.175 (0.028) | -0.159 (0.029) | -0.392 (0.031) | 0.476 (0.208) | 0.501 (0.222) | 0.754 (0.275) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.170 (0.028) | -0.155 (0.030) | -0.384 (0.030) | 0.542 (0.292) | 0.374 (0.310) | 0.803 (0.345) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.100 (0.027) | -0.089 (0.028) | -0.338 (0.025) | 0.841 (0.219) | 0.844 (0.226) | 1.018 (0.259) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.089 (0.031) | -0.072 (0.030) | -0.326 (0.026) | 1.409 (0.281) | 1.261 (0.286) | 1.428 (0.287) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.108 (0.027) | -0.097 (0.029) | -0.345 (0.026) | 0.794 (0.220) | 0.798 (0.227) | 0.978 (0.264) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.093 (0.031) | -0.076 (0.030) | -0.329 (0.027) | 1.354 (0.294) | 1.197 (0.297) | 1.374 (0.300) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.189 (0.027) | -0.162 (0.029) | -0.412 (0.034) | 0.396 (0.207) | 0.439 (0.221) | 0.632 (0.278) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.173 (0.027) | -0.148 (0.028) | -0.386 (0.031) | 0.478 (0.207) | 0.512 (0.219) | 0.760 (0.275) |

## common_lag / Volume-weighted price / V / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.038 (0.120) | 0.060 (0.126) | -0.541 (0.132) | 2.420 (0.239) | 2.304 (0.270) | 2.220 (0.326) |
| Geographic tax + Geographic active-brand count | 2 | 0.053 (0.128) | 0.072 (0.132) | -0.541 (0.136) | 2.482 (0.259) | 2.354 (0.289) | 2.219 (0.341) |
| Geographic tax + Annual incumbent count | 2 | -0.560 (0.178) | -0.478 (0.183) | -1.211 (0.297) | 0.035 (0.498) | 0.159 (0.481) | -0.453 (0.864) |
| Geographic tax + Monthly >7% count | 2 | -0.584 (0.254) | -0.593 (0.271) | -1.349 (0.427) | -0.059 (0.809) | -0.301 (0.853) | -1.006 (1.396) |
| Geographic tax + One-month-lagged quality | 2 | -0.643 (1.108) | -0.632 (1.196) | -0.931 (0.671) | -0.295 (4.379) | -0.454 (4.728) | 0.665 (2.701) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.162 (0.083) | 0.172 (0.093) | -0.402 (0.066) | 1.374 (0.212) | 1.364 (0.239) | 1.048 (0.258) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.174 (0.090) | 0.203 (0.099) | -0.364 (0.070) | 1.951 (0.230) | 1.812 (0.262) | 1.609 (0.226) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | 0.029 (0.117) | 0.051 (0.123) | -0.546 (0.131) | 2.422 (0.239) | 2.306 (0.270) | 2.220 (0.328) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | 0.148 (0.087) | 0.158 (0.097) | -0.437 (0.073) | 1.347 (0.221) | 1.336 (0.248) | 0.980 (0.285) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.186 (0.096) | 0.211 (0.105) | -0.373 (0.073) | 1.980 (0.248) | 1.829 (0.278) | 1.581 (0.240) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | 0.044 (0.124) | 0.063 (0.129) | -0.546 (0.135) | 2.482 (0.258) | 2.354 (0.288) | 2.219 (0.343) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.564 (0.177) | -0.484 (0.180) | -1.200 (0.292) | 0.029 (0.493) | 0.148 (0.474) | -0.433 (0.850) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.588 (0.247) | -0.596 (0.266) | -1.318 (0.405) | -0.070 (0.777) | -0.308 (0.823) | -0.927 (1.320) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.151 (0.080) | 0.161 (0.091) | -0.410 (0.067) | 1.359 (0.208) | 1.348 (0.236) | 1.036 (0.260) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.166 (0.088) | 0.195 (0.097) | -0.370 (0.071) | 1.939 (0.226) | 1.799 (0.259) | 1.599 (0.227) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | 0.136 (0.083) | 0.146 (0.094) | -0.446 (0.074) | 1.329 (0.216) | 1.318 (0.244) | 0.966 (0.287) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.176 (0.094) | 0.201 (0.103) | -0.380 (0.074) | 1.964 (0.244) | 1.813 (0.274) | 1.569 (0.241) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.547 (0.175) | -0.411 (0.167) | -1.131 (0.295) | 0.054 (0.488) | 0.253 (0.439) | -0.340 (0.829) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.550 (0.175) | -0.420 (0.166) | -1.126 (0.291) | 0.048 (0.485) | 0.238 (0.435) | -0.330 (0.819) |

## common_lag / Volume-weighted price / SV / No firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | -0.161 (0.071) | -0.146 (0.071) | -0.400 (0.044) | 2.770 (0.462) | 2.664 (0.478) | 1.977 (0.383) |
| Geographic tax + Geographic active-brand count | 2 | -0.160 (0.075) | -0.144 (0.074) | -0.399 (0.046) | 2.900 (0.517) | 2.772 (0.527) | 2.038 (0.418) |
| Geographic tax + Annual incumbent count | 2 | -0.192 (0.027) | -0.174 (0.028) | -0.418 (0.030) | 0.327 (0.183) | 0.365 (0.210) | 0.513 (0.223) |
| Geographic tax + Monthly >7% count | 2 | -0.194 (0.031) | -0.179 (0.034) | -0.422 (0.036) | 0.157 (0.262) | -0.020 (0.311) | 0.170 (0.284) |
| Geographic tax + One-month-lagged quality | 2 | -0.170 (0.051) | -0.154 (0.051) | -0.384 (0.082) | 2.078 (0.518) | 1.966 (0.553) | 3.248 (1.423) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | -0.145 (0.025) | -0.130 (0.027) | -0.390 (0.026) | 0.629 (0.211) | 0.649 (0.227) | 0.694 (0.229) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | -0.114 (0.029) | -0.097 (0.029) | -0.367 (0.024) | 1.180 (0.318) | 1.030 (0.327) | 0.877 (0.268) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.166 (0.067) | -0.150 (0.067) | -0.391 (0.050) | 2.654 (0.398) | 2.546 (0.405) | 2.190 (0.394) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.150 (0.025) | -0.135 (0.027) | -0.393 (0.027) | 0.587 (0.208) | 0.608 (0.225) | 0.667 (0.228) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | -0.117 (0.028) | -0.101 (0.029) | -0.370 (0.024) | 1.110 (0.326) | 0.950 (0.334) | 0.819 (0.274) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | -0.165 (0.070) | -0.150 (0.069) | -0.391 (0.052) | 2.744 (0.431) | 2.619 (0.433) | 2.267 (0.428) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.176 (0.026) | -0.160 (0.027) | -0.393 (0.026) | 0.410 (0.188) | 0.441 (0.211) | 0.643 (0.229) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.170 (0.027) | -0.154 (0.030) | -0.384 (0.026) | 0.409 (0.272) | 0.240 (0.303) | 0.573 (0.285) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.133 (0.025) | -0.119 (0.027) | -0.368 (0.024) | 0.695 (0.214) | 0.709 (0.226) | 0.809 (0.232) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.106 (0.029) | -0.089 (0.029) | -0.345 (0.022) | 1.254 (0.311) | 1.108 (0.316) | 1.094 (0.269) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.137 (0.025) | -0.123 (0.027) | -0.370 (0.024) | 0.657 (0.212) | 0.672 (0.226) | 0.786 (0.232) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | -0.108 (0.029) | -0.092 (0.029) | -0.346 (0.022) | 1.199 (0.319) | 1.043 (0.323) | 1.057 (0.277) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.183 (0.025) | -0.155 (0.026) | -0.401 (0.028) | 0.341 (0.183) | 0.398 (0.208) | 0.542 (0.223) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.169 (0.024) | -0.143 (0.026) | -0.379 (0.025) | 0.420 (0.188) | 0.467 (0.209) | 0.665 (0.230) |

## common_lag / Volume-weighted price / SV / Firm FE

| Complete excluded instruments | Number | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant |
|---|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count | 2 | 0.009 (0.128) | 0.039 (0.136) | -0.650 (0.123) | 2.247 (0.262) | 2.175 (0.290) | 1.554 (0.325) |
| Geographic tax + Geographic active-brand count | 2 | 0.028 (0.135) | 0.053 (0.142) | -0.646 (0.126) | 2.324 (0.287) | 2.236 (0.315) | 1.573 (0.341) |
| Geographic tax + Annual incumbent count | 2 | -0.489 (0.137) | -0.417 (0.145) | -1.069 (0.214) | 0.162 (0.376) | 0.267 (0.380) | -0.201 (0.616) |
| Geographic tax + Monthly >7% count | 2 | -0.556 (0.219) | -0.566 (0.241) | -1.291 (0.358) | -0.118 (0.675) | -0.358 (0.745) | -1.129 (1.128) |
| Geographic tax + One-month-lagged quality | 2 | -0.204 (0.231) | -0.219 (0.279) | -0.266 (0.762) | 1.356 (1.108) | 1.095 (1.277) | 3.164 (3.258) |
| Geographic tax + National active-brand count + Annual incumbent count | 3 | 0.008 (0.091) | 0.038 (0.102) | -0.651 (0.098) | 1.202 (0.228) | 1.219 (0.250) | 0.674 (0.328) |
| Geographic tax + National active-brand count + Monthly >7% count | 3 | 0.129 (0.101) | 0.167 (0.111) | -0.514 (0.074) | 1.876 (0.252) | 1.779 (0.285) | 1.133 (0.247) |
| Geographic tax + National active-brand count + One-month-lagged quality | 3 | -0.004 (0.115) | 0.023 (0.124) | -0.627 (0.114) | 2.239 (0.256) | 2.165 (0.285) | 1.569 (0.314) |
| Geographic tax + Geographic active-brand count + Annual incumbent count | 3 | -0.013 (0.094) | 0.016 (0.105) | -0.679 (0.106) | 1.155 (0.238) | 1.171 (0.259) | 0.613 (0.351) |
| Geographic tax + Geographic active-brand count + Monthly >7% count | 3 | 0.140 (0.107) | 0.173 (0.116) | -0.521 (0.078) | 1.904 (0.274) | 1.790 (0.304) | 1.108 (0.262) |
| Geographic tax + Geographic active-brand count + One-month-lagged quality | 3 | 0.013 (0.122) | 0.036 (0.130) | -0.621 (0.117) | 2.312 (0.279) | 2.222 (0.307) | 1.593 (0.329) |
| Geographic tax + Annual incumbent count + One-month-lagged quality | 3 | -0.458 (0.135) | -0.396 (0.138) | -0.983 (0.195) | 0.213 (0.357) | 0.302 (0.358) | -0.058 (0.568) |
| Geographic tax + Monthly >7% count + One-month-lagged quality | 3 | -0.484 (0.203) | -0.496 (0.225) | -1.083 (0.290) | 0.069 (0.605) | -0.174 (0.670) | -0.585 (0.911) |
| Geographic tax + National active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.019 (0.080) | 0.009 (0.092) | -0.640 (0.094) | 1.168 (0.218) | 1.183 (0.240) | 0.689 (0.322) |
| Geographic tax + National active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.105 (0.091) | 0.140 (0.103) | -0.510 (0.072) | 1.840 (0.238) | 1.738 (0.272) | 1.139 (0.243) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + One-month-lagged quality | 4 | -0.041 (0.083) | -0.013 (0.094) | -0.664 (0.102) | 1.118 (0.227) | 1.132 (0.248) | 0.632 (0.343) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + One-month-lagged quality | 4 | 0.113 (0.096) | 0.142 (0.106) | -0.516 (0.075) | 1.859 (0.256) | 1.740 (0.288) | 1.116 (0.256) |
| Geographic tax + Annual incumbent count + Monthly >7% count | 3 | -0.447 (0.123) | -0.324 (0.124) | -0.931 (0.192) | 0.221 (0.359) | 0.398 (0.341) | -0.007 (0.566) |
| Geographic tax + Annual incumbent count + Monthly >7% count + One-month-lagged quality | 4 | -0.428 (0.121) | -0.318 (0.119) | -0.878 (0.178) | 0.255 (0.343) | 0.409 (0.326) | 0.084 (0.530) |

# Part B: Current quality treated as endogenous

# Endogenous-quality results

Price, within-nest log share and current quality a_it are jointly endogenous. Every set includes geographic tax and lagged quality, plus at least one count. Lagged quality is intended to help identify current quality; 2SLS uses the full instrument set jointly for all three regressors rather than assigning one instrument mechanically to each. Size and variety, where included, remain exogenous.

All 432 fits use the same 524 observations/131 month clusters as the exogenous-quality common-lag comparisons. Four control groups, two FE choices, two prices, three market sizes, nine eligible instrument sets. Three excluded instruments = exactly identified; four = one overidentifying restriction; five = two. Tax plus lag alone has only two instruments and is not fitted because three endogenous regressors would be underidentified by the order condition.

All coefficient and structural-residual QR checks pass; SW statistics for all three endogenous variables use numerator df L-3+1 and pass independent conditional-IV residual and full-design sandwich checks. All original fits/inputs remain unchanged. No overidentification test or exclusion validity is claimed. Lag quality requires orthogonality to current demand errors despite possible persistence. These conventional estimates and intervals do not establish adequate identification.

## Unweighted price / B / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.112 (0.070) | -0.105 (0.069) | -0.301 (0.067) | 2.971 (0.384) | 2.856 (0.392) | 3.098 (0.467) | 0.009 (0.010) | 0.011 (0.011) | 0.066 (0.011) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.102 (0.074) | -0.097 (0.072) | -0.289 (0.071) | 3.137 (0.446) | 3.000 (0.452) | 3.305 (0.542) | 0.003 (0.012) | 0.006 (0.013) | 0.058 (0.014) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.224 (0.033) | -0.210 (0.036) | -0.382 (0.052) | 1.041 (0.189) | 1.037 (0.191) | 1.691 (0.231) | 0.082 (0.009) | 0.080 (0.010) | 0.119 (0.014) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.212 (0.038) | -0.211 (0.038) | -0.352 (0.067) | 1.241 (0.274) | 1.025 (0.272) | 2.219 (0.377) | 0.075 (0.012) | 0.081 (0.012) | 0.099 (0.019) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.134 (0.032) | -0.125 (0.034) | -0.317 (0.044) | 1.267 (0.182) | 1.249 (0.185) | 1.856 (0.205) | 0.063 (0.008) | 0.062 (0.009) | 0.105 (0.011) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.128 (0.047) | -0.122 (0.046) | -0.309 (0.058) | 1.984 (0.213) | 1.811 (0.216) | 2.596 (0.286) | 0.041 (0.010) | 0.045 (0.010) | 0.082 (0.012) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.131 (0.031) | -0.123 (0.034) | -0.311 (0.043) | 1.208 (0.186) | 1.193 (0.188) | 1.820 (0.207) | 0.064 (0.008) | 0.063 (0.009) | 0.105 (0.011) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.123 (0.046) | -0.118 (0.044) | -0.300 (0.059) | 1.931 (0.231) | 1.744 (0.231) | 2.614 (0.309) | 0.042 (0.010) | 0.046 (0.011) | 0.080 (0.013) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.222 (0.032) | -0.210 (0.036) | -0.378 (0.050) | 1.026 (0.190) | 1.038 (0.193) | 1.651 (0.235) | 0.083 (0.009) | 0.080 (0.010) | 0.119 (0.014) |

## Unweighted price / B / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | 0.022 (0.076) | 0.030 (0.079) | -0.269 (0.078) | 2.371 (0.249) | 2.244 (0.261) | 2.879 (0.351) | 0.036 (0.006) | 0.036 (0.007) | 0.102 (0.007) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.029 (0.077) | 0.034 (0.079) | -0.256 (0.080) | 2.396 (0.253) | 2.260 (0.266) | 2.925 (0.354) | 0.036 (0.006) | 0.036 (0.007) | 0.100 (0.007) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.313 (0.101) | -0.277 (0.106) | -0.560 (0.138) | 1.211 (0.182) | 1.180 (0.173) | 1.870 (0.238) | 0.076 (0.010) | 0.072 (0.010) | 0.136 (0.014) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.260 (0.100) | -0.274 (0.103) | -0.450 (0.144) | 1.397 (0.216) | 1.190 (0.224) | 2.251 (0.272) | 0.069 (0.009) | 0.072 (0.010) | 0.123 (0.014) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.024 (0.056) | 0.032 (0.061) | -0.267 (0.056) | 1.195 (0.133) | 1.166 (0.147) | 1.856 (0.151) | 0.052 (0.007) | 0.051 (0.008) | 0.116 (0.007) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.012 (0.064) | 0.019 (0.066) | -0.275 (0.070) | 1.735 (0.149) | 1.556 (0.159) | 2.469 (0.213) | 0.045 (0.006) | 0.046 (0.007) | 0.108 (0.007) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.023 (0.057) | 0.029 (0.062) | -0.261 (0.057) | 1.171 (0.135) | 1.144 (0.148) | 1.834 (0.151) | 0.053 (0.007) | 0.052 (0.008) | 0.116 (0.007) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.017 (0.063) | 0.021 (0.066) | -0.264 (0.070) | 1.709 (0.151) | 1.524 (0.161) | 2.462 (0.212) | 0.045 (0.006) | 0.046 (0.007) | 0.107 (0.007) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.296 (0.095) | -0.276 (0.102) | -0.525 (0.129) | 1.207 (0.178) | 1.180 (0.174) | 1.862 (0.228) | 0.075 (0.009) | 0.072 (0.010) | 0.134 (0.013) |

## Unweighted price / S / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.116 (0.087) | -0.107 (0.086) | -0.358 (0.074) | 2.961 (0.364) | 2.850 (0.378) | 2.928 (0.391) | 0.009 (0.009) | 0.011 (0.010) | 0.053 (0.010) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.101 (0.092) | -0.094 (0.090) | -0.339 (0.080) | 3.141 (0.435) | 3.006 (0.443) | 3.168 (0.474) | 0.004 (0.011) | 0.007 (0.012) | 0.046 (0.012) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.265 (0.036) | -0.249 (0.041) | -0.450 (0.054) | 1.096 (0.172) | 1.087 (0.176) | 1.781 (0.182) | 0.062 (0.006) | 0.061 (0.006) | 0.085 (0.008) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.260 (0.041) | -0.260 (0.043) | -0.424 (0.069) | 1.168 (0.251) | 0.950 (0.254) | 2.108 (0.315) | 0.060 (0.007) | 0.065 (0.008) | 0.076 (0.011) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.190 (0.040) | -0.177 (0.043) | -0.404 (0.051) | 1.288 (0.171) | 1.268 (0.174) | 1.899 (0.172) | 0.054 (0.005) | 0.054 (0.006) | 0.081 (0.007) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.156 (0.059) | -0.150 (0.057) | -0.377 (0.066) | 1.931 (0.212) | 1.758 (0.217) | 2.457 (0.241) | 0.036 (0.007) | 0.040 (0.007) | 0.065 (0.008) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.182 (0.039) | -0.170 (0.042) | -0.394 (0.050) | 1.231 (0.174) | 1.213 (0.178) | 1.872 (0.173) | 0.055 (0.005) | 0.055 (0.006) | 0.081 (0.007) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.148 (0.058) | -0.143 (0.055) | -0.364 (0.067) | 1.884 (0.231) | 1.696 (0.233) | 2.493 (0.268) | 0.037 (0.007) | 0.042 (0.008) | 0.064 (0.009) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.266 (0.036) | -0.247 (0.041) | -0.454 (0.053) | 1.091 (0.173) | 1.098 (0.178) | 1.755 (0.188) | 0.062 (0.006) | 0.061 (0.006) | 0.086 (0.008) |

## Unweighted price / S / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.004 (0.086) | 0.010 (0.089) | -0.341 (0.082) | 2.291 (0.206) | 2.181 (0.222) | 2.652 (0.275) | 0.016 (0.013) | 0.020 (0.013) | 0.044 (0.017) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.006 (0.087) | 0.016 (0.089) | -0.322 (0.084) | 2.323 (0.213) | 2.202 (0.229) | 2.716 (0.279) | 0.016 (0.013) | 0.020 (0.013) | 0.044 (0.018) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.306 (0.090) | -0.271 (0.097) | -0.549 (0.115) | 1.250 (0.174) | 1.214 (0.171) | 1.935 (0.202) | 0.024 (0.010) | 0.028 (0.011) | 0.050 (0.014) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.275 (0.093) | -0.289 (0.098) | -0.475 (0.123) | 1.360 (0.202) | 1.154 (0.210) | 2.191 (0.243) | 0.023 (0.010) | 0.028 (0.011) | 0.048 (0.015) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.061 (0.069) | -0.043 (0.074) | -0.380 (0.075) | 1.337 (0.127) | 1.295 (0.137) | 1.995 (0.156) | 0.034 (0.007) | 0.037 (0.008) | 0.056 (0.012) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.036 (0.075) | -0.026 (0.078) | -0.357 (0.080) | 1.766 (0.133) | 1.603 (0.144) | 2.392 (0.190) | 0.025 (0.009) | 0.031 (0.009) | 0.049 (0.015) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.054 (0.068) | -0.039 (0.073) | -0.366 (0.074) | 1.299 (0.130) | 1.259 (0.140) | 1.971 (0.153) | 0.035 (0.007) | 0.038 (0.008) | 0.058 (0.012) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.027 (0.074) | -0.020 (0.076) | -0.340 (0.080) | 1.739 (0.136) | 1.567 (0.147) | 2.397 (0.189) | 0.027 (0.009) | 0.032 (0.009) | 0.050 (0.015) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.303 (0.088) | -0.273 (0.096) | -0.541 (0.113) | 1.254 (0.172) | 1.212 (0.170) | 1.944 (0.198) | 0.024 (0.010) | 0.028 (0.011) | 0.050 (0.014) |

## Unweighted price / V / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.204 (0.109) | -0.186 (0.106) | -0.468 (0.122) | 3.549 (0.669) | 3.360 (0.671) | 4.145 (0.860) | -0.001 (0.015) | 0.003 (0.016) | 0.048 (0.018) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.204 (0.115) | -0.185 (0.112) | -0.468 (0.130) | 3.756 (0.775) | 3.540 (0.767) | 4.395 (0.994) | -0.007 (0.018) | -0.003 (0.019) | 0.039 (0.022) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.211 (0.042) | -0.192 (0.044) | -0.474 (0.060) | 1.001 (0.234) | 0.978 (0.233) | 1.992 (0.333) | 0.083 (0.009) | 0.080 (0.009) | 0.118 (0.015) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.211 (0.045) | -0.192 (0.044) | -0.473 (0.072) | 1.238 (0.317) | 0.981 (0.312) | 2.498 (0.469) | 0.075 (0.011) | 0.080 (0.011) | 0.101 (0.019) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.084 (0.035) | -0.073 (0.037) | -0.366 (0.044) | 1.021 (0.215) | 0.996 (0.223) | 2.009 (0.289) | 0.065 (0.008) | 0.064 (0.008) | 0.103 (0.012) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.120 (0.048) | -0.099 (0.045) | -0.408 (0.068) | 1.817 (0.293) | 1.577 (0.293) | 2.911 (0.414) | 0.044 (0.010) | 0.049 (0.010) | 0.080 (0.014) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.079 (0.035) | -0.069 (0.036) | -0.359 (0.042) | 0.965 (0.214) | 0.944 (0.223) | 1.961 (0.287) | 0.067 (0.007) | 0.065 (0.008) | 0.104 (0.012) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.111 (0.046) | -0.091 (0.043) | -0.398 (0.065) | 1.740 (0.305) | 1.491 (0.303) | 2.876 (0.426) | 0.046 (0.011) | 0.051 (0.011) | 0.079 (0.014) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.210 (0.042) | -0.192 (0.044) | -0.472 (0.059) | 0.993 (0.234) | 0.978 (0.234) | 1.974 (0.336) | 0.083 (0.009) | 0.080 (0.009) | 0.118 (0.015) |

## Unweighted price / V / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | 0.036 (0.072) | 0.048 (0.073) | -0.290 (0.081) | 2.285 (0.260) | 2.134 (0.280) | 3.003 (0.357) | 0.041 (0.007) | 0.042 (0.008) | 0.095 (0.010) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.043 (0.073) | 0.054 (0.073) | -0.279 (0.082) | 2.316 (0.267) | 2.156 (0.286) | 3.048 (0.364) | 0.040 (0.007) | 0.042 (0.008) | 0.093 (0.010) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.255 (0.090) | -0.215 (0.095) | -0.565 (0.130) | 1.098 (0.188) | 1.059 (0.183) | 1.878 (0.259) | 0.084 (0.009) | 0.081 (0.009) | 0.135 (0.016) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.196 (0.092) | -0.200 (0.096) | -0.469 (0.130) | 1.336 (0.215) | 1.118 (0.226) | 2.269 (0.291) | 0.075 (0.009) | 0.079 (0.009) | 0.121 (0.016) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.075 (0.049) | 0.083 (0.053) | -0.253 (0.049) | 1.003 (0.145) | 0.974 (0.163) | 1.789 (0.167) | 0.065 (0.006) | 0.064 (0.007) | 0.118 (0.009) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.051 (0.055) | 0.065 (0.057) | -0.278 (0.064) | 1.556 (0.173) | 1.353 (0.187) | 2.439 (0.224) | 0.055 (0.006) | 0.057 (0.007) | 0.106 (0.010) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.075 (0.049) | 0.083 (0.053) | -0.248 (0.049) | 0.985 (0.145) | 0.958 (0.163) | 1.770 (0.166) | 0.065 (0.006) | 0.064 (0.007) | 0.118 (0.009) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.057 (0.055) | 0.068 (0.057) | -0.268 (0.064) | 1.536 (0.175) | 1.330 (0.189) | 2.428 (0.224) | 0.055 (0.006) | 0.057 (0.007) | 0.105 (0.010) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.234 (0.086) | -0.209 (0.093) | -0.531 (0.120) | 1.101 (0.182) | 1.060 (0.182) | 1.883 (0.246) | 0.082 (0.008) | 0.081 (0.009) | 0.133 (0.015) |

## Unweighted price / SV / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.205 (0.106) | -0.186 (0.104) | -0.469 (0.097) | 3.491 (0.611) | 3.319 (0.624) | 3.589 (0.653) | -0.001 (0.015) | 0.002 (0.015) | 0.040 (0.015) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.204 (0.115) | -0.185 (0.112) | -0.468 (0.108) | 3.738 (0.737) | 3.533 (0.737) | 3.920 (0.807) | -0.008 (0.017) | -0.003 (0.018) | 0.032 (0.019) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.211 (0.037) | -0.192 (0.040) | -0.473 (0.046) | 0.924 (0.211) | 0.908 (0.219) | 1.853 (0.269) | 0.064 (0.006) | 0.064 (0.006) | 0.085 (0.009) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.210 (0.038) | -0.192 (0.039) | -0.472 (0.054) | 1.071 (0.288) | 0.817 (0.293) | 2.203 (0.395) | 0.060 (0.007) | 0.066 (0.008) | 0.076 (0.011) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.136 (0.036) | -0.121 (0.038) | -0.423 (0.043) | 1.022 (0.212) | 1.000 (0.221) | 1.919 (0.258) | 0.059 (0.005) | 0.058 (0.006) | 0.081 (0.008) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.147 (0.047) | -0.127 (0.045) | -0.436 (0.058) | 1.716 (0.298) | 1.483 (0.300) | 2.572 (0.361) | 0.041 (0.008) | 0.046 (0.008) | 0.065 (0.010) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.124 (0.036) | -0.111 (0.037) | -0.410 (0.041) | 0.962 (0.210) | 0.943 (0.221) | 1.881 (0.255) | 0.060 (0.005) | 0.059 (0.006) | 0.081 (0.008) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.135 (0.045) | -0.115 (0.043) | -0.424 (0.057) | 1.646 (0.310) | 1.402 (0.310) | 2.573 (0.381) | 0.043 (0.008) | 0.048 (0.008) | 0.064 (0.010) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.212 (0.037) | -0.191 (0.039) | -0.477 (0.047) | 0.921 (0.211) | 0.910 (0.220) | 1.845 (0.272) | 0.064 (0.006) | 0.064 (0.006) | 0.085 (0.009) |

## Unweighted price / SV / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | 0.016 (0.079) | 0.034 (0.081) | -0.355 (0.082) | 2.199 (0.213) | 2.070 (0.235) | 2.718 (0.274) | 0.024 (0.013) | 0.030 (0.013) | 0.039 (0.018) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.026 (0.079) | 0.041 (0.081) | -0.338 (0.083) | 2.238 (0.222) | 2.098 (0.243) | 2.784 (0.284) | 0.023 (0.013) | 0.029 (0.014) | 0.038 (0.018) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.245 (0.079) | -0.207 (0.085) | -0.546 (0.105) | 1.124 (0.175) | 1.081 (0.175) | 1.929 (0.218) | 0.040 (0.010) | 0.044 (0.011) | 0.050 (0.016) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.203 (0.083) | -0.206 (0.089) | -0.481 (0.107) | 1.299 (0.195) | 1.085 (0.206) | 2.196 (0.256) | 0.037 (0.009) | 0.044 (0.011) | 0.046 (0.016) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.006 (0.059) | 0.013 (0.063) | -0.371 (0.067) | 1.161 (0.141) | 1.115 (0.156) | 1.956 (0.167) | 0.052 (0.008) | 0.055 (0.009) | 0.059 (0.012) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.006 (0.065) | 0.023 (0.067) | -0.360 (0.074) | 1.613 (0.153) | 1.429 (0.170) | 2.378 (0.199) | 0.040 (0.008) | 0.047 (0.009) | 0.048 (0.016) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.002 (0.058) | 0.019 (0.062) | -0.357 (0.065) | 1.127 (0.142) | 1.084 (0.157) | 1.931 (0.165) | 0.053 (0.008) | 0.057 (0.009) | 0.061 (0.012) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.017 (0.064) | 0.031 (0.065) | -0.344 (0.073) | 1.590 (0.158) | 1.399 (0.174) | 2.378 (0.200) | 0.041 (0.008) | 0.048 (0.009) | 0.049 (0.015) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.241 (0.078) | -0.207 (0.085) | -0.540 (0.104) | 1.139 (0.172) | 1.082 (0.173) | 1.952 (0.212) | 0.040 (0.010) | 0.044 (0.011) | 0.050 (0.015) |

## Volume-weighted price / B / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.120 (0.069) | -0.113 (0.068) | -0.323 (0.054) | 2.624 (0.298) | 2.530 (0.320) | 2.164 (0.305) | 0.012 (0.011) | 0.014 (0.012) | 0.073 (0.010) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.113 (0.074) | -0.107 (0.073) | -0.319 (0.056) | 2.758 (0.346) | 2.643 (0.367) | 2.236 (0.344) | 0.008 (0.012) | 0.010 (0.013) | 0.070 (0.011) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.237 (0.027) | -0.222 (0.030) | -0.404 (0.037) | 0.416 (0.224) | 0.449 (0.240) | 0.623 (0.262) | 0.085 (0.008) | 0.083 (0.009) | 0.124 (0.011) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.251 (0.036) | -0.249 (0.043) | -0.416 (0.041) | 0.147 (0.346) | -0.063 (0.387) | 0.404 (0.387) | 0.094 (0.012) | 0.100 (0.014) | 0.131 (0.014) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.150 (0.028) | -0.141 (0.031) | -0.344 (0.032) | 0.874 (0.233) | 0.881 (0.240) | 0.942 (0.241) | 0.066 (0.009) | 0.064 (0.009) | 0.110 (0.010) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.109 (0.039) | -0.101 (0.039) | -0.315 (0.034) | 1.543 (0.284) | 1.399 (0.295) | 1.397 (0.273) | 0.043 (0.011) | 0.046 (0.011) | 0.095 (0.010) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.161 (0.028) | -0.152 (0.031) | -0.353 (0.033) | 0.794 (0.236) | 0.804 (0.243) | 0.883 (0.249) | 0.069 (0.009) | 0.068 (0.009) | 0.113 (0.010) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.116 (0.039) | -0.109 (0.039) | -0.321 (0.035) | 1.451 (0.313) | 1.288 (0.321) | 1.319 (0.301) | 0.046 (0.012) | 0.050 (0.012) | 0.098 (0.011) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.227 (0.026) | -0.204 (0.028) | -0.397 (0.036) | 0.448 (0.225) | 0.509 (0.240) | 0.648 (0.260) | 0.084 (0.008) | 0.080 (0.009) | 0.123 (0.011) |

## Volume-weighted price / B / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | 0.041 (0.146) | 0.057 (0.152) | -0.511 (0.146) | 2.427 (0.230) | 2.323 (0.260) | 2.173 (0.289) | 0.042 (0.018) | 0.044 (0.018) | 0.034 (0.020) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.057 (0.156) | 0.069 (0.161) | -0.509 (0.152) | 2.479 (0.248) | 2.360 (0.279) | 2.179 (0.306) | 0.043 (0.019) | 0.045 (0.018) | 0.035 (0.020) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.773 (0.286) | -0.684 (0.284) | -1.382 (0.443) | -0.183 (0.707) | -0.053 (0.674) | -0.624 (1.092) | -0.015 (0.025) | -0.008 (0.025) | -0.026 (0.035) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -1.011 (0.569) | -1.069 (0.624) | -1.754 (0.870) | -0.948 (1.572) | -1.289 (1.699) | -1.817 (2.417) | -0.032 (0.046) | -0.035 (0.050) | -0.052 (0.067) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.199 (0.108) | 0.201 (0.118) | -0.341 (0.066) | 1.459 (0.238) | 1.441 (0.264) | 1.135 (0.222) | 0.073 (0.009) | 0.072 (0.009) | 0.068 (0.008) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.216 (0.111) | 0.244 (0.120) | -0.304 (0.072) | 2.033 (0.240) | 1.902 (0.276) | 1.707 (0.189) | 0.067 (0.010) | 0.071 (0.010) | 0.064 (0.010) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.180 (0.115) | 0.180 (0.125) | -0.380 (0.076) | 1.420 (0.252) | 1.400 (0.277) | 1.064 (0.255) | 0.071 (0.009) | 0.071 (0.010) | 0.065 (0.009) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.230 (0.120) | 0.253 (0.129) | -0.307 (0.077) | 2.065 (0.264) | 1.919 (0.299) | 1.695 (0.205) | 0.068 (0.011) | 0.071 (0.011) | 0.064 (0.010) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.652 (0.250) | -0.489 (0.231) | -1.195 (0.384) | -0.005 (0.624) | 0.234 (0.555) | -0.347 (0.946) | -0.004 (0.021) | 0.010 (0.020) | -0.009 (0.030) |

## Volume-weighted price / S / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.119 (0.082) | -0.110 (0.082) | -0.369 (0.054) | 2.631 (0.336) | 2.545 (0.358) | 1.906 (0.302) | 0.012 (0.009) | 0.014 (0.010) | 0.064 (0.008) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.109 (0.090) | -0.101 (0.088) | -0.364 (0.058) | 2.785 (0.398) | 2.674 (0.418) | 1.975 (0.346) | 0.008 (0.011) | 0.011 (0.012) | 0.062 (0.009) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.272 (0.030) | -0.254 (0.034) | -0.461 (0.037) | 0.367 (0.220) | 0.404 (0.240) | 0.543 (0.233) | 0.070 (0.007) | 0.068 (0.007) | 0.099 (0.007) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.308 (0.057) | -0.308 (0.068) | -0.503 (0.057) | -0.178 (0.421) | -0.396 (0.495) | -0.091 (0.414) | 0.083 (0.011) | 0.089 (0.014) | 0.115 (0.012) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.198 (0.032) | -0.185 (0.035) | -0.417 (0.034) | 0.757 (0.238) | 0.773 (0.249) | 0.778 (0.226) | 0.060 (0.007) | 0.059 (0.008) | 0.093 (0.007) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.120 (0.047) | -0.111 (0.046) | -0.369 (0.033) | 1.484 (0.328) | 1.344 (0.337) | 1.091 (0.262) | 0.041 (0.009) | 0.045 (0.010) | 0.085 (0.008) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.210 (0.031) | -0.196 (0.035) | -0.424 (0.034) | 0.677 (0.238) | 0.695 (0.249) | 0.727 (0.230) | 0.062 (0.007) | 0.061 (0.008) | 0.094 (0.007) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.130 (0.047) | -0.124 (0.046) | -0.379 (0.034) | 1.369 (0.359) | 1.207 (0.366) | 0.988 (0.286) | 0.044 (0.010) | 0.048 (0.011) | 0.087 (0.008) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.244 (0.028) | -0.214 (0.031) | -0.429 (0.035) | 0.449 (0.226) | 0.524 (0.245) | 0.639 (0.234) | 0.067 (0.007) | 0.065 (0.007) | 0.096 (0.007) |

## Volume-weighted price / S / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.007 (0.180) | 0.021 (0.188) | -0.712 (0.166) | 2.280 (0.273) | 2.213 (0.299) | 1.558 (0.337) | 0.015 (0.040) | 0.024 (0.041) | -0.077 (0.036) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.013 (0.192) | 0.035 (0.199) | -0.709 (0.172) | 2.343 (0.302) | 2.259 (0.328) | 1.568 (0.363) | 0.018 (0.042) | 0.026 (0.043) | -0.077 (0.037) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.744 (0.241) | -0.659 (0.246) | -1.333 (0.356) | -0.063 (0.564) | 0.052 (0.551) | -0.417 (0.836) | -0.102 (0.045) | -0.084 (0.046) | -0.176 (0.063) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -1.165 (0.700) | -1.225 (0.777) | -2.014 (1.061) | -1.401 (1.819) | -1.749 (2.005) | -2.585 (2.773) | -0.168 (0.120) | -0.173 (0.132) | -0.284 (0.180) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.023 (0.135) | 0.049 (0.148) | -0.686 (0.125) | 1.291 (0.271) | 1.301 (0.292) | 0.725 (0.341) | 0.044 (0.025) | 0.051 (0.027) | -0.053 (0.022) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.211 (0.141) | 0.256 (0.153) | -0.467 (0.086) | 2.051 (0.288) | 1.967 (0.325) | 1.301 (0.226) | 0.070 (0.027) | 0.084 (0.028) | -0.015 (0.018) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.020 (0.142) | 0.006 (0.155) | -0.735 (0.143) | 1.211 (0.289) | 1.220 (0.308) | 0.634 (0.384) | 0.036 (0.026) | 0.043 (0.028) | -0.062 (0.025) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.226 (0.152) | 0.264 (0.164) | -0.472 (0.091) | 2.086 (0.319) | 1.984 (0.356) | 1.283 (0.246) | 0.073 (0.029) | 0.085 (0.030) | -0.016 (0.019) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.533 (0.186) | -0.375 (0.183) | -0.992 (0.262) | 0.230 (0.472) | 0.445 (0.439) | 0.056 (0.654) | -0.060 (0.036) | -0.027 (0.035) | -0.108 (0.046) |

## Volume-weighted price / V / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.168 (0.070) | -0.153 (0.069) | -0.386 (0.058) | 2.765 (0.391) | 2.648 (0.409) | 2.348 (0.394) | 0.008 (0.014) | 0.011 (0.015) | 0.068 (0.012) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.168 (0.073) | -0.153 (0.072) | -0.386 (0.059) | 2.877 (0.437) | 2.742 (0.451) | 2.380 (0.424) | 0.005 (0.015) | 0.008 (0.016) | 0.067 (0.013) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.174 (0.029) | -0.158 (0.030) | -0.390 (0.030) | 0.388 (0.200) | 0.421 (0.218) | 0.616 (0.265) | 0.085 (0.007) | 0.083 (0.008) | 0.124 (0.011) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.174 (0.029) | -0.158 (0.032) | -0.390 (0.031) | 0.333 (0.283) | 0.157 (0.311) | 0.467 (0.332) | 0.087 (0.010) | 0.091 (0.011) | 0.129 (0.012) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.098 (0.027) | -0.087 (0.028) | -0.335 (0.025) | 0.763 (0.214) | 0.772 (0.225) | 0.890 (0.253) | 0.069 (0.008) | 0.067 (0.009) | 0.112 (0.010) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.088 (0.030) | -0.071 (0.030) | -0.324 (0.025) | 1.326 (0.289) | 1.174 (0.297) | 1.235 (0.288) | 0.050 (0.010) | 0.053 (0.011) | 0.100 (0.010) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.106 (0.027) | -0.095 (0.029) | -0.342 (0.026) | 0.713 (0.214) | 0.724 (0.226) | 0.847 (0.257) | 0.071 (0.008) | 0.069 (0.009) | 0.114 (0.010) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.092 (0.030) | -0.076 (0.029) | -0.329 (0.025) | 1.260 (0.302) | 1.099 (0.309) | 1.164 (0.299) | 0.052 (0.011) | 0.056 (0.011) | 0.103 (0.011) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.171 (0.027) | -0.146 (0.028) | -0.383 (0.030) | 0.391 (0.199) | 0.433 (0.215) | 0.623 (0.264) | 0.085 (0.007) | 0.082 (0.008) | 0.123 (0.011) |

## Volume-weighted price / V / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | 0.065 (0.132) | 0.088 (0.136) | -0.525 (0.142) | 2.384 (0.236) | 2.268 (0.272) | 2.199 (0.317) | 0.049 (0.016) | 0.053 (0.016) | 0.030 (0.020) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.082 (0.140) | 0.101 (0.143) | -0.525 (0.146) | 2.448 (0.255) | 2.319 (0.290) | 2.200 (0.332) | 0.050 (0.016) | 0.054 (0.016) | 0.030 (0.020) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.555 (0.197) | -0.467 (0.203) | -1.230 (0.319) | 0.040 (0.507) | 0.168 (0.489) | -0.469 (0.886) | 0.022 (0.017) | 0.029 (0.017) | -0.000 (0.021) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.579 (0.286) | -0.590 (0.306) | -1.383 (0.474) | -0.053 (0.842) | -0.297 (0.890) | -1.048 (1.469) | 0.021 (0.021) | 0.024 (0.022) | -0.007 (0.030) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.238 (0.094) | 0.243 (0.102) | -0.328 (0.062) | 1.378 (0.216) | 1.367 (0.246) | 1.054 (0.229) | 0.091 (0.009) | 0.091 (0.009) | 0.078 (0.009) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.225 (0.097) | 0.256 (0.105) | -0.312 (0.068) | 1.922 (0.233) | 1.781 (0.270) | 1.583 (0.208) | 0.078 (0.010) | 0.083 (0.010) | 0.068 (0.010) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.230 (0.099) | 0.233 (0.107) | -0.361 (0.068) | 1.362 (0.225) | 1.349 (0.255) | 0.996 (0.253) | 0.090 (0.009) | 0.090 (0.009) | 0.075 (0.009) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.241 (0.104) | 0.268 (0.112) | -0.318 (0.071) | 1.958 (0.254) | 1.807 (0.288) | 1.563 (0.221) | 0.079 (0.010) | 0.084 (0.010) | 0.068 (0.010) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.539 (0.190) | -0.388 (0.180) | -1.132 (0.314) | 0.061 (0.493) | 0.273 (0.436) | -0.337 (0.842) | 0.024 (0.015) | 0.037 (0.015) | 0.009 (0.021) |

## Volume-weighted price / SV / No firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | -0.168 (0.071) | -0.153 (0.071) | -0.386 (0.044) | 2.780 (0.471) | 2.674 (0.487) | 1.958 (0.381) | 0.008 (0.013) | 0.011 (0.014) | 0.063 (0.009) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | -0.168 (0.075) | -0.153 (0.074) | -0.386 (0.046) | 2.911 (0.527) | 2.783 (0.537) | 2.021 (0.416) | 0.005 (0.014) | 0.008 (0.015) | 0.061 (0.010) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.173 (0.027) | -0.158 (0.028) | -0.389 (0.027) | 0.328 (0.178) | 0.366 (0.206) | 0.515 (0.214) | 0.071 (0.006) | 0.070 (0.006) | 0.099 (0.007) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.174 (0.029) | -0.158 (0.033) | -0.390 (0.031) | 0.187 (0.255) | 0.011 (0.303) | 0.217 (0.269) | 0.074 (0.007) | 0.079 (0.009) | 0.107 (0.008) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.130 (0.026) | -0.117 (0.027) | -0.364 (0.024) | 0.619 (0.205) | 0.640 (0.223) | 0.686 (0.220) | 0.063 (0.006) | 0.063 (0.007) | 0.095 (0.007) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.106 (0.028) | -0.089 (0.028) | -0.344 (0.022) | 1.155 (0.315) | 1.005 (0.324) | 0.867 (0.261) | 0.050 (0.009) | 0.053 (0.009) | 0.090 (0.008) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | -0.134 (0.026) | -0.121 (0.027) | -0.366 (0.024) | 0.579 (0.203) | 0.600 (0.221) | 0.661 (0.219) | 0.064 (0.006) | 0.064 (0.007) | 0.096 (0.007) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | -0.109 (0.028) | -0.092 (0.028) | -0.347 (0.022) | 1.088 (0.322) | 0.928 (0.330) | 0.814 (0.266) | 0.051 (0.009) | 0.055 (0.009) | 0.092 (0.008) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.167 (0.025) | -0.140 (0.026) | -0.375 (0.026) | 0.339 (0.177) | 0.394 (0.204) | 0.538 (0.213) | 0.070 (0.005) | 0.069 (0.006) | 0.099 (0.007) |

## Volume-weighted price / SV / Firm FE

| Complete excluded instruments | L | Over-ID df | Alpha annual | Alpha monthly | Alpha constant | Sigma annual | Sigma monthly | Sigma constant | Quality slope annual | Quality slope monthly | Quality slope constant |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Geographic tax + National active-brand count + Lagged quality | 3 | 0 | 0.032 (0.156) | 0.066 (0.162) | -0.691 (0.148) | 2.253 (0.266) | 2.182 (0.295) | 1.544 (0.342) | 0.029 (0.034) | 0.040 (0.034) | -0.070 (0.033) |
| Geographic tax + Geographic active-brand count + Lagged quality | 3 | 0 | 0.052 (0.165) | 0.082 (0.170) | -0.686 (0.152) | 2.331 (0.291) | 2.245 (0.320) | 1.561 (0.359) | 0.032 (0.035) | 0.042 (0.035) | -0.069 (0.033) |
| Geographic tax + Annual incumbent count + Lagged quality | 3 | 0 | -0.523 (0.161) | -0.441 (0.171) | -1.165 (0.249) | 0.140 (0.398) | 0.252 (0.399) | -0.263 (0.666) | -0.041 (0.030) | -0.024 (0.032) | -0.129 (0.041) |
| Geographic tax + Monthly >7% count + Lagged quality | 3 | 0 | -0.612 (0.268) | -0.622 (0.295) | -1.455 (0.453) | -0.201 (0.757) | -0.439 (0.833) | -1.369 (1.315) | -0.052 (0.044) | -0.046 (0.048) | -0.166 (0.070) |
| Geographic tax + National active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.081 (0.114) | 0.111 (0.125) | -0.648 (0.105) | 1.245 (0.234) | 1.262 (0.259) | 0.682 (0.327) | 0.069 (0.021) | 0.077 (0.023) | -0.035 (0.018) |
| Geographic tax + National active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.206 (0.122) | 0.252 (0.132) | -0.484 (0.080) | 1.932 (0.269) | 1.839 (0.305) | 1.162 (0.238) | 0.079 (0.023) | 0.094 (0.023) | -0.010 (0.016) |
| Geographic tax + Geographic active-brand count + Annual incumbent count + Lagged quality | 4 | 1 | 0.057 (0.118) | 0.087 (0.128) | -0.682 (0.114) | 1.198 (0.244) | 1.214 (0.267) | 0.618 (0.352) | 0.065 (0.022) | 0.072 (0.023) | -0.041 (0.019) |
| Geographic tax + Geographic active-brand count + Monthly >7% count + Lagged quality | 4 | 1 | 0.221 (0.129) | 0.262 (0.139) | -0.490 (0.083) | 1.968 (0.293) | 1.860 (0.327) | 1.141 (0.252) | 0.082 (0.024) | 0.096 (0.024) | -0.011 (0.017) |
| Geographic tax + Annual incumbent count + Monthly >7% count + Lagged quality | 4 | 1 | -0.460 (0.140) | -0.313 (0.140) | -0.961 (0.218) | 0.220 (0.371) | 0.413 (0.344) | -0.004 (0.590) | -0.028 (0.026) | 0.002 (0.027) | -0.089 (0.035) |
