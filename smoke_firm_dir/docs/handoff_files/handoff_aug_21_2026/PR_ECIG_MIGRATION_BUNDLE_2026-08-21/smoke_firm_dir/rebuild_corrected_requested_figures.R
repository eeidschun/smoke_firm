## Rebuild the requested decomposition/concentration figures from the
## corrected-nicotine T2 panel.
## This intentionally leaves the canonical panel and unrelated outputs untouched.
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

firm_dir <- "pr"
out_dir <- file.path(firm_dir, "output", "prelim_analysis", "p_and_n_decomp_t2")
load(file.path(firm_dir, "input", "bt_month_t2_niccorr_from_full.RData"))
bt <- bt_month_t2

agg <- function(df, groups) {
  df %>%
    group_by(across(all_of(groups))) %>%
    summarise(
      units = sum(units_sum), mL_sum = sum(mL_sum),
      revenue_real = sum(revenue_real), nic_mg_sum = sum(nic_mg_sum),
      mL_sq = sum(mL_sq_times_unit_sum), .groups = "drop"
    ) %>%
    mutate(
      price_per_mL = revenue_real / mL_sum,
      nic_mg_per_mL = nic_mg_sum / mL_sum,
      avg_mL_per_ecig = mL_sq / mL_sum,
      P_hom = price_per_mL * avg_mL_per_ecig,
      N_hom = nic_mg_per_mL * avg_mL_per_ecig
    )
}

save_plot <- function(p, name, w = 11, h = 6.5, dpi = 200) {
  ggsave(file.path(out_dir, paste0(name, ".png")), p, width = w, height = h, dpi = dpi)
}

## National monthly panels by T2 type.
mser <- agg(bt, c("year_month", "type")) %>%
  mutate(month = as.Date(paste0(year_month, "-01")))
mser_all <- agg(bt, "year_month") %>%
  mutate(month = as.Date(paste0(year_month, "-01")), type = "ALL (pooled)")
mser_long <- bind_rows(mser, mser_all) %>%
  transmute(month, type, price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom) %>%
  pivot_longer(c(price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom),
               names_to = "series", values_to = "value") %>%
  mutate(
    series = factor(series, levels = c("price_per_mL", "avg_mL_per_ecig", "P_hom",
                                       "nic_mg_per_mL", "N_hom")),
    type = factor(type, levels = c("Closed pod", "Disposable", "Open refill", "ALL (pooled)"))
  )
natl_type_cols <- c("Closed pod" = "#3b528b", "Disposable" = "#21908c",
                    "Open refill" = "#5ec962", "ALL (pooled)" = "#e31a1c")

save_plot(
  ggplot(mser_long, aes(month, value, color = type,
                        linewidth = type == "ALL (pooled)",
                        linetype = type == "ALL (pooled)")) +
    geom_line() +
    facet_wrap(~series, scales = "free_y") +
    scale_color_manual(values = natl_type_cols) +
    scale_linewidth_manual(values = c(`FALSE` = 0.9, `TRUE` = 0.9), guide = "none") +
    scale_linetype_manual(values = c(`FALSE` = "solid", `TRUE` = "22"), guide = "none") +
    labs(title = "National monthly e-cig series, broken out by T2 type (pooled = dashed red)",
         x = NULL, y = NULL, color = NULL) +
    theme(legend.position = "bottom"),
  "national_monthly_series_by_type"
)

mser_pd_pool <- agg(bt %>% filter(type != "Open refill"), "year_month") %>%
  mutate(month = as.Date(paste0(year_month, "-01")), type = "Pooled (pod + disposable)")
mser_noopen_long <- bind_rows(
  mser %>% filter(type %in% c("Closed pod", "Disposable")),
  mser_pd_pool
) %>%
  transmute(month, type, price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom) %>%
  pivot_longer(c(price_per_mL, avg_mL_per_ecig, P_hom, nic_mg_per_mL, N_hom),
               names_to = "series", values_to = "value") %>%
  mutate(
    series = factor(series, levels = c("price_per_mL", "avg_mL_per_ecig", "P_hom",
                                       "nic_mg_per_mL", "N_hom")),
    type = factor(type, levels = c("Closed pod", "Disposable", "Pooled (pod + disposable)"))
  )

save_plot(
  ggplot(mser_noopen_long,
         aes(month, value, color = type,
             linewidth = type == "Pooled (pod + disposable)",
             linetype = type == "Pooled (pod + disposable)")) +
    geom_line() +
    facet_wrap(~series, scales = "free_y") +
    scale_color_manual(values = c("Closed pod" = "#3b528b", "Disposable" = "#21908c",
                                  "Pooled (pod + disposable)" = "#e31a1c")) +
    scale_linewidth_manual(values = c(`FALSE` = 0.9, `TRUE` = 0.9), guide = "none") +
    scale_linetype_manual(values = c(`FALSE` = "solid", `TRUE` = "22"), guide = "none") +
    labs(title = paste0("National monthly e-cig series - Closed pod & Disposable ",
                        "(Open refill fully excluded; pooled = dashed red)"),
         x = NULL, y = NULL, color = NULL) +
    theme(legend.position = "bottom"),
  "national_monthly_series_by_type_no_open"
)

## Monthly mL-weighted brand HHI.
brand_mo <- bt %>%
  group_by(month, brand) %>%
  summarise(mL = sum(mL_sum), .groups = "drop_last") %>%
  mutate(share = mL / sum(mL)) %>%
  ungroup()
hhi_mo <- brand_mo %>%
  group_by(month) %>%
  summarise(HHI_all = sum((100 * share)^2), .groups = "drop")
hhi_known <- brand_mo %>%
  filter(brand != "UNKNOWN") %>%
  group_by(month) %>%
  mutate(share_k = mL / sum(mL)) %>%
  summarise(HHI_known = sum((100 * share_k)^2), .groups = "drop")
hhi_long <- hhi_mo %>%
  left_join(hhi_known, by = "month") %>%
  pivot_longer(c(HHI_all, HHI_known), names_to = "series", values_to = "HHI") %>%
  mutate(series = recode(series,
                         HHI_all = "All brands (UNKNOWN as one)",
                         HHI_known = "Identified brands only"))

save_plot(
  ggplot(hhi_long, aes(month, HHI, color = series)) +
    geom_hline(yintercept = c(1500, 2500), linetype = "dashed",
               color = "grey55", linewidth = 0.4) +
    annotate("text", x = min(hhi_mo$month), y = 1560, hjust = 0, size = 3,
             color = "grey40", label = "DOJ: moderately concentrated (1500)") +
    annotate("text", x = min(hhi_mo$month), y = 2560, hjust = 0, size = 3,
             color = "grey40", label = "DOJ: highly concentrated (2500)") +
    geom_line(linewidth = 1) +
    scale_color_manual(values = c("All brands (UNKNOWN as one)" = "#1f78b4",
                                  "Identified brands only" = "#e31a1c")) +
    labs(title = "National e-cigarette market concentration (HHI, mL-weighted)",
         subtitle = "Monthly Herfindahl index of brand mL shares, 0-10,000 scale",
         y = "HHI", x = NULL, color = NULL) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom"),
  "hhi_over_time", w = 9, h = 5.5
)

## Annual mL-weighted brand composition.
brand_yr <- bt %>%
  mutate(year = year(month)) %>%
  group_by(year, brand) %>%
  summarise(mL = sum(mL_sum), .groups = "drop_last") %>%
  mutate(share = mL / sum(mL)) %>%
  arrange(year, desc(share)) %>%
  ungroup()

top_n <- 5
comp <- brand_yr %>% group_by(year) %>% mutate(rank = row_number()) %>% ungroup()
top_seg <- comp %>% filter(rank <= top_n) %>%
  transmute(year, brand, share, is_leader = rank == 1)
other_seg <- comp %>% filter(rank > top_n) %>% group_by(year) %>%
  summarise(brand = "Other", share = sum(share), is_leader = FALSE, .groups = "drop")
comp_plot <- bind_rows(top_seg, other_seg)
brand_levels <- comp_plot %>% filter(brand != "Other") %>% group_by(brand) %>%
  summarise(tot = sum(share), .groups = "drop") %>% arrange(desc(tot)) %>% pull(brand)
comp_plot <- comp_plot %>% mutate(brand = factor(brand, levels = c(brand_levels, "Other")))
pal <- setNames(scales::hue_pal()(length(brand_levels)), brand_levels)
pal["Other"] <- "grey80"
comp_plot <- comp_plot %>%
  mutate(lab = ifelse(share >= 0.05,
                      paste0(ifelse(is_leader, "★ ", ""),
                             str_wrap(as.character(brand), width = 9), "\n",
                             round(100 * share), "%"), ""))

save_plot(
  ggplot(comp_plot, aes(factor(year), share, fill = brand)) +
    geom_col(width = 0.8, color = "white", linewidth = 0.3) +
    geom_text(aes(label = lab), position = position_stack(vjust = 0.5),
              size = 2.7, lineheight = 0.9) +
    scale_fill_manual(values = pal) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(title = "Annual e-cigarette brand composition (mL-weighted)",
         subtitle = "Top-5 brands per year shown individually; ★ = market leader (CR1). Rest = \"Other\".",
         y = "Share of national mL", x = NULL, fill = "Brand") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "right"),
  "concentration_by_year"
)

cat("Rebuilt requested figures, including HHI, from bt_month_t2_niccorr_from_full.RData\n")
