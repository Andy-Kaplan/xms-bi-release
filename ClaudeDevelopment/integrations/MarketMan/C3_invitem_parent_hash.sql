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
