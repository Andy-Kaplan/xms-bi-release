# ClaudeDevelopment Query Status

Reference document for SQL scripts in this folder. Maintained so future sessions can resume investigation without repeating discovery work.

---

## MCP Testing Note

For how to test scripts via the SQL Server MCP tool, see the **ClaudeDevelopment Folder** section in `CLAUDE.md` — it covers the three-part naming pattern required for MCP test queries, and the rule that saved scripts must never include a hardcoded database name.

---

## Scripts

### 1. `products_without_invitem_recipes.sql`

**Purpose:** Identifies leaf-level products (BOTTOM_LEVEL=1, not deleted) that have no INVITEM mapped to them via either recipe link — meaning they cannot be costed or theoretically tracked through inventory.

**Logic:** Returns products from HUB_PRODUCT/SAT_PRODUCT where no row exists in either:
- `LNK_INVITEM_OCCASION_PRODUCT` (standard recipe link)
- `LNK_INVITEM_LOCATION_OCCASION_PRODUCT` (site-specific recipe link)

**Status:** Script executes cleanly. ✓

---

### 2. `products_with_invitem_recipes.sql`

**Purpose:** Returns one row per ingredient line across all product recipes, unioning both recipe link types. Deduplicates SAT_LNK tables (append-only, no CURRENT_FLAG) using ROW_NUMBER() OVER (PARTITION BY LNK_ID ORDER BY LOAD_TS DESC).

**Status:** Script executes cleanly. ✓

---

## Test Results — `20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57`

Tested: 2026-03-03. Integration: `int_marketman001`.

| Table | Row Count |
|---|---|
| HUB_PRODUCT | 315 |
| SAT_PRODUCT (CURRENT_FLAG=1, BOTTOM_LEVEL=1) | 315 |
| HUB_INVITEM | 3,866 |
| SAT_INVITEM (CURRENT_FLAG=1) | 3,866 |
| LNK_INVITEM_OCCASION_PRODUCT | **0** |
| LNK_INVITEM_LOCATION_OCCASION_PRODUCT | 315 |

**Both scripts returned 0 rows.** Root cause fully investigated — see below.

---

## Root Cause Analysis: Broken INVITEM Hash in LNK_INVITEM_LOCATION_OCCASION_PRODUCT

Investigation completed: 2026-03-03.

### Symptom

`products_with_invitem_recipes.sql` returns zero rows despite 315 rows existing in `LNK_INVITEM_LOCATION_OCCASION_PRODUCT`, because the `INNER JOIN` to `HUB_INVITEM` matches nothing.

- All 315 link rows share a **single identical `INVITEM_HUB_ID`** (SHA256Hash of empty string `''`).
- That hash does not exist in `HUB_INVITEM`.
- All 315 rows also share the same `LOCATION_HUB_ID` and `OCCASION_HUB_ID`.
- Only `PRODUCT_HUB_ID` varies correctly across rows.
- All rows loaded in a single batch on `2026-02-03T16:00:01`.

### Stores in This Organisation

| Store ID | Store Name | Menu Items | Profitability (non-zero price) | Recipe Sub-Items | Inventory Items |
|---|---|---|---|---|---|
| `872cf667...` | Kudu - Staff | 4 | 7 (0 non-zero) | **6** | 1,232 |
| `9dbec6a3...` | KUDU Collective | 2,263 | 4,025 (1,894 non-zero) | **0** | 1,251 |
| `ed84ceb7...` | KUDU - HQ | 2,309 | 7 (0 non-zero) | **0** | 1,251 |

### Root Cause Chain

**1. Upstream data gap (PRIMARY ROOT CAUSE):** `DL_MENU_ITEMS_SUBITEMS` (recipe ingredients) contains only 6 rows, all for "Kudu - Staff" (`872cf...`). The main production store "KUDU Collective" (`9dbec...`) — which carries all the real menu item pricing and POS codes — has **zero recipe sub-items**. This is a MarketMan client-side configuration issue: recipes have not been set up for the correct store in MarketMan.

**2. Price filter eliminates the only store with recipes:** The `MMAN_PRODUCT` staging query (`MarketMan001_Staging.sql` ~line 781) applies:
```sql
WHERE CAST([MenuItemPrice] AS NUMERIC) != 0
```
"Kudu - Staff" has zero non-zero-price profitability rows → entirely filtered out. Only "KUDU Collective" survives with 315 products.

**3. LEFT JOIN produces empty string INVITEM_ID:** The staging query LEFT JOINs `DL_MENU_ITEMS_SUBITEMS` (REC) and computes:
```sql
CONCAT_WS('-', REC.[storeId], REC.[ItemID]) AS INVITEM_ID
```
Since "KUDU Collective" has no sub-items, REC columns are all NULL. `CONCAT_WS('-', NULL, NULL)` = `''` (empty string) for every row.

**4. SHA256Hash('') produces a constant orphan hash:** The entity mapping hashes empty string `''` → a single constant `INVITEM_HUB_ID` that doesn't exist in `HUB_INVITEM`. All 315 link records point to this phantom hash.

### Secondary Design Issues

Even once the upstream data is fixed, these staging/mapping design weaknesses remain:

**A. LEFT JOIN in MMAN_PRODUCT staging** — Products without recipes should not produce link records. The LEFT JOIN to `DL_MENU_ITEMS_SUBITEMS` means ALL products get rows, including those with `INVITEM_ID = ''`. For the `INVITEM_LOCATION_OCCASION_PRODUCT` link mapping, only products with actual recipe ingredients should be included. Options:
- Split into separate staging tables for the PRODUCT hub vs. the link
- Change to INNER JOIN for the recipe columns (but this would break the PRODUCT hub mapping which shares this table)
- Add a WHERE filter in the entity mapping or loading process to skip rows with empty hub key source columns

**B. OCC_ID hardcoded to `'-999'`** — Every row gets `OCC_ID = '-999'` (line 769), producing a single OCCASION_HUB_ID = SHA256Hash('-999'). This hash won't match any entry in `HUB_OCCASION` or the platform's standard sentinel `CONVERT(BINARY(32), -999)`. If no occasion applies, the staging should either use a value that exists in HUB_OCCASION or the loading process should insert the sentinel directly.

**C. `LNK_INVITEM_OCCASION_PRODUCT` is empty (0 rows)** — This is the "standard" recipe link (non-location-specific). No MarketMan mapping populates it. All recipe data flows through the location-specific variant `INVITEM_LOCATION_OCCASION_PRODUCT` only.

### Impact

- `products_with_invitem_recipes.sql` — returns 0 rows (should return recipe ingredient lines)
- `products_without_invitem_recipes.sql` — returns 0 rows (misleadingly implies full recipe coverage; in reality no valid recipe links exist)
- All inventory costing, theoretical usage, and product margin calculations for this organisation are broken at the link level
- Presentation tables `F_PRODUCT_MARGIN_DAY`, `F_INV_USAGE_DAY`, `F_INV_SALES_DAY` that depend on recipe links will have no data or incorrect data

### Related Known Issue

From `docs/data-vault-reference.md` §8: "PRODUCT_ID denormalized in LOCATION_OCCASION_PRODUCT SAT_LNK" — separate but related issue in the same link family.

---

## TROAP Integration Scripts

### 3. `integrations/troap/TROAP001_Staging.sql`

**Purpose:** 20 StagingControl INSERT/UPDATE statements for the TROAP POS integration (`int_troap001`). Follows the IF EXISTS/UPDATE/ELSE INSERT pattern from `NCRAloha001_Staging.sql`.

**Structure:** 12 Tier 1 steps (dimensions + Order + Line Item Detail) and 8 Tier 2 steps (link tables dependent on Line Item Detail).

| Step | Table | Tier | Description |
|---|---|---|---|
| 1 | TROAP_LOCATION | 1 | Stores from DL_Store |
| 2 | TROAP_PRODUCT | 1 | Products + categories from DL_Product/DL_ProductCategory (excl. CategoryId=3) |
| 3 | TROAP_MOD | 1 | Modifiers (ProductCategoryId=3 = "Topping") from DL_Product |
| 4 | TROAP_CHANNEL | 1 | Distinct ClientApplication from DL_Order |
| 5 | TROAP_OCCASION | 1 | Distinct ShipmentTypeId from DL_Order |
| 6 | TROAP_DEAL | 1 | Promotions from DL_CustomerOpenCheckPromotion |
| 7 | TROAP_DISCOUNT | 1 | Discounts from DL_CustomerOpenCheckDiscount |
| 8 | TROAP_TENDER | 1 | Payment methods from DL_OrderPayment |
| 9 | TROAP_SVCCHARGE | 1 | Service charges from DL_CustomerOpenCheckCharge |
| 10 | TROAP_REVCENTER | 1 | SalesAreaName from DL_Store |
| 11 | TROAP_ORDER | 1 | Orders with DL_Store + DL_OrderPayment aggregates |
| 12 | TROAP_LINE_ITEM_DETAIL | 1 | 6-branch UNION ALL (PROD/MOD/TENDER/SVC/DEAL/DISCOUNT) |
| 13 | TROAP_PROD_LI_LNK | 2 | Product-to-LineItem link (LINEITEM_TYPE='PROD') |
| 14 | TROAP_MOD_LI_LNK | 2 | Mod-to-LineItem link (LINEITEM_TYPE='MOD') |
| 15 | TROAP_DEAL_LI_LNK | 2 | Deal-to-LineItem link (LINEITEM_TYPE='DEAL') |
| 16 | TROAP_DISC_LI_LNK | 2 | Discount-to-LineItem link (LINEITEM_TYPE='DISCOUNT') |
| 17 | TROAP_TENDER_LI_LNK | 2 | Tender-to-LineItem link (LINEITEM_TYPE='TENDER') |
| 18 | TROAP_SVC_LI_LNK | 2 | ServiceCharge-to-LineItem link (LINEITEM_TYPE='SVC') |
| 19 | TROAP_OCC_LI_LNK | 2 | Occasion-to-LineItem link (PROD+MOD rows) |
| 20 | TROAP_LI_LI_LINK | 2 | LineItem-to-LineItem self-ref (MOD→parent PROD) |

**Status:** All queries validated via MCP. ✓

---

### 4. `integrations/troap/TROAP001_Mapping.sql`

**Purpose:** EntityMapping INSERT/UPDATE statements for the TROAP POS integration (`int_troap001`). Maps staging tables to Data Vault hub and link entities.

**Mappings (25 total):** 12 hub mappings (LOCATION, PRODUCT, MOD, CHANNEL, OCCASION, REVCENTER, DEAL, DISCOUNT, TENDER, SVCCHARGE, CUSTORDER, LINEITEM) + 13 link mappings (CUSTORDER_LOCATION, CUSTORDER_LINEITEM, CHANNEL_CUSTORDER, CUSTORDER_OCCASION, CUSTORDER_REVCENTER, LINEITEM_PRODUCT, LINEITEM_MOD, LINEITEM_OCCASION, LINEITEM_TENDER, LINEITEM_SVCCHARGE, DEAL_LINEITEM, DISCOUNT_LINEITEM, LINEITEM_LINEITEM).

**Status:** Pattern validated against NCRAloha reference. ✓

---

### 5. `integrations/troap/TROAP_Analysis.md`

**Purpose:** Data analysis document for the TROAP integration covering DL table structures, data volumes, staging design decisions, and identified data quality observations.

**Status:** Document written.

---

### 6. `ANSWER_entity_v3_widen_column.sql`

**Purpose:** Fixes ANSWER entity truncation error (SQL error 2628) that blocks SurveyHero Data Vault loading. Survey free-text responses reach 1,071 characters but the ANSWER attribute was defined as NVARCHAR(255).

**Two-part fix:**
- **Part 1 (core database):** Retires ANSWER v2, inserts ANSWER v3 with `ANSWER` attribute widened to `NVARCHAR(MAX)`. Uses MERGE for idempotent v3 insert.
- **Part 2 (client databases):** `ALTER TABLE` on `load.ANSWER` and `datavault.SAT_ANSWER` to widen the existing column. Guarded by `INFORMATION_SCHEMA.COLUMNS` check — only alters if column is still NVARCHAR(255). Required because `sp_GenerateDataVaultTables` uses `IF NOT EXISTS` and will not alter existing tables.

**Scope:** Only the `ANSWER` attribute is widened. `ANSWER_ID` remains NVARCHAR(255) — it is hashed to BINARY(32) for HUB_ID and is not directly populated by the entity mapping.

**Affected tables:** `load.ANSWER`, `datavault.SAT_ANSWER`. No presentation layer impact (ANSWER does not flow to presentation tables).

**Status:** Created. Not yet deployed.

---

### 7. `SurveyHero_ANSWER_ID_fix.sql`

**Purpose:** Replaces the `ISNULL(answer_id, answer_label)` ANSWER_ID derivation in the SurveyHero "Survey Hero Main" staging step with a safer CASE expression.

**Problem (3 issues):**
- **57,515 rows (67%)** — both `answer_id` and `answer_label` NULL (unanswered number/choice/text questions). All hash to the same phantom HUB_ID via SHA256Hash(NULL).
- **23,590 rows (27%)** — falls back to raw `answer_label` text (mutable free-text up to 1,071 chars) as the business key.
- **5,044 rows (6%)** — uses `choice_id` — the only correct group (unchanged by this fix).

**Fix:** CASE expression:
```sql
CASE
    WHEN answer_id IS NOT NULL THEN answer_id           -- structured choice_id (stable, short)
    WHEN answer_label IS NOT NULL THEN CONCAT_WS('-', response_id, answer_element_id)  -- stable composite (~17 chars max)
    ELSE NULL                                            -- unanswered questions
END AS ANSWER_ID
```

**Data validation:** Texts and numbers are confirmed 1:1 per response+element (no duplicates), so `response_id-element_id` is unique per answer instance.

**Impact:** ANSWER_ID values change for all non-choice answers. Existing 82 HUB_ANSWER entries will become orphans — new hub entries created on next DV load with stable composite keys.

**Companion scripts:** Deploy `ANSWER_entity_v3_widen_column.sql` first (widens ANSWER attribute to NVARCHAR(MAX)), then this script (fixes ANSWER_ID derivation), then re-run `sp_DataVaultLoad`.

**Status:** Created. Not yet deployed.

---

### 8. `sp_DataVaultLoad_fix.sql`

**Purpose:** Fixed deployment object for `sp_DataVaultLoad`. Corrects the `sp_ProcessStagingDuplicates` call placement. Uses MERGE (upsert) to safely update or insert the DeploymentObjects record.

**Bug:** `sp_ProcessStagingDuplicates` was called at line 2658 (before `BEGIN TRY`, outside the schema cursor loop) with `@SchemaName` still NULL (declared at line 2626 but never assigned). The dedup proc's default is `'dbo'`, but an explicit NULL parameter overrides the default, so `INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = NULL` matches nothing. Dedup silently skips all DL_* tables.

**Fix:** Removed the pre-loop call. Added the call inside the schema cursor loop, immediately before `sp_Staging`, so it receives the actual `@SchemaName` from the cursor. Dedup now runs per-integration-schema before staging.

**Deploy pattern:** `MERGE INTO [core].[DeploymentObjects]` on `(ObjectName, ObjectType)` — updates existing record or inserts if missing. Sets `ModifiedDate` on update. Safe to re-run.

**Status:** Created. Not yet deployed.

---

## Test Results — `20251112_XMS_DBAB95ED-112E-42C6-B0E9-E0BFD20709D9` (TROAP)

Tested: 2026-03-03. Organisation: Bella Italia. Integration: `int_troap001`.

### DL Table Row Counts

| Table | Rows |
|---|---|
| DL_Store | 243 |
| DL_Order | 48,453 |
| DL_OrderItem | 563,293 |
| DL_OrderPayment | 58,679 |
| DL_Product | 57,845 |
| DL_ProductCategory | 11 |
| DL_CustomerOpenCheck | 149,578 |
| DL_CustomerOpenCheckCharge | 94,552 |
| DL_CustomerOpenCheckPromotion | 24,792 |
| DL_CustomerOpenCheckDiscount | 7,871 |

### Staging Query Validation Results

| Step | Table | Rows | Notes |
|---|---|---|---|
| 1 Location | TROAP_LOCATION | 243 | |
| 2 Product | TROAP_PRODUCT | 56,393 | Products + 10 non-modifier categories |
| 3 Mod | TROAP_MOD | 1,462 | ProductCategoryId=3 ("Topping") |
| 4 Channel | TROAP_CHANNEL | 1 | OLO2_Website only |
| 5 Occasion | TROAP_OCCASION | 1 | ShipmentTypeId=9 only |
| 6 Deal | TROAP_DEAL | 24,792 | Each promo application has unique Id |
| 7 Discount | TROAP_DISCOUNT | 80 | 80 distinct DiscountIds from 7,871 rows |
| 8 Tender | TROAP_TENDER | 2 | |
| 9 Service Charge | TROAP_SVCCHARGE | 2 | |
| 10 RevCenter | TROAP_REVCENTER | 6 | |
| 11 Order | TROAP_ORDER | 48,453 | Matches DL_Order exactly, no join multiplication |
| 12 Line Item Detail | TROAP_LINE_ITEM_DETAIL | 764,329 | PROD:500,232 + MOD:74,050 + TENDER:60,133 + SVC:97,071 + DEAL:24,792 + DISCOUNT:8,051 |
| 13-18 | Tier 2 link tables | Various | Counts match LINEITEM_TYPE filters |
| 19 Occasion to LI | TROAP_OCC_LI_LNK | 574,282 | PROD+MOD rows |
| 20 LI to LI | TROAP_LI_LI_LINK | 74,050 | = MOD count, every modifier links to parent |

### Integrity Checks

- **PROD + MOD = DL_OrderItem:** 500,232 + 74,050 = 574,282 matches joined OrderItem count exactly
- **Order join safety:** No row multiplication from DL_Store or DL_OrderPayment LEFT JOINs
- **LI-to-LI orphan parents:** Only 2 out of 74,050 (both from Order 16688)
- **SVC/DEAL/DISCOUNT join chain:** 2-3 orphan rows filtered by WHERE clause
- **Product/Mod split:** ProductCategoryId=3 ("Topping") correctly isolates modifiers

### Data Observations

- **Single channel/occasion:** This organisation is online-only (OLO2_Website, ShipmentTypeId=9)
- **Deal granularity:** 24,792 promotion application instances (not reusable types) — each has unique Id
- **Product categories:** None, Sides, Pizza, Topping, Breakfast, A La Carte, Desserts, Set Menu, Kids, Drinks, Food Menu RS
- **DL_Store rows (243) vs distinct StoreIds:** 243 rows = 243 distinct StoreIds (1:1); Order step uses ROW_NUMBER dedup as safety measure
- **SRC_KEY collision fix:** MCP validation found 1 cross-branch collision between SVC charge and OrderItem IDs. Fixed by appending LINEITEM_TYPE to all SRC_KEY CONCAT_WS patterns (e.g. `OrderId-ItemId-PROD`), matching NCRAloha's approach

### Financial Total Verification (Step 3)

Verified: 2026-03-03.

| Metric | Value |
|---|---|
| SUM(TotalPriceTotal) — all 48,453 rows | £3,042,199.98 |
| SUM(TotalPriceTotal) — deduped to 47,732 distinct OrderIds | £2,996,418.21 |
| TRY_CAST failures (Total / Net / VAT) | 0 / 0 / 0 |
| TotalPriceTotal = TotalPriceNet for all rows | Yes (TotalPriceVat = 0 everywhere) |
| TENDERED_SALES (SUM DL_OrderPayment.Amount) | £2,630,894.89 (35,389 orders) |
| Orders with no payment record | 12,343 |
| Min / Max order total | £0 / £1,225.31 |

**Result:** Staging is a faithful pass-through — zero cast failures, totals match DL_Order exactly. The 721 duplicate OrderIds (version updates via DateUpdated) are preserved; DV SCD loading will handle dedup at the SAT level.

**Observations:**
- **VAT is zero everywhere** — TotalPriceTotal equals TotalPriceNet for all 48,453 rows. TROAP does not track VAT at the order level.
- **£365K gap** between GRAND_TOTAL (£2,996K deduped) and TENDERED_SALES (£2,631K) — 12,343 orders have no DL_OrderPayment record.
- **No dedup in staging** — The Order step does not deduplicate by OrderId (no ROW_NUMBER). All 48,453 DL_Order rows pass through including 721 version duplicates. This is acceptable for DV loading (HUB ignores duplicate hash keys; SAT applies SCD).

### ITEM_SRC_KEY Referential Integrity (Step 5)

Verified: 2026-03-03. PROD/MOD fix applied and re-verified same day.

Checks whether each LINE_ITEM_DETAIL branch's ITEM_SRC_KEY has a matching record in its corresponding hub staging source.

**Initial findings (before fix):**

| Branch | Total Rows | Orphans | Rate | Cause |
|---|---|---|---|---|
| PROD | 487,232 | **74,827** | 15.4% | Category mismatch: branch used OrderItemParentId, hub used ProductCategoryId |
| MOD | 87,050 | **9,041** | 10.4% | Category mismatch (reverse direction) |
| TENDER | 60,133 | 0 | 0% | Clean ✓ |
| SVC | 97,071 | **7,225** | 7.4% | NULL Name in DL_CustomerOpenCheckCharge |
| DEAL | 24,792 | 0 | 0% | Clean ✓ |
| DISCOUNT | 8,051 | 0 | 0% | Clean ✓ |

**Root cause — PROD/MOD orphans:** The LINE_ITEM_DETAIL PROD/MOD branch split used `OI.[OrderItemParentId]` (parent-child relationship) while the hub staging tables TROAP_PRODUCT and TROAP_MOD used `P.[ProductCategoryId]` (product master data). These are two different classification axes — DL_OrderItem.ProductCategoryId frequently disagrees with DL_Product.ProductCategoryId (83,868 mismatches across 574,282 items).

**Fix applied to TROAP001_Staging.sql:**

1. **Step 12 (LINE_ITEM_DETAIL) — Branches A & B:** Changed PROD/MOD split from `OrderItemParentId` to `DL_Product.ProductCategoryId` via `INNER JOIN [int_troap001].[DL_Product] P ON OI.[ProductId] = P.[ProductId]`. PROD: `WHERE P.[ProductCategoryId] != '3'`. MOD: `WHERE P.[ProductCategoryId] = '3'`. This aligns the branch split with the hub classification.

2. **Step 20 (LI-to-LI self-ref):** Changed PARENT_SRC_KEY from hardcoded `'PROD'` suffix to dynamic `CASE WHEN PP.[ProductCategoryId] = '3' THEN 'MOD' ELSE 'PROD' END` via `INNER JOIN DL_OrderItem POI / DL_Product PP` to look up the parent's actual category. 35% of MOD parents are themselves category 3, so the hardcoded suffix was producing 19,435 orphan PARENT_SRC_KEYs.

**Post-fix results:**

| Branch | Total Rows | Orphans | Notes |
|---|---|---|---|
| PROD | 419,656 | **0** ✓ | Now classified by DL_Product.ProductCategoryId != '3' |
| MOD | 154,626 | **0** ✓ | Now classified by DL_Product.ProductCategoryId = '3' |
| TENDER | 60,133 | 0 ✓ | Unchanged |
| SVC | 97,071 | **7,225** | Unchanged — NULL Name issue (see below) |
| DEAL | 24,792 | 0 ✓ | Unchanged |
| DISCOUNT | 8,051 | 0 ✓ | Unchanged |

Total PROD + MOD = 574,282 = all DL_OrderItem rows joined to DL_Order (no items lost by INNER JOIN to DL_Product). Step 20 (LI-to-LI) now produces 55,509 rows with correct parent suffix (36,074 PROD + 19,435 MOD).

**Row count changes from fix:**
- PROD: 500,232 → 419,656 (−80,576 items reclassified as MOD by category)
- MOD: 74,050 → 154,626 (+80,576 items reclassified from PROD)
- LI-to-LI: 74,050 → 55,509 (only category-3 items with parents; standalone toppings excluded)
- OCC_LI_LNK: 574,282 → 574,282 (unchanged — still PROD+MOD total)

**Outstanding — SVC orphans (7,225):**

7,225 rows in `DL_CustomerOpenCheckCharge` have NULL Name. The TROAP_SVCCHARGE hub uses `Name` as ITEM_SRC_KEY, and the LINE_ITEM_DETAIL SVC branch uses `CH.[Name]` as ITEM_SRC_KEY. When Name is NULL, SHA256Hash(NULL) produces an orphan SVCCHARGE_HUB_ID.

**Potential fix:** COALESCE(CH.[Name], 'Unknown') or filter out NULL-name charges.

---

### 9. `survey_vis_queries_part1.sql`

**Purpose:** MERGE upserts for 9 VisualisationQueries records — the filters, demographics, and completion group (Tasks 5-7 from `2026-03-03-survey-fact-table-plan.md`). Rewrites records from `threerocks.dbo.church_survey_results` to use `[presentation].[F_SURVEY_RESPONSE]` and `[presentation].[D_QUESTION]`.

**Records covered:**

| DataSetName | CardType | Notes |
|---|---|---|
| SurveyFilter | FilterList | COMMUNITY_INVOLVEMENT DISTINCT; no upstream filters |
| SurveyFilterAge | FilterList | AGE_BRACKET DISTINCT; filtered by SurveyFilter |
| SurveyAgeByGender | CustomDataGrid | AGE_BRACKET pivot x GENDER; deduped via age question subquery |
| SurveyAgeByGender | CustomPinnedDataGrid | Same data in PinnedColumn format |
| SurveyAgeByRespondentTotal | BarChartCard | COUNT(DISTINCT TOUCHPOINT_HUB_ID) by ANSWER_TEXT (age bracket answer) |
| SurveyAgeGender | HeatmapCard | AGE_BRACKET x GENDER heatmap using denorm cols; fixed: @FilterClause now applied |
| SurveyGenderByRespondentTotal | PieChartCard | COUNT(DISTINCT TOUCHPOINT_HUB_ID) by gender answer |
| SurveyCompletion | StackedBarChartCard | TOUCHPOINT_STATUS x COMMUNITY_INVOLVEMENT; simplified from legacy UNION pattern |
| SurveyStatusByInvolvement | CustomPinnedDataGrid | COMMUNITY_INVOLVEMENT x TOUCHPOINT_STATUS; fixed: table typo corrected |

**Bugs fixed:**
- `SurveyAgeGender`: legacy had no `@FilterClause` applied — now included
- `SurveyStatusByInvolvement`: legacy queried `threerock.dbo.church_survey_results` (missing 's') — corrected
- All records: stale POS template entries (Discounts, Products, ProductCategories) removed from FilterDefinitions
- All records: `Survey_Status = 'Complete'` replaced with `f.TOUCHPOINT_STATUS = 'completed'`

**Design decisions:**
- Cross-tab and heatmap queries deduplicate to one row per respondent by filtering `QUESTION_HUB_ID` to the age bracket question subquery — avoids fan-out from multi-question fact grain
- SurveyCompletion uses `Survey Selection` question subquery (same dedup pattern) rather than hardcoded UNION per involvement value
- FilterDefinitions updated: SurveyFilter maps to `f.COMMUNITY_INVOLVEMENT`, SurveyFilterAge maps to `f.AGE_BRACKET` (with `f.` alias prefix for @FilterClause injection)

**Status:** Created 2026-03-03. Not yet deployed (F_SURVEY_RESPONSE and D_QUESTION presentation tables must be deployed first).

---

### 10. `survey_vis_queries_part2.sql`

**Purpose:** MERGE upserts for 14 VisualisationQueries records — score average queries for Lifestyle, Challenging Issues, and Environment sections (Tasks 8-10 from `2026-03-03-survey-fact-table-plan.md`). All rewritten from `threerocks.dbo.church_survey_results` (UNPIVOT pattern) to use `[presentation].[F_SURVEY_RESPONSE]` and `[presentation].[D_QUESTION]`.

**Records covered:**

| DataSetName | CardType | Notes |
|---|---|---|
| SurveyAverageLifestyleScore | PieChartCard | AVG(ANSWER_NUMERIC) by COMMUNITY_INVOLVEMENT; TOP='Lifestyle provision', MIDDLE='Poor' |
| SurveyLifestyleProvision | BarChartCard | AVG by BOTTOM_QUESTION_NAME; TOP='Lifestyle provision', MIDDLE='Poor' |
| SurveyLifestyleRadar | RadarChartCard | AVG by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT; Lifestyle provision / Poor |
| SurveyEnvironmentRadar | RadarChartCard | Preserved legacy intent — uses Lifestyle provision data (same as SurveyLifestyleRadar) |
| SurveyRespondentByLifestyle | StackedBarChartCard | AVG by question + community involvement stacked; Lifestyle provision / Poor |
| SurveyLifestyleThoughts | SingleKPICard | STRING_AGG of ANSWER_TEXT; TOP='Lifestyle provision', BOTTOM='Any extra thoughts ?'; fixed: @FilterClause restored and hardcoded involvement filter removed |
| SurveyAverageChallengeScore | PieChartCard | AVG by COMMUNITY_INVOLVEMENT; TOP='Challenging issues', MIDDLE='Poor' |
| SurveyChallengingRadar | RadarChartCard | AVG by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT; Challenging issues / Poor |
| SurveyRespondentByChallenge | StackedBarChartCard | AVG by question + community involvement stacked; Challenging issues / Poor |
| SurveyChallengeThoughts | CustomDataGrid | Free-text listing; TOP='Challenging issues', BOTTOM='Any extra thoughts ?'; fixed: hardcoded Church Member filter removed |
| SurveyChallengeThoughtsnonChurch | CustomDataGrid | Same as above with @FilterClause for SurveyFilter |
| SurveyEnvironmentRadarBad | RadarChartCard | Fixed: was using wrong CASE labels (Lifestyle column names). Now TOP='Our Environment', MIDDLE='Poor'; axis comes from BOTTOM_QUESTION_NAME directly |
| SurveyRespondentByEnvironment | StackedBarChartCard | Fixed: was copy of RespondentByChallenge (Provision_for_* columns). Now TOP='Our Environment', MIDDLE='Poor' |
| SurveyEnvironmentThoughts | CustomDataGrid | Fixed: was querying Extra_Thoughts_Lifestyle_Provision column. Now TOP='Our Environment', BOTTOM='Any extra thoughts ?' |

**Bugs fixed:**
- `SurveyEnvironmentRadarBad`: CASE labels mapped environment column names to lifestyle labels (Arts, Children, etc.) — now no CASE mapping needed; BOTTOM_QUESTION_NAME is the actual question text
- `SurveyRespondentByEnvironment`: was an exact copy of RespondentByChallenge (Provision_for_* UNPIVOT) — now correctly queries Our Environment TOP
- `SurveyEnvironmentThoughts`: queried `Extra_Thoughts_Lifestyle_Provision` column despite being named Environment — now filters by TOP='Our Environment' AND BOTTOM='Any extra thoughts ?'
- `SurveyLifestyleThoughts`: `@filterclause` was commented out; hardcoded `Community_Involvement = 'Influencer'` — both issues corrected
- `SurveyChallengeThoughts`: hardcoded `community_involvement = 'Church Member'` filter removed — all respondents shown; use @FilterClause / SurveyFilter to filter
- All records: stale POS template entries (Discounts, Products, ProductCategories) removed from FilterDefinitions
- All records: SurveyFilter column updated from `Community_Involvement` to `f.COMMUNITY_INVOLVEMENT`; SurveyFilterAge updated to `f.AGE_BRACKET`

**Design decisions:**
- Score queries use `MIDDLE_1_QUESTION_NAME = 'Poor'` — this is the scale all respondent types answered. Church-only scales ('Not called', 'No expertise & resources') can be accessed by changing the MIDDLE filter in a separate query variant.
- Stacked bar charts use `f.COMMUNITY_INVOLVEMENT AS Stack` (actual value string) rather than legacy CASE 'A'/'B'/'C'/'D' codes — cleaner for the front end.
- Header result set for StackedBarChartCard now returns `NULL AS Value` (no aggregate count) rather than a separate COUNT(*) subquery against the old flat table, since the new fact table is at question grain (one row per question per respondent).

**Status:** Created 2026-03-03. Not yet deployed (F_SURVEY_RESPONSE and D_QUESTION presentation tables must be deployed first).

---

### 11. `survey_vis_queries_part3.sql`

**Purpose:** MERGE upserts for 14 VisualisationQueries records — building/travel/activity queries and free-text/KPI queries (Tasks 11-12 from `2026-03-03-survey-fact-table-plan.md`). Rewrites records from `threerocks.dbo.church_survey_results` to use `[presentation].[F_SURVEY_RESPONSE]` and `[presentation].[D_QUESTION]`.

**Records covered:**

| DataSetName | CardType | Notes |
|---|---|---|
| SurveyBuildingActivities | PieChartCard | COUNT(DISTINCT TOUCHPOINT_HUB_ID) by answer; question: 'Are the buildings well suited to the needs of the activities you attend?' |
| SurveyBuildingSuited | PieChartCard | COUNT(DISTINCT TOUCHPOINT_HUB_ID) by answer; question: 'Are the church buildings well suited to the needs of those regularly using them?' |
| SurveyBuildingUse | BarChartCard | COUNT(*) by ANSWER_TEXT; question: 'Which of the following do you regularly attend?' (multi-choice — one DV row per selection, no STRING_SPLIT needed) |
| SurveyBuildingUse | PieChartCard | COUNT(DISTINCT TOUCHPOINT_HUB_ID) by answer; question: 'Do you use, visit or hire the Eastleigh Baptist Church Buildings?' |
| SurveyMembersDistance | BarChartCard | COUNT(DISTINCT TOUCHPOINT_HUB_ID) by answer; question: 'How far do you travel to the church ?'; CASE sort preserved from legacy |
| SurveyMembersTravel | BarChartCard | COUNT(DISTINCT TOUCHPOINT_HUB_ID) by answer; question: 'How do you usually get to the church ?'; CASE sort preserved from legacy |
| SurveyDistanceTransport | HeatmapCard | Cross-tab Distance x Transport; self-join on TOUCHPOINT_HUB_ID using two D_QUESTION lookups |
| SurveyMemberActivities | BarChartCard | Same question as SurveyBuildingUse BarChart ('Which of the following do you regularly attend?') but with the legacy member-specific sort order |
| SurveyImprovementsNeeded | CustomDataGrid | Free-text row listing; question: 'What improvements need to be made to the buildings to support the work of the church better?'; LEN trim guard applied |
| SurveyBuildingUseImprovements | SingleKPICard | STRING_AGG(bullet + ANSWER_TEXT) for improvements question |
| SurveyBuildingUseMessage | SingleKPICard | STRING_AGG for 'What message do you think the church building and site give to visitors and passers by?' |
| SurveyVisitorMessage | CustomDataGrid | Row listing for visitor message question |
| SurveyLifestyleProvisionThoughts | CustomDataGrid | TOP='Lifestyle provision', BOTTOM='Any extra thoughts ?'; hardcoded COMMUNITY_INVOLVEMENT = 'Church congregation member' — no @FilterClause (matches legacy intent) |
| SurveyLifestyleProvisionThoughtsnonChurch | CustomDataGrid | Same question; @FilterClause applied via SurveyFilter (all respondents, user-selectable) |

**Notes:**
- Desborough Hall dataset searched for in `8_VisualisationQueries.sql` — no matching DataSetName found. Not included.
- `SurveyLifestyleThoughts` (SingleKPICard) was covered in `survey_vis_queries_part2.sql` (Task 8). Not duplicated here.
- `SurveyDistanceTransport`: FilterDefinitions use `dist.COMMUNITY_INVOLVEMENT` / `dist.AGE_BRACKET` (the `dist` alias on the first fact join).
- All stale POS template entries removed from FilterDefinitions.

**Status:** Created 2026-03-03. Deployed and tested 2026-03-04.

**MCP Test Results (2026-03-04):** All 37 survey vis queries tested via MCP against `20251202_XMS_3EBF26FE-E14A-40ED-A355-9A411B1273B4`. All 37 execute without SQL errors. Bugs found and fixed:

| Bug | Severity | Fix |
|---|---|---|
| SurveyEnvironmentRadar: wrong TOP_QUESTION_NAME (`Lifestyle provision` → `Our Environment`) | CRITICAL | Fixed in part2 |
| Sentinel -999 TOUCHPOINT rows leaking NULL COMMUNITY_INVOLVEMENT into 8 aggregation queries | DATA QUALITY | Added `AND f.COMMUNITY_INVOLVEMENT IS NOT NULL` to all affected queries |
| SurveyChallengeThoughts: missing hardcoded church member filter (was identical to nonChurch variant) | LOGIC | Added `f.COMMUNITY_INVOLVEMENT = 'Church congregation member'` to match Lifestyle pattern |
| SurveyAgeByRespondentTotal: CASE sort labels didn't match actual data (e.g. `Age 21-30` → `Age 20 - 29`) | SORT | Fixed CASE values to match actual answer text |
| SurveyMembersDistance: CASE sort labels wrong format + missing `1 - 2 miles` | SORT | Fixed CASE values + added missing distance band |
| SurveyMemberActivities: CASE sort used placeholder activity names from different survey | SORT | Replaced CASE with ROW_NUMBER(ORDER BY COUNT DESC) — works for any survey |
| SurveyChallengeThoughts header: duplicate `TYPE11` where `TYPE21` should be | HEADER | Fixed in all 4 branches |

---

### 12. `survey_presentation_tables.sql` and `survey_presentation_control.sql` — 4 Demographic Sub-Tables

**Purpose:** Replaces the single `D_SURVEY_DEMOGRAPHICS` table with 4 individual demographic lookup tables. Each resolves one demographic attribute per touchpoint via a single LEFT JOIN triplet (3 joins) instead of all 4 triplets (12 joins) in one query — significantly faster.

**Refactored 2026-03-04** from the combined D_SURVEY_DEMOGRAPHICS approach (still too slow) to 4 independent sub-tables.

**4 tables** (all Dimension, version 1, live, `is_system_generated=1`, Tier 1):

| Table | GUID | Question Text | Column |
|---|---|---|---|
| `D_SURVEY_COMMUNITY_INVOLVEMENT` | `C1E8D1A3-...2E01` | `Survey Selection` | COMMUNITY_INVOLVEMENT |
| `D_SURVEY_AGE_BRACKET` | `C2E8D1A3-...2E02` | `What age bracket are you in ?` | AGE_BRACKET |
| `D_SURVEY_GENDER` | `C3E8D1A3-...2E03` | `What is your gender ?` | GENDER |
| `D_SURVEY_POSTCODE` | `C4E8D1A3-...2E04` | `What is your postcode ?` | POSTCODE |

Each DDL has 2 columns: `TOUCHPOINT_HUB_ID [binary](32)` + the demographic `[nvarchar](255)`. Each build query uses `SELECT DISTINCT` with `INNER JOIN SAT_TOUCHPOINT` + `LEFT JOIN SAT_QUESTION` (filtered by question text) + `LEFT JOIN SAT_ANSWER`, with `AND SQ.QUESTION IS NOT NULL` to eliminate non-matching rows. Date-range filtered via TOUCHPOINT_START/TOUCHPOINT_END GlobalParameters.

**Status:** Created 2026-03-04. Not yet deployed. Must be deployed before `survey_f_response_control.sql` (Tier 2).

---

### 13. `survey_f_response_control.sql` — Refactored to Tier 2 (4 sub-table joins)

**Purpose:** MERGE upsert for the F_SURVEY_RESPONSE PresentationControl record. **Refactored 2026-03-04** to Tier 2 with 4 LEFT JOINs to individual demographic sub-tables.

**Original design:** 12 demographic LEFT JOINs directly in the fact build query.

**Previous refactor (still slow):** Single LEFT JOIN to combined D_SURVEY_DEMOGRAPHICS.

**Current design:** 4 LEFT JOINs to individual sub-tables:
- `LEFT JOIN [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT] d_ci`
- `LEFT JOIN [presentation].[D_SURVEY_AGE_BRACKET] d_age`
- `LEFT JOIN [presentation].[D_SURVEY_GENDER] d_gen`
- `LEFT JOIN [presentation].[D_SURVEY_POSTCODE] d_pc`

SELECT uses `d_ci.COMMUNITY_INVOLVEMENT`, `d_age.AGE_BRACKET`, `d_gen.GENDER`, `d_pc.POSTCODE`. Each sub-table has ~835 rows so lookups are trivial.

- GUID unchanged: `A7D3F8C2-91E4-4B56-8D7A-2E5F1C093B4A`
- `column_mappings` unchanged — all 11 columns remain

**Status:** Created 2026-03-04. Not yet deployed. Requires all 4 demographic sub-table DDLs and PresentationControl records to be deployed first.

---

### 14. `survey_lifestyle_radar_fix.sql`

**Purpose:** Fixes SurveyLifestyleRadar RadarChartCard — both this and SurveyEnvironmentRadar were using `TOP_QUESTION_NAME = 'Our Environment'`. This fix changes SurveyLifestyleRadar to use `'Lifestyle provision'` and updates the header title to `'Average Score by Lifestyle Provision'`.

**Root cause:** During the MCP test bug fix cycle (2026-03-04), SurveyEnvironmentRadar was corrected from `'Lifestyle provision'` to `'Our Environment'`, but SurveyLifestyleRadar was also set to `'Our Environment'` instead of being left at `'Lifestyle provision'`.

**Status:** Created 2026-03-04. Not yet deployed.

---

## Full Survey Visualisation Test Results — 2026-03-04

Tested by 3-agent parallel team against `20251202_XMS_3EBF26FE-E14A-40ED-A355-9A411B1273B4` (NeighboursSurvey, int_surveyhero001).

**Test criteria:**
1. All queries execute without SQL error (unfiltered)
2. Queries respond correctly to SurveyFilter (`COMMUNITY_INVOLVEMENT`) and SurveyFilterAge (`AGE_BRACKET`) filters
3. Query output tallies with Data Vault source tables

### Group A — Filters, Demographics, Completion, Lifestyle (13 records)

| # | DataSetName | CardType | Exec | Rows | Filter | Filtered | DV | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | SurveyFilter | FilterList | PASS | 4 | SKIP | — | PASS | 4 values match F_SURVEY_RESPONSE DISTINCT |
| 2 | SurveyFilterAge | FilterList | PASS | 8 | PASS | 8 | PASS | 8 brackets; Church filter still returns all 8 |
| 3 | SurveyAgeByGender | CustomDataGrid | PASS | 8 | PASS | 1 | PASS | |
| 4 | SurveyAgeByGender | CustomPinnedDataGrid | PASS | 29 | PASS | 1 | PASS | |
| 5 | SurveyAgeByRespondentTotal | BarChartCard | PASS | 8 | PASS | 8 | PASS | Sum=493 (6 answered gender but not age) |
| 6 | SurveyAgeGender | HeatmapCard | PASS | 29 | PASS | 9 | PASS | |
| 7 | SurveyGenderByRespondentTotal | PieChartCard | PASS | 4 | PASS | 4 | PASS | 499 distinct completed respondents |
| 8 | SurveyCompletion | StackedBarChartCard | PASS | 8 | PASS | 2 | PASS | 817 with involvement (18 NULL) |
| 9 | SurveyStatusByInvolvement | CustomPinnedDataGrid | PASS | 8 | PASS | 2 | PASS | |
| 10 | SurveyLifestyleProvision | BarChartCard | PASS | 10 | PASS | 8 | PASS | Scores 3.21-3.99 |
| 11 | SurveyLifestyleRadar | RadarChartCard | PASS | 36 | PASS | 9 | **BUG** | Wrong TOP_QUESTION_NAME: 'Our Environment' instead of 'Lifestyle provision'. Fix: `survey_lifestyle_radar_fix.sql` |
| 12 | SurveyLifestyleProvisionThoughts | CustomDataGrid | PASS | 305 | SKIP | — | PASS | Hardcoded church member filter |
| 13 | SurveyLifestyleProvisionThoughtsnonChurch | CustomDataGrid | PASS | 923 | PASS | reduced | PASS | |

### Group B — Lifestyle Scores, Challenges, Environment (13 records)

| # | DataSetName | CardType | Exec | Rows | Filter | Filtered | DV | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | SurveyLifestyleThoughts | SingleKPICard | PASS | 1 | PASS | 1 | PASS | STRING_AGG; filter reduces content |
| 2 | SurveyAverageLifestyleScore | PieChartCard | PASS | 4 | PASS | 1 | PASS | Scores 3.16-3.80 (valid range) |
| 3 | SurveyRespondentByLifestyle | StackedBarChartCard | PASS | 38 | PASS | 10 | PASS | 10 questions x 4 groups |
| 4 | SurveyAverageChallengeScore | PieChartCard | PASS | 4 | PASS | 1 | PASS | Scores 3.04-3.63 |
| 5 | SurveyChallengingRadar | RadarChartCard | PASS | 32 | PASS | 8 | PASS | TOP='Challenging issues' confirmed |
| 6 | SurveyRespondentByChallenge | StackedBarChartCard | PASS | 32 | PASS | 8 | PASS | |
| 7 | SurveyChallengeThoughts | CustomDataGrid | PASS | 305 | PASS | 34 | PASS | Church hardcoded; age filter works |
| 8 | SurveyChallengeThoughtsnonChurch | CustomDataGrid | PASS | 926 | PASS | 305 | PASS | |
| 9 | SurveyEnvironmentRadar | RadarChartCard | PASS | 36 | PASS | 9 | PASS | TOP='Our Environment' correct |
| 10 | SurveyEnvironmentRadarBad | RadarChartCard | PASS | 36 | PASS | 9 | NOTE | Identical query to SurveyEnvironmentRadar — intentional duplicate (see findings) |
| 11 | SurveyRespondentByEnvironment | StackedBarChartCard | PASS | 36 | PASS | 9 | PASS | |
| 12 | SurveyEnvironmentThoughts | CustomDataGrid | PASS | 927 | PASS | 305 | PASS | |
| 13 | SurveyImprovementsNeeded | CustomDataGrid | PASS | 584 | PASS | 282 | PASS | |

### Group C — Building, Travel, Activity, KPI, Messages (11 records)

| # | DataSetName | CardType | Exec | Rows | Filter | Filtered | DV | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | SurveyBuildingActivities | PieChartCard | PASS | 3 | PASS | 3 | PASS | Yes/No/Not sure |
| 2 | SurveyBuildingSuited | PieChartCard | PASS | 3 | PASS | 3 | PASS | |
| 3 | SurveyBuildingUse | BarChartCard | PASS | 30 | PASS | 30 | PASS | 30 activity categories |
| 4 | SurveyBuildingUse | PieChartCard | PASS | 2 | PASS | 2 | PASS | Yes/No |
| 5 | SurveyBuildingUseImprovements | SingleKPICard | PASS | 1 | PASS | 1 | PASS | STRING_AGG bullet list |
| 6 | SurveyBuildingUseMessage | SingleKPICard | PASS | 1 | PASS | 1 | PASS | 556→274 filtered |
| 7 | SurveyMemberActivities | BarChartCard | PASS | 30 | PASS | 30 | PASS | |
| 8 | SurveyMembersDistance | BarChartCard | PASS | 5 | PASS* | 5 | PASS | *All respondents are congregation members — filter correct but no reduction |
| 9 | SurveyMembersTravel | BarChartCard | PASS | 4 | PASS* | 4 | PASS | *Same — congregation-only question |
| 10 | SurveyDistanceTransport | HeatmapCard | PASS | 14 | PASS | 14 | PASS | dist. prefix filters correct |
| 11 | SurveyVisitorMessage | CustomDataGrid | PASS | 556 | PASS | 274 | PASS | |

### Data Vault Validation (Cross-Cutting)

| Check | Description | Actual | Expected | Result |
|---|---|---|---|---|
| A | F_SURVEY_RESPONSE distinct respondents | 835 | 835 | PASS |
| B | LNK_ANSWER_QUESTION_TOUCHPOINT rows | 112,173 | ~143,289 | FLAG — fact table has 31,116 more rows due to D_SURVEY_POSTCODE LEFT JOIN fan-out (see below) |
| C | D_QUESTION non-sentinel rows vs HUB_QUESTION | 102 vs 116 | — | FLAG — 14 hub questions not in D_QUESTION (likely non-leaf or retired questions) |
| D | Demographic sub-table row counts | CI=835, Age=835, Gender=836, Postcode=1,338 | ~835 each | FLAG — Gender +1 duplicate; Postcode has multi-row respondents |

### Findings

**BUG — SurveyLifestyleRadar wrong TOP_QUESTION_NAME (CRITICAL)**
Both SurveyLifestyleRadar and SurveyEnvironmentRadar use `TOP_QUESTION_NAME = 'Our Environment'`. SurveyLifestyleRadar should use `'Lifestyle provision'`. Fix script: `survey_lifestyle_radar_fix.sql`.

**FINDING — SurveyEnvironmentRadarBad is a duplicate of SurveyEnvironmentRadar**
Both records have byte-for-byte identical QueryTemplates. They both filter `TOP_QUESTION_NAME = 'Our Environment'` with `MIDDLE_1_QUESTION_NAME = 'Poor'`. The "Bad" variant was presumably meant to show a different scale/perspective. In the legacy survey, scales had "Good" and "Bad" labels, but the D_QUESTION hierarchy stores them under a single 'Poor' MIDDLE_1 value. Both radars produce identical data. No action needed unless the business wants differentiated views.

**FINDING — HTML entity in D_QUESTION source data**
`D_QUESTION` contains `'Not called&nbsp;'` (with HTML non-breaking space entity) as a distinct MIDDLE_1_QUESTION_NAME under 'Our Environment', alongside `'Not called'`. Source data quality issue from SurveyHero — entity stored literally. Does not affect vis queries (they filter on 'Poor') but may affect future queries enumerating scale categories.

**FINDING — D_SURVEY_POSTCODE fan-out inflating F_SURVEY_RESPONSE**
D_SURVEY_POSTCODE has 1,338 rows for 835 respondents (496 respondents have 2-3 entries). The LEFT JOIN in the F_SURVEY_RESPONSE build creates 31,116 extra rows (143,289 fact vs 112,173 link). Impact on vis queries:
- AVG-based queries (radar, scores): **unaffected** — duplicate rows with same ANSWER_NUMERIC don't change averages
- COUNT(DISTINCT TOUCHPOINT_HUB_ID): **unaffected** — distinct count is correct
- COUNT(*) queries: **potentially inflated** — but no current vis queries use raw COUNT(*)
- STRING_AGG queries: **may include duplicate text entries** for respondents with multiple postcodes

Root cause: the postcode question likely has multiple answer records per respondent in the DV (e.g., partial answers or multi-line free text). The sub-table build should use SELECT DISTINCT or ROW_NUMBER dedup.

**FINDING — D_SURVEY_GENDER has 1 duplicate TOUCHPOINT_HUB_ID**
836 rows vs 835 respondents. One respondent has 2 gender entries. Same LEFT JOIN fan-out risk as postcode but only affects 1 row. Negligible impact on current queries.

**FINDING — Age + Church double filter returns 0 rows for some queries**
`COMMUNITY_INVOLVEMENT = 'Church congregation member' AND AGE_BRACKET = 'Age 30 - 39'` returns 0 rows on some aggregation queries. This is a data characteristic (no 30-39 church members in the dataset), not a bug. Filter mechanism works correctly (confirmed via single-filter tests).

**FINDING — Distance/Travel questions are congregation-only**
SurveyMembersDistance and SurveyMembersTravel return identical results whether filtered by 'Church congregation member' or not — all 165 respondents to those questions ARE congregation members. The SurveyFilterAge filter works correctly on these queries.

---

## MarketMan Integration Fix Scripts

### 15. `integrations/MarketMan/C1_occasion_sentinel.sql`

**Purpose:** Fixes the MarketMan occasion orphan problem. MarketMan has no occasion data — OCC_ID is hardcoded to `'-999'` in MMAN_PRODUCT and MMAN_LINEITEM staging. SHA256Hash('-999') doesn't exist in HUB_OCCASION, causing 100% orphan rate on OCCASION_HUB_ID for all 4 occasion link mappings (CUSTORDER_OCCASION, LINEITEM_OCCASION, LOCATION_OCCASION_PRODUCT, INVITEM_LOCATION_OCCASION_PRODUCT).

**Fix (2 MERGE statements):**
1. StagingControl MERGE: creates 'MarketMan Occasion' step (Tier 1) producing `stage.MMAN_OCCASION` with 1 sentinel row: OCC_ID='-999', OCC_NAME='Not Applicable', LEVEL_NAME='Occasion', BOTTOM_LEVEL=1.
2. EntityMappings MERGE: maps OCCASION hub from MMAN_OCCASION. entity_columns match NCRAloha OCCASION pattern: `["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]` (note: double-S typo in OCCASSION_ID is baked into the live entity definition).

**Effect:** DV load creates 1 HUB_OCCASION row with HUB_ID = SHA256Hash('-999'). All link rows referencing the hardcoded '-999' OCC_ID resolve successfully.

**Status:** Created 2026-03-04. Not yet deployed.

---

### 16. `integrations/MarketMan/C2_product_recipe_split.sql`

**Purpose:** Fixes the INVITEM orphan problem in LNK_INVITEM_LOCATION_OCCASION_PRODUCT. The MMAN_PRODUCT staging LEFT JOINs DL_MENU_ITEMS_SUBITEMS — products without recipes get INVITEM_ID='' (empty string from CONCAT_WS of NULLs). SHA256Hash('') doesn't match any HUB_INVITEM row, producing 100% orphan rate (all 315 rows).

**Fix (2 MERGE statements):**
1. StagingControl MERGE: creates 'Product Recipe' step (Tier 2, depends on 'Inventory Items') producing `stage.MMAN_PRODUCT_RECIPE`. Uses INNER JOIN (not LEFT OUTER JOIN) to DL_MENU_ITEMS_SUBITEMS — only products with actual recipe ingredient mappings produce rows. Selects only columns needed for the link: PosCode, INVITEM_ID, UOM, UOM_VALUE, storeId, OCC_ID.
2. EntityMappings MERGE: updates INVITEM_LOCATION_OCCASION_PRODUCT source_table from 'MMAN_PRODUCT' to 'MMAN_PRODUCT_RECIPE'. source_columns and entity_columns unchanged.

**Design note:** LOCATION_OCCASION_PRODUCT mapping stays on MMAN_PRODUCT — it needs MenuItemPrice/RecipeIngredientsCost and does NOT reference INVITEM_HUB_ID.

**Status:** Created 2026-03-04. Not yet deployed.

---

### 17. `integrations/MarketMan/C5_report_id_fix.sql`

**Purpose:** Fixes the MMAN_REPORT REPORT_ID construction bug. `CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), ...)` uses the date as the separator instead of a value — the date never appears in REPORT_ID. Also, 7 rows with NULL ItemID produce 6 duplicate REPORT_IDs.

**Fix:** Changes CONCAT_WS to:
```sql
CONCAT_WS('-', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.[storeId], ISNULL(REP.[ItemID], 'NO_ITEM'))
```
- Uses `'-'` as the separator (proper delimiter)
- Includes the date as a concatenated value (not consumed as separator)
- Wraps ItemID in `ISNULL(..., 'NO_ITEM')` to prevent NULL-induced duplicates

**All other columns, JOINs, and OUTER APPLY logic unchanged.** MERGE upsert on step_name = 'Report'.

**Status:** Created 2026-03-04. Not yet deployed.

---

### 18. `integrations/MarketMan/C6_waste_events_fix.sql`

**Purpose:** Fixes the MMAN_WASTE_EVENTS staging step that drops 81% of rows. The JOIN between DL_WASTE_EVENTS (WE) and DL_WASTE_EVENTS_LINES (WEI) includes `AND WE.[BuyerGuid] = WEI.[storeId]`. 17 out of 21 waste events have NULL BuyerGuid, so `NULL = WEI.[storeId]` evaluates to UNKNOWN and the JOIN silently fails for those rows.

**Fix:** Removes the `AND WE.[BuyerGuid] = WEI.[storeId]` condition from the INNER JOIN. The remaining two conditions (`ON WE.[ID] = WEI.[ID] AND WE.[storeId] = WEI.[storeId]`) correctly match event headers to their line items.

**All other columns, GROUP BY, WHERE, and UOM JOIN unchanged.** MERGE upsert on step_name = 'Waste Events'.

**Status:** Created 2026-03-04. Not yet deployed.

---

### 19. `integrations/MarketMan/H7_prep_recipes_dedup.sql`

**Purpose:** Fixes the MMAN_PREP_RECIPES 3x row inflation (4,167 distinct recipes inflated to 12,501 rows). DL_INVENTORY_PREPS_SUBITEMS has multiple INT_FETCH_DATE values for the same recipe records (each API fetch appends rows). No dedup in the staging query.

**Fix:** Wraps the existing SELECT in a ROW_NUMBER dedup:
```sql
ROW_NUMBER() OVER (
    PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
    ORDER BY REC.[INT_FETCH_DATE] DESC
) AS rn
...
WHERE rn = 1
```
Keeps only the most recent fetch of each recipe ingredient line (keyed on storeId + parent item + child item).

**All output columns unchanged (PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE).** MERGE upsert on step_name = 'MMAN_PREP_RECIPES'.

**Status:** Created 2026-03-04. Not yet deployed.

---

### 14. `integrations/MarketMan/C3_invitem_parent_hash.sql`

**Purpose:** Fixes SAT_INVITEM.PARENT_ID storing raw source strings instead of BINARY(32) hashes. The INVITEM entity mapping had `{"name": "PARENT_ID", "hash": 0}` -- PARENT_ID was not hashed before storage. Since HUB_INVITEM.HUB_ID is SHA-256 hashed, any JOIN between SAT_INVITEM.PARENT_ID and HUB_INVITEM.HUB_ID always fails (incompatible types).

**Fix:** MERGE upsert against `core.int_marketman001.EntityMappings` (key: entity_name='INVITEM', source_table='MMAN_INVITEMS'). Changes PARENT_ID from `"hash": 0` to `"hash": 1` in source_columns JSON. All other columns unchanged.

**Impact:** After deployment, a full reload of INVITEM entity is required to re-hash existing PARENT_ID values. Enables INVITEM hierarchy joins for dimension builds and inventory cost roll-ups.

**Status:** Created 2026-03-04. Not yet deployed.

---

### 15. `integrations/MarketMan/H5_invitems_category_fix.sql`

**Purpose:** Fixes duplicate INVITEM_ID collision in MMAN_INVITEMS staging. Category rows from DL_INVENTORY_ITEMS with NULL CategoryID produce INVITEM_ID = bare storeId (CONCAT_WS skips NULLs). COGS top-level rows from DL_ACTUAL_VS_THEO with NULL COGSCategoryID also produce INVITEM_ID = bare storeId. Result: 1 confirmed duplicate pair on KUDU org.

**Root cause analysis:**
- Branch 2 (DL_INVENTORY_ITEMS categories): `CONCAT_WS('-', storeId, NULL)` = storeId -- valid parent for uncategorized leaf items
- Branch 5 (COGS top-level): `CONCAT_WS('-', storeId, NULL)` = storeId -- orphan row, no category references it as parent (they use ISNULL(COGSCategoryID, -1) which maps to '-1')

**Fix:** MERGE upsert against `core.int_marketman001.StagingControl` (key: step_name='Inventory Items'). Adds `WHERE [COGSCategoryID] IS NOT NULL` to the COGS top-level branch (branch 5). Filters out meaningless NULL COGSCategoryID rows without changing any key patterns. Parent-child consistency preserved -- branch 2 null-category rows remain valid parents for uncategorized leaf items.

**Status:** Created 2026-03-04. Not yet deployed. **Superseded by XMSE944_invitems_dedup_fix.sql** (includes this fix + C10 + cross-branch dedup).

---

### 16. `integrations/MarketMan/C9_cross_store_report_fix.sql`

**Purpose:** Fixes cross-store buyer bleed in the "Report" staging step. The MarketMan actual_vs_theo API returns data for ALL buyers visible to a store, not just its own. Store `ed84ceb7...` (KUDU-HQ) returns data for both "Kudu-Staff" AND "KUDU Collective", while KUDU Collective also has its own separate request. This duplicates all KUDU Collective actual_vs_theo data under the wrong storeId.

**Impact chain:**
- `MMAN_REPORT`: 9,333 → ~6,222 rows (removes ~3,111 cross-store dupes)
- `MMAN_REPORT_STEP2`: automatically fixed (reads from MMAN_REPORT)
- `HUB_INVREPORT`: 165,391 records (~50% are duplicates under wrong location)
- `LNK_INVREPORT_LOCATION`: KUDU-HQ drops from 110,258 to ~55,126 records
- `F_INV_USAGE_DAY` / `F_INV_SALES_DAY`: removes double-counted inventory data

**Fix:** MERGE upsert against `core.int_marketman001.StagingControl` (key: step_name='Report'). Adds `WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL` to the DL_ACTUAL_VS_THEO subquery.

**Status:** Created 2026-03-04. Not yet deployed.

---

### 17. `integrations/MarketMan/C10_cross_store_invitems_fix.sql`

**Purpose:** Fixes cross-store buyer bleed in the "Inventory Items" staging step. Three subqueries read DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS — two for COGS category lookups (low impact, SELECT DISTINCT) and one for top-level COGS category INVITEM records (creates phantom entries under wrong storeId).

**Fix:** MERGE upsert against `core.int_marketman001.StagingControl` (key: step_name='Inventory Items'). Adds `WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL` to all three DL_ACTUAL_VS_THEO subqueries.

**Status:** Created 2026-03-04. Not yet deployed. **Superseded by XMSE944_invitems_dedup_fix.sql** (includes this fix + H5 + cross-branch dedup).

---

### 18. `integrations/MarketMan/XMSE944_invitems_dedup_fix.sql`

**Purpose:** Fixes XMSE-944 — the immediate blocker preventing all DV loads in Three Rocks Cafe (dev). The MMAN_INVITEMS staging query had 5 UNION ALL branches; branches 2 (DL_INVENTORY_ITEMS categories) and 4 (DL_INVENTORY_PREPS categories) produce duplicate INVITEM_IDs when the same CategoryID exists in both DL tables (3 categories x 9 stores = 27 duplicates). These duplicates cause PK violations in `sp_PopulateLoadTable`, dooming the transaction (error 3930) and blocking ALL DV loads (MarketMan + NCRAloha).

**Fix:** Consolidates branches 2+4 into a single category branch that UNIONs (not UNION ALL) both DL tables before extracting categories. Also incorporates:
- H5 fix: `WHERE COGSCategoryID IS NOT NULL` on COGS top-level branch
- C10 fix: `WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL` on COGS subqueries

**Supersedes:** H5_invitems_category_fix.sql and C10_cross_store_invitems_fix.sql (all three MERGE the same StagingControl row; only the last deployed wins).

**Status:** Created 2026-03-11. Not yet deployed.

---

## Growyze Integration Scripts

All scripts in `integrations/Growyze/`. Created 2026-03-05. Based on approved design: `docs/plans/2026-03-05-growyze-staging-design.md`.

### 18. `integrations/Growyze/01_infrastructure.sql`

**Purpose:** Creates `core.reference` schema and `UOM_CONVERSION` table (14 seed records). Required before any other Growyze scripts. Targets the `core` database.

**Status:** Deployed 2026-03-05.

---

### 19. `integrations/Growyze/02_staging_tier1.sql`

**Purpose:** 11 Tier 1 StagingControl MERGE records for `int_growyze001`:
1. GRYZ_LOCATION (DL_ORGANIZATIONS, 7 orgs)
2. GRYZ_INVITEMS (DL_PRODUCTS, 3-tier hierarchy)
3. GRYZ_SUPPLIERS (DL_PRODUCTS + DL_ORDERS union)
4. GRYZ_OCCASION (sentinel -999 row)
5. GRYZ_PREP_RECIPES (DL_RECIPES ingredient links)
6. GRYZ_PRODUCT (DL_DISHES, 2-tier hierarchy)
7. GRYZ_STOCKORDER (DL_ORDERS, 1 row per order)
8. GRYZ_ORDER_ITEMS (DL_ORDERS line items)
9. GRYZ_LINEITEM (DL_SALESDETAIL + DL_DISHES + DL_SALES)
10. GRYZ_DN_EVENTS (DL_DELIVERYNOTES + product barcode resolution)
11. GRYZ_WASTE_EVENTS (DL_WASTES + name-based product resolution)

**Status:** Deployed 2026-03-05. **Fixed 2026-03-05:** CTE-in-derived-table syntax error (SQL Server error 156). All 9 queries with CTEs had `WITH` inside `FROM (...)` — invalid in SQL Server. Fix: moved CTEs before `SELECT * INTO`. Needs re-deploy.

---

### 20. `integrations/Growyze/03_staging_tier2_3.sql`

**Purpose:** 3 Tier 2+3 StagingControl MERGE records:
12. GRYZ_SALES (Tier 2 — sales depletion via recipe explosion + UOM conversion)
13. GRYZ_STOCKEVENT (Tier 2 — UNION ALL consolidation of DN + waste + sales events)
14. GRYZ_PRODUCT_INVITEM (Tier 3 — 4-way link: dish -> ingredient via direct + recipe paths)

**Status:** Created 2026-03-05. **Fixed 2026-03-05:** Same CTE syntax fix as 02_staging_tier1.sql. Needs deploy.

---

### 21. `integrations/Growyze/04_entity_mappings.sql`

**Purpose:** 23 EntityMappings MERGE records for `int_growyze001`:
- 9 hubs: INVITEM, LOCATION, SUPPLIER, PRODUCT, OCCASION, STOCKORDER, STOCKEVENT, CUSTORDER, LINEITEM
- 14 links: CUSTORDER_LINEITEM, CUSTORDER_LOCATION, CUSTORDER_OCCASION, LINEITEM_PRODUCT, LINEITEM_OCCASION, INVITEM_INVITEM, INVITEM_STOCKEVENT, INVITEM_STOCKORDER, LOCATION_STOCKEVENT, STOCKEVENT_STOCKORDER, DISTRIBUTOR_STOCKORDER_SUPPLIER, INVITEM_LOCATION_OCCASION_PRODUCT, INVITEM_OCCASION_PRODUCT, LOCATION_OCCASION_PRODUCT

**Status:** Deployed 2026-03-05.

**Deploy order:** 01_infrastructure → 02_staging_tier1 → 03_staging_tier2_3 → 04_entity_mappings

---

### 22. `integrations/Growyze/REPORTING_WISHLIST_ANALYSIS.md`

**Purpose:** Consolidated analysis of the Growyze customer reporting wishlist (18 reports from 8 customers). Maps each report to existing vis queries, assesses Growyze data coverage, and proposes 12 new datasets (22 vis query records).

**Key findings:**
- **7 FEASIBLE** — Recipe-based GP/margin queries using F_PRODUCT_MARGIN_DAY (Growyze populates NET_COST via SAT_LNK_LOCATION_OCCASION_PRODUCT)
- **4 PARTIAL** — Volume-based inventory queries work but UOM_COST = NULL (no INVREPORT equivalent)
- **7 BLOCKED** — Stocktake/reconciliation (no COUNT events), invoices (Phase 2), revenue streams (no channel data)

**Two root causes block most reports:**
1. **No COUNT events** — Growyze has no stocktake API, so `F_INV_COUNTS_DAY` produces zero rows. Blocks 6 reports.
2. **No INVREPORT data** — `F_INV_USAGE_DAY.UOM_COST` and `F_INV_SALES_DAY.UOM_COST` are NULL. Degrades 4 reports.

**Key design decisions:**
- Use F_PRODUCT_MARGIN_DAY (not F_INV_SALES_DAY) for GP queries — it has real AVG_NET_COST from Growyze
- Volume-based inventory ranking (not cost-based) for consumption/waste queries
- Recipe cost as COGS proxy — the best available measure for Growyze organisations

**Proposed: 12 datasets, 22 vis query records.** No new fact tables or presentation infrastructure required.

**Status:** Created 2026-03-06. Analysis document — no SQL to deploy.

---

### 23. `integrations/Growyze/06_purchases_presentation_table.sql`

**Purpose:** MERGE upsert for `core.PresentationTables` — adds `F_PURCHASES_DAY` DDL (14 columns, 3 indexes). One row per INVITEM x STOCKORDER line item exposing purchase pricing, supplier, and delivery data.

**Prerequisite:** `05_invitem_stockorder_entity_fix.sql` deployed (adds SAT_LNK_INVITEM_STOCKORDER attributes).

**Status:** Created 2026-03-06. Not deployed.

---

### 25. `12_uom_conversion_fix.sql`

**Purpose:** Replaces the hardcoded 10-row `UOMConversion` CTE in 3 inventory PresentationControl steps (F_INV_USAGE_DAY, F_INV_COUNTS_DAY, F_INV_SALES_DAY) with a `SELECT FROM [core].[reference].[UOM_CONVERSION]`. Also adds 4 MarketMan UOM records (`gr`, `lb`, `EA`, `Imperial Pint`) to the reference table so both integrations are covered.

**Fixes:**
- 61.7% of Growyze F_INV_USAGE_DAY rows had NULL STANDARDISED_UOM (Growyze UOMs like `g`, `kg`, `each`, `full`, `pt_UK` etc. not in the hardcoded MarketMan-only CTE)
- ORDER quantities understated by ~75% for Growyze
- Future-proofs UOM handling — new integrations just add rows to the reference table

**MarketMan impact:** Cosmetic only — STANDARDISED_UOM output changes from `gr`→`g` and `EA`→`each`. Case-insensitive collation (CI_AS) handles `Kg`↔`kg` and `Gal`↔`gal` matching. No numeric changes.

**Implementation:**
- Part 1: MERGE 4 MarketMan UOM records into `core.reference.UOM_CONVERSION` (total: 18 rows)
- Part 2: Cursor-based REPLACE across 3 PresentationControl steps — dynamically extracts old CTE body using start/end markers, replaces with single-line reference table SELECT. Preserves column aliases so downstream query references are unaffected.
- Part 3: Verification SELECT confirms all 3 steps reference the table and no hardcoded CTE remains.

**Idempotent:** Yes — MERGE upsert + LIKE guard on cursor prevents double-application.

**Status:** Created 2026-03-09. **DEPLOYED** 2026-03-09.

---

### 24. `integrations/Growyze/07_purchases_presentation_control.sql`

**Purpose:** MERGE upsert for `core.PresentationControl` — adds "Purchases by Day" build step (Tier 1). Joins LNK_INVITEM_STOCKORDER + SAT_LNK (qty/price/cost) with SAT_STOCKORDER (dates/status), SUPPLIER via ternary link, LOCATION via delivery event chain (STOCKEVENT_STOCKORDER → LOCATION_STOCKEVENT). Filtered by STOCKEVENT_START/END.

**Design doc:** `docs/plans/2026-03-06-purchases-fact-design.md`

**Deploy order:** 06 → 07 (table DDL before build step).

**Secondary benefit:** Enables UOM_COST derivation from latest purchase price — follow-up enhancement to enrich F_INV_USAGE_DAY/F_INV_COUNTS_DAY for Growyze orgs without INVREPORT.

**Status:** Created 2026-03-06. Not deployed.

---

### 26. `fix_standardised_uom_width.sql`

**Purpose:** Widens `STANDARDISED_UOM` column from `VARCHAR(2)` to `VARCHAR(255)` on two presentation tables: `F_INV_COUNTS_DAY` and `F_INV_USAGE_DAY`. The original `VARCHAR(2)` was too narrow for standard UOM values from the `UOM_CONVERSION` reference table (`each` = 4 chars, `portion` = 7, `percentage` = 10).

**Error:** `String or binary data would be truncated in table ...F_INV_USAGE_DAY, column 'STANDARDISED_UOM'. Truncated value: 'ea'.`

**Deploy:** Run against each org database with inventory presentation tables. Safe to re-run (ALTER COLUMN is idempotent).

**Note:** The DDL definitions in `8_PresentationTables.sql` still say `VARCHAR(2)` — update those when next editing that file.

**Status:** Created 2026-03-11. Not deployed.

---

### 27. `Deploy/growyze_report_db_dev.sql`

**Purpose:** Configures the DEV microservice `report` database so the GrowyzeDev organisation can render 18 inventory visualisation cards across 3 dashboards. Inserts 59 rows across 7 tables in a single transaction.

**Tables modified:**
| Table | Rows | What |
|---|---|---|
| BiConfig | 1 | Maps GrowyzeDev (94A4B719-...) to MI database (DbPrefix=20251208) |
| VisualisationConfig | 8 | Grants card types: BarChart, Combined, DataGrid, GroupedGrid, MultiLine, Pie, StackedBar, FilterList |
| VisualisationDataSetMap | 20 | Wires 12 Inv* datasets + Locations + InvItems to card types |
| DashboardGrid | 3 | Creates 3 grid containers |
| DashboardGridItem | 18 | Places cards with responsive breakpoints (xs/sm/md/lg/xl) |
| DashboardGridFilter | 6 | Locations + InvItems filters on each dashboard |
| OrganisationDashboardConfig | 3 | "Cost & Margins", "Stock Activity", "Period Analysis" |

**Dashboards:**
- **Cost & Margins** (5 cards): InvCOGSByCategory (Pie+Stacked), InvMarginTrend (MultiLine), InvMargeBrut (GroupedGrid), InvTheoVsActualGP (Combined)
- **Stock Activity** (7 cards): InvConsumption (Bar+Grid), InvWasteAnalysis (Bar+MultiLine+Grid), InvStockActivity (Stacked+MultiLine)
- **Period Analysis** (6 cards): InvWeeklySummary (Combined+Grid), InvPeriodCompWoW/MoM/YoY (3x Combined), InvVarianceCategory (Stacked)

**Gotchas discovered during deployment:**
- `TransactionId` is `bigint IDENTITY` — must be omitted from INSERT column lists (auto-incremented)
- `IsDeleted` is `bit NOT NULL` with no DEFAULT — must be explicitly set to `0` in every INSERT

**Status:** Created 2026-03-11. Deployed and verified 2026-03-11.

**Verification results (8/8 PASS):**
| Check | Expected | Actual | Result |
|---|---|---|---|
| BiConfig row | 1 row, DbPrefix=20251208 | 1 row, correct | PASS |
| VisualisationConfig | 8 card types (1,2,3,4,8,9,11,14) | 8 rows | PASS |
| VisualisationDataSetMap | 20 dataset mappings | 20 rows | PASS |
| OrganisationDashboardConfig | 3 dashboards | 3 rows, correct names | PASS |
| DashboardGridItem | 18 cards (5+7+6) | 18 rows, correct breakpoints | PASS |
| DashboardGridFilter | 6 filters | 6 rows, 2 per dashboard | PASS |
| Smoke: SP wiring | 18 chart rows with ProcedureName | 18 rows | PASS |
| Smoke: MI vis queries LIVE | 20 LIVE queries | 20 rows | PASS |

---

### 28. `suggestions/01_suggestion_templates_table.sql`

**Purpose:** Creates `core.core.SuggestionTemplates` table for storing configurable text templates with `{placeholder}` tokens. Templates are referenced by VisualisationQueries at runtime and replaced with computed values.

**Columns:** TemplateID (PK IDENTITY), TemplateName (UQ), Category, Severity (INFO/WARNING/ERROR), OutputType (Banner/Section), TemplateText, SortOrder, IsActive, CreatedDate, ModifiedDate.

**Status:** Created 2026-03-11. Not deployed.

---

### 29. `suggestions/02_fix_markdowncard_sp.sql`

**Purpose:** MERGE fix for the MarkdownCard DeploymentObjects record. Dev release scripts have a bug: the SP references `VisualizationType = 'BarChartCard'` instead of `'MarkdownCard'`, and error messages reference `CustomDataGrid`. This script corrects both to match the UAT-deployed version.

**Status:** Created 2026-03-11. Not deployed.

---

### 30. `suggestions/03_add_staticboxcard_sp.sql`

**Purpose:** MERGE to add the StaticBoxCard SP to DeploymentObjects (ExecutionOrder 65). This SP exists in UAT but is missing from dev release scripts.

**Status:** Created 2026-03-11. Not deployed.

---

### 31. `suggestions/04_seed_inventory_templates.sql`

**Purpose:** Seeds 6 SuggestionTemplates records for the Inventory category: 2 Banner templates (InvMissingRecipesBanner, InvHighVarianceBanner) + 4 Section templates (InvMissingRecipesSection, InvHealthSection, InvKeyMetricsSection, InvRecommendationSection). All use MERGE on TemplateName for idempotency.

**Status:** Created 2026-03-11. Not deployed.

---

### 32. `suggestions/05_inventory_banner_queries.sql`

**Purpose:** Replaces the hardcoded static `InvMMHeader` and `InvMMHeader2` StaticBoxCard VisualisationQueries with data-driven versions:

- **InvMMHeader (Missing Recipes Banner):** Counts distinct leaf products in D_PRODUCT with no entry in either recipe link table (LNK_INVITEM_OCCASION_PRODUCT, LNK_INVITEM_LOCATION_OCCASION_PRODUCT). Returns severity=warning row only when count > 0. Org-wide — no @FilterClause (recipes are product property, not location/date-specific). Filters BOTTOM_IS_DELETED.
- **InvMMHeader2 (High Variance Banner):** Calculates `SUM(ABS(VARIANCE)) / SUM(ABS(THEO_USAGE)) * 100` from F_INV_COUNTS_DAY. Returns severity=error row only when variance > 15%. Filter-aware via @FilterClause.

**MCP Test Results (UAT — Three Rocks Cafe):**
- Missing recipes banner: Returns 1 row — "106 menu items are missing recipes" (severity=warning). ✓
- High variance banner: Returns 1 row — variance > 15% (severity=error). ✓

**Status:** Created 2026-03-11. Tested via MCP. Not deployed.

---

### 33. `suggestions/06_inventory_analysis_query.sql`

**Purpose:** Replaces the hardcoded static `InvMMHeader` MarkdownCard VisualisationQuery with a data-driven version. Computes missing recipe count + variance %, joins to SuggestionTemplates Section records, replaces `{placeholder}` tokens, and returns concatenated markdown via STRING_AGG. Returns zero rows when no conditions are met (missing_count = 0 AND variance_pct <= 10).

**Sections rendered:** Missing Recipes, Inventory Health, Key Metrics, Recommendation.

**MCP Test Results (UAT — Three Rocks Cafe):**
- Returns 1 row with all 4 sections rendered correctly. ✓
- All placeholder tokens fully replaced. ✓
- Correct recommendation for 106 missing recipes + >15% variance. ✓
- Zero-row behaviour verified with simulated low metrics. ✓

**Status:** Created 2026-03-11. Tested via MCP. Not deployed.

---

### Suggestion System Deploy Order

```
01_suggestion_templates_table.sql     → Core DB (creates table)
02_fix_markdowncard_sp.sql            → Core DB (fixes DeploymentObjects)
03_add_staticboxcard_sp.sql           → Core DB (adds DeploymentObjects)
   ↓
   sp_DeployObjects                   → Propagates SPs to all client DBs
   ↓
04_seed_inventory_templates.sql       → Core DB (seeds templates)
05_inventory_banner_queries.sql       → Core DB (replaces VisualisationQueries)
06_inventory_analysis_query.sql       → Core DB (replaces VisualisationQueries)
```

---

### 34. `neighbours-dashboard/02_challenging_environment.sql`

**Purpose:** Creates the Challenging Issues and Environment survey dashboards on UAT for the Neighbours - Eastleigh organisation. These dashboards do not exist on UAT — the script creates new DashboardGrid, DashboardGridItem, DashboardGridFilter, and OrganisationDashboardConfig rows mirroring the DEV configuration.

**Source (DEV):**
- Challenging Issues grid: `1CA5573D-6EA3-F011-B3CD-000D3AD9E35E`
- Environment grid: `1DA5573D-6EA3-F011-B3CD-000D3AD9E35E`

**Target:** UAT report DB, Neighbours - Eastleigh (`OrganisationId = 3EBF26FE-E14A-40ED-A355-9A411B1273B4`)

**Rows generated:**
| Table | Rows |
|---|---|
| DashboardGrid | 2 |
| DashboardGridItem | 7 (5 Challenging Issues, 2 Environment; 2 soft-deleted to match DEV) |
| DashboardGridFilter | 2 (both on Challenging Issues; Environment has no filters) |
| OrganisationDashboardConfig | 2 |

**Datasets used:**
- Challenging Issues: SurveyChallengingRadar (Vis 15), SurveyRespondentByChallenge (Vis 11), SurveyAverageChallengeScore (Vis 9, deleted), SurveyChallengeThoughts (Vis 3, deleted), SurveyChallengeThoughtsnonChurch (Vis 3)
- Environment: SurveyEnvironmentRadar (Vis 15), SurveyRespondentByEnvironment (Vis 11)
- Filters: SurveyFilterAge (SortOrder 6), SurveyFilter (SortOrder 7)

**Status:** Created 2026-03-12. Not yet deployed to UAT.

---

### 35. `neighbours-dashboard/01_survey_overview_lifestyle.sql`

**Purpose:** Populates `DashboardGridItem` and `DashboardGridFilter` rows for the "Survey Overview" and "Lifestyle Provision" dashboards on UAT for the "Neighbours - Eastleigh" organisation.

**Source data:** Extracted from DEV report DB (grids `6ABCCBA2-4FA3-F011-B3CD-000D3AD9E35E` and `1BA5573D-6EA3-F011-B3CD-000D3AD9E35E`). Only active rows (IsDeleted = 0) are migrated; 5 deleted DEV rows are intentionally excluded.

**Target UAT grids (pre-existing, empty):**
- Survey Overview: `E4026650-A359-4D92-BF90-8BD6051EB144`
- Lifestyle Provision: `B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2`

**Rows inserted:**

| Dashboard | Table | Dataset | VisualisationId | SortOrder | Spans (XS/S/M/L/XL) |
|---|---|---|---|---|---|
| Survey Overview | DashboardGridItem | SurveyCompletion | 11 | 0 | 12/12/4/4/4 |
| Survey Overview | DashboardGridItem | SurveyGenderByRespondentTotal | 9 | 1 | 12/12/4/4/4 |
| Survey Overview | DashboardGridItem | SurveyAgeByRespondentTotal | 1 | 1 | 12/12/4/4/4 |
| Survey Overview | DashboardGridItem | SurveyAgeByGender | 3 | 1 | 12/NULL/NULL/NULL/NULL |
| Survey Overview | DashboardGridFilter | SurveyFilter | — | 4 | — |
| Lifestyle Provision | DashboardGridItem | SurveyLifestyleRadar | 15 | 1 | 12/12/4/4/4 |
| Lifestyle Provision | DashboardGridItem | SurveyRespondentByLifestyle | 11 | 2 | 12/12/8/8/8 |
| Lifestyle Provision | DashboardGridItem | SurveyLifestyleProvisionThoughtsnonChurch | 3 | 4 | 12/NULL/NULL/NULL/NULL |
| Lifestyle Provision | DashboardGridFilter | SurveyFilter | — | 5 | — |
| Lifestyle Provision | DashboardGridFilter | SurveyFilterAge | — | 8 | — |

**Total:** 7 DashboardGridItem rows + 3 DashboardGridFilter rows = 10 rows

**Status:** Created 2026-03-12. Not yet deployed to UAT.

---

### 36. `inventory-variance-fix/13_dedup_presentation_tables.sql`

**Purpose:** Fixes F_INV_DAILY_DETAIL build failure ("Cannot insert the value NULL into column 'THEO_USAGE'") caused by duplicate PresentationTables records in the core control table.

**Root cause:** 4 tables had duplicate PresentationTables records (F_INV_DAILY_DETAIL ×3, E_INV_DAILY_DETAIL ×2, F_PRE_INV_DAILY_DETAIL ×2, FORECAST_ACTUALS_BASE ×2). The `DeployPresentationTables` cursor processes ALL duplicates (drop + recreate each), and whichever DDL runs last wins non-deterministically. F_INV_DAILY_DETAIL was created from an old DDL with `THEO_USAGE NOT NULL`, but E_INV_DAILY_DETAIL legitimately contains NULL THEO_USAGE rows that flow into the UNION-based build query.

**Phase 1:** Deletes old duplicate PresentationTables records, keeping only the newest (correct) one per table:
- F_INV_DAILY_DETAIL: delete 2, keep `DD6F3767` (all event columns NULL)
- E_INV_DAILY_DETAIL: delete 1, keep `A352864E` (has `[presentation].` schema prefix)
- F_PRE_INV_DAILY_DETAIL: delete 1, keep `E18E20F7`
- FORECAST_ACTUALS_BASE: delete 1, keep `7B22A07B`

**Phase 2:** ALTERs the 6 NOT NULL columns on the physical F_INV_DAILY_DETAIL table (THEO_USAGE, ORDER_QTY, SALE_QTY, PRODUCTION_QTY, TRANSFER_QTY, WASTE_QTY) to nullable on all org databases.

**Post-deploy:** Re-trigger presentation build for affected orgs.

**Status:** Created 2026-03-12. Not yet deployed.

---

### 37. `inventory-variance-fix/14_variance_uom_display_fix.sql`

**Purpose:** Fixes the `InvTop20Variance` StackedBarChartCard displaying raw g/ml quantities without conversion, making values like 22,300g appear as "22,300 onions" on the chart.

**Changes to the query:**
1. **UOM conversion:** Divides g/ml quantities by 1000 for display (→ kg/L). `each` items unchanged.
2. **Ranking:** Changed from `ABS(SUM(VarianceQty))` to `ABS(SUM(VarianceValue))` — ranks by £ cost impact instead of raw quantity, which is on a consistent scale across all UOMs.
3. **GROUP BY:** Added `FC.STANDARDISED_UOM` to the inner subquery for the CASE expression.

**MCP test results (Kudu UAT, 05-12 Mar 2026):**

| Item | Old Qty | New Qty | Value (£) | UOM |
|---|---|---|---|---|
| apricot harissa | -2 | -2 | -9,370 | each |
| Beef Lombata | 176,450 | 176.45 | 4,358 | g→kg |
| Potato Pink Fir | -145,000 | -145 | -414 | g→kg |
| Poussin | -122 | -122 | -415 | each |

Top 20 now ranked by value impact — high-£-impact items surface instead of high-gram items.

**Status:** Created 2026-03-12. MCP tested — PASS. Not yet deployed (inventory-variance-fix/14).

---

### 38. `inventory-variance-fix/15_waste_costs_abs_fix.sql`

**Purpose:** Fixes the `InvTheoMargin` PieChartCard showing "Waste Costs: -79" as a negative segment. `WASTE_QTY` is stored negative in `F_INV_COUNTS_DAY` (stock-OUT convention), but the query passed this through without ABS(), causing waste to inflate profit instead of reducing it.

**Change:** Wrapped `ROUND(SUM(WasteVal),2)` with `ABS()` in the Inventory CTE:
```
-- Before
ROUND(SUM(WasteVal),2) AS Waste
-- After
ABS(ROUND(SUM(WasteVal),2)) AS Waste
```

**MCP test results (Kudu UAT, 05-12 Mar 2026):**

| Segment | Before | After |
|---|---|---|
| Waste Costs | -79 | **79** |
| Profit Margin | 79,895 | **79,738** |
| Variance Costs | 23,218 | 23,218 |
| Recipe Costs | 0 | 0 |
| Net Sales | 103,034 | 103,034 |

Arithmetic: 79,738 + 0 + 79 + 23,218 = 103,035 ≈ 103,034.29 (rounding). Balances correctly.

**Status:** Created 2026-03-12. MCP tested — PASS. Not yet deployed (inventory-variance-fix/15).

---

### 39a. `inventory-variance-fix/16_variance_sort_ascending.sql`

**Purpose:** Changes the Top 20 Variance Items bar chart sort order from absolute value (ABS) to ascending by value, so the chart flows from most negative (left) to most positive (right).

**Change:** In the outer query's UNION ALL, replaces `ABS(Variance) AS SORT` with `Variance AS SORT` for both the Value and Quantity branches. The `ROW_NUMBER() OVER(ORDER BY SORT)` then produces an ascending left-to-right layout by actual value.

**Status:** Created 2026-03-23. Not yet deployed.

---

### 39b. `inventory-variance-fix/17_end_date_window_fix.sql`

**Purpose:** Fixes `sp_UpdateEntityDeltaParameters` so the END date parameter covers the full final day. MarketMan COUNT events are timestamped at `23:59:59`. The sproc was casting `MAX(EVENT_TS)` to DATE (= midnight `00:00:00`), so `BETWEEN ... AND '2026-03-22 00:00:00'` excluded events at `23:59:59`. No COUNT data has flowed into `F_INV_COUNTS_DAY` via automated runs since the inventory-variance-fix deployment on Mar 12 — all existing data was from the manual rebuild.

**Fix:** Changes the END parameter to `DATEADD(DAY, 1, CAST(CAST(@MaxValue AS DATE) AS DATETIME2))` — adds 1 day so the window ends at midnight of the NEXT day, covering all timestamps on the max date. Also updates the comparison clause for consistency.

**Affects:** All time-series entity delta parameters (STOCKEVENT, LINEITEM, etc.) — the fix is generic to the sproc, not STOCKEVENT-specific. All entities benefit from the full-day coverage.

**Deploy:** Update `DeploymentObjects` record → run `sp_DeployObjects` to push the new sproc to all org databases. Next scheduled DV load will pick up the fix automatically.

**Status:** Created 2026-03-23. **Deployed to UAT 2026-03-23.**

---

### 39. `suggestions/07_recipe_cost_section.sql`

**Purpose:** Adds a dynamic Recipe Cost / POS integration check to the `InvMMHeader` MarkdownCard. Detects when an organisation has inventory count data but no recipe usage (SALE_QTY) flowing, and renders an advisory section explaining the POS integration gap.

**Changes (3 MERGE statements):**
1. **New SuggestionTemplate:** `InvRecipeCostSection` (SortOrder 25, between Health and Key Metrics). Renders only when `recipe_data_missing = 1`.
2. **Updated SuggestionTemplate:** `InvKeyMetricsSection` — adds `{recipe_cost_brief}` placeholder showing "Not available (no POS link detected)" or "Active".
3. **Updated InvMMHeader MarkdownCard query:**
   - New metric: `recipe_data_missing` — checks `COUNT(*) > 0 AND SUM(ABS(SALE_QTY)) = 0` in `F_INV_COUNTS_DAY` within the filter range
   - New CASE branch for `InvRecipeCostSection` rendering (returns NULL when recipe data IS flowing → section auto-hides)
   - Updated WHERE: `OR m.recipe_data_missing = 1` to show the card when recipe issue exists
   - Updated `InvRecommendationSection` rendering: accounts for recipe + variance combinations

**Dynamic behaviour:**
- `recipe_data_missing = 1` → Recipe Costs section renders with POS integration advisory
- `recipe_data_missing = 0` → Recipe Costs section hidden, Key Metrics shows "Active"
- Works for any org — evaluates each org's own `F_INV_COUNTS_DAY` data

**MCP test results (Kudu UAT, 05-12 Mar 2026):**
- `recipe_data_missing = 1` (Kudu has INVENTORY only, no POS in MarketMan)
- Rendered markdown includes 5 sections: Missing Recipes, Inventory Health, **Recipe Costs**, Key Metrics, Recommendation
- Recipe Costs section shows: "No recipe usage data available" + POS integration advisory
- Recommendation combines: POS config + variance investigation

**Status:** Created 2026-03-12. MCP tested — PASS. Not yet deployed.

---

### 40. `parent-org/10_dashboard_vis_queries.sql`

**Purpose:** Inserts 9 VisualisationQueries MERGE records for the parent org "Group Overview" dashboard. 7 new chart/KPI queries + 2 FilterList queries.

**Datasets:**
| DataSetName | VisualizationType | Source Table |
|---|---|---|
| ParentOrderCount | SingleKPICard | PF_REVENUE_DAY |
| ParentAvgOrderValue | SingleKPICard | PF_REVENUE_DAY |
| ParentProfitByOrg | StackedBarChartCard | PF_PROFIT_DAY |
| ParentDiscountImpact | BarChartCard | PF_PROFIT_DAY |
| ParentEfficiencyByOrg | StackedBarChartCard | PF_INVENTORY_EFFICIENCY_DAY |
| ParentGrowthSummary | CustomDataGrid | PF_GROWTH_PERIOD |
| ParentOrgSummaryTable | CustomDataGrid | PF_REVENUE_DAY + PF_PROFIT_DAY + PF_FOODCOST_DAY + PF_INVENTORY_EFFICIENCY_DAY (4 CTEs) |
| ParentOrganisations | FilterList | PD_ORGANISATION |
| ParentLocations | FilterList | PD_LOCATION |

**Design doc:** `docs/plans/2026-03-16-parent-org-dashboard-design.md`

**Key patterns:**
- Uses NCHAR(163) for £ symbol in N'...' strings
- ParentGrowthSummary: `WHERE F.[LOCATION_HUB_ID] IS NOT NULL` to avoid double-counting with org-level aggregate rows
- ParentOrgSummaryTable: 4 CTEs with identical aliases (C, org, location) so single @FilterClause replacement works uniformly
- FilterList queries have empty `{}` FilterDefinitions and ParameterMappings

**Status:** Created 2026-03-16. Not yet tested or deployed.

---

### 41. `parent-org/11_report_db_config.sql`

**Purpose:** Configures the microservice `report` database for the parent org "Group Overview" dashboard. Targets Nabil Enterprises (`5C4F9C3D-2704-F111-8D4C-000D3AB579E6`).

**Rows inserted:**
| Table | Rows | Detail |
|---|---|---|
| VisualisationConfig | 4 | Card types 1, 3, 4, 8 (parent already has 2, 9, 10, 11, 16, 17) |
| VisualisationDataSetMap | 11 | All card datasets wired to matching card types |
| DashboardGrid | 1 | 12-column responsive grid |
| OrganisationDashboardConfig | 1 | "Group Overview", icon=CorporateFare, sort=0 |
| DashboardGridItem | 11 | 3 KPIs (4-col) + 6 charts (6/12-col) + 2 grids (6/12-col) |
| DashboardGridFilter | 2 | ParentOrganisations, ParentLocations |

**Cleanup:** Soft-deletes 2 stale VisualisationDataSetMap entries (InvTheoMargin, InvCountVariance) — child-level datasets that shouldn't be on the parent org.

**Design doc:** `docs/plans/2026-03-16-parent-org-dashboard-design.md` §6

**Status:** Created 2026-03-16. Not yet deployed.

---

### 42. `integrations/survey-hero/04_fix_barchart_kpi_totals.sql`

**Purpose:** Fixes 4 BarChartCard queries where the KPI header shows "0.00" instead of the actual respondent count. Root cause: `NULL AS TotalValue` in the header SELECT — the frontend renders NULL as "0.00".

**Fix:** Replaces `NULL AS TotalValue` with a `COUNT(DISTINCT TOUCHPOINT_HUB_ID)` correlated subquery (same pattern as the working `SurveyAgeByRespondentTotal` query). Each subquery includes `@FilterClause` so filters work correctly.

**Affected datasets:**
| DataSetName | Page | Question |
|---|---|---|
| SurveyMembersDistance | Church Members | 'How far do you travel to the church ?' |
| SurveyMembersTravel | Church Members | 'How do you usually get to the church ?' |
| SurveyMemberActivities | Church Members | 'Which of the following do you regularly attend?' |
| SurveyBuildingUse (BarChartCard) | Building Use | 'Which of the following do you regularly attend?' |

**Run against:** core database

**Status:** Created 2026-03-16. Not yet deployed.

---

### 43. `integrations/survey-hero/05_fix_challenging_issues_title.sql`

**Purpose:** Fixes duplicate chart title on the Challenging Issues dashboard page. Both the RadarChartCard (`SurveyChallengingRadar`) and StackedBarChartCard (`SurveyRespondentByChallenge`) show "Average Score by Provision" as their title. The bar chart title is updated to "Average Score by Challenging Issue".

**Run against:** core database

**Status:** Created 2026-03-16. Not yet deployed.

---

### 44. `integrations/survey-hero/06_fix_extra_thoughts_junk_filter.sql`

**Purpose:** Adds junk/filler data filtering to all 8 free-text survey vis queries. Current filter only checks `LEN > 0`. New filter adds:
1. Minimum length `>= 3` — removes punctuation-only and single-char entries
2. Explicit exclusion list — removes "none" (864 occurrences!), "test", "testing", "asd", "nil", "n/a", and common misspellings of "none" ("mone", "nono", "nonr", "nonw", "noe", "none.")

**Impact:** Removes ~960 junk rows (69% of 1,389 displayed) while preserving all 413 legitimate responses.

**Affected datasets (8):**
- 7 × CustomDataGrid: SurveyLifestyleProvisionThoughts, SurveyLifestyleProvisionThoughtsnonChurch, SurveyChallengeThoughts, SurveyChallengeThoughtsnonChurch, SurveyEnvironmentThoughts, SurveyVisitorMessage, SurveyImprovementsNeeded
- 1 × SingleKPICard: SurveyLifestyleThoughts

**Run against:** core database

**Status:** Created 2026-03-16. Not yet deployed.

---

### 45. `integrations/survey-hero/07_fix_environment_dashboard_wiring.sql`

**Purpose:** Adds missing Extra Thoughts card and both filters to the Environment dashboard page in the report DB. The `SurveyEnvironmentThoughts` vis query exists in core but was never wired into the dashboard grid. The Lifestyle and Challenging Issues pages both have these items; Environment was an oversight.

**Inserts:**
| Table | Row | Detail |
|---|---|---|
| DashboardGridItem | 1 | VisualisationId=3, DataSet='SurveyEnvironmentThoughts', SortOrder=4, ExtraSmall=12 |
| DashboardGridFilter | 2 | 'SurveyFilter' (sort 5) + 'SurveyFilterAge' (sort 8) |

**Target grid:** `0AFCD2C4-C311-4122-BB41-DF9C37B90AC0` (Environment page for Neighbours - Eastleigh)

**Run against:** microservice report database (UAT: xms-mssql-ne-uat, `report` DB)

**Status:** Created 2026-03-16. Not yet deployed.

---

### 46. `integrations/Growyze/reporting_queries/13_stock_activity_fixes.sql`

**Purpose:** Fixes COALESCE order bug in all 9 vis query records used by the "Stock Activity" dashboard. All queries had `COALESCE(MICROSERVICE_NAME, NATIVE_NAME)` — because Growyze always populates `MICROSERVICE_NAME = 'growyze'`, every label displayed "growyze" instead of the real item/location name.

**Records covered (all 9 MERGE upserts):**

| DataSetName | VisualizationType | Additional fix |
|---|---|---|
| InvConsumption | BarChartCard | Added TotalValue KPI subquery (was NULL — showed 0.00) |
| InvConsumption | CustomDataGrid | COALESCE order only |
| InvWasteAnalysis | BarChartCard | COALESCE order only |
| InvWasteAnalysis | CustomDataGrid | COALESCE order only |
| InvWasteAnalysis | MultiLineChartCard | COALESCE order only |
| InvStockActivity | StackedBarChartCard | COALESCE order only |
| InvStockActivity | MultiLineChartCard | COALESCE order only |
| InvItems | FilterList | COALESCE order (BOTTOM/MIDDLE_1/TOP all 3 levels) |
| Locations | FilterList | COALESCE order in SAT_LOCATION query |

**Fix applied everywhere:** `COALESCE(NATIVE_NAME, MICROSERVICE_NAME)` — native name first, microservice name as fallback. Safe for NCRAloha/MarketMan (their MICROSERVICE_NAME = NULL).

Also fixes FilterDefinitions JSON and ParameterMappings JSON in all 7 vis query records (filter injection would also have used wrong column references).

**MCP test results (Padel Social, 2026-03-17):**
- InvConsumption BarChartCard data: Top items show real names (MAHOU 50 L KEG, STELLA ARTOIS UNFILTERED, etc.). TotalValue = "410,520". ✓
- InvWasteAnalysis BarChartCard TotalValue subquery: Returns "8,793". ✓
- InvWasteAnalysis MultiLineChartCard: Category lines show "Beverages", "Food", "Retail" by week. ✓
- InvStockActivity StackedBarChartCard locations: "Earls Court", "Padel Social Club", "O2" etc. ✓
- InvStockActivity MultiLineChartCard weekly trend: Orders/Sales/Waste lines across weeks from 2024. ✓
- InvItems FilterList: Items show real names with subcategory parents (Water, Soft Drinks, etc.). ✓
- Locations FilterList: 7 real location names. ✓

**Status:** Created 2026-03-17. Not yet deployed.

---

### 47. `integrations/Growyze/reporting_queries/14_period_analysis_fixes.sql`

**Purpose:** Fixes COALESCE order bug in all 6 vis query records used by the "Period Analysis" dashboard. All queries had `COALESCE(MICROSERVICE_NAME, NATIVE_NAME)` — because Growyze always populates `MICROSERVICE_NAME = 'growyze'`, every location/product/category label displayed "growyze" instead of the real name.

**Records covered (all 6 MERGE upserts):**

| DataSetName | VisualizationType | Notes |
|---|---|---|
| InvWeeklySummary | CombinedChartCard | COALESCE order only |
| InvWeeklySummary | CustomDataGrid | COALESCE order only (Location column was showing "growyze") |
| InvPeriodCompWoW | CombinedChartCard | COALESCE order only |
| InvPeriodCompMoM | CombinedChartCard | COALESCE order only |
| InvPeriodCompYoY | CombinedChartCard | COALESCE order only |
| InvVarianceCategory | StackedBarChartCard | COALESCE order only — card still shows "No data" for Growyze (no stock count data) |

**Fix applied everywhere:** `COALESCE(NATIVE_NAME, MICROSERVICE_NAME)` — native name first, microservice name as fallback. Safe for NCRAloha/MarketMan (their MICROSERVICE_NAME = NULL). Applied in QueryTemplate, ParameterMappings, and FilterDefinitions on all 6 records.

**Note on InvVarianceCategory:** The card legitimately shows "No data to display" for Growyze because it requires F_INV_COUNTS_DAY data (stock count variances), which Growyze does not provide. All computed variance values are 0 (no Counts rows via the LEFT JOIN), filtered out by `WHERE Value > 0`. The COALESCE fix is applied for correctness and future-proofing.

**MCP test results (Padel Social, 2026-03-17):**
- InvWeeklySummary grid (NATIVE_NAME first): Real location names "Earls Court", "O2", "Padel Social Club" with per-location rows across W10 and W11 2026. ✓
- InvWeeklySummary chart: W10 Revenue=10,327.76, COGS=3,094.49, GP%=70.0; W11 Revenue=2,067.33, COGS=541.18, GP%=73.8. ✓
- InvPeriodCompWoW: 20 rows returned, current/prior week aligned correctly. ✓
- InvVarianceCategory: Returns 0-value rows (all filtered by WHERE Value > 0) — correct "no data" behaviour. ✓

**Status:** Created 2026-03-17. Not yet deployed.

---

### 48. `integrations/Growyze/12_stocktake_staging.sql`

**Purpose:** Adds stock count (EVENT_TYPE = 'COUNT') support to the Growyze integration using the three new `DL_STOCKTAKE*` tables. Two StagingControl changes:

1. **NEW Step 15 — GRYZ_COUNT_EVENTS (Tier 1):** Stages completed stocktake report products. Joins `DL_STOCKTAKEREPORTPRODUCTS` → `DL_STOCKTAKEREPORTS` (for timestamp) → `DL_PRODUCTS` (for product ID). Key transforms: `quantity × size` → base-UOM total; UOM mapping (`each`→`EA`, `g`→`gr`, `kg`→`Kg`); NULL quantity → 0; only COMPLETED reports staged.

2. **UPDATED Step 13 — GRYZ_STOCKEVENT (Tier 3):** Adds `UNION ALL` for `[stage].[GRYZ_COUNT_EVENTS]`. Also fixes INTERNAL_REF bug — was delivery note ID / waste ID / sales detail ID for non-count events; now `itemId` (product ID) for ALL branches. Required because `F_INV_COUNTS_DAY` partitions by `(INTERNAL_REF, LOCATION_HUB_ID)` to group movements within count intervals.

**MCP test results (GrowyzeDev / Padel Social Club, 2026-03-17):**
- 903 total rows, 903 distinct SRC_KEYs (no duplicates) ✓
- 6 completed reports staged (1 IN_PROGRESS correctly filtered out) ✓
- 532 distinct items, 2 distinct orgs ✓
- All 6 UOM values map to supported pipeline values (0 unsupported) ✓
- UOM breakdown: cl=330, ml=228, EA=165, L=100, gr=46, Kg=34

**Status:** Created 2026-03-17. Not yet deployed.

---

### 48b. `integrations/Growyze/14_dn_events_size_multiplier_fix.sql`

**Purpose:** Fixes Step 10 (Growyze DN Events) so ORDER `UOM_QUANTITY` is the base-UOM total (`receivedQty × size`) instead of the raw pack count. Root cause of the very high positive variance observed on the Growyze inventory variance dashboards (Dirty Sixth, Padel Social, any Growyze org with significant packaged-goods inventory).

**Symptom:** F_INV_COUNTS_DAY.VARIANCE strongly positive — ACTUAL stock appears far above the (PREVIOUS + ORDERS − SALES − WASTE) expected level. COUNT events store `quantity × size` (added 2026-03-17 in 12_stocktake_staging.sql) and SALE events store recipe-exploded base-UOM totals, but ORDER events were storing only the pack count. For packaged drinks (70cl bottles, 200ml mixers, 330ml cans, etc.) orders were 70–850× too small, so EXPECTED was vastly understated.

**Sample evidence (Dirty Sixth UAT, 2026-05-18):**

| UOM | Current sum | Fixed sum | Factor |
|---|---:|---:|---:|
| ml | 1,926 | 808,824 | 420× |
| g | 857 | 285,544 | 333× |
| cl | 2,017 | 139,697 | 69× |
| L | 1,772 | 48,870 | 28× |
| kg | 5,900 | 22,787 | 3.9× |
| each | 1,733 | 11,321 | 6.5× |

**Fix:** `UOM_QUANTITY = TRY_CAST(receivedQty AS DECIMAL(18,6)) * COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(18,6)), 0), 1)` — falls back to raw qty when size is missing/zero so bulk ingredients (size = 1) are unaffected.

**MCP test result (Dirty Sixth UAT, 2026-05-18):** Staging body runs cleanly, returns 5,719 rows / 5,187 distinct SRC_KEYs across 7 UOMs. Post-Tier-3 dedup on (SRC_KEY, EVENT_BEHAVIOUR) will collapse the duplicate fetch snapshots to the same ~5,227 distinct events currently in SAT_STOCKEVENT — only UOM_QUANITY values change.

**Deployment:** Run script → UploadStagingControl for int_growyze001 → re-run sp_Staging for every Growyze org (Padel Social, Dirty Sixth, GrowyzeDev) → re-run sp_DataVaultLoad (CDC will write new SAT_STOCKEVENT versions for every existing ORDER hub and recompute presentation layer).

**Out of scope:** Step 11 Waste Events (totalQty already a base-UOM total; volumes negligible); UOM string normalisation between ORDER ('kg'/'g'/'each') and COUNT ('Kg'/'gr'/'EA') events (a tidy-up — orders currently still reach F_INV_COUNTS_DAY).

**Status:** Created 2026-05-18. Not yet deployed.

---

### 49. `integrations/Growyze/13_stocktake_ddl.sql`

**Purpose:** Adds STAGE_DDL records to `[core].[int_growyze001].[GlobalParameters]` for the three new stocktake DL tables so that `sp_CreateIntegrationTables` can provision them in new org databases. Uses MERGE upsert on `(ParameterKey, Category)`.

| ParameterKey | Columns | Purpose |
|---|---|---|
| `DL_STOCKTAKEREPORTS` | 25 cols | Report headers with timestamps, discrepancy data |
| `DL_STOCKTAKEREPORTDETAIL` | 30 cols | Richer headers with products/recipes split, template IDs |
| `DL_STOCKTAKEREPORTPRODUCTS` | 17 cols | Product-level count lines (barcode, qty, price, UOM) |

**Note:** These records already exist in DEV (auto-created by the API endpoint config). This script ensures they exist in Test/UAT/Prod. DDL values match the DEV database exactly.

**Status:** Created 2026-03-17. Not yet deployed.

---

### 50. `integrations/Growyze/reporting_queries/15_grid_layout_fix.sql`

**Purpose:** (Placeholder — see script file for details.)

**Status:** Created 2026-03-17. Not yet deployed.

---

### 51. `integrations/Growyze/reporting_queries/16_filter_tr_locations.sql`

**Purpose:** (Placeholder — see script file for details.)

**Status:** Created 2026-03-17. Not yet deployed.

---

### 52. `integrations/Growyze/reporting_queries/17_barchart_uom_display.sql`

**Purpose:** Applied ml→L and g→kg UOM conversion to the two BarChartCard records (`InvTopConsumption` and `InvTopWaste`). This was the first pass at UOM display fixes for Growyze.

**Status:** Created 2026-03-17. Not yet deployed.

---

### 53. `integrations/Growyze/reporting_queries/18_remaining_uom_conversions.sql`

**Purpose:** Applies ml→L and g→kg display conversion to the remaining 6 vis query records not covered by script 17. Wraps each physical-quantity SUM with a `CASE WHEN MAX(FU.STANDARDISED_UOM) IN ('ml','g') THEN ROUND(.../ 1000.0, 1) ELSE ROUND(..., 1) END` expression. UOM display columns changed to show 'L'/'kg' instead of raw 'ml'/'g'. ORDER_QTY omits ABS (sign-preserving). YAxisLabels updated to 'Quantity (L / kg)' and 'Waste (L / kg)' on chart cards. InvMargeBrut header labels updated to 'Purchases (L/kg)', 'Consumption (L/kg)', 'Waste (L/kg)'.

**Records covered (6 MERGE upserts):**

| DataSetName | VisualizationType | Changes |
|---|---|---|
| InvConsumption | CustomDataGrid | Column5-9 qty conversion + Column10 UOM display label |
| InvMargeBrut | CustomGroupedDataGrid | Usage CTE PURCHASE/CONSUMPTION/WASTE_QTY conversion + header label updates |
| InvStockActivity | MultiLineChartCard | 3 UNION ALL branches Value conversion + YAxisLabel |
| InvStockActivity | StackedBarChartCard | 3 UNION ALL branches Value conversion + YAxisLabel |
| InvWasteAnalysis | CustomDataGrid | Column4 WASTE_QTY conversion + Column5 UOM display label |
| InvWasteAnalysis | MultiLineChartCard | Value SUM conversion + YAxisLabel |

**MCP test results (Padel Social DB on UAT, 2026-03-18):**
- InvConsumption grid: 324 rows, 226 with L/kg UOM. Values like 7.7L, 0.1L (sensible, not thousands of ml). ✓
- InvMargeBrut: 12 rows. Beverages 28.1L purchases, 396.8L for Earls Court. Monetary cols (TURNOVER, RECIPE_COGS) unaffected. ✓
- InvStockActivity MultiLine: Orders In weekly values 3–61.8L, Sales Out 61.8L/348.7L. ✓
- InvStockActivity StackedBar: Earls Court Orders In 438.4L, Sales Out 213.3L, Waste 8.8L. ✓
- InvWasteAnalysis grid: 23 rows. Values like 0.1L, 1.8L, 1kg. UOM shows 'L'/'kg'/'each'. ✓
- InvWasteAnalysis MultiLine: 5 rows. Values 0.7L, 8.1L. Category legend labels correct. ✓

**Status:** Created 2026-03-18. Not yet deployed.

---

### 54. `parent-org/14_fix_currency_types.sql`

**Purpose:** Fixes "Invalid currency code : null" errors on 3 cards in the Group Overview dashboard for Nabil Enterprises. The parent org context spans multiple child databases and has no currency code set, so `CURRENCY` column types in header metadata cause the front-end to fail.

**Fix:** Changes `CURRENCY` → `DECIMAL` in the QueryTemplate header metadata (second SELECT) for all three datasets. Also updates the OutputDefinitions JSON for ParentLocationRankings.

**Affected datasets:**

| DataSetName | VisualizationType | CURRENCY columns changed |
|---|---|---|
| ParentGrowthSummary | CustomDataGrid | Revenue (Type2), Prev Period (Type3), Avg Order (Type6) |
| ParentOrgSummaryTable | CustomDataGrid | Revenue (Type2), Profit (Type3), Variance (Type5) |
| ParentLocationRankings | CustomGroupedDataGrid | Net Revenue (Type1), Avg Order Value (Type3) + OutputDefinitions JSON |

**Run against:** core database

**Status:** Created 2026-03-23. Not yet deployed.

---

### 55. `parent-org/15_remove_chart_title_values.sql`

**Purpose:** Removes redundant KPI title figures from chart cards on the Group Overview dashboard. The stacked bar, multi-line, and bar charts all display a large aggregate number above the chart (e.g. "1887324") that duplicates the dedicated KPI cards at the top.

**Fix:** Replaces correlated `Value`/`TotalValue` subqueries in the header SELECT with `NULL` for each dataset.

**Affected datasets:**

| DataSetName | VisualizationType | Column nullified |
|---|---|---|
| ParentOrgRevenue | StackedBarChartCard | Value (net revenue sum) |
| ParentOrgRevenueTrend | MultiLineChartCard | Value (net revenue sum) |
| ParentProfitByOrg | StackedBarChartCard | Value (profit sum) |
| ParentDiscountImpact | BarChartCard | TotalValue (discount impact sum) |

**Note:** `ParentEfficiencyByOrg` already has `NULL AS Value` — no change needed.

**Run against:** core database

**Status:** Created 2026-03-23. Not yet deployed.

---

### 56. `parent-org/12_filter_key_fix.sql`

**Purpose:** Fixes Group Overview dashboard filters having no effect on visualisations. Two bugs:

1. **FilterDefinitions key mismatch:** DashboardGridFilter.DataSet values are `ParentOrganisations` / `ParentLocations`, but FilterDefinitions JSON keys used `Organisations` / `Locations`. The system matches by name — mismatch means @FilterClause never injected.

2. **ParentOrganisations FilterList ID column:** Returned `ORG_CODE` (a GUID) as `[ID]`, but chart FilterDefinitions filter on `org.[ORG_NAME]` (a name). System sends ID value in @FilterClause, producing `AND org.[ORG_NAME] IN ('5AD1BEAC-...')` — guaranteed no match. Fix: return `ORG_NAME` as both `[Label]` and `[ID]`.

**Fix:**
- REPLACE FilterDefinitions keys: `"Organisations"` → `"ParentOrganisations"`, `"Locations"` → `"ParentLocations"`
- UPDATE ParentOrganisations FilterList QueryTemplate: `ORG_NAME AS [ID]` instead of `CAST(ORG_CODE ...) AS [ID]`

Idempotent — both statements are safe to re-run.

**Run against:** core database

**Status:** Created 2026-03-24. Not yet deployed.

---

### 57. `parent-org/13_growth_summary_fix.sql`

**Purpose:** Fixes ParentGrowthSummary showing "No rows" unless the date range fully contains a WEEK/MONTH/QUARTER period. A 7-day date picker window rarely contains a full week (must align Mon-Sun) and never a month or quarter.

**Root cause:** ParameterMappings used containment semantics (`PERIOD_START >= @StartDate AND PERIOD_END <= @EndDate`).

**Fix:**
1. Swap ParameterMappings to **overlap** semantics: `PERIOD_END >= @StartDate AND PERIOD_START <= @EndDate` — includes any period that touches the selected date range
2. Rewrite query with CTE to pick only the **latest** overlapping period per type (WEEK/MONTH/QUARTER)
3. Recalculate Growth % and YoY % from group totals instead of AVG of individual rates

**Result:** Any date range always produces up to 3 rows — the latest week, month, and quarter that overlap the selection.

**Run against:** core database

**Status:** Created 2026-03-25. Not yet deployed.

---

## Cost Path Redesign Scripts (`cost-path-redesign/`)

### 56. `cost-path-redesign/01_invitem_v4_entity.sql`

**Purpose:** Introduces INVITEM v4 in `DataVaultEntities`, adding `UOM_COST` (DECIMAL(38,10)) as the 15th attribute to carry catalogue/BOM unit cost in the item's native UOM. This enables the cost path redesign that removes the dependency on the InvLocCost staging table.

**Changes:**
1. Retires INVITEM v3 (UPDATE RELEASE_STATE → 'Retired') — safe conditional update (WHERE RELEASE_STATE = 'Live')
2. Upserts INVITEM v4 Live via MERGE on (ENTITY_NAME, VERSION)

**Attribute order (v4):** INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, MICROSERVICE_ID, INVITEM_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN, UOM_COST

**Run against:** core database

**Status:** Created 2026-03-24. Not yet deployed.

---

### 57. `cost-path-redesign/02_growyze_invitems_uom_cost.sql`

**Purpose:** Growyze staging step to populate `UOM_COST` in SAT_INVITEM. Reads unit cost data from the Growyze DL tables and maps it into the INVITEM v4 attribute, using the new `UOM_COST` column added in script 01.

**Run against:** client database (per-org)

**Status:** Created 2026-03-24. Not yet deployed.

---

### 58. `cost-path-redesign/03_marketman_invitems_uom_cost.sql`

**Purpose:** MarketMan staging step to populate `UOM_COST` in SAT_INVITEM. Reads unit cost data from MarketMan DL tables and maps it into the INVITEM v4 attribute, using the new `UOM_COST` column added in script 01.

**Run against:** client database (per-org)

**Status:** Created 2026-03-24. Not yet deployed.

---

### 59. `cost-path-redesign/04_presentation_counts_cost.sql`

**Purpose:** Replaces the InvLocCost/InvCost CTE chain in the **"Inventory Counts by Day"** PresentationControl step (`F_INV_COUNTS_DAY`) with a simpler `InvItemCost` CTE that reads `UOM_COST` directly from `SAT_INVITEM`, converting from the item's native UOM to the standardised UOM via the `UOMConversion` inline table.

**Deployment:** MERGE on `step_name = N'Inventory Counts by Day'`. Safe to re-run.

**Note:** This step is for `F_INV_COUNTS_DAY` (count/variance facts). It is distinct from `F_INV_USAGE_DAY` (movement/throughput facts), which is handled by script 05.

**Run against:** core database

**Status:** Created 2026-03-24. Not yet deployed.

---

### 60. `cost-path-redesign/05_presentation_usage_cost.sql`

**Purpose:** Replaces the InvLocCost/InvCost CTE chain in the **"Inventory Usage by Day"** PresentationControl step (`F_INV_USAGE_DAY`) with a simpler `InvItemCost` CTE that reads `UOM_COST` directly from `SAT_INVITEM`, converting from the item's native UOM to the standardised UOM via the `UOMConversion` inline table.

**Changes vs source query (lines 2196–2375 of `8_PresentationControl.sql`):**
- Removed: `DECLARE @InvItemAvgDays INT` and `SET @InvItemAvgDays = 30`
- Removed: `InvLocCost` CTE (rolling-average cost from `SAT_INVREPORT` over `@InvItemAvgDays` days)
- Removed: `InvCost` CTE (second-level fallback wrapping `InvLocCost`)
- Added: `InvItemCost` CTE — single join to `SAT_INVITEM` filtered to `CURRENT_FLAG = 1`, `UOM_COST IS NOT NULL`, `BOTTOM_LEVEL = 1`; converts cost using `UOMConversion`
- Replaced: two `LEFT OUTER JOIN` clauses (`ILC` + `IC`) with one `LEFT OUTER JOIN InvItemCost IIC`
- Replaced: `COALESCE(ILC.UOM_COST, IC.UOM_COST)` with `IIC.UOM_COST`
- Preserved: all other CTEs (`UOMConversion`, `StockEvents`, `MovementsByGroup`) and the full final SELECT column list unchanged

**Deployment:** MERGE on `step_name = N'Inventory Usage by Day'`. Safe to re-run.

**Note:** This step is for `F_INV_USAGE_DAY` (movement/throughput facts). It is distinct from `F_INV_COUNTS_DAY` (count/variance facts), which is handled by script 04.

**Run against:** core database

**Status:** Created 2026-03-24. Not yet deployed.

---

### 61. `padel_social_product_dashboard.sql`

**Purpose:** Enables product visualisations and inventory value KPIs for Padel Social on the UAT report database. Creates a new "Products" dashboard and adds value-oriented inventory cards to existing dashboards.

**Evaluated by agent team (2026-03-28):**
- **READY (7 queries):** ProductMargins (Pie/StackedBar/MultiLine/Combined), TopProducts (Grid), UniqueProductsSold (KPI), ProductComparison (Grid)
- **SKIPPED (5 queries):** ProductCount x3 (legacy `[threerocks]` prototype), ProductNetSales (legacy prototype), ProductGC (needs POS co-occurrence data), ProductMarginsChannel (no channel data in Growyze)
- **Currency audit:** 0 of 52 Inv/Product queries contain currency symbols

**Changes (5 parts):**
1. New VisualisationConfig for SingleKPICard (VisId 10) + 8 KPI datasets (UniqueProductsSold, InvWasteCost, InvOrdersCost, InvNegVar, InvPosVar, InvNetSales, InvProdEventCost, InvProdEventValue)
2. Product + inventory datasets added to 7 existing card-type configs (ProductMargins across 4 card types, TopProducts, ProductComparison, InvCountData, InvKPIGrouped, InvTop20Variance, Products filter)
3. New "Products" dashboard (sort 4): 6 cards + 2 filters (Locations, Products)
4. InvMargeBrut + InvKPIGrouped added to Cost & Margins (sort 4-5)
5. InvWasteCost/InvOrdersCost/InvNegVar KPIs + InvTop20Variance + InvCountData added to Stock Activity (sort 8-12)

**Run against:** UAT report database (`xms-mssql-ne-uat`, database: `report`)

**Status:** Created 2026-03-28. Not yet deployed.

---

### 62. `integrations/Growyze/reporting_queries/19_productmargins_formula_fix.sql`

**Purpose:** Fix all 4 ProductMargins visualisation queries that show negative Discounts and totals exceeding 100%.

**Root cause (diagnosed by 3-agent team, 2026-03-28):**
1. **PresentationControl bug:** `PROFIT = SUM(NET_VALUE - NET_COST)` subtracts one unit cost from full row revenue instead of `QUANTITY * NET_COST`. This inflates PROFIT.
2. **Vis query formula:** Uses inflated `PROFIT_LESS_DISCOUNT / NET_VALUE` for Margin%, then derives `Discounts = 100 - Margin% - Cost%` which goes negative when Margin% + Cost% > 100%.
3. **Growyze-specific:** `PROFIT_LESS_DISCOUNT = PROFIT` always (no POS discounting), so "Discounts" is meaningless — just absorbs the overflow.

**Fix (vis query layer):** Derive Margin% as `(NET_VALUE - QUANTITY*AVG_NET_COST) / NET_VALUE` instead of using `PROFIT_LESS_DISCOUNT`. This guarantees Margin% + Cost% = 100% by construction. Discounts becomes a rounding residual only (0 or +/-1). Also removes `FORMAT('N0')` wrappers that returned nvarchar.

**Additional fix:** CombinedChartCard title changed from "Margins by Channel" to "Product Margin Trends" (query groups by date, not channel).

**Verified against data:** Corrected formula yields Margin 76% + Cost 24% + Discounts 0% = 100%.

**Note:** The PresentationControl PROFIT formula should also be fixed as a separate data quality improvement, but this vis query fix is sufficient for correct dashboard display.

**Affects:** 4 MERGE statements updating `core.core.VisualisationQueries` (ProductMargins × PieChartCard, StackedBarChartCard, MultiLineChartCard, CombinedChartCard)

**Run against:** core database

**Status:** Created 2026-03-28. Not yet deployed.

---

### 63. `integrations/Growyze/reporting_queries/20_inv_variance_category_fix.sql`

**Purpose:** Fix InvVarianceCategory StackedBarChartCard showing impossibly large variance values (2M+ instead of ~100K).

**Root cause:** The query joins F_INV_USAGE_DAY to the latest count from F_INV_COUNTS_DAY via a many-to-one LEFT JOIN. Each item's single variance figure is replicated across every usage row. VOSS Water: 77,500ml variance × 89 usage rows = 4.6M inflated value.

**Fix:** Query F_INV_COUNTS_DAY directly with RN=1 filter (latest count per item/location). No F_INV_USAGE_DAY join needed — variance is a count-day concept.

**Verified:** Beverages drops from ~2M to ~93K positive / ~105K negative — sensible values for a padel club.

**Affects:** 1 MERGE on `core.core.VisualisationQueries` (InvVarianceCategory / StackedBarChartCard)

**Run against:** core database

**Status:** Created 2026-03-28. Not yet deployed.

---

### 64. `integrations/Growyze/reporting_queries/21_stock_activity_uom_fix.sql`

**Purpose:** Fix InvStockActivity StackedBarChartCard and MultiLineChartCard showing misaligned values between location-grouped and week-grouped views.

**Root cause:** Both queries use `MAX(STANDARDISED_UOM)` per GROUP BY to decide a single `/1000` conversion for the entire group. Different groupings (location vs week) produce different MAX UOM values, causing inconsistent totals. Also, 'gr' items fail the `IN ('ml','g')` check and never get converted.

**Fix:** Per-row CASE WHEN conversion: `CASE WHEN STANDARDISED_UOM IN ('ml','g','gr') THEN qty/1000.0 ELSE qty END`. Same pattern as scripts 17/18 (InvConsumption, InvWasteAnalysis). Also adds 'gr' to the conversion check.

**Affects:** 2 MERGE statements on `core.core.VisualisationQueries` (InvStockActivity × StackedBarChartCard, MultiLineChartCard)

**Run against:** core database

**Status:** Created 2026-03-28. Not yet deployed.

---

### 65. `snapshot_generator.sql`

**Purpose:** Generates idempotent MERGE scripts for all core control tables by querying the source environment. Run against UAT (or any source), save the output, review, then execute against Prod (or any target). Covers 10 table types across 8 sections.

**Tables included:**
- `core.core`: Integrations, DataVaultEntities, GlobalParameters (excl. ephemeral), DeploymentObjects, PresentationTables, PresentationControl, VisualisationQueries
- Per-integration schemas: GlobalParameters, StagingControl, EntityMappings

**Tables excluded:** Organisations, OrganisationIntegrations (environment-specific), suggestion engine tables (separate deployment)

**Output method:** Results to File (Ctrl+Shift+F) or Results to Text (Ctrl+T, max chars = 8192). Also supports XML grid output (commented option).

**Run against:** core database (source environment)

**Status:** Created 2026-03-28. Not yet tested.

---

### 66. `vis_uom_gr_conversion_fix.sql`

**Purpose:** Add `'gr'` (grams variant) to the UOM conversion logic in InvConsumption and InvWasteAnalysis vis queries. Items with `STANDARDISED_UOM = 'gr'` (e.g. FUNKIN WHITE PEACH) display raw gram values (1000) instead of converted kg (1.0). The InvStockActivity queries already handle `'gr'` — this aligns the other 5 queries.

**Root cause:** Scripts 17/18 (deployed) established the `IN ('ml','g')` conversion pattern but missed the `'gr'` variant present in Growyze data. Script 21 (not deployed) already fixes InvStockActivity with `'gr'`.

**Fix (2 steps):**
- Step 1: `REPLACE` adds `'gr'` to all `IN ('ml','g')` lists → `IN ('ml','g','gr')` for /1000 division
- Step 2: `REPLACE` adds `'gr' → 'kg'` UOM label mapping in CustomDataGrid queries

**Affected queries (5):** InvConsumption (BarChartCard, CustomDataGrid), InvWasteAnalysis (BarChartCard, MultiLineChartCard, CustomDataGrid)

**Run against:** core database. **Idempotent:** Yes (REPLACE no-op if already fixed).

**Status:** Created 2026-03-28. Not yet deployed.

---

### 67. `vis_locations_filter_fix.sql`

**Purpose:** Fix Locations FilterList vis query to only show locations with transaction data. Prevents phantom locations (e.g. parent-org test locations) from appearing in the dropdown.

**Root cause:** Locations FilterList queries `[datavault].[SAT_LOCATION]` with only `CURRENT_FLAG = 1`. Any DV location appears regardless of fact data. Padel Social shows 7 locations but only 3 have transactions.

**Complements:** Script 16 (`16_filter_tr_locations.sql`, not deployed) fixes the staging pipeline. This fix makes the vis query itself resilient for all orgs.

**Fix:** MERGE updates QueryTemplate + ExecutionQuery to add EXISTS checks against 5 fact tables. Parent locations (BOTTOM_LEVEL=0) included only if children have data.

**Affects:** 1 MERGE on `core.core.VisualisationQueries` (Locations / FilterList)

**Run against:** core database. **Idempotent:** Yes (MERGE).

**Status:** Created 2026-03-28. Not yet deployed.

---

### 68. `integrations/Growyze/reporting_queries/22_filter_wiring_fix.sql`

**Purpose:** Add Products filter to Padel Social's Cost & Margins and Period Analysis dashboards.

**Root cause:** These dashboards only have Locations + InvItems filters. 8 POS-margin queries (InvCOGSByCategory ×2, InvMarginTrend, InvWeeklySummary ×2, InvPeriodComp ×3) already have `Products.column` wired in their FilterDefinitions, but no Products filter widget exists on the dashboards. The InvItems filter can't apply to these queries — F_PRODUCT_MARGIN_DAY joins D_PRODUCT not D_INVITEM, and product/invitem names are different entities. The Products FilterList provides a hierarchical tree with expandable categories.

**Fix:** INSERT Products DashboardGridFilter (SortOrder 3) on both dashboards. Idempotent via IF NOT EXISTS guard.

**Affects:** 2 INSERT on `report.dbo.DashboardGridFilter`

**Run against:** report database (microservice server)

**Status:** Created 2026-03-28. Not yet deployed.

---

### 69. `clean-display-characters/clean_display_characters.sql`

**Purpose:** Sanitises characters that break the HTML frontend (e.g. straight apostrophe `'`) at the Data Vault load boundary. Two parts:

- **Part 1:** MERGE a `fnCleanForDisplay` scalar function into DeploymentObjects (order 24, Core Functions category). Uses `NCHAR(39) → NCHAR(8217)` (straight apostrophe → typographic right single quote). Deployed to all client DBs via sp_DeployObjects.
- **Part 2:** Updated `BuildSelectClause` procedure — wraps all hash:0 (pass-through) columns with `core.fnCleanForDisplay()`. After running UploadEntityMappings, all generated load SQL in StagingControl will include the cleaning function.

**Deploy order:** Part 1 (core) → sp_DeployObjects (all orgs) → Part 2 (core) → UploadEntityMappings (each integration schema)

**Affects:** `core.DeploymentObjects` (1 new record), `core.BuildSelectClause` (procedure update), all client DB `core.fnCleanForDisplay` (new function)

**Status:** Created 2026-03-28. Not yet deployed.

---

### 70. `integrations/Growyze/reporting_queries/24_invmargebrut_header_fix.sql`

**Purpose:** Fix InvMargeBrut CustomGroupedDataGrid HTTP 500 error.

**Root cause:** The QueryTemplate includes a second SELECT (header metadata) that produces a second result set. The CustomGroupedDataGrid microservice handler does not support dual result sets — it crashes with HTTP 500. Other working CustomGroupedDataGrid queries (InvKPIGrouped, SalesKPI) have no header SELECT.

**Fix:** Remove the header SELECT from the QueryTemplate. The data query itself is unchanged and returns correct results (verified via MCP against Dirty Sixth on UAT: Turnover £105K, COGS £29K, GP% 72.1%).

**Affects:** 1 VisualisationQueries record — InvMargeBrut / CustomGroupedDataGrid

**Note:** ParentLocationRankings (also CustomGroupedDataGrid with a header) likely has the same issue.

**Status:** Created 2026-04-01. Not yet deployed.

---

### 71. `integrations/Growyze/reporting_queries/25_biconfig_prefix_fix.sql`

**Purpose:** Fix Padel Social BiConfig DbPrefix in the microservice report database (UAT).

**Root cause:** Padel Social (OrgId `94A4B719-EB0F-421F-AD03-ABECDD888B14`) has DbPrefix `20251208` (copied from DEV GrowyzeDev org) instead of the correct UAT prefix `20260310`. The microservice constructs the DB name as `{DbPrefix}_XMS_{OrgId}`, connecting to a nonexistent database. All dashboard cards for Padel Social fail.

**Fix:** Single UPDATE to dbo.BiConfig setting DbPrefix = '20260310'.

**Affects:** 1 BiConfig record in microservice report DB (UAT only)

**Status:** Created 2026-04-01. Not yet deployed.

---

### 72. `integrations/Growyze/reporting_queries/26_invmargintrend_column_fix.sql`

**Purpose:** Fix InvMarginTrend MultiLineChartCard showing "0.00" with empty chart.

**Root cause (probable):** The query uses old Pattern B column schema (`VisType` column) instead of Pattern A (`Curve`, `Stack`, `Area`, `StackOrder`, `ShowMark`) used by all working MultiLineChartCard queries (ProductMargins, NetSales, ForecastDailyRevenue, ParentOrgRevenueTrend). The underlying data is correct — verified via MCP against Dirty Sixth: GP% 71-72%, COGS% 28-29% across Jan-Mar 2026.

**Fix:** Convert outer SELECT from `'line' AS VisType` to `'linear' AS Curve, NULL AS Stack, 'false' AS Area, NULL AS StackOrder, 'true' AS ShowMark`. Data query and header unchanged.

**Affects:** 1 VisualisationQueries record — InvMarginTrend / MultiLineChartCard

**Note:** Other Inv* MultiLineChartCard queries (InvStockActivity, InvWasteAnalysis) and ATV* queries also use Pattern B and may need the same fix. If this fix resolves InvMarginTrend, apply the same conversion to those queries.

**Status:** Created 2026-04-01. Not yet deployed.

## TUBR API Integration Scripts

### 73. `integrations/tubr/01_sp_TubrApi_GetLocations.sql`
### 74. `integrations/tubr/02_sp_TubrApi_GetCatalog.sql`
### 75. `integrations/tubr/03_sp_TubrApi_GetOrders.sql`
### 76. `integrations/tubr/04_register_deployment_objects.sql`

**Purpose:** Three stored procedures backing the three endpoints TUBR (forecasting partner) requires — `GET /v1/locations`, `GET /v1/locations/{id}/catalog`, `GET /v1/locations/{id}/orders`. The fourth script registers all three in `core.core.DeploymentObjects` (ExecutionOrder 140-142, Category `'TUBR API Procedures'`) so `sp_DeployObjects` rolls them out to every client database alongside the card-procedure family.

**SP shape:**
- All three live in the `core` schema of each client database. The API resolves `OrganisationCode → DatabaseName` via `core.core.Organisations` and connects directly to the resolved DB before executing the SP.
- Output is tabular result sets (no `FOR JSON`). `sp_TubrApi_GetCatalog` returns two result sets (products, categories). `sp_TubrApi_GetOrders` returns two result sets (orders, line_items) joined by `order_id`.
- `sp_TubrApi_GetOrders` returns `LINEITEM_TYPE IN ('PROD','MOD')` with `parent_lineitem_id` exposed so the API can re-parent modifiers under their parent product line.
- Pagination is `OFFSET/FETCH` keyed on `(OPEN_TIME, HUB_ID)` via `@PageNumber`/`@PageSize`. Cursor pagination can be added later.
- Stable IDs: orders and line items expose hex-encoded SHA-256 hub keys (`ord_…`, `li_…`), guaranteeing stability across re-fetches.

**Smoke tested against UAT** — Three Rocks Cafe DB (`20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4`):
- Locations query returned 18 outlets ✓
- Orders query returned correct totals and `'completed'` state mapping ✓
- Real-data gaps surfaced (not query bugs): `LNK_ADDRESS_LOCATION` empty (address NULL), `GRAND_TOTAL` NULL on NCRAloha orders (worked around via `COALESCE(GRAND_TOTAL, GROSS_SALES)`), `DISCOUNT_GROSS` stored negative (wrapped in `ABS()`), `order_mode` NULL because no CHANNEL link populated for this org.

**Open follow-ups:**
1. Add `Currency CHAR(3)` and `Timezone NVARCHAR(64)` columns to `core.core.Organisations`; replace SP `@DefaultCurrency` / `@DefaultTimezone` parameter defaults with reads from those columns.
2. Documented in `docs/data-vault-reference.md`: PRODUCT_ID must be unique per variant. Integration staging pipelines (NCRAloha, TROAP, Square, Bizon) need to honour this so TUBR's variant-level granularity is preserved end-to-end.
3. `delivery_partner` is not modelled — needs a new attribute on CHANNEL or a dedicated entity if/when delivery integrations land.

**Status:** Created 2026-05-05. Not yet deployed. Order: deploy `04_register_deployment_objects.sql` against `core`, then run `sp_DeployObjects` per-org cursor to roll the procedures out to client DBs.

## Front-end Test Cards (Kitchen Sink, TEST) — XMSE-1030, XMSE-1014, XMSE-948

### 77. `test-cards/01_register_vis_queries_TEST.sql`
### 78. `test-cards/02_wire_kitchen_sink_TEST.sql`

**Purpose:** Place six self-contained sample cards on the Kitchen Sink dashboard for Three Rocks Cafe (TEST) so Craig can build / reproduce the three open front-end tickets:

- **XMSE-1030** — `HorizontalStackedBarTest` (StackedBarChartCard): 5 stores × 4 categories sample shape for the new horizontal stacked bar component.
- **XMSE-1014** — `MultiLineNullValueTest` (MultiLineChartCard): header `Value = NULL` to repro the "0.00" rendering bug.
- **XMSE-948** — `MarkdownTestEmpty` / `MarkdownTestVisible` (MarkdownCard) and `StaticBoxTestEmpty` / `StaticBoxTestVisible` (StaticBoxCard): paired empty/visible queries to verify the hide-on-empty behaviour.

All six dataset queries are self-contained `(VALUES …)` constructors — no Data Vault or presentation-layer dependency, so they run regardless of whether DV data has loaded on TEST.

**Targets:**
- `01_register_vis_queries_TEST.sql` → BI MI TEST `core.core.VisualisationQueries` (MERGE upserts, idempotent)
- `02_wire_kitchen_sink_TEST.sql` → microservice TEST `report.dbo.*` — patches `VisualisationDataSetMap` + adds six `DashboardGridItem` rows on Kitchen Sink (`DashboardGridId 87D8B576-BE97-F011-B3CD-000D3AD9E35E`) for Three Rocks Cafe (`OrganisationId C14CF568-588D-F011-B3CD-000D3AD9E9D4`). Sort orders 100–105.

See `test-cards/README.md` for deploy order, row-shape reference, and revert instructions.

**Status:** Created 2026-05-06. Not yet deployed. BI MI TEST MCP was unreachable at authoring time (login failure); scripts authored against UAT-derived schema and verified against TEST microservice metadata.

## Growyze Orphan PRODUCT_HUB_ID Fix (2026-05-18)

### 79. `integrations/Growyze/15_orphan_product_fix.sql`

**Purpose:** Two-layer fix for the Growyze orphan PRODUCT_HUB_ID leak that drops product slices from dashboards.

**Background:** `stage.GRYZ_LINEITEM` LEFT-joins `DL_DISHES` on `(items_posId, organizations)`. When a sale-detail `items_posId` has no matching dish, `d.id` is NULL, `PRODUCT_KEY = NULL`, and the DV load hashes NULL into a deterministic orphan PRODUCT_HUB_ID. The link row exists but the hub does not, so `D_PRODUCT` joins yield NULL — any GROUP BY product silently drops the slice. Dirty Sixth UAT 2026-05-09: orphan = £1,454.84 NET (~8.4% of day's £17,405.50 total).

**Section 1 (Growyze-only, root cause):**
- New tier-2 `StagingControl` step `Growyze LineItem Product Link` materialises `stage.GRYZ_LINEITEM_PRODUCT` filtered to rows with non-null `PRODUCT_KEY`.
- `EntityMappings` row for `LINEITEM_PRODUCT` re-pointed from `GRYZ_LINEITEM` → `GRYZ_LINEITEM_PRODUCT` (DELETE old composite-key row + MERGE new).

**Section 2 (platform-wide, defensive):**
- Pattern-guarded UPDATE on `core.PresentationControl` row `131C3A84-F72D-4A12-B958-BFB519973BE0` (`F_LINEITEM_15MIN`): the LEFT JOIN to `LNK_LINEITEM_PRODUCT` is wrapped in a derived table that INNER-joins `HUB_PRODUCT`, so any future orphan key from any integration is discarded → outer LEFT preserves the line → existing `ISNULL(..., -999)` routes to D_PRODUCT "Unknown".

**Idempotent:** MERGE on staging + entity mapping; CHARINDEX guard on presentation patch. Safe to re-run.

**Release note:** `04_entity_mappings.sql` #13 and the `Growyze Line Item` staging step in `02_staging_tier1.sql` should be amended in the same release so future re-runs don't resurrect the old mapping. Section 2 modifies a CORE control table — affects every organisation's F_LINEITEM_15MIN rebuild (intentional safety net).

**Status:** Created 2026-05-18. Not yet deployed. Awaiting MCP verification on Dirty Sixth UAT after running tier-2 staging + DV load + presentation rebuild.

### 80. `integrations/tubr/07_sp_Api_GetLocations_TotalRecords.sql` / `08_sp_Api_GetCatalog_TotalRecords.sql` / `09_sp_Api_GetOrders_TotalRecords.sql` (+ amended `04_register_deployment_objects.sql`)

**Purpose:** Companion count SPs Ian requested so the external-API caller knows when to stop paginating / can sanity-check completeness. Each one mirrors the filtering of its data SP exactly and returns a single row, single column `TotalRecords BIGINT`.

**SP shape:**
- `sp_Api_GetLocations_TotalRecords` — no params, counts active leaf outlets.
- `sp_Api_GetCatalog_TotalRecords(@LocationId, @UpdatedSince)` — counts product rows only (categories are denormalised lookups, not paginated). Returns 0 when @LocationId is unknown.
- `sp_Api_GetOrders_TotalRecords(@LocationId, @StartDate, @EndDate, @UpdatedSince)` — counts orders across the full filtered set (no `@PageNumber`/`@PageSize`). Returns 0 when @LocationId is unknown.
- Filters tracked 1:1 with the data SPs (CURRENT_FLAG = 1, IS_DELETED = 0, BOTTOM_LEVEL = 1, half-open OPEN_TIME range, @UpdatedSince on LOAD_TS).

**Registration:** `04_register_deployment_objects.sql` extended in-place — MERGE now upserts all 6 SPs (ExecutionOrder 140-145, Category `External API Procedures`). MERGE is idempotent so safe to re-run against the `core` DB that already has 140-142 from the Oak & Vine UAT deployment; the new entries (143-145) will INSERT and the existing ones will UPDATE with no functional change.

**Deployment order:**
1. Run amended `04_register_deployment_objects.sql` against `core` (xms-bi managed instance).
2. Run `sp_DeployObjects` with per-org cursor to materialise the new SPs into every client DB.

**Status:** Created 2026-05-21. Not yet deployed.

---

### `integrations/MargeBrut/` — Marge Brut mock dashboard (UAT, hosted on The Oak & Vine)

**Purpose:** A real XMS BI dashboard reproducing the Accor hotel "Marge Brut" (F&B cost-of-sales) spreadsheet, fed by **mocked** Oct-2025 ISLRG data via literal-VALUES visualisation queries (no live Growyze/Bizon feed). Source: `docs/Accor - MargeBrut/`. Design: `integrations/MargeBrut/DESIGN.md`.

**Host org:** existing **The Oak & Vine** (OrgID 16, GUID `7ED2E768-0D22-F111-832F-000D3AB27D87`, MI DB `20260317_XMS_7ED2E768-...`, ACTIVE) — chosen 2026-06-08 in place of a new "Ibis" org. Org already onboarded + card SPs present, so **no org-creation / microservice step**.

**Scripts (deploy order in `DEPLOY.txt`):**
- `02_margebrut_vis_queries.sql` — `core.core.VisualisationQueries`: 9 LIVE literal datasets `MargeBrut*` (CustomDataGrid grid, 4 SingleKPICards, 2 BarChartCards, 2 PieChartCards). MERGE-upsert on (DataSetName, VisualizationType, Status). **Global, org-agnostic.**
- `00_fix_report_audit_trigger.sql` — microservice `report` DB (run directly): **platform bug fix**. ALTERs `dbo.OrganisationDashboardConfig_Audit`, which omitted NOT-NULL audit cols DashboardGridId/IconName/SortOrder (added in the DashboardGrid schema change) and blocked ALL inserts into OrganisationDashboardConfig. Must run before 03. (Same regression exists on `DashboardConfig_Audit` + `StaffDashboardConfig_Audit` — empty/unused tiers, NOT fixed.)
- `03_margebrut_report_config.sql` — microservice `report` DB (run directly; MCP can't reach it): BiConfig → VisualisationConfig (1,3,9,10) → VisualisationDataSetMap → DashboardGrid → DashboardGridItem (9 cards) → DashboardGroup + GroupMapping (visibility) → verify. `@OrgId`/`@DbPrefix` pre-set to Oak & Vine.

**Status:** Created 2026-06-08 (re-targeted from "Ibis" to Oak & Vine same day). **All 4 card query shapes MCP-verified on UAT `core`.** Script 02 (vis queries) run + 03 partially run: 03 hit the audit-trigger bug above (rolled back), now fixed via `00`. Re-run order on `report`: 00 → 03. Not yet fully deployed.

---

### `integrations/MargeBrut/live/` — Marge Brut mock -> live build (2026-07-10)

Delta scripts wiring `MargeBrut*` off real Growyze/Bizon data instead of the mocked literal-VALUES queries above. Design: `.superpowers/sdd/` task briefs.

- `live/10_f_margebrut_month_table.sql` — Task 1. MERGE-upsert of `presentation.F_MARGEBRUT_MONTH` DDL into `core.PresentationTables` on natural key `(table_name, version)` = `('F_MARGEBRUT_MONTH', 1)`. 15 columns: `GROUP_NAME NVARCHAR(50)` + `PERIOD_MONTH DATE` (PK), then 11 `DECIMAL(18,2)` money/qty columns (TURNOVER_INCL/EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION) + 2 `DECIMAL(9,4)` percentages (COST_PCT, GP_PCT). Column list for `core.PresentationTables` (`table_name`, `table_type`, `schema_name`, `ddl_script`, `column_definitions`, `description`, `business_owner`, `data_source`, `version`, `status`, `is_system_generated`, `created_by`/`updated_by`, `created_at`/`updated_at`) and its unique key confirmed via MCP `INFORMATION_SCHEMA.COLUMNS` + `sys.indexes` against UAT `core` — differs from the task brief's illustrative example (real columns are snake_case `table_name`/`ddl_script`, not `TableName`/`CreationScript`; unique key is `(table_name, version)` not `table_name` alone). **Authored, shape-verified, not deployed** (no execution — MERGE only, per MCP read-only rule).
- `live/11_reference_margebrut_manual.sql` — Task 2. `IF OBJECT_ID(...) IS NULL CREATE TABLE` for `reference.MARGEBRUT_MANUAL` (`GROUP_NAME NVARCHAR(50)`, `PERIOD_MONTH DATE`, `REV_PROV`/`NEW_PROV`/`STAFF_MEAL DECIMAL(18,2)`, `COMP_COST_PCT DECIMAL(9,4)`, PK `(GROUP_NAME, PERIOD_MONTH)`), holding the manual inputs no feed supplies (provisions, staff-meal, comp cost %) for the Task 6 build step to LEFT JOIN. MERGE-seeds Oct-2025 sheet figures for all 6 groups (Food/Breakfast/Wines/Bottled Beer/Soft Drinks/Spirit): only Food carries non-zero REV_PROV 1092.60 / NEW_PROV 912.17 / STAFF_MEAL 306.40 (the sheet's TOTAL FOOD row); all groups get the flat 33% `COMP_COST_PCT` assumption. `reference` schema existence confirmed via MCP `INFORMATION_SCHEMA.SCHEMATA` against the Growyze proxy org (`20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`) — already present, no `CREATE SCHEMA` guard added. **Authored, shape-verified, not deployed** (no execution — MERGE only, per MCP read-only rule).
- `live/12_group_mapping.sql` — Task 5. Two `UPDATE ... SET MICROSERVICE_NAME = CASE ...` blocks (`WHERE CURRENT_FLAG = 1`) — one against `datavault.SAT_PRODUCT` (Mews turnover side), one against `datavault.SAT_INVITEM` (Growyze stock/purchases side) — seeding the platform's manual-only MDM column with the same 6 group strings so Task 6 can join turnover and stock under one `GROUP_NAME`. Neither SAT has a category column (ATTR_1..5 are NULL/portion-size junk on SAT_PRODUCT, UOM/pack/cost fields on SAT_INVITEM), so both CASEs key off keyword matches against PRODUCT_NAME/INVITEM_NAME, calibrated against a live sample (Mews DEV proxy org 19; Growyze UAT Padel Social org) and shape-tested read-only via MCP, then hardened in a code-review round. Substring collisions found and guarded: `'%gin%'` bare matches "Original"/"Orginal" (typo seen in "Coke Orginal", "Guinness Original", "JARR KOMBUCHA ORIGINAL") and "Ginger" — excluded explicitly; `'%cola%'` bare matches "chocolate" (Cadbury's Drinking Chocolate, KIND Bar, Fulfil Protein Bar, etc.) — excluded explicitly; `'%beer%'`/`' ale%'` exclude 'ginger' (plain "Ginger Ale"/"Ginger Beer" on Mews, FENTIMANS GINGER BEER / LONDON ESSENCE GINGER ALE on Growyze), with an explicit `ginger beer`/`ginger ale`/`kombucha` → Soft Drinks match in **both** blocks so they land correctly instead of Bottled Beer/Food; `'%water%'` excludes 'watermelon' on the Growyze block only ("Fresh Watermelon", "Monin Watermelon" — a fruit ingredient and a cocktail syrup, not soft drinks; "Rubicon Watermelon Juice" still correctly matches its own `juice` keyword). Defensive guards (not evidence-driven — no colliding row currently exists, but plausible on the real org's menu) added to both blocks: `'%rum%'` excludes 'crumble'/'drumstick'; `'%corona%'` excludes 'coronation'. Checked and found no current-data collision (no guard added) for `bourbon` vs "Bourbon biscuit", `soda` vs "Soda Bread", and `espresso`/`coffee`/`tea` vs "Espresso Martini"/"Irish Coffee" (the last is a latent Breakfast-evaluated-first ordering risk, flagged for the real catalogue). One override applied: SAT_INVITEM `68d64de560ddb80f58e8f267` ("The Lost Explorer Blanco", a mezcal) → Spirit, since its name carries no spirit keyword. Final read-only distributions (all 6 groups present, zero NULLs — guaranteed by the `ELSE N'Food'` catch-all): Mews SAT_PRODUCT (149 current rows) — Food 144, Spirit 82, Wines 51, Soft Drinks 46, Breakfast 44, Bottled Beer 22; Growyze SAT_INVITEM (1,672 current rows) — Food 1,360, Soft Drinks 121, Spirit 99, Bottled Beer 58, Wines 25, Breakfast 19 (Food dominates because the Growyze UAT proxy also stocks retail clothing/padel equipment with no F&B/beverage signal). **Authored, shape-verified, not deployed** (no execution — UPDATE only, per MCP read-only rule).
- `live/13_f_margebrut_month_control.sql` — Task 6. MERGE-upsert (on natural key `step_name` = `'F_MARGEBRUT_MONTH'`) of the `core.core.PresentationControl` build step that populates `presentation.F_MARGEBRUT_MONTH`. `tier=2` (all four sources — D_PRODUCT, D_INVITEM, F_LINEITEM_15MIN, F_INV_COUNTS_DAY — build in tier 1), `table_type='Fact'`, `time_series_target_column='PERIOD_MONTH'`. Control-table schema + unique key confirmed via MCP (`INFORMATION_SCHEMA.COLUMNS` + `sys.indexes` on UAT `core`): columns are snake_case (`step_name`/`query_sql`/`column_mappings`/`time_series_target_column`…), unique key is `step_name` alone. The `query_sql` is a single SELECT (the engine `sp_ProcessPresentation`→`sp_ExecuteQuery` loads mapped columns itself; a Fact with a `time_series_target_column` gets a windowed `DELETE` over MIN..MAX of that column before insert — since the build recomputes all months with no date window, the DELETE spans the whole history = idempotent full rebuild, PK `(GROUP_NAME,PERIOD_MONTH)` safe on re-run). Build: turnover CTE (F_LINEITEM_15MIN `LI_TYPE='PROD'` × D_PRODUCT, `TURNOVER_INCL=SUM(GROSS_VALUE)`, `TURNOVER_EXCL=SUM(NET_VALUE)`); stock CTEs (F_INV_COUNTS_DAY × D_INVITEM, `PURCHASES=SUM(ORDER_QTY*UOM_COST)`, OPENING/CLOSING = `SUM(ACTUAL_COUNT*UOM_COST)` at the first/last COUNT_DATE per group+month via windowed MIN/MAX); manual LEFT JOIN to `reference.MARGEBRUT_MANUAL`; derived `ALL_STOCK`, `CONSUMPTION`, `COST_PCT` (NULL when `TURNOVER_EXCL<=0` = sheet "n/a"), `GP_PCT`. **COMP** = explicit literal `0` (per code review). Deliberately NOT the generic `DISCOUNT_HUB_ID` link: applying `discounted retail × COMP_COST_PCT` would silently inflate GP% the instant any non-comp discount (promo/markdown) lands. An honest 0 is correct today (feed has zero comp/discount lines: LI_TYPE ∈ {PROD,TAX}, all `DISCOUNT_HUB_ID` = -999 sentinel) and awaits a COMP-SPECIFIC signal (comp/void reason code or dedicated flag); `COMP_COST_PCT` retained in `reference.MARGEBRUT_MANUAL` for then. The two `WHERE BOTTOM_MICROSERVICE_NAME IS NOT NULL` filters carry a comment noting unmapped products/invitems are excluded and that Task 5 (`12_group_mapping.sql`) MUST deploy before this step. Shape-tested read-only per half: turnover reconciles exactly to raw F_LINEITEM_15MIN PROD totals (GROSS 4193.35 / NET 3494.49) with no join fan-out (111=111) on the Mews DEV proxy; stock non-negative with no fan-out (8082=8082) on the Growyze UAT proxy (magnitudes inflated by the known O5 UOM_COST pack-vs-unit issue — not this task's to fix); derived-column arithmetic + n/a handling unit-tested against synthetic rows. Both proxies have `BOTTOM_MICROSERVICE_NAME` NULL (Task 5 not yet deployed there). **Authored, shape-verified, not deployed** (no execution — MERGE only, per MCP read-only rule).
- `live/14_margebrut_vis_queries.sql` — Task 7. Rewrites the 9 `MargeBrut*` `core.core.VisualisationQueries` records (same MERGE natural key as `02_margebrut_vis_queries.sql`: `DataSetName, VisualizationType, Status='LIVE'`) from literal Oct-2025 `VALUES` mocks to live reads over `presentation.F_MARGEBRUT_MONTH`. Card render schemas (RS1/RS2 column names), `ParameterMappings`, and `Version` preserved unchanged from the mock. Adds a `PeriodMonth` `FilterDefinitions` IN-filter (dataType DATE) to all 9 (`F.[PERIOD_MONTH]` for the 8 F_MARGEBRUT_MONTH-based queries; a month-truncated `p.[ORDER_DATE]` expression for the supplier one) — no prior FilterDefinitions in the codebase uses a DATE-type IN filter, this is a new pattern. Every %/ratio (COST_PCT, GP_PCT, cost-of-sales %) is recomputed from summed raw measures at whatever grain is displayed, never averaged from the per-row stored ratios (avoids Simpson's-paradox-style misweighting when periods/groups are combined). `MargeBrutGrid`: 9-row grid (TOTAL FOOD / Total Food ex. Breakfast / Total Breakfast / WINES / BOTTLED BEER / SOFT DRINKS ONLY / SPIRIT / TOTAL BEVERAGE / GRAND TOTAL VR) via a canonical-6-groups LEFT JOIN (so a group with zero rows in the filtered range still renders, blank, rather than vanishing) + UNION ALL rollup CTEs. `MargeBrutCostRatioByGroup` / `MargeBrutConsumptionMix`: 5-bucket set matching the mock (Food folds in Breakfast). `BarValue`/`TotalValue` kept numeric (`DECIMAL`, never `FORMAT`-ted text) per the mock's own BarChartCard gotcha comment. Two judgement calls (full detail + supplier-grain investigation in `.superpowers/sdd/task-7-report.md`): (1) **MargeBrutPurchasesBySupplier** — F_MARGEBRUT_MONTH is group-grain, not supplier-grain, so it can't source this dataset; found a clean existing supplier grain instead, `presentation.F_PURCHASES_DAY` (`SUPPLIER_HUB_ID`/`ORDER_DATE`/`LINE_TOTAL`, built by the not-yet-deployed Growyze `06_purchases_presentation_table.sql`/`07_purchases_presentation_control.sql`, QUERY_STATUS #23/#24) joined to the already-live core `presentation.D_SUPPLIER` dimension. **Concern flagged for Task 8/9/10:** this dataset will return no rows until Growyze 06→07 are deployed and run at least once — a deploy-order dependency outside Task 7's scope. **Review fix (post-approval):** the original query summed every `F_PURCHASES_DAY` row regardless of category, disagreeing in principle with the F&B-scoped `MargeBrutPurchasesKPI` — added a `JOIN presentation.D_INVITEM` + `WHERE BOTTOM_MICROSERVICE_NAME IS NOT NULL` filter (Task 5's F&B group set) on both RS1 and the RS2 `TotalValue` subquery (fan-out confirmed safe via MCP: `D_INVITEM` has 1 row per `BOTTOM_HUB_ID` on the Growyze UAT proxy), restored descending-by-value `BarLabelSort` (was alphabetical), and added a `TODO` flagging that `F_PURCHASES_DAY.LINE_TOTAL` and `F_MARGEBRUT_MONTH.PURCHASES` are different measures from different pipelines that must be reconciled (or the chart retitled to "Supplier Spend") once real data lands. Re-verified via MCP with a mock non-F&B invitem row proving the filter excludes it. (2) **MargeBrutCompsSplit** — mock's 4-way split (Staff Meal/Gift-to-Guest/Management/Rooms) can't be sourced; F_MARGEBRUT_MONTH only has STAFF_MEAL and COMP (COMP is an explicit literal 0 today, no comp signal yet per Task 6). Modelled with the 2 categories that exist (Complimentary renders 0 today, will pick up real values automatically once a comp source lands, no further vis-query change needed); the sub-split is dropped and noted as pending. Since F_MARGEBRUT_MONTH isn't populated anywhere yet, all 9 rewritten queries were shape-tested read-only via MCP against inline `VALUES` CTEs standing in for `F_MARGEBRUT_MONTH` (and `F_PURCHASES_DAY`/`D_SUPPLIER` for the supplier one) — every query parsed and returned the exact RS1/RS2 column names the card types expect, rollup arithmetic verified against hand-computed totals, `BarValue` confirmed numeric. **Authored, shape-verified, not deployed** (no execution — MERGE only, per MCP read-only rule).
- `live/15_report_config.sql` — Task 8. Microservice `report` DB config for the new UAT "Three Rocks Hotel" org (Task 9 provisions it) — same wiring shape as the Oak & Vine mock (`../03_margebrut_report_config.sql`), re-pointed: Section 0 prepends the `OrganisationDashboardConfig_Audit` trigger fix (`../00_fix_report_audit_trigger.sql`, verbatim) ahead of the transaction so the `OrganisationDashboardConfig` insert doesn't hit the NOT-NULL audit-column regression the mock hit and rolled back on 2026-06-08; the fix is a full idempotent `ALTER TRIGGER`, harmless to re-run even though it was already applied for Oak & Vine. Steps 1-9 (BiConfig → VisualisationConfig [1,3,9,10] → VisualisationDataSetMap [9 datasets] → DashboardGrid → OrganisationDashboardConfig → DashboardGridItem [9 cards, same hybrid spans] → DashboardGroup + `OrganisationDashboardGroupMapping` [O13 visibility — kept, load-bearing] → verify-or-rollback) are an unchanged line-by-line structural mirror of `03` — same table sequence, same column lists, same `NEWID()`-into-variable FK-capture pattern for `@GridId`, same guard/MERGE natural keys, same `IF @unmapped > 0` verify-or-rollback. Only re-point: `@OrgId`/`@DbPrefix` are now placeholders (`@OrgId` set to an intentionally invalid `UNIQUEIDENTIFIER` string literal so an unmodified run fails fast at the `DECLARE` instead of inserting against a wrong/empty org; `@DbPrefix` placeholder `'00000000'` sized to the real 8-char prefix), and all Oak & Vine-specific `PRINT` text genericised to reference `@OrgId`/"the org" instead of hardcoding the old org name. **Not MCP-testable** (report DB unreachable via MCP — Azure SQL, cross-DB blocked, MCP lands in `master`). Cross-checked structurally against `03` (table-by-table diff, confirmed no shape drift) in lieu of execution. **Authored, not deployed — developer-run against `report` DB once Task 9 supplies the real `@OrgId`/`@DbPrefix`; verify block must pass before COMMIT.**
- `live/01_provision_uat_org.sql` — Task 9. Provisions the new UAT org "Three Rocks Hotel" and maps it to Mews (POS) + Growyze (INVENTORY), via `core.AddOrganisation`/`core.AddIntegration`/`core.MapOrganisationToIntegration` only (never direct INSERT, per CLAUDE.md). **Finding that changed scope:** the task brief assumed Mews001 already existed on UAT alongside Growyze001 — confirmed via MCP that's wrong: UAT `core.Integrations` has 6 rows (Marketman001/NCRAloha001/TROaP001/SurveyHero001/Growyze001/TBTBookingMetrics001), no Mews; Mews001 (IntegrationID 8, `IntegrationType='POS'`, `SchemaName='int_mews001'`) was deployed straight to DEV by the fetcher team and never provisioned on UAT (see `memory/bizon-integration.md`). So this script also creates the Mews001 integration record (mirroring the DEV row's `IntegrationDisplayName`/`Version`, then `UPDATE`s `IntegrationType='POS'` post-insert since `AddIntegration` has no such param) and seeds its `core.int_mews001.GlobalParameters` `STAGE_DDL` config — 22 `DL_*` landing-table `CREATE TABLE` strings, copied verbatim via read-only MCP from DEV's `core.int_mews001.GlobalParameters` (`Category='STAGE_DDL'`) — via a single `MERGE` keyed on `(ParameterKey, Category)`, matching the CLAUDE.md upsert convention (the existing `Growyze001_DDL.sql` release-script precedent uses a per-table `IF EXISTS/UPDATE ELSE INSERT` instead of `MERGE`; this script uses `MERGE` per the newer house rule). **Why the STAGE_DDL seed must precede the mapping:** `trg_OrganisationIntegrations_AfterInsert` only fires on the `INSERT` that creates the org↔integration mapping row — reading `core.{schema}.GlobalParameters` `STAGE_DDL` rows at that moment to create the client DB's `DL_*` tables. A later re-run of `MapOrganisationToIntegration` against an already-existing mapping just `UPDATE`s the row and does not refire the trigger, so seeding STAGE_DDL after mapping would leave the org's `int_mews001` schema permanently empty short of manually re-triggering. `@OrganisationCode` left `NULL` (auto-`NEWID()`, avoiding the hex-only GUID gotcha) and `@OrganisationPrefix` set to the provisioning date `20260710`, matching the convention confirmed against all 18 existing UAT orgs (`OrganisationPrefix` = creation date, not a name abbreviation). Guarded throughout (`IF NOT EXISTS` / `MERGE`) — safe to re-run. Growyze001 (already on UAT, untouched) is looked up by name, not hardcoded. **Review round 2 addition:** a new Section 6 verifies, by dynamic SQL against the org's own client database (its name is only known at runtime, hence `sp_executesql` + `QUOTENAME`), that all 22 `int_mews001.DL_*` tables actually landed — `RAISERROR`s if not. Needed because `trg_OrganisationIntegrations_AfterInsert` only `PRINT`s on a failed `CREATE TABLE`, never raises, so Section 5 completing without visible error was not proof the schema was complete. Verified the check's query shape read-only via MCP against the DEV Mews proxy org, **using three-part naming from the `core` connection** (not the MCP `database` parameter directly — that silently returned wrong results, the exact gotcha CLAUDE.md documents): returns 22. Old Section 6 (verification `SELECT`) renumbered to Section 7. Ends with that verification SELECT surfacing `OrganisationCode`/`DatabaseName`/mapping rows — values `live/15_report_config.sql` and the Mews `sp_DataVaultLoad` call need. Confirmed via MCP (read-only): SP signatures against `3_CoreStoredProceduresAndFunctions.sql` (repo root), UAT `core.Integrations`/`core.Organisations` row sets, DEV `core.int_mews001.GlobalParameters` STAGE_DDL row values. **Authored, not deployed** (no execution — provisioning SPs are state-changing and require the developer's per-stage go-ahead through the PowerShell runner, per CLAUDE.md).
- `live/DEPLOY.txt` — Task 9. Full ordered runbook: (1) `01_provision_uat_org.sql`, with an explicit instruction to scan the runner PRINT output for DDL errors around the mapping step and confirm the script's own Section 6 prints PASS before trusting the schema is complete; (2) Mews DV mapping `../../Mews/` 01→02→**05**→03 (05 before 03 or CRM load steps regenerate) + `sp_DataVaultLoad` for the new org; (3) **⛔ FETCHER GATE** — real Growyze feed for the hotel, plus deploying the not-yet-live Growyze purchases scripts `06_purchases_presentation_table.sql`/`07_purchases_presentation_control.sql` (QUERY_STATUS #23/#24) that `MargeBrutPurchasesBySupplier` depends on, plus a GDPR check that the fetcher hasn't landed the Mews customers endpoint for this org (`DL_CUSTOMERS` re-lands PII regardless of the DV-side GDPR purge); (4) Growyze O5/O6 data-quality gate (NULL `LINEITEM_TIMESTAMP`, UOM_COST pack-vs-unit inflation, `D_PRODUCT` category fall-through) — numbers provisional until cleared; (5) strict grouping/build order — `12_group_mapping.sql` (a data `UPDATE` against the org's live `SAT_PRODUCT`/`SAT_INVITEM`, not a registration) must execute after Mews/Growyze data lands; **`11_reference_margebrut_manual.sql` runs next, before the build** (review-round-2 fix — `13`'s query `LEFT JOIN`s `reference.MARGEBRUT_MANUAL`, so an earlier ordering that ran `11` after the build was wrong: a `LEFT JOIN` to a nonexistent object fails the whole build); then `13_f_margebrut_month_control.sql` + `10_f_margebrut_month_table.sql` (independent control-table registrations, order between them doesn't matter) register before the build actually runs; (6) `14_margebrut_vis_queries.sql` (UAT `core`, global); (7) `15_report_config.sql` run directly against `report`, `@OrgId`/`@DbPrefix` set from step 1's output; (8) `99_verify.sql` (Task 10) + front-end check. Two carried-forward warnings called out prominently: **never re-run `../02_margebrut_vis_queries.sql` after step 6** — it shares the same MERGE natural key `(DataSetName, VisualizationType, Status)` as `live/14_margebrut_vis_queries.sql` and would silently revert every org's Marge Brut dashboard to mocked data; and the unresolved **MargeBrutPurchasesBySupplier vs MargeBrutPurchasesKPI reconciliation TODO** from Task 7 (different measures, different pipelines — validate or rename before trusting both figures together).
- `live/99_verify.sql` — Task 10. Read-only, developer-run go-live verification (spec §6), run AFTER the fetcher gate (DEPLOY.txt step 3) and the full build order (step 5) have completed for the org. Five checks, each emitting `check_name` + diagnostic columns + a `check_result` literal: (1a) **Reconciliation (fact self-consistency)** — recomputes `MargeBrutCostRatioKPI`'s hero formula (`SUM(CONSUMPTION)/NULLIF(SUM(TURNOVER_EXCL),0)`) and `MargeBrutGrid`'s `by_group`/`grand_total` CTEs independently from `F_MARGEBRUT_MONTH`, both grouped off the same raw `GROUP_NAME` set — proves the fact's own SUM = sum-of-groups arithmetic is internally consistent (catches a broken `GROUP BY` or a typo'd formula in either query) but, since both sides are grouped identically, **cannot** by itself prove the live hero KPI and live grid actually agree in production (review-round-2 correction — the original wording overclaimed this). (1b) **Canonical-group guard** — the check that actually protects hero/grid alignment: `MargeBrutGrid`'s `canon` CTE only ever sums 6 named `GROUP_NAME` values (Food/Breakfast/Wines/Bottled Beer/Soft Drinks/Spirit) while `MargeBrutCostRatioKPI` sums the whole table unconditionally, so any `F_MARGEBRUT_MONTH` row with a `GROUP_NAME` outside that set (a typo'd `12_group_mapping.sql` override, or a future 7th category — the column is bare `NVARCHAR(50)` with no `CHECK` constraint) would make 1a pass while hero and grid silently diverge; must return 0 rows, with a detail SELECT reporting the offending `GROUP_NAME` + its turnover/consumption value. (2) **Coverage guard** — any product with `PROD` turnover in `F_LINEITEM_15MIN`, or invitem with activity in `F_INV_COUNTS_DAY`, whose `D_PRODUCT`/`D_INVITEM` `BOTTOM_MICROSERVICE_NAME` is `NULL` (i.e. silently excluded by the two `WHERE ... IS NOT NULL` filters in `13_f_margebrut_month_control.sql`) — must be 0 rows; includes `TOP 50` offender-detail SELECTs for diagnosis. (3) **Grain sanity** — independently recomputes turnover straight from `F_LINEITEM_15MIN` × `D_PRODUCT` (the same join `13`'s own build uses) and compares to what's stored in `F_MARGEBRUT_MONTH`, catching join fan-out or a stale/partially-failed rebuild; normalizes `@PeriodStart`/`@PeriodEnd` out to full calendar-month boundaries (`@PeriodStartMonth`/`@PeriodEndMonth`, via `DATEFROMPARTS`/`EOMONTH`) before filtering either side, since the fact's `PERIOD_MONTH` is always the 1st of the month while `F_LINEITEM_15MIN.ORDER_DATE` is a real date — an un-normalized mid-month bound applies a different effective window to each side and produces a false FAIL (review-round-2 fix; confirmed both the bug and the fix via MCP, see report). (4) **Purchases reconciliation** (WARN/INFO, not a hard gate — carried-forward TODO from Task 7/DEPLOY.txt) — reports `MargeBrutPurchasesBySupplier`'s total (`F_PURCHASES_DAY.LINE_TOTAL`, F&B-scoped) against `MargeBrutPurchasesKPI`'s total (`F_MARGEBRUT_MONTH.PURCHASES`) plus the delta; guarded with `OBJECT_ID('presentation.F_PURCHASES_DAY') IS NULL` + dynamic SQL (`sp_executesql`) since that table is known not-deployed anywhere yet (QUERY_STATUS #23/#24) and a plain `SELECT` referencing a missing table would fail the whole batch at compile time, taking out every other check in the same run. Since `F_MARGEBRUT_MONTH`/`F_PURCHASES_DAY` are not populated anywhere yet, every check (including 1b's PASS/FAIL and 3's normalization fix) was shape-tested read-only via MCP (`mcp__xms-bi-uat__query`, db `core`) by substituting inline `VALUES` CTEs for the real tables, confirming both the PASS and the FAIL/WARN/INFO paths fire correctly (a first pass at Check 4 caught a mismatched mock `BINARY(32)` hub-ID between the two test CTEs — a test-fixture bug, not a bug in the query — fixed and re-verified). **Authored, shape-verified, not deployed** — developer-run post-go-live; not live-verifiable until the fetcher feed lands and the org's build order has executed.

#### DEPLOYMENT UPDATE — 2026-07-30 (later): first UI review — 3 card defects, all 3 actioned

Ledger [O8](../docs/outstanding/O8-marge-brut-dashboard.md). First look at the rendered dashboard on The Oak & Vine surfaced three cards needing work. All three were root-caused to source, and two new scripts plus the O23 fix were deployed the same day. **The dashboard is now 8 cards, not 9.**

**New scripts:**

- `live/16_cost_ratio_total_fix.sql` — **DEPLOYED to UAT `core` + verified.** `MargeBrutCostRatioByGroup` rendered a `0.00` headline above five correct bars. Cause: `14`'s header returns `NULL AS TotalValue` with the comment "a % grand-total is not meaningful, so NULL". Both halves of that premise are wrong — a grand-total cost-of-sales % is exactly what `MargeBrutCostRatioKPI` and the grid's GRAND TOTAL row already display, and **BarChartCard parses `TotalValue` as numeric and renders NULL as `0.00`**, so the card asserted a specific wrong number rather than omitting one. The sibling `MargeBrutPurchasesBySupplier`, whose non-NULL `TotalValue` renders fine, is the control that isolates NULL as the only variable. Fix returns `100.0 * SUM(CONSUMPTION) / NULLIF(SUM(CASE WHEN CONSUMPTION IS NOT NULL THEN TURNOVER_EXCL END), 0)` — the *same coverage-matched denominator* as the hero KPI (months without a stocktake have NULL CONSUMPTION; including their turnover would understate the ratio), scaled to percentage points to match `BarValue`'s units, and aliased `F` so the injected `@FilterClause` resolves inside the subquery. Verified read-only before deploy and confirmed after: **14.8, agreeing with both the KPI card and the grid GRAND TOTAL**; bar values (12.9 / 22.1 / 27.2 / 34.7 / 35.8) match the grid's Cost % column exactly and are unchanged. Supersedes section 6 of `14` — fold it back in when `14` is next revised.
- `live/17_hide_comps_card.sql` — **RUN against the UAT `report` DB + verified.** `MargeBrutCompsSplit` was completely empty, and investigation showed it cannot populate **on any org**: `COMP` is a hardcoded literal `CAST(0 AS DECIMAL(18,2))` in `13` (deliberate — awaiting a comp-specific Mews signal, not the generic `DISCOUNT_HUB_ID` link), and `STAFF_MEAL` reads `reference.MARGEBRUT_MANUAL`, which only ever received `11`'s **Oct-2025** seed. Live data is Apr–Jul 2026, so the `LEFT JOIN` on `(GROUP_NAME, PERIOD_MONTH)` never matches — Gloucester holds only `2025-10` rows, and Oak & Vine's table is **entirely empty** (`11a` created it; `11` seeded Gloucester only). The same gap blanks the grid's Reverse Prov. / New Prov. columns. This is a **data** gap, not a query defect, so the card is **withdrawn rather than rewritten**: soft-deletes the `dbo.DashboardGridItem` row on every org carrying it. Two things checked first rather than assumed — `dbo.DashboardGrid_Load` really does filter `AND [DashboardGridItem].[IsDeleted] = 0` on its item result set (this DB does **not** honour `IsDeleted` everywhere — `OrganisationDashboardGroupMapping` ignores it entirely), and `dbo.DashboardGridItem_Audit` covers all 15 columns including every NOT NULL one and stamps `AuditAction 'U'` on update (the sibling `DashboardConfig`/`StaffDashboardConfig` audit triggers are broken — ledger O22). Result: **both orgs 9 cards → 8, `comps_card_live = 0`, PASS**, 2 base rows soft-deleted, audited as `U`. Deliberately minimal and reversible — the `MargeBrutCompsSplit` vis query stays LIVE and its `VisualisationConfig`/`VisualisationDataSetMap` entitlements stay, so re-enabling is the single `UPDATE` in the script's ROLLBACK block. `Consumption Mix` left at `Medium = 6` rather than widened to 12 (a lone half-width card ending a dashboard is unremarkable; restretching the donut would only need undoing on re-enable).

**Third defect — `MargeBrutPurchasesBySupplier` empty:** root cause was [O23](../docs/outstanding/O23-growyze-supplier-bottom-level.md), fixed and deployed the same day (Growyze `22`/`23`/`94` — see the Growyze section). The card now renders **3 bars: Bidfood £16,535.89, Reynolds Catering £3,782.45, Matthew Clark £2,226.03 = £22,544.37**, reconciling exactly with the header `TotalValue` that had been resolving all along. `99_verify`'s `supplier_dimension_guard` should now turn PASS on both orgs (**not yet re-run** — worth doing before closing O8).

**Still open from this review:**
- The dashboard shows **two different "Purchases" figures ~2.5× apart** — grid/KPI **£9,056.97** (`F_INV_COUNTS_DAY.ORDER_QTY × UOM_COST`, stocktake-derived, via `F_MARGEBRUT_MONTH.PURCHASES`) vs the supplier card's **£22,544.37** (`F_PURCHASES_DAY.LINE_TOTAL`, purchase-order-derived). This is the long-standing Task 7 / `99_verify` check 4 reconciliation TODO, now showing a concrete gap on real data. Not investigated.
- The Oak & Vine's Growyze data appears to **be** Ibis Gloucester Road's: its `D_LOCATION` Growyze row is literally named `"Ibis Gloucester Rd"`, and both orgs return byte-identical supplier totals and 2,438 purchase lines. Consistent with the "mirror of Gloucester's feed" caveat below; likely an org↔integration credential mapping issue (ledger O24). Pre-existing.

---

#### DEPLOYMENT UPDATE — 2026-07-30: source scoping added; also live on The Oak & Vine (OrgID 16)

Integrations loaded 90 days of Mews + Growyze into The Oak & Vine (ledger O24). Two fixes were needed before Marge Brut could work there, and both changed committed scripts:

1. **Its dashboard was ERRORING, not empty.** `14` is global, so it had already repointed that org's 9 mock cards at `presentation.F_MARGEBRUT_MONTH` — a table that existed only on Gloucester. The mock's literal-`VALUES` bodies needed no tables; the live bodies do. **Reusable lesson: a global vis-query swap breaks every org wired for the dashboard but lacking the fact table** — deploy the two together. Fixed by creating the table from its registered `ddl_script` (never `DeployPresentationTables`).
2. **Source collision.** The Oak & Vine carries four integrations (Mews + NCRAloha POS, Growyze + MarketMan inventory) and the source categories overlap: NCRAloha's `D_PRODUCT.TOP_NAME` is also `'Food'`, worth **£916,792.80** against the Mews Food group's £281.62 — unscoped, cost of sales read roughly **0.5%** (a ~99% gross margin). NCRAloha's `Drinks` (£448,913.60) escaped only because that name matches nothing, and MarketMan's stock only because its invitems all sit under `'All INVITEMs'`. Both were luck, not design.

**Fix — pin each side to its own feed via `BOTTOM_SRC`:** `D_PRODUCT LIKE 'int[_]mews%'` for turnover, `D_INVITEM LIKE 'int[_]growyze%'` for stock and purchases (`LIKE`, so a future `int_mews002` still matches). Applied to `13`, to `14`'s supplier chart, and to `99_verify`'s checks 2/3/4 — which had to follow the build again, since unscoped they FAILed on Oak & Vine against data the dashboard was never meant to include. **This retires the original design's "needs a dedicated Mews+Growyze-only org" constraint: the build is now correct on any organisation regardless of what else is mapped.**

**Results after re-registering `13` and rebuilding both orgs** (TRUNCATE first — narrowing a key set leaves orphans):

| Org | Rows | June 2026 | `99_verify` |
|---|---|---|---|
| Ibis Gloucester Road (21) | 18 — **unchanged** | £17,138.71 / £4,701.37 / **27.4%** | 5 of 6 PASS |
| The Oak & Vine (16) | 24 | £17,138.71 / £4,676.89 / **27.3%** | 5 of 6 PASS |

Only the O23 supplier gap fails on either. On Oak & Vine it fails *differently* — `D_SUPPLIER` has 7 rows because **MarketMan does set `BOTTOM_LEVEL`** — which corroborates that O23 is Growyze-specific.

**Caveats on The Oak & Vine:** it is a **mirror** of Gloucester's feed (June turnover identical to the penny, stock differs by £24.48), so it is a rendering check rather than a business number. The 90-day window does give it 3 stocktakes (30 Apr, 31 May, 30 Jun) vs Gloucester's 2, hence two computable months — **but May is not trustworthy**: stock grew £2,153 against £20,157 of turnover, so consumption computes at £834, Breakfast reads 2.1% cost / 97.9% GP and Soft Drinks goes **negative** (−£20.04 → GP **105.2%**). The 30 Apr count is the first of the feed (`DAYS_SINCE_LAST_COUNT` NULL) — the same first-count anomaly behind Gloucester's £45,298.86 backlog. **Quote June only.** A >100% GP will render as a broken-looking figure.

---

#### DEPLOYMENT UPDATE — 2026-07-29: `live/` build DEPLOYED to UAT (Ibis Gloucester Road, OrgID 21)

Ledger [O8](../docs/outstanding/O8-marge-brut-dashboard.md). Target org `20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D`. `live/DEPLOY.txt` now carries an authoritative DONE/TODO status header — **read that before touching anything in this folder**.

**Status changes:**

| Script | Was | Now |
|---|---|---|
| `live/11a_reference_margebrut_manual_all_orgs.sql` | *(new this session)* | **DEPLOYED UAT** — empty `reference.MARGEBRUT_MANUAL` created in all 20 org DBs, all PRESENT |
| `live/11_reference_margebrut_manual.sql` | not deployed | **DEPLOYED UAT** (Gloucester; 6 Oct-2025 seed rows) |
| `live/10_f_margebrut_month_table.sql` | not deployed | **DEPLOYED UAT** (`core.PresentationTables`, status `live`) |
| `live/13_f_margebrut_month_control.sql` | not deployed | **REWRITTEN + DEPLOYED UAT** (`core.PresentationControl`, tier 2) |
| `live/14_margebrut_vis_queries.sql` | authored, shape-verified, not deployed | **DEPLOYED UAT** — all 9 datasets live globally; 8 of 9 executed against real data |
| `live/12_group_mapping.sql` | not deployed | **SUPERSEDED — do not run** |
| `live/01_provision_uat_org.sql` | not deployed | **SUPERSEDED — do not run** (ledger O19 provisioned the real Ibis orgs) |
| `live/15_report_config.sql` | not deployed | **DEPLOYED UAT `report`** — `@OrgId`/`@DbPrefix` set to Gloucester; ran clean in one transaction |
| `live/99_verify.sql` | authored, shape-verified, not deployed | **REVISED + RUN for real** on Gloucester — 5 of 6 checks PASS |

**`13` was rewritten** — three defects, all found by running the original read-only against real Ibis data:

1. **Grouping moved inline; `12` withdrawn.** `12` wrote the 6 group strings into `SAT_PRODUCT`/`SAT_INVITEM.MICROSERVICE_NAME`, which is the platform's product/item **display-name resolver** — `8_VisualisationQueries.sql` has **82** `COALESCE(<dim>.BOTTOM_MICROSERVICE_NAME, <dim>.BOTTOM_PRODUCT_NAME)` sites, so every product and item label on the org would have collapsed to 6 values (and it collides with ledger O20's plan to make that column the cross-integration join key). It was also inaccurate on this catalogue — the `125 ml`/`50 ml`/`Bottle` portion lines that carry wine and spirit revenue matched no keyword, as did San Miguel, Portobello London Pilsner, Shiraz, Gordons, Kraken, Courvoisier, Chivas Regal and Martell VS; all fell to `ELSE 'Food'`. **Both dimensions already carry the source system's own category**, so no keywords are needed: `D_PRODUCT.TOP_NAME` (Mews) and `D_INVITEM.TOP_NAME` + `MIDDLE_1_NAME` (Growyze). Unmapped categories now map to NULL and are **excluded**, not swept into Food. Nothing writes to the data vault, so grouping is always current and the "re-run 12 before every fact rebuild" rule is gone.
2. **`OPENING` = `CLOSING` ⇒ consumption collapsed to purchases.** The original took `MIN`/`MAX(COUNT_DATE)` *within* the month, but stocktakes happen once at month end, so both resolved to the same count and cancelled. Now **`CLOSING` = last stocktake in the month, `OPENING` = the previous calendar month's closing**, guarded (via `LAG` + an explicit `DATEADD(MONTH,-1,…)` equality test) so a gap in the series yields NULL rather than a stale figure. `CONSUMPTION`/`COST_PCT`/`GP_PCT` are NULL when either end is missing — so the first month of a feed and any not-yet-closed month render blank instead of the old `COST_PCT = 0`, which read as a perfect margin.
3. **`PURCHASES` was ~3× low.** Was `F_INV_COUNTS_DAY.ORDER_QTY × UOM_COST` = £912.29 for June vs `F_PURCHASES_DAY`'s £2,652.84. `ORDER_QTY` summarises only part of the inter-count movement, and the *first* count of a feed carries an unbounded backlog (£45,298.86 on 31 May, `DAYS_SINCE_LAST_COUNT` NULL). Now `F_PURCHASES_DAY.LINE_TOTAL` by `ORDER_DATE`, `ORDER_STATUS = 'COMPLETED'`. This also **closes the Task-7 purchases reconciliation TODO** — the KPI and the supplier chart now share one source and one measure (both £2,652.84 for June); they still differ in period *scope* by design, since the fact only holds months with turnover or a stocktake.

Also: `keys` no longer takes a key from purchases alone, so the fact holds only reportable months (18 rows, not 45 — Growyze order history runs back to Feb 2025 and would otherwise inflate the Purchases KPI against a turnover base that doesn't cover it).

**`14` fixes:** all three cost-%/GP-% denominators were **coverage-mismatched** — they summed every `TURNOVER_EXCL` against consumption that only covers fully-stocktaken months, so the unfiltered hero KPI read **14.3%** instead of the real **27.4%**. Now every denominator sums turnover only where `CONSUMPTION IS NOT NULL` (`TURNOVER_EXCL_CONS`), verified identical filtered and unfiltered. And `MargeBrutPurchasesBySupplier` filtered on `inv.BOTTOM_MICROSERVICE_NAME IS NOT NULL`, which after fix 1 matches nothing — re-pointed at the same `TOP_NAME`/`MIDDLE_1_NAME` basis, which unlike the old `ELSE 'Food'` catch-all genuinely excludes non-F&B stock.

**Validated result (Gloucester, June 2026):** 18 rows (2026-05..07 × 6 groups), June complete — turnover ex-VAT **£17,138.71**, opening **£10,175.54**, purchases **£2,652.84**, closing **£8,127.01**, consumption **£4,701.37**, **cost 27.4% / GP 72.6%**. Per group: Breakfast 24.1%, Bottled Beer 44.9%, Soft Drinks 50.1%, Wines 59.5%, Spirit 13.7%, Food 346.6% (a real group-boundary artifact — Ibis books nearly all food revenue under Breakfast while Growyze splits food stock across `Food/Breakfast` and `Food/Others`; the combined `TOTAL FOOD` row is sane at 25.3%).

**`15` deployed to the report DB** (`xms-sql-fog-uat`, db `report`) in one transaction: audit trigger patched, `BiConfig` inserted, card types 1/3/9/10 granted, 9 datasets mapped, 12-col grid created, dashboard linked, 9 cards placed, group mapping created. Verified independently: 1 dashboard "Marge Brut", `IconName` Restaurant, 9 cards all `MargeBrut*`, 1 group mapping (discoverable, not just direct-URL reachable).

**`99_verify.sql` was itself stale and has been rewritten.** Four of its five checks were written against the withdrawn `MICROSERVICE_NAME` grouping and the old `ORDER_QTY` purchases measure. Run unchanged they produced **false FAILs** — `coverage_guard` reported 88 products / 174 invitems "ungrouped" and `grain_sanity` recomputed NULL, purely because nothing populates that column now — and `reconciliation_fact_self_consistency` **passed while validating a hero formula the dashboard no longer uses** (reporting 14.18%, the un-coverage-matched figure). Changes: check 1a now uses the coverage-matched denominator; check 2 rewritten as a **monetary** coverage threshold over `TOP_NAME`/`MIDDLE_1_NAME` (a row count could never reach zero — Tips, Service Charge, Allergies and Growyze `Other`/`Unknown` are correctly excluded forever) with PASS <1% / WARN 1-5% / FAIL >5%; new **check 2b `supplier_dimension_guard`**; check 3's recompute re-pointed at the category predicate; check 4 rewritten around period *scope* now that both sides share one source and measure.

**Results on Gloucester:** `reconciliation_fact_self_consistency` **PASS** (27.4312%, both sides), `canonical_group_guard` **PASS** (0), `coverage_guard` **PASS** (**£0.04 of £33,144.54** turnover excluded = one Tips line; **£0.00 of £18,302.55** stock), `grain_sanity_turnover` **PASS** (fact 39,773.25 / 33,144.50 = independent recompute, to the penny), `purchases_reconciliation` **PASS on an equal window** (£2,652.84 = £2,652.84, delta £0.00 → the Task-7 reconciliation TODO is **CLOSED**), `supplier_dimension_guard` **FAIL** (ledger O23).

Two things that fell out of running it for real:
- **Coverage is near-total**, which retires the design's "non-F&B stock silently inflates Food via the `ELSE 'Food'` catch-all" worry — the source categories cover this catalogue essentially completely, and what *is* excluded is now quantified rather than swept up.
- **A `datetime2` end-date boundary bug in the check itself.** `F_PURCHASES_DAY.ORDER_DATE` carries a time (16 lines at `2026-06-30 09:00:00`, worth exactly the £129.45 discrepancy that first appeared), so `<= @PeriodEnd` — a `DATE`, i.e. midnight — silently dropped the window's last day. Both `datetime2` comparisons now use an exclusive `< DATEADD(DAY, 1, …)` bound. Reusable: never compare a `datetime2` column `<=` a `DATE` bound.

**Outstanding:** a front-end check as Ibis Gloucester Road, and ledger **O23** — the Growyze `Growyze Suppliers` staging step never populates `BOTTOM_LEVEL`, so the `Supplier Dimension` step's `WHERE BOTTOM_LEVEL = 1` anchor matches nothing, `presentation.D_SUPPLIER` holds only the sentinel, and all 2,438 `F_PURCHASES_DAY` lines fail the supplier join. Re-running the dimension step does **not** help (confirmed: `RowsInserted 1, Success`) — the fix is upstream plus a DV reload, affects every Growyze org, and was deliberately left out of scope here.

**Two platform gotchas worth remembering (both in `live/DEPLOY.txt`):**
- **`core.DeployPresentationTables` DROPs and recreates every registered presentation table** for the target org. Do not use it to add one table to a populated org — it would have wiped all 13 populated tables on Gloucester (`F_LINEITEM_15MIN` 1,464 rows, `F_PURCHASES_DAY` 2,438, `D_INVITEM` 502, …). Create the single table from its registered `ddl_script` instead.
- **A Fact step's rebuild `DELETE` only spans `MIN..MAX` of the *current* result set**, so narrowing a fact's key set leaves orphan rows outside the new window (27 stale purchases-only rows survived a re-register + rebuild until the table was truncated once).
- Useful counterpart: **`sp_ExecuteQuery` returns early with a PRINT when the target table is absent**, so a global `PresentationControl` step skips cleanly on orgs that never receive its table — it does not fail them.

---

## Growyze UOM_COST Pack-Size Fix (2026-07-29)

All scripts in `integrations/Growyze/`. Design: `docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md`. Ledger: [O5](../docs/outstanding/O5-growyze-default-dashboards.md) (owner), blocks [O8](../docs/outstanding/O8-marge-brut-dashboard.md). SDD record: `.superpowers/sdd/2026-07-29-growyze-uom-cost-pack-size/progress.md`.

**Root cause:** `DL_PRODUCTS.price` is the price **per pack**, while stock quantities are stored in **base units** — the deployed count step stores `quantity × size`, and `14_dn_events_size_multiplier_fix.sql` applies the same multiplier to deliveries. Staging never divided cost by pack size, so `F_INV_COUNTS_DAY` multiplied per-ml/per-g quantities by a per-bottle/per-pack price — inflation of 16-113× per item, ~93× across a whole stocktake. This is the O5 `UOM_COST` blocker, previously (2026-07-02) marked "RESOLVED / not present" on the strength of `F_INV_USAGE_DAY` alone (where usage happened to already be in pack units); the defect lives specifically in `F_INV_COUNTS_DAY` and the earlier all-clear did not generalise — reopened 2026-07-29.

### 86. `integrations/Growyze/19_invitem_uom_cost_pack_size.sql`

**Purpose:** MERGE upsert (single `@sql` variable referenced by both the `WHEN MATCHED` UPDATE and `WHEN NOT MATCHED` INSERT branches, per this session's house-pattern ruling — no verbatim-duplicated query block) on the `Growyze Inventory Items` `StagingControl` step. Changes the leaf-item branch's `UOM_COST` from `TRY_CAST(price AS DECIMAL(38,10))` to `TRY_CAST(price AS DECIMAL(38,10)) / COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1)` — cost per pack becomes cost per measure unit. Sub Category / Category branches keep `UOM_COST = NULL`. `staging_columns` and the INVITEM `EntityMappings` rows are unchanged. Presentation layer deliberately not touched — its existing `/ CONVERSION_FACTOR` division continues to carry measure → standardised base unit.

**Scope:** `StagingControl` is environment-wide — corrects every Growyze organisation (Padel Social, Dirty Sixth, Ibis Heathrow, Ibis Gloucester Road). MarketMan is unaffected (separate step, derives `UOM_COST` from `BOMPrice`).

**Status:** Deployed to UAT 2026-07-29 via `92_deploy_uom_cost_fix.ps1`, all 4 Growyze orgs. Measured result on Ibis Gloucester Road (`COUNT_DATE` 2026-06-30, 151 count lines): stock value **£762,277.46 → £8,157.61** (after the companion backfill below), 0 null costs. Padel Social and Dirty Sixth figures did **not** move — their catalogue items have `size = 1`, so `price / 1 = price` makes the division a no-op; only the Ibis orgs were materially affected.

### 87. `integrations/Growyze/20_verify_uom_cost_pack_size.sql`

**Purpose:** Read-only verification companion, run against each target organisation database (two-part names). Section A: headline stock-value reconciliation against `F_INV_COUNTS_DAY`. Section B: named spot checks (Hendricks, SALAMI SLICED MILANO 500G, ONE WATER STILL GLASS). Section C: cost coverage against current-flag leaf `SAT_INVITEM` rows. Section D: data-quality flag for `BOTTOM_ATTR_4` (pack size) `>= 100` — surfaces suspect `kg`-vs-`g` catalogue entries for review rather than attempting a SQL fix.

**Status:** Run on UAT post-deploy, all 4 orgs. Ibis Gloucester Road (acceptance gate): **151 lines / £8,157.61 / 0 null costs** — matches the pre-computed target to the penny. Spot checks: Hendricks £27,655.60 → **£39.51**; SALAMI SLICED MILANO £46,620.00 → **£93.24**; ONE WATER STILL GLASS £53,460.00 → **£71.28**. Coverage: 501 leaf items, 0 null costs. Section D (filters `size >= 100`) flags one known source-data residual: ROCKET WILD (`kg` with `size` 500 meaning grams — reads too **low**), a catalogue error, not a SQL defect. A second residual, CORONET WHITE SUGAR STICKS (`each`, size 1, £6.10 implying £6.10 per sugar stick — reads too **high**), was found by separate manual inspection, not by Section D — its `size = 1` falls outside the `>= 100` filter, so no automated check in this script currently surfaces it.

### 88. `integrations/Growyze/21_invitem_uom_cost_backfill.sql`

**Purpose:** Task 3b addition — targeted, idempotent UPDATE of current-flag (`CURRENT_FLAG = 1, BOTTOM_LEVEL = 1, SRC = 'int_growyze001'`) `SAT_INVITEM` leaf rows still holding the un-divided per-pack `UOM_COST`. **Second defect found during deployment:** an inventory item whose other Growyze attributes were byte-identical between the pre-fix and post-fix batches produced "NC" (no change) — no new satellite row was written and the row kept its old, un-divided cost forever; script 19 + a reload alone never corrected it. CONFIRMED: 4 Ibis Gloucester Road rows were stuck this way. NOT ESTABLISHED: why — `EntityMappings.entity_columns` for this entity includes `UOM_COST`, and `sp_GenerateCDC` hashes every column in that list except the HUB/LINK ID columns, so on paper `UOM_COST` *is* in the CDC checksum; a prior claim that it "does not participate in CDC change detection" is not supported by the code and has been withdrawn. Candidate mechanisms (none established): a `CHECKSUM` collision in `sp_GenerateCDC`, the 4 items being absent from `load.INVITEM` on the affected run, or something else in the CDC path. The UPDATE only matches rows where the stored `UOM_COST` still equals `ATTR_5` (raw pack price) to within 1e-7, `ATTR_4` (pack size) is `> 0` and `<> 1`, and `ATTR_5` (price) `<> 0` — already-correct rows (including `size = 1` rows, where the fix is a no-op, and zero-price rows, which would otherwise false-positive) are left untouched, so a second run matches 0 rows.

**Status:** Deployed to UAT 2026-07-29 via `93_backfill_uom_cost.ps1`, all 4 orgs, each followed by a `sp_DataVaultLoad` reload. On Ibis Gloucester Road this backfilled 4 stuck items (EASY PEELERS alone had overstated stock value by £918.04). Post-backfill: **0 genuinely stuck rows across all 4 orgs** — initial raw counts of 10 (Padel), 5 (Heathrow), 1 (Dirty Sixth) were all zero-price artefacts (`price = 0` so `0 / size = 0 = price`, a false positive in the "still per-pack" detector, not real stuck rows) — note the deployed run predated the `<> 0` predicate fix above, so those raw counts were investigated manually rather than excluded automatically. Ibis Gloucester Road: 501 leaf items, 0 null costs — acceptance gate passed (151 lines / £8,157.61). **Open risk, not fixed here:** the mechanism behind the propagation gap is not established (see above), so a future Growyze cost-only change could fail to propagate the same way until the true cause is found and addressed.

### 89. `integrations/Growyze/92_deploy_uom_cost_fix.ps1`

**Purpose:** PowerShell runner (house method) deploying script 19 to `{env}.core`, then re-running staging → `sp_DataVaultLoad @SchemaList = N'int_growyze001'` → presentation rebuild for every Growyze-mapped organisation (discovered data-driven from `core.Organisations` / `OrganisationIntegrations`, not hardcoded) so the corrected cost propagates. `-WhatIf` preflight, typed `DEPLOY` confirmation, `-OnlyOrg` scoping, `QueryTimeout = 0`, prod-name guard, halt-on-error with a per-run log.

**Status:** Executed against UAT 2026-07-29, all 4 Growyze orgs (Padel Social 10, Dirty Sixth 18, Ibis Heathrow 20, Ibis Gloucester Road 21). Exit 0, no FAIL lines. This run alone under-corrected Ibis Gloucester Road (£9,075.65 vs the required £8,157.61) because of the CDC gap described under script 21 above — resolved by the companion backfill runner (90).

### 90. `integrations/Growyze/93_backfill_uom_cost.ps1`

**Purpose:** Companion PowerShell runner (Task 3b) — runs `21_invitem_uom_cost_backfill.sql` against each Growyze-mapped org's own database (the satellite lives in the org DB, not `core`), then re-runs `sp_DataVaultLoad` so the presentation layer picks up the corrected cost. Same guard pattern as 92 (`-WhatIf`, typed `DEPLOY`, `-OnlyOrg`, prod-name refusal, per-run log).

**Status:** Executed against UAT 2026-07-29, all 4 orgs. Exit 0, no FAIL lines. Acceptance gate passed after this run — see script 21/87 above.

**MarketMan regression:** PASS — untouched. Both runners target only Growyze-mapped orgs (10, 18, 20, 21); MarketMan orgs (1, 3, 4, 5, 6, 7, 16) were never in scope, and the backfill additionally filters `SRC = 'int_growyze001'`.

---

### 91. `integrations/Growyze/22_supplier_bottom_level.sql`

**Purpose:** Fix [O23](../docs/outstanding/O23-growyze-supplier-bottom-level.md) — Growyze suppliers never set `BOTTOM_LEVEL`, so `presentation.D_SUPPLIER` cannot build its Growyze rows and every supplier-resolving card renders empty. The global `Supplier Dimension` `PresentationControl` step anchors its recursive hierarchy CTE on `FROM [datavault].[SAT_SUPPLIER] WHERE BOTTOM_LEVEL = 1 AND CURRENT_FLAG = 1`; all 8 Growyze rows had `BOTTOM_LEVEL = NULL`, so the anchor matched nothing and the recursion never started. Two edits, both against `core` (shared by every Growyze org): (a) the `Growyze Suppliers` `StagingControl` step gains `'Supplier' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS PARENT_ID` plus those three names in `staging_columns`; (b) the `SUPPLIER` `EntityMappings` row gains `PARENT_ID`/`LEVEL_NAME`/`BOTTOM_LEVEL` in `source_columns` + `entity_columns`, so `UploadEntityMappings` regenerates the `Data Vault load - SUPPLIER` step carrying them into `SAT_SUPPLIER`. Mirrors the flat `Growyze Location` step exactly — suppliers are flat (all `PARENT_ID IS NULL`), and `D_LOCATION` proves a single-level hierarchy self-populates BOTTOM/MIDDLE_1/TOP. Of the five Growyze staging steps feeding a `D_*` dimension, Suppliers was the only one missing the column; MarketMan's equivalent sets it, which is why the defect presented differently on the two orgs.

**⚠️ `MICROSERVICE_NAME` is deliberately NOT carried — do not "complete" the mapping by adding it.** `stage.GRYZ_SUPPLIERS` sets it to the literal string `'growyze'` (as `GRYZ_LOCATION` does). Since `MargeBrutPurchasesBySupplier` labels bars with `COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME)`, carrying it would collapse Bidfood, Reynolds Catering and Matthew Clark into **one bar named "growyze"** — replacing an obviously-empty chart with a plausible-looking wrong one. It also violates the MDM manual-entry-only rule (`MICROSERVICE_NAME` is the display-name resolver across ~82 vis-query COALESCE sites). The four working sibling mappings all omit it. Script 23's check 2 asserts it stays NULL.

**Status:** **Deployed to UAT 2026-07-30** via `94_deploy_supplier_bottom_level.ps1`. Regenerated Load step verified to carry `BOTTOM_LEVEL` and **not** `MICROSERVICE_NAME`. Also corrects two proc references carried in from an earlier script's header: there is **no `UploadStagingControl` procedure**, and `UploadEntityMappings` takes `@intSchema`/`@entity` (not `@IntegrationSchema`) — `@entity` is pinned to `SUPPLIER` because an unscoped call regenerates every Growyze entity and multi-source entities are known to collide (error 8156 / silent last-source-wins).

### 92. `integrations/Growyze/23_verify_supplier_bottom_level.sql`

**Purpose:** Read-only verification for script 22 — six checks walking the whole chain so a failure names the broken link rather than just "still empty": (1) `SAT_SUPPLIER` current Growyze rows all carry `BOTTOM_LEVEL = 1` (a *partial* count means CDC left rows stuck — the `CHECKSUM`-based failure mode precedented by script 21, whose remedy is a targeted backfill, not another reload); (2) `MICROSERVICE_NAME` stays NULL (the chart-collapse regression above); (3) `D_SUPPLIER` holds Growyze rows, counted by `BOTTOM_SRC` so a co-resident inventory integration's suppliers can't mask the result; (4) every `F_PURCHASES_DAY` line resolves a supplier; (5) the card's own data query reproduced verbatim, including its inner join and food/beverage scope; (6) one-row PASS/FAIL roll-up over 1–4.

**Status:** **Verified on UAT 2026-07-30, both orgs 16 and 21.** Confirmed it detects the *pre*-fix state before deploying (`sat=8 bl_set=0 d_supplier=0 lines=2438 unmatched=2438 → FAIL`) and PASSes after (`bl_set=8 d_supplier=8 unmatched=0`). Check 5 returns **Bidfood £16,535.89 / Reynolds Catering £3,782.45 / Matthew Clark £2,226.03 = £22,544.37**, reconciling exactly with the card's header `TotalValue`.

### 93. `integrations/Growyze/94_deploy_supplier_bottom_level.ps1`

**Purpose:** Runner for script 22, modelled on 92 (same job shape: a Growyze staging change needing a per-org reload). Sequence: `22` against `core` → `UploadEntityMappings @intSchema='int_growyze001', @entity='SUPPLIER'` → assert the regenerated Load step carries `BOTTOM_LEVEL` without `MICROSERVICE_NAME` → per org `sp_DataVaultLoad @SchemaList='int_growyze001'` → per-org verify roll-up gate. Same guards as 92 (`-WhatIf`, typed `DEPLOY`, prod-name refusal, per-run log, halt-on-error) plus: `-OnlyOrg` takes an **int array** so a multi-org run is one coherent log; a typo'd org id throws rather than silently reloading fewer orgs; and the log **names the orgs it did NOT reload**, because 22's control-plane change is shared by every Growyze org — narrowing the reload does not narrow the fix, and a log listing only the reloaded orgs would read as full coverage.

**Status:** **Executed against UAT 2026-07-30, orgs 16 + 21 only** (user's scope decision). Exit 0, `RESULT PASS` on both. **Padel Social (10), Dirty Sixth (18) and Ibis Heathrow (20) were NOT reloaded** — they still receive the shared control-plane change and will apply it on their next scheduled load, unattended and unverified. CDC left no rows stuck (8 of 8 on both orgs), so no backfill was needed.

**Gotcha found and fixed during the first real run:** a one-row `Invoke-Sqlcmd` result is a single `DataRow`, and **indexing a `DataRow` with `[0]` returns its first COLUMN VALUE, not the row** — so `$result[0].Verdict` resolved against a string and threw `PropertyNotFoundStrict` under `Set-StrictMode`. It aborted the run *after* the control-plane deploy had succeeded but before any reload. Both single-row result reads now wrap in `@()`. Worth copying into any future runner that gates on a scalar query.

---

## Mews (int_mews001)

All scripts in `integrations/Mews/`. Created 2026-07-03. Design/plan: `docs/superpowers/specs/2026-07-03-mews-dv-mapping-design.md` + `docs/superpowers/plans/2026-07-03-mews-dv-mapping.md`. Org: `20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43` (DEV).

### 81. `integrations/Mews/01_staging_control.sql`

**Purpose:** 15 StagingControl MERGE records for `int_mews001` — 8 tier-1 dimension steps (Location, Product [3-tier: type/product/variant+synthetic `{productId}-DEFAULT`], Modifier, Tax, Tender, Discount, Channel, Revenue Center), 4 tier-1 transactional steps (Customer Order, Line Item, Line Item Tax, Line Item Discount), 2 tier-2 link staging steps (Order Revenue Center Link, Discount Line Link), and 1 tier-2 union step (Line Item Combined → `stage.MEWS_LINEITEM_ALL`, added 2026-07-03 8156 fix — see 82). The 3 CRM steps (Customer, Address, Contact) were GDPR-removed 2026-07-03 — see 85.

**Status:** revised 2026-07-03 (added step 18 union; removed CRM steps 13–15) — awaiting re-deploy. Original 17-step version deployed 2026-07-03; E2E staging phase passed.

---

### 82. `integrations/Mews/02_entity_mappings.sql`

**Purpose:** 16 EntityMappings MERGE records — 10 hub rows (LOCATION, PRODUCT, MOD, TAX, TENDER, DISCOUNT, CHANNEL, REVCENTER, CUSTORDER, LINEITEM) + 6 link rows (CUSTORDER_LOCATION, CUSTORDER_LINEITEM, LINEITEM_PRODUCT, LINEITEM_TAX, DISCOUNT_LINEITEM, CUSTORDER_REVCENTER). One row per entity — LINEITEM and CUSTORDER_LINEITEM map from the tier-2 union table `MEWS_LINEITEM_ALL`; guarded DELETEs retire the six obsolete per-type rows in already-deployed environments. INDIVIDUAL/ADDRESS/CONTACT + ADDRESS_INDIVIDUAL/CONTACT_INDIVIDUAL were GDPR-removed 2026-07-03 — see 85.

**Root-cause note (E2E failure 2026-07-03):** the original design had 3 mapping rows each for LINEITEM/CUSTORDER_LINEITEM (one per PROD/TAX/DISCOUNT stage table). `core.UploadEntityMappings` parses column JSON into temp tables keyed by `entity_name` only (`3_CoreStoredProceduresAndFunctions.sql:1469,1479`), so multiple rows per entity triple the generated column list → SQL 8156 ("LINEITEM_HUB_ID specified multiple times") and `sp_DataVaultLoad` rolls back (surfaced as 2754 because the proc re-raises with `@ErrorNumber` in the severity slot). Even without 8156, all rows share step_name `Data Vault load - {entity}`, so the MERGE keeps only the last source table. Platform contract = one mapping row per entity; multi-source union belongs in staging (NCRAloha precedent: `NCR_LINE_ITEM_DETAIL`).

**Status:** revised 2026-07-03 — awaiting re-deploy. Original 25-row version deployed 2026-07-03 and caused the DV-load E2E failure.

---

### 83. `integrations/Mews/03_upload_load_steps.sql`

**Purpose:** `EXEC [core].[UploadEntityMappings] @intSchema = N'int_mews001'` — translates the 16 EntityMappings rows into 16 StagingControl `step_type = 'Load'` rows. Developer-executed (EXEC not permitted via MCP); run after 01 + 02 + **05 Section A** (if 03 runs before 05, the still-present CRM mappings regenerate the CRM load steps).

**Status:** deployed 2026-07-03 (twice: first against the triplicate mappings, then post-8156-fix at 14:02 — load succeeded) — must re-run after the GDPR removal (01 → 02 → 05 → 03).

---

### 84. `integrations/Mews/04_verification.sql`

**Purpose:** Read-only, 5-section verification script (control-plane / stage / data-quality / DV / presentation), one `check_name, expected, actual, status` row per check. Section A run via MCP against `core` on 2026-07-03 (see below); Sections B–E are Task 7's post-deploy job.

**Corrected expected-count baselines (2026-07-03 live data, supersede the task-6 brief's literals):**

| Table/check | Expected | Note |
|---|---|---|
| MEWS_LOCATION | 2 | |
| MEWS_PRODUCT | 389 (TOP 12 / MIDDLE_1 98 / BOTTOM 279) | |
| MEWS_MOD | 0 | no modifier data landed yet |
| MEWS_TAX | 1 | single-tax assumption depends on this staying 1 |
| MEWS_TENDER | 6 | |
| MEWS_DISCOUNT | 2 | inactive members deliberately included (orphan-link fix) |
| MEWS_CHANNEL | **1**, not 2 | area "Rooms" confirmed inactive; filter stands — this is the corrected value |
| MEWS_REVCENTER | 0 | inactive members deliberately included (orphan-link fix) |
| MEWS_CUSTORDER | 19 | |
| MEWS_LINEITEM | 22 (5 with VOID_FLAG=1) | |
| MEWS_LINEITEM_TAX | **DL-derived, not the literal 17** | compare to `CAST(tax AS DECIMAL(18,2)) <> 0` count on DL_INVOICE_ITEMS/DL_INVOICES |
| MEWS_LINEITEM_DISCOUNT | 0 | no non-null promoCodeId observed yet |
| MEWS_CUSTOMER / MEWS_ADDRESS / MEWS_CONTACT | **removed** | CRM lane GDPR-removed 2026-07-03; stage tables must not exist (05 purge) |
| both `_LNK` staging tables | 0 | |
| HUB_LINEITEM (DV) | derived = MEWS_LINEITEM + MEWS_LINEITEM_TAX + MEWS_LINEITEM_DISCOUNT (39 today) | never hardcode — derive |
| LNK_CUSTORDER_LINEITEM | = HUB_LINEITEM count | |
| LNK_LINEITEM_PRODUCT | 22 | |
| LNK_LINEITEM_TAX | 17 | |
| LNK_CUSTORDER_LOCATION | 19 | |
| LNK_CONTACT_INDIVIDUAL / LNK_ADDRESS_INDIVIDUAL | **0 Mews-sourced rows** | GDPR purge check (05) |

**Count-drift rule:** if the Mews fetcher has landed more data by the time Task 7 runs, re-derive expected counts from the DL side rather than trusting these literals — the script already does this for LINEITEM_TAX and ADDRESS per the brief; the rest are point-in-time literals that may need bumping.

**Section A MCP result (2026-07-03, pre-deploy, `mcp__xms-bi-dev__query` against `core`):** `staging_steps` actual 0 (expected 17, FAIL), `load_steps_generated` actual 0 (expected 25, FAIL), `entity_mappings` actual 0 (expected 25, FAIL). Correct pre-deploy observation — 01/02/03 have not been deployed yet, so `int_mews001.StagingControl`/`EntityMappings` are provisioned but empty.

**E2E test result (2026-07-03, first deploy):** stage phase PASSED end-to-end (live Mews API pull, pagination fix confirmed, DL re-staged, CTL completed); DV load phase FAILED — SQL 8156 on `load.CUSTORDER_LINEITEM` (tripled column list, see 82), then succeeded at 14:02 after the fix. Section A expectations now 15/16/16 plus the `one_mapping_row_per_entity` guard; Section B gains `stage_MEWS_LINEITEM_ALL` = sum-of-parts and GDPR-absence checks; DV sections gain GDPR purge checks.

**Data-quality audit findings (2026-07-03, post-14:02 run):** ① fullName was staged whole into FORENAME (surnames discarded) — resolved by the GDPR removal of the CRM lane; the validated split logic (first token=FORENAME, last=SURNAME, middle=MIDDLE_NAMES; MCP-tested: 365 rows, 143 surnames, 15 middles) is preserved in the 01 removal note for any future re-enable. ② "LNK_CONTACT_INDIVIDUAL loaded 0 rows silently" — **disproven, expected behaviour**: `sp_ProcessLink` DELETEs already-present LNK_IDs from the `load.*` table before inserting, so an empty load link table + LNK rows timestamped from an earlier run is the normal idempotent signature, not silent loss (confirmed live: links first committed at 14:02 still hold their load rows; the 12:56-committed link had its 258 load rows dedup-deleted). Also note failed `sp_DataVaultLoad` runs COMMIT completed entities — there is no cross-entity rollback.

**Status:** revised 2026-07-03 — Sections B–E await the GDPR re-deploy (01→02→05→03) and DV load re-run.

---

### 85. `integrations/Mews/05_remove_crm_pii.sql`

**Purpose:** GDPR removal of the Mews CRM lane. Section A (vs `core`): deletes the 5 CRM EntityMappings rows (INDIVIDUAL, ADDRESS, CONTACT, ADDRESS_INDIVIDUAL, CONTACT_INDIVIDUAL), the 3 CRM staging steps, and the 5 generated Load steps. Section B (vs org DB): drops `stage.MEWS_CUSTOMER/MEWS_ADDRESS/MEWS_CONTACT`, clears the CRM `load.*`/`load.CDC_*` tables, and purges Mews-sourced rows (`SRC = 'int_mews001'`) from the CRM hubs/satellites/links loaded on 2026-07-03 (365 names, 258 contacts, 258 link rows). Idempotent; deliberately not flag-reversible. **Must run before 03** or the CRM load steps regenerate. Landing-layer `DL_CUSTOMERS` still holds raw PII — flagged to the fetcher team (remove customers endpoint from the fetch config).

**Status:** created 2026-07-03 — not deployed.
