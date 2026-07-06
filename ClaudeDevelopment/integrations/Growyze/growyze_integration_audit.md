# Growyze Integration Audit Report

**Date:** 2026-03-18
**Scope:** Staging → Data Vault → Presentation → Visualisation layers
**Environment:** UAT (Padel Social — `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`)
**Cross-reference org:** Three Rocks Cafe (MarketMan — `20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4`)

---

## Executive Summary

The Growyze integration's **quantity pipeline is sound** — stock events (ORDER, SALE, WASTE, COUNT) flow correctly through staging → DV → presentation. The new stocktake COUNT events are fully wired and 2,095 rows exist in F_INV_COUNTS_DAY.

Three systemic issues require attention:

1. **Cost source gap (Critical):** UOM_COST is NULL for 100% of Growyze rows. The cost derivation CTE (InvLocCost) reads SAT_INVREPORT — a MarketMan-only entity. All monetary downstream calculations are zero.
2. **UOM value mismatch (Critical):** All UOM scaling uses `IN ('ml','g')` but MarketMan uses `'gr'` (not `'g'`). 8,800+ MarketMan rows display in raw grams instead of kg.
3. **Phantom hash records (High):** Five staging/load paths produce NULL key components that CONCAT_WS collapses into valid-looking but meaningless hashes, creating broken DV link records.

The visualisation layer is **functional but overfitted** to the Growyze+POS data model. Several queries assume F_INV_SALES_DAY has NET_SALES data (always zero for Growyze), and the D_PRODUCT hierarchy is flat for MarketMan (breaking category-based charts).

---

## 1. Staging Layer

### 1.1 Dedup Pattern Inconsistencies

The standard dedup pattern is `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC)`. Three steps deviate:

| Step | Pattern Used | Risk |
|---|---|---|
| Growyze DN Events (product lookup) | `ORDER BY id` (not LOADTS_UTC) | Stale product data selected if product updated |
| Growyze Prep Recipes | `DISTINCT` (no LOADTS ordering) | Non-deterministic UOM_VALUE if recipe ratio changes |
| Growyze Product InvItem | `DISTINCT` (no LOADTS ordering) | Same as Prep Recipes |
| Growyze Line Item (sales_agg) | `MIN()` aggregate | Weak dedup — doesn't guarantee latest fetch |

**Recommendation:** Standardise all dedup to `ROW_NUMBER() OVER (PARTITION BY {key} ORDER BY LOADTS_UTC DESC)`.

### 1.2 NULL Key Values Creating Phantom Hashes

CONCAT_WS skips NULLs rather than producing NULL, so `CONCAT_WS('|', NULL, 'int_growyze001')` = `'int_growyze001'` — a valid string that hashes to a real (but meaningless) hub record.

| Source | NULL Column | Affected Link | Rows |
|---|---|---|---|
| GRYZ_LINEITEM | PRODUCT_KEY (180 rows, unmatched posId) | LINEITEM_PRODUCT | 180 |
| GRYZ_PRODUCT | LOCATION_KEY + OCC_ID (category rows) | LOCATION_OCCASION_PRODUCT | ~7 |
| GRYZ_DN_EVENTS | ORDER_ID (278 DN rows with no PO) | STOCKEVENT_STOCKORDER | 278 |
| GRYZ_STOCKEVENT | itemId (1 waste row — Peppermint Tea) | INVITEM_STOCKEVENT | 1 |

**Recommendation:** Add `WHERE {key} IS NOT NULL` guards to each affected load step or staging SELECT.

### 1.3 INTERNAL_REF Semantic Inconsistency

INTERNAL_REF carries different values across event types:

| Event Type | INTERNAL_REF Contains | Should Contain |
|---|---|---|
| COUNT | Product ID | Product ID ✓ |
| SALE | Sale detail row ID | Product ID? |
| WASTE | Waste record ID | Product ID? |
| ORDER | Delivery note row ID | Product ID? |

**Recommendation:** Align INTERNAL_REF to always carry the product/item ID for consistency with INVITEM_STOCKEVENT link requirements, or document the varying semantics.

### 1.4 Category HUB_ID Cross-Org Collision

GRYZ_INVITEMS sub-category HUB_ID is org-scoped (`CONCAT(organizations, '-', subCategory)`) but category HUB_ID is just the bare `category` string. If two Growyze orgs share a category name (e.g. "Beverages"), they share the same HUB_INVITEM record — potential hierarchy cross-contamination.

**Recommendation:** Make category HUB_ID org-scoped: `CONCAT(organizations, '-', category)`. Same issue exists in GRYZ_PRODUCT.

### 1.5 Supplier Name Gap

55 of 89 SAT_SUPPLIER records (62%) have NULL SUPPLIER_NAME. Root cause: DL_PRODUCTS has `supplierId` but NULL `supplierName`. The GRYZ_SUPPLIERS step COALESCEs from DL_ORDERS (which has names) but suppliers that appear only in products (never ordered) get NULL names.

**Recommendation:** Investigate whether Growyze has a dedicated suppliers endpoint. If not, enrich supplier names by broadening the DL_ORDERS join.

### 1.6 Other Staging Findings

- **PACK_QUANTITY in GRYZ_COUNT_EVENTS** equals UOM_QUANTITY (`qty × size`). Should be raw `quantity` (number of packs counted).
- **Waste UOM values** include `'gal'` and `'oz'` from DL_PRODUCTS fallback — these are not in the UOM_CONVERSION reference table.
- **Sales double-counting risk:** If a dish has both INGREDIENT and RECIPE type sections, GRYZ_SALES Part A and Part B both fire for the same sale — potential ingredient consumption double-count.
- **Zero-quantity COUNT events:** 153 of 400 stocktake products have NULL quantity → treated as 0. Defensible but should be documented.

---

## 2. Data Vault Layer

### 2.1 Entity Mapping Coverage

All 22 entity mappings have corresponding load steps. The hub/satellite/link structure is correct. Key observations:

- **No Type 2 tracking** on any Growyze entity. All changes are Type 1 (overwrite). Recipe ratio changes, product renames, and stock event corrections are not historised.
- **SAT_LINEITEM.SRC_KEY is NULL for all 6,794 rows** — the raw source key is hashed into HUB_ID but not stored in the satellite, making traceability difficult.
- **`UOM_QUANITY` typo** in SAT_STOCKEVENT column name (missing 'T'). Systemic — internally consistent but permanently misspelled.
- **`OCCASSION_ID` typo** in SAT_OCCASION (double 'S'). Same — systemic, internally consistent.

### 2.2 DV Data Quality (Padel Social UAT)

| Entity | Rows | Key Issues |
|---|---|---|
| SAT_PRODUCT | 2,183 | MICROSERVICE_NAME should be NULL (cleanup deployed) |
| SAT_INVITEM | 3,504 | 3,377 leaf items + 120 subcats + 7 categories |
| SAT_LOCATION | 7 | 4 TR/DEMO locations still present (filter not deployed) |
| SAT_SUPPLIER | 89 | 55 (62%) have NULL SUPPLIER_NAME |
| SAT_STOCKEVENT | 8,822 | 2,050 COUNT + 128 WASTE + 5,379 SALE + 1,265 ORDER |
| SAT_LINEITEM | 6,794 | SRC_KEY = NULL for all rows |

### 2.3 Stocktake Pipeline Status

**Fully operational.** Step 15 (GRYZ_COUNT_EVENTS) → GRYZ_STOCKEVENT UNION ALL → SAT_STOCKEVENT (2,050 COUNT rows) → F_INV_COUNTS_DAY (2,095 rows, date range 2026-02-23 to 2026-03-16). ACTUAL_COUNT is populated correctly. The only gap is UOM_COST = NULL (cost source issue, §3.1).

DL_STOCKTAKEREPORTDETAIL (12 rows) is currently unused — holds aggregate totals per sub-report. May be needed for future discrepancy reporting.

---

## 3. Presentation Layer

### 3.1 UOM_COST Source Gap (Critical)

The InvLocCost CTE in three PresentationControl steps sources cost from SAT_INVREPORT — a MarketMan-only entity (0 rows for Growyze). This cascades:

| Fact Table | Rows | UOM_COST NULL | Impact |
|---|---|---|---|
| F_INV_USAGE_DAY | 3,440 | 3,440 (100%) | All monetary calculations zero |
| F_INV_COUNTS_DAY | 2,095 | 2,095 (100%) | Variance costs zero |
| F_INV_SALES_DAY | 2,257 | Masked as 0 by ISNULL | NET_SALES, SALES_RECIPE_COST all zero |

Growyze DL_PRODUCTS contains purchase price data (`price` column). This needs to be mapped into the DV (e.g. as a SAT_INVITEM attribute or dedicated SAT_INVCOST) and used as a COALESCE fallback: `COALESCE(invreport_cost, invitem_cost, NULL)`.

**Recommendation:** Define an alternative cost derivation pathway for non-MarketMan integrations. This is the single highest-impact fix for Growyze dashboard usability.

### 3.2 InvLocCost Partition Bug

F_PRE_INV_DAILY_DETAIL has `PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]` (INVITEM_HUB_ID listed twice). Should be `PARTITION BY LII.[INVITEM_HUB_ID], LIL.[LOCATION_HUB_ID]`. This means location-specific cost averaging is broken — produces a global per-item average instead.

Currently moot for Growyze (SAT_INVREPORT = 0 rows), but affects MarketMan orgs with multi-location cost variation.

### 3.3 GlobalParameters Not Set

All 6 date-range parameters (STOCKEVENT_START/END, INVREPORT_START/END, LINEITEM_START/END) are NULL for Padel Social. Every date-filtered PresentationControl step produces 0 rows when these are NULL. The existing presentation data was loaded during a prior run when parameters were temporarily set.

**Recommendation:** Set GlobalParameters for Padel Social before any scheduled presentation rebuild.

### 3.4 IntegrationType Filter Commented Out

"Product Margins by Day" has the `AND IG.[IntegrationType] IN ('POS', 'INVENTORY')` filter commented out. All integrations' lineitems flow into F_PRODUCT_MARGIN_DAY unfiltered. For Growyze this causes inventory sales data to appear in the margins table — possibly intentional but undocumented.

### 3.5 Cross-Integration Comparison

| Metric | Padel Social (Growyze) | Three Rocks Cafe (MarketMan) |
|---|---|---|
| F_INV_USAGE_DAY rows | 3,440 | 20,262 |
| F_INV_USAGE_DAY UOM_COST NULL% | 100% | 15.9% |
| F_INV_COUNTS_DAY rows | 2,095 | 3,247 |
| F_INV_COUNTS_DAY UOM_COST NULL% | 100% | 0% |
| SAT_INVREPORT rows | 0 | 171,648 |
| Column structure match | ✓ Identical | ✓ Identical |

Column structures are identical — the presentation tables are integration-agnostic. The gap is cost data only.

### 3.6 Dimension Hierarchy Integrity

All dimensions are well-formed for Growyze: no NULL names, coherent BOTTOM/MIDDLE_1/TOP paths, correct TOTAL_LEVELS. One sentinel row per dimension (CONVERT(BINARY(32), -999) key) with NULL HIERARCHY_PATH — expected.

Minor issue: D_INVITEM sentinel row SQL uses alias `BOTTOM_CHANNEL_NAME` instead of `BOTTOM_INVITEM_NAME` — copy-paste defect, non-breaking.

---

## 4. Visualisation Layer

### 4.1 UOM Scaling — MarketMan 'gr' Not Covered (Critical)

All 10 queries with UOM conversion use `IN ('ml','g')`. MarketMan uses `'gr'` (not `'g'`) for grams — confirmed by live data (8,182 F_INV_USAGE_DAY rows, 622 F_INV_COUNTS_DAY rows). These display in raw grams (e.g. "2,698,550" instead of "2,698.6 kg").

**Affected queries:** InvConsumption (×2), InvStockActivity (×2), InvWasteAnalysis (×3), InvMargeBrut, InvTop20Variance, plus the UOM display string conversion.

**Recommendation:** Add `'gr'` to all `IN ('ml','g')` checks. Add `'gr'→'kg'` to display UOM conversions.

### 4.2 Type-Arithmetic Bug in Pie Charts

InvActMargin and InvRecipeMargin compute percentage as `FORMAT(..., 'N0')` (produces NVARCHAR), then do `100 - (formatted_string)`. This relies on implicit NVARCHAR→numeric coercion — fragile.

**Recommendation:** Compute numeric percentage first, apply FORMAT only in the final display.

### 4.3 Broken Location Filtering on Markdown/Static Cards

InvMMHeader and InvMMHeader2 define Locations filter as `"column": "LOCATION_HUB_ID"` (the raw BINARY(32) column) instead of the COALESCE display pattern. Location filtering on these two cards injects `AND LOCATION_HUB_ID IN ('string_name')` — type mismatch, always fails.

**Recommendation:** Change to `"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])"`.

### 4.4 Flat Product Hierarchy for MarketMan

For Three Rocks Cafe, D_PRODUCT has TOP_NAME = individual product name (not a category). InvCOGSByCategory PieChartCard shows ~70 individual products as "categories" — unusable. The MIDDLE_1 level is also flat.

This is a D_PRODUCT hierarchy structure issue, not a vis query issue. The hierarchy is as deep as the source data provides.

**Recommendation:** Either ensure all integrations map a meaningful category hierarchy, or add a fallback grouping in category-based queries (e.g. group by MIDDLE_1 if TOP has too many distinct values).

### 4.5 InvMargeBrut Column Slot Mismatch

Parent rows put TURNOVER/RECIPE_COGS/GP% in Columns 4-6, but the header labels Columns 4-6 as "Purchases (L/kg)" / "Consumption (L/kg)" / "Waste (L/kg)". Financial metrics are displayed under volume headings at the parent level.

**Recommendation:** Reserve Columns 7-9 for financial fields, or restructure to separate child (volume) and parent (financial) column slots cleanly.

### 4.6 Dead/Misleading Cards

| Card | Issue | Impact |
|---|---|---|
| InvTheoVsActualGP | Only shows Recipe GP% (one series). Title promises "Theo vs Actual" | Permanently half-implemented |
| InvProdEventCost / InvProdEventValue | Production events are Growyze-specific. MarketMan always shows 0 | Dead cards for MarketMan |
| InvActMargin | Computes RECIPE_COST_PERC and THEO_COST_PERC but only displays ACTUAL_COST_PERC | Dead code in CTE |

### 4.7 Filter/Parameter Inconsistencies

- **ProductCategories** maps to `product.MIDDLE_1` in F_PRODUCT_MARGIN_DAY queries but `invitem.TOP` in F_INV_USAGE_DAY queries — different hierarchy levels across dashboards.
- **InvUseAnalisys InvItems filter** uses `"column": "Column5"` (an output alias) instead of a source column reference.
- **RedLion filter keys** in InvCountVariance and InvTop20Variance — 8 dead entries each from a copy-paste origin.
- **InvCountData COUNT_RECENCY** uses `DATEDIFF(DAY, GETDATE(), COUNT_DATE)` — produces negative values. Should be `DATEDIFF(DAY, COUNT_DATE, GETDATE())`.

### 4.8 Code Duplication

InvVariances and InvKPIGrouped contain an identical ~40-line Base CTE. Any business logic change must be applied to both independently.

### 4.9 Cross-Integration Test Summary

| Dataset | Growyze | MarketMan | Both Return Data? |
|---|---|---|---|
| InvConsumption | ✓ (converted to L/kg) | ✓ (raw grams — `'gr'` not converted) | Yes, but UOM display broken for MM |
| InvWasteAnalysis | ✓ | ✓ (raw grams) | Yes, same UOM issue |
| InvStockActivity | ✓ | ✓ (only 2/9 locations have SALE_QTY) | Yes |
| InvCOGSByCategory | ✓ (23 real categories) | ✓ but ~70 flat "categories" (product names) | Yes, but unusable for MM |
| InvWeeklySummary | ✓ (GP% 70-79%) | ✓ (GP% 74-75%) | Yes |

---

## 5. Agnostic Fitness Summary

### What Works Well
- **Quantity pipeline** (staging → DV → presentation): Integration-agnostic. SAT_STOCKEVENT, F_INV_USAGE_DAY, F_INV_COUNTS_DAY work correctly for both Growyze and MarketMan.
- **@HasPOS flag** in F_INV_SALES_DAY: Clean integration-detection mechanism.
- **Presentation table schema**: Identical column structure across integrations.
- **Filter framework**: Consistent COALESCE pattern across most queries.

### What Needs Rework for True Agnosticism
1. **Cost derivation** (InvLocCost CTE) — tied to SAT_INVREPORT (MarketMan-only)
2. **UOM value vocabulary** — `'g'` vs `'gr'`, `'each'` vs `'EA'`
3. **D_PRODUCT hierarchy depth** — flat for MarketMan, 2-tier for Growyze
4. **Production events** — Growyze-specific, dead for MarketMan
5. **F_LINEITEM_15MIN** in InvTheoMargin — cross-table mix, brittle for pure-inventory orgs

---

## 6. Consolidated Recommendations

### P1 — Critical (Data Correctness)

| # | Area | Recommendation |
|---|---|---|
| 1 | Presentation | **Define alternative UOM_COST source for non-MarketMan integrations.** Growyze DL_PRODUCTS has purchase price data — map to DV and COALESCE as fallback in InvLocCost CTE. |
| 2 | Visualisation | **Add `'gr'` to all UOM scaling checks.** 10 queries affected. Without this, all MarketMan gram items display in raw grams. |
| 3 | Staging | **Add NULL key guards** to 4 load paths (LINEITEM_PRODUCT, LOCATION_OCCASION_PRODUCT, STOCKEVENT_STOCKORDER, INVITEM_STOCKEVENT) to prevent phantom hash records. |
| 4 | Presentation | **Set Padel Social GlobalParameters** (STOCKEVENT_START/END, LINEITEM_START/END). Currently NULL — next presentation rebuild produces 0 rows. |

### P2 — High (Usability / Accuracy)

| # | Area | Recommendation |
|---|---|---|
| 5 | Staging | **Standardise dedup** to ROW_NUMBER LOADTS_UTC DESC across all steps (DN Events product lookup, Prep Recipes, Product InvItem, Line Item sales_agg). |
| 6 | Staging | **Make category HUB_ID org-scoped** in GRYZ_INVITEMS and GRYZ_PRODUCT (`CONCAT(organizations, '-', category)`) to prevent cross-org collision. |
| 7 | Presentation | **Fix InvLocCost PARTITION BY bug** in F_PRE_INV_DAILY_DETAIL (INVITEM_HUB_ID listed twice instead of INVITEM + LOCATION). |
| 8 | Visualisation | **Fix InvActMargin/InvRecipeMargin type-arithmetic** — compute numeric percentage before FORMAT. |
| 9 | Visualisation | **Fix InvMMHeader/InvMMHeader2 location filter** — LOCATION_HUB_ID → COALESCE display pattern. |
| 10 | Visualisation | **Fix InvMargeBrut column slot mismatch** — parent financial columns overlap child volume column positions. |
| 11 | Visualisation | **Fix InvCountData COUNT_RECENCY sign** — swap DATEDIFF arguments. |
| 12 | Staging | **Enrich NULL SUPPLIER_NAME** — 62% of suppliers nameless. Add DL_ORDERS-based name fallback. |

### P3 — Medium (Maintenance / Consistency)

| # | Area | Recommendation |
|---|---|---|
| 13 | Staging | **Align INTERNAL_REF semantics** across event types (or document the variation). |
| 14 | Staging | **Fix PACK_QUANTITY in GRYZ_COUNT_EVENTS** — should be raw `quantity`, not `quantity × size`. |
| 15 | Staging | **Validate UOM coverage** — `'gal'`, `'oz'` from waste events not in UOM_CONVERSION table. |
| 16 | Staging | **Guard against sales double-counting** — dishes with both INGREDIENT and RECIPE sections. |
| 17 | Presentation | **Decide on IntegrationType filter** in Product Margins by Day — currently commented out. |
| 18 | Presentation | **Abstract InvLocCost** into a dedicated Tier 1 step to eliminate duplication across 3 steps. |
| 19 | Visualisation | **Consolidate InvVariances/InvKPIGrouped** shared CTE (40-line duplication). |
| 20 | Visualisation | **Remove RedLion filter keys** from InvCountVariance and InvTop20Variance. |
| 21 | Visualisation | **Fix InvUseAnalisys** — Column16/18 duplicate, InvItems filter uses output alias. |

### P4 — Low (Polish / Documentation)

| # | Area | Recommendation |
|---|---|---|
| 22 | Visualisation | **Rename InvTheoVsActualGP** to "Recipe GP% Trend" (only has one series). |
| 23 | Visualisation | **Suppress InvProdEventCost/Value** for MarketMan orgs (always 0). |
| 24 | Staging | **Document DL_STOCKTAKEREPORTDETAIL** as unused / reserved for future use. |
| 25 | Staging | **Document zero-qty COUNT events** (153 of 400 stocktake rows). |
| 26 | DV | **Fix D_INVITEM sentinel row alias** (`BOTTOM_CHANNEL_NAME` → `BOTTOM_INVITEM_NAME`). |
| 27 | Visualisation | **Add BOTTOM_INVITEM_NAME IS NOT NULL guard** to InvNegVar, InvPosVar, InvWasteCost, InvProdEventCost, InvProdEventValue. |
| 28 | Visualisation | **Fix header Type21 copy-paste bug** in InvCountData and InvKPIGrouped. |

---

## 7. Delivery Info Trace (Padel Social UAT, 2026-05-12)

**Jira (created 2026-05-12):** [XMSE-1378](https://threerocks.atlassian.net/browse/XMSE-1378) (D1, S2/Major), [XMSE-1379](https://threerocks.atlassian.net/browse/XMSE-1379) (D2, S3/Major), [XMSE-1380](https://threerocks.atlassian.net/browse/XMSE-1380) (D3, S3/Major). Cross-linked via "Relates".

### Counts at each pipeline stage

| Stage | Rows | Note |
|---|---|---|
| DL_DELIVERYNOTES | 1,230 | 210 deliveries × ~5.9 lines |
| `INNER JOIN` DL_PRODUCTS on barcode | 1,225 | 5 rows silently dropped (no matching product) |
| stage.GRYZ_DN_EVENTS | 1,225 | |
| stage.GRYZ_STOCKEVENT type='ORDER' | 983 | dedup on (SRC_KEY, EVENT_BEHAVIOUR); 242 exact dupes (max 1 organization per delivery — safe) |
| SAT_STOCKEVENT type='ORDER' | 1,025 | DV adds CDC history |
| LNK_STOCKEVENT_STOCKORDER | 1,025 | every ORDER event linked to a PO |
| HUB_STOCKORDER / SAT_STOCKORDER | 191 / 191 | PO side, from DL_ORDERS |

### Issue D1 (HIGH): `SAT_STOCKORDER.DELIVERY_DATE` NULL for ~99% of rows

`Growyze Stock Order` staging sources `DELIVERY_DATE` from `MIN(DL_ORDERS.expectedDeliveryDate)`:

- `DL_ORDERS.expectedDeliveryDate` populated **76 / 965 (8%)** → only **12 / 191** SAT_STOCKORDER rows get a date.
- The actual delivery date is `DL_DELIVERYNOTES.deliveryDate`, populated **1,230 / 1,230 (100%)**, and does reach DV at `SAT_STOCKEVENT.EVENT_TS` for `EVENT_TYPE='ORDER'` (1,025/1,025, range 2025-09-05+).

**Fix:** In `Growyze Stock Order` staging, LEFT JOIN `DL_DELIVERYNOTES` on `po` and take `MAX(deliveryDate)` as DELIVERY_DATE (falling back to `expectedDeliveryDate`). Or change downstream presentation to use `SAT_STOCKEVENT.EVENT_TS` via `LNK_STOCKEVENT_STOCKORDER`.

### Issue D2 (MEDIUM): No DELIVERY entity — DN attributes lost

These `DL_DELIVERYNOTES` fields are not staged anywhere:

| Field | Description |
|---|---|
| `deliveryNoteNumber` | DN reference |
| `status` | DRAFT / COMPLETED / APPROVED / IN_QUERY / REJECTED |
| `dateOfScanning`, `completedDate`, `approvedDate`, `inQueryDate`, `rejectedDate` | DN lifecycle |
| `hasReceivedQtyDiscrepancies`, `hasDNQtyDiscrepancies`, `hasReceivedOrderQtyDiscrepancies` | reconciliation flags |
| `products_price` | per-line price |
| `products_productDiscrepancies_delta*` | discrepancy quantities |
| `supplier_id` / `supplier_name` on DN | can diverge from PO supplier |

Belongs on a new SAT_LNK on `LNK_STOCKEVENT_STOCKORDER`, or a dedicated `DELIVERY` hub if deliveries should be first-class.

### Issue D3 (LOW): INNER JOIN on barcode silently drops rows

`Growyze DN Events` uses `INNER JOIN DL_PRODUCTS p ON dn.products_barcode = p.barcode`. At Padel Social this loses 5/1230 rows; orgs with worse product coverage can lose far more without any signal. Soften to LEFT JOIN with `-999` sentinel or a `COALESCE` fallback like `Growyze Waste Events`.
