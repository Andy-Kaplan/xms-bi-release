-- ============================================================
-- XMS BI Control Record Snapshot Generator
-- ============================================================
-- Generates idempotent MERGE scripts for all core control tables.
-- Run against the SOURCE environment (e.g. UAT), save the output,
-- review it, then execute against the TARGET (e.g. Prod).
--
-- Usage:
--   1. Connect to source core database in SSMS
--   2. Press Ctrl+Shift+F (Results to File) before executing
--   3. Set max column width if using Results to Text:
--      Tools > Options > Query Results > SQL Server >
--      Results to Text > Max chars = 8192
--   4. Execute this script
--   5. Save/copy the output as a .sql file
--   6. Review the generated script
--   7. Execute against the target core database
--
-- Tables included:
--   core.core: Integrations, DataVaultEntities, GlobalParameters,
--              DeploymentObjects, PresentationTables,
--              PresentationControl, VisualisationQueries
--   Per-integration schemas: GlobalParameters, StagingControl,
--                            EntityMappings
--
-- Tables excluded:
--   Organisations (environment-specific, use AddOrganisation SP)
--   OrganisationIntegrations (environment-specific, has credentials)
--   Suggestion engine tables (deploy via dedicated scripts)
--
-- Ephemeral parameters excluded:
--   LINEITEM_START, LINEITEM_END, STOCKEVENT_START, STOCKEVENT_END
-- ============================================================

USE [core]
GO
SET NOCOUNT ON;

DECLARE @NL NVARCHAR(2) = NCHAR(13) + NCHAR(10);

-- Output accumulator
IF OBJECT_ID('tempdb..#output') IS NOT NULL DROP TABLE #output;
CREATE TABLE #output (seq INT IDENTITY(1,1), line NVARCHAR(MAX));

-- ============================================================
-- RECORD COUNTS (for verification header)
-- ============================================================
DECLARE @cntInt INT, @cntDVE INT, @cntGP INT, @cntDO INT;
DECLARE @cntPT INT, @cntPC INT, @cntVQ INT;

SELECT @cntInt = COUNT(*) FROM [core].[Integrations] WHERE IsActive = 1;
SELECT @cntDVE = COUNT(*) FROM [core].[DataVaultEntities];
SELECT @cntGP = COUNT(*) FROM [core].[GlobalParameters]
    WHERE ParameterKey NOT IN (N'LINEITEM_START',N'LINEITEM_END',N'STOCKEVENT_START',N'STOCKEVENT_END');
SELECT @cntDO = COUNT(*) FROM [core].[DeploymentObjects];
SELECT @cntPT = COUNT(*) FROM [core].[PresentationTables];
SELECT @cntPC = COUNT(*) FROM [core].[PresentationControl];
SELECT @cntVQ = COUNT(*) FROM [core].[VisualisationQueries];

-- ============================================================
-- OUTPUT HEADER
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ============================================================');
INSERT INTO #output (line) VALUES (N'-- XMS BI Control Record Snapshot');
INSERT INTO #output (line) VALUES (N'-- Source: ' + @@SERVERNAME);
INSERT INTO #output (line) VALUES (N'-- Generated: ' + FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss'));
INSERT INTO #output (line) VALUES (N'-- ============================================================');
INSERT INTO #output (line) VALUES (N'-- Record counts:');
INSERT INTO #output (line) VALUES (N'--   Integrations:         ' + CAST(@cntInt AS NVARCHAR(10)));
INSERT INTO #output (line) VALUES (N'--   DataVaultEntities:    ' + CAST(@cntDVE AS NVARCHAR(10)));
INSERT INTO #output (line) VALUES (N'--   GlobalParameters:     ' + CAST(@cntGP AS NVARCHAR(10)));
INSERT INTO #output (line) VALUES (N'--   DeploymentObjects:    ' + CAST(@cntDO AS NVARCHAR(10)));
INSERT INTO #output (line) VALUES (N'--   PresentationTables:   ' + CAST(@cntPT AS NVARCHAR(10)));
INSERT INTO #output (line) VALUES (N'--   PresentationControl:  ' + CAST(@cntPC AS NVARCHAR(10)));
INSERT INTO #output (line) VALUES (N'--   VisualisationQueries: ' + CAST(@cntVQ AS NVARCHAR(10)));
INSERT INTO #output (line) VALUES (N'-- ============================================================');
INSERT INTO #output (line) VALUES (N'');
INSERT INTO #output (line) VALUES (N'USE [core]');
INSERT INTO #output (line) VALUES (N'GO');
INSERT INTO #output (line) VALUES (N'SET NOCOUNT ON;');
INSERT INTO #output (line) VALUES (N'');

-- ============================================================
-- SECTION 1: Integrations
-- Key: IntegrationName
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 1: Integrations (' + CAST(@cntInt AS NVARCHAR(10)) + N' records)');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

INSERT INTO #output (line)
SELECT
    N'MERGE INTO [core].[Integrations] AS tgt' + @NL +
    N'USING (VALUES (' + @NL +
    N'    ' + N'''' + CAST(IntegrationCode AS NVARCHAR(36)) + N'''' + N',' + @NL +
    N'    N''' + REPLACE(IntegrationName, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN IntegrationDisplayName IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(IntegrationDisplayName, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN SchemaName IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(SchemaName, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CAST(SchemaCreated AS NVARCHAR(1)) + N',' + @NL +
    N'    ' + CAST(SchemaCreationRequested AS NVARCHAR(1)) + N',' + @NL +
    N'    N''' + REPLACE([Version], N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN [Description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE([Description], N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CAST(IsActive AS NVARCHAR(1)) + N',' + @NL +
    N'    ' + CASE WHEN APIEndpointDetail IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(CAST(APIEndpointDetail AS NVARCHAR(MAX)), N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN IntegrationType IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(IntegrationType, N'''', N'''''') + N'''' END + @NL +
    N')) AS src (IntegrationCode, IntegrationName, IntegrationDisplayName, SchemaName,' + @NL +
    N'    SchemaCreated, SchemaCreationRequested, [Version], [Description], IsActive,' + @NL +
    N'    APIEndpointDetail, IntegrationType)' + @NL +
    N'ON tgt.IntegrationName = src.IntegrationName' + @NL +
    N'WHEN MATCHED THEN' + @NL +
    N'    UPDATE SET IntegrationCode = src.IntegrationCode,' + @NL +
    N'        IntegrationDisplayName = src.IntegrationDisplayName,' + @NL +
    N'        SchemaName = src.SchemaName, SchemaCreated = src.SchemaCreated,' + @NL +
    N'        SchemaCreationRequested = src.SchemaCreationRequested,' + @NL +
    N'        [Version] = src.[Version], [Description] = src.[Description],' + @NL +
    N'        IsActive = src.IsActive, APIEndpointDetail = src.APIEndpointDetail,' + @NL +
    N'        IntegrationType = src.IntegrationType, ModifiedDate = GETDATE()' + @NL +
    N'WHEN NOT MATCHED THEN' + @NL +
    N'    INSERT (IntegrationCode, IntegrationName, IntegrationDisplayName, SchemaName,' + @NL +
    N'        SchemaCreated, SchemaCreationRequested, [Version], [Description], IsActive,' + @NL +
    N'        APIEndpointDetail, IntegrationType)' + @NL +
    N'    VALUES (src.IntegrationCode, src.IntegrationName, src.IntegrationDisplayName,' + @NL +
    N'        src.SchemaName, src.SchemaCreated, src.SchemaCreationRequested,' + @NL +
    N'        src.[Version], src.[Description], src.IsActive,' + @NL +
    N'        src.APIEndpointDetail, src.IntegrationType);' + @NL +
    N'GO' + @NL
FROM [core].[Integrations]
WHERE IsActive = 1
ORDER BY IntegrationName;

-- ============================================================
-- SECTION 2: DataVaultEntities
-- Key: ENTITY_NAME + VERSION
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 2: DataVaultEntities (' + CAST(@cntDVE AS NVARCHAR(10)) + N' records)');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

INSERT INTO #output (line)
SELECT
    N'MERGE INTO [core].[DataVaultEntities] AS tgt' + @NL +
    N'USING (VALUES (' + @NL +
    N'    N''' + REPLACE(ENTITY_NAME, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN DESCRIPTION IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(CAST(DESCRIPTION AS NVARCHAR(MAX)), N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN ATTRIBUTE_NAMES IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(ATTRIBUTE_NAMES, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN ATTRIBUTE_TYPES IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(ATTRIBUTE_TYPES, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN PRIMARY_SOURCE_TYPE IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(PRIMARY_SOURCE_TYPE, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN TIME_SERIES IS NULL THEN N'NULL' ELSE CAST(TIME_SERIES AS NVARCHAR(1)) END + N',' + @NL +
    N'    ' + CASE WHEN TIME_SERIES_COLUMN IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(TIME_SERIES_COLUMN, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CAST([VERSION] AS NVARCHAR(10)) + N',' + @NL +
    N'    N''' + REPLACE(RELEASE_STATE, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN SPLIT_MAP IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(SPLIT_MAP, N'''', N'''''') + N'''' END + @NL +
    N')) AS src (ENTITY_NAME, [DESCRIPTION], ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,' + @NL +
    N'    PRIMARY_SOURCE_TYPE, TIME_SERIES, TIME_SERIES_COLUMN, [VERSION],' + @NL +
    N'    RELEASE_STATE, SPLIT_MAP)' + @NL +
    N'ON tgt.ENTITY_NAME = src.ENTITY_NAME AND tgt.[VERSION] = src.[VERSION]' + @NL +
    N'WHEN MATCHED THEN' + @NL +
    N'    UPDATE SET [DESCRIPTION] = src.[DESCRIPTION],' + @NL +
    N'        ATTRIBUTE_NAMES = src.ATTRIBUTE_NAMES, ATTRIBUTE_TYPES = src.ATTRIBUTE_TYPES,' + @NL +
    N'        PRIMARY_SOURCE_TYPE = src.PRIMARY_SOURCE_TYPE, TIME_SERIES = src.TIME_SERIES,' + @NL +
    N'        TIME_SERIES_COLUMN = src.TIME_SERIES_COLUMN,' + @NL +
    N'        RELEASE_STATE = src.RELEASE_STATE, SPLIT_MAP = src.SPLIT_MAP,' + @NL +
    N'        UPDATED_AT = GETDATE()' + @NL +
    N'WHEN NOT MATCHED THEN' + @NL +
    N'    INSERT (ENTITY_NAME, [DESCRIPTION], ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,' + @NL +
    N'        PRIMARY_SOURCE_TYPE, TIME_SERIES, TIME_SERIES_COLUMN, [VERSION],' + @NL +
    N'        RELEASE_STATE, SPLIT_MAP)' + @NL +
    N'    VALUES (src.ENTITY_NAME, src.[DESCRIPTION], src.ATTRIBUTE_NAMES,' + @NL +
    N'        src.ATTRIBUTE_TYPES, src.PRIMARY_SOURCE_TYPE, src.TIME_SERIES,' + @NL +
    N'        src.TIME_SERIES_COLUMN, src.[VERSION], src.RELEASE_STATE, src.SPLIT_MAP);' + @NL +
    N'GO' + @NL
FROM [core].[DataVaultEntities]
ORDER BY ENTITY_NAME, [VERSION];

-- ============================================================
-- SECTION 3: GlobalParameters (core.core)
-- Key: ParameterKey
-- Excludes ephemeral load-window parameters
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 3: GlobalParameters (' + CAST(@cntGP AS NVARCHAR(10)) + N' records)');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

INSERT INTO #output (line)
SELECT
    N'MERGE INTO [core].[GlobalParameters] AS tgt' + @NL +
    N'USING (VALUES (' + @NL +
    N'    N''' + REPLACE(ParameterKey, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN ParameterValue IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(ParameterValue, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    N''' + REPLACE(DataType, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN Category IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(Category, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN [Description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE([Description], N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CAST(IsActive AS NVARCHAR(1)) + N',' + @NL +
    N'    N''' + REPLACE(CreatedBy, N'''', N'''''') + N''',' + @NL +
    N'    ' + CAST([Version] AS NVARCHAR(10)) + @NL +
    N')) AS src (ParameterKey, ParameterValue, DataType, Category,' + @NL +
    N'    [Description], IsActive, CreatedBy, [Version])' + @NL +
    N'ON tgt.ParameterKey = src.ParameterKey' + @NL +
    N'WHEN MATCHED THEN' + @NL +
    N'    UPDATE SET ParameterValue = src.ParameterValue, DataType = src.DataType,' + @NL +
    N'        Category = src.Category, [Description] = src.[Description],' + @NL +
    N'        IsActive = src.IsActive, [Version] = src.[Version],' + @NL +
    N'        ModifiedBy = N''SnapshotGenerator'', ModifiedDate = GETDATE()' + @NL +
    N'WHEN NOT MATCHED THEN' + @NL +
    N'    INSERT (ParameterKey, ParameterValue, DataType, Category,' + @NL +
    N'        [Description], IsActive, CreatedBy, [Version])' + @NL +
    N'    VALUES (src.ParameterKey, src.ParameterValue, src.DataType, src.Category,' + @NL +
    N'        src.[Description], src.IsActive, src.CreatedBy, src.[Version]);' + @NL +
    N'GO' + @NL
FROM [core].[GlobalParameters]
WHERE ParameterKey NOT IN (N'LINEITEM_START', N'LINEITEM_END', N'STOCKEVENT_START', N'STOCKEVENT_END')
ORDER BY Category, ParameterKey;

-- ============================================================
-- SECTION 4: DeploymentObjects
-- Key: ObjectName + ObjectType
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 4: DeploymentObjects (' + CAST(@cntDO AS NVARCHAR(10)) + N' records)');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

INSERT INTO #output (line)
SELECT
    N'MERGE INTO [core].[DeploymentObjects] AS tgt' + @NL +
    N'USING (VALUES (' + @NL +
    N'    N''' + REPLACE(ObjectName, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(ObjectType, N'''', N'''''') + N''',' + @NL +
    N'    ' + CAST(ExecutionOrder AS NVARCHAR(10)) + N',' + @NL +
    N'    ' + CASE WHEN Category IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(Category, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN [Description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE([Description], N'''', N'''''') + N'''' END + N',' + @NL +
    N'    N''' + REPLACE(CreationScript, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN DropScript IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(DropScript, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CAST(IsActive AS NVARCHAR(1)) + @NL +
    N')) AS src (ObjectName, ObjectType, ExecutionOrder, Category,' + @NL +
    N'    [Description], CreationScript, DropScript, IsActive)' + @NL +
    N'ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType' + @NL +
    N'WHEN MATCHED THEN' + @NL +
    N'    UPDATE SET ExecutionOrder = src.ExecutionOrder, Category = src.Category,' + @NL +
    N'        [Description] = src.[Description], CreationScript = src.CreationScript,' + @NL +
    N'        DropScript = src.DropScript, IsActive = src.IsActive,' + @NL +
    N'        ModifiedDate = GETDATE()' + @NL +
    N'WHEN NOT MATCHED THEN' + @NL +
    N'    INSERT (ObjectName, ObjectType, ExecutionOrder, Category,' + @NL +
    N'        [Description], CreationScript, DropScript, IsActive)' + @NL +
    N'    VALUES (src.ObjectName, src.ObjectType, src.ExecutionOrder, src.Category,' + @NL +
    N'        src.[Description], src.CreationScript, src.DropScript, src.IsActive);' + @NL +
    N'GO' + @NL
FROM [core].[DeploymentObjects]
ORDER BY ExecutionOrder, ObjectName;

-- ============================================================
-- SECTION 5: PresentationTables
-- Key: table_name + version
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 5: PresentationTables (' + CAST(@cntPT AS NVARCHAR(10)) + N' records)');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

INSERT INTO #output (line)
SELECT
    N'MERGE INTO [core].[PresentationTables] AS tgt' + @NL +
    N'USING (VALUES (' + @NL +
    N'    N''' + REPLACE(table_name, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(table_type, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(schema_name, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(ddl_script, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(column_definitions, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN [description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(CAST([description] AS NVARCHAR(MAX)), N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN business_owner IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(business_owner, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN data_source IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(data_source, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CAST([version] AS NVARCHAR(10)) + N',' + @NL +
    N'    N''' + REPLACE([status], N'''', N'''''') + N''',' + @NL +
    N'    ' + CAST(is_system_generated AS NVARCHAR(1)) + N',' + @NL +
    N'    ' + CASE WHEN parent_tables IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(parent_tables, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN child_tables IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(child_tables, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN created_by IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(created_by, N'''', N'''''') + N'''' END + @NL +
    N')) AS src (table_name, table_type, schema_name, ddl_script, column_definitions,' + @NL +
    N'    [description], business_owner, data_source, [version], [status],' + @NL +
    N'    is_system_generated, parent_tables, child_tables, created_by)' + @NL +
    N'ON tgt.table_name = src.table_name AND tgt.[version] = src.[version]' + @NL +
    N'WHEN MATCHED THEN' + @NL +
    N'    UPDATE SET table_type = src.table_type, schema_name = src.schema_name,' + @NL +
    N'        ddl_script = src.ddl_script, column_definitions = src.column_definitions,' + @NL +
    N'        [description] = src.[description], business_owner = src.business_owner,' + @NL +
    N'        data_source = src.data_source, [status] = src.[status],' + @NL +
    N'        is_system_generated = src.is_system_generated,' + @NL +
    N'        parent_tables = src.parent_tables, child_tables = src.child_tables,' + @NL +
    N'        updated_by = N''SnapshotGenerator'', updated_at = GETDATE()' + @NL +
    N'WHEN NOT MATCHED THEN' + @NL +
    N'    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions,' + @NL +
    N'        [description], business_owner, data_source, [version], [status],' + @NL +
    N'        is_system_generated, parent_tables, child_tables, created_by)' + @NL +
    N'    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script,' + @NL +
    N'        src.column_definitions, src.[description], src.business_owner,' + @NL +
    N'        src.data_source, src.[version], src.[status],' + @NL +
    N'        src.is_system_generated, src.parent_tables, src.child_tables,' + @NL +
    N'        src.created_by);' + @NL +
    N'GO' + @NL
FROM [core].[PresentationTables]
ORDER BY table_name, [version];

-- ============================================================
-- SECTION 6: PresentationControl
-- Key: step_name
-- Note: query_sql, depends_on_steps, description are TEXT columns
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 6: PresentationControl (' + CAST(@cntPC AS NVARCHAR(10)) + N' records)');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

INSERT INTO #output (line)
SELECT
    N'MERGE INTO [core].[PresentationControl] AS tgt' + @NL +
    N'USING (VALUES (' + @NL +
    N'    N''' + REPLACE(step_name, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(table_name, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(CAST(query_sql AS NVARCHAR(MAX)), N'''', N'''''') + N''',' + @NL +
    N'    ' + CAST(tier AS NVARCHAR(10)) + N',' + @NL +
    N'    N''' + REPLACE(table_type, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN column_mappings IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(column_mappings, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN [exclude] IS NULL THEN N'NULL' ELSE CAST([exclude] AS NVARCHAR(1)) END + N',' + @NL +
    N'    ' + CASE WHEN [priority] IS NULL THEN N'NULL' ELSE CAST([priority] AS NVARCHAR(10)) END + N',' + @NL +
    N'    ' + CASE WHEN retry_count IS NULL THEN N'NULL' ELSE CAST(retry_count AS NVARCHAR(10)) END + N',' + @NL +
    N'    ' + CASE WHEN timeout_minutes IS NULL THEN N'NULL' ELSE CAST(timeout_minutes AS NVARCHAR(10)) END + N',' + @NL +
    N'    ' + CASE WHEN depends_on_steps IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(CAST(depends_on_steps AS NVARCHAR(MAX)), N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN time_series_entity IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(time_series_entity, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN time_series_target_column IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(time_series_target_column, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN [description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(CAST([description] AS NVARCHAR(MAX)), N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN created_by IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(created_by, N'''', N'''''') + N'''' END + @NL +
    N')) AS src (step_name, table_name, query_sql, tier, table_type, column_mappings,' + @NL +
    N'    [exclude], [priority], retry_count, timeout_minutes, depends_on_steps,' + @NL +
    N'    time_series_entity, time_series_target_column, [description], created_by)' + @NL +
    N'ON tgt.step_name = src.step_name' + @NL +
    N'WHEN MATCHED THEN' + @NL +
    N'    UPDATE SET table_name = src.table_name, query_sql = src.query_sql,' + @NL +
    N'        tier = src.tier, table_type = src.table_type,' + @NL +
    N'        column_mappings = src.column_mappings, [exclude] = src.[exclude],' + @NL +
    N'        [priority] = src.[priority], retry_count = src.retry_count,' + @NL +
    N'        timeout_minutes = src.timeout_minutes,' + @NL +
    N'        depends_on_steps = src.depends_on_steps,' + @NL +
    N'        time_series_entity = src.time_series_entity,' + @NL +
    N'        time_series_target_column = src.time_series_target_column,' + @NL +
    N'        [description] = src.[description], created_by = src.created_by,' + @NL +
    N'        updated_at = GETDATE()' + @NL +
    N'WHEN NOT MATCHED THEN' + @NL +
    N'    INSERT (step_name, table_name, query_sql, tier, table_type, column_mappings,' + @NL +
    N'        [exclude], [priority], retry_count, timeout_minutes, depends_on_steps,' + @NL +
    N'        time_series_entity, time_series_target_column, [description], created_by)' + @NL +
    N'    VALUES (src.step_name, src.table_name, src.query_sql, src.tier,' + @NL +
    N'        src.table_type, src.column_mappings, src.[exclude], src.[priority],' + @NL +
    N'        src.retry_count, src.timeout_minutes, src.depends_on_steps,' + @NL +
    N'        src.time_series_entity, src.time_series_target_column,' + @NL +
    N'        src.[description], src.created_by);' + @NL +
    N'GO' + @NL
FROM [core].[PresentationControl]
ORDER BY tier, [priority], step_name;

-- ============================================================
-- SECTION 7: VisualisationQueries
-- Key: DataSetName + VisualizationType + Status
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 7: VisualisationQueries (' + CAST(@cntVQ AS NVARCHAR(10)) + N' records)');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

INSERT INTO #output (line)
SELECT
    N'MERGE INTO [core].[VisualisationQueries] AS tgt' + @NL +
    N'USING (VALUES (' + @NL +
    N'    N''' + REPLACE(DataSetName, N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(VisualizationType, N'''', N'''''') + N''',' + @NL +
    N'    ' + CAST([Version] AS NVARCHAR(10)) + N',' + @NL +
    N'    N''' + REPLACE([Status], N'''', N'''''') + N''',' + @NL +
    N'    N''' + REPLACE(QueryTemplate, N'''', N'''''') + N''',' + @NL +
    N'    ' + CASE WHEN ParameterMappings IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(ParameterMappings, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN FilterDefinitions IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(FilterDefinitions, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN [Description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE([Description], N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN OutputDefinitions IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(OutputDefinitions, N'''', N'''''') + N'''' END + N',' + @NL +
    N'    ' + CASE WHEN ExecutionQuery IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(ExecutionQuery, N'''', N'''''') + N'''' END + @NL +
    N')) AS src (DataSetName, VisualizationType, [Version], [Status], QueryTemplate,' + @NL +
    N'    ParameterMappings, FilterDefinitions, [Description],' + @NL +
    N'    OutputDefinitions, ExecutionQuery)' + @NL +
    N'ON tgt.DataSetName = src.DataSetName' + @NL +
    N'    AND tgt.VisualizationType = src.VisualizationType' + @NL +
    N'    AND tgt.[Status] = src.[Status]' + @NL +
    N'WHEN MATCHED THEN' + @NL +
    N'    UPDATE SET [Version] = src.[Version],' + @NL +
    N'        QueryTemplate = src.QueryTemplate,' + @NL +
    N'        ParameterMappings = src.ParameterMappings,' + @NL +
    N'        FilterDefinitions = src.FilterDefinitions,' + @NL +
    N'        [Description] = src.[Description],' + @NL +
    N'        OutputDefinitions = src.OutputDefinitions,' + @NL +
    N'        ExecutionQuery = src.ExecutionQuery,' + @NL +
    N'        ModifiedDate = GETDATE(), ModifiedBy = N''SnapshotGenerator''' + @NL +
    N'WHEN NOT MATCHED THEN' + @NL +
    N'    INSERT (DataSetName, VisualizationType, [Version], [Status], QueryTemplate,' + @NL +
    N'        ParameterMappings, FilterDefinitions, [Description],' + @NL +
    N'        OutputDefinitions, ExecutionQuery)' + @NL +
    N'    VALUES (src.DataSetName, src.VisualizationType, src.[Version], src.[Status],' + @NL +
    N'        src.QueryTemplate, src.ParameterMappings, src.FilterDefinitions,' + @NL +
    N'        src.[Description], src.OutputDefinitions, src.ExecutionQuery);' + @NL +
    N'GO' + @NL
FROM [core].[VisualisationQueries]
ORDER BY DataSetName, VisualizationType, [Status];

-- ============================================================
-- SECTION 8: Per-Integration Tables
-- Dynamically discovers integration schemas and exports:
--   GlobalParameters, StagingControl, EntityMappings
-- ============================================================
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'-- Section 8: Per-Integration Tables');
INSERT INTO #output (line) VALUES (N'-- ==============================================');
INSERT INTO #output (line) VALUES (N'');

-- Temp tables for per-integration data
IF OBJECT_ID('tempdb..#int_staging') IS NOT NULL DROP TABLE #int_staging;
IF OBJECT_ID('tempdb..#int_mappings') IS NOT NULL DROP TABLE #int_mappings;
IF OBJECT_ID('tempdb..#int_params') IS NOT NULL DROP TABLE #int_params;

CREATE TABLE #int_staging (
    schema_name NVARCHAR(128),
    step_name NVARCHAR(255),
    staging_table NVARCHAR(255),
    staging_columns NVARCHAR(MAX),
    query_sql NVARCHAR(MAX),
    tier INT,
    step_type NVARCHAR(255),
    [exclude] BIT,
    [description] NVARCHAR(MAX),
    depends_on_steps NVARCHAR(MAX),
    retry_count INT,
    timeout_minutes INT
);

CREATE TABLE #int_mappings (
    schema_name NVARCHAR(128),
    entity_name NVARCHAR(255),
    source_table NVARCHAR(255),
    source_columns NVARCHAR(MAX),
    entity_columns NVARCHAR(MAX),
    type2_columns NVARCHAR(MAX),
    cdc_exclude_columns NVARCHAR(MAX),
    date_filter_column NVARCHAR(255),
    exclude_conditions NVARCHAR(MAX),
    track_deletions BIT,
    split_by_source BIT,
    is_active BIT
);

CREATE TABLE #int_params (
    schema_name NVARCHAR(128),
    ParameterKey NVARCHAR(100),
    ParameterValue NVARCHAR(4000),
    DataType VARCHAR(20),
    Category NVARCHAR(50),
    [Description] NVARCHAR(500),
    IsActive BIT,
    CreatedBy NVARCHAR(100),
    [Version] INT
);

-- Load data from each integration schema
DECLARE @intSchema NVARCHAR(128);
DECLARE @dynSQL NVARCHAR(MAX);

DECLARE int_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT SchemaName FROM [core].[Integrations]
    WHERE IsActive = 1 AND SchemaCreated = 1
    ORDER BY SchemaName;

OPEN int_cursor;
FETCH NEXT FROM int_cursor INTO @intSchema;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- StagingControl
    BEGIN TRY
        SET @dynSQL = N'SELECT @s, step_name, staging_table, staging_columns, query_sql, tier, step_type, [exclude], [description], depends_on_steps, retry_count, timeout_minutes FROM ' + QUOTENAME(@intSchema) + N'.[StagingControl]';
        INSERT INTO #int_staging EXEC sp_executesql @dynSQL, N'@s NVARCHAR(128)', @s = @intSchema;
    END TRY
    BEGIN CATCH
        PRINT N'Warning: Could not load StagingControl from ' + @intSchema + N': ' + ERROR_MESSAGE();
    END CATCH

    -- EntityMappings
    BEGIN TRY
        SET @dynSQL = N'SELECT @s, entity_name, source_table, source_columns, entity_columns, type2_columns, cdc_exclude_columns, date_filter_column, exclude_conditions, track_deletions, split_by_source, is_active FROM ' + QUOTENAME(@intSchema) + N'.[EntityMappings]';
        INSERT INTO #int_mappings EXEC sp_executesql @dynSQL, N'@s NVARCHAR(128)', @s = @intSchema;
    END TRY
    BEGIN CATCH
        PRINT N'Warning: Could not load EntityMappings from ' + @intSchema + N': ' + ERROR_MESSAGE();
    END CATCH

    -- GlobalParameters
    BEGIN TRY
        SET @dynSQL = N'SELECT @s, ParameterKey, ParameterValue, DataType, Category, [Description], IsActive, CreatedBy, [Version] FROM ' + QUOTENAME(@intSchema) + N'.[GlobalParameters]';
        INSERT INTO #int_params EXEC sp_executesql @dynSQL, N'@s NVARCHAR(128)', @s = @intSchema;
    END TRY
    BEGIN CATCH
        PRINT N'Warning: Could not load GlobalParameters from ' + @intSchema + N': ' + ERROR_MESSAGE();
    END CATCH

    FETCH NEXT FROM int_cursor INTO @intSchema;
END
CLOSE int_cursor;
DEALLOCATE int_cursor;

-- Generate MERGEs for per-integration GlobalParameters
DECLARE @sch NVARCHAR(128);
DECLARE @schCnt INT;

DECLARE gp_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT schema_name FROM #int_params ORDER BY schema_name;
OPEN gp_cursor;
FETCH NEXT FROM gp_cursor INTO @sch;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @schCnt = COUNT(*) FROM #int_params WHERE schema_name = @sch;
    INSERT INTO #output (line) VALUES (N'-- ' + @sch + N'.GlobalParameters (' + CAST(@schCnt AS NVARCHAR(10)) + N' records)');
    INSERT INTO #output (line) VALUES (N'');

    INSERT INTO #output (line)
    SELECT
        N'MERGE INTO ' + QUOTENAME(schema_name) + N'.[GlobalParameters] AS tgt' + @NL +
        N'USING (VALUES (' + @NL +
        N'    N''' + REPLACE(ParameterKey, N'''', N'''''') + N''',' + @NL +
        N'    ' + CASE WHEN ParameterValue IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(ParameterValue, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    N''' + REPLACE(DataType, N'''', N'''''') + N''',' + @NL +
        N'    ' + CASE WHEN Category IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(Category, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN [Description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE([Description], N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN IsActive IS NULL THEN N'NULL' ELSE CAST(IsActive AS NVARCHAR(1)) END + N',' + @NL +
        N'    ' + CASE WHEN CreatedBy IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(CreatedBy, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN [Version] IS NULL THEN N'NULL' ELSE CAST([Version] AS NVARCHAR(10)) END + @NL +
        N')) AS src (ParameterKey, ParameterValue, DataType, Category,' + @NL +
        N'    [Description], IsActive, CreatedBy, [Version])' + @NL +
        N'ON tgt.ParameterKey = src.ParameterKey' + @NL +
        N'WHEN MATCHED THEN' + @NL +
        N'    UPDATE SET ParameterValue = src.ParameterValue, DataType = src.DataType,' + @NL +
        N'        Category = src.Category, [Description] = src.[Description],' + @NL +
        N'        IsActive = src.IsActive, [Version] = src.[Version],' + @NL +
        N'        ModifiedBy = N''SnapshotGenerator'', ModifiedDate = GETDATE()' + @NL +
        N'WHEN NOT MATCHED THEN' + @NL +
        N'    INSERT (ParameterKey, ParameterValue, DataType, Category,' + @NL +
        N'        [Description], IsActive, CreatedBy, [Version])' + @NL +
        N'    VALUES (src.ParameterKey, src.ParameterValue, src.DataType, src.Category,' + @NL +
        N'        src.[Description], src.IsActive, src.CreatedBy, src.[Version]);' + @NL +
        N'GO' + @NL
    FROM #int_params
    WHERE schema_name = @sch
    ORDER BY Category, ParameterKey;

    FETCH NEXT FROM gp_cursor INTO @sch;
END
CLOSE gp_cursor;
DEALLOCATE gp_cursor;

-- Generate MERGEs for per-integration StagingControl
DECLARE stg_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT schema_name FROM #int_staging ORDER BY schema_name;
OPEN stg_cursor;
FETCH NEXT FROM stg_cursor INTO @sch;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @schCnt = COUNT(*) FROM #int_staging WHERE schema_name = @sch;
    INSERT INTO #output (line) VALUES (N'-- ' + @sch + N'.StagingControl (' + CAST(@schCnt AS NVARCHAR(10)) + N' records)');
    INSERT INTO #output (line) VALUES (N'');

    INSERT INTO #output (line)
    SELECT
        N'MERGE INTO ' + QUOTENAME(schema_name) + N'.[StagingControl] AS tgt' + @NL +
        N'USING (VALUES (' + @NL +
        N'    N''' + REPLACE(step_name, N'''', N'''''') + N''',' + @NL +
        N'    N''' + REPLACE(staging_table, N'''', N'''''') + N''',' + @NL +
        N'    N''' + REPLACE(staging_columns, N'''', N'''''') + N''',' + @NL +
        N'    N''' + REPLACE(query_sql, N'''', N'''''') + N''',' + @NL +
        N'    ' + CAST(tier AS NVARCHAR(10)) + N',' + @NL +
        N'    ' + CASE WHEN step_type IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(step_type, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN [exclude] IS NULL THEN N'NULL' ELSE CAST([exclude] AS NVARCHAR(1)) END + N',' + @NL +
        N'    ' + CASE WHEN [description] IS NULL THEN N'NULL' ELSE N'N''' + REPLACE([description], N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN depends_on_steps IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(depends_on_steps, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN retry_count IS NULL THEN N'NULL' ELSE CAST(retry_count AS NVARCHAR(10)) END + N',' + @NL +
        N'    ' + CASE WHEN timeout_minutes IS NULL THEN N'NULL' ELSE CAST(timeout_minutes AS NVARCHAR(10)) END + @NL +
        N')) AS src (step_name, staging_table, staging_columns, query_sql, tier,' + @NL +
        N'    step_type, [exclude], [description], depends_on_steps, retry_count, timeout_minutes)' + @NL +
        N'ON tgt.step_name = src.step_name' + @NL +
        N'WHEN MATCHED THEN' + @NL +
        N'    UPDATE SET staging_table = src.staging_table,' + @NL +
        N'        staging_columns = src.staging_columns, query_sql = src.query_sql,' + @NL +
        N'        tier = src.tier, step_type = src.step_type, [exclude] = src.[exclude],' + @NL +
        N'        [description] = src.[description], depends_on_steps = src.depends_on_steps,' + @NL +
        N'        retry_count = src.retry_count, timeout_minutes = src.timeout_minutes,' + @NL +
        N'        updated_at = GETDATE()' + @NL +
        N'WHEN NOT MATCHED THEN' + @NL +
        N'    INSERT (step_name, staging_table, staging_columns, query_sql, tier,' + @NL +
        N'        step_type, [exclude], [description], depends_on_steps, retry_count, timeout_minutes)' + @NL +
        N'    VALUES (src.step_name, src.staging_table, src.staging_columns, src.query_sql,' + @NL +
        N'        src.tier, src.step_type, src.[exclude], src.[description],' + @NL +
        N'        src.depends_on_steps, src.retry_count, src.timeout_minutes);' + @NL +
        N'GO' + @NL
    FROM #int_staging
    WHERE schema_name = @sch
    ORDER BY tier, step_name;

    FETCH NEXT FROM stg_cursor INTO @sch;
END
CLOSE stg_cursor;
DEALLOCATE stg_cursor;

-- Generate MERGEs for per-integration EntityMappings
DECLARE map_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT schema_name FROM #int_mappings ORDER BY schema_name;
OPEN map_cursor;
FETCH NEXT FROM map_cursor INTO @sch;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @schCnt = COUNT(*) FROM #int_mappings WHERE schema_name = @sch;
    INSERT INTO #output (line) VALUES (N'-- ' + @sch + N'.EntityMappings (' + CAST(@schCnt AS NVARCHAR(10)) + N' records)');
    INSERT INTO #output (line) VALUES (N'');

    INSERT INTO #output (line)
    SELECT
        N'MERGE INTO ' + QUOTENAME(schema_name) + N'.[EntityMappings] AS tgt' + @NL +
        N'USING (VALUES (' + @NL +
        N'    N''' + REPLACE(entity_name, N'''', N'''''') + N''',' + @NL +
        N'    N''' + REPLACE(source_table, N'''', N'''''') + N''',' + @NL +
        N'    ' + CASE WHEN source_columns IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(source_columns, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN entity_columns IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(entity_columns, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN type2_columns IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(type2_columns, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN cdc_exclude_columns IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(cdc_exclude_columns, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN date_filter_column IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(date_filter_column, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN exclude_conditions IS NULL THEN N'NULL' ELSE N'N''' + REPLACE(exclude_conditions, N'''', N'''''') + N'''' END + N',' + @NL +
        N'    ' + CASE WHEN track_deletions IS NULL THEN N'NULL' ELSE CAST(track_deletions AS NVARCHAR(1)) END + N',' + @NL +
        N'    ' + CASE WHEN split_by_source IS NULL THEN N'NULL' ELSE CAST(split_by_source AS NVARCHAR(1)) END + N',' + @NL +
        N'    ' + CASE WHEN is_active IS NULL THEN N'NULL' ELSE CAST(is_active AS NVARCHAR(1)) END + @NL +
        N')) AS src (entity_name, source_table, source_columns, entity_columns,' + @NL +
        N'    type2_columns, cdc_exclude_columns, date_filter_column,' + @NL +
        N'    exclude_conditions, track_deletions, split_by_source, is_active)' + @NL +
        N'ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table' + @NL +
        N'WHEN MATCHED THEN' + @NL +
        N'    UPDATE SET source_columns = src.source_columns,' + @NL +
        N'        entity_columns = src.entity_columns, type2_columns = src.type2_columns,' + @NL +
        N'        cdc_exclude_columns = src.cdc_exclude_columns,' + @NL +
        N'        date_filter_column = src.date_filter_column,' + @NL +
        N'        exclude_conditions = src.exclude_conditions,' + @NL +
        N'        track_deletions = src.track_deletions,' + @NL +
        N'        split_by_source = src.split_by_source,' + @NL +
        N'        is_active = src.is_active, updated_at = GETDATE()' + @NL +
        N'WHEN NOT MATCHED THEN' + @NL +
        N'    INSERT (entity_name, source_table, source_columns, entity_columns,' + @NL +
        N'        type2_columns, cdc_exclude_columns, date_filter_column,' + @NL +
        N'        exclude_conditions, track_deletions, split_by_source, is_active)' + @NL +
        N'    VALUES (src.entity_name, src.source_table, src.source_columns,' + @NL +
        N'        src.entity_columns, src.type2_columns, src.cdc_exclude_columns,' + @NL +
        N'        src.date_filter_column, src.exclude_conditions,' + @NL +
        N'        src.track_deletions, src.split_by_source, src.is_active);' + @NL +
        N'GO' + @NL
    FROM #int_mappings
    WHERE schema_name = @sch
    ORDER BY entity_name, source_table;

    FETCH NEXT FROM map_cursor INTO @sch;
END
CLOSE map_cursor;
DEALLOCATE map_cursor;

-- Footer
INSERT INTO #output (line) VALUES (N'');
INSERT INTO #output (line) VALUES (N'-- ============================================================');
INSERT INTO #output (line) VALUES (N'-- End of snapshot');
INSERT INTO #output (line) VALUES (N'-- Post-deploy steps (if applicable):');
INSERT INTO #output (line) VALUES (N'--   1. Run sp_DeployObjects for all active orgs');
INSERT INTO #output (line) VALUES (N'--   2. Run sp_GenerateDataVaultTables for all active orgs');
INSERT INTO #output (line) VALUES (N'--   3. Run UploadEntityMappings for each integration schema');
INSERT INTO #output (line) VALUES (N'-- ============================================================');

-- ============================================================
-- OUTPUT
-- ============================================================
-- Method A (recommended): Results to File
--   Press Ctrl+Shift+F before executing, or use Ctrl+T for
--   Results to Text. Set max column width to 8192:
--   Tools > Options > Query Results > SQL Server >
--   Results to Text > Maximum number of characters = 8192

SELECT line AS [--] FROM #output ORDER BY seq;

-- Method B: XML output (click the hyperlink in Grid mode)
-- Uncomment below for a single clickable XML cell:
/*
SELECT (
    SELECT line + NCHAR(13) + NCHAR(10) AS [text()]
    FROM #output ORDER BY seq
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)') AS [snapshot_output];
*/

-- Cleanup
DROP TABLE #output;
DROP TABLE #int_staging;
DROP TABLE #int_mappings;
DROP TABLE #int_params;
GO
