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

## Mews (int_mews001)

All scripts in `integrations/Mews/`. Created 2026-07-03. Design/plan: `docs/superpowers/specs/2026-07-03-mews-dv-mapping-design.md` + `docs/superpowers/plans/2026-07-03-mews-dv-mapping.md`. Org: `20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43` (DEV).

### 81. `integrations/Mews/01_staging_control.sql`

**Purpose:** 17 StagingControl MERGE records for `int_mews001` — 8 tier-1 dimension steps (Location, Product [3-tier: type/product/variant+synthetic `{productId}-DEFAULT`], Modifier, Tax, Tender, Discount, Channel, Revenue Center), 4 tier-1 transactional steps (Customer Order, Line Item, Line Item Tax, Line Item Discount), 3 tier-1 CRM steps (Customer, Address, Contact), and 2 tier-2 link staging steps (Order Revenue Center Link, Discount Line Link).

**Status:** created — not deployed.

---

### 82. `integrations/Mews/02_entity_mappings.sql`

**Purpose:** 25 EntityMappings MERGE records — 15 hub rows (#1–#15: LOCATION, PRODUCT, MOD, TAX, TENDER, DISCOUNT, CHANNEL, REVCENTER, CUSTORDER, 3× LINEITEM sources, INDIVIDUAL, ADDRESS, CONTACT) + 10 link rows (#16–#25: CUSTORDER_LOCATION, CUSTORDER_LINEITEM ×3 sources, LINEITEM_PRODUCT, LINEITEM_TAX, DISCOUNT_LINEITEM, CUSTORDER_REVCENTER, ADDRESS_INDIVIDUAL, CONTACT_INDIVIDUAL). The 10 link rows collapse into 8 distinct `LNK_*` tables at load time.

**Status:** created — not deployed.

---

### 83. `integrations/Mews/03_upload_load_steps.sql`

**Purpose:** `EXEC [core].[UploadEntityMappings] @intSchema = N'int_mews001'` — translates the 25 EntityMappings rows into 25 StagingControl `step_type = 'Load'` rows. Developer-executed (EXEC not permitted via MCP); run after 01 + 02.

**Status:** created — not deployed.

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
| MEWS_CUSTOMER | 364 | |
| MEWS_ADDRESS | **0 — genuine source gap, not a failure** | check passes on equality with the DL-side derivation (both 0 today) |
| MEWS_CONTACT | 257 (185 EMAIL + 72 PHONE) | |
| both `_LNK` staging tables | 0 | |
| HUB_LINEITEM (DV) | derived = MEWS_LINEITEM + MEWS_LINEITEM_TAX + MEWS_LINEITEM_DISCOUNT (39 today) | never hardcode — derive |
| LNK_CUSTORDER_LINEITEM | = HUB_LINEITEM count | |
| LNK_LINEITEM_PRODUCT | 22 | |
| LNK_LINEITEM_TAX | 17 | |
| LNK_CUSTORDER_LOCATION | 19 | |
| LNK_CONTACT_INDIVIDUAL | 257 | |
| LNK_ADDRESS_INDIVIDUAL | 0 | |

**Count-drift rule:** if the Mews fetcher has landed more data by the time Task 7 runs, re-derive expected counts from the DL side rather than trusting these literals — the script already does this for LINEITEM_TAX and ADDRESS per the brief; the rest are point-in-time literals that may need bumping.

**Section A MCP result (2026-07-03, pre-deploy, `mcp__xms-bi-dev__query` against `core`):** `staging_steps` actual 0 (expected 17, FAIL), `load_steps_generated` actual 0 (expected 25, FAIL), `entity_mappings` actual 0 (expected 25, FAIL). Correct pre-deploy observation — 01/02/03 have not been deployed yet, so `int_mews001.StagingControl`/`EntityMappings` are provisioned but empty.

**Status:** created — not deployed. Section A MCP-verified (pre-deploy state confirmed 2026-07-03); Sections B–E await Task 7 post-deploy run.
