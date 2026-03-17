# MarketMan Staging & Mapping Audit

**Date:** 2026-03-04
**Test org:** `20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57` (KUDU, 3 stores, int_marketman001)
**Scope:** 17 staging steps, 22 entity mappings, 34 DL tables — full DL-to-Data Vault data flow
**Method:** 3-agent parallel audit via MCP queries against live data

---

## Summary

| Severity | Count | Analytics impact |
|----------|-------|------------------|
| CRITICAL | 8 | 5 core analytics capabilities non-functional |
| HIGH | 8 | Significant data quality gaps |
| MEDIUM | 7 | Minor gaps and missing data |
| LOW | 4 | Cosmetic / expected behaviour |

### Non-Functional Analytics (this org)

1. **Occasion dimension** — 100% broken (C1)
2. **Product-to-ingredient cost mapping** — 100% broken (C2)
3. **Inventory item hierarchy** — 100% broken (C3)
4. **Inventory usage/variance reporting** — 67% incomplete (C4) + meaningless (C7/H8)
5. **Sales-to-product resolution** — 55% broken (H1)

### Root Cause Split

- **Code bugs (fixable):** C1, C2, C3, C5, C6, H2, H5, H7
- **Data/API gaps (client or config issue):** C4, C7, C8, H1, H8

---

## CRITICAL Issues

### C1 — OCCASION hub never populated: 100% orphan rate on all occasion links

**Affected links:** LNK_CUSTORDER_OCCASION (927 rows), LNK_LINEITEM_OCCASION (927 rows), LNK_LOCATION_OCCASION_PRODUCT (315 rows), LNK_INVITEM_LOCATION_OCCASION_PRODUCT (315 rows) — 2,484 total orphan rows.

**Root cause:** OCC_ID is hardcoded to the string `'-999'` in MMAN_PRODUCT and MMAN_LINEITEM staging queries. `SHA256Hash('-999')` produces a hash that does not match the platform sentinel `CONVERT(BINARY(32), -999)`. HUB_OCCASION has 0 rows — the OCCASION hub is never populated from MarketMan data (no MarketMan endpoint provides occasion data).

**Impact:** Every occasion-linked join fails. F_PRODUCT_MARGIN_DAY and other presentation tables that traverse OCCASION return no data.

**Category:** Code bug (sentinel mismatch) + design gap (no occasion source)

---

### C2 — INVITEM hash collapse: all 315 product-to-ingredient links are orphaned

**Affected tables:** LNK_INVITEM_LOCATION_OCCASION_PRODUCT (315 rows, 100% INVITEM orphan rate), SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT (315 rows, UOM/UOM_VALUE 100% NULL).

**Root cause chain:**
1. `MMAN_PRODUCT` LEFT JOINs `DL_MENU_ITEMS_SUBITEMS` for recipe ingredients
2. `DL_MENU_ITEMS_SUBITEMS` has only 6 rows, all from store `872cf...` (Kudu Staff)
3. Price filter `WHERE CAST(MenuItemPrice AS NUMERIC) != 0` eliminates store `872cf...` (all prices = 0)
4. Only store `9dbec...` (KUDU Collective, 315 products) survives — which has 0 sub-item rows
5. LEFT JOIN returns NULL for all recipe columns
6. `CONCAT_WS('-', NULL, NULL)` = `''` → `SHA256Hash('')` = single constant hash for all 315 rows
7. That hash does not exist in HUB_INVITEM

**Impact:** Product-to-ingredient mapping is 100% broken. Cost-of-sales analysis impossible. All 315 LNK_INVITEM_LOCATION_OCCASION_PRODUCT rows point to a phantom INVITEM.

**Category:** Code bug (LEFT JOIN design — should be split or filtered) + data gap (client hasn't configured recipes for main store)

---

### C3 — SAT_INVITEM.PARENT_ID stores raw string, not BINARY(32) hash

**Affected tables:** SAT_INVITEM (3,866 rows), all downstream hierarchy queries.

**Root cause:** The INVITEM entity mapping maps `PARENT_ID` from `MMAN_INVITEMS` into `SAT_INVITEM.PARENT_ID`. The staging query stores the source composite key string (e.g. `"9dbec6a3992f40bd84b247f474c851f5-583815"`), but `HUB_INVITEM.HUB_ID` is `BINARY(32)` (a SHA-256 hash of that same string). The types are incompatible — JOINs always fail.

**Evidence:** 3,860/3,866 SAT rows have non-NULL PARENT_ID. Zero of these resolve to a HUB_INVITEM.HUB_ID when joined. The PARENT_ID column is NVARCHAR but the hub key is BINARY(32).

**Impact:** INVITEM category hierarchy completely broken. D_INVITEM dimension hierarchy cannot be built. All inventory dimension reporting that traverses parent/child categories fails.

**Category:** Code bug — PARENT_ID should be hashed before storage, or the mapping should use `hash=1` on the parent column.

**Note:** This issue was NOT in the previously known bugs list. New finding.

---

### C4 — LNK_INVITEM_INVREPORT: 66.6% INVITEM orphan rate

**Affected tables:** LNK_INVITEM_INVREPORT (21,234 rows; 14,154 orphans on INVITEM_HUB_ID).

**Root cause:** MMAN_REPORT for store `ed84c...` (KUDU HQ) references 2,023 ItemIDs via `DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS`. Only 1 of those items matches an item in `MMAN_INVITEMS` for that store. The ActualVsTheo API endpoint returns items that were never fetched by the inventory items endpoint for KUDU HQ — an API endpoint coverage gap.

**Evidence:** 2,022 distinct INVITEM_HUB_IDs in the link have no matching HUB_INVITEM row. Almost all orphans are from KUDU HQ store.

**Impact:** 2/3 of inventory report records cannot be joined to their ingredient. F_INV_USAGE_DAY and F_INV_COUNTS_DAY metrics are severely incomplete for KUDU HQ.

**Category:** Data/API gap — the client's MarketMan configuration doesn't sync inventory items for KUDU HQ.

---

### C5 — REPORT_ID CONCAT_WS separator bug + non-unique key

**Affected tables:** MMAN_REPORT (staging), HUB_INVREPORT (DV).

**Root cause (separator bug):** The staging query constructs REPORT_ID as:
```sql
CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.storeId, REP.ItemID)
```
The FIRST argument to `CONCAT_WS` is the separator, not a value. This uses the DATETIME2 date as the separator between storeId and ItemID. The date does not appear as a standalone field — it's the glue. Should be:
```sql
CONCAT_WS('-', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.storeId, REP.ItemID)
```

**Root cause (duplicates):** 7 rows in `DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS` have NULL ItemID (all from store `872cf...`). NULL values are dropped by CONCAT_WS, producing identical REPORT_IDs for different rows. 21,240 total rows but only 21,234 distinct REPORT_IDs — 6 duplicate pairs.

**Impact:** Non-unique INVREPORT hub key. Duplicate hub records or silent satellite overwrites.

**Category:** Code bug (both the separator misuse and the NULL-ItemID collision).

**Note:** New finding — not in previously known bugs list.

---

### C6 — MMAN_WASTE_EVENTS drops 81% of event rows

**Affected tables:** MMAN_WASTE_EVENTS (staging), MMAN_STOCKEVENT downstream.

**Root cause:** The JOIN condition `WE.[BuyerGuid] = WEI.[storeId]` requires BuyerGuid to match the waste event line's storeId. 17 of 21 DL_WASTE_EVENTS rows have NULL BuyerGuid. NULL = anything is never true, so those rows never match any lines. Only 4 rows (2 events x 2 stores) with non-NULL BuyerGuid survive the JOIN.

**Evidence:** 21 DL_WASTE_EVENTS rows → 17 staged rows (from 4 surviving event headers). 17/21 event headers silently discarded.

**Impact:** Waste tracking severely undercounted. STOCKEVENT only has 17 waste rows when there should be many more. Inventory reconciliation impossible.

**Category:** Code bug — should handle NULL BuyerGuid (either COALESCE to storeId or use a different join strategy).

---

### C7 — MMAN_SALES produces 0 rows

**Affected tables:** MMAN_SALES (staging), MMAN_STOCKEVENT SALE branch (DV).

**Root cause:** `MMAN_SALES` INNER JOINs `DL_MENU_PROFITABILITY` to `DL_MENU_ITEMS_SUBITEMS` (for recipe ingredient expansion). DL_MENU_ITEMS_SUBITEMS has only 6 rows, all from store `872cf...` (Kudu Staff). The profitability data is almost entirely from store `9dbec...` (KUDU Collective) which has 0 sub-item rows. INNER JOIN produces 0 matches.

**Impact:** Zero sales depletion data in STOCKEVENT. Actual-vs-theoretical variance shows -100% for all items with any actual usage. Sales-driven inventory consumption is completely unmeasured.

**Category:** Data/API gap — same root cause as C2 (recipe data absent for production store).

---

### C8 — Production pipeline non-functional

**Affected tables:** MMAN_PRE_PRODUCTION, MMAN_PROD_EVENTS (both staging), MMAN_STOCKEVENT PRODUCTION branch.

**Root cause:** All 21 rows in DL_PRODUCTION_EVENTS have NULL EventID. 7 rows have `IsSuccess = '0'` with error message "Buyer cant be chain manager" (API permission issue). 14 rows have `IsSuccess = '1'` but still NULL EventID. The INNER JOIN `PE.EventID = pi.EventID` on NULL = NULL produces no matches (NULL != NULL in SQL).

**Evidence:** MMAN_PRE_PRODUCTION = 0 rows. MMAN_PROD_EVENTS = 0 rows. DL_PRODUCTION_EVENTS_PRODUCTIONITEMS = 0 rows.

**Impact:** Zero production data in the data vault. Production-related STOCKEVENT entries are completely absent.

**Category:** Data/API gap — MarketMan API permission error preventing event ID retrieval.

---

## HIGH Issues

### H1 — LNK_LINEITEM_PRODUCT: 55.4% PRODUCT orphan rate

**Evidence:** 514/927 link rows have PRODUCT_HUB_ID that doesn't exist in HUB_PRODUCT. 125 distinct PosCodes appear in MMAN_LINEITEM that don't exist in MMAN_PRODUCT (MMAN_PRODUCT has 315 rows; MMAN_LINEITEM has 254 distinct PosCodes — 125 are unmatched).

**Root cause:** MMAN_PRODUCT requires an INNER JOIN to DL_MENU_PROFITABILITY (only 4,039 rows across 3 stores, heavily skewed to `9dbec...`) AND a price filter `MenuItemPrice != 0`. Products that have sales (appear in profitability) but fail the JOIN or price filter are in MMAN_LINEITEM but not in MMAN_PRODUCT.

**Impact:** Over half of line items can't join to their product. Sales-by-product reporting > 50% incomplete.

---

### H2 — PRE_INVOICE + PRE_ORDEREVENT fan-out from duplicate purchaseitems

**Evidence:** 10 (VendorName, CatalogItemCode, storeId) combinations in DL_INVENTORY_ITEMS_PURCHASEITEMS have 2 rows each. All from vendors: Billfields of London, Drink Warehouse, Seckford Wines, Woods Food Service Ltd.

**Impact:** 4 duplicate invoice rows in MMAN_PRE_INVOICE, 2 duplicate order rows in MMAN_PRE_ORDEREVENT. The GROUP BY includes `ipi.ID` so duplicates are not collapsed.

---

### H3 — MMAN_STOCKORDER: 7 NULL ORDER_SRC_KEY rows + no deduplication

**Evidence:** 157 stage rows but only 75 distinct OrderNumbers. Each order appears ~2x (multi-store fetch: 3 stores x orders). 7 rows have completely NULL ORDER_SRC_KEY, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_STATUS.

**Impact:** 1 phantom HUB_STOCKORDER record from NULL hash key. Duplicate processing cycles (CDC handles dedup but wastes resources).

---

### H4 — SUPPLIER keyed on Name string: 3 duplicate vendor names

**Evidence:** Vendors "Allan Reeder Ltd", "BELAZU ", "NATOORA" each appear with 2 different Guids in DL_VENDORS but collapse to 1 HUB_SUPPLIER record (Name is the hash key, not Guid).

**Impact:** Distinct vendor entities silently merged. Supplier-level reporting conflates different vendors sharing a name.

---

### H5 — MMAN_INVITEMS: category rows have NULL storeId causing 1 duplicate INVITEM_ID

**Evidence:** All 118 category rows (BOTTOM_LEVEL=0) have storeId = NULL (by design in the SELECT). CONCAT_WS with NULL storeId collapses to just CategoryID. When two categories have NULL COGSCategoryID from different sources, they produce the same empty-string key. 1 confirmed duplicate pair.

**Impact:** Duplicate INVITEM hub key. Minor category hierarchy corruption.

---

### H6 — MMAN_TRANSFERS: 2 incoming items unmatched by cross-store name

**Evidence:** Outgoing branch: 24 line events. Incoming branch: 22 line events. The incoming branch uses a double JOIN to DL_INVENTORY_ITEMS matching by item Name between the sender and receiver stores. 2 items sent from KUDU Collective have no matching name in Kudu Staff's inventory.

**Impact:** Transfer-in movements undercounted. Outgoing != incoming for 2 items — inventory balance discrepancy.

---

### H7 — MMAN_PREP_RECIPES: 3x row inflation from multi-fetch

**Evidence:** DL_INVENTORY_PREPS_SUBITEMS has 4,167 source rows but stages as 12,501 rows. The same recipes are fetched across multiple INT_FETCH_DATE values (7 fetch dates). No deduplication in the staging query.

**Impact:** LNK_INVITEM_INVITEM has 4,164 rows (CDC dedup partially works) but the bloated staging table wastes processing. The ~1,110 actual recipe relationships are represented 3x.

---

### H8 — MMAN_REPORT: 98% of rows have zero Theoretical/Sales usage

**Evidence:** 20,907/21,240 report rows have zero SalesUsageInReportingUOM and TheoreticalUsageInReportingUOM. VariancePercent = -1.0 (-100%) for 755 rows where ActualUsage > 0 but Theoretical = 0.

**Impact:** Actual-vs-theoretical variance reporting is meaningless without recipe-driven sales consumption data. Cascades from C7 (MMAN_SALES = 0 rows).

**Category:** Data gap — consequence of missing recipe data.

---

## MEDIUM Issues

### M1 — LNK_INVITEM_INVITEM: 8% PARENT orphan rate

333/4,164 recipe link rows have PARENT_HUB_ID that doesn't resolve to HUB_INVITEM. 63 distinct parent IDs affected. Likely cause: prep recipe parents reference deleted or unfetched items.

### M2 — SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT: UOM and UOM_VALUE 100% NULL

Even if C2 (hash collapse) were fixed, the SAT_LNK attributes are empty because MMAN_PRODUCT has no sub-item UOM data for KUDU Collective. Recipe quantity-per-product data entirely missing.

### M3 — MMAN_LINEITEM: negative NET_VALUE and zero-price rows

1 row with negative NET_VALUE (-169, PosCode="PartialRefund", likely a refund/credit). GROSS_PRICE = 0 for the same row is suspicious. 85 additional rows have zero NET_PRICE.

### M4 — MMAN_VENDORS: SELECT DISTINCT produces 45 rows not 42

Non-key column variance (TaxLevelID etc.) between store copies of the same vendor prevents full deduplication. 3 vendor names appear twice in staging output despite having the same Name and Guid.

### M5 — SAT_INVITEM ATTR_1 through ATTR_4: 100% NULL

Maps to ParLevel, MinOrderQty, MaxOrderQty, DateRangeType. All NULL in source for this org. Inventory management thresholds unavailable.

### M6 — SAT_INVREPORT COUNT_FREQUENCY / COUNT_RECENCY: 100% NULL

DL_INVENTORY_COUNTS_LINES is empty (0 rows). The OUTER APPLY in MMAN_REPORT always returns NULL for AvgDaysBetweenCounts and DaysSinceLastCount.

### M7 — MMAN_STOCKEVENT invoice branch permanently commented out

The MMAN_PRE_INVOICE UNION branch in MMAN_STOCKEVENT is commented out. The ORDER dedup ROW_NUMBER (partitioned by SRC_KEY, EVENT_BEHANIOUR with priority_id ordering) serves no real purpose with only a single source (priority_id = 99 always wins). Only 2 true duplicates were deduped.

---

## LOW Issues

### L1 — Isolated orphans in INVITEM_STOCKEVENT / INVITEM_STOCKORDER

1 orphan in LNK_INVITEM_STOCKEVENT (0.2%), 2 orphans in LNK_INVITEM_STOCKORDER (0.3%). Historical deleted items referenced by events.

### L2 — SAT_STOCKEVENT EXTERNAL_REF: 11.6% NULL

63/541 stock events have no external reference. Expected for manual adjustments and transfers.

### L3 — DL_TRANSFERS stored 3x per transfer

Each transfer appears once per storeId (3 stores = 3 copies). The JOIN `BuyerFromGuid = storeId` correctly filters to sender's copy only. Expected API behaviour.

### L4 — 46 "Viewed by supplier" orders excluded from STOCKEVENT

These represent order commitments not yet fulfilled. Correctly excluded — only "Received" orders create inventory movements.

---

## Row Count Cross-Reference

### Staging Layer

| Step | Stage Table | DL Source Rows | Staged Rows | Notes |
|------|-------------|----------------|-------------|-------|
| 1 | MMAN_INVITEMS | 3,083 + 666 active | 3,867 | +133 synthesised category rows |
| 2 | MMAN_PRE_INVOICE | 734 doc items | 734 | 4 fan-out duplicates |
| 3 | MMAN_LOCATION | 3 | 3 | Clean |
| 4 | MMAN_PREP_RECIPES | 4,167 | 12,501 | 3x inflation (multi-fetch) |
| 5 | MMAN_PRE_ORDEREVENT | 674 | 676 | +2 fan-out, INNER JOIN risk |
| 6 | MMAN_PRODUCT | 2,263 (KUDU Collective) | 315 | Price filter + profitability JOIN |
| 7 | MMAN_PRE_PRODUCTION | 21 events / 0 items | 0 | API failure |
| 8 | MMAN_PROD_EVENTS | 0 items | 0 | Cascades from step 7 |
| 9 | MMAN_REPORT | 21,240 | 21,240 | 6 duplicate REPORT_IDs |
| 10 | MMAN_SALES | 927 eligible | 0 | INNER JOIN to empty subitems |
| 11 | MMAN_LINEITEM | 927 | 927 | 1 refund row, 85 zero-price |
| 12 | MMAN_PRE_STOCK_COUNT | 0 lines | 0 | DL count lines empty |
| 13 | MMAN_STOCKORDER | 157 | 157 | 7 NULL keys, no dedup |
| 14 | MMAN_TRANSFERS | 72 lines | 46 | 24 out + 22 in (2 unmatched) |
| 15 | MMAN_VENDORS | 126 | 45 | DISTINCT, 3 name dupes remain |
| 16 | MMAN_WASTE_EVENTS | 34 lines | 17 | 81% dropped (NULL BuyerGuid) |
| 17 | MMAN_STOCKEVENT | mixed | 541 | 478 order + 46 transfer + 17 waste |

### Data Vault Layer

| Hub | HUB Rows | SAT Rows | Key Link | Link Rows | Orphan Rate |
|-----|----------|----------|----------|-----------|-------------|
| CUSTORDER | 927 | 927 | CUSTORDER_LINEITEM | 927 | 0% |
| INVITEM | 3,866 | 3,866 | INVITEM_INVITEM | 4,164 | 8% parent |
| INVREPORT | 21,234 | 21,234 | INVITEM_INVREPORT | 21,234 | 66.6% invitem |
| LINEITEM | 927 | 927 | LINEITEM_PRODUCT | 927 | 55.4% product |
| LOCATION | 3 | 3 | CUSTORDER_LOCATION | 927 | 0% |
| PRODUCT | 315 | 315 | LOCATION_OCCASION_PRODUCT | 315 | 100% occasion |
| STOCKEVENT | 541 | 541 | INVITEM_STOCKEVENT | 541 | 0.2% |
| STOCKORDER | 76 | 76 | INVITEM_STOCKORDER | 676 | 0.3% |
| SUPPLIER | 42 | 42 | (no link mapped) | — | — |

### Unused DL Tables (8 tables land in DL but are never consumed by staging)

- `DL_CATEGORIES` — category data comes from COGS fields in DL_ACTUAL_VS_THEO instead
- `DL_BUYER_USERS` — no staging step
- `DL_TAX_LEVELS` — no staging step
- `DL_MENU_ITEMS_LOCATIONSYNCINFOS` — defined but never joined
- `DL_ORDERS_BY_SENTDATE_HISTORYLOG` — no staging step
- `DL_DOCS_BY_DATE_HISTORYLOG` — no staging step
- `DL_SALES_BY_DATE` — sales data comes from DL_MENU_PROFITABILITY instead
- `DL_SALES_BY_DATE_CATEGORYSUMMARIES` — same as above
