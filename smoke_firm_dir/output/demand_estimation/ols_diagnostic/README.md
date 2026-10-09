# OLS diagnostic: firm FE, no month FE

540 observations; 9 firms; 132 month clusters. Both price and within-nest share are uninstrumented.
Alpha is the signed price coefficient. There is only one OLS specification: the count instruments are not used.

| Parameter | Estimate | Clustered SE | 95% CI |
|---|---:|---:|---|
| alpha | -0.04645 | 0.01643 | [-0.07895, -0.01396] |
| sigma | 0.91102 | 0.05181 | [0.80852, 1.01352] |
| beta_a | 0.05657 | 0.00499 | [0.04670, 0.06645] |

The point estimate of sigma is inside [0,1), but its 95% confidence interval includes 1.
The prior firm-FE IV sigma estimates are 3.85986 (national count) and 3.94210 (geographic count).
This contrast motivates investigation of the identifying variation and joint instrument strength; it does not establish instrument invalidity. OLS may be biased by endogeneity of both regressors.
The dependent variable also equals within-nest log share plus log(s_g/s_0), so an OLS slope near one is not independent validation of the structural specification.
Coefficients and residuals were verified with an independent explicit-firm-dummy OLS regression. No cost recovery is performed.
