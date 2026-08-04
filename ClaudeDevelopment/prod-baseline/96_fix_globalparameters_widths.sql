-- ============================================================================
-- 96_fix_globalparameters_widths.sql - Align int_* GlobalParameters columns
-- ============================================================================
-- Root cause (found during the 2026-07-06 Prod deploy, step 26):
-- sp_CreateIntegrationTables creates GlobalParameters with narrower columns
-- than the UAT tables actually have (UAT tables were widened at some point,
-- the SP was never updated):
--
--   Column          SP creates   UAT actual
--   ParameterKey    100          200
--   ParameterValue  4000         MAX   (Growyze DL_DISHES DDL > 4000 chars
--                                        -> Msg 2628 truncation on Prod)
--   Category        50           100
--   Description     500          1000
--   CreatedBy       100          200
--   ModifiedBy      100          200
--
-- This script widens GlobalParameters in EVERY int_* schema of the connected
-- core database to the UAT-actual shape. Widening only - no data change, safe
-- on any environment. Idempotent: skips columns already at target size.
-- Also run on UAT (int_ncraloha001.ParameterValue is still 4000 there) so all
-- environments end up identical. The companion SP fix lives in
-- 5_CreateIntegrationTables.sql (ParameterValue -> NVARCHAR(MAX) etc.).
-- Run against the CORE database.
-- ============================================================================

SET NOCOUNT ON;

DECLARE @targets TABLE (col SYSNAME, decl NVARCHAR(50), target_len INT, is_nullable BIT);
INSERT INTO @targets VALUES
    (N'ParameterKey',   N'NVARCHAR(200)',  400, 0),
    (N'ParameterValue', N'NVARCHAR(MAX)',   -1, 1),
    (N'Category',       N'NVARCHAR(100)',  200, 1),
    (N'Description',    N'NVARCHAR(1000)', 2000, 1),
    (N'CreatedBy',      N'NVARCHAR(200)',  400, 0),
    (N'ModifiedBy',     N'NVARCHAR(200)',  400, 1);

DECLARE @SchemaName SYSNAME, @Col SYSNAME, @Decl NVARCHAR(50), @TargetLen INT, @Nullable BIT, @CurLen INT;
DECLARE @sql NVARCHAR(MAX);

DECLARE fix_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT s.name, t.col, t.decl, t.target_len, t.is_nullable, c.max_length
    FROM sys.schemas s
    JOIN sys.tables tb ON tb.schema_id = s.schema_id AND tb.name = N'GlobalParameters'
    JOIN sys.columns c ON c.object_id = tb.object_id
    JOIN @targets t ON t.col = c.name
    WHERE s.name LIKE N'int[_]%'
      AND c.max_length <> t.target_len
      AND c.max_length <> -1               -- never shrink an existing MAX
    ORDER BY s.name, t.col;

OPEN fix_cursor;
FETCH NEXT FROM fix_cursor INTO @SchemaName, @Col, @Decl, @TargetLen, @Nullable, @CurLen;
IF @@FETCH_STATUS <> 0 PRINT 'All int_* GlobalParameters columns already at target widths - nothing to do.';
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'ALTER TABLE ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters] ALTER COLUMN '
             + QUOTENAME(@Col) + N' ' + @Decl + CASE WHEN @Nullable = 1 THEN N' NULL' ELSE N' NOT NULL' END + N';';
    PRINT @SchemaName + N'.' + @Col + N': ' + CAST(@CurLen AS NVARCHAR(10)) + N' bytes -> ' + @Decl;
    EXEC sp_executesql @sql;
    FETCH NEXT FROM fix_cursor INTO @SchemaName, @Col, @Decl, @TargetLen, @Nullable, @CurLen;
END
CLOSE fix_cursor; DEALLOCATE fix_cursor;

-- Post-state
SELECT s.name AS schema_name, c.name AS col, ty.name AS type_name,
       CASE c.max_length WHEN -1 THEN 'MAX' ELSE CAST(c.max_length / 2 AS VARCHAR(10)) END AS nchar_len
FROM sys.schemas s
JOIN sys.tables tb ON tb.schema_id = s.schema_id AND tb.name = N'GlobalParameters'
JOIN sys.columns c ON c.object_id = tb.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE s.name LIKE N'int[_]%' AND c.name IN (SELECT col FROM @targets)
ORDER BY s.name, c.name;
