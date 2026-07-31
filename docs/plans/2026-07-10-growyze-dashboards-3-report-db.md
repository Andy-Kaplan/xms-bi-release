# Growyze Dashboards — Plan 3: Report DB Wiring

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire Kati's 3-dashboard default pack (Overview / Sales & Profitability / Inventory Control) into the microservice **Report DB** for Padel Social and Dirty Sixth, so the cards built in Plans 1–2 render and are navigable in the dashboard UI.

**Architecture:** The Report DB (`report`) is an **Azure SQL Database on `xms-mssql-ne-uat`** — NOT the Managed Instance. Dashboards resolve through: `BiConfig` (org→MI DB) → `VisualisationConfig` (org card-type grant) → `VisualisationDataSetMap` (dataset→card) → `DashboardGrid`/`DashboardGridItem`/`DashboardGridFilter` (layout) → `OrganisationDashboardConfig` (names the dashboard) → `DashboardGroup` + `OrganisationDashboardGroupMapping` (navigation visibility — **load-bearing**). A dashboard renders only if its config row is joined to a visible group.

**Tech Stack:** T-SQL run **directly** against `report` (SSMS / Azure Data Studio) — the MI PowerShell runners and MCP write path do NOT reach it; the `mcp__microservice-uat__query` tool is read-only and used for verification only. Idempotent `IF NOT EXISTS` / `MERGE` on natural keys.

## Global Constraints (Report DB INSERT rules — verbatim from `docs/microservice-report-database.md` §2 + report-db-notes)

- **`TransactionId` is IDENTITY** on every dbo table — never list it in an INSERT.
- **PK `{Table}Id` defaults `NEWSEQUENTIALID()`** — never specify it, EXCEPT where we need the value downstream (grid IDs), where we set explicit constant GUIDs for stable idempotency.
- **`IsDeleted` is `bit NOT NULL` with no default** — pass `0` explicitly in every INSERT.
- **`DateCreated` / `DateUpdated` default `SYSUTCDATETIME()`** — omit on insert.
- **Every script** wraps in `SET NOCOUNT ON; SET XACT_ABORT ON; BEGIN TRANSACTION … COMMIT` with a `TRY/CATCH` rollback (per the Marge Brut reference `integrations/MargeBrut/03_margebrut_report_config.sql`).
- **`DataSet` token = `DataSetName` on MI** — must match `core.core.VisualisationQueries` exactly (case/spelling). This is the cross-system key.
- **Prerequisite:** Plans 1 **and** 2 must be deployed to the MI first — every `DataSet` wired here must resolve to a LIVE MI vis query, or the card renders empty.

---

## Target orgs (Report DB `OrganisationId` == MI DB GUID)
- Padel Social — `94A4B719-EB0F-421F-AD03-ABECDD888B14` (MI prefix `20260310`)
- Dirty Sixth — `7B50D717-124C-4902-ADD2-439A9310326A` (MI prefix `20260327`)

## Verified current state (UAT `report`, 2026-07-10)
- **`BiConfig`:** Padel `DbPrefix = 20251208` ← **WRONG, must become `20260310`** (Task 1); Dirty `20260327` ✓.
- **`VisualisationConfig`:** both orgs have card types 1,2,3,4,8,9,10,11,14. **Missing: 6 (HeatmapCard)** — granted in Task 1.
- **`DashboardGroup`:** both orgs already have an **"All Dashboards"** root group (Padel `68635668-BC52-F111-8EF3-000D3AB5729E`, Dirty `64635668-BC52-F111-8EF3-000D3AB5729E`) — reuse, don't create.
- **Existing dashboards** (both orgs, on shared grids): Cost & Margins, Stock Activity, Period Analysis, Products — **left untouched**; the pack adds 3 new dashboards additively.
- **Already-wired datasets** (both orgs — do NOT re-map): `ProductComparison`(3), `TopProducts`(3), `InvKPIGrouped`(4), `InvMargeBrut`(4), `InvCOGSByCategory`(9), `InvStockActivity`(8,11), `InvWasteCost`(10), `Locations`(14), `Products`(14), `InvItems`(14).

## Card-type reference (`VisualisationProcedure.VisualisationId`)
`1 BarChart · 2 CombinedChart · 3 CustomDataGrid · 4 CustomGroupedDataGrid · 6 Heatmap · 8 MultiLineChart · 9 PieChart · 10 SingleKPI · 11 StackedBar · 14 FilterList (no card SP)`

## Pack grid identity (fixed constant GUIDs for stable idempotency — shared by both orgs)
- Overview `B0A1D000-0001-4A00-9E00-000000000001`
- Sales & Profitability `B0A1D000-0002-4A00-9E00-000000000002`
- Inventory Control `B0A1D000-0003-4A00-9E00-000000000003`

## Release & File Structure
Report-DB scripts are **not** part of the MI `releases/v1.1/` runner set (different server, run by hand). They live in `ClaudeDevelopment/integrations/Growyze/report_config/` and are tracked in `QUERY_STATUS.md`. Deploy order = Task order (1→7).

## Self-Contained Test Pattern
Each task ends with **read-only MCP verification** via `mcp__microservice-uat__query` (`database="report"`). Writes are executed by the developer directly against `report`.

---

## Task 1: Prerequisites — fix Padel `DbPrefix` + grant HeatmapCard

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/report_config/01_prereqs_biconfig_visconfig.sql`

**Interfaces:** Corrects `BiConfig.DbPrefix` for Padel (`20251208`→`20260310`) so the microservice resolves the right MI DB; grants `VisualisationConfig` card type 6 (HeatmapCard) to both orgs (needed by `GrowyzeSalesHeatmap`). All other card types already present.

- [ ] **Step 1 — Baseline**
```sql
SELECT OrganisationId, DbPrefix FROM dbo.BiConfig WHERE OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14','7B50D717-124C-4902-ADD2-439A9310326A');
SELECT OrganisationId, VisualisationId FROM dbo.VisualisationConfig WHERE OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14','7B50D717-124C-4902-ADD2-439A9310326A') AND VisualisationId = 6 AND IsDeleted = 0;
```
Expected before: Padel `20251208`; no VisualisationId=6 rows.

- [ ] **Step 2 — Write `01_prereqs_biconfig_visconfig.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    -- 1a. Fix Padel DbPrefix (was 20251208, copied from DEV GrowyzeDev)
    UPDATE dbo.BiConfig
    SET DbPrefix = N'20260310', DateUpdated = SYSUTCDATETIME()
    WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
      AND IsDeleted = 0 AND DbPrefix <> N'20260310';

    -- 1b. Grant HeatmapCard (6) to both orgs
    DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER);
    INSERT INTO @Orgs VALUES ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),('7B50D717-124C-4902-ADD2-439A9310326A');
    INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, IsDeleted)
    SELECT o.OrganisationId, 6, SYSUTCDATETIME(), 0
    FROM @Orgs o
    WHERE NOT EXISTS (SELECT 1 FROM dbo.VisualisationConfig vc
        WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = 6 AND vc.IsDeleted = 0);

    COMMIT TRANSACTION;
    PRINT 'Task 1: BiConfig fixed + HeatmapCard granted.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```

- [ ] **Step 3 — MCP-verify:** Padel `DbPrefix = 20260310`; both orgs now have VisualisationId=6.

---

## Task 2: Dataset wiring (`VisualisationDataSetMap`) — both orgs

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/report_config/02_dataset_map.sql`

**Interfaces:** Adds the pack datasets NOT already wired, for both orgs, joined to the matching `VisualisationConfig` row by card type. Depends on Task 1 (HeatmapCard config for `GrowyzeSalesHeatmap`). Already-wired datasets (see current state) are intentionally omitted.

- [ ] **Step 1 — Baseline** (confirm the new datasets are absent):
```sql
SELECT vc.OrganisationId, vdsm.DataSet FROM dbo.VisualisationDataSetMap vdsm
JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = vdsm.VisualisationConfigId
WHERE vc.OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14','7B50D717-124C-4902-ADD2-439A9310326A')
AND vdsm.DataSet LIKE 'Growyze%' AND vdsm.IsDeleted = 0;
```
Expected before: no rows.

- [ ] **Step 2 — Write `02_dataset_map.sql`** (both orgs × the dataset/cardtype set below; idempotent `WHERE NOT EXISTS`):
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER);
    INSERT INTO @Orgs VALUES ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),('7B50D717-124C-4902-ADD2-439A9310326A');

    DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
    INSERT INTO @DataSets VALUES
        -- SingleKPICard (10)
        (N'NetSales', 10), (N'OakVineMenuAvgItemValue', 10), (N'OakVineInvTotalCost', 10),
        (N'GrowyzeProfit', 10), (N'GrowyzeProfitPct', 10), (N'GrowyzeActiveStocktakes', 10),
        (N'GrowyzeDeliveriesValue', 10), (N'GrowyzeAvgCostSpend', 10), (N'GrowyzeBestCategory', 10),
        (N'GrowyzeTopRevenueItem', 10), (N'GrowyzeHighestGPItem', 10), (N'GrowyzeMostSoldItem', 10),
        (N'GrowyzeLowestItem', 10), (N'GrowyzeHighestVenue', 10), (N'GrowyzeLowestVenue', 10),
        -- PieChartCard (9)
        (N'GrowyzeSalesByCategory', 9),
        -- CombinedChartCard (2)
        (N'GrowyzeMenuProfitabilityTrend', 2),
        -- CustomDataGrid (3)
        (N'GrowyzeCategoryStockTrend', 3), (N'GrowyzeMenuEngineering', 3), (N'InvUseAnalisys', 3),
        -- HeatmapCard (6)
        (N'GrowyzeSalesHeatmap', 6),
        -- FilterList (14)
        (N'GrowyzeProductsCompFilter', 14);

    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    SELECT vc.VisualisationConfigId, ds.DataSet, 0
    FROM @Orgs o
    JOIN @DataSets ds ON 1=1
    JOIN dbo.VisualisationConfig vc
        ON vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = ds.VisualisationId AND vc.IsDeleted = 0
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.VisualisationDataSetMap m
        WHERE m.VisualisationConfigId = vc.VisualisationConfigId AND m.DataSet = ds.DataSet AND m.IsDeleted = 0);

    COMMIT TRANSACTION;
    PRINT 'Task 2: pack datasets wired for both orgs.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```
> **Note:** `InvUseAnalisys` is spelled with the existing misspelling (must match the MI `DataSetName` exactly).

- [ ] **Step 3 — MCP-verify:** each `Growyze*` dataset + `NetSales`/`OakVine*`/`InvUseAnalisys` now has a row for BOTH orgs (44 new rows = 22 datasets × 2 orgs, minus any already present).

---

## Task 3: Grids, dashboard configs, and group mappings (structure)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/report_config/03_grids_configs_groups.sql`

**Interfaces:** Creates the 3 shared pack grids (fixed GUIDs), 6 `OrganisationDashboardConfig` rows (3 dashboards × 2 orgs) pointing at them, and maps all 6 into each org's existing "All Dashboards" group. Produces the grid IDs that Tasks 4–6 populate with items/filters. **No `DashboardGroup` creation** — reuse existing.

- [ ] **Step 1 — Write `03_grids_configs_groups.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @G_Overview  UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';
    DECLARE @G_Sales     UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';
    DECLARE @G_Inventory UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';

    -- 3a. Grids (shared; fixed GUIDs)
    DECLARE @Grids TABLE (DashboardGridId UNIQUEIDENTIFIER);
    INSERT INTO @Grids VALUES (@G_Overview),(@G_Sales),(@G_Inventory);
    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    SELECT g.DashboardGridId, 1, 2, 12, 0 FROM @Grids g
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DashboardGrid d WHERE d.DashboardGridId = g.DashboardGridId);

    -- 3b. OrganisationDashboardConfig (3 dashboards x 2 orgs). SortOrder 10/11/12 to sit after existing.
    DECLARE @Cfg TABLE (OrganisationId UNIQUEIDENTIFIER, DashboardGridId UNIQUEIDENTIFIER, Name NVARCHAR(256), IconName NVARCHAR(254), SortOrder INT);
    INSERT INTO @Cfg VALUES
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14', @G_Overview,  N'Overview',                N'Dashboard',  10),
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14', @G_Sales,     N'Sales & Profitability',   N'TrendingUp', 11),
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14', @G_Inventory, N'Inventory Control',       N'Inventory',  12),
        ('7B50D717-124C-4902-ADD2-439A9310326A', @G_Overview,  N'Overview',                N'Dashboard',  10),
        ('7B50D717-124C-4902-ADD2-439A9310326A', @G_Sales,     N'Sales & Profitability',   N'TrendingUp', 11),
        ('7B50D717-124C-4902-ADD2-439A9310326A', @G_Inventory, N'Inventory Control',       N'Inventory',  12);
    INSERT INTO dbo.OrganisationDashboardConfig (DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted)
    SELECT c.DashboardGridId, c.OrganisationId, c.Name, c.IconName, c.SortOrder, 0
    FROM @Cfg c
    WHERE NOT EXISTS (SELECT 1 FROM dbo.OrganisationDashboardConfig o
        WHERE o.OrganisationId = c.OrganisationId AND o.Name = c.Name AND o.IsDeleted = 0);

    -- 3c. Map the 3 new configs per org into that org's existing "All Dashboards" group
    MERGE INTO dbo.OrganisationDashboardGroupMapping AS tgt
    USING (
        SELECT g.DashboardGroupId, odc.OrganisationDashboardConfigId
        FROM dbo.OrganisationDashboardConfig odc
        JOIN dbo.DashboardGroup g
            ON g.OrganisationId = odc.OrganisationId AND g.Name = N'All Dashboards'
            AND g.ParentDashboardGroupId IS NULL AND g.StaffId IS NULL AND g.IsDeleted = 0
        WHERE odc.OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14','7B50D717-124C-4902-ADD2-439A9310326A')
          AND odc.Name IN (N'Overview', N'Sales & Profitability', N'Inventory Control')
          AND odc.IsDeleted = 0
    ) AS src
        ON tgt.DashboardGroupId = src.DashboardGroupId AND tgt.OrganisationDashboardConfigId = src.OrganisationDashboardConfigId
    WHEN MATCHED AND tgt.IsDeleted = 1 THEN UPDATE SET IsDeleted = 0, DateUpdated = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (DashboardGroupId, OrganisationDashboardConfigId, IsDeleted)
        VALUES (src.DashboardGroupId, src.OrganisationDashboardConfigId, 0);

    COMMIT TRANSACTION;
    PRINT 'Task 3: grids + configs + group mappings created.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```

- [ ] **Step 2 — MCP-verify:** 3 grids exist; 6 new `OrganisationDashboardConfig` rows; each maps into the right "All Dashboards" group (0 unmapped — see Task 7).

---

## Task 4: Overview dashboard — items + filters

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/report_config/04_items_overview.sql`

**Interfaces:** Populates grid `B0A1D000-0001-…` (shared). Layout: 7 KPIs (md=3) → stock-value-over-time MultiLine (md=12) → category-stock-trend grid (md=12). Filters: Locations, InvItems.

- [ ] **Step 1 — Write `04_items_overview.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';

    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT, ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items VALUES
        (10, N'NetSales',                  1, 12, 6, 3, 3, 3),
        (10, N'GrowyzeProfit',             2, 12, 6, 3, 3, 3),
        (10, N'GrowyzeProfitPct',          3, 12, 6, 3, 3, 3),
        (10, N'OakVineInvTotalCost',       4, 12, 6, 3, 3, 3),
        (10, N'GrowyzeActiveStocktakes',   5, 12, 6, 3, 3, 3),
        (10, N'GrowyzeDeliveriesValue',    6, 12, 6, 3, 3, 3),
        (10, N'InvWasteCost',              7, 12, 6, 3, 3, 3),
        ( 8, N'InvStockActivity',          8, 12,12,12,12,12),
        ( 3, N'GrowyzeCategoryStockTrend', 9, 12,12,12,12,12);
    INSERT INTO dbo.DashboardGridItem (DashboardGridId, VisualisationId, DataSet, SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
    SELECT @Grid, i.VisualisationId, i.DataSet, i.SortOrder, i.ExtraSmall, i.Small, i.Medium, i.Large, i.ExtraLarge, 0
    FROM @Items i
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem d
        WHERE d.DashboardGridId = @Grid AND d.DataSet = i.DataSet AND d.VisualisationId = i.VisualisationId AND d.IsDeleted = 0);

    DECLARE @Filters TABLE (DataSet NVARCHAR(1024), SortOrder INT);
    INSERT INTO @Filters VALUES (N'Locations', 1), (N'InvItems', 2);
    INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, SortOrder, IsDeleted)
    SELECT @Grid, f.DataSet, f.SortOrder, 0 FROM @Filters f
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DashboardGridFilter d
        WHERE d.DashboardGridId = @Grid AND d.DataSet = f.DataSet AND d.IsDeleted = 0);

    COMMIT TRANSACTION;
    PRINT 'Task 4: Overview items + filters placed.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```

- [ ] **Step 2 — MCP-verify:** 9 items + 2 filters on the Overview grid.

---

## Task 5: Sales & Profitability dashboard — items + filters

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/report_config/05_items_sales.sql`

**Interfaces:** Populates grid `B0A1D000-0002-…`. Layout: 6 KPIs (md=2) → 4 Menu-Item-Highlight KPIs (md=3) → SalesByCategory pie (md=5) + ProductComparison grid (md=7) → MenuProfitabilityTrend combined (md=12) → MenuEngineering grid (md=12) → SalesHeatmap (md=12). Filters: Locations, Products, GrowyzeProductsCompFilter.

- [ ] **Step 1 — Write `05_items_sales.sql`** (same shape as Task 4; item table):
```sql
    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';
    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT, ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items VALUES
        (10, N'NetSales',                       1, 12, 6, 2, 2, 2),
        (10, N'GrowyzeProfit',                  2, 12, 6, 2, 2, 2),
        (10, N'GrowyzeProfitPct',               3, 12, 6, 2, 2, 2),
        (10, N'OakVineMenuAvgItemValue',        4, 12, 6, 2, 2, 2),
        (10, N'GrowyzeAvgCostSpend',            5, 12, 6, 2, 2, 2),
        (10, N'GrowyzeBestCategory',            6, 12, 6, 2, 2, 2),
        (10, N'GrowyzeTopRevenueItem',          7, 12, 6, 3, 3, 3),
        (10, N'GrowyzeHighestGPItem',           8, 12, 6, 3, 3, 3),
        (10, N'GrowyzeMostSoldItem',            9, 12, 6, 3, 3, 3),
        (10, N'GrowyzeLowestItem',             10, 12, 6, 3, 3, 3),
        ( 9, N'GrowyzeSalesByCategory',        11, 12,12, 5, 5, 5),
        ( 3, N'ProductComparison',             12, 12,12, 7, 7, 7),
        ( 2, N'GrowyzeMenuProfitabilityTrend', 13, 12,12,12,12,12),
        ( 3, N'GrowyzeMenuEngineering',        14, 12,12,12,12,12),
        ( 6, N'GrowyzeSalesHeatmap',           15, 12,12,12,12,12);
    -- INSERT ... DashboardGridItem with the same NOT EXISTS guard as Task 4
    -- Filters: (N'Locations',1),(N'Products',2),(N'GrowyzeProductsCompFilter',3) -> DashboardGridFilter, same guard
```
Wrap in the same `SET NOCOUNT/XACT_ABORT` + `TRY/CATCH` transaction as Task 4, with both the `DashboardGridItem` insert and the `DashboardGridFilter` insert.

- [ ] **Step 2 — MCP-verify:** 15 items + 3 filters on the Sales grid.

---

## Task 6: Inventory Control dashboard — items + filters

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/report_config/06_items_inventory.sql`

**Interfaces:** Populates grid `B0A1D000-0003-…`. Layout: 4 KPIs (md=3) → StockActivity stacked-bar (md=12) → Highest/Lowest venue KPIs (md=6 each) → InvKPIGrouped grid (md=12) → InvCOGSByCategory pie (md=6) + InvUseAnalisys grid (md=6). Filters: Locations, InvItems.

- [ ] **Step 1 — Write `06_items_inventory.sql`** (same shape; item table):
```sql
    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';
    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT, ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items VALUES
        (10, N'OakVineInvTotalCost',     1, 12, 6, 3, 3, 3),
        (10, N'GrowyzeActiveStocktakes', 2, 12, 6, 3, 3, 3),
        (10, N'GrowyzeDeliveriesValue',  3, 12, 6, 3, 3, 3),
        (10, N'InvWasteCost',            4, 12, 6, 3, 3, 3),
        (11, N'InvStockActivity',        5, 12,12,12,12,12),
        (10, N'GrowyzeHighestVenue',     6, 12, 6, 6, 6, 6),
        (10, N'GrowyzeLowestVenue',      7, 12, 6, 6, 6, 6),
        ( 4, N'InvKPIGrouped',           8, 12,12,12,12,12),
        ( 9, N'InvCOGSByCategory',       9, 12,12, 6, 6, 6),
        ( 3, N'InvUseAnalisys',         10, 12,12, 6, 6, 6);
    -- INSERT ... DashboardGridItem with the NOT EXISTS guard
    -- Filters: (N'Locations',1),(N'InvItems',2) -> DashboardGridFilter, same guard
```
Wrap identically to Tasks 4–5.

> **Note — `InvStockActivity` appears on both Overview (as MultiLine=8) and Inventory (as StackedBar=11).** These are two distinct LIVE vis-query rows for the same `DataSetName`; the `DashboardGridItem` uniqueness guard is per (grid, dataset, **VisualisationId**), so both placements coexist and each org's `VisualisationDataSetMap` already maps `InvStockActivity` under both 8 and 11.

- [ ] **Step 2 — MCP-verify:** 10 items + 2 filters on the Inventory grid.

---

## Task 7: End-to-end render verification

**Files:** verification only (no new script).

- [ ] **Step 1 — No ungrouped configs (both orgs)** — the O13 failure mode:
```sql
SELECT odc.OrganisationId, odc.Name
FROM dbo.OrganisationDashboardConfig odc
WHERE odc.OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14','7B50D717-124C-4902-ADD2-439A9310326A')
  AND odc.IsDeleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
    JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId AND g.IsDeleted = 0
    WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId AND m.IsDeleted = 0);
```
Expected: **0 rows**.

- [ ] **Step 2 — Every grid item's dataset is granted to each org**:
```sql
SELECT DISTINCT o.OrganisationId, dgi.DataSet, dgi.VisualisationId
FROM dbo.DashboardGridItem dgi
CROSS JOIN (VALUES ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),('7B50D717-124C-4902-ADD2-439A9310326A')) o(OrganisationId)
WHERE dgi.DashboardGridId IN ('B0A1D000-0001-4A00-9E00-000000000001','B0A1D000-0002-4A00-9E00-000000000002','B0A1D000-0003-4A00-9E00-000000000003')
  AND dgi.IsDeleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap m
    JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
    WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = dgi.VisualisationId
      AND m.DataSet = dgi.DataSet AND m.IsDeleted = 0 AND vc.IsDeleted = 0);
```
Expected: **0 rows** (every placed card is granted for both orgs).

- [ ] **Step 3 — BiConfig correct**: Padel `DbPrefix = 20260310`, Dirty `20260327`.

- [ ] **Step 4 — Front-end smoke test** (developer): open the dashboard UI as each org — Overview / Sales & Profitability / Inventory Control appear in the nav and every card loads (KPIs show numbers, grids show rows, the heatmap shows hour×day, the pie shows the real category set). Record any empty card → trace to a missing MI vis query (Plan 1/2 not deployed) or a `DataSet` name mismatch.

---

## Verification Checklist (Plan 3 done when all true)
- [ ] Padel `BiConfig.DbPrefix = 20260310`; HeatmapCard (6) granted to both orgs.
- [ ] All pack datasets wired in `VisualisationDataSetMap` for both orgs (Task 7 Step 2 returns 0).
- [ ] 3 grids + 6 configs created; 0 ungrouped configs (Task 7 Step 1 returns 0).
- [ ] Overview (9 items/2 filters), Sales (15/3), Inventory (10/2) populated.
- [ ] Front-end shows all 3 dashboards for both orgs with cards rendering.
- [ ] `QUERY_STATUS.md` updated; existing 4 dashboards untouched.

## Rollback
- Soft-delete the additions: `UPDATE … SET IsDeleted = 1` on the new `OrganisationDashboardGroupMapping`, `OrganisationDashboardConfig`, `DashboardGridItem`, `DashboardGridFilter`, `DashboardGrid` rows (by the fixed grid GUIDs / dashboard names) and the new `VisualisationDataSetMap` rows. Revert `BiConfig.DbPrefix` only if it regresses (it was already wrong). The existing 4 dashboards and shared datasets are untouched, so rollback is contained to the pack.

---

## Self-Review
- **Spec coverage:** every mockup card maps to a placed item (reused, Plan-1/2-built, or here-wired) or a documented deferral (Ingredient Based Sales, Fastest-Growing, transfers, discounts). All 3 dashboards + navigation covered for both orgs. ✓
- **Placeholder scan:** Tasks 5–6 give the full item/filter tables and reference Task 4's exact INSERT+guard shape rather than repeating it verbatim — a precise back-reference, not a TODO. ✓
- **Consistency:** `DataSet` tokens match the MI `DataSetName`s from Plans 1–2 and the verified already-wired names (incl. the `InvUseAnalisys` misspelling); `VisualisationId`s match `VisualisationProcedure`; org GUIDs and the existing "All Dashboards" group IDs are the live UAT values. ✓
- **Risk:** additive only — new shared grids + new per-org configs mapped into the existing group; existing dashboards and shared datasets untouched. The one UPDATE (Padel `DbPrefix`) is a correctness fix. ✓

## Execution Handoff
**Plan complete and saved to `docs/plans/2026-07-10-growyze-dashboards-3-report-db.md`.** Prerequisite: Plans 1 & 2 deployed to the MI (every wired `DataSet` must resolve to a LIVE vis query). Report-DB scripts run **directly against `report` on `xms-mssql-ne-uat`** (not the MI runners; MCP is read-only verification).

Two execution options: **1. Subagent-Driven** (a subagent per task, review between) or **2. Inline** (executing-plans, batched with checkpoints). Which approach?
