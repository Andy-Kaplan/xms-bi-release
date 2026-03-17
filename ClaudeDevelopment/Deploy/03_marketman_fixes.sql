-- ============================================================================
-- 03_marketman_fixes.sql
-- Consolidated deployment script: MarketMan integration fixes
-- Target: Core database
-- Deploy order: C1 > C3 > H5 > H7 > C5 > C6 > H2 > C2 > C9 > C10
-- ============================================================================

-- ============================================================================
-- SECTION 1 of 10: C1 — Occasion sentinel staging + hub mapping
-- Source: C1_occasion_sentinel.sql
-- ============================================================================
-- =============================================================================
-- FIX C1: MarketMan Occasion Sentinel
-- =============================================================================
-- PROBLEM:
--   MarketMan has no occasion data. OCC_ID is hardcoded to '-999' in both
--   MMAN_PRODUCT and MMAN_LINEITEM staging. SHA256Hash('-999') produces a hash
--   that doesn't exist in HUB_OCCASION. All 4 occasion link mappings
--   (CUSTORDER_OCCASION, LINEITEM_OCCASION, LOCATION_OCCASION_PRODUCT,
--   INVITEM_LOCATION_OCCASION_PRODUCT) have 100% orphan rate on OCCASION_HUB_ID.
--
-- FIX:
--   1. New StagingControl step 'MarketMan Occasion' producing 1 sentinel row
--      in stage.MMAN_OCCASION with OCC_ID = '-999' (matching the hardcoded value)
--   2. New EntityMappings record mapping OCCASION hub from MMAN_OCCASION so that
--      SHA256Hash('-999') resolves to a valid HUB_OCCASION row
--
-- EFFECT:
--   After deployment, the DV load will create 1 row in HUB_OCCASION with
--   HUB_ID = SHA256Hash('-999'). All link rows referencing OCC_ID = '-999'
--   will join successfully to this hub row.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. StagingControl: MMAN_OCCASION (Tier 1)
-- -----------------------------------------------------------------------------
-- Produces exactly 1 sentinel row. The OCC_ID '-999' matches the hardcoded
-- value in MMAN_PRODUCT.OCC_ID and MMAN_LINEITEM.OCC_ID.
-- -----------------------------------------------------------------------------

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'MarketMan Occasion')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table   = N'MMAN_OCCASION',
        query_sql       = N'IF OBJECT_ID(''stage.MMAN_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_OCCASION];

SELECT * INTO [stage].[MMAN_OCCASION]
FROM (
    SELECT
        ''-999'' AS OCC_ID,
        ''Not Applicable'' AS OCC_NAME,
        NULL AS PARENT_ID,
        ''Occasion'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL
) src;',
        tier            = 1,
        step_type       = N'Staging',
        exclude         = 0,
        description     = N'Sentinel occasion row for MarketMan (no occasion data in source)',
        depends_on_steps = NULL,
        retry_count     = 3,
        timeout_minutes = 30,
        staging_columns = N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        updated_at      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (
        N'MarketMan Occasion',
        N'MMAN_OCCASION',
        N'IF OBJECT_ID(''stage.MMAN_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_OCCASION];

SELECT * INTO [stage].[MMAN_OCCASION]
FROM (
    SELECT
        ''-999'' AS OCC_ID,
        ''Not Applicable'' AS OCC_NAME,
        NULL AS PARENT_ID,
        ''Occasion'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL
) src;',
        1,
        N'Staging',
        0,
        N'Sentinel occasion row for MarketMan (no occasion data in source)',
        NULL,
        3,
        30,
        N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        GETDATE(),
        GETDATE()
    );
GO

-- -----------------------------------------------------------------------------
-- 2. EntityMappings: OCCASION hub from MMAN_OCCASION
-- -----------------------------------------------------------------------------
-- Maps the sentinel row into HUB_OCCASION / SAT_OCCASION.
--
-- source_columns JSON format (per NCRAloha pattern):
--   - OCC_ID  hashed=1  -> HUB_ID        (business key hash)
--   - OCC_ID  hashed=0  -> OCCASSION_ID   (native ID, note: double-S typo is baked in)
--   - OCC_NAME hashed=0 -> OCCASION_NAME  (satellite attribute)
--   - LEVEL_NAME hashed=0 -> LEVEL_NAME   (satellite attribute)
--   - BOTTOM_LEVEL hashed=0 -> BOTTOM_LEVEL (satellite attribute)
--
-- entity_columns must match the NCRAloha OCCASION mapping pattern:
--   ["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]
-- -----------------------------------------------------------------------------

MERGE INTO [core].[int_marketman001].[EntityMappings] AS tgt
USING (VALUES ('OCCASION', 'MMAN_OCCASION')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = '[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns      = '["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (
        'A7E3D4B1-6F29-4C8A-B5D7-3E1F9A2C0D45',
        'OCCASION',
        'MMAN_OCCASION',
        '[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        '["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        NULL,
        NULL,
        NULL,
        0,
        GETDATE(),
        GETDATE(),
        1
    );
GO

-- ============================================================================
-- SECTION 2 of 10: C3 — INVITEM PARENT_ID hash fix
-- Source: C3_invitem_parent_hash.sql
-- ============================================================================
-- =============================================================================
-- FIX: C3_invitem_parent_hash.sql
-- Issue: SAT_INVITEM.PARENT_ID stores raw source strings instead of BINARY(32) hashes
-- Severity: CRITICAL
-- Date: 2026-03-04
-- =============================================================================
--
-- PROBLEM
-- -------
-- The INVITEM entity mapping has PARENT_ID with {"hash": 0}, so the staging
-- value (e.g. "9dbec6a3...-583815") is stored as-is in SAT_INVITEM.PARENT_ID.
-- However, HUB_INVITEM.HUB_ID is a SHA-256 BINARY(32) hash of the same string.
-- Any JOIN between SAT_INVITEM.PARENT_ID and HUB_INVITEM.HUB_ID always fails
-- because the types are incompatible (raw string vs hash). This breaks the
-- entire INVITEM hierarchy: category lookups, D_INVITEM dimension build,
-- and inventory cost roll-ups all silently return no matches.
--
-- ROOT CAUSE
-- ----------
-- In the source_columns JSON for the INVITEM entity mapping, PARENT_ID has
-- "hash": 0 when it should be "hash": 1. The mapping system hashes columns
-- with "hash": 1 using SHA-256 before loading to the Data Vault, matching
-- the HUB_ID generation pattern.
--
-- FIX
-- ---
-- Change PARENT_ID from {"name": "PARENT_ID", "hash": 0} to
-- {"name": "PARENT_ID", "hash": 1} in the EntityMappings record.
-- This ensures PARENT_ID is SHA-256 hashed before storage, making it
-- compatible with HUB_INVITEM.HUB_ID for hierarchy joins.
--
-- After deploying this fix, a full reload of the INVITEM entity is required
-- to re-hash existing PARENT_ID values.
--
-- UPSERT: EntityMappings keyed on (entity_name, source_table)
-- =============================================================================

MERGE INTO [core].[int_marketman001].[EntityMappings] AS tgt
USING (VALUES (
    N'INVITEM',
    N'MMAN_INVITEMS'
)) AS src (entity_name, source_table)
ON tgt.[entity_name] = src.[entity_name]
   AND tgt.[source_table] = src.[source_table]
WHEN MATCHED THEN
    UPDATE SET
        [source_columns] = N'[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 1}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}]',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([id], [entity_name], [source_table], [source_columns], [entity_columns],
            [type2_columns], [cdc_exclude_columns], [date_filter_column],
            [track_deletions], [created_at], [updated_at], [is_active])
    VALUES (
        NEWID(),
        N'INVITEM',
        N'MMAN_INVITEMS',
        N'[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 1}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}]',
        N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "BOTTOM_LEVEL", "INVITEM_ID"]',
        NULL,   -- type2_columns
        NULL,   -- cdc_exclude_columns
        NULL,   -- date_filter_column
        0,      -- track_deletions
        GETDATE(),
        GETDATE(),
        1       -- is_active
    );
GO

-- ============================================================================
-- SECTION 3 of 10: H5 — INVITEMS category duplicate fix (COGSCategoryID NULL)
-- Source: H5_invitems_category_fix.sql
-- ============================================================================
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

-- ============================================================================
-- SECTION 4 of 10: H7 — Prep recipes deduplication (3x row inflation)
-- Source: H7_prep_recipes_dedup.sql
-- ============================================================================
-- =============================================================================
-- H7_prep_recipes_dedup.sql
-- Fix: MMAN_PREP_RECIPES 3x row inflation from multi-fetch without dedup
-- =============================================================================
--
-- PROBLEM:
--   MMAN_PREP_RECIPES produces 12,501 rows from 4,167 source rows (3x inflation).
--   DL_INVENTORY_PREPS_SUBITEMS has multiple INT_FETCH_DATE values for the same
--   recipe records (each API fetch appends rows). The staging query has no
--   deduplication, so every fetch duplicate flows through to the staging table.
--
-- FIX:
--   Wrap the existing SELECT in a CTE with:
--     ROW_NUMBER() OVER (
--       PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
--       ORDER BY REC.[INT_FETCH_DATE] DESC
--     ) AS rn
--   Then filter to rn = 1, keeping only the most recent fetch of each recipe
--   ingredient line.
--
-- TARGET: core.int_marketman001.StagingControl, step_name = 'MMAN_PREP_RECIPES'
-- PATTERN: MERGE upsert on step_name
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'MMAN_PREP_RECIPES')) AS src (step_name)
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        [staging_table] = N'MMAN_PREP_RECIPES',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    PARENT_HUB_ID
    ,CHILD_HUB_ID
    ,UOM
    ,UOM_VALUE
FROM (
    SELECT
        CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
        ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
        ,UOM.[Name] AS UOM
        ,[ActualUsage] AS UOM_VALUE
        ,ROW_NUMBER() OVER (
            PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
            ORDER BY REC.[INT_FETCH_DATE] DESC
        ) AS rn
    FROM
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
) deduped
WHERE rn = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'MMAN_PREP_RECIPES', N'MMAN_PREP_RECIPES', N'IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    PARENT_HUB_ID
    ,CHILD_HUB_ID
    ,UOM
    ,UOM_VALUE
FROM (
    SELECT
        CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
        ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
        ,UOM.[Name] AS UOM
        ,[ActualUsage] AS UOM_VALUE
        ,ROW_NUMBER() OVER (
            PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
            ORDER BY REC.[INT_FETCH_DATE] DESC
        ) AS rn
    FROM
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
) deduped
WHERE rn = 1
) AS source_query;',
           1, N'Staging', 0, NULL, NULL, 3, 30,
           N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
           GETDATE(), GETDATE());
GO

-- ============================================================================
-- SECTION 5 of 10: C5 — Report CONCAT_WS separator bug fix
-- Source: C5_report_id_fix.sql
-- ============================================================================
-- =============================================================================
-- C5_report_id_fix.sql
-- Fix: MMAN_REPORT CONCAT_WS separator bug
-- =============================================================================
--
-- PROBLEM:
--   The MMAN_REPORT staging step constructs REPORT_ID as:
--     CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID])
--
--   CONCAT_WS uses the FIRST argument as the separator. The DATETIME2-cast date
--   is consumed as the separator between storeId and ItemID -- the date itself
--   never appears as a standalone value in REPORT_ID.
--
--   Additionally, 7 rows have NULL ItemID. CONCAT_WS skips NULLs, producing
--   6 duplicate REPORT_IDs (storeId alone with date as separator).
--
-- FIX:
--   Change CONCAT_WS to use '-' as the separator, include the date as a value,
--   and wrap ItemID in ISNULL(..., 'NO_ITEM') to prevent NULL collisions:
--     CONCAT_WS('-', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.[storeId], ISNULL(REP.[ItemID], 'NO_ITEM'))
--
-- TARGET: core.int_marketman001.StagingControl, step_name = 'Report'
-- PATTERN: MERGE upsert on step_name
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Report')) AS src (step_name)
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        [staging_table] = N'MMAN_REPORT',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(''-'', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.[storeId], ISNULL(REP.[ItemID], ''NO_ITEM'')) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID]
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Report', N'MMAN_REPORT', N'IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(''-'', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.[storeId], ISNULL(REP.[ItemID], ''NO_ITEM'')) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID]
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
) AS source_query;',
           1, N'Staging', 0, NULL, NULL, 3, 30,
           N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]',
           GETDATE(), GETDATE());
GO

-- ============================================================================
-- SECTION 6 of 10: C6 — Waste events NULL BuyerGuid JOIN fix
-- Source: C6_waste_events_fix.sql
-- ============================================================================
-- =============================================================================
-- C6_waste_events_fix.sql
-- Fix: MMAN_WASTE_EVENTS drops 81% of rows due to NULL BuyerGuid JOIN
-- =============================================================================
--
-- PROBLEM:
--   The MMAN_WASTE_EVENTS staging step JOINs DL_WASTE_EVENTS (WE) to
--   DL_WASTE_EVENTS_LINES (WEI) with three conditions:
--     ON WE.[ID] = WEI.[ID]
--     AND WE.[storeId] = WEI.[storeId]
--     AND WE.[BuyerGuid] = WEI.[storeId]
--
--   The third condition (WE.[BuyerGuid] = WEI.[storeId]) drops 81% of rows
--   because 17 out of 21 waste events have NULL BuyerGuid. NULL != anything
--   evaluates to UNKNOWN, so the JOIN fails silently for those rows.
--
-- FIX:
--   Remove the AND WE.[BuyerGuid] = WEI.[storeId] condition. The remaining
--   two conditions (ON WE.[ID] = WEI.[ID] AND WE.[storeId] = WEI.[storeId])
--   are sufficient to correctly match waste event headers to their line items.
--
-- TARGET: core.int_marketman001.StagingControl, step_name = 'Waste Events'
-- PATTERN: MERGE upsert on step_name
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Waste Events')) AS src (step_name)
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        [staging_table] = N'MMAN_WASTE_EVENTS',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

SELECT * INTO [stage].[MMAN_WASTE_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''WASTE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        WEI.[ItemID]
        ,WE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', WEI.[ItemID], WE.[storeId], WE.[ID]) AS EVENT_ID
        ,CAST(WE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_WASTE_EVENTS] WE
    INNER JOIN
	    [int_marketman001].[DL_WASTE_EVENTS_LINES] WEI
    ON WE.[ID] = WEI.[ID]
    AND WE.[storeId] = WEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON WEI.UOMID = UOM.ID
    AND WEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Waste Events', N'MMAN_WASTE_EVENTS', N'IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

SELECT * INTO [stage].[MMAN_WASTE_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''WASTE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        WEI.[ItemID]
        ,WE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', WEI.[ItemID], WE.[storeId], WE.[ID]) AS EVENT_ID
        ,CAST(WE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_WASTE_EVENTS] WE
    INNER JOIN
	    [int_marketman001].[DL_WASTE_EVENTS_LINES] WEI
    ON WE.[ID] = WEI.[ID]
    AND WE.[storeId] = WEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON WEI.UOMID = UOM.ID
    AND WEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
           1, N'Staging', 0, NULL, NULL, 3, 30,
           N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
           GETDATE(), GETDATE());
GO

-- ============================================================================
-- SECTION 7 of 10: H2 — PurchaseItem deduplication (Invoice + Order Items)
-- Source: H2_purchaseitem_dedup.sql
-- ============================================================================
-- =============================================================================
-- FIX: H2_purchaseitem_dedup.sql
-- Priority: HIGH (H2)
-- Date: 2026-03-04
-- =============================================================================
--
-- PROBLEM:
--   DL_INVENTORY_ITEMS_PURCHASEITEMS contains duplicate rows: 10 combinations
--   of (SupplierName, CatalogItemCode, storeId) have 2 rows each, differing
--   only in the ID column. Both MMAN_PRE_INVOICE and MMAN_PRE_ORDEREVENT join
--   to this table on (SupplierName, CatalogItemCode, storeId), causing fan-out:
--     - MMAN_PRE_INVOICE: 4 duplicate invoice rows (LEFT OUTER JOIN)
--     - MMAN_PRE_ORDEREVENT: 2 duplicate order rows (INNER JOIN)
--   The GROUP BY includes ipi.ID, so duplicates are not collapsed.
--
-- FIX:
--   Replace the direct JOIN to DL_INVENTORY_ITEMS_PURCHASEITEMS with a JOIN to
--   a deduped subquery using ROW_NUMBER() OVER (PARTITION BY SupplierName,
--   CatalogItemCode, storeId ORDER BY ID). Add AND ipi.rn = 1 to the ON clause
--   so only one purchaseitem row matches per (Supplier, CatalogItem, Store).
--
-- SCOPE:
--   Two StagingControl records updated:
--     1. 'Invoice Items' (MMAN_PRE_INVOICE) - LEFT OUTER JOIN preserved
--     2. 'Order Items'   (MMAN_PRE_ORDEREVENT) - INNER JOIN preserved
--
-- DEPLOY: Run against the core database.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Invoice Items (MMAN_PRE_INVOICE) - Fix LEFT OUTER JOIN to deduped subquery
-- -----------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Invoice Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID
    ,di.CatalogItemCode
    ,TRY_CAST(d.DocTypeID AS INT) as DocTypeID
    ,d.DocType
    ,TRY_CAST(d.DocStatusID AS INT) as DocStatusID
    ,d.DocStatusType
    ,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
    ,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
    ,TRY_CAST(d.DateUTC AS datetime2) as DocDateUTC
    ,TRY_CAST(d.DueDateUTC AS datetime2) as DueDateUTC
    ,d.VendorGuid
    ,d.BuyerGuid
    ,ipi.ID as ItemId
    ,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as ORDER_PACK_QUANTITY
    ,SUM(CAST(di.OrderQuantity AS DECIMAL(19,3))) as DOC_ORDERED_PACK_QUANTITY
    ,SUM(CAST(di.Quantity AS DECIMAL(19,3))) as DOC_PACK_QUANTITY
    ,SUM(CAST(di.ReceiveQuantity AS DECIMAL(19,3))) as DELIVERED_PACK_QUANTITY
    ,SUM(CAST(di.TaxValue AS DECIMAL(19,3))) as TaxValue
    ,SUM(CAST(di.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName
      ,di.ItemMeasureTypeName
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))
,di.CatalogItemID
,di.CatalogItemCode
,TRY_CAST(d.DocTypeID AS INT)
,d.DocType
,TRY_CAST(d.DocStatusID AS INT)
,d.DocStatusType
,TRY_CAST(o.OrderStatusUIName as nvarchar(256))
,TRY_CAST(o.DeliveryDateUTC AS datetime2)
,TRY_CAST(d.DateUTC AS datetime2)
,TRY_CAST(d.DueDateUTC AS datetime2)
,d.VendorGuid
,d.BuyerGuid
,ipi.ID
) AS source_query;',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [retry_count], [timeout_minutes],
            [staging_columns], [created_at], [updated_at])
    VALUES (N'Invoice Items', N'MMAN_PRE_INVOICE',
            N'IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID
    ,di.CatalogItemCode
    ,TRY_CAST(d.DocTypeID AS INT) as DocTypeID
    ,d.DocType
    ,TRY_CAST(d.DocStatusID AS INT) as DocStatusID
    ,d.DocStatusType
    ,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
    ,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
    ,TRY_CAST(d.DateUTC AS datetime2) as DocDateUTC
    ,TRY_CAST(d.DueDateUTC AS datetime2) as DueDateUTC
    ,d.VendorGuid
    ,d.BuyerGuid
    ,ipi.ID as ItemId
    ,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as ORDER_PACK_QUANTITY
    ,SUM(CAST(di.OrderQuantity AS DECIMAL(19,3))) as DOC_ORDERED_PACK_QUANTITY
    ,SUM(CAST(di.Quantity AS DECIMAL(19,3))) as DOC_PACK_QUANTITY
    ,SUM(CAST(di.ReceiveQuantity AS DECIMAL(19,3))) as DELIVERED_PACK_QUANTITY
    ,SUM(CAST(di.TaxValue AS DECIMAL(19,3))) as TaxValue
    ,SUM(CAST(di.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName
      ,di.ItemMeasureTypeName
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))
,di.CatalogItemID
,di.CatalogItemCode
,TRY_CAST(d.DocTypeID AS INT)
,d.DocType
,TRY_CAST(d.DocStatusID AS INT)
,d.DocStatusType
,TRY_CAST(o.OrderStatusUIName as nvarchar(256))
,TRY_CAST(o.DeliveryDateUTC AS datetime2)
,TRY_CAST(d.DateUTC AS datetime2)
,TRY_CAST(d.DueDateUTC AS datetime2)
,d.VendorGuid
,d.BuyerGuid
,ipi.ID
) AS source_query;',
            1, N'Staging', 0, 3, 30,
            N'["OrderNumber", "storeId", "EVENT_TYPE", "DOC_PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "DocTypeID", "DocType", "DocStatusID", "DocStatusType", "OrderStatusUIName", "DeliveryDateUTC", "DocDateUTC", "DueDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "ORDER_PACK_QUANTITY", "DOC_ORDERED_PACK_QUANTITY", "DOC_PACK_QUANTITY", "DELIVERED_PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
            GETDATE(), GETDATE());
GO

-- -----------------------------------------------------------------------------
-- 2. Order Items (MMAN_PRE_ORDEREVENT) - Fix INNER JOIN to deduped subquery
-- -----------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Order Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

SELECT * INTO [stage].[MMAN_PRE_ORDEREVENT]
FROM (
SELECT  od.OrderNumber
,od.StoreId
,''ORDER'' as EVENT_TYPE
,o.SentDateUTC as EVENT_TS
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
,od.ItemMeasureTypeName as UOM
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
,od.CatalogItemID
,od.CatalogItemCode
,''info'' as EVENT_BEHAVIOUR
,TRY_CAST(o.OrderStatus AS INT) as OrderStatus
,o.OrderStatusID
,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID) as ItemId
,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as PACK_QUANTITY
,SUM(CAST(od.TaxValue AS DECIMAL(19,3))) as TaxValue
,SUM(CAST(od.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY od.OrderNumber
,od.StoreId
,o.SentDateUTC
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName
,od.ItemMeasureTypeName
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))
,od.CatalogItemID
,od.CatalogItemCode
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID)
,o.OrderStatus
,o.OrderStatusID
,o.OrderStatusUIName
,o.DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
) AS source_query;',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [retry_count], [timeout_minutes],
            [staging_columns], [created_at], [updated_at])
    VALUES (N'Order Items', N'MMAN_PRE_ORDEREVENT',
            N'IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

SELECT * INTO [stage].[MMAN_PRE_ORDEREVENT]
FROM (
SELECT  od.OrderNumber
,od.StoreId
,''ORDER'' as EVENT_TYPE
,o.SentDateUTC as EVENT_TS
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
,od.ItemMeasureTypeName as UOM
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
,od.CatalogItemID
,od.CatalogItemCode
,''info'' as EVENT_BEHAVIOUR
,TRY_CAST(o.OrderStatus AS INT) as OrderStatus
,o.OrderStatusID
,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID) as ItemId
,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as PACK_QUANTITY
,SUM(CAST(od.TaxValue AS DECIMAL(19,3))) as TaxValue
,SUM(CAST(od.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY od.OrderNumber
,od.StoreId
,o.SentDateUTC
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName
,od.ItemMeasureTypeName
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))
,od.CatalogItemID
,od.CatalogItemCode
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID)
,o.OrderStatus
,o.OrderStatusID
,o.OrderStatusUIName
,o.DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
) AS source_query;',
            1, N'Staging', 0, 3, 30,
            N'["OrderNumber", "StoreId", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "EVENT_BEHAVIOUR", "OrderStatus", "OrderStatusID", "OrderStatusUIName", "DeliveryDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
            GETDATE(), GETDATE());
GO

-- ============================================================================
-- SECTION 8 of 10: C2 — Product-recipe link split to separate staging table
-- Source: C2_product_recipe_split.sql
-- ============================================================================
-- =============================================================================
-- FIX C2: Split Product-Recipe Link into Separate Staging Table
-- =============================================================================
-- PROBLEM:
--   MMAN_PRODUCT staging uses LEFT OUTER JOIN to DL_MENU_ITEMS_SUBITEMS.
--   Products WITHOUT recipes get INVITEM_ID = '' (empty string from CONCAT_WS
--   of NULLs when REC.storeId and REC.ItemID are NULL). This empty-string
--   INVITEM_ID hashes to a value that doesn't exist in HUB_INVITEM, causing
--   100% orphan rate on INVITEM_HUB_ID in LNK_INVITEM_LOCATION_OCCASION_PRODUCT.
--   All 315 link rows are orphans.
--
-- FIX:
--   1. New StagingControl step 'Product Recipe' producing MMAN_PRODUCT_RECIPE
--      with INNER JOIN to DL_MENU_ITEMS_SUBITEMS -- only products that actually
--      have recipe ingredient mappings produce rows.
--   2. Update INVITEM_LOCATION_OCCASION_PRODUCT entity mapping to source from
--      MMAN_PRODUCT_RECIPE instead of MMAN_PRODUCT.
--
-- NOTE: LOCATION_OCCASION_PRODUCT stays on MMAN_PRODUCT because it needs
--   MenuItemPrice and RecipeIngredientsCost (pricing data) and does NOT
--   reference INVITEM_HUB_ID. The orphan issue only affects the INVITEM link.
--
-- EFFECT:
--   After deployment, MMAN_PRODUCT_RECIPE contains only rows where a recipe
--   ingredient mapping exists (INNER JOIN ensures INVITEM_ID is always valid).
--   LNK_INVITEM_LOCATION_OCCASION_PRODUCT will have 0% orphan rate on
--   INVITEM_HUB_ID (assuming the ingredient items exist in HUB_INVITEM via
--   the Inventory Items staging step).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. StagingControl: MMAN_PRODUCT_RECIPE (Tier 2, depends on Inventory Items)
-- -----------------------------------------------------------------------------
-- This is a Tier 2 step because it needs DL_MENU_ITEMS_SUBITEMS data AND should
-- run after the Inventory Items step (so INVITEM IDs are already staged).
--
-- Query is identical to MMAN_PRODUCT but with two key differences:
--   a) INNER JOIN to DL_MENU_ITEMS_SUBITEMS (not LEFT OUTER JOIN)
--   b) Only selects columns needed for the INVITEM link mapping:
--      PosCode, INVITEM_ID, OCC_ID, UOM, UOM_VALUE, storeId
-- -----------------------------------------------------------------------------

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Product Recipe')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table   = N'MMAN_PRODUCT_RECIPE',
        query_sql       = N'IF OBJECT_ID(''stage.MMAN_PRODUCT_RECIPE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT_RECIPE];

SELECT * INTO [stage].[MMAN_PRODUCT_RECIPE]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,MIP.[storeId]
    ,''-999'' AS OCC_ID
FROM [int_marketman001].[DL_MENU_ITEMS] MI
INNER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
    ON MIP.[ID] = MI.[ID]
    AND MIP.[storeId] = MI.[storeId]
INNER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
    ON MIP.[ID] = REC.[ID]
    AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;',
        tier            = 2,
        step_type       = N'Staging',
        exclude         = 0,
        description     = N'Product-to-ingredient recipe rows (INNER JOIN to subitems). Feeds INVITEM_LOCATION_OCCASION_PRODUCT link.',
        depends_on_steps = N'Inventory Items',
        retry_count     = 3,
        timeout_minutes = 30,
        staging_columns = N'["PosCode", "INVITEM_ID", "UOM", "UOM_VALUE", "storeId", "OCC_ID"]',
        updated_at      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (
        N'Product Recipe',
        N'MMAN_PRODUCT_RECIPE',
        N'IF OBJECT_ID(''stage.MMAN_PRODUCT_RECIPE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT_RECIPE];

SELECT * INTO [stage].[MMAN_PRODUCT_RECIPE]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,MIP.[storeId]
    ,''-999'' AS OCC_ID
FROM [int_marketman001].[DL_MENU_ITEMS] MI
INNER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
    ON MIP.[ID] = MI.[ID]
    AND MIP.[storeId] = MI.[storeId]
INNER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
    ON MIP.[ID] = REC.[ID]
    AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;',
        2,
        N'Staging',
        0,
        N'Product-to-ingredient recipe rows (INNER JOIN to subitems). Feeds INVITEM_LOCATION_OCCASION_PRODUCT link.',
        N'Inventory Items',
        3,
        30,
        N'["PosCode", "INVITEM_ID", "UOM", "UOM_VALUE", "storeId", "OCC_ID"]',
        GETDATE(),
        GETDATE()
    );
GO

-- -----------------------------------------------------------------------------
-- 2. EntityMappings: Update INVITEM_LOCATION_OCCASION_PRODUCT source table
-- -----------------------------------------------------------------------------
-- Changes source_table from MMAN_PRODUCT to MMAN_PRODUCT_RECIPE.
-- source_columns and entity_columns remain identical -- the new staging table
-- has the same column names, just filtered to rows with valid INVITEM_ID.
--
-- Uses entity_name + source_table as the MERGE key. Since the source_table is
-- changing, we cannot MERGE on the new value. Instead we match on entity_name
-- alone (there is only one mapping for this entity in MarketMan).
-- -----------------------------------------------------------------------------

MERGE INTO [core].[int_marketman001].[EntityMappings] AS tgt
USING (VALUES ('INVITEM_LOCATION_OCCASION_PRODUCT')) AS src (entity_name)
ON tgt.entity_name = src.entity_name
WHEN MATCHED THEN
    UPDATE SET
        source_table        = 'MMAN_PRODUCT_RECIPE',
        source_columns      = '[{"name": "PosCode", "hash": 1}, {"name": "INVITEM_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}, {"name": "storeId", "hash": 1}]',
        entity_columns      = '["PRODUCT_HUB_ID", "INVITEM_HUB_ID", "OCCASION_HUB_ID", "UOM", "UOM_VALUE", "LOCATION_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (
        'ABDBD083-8894-4AEE-992D-E6362B19DF0A',
        'INVITEM_LOCATION_OCCASION_PRODUCT',
        'MMAN_PRODUCT_RECIPE',
        '[{"name": "PosCode", "hash": 1}, {"name": "INVITEM_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}, {"name": "storeId", "hash": 1}]',
        '["PRODUCT_HUB_ID", "INVITEM_HUB_ID", "OCCASION_HUB_ID", "UOM", "UOM_VALUE", "LOCATION_HUB_ID"]',
        NULL,
        NULL,
        NULL,
        0,
        GETDATE(),
        GETDATE(),
        1
    );
GO

-- ============================================================================
-- SECTION 9 of 10: C9 — Cross-store buyer bleed in Report staging
-- Source: C9_cross_store_report_fix.sql
-- ============================================================================
/*
    FIX: C9 - Cross-Store Buyer Bleed in Report Staging
    ====================================================

    PROBLEM:
    The MarketMan actual_vs_theo API, when queried with a storeId, returns data
    for ALL buyers visible to that store, not just its own. For KUDU:
    - Store ed84ceb7... (KUDU-HQ) returns data for both "Kudu-Staff" AND "KUDU Collective"
    - Store 9dbec6a3... (KUDU Collective) returns only its own data

    The "Report" staging step reads ALL rows from DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS
    without filtering, so KUDU Collective's data appears twice in MMAN_REPORT:
    - Once under storeId 9dbec6a3... (correct)
    - Once under storeId ed84ceb7... (duplicate, wrong location)

    This flows through to HUB_INVREPORT (165K records, ~50% duplicates),
    F_INV_USAGE_DAY, and F_INV_SALES_DAY, inflating all inventory reporting.

    FIX:
    Add WHERE clause: storeId = BueyrGuid OR BueyrGuid IS NULL
    This ensures each store's report only contains its own buyer data.

    IMPACT:
    - MMAN_REPORT rows will drop from ~9,333 to ~6,222 (removes ~3,111 cross-store dupes)
    - MMAN_REPORT_STEP2 (reads from MMAN_REPORT) automatically fixed
    - DV load INVREPORT (reads from MMAN_REPORT_STEP2) automatically fixed
    - All downstream: LNK_INVREPORT_LOCATION, LNK_INVITEM_INVREPORT, F_INV_USAGE_DAY,
      F_INV_SALES_DAY automatically fixed

    NOTE: After deployment, existing duplicate INVREPORT records in the data vault
    will remain (DV is append-only). They will age out naturally as new data loads
    with correct figures, or can be cleaned up with a one-off delete of records
    linked to the wrong LOCATION_HUB_ID.

    TARGETS: StagingControl (Report step)
*/

MERGE INTO [int_marketman001].[StagingControl] AS tgt
USING (VALUES (
    N'Report',
    N'MMAN_REPORT',
    N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID]) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID]
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
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

GO

-- ============================================================================
-- SECTION 10 of 10: C10 — Cross-store buyer bleed in Inventory Items staging
-- Source: C10_cross_store_invitems_fix.sql
-- ============================================================================
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
