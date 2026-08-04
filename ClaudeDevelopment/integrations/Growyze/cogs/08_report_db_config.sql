/* =============================================================================
   08_report_db_config.sql
   -----------------------------------------------------------------------------
   Target server  : xms-mssql-ne-uat (or the equivalent Prod microservice server)
   Target database: report  --  the MICROSERVICE report database.
                    This is a DIFFERENT SERVER from the client data warehouse
                    (the XMS BI Managed Instance). It is run BY HAND, directly
                    against `report`, using SSMS / Azure Data Studio.
                    Do NOT run this through the Managed Instance PowerShell
                    release runners. Do NOT run this via MCP -- every
                    microservice-* MCP connection is read-only (per
                    docs/microservice-report-database.md section 1); this DB cannot be
                    written through MCP at all.

   Purpose: Wire the "Pantry COGS" dashboard into the report DB so it renders
            for the target Growyze organisation, following the same chain
            `03_margebrut_report_config.sql` used for Oak & Vine's "Marge Brut"
            dashboard (statement shapes mirrored deliberately).

   NOTE ON EXECUTION: no database access was available while writing this file.
   Nothing here has been executed against report or any other server. This has
   been verified by construction and against docs/microservice-report-database.md
   plus the two existing report-DB scripts in this repo
   (ClaudeDevelopment/integrations/MargeBrut/03_margebrut_report_config.sql and
   ClaudeDevelopment/integrations/Growyze/reporting_queries/22_filter_wiring_fix.sql)
   -- review before deploying.

   -----------------------------------------------------------------------------
   PARAMETERS -- the only two values to set per deployment.
   -----------------------------------------------------------------------------
   Deliberately left as placeholders: the target for this round is UAT org 21
   (Ibis Gloucester Road), but the committed script must not be pinned to one org.

   TYPE CORRECTION vs. the task brief: the brief's template declared
   `@OrgId INT`. That is wrong for this database -- BiConfig.OrganisationId,
   VisualisationConfig.OrganisationId, OrganisationDashboardConfig.OrganisationId
   and DashboardGroup.OrganisationId are all `uniqueidentifier`
   (docs/microservice-report-database.md sections 3.1/3.3/5.1/5.3), and SQL Server
   does not allow converting between int and uniqueidentifier. Every existing
   report-DB script in this repo (03_margebrut_report_config.sql) declares
   @OrgId as UNIQUEIDENTIFIER. "Org 21" is the MI-side (client warehouse)
   integer OrganisationID used inside F_COGS_PERIOD etc. -- a different
   identifier from the microservice-side GUID needed here.

   DEPLOYMENT PREREQUISITE -- @OrgId is a genuine lookup, not a placeholder to
   guess at: the org GUID must be looked up directly IN THE `report` DATABASE
   for the target organisation (e.g. `SELECT OrganisationId FROM dbo.BiConfig
   WHERE ...` if a BiConfig row already exists for it, or the `organisation`
   microservice DB otherwise) BEFORE running this script. The MI-side integer
   OrganisationID ("org 21") is NOT this value and will not work here even if
   pasted into the placeholder below.

   -----------------------------------------------------------------------------
   RE-RUNNING THIS SCRIPT DOES NOT PICK UP LAYOUT EDITS. READ BEFORE EDITING.
   -----------------------------------------------------------------------------
   Final-review M16, documented rather than changed. Design section 9 requires "MERGE
   upserts on natural keys so every script re-runs cleanly (never bare INSERT)".
   Five writes below are `INSERT ... WHERE NOT EXISTS` instead: BiConfig (section 1),
   VisualisationConfig (2), VisualisationDataSetMap (3), DashboardGridItem (6) and
   DashboardGridFilter (7). They are GUARDED, not bare, so re-running is safe and
   creates no duplicates - but they never UPDATE.

   The consequence matters here specifically because section 6 invites rearrangement
   ("no design sign-off"). If you change a SortOrder or a breakpoint below and re-run
   this script, NOTHING HAPPENS: the guard finds the existing row, the insert is
   skipped, no message is printed, and step 10's verify still reports PASS because it
   only counts rows. To apply a layout change you must either soft-delete the affected
   DashboardGridItem / DashboardGridFilter rows (IsDeleted = 1 - DashboardGridItem.
   IsDeleted IS honoured by DashboardGrid_Load, design section 7.2 #5) and re-run, or
   UPDATE the rows by hand.

   Left as guarded INSERTs because that matches the only precedent in this repo
   (ClaudeDevelopment/integrations/MargeBrut/03_margebrut_report_config.sql), and this
   file is hand-run against a different server by a person who can see what happened.
   This is therefore a divergence from the spec, not from the codebase - but it is now
   written down instead of being a surprise.
   ============================================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY

DECLARE @OrgId    UNIQUEIDENTIFIER = N'<TARGET-ORG-GUID>';       -- e.g. UAT org 21, Ibis Gloucester Road -- microservice OrganisationId GUID, NOT the MI integer OrgID
DECLARE @DbPrefix NVARCHAR(100)   = N'<TARGET-DB-PREFIX>';       -- e.g. '20260317' -- resolves the MI database name {DbPrefix}_XMS_{OrgId}; column is nvarchar(8), this variable is just declared wide per the brief

----------------------------------------------------------------------
-- Card-type VisualisationId map (report.dbo.VisualisationProcedure)
--   1  = BarChartCard            (confirmed: docs/microservice-report-database.md section 3.2, and 03_margebrut_report_config.sql header comment)
--   3  = CustomDataGrid          (confirmed: same sources)
--   4  = CustomGroupedDataGrid   (confirmed: docs section 3.2 table -- "4 | core.CustomGroupedDataGrid | 2025-12-16"; also
--                                  00_CARD_CONTRACTS.md's CustomGroupedDataGrid example is a real live VisualisationProcedure row)
--   9  = PieChartCard            (confirmed: docs section 3.2, and 03_margebrut_report_config.sql header comment)
--   10 = SingleKPICard           (confirmed: same sources)
--
-- FilterList / VisualisationId 14 -- deliberately NOT wired into VisualisationConfig or
-- VisualisationDataSetMap. Recorded here so this doesn't get "fixed" back in six months:
--   docs/microservice-report-database.md sections 3.2 and 12 both state VisualisationId 14 is a
--   documented GAP in VisualisationProcedure: "FilterList is handled separately by the
--   microservice, not via a card SP" -- explicitly "by design, not a defect". There is no
--   ProcedureName row for it and there never will be.
--   DashboardGridFilter has no VisualisationId column (docs section 4.3) and is the FilterList
--   widgets' ONLY wiring -- see step 7 below. VisualisationDataSetMap "is not a render gate"
--   (docs section 3.4); a missing map row there is a config-UI completeness gap only, never a
--   broken filter widget. Neither existing report-DB script in this repo
--   (03_margebrut_report_config.sql, 22_filter_wiring_fix.sql) wires filter datasets into
--   VisualisationConfig/VisualisationDataSetMap -- both rely on DashboardGridFilter alone. This
--   script follows that precedent: VisualisationConfig grants only the 5 real card types below,
--   and VisualisationDataSetMap carries only the 12 card datasets (step 3). Do not add
--   VisualisationId = 14 rows to either table for the 3 filter datasets -- there is nowhere in
--   this system that reads them from there.
----------------------------------------------------------------------

----------------------------------------------------------------------
-- 1. BiConfig -- org -> MI client DB mapping ({DbPrefix}_XMS_{OrgId})
----------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.BiConfig WHERE OrganisationId = @OrgId AND IsDeleted = 0)
BEGIN
    INSERT INTO dbo.BiConfig (OrganisationId, DbPrefix, IsDeleted)
    VALUES (@OrgId, @DbPrefix, 0);
    PRINT 'BiConfig: inserted target org';
END
ELSE PRINT 'BiConfig: target org already exists, skipped';

----------------------------------------------------------------------
-- 2. VisualisationConfig -- grant the 5 card types the Pantry COGS dashboard uses
--    (1 Bar, 3 CustomDataGrid, 4 CustomGroupedDataGrid, 9 Pie, 10 KPI).
--    FilterList (14) is deliberately NOT granted here -- see the note above section 1:
--    it has no VisualisationProcedure row and is wired solely via DashboardGridFilter (step 7).
----------------------------------------------------------------------
DECLARE @VisTypes TABLE (VisualisationId INT);
INSERT INTO @VisTypes VALUES (1),(3),(4),(9),(10);

INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, IsDeleted)
SELECT @OrgId, vt.VisualisationId, SYSUTCDATETIME(), 0
FROM @VisTypes vt
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationConfig vc
    WHERE vc.OrganisationId = @OrgId AND vc.VisualisationId = vt.VisualisationId AND vc.IsDeleted = 0
);
PRINT 'VisualisationConfig: granted card types 1,3,4,9,10';

----------------------------------------------------------------------
-- 3. VisualisationDataSetMap -- wire the 12 card datasets to their card type.
--    The 3 FilterList datasets (PantryCOGSVenues/Periods/Categories) are intentionally
--    ABSENT from this table -- see the note above section 1. Their only wiring is the
--    DashboardGridFilter rows in step 7; do not add them here.
----------------------------------------------------------------------
DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @DataSets VALUES
    -- 4 SingleKPICard datasets (Task 6)
    (N'PantryCOGSSpendKPI',            10),
    (N'PantryCOGSSoldKPI',              10),
    (N'PantryCOGSClosingStockKPI',      10),
    (N'PantryCOGSVarianceKPI',          10),
    -- 1 PieChartCard + 4 BarChartCard datasets (Task 7)
    (N'PantryCOGSConsumptionMix',       9),
    (N'PantryCOGSPeriodComparison',     1),
    (N'PantryCOGSTopItemsByCategory',   1),
    (N'PantryCOGSSlowMovers',           1),
    (N'PantryCOGSByVenue',              1),
    -- 2 CustomDataGrid + 1 CustomGroupedDataGrid datasets (Task 8)
    (N'PantryCOGSBillingTotals',        3),
    (N'PantryCOGSItemTable',            4),
    (N'PantryCOGSExceptions',           3);

INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT vc.VisualisationConfigId, ds.DataSet, 0
FROM @DataSets ds
INNER JOIN dbo.VisualisationConfig vc
    ON vc.OrganisationId = @OrgId AND vc.VisualisationId = ds.VisualisationId AND vc.IsDeleted = 0
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap vdsm
    WHERE vdsm.VisualisationConfigId = vc.VisualisationConfigId AND vdsm.DataSet = ds.DataSet AND vdsm.IsDeleted = 0
);
PRINT 'VisualisationDataSetMap: wired 12 card datasets';

----------------------------------------------------------------------
-- 4. DashboardGrid -- one grid for the Pantry COGS dashboard
----------------------------------------------------------------------
DECLARE @GridId UNIQUEIDENTIFIER = NEWID();

IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Pantry COGS' AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    VALUES (@GridId, 1, 2, 12, 0);
    PRINT 'DashboardGrid: created grid for Pantry COGS';
END
ELSE
BEGIN
    SELECT @GridId = DashboardGridId FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Pantry COGS' AND IsDeleted = 0;
    PRINT 'DashboardGrid: Pantry COGS grid already exists, using existing ID';
END

----------------------------------------------------------------------
-- 5. OrganisationDashboardConfig -- name & link the dashboard
--    NOTE: OrganisationDashboardConfig_Audit was already fixed (docs sections 5/12, fix committed
--    2026-07-06 in ClaudeDevelopment/integrations/MargeBrut/00_fix_report_audit_trigger.sql),
--    so writes to THIS table are expected to succeed. DashboardConfig_Audit and
--    StaffDashboardConfig_Audit remain broken (missing DashboardGridId/IconName/SortOrder in
--    their audit inserts) -- this script never writes to those two platform/staff tiers, so
--    that defect does not apply here. If a future change to this dashboard ever needs the
--    platform-default or staff tier, fix those two triggers first using the same pattern as
--    00_fix_report_audit_trigger.sql -- do not attempt the write and work around a failure silently.
----------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Pantry COGS' AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.OrganisationDashboardConfig (DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted)
    VALUES (@GridId, @OrgId, N'Pantry COGS', N'Kitchen', 0, 0);
    PRINT 'OrganisationDashboardConfig: linked Pantry COGS dashboard';
END
ELSE PRINT 'OrganisationDashboardConfig: Pantry COGS already exists, skipped';

----------------------------------------------------------------------
-- 6. DashboardGridItem -- place the 12 cards
--    Layout: KPI strip (4) -> Consumption mix + Period comparison (2) ->
--            Top items by category + Slow movers (2) -> By venue (1, full width) ->
--            Billing totals grid -> Item table (grouped) -> Exceptions grid
--    DESIGN CHOICE, NOT SPECIFIED: no layout spec was provided for this task beyond the
--    12 dataset names and card types. This row/column arrangement (mirroring the
--    03_margebrut_report_config.sql hybrid-layout convention: KPI strip -> paired charts ->
--    full-width grids) is this author's own choice. It is open to rearrangement -- flag to
--    whoever reviews the dashboard UI that the SortOrder/breakpoint values below have no
--    design sign-off behind them.
----------------------------------------------------------------------
DECLARE @Items TABLE (
    VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
    ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT
);
INSERT INTO @Items VALUES
    -- Row 1: KPI strip
    (10, N'PantryCOGSSpendKPI',            1, 12, 6, 3, 3, 3),
    (10, N'PantryCOGSSoldKPI',              2, 12, 6, 3, 3, 3),
    (10, N'PantryCOGSClosingStockKPI',      3, 12, 6, 3, 3, 3),
    (10, N'PantryCOGSVarianceKPI',          4, 12, 6, 3, 3, 3),
    -- Row 2: consumption mix + period comparison
    ( 9, N'PantryCOGSConsumptionMix',       5, 12, 12, 6, 6, 6),
    ( 1, N'PantryCOGSPeriodComparison',     6, 12, 12, 6, 6, 6),
    -- Row 3: top items by category + slow movers
    ( 1, N'PantryCOGSTopItemsByCategory',   7, 12, 12, 6, 6, 6),
    ( 1, N'PantryCOGSSlowMovers',           8, 12, 12, 6, 6, 6),
    -- Row 4: by venue, full width
    ( 1, N'PantryCOGSByVenue',              9, 12, 12, 12, 12, 12),
    -- Row 5-7: the three grids, full width
    ( 3, N'PantryCOGSBillingTotals',       10, 12, 12, 12, 12, 12),
    ( 4, N'PantryCOGSItemTable',           11, 12, 12, 12, 12, 12),
    ( 3, N'PantryCOGSExceptions',          12, 12, 12, 12, 12, 12);

INSERT INTO dbo.DashboardGridItem (DashboardGridId, VisualisationId, DataSet, SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
SELECT @GridId, i.VisualisationId, i.DataSet, i.SortOrder, i.ExtraSmall, i.Small, i.Medium, i.Large, i.ExtraLarge, 0
FROM @Items i
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem dgi
    WHERE dgi.DashboardGridId = @GridId AND dgi.DataSet = i.DataSet AND dgi.VisualisationId = i.VisualisationId AND dgi.IsDeleted = 0
);
PRINT 'DashboardGridItem: placed 12 cards';

----------------------------------------------------------------------
-- 7. DashboardGridFilter -- the 3 filter widgets
--    DataSet values below MUST equal the FilterDefinitions keys used in
--    Tasks 6-9 (04_vis_kpis.sql / 05_vis_charts.sql / 06_vis_grids.sql / 07_vis_filters.sql)
--    character for character: PantryCOGSVenues, PantryCOGSPeriods, PantryCOGSCategories.
--    Confirmed against 07_vis_filters.sql's DataSetName literals and 04_vis_kpis.sql's
--    FilterDefinitions block -- exact match, case-sensitive. A mismatch here means the widget
--    renders and does nothing when clicked.
--    DashboardGridFilter has no VisualisationId column (docs section 4.3) -- filters are not
--    typed as a card, so none is supplied here.
----------------------------------------------------------------------
DECLARE @Filters TABLE (DataSet NVARCHAR(1024), SortOrder INT);
INSERT INTO @Filters VALUES
    (N'PantryCOGSVenues',     1),
    (N'PantryCOGSPeriods',    2),
    (N'PantryCOGSCategories', 3);

INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, IsDeleted, SortOrder)
SELECT @GridId, f.DataSet, 0, f.SortOrder
FROM @Filters f
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter dgf
    WHERE dgf.DashboardGridId = @GridId AND dgf.DataSet = f.DataSet AND dgf.IsDeleted = 0
);
PRINT 'DashboardGridFilter: placed 3 filter widgets';

----------------------------------------------------------------------
-- 8. DashboardGroup -- root "All Dashboards" group for the org (LOAD-BEARING)
--    A dashboard config without a group mapping is silently invisible (docs section 5.3).
--    OrganisationDashboardGroupMapping is the load-bearing junction here -- NOT
--    DashboardGroupMapping, which is the unused platform-default tier (0 rows on UAT;
--    ledger O13 was raised, investigated and closed as a misdiagnosis on exactly this
--    confusion -- docs section 12 "Dashboards invisible without a group").
----------------------------------------------------------------------
MERGE INTO dbo.DashboardGroup AS tgt
USING ( SELECT @OrgId AS OrganisationId, N'All Dashboards' AS Name ) AS src
    ON  tgt.OrganisationId          = src.OrganisationId
    AND tgt.Name                    = src.Name
    AND tgt.ParentDashboardGroupId IS NULL
    AND tgt.StaffId                IS NULL
    AND tgt.IsDeleted               = 0
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ParentDashboardGroupId, Name, OrganisationId, StaffId, IsDeleted, SortOrder)
    VALUES (NULL, src.Name, src.OrganisationId, NULL, 0, 0);
PRINT 'DashboardGroup: ensured All Dashboards group for target org';

----------------------------------------------------------------------
-- 9. OrganisationDashboardGroupMapping -- map config into the group
----------------------------------------------------------------------
MERGE INTO dbo.OrganisationDashboardGroupMapping AS tgt
USING (
    SELECT g.DashboardGroupId, odc.OrganisationDashboardConfigId
    FROM dbo.OrganisationDashboardConfig AS odc
    INNER JOIN dbo.DashboardGroup AS g
        ON  g.OrganisationId          = odc.OrganisationId
        AND g.Name                    = N'All Dashboards'
        AND g.ParentDashboardGroupId IS NULL
        AND g.StaffId                IS NULL
        AND g.IsDeleted               = 0
    WHERE odc.OrganisationId = @OrgId AND odc.Name = N'Pantry COGS' AND odc.IsDeleted = 0
) AS src
    ON tgt.DashboardGroupId = src.DashboardGroupId
   AND tgt.OrganisationDashboardConfigId = src.OrganisationDashboardConfigId
WHEN MATCHED AND tgt.IsDeleted = 1 THEN
    UPDATE SET IsDeleted = 0, DateUpdated = SYSUTCDATETIME()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (DashboardGroupId, OrganisationDashboardConfigId, IsDeleted)
    VALUES (src.DashboardGroupId, src.OrganisationDashboardConfigId, 0);
PRINT 'OrganisationDashboardGroupMapping: mapped Pantry COGS dashboard into group';

----------------------------------------------------------------------
-- 10. Verify-or-rollback -- card count for the new grid + group mapping presence
----------------------------------------------------------------------
DECLARE @cardCount INT;
SELECT @cardCount = COUNT(*)
FROM dbo.DashboardGridItem
WHERE DashboardGridId = @GridId AND IsDeleted = 0;

DECLARE @filterCount INT;
SELECT @filterCount = COUNT(*)
FROM dbo.DashboardGridFilter
WHERE DashboardGridId = @GridId AND IsDeleted = 0;

DECLARE @groupMapped INT;
SELECT @groupMapped = COUNT(*)
FROM dbo.OrganisationDashboardConfig odc
WHERE odc.OrganisationId = @OrgId AND odc.Name = N'Pantry COGS' AND odc.IsDeleted = 0
  AND EXISTS (
      SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
      INNER JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId AND g.IsDeleted = 0
      WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId AND m.IsDeleted = 0
  );

IF @cardCount <> 12 OR @filterCount <> 3 OR @groupMapped <> 1
BEGIN
    PRINT N'FAIL -- expected 12 cards / 3 filters / 1 grouped config, got '
        + CAST(@cardCount AS NVARCHAR(10)) + N' cards, '
        + CAST(@filterCount AS NVARCHAR(10)) + N' filters, '
        + CAST(@groupMapped AS NVARCHAR(10)) + N' grouped configs. Rolling back.';
    ROLLBACK TRANSACTION;
    RETURN;
END

PRINT N'PASS -- Pantry COGS dashboard wired: 12 cards, 3 filters, group-mapped and visible.';
COMMIT TRANSACTION;
PRINT '=== Pantry COGS dashboard wired ===';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
