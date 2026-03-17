-- ==============================================
-- Parent Organisation Reporting: Presentation Table DDLs
-- Date: 2026-03-09
-- 7 PresentationTables records (2 dims + 5 facts)
-- ==============================================

-- -----------------------------------------------
-- 1. PD_ORGANISATION — Organisation dimension
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PD_ORGANISATION',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[PD_ORGANISATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [ORG_PREFIX] [nvarchar](255) NOT NULL,
    [DATABASE_NAME] [nvarchar](128) NULL,
    [IS_ACTIVE] [bit] NOT NULL,
    [CREATED_DATE] [datetime2](7) NULL
) ON [PRIMARY];

CREATE UNIQUE CLUSTERED INDEX [PD_ORGANISATION-CLUSTERED] ON [presentation].[PD_ORGANISATION]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"ORG_PREFIX","data_type":"nvarchar(255)","nullable":false},{"name":"DATABASE_NAME","data_type":"nvarchar(128)","nullable":true},{"name":"IS_ACTIVE","data_type":"bit","nullable":false},{"name":"CREATED_DATE","data_type":"datetime2(7)","nullable":true}]',
    N'Organisation dimension for parent reporting - lists child organisations',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
               column_definitions = src.column_definitions, description = src.description,
               business_owner = src.business_owner, data_source = src.data_source,
               status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description,
            business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description,
            src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 2. PD_LOCATION — Combined location dimension
-- 38 D_LOCATION columns + 2 org columns = 40 total
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PD_LOCATION',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[PD_LOCATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_LOCATION_NAME] [nvarchar](255) NULL,
    [BOTTOM_LOCATION_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PD_LOCATION-CLUSTERED] ON [presentation].[PD_LOCATION]
(
    [ORG_CODE] ASC,
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PD_LOCATION-BOTTOM_HUB_ID] ON [presentation].[PD_LOCATION]
(
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"BOTTOM_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"BOTTOM_SRC","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_CURRENT_FLAG","data_type":"bit","nullable":true},{"name":"BOTTOM_IS_DELETED","data_type":"bit","nullable":true},{"name":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"HIERARCHY_PATH","data_type":"nvarchar(255)","nullable":true},{"name":"TOTAL_LEVELS","data_type":"decimal(38,10)","nullable":true}]',
    N'Combined location dimension for parent reporting - unions child org D_LOCATION tables with org identifier',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
               column_definitions = src.column_definitions, description = src.description,
               business_owner = src.business_owner, data_source = src.data_source,
               status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description,
            business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description,
            src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 3. PF_REVENUE_DAY — Daily revenue fact
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_REVENUE_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_REVENUE_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [LI_TYPE] [nvarchar](255) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [GROSS_VALUE] [decimal](38, 10) NULL,
    [TAX_VALUE] [decimal](38, 10) NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_REVENUE_DAY-CLUSTERED] ON [presentation].[PF_REVENUE_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-ORG] ON [presentation].[PF_REVENUE_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-LOCATION] ON [presentation].[PF_REVENUE_DAY]
(
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-CHANNEL] ON [presentation].[PF_REVENUE_DAY]
(
    [CHANNEL_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"LI_TYPE","data_type":"nvarchar(255)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"GROSS_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"TAX_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true}]',
    N'Parent fact: daily revenue aggregated from child org F_LINEITEM_15MIN tables',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
               column_definitions = src.column_definitions, description = src.description,
               business_owner = src.business_owner, data_source = src.data_source,
               status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description,
            business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description,
            src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 4. PF_PROFIT_DAY — Daily profit fact
-- Note: DISCOUNT_IMPACT is positive when discounts reduce profit
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_PROFIT_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_PROFIT_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL,
    [PROFIT] [decimal](38, 10) NULL,
    [PROFIT_LESS_DISCOUNT] [decimal](38, 10) NULL,
    [DISCOUNT_IMPACT] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_PROFIT_DAY-CLUSTERED] ON [presentation].[PF_PROFIT_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_PROFIT_DAY-ORG] ON [presentation].[PF_PROFIT_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","nullable":true},{"name":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","nullable":true}]',
    N'Parent fact: daily profit aggregated from child org F_PRODUCT_MARGIN_DAY tables',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 5. PF_FOODCOST_DAY — Daily food cost fact
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_FOODCOST_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_FOODCOST_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [INV_DATE] [datetime2](7) NOT NULL,
    [TOTAL_UOM_COST] [decimal](38, 6) NULL,
    [TOTAL_RECIPE_COST] [decimal](38, 6) NULL,
    [NET_SALES] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_FOODCOST_DAY-CLUSTERED] ON [presentation].[PF_FOODCOST_DAY]
(
    [INV_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_FOODCOST_DAY-ORG] ON [presentation].[PF_FOODCOST_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"INV_DATE","data_type":"datetime2(7)","nullable":false},{"name":"TOTAL_UOM_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"NET_SALES","data_type":"decimal(38,6)","nullable":true}]',
    N'Parent fact: daily food cost aggregated from child org F_INV_SALES_DAY tables',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 6. PF_INVENTORY_EFFICIENCY_DAY — Daily inventory efficiency fact
-- Simplification: all columns sourced from F_INV_COUNTS_DAY only (no JOIN to F_INV_USAGE_DAY)
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_INVENTORY_EFFICIENCY_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_INVENTORY_EFFICIENCY_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [COUNT_DATE] [datetime2](7) NOT NULL,
    [INVENTORY_VALUE] [decimal](38, 6) NULL,
    [THEO_USAGE_COST] [decimal](38, 6) NULL,
    [ACTUAL_USAGE_COST] [decimal](38, 6) NULL,
    [VARIANCE_COST] [decimal](38, 6) NULL,
    [WASTE_COST] [decimal](38, 6) NULL,
    [TRANSFER_COST] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-CLUSTERED] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [COUNT_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-ORG] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"COUNT_DATE","data_type":"datetime2(7)","nullable":false},{"name":"INVENTORY_VALUE","data_type":"decimal(38,6)","nullable":true},{"name":"THEO_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"VARIANCE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"WASTE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TRANSFER_COST","data_type":"decimal(38,6)","nullable":true}]',
    N'Parent fact: daily inventory efficiency metrics (cost-weighted) from child org F_INV_COUNTS_DAY',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 7. PF_GROWTH_PERIOD — Period-over-period growth fact
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_GROWTH_PERIOD',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_GROWTH_PERIOD](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NULL,
    [PERIOD_TYPE] [varchar](10) NOT NULL,
    [PERIOD_START] [date] NOT NULL,
    [PERIOD_END] [date] NOT NULL,
    [NET_REVENUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [PREV_PERIOD_REVENUE] [decimal](38, 10) NULL,
    [PREV_YEAR_REVENUE] [decimal](38, 10) NULL,
    [REVENUE_GROWTH_PCT] [decimal](10, 4) NULL,
    [REVENUE_GROWTH_YOY_PCT] [decimal](10, 4) NULL,
    [AVG_ORDER_VALUE] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_GROWTH_PERIOD-CLUSTERED] ON [presentation].[PF_GROWTH_PERIOD]
(
    [PERIOD_TYPE] ASC,
    [PERIOD_START] ASC,
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_GROWTH_PERIOD-ORG] ON [presentation].[PF_GROWTH_PERIOD]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"PERIOD_TYPE","data_type":"varchar(10)","nullable":false},{"name":"PERIOD_START","data_type":"date","nullable":false},{"name":"PERIOD_END","data_type":"date","nullable":false},{"name":"NET_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","nullable":true}]',
    N'Parent fact: period-over-period growth metrics derived from PF_REVENUE_DAY',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);
