-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: replace basic Tip Rate bar with three richer cards
-- =============================================================================
-- Cards:
--   * RedLionTipRateByDay     (NEW)   MultiLineChartCard  - daily tip rate per tender
--   * RedLionATVByTender      (NEW)   BarChartCard        - avg spend per tender per tx
--   * RedLionTipRateByBillSize(NEW)   MultiLineChartCard  - tip rate by bill-size bucket per tender (like-for-like)
--   * RedLionTipRateByTender  RETIRE  remove old basic bar and its grid placement
--
-- Run order:
--   PART 1 -> UAT MI core DB  (xms-bi-uat, database = core)
--   PART 2 -> UAT report DB   (xms-mssql-ne-uat, database = report)
-- =============================================================================


-- =============================================================================
-- PART 1: MI core DB (database = core)
-- =============================================================================

-- 1a. Retire the basic single-bar TipRateByTender query
UPDATE [core].[core].[VisualisationQueries]
SET [Status] = N'RETIRED',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionTipRateByTender'
  AND [Status] = N'LIVE';

PRINT '1a. RedLionTipRateByTender retired';


-- 1b. Common JSON blobs reused by all three new RedLion queries
DECLARE @ParamMap NVARCHAR(MAX) =
    N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}';
DECLARE @FilterDef NVARCHAR(MAX) =
    N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}';
DECLARE @OutDef NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';


-- 1c. RedLionTipRateByDay - MultiLineChartCard
DECLARE @QDay NVARCHAR(MAX) = N'WITH agg AS (
    SELECT CONVERT(DATE, [Trading_Date]) AS d,
           ISNULL([Payment_Type], ''(Unknown)'') AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS NetRev
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
    GROUP BY CONVERT(DATE, [Trading_Date]), ISNULL([Payment_Type], ''(Unknown)'')
)
SELECT
    CONVERT(NVARCHAR(10), d, 23) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY d) AS LabelSort,
    CAST(100.0 * Tip / NULLIF(NetRev, 0) AS DECIMAL(6,2)) AS Value,
    DENSE_RANK() OVER(ORDER BY CAST(100.0 * Tip / NULLIF(NetRev, 0) AS DECIMAL(6,2))) AS ValueSort,
    1 AS VisId,
    ''line'' AS VisType,
    Tender AS LegendLabel
FROM agg
WHERE NetRev > 0

SELECT
    ''Trading Date'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Daily Tip Rate by Payment Type'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionTipRateByDay', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'MultiLineChartCard',
    [QueryTemplate] = @QDay,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Daily tip rate (gratuity / non-gratuity revenue) per payment type, line per tender.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionTipRateByDay', N'MultiLineChartCard', 1, N'LIVE', @QDay,
        @ParamMap, @FilterDef,
        N'Daily tip rate (gratuity / non-gratuity revenue) per payment type, line per tender.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '1c. RedLionTipRateByDay - upserted (MultiLineChartCard)';


-- 1d. RedLionATVByTender - BarChartCard
DECLARE @QATV NVARCHAR(MAX) = N'WITH sessions AS (
    SELECT [Transaction_ID],
           ISNULL([Payment_Type], ''(Unknown)'') AS Tender,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
    GROUP BY [Transaction_ID], ISNULL([Payment_Type], ''(Unknown)'')
)
SELECT
    Tender AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY AVG(Bill) DESC) AS BarLabelSort,
    CAST(AVG(Bill) AS DECIMAL(10,2)) AS BarValue,
    ROW_NUMBER() OVER(ORDER BY AVG(Bill)) AS BarValueSort
FROM sessions
WHERE Bill > 0
GROUP BY Tender

SELECT
    ''Payment Type'' AS XAxisLabel,
    ''Avg Spend ('' + NCHAR(163) + '')'' AS YAxisLabel,
    ''Avg Spend per Transaction by Payment Type'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionATVByTender', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'BarChartCard',
    [QueryTemplate] = @QATV,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Average spend per transaction-tender pair, by payment type. Each (transaction_id, payment_type) pair is treated as one settlement; the average is across these pairs per tender.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionATVByTender', N'BarChartCard', 1, N'LIVE', @QATV,
        @ParamMap, @FilterDef,
        N'Average spend per transaction-tender pair, by payment type. Each (transaction_id, payment_type) pair is treated as one settlement; the average is across these pairs per tender.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '1d. RedLionATVByTender - upserted (BarChartCard)';


-- 1e. RedLionTipRateByBillSize - MultiLineChartCard (like-for-like)
DECLARE @QBkt NVARCHAR(MAX) = N'WITH sessions AS (
    SELECT [Transaction_ID],
           ISNULL([Payment_Type], ''(Unknown)'') AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
    GROUP BY [Transaction_ID], ISNULL([Payment_Type], ''(Unknown)'')
),
bucketed AS (
    SELECT Tender, Tip, Bill,
           CASE WHEN Bill < 20  THEN 1
                WHEN Bill < 50  THEN 2
                WHEN Bill < 100 THEN 3
                WHEN Bill < 200 THEN 4
                ELSE 5 END AS BucketSort,
           CASE WHEN Bill < 20  THEN ''Under '' + NCHAR(163) + ''20''
                WHEN Bill < 50  THEN NCHAR(163) + ''20-50''
                WHEN Bill < 100 THEN NCHAR(163) + ''50-100''
                WHEN Bill < 200 THEN NCHAR(163) + ''100-200''
                ELSE NCHAR(163) + ''200+'' END AS Bucket
    FROM sessions
    WHERE Bill > 0
)
SELECT
    Bucket AS XAxisLabel,
    BucketSort AS LabelSort,
    CAST(100.0 * SUM(Tip) / NULLIF(SUM(Bill), 0) AS DECIMAL(6,2)) AS Value,
    DENSE_RANK() OVER(ORDER BY CAST(100.0 * SUM(Tip) / NULLIF(SUM(Bill), 0) AS DECIMAL(6,2))) AS ValueSort,
    1 AS VisId,
    ''line'' AS VisType,
    Tender AS LegendLabel
FROM bucketed
GROUP BY Tender, Bucket, BucketSort

SELECT
    ''Bill Size Bucket'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Tip Rate by Bill Size (Like-for-Like)'' AS Title,
    ''Tip rate at comparable bill sizes - controls for the fact that EFT carries smaller transactions.'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionTipRateByBillSize', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'MultiLineChartCard',
    [QueryTemplate] = @QBkt,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Like-for-like tip rate per payment type, faceted by bill-size bucket - controls for the volume mix between counter and table service.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionTipRateByBillSize', N'MultiLineChartCard', 1, N'LIVE', @QBkt,
        @ParamMap, @FilterDef,
        N'Like-for-like tip rate per payment type, faceted by bill-size bucket - controls for the volume mix between counter and table service.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '1e. RedLionTipRateByBillSize - upserted (MultiLineChartCard)';


-- =============================================================================
-- PART 2: Report DB (database = report on xms-mssql-ne-uat)
-- =============================================================================
--   Org:                 Punch Pubs - Trial = 8381A215-4601-F111-8D4C-000D3AB579E6
--   Demo Dashboard 3:    CA832FD3-DA27-F111-9A49-000D3AB27214
--   BarChartCard cfg:    358201FC-DD27-F111-9A49-000D3AB27214 (existing for org)
--   MultiLineChartCard:  VisId 8 - org has no config yet, provision below

-- 2a. Soft-delete the old basic Tip Rate bar from the dashboard
UPDATE dbo.DashboardGridItem
SET IsDeleted = 1
WHERE DashboardGridId = 'CA832FD3-DA27-F111-9A49-000D3AB27214'
  AND DataSet = N'RedLionTipRateByTender'
  AND IsDeleted = 0;

UPDATE dbo.VisualisationDataSetMap
SET IsDeleted = 1
WHERE DataSet = N'RedLionTipRateByTender'
  AND IsDeleted = 0;

PRINT '2a. RedLionTipRateByTender grid + map soft-deleted';


-- 2b. Provision MultiLineChartCard config (VisId 8) for org if missing
DECLARE @MultiLineCfgId UNIQUEIDENTIFIER = (
    SELECT TOP 1 VisualisationConfigId
    FROM dbo.VisualisationConfig
    WHERE OrganisationId = '8381A215-4601-F111-8D4C-000D3AB579E6'
      AND VisualisationId = 8
      AND IsDeleted = 0
);

IF @MultiLineCfgId IS NULL
BEGIN
    DECLARE @CfgOut TABLE (Id UNIQUEIDENTIFIER);
    INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, ActiveUntil, IsDeleted)
    OUTPUT inserted.VisualisationConfigId INTO @CfgOut
    VALUES ('8381A215-4601-F111-8D4C-000D3AB579E6', 8, GETDATE(), NULL, 0);
    SELECT @MultiLineCfgId = Id FROM @CfgOut;
    PRINT '2b. Provisioned new VisualisationConfig for VisId 8 (MultiLineChartCard)';
END
ELSE
BEGIN
    PRINT '2b. VisualisationConfig for VisId 8 already exists - reusing';
END;


-- 2c. Wire datasets to configs (idempotent)
DECLARE @BarCfgId UNIQUEIDENTIFIER = '358201FC-DD27-F111-9A49-000D3AB27214';

IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @MultiLineCfgId
                 AND DataSet = N'RedLionTipRateByDay' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@MultiLineCfgId, N'RedLionTipRateByDay', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @BarCfgId
                 AND DataSet = N'RedLionATVByTender' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@BarCfgId, N'RedLionATVByTender', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @MultiLineCfgId
                 AND DataSet = N'RedLionTipRateByBillSize' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@MultiLineCfgId, N'RedLionTipRateByBillSize', 0);

PRINT '2c. DataSetMap rows in place for the three new datasets';


-- 2d. Place new cards on Demo Dashboard 3 (idempotent)
--     Layout: full-width daily line, then ATV + LikeForLike side by side
DECLARE @GridId UNIQUEIDENTIFIER = 'CA832FD3-DA27-F111-9A49-000D3AB27214';

IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId AND DataSet = N'RedLionTipRateByDay' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 12, 12, 12, 8, N'RedLionTipRateByDay', 5, 0);

IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId AND DataSet = N'RedLionATVByTender' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 6, 6, 6, 1, N'RedLionATVByTender', 6, 0);

IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId AND DataSet = N'RedLionTipRateByBillSize' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 6, 6, 6, 8, N'RedLionTipRateByBillSize', 7, 0);

PRINT '2d. Grid items placed: TipRateByDay (full), ATVByTender + TipRateByBillSize (half each)';
