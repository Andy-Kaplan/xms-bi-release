-- =============================================================================
-- Punch Pubs - Demo Dashboard 3 - new card: Tip Rate by Payment Type
-- =============================================================================
-- Tests the owner's hypothesis that table service drives gratuity:
--   tip_rate = SUM(gratuity lines) / SUM(non-gratuity revenue lines), per tender.
-- Computed at line-item level (each line carries its own Payment_Type), so
-- split-bill transactions don't get mis-attributed.
--
-- Run order:
--   PART 1 -> UAT MI core DB  (xms-bi-uat, database = core)
--   PART 2 -> UAT report DB   (xms-mssql-ne-uat, database = report)
-- =============================================================================


-- =============================================================================
-- PART 1: MI core DB (database = core)
-- =============================================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionTipRateByTender', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName
   AND tgt.Status = src.Status
   AND tgt.Version = src.Version
WHEN MATCHED THEN
UPDATE SET
    [VisualizationType] = N'BarChartCard',
    [QueryTemplate] = N'WITH base AS (
    SELECT [Payment_Type], [Item_Name], [Item_ID], [Item_Value]
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
),
tender_agg AS (
    SELECT
        ISNULL([Payment_Type], ''(Unknown)'') AS Tender,
        SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Gratuity,
        SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS NetRevenue
    FROM base
    GROUP BY ISNULL([Payment_Type], ''(Unknown)'')
),
tender_rate AS (
    SELECT Tender,
           CAST(100.0 * Gratuity / NULLIF(NetRevenue, 0) AS DECIMAL(6,2)) AS TipRatePct
    FROM tender_agg
    WHERE NetRevenue > 0
)
SELECT
    Tender AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY TipRatePct DESC) AS BarLabelSort,
    TipRatePct AS BarValue,
    ROW_NUMBER() OVER(ORDER BY TipRatePct) AS BarValueSort
FROM tender_rate

SELECT
    ''Payment Type'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Tip Rate by Payment Type'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
    [ParameterMappings] = N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}',
    [FilterDefinitions] = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
    [Description] = N'Tip rate (gratuity / non-gratuity revenue) per payment type. Computed at line-item level so split-bill transactions are attributed to the actual tender that paid each line.',
    [OutputDefinitions] = N'{"column_mappings": {}, "additional_datasets": []}',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionTipRateByTender', N'BarChartCard', 1, N'LIVE',
        N'WITH base AS (
    SELECT [Payment_Type], [Item_Name], [Item_ID], [Item_Value]
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
),
tender_agg AS (
    SELECT
        ISNULL([Payment_Type], ''(Unknown)'') AS Tender,
        SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Gratuity,
        SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS NetRevenue
    FROM base
    GROUP BY ISNULL([Payment_Type], ''(Unknown)'')
),
tender_rate AS (
    SELECT Tender,
           CAST(100.0 * Gratuity / NULLIF(NetRevenue, 0) AS DECIMAL(6,2)) AS TipRatePct
    FROM tender_agg
    WHERE NetRevenue > 0
)
SELECT
    Tender AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY TipRatePct DESC) AS BarLabelSort,
    TipRatePct AS BarValue,
    ROW_NUMBER() OVER(ORDER BY TipRatePct) AS BarValueSort
FROM tender_rate

SELECT
    ''Payment Type'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Tip Rate by Payment Type'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
        N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'Tip rate (gratuity / non-gratuity revenue) per payment type. Computed at line-item level so split-bill transactions are attributed to the actual tender that paid each line.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(),
        N'{"column_mappings": {}, "additional_datasets": []}', NULL);

PRINT '1. RedLionTipRateByTender - upserted (BarChartCard)';


-- =============================================================================
-- PART 2: Report DB (database = report on xms-mssql-ne-uat)
-- =============================================================================

-- Org:                Punch Pubs - Trial = 8381A215-4601-F111-8D4C-000D3AB579E6
-- Demo Dashboard 3:   CA832FD3-DA27-F111-9A49-000D3AB27214
-- BarChartCard cfg:   358201FC-DD27-F111-9A49-000D3AB27214 (already exists for org)


-- 2a. Wire RedLionTipRateByTender to BarChartCard config (idempotent)
IF NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap
    WHERE VisualisationConfigId = '358201FC-DD27-F111-9A49-000D3AB27214'
      AND DataSet = N'RedLionTipRateByTender'
)
BEGIN
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES ('358201FC-DD27-F111-9A49-000D3AB27214', N'RedLionTipRateByTender', 0);

    PRINT '2a. DataSetMap inserted for RedLionTipRateByTender';
END
ELSE
BEGIN
    PRINT '2a. DataSetMap already exists for RedLionTipRateByTender - skipped';
END;


-- 2b. Place new card on Demo Dashboard 3, full width, after the staff cards
IF NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem
    WHERE DashboardGridId = 'CA832FD3-DA27-F111-9A49-000D3AB27214'
      AND DataSet = N'RedLionTipRateByTender'
      AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('CA832FD3-DA27-F111-9A49-000D3AB27214', 12, 12, 12, 12, 12,
         1, N'RedLionTipRateByTender', 4, 0);

    PRINT '2b. Grid item placed on Demo Dashboard 3 (sort 4, full width, BarChartCard)';
END
ELSE
BEGIN
    PRINT '2b. Grid item already exists for RedLionTipRateByTender - skipped';
END;
