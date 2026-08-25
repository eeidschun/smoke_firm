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
library(stringr)
library(bit64) # ADD TO EVERY CODE FOR NIELSEN



mydir =  "/projectnb/econdept/eidschun/pr/smoke_demand"
infl_peg = 2023

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
  
  # p_mL_ec = ggplot(p_check %>% filter(type %in% c("One mL of E-liquid", "One E-cigarette")), aes(x = date))+
  #   geom_line(aes(y = price, color = factor(type))) +
  #   theme(legend.position = "bottom", legend.title = element_blank())  + 
  #   labs(x = "", y = "Price ($)") +
  #   scale_color_manual(values = c('One E-cigarette' = '#5ec962', 'One mL of E-liquid' = '#480882')) +
  #   theme(legend.text=element_text(size=16),
  #         axis.title.y=element_text(size=14),
  #         axis.text.x = element_text(size = 14, hjust = 1, angle = 45),
  #         axis.text.y = element_text(size = 14))
}

# ------------------------------------------------------------
# 1. Function to process one raw RMS year
# ------------------------------------------------------------

process_one_year <- function(rms, out_file = NULL) {
  out <- rms %>%
    mutate(
      month = floor_date(as.Date(week_end), "month"),
      brand = str_to_title(brand_descr_f),
      type = str_to_title(product_type),
      sales = units * price_d_prmult,
      mL_sales = units * liq_total_f
    ) %>%
    filter(
      units > 0,
      price_d_prmult > 0,
      liq_total_f > 0,
      sales > 0,
      mL_sales > 0,
      !is.na(brand),
      !is.na(type)
    ) %>%
    group_by(month, type, brand) %>%
    summarise(
      sales = sum(sales, na.rm = TRUE),
      mL_sales = sum(mL_sales, na.rm = TRUE),
      units = sum(units, na.rm = TRUE),
      n_upcs = n_distinct(upc),
      n_stores = n_distinct(store_code_uc),
      .groups = "drop"
    ) %>%
    mutate(price_per_mL = sales / mL_sales)
  
  if (!is.null(out_file)) {
    write_csv(out, out_file)
  }
  
  out
}

setwd("input/RMS/1_initial/")

files <- list.files(pattern = "\\.RData$")

years <- as.integer(stringr::str_extract(files, "20\\d{2}"))

files <- files[order(years)]
years <- sort(years)

bt_list <- vector("list", length(files))

for(i in seq_along(files)) {
  
  cat("Processing", years[i], "\n")
  
  load(files[i])
  
  process_one_year(
    rms,
    paste0("bt_", years[i], ".csv")
  )
  
  rm(rms)
  gc()
}

bt_month <- list.files(
  pattern = "^bt_[0-9]{4}\\.csv$"
) %>%
  purrr::map_dfr(readr::read_csv)

save(bt_month, file = "../../../../smoke_firm/input/bt_month.RData")

bt_month <- bt_month %>%
  group_by(month) %>%
  mutate(
    mL_share = mL_sales / sum(mL_sales, na.rm = TRUE),
    sales_share = sales / sum(sales, na.rm = TRUE)
  ) %>%
  ungroup()

national_price <- bt_month %>%
  mutate(
    avg_mL_per_ecig_cell = mL_sales / units
  ) %>%
  group_by(month) %>%
  summarise(
    
    # your existing series
    price_per_mL =
      weighted.mean(price_per_mL,
                    w = mL_sales,
                    na.rm = TRUE),
    
    # average product size
    avg_mL_per_ecig =
      weighted.mean(avg_mL_per_ecig_cell,
                    w = mL_sales,
                    na.rm = TRUE),
    
    # homogeneous e-cigarette price
    price_per_hom_ecig =
      price_per_mL * avg_mL_per_ecig,
    
    total_sales = sum(sales, na.rm = TRUE),
    total_mL = sum(mL_sales, na.rm = TRUE),
    
    .groups = "drop"
  )




decomp_two_months <- function(df, base_month, comp_month) {
  # mL_share is the type-brand's mL sales as a share of total sales in the month
  base <- df %>%
    filter(month == base_month) %>%
    select(type, brand, s0 = mL_share, p0 = price_per_mL)
  
  comp <- df %>%
    filter(month == comp_month) %>%
    select(type, brand, s1 = mL_share, p1 = price_per_mL)
  
  full_join(base, comp, by = c("type", "brand")) %>%
    mutate(
      s0 = replace_na(s0, 0),
      s1 = replace_na(s1, 0),
      p0 = replace_na(p0, 0),
      p1 = replace_na(p1, 0),
      
      within_price = s0 * (p1 - p0), # how much would agg. price have changed if market shares stayed fixed?
      composition = (s1 - s0) * p0, # did consumers shift toward epxensive or cheap products?
      interaction = (s1 - s0) * (p1 - p0), # did market share changes and price changes occur simultaneously
      total_contribution = within_price + composition + interaction,
      
      base_month = base_month,
      comp_month = comp_month
    )
}

months <- sort(unique(bt_month$month))

# Plot: for each month, change in price is decomposed into: within + composition + interaction
monthly_decomp <- map_dfr(
  2:length(months),
  function(i) {
    
    temp <- decomp_two_months(
      bt_month,
      base_month = months[i - 1],
      comp_month = months[i]
    )
    
    temp %>%
      summarise(
        month = months[i],
        within_price = sum(within_price, na.rm = TRUE),
        composition = sum(composition, na.rm = TRUE),
        interaction = sum(interaction, na.rm = TRUE),
        total_change = sum(total_contribution, na.rm = TRUE),
        .groups = "drop"
      )
  }
)

monthly_decomp %>%
  pivot_longer(
    cols = c(within_price, composition, interaction),
    names_to = "component",
    values_to = "change"
  ) %>%
  ggplot(aes(month, change, fill = component)) +
  geom_col() +
  geom_line(
    data = monthly_decomp,
    aes(month, total_change),
    inherit.aes = FALSE,
    linewidth = 1
  ) +
  labs(
    x = NULL,
    y = "Monthly change in price per mL",
    fill = "Component",
    title = "Month-to-month decomposition of e-cigarette price changes"
  )

base_month <- as.Date(min(bt_month$month))

# every month is compared to january 2013:asks why is price different from 2013?
fixed_base_decomp <- map_dfr(
  months[months > base_month],
  function(m) {
    
    temp <- decomp_two_months(
      bt_month,
      base_month = base_month,
      comp_month = m
    )
    
    temp %>%
      summarise(
        month = m,
        within_price = sum(within_price, na.rm = TRUE),
        composition = sum(composition, na.rm = TRUE),
        interaction = sum(interaction, na.rm = TRUE),
        total_change = sum(total_contribution, na.rm = TRUE),
        .groups = "drop"
      )
  }
)

fixed_base_decomp %>%
  pivot_longer(
    cols = c(within_price, composition, interaction),
    names_to = "component",
    values_to = "change"
  ) %>%
  ggplot(aes(month, change, fill = component)) +
  geom_col() +
  geom_line(
    data = fixed_base_decomp,
    aes(month, total_change),
    inherit.aes = FALSE,
    linewidth = 1
  ) +
  labs(
    x = NULL,
    y = "Change in price per mL since Jan 2013",
    fill = "Component",
    title = "Fixed-base decomposition of e-cigarette price changes"
  )

fixed_base_decomp %>%
  pivot_longer(
    cols = c(within_price, composition, interaction),
    names_to = "component",
    values_to = "change"
  ) %>%
  ggplot(aes(month, change, fill = component)) +
  geom_col() +
  geom_line(
    data = fixed_base_decomp,
    aes(month, total_change),
    inherit.aes = FALSE,
    linewidth = 1
  ) +
  labs(
    x = NULL,
    y = "Change in price per mL since Jan 2013",
    fill = "Component",
    title = "Fixed-base decomposition of e-cigarette price changes"
  )

drivers_2013_2023 <- decomp_two_months(
  bt_month,
  base_month = as.Date("2013-01-01"),
  comp_month = as.Date("2023-12-01")
)

drivers_2013_2023 %>%
  arrange(desc(abs(total_contribution))) %>%
  select(
    type, brand,
    s0, s1,
    p0, p1,
    within_price,
    composition,
    interaction,
    total_contribution
  ) %>%
  head(30)

type_month <- bt_month %>%
  group_by(month, type) %>%
  summarise(
    sales = sum(sales, na.rm = TRUE),
    mL_sales = sum(mL_sales, na.rm = TRUE),
    price_per_mL = sales / mL_sales,
    .groups = "drop"
  ) %>%
  group_by(month) %>%
  mutate(mL_share = mL_sales / sum(mL_sales, na.rm = TRUE)) %>%
  ungroup()

type_month_plot = ggplot(data =type_month, aes(month, mL_share, color = type)) + geom_line()

ggsave(type_month_plot, file = file.path(firm_dir, "output", "prelim_analysis", "p_and_n_decomp", "prodtype_plot_ai.png"))


decomp_two_months_type <- function(df, base_month, comp_month) {
  
  base <- df %>%
    filter(month == base_month) %>%
    select(type, s0 = mL_share, p0 = price_per_mL)
  
  comp <- df %>%
    filter(month == comp_month) %>%
    select(type, s1 = mL_share, p1 = price_per_mL)
  
  full_join(base, comp, by = "type") %>%
    mutate(
      s0 = replace_na(s0, 0),
      s1 = replace_na(s1, 0),
      p0 = replace_na(p0, 0),
      p1 = replace_na(p1, 0),
      
      within_price = s0 * (p1 - p0),
      composition = (s1 - s0) * p0,
      interaction = (s1 - s0) * (p1 - p0),
      total_contribution = within_price + composition + interaction
    )
}

type_fixed_base_decomp <- map_dfr(
  months[months > base_month],
  function(m) {
    
    temp <- decomp_two_months_type(
      type_month,
      base_month = base_month,
      comp_month = m
    )
    
    temp %>%
      summarise(
        month = m,
        within_price = sum(within_price, na.rm = TRUE),
        composition = sum(composition, na.rm = TRUE),
        interaction = sum(interaction, na.rm = TRUE),
        total_change = sum(total_contribution, na.rm = TRUE),
        .groups = "drop"
      )
  }
)

brand_month <- bt_month %>%
  group_by(month, brand) %>%
  summarise(
    sales = sum(sales, na.rm = TRUE),
    mL_sales = sum(mL_sales, na.rm = TRUE),
    price_per_mL = sales / mL_sales,
    .groups = "drop"
  ) %>%
  group_by(month) %>%
  mutate(mL_share = mL_sales / sum(mL_sales, na.rm = TRUE)) %>%
  ungroup()

brand_type_month <- bt_month %>%
  group_by(month, brand, type) %>%
  summarise(
    sales = sum(sales, na.rm = TRUE),
    mL_sales = sum(mL_sales, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(month) %>%
  mutate(
    mL_share = mL_sales / sum(mL_sales, na.rm = TRUE)
  ) %>%
  group_by(month, brand) %>%
  mutate(
    within_brand_share = mL_sales / sum(mL_sales, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(
    era = case_when(
      month < as.Date("2016-01-01") ~ "2013-2015",
      month < as.Date("2020-01-01") ~ "2016-2019",
      TRUE ~ "2020-2023"
    )
  )

top_brands_by_era <- brand_type_month %>%
  group_by(era, brand) %>%
  summarise(total_mL = sum(mL_sales, na.rm = TRUE), .groups = "drop") %>%
  group_by(era) %>%
  slice_max(total_mL, n = 5) %>%
  ungroup()

plot_df <- brand_type_month %>%
  semi_join(top_brands_by_era, by = c("era", "brand"))

brand_competition <- brand_month %>%
  group_by(month) %>%
  summarise(
    hhi = sum(mL_share^2, na.rm = TRUE),
    n_brands = n_distinct(brand),
    top1_share = max(mL_share, na.rm = TRUE),
    top5_share = sum(sort(mL_share, decreasing = TRUE)[1:min(5, n())]),
    .groups = "drop"
  )

# shows HHI over time
# 2013: 0.45 is highly concentrated
# 2014 -  early 2018 : lots of entry
# Late 2018 - 2019 few brands

ggplot(brand_competition, aes(month, hhi)) +
  geom_line(linewidth = 1) +
  labs(
    x = NULL,
    y = "Brand HHI",
    title = "Brand concentration in e-cigarette market"
  )

price_competition <- national_price %>%
  left_join(brand_competition, by = "month")

lm_comp <- lm(
  log(price_per_mL) ~ hhi + n_brands + factor(year(month)),
  data = price_competition
)

lm_comp_summ = summary(lm_comp)

write.csv(
  lm_comp_summ,
  file = file.path(
    firm_dir,
    "output",
    "prelim_analysis",
    "p_and_n_decomp",
    "lm_comp_summ_ai.csv"
  )
)


plot_df <- national_price %>%
  select(
    month,
    price_per_mL,
    avg_mL_per_ecig,
    price_per_hom_ecig
  ) %>%
  pivot_longer(
    -month,
    names_to = "series",
    values_to = "value"
  )

plot_gg = ggplot(plot_df,
                 aes(month, value, color = series)) +
  geom_line(linewidth = 1)


ggsave(plot_gg, file = file.path(firm_dir, "output", "prelim_analysis", "p_and_n_decomp", "ntnl_prices_plot_ai.png"))

compare <- national_price %>%
  left_join(brand_competition, by = "month") %>%
  mutate(
    price_index = 100 * price_per_mL / first(price_per_mL),
    hhi_index = 100 * hhi / first(hhi)
  ) %>%
  select(month, price_index, hhi_index) %>%
  pivot_longer(-month,
               names_to = "series",
               values_to = "index")

plot_compare= ggplot(compare,
       aes(month, index, color = series)) +
  geom_line(linewidth = 1.2) +
  labs(y = "Jan 2013 = 100",
       x = NULL,
       color = "")

ggsave(plot_compare, file = file.path(firm_dir, "output", "prelim_analysis", "p_and_n_decomp", "ntnl_prices_plot_and_hhi_ai.png"))

top5 <- brand_month %>%
  group_by(brand) %>%
  summarise(total_ml = sum(mL_sales), .groups = "drop") %>%
  slice_max(total_ml, n = 5)

top5_brands_plot = brand_month %>%
  filter(brand %in% top5$brand) %>%
  ggplot(aes(month, mL_share, color = brand)) +
  geom_line(linewidth = 1)

ggsave(top5_brands_plot, file = file.path(firm_dir, "output", "prelim_analysis", "p_and_n_decomp", "top5_brands_ai.png"))

brand_type_month <- brand_type_month %>%
  mutate(
    era = case_when(
      month < as.Date("2016-01-01") ~ "2013-2015",
      month < as.Date("2020-01-01") ~ "2016-2019",
      TRUE ~ "2020-2023"
    )
  )

top_brands_by_era <- brand_type_month %>%
  group_by(era, brand) %>%
  summarise(total_mL = sum(mL_sales, na.rm = TRUE), .groups = "drop") %>%
  group_by(era) %>%
  slice_max(total_mL, n = 5) %>%
  ungroup()

plot_df <- brand_type_month %>%
  semi_join(top_brands_by_era, by = c("era", "brand")) %>%
  mutate(
    brand_type = paste(brand, type, sep = " - ")
  )

facet_types_per_major_brand <- plot_df %>%
  ggplot(aes(month, within_brand_share, color = type)) +
  geom_line(linewidth = .5) +
  facet_wrap(~ brand) +
  labs(
    x = NULL,
    y = "Share within brand",
    color = "Product type",
    title = "Product-type composition within major brands"
  )

ggsave(
  facet_types_per_major_brand,
  file = file.path(
    firm_dir,
    "output",
    "prelim_analysis",
    "p_and_n_decomp",
    "types_within_brand_ai.png"
  )
)

drivers_2013_2023 = drivers_2013_2023 %>%
  group_by(brand, type) %>%
  summarise(
    within = sum(within_price),
    composition = sum(composition),
    interaction = sum(interaction),
    total = sum(total_contribution),
    .groups = "drop"
  ) %>%
  arrange(desc(abs(total)))

write.csv(
  drivers_2013_2023,
  file = file.path(
    firm_dir,
    "output",
    "prelim_analysis",
    "p_and_n_decomp",
    "drivers_2013_2023_tbl_ai.csv"
  )
)

highest_and_lowest_price_brands = brand_month %>%
  group_by(brand) %>%
  summarise(
    avg_price = weighted.mean(price_per_mL,
                              w = mL_sales),
    total_ml = sum(mL_sales),
    .groups = "drop"
  ) %>%
  arrange(desc(total_ml))

write.csv(
  highest_and_lowest_price_brands,
  file = file.path(
    firm_dir,
    "output",
    "prelim_analysis",
    "p_and_n_decomp",
    "highest_and_lowest_price_brands_tbl_ai.csv"
  )
)

# price per mL per major brand
brand_price <- bt_month %>%
  group_by(month, brand) %>%
  summarise(
    price_per_mL = sum(sales) / sum(mL_sales),
    mL_sales = sum(mL_sales),
    .groups = "drop"
  )

top5 <- brand_price %>%
  group_by(brand) %>%
  summarise(total_ml = sum(mL_sales), .groups = "drop") %>%
  slice_max(total_ml, n = 5)

p_per_mL_per_major_brand = ggplot(
  brand_price %>% filter(brand %in% top5$brand),
  aes(month, price_per_mL, color = brand)
) +
  geom_line()

ggsave(
  p_per_mL_per_major_brand ,
  file = file.path(
    firm_dir,
    "output",
    "prelim_analysis",
    "p_and_n_decomp",
    "p_per_mL_per_brand_ai.png"
  )
)

monthly_decomp
fixed_base_decomp

write.csv(
 monthly_decomp,
  file = file.path(
    firm_dir,
    "output",
    "prelim_analysis",
    "p_and_n_decomp",
    "monthly_decomp_tbl_ai.csv"
  )
)


write.csv(
  fixed_base_decomp,
  file = file.path(
    firm_dir,
    "output",
    "prelim_analysis",
    "p_and_n_decomp",
    "fixed_base_decomp_tbl_ai.csv"
  )
)




drivers_2013_2023