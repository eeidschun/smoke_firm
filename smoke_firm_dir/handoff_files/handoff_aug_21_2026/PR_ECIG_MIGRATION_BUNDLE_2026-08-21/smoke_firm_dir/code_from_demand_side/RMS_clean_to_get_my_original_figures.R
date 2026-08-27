# RMS data from Nielsen. For now, I am not doing 2021-22 years due to issues reconciling that data with 2020-
# CHECK ON UPC 002820019480 (it's in master products) and 081127600052 (it's not)
if(T){
  # we'll do an rm because the storage is so big
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
  
  clean_raw_data = T

  cps_years = 2013:2023
  
  infl_peg = 2023
  
  setwd(file.path(rmsdir, nielsen_extracts))
  
  # figure out the product module cigs and e-cigs fall into
  load(file.path(mydir, "input/NCP_and_RMS", "prod_module_codes_ecig.RData"))
  load(file.path(mydir, "input/NCP_and_RMS", "prod_module_codes_cig.RData"))
  load(file.path(mydir, "input/NCP_and_RMS", "pmod_codes.RData"))
  
  extra_ec = as.numeric(setdiff(final_pmod_2020$product_module_code , c(cig_codes, ecig_codes)))
  
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
        if(any(substr(x, 1, 4) %in% c(cig_codes, ecig_codes, extra_ec))){
          
          which_files_idx = which(substr(x, 1, 4) %in% c(cig_codes, ecig_codes, extra_ec))
          which_files = file.path(path, i, x[which_files_idx])
          mvt_paths = c(mvt_paths, which_files)
          year_vec = c(year_vec, rep(yr, length(which_files)))
        }
      }
    } else{
      path = file.path(after2020dir, yr, "Movement_Files/TOBACCO")
      
      for(i in list.files(path)){
        which_files = file.path(path, i)
        
        mvt_paths = c(mvt_paths, which_files)
        year_vec = c(year_vec, rep(yr, length(which_files)))
      }
    }
    
  }
  
  # take out SMOKING ACCESSORIES since they don't have UPCs that fall into product_module 7467 or 7460
  year_vec = year_vec[!grepl("SMOKING ACCESSORIES", mvt_paths)]
  mvt_paths = mvt_paths[!grepl("SMOKING ACCESSORIES", mvt_paths)]
  
  
  setwd(rmsdir)
}

if(clean_raw_data){
  
  # inputs: year-index, year, and product module code
  ## 1) Read in RMS movement file (upc, store code, quantity, price)
  ## 2) Create proper formatting for time variables
  ## 3) Join to master product file and subset for those that are cigs/ecs
  ## 4) Calculate sales volume and dollar sales
  ## 5) Join to store location data
  ## Result: weekly RMS data (assigned to month) with product features and locations
  ## Product features do not include nicotine
  get_rms_wk_data = function(yr_idx, yr, pmod_code){
    setwd(rmsdir)
    
    # diff dir names based on year
    tempdir = ifelse(yr <=2020, until2020dir, after2020dir)
    
    # main file has cols: store_code_uc, upc, week_end, units, prmult, price
    rms = read_tsv(mvt_paths[yr_idx], col_types = cols(.default = "c"))
    
    # year format is yyyymmdd for <=2020, but is yyyy-mm-dd for > 2020
    rms$week_end = as.numeric(gsub("-", "", rms$week_end))
    
    # extract year (don't just add the year yr because this is transaction date and might be better)
    rms$year = substr(rms$week_end,1,4)
    
    # need to merge rms_ver and prods_master first to get both upc_ver_uc and
    # size1_units. if I left join rms with prods ann then left join with prods_master, I get
    # some NA size1_units
    # Must read this in to get upc_ver_uc so then I can later join in prods_master
    # Only applies to <= 2020 because upc_ver_uc phased out in 2021
    if(yr <=2020){
      rms$product_module_code = pmod_code
      
      # this gets us upc_ver_uc
      rms_ver = read_tsv(file.path(tempdir, yr, "Annual_Files", paste0("rms_versions_", yr, ".tsv")),
                         col_types = cols(.default = "c"))
      
      # merge the RMS version file with the movement file
      rms = rms %>% left_join(rms_ver, by = c("upc", "year" = "panel_year"))
      
      rm(list = "rms_ver")
    }
    
    # Merge in the master products file that I created, identifies ec and c, and has all prod. attributes
    setwd(mydir)
    # Different master files based on <=2020
    if(yr <=2020){
      prods_master_until_20 = get(load("input/NCP_and_RMS/upc_master_to_2020.RData"))
      
      # get relevant part of the master file
      prods_master_yr = prods_master_until_20 %>% filter(year == yr)
      prods_master_yr$year = NULL
      
      rms$product_module_code = NULL
      rms = rms %>% left_join(prods_master_yr, 
                              by = c("upc", "upc_ver_uc"))
      
      # if prod_type is ecig_codes or cig_codes (7467 or 7460) then assign prod_type
      # but if it's 7465 (extra ec mostly, however upc "068146700322" is a cig and in here), this only applies whereever we matched prods_master
      if(pmod_code %in% c(ecig_codes, cig_codes)){
        rms$prod_type = ifelse(pmod_code %in% c(ecig_codes), 
                               "ec", ifelse(pmod_code %in% cig_codes, "cig", NA))
      } else{
        # then pmod_code is 7465 and only take those that were in prods_master
        rms = rms %>% mutate(prod_type = ifelse(
          product_module_code %in% ecig_codes, "ec", 
          ifelse(product_module_code %in% cig_codes, "cig", NA)))
        
        # it is possible that there are no matches for the year from 7465
      }
      rm(list = "prods_master_until_20")
      
      
    } else{
      
      # Read in list of upc/product modules/attributes that was cleaned
      load(paste0("input/NCP_and_RMS/upc_master_2021-2023.RData"))
      
      # get relevant part of the master file
      prods_master_yr = prods_master_21_23 %>% filter(year == yr)
      prods_master_yr$year = NULL
      
      rms = rms %>% left_join(prods_master_yr, by = c("upc"))
      
      rms$prod_type = ifelse(rms$product_module_code %in% ecig_codes, "ec", ifelse(rms$product_module_code %in% cig_codes, "cig", NA))
      
      # any prod_type/product module code which is still NA doesn't fall into ec or cig 
      # category  (like cigars or hookahs)
      
      rm(list = c("prods_master_yr", "prods_master_21_23"))
    }
    
    # now drop anywhere in which product type is NA (this means TOBACCO ALTERNATIVE for example, that doesn't fall into ec or cig cat.)
    # this only affects 2021+ 
    # warning that it seems that 2021-SMOKING ACCESSORIES has no overlap with the above files (no matching UPCs) so prod_type is NA everywhere
    rms = rms %>% filter(!is.na(prod_type))
    
    # this may happen with 7465 codes
    if(nrow(rms) == 0){
      cat('no smoking products in', mvt_paths[yr_idx])
      
      save(rms, file = file.path("input", "RMS","1_initial",
                                 paste0(yr_idx, "_", yr, "_", sub(".*/([^/]+)\\.tsv", "\\1", mvt_paths[yr_idx]), "BLANK.RData")))
      
      break
    }
    
    
    # In preparation for:  aggregate to year-month
    # convert week_end to date
    rms$week_end = as.Date(as.character(rms$week_end), format = "%Y%m%d")
    
    # Create yearmonth object for the week_end
    rms = rms %>% mutate(year_month = format(as.Date(week_end), "%Y-%m"))
    
    # before removing any rows in which store ID isn't known, save an
    # aggregated data frame to calculate sales summary statistics later
    rms = rms %>% mutate(size1xmulti = ifelse(is.na(num_sticks_f), num_cartridges_f, num_sticks_f))
    
    rms_agg_for_sales = rms %>% group_by(year_month, prod_type) %>% 
      summarise(sales = sum(as.numeric(units) * as.numeric(price)/as.numeric(prmult), na.rm  = T),
                unit_sales = sum(as.numeric(units) * size1xmulti, na.rm = T))
    
    save(rms_agg_for_sales, file = file.path(mydir,"input", "RMS", "for_summ_stats",
                                             paste0("sales_without_filter_", 
                                                    sub(".*/([^/]+)\\.tsv", "\\1", mvt_paths[yr_idx]), "_", yr_idx, ".RData")))
    
    # remove any rows in which store ID isn't known
    rms = rms %>% filter(!is.na(store_code_uc))
    
    # Merge in store information
    if(yr <= 2020){
      # colnames: store_code_uc, year (these two are keys), parent_code, retailer_code, channel_code, store_zip3
      # fips_state_code, fips_state_descr, fips_county_code, fips_county_descr, dma_code, dma_descr
      store_info = read_tsv(file.path(rmsdir, nielsen_extracts, yr, "Annual_Files", paste0("stores_", yr, ".tsv")),
                            col_types = cols(.default = "c")
      )
      
      store_info = store_info %>% select(-c(dma_code, dma_descr, fips_county_code, fips_county_descr))
      
      rms = rms %>% left_join(store_info, by = c("year", "store_code_uc"))
      
    } else{
      store_info = read_tsv(file.path(rmsdir, after2020dir, yr, "Annual_Files", "stores.tsv"),
                            col_types = cols(.default = "c"))
      
      # same names except missing: fips_state_descr, fips_county_descr, dma_code, 
      ## IF I END UP USING DMA, READ DOCUMENTATION SINCE DMAS CHANGED SINCE 2020 DOCUMENTATION!!!
      
      # read in state and county IDs. File made in get_state_and_county_ID.R
      load(file.path(mydir, "input", "RMS", "county_state_ID_after2020.RData"))
      
      store_info = store_info %>% left_join(county_state_mapping, by = c("store_zip3", "fips_state_code", "fips_county_code"))
      
      # There are some unmatched stores but lets wait to do merge into EC/C to find out how many are NA
      
      rms = rms %>% left_join(store_info, by = c("year", "store_code_uc"))
      
    }
    
    rm(list = "store_info")
    
    # remove any stores that couldn't match based on store_code_uc
    rms = rms %>% filter(!is.na(fips_state_code))
    
    # Prep for calc sales and volume
    rms$units = as.numeric(rms$units)
    rms$price_d_prmult = as.numeric(rms$price) / as.numeric(rms$prmult)
    
    # remove unnecc variables
    rms = rms %>% select(-c(feature, display, parent_code,
                            retailer_code, channel_code, store_zip3))
    
    
    # These are sales by UPC/store/week. year_month is in there but this is at the week level
    if(yr > 2020 & grepl("TOBACCO ALTERNATIVES", mvt_paths[yr_idx])){
      filename  = paste0(yr_idx, "_", yr, "_", ecig_codes,"_", yr, ".RData")
    } else if(yr > 2020 & grepl("TOBACCO.", mvt_paths[yr_idx])){
      filename  = paste0(yr_idx, "_", yr, "_", cig_codes,"_", yr, ".RData")
    } else if(yr <= 2020 & (any(rms$prod_type == "ec") | any(rms$prod_type == "cig")) & pmod_code == 7465){
      filename_ec = paste0(yr_idx, "_", yr, "_", ecig_codes, "_", yr, "-7465", ".RData")
      filename_cig = paste0(yr_idx, "_", yr, "_", cig_codes, "_", yr, "-7465", ".RData")
      
      if(all(rms$prod_type == "ec")){
        filename = filename_ec
      }
      
      if(all(rms$prod_type == "cig")){
        filename = filename_cig
      }
      
    } else if(yr <= 2020 & pmod_code != 7465){
      filename  =  paste0(yr_idx, "_", yr, "_", sub(".*/([^/]+)\\.tsv", "\\1", mvt_paths[yr_idx]), ".RData")
      
    } else{
      stop("unrecognizable file name")
    }
    
    
    # can be case for pmod code 7465
    if(length(unique(rms$prod_type)) > 1){
      rms_ec = rms %>% filter(prod_type == "ec")
      rms_cig = rms %>% filter(prod_type == "cig")
      
      #exception for some weird thins
      if((!is.na(pmod_code) & pmod_code == 7467) | grepl("TOBACCO ALTERNATIVES", mvt_paths[yr_idx])){
        rms = rms %>% filter(prod_type == "ec")
        save(rms, file = file.path("input/RMS/1_initial", filename))
        break
      } else if((!is.na(pmod_code) & pmod_code == 7460) | grepl("TOBACCO.", mvt_paths[yr_idx])){
        rms = rms %>% filter(prod_type == "cig")
        save(rms, file = file.path("input/RMS/1_initial", filename))
        break
      } else{

        
        save(rms_ec, file = file.path("input/RMS/1_initial", filename_ec))
        save(rms_cig, file = file.path("input/RMS/1_initial", filename_cig))
        
        # record what stores were in this for purpose of balancing later
        rms_stores_ec = unique(rms_ec$store_code_uc)
        rms_stores_cig = unique(rms_cig$store_code_uc)
        
        save(rms_stores_ec, file = file.path(mydir, "input", "RMS", "2_stores", 
                                          paste0("stores_", filename_ec)))
        save(rms_stores_cig, file = file.path(mydir, "input", "RMS", "2_stores", 
                                             paste0("stores_", filename_cig)))
      }
      
    } else{
      save(rms, file = file.path("input", "RMS","1_initial",
                                 filename))
      
      # record what stores were in this for purpose of balancing later
      rms_stores = unique(rms$store_code_uc)
      
      save(rms_stores, file = file.path(mydir, "input", "RMS", "2_stores", 
                                        paste0("stores_", filename)))
    }
    

    
    
    
    rm(list = "rms")
  }
  
  
  cl = makeCluster(detectCores(logical = F), type = "SOCK")
  registerDoParallel(cl)
  
  foreach (yr_idx = c(12, 15, 18, 21, 24, 25, 27, 29)#c(17,18,1,4,7,10)
           ,.packages = c('tidyverse', 'openxlsx', 'lubridate', 'zoo', 'Hmisc', 'scales')
  ) %dopar%
    {
      yr = year_vec[yr_idx]
      
      pmod_code = ifelse(yr <= 2020, substr(mvt_paths[yr_idx], 52, 55), NA)
      
      get_rms_wk_data(yr_idx, yr, pmod_code)
    }
  
  closeAllConnections()
  
}
break
setwd(mydir)
ec_codes = get(load("input/NCP_and_RMS/prod_module_codes_ecig.RData"))
cig_codes = get(load("input/NCP_and_RMS/prod_module_codes_cig.RData"))

### Now get list of common stores
if(F){ # a ton of ec stores get dropped this way

common_store_files = sort(list.files("input/RMS/2_stores"))

common_store_files = common_store_files[!grepl("BLANK", common_store_files)]
common_store_files_ec = common_store_files[grepl(ec_codes, common_store_files)]
common_store_files_cig = common_store_files[grepl(cig_codes, common_store_files)]

first_store_cig_file = common_store_files_cig[grepl(cps_years[1], common_store_files_cig)]
first_store_ec_file = common_store_files_ec[grepl(cps_years[1], common_store_files_ec)]
common_store_cig = get(load(file.path("input/RMS/2_stores", first_store_cig_file)))
common_store_ec = get(load(file.path("input/RMS/2_stores", first_store_ec_file)))

files_w_7465_ec = common_store_files_ec[grepl("7465", common_store_files_ec)]
files_w_7465_cig = common_store_files_cig[grepl("7465", common_store_files_cig)]

f_2017_cig = get(load(file.path("input/RMS/2_stores/stores_13_2017_7460_2017.RData")))
f_2017_cig_7465 = get(load(file.path("input/RMS/2_stores/stores_14_2017_7460_2017-7465.RData")))
stores_cig_2017 = c(f_2017_cig, f_2017_cig_7465)

f_2017_ec = get(load(file.path("input/RMS/2_stores/stores_15_2017_7467_2017.RData")))
f_2017_ec_7465 = get(load(file.path("input/RMS/2_stores/stores_14_2017_7467_2017-7465.RData")))
stores_ec_2017 = c(f_2017_ec, f_2017_ec_7465)

for(f in common_store_files_cig){
  store_f = get(load(file.path("input/RMS/2_stores", f)))
  if(grepl("2017", f)){
    common_store_cig = intersect(common_store_cig, stores_cig_2017)
  } else{
    common_store_cig = intersect(common_store_cig, store_f)
  }
}

for(f in common_store_files_ec){
  print(length(common_store_ec))
  store_f = get(load(file.path("input/RMS/2_stores", f)))
  if(grepl("2017", f)){
    common_store_ec = intersect(common_store_ec, stores_ec_2017)
  } else{
    common_store_ec = intersect(common_store_ec, store_f)
    
  }
}

# this is the set of common store-year pairs
save(common_stores_cig, file = file.path(mydir, "input", "RMS", "2_stores",
                                     paste0("stores_", cig_codes,"_master.RData")))
save(common_stores_ec, file = file.path(mydir, "input", "RMS", "2_stores",
                                         paste0("stores_", ec_codes,"_master.RData")))
}

if(F){
# Combine the 7465 files 
rms_2017_7460 = get(load(file.path(mydir, "input/RMS/1_initial/13_2017_7460_2017.RData")))
rms_2017_7467 = get(load(file.path(mydir, "input/RMS/1_initial/15_2017_7467_2017.RData")))
rms_2017_7467_7465 = get(load(file.path(mydir, "input/RMS/1_initial/14_2017_7467_2017-7465.RData")))
rms_2017_7460_7465 = get(load(file.path(mydir, "input/RMS/1_initial/14_2017_7460_2017-7465.RData")))
rms_2017_7460 = bind_rows(rms_2017_7460, rms_2017_7460_7465)
rms_2017_7467 = bind_rows(rms_2017_7467, rms_2017_7467_7465)

save(rms_2017_7460, file = file.path(mydir, "input/RMS/1_initial/13_2017_7460_2017.RData"))
save(rms_2017_7467, file = file.path(mydir, "input/RMS/1_initial/15_2017_7467_2017.RData"))
}

# now read in all the weekly-files with added attributes and subset them
# so they are balanced across store-year
# now read in all the weekly-files with added attributes and subset them
# so they are balanced across store-year. Do some additional subsetting of 
# empty rows
setwd(mydir)
rms_files = list.files("input/RMS/1_initial")
rms_files = rms_files[grepl("RData", rms_files)]
rms_files = rms_files[!grepl("BLANK", rms_files)]
rms_files = rms_files[!grepl("7465", rms_files)]
rms_files  = rms_files[c(3, 5, 7, 9, 11, 12,14, 16, 17, 20, 22)]
cl = makeCluster(detectCores(logical = F), type = "SOCK")
registerDoParallel(cl)

foreach (i = 1:length(rms_files)
         ,.packages = c('tidyverse', 'openxlsx', 'lubridate', 'zoo', 'Hmisc', 'scales')
         ,.export = c('mydir', 'rmsdir', 'cig_codes', 'ec_codes', 'cps_years',
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
    
    # Drop any rows with crucially missing data
    rms_w_attr = rms_w_attr %>% filter(!is.na(nic_yield_tot_f))
    
    if(grepl(ec_codes, filename)){
      rms_w_attr = rms_w_attr %>% filter(!is.na(num_cartridges_f) & !is.na(liq_total_f))
    } else{
      rms_w_attr = rms_w_attr %>% filter(!is.na(nic_yield_per_stick_f))
    }
    
    ###  Calculate monthly aggregates
    # create a quantity-sales weight at the upc-week-month level (number of sticks sold) for cigs
    # create a liquid volume- weight for ecigs
    rms_w_attr = rms_w_attr %>% mutate(upc_store_wk_q_weight = 
                                         ifelse(prod_type == "cig", units * num_sticks_f,
                                                units * liq_total_f))
    
    # create weight as its share in the state-month-size1_units
    # usually size1_units is homogeneous anyway
    rms_w_attr = rms_w_attr %>% group_by(year, year_month, prod_type,
                                         product_module_code,
                                         fips_state_code) %>% # don't group by state descr
      mutate(upc_store_wk_q_weight = upc_store_wk_q_weight /
               sum(upc_store_wk_q_weight)) %>% ungroup()
    
    if(grepl(ec_codes, filename)){
      load("input/prod_attr/taxes/ec_tax_cotti_per_mL.RData")
      rms_w_attr = rms_w_attr %>% left_join(closed_t, by = c("fips_state_code", 
                                                             "year_month"))
      rms_w_attr$price_per_mL = rms_w_attr$price_d_prmult / rms_w_attr$liq_total_f
      rms_w_attr$nic_mg_per_mL = rms_w_attr$nic_yield_tot_f / rms_w_attr$liq_total_f
      
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
    } else if(grepl(cig_codes, filename)){
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
    } else{
      stop("unexpected product code detected")
    }
    cpi_data = get(load(file.path(mydir, "input", "Misc", paste0("cpi_mult_peg_to_", infl_peg, "_yr.RData"))))
    
    cpi_data$year = as.character(cpi_data$year)
    rms_w_attr_state = rms_w_attr_state %>% left_join(cpi_data, by = c("year"))
    rms_w_attr_state$rev_sales_real = rms_w_attr_state$rev_sales / rms_w_attr_state$infl_mult
    
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
    
    
    ### End of calculate monthly aggregates
    
    
  }
closeAllConnections()

state_files = list.files("input/RMS/3_state")
state_ec = get(load("input/RMS/3_state/state_7467_2013.RData"))
state_cig = get(load("input/RMS/3_state/state_7460_2013.RData"))

state_files = state_files[!(state_files %in% c("state_7467_2013.RData", "state_7460_2013.RData", "state_cig.RData", "state_ec.RData"))]
for(f in state_files){
  temp = get(load(file.path("input/RMS/3_state", f)))
  if(grepl(ecig_codes, f)){
    state_ec = bind_rows(state_ec, temp)
  } else{
    state_cig = bind_rows(state_cig, temp)
  }
  
}

state_cig = state_cig %>% arrange(fips_state_code, year, year_month)

state_ec = state_ec %>% arrange(fips_state_code, year, year_month)

save(state_cig, file = "input/RMS/3_state/state_cig.RData")
save(state_ec, file = "input/RMS/3_state/state_ec.RData")

setwd(mydir)
## Clean the tax stuff
load("input/prod_attr/taxes/cig_tax_cdc.RData")
cig_tax$year_month = substr(as.character(cig_tax$year_month), 1, 7)
state_ec$alt = "ecigarette"
ec_tax = state_ec %>% select(year_month, tau_per_hom_ct_real, alt, fips_state_code) %>% distinct()
ec_tax = ec_tax %>% rename(tau_per_ct_real = tau_per_hom_ct_real)
ec_tax$fips_state_code = as.numeric(ec_tax$fips_state_code)

cig_tax = cig_tax %>% rename(tau_per_ct_real = real_tau)

neither_tax = expand.grid(year_month = sort(unique(ec_tax$year_month)),
                          tau_per_ct_real = 0,
                          alt = "neither",
                          fips_state_code = sort(unique(ec_tax$fips_state_code)))

# combine into one data frame to be merged in
all_tax = cig_tax %>% bind_rows(ec_tax) %>% bind_rows(neither_tax)

# join to store_state_descr
state_mapping = read.csv("raw/Misc/StateCodeMapping.csv")

all_tax = all_tax %>% left_join(state_mapping , by = c("fips_state_code" = "Fips_State_Cd"))
all_tax = all_tax %>% rename(store_state_descr = fips_state_descr)
all_tax$fips_state_code = NULL
# notice that this data set is missing some obs for e-cig tax. That is because
# it is not represented in the RMS data: AK, HI, DE, and DC
write.csv(all_tax, file = "input/prod_attr/taxes/all_tax_for_stata.csv", row.names = F)
