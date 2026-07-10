/* =============================================================================
   14_margebrut_vis_queries.sql
   -----------------------------------------------------------------------------
   Target server  : xms-bi-uat   (SQL Managed Instance)
   Target database: core          (writes to core.core.VisualisationQueries)
   Purpose        : Rewire the 9 "Marge Brut" datasets registered by
                    ../02_margebrut_vis_queries.sql from literal Oct-2025 mocks
                    (FROM (VALUES ...)) to live reads over
                    presentation.F_MARGEBRUT_MONTH (Task 1/6) so the dashboard
                    renders real Mews/Growyze-derived figures.

   Datasets (9) -- unchanged DataSetName / VisualizationType / card render
   schema from the mock; only QueryTemplate bodies change:
     MargeBrutGrid        CustomDataGrid   the full Marge Brut grid
     MargeBrutCostRatioKPI         SingleKPICard    hero: Cost of Sales %
     MargeBrutConsumptionKPI       SingleKPICard    Consumption GBP
     MargeBrutTurnoverKPI          SingleKPICard    Turnover ex-VAT GBP
     MargeBrutPurchasesKPI         SingleKPICard    Purchases GBP
     MargeBrutCostRatioByGroup     BarChartCard     cost-of-sales % by group
     MargeBrutConsumptionMix       PieChartCard     consumption GBP by group
     MargeBrutCompsSplit           PieChartCard     comps + staff meals
     MargeBrutPurchasesBySupplier  BarChartCard     food purchases by supplier

   Idempotent: each block assigns the template to @sql, then MERGEs on the
   natural key (DataSetName, VisualizationType, Status='LIVE'). Safe to re-run.

   Card render schemas (unchanged from the mock -- see ../02_margebrut_vis_queries.sql
   header for the confirmed-against-8_VisualisationQueries.sql source):
     SingleKPICard : RS1 = Title, Value (+Description/Trend/Chip)
     CustomDataGrid: RS1 = Column1..Column29 ; RS2 = Title, Description, Label1/Type1 .. Label29/Type29
     BarChartCard  : RS1 = BarLabel, BarLabelSort, BarValue, BarValueSort ; RS2 = XAxisLabel, YAxisLabel, Title, Description, Trend, TotalValue, Chip
     PieChartCard  : RS1 = Label, Value, Id, Curve, Stack, Area, StackOrder, ShowMark, LegendLabel ; RS2 = Title, Description, Trend, Chip, PiePrimaryText, PieSecondaryText

   GROUP_NAME values written by Task 5 (12_group_mapping.sql): Food, Breakfast,
   Wines, Bottled Beer, Soft Drinks, Spirit. The grid (mock rows 1-3) and the
   two chart datasets fold Food+Breakfast into a single "Food" bucket, matching
   the mock's category set (Food, Wines, Bottled Beer, Soft Drinks, Spirit) --
   see per-block comments.

   Aggregation rule: every %/ratio column (COST_PCT, GP_PCT, cost-of-sales %)
   is recomputed from the SUMMED raw measures at whatever grain is being
   displayed (per group, per rollup, per filtered period range) -- never an
   average of the per-month stored ratios. Averaging percentages across
   months/groups of different size would misweight them (Simpson's-paradox
   style); summing CONSUMPTION and TURNOVER_EXCL first and dividing once is
   correct at any grain.

   PERIOD_MONTH filter: FilterDefinitions defines a "PeriodMonth" IN-filter
   (see per-block JSON). Default (empty @FilterClause) = all periods summed
   together. Per the house rule (memory/feedback_filterclause_aliases.md),
   every table alias referenced by a FilterDefinitions column expression is
   kept in scope everywhere @FilterClause is substituted in that query's text
   (data query and, where a header subquery re-reads the fact, the header too
   -- reusing the SAME alias, since each SELECT has independent scope).

   NOTE: Claude authored this script; a developer executes it (MCP is read-only).
   ============================================================================= */

SET NOCOUNT ON;
DECLARE @me  NVARCHAR(100)  = N'andrew.kaplan@threerocks.co.uk';
DECLARE @sql NVARCHAR(MAX);

/* ===========================================================================
   1. MargeBrutGrid  --  CustomDataGrid (the centrepiece)
   ---------------------------------------------------------------------------
   9 fixed rows, same layout as the mock:
     TOTAL FOOD (Food+Breakfast) / Total Food (ex. Breakfast) / Total Breakfast
     / WINES / BOTTLED BEER / SOFT DRINKS ONLY / SPIRIT / TOTAL BEVERAGE
     / GRAND TOTAL VR
   A canonical-groups CTE LEFT JOINs the fact so all 6 groups always appear
   (a group with zero rows in the filtered period range renders as NULL/blank
   rather than vanishing from the grid).
   =========================================================================== */
SET @sql = N'WITH base AS (
    SELECT F.GROUP_NAME, F.PERIOD_MONTH, F.TURNOVER_INCL, F.TURNOVER_EXCL, F.OPENING, F.PURCHASES,
           F.REV_PROV, F.NEW_PROV, F.ALL_STOCK, F.CLOSING, F.STAFF_MEAL, F.COMP, F.CONSUMPTION
    FROM presentation.F_MARGEBRUT_MONTH F
    WHERE 1=1
    @FilterClause
),
canon AS (
    SELECT g.GROUP_NAME FROM (VALUES (N''Food''),(N''Breakfast''),(N''Wines''),(N''Bottled Beer''),(N''Soft Drinks''),(N''Spirit'')) AS g(GROUP_NAME)
),
by_group AS (
    SELECT c.GROUP_NAME,
        SUM(b.TURNOVER_INCL) AS TURNOVER_INCL, SUM(b.TURNOVER_EXCL) AS TURNOVER_EXCL,
        SUM(b.OPENING) AS OPENING, SUM(b.PURCHASES) AS PURCHASES,
        SUM(b.REV_PROV) AS REV_PROV, SUM(b.NEW_PROV) AS NEW_PROV,
        SUM(b.ALL_STOCK) AS ALL_STOCK, SUM(b.CLOSING) AS CLOSING,
        SUM(b.STAFF_MEAL) AS STAFF_MEAL, SUM(b.COMP) AS COMP, SUM(b.CONSUMPTION) AS CONSUMPTION
    FROM canon c
    LEFT JOIN base b ON b.GROUP_NAME = c.GROUP_NAME
    GROUP BY c.GROUP_NAME
),
food_total AS (
    SELECT SUM(TURNOVER_INCL) AS TURNOVER_INCL, SUM(TURNOVER_EXCL) AS TURNOVER_EXCL,
           SUM(OPENING) AS OPENING, SUM(PURCHASES) AS PURCHASES, SUM(REV_PROV) AS REV_PROV,
           SUM(NEW_PROV) AS NEW_PROV, SUM(ALL_STOCK) AS ALL_STOCK, SUM(CLOSING) AS CLOSING,
           SUM(STAFF_MEAL) AS STAFF_MEAL, SUM(COMP) AS COMP, SUM(CONSUMPTION) AS CONSUMPTION
    FROM by_group WHERE GROUP_NAME IN (N''Food'', N''Breakfast'')
),
bev_total AS (
    SELECT SUM(TURNOVER_INCL) AS TURNOVER_INCL, SUM(TURNOVER_EXCL) AS TURNOVER_EXCL,
           SUM(OPENING) AS OPENING, SUM(PURCHASES) AS PURCHASES, SUM(REV_PROV) AS REV_PROV,
           SUM(NEW_PROV) AS NEW_PROV, SUM(ALL_STOCK) AS ALL_STOCK, SUM(CLOSING) AS CLOSING,
           SUM(STAFF_MEAL) AS STAFF_MEAL, SUM(COMP) AS COMP, SUM(CONSUMPTION) AS CONSUMPTION
    FROM by_group WHERE GROUP_NAME IN (N''Wines'', N''Bottled Beer'', N''Soft Drinks'', N''Spirit'')
),
grand_total AS (
    SELECT SUM(TURNOVER_INCL) AS TURNOVER_INCL, SUM(TURNOVER_EXCL) AS TURNOVER_EXCL,
           SUM(OPENING) AS OPENING, SUM(PURCHASES) AS PURCHASES, SUM(REV_PROV) AS REV_PROV,
           SUM(NEW_PROV) AS NEW_PROV, SUM(ALL_STOCK) AS ALL_STOCK, SUM(CLOSING) AS CLOSING,
           SUM(STAFF_MEAL) AS STAFF_MEAL, SUM(COMP) AS COMP, SUM(CONSUMPTION) AS CONSUMPTION
    FROM by_group
),
rows AS (
    SELECT 1 AS SortOrder, N''TOTAL FOOD'' AS RowLabel,
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM food_total
    UNION ALL
    SELECT 2, N''Total Food (ex. Breakfast)'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM by_group WHERE GROUP_NAME = N''Food''
    UNION ALL
    SELECT 3, N''Total Breakfast'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM by_group WHERE GROUP_NAME = N''Breakfast''
    UNION ALL
    SELECT 4, N''WINES'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM by_group WHERE GROUP_NAME = N''Wines''
    UNION ALL
    SELECT 5, N''BOTTLED BEER'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM by_group WHERE GROUP_NAME = N''Bottled Beer''
    UNION ALL
    SELECT 6, N''SOFT DRINKS ONLY'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM by_group WHERE GROUP_NAME = N''Soft Drinks''
    UNION ALL
    SELECT 7, N''SPIRIT'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM by_group WHERE GROUP_NAME = N''Spirit''
    UNION ALL
    SELECT 8, N''TOTAL BEVERAGE'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM bev_total
    UNION ALL
    SELECT 9, N''GRAND TOTAL VR'',
        TURNOVER_INCL, TURNOVER_EXCL, OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION
    FROM grand_total
)
SELECT
  RowLabel AS Column1,
  FORMAT(TURNOVER_INCL, ''N2'') AS Column2,
  FORMAT(TURNOVER_EXCL, ''N2'') AS Column3,
  FORMAT(OPENING, ''N2'') AS Column4,
  FORMAT(PURCHASES, ''N2'') AS Column5,
  FORMAT(REV_PROV, ''N2'') AS Column6,
  FORMAT(NEW_PROV, ''N2'') AS Column7,
  FORMAT(ALL_STOCK, ''N2'') AS Column8,
  FORMAT(CLOSING, ''N2'') AS Column9,
  FORMAT(STAFF_MEAL, ''N2'') AS Column10,
  FORMAT(COMP, ''N2'') AS Column11,
  FORMAT(CONSUMPTION, ''N2'') AS Column12,
  FORMAT(CASE WHEN TURNOVER_EXCL > 0 THEN CONSUMPTION / TURNOVER_EXCL END, ''P1'') AS Column13,
  FORMAT(CASE WHEN TURNOVER_EXCL > 0 THEN 1 - (CONSUMPTION / TURNOVER_EXCL) END, ''P1'') AS Column14,
  NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20,
  NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
  NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM rows
ORDER BY SortOrder

SELECT
  N''Marge Brut - F&B Cost of Sales'' AS [Title],
  N''ISLRG - figures in GBP, ex-VAT'' AS [Description],
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
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Marge Brut grid (live, F_MARGEBRUT_MONTH)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Marge Brut grid (live, F_MARGEBRUT_MONTH)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutGrid merged';

/* ===========================================================================
   2. MargeBrutCostRatioKPI  --  SingleKPICard (hero)
   =========================================================================== */
SET @sql = N'SELECT
  N''Cost of Sales'' AS Title,
  FORMAT(SUM(F.CONSUMPTION) / NULLIF(SUM(F.TURNOVER_EXCL), 0), ''P1'') AS Value,
  N''Gross Margin '' + FORMAT(1 - SUM(F.CONSUMPTION) / NULLIF(SUM(F.TURNOVER_EXCL), 0), ''P1'') AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM presentation.F_MARGEBRUT_MONTH F
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutCostRatioKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Cost of Sales hero KPI (live)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Cost of Sales hero KPI (live)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutCostRatioKPI merged';

/* ===========================================================================
   3. MargeBrutConsumptionKPI  --  SingleKPICard
   =========================================================================== */
SET @sql = N'SELECT
  N''Consumption'' AS Title,
  N''GBP '' + FORMAT(SUM(F.CONSUMPTION), ''N2'') AS Value,
  N''Total F&B consumed'' AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM presentation.F_MARGEBRUT_MONTH F
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutConsumptionKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Consumption KPI (live)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Consumption KPI (live)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutConsumptionKPI merged';

/* ===========================================================================
   4. MargeBrutTurnoverKPI  --  SingleKPICard
   =========================================================================== */
SET @sql = N'SELECT
  N''Turnover (ex VAT)'' AS Title,
  N''GBP '' + FORMAT(SUM(F.TURNOVER_EXCL), ''N2'') AS Value,
  N''Net F&B turnover'' AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM presentation.F_MARGEBRUT_MONTH F
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutTurnoverKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Turnover KPI (live)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Turnover KPI (live)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutTurnoverKPI merged';

/* ===========================================================================
   5. MargeBrutPurchasesKPI  --  SingleKPICard
   =========================================================================== */
SET @sql = N'SELECT
  N''Purchases'' AS Title,
  N''GBP '' + FORMAT(SUM(F.PURCHASES), ''N2'') AS Value,
  N''Food & beverage purchases'' AS Description,
  NULL AS Trend,
  NULL AS Chip
FROM presentation.F_MARGEBRUT_MONTH F
WHERE 1=1
@FilterClause';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutPurchasesKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Purchases KPI (live)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Purchases KPI (live)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutPurchasesKPI merged';

/* ===========================================================================
   6. MargeBrutCostRatioByGroup  --  BarChartCard
   ---------------------------------------------------------------------------
   Same 5-bucket set as the mock (Food, Wines, Bottled Beer, Soft Drinks,
   Spirit) -- Food folds in Breakfast, matching the grid's TOTAL FOOD row.
   BarValue/TotalValue are numeric (never a formatted string) -- known
   BarChartCard gotcha from the mock's own comment.
   =========================================================================== */
SET @sql = N'WITH base AS (
    SELECT
        CASE WHEN F.GROUP_NAME IN (N''Food'', N''Breakfast'') THEN N''Food'' ELSE F.GROUP_NAME END AS BUCKET,
        F.TURNOVER_EXCL, F.CONSUMPTION
    FROM presentation.F_MARGEBRUT_MONTH F
    WHERE 1=1
    @FilterClause
),
agg AS (
    SELECT BUCKET, SUM(TURNOVER_EXCL) AS TURNOVER_EXCL, SUM(CONSUMPTION) AS CONSUMPTION
    FROM base
    GROUP BY BUCKET
),
ratios AS (
    SELECT BUCKET,
        CAST(CASE WHEN TURNOVER_EXCL > 0 THEN 100.0 * CONSUMPTION / TURNOVER_EXCL END AS DECIMAL(9,1)) AS COST_PCT
    FROM agg
)
SELECT
  BUCKET AS BarLabel,
  CASE BUCKET WHEN N''Food'' THEN 1 WHEN N''Wines'' THEN 2 WHEN N''Bottled Beer'' THEN 3 WHEN N''Soft Drinks'' THEN 4 WHEN N''Spirit'' THEN 5 END AS BarLabelSort,
  COST_PCT AS BarValue,
  ROW_NUMBER() OVER (ORDER BY COST_PCT ASC) AS BarValueSort
FROM ratios

SELECT
  N''Group'' AS XAxisLabel,
  N''Cost of Sales %'' AS YAxisLabel,
  N''Cost of Sales % by Group'' AS Title,
  N''Lower is better'' AS Description,
  NULL AS Trend,
  NULL AS TotalValue,            -- BarChartCard parses TotalValue as numeric; a % grand-total is not meaningful, so NULL
  NULL AS Chip';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutCostRatioByGroup', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Cost ratio by group (live)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Cost ratio by group (live)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutCostRatioByGroup merged';

/* ===========================================================================
   7. MargeBrutPurchasesBySupplier  --  BarChartCard
   ---------------------------------------------------------------------------
   JUDGEMENT CALL (see task-7-report.md for full detail): F_MARGEBRUT_MONTH is
   group-grain, not supplier-grain, so it CANNOT source this dataset. The
   Growyze workstream already designed a clean supplier grain for exactly this
   purpose -- presentation.F_PURCHASES_DAY (SUPPLIER_HUB_ID, ORDER_DATE,
   LINE_TOTAL), built in ClaudeDevelopment/integrations/Growyze/06_.../07_...
   -- joined to the CORE (already-deployed) presentation.D_SUPPLIER dimension
   for the display name. This is that table, unqualified.
   CONCERN: F_PURCHASES_DAY's PresentationTables/PresentationControl records
   (Growyze scripts 06/07) are registered but NOT deployed to any org yet
   (QUERY_STATUS.md #23/#24, "Not deployed") -- this dataset will return no
   rows / error until that table exists and its build step has run at least
   once. Flagging for Task 8/9/10 (report-DB config, org provisioning,
   go-live verification) to pick up as a deploy-order dependency.
   REVIEW FIX: also join presentation.D_INVITEM (BOTTOM_HUB_ID unique per hub
   -- confirmed via MCP, 1,625 rows / 1,625 distinct BOTTOM_HUB_ID on the
   Growyze UAT proxy, so this join cannot fan out the fact) and filter to
   BOTTOM_MICROSERVICE_NAME IS NOT NULL, the same F&B group set Task 5
   (12_group_mapping.sql) assigns, so this chart is scoped on the same basis
   as the rest of the dashboard rather than summing every F_PURCHASES_DAY
   category regardless of type. NOTE: Task 5''s CASE has an ELSE ''Food''
   catch-all, so on an org whose Growyze catalogue mixes F&B with non-F&B
   stock (e.g. retail clothing/equipment -- see 12_group_mapping.sql''s own
   comment on the Padel Social proxy), every invitem ends up non-NULL and this
   filter does not yet exclude anything; it becomes a real scope once an org''s
   catalogue either has no non-F&B admixture or gets a proper category source.
   ============================================================================
   TODO: F_PURCHASES_DAY.LINE_TOTAL (order qty x price, from Growyze purchase
   orders) is a different measure and a different source pipeline than
   F_MARGEBRUT_MONTH.PURCHASES (F_INV_COUNTS_DAY ORDER_QTY x UOM_COST, from
   Growyze stock counts) -- this chart''s total is NOT guaranteed to reconcile
   with MargeBrutPurchasesKPI on real data. MUST be validated at go-live: if
   the two disagree materially, either point this chart at the same
   F_INV_COUNTS_DAY-based measure as the KPI, or rename the title/description
   to something scope-honest like "Supplier Spend" rather than implying it is
   the same Purchases figure shown elsewhere on the dashboard.
   =========================================================================== */
SET @sql = N'SELECT
  COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME) AS BarLabel,
  ROW_NUMBER() OVER (ORDER BY SUM(p.LINE_TOTAL) DESC) AS BarLabelSort,
  CAST(SUM(p.LINE_TOTAL) AS DECIMAL(18,2)) AS BarValue,
  ROW_NUMBER() OVER (ORDER BY SUM(p.LINE_TOTAL) ASC) AS BarValueSort
FROM presentation.F_PURCHASES_DAY p
JOIN presentation.D_SUPPLIER sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID
JOIN presentation.D_INVITEM inv ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
WHERE 1=1
AND inv.BOTTOM_MICROSERVICE_NAME IS NOT NULL
@FilterClause
GROUP BY COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME)

SELECT
  N''Supplier'' AS XAxisLabel,
  N''Purchases (GBP)'' AS YAxisLabel,
  N''Food Purchases by Supplier'' AS Title,
  N''Live'' AS Description,
  NULL AS Trend,
  (SELECT CAST(SUM(p.LINE_TOTAL) AS DECIMAL(18,2))
   FROM presentation.F_PURCHASES_DAY p
   JOIN presentation.D_INVITEM inv ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
   WHERE 1=1
   AND inv.BOTTOM_MICROSERVICE_NAME IS NOT NULL
   @FilterClause) AS TotalValue,  -- BarChartCard parses TotalValue as numeric; reuses alias ''p''/''inv'' so @FilterClause resolves in this subquery too
  NULL AS Chip';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutPurchasesBySupplier', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "DATEFROMPARTS(YEAR(p.[ORDER_DATE]),MONTH(p.[ORDER_DATE]),1)", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Purchases by supplier (live, F_PURCHASES_DAY -- NOT YET DEPLOYED, see Growyze 06/07)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "DATEFROMPARTS(YEAR(p.[ORDER_DATE]),MONTH(p.[ORDER_DATE]),1)", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Purchases by supplier (live, F_PURCHASES_DAY -- NOT YET DEPLOYED, see Growyze 06/07)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutPurchasesBySupplier merged';

/* ===========================================================================
   8. MargeBrutConsumptionMix  --  PieChartCard
   ---------------------------------------------------------------------------
   Same 5-bucket set as MargeBrutCostRatioByGroup (Food folds in Breakfast).
   =========================================================================== */
SET @sql = N'WITH base AS (
    SELECT
        CASE WHEN F.GROUP_NAME IN (N''Food'', N''Breakfast'') THEN N''Food'' ELSE F.GROUP_NAME END AS BUCKET,
        F.CONSUMPTION
    FROM presentation.F_MARGEBRUT_MONTH F
    WHERE 1=1
    @FilterClause
),
agg AS (
    SELECT BUCKET, SUM(CONSUMPTION) AS CONSUMPTION
    FROM base
    GROUP BY BUCKET
)
SELECT
  BUCKET AS Label,
  FORMAT(CONSUMPTION, ''N2'') AS Value,
  BUCKET AS Id,
  N''linear'' AS Curve,
  N''total'' AS Stack,
  N''true'' AS Area,
  N''ascending'' AS StackOrder,
  N''false'' AS ShowMark,
  N''Consumption (GBP)'' AS LegendLabel
FROM agg

SELECT
  N''Consumption Mix'' AS Title,
  N''Cost of F&B consumed'' AS Description,
  NULL AS Trend,
  NULL AS Chip,
  (SELECT FORMAT(SUM(F.CONSUMPTION), ''N2'') FROM presentation.F_MARGEBRUT_MONTH F WHERE 1=1 @FilterClause) AS PiePrimaryText,
  N''Consumption (GBP)'' AS PieSecondaryText';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutConsumptionMix', N'PieChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Consumption mix (live)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Consumption mix (live)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutConsumptionMix merged';

/* ===========================================================================
   9. MargeBrutCompsSplit  --  PieChartCard
   ---------------------------------------------------------------------------
   JUDGEMENT CALL (see task-7-report.md): the mock split comps into Staff
   Meal / Gift-to-Guest / Management / Rooms. F_MARGEBRUT_MONTH only carries
   STAFF_MEAL and COMP (COMP is an explicit literal 0 today -- Task 6 has no
   comp-specific line signal to source it from; see 13_f_margebrut_month_control.sql
   comment). Modelled here with the two categories the fact actually has --
   Staff Meal and Complimentary -- so the pie starts correct (Complimentary
   at 0) and will reflect real values automatically once a comp signal lands
   in the fact, with no further vis-query change needed. The Gift-to-Guest /
   Management / Rooms sub-split from the mock is NOT sourced and is dropped
   pending that comp signal.
   =========================================================================== */
SET @sql = N'WITH agg AS (
    SELECT SUM(F.STAFF_MEAL) AS STAFF_MEAL, SUM(F.COMP) AS COMP
    FROM presentation.F_MARGEBRUT_MONTH F
    WHERE 1=1
    @FilterClause
),
rows AS (
    SELECT N''Staff Meal'' AS Label, STAFF_MEAL AS Value FROM agg
    UNION ALL
    SELECT N''Complimentary'', COMP FROM agg
)
SELECT
  Label,
  FORMAT(Value, ''N2'') AS Value,
  Label AS Id,
  N''linear'' AS Curve,
  N''total'' AS Stack,
  N''true'' AS Area,
  N''ascending'' AS StackOrder,
  N''false'' AS ShowMark,
  N''Removed from cost (GBP)'' AS LegendLabel
FROM rows

SELECT
  N''Comps & Staff Meals'' AS Title,
  N''Cost removed from consumption'' AS Description,
  NULL AS Trend,
  NULL AS Chip,
  (SELECT FORMAT(SUM(F.STAFF_MEAL) + SUM(F.COMP), ''N2'') FROM presentation.F_MARGEBRUT_MONTH F WHERE 1=1 @FilterClause) AS PiePrimaryText,
  N''Removed from cost (GBP)'' AS PieSecondaryText';
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutCompsSplit', N'PieChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Comps & staff meals split (live -- Gift-to-Guest/Management/Rooms sub-split awaits a comp source)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Comps & staff meals split (live -- Gift-to-Guest/Management/Rooms sub-split awaits a comp source)', @me, @me, GETDATE(), GETDATE());
PRINT 'MargeBrutCompsSplit merged';

PRINT '=== Marge Brut visualisation queries rewired to live reads (9 datasets) ===';

/* ---------------------------------------------------------------------------
   POST-RUN MCP SHAPE TEST (per CLAUDE.md "Testing Visualisation Queries via
   MCP"): F_MARGEBRUT_MONTH is not populated anywhere yet, so each query was
   shape-tested by substituting a small inline VALUES CTE aliased as
   F_MARGEBRUT_MONTH (F_PURCHASES_DAY similarly for dataset 7) with the 15/14
   real columns, run read-only from the core DB with @FilterClause replaced
   by '' -- confirms the SQL parses and RS1/RS2 column names match the card
   schema. Full results in task-7-report.md. Once F_MARGEBRUT_MONTH is
   populated (post go-live), re-run the same test against the real table.
   --------------------------------------------------------------------------- */
