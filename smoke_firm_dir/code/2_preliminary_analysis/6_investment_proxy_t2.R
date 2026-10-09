## Investment-proxy exploration: for every brand that was EVER top-6 (by annual
## national mL share), track its (a) product-type mix and (b) nicotine input over
## time, against its market share — to see whether form changes / nicotine jumps
## precede or coincide with the 2013-2023 "leap-frogging" of leaders.
rm(list = ls()); suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })
source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir <- file.path(PRELIM_DIR, "investment_proxy")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
load(file.path(SUPPORT_DIR, "bt_month_t2_niccorr_from_full.RData")); df <- bt_month_t2  # nic-corrected panel
df$year <- as.integer(format(df$month, "%Y"))
save_plot <- function(p, name, w = 12, h = 7.5)
  ggsave(file.path(out_dir, paste0(name, ".png")), p, width = w, height = h, dpi = 200)

## annual brand panel with investment-proxy measures
ba <- df %>% group_by(year, brand) %>%
  summarise(mL = sum(mL_sum), units = sum(units_sum), nic = sum(nic_mg_sum),
            CP = sum(mL_sum[type == "Closed pod"]),
            DISP = sum(mL_sum[type == "Disposable"]),
            OR = sum(mL_sum[type == "Open refill"]), .groups = "drop") %>%
  group_by(year) %>% mutate(share = 100 * mL / sum(mL),
                            rnk = rank(-mL, ties.method = "first")) %>% ungroup() %>%
  mutate(nic_mg_per_mL = nic / mL,          # concentration = salt-nicotine signal
         avg_mL_per_unit = mL / units,       # capacity proxy (mL per package)
         nic_per_unit   = nic / units,       # delivered nicotine per package (mg)
         CPp = 100 * CP / mL, DISPp = 100 * DISP / mL, ORp = 100 * OR / mL)

## ever-top-6 firms (exclude the residual UNKNOWN bucket)
ever <- ba %>% filter(brand != "UNKNOWN", rnk <= 6) %>% distinct(brand) %>% pull(brand)
cat("Ever-top-6 firms (", length(ever), "):", paste(ever, collapse = ", "), "\n")
ord <- ba %>% filter(brand %in% ever) %>% group_by(brand) %>%
  summarise(peak = max(share), .groups = "drop") %>% arrange(desc(peak)) %>% pull(brand)
sub <- ba %>% filter(brand %in% ever) %>% mutate(brand = factor(brand, levels = ord))

write_csv(
  sub %>% transmute(year, brand, share = round(share, 1), rank = rnk,
                    Closed_pod_pct = round(CPp), Disposable_pct = round(DISPp),
                    Open_refill_pct = round(ORp), nic_mg_per_mL = round(nic_mg_per_mL, 1),
                    avg_mL_per_unit = round(avg_mL_per_unit, 2), nic_per_unit_mg = round(nic_per_unit, 1)),
  file.path(out_dir, "ever_top6_brand_year_panel.csv"))

## Fig A: share (bars) + nicotine concentration (red line), per brand.
## Both sit on ~0-55, so they share one numeric scale (relabeled on the right).
save_plot(
  ggplot(sub, aes(year)) +
    geom_col(aes(y = share), fill = "grey78") +
    geom_line(aes(y = nic_mg_per_mL), color = "#e31a1c", linewidth = 0.9) +
    geom_point(aes(y = nic_mg_per_mL), color = "#e31a1c", size = 0.9) +
    facet_wrap(~brand) +
    scale_x_continuous(breaks = seq(2013, 2023, 3)) +
    scale_y_continuous(name = "mL share (%)  [grey bars]",
                       sec.axis = sec_axis(~., name = "nicotine mg/mL  [red line]")) +
    labs(title = "Market share vs. nicotine concentration, ever-top-6 brands",
         subtitle = "Grey bars = national mL share (%); red line = nicotine mg/mL (same numeric scale)",
         x = NULL) +
    theme_minimal(base_size = 11) +
    theme(axis.title.y.right = element_text(color = "#e31a1c")),
  "share_vs_nicotine_by_brand")

## Fig B: product-type mix (stacked area) per brand, to see form shifts vs share.
mix <- sub %>% select(year, brand, `Closed pod` = CPp, Disposable = DISPp, `Open refill` = ORp) %>%
  pivot_longer(-c(year, brand), names_to = "type", values_to = "pct") %>%
  mutate(type = factor(type, levels = c("Closed pod", "Disposable", "Open refill")))
save_plot(
  ggplot(mix, aes(year, pct, fill = type)) + geom_area() +
    facet_wrap(~brand) +
    scale_fill_manual(values = c("Closed pod" = "#3b528b", "Disposable" = "#21908c",
                                 "Open refill" = "#5ec962")) +
    scale_x_continuous(breaks = seq(2013, 2023, 3)) +
    labs(title = "Product-type mix over time, ever-top-6 brands",
         subtitle = "Share of each brand's own mL by T2 type (Closed pod includes cigalike cartridges and modern pods)",
         y = "% of brand mL", x = NULL, fill = NULL) +
    theme_minimal(base_size = 11) + theme(legend.position = "bottom"),
  "typemix_by_brand")

## console: per-brand peak share, and dominant form at peak vs at entry
cat("\n=== per-brand summary: entry year, peak year/share, form at peak ===\n")
sub %>% group_by(brand) %>%
  summarise(first_yr = min(year[share >= 1]),
            peak_yr = year[which.max(share)], peak_share = round(max(share), 1),
            form_at_peak = c("Closed pod","Disposable","Open refill")[which.max(c(
              CPp[which.max(share)], DISPp[which.max(share)], ORp[which.max(share)]))],
            nic_at_peak = round(nic_mg_per_mL[which.max(share)], 1), .groups = "drop") %>%
  arrange(desc(peak_share)) %>% as.data.frame() %>% print(row.names = FALSE)
cat("\nWrote ever_top6_brand_year_panel.csv, share_vs_nicotine_by_brand.png, typemix_by_brand.png\n")
