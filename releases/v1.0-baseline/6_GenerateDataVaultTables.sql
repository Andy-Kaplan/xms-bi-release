-- ============================================
-- 6_GenerateDataVaultTables.sql
-- Regenerated from UAT 2026-07-06 15:17:16
-- Server: xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net
-- ============================================

-- ============================================
-- SQL_STORED_PROCEDURE : [core].[sp_GenerateDataVaultTables]
-- ============================================
CREATE OR ALTER PROCEDURE [core].[sp_GenerateDataVaultTables]
    @DatabaseName NVARCHAR(128) = 'demoXMS',  -- Target database name (NULL = current database)
    @SchemaName NVARCHAR(128) = 'datavault',   -- Target schema name
    @EntityDefinitionTable NVARCHAR(255) = '[core].[DataVaultEntities]',
    @ExecuteSQL BIT = 1  -- Set to 0 to only print SQL without executing
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX) = '';
    DECLARE @EntityName NVARCHAR(255);
    DECLARE @AttributeNames NVARCHAR(MAX);
    DECLARE @AttributeTypes NVARCHAR(MAX);
    DECLARE @HubSQL NVARCHAR(MAX);
    DECLARE @SatSQL NVARCHAR(MAX);
    DECLARE @LoadSQL NVARCHAR(MAX);
    DECLARE @LnkSQL NVARCHAR(MAX);
    DECLARE @SatLnkSQL NVARCHAR(MAX);
    DECLARE @Version INT;
    DECLARE @FullSchemaName NVARCHAR(400);
    DECLARE @FullLoadSchemaName NVARCHAR(400);
    DECLARE @IsLinkEntity BIT;
    DECLARE @IsSelfReferencing BIT;
    DECLARE @EntityParts TABLE (PartNum INT, EntityPart NVARCHAR(255));
    DECLARE @EntityPartCount INT;
    
    -- Declare attribute processing table variable at procedure level to ensure proper clearing
    DECLARE @AttributeList TABLE (
        AttributeOrder INT,
        AttributeName NVARCHAR(255),
        AttributeType NVARCHAR(255),
        IsNullable BIT
    );
    
    -- Build schema names without database prefix since we'll switch to target database
    SET @FullSchemaName = QUOTENAME(@SchemaName);
    SET @FullLoadSchemaName = QUOTENAME('load');
    
    -- Cursor to process each entity
    DECLARE entity_cursor CURSOR FOR
    SELECT 
        e.ENTITY_NAME,
        e.ATTRIBUTE_NAMES,
        e.ATTRIBUTE_TYPES,
        e.VERSION
    FROM (
        -- Get highest version per entity where release state is 'Live'
        SELECT 
            ENTITY_NAME,
            ATTRIBUTE_NAMES,
            ATTRIBUTE_TYPES,
            VERSION,
            ROW_NUMBER() OVER (PARTITION BY ENTITY_NAME ORDER BY VERSION DESC) as rn
        FROM [core].[DataVaultEntities]
        WHERE RELEASE_STATE = 'Live'
    ) e
    WHERE e.rn = 1;
    
    OPEN entity_cursor;
    FETCH NEXT FROM entity_cursor INTO @EntityName, @AttributeNames, @AttributeTypes, @Version;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '-- Processing Entity: ' + @EntityName + ' (Version: ' + CAST(@Version AS NVARCHAR(10)) + ')';
        PRINT '-- RAW AttributeNames from cursor: ' + ISNULL(@AttributeNames, 'NULL');
        PRINT '-- RAW AttributeTypes from cursor: ' + LEFT(ISNULL(@AttributeTypes, 'NULL'), 500) + '...';
        
        -- Initialize/Clear ALL variables for this iteration
        SET @HubSQL = '';
        SET @SatSQL = '';
        SET @LoadSQL = '';
        SET @LnkSQL = '';
        SET @SatLnkSQL = '';
        SET @IsSelfReferencing = 0;
        
        -- Clear entity parts table
        DELETE FROM @EntityParts;
        
        -- Clear attribute list table
        DELETE FROM @AttributeList;
        
        -- Check if this is a link entity (contains underscore)
        SET @IsLinkEntity = CASE WHEN CHARINDEX('_', @EntityName) > 0 THEN 1 ELSE 0 END;
        
        IF @IsLinkEntity = 1
        BEGIN
            -- Parse entity name into parts
            DECLARE @EntityNameCopy NVARCHAR(255) = @EntityName;
            DECLARE @ParsePartNum INT = 1;
            DECLARE @UnderscorePos INT;
            
            WHILE CHARINDEX('_', @EntityNameCopy) > 0
            BEGIN
                SET @UnderscorePos = CHARINDEX('_', @EntityNameCopy);
                INSERT INTO @EntityParts (PartNum, EntityPart) 
                VALUES (@ParsePartNum, LEFT(@EntityNameCopy, @UnderscorePos - 1));
                SET @EntityNameCopy = SUBSTRING(@EntityNameCopy, @UnderscorePos + 1, LEN(@EntityNameCopy));
                SET @ParsePartNum = @ParsePartNum + 1;
            END;
            
            -- Add the last part
            INSERT INTO @EntityParts (PartNum, EntityPart) VALUES (@ParsePartNum, @EntityNameCopy);
            
            SELECT @EntityPartCount = COUNT(*) FROM @EntityParts;
            
            -- Check if this is a self-referencing link (same entity name appears twice)
            SET @IsSelfReferencing = 0;
            IF @EntityPartCount = 2
            BEGIN
                DECLARE @FirstPart NVARCHAR(255), @SecondPart NVARCHAR(255);
                SELECT @FirstPart = EntityPart FROM @EntityParts WHERE PartNum = 1;
                SELECT @SecondPart = EntityPart FROM @EntityParts WHERE PartNum = 2;
                
                IF @FirstPart = @SecondPart
                BEGIN
                    SET @IsSelfReferencing = 1;
                    PRINT '-- Self-referencing link detected: ' + @FirstPart + '_' + @SecondPart;
                END;
            END;
            
            PRINT '-- Link Entity detected with ' + CAST(@EntityPartCount AS NVARCHAR(10)) + ' parts' + 
                  CASE WHEN @IsSelfReferencing = 1 THEN ' (Self-Referencing)' ELSE '' END;
        END;
        
        IF @IsLinkEntity = 0
        BEGIN
            -- Generate HUB table SQL for regular entities
            SET @HubSQL = 'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[HUB_' + @EntityName + ']'') AND type in (N''U''))
BEGIN
    CREATE TABLE ' + @FullSchemaName + '.[HUB_' + @EntityName + '] (
        -- Data Vault Infrastructure Columns
        [HUB_ID] [BINARY](32) NOT NULL,                    -- SHA-256 hash key
        [SRC] [NVARCHAR](255) NOT NULL,                    -- Record source
        [IS_DELETED] [BIT] NULL,                           -- Soft deletion flag
        [LOAD_TS] [DATETIME2](7) NOT NULL,                 -- Load timestamp
        
        -- Constraints
        CONSTRAINT [PK_HUB_' + @EntityName + '] PRIMARY KEY CLUSTERED ([HUB_ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
              ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';

            -- Generate SAT table SQL with dynamic attributes for regular entities
            SET @SatSQL = 'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[SAT_' + @EntityName + ']'') AND type in (N''U''))
BEGIN
    CREATE TABLE ' + @FullSchemaName + '.[SAT_' + @EntityName + '] (
        -- Data Vault Infrastructure Columns
        [HUB_ID] [BINARY](32) NOT NULL,                    -- Foreign key to hub
        [SRC] [NVARCHAR](255) NOT NULL,                    -- Record source
        [LOAD_TS] [DATETIME2](7) NOT NULL,                 -- Load timestamp
        [EFFECTIVEFROM] [DATETIME2](7) NOT NULL,
        [EFFECTIVETO] [DATETIME2](7) NULL,
        [CURRENT_FLAG] [BIT] NOT NULL,
        [IS_DELETED] [BIT] NULL';
            
            -- Generate LOAD table SQL with dynamic attributes (same structure as SAT)
            SET @LoadSQL = 'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullLoadSchemaName + '.[' + @EntityName + ']'') AND type in (N''U''))
BEGIN
    CREATE TABLE ' + @FullLoadSchemaName + '.[' + @EntityName + '] (
        -- Data Vault Infrastructure Columns
        [HUB_ID] [BINARY](32) NOT NULL,                    -- Foreign key to hub
        [SRC] [NVARCHAR](255) NOT NULL,                    -- Record source
        [LOAD_TS] [DATETIME2](7) NOT NULL,                 -- Load timestamp
        [EFFECTIVEFROM] [DATETIME2](7) NOT NULL,
        [EFFECTIVETO] [DATETIME2](7) NULL,
        [CURRENT_FLAG] [BIT] NOT NULL,
        [IS_DELETED] [BIT] NULL';
        END
        ELSE
        BEGIN
            -- Generate LNK table SQL for link entities
            SET @LnkSQL = 'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[LNK_' + @EntityName + ']'') AND type in (N''U''))
BEGIN
    CREATE TABLE ' + @FullSchemaName + '.[LNK_' + @EntityName + '] (
        -- Data Vault Infrastructure Columns
        [LNK_ID] [BINARY](32) NOT NULL,                    -- SHA-256 hash key
        [SRC] [NVARCHAR](255) NOT NULL,                    -- Record source
        [LOAD_TS] [DATETIME2](7) NOT NULL';
            
            -- Add hub reference columns for each entity part
            DECLARE @LnkPartNum INT = 1;
            DECLARE @EntityPart NVARCHAR(255);
            
            IF @IsSelfReferencing = 1
            BEGIN
                -- Use PARENT/CHILD naming for self-referencing links
                SET @LnkSQL = @LnkSQL + ',
        [PARENT_HUB_ID] [BINARY](32) NOT NULL,
        [CHILD_HUB_ID] [BINARY](32) NOT NULL';
            END
            ELSE
            BEGIN
                -- Use standard entity name-based naming
                WHILE @LnkPartNum <= @EntityPartCount
                BEGIN
                    SELECT @EntityPart = EntityPart FROM @EntityParts WHERE PartNum = @LnkPartNum;
                    SET @LnkSQL = @LnkSQL + ',
        [' + UPPER(@EntityPart) + '_HUB_ID] [BINARY](32) NOT NULL';
                    SET @LnkPartNum = @LnkPartNum + 1;
                END;
            END;
            
            -- Add aggregation columns if only 2 parts
            IF @EntityPartCount = 2
            BEGIN
                IF @IsSelfReferencing = 1
                BEGIN
                    -- Use PARENT/CHILD aggregation naming for self-referencing links
                    SET @LnkSQL = @LnkSQL + ',
        [PARENT_AGG] [BIT] NULL,
        [CHILD_AGG] [BIT] NULL';
                END
                ELSE
                BEGIN
                    -- Use standard entity name-based aggregation naming
                    SELECT @EntityPart = EntityPart FROM @EntityParts WHERE PartNum = 1;
                    SET @LnkSQL = @LnkSQL + ',
        [' + UPPER(@EntityPart) + '_AGG] [BIT] NULL';
                    
                    SELECT @EntityPart = EntityPart FROM @EntityParts WHERE PartNum = 2;
                    SET @LnkSQL = @LnkSQL + ',
        [' + UPPER(@EntityPart) + '_AGG] [BIT] NULL';
                END;
            END;
            
            -- Complete LNK table structure
            SET @LnkSQL = @LnkSQL + '
        
        -- Constraints
        CONSTRAINT [PK_LNK_' + @EntityName + '] PRIMARY KEY CLUSTERED ([LNK_ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
              ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';

            -- Note: Foreign key constraints for LNK tables will be added after all tables are created

            -- Generate SAT_LNK table if attributes exist
            IF ISNULL(@AttributeNames, '') <> '' AND @AttributeNames <> '[]'
            BEGIN
                SET @SatLnkSQL = 'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[SAT_LNK_' + @EntityName + ']'') AND type in (N''U''))
BEGIN
    CREATE TABLE ' + @FullSchemaName + '.[SAT_LNK_' + @EntityName + '] (
        -- Data Vault Infrastructure Columns
        [LNK_ID] [BINARY](32) NOT NULL,                    -- Foreign key to link
        [SRC] [NVARCHAR](255) NOT NULL,                    -- Record source
        [LOAD_TS] [DATETIME2](7) NOT NULL';
            END
            ELSE
            BEGIN
                SET @SatLnkSQL = '';
            END;
            
            -- Generate LOAD table for link entity (always created)
            SET @LoadSQL = 'IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullLoadSchemaName + '.[' + @EntityName + ']'') AND type in (N''U''))
BEGIN
    CREATE TABLE ' + @FullLoadSchemaName + '.[' + @EntityName + '] (
        -- Data Vault Infrastructure Columns
        [LNK_ID] [BINARY](32) NOT NULL,                    -- Foreign key to link
        [SRC] [NVARCHAR](255) NOT NULL,                    -- Record source
        [LOAD_TS] [DATETIME2](7) NOT NULL';
    
            -- Add hub reference columns to load table
            DECLARE @LoadLnkPartNum INT = 1;
            DECLARE @LoadEntityPart NVARCHAR(255);
            
            IF @IsSelfReferencing = 1
            BEGIN
                -- Use PARENT/CHILD naming for self-referencing links
                SET @LoadSQL = @LoadSQL + ',
        [PARENT_HUB_ID] [BINARY](32) NOT NULL,
        [CHILD_HUB_ID] [BINARY](32) NOT NULL';
            END
            ELSE
            BEGIN
                -- Use standard entity name-based naming
                WHILE @LoadLnkPartNum <= @EntityPartCount
                BEGIN
                    SELECT @LoadEntityPart = EntityPart FROM @EntityParts WHERE PartNum = @LoadLnkPartNum;
                    SET @LoadSQL = @LoadSQL + ',
        [' + UPPER(@LoadEntityPart) + '_HUB_ID] [BINARY](32) NOT NULL';
                    SET @LoadLnkPartNum = @LoadLnkPartNum + 1;
                END;
            END;
            
            -- If attributes exist, add them to the load table structure
            IF ISNULL(@AttributeNames, '') <> '' AND @AttributeNames <> '[]'
            BEGIN
                SET @LoadSQL = @LoadSQL + '';
            END;
        END;
        
        -- Parse JSON and build attribute columns using improved approach
        -- For link entities: uses attributes from the link entity row (e.g., CUSTOMER_ORDER)
        -- For regular entities: uses attributes from the entity row (e.g., CUSTOMER)
        IF (ISNULL(@AttributeNames, '') <> '' AND @AttributeNames <> '[]')
        BEGIN
            -- Initialize ALL attribute processing variables
            DECLARE @AttributeSQL NVARCHAR(MAX) = '';
            DECLARE @CurrentAttributeName NVARCHAR(255) = '';
            DECLARE @CurrentAttributeType NVARCHAR(255) = '';
            DECLARE @CurrentNullable BIT = 0;
            DECLARE @AttributeCount INT = 0;
            
            PRINT '-- Using attributes from entity: ' + @EntityName;
            PRINT '-- AttributeNames JSON: ' + @AttributeNames;
            PRINT '-- AttributeTypes JSON: ' + @AttributeTypes;
            
            -- AttributeList table variable is declared at procedure level and cleared above
            -- Collect all attributes into the table variable for this entity
            INSERT INTO @AttributeList (AttributeOrder, AttributeName, AttributeType, IsNullable)
            SELECT 
                CAST(names.[key] AS INT) as AttributeOrder,
                names.[value] as AttributeName,
                JSON_VALUE(types.[value], '$.data_type') as AttributeType,
                CAST(JSON_VALUE(types.[value], '$.nullable') AS BIT) as IsNullable
            FROM OPENJSON(@AttributeNames) names
            INNER JOIN OPENJSON(@AttributeTypes) types ON names.[key] = types.[key]
            ORDER BY CAST(names.[key] AS INT);

            SELECT @AttributeCount = COUNT(*) FROM @AttributeList;

            -- Debug: Show what attributes were actually loaded
            PRINT '-- Loaded attributes for ' + @EntityName + ':';
            DECLARE @DebugOutput NVARCHAR(MAX) = '';
            SELECT @DebugOutput = @DebugOutput + '[' + AttributeName + '] ' + AttributeType + '; '
            FROM @AttributeList ORDER BY AttributeOrder;
            PRINT '-- ' + @DebugOutput;

            -- Now build the SQL properly with correct comma placement
            DECLARE @AttrOrder INT = 0;  -- Start at 0 since OPENJSON uses 0-based indices
            DECLARE @MaxAttrOrder INT;
            SELECT @MaxAttrOrder = MAX(AttributeOrder) FROM @AttributeList;

            WHILE @AttrOrder <= @MaxAttrOrder
            BEGIN
                SELECT 
                    @CurrentAttributeName = AttributeName,
                    @CurrentAttributeType = AttributeType,
                    @CurrentNullable = IsNullable
                FROM @AttributeList 
                WHERE AttributeOrder = @AttrOrder;
                
                IF @CurrentAttributeName IS NOT NULL
                BEGIN
                    PRINT '-- Processing attribute ' + CAST((@AttrOrder + 1) AS NVARCHAR(10)) + ': [' + @CurrentAttributeName + '] ' + @CurrentAttributeType;
                    
                    -- Add the attribute definition (first attribute needs leading comma to separate from infrastructure columns)
                    IF @AttrOrder = 0
                        SET @AttributeSQL = @AttributeSQL + ',' + CHAR(13) + CHAR(10) + '        [' + @CurrentAttributeName + '] ' + @CurrentAttributeType;
                    ELSE
                        SET @AttributeSQL = @AttributeSQL + CHAR(13) + CHAR(10) + '        [' + @CurrentAttributeName + '] ' + @CurrentAttributeType;
                    
                    -- Add nullable constraint
                    IF @CurrentNullable = 0
                        SET @AttributeSQL = @AttributeSQL + ' NOT NULL';
                    ELSE
                        SET @AttributeSQL = @AttributeSQL + ' NULL';
                    
                    -- Add comma if not the last attribute
                    IF @AttrOrder < @MaxAttrOrder
                        SET @AttributeSQL = @AttributeSQL + ',';
                END;
                
                SET @AttrOrder = @AttrOrder + 1;
            END;
            
            PRINT '-- Found ' + CAST(@AttributeCount AS NVARCHAR(10)) + ' attributes for ' + @EntityName;
            PRINT '-- Built AttributeSQL: ' + @AttributeSQL;
            
            -- Complete table SQL based on entity type
            IF @IsLinkEntity = 0
            BEGIN
                -- Complete SAT table SQL for regular entities
                IF LEN(@AttributeSQL) > 0
                BEGIN
                    SET @SatSQL = @SatSQL + @AttributeSQL;
                END;
                
                SET @SatSQL = @SatSQL + '
        
        -- Constraints
        CONSTRAINT [PK_SAT_' + @EntityName + '] PRIMARY KEY CLUSTERED 
        (
            [HUB_ID] ASC,
            [LOAD_TS] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
                ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';

                -- Complete LOAD table SQL for regular entities
                IF LEN(@AttributeSQL) > 0
                BEGIN
                    SET @LoadSQL = @LoadSQL + @AttributeSQL;
                END;
                
                SET @LoadSQL = @LoadSQL + '
        
        -- Constraints
        CONSTRAINT [PK_LOAD_' + @EntityName + '] PRIMARY KEY CLUSTERED 
        (
            [HUB_ID] ASC,
            [LOAD_TS] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
                ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';
            END
            ELSE
            BEGIN
                -- Complete SAT_LNK table SQL for link entities
                PRINT '-- Completing SAT_LNK table for: ' + @EntityName;
                PRINT '-- AttributeSQL being added: ' + ISNULL(@AttributeSQL, 'NULL');
                
                IF LEN(@AttributeSQL) > 0
                BEGIN
                    SET @SatLnkSQL = @SatLnkSQL + @AttributeSQL;
                END;
                
                SET @SatLnkSQL = @SatLnkSQL + '
        
        -- Constraints
        CONSTRAINT [PK_SAT_LNK_' + @EntityName + '] PRIMARY KEY CLUSTERED 
        (
            [LNK_ID] ASC,
            [LOAD_TS] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
                ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';

                PRINT '-- Complete SAT_LNK SQL: ' + LEFT(@SatLnkSQL, 500) + '...';

                -- Complete LOAD table SQL for link entities with attributes
                IF LEN(@AttributeSQL) > 0
                BEGIN
                    SET @LoadSQL = @LoadSQL + @AttributeSQL;
                END;
                
                SET @LoadSQL = @LoadSQL + '
        
        -- Constraints
        CONSTRAINT [PK_LOAD_' + @EntityName + '] PRIMARY KEY CLUSTERED 
        (
            [LNK_ID] ASC,
            [LOAD_TS] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
                ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';
            END;
        END;
        ELSE
        BEGIN
            -- For entities without attributes, complete the table structures
            PRINT '-- No attributes found for ' + @EntityName + ', completing table structures';
            
            IF @IsLinkEntity = 0
            BEGIN
                -- Complete SAT table for regular entities without attributes
                SET @SatSQL = @SatSQL + '
        
        -- Constraints
        CONSTRAINT [PK_SAT_' + @EntityName + '] PRIMARY KEY CLUSTERED 
        (
            [HUB_ID] ASC,
            [LOAD_TS] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
                ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';

                -- Complete LOAD table for regular entities without attributes
                SET @LoadSQL = @LoadSQL + '
        
        -- Constraints
        CONSTRAINT [PK_LOAD_' + @EntityName + '] PRIMARY KEY CLUSTERED 
        (
            [HUB_ID] ASC,
            [LOAD_TS] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
                ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';
            END
            ELSE
            BEGIN
                -- Complete LOAD table for link entities without attributes
                PRINT '-- Completing LOAD table for link entity without attributes: ' + @EntityName;
                SET @LoadSQL = @LoadSQL + '
        
        -- Constraints
        CONSTRAINT [PK_LOAD_' + @EntityName + '] PRIMARY KEY CLUSTERED 
        (
            [LNK_ID] ASC,
            [LOAD_TS] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
                ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
        ON [PRIMARY]
    ) ON [PRIMARY];
END;
';
            END;
        END;
        
        -- Add table creation statements based on entity type
        IF @IsLinkEntity = 0
        BEGIN
            -- Regular entity tables
            SET @SQL = @SQL + '
-- Create HUB table for ' + @EntityName + '
' + @HubSQL + '

-- Create SAT table for ' + @EntityName + '
' + @SatSQL + '

-- Create LOAD table for ' + @EntityName + ' in load schema
' + @LoadSQL + '

-- Create indexes for performance

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[HUB_' + @EntityName + ']'') AND name = N''IX_HUB_' + @EntityName + '_LOAD_TS'')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_HUB_' + @EntityName + '_LOAD_TS] 
    ON ' + @FullSchemaName + '.[HUB_' + @EntityName + '] ([LOAD_TS] ASC);
END;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[SAT_' + @EntityName + ']'') AND name = N''IX_SAT_' + @EntityName + '_LOAD_TS'')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SAT_' + @EntityName + '_LOAD_TS] 
    ON ' + @FullSchemaName + '.[SAT_' + @EntityName + '] ([LOAD_TS] ASC);
END;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @FullLoadSchemaName + '.[' + @EntityName + ']'') AND name = N''IX_LOAD_' + @EntityName + '_LOAD_TS'')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LOAD_' + @EntityName + '_LOAD_TS] 
    ON ' + @FullLoadSchemaName + '.[' + @EntityName + '] ([LOAD_TS] ASC);
END;


';
        END
        ELSE
        BEGIN
            -- Link entity tables
            SET @SQL = @SQL + '
-- Create LNK table for ' + @EntityName + '
' + @LnkSQL;
            
            IF @SatLnkSQL <> ''
            BEGIN
                SET @SQL = @SQL + '

-- Create SAT_LNK table for ' + @EntityName + '
' + @SatLnkSQL;
            END;
            
            -- Always create LOAD table for link entities
            SET @SQL = @SQL + '

-- Create LOAD table for ' + @EntityName + ' in load schema
' + @LoadSQL;
            
            SET @SQL = @SQL + '

-- Create indexes for performance

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[LNK_' + @EntityName + ']'') AND name = N''IX_LNK_' + @EntityName + '_LOAD_TS'')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LNK_' + @EntityName + '_LOAD_TS] 
    ON ' + @FullSchemaName + '.[LNK_' + @EntityName + '] ([LOAD_TS] ASC);
END;
';

            IF @SatLnkSQL <> ''
            BEGIN
                SET @SQL = @SQL + '
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @FullSchemaName + '.[SAT_LNK_' + @EntityName + ']'') AND name = N''IX_SAT_LNK_' + @EntityName + '_LOAD_TS'')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SAT_LNK_' + @EntityName + '_LOAD_TS] 
    ON ' + @FullSchemaName + '.[SAT_LNK_' + @EntityName + '] ([LOAD_TS] ASC);
END;
';
            END;
            
            -- Always create load table index for link entities
            SET @SQL = @SQL + '
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @FullLoadSchemaName + '.[' + @EntityName + ']'') AND name = N''IX_LOAD_' + @EntityName + '_LOAD_TS'')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LOAD_' + @EntityName + '_LOAD_TS] 
    ON ' + @FullLoadSchemaName + '.[' + @EntityName + '] ([LOAD_TS] ASC);
END;

';
        END;
        
        FETCH NEXT FROM entity_cursor INTO @EntityName, @AttributeNames, @AttributeTypes, @Version;
    END;
    
    CLOSE entity_cursor;
    DEALLOCATE entity_cursor;
    
    -- Execute or print the SQL using metaSQL approach
    IF @ExecuteSQL = 1
    BEGIN
        PRINT '-- Executing SQL statements using metaSQL approach...';
        
        -- Use metaSQL approach if DatabaseName is provided and different from current database
        IF @DatabaseName IS NOT NULL AND @DatabaseName <> DB_NAME()
        BEGIN
            DECLARE @metasql NVARCHAR(MAX) = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
            EXEC (@metasql);
        END
        ELSE
        BEGIN
            -- Execute normally if using current database
            EXEC sp_executesql @SQL;
        END
        
        PRINT '-- Data Vault tables (HUB/LNK, SAT/SAT_LNK, and LOAD) created successfully!';
    END
    ELSE
    BEGIN
        PRINT '-- Generated SQL (set @ExecuteSQL = 1 to execute):';
        
        -- Show metaSQL version if targeting different database
        IF @DatabaseName IS NOT NULL AND @DatabaseName <> DB_NAME()
        BEGIN
            PRINT '-- MetaSQL approach will be used for cross-database execution';
            PRINT '-- Target Database: ' + @DatabaseName;
            PRINT '';
        END
        
        PRINT @SQL;
    END;
    
END;
GO


