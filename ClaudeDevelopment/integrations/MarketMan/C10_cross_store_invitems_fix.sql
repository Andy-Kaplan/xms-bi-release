/*
    FIX: C10 - Cross-Store Buyer Bleed in Inventory Items Staging
    ==============================================================

    PROBLEM:
    The "Inventory Items" staging step reads DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS
    in three places:
    1. COGS category lookup for DL_INVENTORY_ITEMS (SELECT DISTINCT with storeId=NULL)
    2. COGS category lookup for DL_INVENTORY_PREPS (SELECT DISTINCT with storeId=NULL)
    3. Top-level COGS category rows (uses storeId in INVITEM_ID)

    Places 1 & 2 use SELECT DISTINCT and NULL storeId, so cross-store data just
    adds redundant rows that collapse to the same distinct set — low impact.

    Place 3 creates INVITEM hierarchy top-level records keyed by storeId. Cross-store
    rows create phantom COGS category entries under the wrong storeId (e.g. "Beverage"
    under ed84ceb7... when it should only exist under 9dbec6a3...).

    FIX:
    Add WHERE clause to all three DL_ACTUAL_VS_THEO subqueries:
    WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL

    IMPACT:
    - Removes phantom COGS category INVITEM records under wrong storeId
    - COGS category lookups remain functionally identical (DISTINCT already collapsed dupes)
    - Cleaner INVITEM hierarchy in data vault

    TARGETS: StagingControl (Inventory Items step)
*/

MERGE INTO [int_marketman001].[StagingControl] AS tgt
USING (VALUES (
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
FROM [int_marketman001].[DL_INVENTORY_ITEMS]
WHERE IsDeleted != 1

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
FROM
    [int_marketman001].[DL_INVENTORY_ITEMS] PARENT
LEFT OUTER JOIN
    (
    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
        [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
     WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
    ) COG
ON PARENT.[CategoryID] = COG.[CategoryID]
WHERE IsDeleted != 1

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
FROM [int_marketman001].[DL_INVENTORY_PREPS]
WHERE IsDeleted != 1

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
FROM
    [int_marketman001].[DL_INVENTORY_PREPS] PARENT
LEFT OUTER JOIN
    (
    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
        [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
     WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
    ) COG
ON PARENT.[CategoryID] = COG.[CategoryID]
WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
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
WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
) AS source_query;'
)) AS src (step_name, staging_table, query_sql)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = src.query_sql,
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, staging_columns, query_sql, tier)
    VALUES (src.step_name, src.staging_table, '*', src.query_sql, 1);
