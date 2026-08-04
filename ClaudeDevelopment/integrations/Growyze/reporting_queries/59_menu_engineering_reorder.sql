/*==============================================================================
  59_menu_engineering_reorder.sql
  O5 Plan 4 -- GrowyzeMenuEngineering: move Classification to column 2,
               sentence-case headers, fix two type tokens

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md 5c

  WHY
    Classification (Star / Puzzle / Workhorse / Dog) is the most actionable
    column on the Sales & Profitability board and it currently sits LAST, past
    four numeric columns. It moves to position 2, immediately after Menu item,
    so the verdict reads beside the thing being judged.

    Also: Revenue is typed DECIMAL and renders without a currency symbol; GP %
    is typed DECIMAL and renders '88.5' rather than '88.5%'.

  *** HOW THE REORDER IS DONE -- READ THIS BEFORE EDITING ***

  The data query is shaped:

      SELECT Column1, Column2, ... Column29
      FROM ( <branch 1>  UNION ALL  <branch 2> ) z
      ORDER BY z.pri, z.rn

  The OUTER select picks columns BY NAME, while the UNION aligns its two branches
  BY POSITION. So the reorder is achieved by RE-ALIASING branch 1 only -- the
  physical column order is left exactly as it is.

  That has an important consequence: branch 2 (the "No cost data" sentinel row
  that fires when the resolved source has no costed sales at all -- O35) needs NO
  change whatsoever. Its 2nd positional value is still the category NULL and its
  6th is still N''No cost data'', which is precisely what branch 1''s 2nd and 6th
  POSITIONS now carry. Reordering branch 2 as well would silently break the
  alignment. Do not "tidy" it.

  Types across the UNION stay consistent: the new Column2 is NVARCHAR in both
  branches ('Star'/'Dog' vs 'No cost data'), the new Column3 is NVARCHAR(400) vs
  CAST(NULL AS NVARCHAR(400)), and Columns 4-6 are decimals in both.

  Each search string is anchored to its own distinct expression (p.category,
  ROUND(p.qty..., ELSE N'Dog' END...), so no rule can match a string produced by
  another rule. The re-aliasing is therefore order-independent.

  BLAST RADIUS: 5 cards / 5 orgs -- the Growyze Sales & Profitability grid only.
  Live column is QueryTemplate (ExecutionQuery is NULL, asserted below).

  NOT CHANGED: the median-split logic, the resolver, the CAST on the CALENDAR
  join, and the coverage guard on gp_pct -- all already correct.

  IDEMPOTENT: CHARINDEX-guarded.
  Run against: core (UAT/DEV/TEST).
==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (SELECT 1 FROM core.core.VisualisationQueries
            WHERE DataSetName = N'GrowyzeMenuEngineering' AND VisualizationType = N'CustomDataGrid'
              AND Status = N'LIVE' AND ExecutionQuery IS NOT NULL)
    THROW 51590, 'GrowyzeMenuEngineering now has ExecutionQuery populated; this script edits QueryTemplate. Editing the wrong column is a silent no-op -- re-check first.', 1;

DECLARE @Changes TABLE (Step NVARCHAR(80), RowsAffected INT);

/*------------------------------------------------------------------------------
  1. Re-alias branch 1. Classification 6 -> 2; category/qty/revenue/gp_pct
     each shift down one.
------------------------------------------------------------------------------*/
DECLARE @Realias TABLE (OldText NVARCHAR(200), NewText NVARCHAR(200), Step NVARCHAR(80));
INSERT INTO @Realias VALUES
    (N'p.category AS Column2,',        N'p.category AS Column3,',        N'category      2 -> 3'),
    (N'ROUND(p.qty, 2) AS Column3,',   N'ROUND(p.qty, 2) AS Column4,',   N'qty           3 -> 4'),
    (N'ROUND(p.revenue, 2) AS Column4,',N'ROUND(p.revenue, 2) AS Column5,',N'revenue       4 -> 5'),
    (N'ROUND(p.gp_pct, 1) AS Column5,',N'ROUND(p.gp_pct, 1) AS Column6,',N'gp_pct        5 -> 6'),
    (N'ELSE N''Dog'' END AS Column6,', N'ELSE N''Dog'' END AS Column2,', N'classification 6 -> 2');

DECLARE @o NVARCHAR(200), @n NVARCHAR(200), @s NVARCHAR(80);
DECLARE ra CURSOR LOCAL FAST_FORWARD FOR SELECT OldText, NewText, Step FROM @Realias;
OPEN ra; FETCH NEXT FROM ra INTO @o, @n, @s;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE core.core.VisualisationQueries
    SET QueryTemplate = REPLACE(QueryTemplate, @o, @n),
        ModifiedDate  = SYSUTCDATETIME(),
        ModifiedBy    = N'O5-Plan4-59'
    WHERE DataSetName = N'GrowyzeMenuEngineering'
      AND VisualizationType = N'CustomDataGrid'
      AND Status = N'LIVE'
      AND CHARINDEX(@o, QueryTemplate) > 0;
    INSERT INTO @Changes VALUES (@s, @@ROWCOUNT);
    FETCH NEXT FROM ra INTO @o, @n, @s;
END
CLOSE ra; DEALLOCATE ra;

/*------------------------------------------------------------------------------
  2. The header block, replaced whole. Six contiguous lines, unique in the query,
     so one REPLACE cannot half-apply.
------------------------------------------------------------------------------*/
DECLARE @HdrOld NVARCHAR(MAX) =
    N'    N''Menu Item''      AS [Label1], N''TEXT''    AS [Type1],' + CHAR(10) +
    N'    N''Category''       AS [Label2], N''TEXT''    AS [Type2],' + CHAR(10) +
    N'    N''Qty Sold''       AS [Label3], N''DECIMAL'' AS [Type3],' + CHAR(10) +
    N'    N''Revenue''        AS [Label4], N''DECIMAL'' AS [Type4],' + CHAR(10) +
    N'    N''GP %''           AS [Label5], N''DECIMAL'' AS [Type5],' + CHAR(10) +
    N'    N''Classification'' AS [Label6], N''TEXT''    AS [Type6],';

DECLARE @HdrNew NVARCHAR(MAX) =
    N'    N''Menu item''      AS [Label1], N''TEXT''     AS [Type1],' + CHAR(10) +
    N'    N''Classification'' AS [Label2], N''TEXT''     AS [Type2],' + CHAR(10) +
    N'    N''Category''       AS [Label3], N''TEXT''     AS [Type3],' + CHAR(10) +
    N'    N''Qty sold''       AS [Label4], N''DECIMAL''  AS [Type4],' + CHAR(10) +
    N'    N''Revenue''        AS [Label5], N''CURRENCY'' AS [Type5],' + CHAR(10) +
    N'    N''GP %''           AS [Label6], N''PERCENT''  AS [Type6],';

UPDATE core.core.VisualisationQueries
SET QueryTemplate = REPLACE(QueryTemplate, @HdrOld, @HdrNew),
    ModifiedDate  = SYSUTCDATETIME(),
    ModifiedBy    = N'O5-Plan4-59'
WHERE DataSetName = N'GrowyzeMenuEngineering'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE'
  AND CHARINDEX(@HdrOld, QueryTemplate) > 0;
INSERT INTO @Changes VALUES (N'header block', @@ROWCOUNT);

SELECT Step, RowsAffected FROM @Changes;


/*==============================================================================
  Assertions. Each states what makes it FAIL.

  Chk_DataAndHeaderAgree is the one that catches a half-applied edit -- the
  dangerous failure mode here, because a data query re-aliased without its header
  (or vice versa) renders plausible-looking columns under the WRONG headings, and
  nothing errors. It requires classification to be BOTH aliased Column2 in the
  data AND labelled Label2 in the header.
==============================================================================*/
SELECT
    DataSetName,
    CASE WHEN CHARINDEX(N'ELSE N''Dog'' END AS Column2,', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - classification is not aliased Column2' END AS Chk_DataRealiased,
    CASE WHEN CHARINDEX(N'N''Classification'' AS [Label2]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - Classification is not Label2' END AS Chk_HeaderReordered,
    CASE WHEN CHARINDEX(N'ELSE N''Dog'' END AS Column2,', QueryTemplate) > 0
              AND CHARINDEX(N'N''Classification'' AS [Label2]', QueryTemplate) > 0
         THEN 'PASS'
         ELSE 'FAIL - data and header disagree; columns would render under wrong headings' END AS Chk_DataAndHeaderAgree,
    CASE WHEN CHARINDEX(N'N''CURRENCY'' AS [Type5]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - Revenue not typed CURRENCY' END AS Chk_RevenueCurrency,
    CASE WHEN CHARINDEX(N'N''PERCENT''  AS [Type6]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - GP % not typed PERCENT' END AS Chk_GpPercent,
    /* The sentinel branch must be untouched -- its alignment is positional. */
    CASE WHEN CHARINDEX(N'N''No cost data''', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - O35 no-cost sentinel row was lost' END AS Chk_SentinelIntact,
    /* No alias may appear twice, which is what a partial re-alias would leave. */
    CASE WHEN (LEN(QueryTemplate) - LEN(REPLACE(QueryTemplate, N'AS Column2,', N''))) / 11 = 1
         THEN 'PASS' ELSE 'FAIL - Column2 aliased more than once (partial re-alias)' END AS Chk_NoDuplicateAlias
FROM core.core.VisualisationQueries
WHERE DataSetName = N'GrowyzeMenuEngineering'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE';
