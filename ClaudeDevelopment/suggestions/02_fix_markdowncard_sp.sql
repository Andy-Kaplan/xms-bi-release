-- =====================================================
-- Fix MarkdownCard SP: correct VisualizationType reference
-- Bug: dev script references 'BarChartCard' instead of 'MarkdownCard'
-- This matches the UAT-deployed version.
-- =====================================================

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'MarkdownCard', N'PROCEDURE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        CreationScript = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MarkdownCard]
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
END;',
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, CreationScript, ExecutionOrder, Category, IsActive, CreatedDate, ModifiedDate)
    VALUES (N'MarkdownCard', N'PROCEDURE',
        N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MarkdownCard]
    @StartDate DATE = NULL, @EndDate DATE = NULL, @LocationList NVARCHAR(MAX) = NULL,
    @DataSet NVARCHAR(100), @Filters NVARCHAR(MAX) = NULL
AS BEGIN SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX), @ErrorMsg NVARCHAR(500), @ParameterMappings NVARCHAR(MAX),
            @FilterDefinitions NVARCHAR(MAX), @FilterClause NVARCHAR(MAX);
    SELECT @SQL = COALESCE(ExecutionQuery, QueryTemplate), @ParameterMappings = ParameterMappings,
           @FilterDefinitions = FilterDefinitions
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet AND VisualizationType = ''MarkdownCard'' AND Status = ''LIVE'';
    IF @SQL IS NULL BEGIN RAISERROR(''DataSet "%s" not found for Markdown or inactive'', 16, 1, @DataSet); RETURN; END
    BEGIN TRY
        EXEC {SCHEMA}.[BuildDynamicWhereClause] @StartDate=@StartDate, @EndDate=@EndDate,
            @LocationList=@LocationList, @Filters=@Filters, @ParameterMappings=@ParameterMappings,
            @FilterDefinitions=@FilterDefinitions, @FilterClause=@FilterClause OUTPUT;
        SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause); EXEC sp_executesql @SQL;
    END TRY BEGIN CATCH
        SET @ErrorMsg = ''Error executing Markdown for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH END;',
        64, N'Visualisation Procedures', 1, GETDATE(), GETDATE());
