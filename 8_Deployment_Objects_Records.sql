-- ============================================
-- Deployment Objects Export
-- Generated: 2026-02-07 13:34:06
-- Object Count: 46
-- ============================================

-- Note: These INSERT statements will create deployment objects
-- If an object with the same name already exists, you may need to
-- delete it first or modify the ObjectName to avoid conflicts.

-- ============================================
-- Object: GlobalParameters
-- Type: TABLE
-- Order: 10
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'GlobalParameters',
    N'TABLE',
    10,
    N'Core Tables',
    N'Main table for storing global parameters',
    N'CREATE TABLE {SCHEMA}.[GlobalParameters] (
        [ParameterID] int IDENTITY(1,1) NOT NULL,
        [ParameterKey] nvarchar(100) NOT NULL,
        [ParameterValue] nvarchar(4000) NULL,
        [DataType] varchar(20) NOT NULL DEFAULT ''STRING'',
        [Category] nvarchar(50) NULL,
        [Description] nvarchar(500) NULL,
        [IsActive] bit NOT NULL DEFAULT 1,
        [CreatedBy] nvarchar(100) NOT NULL DEFAULT SYSTEM_USER,
        [CreatedDate] datetime2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] nvarchar(100) NULL,
        [ModifiedDate] datetime2 NULL,
        [Version] int NOT NULL DEFAULT 1,
        
        CONSTRAINT [PK_{SCHEMA_NAME}_GlobalParameters] PRIMARY KEY CLUSTERED ([ParameterID]),
        CONSTRAINT [UK_{SCHEMA_NAME}_GlobalParameters_Key] UNIQUE NONCLUSTERED ([ParameterKey]),
        CONSTRAINT [CK_{SCHEMA_NAME}_GlobalParameters_DataType] CHECK ([DataType] IN (''STRING'', ''INT'', ''DECIMAL'', ''BOOLEAN'', ''DATE'', ''DATETIME'', ''JSON''))
    );',
    N'DROP TABLE {SCHEMA}.[GlobalParameters];',
    1,
    GETDATE()
);


-- ============================================
-- Object: GlobalParameters_Indexes
-- Type: INDEX
-- Order: 15
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'GlobalParameters_Indexes',
    N'INDEX',
    15,
    N'Indexes',
    N'Indexes for GlobalParameters table',
    N'CREATE NONCLUSTERED INDEX [IX_{SCHEMA_NAME}_GlobalParameters_Category] 
    ON {SCHEMA}.[GlobalParameters] ([Category]) 
    WHERE [IsActive] = 1;

    CREATE NONCLUSTERED INDEX [IX_{SCHEMA_NAME}_GlobalParameters_Active] 
    ON {SCHEMA}.[GlobalParameters] ([IsActive]) 
    INCLUDE ([ParameterKey], [ParameterValue], [DataType]);',
    N'DROP INDEX IF EXISTS [IX_{SCHEMA_NAME}_GlobalParameters_Category] ON {SCHEMA}.[GlobalParameters];
    DROP INDEX IF EXISTS [IX_{SCHEMA_NAME}_GlobalParameters_Active] ON {SCHEMA}.[GlobalParameters];',
    1,
    GETDATE()
);


-- ============================================
-- Object: BuildDynamicWhereClause
-- Type: PROCEDURE
-- Order: 20
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'BuildDynamicWhereClause',
    N'PROCEDURE',
    20,
    N'Visualization System',
    N'Builds dynamic filter clause with AND conditions based on parameter mappings and filter definitions',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[BuildDynamicWhereClause] 
        @StartDate DATE,
        @EndDate DATE,
        @LocationList NVARCHAR(MAX),
        @Filters NVARCHAR(MAX),
        @ParameterMappings NVARCHAR(MAX),
        @FilterDefinitions NVARCHAR(MAX),
        @FilterClause NVARCHAR(MAX) OUTPUT
    AS
    BEGIN
        SET NOCOUNT ON;
        
        DECLARE @StartDateColumn NVARCHAR(100);
        DECLARE @EndDateColumn NVARCHAR(100);
        DECLARE @LocationColumn NVARCHAR(100);
        
        SET @FilterClause = '''';
        
        -- Parse parameter mappings
        IF @ParameterMappings IS NOT NULL AND ISJSON(@ParameterMappings) = 1
        BEGIN
            SET @StartDateColumn = NULLIF(JSON_VALUE(@ParameterMappings, ''$.StartDate''),'''');
            SET @EndDateColumn = NULLIF(JSON_VALUE(@ParameterMappings, ''$.EndDate''),'''');
            SET @LocationColumn = NULLIF(JSON_VALUE(@ParameterMappings, ''$.LocationList''),'''');
        END
        
        -- Build date filters
        IF @StartDate IS NOT NULL AND @StartDateColumn IS NOT NULL
        BEGIN
            SET @FilterClause = @FilterClause + '' AND '' + @StartDateColumn + '' >= '''''' + CONVERT(NVARCHAR, @StartDate, 120) + '''''''';
        END
        
        IF @EndDate IS NOT NULL AND @EndDateColumn IS NOT NULL
        BEGIN
            SET @FilterClause = @FilterClause + '' AND '' + @EndDateColumn + '' <= '''''' + CONVERT(NVARCHAR, @EndDate, 120) + '''''''';
        END
        
        -- Build location filter (handle comma-separated list)
        IF @LocationList IS NOT NULL AND @LocationColumn IS NOT NULL
        BEGIN
            SET @FilterClause = @FilterClause + '' AND '' + @LocationColumn + '' IN ('' + @LocationList + '')'';
        END
        
        -- Build JSON filters
        IF @Filters IS NOT NULL AND @FilterDefinitions IS NOT NULL AND ISJSON(@Filters) = 1 AND ISJSON(@FilterDefinitions) = 1
        BEGIN
            DECLARE @FilterKey NVARCHAR(100);
            DECLARE @FilterColumn NVARCHAR(100);
            DECLARE @FilterType NVARCHAR(20);
            DECLARE @FilterDataType NVARCHAR(20);
            DECLARE @FilterValue NVARCHAR(MAX);
            
            -- Parse each filter from JSON
            DECLARE filter_cursor CURSOR FOR
            SELECT [key]
            FROM OPENJSON(@Filters);
            
            OPEN filter_cursor;
            FETCH NEXT FROM filter_cursor INTO @FilterKey;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Get filter definition
                SET @FilterColumn = NULLIF(JSON_VALUE(@FilterDefinitions, ''$.'' + @FilterKey + ''.column''),'''');
                SET @FilterType = NULLIF(JSON_VALUE(@FilterDefinitions, ''$.'' + @FilterKey + ''.type''),'''');
                SET @FilterDataType = NULLIF(JSON_VALUE(@FilterDefinitions, ''$.'' + @FilterKey + ''.dataType''),'''');
                
                IF @FilterColumn IS NOT NULL
                BEGIN
                    -- Get filter values and build appropriate format
                    SELECT @FilterValue = STRING_AGG(
                        CASE 
                            WHEN @FilterDataType IN (''INT'', ''DECIMAL'', ''NUMERIC'') THEN value
                            ELSE ''''''''+value +''''''''  -- Escape single quotes
                        END, 
                        '', ''
                    )
                    FROM OPENJSON(@Filters, ''$.'' + @FilterKey) WITH (value NVARCHAR(MAX) ''$'');
                    
                    -- Build filter clause based on type
                    IF @FilterType = ''IN'' AND @FilterValue IS NOT NULL
                    BEGIN
                        SET @FilterClause = @FilterClause + '' AND '' + @FilterColumn + '' IN ('' + @FilterValue + '')'';
                    END
                    -- Could add support for other filter types here (EQUALS, LIKE, etc.)
                END
                
                FETCH NEXT FROM filter_cursor INTO @FilterKey;
            END
            
            CLOSE filter_cursor;
            DEALLOCATE filter_cursor;
        END
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[BuildDynamicWhereClause];',
    1,
    GETDATE()
);


-- ============================================
-- Object: GetParameter
-- Type: FUNCTION
-- Order: 20
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'GetParameter',
    N'FUNCTION',
    20,
    N'Core Functions',
    N'Returns parameter value by key',
    N'CREATE FUNCTION {SCHEMA}.[GetParameter]
    (
        @ParameterKey nvarchar(100)
    )
    RETURNS nvarchar(4000)
    AS
    BEGIN
        DECLARE @Value nvarchar(4000);
        
        SELECT @Value = [ParameterValue]
        FROM {SCHEMA}.[GlobalParameters]
        WHERE [ParameterKey] = @ParameterKey 
          AND [IsActive] = 1;
        
        RETURN @Value;
    END;',
    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetParameter];',
    1,
    GETDATE()
);


-- ============================================
-- Object: GetParameterWithType
-- Type: FUNCTION
-- Order: 21
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'GetParameterWithType',
    N'FUNCTION',
    21,
    N'Core Functions',
    N'Returns parameter with metadata',
    N'CREATE FUNCTION {SCHEMA}.[GetParameterWithType]
    (
        @ParameterKey nvarchar(100)
    )
    RETURNS TABLE
    AS
    RETURN
    (
        SELECT 
            [ParameterValue],
            [DataType],
            [Category],
            [Description]
        FROM {SCHEMA}.[GlobalParameters]
        WHERE [ParameterKey] = @ParameterKey 
          AND [IsActive] = 1
    );',
    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetParameterWithType];',
    1,
    GETDATE()
);


-- ============================================
-- Object: GetParameterDataType
-- Type: FUNCTION
-- Order: 22
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'GetParameterDataType',
    N'FUNCTION',
    22,
    N'Core Functions',
    N'Returns parameter data type',
    N'CREATE FUNCTION {SCHEMA}.[GetParameterDataType]
    (
        @ParameterKey nvarchar(100)
    )
    RETURNS varchar(20)
    AS
    BEGIN
        DECLARE @DataType varchar(20);
        
        SELECT @DataType = [DataType]
        FROM {SCHEMA}.[GlobalParameters]
        WHERE [ParameterKey] = @ParameterKey 
          AND [IsActive] = 1;
        
        RETURN @DataType;
    END;',
    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetParameterDataType];',
    1,
    GETDATE()
);


-- ============================================
-- Object: GetTypedParameter
-- Type: FUNCTION
-- Order: 23
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'GetTypedParameter',
    N'FUNCTION',
    23,
    N'Core Functions',
    N'Returns parameter with automatic type conversion',
    N'CREATE FUNCTION {SCHEMA}.[GetTypedParameter]
    (
        @ParameterKey nvarchar(100),
        @OutputDataType varchar(20) = NULL
    )
    RETURNS sql_variant
    AS
    BEGIN
        DECLARE @Value nvarchar(4000);
        DECLARE @DataType varchar(20);
        DECLARE @Result sql_variant;
        
        SELECT 
            @Value = [ParameterValue],
            @DataType = [DataType]
        FROM {SCHEMA}.[GlobalParameters]
        WHERE [ParameterKey] = @ParameterKey 
          AND [IsActive] = 1;
        
        -- Optional type validation
        IF @OutputDataType IS NOT NULL AND @DataType != @OutputDataType
        BEGIN
            RETURN NULL;
        END
        
        -- Convert based on stored data type
        IF @DataType = ''INT''
            SET @Result = CAST(@Value AS int);
        ELSE IF @DataType = ''DECIMAL''
            SET @Result = CAST(@Value AS decimal(18,6));
        ELSE IF @DataType = ''BOOLEAN''
            SET @Result = CASE WHEN LOWER(@Value) IN (''true'', ''1'', ''yes'') THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END;
        ELSE IF @DataType = ''DATE''
            SET @Result = CAST(@Value AS date);
        ELSE IF @DataType = ''DATETIME''
            SET @Result = CAST(@Value AS datetime2);
        ELSE
            SET @Result = @Value;
        
        RETURN @Result;
    END;',
    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetTypedParameter];',
    1,
    GETDATE()
);


-- ============================================
-- Object: SetParameter
-- Type: PROCEDURE
-- Order: 30
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'SetParameter',
    N'PROCEDURE',
    30,
    N'Core Procedures',
    N'Sets or updates a parameter value',
    N'CREATE PROCEDURE {SCHEMA}.[SetParameter]
        @ParameterKey nvarchar(100),
        @ParameterValue nvarchar(4000),
        @DataType varchar(20) = ''STRING'',
        @Category nvarchar(50) = NULL,
        @Description nvarchar(500) = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        
        -- Validate DataType
        IF @DataType NOT IN (''STRING'', ''INT'', ''DECIMAL'', ''BOOLEAN'', ''DATE'', ''DATETIME'', ''JSON'')
        BEGIN
            RAISERROR(''Invalid DataType. Must be one of: STRING, INT, DECIMAL, BOOLEAN, DATE, DATETIME, JSON'', 16, 1);
            RETURN;
        END
        
        -- Insert or Update
        IF EXISTS (SELECT 1 FROM {SCHEMA}.[GlobalParameters] WHERE [ParameterKey] = @ParameterKey)
        BEGIN
            UPDATE {SCHEMA}.[GlobalParameters]
            SET [ParameterValue] = @ParameterValue,
                [DataType] = @DataType,
                [Category] = ISNULL(@Category, [Category]),
                [Description] = ISNULL(@Description, [Description]),
                [ModifiedBy] = SYSTEM_USER,
                [ModifiedDate] = GETDATE(),
                [Version] = [Version] + 1
            WHERE [ParameterKey] = @ParameterKey;
            
            PRINT ''Parameter updated: '' + @ParameterKey;
        END
        ELSE
        BEGIN
            INSERT INTO {SCHEMA}.[GlobalParameters] 
            ([ParameterKey], [ParameterValue], [DataType], [Category], [Description])
            VALUES 
            (@ParameterKey, @ParameterValue, @DataType, @Category, @Description);
            
            PRINT ''Parameter created: '' + @ParameterKey;
        END
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[SetParameter];',
    1,
    GETDATE()
);


-- ============================================
-- Object: SampleData
-- Type: SAMPLE_DATA
-- Order: 40
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'SampleData',
    N'SAMPLE_DATA',
    40,
    N'Sample Data',
    N'Insert sample parameters for testing',
    N'EXEC {SCHEMA}.[SetParameter] 
        @ParameterKey = ''APP_VERSION'', 
        @ParameterValue = ''1.0.0'', 
        @DataType = ''STRING'', 
        @Category = ''Application'',
        @Description = ''Current application version'';

    EXEC {SCHEMA}.[SetParameter] 
        @ParameterKey = ''MAX_RETRY_ATTEMPTS'', 
        @ParameterValue = ''3'', 
        @DataType = ''INT'', 
        @Category = ''Configuration'',
        @Description = ''Maximum number of retry attempts'';

    EXEC {SCHEMA}.[SetParameter] 
        @ParameterKey = ''MAINTENANCE_MODE'', 
        @ParameterValue = ''false'', 
        @DataType = ''BOOLEAN'', 
        @Category = ''System'',
        @Description = ''Whether the system is in maintenance mode'';

    EXEC {SCHEMA}.[SetParameter] 
        @ParameterKey = ''DEFAULT_TIMEOUT'', 
        @ParameterValue = ''30.5'', 
        @DataType = ''DECIMAL'', 
        @Category = ''Configuration'',
        @Description = ''Default timeout in seconds'';

    EXEC {SCHEMA}.[SetParameter] 
        @ParameterKey = ''LAST_MAINTENANCE_DATE'', 
        @ParameterValue = ''{CURRENT_DATETIME}'', 
        @DataType = ''DATETIME'', 
        @Category = ''System'',
        @Description = ''Last maintenance date and time'';',
    NULL,
    1,
    GETDATE()
);


-- ============================================
-- Object: FilterList
-- Type: PROCEDURE
-- Order: 49
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'FilterList',
    N'PROCEDURE',
    49,
    N'Visualization Procedures',
    N'Returns a list of filter values for dropdowns',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[FilterList]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''FilterList'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for FilterList or inactive'', 16, 1, @DataSet);
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
            SELECT @DataSet AS DataSet;
            
        END TRY
        BEGIN CATCH
            SET @ErrorMsg = ''Error executing FilterList for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[FilterList];',
    1,
    GETDATE()
);


-- ============================================
-- Object: BarChartCard
-- Type: PROCEDURE
-- Order: 50
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'BarChartCard',
    N'PROCEDURE',
    50,
    N'Visualization Procedures',
    N'Executes bar chart queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[BarChartCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''BarChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for BarChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[BarChartCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: LineChartCard
-- Type: PROCEDURE
-- Order: 51
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'LineChartCard',
    N'PROCEDURE',
    51,
    N'Visualization Procedures',
    N'Executes line chart queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[LineChartCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''LineChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for LineChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[LineChartCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: PieChartCard
-- Type: PROCEDURE
-- Order: 52
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'PieChartCard',
    N'PROCEDURE',
    52,
    N'Visualization Procedures',
    N'Executes pie chart queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[PieChartCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''PieChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for PieChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[PieChartCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: SingleKPICard
-- Type: PROCEDURE
-- Order: 53
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'SingleKPICard',
    N'PROCEDURE',
    53,
    N'Visualization Procedures',
    N'Executes single KPI queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[SingleKPICard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''SingleKPICard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for SingleKPICard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing SingleKPICard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[SingleKPICard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: CustomDataGrid
-- Type: PROCEDURE
-- Order: 54
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'CustomDataGrid',
    N'PROCEDURE',
    54,
    N'Visualization Procedures',
    N'Executes custom data grid queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CustomDataGrid]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''CustomDataGrid'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for CustomDataGrid or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CustomDataGrid];',
    1,
    GETDATE()
);


-- ============================================
-- Object: HeatmapCard
-- Type: PROCEDURE
-- Order: 55
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'HeatmapCard',
    N'PROCEDURE',
    55,
    N'Visualization Procedures',
    N'Executes heatmap queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[HeatmapCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''HeatmapCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for HeatmapCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing HeatmapCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[HeatmapCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: CombinedChartCard
-- Type: PROCEDURE
-- Order: 56
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'CombinedChartCard',
    N'PROCEDURE',
    56,
    N'Visualization Procedures',
    N'Executes combined chart queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CombinedChartCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''CombinedChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for CombinedChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CombinedChartCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CombinedChartCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: TreeViewCard
-- Type: PROCEDURE
-- Order: 57
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'TreeViewCard',
    N'PROCEDURE',
    57,
    N'Visualization Procedures',
    N'Executes tree view queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[TreeViewCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''TreeViewCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for TreeViewCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing TreeViewCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[TreeViewCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: StackedBarChartCard
-- Type: PROCEDURE
-- Order: 58
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'StackedBarChartCard',
    N'PROCEDURE',
    58,
    N'Visualization Procedures',
    N'Executes stacked bar chart queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StackedBarChartCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''StackedBarChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for StackedBarChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing StackedBarChartCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[StackedBarChartCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: StatCard
-- Type: PROCEDURE
-- Order: 59
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'StatCard',
    N'PROCEDURE',
    59,
    N'Visualization Procedures',
    N'Executes stat card queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StatCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''StatCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for StatCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing StatCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[StatCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: MultiLineChartCard
-- Type: PROCEDURE
-- Order: 60
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'MultiLineChartCard',
    N'PROCEDURE',
    60,
    N'Visualization Procedures',
    N'Executes multi-line chart queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MultiLineChartCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''MultiLineChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for MultiLineChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing MultiLineChartCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[MultiLineChartCard];',
    1,
    GETDATE()
);


-- ============================================
-- Object: CustomGroupedDataGrid
-- Type: PROCEDURE
-- Order: 61
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'CustomGroupedDataGrid',
    N'PROCEDURE',
    61,
    N'Visualization Procedures',
    N'Executes custom grouped data grid queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CustomGroupedDataGrid]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''CustomGroupedDataGrid'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for CustomGroupedDataGrid or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CustomGroupedDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CustomGroupedDataGrid];',
    1,
    GETDATE()
);


-- ============================================
-- Object: CustomPinnedDataGrid
-- Type: PROCEDURE
-- Order: 62
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'CustomPinnedDataGrid',
    N'PROCEDURE',
    62,
    N'Visualization Procedures',
    N'Executes custom pinned data grid queries based on dataset configuration',
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CustomPinnedDataGrid]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''CustomPinnedDataGrid'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for CustomPinnedDataGrid or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CustomPinnedDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CustomPinnedDataGrid];',
    1,
    GETDATE()
);


-- ============================================
-- Object: RadarChartCard
-- Type: PROCEDURE
-- Order: 63
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'RadarChartCard',
    N'PROCEDURE',
    63,
    N'Visualisation Procedures',
    NULL,
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[RadarChartCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''RadarChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for RadarChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing RadarChartCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    N'DROP PROCEDURE {SCHEMA}.[RadarChartCard]',
    1,
    GETDATE()
);


-- ============================================
-- Object: MarkdownCard
-- Type: PROCEDURE
-- Order: 64
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'MarkdownCard',
    N'PROCEDURE',
    64,
    N'Visualisation Procedures',
    NULL,
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MarkdownCard]
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
            @SQL = COALESCE(ExecutionQuery,QueryTemplate),
            @ParameterMappings = ParameterMappings,
            @FilterDefinitions = FilterDefinitions
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = ''BarChartCard'' 
        AND Status = ''LIVE'';
        
        IF @SQL IS NULL
        BEGIN
            RAISERROR(''DataSet "%s" not found for BarChartCard or inactive'', 16, 1, @DataSet);
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
            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END;',
    NULL,
    1,
    GETDATE()
);


-- ============================================
-- Object: CTL_DV_PROCESS
-- Type: TABLE
-- Order: 100
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'CTL_DV_PROCESS',
    N'TABLE',
    100,
    N'Core Tables',
    N'Data Vault Process Table',
    N'CREATE TABLE {SCHEMA}.[CTL_DV_PROCESS](
	[JobId] [uniqueidentifier] NOT NULL,
	[Status] [nvarchar](100) NOT NULL,
	[StartTS_UTC] [datetime2](7) NOT NULL,
	[EndTS_UTC] [datetime2](7) NULL,
	[StgLoadBatchID] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];',
    N'DROP TABLE IF EXISTS {SCHEMA}.[CTL_DV_PROCESS]',
    1,
    GETDATE()
);


-- ============================================
-- Object: CTL_STG_PROCESS
-- Type: TABLE
-- Order: 101
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'CTL_STG_PROCESS',
    N'TABLE',
    101,
    N'Core Tables',
    N'Staging Process Table',
    N'CREATE TABLE {SCHEMA}.[CTL_STG_PROCESS](
	[BatchID] [uniqueidentifier] NOT NULL,
	[IntegrationSchema] [nvarchar](100) NOT NULL,
	[StoreID] [nvarchar](100) NOT NULL,
	[ApiDate] [nvarchar](100) NOT NULL,
	[Status] [nvarchar](100) NOT NULL,
	[StartTS_UTC] [datetime2](7) NULL,
	[EndTS_UTC] [datetime2](7) NULL,
 CONSTRAINT [PK_CTL_STG_PROCESS] PRIMARY KEY CLUSTERED 
(
	[BatchID] ASC,
	[StoreID] ASC,
	[ApiDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];',
    N'DROP TABLE {SCHEMA}.[CTL_STG_PROCESS];',
    1,
    GETDATE()
);


-- ============================================
-- Object: LOG_DV
-- Type: TABLE
-- Order: 102
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'LOG_DV',
    N'TABLE',
    102,
    N'Core Tables',
    N'Data Vault Logging Table',
    N'CREATE TABLE {SCHEMA}.[LOG_DV](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dv_process_job_id] [uniqueidentifier] NOT NULL,
	[src] [nvarchar](100) NULL,
	[entity] [nvarchar](100) NULL,
	[log_level] [nvarchar](100) NOT NULL,
	[log_msg] [nvarchar](max) NOT NULL,
	[logts_utc] [datetime2](7) NOT NULL DEFAULT (sysutcdatetime()),
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];',
    N'DROP TABLE {SCHEMA}.[LOG_DV];',
    1,
    GETDATE()
);


-- ============================================
-- Object: LOG_STG
-- Type: TABLE
-- Order: 103
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'LOG_STG',
    N'TABLE',
    103,
    N'Core Tables',
    N'Staging Logging Table',
    N'CREATE TABLE {SCHEMA}.[LOG_STG](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[stg_process_batchid] [uniqueidentifier] NOT NULL,
	[integration_schema] [nvarchar](100) NULL,
	[storeid] [nvarchar](100) NULL,
	[ApiDate] [nvarchar](100) NULL,
	[log_level] [nvarchar](100) NOT NULL,
	[log_msg] [nvarchar](max) NOT NULL,
	[logts_utc] [datetime2](7) NOT NULL DEFAULT (sysutcdatetime()),
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];',
    N'DROP TABLE {SCHEMA}.[LOG_STG];',
    1,
    GETDATE()
);


-- ============================================
-- Object: ForecastModels
-- Type: TABLE
-- Order: 104
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'ForecastModels',
    N'TABLE',
    104,
    N'Core Tables',
    NULL,
    N'CREATE TABLE {SCHEMA}.ForecastModels (
    -- Primary Key
    model_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    
    -- Location and Category Info
    location_hub_id BINARY(32) NOT NULL,
    product_category NVARCHAR(255) NOT NULL,
    
    -- Model Info
    model_type NVARCHAR(255) NOT NULL,  -- ''gb_quantity'', ''gb_revenue'', ''gb_transactions''
    model_binary VARBINARY(MAX) NOT NULL,  -- The actual trained model (.pkl file)
    
    -- Training Metadata
    training_date DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    training_samples INT,  -- Number of records used to train
    mae FLOAT,  -- Mean Absolute Error
    mape FLOAT,  -- Mean Absolute Percentage Error
    
    -- Features Used
    feature_columns NVARCHAR(MAX),  -- JSON array of feature names
    model_metadata NVARCHAR(MAX),  -- JSON with hyperparameters, etc.
    
    -- Status
    is_active BIT NOT NULL DEFAULT 1,  -- Only one active model per location-category-type
    
    -- Audit
    created_date DATETIME NOT NULL DEFAULT GETDATE(),
    created_by VARCHAR(100) DEFAULT SYSTEM_USER
)

-- Create indexes for fast lookups
CREATE INDEX IX_ForecastModels_Lookup 
ON {SCHEMA}.ForecastModels(location_hub_id, product_category, model_type, is_active)

CREATE INDEX IX_ForecastModels_TrainingDate 
ON {SCHEMA}.ForecastModels(training_date DESC)

CREATE INDEX IX_ForecastModels_LocationCategory
ON {SCHEMA}.ForecastModels(location_hub_id, product_category)',
    NULL,
    1,
    GETDATE()
);


-- ============================================
-- Object: ForecastResults
-- Type: TABLE
-- Order: 105
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'ForecastResults',
    N'TABLE',
    105,
    N'Core Tables',
    NULL,
    N'CREATE TABLE {SCHEMA}.ForecastResults (
    -- Primary Key
    forecast_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    
    -- Links to model
    model_id UNIQUEIDENTIFIER NOT NULL,
    
    -- Location and Category
    location_hub_id BINARY(32) NOT NULL,
    product_category NVARCHAR(255) NOT NULL,
    
    -- Forecast Data
    forecast_date DATETIME2(7) NOT NULL,
    forecasted_quantity FLOAT NOT NULL,
    lower_bound FLOAT,  -- Confidence interval lower bound
    upper_bound FLOAT,  -- Confidence interval upper bound
    confidence_level FLOAT DEFAULT 0.95,  -- e.g., 95% confidence
    
    -- Audit
    created_date DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
);

-- Indexes for queries
CREATE INDEX IX_ForecastResults_Lookup 
ON {SCHEMA}.ForecastResults(location_hub_id, product_category, forecast_date);

CREATE INDEX IX_ForecastResults_ModelDate 
ON {SCHEMA}.ForecastResults(model_id, forecast_date);

CREATE INDEX IX_ForecastResults_Date 
ON {SCHEMA}.ForecastResults(forecast_date);

CREATE INDEX IX_ForecastResults_LocationDate
ON {SCHEMA}.ForecastResults(location_hub_id, forecast_date);',
    NULL,
    1,
    GETDATE()
);


-- ============================================
-- Object: ModelPerformanceHistory
-- Type: TABLE
-- Order: 106
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'ModelPerformanceHistory',
    N'TABLE',
    106,
    N'Core Tables',
    NULL,
    N'CREATE TABLE {SCHEMA}.ModelPerformanceHistory (
    -- Primary Key
    performance_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    
    -- Links to model
    model_id UNIQUEIDENTIFIER NOT NULL,
    
    -- Evaluation Data
    evaluation_date DATETIME2(7) NOT NULL,
    actual_quantity FLOAT,
    predicted_quantity FLOAT,
    absolute_error FLOAT,  -- |actual - predicted|
    percentage_error FLOAT,  -- (|actual - predicted| / actual) * 100
    
    -- Audit
    created_date DATETIME2(7) NOT NULL DEFAULT GETDATE(),
    
);

-- Index for tracking over time
CREATE INDEX IX_ModelPerformance_Date 
ON {SCHEMA}.ModelPerformanceHistory(model_id, evaluation_date);',
    NULL,
    1,
    GETDATE()
);


-- ============================================
-- Object: WeatherData
-- Type: TABLE
-- Order: 107
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'WeatherData',
    N'TABLE',
    107,
    N'Core Tables',
    NULL,
    N'CREATE TABLE {SCHEMA}.WeatherData (
    -- Primary Key
    weather_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    
    -- Location
    location_hub_id BINARY(32) NOT NULL,
    weather_date DATETIME2(7) NOT NULL,
    
    -- Temperature (Fahrenheit)
    temperature_avg DECIMAL(5,2),
    temperature_high DECIMAL(5,2),
    temperature_low DECIMAL(5,2),
    
    -- Precipitation
    precipitation_cm DECIMAL(5,2),
    precipitation_probability INT,  -- 0-100%
    
    -- Conditions
    weather_condition NVARCHAR(50),  -- ''sunny'', ''rainy'', ''snowy'', etc.
    is_severe_weather BIT,  -- Flag for extreme conditions
    
    -- Other
    humidity_pct INT,
    wind_speed_mph DECIMAL(5,2),
    
    -- Metadata
    data_source VARCHAR(100),  -- ''OpenWeatherMap'', ''NOAA'', etc.
    created_date DATETIME2(7) DEFAULT GETDATE(),
    
    -- Unique constraint: one weather record per location per date
    CONSTRAINT UQ_WeatherData UNIQUE (location_hub_id, weather_date)
);

CREATE INDEX IX_WeatherData_Lookup 
ON {SCHEMA}.WeatherData(location_hub_id, weather_date);',
    NULL,
    1,
    GETDATE()
);


-- ============================================
-- Object: LOCATION
-- Type: TABLE
-- Order: 108
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'LOCATION',
    N'TABLE',
    108,
    N'Core Tables',
    N'Global Location Table',
    N'CREATE TABLE {SCHEMA}.LOCATION
(
    Id                      INT IDENTITY(1,1) PRIMARY KEY,
    IntegrationLocationId   NVARCHAR(100)    NOT NULL,
    IntegrationLocationName NVARCHAR(255)    NULL,
    IntegrationSrc          NVARCHAR(50)     NOT NULL,
    MicroserviceId          UNIQUEIDENTIFIER NULL,
    MicroserviceName        NVARCHAR(255)    NULL,
    ApiFetch                BIT              NOT NULL DEFAULT (1),
    CreatedAtUtc            DATETIME2(7)     NOT NULL DEFAULT (SYSUTCDATETIME()),
    UpdatedAtUtc            DATETIME2(7)     NULL,
    CreatedBy               NVARCHAR(100)    NULL,
    UpdatedBy               NVARCHAR(100)    NULL
);

ALTER TABLE core.LOCATION
ADD CONSTRAINT UQ_LOCATION_Integration UNIQUE (IntegrationLocationId, IntegrationSrc);',
    N'DROP TABLE {SCHEMA}.LOCATION;',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_GenerateCDC
-- Type: PROCEDURE
-- Order: 120
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_GenerateCDC',
    N'PROCEDURE',
    120,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER   PROCEDURE {SCHEMA}.[sp_GenerateCDC] 
    @PK_COLUMN_IN VARCHAR(255),
    @ENTITY_IN VARCHAR(255),
    @COLUMN_LIST_IN NVARCHAR(MAX),
    @TYPE2_LIST_IN NVARCHAR(MAX),
    @TARGET_TABLE_FILTER_IN VARCHAR(4000) = '' '',
    @SRC NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL_CREATE NVARCHAR(4000)
    DECLARE @SQL NVARCHAR(4000)
    DECLARE @TARGET_TABLE_FILTER VARCHAR(4000)
    DECLARE @SAT_TABLE_NAME VARCHAR(255)
    DECLARE @CDC_TABLE_NAME VARCHAR(255) = ''load.CDC_'' + @ENTITY_IN
    DECLARE @ATTRIBUTES NVARCHAR(MAX)
    SELECT @ATTRIBUTES = STRING_AGG(LTRIM(RTRIM(value)), '', '')
    FROM STRING_SPLIT(@COLUMN_LIST_IN, '','')
    WHERE LTRIM(RTRIM(value)) NOT LIKE ''%_HUB_ID]''
    AND LTRIM(RTRIM(value)) != ''[LINK_ID]''
    AND LTRIM(RTRIM(value)) != ''[MICROSERVICE%''
    
    -- Set SAT table name based on primary key
    SET @SAT_TABLE_NAME = CASE 
        WHEN @PK_COLUMN_IN = ''LNK_ID'' THEN ''datavault.SAT_LNK_'' + @ENTITY_IN
        ELSE ''datavault.SAT_'' + @ENTITY_IN
    END
    
    -- Skip if SAT table doesn''t exist
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@SAT_TABLE_NAME) AND type = ''U'')
        RETURN 0
    
    -- Build target table filter
    SET @TARGET_TABLE_FILTER = CASE 
        WHEN LEN(RTRIM(LTRIM(@TARGET_TABLE_FILTER_IN))) >= 2 THEN '' WHERE CURRENT_FLAG = 1''
        ELSE '' ''
    END
    
    -- Create CDC table if it doesn''t exist
    SET @SQL_CREATE = 
    ''IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''''load.CDC_'' + @ENTITY_IN + '''''') AND type = ''''U'''')
    CREATE TABLE load.CDC_'' + @ENTITY_IN + ''('' + @PK_COLUMN_IN + '' BINARY(32), CHANGE_TYPE VARCHAR(10))
    
    IF EXISTS (SELECT * FROM sys.indexes WHERE name=''''IDX_CDC_'' + @ENTITY_IN + '''''' AND object_id = OBJECT_ID(N''''load.CDC_'' + @ENTITY_IN + ''''''))
    DROP INDEX IDX_CDC_'' + @ENTITY_IN + '' ON load.CDC_'' + @ENTITY_IN +''
    
    TRUNCATE TABLE load.CDC_'' + @ENTITY_IN +''
    
    CREATE UNIQUE CLUSTERED INDEX IDX_CDC_'' + @ENTITY_IN + '' ON load.CDC_'' + @ENTITY_IN + ''('' + @PK_COLUMN_IN + '' ASC)''
    
    EXEC sp_executesql @SQL_CREATE
    
    -- Generate CDC data
    SET @SQL = 
    ''INSERT INTO load.CDC_'' + @ENTITY_IN + ''  
    SELECT
        ISNULL(LH.'' + @PK_COLUMN_IN + '',RH.'' + @PK_COLUMN_IN + ''),
        CASE
           /* WHEN LH.'' + @PK_COLUMN_IN + '' IS NULL THEN ''''D''''*/
            WHEN RH.'' + @PK_COLUMN_IN + '' IS NULL THEN ''''N''''
            WHEN LH.CHECK_TYPE1 != RH.CHECK_TYPE1 THEN 
                CASE WHEN LH.CHECK_TYPE2 != RH.CHECK_TYPE2 THEN ''''T2'''' ELSE ''''T1'''' END
            ELSE ''''NC''''
        END AS CHANGE_TYPE
    FROM
        (SELECT '' + @PK_COLUMN_IN + '', CHECKSUM('' + @ATTRIBUTES + '') AS CHECK_TYPE1, CHECKSUM('' + @TYPE2_LIST_IN + '') AS CHECK_TYPE2
         FROM load.'' + @ENTITY_IN + '') LH
        LEFT OUTER JOIN
        (SELECT '' + @PK_COLUMN_IN + '', CHECKSUM('' + @ATTRIBUTES + '') AS CHECK_TYPE1, CHECKSUM('' + @TYPE2_LIST_IN + '') AS CHECK_TYPE2
         FROM '' + @SAT_TABLE_NAME + @TARGET_TABLE_FILTER + '') RH
        ON RH.'' + @PK_COLUMN_IN + '' = LH.'' + @PK_COLUMN_IN
    
    EXEC sp_executesql @SQL
    
    RETURN 0
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_GenerateCDC];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_PopulateLoadTable
-- Type: PROCEDURE
-- Order: 121
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_PopulateLoadTable',
    N'PROCEDURE',
    121,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER   PROCEDURE {SCHEMA}.[sp_PopulateLoadTable] 
    @ENTITY_IN VARCHAR(255),
    @QUERY_SQL_IN NVARCHAR(MAX),
    @PK_COL_IN VARCHAR(255) = ''HUB_ID''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @LOAD_TABLE_NAME VARCHAR(255) = ''load.'' + @ENTITY_IN
    DECLARE @SQL_TRUNCATE NVARCHAR(4000) = ''TRUNCATE TABLE '' + @LOAD_TABLE_NAME
    
    -- Truncate and populate load table
    EXEC sp_executesql @SQL_TRUNCATE
    EXEC sp_executesql @QUERY_SQL_IN
    
    RETURN 0
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_PopulateLoadTable] ;',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_ProcessHubSat
-- Type: PROCEDURE
-- Order: 122
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_ProcessHubSat',
    N'PROCEDURE',
    122,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER   PROCEDURE {SCHEMA}.[sp_ProcessHubSat] 
    @ENTITY_IN VARCHAR(255),
    @PK_COLUMN_IN VARCHAR(255),
    @COLUMN_LIST_IN NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @HUB_TABLE VARCHAR(255) = ''datavault.HUB_'' + @ENTITY_IN
    DECLARE @SAT_TABLE VARCHAR(255) = ''datavault.SAT_'' + @ENTITY_IN
    DECLARE @LOAD_TABLE VARCHAR(255) = ''load.'' + @ENTITY_IN
    DECLARE @CDC_TABLE VARCHAR(255) = ''load.CDC_'' + @ENTITY_IN
    
    -- Execute the 10-step SCD Type 2 processing
    SET @SQL = 
    ''BEGIN TRANSACTION
    
    -- 1: Update EFFECTIVEFROM dates for T1 changes
    UPDATE L SET L.EFFECTIVEFROM = S.EFFECTIVEFROM
    FROM '' + @LOAD_TABLE + '' L
    INNER JOIN '' + @CDC_TABLE + '' C ON L.'' + @PK_COLUMN_IN + '' = C.'' + @PK_COLUMN_IN + ''
    INNER JOIN '' + @SAT_TABLE + '' S ON L.'' + @PK_COLUMN_IN + '' = S.'' + @PK_COLUMN_IN + ''
    WHERE S.CURRENT_FLAG = 1 AND C.CHANGE_TYPE = ''''T1''''
    
    -- 2: Delete T1 and N records from SAT table
    DELETE FROM '' + @SAT_TABLE + '' 
    WHERE '' + @PK_COLUMN_IN + '' IN (
        SELECT L.'' + @PK_COLUMN_IN + '' FROM '' + @LOAD_TABLE + '' L
        INNER JOIN '' + @CDC_TABLE + '' C ON L.'' + @PK_COLUMN_IN + '' = C.'' + @PK_COLUMN_IN + '' 
        WHERE C.CHANGE_TYPE IN (''''T1'''',''''N''''))
    
    -- 3: Delete N records from HUB table
    DELETE FROM '' + @HUB_TABLE + '' 
    WHERE '' + @PK_COLUMN_IN + '' IN (
        SELECT L.'' + @PK_COLUMN_IN + '' FROM '' + @LOAD_TABLE + '' L
        INNER JOIN '' + @CDC_TABLE + '' C ON L.'' + @PK_COLUMN_IN + '' = C.'' + @PK_COLUMN_IN + '' 
        WHERE C.CHANGE_TYPE = ''''N'''')
    
    -- 4: Close T2 records
    UPDATE S SET S.EFFECTIVETO = CAST(DATEADD(DAY, -1, L.LOAD_TS) AS DATETIME2(7)), S.CURRENT_FLAG = 0
    FROM '' + @LOAD_TABLE + '' L
    INNER JOIN '' + @CDC_TABLE + '' C ON L.'' + @PK_COLUMN_IN + '' = C.'' + @PK_COLUMN_IN + ''
    INNER JOIN '' + @SAT_TABLE + '' S ON L.'' + @PK_COLUMN_IN + '' = S.'' + @PK_COLUMN_IN + ''
    WHERE S.CURRENT_FLAG = 1 AND C.CHANGE_TYPE = ''''T2''''
    
    -- 5: Insert N, T1, T2 records into SAT table
    INSERT INTO '' + @SAT_TABLE + '' ('' + @COLUMN_LIST_IN + '',EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC)
    SELECT '' + @COLUMN_LIST_IN + '',EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM ( SELECT L.* FROM '' + @LOAD_TABLE + '' L
    INNER JOIN '' + @CDC_TABLE + '' C ON L.'' + @PK_COLUMN_IN + '' = C.'' + @PK_COLUMN_IN + ''
    WHERE C.CHANGE_TYPE NOT IN (''''NC'''',''''D'''') )SUB
    
    -- 6: Insert new records into HUB table
    INSERT INTO '' + @HUB_TABLE + ''
    SELECT L.'' + @PK_COLUMN_IN + '', L.SRC, L.IS_DELETED, L.LOAD_TS
    FROM '' + @LOAD_TABLE + '' L
    INNER JOIN '' + @CDC_TABLE + '' C ON L.'' + @PK_COLUMN_IN + '' = C.'' + @PK_COLUMN_IN + ''
    WHERE C.CHANGE_TYPE = ''''N''''
    
    -- 9: Reset deletion flags in SAT table for NC records
    UPDATE S SET S.IS_DELETED = 0
    FROM '' + @CDC_TABLE + '' C
    INNER JOIN '' + @SAT_TABLE + '' S ON C.'' + @PK_COLUMN_IN + '' = S.'' + @PK_COLUMN_IN + ''
    WHERE C.CHANGE_TYPE = ''''NC''''
    
    -- 10: Reset deletion flags in HUB table for NC records
    UPDATE H SET H.IS_DELETED = 0
    FROM '' + @CDC_TABLE + '' C
    INNER JOIN '' + @HUB_TABLE + '' H ON C.'' + @PK_COLUMN_IN + '' = H.'' + @PK_COLUMN_IN + ''
    WHERE C.CHANGE_TYPE = ''''NC''''
    
    COMMIT TRANSACTION''
    
    EXECUTE sp_executesql @SQL
    
    RETURN 0
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_ProcessHubSat];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_ProcessLink
-- Type: PROCEDURE
-- Order: 123
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_ProcessLink',
    N'PROCEDURE',
    123,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER   PROCEDURE {SCHEMA}.[sp_ProcessLink] 
    @ENTITY_IN VARCHAR(255),
    @PK_COLUMN_IN VARCHAR(255),
    @COLUMN_LIST_IN NVARCHAR(MAX)
AS
-- SP used as standard process for loading Link tables with simple append-only logic
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @LINK_TABLE VARCHAR(255) = ''datavault.LNK_'' + @ENTITY_IN
    DECLARE @SAT_LINK_TABLE VARCHAR(255) = ''datavault.SAT_LNK_'' + @ENTITY_IN
    DECLARE @LOAD_TABLE VARCHAR(255) = ''load.'' + @ENTITY_IN
    DECLARE @HubIdColumns NVARCHAR(MAX)
    DECLARE @ATTRIBUTES NVARCHAR(MAX)
    SELECT @HubIdColumns = STRING_AGG(LTRIM(RTRIM(value)), '', '')
    FROM STRING_SPLIT(@COLUMN_LIST_IN, '','')
    WHERE LTRIM(RTRIM(value)) LIKE ''%_HUB_ID]'' OR LTRIM(RTRIM(value)) = ''[LNK_ID]''
    SELECT @ATTRIBUTES = STRING_AGG(LTRIM(RTRIM(value)), '', '')
    FROM STRING_SPLIT(@COLUMN_LIST_IN, '','')
    WHERE LTRIM(RTRIM(value)) NOT LIKE ''%_HUB_ID]''
    
    -- Execute simple 2-step link processing
    SET @SQL = 
    ''BEGIN TRANSACTION
    
    -- 1: Delete from LOAD table where records already exist in Link table (prevent duplicates)
    DELETE FROM '' + @LOAD_TABLE + '' 
    WHERE '' + @PK_COLUMN_IN + '' IN (SELECT '' + @PK_COLUMN_IN + '' FROM '' + @LINK_TABLE + '')
    
    -- 2: Insert remaining new records from LOAD table into Link table
    INSERT INTO '' + @LINK_TABLE + '' ('' + @HubIdColumns + '', LOAD_TS, SRC)
    SELECT '' + @HubIdColumns + '', LOAD_TS, SRC FROM '' + @LOAD_TABLE + ''
    
    COMMIT TRANSACTION''
    
    EXECUTE sp_executesql @SQL

    IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(@SAT_LINK_TABLE) 
           AND type = ''U'')
    BEGIN
    SET @SQL = 
    ''BEGIN TRANSACTION
    
    
    -- 3: Insert remaining new records from LOAD table into Sat Link table
    INSERT INTO '' + @SAT_LINK_TABLE + '' ('' + @ATTRIBUTES + '', LOAD_TS, SRC)
    SELECT '' + @ATTRIBUTES + '', LOAD_TS, SRC FROM '' + @LOAD_TABLE + ''
    
    COMMIT TRANSACTION''
    
    EXECUTE sp_executesql @SQL
    END
    RETURN 0
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_ProcessLink];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_Staging
-- Type: PROCEDURE
-- Order: 124
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_Staging',
    N'PROCEDURE',
    124,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER   PROCEDURE {SCHEMA}.[sp_Staging]
    @SchemaName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StepName NVARCHAR(255)
    DECLARE @Entity NVARCHAR(255)
    DECLARE @QuerySQL NVARCHAR(MAX)
    DECLARE @Tier INT
    DECLARE @StepType NVARCHAR(255)
    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @ReturnCode INT = 0
    
    CREATE TABLE #CurrentSchemaSteps (
        step_name NVARCHAR(255),
        staging_table NVARCHAR(255), 
        query_sql NVARCHAR(MAX),
        tier INT,
        step_type NVARCHAR(255)
    )
    
    -- Get staging steps for current schema
    SET @SQL = ''
    INSERT INTO #CurrentSchemaSteps (step_name, staging_table, query_sql, tier, step_type)
    SELECT step_name, staging_table, query_sql, tier, step_type
    FROM core.'' + QUOTENAME(@SchemaName) + ''.StagingControl
    WHERE step_type = ''''Staging'''' AND ISNULL(exclude, 0) = 0
    ORDER BY tier, step_name''
    
    EXEC sp_executesql @SQL
    
    -- Process each staging step in current schema
    DECLARE staging_cursor CURSOR FOR
    SELECT step_name, staging_table, query_sql, tier, step_type
    FROM #CurrentSchemaSteps ORDER BY tier, step_name
    
    OPEN staging_cursor
    FETCH NEXT FROM staging_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Execute the query SQL for this staging step
        BEGIN TRY
            EXEC sp_executesql @QuerySQL
        END TRY
        BEGIN CATCH
            -- Log error or handle as needed
            SET @ReturnCode = ERROR_NUMBER()
            PRINT ''Error in staging step: '' + @StepName + '' - '' + ERROR_MESSAGE()
            -- You might want to break here or continue based on your error handling strategy
        END CATCH
        
        FETCH NEXT FROM staging_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType
    END
    
    CLOSE staging_cursor
    DEALLOCATE staging_cursor
    
    DROP TABLE #CurrentSchemaSteps
    
    RETURN @ReturnCode
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_Staging];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_InitEntityDeltaParameters
-- Type: PROCEDURE
-- Order: 125
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_InitEntityDeltaParameters',
    N'PROCEDURE',
    125,
    N'Data Vault Procedures',
    NULL,
    N'CREATE  OR ALTER   PROCEDURE {SCHEMA}.[sp_InitEntityDeltaParameters]
    @ExecutedBy NVARCHAR(100) = ''SYSTEM''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentDate DATETIME = GETDATE();
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Create a temp table with the parameters that should exist
        WITH EntityParameters AS (
            SELECT 
                [ENTITY_NAME] + ''_START'' AS ParameterKey,
                ''DATETIME'' AS DataType,
                ''Entity Delta'' AS Category,
                ''Automated entity delta start date for '' + [ENTITY_NAME] AS Description
            FROM [core].[core].[DataVaultEntities]
            WHERE ISNULL([TIME_SERIES], 0) = 1            AND RELEASE_STATE = ''Live''
            
            UNION ALL
            
            SELECT 
                ENTITY_NAME + ''_END'' AS ParameterKey,
                ''DATETIME'' AS DataType,
                ''Entity Delta'' AS Category,
                ''Automated entity delta end date for '' + ENTITY_NAME AS Description
            FROM [core].[core].[DataVaultEntities]
            WHERE ISNULL([TIME_SERIES], 0) = 1            AND RELEASE_STATE = ''Live''
        )
        
        -- Merge the parameters into GlobalParameters
        MERGE INTO [core].[GlobalParameters] AS Target
        USING EntityParameters AS Source
        ON Target.ParameterKey = Source.ParameterKey
        
        -- Update existing records - reset ParameterValue to NULL
        WHEN MATCHED THEN
            UPDATE SET
                Target.ParameterValue = NULL,
                Target.DataType = Source.DataType,
                Target.Category = Source.Category,
                Target.Description = Source.Description,
                Target.IsActive = 1,
                Target.ModifiedBy = @ExecutedBy,
                Target.ModifiedDate = @CurrentDate,
                Target.Version = ISNULL(Target.Version, 0) + 1
        
        -- Insert new records
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                ParameterKey,
                ParameterValue,
                DataType,
                Category,
                Description,
                IsActive,
                CreatedBy,
                CreatedDate,
                ModifiedBy,                ModifiedDate,
                Version
            )
            VALUES (
                Source.ParameterKey,
                NULL,
                Source.DataType,
                Source.Category,
                Source.Description,
                1,
                @ExecutedBy,
                @CurrentDate,
                @ExecutedBy,
                @CurrentDate,
                1
            );
        -- Return summary of changes
        DECLARE @InsertCount INT, @UpdateCount INT;
        SET @InsertCount = @@ROWCOUNT;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        -- Re-throw the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_InitEntityDeltaParameters];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_UpdateEntityDeltaParameters
-- Type: PROCEDURE
-- Order: 126
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_UpdateEntityDeltaParameters',
    N'PROCEDURE',
    126,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_UpdateEntityDeltaParameters]
    @EntityName NVARCHAR(255),
    @ExecutedBy NVARCHAR(100) = ''SYSTEM''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TimeSeriesColumn NVARCHAR(255);
    DECLARE @MinValue DATETIME2;
    DECLARE @MaxValue DATETIME2;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @CurrentDate DATETIME2 = SYSUTCDATETIME();
    
    BEGIN TRY
        -- Check if entity exists and is a time series entity
        SELECT @TimeSeriesColumn = [TIME_SERIES_COLUMN]
        FROM [core].[core].[DataVaultEntities]
        WHERE [ENTITY_NAME] = @EntityName
            AND ISNULL([TIME_SERIES], 0) = 1;
        
        -- If no matching row found, exit
        IF @TimeSeriesColumn IS NULL
        BEGIN
            RETURN;
        END
        
        -- Build dynamic SQL to get MIN and MAX from the entity table
        SET @SQL = N''
            SELECT 
                @MinValueOut = MIN('' + QUOTENAME(@TimeSeriesColumn) + ''),
                @MaxValueOut = MAX('' + QUOTENAME(@TimeSeriesColumn) + '')
            FROM [load].'' + QUOTENAME(@EntityName);
        
        -- Execute dynamic SQL to get MIN and MAX values
        EXEC sp_executesql 
            @SQL,
            N''@MinValueOut DATETIME2 OUTPUT, @MaxValueOut DATETIME2 OUTPUT'',
            @MinValueOut = @MinValue OUTPUT,
            @MaxValueOut = @MaxValue OUTPUT;
        
        BEGIN TRANSACTION;
        
        -- Update START parameter if new MIN is lower than existing value
        -- Strip time component - use start of day
        UPDATE [core].[GlobalParameters]
        SET 
            ParameterValue = CONVERT(NVARCHAR(MAX), CAST(CAST(@MinValue AS DATE) AS DATETIME2), 121),
            ModifiedBy = @ExecutedBy,
            ModifiedDate = @CurrentDate,
            Version = ISNULL(Version, 0) + 1
        WHERE ParameterKey = @EntityName + ''_START''
            AND (
                ParameterValue IS NULL 
                OR CONVERT(DATETIME2, ParameterValue) > CAST(CAST(@MinValue AS DATE) AS DATETIME2)
            )
            AND @MinValue IS NOT NULL;
        
        -- Update END parameter if new MAX is higher than existing value
        -- Strip time component - use start of day
        UPDATE [core].[GlobalParameters]
        SET 
            ParameterValue = CONVERT(NVARCHAR(MAX), CAST(CAST(@MaxValue AS DATE) AS DATETIME2), 121),
            ModifiedBy = @ExecutedBy,
            ModifiedDate = @CurrentDate,
            Version = ISNULL(Version, 0) + 1
        WHERE ParameterKey = @EntityName + ''_END''
            AND (
                ParameterValue IS NULL 
                OR CONVERT(DATETIME2, ParameterValue) < CAST(CAST(@MaxValue AS DATE) AS DATETIME2)
            )
            AND @MaxValue IS NOT NULL;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Re-throw the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_UpdateEntityDeltaParameters];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_DataVaultLoad
-- Type: PROCEDURE
-- Order: 129
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_DataVaultLoad',
    N'PROCEDURE',
    129,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_DataVaultLoad]
    @SchemaList NVARCHAR(MAX) = NULL,
    @StgLoadBatchID UNIQUEIDENTIFIER = NULL,
    @LoggingLevel NVARCHAR(10) = ''ERROR''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @JobID UNIQUEIDENTIFIER = NEWID()
    DECLARE @SchemaName NVARCHAR(255)
    DECLARE @StepName NVARCHAR(255)
    DECLARE @Entity NVARCHAR(255)
    DECLARE @QuerySQL NVARCHAR(MAX)
    DECLARE @Tier INT
    DECLARE @StepType NVARCHAR(255)
    DECLARE @PrimaryKey NVARCHAR(255)
    DECLARE @ReturnCode INT
    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @ColumnList NVARCHAR(MAX)
    DECLARE @Type2List NVARCHAR(MAX)
    DECLARE @EntityColumnsJSON NVARCHAR(MAX)
    DECLARE @ErrorMessage NVARCHAR(MAX)
    DECLARE @ErrorNumber INT
    DECLARE @StartTime DATETIME2(7) = GETUTCDATE()
    DECLARE @SchemaCount INT = 0
    DECLARE @StepCount INT = 0
    DECLARE @ProcessedSchemas INT = 0
    DECLARE @ProcessedSteps INT = 0
    
IF CURSOR_STATUS(''local'', ''step_cursor'') >= 0
            BEGIN
                CLOSE step_cursor
                DEALLOCATE step_cursor
            END
            
            IF CURSOR_STATUS(''global'', ''step_cursor'') >= 0
            BEGIN
                CLOSE step_cursor
                DEALLOCATE step_cursor
            END

EXEC core.sp_ProcessStagingDuplicates 
    @SchemaName = @SchemaName

    BEGIN TRY
        -- Insert initial process control record
        INSERT INTO [core].[CTL_DV_PROCESS] ([JobId], [Status], [StartTS_UTC], [EndTS_UTC], [StgLoadBatchID])
        VALUES (@JobID, ''processing'', @StartTime, NULL, @StgLoadBatchID)
        
        -- Log process start (always logged)
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, NULL, NULL, ''START'', ''Data Vault Load process started with JobID: '' + CAST(@JobID AS NVARCHAR(36)) + '', LogLevel: '' + @LoggingLevel, GETUTCDATE())
        
        CREATE TABLE #SchemasToProcess (schema_name NVARCHAR(255))
        CREATE TABLE #CurrentSchemaSteps (
            step_name NVARCHAR(255),
            staging_table NVARCHAR(255), 
            query_sql NVARCHAR(MAX),
            tier INT,
            step_type NVARCHAR(255)
        )
        
        -- Determine schemas to process
        IF @SchemaList IS NULL
        BEGIN
            INSERT INTO #SchemasToProcess (schema_name)
            SELECT DISTINCT s.name
            FROM core.sys.schemas s
            INNER JOIN core.sys.objects o ON s.schema_id = o.schema_id
            WHERE o.name = ''StagingControl''
            AND s.name LIKE ''int_%''
            
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, NULL, NULL, ''INFO'', ''Processing all available int_% schemas with StagingControl'', GETUTCDATE())
            END
        END
        ELSE
        BEGIN
            INSERT INTO #SchemasToProcess (schema_name)
            SELECT LTRIM(RTRIM(value)) 
            FROM STRING_SPLIT(@SchemaList, '','')
            WHERE LTRIM(RTRIM(value)) <> ''''
            
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, NULL, NULL, ''INFO'', ''Processing specified schemas: '' + @SchemaList, GETUTCDATE())
            END
        END
        
        -- Get count of schemas to process
        SELECT @SchemaCount = COUNT(*) FROM #SchemasToProcess
        
        IF @LoggingLevel = ''DEBUG''
        BEGIN
            INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
            VALUES (@JobID, NULL, NULL, ''INFO'', ''Found '' + CAST(@SchemaCount AS NVARCHAR(10)) + '' schema(s) to process'', GETUTCDATE())
        END
        
        -- Process each schema
        DECLARE schema_cursor CURSOR FOR SELECT schema_name FROM #SchemasToProcess
        OPEN schema_cursor
        FETCH NEXT FROM schema_cursor INTO @SchemaName
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Log schema start for INFO and DEBUG levels only
            IF @LoggingLevel IN (''INFO'', ''DEBUG'')
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''START'', ''Starting processing for schema: '' + @SchemaName, GETUTCDATE())
            END
            
            -- FIRST: Process Staging steps for current schema
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''START'', ''Starting staging process'', GETUTCDATE())
            END
            
            EXEC @ReturnCode = core.sp_Staging @SchemaName = @SchemaName
            
            IF @ReturnCode <> 0
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''ERROR'', ''Staging process failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())
                
                RAISERROR(''Staging process failed for schema %s with return code %d'', 16, 1, @SchemaName, @ReturnCode)
            END
            ELSE
            BEGIN
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, NULL, ''END'', ''Staging process completed successfully'', GETUTCDATE())
                END
            END

            -- SECOND: Process Load steps for current schema
            TRUNCATE TABLE #CurrentSchemaSteps
            
            -- Get steps for current schema
            SET @SQL = ''
            INSERT INTO #CurrentSchemaSteps (step_name, staging_table, query_sql, tier, step_type)
            SELECT step_name, staging_table, query_sql, tier, step_type
            FROM core.'' + QUOTENAME(@SchemaName) + ''.StagingControl
            WHERE step_type = ''''Load'''' AND ISNULL(exclude, 0) = 0
            ORDER BY tier, step_name''
            
            EXEC sp_executesql @SQL
            
            -- Get count of steps for this schema
            SELECT @StepCount = COUNT(*) FROM #CurrentSchemaSteps
            
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''INFO'', ''Found '' + CAST(@StepCount AS NVARCHAR(10)) + '' load steps to process'', GETUTCDATE())
            END
            
            -- Process each step in current schema
            DECLARE step_cursor CURSOR FOR
            SELECT step_name, staging_table, query_sql, tier, step_type
            FROM #CurrentSchemaSteps ORDER BY tier, step_name
            
            OPEN step_cursor
            FETCH NEXT FROM step_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType
            
            SET @ProcessedSteps = 0
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Log entity start for INFO and DEBUG levels only
                IF @LoggingLevel IN (''INFO'', ''DEBUG'')
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting processing for entity: '' + @Entity + '' (Tier: '' + CAST(@Tier AS NVARCHAR(10)) + '')'', GETUTCDATE())
                END
                
                -- Determine primary key
                SET @PrimaryKey = CASE 
                    WHEN CHARINDEX(''_'', @Entity, 1) > 0 THEN ''LNK_ID''
                    ELSE ''HUB_ID''
                END
                
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''INFO'', ''Determined primary key: '' + @PrimaryKey, GETUTCDATE())
                END
                
                -- Get column lists from EntityMappings (consolidated logic)
                SET @SQL = 
                N''SELECT @EntityColumns = entity_columns, @Type2Columns = ISNULL(type2_columns, ''''["'' + @PrimaryKey + ''"]'''')
                FROM core.'' + QUOTENAME(@SchemaName) + ''.EntityMappings
                WHERE entity_name = '''''' + @Entity + ''''''''
                
                EXECUTE sp_executesql @SQL, 
                    N''@EntityColumns NVARCHAR(MAX) OUTPUT, @Type2Columns NVARCHAR(MAX) OUTPUT'',
                    @EntityColumns = @EntityColumnsJSON OUTPUT, @Type2Columns = @Type2List OUTPUT;
                
                -- Parse JSON to column lists
                SET @SQL = ''SELECT @ResultSet = STRING_AGG(QUOTENAME(value), '''','''') FROM OPENJSON(@JsonArray)''
                EXECUTE sp_executesql @SQL, N''@JsonArray NVARCHAR(MAX), @ResultSet NVARCHAR(MAX) OUTPUT'', 
                    @JsonArray = @EntityColumnsJSON, @ResultSet = @ColumnList OUTPUT;
                
                -- Convert Type2List from JSON array to comma-separated string if needed
                IF LEFT(@Type2List, 1) = ''[''
                BEGIN
                    EXECUTE sp_executesql @SQL, N''@JsonArray NVARCHAR(MAX), @ResultSet NVARCHAR(MAX) OUTPUT'', 
                        @JsonArray = @Type2List, @ResultSet = @Type2List OUTPUT;
                END

                IF @PrimaryKey = ''LNK_ID''
                BEGIN
                    SET @ColumnList = ''[LNK_ID],''+@ColumnList
                END
                
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''INFO'', ''Retrieved column mappings - Column List Length: '' + CAST(LEN(@ColumnList) AS NVARCHAR(10)), GETUTCDATE())
                END
                
                -- Step 1: Populate Load Table
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting PopulateLoadTable'', GETUTCDATE())
                END
                
                EXEC @ReturnCode = core.sp_PopulateLoadTable
                    @ENTITY_IN = @Entity,
                    @QUERY_SQL_IN = @QuerySQL, 
                    @PK_COL_IN = @PrimaryKey
                
                IF @ReturnCode = 0
                BEGIN
                    
                    EXEC core.sp_UpdateEntityDeltaParameters
                    @EntityName = @Entity

                    IF @LoggingLevel = ''DEBUG''
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''END'', ''PopulateLoadTable completed successfully'', GETUTCDATE())
                    END
                    
                    -- Step 2: Generate CDC
                    IF @LoggingLevel = ''DEBUG''
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting GenerateCDC'', GETUTCDATE())
                    END
                    
                    EXEC @ReturnCode = [core].[sp_GenerateCDC]
                        @PK_COLUMN_IN = @PrimaryKey,
                        @ENTITY_IN = @Entity,
                        @COLUMN_LIST_IN = @ColumnList,
                        @TYPE2_LIST_IN = @Type2List,
                        @SRC = @SchemaName
                    
                    IF @ReturnCode = 0
                    BEGIN
                        IF @LoggingLevel = ''DEBUG''
                        BEGIN
                            INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                            VALUES (@JobID, @SchemaName, @Entity, ''END'', ''GenerateCDC completed successfully'', GETUTCDATE())
                        END
                        
                        -- Step 3: Process entities based on table type
                        IF @PrimaryKey = ''HUB_ID''
                        BEGIN
                            IF @LoggingLevel = ''DEBUG''
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting ProcessHubSat'', GETUTCDATE())
                            END
                            
                            EXEC @ReturnCode = core.sp_ProcessHubSat
                                @ENTITY_IN = @Entity,
                                @PK_COLUMN_IN = @PrimaryKey,
                                @COLUMN_LIST_IN = @ColumnList
                            
                            IF @ReturnCode = 0
                            BEGIN
                                IF @LoggingLevel = ''DEBUG''
                                BEGIN
                                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessHubSat completed successfully'', GETUTCDATE())
                                END
                            END
                            ELSE
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''ProcessHubSat failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())
                                
                                RAISERROR(''ProcessHubSat failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                            END
                        END

                        IF @PrimaryKey = ''LNK_ID''
                        BEGIN
                            IF @LoggingLevel = ''DEBUG''
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting ProcessLink'', GETUTCDATE())
                            END
                            
                            EXEC @ReturnCode = core.sp_ProcessLink
                                @ENTITY_IN = @Entity,
                                @PK_COLUMN_IN = @PrimaryKey,
                                @COLUMN_LIST_IN = @ColumnList
                            
                            IF @ReturnCode = 0
                            BEGIN
                                IF @LoggingLevel = ''DEBUG''
                                BEGIN
                                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessLink completed successfully'', GETUTCDATE())
                                END
                            END
                            ELSE
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''ProcessLink failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())
                                
                                RAISERROR(''ProcessLink failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                            END
                        END
                    END
                    ELSE
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''GenerateCDC failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())
                        
                        RAISERROR(''GenerateCDC failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                    END
                END
                ELSE
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''PopulateLoadTable failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())
                    
                    RAISERROR(''PopulateLoadTable failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                END
                
                SET @ProcessedSteps = @ProcessedSteps + 1
                
                -- Only log entity completion for DEBUG level
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''Completed processing for entity: '' + @Entity, GETUTCDATE())
                END
                
                FETCH NEXT FROM step_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType
            END
            
            CLOSE step_cursor
            DEALLOCATE step_cursor
            
            SET @ProcessedSchemas = @ProcessedSchemas + 1
            
            -- Only log schema completion for DEBUG level
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''END'', ''Completed processing for schema: '' + @SchemaName + '' (Processed '' + CAST(@ProcessedSteps AS NVARCHAR(10)) + '' steps)'', GETUTCDATE())
            END
            
            FETCH NEXT FROM schema_cursor INTO @SchemaName
        END
        
        CLOSE schema_cursor
        DEALLOCATE schema_cursor
        
        DROP TABLE #SchemasToProcess
        DROP TABLE #CurrentSchemaSteps
        
        -- Process Presentation Layer
        EXEC core.sp_PopulateCalendar @YearsBefore = 2, @YearsAfter = 2

        EXEC @ReturnCode = core.sp_ProcessPresentation
                            
            IF @ReturnCode = 0
            BEGIN

                EXEC core.[sp_InitEntityDeltaParameters]

                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessPresentation completed successfully'', GETUTCDATE())
                END
            END

        -- Update process control record to completed
        UPDATE [core].[CTL_DV_PROCESS] 
        SET [Status] = ''completed'', [EndTS_UTC] = GETUTCDATE()
        WHERE [JobId] = @JobID
        
        -- Always log process completion
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, NULL, NULL, ''END'', ''Data Vault Load process completed successfully. Processed '' + CAST(@ProcessedSchemas AS NVARCHAR(10)) + '' schema(s)'', GETUTCDATE())
        
    END TRY
    BEGIN CATCH
        -- Capture error details
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorMessage = ERROR_MESSAGE()
        
        -- Log the error
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, ISNULL(@SchemaName, ''Unknown''), ISNULL(@Entity, ''Unknown''), ''ERROR'', 
                ''Process failed with error '' + CAST(@ErrorNumber AS NVARCHAR(10)) + '': '' + @ErrorMessage, GETUTCDATE())
        
        -- Update process control record to failed
        UPDATE [core].[CTL_DV_PROCESS] 
        SET [Status] = ''failed'', [EndTS_UTC] = GETUTCDATE()
        WHERE [JobId] = @JobID
        
        -- Clean up cursors if they exist
        IF CURSOR_STATUS(''local'', ''schema_cursor'') >= 0
        BEGIN
            CLOSE schema_cursor
            DEALLOCATE schema_cursor
        END
        
        IF CURSOR_STATUS(''local'', ''step_cursor'') >= 0
        BEGIN
            CLOSE step_cursor
            DEALLOCATE step_cursor
        END
        
        -- Clean up temp tables
        IF OBJECT_ID(''tempdb..#SchemasToProcess'') IS NOT NULL
            DROP TABLE #SchemasToProcess
        IF OBJECT_ID(''tempdb..#CurrentSchemaSteps'') IS NOT NULL
            DROP TABLE #CurrentSchemaSteps
        
        -- Re-raise the error
        RAISERROR(@ErrorMessage, @ErrorNumber, 1)
    END CATCH
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_DataVaultLoad];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_ExecuteQuery
-- Type: PROCEDURE
-- Order: 130
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_ExecuteQuery',
    N'PROCEDURE',
    130,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER   PROCEDURE {SCHEMA}.[sp_ExecuteQuery]
    @SourceQuery NVARCHAR(MAX),
    @TargetTable NVARCHAR(255),
    @ColumnMappingsJson NVARCHAR(MAX),
    @TableType NVARCHAR(50),
    @TimeSeriesTargetColumn NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @TempTable NVARCHAR(255) = ''##TempResults'';
    DECLARE @RowCount INT;
    DECLARE @TempTableSchema NVARCHAR(MAX) = '''';
    DECLARE @SourceColumns NVARCHAR(MAX) = '''';
    DECLARE @TargetColumns NVARCHAR(MAX) = '''';
    DECLARE @TimeSeriesSourceColumn NVARCHAR(255) = NULL;
    DECLARE @MinDate DATETIME2;
    DECLARE @MaxDate DATETIME2;
    
    BEGIN TRY
        -- Drop temp table if it exists from previous run
        IF OBJECT_ID(''tempdb..##TempResults'') IS NOT NULL
        BEGIN
            DROP TABLE ##TempResults;
        END
        
        -- Extract target columns (table_column) from JSON
        SELECT @TargetColumns = STRING_AGG([table_column], '', '')
        FROM OPENJSON(@ColumnMappingsJson)
        WITH (
            table_column NVARCHAR(255) ''$.table_column''
        );
        
        -- Extract source columns (query_column) from JSON
        SELECT @SourceColumns = STRING_AGG([query_column], '', '')
        FROM OPENJSON(@ColumnMappingsJson)
        WITH (
            query_column NVARCHAR(255) ''$.query_column''
        );
        
        -- If Fact table, find the source column that maps to the time series target column
        IF @TableType = ''Fact'' AND @TimeSeriesTargetColumn IS NOT NULL
        BEGIN
            SELECT @TimeSeriesSourceColumn = query_column
            FROM OPENJSON(@ColumnMappingsJson)
            WITH (
                query_column NVARCHAR(255) ''$.query_column'',
                table_column NVARCHAR(255) ''$.table_column''
            )
            WHERE table_column = @TimeSeriesTargetColumn;
            
            IF @TimeSeriesSourceColumn IS NULL
            BEGIN
                RAISERROR(''Time series target column "%s" not found in column mappings'', 16, 1, @TimeSeriesTargetColumn);
            END
        END
        
        -- Get the result set metadata from the source query
        SET @SQL = N''
        SELECT 
            QUOTENAME(name) + '''' '''' + 
            system_type_name + 
            CASE WHEN is_nullable = 1 THEN '''' NULL'''' ELSE '''' NOT NULL'''' END as ColumnDef
        INTO #TempColumnDefs
        FROM sys.dm_exec_describe_first_result_set(N'''''' + 
            REPLACE(@SourceQuery, '''''''', '''''''''''') + '''''', NULL, 0);
        
        SELECT @TempTableSchema = STRING_AGG(ColumnDef, '''', '''')
        FROM #TempColumnDefs;
        
        DROP TABLE #TempColumnDefs;
        '';
        
        EXEC sp_executesql @SQL, 
            N''@TempTableSchema NVARCHAR(MAX) OUTPUT'', 
            @TempTableSchema OUTPUT;
        IF @TableType != ''Staging''
        BEGIN
        -- Step 1: Create temp table with ALL columns from source query
        SET @SQL = N''CREATE TABLE '' + @TempTable + N'' ('' + @TempTableSchema + N'')'';
        EXEC sp_executesql @SQL;
        
        -- Step 2: Insert ALL results from source query into temp table
        SET @SQL = N''INSERT INTO '' + @TempTable + 
                   N'' EXEC sp_executesql N'''''' + 
                   REPLACE(@SourceQuery, '''''''', '''''''''''') + '''''''';
        
        EXEC sp_executesql @SQL;
        END
        -- Step 3: Handle table type specific logic BEFORE inserting to target
        IF @TableType = ''Staging''
        BEGIN
            -- Truncate dimension tables
            PRINT ''Table Type: Staging - Run query directly'';
            EXEC sp_executesql @SourceQuery;
        END
        IF @TableType = ''Dimension''
        BEGIN
            -- Truncate dimension tables
            PRINT ''Table Type: Dimension - Truncating target table'';
            SET @SQL = N''TRUNCATE TABLE '' + @TargetTable;
            EXEC sp_executesql @SQL;
        END
        ELSE IF @TableType = ''Fact'' AND @TimeSeriesTargetColumn IS NOT NULL
        BEGIN
            -- Get min and max dates from temp table
            SET @SQL = N''SELECT @MinDate = MIN('' + QUOTENAME(@TimeSeriesSourceColumn) + N''), '' +
                       N''@MaxDate = MAX('' + QUOTENAME(@TimeSeriesSourceColumn) + N'') '' +
                       N''FROM '' + @TempTable;
            
            EXEC sp_executesql @SQL,
                N''@MinDate DATETIME2 OUTPUT, @MaxDate DATETIME2 OUTPUT'',
                @MinDate OUTPUT,
                @MaxDate OUTPUT;
            
            PRINT ''Table Type: Fact - Deleting from target table'';
            PRINT ''Time Series Column: '' + @TimeSeriesTargetColumn;
            PRINT ''Date Range: '' + ISNULL(CONVERT(VARCHAR, @MinDate, 120), ''NULL'') + 
                  '' to '' + ISNULL(CONVERT(VARCHAR, @MaxDate, 120), ''NULL'');
            
            -- Delete from target table for the date range
            IF @MinDate IS NOT NULL AND @MaxDate IS NOT NULL
            BEGIN
                SET @SQL = N''DELETE FROM '' + @TargetTable + 
                           N'' WHERE '' + QUOTENAME(@TimeSeriesTargetColumn) + 
                           N'' BETWEEN @MinDate AND @MaxDate'';
                
                EXEC sp_executesql @SQL,
                    N''@MinDate DATETIME2, @MaxDate DATETIME2'',
                    @MinDate,
                    @MaxDate;
                
                PRINT ''Deleted '' + CAST(@@ROWCOUNT AS VARCHAR) + '' rows from target table'';
            END
        END
        ELSE IF @TableType = ''Staging''
        BEGIN
            PRINT ''Table Type: Staging - No pre-processing required'';
        END
        
        -- Step 4: Insert ONLY mapped columns from temp table to target
        SET @SQL = N''INSERT INTO '' + @TargetTable + N'' ('' + @TargetColumns + N'') '' +
                   N''SELECT '' + @SourceColumns + N'' FROM '' + @TempTable;
        
        EXEC sp_executesql @SQL;
        
        SET @RowCount = @@ROWCOUNT;
        
        -- Cleanup
        IF OBJECT_ID(''tempdb..##TempResults'') IS NOT NULL
        BEGIN
            DROP TABLE ##TempResults;
        END;
        
        SELECT @RowCount AS RowsInserted, ''Success'' AS Status;
        
    END TRY
    BEGIN CATCH
        -- Cleanup temp table if it exists
        IF OBJECT_ID(''tempdb..##TempResults'') IS NOT NULL
        BEGIN
            DROP TABLE ##TempResults;
        END
        
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine,
            ''Failed'' AS Status;
            
        THROW;
    END CATCH
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_ExecuteQuery];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_ProcessPresentation
-- Type: PROCEDURE
-- Order: 131
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_ProcessPresentation',
    N'PROCEDURE',
    131,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER   PROCEDURE {SCHEMA}.[sp_ProcessPresentation]
    @TierFilter INT = NULL,
    @StopOnError BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Id uniqueidentifier;
    DECLARE @StepName NVARCHAR(255);
    DECLARE @TableName NVARCHAR(255);
    DECLARE @FullTableName NVARCHAR(255);
    DECLARE @QuerySql NVARCHAR(MAX);
    DECLARE @Tier INT;
    DECLARE @TableType NVARCHAR(50);
    DECLARE @ColumnMappings NVARCHAR(MAX);
    DECLARE @TimeSeriesEntity NVARCHAR(255);
    DECLARE @TimeSeriesColumn NVARCHAR(255);
    DECLARE @ErrorMessage NVARCHAR(MAX);
    DECLARE @StartTime DATETIME2;
    DECLARE @EndTime DATETIME2;
    
    CREATE TABLE #ProcessingLog (
        Id uniqueidentifier,
        StepName NVARCHAR(255),
        TableName NVARCHAR(255),
        Tier INT,
        TableType NVARCHAR(50),
        Status NVARCHAR(50),
        RowsProcessed INT,
        StartTime DATETIME2,
        EndTime DATETIME2,
        DurationSeconds DECIMAL(10,2),
        ErrorMessage NVARCHAR(MAX)
    );
    
    DECLARE control_cursor CURSOR FOR
    SELECT 
        [id],
        [step_name],
        [table_name],
        [query_sql],
        [tier],
        [table_type],
        [column_mappings],
        [time_series_entity],
        [time_series_target_column]
    FROM [core].[core].[PresentationControl]
    WHERE [exclude] = 0
        AND (@TierFilter IS NULL OR [tier] = @TierFilter)
    ORDER BY [tier], [priority], [id];
    
    OPEN control_cursor;
    
    FETCH NEXT FROM control_cursor INTO 
        @Id, @StepName, @TableName, @QuerySql, @Tier, @TableType, 
        @ColumnMappings, @TimeSeriesEntity, @TimeSeriesColumn;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @StartTime = GETDATE();
        SET @ErrorMessage = NULL;
        
        BEGIN TRY
            -- Apply schema prefix based on table type
            IF @TableType = ''Staging''
                SET @FullTableName = ''[stage].'' + @TableName;
            ELSE
                SET @FullTableName = ''[presentation].'' + @TableName;
            
            PRINT ''---------------------------------------------------'';
            PRINT ''Processing: '' + @StepName + '' (Tier '' + CAST(@Tier AS VARCHAR) + '', Type: '' + @TableType + '')'';
            PRINT ''Table: '' + @FullTableName;
            IF @TableType = ''Fact'' AND @TimeSeriesColumn IS NOT NULL
                PRINT ''Time Series Column: '' + @TimeSeriesColumn;
            
            -- Execute the query
            EXEC [core].[sp_ExecuteQuery]
                @SourceQuery = @QuerySql,
                @TargetTable = @FullTableName,
                @ColumnMappingsJson = @ColumnMappings,
                @TableType = @TableType,
                @TimeSeriesTargetColumn = @TimeSeriesColumn;
            
            SET @EndTime = GETDATE();
            
            INSERT INTO #ProcessingLog (
                Id, StepName, TableName, Tier, TableType, 
                Status, RowsProcessed, StartTime, EndTime, 
                DurationSeconds, ErrorMessage
            )
            VALUES (
                @Id, @StepName, @FullTableName, @Tier, @TableType,
                ''Success'', @@ROWCOUNT, @StartTime, @EndTime,
                DATEDIFF(SECOND, @StartTime, @EndTime), NULL
            );
            
            PRINT ''Status: Success'';
            PRINT ''Duration: '' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + '' seconds'';
            
        END TRY
        BEGIN CATCH
            SET @EndTime = GETDATE();
            SET @ErrorMessage = ERROR_MESSAGE();
            
            INSERT INTO #ProcessingLog (
                Id, StepName, TableName, Tier, TableType,
                Status, RowsProcessed, StartTime, EndTime,
                DurationSeconds, ErrorMessage
            )
            VALUES (
                @Id, @StepName, @FullTableName, @Tier, @TableType,
                ''Failed'', 0, @StartTime, @EndTime,
                DATEDIFF(SECOND, @StartTime, @EndTime), @ErrorMessage
            );
            
            PRINT ''Status: Failed'';
            PRINT ''Error: '' + @ErrorMessage;
            
            IF @StopOnError = 1
                BREAK;
        END CATCH
        
        FETCH NEXT FROM control_cursor INTO 
            @Id, @StepName, @TableName, @QuerySql, @Tier, @TableType,
            @ColumnMappings, @TimeSeriesEntity, @TimeSeriesColumn;
    END
    
    CLOSE control_cursor;
    DEALLOCATE control_cursor;
    
    -- Summary
    PRINT ''==================================================='';
    PRINT ''PROCESSING SUMMARY'';
    PRINT ''==================================================='';
    
    SELECT 
        Tier,
        TableType,
        COUNT(*) AS TotalSteps,
        SUM(CASE WHEN Status = ''Success'' THEN 1 ELSE 0 END) AS Successful,
        SUM(CASE WHEN Status = ''Failed'' THEN 1 ELSE 0 END) AS Failed,
        SUM(RowsProcessed) AS TotalRowsProcessed,
        SUM(DurationSeconds) AS TotalDurationSeconds
    FROM #ProcessingLog
    GROUP BY Tier, TableType
    ORDER BY Tier, TableType;
    
    SELECT * FROM #ProcessingLog ORDER BY Tier, StartTime;
    
    DROP TABLE #ProcessingLog;
END;',
    N'DROP PROCEDURE {SCHEMA}.[sp_ProcessPresentation];',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_PopulateCalendar
-- Type: PROCEDURE
-- Order: 132
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_PopulateCalendar',
    N'PROCEDURE',
    132,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.sp_PopulateCalendar
    @YearsBefore INT = 2,
    @YearsAfter INT = 2
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Clear existing data
    TRUNCATE TABLE presentation.CALENDAR;
    
    -- Populate the calendar dimension
    ;WITH DateRange AS (
        -- Generate date range based on parameters
        SELECT CAST(DATEADD(YEAR, -@YearsBefore, GETDATE()) AS DATE) AS Date
        UNION ALL
        SELECT DATEADD(DAY, 1, Date)
        FROM DateRange
        WHERE Date < CAST(DATEADD(YEAR, @YearsAfter, GETDATE()) AS DATE)
    ),
    EasterCalc AS (
        -- Calculate Easter Sunday components using Computus algorithm
        SELECT DISTINCT
            YEAR(Date) AS Year,
            YEAR(Date) % 19 AS a,
            YEAR(Date) / 100 AS b,
            YEAR(Date) % 100 AS c
        FROM DateRange
    ),
    EasterDates AS (
        SELECT 
            Year,
            DATEFROMPARTS(
                Year,
                ((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30 + 
                 (c / 4) * 2 + (b / 4) * 2 - (c % 4) - 
                 ((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30) - 
                 7 * ((a + 11 * ((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30) + 
                       22 * ((c / 4) * 2 + (b / 4) * 2 - (c % 4) - 
                       ((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30))) / 451) + 114) / 31,
                (((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30 + 
                  (c / 4) * 2 + (b / 4) * 2 - (c % 4) - 
                  ((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30) - 
                  7 * ((a + 11 * ((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30) + 
                        22 * ((c / 4) * 2 + (b / 4) * 2 - (c % 4) - 
                        ((19 * a + b - (b / 4) - ((b - ((b + 8) / 25) + 1) / 3) + 15) % 30))) / 451) + 114) % 31) + 1
            ) AS EasterSunday
        FROM EasterCalc
    )
    INSERT INTO presentation.CALENDAR (
        Date, Year, Quarter, Month, MonthName, Week,
        DayOfYear, DayOfMonth, DayOfWeek, DayName,
        IsWeekend, IsWeekday, SameDayLastWeek, SameDayLastYear,
        IsHoliday_GB, IsHoliday_FR, IsHoliday_DE, IsHoliday_IT, IsHoliday_ES,
        IsHoliday_NL, IsHoliday_BE, IsHoliday_SE, IsHoliday_NO, IsHoliday_DK,
        IsHoliday_FI, IsHoliday_PL, IsHoliday_IE,
        IsHoliday_US, IsHoliday_CA, IsHoliday_MX, IsHoliday_BR, IsHoliday_AR
    )
    SELECT 
        d.[Date],
        YEAR(d.[Date]) AS Year,
        DATEPART(QUARTER, d.[Date]) AS Quarter,
        MONTH(d.[Date]) AS Month,
        DATENAME(MONTH, d.[Date]) AS MonthName,
        DATEPART(WEEK, d.[Date]) AS Week,
        DATEPART(DAYOFYEAR, d.[Date]) AS DayOfYear,
        DAY(d.[Date]) AS DayOfMonth,
        DATEPART(WEEKDAY, d.[Date]) AS DayOfWeek,
        DATENAME(WEEKDAY, d.[Date]) AS DayName,
        CASE WHEN DATEPART(WEEKDAY, d.[Date]) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend,
        CASE WHEN DATEPART(WEEKDAY, d.[Date]) BETWEEN 2 AND 6 THEN 1 ELSE 0 END AS IsWeekday,
        DATEADD(DAY, -7, d.[Date]) AS SameDayLastWeek,
        DATEADD(YEAR, -1, d.[Date]) AS SameDayLastYear,
        
        -- UNITED KINGDOM Holidays
        CASE WHEN 
            (MONTH(d.[Date]) = 1 AND DAY(d.[Date]) = 1) OR
            (d.[Date] = DATEADD(DAY, -2, e.EasterSunday)) OR -- Good Friday
            (d.[Date] = DATEADD(DAY, 1, e.EasterSunday)) OR -- Easter Monday
            (MONTH(d.[Date]) = 5 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) <= 7) OR -- Early May Bank Holiday
            (MONTH(d.[Date]) = 5 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) >= 25) OR -- Spring Bank Holiday
            (MONTH(d.[Date]) = 8 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) >= 25) OR -- Summer Bank Holiday
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 25) OR
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 26)
        THEN 1 ELSE 0 END AS IsHoliday_GB,
        
        -- FRANCE Holidays
        CASE WHEN 
            (MONTH(d.[Date]) = 1 AND DAY(d.[Date]) = 1) OR
            (d.[Date] = DATEADD(DAY, 1, e.EasterSunday)) OR -- Easter Monday
            (MONTH(d.[Date]) = 5 AND DAY(d.[Date]) = 1) OR -- Labour Day
            (MONTH(d.[Date]) = 5 AND DAY(d.[Date]) = 8) OR -- Victory in Europe Day
            (d.[Date] = DATEADD(DAY, 39, e.EasterSunday)) OR -- Ascension Day
            (d.[Date] = DATEADD(DAY, 50, e.EasterSunday)) OR -- Whit Monday
            (MONTH(d.[Date]) = 7 AND DAY(d.[Date]) = 14) OR -- Bastille Day
            (MONTH(d.[Date]) = 8 AND DAY(d.[Date]) = 15) OR -- Assumption of Mary
            (MONTH(d.[Date]) = 11 AND DAY(d.[Date]) = 1) OR -- All Saints'' Day
            (MONTH(d.[Date]) = 11 AND DAY(d.[Date]) = 11) OR -- Armistice Day
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 25)
        THEN 1 ELSE 0 END AS IsHoliday_FR,
        
        -- GERMANY Holidays
        CASE WHEN 
            (MONTH(d.[Date]) = 1 AND DAY(d.[Date]) = 1) OR
            (d.[Date] = DATEADD(DAY, -2, e.EasterSunday)) OR -- Good Friday
            (d.[Date] = DATEADD(DAY, 1, e.EasterSunday)) OR -- Easter Monday
            (MONTH(d.[Date]) = 5 AND DAY(d.[Date]) = 1) OR -- Labour Day
            (d.[Date] = DATEADD(DAY, 39, e.EasterSunday)) OR -- Ascension Day
            (d.[Date] = DATEADD(DAY, 50, e.EasterSunday)) OR -- Whit Monday
            (MONTH(d.[Date]) = 10 AND DAY(d.[Date]) = 3) OR -- German Unity Day
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 25) OR
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 26)
        THEN 1 ELSE 0 END AS IsHoliday_DE,
        
        -- ITALY Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_IT,
        
        -- SPAIN Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_ES,
        
        -- NETHERLANDS Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_NL,
        
        -- BELGIUM Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_BE,
        
        -- SWEDEN Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_SE,
        
        -- NORWAY Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_NO,
        
        -- DENMARK Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_DK,
        
        -- FINLAND Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_FI,
        
        -- POLAND Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_PL,
        
        -- IRELAND Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_IE,
        
        -- UNITED STATES Holidays
        CASE WHEN 
            (MONTH(d.[Date]) = 1 AND DAY(d.[Date]) = 1) OR -- New Year''s Day
            (MONTH(d.[Date]) = 1 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) BETWEEN 15 AND 21) OR -- MLK Day
            (MONTH(d.[Date]) = 2 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) BETWEEN 15 AND 21) OR -- Presidents'' Day
            (MONTH(d.[Date]) = 5 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) >= 25) OR -- Memorial Day
            (MONTH(d.[Date]) = 7 AND DAY(d.[Date]) = 4) OR -- Independence Day
            (MONTH(d.[Date]) = 9 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) <= 7) OR -- Labor Day
            (MONTH(d.[Date]) = 10 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) BETWEEN 8 AND 14) OR -- Columbus Day
            (MONTH(d.[Date]) = 11 AND DAY(d.[Date]) = 11) OR -- Veterans Day
            (MONTH(d.[Date]) = 11 AND DATENAME(WEEKDAY, d.[Date]) = ''Thursday'' AND DAY(d.[Date]) BETWEEN 22 AND 28) OR -- Thanksgiving
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 25) -- Christmas
        THEN 1 ELSE 0 END AS IsHoliday_US,
        
        -- CANADA Holidays
        CASE WHEN 
            (MONTH(d.[Date]) = 1 AND DAY(d.[Date]) = 1) OR
            (d.[Date] = DATEADD(DAY, -2, e.EasterSunday)) OR -- Good Friday
            (d.[Date] = DATEADD(DAY, 1, e.EasterSunday)) OR -- Easter Monday
            (MONTH(d.[Date]) = 5 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) BETWEEN 18 AND 24) OR -- Victoria Day
            (MONTH(d.[Date]) = 7 AND DAY(d.[Date]) = 1) OR -- Canada Day
            (MONTH(d.[Date]) = 9 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) <= 7) OR -- Labour Day
            (MONTH(d.[Date]) = 10 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) BETWEEN 8 AND 14) OR -- Thanksgiving
            (MONTH(d.[Date]) = 11 AND DAY(d.[Date]) = 11) OR -- Remembrance Day
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 25) OR
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 26)
        THEN 1 ELSE 0 END AS IsHoliday_CA,
        
        -- MEXICO Holidays
        CASE WHEN 
            (MONTH(d.[Date]) = 1 AND DAY(d.[Date]) = 1) OR
            (MONTH(d.[Date]) = 2 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) <= 7) OR -- Constitution Day
            (MONTH(d.[Date]) = 3 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) BETWEEN 15 AND 21) OR -- Benito Juárez''s Birthday
            (MONTH(d.[Date]) = 5 AND DAY(d.[Date]) = 1) OR -- Labour Day
            (MONTH(d.[Date]) = 9 AND DAY(d.[Date]) = 16) OR -- Independence Day
            (MONTH(d.[Date]) = 11 AND DATENAME(WEEKDAY, d.[Date]) = ''Monday'' AND DAY(d.[Date]) BETWEEN 15 AND 21) OR -- Revolution Day
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 25)
        THEN 1 ELSE 0 END AS IsHoliday_MX,
        
        -- BRAZIL Holidays
        CASE WHEN 
            (MONTH(d.[Date]) = 1 AND DAY(d.[Date]) = 1) OR
            (d.[Date] = DATEADD(DAY, -47, e.EasterSunday)) OR -- Carnival
            (d.[Date] = DATEADD(DAY, -2, e.EasterSunday)) OR -- Good Friday
            (MONTH(d.[Date]) = 4 AND DAY(d.[Date]) = 21) OR -- Tiradentes'' Day
            (MONTH(d.[Date]) = 5 AND DAY(d.[Date]) = 1) OR -- Labour Day
            (d.[Date] = DATEADD(DAY, 60, e.EasterSunday)) OR -- Corpus Christi
            (MONTH(d.[Date]) = 9 AND DAY(d.[Date]) = 7) OR -- Independence Day
            (MONTH(d.[Date]) = 10 AND DAY(d.[Date]) = 12) OR -- Our Lady of Aparecida
            (MONTH(d.[Date]) = 11 AND DAY(d.[Date]) = 2) OR -- All Souls'' Day
            (MONTH(d.[Date]) = 11 AND DAY(d.[Date]) = 15) OR -- Republic Day
            (MONTH(d.[Date]) = 12 AND DAY(d.[Date]) = 25)
        THEN 1 ELSE 0 END AS IsHoliday_BR,
        
        -- ARGENTINA Holidays (placeholder - add specific holidays)
        0 AS IsHoliday_AR
        
    FROM DateRange d
    LEFT JOIN EasterDates e ON YEAR(d.[Date]) = e.Year
    OPTION (MAXRECURSION 0);
    
    -- Return row count
    SELECT @@ROWCOUNT AS RowsInserted;
END',
    N'DROP PROCEDURE {SCHEMA}.sp_PopulateCalendar',
    1,
    GETDATE()
);


-- ============================================
-- Object: sp_ProcessStagingDuplicates
-- Type: PROCEDURE
-- Order: 133
-- ============================================
INSERT INTO [core].[DeploymentObjects]
    (ObjectName, ObjectType, ExecutionOrder, Category, Description,
     CreationScript, DropScript, IsActive, CreatedDate)
VALUES (
    N'sp_ProcessStagingDuplicates',
    N'PROCEDURE',
    133,
    N'Data Vault Procedures',
    NULL,
    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_ProcessStagingDuplicates]
    @SchemaName NVARCHAR(128) = ''dbo''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @TableName NVARCHAR(128);
    DECLARE @FullTableName NVARCHAR(400);
    DECLARE @ColumnList NVARCHAR(MAX);
    DECLARE @DeletedRows INT;
    DECLARE @TotalDeleted INT = 0;
    
    -- Clean up cursor if it exists from previous failed run
    IF CURSOR_STATUS(''global'', ''table_cursor'') >= -1
    BEGIN
        CLOSE table_cursor;
        DEALLOCATE table_cursor;
    END
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Cursor for tables prefixed with DL_
        DECLARE table_cursor CURSOR FOR
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = @SchemaName
            AND TABLE_TYPE = ''BASE TABLE''
            AND TABLE_NAME LIKE ''DL_%''
        ORDER BY TABLE_NAME;
        
        OPEN table_cursor;
        FETCH NEXT FROM table_cursor INTO @TableName;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @FullTableName = QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName);
            
            -- Build column list (exclude computed columns, LOADTS_UTC, and RequestID)
            SELECT @ColumnList = STRING_AGG(QUOTENAME(COLUMN_NAME), '', '')
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = @SchemaName
                AND TABLE_NAME = @TableName
                AND COLUMNPROPERTY(OBJECT_ID(QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName)), COLUMN_NAME, ''IsComputed'') = 0
                AND COLUMN_NAME NOT IN (''LOADTS_UTC'', ''RequestID'');
            
            -- Skip if no valid columns
            IF @ColumnList IS NULL OR LEN(@ColumnList) = 0
            BEGIN
                FETCH NEXT FROM table_cursor INTO @TableName;
                CONTINUE;
            END
            
            -- Delete duplicates, keeping one row per group
            SET @SQL = ''
                WITH DuplicateCTE AS (
                    SELECT *,
                           ROW_NUMBER() OVER (
                               PARTITION BY '' + @ColumnList + ''
                               ORDER BY (SELECT NULL)
                           ) as RowNum
                    FROM '' + @FullTableName + ''
                )
                DELETE FROM DuplicateCTE
                WHERE RowNum > 1;
                
                SELECT @Deleted = @@ROWCOUNT;'';
            
            EXEC sp_executesql @SQL, N''@Deleted INT OUTPUT'', @Deleted = @DeletedRows OUTPUT;
            
            IF @DeletedRows > 0
            BEGIN
                SET @TotalDeleted = @TotalDeleted + @DeletedRows;
                PRINT @FullTableName + '': Deleted '' + CAST(@DeletedRows AS NVARCHAR(10)) + '' duplicate rows'';
            END
            
            FETCH NEXT FROM table_cursor INTO @TableName;
        END
        
        CLOSE table_cursor;
        DEALLOCATE table_cursor;
        
        COMMIT TRANSACTION;
        
        PRINT '''';
        PRINT ''Total duplicate rows deleted: '' + CAST(@TotalDeleted AS NVARCHAR(10));
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT ''Error occurred! Transaction rolled back.'';
        PRINT ''Error: '' + @ErrorMessage;
        
        IF CURSOR_STATUS(''local'', ''table_cursor'') >= 0
        BEGIN
            CLOSE table_cursor;
            DEALLOCATE table_cursor;
        END
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END',
    NULL,
    1,
    GETDATE()
);


-- ============================================
-- End of Export
-- ============================================