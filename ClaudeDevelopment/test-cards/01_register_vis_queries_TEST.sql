-- =============================================================================
-- TEST: Register front-end test visualisation queries (XMSE-1030, XMSE-1014, XMSE-948)
-- Target environment: BI MI TEST -> client database `20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4` (Three Rocks Cafe)
-- Target table:       core.core.VisualisationQueries
-- Idempotent:         Yes (MERGE on natural key DataSetName + VisualizationType + Status='LIVE')
--
-- Six datasets are registered:
--   XMSE-1030  HorizontalStackedBarTest    StackedBarChartCard      (sample data, no DV dependencies)
--   XMSE-1014  MultiLineNullValueTest      MultiLineChartCard       (header has NULL Value to repro the "0.00" bug)
--   XMSE-948   MarkdownTestEmpty           MarkdownCard             (returns 0 rows -> card should hide)
--   XMSE-948   MarkdownTestVisible         MarkdownCard             (returns 1 row  -> card should be visible)
--   XMSE-948   StaticBoxTestEmpty          StaticBoxCard            (returns 0 rows -> card should hide)
--   XMSE-948   StaticBoxTestVisible        StaticBoxCard            (returns 1 row  -> card should be visible)
--
-- Run from the core control DB on TEST. The queries themselves are self-contained
-- (use VALUES constructors) so they do not depend on Data Vault data being loaded.
-- =============================================================================

USE [core];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ---------------------------------------------------------------------------
-- 1. XMSE-1030 -- HorizontalStackedBarTest (StackedBarChartCard)
-- ---------------------------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'HorizontalStackedBarTest', N'StackedBarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
   ON tgt.DataSetName       = src.DataSetName
  AND tgt.VisualizationType = src.VisualizationType
  AND tgt.Status            = src.Status
WHEN MATCHED THEN UPDATE SET
     QueryTemplate = N'SELECT
    XAxisLabel,
    ROW_NUMBER() OVER (ORDER BY XAxisSort, VisIdSort) AS LabelSort,
    Value,
    ROW_NUMBER() OVER (ORDER BY Value) AS ValueSort,
    VisId,
    Stack
FROM (
    SELECT
        v.XAxisLabel,
        v.XAxisSort,
        v.VisId,
        v.VisIdSort,
        v.Value,
        N''A'' AS Stack
    FROM (VALUES
        (N''Camden Road'',     1, N''Food'',    1, 12450.50),
        (N''Camden Road'',     1, N''Drink'',   2,  8920.25),
        (N''Camden Road'',     1, N''Snacks'',  3,  3210.00),
        (N''Camden Road'',     1, N''Other'',   4,   890.75),
        (N''Shoreditch'',      2, N''Food'',    1, 15820.40),
        (N''Shoreditch'',      2, N''Drink'',   2, 11240.80),
        (N''Shoreditch'',      2, N''Snacks'',  3,  4180.00),
        (N''Shoreditch'',      2, N''Other'',   4,  1240.30),
        (N''King''''s Cross'', 3, N''Food'',    1,  9870.10),
        (N''King''''s Cross'', 3, N''Drink'',   2,  7150.40),
        (N''King''''s Cross'', 3, N''Snacks'',  3,  2640.50),
        (N''King''''s Cross'', 3, N''Other'',   4,   720.00),
        (N''Brick Lane'',      4, N''Food'',    1, 14210.95),
        (N''Brick Lane'',      4, N''Drink'',   2, 10330.60),
        (N''Brick Lane'',      4, N''Snacks'',  3,  3850.20),
        (N''Brick Lane'',      4, N''Other'',   4,  1015.50),
        (N''Spitalfields'',    5, N''Food'',    1, 11540.30),
        (N''Spitalfields'',    5, N''Drink'',   2,  8460.75),
        (N''Spitalfields'',    5, N''Snacks'',  3,  3015.40),
        (N''Spitalfields'',    5, N''Other'',   4,   815.20)
    ) v(XAxisLabel, XAxisSort, VisId, VisIdSort, Value)
) SUB
WHERE 1=1
@FilterClause;

SELECT
    N''Store'' AS XAxisLabel,
    N''Net Revenue'' AS YAxisLabel,
    N''Revenue by Store, Stacked by Category (XMSE-1030)'' AS Title,
    N''Sample data for the new horizontal stacked bar component'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    CAST(99514.93 AS DECIMAL(18,2)) AS Value;'
    ,ParameterMappings   = N'{}'
    ,FilterDefinitions   = N'{}'
    ,Description         = N'XMSE-1030 sample data for horizontal stacked bar chart component. Self-contained VALUES constructor — five stores stacked by four product categories. No DV dependency.'
    ,ModifiedDate        = GETDATE()
    ,ModifiedBy          = N'XMSE-1030'
    ,OutputDefinitions   = NULL
    ,ExecutionQuery      = NULL
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES
    (src.DataSetName, src.VisualizationType, 1, src.Status,
     N'SELECT
    XAxisLabel,
    ROW_NUMBER() OVER (ORDER BY XAxisSort, VisIdSort) AS LabelSort,
    Value,
    ROW_NUMBER() OVER (ORDER BY Value) AS ValueSort,
    VisId,
    Stack
FROM (
    SELECT
        v.XAxisLabel,
        v.XAxisSort,
        v.VisId,
        v.VisIdSort,
        v.Value,
        N''A'' AS Stack
    FROM (VALUES
        (N''Camden Road'',     1, N''Food'',    1, 12450.50),
        (N''Camden Road'',     1, N''Drink'',   2,  8920.25),
        (N''Camden Road'',     1, N''Snacks'',  3,  3210.00),
        (N''Camden Road'',     1, N''Other'',   4,   890.75),
        (N''Shoreditch'',      2, N''Food'',    1, 15820.40),
        (N''Shoreditch'',      2, N''Drink'',   2, 11240.80),
        (N''Shoreditch'',      2, N''Snacks'',  3,  4180.00),
        (N''Shoreditch'',      2, N''Other'',   4,  1240.30),
        (N''King''''s Cross'', 3, N''Food'',    1,  9870.10),
        (N''King''''s Cross'', 3, N''Drink'',   2,  7150.40),
        (N''King''''s Cross'', 3, N''Snacks'',  3,  2640.50),
        (N''King''''s Cross'', 3, N''Other'',   4,   720.00),
        (N''Brick Lane'',      4, N''Food'',    1, 14210.95),
        (N''Brick Lane'',      4, N''Drink'',   2, 10330.60),
        (N''Brick Lane'',      4, N''Snacks'',  3,  3850.20),
        (N''Brick Lane'',      4, N''Other'',   4,  1015.50),
        (N''Spitalfields'',    5, N''Food'',    1, 11540.30),
        (N''Spitalfields'',    5, N''Drink'',   2,  8460.75),
        (N''Spitalfields'',    5, N''Snacks'',  3,  3015.40),
        (N''Spitalfields'',    5, N''Other'',   4,   815.20)
    ) v(XAxisLabel, XAxisSort, VisId, VisIdSort, Value)
) SUB
WHERE 1=1
@FilterClause;

SELECT
    N''Store'' AS XAxisLabel,
    N''Net Revenue'' AS YAxisLabel,
    N''Revenue by Store, Stacked by Category (XMSE-1030)'' AS Title,
    N''Sample data for the new horizontal stacked bar component'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    CAST(99514.93 AS DECIMAL(18,2)) AS Value;'
     ,N'{}', N'{}'
     ,N'XMSE-1030 sample data for horizontal stacked bar chart component. Self-contained VALUES constructor — five stores stacked by four product categories. No DV dependency.'
     ,GETDATE(), GETDATE(), N'XMSE-1030', N'XMSE-1030', NULL, NULL);
GO

-- ---------------------------------------------------------------------------
-- 2. XMSE-1014 -- MultiLineNullValueTest (MultiLineChartCard, header Value = NULL)
-- ---------------------------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MultiLineNullValueTest', N'MultiLineChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
   ON tgt.DataSetName       = src.DataSetName
  AND tgt.VisualizationType = src.VisualizationType
  AND tgt.Status            = src.Status
WHEN MATCHED THEN UPDATE SET
     QueryTemplate = N'SELECT
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
    CAST(NULL AS DECIMAL(18,2)) AS Value;'
    ,ParameterMappings = N'{}'
    ,FilterDefinitions = N'{}'
    ,Description       = N'XMSE-1014 reproduction. Header SELECT returns NULL AS Value. MultiLineChartCard front-end currently renders this as "0.00"; it should hide the inline KPI figure to match StackedBarChartCard behaviour.'
    ,ModifiedDate      = GETDATE()
    ,ModifiedBy        = N'XMSE-1014'
    ,OutputDefinitions = NULL
    ,ExecutionQuery    = NULL
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES
    (src.DataSetName, src.VisualizationType, 1, src.Status,
     N'SELECT
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
    CAST(NULL AS DECIMAL(18,2)) AS Value;'
     ,N'{}', N'{}'
     ,N'XMSE-1014 reproduction. Header SELECT returns NULL AS Value. MultiLineChartCard front-end currently renders this as "0.00"; it should hide the inline KPI figure to match StackedBarChartCard behaviour.'
     ,GETDATE(), GETDATE(), N'XMSE-1014', N'XMSE-1014', NULL, NULL);
GO

-- ---------------------------------------------------------------------------
-- 3. XMSE-948 -- MarkdownTestEmpty (MarkdownCard, returns 0 rows)
-- ---------------------------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MarkdownTestEmpty', N'MarkdownCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
   ON tgt.DataSetName       = src.DataSetName
  AND tgt.VisualizationType = src.VisualizationType
  AND tgt.Status            = src.Status
WHEN MATCHED THEN UPDATE SET
     QueryTemplate = N'SELECT TOP 0 CAST(N'''' AS NVARCHAR(MAX)) AS markdown
FROM (VALUES (1)) v(x)
WHERE 1=1
@FilterClause;'
    ,ParameterMappings = N'{}'
    ,FilterDefinitions = N'{}'
    ,Description       = N'XMSE-948 hide-on-empty test. MarkdownCard query that always returns 0 rows. Front-end must HIDE the entire card (no empty container, no layout gap).'
    ,ModifiedDate      = GETDATE()
    ,ModifiedBy        = N'XMSE-948'
    ,OutputDefinitions = NULL
    ,ExecutionQuery    = NULL
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES
    (src.DataSetName, src.VisualizationType, 1, src.Status,
     N'SELECT TOP 0 CAST(N'''' AS NVARCHAR(MAX)) AS markdown
FROM (VALUES (1)) v(x)
WHERE 1=1
@FilterClause;'
     ,N'{}', N'{}'
     ,N'XMSE-948 hide-on-empty test. MarkdownCard query that always returns 0 rows. Front-end must HIDE the entire card (no empty container, no layout gap).'
     ,GETDATE(), GETDATE(), N'XMSE-948', N'XMSE-948', NULL, NULL);
GO

-- ---------------------------------------------------------------------------
-- 4. XMSE-948 -- MarkdownTestVisible (MarkdownCard, returns 1 row)
-- ---------------------------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MarkdownTestVisible', N'MarkdownCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
   ON tgt.DataSetName       = src.DataSetName
  AND tgt.VisualizationType = src.VisualizationType
  AND tgt.Status            = src.Status
WHEN MATCHED THEN UPDATE SET
     QueryTemplate = N'SELECT
    CAST(
        N''### Markdown Card — Visible Test'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N''This card **must be visible** because the query returns one row.'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N''- Bullet item one'' + CHAR(13) + CHAR(10) +
        N''- Bullet item two'' + CHAR(13) + CHAR(10) +
        N''- Bullet item three'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N''> When this query starts returning zero rows the card should disappear (XMSE-948).''
        AS NVARCHAR(MAX)) AS markdown
WHERE 1=1
@FilterClause;'
    ,ParameterMappings = N'{}'
    ,FilterDefinitions = N'{}'
    ,Description       = N'XMSE-948 hide-on-empty test (paired with MarkdownTestEmpty). Always returns one markdown row so Craig can confirm the card is visible when it has content.'
    ,ModifiedDate      = GETDATE()
    ,ModifiedBy        = N'XMSE-948'
    ,OutputDefinitions = NULL
    ,ExecutionQuery    = NULL
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES
    (src.DataSetName, src.VisualizationType, 1, src.Status,
     N'SELECT
    CAST(
        N''### Markdown Card — Visible Test'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N''This card **must be visible** because the query returns one row.'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N''- Bullet item one'' + CHAR(13) + CHAR(10) +
        N''- Bullet item two'' + CHAR(13) + CHAR(10) +
        N''- Bullet item three'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
        N''> When this query starts returning zero rows the card should disappear (XMSE-948).''
        AS NVARCHAR(MAX)) AS markdown
WHERE 1=1
@FilterClause;'
     ,N'{}', N'{}'
     ,N'XMSE-948 hide-on-empty test (paired with MarkdownTestEmpty). Always returns one markdown row so Craig can confirm the card is visible when it has content.'
     ,GETDATE(), GETDATE(), N'XMSE-948', N'XMSE-948', NULL, NULL);
GO

-- ---------------------------------------------------------------------------
-- 5. XMSE-948 -- StaticBoxTestEmpty (StaticBoxCard, returns 0 rows)
-- ---------------------------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'StaticBoxTestEmpty', N'StaticBoxCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
   ON tgt.DataSetName       = src.DataSetName
  AND tgt.VisualizationType = src.VisualizationType
  AND tgt.Status            = src.Status
WHEN MATCHED THEN UPDATE SET
     QueryTemplate = N'SELECT TOP 0
    CAST(N''INFO'' AS NVARCHAR(50))   AS severity,
    CAST(N''''     AS NVARCHAR(MAX))  AS text,
    CAST(NULL     AS NVARCHAR(256))  AS title,
    CAST(N''True'' AS NVARCHAR(10))   AS dismissable
FROM (VALUES (1)) v(x)
WHERE 1=1
@FilterClause;'
    ,ParameterMappings = N'{}'
    ,FilterDefinitions = N'{}'
    ,Description       = N'XMSE-948 hide-on-empty test. StaticBoxCard query that always returns 0 rows. Front-end must HIDE the entire banner.'
    ,ModifiedDate      = GETDATE()
    ,ModifiedBy        = N'XMSE-948'
    ,OutputDefinitions = NULL
    ,ExecutionQuery    = NULL
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES
    (src.DataSetName, src.VisualizationType, 1, src.Status,
     N'SELECT TOP 0
    CAST(N''INFO'' AS NVARCHAR(50))   AS severity,
    CAST(N''''     AS NVARCHAR(MAX))  AS text,
    CAST(NULL     AS NVARCHAR(256))  AS title,
    CAST(N''True'' AS NVARCHAR(10))   AS dismissable
FROM (VALUES (1)) v(x)
WHERE 1=1
@FilterClause;'
     ,N'{}', N'{}'
     ,N'XMSE-948 hide-on-empty test. StaticBoxCard query that always returns 0 rows. Front-end must HIDE the entire banner.'
     ,GETDATE(), GETDATE(), N'XMSE-948', N'XMSE-948', NULL, NULL);
GO

-- ---------------------------------------------------------------------------
-- 6. XMSE-948 -- StaticBoxTestVisible (StaticBoxCard, returns 1 row)
-- ---------------------------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'StaticBoxTestVisible', N'StaticBoxCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
   ON tgt.DataSetName       = src.DataSetName
  AND tgt.VisualizationType = src.VisualizationType
  AND tgt.Status            = src.Status
WHEN MATCHED THEN UPDATE SET
     QueryTemplate = N'SELECT
    N''INFO'' AS severity,
    N''This banner should be visible. When the query starts returning zero rows, the entire StaticBoxCard must hide (XMSE-948).'' AS text,
    N''Visible Banner Test'' AS title,
    N''True'' AS dismissable
WHERE 1=1
@FilterClause;'
    ,ParameterMappings = N'{}'
    ,FilterDefinitions = N'{}'
    ,Description       = N'XMSE-948 hide-on-empty test (paired with StaticBoxTestEmpty). Always returns one row so Craig can confirm the banner renders correctly when populated.'
    ,ModifiedDate      = GETDATE()
    ,ModifiedBy        = N'XMSE-948'
    ,OutputDefinitions = NULL
    ,ExecutionQuery    = NULL
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES
    (src.DataSetName, src.VisualizationType, 1, src.Status,
     N'SELECT
    N''INFO'' AS severity,
    N''This banner should be visible. When the query starts returning zero rows, the entire StaticBoxCard must hide (XMSE-948).'' AS text,
    N''Visible Banner Test'' AS title,
    N''True'' AS dismissable
WHERE 1=1
@FilterClause;'
     ,N'{}', N'{}'
     ,N'XMSE-948 hide-on-empty test (paired with StaticBoxTestEmpty). Always returns one row so Craig can confirm the banner renders correctly when populated.'
     ,GETDATE(), GETDATE(), N'XMSE-948', N'XMSE-948', NULL, NULL);
GO

-- ---------------------------------------------------------------------------
-- Verification
-- ---------------------------------------------------------------------------
SELECT DataSetName, VisualizationType, Version, Status, ModifiedBy, ModifiedDate
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName IN (
        N'HorizontalStackedBarTest',
        N'MultiLineNullValueTest',
        N'MarkdownTestEmpty',
        N'MarkdownTestVisible',
        N'StaticBoxTestEmpty',
        N'StaticBoxTestVisible')
ORDER BY DataSetName, VisualizationType;
GO
