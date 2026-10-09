# Cartridge-count review: 17 flagged UPCs

Edit `upc_cartridge_review.csv` (unresolved rows only); use `nearby_upc_candidates.csv` for comparison. Completed count-and-volume decisions are retained in `upc_cartridge_review_completed.csv`. The table below and candidate file retain the original 17-UPC screening set. Import UPC columns as TEXT in Excel to preserve leading zeros. Blank decision fields are intentional.

Scope: UPCs with positive imputed pack volume and missing cartridge count in the existing imputation review, appearing in the incumbent demand sample (positive units/mL, known brand, at least 3 stores). This is a screening list, not a complete size-coverage audit.

Available attributes come from the existing raw-attribute imputation cache and explicit manual UPC overrides. They have not been re-audited against every annual raw file. Multiple values are separated by semicolons; do not treat conflicts as resolved. Cache values can predate corrections.

Candidates: up to five other UPCs with a populated count sharing at least eight leading digits, ranked by longest common prefix then numerical distance. Similar digits are search clues, not proof of matching pack size. Candidate values are not applied to targets.

Record the exact product/pack evidence, count, confidence, and any correction needed to imputed total mL. Refill bottles require a separate product-type decision. No demand panels or regressions have been changed.

| Brand | UPC | Product description | Imputed pack mL | Existing count clues |
|---|---|---|---:|---|
| FINITI | `085962600262` |  | 3 | 3 |
| JUUL | `081991301137` |  | 2.8 | 4 |
| JUUL | `081991301269` | JUUL SMOKING ALTERNATIVE PRODUCT ELECTRONIC CIGARETTE CARTRIDGE CLASSIC TOBACCO THE ALTERNATIVE FOR ADULT SMOK BOX 4 COUNT; JUUL SMOKING ALTERNATIVE PRODUCT ELECTRONIC CIGARETTE LIQUID PO CLASSIC TOBACCO THE ALTERNATIVE FOR ADULT SMOK BOX 4 COUNT | 2.8 | 4 |
| JUUL | `081991301543` |  | 1.4 | none in cache |
| MISTIC | `085570400806` |  | 10 | none in cache |
| MISTIC | `085570400807` |  | 10 | none in cache |
| NJOY | `081068701483` | NJOY ACE SMOKING ALTERNATIVE PRODUCT ELECTRONIC CIGARETTE CARTRIDGE CLASSIC TOBACCO BOX 2 COUNT; NJOY ACE SMOKING ALTERNATIVE PRODUCT ELECTRONIC CIGARETTE LIQUID PO CLASSIC TOBACCO BOX 2 COUNT | 3.8 | 2 |
| VUSE | `084920501532` |  | 3.8 | 2 |
| VUSE | `084920501535` |  | 3.8 | 2 |
| VUSE | `084920501544` |  | 3.8 | 2 |
| VUSE | `084920501547` |  | 3.8 | 2 |
| VUSE | `084920501622` |  | 3.6 | none in cache |
| VUSE | `084920501712` | VUSE VIBE SMOKING ALTERNATIVE PRODUCT LIQUID VAPORIZER PEN ORIGINAL BOX 1 COUNT; VUSE VIBE SMOKING ALTERNATIVE PRODUCT ORIGINAL 1 COUNT | 1.9 | 1 |
| VUSE | `084920501793` |  | 3.6 | none in cache |
| VUSE | `084920501808` |  | 1.8 | none in cache |
| VUSE | `084920501811` |  | 1.8 | none in cache |
| VUSE | `084920502165` |  | 1.8 | none in cache |


## User decisions received

All 17 screening rows now have count and volume decisions in `upc_cartridge_review_completed.csv`; the pending CSV contains only its header. Completed means decisions entered, not independently verified. Original imputed and cached attributes are retained unchanged; user corrections are in decision columns. No canonical panel has been rebuilt.

User approved transferring the JUUL information cited under source identifier 819913015434 to original target UPC 081991301543; retain the original UPC. User explicitly selected 1.5 mL per disposable for both MISTIC UPCs; the approximate 1.5-2.0 mL source range remains provenance only. Pack-volume changes are JUUL 081991301543: 1.4 to 0.7 mL; MISTIC 085570400806 and 085570400807: 10 to 1.5 mL each. These changes would also affect volume-based shares and prices when applied upstream.


## Rebuild completed 2026-10-08

The reviewed corrections have now been applied to canonical retail volumes, nicotine quantities and demand inputs. The earlier notes describing them as unapplied record the review stage. All reviewed pack-volume identities now agree with the rebuilt panel (the discrepancy CSV is empty). The NCP input is unchanged. BLU UPC 088796900752 remains unresolved in 2018; the 12 affected firm-months are explicitly excluded from matched size/variety and market-size comparisons.
