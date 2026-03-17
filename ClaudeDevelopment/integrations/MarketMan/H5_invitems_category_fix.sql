-- =============================================================================
-- FIX: H5_invitems_category_fix.sql
-- Issue: Category rows with NULL storeId produce duplicate INVITEM_IDs
-- Severity: HIGH
-- Date: 2026-03-04
-- =============================================================================
--
-- PROBLEM
-- -------
-- The MMAN_INVITEMS staging query has 5 UNION ALL branches:
--   Branch 1: Leaf items from DL_INVENTORY_ITEMS (BOTTOM_LEVEL=1)
--   Branch 2: Category items from DL_INVENTORY_ITEMS (BOTTOM_LEVEL=0)
--   Branch 3: Leaf items from DL_INVENTORY_PREPS (BOTTOM_LEVEL=1)
--   Branch 4: Category items from DL_INVENTORY_PREPS (BOTTOM_LEVEL=0)
--   Branch 5: COGS top-level categories from DL_ACTUAL_VS_THEO (BOTTOM_LEVEL=0)
--
-- Branches 2 and 5 can collide when key columns are NULL:
--   - Branch 2: INVITEM_ID = CONCAT_WS('-', storeId, CategoryID)
--     When CategoryID IS NULL -> INVITEM_ID = storeId alone
--   - Branch 5: INVITEM_ID = CONCAT_WS('-', storeId, COGSCategoryID)
--     When COGSCategoryID IS NULL -> INVITEM_ID = storeId alone
--
-- Both produce the bare storeId as INVITEM_ID, creating duplicates.
-- Confirmed: 1 duplicate pair on KUDU org (storeId 872cf667...).
--
-- ROOT CAUSE
-- ----------
-- Branch 5 (COGS top-level) has no WHERE clause, so rows with NULL
-- COGSCategoryID are included. A NULL COGSCategoryID does not represent
-- a real COGS category - it means the ACTUAL_VS_THEO row has no COGS
-- classification. These NULL rows are orphans: no category row references
-- them as parent (category rows use ISNULL(COGSCategoryID, -1) which
-- maps to the literal '-1' Unallocated category, not NULL).
--
-- FIX
-- ---
-- Add WHERE [COGSCategoryID] IS NOT NULL to the COGS top-level branch
-- (branch 5). This filters out the meaningless NULL COGSCategoryID rows
-- that cause the collision, without changing any key patterns or breaking
-- parent-child consistency.
--
-- The branch 2 "null category" rows (storeId with NULL CategoryID) remain
-- valid parents for uncategorized leaf items and are unaffected.
--
-- UPSERT: StagingControl keyed on (step_name)
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (
    N'Inventory Items'
)) AS src (step_name)
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        [staging_table] = N'MMAN_INVITEMS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
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
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
WHERE [COGSCategoryID] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL"]',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [description], [depends_on_steps], [retry_count], [timeout_minutes],
            [staging_columns], [created_at], [updated_at])
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
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
WHERE [COGSCategoryID] IS NOT NULL
) AS source_query;',
        1,      -- tier
        N'Staging',
        0,      -- exclude
        NULL,   -- description
        NULL,   -- depends_on_steps
        3,      -- retry_count
        30,     -- timeout_minutes
        N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL"]',
        GETDATE(),
        GETDATE()
    );
GO
