# Growyze Dashboards — Plan 2: Cards & Visualisation Queries

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the new and Growyze-aware visualisation queries that back Kati's 3-dashboard default pack (Overview / Sales & Profitability / Inventory Control), building on the trustworthy data Plan 1 established — so Plan 3 only has to wire cards into the Report DB.

**Architecture:** XMS BI Managed Instance. All cards are rows in `core.core.VisualisationQueries` (key = `DataSetName` + `VisualizationType`), executed by card-type stored procedures with `@FilterClause` injection. We author every change as an idempotent MERGE script in `ClaudeDevelopment/integrations/Growyze/reporting_queries/`, then (release-prep) copy to `releases/v1.1/` and sync `8_VisualisationQueries.sql` in the same commit per `docs/release-guide.md` §10.

**Tech Stack:** T-SQL, `MERGE` upserts on (DataSetName, VisualizationType), `CAST(... AS NVARCHAR(MAX))` for TEXT control columns, MCP read-only verification (`mcp__xms-bi-uat__query`, `database="core"`, three-part naming, comments stripped, `@FilterClause`→empty, drop trailing header SELECT).

## Global Constraints

- **Never mutate shared `OakVine*` / cross-org datasets.** Every new or re-pointed card gets a **Growyze-scoped** `DataSetName` (`Growyze*`) and is wired only to the Growyze pack — zero regression on Oak & Vine or any other org. (Established in Plan 1.)
- **All cost / GP sources from `presentation.F_PRODUCT_MARGIN_DAY`** (`PROFIT`, `AVG_NET_COST`, `NET_VALUE`) — never `F_INV_SALES_DAY` (recipe-cost inflated) and never `D_PRODUCT.BOTTOM_NET_COST` (does not exist).
- **Guard comp lines:** every GP/profit/mix aggregation includes `AND F.NET_VALUE > 0` (excludes the ~18–22% £0 comp lines).
- **Category label** resolves as `COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])`; for Growyze `TOP_NAME == MIDDLE_1_NAME`. MICROSERVICE_NAME is the MDM layer (may be NULL) — always COALESCE to the native name.
- **Idempotent + master-synced:** every delta is re-runnable (`MERGE` on the natural key); `8_VisualisationQueries.sql` is updated in the same commit.
- **Card output contract:** each vis query returns result-set 1 = data rows, result-set 2 = header metadata (Title, Description, Trend, Chip, …). New cards MUST mirror the exact output aliases of the closest working card of the same `VisualizationType` so the card-type SP renders them.
- **Depends on Plan 1 being deployed** — these cards read `GrowyzeProfit`/`GrowyzeProfitPct`/`GrowyzeSalesByCategory` datasets, the category sentinel, the `createdAt`→`LINEITEM_TIMESTAMP` mapping, and `F_PURCHASES_DAY` on Padel.

---

## Target orgs (UAT)
- Padel Social — `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`
- Dirty Sixth — `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A`

## Card inventory (mockup → build classification)

The mockup (`ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html`) has ~45 card slots. Classified against current capability + Plan 1:

### Already handled by Plan 1 (no work here — Plan 3 wires them)
- `GrowyzeProfit`, `GrowyzeProfitPct` (SingleKPICard) — Profit / Profit% KPIs.
- `GrowyzeSalesByCategory` (PieChartCard) — Menu Performance donut / Sales-by-Category.
- `F_PURCHASES_DAY` fact on Padel — feeds the Deliveries KPI (built here as a card).

### Reuse existing shared datasets as-is (no new SQL — Plan 3 wiring only)
- `NetSales` (SingleKPICard) — Total Menu Sales.
- `OakVineMenuAvgItemValue` (SingleKPICard) — Avg Selling Price. *(verify Growyze-safe in Task V.)*
- `OakVineInvTotalCost` — Theoretical stock on hand.
- `InvWasteCost` — Waste (value).
- `InvStockActivity` — Stock Value over time (MultiLineChartCard + StackedBarChartCard).
- `InvKPIGrouped` — Stock value by venue×category grid + totals.
- `InvCOGSByCategory` — Stock value by category pie.
- `InvUseAnalisys` — Inventory Items Movement grid (Transfers column deferred).
- `ProductComparison` — Category Breakdown grid / Menu Item Performance grid.

### NEW / Growyze-aware — the work of this plan (one task each)
| Task | DataSetName | Card type | Purpose | Grounded on |
|---|---|---|---|---|
| A | `GrowyzeActiveStocktakes` | SingleKPICard | "X / Y" venues counted in period | F_INV_COUNTS_DAY, D_LOCATION |
| B | `GrowyzeDeliveriesValue` | SingleKPICard | Deliveries £ in period | F_PURCHASES_DAY |
| C | `GrowyzeAvgCostSpend` | SingleKPICard | Avg cost per item sold | F_PRODUCT_MARGIN_DAY |
| D | `GrowyzeBestCategory` | SingleKPICard (label) | Best-performing category name + GP% | F_PRODUCT_MARGIN_DAY, D_PRODUCT |
| E | `GrowyzeTopRevenueItem`, `GrowyzeHighestGPItem`, `GrowyzeMostSoldItem`, `GrowyzeLowestItem` | SingleKPICard (label) | Menu Item Highlights strip (4 of 5; "Fastest Growing" deferred) | F_PRODUCT_MARGIN_DAY, D_PRODUCT |
| F | `GrowyzeHighestVenue`, `GrowyzeLowestVenue` | SingleKPICard (label) | Highest / Lowest stock-value venue | F_INV_COUNTS_DAY, D_LOCATION |
| G | `GrowyzeCategoryStockTrend` | CustomDataGrid | Category stock delta callouts (latest − earliest in window) | F_INV_COUNTS_DAY, D_INVITEM |
| H | `GrowyzeMenuProfitabilityTrend` | (Combined/MultiLine) | Margin + Cost over time (no Discounts for Growyze) | F_PRODUCT_MARGIN_DAY |
| I | `GrowyzeMenuEngineering` | CustomDataGrid | Menu-engineering quadrant via SQL CASE (Stars/Puzzles/Workhorses/Dogs) | F_PRODUCT_MARGIN_DAY |
| J | `GrowyzeSalesHeatmap` | HeatmapCard | Top-10 products qty by day × time-of-day | F_LINEITEM_15MIN (needs Plan 1 Task 6) |
| K | `GrowyzeProductsCompFilter` | FilterList | Location filter, Growyze-aware (no hardcoded NCRAloha SRC) | D_LOCATION |
| L | `InvMargeBrut` fix | (existing) | Scope out unbindable invitem filters (XMSE-1099) | existing template |

### Deferred (out of scope for this pass — documented, not silently dropped)
- **Ingredient Based Sales** panel (entire Inventory section) — needs Growyze recipe ingest (RECIPE_PRODUCT mapping) + supplier-unit conversion + a new Tier-2 presentation table + ~5 vis queries. **Phase 2 / separate plan** per the mockup's own recommendation.
- **"Fastest Growing Item"** highlight — needs a per-item prior-period comparison not currently exposed; ship 4 of the 5 highlight slots.
- **Menu Engineering as a true scatter/quadrant chart component** — no ScatterChartCard exists; ship the CustomDataGrid classification (Task I) instead, per the mockup recommendation.
- **Inventory Items Movement "Transfers" column** — STOCKEVENT `TRANSFER` isn't aggregated into a presentation column; reuse `InvUseAnalisys` without it.
- **"Discounts" series** in Overall Menu Profitability — Growyze has no per-line discount; ship Margin + Cost two-series (Task H).
- **NetSales chart variants** (Bar/Combined/MultiLine/StackedBar/Stat) — 5 of 6 query dead legacy `threerocks.dbo.CShopProductSales` and 500. Not shown in the mockup dashboards (only the SingleKPICard is). Tracked as a separate cleanup, not part of the default pack.

---

## Release & File Structure

Ships as part of **release `v1.1`** (same delta folder as Plan 1). Authored files live in `ClaudeDevelopment/integrations/Growyze/reporting_queries/` (numbers continue from Plan 1's 39/40), release copies in `releases/v1.1/`, master sync `8_VisualisationQueries.sql`.

| Authored file | Release copy | Task |
|---|---|---|
| `reporting_queries/41_growyze_active_stocktakes.sql` | `releases/v1.1/10_growyze_active_stocktakes.sql` | A |
| `reporting_queries/42_growyze_deliveries_value.sql` | `releases/v1.1/11_growyze_deliveries_value.sql` | B |
| `reporting_queries/43_growyze_avg_cost_spend.sql` | `releases/v1.1/12_growyze_avg_cost_spend.sql` | C |
| `reporting_queries/44_growyze_best_category.sql` | `releases/v1.1/13_growyze_best_category.sql` | D |
| `reporting_queries/45_growyze_menu_highlights.sql` | `releases/v1.1/14_growyze_menu_highlights.sql` | E |
| `reporting_queries/46_growyze_venue_extremes.sql` | `releases/v1.1/15_growyze_venue_extremes.sql` | F |
| `reporting_queries/47_growyze_category_stock_trend.sql` | `releases/v1.1/16_growyze_category_stock_trend.sql` | G |
| `reporting_queries/48_growyze_menu_profitability_trend.sql` | `releases/v1.1/17_growyze_menu_profitability_trend.sql` | H |
| `reporting_queries/49_growyze_menu_engineering.sql` | `releases/v1.1/18_growyze_menu_engineering.sql` | I |
| `reporting_queries/50_growyze_sales_heatmap.sql` | `releases/v1.1/19_growyze_sales_heatmap.sql` | J |
| `reporting_queries/51_growyze_productscomp_filter.sql` | `releases/v1.1/20_growyze_productscomp_filter.sql` | K |
| `reporting_queries/52_invmargebrut_filter_fix.sql` | `releases/v1.1/21_invmargebrut_filter_fix.sql` | L |

## Self-Contained Test Pattern

Each task ends with **MCP read-only verification**: strip comments, replace `@FilterClause` with empty string, prefix presentation tables with the Padel DB name, drop the trailing header SELECT, run from `database="core"`, and confirm the row shape + sane values. Deploys (writes) are executed by the developer.

---

## Deployment Order (all to `core`, after Plan 1 is deployed)

```
41 (active stocktakes) → 42 (deliveries) → 43 (avg cost) → 44 (best category)
→ 45 (menu highlights ×4) → 46 (venue extremes ×2) → 47 (category stock trend)
→ 48 (profitability trend) → 49 (menu engineering) → 50 (sales heatmap)
→ 51 (ProductsComp filter) → 52 (InvMargeBrut fix)
```
No presentation rebuild needed (vis queries are read at card-execution time). All are new Growyze-scoped datasets except 51 (new Growyze-scoped filter) and 52 (edits the existing InvMargeBrut FilterDefinitions only).

## Rollback (Tier 2 — data records)
- Tasks A–K: `UPDATE core.core.VisualisationQueries SET Status='RETIRED'` for the new `Growyze*` datasets (or delete the rows) — new datasets, clean removal, affects nothing else.
- Task L: restore InvMargeBrut's prior `FilterDefinitions` from the previous git commit.

---

## Shared Constants (paste literally where a task references them)

**Every MERGE uses this idempotent shape** (template held in a variable so the QueryTemplate text is written once, not duplicated across MATCHED/NOT MATCHED):

```sql
DECLARE @q NVARCHAR(MAX) = N'<QueryTemplate>';
DECLARE @fd NVARCHAR(MAX) = N'<FilterDefinitions JSON>';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'<DataSetName>', N'<VisualizationType>')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'<DataSetName>', N'<VisualizationType>', 1, N'LIVE', @q, @fd, GETDATE(), N'plan-2026-07-10-O5');
```

**`FD_MARGIN`** — FilterDefinitions for cards over `F_PRODUCT_MARGIN_DAY` / `F_LINEITEM_15MIN` with `product` + `location` aliases (verbatim from `ProductComparison`, ProductCategories re-pointed to MIDDLE_1 to match Growyze grouping):
```json
{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}
```

**`FD_INV`** — FilterDefinitions for cards over the inventory facts with `location` + `invitem` aliases:
```json
{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}
```

> **MCP verification recipe (all tasks):** run from `database="core"`; strip comments; replace `@FilterClause` with an empty string; prefix every presentation/datavault table with the Padel DB name `[20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14]`; drop the trailing header SELECT (result-set 2) before running (MCP returns only the first result set).

---

## Phase A — Overview / Inventory KPIs

### Task A: `GrowyzeActiveStocktakes` (SingleKPICard — "X / Y")

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/41_growyze_active_stocktakes.sql`
- Release copy: `releases/v1.1/10_growyze_active_stocktakes.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces vis dataset `GrowyzeActiveStocktakes`/`SingleKPICard`. Consumes `presentation.F_INV_COUNTS_DAY`, `presentation.D_LOCATION`, `presentation.CALENDAR`. Ground truth: Padel has 3 venue rows (`BOTTOM_LEVEL_NAME='Location'`, name≠'Unknown') and stocktakes for 2 distinct locations ⇒ expect `2 / 3`.

- [ ] **Step 1 — Baseline**
```sql
SELECT
  (SELECT COUNT(*) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_LOCATION] WHERE BOTTOM_LEVEL_NAME='Location' AND BOTTOM_LOCATION_NAME<>'Unknown') AS total_venues,
  (SELECT COUNT(DISTINCT LOCATION_HUB_ID) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_INV_COUNTS_DAY]) AS venues_counted;
```
Expected: `total_venues=3`, `venues_counted=2`.

- [ ] **Step 2 — Write `41_growyze_active_stocktakes.sql`** using the Shared MERGE shape with `@fd = FD_INV`:
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT
    N''Active Stocktakes'' AS Title,
    CAST(COUNT(DISTINCT FC.LOCATION_HUB_ID) AS NVARCHAR(10)) + N'' / '' +
    CAST((SELECT COUNT(*) FROM [presentation].[D_LOCATION] v WHERE v.[BOTTOM_LEVEL_NAME] = ''Location'' AND v.[BOTTOM_LOCATION_NAME] <> ''Unknown'') AS NVARCHAR(10)) AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';
-- @fd = the FD_INV JSON block from Shared Constants
-- MERGE (Shared shape) on (N'GrowyzeActiveStocktakes', N'SingleKPICard')
```

- [ ] **Step 3 — MCP-verify** (strip comments, `@FilterClause`→'', prefix tables): expect one row `Active Stocktakes | 2 / 3`.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/41_growyze_active_stocktakes.sql" "releases/v1.1/10_growyze_active_stocktakes.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeActiveStocktakes X/Y venues-counted KPI"
```

---

### Task B: `GrowyzeDeliveriesValue` (SingleKPICard)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/42_growyze_deliveries_value.sql`
- Release copy: `releases/v1.1/11_growyze_deliveries_value.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeDeliveriesValue`/`SingleKPICard`. Consumes `presentation.F_PURCHASES_DAY` (columns: ORDER_DATE, LINE_TOTAL, LOCATION_HUB_ID, INVITEM_HUB_ID, …). **Depends on Plan 1 Task 7** (F_PURCHASES_DAY on Padel; already present on Dirty Sixth).

- [ ] **Step 1 — Baseline** (Dirty Sixth, which already has the fact):
```sql
SELECT COUNT(*) AS rows_, FORMAT(SUM(ISNULL(LINE_TOTAL,0)),'N0') AS total_value
FROM [20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A].[presentation].[F_PURCHASES_DAY];
```
Expected: ≥1 row, a sensible £ total.

- [ ] **Step 2 — Write `42_growyze_deliveries_value.sql`** (Shared MERGE, `@fd = FD_INV`):
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT
    N''Deliveries'' AS Title,
    N''£'' + FORMAT(SUM(ISNULL(F.[LINE_TOTAL],0)), ''N0'') AS Value
FROM [presentation].[F_PURCHASES_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON F.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';
-- @fd = FD_INV ; MERGE (Shared shape) on (N'GrowyzeDeliveriesValue', N'SingleKPICard')
```

- [ ] **Step 3 — MCP-verify** against **Dirty Sixth** (Padel has no rows until Plan 1 Task 7 loads): expect `Deliveries | £<n>`.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/42_growyze_deliveries_value.sql" "releases/v1.1/11_growyze_deliveries_value.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeDeliveriesValue KPI on F_PURCHASES_DAY"
```

---

### Task C: `GrowyzeAvgCostSpend` (SingleKPICard)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/43_growyze_avg_cost_spend.sql`
- Release copy: `releases/v1.1/12_growyze_avg_cost_spend.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeAvgCostSpend`/`SingleKPICard`. Consumes `presentation.F_PRODUCT_MARGIN_DAY` (QUANTITY, AVG_NET_COST, NET_VALUE). Avg cost per item sold = `SUM(QUANTITY*AVG_NET_COST)/SUM(QUANTITY)`.

- [ ] **Step 1 — Baseline**
```sql
SELECT N'£' + FORMAT(SUM(F.QUANTITY*F.AVG_NET_COST)/NULLIF(SUM(F.QUANTITY),0),'N2') AS avg_cost_spend
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] F
WHERE F.NET_VALUE > 0;
```
Expected: a small positive £ (single-item cost, e.g. £1–£15).

- [ ] **Step 2 — Write `43_growyze_avg_cost_spend.sql`** (Shared MERGE, `@fd = FD_MARGIN`):
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT
    N''Avg Cost Spend'' AS Title,
    N''£'' + FORMAT(SUM(F.[QUANTITY] * F.[AVG_NET_COST]) / NULLIF(SUM(F.[QUANTITY]), 0), ''N2'') AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.[NET_VALUE] > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';
-- @fd = FD_MARGIN ; MERGE (Shared shape) on (N'GrowyzeAvgCostSpend', N'SingleKPICard')
```

- [ ] **Step 3 — MCP-verify** (prefixed): one row, sane per-item £.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/43_growyze_avg_cost_spend.sql" "releases/v1.1/12_growyze_avg_cost_spend.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeAvgCostSpend KPI off F_PRODUCT_MARGIN_DAY"
```

---

## Phase B — Sales & Profitability label KPIs

### Task D: `GrowyzeBestCategory` (SingleKPICard — label)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/44_growyze_best_category.sql`
- Release copy: `releases/v1.1/13_growyze_best_category.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeBestCategory`/`SingleKPICard`. Label-KPI pattern (`Title`+text `Value`, `TOP 1 ... GROUP BY ... ORDER BY`). Ranks categories by total `PROFIT`; `Value` = `"<Category> · <GP%>"`.

- [ ] **Step 1 — Baseline**
```sql
SELECT TOP 3 COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]) AS cat,
  ROUND(SUM(F.PROFIT),0) AS profit,
  FORMAT(SUM(F.PROFIT)*100.0/NULLIF(SUM(F.NET_VALUE),0),'N1')+'%' AS gp
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] F
LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID=product.BOTTOM_HUB_ID
WHERE F.NET_VALUE>0 AND COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])<>'Unknown'
GROUP BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]) ORDER BY SUM(F.PROFIT) DESC;
```
Expected: top category = Beverages or Other (per Plan 1 pie), with a plausible GP%.

- [ ] **Step 2 — Write `44_growyze_best_category.sql`** (Shared MERGE, `@fd = FD_MARGIN`):
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT TOP 1
    N''Best Category'' AS Title,
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) + N'' · '' +
    FORMAT(SUM(F.[PROFIT]) * 100.0 / NULLIF(SUM(F.[NET_VALUE]), 0), ''N1'') + N''%'' AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1 AND F.[NET_VALUE] > 0
AND COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) <> ''Unknown''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])
ORDER BY SUM(F.[PROFIT]) DESC;';
-- Replace the · with a literal middot character in the actual file.
-- @fd = FD_MARGIN ; MERGE (Shared shape) on (N'GrowyzeBestCategory', N'SingleKPICard')
```

- [ ] **Step 3 — MCP-verify** (prefixed): one row, `Best Category | <name> · <gp>%`.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/44_growyze_best_category.sql" "releases/v1.1/13_growyze_best_category.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeBestCategory label KPI (category + GP%)"
```

---

### Task E: Menu Item Highlights — 4 label KPIs

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/45_growyze_menu_highlights.sql`
- Release copy: `releases/v1.1/14_growyze_menu_highlights.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces four `SingleKPICard` label datasets — `GrowyzeTopRevenueItem`, `GrowyzeHighestGPItem`, `GrowyzeMostSoldItem`, `GrowyzeLowestItem` — all off `F_PRODUCT_MARGIN_DAY`, `Value` = product name via `COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])`. The 5th mockup slot ("Fastest Growing") is **deferred** (needs a per-item prior-period comparison not exposed today). One script, four MERGEs, each `@fd = FD_MARGIN`.

- [ ] **Step 1 — Baseline** (confirms each ranking returns a real product):
```sql
SELECT
 (SELECT TOP 1 COALESCE(p.[BOTTOM_MICROSERVICE_NAME],p.[BOTTOM_PRODUCT_NAME]) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] f LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT] p ON f.PRODUCT_HUB_ID=p.BOTTOM_HUB_ID WHERE f.NET_VALUE>0 GROUP BY COALESCE(p.[BOTTOM_MICROSERVICE_NAME],p.[BOTTOM_PRODUCT_NAME]) ORDER BY SUM(f.NET_VALUE) DESC) AS top_revenue,
 (SELECT TOP 1 COALESCE(p.[BOTTOM_MICROSERVICE_NAME],p.[BOTTOM_PRODUCT_NAME]) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] f LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT] p ON f.PRODUCT_HUB_ID=p.BOTTOM_HUB_ID WHERE f.NET_VALUE>0 GROUP BY COALESCE(p.[BOTTOM_MICROSERVICE_NAME],p.[BOTTOM_PRODUCT_NAME]) HAVING SUM(f.QUANTITY)>=10 ORDER BY SUM(f.PROFIT)*1.0/NULLIF(SUM(f.NET_VALUE),0) DESC) AS highest_gp,
 (SELECT TOP 1 COALESCE(p.[BOTTOM_MICROSERVICE_NAME],p.[BOTTOM_PRODUCT_NAME]) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] f LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT] p ON f.PRODUCT_HUB_ID=p.BOTTOM_HUB_ID WHERE f.NET_VALUE>0 GROUP BY COALESCE(p.[BOTTOM_MICROSERVICE_NAME],p.[BOTTOM_PRODUCT_NAME]) ORDER BY SUM(f.QUANTITY) DESC) AS most_sold;
```
Expected: three real, distinct product names. (The `HAVING SUM(QUANTITY)>=10` guard on Highest-GP avoids single-sale 100%-margin outliers — median product popularity is only 9.)

- [ ] **Step 2 — Write `45_growyze_menu_highlights.sql`** — four MERGEs. Each QueryTemplate is the label-KPI shape below with the noted Title / ORDER BY / guard:

| DataSetName | Title | Ranking (`ORDER BY`) | Extra |
|---|---|---|---|
| `GrowyzeTopRevenueItem` | `Top Revenue Item` | `SUM(F.[NET_VALUE]) DESC` | — |
| `GrowyzeHighestGPItem` | `Highest GP% Item` | `SUM(F.[PROFIT])*1.0/NULLIF(SUM(F.[NET_VALUE]),0) DESC` | `HAVING SUM(F.[QUANTITY]) >= 10` |
| `GrowyzeMostSoldItem` | `Most Sold Item` | `SUM(F.[QUANTITY]) DESC` | — |
| `GrowyzeLowestItem` | `Lowest Performer` | `SUM(F.[NET_VALUE]) ASC` | — |

Template (substitute `<Title>`, `<ORDER BY>`, and insert `<HAVING>` only for GrowyzeHighestGPItem):
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT TOP 1
    N''<Title>'' AS Title,
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1 AND F.[NET_VALUE] > 0
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) <> ''Unknown''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME])
<HAVING>
ORDER BY <ORDER BY>;';
-- @fd = FD_MARGIN ; one MERGE (Shared shape) per row of the table above.
```

- [ ] **Step 3 — MCP-verify each of the four** (prefixed): each returns one row, a distinct real product name in `Value`.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/45_growyze_menu_highlights.sql" "releases/v1.1/14_growyze_menu_highlights.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): Menu Item Highlights - 4 label KPIs (top revenue/GP/sold/lowest)"
```

---

### Task F: Venue extremes — `GrowyzeHighestVenue` / `GrowyzeLowestVenue`

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/46_growyze_venue_extremes.sql`
- Release copy: `releases/v1.1/15_growyze_venue_extremes.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeHighestVenue` and `GrowyzeLowestVenue` (`SingleKPICard`, label). Theoretical stock value per venue = latest count per (location,invitem) then `SUM(THEO_QTY*UOM_COST)` per venue (mirrors InvKPIGrouped's `Counts` RN=1 pattern). `Value` = `"<Venue> · £<value>"`. Two MERGEs; `@fd = FD_INV`.

- [ ] **Step 1 — Baseline** (venue stock-value ranking):
```sql
WITH L AS (
  SELECT FC.LOCATION_HUB_ID, FC.THEO_QTY, FC.UOM_COST,
    ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.COUNT_DATE DESC) AS RN
  FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_INV_COUNTS_DAY] FC)
SELECT COALESCE(loc.[BOTTOM_MICROSERVICE_NAME],loc.[BOTTOM_LOCATION_NAME]) AS venue,
  ROUND(SUM(ISNULL(L.THEO_QTY,0)*ISNULL(L.UOM_COST,0)),0) AS stock_value
FROM L LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_LOCATION] loc ON L.LOCATION_HUB_ID=loc.BOTTOM_HUB_ID
WHERE L.RN=1 GROUP BY COALESCE(loc.[BOTTOM_MICROSERVICE_NAME],loc.[BOTTOM_LOCATION_NAME]) ORDER BY stock_value DESC;
```
Expected: 2 venue rows with sane £ values (Padel has counts for 2 of 3 venues).

- [ ] **Step 2 — Write `46_growyze_venue_extremes.sql`** — two MERGEs sharing this template (differ only in `<Title>` and the final `ORDER BY sv.stock_value <DESC|ASC>`):
```sql
DECLARE @q NVARCHAR(MAX) = N'WITH LatestCount AS (
    SELECT FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID, FC.THEO_QTY, FC.UOM_COST,
        ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.[BOTTOM_INVITEM_NAME] IS NOT NULL
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
),
sv AS (
    SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME]) AS venue,
           SUM(ISNULL(L.THEO_QTY,0) * ISNULL(L.UOM_COST,0)) AS stock_value
    FROM LatestCount L
    LEFT JOIN [presentation].[D_LOCATION] location ON L.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE L.RN = 1
    GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME])
)
SELECT TOP 1
    N''<Title>'' AS Title,
    sv.venue + N'' · £'' + FORMAT(sv.stock_value, ''N0'') AS Value
FROM sv
ORDER BY sv.stock_value <DESC|ASC>;';
-- Replace · with a middot and £ with a literal pound sign in the file.
-- GrowyzeHighestVenue: Title=''Highest Stock Venue'', ORDER BY ... DESC
-- GrowyzeLowestVenue:  Title=''Lowest Stock Venue'',  ORDER BY ... ASC
-- @fd = FD_INV ; MERGE (Shared shape) per dataset.
```

- [ ] **Step 3 — MCP-verify both** (prefixed, drop the `@FilterClause` line): Highest returns the larger venue, Lowest the smaller.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/46_growyze_venue_extremes.sql" "releases/v1.1/15_growyze_venue_extremes.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): Highest/Lowest stock-value venue label KPIs"
```

---

## Phase C — Trend & analytical grids

### Task G: `GrowyzeCategoryStockTrend` (CustomDataGrid)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/47_growyze_category_stock_trend.sql`
- Release copy: `releases/v1.1/16_growyze_category_stock_trend.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeCategoryStockTrend`/`CustomDataGrid`. Backs the Overview "category trend callouts" (+£ / %). Per inventory category (`D_INVITEM.TOP_NAME`), computes stock value at the earliest vs latest stocktake in the period (`THEO_QTY*UOM_COST`) and the delta. Grid Column layout mirrors `ProductComparison`/`InvUseAnalisys` (Column1..29 + header Label/Type). `@fd = FD_INV`.

- [ ] **Step 1 — Baseline** (categories + how many distinct count dates exist per category):
```sql
SELECT COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS category,
  COUNT(DISTINCT FC.[COUNT_DATE]) AS count_dates,
  ROUND(SUM(ISNULL(FC.THEO_QTY,0)*ISNULL(FC.UOM_COST,0)),0) AS total_theo_value
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_INV_COUNTS_DAY] FC
LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID=invitem.BOTTOM_HUB_ID
GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) ORDER BY total_theo_value DESC;
```
Expected: a handful of categories, each with ≥2 count dates (needed for a delta). Record them.

- [ ] **Step 2 — Write `47_growyze_category_stock_trend.sql`** (Shared MERGE, `@fd = FD_INV`). QueryTemplate:
```sql
DECLARE @q NVARCHAR(MAX) = N'WITH PerCatDate AS (
    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS category,
        FC.[COUNT_DATE] AS count_date,
        SUM(ISNULL(FC.THEO_QTY,0) * ISNULL(FC.UOM_COST,0)) AS value_
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.[BOTTOM_INVITEM_NAME] IS NOT NULL
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]), FC.[COUNT_DATE]
),
Ranked AS (
    SELECT category, count_date, value_,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY count_date ASC)  AS rn_early,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY count_date DESC) AS rn_late
    FROM PerCatDate
)
SELECT
    category AS Column1,
    ROUND(MAX(CASE WHEN rn_early = 1 THEN value_ END), 0) AS Column2,
    ROUND(MAX(CASE WHEN rn_late  = 1 THEN value_ END), 0) AS Column3,
    ROUND(MAX(CASE WHEN rn_late = 1 THEN value_ END) - MAX(CASE WHEN rn_early = 1 THEN value_ END), 0) AS Column4,
    CASE WHEN ISNULL(MAX(CASE WHEN rn_early = 1 THEN value_ END),0) = 0 THEN NULL
         ELSE ROUND((MAX(CASE WHEN rn_late = 1 THEN value_ END) - MAX(CASE WHEN rn_early = 1 THEN value_ END)) * 100.0
                    / MAX(CASE WHEN rn_early = 1 THEN value_ END), 1) END AS Column5,
    NULL AS Column6
    /* pad Column7..Column29 as NULL AS ColumnN, exactly as ProductComparison does */
FROM Ranked
WHERE rn_early = 1 OR rn_late = 1
GROUP BY category
ORDER BY Column4 DESC;

SELECT
    N''Category Stock Trend'' AS Title,
    N''Stock value change per category, earliest to latest stocktake in period'' AS Description,
    N''Category'' AS Label1, N''TEXT'' AS Type1,
    N''Earliest Value'' AS Label2, N''DECIMAL'' AS Type2,
    N''Latest Value'' AS Label3, N''DECIMAL'' AS Type3,
    N''Change (GBP)'' AS Label4, N''DECIMAL'' AS Type4,
    N''Change (%)'' AS Label5, N''DECIMAL'' AS Type5,
    NULL AS Label6, NULL AS Type6
    /* pad Label7..Label29 + Type7..Type29 as NULL, exactly as ProductComparison does */;';
-- @fd = FD_INV ; MERGE (Shared shape) on (N'GrowyzeCategoryStockTrend', N'CustomDataGrid')
```

- [ ] **Step 3 — MCP-verify** (prefixed, run only the FIRST SELECT): one row per category, Column2/3 populated, Column4 = latest − earliest, Column5 = %.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/47_growyze_category_stock_trend.sql" "releases/v1.1/16_growyze_category_stock_trend.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeCategoryStockTrend delta grid (earliest vs latest stocktake)"
```

---

### Task H: `GrowyzeMenuProfitabilityTrend` (CombinedChartCard)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/48_growyze_menu_profitability_trend.sql`
- Release copy: `releases/v1.1/17_growyze_menu_profitability_trend.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeMenuProfitabilityTrend`/`CombinedChartCard`. Two series over time — **Margin** (`SUM(PROFIT)`, bar) and **Cost** (`SUM(QUANTITY*AVG_NET_COST)`, line) by day. **No "Discounts" series** — Growyze has no per-line discount (documented in Deferred). Output shape mirrors `OakVineMarginByCategory`: data `XAxisLabel, LabelSort, Value, ValueSort, VisId, VisType, LegendLabel`; header `XAxisLabel, YAxisLabel, Title, Description`. `@fd = FD_MARGIN`.

- [ ] **Step 1 — Baseline** (confirm both series have daily values):
```sql
SELECT CAST(F.ORDER_DATE AS DATE) AS d, ROUND(SUM(F.PROFIT),0) AS margin, ROUND(SUM(F.QUANTITY*F.AVG_NET_COST),0) AS cost
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] F
WHERE F.NET_VALUE>0 GROUP BY CAST(F.ORDER_DATE AS DATE) ORDER BY d DESC;
```
Expected: multiple day rows, margin & cost both positive.

- [ ] **Step 2 — Write `48_growyze_menu_profitability_trend.sql`** (Shared MERGE, `@fd = FD_MARGIN`). QueryTemplate:
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT XAxisLabel, LabelSort, Value, ValueSort, VisId, VisType, LegendLabel
FROM (
    SELECT
        CONVERT(NVARCHAR, CAST(F.[ORDER_DATE] AS DATE), 23) AS XAxisLabel,
        DENSE_RANK() OVER(ORDER BY CAST(F.[ORDER_DATE] AS DATE)) AS LabelSort,
        ROUND(SUM(F.[PROFIT]), 0) AS Value,
        1 AS ValueSort, 1 AS VisId, ''bar'' AS VisType, ''Margin'' AS LegendLabel
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1 AND F.[NET_VALUE] > 0 AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY CAST(F.[ORDER_DATE] AS DATE)
    UNION ALL
    SELECT
        CONVERT(NVARCHAR, CAST(F.[ORDER_DATE] AS DATE), 23) AS XAxisLabel,
        DENSE_RANK() OVER(ORDER BY CAST(F.[ORDER_DATE] AS DATE)) AS LabelSort,
        ROUND(SUM(F.[QUANTITY] * F.[AVG_NET_COST]), 0) AS Value,
        2 AS ValueSort, 2 AS VisId, ''line'' AS VisType, ''Cost'' AS LegendLabel
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1 AND F.[NET_VALUE] > 0 AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY CAST(F.[ORDER_DATE] AS DATE)
) sub

SELECT
    N''Date'' AS XAxisLabel,
    N''Margin / Cost'' AS YAxisLabel,
    N''Menu Profitability Trend'' AS Title,
    N''Daily margin vs recipe cost'' AS Description;';
-- @fd = FD_MARGIN ; MERGE (Shared shape) on (N'GrowyzeMenuProfitabilityTrend', N'CombinedChartCard')
```

- [ ] **Step 3 — MCP-verify** (prefixed, first SELECT only): two interleaved series (Margin/Cost) across dates, ordered by LabelSort.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/48_growyze_menu_profitability_trend.sql" "releases/v1.1/17_growyze_menu_profitability_trend.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeMenuProfitabilityTrend margin+cost combined chart"
```

---

### Task I: `GrowyzeMenuEngineering` (CustomDataGrid — quadrant classification)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/49_growyze_menu_engineering.sql`
- Release copy: `releases/v1.1/18_growyze_menu_engineering.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeMenuEngineering`/`CustomDataGrid`. Per the mockup recommendation (no ScatterChartCard exists), ships the quadrant as a grid: each product classified Star / Puzzle / Workhorse / Dog by **dynamically computed medians** (popularity = `SUM(QUANTITY)`, profitability = GP%). Ground-truth split points today: popularity median 9, GP% median 81.0% (computed live, not hardcoded, since data shifts). Columns mirror `ProductComparison`. `@fd = FD_MARGIN`.

> **Caveat (document on the card):** popularity is heavily right-skewed (median 9, max ~2958) and GP% has negative outliers (min ~−84%), so a median split puts roughly half the catalogue at ≤9 units. Acceptable for a first-pass classification; revisit thresholds with Kati if needed.

- [ ] **Step 1 — Baseline** (median split points + a sample classification count):
```sql
WITH prod AS (
  SELECT SUM(F.QUANTITY) AS qty, SUM(F.PROFIT)*100.0/NULLIF(SUM(F.NET_VALUE),0) AS gp
  FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] F
  WHERE F.NET_VALUE>0 GROUP BY F.PRODUCT_HUB_ID)
SELECT COUNT(*) AS products,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY qty) OVER() AS med_qty,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gp) OVER() AS med_gp
FROM prod;
```
Expected: ~489 products, med_qty ≈ 9, med_gp ≈ 81.

- [ ] **Step 2 — Write `49_growyze_menu_engineering.sql`** (Shared MERGE, `@fd = FD_MARGIN`). QueryTemplate:
```sql
DECLARE @q NVARCHAR(MAX) = N'WITH prod AS (
    SELECT
        COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) AS product_name,
        COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) AS category,
        SUM(F.[QUANTITY]) AS qty,
        SUM(F.[NET_VALUE]) AS revenue,
        SUM(F.[PROFIT]) * 100.0 / NULLIF(SUM(F.[NET_VALUE]), 0) AS gp_pct
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1 AND F.[NET_VALUE] > 0
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) <> ''Unknown''
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]),
             COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])
),
med AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY qty)    OVER () AS med_qty,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gp_pct) OVER () AS med_gp
    FROM prod
)
SELECT
    p.product_name AS Column1,
    p.category AS Column2,
    p.qty AS Column3,
    ROUND(p.revenue, 0) AS Column4,
    ROUND(p.gp_pct, 1) AS Column5,
    CASE WHEN p.qty >= m.med_qty AND p.gp_pct >= m.med_gp THEN ''Star''
         WHEN p.qty <  m.med_qty AND p.gp_pct >= m.med_gp THEN ''Puzzle''
         WHEN p.qty >= m.med_qty AND p.gp_pct <  m.med_gp THEN ''Workhorse''
         ELSE ''Dog'' END AS Column6,
    NULL AS Column7
    /* pad Column8..Column29 as NULL AS ColumnN, exactly as ProductComparison does */
FROM prod p CROSS JOIN med m
ORDER BY p.revenue DESC;

SELECT
    N''Menu Engineering'' AS Title,
    N''Products classified by popularity (qty) and profitability (GP%)'' AS Description,
    N''Menu Item'' AS Label1, N''TEXT'' AS Type1,
    N''Category'' AS Label2, N''TEXT'' AS Type2,
    N''Qty Sold'' AS Label3, N''DECIMAL'' AS Type3,
    N''Revenue'' AS Label4, N''DECIMAL'' AS Type4,
    N''GP %'' AS Label5, N''DECIMAL'' AS Type5,
    N''Classification'' AS Label6, N''TEXT'' AS Type6,
    NULL AS Label7, NULL AS Type7
    /* pad Label8..Label29 + Type8..Type29 as NULL, exactly as ProductComparison does */;';
-- @fd = FD_MARGIN ; MERGE (Shared shape) on (N'GrowyzeMenuEngineering', N'CustomDataGrid')
```

- [ ] **Step 3 — MCP-verify** (prefixed, first SELECT only): one row per product with a `Classification` in {Star, Puzzle, Workhorse, Dog}; spot-check a high-qty high-GP item is a Star.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/49_growyze_menu_engineering.sql" "releases/v1.1/18_growyze_menu_engineering.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeMenuEngineering quadrant grid (median-split classification)"
```

---

## Phase D — Heatmap, filter, and the InvMargeBrut fix

### Task J: `GrowyzeSalesHeatmap` (HeatmapCard)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/50_growyze_sales_heatmap.sql`
- Release copy: `releases/v1.1/19_growyze_sales_heatmap.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeSalesHeatmap`/`HeatmapCard`. HeatmapCard contract = exactly `XAxisLabel` (hour), `YAxisLabel` (day name), `Value` (qty) + header SELECT. Models `OakVineMenuSalesByHour` but `Value = SUM(QUANTITY)`. **DEPENDS ON Plan 1 Task 6** — until `LINEITEM_TIMESTAMP` is populated from `createdAt`, this returns 0 rows. The mockup's "top-10 products" dimension is not a third axis (the card is 2-axis); it is available via the Products filter. `@fd = FD_MARGIN`.

- [ ] **Step 1 — Baseline** (only meaningful AFTER Plan 1 Task 6 deploy + rebuild):
```sql
SELECT COUNT(DISTINCT DATEPART(HOUR, F.LINEITEM_TIMESTAMP)) AS distinct_hours,
       COUNT(*) AS rows_with_ts
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_LINEITEM_15MIN] F
WHERE F.LINEITEM_TIMESTAMP IS NOT NULL;
```
Expected AFTER Task 6: distinct_hours ≫ 1. BEFORE Task 6: 0 (documents the dependency).

- [ ] **Step 2 — Write `50_growyze_sales_heatmap.sql`** (Shared MERGE, `@fd = FD_MARGIN`). QueryTemplate:
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT
    CAST(DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS NVARCHAR) AS XAxisLabel,
    C.[DayName] AS YAxisLabel,
    ROUND(SUM(F.[QUANTITY]), 0) AS Value
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
WHERE 1=1
AND F.[LI_TYPE] = ''PROD''
AND F.[LINEITEM_TIMESTAMP] IS NOT NULL
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]), C.[DayName], C.[DayOfWeek];

SELECT
    N''Sales Heatmap'' AS Title,
    N''Quantity sold by hour of day and day of week'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value;';
-- @fd = FD_MARGIN ; MERGE (Shared shape) on (N'GrowyzeSalesHeatmap', N'HeatmapCard')
```

- [ ] **Step 3 — MCP-verify** (prefixed, first SELECT only; run AFTER Plan 1 Task 6): rows across multiple `XAxisLabel` hours × `YAxisLabel` day names with a qty `Value`.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/50_growyze_sales_heatmap.sql" "releases/v1.1/19_growyze_sales_heatmap.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeSalesHeatmap qty by hour x day (needs Plan 1 timestamp)"
```

---

### Task K: `GrowyzeProductsCompFilter` (FilterList — Growyze-aware)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/51_growyze_productscomp_filter.sql`
- Release copy: `releases/v1.1/20_growyze_productscomp_filter.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Produces `GrowyzeProductsCompFilter`/`FilterList`. The shared `ProductsComp` FilterList hardcodes `AND [SRC] = 'int_ncraloha001'`, so it returns **empty** for Growyze orgs. Rather than mutate the shared dataset, create a Growyze-scoped comparison-products filter (`SRC = 'int_growyze001'`). FilterList requires **`OutputDefinitions`** set (the `column_mappings` + `Header1`), so this MERGE sets OutputDefinitions too (the Shared shape only covers QueryTemplate+FilterDefinitions). Plan 3 wires the Growyze dashboard's product-comparison filter to this dataset.

- [ ] **Step 1 — Baseline** (confirm Growyze products exist and NCR-scoped filter is empty for Growyze):
```sql
SELECT
 (SELECT COUNT(DISTINCT COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME])) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[datavault].[SAT_PRODUCT] WHERE [CURRENT_FLAG]=1 AND [SRC]='int_growyze001') AS growyze_products,
 (SELECT COUNT(*) FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[datavault].[SAT_PRODUCT] WHERE [CURRENT_FLAG]=1 AND [SRC]='int_ncraloha001') AS ncr_products;
```
Expected: growyze_products > 0, ncr_products = 0 (Padel is Growyze-only) — proving the shared ProductsComp is empty here.

- [ ] **Step 2 — Write `51_growyze_productscomp_filter.sql`** — full MERGE (sets QueryTemplate + FilterDefinitions + OutputDefinitions):
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT DISTINCT
    COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) AS [PRODUCT_NAME],
    CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) ELSE [PRODUCT_ID] END AS [PRODUCT_ID],
    [PARENT_ID],
    [BOTTOM_LEVEL]
FROM [datavault].[SAT_PRODUCT]
WHERE [CURRENT_FLAG] = 1
AND [SRC] = ''int_growyze001'';';
DECLARE @od NVARCHAR(MAX) = N'{"column_mappings":{"Label":"PRODUCT_NAME","ID":"PRODUCT_ID","ParentID":"PARENT_ID","BottomLevel":"BOTTOM_LEVEL"},"additional_datasets":[{"name":"Header1","type":"Header","columns":["Title"],"values":{"Title":"Comparison Products"}}]}';
DECLARE @fd NVARCHAR(MAX) = N'{}';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeProductsCompFilter', N'FilterList')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, OutputDefinitions = @od, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, OutputDefinitions, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeProductsCompFilter', N'FilterList', 1, N'LIVE', @q, @od, @fd, GETDATE(), N'plan-2026-07-10-O5');
```

- [ ] **Step 3 — MCP-verify** (prefixed): returns Growyze products with PRODUCT_NAME/PRODUCT_ID/PARENT_ID/BOTTOM_LEVEL, non-empty.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/51_growyze_productscomp_filter.sql" "releases/v1.1/20_growyze_productscomp_filter.sql" "8_VisualisationQueries.sql"
git commit -m "feat(growyze): GrowyzeProductsCompFilter FilterList (Growyze-scoped, no NCR hardcode)"
```

---

### Task L: Fix `InvMargeBrut` unbindable-filter bug (XMSE-1099)

> **Shared-dataset exception:** this is the ONE task that edits a shared (`InvMargeBrut`) dataset, justified because the card currently **hard-fails** for every org when the `InvItems` or `ProductCategories` filter is applied. It changes only `FilterDefinitions` (not the query), and only for those two keys.

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/52_invmargebrut_filter_fix.sql`
- Release copy: `releases/v1.1/21_invmargebrut_filter_fix.sql`
- Master sync: `8_VisualisationQueries.sql`

**Interfaces:** Edits `InvMargeBrut`/`CustomGroupedDataGrid`. **Root cause (grounded):** the same `@FilterClause` is injected into both the `Revenue` CTE (aliases `F`/`C`/`product`/`location` — **no `invitem`**) and the `Usage` CTE (has `invitem`). The `InvItems` and `ProductCategories` filters bind to `invitem.*`, so applying either injects `invitem.…` into `Revenue` → *Msg 4104 "multi-part identifier could not be bound"* → whole card fails. **Fix:** blank the `column` for `InvItems` and `ProductCategories` in `InvMargeBrut`'s FilterDefinitions so they don't inject (`Locations` stays — it binds in both CTEs).

- [ ] **Step 1 — Fetch current FilterDefinitions + re-confirm the exact anchors**
```sql
SELECT CAST(FilterDefinitions AS NVARCHAR(MAX)) AS fd
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName='InvMargeBrut' AND VisualizationType='CustomGroupedDataGrid' AND Status='LIVE';
```
Confirm the two entries are exactly:
`"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"}` and
`"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"}`.
If the whitespace/format differs, adjust the REPLACE anchors in Step 2 to match the fetched text.

- [ ] **Step 2 — Write `52_invmargebrut_filter_fix.sql`** (keyed, idempotent UPDATE; re-running is a no-op once blanked):
```sql
UPDATE [core].[core].[VisualisationQueries]
SET FilterDefinitions = REPLACE(REPLACE(CAST(FilterDefinitions AS NVARCHAR(MAX)),
        N'"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])"',
        N'"InvItems":{"column":""'),
        N'"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])"',
        N'"ProductCategories":{"column":""'),
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5'
WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid' AND Status = N'LIVE';

IF @@ROWCOUNT <> 1
    RAISERROR(N'Task L abort: expected exactly 1 InvMargeBrut row updated.', 16, 1);
PRINT 'Task L: InvMargeBrut InvItems/ProductCategories filters scoped out (unbindable-filter fix).';
```

- [ ] **Step 3 — MCP-verify** the two columns are now blank:
```sql
SELECT CAST(FilterDefinitions AS NVARCHAR(MAX)) AS fd
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName='InvMargeBrut' AND VisualizationType='CustomGroupedDataGrid' AND Status='LIVE';
```
Expected: `"InvItems":{"column":""...}` and `"ProductCategories":{"column":""...}`; `Locations` unchanged.

- [ ] **Step 4 — Sync master + commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/52_invmargebrut_filter_fix.sql" "releases/v1.1/21_invmargebrut_filter_fix.sql" "8_VisualisationQueries.sql"
git commit -m "fix(vis): scope InvMargeBrut InvItems/ProductCategories filters out of the unbindable Revenue CTE (XMSE-1099)"
```

---

## Verification Checklist (Plan 2 done when all true)

- [ ] `GrowyzeActiveStocktakes` returns `2 / 3` on Padel.
- [ ] `GrowyzeDeliveriesValue` returns a sane £ (Dirty now; Padel after Plan 1 Task 7 load).
- [ ] `GrowyzeAvgCostSpend` returns a small per-item £.
- [ ] `GrowyzeBestCategory` returns `<category> · <gp>%`.
- [ ] All four Menu Item Highlights return distinct real product names.
- [ ] `GrowyzeHighestVenue` / `GrowyzeLowestVenue` return venue + £.
- [ ] `GrowyzeCategoryStockTrend` returns per-category earliest/latest/delta.
- [ ] `GrowyzeMenuProfitabilityTrend` returns interleaved Margin + Cost daily series.
- [ ] `GrowyzeMenuEngineering` classifies every product into a quadrant.
- [ ] `GrowyzeSalesHeatmap` returns hour × day qty (AFTER Plan 1 Task 6).
- [ ] `GrowyzeProductsCompFilter` returns Growyze products (non-empty).
- [ ] `InvMargeBrut` no longer errors when InvItems/ProductCategories filters are applied.
- [ ] Master `8_VisualisationQueries.sql` synced in every commit; `QUERY_STATUS.md` updated.
- [ ] Deferred items (Ingredient Based Sales, Fastest Growing, transfers column, discounts series, NetSales chart variants) recorded, not silently dropped.

---

## Self-Review

- **Spec coverage:** Every mockup card slot is accounted for — reused (NetSales, OakVineMenuAvgItemValue, OakVineInvTotalCost, InvWasteCost, InvStockActivity, InvKPIGrouped, InvCOGSByCategory, InvUseAnalisys, ProductComparison), delivered by Plan 1 (Profit/Profit%/SalesByCategory/F_PURCHASES_DAY), newly built here (Tasks A–K), or explicitly Deferred with a reason (Ingredient Based Sales, Fastest Growing, transfers column, discounts, scatter component). ✓
- **Placeholder scan:** the only non-literal fill-ins are (a) the `Column7..Column29` / `Label7..29` / `Type7..29` NULL padding in the two CustomDataGrids, tied to the exact `ProductComparison` pattern, and (b) the Task E per-row Title/ORDER BY/HAVING table — both are precise instructions, not vague TODOs. ✓
- **Type/name consistency:** all column references checked against the grounding pull — `F_PRODUCT_MARGIN_DAY` (PROFIT/AVG_NET_COST/QUANTITY/NET_VALUE, no GROSS_VALUE), `F_LINEITEM_15MIN` (QUANTITY/LINEITEM_TIMESTAMP/LI_TYPE), `F_INV_COUNTS_DAY` (THEO_QTY/UOM_COST/COUNT_DATE), `F_PURCHASES_DAY` (LINE_TOTAL/ORDER_DATE), `D_LOCATION` (BOTTOM_LEVEL_NAME/BOTTOM_LOCATION_NAME), `D_INVITEM` (TOP_NAME/BOTTOM_INVITEM_NAME). Card output aliases match each card type's live contract (SingleKPICard Title/Value; CombinedChartCard XAxisLabel/LabelSort/Value/ValueSort/VisId/VisType/LegendLabel; HeatmapCard XAxisLabel/YAxisLabel/Value; CustomDataGrid Column1..29; FilterList column_mappings). ✓
- **Risk:** all new datasets are Growyze-scoped (no shared-dataset regression) except Task L, which is a flagged bug-fix on `InvMargeBrut` (FilterDefinitions only, with rollback). ✓

---

## Execution Handoff

**Plan complete and saved to `docs/plans/2026-07-10-growyze-dashboards-2-cards.md`. Two execution options:**

**1. Subagent-Driven (recommended)** — dispatch a fresh subagent per task (A–L), review between tasks, fast iteration. Fits this stack: each task is one idempotent MERGE script + a read-only MCP verification.

**2. Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints for review.

**Prerequisite for both:** Plan 1 must be deployed first (Tasks depend on `GrowyzeProfit`/`GrowyzeProfitPct`/`GrowyzeSalesByCategory`, the category sentinel, `F_PURCHASES_DAY` on Padel, and the `createdAt`→`LINEITEM_TIMESTAMP` mapping for Task J).

**Which approach?**
