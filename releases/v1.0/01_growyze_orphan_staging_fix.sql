-- =============================================================================
-- Release v1.0 / Script 01
-- File:    01_growyze_orphan_staging_fix.sql
-- Target:  Managed Instance, core database
-- Scope:   Core-only (modifies core.int_growyze001.StagingControl + EntityMappings)
-- Purpose: Stop the Growyze pipeline from emitting LNK_LINEITEM_PRODUCT rows
--          with NULL PRODUCT_KEY (root cause of orphan PRODUCT_HUB_ID).
--
-- Background
-- ----------
-- GRYZ_LINEITEM staging LEFT-joins DL_DISHES on (items_posId, organizations).
-- When the dish does not resolve, d.id is NULL, and the DV load hashes NULL
-- into a deterministic SHA256 value -- creating a LNK_LINEITEM_PRODUCT row
-- whose PRODUCT_HUB_ID has no matching HUB_PRODUCT entry. Any product-
-- breakdown card silently drops the slice. Confirmed on Dirty Sixth UAT
-- 2026-05-18: ~£1,454.84 NET (~8.4% of day's total).
--
-- Fix
-- ---
-- 1. Add a tier-2 staging step (`Growyze LineItem Product Link`) that
--    materialises stage.GRYZ_LINEITEM_PRODUCT from stage.GRYZ_LINEITEM,
--    keeping only rows with PRODUCT_KEY IS NOT NULL.
-- 2. Re-point the LINEITEM_PRODUCT entity mapping at the filtered table.
--    SAT_LINEITEM still receives every line; LNK_LINEITEM_PRODUCT only gets
--    rows with a resolved product. Unmatched lines fall through to the
--    existing F_LINEITEM_15MIN `ISNULL(..., -999)` fallback -> D_PRODUCT
--    "Unknown" sentinel.
--
-- Idempotency: MERGE on StagingControl; DELETE-then-MERGE on EntityMappings
-- (composite key (entity_name, source_table) -- old row must be removed).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Section A: New tier-2 staging step
-- -----------------------------------------------------------------------------
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze LineItem Product Link')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_LINEITEM_PRODUCT',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_LINEITEM_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LINEITEM_PRODUCT]; SELECT SRC_KEY, PRODUCT_KEY INTO [stage].[GRYZ_LINEITEM_PRODUCT] FROM [stage].[GRYZ_LINEITEM] WHERE PRODUCT_KEY IS NOT NULL;',
        tier             = 2,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Filters GRYZ_LINEITEM to rows with a resolved dish (PRODUCT_KEY IS NOT NULL) before feeding LNK_LINEITEM_PRODUCT. Prevents orphan PRODUCT_HUB_ID generation.',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "PRODUCT_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze LineItem Product Link', N'GRYZ_LINEITEM_PRODUCT',
            N'IF OBJECT_ID(''stage.GRYZ_LINEITEM_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LINEITEM_PRODUCT]; SELECT SRC_KEY, PRODUCT_KEY INTO [stage].[GRYZ_LINEITEM_PRODUCT] FROM [stage].[GRYZ_LINEITEM] WHERE PRODUCT_KEY IS NOT NULL;',
            2, N'Staging', 0,
            N'Filters GRYZ_LINEITEM to rows with a resolved dish (PRODUCT_KEY IS NOT NULL) before feeding LNK_LINEITEM_PRODUCT. Prevents orphan PRODUCT_HUB_ID generation.',
            NULL, 3, 30,
            N'["SRC_KEY", "PRODUCT_KEY"]',
            GETDATE(), GETDATE());
GO


-- -----------------------------------------------------------------------------
-- Section B: Re-point LINEITEM_PRODUCT entity mapping
--   The natural key in EntityMappings is (entity_name, source_table).
--   Remove the old (LINEITEM_PRODUCT, GRYZ_LINEITEM) row, then upsert the new
--   (LINEITEM_PRODUCT, GRYZ_LINEITEM_PRODUCT) row.
-- -----------------------------------------------------------------------------
DELETE FROM [core].[int_growyze001].[EntityMappings]
WHERE entity_name  = N'LINEITEM_PRODUCT'
  AND source_table = N'GRYZ_LINEITEM';
GO

MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM_PRODUCT', N'GRYZ_LINEITEM_PRODUCT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]',
        entity_columns      = N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LINEITEM_PRODUCT', N'GRYZ_LINEITEM_PRODUCT',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO


-- -----------------------------------------------------------------------------
-- Verification (run manually post-deploy)
-- -----------------------------------------------------------------------------
-- SELECT step_name, staging_table, tier FROM [core].[int_growyze001].[StagingControl]
-- WHERE step_name = N'Growyze LineItem Product Link';
--
-- SELECT entity_name, source_table FROM [core].[int_growyze001].[EntityMappings]
-- WHERE entity_name = N'LINEITEM_PRODUCT';   -- expect exactly one row, source_table = GRYZ_LINEITEM_PRODUCT
-- =============================================================================
