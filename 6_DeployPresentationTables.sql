USE [core]
GO

/****** Object:  StoredProcedure [core].[DeployPresentationTables]    Script Date: 25/09/2025 00:32:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [core].[DeployPresentationTables]
    @DatabaseName NVARCHAR(128),
    @DryRun BIT = 0,
    @ContinueOnError BIT = 1,
    @LogResults BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declare variables
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @CurrentTableId UNIQUEIDENTIFIER;
    DECLARE @CurrentTableName NVARCHAR(255);
    DECLARE @CurrentSchemaName NVARCHAR(255);
    DECLARE @CurrentDDLScript NVARCHAR(MAX);
    DECLARE @CurrentTableType NVARCHAR(100);
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @ProcessedCount INT = 0;
    DECLARE @SuccessCount INT = 0;
    DECLARE @ErrorCount INT = 0;
    DECLARE @StartTime DATETIME2 = GETDATE();
    
    -- Validate input parameters
    IF @DatabaseName IS NULL OR LTRIM(RTRIM(@DatabaseName)) = ''
    BEGIN
        RAISERROR('Database name cannot be null or empty', 16, 1);
        RETURN;
    END
    
    -- Check if database exists
    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
    BEGIN
        RAISERROR('Database "%s" does not exist', 16, 1, @DatabaseName);
        RETURN;
    END
    
    -- Create temporary table for logging results
    CREATE TABLE #ProcessingLog (
        Id UNIQUEIDENTIFIER,
        TableName NVARCHAR(255),
        SchemaName NVARCHAR(255),
        TableType NVARCHAR(100),
        ProcessedAt DATETIME2,
        Status NVARCHAR(50),
        ErrorMessage NVARCHAR(4000)
    );
    
    -- Log start of processing
    IF @LogResults = 1
    BEGIN
        PRINT 'Starting processing of presentation tables for database: ' + @DatabaseName;
        PRINT 'Dry Run Mode: ' + CASE WHEN @DryRun = 1 THEN 'ON' ELSE 'OFF' END;
        PRINT 'Continue On Error: ' + CASE WHEN @ContinueOnError = 1 THEN 'ON' ELSE 'OFF' END;
        PRINT 'Start Time: ' + CONVERT(NVARCHAR(30), @StartTime, 121);
        PRINT REPLICATE('-', 80);
    END
    
    -- Declare cursor for sequential processing
    DECLARE table_cursor CURSOR FOR
    SELECT 
        id,
        table_name,
        schema_name,
        ddl_script,
        table_type
    FROM core.PresentationTables
    WHERE status = 'Live'
        AND ddl_script IS NOT NULL
        AND LTRIM(RTRIM(ddl_script)) <> ''
    ORDER BY 
        schema_name,
        table_name;
    
    -- Open cursor and begin processing
    OPEN table_cursor;
    
    FETCH NEXT FROM table_cursor INTO 
        @CurrentTableId, 
        @CurrentTableName, 
        @CurrentSchemaName, 
        @CurrentDDLScript,
        @CurrentTableType;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ProcessedCount = @ProcessedCount + 1;
        
        BEGIN TRY
            -- Log current table being processed
            IF @LogResults = 1
            BEGIN
                PRINT 'Processing Table ' + CAST(@ProcessedCount AS NVARCHAR(10)) + 
                      ': [' + @CurrentSchemaName + '].[' + @CurrentTableName + '] (' + @CurrentTableType + ')';
            END
            
            -- Prepare dynamic SQL to execute in target database
            SET @SQL = 'USE [' + @DatabaseName + ']; ' + CHAR(13) + CHAR(10);
            
            -- Check if schema exists, create if it doesn't
            SET @SQL = @SQL + 
                'IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + @CurrentSchemaName + ''') ' + CHAR(13) + CHAR(10) +
                'BEGIN ' + CHAR(13) + CHAR(10) +
                '    EXEC(''CREATE SCHEMA [' + @CurrentSchemaName + ']''); ' + CHAR(13) + CHAR(10) +
                'END; ' + CHAR(13) + CHAR(10);
            
            -- Check if table already exists and drop it (optional - you may want to modify this behavior)
            SET @SQL = @SQL + 
                'IF EXISTS (SELECT 1 FROM sys.tables t ' + CHAR(13) + CHAR(10) +
                '           INNER JOIN sys.schemas s ON t.schema_id = s.schema_id ' + CHAR(13) + CHAR(10) +
                '           WHERE s.name = ''' + @CurrentSchemaName + ''' AND t.name = ''' + @CurrentTableName + ''') ' + CHAR(13) + CHAR(10) +
                'BEGIN ' + CHAR(13) + CHAR(10) +
                '    DROP TABLE [' + @CurrentSchemaName + '].[' + @CurrentTableName + ']; ' + CHAR(13) + CHAR(10) +
                'END; ' + CHAR(13) + CHAR(10);
            
            -- Add the DDL script
            SET @SQL = @SQL + @CurrentDDLScript;
            
            -- Execute if not in dry run mode
            IF @DryRun = 0
            BEGIN
                EXEC sp_executesql @SQL;
            END
            ELSE
            BEGIN
                -- In dry run mode, just validate the SQL syntax
                IF @LogResults = 1
                BEGIN
                    PRINT '  [DRY RUN] Would execute: ';
                    PRINT '  ' + LEFT(@CurrentDDLScript, 100) + '...';
                END
            END
            
            -- Log success
            INSERT INTO #ProcessingLog (Id, TableName, SchemaName, TableType, ProcessedAt, Status, ErrorMessage)
            VALUES (@CurrentTableId, @CurrentTableName, @CurrentSchemaName, @CurrentTableType, GETDATE(), 'SUCCESS', NULL);
            
            SET @SuccessCount = @SuccessCount + 1;
            
            IF @LogResults = 1
            BEGIN
                PRINT '  ✓ SUCCESS';
            END
            
        END TRY
        BEGIN CATCH
            -- Capture error details
            SELECT 
                @ErrorMessage = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState = ERROR_STATE();
            
            -- Log error
            INSERT INTO #ProcessingLog (Id, TableName, SchemaName, TableType, ProcessedAt, Status, ErrorMessage)
            VALUES (@CurrentTableId, @CurrentTableName, @CurrentSchemaName, @CurrentTableType, GETDATE(), 'ERROR', @ErrorMessage);
            
            SET @ErrorCount = @ErrorCount + 1;
            
            IF @LogResults = 1
            BEGIN
                PRINT '  ✗ ERROR: ' + @ErrorMessage;
            END
            
            -- Decide whether to continue or stop
            IF @ContinueOnError = 0
            BEGIN
                CLOSE table_cursor;
                DEALLOCATE table_cursor;
                
                -- Return error details
                RAISERROR('Processing stopped due to error in table [%s].[%s]: %s', 16, 1, 
                    @CurrentSchemaName, @CurrentTableName, @ErrorMessage);
                RETURN;
            END
        END CATCH
        
        -- Move to next record
        FETCH NEXT FROM table_cursor INTO 
            @CurrentTableId, 
            @CurrentTableName, 
            @CurrentSchemaName, 
            @CurrentDDLScript,
            @CurrentTableType;
    END
    
    -- Clean up cursor
    CLOSE table_cursor;
    DEALLOCATE table_cursor;
    
    -- Final summary
    DECLARE @EndTime DATETIME2 = GETDATE();
    DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);
    
    IF @LogResults = 1
    BEGIN
        PRINT REPLICATE('-', 80);
        PRINT 'Processing completed for database: ' + @DatabaseName;
        PRINT 'Total tables processed: ' + CAST(@ProcessedCount AS NVARCHAR(10));
        PRINT 'Successful: ' + CAST(@SuccessCount AS NVARCHAR(10));
        PRINT 'Errors: ' + CAST(@ErrorCount AS NVARCHAR(10));
        PRINT 'Duration: ' + CAST(@Duration AS NVARCHAR(10)) + ' seconds';
        PRINT 'End Time: ' + CONVERT(NVARCHAR(30), @EndTime, 121);
        
        -- Show detailed error log if there were errors
        IF @ErrorCount > 0
        BEGIN
            PRINT '';
            PRINT 'Error Details:';
            PRINT REPLICATE('-', 40);
            
            SELECT 
                TableName,
                SchemaName,
                ErrorMessage
            FROM #ProcessingLog
            WHERE Status = 'ERROR'
            ORDER BY ProcessedAt;
        END
    END
    
    -- Return summary as result set
    SELECT 
        @DatabaseName AS DatabaseName,
        @ProcessedCount AS TotalProcessed,
        @SuccessCount AS SuccessCount,
        @ErrorCount AS ErrorCount,
        @Duration AS DurationSeconds,
        @StartTime AS StartTime,
        @EndTime AS EndTime,
        CASE WHEN @ErrorCount = 0 THEN 'COMPLETED SUCCESSFULLY' 
             ELSE 'COMPLETED WITH ERRORS' END AS OverallStatus;
    
    -- Optional: Return detailed log
    IF @LogResults = 1
    BEGIN
        SELECT * FROM #ProcessingLog ORDER BY ProcessedAt;
    END
    
    -- Clean up
    DROP TABLE #ProcessingLog;
    
END
GO

