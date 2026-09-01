## ============================================================================
## Step 1 of the build pipeline (PROVENANCE ONLY on this machine).
##
## Runs on the BU SCC cluster against the restricted Nielsen Scanner data. It
## produces the cleaned annual store x week x UPC files `full_*_7467_*.RData`,
## which are ALREADY PROVIDED in smoke_firm_dir/raw/cleaned_RMS/ (data-sharing
## agreement — the raw Nielsen inputs are not in this repo). The paths below are
## the cluster paths and will not resolve locally. Start the local pipeline at
## 2_impute_missing_mL.R / 3_build_t2_panel_niccorr.R.
## ============================================================================
rm(list = ls())

# function to get my directory always
get_mydir <- function(current_path){
  current_path_split = strsplit(current_path, "/")[[1]]
  idx = which(current_path_split == "smoke_demand")
  return(paste0(current_path_split[c(1:idx)], "/", collapse = ""))
}

mydir = "/projectnb/econdept/eidschun/pr/smoke_demand"
# current_path = rstudioapi::getActiveDocumentContext()$path 
# mydir = get_mydir(current_path)
# mydir = substr(mydir, 1, nchar(mydir)-1)
library(truncnorm)
library(openxlsx)
library(lubridate)
library(zoo)
library(tidyverse)
library(Hmisc)
library(scales)
library(doParallel)
library(gridExtra)
library(bit64) # ADD TO EVERY CODE FOR NIELSEN
rmsdir = "/restricted/projectnb/nielsendata/Scanner"
nielsen_extracts = "nielsen_extracts/RMS"
until2020dir = "nielsen_extracts/RMS"
after2020dir = "2021-Onward_Scanner_Data/nielsen_extracts/RMS"

cig_codes = "7460"
ec_codes = "7467"
infl_peg = 2023
setwd(mydir)
rms_files = list.files("input/RMS/1_initial")
rms_files = rms_files[grepl("RData", rms_files)]
rms_files = rms_files[grepl("7467", rms_files)]
firm_dir = "/projectnb/econdept/eidschun/pr/smoke_firm"


keep_full = T

cl = makeCluster(detectCores(logical = F), type = "SOCK")
registerDoParallel(cl)

foreach (i = 1:length(rms_files)
         ,.packages = c('tidyverse', 'openxlsx', 'lubridate', 'zoo', 'Hmisc', 'scales')
         ,.export = c('mydir', 'rmsdir', 'cig_codes', 'ec_codes', 
                      'rms_files')
) %dopar%
  {
    filename = rms_files[i]
    
    rms_w_attr =  get(load(file.path(mydir, "input", "RMS", "1_initial", 
                                     filename)))
    
    # TEMPORARY DUE TO FUCK UP
    yr_file = str_extract(filename, "\\d{4}(?=\\.RData)")
    if(yr_file >= 2021 & grepl(cig_codes, filename)){
      rms_w_attr = rms_w_attr %>% mutate(nic_yield_tot_f = num_sticks_f * nic_yield_per_stick_f)
    }
    
    if(F){
      if(grepl(ec_codes, filename)){
        common_stores = common_stores_ec
      } else if(grepl(cig_codes, filename)){
        common_stores = common_stores_cig
      } else{
        stop("unexpected product code detected")
      }
      
      # subset for stores
      rms_w_attr = rms_w_attr %>% filter(store_code_uc %in% common_stores)
    }
    
    if(!keep_full){
      # Drop any rows with crucially missing data
      rms_w_attr = rms_w_attr %>% filter(!is.na(nic_yield_tot_f))
      
      if(grepl(ec_codes, filename)){
        rms_w_attr = rms_w_attr %>% filter(!is.na(num_cartridges_f) & !is.na(liq_total_f))
      } else{
        rms_w_attr = rms_w_attr %>% filter(!is.na(nic_yield_per_stick_f))
      }
    }
    ###  Calculate monthly aggregates
    # create a quantity-sales weight at the upc-week-month level (number of sticks sold) for cigs
    # create a liquid volume- weight for ecigs
    rms_w_attr = rms_w_attr %>% mutate(num_cig_sticks_or_mL_sold = 
                                         ifelse(prod_type == "cig", units * num_sticks_f,
                                                units * liq_total_f))
    
    # create weight as its share in the state-month-size1_units
    # usually size1_units is homogeneous anyway
    if(!keep_full){
      rms_w_attr = rms_w_attr %>% group_by(year, year_month, prod_type,
                                           product_module_code,
                                           fips_state_code) %>% # don't group by state descr
        mutate(upc_store_wk_q_weight = num_cig_sticks_or_mL_sold /
                 sum(num_cig_sticks_or_mL_sold)) %>% ungroup()
      
    }

    if(grepl(ec_codes, filename)){
      load("input/prod_attr/taxes/ec_tax_cotti_per_mL.RData")
      rms_w_attr = rms_w_attr %>% left_join(closed_t, by = c("fips_state_code", 
                                                             "year_month"))
      rms_w_attr$price_per_mL = rms_w_attr$price_d_prmult / rms_w_attr$liq_total_f
      rms_w_attr$nic_mg_per_mL = rms_w_attr$nic_yield_tot_f / rms_w_attr$liq_total_f
      
      
      if(!keep_full){
      # sales-weighted pr / mL * sales-weighted average ml
      # group by real_tau_per_mL beause cotti already put this at year-month level
      rms_w_attr_state = rms_w_attr %>% group_by(year, year_month, prod_type, product_module_code, 
                                                 fips_state_code, real_tau_per_mL) %>% # don't group by state descr
        summarise(rev_sales = sum(units * price_d_prmult), # this is tot revenue sales
                  mL_sales = sum(units * liq_total_f), # this is tot mL sales
                  num_cart_avg = weighted.mean(num_cartridges_f, w = upc_store_wk_q_weight),#size1_amount = weighted.mean(size1_amount, w = upc_store_wk_q_weight), # this is probs not needed
                  nic_per_cart_avg = weighted.mean(nic_yield_per_cart_f, 
                                                   w = upc_store_wk_q_weight),
                  price_per_ml_avg = weighted.mean(price_per_mL,
                                                   w = upc_store_wk_q_weight),
                  liq_total_f_avg = weighted.mean(liq_total_f,
                                                  w = upc_store_wk_q_weight),
                  nic_mg_per_ml_avg = weighted.mean(nic_mg_per_mL,
                                                    w = upc_store_wk_q_weight)# same explanation as above
        ) %>% ungroup()
      
      rms_w_attr_state = rms_w_attr_state %>% mutate(price_per_hom_ct = price_per_ml_avg * liq_total_f_avg,
                                                     nic_per_hom_ct = nic_mg_per_ml_avg * liq_total_f_avg,
                                                     tau_per_hom_ct_real = real_tau_per_mL * liq_total_f_avg)
      }
    } else if(grepl(cig_codes, filename)){
      if(!keep_full){
      rms_w_attr_state = rms_w_attr %>% group_by(year, year_month, prod_type, product_module_code, 
                                                 fips_state_code) %>%
        summarise(rev_sales = sum(units * price_d_prmult), # this is tot revenue sales
                  unit_sales = sum(units * num_sticks_f), # this is tot quant sales (cig sticks)
                  num_ct_state_avg = weighted.mean(num_sticks_f, w = upc_store_wk_q_weight),#size1_amount = weighted.mean(size1_amount, w = upc_store_wk_q_weight), # this is probs not needed
                  nic_per_ct_avg = weighted.mean(nic_yield_per_stick_f, # nic_per_ct formally
                                                 w = upc_store_wk_q_weight), # since strength_descr_mg is per upc, divide by size1_amount and multi, not units 
                  price_per_ct_avg = weighted.mean(price_d_prmult / num_sticks_f, 
                                                   w = upc_store_wk_q_weight) # same explanation as above
        ) %>% ungroup()
      }
    } else{
      stop("unexpected product code detected")
    }
    cpi_data = get(load(file.path(mydir, "input", "Misc", paste0("cpi_mult_peg_to_", infl_peg, "_yr.RData"))))
    
    cpi_data$year = as.character(cpi_data$year)
    
    
    if(!keep_full){
      rms_w_attr_state = rms_w_attr_state %>% left_join(cpi_data, by = c("year"))
      rms_w_attr_state$rev_sales_real = rms_w_attr_state$rev_sales / rms_w_attr_state$infl_mult
    } else{
      rms_w_attr = rms_w_attr %>% left_join(cpi_data, by = "year")
      save(rms_w_attr, file = file.path(firm_dir, "input", "rms_all_info", paste0("full_", filename)))
      break
    }
    if(F){
    yr_file = str_extract(filename, "\\d{4}(?=\\.RData)")
    
    if(grepl(ec_codes, filename)){
      rms_w_attr_state$price_per_mL_avg_real = rms_w_attr_state$price_per_ml_avg / rms_w_attr_state$infl_mult
      rms_w_attr_state$price_per_hom_ct_real = rms_w_attr_state$price_per_hom_ct / rms_w_attr_state$infl_mult
      
      rms_w_attr_state = rms_w_attr_state %>% select(year:fips_state_code, mL_sales, num_cart_avg,
                                                     nic_per_cart_avg, liq_total_f_avg, nic_mg_per_ml_avg,
                                                     nic_per_hom_ct, tau_per_hom_ct_real, infl_mult, rev_sales_real:price_per_hom_ct_real)
      
      save(rms_w_attr_state, file = file.path(mydir, "input", "RMS", "3_state", 
                                              paste0("state_", ec_codes, "_", yr_file, ".RData")))
      
    } else{
      rms_w_attr_state$price_per_ct_avg_real = rms_w_attr_state$price_per_ct_avg / rms_w_attr_state$infl_mult
      
      save(rms_w_attr_state, file = file.path(mydir, "input", "RMS", "3_state", 
                                              paste0("state_", cig_codes, "_", yr_file, ".RData")))
      
    }
    }
    
    
    ### End of calculate monthly aggregates
    
    
  }
closeAllConnections()