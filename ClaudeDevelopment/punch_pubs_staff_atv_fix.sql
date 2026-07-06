-- =============================================================================
-- Fix RedLionStaffATV — revert to BarChartCard with correct column aliases
-- Target: UAT core (MI)
-- =============================================================================

UPDATE [core].[core].[VisualisationQueries]
SET [VisualizationType] = N'BarChartCard',
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
    NULL AS Chip',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionStaffATV'
AND [Status] = N'LIVE';

PRINT 'Fixed RedLionStaffATV - BarChartCard with correct column aliases';
