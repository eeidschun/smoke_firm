# total mL of eliquid consumed per month, at the national level
# used to define M_t 
rm(list = ls())

# this is from demand side, not in github repo
load("input/NCP/cps_2013-2023.RData")

cps_ec = cps_yr_all %>% filter(ec) %>% select(household_code, wt, year_month, liq_total_f)
cps_ec = cps_ec %>% filter(!is.na(liq_total_f))

M_t = cps_ec %>% group_by(year_month) %>% summarise(simple_avg_mL = mean(liq_total_f),
                                              hh_wt_avg_mL = weighted.mean(liq_total_f, wt)) %>% ungroup()

M_t_long = M_t %>% pivot_longer(cols = c(simple_avg_mL, hh_wt_avg_mL))

library(dplyr)
library(ggplot2)

M_t_long <- M_t_long %>%
  mutate(date = as.Date(paste0(year_month, "-01")))

ggplot(M_t_long, aes(x = date, y = value, color = name)) +
  geom_line() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")

save(M_t_long, file = "smoke_firm/smoke_firm_dir/input/avg_mL_by_hh_in_ncp.RData")
