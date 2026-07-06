-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: Visualisation Queries
-- Target: UAT core database (xms-bi-uat), table core.core.VisualisationQueries
-- =============================================================================

-- ============================================================
-- 1. BarChartCard — Staff ATV League Table
-- DataSetName:        RedLionStaffATV
-- VisualizationType:  BarChartCard
-- Generated:          2026-03-24
-- ============================================================
INSERT INTO [core].[core].[VisualisationQueries]
(
     [DataSetName]
    ,[VisualizationType]
    ,[Version]
    ,[Status]
    ,[QueryTemplate]
    ,[ParameterMappings]
    ,[FilterDefinitions]
    ,[Description]
    ,[CreatedDate]
    ,[ModifiedDate]
    ,[CreatedBy]
    ,[ModifiedBy]
    ,[OutputDefinitions]
    ,[ExecutionQuery]
)
VALUES
(
     N'RedLionStaffATV'
    ,N'BarChartCard'
    ,1
    ,N'LIVE'
    ,N'WITH base_data AS (
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
    (SELECT ROUND(SUM([Item_Value]) / NULLIF(COUNT(DISTINCT [Transaction_ID]), 0), 2)
     FROM (SELECT [Item_Value], [Transaction_ID]
           FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
           WHERE [Voided] = ''FALSE'' AND [Item_ID] > 0
           @FilterClause) SUB) AS TotalValue,
    NULL AS Chip'
    ,N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}'
    ,N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}'
    ,N'Staff league table ranked by average transaction value (net sales / distinct transactions per staff member)'
    ,GETDATE()
    ,GETDATE()
    ,SUSER_SNAME()
    ,SUSER_SNAME()
    ,N'{"column_mappings": {}, "additional_datasets": []}'
    ,NULL
);

-- ============================================================
-- 2. StackedBarChartCard — Product Category Mix by Staff
-- DataSetName:        RedLionStaffCatMix
-- VisualizationType:  StackedBarChartCard
-- Generated:          2026-03-24
-- ============================================================
INSERT INTO [core].[core].[VisualisationQueries]
(
     [DataSetName]
    ,[VisualizationType]
    ,[Version]
    ,[Status]
    ,[QueryTemplate]
    ,[ParameterMappings]
    ,[FilterDefinitions]
    ,[Description]
    ,[CreatedDate]
    ,[ModifiedDate]
    ,[CreatedBy]
    ,[ModifiedBy]
    ,[OutputDefinitions]
    ,[ExecutionQuery]
)
VALUES
(
     N'RedLionStaffCatMix'
    ,N'StackedBarChartCard'
    ,1
    ,N'LIVE'
    ,N'WITH base_data AS (
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
)
SELECT
    [User_Name] AS XAxisLabel,
    [User_Name] AS LabelSort,
    Revenue AS Value,
    [User_Name] AS ValueSort,
    [Group_Name] AS VisId,
    ''A'' AS Stack
FROM staff_cat

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
           @FilterClause) SUB) AS Value'
    ,N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}'
    ,N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}'
    ,N'Product category (Group_Name) revenue breakdown per staff member as stacked bars'
    ,GETDATE()
    ,GETDATE()
    ,SUSER_SNAME()
    ,SUSER_SNAME()
    ,N'{"column_mappings": {}, "additional_datasets": []}'
    ,NULL
);
