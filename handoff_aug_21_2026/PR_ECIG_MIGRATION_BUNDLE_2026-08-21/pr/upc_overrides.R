## ============================================================================
## Shared UPC / product overrides for the e-cigarette pipeline.
## Sourced by BOTH impute_missing_mL.R (fills MISSING mL) and build_t2_panel.R
## (applies to ALL rows: corrects labeled values, fills missing, drops non-e-liquid).
##
## Nicotine is entered as RAW concentration (mg/mL; 5% = 50). The panel's
## nic_yield_tot_f = YIELD_FACTOR * mL * mg/mL (0.68 is the intentional e-cig
## nicotine-amount -> yield factor from external research).
## ============================================================================

YIELD_FACTOR <- 0.68

## Line-pattern overrides (whole product families), matched on product_descr/line.
## liq_cart_f = mL per cartridge; nic_mg_per_ml RAW (NA -> impute from siblings).
MANUAL_OVERRIDES <- tibble::tribble(
  ~pattern,       ~brand,                ~liq_cart_f, ~nic_mg_per_ml, ~t2_type,
  "LOON AIR",     "MADURO DISTRIBUTORS", 8.5,         50,             "Disposable",
  "LOON MAXX",    "MADURO DISTRIBUTORS", 6.5,         50,             "Disposable",
  "POP HIT PRO",  "POP",                 1.2,         50,             "Disposable",
  "POP HIT",      "POP",                 1.2,         50,             "Disposable",
  "BIDI",         "BIDI",                1.4,         60,             "Disposable",
  "STAGBAR",      "STAGBAR",             13,          NA,             "Disposable"
)

## UPC-specific overrides (highest priority). Used to (a) fill missing mL for one
## SKU and (b) CORRECT wrong labeled values. num_cartridges = pack cart count, so
## liq_total = liq_cart_f * num_cartridges. nic_mg_per_ml RAW; NA -> keep the row's
## existing nicotine (correct mL only). Leading zeros are added automatically.
MANUAL_UPC_OVERRIDES <- tibble::tribble(
  ~upc,           ~brand,  ~liq_cart_f, ~num_cartridges, ~nic_mg_per_ml, ~t2_type,
  "84920501991",  "VUSE",  1.8,         2,               18,             "Closed pod",  # VUSE Alto
  "84920501967",  "VUSE",  1.8,         2,               18,             "Closed pod",  # VUSE Alto
  "84920501522",  "VUSE",  0.9,         3,               15,             "Closed pod",  # VUSE Ciro 1.5% pod
  "081505802044", "LOGIC", 1.5,         3,               18,             "Closed pod",  # Logic Pro capsule
  "081505802005", "LOGIC", 1.5,         3,               18,             "Closed pod",  # Logic Pro capsule
  ## --- corrections to WRONG labeled Nielsen rows (user-verified online) ---
  "084004820296", "JUUL",  0.7,         4,               30,             "Closed pod",  # 3% menthol 4-pk; was booked 0.7mL total/120mg -> real 2.8mL
  "081991301498", "JUUL",  0.7,         2,               30,             "Closed pod",  # 3% VA tobacco 2-pk; was 0.7mL total/60mg -> real 1.4mL
  "081991301288", "JUUL",  0.7,         4,               NA,             "Closed pod",  # assume 0.7mL/cart; total 2.8 already right, keep nic, fix cart split
  ## --- HAUS e-liquid dropper bottles (...007xx block), user-confirmed 30 mL / 4 mg
  ## Open refill. brand="HAUS" here; BRAND_RENAME folds it to MISTIC if that stays on. ---
  "085570400761", "HAUS", 30,           1,               4,              "Open refill", # HAUS Dark Ice
  "085570400760", "HAUS", 30,           1,               4,              "Open refill", # HAUS SCT
  "085570400864", "HAUS", 30,           1,               4,              "Open refill", # HAUS Cloud Punch
  "085570400795", "HAUS", 30,           1,               4,              "Open refill", # HAUS Sweet Voo Dew
  "085570400798", "HAUS", 30,           1,               4,              "Open refill", # HAUS Moon Milk
  "085570400757", "HAUS", 30,           1,               4,              "Open refill", # HAUS Zomberry
  "085570400754", "HAUS", 30,           1,               4,              "Open refill"  # HAUS Jam Session
)

## Brand renames applied pipeline-wide (after the brand cascade). HAUS is a
## sub-brand of Mistic ("HAUS by Mistic"), so fold it into MISTIC.
BRAND_RENAME <- tibble::tribble(
  ~from,   ~to,
  "HAUS",  "MISTIC"
)

## UPCs to DROP entirely (not e-liquid; misfiled into the e-cig module).
## Marlboro 009700000500/501/502 = Altria heated-tobacco (HeatSticks): 20 sticks
## per pack, no liquid, Altria prefix 009700, tagged "SMOKING ALTERNATIVE PRODUCT".
EXCLUDE_UPCS <- c(
  "009700000500", "009700000501", "009700000502",   # Altria heated-tobacco (HeatSticks)
  ## HAUS/Mistic tank & coil HARDWARE (form_descr = sub-ohm tank / coil / tank
  ## atomizer; no e-liquid). "RFL"/"E-CG LIQUID" HAUS SKUs are kept (they hold liquid).
  "085570400786",   # HAUS ESOT  - sub-ohm tank (starter kit)
  "085570400789",   # HAUS ECSOC - sub-ohm coil
  "085570400814",   # HAUS ECTA  - tank atomizer
  "085570400792"    # HAUS ECSOC/E-CG TANK 2PK - 2 coils (hardware), user-confirmed
)
