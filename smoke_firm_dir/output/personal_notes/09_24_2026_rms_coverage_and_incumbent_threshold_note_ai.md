---
title: "RMS Coverage vs. Outside Market Shares, and the Share-Threshold Incumbent Definition"
subtitle: "Open decision, deferred: noted 2026-09-24"
date: "2026"
geometry: margin=1in
fontsize: 11pt
---

## 1. The question

For the nested-logit demand side, I'm considering redefining an "incumbent" as any
firm with more than 10% (or 15%) of the annual mL market share, replacing the
annual top 5. The shares below use the same subsetting as `supply_model_state`:
UPC-months with at least 3 stores, UNKNOWN brand excluded, and shares taken among
identified brands.

- **Above 10%:** 2 to 5 firms per year (3 in every year from 2018 on). NJOY is the
  only firm that leaves and comes back: incumbent 2015 to 2017, out in 2018 (7.6%),
  back 2019 to 2023. Every other firm has a single unbroken spell. The big turnover
  is 2017 to 2018: BLU, MISTIC and LOGIC fall out, and JUUL, VUSE and MARKTEN come in.
- **Above 15%:** 1 to 4 firms per year. NJOY again leaves and comes back (2016 to
  2017, out in 2018, back 2019 to 2021), then sits near the line at 12.9% to 16.1%
  from 2021 to 2023. FINITI (2014) and LOGIC (2017) are incumbents for one year only.

The concern is how to model F_a for a firm that goes incumbent, then fringe, then
incumbent again.

## 2. Sanity check against an outside source

The outside source reports 2013 dollar shares from Nielsen Convenience Track plus
All Outlets Combined: Blu 44.1%, NJOY 24.3%, Logic 12.5%, 21st Century Smoke 5.8%,
implying a total market of about $636M.

Our Kilts RMS 2013 dollar shares (all brands, no store-count filter):

| Brand | Outside source | RMS, dollars | RMS, mL |
|---|---|---|---|
| Blu | 44.1% | 66.7% | 56.0% |
| NJOY | 24.3% | 8.6% | 8.5% |
| Logic | 12.5% | 1.0% | 3.3% |
| 21st Century Smoke | 5.8% | 6.5% | 9.2% |
| Total | ~$636M | $116M | |

**Measuring in dollars instead of mL does not explain the gap.** NJOY is about 8.5%
in RMS either way. NJOY's UPC mapping and prices look fine.

**The likely cause is store coverage.** Convenience Track includes independent and
chain convenience stores, and uses field audits for stores without scanners. Kilts
RMS only has stores from retailers that share scanner data, so its convenience
sample is thin and chain-heavy. NJOY and Logic sold mainly through convenience
stores, while Blu (Lorillard) was also strong in grocery and drug stores. This fits
the pattern: Blu is overstated in RMS, NJOY and Logic are understated, and the RMS
market is about 5.5 times smaller. The bias is probably largest in 2013 to 2016.

**The RMS e-cig store sample also moves a lot over time:**

| Period | Stores selling e-cigs per month |
|---|---|
| 2013 | 16.6k to 20.4k |
| 2017 | about 16k |
| 2018 | 27.7k to 29.0k |
| 2021 to 2023 | about 12k |

NJOY's 2018 drop below the threshold happens in the same year the store count
jumps, so it may be caused by the sample changing rather than by NJOY.

## 3. Would a balanced store panel fix it?

**Probably not for matching the outside level.** A balanced panel removes
share changes caused by stores entering and leaving the sample, such as the 2018
jump. But it can only drop stores, not add the missing convenience stores. It could
even make the channel bias worse if convenience chains are the retailers that churn
in and out of RMS.

A balanced panel is still worth testing, to see whether NJOY's 2018 dip holds up
with a fixed set of stores.

**What would move the shares toward the outside level is reweighting by channel.**
Pull the Kilts stores file, which has `channel_code`, from the SCC. It is not in
the repo, and the raw `full_*` files have no channel variable. Merge it on
`store_code_uc`, compute brand shares within each channel, and reweight them using
outside channel shares.

## 4. Options when I come back to this

1. Keep RMS shares, and state that the market being modeled is the RMS-tracked
   market. This is internally consistent for the demand side.
2. Anchor the early-year (2013 to 2016) incumbent set to outside sources. Under
   that, NJOY is likely an incumbent from 2013, and its 2018 exit and re-entry
   probably goes away. Use RMS shares only from the years where coverage is steadier.
3. Run the balanced-panel check to see whether NJOY's 2018 dip is caused by the
   change in the store sample.
4. Get `channel_code` from the SCC and reweight by channel.

**Status:** decision deferred.
