-- =============================================================================
-- TEST FIX: MultiLineNullValueTest QueryTemplate
--
-- Bug:  The data result set declared `NULL AS Stack`. The MultiLineChartCard
--       front-end requires a non-null Stack value (every working query in UAT
--       uses a literal like 'total' or a column expression). NULL crashes the
--       card with HTTP 500.
--
-- Fix:  Replace `NULL AS Stack` with `N'total' AS Stack` in the QueryTemplate.
--       The header still returns NULL AS Value — that part is the actual
--       XMSE-1014 repro and stays as-is.
--
-- Idempotent: Yes (MERGE update on the existing row).
-- =============================================================================

USE [core];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @NewTemplate NVARCHAR(MAX) = N'SELECT
    XAxisLabel,
    ROW_NUMBER() OVER (ORDER BY XAxisSort, LegendLabel) AS LabelSort,
    Value,
    ROW_NUMBER() OVER (ORDER BY Value) AS ValueSort,
    VisId,
    Curve,
    Stack,
    Area,
    StackOrder,
    ShowMark,
    LegendLabel
FROM (
    SELECT
        v.XAxisLabel, v.XAxisSort,
        v.VisId, v.LegendLabel, v.Value,
        N''linear''     AS Curve,
        N''total''      AS Stack,
        N''false''      AS Area,
        N''ascending''  AS StackOrder,
        N''true''       AS ShowMark
    FROM (VALUES
        (N''01 May 2026'', 1, N''Series A'', N''Series A'', 1240.50),
        (N''02 May 2026'', 2, N''Series A'', N''Series A'', 1380.10),
        (N''03 May 2026'', 3, N''Series A'', N''Series A'', 1175.80),
        (N''04 May 2026'', 4, N''Series A'', N''Series A'', 1420.65),
        (N''05 May 2026'', 5, N''Series A'', N''Series A'', 1305.20),
        (N''01 May 2026'', 1, N''Series B'', N''Series B'',  860.30),
        (N''02 May 2026'', 2, N''Series B'', N''Series B'',  945.70),
        (N''03 May 2026'', 3, N''Series B'', N''Series B'',  812.40),
        (N''04 May 2026'', 4, N''Series B'', N''Series B'', 1010.55),
        (N''05 May 2026'', 5, N''Series B'', N''Series B'',  920.85)
    ) v(XAxisLabel, XAxisSort, VisId, LegendLabel, Value)
) SUB
WHERE 1=1
@FilterClause;

SELECT
    N''Date'' AS XAxisLabel,
    N''Net Revenue'' AS YAxisLabel,
    N''NULL Value Repro (XMSE-1014)'' AS Title,
    N''Header Value = NULL — should hide the inline KPI but currently renders "0.00"'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    CAST(NULL AS DECIMAL(18,2)) AS Value;';

UPDATE [core].[core].[VisualisationQueries]
SET QueryTemplate  = @NewTemplate,
    ExecutionQuery = NULL,
    ModifiedDate   = GETDATE(),
    ModifiedBy     = N'XMSE-1014'
WHERE DataSetName = N'MultiLineNullValueTest'
  AND VisualizationType = N'MultiLineChartCard'
  AND Status = N'LIVE';

PRINT 'MultiLineNullValueTest updated. Rows affected: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-- Verification: confirm Stack is now 'total' not NULL
SELECT DataSetName,
       CASE WHEN CAST(QueryTemplate AS NVARCHAR(MAX)) LIKE N'%N''total''      AS Stack%'
            THEN 'OK — Stack literal is total'
            ELSE 'STILL BROKEN'
       END AS StackCheck,
       CASE WHEN CAST(QueryTemplate AS NVARCHAR(MAX)) LIKE N'%CAST(NULL AS DECIMAL(18,2)) AS Value%'
            THEN 'OK — header Value remains NULL (XMSE-1014 repro intact)'
            ELSE 'CHECK — header Value pattern not detected'
       END AS HeaderValueCheck
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName = N'MultiLineNullValueTest';
GO
