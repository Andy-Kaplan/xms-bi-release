/*
=====================================================================================
Table Creation Stored Procedure Template
=====================================================================================
Template for creating multiple tables in any database/schema combination.
Includes comprehensive logging, error handling, and validation.

Usage:
EXEC [core].[sp_CreateIntegrationTables] 
    @DatabaseName = 'core',
    @SchemaName = 'core';

=====================================================================================
*/

USE [core]  -- Or your central management database
GO

CREATE OR ALTER PROCEDURE [core].[sp_CreateIntegrationTables]
    @DatabaseName NVARCHAR(128),
    @SchemaName NVARCHAR(128) = 'core',
    @DropExisting BIT = 0,
    @CreateIndexes BIT = 1,
    @CreateConstraints BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for deployment tracking
    DECLARE @StartTime DATETIME2 = GETDATE();
    DECLARE @StepCount INT = 0;
    DECLARE @ErrorCount INT = 0;
    DECLARE @SQL NVARCHAR(MAX);
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
    
    PRINT '?? SECTION 1: VALIDATION AND SETUP';
    PRINT '???????????????????????????????????????????????????????????????????????????????????';
    
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
            PRINT ''  ? Created schema: ' + @SchemaName + N''';
        END
        ELSE
            PRINT ''  ? Schema already exists: ' + @SchemaName + N''';
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
    -- SECTION 3: CREATE TABLES
    -- =====================================================================================
    
    PRINT '???  SECTION 3: CREATE TABLES';
    PRINT '???????????????????????????????????????????????????????????????????????????????????';
    
    -- Table 1: StagingControl
    BEGIN TRY
        SET @SQL = N'
        USE ' + QUOTENAME(@DatabaseName) + N';
        
        IF NOT EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''StagingControl'')
        BEGIN
            CREATE TABLE ' + QUOTENAME(@SchemaName) + N'.[StagingControl] (
                id uniqueidentifier NOT NULL DEFAULT NEWID(),
                step_name VARCHAR(255) NOT NULL,
                staging_table VARCHAR(255) NOT NULL,
                query_sql TEXT NOT NULL,
                tier INTEGER NOT NULL,
                step_type VARCHAR(255),
                exclude BIT DEFAULT 0,
                description TEXT,
                depends_on_steps TEXT,
                retry_count INTEGER DEFAULT 3,
                timeout_minutes INTEGER DEFAULT 30,
                created_at DATETIME DEFAULT GETDATE(),
                updated_at DATETIME DEFAULT GETDATE()
            );
        END
        ELSE
            PRINT ''  ??  StagingControl table already exists'';
        ';
        EXEC sp_executesql @SQL;
        
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
        USE ' + QUOTENAME(@DatabaseName) + N';
        
        IF NOT EXISTS (SELECT 1 FROM sys.tables t 
                       INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
                       WHERE s.name = ''' + @SchemaName + N''' AND t.name = ''EntityMappings'')
        BEGIN
            CREATE TABLE ' + QUOTENAME(@SchemaName) + N'.[EntityMappings] (
                id uniqueidentifier NOT NULL DEFAULT NEWID(),
                entity_name VARCHAR(255) NOT NULL,
                source_table VARCHAR(255) NOT NULL,
                source_columns TEXT,
                entity_columns TEXT,
                type2_columns TEXT,
                cdc_exclude_columns TEXT,
                date_filter_column VARCHAR(255),
                exclude_conditions TEXT,
                track_deletions BIT DEFAULT 0,
                created_at DATETIME DEFAULT GETDATE(),
                updated_at DATETIME DEFAULT GETDATE(),
                is_active BIT DEFAULT 1
            );
        END
        ELSE
            PRINT ''  ??  EntityMappings table already exists'';
        ';
        EXEC sp_executesql @SQL;
        
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
    PRINT '?????????????????????????????????????????????????????????????????????????????????';
    SELECT 
        FORMAT(StepNumber, '00') + '. ' + StepName as Step,
        Status,
        FORMAT(ExecutionTime, 'HH:mm:ss') as [Time],
        ISNULL(ErrorMessage, '') as Error
    FROM #DeploymentLog
    ORDER BY StepNumber;
    
    -- Final status
    IF @ErrorCount = 0
        PRINT '?? TABLE CREATION DEPLOYMENT COMPLETED SUCCESSFULLY!';
    ELSE
        PRINT '??  DEPLOYMENT COMPLETED WITH ' + CAST(@ErrorCount AS VARCHAR) + ' ERROR(S)';
    
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
-- EXEC [dbo].[sp_CreateTables] @DatabaseName = 'MyDatabase', @SchemaName = 'dbo', @DropExisting = 0;