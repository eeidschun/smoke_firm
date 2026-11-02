## Corrected nicotine trajectories for every named brand that appears in the
## annual top-five brand-composition chart. UNKNOWN and Other are not firms.
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })

input_file <- file.path("pr", "input", "bt_month_t2_niccorr_from_full.RData")
out_dir <- file.path("pr", "output", "prelim_analysis", "p_and_n_decomp_t2")
load(input_file)  # bt_month_t2

brand_year <- bt_month_t2 %>%
  mutate(year = year(month)) %>%
  group_by(year, brand) %>%
  summarise(
    mL_sum = sum(mL_sum),
    nic_mg_sum = sum(nic_mg_sum),
    mL_sq = sum(mL_sq_times_unit_sum),
    .groups = "drop_last"
  ) %>%
  mutate(mL_share = mL_sum / sum(mL_sum)) %>%
  ungroup() %>%
  mutate(
    nic_mg_per_mL = nic_mg_sum / mL_sum,
    avg_mL_per_ecig = mL_sq / mL_sum,
    N_hom = nic_mg_per_mL * avg_mL_per_ecig
  )

top_brands <- brand_year %>%
  group_by(year) %>%
  slice_max(mL_sum, n = 5, with_ties = FALSE) %>%
  ungroup() %>%
  distinct(brand) %>%
  filter(brand != "UNKNOWN") %>%
  pull(brand)

brand_order <- brand_year %>%
  filter(brand %in% top_brands) %>%
  group_by(brand) %>%
  summarise(total_mL = sum(mL_sum), .groups = "drop") %>%
  arrange(desc(total_mL)) %>%
  pull(brand)

plot_data <- brand_year %>%
  filter(brand %in% top_brands, mL_share >= 0.001) %>%
  select(year, brand, mL_share, nic_mg_per_mL, avg_mL_per_ecig, N_hom) %>%
  complete(brand, year = 2013:2023) %>%
  mutate(brand = factor(brand, levels = brand_order))

write_csv(
  plot_data %>%
    mutate(across(c(mL_share, nic_mg_per_mL, avg_mL_per_ecig, N_hom), ~round(.x, 3))),
  file.path(out_dir, "top_brand_nicotine_by_year.csv")
)

base_theme <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.title.position = "plot"
  )

p_conc <- ggplot(plot_data, aes(year, nic_mg_per_mL, group = brand)) +
  geom_line(color = "#2a788e", linewidth = 0.9, na.rm = TRUE) +
  geom_point(color = "#2a788e", size = 1.8, na.rm = TRUE) +
  facet_wrap(~brand, ncol = 4) +
  scale_x_continuous(breaks = seq(2013, 2023, 2)) +
  scale_y_continuous(limits = c(0, 45), breaks = seq(0, 40, 10)) +
  labs(
    title = "Delivered nicotine concentration over time, by top brand",
    subtitle = paste0("Annual mL-weighted mg/mL; named brands appearing in any annual top five. ",
                      "Shown when national mL share ≥0.1%. Corrected nicotine panel."),
    x = NULL, y = "Delivered nicotine (mg/mL)"
  ) +
  base_theme

p_nhom <- ggplot(plot_data, aes(year, N_hom, group = brand)) +
  geom_line(color = "#c0392b", linewidth = 0.9, na.rm = TRUE) +
  geom_point(color = "#c0392b", size = 1.8, na.rm = TRUE) +
  facet_wrap(~brand, ncol = 4) +
  scale_x_continuous(breaks = seq(2013, 2023, 2)) +
  scale_y_continuous(limits = c(0, 220), breaks = seq(0, 200, 50)) +
  labs(
    title = expression(N[hom]~"over time, by top brand"),
    subtitle = paste0("Annual mL-weighted nicotine per homogeneous e-cig; named brands appearing ",
                      "in any annual top five. Shown when national mL share ≥0.1%."),
    x = NULL, y = expression(N[hom]~"(mg per homogeneous e-cig)")
  ) +
  base_theme

ggsave(file.path(out_dir, "nic_mg_per_mL_by_top_brand_over_time.png"),
       p_conc, width = 13, height = 9.5, dpi = 200)
ggsave(file.path(out_dir, "N_hom_by_top_brand_over_time.png"),
       p_nhom, width = 13, height = 9.5, dpi = 200)

cat("Top brands:", paste(brand_order, collapse = ", "), "\n")
cat("Wrote top_brand_nicotine_by_year.csv and two top-brand nicotine figures\n")
