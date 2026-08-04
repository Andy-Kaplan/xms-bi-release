/*  Pantry COGS Dashboard - Task 6: SingleKPICard datasets

    4 KPI cards over [presentation].[F_COGS_PERIOD] (one row per inventory item
    per location per stocktake period):
      - PantryCOGSSpendKPI          SUM(COG_SPEND)      "value delivered - what the client is billed"
      - PantryCOGSSoldKPI           SUM(COG_SOLD)       "value consumed - what was actually used"
      - PantryCOGSClosingStockKPI   CLOSING_VALUE at the LATEST period in scope, per location
                                    (a snapshot - never summed across periods; see C5 note below)
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
-- CLOSING STOCK IS A SNAPSHOT, NOT A FLOW - DO NOT SUM IT ACROSS PERIODS (defect C5).
-- This was originally a plain SUM(F.[CLOSING_VALUE]) over every row in scope. That is correct
-- ONLY when exactly one period is in scope, which is why it looked right on the first deploy
-- org (Ibis Gloucester Road has a single non-first period). On any org with real stocktake
-- history it silently adds every period''s closing balance together: on Padel Social the KPI
-- read GBP 709,650.42 where the true latest closing stock is GBP 31,395.51 - a 22.6x
-- overstatement presented as a headline figure.
-- COG Spend, COG Sold, waste and variance are FLOWS and remain plain SUMs - summing those
-- across periods is correct. Only opening/closing balances need this treatment.
-- Latest period is resolved PER LOCATION, then summed across locations, because venues in one
-- org keep independent stocktake calendars (design D5/D6) - taking one global MAX would drop
-- every venue that did not happen to count on the most recent date.
-- The alias F must stay on the CTE: @FilterClause and ParameterMappings both emit F.[...].
SET @q = N'WITH Scoped AS (
    SELECT
         F.[LOCATION_HUB_ID]
        ,F.[PERIOD_END_DATE]
        ,F.[CLOSING_VALUE]
    FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE N''int_growyze%''
      AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
      @FilterClause
),
LatestPerLocation AS (
    SELECT [LOCATION_HUB_ID], MAX([PERIOD_END_DATE]) AS [PERIOD_END_DATE]
    FROM Scoped
    GROUP BY [LOCATION_HUB_ID]
)
SELECT
     N''Closing stock'' AS Title
    ,SUM(S.[CLOSING_VALUE]) AS Value
FROM Scoped S
INNER JOIN LatestPerLocation L
    ON  L.[LOCATION_HUB_ID]  = S.[LOCATION_HUB_ID]
    AND L.[PERIOD_END_DATE] = S.[PERIOD_END_DATE]';

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
