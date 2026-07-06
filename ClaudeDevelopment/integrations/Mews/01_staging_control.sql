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
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_DISCOUNT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PROMO_CODES] ) SELECT * INTO [stage].[MEWS_DISCOUNT] FROM ( SELECT id AS HUB_ID, COALESCE(NULLIF(description, ''''), code) AS DISCOUNT_NAME, id AS DISCOUNT_ID, discountType AS VALUE_TYPE, CAST(amount AS DECIMAL(18,2)) AS [VALUE], 0 AS IS_WASTE, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews promo codes as discount dimension. Inactive members included deliberately - links may reference them (orphan-link prevention).',
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
            N'IF OBJECT_ID(''stage.MEWS_DISCOUNT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PROMO_CODES] ) SELECT * INTO [stage].[MEWS_DISCOUNT] FROM ( SELECT id AS HUB_ID, COALESCE(NULLIF(description, ''''), code) AS DISCOUNT_NAME, id AS DISCOUNT_ID, discountType AS VALUE_TYPE, CAST(amount AS DECIMAL(18,2)) AS [VALUE], 0 AS IS_WASTE, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews promo codes as discount dimension. Inactive members included deliberately - links may reference them (orphan-link prevention).',
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
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_REVCENTER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_REVCENTER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REVENUE_CENTERS] ) SELECT * INTO [stage].[MEWS_REVCENTER] FROM ( SELECT id AS HUB_ID, name AS REVC_NAME, id AS REVC_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages Mews revenue centers; empty until revenue center data lands. Inactive members included deliberately - links may reference them (orphan-link prevention).',
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
            N'IF OBJECT_ID(''stage.MEWS_REVCENTER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_REVCENTER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REVENUE_CENTERS] ) SELECT * INTO [stage].[MEWS_REVCENTER] FROM ( SELECT id AS HUB_ID, name AS REVC_NAME, id AS REVC_ID, NULL AS PARENT_ID, ''BOTTOM'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM deduped WHERE rn = 1 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages Mews revenue centers; empty until revenue center data lands. Inactive members included deliberately - links may reference them (orphan-link prevention).',
            NULL, 3, 30,
            N'["HUB_ID", "REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 9: Mews Customer Order
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Customer Order')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_CUSTORDER',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_CUSTORDER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTORDER]; WITH inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), ord AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_ORDERS] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ), itm AS ( SELECT invoiceId, COUNT(*) AS ITEM_COUNT FROM ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ) d WHERE d.rn = 1 GROUP BY invoiceId ) SELECT * INTO [stage].[MEWS_CUSTORDER] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, inv.id) AS HEADER_ID, CAST(inv.total AS DECIMAL(18,2)) AS GRAND_TOTAL, CAST(inv.subtotal AS DECIMAL(18,2)) AS GROSS_SALES, CAST(inv.tax AS DECIMAL(18,2)) AS TAX_TOTAL, CAST(COALESCE(NULLIF(inv.discountAmount, ''''), ''0'') AS DECIMAL(18,2)) AS DISCOUNT_GROSS, CAST(inv.subtotal AS DECIMAL(18,2)) - CAST(COALESCE(NULLIF(inv.discountAmount, ''''), ''0'') AS DECIMAL(18,2)) AS NET_SALES, TRY_CAST(ord.covers AS INT) AS GUEST_COUNT, itm.ITEM_COUNT AS ITEM_COUNT, 1 AS ORDER_COUNT, TRY_CONVERT(DATETIME2, ord.createdAt, 127) AS OPEN_TIME, TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS CLOSE_TIME, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, NULL AS TABLE_NO, ord.notes AS ORDER_INFO, ord.bookingId AS EXTERNAL_REFERENCE, ord.state AS ORDER_STATUS, CASE WHEN inv.cancelled = ''1'' THEN ''CANCELLED'' ELSE ''PAID'' END AS PAYMENT_STATUS, reg.outletId AS LOCATION_KEY FROM inv LEFT JOIN ord ON ord.id = inv.orderId AND ord.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 LEFT JOIN itm ON itm.invoiceId = inv.id WHERE inv.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages invoices joined to orders and registers as customer orders. Invoice is the financial source; order supplies covers/state; register resolves outlet.',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HEADER_ID", "GRAND_TOTAL", "GROSS_SALES", "TAX_TOTAL", "DISCOUNT_GROSS", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "LOCATION_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Customer Order', N'MEWS_CUSTORDER',
            N'IF OBJECT_ID(''stage.MEWS_CUSTORDER'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTORDER]; WITH inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), ord AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_ORDERS] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ), itm AS ( SELECT invoiceId, COUNT(*) AS ITEM_COUNT FROM ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ) d WHERE d.rn = 1 GROUP BY invoiceId ) SELECT * INTO [stage].[MEWS_CUSTORDER] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, inv.id) AS HEADER_ID, CAST(inv.total AS DECIMAL(18,2)) AS GRAND_TOTAL, CAST(inv.subtotal AS DECIMAL(18,2)) AS GROSS_SALES, CAST(inv.tax AS DECIMAL(18,2)) AS TAX_TOTAL, CAST(COALESCE(NULLIF(inv.discountAmount, ''''), ''0'') AS DECIMAL(18,2)) AS DISCOUNT_GROSS, CAST(inv.subtotal AS DECIMAL(18,2)) - CAST(COALESCE(NULLIF(inv.discountAmount, ''''), ''0'') AS DECIMAL(18,2)) AS NET_SALES, TRY_CAST(ord.covers AS INT) AS GUEST_COUNT, itm.ITEM_COUNT AS ITEM_COUNT, 1 AS ORDER_COUNT, TRY_CONVERT(DATETIME2, ord.createdAt, 127) AS OPEN_TIME, TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS CLOSE_TIME, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, NULL AS TABLE_NO, ord.notes AS ORDER_INFO, ord.bookingId AS EXTERNAL_REFERENCE, ord.state AS ORDER_STATUS, CASE WHEN inv.cancelled = ''1'' THEN ''CANCELLED'' ELSE ''PAID'' END AS PAYMENT_STATUS, reg.outletId AS LOCATION_KEY FROM inv LEFT JOIN ord ON ord.id = inv.orderId AND ord.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 LEFT JOIN itm ON itm.invoiceId = inv.id WHERE inv.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' ) AS source_query;',
            1, N'Staging', 0,
            N'Stages invoices joined to orders and registers as customer orders. Invoice is the financial source; order supplies covers/state; register resolves outlet.',
            NULL, 3, 30,
            N'["HEADER_ID", "GRAND_TOTAL", "GROSS_SALES", "TAX_TOTAL", "DISCOUNT_GROSS", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "LOCATION_KEY"]',
            GETDATE(), GETDATE());
GO

-- Step 10: Mews Line Item
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Line Item')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_LINEITEM',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_LINEITEM'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM]; WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ), inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ) SELECT * INTO [stage].[MEWS_LINEITEM] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, ii.invoiceId, ii.id, ''PROD'') AS SRC_KEY, CONCAT_WS(''-'', reg.outletId, ii.invoiceId) AS HEADER_ID, ''PROD'' AS LINEITEM_TYPE, CAST(ii.total AS DECIMAL(18,2)) AS GROSS_VALUE, CAST(ii.tax AS DECIMAL(18,2)) AS TAX_VALUE, CAST(ii.subtotal AS DECIMAL(18,2)) AS NET_VALUE, CAST(ii.quantity AS DECIMAL(18,4)) AS QUANTITY, CASE WHEN ii.isVoid = ''1'' OR ii.isComp = ''1'' THEN 1 ELSE 0 END AS VOID_FLAG, TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP, CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, ii.id AS LINE_ID, ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER, COALESCE(ii.productVariantId, CONCAT(ii.productId, ''-DEFAULT'')) AS PRODUCT_KEY FROM ii INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 WHERE ii.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages invoice items as PROD line items. PRODUCT_KEY = COALESCE(variantId, productId-DEFAULT) resolving 100% of lines to a BOTTOM product member. LINEITEM_TIMESTAMP from item createdAt (must never be NULL).',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "PRODUCT_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Line Item', N'MEWS_LINEITEM',
            N'IF OBJECT_ID(''stage.MEWS_LINEITEM'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM]; WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ), inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ) SELECT * INTO [stage].[MEWS_LINEITEM] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, ii.invoiceId, ii.id, ''PROD'') AS SRC_KEY, CONCAT_WS(''-'', reg.outletId, ii.invoiceId) AS HEADER_ID, ''PROD'' AS LINEITEM_TYPE, CAST(ii.total AS DECIMAL(18,2)) AS GROSS_VALUE, CAST(ii.tax AS DECIMAL(18,2)) AS TAX_VALUE, CAST(ii.subtotal AS DECIMAL(18,2)) AS NET_VALUE, CAST(ii.quantity AS DECIMAL(18,4)) AS QUANTITY, CASE WHEN ii.isVoid = ''1'' OR ii.isComp = ''1'' THEN 1 ELSE 0 END AS VOID_FLAG, TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP, CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, ii.id AS LINE_ID, ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER, COALESCE(ii.productVariantId, CONCAT(ii.productId, ''-DEFAULT'')) AS PRODUCT_KEY FROM ii INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 WHERE ii.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' ) AS source_query;',
            1, N'Staging', 0,
            N'Stages invoice items as PROD line items. PRODUCT_KEY = COALESCE(variantId, productId-DEFAULT) resolving 100% of lines to a BOTTOM product member. LINEITEM_TIMESTAMP from item createdAt (must never be NULL).',
            NULL, 3, 30,
            N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "PRODUCT_KEY"]',
            GETDATE(), GETDATE());
GO

-- Step 11: Mews Line Item Tax
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Line Item Tax')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_LINEITEM_TAX',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_LINEITEM_TAX'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM_TAX]; WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ), inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ), tx AS ( SELECT TOP 1 id FROM ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_TAXES] ) t WHERE t.rn = 1 ORDER BY id ) SELECT * INTO [stage].[MEWS_LINEITEM_TAX] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, ii.invoiceId, ii.id, ''TAX'') AS SRC_KEY, CONCAT_WS(''-'', reg.outletId, ii.invoiceId) AS HEADER_ID, ''TAX'' AS LINEITEM_TYPE, CAST(ii.tax AS DECIMAL(18,2)) AS GROSS_VALUE, CAST(ii.tax AS DECIMAL(18,2)) AS TAX_VALUE, CAST(0 AS DECIMAL(18,2)) AS NET_VALUE, CAST(1 AS DECIMAL(18,4)) AS QUANTITY, CASE WHEN ii.isVoid = ''1'' OR ii.isComp = ''1'' THEN 1 ELSE 0 END AS VOID_FLAG, TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP, CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, ii.id AS LINE_ID, ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER, tx.id AS TAX_KEY FROM ii INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 CROSS JOIN tx WHERE ii.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' AND CAST(ii.tax AS DECIMAL(18,2)) <> 0 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages TAX-type line items from invoice item tax amounts. SINGLE-TAX ASSUMPTION: items carry no tax id; all TAX lines link to the sole tax profile via CROSS JOIN. Verification guards against >1 active tax.',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "TAX_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Line Item Tax', N'MEWS_LINEITEM_TAX',
            N'IF OBJECT_ID(''stage.MEWS_LINEITEM_TAX'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM_TAX]; WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ), inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ), tx AS ( SELECT TOP 1 id FROM ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_TAXES] ) t WHERE t.rn = 1 ORDER BY id ) SELECT * INTO [stage].[MEWS_LINEITEM_TAX] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, ii.invoiceId, ii.id, ''TAX'') AS SRC_KEY, CONCAT_WS(''-'', reg.outletId, ii.invoiceId) AS HEADER_ID, ''TAX'' AS LINEITEM_TYPE, CAST(ii.tax AS DECIMAL(18,2)) AS GROSS_VALUE, CAST(ii.tax AS DECIMAL(18,2)) AS TAX_VALUE, CAST(0 AS DECIMAL(18,2)) AS NET_VALUE, CAST(1 AS DECIMAL(18,4)) AS QUANTITY, CASE WHEN ii.isVoid = ''1'' OR ii.isComp = ''1'' THEN 1 ELSE 0 END AS VOID_FLAG, TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP, CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, ii.id AS LINE_ID, ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER, tx.id AS TAX_KEY FROM ii INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 CROSS JOIN tx WHERE ii.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' AND CAST(ii.tax AS DECIMAL(18,2)) <> 0 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages TAX-type line items from invoice item tax amounts. SINGLE-TAX ASSUMPTION: items carry no tax id; all TAX lines link to the sole tax profile via CROSS JOIN. Verification guards against >1 active tax.',
            NULL, 3, 30,
            N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "TAX_KEY"]',
            GETDATE(), GETDATE());
GO

-- Step 12: Mews Line Item Discount
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Line Item Discount')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_LINEITEM_DISCOUNT',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_LINEITEM_DISCOUNT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM_DISCOUNT]; WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ), inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ) SELECT * INTO [stage].[MEWS_LINEITEM_DISCOUNT] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, ii.invoiceId, ii.id, ''DISCOUNT'') AS SRC_KEY, CONCAT_WS(''-'', reg.outletId, ii.invoiceId) AS HEADER_ID, ''DISCOUNT'' AS LINEITEM_TYPE, -1 * COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '''') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '''') AS DECIMAL(18,2)), 0) AS GROSS_VALUE, CAST(0 AS DECIMAL(18,2)) AS TAX_VALUE, -1 * COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '''') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '''') AS DECIMAL(18,2)), 0) AS NET_VALUE, CAST(1 AS DECIMAL(18,4)) AS QUANTITY, CASE WHEN ii.isVoid = ''1'' OR ii.isComp = ''1'' THEN 1 ELSE 0 END AS VOID_FLAG, TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP, CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, ii.id AS LINE_ID, ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER, inv.promoCodeId AS DISCOUNT_KEY FROM ii INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 WHERE ii.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' AND COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '''') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '''') AS DECIMAL(18,2)), 0) <> 0 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages DISCOUNT-type line items (negative values) from invoice item discounts. DISCOUNT_KEY = invoice promoCodeId, may be NULL for ad-hoc discounts; the DISCOUNT_LINEITEM link stages separately with NULL keys filtered.',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "DISCOUNT_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Line Item Discount', N'MEWS_LINEITEM_DISCOUNT',
            N'IF OBJECT_ID(''stage.MEWS_LINEITEM_DISCOUNT'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM_DISCOUNT]; WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICE_ITEMS] ), inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ) SELECT * INTO [stage].[MEWS_LINEITEM_DISCOUNT] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, ii.invoiceId, ii.id, ''DISCOUNT'') AS SRC_KEY, CONCAT_WS(''-'', reg.outletId, ii.invoiceId) AS HEADER_ID, ''DISCOUNT'' AS LINEITEM_TYPE, -1 * COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '''') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '''') AS DECIMAL(18,2)), 0) AS GROSS_VALUE, CAST(0 AS DECIMAL(18,2)) AS TAX_VALUE, -1 * COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '''') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '''') AS DECIMAL(18,2)), 0) AS NET_VALUE, CAST(1 AS DECIMAL(18,4)) AS QUANTITY, CASE WHEN ii.isVoid = ''1'' OR ii.isComp = ''1'' THEN 1 ELSE 0 END AS VOID_FLAG, TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP, CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE, CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE, ii.id AS LINE_ID, ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER, inv.promoCodeId AS DISCOUNT_KEY FROM ii INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1 LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 WHERE ii.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' AND COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '''') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '''') AS DECIMAL(18,2)), 0) <> 0 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages DISCOUNT-type line items (negative values) from invoice item discounts. DISCOUNT_KEY = invoice promoCodeId, may be NULL for ad-hoc discounts; the DISCOUNT_LINEITEM link stages separately with NULL keys filtered.',
            NULL, 3, 30,
            N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "DISCOUNT_KEY"]',
            GETDATE(), GETDATE());
GO

-- Steps 13-15 (Mews Customer / Mews Address / Mews Contact) REMOVED 2026-07-03.
-- GDPR ruling: guest names, home addresses, and email/phone contacts are
-- personal data with no current reporting need for the Mews integration, so
-- the whole CRM lane (INDIVIDUAL/ADDRESS/CONTACT + their links) is excluded
-- from staging and the DV load. 05_remove_crm_pii.sql deletes the deployed
-- control rows and purges the already-loaded data.
-- If this lane is ever re-enabled, note that DL_CUSTOMERS.fullName must be
-- SPLIT (first token=FORENAME, last=SURNAME, middle=MIDDLE_NAMES) — the
-- original step dumped fullName into FORENAME, discarding surnames.

-- Step 16: Mews Order Revenue Center Link
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Order Revenue Center Link')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_CUSTORDER_REVCENTER_LNK',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_CUSTORDER_REVCENTER_LNK'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTORDER_REVCENTER_LNK]; WITH inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ) SELECT * INTO [stage].[MEWS_CUSTORDER_REVCENTER_LNK] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, inv.id) AS HEADER_ID, inv.revenueCenterId AS REVC_KEY FROM inv LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 WHERE inv.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' AND inv.revenueCenterId IS NOT NULL ) AS source_query;',
        tier             = 2,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Link staging: order-to-revenue-center pairs, NULL revenue center keys filtered out. Empty until Mews populates revenueCenterId.',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HEADER_ID", "REVC_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Order Revenue Center Link', N'MEWS_CUSTORDER_REVCENTER_LNK',
            N'IF OBJECT_ID(''stage.MEWS_CUSTORDER_REVCENTER_LNK'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTORDER_REVCENTER_LNK]; WITH inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ), reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] ) SELECT * INTO [stage].[MEWS_CUSTORDER_REVCENTER_LNK] FROM ( SELECT CONCAT_WS(''-'', reg.outletId, inv.id) AS HEADER_ID, inv.revenueCenterId AS REVC_KEY FROM inv LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1 WHERE inv.rn = 1 AND COALESCE(inv.cancelled, ''0'') <> ''1'' AND inv.revenueCenterId IS NOT NULL ) AS source_query;',
            2, N'Staging', 0,
            N'Link staging: order-to-revenue-center pairs, NULL revenue center keys filtered out. Empty until Mews populates revenueCenterId.',
            NULL, 3, 30,
            N'["HEADER_ID", "REVC_KEY"]',
            GETDATE(), GETDATE());
GO

-- Step 17: Mews Discount Line Link
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Discount Line Link')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_DISCOUNT_LINEITEM_LNK',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_DISCOUNT_LINEITEM_LNK'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT_LINEITEM_LNK]; SELECT * INTO [stage].[MEWS_DISCOUNT_LINEITEM_LNK] FROM ( SELECT li.SRC_KEY, li.DISCOUNT_KEY FROM [stage].[MEWS_LINEITEM_DISCOUNT] li WHERE li.DISCOUNT_KEY IS NOT NULL ) AS source_query;',
        tier             = 2,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Link staging: discount-to-line pairs from MEWS_LINEITEM_DISCOUNT with NULL promo keys filtered out',
        depends_on_steps = N'Mews Line Item Discount',
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "DISCOUNT_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Discount Line Link', N'MEWS_DISCOUNT_LINEITEM_LNK',
            N'IF OBJECT_ID(''stage.MEWS_DISCOUNT_LINEITEM_LNK'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT_LINEITEM_LNK]; SELECT * INTO [stage].[MEWS_DISCOUNT_LINEITEM_LNK] FROM ( SELECT li.SRC_KEY, li.DISCOUNT_KEY FROM [stage].[MEWS_LINEITEM_DISCOUNT] li WHERE li.DISCOUNT_KEY IS NOT NULL ) AS source_query;',
            2, N'Staging', 0,
            N'Link staging: discount-to-line pairs from MEWS_LINEITEM_DISCOUNT with NULL promo keys filtered out',
            N'Mews Line Item Discount', 3, 30,
            N'["SRC_KEY", "DISCOUNT_KEY"]',
            GETDATE(), GETDATE());
GO

-- Step 18: Mews Line Item Combined
-- The DV load generator (UploadEntityMappings) supports exactly ONE
-- EntityMappings row per entity. LINEITEM and CUSTORDER_LINEITEM ingest
-- PROD + TAX + DISCOUNT lines, so those three tier-1 tables are unioned
-- here into a single stage table (NCRAloha precedent: NCR_LINE_ITEM_DETAIL).
-- Tier 2 guarantees the three tier-1 line item steps have completed.
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'Mews Line Item Combined')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'MEWS_LINEITEM_ALL',
        query_sql        = N'IF OBJECT_ID(''stage.MEWS_LINEITEM_ALL'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM_ALL]; SELECT * INTO [stage].[MEWS_LINEITEM_ALL] FROM ( SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, VOID_FLAG, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, TRADING_DATE, LINE_ID, LINE_ORDER FROM [stage].[MEWS_LINEITEM] UNION ALL SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, VOID_FLAG, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, TRADING_DATE, LINE_ID, LINE_ORDER FROM [stage].[MEWS_LINEITEM_TAX] UNION ALL SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, VOID_FLAG, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, TRADING_DATE, LINE_ID, LINE_ORDER FROM [stage].[MEWS_LINEITEM_DISCOUNT] ) AS source_query;',
        tier             = 2,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Unions PROD/TAX/DISCOUNT line items into one stage table for the LINEITEM hub and CUSTORDER_LINEITEM link (the DV load generator supports one mapping row per entity). SRC_KEY is unique across types via the PROD/TAX/DISCOUNT suffix.',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Mews Line Item Combined', N'MEWS_LINEITEM_ALL',
            N'IF OBJECT_ID(''stage.MEWS_LINEITEM_ALL'', ''U'') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM_ALL]; SELECT * INTO [stage].[MEWS_LINEITEM_ALL] FROM ( SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, VOID_FLAG, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, TRADING_DATE, LINE_ID, LINE_ORDER FROM [stage].[MEWS_LINEITEM] UNION ALL SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, VOID_FLAG, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, TRADING_DATE, LINE_ID, LINE_ORDER FROM [stage].[MEWS_LINEITEM_TAX] UNION ALL SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, VOID_FLAG, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, TRADING_DATE, LINE_ID, LINE_ORDER FROM [stage].[MEWS_LINEITEM_DISCOUNT] ) AS source_query;',
            2, N'Staging', 0,
            N'Unions PROD/TAX/DISCOUNT line items into one stage table for the LINEITEM hub and CUSTORDER_LINEITEM link (the DV load generator supports one mapping row per entity). SRC_KEY is unique across types via the PROD/TAX/DISCOUNT suffix.',
            NULL, 3, 30,
            N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER"]',
            GETDATE(), GETDATE());
GO
