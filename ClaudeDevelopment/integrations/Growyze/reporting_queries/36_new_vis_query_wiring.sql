/*
    36_new_vis_query_wiring.sql
    ============================
    Report DB wiring for 3 new vis query datasets created by
    scripts 32 and 33:
      - InvUsageByCategory   (PieChartCard, id 9)
      - InvUsageBySubCategory (StackedBarChartCard, id 11)
      - InvVarianceTrend     (MultiLineChartCard, id 8)

    Wires to both Growyze orgs:
      - Padel Social:  94A4B719-EB0F-421F-AD03-ABECDD888B14
      - Dirty Sixth:   7B50D717-124C-4902-ADD2-439A9310326A

    Placement:
      - InvUsageByCategory + InvUsageBySubCategory → Cost & Margins
        (7C83F241-9CD7-4326-B659-109CF4408793)
      - InvVarianceTrend → Stock Activity
        (7ED51BEF-1DEE-496F-8B83-09BF7E357F1B)

    Prerequisites: Scripts 32 + 33 deployed to core MI first.

    TARGET: report database on microservice server (xms-mssql-ne-uat)
*/

DECLARE @PadelSocial UNIQUEIDENTIFIER = '94A4B719-EB0F-421F-AD03-ABECDD888B14';
DECLARE @DirtySixth  UNIQUEIDENTIFIER = '7B50D717-124C-4902-ADD2-439A9310326A';
DECLARE @CostMarginsGrid UNIQUEIDENTIFIER = '7C83F241-9CD7-4326-B659-109CF4408793';
DECLARE @StockActivityGrid UNIQUEIDENTIFIER = '7ED51BEF-1DEE-496F-8B83-09BF7E357F1B';

----------------------------------------------------------------------
-- 1. VisualisationDataSetMap — wire new datasets to existing configs
----------------------------------------------------------------------
-- Both orgs should already have VisualisationConfig rows for
-- PieChartCard (9), StackedBarChartCard (11), MultiLineChartCard (8).
-- We just need to add VisualisationDataSetMap entries.

DECLARE @NewDataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @NewDataSets VALUES
    (N'InvUsageByCategory',    9),   -- PieChartCard
    (N'InvUsageBySubCategory', 11),  -- StackedBarChartCard
    (N'InvVarianceTrend',      8);   -- MultiLineChartCard

-- Padel Social
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT
    vc.VisualisationConfigId,
    ds.DataSet,
    0
FROM @NewDataSets ds
INNER JOIN dbo.VisualisationConfig vc
    ON vc.OrganisationId = @PadelSocial
   AND vc.VisualisationId = ds.VisualisationId
   AND vc.IsDeleted = 0
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap vdsm
    WHERE vdsm.VisualisationConfigId = vc.VisualisationConfigId
      AND vdsm.DataSet = ds.DataSet
      AND vdsm.IsDeleted = 0
);

-- Dirty Sixth
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT
    vc.VisualisationConfigId,
    ds.DataSet,
    0
FROM @NewDataSets ds
INNER JOIN dbo.VisualisationConfig vc
    ON vc.OrganisationId = @DirtySixth
   AND vc.VisualisationId = ds.VisualisationId
   AND vc.IsDeleted = 0
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap vdsm
    WHERE vdsm.VisualisationConfigId = vc.VisualisationConfigId
      AND vdsm.DataSet = ds.DataSet
      AND vdsm.IsDeleted = 0
);

PRINT 'VisualisationDataSetMap: wired 3 new datasets for both orgs';

----------------------------------------------------------------------
-- 2. DashboardGridItem — place cards on grids
----------------------------------------------------------------------
-- Cost & Margins: existing max SortOrder is ~5 (InvTheoVsActualGP).
-- Add new cards at SortOrder 6 and 7.
-- Stock Activity: existing max SortOrder is ~12.
-- Add InvVarianceTrend at SortOrder 13.

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

INSERT INTO @Items VALUES
    -- Cost & Margins: InvUsageByCategory pie (half-width)
    (@CostMarginsGrid,    9, N'InvUsageByCategory',    6, 12, 12, 6, 6, 6),
    -- Cost & Margins: InvUsageBySubCategory stacked bar (half-width)
    (@CostMarginsGrid,   11, N'InvUsageBySubCategory', 7, 12, 12, 6, 6, 6),
    -- Stock Activity: InvVarianceTrend multi-line (full-width)
    (@StockActivityGrid,  8, N'InvVarianceTrend',     13, 12, 12, 12, 12, 12);

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

PRINT 'DashboardGridItem: placed 3 new cards';

----------------------------------------------------------------------
-- 3. Verify
----------------------------------------------------------------------
SELECT 'Cost & Margins' AS Grid, DataSet, VisualisationId, SortOrder, IsDeleted
FROM dbo.DashboardGridItem
WHERE DashboardGridId = @CostMarginsGrid
ORDER BY SortOrder;

SELECT 'Stock Activity' AS Grid, DataSet, VisualisationId, SortOrder, IsDeleted
FROM dbo.DashboardGridItem
WHERE DashboardGridId = @StockActivityGrid
ORDER BY SortOrder;
