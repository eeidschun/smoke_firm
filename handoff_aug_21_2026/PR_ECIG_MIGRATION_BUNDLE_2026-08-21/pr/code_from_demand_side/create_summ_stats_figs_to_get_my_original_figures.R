if(T){

library(viridis)
library(ggplot2)
library(tidyverse)
library(gridExtra)


mydir =  "/projectnb/econdept/eidschun/pr/smoke_demand"

setwd(mydir)
cpi_data = get(load(paste0("input/Misc/cpi_mult_peg_to_", infl_peg,"_yr.RData")))

rms_c = get(load(paste0("input/RMS/3_state/state_cig.RData")))
rms_ec = get(load(paste0("input/RMS/3_state/state_ec.RData")))

rms_c = rms_c %>% filter(as.numeric(year) <= 2023)
rms_ec = rms_ec %>% filter(as.numeric(year) <= 2023)

  get_x_breaks <- function(df, num_ticks){
    x_breaks <- c(as.Date(paste0(
      unique(df$year_month)[seq(1, length(unique(df$year_month)), by = num_ticks)],
      "-01")), max(as.Date(paste0(df$year_month, "-01"))))
  }
}



#****************************** FIGURE 0: PRICE AND NIC OF PACK + ECIG (PER STATE)*********************
if(F){
  # check price of a pack (20 cigs) graphically
  p_c_n_check = rms_c %>% select(year, year_month, price_per_ct_real,nic_per_ct, store_state_descr) %>% 
    mutate(store_state_descr = as.factor(store_state_descr), price_per_ct_real = 20* price_per_ct_real) %>% 
    rename(pr_per_ct_c_real = price_per_ct_real,
           nic_per_ct_c = nic_per_ct)
  p_c_n_check$date = as.Date(paste0(p_c_n_check$year_month, "-01"))
  
  # check price of a single EC
  p_ec_n_check = rms_ec %>% select(year, year_month, price_per_ct_real,nic_per_ct, store_state_descr) %>% 
    mutate(store_state_descr = as.factor(store_state_descr)) %>% 
    rename(pr_per_ct_ec_real = price_per_ct_real,
           nic_per_ct_ec = nic_per_ct)
  p_ec_n_check$date = as.Date(paste0(p_ec_n_check$year_month, "-01"))
  
  x_breaks <- get_x_breaks(p_ec_n_check, num_ticks = 12)
  
  p_check = p_c_n_check %>% left_join(p_ec_n_check, by = c("date", "year", "year_month", "store_state_descr"))
  
  #Scale factor
  scalefactor <- max(p_check$pr_per_ct_ec_real)/max(20*p_check$pr_per_ct_c_real)
  #Plot
  # NA warning because missing for DC and DE in 2020
  ggplot(p_check, aes(x = date, y = pr_per_ct_ec_real, color = store_state_descr)) +
    geom_line()
  ggplot(p_check, aes(x = date, y = pr_per_ct_c_real, color = store_state_descr)) +
    geom_line()
  
  ggplot(p_check, aes(x = date, y = 20*nic_per_ct_c, color = store_state_descr)) +
    geom_line() + labs(title = "cigarette strength in pack")
  ggplot(p_check, aes(x = date, y = nic_per_ct_ec,  color = store_state_descr)) +
    geom_line() + labs(title = "e-cig strength")
}

#****************************** FIGURE 1: PRICE OF PACK + ECIG (AGG ACROSS STATES_ *********************
if(T){
# check price of a pack graphically
p_c_check = rms_c %>% group_by(year, year_month) %>% 
  summarise(pr_per_ct_c_real = weighted.mean(price_per_ct_avg_real, 
                                             w = unit_sales)) %>% ungroup()
p_c_check$date = as.Date(paste0(p_c_check$year_month, "-01"))

# check price of an ec graphically
p_ec_check = rms_ec %>% group_by(year, year_month) %>%
  summarise(pr_per_hom_ct_ec_real = weighted.mean(price_per_hom_ct_real, 
                                              w = mL_sales),
            pr_per_mL_ec_real = weighted.mean(price_per_mL_avg_real,
                                              w = mL_sales)) %>% ungroup()

p_ec_check$date = as.Date(paste0(p_ec_check$year_month, "-01"))

x_breaks <- get_x_breaks(p_ec_check, num_ticks = 12)


p_check = p_c_check %>% left_join(p_ec_check, by = c("date", "year", "year_month"))

# put them into same column and convert into a pack
p_check = p_check %>% mutate(pr_per_pack_c_real = 20 * pr_per_ct_c_real) %>% select(-pr_per_ct_c_real) %>%
  pivot_longer(c(pr_per_pack_c_real, pr_per_hom_ct_ec_real, pr_per_mL_ec_real),
                                   names_to = "type", values_to = "price")
p_check = p_check %>% mutate(type = ifelse(type == "pr_per_pack_c_real", "Cigarette Pack",
                                           ifelse(type == "pr_per_hom_ct_ec_real", "One E-cigarette", "One mL of E-liquid")))

p = ggplot(p_check %>% filter(type %in% c("Cigarette Pack", "One E-cigarette")), aes(x = date))+
  geom_line(aes(y = price, color = factor(type))) +
  theme(legend.position = "bottom", legend.title = element_blank())  + 
  labs(x = "", y = "Price ($)") +
  scale_color_manual(values = c('One E-cigarette' = '#5ec962', 'Cigarette Pack' = '#3b528b')) +
  theme(legend.text=element_text(size=16),
        axis.title.y=element_text(size=14),
        axis.text.x = element_text(size = 14, hjust = 1, angle = 45),
        axis.text.y = element_text(size = 14))

p_mL_ec = ggplot(p_check %>% filter(type %in% c("One mL of E-liquid", "One E-cigarette")), aes(x = date))+
  geom_line(aes(y = price, color = factor(type))) +
  theme(legend.position = "bottom", legend.title = element_blank())  + 
  labs(x = "", y = "Price ($)") +
  scale_color_manual(values = c('One E-cigarette' = '#5ec962', 'One mL of E-liquid' = '#480882')) +
  theme(legend.text=element_text(size=16),
        axis.title.y=element_text(size=14),
        axis.text.x = element_text(size = 14, hjust = 1, angle = 45),
        axis.text.y = element_text(size = 14))
ggsave(p,file = paste0("figures/plots/latex/price_hom_goods.png"), width = 5, height = 5.3)
}

#*********************** FIGURE 2A AND 2B: NIC OF PACK + ECIG (AGG ACROSS STATES) **********************************
if(T){
# plot this to see how it's evolved over time
nic_ec_check = rms_ec %>% group_by(year, year_month) %>% 
  summarise(
    nic_per_ct_ec = weighted.mean(nic_per_hom_ct, w = mL_sales),
    nic_per_mL_ec = weighted.mean(nic_mg_per_ml_avg, w = mL_sales)) %>% ungroup()
nic_ec_check$date = as.Date(paste0(nic_ec_check$year_month, "-01"))


# plot this to see how it's evolved over time
nic_c_check = rms_c %>% group_by(year, year_month) %>% 
  summarise(nic_per_pack_c = weighted.mean(20*nic_per_ct_avg, w = unit_sales)) %>% 
  ungroup()
nic_c_check$date = as.Date(paste0(nic_c_check$year_month, "-01"))

nic_check = nic_c_check %>% left_join(nic_ec_check, by = c("date", "year", "year_month"))

x_breaks <- get_x_breaks(nic_ec_check, num_ticks = 12)

# put them into same column
nic_check = nic_check %>% 
  pivot_longer(c(nic_per_pack_c, nic_per_ct_ec, nic_per_mL_ec),
               names_to = "type", values_to = "nicotine")
nic_check = nic_check %>% mutate(type = ifelse(type == "nic_per_pack_c", "Cigarette Pack", 
                                           ifelse(type == "nic_per_ct_ec", "One E-cigarette", "One mL of E-liquid")))

p = ggplot(nic_check %>% filter(type %in% c("Cigarette Pack", "One E-cigarette")), aes(x = date))+
  geom_line(aes(y = nicotine, color = type)) +
  theme(legend.position = "bottom", legend.title = element_blank())  + 
  labs(x = "", y = "Nicotine Yield (mg)") +
  scale_color_manual(values = c('One E-cigarette' = '#5ec962', 'Cigarette Pack' = '#3b528b')) +
  theme(legend.text=element_text(size=16),
        axis.title.y=element_text(size=14),
        axis.text.x = element_text(size = 14, hjust = 1, angle = 45),
        axis.text.y = element_text(size = 14))

ggsave(p,file = paste0("figures/plots/latex/nic_yield_hom_goods.png"), width = 5, height = 5.3)


#*********************** FIGURE 2B: NIC PER mL OF ECIG (AGG ACROSS STATES) **********************************
p=ggplot(nic_check %>% filter(type == "One mL of E-liquid"), aes(x = date)) +
  geom_line(aes(y = nicotine), color = '#480882') +
  scale_x_date(breaks = x_breaks, date_labels = "%m/%Y") +  # Format the x-axis labels as MM/YYYY
  theme(legend.position = "bottom", legend.title = element_blank()) + 
  labs(x = "", y = "Nicotine Yield per mL (mg)") +
  theme(legend.text=element_text(size=16),
        axis.title.y=element_text(size=14),
        axis.text.x = element_text(size = 14, hjust = 1, angle = 45),
        axis.text.y = element_text(size = 14))
ggsave(p,file = paste0("figures/plots/latex/nic_yield_mg_per_mL.png"), width = 5, height = 5.3)
}


#***************************************** FIGURE 3: AMOUNT OF ML ON AVG IN EC **********************************
if(T){
  # maybe this is messsed up looking due to starter kits versus refills sales volume
ec_avg_ml = rms_ec %>% group_by(year, year_month) %>%
        summarise(mean_mL = weighted.mean(liq_total_f_avg, w=mL_sales))
ec_avg_ml$date = as.Date(paste0(ec_avg_ml$year_month, "-01"))

p=ggplot(ec_avg_ml, aes(x = date)) +
  geom_line(aes(y = mean_mL), color = '#480882') +
  scale_x_date(breaks = x_breaks, date_labels = "%m/%Y") +  # Format the x-axis labels as MM/YYYY
  labs(x = "", y = "E-cigarette Volume (mL)") +
  theme(legend.text=element_text(size=16),
        axis.title.y=element_text(size=14),
        axis.text.x = element_text(size = 14, hjust = 1, angle = 45),
        axis.text.y = element_text(size = 14))
ggsave(p,file = paste0("figures/plots/latex/ec_liq_tot_avg.png"), width = 5, height = 5.3)
}