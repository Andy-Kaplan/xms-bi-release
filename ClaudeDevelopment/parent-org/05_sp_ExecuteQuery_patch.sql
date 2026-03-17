-- ============================================================================
-- 05_sp_ExecuteQuery_patch.sql
-- Patches sp_ExecuteQuery in core.core.DeploymentObjects to add a fallback
-- when sys.dm_exec_describe_first_result_set() returns no rows.
--
-- Problem: dm_exec_describe_first_result_set cannot describe result sets from
-- multi-statement batches (e.g. DECLARE @vars; ... EXEC sp_executesql ...).
-- When this happens, @TempTableSchema is empty and the CREATE TABLE fails.
--
-- Fix: After the existing DMF-based schema detection, add a fallback that
-- parses @ColumnMappingsJson to build the ##TempResults DDL. This only
-- activates when the DMF returned no rows (i.e. @TempTableSchema is empty).
--
-- Prerequisites: sp_ExecuteQuery must exist in DeploymentObjects.
-- Idempotent: safe to re-run (checks for existing fallback code).
-- ============================================================================

PRINT 'Patching sp_ExecuteQuery to add ColumnMappingsJson fallback for DMF empty results...';

IF NOT EXISTS (
    SELECT 1
    FROM [core].[DeploymentObjects]
    WHERE ObjectName = 'sp_ExecuteQuery'
      AND CAST(CreationScript AS NVARCHAR(MAX)) LIKE '%FallbackDDL%'
)
BEGIN
    -- Build search/replace strings with explicit CRLF to match stored code
    DECLARE @CRLF NCHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @SearchText NVARCHAR(MAX);
    DECLARE @ReplaceText NVARCHAR(MAX);

    SET @SearchText =
        N'@TempTableSchema OUTPUT;' + @CRLF + @CRLF +
        N'        IF @TableType != ''Staging''';

    SET @ReplaceText =
        N'@TempTableSchema OUTPUT;' + @CRLF + @CRLF +
        N'        -- Fallback: if dm_exec_describe_first_result_set returned no rows,' + @CRLF +
        N'        -- build temp table schema from @ColumnMappingsJson' + @CRLF +
        N'        IF @TempTableSchema IS NULL OR @TempTableSchema = ''''' + @CRLF +
        N'        BEGIN' + @CRLF +
        N'            DECLARE @FallbackDDL NVARCHAR(MAX);' + @CRLF +
        N'            SELECT @FallbackDDL = STRING_AGG(' + @CRLF +
        N'                QUOTENAME(COALESCE(j.query_column, j.col_name)) + '' '' + j.target_data_type + '' NULL'',' + @CRLF +
        N'                '', ''' + @CRLF +
        N'            )' + @CRLF +
        N'            FROM OPENJSON(@ColumnMappingsJson)' + @CRLF +
        N'            WITH (' + @CRLF +
        N'                query_column NVARCHAR(255) ''$.query_column'',' + @CRLF +
        N'                col_name NVARCHAR(255) ''$.name'',' + @CRLF +
        N'                target_data_type NVARCHAR(255) ''$.target_data_type''' + @CRLF +
        N'            ) j;' + @CRLF + @CRLF +
        N'            SET @TempTableSchema = @FallbackDDL;' + @CRLF +
        N'            PRINT ''dm_exec_describe_first_result_set returned no rows - using ColumnMappingsJson fallback'';' + @CRLF +
        N'        END;' + @CRLF + @CRLF +
        N'        IF @TableType != ''Staging''';

    UPDATE [core].[DeploymentObjects]
    SET CreationScript = CAST(
        REPLACE(
            CAST(CreationScript AS NVARCHAR(MAX)),
            @SearchText,
            @ReplaceText
        ) AS TEXT)
    WHERE ObjectName = 'sp_ExecuteQuery';

    -- Verify the patch took effect
    IF EXISTS (
        SELECT 1
        FROM [core].[DeploymentObjects]
        WHERE ObjectName = 'sp_ExecuteQuery'
          AND CAST(CreationScript AS NVARCHAR(MAX)) LIKE '%FallbackDDL%'
    )
        PRINT 'sp_ExecuteQuery patched successfully: ColumnMappingsJson fallback added.';
    ELSE
        PRINT 'WARNING: REPLACE did not match - patch NOT applied. Check whitespace in stored CreationScript.';
END
ELSE
BEGIN
    PRINT 'sp_ExecuteQuery already contains FallbackDDL logic - no patch needed.';
END
