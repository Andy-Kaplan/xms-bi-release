/* =============================================================================
   16_cost_ratio_total_fix.sql
   -----------------------------------------------------------------------------
   Target server  : xms-bi-uat   (SQL Managed Instance)
   Target database: core          (writes to core.core.VisualisationQueries)
   Ledger         : O8
   Purpose        : Give MargeBrutCostRatioByGroup a real headline figure.

   SYMPTOM
   The "Cost of Sales % by Group" card renders its five bars correctly but shows
   a headline of "0.00" above them (observed on The Oak & Vine, UAT org 16).

   ROOT CAUSE
   14_margebrut_vis_queries.sql returns `NULL AS TotalValue` in the header
   result set, with the reasoning "a % grand-total is not meaningful, so NULL".
   The premise is wrong on both counts:
     * A grand-total cost-of-sales % IS meaningful and already exists elsewhere
       on this dashboard -- it is exactly what MargeBrutCostRatioKPI shows and
       what the grid's GRAND TOTAL row reports in its Cost % column (14.8%).
     * BarChartCard does not treat NULL as "no headline"; it parses TotalValue as
       numeric and renders the NULL as 0.00. The sibling
       MargeBrutPurchasesBySupplier proves a non-NULL TotalValue renders its real
       value, so NULL is the only difference in play.
   A card reading "0.00" next to bars sitting at 20-40% is not a blank slot --
   it states a specific, wrong number.

   FIX
   Return the same coverage-matched ratio the hero KPI uses, scaled to match the
   bar units (percentage points, not a 0-1 fraction, since BarValue is
   `100.0 * CONSUMPTION / TURNOVER_EXCL_CONS`):

       100.0 * SUM(CONSUMPTION) / NULLIF(SUM(CASE WHEN CONSUMPTION IS NOT NULL
                                                  THEN TURNOVER_EXCL END), 0)

   The CASE is the coverage-matched denominator: months with no stocktake have
   NULL CONSUMPTION, and including their turnover would understate the ratio.
   Dropping the CASE would make the headline disagree with both the KPI card and
   the grid -- it is load-bearing, not defensive.

   The subquery aliases the table `F` so the injected @FilterClause (defined over
   `F.[PERIOD_MONTH]`) resolves inside it, matching how
   MargeBrutPurchasesBySupplier's header subquery is written.

   VERIFIED (read-only, UAT The Oak & Vine, unfiltered = all 4 months):
     proposed TotalValue = 14.8
     MargeBrutCostRatioKPI Value = 14.8%   grid GRAND TOTAL Cost % = 14.8%
   All three now agree. Data query and bar values are untouched.

   Idempotent: MERGE on (DataSetName, VisualizationType, Status). Safe to re-run.
   Supersedes section 6 of 14_margebrut_vis_queries.sql -- fold this body back
   into 14 when that script is next revised, so a clean run needs only 14.
   ============================================================================= */

SET NOCOUNT ON;

DECLARE @me  NVARCHAR(128) = SUSER_SNAME();
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'WITH base AS (
    SELECT
        CASE WHEN F.GROUP_NAME IN (N''Food'', N''Breakfast'') THEN N''Food'' ELSE F.GROUP_NAME END AS BUCKET,
        F.CONSUMPTION,
        -- Coverage-matched denominator -- see the MargeBrutGrid base CTE comment.
        CASE WHEN F.CONSUMPTION IS NOT NULL THEN F.TURNOVER_EXCL END AS TURNOVER_EXCL_CONS
    FROM presentation.F_MARGEBRUT_MONTH F
    WHERE 1=1
    @FilterClause
),
agg AS (
    SELECT BUCKET, SUM(TURNOVER_EXCL_CONS) AS TURNOVER_EXCL_CONS, SUM(CONSUMPTION) AS CONSUMPTION
    FROM base
    GROUP BY BUCKET
),
ratios AS (
    SELECT BUCKET,
        CAST(CASE WHEN TURNOVER_EXCL_CONS > 0 THEN 100.0 * CONSUMPTION / TURNOVER_EXCL_CONS END AS DECIMAL(9,1)) AS COST_PCT
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
  -- BarChartCard parses TotalValue as numeric and renders NULL as 0.00, so this
  -- must be a real number. Overall cost-of-sales % in percentage points, on the
  -- same coverage-matched denominator as MargeBrutCostRatioKPI and the grid
  -- GRAND TOTAL, so all three agree. Alias F matches the @FilterClause column.
  (SELECT CAST(100.0 * SUM(F.CONSUMPTION)
               / NULLIF(SUM(CASE WHEN F.CONSUMPTION IS NOT NULL THEN F.TURNOVER_EXCL END), 0)
          AS DECIMAL(9,1))
   FROM presentation.F_MARGEBRUT_MONTH F
   WHERE 1=1
   @FilterClause) AS TotalValue,
  NULL AS Chip';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutCostRatioByGroup', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Status = src.Status
WHEN MATCHED THEN UPDATE SET Version=1, QueryTemplate=@sql, ParameterMappings=N'{}', FilterDefinitions=N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', OutputDefinitions=N'{}', ExecutionQuery=NULL, Description=N'Cost ratio by group (live)', ModifiedDate=GETDATE(), ModifiedBy=@me
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (src.DataSetName, src.VisualizationType, 1, src.Status, @sql, N'{}', N'{"PeriodMonth": {"column": "F.[PERIOD_MONTH]", "type": "IN", "dataType": "DATE"}}', N'{}', NULL, N'Cost ratio by group (live)', @me, @me, GETDATE(), GETDATE());

PRINT 'MargeBrutCostRatioByGroup merged (TotalValue now a real figure)';

-- ---------------------------------------------------------------------------
-- Verify: TotalValue is no longer the NULL literal.
-- ---------------------------------------------------------------------------
SELECT
    N'MargeBrutCostRatioByGroup TotalValue' AS Check_Name,
    CASE WHEN COALESCE(ExecutionQuery, QueryTemplate) LIKE N'%NULL AS TotalValue%'
         THEN N'FAIL - still NULL'
         WHEN COALESCE(ExecutionQuery, QueryTemplate) LIKE N'%) AS TotalValue%'
         THEN N'PASS - computed'
         ELSE N'FAIL - unrecognised' END AS Verdict
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName = N'MargeBrutCostRatioByGroup'
  AND VisualizationType = N'BarChartCard'
  AND Status = N'LIVE';
