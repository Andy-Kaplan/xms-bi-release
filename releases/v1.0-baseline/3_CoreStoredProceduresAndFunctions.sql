-- ============================================
-- 3_CoreStoredProceduresAndFunctions.sql
-- Regenerated from UAT 2026-07-06 15:17:16
-- Server: xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net
-- ============================================

-- ============================================
-- SQL_SCALAR_FUNCTION : [core].[GetDatabaseFromOrganisationID]
-- ============================================
CREATE OR ALTER FUNCTION [core].[GetDatabaseFromOrganisationID]
        (
            @intID int
        )
        RETURNS nvarchar(4000)
        AS
        BEGIN
            DECLARE @Value nvarchar(4000);
            
            SELECT @Value = [DatabaseName]
            FROM [core].[Organisations]
            WHERE [OrganisationID] = @intID 
              AND [IsActive] = 1;
            
            RETURN @Value;
        END;
GO


-- ============================================
-- SQL_SCALAR_FUNCTION : [core].[GetParameter]
-- ============================================
CREATE OR ALTER FUNCTION [core].[GetParameter]
        (
            @ParameterKey nvarchar(100)
        )
        RETURNS nvarchar(4000)
        AS
        BEGIN
            DECLARE @Value nvarchar(4000);
            
            SELECT @Value = [ParameterValue]
            FROM [core].[GlobalParameters]
            WHERE [ParameterKey] = @ParameterKey 
              AND [IsActive] = 1;
            
            RETURN @Value;
        END;
GO


-- ============================================
-- SQL_SCALAR_FUNCTION : [core].[GetParameterDataType]
-- ============================================
CREATE OR ALTER FUNCTION [core].[GetParameterDataType]
        (
            @ParameterKey nvarchar(100)
        )
        RETURNS varchar(20)
        AS
        BEGIN
            DECLARE @DataType varchar(20);
            
            SELECT @DataType = [DataType]
            FROM [core].[GlobalParameters]
            WHERE [ParameterKey] = @ParameterKey 
              AND [IsActive] = 1;
            
            RETURN @DataType;
        END;
GO


-- ============================================
-- SQL_INLINE_TABLE_VALUED_FUNCTION : [core].[GetParameterWithType]
-- ============================================
CREATE OR ALTER FUNCTION [core].[GetParameterWithType]
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
            FROM [core].[GlobalParameters]
            WHERE [ParameterKey] = @ParameterKey 
              AND [IsActive] = 1
        );
GO


-- ============================================
-- SQL_SCALAR_FUNCTION : [core].[GetSchemaFromIntegrationID]
-- ============================================
CREATE OR ALTER FUNCTION [core].[GetSchemaFromIntegrationID]
        (
            @intID int
        )
        RETURNS nvarchar(4000)
        AS
        BEGIN
            DECLARE @Value nvarchar(4000);
            
            SELECT @Value = [SchemaName]
            FROM [core].[Integrations]
            WHERE [IntegrationID] = @intID 
              AND [IsActive] = 1;
            
            RETURN @Value;
        END;
GO


-- ============================================
-- SQL_SCALAR_FUNCTION : [core].[GetTypedParameter]
-- ============================================
CREATE OR ALTER FUNCTION [core].[GetTypedParameter]
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
            FROM [core].[GlobalParameters]
            WHERE [ParameterKey] = @ParameterKey 
              AND [IsActive] = 1;
            
            -- Optional type validation
            IF @OutputDataType IS NOT NULL AND @DataType != @OutputDataType
            BEGIN
                RETURN NULL;
            END
            
            -- Convert based on stored data type
            IF @DataType = 'INT'
                SET @Result = CAST(@Value AS int);
            ELSE IF @DataType = 'DECIMAL'
                SET @Result = CAST(@Value AS decimal(18,6));
            ELSE IF @DataType = 'BOOLEAN'
                SET @Result = CASE WHEN LOWER(@Value) IN ('true', '1', 'yes') THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END;
            ELSE IF @DataType = 'DATE'
                SET @Result = CAST(@Value AS date);
            ELSE IF @DataType = 'DATETIME'
                SET @Result = CAST(@Value AS datetime2);
            ELSE
                SET @Result = @Value;
            
            RETURN @Result;
        END;
GO


-- ============================================
-- SQL_SCALAR_FUNCTION : [core].[SHA256Hash]
-- ============================================
CREATE OR ALTER FUNCTION [core].[SHA256Hash](@input NVARCHAR(MAX))
RETURNS VARBINARY(32)
AS
BEGIN
    DECLARE @binary VARBINARY(32);
    SET @binary = HASHBYTES('SHA2_256', CAST(@input AS VARBINARY(MAX)));
    RETURN @binary;
END
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[AddAPIEndpoint]
-- ============================================

/*##########################################################################*/
/*##########################################################################*/
---------------------------STORED PROCEDURES---------------------------------
/*##########################################################################*/
/*##########################################################################*/

/*##################################*/
/*            Add API               */
/*##################################*/

-- Use CREATE OR ALTER for stored procedures
CREATE   PROCEDURE [core].[AddAPIEndpoint]
    @IntegrationID int,
    @EndpointName nvarchar(100),
    @EndpointURL nvarchar(1000),
    @HttpMethod varchar(10) = 'GET',
    @EndpointDisplayName nvarchar(200) = NULL,
    @AuthenticationType varchar(50) = NULL,
    @RequiresAuthentication bit = 1,
    @ContentType varchar(100) = 'application/json',
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
    FROM [core].[Integrations] 
    WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1;
    
    IF @SchemaName IS NULL
    BEGIN
        RAISERROR('Integration with ID %d not found or inactive.', 16, 1, @IntegrationID);
        RETURN;
    END
    
    -- Check if schema exists
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        RAISERROR('Integration schema [%s] does not exist. Create the integration schema first.', 16, 1, @SchemaName);
        RETURN;
    END
    
    -- Set default display name
    IF @EndpointDisplayName IS NULL
        SET @EndpointDisplayName = @EndpointName;
    
    -- Build dynamic SQL to insert into the integration schema
    SET @SQL = '
    -- Check if endpoint already exists
    IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@SchemaName) + '.[APIEndpoints] WHERE [EndpointName] = ''' + @EndpointName + ''')
    BEGIN
        RAISERROR(''Endpoint %s already exists for this integration.'', 16, 1, ''' + @EndpointName + ''');
        RETURN;
    END
    
    -- Insert endpoint record
    INSERT INTO ' + QUOTENAME(@SchemaName) + '.[APIEndpoints] 
    ([EndpointName], [EndpointDisplayName], [EndpointURL], [HttpMethod], 
     [AuthenticationType], [RequiresAuthentication], [ContentType], [TimeoutSeconds], [Description])
    VALUES 
    (''' + @EndpointName + ''', ''' + ISNULL(@EndpointDisplayName, @EndpointName) + ''', ''' + @EndpointURL + ''', ''' + @HttpMethod + ''', 
     ' + CASE WHEN @AuthenticationType IS NULL THEN 'NULL' ELSE '''' + @AuthenticationType + '''' END + ', ' + CAST(@RequiresAuthentication AS nvarchar(1)) + ', 
     ''' + @ContentType + ''', ' + CAST(@TimeoutSeconds AS nvarchar(10)) + ', ' + CASE WHEN @Description IS NULL THEN 'NULL' ELSE '''' + @Description + '''' END + ');
    
    SELECT @EndpointID = SCOPE_IDENTITY();
    ';
    
    -- Execute the dynamic SQL
    EXEC sp_executesql @SQL, N'@EndpointID int OUTPUT', @EndpointID = @NewEndpointID OUTPUT;
    
    PRINT 'API Endpoint added to [' + @SchemaName + ']: ' + @EndpointName + ' (ID: ' + CAST(@NewEndpointID AS nvarchar(10)) + ')';
    
    -- Return the new endpoint ID
    SELECT @NewEndpointID as EndpointID, @SchemaName as SchemaName;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[AddIntegration]
-- ============================================

/*##################################*/
/*            Add Integration       */
/*##################################*/

CREATE   PROCEDURE [core].[AddIntegration]
    @IntegrationName nvarchar(100),
    @IntegrationDisplayName nvarchar(200) = NULL,
    @Description nvarchar(500) = NULL,
    @CreateSchemaImmediately bit = 1,
    @Version nvarchar(20) = '1.0.0'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewIntegrationID int;
    DECLARE @IntegrationCode uniqueidentifier;
    DECLARE @SchemaName nvarchar(128);
    
    -- Generate schema name from integration name
    SET @SchemaName = 'int_' + LOWER(REPLACE(REPLACE(@IntegrationName, ' ', '_'), '-', '_'));
    SET @IntegrationCode = NEWID();
    
    -- Set default display name
    IF @IntegrationDisplayName IS NULL
        SET @IntegrationDisplayName = @IntegrationName;
    
    -- Check if integration already exists
    IF EXISTS (SELECT 1 FROM [core].[Integrations] WHERE [IntegrationName] = @IntegrationName)
    BEGIN
        RAISERROR('Integration with name %s already exists.', 16, 1, @IntegrationName);
        RETURN;
    END
    
    -- Check if schema name would conflict
    IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        RAISERROR('Schema %s already exists. Choose a different integration name.', 16, 1, @SchemaName);
        RETURN;
    END
    
    -- Insert integration record
    INSERT INTO [core].[Integrations] 
    ([IntegrationCode], [IntegrationName], [IntegrationDisplayName], [SchemaName], [Description], [Version], [SchemaCreationRequested])
    VALUES 
    (@IntegrationCode, @IntegrationName, @IntegrationDisplayName, @SchemaName, @Description, @Version, @CreateSchemaImmediately);
    
    SET @NewIntegrationID = SCOPE_IDENTITY();
    
    PRINT 'Integration added: ' + @IntegrationName + ' (ID: ' + CAST(@NewIntegrationID AS nvarchar(10)) + ')';
    PRINT 'Schema will be: [' + @SchemaName + ']';
    
    -- Create schema immediately if requested
    IF @CreateSchemaImmediately = 1
    BEGIN
        PRINT 'Creating schema immediately...';
        EXEC [core].[CreateIntegrationSchema] @IntegrationID = @NewIntegrationID;
    END
    ELSE
    BEGIN
        PRINT 'Schema creation deferred. Use CreateIntegrationSchema procedure when ready.';
    END
    
    -- Return the new integration details
    SELECT 
        @NewIntegrationID as IntegrationID, 
        @IntegrationCode as IntegrationCode,
        @SchemaName as SchemaName;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[AddOrganisation]
-- ============================================

/*##################################*/
/*         Add Organisation       */
/*##################################*/

CREATE   PROCEDURE [core].[AddOrganisation]
    @OrganisationName nvarchar(255),
    @OrganisationPrefix nvarchar(255),
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
    SET @DatabaseName = @OrganisationPrefix + '_XMS_' + @OrganisationCodeStr;
    
    -- Check if Organisation already exists
    IF EXISTS (SELECT 1 FROM [core].[Organisations] WHERE [OrganisationCode] = @OrganisationCode)
    BEGIN
        RAISERROR('Organisation with code %s already exists.', 16, 1, @OrganisationCodeStr);
        RETURN;
    END
    
    -- Insert Organisation record
    INSERT INTO [core].[Organisations] 
    ([OrganisationCode], [OrganisationName], [DatabaseName], [DatabaseCreationRequested], [OrganisationPrefix], [Notes])
    VALUES 
    (@OrganisationCode, @OrganisationName, @DatabaseName, @CreateDatabaseImmediately, @OrganisationPrefix, @Notes);
    
    PRINT 'Organisation added: ' + @OrganisationName + ' (Code: ' + @OrganisationCodeStr + ')';
    PRINT 'Database will be: ' + @DatabaseName;
    
    -- Create database immediately if requested
    IF @CreateDatabaseImmediately = 1
    BEGIN
        PRINT 'Creating database immediately...';
        EXEC [core].[CreateOrganisationDatabase] @OrganisationCode = @OrganisationCode, @OrganisationPrefix = @OrganisationPrefix;
    END
    ELSE
    BEGIN
        PRINT 'Database creation deferred. Use CreateOrganisationDatabase procedure when ready.';
    END
    
    -- Return the new Organisation code
    SELECT @OrganisationCode as NewOrganisationCode, @DatabaseName as DatabaseName;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[BuildColumnList]
-- ============================================


/*##################################*/
/*    Build Column List             */
/*##################################*/

-- =============================================
-- 1. Helper procedure to build column list for INSERT
-- =============================================
CREATE   PROCEDURE [core].[BuildColumnList]
    @entityName NVARCHAR(128),
    @columnList NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @isLink BIT = CASE WHEN CHARINDEX('_', @entityName, 1) > 0 THEN 1 ELSE 0 END;
    
    -- Get entity columns from temp table
    SELECT @columnList = STRING_AGG(column_name, ', ') WITHIN GROUP (ORDER BY ordinal)
    FROM #ParsedEntityColumns
    WHERE entity_name = @entityName;
    
    -- Add standard columns based on entity type
    IF @isLink = 1
        SET @columnList = 'LNK_ID, ' + @columnList + ', LOAD_TS, SRC';
    ELSE
        SET @columnList = @columnList + ', EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC';
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[BuildSelectClause]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[BuildSelectClause]
    @entityName NVARCHAR(128),
    @intSchema NVARCHAR(128),
    @selectClause NVARCHAR(MAX) OUTPUT,
    @partitionExpression NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @isLink BIT = CASE WHEN CHARINDEX('_', @entityName, 1) > 0 THEN 1 ELSE 0 END;
    DECLARE @linkIdPart NVARCHAR(MAX) = '';
    DECLARE @columnsPart NVARCHAR(MAX);
    DECLARE @standardPart NVARCHAR(MAX);

    -- Build LINK ID hash if this is a link entity
    IF @isLink = 1
    BEGIN
        SELECT @linkIdPart =
            'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' +
            STRING_AGG(
                CASE hash_type
                    WHEN 1 THEN 'CONCAT_WS(''|'', ' + column_name + ', ''' + @intSchema + ''')'
                    WHEN 2 THEN column_name
                END, ', '
            ) WITHIN GROUP (ORDER BY ordinal) + ') AS VARBINARY(MAX))) AS LNK_ID'
        FROM #ParsedSourceColumns
        WHERE entity_name = @entityName AND hash_type > 0;

        -- Partition expression without alias
        SELECT @partitionExpression =
            'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' +
            STRING_AGG(
                CASE hash_type
                    WHEN 1 THEN 'CONCAT_WS(''|'', ' + column_name + ', ''' + @intSchema + ''')'
                    WHEN 2 THEN column_name
                END, ', '
            ) WITHIN GROUP (ORDER BY ordinal) + ') AS VARBINARY(MAX)))'
        FROM #ParsedSourceColumns
        WHERE entity_name = @entityName AND hash_type > 0;
    END
    ELSE
    BEGIN
        -- For hubs/satellites, extract the partition expression (HUB_ID without alias)
        SELECT TOP 1 @partitionExpression =
            'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' + column_name + ', ''' + @intSchema + ''') AS VARBINARY(MAX)))'
        FROM #ParsedSourceColumns
        WHERE entity_name = @entityName AND hash_type = 1
        ORDER BY ordinal;
    END;

    -- Build columns part with aliases from entity_columns
    -- hash:0 columns are wrapped with fnCleanForDisplay to sanitise
    -- display characters (e.g. straight apostrophe) at DV load time
    SELECT @columnsPart = STRING_AGG(
        CASE sc.hash_type
            WHEN 0 THEN 'core.fnCleanForDisplay(' + sc.column_name + ')'
            WHEN 1 THEN 'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' + sc.column_name + ', ''' + @intSchema + ''') AS VARBINARY(MAX)))'
            WHEN 2 THEN 'HASHBYTES(''SHA2_256'', CAST(' + sc.column_name + ' AS VARBINARY(MAX)))'
        END + ' AS ' + ec.column_name, ', '
    ) WITHIN GROUP (ORDER BY sc.ordinal)
    FROM #ParsedSourceColumns sc
    JOIN #ParsedEntityColumns ec ON sc.entity_name = ec.entity_name AND sc.ordinal = ec.ordinal
    WHERE sc.entity_name = @entityName;

    -- Add standard columns with aliases
    IF @isLink = 1
        SET @standardPart = ', GETDATE() AS LOAD_TS, ''' + @intSchema + ''' AS SRC';
    ELSE
        SET @standardPart = ', CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''' + @intSchema + ''' AS SRC';

    -- Build final select clause
    IF LEN(@linkIdPart) > 0
        SET @selectClause = @linkIdPart + ', ' + @columnsPart + @standardPart;
    ELSE
        SET @selectClause = @columnsPart + @standardPart;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[CreateDatabaseSchemas]
-- ============================================

/*##################################*/
/*    Create Database Schemas   */
/*################################## */

CREATE   PROCEDURE [core].[CreateDatabaseSchemas]
     @DatabaseName NVARCHAR(128),
    @SchemaList NVARCHAR(MAX) = 'core,load,stage,datavault,presentation'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @SchemaName NVARCHAR(128);
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @Position INT;
    DECLARE @NextPosition INT;
    DECLARE @SchemaCount INT = 0;
    DECLARE @SuccessCount INT = 0;
    DECLARE @FullSpName NVARCHAR(256);
    
    -- Validate database exists
    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
    BEGIN
        RAISERROR('Database %s does not exist.', 16, 1, @DatabaseName);
        RETURN;
    END
    
    PRINT 'Creating schemas in database: ' + @DatabaseName;
    PRINT 'Schema list: ' + @SchemaList;
    
    -- Build the fully qualified sp_executesql name for the target database
    SET @FullSpName = QUOTENAME(@DatabaseName) + '.sys.sp_executesql';
    
    -- Parse comma-separated schema list
    SET @SchemaList = @SchemaList + ','; -- Add trailing comma for parsing
    SET @Position = 1;
    
    WHILE @Position <= LEN(@SchemaList)
    BEGIN
        SET @NextPosition = CHARINDEX(',', @SchemaList, @Position);
        
        IF @NextPosition > @Position
        BEGIN
            SET @SchemaName = LTRIM(RTRIM(SUBSTRING(@SchemaList, @Position, @NextPosition - @Position)));
            
            IF LEN(@SchemaName) > 0
            BEGIN
                SET @SchemaCount = @SchemaCount + 1;
                
                BEGIN TRY
                    PRINT 'Creating schema: [' + @SchemaName + ']';
                    
                    -- Check if schema exists using database-specific query
                    SET @SQL = 'SELECT COUNT(*) FROM sys.schemas WHERE name = ''' + @SchemaName + '''';
                    
                    DECLARE @SchemaExists INT;
                    DECLARE @ParamDef NVARCHAR(100) = '@Count INT OUTPUT';
                    
                    -- Execute in the target database context
                    EXEC @FullSpName @SQL, @ParamDef, @Count = @SchemaExists OUTPUT;
                    
                    IF @SchemaExists = 0
                    BEGIN
                        -- Create the schema using database-specific sp_executesql
                        SET @SQL = 'CREATE SCHEMA ' + QUOTENAME(@SchemaName);
                        EXEC @FullSpName @SQL;
                        PRINT 'Successfully created schema: [' + @SchemaName + ']';
                    END
                    ELSE
                    BEGIN
                        PRINT 'Schema [' + @SchemaName + '] already exists - skipping';
                    END
                    
                    SET @SuccessCount = @SuccessCount + 1;
                    
                END TRY
                BEGIN CATCH
                    SET @ErrorMessage = ERROR_MESSAGE();
                    PRINT 'Failed to create schema [' + @SchemaName + ']: ' + @ErrorMessage;
                    -- Continue with next schema rather than failing completely
                END CATCH
            END
        END
        
        SET @Position = @NextPosition + 1;
    END
    
    PRINT 'Schema creation complete. Created/Verified: ' + CAST(@SuccessCount AS NVARCHAR(10)) + ' of ' + CAST(@SchemaCount AS NVARCHAR(10)) + ' schemas.';
    
    -- Return success/failure info
    IF @SuccessCount = @SchemaCount
    BEGIN
        PRINT 'All schemas created successfully.';
        RETURN 0; -- Success
    END
    ELSE
    BEGIN
        PRINT 'Some schemas failed to create.';
        RETURN 1; -- Partial failure
    END
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[CreateIntegrationSchema]
-- ============================================

/*##################################*/
/*    Create Integration Schemas   */
/*##################################*/

CREATE   PROCEDURE [core].[CreateIntegrationSchema]
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
    FROM [core].[Integrations]
    WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1;
    
    IF @SchemaName IS NULL
    BEGIN
        RAISERROR('Integration with ID %d not found or inactive.', 16, 1, @IntegrationID);
        RETURN;
    END
    
    BEGIN TRY
        -- Check if schema already exists
        IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
        BEGIN
            PRINT 'Schema [' + @SchemaName + '] already exists. Updating integration record.';
            -- Update status to indicate schema exists
            UPDATE [core].[Integrations]
            SET [SchemaCreated] = 1,
                [SchemaCreatedDate] = GETDATE(),
                [ModifiedBy] = SYSTEM_USER,
                [ModifiedDate] = GETDATE()
            WHERE [IntegrationID] = @IntegrationID;
            RETURN;
        END
        
        -- Create the schema
        PRINT 'Creating schema: [' + @SchemaName + ']';
        SET @SQL = 'CREATE SCHEMA ' + QUOTENAME(@SchemaName);
        EXEC sp_executesql @SQL;
        
        -- Create standard tables in the new schema
        SET @SQL = '
        EXEC [core].[sp_CreateIntegrationTables] 
        @DatabaseName = ''core'',
        @SchemaName = ' + QUOTENAME(@SchemaName);
        
        EXEC sp_executesql @SQL;

        SET @SQL = '
        EXEC [core].[sp_CreateGlobalParametersTools]
        @DatabaseName = ''core'',
        @SchemaName = ' + QUOTENAME(@SchemaName);
        
        EXEC sp_executesql @SQL;

        -- Update integration record to success
        UPDATE [core].[Integrations]
        SET [SchemaCreated] = 1,
            [SchemaCreatedDate] = GETDATE(),
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [IntegrationID] = @IntegrationID;
        
        PRINT 'Schema created successfully: [' + @SchemaName + ']';
        
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Schema creation failed';
    END CATCH
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[CreateNewDataSetVersion]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[CreateNewDataSetVersion]
    @DataSet NVARCHAR(100),
    @VisualizationType NVARCHAR(100),
    @BaseVersion INT = NULL,
    @NewStatus NVARCHAR(20) = 'BUILD',
    @Description NVARCHAR(500) = NULL,
    @CreatedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMsg NVARCHAR(500);
    DECLARE @NewVersion INT;
    DECLARE @BaseQuery NVARCHAR(MAX);
    DECLARE @BaseParameterMappings NVARCHAR(MAX);
    DECLARE @BaseFilterDefinitions NVARCHAR(MAX);
    DECLARE @BaseDescription NVARCHAR(500);
    
    IF @CreatedBy IS NULL SET @CreatedBy = SUSER_SNAME();
    
    -- Get the base version details
    IF @BaseVersion IS NULL
    BEGIN
        -- Use current LIVE version as base
        SELECT TOP 1 
            @BaseVersion = Version,
            @BaseQuery = QueryTemplate,
            @BaseParameterMappings = ParameterMappings,
            @BaseFilterDefinitions = FilterDefinitions,
            @BaseDescription = Description
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = @VisualizationType 
        AND Status = 'LIVE'
        ORDER BY Version DESC;
    END
    ELSE
    BEGIN
        -- Use specified version as base
        SELECT 
            @BaseQuery = QueryTemplate,
            @BaseParameterMappings = ParameterMappings,
            @BaseFilterDefinitions = FilterDefinitions,
            @BaseDescription = Description
        FROM [core].[core].[VisualisationQueries] 
        WHERE DataSetName = @DataSet 
        AND VisualizationType = @VisualizationType 
        AND Version = @BaseVersion;
    END
    
    -- Validate base version exists
    IF @BaseQuery IS NULL
    BEGIN
        SET @ErrorMsg = 'Base version not found for DataSet "' + @DataSet + '" and VisualizationType "' + @VisualizationType + '"';
        RAISERROR(@ErrorMsg, 16, 1);
        RETURN;
    END
    
    -- Calculate new version number
    SELECT @NewVersion = ISNULL(MAX(Version), 0) + 1
    FROM [core].[core].[VisualisationQueries] 
    WHERE DataSetName = @DataSet 
    AND VisualizationType = @VisualizationType;
    
    -- Use provided description or copy from base
    IF @Description IS NULL SET @Description = @BaseDescription;
    
    BEGIN TRY
        -- Insert new version
        INSERT INTO [core].[core].[VisualisationQueries] (
            DataSetName,
            VisualizationType,
            Version,
            Status,
            QueryTemplate,
            ParameterMappings,
            FilterDefinitions,
            Description,
            CreatedBy,
            ModifiedBy
        )
        VALUES (
            @DataSet,
            @VisualizationType,
            @NewVersion,
            @NewStatus,
            @BaseQuery,
            @BaseParameterMappings,
            @BaseFilterDefinitions,
            @Description,
            @CreatedBy,
            @CreatedBy
        );
        
        PRINT 'Successfully created version ' + CAST(@NewVersion AS NVARCHAR) + ' with status ' + @NewStatus;
        
        -- Return the new version details
        SELECT 
            DataSetName,
            VisualizationType,
            Version,
            Status,
            Description,
            CreatedDate,
            CreatedBy
        FROM [core].[core].[VisualisationQueries]
        WHERE DataSetName = @DataSet 
        AND VisualizationType = @VisualizationType 
        AND Version = @NewVersion;
        
    END TRY
    BEGIN CATCH
        SET @ErrorMsg = 'Error creating new version: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[CreateOrganisationDatabase]
-- ============================================

/*##################################*/
/*       Create Org Database       */
/*##################################*/

CREATE   PROCEDURE [core].[CreateOrganisationDatabase] 
    @OrganisationCode uniqueidentifier,
    @OrganisationPrefix nvarchar(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DatabaseName nvarchar(128);
    DECLARE @OrganisationName nvarchar(255);
    DECLARE @SQL nvarchar(max);
    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @OrganisationCodeStr nvarchar(36);
    
    -- Convert GUID to string once for reuse
    SET @OrganisationCodeStr = CONVERT(nvarchar(36), @OrganisationCode);
    
    -- Get Organisation details
    SELECT 
        @DatabaseName = @OrganisationPrefix + '_XMS_' + @OrganisationCodeStr,
        @OrganisationName = [OrganisationName]
    FROM [core].[Organisations]
    WHERE [OrganisationCode] = @OrganisationCode AND [IsActive] = 1;
    
    IF @DatabaseName IS NULL
    BEGIN
        RAISERROR('Organisation with code %s not found or inactive.', 16, 1, @OrganisationCodeStr);
        RETURN;
    END
    
    -- Check if database already exists
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
    BEGIN
        PRINT 'Database ' + @DatabaseName + ' already exists. Skipping creation.';
        -- Update status to ACTIVE since DB exists
        UPDATE [core].[Organisations]
        SET [DatabaseStatus] = 'ACTIVE',
            [DatabaseCreated] = 1,
            [DatabaseCreatedDate] = GETDATE(),
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationCode] = @OrganisationCode;
        RETURN;
    END
    
    -- Update status to CREATING
    UPDATE [core].[Organisations]
    SET [DatabaseStatus] = 'CREATING',
        [DatabaseName] = @DatabaseName,
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [OrganisationCode] = @OrganisationCode;
    
    BEGIN TRY
        -- Create the database
        PRINT 'Creating database: ' + @DatabaseName;
        SET @SQL = 'CREATE DATABASE ' + QUOTENAME(@DatabaseName);
        EXEC sp_executesql @SQL;
        
        -- Create schemas
       BEGIN TRY
            DECLARE @SchemaList TABLE (SchemaName NVARCHAR(128));
    
            INSERT INTO @SchemaList VALUES ('core'), ('datavault'), ('load'), ('stage'), ('presentation'),('reference');
            SET @SQL = N'';
    
            SELECT @SQL = @SQL + N'
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + SchemaName + N''')
            BEGIN
                EXEC(''CREATE SCHEMA [' + SchemaName + N']'');
                PRINT ''✓ Created schema: ' + SchemaName + N''';
            END
            ELSE
                PRINT ''✓ Schema already exists: ' + SchemaName + N''';
            '
            FROM @SchemaList;
    
            DECLARE @metasql NVARCHAR(MAX) = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
            EXEC (@metasql);
    
            PRINT 'Schema creation completed successfully';
    
        END TRY
        BEGIN CATCH
            PRINT 'Error creating schemas: ' + ERROR_MESSAGE();
        END CATCH

        SET @SQL = '
        EXEC [core].[sp_GenerateDataVaultTables] 
            @DatabaseName = ' + QUOTENAME(@DatabaseName) + ',
            @SchemaName = ''datavault'',
            @ExecuteSQL = 1;
         ' ;
        
        EXEC sp_executesql @SQL;

        SET @SQL = '
        EXEC [core].[sp_DeployObjects]
        @DatabaseName = ' + QUOTENAME(@DatabaseName) + ',
        @SchemaName = ''core''';
        
        EXEC sp_executesql @SQL;

        SET @SQL = '
        EXEC [core].[DeployPresentationTables]
        @DatabaseName = ' + QUOTENAME(@DatabaseName) 
        ;
        
        EXEC sp_executesql @SQL;

        SET @SQL = '
        EXEC ' + QUOTENAME(@DatabaseName) + '.core.[sp_InitEntityDeltaParameters]'
        ;
        
        EXEC sp_executesql @SQL;


        -- Update Organisation record to success
        UPDATE [core].[Organisations]
        SET [DatabaseStatus] = 'ACTIVE',
            [DatabaseCreated] = 1,
            [DatabaseCreatedDate] = GETDATE(),
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationCode] = @OrganisationCode;
        
        PRINT 'Database created successfully: ' + @DatabaseName;
        
    END TRY
    BEGIN CATCH
        -- Update status to FAILED
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE [core].[Organisations]
        SET [DatabaseStatus] = 'FAILED',
            [Notes] = 'Database creation failed: ' + @ErrorMessage,
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationCode] = @OrganisationCode;
        
        PRINT 'Database creation failed: ' + @ErrorMessage;
        RAISERROR('Failed to create database %s: %s', 16, 1, @DatabaseName, @ErrorMessage);
    END CATCH
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[CreatePendingDatabases]
-- ============================================

/*##################################*/
/*    Create Pending Org Database    */
/*##################################*/

CREATE   PROCEDURE [core].[CreatePendingDatabases]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrganisationCode uniqueidentifier;
    DECLARE @OrganisationName nvarchar(255);
    DECLARE @OrganisationPrefix nvarchar(255);
    DECLARE @ProcessedCount int = 0;
    
    PRINT 'Processing Organisations with pending database creation...';
    
    -- Find Organisations that need database creation
    DECLARE pending_cursor CURSOR FOR
    SELECT [OrganisationCode], [OrganisationName], [OrganisationPrefix]
    FROM [core].[Organisations]
    WHERE [DatabaseCreationRequested] = 1 
      AND [DatabaseCreated] = 0 
      AND [DatabaseStatus] IN ('PENDING', 'FAILED')
      AND [IsActive] = 1;
    
    OPEN pending_cursor;
    FETCH NEXT FROM pending_cursor INTO @OrganisationCode, @OrganisationName, @OrganisationPrefix;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            PRINT 'Creating database for: ' + @OrganisationName;
            EXEC [core].[CreateOrganisationDatabase] @OrganisationCode = @OrganisationCode, @OrganisationPrefix = @OrganisationPrefix;
            SET @ProcessedCount = @ProcessedCount + 1;
        END TRY
        BEGIN CATCH
            PRINT 'Failed to create database for ' + @OrganisationName + ': ' + ERROR_MESSAGE();
        END CATCH
        
        FETCH NEXT FROM pending_cursor INTO @OrganisationCode, @OrganisationName, @OrganisationPrefix;
    END
    
    CLOSE pending_cursor;
    DEALLOCATE pending_cursor;
    
    PRINT 'Processed ' + CAST(@ProcessedCount AS nvarchar(10)) + ' pending database creation requests.';
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[GetDataSetVersionHistory]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[GetDataSetVersionHistory]
    @DataSet NVARCHAR(100),
    @VisualizationType NVARCHAR(100)
AS
BEGIN
    SELECT 
        DataSetName,
        VisualizationType,
        Version,
        Status,
        Description,
        CreatedDate,
        CreatedBy,
        ModifiedDate,
        ModifiedBy
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = @DataSet 
    AND VisualizationType = @VisualizationType
    ORDER BY Version DESC;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[GetIntegrationEndpoints]
-- ============================================

/*##################################*/
/*    Get Integration EndPoints   */
/*##################################*/

CREATE   PROCEDURE [core].[GetIntegrationEndpoints]
    @IntegrationID int,
    @ActiveOnly bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SchemaName nvarchar(128);
    DECLARE @SQL nvarchar(max);
    
    -- Get integration schema name
    SELECT @SchemaName = [SchemaName]
    FROM [core].[Integrations] 
    WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1;
    
    IF @SchemaName IS NULL
    BEGIN
        RAISERROR('Integration with ID %d not found or inactive.', 16, 1, @IntegrationID);
        RETURN;
    END
    
    -- Check if schema exists
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = @SchemaName)
    BEGIN
        RAISERROR('Integration schema [%s] does not exist.', 16, 1, @SchemaName);
        RETURN;
    END
    
    -- Build dynamic SQL to query the integration schema
    SET @SQL = '
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
    FROM ' + QUOTENAME(@SchemaName) + '.[APIEndpoints]
    WHERE (' + CAST(@ActiveOnly AS nvarchar(1)) + ' = 0 OR [IsActive] = 1)
    ORDER BY [EndpointName];
    ';
    
    -- Execute the dynamic SQL
    EXEC sp_executesql @SQL;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[GetIntegrations]
-- ============================================

/*##################################*/
/*    Get Integrations     */
/*##################################*/

CREATE   PROCEDURE [core].[GetIntegrations]
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
        (SELECT COUNT(*) FROM [core].[OrganisationIntegrations] ci WHERE ci.[IntegrationID] = i.[IntegrationID] AND ci.[IsEnabled] = 1) AS [OrganisationCount]
    FROM [core].[Integrations] i
    LEFT JOIN sys.schemas s ON i.[SchemaName] = s.name
    WHERE (@ActiveOnly = 0 OR i.[IsActive] = 1)
    ORDER BY i.[IntegrationName];
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[GetOrganisationIntegrations]
-- ============================================

/*##################################*/
/*    Get Organisation Integrations     */
/*##################################*/

CREATE   PROCEDURE [core].[GetOrganisationIntegrations]
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
    FROM [core].[OrganisationIntegrations] ci
    INNER JOIN [core].[Organisations] c ON ci.[OrganisationID] = c.[OrganisationID]
    INNER JOIN [core].[Integrations] i ON ci.[IntegrationID] = i.[IntegrationID]
    WHERE (@OrganisationID IS NULL OR ci.[OrganisationID] = @OrganisationID)
      AND (@IntegrationID IS NULL OR ci.[IntegrationID] = @IntegrationID)
      AND (@EnabledOnly = 0 OR ci.[IsEnabled] = 1)
      AND c.[IsActive] = 1
      AND i.[IsActive] = 1
    ORDER BY c.[OrganisationName], i.[IntegrationName];
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[GetOrganisations]
-- ============================================

/*##################################*/
/*    Get Organisations           */
/*##################################*/

CREATE   PROCEDURE [core].[GetOrganisations]
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
    FROM [core].[Organisations] c
    LEFT JOIN sys.databases d ON c.[DatabaseName] = d.name AND @IncludeDatabaseExists = 1
    WHERE (@ActiveOnly = 0 OR c.[IsActive] = 1)
    ORDER BY c.[CreatedDate] DESC;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[GetOrgIntegrations]
-- ============================================

/*##################################*/
/*    Get Org Integrations              */
/*##################################*/

CREATE   PROCEDURE [core].[GetOrgIntegrations]
    @DatabaseName NVARCHAR(4000) = NULL,
    @SchemaName NVARCHAR(4000) = NULL 
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        O.DatabaseName AS OrganisationDatabase,
        I.SchemaName AS IntegrationSchema,
        I.APIEndpointDetail
    FROM
        core.Integrations I
    INNER JOIN
        core.OrganisationIntegrations OI
        ON I.IntegrationID = OI.IntegrationID
    INNER JOIN
        core.Organisations O
        ON O.OrganisationID = OI.OrganisationID
    WHERE (@DatabaseName IS NULL OR O.DatabaseName = @DatabaseName) 
    AND (@SchemaName IS NULL OR I.SchemaName = @SchemaName)
    ORDER BY 1,2;
END
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[ListAllDataSets]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[ListAllDataSets]
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SELECT 
        DataSetName,
        VisualizationType,
        Version,
        Status,
        Description,
        CreatedDate,
        CreatedBy,
        ModifiedDate,
        ModifiedBy
    FROM [core].[core].[VisualisationQueries]
    WHERE (@Status IS NULL OR Status = @Status)
    ORDER BY VisualizationType, DataSetName, Version DESC;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[ListDataSetsForVisualization]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[ListDataSetsForVisualization]
    @VisualizationType NVARCHAR(100),
    @Status NVARCHAR(20) = 'LIVE'
AS
BEGIN
    SELECT 
        DataSetName,
        Version,
        Status,
        Description,
        CreatedDate,
        CreatedBy,
        ModifiedDate,
        ModifiedBy
    FROM [core].[core].[VisualisationQueries]
    WHERE VisualizationType = @VisualizationType
    AND (@Status IS NULL OR Status = @Status)
    ORDER BY DataSetName, Version DESC;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[MapOrganisationToIntegration]
-- ============================================

/*##################################*/
/*    Map Org Integrations              */
/*##################################*/

CREATE   PROCEDURE [core].[MapOrganisationToIntegration]
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
    IF NOT EXISTS (SELECT 1 FROM [core].[Organisations] WHERE [OrganisationID] = @OrganisationID AND [IsActive] = 1)
    BEGIN
        RAISERROR('Organisation with ID %d not found or inactive.', 16, 1, @OrganisationID);
        RETURN;
    END
    
    -- Validate integration exists
    IF NOT EXISTS (SELECT 1 FROM [core].[Integrations] WHERE [IntegrationID] = @IntegrationID AND [IsActive] = 1)
    BEGIN
        RAISERROR('Integration with ID %d not found or inactive.', 16, 1, @IntegrationID);
        RETURN;
    END
    
    -- Check if mapping already exists
    IF EXISTS (SELECT 1 FROM [core].[OrganisationIntegrations] WHERE [OrganisationID] = @OrganisationID AND [IntegrationID] = @IntegrationID)
    BEGIN
        -- Update existing mapping
        UPDATE [core].[OrganisationIntegrations]
        SET [ConnectionString] = ISNULL(@ConnectionString, [ConnectionString]),
            [APIKey] = ISNULL(@APIKey, [APIKey]),
            [Username] = ISNULL(@Username, [Username]),
            [PasswordHash] = ISNULL(@PasswordHash, [PasswordHash]),
            [BaseURL] = ISNULL(@BaseURL, [BaseURL]),
            [CustomSettings] = ISNULL(@CustomSettings, [CustomSettings]),
            [Notes] = ISNULL(@Notes, [Notes]),
            [IsEnabled] = 1,
            [SyncStatus] = 'PENDING',
            [ModifiedBy] = SYSTEM_USER,
            [ModifiedDate] = GETDATE()
        WHERE [OrganisationID] = @OrganisationID AND [IntegrationID] = @IntegrationID;
        
        SELECT @NewMappingID = [OrganisationIntegrationID] 
        FROM [core].[OrganisationIntegrations] 
        WHERE [OrganisationID] = @OrganisationID AND [IntegrationID] = @IntegrationID;
        
        PRINT 'Organisation-Integration mapping updated (ID: ' + CAST(@NewMappingID AS nvarchar(10)) + ')';
    END
    ELSE
    BEGIN
        -- Insert new mapping
        INSERT INTO [core].[OrganisationIntegrations] 
        ([OrganisationID], [IntegrationID], [ConnectionString], [APIKey], [Username], [PasswordHash], 
         [BaseURL], [CustomSettings], [Notes])
        VALUES 
        (@OrganisationID, @IntegrationID, @ConnectionString, @APIKey, @Username, @PasswordHash, 
         @BaseURL, @CustomSettings, @Notes);
        
        SET @NewMappingID = SCOPE_IDENTITY();
        PRINT 'Organisation-Integration mapping created (ID: ' + CAST(@NewMappingID AS nvarchar(10)) + ')';
    END
    
    -- Return the mapping ID
    SELECT @NewMappingID as OrganisationIntegrationID;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[ProcessSingleEntityMapping]
-- ============================================

/*########################################*/
/*    Process Single Entity Mappings      */
/*########################################*/

CREATE   PROCEDURE [core].[ProcessSingleEntityMapping]
    @intSchema NVARCHAR(128),
    @entityName NVARCHAR(128),
    @sourceTable NVARCHAR(128),
    @stagingControlTable NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @columnList NVARCHAR(MAX);
    DECLARE @selectClause NVARCHAR(MAX);
    DECLARE @partitionExpression NVARCHAR(MAX);
    DECLARE @querySql NVARCHAR(MAX);
    DECLARE @stepName NVARCHAR(256) = 'Data Vault load - ' + @entityName;
    DECLARE @description NVARCHAR(512) = 'Data Vault load step for ' + @entityName;
    DECLARE @sql NVARCHAR(MAX);
    
    -- Build column list for INSERT
    EXEC [core].[BuildColumnList] 
        @entityName = @entityName,
        @columnList = @columnList OUTPUT;
    
    -- Build SELECT clause and partition expression
    EXEC [core].[BuildSelectClause]
        @entityName = @entityName,
        @intSchema = @intSchema,
        @selectClause = @selectClause OUTPUT,
        @partitionExpression = @partitionExpression OUTPUT;
    
    -- Build complete query SQL with ROW_NUMBER() to eliminate duplicates
    SET @querySql = 
        'INSERT INTO [load].' + @entityName + ' (' + @columnList + ') ' +
        'SELECT ' + @columnList + ' FROM (' +
        'SELECT ' + @selectClause + ', ' +
        'ROW_NUMBER() OVER (PARTITION BY ' + @partitionExpression + ' ORDER BY (SELECT NULL)) AS rn ' +
        'FROM stage.' + @sourceTable + 
        ') sub WHERE rn = 1';
    
    -- MERGE into StagingControl
    SET @sql = N'
    MERGE ' + @stagingControlTable + N' AS target
    USING (
        SELECT 
            @stepName AS step_name,
            @entityName AS staging_table,
            1 AS tier,
            ''Load'' AS step_type,
            @description AS description,
            @querySql AS query_sql
    ) AS source ON target.step_name = source.step_name
    
    WHEN MATCHED THEN
        UPDATE SET
            staging_table = source.staging_table,
            tier = source.tier,
            step_type = source.step_type,
            description = source.description,
            query_sql = source.query_sql
    
    WHEN NOT MATCHED THEN
        INSERT (step_name, staging_table, tier, step_type, description, query_sql, staging_columns)
        VALUES (source.step_name, source.staging_table, source.tier, source.step_type, 
                source.description, source.query_sql, ''[]'');';
    
    EXEC sp_executesql @sql, 
        N'@stepName NVARCHAR(256), @entityName NVARCHAR(128), @description NVARCHAR(512), @querySql NVARCHAR(MAX)',
        @stepName, @entityName, @description, @querySql;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[PromoteDataSetToLive]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[PromoteDataSetToLive]
    @DataSet NVARCHAR(100),
    @VisualizationType NVARCHAR(100),
    @Version INT,
    @ModifiedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMsg NVARCHAR(500);
    
    IF @ModifiedBy IS NULL SET @ModifiedBy = SUSER_SNAME();
    
    -- Validate the version exists
    IF NOT EXISTS (SELECT 1 FROM [core].[core].[VisualisationQueries] 
                  WHERE DataSetName = @DataSet 
                  AND VisualizationType = @VisualizationType 
                  AND Version = @Version)
    BEGIN
        SET @ErrorMsg = 'Version ' + CAST(@Version AS NVARCHAR) + ' not found for DataSet "' + @DataSet + '" and VisualizationType "' + @VisualizationType + '"';
        RAISERROR(@ErrorMsg, 16, 1);
        RETURN;
    END
    
    -- Check current status
    DECLARE @CurrentStatus NVARCHAR(20);
    SELECT @CurrentStatus = Status 
    FROM [core].[core].[VisualisationQueries] 
    WHERE DataSetName = @DataSet 
    AND VisualizationType = @VisualizationType 
    AND Version = @Version;
    
    IF @CurrentStatus = 'LIVE'
    BEGIN
        PRINT 'Version is already LIVE';
        RETURN;
    END
    
    BEGIN TRY
        -- Update the specified version to LIVE (trigger will handle retiring the previous LIVE version)
        UPDATE [core].[core].[VisualisationQueries] 
        SET Status = 'LIVE',
            ModifiedDate = GETDATE(),
            ModifiedBy = @ModifiedBy
        WHERE DataSetName = @DataSet 
        AND VisualizationType = @VisualizationType 
        AND Version = @Version;
        
        PRINT 'Successfully promoted version ' + CAST(@Version AS NVARCHAR) + ' to LIVE';
    END TRY
    BEGIN CATCH
        SET @ErrorMsg = 'Error promoting version to LIVE: ' + ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[SetParameter]
-- ============================================

/*##################################*/
/*    Set Params              */
/*##################################*/

CREATE   PROCEDURE [core].[SetParameter]
            @ParameterKey nvarchar(100),
            @ParameterValue nvarchar(4000),
            @DataType varchar(20) = 'STRING',
            @Category nvarchar(50) = NULL,
            @Description nvarchar(500) = NULL
        AS
        BEGIN
            SET NOCOUNT ON;
            
            -- Validate DataType
            IF @DataType NOT IN ('STRING', 'INT', 'DECIMAL', 'BOOLEAN', 'DATE', 'DATETIME', 'JSON')
            BEGIN
                RAISERROR('Invalid DataType. Must be one of: STRING, INT, DECIMAL, BOOLEAN, DATE, DATETIME, JSON', 16, 1);
                RETURN;
            END
            
            -- Insert or Update
            IF EXISTS (SELECT 1 FROM [core].[GlobalParameters] WHERE [ParameterKey] = @ParameterKey)
            BEGIN
                UPDATE [core].[GlobalParameters]
                SET [ParameterValue] = @ParameterValue,
                    [DataType] = @DataType,
                    [Category] = ISNULL(@Category, [Category]),
                    [Description] = ISNULL(@Description, [Description]),
                    [ModifiedBy] = SYSTEM_USER,
                    [ModifiedDate] = GETDATE(),
                    [Version] = [Version] + 1
                WHERE [ParameterKey] = @ParameterKey;
                
                PRINT 'Parameter updated: ' + @ParameterKey;
            END
            ELSE
            BEGIN
                INSERT INTO [core].[GlobalParameters] 
                ([ParameterKey], [ParameterValue], [DataType], [Category], [Description])
                VALUES 
                (@ParameterKey, @ParameterValue, @DataType, @Category, @Description);
                
                PRINT 'Parameter created: ' + @ParameterKey;
            END
        END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[sp_BuildParentPresentationSQL]
-- ============================================
-- ==============================================
-- Parent Organisation Reporting: sp_BuildParentPresentationSQL
-- Date: 2026-03-09
-- Deploy to: core database only
-- ==============================================

CREATE   PROCEDURE [core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode UNIQUEIDENTIFIER,
    @SourceTableOrQuery NVARCHAR(MAX),
    @IsRawQuery BIT = 0,
    @ResultSQL NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = N'';
    DECLARE @ChildDBName NVARCHAR(128);
    DECLARE @ChildOrgCode UNIQUEIDENTIFIER;
    DECLARE @ChildOrgName NVARCHAR(255);
    DECLARE @First BIT = 1;

    DECLARE child_cursor CURSOR FOR
    SELECT [OrganisationCode], [OrganisationName], [DatabaseName]
    FROM [core].[core].[Organisations]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1
      AND [DatabaseCreated] = 1
      AND [DatabaseName] IS NOT NULL
    ORDER BY [OrganisationName];

    OPEN child_cursor;
    FETCH NEXT FROM child_cursor INTO @ChildOrgCode, @ChildOrgName, @ChildDBName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @First = 0
            SET @SQL = @SQL + N' UNION ALL ';

        IF @IsRawQuery = 1
        BEGIN
            -- Replace {DB} and {ORG_CODE} and {ORG_NAME} placeholders
            DECLARE @ChildSQL NVARCHAR(MAX) = @SourceTableOrQuery;
            SET @ChildSQL = REPLACE(@ChildSQL, N'{DB}', QUOTENAME(@ChildDBName));
            SET @ChildSQL = REPLACE(@ChildSQL, N'{ORG_CODE}', CAST(@ChildOrgCode AS NVARCHAR(36)));
            SET @ChildSQL = REPLACE(@ChildSQL, N'{ORG_NAME}', REPLACE(@ChildOrgName, N'''', N''''''));
            SET @SQL = @SQL + @ChildSQL;
        END
        ELSE
        BEGIN
            -- Simple table select with org identifiers prepended
            SET @SQL = @SQL + N'SELECT ''' + CAST(@ChildOrgCode AS NVARCHAR(36)) + N''' AS ORG_CODE, N'''
                + REPLACE(@ChildOrgName, N'''', N'''''') + N''' AS ORG_NAME, T.* FROM '
                + QUOTENAME(@ChildDBName) + N'.' + @SourceTableOrQuery + N' T';
        END;

        SET @First = 0;
        FETCH NEXT FROM child_cursor INTO @ChildOrgCode, @ChildOrgName, @ChildDBName;
    END;

    CLOSE child_cursor;
    DEALLOCATE child_cursor;

    SET @ResultSQL = @SQL;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[sp_SignalChildCompletion]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[sp_SignalChildCompletion]
    @ChildOrganisationCode UNIQUEIDENTIFIER,
    @CompletionDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CompletionDate IS NULL
        SET @CompletionDate = CAST(GETDATE() AS DATE);

    -- Find parent org for this child
    DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
    SELECT @ParentOrgCode = [ParentOrganisationCode]
    FROM [core].[Organisations]
    WHERE [OrganisationCode] = @ChildOrganisationCode
      AND [IsActive] = 1;

    -- If no parent, nothing to do
    IF @ParentOrgCode IS NULL
    BEGIN
        PRINT 'No parent organisation found for child. Skipping quorum check.';
        RETURN 0;
    END;

    -- Upsert completion signal
    MERGE [core].[ParentBuildStatus] AS target
    USING (SELECT @ParentOrgCode, @ChildOrganisationCode, @CompletionDate, GETDATE())
        AS source (ParentOrganisationCode, ChildOrganisationCode, LastCompletedDate, CompletedAt)
    ON target.[ParentOrganisationCode] = source.[ParentOrganisationCode]
       AND target.[ChildOrganisationCode] = source.[ChildOrganisationCode]
       AND target.[LastCompletedDate] = source.[LastCompletedDate]
    WHEN MATCHED THEN
        UPDATE SET [CompletedAt] = source.[CompletedAt]
    WHEN NOT MATCHED THEN
        INSERT ([ParentOrganisationCode], [ChildOrganisationCode], [LastCompletedDate], [CompletedAt])
        VALUES (source.[ParentOrganisationCode], source.[ChildOrganisationCode], source.[LastCompletedDate], source.[CompletedAt]);

    -- Acquire exclusive lock to prevent double-trigger
    DECLARE @LockResource NVARCHAR(255) = N'ParentBuild_' + CAST(@ParentOrgCode AS NVARCHAR(36));
    DECLARE @LockResult INT;
    EXEC @LockResult = sp_getapplock
        @Resource = @LockResource,
        @LockMode = 'Exclusive',
        @LockOwner = 'Session',
        @LockTimeout = 0;

    IF @LockResult < 0
    BEGIN
        PRINT 'Another session is handling quorum check. Exiting.';
        RETURN 0;
    END;

    -- Check quorum
    DECLARE @TotalChildren INT;
    DECLARE @CompletedChildren INT;
    DECLARE @QuorumPercentage DECIMAL(5,2);
    DECLARE @ParentDatabaseName NVARCHAR(128);

    -- Get parent org config
    SELECT @QuorumPercentage = [QuorumPercentage],
           @ParentDatabaseName = [DatabaseName]
    FROM [core].[Organisations]
    WHERE [OrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1
      AND [DatabaseCreated] = 1;

    IF @ParentDatabaseName IS NULL
    BEGIN
        EXEC sp_releaseapplock
            @Resource = @LockResource,
            @LockOwner = 'Session';
        PRINT 'Parent organisation database not yet created. Skipping quorum check.';
        RETURN 0;
    END;

    -- Count total active children
    SELECT @TotalChildren = COUNT(*)
    FROM [core].[Organisations]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1;

    -- Count children completed today
    SELECT @CompletedChildren = COUNT(*)
    FROM [core].[ParentBuildStatus]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [LastCompletedDate] = @CompletionDate;

    DECLARE @ActualPercentage DECIMAL(5,2);
    SET @ActualPercentage = CASE WHEN @TotalChildren > 0
        THEN CAST(@CompletedChildren AS DECIMAL(5,2)) / CAST(@TotalChildren AS DECIMAL(5,2)) * 100.00
        ELSE 0 END;

    PRINT 'Quorum check: ' + CAST(@CompletedChildren AS VARCHAR) + '/' + CAST(@TotalChildren AS VARCHAR)
        + ' children completed (' + CAST(@ActualPercentage AS VARCHAR) + '%). Threshold: ' + CAST(@QuorumPercentage AS VARCHAR) + '%';

    IF @ActualPercentage >= @QuorumPercentage
    BEGIN
        PRINT 'Quorum met. Triggering parent presentation build for ' + @ParentDatabaseName;

        -- Populate calendar in parent database
        -- Parent orgs have no DV loads, so sp_PopulateCalendar is never triggered
        -- by the normal pipeline. Call it here before the presentation build.
        DECLARE @CalendarSQL NVARCHAR(MAX);
        SET @CalendarSQL = N'EXEC ' + QUOTENAME(@ParentDatabaseName) + N'.[core].[sp_PopulateCalendar]';
        BEGIN TRY
            EXEC sp_executesql @CalendarSQL;
            PRINT 'Parent calendar populated successfully.';
        END TRY
        BEGIN CATCH
            PRINT 'Warning: Parent calendar population failed: ' + ERROR_MESSAGE();
            -- Non-fatal: continue with presentation build
        END CATCH;

        -- Execute parent presentation build (tier 100+ only)
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = N'EXEC ' + QUOTENAME(@ParentDatabaseName) + N'.[core].[sp_ProcessPresentation] @TierFilter = 100';

        BEGIN TRY
            EXEC sp_executesql @SQL;
            PRINT 'Parent presentation build completed successfully.';
        END TRY
        BEGIN CATCH
            PRINT 'Parent presentation build failed: ' + ERROR_MESSAGE();
            EXEC sp_releaseapplock
                @Resource = @LockResource,
                @LockOwner = 'Session';
            RETURN 1;
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT 'Quorum not yet met. Waiting for more children to complete.';
    END;

    EXEC sp_releaseapplock
        @Resource = @LockResource,
        @LockOwner = 'Session';

    RETURN 0;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[SyncDatabaseStatus]
-- ============================================


/*##################################*/
/*    Sync DB Status              */
/*##################################*/

CREATE   PROCEDURE [core].[SyncDatabaseStatus]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UpdatedCount int = 0;
    
    PRINT 'Synchronizing database status with actual databases...';
    
    -- Update Organisations where database exists but status shows otherwise
    UPDATE c 
    SET [DatabaseStatus] = 'ACTIVE',
        [DatabaseCreated] = 1,
        [DatabaseCreatedDate] = ISNULL([DatabaseCreatedDate], GETDATE()),
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    FROM [core].[Organisations] c
    INNER JOIN sys.databases d ON c.[DatabaseName] = d.name
    WHERE c.[DatabaseStatus] != 'ACTIVE' OR c.[DatabaseCreated] = 0;
    
    SET @UpdatedCount = @@ROWCOUNT;
    
    -- Update Organisations where database doesn't exist but status shows ACTIVE
    UPDATE c 
    SET [DatabaseStatus] = 'FAILED',
        [DatabaseCreated] = 0,
        [Notes] = 'Database not found during sync - ' + ISNULL([Notes], ''),
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    FROM [core].[Organisations] c
    LEFT JOIN sys.databases d ON c.[DatabaseName] = d.name
    WHERE d.name IS NULL AND c.[DatabaseStatus] = 'ACTIVE';
    
    SET @UpdatedCount = @UpdatedCount + @@ROWCOUNT;
    
    PRINT 'Database status synchronization completed. Records updated: ' + CAST(@UpdatedCount AS nvarchar(10));
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[UpdateOrganisationStatus]
-- ============================================


/*##################################*/
/*    Update Org Status              */
/*##################################*/


CREATE   PROCEDURE [core].[UpdateOrganisationStatus]
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
    IF @DatabaseStatus IS NOT NULL AND @DatabaseStatus NOT IN ('PENDING', 'CREATING', 'ACTIVE', 'FAILED', 'INACTIVE', 'MAINTENANCE', 'ARCHIVED')
    BEGIN
        RAISERROR('Invalid DatabaseStatus. Must be one of: PENDING, CREATING, ACTIVE, FAILED, INACTIVE, MAINTENANCE, ARCHIVED', 16, 1);
        RETURN;
    END
    
    -- Update Organisation record
    UPDATE [core].[Organisations]
    SET [DatabaseStatus] = ISNULL(@DatabaseStatus, [DatabaseStatus]),
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [Notes] = ISNULL(@Notes, [Notes]),
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [OrganisationCode] = @OrganisationCode;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Organisation with code %s not found.', 16, 1, @OrganisationCodeStr);
        RETURN;
    END
    
    PRINT 'Organisation status updated for: ' + @OrganisationCodeStr;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[UploadEntityMappings]
-- ============================================


/*##################################*/
/*    Upload Entity Mappings       */
/*##################################*/

CREATE   PROCEDURE [core].[UploadEntityMappings]
    @intSchema NVARCHAR(128),
    @entity NVARCHAR(128) = NULL,
    @sourceTableSchema NVARCHAR(128) = 'stage'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @entityMappingsTable NVARCHAR(256);
    DECLARE @stagingControlTable NVARCHAR(256);
    DECLARE @totalRows INT = 0;
    DECLARE @sql NVARCHAR(MAX);
    
    -- Build fully qualified table names
    SET @entityMappingsTable = QUOTENAME('core') + '.' + QUOTENAME(@intSchema) + '.' + QUOTENAME('EntityMappings');
    SET @stagingControlTable = QUOTENAME('core') + '.' + QUOTENAME(@intSchema) + '.' + QUOTENAME('StagingControl');
    
    -- Create temp table to store entity mappings
    IF OBJECT_ID('tempdb..#EntityMappings') IS NOT NULL DROP TABLE #EntityMappings;
    CREATE TABLE #EntityMappings (
        entity_name NVARCHAR(128),
        source_table NVARCHAR(128),
        source_columns NVARCHAR(MAX),
        entity_columns NVARCHAR(MAX)
    );
    
    -- Create temp tables for parsed JSON data
    IF OBJECT_ID('tempdb..#ParsedSourceColumns') IS NOT NULL DROP TABLE #ParsedSourceColumns;
    CREATE TABLE #ParsedSourceColumns (
        entity_name NVARCHAR(128),
        ordinal INT,
        column_name NVARCHAR(128),
        hash_type INT
    );
    
    IF OBJECT_ID('tempdb..#ParsedEntityColumns') IS NOT NULL DROP TABLE #ParsedEntityColumns;
    CREATE TABLE #ParsedEntityColumns (
        entity_name NVARCHAR(128),
        ordinal INT,
        column_name NVARCHAR(128)
    );
    
    -- Load entity mappings into temp table
    SET @sql = N'
    INSERT INTO #EntityMappings (entity_name, source_table, source_columns, entity_columns)
    SELECT entity_name, source_table, source_columns, entity_columns
    FROM ' + @entityMappingsTable + N'
    WHERE (@entity IS NULL OR entity_name = @entity)';
    
    EXEC sp_executesql @sql, N'@entity NVARCHAR(128)', @entity;
    
    -- Parse all JSON data upfront directly from temp table
    -- Parse source_columns JSON
    INSERT INTO #ParsedSourceColumns (entity_name, ordinal, column_name, hash_type)
    SELECT 
        em.entity_name,
        ROW_NUMBER() OVER (PARTITION BY em.entity_name ORDER BY (SELECT NULL)) AS ordinal,
        JSON_VALUE(sc.value, '$.name') AS column_name,
        CAST(JSON_VALUE(sc.value, '$.hash') AS INT) AS hash_type
    FROM #EntityMappings em
    CROSS APPLY OPENJSON(em.source_columns) sc;
    
    -- Parse entity_columns JSON (simple array of strings, use value directly)
    INSERT INTO #ParsedEntityColumns (entity_name, ordinal, column_name)
    SELECT 
        em.entity_name,
        ROW_NUMBER() OVER (PARTITION BY em.entity_name ORDER BY (SELECT NULL)) AS ordinal,
        ec.value AS column_name
    FROM #EntityMappings em
    CROSS APPLY OPENJSON(em.entity_columns) ec;
    
    -- Process each entity mapping
    DECLARE @currentEntity NVARCHAR(128);
    DECLARE @currentSourceTable NVARCHAR(128);
    
    DECLARE entity_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT entity_name, source_table
        FROM #EntityMappings;
    
    OPEN entity_cursor;
    
    FETCH NEXT FROM entity_cursor INTO @currentEntity, @currentSourceTable;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC [core].[ProcessSingleEntityMapping]
            @intSchema = @intSchema,
            @entityName = @currentEntity,
            @sourceTable = @currentSourceTable,
            @stagingControlTable = @stagingControlTable;
        
        SET @totalRows = @totalRows + 1;
        
        FETCH NEXT FROM entity_cursor INTO @currentEntity, @currentSourceTable;
    END;
    
    CLOSE entity_cursor;
    DEALLOCATE entity_cursor;
    
    -- Clean up
    DROP TABLE #EntityMappings;
    DROP TABLE #ParsedSourceColumns;
    DROP TABLE #ParsedEntityColumns;
    
    -- Return count of affected entities
    SELECT @totalRows AS RowsAffected;
END;
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[ValidateDataSetQuery]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[ValidateDataSetQuery]
    @DataSet NVARCHAR(100),
    @VisualizationType NVARCHAR(100),
    @Status NVARCHAR(20) = 'LIVE'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    
    SELECT @SQL = QueryTemplate 
    FROM [core].[core].[VisualisationQueries] 
    WHERE DataSetName = @DataSet 
    AND VisualizationType = @VisualizationType 
    AND Status = @Status;
    
    IF @SQL IS NULL
    BEGIN
        PRINT 'DataSet/Visualization combination not found or not in ' + @Status + ' status';
        RETURN;
    END
    
    BEGIN TRY
        -- Basic SQL syntax validation (replace @FilterClause with empty string for parsing)
        DECLARE @TestSQL NVARCHAR(MAX) = REPLACE(@SQL, '@FilterClause', '');
        SET @TestSQL = 'SET PARSEONLY ON; ' + @TestSQL + '; SET PARSEONLY OFF;';
        EXEC sp_executesql @TestSQL;
        PRINT 'Query syntax is valid';
    END TRY
    BEGIN CATCH
        PRINT 'Query syntax error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


