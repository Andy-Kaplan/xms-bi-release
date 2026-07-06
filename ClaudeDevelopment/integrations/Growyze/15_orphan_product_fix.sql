-- =============================================================================
-- Script: 15_orphan_product_fix.sql
-- Created: 2026-05-18
-- Purpose: Fix the Growyze orphan PRODUCT_HUB_ID leak that drops sales from
--          product-breakdown dashboards.
--
-- Background
-- ----------
-- The Growyze GRYZ_LINEITEM staging step LEFT-joins DL_DISHES on
-- (items_posId, organizations). When DL_SALESDETAIL.items_posId does not match
-- any dish, d.id is NULL. That NULL flows into stage.GRYZ_LINEITEM.PRODUCT_KEY,
-- the DV load hashes NULL into a deterministic SHA256 value, and a
-- LNK_LINEITEM_PRODUCT row is created with a PRODUCT_HUB_ID that has no
-- matching HUB_PRODUCT row -- an "orphan" hub key.
--
-- Confirmed on Dirty Sixth UAT 2026-05-18:
--   * 149 stage.GRYZ_LINEITEM rows have PRODUCT_KEY = NULL
--   * Single orphan PRODUCT_HUB_ID accounts for £1,454.84 NET_VALUE on
--     2026-05-09 (~8.4% of the day's £17,405.50 net).
--   * F_LINEITEM_15MIN totals are correct (LEFT JOIN preserves the line)
--     but any product-breakdown card that GROUPs or filters by product name
--     drops the orphan slice because D_PRODUCT cannot resolve the key.
--
-- Two-layer fix
-- -------------
-- Section 1 (Growyze-only, root cause):
--   Stop emitting LNK_LINEITEM_PRODUCT rows when PRODUCT_KEY is NULL.
--   Implemented by splitting the link source into a dedicated tier-2 stage
--   table (stage.GRYZ_LINEITEM_PRODUCT) filtered to non-null keys, and
--   re-pointing the LINEITEM_PRODUCT entity mapping at it.
--   Result: unmatched lines stay in SAT_LINEITEM (so totals remain), but
--   create no link row -- F_LINEITEM_15MIN's existing ISNULL(..., -999)
--   fallback then routes the line to the platform-standard "Unknown"
--   sentinel in D_PRODUCT.
--
-- Section 2 (platform-wide, defensive):
--   Hardens the F_LINEITEM_15MIN PresentationControl build so the join to
--   LNK_LINEITEM_PRODUCT validates the referenced PRODUCT_HUB_ID against
--   HUB_PRODUCT. Any future orphan class (Growyze, MarketMan, NCRAloha, or
--   a new integration) is caught at presentation rebuild and routed to -999
--   instead of silently dropping from product-breakdown charts.
--
-- Idempotent: both sections use MERGE / pattern-guarded UPDATE -- safe to re-run.
-- =============================================================================


-- =============================================================================
-- SECTION 1: STAGING-LAYER FIX (Growyze-only)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1a. New tier-2 staging step: Growyze LineItem Product Link
--     Builds stage.GRYZ_LINEITEM_PRODUCT containing only rows where the dish
--     join resolved (PRODUCT_KEY IS NOT NULL).
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
-- 1b. Re-point LINEITEM_PRODUCT entity mapping at the filtered staging table.
--     Original entity mapping (file 04 #13) sourced from GRYZ_LINEITEM.
--     The table's composite key is (entity_name, source_table) -- to keep a
--     single row for this entity, we remove the old (GRYZ_LINEITEM) row and
--     upsert the new (GRYZ_LINEITEM_PRODUCT) row.
--
--     NOTE: file 04 (04_entity_mappings.sql #13) should be amended in the
--     same release so a re-run does not resurrect the old mapping.
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


-- =============================================================================
-- SECTION 2: PRESENTATION-LAYER FIX (platform-wide, defensive)
-- =============================================================================
-- Wraps the LNK_LINEITEM_PRODUCT join inside F_LINEITEM_15MIN with an INNER
-- JOIN to HUB_PRODUCT so any link row pointing at a non-existent hub is
-- discarded. The outer LEFT JOIN preserves the SAT_LINEITEM row, and the
-- existing ISNULL(PROD.[PRODUCT_HUB_ID], CONVERT(BINARY(32), -999)) fallback
-- routes it to the D_PRODUCT "Unknown" sentinel.
--
-- Guard: only applies the patch if the original (unpatched) join text is
-- present. Re-runs are no-ops.
-- =============================================================================
DECLARE @old_join NVARCHAR(MAX) = N'LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_PRODUCT] PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]';

DECLARE @new_join NVARCHAR(MAX) = N'LEFT OUTER JOIN
    (SELECT L.[LINEITEM_HUB_ID], L.[PRODUCT_HUB_ID]
     FROM [datavault].[LNK_LINEITEM_PRODUCT] L
     INNER JOIN [datavault].[HUB_PRODUCT] HP ON L.[PRODUCT_HUB_ID] = HP.[HUB_ID]) PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]';

IF EXISTS (
    SELECT 1
    FROM [core].[PresentationControl]
    WHERE id = N'131C3A84-F72D-4A12-B958-BFB519973BE0'
      AND CHARINDEX(@old_join, CAST(query_sql AS NVARCHAR(MAX))) > 0
)
BEGIN
    UPDATE [core].[PresentationControl]
    SET query_sql  = REPLACE(CAST(query_sql AS NVARCHAR(MAX)), @old_join, @new_join),
        updated_at = GETDATE()
    WHERE id = N'131C3A84-F72D-4A12-B958-BFB519973BE0';

    PRINT N'F_LINEITEM_15MIN PresentationControl patched: LNK_LINEITEM_PRODUCT join now hub-validated.';
END
ELSE
BEGIN
    PRINT N'F_LINEITEM_15MIN PresentationControl already patched or original pattern not found -- no change.';
END
GO


-- =============================================================================
-- VERIFICATION QUERIES (run manually after deploy)
-- =============================================================================
-- 1. Confirm new staging step is registered (target org):
--      SELECT step_name, staging_table, tier, query_sql
--      FROM [core].[int_growyze001].[StagingControl]
--      WHERE step_name = N'Growyze LineItem Product Link';
--
-- 2. Confirm entity mapping repointed:
--      SELECT entity_name, source_table FROM [core].[int_growyze001].[EntityMappings]
--      WHERE entity_name = N'LINEITEM_PRODUCT';   -- expect: GRYZ_LINEITEM_PRODUCT
--
-- 3. Confirm presentation patch applied:
--      SELECT CHARINDEX(N'INNER JOIN [datavault].[HUB_PRODUCT] HP', CAST(query_sql AS NVARCHAR(MAX)))
--      FROM [core].[PresentationControl]
--      WHERE id = N'131C3A84-F72D-4A12-B958-BFB519973BE0';     -- expect: > 0
--
-- 4. After next staging + DV + presentation rebuild on Dirty Sixth UAT
--    (20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A):
--      -- orphan should be gone from LNK_LINEITEM_PRODUCT:
--      SELECT COUNT(*) FROM [datavault].[LNK_LINEITEM_PRODUCT] L
--      LEFT JOIN [datavault].[HUB_PRODUCT] H ON L.PRODUCT_HUB_ID = H.HUB_ID
--      WHERE H.HUB_ID IS NULL;     -- expect: 0
--
--      -- orphan slice should now resolve to "Unknown" in F_LINEITEM_15MIN:
--      SELECT P.BOTTOM_PRODUCT_NAME, SUM(F.NET_VALUE) AS net
--      FROM [presentation].[F_LINEITEM_15MIN] F
--      LEFT JOIN [presentation].[D_PRODUCT] P ON F.PRODUCT_HUB_ID = P.BOTTOM_HUB_ID
--      WHERE F.ORDER_DATE = '2026-05-09'
--      GROUP BY P.BOTTOM_PRODUCT_NAME
--      ORDER BY net DESC;          -- expect: an "Unknown" row replaces the silent drop
-- =============================================================================
