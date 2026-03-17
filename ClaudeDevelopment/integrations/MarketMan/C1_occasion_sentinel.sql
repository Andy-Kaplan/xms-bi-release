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
