-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: bucket the incidence chart + add data grid
-- =============================================================================
-- Changes:
--   * Update RedLionTipIncidenceByTender to bucket by bill-size as well as
--     tender. X-axis shows "Tender / Bucket" composite labels, stacked
--     tipped vs untipped.
--   * Add RedLionTipMatrix (CustomDataGrid) - full per-tender per-bucket
--     view: total settlements, with tip, without tip, tip incidence %,
--     tip rate %, gross net revenue, gross gratuity.
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


-- 1a. Update RedLionTipIncidenceByTender to include bill-size buckets
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH sessions AS (
    SELECT [Transaction_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [Transaction_ID], [Payment_Type]
),
bucketed AS (
    SELECT Tender, Tip, Bill,
           CASE WHEN Bill < 20  THEN 1
                WHEN Bill < 50  THEN 2
                WHEN Bill < 100 THEN 3
                WHEN Bill < 200 THEN 4
                ELSE 5 END AS BSort,
           CASE WHEN Bill < 20  THEN ''<'' + NCHAR(163) + ''20''
                WHEN Bill < 50  THEN NCHAR(163) + ''20-50''
                WHEN Bill < 100 THEN NCHAR(163) + ''50-100''
                WHEN Bill < 200 THEN NCHAR(163) + ''100-200''
                ELSE NCHAR(163) + ''200+'' END AS Bucket
    FROM sessions WHERE Bill > 0
),
counts AS (
    SELECT Tender, Bucket, BSort,
           ''With Gratuity'' AS TipStatus,
           SUM(CASE WHEN Tip > 0 THEN 1 ELSE 0 END) AS Cnt
    FROM bucketed
    GROUP BY Tender, Bucket, BSort
    UNION ALL
    SELECT Tender, Bucket, BSort,
           ''Without Gratuity'' AS TipStatus,
           SUM(CASE WHEN Tip = 0 THEN 1 ELSE 0 END) AS Cnt
    FROM bucketed
    GROUP BY Tender, Bucket, BSort
)
SELECT
    Tender + '' / '' + Bucket AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY Tender, BSort) AS LabelSort,
    Cnt AS Value,
    DENSE_RANK() OVER(ORDER BY Cnt) AS ValueSort,
    TipStatus AS VisId,
    ''A'' AS Stack
FROM counts

SELECT
    ''Payment Type / Bill Size'' AS XAxisLabel,
    ''Order Count'' AS YAxisLabel,
    ''Tip Incidence by Payment Type and Bill Size'' AS Title,
    ''Settlement counts split by tipped vs untipped, broken out by tender and bill-size bucket.'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
    [Description] = N'Settlement counts (with tip vs without tip) by payment type, bucketed by bill size.',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionTipIncidenceByTender' AND [Status] = N'LIVE';

PRINT '1a. RedLionTipIncidenceByTender - bucketed by bill size';


-- 1b. RedLionTipMatrix - new CustomDataGrid (full breakdown)
DECLARE @QGrid NVARCHAR(MAX) = N'WITH sessions AS (
    SELECT [Transaction_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [Transaction_ID], [Payment_Type]
),
bucketed AS (
    SELECT Tender, Tip, Bill,
           CASE WHEN Bill < 20  THEN 1
                WHEN Bill < 50  THEN 2
                WHEN Bill < 100 THEN 3
                WHEN Bill < 200 THEN 4
                ELSE 5 END AS BSort,
           CASE WHEN Bill < 20  THEN ''<'' + NCHAR(163) + ''20''
                WHEN Bill < 50  THEN NCHAR(163) + ''20-50''
                WHEN Bill < 100 THEN NCHAR(163) + ''50-100''
                WHEN Bill < 200 THEN NCHAR(163) + ''100-200''
                ELSE NCHAR(163) + ''200+'' END AS Bucket
    FROM sessions WHERE Bill > 0
)
SELECT
    Tender AS Column1,
    Bucket AS Column2,
    COUNT(*) AS Column3,
    SUM(CASE WHEN Tip > 0 THEN 1 ELSE 0 END) AS Column4,
    SUM(CASE WHEN Tip = 0 THEN 1 ELSE 0 END) AS Column5,
    CAST(100.0 * SUM(CASE WHEN Tip > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS DECIMAL(6,2)) AS Column6,
    CAST(100.0 * SUM(Tip) / NULLIF(SUM(Bill), 0) AS DECIMAL(6,2)) AS Column7,
    CAST(SUM(Bill) AS DECIMAL(12,2)) AS Column8,
    CAST(SUM(Tip) AS DECIMAL(12,2)) AS Column9,
    NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13,
    NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17,
    NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21,
    NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25,
    NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM bucketed
GROUP BY Tender, Bucket, BSort
ORDER BY Tender, BSort

SELECT
    ''Tip Incidence Matrix'' AS [Title],
    ''Per tender and bill-size bucket - settlement counts, tip incidence and tip rate.'' AS [Description],
    ''Tender'' AS [Label1], ''TEXT'' AS [Type1],
    ''Bill Size'' AS [Label2], ''TEXT'' AS [Type2],
    ''Total'' AS [Label3], ''INT'' AS [Type3],
    ''With Tip'' AS [Label4], ''INT'' AS [Type4],
    ''Without Tip'' AS [Label5], ''INT'' AS [Type5],
    ''Tip Incidence %'' AS [Label6], ''PERCENT'' AS [Type6],
    ''Tip Rate %'' AS [Label7], ''PERCENT'' AS [Type7],
    ''Net Revenue'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''Gratuity'' AS [Label9], ''DECIMAL'' AS [Type9],
    NULL AS [Label10], NULL AS [Type10], NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12], NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14], NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20], NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26], NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29]';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionTipMatrix', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'CustomDataGrid',
    [QueryTemplate] = @QGrid,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Full tip-incidence picture: per tender and bill-size bucket, with counts, percentages and totals.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionTipMatrix', N'CustomDataGrid', 1, N'LIVE', @QGrid,
        @ParamMap, @FilterDef,
        N'Full tip-incidence picture: per tender and bill-size bucket, with counts, percentages and totals.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '1b. RedLionTipMatrix - upserted (CustomDataGrid)';


-- =============================================================================
-- PART 2: Report DB (database = report on xms-mssql-ne-uat)
-- =============================================================================
--   Org:                 Punch Pubs - Trial = 8381A215-4601-F111-8D4C-000D3AB579E6
--   Demo Dashboard 3:    CA832FD3-DA27-F111-9A49-000D3AB27214
--   CustomDataGrid:      VisId 3 - org has no config yet, provision below

DECLARE @GridId UNIQUEIDENTIFIER = 'CA832FD3-DA27-F111-9A49-000D3AB27214';

-- 2a. Provision VisualisationConfig for VisId 3 (CustomDataGrid) if missing
DECLARE @GridCfgId UNIQUEIDENTIFIER = (
    SELECT TOP 1 VisualisationConfigId
    FROM dbo.VisualisationConfig
    WHERE OrganisationId = '8381A215-4601-F111-8D4C-000D3AB579E6'
      AND VisualisationId = 3 AND IsDeleted = 0
);

IF @GridCfgId IS NULL
BEGIN
    DECLARE @CfgOut TABLE (Id UNIQUEIDENTIFIER);
    INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, ActiveUntil, IsDeleted)
    OUTPUT inserted.VisualisationConfigId INTO @CfgOut
    VALUES ('8381A215-4601-F111-8D4C-000D3AB579E6', 3, GETDATE(), NULL, 0);
    SELECT @GridCfgId = Id FROM @CfgOut;
    PRINT '2a. Provisioned new VisualisationConfig for VisId 3 (CustomDataGrid)';
END
ELSE
BEGIN
    PRINT '2a. VisualisationConfig for VisId 3 already exists - reusing';
END;


-- 2b. Wire the dataset to the CustomDataGrid config
IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @GridCfgId
                 AND DataSet = N'RedLionTipMatrix' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@GridCfgId, N'RedLionTipMatrix', 0);

-- 2c. Place the grid full-width at the bottom of the dashboard
IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId
                 AND DataSet = N'RedLionTipMatrix' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 12, 12, 12, 3, N'RedLionTipMatrix', 9, 0);

PRINT '2c. RedLionTipMatrix wired and placed (full width, sort 9, VisId 3)';
