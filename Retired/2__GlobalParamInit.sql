/*
=====================================================================================
Global Parameters System Deployment Stored Procedure
=====================================================================================
Creates a comprehensive GlobalParameters table and helper functions in any database/schema.
Provides a centralized parameter management system with type safety and versioning.

Usage:
EXEC [core].[sp_CreateGlobalParametersTools] 
    @DatabaseName = 'MyDatabase',
    @SchemaName = 'dbo',
    @IncludeSampleData = 1;

Features:
- GlobalParameters table with versioning and auditing
- Type-safe parameter storage (STRING, INT, DECIMAL, BOOLEAN, DATE, DATETIME, JSON)
- Helper functions for parameter retrieval
- Stored procedure for parameter management
- Optional sample data insertion
=====================================================================================
*/

USE [core]  -- Or your central management database
GO

CREATE OR ALTER PROCEDURE [core].[sp_CreateGlobalParametersTools]
    @DatabaseName NVARCHAR(128),
    @SchemaName NVARCHAR(128) = 'core',
    @IncludeSampleData BIT = 1,
    @DropExisting BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for deployment tracking
    DECLARE @StartTime DATETIME2 = GETDATE();
    DECLARE @StepCount INT = 0;
    DECLARE @ErrorCount INT = 0;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ErrorMessage NVARCHAR(MAX);
    
    -- Create temp table for logging
    CREATE TABLE #DeploymentLog (
        StepNumber INT,
        StepName NVARCHAR(100),
        Status NVARCHAR(20),
        ExecutionTime DATETIME2,
        ErrorMessage NVARCHAR(MAX)
    );
    
    -- Helper procedure for logging
    DECLARE @LogStep NVARCHAR(MAX) = N'
        SET @StepCount = @StepCount + 1;
        INSERT INTO #DeploymentLog VALUES (@StepCount, @StepName, @Status, GETDATE(), @ErrorMsg);
        PRINT FORMAT(GETDATE(), ''HH:mm:ss'') + '' | '' + @Status + '' | '' + @StepName;
        IF @ErrorMsg IS NOT NULL PRINT ''           ERROR: '' + @ErrorMsg;
        IF @Status = ''ERROR'' SET @ErrorCount = @ErrorCount + 1;
    ';
    
    PRINT '=====================================================================================';
    PRINT 'GLOBAL PARAMETERS SYSTEM DEPLOYMENT';
    PRINT 'Target Database: ' + @DatabaseName;
    PRINT 'Target Schema: ' + @SchemaName;
    PRINT 'Started: ' + FORMAT(@StartTime, 'yyyy-MM-dd HH:mm:ss');
    PRINT '=====================================================================================';
    PRINT '';
    
    -- =====================================================================================
    -- SECTION 1: VALIDATION AND SETUP
    -- =====================================================================================
    
    PRINT '📋 SECTION 1: VALIDATION AND SETUP';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    BEGIN TRY
        -- Validate database exists
        IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
        BEGIN
            DECLARE @StepName NVARCHAR(100) = 'Database Validation';
            DECLARE @Status NVARCHAR(20) = 'ERROR'; 
            DECLARE @ErrorMsg NVARCHAR(MAX) = 'Database does not exist';
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
            RETURN;
        END
        
        SET @StepName = 'Database Validation';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
        -- Create schema if it doesn't exist
        SET @SQL = N'
        USE ' + QUOTENAME(@DatabaseName) + N';
        IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + @SchemaName + N''')
        BEGIN
            EXEC(''CREATE SCHEMA [' + @SchemaName + N']'');
            PRINT ''  ✓ Created schema: ' + @SchemaName + N''';
        END
        ELSE
            PRINT ''  ✓ Schema already exists: ' + @SchemaName + N''';
        ';
        EXEC sp_executesql @SQL;
        
        SET @StepName = 'Schema Setup';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'Validation and Setup';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    PRINT '';
    
    -- =====================================================================================
    -- SECTION 2: DROP EXISTING OBJECTS (IF REQUESTED)
    -- =====================================================================================
    
    IF @DropExisting = 1
    BEGIN
        PRINT '🗑️  SECTION 2: DROPPING EXISTING OBJECTS';
        PRINT '───────────────────────────────────────────────────────────────────────────────────';
        
        BEGIN TRY
            SET @SQL = N'
            USE ' + QUOTENAME(@DatabaseName) + N';
            
            -- Drop procedures
            IF OBJECT_ID(''' + @SchemaName + N'.SetParameter'') IS NOT NULL
            BEGIN
                DROP PROCEDURE ' + QUOTENAME(@SchemaName) + N'.[SetParameter];
                PRINT ''  ✓ Dropped SetParameter procedure'';
            END
            
            -- Drop functions
            IF OBJECT_ID(''' + @SchemaName + N'.GetTypedParameter'') IS NOT NULL
            BEGIN
                DROP FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetTypedParameter];
                PRINT ''  ✓ Dropped GetTypedParameter function'';
            END
            
            IF OBJECT_ID(''' + @SchemaName + N'.GetParameterDataType'') IS NOT NULL
            BEGIN
                DROP FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetParameterDataType];
                PRINT ''  ✓ Dropped GetParameterDataType function'';
            END
            
            IF OBJECT_ID(''' + @SchemaName + N'.GetParameterWithType'') IS NOT NULL
            BEGIN
                DROP FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetParameterWithType];
                PRINT ''  ✓ Dropped GetParameterWithType function'';
            END
            
            IF OBJECT_ID(''' + @SchemaName + N'.GetParameter'') IS NOT NULL
            BEGIN
                DROP FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetParameter];
                PRINT ''  ✓ Dropped GetParameter function'';
            END
            
            -- Drop table
            IF EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''GlobalParameters'')
            BEGIN
                DROP TABLE ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters];
                PRINT ''  ✓ Dropped GlobalParameters table'';
            END
            ';
            EXEC sp_executesql @SQL;
            
            SET @StepName = 'Drop Existing Objects';
            SET @Status = 'SUCCESS';
            SET @ErrorMsg = NULL;
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
            
        END TRY
        BEGIN CATCH
            SET @StepName = 'Drop Existing Objects';
            SET @Status = 'ERROR';
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        END CATCH
        
        PRINT '';
    END
    
    -- =====================================================================================
    -- SECTION 3: CREATE TABLE AND INDEXES
    -- =====================================================================================
    
    PRINT '🏗️  SECTION 3: CREATE TABLE AND INDEXES';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    BEGIN TRY
        -- Create GlobalParameters table
        SET @SQL = N'
        USE ' + QUOTENAME(@DatabaseName) + N';
        
        CREATE TABLE ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters] (
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
            
            CONSTRAINT [PK_' + @SchemaName + N'_GlobalParameters] PRIMARY KEY CLUSTERED ([ParameterID]),
            CONSTRAINT [UK_' + @SchemaName + N'_GlobalParameters_Key] UNIQUE NONCLUSTERED ([ParameterKey]),
            CONSTRAINT [CK_' + @SchemaName + N'_GlobalParameters_DataType] CHECK ([DataType] IN (''STRING'', ''INT'', ''DECIMAL'', ''BOOLEAN'', ''DATE'', ''DATETIME'', ''JSON''))
        );
        
        PRINT ''  ✓ Created GlobalParameters table'';
        ';
        EXEC sp_executesql @SQL;
        
        -- Create indexes
        SET @SQL = N'
        USE ' + QUOTENAME(@DatabaseName) + N';
        
        CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + N'_GlobalParameters_Category] 
        ON ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters] ([Category]) 
        WHERE [IsActive] = 1;
        
        CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + N'_GlobalParameters_Active] 
        ON ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters] ([IsActive]) 
        INCLUDE ([ParameterKey], [ParameterValue], [DataType]);
        
        PRINT ''  ✓ Created indexes'';
        ';
        EXEC sp_executesql @SQL;
        
        SET @StepName = 'Table and Indexes Creation';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'Table and Indexes Creation';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    PRINT '';
    
    -- =====================================================================================
    -- SECTION 4: CREATE FUNCTIONS
    -- =====================================================================================
    
    PRINT '⚙️  SECTION 4: CREATE FUNCTIONS';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    -- Function 1: GetParameter
    BEGIN TRY
        SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + N';';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'
        CREATE FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetParameter]
        (
            @ParameterKey nvarchar(100)
        )
        RETURNS nvarchar(4000)
        AS
        BEGIN
            DECLARE @Value nvarchar(4000);
            
            SELECT @Value = [ParameterValue]
            FROM ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters]
            WHERE [ParameterKey] = @ParameterKey 
              AND [IsActive] = 1;
            
            RETURN @Value;
        END;
        ';
        EXEC sp_executesql @SQL;
        PRINT '  ✓ Created GetParameter function';
        
        SET @StepName = 'GetParameter Function';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'GetParameter Function';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    -- Function 2: GetParameterWithType
    BEGIN TRY
        SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + N';';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'
        CREATE FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetParameterWithType]
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
            FROM ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters]
            WHERE [ParameterKey] = @ParameterKey 
              AND [IsActive] = 1
        );
        ';
        EXEC sp_executesql @SQL;
        PRINT '  ✓ Created GetParameterWithType function';
        
        SET @StepName = 'GetParameterWithType Function';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'GetParameterWithType Function';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    -- Function 3: GetParameterDataType
    BEGIN TRY
        SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + N';';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'
        CREATE FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetParameterDataType]
        (
            @ParameterKey nvarchar(100)
        )
        RETURNS varchar(20)
        AS
        BEGIN
            DECLARE @DataType varchar(20);
            
            SELECT @DataType = [DataType]
            FROM ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters]
            WHERE [ParameterKey] = @ParameterKey 
              AND [IsActive] = 1;
            
            RETURN @DataType;
        END;
        ';
        EXEC sp_executesql @SQL;
        PRINT '  ✓ Created GetParameterDataType function';
        
        SET @StepName = 'GetParameterDataType Function';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'GetParameterDataType Function';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    -- Function 4: GetTypedParameter
    BEGIN TRY
        SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + N';';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'
        CREATE FUNCTION ' + QUOTENAME(@SchemaName) + N'.[GetTypedParameter]
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
            FROM ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters]
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
        END;
        ';
        EXEC sp_executesql @SQL;
        PRINT '  ✓ Created GetTypedParameter function';
        
        SET @StepName = 'GetTypedParameter Function';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'GetTypedParameter Function';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    PRINT '';
    
    -- =====================================================================================
    -- SECTION 5: CREATE STORED PROCEDURES
    -- =====================================================================================
    
    PRINT '📝 SECTION 5: CREATE STORED PROCEDURES';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    BEGIN TRY
        SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + N';';
        EXEC sp_executesql @SQL;
        
        SET @SQL = N'
        CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + N'.[SetParameter]
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
            IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters] WHERE [ParameterKey] = @ParameterKey)
            BEGIN
                UPDATE ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters]
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
                INSERT INTO ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters] 
                ([ParameterKey], [ParameterValue], [DataType], [Category], [Description])
                VALUES 
                (@ParameterKey, @ParameterValue, @DataType, @Category, @Description);
                
                PRINT ''Parameter created: '' + @ParameterKey;
            END
        END;
        ';
        EXEC sp_executesql @SQL;
        PRINT '  ✓ Created SetParameter procedure';
        
        SET @StepName = 'SetParameter Procedure';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'SetParameter Procedure';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    PRINT '';
    
    -- =====================================================================================
    -- SECTION 6: INSERT SAMPLE DATA (IF REQUESTED)
    -- =====================================================================================
    
    IF @IncludeSampleData = 1
    BEGIN
        PRINT '📊 SECTION 6: INSERT SAMPLE DATA';
        PRINT '───────────────────────────────────────────────────────────────────────────────────';
        
        BEGIN TRY
            SET @SQL = N'
            USE ' + QUOTENAME(@DatabaseName) + N';
            
            EXEC ' + QUOTENAME(@SchemaName) + N'.[SetParameter] 
                @ParameterKey = ''APP_VERSION'', 
                @ParameterValue = ''1.0.0'', 
                @DataType = ''STRING'', 
                @Category = ''Application'',
                @Description = ''Current application version'';
            
            EXEC ' + QUOTENAME(@SchemaName) + N'.[SetParameter] 
                @ParameterKey = ''MAX_RETRY_ATTEMPTS'', 
                @ParameterValue = ''3'', 
                @DataType = ''INT'', 
                @Category = ''Configuration'',
                @Description = ''Maximum number of retry attempts'';
            
            EXEC ' + QUOTENAME(@SchemaName) + N'.[SetParameter] 
                @ParameterKey = ''MAINTENANCE_MODE'', 
                @ParameterValue = ''false'', 
                @DataType = ''BOOLEAN'', 
                @Category = ''System'',
                @Description = ''Whether the system is in maintenance mode'';
            
            EXEC ' + QUOTENAME(@SchemaName) + N'.[SetParameter] 
                @ParameterKey = ''DEFAULT_TIMEOUT'', 
                @ParameterValue = ''30.5'', 
                @DataType = ''DECIMAL'', 
                @Category = ''Configuration'',
                @Description = ''Default timeout in seconds'';
            
            EXEC ' + QUOTENAME(@SchemaName) + N'.[SetParameter] 
                @ParameterKey = ''LAST_MAINTENANCE_DATE'', 
                @ParameterValue = ''' + FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + N''', 
                @DataType = ''DATETIME'', 
                @Category = ''System'',
                @Description = ''Last maintenance date and time'';
            
            PRINT ''  ✓ Sample parameters inserted'';
            ';
            EXEC sp_executesql @SQL;
            
            SET @StepName = 'Sample Data Insertion';
            SET @Status = 'SUCCESS';
            SET @ErrorMsg = NULL;
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
            
        END TRY
        BEGIN CATCH
            SET @StepName = 'Sample Data Insertion';
            SET @Status = 'ERROR';
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        END CATCH
        
        PRINT '';
    END
    
    -- =====================================================================================
    -- SECTION 7: VALIDATION AND SUMMARY
    -- =====================================================================================
    
    PRINT '✅ SECTION 7: VALIDATION AND SUMMARY';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    BEGIN TRY
        -- Validate deployment
        SET @SQL = N'
        USE ' + QUOTENAME(@DatabaseName) + N';
        
        DECLARE @TableExists BIT = 0;
        DECLARE @FunctionCount INT = 0;
        DECLARE @ProcedureCount INT = 0;
        DECLARE @ParameterCount INT = 0;
        
        -- Check table exists
        IF EXISTS (SELECT 1 FROM sys.tables t 
                   INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                   WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''GlobalParameters'')
            SET @TableExists = 1;
        
        -- Count functions
        SELECT @FunctionCount = COUNT(*) 
        FROM sys.objects o
        INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
        WHERE s.name = ''' + @SchemaName + N''' 
          AND o.type IN (''FN'', ''IF'', ''TF'')
          AND o.name LIKE ''Get%Parameter%'';
        
        -- Count procedures
        SELECT @ProcedureCount = COUNT(*) 
        FROM sys.objects o
        INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
        WHERE s.name = ''' + @SchemaName + N''' 
          AND o.type = ''P''
          AND o.name = ''SetParameter'';
        
        -- Count parameters (if sample data was inserted)
        IF EXISTS (SELECT 1 FROM sys.tables t 
                   INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                   WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''GlobalParameters'')
        BEGIN
            SELECT @ParameterCount = COUNT(*) FROM ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters];
        END
        
        PRINT ''  📊 Deployment Statistics:'';
        PRINT ''     GlobalParameters Table: '' + CASE WHEN @TableExists = 1 THEN ''✓ Created'' ELSE ''❌ Missing'' END;
        PRINT ''     Functions: '' + CAST(@FunctionCount AS VARCHAR) + '' created'';
        PRINT ''     Procedures: '' + CAST(@ProcedureCount AS VARCHAR) + '' created'';
        PRINT ''     Sample Parameters: '' + CAST(@ParameterCount AS VARCHAR) + '' inserted'';
        ';
        EXEC sp_executesql @SQL;
        
        SET @StepName = 'Final Validation';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'Final Validation';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    -- =====================================================================================
    -- DEPLOYMENT SUMMARY
    -- =====================================================================================
    
    DECLARE @EndTime DATETIME2 = GETDATE();
    DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);
    
    PRINT '';
    PRINT '=====================================================================================';
    PRINT 'GLOBAL PARAMETERS SYSTEM DEPLOYMENT SUMMARY';
    PRINT '=====================================================================================';
    PRINT 'Database: ' + @DatabaseName;
    PRINT 'Schema: ' + @SchemaName;
    PRINT 'Started: ' + FORMAT(@StartTime, 'yyyy-MM-dd HH:mm:ss');
    PRINT 'Completed: ' + FORMAT(@EndTime, 'yyyy-MM-dd HH:mm:ss');
    PRINT 'Duration: ' + CAST(@Duration AS VARCHAR) + ' seconds';
    PRINT 'Steps Executed: ' + CAST(@StepCount AS VARCHAR);
    PRINT 'Errors: ' + CAST(@ErrorCount AS VARCHAR);
    PRINT '';
    
    -- Show detailed log
    PRINT 'DETAILED LOG:';
    PRINT '─────────────────────────────────────────────────────────────────────────────────';
    SELECT 
        FORMAT(StepNumber, '00') + '. ' + StepName as Step,
        Status,
        FORMAT(ExecutionTime, 'HH:mm:ss') as [Time],
        ISNULL(ErrorMessage, '') as Error
    FROM #DeploymentLog
    ORDER BY StepNumber;
    
    PRINT '';
    PRINT 'USAGE EXAMPLES:';
    PRINT '─────────────────────────────────────────────────────────────────────────────────';
    PRINT 'Get a parameter value:';
    PRINT '  SELECT ' + @SchemaName + '.GetParameter(''APP_VERSION'');';
    PRINT '';
    PRINT 'Get typed parameter value:';
    PRINT '  SELECT ' + @SchemaName + '.GetTypedParameter(''MAX_RETRY_ATTEMPTS'');';
    PRINT '';
    PRINT 'Set a new parameter:';
    PRINT '  EXEC ' + @SchemaName + '.SetParameter @ParameterKey=''MY_PARAM'', @ParameterValue=''MyValue'';';
    PRINT '';
    PRINT 'View all parameters:';
    PRINT '  SELECT * FROM ' + @SchemaName + '.GlobalParameters WHERE IsActive = 1;';
    
    -- Final status
    IF @ErrorCount = 0
        PRINT '🎉 GLOBAL PARAMETERS SYSTEM DEPLOYMENT COMPLETED SUCCESSFULLY!';
    ELSE
        PRINT '⚠️  DEPLOYMENT COMPLETED WITH ' + CAST(@ErrorCount AS VARCHAR) + ' ERROR(S)';
    
    PRINT '=====================================================================================';
    
    -- Cleanup
    DROP TABLE #DeploymentLog;
    
    -- Return success/failure
    IF @ErrorCount = 0
        RETURN 0;
    ELSE
        RETURN 1;
END
GO



-- Example usage:
-- EXEC [core].[sp_CreateGlobalParametersTools] @DatabaseName = 'core', @SchemaName = 'dbo', @IncludeSampleData = 1;