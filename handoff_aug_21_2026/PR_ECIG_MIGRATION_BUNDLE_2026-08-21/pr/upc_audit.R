## UPC audit for nicotine checking. Per (year, upc): brand, descr, num_cartridges,
## mL/cartridge, total capacity, cleaned label (mg/mL), delivered
## new vs old, mL share. Outputs top-5 per year PLUS appended implausible rows
## (cleaned label < 12 mg/mL & >=0.2% within-year share) for manual audit.
rm(list = ls()); suppressPackageStartupMessages({ library(tidyverse) })
firm_dir <- "pr"; input_dir <- file.path(firm_dir, "input")
out_dir <- file.path(firm_dir, "output", "prelim_analysis", "investment_proxy")
source(file.path(firm_dir, "upc_overrides.R"))   # YIELD_FACTOR, overrides, EXCLUDE
pad12 <- function(u) str_pad(as.character(u), 12, "left", "0")
upc_ov <- MANUAL_UPC_OVERRIDES %>% mutate(upc12=pad12(upc), ov_total=liq_cart_f*num_cartridges,
          ov_carts=num_cartridges,
          ov_nicyield=ifelse(!is.na(nic_mg_per_ml), ov_total*nic_mg_per_ml*YIELD_FACTOR, NA_real_)) %>%
          select(upc12, ov_total, ov_carts, ov_nicyield)
impmap_path <- file.path(input_dir, "missing_mL_imputation_map.rds")
impmap <- if (file.exists(impmap_path)) readRDS(impmap_path)$map %>% mutate(upc12=pad12(upc)) %>%
    select(upc12, map_mL=mL_total_imputed, map_nicyield=nic_yield_tot_imputed) else
    tibble(upc12=character(), map_mL=double(), map_nicyield=double())
exclude12 <- pad12(EXCLUDE_UPCS)
mcorr <- read_csv(file.path(input_dir, "manual_nic_corrections.csv"), show_col_types=FALSE) %>%
  mutate(upc12=pad12(upc12))
exclude12 <- union(exclude12, mcorr %>% filter(exclude == 1) %>% pull(upc12))
corr_lab <- mcorr %>% filter(is.na(exclude) | exclude == 0) %>%
  select(upc12, clabel=true_label_mg_per_ml, cmlcart=true_mL_per_cart)
load(file.path(input_dir, "label_maps.RData"))
escape_re <- function(x) gsub("([][{}()+*^$|\\\\?.])","\\\\\\1",x)
brx <- paste0("^(", paste(escape_re(label_maps$brand_vocab), collapse="|"), ")")
files <- list.files(input_dir, pattern="^full_.*7467.*\\.RData$", full.names=TRUE)
rows <- list()
for (f in files) {
  load(f); yr <- as.integer(str_extract(basename(f),"20\\d\\d"))
  x <- rms_w_attr %>% filter(prod_type=="ec", !is.na(units), units>0, !is.na(infl_mult), infl_mult>0) %>%
    mutate(upc12=pad12(upc)) %>% filter(!upc12 %in% exclude12) %>%
    left_join(upc_ov,by="upc12") %>% left_join(impmap,by="upc12") %>%
    mutate(liq_total_f=coalesce(ov_total,liq_total_f,map_mL),
           num_cartridges_f=coalesce(ov_carts,num_cartridges_f),
           nic_yield_tot_f=coalesce(ov_nicyield,nic_yield_tot_f,map_nicyield)) %>%
    filter(!is.na(nic_yield_tot_f), !is.na(liq_total_f), liq_total_f>0) %>%
    left_join(label_maps$upc_to_brand, by="upc")
  bf <- coalesce(x$brand_descr_f, x$brand_upc, str_extract(x$product_descr, brx))
  rn <- setNames(BRAND_RENAME$to, BRAND_RENAME$from)
  bf <- ifelse(!is.na(bf) & bf %in% names(rn), unname(rn[bf]), bf)
  x$brand <- coalesce(bf,"UNKNOWN")
  x <- x %>% left_join(corr_lab,by="upc12") %>%
    mutate(dU=toupper(product_descr),
           fam=case_when(brand=="VUSE"&grepl("CIRO",dU)~"ciro", brand=="VUSE"&grepl("VIBE",dU)~"vibe",
                         brand=="VUSE"&grepl("SOLO",dU)~"solo", TRUE~"o"),
           fam_mlcart=case_when(fam=="ciro"~0.9, fam=="vibe"~2.0, fam=="solo"~0.5, TRUE~NA_real_),
           fam_label=case_when(fam=="ciro"~15, fam=="vibe"~30, fam=="solo"~48, TRUE~NA_real_),
           liq_cart_corr=coalesce(cmlcart, fam_mlcart, liq_cart_f),
           liq_total_new=ifelse((!is.na(cmlcart) | !is.na(fam_mlcart)) & !is.na(num_cartridges_f),
                                liq_cart_corr*num_cartridges_f, liq_total_f),
           label_used=coalesce(clabel, fam_label, nic_mg_per_ml_f),
           nic_new=coalesce(liq_total_new*label_used*YIELD_FACTOR, nic_yield_tot_f))
  rows[[f]] <- x %>% group_by(year=yr, upc12, brand) %>%
    summarise(descr=first(product_descr),
              num_cart=round(weighted.mean(num_cartridges_f, units, na.rm=TRUE),1),
              mL_per_cart=round(weighted.mean(liq_cart_corr, units, na.rm=TRUE),2),
              cap_total_mL=round(weighted.mean(liq_total_new, units, na.rm=TRUE),2),
              label_mg_per_mL=round(weighted.mean(label_used, units, na.rm=TRUE),1),
              deliv_new=round(sum(units*nic_new)/sum(units*liq_total_new),1),
              deliv_old=round(sum(units*nic_yield_tot_f)/sum(units*liq_total_f),1),
              mL=sum(units*liq_total_new), .groups="drop")
  cat(yr,"done\n"); rm(rms_w_attr,x); gc(verbose=FALSE)
}
d <- bind_rows(rows) %>% group_by(year) %>% mutate(mL_share=round(100*mL/sum(mL),2)) %>% ungroup()
## full per-UPC table (mL_share>=0.02%) for future audits without another raw pass
write_csv(d %>% filter(mL_share>=0.02) %>% arrange(year, desc(mL)),
          file.path(out_dir, "all_upc_by_year.csv"))
top5 <- d %>% group_by(year) %>% slice_max(mL, n=5) %>% ungroup() %>% mutate(group="top5")
## implausible: implied label < 12 mg/mL (suspicious for nicotine), non-trivial volume,
## top 8 per year; mL_per_cart lets you tell a bugged pod (small) from a legit low-nic bottle (large)
impl <- d %>% anti_join(top5, by=c("year","upc12")) %>%
  filter(label_mg_per_mL < 12, mL_share >= 0.2) %>%
  group_by(year) %>% slice_max(mL, n=8) %>% ungroup() %>% mutate(group="implausible")
out <- bind_rows(top5, impl) %>% arrange(year, group, desc(mL_share)) %>%
  select(year, group, brand, upc12, num_cart, mL_per_cart, cap_total_mL,
         label_mg_per_mL, deliv_new, deliv_old, mL_share, descr)
write_csv(out, file.path(out_dir, "top5_upc_per_year.csv"))
cat("\nwrote top5_upc_per_year.csv:", nrow(out), "rows (",
    sum(out$group=="top5"), "top5 +", sum(out$group=="implausible"), "implausible )\n")
cat("\n=== IMPLAUSIBLE rows (cleaned label < 12 mg/mL, >=0.2% share) ===\n")
impl %>% arrange(year, desc(mL_share)) %>%
  transmute(year, brand, num_cart, mL_per_cart, label_mg_per_mL, mL_share, descr=substr(descr,1,40)) %>%
  as.data.frame() %>% print(row.names=FALSE)
