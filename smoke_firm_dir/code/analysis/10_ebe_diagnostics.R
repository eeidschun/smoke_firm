## ============================================================================
## Firm-dynamics diagnostics for the EBE supply-side model
## Covers items 7.1, 7.2, 7.4, 7.5 of 08_27_2026 model note
## (7.3 nicotine-vs-FDA event study and 7.6 ownership-vs-quality are NOT here,
##  deferred per the model note and the data request).
##
## Data:
##   - smoke_firm_dir/input/bt_month_t2_niccorr_from_full.RData  (corrected panel,
##     brand x type x month, 2013-01..2023-12) -> everything monthly
##   - smoke_firm_dir/input/upc_month_niccorr_from_full.RData  (brand x UPC x month,
##     built by build/5_build_upc_month_niccorr.R from raw/cleaned_RMS/) -> 7.5, monthly
##
## Conventions match the two 08_05_2026 notes: national, and where a weight is
## needed the demand series use mL weights -- but per Marc's instruction the
## firm-level nicotine state (7.5b) is built UPC-unweighted, NOT mL-sales-weighted.
## ============================================================================

rm(list = ls())
suppressPackageStartupMessages({
  library(tidyverse); library(lubridate); library(fixest)
})

source("smoke_firm_dir/code/fxns/1_paths.R")
out_dir  <- file.path(PRELIM_DIR, "firm_dynamics_ebe")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
fxn("4_event_lines_t2.R")   # events, event_layers(), event_vlines()

save_plot <- function(p, name, w = 9, h = 5.5)
  ggsave(file.path(out_dir, paste0(name, ".png")), p, width = w, height = h, dpi = 200)

theme_note <- theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())

BLUE <- "#1f78b4"; RED <- "#e31a1c"; GREY <- "grey55"

## ---- base brand x month panel (collapse product type) -----------------------
load(file.path(SUPPORT_DIR, "bt_month_t2_niccorr_from_full.RData"))   # bt_month_t2

bm <- bt_month_t2 %>%
  mutate(brand = str_trim(brand)) %>%
  group_by(month, brand) %>%
  summarise(units = sum(units_sum), mL = sum(mL_sum),
            rev_real = sum(revenue_real), nic_mg = sum(nic_mg_sum),
            mLsq_u = sum(mL_sq_times_unit_sum), .groups = "drop") %>%
  group_by(month) %>%
  mutate(sh = mL / sum(mL)) %>%
  ungroup() %>%
  mutate(price_per_mL = rev_real / mL,
         year = year(month))

## UNKNOWN is the residual un-attributed bucket (~1.9% of mL); it is not a firm,
## so it is dropped from every firm-count / entry-exit / learning statistic.
bmf <- bm %>% filter(brand != "UNKNOWN")

## ===========================================================================
## 7.1  How many firms really compete, and does the cap of 5 bind?
## ===========================================================================
d1 <- bmf %>%
  group_by(month) %>%
  summarise(
    n_any  = sum(mL > 0),
    n_1pct = sum(sh > 0.01),
    n_5pct = sum(sh > 0.05),
    other_below_top5 = { o <- sort(sh, decreasing = TRUE); sum(o[-(1:5)]) },
    other_below_1pct = sum(sh[sh <= 0.01]),
    .groups = "drop")
write_csv(d1, file.path(out_dir, "d1_active_firm_counts_monthly.csv"))

d1_summary <- d1 %>%
  mutate(year = year(month)) %>%
  group_by(year) %>%
  summarise(across(c(n_any, n_1pct, n_5pct, other_below_top5, other_below_1pct),
                   ~ round(mean(.x), 2)), .groups = "drop")
write_csv(d1_summary, file.path(out_dir, "d1_active_firm_counts_by_year.csv"))

cat("\n=== 7.1 active-firm counts ===\n")
cat(sprintf("brands with any mL:  median %d  range %d-%d\n",
            median(d1$n_any), min(d1$n_any), max(d1$n_any)))
cat(sprintf("brands >1%% mL share: median %d  range %d-%d ; >5 in %d/%d months\n",
            median(d1$n_1pct), min(d1$n_1pct), max(d1$n_1pct),
            sum(d1$n_1pct > 5), nrow(d1)))
cat(sprintf("brands >5%% mL share: median %d  range %d-%d ; >5 in %d/%d months\n",
            median(d1$n_5pct), min(d1$n_5pct), max(d1$n_5pct),
            sum(d1$n_5pct > 5), nrow(d1)))
cat(sprintf("'Other' (below top-5) mL share: mean %.1f%%  range %.1f-%.1f%%\n",
            100*mean(d1$other_below_top5), 100*min(d1$other_below_top5),
            100*max(d1$other_below_top5)))
print(d1_summary)

## Figure: counts over threshold + fringe share, stacked panels
d1_long <- d1 %>%
  select(month, `> 1% mL share` = n_1pct, `> 5% mL share` = n_5pct) %>%
  pivot_longer(-month, names_to = "cut", values_to = "n")

p1a <- ggplot(d1_long, aes(month, n, color = cut)) +
  event_vlines() +
  geom_hline(yintercept = 5, linetype = "dotted", color = "black", linewidth = 0.5) +
  annotate("text", x = min(d1$month), y = 5.35, hjust = 0, size = 3,
           color = "grey30", label = "model cap N = 5") +
  geom_line(linewidth = 0.9) +
  scale_color_manual(values = c("> 1% mL share" = BLUE, "> 5% mL share" = RED)) +
  scale_y_continuous(breaks = seq(0, 12, 2)) +
  labs(subtitle = "(a) Number of national brands above a materiality threshold, by month",
       x = NULL, y = "brands", color = NULL) +
  theme_note

p1b <- ggplot(d1, aes(month, 100 * other_below_top5)) +
  event_vlines() +
  geom_area(fill = BLUE, alpha = 0.25) +
  geom_line(color = BLUE, linewidth = 0.9) +
  labs(subtitle = "(b) Aggregate mL share of the fringe (all brands outside the top 5)",
       x = NULL, y = "% of national mL") +
  theme_note

save_plot(patchwork::wrap_plots(p1a, p1b, ncol = 1) +
            patchwork::plot_annotation(
              title = "7.1  How many brands compete, and does the cap of 5 bind?",
              caption = event_caption,
              theme = theme(plot.caption = element_text(hjust = 0, size = 8, color = "grey40"))),
          "d1_firm_counts_and_fringe", w = 9, h = 7)

## ===========================================================================
## 7.2  Entry / exit hazards and the one-entrant-per-period assumption
## ===========================================================================
## (a) first-ever month of positive national mL, market-wide
appear <- bmf %>% filter(mL > 0) %>%
  group_by(brand) %>% summarise(first = min(month), .groups = "drop")
## 2013-01 is left-censored (every incumbent "appears" then) -> drop it
entry_mo <- appear %>% filter(first > as.Date("2013-01-01")) %>%
  count(first, name = "n_entrants") %>%
  complete(first = seq(as.Date("2013-02-01"), as.Date("2023-12-01"), by = "month"),
           fill = list(n_entrants = 0))
write_csv(entry_mo, file.path(out_dir, "d2_first_appearance_by_month.csv"))

cat("\n=== 7.2a first appearances (excl. 2013-01) ===\n")
cat(sprintf("total new brand-codes: %d  across %d distinct months  (max %d in one month)\n",
            sum(entry_mo$n_entrants), sum(entry_mo$n_entrants > 0), max(entry_mo$n_entrants)))
cat(sprintf("in calendar 2021: %d\n", sum(entry_mo$n_entrants[year(entry_mo$first) == 2021])))
cat("by year:\n")
print(entry_mo %>% mutate(y = year(first)) %>% group_by(y) %>%
        summarise(new_brands = sum(n_entrants), months_with_entry = sum(n_entrants > 0)))

p2a <- ggplot(entry_mo, aes(first, n_entrants)) +
  event_layers(ymax = max(entry_mo$n_entrants)) +
  geom_col(fill = BLUE, width = 25) +
  scale_y_continuous(breaks = seq(0, 16, 4)) +
  labs(title = "7.2a  New brand-codes entering the tracked market, by month",
       subtitle = "First month of positive national tracked mL (2013-01 left-censored, omitted)",
       x = NULL, y = "new brands", caption = event_caption) +
  theme_note +
  theme(plot.caption = element_text(hjust = 0, size = 8, color = "grey40"))
save_plot(p2a, "d2_entry_first_appearance", w = 9, h = 5)

## (b) top-5 tenure and age at exit
rk <- bmf %>% group_by(month) %>%
  mutate(rank = rank(-mL, ties.method = "first")) %>% ungroup()
top5_ever <- rk %>% filter(rank <= 5) %>% distinct(brand) %>% pull(brand)

tenure <- rk %>% filter(brand %in% top5_ever) %>%
  group_by(brand) %>% arrange(month) %>%
  summarise(first          = min(month[mL > 0]),
            last_present   = max(month[mL > 0]),
            months_in_top5 = sum(rank <= 5),
            longest_spell  = { r <- rle(rank <= 5); m <- r$lengths[r$values]
                               if (length(m)) max(m) else 0L },
            last_top5      = max(month[rank <= 5]),
            .groups = "drop") %>%
  mutate(left_top5   = last_top5   < as.Date("2023-06-01"),
         left_panel  = last_present < as.Date("2023-06-01"),
         age_at_last_top5 = interval(first, last_top5) %/% months(1),
         age_at_panel_exit = ifelse(left_panel,
                                    interval(first, last_present) %/% months(1), NA_integer_),
         status = case_when(!left_top5              ~ "in top-5 at end of 2023",
                            left_top5 & !left_panel ~ "left top-5, still selling",
                            TRUE                    ~ "left the panel"))
write_csv(tenure, file.path(out_dir, "d2_top5_tenure.csv"))

cat("\n=== 7.2b top-5 tenure ===\n")
cat(sprintf("brands ever in top-5: %d ; median total months in top-5: %d ; mean: %.1f\n",
            length(top5_ever), median(tenure$months_in_top5), mean(tenure$months_in_top5)))
cat("age (months since first appearance) at last top-5 month, for permanent leavers:\n")
print(tenure %>% filter(left_top5) %>%
        arrange(age_at_last_top5) %>%
        select(brand, first, last_top5, age_at_last_top5, age_at_panel_exit, status))

lvl <- tenure %>% arrange(months_in_top5) %>% pull(brand)
p2b <- tenure %>%
  mutate(brand = factor(brand, levels = lvl)) %>%
  ggplot(aes(months_in_top5, brand, color = status)) +
  geom_segment(aes(x = 0, xend = months_in_top5, yend = brand), linewidth = 0.6) +
  geom_point(size = 2.6) +
  scale_color_manual(values = c("in top-5 at end of 2023" = BLUE,
                                "left top-5, still selling" = "#ff7f00",
                                "left the panel" = RED)) +
  labs(title = "7.2b  Months spent in the national top-5 by mL share, 2013-2023",
       subtitle = "132 months total; point colour = status at end of 2023",
       x = "months in top-5 (total, not necessarily contiguous)", y = NULL, color = NULL) +
  theme_note
save_plot(p2b, "d2_top5_tenure", w = 9, h = 5)

## ===========================================================================
## 7.4  Learning-by-doing cost signature (Benkard channel)
## ===========================================================================
lc <- bmf %>% filter(units > 0, mL > 0) %>%
  arrange(brand, month) %>%
  group_by(brand) %>%
  mutate(cum_units = cumsum(units) - units,     # stock entering month t (excl. t)
         cum_mL    = cumsum(mL)    - mL,
         n_mo = n()) %>%
  ungroup() %>%
  filter(cum_units > 0)
lc$ym <- factor(format(lc$month, "%Y-%m"))
lc$yr <- factor(lc$year)

m_pool_month <- feols(log(price_per_mL) ~ log(cum_units) | brand + ym, data = lc)
m_pool_year  <- feols(log(price_per_mL) ~ log(cum_units) | brand + yr, data = lc)
m_pool_none  <- feols(log(price_per_mL) ~ log(cum_units) | brand,      data = lc)
m_pool_mL    <- feols(log(price_per_mL) ~ log(cum_mL)    | brand + ym, data = lc)

cat("\n=== 7.4 pooled learning slopes (log price/mL on log cumulative own output) ===\n")
cat(sprintf("brand + month FE, cum units : %+.3f (SE %.3f, p %.3f)\n",
            coef(m_pool_month)[1], se(m_pool_month)[1], pvalue(m_pool_month)[1]))
cat(sprintf("brand + year  FE, cum units : %+.3f (SE %.3f, p %.3f)\n",
            coef(m_pool_year)[1], se(m_pool_year)[1], pvalue(m_pool_year)[1]))
cat(sprintf("brand FE only  (no time)    : %+.3f (SE %.3f, p %.3f)   <- absorbs the market-wide $/mL decline\n",
            coef(m_pool_none)[1], se(m_pool_none)[1], pvalue(m_pool_none)[1]))
cat(sprintf("brand + month FE, cum mL    : %+.3f (SE %.3f, p %.3f)\n",
            coef(m_pool_mL)[1], se(m_pool_mL)[1], pvalue(m_pool_mL)[1]))

## firm-by-firm: within-brand, calendar-year FE to net out the common trend.
## Restrict to brands that ever held >=3% of national mL in a year (13 brands) --
## the set the dynamic model would actually track.
ever_3pct <- bmf %>% group_by(brand, year) %>% summarise(mL = sum(mL), .groups = "drop") %>%
  group_by(year) %>% mutate(sh = mL / sum(mL)) %>% group_by(brand) %>%
  summarise(peak = max(sh), .groups = "drop") %>% filter(peak >= 0.03) %>% pull(brand)
fbf_brands <- lc %>% count(brand) %>% filter(n >= 24) %>% pull(brand) %>% intersect(ever_3pct)
fbf <- map_dfr(fbf_brands, function(b) {
  s <- lc %>% filter(brand == b)
  m <- tryCatch(feols(log(price_per_mL) ~ log(cum_units) | yr, data = s, warn = FALSE),
                error = function(e) NULL)
  if (is.null(m)) return(NULL)
  ct <- coeftable(m)["log(cum_units)", ]
  tibble(brand = b, n_mo = nrow(s), beta = ct[1], se = ct[2], p = ct[4])
}) %>%
  mutate(era = case_when(
           brand %in% c("JUUL", "VUSE", "NJOY")          ~ "salt-pod-era leader",
           brand %in% c("HYPPE", "BREEZE", "MNGO", "IGNITE") ~ "modern disposable",
           TRUE                                          ~ "cigalike-era brand"),
         lo = beta - 1.96 * se, hi = beta + 1.96 * se)
write_csv(fbf, file.path(out_dir, "d3_learning_firm_by_firm.csv"))

cat("\n=== 7.4 firm-by-firm learning slopes (year FE within brand) ===\n")
print(fbf %>% arrange(beta) %>%
        transmute(brand, n_mo, era, beta = round(beta, 3), se = round(se, 3), p = round(p, 3)))

ord <- fbf %>% arrange(beta) %>% pull(brand)
pooled_b  <- coef(m_pool_month)[1]
pooled_se <- se(m_pool_month)[1]
p3a <- fbf %>%
  mutate(brand = factor(brand, levels = ord)) %>%
  ggplot(aes(beta, brand, color = era)) +
  annotate("rect", xmin = pooled_b - 1.96 * pooled_se, xmax = pooled_b + 1.96 * pooled_se,
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.5) +
  geom_vline(xintercept = 0, color = "grey40") +
  geom_vline(xintercept = pooled_b, linetype = "dashed", color = "grey30") +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0, linewidth = 0.6) +
  geom_point(size = 2.8) +
  scale_color_manual(values = c("cigalike-era brand" = RED,
                                "salt-pod-era leader" = BLUE,
                                "modern disposable" = "#33a02c")) +
  labs(title = "7.4  Learning-curve slope by firm: log(price/mL) on log(cumulative own units)",
       subtitle = sprintf(paste0("Within brand + calendar-year FE, 95%% CI. Dashed line / band = ",
                                 "pooled estimate (%.3f, not significant)."), pooled_b),
       x = "elasticity of real price per mL w.r.t. cumulative own units  (negative = learning-curve sign)",
       y = NULL, color = NULL) +
  theme_note
save_plot(p3a, "d3_learning_coefplot", w = 9.5, h = 5)

## scatter: residualize both sides on calendar-year means (what the firm-by-firm
## regression actually identifies), 6 illustrative brands
show6 <- intersect(c("BLU", "LOGIC", "21ST CENTURY SMOKE", "JUUL", "VUSE", "NJOY"), lc$brand)
resid_df <- lc %>% filter(brand %in% show6) %>%
  group_by(brand) %>%
  mutate(ly = log(price_per_mL), lx = log(cum_units),
         ry = ly - ave(ly, year), rx = lx - ave(lx, year)) %>%
  ungroup() %>% mutate(brand = factor(brand, levels = show6))
p3b <- ggplot(resid_df, aes(rx, ry)) +
  geom_hline(yintercept = 0, color = "grey80") + geom_vline(xintercept = 0, color = "grey80") +
  geom_point(color = BLUE, size = 1.1, alpha = 0.55) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 0.8, formula = y ~ x) +
  facet_wrap(~brand, scales = "free") +
  labs(title = "7.4  Learning curve after removing the common time trend",
       subtitle = "Both axes residualized on calendar-year means. Down-slope = price/mL falls with own accumulation, net of the market-wide decline.",
       x = "log cumulative own units, deviation from year mean",
       y = "log real price per mL, deviation from year mean") +
  theme_note
save_plot(p3b, "d3_learning_scatter", w = 10, h = 6)

## ===========================================================================
## 7.5  Product-offering-set (UPC count) dynamics + nicotine-weighting check
## Monthly, from the corrected brand x UPC x month panel.
## ===========================================================================
load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))   # upc_month_t2
um <- upc_month_t2 %>% mutate(brand = str_trim(brand)) %>%
  filter(brand != "UNKNOWN", units_sum > 0, mL_sum > 0)

## (a) monthly active-UPC count per brand
upc_ct <- um %>% group_by(month, brand) %>%
  summarise(n_upc = n_distinct(upc12), mL = sum(mL_sum), .groups = "drop")
write_csv(upc_ct, file.path(out_dir, "d4_upc_counts_by_brand_month.csv"))

## monthly national mL share (same brand universe as 7.1-7.4)
sh_mo <- bmf %>% select(month, brand, sh)

majors <- c("JUUL", "VUSE", "NJOY", "BLU", "MISTIC", "LOGIC")
p4a <- upc_ct %>% filter(brand %in% majors) %>%
  mutate(brand = factor(brand, levels = majors)) %>%
  ggplot(aes(month, n_upc, color = brand)) +
  event_vlines() +
  geom_line(linewidth = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(title = "7.5a  Active UPC count per brand, monthly",
       subtitle = "Distinct UPCs with positive tracked national sales, corrected panel",
       x = NULL, y = "active UPCs", color = NULL, caption = event_caption) +
  theme_note +
  theme(plot.caption = element_text(hjust = 0, size = 8, color = "grey40"))
save_plot(p4a, "d4_upc_counts", w = 9.5, h = 5)

## lead-lag: monthly change in national share vs change in log UPC count.
## Distributed-lag regression, brand + month FE, SE clustered by brand.
ll <- upc_ct %>%
  inner_join(sh_mo, by = c("month", "brand")) %>%
  filter(brand %in% (bmf %>% group_by(brand) %>% summarise(pk = max(sh)) %>%
                       filter(pk > 0.02) %>% pull(brand))) %>%
  arrange(brand, month) %>%
  group_by(brand) %>%
  mutate(mo_idx = (as.integer(format(month, "%Y")) - 2013) * 12 +
                   as.integer(format(month, "%m")),
         gap    = c(1L, diff(mo_idx)),
         d_lupc = ifelse(gap == 1, c(NA, diff(log(n_upc))), NA),
         d_sh   = ifelse(gap == 1, c(NA, diff(100 * sh)), NA)) %>%
  ungroup()
ll$ym <- factor(ll$mo_idx)
dl <- feols(d_sh ~ l(d_lupc, -3:3) | brand + ym, data = ll,
            panel.id = ~ brand + mo_idx)
cat("\n=== 7.5a distributed-lag: d(share, pp) on d(log UPC count) leads/lags ===\n")
print(coeftable(dl))
## per-brand lead/lag correlation: d(logUPC)_t with d(share)_{t+k}
shift_k <- function(x, k) if (k >= 0) dplyr::lead(x, k) else dplyr::lag(x, -k)
ccf_tab <- ll %>% filter(brand %in% majors) %>% arrange(brand, month) %>%
  group_by(brand) %>%
  group_modify(~ map_dfr(-4:4, function(k)
    tibble(k = k, corr = suppressWarnings(
      cor(.x$d_lupc, shift_k(.x$d_sh, k), use = "complete.obs"))))) %>%
  ungroup()
write_csv(ccf_tab, file.path(out_dir, "d4_upc_share_ccf.csv"))
cat("\ncorr( d(logUPC)_t , d(share)_{t+k} ) by brand  (k>0: share change comes after UPC change):\n")
print(ccf_tab %>% filter(k %in% -3:3) %>%
        pivot_wider(names_from = k, values_from = corr) %>%
        mutate(across(-brand, ~ round(.x, 2))))
cat("pooled corr at k=-2..2: ",
    paste(sprintf("k=%+d:%.2f", -2:2,
      sapply(-2:2, function(k) with(ll, cor(d_lupc, shift_k(d_sh, k), use = "complete.obs")))),
      collapse = "  "), "\n")

## (b) nicotine: mL-sales-weighted (demand-note style) vs UPC-unweighted (Marc)
mlwt <- um %>% group_by(month, brand) %>%
  summarise(mgml = sum(nic_mg_sum) / sum(mL_sum),
            cap  = sum(mL_sq_times_unit_sum) / sum(mL_sum), .groups = "drop") %>%
  mutate(Nhom = mgml * cap, weight = "mL-sales-weighted")
unwt <- um %>%
  mutate(upc_mgml = nic_mg_sum / mL_sum, upc_cap = mL_sum / units_sum) %>%
  group_by(month, brand) %>%
  summarise(mgml = mean(upc_mgml), cap = mean(upc_cap), .groups = "drop") %>%
  mutate(Nhom = mgml * cap, weight = "UPC-unweighted")
nic_cmp <- bind_rows(mlwt, unwt)
write_csv(nic_cmp %>% pivot_wider(names_from = weight, values_from = c(mgml, cap, Nhom)),
          file.path(out_dir, "d4_nicotine_weighting_compare.csv"))

show4 <- c("JUUL", "VUSE", "NJOY", "BLU")
wide <- nic_cmp %>% filter(brand %in% show4) %>%
  select(month, brand, weight, mgml) %>%
  pivot_wider(names_from = weight, values_from = mgml)
cat("\n=== 7.5b mL-weighted vs UPC-unweighted delivered mg/mL (monthly) ===\n")
cat(sprintf("%s: mean |diff| = %.2f mg/mL ; correlation = %.2f\n",
            paste(show4, collapse = "/"),
            mean(abs(wide$`mL-sales-weighted` - wide$`UPC-unweighted`)),
            cor(wide$`mL-sales-weighted`, wide$`UPC-unweighted`)))
print(nic_cmp %>% filter(brand %in% show4, format(month, "%m") == "12") %>%
        transmute(brand, year = format(month, "%Y"), weight,
                  mgml = round(mgml, 1), Nhom = round(Nhom)) %>%
        pivot_wider(names_from = weight, values_from = c(mgml, Nhom)), n = 40)

nic_long <- nic_cmp %>% filter(brand %in% show4) %>%
  select(month, brand, weight, `delivered nicotine (mg/mL)` = mgml,
         `N_hom-style flow (mg)` = Nhom) %>%
  pivot_longer(c(`delivered nicotine (mg/mL)`, `N_hom-style flow (mg)`),
               names_to = "panel", values_to = "val") %>%
  mutate(brand = factor(brand, levels = show4))
p4b <- ggplot(nic_long, aes(month, val, color = weight)) +
  geom_line(linewidth = 0.75) +
  facet_grid(panel ~ brand, scales = "free_y") +
  scale_color_manual(values = c("mL-sales-weighted" = RED, "UPC-unweighted" = BLUE)) +
  labs(title = "7.5b  Firm-level nicotine: mL-sales-weighted vs. UPC-unweighted (monthly)",
       subtitle = "Marc's instruction is the blue series - averaged over the firm's active UPCs, not its realized sales mix.",
       x = NULL, y = NULL, color = NULL) +
  theme_note
save_plot(p4b, "d4_nicotine_weighting", w = 10, h = 6)

cat("\nAll figures + CSVs written to", out_dir, "\n")
