-- =============================================================================
-- Script 02: Add UOM_COST to Growyze GRYZ_INVITEMS staging + INVITEM mapping
-- =============================================================================
-- Purpose : Extends the GRYZ_INVITEMS staging step and INVITEM entity mapping
--           to carry UOM_COST (the per-unit price as DECIMAL(38,10)) so that
--           the cost-path redesign can read it from the Data Vault layer.
--
-- Part 1  : Updates StagingControl — adds TRY_CAST(price ...) AS UOM_COST to
--           branch 1 (leaf items) and CAST(NULL ...) AS UOM_COST to branches
--           2 and 3 (sub-categories, categories).  Appends "UOM_COST" to
--           staging_columns JSON.
--
-- Part 2  : Updates EntityMappings — appends UOM_COST to source_columns and
--           entity_columns for INVITEM / GRYZ_INVITEMS.
--
-- Target  : core database  →  [core].[int_growyze001]  schema
-- Safe    : MERGE upserts — idempotent, re-runnable
-- =============================================================================


-- =============================================================================
-- PART 1: Update GRYZ_INVITEMS staging step
-- =============================================================================

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Inventory Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_INVITEMS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "UOM_COST", "INVITEM_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Inventory Items', N'GRYZ_INVITEMS',
            N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;',
            1, N'Staging', 0,
            N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category)',
            NULL, 3, 30,
            N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "UOM_COST", "INVITEM_ID"]',
            GETDATE(), GETDATE());
GO


-- =============================================================================
-- PART 2: Update INVITEM entity mapping
-- =============================================================================

MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM', N'GRYZ_INVITEMS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "INVITEM_ID", "UOM_COST"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0001-4A00-B001-AE0FDE100001', N'INVITEM', N'GRYZ_INVITEMS',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
            N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "INVITEM_ID", "UOM_COST"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO
