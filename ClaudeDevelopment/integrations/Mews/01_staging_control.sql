/* ============================================================================
   Mews Integration - Dimension Staging Steps (1-8)
   Target: [core].[int_mews001].[StagingControl]

   8 Tier 1 dimension staging steps for the Mews001 integration: Location,
   Product (3-tier: type/product/variant+synthetic default), Modifier,
   Tax, Tender, Discount, Channel, Revenue Center.
   All steps use MERGE upsert pattern for idempotent re-runs.

   Spec: .superpowers/sdd/task-1-brief.md (+ plan-preamble.md for shared
   constraints and MERGE template)
   Created: 2026-07-03
   ============================================================================ */

-- Step 1: Mews Location
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Location')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_LOCATION',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_LOCATION'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LOCATION]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_OUTLETS] ) SELECT * INTO [stage].[MEWS_LOCATION] FROM ( SELECT id AS HUB_ID, name AS LOCATION_NAME, id AS LOCATION_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews outlets as single-level location dimension',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Location', N'MEWS_LOCATION',
            N'IF OBJECT_ID(''stage.MEWS_LOCATION'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LOCATION]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_OUTLETS] ) SELECT * INTO [stage].[MEWS_LOCATION] FROM ( SELECT id AS HUB_ID, name AS LOCATION_NAME, id AS LOCATION_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews outlets as single-level location dimension',
            NULL, 3, 30,
            N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 2: Mews Product
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Product')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_PRODUCT',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_PRODUCT]; WITH prod AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PRODUCTS] ), var AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PRODUCT_VARIANTS] ), typ AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PRODUCT_TYPES] ) SELECT * INTO [stage].[MEWS_PRODUCT] FROM ( SELECT t.id AS HUB_ID, t.name AS PRODUCT_NAME, NULL AS PARENT_ID, ''TOP'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, t.id AS PRODUCT_ID, NULL AS ATTR_1, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM typ t WHERE t.rn = 1 UNION ALL SELECT p.id, p.name, p.productTypeId, ''MIDDLE_1'', 0, p.id, p.sku, NULL, NULL FROM prod p WHERE p.rn = 1 AND (p.status <> ''inactive'' OR p.status IS NULL) UNION ALL SELECT CONCAT(p.id, ''-DEFAULT''), p.name, p.id, ''BOTTOM'', 1, CONCAT(p.id, ''-DEFAULT''), p.sku, NULL, NULL FROM prod p WHERE p.rn = 1 AND (p.status <> ''inactive'' OR p.status IS NULL) UNION ALL SELECT v.id, COALESCE(NULLIF(v.selector, ''''), NULLIF(v.sku, ''''), CONCAT(p.name, '' @ '', v.retailPriceInclTax)), v.productId, ''BOTTOM'', 1, v.id, v.sku, NULL, NULL FROM var v INNER JOIN prod p ON p.id = v.productId AND p.rn = 1 WHERE v.rn = 1 AND (p.status <> ''inactive'' OR p.status IS NULL) ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages 3-tier product hierarchy: types=TOP, products=MIDDLE_1, variants + synthetic {productId}-DEFAULT rows=BOTTOM. Line items key on COALESCE(variantId, productId-DEFAULT).',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Product', N'MEWS_PRODUCT',
            N'IF OBJECT_ID(''stage.MEWS_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_PRODUCT]; WITH prod AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PRODUCTS] ), var AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PRODUCT_VARIANTS] ), typ AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PRODUCT_TYPES] ) SELECT * INTO [stage].[MEWS_PRODUCT] FROM ( SELECT t.id AS HUB_ID, t.name AS PRODUCT_NAME, NULL AS PARENT_ID, ''TOP'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, t.id AS PRODUCT_ID, NULL AS ATTR_1, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM typ t WHERE t.rn = 1 UNION ALL SELECT p.id, p.name, p.productTypeId, ''MIDDLE_1'', 0, p.id, p.sku, NULL, NULL FROM prod p WHERE p.rn = 1 AND (p.status <> ''inactive'' OR p.status IS NULL) UNION ALL SELECT CONCAT(p.id, ''-DEFAULT''), p.name, p.id, ''BOTTOM'', 1, CONCAT(p.id, ''-DEFAULT''), p.sku, NULL, NULL FROM prod p WHERE p.rn = 1 AND (p.status <> ''inactive'' OR p.status IS NULL) UNION ALL SELECT v.id, COALESCE(NULLIF(v.selector, ''''), NULLIF(v.sku, ''''), CONCAT(p.name, '' @ '', v.retailPriceInclTax)), v.productId, ''BOTTOM'', 1, v.id, v.sku, NULL, NULL FROM var v INNER JOIN prod p ON p.id = v.productId AND p.rn = 1 WHERE v.rn = 1 AND (p.status <> ''inactive'' OR p.status IS NULL) ) AS source_query;',
            1, N'Staging', 0,
            N'Stages 3-tier product hierarchy: types=TOP, products=MIDDLE_1, variants + synthetic {productId}-DEFAULT rows=BOTTOM. Line items key on COALESCE(variantId, productId-DEFAULT).',
            NULL, 3, 30,
            N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 3: Mews Modifier
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Modifier')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_MOD',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_MOD'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_MOD]; WITH sets AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_MODIFIER_SETS] ), mods AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_MODIFIERS] ) SELECT * INTO [stage].[MEWS_MOD] FROM ( SELECT s.id AS HUB_ID, s.name AS MOD_NAME, NULL AS PARENT_ID, ''TOP'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, s.id AS MOD_ID, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM sets s WHERE s.rn = 1 UNION ALL SELECT m.id, m.name, m.modifierSetId, ''BOTTOM'', 1, m.id, NULL, NULL FROM mods m WHERE m.rn = 1 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages 2-level modifier hierarchy (sets=TOP, modifiers=BOTTOM); empty until modifier data lands',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Modifier', N'MEWS_MOD',
            N'IF OBJECT_ID(''stage.MEWS_MOD'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_MOD]; WITH sets AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_MODIFIER_SETS] ), mods AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_MODIFIERS] ) SELECT * INTO [stage].[MEWS_MOD] FROM ( SELECT s.id AS HUB_ID, s.name AS MOD_NAME, NULL AS PARENT_ID, ''TOP'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, s.id AS MOD_ID, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM sets s WHERE s.rn = 1 UNION ALL SELECT m.id, m.name, m.modifierSetId, ''BOTTOM'', 1, m.id, NULL, NULL FROM mods m WHERE m.rn = 1 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages 2-level modifier hierarchy (sets=TOP, modifiers=BOTTOM); empty until modifier data lands',
            NULL, 3, 30,
            N'["HUB_ID", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 4: Mews Tax
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Tax')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_TAX',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_TAX'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_TAX]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_TAXES] ) SELECT * INTO [stage].[MEWS_TAX] FROM ( SELECT id AS HUB_ID, name AS TAX_NAME, id AS TAX_ID, CAST(rate AS DECIMAL(18,6)) AS TAX_MULTIPLIER, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews tax profiles; rate column is already a decimal multiplier',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "TAX_NAME", "TAX_ID", "TAX_MULTIPLIER", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Tax', N'MEWS_TAX',
            N'IF OBJECT_ID(''stage.MEWS_TAX'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_TAX]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_TAXES] ) SELECT * INTO [stage].[MEWS_TAX] FROM ( SELECT id AS HUB_ID, name AS TAX_NAME, id AS TAX_ID, CAST(rate AS DECIMAL(18,6)) AS TAX_MULTIPLIER, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews tax profiles; rate column is already a decimal multiplier',
            NULL, 3, 30,
            N'["HUB_ID", "TAX_NAME", "TAX_ID", "TAX_MULTIPLIER", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 5: Mews Tender
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Tender')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_TENDER',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_TENDER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_TENDER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PAYMENT_METHODS] ) SELECT * INTO [stage].[MEWS_TENDER] FROM ( SELECT id AS HUB_ID, name AS TENDER_NAME, id AS TENDER_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(active, ''1'') <> ''0'' ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews payment methods as tender dimension (no tender line items yet - DL_ORDER_PAYMENTS not landed)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Tender', N'MEWS_TENDER',
            N'IF OBJECT_ID(''stage.MEWS_TENDER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_TENDER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PAYMENT_METHODS] ) SELECT * INTO [stage].[MEWS_TENDER] FROM ( SELECT id AS HUB_ID, name AS TENDER_NAME, id AS TENDER_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(active, ''1'') <> ''0'' ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews payment methods as tender dimension (no tender line items yet - DL_ORDER_PAYMENTS not landed)',
            NULL, 3, 30,
            N'["HUB_ID", "TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 6: Mews Discount
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Discount')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_DISCOUNT',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_DISCOUNT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PROMO_CODES] ) SELECT * INTO [stage].[MEWS_DISCOUNT] FROM ( SELECT id AS HUB_ID, COALESCE(NULLIF(description, ''''), code) AS DISCOUNT_NAME, id AS DISCOUNT_ID, discountType AS VALUE_TYPE, CAST(amount AS DECIMAL(18,2)) AS [VALUE], 0 AS IS_WASTE, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(active, ''1'') <> ''0'' ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews promo codes as discount dimension',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "DISCOUNT_NAME", "DISCOUNT_ID", "VALUE_TYPE", "VALUE", "IS_WASTE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Discount', N'MEWS_DISCOUNT',
            N'IF OBJECT_ID(''stage.MEWS_DISCOUNT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PROMO_CODES] ) SELECT * INTO [stage].[MEWS_DISCOUNT] FROM ( SELECT id AS HUB_ID, COALESCE(NULLIF(description, ''''), code) AS DISCOUNT_NAME, id AS DISCOUNT_ID, discountType AS VALUE_TYPE, CAST(amount AS DECIMAL(18,2)) AS [VALUE], 0 AS IS_WASTE, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(active, ''1'') <> ''0'' ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews promo codes as discount dimension',
            NULL, 3, 30,
            N'["HUB_ID", "DISCOUNT_NAME", "DISCOUNT_ID", "VALUE_TYPE", "VALUE", "IS_WASTE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 7: Mews Channel
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Channel')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_CHANNEL',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_CHANNEL'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_CHANNEL]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_AREAS] ) SELECT * INTO [stage].[MEWS_CHANNEL] FROM ( SELECT id AS HUB_ID, name AS CHANNEL_NAME, id AS CHANNEL_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(isActive, ''1'') <> ''0'' ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews dining areas as channel dimension (hub only - no order-to-area path in landed data)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Channel', N'MEWS_CHANNEL',
            N'IF OBJECT_ID(''stage.MEWS_CHANNEL'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_CHANNEL]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_AREAS] ) SELECT * INTO [stage].[MEWS_CHANNEL] FROM ( SELECT id AS HUB_ID, name AS CHANNEL_NAME, id AS CHANNEL_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(isActive, ''1'') <> ''0'' ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews dining areas as channel dimension (hub only - no order-to-area path in landed data)',
            NULL, 3, 30,
            N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 8: Mews Revenue Center
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Revenue Center')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_REVCENTER',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_REVCENTER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_REVCENTER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REVENUE_CENTERS] ) SELECT * INTO [stage].[MEWS_REVCENTER] FROM ( SELECT id AS HUB_ID, name AS REVC_NAME, id AS REVC_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(isActive, ''1'') <> ''0'' ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews revenue centers; empty until revenue center data lands',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Revenue Center', N'MEWS_REVCENTER',
            N'IF OBJECT_ID(''stage.MEWS_REVCENTER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_REVCENTER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REVENUE_CENTERS] ) SELECT * INTO [stage].[MEWS_REVCENTER] FROM ( SELECT id AS HUB_ID, name AS REVC_NAME, id AS REVC_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 AND COALESCE(isActive, ''1'') <> ''0'' ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews revenue centers; empty until revenue center data lands',
            NULL, 3, 30,
            N'["HUB_ID", "REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO
