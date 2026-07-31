/*  Pantry COGS Dashboard - Task 6: SingleKPICard datasets

    4 KPI cards over [presentation].[F_COGS_PERIOD] (one row per inventory item
    per location per stocktake period):
      - PantryCOGSSpendKPI          SUM(COG_SPEND)      "value delivered - what the client is billed"
      - PantryCOGSSoldKPI           SUM(COG_SOLD)       "value consumed - what was actually used"
      - PantryCOGSClosingStockKPI   SUM(CLOSING_VALUE)  closing stock at cost
      - PantryCOGSVarianceKPI       SUM(VARIANCE_VALUE) consumption unexplained by waste/sales

    Per 00_CARD_CONTRACTS.md, the live SingleKPICard example (DiscountPerc) has
    ONE result set only - Title and Value in the same row - so every query
    below is a single SELECT. Do not add a second header SELECT.

    Natural key: (DataSetName, VisualizationType, Status). MERGE upserts against
    [core].[core].[VisualisationQueries] (three-part name - the table lives in
    the core DATABASE's core SCHEMA; a two-part name would resolve against the
    calling client database's own core schema instead).

    Every query is scoped with F.[SOURCE] LIKE 'int_growyze%' (excludes any
    co-resident POS integration data) and ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
    (a venue's first stocktake has no opening stock, so its consumption figure
    is meaningless).

    NOTE: no database access was available while writing this file. Nothing
    here has been executed against a live server - review before deploying.
*/

DECLARE @q  NVARCHAR(MAX);
DECLARE @pm NVARCHAR(MAX);
DECLARE @fd NVARCHAR(MAX);
DECLARE @od NVARCHAR(MAX);

-- ============================================
-- Dataset: PantryCOGSSpendKPI
-- SingleKPICard - Version 1 - LIVE
-- ============================================
SET @q = N'SELECT
     N''COG Spend'' AS Title
    ,SUM(F.[COG_SPEND]) AS Value
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE N''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause';

SET @pm = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

SET @fd = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

SET @od = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSSpendKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Value delivered - what the client is billed'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSSpendKPI', N'SingleKPICard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Value delivered - what the client is billed',
     NULL, NULL, GETDATE(), GETDATE());

-- ============================================
-- Dataset: PantryCOGSSoldKPI
-- SingleKPICard - Version 1 - LIVE
-- ============================================
SET @q = N'SELECT
     N''COG Sold'' AS Title
    ,SUM(F.[COG_SOLD]) AS Value
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE N''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause';

SET @pm = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

SET @fd = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

SET @od = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSSoldKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Value consumed - what was actually used'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSSoldKPI', N'SingleKPICard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Value consumed - what was actually used',
     NULL, NULL, GETDATE(), GETDATE());

-- ============================================
-- Dataset: PantryCOGSClosingStockKPI
-- SingleKPICard - Version 1 - LIVE
-- ============================================
SET @q = N'SELECT
     N''Closing stock'' AS Title
    ,SUM(F.[CLOSING_VALUE]) AS Value
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE N''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause';

SET @pm = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

SET @fd = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

SET @od = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSClosingStockKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Stock on hand at the closing stocktake, at cost'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSClosingStockKPI', N'SingleKPICard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Stock on hand at the closing stocktake, at cost',
     NULL, NULL, GETDATE(), GETDATE());

-- ============================================
-- Dataset: PantryCOGSVarianceKPI
-- SingleKPICard - Version 1 - LIVE
-- ============================================
SET @q = N'SELECT
     N''Unexplained variance'' AS Title
    ,SUM(F.[VARIANCE_VALUE]) AS Value
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE N''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause';

SET @pm = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

SET @fd = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

SET @od = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSVarianceKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Consumption not explained by declared waste or sales'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSVarianceKPI', N'SingleKPICard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Consumption not explained by declared waste or sales',
     NULL, NULL, GETDATE(), GETDATE());
