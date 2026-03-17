/*
================================================================================
  Growyze Integration — Tier 2 & Tier 3 Staging Steps
  File:    03_staging_tier2_3.sql
  Date:    2026-03-05
  Fixed:   2026-03-05 — Moved CTEs outside derived tables (SQL Server error 156)
  Fixed:   2026-03-06 — GRYZ_SALES: yieldSize→yield_size, yieldMeasure→yield_measure (DL_RECIPES column name mismatch)
  Fixed:   2026-03-06 — GRYZ_STOCKEVENT: Tier 2→3 (depends on [stage].[GRYZ_SALES] which is also Tier 2)
  Fixed:   2026-03-06 — GRYZ_STOCKEVENT: CAST PACK_QUANTITY/UOM_QUANTITY to NVARCHAR in GRYZ_SALES branch
  Fixed:   2026-03-06 — GRYZ_SALES + GRYZ_WASTE_EVENTS: NULL AS PACK_DESC typed as int, 1 AS PACK_QUANTITY
                         typed as int — UNION ALL with DN_EVENTS nvarchar PACK_DESC ('7.0 Other') fails error 245.
                         Fix: CAST NULL/literals to NVARCHAR(MAX) at source, remove STOCKEVENT branch CASTs.
  Purpose: Creates StagingControl records for Growyze Tier 2 (sales depletion,
           stock event consolidation) and Tier 3 (product-invitem link staging).
           Uses MERGE upsert pattern for idempotent re-runs.

  Steps:
    12. Growyze Sales          (Tier 2) — Recipe explosion for sales depletion
    13. Growyze Stock Event    (Tier 3) — Consolidate delivery + waste + sales
    14. Growyze Product InvItem (Tier 3) — 4-way link staging (dish -> ingredient)

  Target: [core].[int_growyze001].[StagingControl]
  Depends: 01_infrastructure.sql (UOM_CONVERSION table), 02_staging_tier1.sql
================================================================================
*/

-- ============================================================================
-- Step 12: Growyze Sales (Tier 2)
-- Calculate INVITEM depletion from sales via recipe explosion with UOM conversion
-- ============================================================================

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Sales')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_SALES',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_SALES'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_SALES]; WITH direct_dishes AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), direct_dedup AS ( SELECT * FROM direct_dishes WHERE rn = 1 ), recipe_dishes AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''RECIPE'' ), recipe_dishes_dedup AS ( SELECT * FROM recipe_dishes WHERE rn = 1 ), recipe_ingredients AS ( SELECT DISTINCT id, sections_elements_ingredient_product_id, sections_elements_ingredient_measure, sections_elements_ingredient_usedQty, sections_elements_type, yield_size, yield_measure, portionCount FROM [int_growyze001].[DL_RECIPES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), part_a AS ( SELECT CONCAT_WS(''-'', d.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY, ''SALE'' AS EVENT_TYPE, ''-'' AS EVENT_BEHANIOUR, sd.[from] AS EVENT_TS, CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC, CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY, d.sections_elements_ingredient_measure AS UOM, CAST(sd.items_soldQty AS DECIMAL(18,6)) * CAST(d.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) AS UOM_QUANTITY, d.name AS EXTERNAL_REF, sd.id AS INTERNAL_REF, d.sections_elements_ingredient_product_id AS itemId, sd.organizations AS storeID FROM [int_growyze001].[DL_SALESDETAIL] sd JOIN direct_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0 ), part_b AS ( SELECT CONCAT_WS(''-'', r.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY, ''SALE'' AS EVENT_TYPE, ''-'' AS EVENT_BEHANIOUR, sd.[from] AS EVENT_TS, CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC, CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY, r.sections_elements_ingredient_measure AS UOM, CASE WHEN d.sections_elements_recipe_measure = ''portion'' THEN CAST(sd.items_soldQty AS DECIMAL(18,6)) * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) / NULLIF(CAST(r.portionCount AS DECIMAL(18,6)), 0)) * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) ELSE CAST(sd.items_soldQty AS DECIMAL(18,6)) * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) * COALESCE(uom_dish.CONVERSION_FACTOR, 1) / NULLIF(CAST(r.yield_size AS DECIMAL(18,6)) * COALESCE(uom_yield.CONVERSION_FACTOR, 1), 0)) * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) END AS UOM_QUANTITY, d.name AS EXTERNAL_REF, sd.id AS INTERNAL_REF, r.sections_elements_ingredient_product_id AS itemId, sd.organizations AS storeID FROM [int_growyze001].[DL_SALESDETAIL] sd JOIN recipe_dishes_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations JOIN recipe_ingredients r ON d.sections_elements_recipe_recipe_id = r.id LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_dish ON d.sections_elements_recipe_measure = uom_dish.FROM_UOM LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_yield ON r.yield_measure = uom_yield.FROM_UOM AND uom_yield.UOM_CATEGORY = uom_dish.UOM_CATEGORY WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0 ) SELECT * INTO [stage].[GRYZ_SALES] FROM ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM part_a UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM part_b ) AS source_query;',
        tier             = 2,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Calculate INVITEM depletion from sales via recipe explosion with UOM conversion',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Sales', N'GRYZ_SALES',
            N'IF OBJECT_ID(''stage.GRYZ_SALES'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_SALES]; WITH direct_dishes AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), direct_dedup AS ( SELECT * FROM direct_dishes WHERE rn = 1 ), recipe_dishes AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''RECIPE'' ), recipe_dishes_dedup AS ( SELECT * FROM recipe_dishes WHERE rn = 1 ), recipe_ingredients AS ( SELECT DISTINCT id, sections_elements_ingredient_product_id, sections_elements_ingredient_measure, sections_elements_ingredient_usedQty, sections_elements_type, yield_size, yield_measure, portionCount FROM [int_growyze001].[DL_RECIPES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), part_a AS ( SELECT CONCAT_WS(''-'', d.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY, ''SALE'' AS EVENT_TYPE, ''-'' AS EVENT_BEHANIOUR, sd.[from] AS EVENT_TS, CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC, CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY, d.sections_elements_ingredient_measure AS UOM, CAST(sd.items_soldQty AS DECIMAL(18,6)) * CAST(d.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) AS UOM_QUANTITY, d.name AS EXTERNAL_REF, sd.id AS INTERNAL_REF, d.sections_elements_ingredient_product_id AS itemId, sd.organizations AS storeID FROM [int_growyze001].[DL_SALESDETAIL] sd JOIN direct_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0 ), part_b AS ( SELECT CONCAT_WS(''-'', r.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY, ''SALE'' AS EVENT_TYPE, ''-'' AS EVENT_BEHANIOUR, sd.[from] AS EVENT_TS, CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC, CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY, r.sections_elements_ingredient_measure AS UOM, CASE WHEN d.sections_elements_recipe_measure = ''portion'' THEN CAST(sd.items_soldQty AS DECIMAL(18,6)) * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) / NULLIF(CAST(r.portionCount AS DECIMAL(18,6)), 0)) * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) ELSE CAST(sd.items_soldQty AS DECIMAL(18,6)) * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) * COALESCE(uom_dish.CONVERSION_FACTOR, 1) / NULLIF(CAST(r.yield_size AS DECIMAL(18,6)) * COALESCE(uom_yield.CONVERSION_FACTOR, 1), 0)) * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) END AS UOM_QUANTITY, d.name AS EXTERNAL_REF, sd.id AS INTERNAL_REF, r.sections_elements_ingredient_product_id AS itemId, sd.organizations AS storeID FROM [int_growyze001].[DL_SALESDETAIL] sd JOIN recipe_dishes_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations JOIN recipe_ingredients r ON d.sections_elements_recipe_recipe_id = r.id LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_dish ON d.sections_elements_recipe_measure = uom_dish.FROM_UOM LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_yield ON r.yield_measure = uom_yield.FROM_UOM AND uom_yield.UOM_CATEGORY = uom_dish.UOM_CATEGORY WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0 ) SELECT * INTO [stage].[GRYZ_SALES] FROM ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM part_a UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM part_b ) AS source_query;',
            2, N'Staging', 0,
            N'Calculate INVITEM depletion from sales via recipe explosion with UOM conversion',
            NULL, 3, 30,
            N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
            GETDATE(), GETDATE());
GO

-- ============================================================================
-- Step 13: Growyze Stock Event (Tier 3)
-- Consolidates delivery, waste, and sales depletion events into unified
-- STOCKEVENT staging (Tier 3 because it depends on [stage].[GRYZ_SALES] from Tier 2)
-- ============================================================================

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Stock Event')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_STOCKEVENT',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_STOCKEVENT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_STOCKEVENT]; WITH combined AS ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_DN_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_WASTE_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, CAST(UOM_QUANTITY AS NVARCHAR(MAX)) AS UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_SALES] ), deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR ORDER BY EVENT_TS DESC) AS rn FROM combined ) SELECT * INTO [stage].[GRYZ_STOCKEVENT] FROM ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM deduped WHERE rn = 1 ) AS source_query;',
        tier             = 3,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Consolidates delivery, waste, and sales depletion events into unified STOCKEVENT staging (depends on GRYZ_SALES)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Stock Event', N'GRYZ_STOCKEVENT',
            N'IF OBJECT_ID(''stage.GRYZ_STOCKEVENT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_STOCKEVENT]; WITH combined AS ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_DN_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_WASTE_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, CAST(UOM_QUANTITY AS NVARCHAR(MAX)) AS UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_SALES] ), deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR ORDER BY EVENT_TS DESC) AS rn FROM combined ) SELECT * INTO [stage].[GRYZ_STOCKEVENT] FROM ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID FROM deduped WHERE rn = 1 ) AS source_query;',
            3, N'Staging', 0,
            N'Consolidates delivery, waste, and sales depletion events into unified STOCKEVENT staging',
            NULL, 3, 30,
            N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
            GETDATE(), GETDATE());
GO

-- ============================================================================
-- Step 14: Growyze Product InvItem (Tier 3)
-- Build 4-way INVITEM_LOCATION_OCCASION_PRODUCT link connecting POS menu items
-- to inventory ingredients
-- ============================================================================

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Product InvItem')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_PRODUCT_INVITEM',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_PRODUCT_INVITEM'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_PRODUCT_INVITEM]; WITH dish_ingredient AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), dish_ingredient_dedup AS ( SELECT * FROM dish_ingredient WHERE rn = 1 ), dish_recipe AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''RECIPE'' ), dish_recipe_dedup AS ( SELECT * FROM dish_recipe WHERE rn = 1 ), recipe_ingredient AS ( SELECT DISTINCT id, sections_elements_ingredient_product_id, sections_elements_ingredient_measure, sections_elements_ingredient_usedQty FROM [int_growyze001].[DL_RECIPES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), path_a AS ( SELECT d.id AS PRODUCT_KEY, d.sections_elements_ingredient_product_id AS INVITEM_KEY, d.organizations AS LOCATION_KEY, ''-999'' AS OCCASION_KEY, d.sections_elements_ingredient_measure AS UOM, d.sections_elements_ingredient_usedQty AS UOM_VALUE FROM dish_ingredient_dedup d ), path_b AS ( SELECT d.id AS PRODUCT_KEY, r.sections_elements_ingredient_product_id AS INVITEM_KEY, d.organizations AS LOCATION_KEY, ''-999'' AS OCCASION_KEY, r.sections_elements_ingredient_measure AS UOM, r.sections_elements_ingredient_usedQty AS UOM_VALUE FROM dish_recipe_dedup d JOIN recipe_ingredient r ON d.sections_elements_recipe_recipe_id = r.id ), combined AS ( SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE FROM path_a UNION ALL SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE FROM path_b ) SELECT * INTO [stage].[GRYZ_PRODUCT_INVITEM] FROM ( SELECT DISTINCT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE FROM combined ) AS source_query;',
        tier             = 3,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Build 4-way INVITEM_LOCATION_OCCASION_PRODUCT link connecting POS menu items to inventory ingredients',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["PRODUCT_KEY", "INVITEM_KEY", "LOCATION_KEY", "OCCASION_KEY", "UOM", "UOM_VALUE"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Product InvItem', N'GRYZ_PRODUCT_INVITEM',
            N'IF OBJECT_ID(''stage.GRYZ_PRODUCT_INVITEM'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_PRODUCT_INVITEM]; WITH dish_ingredient AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), dish_ingredient_dedup AS ( SELECT * FROM dish_ingredient WHERE rn = 1 ), dish_recipe AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE sections_elements_type = ''RECIPE'' ), dish_recipe_dedup AS ( SELECT * FROM dish_recipe WHERE rn = 1 ), recipe_ingredient AS ( SELECT DISTINCT id, sections_elements_ingredient_product_id, sections_elements_ingredient_measure, sections_elements_ingredient_usedQty FROM [int_growyze001].[DL_RECIPES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ), path_a AS ( SELECT d.id AS PRODUCT_KEY, d.sections_elements_ingredient_product_id AS INVITEM_KEY, d.organizations AS LOCATION_KEY, ''-999'' AS OCCASION_KEY, d.sections_elements_ingredient_measure AS UOM, d.sections_elements_ingredient_usedQty AS UOM_VALUE FROM dish_ingredient_dedup d ), path_b AS ( SELECT d.id AS PRODUCT_KEY, r.sections_elements_ingredient_product_id AS INVITEM_KEY, d.organizations AS LOCATION_KEY, ''-999'' AS OCCASION_KEY, r.sections_elements_ingredient_measure AS UOM, r.sections_elements_ingredient_usedQty AS UOM_VALUE FROM dish_recipe_dedup d JOIN recipe_ingredient r ON d.sections_elements_recipe_recipe_id = r.id ), combined AS ( SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE FROM path_a UNION ALL SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE FROM path_b ) SELECT * INTO [stage].[GRYZ_PRODUCT_INVITEM] FROM ( SELECT DISTINCT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE FROM combined ) AS source_query;',
            3, N'Staging', 0,
            N'Build 4-way INVITEM_LOCATION_OCCASION_PRODUCT link connecting POS menu items to inventory ingredients',
            NULL, 3, 30,
            N'["PRODUCT_KEY", "INVITEM_KEY", "LOCATION_KEY", "OCCASION_KEY", "UOM", "UOM_VALUE"]',
            GETDATE(), GETDATE());
GO
