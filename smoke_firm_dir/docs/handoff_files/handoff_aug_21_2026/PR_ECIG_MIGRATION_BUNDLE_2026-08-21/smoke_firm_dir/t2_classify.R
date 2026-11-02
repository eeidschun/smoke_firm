## ============================================================================
## T2 product-type classifier for the e-cigarette panel.
##
## Taxonomy (T2): every e-liquid-bearing UPC-row is assigned to one of
##   - "Closed pod"  : pre-filled, sealed pod/cartridge that snaps onto a
##                     REUSABLE battery. Manufacturer fixes the nicotine.
##                     (VUSE Alto, JUUL, NJOY Ace, Logic, MarkTen, my|blu, ...)
##   - "Disposable"  : single integrated single-use unit (battery + juice in
##                     one sealed body), thrown away when spent. Manufacturer
##                     fixes the nicotine, typically at the ~5% ceiling.
##                     (old cigalike sticks: BLU/NJOY Daily; modern big bars:
##                      BREEZE, HYPPE, HQD, Juicy Bar, Esco, ...)
##   - "Open refill" : bottled e-liquid or open/refillable tank where the
##                     CONSUMER chooses and can step down nicotine.
##                     (HAUS, Halo, SMOK/Aspire tanks, ...)
##
## Why T2 (vs. Nielsen's Disposable/Refill/Starter Kit): the three classes are
## homogeneous in the firm's nicotine + price decision problem (who sets the
## nicotine, and the pricing/cost structure), which is what the supply model
## needs. See project notes. Nielsen's `product_type` is (a) ~43-53% missing on
## mL in 2022-2023 and (b) conceptually inconsistent (its "Disposable" is only
## the OLD small sticks; modern big disposables are unlabeled or land in
## "Refill"; and "Refill" mixes closed pods with open e-liquid).
##
## METHOD = M3 (hybrid, validated):
##   * primary signal is the always-populated STRUCTURE: num_cartridges_f
##     (a multipack of sealed pods => closed pod; a single integrated unit =>
##     disposable/open) plus liq_cart_f / nic_mg_per_ml_f fingerprints;
##   * a small hand-curated BRAND dictionary and form-word KEYWORDS resolve the
##     one genuinely ambiguous cell (single large-capacity unit: modern
##     disposable vs. open bottle);
##   * `validate_t2()` (see build_t2_panel.R) measures accuracy against the
##     Nielsen labels where they exist, and reports how much mass rests on the
##     weak fallback tiers.
##
## IMPORTANT data quirk this encodes: the Nielsen `product_descr` template is
##   "<BRAND> <LINE> ... ELECTRONIC CIGARETTE LIQUID POD ..."
## and is often truncated ("LIQUID PO"). So the word "LIQUID" is BOILERPLATE
## that appears on closed pods AND disposables alike -- it is NOT an
## open-system signal and must never be used as one. Open detection relies on
## real open words (BOTTLE / JUICE / TANK / VIAL) and open brands only.
## ============================================================================

## ---- dictionaries (external product knowledge; tie-breakers) ----------------
## Brands that are (near-)exclusively ONE form factor. Ambiguous multi-form
## brands (BLU, VUSE, NJOY, FINITI, Logic sell more than one form) are
## deliberately left OUT so the structural signal decides them per-SKU.
T2_POD_BRANDS  <- c("JUUL","VUSE ALTO","VUSE VIBE","VUSE CIRO","VUSE SOLO","MARKTEN",
                    "LOGIC POWER","LOGIC PRO","MY BLU","MYBLU","21ST CENTURY","21SCS",
                    "LEAP","NJOY ACE","NJOY POD")
T2_DISP_BRANDS <- c("HYPPE","BREEZE","LOON","HQD","STAGBAR","STAG BAR","JUICY BAR","JUICY",
                    "ESCO","ZEO","IGNITE","AVATA","ELF BAR","ELFBAR","PUFF BAR","FLUM",
                    "GEEK BAR","LOST MARY","BANG","MOJO","MNGO","FUME","CALI","AIR BAR",
                    "KANGVAPE","NEXA","EBDESIGN","EB DESIGN","NJOY DAILY","VAPES BAR",
                    "STIIIZY")
T2_OPEN_BRANDS <- c("HAUS","HALO","NICOTEK","VAPIN PLUS","SMOK","ASPIRE","INNOKIN",
                    "KANGER","JOYETECH","NAKED","VAPORFI","BLACK NOTE","MISTIC E","FINITI")

## Form-word keywords (matched on brand + product_descr, upper-cased).
T2_POD_KW  <- "\\bPOD|CARTRIDGE|CRTRD|CARTOMIZER|\\bCART\\b|\\bCTR\\b|CAPSULE|ECLE|ECGLC|E-CGAC|EVPC"
T2_DISP_KW <- "DISPOSABLE|\\bDISP\\b"
## Genuine open-system words ONLY. "LIQUID" is intentionally excluded (see header).
T2_OPEN_KW <- "BOTTLE|\\bBTL\\b|E-JUICE|EJUICE|\\bJUICE\\b|\\bVIAL\\b|\\bTANK\\b|DRIP|SUB[- ]?OHM"

.t2_anyx <- function(txt, pats) Reduce(`|`, lapply(pats, function(p)
              grepl(p, txt, ignore.case = TRUE, perl = TRUE)))

## ---- classifier ------------------------------------------------------------
## Input : a data.frame with columns brand_descr_f, product_descr,
##         num_cartridges_f, liq_total_f, liq_cart_f, nic_mg_per_ml_f.
## Output: a tibble with
##         $type : the T2 class
##         $tier : which rule fired (for the confidence/validation report)
## Set `use_brand = FALSE` for the held-out test (structure + keywords only).
classify_t2 <- function(df, use_brand = TRUE) {
  b   <- toupper(dplyr::coalesce(df$brand_descr_f, ""))
  d   <- toupper(dplyr::coalesce(df$product_descr, ""))
  bd  <- paste(b, d)
  carts <- df$num_cartridges_f
  mL    <- df$liq_total_f
  mlc   <- df$liq_cart_f
  nic   <- df$nic_mg_per_ml_f

  has_pod  <- grepl(T2_POD_KW,  bd, perl = TRUE)
  has_disp <- grepl(T2_DISP_KW, bd, perl = TRUE) | (use_brand & .t2_anyx(b, T2_DISP_BRANDS))
  open_sig <- grepl(T2_OPEN_KW, bd, perl = TRUE) | (use_brand & .t2_anyx(b, T2_OPEN_BRANDS))
  pod_br   <- use_brand & .t2_anyx(b, T2_POD_BRANDS)
  ## bottled-juice fingerprint: a SINGLE large-capacity (>=5 mL) unit with modest
  ## nicotine (<40 mg/mL, i.e. below the disposable salt-nic ceiling) that isn't a
  ## known disposable -> most likely an open e-liquid bottle. carts must be exactly
  ## 1 (not NA) so mis-recorded rows don't leak in.
  open_fp  <- !is.na(carts) & carts == 1 & !is.na(mlc) & mlc >= 5 &
              !is.na(nic) & nic < 40 & !has_disp

  type <- rep(NA_character_, nrow(df))
  tier <- rep(NA_character_, nrow(df))
  set <- function(mask, ty, tr) {          # tr may be scalar or a full-length vector
    m <- is.na(type) & mask
    type[m] <<- ty
    tier[m] <<- if (length(tr) == 1L) tr else tr[m]
  }
  ## 1. DISPOSABLE (explicit): a disposable keyword or disposable-only brand wins
  ##    outright -- even in a multipack (carts>=2) -- so it is not stolen by the
  ##    closed-pod or open rules below.
  set(has_disp, "Disposable", "disp_kw/brand")
  ## 2. OPEN: real open word / open brand / bottle fingerprint, and not a pod pack
  set((open_sig | open_fp) & !has_pod & !pod_br & (is.na(carts) | carts < 2),
      "Open refill", ifelse(open_sig, "open_kw/brand", "open_fingerprint"))
  ## 3. CLOSED POD: multipack prefilled, pod/cartridge keyword, or pod brand
  set(!is.na(carts) & carts >= 2, "Closed pod", "carts>=2")
  set(has_pod,                    "Closed pod", "pod_keyword")
  set(pod_br,                     "Closed pod", "pod_brand")
  ## 4. DISPOSABLE (structural): a single integrated unit with no pod signal
  set(!is.na(carts) & carts == 1,        "Disposable", "single_unit(carts==1)")
  ## 5. residual fallbacks (carts NA & no other signal)
  set(!is.na(mL) & mL >= 4, "Disposable", "fallback_size>=4")
  set(rep(TRUE, length(type)), "Closed pod", "fallback_default")

  tibble::tibble(type = type, tier = tier)
}
