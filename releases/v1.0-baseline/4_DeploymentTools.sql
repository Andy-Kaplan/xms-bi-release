-- ============================================
-- 4_DeploymentTools.sql
-- Regenerated from UAT 2026-07-06 15:17:16
-- Server: xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net
-- ============================================

-- ============================================
-- Table: [core].[DeploymentObjects]
-- ============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DeploymentObjects]') AND type in (N'U'))
BEGIN
CREATE TABLE [core].[DeploymentObjects](
	[ObjectID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ObjectType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExecutionOrder] [int] NOT NULL,
	[Category] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreationScript] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DropScript] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_DeploymentObjects] PRIMARY KEY CLUSTERED 
(
	[ObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_DeploymentObjects_Name_Type] UNIQUE NONCLUSTERED 
(
	[ObjectName] ASC,
	[ObjectType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[core].[DeploymentObjects]') AND name = N'IX_DeploymentObjects_Order')
CREATE NONCLUSTERED INDEX [IX_DeploymentObjects_Order] ON [core].[DeploymentObjects]
(
	[ExecutionOrder] ASC,
	[IsActive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Deploymen__IsAct__31B762FC]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DeploymentObjects] ADD  DEFAULT ((1)) FOR [IsActive]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[DF__Deploymen__Creat__32AB8735]') AND type = 'D')
BEGIN
ALTER TABLE [core].[DeploymentObjects] ADD  DEFAULT (getdate()) FOR [CreatedDate]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_DeploymentObjects_Type]') AND parent_object_id = OBJECT_ID(N'[core].[DeploymentObjects]'))
ALTER TABLE [core].[DeploymentObjects]  WITH CHECK ADD  CONSTRAINT [CK_DeploymentObjects_Type] CHECK  (([ObjectType]='SAMPLE_DATA' OR [ObjectType]='INDEX' OR [ObjectType]='PROCEDURE' OR [ObjectType]='FUNCTION' OR [ObjectType]='TABLE'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[core].[CK_DeploymentObjects_Type]') AND parent_object_id = OBJECT_ID(N'[core].[DeploymentObjects]'))
ALTER TABLE [core].[DeploymentObjects] CHECK CONSTRAINT [CK_DeploymentObjects_Type]
GO


-- ============================================
-- SQL_STORED_PROCEDURE : [core].[sp_DeployObjects]
-- ============================================
---- =====================================================================================
---- STEP 2: POPULATE CONFIGURATION TABLE WITH OBJECT DEFINITIONS
---- =====================================================================================

---- Clear existing data (for updates)
----DELETE FROM [core].[DeploymentObjects];

---- TABLE: GlobalParameters
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'GlobalParameters',
--    'TABLE', 
--    10,
--    'Core Tables',
--    'Main table for storing global parameters',
--    N'CREATE TABLE {SCHEMA}.[GlobalParameters] (
--        [ParameterID] int IDENTITY(1,1) NOT NULL,
--        [ParameterKey] nvarchar(100) NOT NULL,
--        [ParameterValue] nvarchar(4000) NULL,
--        [DataType] varchar(20) NOT NULL DEFAULT ''STRING'',
--        [Category] nvarchar(50) NULL,
--        [Description] nvarchar(500) NULL,
--        [IsActive] bit NOT NULL DEFAULT 1,
--        [CreatedBy] nvarchar(100) NOT NULL DEFAULT SYSTEM_USER,
--        [CreatedDate] datetime2 NOT NULL DEFAULT GETDATE(),
--        [ModifiedBy] nvarchar(100) NULL,
--        [ModifiedDate] datetime2 NULL,
--        [Version] int NOT NULL DEFAULT 1,
        
--        CONSTRAINT [PK_{SCHEMA_NAME}_GlobalParameters] PRIMARY KEY CLUSTERED ([ParameterID]),
--        CONSTRAINT [UK_{SCHEMA_NAME}_GlobalParameters_Key] UNIQUE NONCLUSTERED ([ParameterKey]),
--        CONSTRAINT [CK_{SCHEMA_NAME}_GlobalParameters_DataType] CHECK ([DataType] IN (''STRING'', ''INT'', ''DECIMAL'', ''BOOLEAN'', ''DATE'', ''DATETIME'', ''JSON''))
--    );',
--    N'DROP TABLE {SCHEMA}.[GlobalParameters];'
--);

--    -- TABLE: CTL_DV_PROCESS
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'CTL_DV_PROCESS',
--    'TABLE', 
--    100,
--    'Core Tables',
--    'Data Vault Process Table',
--    N'CREATE TABLE {SCHEMA}.[CTL_DV_PROCESS](
--	[JobId] [uniqueidentifier] NOT NULL,
--	[Status] [nvarchar](100) NOT NULL,
--	[StartTS_UTC] [datetime2](7) NOT NULL,
--	[EndTS_UTC] [datetime2](7) NULL,
--	[StgLoadBatchID] [uniqueidentifier] NULL,
--PRIMARY KEY CLUSTERED 
--(
--	[JobId] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY];',
--    N'DROP TABLE {SCHEMA}.[CTL_DV_PROCESS];'
--);

--    -- TABLE: CTL_STG_PROCESS
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'CTL_STG_PROCESS',
--    'TABLE', 
--    101,
--    'Core Tables',
--    'Staging Process Table',
--    N'CREATE TABLE {SCHEMA}.[CTL_STG_PROCESS](
--	[BatchID] [uniqueidentifier] NOT NULL,
--	[StoreID] [nvarchar](100) NOT NULL,
--	[ApiDate] [nvarchar](8) NOT NULL,
--	[Status] [nvarchar](100) NOT NULL,
--	[StartTS_UTC] [datetime2](7) NULL,
--	[EndTS_UTC] [datetime2](7) NULL,
-- CONSTRAINT [PK_CTL_STG_PROCESS] PRIMARY KEY CLUSTERED 
--(
--	[BatchID] ASC,
--	[StoreID] ASC,
--	[ApiDate] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY];',
--    N'DROP TABLE {SCHEMA}.[CTL_STG_PROCESS];'
--);

--   -- TABLE: LOG_DV
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'LOG_DV',
--    'TABLE', 
--    102,
--    'Core Tables',
--    'Data Vault Logging Table',
--    N'CREATE TABLE {SCHEMA}.[LOG_DV](
--	[id] [int] IDENTITY(1,1) NOT NULL,
--	[dv_process_job_id] [uniqueidentifier] NOT NULL,
--	[src] [nvarchar](100) NULL,
--	[entity] [nvarchar](100) NULL,
--	[log_level] [nvarchar](100) NOT NULL,
--	[log_msg] [nvarchar](max) NOT NULL,
--	[logts_utc] [datetime2](7) NOT NULL DEFAULT (sysutcdatetime()),
--PRIMARY KEY CLUSTERED 
--(
--	[id] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];',
--    N'DROP TABLE {SCHEMA}.[LOG_DV];'
--);

--    -- TABLE: LOG_STG
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'LOG_STG',
--    'TABLE', 
--    102,
--    'Core Tables',
--    'Staging Logging Table',
--    N'CREATE TABLE {SCHEMA}.[LOG_STG](
--	[id] [int] IDENTITY(1,1) NOT NULL,
--	[stg_process_batchid] [uniqueidentifier] NOT NULL,
--	[storeid] [nvarchar](100) NULL,
--	[ApiDate] [nvarchar](100) NULL,
--	[log_level] [nvarchar](100) NOT NULL,
--	[log_msg] [nvarchar](max) NOT NULL,
--	[logts_utc] [datetime2](7) NOT NULL DEFAULT (sysutcdatetime()),
--PRIMARY KEY CLUSTERED 
--(
--	[id] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];',
--    N'DROP TABLE {SCHEMA}.[LOG_STG];'
--);

---- INDEXES for GlobalParameters
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'GlobalParameters_Indexes',
--    'INDEX',
--    15,
--    'Indexes',
--    'Indexes for GlobalParameters table',
--    N'CREATE NONCLUSTERED INDEX [IX_{SCHEMA_NAME}_GlobalParameters_Category] 
--    ON {SCHEMA}.[GlobalParameters] ([Category]) 
--    WHERE [IsActive] = 1;

--    CREATE NONCLUSTERED INDEX [IX_{SCHEMA_NAME}_GlobalParameters_Active] 
--    ON {SCHEMA}.[GlobalParameters] ([IsActive]) 
--    INCLUDE ([ParameterKey], [ParameterValue], [DataType]);',
--    N'DROP INDEX IF EXISTS [IX_{SCHEMA_NAME}_GlobalParameters_Category] ON {SCHEMA}.[GlobalParameters];
--    DROP INDEX IF EXISTS [IX_{SCHEMA_NAME}_GlobalParameters_Active] ON {SCHEMA}.[GlobalParameters];'
--);

---- FUNCTION: GetParameter
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'GetParameter',
--    'FUNCTION',
--    20,
--    'Core Functions',
--    'Returns parameter value by key',
--    N'CREATE FUNCTION {SCHEMA}.[GetParameter]
--    (
--        @ParameterKey nvarchar(100)
--    )
--    RETURNS nvarchar(4000)
--    AS
--    BEGIN
--        DECLARE @Value nvarchar(4000);
        
--        SELECT @Value = [ParameterValue]
--        FROM {SCHEMA}.[GlobalParameters]
--        WHERE [ParameterKey] = @ParameterKey 
--          AND [IsActive] = 1;
        
--        RETURN @Value;
--    END;',
--    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetParameter];'
--);

---- FUNCTION: GetParameterWithType
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'GetParameterWithType',
--    'FUNCTION',
--    21,
--    'Core Functions', 
--    'Returns parameter with metadata',
--    N'CREATE FUNCTION {SCHEMA}.[GetParameterWithType]
--    (
--        @ParameterKey nvarchar(100)
--    )
--    RETURNS TABLE
--    AS
--    RETURN
--    (
--        SELECT 
--            [ParameterValue],
--            [DataType],
--            [Category],
--            [Description]
--        FROM {SCHEMA}.[GlobalParameters]
--        WHERE [ParameterKey] = @ParameterKey 
--          AND [IsActive] = 1
--    );',
--    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetParameterWithType];'
--);

---- FUNCTION: GetParameterDataType
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'GetParameterDataType',
--    'FUNCTION',
--    22,
--    'Core Functions',
--    'Returns parameter data type',
--    N'CREATE FUNCTION {SCHEMA}.[GetParameterDataType]
--    (
--        @ParameterKey nvarchar(100)
--    )
--    RETURNS varchar(20)
--    AS
--    BEGIN
--        DECLARE @DataType varchar(20);
        
--        SELECT @DataType = [DataType]
--        FROM {SCHEMA}.[GlobalParameters]
--        WHERE [ParameterKey] = @ParameterKey 
--          AND [IsActive] = 1;
        
--        RETURN @DataType;
--    END;',
--    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetParameterDataType];'
--);

---- FUNCTION: GetTypedParameter
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'GetTypedParameter',
--    'FUNCTION',
--    23,
--    'Core Functions',
--    'Returns parameter with automatic type conversion',
--    N'CREATE FUNCTION {SCHEMA}.[GetTypedParameter]
--    (
--        @ParameterKey nvarchar(100),
--        @OutputDataType varchar(20) = NULL
--    )
--    RETURNS sql_variant
--    AS
--    BEGIN
--        DECLARE @Value nvarchar(4000);
--        DECLARE @DataType varchar(20);
--        DECLARE @Result sql_variant;
        
--        SELECT 
--            @Value = [ParameterValue],
--            @DataType = [DataType]
--        FROM {SCHEMA}.[GlobalParameters]
--        WHERE [ParameterKey] = @ParameterKey 
--          AND [IsActive] = 1;
        
--        -- Optional type validation
--        IF @OutputDataType IS NOT NULL AND @DataType != @OutputDataType
--        BEGIN
--            RETURN NULL;
--        END
        
--        -- Convert based on stored data type
--        IF @DataType = ''INT''
--            SET @Result = CAST(@Value AS int);
--        ELSE IF @DataType = ''DECIMAL''
--            SET @Result = CAST(@Value AS decimal(18,6));
--        ELSE IF @DataType = ''BOOLEAN''
--            SET @Result = CASE WHEN LOWER(@Value) IN (''true'', ''1'', ''yes'') THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END;
--        ELSE IF @DataType = ''DATE''
--            SET @Result = CAST(@Value AS date);
--        ELSE IF @DataType = ''DATETIME''
--            SET @Result = CAST(@Value AS datetime2);
--        ELSE
--            SET @Result = @Value;
        
--        RETURN @Result;
--    END;',
--    N'DROP FUNCTION IF EXISTS {SCHEMA}.[GetTypedParameter];'
--);

---- PROCEDURE: SetParameter
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'SetParameter',
--    'PROCEDURE',
--    30,
--    'Core Procedures',
--    'Sets or updates a parameter value',
--    N'CREATE PROCEDURE {SCHEMA}.[SetParameter]
--        @ParameterKey nvarchar(100),
--        @ParameterValue nvarchar(4000),
--        @DataType varchar(20) = ''STRING'',
--        @Category nvarchar(50) = NULL,
--        @Description nvarchar(500) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        -- Validate DataType
--        IF @DataType NOT IN (''STRING'', ''INT'', ''DECIMAL'', ''BOOLEAN'', ''DATE'', ''DATETIME'', ''JSON'')
--        BEGIN
--            RAISERROR(''Invalid DataType. Must be one of: STRING, INT, DECIMAL, BOOLEAN, DATE, DATETIME, JSON'', 16, 1);
--            RETURN;
--        END
        
--        -- Insert or Update
--        IF EXISTS (SELECT 1 FROM {SCHEMA}.[GlobalParameters] WHERE [ParameterKey] = @ParameterKey)
--        BEGIN
--            UPDATE {SCHEMA}.[GlobalParameters]
--            SET [ParameterValue] = @ParameterValue,
--                [DataType] = @DataType,
--                [Category] = ISNULL(@Category, [Category]),
--                [Description] = ISNULL(@Description, [Description]),
--                [ModifiedBy] = SYSTEM_USER,
--                [ModifiedDate] = GETDATE(),
--                [Version] = [Version] + 1
--            WHERE [ParameterKey] = @ParameterKey;
            
--            PRINT ''Parameter updated: '' + @ParameterKey;
--        END
--        ELSE
--        BEGIN
--            INSERT INTO {SCHEMA}.[GlobalParameters] 
--            ([ParameterKey], [ParameterValue], [DataType], [Category], [Description])
--            VALUES 
--            (@ParameterKey, @ParameterValue, @DataType, @Category, @Description);
            
--            PRINT ''Parameter created: '' + @ParameterKey;
--        END
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[SetParameter];'
--);

---- PROCEDURE: BuildDynamicWhereClause (Converted to stored procedure for cursor support)
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'BuildDynamicWhereClause',
--    'PROCEDURE',
--    20,
--    'Visualization System',
--    'Builds dynamic filter clause with AND conditions based on parameter mappings and filter definitions',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[BuildDynamicWhereClause] 
--        @StartDate DATE,
--        @EndDate DATE,
--        @LocationList NVARCHAR(MAX),
--        @Filters NVARCHAR(MAX),
--        @ParameterMappings NVARCHAR(MAX),
--        @FilterDefinitions NVARCHAR(MAX),
--        @FilterClause NVARCHAR(MAX) OUTPUT
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @StartDateColumn NVARCHAR(100);
--        DECLARE @EndDateColumn NVARCHAR(100);
--        DECLARE @LocationColumn NVARCHAR(100);
        
--        SET @FilterClause = '';
        
--        -- Parse parameter mappings
--        IF @ParameterMappings IS NOT NULL AND ISJSON(@ParameterMappings) = 1
--        BEGIN
--            SET @StartDateColumn = NULLIF(JSON_VALUE(@ParameterMappings, '$.StartDate'),'');
--            SET @EndDateColumn = NULLIF(JSON_VALUE(@ParameterMappings, '$.EndDate'),'');
--            SET @LocationColumn = NULLIF(JSON_VALUE(@ParameterMappings, '$.LocationList'),'');
--        END
        
--        -- Build date filters
--        IF @StartDate IS NOT NULL AND @StartDateColumn IS NOT NULL
--        BEGIN
--            SET @FilterClause = @FilterClause + ' AND ' + @StartDateColumn + ' >= ''' + CONVERT(NVARCHAR, @StartDate, 120) + '''';
--        END
        
--        IF @EndDate IS NOT NULL AND @EndDateColumn IS NOT NULL
--        BEGIN
--            SET @FilterClause = @FilterClause + ' AND ' + @EndDateColumn + ' <= ''' + CONVERT(NVARCHAR, @EndDate, 120) + '''';
--        END
        
--        -- Build location filter (handle comma-separated list)
--        IF @LocationList IS NOT NULL AND @LocationColumn IS NOT NULL
--        BEGIN
--            SET @FilterClause = @FilterClause + ' AND ' + @LocationColumn + ' IN (' + @LocationList + ')';
--        END
        
--        -- Build JSON filters
--        IF @Filters IS NOT NULL AND @FilterDefinitions IS NOT NULL AND ISJSON(@Filters) = 1 AND ISJSON(@FilterDefinitions) = 1
--        BEGIN
--            DECLARE @FilterKey NVARCHAR(100);
--            DECLARE @FilterColumn NVARCHAR(100);
--            DECLARE @FilterType NVARCHAR(20);
--            DECLARE @FilterDataType NVARCHAR(20);
--            DECLARE @FilterValue NVARCHAR(MAX);
            
--            -- Parse each filter from JSON
--            DECLARE filter_cursor CURSOR FOR
--            SELECT [key]
--            FROM OPENJSON(@Filters);
            
--            OPEN filter_cursor;
--            FETCH NEXT FROM filter_cursor INTO @FilterKey;
            
--            WHILE @@FETCH_STATUS = 0
--            BEGIN
--                -- Get filter definition
--                SET @FilterColumn = NULLIF(JSON_VALUE(@FilterDefinitions, '$.' + @FilterKey + '.column'),'');
--                SET @FilterType = NULLIF(JSON_VALUE(@FilterDefinitions, '$.' + @FilterKey + '.type'),'');
--                SET @FilterDataType = NULLIF(JSON_VALUE(@FilterDefinitions, '$.' + @FilterKey + '.dataType'),'');
                
--                IF @FilterColumn IS NOT NULL
--                BEGIN
--                    -- Get filter values and build appropriate format
--                    SELECT @FilterValue = STRING_AGG(
--                        CASE 
--                            WHEN @FilterDataType IN ('INT', 'DECIMAL', 'NUMERIC') THEN value
--                            ELSE ''''+value +''''  -- Escape single quotes
--                        END, 
--                        ', '
--                    )
--                    FROM OPENJSON(@Filters, '$.' + @FilterKey) WITH (value NVARCHAR(MAX) '$');
                    
--                    -- Build filter clause based on type
--                    IF @FilterType = 'IN' AND @FilterValue IS NOT NULL
--                    BEGIN
--                        SET @FilterClause = @FilterClause + ' AND ' + @FilterColumn + ' IN (' + @FilterValue + ')';
--                    END
--                    -- Could add support for other filter types here (EQUALS, LIKE, etc.)
--                END
                
--                FETCH NEXT FROM filter_cursor INTO @FilterKey;
--            END
            
--            CLOSE filter_cursor;
--            DEALLOCATE filter_cursor;
--        END
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[BuildDynamicWhereClause];'
--);

---- PROCEDURE: FilterList
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'FilterList',
--    'PROCEDURE',
--    49,
--    'Visualization Procedures',
--    'Returns a list of filter values for dropdowns',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[FilterList]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''FilterList'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for FilterList or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing FilterList for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[FilterList];'
--);

---- PROCEDURE: BarChartCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'BarChartCard',
--    'PROCEDURE',
--    50,
--    'Visualization Procedures',
--    'Executes bar chart queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[BarChartCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''BarChartCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for BarChartCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[BarChartCard];'
--);

---- PROCEDURE: LineChartCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'LineChartCard',
--    'PROCEDURE',
--    51,
--    'Visualization Procedures',
--    'Executes line chart queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[LineChartCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''LineChartCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for LineChartCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[LineChartCard];'
--);

---- PROCEDURE: PieChartCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'PieChartCard',
--    'PROCEDURE',
--    52,
--    'Visualization Procedures',
--    'Executes pie chart queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[PieChartCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''PieChartCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for PieChartCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[PieChartCard];'
--);

---- PROCEDURE: SingleKPICard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'SingleKPICard',
--    'PROCEDURE',
--    53,
--    'Visualization Procedures',
--    'Executes single KPI queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[SingleKPICard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''SingleKPICard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for SingleKPICard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing SingleKPICard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[SingleKPICard];'
--);

---- PROCEDURE: CustomDataGrid
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'CustomDataGrid',
--    'PROCEDURE',
--    54,
--    'Visualization Procedures',
--    'Executes custom data grid queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CustomDataGrid]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''CustomDataGrid'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for CustomDataGrid or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing CustomDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CustomDataGrid];'
--);

---- PROCEDURE: HeatmapCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'HeatmapCard',
--    'PROCEDURE',
--    55,
--    'Visualization Procedures',
--    'Executes heatmap queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[HeatmapCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''HeatmapCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for HeatmapCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing HeatmapCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[HeatmapCard];'
--);

---- PROCEDURE: CombinedChartCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'CombinedChartCard',
--    'PROCEDURE',
--    56,
--    'Visualization Procedures',
--    'Executes combined chart queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CombinedChartCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''CombinedChartCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for CombinedChartCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing CombinedChartCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CombinedChartCard];'
--);

---- PROCEDURE: TreeViewCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'TreeViewCard',
--    'PROCEDURE',
--    57,
--    'Visualization Procedures',
--    'Executes tree view queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[TreeViewCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''TreeViewCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for TreeViewCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing TreeViewCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[TreeViewCard];'
--);

---- PROCEDURE: StackedBarChartCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'StackedBarChartCard',
--    'PROCEDURE',
--    58,
--    'Visualization Procedures',
--    'Executes stacked bar chart queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StackedBarChartCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''StackedBarChartCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for StackedBarChartCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing StackedBarChartCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[StackedBarChartCard];'
--);

---- PROCEDURE: StatCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'StatCard',
--    'PROCEDURE',
--    59,
--    'Visualization Procedures',
--    'Executes stat card queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[StatCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''StatCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for StatCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing StatCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[StatCard];'
--);

---- PROCEDURE: MultiLineChartCard
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'MultiLineChartCard',
--    'PROCEDURE',
--    60,
--    'Visualization Procedures',
--    'Executes multi-line chart queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[MultiLineChartCard]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''MultiLineChartCard'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for MultiLineChartCard or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing MultiLineChartCard for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[MultiLineChartCard];'
--);

---- PROCEDURE: CustomGroupedDataGrid
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'CustomGroupedDataGrid',
--    'PROCEDURE',
--    61,
--    'Visualization Procedures',
--    'Executes custom grouped data grid queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CustomGroupedDataGrid]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''CustomGroupedDataGrid'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for CustomGroupedDataGrid or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing CustomGroupedDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CustomGroupedDataGrid];'
--);

---- PROCEDURE: CustomPinnedDataGrid
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript], [DropScript])
--VALUES (
--    'CustomPinnedDataGrid',
--    'PROCEDURE',
--    62,
--    'Visualization Procedures',
--    'Executes custom pinned data grid queries based on dataset configuration',
--    N'CREATE OR ALTER PROCEDURE {SCHEMA}.[CustomPinnedDataGrid]
--        @StartDate DATE = NULL,
--        @EndDate DATE = NULL,
--        @LocationList NVARCHAR(MAX) = NULL,
--        @DataSet NVARCHAR(100),
--        @Filters NVARCHAR(MAX) = NULL
--    AS
--    BEGIN
--        SET NOCOUNT ON;
        
--        DECLARE @SQL NVARCHAR(MAX);
--        DECLARE @ErrorMsg NVARCHAR(500);
--        DECLARE @ParameterMappings NVARCHAR(MAX);
--        DECLARE @FilterDefinitions NVARCHAR(MAX);
--        DECLARE @FilterClause NVARCHAR(MAX);
        
--        SELECT 
--            @SQL = QueryTemplate,
--            @ParameterMappings = ParameterMappings,
--            @FilterDefinitions = FilterDefinitions
--        FROM [core].[core].[VisualisationQueries] 
--        WHERE DataSetName = @DataSet 
--        AND VisualizationType = ''CustomPinnedDataGrid'' 
--        AND Status = ''LIVE'';
        
--        IF @SQL IS NULL
--        BEGIN
--            RAISERROR(''DataSet "%s" not found for CustomPinnedDataGrid or inactive'', 16, 1, @DataSet);
--            RETURN;
--        END
        
--        BEGIN TRY
--            EXEC {SCHEMA}.[BuildDynamicWhereClause]
--                @StartDate = @StartDate,
--                @EndDate = @EndDate, 
--                @LocationList = @LocationList, 
--                @Filters = @Filters, 
--                @ParameterMappings = @ParameterMappings, 
--                @FilterDefinitions = @FilterDefinitions,
--                @FilterClause = @FilterClause OUTPUT;
            
--            SET @SQL = REPLACE(@SQL, ''@FilterClause'', @FilterClause);

--            EXEC sp_executesql @SQL;
            
--        END TRY
--        BEGIN CATCH
--            SET @ErrorMsg = ''Error executing CustomPinnedDataGrid for DataSet "'' + @DataSet + ''": '' + ERROR_MESSAGE();
--            RAISERROR(@ErrorMsg, 16, 1);
--        END CATCH
--    END;',
--    N'DROP PROCEDURE IF EXISTS {SCHEMA}.[CustomPinnedDataGrid];'
--);
---- SAMPLE DATA
--INSERT INTO [core].[DeploymentObjects] ([ObjectName], [ObjectType], [ExecutionOrder], [Category], [Description], [CreationScript])
--VALUES (
--    'SampleData',
--    'SAMPLE_DATA',
--    40,
--    'Sample Data',
--    'Insert sample parameters for testing',
--    N'EXEC {SCHEMA}.[SetParameter] 
--        @ParameterKey = ''APP_VERSION'', 
--        @ParameterValue = ''1.0.0'', 
--        @DataType = ''STRING'', 
--        @Category = ''Application'',
--        @Description = ''Current application version'';

--    EXEC {SCHEMA}.[SetParameter] 
--        @ParameterKey = ''MAX_RETRY_ATTEMPTS'', 
--        @ParameterValue = ''3'', 
--        @DataType = ''INT'', 
--        @Category = ''Configuration'',
--        @Description = ''Maximum number of retry attempts'';

--    EXEC {SCHEMA}.[SetParameter] 
--        @ParameterKey = ''MAINTENANCE_MODE'', 
--        @ParameterValue = ''false'', 
--        @DataType = ''BOOLEAN'', 
--        @Category = ''System'',
--        @Description = ''Whether the system is in maintenance mode'';

--    EXEC {SCHEMA}.[SetParameter] 
--        @ParameterKey = ''DEFAULT_TIMEOUT'', 
--        @ParameterValue = ''30.5'', 
--        @DataType = ''DECIMAL'', 
--        @Category = ''Configuration'',
--        @Description = ''Default timeout in seconds'';

--    EXEC {SCHEMA}.[SetParameter] 
--        @ParameterKey = ''LAST_MAINTENANCE_DATE'', 
--        @ParameterValue = ''{CURRENT_DATETIME}'', 
--        @DataType = ''DATETIME'', 
--        @Category = ''System'',
--        @Description = ''Last maintenance date and time'';'
--);

--PRINT 'Configuration data loaded into DeploymentObjects table';
--GO

-- =====================================================================================
-- STEP 3: SMART DEPLOYMENT STORED PROCEDURE
-- =====================================================================================

CREATE   PROCEDURE [core].[sp_DeployObjects]
    @DatabaseName NVARCHAR(128),
    @SchemaName NVARCHAR(128) = 'core',
    @IncludeSampleData BIT = 0,
    @DropExisting BIT = 0,
    @ObjectTypes NVARCHAR(200) = NULL -- Optional filter: 'TABLE,FUNCTION,PROCEDURE' etc.
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for deployment tracking
    DECLARE @StartTime DATETIME2 = GETDATE();
    DECLARE @StepCount INT = 0;
    DECLARE @ErrorCount INT = 0;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @metasql NVARCHAR(MAX);
    DECLARE @ProcessedScript NVARCHAR(MAX);
    
    -- Object processing variables
    DECLARE @ObjectID INT;
    DECLARE @ObjectName NVARCHAR(128);
    DECLARE @ObjectType VARCHAR(20);
    DECLARE @ExecutionOrder INT;
    DECLARE @Category NVARCHAR(50);
    DECLARE @Description NVARCHAR(500);
    DECLARE @CreationScript NVARCHAR(MAX);
    DECLARE @DropScript NVARCHAR(MAX);
    
    -- Create temp table for logging
    CREATE TABLE #DeploymentLog (
        StepNumber INT,
        ObjectName NVARCHAR(128),
        ObjectType VARCHAR(20),
        Status NVARCHAR(20),
        ExecutionTime DATETIME2,
        ErrorMessage NVARCHAR(MAX)
    );
    
    -- Helper procedure for logging
    DECLARE @LogStep NVARCHAR(MAX) = N'
        SET @StepCount = @StepCount + 1;
        INSERT INTO #DeploymentLog VALUES (@StepCount, @ObjectName, @ObjectType, @Status, GETDATE(), @ErrorMsg);
        PRINT FORMAT(GETDATE(), ''HH:mm:ss'') + '' | '' + @Status + '' | '' + @ObjectType + '' | '' + @ObjectName;
        IF @ErrorMsg IS NOT NULL PRINT ''           ERROR: '' + @ErrorMsg;
        IF @Status = ''ERROR'' SET @ErrorCount = @ErrorCount + 1;
    ';
    
    PRINT '=====================================================================================';
    PRINT 'SMART GLOBAL PARAMETERS SYSTEM DEPLOYMENT';
    PRINT 'Target Database: ' + @DatabaseName;
    PRINT 'Target Schema: ' + @SchemaName;
    PRINT 'Include Sample Data: ' + CASE WHEN @IncludeSampleData = 1 THEN 'Yes' ELSE 'No' END;
    PRINT 'Drop Existing: ' + CASE WHEN @DropExisting = 1 THEN 'Yes' ELSE 'No' END;
    IF @ObjectTypes IS NOT NULL PRINT 'Object Types Filter: ' + @ObjectTypes;
    PRINT 'Started: ' + FORMAT(@StartTime, 'yyyy-MM-dd HH:mm:ss');
    PRINT '=====================================================================================';
    PRINT '';
    
    -- =====================================================================================
    -- VALIDATION AND SETUP
    -- =====================================================================================
    
    PRINT '📋 VALIDATION AND SETUP';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    -- Validate database exists
    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
    BEGIN
        PRINT '❌ ERROR: Database ''' + @DatabaseName + ''' does not exist';
        RETURN;
    END
    PRINT '✓ Database validation passed';
    
    -- Create schema if needed
    SET @SQL = N'
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = ''' + @SchemaName + N''')
    BEGIN
        EXEC(''CREATE SCHEMA [' + @SchemaName + N']'');
        PRINT ''✓ Created schema: ' + @SchemaName + N''';
    END
    ELSE
        PRINT ''✓ Schema already exists: ' + @SchemaName + N''';
    ';
    SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
    EXEC (@metasql);
    
    PRINT '';
    
    -- =====================================================================================
    -- DROP EXISTING OBJECTS (IF REQUESTED)
    -- =====================================================================================
    
    IF @DropExisting = 1
    BEGIN
        PRINT '🗑️  DROPPING EXISTING OBJECTS';
        PRINT '───────────────────────────────────────────────────────────────────────────────────';
        
        DECLARE drop_cursor CURSOR FOR
        SELECT ObjectID, ObjectName, ObjectType, DropScript
        FROM [core].[DeploymentObjects]
        WHERE IsActive = 1 
          AND DropScript IS NOT NULL
          AND (@ObjectTypes IS NULL OR ObjectType IN (SELECT value FROM STRING_SPLIT(@ObjectTypes, ',')))
        ORDER BY ExecutionOrder DESC; -- Reverse order for dropping
        
        OPEN drop_cursor;
        FETCH NEXT FROM drop_cursor INTO @ObjectID, @ObjectName, @ObjectType, @DropScript;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            BEGIN TRY
                -- Process placeholders in drop script
                SET @ProcessedScript = REPLACE(@DropScript, '{SCHEMA}', QUOTENAME(@SchemaName));
                SET @ProcessedScript = REPLACE(@ProcessedScript, '{SCHEMA_NAME}', @SchemaName);
                
                SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@ProcessedScript, '''', '''''') + ''')';
                EXEC (@metasql);
                
                DECLARE @Status NVARCHAR(20) = 'SUCCESS';
                DECLARE @ErrorMsg NVARCHAR(MAX) = NULL;
                EXEC sp_executesql @LogStep, 
                    N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @ObjectName NVARCHAR(128), @ObjectType VARCHAR(20), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', 
                    @StepCount OUTPUT, @ErrorCount OUTPUT, @ObjectName, @ObjectType, @Status, @ErrorMsg;
                
            END TRY
            BEGIN CATCH
                SET @Status = 'ERROR';
                SET @ErrorMsg = ERROR_MESSAGE();
                EXEC sp_executesql @LogStep, 
                    N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @ObjectName NVARCHAR(128), @ObjectType VARCHAR(20), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', 
                    @StepCount OUTPUT, @ErrorCount OUTPUT, @ObjectName, @ObjectType, @Status, @ErrorMsg;
            END CATCH
            
            FETCH NEXT FROM drop_cursor INTO @ObjectID, @ObjectName, @ObjectType, @DropScript;
        END
        
        CLOSE drop_cursor;
        DEALLOCATE drop_cursor;
        
        PRINT '';
    END
    
    -- =====================================================================================
    -- CREATE OBJECTS FROM CONFIGURATION
    -- =====================================================================================
    
    PRINT '🏗️  CREATING OBJECTS FROM CONFIGURATION';
    PRINT '───────────────────────────────────────────────────────────────────────────────────';
    
    DECLARE object_cursor CURSOR FOR
    SELECT ObjectID, ObjectName, ObjectType, ExecutionOrder, Category, Description, CreationScript
    FROM [core].[DeploymentObjects]
    WHERE IsActive = 1 
      AND (@ObjectTypes IS NULL OR ObjectType IN (SELECT value FROM STRING_SPLIT(@ObjectTypes, ',')))
      AND (ObjectType != 'SAMPLE_DATA' OR @IncludeSampleData = 1)
    ORDER BY ExecutionOrder, ObjectID;
    
    OPEN object_cursor;
    FETCH NEXT FROM object_cursor INTO @ObjectID, @ObjectName, @ObjectType, @ExecutionOrder, @Category, @Description, @CreationScript;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Process placeholders in script
            SET @ProcessedScript = @CreationScript;
            SET @ProcessedScript = REPLACE(@ProcessedScript, '{SCHEMA}', QUOTENAME(@SchemaName));
            SET @ProcessedScript = REPLACE(@ProcessedScript, '{SCHEMA_NAME}', @SchemaName);
            SET @ProcessedScript = REPLACE(@ProcessedScript, '{CURRENT_DATETIME}', FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss'));
            
            -- Execute based on object type
            IF @ObjectType = 'SAMPLE_DATA'
            BEGIN
                -- Sample data can use direct execution with USE
                SET @SQL = N'USE ' + QUOTENAME(@DatabaseName) + N'; ' + @ProcessedScript;
                EXEC sp_executesql @SQL;
            END
            ELSE
            BEGIN
                -- Other objects need metasql approach
                SET @metasql = 'USE ' + QUOTENAME(@DatabaseName) + ' EXEC (''' + REPLACE(@ProcessedScript, '''', '''''') + ''')';
                EXEC (@metasql);
            END
            
            SET @Status = 'SUCCESS';
            SET @ErrorMsg = NULL;
            EXEC sp_executesql @LogStep, 
                N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @ObjectName NVARCHAR(128), @ObjectType VARCHAR(20), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', 
                @StepCount OUTPUT, @ErrorCount OUTPUT, @ObjectName, @ObjectType, @Status, @ErrorMsg;
            
        END TRY
        BEGIN CATCH
            SET @Status = 'ERROR';
            SET @ErrorMsg = ERROR_MESSAGE();
            EXEC sp_executesql @LogStep, 
                N'@StepCount INT OUTPUT, @ErrorCount INT OUTPUT, @ObjectName NVARCHAR(128), @ObjectType VARCHAR(20), @Status NVARCHAR(20), @ErrorMsg NVARCHAR(MAX)', 
                @StepCount OUTPUT, @ErrorCount OUTPUT, @ObjectName, @ObjectType, @Status, @ErrorMsg;
        END CATCH
        
        FETCH NEXT FROM object_cursor INTO @ObjectID, @ObjectName, @ObjectType, @ExecutionOrder, @Category, @Description, @CreationScript;
    END
    
    CLOSE object_cursor;
    DEALLOCATE object_cursor;
    
    -- =====================================================================================
    -- DEPLOYMENT SUMMARY
    -- =====================================================================================
    
    DECLARE @EndTime DATETIME2 = GETDATE();
    DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);
    DECLARE @SuccessCount INT = @StepCount - @ErrorCount;
    
    PRINT '';
    PRINT '=====================================================================================';
    PRINT 'SMART DEPLOYMENT SUMMARY';
    PRINT '=====================================================================================';
    PRINT 'Database: ' + @DatabaseName;
    PRINT 'Schema: ' + @SchemaName;
    PRINT 'Started: ' + FORMAT(@StartTime, 'yyyy-MM-dd HH:mm:ss');
    PRINT 'Completed: ' + FORMAT(@EndTime, 'yyyy-MM-dd HH:mm:ss');
    PRINT 'Duration: ' + CAST(@Duration AS VARCHAR) + ' seconds';
    PRINT 'Objects Processed: ' + CAST(@StepCount AS VARCHAR);
    PRINT 'Successful: ' + CAST(@SuccessCount AS VARCHAR);
    PRINT 'Errors: ' + CAST(@ErrorCount AS VARCHAR);
    PRINT '';
    
    -- Show detailed log
    PRINT 'DETAILED LOG:';
    PRINT '─────────────────────────────────────────────────────────────────────────────────';
    SELECT 
        FORMAT(StepNumber, '00') + '. ' + ObjectName as [Object],
        ObjectType as [Type],
        Status,
        FORMAT(ExecutionTime, 'HH:mm:ss') as [Time],
        ISNULL(ErrorMessage, '') as Error
    FROM #DeploymentLog
    ORDER BY StepNumber;
    
    PRINT '';
    PRINT 'USAGE EXAMPLES:';
    PRINT '─────────────────────────────────────────────────────────────────────────────────';
    PRINT 'Get parameter: SELECT ' + @SchemaName + '.GetParameter(''APP_VERSION'');';
    PRINT 'Set parameter: EXEC ' + @SchemaName + '.SetParameter @ParameterKey=''MY_PARAM'', @ParameterValue=''Value'';';
    PRINT 'View all: SELECT * FROM ' + @SchemaName + '.GlobalParameters WHERE IsActive = 1;';
    
    -- Final status
    IF @ErrorCount = 0
        PRINT '🎉 SMART DEPLOYMENT COMPLETED SUCCESSFULLY!';
    ELSE
        PRINT '⚠️  DEPLOYMENT COMPLETED WITH ' + CAST(@ErrorCount AS VARCHAR) + ' ERROR(S)';
    
    PRINT '=====================================================================================';
    
    -- Cleanup
    DROP TABLE #DeploymentLog;
    
    -- Return success/failure
    RETURN CASE WHEN @ErrorCount = 0 THEN 0 ELSE 1 END;
END
GO


