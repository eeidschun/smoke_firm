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
