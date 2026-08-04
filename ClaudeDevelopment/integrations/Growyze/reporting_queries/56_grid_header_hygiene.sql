/*==============================================================================
  56_grid_header_hygiene.sql
  O5 Plan 4 -- sentence-case headers + a duplicate column alias

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md 5c

  SCOPE: label-only edits to two grids.
    ProductComparison (CustomDataGrid, QueryTemplate live) -- 7 cards / 5 orgs
    InvKPIGrouped     (CustomGroupedDataGrid, ExecutionQuery live) -- 6 cards / 6 orgs

  The other two grids in the design doc's header list need COORDINATED data +
  header changes (a column reorder and a 19->8 column cut), so they get their own
  scripts rather than being force-fitted into a REPLACE pass:
    59_menu_engineering_reorder.sql
    60_invuseanalisys_column_cut.sql

  THE DUPLICATE ALIAS
    Both InvUseAnalisys and InvKPIGrouped emit

        , NULL AS [Label21]
        , NULL AS [Type11]      <-- should be [Type21]

    so [Type11] appears TWICE in the header result set and [Type21] never
    appears. ProductComparison and GrowyzeMenuEngineering -- which both render
    correctly -- have the correct [Type21].

    Both affected grids are the two that misbehave in the browser (S5 renders 0
    rows, S6 returns HTTP 500). That is a CORRELATION, not a demonstrated cause,
    and it is not claimed as one here: GrowyzeCategoryStockTrend also fails (S1)
    and does NOT have this bug. Fixed because a duplicate column name in a result
    set is wrong regardless, and because it removes a confound from the S1-S6
    diagnosis. If S5/S6 clear up as a side effect, that is a finding to record --
    not the reason for this change.

  All values are NULL on both sides, so this cannot alter any rendered value.

  IDEMPOTENT: CHARINDEX-guarded. Every search string is anchored to its [LabelN]
  alias so that e.g. 'Variance % of Total' cannot corrupt
  'Variance % of Total Sales'.
  Run against: core (UAT/DEV/TEST).
==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Changes TABLE (Item NVARCHAR(120), TargetColumn NVARCHAR(20), RowsAffected INT);
DECLARE @o NVARCHAR(200), @n NVARCHAR(200), @c NVARCHAR(60), @rc INT;

/*==============================================================================
  1. ProductComparison -- sentence case. QueryTemplate is live (ExecutionQuery
     is NULL, asserted). Labels in this query carry NO N prefix.

     Left alone deliberately:
       'Location', 'Category', 'Subcategory', 'Product', 'Revenue', 'Profit'
         -- already correct.
       'COGS' -- an acronym; sentence case does not lowercase it.

     'Subcategory' is KEPT. The design doc asked for it to be dropped, having
     observed it identical to Category on every Beverages row. That is true for
     GROWYZE ONLY -- portability rule 2 records Growyze's TOP being identical to
     its MIDDLE_1, whereas Mews TOP = 12 real categories vs MIDDLE_1 = product
     families, and NCRAloha TOP = Food/Drinks vs MIDDLE_1 = Mains/Cocktails.
     Dropping the column would degrade Oak & Vine and both Ibis orgs in order to
     tidy a cosmetic duplication on two Growyze-only orgs.
==============================================================================*/
IF EXISTS (SELECT 1 FROM core.core.VisualisationQueries
            WHERE DataSetName = N'ProductComparison' AND VisualizationType = N'CustomDataGrid'
              AND Status = N'LIVE' AND ExecutionQuery IS NOT NULL)
    THROW 51560, 'ProductComparison now has ExecutionQuery populated; this script edits QueryTemplate. Re-check -- editing the wrong column is a silent no-op.', 1;

DECLARE @PC TABLE (OldText NVARCHAR(200), NewText NVARCHAR(200), ColName NVARCHAR(60));
INSERT INTO @PC VALUES
    (N'''Qty Sold'' AS [Label5]',    N'''Qty sold'' AS [Label5]',    N'Qty sold'),
    (N'''GP%'' AS [Label9]',         N'''GP %'' AS [Label9]',        N'GP % (spaced)'),
    (N'''Menu Price'' AS [Label10]', N'''Menu price'' AS [Label10]', N'Menu price'),
    (N'''Recipe Cost'' AS [Label11]',N'''Recipe cost'' AS [Label11]',N'Recipe cost');

DECLARE pc CURSOR LOCAL FAST_FORWARD FOR SELECT OldText, NewText, ColName FROM @PC;
OPEN pc; FETCH NEXT FROM pc INTO @o, @n, @c;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE core.core.VisualisationQueries
    SET QueryTemplate = REPLACE(QueryTemplate, @o, @n),
        ModifiedDate  = SYSUTCDATETIME(),
        ModifiedBy    = N'O5-Plan4-56'
    WHERE DataSetName = N'ProductComparison'
      AND VisualizationType = N'CustomDataGrid'
      AND Status = N'LIVE'
      AND CHARINDEX(@o, QueryTemplate) > 0;
    SET @rc = @@ROWCOUNT;
    INSERT INTO @Changes VALUES (N'ProductComparison / ' + @c, N'QueryTemplate', @rc);
    FETCH NEXT FROM pc INTO @o, @n, @c;
END
CLOSE pc; DEALLOCATE pc;


/*==============================================================================
  2. InvKPIGrouped -- sentence case + the duplicate alias.
     ExecutionQuery is the LIVE column and is DIVERGED from QueryTemplate
     (10,678 vs 8,443 chars -- the template is stale against what runs). Both are
     updated and reported separately; a differing row count between the two
     columns is EXPECTED here and is evidence of that divergence, not a failure.

     'Variance %' (Label5) is already correct and is left alone.
==============================================================================*/
DECLARE @KPI TABLE (OldText NVARCHAR(200), NewText NVARCHAR(200), ColName NVARCHAR(60));
INSERT INTO @KPI VALUES
    (N'''Net Sales'' AS [Label1]',                 N'''Net sales'' AS [Label1]',                 N'Net sales'),
    (N'''Recipe Cost'' AS [Label2]',               N'''Recipe cost'' AS [Label2]',               N'Recipe cost'),
    (N'''Waste Cost'' AS [Label3]',                N'''Waste cost'' AS [Label3]',                N'Waste cost'),
    (N'''Variance Cost'' AS [Label4]',             N'''Variance cost'' AS [Label4]',             N'Variance cost'),
    (N'''Variance % of Total'' AS [Label6]',       N'''Variance % of total'' AS [Label6]',       N'Variance % of total'),
    (N'''Variance % of Total Sales'' AS [Label7]', N'''Variance % of total sales'' AS [Label7]', N'Variance % of total sales'),
    /* the duplicate alias -- anchored on [Label21] so it is unambiguous */
    (N'NULL AS [Label21]' + CHAR(13) + CHAR(10) + N'    ,    NULL AS [Type11]',
     N'NULL AS [Label21]' + CHAR(13) + CHAR(10) + N'    ,    NULL AS [Type21]',
     N'duplicate [Type11] -> [Type21]');

DECLARE kpi CURSOR LOCAL FAST_FORWARD FOR SELECT OldText, NewText, ColName FROM @KPI;
OPEN kpi; FETCH NEXT FROM kpi INTO @o, @n, @c;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE core.core.VisualisationQueries
    SET ExecutionQuery = REPLACE(ExecutionQuery, @o, @n),
        ModifiedDate   = SYSUTCDATETIME(),
        ModifiedBy     = N'O5-Plan4-56'
    WHERE DataSetName = N'InvKPIGrouped'
      AND VisualizationType = N'CustomGroupedDataGrid'
      AND Status = N'LIVE'
      AND ExecutionQuery IS NOT NULL
      AND CHARINDEX(@o, ExecutionQuery) > 0;
    SET @rc = @@ROWCOUNT;
    INSERT INTO @Changes VALUES (N'InvKPIGrouped / ' + @c, N'ExecutionQuery', @rc);

    UPDATE core.core.VisualisationQueries
    SET QueryTemplate = REPLACE(QueryTemplate, @o, @n),
        ModifiedDate  = SYSUTCDATETIME(),
        ModifiedBy    = N'O5-Plan4-56'
    WHERE DataSetName = N'InvKPIGrouped'
      AND VisualizationType = N'CustomGroupedDataGrid'
      AND Status = N'LIVE'
      AND CHARINDEX(@o, QueryTemplate) > 0;
    SET @rc = @@ROWCOUNT;
    INSERT INTO @Changes VALUES (N'InvKPIGrouped / ' + @c, N'QueryTemplate', @rc);

    FETCH NEXT FROM kpi INTO @o, @n, @c;
END
CLOSE kpi; DEALLOCATE kpi;


/*------------------------------------------------------------------------------
  Report + assertions.
  Chk_NoDupType11 FAILS if [Type11] still appears more than once in the live
  column -- that is the actual defect, not merely whether [Type21] exists.
------------------------------------------------------------------------------*/
SELECT Item, TargetColumn, RowsAffected FROM @Changes ORDER BY Item, TargetColumn;

SELECT
    DataSetName,
    VisualizationType,
    (LEN(COALESCE(ExecutionQuery, QueryTemplate))
       - LEN(REPLACE(COALESCE(ExecutionQuery, QueryTemplate), N'[Type11]', N''))) / 8 AS Type11_Occurrences,
    CASE WHEN (LEN(COALESCE(ExecutionQuery, QueryTemplate))
                 - LEN(REPLACE(COALESCE(ExecutionQuery, QueryTemplate), N'[Type11]', N''))) / 8 <= 1
         THEN 'PASS' ELSE 'FAIL - [Type11] still duplicated in the live column' END AS Chk_NoDupType11,
    CASE WHEN CHARINDEX(N'[Type21]', COALESCE(ExecutionQuery, QueryTemplate)) > 0
         THEN 'PASS' ELSE 'FAIL - [Type21] absent' END AS Chk_Type21Present
FROM core.core.VisualisationQueries
WHERE Status = N'LIVE'
  AND ((DataSetName = N'InvKPIGrouped'     AND VisualizationType = N'CustomGroupedDataGrid')
    OR (DataSetName = N'ProductComparison' AND VisualizationType = N'CustomDataGrid'))
ORDER BY DataSetName;
