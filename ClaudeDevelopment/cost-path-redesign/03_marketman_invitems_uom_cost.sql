-- =============================================================================
-- Script: 03_marketman_invitems_uom_cost.sql
-- Part of: Inventory Cost Path Redesign
-- Purpose: (1) Add UOM_COST column to MMAN_INVITEMS staging step
--          (2) Add UOM_COST to INVITEM entity mapping
-- =============================================================================

-- =============================================================================
-- PART 1: Update MMAN_INVITEMS staging step in StagingControl
--         Adds TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST to leaf branches
--         and CAST(NULL AS DECIMAL(38,10)) AS UOM_COST to category/COGS branches.
--         Also appends "UOM_COST" to staging_columns JSON array.
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Inventory Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table = N'MMAN_INVITEMS',
        query_sql = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_INVITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_INVITEMS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_INVITEMS]
FROM (
SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,[ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,[MinOrderQty]
    ,[MaxOrderQty]
    ,[DateRangeType]
    ,[IsDeleted]
    ,[CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_ITEMS]WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM    [int_marketman001].[DL_INVENTORY_ITEMS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1

UNION ALL

SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,NULL AS [ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,NULL AS [MinOrderQty]
    ,NULL AS [MaxOrderQty]
    ,NULL AS [DateRangeType]
    ,[IsDeleted]
    ,NULL AS [CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_PREPS]WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM    [int_marketman001].[DL_INVENTORY_PREPS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1UNION ALLSELECT DISTINCT
    CONCAT_WS(''-'',[storeId],[COGSCategoryID]) as INVITEM_ID
    ,[COGSCategory] as InvItemName
    ,NULL AS PARENT_ID
    ,NULL AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) AS source_query;',
        tier = 1,
        step_type = N'Staging',
        exclude = 0,
        description = NULL,
        depends_on_steps = NULL,
        retry_count = 3,
        timeout_minutes = 30,
        staging_columns = N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL", "UOM_COST"]',
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (
        N'Inventory Items',
        N'MMAN_INVITEMS',
        N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_INVITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_INVITEMS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_INVITEMS]
FROM (
SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,[ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,[MinOrderQty]
    ,[MaxOrderQty]
    ,[DateRangeType]
    ,[IsDeleted]
    ,[CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_ITEMS]WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM    [int_marketman001].[DL_INVENTORY_ITEMS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1

UNION ALL

SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,NULL AS [ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,NULL AS [MinOrderQty]
    ,NULL AS [MaxOrderQty]
    ,NULL AS [DateRangeType]
    ,[IsDeleted]
    ,NULL AS [CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_PREPS]WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM    [int_marketman001].[DL_INVENTORY_PREPS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1UNION ALLSELECT DISTINCT
    CONCAT_WS(''-'',[storeId],[COGSCategoryID]) as INVITEM_ID
    ,[COGSCategory] as InvItemName
    ,NULL AS PARENT_ID
    ,NULL AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) AS source_query;',
        1,
        N'Staging',
        0,
        NULL,
        NULL,
        3,
        30,
        N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL", "UOM_COST"]',
        GETDATE(),
        GETDATE()
    );
GO

-- =============================================================================
-- PART 2: Update INVITEM entity mapping in EntityMappings
--         Appends UOM_COST to source_columns (hash: 0) and entity_columns.
--
-- Current source_columns (12 entries):
--   INVITEM_ID (hash:1), InvItemName, PARENT_ID, PARENT_NAME, UOM, ParLevel,
--   MinOrderQty, MaxOrderQty, DateRangeType, IsDeleted, BOTTOM_LEVEL, INVITEM_ID
-- Current entity_columns (12 entries):
--   HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, UOM, ATTR_1, ATTR_2, ATTR_3,
--   ATTR_4, ATTR_5, BOTTOM_LEVEL, INVITEM_ID
-- =============================================================================

MERGE INTO [core].[int_marketman001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM', N'MMAN_INVITEMS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns = N'[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
        entity_columns = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "BOTTOM_LEVEL", "INVITEM_ID", "UOM_COST"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column,
            track_deletions, created_at, updated_at, is_active)
    VALUES (
        N'INVITEM',
        N'MMAN_INVITEMS',
        N'[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
        N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "BOTTOM_LEVEL", "INVITEM_ID", "UOM_COST"]',
        NULL,
        NULL,
        NULL,
        0,
        GETDATE(),
        GETDATE(),
        1
    );
GO
