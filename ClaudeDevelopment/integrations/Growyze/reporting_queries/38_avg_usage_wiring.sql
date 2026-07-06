/*
    38_avg_usage_wiring.sql
    ========================
    Report DB wiring for 2 new average usage datasets created
    by script 37:
      - InvAvgUsage       (CustomDataGrid, id 3)
      - ProductAvgUsage   (CustomDataGrid, id 3)

    Wires to both Growyze orgs:
      - Padel Social:  94A4B719-EB0F-421F-AD03-ABECDD888B14
      - Dirty Sixth:   7B50D717-124C-4902-ADD2-439A9310326A

    Placement:
      - InvAvgUsage → Stock Activity grid
        (7ED51BEF-1DEE-496F-8B83-09BF7E357F1B, SortOrder 14)
      - ProductAvgUsage → Products grid
        (5E13630D-462A-F111-9A49-000D3AB27214, SortOrder 7)

    Prerequisites: Script 37 deployed to core MI first.

    TARGET: report database on microservice server (xms-mssql-ne-uat)
*/

DECLARE @PadelSocial UNIQUEIDENTIFIER = '94A4B719-EB0F-421F-AD03-ABECDD888B14';
DECLARE @DirtySixth  UNIQUEIDENTIFIER = '7B50D717-124C-4902-ADD2-439A9310326A';
DECLARE @StockActivityGrid UNIQUEIDENTIFIER = '7ED51BEF-1DEE-496F-8B83-09BF7E357F1B';
DECLARE @ProductsGrid      UNIQUEIDENTIFIER = '5E13630D-462A-F111-9A49-000D3AB27214';

----------------------------------------------------------------------
-- 1. VisualisationDataSetMap — wire new datasets
----------------------------------------------------------------------
-- Both datasets use CustomDataGrid (VisualisationId = 3).
-- Both orgs should already have VisualisationConfig for id 3.

DECLARE @NewDataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @NewDataSets VALUES
    (N'InvAvgUsage',      3),   -- CustomDataGrid
    (N'ProductAvgUsage',  3);   -- CustomDataGrid

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

PRINT 'VisualisationDataSetMap: wired InvAvgUsage + ProductAvgUsage for both orgs';

----------------------------------------------------------------------
-- 2. DashboardGridItem — place cards on grids
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

INSERT INTO @Items VALUES
    -- Stock Activity: InvAvgUsage grid (full-width)
    (@StockActivityGrid, 3, N'InvAvgUsage',     14, 12, 12, 12, 12, 12),
    -- Products: ProductAvgUsage grid (full-width)
    (@ProductsGrid,      3, N'ProductAvgUsage',   7, 12, 12, 12, 12, 12);

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

PRINT 'DashboardGridItem: placed InvAvgUsage on Stock Activity, ProductAvgUsage on Products';

----------------------------------------------------------------------
-- 3. Verify
----------------------------------------------------------------------
SELECT 'Stock Activity' AS Grid, DataSet, VisualisationId, SortOrder, IsDeleted
FROM dbo.DashboardGridItem
WHERE DashboardGridId = @StockActivityGrid
ORDER BY SortOrder;

SELECT 'Products' AS Grid, DataSet, VisualisationId, SortOrder, IsDeleted
FROM dbo.DashboardGridItem
WHERE DashboardGridId = @ProductsGrid
ORDER BY SortOrder;
