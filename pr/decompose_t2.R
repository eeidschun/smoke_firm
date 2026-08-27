## ============================================================================
## Decompose P_hom (price of a homogeneous e-cig) and N_hom (nicotine yield of a
## homogeneous e-cig) on the CORRECTED T2 panel, reported WITHIN each T2 type.
##
##   P_hom = (avg price per mL) * (avg mL per e-cig)
##   N_hom = (avg nic yield per mL) * (avg mL per e-cig)
## with mL-weighted averages; avg_mL_per_ecig = Sigma units*mL^2 / Sigma units*mL.
##
## Why within-type: pooling averages 0.7 mL pods with 10-30 mL open-refill bottles,
## and the mL^2 weighting lets a few big bottles dominate the pooled size metric
## (this is why pooled early-year P_hom spiked). Reporting within Closed pod /
## Disposable / Open refill keeps each firm-decision-homogeneous.
##
## Input : pr/input/bt_month_t2_niccorr_from_full.RData
## Output: pr/output/prelim_analysis/p_and_n_decomp_t2/
## ============================================================================

rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

firm_dir <- "pr"
out_dir  <- file.path(firm_dir, "output", "prelim_analysis", "p_and_n_decomp_t2")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
load(file.path(firm_dir, "input", "bt_month_t2_niccorr_from_full.RData"))  # bt_month_t2

## ---- aggregate cells to any grouping and (re)build ratios ----
agg <- function(df, groups) {
  df %>% group_by(across(all_of(groups))) %>%
    summarise(units = sum(units_sum), mL_sum = sum(mL_sum),
              revenue_real = sum(revenue_real), nic_mg_sum = sum(nic_mg_sum),
              mL_sq = sum(mL_sq_times_unit_sum), .groups = "drop") %>%
    mutate(price_per_mL    = revenue_real / mL_sum,
           nic_mg_per_mL   = nic_mg_sum   / mL_sum,
           avg_mL_per_ecig = mL_sq        / mL_sum,
           P_hom = price_per_mL  * avg_mL_per_ecig,
           N_hom = nic_mg_per_mL * avg_mL_per_ecig)
}
bt <- bt_month_t2 %>% mutate(year = substr(year_month, 1, 4))

## ---- 1. annual series: within each T2 type + pooled (ALL) ----
series <- bind_rows(agg(bt, c("year", "type")),
                    agg(bt, "year") %>% mutate(type = "ALL")) %>%
  arrange(type, year)
write.csv(series %>% transmute(year, type,
            price_per_mL = round(price_per_mL, 2), avg_mL_per_ecig = round(avg_mL_per_ecig, 2),
            nic_mg_per_mL = round(nic_mg_per_mL, 1), P_hom = round(P_hom, 2), N_hom = round(N_hom, 1),
            mL_sum = round(mL_sum), mL_share = NA),
          file.path(out_dir, "annual_series_by_type.csv"), row.names = FALSE)

## mL share by type per year (composition of the market)
share_by_type <- bt %>% group_by(year, type) %>% summarise(mL = sum(mL_sum), .groups = "drop") %>%
  group_by(year) %>% mutate(share = mL / sum(mL)) %>% ungroup()
write.csv(share_by_type %>% transmute(year, type, mL_share = round(share, 4)),
          file.path(out_dir, "mL_share_by_type.csv"), row.names = FALSE)

## ---- 2. channel decomposition of Delta P_hom and Delta N_hom ----
## P_hom = a*b with a = price/mL (or nic/mL for N_hom), b = avg mL/e-cig.
## Delta(a*b) = Delta a * b0  +  a0 * Delta b  +  Delta a * Delta b
decomp_product <- function(a0, a1, b0, b1)
  tibble(intensity_channel = (a1 - a0) * b0,
         size_channel      = a0 * (b1 - b0),
         interaction       = (a1 - a0) * (b1 - b0),
         total             = a1 * b1 - a0 * b0)

channels <- function(base_yr, comp_yr) {
  s <- series %>% filter(year %in% c(base_yr, comp_yr))
  map_dfr(unique(s$type), function(ty) {
    b <- s %>% filter(type == ty, year == base_yr)
    c <- s %>% filter(type == ty, year == comp_yr)
    if (!nrow(b) || !nrow(c)) return(tibble())
    bind_rows(
      decomp_product(b$price_per_mL, c$price_per_mL, b$avg_mL_per_ecig, c$avg_mL_per_ecig) %>%
        mutate(measure = "P_hom", type = ty, v0 = round(b$P_hom,2), v1 = round(c$P_hom,2)),
      decomp_product(b$nic_mg_per_mL, c$nic_mg_per_mL, b$avg_mL_per_ecig, c$avg_mL_per_ecig) %>%
        mutate(measure = "N_hom", type = ty, v0 = round(b$N_hom,1), v1 = round(c$N_hom,1)))
  }) %>%
    mutate(base = base_yr, comp = comp_yr,
           across(c(intensity_channel, size_channel, interaction, total), ~round(.x, 2)))
}

ch_full   <- channels("2013", "2023")   # whole panel
ch_modern <- channels("2018", "2023")   # pod/disposable era (JUUL onward)
write.csv(ch_full,   file.path(out_dir, "channels_2013_2023.csv"), row.names = FALSE)
write.csv(ch_modern, file.path(out_dir, "channels_2018_2023.csv"), row.names = FALSE)

## ---- 3. brand composition WITHIN each type (what drove Delta P_hom_cell) ----
## share-weighted decomposition of a type's national price/mL & nic/mL into
## within-brand vs composition (mL-share shift) vs interaction, 2018 -> 2023.
brand_panel <- bt %>% group_by(year, type, brand) %>%
  summarise(mL_sum = sum(mL_sum), revenue_real = sum(revenue_real),
            nic_mg_sum = sum(nic_mg_sum), mL_sq = sum(mL_sq_times_unit_sum), .groups = "drop") %>%
  mutate(price_per_mL = revenue_real/mL_sum, nic_mg_per_mL = nic_mg_sum/mL_sum,
         avg_mL_per_ecig = mL_sq/mL_sum,
         P_hom_cell = price_per_mL*avg_mL_per_ecig, N_hom_cell = nic_mg_per_mL*avg_mL_per_ecig) %>%
  group_by(year, type) %>% mutate(mL_share = mL_sum/sum(mL_sum)) %>% ungroup()

decomp_shares <- function(df, ty, base_yr, comp_yr, xcol) {
  b <- df %>% filter(type==ty, year==base_yr) %>% select(brand, s0=mL_share, x0=all_of(xcol))
  c <- df %>% filter(type==ty, year==comp_yr) %>% select(brand, s1=mL_share, x1=all_of(xcol))
  full_join(b, c, by="brand") %>% mutate(across(c(s0,s1,x0,x1), ~replace_na(.x,0))) %>%
    transmute(type=ty, brand, within=s0*(x1-x0), composition=(s1-s0)*x0,
              interaction=(s1-s0)*(x1-x0), total=within+composition+interaction)
}
brand_drivers <- map_dfr(c("Closed pod","Disposable","Open refill"), function(ty)
  decomp_shares(brand_panel, ty, "2018", "2023", "P_hom_cell")) %>%
  arrange(type, desc(abs(total)))
write.csv(brand_drivers %>% mutate(across(where(is.numeric), ~round(.x,3))),
          file.path(out_dir, "brand_drivers_P_hom_by_type_2018_2023.csv"), row.names = FALSE)

## ---- 4. plots ----
save_plot <- function(gg, name, w=9, h=5) ggsave(file.path(out_dir, paste0(name,".png")), gg, width=w, height=h)
mser <- bind_rows(agg(bt, c("year_month","type"))) %>% mutate(month=as.Date(paste0(year_month,"-01")))
save_plot(ggplot(mser, aes(month, P_hom, color=type)) + geom_line(linewidth=0.9) +
  labs(title="P_hom (real $ per homogeneous e-cig) within T2 type", x=NULL, y="P_hom ($)"),
  "P_hom_by_type")
save_plot(ggplot(mser, aes(month, N_hom, color=type)) + geom_line(linewidth=0.9) +
  labs(title="N_hom (nicotine yield mg per homogeneous e-cig) within T2 type", x=NULL, y="N_hom (mg)"),
  "N_hom_by_type")
save_plot(ggplot(share_by_type, aes(as.Date(paste0(year,"-01-01")), share, fill=type)) +
  geom_area() + labs(title="mL share by T2 type", x=NULL, y="mL share"), "mL_share_by_type")

## "second version" of national_monthly_series: the same 5 measures faceted, but
## a line per T2 type (+ pooled ALL, dashed grey, for reference) so open-refill
## bursts (e.g. the mid-2019 clearance) stay isolated from the pod/disposable series.
mser_all <- agg(bt, "year_month") %>%
  mutate(month = as.Date(paste0(year_month, "-01")), type = "ALL (pooled)")
mser_long <- bind_rows(mser, mser_all) %>%
  transmute(month, type, price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom) %>%
  pivot_longer(c(price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom),
               names_to = "series", values_to = "value") %>%
  mutate(series = factor(series, levels = c("price_per_mL","avg_mL_per_ecig","P_hom",
                                            "nic_mg_per_mL","N_hom")),
         type   = factor(type, levels = c("Closed pod","Disposable","Open refill","ALL (pooled)")))
natl_type_cols <- c("Closed pod"="#3b528b", "Disposable"="#21908c",
                    "Open refill"="#5ec962", "ALL (pooled)"="#e31a1c")
save_plot(
  ggplot(mser_long, aes(month, value, color = type,
                        linetype = type == "ALL (pooled)")) +
    geom_line(linewidth = 0.9) +
    facet_wrap(~series, scales = "free_y") +
    scale_color_manual(values = natl_type_cols) +
    scale_linetype_manual(values = c(`FALSE`="solid", `TRUE`="22"), guide = "none") +
    labs(title = "National monthly e-cig series, broken out by T2 type (pooled = dashed red)",
         x = NULL, y = NULL, color = NULL) +
    theme(legend.position = "bottom"),
  "national_monthly_series_by_type", w = 11, h = 6.5)

## nicotine-only excerpt of the same series (nic_mg_per_mL and N_hom), for readability
save_plot(
  ggplot(mser_long %>% filter(series %in% c("nic_mg_per_mL","N_hom")),
         aes(month, value, color = type,
             linetype = type == "ALL (pooled)")) +
    geom_line(linewidth = 0.9) +
    facet_wrap(~series, scales = "free_y") +
    scale_color_manual(values = natl_type_cols) +
    scale_linetype_manual(values = c(`FALSE`="solid", `TRUE`="22"), guide = "none") +
    labs(title = "National monthly nicotine series by T2 type (repeated from the full series; pooled = dashed red)",
         x = NULL, y = NULL, color = NULL) +
    theme(legend.position = "bottom"),
  "national_monthly_series_nicotine", w = 11, h = 5)

## same, with Open refill removed. IMPORTANT: the pooled line here is
## Closed pod + Disposable ONLY (open refill fully excluded from the pooling),
## labelled explicitly in the legend.
mser_pd_pool <- agg(bt %>% filter(type != "Open refill"), "year_month") %>%
  mutate(month = as.Date(paste0(year_month, "-01")), type = "Pooled (pod + disposable)")
mser_noopen_long <- bind_rows(mser %>% filter(type %in% c("Closed pod", "Disposable")),
                              mser_pd_pool) %>%
  transmute(month, type, price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom) %>%
  pivot_longer(c(price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom),
               names_to = "series", values_to = "value") %>%
  mutate(series = factor(series, levels = c("price_per_mL","avg_mL_per_ecig","P_hom",
                                            "nic_mg_per_mL","N_hom")),
         type   = factor(type, levels = c("Closed pod","Disposable","Pooled (pod + disposable)")))
save_plot(
  ggplot(mser_noopen_long,
         aes(month, value, color = type,
             linetype  = type == "Pooled (pod + disposable)")) +
    geom_line(linewidth = 0.9) +
    facet_wrap(~series, scales = "free_y") +
    scale_color_manual(values = c("Closed pod"="#3b528b", "Disposable"="#21908c",
                                  "Pooled (pod + disposable)"="#e31a1c")) +
    scale_linetype_manual(values = c(`FALSE`="solid", `TRUE`="22"), guide = "none") +
    labs(title = "National monthly e-cig series - Closed pod & Disposable (Open refill fully excluded; pooled = dashed red)",
         x = NULL, y = NULL, color = NULL) +
    theme(legend.position = "bottom"),
  "national_monthly_series_by_type_no_open", w = 11, h = 6.5)

## ---- console summary ----
cat("=== Annual P_hom / N_hom WITHIN type (and pooled ALL) ===\n")
series %>% transmute(year, type, P_hom=round(P_hom,1), N_hom=round(N_hom,1)) %>%
  pivot_wider(names_from=type, values_from=c(P_hom,N_hom)) %>% as.data.frame() %>% print()
cat("\n=== Delta P_hom / N_hom channels 2013->2023 (intensity=price or nic /mL; size=mL/ecig) ===\n")
print(as.data.frame(ch_full), row.names=FALSE)
cat("\n=== same, 2018->2023 (modern era) ===\n")
print(as.data.frame(ch_modern), row.names=FALSE)
cat("\nWrote tables + plots under", out_dir, "\n")
