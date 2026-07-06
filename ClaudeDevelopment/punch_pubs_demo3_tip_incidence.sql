-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: tip incidence by tender (StackedBarChartCard)
-- =============================================================================
-- One bar per payment type, stacked by tipped vs not-tipped settlement count.
-- Uses (Transaction_ID, Payment_Type) settlements as the count unit.
--
-- Run order:
--   PART 1 -> UAT MI core DB  (xms-bi-uat, database = core)
--   PART 2 -> UAT report DB   (xms-mssql-ne-uat, database = report)
-- =============================================================================


-- =============================================================================
-- PART 1: MI core DB (database = core)
-- =============================================================================

DECLARE @ParamMap NVARCHAR(MAX) =
    N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}';
DECLARE @FilterDef NVARCHAR(MAX) =
    N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}';
DECLARE @OutDef NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';

DECLARE @QInc NVARCHAR(MAX) = N'WITH sessions AS (
    SELECT [Transaction_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [Transaction_ID], [Payment_Type]
),
counts AS (
    SELECT Tender, ''With Gratuity'' AS TipStatus, COUNT(*) AS Cnt, 1 AS StatusSort
    FROM sessions WHERE Tip > 0
    GROUP BY Tender
    UNION ALL
    SELECT Tender, ''Without Gratuity'' AS TipStatus, COUNT(*) AS Cnt, 2 AS StatusSort
    FROM sessions WHERE Tip = 0
    GROUP BY Tender
)
SELECT
    Tender AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY Tender) AS LabelSort,
    Cnt AS Value,
    DENSE_RANK() OVER(ORDER BY Cnt) AS ValueSort,
    TipStatus AS VisId,
    ''A'' AS Stack
FROM counts

SELECT
    ''Payment Type'' AS XAxisLabel,
    ''Order Count'' AS YAxisLabel,
    ''Tip Incidence by Payment Type'' AS Title,
    ''Count of settlements (transaction-tender pairs) with vs without gratuity.'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionTipIncidenceByTender', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'StackedBarChartCard',
    [QueryTemplate] = @QInc,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Tipped vs untipped settlement counts by payment type. One stacked bar per tender.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionTipIncidenceByTender', N'StackedBarChartCard', 1, N'LIVE', @QInc,
        @ParamMap, @FilterDef,
        N'Tipped vs untipped settlement counts by payment type. One stacked bar per tender.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '1. RedLionTipIncidenceByTender - upserted (StackedBarChartCard)';


-- =============================================================================
-- PART 2: Report DB (database = report on xms-mssql-ne-uat)
-- =============================================================================
--   Org:                  Punch Pubs - Trial = 8381A215-4601-F111-8D4C-000D3AB579E6
--   Demo Dashboard 3:     CA832FD3-DA27-F111-9A49-000D3AB27214
--   StackedBarChartCard:  C18CA0A8-EBCB-4BE6-95C7-BC52340D460A (existing, VisId 11)

DECLARE @StackBarCfgId UNIQUEIDENTIFIER = 'C18CA0A8-EBCB-4BE6-95C7-BC52340D460A';
DECLARE @GridId UNIQUEIDENTIFIER = 'CA832FD3-DA27-F111-9A49-000D3AB27214';

IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @StackBarCfgId
                 AND DataSet = N'RedLionTipIncidenceByTender' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@StackBarCfgId, N'RedLionTipIncidenceByTender', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId
                 AND DataSet = N'RedLionTipIncidenceByTender' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 12, 12, 12, 11, N'RedLionTipIncidenceByTender', 8, 0);

PRINT '2. DataSetMap + Grid item placed for RedLionTipIncidenceByTender (full width, sort 8)';
