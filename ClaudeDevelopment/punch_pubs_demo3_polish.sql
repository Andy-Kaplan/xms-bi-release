-- =============================================================================
-- Punch Pubs - Demo Dashboard 3 polish for owner showcase
-- =============================================================================
-- Changes:
--   1. RedLionStaffATV       - remove headline total (NULL)
--   2. RedLionStaffCatMix    - revenue -> % of staff sales (sums to 100 per
--                              staff member); remove headline total; relabel
--                              Y-axis as "% of Sales"
--   3. RedLionStaffRevPerHour (NEW) - BarChartCard ranking staff by avg revenue
--                              per distinct (date, hour) bucket they sold in.
--                              Used as a labour-free proxy for hours worked.
--
-- Run order:
--   PART 1 -> UAT MI core DB  (xms-bi-uat, database = core)
--   PART 2 -> UAT report DB   (xms-mssql-ne-uat, database = report)
-- =============================================================================


-- =============================================================================
-- PART 1: MI core DB (database = core)
-- =============================================================================

-- 1a. RedLionStaffATV: clear headline TotalValue
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
staff_atv AS (
    SELECT
        [User_Name],
        ROUND(SUM([Item_Value]) / NULLIF(COUNT(DISTINCT [Transaction_ID]), 0), 2) AS ATV,
        COUNT(DISTINCT [Transaction_ID]) AS Tx_Count
    FROM base_data
    GROUP BY [User_Name]
)
SELECT
    [User_Name] AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY ATV DESC) AS BarLabelSort,
    ATV AS BarValue,
    ROW_NUMBER() OVER(ORDER BY ATV) AS BarValueSort
FROM staff_atv

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Avg Transaction Value'' AS YAxisLabel,
    ''Staff League Table - Average Transaction Value'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionStaffATV'
  AND [Status] = N'LIVE';

PRINT '1a. RedLionStaffATV - cleared headline total';


-- 1b. RedLionStaffCatMix: revenue -> % of staff sales, clear headline total
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
staff_totals AS (
    SELECT [User_Name], SUM(Revenue) AS StaffTotal
    FROM staff_cat
    GROUP BY [User_Name]
),
staff_order AS (
    SELECT DISTINCT [User_Name],
           DENSE_RANK() OVER(ORDER BY [User_Name]) AS UserSort
    FROM staff_cat
)
SELECT
    sc.[User_Name] AS XAxisLabel,
    so.UserSort AS LabelSort,
    ROUND(sc.Revenue * 100.0 / NULLIF(st.StaffTotal, 0), 2) AS Value,
    so.UserSort AS ValueSort,
    sc.[Group_Name] AS VisId,
    ''A'' AS Stack
FROM staff_cat sc
JOIN staff_totals st ON st.[User_Name] = sc.[User_Name]
JOIN staff_order so  ON sc.[User_Name] = so.[User_Name]

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''% of Sales'' AS YAxisLabel,
    ''Product Category Mix by Staff'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionStaffCatMix'
  AND [Status] = N'LIVE';

PRINT '1b. RedLionStaffCatMix - converted to percentage of staff sales';


-- 1c. RedLionStaffRevPerHour (NEW) - upsert via MERGE
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionStaffRevPerHour', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName
   AND tgt.Status = src.Status
   AND tgt.Version = src.Version
WHEN MATCHED THEN
UPDATE SET
    [VisualizationType] = N'BarChartCard',
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
staff_hours AS (
    SELECT
        [User_Name],
        SUM([Item_Value]) AS TotalRevenue,
        COUNT(DISTINCT CONVERT(VARCHAR(10), [Trading_Date], 23)
                       + ''-''
                       + RIGHT(''00'' + CAST(DATEPART(HOUR, [Sold_Time]) AS VARCHAR(2)), 2)) AS ActiveHours
    FROM base_data
    GROUP BY [User_Name]
),
staff_rate AS (
    SELECT [User_Name],
           ROUND(TotalRevenue / NULLIF(ActiveHours, 0), 2) AS RevPerHour
    FROM staff_hours
)
SELECT
    [User_Name] AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY RevPerHour DESC) AS BarLabelSort,
    RevPerHour AS BarValue,
    ROW_NUMBER() OVER(ORDER BY RevPerHour) AS BarValueSort
FROM staff_rate

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Avg Revenue per Active Hour'' AS YAxisLabel,
    ''Staff League Table - Revenue per Hour'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
    [ParameterMappings] = N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}',
    [FilterDefinitions] = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
    [Description] = N'Staff league table ranked by average revenue per active hour (total revenue / distinct (date, hour) buckets the staff member rang transactions in)',
    [OutputDefinitions] = N'{"column_mappings": {}, "additional_datasets": []}',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionStaffRevPerHour', N'BarChartCard', 1, N'LIVE',
        N'WITH base_data AS (
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
staff_hours AS (
    SELECT
        [User_Name],
        SUM([Item_Value]) AS TotalRevenue,
        COUNT(DISTINCT CONVERT(VARCHAR(10), [Trading_Date], 23)
                       + ''-''
                       + RIGHT(''00'' + CAST(DATEPART(HOUR, [Sold_Time]) AS VARCHAR(2)), 2)) AS ActiveHours
    FROM base_data
    GROUP BY [User_Name]
),
staff_rate AS (
    SELECT [User_Name],
           ROUND(TotalRevenue / NULLIF(ActiveHours, 0), 2) AS RevPerHour
    FROM staff_hours
)
SELECT
    [User_Name] AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY RevPerHour DESC) AS BarLabelSort,
    RevPerHour AS BarValue,
    ROW_NUMBER() OVER(ORDER BY RevPerHour) AS BarValueSort
FROM staff_rate

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Avg Revenue per Active Hour'' AS YAxisLabel,
    ''Staff League Table - Revenue per Hour'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
        N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'Staff league table ranked by average revenue per active hour (total revenue / distinct (date, hour) buckets the staff member rang transactions in)',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(),
        N'{"column_mappings": {}, "additional_datasets": []}', NULL);

PRINT '1c. RedLionStaffRevPerHour - upserted (BarChartCard)';


-- =============================================================================
-- PART 2: Report DB (database = report on xms-mssql-ne-uat)
-- =============================================================================

-- Org:                Punch Pubs - Trial = 8381A215-4601-F111-8D4C-000D3AB579E6
-- Demo Dashboard 3:   CA832FD3-DA27-F111-9A49-000D3AB27214
-- BarChartCard cfg:   358201FC-DD27-F111-9A49-000D3AB27214 (already exists for org)


-- 2a. Wire RedLionStaffRevPerHour to BarChartCard config (idempotent)
IF NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = '358201FC-DD27-F111-9A49-000D3AB27214'
      AND DataSet = N'RedLionStaffRevPerHour'
)
BEGIN
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES ('358201FC-DD27-F111-9A49-000D3AB27214', N'RedLionStaffRevPerHour', 0);

    PRINT '2a. DataSetMap inserted for RedLionStaffRevPerHour';
END
ELSE
BEGIN
    PRINT '2a. DataSetMap already exists for RedLionStaffRevPerHour - skipped';
END;


-- 2b. Place new card on Demo Dashboard 3 below the existing pair, full width
IF NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem
    WHERE DashboardGridId = 'CA832FD3-DA27-F111-9A49-000D3AB27214'
      AND DataSet = N'RedLionStaffRevPerHour'
      AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('CA832FD3-DA27-F111-9A49-000D3AB27214', 12, 12, 12, 12, 12,
         1, N'RedLionStaffRevPerHour', 3, 0);

    PRINT '2b. Grid item placed on Demo Dashboard 3 (sort 3, full width, BarChartCard)';
END
ELSE
BEGIN
    PRINT '2b. Grid item already exists for RedLionStaffRevPerHour - skipped';
END;
