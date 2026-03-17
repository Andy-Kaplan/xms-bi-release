# Growyze Report DB Visualisations — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure the DEV microservice report database so the GrowyzeDev organisation can render 18 inventory visualisation cards across 3 dashboards (Cost & Margins, Stock Activity, Period Analysis).

**Architecture:** The microservice `report` database on `xms-mssql-ne-dev` is a configuration store — no analytical data. We INSERT rows into 7 tables that wire the GrowyzeDev org to its MI database, grant card type access, map datasets, define dashboard grids, place cards, add filters, and name the dashboards. All writes are SQL scripts in `ClaudeDevelopment/` executed by the developer against the `report` database on the dev microservice Azure SQL server.

**Tech Stack:** SQL Server (Azure SQL Database), MCP read-only queries for verification.

---

## Background & Key References

### Environment
- **Target:** DEV microservice Azure SQL server → `report` database
- **MCP tool:** `mcp__microservice-dev__query` with `database: 'report'` — **read-only verification only**
- **MI org:** GrowyzeDev, OrganisationCode `94A4B719-EB0F-421F-AD03-ABECDD888B14`, DbPrefix `20251208`
- **MI database:** `20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`

### Report DB Schema Conventions
Every dbo table follows this pattern:
- PK: `{Table}Id` — `uniqueidentifier DEFAULT NEWSEQUENTIALID()`
- `TransactionId` — `bigint IDENTITY`, clustered index, auto-incremented by SQL Server. **Do NOT include in INSERT statements** — omit from column lists entirely.
- `IsDeleted` — `bit DEFAULT 0`
- `DateCreated` / `DateUpdated` — `datetime2 DEFAULT SYSUTCDATETIME()`
- Triggers auto-maintain `DateUpdated` and write to `Audit.{Table}`

### Current Max TransactionIds (as of 2026-03-11)
| Table | Max TransactionId |
|---|---|
| BiConfig | 4 |
| VisualisationConfig | 50 |
| VisualisationDataSetMap | 152 |
| DashboardGrid | 14 |
| DashboardGridItem | 80 |
| DashboardGridFilter | 53 |
| OrganisationDashboardConfig | 17 |

**Important:** Do NOT hardcode TransactionId values. Always use the subquery pattern `(SELECT ISNULL(MAX(TransactionId),0)+N FROM dbo.{Table})` to avoid collisions if other rows are added between now and execution.

### Idempotency Pattern
Use `IF NOT EXISTS` checks before each INSERT so the script can be safely re-run:
```sql
IF NOT EXISTS (SELECT 1 FROM dbo.BiConfig WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14' AND IsDeleted = 0)
BEGIN
    INSERT INTO dbo.BiConfig (TransactionId, OrganisationId, DbPrefix)
    VALUES ((SELECT ISNULL(MAX(TransactionId),0)+1 FROM dbo.BiConfig), '94A4B719-...', '20251208');
END
```

### Dashboard Design (3 dashboards, 18 cards, 6 filters)

**Dashboard 1 — "Cost & Margins" (5 cards)**
| Sort | DataSet | VisualisationId | Card Type | xs | md | lg |
|---|---|---|---|---|---|---|
| 1 | InvCOGSByCategory | 9 | PieChartCard | 12 | 6 | 6 |
| 2 | InvCOGSByCategory | 11 | StackedBarChartCard | 12 | 6 | 6 |
| 3 | InvMarginTrend | 8 | MultiLineChartCard | 12 | 12 | 12 |
| 4 | InvMargeBrut | 4 | CustomGroupedDataGrid | 12 | 12 | 12 |
| 5 | InvTheoVsActualGP | 2 | CombinedChartCard | 12 | 12 | 12 |

**Dashboard 2 — "Stock Activity" (7 cards)**
| Sort | DataSet | VisualisationId | Card Type | xs | md | lg |
|---|---|---|---|---|---|---|
| 1 | InvConsumption | 1 | BarChartCard | 12 | 6 | 6 |
| 2 | InvConsumption | 3 | CustomDataGrid | 12 | 6 | 6 |
| 3 | InvWasteAnalysis | 1 | BarChartCard | 12 | 6 | 6 |
| 4 | InvWasteAnalysis | 8 | MultiLineChartCard | 12 | 6 | 6 |
| 5 | InvWasteAnalysis | 3 | CustomDataGrid | 12 | 12 | 12 |
| 6 | InvStockActivity | 11 | StackedBarChartCard | 12 | 6 | 6 |
| 7 | InvStockActivity | 8 | MultiLineChartCard | 12 | 6 | 6 |

**Dashboard 3 — "Period Analysis" (6 cards)**
| Sort | DataSet | VisualisationId | Card Type | xs | md | lg |
|---|---|---|---|---|---|---|
| 1 | InvWeeklySummary | 2 | CombinedChartCard | 12 | 12 | 12 |
| 2 | InvWeeklySummary | 3 | CustomDataGrid | 12 | 12 | 12 |
| 3 | InvPeriodCompWoW | 2 | CombinedChartCard | 12 | 4 | 4 |
| 4 | InvPeriodCompMoM | 2 | CombinedChartCard | 12 | 4 | 4 |
| 5 | InvPeriodCompYoY | 2 | CombinedChartCard | 12 | 4 | 4 |
| 6 | InvVarianceCategory | 11 | StackedBarChartCard | 12 | 12 | 12 |

**All 3 dashboards get filters:** Locations (sort 1), InvItems (sort 2).

---

## Chunk 1: Script Creation

### Task 1: Create the deployment SQL script

**Files:**
- Create: `ClaudeDevelopment/Deploy/growyze_report_db_dev.sql`

The entire deployment is a single SQL script with 7 clearly labelled sections, wrapped in a transaction. The developer runs this against the `report` database on the dev microservice server.

- [ ] **Step 1: Write Section 1 — BiConfig**

Add one row mapping GrowyzeDev to its MI database.

```sql
----------------------------------------------------------------------
-- Growyze Report DB Configuration — DEV Microservice
-- Target: report database on xms-mssql-ne-dev
-- Run as: Single script, entire file
----------------------------------------------------------------------

BEGIN TRANSACTION;
BEGIN TRY

DECLARE @OrgId UNIQUEIDENTIFIER = '94A4B719-EB0F-421F-AD03-ABECDD888B14';
DECLARE @DbPrefix NVARCHAR(8) = N'20251208';

----------------------------------------------------------------------
-- 1. BiConfig — org-to-MI-database mapping
----------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM dbo.BiConfig
    WHERE OrganisationId = @OrgId AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.BiConfig (TransactionId, OrganisationId, DbPrefix)
    VALUES (
        (SELECT ISNULL(MAX(TransactionId),0)+1 FROM dbo.BiConfig),
        @OrgId,
        @DbPrefix
    );
    PRINT 'BiConfig: inserted GrowyzeDev';
END
ELSE
    PRINT 'BiConfig: GrowyzeDev already exists, skipped';
```

- [ ] **Step 2: Write Section 2 — VisualisationConfig (8 card types)**

Grant GrowyzeDev access to 7 chart card types + FilterList. Use a table-valued constructor to loop through all 8, inserting only those that don't already exist.

```sql
----------------------------------------------------------------------
-- 2. VisualisationConfig — grant card type access
----------------------------------------------------------------------
DECLARE @VisTypes TABLE (VisualisationId INT);
INSERT INTO @VisTypes VALUES (1),(2),(3),(4),(8),(9),(11),(14);

INSERT INTO dbo.VisualisationConfig (TransactionId, OrganisationId, VisualisationId, ActiveFrom)
SELECT
    (SELECT ISNULL(MAX(TransactionId),0) FROM dbo.VisualisationConfig) + ROW_NUMBER() OVER (ORDER BY vt.VisualisationId),
    @OrgId,
    vt.VisualisationId,
    SYSUTCDATETIME()
FROM @VisTypes vt
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationConfig vc
    WHERE vc.OrganisationId = @OrgId
      AND vc.VisualisationId = vt.VisualisationId
      AND vc.IsDeleted = 0
);

PRINT 'VisualisationConfig: granted card type access';
```

- [ ] **Step 3: Write Section 3 — VisualisationDataSetMap (20 dataset mappings)**

Wire each of the 18 chart datasets + 2 filter datasets to their corresponding VisualisationConfig row. The FK is `VisualisationConfigId`, looked up by org + card type.

```sql
----------------------------------------------------------------------
-- 3. VisualisationDataSetMap — wire datasets to card types
----------------------------------------------------------------------
DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @DataSets VALUES
    (N'InvCOGSByCategory',  9),
    (N'InvCOGSByCategory', 11),
    (N'InvConsumption',      1),
    (N'InvConsumption',      3),
    (N'InvWasteAnalysis',    1),
    (N'InvWasteAnalysis',    8),
    (N'InvWasteAnalysis',    3),
    (N'InvMarginTrend',      8),
    (N'InvMargeBrut',        4),
    (N'InvWeeklySummary',    2),
    (N'InvWeeklySummary',    3),
    (N'InvStockActivity',   11),
    (N'InvStockActivity',    8),
    (N'InvPeriodCompWoW',    2),
    (N'InvPeriodCompMoM',    2),
    (N'InvPeriodCompYoY',    2),
    (N'InvVarianceCategory',11),
    (N'InvTheoVsActualGP',  2),
    (N'Locations',          14),
    (N'InvItems',           14);

INSERT INTO dbo.VisualisationDataSetMap (TransactionId, VisualisationConfigId, DataSet)
SELECT
    (SELECT ISNULL(MAX(TransactionId),0) FROM dbo.VisualisationDataSetMap) + ROW_NUMBER() OVER (ORDER BY ds.DataSet, ds.VisualisationId),
    vc.VisualisationConfigId,
    ds.DataSet
FROM @DataSets ds
INNER JOIN dbo.VisualisationConfig vc
    ON vc.OrganisationId = @OrgId
   AND vc.VisualisationId = ds.VisualisationId
   AND vc.IsDeleted = 0
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap vdsm
    WHERE vdsm.VisualisationConfigId = vc.VisualisationConfigId
      AND vdsm.DataSet = ds.DataSet
      AND vdsm.IsDeleted = 0
);

PRINT 'VisualisationDataSetMap: wired datasets';
```

- [ ] **Step 4: Write Section 4 — DashboardGrid (3 grids)**

Create 3 new grid containers. Declare variables to hold their IDs for use in later sections.

```sql
----------------------------------------------------------------------
-- 4. DashboardGrid — 3 new grids
----------------------------------------------------------------------
DECLARE @GridA UNIQUEIDENTIFIER = NEWID();
DECLARE @GridB UNIQUEIDENTIFIER = NEWID();
DECLARE @GridC UNIQUEIDENTIFIER = NEWID();

-- Only insert if GrowyzeDev doesn't already have dashboard configs
-- (presence of OrganisationDashboardConfig rows = grids already created)
IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.DashboardGrid (DashboardGridId, TransactionId, Container, Spacing, Columns)
    VALUES
        (@GridA, (SELECT ISNULL(MAX(TransactionId),0)+1 FROM dbo.DashboardGrid), 1, 2, 12),
        (@GridB, (SELECT ISNULL(MAX(TransactionId),0)+2 FROM dbo.DashboardGrid), 1, 2, 12),
        (@GridC, (SELECT ISNULL(MAX(TransactionId),0)+3 FROM dbo.DashboardGrid), 1, 2, 12);

    PRINT 'DashboardGrid: created 3 grids';
END
ELSE
BEGIN
    -- If re-running, look up existing grid IDs from OrganisationDashboardConfig
    SELECT @GridA = DashboardGridId FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Cost & Margins' AND IsDeleted = 0;

    SELECT @GridB = DashboardGridId FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Stock Activity' AND IsDeleted = 0;

    SELECT @GridC = DashboardGridId FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Period Analysis' AND IsDeleted = 0;

    PRINT 'DashboardGrid: grids already exist, using existing IDs';
END
```

- [ ] **Step 5: Write Section 5 — DashboardGridItem (18 cards)**

Place all 18 cards across the 3 grids with responsive breakpoints.

```sql
----------------------------------------------------------------------
-- 5. DashboardGridItem — place cards on grids
----------------------------------------------------------------------
DECLARE @Items TABLE (
    GridId UNIQUEIDENTIFIER,
    VisualisationId INT,
    DataSet NVARCHAR(1024),
    SortOrder INT,
    ExtraSmall INT,
    Small INT,
    Medium INT,
    Large INT,
    ExtraLarge INT
);

-- Grid A: Cost & Margins (5 cards)
INSERT INTO @Items VALUES
    (@GridA,  9, N'InvCOGSByCategory',   1, 12, 12, 6, 6, 6),
    (@GridA, 11, N'InvCOGSByCategory',   2, 12, 12, 6, 6, 6),
    (@GridA,  8, N'InvMarginTrend',      3, 12, 12, 12, 12, 12),
    (@GridA,  4, N'InvMargeBrut',        4, 12, 12, 12, 12, 12),
    (@GridA,  2, N'InvTheoVsActualGP',   5, 12, 12, 12, 12, 12);

-- Grid B: Stock Activity (7 cards)
INSERT INTO @Items VALUES
    (@GridB,  1, N'InvConsumption',      1, 12, 12, 6, 6, 6),
    (@GridB,  3, N'InvConsumption',      2, 12, 12, 6, 6, 6),
    (@GridB,  1, N'InvWasteAnalysis',    3, 12, 12, 6, 6, 6),
    (@GridB,  8, N'InvWasteAnalysis',    4, 12, 12, 6, 6, 6),
    (@GridB,  3, N'InvWasteAnalysis',    5, 12, 12, 12, 12, 12),
    (@GridB, 11, N'InvStockActivity',    6, 12, 12, 6, 6, 6),
    (@GridB,  8, N'InvStockActivity',    7, 12, 12, 6, 6, 6);

-- Grid C: Period Analysis (6 cards)
INSERT INTO @Items VALUES
    (@GridC,  2, N'InvWeeklySummary',    1, 12, 12, 12, 12, 12),
    (@GridC,  3, N'InvWeeklySummary',    2, 12, 12, 12, 12, 12),
    (@GridC,  2, N'InvPeriodCompWoW',    3, 12, 12, 4, 4, 4),
    (@GridC,  2, N'InvPeriodCompMoM',    4, 12, 12, 4, 4, 4),
    (@GridC,  2, N'InvPeriodCompYoY',    5, 12, 12, 4, 4, 4),
    (@GridC, 11, N'InvVarianceCategory', 6, 12, 12, 12, 12, 12);

INSERT INTO dbo.DashboardGridItem (
    TransactionId, DashboardGridId, VisualisationId, DataSet,
    SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge
)
SELECT
    (SELECT ISNULL(MAX(TransactionId),0) FROM dbo.DashboardGridItem) + ROW_NUMBER() OVER (ORDER BY i.GridId, i.SortOrder),
    i.GridId,
    i.VisualisationId,
    i.DataSet,
    i.SortOrder,
    i.ExtraSmall,
    i.Small,
    i.Medium,
    i.Large,
    i.ExtraLarge
FROM @Items i
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem dgi
    WHERE dgi.DashboardGridId = i.GridId
      AND dgi.DataSet = i.DataSet
      AND dgi.VisualisationId = i.VisualisationId
      AND dgi.IsDeleted = 0
);

PRINT 'DashboardGridItem: placed 18 cards';
```

- [ ] **Step 6: Write Section 6 — DashboardGridFilter (6 filters)**

Add Locations and InvItems filter widgets to each grid.

```sql
----------------------------------------------------------------------
-- 6. DashboardGridFilter — filter widgets
----------------------------------------------------------------------
DECLARE @Filters TABLE (GridId UNIQUEIDENTIFIER, DataSet NVARCHAR(1024), SortOrder INT);
INSERT INTO @Filters VALUES
    (@GridA, N'Locations', 1), (@GridA, N'InvItems', 2),
    (@GridB, N'Locations', 1), (@GridB, N'InvItems', 2),
    (@GridC, N'Locations', 1), (@GridC, N'InvItems', 2);

INSERT INTO dbo.DashboardGridFilter (TransactionId, DashboardGridId, DataSet, SortOrder)
SELECT
    (SELECT ISNULL(MAX(TransactionId),0) FROM dbo.DashboardGridFilter) + ROW_NUMBER() OVER (ORDER BY f.GridId, f.SortOrder),
    f.GridId,
    f.DataSet,
    f.SortOrder
FROM @Filters f
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter dgf
    WHERE dgf.DashboardGridId = f.GridId
      AND dgf.DataSet = f.DataSet
      AND dgf.IsDeleted = 0
);

PRINT 'DashboardGridFilter: added 6 filters';
```

- [ ] **Step 7: Write Section 7 — OrganisationDashboardConfig + Transaction close**

Link grids to GrowyzeDev org with dashboard names and close the transaction.

```sql
----------------------------------------------------------------------
-- 7. OrganisationDashboardConfig — name and link dashboards
----------------------------------------------------------------------
DECLARE @Dashboards TABLE (GridId UNIQUEIDENTIFIER, Name NVARCHAR(256), SortOrder INT);
INSERT INTO @Dashboards VALUES
    (@GridA, N'Cost & Margins',  1),
    (@GridB, N'Stock Activity',  2),
    (@GridC, N'Period Analysis', 3);

INSERT INTO dbo.OrganisationDashboardConfig (
    TransactionId, DashboardGridId, OrganisationId, Name, IconName, SortOrder
)
SELECT
    (SELECT ISNULL(MAX(TransactionId),0) FROM dbo.OrganisationDashboardConfig) + ROW_NUMBER() OVER (ORDER BY d.SortOrder),
    d.GridId,
    @OrgId,
    d.Name,
    N'',
    d.SortOrder
FROM @Dashboards d
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig odc
    WHERE odc.OrganisationId = @OrgId
      AND odc.Name = d.Name
      AND odc.IsDeleted = 0
);

PRINT 'OrganisationDashboardConfig: linked 3 dashboards';

COMMIT TRANSACTION;
PRINT '=== All Growyze report DB config inserted successfully ===';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
```

- [ ] **Step 8: Save the complete script**

Combine all 7 sections into a single file at `ClaudeDevelopment/Deploy/growyze_report_db_dev.sql`. Verify the file is syntactically complete — opening `BEGIN TRANSACTION` / `BEGIN TRY` at the top, closing `COMMIT` / `END CATCH` at the bottom.

- [ ] **Step 9: Commit**

```bash
git add ClaudeDevelopment/Deploy/growyze_report_db_dev.sql
git commit -m "feat: add Growyze report DB config script for dev microservice"
```

---

## Chunk 2: Developer Execution & Verification

### Task 2: Developer executes the script

The developer runs the script against the `report` database on the dev microservice server. This is NOT done via MCP.

- [ ] **Step 1: Execute the script**

Connect to `xms-mssql-ne-dev`, database `report`. Run the entire contents of `ClaudeDevelopment/Deploy/growyze_report_db_dev.sql`. Verify all 7 PRINT messages appear with no errors.

### Task 3: Verify BiConfig

- [ ] **Step 1: Check BiConfig row exists**

MCP verification query (run from Claude Code):
```sql
SELECT OrganisationId, DbPrefix, IsDeleted
FROM dbo.BiConfig
WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
```

Expected: 1 row, `DbPrefix = '20251208'`, `IsDeleted = 0`.

### Task 4: Verify VisualisationConfig

- [ ] **Step 1: Check 8 card type grants**

```sql
SELECT VisualisationId, VisualisationConfigId, IsDeleted
FROM dbo.VisualisationConfig
WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
ORDER BY VisualisationId
```

Expected: 8 rows with VisualisationId values `1, 2, 3, 4, 8, 9, 11, 14`. All `IsDeleted = 0`.

### Task 5: Verify VisualisationDataSetMap

- [ ] **Step 1: Check 20 dataset mappings**

```sql
SELECT vdsm.DataSet, vc.VisualisationId, vdsm.IsDeleted
FROM dbo.VisualisationDataSetMap vdsm
INNER JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = vdsm.VisualisationConfigId
WHERE vc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND vdsm.IsDeleted = 0
ORDER BY vdsm.DataSet, vc.VisualisationId
```

Expected: 20 rows. Verify all 12 Inv* datasets present plus `Locations` (14) and `InvItems` (14).

### Task 6: Verify Dashboard Grids & Items

- [ ] **Step 1: Check 3 dashboards exist**

```sql
SELECT odc.Name, odc.SortOrder, odc.DashboardGridId
FROM dbo.OrganisationDashboardConfig odc
WHERE odc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND odc.IsDeleted = 0
ORDER BY odc.SortOrder
```

Expected: 3 rows — "Cost & Margins" (1), "Stock Activity" (2), "Period Analysis" (3).

- [ ] **Step 2: Check 18 cards placed**

```sql
SELECT dgi.DataSet, dgi.VisualisationId, dgi.SortOrder,
       dgi.ExtraSmall, dgi.Medium, dgi.Large
FROM dbo.DashboardGridItem dgi
INNER JOIN dbo.OrganisationDashboardConfig odc ON odc.DashboardGridId = dgi.DashboardGridId
WHERE odc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND dgi.IsDeleted = 0 AND odc.IsDeleted = 0
ORDER BY odc.SortOrder, dgi.SortOrder
```

Expected: 18 rows. Verify card counts per dashboard: 5 (Cost & Margins), 7 (Stock Activity), 6 (Period Analysis).

- [ ] **Step 3: Check 6 filters placed**

```sql
SELECT dgf.DataSet, dgf.SortOrder, odc.Name AS Dashboard
FROM dbo.DashboardGridFilter dgf
INNER JOIN dbo.OrganisationDashboardConfig odc ON odc.DashboardGridId = dgf.DashboardGridId
WHERE odc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND dgf.IsDeleted = 0 AND odc.IsDeleted = 0
ORDER BY odc.SortOrder, dgf.SortOrder
```

Expected: 6 rows — Locations + InvItems for each of the 3 dashboards.

### Task 7: End-to-end smoke test

- [ ] **Step 1: Verify the full config load SP returns data**

This simulates what the front end calls. Run via MCP:
```sql
SELECT bc.DbPrefix, bc.OrganisationId,
       vc.VisualisationId, vp.ProcedureName,
       vdsm.DataSet
FROM dbo.BiConfig bc
CROSS JOIN dbo.VisualisationConfig vc
INNER JOIN dbo.VisualisationProcedure vp ON vp.VisualisationId = vc.VisualisationId AND vp.IsDeleted = 0
INNER JOIN dbo.VisualisationDataSetMap vdsm ON vdsm.VisualisationConfigId = vc.VisualisationConfigId AND vdsm.IsDeleted = 0
WHERE bc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND bc.IsDeleted = 0
  AND vc.OrganisationId = bc.OrganisationId
  AND vc.IsDeleted = 0
ORDER BY vdsm.DataSet
```

Expected: 20 rows. Each row should show `DbPrefix = '20251208'`, a valid `ProcedureName`, and a dataset name. The FilterList rows (VisId 14) won't join to VisualisationProcedure (it has no entry for id 14), so expect 18 rows from chart types only.

- [ ] **Step 2: Verify MI vis queries exist for all mapped datasets**

Run against MI dev (use `mcp__xms-bi-dev__query`, database `core`):
```sql
SELECT DataSetName, VisualizationType, Status
FROM core.core.VisualisationQueries
WHERE DataSetName IN (
    'InvCOGSByCategory','InvConsumption','InvWasteAnalysis','InvMarginTrend',
    'InvMargeBrut','InvWeeklySummary','InvStockActivity','InvPeriodCompWoW',
    'InvPeriodCompMoM','InvPeriodCompYoY','InvVarianceCategory','InvTheoVsActualGP',
    'Locations','InvItems'
)
AND Status = 'LIVE'
ORDER BY DataSetName, VisualizationType
```

Expected: 20 rows (18 chart queries + Locations FilterList + InvItems FilterList). All `Status = 'LIVE'`. If any dataset is missing, the corresponding card will fail to render.

- [ ] **Step 3: Update QUERY_STATUS.md**

Add an entry for `growyze_report_db_dev.sql` to `ClaudeDevelopment/QUERY_STATUS.md` with execution results and verification status.

---

## Risks & Contingencies

| Risk | Mitigation |
|---|---|
| GrowyzeDev org doesn't exist in the `organisation` microservice DB on dev | Check with the team before executing. BiConfig INSERT will succeed (no FK), but front-end login/auth may fail. |
| Filter datasets (Locations, InvItems) not LIVE in MI dev | Verify in Task 7 Step 2. If missing, filters will show empty dropdowns — cards still render unfiltered. |
| TransactionId collision from concurrent inserts | The subquery pattern handles this within a single transaction, but concurrent scripts could collide. Run this script alone. |
| Responsive breakpoints need tuning | Adjust DashboardGridItem column spans after visual testing. Use the `_UpdateEntity_AutoGenerated` SPs to modify individual items. |

## Summary

| What | Count |
|---|---|
| SQL scripts to create | 1 (`ClaudeDevelopment/Deploy/growyze_report_db_dev.sql`) |
| Tables modified | 7 |
| Total rows inserted | 59 (1 + 8 + 20 + 3 + 18 + 6 + 3) |
| Verification queries | 6 |
| Dashboards created | 3 (Cost & Margins, Stock Activity, Period Analysis) |
