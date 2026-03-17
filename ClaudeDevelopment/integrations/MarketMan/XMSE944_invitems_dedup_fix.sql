/*
    FIX: XMSE-944 - Duplicate INVITEM_IDs in MMAN_INVITEMS Staging
    ================================================================

    PROBLEM:
    The MMAN_INVITEMS staging query has 5 UNION ALL branches. Branches 2 and 4
    extract category rows from DL_INVENTORY_ITEMS and DL_INVENTORY_PREPS
    respectively, using SELECT DISTINCT within each branch. When the same
    CategoryID exists in BOTH DL tables (which it does for 3 categories across
    9 stores = 27 duplicates), the UNION ALL produces duplicate INVITEM_IDs.

    The 3 duplicate categories (Three Rocks Cafe):
    - 362718: Milkshakes Inventory Count
    - 362721: Produce Inventory Count
    - 365898: Meats Inventory Count

    ERROR CHAIN:
    Duplicate INVITEM_ID in staging -> duplicate HUB_ID hash in load table ->
    PK violation in sp_PopulateLoadTable -> transaction doomed -> SQL error 3930
    -> entire DV load fails for ALL schemas (MarketMan AND NCRAloha blocked)

    IMPACT:
    MarketMan DV data stale since 2026-02-03 (~5 week gap).
    NCRAloha also blocked since 2026-03-11 due to shared DV load transaction.

    FIX:
    Consolidate branches 2 and 4 into a single category branch that UNIONs
    (not UNION ALL) both DL tables before extracting categories. The UNION
    deduplicates (storeId, CategoryID, CategoryName) across both sources.

    SUPERSEDES: H5_invitems_category_fix.sql AND C10_cross_store_invitems_fix.sql
    (all three MERGE the same StagingControl row; only the last deployed wins)

    This script includes all three fixes:
    - XMSE-944: Cross-branch category dedup (branches 2+4 consolidated)
    - H5: WHERE COGSCategoryID IS NOT NULL on COGS top-level branch
    - C10: WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL on COGS subqueries

    TARGETS: StagingControl (Inventory Items step)
    DEPLOY ORDER: Replaces H5 and C10 in sequence. Run at C10's position or later.
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
-- Branch 1: Bottom-level items from DL_INVENTORY_ITEMS
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

-- Branches 2+4 consolidated: Category rows from BOTH DL tables (deduped via UNION)
-- Fixes XMSE-944: prevents duplicate INVITEM_IDs when same CategoryID appears in both tables
SELECT DISTINCT
    CONCAT_WS(''-'', PARENT.[storeId], PARENT.[CategoryID]) as INVITEM_ID
    ,PARENT.[CategoryName] as InvItemName
    ,CONCAT_WS(''-'', PARENT.[storeId], ISNULL(COG.[COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL(COG.[COGSCategory],''Unallocated'') AS PARENT_NAME
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
FROM (
    SELECT [storeId], [CategoryID], [CategoryName], [IsDeleted]
    FROM [int_marketman001].[DL_INVENTORY_ITEMS]
    UNION
    SELECT [storeId], [CategoryID], [CategoryName], [IsDeleted]
    FROM [int_marketman001].[DL_INVENTORY_PREPS]
) PARENT
LEFT OUTER JOIN (
    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
) COG ON PARENT.[CategoryID] = COG.[CategoryID]
WHERE PARENT.IsDeleted != 1

UNION ALL

-- Branch 3: Bottom-level items from DL_INVENTORY_PREPS
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

-- Branch 5: Top-level COGS categories
-- H5 fix: WHERE COGSCategoryID IS NOT NULL (removes orphan NULL key collision)
-- C10 fix: WHERE storeId = BueyrGuid (removes cross-store phantom entries)
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
WHERE ([storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL)
  AND [COGSCategoryID] IS NOT NULL
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
