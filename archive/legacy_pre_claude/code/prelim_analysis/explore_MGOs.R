setwd("/projectnb/econdept/eidschun/pr/smoke_firm")
library(openxlsx)
library(tidyverse)

library(readxl)

# library(tabulizer)
library(dplyr)
library(stringr)

df <- read_excel("raw/fda/MGOs/tobacco_products_search_results.xls")
df$Company[which(df$Company == "R.J. Reynolds Vapor Company")] = "R.J. Reynolds (Vuse)"
# these are all pmtas so drop col
df$`Submission Type - Marketing Authority` = NULL

# don't think we care for env. assessment
df$`Environmental Assessment` = NULL

df$`Associated MRTP` = NULL

# open up the decision letter manually
df$submission_date = c(rep("10/10/2019",3 ),
                       rep("09/04/2020", 7),
                       rep("07/29/2020", 5),
                       rep("03/20/2020", 2),
                       rep("03/10/2020", 2),
                       rep("03/30/2020", 2),
                       rep("04/15/2020", 3),
                       rep("04/02/2020", 3),
                       rep("03/10/2020", 4),
                       rep("08/19/2019", 8))
                       
library(lubridate)                       
df$submission_date = as.Date(df$submission_date, "%m/%d/%Y")                       
df$`Date of Action` = as.Date(df$`Date of Action`, "%m/%d/%y")         

df$time_to_accept = df$`Date of Action` - df$submission_date

df$months_to_accept = as.numeric(df$time_to_accept) / 30

df_clean= df %>% select(Company, Product, months_to_accept)

time_to_accept_df = df_clean %>% group_by(Company) %>% 
  summarise(num_products = n(),
   avg_months_to_accept = round(mean(months_to_accept),1)) %>% ungroup()
avg_df = data.frame(Company = "Total", num_products = sum(time_to_accept_df$num_products),
                    avg_months_to_accept = mean(time_to_accept_df$avg_months_to_accept))
avg_df = bind_rows(time_to_accept_df, avg_df)
library(xtable)
print(xtable(avg_df), include.rownames=FALSE)
