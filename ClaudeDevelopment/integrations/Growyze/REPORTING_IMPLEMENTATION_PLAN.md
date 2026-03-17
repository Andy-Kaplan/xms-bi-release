# Growyze Reporting Wishlist — Implementation Plan

**Date:** 2026-03-06
**Source analysis:** [`REPORTING_WISHLIST_ANALYSIS.md`](REPORTING_WISHLIST_ANALYSIS.md)
**Status:** Reviewed by 4-agent scrutiny team; ready for development

---

## Executive Summary

The analysis proposed 12 datasets (22 vis query records) for Growyze reporting. A 4-agent scrutiny review identified a **critical blocker** — the `IntegrationType='POS'` filter on F_PRODUCT_MARGIN_DAY and F_LINEITEM_15MIN excludes all Growyze data — plus several rating reclassifications and a cross-fact join redesign.

After incorporating all findings:
- **14 query records** in Phase 1 (8 datasets) — deployable after prerequisite P1
- **5 query records** in Phase 2 (3 datasets) — ready to build
- **1 query record** held/blocked (SalesByDayOfWeek — no LINEITEM_TIMESTAMP)
- **Total: 19 deployable + 1 held = 20 specified records across 12 datasets**

---

## 1. Prerequisites & Infrastructure Fixes

Before any Growyze visualisation queries can be built, five infrastructure issues must be resolved. Each is labelled P1-P5 for cross-referencing throughout this document.

### P1. F_PRODUCT_MARGIN_DAY and F_LINEITEM_15MIN exclude Growyze data (CRITICAL BLOCKER)

**What:** Both presentation fact build steps filter on `IntegrationType = 'POS'` when selecting from `SAT_LINEITEM`. Growyze is registered as `IntegrationType = 'INVENTORY'`. Result: zero Growyze rows in either fact table.

**Where:**
- `8_PresentationControl.sql` line 1258 (F_LINEITEM_15MIN): `AND IG.[IntegrationType] = ''POS''`
- `8_PresentationControl.sql` line 3398 (F_PRODUCT_MARGIN_DAY): `AND IG.[IntegrationType] = ''POS''`

**Datasets blocked:** 7 of 12 proposed datasets depend on F_PRODUCT_MARGIN_DAY (InvCOGSByCategory, ProductComparison, InvMarginTrend, InvMargeBrut, InvWeeklySummary, InvPeriodComp) plus 1 depends on F_LINEITEM_15MIN (SalesByDayOfWeek).

**Design options evaluated:**

| Option | Approach | Pros | Cons |
|---|---|---|---|
| A | Change filter to `IN ('POS', 'INVENTORY')` | Simplest change | Appears too broad but is actually safe (see below) |
| B | Add new IntegrationType `'POS_INVENTORY'` | Clean type separation | Cascading changes to all INVENTORY-filtered steps; high risk |
| C | Filter on presence of LINEITEM entity mappings | Data-driven, future-proof | PresentationControl runs inside client DB; cannot easily query per-integration-schema tables dynamically |
| D | Filter on actual SAT_LINEITEM data presence | Empirically correct | Ties build to data presence rather than configuration |

**Recommended approach: Option A** — `IN ('POS', 'INVENTORY')`. This is safe because:

1. The `INNER JOIN` on `LI.[SRC] = IG.[SchemaName]` already ensures only integrations with actual LINEITEM rows in `SAT_LINEITEM` participate.
2. MarketMan (INVENTORY) has **no LINEITEM entity mapping** — its schema name never appears in `SAT_LINEITEM.SRC`, so zero MarketMan rows are returned even with the widened filter.
3. SurveyHero (SURVEY) is excluded by the filter regardless.
4. The `IntegrationType` filter's purpose is to prevent accidental cross-contamination — the JOIN on SRC already provides the real guard.

**Deliverable:** New script `ClaudeDevelopment/integrations/Growyze/08_presentation_filter_fix.sql` containing two MERGE statements against `core.PresentationControl` that update the `query_sql` column for the F_LINEITEM_15MIN and F_PRODUCT_MARGIN_DAY steps, changing `= ''POS''` to `IN (''POS'', ''INVENTORY'')`.

**Impact:** After deployment and a presentation layer rebuild, both fact tables will include Growyze LINEITEM rows. Unblocks 7 of 12 proposed datasets.

---

### P2. Growyze LINEITEM entity mapping missing LINEITEM_TIMESTAMP (BLOCKER for SalesByDayOfWeek)

**What:** The LINEITEM entity definition (v3, Live, `8_DataVaultEntities.sql`) includes `LINEITEM_TIMESTAMP` as a `DATETIME2(7)` column. The Growyze LINEITEM entity mapping (#9 in `04_entity_mappings.sql`) maps only 8 columns — `LINEITEM_TIMESTAMP` is **not** among them:

```
entity_columns: ["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE"]
```

The F_LINEITEM_15MIN build step uses `LINEITEM_TIMESTAMP` for its 15-minute time bucketing. With no timestamp mapped, all Growyze rows get `LINEITEM_TIMESTAMP = NULL`, collapsing the heatmap into a single NULL bucket.

**Root cause:** The Growyze `DL_DISHES` source has `createdDate` — but this may be date-only. Data investigation required (see DQ-4 in Section 2).

**Fix (if DQ-4 confirms time precision):**
1. Add LINEITEM_TIMESTAMP column to GRYZ_LINEITEM staging step in `02_staging_tier1.sql`
2. Add `LINEITEM_TIMESTAMP` to entity mapping #9 in `04_entity_mappings.sql`

**Datasets blocked without this fix:** Dataset 9 (SalesByDayOfWeek / HeatmapCard).

---

### P3. INVITEM_STOCKORDER entity needs satellite attributes (RESOLVED — script exists)

**What:** The `INVITEM_STOCKORDER` entity was originally created without satellite attributes. Growyze mapping #17 maps 6 satellite columns that don't yet exist in the DV tables.

**Status:** Fix script exists at `ClaudeDevelopment/integrations/Growyze/05_invitem_stockorder_entity_fix.sql`. Created, not yet deployed.

**Datasets dependent:** F_PURCHASES_DAY (scripts 06 + 07) and any purchase-order-based visualisations.

---

### P4. F_PURCHASES_DAY presentation table and build step (RESOLVED — scripts exist)

**What:** The analysis labelled UOM_COST enrichment and F_PURCHASES_DAY as "medium-term". All three scripts are already written:

| Script | Purpose | Status |
|---|---|---|
| `05_invitem_stockorder_entity_fix.sql` | Entity definition + load table fix | Created, not deployed |
| `06_purchases_presentation_table.sql` | PresentationTables DDL for F_PURCHASES_DAY | Created, not deployed |
| `07_purchases_presentation_control.sql` | PresentationControl build step (Tier 1) | Created, not deployed |

**Deploy order:** 05 → 06 → 07.

---

### P5. Growyze staging scripts 02 + 03 must be re-deployed

**What:** Multiple bugs were fixed in `02_staging_tier1.sql` and `03_staging_tier2_3.sql` on 2026-03-06 (CAST fixes, LINEITEM_TYPE, EVENT_TYPE corrections). Not yet re-deployed. Without re-deployment, Growyze staging fails and no data flows to presentation tables.

**Datasets blocked:** All 12 proposed datasets.

---

### Prerequisite Dependency Chain

```
P5 (redeploy 02+03) ──────────────────────────────────> [Growyze data flows to DV]
                                                              |
P1 (POS filter fix) ──> [rebuild presentation] ────────> F_PRODUCT_MARGIN_DAY has Growyze rows
                                                         F_LINEITEM_15MIN has Growyze rows
                                                              |
P2 (LINEITEM_TIMESTAMP) ──> [redeploy 02+04] ─────────> LINEITEM_TIMESTAMP populated
                                                              |
P3 (entity fix) ──> P4 (F_PURCHASES_DAY) ──> [rebuild] ──> F_PURCHASES_DAY populated
```

**Critical path:** P5 must deploy first. P1 can deploy in parallel but only takes effect after a presentation rebuild following successful staging + DV load.

---

## 2. Data Quality Gate

All queries below run from the `core` database via MCP using three-part naming against GrowyzeDev org `20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`. Strip all SQL comments before executing.

### DQ-1: F_PRODUCT_MARGIN_DAY has Growyze rows with non-NULL AVG_NET_COST

*Run after P1 + P5 deployed and presentation rebuilt.*

```sql
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN AVG_NET_COST IS NOT NULL AND AVG_NET_COST <> 0 THEN 1 ELSE 0 END) AS rows_with_cost,
    SUM(CASE WHEN AVG_NET_COST IS NULL OR AVG_NET_COST = 0 THEN 1 ELSE 0 END) AS rows_without_cost,
    MIN(ORDER_DATE) AS min_date,
    MAX(ORDER_DATE) AS max_date
FROM [20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY]
```

**Pass:** `total_rows > 0` AND `rows_with_cost > 0`.

### DQ-2: F_INV_USAGE_DAY has non-zero activity rows

*Run after P5 deployed and presentation rebuilt.*

```sql
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN ABS(SALE_QTY) > 0 THEN 1 ELSE 0 END) AS sale_rows,
    SUM(CASE WHEN ABS(WASTE_QTY) > 0 THEN 1 ELSE 0 END) AS waste_rows,
    SUM(CASE WHEN ABS(ORDER_QTY) > 0 THEN 1 ELSE 0 END) AS order_rows,
    SUM(CASE WHEN UOM_COST IS NOT NULL AND UOM_COST <> 0 THEN 1 ELSE 0 END) AS rows_with_uom_cost
FROM [20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_INV_USAGE_DAY]
```

**Pass:** `total_rows > 0` AND at least one of sale/waste/order > 0. `rows_with_uom_cost` expected to be 0 (confirms PARTIAL rating).

### DQ-3: SAT_LNK_LOCATION_OCCASION_PRODUCT has NET_COST populated

```sql
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN NET_COST IS NOT NULL AND NET_COST <> 0 THEN 1 ELSE 0 END) AS rows_with_cost,
    SUM(CASE WHEN NET_PRICE IS NOT NULL AND NET_PRICE <> 0 THEN 1 ELSE 0 END) AS rows_with_price,
    AVG(CAST(NET_COST AS FLOAT)) AS avg_cost,
    AVG(CAST(NET_PRICE AS FLOAT)) AS avg_price
FROM [20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[datavault].[SAT_LNK_LOCATION_OCCASION_PRODUCT]
WHERE CURRENT_FLAG = 1
```

**Pass:** `total_rows > 0` AND `rows_with_cost > 0`.

### DQ-4: Growyze LINEITEM_TIMESTAMP precision check

*Determines whether P2 is fixable.*

```sql
SELECT TOP 10
    createdDate,
    LEN(createdDate) AS field_length,
    CASE
        WHEN TRY_CAST(createdDate AS DATETIME2) IS NOT NULL
             AND DATEPART(HOUR, TRY_CAST(createdDate AS DATETIME2)) <> 0
        THEN 'HAS_TIME'
        WHEN TRY_CAST(createdDate AS DATETIME2) IS NOT NULL
        THEN 'DATE_ONLY_OR_MIDNIGHT'
        ELSE 'UNPARSEABLE'
    END AS precision_check
FROM [20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[int_growyze001].[DL_DISHES]
WHERE createdDate IS NOT NULL
```

**Pass for P2:** At least some rows show `HAS_TIME`. If all `DATE_ONLY_OR_MIDNIGHT`, Dataset 9 is permanently blocked for Growyze.

### DQ-5: Growyze staging deployment verification

```sql
SELECT
    t.name AS table_name,
    p.rows AS row_count
FROM [20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].sys.tables t
INNER JOIN [20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN [20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
WHERE s.name = 'stage'
  AND t.name LIKE 'GRYZ_%'
ORDER BY t.name
```

**Pass:** At least `GRYZ_LINEITEM`, `GRYZ_INVITEMS`, `GRYZ_STOCKEVENT`, `GRYZ_PRODUCT` exist with `row_count > 0`.

---

## 3. Revised Rating Classification

| # | Dataset | Card Types | Original Rating | Revised Rating | Rationale |
|---|---|---|---|---|---|
| 1 | InvCOGSByCategory | Pie, StackedBar | FEASIBLE | **FEASIBLE (after P1)** | Requires POS filter fix for F_PRODUCT_MARGIN_DAY |
| 2 | InvConsumption | Bar, Grid | PARTIAL | **PARTIAL (UOM_COST scripts ready)** | Volume works now; cost enrichment is a deployment action, not design work |
| 3 | InvWasteAnalysis | Bar, MultiLine, Grid | PARTIAL | **PARTIAL (UOM_COST scripts ready)** | Same as #2 |
| 4 | ProductComparison | Grid | FEASIBLE | **FEASIBLE (after P1)** | Requires P1 |
| 5 | InvMarginTrend | MultiLine | FEASIBLE | **FEASIBLE (after P1)** | Requires P1 |
| 6 | InvMargeBrut | GroupedGrid | FEASIBLE | **FEASIBLE (after P1, redesigned)** | Cross-fact join redesigned; requires P1 |
| 7 | InvWeeklySummary | Combined, Grid | FEASIBLE | **FEASIBLE (after P1)** | Requires P1 |
| 8 | InvStockActivity | StackedBar, MultiLine | PARTIAL | **PARTIAL (UOM_COST scripts ready)** | Renamed from "InvStockValue"; volume works now |
| 9 | SalesByDayOfWeek | Heatmap | FEASIBLE | **BLOCKED (P1 + P2 required)** | No LINEITEM_TIMESTAMP mapped for Growyze |
| 10 | InvPeriodComp | Combined x3 | FEASIBLE | **FEASIBLE (after P1)** | Requires P1; split into WoW/MoM/YoY |
| 11 | InvVarianceCategory | StackedBar | BLOCKED | **BLOCKED** | No change — requires COUNT events. Serves MarketMan now. |
| 12 | InvTheoVsActualGP | Combined | BLOCKED | **PARTIAL** | Theoretical GP% deliverable now (after P1); only Actual GP% needs counts |

### Net Effect of Deploying All Prerequisites

- After P1 + P5: **7 datasets immediately buildable**
- After P3 + P4: **4 PARTIAL datasets upgradeable** to full cost-weighted analysis
- Dataset 12: partially functional (Theoretical GP% only)
- Dataset 9: blocked pending P2 data investigation (DQ-4)
- Dataset 11: blocked (external dependency: Growyze stocktake API)

---

## 4. Phase 1 — Visualisation Query Specifications

8 datasets producing **14 vis query records**. All queries target existing presentation tables and dimensions.

**Conventions:**
- All FilterDefinitions follow the **Growyze filter template** (only Locations, InvItems/Products, ProductCategories, StartDate, EndDate populated; all others empty)
- ParameterMappings always include `LocationList`, `StartDate`, `EndDate`
- Dual-result-set pattern: result set 1 = data, result set 2 = header metadata
- `WHERE 1=1 @FilterClause` in every query
- Aliases: `F` = fact, `P`/`product` = D_PRODUCT, `I`/`invitem` = D_INVITEM, `L`/`location` = D_LOCATION, `C` = CALENDAR
- All recipe-cost queries include "Based on recipe cost" in header Description

**Standard Growyze Product FilterDefinitions JSON** (referenced as `GROWYZE_FILTER_PRODUCT`):
```json
{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}
```

**Standard Growyze InvItem FilterDefinitions JSON** (referenced as `GROWYZE_FILTER_INVITEM`):
```json
{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}
```

**Standard ParameterMappings** (all queries):
```json
{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}
```

---

### 4.1 InvCOGSByCategory (Cost of Sales / GP% by Category)

**Category:** Inventory | **Fact:** F_PRODUCT_MARGIN_DAY | **Prerequisite:** P1 | **Addresses:** C2, C6, C8

#### 4.1.1 PieChartCard

| Field | Value |
|---|---|
| DataSetName | `InvCOGSByCategory` |
| VisualizationType | `PieChartCard` |
| FilterDefinitions | `GROWYZE_FILTER_PRODUCT` |

**QueryTemplate:**
```sql
WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT
    CATEGORY AS Label, COGS AS Value,
    ROW_NUMBER() OVER(ORDER BY COGS DESC) AS Id,
    'linear' AS Curve, 'total' AS Stack, 'true' AS Area,
    'ascending' AS StackOrder, 'false' AS ShowMark, 'COGS' AS LegendLabel
FROM Base
WHERE CATEGORY IS NOT NULL

SELECT
    'COGS by Category' AS Title,
    'Based on recipe cost' AS Description,
    NULL AS Trend, NULL AS Chip,
    (SELECT FORMAT(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),'N0')
     FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
     INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     WHERE 1=1 AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL @FilterClause) AS PiePrimaryText,
    'Total COGS' AS PieSecondaryText
```

#### 4.1.2 StackedBarChartCard

| Field | Value |
|---|---|
| DataSetName | `InvCOGSByCategory` |
| VisualizationType | `StackedBarChartCard` |
| FilterDefinitions | `GROWYZE_FILTER_PRODUCT` |

**QueryTemplate:**
```sql
WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS,
        SUM(ISNULL(F.[NET_VALUE],0)) AS REVENUE,
        SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS GP
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[NET_VALUE],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT CATEGORY, 'COGS' AS Label, COGS AS Value, 'A' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
    UNION ALL
    SELECT CATEGORY, 'Gross Profit' AS Label, GP AS Value, 'A' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
) SUB

SELECT 'Category' AS XAxisLabel, 'Value' AS YAxisLabel,
    'COGS vs Gross Profit by Category' AS Title,
    'Based on recipe cost' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value
```

---

### 4.2 InvConsumption (Usage & Consumption Tracking)

**Category:** Inventory | **Fact:** F_INV_USAGE_DAY | **Prerequisite:** None | **Addresses:** C2, C5

#### 4.2.1 BarChartCard

| Field | Value |
|---|---|
| DataSetName | `InvConsumption` |
| VisualizationType | `BarChartCard` |
| FilterDefinitions | `GROWYZE_FILTER_INVITEM` |

**QueryTemplate:**
```sql
SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarLabelSort,
    TOTAL_USAGE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS TOTAL_USAGE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_USAGE DESC
) SUB

SELECT 'Item' AS XAxisLabel, 'Consumption Quantity' AS YAxisLabel,
    'Top 20 Items by Consumption' AS Title,
    'Volume-based ranking (units consumed via sales)' AS Description,
    NULL AS Trend, NULL AS TotalValue, NULL AS Chip
```

#### 4.2.2 CustomDataGrid

| Field | Value |
|---|---|
| DataSetName | `InvConsumption` |
| VisualizationType | `CustomDataGrid` |
| FilterDefinitions | `GROWYZE_FILTER_INVITEM` |

**QueryTemplate:** Columns: Location (1), Category (2), Subcategory (3), Item (4), Sales Qty (5), Waste Qty (6), Order Qty (7), Production Qty (8), Transfer Qty (9), UOM (10). Column11-29 = NULL.

**Header:** Title = "Consumption Detail", Description = "Volume-based consumption tracking by item". Labels: Location/TEXT, Category/TEXT, Subcategory/TEXT, Item/TEXT, Sales Qty/DECIMAL, Waste Qty/DECIMAL, Order Qty/DECIMAL, Production Qty/DECIMAL, Transfer Qty/DECIMAL, UOM/TEXT.

---

### 4.3 InvWasteAnalysis (Waste Breakdown)

**Category:** Inventory | **Fact:** F_INV_USAGE_DAY | **Prerequisite:** None | **Addresses:** C2, C7, C8

#### 4.3.1 BarChartCard — Top 20 Items by Waste

Same pattern as InvConsumption BarChartCard but using `WASTE_QTY` instead of `SALE_QTY`, filtered to `ISNULL(FU.[WASTE_QTY],0) != 0`. Header TotalValue = sum of all waste.

#### 4.3.2 MultiLineChartCard — Weekly Waste Trend by Category

Weekly aggregation by `D_INVITEM.TOP_NAME`. Each category = one line. CROSS APPLY VALUES unpivot pattern. X-axis = week label, Y-axis = waste quantity.

#### 4.3.3 CustomDataGrid — Waste Detail

Columns: Location (1), Category (2), Item (3), Waste Qty (4), UOM (5). Filtered to waste > 0.

---

### 4.4 ProductComparison (Side-by-Side Product Comparison)

**Category:** Products | **Fact:** F_PRODUCT_MARGIN_DAY | **Prerequisite:** P1 | **Addresses:** C3

#### 4.4.1 CustomDataGrid

| Field | Value |
|---|---|
| DataSetName | `ProductComparison` |
| VisualizationType | `CustomDataGrid` |
| FilterDefinitions | `GROWYZE_FILTER_PRODUCT` |

**Columns:** Location (1), Category (2), Subcategory (3), Product (4), Qty Sold (5), Revenue (6), COGS (7), Profit (8), GP% (9), Menu Price (10), Recipe Cost (11).

GP% = `CASE WHEN SUM(NET_VALUE) = 0 THEN 0 ELSE ROUND(SUM(PROFIT) / SUM(NET_VALUE) * 100, 1) END`.

**Header:** Title = "Product Comparison", Description = "Side-by-side product performance. COGS based on recipe cost."

---

### 4.5 InvMarginTrend (Profit Margin Over Time)

**Category:** Inventory | **Fact:** F_PRODUCT_MARGIN_DAY | **Prerequisite:** P1 | **Addresses:** C6

#### 4.5.1 MultiLineChartCard

| Field | Value |
|---|---|
| DataSetName | `InvMarginTrend` |
| VisualizationType | `MultiLineChartCard` |
| FilterDefinitions | `GROWYZE_FILTER_PRODUCT` |

**QueryTemplate:** CTE aggregates monthly using `C.[Year] * 100 + C.[Month]`. Two lines via UNION ALL: GP% (VisId=1) and COGS% (VisId=2). MonthName + Year label for X-axis.

**Header:** Title = "Margin Trend", Description = "Monthly GP% and COGS% over time. Based on recipe cost."

---

### 4.6 InvMargeBrut (Gross Margin Summary) — REDESIGNED

**Category:** Inventory | **Facts:** F_INV_USAGE_DAY (primary) + F_PRODUCT_MARGIN_DAY (location-level CTE) | **Prerequisite:** P1 | **Addresses:** C8, C1

**Original problem:** Cross-fact join between PRODUCT grain and INVITEM grain has no presentation-layer bridge.

**Redesign:** Two independent CTEs joined only at LOCATION_HUB_ID level:
- `Revenue` CTE: F_PRODUCT_MARGIN_DAY aggregated to location (Turnover, Recipe COGS, GP%)
- `Usage` CTE: F_INV_USAGE_DAY by invitem category within location (Purchases, Consumption, Waste volumes)

#### 4.6.1 CustomGroupedDataGrid

| Field | Value |
|---|---|
| DataSetName | `InvMargeBrut` |
| VisualizationType | `CustomGroupedDataGrid` |
| FilterDefinitions | `GROWYZE_FILTER_INVITEM` |

**Two-level hierarchy:**
- **Child rows** (per category within location): Purchases Qty, Consumption Qty, Waste Qty
- **Parent rows** (per location): + Turnover, Recipe COGS, GP% from Revenue CTE

`@FilterClause` appears in both CTEs for consistent filtering.

**Header:** Title = "Gross Margin Summary", Description = "Turnover and recipe COGS at location level; purchase/waste/consumption volumes by category. Based on recipe cost."

---

### 4.7 InvWeeklySummary (Weekly Sales & Costs)

**Category:** Inventory | **Fact:** F_PRODUCT_MARGIN_DAY | **Prerequisite:** P1 | **Addresses:** C8

#### 4.7.1 CombinedChartCard

| Field | Value |
|---|---|
| DataSetName | `InvWeeklySummary` |
| VisualizationType | `CombinedChartCard` |
| FilterDefinitions | `GROWYZE_FILTER_PRODUCT` |

**QueryTemplate:** CTE aggregates by `C.[Year] * 100 + C.[Week]`. Three series via UNION ALL: Revenue (bar, VisId=1), Recipe COGS (bar, VisId=2), GP% (line, VisId=3).

**Header:** Title = "Weekly Sales & Costs", Description = "Revenue and recipe COGS by week with GP% trend. Based on recipe cost."

#### 4.7.2 CustomDataGrid

Columns: Week (1), Location (2), Qty Sold (3), Revenue (4), Recipe COGS (5), Profit (6), GP% (7).

**Header:** Title = "Weekly Summary", Description = "Weekly sales and costs by location. Based on recipe cost."

---

### 4.8 InvStockActivity (Stock Activity by Period & Category)

**Category:** Inventory | **Fact:** F_INV_USAGE_DAY | **Prerequisite:** None | **Addresses:** C1

*Renamed from "InvStockValue" — UOM_COST is NULL so no monetary valuation.*

#### 4.8.1 StackedBarChartCard — by Location

Three UNION ALL segments: Orders In (`ORDER_QTY`), Sales Out (`ABS(SALE_QTY)`), Waste (`ABS(WASTE_QTY)`). Grouped by location. Separate Stack groups (A, B, C) for side-by-side bars.

**Header:** Title = "Stock Activity by Location", Description = "Volume-based: orders in, sales out, waste by location."

#### 4.8.2 MultiLineChartCard — Weekly Trend

Three lines (Orders In, Sales Out, Waste) aggregated weekly. Same pattern as InvMarginTrend but with F_INV_USAGE_DAY columns.

**Header:** Title = "Stock Activity Trend", Description = "Weekly volume trend: orders, sales, waste."

---

### Phase 1 Summary

| # | DataSetName | VisualizationType | Fact Table | Records |
|---|---|---|---|---|
| 1a | InvCOGSByCategory | PieChartCard | F_PRODUCT_MARGIN_DAY | 1 |
| 1b | InvCOGSByCategory | StackedBarChartCard | F_PRODUCT_MARGIN_DAY | 1 |
| 2a | InvConsumption | BarChartCard | F_INV_USAGE_DAY | 1 |
| 2b | InvConsumption | CustomDataGrid | F_INV_USAGE_DAY | 1 |
| 3a | InvWasteAnalysis | BarChartCard | F_INV_USAGE_DAY | 1 |
| 3b | InvWasteAnalysis | MultiLineChartCard | F_INV_USAGE_DAY | 1 |
| 3c | InvWasteAnalysis | CustomDataGrid | F_INV_USAGE_DAY | 1 |
| 4 | ProductComparison | CustomDataGrid | F_PRODUCT_MARGIN_DAY | 1 |
| 5 | InvMarginTrend | MultiLineChartCard | F_PRODUCT_MARGIN_DAY | 1 |
| 6 | InvMargeBrut | CustomGroupedDataGrid | F_INV_USAGE_DAY + F_PRODUCT_MARGIN_DAY | 1 |
| 7a | InvWeeklySummary | CombinedChartCard | F_PRODUCT_MARGIN_DAY | 1 |
| 7b | InvWeeklySummary | CustomDataGrid | F_PRODUCT_MARGIN_DAY | 1 |
| 8a | InvStockActivity | StackedBarChartCard | F_INV_USAGE_DAY | 1 |
| 8b | InvStockActivity | MultiLineChartCard | F_INV_USAGE_DAY | 1 |
| | | | **Phase 1 total:** | **14** |

**Dependency split:** 7 records (datasets 1, 4, 5, 6-revenue, 7) require P1. The other 7 (datasets 2, 3, 8) work immediately via F_INV_USAGE_DAY.

---

## 5. Phase 2 — Visualisation Query Specifications

### 5.1 Dataset 9: SalesByDayOfWeek — BLOCKED

**Status:** BLOCKED — cannot be built for Growyze organisations.

**Reason:** Requires intra-day `LINEITEM_TIMESTAMP` for the day-of-week x hour-of-day heatmap. Growyze LINEITEM entity mapping does not include `LINEITEM_TIMESTAMP`. Source `DL_DISHES.createdDate` may be date-only.

**Unblocking path:** Growyze needs a timestamp-precision field on sales transactions. Once available: update staging, entity mapping, re-run DV load, deploy the held vis query.

**Held specification:**

| Field | Value |
|---|---|
| DataSetName | `SalesByDayOfWeek` |
| VisualizationType | `HeatmapCard` |
| Fact | F_LINEITEM_15MIN |
| X-axis | `C.DayName` (Mon-Sun) |
| Y-axis | `DATEPART(HOUR, LINEITEM_TIMESTAMP)` (0-23) |
| Measure | `SUM(NET_VALUE)` per cell |
| Records | 1 (held) |

---

### 5.2 Dataset 10: InvPeriodComp (Period-to-Period Comparison)

**Status:** Phase 2 — ready to build. **Addresses:** C5, C6 (2 customers).

**Design:** Three separate CombinedChartCard records (one per period grain) rather than a single parameterised query. Follows the `NetSalesByHour` UNION ALL pattern with date-shifted joins.

| DataSetName | Period Join | Header Title |
|---|---|---|
| `InvPeriodCompWoW` | `C.SameDayLastWeek` | Revenue: Week over Week |
| `InvPeriodCompMoM` | `DATEADD(MONTH, -1, C.Date)` | Revenue: Month over Month |
| `InvPeriodCompYoY` | `C.SameDayLastYear` | Revenue: Year over Year |

Each record has two series: Current (bar, VisId=1) and Prior Period (line, VisId=2). Measures: `ROUND(SUM(NET_VALUE), 2)`. Prior period X-axis labels are date-shifted to align with current.

**Cost labeling:** All three include "Based on recipe cost" in Description.

**Note on MoM:** CALENDAR lacks `SameDayLastMonth`. Uses `DATEADD(MONTH, -1, C.Date)` inline.

**Query records: 3.**

---

### 5.3 Dataset 11: InvVarianceCategory (Variance by Inventory Category)

**Status:** Phase 2 — build for MarketMan. Auto-activates for Growyze when COUNT events arrive.

| Field | Value |
|---|---|
| DataSetName | `InvVarianceCategory` |
| VisualizationType | `StackedBarChartCard` |
| Fact | F_INV_USAGE_DAY LEFT JOIN F_INV_COUNTS_DAY (via Counts CTE) |
| X-axis | `COALESCE(invitem.TOP_MICROSERVICE_NAME, invitem.TOP_NAME)` |
| Stacks | Positive Variance (A), Negative Variance (B) |
| Measures | `SUM(VARIANCE * UOM_COST)` split by sign |

Follows the `InvVariances` query structure but groups by inventory category instead of location.

**Growyze behaviour:** Returns zero rows (no COUNT events). Acceptable.

**Query records: 1.**

---

### 5.4 Dataset 12: InvTheoVsActualGP (Theoretical vs Actual GP%)

**Status:** Phase 2 — build now. Growyze gets partial output (Recipe GP% only).

| Field | Value |
|---|---|
| DataSetName | `InvTheoVsActualGP` |
| VisualizationType | `CombinedChartCard` |
| Facts | F_INV_SALES_DAY + F_INV_COUNTS_DAY + F_INV_USAGE_DAY |
| X-axis | Monthly period |
| Series 1 | VisId=1, bar, "Recipe GP%" — fully available |
| Series 2 | VisId=2, line, "Actual GP%" — NULL for Growyze (needs COUNT) |

**Important:** Verify F_INV_SALES_DAY date column name (`INV_DATE` per DDL vs `REPORTING_DATE` in existing queries) before implementation. See Risk R8.

**Header:** Description = "Recipe GP% based on recipe cost. Actual GP% requires stock count data."

**Query records: 1.**

---

### Phase 2 Summary

| # | DataSetName | Card Types | Records | Status |
|---|---|---|---|---|
| 9 | SalesByDayOfWeek | HeatmapCard | 1 (held) | BLOCKED |
| 10 | InvPeriodCompWoW/MoM/YoY | CombinedChartCard x3 | 3 | Ready |
| 11 | InvVarianceCategory | StackedBarChartCard | 1 | Ready (MarketMan) |
| 12 | InvTheoVsActualGP | CombinedChartCard | 1 | Ready (partial for Growyze) |
| | **Phase 2 deployable** | | **5** | |

---

## 6. Risk Register

| ID | Risk | Severity | Impact | Mitigation |
|---|---|---|---|---|
| R1 | **Growyze integration stability** | **HIGH** | Staging fixes not yet re-deployed. Data may be incorrect (wrong LINEITEM_TYPE, EVENT_TYPE). Vis queries on bad data show wrong results. | **Gate:** Re-deploy 02+03, run clean presentation build, verify via DQ queries before any vis development. |
| R2 | **AVG_NET_COST verification** | **HIGH** | 6 of 8 Phase 1 datasets use AVG_NET_COST. If NULL/zero for Growyze, all cost-based measures are meaningless. | **Gate:** DQ-1 + DQ-3 must pass before building recipe-cost queries. |
| R3 | **Recipe cost != actual COGS** | **MEDIUM** | 3-8% GP variance between recipe and actual purchase cost. Customers may make commercial decisions on inaccurate margins. | **Mandatory:** "Based on recipe cost" in every affected query's header Description. Account team briefing before launch. |
| R4 | **Sentinel dimension joins** | **MEDIUM** | Growyze has no occasion/channel/employee data. Sentinel values in fact tables. Queries grouping by sentinel dimensions produce a single "Unknown" bucket. | **Design rule:** Never GROUP BY sentinel dimensions. FilterDefinitions leave sentinel-dimension columns empty. |
| R5 | **InvMargeBrut cross-fact complexity** | **MEDIUM** | Redesigned to join at LOCATION level only. Revenue cannot be attributed to invitem categories. | **Accepted:** Parent rows show revenue; child rows show volumes. Clear header labeling. |
| R6 | **Customer expectation management** | **MEDIUM** | 4 PARTIAL reports show volume only, not cost. "Stock Activity" instead of "Stock Value". | **Process:** Account team briefing. Subtitles on partial cards: "Showing quantities — cost valuation available after UOM_COST enrichment." |
| R7 | **Maintenance burden** | **LOW** | +18% vis query catalog (109 → 128). Each needs testing after schema changes. | **Mitigation:** Consistent naming (Inv* prefix). Reusable filter templates. Document all in `docs/presentation-and-visualisation.md`. |
| R8 | **F_INV_SALES_DAY column discrepancy** | **LOW** | DDL says `INV_DATE`, existing queries use `REPORTING_DATE`. | **Action:** Verify via MCP before writing any F_INV_SALES_DAY query. |
| R9 | **UOM_COST enrichment CTE UOM mismatch** | **MEDIUM** | F_PURCHASES_DAY.UNIT_PRICE is per purchase unit (may be kg/case); F_INV_USAGE_DAY expects cost per standardised UOM (g/ml). LatestPurchasePrice CTE doesn't apply conversion. | **Action:** Add UOM conversion join to the enrichment CTE when implementing Step 5. |

---

## 7. Implementation Roadmap

### Ordered Steps

```
Step 0  Re-deploy Growyze staging fixes (02 + 03)
        Prerequisite: None
        Delivers: Clean staging data, correct LINEITEM_TYPE + EVENT_TYPE values

Step 1  Presentation layer verification
        Prerequisite: Step 0
        Actions: Run full presentation build for GrowyzeDev, then DQ-1 through DQ-5
        Delivers: Validated data foundation; go/no-go decision

Step 2  PresentationControl filter fix (P1)
        Prerequisite: Step 1 (confirms data flows correctly)
        Delivers: F_PRODUCT_MARGIN_DAY + F_LINEITEM_15MIN include Growyze rows

Step 3  Phase 1 vis queries — 8 datasets, 14 query records
        Prerequisite: Steps 1 + 2
        Script: Single deployment SQL using MERGE upsert pattern
        Delivers: 14 vis query records (7 work immediately; 7 after P1 rebuild)

Step 4  Deploy F_PURCHASES_DAY prerequisites (parallel with Steps 2-3)
        Prerequisite: Step 1
        Deploy order: 05 (entity fix) -> 06 (table DDL) -> 07 (build step)
        Delivers: New fact table with per-item purchase pricing

Step 5  UOM_COST enrichment
        Prerequisite: Step 4
        Action: Modify F_INV_USAGE_DAY/F_INV_COUNTS_DAY build steps to derive
                UOM_COST from latest purchase price when SAT_INVREPORT cost is NULL
        Delivers: Non-NULL UOM_COST for Growyze; upgrades 4 PARTIAL datasets

Step 6  Phase 2 vis queries — 3 datasets, 5 query records
        Prerequisite: Steps 3 + 5
        Script: Single deployment SQL using MERGE upsert pattern
        Delivers: InvPeriodCompWoW/MoM/YoY, InvVarianceCategory, InvTheoVsActualGP

Step 7  LINEITEM_TIMESTAMP mapping fix (future)
        Prerequisite: Growyze API provides timestamp-precision sales data
        Delivers: SalesByDayOfWeek HeatmapCard (1 query record)
```

### Dependency Diagram

```
Step 0 ──────┐
             v
Step 1 ──────┬──────────────────┐
             |                  |
             v                  v
Step 2       Step 4
             |                  |
             v                  v
Step 3       Step 5
             |                  |
             └────────┬─────────┘
                      v
                   Step 6


Step 7 <-- External dependency (Growyze API timestamp)
           Independent of Steps 0-6
```

**Critical path:** Steps 0 -> 1 -> 2 -> 3 (Phase 1 delivery).
**Parallel path:** Steps 1 -> 4 -> 5 can run concurrently with Steps 2 -> 3.

### Estimated Effort

| Step | Effort | Notes |
|---|---|---|
| 0 | 15 min | Script re-deploy + staging re-run |
| 1 | 30 min | MCP verification queries |
| 2 | 30 min | Single PresentationControl MERGE script |
| 3 | 3-4 hrs | 14 query records, test each via MCP |
| 4 | 30 min | Three script deploys |
| 5 | 1-2 hrs | PresentationControl modification + test |
| 6 | 1-2 hrs | 5 query records, test each via MCP |
| 7 | TBD | Blocked on external API |

---

## 8. Appendix — Corrected Record Counts

The original analysis claimed "12 datasets (22 vis query records)". The corrected count is **19 deployable + 1 held = 20 specified records**.

| # | DataSetName | Card Types | Records | Phase |
|---|---|---|---|---|
| 1 | InvCOGSByCategory | PieChartCard, StackedBarChartCard | 2 | 1 |
| 2 | InvConsumption | BarChartCard, CustomDataGrid | 2 | 1 |
| 3 | InvWasteAnalysis | BarChartCard, MultiLineChartCard, CustomDataGrid | 3 | 1 |
| 4 | ProductComparison | CustomDataGrid | 1 | 1 |
| 5 | InvMarginTrend | MultiLineChartCard | 1 | 1 |
| 6 | InvMargeBrut | CustomGroupedDataGrid | 1 | 1 |
| 7 | InvWeeklySummary | CombinedChartCard, CustomDataGrid | 2 | 1 |
| 8 | InvStockActivity | StackedBarChartCard, MultiLineChartCard | 2 | 1 |
| | **Phase 1 subtotal** | | **14** | |
| 9 | SalesByDayOfWeek | HeatmapCard | 1 (held) | BLOCKED |
| 10 | InvPeriodComp (WoW/MoM/YoY) | CombinedChartCard x3 | 3 | 2 |
| 11 | InvVarianceCategory | StackedBarChartCard | 1 | 2 |
| 12 | InvTheoVsActualGP | CombinedChartCard | 1 | 2 |
| | **Phase 2 deployable** | | **5** | |
| | **Phase 2 held** | | **1** | |
| | **Grand total (deployable)** | | **19** | |
| | **Grand total (all specified)** | | **20** | |

### Reconciliation

Original claim: 15 (Phase 1) + 7 (Phase 2) = 22. Changes:
- InvMargeBrut reduced from 2 to 1 record (redesigned as single CustomGroupedDataGrid): **-1**
- SalesByDayOfWeek moved to BLOCKED (held): **-1**
- InvPeriodComp split into 3 records (WoW/MoM/YoY): **+2**
- Other Phase 2 adjustments: **-2**
- **Net: 22 - 3 = 19 deployable + 1 held = 20 total**
