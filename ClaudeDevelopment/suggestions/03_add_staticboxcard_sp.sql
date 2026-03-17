-- =====================================================
-- Add StaticBoxCard SP to DeploymentObjects
-- Matches UAT-deployed version (ExecutionOrder 65)
-- =====================================================

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'StaticBoxCard', N'PROCEDURE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        CreationScript = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StaticBoxCard]
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
    AND VisualizationType = ''StaticBoxCard''
    AND Status = ''LIVE'';

    IF @SQL IS NULL
    BEGIN
        RAISERROR(''DataSet "%s" not found for StaticBox or inactive'', 16, 1, @DataSet);
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
        SET @ErrorMsg = ''Error executing StaticBox for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;',
        ExecutionOrder = 65,
        Category = N'Visualisation Procedures',
        IsActive = 1,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, CreationScript, ExecutionOrder, Category, IsActive, CreatedDate, ModifiedDate)
    VALUES (N'StaticBoxCard', N'PROCEDURE',
        N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StaticBoxCard]
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
    AND VisualizationType = ''StaticBoxCard''
    AND Status = ''LIVE'';

    IF @SQL IS NULL
    BEGIN
        RAISERROR(''DataSet "%s" not found for StaticBox or inactive'', 16, 1, @DataSet);
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
        SET @ErrorMsg = ''Error executing StaticBox for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;',
        65, N'Visualisation Procedures', 1, GETDATE(), GETDATE());
