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
