-- =============================================
-- Organisation-DRIVEN DATABASE CREATION SYSTEM
-- Creates Organisation table where new Organisation records trigger database creation
-- =============================================

-- =============================================
-- SCRIPT PARAMETERS - MODIFY THESE VALUES
-- =============================================
DECLARE @DatabaseName NVARCHAR(128) = 'core';           -- Target database name
DECLARE @SchemaName NVARCHAR(128) = 'core';             -- Target schema name

-- =============================================
-- VALIDATION AND SETUP
-- =============================================
DECLARE @SQL NVARCHAR(MAX);

-- Validate database exists
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
BEGIN
    RAISERROR('Database [%s] does not exist.', 16, 1, @DatabaseName);
    RETURN;
END

PRINT '=============================================';
PRINT 'Creating Organisation-Driven Database Management System in: [' + @DatabaseName + '].[' + @SchemaName + ']';
PRINT '=============================================';

-- =============================================
-- SWITCH TO TARGET DATABASE
-- =============================================
SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + ';';
EXEC sp_executesql @SQL;

-- =============================================
-- CREATE SCHEMA IF IT DOESN'T EXIST
-- =============================================
SET @SQL = N'
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + @SchemaName + ''')
BEGIN
    EXEC(''CREATE SCHEMA ' + QUOTENAME(@SchemaName) + ''');
    PRINT ''Schema [' + @SchemaName + '] created.'';
END
ELSE
BEGIN
    PRINT ''Schema [' + @SchemaName + '] already exists.'';
END';

EXEC sp_executesql @SQL;

-- =============================================
-- DROP EXISTING OBJECTS IF THEY EXIST
-- =============================================
SET @SQL = N'
-- Drop triggers first
IF OBJECT_ID(''' + @SchemaName + '.trg_CreateOrganisationDatabase'') IS NOT NULL
    DROP TRIGGER ' + QUOTENAME(@SchemaName) + '.[trg_CreateOrganisationDatabase];

-- Drop procedures
IF OBJECT_ID(''' + @SchemaName + '.CreateOrganisationDatabase'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[CreateOrganisationDatabase];

IF OBJECT_ID(''' + @SchemaName + '.AddOrganisation'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[AddOrganisation];

IF OBJECT_ID(''' + @SchemaName + '.GetOrganisations'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetOrganisations];

IF OBJECT_ID(''' + @SchemaName + '.UpdateOrganisationStatus'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[UpdateOrganisationStatus];

IF OBJECT_ID(''' + @SchemaName + '.SyncDatabaseStatus'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[SyncDatabaseStatus];

-- Drop table
IF EXISTS (SELECT 1 FROM sys.tables t 
           INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
           WHERE s.name = ''' + @SchemaName + ''' AND t.name = ''Organisations'')
BEGIN
    DROP TABLE ' + QUOTENAME(@SchemaName) + '.[Organisations];
    PRINT ''Existing Organisation management objects dropped.'';
END';

EXEC sp_executesql @SQL;

-- =============================================
-- CREATE Organisation TABLE
-- =============================================
SET @SQL = N'
CREATE TABLE ' + QUOTENAME(@SchemaName) + '.[Organisations] (
    [OrganisationID] int IDENTITY(1,1) NOT NULL,
    [OrganisationCode] uniqueidentifier NOT NULL DEFAULT NEWID(),
    [OrganisationName] nvarchar(200) NOT NULL,
    [DatabaseName] nvarchar(128) NULL, -- Calculated field
    [DatabaseStatus] varchar(20) NOT NULL DEFAULT ''PENDING'',
    [DatabaseCreationRequested] bit NOT NULL DEFAULT 0,
    [DatabaseCreated] bit NOT NULL DEFAULT 0,
    [IsActive] bit NOT NULL DEFAULT 1,
    [CreatedBy] nvarchar(100) NOT NULL DEFAULT SYSTEM_USER,
    [CreatedDate] datetime2 NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] nvarchar(100) NULL,
    [ModifiedDate] datetime2 NULL,
    [DatabaseCreatedDate] datetime2 NULL,
    [Notes] nvarchar(1000) NULL,
    
    CONSTRAINT [PK_' + @SchemaName + '_Organisations] PRIMARY KEY CLUSTERED ([OrganisationID]),
    CONSTRAINT [UK_' + @SchemaName + '_Organisations_Code] UNIQUE NONCLUSTERED ([OrganisationCode]),
    CONSTRAINT [UK_' + @SchemaName + '_Organisations_Database] UNIQUE NONCLUSTERED ([DatabaseName]),
    CONSTRAINT [CK_' + @SchemaName + '_Organisations_Status] CHECK ([DatabaseStatus] IN (''PENDING'', ''CREATING'', ''ACTIVE'', ''FAILED'', ''INACTIVE'', ''MAINTENANCE'', ''ARCHIVED''))
);';

EXEC sp_executesql @SQL;

-- =============================================
-- CREATE INDEXES
-- =============================================
SET @SQL = N'
CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + '_Organisations_Active] 
ON ' + QUOTENAME(@SchemaName) + '.[Organisations] ([IsActive]) 
INCLUDE ([OrganisationCode], [OrganisationName], [DatabaseName], [DatabaseStatus]);

CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + '_Organisations_Status] 
ON ' + QUOTENAME(@SchemaName) + '.[Organisations] ([DatabaseStatus]) 
WHERE [IsActive] = 1;

CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + '_Organisations_CreationPending] 
ON ' + QUOTENAME(@SchemaName) + '.[Organisations] ([DatabaseCreationRequested], [DatabaseCreated]) 
WHERE [IsActive] = 1 AND [DatabaseCreated] = 0;';

EXEC sp_executesql @SQL;

PRINT 'Organisation table and indexes created successfully.';

-- =============================================
-- CREATE STORED PROCEDURES
-- =============================================

-- Procedure 1: CreateOrganisationDatabase
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[CreateOrganisationDatabase]
    @OrganisationCode uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DatabaseName nvarchar(128);
    DECLARE @OrganisationName nvarchar(200);
    DECLARE @SQL nvarchar(max);
    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @OrganisationCodeStr nvarchar(36);
    
    -- Convert GUID to string once for reuse
    SET @OrganisationCodeStr = CONVERT(nvarchar(36), @OrganisationCode);
    
    -- Get Organisation details
    SELECT 
        @DatabaseName = @OrganisationCodeStr + ''XMSBI'',
        @OrganisationName = [OrganisationName]
    FROM ' + QUOTENAME(@SchemaName) + '.[Organisations]
    WHERE [OrganisationCode] = @OrganisationCode AND [IsActive] = 1;
    
    IF @DatabaseName IS NULL
    BEGIN
        RAISERROR(''Organisation with code %s not found or inactive.'', 16, 1, @OrganisationCodeStr);
        RETURN;
    END
    
    -- Check if database already exists
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
    BEGIN
        PRINT ''Database '' + @DatabaseName + '' already exists. Skipping creation.'';
        -- Update status to ACTIVE since DB exists
        UPDATE ' + QUOTENAME(@SchemaName) + '.[Organisations]
        SET [DatabaseStatus] = ''ACTIVE'',
            [DatabaseCreated] = 1,
            [DatabaseCreatedDate] = GETDATE(),
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationCode] = @OrganisationCode;
        RETURN;
    END
    
    -- Update status to CREATING
    UPDATE ' + QUOTENAME(@SchemaName) + '.[Organisations]
    SET [DatabaseStatus] = ''CREATING'',
        [DatabaseName] = @DatabaseName,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [OrganisationCode] = @OrganisationCode;
    
    BEGIN TRY
        -- Create the database
        PRINT ''Creating database: '' + @DatabaseName;
        SET @SQL = ''CREATE DATABASE '' + QUOTENAME(@DatabaseName);
        EXEC sp_executesql @SQL;
        
        -- Set up initial database schema/objects
        SET @SQL = ''
        USE '' + QUOTENAME(@DatabaseName) + '';
        
        -- Create a basic Organisation info table in the new database
        CREATE TABLE [dbo].[OrganisationInfo] (
            [OrganisationCode] uniqueidentifier PRIMARY KEY,
            [OrganisationName] nvarchar(200) NOT NULL,
            [DatabaseCreated] datetime2 NOT NULL DEFAULT GETDATE(),
            [Version] nvarchar(20) NOT NULL DEFAULT ''''1.0.0''''
        );
        
        -- Insert Organisation information
        INSERT INTO [dbo].[OrganisationInfo] ([OrganisationCode], [OrganisationName])
        VALUES ('''''' + @OrganisationCodeStr + '''''', '''''' + @OrganisationName + '''''');
        '';
        
        EXEC sp_executesql @SQL;
        
        -- Update Organisation record to success
        UPDATE ' + QUOTENAME(@SchemaName) + '.[Organisations]
        SET [DatabaseStatus] = ''ACTIVE'',
            [DatabaseCreated] = 1,
            [DatabaseCreatedDate] = GETDATE(),
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationCode] = @OrganisationCode;
        
        PRINT ''Database created successfully: '' + @DatabaseName;
        
    END TRY
    BEGIN CATCH
        -- Update status to FAILED
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ' + QUOTENAME(@SchemaName) + '.[Organisations]
        SET [DatabaseStatus] = ''FAILED'',
            [Notes] = ''Database creation failed: '' + @ErrorMessage,
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationCode] = @OrganisationCode;
        
        PRINT ''Database creation failed: '' + @ErrorMessage;
        RAISERROR(''Failed to create database %s: %s'', 16, 1, @DatabaseName, @ErrorMessage);
    END CATCH
END;';

EXEC sp_executesql @SQL;
PRINT 'CreateOrganisationDatabase procedure created.';

-- Procedure 2: AddOrganisation
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[AddOrganisation]
    @OrganisationName nvarchar(200),
    @OrganisationCode uniqueidentifier = NULL,
    @CreateDatabaseImmediately bit = 1,
    @Notes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewOrganisationCode uniqueidentifier;
    DECLARE @DatabaseName nvarchar(128);
    DECLARE @OrganisationCodeStr nvarchar(36);
    
    -- Generate GUID if not provided
    IF @OrganisationCode IS NULL
        SET @OrganisationCode = NEWID();
    
    SET @NewOrganisationCode = @OrganisationCode;
    SET @OrganisationCodeStr = CONVERT(nvarchar(36), @OrganisationCode);
    SET @DatabaseName = @OrganisationCodeStr + ''XMSBI'';
    
    -- Check if Organisation already exists
    IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@SchemaName) + '.[Organisations] WHERE [OrganisationCode] = @OrganisationCode)
    BEGIN
        RAISERROR(''Organisation with code %s already exists.'', 16, 1, @OrganisationCodeStr);
        RETURN;
    END
    
    -- Insert Organisation record
    INSERT INTO ' + QUOTENAME(@SchemaName) + '.[Organisations] 
    ([OrganisationCode], [OrganisationName], [DatabaseName], [DatabaseCreationRequested], [Notes])
    VALUES 
    (@OrganisationCode, @OrganisationName, @DatabaseName, @CreateDatabaseImmediately, @Notes);
    
    PRINT ''Organisation added: '' + @OrganisationName + '' (Code: '' + @OrganisationCodeStr + '')'';
    PRINT ''Database will be: '' + @DatabaseName;
    
    -- Create database immediately if requested
    IF @CreateDatabaseImmediately = 1
    BEGIN
        PRINT ''Creating database immediately...'';
        EXEC ' + QUOTENAME(@SchemaName) + '.[CreateOrganisationDatabase] @OrganisationCode = @OrganisationCode;
    END
    ELSE
    BEGIN
        PRINT ''Database creation deferred. Use CreateOrganisationDatabase procedure when ready.'';
    END
    
    -- Return the new Organisation code
    SELECT @OrganisationCode as NewOrganisationCode, @DatabaseName as DatabaseName;
END;';

EXEC sp_executesql @SQL;
PRINT 'AddOrganisation procedure created.';

-- Procedure 3: GetOrganisations
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetOrganisations]
    @ActiveOnly bit = 1,
    @IncludeDatabaseExists bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.[OrganisationID],
        c.[OrganisationCode],
        c.[OrganisationName],
        c.[DatabaseName],
        c.[DatabaseStatus],
        c.[DatabaseCreationRequested],
        c.[DatabaseCreated],
        c.[IsActive],
        c.[CreatedDate],
        c.[ModifiedDate],
        c.[DatabaseCreatedDate],
        c.[Notes],
        CASE 
            WHEN @IncludeDatabaseExists = 1 AND d.name IS NOT NULL THEN 1 
            WHEN @IncludeDatabaseExists = 1 THEN 0
            ELSE NULL 
        END AS [DatabaseExists]
    FROM ' + QUOTENAME(@SchemaName) + '.[Organisations] c
    LEFT JOIN sys.databases d ON c.[DatabaseName] = d.name AND @IncludeDatabaseExists = 1
    WHERE (@ActiveOnly = 0 OR c.[IsActive] = 1)
    ORDER BY c.[CreatedDate] DESC;
END;';

EXEC sp_executesql @SQL;
PRINT 'GetOrganisations procedure created.';

-- Procedure 4: UpdateOrganisationStatus
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[UpdateOrganisationStatus]
    @OrganisationCode uniqueidentifier,
    @DatabaseStatus varchar(20) = NULL,
    @IsActive bit = NULL,
    @Notes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrganisationCodeStr nvarchar(36);
    SET @OrganisationCodeStr = CONVERT(nvarchar(36), @OrganisationCode);
    
    -- Validate status
    IF @DatabaseStatus IS NOT NULL AND @DatabaseStatus NOT IN (''PENDING'', ''CREATING'', ''ACTIVE'', ''FAILED'', ''INACTIVE'', ''MAINTENANCE'', ''ARCHIVED'')
    BEGIN
        RAISERROR(''Invalid DatabaseStatus. Must be one of: PENDING, CREATING, ACTIVE, FAILED, INACTIVE, MAINTENANCE, ARCHIVED'', 16, 1);
        RETURN;
    END
    
    -- Update Organisation record
    UPDATE ' + QUOTENAME(@SchemaName) + '.[Organisations]
    SET [DatabaseStatus] = ISNULL(@DatabaseStatus, [DatabaseStatus]),
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [Notes] = ISNULL(@Notes, [Notes]),
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [OrganisationCode] = @OrganisationCode;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(''Organisation with code %s not found.'', 16, 1, @OrganisationCodeStr);
        RETURN;
    END
    
    PRINT ''Organisation status updated for: '' + @OrganisationCodeStr;
END;';

EXEC sp_executesql @SQL;
PRINT 'UpdateOrganisationStatus procedure created.';

-- Procedure 5: SyncDatabaseStatus
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[SyncDatabaseStatus]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UpdatedCount int = 0;
    
    PRINT ''Synchronizing database status with actual databases...'';
    
    -- Update Organisations where database exists but status shows otherwise
    UPDATE c 
    SET [DatabaseStatus] = ''ACTIVE'',
        [DatabaseCreated] = 1,
        [DatabaseCreatedDate] = ISNULL([DatabaseCreatedDate], GETDATE()),
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    FROM ' + QUOTENAME(@SchemaName) + '.[Organisations] c
    INNER JOIN sys.databases d ON c.[DatabaseName] = d.name
    WHERE c.[DatabaseStatus] != ''ACTIVE'' OR c.[DatabaseCreated] = 0;
    
    SET @UpdatedCount = @@ROWCOUNT;
    
    -- Update Organisations where database doesn''t exist but status shows ACTIVE
    UPDATE c 
    SET [DatabaseStatus] = ''FAILED'',
        [DatabaseCreated] = 0,
        [Notes] = ''Database not found during sync - '' + ISNULL([Notes], ''''),
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    FROM ' + QUOTENAME(@SchemaName) + '.[Organisations] c
    LEFT JOIN sys.databases d ON c.[DatabaseName] = d.name
    WHERE d.name IS NULL AND c.[DatabaseStatus] = ''ACTIVE'';
    
    SET @UpdatedCount = @UpdatedCount + @@ROWCOUNT;
    
    PRINT ''Database status synchronization completed. Records updated: '' + CAST(@UpdatedCount AS nvarchar(10));
END;';

EXEC sp_executesql @SQL;
PRINT 'SyncDatabaseStatus procedure created.';

-- =============================================
-- CREATE TRIGGER FOR AUTOMATIC DATABASE CREATION
-- =============================================
SET @SQL = N'
CREATE TRIGGER ' + QUOTENAME(@SchemaName) + '.[trg_CreateOrganisationDatabase]
ON ' + QUOTENAME(@SchemaName) + '.[Organisations]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrganisationCode uniqueidentifier;
    DECLARE @OrganisationName nvarchar(200);
    DECLARE @CreateRequested bit;
    DECLARE @OrganisationCodeStr nvarchar(36);
    DECLARE @JobName nvarchar(128);
    DECLARE @Command nvarchar(4000);
    
    -- Process each inserted record that needs database creation
    DECLARE Organisation_cursor CURSOR FOR
    SELECT [OrganisationCode], [OrganisationName], [DatabaseCreationRequested]
    FROM inserted
    WHERE [DatabaseCreationRequested] = 1 AND [IsActive] = 1;
    
    OPEN Organisation_cursor;
    FETCH NEXT FROM Organisation_cursor INTO @OrganisationCode, @OrganisationName, @CreateRequested;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @OrganisationCodeStr = CONVERT(nvarchar(36), @OrganisationCode);
            SET @JobName = ''CreateOrganisationDB_'' + @OrganisationCodeStr;
            SET @Command = ''EXEC [' + @DatabaseName + '].[' + @SchemaName + '].[CreateOrganisationDatabase] @OrganisationCode = '''''' + @OrganisationCodeStr + '''''';'';
            
            -- Create a SQL Server Agent job to handle database creation
            -- This runs outside the current transaction context
            EXEC msdb.dbo.sp_add_job
                @job_name = @JobName,
                @enabled = 1,
                @delete_level = 3; -- Delete job after completion
            
            EXEC msdb.dbo.sp_add_jobstep
                @job_name = @JobName,
                @step_name = ''CreateDatabase'',
                @command = @Command;
            
            EXEC msdb.dbo.sp_add_jobserver
                @job_name = @JobName;
            
            -- Start the job immediately
            EXEC msdb.dbo.sp_start_job
                @job_name = @JobName;
            
            PRINT ''Trigger: Queued database creation job for Organisation: '' + @OrganisationName + '' (Job: '' + @JobName + '')'';
            
        END TRY
        BEGIN CATCH
            -- If SQL Agent jobs are not available, log the error but don''t fail the insert
            PRINT ''Trigger: Could not create SQL Agent job for '' + @OrganisationName + ''. Error: '' + ERROR_MESSAGE();
            PRINT ''Trigger: You can manually create the database using: EXEC ' + @SchemaName + '.CreateOrganisationDatabase @OrganisationCode = '''''' + CONVERT(nvarchar(36), @OrganisationCode) + '''''';'';
        END CATCH
        
        FETCH NEXT FROM Organisation_cursor INTO @OrganisationCode, @OrganisationName, @CreateRequested;
    END
    
    CLOSE Organisation_cursor;
    DEALLOCATE Organisation_cursor;
END;';

EXEC sp_executesql @SQL;
PRINT 'Database creation trigger created.';
PRINT 'Note: Trigger uses SQL Server Agent jobs for async database creation.';
PRINT 'If SQL Agent is not available, databases must be created manually.';

-- =============================================
-- CREATE MANUAL DATABASE CREATION PROCEDURE
-- =============================================
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[CreatePendingDatabases]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrganisationCode uniqueidentifier;
    DECLARE @OrganisationName nvarchar(200);
    DECLARE @ProcessedCount int = 0;
    
    PRINT ''Processing Organisations with pending database creation...'';
    
    -- Find Organisations that need database creation
    DECLARE pending_cursor CURSOR FOR
    SELECT [OrganisationCode], [OrganisationName]
    FROM ' + QUOTENAME(@SchemaName) + '.[Organisations]
    WHERE [DatabaseCreationRequested] = 1 
      AND [DatabaseCreated] = 0 
      AND [DatabaseStatus] IN (''PENDING'', ''FAILED'')
      AND [IsActive] = 1;
    
    OPEN pending_cursor;
    FETCH NEXT FROM pending_cursor INTO @OrganisationCode, @OrganisationName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            PRINT ''Creating database for: '' + @OrganisationName;
            EXEC ' + QUOTENAME(@SchemaName) + '.[CreateOrganisationDatabase] @OrganisationCode = @OrganisationCode;
            SET @ProcessedCount = @ProcessedCount + 1;
        END TRY
        BEGIN CATCH
            PRINT ''Failed to create database for '' + @OrganisationName + '': '' + ERROR_MESSAGE();
        END CATCH
        
        FETCH NEXT FROM pending_cursor INTO @OrganisationCode, @OrganisationName;
    END
    
    CLOSE pending_cursor;
    DEALLOCATE pending_cursor;
    
    PRINT ''Processed '' + CAST(@ProcessedCount AS nvarchar(10)) + '' pending database creation requests.'';
END;';

EXEC sp_executesql @SQL;
PRINT 'CreatePendingDatabases procedure created.';

-- =============================================
-- COMPLETION MESSAGE AND EXAMPLES
-- =============================================
PRINT '=============================================';
PRINT 'Organisation-Driven Database Management System Setup Complete!';
PRINT '=============================================';
PRINT 'Available procedures:';
PRINT '- ' + @SchemaName + '.AddOrganisation - Add new Organisation (auto-creates DB)';
PRINT '- ' + @SchemaName + '.CreateOrganisationDatabase - Manually create Organisation DB';
PRINT '- ' + @SchemaName + '.GetOrganisations - List all Organisations';
PRINT '- ' + @SchemaName + '.CreatePendingDatabases - Process pending database creations';
PRINT '- ' + @SchemaName + '.SyncDatabaseStatus - Sync status with actual DBs';
PRINT '';
PRINT 'Usage examples:';
PRINT '-- Add new Organisation (queues database creation):';
PRINT 'EXEC ' + @SchemaName + '.AddOrganisation @OrganisationName = ''My New Organisation'';';
PRINT '';
PRINT '-- Process pending database creations manually:';
PRINT 'EXEC ' + @SchemaName + '.CreatePendingDatabases;';
PRINT '';
PRINT '-- Add Organisation without auto-creating database:';
PRINT 'EXEC ' + @SchemaName + '.AddOrganisation @OrganisationName = ''Future Organisation'', @CreateDatabaseImmediately = 0;';
PRINT '';
PRINT '-- View all Organisations:';
PRINT 'EXEC ' + @SchemaName + '.GetOrganisations;';
PRINT '';
PRINT '-- Manually create database for existing Organisation:';
PRINT 'EXEC ' + @SchemaName + '.CreateOrganisationDatabase @OrganisationCode = ''<GUID>'';';
PRINT '';
PRINT '-- Sync database status:';
PRINT 'EXEC ' + @SchemaName + '.SyncDatabaseStatus;';
PRINT '=============================================';