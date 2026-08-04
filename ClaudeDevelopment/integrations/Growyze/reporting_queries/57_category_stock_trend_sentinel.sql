/*==============================================================================
  57_category_stock_trend_sentinel.sql
  O5 Plan 4 -- GrowyzeCategoryStockTrend: relabel the D_INVITEM sentinel,
               tidy two column headers

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md 5c

  THE SENTINEL -- AND WHY WE RELABEL RATHER THAN FILTER

  The card groups on COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]),
  and D_INVITEM's top-level sentinel row name, 'All INVITEMs', leaks through as
  if it were a real category. Both the design doc and sub-item S1's notes
  observed this.

  The design doc instructed: "contains an 'All INVITEMs' row with all-zero
  values -- filter it out."  THAT IS WRONG ON THIS DATA. Measured on Dirty Sixth
  (UAT, 2026-08-03), the 'All INVITEMs' bucket holds:

      Beverages       159 items,  8 count dates,  GBP 44,429.65
      Food            224 items,  2 count dates,  GBP 16,667.69
      All INVITEMs      9 items,  8 count dates,  GBP  1,164.56   <-- real money

  Nine real inventory items carrying GBP 1,164.56 of counted stock. Filtering the
  row out would silently delete that value from the grid and make the card
  under-report total counted stock. The doc's observation was made on Padel
  Social, where the bucket happens to be empty; it does not generalise.

  FIX: relabel the sentinel to 'Uncategorised'. This keeps the money visible and
  names the condition honestly. It also matches the platform idiom -- Plan 1's
  category-sentinel work created exactly this bucket for PRODUCTS, for exactly
  this reason (Padel's set is {Beverages, Retail, Food, Other, Uncategorised}).

  A relabel, not a filter, means the grid's category values still sum to the
  org's total counted stock. Worth preserving: any future check that reconciles
  this card against a stocktake total depends on it.

  HEADER TIDY
    'Change (GBP )' -> 'Change'    (script 54 retypes Type5 to CURRENCY, so the
                                 symbol comes from the type token, not the label)
    'Change (%)' -> 'Change %'  (Type6 becomes PERCENT)

  SCOPE: 1 dataset, 1 card type, 5 cards, 5 orgs -- the Growyze Overview grid.
  This query is already correctly source-scoped (invitem.[BOTTOM_SRC] =
  'int_growyze001') and already CASTs its CALENDAR join, so neither portability
  fix is needed here.

  ORDERING: independent of 54. 54 touches only [TypeN] tokens; this touches the
  category expression and two [LabelN] values. No overlap, either order is safe.

  IDEMPOTENT: CHARINDEX-guarded. CHARINDEX not LIKE, so the [] in column names
  are not treated as character classes.
  Run against: core (UAT/DEV/TEST).
==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (
    SELECT 1 FROM core.core.VisualisationQueries
    WHERE DataSetName = N'GrowyzeCategoryStockTrend'
      AND VisualizationType = N'CustomDataGrid'
      AND Status = N'LIVE'
      AND ExecutionQuery IS NOT NULL)
BEGIN
    THROW 51057, 'GrowyzeCategoryStockTrend now has ExecutionQuery populated. This script edits QueryTemplate (verified live 2026-08-03). Editing the wrong column is a silent no-op -- re-check first.', 1;
END

DECLARE @Rows INT;

/*------------------------------------------------------------------------------
  1. Relabel the sentinel inside the `counts` CTE.
------------------------------------------------------------------------------*/
DECLARE @CatOld NVARCHAR(400) =
    N'MAX(COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])) AS category';
DECLARE @CatNew NVARCHAR(400) =
    N'MAX(CASE WHEN COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) = N''All INVITEMs''' + CHAR(13) + CHAR(10) +
    N'               THEN N''Uncategorised''' + CHAR(13) + CHAR(10) +
    N'               ELSE COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) END) AS category';

UPDATE core.core.VisualisationQueries
SET QueryTemplate = REPLACE(QueryTemplate, @CatOld, @CatNew),
    ModifiedDate  = SYSUTCDATETIME(),
    ModifiedBy    = N'O5-Plan4-57'
WHERE DataSetName = N'GrowyzeCategoryStockTrend'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE'
  AND CHARINDEX(@CatOld, QueryTemplate) > 0
  AND CHARINDEX(N'N''Uncategorised''', QueryTemplate) = 0;
SET @Rows = @@ROWCOUNT;
PRINT '  Sentinel relabelled to Uncategorised, rows = ' + CAST(@Rows AS VARCHAR(10)) + ' (of 1; 0 on a re-run)';

/*------------------------------------------------------------------------------
  2. Header tidy.
------------------------------------------------------------------------------*/
/* The existing header contains a literal pound sign. It is matched via
   NCHAR(163) so that THIS FILE stays pure ASCII -- sqlcmd decodes a UTF-8 file
   with no BOM using the system ANSI codepage, which would mangle a literal
   symbol here into mojibake and the search would then silently match nothing.
   A no-op that reports success is the worst outcome available, so the symbol is
   constructed rather than typed. See script 54's ENCODING note. */
DECLARE @LblPoundOld NVARCHAR(100) = N'N''Change (' + NCHAR(163) + N')''      AS [Label5]';
DECLARE @LblPoundNew NVARCHAR(100) = N'N''Change''          AS [Label5]';
DECLARE @LblPctOld   NVARCHAR(100) = N'N''Change (%)''      AS [Label6]';
DECLARE @LblPctNew   NVARCHAR(100) = N'N''Change %''        AS [Label6]';

UPDATE core.core.VisualisationQueries
SET QueryTemplate = REPLACE(REPLACE(QueryTemplate, @LblPoundOld, @LblPoundNew), @LblPctOld, @LblPctNew),
    ModifiedDate  = SYSUTCDATETIME(),
    ModifiedBy    = N'O5-Plan4-57'
WHERE DataSetName = N'GrowyzeCategoryStockTrend'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE'
  AND CHARINDEX(@LblPoundOld, QueryTemplate) > 0;
SET @Rows = @@ROWCOUNT;
PRINT '  Change / Change % headers tidied, rows = ' + CAST(@Rows AS VARCHAR(10)) + ' (of 1; 0 on a re-run)';


/*------------------------------------------------------------------------------
  Assertions. Each states what makes it FAIL.

  Chk_NoBareSentinel is the one that matters: it FAILS if the raw COALESCE is
  still assigned straight to `category`, which is the state that lets the
  sentinel leak. It does NOT merely assert that the word 'Uncategorised' appears
  somewhere -- that would pass even if the CASE were mis-wired.
------------------------------------------------------------------------------*/
SELECT
    DataSetName,
    CASE WHEN CHARINDEX(@CatOld, QueryTemplate) = 0
         THEN 'PASS' ELSE 'FAIL - bare COALESCE still assigned to category; sentinel still leaks' END AS Chk_NoBareSentinel,
    CASE WHEN CHARINDEX(N'THEN N''Uncategorised''', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - no Uncategorised branch present' END AS Chk_RelabelPresent,
    CASE WHEN CHARINDEX(@LblPoundOld, QueryTemplate) = 0
              AND CHARINDEX(N'N''Change''', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - Change header not tidied' END AS Chk_Headers,
    CASE WHEN CHARINDEX(N'invitem.[BOTTOM_SRC] = ''int_growyze001''', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - source scope was lost by this edit' END AS Chk_SourceScopeIntact
FROM core.core.VisualisationQueries
WHERE DataSetName = N'GrowyzeCategoryStockTrend'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE';
