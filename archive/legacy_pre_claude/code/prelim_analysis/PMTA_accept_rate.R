library(tidyverse)
setwd("/projectnb/econdept/eidschun/pr/smoke_firm")
# Path to your PDF
# raw file from here: https://www.fda.gov/tobacco-products/market-and-distribute-tobacco-product/tobacco-product-applications-metrics-reporting#Glossary
pdf_file <- "raw/fda/acceptance_rates/PMTA-Metrics-March-2025.pdf"

# total number of apps 
total_apps = 8015786 + 17362570+  1219257+  14168+  3127+  22825
total_accepted = 1456+ 6635824 +56715 +72006+ 73214 +11188
pct_accepted_phase1 = total_accepted / total_apps
total_filed = 732 + 1018466 + 54608 + 115762 + 64827 + 21
pct_filed_phase2 = total_filed / total_accepted

total_mdos = 0 + 1201817  + 30079  + 6869 + 62848 + 16733
pct_mdo = total_mdos / total_apps
total_mgos = 23 + 11
pct_mgo = total_mgos / total_apps
total_withdrawn_or_closed = 561+1820+12+33+156+80143+144+391
pct_w_or_c = total_withdrawn_or_closed / total_apps

pmta_rate = data.frame(description = c("Passing Phase 1", "Passing Phase 2 from Phase 1",
                           "Denied / Apps", "Authorized / Apps", "Withdrawn / Apps"),
           percent = c(pct_accepted_phase1, pct_filed_phase2, 
                       pct_mdo, pct_mgo, pct_w_or_c))
pmta_rate$percent = 100 * pmta_rate$percent
pmta_rate

library(xtable)
xtable(pmta_rate)
# impossible to read in so just going manually
raw = data.frame(metric = c(rep("Accepted", 6), rep("RTA", 6), rep("Total Received", 6)),
                 start = c("2019-10-01", "2020-10-01", "2021-10-01", "2022-10-01", "2023-10-01", "2024-10-01"),
                 end = c("2020-09-01", "2021-09-01", "2022-09-01", "2023-09-01", "2024-09-01", "2025-03-01"),
                 value = c(1456,6635824,56715,72006,73214,3038,
                           150,1311386,970238, 17276120,24022,1694,
                           8015786, 17362570,1219257,14168,3127,22054))
df = raw %>%
  arrange(start) 

# Compute cumulative sums per metric
df_cum <- df %>%
  group_by(metric) %>%
  mutate(cum_value = cumsum(value)) %>%
  ungroup()

# Compute rolling No_Status_Yet
# For each period, No_Status_Yet = cumulative total received - cumulative accepted - cumulative RTA


df_wide <- df_cum %>%
  select(start, end, metric, cum_value) %>%
  pivot_wider(names_from = metric, values_from = cum_value)

df_wide <- df_wide %>%
  arrange(start) %>%
  mutate(
    No_Status_Yet = Reduce(
      f = function(prev, cur) prev + cur,
      x = `Total Received` - Accepted - RTA,
      init = 0,
      accumulate = TRUE
    )[-1]  # Remove initial zero from Reduce
  )
# If you want back in long format (like original)
# accept_rta_rec_nsy_val is cumulative sum
accept_final <- df_wide %>%
  pivot_longer(cols = c(Accepted, RTA, `Total Received`, No_Status_Yet),
               names_to = "metric", values_to = "accept_rta_rec_nsy_val")
#### 2. file vs. RTF
raw = data.frame(metric = c(rep("Filed", 6), rep("RTF", 6)),
                 start = c("2019-10-01", "2020-10-01", "2021-10-01", "2022-10-01", "2023-10-01", "2024-10-01"),
                 end = c("2020-09-01", "2021-09-01", "2022-09-01", "2023-09-01", "2024-09-01", "2025-03-01"),
                 value = c(732,1018466,54608, 115762, 64827, 21,
                           156,5089664,20298,51475,6088,11))
df = raw %>% group_by(start) %>% mutate(sum_file_rtf = sum(value)) %>% ungroup()
df = df %>% left_join(accept_final %>% filter(metric == "Accepted") %>% select(-metric), by = c("start", "end"))

# check that sum of filed and rtf <= # cum sum of accepted from first file
df = df %>% mutate(check = sum_file_rtf < accept_rta_rec_nsy_val)

if(any(df$check) == F){
  stop('error')
} else{
  df$check  = NULL
}

# calculate number undecided on
df = df %>% group_by(start) %>% mutate(undecided_file = accept_rta_rec_nsy_val - sum_file_rtf)

accept_and_file_final = df

## File 3: deficiency letters
def_raw = data.frame(
                     start = c("2019-10-01", "2020-10-01", "2021-10-01", "2022-10-01", "2023-10-01", "2024-10-01"),
                     end = c("2020-09-01", "2021-09-01", "2022-09-01", "2023-09-01", "2024-09-01", "2025-03-01"),
                     def = c(40,1001,0,70,15,0))

accept_and_file_final_minus_def = accept_and_file_final %>% left_join(def_raw, by = c("start", "end"))
accept_and_file_final_minus_def = accept_and_file_final_minus_def %>% mutate(metric = ifelse(metric == "Filed", "Filed_minus_def", metric))
accept_and_file_final_minus_def = accept_and_file_final_minus_def %>% mutate(value = ifelse(metric == "Filed_minus_def", value - def, value)) %>% select(-def)

## File 4: MGO/MDO/Withdrawn/closure
raw = data.frame(metric = c(rep("MGO", 6), rep("MDO", 6), rep("Withdrawn", 6), rep("Closure", 6)),
                 start = c("2019-10-01", "2020-10-01", "2021-10-01", "2022-10-01", "2023-10-01", "2024-10-01"),
                 end = c("2020-09-01", "2021-09-01", "2022-09-01", "2023-09-01", "2024-09-01", "2025-03-01"),
                 value = c(0,0,23,0,11,0,
                           0,1201817,30079,6869,62848,3704,
                           0,561,1820,12,33,150,
                           0,80143,144,391,0,0))
df = raw %>% mutate(metric2 = ifelse(metric %in% c("MGO", "MDO"), metric, "Withdrawn_Closure"))
df = df %>% group_by(metric2, start, end) %>% summarise(value=  sum(value)) %>% ungroup()
df = df %>% group_by(start, end) %>% mutate(sum_mgo_mdo_w_c  = sum(value)) %>% ungroup()

filed_final_cum = accept_and_file_final_minus_def %>% filter(metric =="Filed_minus_def") %>% ungroup() %>% 
  arrange(start) %>% mutate(cum_filed_minus_def = cumsum(value)) %>% ungroup() %>% select(-c(metric, value:undecided_file))
df = df %>% left_join(filed_final_cum, by = c("start", "end")) %>% arrange(start, metric2)

# since sum_mgo_mdo_w_c < cum_filed_minus_def sometimes, that's werid Emailing FDA now
df$check = df$cum_filed - df$sum_mgo_mdo_w_c
