## Tracked RMS sales VOLUME (units/cartridges) for the appendix.
## (1) monthly tracked units by T2 type; (2) monthly units pooled two ways:
## all three types vs pod+disposable only (open refill excluded).
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

source("smoke_firm_dir/code/fxns/1_paths.R")
output_dir <- file.path(PRELIM_DIR, "p_and_n_decomp_t2")
fxn("4_event_lines_t2.R")   # events, event_layers(), event_caption
load(file.path(SUPPORT_DIR, "bt_month_t2_niccorr_from_full.RData"))  # bt_month_t2
df <- bt_month_t2

save_plot <- function(p, name, w = 10, h = 5.5)
  ggplot2::ggsave(file.path(output_dir, paste0(name, ".png")), p,
                  width = w, height = h, dpi = 200)

type_cols <- c("Closed pod" = "#3b528b", "Disposable" = "#21908c",
               "Open refill" = "#5dc963")

## ---- (1) units by type ----
units_type <- df %>%
  group_by(month, type) %>%
  summarise(units_mm = sum(units_sum) / 1e6, .groups = "drop") %>%
  mutate(type = factor(type, levels = names(type_cols)))

save_plot(
  ggplot(units_type, aes(month, units_mm, color = type)) +
    event_layers(ymax = max(units_type$units_mm)) +
    geom_line(linewidth = 0.9) +
    scale_color_manual(values = type_cols) +
    labs(title = "Tracked e-cigarette unit sales by product type (RMS)",
         subtitle = "Monthly units (packages/cartridges as scanned), millions",
         caption = event_caption,
         y = "Units (millions)", x = NULL, color = NULL) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom",
          plot.caption = element_text(hjust = 0, color = "grey30", size = 8)),
  "tracked_units_by_type"
)

## ---- (2) pooled: all three vs pod+disposable ----
pooled_all <- df %>%
  group_by(month) %>% summarise(units_mm = sum(units_sum) / 1e6, .groups = "drop") %>%
  mutate(series = "All three types (pod + disposable + open refill)")
pooled_noopen <- df %>%
  filter(type %in% c("Closed pod", "Disposable")) %>%
  group_by(month) %>% summarise(units_mm = sum(units_sum) / 1e6, .groups = "drop") %>%
  mutate(series = "Pod + disposable only (open refill excluded)")
pooled <- bind_rows(pooled_all, pooled_noopen)

save_plot(
  ggplot(pooled, aes(month, units_mm, color = series)) +
    event_layers(ymax = max(pooled$units_mm)) +
    geom_line(linewidth = 0.9) +
    scale_color_manual(values = c(
      "All three types (pod + disposable + open refill)" = "grey40",
      "Pod + disposable only (open refill excluded)"     = "#21908c")) +
    labs(title = "Tracked e-cigarette unit sales, pooled (RMS)",
         subtitle = "Open refill is a small share of tracked units; the two lines nearly coincide after 2019",
         caption = event_caption,
         y = "Units (millions)", x = NULL, color = NULL) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom",
          plot.caption = element_text(hjust = 0, color = "grey30", size = 8)),
  "tracked_units_pooled"
)

cat("Wrote tracked_units_by_type.png, tracked_units_pooled.png\n")
