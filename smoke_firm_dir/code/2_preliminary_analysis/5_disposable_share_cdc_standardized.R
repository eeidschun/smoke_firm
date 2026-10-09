## CDC-comparability DIAGNOSTIC (not a model input): recompute the RMS disposable
## unit share using CDC/IRI's standardized unit definition
##   1 unit = 5 prefilled cartridges = 1 disposable device = 1 e-liquid bottle
## (Ali et al., MMWR 2023;72(25):672-677), to see how much of the RMS-vs-CDC
## level gap is the unit definition vs. genuine channel undercoverage.
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })
source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(PRELIM_DIR, "p_and_n_decomp_t2")
fxn("4_event_lines_t2.R")   # events, event_layers(), event_caption
cc <- read_csv(file.path(out_dir, "cart_counts_by_type_month.csv"), show_col_types = FALSE) %>%
  mutate(month = as.Date(paste0(year_month, "-01")))

wide <- cc %>%
  select(month, type, units_sum, cart_sum) %>%
  pivot_wider(names_from = type, values_from = c(units_sum, cart_sum), values_fill = 0)

d <- wide %>% transmute(
  month,
  pod_std  = `cart_sum_Closed pod` / 5,       # 5 cartridges = 1 unit
  disp_std = `units_sum_Disposable`,          # 1 device = 1 unit
  open_std = `units_sum_Open refill`,         # 1 bottle = 1 unit
  pod_pkg  = `units_sum_Closed pod`,
  # (a) raw package counts, disp/(pod+disp) -- the original figure's definition
  rms_raw       = 100 * disp_std / (pod_pkg + disp_std),
  # (b) CDC-standardized, incl. e-liquid in denominator (matches CDC's 3 categories)
  rms_cdc_std   = 100 * disp_std / (pod_std + disp_std + open_std)
)
write_csv(d, file.path(out_dir, "disposable_share_cdc_standardized.csv"))

cdc <- tibble(month = as.Date(c("2020-01-01","2022-12-01")),
              share = c(24.7, 51.8), lab = c("CDC/IRI Jan 2020: 24.7%","CDC/IRI Dec 2022: 51.8%"))

plt <- d %>% select(month, rms_raw, rms_cdc_std) %>%
  pivot_longer(-month, names_to = "series", values_to = "share") %>%
  mutate(series = recode(series,
    rms_raw     = "RMS, raw package counts  (disp / pod+disp)",
    rms_cdc_std = "RMS, CDC standardized unit  (5 cartridges = 1 unit)"))

ggplot(plt, aes(month, share, color = series)) +
  event_layers(ymax = 60) +
  geom_line(linewidth = 1) +
  geom_point(data = cdc, aes(month, share), inherit.aes = FALSE, color = "#b2182b", size = 4) +
  geom_text(data = cdc, aes(month, share, label = lab), inherit.aes = FALSE,
            color = "#b2182b", vjust = -1.1, size = 3.4) +
  scale_color_manual(values = c(
    "RMS, raw package counts  (disp / pod+disp)"          = "#1b9e91",
    "RMS, CDC standardized unit  (5 cartridges = 1 unit)" = "#7570b3")) +
  scale_y_continuous(limits = c(0, 62)) +
  labs(title = "Does RMS understate the disposable share? Unit-definition diagnostic",
       subtitle = "Applying CDC's standardized unit raises the RMS disposable share, closing part of the gap; the rest is channel coverage",
       caption = event_caption,
       y = "Disposable share of unit sales (%)", x = NULL, color = NULL) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.caption = element_text(hjust = 0, color = "grey30", size = 8)) -> p
ggsave(file.path(out_dir, "disposable_share_cdc_standardized.png"), p, width = 10, height = 5.8, dpi = 200)

cat("Anchor comparison (%):\n")
d %>% filter(month %in% as.Date(c("2020-01-01","2022-12-01"))) %>%
  transmute(month, rms_raw = round(rms_raw,1), rms_cdc_std = round(rms_cdc_std,1)) %>%
  mutate(cdc = c(24.7, 51.8)) %>% as.data.frame() %>% print(row.names = FALSE)
