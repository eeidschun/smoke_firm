## ============================================================================
## 2021 entry-wave: coverage-vs-entry check  (09_01_2026 note)
##
## Verifies the 7.2a hypothesis that the calendar-2021 burst of new brand-codes
## is an RMS coverage / taxonomy discontinuity, not economic entry. Five checks:
##   1  first-appearance trajectory (abrupt onset vs diffusion ramp)
##   2  outlet coverage (store panel vs brand/UPC count)  -- needs the store cache
##   3  brand identity vs documented launch dates (printed list; text is in note)
##   4  rebrand / reclassification (shared UPC prefixes)
##   5  entry timing vs the regulatory dates
##
## Inputs : input/bt_month_t2_niccorr_from_full.RData, input/upc_month_niccorr_from_full.RData,
##          input/entry_wave_store_cache.rds  (from manual_refinement/7_entry_wave_store_pass.R)
## Outputs: output/prelim_analysis/firm_dynamics_ebe/entry_*.png  + console summary
## ============================================================================
rm(list = ls())
suppressPackageStartupMessages({ library(tidyverse); library(lubridate) })
source("smoke_firm_dir/code/fxns/1_paths.R")
fxn("4_event_lines_t2.R")
out_dir <- file.path(PRELIM_DIR, "firm_dynamics_ebe")
BLUE <- "#1f78b4"; RED <- "#e31a1c"; GREEN <- "#33a02c"
theme_note <- theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())
save_plot <- function(p, n, w = 9, h = 5.5)
  ggsave(file.path(out_dir, paste0(n, ".png")), p, width = w, height = h, dpi = 200)

load(file.path(SUPPORT_DIR, "bt_month_t2_niccorr_from_full.RData"))
load(file.path(SUPPORT_DIR, "upc_month_niccorr_from_full.RData"))

bm <- bt_month_t2 %>% mutate(brand = str_trim(brand)) %>% filter(brand != "UNKNOWN") %>%
  group_by(month, brand) %>%
  summarise(units = sum(units_sum), mL = sum(mL_sum),
            dtype = type[which.max(mL_sum)], .groups = "drop") %>%
  group_by(month) %>% mutate(sh = 100 * mL / sum(mL)) %>% ungroup()
first <- bm %>% filter(mL > 0) %>% group_by(brand) %>% summarise(f = min(month), .groups = "drop")

## ---- 5. entry timing ------------------------------------------------------
entry <- first %>% filter(f > as.Date("2013-01-01"))
cat("=== 5. first-appearance counts ===\n")
cat(sprintf("2019: %d | 2020: %d | Feb-Dec 2020 (post enforcement): %d | Sep-Dec 2020 (post PMTA): %d\n",
            sum(year(entry$f) == 2019), sum(year(entry$f) == 2020),
            sum(entry$f >= as.Date("2020-02-01") & entry$f <= as.Date("2020-12-01")),
            sum(entry$f >= as.Date("2020-09-01") & entry$f <= as.Date("2020-12-01"))))
cat(sprintf("Jan 2021: %d | Feb-Dec 2021: %d | 2022: %d | 2023: %d\n",
            sum(entry$f == as.Date("2021-01-01")),
            sum(year(entry$f) == 2021 & month(entry$f) > 1),
            sum(year(entry$f) == 2022), sum(year(entry$f) == 2023)))

e2021 <- first %>% filter(year(f) == 2021) %>% pull(brand)
e2022 <- first %>% filter(year(f) == 2022) %>% pull(brand)

## ---- 1. first-appearance trajectory -------------------------------------
traj <- bm %>% inner_join(first, by = "brand") %>% filter(mL > 0) %>%
  group_by(brand) %>% arrange(month) %>% mutate(k = row_number()) %>% ungroup()
ref <- traj %>% group_by(brand) %>%
  summarise(ref_mL = { m <- mL[k >= 10 & k <= 24]; if (length(m) >= 3) median(m) else max(mL) },
            .groups = "drop")
clean <- c("JUUL", "VUSE", "LOGIC", "MARKTEN", "LEAP", "NICOTEK", "V2 CIGS")
tp <- traj %>% left_join(ref, by = "brand") %>%
  mutate(cohort = case_when(brand %in% clean          ~ "genuine entrants (JUUL, VUSE, LEAP, ...)",
                            year(f) == 2021           ~ "2021 cohort (27)",
                            year(f) == 2022           ~ "2022 cohort (10)", TRUE ~ NA_character_)) %>%
  filter(!is.na(cohort), k <= 6, ref_mL > 0) %>%
  mutate(fr = pmin(mL / ref_mL, 3))
tsum <- tp %>% group_by(cohort, k) %>%
  summarise(med = median(fr), q25 = quantile(fr, .25), q75 = quantile(fr, .75), .groups = "drop")
cat("\n=== 1. month-1 mL as fraction of own later level (cohort medians) ===\n")
print(tsum %>% filter(k %in% c(1, 3, 6)) %>%
        pivot_wider(id_cols = cohort, names_from = k, values_from = med,
                    names_prefix = "k") %>% mutate(across(-cohort, ~ round(.x, 2))))

pal3 <- c("2021 cohort (27)" = RED, "2022 cohort (10)" = GREEN,
          "genuine entrants (JUUL, VUSE, LEAP, ...)" = BLUE)
p2 <- ggplot(tsum, aes(k, med, color = cohort, fill = cohort)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.13, color = NA) +
  geom_line(linewidth = 1) + geom_point(size = 1.8) +
  scale_color_manual(values = pal3) + scale_fill_manual(values = pal3) +
  scale_x_continuous(breaks = 1:6) +
  labs(title = "First-appearance trajectory: tracked mL vs. the brand's own later level",
       subtitle = "Cohort median (band = IQR). 1.0 = this month is already a typical later month for the brand.",
       x = "tracked month since first RMS appearance",
       y = "mL / own months 10-24 median", color = NULL, fill = NULL) +
  theme_note
save_plot(p2, "entry_trajectory_by_cohort", w = 9, h = 5.5)

## ---- 4. rebrand / reclassification: shared UPC prefixes ------------------
u <- upc_month_t2 %>% mutate(brand = str_trim(brand))
pre_pfx <- u %>% filter(month < as.Date("2021-01-01")) %>%
  transmute(pfx8 = substr(upc12, 1, 8), brand_pre = brand) %>% distinct()
new_pfx <- u %>% filter(brand %in% e2021) %>%
  transmute(pfx8 = substr(upc12, 1, 8), brand_new = brand) %>% distinct()
cat("\n=== 4. 2021-entrant UPC prefixes shared with a pre-2021 brand-code ===\n")
print(new_pfx %>% inner_join(pre_pfx, by = "pfx8", relationship = "many-to-many") %>%
        filter(brand_new != brand_pre) %>% arrange(pfx8) %>% as.data.frame())
cat("\n2021 entrants sharing a product description across codes (Puff family etc.):\n")
print(u %>% filter(brand %in% e2021) %>%
        group_by(brand) %>% summarise(descr = paste(unique(substr(descr, 1, 22)), collapse = " | "),
                                      .groups = "drop") %>%
        filter(str_detect(descr, "PUFF|SAVAGE|AIR BAR|RARE|HYPPE")) %>% as.data.frame())

## ---- 2. outlet coverage (needs the store cache) -------------------------
cache_path <- file.path(SUPPORT_DIR, "entry_wave_store_cache.rds")
if (!file.exists(cache_path)) {
  cat("\n[2] store cache not found -- run manual_refinement/7_entry_wave_store_pass.R first.\n")
} else {
  cache <- readRDS(cache_path)
  s <- as.data.frame(cache$stores_ym); s$month <- as.Date(paste0(s$year_month, "-01"))
  cat("\n=== 2. RMS e-cig store panel vs. UPC / brand counts ===\n")
  print(s %>% filter(year_month %in% c("2019-06", "2020-01", "2020-03", "2020-12",
                                       "2021-01", "2021-06", "2022-06")) %>%
          select(year_month, n_store_ec, n_store_disp, n_upc_ec, units_ec))
  s20 <- cache$store_ids$store_code_uc[cache$store_ids$year_month == "2020-12"]
  s21 <- cache$store_ids$store_code_uc[cache$store_ids$year_month == "2021-01"]
  cat(sprintf("Dec20 -> Jan21 stores: %d -> %d (both %d, new %d, dropped %d)\n",
              length(s20), length(s21), length(intersect(s20, s21)),
              length(setdiff(s21, s20)), length(setdiff(s20, s21))))

  nb <- bt_month_t2 %>% mutate(brand = str_trim(brand)) %>% filter(brand != "UNKNOWN") %>%
    group_by(month) %>%
    summarise(n_disp_brand = n_distinct(brand[type == "Disposable" & mL_sum > 0]), .groups = "drop")
  d1 <- s %>% transmute(month, `e-cig stores` = n_store_ec, `distinct e-cig UPCs` = n_upc_ec) %>%
    left_join(nb %>% transmute(month, `disposable brand-codes` = n_disp_brand), by = "month") %>%
    filter(month >= as.Date("2018-01-01")) %>%
    pivot_longer(-month) %>%
    group_by(name) %>%
    mutate(idx = 100 * value / mean(value[year(month) == 2019])) %>% ungroup()
  seam <- as.Date("2021-01-01")
  p1 <- ggplot(d1, aes(month, idx, color = name)) +
    geom_vline(xintercept = seam, color = "grey30", linewidth = 0.5) +
    annotate("text", x = seam, y = max(d1$idx), label = "  Nielsen extract seam (Jan 2021)",
             hjust = 0, vjust = 1, size = 3, color = "grey30") +
    event_vlines() + geom_line(linewidth = 0.9) +
    scale_color_manual(values = c("e-cig stores" = BLUE, "distinct e-cig UPCs" = GREEN,
                                  "disposable brand-codes" = RED)) +
    labs(title = "RMS e-cigarettes: stores vs. UPC and disposable-brand counts (2019 = 100)",
         subtitle = "Store panel halves at the Feb-2020 enforcement; UPC and brand counts step up at the Jan-2021 data seam, with no new stores.",
         x = NULL, y = "index (2019 = 100)", color = NULL, caption = event_caption) +
    theme_note + theme(plot.caption = element_text(hjust = 0, size = 8, color = "grey40"))
  save_plot(p1, "entry_stores_vs_brands", w = 9.5, h = 5.5)

  ## first-tracked-month footprint of the cohort brands
  td <- cache$target_detail
  td$brand <- cache$ubrand$brand[match(td$upc12, cache$ubrand$upc12)]
  bmn <- as_tibble(td) %>% group_by(brand, year_month) %>%
    summarise(units = sum(units), store_upc_months = sum(n_store),
              n_states = max(n_states), .groups = "drop")
  fp <- bmn %>% group_by(brand) %>% slice_min(year_month, n = 1, with_ties = FALSE) %>% ungroup()
  cat("\n=== first-tracked-month footprint, 2021/2022 cohorts (by states in month 1) ===\n")
  print(fp %>% arrange(desc(n_states)) %>% as.data.frame(), row.names = FALSE)
}

cat("\nfigures ->", out_dir, "\n")
