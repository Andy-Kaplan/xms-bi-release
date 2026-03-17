-- ==============================================
-- Parent Organisation Reporting: PresentationControl Steps
-- Date: 2026-03-09
-- 7 steps: 2 dims (Tier 100) + 4 facts (Tier 101) + 1 derived (Tier 102)
-- Prerequisite: 05_sp_ExecuteQuery_patch.sql must be deployed first
-- ==============================================

-- -----------------------------------------------
-- 1. PD_ORGANISATION — Tier 100
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000001-A0B1-C2D3-E4F5-A00000000001',
    N'Parent Organisation Dimension',
    N'PD_ORGANISATION',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

SELECT
    [OrganisationCode] AS ORG_CODE,
    [OrganisationName] AS ORG_NAME,
    [OrganisationPrefix] AS ORG_PREFIX,
    [DatabaseName] AS DATABASE_NAME,
    [IsActive] AS IS_ACTIVE,
    [CreatedDate] AS CREATED_DATE
FROM [core].[core].[Organisations]
WHERE [ParentOrganisationCode] = @ParentOrgCode
  AND [IsActive] = 1;',
    100,
    N'Dimension',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORG_PREFIX","table_column":"ORG_PREFIX","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"DATABASE_NAME","table_column":"DATABASE_NAME","data_type":"nvarchar(128)","target_data_type":"[nvarchar](128)"},{"query_column":"IS_ACTIVE","table_column":"IS_ACTIVE","data_type":"bit","target_data_type":"[bit]"},{"query_column":"CREATED_DATE","table_column":"CREATED_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"}]',
    0, 100, 3, 30,
    N'Parent Organisation Dimension - lists child organisations',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'None', NULL
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 2. PD_LOCATION — Tier 100
-- Uses sp_BuildParentPresentationSQL with @IsRawQuery=0
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000002-A0B1-C2D3-E4F5-A00000000002',
    N'Parent Location Dimension',
    N'PD_LOCATION',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = N''[presentation].[D_LOCATION]'',
    @IsRawQuery = 0,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    100,
    N'Dimension',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"varchar(36)","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_HUB_ID","table_column":"BOTTOM_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"BOTTOM_SRC","table_column":"BOTTOM_SRC","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOAD_TS","table_column":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVEFROM","table_column":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVETO","table_column":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_CURRENT_FLAG","table_column":"BOTTOM_CURRENT_FLAG","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_IS_DELETED","table_column":"BOTTOM_IS_DELETED","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_LOCATION_NAME","table_column":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOCATION_ID","table_column":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LEVEL_NAME","table_column":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_1","table_column":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_2","table_column":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_3","table_column":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_4","table_column":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_5","table_column":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_ID","table_column":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_NAME","table_column":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_NAME","table_column":"MIDDLE_1_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_LEVEL_NAME","table_column":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_1","table_column":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_2","table_column":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_3","table_column":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_4","table_column":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_5","table_column":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_ID","table_column":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_NAME","table_column":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_NAME","table_column":"TOP_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_LEVEL_NAME","table_column":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_1","table_column":"TOP_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_2","table_column":"TOP_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_3","table_column":"TOP_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_4","table_column":"TOP_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_5","table_column":"TOP_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_ID","table_column":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_NAME","table_column":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"HIERARCHY_PATH","table_column":"HIERARCHY_PATH","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOTAL_LEVELS","table_column":"TOTAL_LEVELS","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 110, 3, 30,
    N'Parent Location Dimension - unions child D_LOCATION tables',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'None', NULL
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 3. PF_REVENUE_DAY — Tier 101
-- ORDER_DATE cast from datetime2(7) 15-min precision to date before grouping
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000003-A0B1-C2D3-E4F5-A00000000003',
    N'Parent Revenue Day',
    N'PF_REVENUE_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    [LI_TYPE],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([GROSS_VALUE]) AS [GROSS_VALUE],
    SUM([TAX_VALUE]) AS [TAX_VALUE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([ORDER_COUNT]) AS [ORDER_COUNT],
    SUM([QUANTITY]) AS [QUANTITY]
FROM {DB}.[presentation].[F_LINEITEM_15MIN]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], [LI_TYPE], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"LI_TYPE","table_column":"LI_TYPE","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"GROSS_VALUE","table_column":"GROSS_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"TAX_VALUE","table_column":"TAX_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 100, 3, 60,
    N'Parent Revenue Day - aggregates child F_LINEITEM_15MIN to daily grain',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'LINEITEM', N'ORDER_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 4. PF_PROFIT_DAY — Tier 101
-- Same ORDER_DATE CAST as PF_REVENUE_DAY
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000004-A0B1-C2D3-E4F5-A00000000004',
    N'Parent Profit Day',
    N'PF_PROFIT_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([QUANTITY]) AS [QUANTITY],
    SUM([PROFIT]) AS [PROFIT],
    SUM([PROFIT_LESS_DISCOUNT]) AS [PROFIT_LESS_DISCOUNT],
    SUM([PROFIT]) - SUM([PROFIT_LESS_DISCOUNT]) AS [DISCOUNT_IMPACT]
FROM {DB}.[presentation].[F_PRODUCT_MARGIN_DAY]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT","table_column":"PROFIT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT_LESS_DISCOUNT","table_column":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"DISCOUNT_IMPACT","table_column":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 110, 3, 60,
    N'Parent Profit Day - aggregates child F_PRODUCT_MARGIN_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'LINEITEM', N'ORDER_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 5. PF_FOODCOST_DAY — Tier 101
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000005-A0B1-C2D3-E4F5-A00000000005',
    N'Parent Food Cost Day',
    N'PF_FOODCOST_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    CAST([INV_DATE] AS datetime2(7)) AS [INV_DATE],
    SUM([UOM_COST]) AS [TOTAL_UOM_COST],
    SUM([SALES_RECIPE_COST]) AS [TOTAL_RECIPE_COST],
    SUM([NET_SALES]) AS [NET_SALES]
FROM {DB}.[presentation].[F_INV_SALES_DAY]
GROUP BY [LOCATION_HUB_ID], [INV_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"INV_DATE","table_column":"INV_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"TOTAL_UOM_COST","table_column":"TOTAL_UOM_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TOTAL_RECIPE_COST","table_column":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"NET_SALES","table_column":"NET_SALES","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]',
    0, 120, 3, 60,
    N'Parent Food Cost Day - aggregates child F_INV_SALES_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'STOCKEVENT', N'INV_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 6. PF_INVENTORY_EFFICIENCY_DAY — Tier 101
-- All metrics from F_INV_COUNTS_DAY only (no JOIN to F_INV_USAGE_DAY)
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000006-A0B1-C2D3-E4F5-A00000000006',
    N'Parent Inventory Efficiency Day',
    N'PF_INVENTORY_EFFICIENCY_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [COUNT_DATE],
    SUM([ACTUAL_COUNT] * [UOM_COST]) AS [INVENTORY_VALUE],
    SUM([THEO_USAGE] * [UOM_COST]) AS [THEO_USAGE_COST],
    SUM([ACTUAL_USAGE] * [UOM_COST]) AS [ACTUAL_USAGE_COST],
    SUM([VARIANCE] * [UOM_COST]) AS [VARIANCE_COST],
    SUM([WASTE_QTY] * [UOM_COST]) AS [WASTE_COST],
    SUM([TRANSFER_QTY] * [UOM_COST]) AS [TRANSFER_COST]
FROM {DB}.[presentation].[F_INV_COUNTS_DAY]
GROUP BY [LOCATION_HUB_ID], [COUNT_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"COUNT_DATE","table_column":"COUNT_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"INVENTORY_VALUE","table_column":"INVENTORY_VALUE","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"THEO_USAGE_COST","table_column":"THEO_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"ACTUAL_USAGE_COST","table_column":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"VARIANCE_COST","table_column":"VARIANCE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"WASTE_COST","table_column":"WASTE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TRANSFER_COST","table_column":"TRANSFER_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]',
    0, 130, 3, 60,
    N'Parent Inventory Efficiency Day - cost-weighted aggregates from child F_INV_COUNTS_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'STOCKEVENT', N'COUNT_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 7. PF_GROWTH_PERIOD — Tier 102 (depends on PF_REVENUE_DAY at Tier 101)
-- Inline period-over-period and YoY growth calculation via CTEs
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000007-A0B1-C2D3-E4F5-A00000000007',
    N'Parent Growth Period',
    N'PF_GROWTH_PERIOD',
    N'WITH PeriodBase AS (
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID,
        ''WEEK'' AS PERIOD_TYPE,
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE) AS PERIOD_START,
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE) AS PERIOD_END,
        SUM(R.NET_VALUE) AS NET_REVENUE, SUM(R.ORDER_COUNT) AS ORDER_COUNT
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''WEEK'',
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE),
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
),
GrowthCalc AS (
    SELECT cur.ORG_CODE, cur.ORG_NAME, cur.LOCATION_HUB_ID,
        cur.PERIOD_TYPE, cur.PERIOD_START, cur.PERIOD_END,
        cur.NET_REVENUE, cur.ORDER_COUNT,
        prv.NET_REVENUE AS PREV_PERIOD_REVENUE,
        yoy.NET_REVENUE AS PREV_YEAR_REVENUE
    FROM PeriodBase cur
    OUTER APPLY (
        SELECT TOP 1 p.NET_REVENUE FROM PeriodBase p
        WHERE p.ORG_CODE = cur.ORG_CODE AND p.PERIOD_TYPE = cur.PERIOD_TYPE
          AND ISNULL(p.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
          AND p.PERIOD_START < cur.PERIOD_START
        ORDER BY p.PERIOD_START DESC
    ) prv
    LEFT JOIN PeriodBase yoy
        ON yoy.ORG_CODE = cur.ORG_CODE AND yoy.PERIOD_TYPE = cur.PERIOD_TYPE
        AND ISNULL(yoy.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
        AND yoy.PERIOD_START = CASE cur.PERIOD_TYPE
            WHEN ''WEEK'' THEN DATEADD(DAY,-364,cur.PERIOD_START)
            WHEN ''MONTH'' THEN DATEADD(MONTH,-12,cur.PERIOD_START)
            WHEN ''QUARTER'' THEN DATEADD(MONTH,-12,cur.PERIOD_START) END
)
SELECT ORG_CODE, ORG_NAME, LOCATION_HUB_ID, PERIOD_TYPE, PERIOD_START, PERIOD_END,
    NET_REVENUE, ORDER_COUNT, PREV_PERIOD_REVENUE, PREV_YEAR_REVENUE,
    CASE WHEN PREV_PERIOD_REVENUE IS NULL OR PREV_PERIOD_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_PERIOD_REVENUE) / PREV_PERIOD_REVENUE * 100, 2) END AS REVENUE_GROWTH_PCT,
    CASE WHEN PREV_YEAR_REVENUE IS NULL OR PREV_YEAR_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_YEAR_REVENUE) / PREV_YEAR_REVENUE * 100, 2) END AS REVENUE_GROWTH_YOY_PCT,
    CASE WHEN ORDER_COUNT > 0 THEN NET_REVENUE / ORDER_COUNT ELSE NULL END AS AVG_ORDER_VALUE
FROM GrowthCalc',
    102,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"PERIOD_TYPE","table_column":"PERIOD_TYPE","data_type":"varchar(10)","target_data_type":"[varchar](10)"},{"query_column":"PERIOD_START","table_column":"PERIOD_START","data_type":"date","target_data_type":"[date]"},{"query_column":"PERIOD_END","table_column":"PERIOD_END","data_type":"date","target_data_type":"[date]"},{"query_column":"NET_REVENUE","table_column":"NET_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_PERIOD_REVENUE","table_column":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_YEAR_REVENUE","table_column":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"REVENUE_GROWTH_PCT","table_column":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"REVENUE_GROWTH_YOY_PCT","table_column":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"AVG_ORDER_VALUE","table_column":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 100, 3, 30,
    N'Parent Growth Period - week/month/quarter aggregates with inline period-over-period and YoY growth from PF_REVENUE_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'None', NULL
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);
