-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: Fix vis queries + report DB wiring
-- Target: Run Part 1 on UAT core (MI), Part 2 on UAT report (microservice)
-- =============================================================================

-- =====================
-- PART 1: MI core DB
-- =====================

-- 1a. Fix RedLionStaffATV — change to StackedBarChartCard (matches all Punch Pubs vis queries)
--     and use correct output columns with numeric sort
UPDATE [core].[core].[VisualisationQueries]
SET [VisualizationType] = N'StackedBarChartCard',
    [QueryTemplate] = N'WITH base_data AS (
    SELECT [Location_Name], [Revenue_Center], [Transaction_ID],
           [Trading_Date], [Sold_Time], [User_Name],
           [Item_ID], [Item_Name], [Item_Value], [Item_Tax_Value],
           [Voided], [Sub_Group_Name], [Group_Name], [Category_Name],
           [Payment_Type], [Day_Of_Week]
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    AND [Item_ID] > 0
    @FilterClause
),
staff_atv AS (
    SELECT
        [User_Name],
        ROUND(SUM([Item_Value]) / NULLIF(COUNT(DISTINCT [Transaction_ID]), 0), 2) AS ATV,
        COUNT(DISTINCT [Transaction_ID]) AS Tx_Count
    FROM base_data
    GROUP BY [User_Name]
)
SELECT
    [User_Name] AS XAxisLabel,
    ROW_NUMBER() OVER(ORDER BY ATV DESC) AS LabelSort,
    ATV AS Value,
    ROW_NUMBER() OVER(ORDER BY ATV) AS ValueSort,
    ''ATV'' AS VisId,
    ''A'' AS Stack
FROM staff_atv

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Avg Transaction Value'' AS YAxisLabel,
    ''Staff League Table - Average Transaction Value'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    (SELECT ROUND(SUM([Item_Value]) / NULLIF(COUNT(DISTINCT [Transaction_ID]), 0), 2)
     FROM (SELECT [Item_Value], [Transaction_ID]
           FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
           WHERE [Voided] = ''FALSE'' AND [Item_ID] > 0
           @FilterClause) SUB) AS Value',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionStaffATV'
AND [Status] = N'LIVE';

-- 1b. Fix RedLionStaffCatMix — use numeric LabelSort/ValueSort
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH base_data AS (
    SELECT [Location_Name], [Revenue_Center], [Transaction_ID],
           [Trading_Date], [Sold_Time], [User_Name],
           [Item_ID], [Item_Name], [Item_Value], [Item_Tax_Value],
           [Voided], [Sub_Group_Name], [Group_Name], [Category_Name],
           [Payment_Type], [Day_Of_Week]
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    AND [Item_ID] > 0
    @FilterClause
),
staff_cat AS (
    SELECT
        [User_Name],
        [Group_Name],
        SUM([Item_Value]) AS Revenue
    FROM base_data
    WHERE [Group_Name] IS NOT NULL
    GROUP BY [User_Name], [Group_Name]
),
staff_order AS (
    SELECT DISTINCT [User_Name],
           DENSE_RANK() OVER(ORDER BY [User_Name]) AS UserSort
    FROM staff_cat
)
SELECT
    sc.[User_Name] AS XAxisLabel,
    so.UserSort AS LabelSort,
    sc.Revenue AS Value,
    so.UserSort AS ValueSort,
    sc.[Group_Name] AS VisId,
    ''A'' AS Stack
FROM staff_cat sc
JOIN staff_order so ON sc.[User_Name] = so.[User_Name]

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Revenue'' AS YAxisLabel,
    ''Product Category Mix by Staff'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    (SELECT ROUND(SUM([Item_Value]), 2)
     FROM (SELECT [Item_Value]
           FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
           WHERE [Voided] = ''FALSE'' AND [Item_ID] > 0
           @FilterClause) SUB) AS Value',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionStaffCatMix'
AND [Status] = N'LIVE';

PRINT 'Fixed both vis queries on MI';

-- =====================
-- PART 2: Report DB
-- =====================

-- 2a. Move RedLionStaffATV DataSetMap back to VisId 11 (StackedBarChartCard)
UPDATE dbo.VisualisationDataSetMap
SET VisualisationConfigId = 'C18CA0A8-EBCB-4BE6-95C7-BC52340D460A'
WHERE DataSet = N'RedLionStaffATV'
AND VisualisationConfigId IN (
    SELECT VisualisationConfigId FROM dbo.VisualisationConfig
    WHERE OrganisationId = '8381A215-4601-F111-8D4C-000D3AB579E6'
    AND VisualisationId = 1
);

-- 2b. Fix DashboardGridItem back to VisId 11
UPDATE dbo.DashboardGridItem
SET VisualisationId = 11
WHERE DashboardGridId = 'CA832FD3-DA27-F111-9A49-000D3AB27214'
AND DataSet = N'RedLionStaffATV';

-- 2c. Clean up the unnecessary VisId 1 config
UPDATE dbo.VisualisationConfig
SET IsDeleted = 1
WHERE OrganisationId = '8381A215-4601-F111-8D4C-000D3AB579E6'
AND VisualisationId = 1;

PRINT 'Fixed report DB wiring - StaffATV back to VisId 11';
