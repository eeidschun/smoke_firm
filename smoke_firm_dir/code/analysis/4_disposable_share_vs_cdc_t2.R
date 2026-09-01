## Reproducible source for disposable_share_vs_CDC_benchmark.png.
## RMS series = disposable unit share among (closed pod + disposable) units,
##   i.e. disposable_units / (pod_units + disposable_units), monthly, national.
##   (Open refill is excluded from the denominator.)
## CDC/IRI benchmark points from:
##   Ali FRM, Seidenberg AB, Crane E, et al. E-cigarette Unit Sales by Product
##   and Flavor Type, and Top-Selling Brands, United States, 2020-2022.
##   MMWR Morb Mortal Wkly Rep 2023;72(25):672-677. (IRI retail-scanner data;
##   convenience/gas/grocery/drug/mass/club/dollar/military; EXCLUDES vape
##   shops + online.) Disposable unit share of total: Jan 2020 = 24.7%,
##   Dec 2022 = 51.8%. NB: CDC standardizes 1 unit = 5 cartridges = 1 disposable
##   = 1 e-liquid bottle; this RMS series uses raw package counts (see note).
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

source("smoke_firm_dir/code/fxns/1_paths.R")
output_dir <- file.path(PRELIM_DIR, "p_and_n_decomp_t2")
fxn("4_event_lines_t2.R")   # events, event_layers(), event_caption
load(file.path(SUPPORT_DIR, "bt_month_t2_niccorr_from_full.RData"))  # bt_month_t2
df <- bt_month_t2

rms <- df %>%
  filter(type %in% c("Closed pod", "Disposable")) %>%
  group_by(month, type) %>%
  summarise(u = sum(units_sum), .groups = "drop_last") %>%
  mutate(sh = u / sum(u)) %>%
  filter(type == "Disposable") %>%
  transmute(month, disp_share = 100 * sh) %>%
  ungroup()

cdc <- tibble(
  month = as.Date(c("2020-01-01", "2022-12-01")),
  disp_share = c(24.7, 51.8),
  lab = c("CDC/IRI Jan 2020: 24.7%", "CDC/IRI Dec 2022: 51.8%")
)

write_csv(rms, file.path(output_dir, "rms_disposable_share_monthly.csv"))

save_plot <- function(p, name, w = 10, h = 5.5)
  ggplot2::ggsave(file.path(output_dir, paste0(name, ".png")), p,
                  width = w, height = h, dpi = 200)

save_plot(
  ggplot(rms, aes(month, disp_share)) +
    event_layers(ymax = 60) +
    geom_line(color = "#1b9e91", linewidth = 1) +
    geom_point(data = cdc, color = "#b2182b", size = 4) +
    geom_text(data = cdc, aes(label = lab), color = "#b2182b",
              vjust = -1.1, size = 3.6) +
    annotate("text", x = as.Date("2015-06-01"), y = 43, color = "#1b9e91",
             hjust = 0, size = 3.8,
             label = "RMS (this dataset):\ndisposable % of pod+disposable units") +
    scale_y_continuous(limits = c(0, 62)) +
    labs(title = "Disposable share of e-cigarette unit sales: RMS vs CDC/IRI all-outlet benchmark",
         subtitle = "RMS tracks the same rise but captures only ~30-40% of the all-outlet disposable share",
         caption = event_caption,
         y = "Disposable share of unit sales (%)", x = NULL) +
    theme(plot.caption = element_text(hjust = 0, color = "grey30", size = 8)),
  "disposable_share_vs_CDC_benchmark"
)

cat("Wrote disposable_share_vs_CDC_benchmark.png, rms_disposable_share_monthly.csv\n")
cat("Check anchors:\n")
rms %>% filter(month %in% as.Date(c("2020-01-01","2022-12-01"))) %>% print()
