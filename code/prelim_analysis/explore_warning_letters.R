setwd("/projectnb/econdept/eidschun/pr/smoke_firm")
library(openxlsx)
library(tidyverse)

df = read.xlsx("raw/fda/warning_letters/warning-letters.xlsx")

df$Response.Letter = NULL
df$Posted.Date= NULL
# fda mislabeled so don't do this
#df_no_auth = df %>% filter(grepl("Marketing Auth", Subject))

library(lubridate)
df$Letter.Issue.Date = as.Date(df$Letter.Issue.Date, format = "%m/%d/%Y")
df$year_month = substr(df$Letter.Issue.Date, 1, 7)

################# PLOT ############
df_by_month = df %>% group_by(year_month) %>% summarise(num_letters = n()) %>% ungroup() %>% arrange(year_month)
df_by_month$year_month = paste0(df_by_month$year_month, "-01")

# create expanded grid
warn_by_month = expand.grid(year= c(2020:2025), month = c(1:12), day = "01")
warn_by_month = warn_by_month %>% mutate(year_month =
                                           paste0(warn_by_month$year, "-", month, "-", day))
warn_by_month$year_month = as.Date(warn_by_month$year_month, format = "%Y-%m-%d")
df_by_month$year_month = as.Date(df_by_month$year_month, format = "%Y-%m-%d")
warn_by_month = warn_by_month %>% left_join(df_by_month, by = c("year_month"))
warn_by_month = warn_by_month %>% mutate(num_letters = ifelse(is.na(num_letters),0,num_letters))
warn_by_month = warn_by_month %>% arrange(year_month)
warn_by_month_today = which(warn_by_month$year_month == "2025-10-01")
warn_by_month = warn_by_month[1:(warn_by_month_today - 1),]
library(ggplot2)

g = ggplot(warn_by_month, aes(x = year_month, y = num_letters)) +
  geom_line() +
  labs(x = "Time (monthly)", y = "Number of warning letters issued") +
  theme(
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18),
    axis.text.x  = element_text(size = 14),
    axis.text.y  = element_text(size = 14)
  )

ggsave(g, file = "output/prelim_analysis/fda/warning_letters_t_series.png")

############# TABLE #######
# how many letters are usually issued per company?
num_per_company = df %>% group_by(Company.Name) %>% summarise(num_letters_per_company = n()) %>% ungroup()
num_letters_per_company = num_per_company %>% group_by(num_letters_per_company) %>% 
  summarise(num_companies = n()) %>% ungroup()
print(xtable(num_letters_per_company), include.rownames = F)
