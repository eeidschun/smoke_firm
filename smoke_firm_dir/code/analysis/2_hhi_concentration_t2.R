## Market-concentration summary stats for the homogeneous e-cig supply-side note.
## National, mL-weighted (to match the demand object P_hom / N_hom).
## Outputs: monthly HHI figure, annual concentration table + figure.
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

source("smoke_firm_dir/code/fxns/1_paths.R")
output_dir <- file.path(PRELIM_DIR, "p_and_n_decomp_t2")
load(file.path(SUPPORT_DIR, "bt_month_t2_niccorr_from_full.RData"))  # bt_month_t2
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
                      paste0(str_wrap(as.character(brand), width = 9), "\n",
                             round(100 * share), "%"),
                      ""))

## The unicode star (U+2605) failed to render via geom_text() when typed as a
## literal character straight into this file (a source-encoding issue, not a
## missing font glyph -- it renders fine both in theme text and in geom_text()
## once specified as the "★" escape instead, tested separately). Placed
## INSIDE the leader's own bar segment, not floating above the bar --
## position_stack() can't be trusted for a layer holding only the leader's
## row (it needs every segment present in that x-group to compute the right
## cumulative offset), so the stacking is replicated by hand here to get each
## segment's true [ymin, ymax] and center the star a bit above its label so
## the two don't overlap. position_stack()'s default puts the FIRST factor
## level at the TOP of the bar (last level, "Other", at the bottom) --
## descending factor-level order from the bottom up, not ascending.
stack_pos <- comp_plot %>%
  arrange(year, desc(as.integer(brand))) %>%
  group_by(year) %>%
  mutate(ymax = cumsum(share), ymin = ymax - share, ymid = (ymin + ymax) / 2) %>%
  ungroup()
leader_pos <- stack_pos %>% filter(is_leader) %>%
  mutate(y_star = pmin(ymax - 0.01, ymid + 0.3 * share))

save_plot(
  ggplot(comp_plot, aes(factor(year), share, fill = brand)) +
    geom_col(width = 0.8, color = "white", linewidth = 0.3) +
    geom_text(aes(label = lab), position = position_stack(vjust = 0.5),
              size = 2.7, lineheight = 0.9) +
    geom_text(data = leader_pos, aes(x = factor(year), y = y_star), label = "★",
              size = 5, color = "black", inherit.aes = FALSE) +
    scale_fill_manual(values = pal) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(title = "Annual e-cigarette brand composition (mL-weighted)",
         subtitle = "Top-5 brands per year shown individually; ★ = market leader.",
         y = "Share of national mL", x = NULL, fill = "Brand") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "right"),
  "concentration_by_year", w = 11, h = 6.5
)

cat("\nWrote: hhi_over_time.png, concentration_by_year.png,",
    "hhi_monthly.csv, brand_concentration_by_year.csv\n")

## ---- monthly version of concentration_by_year.png --------------------------
## Same top-5 (re-ranked fresh each period, like the annual chart re-ranks each
## year) + "Other" design as the annual bar chart, at monthly cadence. Bars,
## not area -- easier to read a specific month off than a stacked area. No
## per-segment text (132 months x up to 6 labels would be illegible like the
## annual chart's); instead just the leader's name is printed above each bar.
comp_mo <- brand_mo %>%
  group_by(month) %>%
  arrange(month, desc(share)) %>%
  mutate(rank = row_number()) %>%
  ungroup()

top_seg_mo <- comp_mo %>%
  filter(rank <= TOPN) %>%
  transmute(month, brand, share)

other_seg_mo <- comp_mo %>%
  filter(rank > TOPN) %>%
  group_by(month) %>%
  summarise(brand = "Other", share = sum(share), .groups = "drop")

comp_plot_mo <- bind_rows(top_seg_mo, other_seg_mo)
write_csv(comp_plot_mo %>% arrange(month, desc(share)),
          file.path(output_dir, "brand_concentration_by_month.csv"))

brand_levels_mo <- comp_plot_mo %>%
  filter(brand != "Other") %>%
  group_by(brand) %>% summarise(tot = sum(share), .groups = "drop") %>%
  arrange(desc(tot)) %>% pull(brand)
comp_plot_mo <- comp_plot_mo %>%
  mutate(brand = factor(brand, levels = c(brand_levels_mo, "Other")))

pal_mo <- setNames(scales::hue_pal()(length(brand_levels_mo)), brand_levels_mo)
pal_mo["Other"] <- "grey80"

## Label only where the leader actually changes month-to-month -- the leader
## typically holds for a multi-year stretch, so labeling every month just
## repeats the same name dozens of times in a row and is unreadable.
leader_mo <- comp_mo %>% filter(rank == 1) %>%
  arrange(month) %>%
  mutate(is_new = brand != lag(brand) | row_number() == 1) %>%
  filter(is_new) %>%
  transmute(month, lab = as.character(brand))

save_plot(
  ggplot(comp_plot_mo, aes(month, share, fill = brand)) +
    geom_col(position = "stack", width = 26, color = NA) +
    geom_vline(data = leader_mo, aes(xintercept = month), inherit.aes = FALSE,
               linetype = "dotted", color = "grey40", linewidth = 0.3) +
    geom_text(data = leader_mo, aes(x = month, y = 1.02, label = lab),
              inherit.aes = FALSE, hjust = 0, vjust = 0, angle = 30,
              size = 3, color = "grey15", fontface = "bold") +
    scale_fill_manual(values = pal_mo) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                        expand = expansion(mult = c(0, 0.13))) +
    labs(title = "Monthly e-cigarette brand composition (mL-weighted)",
         subtitle = "Top-5 brands each month (re-ranked monthly, unlike the fixed annual-incumbent roster used for a_it); rest = \"Other\". Name above each bar = that month's leader.",
         y = "Share of national mL", x = NULL, fill = "Brand") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "right"),
  "concentration_by_month", w = 13, h = 6.5
)

cat("Wrote: concentration_by_month.png, brand_concentration_by_month.csv\n")
