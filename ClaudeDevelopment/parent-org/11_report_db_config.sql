----------------------------------------------------------------------
-- Parent Organisation Dashboard — Report DB Configuration
-- Target: report database on microservice server
-- Org: Nabil Enterprises (5C4F9C3D-2704-F111-8D4C-000D3AB579E6)
-- Dashboard: "Group Overview" — 11 cards + 2 filters
-- Run as: Single script, entire file
----------------------------------------------------------------------

BEGIN TRANSACTION;
BEGIN TRY

DECLARE @OrgId UNIQUEIDENTIFIER = '5C4F9C3D-2704-F111-8D4C-000D3AB579E6';

----------------------------------------------------------------------
-- 1. VisualisationConfig — grant card type access
--    Parent already has: 2, 9, 10, 11, 16, 17
--    Adding: 1 (BarChartCard), 3 (CustomDataGrid),
--            4 (CustomGroupedDataGrid), 8 (MultiLineChartCard)
----------------------------------------------------------------------
DECLARE @VisTypes TABLE (VisualisationId INT);
INSERT INTO @VisTypes VALUES (1),(3),(4),(8);

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

PRINT 'VisualisationConfig: granted card types 1, 3, 4, 8';

----------------------------------------------------------------------
-- 2. VisualisationDataSetMap — wire 11 card datasets
----------------------------------------------------------------------
DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @DataSets VALUES
    (N'ParentNetSales',          10),
    (N'ParentOrderCount',        10),
    (N'ParentAvgOrderValue',     10),
    (N'ParentOrgRevenue',        11),
    (N'ParentOrgRevenueTrend',    8),
    (N'ParentGrowthSummary',      3),
    (N'ParentProfitByOrg',       11),
    (N'ParentDiscountImpact',     1),
    (N'ParentEfficiencyByOrg',   11),
    (N'ParentLocationRankings',   4),
    (N'ParentOrgSummaryTable',    3);

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

PRINT 'VisualisationDataSetMap: wired 11 card datasets';

----------------------------------------------------------------------
-- 3. Cleanup — soft-delete 2 stale DataSetMap entries
--    InvTheoMargin and InvCountVariance are child-level datasets
--    that shouldn't be on the parent org
----------------------------------------------------------------------
UPDATE vdsm
SET vdsm.IsDeleted = 1,
    vdsm.DateUpdated = SYSUTCDATETIME()
FROM dbo.VisualisationDataSetMap vdsm
INNER JOIN dbo.VisualisationConfig vc
    ON vdsm.VisualisationConfigId = vc.VisualisationConfigId
WHERE vc.OrganisationId = @OrgId
  AND vdsm.DataSet IN (N'InvTheoMargin', N'InvCountVariance')
  AND vdsm.IsDeleted = 0;

PRINT 'VisualisationDataSetMap: soft-deleted InvTheoMargin + InvCountVariance';

----------------------------------------------------------------------
-- 4. DashboardGrid — 1 new grid for Group Overview
----------------------------------------------------------------------
DECLARE @GridId UNIQUEIDENTIFIER = NEWID();

IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId
      AND Name = N'Group Overview'
      AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    VALUES (@GridId, 1, 2, 12, 0);

    PRINT 'DashboardGrid: created grid for Group Overview';
END
ELSE
BEGIN
    SELECT @GridId = DashboardGridId FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId
      AND Name = N'Group Overview'
      AND IsDeleted = 0;

    PRINT 'DashboardGrid: Group Overview grid already exists, using existing ID';
END

----------------------------------------------------------------------
-- 5. OrganisationDashboardConfig — link dashboard to parent org
----------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId
      AND Name = N'Group Overview'
      AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.OrganisationDashboardConfig (
        DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted
    )
    VALUES (@GridId, @OrgId, N'Group Overview', N'CorporateFare', 0, 0);

    PRINT 'OrganisationDashboardConfig: linked Group Overview dashboard';
END
ELSE
    PRINT 'OrganisationDashboardConfig: Group Overview already exists, skipped';

----------------------------------------------------------------------
-- 6. DashboardGridItem — 11 cards on the grid
----------------------------------------------------------------------
DECLARE @Items TABLE (
    VisualisationId INT,
    DataSet NVARCHAR(1024),
    SortOrder INT,
    ExtraSmall INT,
    Small INT,
    Medium INT,
    Large INT,
    ExtraLarge INT
);

INSERT INTO @Items VALUES
    (10, N'ParentNetSales',         1, 12, 12,  4,  4,  4),
    (10, N'ParentOrderCount',       2, 12, 12,  4,  4,  4),
    (10, N'ParentAvgOrderValue',    3, 12, 12,  4,  4,  4),
    (11, N'ParentOrgRevenue',       4, 12, 12,  6,  6,  6),
    ( 8, N'ParentOrgRevenueTrend',  5, 12, 12,  6,  6,  6),
    ( 3, N'ParentGrowthSummary',    6, 12, 12, 12, 12, 12),
    (11, N'ParentProfitByOrg',      7, 12, 12,  6,  6,  6),
    ( 1, N'ParentDiscountImpact',   8, 12, 12,  6,  6,  6),
    (11, N'ParentEfficiencyByOrg',  9, 12, 12, 12, 12, 12),
    ( 4, N'ParentLocationRankings',10, 12, 12,  6,  6,  6),
    ( 3, N'ParentOrgSummaryTable', 11, 12, 12,  6,  6,  6);

INSERT INTO dbo.DashboardGridItem (
    DashboardGridId, VisualisationId, DataSet,
    SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted
)
SELECT
    @GridId,
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
    WHERE dgi.DashboardGridId = @GridId
      AND dgi.DataSet = i.DataSet
      AND dgi.VisualisationId = i.VisualisationId
      AND dgi.IsDeleted = 0
);

PRINT 'DashboardGridItem: placed 11 cards';

----------------------------------------------------------------------
-- 7. DashboardGridFilter — 2 filter widgets
----------------------------------------------------------------------
DECLARE @Filters TABLE (DataSet NVARCHAR(1024), SortOrder INT);
INSERT INTO @Filters VALUES
    (N'ParentOrganisations', 1),
    (N'ParentLocations',     2);

INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, SortOrder, IsDeleted)
SELECT
    @GridId,
    f.DataSet,
    f.SortOrder,
    0
FROM @Filters f
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter dgf
    WHERE dgf.DashboardGridId = @GridId
      AND dgf.DataSet = f.DataSet
      AND dgf.IsDeleted = 0
);

PRINT 'DashboardGridFilter: added 2 filters (Organisations, Locations)';

COMMIT TRANSACTION;
PRINT '=== Parent org Group Overview dashboard config inserted successfully ===';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
