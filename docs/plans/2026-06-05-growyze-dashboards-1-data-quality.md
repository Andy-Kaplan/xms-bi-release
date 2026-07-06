# Growyze Dashboards — Plan 1: Data Quality & Enablement

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Growyze sales/margin/inventory facts trustworthy and complete enough to back Kati's default dashboard pack — fix the two upstream data-quality bugs, enable time-of-day, and deploy the deliveries fact to Padel — so that Plan 2 (cards) and Plan 3 (Report DB wiring) build on solid data.

**Architecture:** XMS BI Managed Instance. Growyze (`int_growyze001`) staging + entity mappings live in the **core** database under the integration schema; presentation build steps live in `core.core.PresentationControl`; vis queries in `core.core.VisualisationQueries`. Changes are control-table edits that propagate at the next staging → DV load → presentation rebuild per org. We author every change as an idempotent script in `ClaudeDevelopment/integrations/Growyze/`, then (release-prep step) copy it into `releases/v1.1/` and sync the master integration files in the same commit, per `docs/release-guide.md`.

**Tech Stack:** T-SQL, MERGE/UPDATE upserts, `CAST(... AS NVARCHAR(MAX))` for TEXT control columns, MCP read-only verification (`mcp__xms-bi-uat__query`, `database="core"`, three-part naming, comments stripped).

---

## Ground Truth (verified live on UAT, 2026-06-05 — supersedes the 2026-05-20 plan)

- **Growyze sales ALREADY populate** `F_LINEITEM_15MIN` and `F_PRODUCT_MARGIN_DAY` (the old "P1 filter widening" is void — the `IntegrationType` filter is commented out). Net sales: Padel £184k, Dirty £448k.
- **Product cost is `F_PRODUCT_MARGIN_DAY.AVG_NET_COST`** (and `PROFIT`). `D_PRODUCT.BOTTOM_NET_COST` **does not exist** — never reference it.
- **`F_INV_SALES_DAY` / `F_INV_COUNTS_DAY` cost is inflated 16–113×** (UOM_COST = whole-pack price multiplied by sub-unit quantity). The two `OakVine*` cost KPIs that read it return garbage.
- **`LINEITEM_TIMESTAMP` is 100% NULL** for Growyze (source only has sale-window `OPEN_TIME`). The 15-min bucket collapses → all time-of-day cards are dead.
- **D_PRODUCT category fall-through (~5%)**: blank `DL_DISHES.category` → product name leaks into MIDDLE_1/TOP.
- **F_PURCHASES_DAY** exists on **Dirty Sixth** but **not Padel**.

### Target orgs (UAT)
- Padel Social — `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`
- Dirty Sixth — `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A`

### Verified table columns (use these exact names)
- `F_PRODUCT_MARGIN_DAY`: PRODUCT_HUB_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, REVCENTER_HUB_ID, CHANNEL_HUB_ID, DEAL_HUB_ID, DISCOUNT_HUB_ID, ORDER_DATE, DEAL_FLAG, **NET_VALUE, QUANTITY, AVG_NET_COST, AVG_NET_PRICE_CHARGED, AVG_NET_PRICE, PROFIT, PROFIT_LESS_DISCOUNT**.
- `F_LINEITEM_15MIN`: SRC, LI_TYPE, PRODUCT_HUB_ID, LOCATION_HUB_ID (+ other hub ids), GROSS_VALUE, TAX_VALUE, NET_VALUE, ORDER_COUNT, QUANTITY, QUANTITY_INV, **LINEITEM_TIMESTAMP**, ORDER_DATE.
- `D_PRODUCT`: BOTTOM_HUB_ID, **BOTTOM_PRODUCT_NAME**, BOTTOM_MICROSERVICE_NAME, BOTTOM_LEVEL_NAME, **MIDDLE_1_NAME**, MIDDLE_1_MICROSERVICE_NAME, **TOP_NAME**, TOP_MICROSERVICE_NAME, TOTAL_LEVELS, HIERARCHY_PATH.
- `D_LOCATION`: BOTTOM_HUB_ID, **BOTTOM_LOCATION_NAME**, BOTTOM_MICROSERVICE_NAME, **BOTTOM_LEVEL_NAME**.
- `F_INV_COUNTS_DAY`: LOCATION_HUB_ID, INVITEM_HUB_ID, COUNT_DATE, ACTUAL_COUNT, UOM_COST, THEO_QTY, … (no ON_HAND_VALUE — value = ACTUAL_COUNT × UOM_COST).

### MCP verification recipe
Run from `database="core"`, strip comments, three-part-name client tables, e.g.:
`[20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT]`. For vis templates: replace `@FilterClause` with empty string and drop any trailing header SELECT.

---

## Design Principles (apply throughout this program)

1. **Never mutate shared `OakVine*` datasets.** The cost KPIs and FoodDrinksSplit are shared with non-Growyze orgs (e.g. The Oak & Vine). Create **Growyze-scoped** dataset names (`Growyze*`) and wire only those to the Growyze pack — zero regression risk elsewhere.
2. **All cost/GP sources from `F_PRODUCT_MARGIN_DAY`**, never `F_INV_SALES_DAY` (inflated) and never `D_PRODUCT.BOTTOM_NET_COST` (nonexistent).
3. **Guard comp lines:** add `AND F.NET_VALUE > 0` to GP/profit aggregations (excludes the ~18–22 % £0 lines).
4. **Idempotent + master-synced:** every delta is re-runnable (MERGE / keyed UPDATE / IF NOT EXISTS); the master integration file is updated in the same commit.

---

## Release & File Structure

This program ships as **release `v1.1`** (delta folder `releases/v1.1/`). Plan 1 contributes the scripts below; Plans 2 and 3 add more to the same folder.

| Authored file (ClaudeDevelopment) | Release copy | Master file to sync |
|---|---|---|
| `integrations/Growyze/17_product_category_sentinel.sql` | `releases/v1.1/01_growyze_product_category_sentinel.sql` | `integrations/Growyze/02_staging_tier1.sql` (GRYZ_PRODUCT step) |
| `integrations/Growyze/reporting_queries/39_growyze_cost_kpis.sql` | `releases/v1.1/02_growyze_cost_kpis.sql` | `8_VisualisationQueries.sql` |
| `integrations/Growyze/reporting_queries/40_growyze_sales_by_category.sql` | `releases/v1.1/03_growyze_sales_by_category.sql` | `8_VisualisationQueries.sql` |
| `integrations/Growyze/18_lineitem_timestamp_mapping.sql` | `releases/v1.1/04_growyze_lineitem_timestamp.sql` | `integrations/Growyze/02_staging_tier1.sql` + `04_entity_mappings.sql` |
| (Phase 2 — investigation-gated, see Task 5) | `releases/v1.1/05_growyze_invitem_unit_cost.sql` *(may defer to v1.2)* | `integrations/Growyze/02_staging_tier1.sql` |
| promote `05_invitem_stockorder_entity_fix.sql` | `releases/v1.1/06_invitem_stockorder_entity.sql` | `8_DataVaultEntities.sql` |
| promote `06_purchases_presentation_table.sql` | `releases/v1.1/07_f_purchases_day_table.sql` | `8_PresentationTables.sql` |
| promote `07_purchases_presentation_control.sql` | `releases/v1.1/08_f_purchases_day_build.sql` | `8_PresentationControl.sql` |
| new per-org wrapper | `releases/v1.1/09_per_org_purchases_padel.sql` | — |

> **CLAUDE.md note:** Claude authors only under `ClaudeDevelopment/`. Copying to `releases/` and editing master files are the *release-preparation* step sanctioned by `docs/release-guide.md` §10; do them together in the release commit, not during development.

---

## Self-Contained Test Pattern

Each task ends with **MCP read-only verification** (no unit tests in this stack). Deploys (writes) are executed by the developer — Claude never runs writes via MCP. Where a task needs a presentation rebuild to take effect, the verification is "after the next staging → DV load → presentation rebuild for the org".

---

## Phase 1 — Make existing cards trustworthy

### Task 1: Fix D_PRODUCT category fall-through (Growyze staging sentinel)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/17_product_category_sentinel.sql`
- Release copy: `releases/v1.1/01_growyze_product_category_sentinel.sql`
- Master sync: `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql`

**Root cause:** the `GRYZ_PRODUCT` staging step sets `category AS PARENT_ID` for products and seeds category rows only `WHERE category IS NOT NULL`. Blank `DL_DISHES.category` → `PARENT_ID = NULL` → the D_PRODUCT recursive flatten falls back to the product's own name for MIDDLE_1/TOP. Fix: COALESCE blank category to a `'Uncategorised'` sentinel in **both** halves so every product resolves to a real category row.

- [ ] **Step 1 — Confirm current fall-through count (baseline)**

```sql
SELECT COUNT(*) AS fallthrough_products
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = 'Product' AND TOP_NAME = BOTTOM_PRODUCT_NAME
```
Expected (before fix): ~108 (Padel). Record it.

- [ ] **Step 2 — Write the delta script**

`17_product_category_sentinel.sql` — wholesale, idempotent UPDATE of the staging step (avoids fragile REPLACE anchors; re-running sets the same value):

```sql
-- Growyze GRYZ_PRODUCT category sentinel: blank DL_DISHES.category -> 'Uncategorised'
-- so no product falls through the D_PRODUCT hierarchy flatten to its own name.
-- See docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md Task 1
UPDATE [core].[int_growyze001].[StagingControl]
SET updated_at = GETDATE(),
    query_sql = N'IF OBJECT_ID(''stage.GRYZ_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PRODUCT];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
),
base AS (SELECT * FROM deduped WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_PRODUCT]
FROM (
    SELECT
        id AS HUB_ID,
        name AS PRODUCT_NAME,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS PARENT_ID,
        ''Product'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        id AS PRODUCT_ID,
        posId AS ATTR_1,
        barcode AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        id AS MICROSERVICE_ID,
        organizations AS LOCATION_KEY,
        ''-999'' AS OCC_ID,
        salePrice AS NET_PRICE,
        totalCost AS NET_COST
    FROM base
    UNION ALL
    SELECT DISTINCT
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS HUB_ID,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS PRODUCT_NAME,
        NULL AS PARENT_ID,
        ''Category'' AS LEVEL_NAME,
        0 AS BOTTOM_LEVEL,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS PRODUCT_ID,
        NULL AS ATTR_1,
        NULL AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS MICROSERVICE_ID,
        NULL AS LOCATION_KEY,
        NULL AS OCC_ID,
        NULL AS NET_PRICE,
        NULL AS NET_COST
    FROM base
) AS source_query;'
WHERE staging_table = N'GRYZ_PRODUCT' AND step_name = N'Growyze Product';

IF @@ROWCOUNT <> 1
    RAISERROR(N'Task1 abort: expected exactly 1 GRYZ_PRODUCT staging row updated.', 16, 1);
PRINT 'Task 1: GRYZ_PRODUCT category sentinel applied.';
```

- [ ] **Step 3 — Deploy to UAT** (developer runs script against `core`), then run **Growyze staging → DV load → presentation rebuild** for Padel Social and Dirty Sixth.

- [ ] **Step 4 — Verify fall-through eliminated**

```sql
SELECT COUNT(*) AS fallthrough_products
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = 'Product' AND TOP_NAME = BOTTOM_PRODUCT_NAME;

SELECT TOP_NAME, COUNT(*) AS products
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = 'Product'
GROUP BY TOP_NAME ORDER BY products DESC;
```
Expected: fall-through ≈ 0; distinct TOP_NAME = {Beverages, Retail, Food, Other, Uncategorised} (Padel) / {Beverages, Food, Other, Uncategorised} (Dirty). No product names in the list.

- [ ] **Step 5 — Sync master + commit**

Update the GRYZ_PRODUCT block in `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql` to match, copy the script to `releases/v1.1/01_growyze_product_category_sentinel.sql`.

```bash
git add "ClaudeDevelopment/integrations/Growyze/17_product_category_sentinel.sql" "releases/v1.1/01_growyze_product_category_sentinel.sql" "ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql"
git commit -m "fix(growyze): sentinel blank product category to stop D_PRODUCT hierarchy fall-through"
```

---

### Task 2: Growyze-scoped cost / profit KPIs (replace the garbage OakVine cost cards)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/39_growyze_cost_kpis.sql`
- Release copy: `releases/v1.1/02_growyze_cost_kpis.sql`
- Master sync: `8_VisualisationQueries.sql`

Creates two new **Growyze-scoped** SingleKPICard datasets sourced from the healthy `F_PRODUCT_MARGIN_DAY`. The shared `OakVineCostGrossMargin` / `OakVineCostFoodCostPct` are left untouched (they read the inflated `F_INV_SALES_DAY`; their proper fix is Task 5).

- [ ] **Step 1 — Confirm PROFIT semantics before authoring**

```sql
SELECT
  SUM(PROFIT)                                    AS sum_profit,
  SUM(NET_VALUE) - SUM(QUANTITY * AVG_NET_COST)  AS computed_margin,
  SUM(NET_VALUE)                                 AS sum_net_value
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY]
WHERE NET_VALUE > 0;
```
Expected: `sum_profit` ≈ `computed_margin` (confirms `PROFIT` is row-level margin). If they diverge materially, use the explicit `SUM(NET_VALUE) - SUM(QUANTITY*AVG_NET_COST)` form in the templates below instead of `SUM(PROFIT)`.

- [ ] **Step 2 — Fetch FilterDefinitions to reuse**

```sql
SELECT DataSetName, FilterDefinitions
FROM core.core.VisualisationQueries
WHERE DataSetName IN ('ProductComparison','OakVineMarginByCategory') AND Status='LIVE';
```
Use the `ProductComparison` FilterDefinitions (it filters `F_PRODUCT_MARGIN_DAY` + `D_LOCATION` + `D_PRODUCT` on the same aliases) as the template for the two new cards — it gives Period/Venue/Category filter binding consistent with the rest of the pack.

- [ ] **Step 3 — Write the delta script** (`39_growyze_cost_kpis.sql`). Substitute the FilterDefinitions JSON captured in Step 2 into the `FilterDefinitions` column of each MERGE.

```sql
-- Growyze-scoped Profit / Profit% KPIs off the healthy F_PRODUCT_MARGIN_DAY.
-- See docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md Task 2

MERGE INTO core.core.VisualisationQueries AS tgt
USING (VALUES (N'GrowyzeProfit', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    N''Profit'' AS Title,
    N''£'' + FORMAT(SUM(F.PROFIT), ''N0'') AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    FilterDefinitions = N'<<ProductComparison FilterDefinitions from Step 2>>',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeProfit', N'SingleKPICard', 1, N'LIVE',
    N'SELECT
    N''Profit'' AS Title,
    N''£'' + FORMAT(SUM(F.PROFIT), ''N0'') AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    N'<<ProductComparison FilterDefinitions from Step 2>>', GETDATE(), N'plan-2026-06-05');

MERGE INTO core.core.VisualisationQueries AS tgt
USING (VALUES (N'GrowyzeProfitPct', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    N''Profit %'' AS Title,
    FORMAT(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0), ''N1'') + N''%'' AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    FilterDefinitions = N'<<ProductComparison FilterDefinitions from Step 2>>',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeProfitPct', N'SingleKPICard', 1, N'LIVE',
    N'SELECT
    N''Profit %'' AS Title,
    FORMAT(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0), ''N1'') + N''%'' AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    N'<<ProductComparison FilterDefinitions from Step 2>>', GETDATE(), N'plan-2026-06-05');

PRINT 'Task 2: GrowyzeProfit + GrowyzeProfitPct deployed.';
```

- [ ] **Step 4 — Deploy + MCP test each template** (strip comments, `@FilterClause`→empty, prefix tables with Padel DB):

```sql
SELECT N'Profit' AS Title, N'£' + FORMAT(SUM(F.PROFIT), 'N0') AS Value
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0 AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown';
```
Expected: one row, a sensible positive £ profit and a plausible Profit % (roughly 40–80%), NOT −£1.6M / 1,469%. Repeat for Dirty Sixth.

- [ ] **Step 5 — Sync master + commit**

Add both records to `8_VisualisationQueries.sql`; copy script to `releases/v1.1/02_growyze_cost_kpis.sql`.

```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/39_growyze_cost_kpis.sql" "releases/v1.1/02_growyze_cost_kpis.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeProfit/GrowyzeProfitPct KPIs off F_PRODUCT_MARGIN_DAY (replace garbage OakVine cost cards)"
```

---

### Task 3: Growyze-scoped "Sales by Category" pie (replace FoodDrinksSplit)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/40_growyze_sales_by_category.sql`
- Release copy: `releases/v1.1/03_growyze_sales_by_category.sql`
- Master sync: `8_VisualisationQueries.sql`

`OakVineMenuFoodDrinksSplit` hardcodes `TOP_NAME IN ('Food','Drinks')` — Growyze has no "Drinks" category → 1-slice pie. New Growyze-scoped `GrowyzeSalesByCategory` groups on the real category set. Depends on Task 1 (clean categories).

- [ ] **Step 1 — Mirror the PieChartCard output contract**

```sql
SELECT CAST(QueryTemplate AS NVARCHAR(MAX)) AS q, OutputDefinitions, FilterDefinitions
FROM core.core.VisualisationQueries
WHERE DataSetName='OakVineMenuFoodDrinksSplit' AND VisualizationType='PieChartCard' AND Status='LIVE';
```
Note the exact output column aliases (e.g. label/value column names) and reuse them so the card renders identically; capture its FilterDefinitions to reuse (adjusting only the hardcoded category filter).

- [ ] **Step 2 — Write the delta script** (`40_growyze_sales_by_category.sql`). Use the same output aliases captured in Step 1 — shown here as `Category` / `Revenue` placeholders; replace with the real aliases:

```sql
-- Growyze-scoped Sales-by-Category pie (replaces hardcoded Food/Drinks split).
-- See docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md Task 3
MERGE INTO core.core.VisualisationQueries AS tgt
USING (VALUES (N'GrowyzeSalesByCategory', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) AS Category,
    SUM(F.NET_VALUE) AS Revenue
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE F.LI_TYPE = ''PROD'' AND F.NET_VALUE > 0
AND COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) NOT IN (''Unknown'')
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])
ORDER BY Revenue DESC;',
    FilterDefinitions = N'<<FoodDrinksSplit FilterDefinitions from Step 1>>',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeSalesByCategory', N'PieChartCard', 1, N'LIVE',
    N'SELECT
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) AS Category,
    SUM(F.NET_VALUE) AS Revenue
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE F.LI_TYPE = ''PROD'' AND F.NET_VALUE > 0
AND COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) NOT IN (''Unknown'')
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])
ORDER BY Revenue DESC;',
    N'<<FoodDrinksSplit FilterDefinitions from Step 1>>', GETDATE(), N'plan-2026-06-05');
PRINT 'Task 3: GrowyzeSalesByCategory deployed.';
```

- [ ] **Step 3 — Deploy + MCP test** (Padel, prefixed). Expected: ≥ 4 slices (Beverages, Food, Other, Retail [+ Uncategorised]), Beverages the largest, no product names as categories, no single-slice degeneracy.

- [ ] **Step 4 — Sync master + commit**

```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/40_growyze_sales_by_category.sql" "releases/v1.1/03_growyze_sales_by_category.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeSalesByCategory pie on real category set (replaces hardcoded Food/Drinks)"
```

---

## Phase 2 — Deep inventory unit-cost fix (investigation-gated)

> **Gate:** Task 4 is a read-only investigation. Its outcome decides whether Task 5 lands in v1.1 or is carved to a v1.2 inventory-variance follow-up. The dashboard cost/GP cards do **not** depend on this (they use `F_PRODUCT_MARGIN_DAY`); this fixes the inventory-side valuation cards.

### Task 4: Confirm pack-size source for unit-cost derivation (investigation)

**Files:** investigation only — record findings in this plan and `ClaudeDevelopment/QUERY_STATUS.md`.

The proper fix needs cost-per-stock-unit = pack price ÷ pack size. We must confirm where pack size lives.

- [ ] **Step 1 — Inspect SAT_INVITEM unit semantics**

```sql
SELECT TOP 50 CAST(HUB_ID AS VARCHAR(80)) AS HUB_ID, UOM, UOM_COST
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[datavault].[SAT_INVITEM]
WHERE CURRENT_FLAG = 1 AND UOM IN ('ml','cl','L','g','kg') ORDER BY UOM_COST DESC;
```
Confirms UOM_COST holds pack price against a sub-unit UOM.

- [ ] **Step 2 — Find pack size in the DL/staging layer**

Inspect `int_growyze001.DL_INVENTORY*` / `DL_DISHES` and the GRYZ inventory staging for a pack-size / pack-quantity / unit-size field (e.g. `packSize`, `size`, `unitQuantity`). Document the exact column and whether it is populated for the ml/cl/g items.

- [ ] **Step 3 — Decide & record**

If a reliable pack size exists for ≳95% of inventory items → **proceed to Task 5** (in v1.1). If not → record that the proper fix requires a Growyze API/ingestion enhancement, **carve Task 5 to a v1.2 inventory-variance ticket**, and rely on the `F_PRODUCT_MARGIN_DAY` re-point (Task 2) for the dashboard. Either way, raise/append a Jira note under the inventory-variance track. Update `memory/growyze-default-dashboards.md`.

### Task 5: Correct SAT_INVITEM.UOM_COST to cost-per-stock-unit *(only if Task 4 = GO)*

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/19_invitem_unit_cost.sql`
- Release copy: `releases/v1.1/05_growyze_invitem_unit_cost.sql`
- Master sync: relevant Growyze inventory staging in `02_staging_tier1.sql` / `03_staging_tier2_3.sql`

- [ ] **Step 1** — In the GRYZ inventory-item staging, derive `UOM_COST = pack_price / NULLIF(pack_size_in_uom, 0)` (using the field confirmed in Task 4), so the stored cost is per ml/g/each. Also fix the inline UOM conversion to recognise `g`/`kg` (currently lists `gr`/`Kg`).
- [ ] **Step 2** — Deploy, re-run staging → DV load → presentation rebuild for both orgs.
- [ ] **Step 3 — Verify ratio sane**

```sql
SELECT SUM(SALES_RECIPE_COST) AS recipe_cost, SUM(NET_SALES) AS net_sales,
       SUM(SALES_RECIPE_COST)*1.0/NULLIF(SUM(NET_SALES),0) AS cost_ratio
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_INV_SALES_DAY];
```
Expected: `cost_ratio` between ~0.2 and ~0.6 (was ~16). Spot-check the worked example (the rosé wine row) reconciles to pennies-per-ml.
- [ ] **Step 4** — Validate the SALES_RECIPE_COST join grain for fan-out (compare a single invitem/day's recipe-cost against hand arithmetic). Commit.

---

## Phase 3 — Time-of-day enablement

### Task 6: Map LINEITEM_TIMESTAMP from the Growyze sale window

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/18_lineitem_timestamp_mapping.sql`
- Release copy: `releases/v1.1/04_growyze_lineitem_timestamp.sql`
- Master sync: `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql` + `04_entity_mappings.sql`

`GRYZ_LINEITEM` staging already emits `s.sale_from AS OPEN_TIME`. `SAT_LINEITEM` already has a `LINEITEM_TIMESTAMP` column consumed by the 15-min bucket. We add `LINEITEM_TIMESTAMP` to (a) staging output + columns, (b) the LINEITEM entity mapping, so the load populates it. Granularity = sale-window open (day-part accurate, not pour-time) — **caveat documented on the heatmap card in Plan 2**.

- [ ] **Step 1 — Confirm NULL baseline**

```sql
SELECT COUNT(*) AS total,
       SUM(CASE WHEN LINEITEM_TIMESTAMP IS NULL THEN 1 ELSE 0 END) AS null_ts
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[datavault].[SAT_LINEITEM]
WHERE CURRENT_FLAG = 1;
```
Expected: null_ts = total.

- [ ] **Step 2 — Write the delta script**

```sql
-- Map Growyze LINEITEM_TIMESTAMP from sale-window OPEN_TIME (s.sale_from).
-- Session-window granularity (no per-line pour time available from Growyze).
-- See docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md Task 6

-- (a) staging: add LINEITEM_TIMESTAMP to SELECT + staging_columns of GRYZ_LINEITEM
UPDATE [core].[int_growyze001].[StagingControl]
SET query_sql = REPLACE(CAST(query_sql AS NVARCHAR(MAX)),
        N's.sale_from AS OPEN_TIME,',
        N's.sale_from AS OPEN_TIME, s.sale_from AS LINEITEM_TIMESTAMP,'),
    staging_columns = REPLACE(staging_columns,
        N'"OPEN_TIME",',
        N'"OPEN_TIME", "LINEITEM_TIMESTAMP",'),
    updated_at = GETDATE()
WHERE staging_table = N'GRYZ_LINEITEM' AND step_name = N'Growyze Line Item';

-- (b) entity mapping: add LINEITEM_TIMESTAMP to source_columns + entity_columns of LINEITEM
UPDATE [core].[int_growyze001].[EntityMappings]
SET source_columns = REPLACE(source_columns,
        N'{"name": "TRADING_DATE", "hash": 0}',
        N'{"name": "TRADING_DATE", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}'),
    entity_columns = REPLACE(entity_columns,
        N'"TRADING_DATE"',
        N'"TRADING_DATE", "LINEITEM_TIMESTAMP"'),
    updated_at = GETDATE()
WHERE entity_name = N'LINEITEM' AND source_table = N'GRYZ_LINEITEM';

PRINT 'Task 6: LINEITEM_TIMESTAMP mapped from OPEN_TIME.';
```

> The REPLACE anchors above match the current live values (verified 2026-06-05): the staging SELECT contains `s.sale_from AS OPEN_TIME,` and `staging_columns` contains `"OPEN_TIME",`; LINEITEM `entity_columns` ends `... , "ORDER_DATE", "TRADING_DATE"` and `source_columns` contains `{"name": "TRADING_DATE", "hash": 0}`. **Before deploy, re-confirm each anchor matches exactly** (Task 6 Step 1's sibling query) — if the staging was edited since, adjust the anchor.

- [ ] **Step 3 — Confirm SAT_LINEITEM populates LINEITEM_TIMESTAMP**

The auto-managed Load step maps `entity_columns` by name to SAT columns; since `SAT_LINEITEM.LINEITEM_TIMESTAMP` already exists, no DDL change is needed. If the integration regenerates Load steps via `UploadEntityMappings`, call it: `EXEC core.UploadEntityMappings @IntegrationSchema = N'int_growyze001';` (include this in the deploy order).

- [ ] **Step 4 — Deploy + re-run staging → DV load → presentation rebuild** (both orgs), then verify:

```sql
SELECT COUNT(*) AS rows_with_ts, MIN(LINEITEM_TIMESTAMP) AS min_ts, MAX(LINEITEM_TIMESTAMP) AS max_ts
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[datavault].[SAT_LINEITEM]
WHERE CURRENT_FLAG = 1 AND LINEITEM_TIMESTAMP IS NOT NULL;

SELECT COUNT(DISTINCT LINEITEM_TIMESTAMP) AS distinct_buckets
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_LINEITEM_15MIN]
WHERE SRC = 'int_growyze001';
```
Expected: rows_with_ts > 0 with a real datetime range; distinct_buckets ≫ 1 (was 0/NULL).

- [ ] **Step 5 — Sync master + commit**

```bash
git add "ClaudeDevelopment/integrations/Growyze/18_lineitem_timestamp_mapping.sql" "releases/v1.1/04_growyze_lineitem_timestamp.sql" "ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql" "ClaudeDevelopment/integrations/Growyze/04_entity_mappings.sql"
git commit -m "feat(growyze): map LINEITEM_TIMESTAMP from sale-window OPEN_TIME (enables time-of-day cards)"
```

---

## Phase 4 — Deploy F_PURCHASES_DAY to Padel

### Task 7: Promote F_PURCHASES_DAY and create it on Padel

F_PURCHASES_DAY already exists on Dirty Sixth. Padel is missing the table (and may be missing `SAT_LNK_INVITEM_STOCKORDER`). The three source scripts (`05`/`06`/`07`) are control-table inserts + per-org DV/table creation.

**Files:**
- Release copies: `releases/v1.1/06_invitem_stockorder_entity.sql` (from `05_invitem_stockorder_entity_fix.sql`), `releases/v1.1/07_f_purchases_day_table.sql` (from `06_…`), `releases/v1.1/08_f_purchases_day_build.sql` (from `07_…`)
- Create: `releases/v1.1/09_per_org_purchases_padel.sql` (cursor/targeted per-org step)
- Master sync: `8_DataVaultEntities.sql`, `8_PresentationTables.sql`, `8_PresentationControl.sql`

- [ ] **Step 1 — Confirm Padel gap**

```sql
SELECT
  (SELECT COUNT(*) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE s.name='presentation' AND t.name='F_PURCHASES_DAY') AS padel_has_fact,
  (SELECT COUNT(*) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE s.name='datavault' AND t.name='SAT_LNK_INVITEM_STOCKORDER') AS padel_has_satlnk;
```
Expected (before): padel_has_fact = 0. Note padel_has_satlnk (if 0, Step 3 must run `sp_GenerateDataVaultTables` for Padel).

- [ ] **Step 2 — Confirm the three source scripts use idempotent patterns**

Re-read `05/06/07`. `06` and `07` use MERGE on natural keys (good). `05` is a keyed UPDATE of `DataVaultEntities` (idempotent) plus per-org `sp_GenerateDataVaultTables` + a load-table recreate — these must be wrapped per-org (Step 4). Remove the hardcoded org GUID in `05`'s commented EXEC when promoting.

- [ ] **Step 3 — Copy to release folder** (verbatim bodies of `05/06/07`):

```bash
cp "ClaudeDevelopment/integrations/Growyze/05_invitem_stockorder_entity_fix.sql" "releases/v1.1/06_invitem_stockorder_entity.sql"
cp "ClaudeDevelopment/integrations/Growyze/06_purchases_presentation_table.sql" "releases/v1.1/07_f_purchases_day_table.sql"
cp "ClaudeDevelopment/integrations/Growyze/07_purchases_presentation_control.sql" "releases/v1.1/08_f_purchases_day_build.sql"
```

- [ ] **Step 4 — Write the per-org Padel creation wrapper** (`09_per_org_purchases_padel.sql`): runs `sp_GenerateDataVaultTables` for Padel (creates `SAT_LNK_INVITEM_STOCKORDER` if missing) and creates `presentation.F_PURCHASES_DAY` via the `IF NOT EXISTS` targeted-table pattern from `release-guide.md` §3, using the DDL from `06`. (Do **not** run `DeployPresentationTables` — it drops/recreates all presentation tables.)

```sql
-- Create F_PURCHASES_DAY on Padel only, additively. See release-guide.md §3 targeted pattern.
DECLARE @Db NVARCHAR(128) = N'20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14';
EXEC [core].[core].[sp_GenerateDataVaultTables] @DatabaseName = @Db, @SchemaName = 'datavault', @ExecuteSQL = 1;
DECLARE @sql NVARCHAR(MAX) = N'USE ' + QUOTENAME(@Db) + N';
IF NOT EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE s.name=''presentation'' AND t.name=''F_PURCHASES_DAY'')
BEGIN
    -- (paste the CREATE TABLE [presentation].[F_PURCHASES_DAY] (...) + indexes from releases/v1.1/07_f_purchases_day_table.sql ddl_script here)
END;';
EXEC sys.sp_executesql @sql;
PRINT 'Task 7: F_PURCHASES_DAY ensured on Padel.';
```

- [ ] **Step 5 — Deploy order** (UAT): `06` (entity → core) → `09` (per-org Padel: gen DV + create table) → `07` (PresentationTables record) → `08` (PresentationControl build) → run **DV load + presentation rebuild for Padel**. (Dirty Sixth already has it; the MERGE/IF NOT EXISTS make re-running harmless.)

- [ ] **Step 6 — Verify Padel populated**

```sql
SELECT COUNT(*) AS rows_, MIN(ORDER_DATE) AS min_d, MAX(ORDER_DATE) AS max_d, SUM(LINE_TOTAL) AS total_value
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PURCHASES_DAY];
```
Expected: ≥ 1 row with a sensible value. (Deliveries KPI accuracy is subject to XMSE-1378/1379/1380 — note in release notes, not a blocker.)

- [ ] **Step 7 — Sync master + commit**

Ensure `8_DataVaultEntities.sql` (INVITEM_STOCKORDER attrs), `8_PresentationTables.sql` (F_PURCHASES_DAY DDL), `8_PresentationControl.sql` ("Purchases by Day" step) all match.

```bash
git add releases/v1.1/06_invitem_stockorder_entity.sql releases/v1.1/07_f_purchases_day_table.sql releases/v1.1/08_f_purchases_day_build.sql releases/v1.1/09_per_org_purchases_padel.sql "8_DataVaultEntities.sql" "8_PresentationTables.sql" "8_PresentationControl.sql"
git commit -m "feat(growyze): deploy F_PURCHASES_DAY fact to Padel (promote 05-07 + per-org create)"
```

---

## Deployment Order (Plan 1, UAT first then Prod)

```
core (run once):
  01 (category sentinel) → 04 (lineitem timestamp) → UploadEntityMappings int_growyze001
  → 02 (cost KPIs) → 03 (sales-by-category)
  → 06 (invitem_stockorder entity) → 07 (F_PURCHASES_DAY table record) → 08 (build step)
  → [Phase 2: 05 only if Task 4 = GO]

per-org (Padel + Dirty Sixth):
  Growyze staging → DV load → presentation rebuild   (picks up 01, 04, and category/timestamp data)
  09 (Padel only: gen DV tables + create F_PURCHASES_DAY) then DV load + presentation rebuild for Padel
```

## Rollback (Tier 2 — data records)

- Task 1/6 (staging/mapping): restore the prior `query_sql` / `staging_columns` / `source_columns` / `entity_columns` from the previous git commit via keyed UPDATE; re-run `UploadEntityMappings`; next rebuild reverts.
- Task 2/3 (vis queries): `UPDATE core.core.VisualisationQueries SET Status='RETIRED'` for `GrowyzeProfit`, `GrowyzeProfitPct`, `GrowyzeSalesByCategory` (or delete the rows) — they are new datasets, so removal is clean and affects nothing else.
- Task 7 (F_PURCHASES_DAY on Padel): drop `presentation.F_PURCHASES_DAY` on Padel; the PresentationTables/Control records are shared (Dirty uses them) so leave them.
- Phase 2 (Task 5): restore prior inventory staging; rebuild.

## Verification Checklist (Plan 1 done when all true)

- [ ] D_PRODUCT fall-through ≈ 0 on both orgs; categories = real set + Uncategorised
- [ ] `GrowyzeProfit` / `GrowyzeProfitPct` return sane £ / % (not −£1.6M / 1,469%) on both orgs
- [ ] `GrowyzeSalesByCategory` returns the multi-slice real category breakdown
- [ ] `SAT_LINEITEM.LINEITEM_TIMESTAMP` populated; F_LINEITEM_15MIN distinct buckets ≫ 1
- [ ] `F_PURCHASES_DAY` populated on Padel (and still on Dirty)
- [ ] Phase 2 decision recorded (GO in v1.1 with sane cost ratio, OR carved to v1.2 with the re-point covering the dashboard)
- [ ] Master files synced in the same commits; `QUERY_STATUS.md` updated

---

## Self-Review

- **Spec coverage:** Phase 1 covers the two upstream bugs (category §Task1, cost re-point §Task2, FoodDrinksSplit §Task3) the user asked to fix; Phase 2 carries the deep inventory-cost fix investigation-gated; Phase 3 the timestamp; Phase 4 the F_PURCHASES_DAY gap on Padel. ✓
- **Placeholders:** the only intentional fill-ins are the FilterDefinitions / OutputDefinitions JSON and the F_PURCHASES_DAY DDL paste — each has an explicit "fetch from X" step rather than a vague TODO. ✓
- **Type/name consistency:** all column references checked against the 2026-06-05 INFORMATION_SCHEMA pull (D_PRODUCT.MIDDLE_1_NAME, D_LOCATION.BOTTOM_LOCATION_NAME, F_PRODUCT_MARGIN_DAY.PROFIT/AVG_NET_COST, F_LINEITEM_15MIN.LI_TYPE/NET_VALUE). ✓
- **Risk:** the only behaviour-changing edits to shared objects are the GRYZ_PRODUCT staging (Growyze-only schema) and the per-org rebuilds; no shared vis query is mutated (Growyze-scoped names throughout). ✓
