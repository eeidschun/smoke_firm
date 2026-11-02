# Tax weighting: admissible-sigma families

Analysis date: 2026-10-27. Meeting date: TBD.

Each tax definition has 1,776 national firm-month fits (1,344 exogenous-quality and 432 endogenous-quality), including the original 48 designs. Strict qualification is 0 < sigma < 1. Samples, prices, controls and other instruments are matched. Sales means brand-specific current liquid-volume weights across states; population means the existing geographic population weights. Means and medians use only qualifying runs, with equal weight per specification; a dash means no qualifying runs. Counts include repeated sample comparisons and do not establish instrument validity.

## overall

| tax_weights | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|
| population | 357 / 1776 | 20.1% | 354 | 0.573 | 0.616 |
| sales | 707 / 1776 | 39.8% | 374 | 0.780 | 0.831 |

## price_FE

| tax_weights | price_measure | firm_FE | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|---|
| population | p_it | TRUE | 7 / 444 | 1.6% | 4 | 0.769 | 0.871 |
| population | p_it_volume_weighted | TRUE | 83 / 444 | 18.7% | 83 | 0.319 | 0.234 |
| population | p_it | FALSE | 35 / 444 | 7.9% | 35 | 0.948 | 0.950 |
| population | p_it_volume_weighted | FALSE | 232 / 444 | 52.3% | 232 | 0.601 | 0.624 |
| sales | p_it | TRUE | 156 / 444 | 35.1% | 42 | 0.791 | 0.798 |
| sales | p_it_volume_weighted | TRUE | 174 / 444 | 39.2% | 167 | 0.641 | 0.744 |
| sales | p_it | FALSE | 142 / 444 | 32.0% | 16 | 0.786 | 0.826 |
| sales | p_it_volume_weighted | FALSE | 235 / 444 | 52.9% | 149 | 0.871 | 0.880 |

## quality

| tax_weights | quality | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|
| population | Exogenous | 260 / 1344 | 19.3% | 260 | 0.559 | 0.577 |
| population | Endogenous | 97 / 432 | 22.5% | 94 | 0.611 | 0.639 |
| sales | Exogenous | 517 / 1344 | 38.5% | 291 | 0.782 | 0.831 |
| sales | Endogenous | 190 / 432 | 44.0% | 83 | 0.775 | 0.830 |

## instrument

| tax_weights | instrument_set | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|
| population | Annual | 40 / 96 | 41.7% | 40 | 0.417 | 0.402 |
| population | Annual_Monthly | 46 / 96 | 47.9% | 46 | 0.424 | 0.418 |
| population | Geographic | 0 / 96 | 0.0% | 0 | — | — |
| population | Geographic+incumbent_annual | 31 / 96 | 32.3% | 31 | 0.758 | 0.738 |
| population | Geographic+incumbent_monthly | 4 / 96 | 4.2% | 4 | 0.900 | 0.915 |
| population | Monthly | 21 / 96 | 21.9% | 21 | 0.380 | 0.297 |
| population | National | 0 / 96 | 0.0% | 0 | — | — |
| population | National+incumbent_annual | 27 / 96 | 28.1% | 27 | 0.785 | 0.785 |
| population | National+incumbent_monthly | 2 / 96 | 2.1% | 2 | 0.914 | 0.914 |
| population | Annual_Lag | 41 / 96 | 42.7% | 41 | 0.454 | 0.436 |
| population | Annual_Monthly_Lag | 48 / 96 | 50.0% | 48 | 0.479 | 0.458 |
| population | Geographic+a_lag1 | 0 / 96 | 0.0% | 0 | — | — |
| population | Geographic+incumbent_annual+lag | 35 / 96 | 36.5% | 33 | 0.792 | 0.794 |
| population | Geographic+incumbent_monthly+lag | 3 / 96 | 3.1% | 3 | 0.910 | 0.928 |
| population | Lag | 5 / 48 | 10.4% | 5 | 0.626 | 0.572 |
| population | Monthly_Lag | 24 / 96 | 25.0% | 24 | 0.445 | 0.407 |
| population | National+a_lag1 | 0 / 96 | 0.0% | 0 | — | — |
| population | National+incumbent_annual+lag | 29 / 96 | 30.2% | 28 | 0.810 | 0.809 |
| population | National+incumbent_monthly+lag | 1 / 96 | 1.0% | 1 | 0.867 | 0.867 |
| sales | Annual | 63 / 96 | 65.6% | 55 | 0.748 | 0.813 |
| sales | Annual_Monthly | 64 / 96 | 66.7% | 56 | 0.750 | 0.816 |
| sales | Geographic | 0 / 96 | 0.0% | 0 | — | — |
| sales | Geographic+incumbent_annual | 64 / 96 | 66.7% | 19 | 0.772 | 0.798 |
| sales | Geographic+incumbent_monthly | 29 / 96 | 30.2% | 8 | 0.844 | 0.855 |
| sales | Monthly | 52 / 96 | 54.2% | 44 | 0.769 | 0.844 |
| sales | National | 0 / 96 | 0.0% | 0 | — | — |
| sales | National+incumbent_annual | 64 / 96 | 66.7% | 16 | 0.792 | 0.839 |
| sales | National+incumbent_monthly | 24 / 96 | 25.0% | 8 | 0.859 | 0.883 |
| sales | Annual_Lag | 63 / 96 | 65.6% | 43 | 0.780 | 0.838 |
| sales | Annual_Monthly_Lag | 65 / 96 | 67.7% | 50 | 0.769 | 0.839 |
| sales | Geographic+a_lag1 | 0 / 96 | 0.0% | 0 | — | — |
| sales | Geographic+incumbent_annual+lag | 63 / 96 | 65.6% | 15 | 0.770 | 0.799 |
| sales | Geographic+incumbent_monthly+lag | 27 / 96 | 28.1% | 6 | 0.819 | 0.830 |
| sales | Lag | 1 / 48 | 2.1% | 1 | 0.076 | 0.076 |
| sales | Monthly_Lag | 45 / 96 | 46.9% | 33 | 0.785 | 0.859 |
| sales | National+a_lag1 | 0 / 96 | 0.0% | 0 | — | — |
| sales | National+incumbent_annual+lag | 59 / 96 | 61.5% | 14 | 0.774 | 0.814 |
| sales | National+incumbent_monthly+lag | 24 / 96 | 25.0% | 6 | 0.839 | 0.865 |

## controls

| tax_weights | controls | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|
| population | B | 64 / 444 | 14.4% | 64 | 0.575 | 0.544 |
| population | SV | 123 / 444 | 27.7% | 123 | 0.585 | 0.618 |
| population | S | 80 / 444 | 18.0% | 80 | 0.554 | 0.635 |
| population | V | 90 / 444 | 20.3% | 87 | 0.572 | 0.619 |
| sales | B | 152 / 444 | 34.2% | 92 | 0.809 | 0.863 |
| sales | SV | 203 / 444 | 45.7% | 97 | 0.762 | 0.806 |
| sales | S | 160 / 444 | 36.0% | 104 | 0.788 | 0.847 |
| sales | V | 192 / 444 | 43.2% | 81 | 0.769 | 0.828 |

## market

| tax_weights | market | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|
| population | annual | 118 / 592 | 19.9% | 117 | 0.485 | 0.431 |
| population | constant | 106 / 592 | 17.9% | 106 | 0.668 | 0.683 |
| population | monthly | 133 / 592 | 22.5% | 131 | 0.575 | 0.524 |
| sales | annual | 231 / 592 | 39.0% | 105 | 0.807 | 0.832 |
| sales | constant | 171 / 592 | 28.9% | 171 | 0.682 | 0.805 |
| sales | monthly | 305 / 592 | 51.5% | 98 | 0.814 | 0.839 |

## lag

| tax_weights | lag_quality | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|
| population | FALSE | 171 / 864 | 19.8% | 171 | 0.551 | 0.587 |
| population | TRUE | 186 / 912 | 20.4% | 183 | 0.593 | 0.628 |
| sales | FALSE | 360 / 864 | 41.7% | 206 | 0.779 | 0.821 |
| sales | TRUE | 347 / 912 | 38.0% | 168 | 0.781 | 0.838 |

## price_FE_instrument

| tax_weights | price_measure | firm_FE | instrument_set | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|---|---|
| population | p_it | TRUE | Annual | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Annual_Monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Geographic+incumbent_annual | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Geographic+incumbent_monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | National | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | National+incumbent_annual | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | National+incumbent_monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | Annual | 12 / 24 | 50.0% | 12 | 0.148 | 0.149 |
| population | p_it_volume_weighted | TRUE | Annual_Monthly | 18 / 24 | 75.0% | 18 | 0.201 | 0.223 |
| population | p_it_volume_weighted | TRUE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | Geographic+incumbent_annual | 5 / 24 | 20.8% | 5 | 0.732 | 0.710 |
| population | p_it_volume_weighted | TRUE | Geographic+incumbent_monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | Monthly | 2 / 24 | 8.3% | 2 | 0.105 | 0.105 |
| population | p_it_volume_weighted | TRUE | National | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | National+incumbent_annual | 4 / 24 | 16.7% | 4 | 0.739 | 0.744 |
| population | p_it_volume_weighted | TRUE | National+incumbent_monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | Annual | 4 / 24 | 16.7% | 4 | 0.944 | 0.944 |
| population | p_it | FALSE | Annual_Monthly | 4 / 24 | 16.7% | 4 | 0.943 | 0.943 |
| population | p_it | FALSE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | Geographic+incumbent_annual | 2 / 24 | 8.3% | 2 | 0.988 | 0.988 |
| population | p_it | FALSE | Geographic+incumbent_monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | Monthly | 4 / 24 | 16.7% | 4 | 0.902 | 0.896 |
| population | p_it | FALSE | National | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | National+incumbent_annual | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | National+incumbent_monthly | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | Annual | 24 / 24 | 100.0% | 24 | 0.463 | 0.426 |
| population | p_it_volume_weighted | FALSE | Annual_Monthly | 24 / 24 | 100.0% | 24 | 0.505 | 0.483 |
| population | p_it_volume_weighted | FALSE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | Geographic+incumbent_annual | 24 / 24 | 100.0% | 24 | 0.745 | 0.740 |
| population | p_it_volume_weighted | FALSE | Geographic+incumbent_monthly | 4 / 24 | 16.7% | 4 | 0.900 | 0.915 |
| population | p_it_volume_weighted | FALSE | Monthly | 15 / 24 | 62.5% | 15 | 0.277 | 0.200 |
| population | p_it_volume_weighted | FALSE | National | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | National+incumbent_annual | 23 / 24 | 95.8% | 23 | 0.793 | 0.791 |
| population | p_it_volume_weighted | FALSE | National+incumbent_monthly | 2 / 24 | 8.3% | 2 | 0.914 | 0.914 |
| population | p_it | TRUE | Annual_Lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Annual_Monthly_Lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Geographic+incumbent_annual+lag | 2 / 24 | 8.3% | 0 | 0.971 | 0.971 |
| population | p_it | TRUE | Geographic+incumbent_monthly+lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | Lag | 4 / 12 | 33.3% | 4 | 0.616 | 0.556 |
| population | p_it | TRUE | Monthly_Lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | TRUE | National+incumbent_annual+lag | 1 / 24 | 4.2% | 0 | 0.974 | 0.974 |
| population | p_it | TRUE | National+incumbent_monthly+lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | Annual_Lag | 12 / 24 | 50.0% | 12 | 0.154 | 0.158 |
| population | p_it_volume_weighted | TRUE | Annual_Monthly_Lag | 18 / 24 | 75.0% | 18 | 0.239 | 0.236 |
| population | p_it_volume_weighted | TRUE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | Geographic+incumbent_annual+lag | 6 / 24 | 25.0% | 6 | 0.755 | 0.659 |
| population | p_it_volume_weighted | TRUE | Geographic+incumbent_monthly+lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | Lag | 1 / 12 | 8.3% | 1 | 0.665 | 0.665 |
| population | p_it_volume_weighted | TRUE | Monthly_Lag | 1 / 24 | 4.2% | 1 | 0.069 | 0.069 |
| population | p_it_volume_weighted | TRUE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | National+incumbent_annual+lag | 4 / 24 | 16.7% | 4 | 0.714 | 0.707 |
| population | p_it_volume_weighted | TRUE | National+incumbent_monthly+lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | Annual_Lag | 5 / 24 | 20.8% | 5 | 0.955 | 0.971 |
| population | p_it | FALSE | Annual_Monthly_Lag | 6 / 24 | 25.0% | 6 | 0.961 | 0.975 |
| population | p_it | FALSE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | Geographic+incumbent_annual+lag | 4 / 24 | 16.7% | 4 | 0.953 | 0.953 |
| population | p_it | FALSE | Geographic+incumbent_monthly+lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | Lag | 0 / 12 | 0.0% | 0 | — | — |
| population | p_it | FALSE | Monthly_Lag | 4 / 24 | 16.7% | 4 | 0.923 | 0.948 |
| population | p_it | FALSE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it | FALSE | National+incumbent_annual+lag | 2 / 24 | 8.3% | 2 | 0.998 | 0.998 |
| population | p_it | FALSE | National+incumbent_monthly+lag | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | Annual_Lag | 24 / 24 | 100.0% | 24 | 0.500 | 0.472 |
| population | p_it_volume_weighted | FALSE | Annual_Monthly_Lag | 24 / 24 | 100.0% | 24 | 0.539 | 0.517 |
| population | p_it_volume_weighted | FALSE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | Geographic+incumbent_annual+lag | 23 / 24 | 95.8% | 23 | 0.758 | 0.753 |
| population | p_it_volume_weighted | FALSE | Geographic+incumbent_monthly+lag | 3 / 24 | 12.5% | 3 | 0.910 | 0.928 |
| population | p_it_volume_weighted | FALSE | Lag | 0 / 12 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | Monthly_Lag | 19 / 24 | 79.2% | 19 | 0.364 | 0.374 |
| population | p_it_volume_weighted | FALSE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | National+incumbent_annual+lag | 22 / 24 | 91.7% | 22 | 0.803 | 0.812 |
| population | p_it_volume_weighted | FALSE | National+incumbent_monthly+lag | 1 / 24 | 4.2% | 1 | 0.867 | 0.867 |
| sales | p_it | TRUE | Annual | 8 / 24 | 33.3% | 8 | 0.935 | 0.933 |
| sales | p_it | TRUE | Annual_Monthly | 8 / 24 | 33.3% | 8 | 0.935 | 0.928 |
| sales | p_it | TRUE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | TRUE | Geographic+incumbent_annual | 16 / 24 | 66.7% | 0 | 0.700 | 0.694 |
| sales | p_it | TRUE | Geographic+incumbent_monthly | 10 / 24 | 41.7% | 0 | 0.837 | 0.803 |
| sales | p_it | TRUE | Monthly | 8 / 24 | 33.3% | 8 | 0.936 | 0.931 |
| sales | p_it | TRUE | National | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | TRUE | National+incumbent_annual | 16 / 24 | 66.7% | 0 | 0.708 | 0.701 |
| sales | p_it | TRUE | National+incumbent_monthly | 8 / 24 | 33.3% | 0 | 0.835 | 0.828 |
| sales | p_it_volume_weighted | TRUE | Annual | 23 / 24 | 95.8% | 23 | 0.588 | 0.728 |
| sales | p_it_volume_weighted | TRUE | Annual_Monthly | 24 / 24 | 100.0% | 24 | 0.592 | 0.718 |
| sales | p_it_volume_weighted | TRUE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | TRUE | Geographic+incumbent_annual | 8 / 24 | 33.3% | 8 | 0.664 | 0.672 |
| sales | p_it_volume_weighted | TRUE | Geographic+incumbent_monthly | 4 / 24 | 16.7% | 4 | 0.814 | 0.820 |
| sales | p_it_volume_weighted | TRUE | Monthly | 17 / 24 | 70.8% | 17 | 0.623 | 0.619 |
| sales | p_it_volume_weighted | TRUE | National | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | TRUE | National+incumbent_annual | 8 / 24 | 33.3% | 8 | 0.720 | 0.719 |
| sales | p_it_volume_weighted | TRUE | National+incumbent_monthly | 4 / 24 | 16.7% | 4 | 0.879 | 0.886 |
| sales | p_it | FALSE | Annual | 8 / 24 | 33.3% | 4 | 0.802 | 0.800 |
| sales | p_it | FALSE | Annual_Monthly | 8 / 24 | 33.3% | 4 | 0.811 | 0.808 |
| sales | p_it | FALSE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | FALSE | Geographic+incumbent_annual | 16 / 24 | 66.7% | 0 | 0.719 | 0.722 |
| sales | p_it | FALSE | Geographic+incumbent_monthly | 11 / 24 | 45.8% | 0 | 0.849 | 0.917 |
| sales | p_it | FALSE | Monthly | 6 / 24 | 25.0% | 2 | 0.875 | 0.855 |
| sales | p_it | FALSE | National | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | FALSE | National+incumbent_annual | 16 / 24 | 66.7% | 0 | 0.733 | 0.736 |
| sales | p_it | FALSE | National+incumbent_monthly | 8 / 24 | 33.3% | 0 | 0.838 | 0.844 |
| sales | p_it_volume_weighted | FALSE | Annual | 24 / 24 | 100.0% | 20 | 0.822 | 0.834 |
| sales | p_it_volume_weighted | FALSE | Annual_Monthly | 24 / 24 | 100.0% | 20 | 0.826 | 0.828 |
| sales | p_it_volume_weighted | FALSE | Geographic | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | FALSE | Geographic+incumbent_annual | 24 / 24 | 100.0% | 11 | 0.892 | 0.900 |
| sales | p_it_volume_weighted | FALSE | Geographic+incumbent_monthly | 4 / 24 | 16.7% | 4 | 0.880 | 0.881 |
| sales | p_it_volume_weighted | FALSE | Monthly | 21 / 24 | 87.5% | 17 | 0.793 | 0.843 |
| sales | p_it_volume_weighted | FALSE | National | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | FALSE | National+incumbent_annual | 24 / 24 | 100.0% | 8 | 0.912 | 0.921 |
| sales | p_it_volume_weighted | FALSE | National+incumbent_monthly | 4 / 24 | 16.7% | 4 | 0.930 | 0.936 |
| sales | p_it | TRUE | Annual_Lag | 9 / 24 | 37.5% | 6 | 0.914 | 0.950 |
| sales | p_it | TRUE | Annual_Monthly_Lag | 9 / 24 | 37.5% | 6 | 0.910 | 0.949 |
| sales | p_it | TRUE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | TRUE | Geographic+incumbent_annual+lag | 16 / 24 | 66.7% | 0 | 0.656 | 0.671 |
| sales | p_it | TRUE | Geographic+incumbent_monthly+lag | 12 / 24 | 50.0% | 0 | 0.793 | 0.825 |
| sales | p_it | TRUE | Lag | 1 / 12 | 8.3% | 1 | 0.076 | 0.076 |
| sales | p_it | TRUE | Monthly_Lag | 7 / 24 | 29.2% | 5 | 0.913 | 0.923 |
| sales | p_it | TRUE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | TRUE | National+incumbent_annual+lag | 16 / 24 | 66.7% | 0 | 0.661 | 0.674 |
| sales | p_it | TRUE | National+incumbent_monthly+lag | 12 / 24 | 50.0% | 0 | 0.827 | 0.847 |
| sales | p_it_volume_weighted | TRUE | Annual_Lag | 22 / 24 | 91.7% | 19 | 0.619 | 0.739 |
| sales | p_it_volume_weighted | TRUE | Annual_Monthly_Lag | 24 / 24 | 100.0% | 22 | 0.601 | 0.723 |
| sales | p_it_volume_weighted | TRUE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | TRUE | Geographic+incumbent_annual+lag | 8 / 24 | 33.3% | 8 | 0.659 | 0.661 |
| sales | p_it_volume_weighted | TRUE | Geographic+incumbent_monthly+lag | 4 / 24 | 16.7% | 4 | 0.814 | 0.815 |
| sales | p_it_volume_weighted | TRUE | Lag | 0 / 12 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | TRUE | Monthly_Lag | 16 / 24 | 66.7% | 14 | 0.601 | 0.628 |
| sales | p_it_volume_weighted | TRUE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | TRUE | National+incumbent_annual+lag | 8 / 24 | 33.3% | 8 | 0.717 | 0.718 |
| sales | p_it_volume_weighted | TRUE | National+incumbent_monthly+lag | 4 / 24 | 16.7% | 4 | 0.879 | 0.879 |
| sales | p_it | FALSE | Annual_Lag | 8 / 24 | 33.3% | 2 | 0.804 | 0.803 |
| sales | p_it | FALSE | Annual_Monthly_Lag | 8 / 24 | 33.3% | 2 | 0.815 | 0.818 |
| sales | p_it | FALSE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | FALSE | Geographic+incumbent_annual+lag | 16 / 24 | 66.7% | 0 | 0.722 | 0.736 |
| sales | p_it | FALSE | Geographic+incumbent_monthly+lag | 9 / 24 | 37.5% | 0 | 0.842 | 0.859 |
| sales | p_it | FALSE | Lag | 0 / 12 | 0.0% | 0 | — | — |
| sales | p_it | FALSE | Monthly_Lag | 6 / 24 | 25.0% | 2 | 0.912 | 0.941 |
| sales | p_it | FALSE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it | FALSE | National+incumbent_annual+lag | 16 / 24 | 66.7% | 0 | 0.735 | 0.751 |
| sales | p_it | FALSE | National+incumbent_monthly+lag | 6 / 24 | 25.0% | 0 | 0.807 | 0.824 |
| sales | p_it_volume_weighted | FALSE | Annual_Lag | 24 / 24 | 100.0% | 16 | 0.869 | 0.870 |
| sales | p_it_volume_weighted | FALSE | Annual_Monthly_Lag | 24 / 24 | 100.0% | 20 | 0.868 | 0.867 |
| sales | p_it_volume_weighted | FALSE | Geographic+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | FALSE | Geographic+incumbent_annual+lag | 23 / 24 | 95.8% | 7 | 0.923 | 0.930 |
| sales | p_it_volume_weighted | FALSE | Geographic+incumbent_monthly+lag | 2 / 24 | 8.3% | 2 | 0.886 | 0.886 |
| sales | p_it_volume_weighted | FALSE | Lag | 0 / 12 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | FALSE | Monthly_Lag | 16 / 24 | 66.7% | 12 | 0.866 | 0.891 |
| sales | p_it_volume_weighted | FALSE | National+a_lag1 | 0 / 24 | 0.0% | 0 | — | — |
| sales | p_it_volume_weighted | FALSE | National+incumbent_annual+lag | 19 / 24 | 79.2% | 6 | 0.927 | 0.931 |
| sales | p_it_volume_weighted | FALSE | National+incumbent_monthly+lag | 2 / 24 | 8.3% | 2 | 0.928 | 0.928 |

## price_FE_controls

| tax_weights | price_measure | firm_FE | controls | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|---|---|
| population | p_it | TRUE | B | 2 / 111 | 1.8% | 2 | 0.510 | 0.510 |
| population | p_it_volume_weighted | TRUE | B | 8 / 111 | 7.2% | 8 | 0.132 | 0.117 |
| population | p_it | FALSE | B | 0 / 111 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | FALSE | B | 54 / 111 | 48.6% | 54 | 0.643 | 0.650 |
| population | p_it | TRUE | SV | 2 / 111 | 1.8% | 2 | 0.722 | 0.722 |
| population | p_it_volume_weighted | TRUE | SV | 28 / 111 | 25.2% | 28 | 0.357 | 0.285 |
| population | p_it | FALSE | SV | 25 / 111 | 22.5% | 25 | 0.939 | 0.945 |
| population | p_it_volume_weighted | FALSE | SV | 68 / 111 | 61.3% | 68 | 0.544 | 0.583 |
| population | p_it | TRUE | S | 0 / 111 | 0.0% | 0 | — | — |
| population | p_it_volume_weighted | TRUE | S | 26 / 111 | 23.4% | 26 | 0.365 | 0.301 |
| population | p_it | FALSE | S | 3 / 111 | 2.7% | 3 | 0.954 | 0.950 |
| population | p_it_volume_weighted | FALSE | S | 51 / 111 | 45.9% | 51 | 0.626 | 0.668 |
| population | p_it | TRUE | V | 3 / 111 | 2.7% | 0 | 0.972 | 0.974 |
| population | p_it_volume_weighted | TRUE | V | 21 / 111 | 18.9% | 21 | 0.282 | 0.159 |
| population | p_it | FALSE | V | 7 / 111 | 6.3% | 7 | 0.976 | 0.978 |
| population | p_it_volume_weighted | FALSE | V | 59 / 111 | 53.2% | 59 | 0.607 | 0.623 |
| sales | p_it | TRUE | B | 34 / 111 | 30.6% | 8 | 0.825 | 0.768 |
| sales | p_it_volume_weighted | TRUE | B | 42 / 111 | 37.8% | 42 | 0.618 | 0.743 |
| sales | p_it | FALSE | B | 22 / 111 | 19.8% | 2 | 0.912 | 0.902 |
| sales | p_it_volume_weighted | FALSE | B | 54 / 111 | 48.6% | 40 | 0.905 | 0.904 |
| sales | p_it | TRUE | SV | 45 / 111 | 40.5% | 15 | 0.764 | 0.804 |
| sales | p_it_volume_weighted | TRUE | SV | 46 / 111 | 41.4% | 43 | 0.673 | 0.762 |
| sales | p_it | FALSE | SV | 49 / 111 | 44.1% | 6 | 0.742 | 0.777 |
| sales | p_it_volume_weighted | FALSE | SV | 63 / 111 | 56.8% | 33 | 0.841 | 0.849 |
| sales | p_it | TRUE | S | 30 / 111 | 27.0% | 4 | 0.811 | 0.798 |
| sales | p_it_volume_weighted | TRUE | S | 46 / 111 | 41.4% | 46 | 0.620 | 0.665 |
| sales | p_it | FALSE | S | 20 / 111 | 18.0% | 2 | 0.899 | 0.890 |
| sales | p_it_volume_weighted | FALSE | S | 64 / 111 | 57.7% | 52 | 0.863 | 0.877 |
| sales | p_it | TRUE | V | 47 / 111 | 42.3% | 15 | 0.780 | 0.809 |
| sales | p_it_volume_weighted | TRUE | V | 40 / 111 | 36.0% | 36 | 0.653 | 0.799 |
| sales | p_it | FALSE | V | 51 / 111 | 45.9% | 6 | 0.729 | 0.769 |
| sales | p_it_volume_weighted | FALSE | V | 54 / 111 | 48.6% | 24 | 0.884 | 0.883 |

## quality_price_FE

| tax_weights | quality | price_measure | firm_FE | Qualifying / total | Percent | Also negative alpha | Mean sigma | Median sigma |
|---|---|---|---|---|---|---|---|---|
| population | Exogenous | p_it | TRUE | 4 / 336 | 1.2% | 4 | 0.616 | 0.556 |
| population | Exogenous | p_it_volume_weighted | TRUE | 65 / 336 | 19.3% | 65 | 0.311 | 0.234 |
| population | Exogenous | p_it | FALSE | 19 / 336 | 5.7% | 19 | 0.948 | 0.948 |
| population | Exogenous | p_it_volume_weighted | FALSE | 172 / 336 | 51.2% | 172 | 0.608 | 0.631 |
| population | Endogenous | p_it | TRUE | 3 / 108 | 2.8% | 0 | 0.972 | 0.974 |
| population | Endogenous | p_it_volume_weighted | TRUE | 18 / 108 | 16.7% | 18 | 0.347 | 0.243 |
| population | Endogenous | p_it | FALSE | 16 / 108 | 14.8% | 16 | 0.948 | 0.956 |
| population | Endogenous | p_it_volume_weighted | FALSE | 60 / 108 | 55.6% | 60 | 0.583 | 0.617 |
| sales | Exogenous | p_it | TRUE | 108 / 336 | 32.1% | 34 | 0.814 | 0.798 |
| sales | Exogenous | p_it_volume_weighted | TRUE | 132 / 336 | 39.3% | 132 | 0.631 | 0.728 |
| sales | Exogenous | p_it | FALSE | 104 / 336 | 31.0% | 14 | 0.793 | 0.834 |
| sales | Exogenous | p_it_volume_weighted | FALSE | 173 / 336 | 51.5% | 111 | 0.870 | 0.878 |
| sales | Endogenous | p_it | TRUE | 48 / 108 | 44.4% | 8 | 0.740 | 0.773 |
| sales | Endogenous | p_it_volume_weighted | TRUE | 42 / 108 | 38.9% | 35 | 0.674 | 0.775 |
| sales | Endogenous | p_it | FALSE | 38 / 108 | 35.2% | 2 | 0.765 | 0.786 |
| sales | Endogenous | p_it_volume_weighted | FALSE | 62 / 108 | 57.4% | 38 | 0.876 | 0.883 |

