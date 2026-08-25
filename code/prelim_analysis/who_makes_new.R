# RMS data from Nielsen. For now, I am not doing 2021-22 years due to issues reconciling that data with 2020-
# CHECK ON UPC 002820019480 (it's in master products) and 081127600052 (it's not)
if(T){
  # we'll do an rm because the storage is so big
  rm(list = ls())
  part0 = T
  part1 = T
  part2 = T
  
  firm_dir = "/projectnb/econdept/eidschun/pr/smoke_firm"
  
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
  ncpdir = "/restricted/projectnb/nielsendata/Panel"
  nielsen_extracts = "nielsen_extracts/RMS"
  until2020dir = "nielsen_extracts/RMS"
  after2020dir = "2021-Onward_Scanner_Data/nielsen_extracts/RMS"
  
  clean_raw_data = T
  
  cps_years = 2013:2023
  
  infl_peg = 2023
  
  setwd(file.path(rmsdir, nielsen_extracts))
  
  # figure out the product module cigs and e-cigs fall into
  load(file.path(mydir, "input/NCP_and_RMS", "prod_module_codes_ecig.RData"))
  load(file.path(mydir, "input/NCP_and_RMS", "prod_module_codes_cig.RData"))
  load(file.path(mydir, "input/NCP_and_RMS", "pmod_codes.RData"))
  

  # Find the movement files up to 2020
  # the movement files are organized as[product_group_code] / [product module code] = [4510] / [7460 or 7467]
  setwd(file.path(rmsdir))
  mvt_paths = c()
  year_vec = c()
  for(yr in cps_years){
    if(yr <= 2020){
      path = file.path(until2020dir, yr, "Movement_Files")
      for(i in list.files(path)){
        x = (list.files(file.path(path, i)))
        if(any(substr(x, 1, 4) %in% c(ecig_codes))){
          
          which_files_idx = which(substr(x, 1, 4) %in% c(ecig_codes))
          which_files = file.path(path, i, x[which_files_idx])
          mvt_paths = c(mvt_paths, which_files)
          year_vec = c(year_vec, rep(yr, length(which_files)))
        }
      }
    } else{
      path = file.path(after2020dir, yr, "Movement_Files/TOBACCO")
      
      for(i in list.files(path)){
        which_files = file.path(path, i)
        
        if(grepl("ALTERNATIVES", which_files)){
          mvt_paths = c(mvt_paths, which_files)
          year_vec = c(year_vec, rep(yr, length(which_files)))
        }

      }
    }
    
  }
  
  # take out SMOKING ACCESSORIES since they don't have UPCs that fall into product_module 7467 or 7460
  year_vec = year_vec[!grepl("SMOKING ACCESSORIES", mvt_paths)]
  mvt_paths = mvt_paths[!grepl("SMOKING ACCESSORIES", mvt_paths)]
  
  
  setwd(rmsdir)
}

# Clean Nielsen data or read in cleaned-versions
if(part0){
setwd(mydir)
prods_master_21_23_raw = read.xlsx(file.path(firm_dir, "raw/manual_added_upc", "O_rms_21_to_23_manual.xlsx"))
prods_master_21_23 = prods_master_21_23_raw %>% select(upc, product_module_code,  brand_descr_f, liq_total_f, num_cartridges_f, product_descr) %>% filter(!is.na(product_module_code)) %>% distinct()
prods_master_21_23 = prods_master_21_23 %>% group_by(upc) %>% 
  slice_max(nchar(product_descr), n = 1, with_ties = FALSE) %>%
  ungroup()

prods_master_until_20_raw = read.xlsx(file.path(firm_dir, "raw/manual_added_upc", "rms_without_year_col_2013_2020_cleaned_flavors.xlsx"))
# remove versioning
prods_master_until_20 = prods_master_until_20_raw %>% select(-c(upc_upc_ver_uc)) %>% distinct()
prods_master_until_20 = prods_master_until_20  %>% group_by(upc) %>% mutate(nic_yield_tot_f = mean(nic_yield_tot_f) ) %>% distinct()
prods_master_until_20 = prods_master_until_20  %>% group_by(upc) %>% 
  slice_max(nchar(product_descr), n = 1, with_ties = FALSE) %>%
  ungroup()
prods_master_until_20 = prods_master_until_20 %>% select(upc, product_module_code:flavor_f, product_descr) %>% distinct()


clean_raw_rms = T
if(clean_raw_rms){



# balanced stores
stores_list = list.files("input/RMS/2_stores/")
stores_list = stores_list[grepl("7467", stores_list) & !grepl("(2019|7465)", stores_list)]
stores_list = sort(stores_list)[4:7]
intersected_stores = get(load("input/RMS/2_stores/stores_21_2019_7467_2019.RData"))

for(store_file in stores_list){
  rms_store = get(load(paste0("input/RMS/2_stores/", store_file)))
  intersected_stores = intersect(intersected_stores, rms_store)
}

# prods_yr_raw = read_tsv(file.path(rmsdir, "nielsen_extracts/RMS", "2015", "Annual_Files",paste0("products_extra_" , "2015", ".tsv")))
# prods_desc = prods_yr_raw %>% select(upc, upc_ver_uc, product_descr)

for(yr_idx in c(1:length(mvt_paths))){
  setwd(rmsdir)
  rms_raw = read_tsv(mvt_paths[yr_idx], col_types = cols(.default = "c"))
  rms = rms_raw
  rms$year = year_vec[yr_idx]
  
  jan_date =paste0((year_vec[yr_idx] + 1), "-01")
  dec_date = paste0(year_vec[yr_idx], "-12-31")
  
  # change the last week to december 31 so that I don't have 2022-01-01 in 2021 data for ex
  rms = rms %>% mutate(week_end = ifelse(substr(week_end,1,7) == jan_date, dec_date, week_end))
  
  if(year_vec[yr_idx] > 2020){
    rms = rms %>% left_join(prods_master_21_23, by = c("upc"))
    
  } else{
    # this gets us upc_ver_uc
    if(F){
      rms_ver = read_tsv(file.path(rmsdir, "nielsen_extracts/RMS", year_vec[yr_idx], "Annual_Files", paste0("rms_versions_", year_vec[yr_idx], ".tsv")),
                         col_types = cols(.default = "c"))
      rms_ver$panel_year = as.numeric(rms_ver$panel_year)
      # merge the RMS version file with the movement file
      rms = rms %>% left_join(rms_ver, by = c("upc", "year" = "panel_year"))
    }
    
    rms = rms %>% left_join(prods_master_until_20, 
                                     by = c("upc"))
  }
  
  rms$prod_type = ifelse(rms$product_module_code %in% ecig_codes, "ec", ifelse(rms$product_module_code %in% cig_codes, "cig", NA))
  rms = rms %>% filter(prod_type == "ec")
  
  rms$units = as.numeric(rms$units)
  rms$prmult = as.numeric(rms$prmult)
  rms$price = as.numeric(rms$price)
  
  if(year_vec[yr_idx] > 2020){
    rms = rms %>% mutate(month=substr(week_end, 6, 7))
  } else{
    rms = rms %>% mutate(month=substr(week_end, 5, 6))
  }
  rms_at_upc = rms %>% group_by(brand_descr_f, upc,  month, product_descr) %>% 
    summarise(mL_sales = sum(units * liq_total_f),
              cart_sales = sum(units * num_cartridges_f),
              rev_sales = sum(units * price/prmult),
              # nic_mg_per_ml_f = unique(nic_mg_per_ml_f),
              # nic_yield_tot_f = unique(nic_yield_tot_f),
              liq_total_f = unique(liq_total_f)) %>% ungroup()
  
  save(rms_at_upc, file = file.path(firm_dir, "input/rms_upc_month_level",
                                    paste0("7467_", year_vec[yr_idx], ".RData")))
  
  if(year_vec[yr_idx] >= 2019){
    rms_bal = rms %>% filter(store_code_uc %in% intersected_stores)
    
    rms_at_upc_bal = rms_bal %>% group_by(brand_descr_f, upc,  month, product_descr) %>% 
      summarise(mL_sales = sum(units * liq_total_f),
                cart_sales = sum(units * num_cartridges_f),
                rev_sales = sum(units * price/prmult) ,
                # nic_mg_per_ml_f = unique(nic_mg_per_ml_f),
                # nic_yield_tot_f = unique(nic_yield_tot_f),
                liq_total_f = unique(liq_total_f) ) %>% ungroup()
                #) %>% ungroup()
    
    save(rms_at_upc_bal, file = file.path(firm_dir, "input/rms_upc_month_level",
                                      paste0("bal_7467_", year_vec[yr_idx], ".RData")))
  }
  
}
} else{
  setwd(firm_dir)
  upc_month_df = data.frame(brand_descr_f = NA, upc = NA, product_descr = NA,
                            month = NA, mL_sales = NA, cart_sales = NA,
                            rev_sales = NA, nic_mg_per_ml_f = NA,
                            nic_yield_tot_f = NA, liq_total_f = NA, year = NA)
  
  upc_month_df_bal = upc_month_df
  
  setwd(firm_dir)
  cleaned_files = sort(list.files("input/rms_upc_month_level"))
  unbalanced_files = cleaned_files[!grepl("bal", cleaned_files)]
  balanced_files = cleaned_files[grepl("bal", cleaned_files)]
  for(i in 1:length(unbalanced_files)){
    temp = get(load(file.path('input', 'rms_upc_month_level', unbalanced_files[i])))
    temp$year = year_vec[i]
    upc_month_df = bind_rows(upc_month_df, temp)
  }
  upc_month_df = upc_month_df[2:nrow(upc_month_df),]
  
  # repeat for balanced ones
  for(i in 1:length(balanced_files)){
    temp = get(load(file.path('input', 'rms_upc_month_level', balanced_files[i])))
    temp$year = 2019 + i - 1
    upc_month_df_bal = bind_rows(upc_month_df_bal, temp)
  }
  upc_month_df_bal = upc_month_df_bal[2:nrow(upc_month_df_bal),]
  
}

clean_raw_ncp = T
if(clean_raw_ncp){
  setwd(ncpdir)
  ncp_ec_all = data.frame(purchase_date = NA, upc = NA, 
                          product_descr_f = NA, 
                          nic_yield_tot_f = NA, nic_yield_per_cart_f = NA,
                          nic_mg_per_ml_f = NA, nic_yield_per_stick_f = NA,
                          num_sticks_f = NA, liq_cart_f = NA, flavor_f = NA,
                          product_module_code = NA,  brand_descr_f = NA, liq_total_f = NA,
                          num_cartridges_f = NA, year = NA)
  for(yr in 2013:2023){
    if(yr <= 2020){
      ncp_raw = read_tsv(paste0(yr, "/Annual_Files/purchases_", yr, ".tsv"))
      ncp_ec = ncp_raw %>% filter(upc %in% c(prods_master_until_20$upc, 
                                                        prods_master_21_23$upc))
      trips_raw = read_tsv(paste0(yr, "/Annual_Files/trips_", yr, ".tsv"))
      ncp_ec = ncp_ec %>% left_join(prods_master_until_20, by = c("upc"))
      ncp_ec = ncp_ec %>% mutate(matched_20 = ifelse(product_module_code == 7467, T, F))
      
      if(nrow(ncp_ec) != sum(ncp_ec$matched_20,  na.rm = T)){
        ncp_ec = ncp_ec %>% left_join(prods_master_21_23 %>% filter(product_module_code == "7467"), by = c("upc"))
        
        # now choose correct ones
        ncp_ec = ncp_ec %>% mutate(product_module_code = ifelse(matched_20, product_module_code.x, product_module_code.y),
                                   brand_descr_f = ifelse(matched_20, brand_descr_f.x, brand_descr_f.y),
                                   liq_total_f = ifelse(matched_20, liq_total_f.x, liq_total_f.y),
                                   num_cartridges_f = ifelse(matched_20, num_cartridges_f.x, brand_descr_f.y),
                                   product_descr_f = ifelse(matched_20, product_descr.x, product_descr.y)) %>%
          select(-c(product_module_code.x, product_module_code.y,
                    brand_descr_f.x, brand_descr_f.y,
                    liq_total_f.x, liq_total_f.y,
                    num_cartridges_f.x, num_cartridges_f.y, 
                    product_descr.x, product_descr.y))
      }
      
    } else{
      ncp_raw = read_tsv(paste0("2021-Onward_Panel_Data/nielsen_extracts/HMS/", yr,"/Annual_Files/purchase.tsv"))
      ncp_ec = ncp_raw %>% filter(upc %in% c(prods_master_until_20$upc, 
                                                        prods_master_21_23$upc))
      trips_raw = read_tsv(paste0("2021-Onward_Panel_Data/nielsen_extracts/HMS/", yr,"/Annual_Files/trip.tsv"))
      ncp_ec = ncp_ec  %>% left_join(prods_master_21_23, by = c("upc"))
      ncp_ec = ncp_ec %>% mutate(matched_21_23 = ifelse(product_module_code == "7467", T, F))
      if(nrow(ncp_ec) != sum(ncp_ec$matched_21_23, na.rm = T)){
        ncp_ec = ncp_ec %>% left_join(prods_master_until_20 %>% filter(product_module_code == "7467"), by = c("upc"))
        npc_ec = ncp_ec %>% distinct() # takes care of many-to-many
        # now choose correct ones
        ncp_ec = ncp_ec %>% mutate(product_module_code = ifelse(matched_21_23, product_module_code.x, product_module_code.y),
          brand_descr_f = ifelse(matched_21_23, brand_descr_f.x, brand_descr_f.y),
          liq_total_f = ifelse(matched_21_23, liq_total_f.x, liq_total_f.y),
          num_cartridges_f = ifelse(matched_21_23, num_cartridges_f.x, brand_descr_f.y),
          product_descr_f = ifelse(matched_21_23, product_descr.x, product_descr.y)) %>%
          select(-c(product_module_code.x, product_module_code.y,
                    brand_descr_f.x, brand_descr_f.y,
                    liq_total_f.x, liq_total_f.y,
                    num_cartridges_f.x, num_cartridges_f.y, product_descr.x, product_descr.y))
                                   
        
      }
      
    }
    
    ncp_ec = ncp_ec %>% filter(!is.na(product_module_code))
    
    ncp_ec = ncp_ec %>% left_join(trips_raw, by = c("trip_code_uc"))
    ncp_ec = ncp_ec %>% select(purchase_date, upc, 
                                product_descr_f, nic_yield_tot_f,
                               nic_yield_per_cart_f, nic_mg_per_ml_f,
                               nic_yield_per_stick_f, num_sticks_f, liq_cart_f, 
                               flavor_f, product_module_code, brand_descr_f, 
                               liq_total_f, num_cartridges_f) %>% distinct()
    ncp_ec$year = yr
    ncp_ec$num_cartridges_f = as.numeric(ncp_ec$num_cartridges_f)
    ncp_ec_all = bind_rows(ncp_ec_all, ncp_ec)
    
  }
  ncp_ec_all = ncp_ec_all[2:nrow(ncp_ec_all),]
  ncp_ec_all$month = substr(ncp_ec_all$purchase_date, 6, 7)
  ncp_ec_all = ncp_ec_all %>% mutate(m_date = ym(paste0(year, "-", month)))
  ncp_ec_all = ncp_ec_all %>% select(-purchase_date) %>% distinct()
  ncp_ec_all$product_module_code = NULL
  setwd(firm_dir)
  save(ncp_ec_all, file = "input/ncp_upc_month_level/ncp_ec_all_months.RData")
  ncp_ec_all_fm = ncp_ec_all %>% group_by(upc,
                                          product_descr_f, product_type, nic_yield_tot_f,
                                          nic_yield_per_cart_f, nic_mg_per_ml_f,
                                          nic_yield_per_stick_f, num_sticks_f, liq_cart_f, 
                                          flavor_f, brand_descr_f, 
                                          liq_total_f, num_cartridges_f) %>% 
    summarise(first_ym = first(m_date))
  save(ncp_ec_all_fm, file = "input/ncp_upc_month_level/ncp_ec_all_fm.RData")
} else{
  setwd(firm_dir)
  load("input/ncp_upc_month_level/ncp_ec_all_months.RData")
  load("input/ncp_upc_month_level/ncp_ec_all_fm.RData")
}
break
# put the nielsen scanner and panel data together for the unbalanced
if(T){
  # 1. Remove unneeded sales columns
  sales_clean <- upc_month_df %>%
    select(-mL_sales, -cart_sales, -rev_sales)
  
  # 2. Stack both datasets
  combined_obs <- bind_rows(
    sales_clean,
    ncp_ec_all
  ) %>%
    distinct(upc, year, month, .keep_all = TRUE) %>%
    mutate(m_date = as.Date(paste(year, month, "01", sep = "-")))
  
  # 3. Find earliest observed month for each product
  first_obs <- combined_obs %>%
    group_by(upc) %>%
    summarise(first_date = min(m_date), last_date = max(m_date), .groups = "drop")
  
  # 4. Create continuous monthly sequence from earliest to last observed date
  expanded <- first_obs %>%
    rowwise() %>%
    mutate(all_months = list(seq(from = first_date, to = last_date, by = "1 month"))) %>%
    unnest(all_months) %>%
    rename(m_date = all_months)
  
  # 5. Join back any other columns from combined_obs
  upcs_observed <- expanded %>%
    left_join(combined_obs, by = c("upc", "m_date")) %>%
    arrange(upc, m_date)
  
  # fill in all the missing characteristics due to filling in for missing months within the first-to-last month range
  upcs_observed <- upcs_observed %>%
    group_by(upc) %>%
    arrange(m_date, .by_group = TRUE) %>%
    fill(
      brand_descr_f,
      nic_mg_per_ml_f,
      nic_yield_tot_f,
      liq_total_f,
      product_descr_f,
      nic_yield_per_cart_f,
      nic_yield_per_stick_f,
      num_sticks_f,
      liq_cart_f,
      flavor_f,
      num_cartridges_f,
      .direction = "downup" # fill forward then backward so both ends get values
    ) %>%
    ungroup()
  upcs_observed$year = substr(upcs_observed$m_date,1, 4)
  upcs_observed$month = substr(upcs_observed$m_date,6, 7)
  upcs_from_all_niel = upcs_observed
}
}

# graph over time, HHI, number of products, number of brands
if(part1){
count_and_plot_upcs_by_time <- function(df, balanced  = F, use_all_niel){

    # Count number of e-cigarette barcodes by month
    df <- df %>%
      mutate(
        month = as.integer(month),
        quarter = quarter(month),
        year = as.integer(year)
      )
    
    # Group by year and quarter
    num_prods_by_month <- df %>%
      group_by(year, quarter, month) %>%
      summarise(num_unique_ec = n_distinct(upc), 
                num_unique_brand = n_distinct(brand_descr_f),
                .groups = "drop") %>%
      mutate(
        m_date = ym(paste0(year, "-", month)),
        # Create a date for plotting (first day of quarter)
        q_date = yq(paste0(year, " Q", quarter)) # in case i want to group by quarter
      )
    
    num_prods_by_month <- num_prods_by_month %>%
      mutate(
        q_label = paste0(year, "-Q", quarter)
      )
    
    if(use_all_niel){
      # stop here because don't want HHI stuff
      return(num_prods_by_month)
    }
    # calculate lagged HHI
    hhi = df %>% filter(!is.na(brand_descr_f)) %>%
      group_by(year, quarter, month, brand_descr_f) %>%
      summarise(rev = sum(rev_sales, na.rm = TRUE), .groups = "drop") %>%
      group_by(year, quarter, month) %>%
      mutate(
        share = rev / sum(rev) * 100, # do this as a percentage
        share_sq = share^2
      ) %>%
      summarise(HHI = sum(share_sq), .groups = "drop") %>%
      mutate(
        month_date = ym(paste0(year, "-", month)),
        quarter_date = as.Date(as.yearqtr(paste(year, quarter), format = "%Y %q"))
      ) %>%
      arrange(month_date) %>%
      mutate(HHI_lag = lag(HHI)) %>% select(month_date, HHI_lag, HHI)
    
    num_prods_by_month = num_prods_by_month %>% left_join(hhi, by = c("m_date" = "month_date"))
    
    file_suffix = ifelse(balanced, "balanced", "unbalanced")
    line_color = ifelse(balanced, "darkgreen", "steelblue")
    # because balanced is only for 2019 and after
    
    plot_HHI_and_prods_and_brands <- function(num_prods_by_month_df, at_and_after_2019){
      title_suffix = ifelse(at_and_after_2019, "(2019 and after)", "")
      title_file_suffix = ifelse(at_and_after_2019, "-after_2019", "")
      
      # scaling factor so both lines fit on the same plot
      scale_factor <- max(num_prods_by_month$num_unique_ec, na.rm = TRUE) /
        max(num_prods_by_month$HHI_lag, na.rm = TRUE)
      
      a = ggplot(num_prods_by_month, aes(x = m_date)) +
        # left axis: num_unique_ec in line_color
        geom_line(aes(y = num_unique_ec), color = line_color, linewidth = 0.5) +
        geom_point(aes(y = num_unique_ec), color = line_color) +
        
        # right axis: HHI_lag in black
        geom_line(aes(y = HHI_lag * scale_factor), color = "black", linewidth = 0.5) +
        geom_point(aes(y = HHI_lag * scale_factor), color = "black") +
        
        scale_y_continuous(
          name = "Unique UPCs",
          sec.axis = sec_axis(~ . / scale_factor, name = "HHI (lag)")
        ) +
        scale_x_date(
          date_breaks = "3 month",
          date_labels = "%b %Y",
          expand = c(0, 0)
        ) +
        labs(
          title = paste0("Lagged HHI and Monthly Count of Unique E-Cigarette Products W/ Positive Sales", title_suffix),
          subtitle = file_suffix,
          x = ""
        ) +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.y.left  = element_text(color = line_color, size = 12, face = "bold"),
          axis.text.y.left   = element_text(color = line_color),
          axis.title.y.right = element_text(color = "black", size = 12, face = "bold"),
          axis.text.y.right  = element_text(color = "black")
        )
      
    ggsave(a, file = paste0("output/prelim_analysis/mkt_offer/HHI_and_unique_prods_", file_suffix,"-",  title_file_suffix,  ".png"),
           height = 6, width = 8)
    
    scale_factor <- max(num_prods_by_month$num_unique_brand, na.rm = TRUE) /
      max(num_prods_by_month$HHI_lag, na.rm = TRUE)
    
    a2 = ggplot(num_prods_by_month, aes(x = m_date)) +
      # left axis: num_unique_ec in line_color
      geom_line(aes(y = num_unique_brand), color = line_color, linewidth = 0.5) +
      geom_point(aes(y = num_unique_brand), color = line_color) +
      
      # right axis: HHI_lag in black
      geom_line(aes(y = HHI_lag * scale_factor), color = "black", linewidth = 0.5) +
      geom_point(aes(y = HHI_lag * scale_factor), color = "black") +
      
      scale_y_continuous(
        name = "Unique UPCs",
        sec.axis = sec_axis(~ . / scale_factor, name = "HHI (lag)")
      ) +
      scale_x_date(
        date_breaks = "3 month",
        date_labels = "%b %Y",
        expand = c(0, 0)
      ) +
      labs(
        title = paste0("Lagged HHI and Monthly Count of Unique E-Cigarette Brands W/ Positive Sales", title_suffix),
        subtitle = file_suffix,
        x = ""
      ) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.y.left  = element_text(color = line_color, size = 12, face = "bold"),
        axis.text.y.left   = element_text(color = line_color),
        axis.title.y.right = element_text(color = "black", size = 12, face = "bold"),
        axis.text.y.right  = element_text(color = "black")
      )
    
    ggsave(a2, file = paste0("output/prelim_analysis/mkt_offer/HHI_and_unique_brands_", file_suffix,"-",  title_file_suffix,  ".png"),
           height = 6, width = 8)
    
    ##### PART 2 REPEAT FOR NEW PRODUCT ENTRIES
    # STEP 1: Flag new products (first appearance of each UPC)
    df = df %>% mutate(q_date = yq(paste0(year, " Q", quarter)),
                       m_date = ym(paste0(year, "-", month)))
    
    df_new_ec <- df %>%
      group_by(upc) %>%
      summarise(
        first_qtr_date = min(q_date),
        first_month_date = min(m_date),
        .groups = "drop"
      )
    
    df_new_ec = df_new_ec %>% group_by(first_month_date) %>% summarise(num_new = n()) %>% ungroup()
    
    df_new_ec = df_new_ec %>% filter(first_month_date != min(first_month_date))
    
    df_new_ec = df_new_ec %>% left_join(num_prods_by_month_df %>% select(m_date, HHI_lag, HHI), by = c("first_month_date" = "m_date"))
    # scaling factor so both lines fit nicely
    scale_factor <- max(df_new_ec$num_new, na.rm = TRUE) /
      max(df_new_ec$HHI_lag, na.rm = TRUE) * .3
    
    c <- ggplot(data = df_new_ec, aes(x = first_month_date)) + 
      # left axis: num_new
      geom_line(aes(y = num_new), color = line_color, linewidth = 0.5) + 
      geom_point(aes(y = num_new), color = line_color) + 
      
      # right axis: HHI_lag
      geom_line(aes(y = HHI_lag * scale_factor), color = "black", linewidth = 0.5) + 
      geom_point(aes(y = HHI_lag * scale_factor), color = "black") + 
      
      labs(
        title = "Lagged HHI and Monthly New Unique E-Cigarette Products",
        subtitle = file_suffix,
        x = "",
        y = "Unique UPCs"
      ) +
      scale_y_continuous(
        name = "Unique New UPCs",
        sec.axis = sec_axis(~ . / scale_factor, name = "HHI (lag)")
      ) +
      scale_x_date(
        date_breaks = "3 month",
        date_labels = "%b %Y",  # e.g., "Feb 2019"
        expand = c(0, 0)
      ) +
      theme(
        axis.text.x      = element_text(angle = 45, hjust = 1),
        axis.title.y.left  = element_text(color = line_color, size = 12, face = "bold"),
        axis.text.y.left   = element_text(color = line_color),
        axis.title.y.right = element_text(color = "black", size = 12, face = "bold"),
        axis.text.y.right  = element_text(color = "black")
      )
    
    ggsave(c, file = paste0("output/prelim_analysis/mkt_offer/new_ec_prods_", file_suffix, "-", title_file_suffix, ".png"),
           height = 6, width = 8)
    
    # count number of unique brands
    df_new_brand_all_months = df %>% select(m_date) %>% distinct() %>% arrange(m_date)
    
    df_new_brand = df %>%
      group_by(brand_descr_f) %>%
      summarise(
        first_qtr_date = min(q_date),
        first_month_date = min(m_date),
        .groups = "drop"
      )
    
    df_new_brand = df_new_brand %>% group_by(first_month_date) %>% summarise(num_new = n()) %>% ungroup()
    
    df_new_brand = df_new_brand %>% filter(first_month_date != min(first_month_date))
    
    
    df_new_brand = df_new_brand_all_months %>% left_join(df_new_brand, by = c("m_date" = "first_month_date"))
    
    df_new_brand = df_new_brand %>% mutate(num_new = ifelse(is.na(num_new), 0, num_new))
    
    df_new_brand = df_new_brand %>% left_join(num_prods_by_month_df %>% select(m_date, HHI_lag, HHI), by = c("m_date"))
    
    scale_factor <- max(df_new_brand$num_new, na.rm = TRUE) /
      max(df_new_brand$HHI_lag, na.rm = TRUE) * .3
    
    c2 <- ggplot(data = df_new_brand, aes(x = m_date)) + 
      # left axis: num_new
      geom_line(aes(y = num_new), color = line_color, linewidth = 0.5) + 
      geom_point(aes(y = num_new), color = line_color) + 
      
      # right axis: HHI_lag
      geom_line(aes(y = HHI_lag * scale_factor), color = "black", linewidth = 0.5) + 
      geom_point(aes(y = HHI_lag * scale_factor), color = "black") + 
      
      labs(
        title = "Lagged HHI and Monthly New Unique E-Cigarette Brands",
        subtitle = file_suffix,
        x = "",
        y = "Unique UPCs"
      ) +
      scale_y_continuous(
        name = "Unique New Brands",
        sec.axis = sec_axis(~ . / scale_factor, name = "HHI (lag)")
      ) +
      scale_x_date(
        date_breaks = "3 month",
        date_labels = "%b %Y",  # e.g., "Feb 2019"
        expand = c(0, 0)
      ) +
      theme(
        axis.text.x      = element_text(angle = 45, hjust = 1),
        axis.title.y.left  = element_text(color = line_color, size = 12, face = "bold"),
        axis.text.y.left   = element_text(color = line_color),
        axis.title.y.right = element_text(color = "black", size = 12, face = "bold"),
        axis.text.y.right  = element_text(color = "black")
      )
    
    
    ggsave(c2, file = paste0("output/prelim_analysis/mkt_offer/new_ec_brands_", file_suffix, "-", title_file_suffix, ".png"),
           height = 6, width = 8)
    }


    if(!balanced){
      plot_HHI_and_prods_and_brands(num_prods_by_month, at_and_after_2019 = F)
    }
          
    # Filter for after Jan 2019, to see if we can match truth initiative
    num_prods_by_month_after_xxx <- num_prods_by_month %>% filter(year >= 2019)
    
    plot_HHI_and_prods_and_brands(num_prods_by_month_after_xxx, at_and_after_2019 = T)

    return(num_prods_by_month)
}

num_prods_by_month_rms = count_and_plot_upcs_by_time(df = upc_month_df, balanced = F, use_all_niel = F)
x_null = count_and_plot_upcs_by_time(df = upc_month_df_bal, balanced = T, use_all_niel = F)
num_prods_by_month_all_niel = count_and_plot_upcs_by_time(df = upcs_from_all_niel, balanced = F, use_all_niel = T)

## plots to compare rms to rms + ncp for number of unique products / brands
compare_niel = num_prods_by_month_rms %>% select(m_date, num_unique_ec, num_unique_brand) %>%
  rename(rms_num_unique_ec = num_unique_ec, rms_num_unique_brand = num_unique_brand)
compare_niel = compare_niel %>% left_join(num_prods_by_month_all_niel %>% 
                                            select(m_date, num_unique_ec, num_unique_brand) ,
                                          by = c("m_date"))
compare_niel = compare_niel %>% pivot_longer(cols = rms_num_unique_ec:num_unique_brand,
                                             names_to = c("is_rms", ".value"),
                                             names_pattern = "(rms_)?(num_unique_.+)") %>%
                                               mutate(source = factor(ifelse(is_rms == "", "NCP & RMS", "RMS")))

compare = ggplot(data = compare_niel, aes(x = m_date, y = num_unique_ec, color = source)) + geom_line() +
  geom_point() + labs(x = "", y = "Number of Unique E-Cig UPCs")
ggsave(compare, file = paste0("output/prelim_analysis/mkt_offer/compare_data_unique_upc_unbalanced.png"),
       height = 6, width = 8)
compare = ggplot(data = compare_niel %>% filter(m_date >= "2019-01-01" & m_date <= "2023-01-01"), aes(x = m_date, y = num_unique_ec, color = source)) + geom_line() +
  geom_point() + labs(x = "", y = "Number of Unique E-Cig UPCs")
ggsave(compare, file = paste0("output/prelim_analysis/mkt_offer/compare_data_unique_upc_unbalanced-subset_yrs.png"),
       height = 6, width = 8)
compare = ggplot(data = compare_niel, aes(x = m_date, y = num_unique_brand, color = source)) + geom_line() +
  geom_point() + labs(x = "", y = "Number of Unique E-Cig Brands")
ggsave(compare, file = paste0("output/prelim_analysis/mkt_offer/compare_data_unique_brands_unbalanced.png"),
       height = 6, width = 8)

## plots to compare rms to rms + ncp for NEW products and brands
all_niel_new_ec <- upcs_from_all_niel %>%
  group_by(upc) %>%
  summarise(
    first_month_date = min(m_date),
    .groups = "drop"
  )
all_niel_new_ec = all_niel_new_ec %>% group_by(first_month_date) %>% summarise(num_new = n()) %>% ungroup()
all_niel_new_ec = all_niel_new_ec %>% filter(first_month_date != min(first_month_date))

rms_niel_new_ec <- upc_month_df %>% mutate(m_date = ym(paste0(year, "-", month))) %>% 
  group_by(upc) %>%
  summarise(
    first_month_date = min(m_date),
    .groups = "drop"
  )
rms_niel_new_ec = rms_niel_new_ec %>% group_by(first_month_date) %>% summarise(num_new = n()) %>% ungroup()
rms_niel_new_ec = rms_niel_new_ec %>% filter(first_month_date != min(first_month_date)) %>% rename(rms_num_new = num_new)

compare_niel = rms_niel_new_ec %>% left_join(all_niel_new_ec ,
                                          by = c("first_month_date"))
compare_niel = compare_niel %>% pivot_longer(cols = -first_month_date,
                                             names_to = c("is_rms", ".value"),
                                             names_pattern = "(rms_)?(num_new.*)") %>%
  mutate(source = factor(ifelse(is_rms == "", "NCP & RMS", "RMS")))
compare_niel_exp <- expand.grid(
  first_month_date = seq(ym("2013-03"), ym("2023-12"), by = "month"),
  source = c("NCP & RMS", "RMS")
)
compare_niel_exp = compare_niel_exp %>% left_join(compare_niel, by = c("first_month_date", "source"))
compare_niel_exp = compare_niel_exp %>% mutate(num_new = ifelse(is.na(num_new), 0, num_new))
compare = ggplot(data = compare_niel_exp, 
                 aes(x = first_month_date, y = num_new, color = source)) + geom_line(alpha = 0.6) +
  geom_point(size = 0.8) + labs(x = "", y = "Number of New E-Cig UPCs")
ggsave(compare, file = paste0("output/prelim_analysis/mkt_offer/compare_data_new_upc_unbalanced.png"),
       height = 6, width = 8)
}

# what is driving the peaks of new products? Jan 2021
if(part2){
  jan_2021_new = upcs_from_all_niel %>% filter(first_date == "2021-01-01") %>%
    select(upc:last_date, brand_descr_f) %>% distinct()
  top_3_new_prods_brands = table(jan_2021_new$brand_descr_f) %>% as.data.frame() %>% arrange(-Freq) %>% slice(1:3) %>% pull(Var1)
  
  # see how these 3 brands evolved
  upcs_top_3_new_prods = upcs_from_all_niel %>% filter(brand_descr_f %in% top_3_new_prods_brands) %>% 
    select(upc:last_date, brand_descr_f, product_descr_f) %>% distinct() %>% arrange(brand_descr_f, first_date, upc)
  
  View(upcs_top_3_new_prods)
}
break

if(F){
##### PART 2 TRY TO IDENTIFY NEW PRODUCT ENTRIES
# STEP 1: Flag new products (first appearance of each UPC)
upc_month_df_bal <- upc_month_df_bal %>%
  group_by(upc) %>%
  mutate(first_year = min(year)) %>%
  ungroup() %>%
  mutate(new_product = (year == first_year))

# STEP 2: Identify brands with <5 total new products across all years
brand_new_totals <- upc_month_df_bal %>%
  filter(new_product) %>%
  count(brand_descr_f, name = "total_new_products")

low_entry_brands <- brand_new_totals %>%
  filter(total_new_products <=10) %>%
  pull(brand_descr_f)
}

## Graph of lag HHI versus number of NEW products
# HHI calculated using revenue share
if(T){
  calc_hhi = function(df){
    df = df %>% filter(!is.na(brand_descr_f))
    # STEP 0: Prepare quarter and quarter_date
    df <- df %>%
      mutate(
        month = as.integer(month),
        quarter = case_when(
          month %in% 1:3   ~ 1,
          month %in% 4:6   ~ 2,
          month %in% 7:9   ~ 3,
          month %in% 10:12 ~ 4
        ),
        quarter_date = as.Date(as.yearqtr(paste(year, quarter), format = "%Y %q"))
      )
    
    # STEP 1: Compute lagged HHI by quarter using brand_descr_f as firm
    hhi_df <- df %>%
      group_by(year, quarter, brand_descr_f) %>%
      summarise(rev = sum(rev_sales, na.rm = TRUE), .groups = "drop") %>%
      group_by(year, quarter) %>%
      mutate(
        share = rev / sum(rev) * 100, # do this as a percentage
        share_sq = share^2
      ) %>%
      summarise(HHI = sum(share_sq), .groups = "drop") %>%
      mutate(
        quarter_date = as.Date(as.yearqtr(paste(year, quarter), format = "%Y %q"))
      ) %>%
      arrange(quarter_date) %>%
      mutate(HHI_lag = lag(HHI))
    
    # STEP 2: Flag new products based on first quarter appearance
    first_seen <- df %>%
      group_by(upc) %>%
      summarise(
        first_qtr_date = min(quarter_date),
        .groups = "drop"
      )
    
    df_flagged <- df %>%
      left_join(first_seen, by = c("upc")) %>%
      mutate(new_product = (quarter_date == first_qtr_date))
    
    # STEP 3: Count new products by quarter
    new_prods_by_quarter <- df_flagged %>%
      filter(new_product) %>%
      group_by(year, quarter) %>%
      summarise(num_new_products = n_distinct(upc), .groups = "drop") %>%
      mutate(
        quarter_date = as.Date(as.yearqtr(paste(year, quarter), format = "%Y %q"))
      )
    
    # STEP 4: Merge HHI and innovation
    innovation_df <- left_join(new_prods_by_quarter, hhi_df, by = "quarter_date")
    
    return(innovation_df) 
  }
  
  innovation_df_bal = calc_hhi(df = upc_month_df_bal)
  innovation_df = calc_hhi(df = upc_month_df)
  
  # STEP 5: Plot
  new_prods_vs_L_hhi = ggplot(innovation_df, aes(x = HHI_lag, y = num_new_products)) +
    geom_point(color = "blue", alpha = 0.7) +
    geom_smooth(method = "lm", se = F, color = "red", linewidth = 1) +
    labs(
      title = "Quarterly New Product Entry vs. Lagged HHI",
      subtitle = "388 product - Jan 2021 \n Highly concentrated \n Balanced 2019 - 2023 data",
      x = "Lagged HHI",
      y = "Number of New E-Cigarette Products"
    ) 
  
  ggsave(new_prods_vs_L_hhi, file = paste0("output/prelim_analysis/mkt_offer/mkt_offernew_prods_vs_L_hhi.png"),
         height = 6, width = 8)
}

# STEP 3: Reassign those brands to "OTHER"
upc_month_df_bal <- upc_month_df_bal %>%
  mutate(brand_descr_f = ifelse((brand_descr_f %in% low_entry_brands) | is.na(brand_descr_f), "OTHER", brand_descr_f))

# STEP 4: Re-flag new products (brand name might have changed)
upc_month_df_bal <- upc_month_df_bal %>%
  group_by(upc) %>%
  mutate(first_year = min(year)) %>%
  ungroup() %>%
  mutate(new_product = (year == first_year))

# STEP 2: Identify brands with <5 total new products across all years
brand_new_totals <- upc_month_df_bal %>%
  filter(new_product) %>%
  distinct(upc, .keep_all = TRUE) %>%   # <-- only count each new product once (matters bc i have monthly data)
  count(brand_descr_f, name = "total_new_products")

low_entry_brands <- brand_new_totals %>%
  filter(total_new_products <=20) %>%
  pull(brand_descr_f)

if(T){
  # STEP 2.5: Compute prior-year total sales by brand
  brand_year_sales <- upc_month_df_bal %>%
    group_by(year, brand_descr_f) %>%
    summarise(
      rev_sales = sum(rev_sales, na.rm = TRUE),
      cart_sales = sum(cart_sales, na.rm = TRUE),
      ml_sales = sum(liq_total_f, na.rm = TRUE),
      .groups = "drop"
    )
  
  # number of new products per brand per year
  brand_new_products <- upc_month_df_bal %>%
    filter(new_product) %>% # filters for first year (and months) in which upc first appeared
    distinct(upc, .keep_all = TRUE) %>%
    group_by(year, brand_descr_f) %>%
    summarise(num_new_products = n(), .groups = "drop")
  
  # Join in current year’s sales
  brand_product_stats <- brand_new_products %>%
    left_join(brand_year_sales, by = c("year" = "year", "brand_descr_f" = "brand_descr_f")) 
  
  # put into constant dollar terms
  setwd(mydir)
  load("input/Misc/cpi_mult_peg_to_2023_yr.RData")
  
  brand_product_stats = brand_product_stats %>% left_join(cpi_data, by = "year")
  brand_product_stats$rev_sales = brand_product_stats$rev_sales / brand_product_stats$infl_mult
  
  brand_product_stats = brand_product_stats %>% group_by(brand_descr_f) %>% arrange(year) %>%
    mutate(lag_rev_sales = lag(rev_sales), lag_cart_sales = lag(cart_sales), lag_ml_sales = lag(ml_sales)) %>% ungroup()
  
  # don't want this driven by really-low-sales brands
  brand_product_stats = brand_product_stats %>% group_by(brand_descr_f) %>%
    filter(sum(rev_sales) > 800) %>% ungroup()

  # kick out obs from company's second year in the market, if they're just getting their footing
  brand_product_stats = brand_product_stats %>% group_by(brand_descr_f) %>%
    filter(year != min(year)) %>% ungroup()
  
  
  # Plot (filtering brands with any prior-year sales)
  ggplot(brand_product_stats %>% filter(year > 2013 & !is.na(brand_descr_f) & year != 2020), 
         aes(x = lag_rev_sales, y = num_new_products, color = factor(year))) +
    geom_point(alpha = 0.6) +
    # geom_smooth(method = "lm", se = FALSE) +  # line of best fit per group
    labs(
      title = "New Products vs. Prior-Year Real Revenue Sales (Pre-'OTHER' Recoding)",
      x = "Prior-Year Revenue",
      y = "New Products Introduced"
    ) +
    theme_minimal()
  
  
  ggplot(brand_product_stats %>% filter(year > 2013 & !is.na(brand_descr_f) & year != 2020), 
         aes(x = lag_cart_sales, y = num_new_products, color = factor(year))) +
    geom_point(alpha = 0.6) +
    geom_smooth(method = "lm", se = FALSE) +  # line of best fit per group
    labs(
      title = "New Products vs. Prior-Year # of Cartridges Sold (Pre-'OTHER' Recoding)",
      x = "Prior-Year # Cartridges sold",
      y = "New Products Introduced"
    ) +
    theme_minimal()
  
  
}
# STEP 3: Reassign those brands to "OTHER"
upc_month_df_bal <- upc_month_df_bal %>%
  mutate(brand_descr_f = ifelse((brand_descr_f %in% low_entry_brands) | is.na(brand_descr_f), "OTHER", brand_descr_f))

# STEP 4: Re-flag new products (brand name might have changed)
upc_month_df_bal <- upc_month_df_bal %>%
  group_by(upc) %>%
  mutate(first_year = min(year)) %>%
  ungroup() %>%
  mutate(new_product = (year == first_year))

# STEP 5 (Fixed): Summarize new product entries by year and brand (deduplicated)
new_product_summary <- upc_month_df_bal %>%
  filter(new_product) %>%
  distinct(upc, .keep_all = TRUE) %>%  
  group_by(year, brand_descr_f) %>%
  summarise(
    num_new_products = n(),
    total_rev_sales = sum(rev_sales, na.rm = TRUE),
    total_cart_sales = sum(cart_sales, na.rm = TRUE),
    total_nic_yield = sum(nic_yield_tot_f, na.rm = TRUE),
    .groups = "drop"
  )

# STEP 6: Identify brand entry year (for possible later use)
brand_entry <- upc_month_df_bal %>%
  group_by(brand_descr_f) %>%
  summarise(first_year = min(year), .groups = "drop")

# STEP 7: Plot using final summary
ggplot(new_product_summary, aes(x = year, y = num_new_products, 
                                fill = brand_descr_f)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "New E-Cigarette Product Entries by Brand",
       x = "Year", y = "Number of New Products") +
  theme_minimal()








