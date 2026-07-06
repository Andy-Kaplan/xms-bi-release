/* =============================================================================
   02_margebrut_vis_queries.sql
   -----------------------------------------------------------------------------
   Target server  : xms-bi-uat   (SQL Managed Instance)
   Target database: core          (writes to core.core.VisualisationQueries)
   Purpose        : Register the bespoke "Marge Brut" mock datasets. Every query
                    returns LITERAL October-2025 ISLRG figures (FROM (VALUES ...))
                    -- no real table reads -- so the dashboard renders without any
                    live Growyze/Bizon data.

   Datasets (9):
     MargeBrutGrid        CustomDataGrid   the full Marge Brut grid
     MargeBrutCostRatioKPI         SingleKPICard    hero: Cost of Sales 31.6% (GP 68.4%)
     MargeBrutConsumptionKPI       SingleKPICard    Consumption GBP 4,910.92
     MargeBrutTurnoverKPI          SingleKPICard    Turnover ex-VAT GBP 15,531.79
     MargeBrutPurchasesKPI         SingleKPICard    Purchases GBP 4,562.64
     MargeBrutCostRatioByGroup     BarChartCard     cost-of-sales % by group
     MargeBrutConsumptionMix       PieChartCard     consumption GBP by group
     MargeBrutCompsSplit           PieChartCard     comps + staff meals by category
     MargeBrutPurchasesBySupplier  BarChartCard     food purchases by supplier

   Idempotent: each block assigns the template to @sql, then MERGEs on the
   natural key (DataSetName, VisualizationType, Status='LIVE'). Safe to re-run.

   Card render schemas (confirmed against 8_VisualisationQueries.sql):
     SingleKPICard : RS1 = Title, Value (+Description/Trend/Chip)
     CustomDataGrid: RS1 = Column1..Column29 ; RS2 = Title, Description, Label1/Type1 .. Label29/Type29
     BarChartCard  : RS1 = BarLabel, BarLabelSort, BarValue, BarValueSort ; RS2 = XAxisLabel, YAxisLabel, Title, Description, Trend, TotalValue, Chip
     PieChartCard  : RS1 = Label, Value, Id, Curve, Stack, Area, StackOrder, ShowMark, LegendLabel ; RS2 = Title, Description, Trend, Chip, PiePrimaryText, PieSecondaryText

   No filters are wired for this mock, so ParameterMappings / FilterDefinitions
   are '{}' and @FilterClause resolves to empty. Card SPs read
   COALESCE(ExecutionQuery, QueryTemplate); ExecutionQuery is NULL throughout.

   NOTE: Claude authored this script; a developer executes it (MCP is read-only).
   ============================================================================= */

SET NOCOUNT ON;
DECLARE @me  NVARCHAR(100)  = N'andrew.kaplan@threerocks.co.uk';
DECLARE @sql NVARCHAR(MAX);

/* ===========================================================================
   1. MargeBrutGrid  --  CustomDataGrid (the centrepiece)
   =========================================================================== */
SET @sql = N'SELECT
  Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8, Column9, Column10, Column11, Column12, Column13, Column14,
  NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM ( VALUES
  (N''TOTAL FOOD'',                N''17,113.05'', N''14,260.88'', N''2,381.14'', N''4,562.64'', N''1,092.60'', N''912.17'', N''6,763.35'', N''1,879.36'', N''306.40'', N''8.72'',   N''4,568.87'', N''32.0%'', N''68.0%''),
  (N''Total Food (ex. Breakfast)'', N''17,113.05'', N''14,260.88'', N''2,381.14'', N''1,092.60'', N''1,092.60'', N''0.00'',  N''2,381.14'', N''1,879.36'', N'''',      N''8.72'',   N''493.06'',   N''3.5%'',  N''96.5%''),
  (N''Total Breakfast'',           N'''',          N''0.00'',      N'''',         N''3,470.04'', N'''',         N''912.17'', N''4,382.21'', N'''',         N'''',      N''0.00'',   N''4,382.21'', N''n/a'',   N''n/a''),
  (N''WINES'',                     N''505.65'',    N''421.38'',    N''446.46'',   N''0.00'',     N''0.00'',     N''0.00'',   N''446.46'',   N''261.51'',   N'''',      N''61.67'',  N''123.28'',   N''29.3%'', N''70.7%''),
  (N''BOTTLED BEER'',              N''564.30'',    N''470.25'',    N''295.93'',   N''0.00'',     N''0.00'',     N''0.00'',   N''295.93'',   N''126.15'',   N'''',      N''69.60'',  N''100.18'',   N''21.3%'', N''78.7%''),
  (N''SOFT DRINKS ONLY'',          N''261.50'',    N''217.92'',    N''520.24'',   N''0.00'',     N''0.00'',     N''0.00'',   N''520.24'',   N''406.09'',   N'''',      N''40.23'',  N''73.92'',    N''33.9%'', N''66.1%''),
  (N''SPIRIT'',                    N''193.65'',    N''161.38'',    N''685.39'',   N''0.00'',     N''0.00'',     N''0.00'',   N''685.39'',   N''640.72'',   N'''',      N''0.00'',   N''44.67'',    N''27.7%'', N''72.3%''),
  (N''TOTAL BEVERAGE'',            N''1,525.10'',  N''1,270.92'',  N''1,948.02'', N''0.00'',     N''0.00'',     N''0.00'',   N''1,948.02'', N''1,434.47'', N'''',      N''171.50'', N''342.05'',   N''26.9%'', N''73.1%''),
  (N''GRAND TOTAL VR'',            N''18,638.15'', N''15,531.79'', N''4,329.16'', N''4,562.64'', N''1,092.60'', N''912.17'', N''8,711.37'', N''3,313.83'', N''306.40'', N''180.22'', N''4,910.92'', N''31.6%'', N''68.4%'')
) AS t (Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8, Column9, Column10, Column11, Column12, Column13, Column14)
WHERE 1=1
@FilterClause

SELECT
  N''Marge Brut - F&B Cost of Sales'' AS [Title],
  N''ISLRG - October 2025 - figures in GBP, ex-VAT'' AS [Description],
  N''Group'' AS [Label1], N''TEXT'' AS [Type1],
  N''Turnover Incl VAT'' AS [Label2], N''TEXT'' AS [Type2],
  N''Turnover Excl VAT'' AS [Label3], N''TEXT'' AS [Type3],
  N''Opening Stock'' AS [Label4], N''TEXT'' AS [Type4],
  N''Purchases'' AS [Label5], N''TEXT'' AS [Type5],
  N''Reverse Prov.'' AS [Label6], N''TEXT'' AS [Type6],
  N''New Prov.'' AS [Label7], N''TEXT'' AS [Type7],
  N''All Stocks'' AS [Label8], N''TEXT'' AS [Type8],
  N''Closing Stock'' AS [Label9], N''TEXT'' AS [Type9],
  N''Staff Meal'' AS [Label10], N''TEXT'' AS [Type10],
  N''Complimentary'' AS [Label11], N''TEXT'' AS [Type11],
  N''Consumption'' AS [Label12], N''TEXT'' AS [Type12],
  N''Cost %'' AS [Label13], N''TEXT'' AS [Type13],
  N''GP %'' AS [Label14], N''TEXT'' AS [Type14],
  NULL AS [Label15], NULL AS [Type15], NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17],
  NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19], NULL AS [Label20], NULL AS [Type20],
  NULL AS [Label21], NULL AS [Type21], NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23],
  NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25], NULL AS [Label26], NULL AS [Type26],
  NULL AS [Label27], NULL AS [Type27], NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29]';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutGrid', N'CustomDataGrid', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Marge Brut grid (mock, Oct 2025 ISLRG)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Marge Brut grid (mock, Oct 2025 ISLRG)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutGrid merged';

/* ===========================================================================
   2. MargeBrutCostRatioKPI  --  SingleKPICard (hero)
   =========================================================================== */
SET @sql = N'SELECT
  N''Cost of Sales'' AS Title,
  N''31.6%'' AS Value,
  N''Gross margin 68.4% - October 2025'' AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM (VALUES (1)) AS d(x)
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutCostRatioKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Cost of Sales hero KPI (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Cost of Sales hero KPI (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutCostRatioKPI merged';

/* ===========================================================================
   3. MargeBrutConsumptionKPI  --  SingleKPICard
   =========================================================================== */
SET @sql = N'SELECT
  N''Consumption'' AS Title,
  N''GBP 4,910.92'' AS Value,
  N''Total F&B consumed - October 2025'' AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM (VALUES (1)) AS d(x)
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutConsumptionKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Consumption KPI (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Consumption KPI (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutConsumptionKPI merged';

/* ===========================================================================
   4. MargeBrutTurnoverKPI  --  SingleKPICard
   =========================================================================== */
SET @sql = N'SELECT
  N''Turnover (ex VAT)'' AS Title,
  N''GBP 15,531.79'' AS Value,
  N''Net F&B turnover - October 2025'' AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM (VALUES (1)) AS d(x)
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutTurnoverKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Turnover KPI (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Turnover KPI (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutTurnoverKPI merged';

/* ===========================================================================
   5. MargeBrutPurchasesKPI  --  SingleKPICard
   =========================================================================== */
SET @sql = N'SELECT
  N''Purchases'' AS Title,
  N''GBP 4,562.64'' AS Value,
  N''Food & beverage - October 2025'' AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM (VALUES (1)) AS d(x)
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutPurchasesKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Purchases KPI (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Purchases KPI (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutPurchasesKPI merged';

/* ===========================================================================
   6. MargeBrutCostRatioByGroup  --  BarChartCard
   =========================================================================== */
SET @sql = N'SELECT
  BarLabel,
  BarLabelSort,
  BarValue,
  BarValueSort
FROM ( VALUES
  (N''Food'',         1, 32.0, 4),
  (N''Wines'',        2, 29.3, 3),
  (N''Bottled Beer'', 3, 21.3, 1),
  (N''Soft Drinks'',  4, 33.9, 5),
  (N''Spirit'',       5, 27.7, 2)
) AS t (BarLabel, BarLabelSort, BarValue, BarValueSort)
WHERE 1=1
@FilterClause

SELECT
  N''Group'' AS XAxisLabel,
  N''Cost of Sales %'' AS YAxisLabel,
  N''Cost of Sales % by Group'' AS Title,
  N''Lower is better - October 2025'' AS Description,
  NULL AS Trend,
  NULL AS TotalValue,            -- BarChartCard parses TotalValue as numeric; a % grand-total is not meaningful, so NULL
  NULL AS Chip';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutCostRatioByGroup', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Cost ratio by group (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Cost ratio by group (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutCostRatioByGroup merged';

/* ===========================================================================
   7. MargeBrutPurchasesBySupplier  --  BarChartCard
   =========================================================================== */
SET @sql = N'SELECT
  BarLabel,
  BarLabelSort,
  BarValue,
  BarValueSort
FROM ( VALUES
  (N''Bidfood'',    1, 3408.37, 3),
  (N''Reynolds'',   2, 1074.04, 2),
  (N''Petty Cash'', 3,   80.23, 1)
) AS t (BarLabel, BarLabelSort, BarValue, BarValueSort)
WHERE 1=1
@FilterClause

SELECT
  N''Supplier'' AS XAxisLabel,
  N''Purchases (GBP)'' AS YAxisLabel,
  N''Food Purchases by Supplier'' AS Title,
  N''October 2025'' AS Description,
  NULL AS Trend,
  4562.64 AS TotalValue,         -- BarChartCard parses TotalValue as numeric (total purchases GBP); backend formats it
  NULL AS Chip';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutPurchasesBySupplier', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Purchases by supplier (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Purchases by supplier (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutPurchasesBySupplier merged';

/* ===========================================================================
   8. MargeBrutConsumptionMix  --  PieChartCard
   =========================================================================== */
SET @sql = N'SELECT
  Label,
  Value,
  Id,
  N''linear'' AS Curve,
  N''total'' AS Stack,
  N''true'' AS Area,
  N''ascending'' AS StackOrder,
  N''false'' AS ShowMark,
  N''Consumption (GBP)'' AS LegendLabel
FROM ( VALUES
  (N''Food'',         N''4,568.87'', N''Food''),
  (N''Wines'',        N''123.28'',   N''Wines''),
  (N''Bottled Beer'', N''100.18'',   N''Bottled Beer''),
  (N''Soft Drinks'',  N''73.92'',    N''Soft Drinks''),
  (N''Spirit'',       N''44.67'',    N''Spirit'')
) AS t (Label, Value, Id)
WHERE 1=1
@FilterClause

SELECT
  N''Consumption Mix'' AS Title,
  N''Cost of F&B consumed - October 2025'' AS Description,
  NULL AS Trend,
  NULL AS Chip,
  N''4,910.92'' AS PiePrimaryText,
  N''Consumption (GBP)'' AS PieSecondaryText';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutConsumptionMix', N'PieChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Consumption mix (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Consumption mix (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutConsumptionMix merged';

/* ===========================================================================
   9. MargeBrutCompsSplit  --  PieChartCard
   =========================================================================== */
SET @sql = N'SELECT
  Label,
  Value,
  Id,
  N''linear'' AS Curve,
  N''total'' AS Stack,
  N''true'' AS Area,
  N''ascending'' AS StackOrder,
  N''false'' AS ShowMark,
  N''Removed from cost (GBP)'' AS LegendLabel
FROM ( VALUES
  (N''Staff Meal'',          N''306.40'', N''Staff Meal''),
  (N''Gift to Guest (F&B)'', N''169.19'', N''Gift to Guest (F&B)''),
  (N''Management'',          N''6.55'',   N''Management''),
  (N''Rooms'',               N''4.48'',   N''Rooms'')
) AS t (Label, Value, Id)
WHERE 1=1
@FilterClause

SELECT
  N''Comps & Staff Meals'' AS Title,
  N''Cost removed from consumption - October 2025'' AS Description,
  NULL AS Trend,
  NULL AS Chip,
  N''486.62'' AS PiePrimaryText,
  N''Removed from cost (GBP)'' AS PieSecondaryText';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutCompsSplit', N'PieChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Comps & staff meals split (mock)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{}', N'{}', NULL, N'Comps & staff meals split (mock)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutCompsSplit merged';

PRINT '=== Marge Brut visualisation queries registered (9 datasets) ===';

/* ---------------------------------------------------------------------------
   POST-RUN MCP TEST (per CLAUDE.md "Testing Visualisation Queries via MCP"):
   For each dataset, fetch COALESCE(ExecutionQuery,QueryTemplate), strip comments,
   replace @FilterClause with '' , remove the SECOND SELECT (header), and run from
   the core DB. These are pure literals so no client-DB prefix is needed.
   Confirm RS1 values match the spreadsheet (DESIGN.md s7).
   --------------------------------------------------------------------------- */
