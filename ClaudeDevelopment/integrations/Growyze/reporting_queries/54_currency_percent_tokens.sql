/*==============================================================================
  54_currency_percent_tokens.sql
  O5 Plan 4 -- currency and percent formatting tokens

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md 5a

  WHAT THIS FIXES
    Money and percentage values across the Growyze 3-pack render without a
    currency symbol or percent sign. Two mechanisms are involved:

      * SingleKPICard has NO display-format configuration. Its `Value` is a
        pre-formatted STRING built in SQL, so the only place a currency symbol
        can come from is the query itself. (This corrects sub-item S9, which
        proposed diffing DashboardGridItem display config -- no such config
        exists.)

      * The data grids DO carry per-column type tokens (TEXT / INT / DECIMAL /
        PERCENT / CURRENCY) in their header result set. Money columns are
        currently typed DECIMAL.

  SCOPE / BLAST RADIUS  (measured on UAT report DB, 2026-08-03)
    NetSales     SingleKPICard -- 21 cards / 16 orgs (10 in the Growyze pack)
    InvWasteCost SingleKPICard -- 18 cards / 11 orgs (10 in the Growyze pack)
    All others are confined to the 5 Growyze orgs, except InvKPIGrouped (6).
    Fixing in place with the fan-out accepted -- decision recorded in the spec:
    a money KPI rendering "19,009" with no symbol is a defect on every org.

  DELIBERATELY NOT IN THIS SCRIPT
    * GrowyzeMenuEngineering and InvUseAnalisys type tokens. Script 56 makes
      STRUCTURAL changes to both headers (a column reorder, and a 19->8 column
      cut). Editing their tokens here as well would either be wasted work or
      collide, so both are handled wholly in 56.
    * Any change to what a query MEASURES. This script only changes presentation.

  ExecutionQuery vs QueryTemplate
    The card SPs read COALESCE(ExecutionQuery, QueryTemplate). Editing only
    QueryTemplate on a dataset whose ExecutionQuery is populated is a SILENT
    NO-OP. This script updates BOTH columns and reports the rows touched in each
    so the two stay in sync.

    NOTE: InvKPIGrouped's ExecutionQuery (10,678 chars) is DIVERGED from its
    QueryTemplate (8,443) by 2,235 characters -- the template is stale against
    what actually runs. This script does not attempt to reconcile that; it
    applies the token fix to whichever column contains the target text and
    reports each independently. The divergence is a separate finding.

  IDEMPOTENT
    Every UPDATE is guarded with CHARINDEX on the target text, so re-running is
    a no-op and cannot double-prefix a currency symbol. CHARINDEX is used rather
    than LIKE deliberately: LIKE would treat the [TypeNN] brackets as character
    classes and require escaping.

  *** ENCODING -- WHY THERE IS NO POUND SIGN IN THIS FILE ***
    This script is deployed with Invoke-Sqlcmd -InputFile. sqlcmd decodes a
    UTF-8 file that has NO BYTE-ORDER MARK using the system ANSI codepage, which
    turns a pound sign into two mojibake characters -- and the mangled text then
    goes straight into the stored query and renders on the dashboard. The Plan 2
    runner already screens for this exact failure (it greps the deployed queries
    for mojibake), which is evidence it has bitten before.

    So this file is PURE ASCII. Currency symbols are emitted as NCHAR(163),
    evaluated by sp_executesql at card-render time. That makes correctness
    independent of file encoding, editor and shell, rather than dependent on all
    three. Do NOT "simplify" NCHAR(163) back to a literal symbol.

  Run against: core (UAT/DEV/TEST). Read-only verification in 88_verify_plan4.sql.
==============================================================================*/

SET NOCOUNT ON;

DECLARE @Changes TABLE (
    Item          NVARCHAR(200),
    TargetColumn  NVARCHAR(20),
    RowsAffected  INT
);

/*------------------------------------------------------------------------------
  1. NetSales (SingleKPICard) -- prepend the currency symbol
     Live column: ExecutionQuery (in sync with QueryTemplate at 1,366 chars)
------------------------------------------------------------------------------*/
/* NCHAR(163) rather than a literal pound sign -- see the ENCODING note in the
   header. The stored query then contains "NCHAR(163) + FORMAT(...)", which
   sp_executesql evaluates to the symbol at card-render time. Identical output,
   but this file stays pure ASCII and cannot be mangled by sqlcmd. */
DECLARE @NetSalesOld NVARCHAR(200) = N'FORMAT(ROUND(SUM(NET_VALUE), 0), ''N0'') AS Value';
DECLARE @NetSalesNew NVARCHAR(200) = N'NCHAR(163) + FORMAT(ROUND(SUM(NET_VALUE), 0), ''N0'') AS Value';

UPDATE core.core.VisualisationQueries
SET ExecutionQuery = REPLACE(ExecutionQuery, @NetSalesOld, @NetSalesNew),
    ModifiedDate   = SYSUTCDATETIME(),
    ModifiedBy     = N'O5-Plan4-54'
WHERE DataSetName = N'NetSales'
  AND VisualizationType = N'SingleKPICard'
  AND Status = N'LIVE'
  AND ExecutionQuery IS NOT NULL
  AND CHARINDEX(@NetSalesOld, ExecutionQuery) > 0
  AND CHARINDEX(@NetSalesNew, ExecutionQuery) = 0;
INSERT INTO @Changes VALUES (N'NetSales / SingleKPICard', N'ExecutionQuery', @@ROWCOUNT);

UPDATE core.core.VisualisationQueries
SET QueryTemplate = REPLACE(QueryTemplate, @NetSalesOld, @NetSalesNew),
    ModifiedDate  = SYSUTCDATETIME(),
    ModifiedBy    = N'O5-Plan4-54'
WHERE DataSetName = N'NetSales'
  AND VisualizationType = N'SingleKPICard'
  AND Status = N'LIVE'
  AND CHARINDEX(@NetSalesOld, QueryTemplate) > 0
  AND CHARINDEX(@NetSalesNew, QueryTemplate) = 0;
INSERT INTO @Changes VALUES (N'NetSales / SingleKPICard', N'QueryTemplate', @@ROWCOUNT);


/*------------------------------------------------------------------------------
  2. InvWasteCost (SingleKPICard) -- prepend the currency symbol
     Live column: ExecutionQuery (in sync at 455 chars)
     The card title stays "Waste Cost"; the design doc offered "retitle to
     Waste items" as the alternative, and currency is the correct reading --
     the measure is WASTE_QTY * UOM_COST, i.e. money.
------------------------------------------------------------------------------*/
DECLARE @WasteOld NVARCHAR(300) = N'FORMAT(ROUND(SUM(ABS(ISNULL(FU.WASTE_QTY, 0)) * ISNULL(FU.UOM_COST, 0)), 2), ''N0'') AS Value';
DECLARE @WasteNew NVARCHAR(300) = N'NCHAR(163) + FORMAT(ROUND(SUM(ABS(ISNULL(FU.WASTE_QTY, 0)) * ISNULL(FU.UOM_COST, 0)), 2), ''N0'') AS Value';

UPDATE core.core.VisualisationQueries
SET ExecutionQuery = REPLACE(ExecutionQuery, @WasteOld, @WasteNew),
    ModifiedDate   = SYSUTCDATETIME(),
    ModifiedBy     = N'O5-Plan4-54'
WHERE DataSetName = N'InvWasteCost'
  AND VisualizationType = N'SingleKPICard'
  AND Status = N'LIVE'
  AND ExecutionQuery IS NOT NULL
  AND CHARINDEX(@WasteOld, ExecutionQuery) > 0
  AND CHARINDEX(@WasteNew, ExecutionQuery) = 0;
INSERT INTO @Changes VALUES (N'InvWasteCost / SingleKPICard', N'ExecutionQuery', @@ROWCOUNT);

UPDATE core.core.VisualisationQueries
SET QueryTemplate = REPLACE(QueryTemplate, @WasteOld, @WasteNew),
    ModifiedDate  = SYSUTCDATETIME(),
    ModifiedBy    = N'O5-Plan4-54'
WHERE DataSetName = N'InvWasteCost'
  AND VisualizationType = N'SingleKPICard'
  AND Status = N'LIVE'
  AND CHARINDEX(@WasteOld, QueryTemplate) > 0
  AND CHARINDEX(@WasteNew, QueryTemplate) = 0;
INSERT INTO @Changes VALUES (N'InvWasteCost / SingleKPICard', N'QueryTemplate', @@ROWCOUNT);


/*------------------------------------------------------------------------------
  3. InvCOGSByCategory -- NOT HANDLED HERE.
     Its pie centre total needs the currency symbol, but it ALSO disagrees with
     the sum of its own slices (the subquery omits the guards the Base CTE
     applies), joins CALENDAR without a CAST, and carries no source scope.
     Script 55 rewrites both InvCOGSByCategory queries in full and adds the
     currency symbol as part of that rewrite. Doing it here as well would be
     dead work at best and a merge hazard at worst.
------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------
  4. ProductComparison (CustomDataGrid) -- 5 money columns + 1 percent
     Live column: QueryTemplate. Labels use no N prefix in this query.

     Qty Sold (Type5) stays DECIMAL -- it is a quantity, not money.

     The trailing comma is included in every search string on purpose:
     without it, '[Type1]' is a prefix of '[Type10]'/'[Type11]' and a REPLACE
     would corrupt them.
------------------------------------------------------------------------------*/
DECLARE @PCTokens TABLE (OldText NVARCHAR(100), NewText NVARCHAR(100), ColName NVARCHAR(40));
INSERT INTO @PCTokens VALUES
    (N'''DECIMAL'' AS [Type6],',  N'''CURRENCY'' AS [Type6],',  N'Revenue'),
    (N'''DECIMAL'' AS [Type7],',  N'''CURRENCY'' AS [Type7],',  N'COGS'),
    (N'''DECIMAL'' AS [Type8],',  N'''CURRENCY'' AS [Type8],',  N'Profit'),
    (N'''DECIMAL'' AS [Type9],',  N'''PERCENT'' AS [Type9],',   N'GP%'),
    (N'''DECIMAL'' AS [Type10],', N'''CURRENCY'' AS [Type10],', N'Menu Price'),
    (N'''DECIMAL'' AS [Type11],', N'''CURRENCY'' AS [Type11],', N'Recipe Cost');

DECLARE @o NVARCHAR(100), @n NVARCHAR(100), @c NVARCHAR(40), @rc INT;

DECLARE pc CURSOR LOCAL FAST_FORWARD FOR SELECT OldText, NewText, ColName FROM @PCTokens;
OPEN pc; FETCH NEXT FROM pc INTO @o, @n, @c;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE core.core.VisualisationQueries
    SET QueryTemplate = REPLACE(QueryTemplate, @o, @n),
        ModifiedDate  = SYSUTCDATETIME(),
        ModifiedBy    = N'O5-Plan4-54'
    WHERE DataSetName = N'ProductComparison'
      AND VisualizationType = N'CustomDataGrid'
      AND Status = N'LIVE'
      AND CHARINDEX(@o, QueryTemplate) > 0;
    SET @rc = @@ROWCOUNT;
    INSERT INTO @Changes VALUES (N'ProductComparison / ' + @c, N'QueryTemplate', @rc);
    FETCH NEXT FROM pc INTO @o, @n, @c;
END
CLOSE pc; DEALLOCATE pc;


/*------------------------------------------------------------------------------
  5. GrowyzeCategoryStockTrend (CustomDataGrid) -- 3 money, 1 percent, 1 count
     Live column: QueryTemplate. Labels use the N prefix in this query.
     Stocktakes (Type2) is a COUNT and is retyped DECIMAL -> INT so it stops
     rendering with two decimal places.
------------------------------------------------------------------------------*/
DECLARE @CSTTokens TABLE (OldText NVARCHAR(100), NewText NVARCHAR(100), ColName NVARCHAR(40));
INSERT INTO @CSTTokens VALUES
    (N'N''DECIMAL'' AS [Type2],', N'N''INT'' AS [Type2],',      N'Stocktakes (count)'),
    (N'N''DECIMAL'' AS [Type3],', N'N''CURRENCY'' AS [Type3],', N'Earliest Value'),
    (N'N''DECIMAL'' AS [Type4],', N'N''CURRENCY'' AS [Type4],', N'Latest Value'),
    (N'N''DECIMAL'' AS [Type5],', N'N''CURRENCY'' AS [Type5],', N'Change'),
    (N'N''DECIMAL'' AS [Type6],', N'N''PERCENT'' AS [Type6],',  N'Change %');

DECLARE cst CURSOR LOCAL FAST_FORWARD FOR SELECT OldText, NewText, ColName FROM @CSTTokens;
OPEN cst; FETCH NEXT FROM cst INTO @o, @n, @c;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE core.core.VisualisationQueries
    SET QueryTemplate = REPLACE(QueryTemplate, @o, @n),
        ModifiedDate  = SYSUTCDATETIME(),
        ModifiedBy    = N'O5-Plan4-54'
    WHERE DataSetName = N'GrowyzeCategoryStockTrend'
      AND VisualizationType = N'CustomDataGrid'
      AND Status = N'LIVE'
      AND CHARINDEX(@o, QueryTemplate) > 0;
    SET @rc = @@ROWCOUNT;
    INSERT INTO @Changes VALUES (N'GrowyzeCategoryStockTrend / ' + @c, N'QueryTemplate', @rc);
    FETCH NEXT FROM cst INTO @o, @n, @c;
END
CLOSE cst; DEALLOCATE cst;


/*------------------------------------------------------------------------------
  6. InvKPIGrouped (CustomGroupedDataGrid) -- 4 money columns
     Live column: ExecutionQuery, WHICH IS DIVERGED FROM QueryTemplate.
     Both are updated and reported separately; a differing row count between
     the two is expected here and is evidence of the divergence, not a failure.

     Variance % (Type5/6/7) are already PERCENT -- correctly typed, left alone.
     '[Type1]' is safe to match unbracketed here because the only other Type1*
     entries are 'NULL AS [Type10]' etc., which do not carry the
     "'DECIMAL' AS " prefix.
------------------------------------------------------------------------------*/
DECLARE @KPITokens TABLE (OldText NVARCHAR(100), NewText NVARCHAR(100), ColName NVARCHAR(40));
INSERT INTO @KPITokens VALUES
    (N'''DECIMAL'' AS [Type1]', N'''CURRENCY'' AS [Type1]', N'Net Sales'),
    (N'''DECIMAL'' AS [Type2]', N'''CURRENCY'' AS [Type2]', N'Recipe Cost'),
    (N'''DECIMAL'' AS [Type3]', N'''CURRENCY'' AS [Type3]', N'Waste Cost'),
    (N'''DECIMAL'' AS [Type4]', N'''CURRENCY'' AS [Type4]', N'Variance Cost');

DECLARE kpi CURSOR LOCAL FAST_FORWARD FOR SELECT OldText, NewText, ColName FROM @KPITokens;
OPEN kpi; FETCH NEXT FROM kpi INTO @o, @n, @c;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE core.core.VisualisationQueries
    SET ExecutionQuery = REPLACE(ExecutionQuery, @o, @n),
        ModifiedDate   = SYSUTCDATETIME(),
        ModifiedBy     = N'O5-Plan4-54'
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
        ModifiedBy    = N'O5-Plan4-54'
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
  Change report
    A zero against an item means EITHER already applied (re-run) OR the target
    text was not found -- those two cases are distinguished by
    88_verify_plan4.sql, which asserts the NEW text is present.
------------------------------------------------------------------------------*/
SELECT Item, TargetColumn, RowsAffected
FROM @Changes
ORDER BY Item, TargetColumn;

SELECT
    SUM(RowsAffected) AS TotalRowsChanged,
    SUM(CASE WHEN RowsAffected = 0 THEN 1 ELSE 0 END) AS ItemsWithNoChange
FROM @Changes;
