-- =============================================
-- INTEGRATION MANAGEMENT SYSTEM
-- Creates tables for integrations, API endpoints, and Organisation mappings
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
PRINT 'Creating Integration Management System in: [' + @DatabaseName + '].[' + @SchemaName + ']';
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
IF OBJECT_ID(''' + @SchemaName + '.trg_CreateIntegrationSchema'') IS NOT NULL
    DROP TRIGGER ' + QUOTENAME(@SchemaName) + '.[trg_CreateIntegrationSchema];

-- Drop procedures
IF OBJECT_ID(''' + @SchemaName + '.AddIntegration'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[AddIntegration];

IF OBJECT_ID(''' + @SchemaName + '.AddAPIEndpoint'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[AddAPIEndpoint];

IF OBJECT_ID(''' + @SchemaName + '.MapOrganisationToIntegration'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[MapOrganisationToIntegration];

IF OBJECT_ID(''' + @SchemaName + '.GetIntegrations'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetIntegrations];

IF OBJECT_ID(''' + @SchemaName + '.GetOrganisationIntegrations'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetOrganisationIntegrations];

IF OBJECT_ID(''' + @SchemaName + '.GetIntegrationEndpoints'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetIntegrationEndpoints];

IF OBJECT_ID(''' + @SchemaName + '.CreateIntegrationSchema'') IS NOT NULL
    DROP PROCEDURE ' + QUOTENAME(@SchemaName) + '.[CreateIntegrationSchema];

-- Drop foreign key constraints first
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = ''FK_OrganisationIntegrations_Organisation'')
    ALTER TABLE ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] DROP CONSTRAINT [FK_OrganisationIntegrations_Organisation];

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = ''FK_OrganisationIntegrations_Integration'')
    ALTER TABLE ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] DROP CONSTRAINT [FK_OrganisationIntegrations_Integration];

-- Drop tables (APIEndpoints no longer in core schema)
IF EXISTS (SELECT 1 FROM sys.tables t INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = ''' + @SchemaName + ''' AND t.name = ''OrganisationIntegrations'')
    DROP TABLE ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations];

IF EXISTS (SELECT 1 FROM sys.tables t INNER JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = ''' + @SchemaName + ''' AND t.name = ''Integrations'')
    DROP TABLE ' + QUOTENAME(@SchemaName) + '.[Integrations];

PRINT ''Existing integration management objects dropped.'';';

EXEC sp_executesql @SQL;

-- =============================================
-- CREATE INTEGRATIONS TABLE (Core Schema)
-- =============================================
SET @SQL = N'
CREATE TABLE ' + QUOTENAME(@SchemaName) + '.[Integrations] (
    [IntegrationID] int IDENTITY(1,1) NOT NULL,
    [IntegrationCode] uniqueidentifier NOT NULL DEFAULT NEWID(),
    [IntegrationName] nvarchar(100) NOT NULL,
    [IntegrationDisplayName] nvarchar(200) NULL,
    [SchemaName] nvarchar(128) NULL, -- Calculated field
    [SchemaCreated] bit NOT NULL DEFAULT 0,
    [SchemaCreationRequested] bit NOT NULL DEFAULT 1,
    [Version] nvarchar(20) NOT NULL DEFAULT ''1.0.0'',
    [Description] nvarchar(500) NULL,
    [IsActive] bit NOT NULL DEFAULT 1,
    [CreatedBy] nvarchar(100) NOT NULL DEFAULT SYSTEM_USER,
    [CreatedDate] datetime2 NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] nvarchar(100) NULL,
    [ModifiedDate] datetime2 NULL,
    [SchemaCreatedDate] datetime2 NULL,
    
    CONSTRAINT [PK_' + @SchemaName + '_Integrations] PRIMARY KEY CLUSTERED ([IntegrationID]),
    CONSTRAINT [UK_' + @SchemaName + '_Integrations_Code] UNIQUE NONCLUSTERED ([IntegrationCode]),
    CONSTRAINT [UK_' + @SchemaName + '_Integrations_Name] UNIQUE NONCLUSTERED ([IntegrationName]),
    CONSTRAINT [UK_' + @SchemaName + '_Integrations_Schema] UNIQUE NONCLUSTERED ([SchemaName])
);';

EXEC sp_executesql @SQL;

-- =============================================
-- CREATE Organisation INTEGRATIONS MAPPING TABLE
-- =============================================
SET @SQL = N'
CREATE TABLE ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] (
    [OrganisationIntegrationID] int IDENTITY(1,1) NOT NULL,
    [OrganisationID] int NOT NULL,
    [IntegrationID] int NOT NULL,
    [ConnectionString] nvarchar(1000) NULL,
    [APIKey] nvarchar(500) NULL,
    [Username] nvarchar(200) NULL,
    [PasswordHash] nvarchar(500) NULL, -- Store encrypted
    [BaseURL] nvarchar(1000) NULL,
    [CustomSettings] nvarchar(max) NULL, -- JSON format for flexible config
    [IsEnabled] bit NOT NULL DEFAULT 1,
    [LastSyncDate] datetime2 NULL,
    [SyncStatus] varchar(20) NOT NULL DEFAULT ''PENDING'',
    [Notes] nvarchar(1000) NULL,
    [CreatedBy] nvarchar(100) NOT NULL DEFAULT SYSTEM_USER,
    [CreatedDate] datetime2 NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] nvarchar(100) NULL,
    [ModifiedDate] datetime2 NULL,
    
    CONSTRAINT [PK_' + @SchemaName + '_OrganisationIntegrations] PRIMARY KEY CLUSTERED ([OrganisationIntegrationID]),
    CONSTRAINT [UK_' + @SchemaName + '_OrganisationIntegrations_OrganisationInt] UNIQUE NONCLUSTERED ([OrganisationID], [IntegrationID]),
    CONSTRAINT [CK_' + @SchemaName + '_OrganisationIntegrations_SyncStatus] CHECK ([SyncStatus] IN (''PENDING'', ''ACTIVE'', ''ERROR'', ''DISABLED''))
);';

EXEC sp_executesql @SQL;

-- =============================================
-- CREATE FOREIGN KEY CONSTRAINTS
-- =============================================
SET @SQL = N'
ALTER TABLE ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations]
ADD CONSTRAINT [FK_OrganisationIntegrations_Organisation] 
FOREIGN KEY ([OrganisationID]) REFERENCES ' + QUOTENAME(@SchemaName) + '.[Organisations]([OrganisationID]);

ALTER TABLE ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations]
ADD CONSTRAINT [FK_OrganisationIntegrations_Integration] 
FOREIGN KEY ([IntegrationID]) REFERENCES ' + QUOTENAME(@SchemaName) + '.[Integrations]([IntegrationID]);';

EXEC sp_executesql @SQL;

-- =============================================
-- CREATE INDEXES
-- =============================================
SET @SQL = N'
-- Integrations indexes
CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + '_Integrations_Active] 
ON ' + QUOTENAME(@SchemaName) + '.[Integrations] ([IsActive]) 
INCLUDE ([IntegrationName], [SchemaName], [SchemaCreated]);

-- Organisation Integrations indexes
CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + '_OrganisationIntegrations_Organisation] 
ON ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] ([OrganisationID]) 
INCLUDE ([IntegrationID], [IsEnabled], [SyncStatus]);

CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + '_OrganisationIntegrations_Integration] 
ON ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] ([IntegrationID]) 
INCLUDE ([OrganisationID], [IsEnabled], [SyncStatus]);

CREATE NONCLUSTERED INDEX [IX_' + @SchemaName + '_OrganisationIntegrations_Status] 
ON ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] ([SyncStatus]) 
WHERE [IsEnabled] = 1;';

EXEC sp_executesql @SQL;

PRINT 'Integration tables and indexes created successfully.';

-- =============================================
-- CREATE STORED PROCEDURES
-- =============================================

-- Procedure 1: CreateIntegrationSchema
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[CreateIntegrationSchema]
    @IntegrationID int
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SchemaName nvarchar(128);
    DECLARE @IntegrationName nvarchar(100);
    DECLARE @SQL nvarchar(max);
    DECLARE @ErrorMessage nvarchar(4000);
    
    -- Get integration details
    SELECT 
        @SchemaName = [SchemaName],
        @IntegrationName = [IntegrationName]
    FROM ' + QUOTENAME(@SchemaName) + '.[Integrations]
    WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1;
    
    IF @SchemaName IS NULL
    BEGIN
        RAISERROR(''Integration with ID %d not found or inactive.'', 16, 1, @IntegrationID);
        RETURN;
    END
    
    BEGIN TRY
        -- Check if schema already exists
        IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
        BEGIN
            PRINT ''Schema ['' + @SchemaName + ''] already exists. Updating integration record.'';
            -- Update status to indicate schema exists
            UPDATE ' + QUOTENAME(@SchemaName) + '.[Integrations]
            SET [SchemaCreated] = 1,
                [SchemaCreatedDate] = GETDATE(),
                [ModifiedBy] = SYSTEM_USER,
                [ModifiedDate] = GETDATE()
            WHERE [IntegrationID] = @IntegrationID;
            RETURN;
        END
        
        -- Create the schema
        PRINT ''Creating schema: ['' + @SchemaName + '']'';
        SET @SQL = ''CREATE SCHEMA '' + QUOTENAME(@SchemaName);
        EXEC sp_executesql @SQL;
        
        -- Create standard tables in the new schema
        SET @SQL = ''
        EXEC [core].[sp_CreateIntegrationTables] 
        @DatabaseName = ''''core'''',
        @SchemaName = '' + QUOTENAME(@SchemaName);
        
        EXEC sp_executesql @SQL;

        SET @SQL = ''
        EXEC [core].[sp_CreateGlobalParametersTools]
        @DatabaseName = ''''core'''',
        @SchemaName = '' + QUOTENAME(@SchemaName);
        
        EXEC sp_executesql @SQL;

        -- Update integration record to success
        UPDATE ' + QUOTENAME(@SchemaName) + '.[Integrations]
        SET [SchemaCreated] = 1,
            [SchemaCreatedDate] = GETDATE(),
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [IntegrationID] = @IntegrationID;
        
        PRINT ''Schema created successfully: ['' + @SchemaName + '']'';
        
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT ''Schema creation failed'';
    END CATCH
END;';

EXEC sp_executesql @SQL;
PRINT 'CreateIntegrationSchema procedure created.';

-- Procedure 2: AddIntegration
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[AddIntegration]
    @IntegrationName nvarchar(100),
    @IntegrationDisplayName nvarchar(200) = NULL,
    @Description nvarchar(500) = NULL,
    @CreateSchemaImmediately bit = 1,
    @Version nvarchar(20) = ''1.0.0''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewIntegrationID int;
    DECLARE @IntegrationCode uniqueidentifier;
    DECLARE @SchemaName nvarchar(128);
    
    -- Generate schema name from integration name
    SET @SchemaName = ''int_'' + LOWER(REPLACE(REPLACE(@IntegrationName, '' '', ''_''), ''-'', ''_''));
    SET @IntegrationCode = NEWID();
    
    -- Set default display name
    IF @IntegrationDisplayName IS NULL
        SET @IntegrationDisplayName = @IntegrationName;
    
    -- Check if integration already exists
    IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@SchemaName) + '.[Integrations] WHERE [IntegrationName] = @IntegrationName)
    BEGIN
        RAISERROR(''Integration with name %s already exists.'', 16, 1, @IntegrationName);
        RETURN;
    END
    
    -- Check if schema name would conflict
    IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        RAISERROR(''Schema %s already exists. Choose a different integration name.'', 16, 1, @SchemaName);
        RETURN;
    END
    
    -- Insert integration record
    INSERT INTO ' + QUOTENAME(@SchemaName) + '.[Integrations] 
    ([IntegrationCode], [IntegrationName], [IntegrationDisplayName], [SchemaName], [Description], [Version], [SchemaCreationRequested])
    VALUES 
    (@IntegrationCode, @IntegrationName, @IntegrationDisplayName, @SchemaName, @Description, @Version, @CreateSchemaImmediately);
    
    SET @NewIntegrationID = SCOPE_IDENTITY();
    
    PRINT ''Integration added: '' + @IntegrationName + '' (ID: '' + CAST(@NewIntegrationID AS nvarchar(10)) + '')'';
    PRINT ''Schema will be: ['' + @SchemaName + '']'';
    
    -- Create schema immediately if requested
    IF @CreateSchemaImmediately = 1
    BEGIN
        PRINT ''Creating schema immediately...'';
        EXEC ' + QUOTENAME(@SchemaName) + '.[CreateIntegrationSchema] @IntegrationID = @NewIntegrationID;
    END
    ELSE
    BEGIN
        PRINT ''Schema creation deferred. Use CreateIntegrationSchema procedure when ready.'';
    END
    
    -- Return the new integration details
    SELECT 
        @NewIntegrationID as IntegrationID, 
        @IntegrationCode as IntegrationCode,
        @SchemaName as SchemaName;
END;';

EXEC sp_executesql @SQL;
PRINT 'AddIntegration procedure created.';

-- Procedure 3: AddAPIEndpoint
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[AddAPIEndpoint]
    @IntegrationID int,
    @EndpointName nvarchar(100),
    @EndpointURL nvarchar(1000),
    @HttpMethod varchar(10) = ''GET'',
    @EndpointDisplayName nvarchar(200) = NULL,
    @AuthenticationType varchar(50) = NULL,
    @RequiresAuthentication bit = 1,
    @ContentType varchar(100) = ''application/json'',
    @TimeoutSeconds int = 30,
    @Description nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewEndpointID int;
    DECLARE @SchemaName nvarchar(128);
    DECLARE @SQL nvarchar(max);
    
    -- Get integration schema name and validate integration exists
    SELECT @SchemaName = [SchemaName]
    FROM ' + QUOTENAME(@SchemaName) + '.[Integrations] 
    WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1;
    
    IF @SchemaName IS NULL
    BEGIN
        RAISERROR(''Integration with ID %d not found or inactive.'', 16, 1, @IntegrationID);
        RETURN;
    END
    
    -- Check if schema exists
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        RAISERROR(''Integration schema [%s] does not exist. Create the integration schema first.'', 16, 1, @SchemaName);
        RETURN;
    END
    
    -- Set default display name
    IF @EndpointDisplayName IS NULL
        SET @EndpointDisplayName = @EndpointName;
    
    -- Build dynamic SQL to insert into the integration schema
    SET @SQL = ''
    -- Check if endpoint already exists
    IF EXISTS (SELECT 1 FROM '' + QUOTENAME(@SchemaName) + ''.[APIEndpoints] WHERE [EndpointName] = '''''' + @EndpointName + '''''')
    BEGIN
        RAISERROR(''''Endpoint %s already exists for this integration.'''', 16, 1, '''''' + @EndpointName + '''''');
        RETURN;
    END
    
    -- Insert endpoint record
    INSERT INTO '' + QUOTENAME(@SchemaName) + ''.[APIEndpoints] 
    ([EndpointName], [EndpointDisplayName], [EndpointURL], [HttpMethod], 
     [AuthenticationType], [RequiresAuthentication], [ContentType], [TimeoutSeconds], [Description])
    VALUES 
    ('''''' + @EndpointName + '''''', '''''' + ISNULL(@EndpointDisplayName, @EndpointName) + '''''', '''''' + @EndpointURL + '''''', '''''' + @HttpMethod + '''''', 
     '' + CASE WHEN @AuthenticationType IS NULL THEN ''NULL'' ELSE '''''''' + @AuthenticationType + '''''''' END + '', '' + CAST(@RequiresAuthentication AS nvarchar(1)) + '', 
     '''''' + @ContentType + '''''', '' + CAST(@TimeoutSeconds AS nvarchar(10)) + '', '' + CASE WHEN @Description IS NULL THEN ''NULL'' ELSE '''''''' + @Description + '''''''' END + '');
    
    SELECT @EndpointID = SCOPE_IDENTITY();
    '';
    
    -- Execute the dynamic SQL
    EXEC sp_executesql @SQL, N''@EndpointID int OUTPUT'', @EndpointID = @NewEndpointID OUTPUT;
    
    PRINT ''API Endpoint added to ['' + @SchemaName + '']: '' + @EndpointName + '' (ID: '' + CAST(@NewEndpointID AS nvarchar(10)) + '')'';
    
    -- Return the new endpoint ID
    SELECT @NewEndpointID as EndpointID, @SchemaName as SchemaName;
END;';

EXEC sp_executesql @SQL;
PRINT 'AddAPIEndpoint procedure created.';

-- Procedure 4: MapOrganisationToIntegration
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[MapOrganisationToIntegration]
    @OrganisationID int,
    @IntegrationID int,
    @ConnectionString nvarchar(1000) = NULL,
    @APIKey nvarchar(500) = NULL,
    @Username nvarchar(200) = NULL,
    @PasswordHash nvarchar(500) = NULL,
    @BaseURL nvarchar(1000) = NULL,
    @CustomSettings nvarchar(max) = NULL,
    @Notes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewMappingID int;
    
    -- Validate Organisation exists
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@SchemaName) + '.[Organisations] WHERE [OrganisationID] = @OrganisationID AND [IsActive] = 1)
    BEGIN
        RAISERROR(''Organisation with ID %d not found or inactive.'', 16, 1, @OrganisationID);
        RETURN;
    END
    
    -- Validate integration exists
    IF NOT EXISTS (SELECT 1 FROM ' + QUOTENAME(@SchemaName) + '.[Integrations] WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1)
    BEGIN
        RAISERROR(''Integration with ID %d not found or inactive.'', 16, 1, @IntegrationID);
        RETURN;
    END
    
    -- Check if mapping already exists
    IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] WHERE [OrganisationID] = @OrganisationID AND [IntegrationID] = @IntegrationID)
    BEGIN
        -- Update existing mapping
        UPDATE ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations]
        SET [ConnectionString] = ISNULL(@ConnectionString, [ConnectionString]),
            [APIKey] = ISNULL(@APIKey, [APIKey]),
            [Username] = ISNULL(@Username, [Username]),
            [PasswordHash] = ISNULL(@PasswordHash, [PasswordHash]),
            [BaseURL] = ISNULL(@BaseURL, [BaseURL]),
            [CustomSettings] = ISNULL(@CustomSettings, [CustomSettings]),
            [Notes] = ISNULL(@Notes, [Notes]),
            [IsEnabled] = 1,
            [SyncStatus] = ''PENDING'',
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationID] = @OrganisationID AND [IntegrationID] = @IntegrationID;
        
        SELECT @NewMappingID = [OrganisationIntegrationID] 
        FROM ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] 
        WHERE [OrganisationID] = @OrganisationID AND [IntegrationID] = @IntegrationID;
        
        PRINT ''Organisation-Integration mapping updated (ID: '' + CAST(@NewMappingID AS nvarchar(10)) + '')'';
    END
    ELSE
    BEGIN
        -- Insert new mapping
        INSERT INTO ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] 
        ([OrganisationID], [IntegrationID], [ConnectionString], [APIKey], [Username], [PasswordHash], 
         [BaseURL], [CustomSettings], [Notes])
        VALUES 
        (@OrganisationID, @IntegrationID, @ConnectionString, @APIKey, @Username, @PasswordHash, 
         @BaseURL, @CustomSettings, @Notes);
        
        SET @NewMappingID = SCOPE_IDENTITY();
        PRINT ''Organisation-Integration mapping created (ID: '' + CAST(@NewMappingID AS nvarchar(10)) + '')'';
    END
    
    -- Return the mapping ID
    SELECT @NewMappingID as OrganisationIntegrationID;
END;';

EXEC sp_executesql @SQL;
PRINT 'MapOrganisationToIntegration procedure created.';

-- Procedure 5: GetIntegrations
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetIntegrations]
    @ActiveOnly bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get integrations
    SELECT 
        i.[IntegrationID],
        i.[IntegrationCode],
        i.[IntegrationName],
        i.[IntegrationDisplayName],
        i.[SchemaName],
        i.[SchemaCreated],
        i.[Version],
        i.[Description],
        i.[IsActive],
        i.[CreatedDate],
        i.[ModifiedDate],
        i.[SchemaCreatedDate],
        CASE WHEN s.name IS NOT NULL THEN 1 ELSE 0 END AS [SchemaExists],
        (SELECT COUNT(*) FROM ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] ci WHERE ci.[IntegrationID] = i.[IntegrationID] AND ci.[IsEnabled] = 1) AS [OrganisationCount]
    FROM ' + QUOTENAME(@SchemaName) + '.[Integrations] i
    LEFT JOIN sys.schemas s ON i.[SchemaName] = s.name
    WHERE (@ActiveOnly = 0 OR i.[IsActive] = 1)
    ORDER BY i.[IntegrationName];
END;';

EXEC sp_executesql @SQL;
PRINT 'GetIntegrations procedure created.';

-- Procedure 6: GetIntegrationEndpoints
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetIntegrationEndpoints]
    @IntegrationID int,
    @ActiveOnly bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SchemaName nvarchar(128);
    DECLARE @SQL nvarchar(max);
    
    -- Get integration schema name
    SELECT @SchemaName = [SchemaName]
    FROM ' + QUOTENAME(@SchemaName) + '.[Integrations] 
    WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1;
    
    IF @SchemaName IS NULL
    BEGIN
        RAISERROR(''Integration with ID %d not found or inactive.'', 16, 1, @IntegrationID);
        RETURN;
    END
    
    -- Check if schema exists
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        RAISERROR(''Integration schema [%s] does not exist.'', 16, 1, @SchemaName);
        RETURN;
    END
    
    -- Build dynamic SQL to query the integration schema
    SET @SQL = ''
    SELECT 
        [EndpointID],
        [EndpointName],
        [EndpointDisplayName],
        [EndpointURL],
        [HttpMethod],
        [AuthenticationType],
        [RequiresAuthentication],
        [ContentType],
        [TimeoutSeconds],
        [Description],
        [IsActive],
        [CreatedDate],
        [ModifiedDate]
    FROM '' + QUOTENAME(@SchemaName) + ''.[APIEndpoints]
    WHERE ('' + CAST(@ActiveOnly AS nvarchar(1)) + '' = 0 OR [IsActive] = 1)
    ORDER BY [EndpointName];
    '';
    
    -- Execute the dynamic SQL
    EXEC sp_executesql @SQL;
END;';

EXEC sp_executesql @SQL;
PRINT 'GetIntegrationEndpoints procedure created.';

-- Procedure 7: GetOrganisationIntegrations
SET @SQL = N'
CREATE PROCEDURE ' + QUOTENAME(@SchemaName) + '.[GetOrganisationIntegrations]
    @OrganisationID int = NULL,
    @IntegrationID int = NULL,
    @EnabledOnly bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ci.[OrganisationIntegrationID],
        ci.[OrganisationID],
        c.[OrganisationName],
        c.[OrganisationCode],
        ci.[IntegrationID],
        i.[IntegrationName],
        i.[IntegrationDisplayName],
        i.[SchemaName],
        ci.[ConnectionString],
        ci.[APIKey],
        ci.[Username],
        ci.[BaseURL],
        ci.[CustomSettings],
        ci.[IsEnabled],
        ci.[LastSyncDate],
        ci.[SyncStatus],
        ci.[Notes],
        ci.[CreatedDate],
        ci.[ModifiedDate]
    FROM ' + QUOTENAME(@SchemaName) + '.[OrganisationIntegrations] ci
    INNER JOIN ' + QUOTENAME(@SchemaName) + '.[Organisations] c ON ci.[OrganisationID] = c.[OrganisationID]
    INNER JOIN ' + QUOTENAME(@SchemaName) + '.[Integrations] i ON ci.[IntegrationID] = i.[IntegrationID]
    WHERE (@OrganisationID IS NULL OR ci.[OrganisationID] = @OrganisationID)
      AND (@IntegrationID IS NULL OR ci.[IntegrationID] = @IntegrationID)
      AND (@EnabledOnly = 0 OR ci.[IsEnabled] = 1)
      AND c.[IsActive] = 1
      AND i.[IsActive] = 1
    ORDER BY c.[OrganisationName], i.[IntegrationName];
END;';

EXEC sp_executesql @SQL;
PRINT 'GetOrganisationIntegrations procedure created.';

-- =============================================
-- CREATE TRIGGER FOR AUTOMATIC SCHEMA CREATION
-- =============================================
SET @SQL = N'
CREATE TRIGGER ' + QUOTENAME(@SchemaName) + '.[trg_CreateIntegrationSchema]
ON ' + QUOTENAME(@SchemaName) + '.[Integrations]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IntegrationID int;
    DECLARE @IntegrationName nvarchar(100);
    DECLARE @CreateRequested bit;
    DECLARE @JobName nvarchar(128);
    DECLARE @Command nvarchar(4000);
    
    -- Process each inserted record that needs schema creation
    DECLARE integration_cursor CURSOR FOR
    SELECT [IntegrationID], [IntegrationName], [SchemaCreationRequested]
    FROM inserted
    WHERE [SchemaCreationRequested] = 1 AND [IsActive] = 1;
    
    OPEN integration_cursor;
    FETCH NEXT FROM integration_cursor INTO @IntegrationID, @IntegrationName, @CreateRequested;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @JobName = ''CreateIntegrationSchema_'' + CAST(@IntegrationID AS nvarchar(10));
            SET @Command = ''EXEC [' + @DatabaseName + '].[' + @SchemaName + '].[CreateIntegrationSchema] @IntegrationID = '' + CAST(@IntegrationID AS nvarchar(10)) + '';'';
            
            -- Create a SQL Server Agent job to handle schema creation
            EXEC msdb.dbo.sp_add_job
                @job_name = @JobName,
                @enabled = 1,
                @delete_level = 3; -- Delete job after completion
            
            EXEC msdb.dbo.sp_add_jobstep
                @job_name = @JobName,
                @step_name = ''CreateSchema'',
                @command = @Command;
            
            EXEC msdb.dbo.sp_add_jobserver
                @job_name = @JobName;
            
            -- Start the job immediately
            EXEC msdb.dbo.sp_start_job
                @job_name = @JobName;
            
            PRINT ''Trigger: Queued schema creation job for integration: '' + @IntegrationName + '' (Job: '' + @JobName + '')'';
            
        END TRY
        BEGIN CATCH
            -- If SQL Agent jobs are not available, log the error but don''t fail the insert
            PRINT ''Trigger: Could not create SQL Agent job for '' + @IntegrationName + ''. Error: '' + ERROR_MESSAGE();
            PRINT ''Trigger: You can manually create the schema using: EXEC ' + @SchemaName + '.CreateIntegrationSchema @IntegrationID = '' + CAST(@IntegrationID AS nvarchar(10)) + '';'';
        END CATCH
        
        FETCH NEXT FROM integration_cursor INTO @IntegrationID, @IntegrationName, @CreateRequested;
    END
    
    CLOSE integration_cursor;
    DEALLOCATE integration_cursor;
END;';

EXEC sp_executesql @SQL;

PRINT 'Integration schema creation trigger created.';
PRINT 'Note: Trigger uses SQL Server Agent jobs for async schema creation.';

-- =============================================
-- COMPLETION MESSAGE AND EXAMPLES
-- =============================================
PRINT '=============================================';
PRINT 'Integration Management System Setup Complete!';
PRINT '=============================================';
PRINT 'Available procedures:';
PRINT '- ' + @SchemaName + '.AddIntegration - Add new integration (auto-creates schema)';
PRINT '- ' + @SchemaName + '.AddAPIEndpoint - Add API endpoint to integration schema';
PRINT '- ' + @SchemaName + '.MapOrganisationToIntegration - Map Organisation to integration';
PRINT '- ' + @SchemaName + '.GetIntegrations - List all integrations';
PRINT '- ' + @SchemaName + '.GetIntegrationEndpoints - List endpoints for an integration';
PRINT '- ' + @SchemaName + '.GetOrganisationIntegrations - List Organisation integration mappings';
PRINT '- ' + @SchemaName + '.CreateIntegrationSchema - Manually create integration schema';
PRINT '';
PRINT 'Usage examples:';
PRINT '-- Add new integration (auto-creates schema):';
PRINT 'EXEC ' + @SchemaName + '.AddIntegration @IntegrationName = ''Zonal'', @Description = ''Zonal POS System'';';
PRINT '';
PRINT '-- Add API endpoint (stored in integration schema):';
PRINT 'EXEC ' + @SchemaName + '.AddAPIEndpoint @IntegrationID = 1, @EndpointName = ''GetTransactions'', @EndpointURL = ''/api/transactions'';';
PRINT '';
PRINT '-- View endpoints for an integration:';
PRINT 'EXEC ' + @SchemaName + '.GetIntegrationEndpoints @IntegrationID = 1;';
PRINT '';
PRINT '-- Map Organisation to integration:';
PRINT 'EXEC ' + @SchemaName + '.MapOrganisationToIntegration @OrganisationID = 1, @IntegrationID = 1, @APIKey = ''your-api-key'';';
PRINT '';
PRINT '-- View all integrations:';
PRINT 'EXEC ' + @SchemaName + '.GetIntegrations;';
PRINT '';
PRINT '-- View Organisation integrations:';
PRINT 'EXEC ' + @SchemaName + '.GetOrganisationIntegrations @OrganisationID = 1;';
PRINT '';
PRINT 'Note: API endpoints are now stored in their respective integration schemas.';
PRINT 'Example: Zonal endpoints are in [int_zonal].[APIEndpoints] table.';
PRINT '=============================================';