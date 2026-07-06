-- =============================================================================
-- TEST FIX: core.MarkdownCard stored procedure
--
-- Bug:  The MarkdownCard SP on TEST filters core.core.VisualisationQueries by
--       VisualizationType = 'BarChartCard' instead of 'MarkdownCard', and the
--       error messages reference 'BarChartCard' / 'CustomDataGrid'. Result:
--       the SP can NEVER find a MarkdownCard query, so every front-end call
--       raises an error and the API returns HTTP 500.
--
-- Source of bug: core.core.DeploymentObjects on TEST (the master) has the
--                buggy CreationScript stored. Every client DB has the buggy
--                SP because they were all deployed from this row. UAT has the
--                correct version, so this is TEST-specific drift.
--
-- Fix:  (1) Update the master CreationScript in core.core.DeploymentObjects.
--       (2) ALTER the SP in each client DB that has it.
--
-- This script patches the master + the Three Rocks Cafe TEST DB directly so
-- Craig can unblock XMSE-948 testing. Other client DBs can be patched on the
-- next sp_DeployObjects run, or by extending the cursor below.
--
-- Idempotent: Yes (CREATE OR ALTER + UPDATE).
-- =============================================================================

USE [core];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ---------------------------------------------------------------------------
-- 1. Update the master CreationScript in core.core.DeploymentObjects.
-- ---------------------------------------------------------------------------
DECLARE @CorrectScript NVARCHAR(MAX) = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MarkdownCard]
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @LocationList NVARCHAR(MAX) = NULL,
    @DataSet NVARCHAR(100),
    @Filters NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ErrorMsg NVARCHAR(500);
    DECLARE @ParameterMappings NVARCHAR(MAX);
    DECLARE @FilterDefinitions NVARCHAR(MAX);
    DECLARE @FilterClause NVARCHAR(MAX);

    SELECT
        @SQL = COALESCE(ExecutionQuery, QueryTemplate),
        @ParameterMappings = ParameterMappings,
        @FilterDefinitions = FilterDefinitions
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet
    AND VisualizationType = ''MarkdownCard''
    AND Status = ''LIVE'';

    IF @SQL IS NULL
    BEGIN
        RAISERROR(''DataSet "%s" not found for Markdown or inactive'', 16, 1, @DataSet);
        RETURN;
    END

    BEGIN TRY
        EXEC {SCHEMA}.[BuildDynamicWhereClause]
            @StartDate = @StartDate,
            @EndDate = @EndDate,
            @LocationList = @LocationList,
            @Filters = @Filters,
            @ParameterMappings = @ParameterMappings,
            @FilterDefinitions = @FilterDefinitions,
            @FilterClause = @FilterClause OUTPUT;

        SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);
        EXEC sp_executesql @SQL;

    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ''Error executing Markdown for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;';

UPDATE [core].[core].[DeploymentObjects]
SET CreationScript = @CorrectScript,
    ModifiedDate   = GETDATE()
WHERE ObjectName = N'MarkdownCard'
  AND ObjectType = N'PROCEDURE';

PRINT 'Master CreationScript for MarkdownCard updated. Rows affected: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-- ---------------------------------------------------------------------------
-- 2. Deploy the corrected SP into the Three Rocks Cafe TEST client DB.
--    {SCHEMA} is replaced with 'core' (the deployment convention).
-- ---------------------------------------------------------------------------
EXEC [20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4].sys.sp_executesql N'
CREATE OR ALTER PROCEDURE [core].[MarkdownCard]
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @LocationList NVARCHAR(MAX) = NULL,
    @DataSet NVARCHAR(100),
    @Filters NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ErrorMsg NVARCHAR(500);
    DECLARE @ParameterMappings NVARCHAR(MAX);
    DECLARE @FilterDefinitions NVARCHAR(MAX);
    DECLARE @FilterClause NVARCHAR(MAX);

    SELECT
        @SQL = COALESCE(ExecutionQuery, QueryTemplate),
        @ParameterMappings = ParameterMappings,
        @FilterDefinitions = FilterDefinitions
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet
    AND VisualizationType = ''MarkdownCard''
    AND Status = ''LIVE'';

    IF @SQL IS NULL
    BEGIN
        RAISERROR(''DataSet "%s" not found for Markdown or inactive'', 16, 1, @DataSet);
        RETURN;
    END

    BEGIN TRY
        EXEC [core].[BuildDynamicWhereClause]
            @StartDate = @StartDate,
            @EndDate = @EndDate,
            @LocationList = @LocationList,
            @Filters = @Filters,
            @ParameterMappings = @ParameterMappings,
            @FilterDefinitions = @FilterDefinitions,
            @FilterClause = @FilterClause OUTPUT;

        SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);
        EXEC sp_executesql @SQL;

    END TRY
    BEGIN CATCH
        SET @ErrorMsg = ''Error executing Markdown for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;
';
GO

-- ---------------------------------------------------------------------------
-- 3. Verification
-- ---------------------------------------------------------------------------
SELECT 'Master' AS Layer, ObjectName,
       SUBSTRING(CAST(CreationScript AS NVARCHAR(MAX)),
                 CHARINDEX('VisualizationType', CAST(CreationScript AS NVARCHAR(MAX))),
                 80) AS VisTypeFilter
FROM [core].[core].[DeploymentObjects]
WHERE ObjectName = N'MarkdownCard';

SELECT 'Three Rocks Cafe' AS Layer, p.name AS ProcName,
       SUBSTRING(m.definition,
                 CHARINDEX('VisualizationType', m.definition),
                 80) AS VisTypeFilter
FROM [20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4].sys.procedures p
JOIN [20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4].sys.sql_modules m ON m.object_id = p.object_id
WHERE p.name = 'MarkdownCard';
GO
