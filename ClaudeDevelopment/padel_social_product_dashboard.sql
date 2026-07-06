-- ============================================================
-- Script: padel_social_product_dashboard.sql
-- Purpose: Enable product visualisations and inventory value KPIs
--          for Padel Social on the UAT report database.
--
-- Target:  UAT report database (xms-mssql-ne-uat, database: report)
-- Org:     Padel Social (94A4B719-EB0F-421F-AD03-ABECDD888B14)
--
-- Changes:
--   Part 1: Enable SingleKPICard (VisId 10) + 8 KPI datasets
--   Part 2: Add product + inventory datasets to existing card types
--   Part 3: Create "Products" dashboard with 6 cards + 2 filters
--   Part 4: Add InvMargeBrut + InvKPIGrouped to Cost & Margins
--   Part 5: Add value KPIs + InvTop20Variance + InvCountData
--           to Stock Activity
--
-- Idempotent: safe to re-run (all INSERTs guarded by NOT EXISTS)
--
-- Evaluated datasets:
--   READY:  ProductMargins (Pie/StackedBar/MultiLine/Combined),
--           TopProducts (Grid), UniqueProductsSold (KPI),
--           ProductComparison (Grid)
--   SKIP:   ProductCount (legacy [threerocks] prototype),
--           ProductNetSales (legacy prototype),
--           ProductGC (needs POS co-occurrence data),
--           ProductMarginsChannel (no channel data in Growyze)
-- ============================================================

DECLARE @OrgId UNIQUEIDENTIFIER = '94A4B719-EB0F-421F-AD03-ABECDD888B14';

-- Existing VisualisationConfig IDs for Padel Social
DECLARE @BarChartConfigId      UNIQUEIDENTIFIER = 'AAF367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId  1
DECLARE @CombinedConfigId      UNIQUEIDENTIFIER = 'ABF367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId  2
DECLARE @DataGridConfigId      UNIQUEIDENTIFIER = 'ACF367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId  3
DECLARE @GroupedGridConfigId   UNIQUEIDENTIFIER = 'ADF367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId  4
DECLARE @MultiLineConfigId     UNIQUEIDENTIFIER = 'AEF367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId  8
DECLARE @PieChartConfigId      UNIQUEIDENTIFIER = 'AFF367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId  9
DECLARE @StackedBarConfigId    UNIQUEIDENTIFIER = 'B0F367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId 11
DECLARE @FilterListConfigId    UNIQUEIDENTIFIER = 'B1F367B8-5E1D-F111-832F-000D3AB27D87';  -- VisId 14

-- Existing DashboardGrid IDs
DECLARE @CostMarginsGridId     UNIQUEIDENTIFIER = '7C83F241-9CD7-4326-B659-109CF4408793';  -- Sort 1
DECLARE @StockActivityGridId   UNIQUEIDENTIFIER = '7ED51BEF-1DEE-496F-8B83-09BF7E357F1B';  -- Sort 2
DECLARE @PeriodAnalysisGridId  UNIQUEIDENTIFIER = 'D07AC385-36C4-424B-922B-406D6A00B4B3';  -- Sort 3

-- ============================================================
-- PART 1: Enable SingleKPICard (VisualisationId = 10)
-- ============================================================

DECLARE @KPIConfigId UNIQUEIDENTIFIER;

IF NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationConfig
    WHERE OrganisationId = @OrgId AND VisualisationId = 10 AND IsDeleted = 0
)
BEGIN
    DECLARE @KPIOutput TABLE (Id UNIQUEIDENTIFIER);

    INSERT INTO dbo.VisualisationConfig
        (OrganisationId, VisualisationId, ActiveFrom, IsDeleted)
    OUTPUT inserted.VisualisationConfigId INTO @KPIOutput
    VALUES (@OrgId, 10, SYSUTCDATETIME(), 0);

    SELECT @KPIConfigId = Id FROM @KPIOutput;
END
ELSE
BEGIN
    SELECT @KPIConfigId = VisualisationConfigId
    FROM dbo.VisualisationConfig
    WHERE OrganisationId = @OrgId AND VisualisationId = 10 AND IsDeleted = 0;
END;

-- KPI datasets: product + inventory value
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @KPIConfigId, ds.DataSet, 0
FROM (VALUES
    (N'UniqueProductsSold'),
    (N'InvWasteCost'),
    (N'InvOrdersCost'),
    (N'InvNegVar'),
    (N'InvPosVar'),
    (N'InvNetSales'),
    (N'InvProdEventCost'),
    (N'InvProdEventValue')
) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @KPIConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- ============================================================
-- PART 2: Add product + inventory datasets to existing cards
-- ============================================================

-- CombinedChartCard (VisId 2) -- ProductMargins
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @CombinedConfigId, ds.DataSet, 0
FROM (VALUES (N'ProductMargins')) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @CombinedConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- CustomDataGrid (VisId 3) -- TopProducts, ProductComparison, InvCountData
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @DataGridConfigId, ds.DataSet, 0
FROM (VALUES
    (N'TopProducts'),
    (N'ProductComparison'),
    (N'InvCountData')
) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @DataGridConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- CustomGroupedDataGrid (VisId 4) -- InvKPIGrouped
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @GroupedGridConfigId, ds.DataSet, 0
FROM (VALUES (N'InvKPIGrouped')) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @GroupedGridConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- MultiLineChartCard (VisId 8) -- ProductMargins
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @MultiLineConfigId, ds.DataSet, 0
FROM (VALUES (N'ProductMargins')) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @MultiLineConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- PieChartCard (VisId 9) -- ProductMargins
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @PieChartConfigId, ds.DataSet, 0
FROM (VALUES (N'ProductMargins')) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @PieChartConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- StackedBarChartCard (VisId 11) -- ProductMargins, InvTop20Variance
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @StackedBarConfigId, ds.DataSet, 0
FROM (VALUES
    (N'ProductMargins'),
    (N'InvTop20Variance')
) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @StackedBarConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- FilterList (VisId 14) -- Products filter
INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT @FilterListConfigId, ds.DataSet, 0
FROM (VALUES (N'Products')) AS ds(DataSet)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = @FilterListConfigId
      AND DataSet = ds.DataSet AND IsDeleted = 0
);

-- ============================================================
-- PART 3: Create "Products" dashboard
-- ============================================================

DECLARE @ProductsGridId UNIQUEIDENTIFIER;

IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Products' AND IsDeleted = 0
)
BEGIN
    DECLARE @GridOutput TABLE (Id UNIQUEIDENTIFIER);

    INSERT INTO dbo.DashboardGrid (Container, Spacing, Columns, IsDeleted)
    OUTPUT inserted.DashboardGridId INTO @GridOutput
    VALUES (1, 2, 12, 0);

    SELECT @ProductsGridId = Id FROM @GridOutput;

    INSERT INTO dbo.OrganisationDashboardConfig
        (DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted)
    VALUES
        (@ProductsGridId, @OrgId, N'Products', N'', 4, 0);
END
ELSE
BEGIN
    SELECT @ProductsGridId = odc.DashboardGridId
    FROM dbo.OrganisationDashboardConfig odc
    WHERE odc.OrganisationId = @OrgId
      AND odc.Name = N'Products' AND odc.IsDeleted = 0;
END;

-- Dashboard layout:
--   Sort 1: UniqueProductsSold  KPI           (half width)
--   Sort 2: ProductMargins      PieChart      (half width)
--   Sort 3: ProductMargins      StackedBar    (full width)
--   Sort 4: TopProducts         DataGrid      (full width)
--   Sort 5: ProductMargins      MultiLine     (full width)
--   Sort 6: ProductComparison   DataGrid      (full width)

INSERT INTO dbo.DashboardGridItem
    (DashboardGridId, DataSet, VisualisationId, SortOrder,
     ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
SELECT @ProductsGridId, v.DataSet, v.VisId, v.SortOrder,
       v.XS, v.S, v.M, v.L, v.XL, 0
FROM (VALUES
    (N'UniqueProductsSold', 10, 1,  12, 12, 6, 6, 6),
    (N'ProductMargins',      9, 2,  12, 12, 6, 6, 6),
    (N'ProductMargins',     11, 3,  12, 12, 12, 12, 12),
    (N'TopProducts',         3, 4,  12, 12, 12, 12, 12),
    (N'ProductMargins',      8, 5,  12, 12, 12, 12, 12),
    (N'ProductComparison',   3, 6,  12, 12, 12, 12, 12)
) AS v(DataSet, VisId, SortOrder, XS, S, M, L, XL)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem
    WHERE DashboardGridId = @ProductsGridId
      AND DataSet = v.DataSet
      AND VisualisationId = v.VisId
      AND IsDeleted = 0
);

-- Products dashboard filters: Locations + Products
INSERT INTO dbo.DashboardGridFilter
    (DashboardGridId, DataSet, SortOrder, IsDeleted)
SELECT @ProductsGridId, v.DataSet, v.SortOrder, 0
FROM (VALUES
    (N'Locations', 1),
    (N'Products',  2)
) AS v(DataSet, SortOrder)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter
    WHERE DashboardGridId = @ProductsGridId
      AND DataSet = v.DataSet AND IsDeleted = 0
);

-- ============================================================
-- PART 4: Cost & Margins — add InvMargeBrut + InvKPIGrouped
-- (appended after existing 3 cards)
-- ============================================================

INSERT INTO dbo.DashboardGridItem
    (DashboardGridId, DataSet, VisualisationId, SortOrder,
     ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
SELECT @CostMarginsGridId, v.DataSet, v.VisId, v.SortOrder,
       v.XS, v.S, v.M, v.L, v.XL, 0
FROM (VALUES
    -- InvMargeBrut: Gross margin tree (Location > Category)
    (N'InvMargeBrut',  4, 4,  12, 12, 12, 12, 12),
    -- InvKPIGrouped: Full KPI tree (Location > Category > Subcategory > Item)
    (N'InvKPIGrouped', 4, 5,  12, 12, 12, 12, 12)
) AS v(DataSet, VisId, SortOrder, XS, S, M, L, XL)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem
    WHERE DashboardGridId = @CostMarginsGridId
      AND DataSet = v.DataSet
      AND VisualisationId = v.VisId
      AND IsDeleted = 0
);

-- ============================================================
-- PART 5: Stock Activity — add value KPIs + variance + counts
-- (appended after existing 7 cards)
--
-- NOTE: KPIs appear at the bottom (sort 8-10). If you prefer
-- them at the top, renumber existing items from 4 upward and
-- set these to sort 1-3.
-- ============================================================

INSERT INTO dbo.DashboardGridItem
    (DashboardGridId, DataSet, VisualisationId, SortOrder,
     ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
SELECT @StockActivityGridId, v.DataSet, v.VisId, v.SortOrder,
       v.XS, v.S, v.M, v.L, v.XL, 0
FROM (VALUES
    -- Three value KPIs in a row (1/3 width each)
    (N'InvWasteCost',      10,  8,  12, 12, 4, 4, 4),
    (N'InvOrdersCost',     10,  9,  12, 12, 4, 4, 4),
    (N'InvNegVar',         10, 10,  12, 12, 4, 4, 4),
    -- Top 20 variance items by value
    (N'InvTop20Variance',  11, 11,  12, 12, 12, 12, 12),
    -- Count compliance detail grid
    (N'InvCountData',       3, 12,  12, 12, 12, 12, 12)
) AS v(DataSet, VisId, SortOrder, XS, S, M, L, XL)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem
    WHERE DashboardGridId = @StockActivityGridId
      AND DataSet = v.DataSet
      AND VisualisationId = v.VisId
      AND IsDeleted = 0
);

-- ============================================================
-- Verification queries (run after deployment to confirm)
-- ============================================================

-- Check VisualisationConfig count (should be 9: 8 existing + 1 new KPI)
SELECT 'VisualisationConfig' AS [Check], COUNT(*) AS Cnt
FROM dbo.VisualisationConfig
WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND IsDeleted = 0;

-- Check VisualisationDataSetMap count per card type
SELECT vp.ProcedureName, COUNT(vdsm.DataSet) AS DataSets
FROM dbo.VisualisationConfig vc
INNER JOIN dbo.VisualisationProcedure vp ON vc.VisualisationId = vp.VisualisationId
INNER JOIN dbo.VisualisationDataSetMap vdsm ON vc.VisualisationConfigId = vdsm.VisualisationConfigId
WHERE vc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND vc.IsDeleted = 0 AND vdsm.IsDeleted = 0
GROUP BY vp.ProcedureName
ORDER BY vp.ProcedureName;

-- Check dashboard card count
SELECT odc.Name AS Dashboard, COUNT(dgi.DashboardGridItemId) AS Cards
FROM dbo.OrganisationDashboardConfig odc
INNER JOIN dbo.DashboardGridItem dgi ON odc.DashboardGridId = dgi.DashboardGridId
WHERE odc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND odc.IsDeleted = 0 AND dgi.IsDeleted = 0
GROUP BY odc.Name, odc.SortOrder
ORDER BY odc.SortOrder;

-- List all datasets now available
SELECT odc.Name AS Dashboard, dgi.DataSet, vp.ProcedureName AS CardType, dgi.SortOrder
FROM dbo.OrganisationDashboardConfig odc
INNER JOIN dbo.DashboardGridItem dgi ON odc.DashboardGridId = dgi.DashboardGridId
INNER JOIN dbo.VisualisationProcedure vp ON dgi.VisualisationId = vp.VisualisationId
WHERE odc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND odc.IsDeleted = 0 AND dgi.IsDeleted = 0
ORDER BY odc.SortOrder, dgi.SortOrder;
