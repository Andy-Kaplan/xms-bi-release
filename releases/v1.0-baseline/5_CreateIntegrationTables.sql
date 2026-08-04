-- ============================================
-- 5_CreateIntegrationTables.sql
-- Regenerated from UAT 2026-07-06 15:17:16
-- Server: xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net
-- ============================================

-- ============================================
-- SQL_STORED_PROCEDURE : [core].[sp_CreateIntegrationTables]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[sp_CreateIntegrationTables]
    @DatabaseName NVARCHAR(128),
    @SchemaName NVARCHAR(128) = 'core',
    @DropExisting BIT = 0,
    @CreateIndexes BIT = 0,
    @CreateConstraints BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for deployment tracking
    DECLARE @StartTime DATETIME2 = GETDATE();
    DECLARE @StepCount INT = 0;
    DECLARE @ErrorCount INT = 0;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @metasql NVARCHAR(MAX);
    DECLARE @ErrorMessage NVARCHAR(MAX);
    DECLARE @TableCount INT = 0;
    
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
    PRINT 'TABLE CREATION DEPLOYMENT';
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
        IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + @SchemaName + N''')
        BEGIN
            EXEC(''CREATE SCHEMA [' + @SchemaName + N']'');
            PRINT ''  ✓ Created schema: ' + @SchemaName + N''';
        END
        ELSE
            PRINT ''  ✓ Schema already exists: ' + @SchemaName + N''';
        ';
        SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
        EXEC (@metasql);
        
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
            -- Drop tables in reverse dependency order
            IF EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''EntityMappings'')
            BEGIN
                DROP TABLE ' + QUOTENAME(@SchemaName) + N'.[EntityMappings];
                PRINT ''  ✓ Dropped EntityMappings table'';
            END
            
            IF EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''StagingControl'')
            BEGIN
                DROP TABLE ' + QUOTENAME(@SchemaName) + N'.[StagingControl];
                PRINT ''  ✓ Dropped StagingControl table'';
            END
            ';
            SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
            EXEC (@metasql);
            
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
    -- SECTION 3: CREATE TABLES
    -- =====================================================================================
    
    PRINT '🏗️  SECTION 3: CREATE TABLES';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    -- Table 1: StagingControl
    BEGIN TRY
        SET @SQL = N'
        IF NOT EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''StagingControl'')
        BEGIN
            CREATE TABLE ' + QUOTENAME(@SchemaName) + N'.[StagingControl] (
                id uniqueidentifier NOT NULL DEFAULT NEWID(),
                step_name VARCHAR(255) NOT NULL,
                staging_table VARCHAR(255) NOT NULL,
                staging_columns VARCHAR(MAX) NOT NULL,
                query_sql NVARCHAR(MAX) NOT NULL,
                tier INTEGER NOT NULL,
                step_type VARCHAR(255),
                exclude BIT DEFAULT 0,
                description NVARCHAR(MAX),
                depends_on_steps NVARCHAR(MAX),
                retry_count INTEGER DEFAULT 3,
                timeout_minutes INTEGER DEFAULT 30,
                created_at DATETIME DEFAULT GETDATE(),
                updated_at DATETIME DEFAULT GETDATE()
            );
            PRINT ''  ✓ Created StagingControl table'';
        END
        ELSE
            PRINT ''  ℹ️  StagingControl table already exists'';
        ';
        SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
        EXEC (@metasql);
        
        SET @StepName = 'StagingControl Table Creation';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'StagingControl Table Creation';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH
    
    -- Table 2: EntityMappings
    BEGIN TRY
        SET @SQL = N'
        IF NOT EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''EntityMappings'')
        BEGIN
            CREATE TABLE ' + QUOTENAME(@SchemaName) + N'.[EntityMappings] (
                id uniqueidentifier NOT NULL DEFAULT NEWID(),
                entity_name VARCHAR(255) NOT NULL,
                source_table VARCHAR(255) NOT NULL,
                source_columns NVARCHAR(MAX),
                entity_columns NVARCHAR(MAX),
                type2_columns NVARCHAR(MAX),
                cdc_exclude_columns NVARCHAR(MAX),
                date_filter_column VARCHAR(255),
                exclude_conditions NVARCHAR(MAX),
                track_deletions BIT DEFAULT 0,
                split_by_source BIT DEFAULT 0,
                created_at DATETIME DEFAULT GETDATE(),
                updated_at DATETIME DEFAULT GETDATE(),
                is_active BIT DEFAULT 1
            );
            PRINT ''  ✓ Created EntityMappings table'';
        END
        ELSE
            PRINT ''  ℹ️  EntityMappings table already exists'';
        ';
        SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
        EXEC (@metasql);
        
        SET @StepName = 'EntityMappings Table Creation';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'EntityMappings Table Creation';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH

    -- Table 3: GlobalParameters
    BEGIN TRY
        SET @SQL = N'
        IF NOT EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''GlobalParameters'')
        BEGIN
            CREATE TABLE ' + QUOTENAME(@SchemaName) + N'.[GlobalParameters] (
                [ParameterID] [int] IDENTITY(1,1) NOT NULL,
	            [ParameterKey] [nvarchar](200) NOT NULL,
	            [ParameterValue] [nvarchar](max) NULL,
	            [DataType] [varchar](20) NOT NULL,
	            [Category] [nvarchar](100) NULL,
	            [Description] [nvarchar](1000) NULL,
	            [IsActive] [bit] NOT NULL,
	            [CreatedBy] [nvarchar](200) NOT NULL,
	            [CreatedDate] [datetime2](7) NOT NULL,
	            [ModifiedBy] [nvarchar](200) NULL,
	            [ModifiedDate] [datetime2](7) NULL,
	            [Version] [int] NOT NULL
            );
            PRINT ''  ✓ Created GlobalParameters table'';
        END
        ELSE
            PRINT ''  ℹ️  GlobalParameters table already exists'';
        ';
        SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
        EXEC (@metasql);
        
        SET @StepName = 'GlobalParameters Table Creation';
        SET @Status = 'SUCCESS';
        SET @ErrorMsg = NULL;
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        
    END TRY
    BEGIN CATCH
        SET @StepName = 'GlobalParameters Table Creation';
        SET @Status = 'ERROR';
        SET @ErrorMsg = ERROR_MESSAGE();
        EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
    END CATCH

    -- =====================================================================================
    -- SECTION 4: CREATE INDEXES (IF REQUESTED)
    -- =====================================================================================
    
    IF @CreateIndexes = 1
    BEGIN
        PRINT '📊 SECTION 4: CREATE INDEXES';
        PRINT '───────────────────────────────────────────────────────────────────────────────────';
        
        -- Indexes for StagingControl
        BEGIN TRY
            SET @SQL = N'
            -- Index on tier for execution order queries
            IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(''' + @SchemaName + N'.StagingControl'') AND name = ''IX_StagingControl_Tier'')
            BEGIN
                CREATE NONCLUSTERED INDEX [IX_StagingControl_Tier] 
                ON ' + QUOTENAME(@SchemaName) + N'.[StagingControl] ([tier], [exclude]) 
                INCLUDE ([step_name], [staging_table]);
                PRINT ''  ✓ Created IX_StagingControl_Tier index'';
            END
            
            -- Index on step_name for lookups
            IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(''' + @SchemaName + N'.StagingControl'') AND name = ''IX_StagingControl_StepName'')
            BEGIN
                CREATE NONCLUSTERED INDEX [IX_StagingControl_StepName] 
                ON ' + QUOTENAME(@SchemaName) + N'.[StagingControl] ([step_name]) 
                WHERE [exclude] = 0;
                PRINT ''  ✓ Created IX_StagingControl_StepName index'';
            END
            ';
            SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
            EXEC (@metasql);
            
            SET @StepName = 'StagingControl Indexes';
            SET @Status = 'SUCCESS';
            SET @ErrorMsg = NULL;
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
            
        END TRY
        BEGIN CATCH
            SET @StepName = 'StagingControl Indexes';
            SET @Status = 'ERROR';
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        END CATCH
        
        -- Indexes for EntityMappings
        BEGIN TRY
            SET @SQL = N'
            -- Index on entity_name for lookups
            IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(''' + @SchemaName + N'.EntityMappings'') AND name = ''IX_EntityMappings_EntityName'')
            BEGIN
                CREATE NONCLUSTERED INDEX [IX_EntityMappings_EntityName] 
                ON ' + QUOTENAME(@SchemaName) + N'.[EntityMappings] ([entity_name]) 
                WHERE [is_active] = 1;
                PRINT ''  ✓ Created IX_EntityMappings_EntityName index'';
            END
            
            -- Index on source_table for lookups
            IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(''' + @SchemaName + N'.EntityMappings'') AND name = ''IX_EntityMappings_SourceTable'')
            BEGIN
                CREATE NONCLUSTERED INDEX [IX_EntityMappings_SourceTable] 
                ON ' + QUOTENAME(@SchemaName) + N'.[EntityMappings] ([source_table], [is_active]);
                PRINT ''  ✓ Created IX_EntityMappings_SourceTable index'';
            END
            ';
            SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
            EXEC (@metasql);
            
            SET @StepName = 'EntityMappings Indexes';
            SET @Status = 'SUCCESS';
            SET @ErrorMsg = NULL;
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
            
        END TRY
        BEGIN CATCH
            SET @StepName = 'EntityMappings Indexes';
            SET @Status = 'ERROR';
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC sp_executesql @LogStep, N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @StepName NVARCHAR(100), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', @StepCount OUTPUT, @ErrorCount OUTPUT, @StepName, @Status, @ErrorMsg;
        END CATCH
        
        PRINT '';
    END
    
    -- =====================================================================================
    -- DEPLOYMENT SUMMARY
    -- =====================================================================================
    
    DECLARE @EndTime DATETIME2 = GETDATE();
    DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);
    
    PRINT '';
    PRINT '=====================================================================================';
    PRINT 'TABLE CREATION DEPLOYMENT SUMMARY';
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
    
    -- Final status
    IF @ErrorCount = 0
        PRINT '🎉 TABLE CREATION DEPLOYMENT COMPLETED SUCCESSFULLY!';
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


