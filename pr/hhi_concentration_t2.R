## Market-concentration summary stats for the homogeneous e-cig supply-side note.
## National, mL-weighted (to match the demand object P_hom / N_hom).
## Outputs: monthly HHI figure, annual concentration table + figure.
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

output_dir <- file.path("pr", "output", "prelim_analysis", "p_and_n_decomp_t2")
load(file.path("pr", "input", "bt_month_t2_niccorr_from_full.RData"))  # bt_month_t2
df <- bt_month_t2

save_plot <- function(p, name, w = 9, h = 5.5)
  ggplot2::ggsave(file.path(output_dir, paste0(name, ".png")), p,
                  width = w, height = h, dpi = 200)

## ---- national brand x month mL, then shares ----
brand_mo <- df %>%
  group_by(month, brand) %>%
  summarise(mL = sum(mL_sum), .groups = "drop_last") %>%
  mutate(share = mL / sum(mL)) %>%
  ungroup()

## ---- monthly HHI (0-10,000 scale), all brands and excl. UNKNOWN ----
hhi_mo <- brand_mo %>%
  group_by(month) %>%
  summarise(
    HHI_all      = sum((100 * share)^2),
    unknown_share = sum(share[brand == "UNKNOWN"]),
    .groups = "drop"
  )

# HHI among *identified* brands only (UNKNOWN dropped, shares renormalised):
hhi_known <- brand_mo %>%
  filter(brand != "UNKNOWN") %>%
  group_by(month) %>%
  mutate(share_k = mL / sum(mL)) %>%
  summarise(HHI_known = sum((100 * share_k)^2), .groups = "drop")

hhi_mo <- hhi_mo %>% left_join(hhi_known, by = "month")
write_csv(hhi_mo, file.path(output_dir, "hhi_monthly.csv"))

hhi_long <- hhi_mo %>%
  select(month, HHI_all, HHI_known) %>%
  pivot_longer(-month, names_to = "series", values_to = "HHI") %>%
  mutate(series = recode(series,
                         HHI_all   = "All brands (UNKNOWN as one)",
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
  "hhi_over_time"
)

## ---- annual concentration table: leader, CR1/CR3/CR4, HHI ----
brand_yr <- df %>%
  mutate(year = year(month)) %>%
  group_by(year, brand) %>%
  summarise(mL = sum(mL_sum), .groups = "drop_last") %>%
  mutate(share = mL / sum(mL)) %>%
  arrange(year, desc(share)) %>%
  ungroup()

conc_yr <- brand_yr %>%
  group_by(year) %>%
  summarise(
    leader        = brand[1],
    leader_share  = 100 * share[1],
    runner_up     = brand[2],
    CR3           = 100 * sum(share[1:3]),
    CR4           = 100 * sum(share[1:4]),
    HHI           = sum((100 * share)^2),
    unknown_share = 100 * sum(share[brand == "UNKNOWN"]),
    n_brands_pos  = sum(mL > 0),
    .groups = "drop"
  ) %>%
  mutate(across(c(leader_share, CR3, CR4, HHI, unknown_share), ~ round(.x, 1)))

write_csv(conc_yr, file.path(output_dir, "brand_concentration_by_year.csv"))
cat("\n==== Annual concentration (mL-weighted) ====\n")
print(as.data.frame(conc_yr), row.names = FALSE)

## ---- annual brand-composition figure: which brands make up each year ----
## Top-5 brands per year shown individually (leader flagged with a star), the
## remaining brands collapsed into "Other". CR1 = leader segment; CR3 = three
## largest brand segments in each bar.
TOPN <- 5
comp <- brand_yr %>%
  group_by(year) %>%
  mutate(rank = row_number()) %>%              # brand_yr already sorted desc(share)
  ungroup()

top_seg <- comp %>%
  filter(rank <= TOPN) %>%
  transmute(year, brand, share, is_leader = rank == 1)

other_seg <- comp %>%
  filter(rank > TOPN) %>%
  group_by(year) %>%
  summarise(brand = "Other", share = sum(share), is_leader = FALSE, .groups = "drop")

comp_plot <- bind_rows(top_seg, other_seg)

# consistent color per brand across years; "Other" forced to grey
brand_levels <- comp_plot %>%
  filter(brand != "Other") %>%
  group_by(brand) %>% summarise(tot = sum(share), .groups = "drop") %>%
  arrange(desc(tot)) %>% pull(brand)
comp_plot <- comp_plot %>%
  mutate(brand = factor(brand, levels = c(brand_levels, "Other")))

pal <- setNames(scales::hue_pal()(length(brand_levels)), brand_levels)
pal["Other"] <- "grey80"

comp_plot <- comp_plot %>%
  mutate(lab = ifelse(share >= 0.05,
                      paste0(ifelse(is_leader, "★ ", ""),
                             str_wrap(as.character(brand), width = 9), "\n",
                             round(100 * share), "%"),
                      ""))

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
  "concentration_by_year", w = 11, h = 6.5
)

cat("\nWrote: hhi_over_time.png, concentration_by_year.png,",
    "hhi_monthly.csv, brand_concentration_by_year.csv\n")
