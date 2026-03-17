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
    INSERT INTO dbo.BiConfig (OrganisationId, DbPrefix, IsDeleted)
    VALUES (@OrgId, @DbPrefix, 0);
    PRINT 'BiConfig: inserted GrowyzeDev';
END
ELSE
    PRINT 'BiConfig: GrowyzeDev already exists, skipped';

----------------------------------------------------------------------
-- 2. VisualisationConfig — grant card type access
----------------------------------------------------------------------
DECLARE @VisTypes TABLE (VisualisationId INT);
INSERT INTO @VisTypes VALUES (1),(2),(3),(4),(8),(9),(11),(14);

INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, IsDeleted)
SELECT
    @OrgId,
    vt.VisualisationId,
    SYSUTCDATETIME(),
    0
FROM @VisTypes vt
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationConfig vc
    WHERE vc.OrganisationId = @OrgId
      AND vc.VisualisationId = vt.VisualisationId
      AND vc.IsDeleted = 0
);

PRINT 'VisualisationConfig: granted card type access';

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

INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT
    vc.VisualisationConfigId,
    ds.DataSet,
    0
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
    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    VALUES
        (@GridA, 1, 2, 12, 0),
        (@GridB, 1, 2, 12, 0),
        (@GridC, 1, 2, 12, 0);

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
    DashboardGridId, VisualisationId, DataSet,
    SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted
)
SELECT
    i.GridId,
    i.VisualisationId,
    i.DataSet,
    i.SortOrder,
    i.ExtraSmall,
    i.Small,
    i.Medium,
    i.Large,
    i.ExtraLarge,
    0
FROM @Items i
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem dgi
    WHERE dgi.DashboardGridId = i.GridId
      AND dgi.DataSet = i.DataSet
      AND dgi.VisualisationId = i.VisualisationId
      AND dgi.IsDeleted = 0
);

PRINT 'DashboardGridItem: placed 18 cards';

----------------------------------------------------------------------
-- 6. DashboardGridFilter — filter widgets
----------------------------------------------------------------------
DECLARE @Filters TABLE (GridId UNIQUEIDENTIFIER, DataSet NVARCHAR(1024), SortOrder INT);
INSERT INTO @Filters VALUES
    (@GridA, N'Locations', 1), (@GridA, N'InvItems', 2),
    (@GridB, N'Locations', 1), (@GridB, N'InvItems', 2),
    (@GridC, N'Locations', 1), (@GridC, N'InvItems', 2);

INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, SortOrder, IsDeleted)
SELECT
    f.GridId,
    f.DataSet,
    f.SortOrder,
    0
FROM @Filters f
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter dgf
    WHERE dgf.DashboardGridId = f.GridId
      AND dgf.DataSet = f.DataSet
      AND dgf.IsDeleted = 0
);

PRINT 'DashboardGridFilter: added 6 filters';

----------------------------------------------------------------------
-- 7. OrganisationDashboardConfig — name and link dashboards
----------------------------------------------------------------------
DECLARE @Dashboards TABLE (GridId UNIQUEIDENTIFIER, Name NVARCHAR(256), SortOrder INT);
INSERT INTO @Dashboards VALUES
    (@GridA, N'Cost & Margins',  1),
    (@GridB, N'Stock Activity',  2),
    (@GridC, N'Period Analysis', 3);

INSERT INTO dbo.OrganisationDashboardConfig (
    DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted
)
SELECT
    d.GridId,
    @OrgId,
    d.Name,
    N'',
    d.SortOrder,
    0
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
