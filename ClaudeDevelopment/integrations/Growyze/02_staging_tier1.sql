/* ============================================================================
   Growyze Integration - Tier 1 Staging Steps
   Target: [core].[int_growyze001].[StagingControl]

   11 Tier 1 staging steps for the Growyze integration.
   All steps use MERGE upsert pattern for idempotent re-runs.

   Created: 2026-03-05
   Fixed: 2026-03-05 — Moved CTEs outside derived tables (SQL Server error 156)
   Fixed: 2026-03-06 — GRYZ_LINEITEM: createdAt → createdDate (DL_DISHES column name mismatch)
   ============================================================================ */

-- Step 1: Growyze Location
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Location')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_LOCATION',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_LOCATION'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LOCATION]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_ORGANIZATIONS] ) SELECT * INTO [stage].[GRYZ_LOCATION] FROM ( SELECT id AS HUB_ID, companyName AS LOCATION_NAME, id AS LOCATION_ID, ''Location'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS PARENT_ID, ''growyze'' AS MICROSERVICE_NAME, id AS MICROSERVICE_ID, type AS ATTR_1 FROM deduped WHERE rn = 1 ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages organisation records as location hierarchy (single level)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PARENT_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID", "ATTR_1"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Location', N'GRYZ_LOCATION',
            N'IF OBJECT_ID(''stage.GRYZ_LOCATION'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LOCATION]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_ORGANIZATIONS] ) SELECT * INTO [stage].[GRYZ_LOCATION] FROM ( SELECT id AS HUB_ID, companyName AS LOCATION_NAME, id AS LOCATION_ID, ''Location'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS PARENT_ID, ''growyze'' AS MICROSERVICE_NAME, id AS MICROSERVICE_ID, type AS ATTR_1 FROM deduped WHERE rn = 1 ) AS source_query;',
            1, N'Staging', 0,
            N'Stages organisation records as location hierarchy (single level)',
            NULL, 3, 30,
            N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PARENT_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID", "ATTR_1"]',
            GETDATE(), GETDATE());
GO

-- Step 2: Growyze Inventory Items
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Inventory Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_INVITEMS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, ''growyze'' AS MICROSERVICE_NAME, id AS MICROSERVICE_ID, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, ''growyze'' AS MICROSERVICE_NAME, CONCAT(organizations, ''-'', subCategory) AS MICROSERVICE_ID, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, ''growyze'' AS MICROSERVICE_NAME, category AS MICROSERVICE_ID, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_NAME", "MICROSERVICE_ID", "INVITEM_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Inventory Items', N'GRYZ_INVITEMS',
            N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, ''growyze'' AS MICROSERVICE_NAME, id AS MICROSERVICE_ID, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, ''growyze'' AS MICROSERVICE_NAME, CONCAT(organizations, ''-'', subCategory) AS MICROSERVICE_ID, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, ''growyze'' AS MICROSERVICE_NAME, category AS MICROSERVICE_ID, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;',
            1, N'Staging', 0,
            N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category)',
            NULL, 3, 30,
            N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_NAME", "MICROSERVICE_ID", "INVITEM_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 3: Growyze Suppliers
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Suppliers')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_SUPPLIERS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_SUPPLIERS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_SUPPLIERS]; WITH prod_suppliers AS ( SELECT DISTINCT supplierId AS supplier_id, supplierName AS supplier_name FROM [int_growyze001].[DL_PRODUCTS] WHERE supplierId IS NOT NULL ), order_suppliers AS ( SELECT DISTINCT supplier_id, supplier_name FROM [int_growyze001].[DL_ORDERS] WHERE supplier_id IS NOT NULL ) SELECT * INTO [stage].[GRYZ_SUPPLIERS] FROM ( SELECT COALESCE(p.supplier_id, o.supplier_id) AS HUB_ID, COALESCE(o.supplier_name, p.supplier_name) AS SUPPLIER_NAME, COALESCE(p.supplier_id, o.supplier_id) AS SUPPLIER_ID, ''growyze'' AS MICROSERVICE_NAME, COALESCE(p.supplier_id, o.supplier_id) AS MICROSERVICE_ID FROM prod_suppliers p FULL OUTER JOIN order_suppliers o ON p.supplier_id = o.supplier_id ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages suppliers from both products and orders sources with FULL OUTER JOIN dedup',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Suppliers', N'GRYZ_SUPPLIERS',
            N'IF OBJECT_ID(''stage.GRYZ_SUPPLIERS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_SUPPLIERS]; WITH prod_suppliers AS ( SELECT DISTINCT supplierId AS supplier_id, supplierName AS supplier_name FROM [int_growyze001].[DL_PRODUCTS] WHERE supplierId IS NOT NULL ), order_suppliers AS ( SELECT DISTINCT supplier_id, supplier_name FROM [int_growyze001].[DL_ORDERS] WHERE supplier_id IS NOT NULL ) SELECT * INTO [stage].[GRYZ_SUPPLIERS] FROM ( SELECT COALESCE(p.supplier_id, o.supplier_id) AS HUB_ID, COALESCE(o.supplier_name, p.supplier_name) AS SUPPLIER_NAME, COALESCE(p.supplier_id, o.supplier_id) AS SUPPLIER_ID, ''growyze'' AS MICROSERVICE_NAME, COALESCE(p.supplier_id, o.supplier_id) AS MICROSERVICE_ID FROM prod_suppliers p FULL OUTER JOIN order_suppliers o ON p.supplier_id = o.supplier_id ) AS source_query;',
            1, N'Staging', 0,
            N'Stages suppliers from both products and orders sources with FULL OUTER JOIN dedup',
            NULL, 3, 30,
            N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 4: Growyze Occasion (no CTE - unchanged)
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Occasion')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_OCCASION',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_OCCASION'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_OCCASION]; SELECT * INTO [stage].[GRYZ_OCCASION] FROM ( SELECT ''-999'' AS OCC_ID, ''Not Applicable'' AS OCC_NAME, NULL AS PARENT_ID, ''Occasion'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages a single sentinel occasion row (Growyze has no occasion concept)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Occasion', N'GRYZ_OCCASION',
            N'IF OBJECT_ID(''stage.GRYZ_OCCASION'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_OCCASION]; SELECT * INTO [stage].[GRYZ_OCCASION] FROM ( SELECT ''-999'' AS OCC_ID, ''Not Applicable'' AS OCC_NAME, NULL AS PARENT_ID, ''Occasion'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL ) AS source_query;',
            1, N'Staging', 0,
            N'Stages a single sentinel occasion row (Growyze has no occasion concept)',
            NULL, 3, 30,
            N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            GETDATE(), GETDATE());
GO

-- Step 5: Growyze Prep Recipes (no CTE - unchanged)
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Prep Recipes')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_PREP_RECIPES',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_PREP_RECIPES'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_PREP_RECIPES]; SELECT * INTO [stage].[GRYZ_PREP_RECIPES] FROM ( SELECT DISTINCT id AS PARENT_HUB_ID, sections_elements_ingredient_product_id AS CHILD_HUB_ID, sections_elements_ingredient_measure AS UOM, sections_elements_ingredient_usedQty AS UOM_VALUE FROM [int_growyze001].[DL_RECIPES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages recipe-to-ingredient links from DL_RECIPES',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Prep Recipes', N'GRYZ_PREP_RECIPES',
            N'IF OBJECT_ID(''stage.GRYZ_PREP_RECIPES'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_PREP_RECIPES]; SELECT * INTO [stage].[GRYZ_PREP_RECIPES] FROM ( SELECT DISTINCT id AS PARENT_HUB_ID, sections_elements_ingredient_product_id AS CHILD_HUB_ID, sections_elements_ingredient_measure AS UOM, sections_elements_ingredient_usedQty AS UOM_VALUE FROM [int_growyze001].[DL_RECIPES] WHERE sections_elements_type = ''INGREDIENT'' AND sections_elements_ingredient_product_id IS NOT NULL ) AS source_query;',
            1, N'Staging', 0,
            N'Stages recipe-to-ingredient links from DL_RECIPES',
            NULL, 3, 30,
            N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
            GETDATE(), GETDATE());
GO

-- Step 6: Growyze Product
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Product')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_PRODUCT',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_PRODUCT]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_PRODUCT] FROM ( SELECT id AS HUB_ID, name AS PRODUCT_NAME, category AS PARENT_ID, ''Product'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, id AS PRODUCT_ID, posId AS ATTR_1, barcode AS ATTR_2, ''growyze'' AS MICROSERVICE_NAME, id AS MICROSERVICE_ID, organizations AS LOCATION_KEY, ''-999'' AS OCC_ID, salePrice AS NET_PRICE, totalCost AS NET_COST FROM base UNION ALL SELECT DISTINCT category AS HUB_ID, category AS PRODUCT_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, category AS PRODUCT_ID, NULL AS ATTR_1, NULL AS ATTR_2, ''growyze'' AS MICROSERVICE_NAME, category AS MICROSERVICE_ID, NULL AS LOCATION_KEY, NULL AS OCC_ID, NULL AS NET_PRICE, NULL AS NET_COST FROM base WHERE category IS NOT NULL ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages dishes as 2-tier product hierarchy (Product/Category)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_KEY", "OCC_ID", "NET_PRICE", "NET_COST"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Product', N'GRYZ_PRODUCT',
            N'IF OBJECT_ID(''stage.GRYZ_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_PRODUCT]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_DISHES] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_PRODUCT] FROM ( SELECT id AS HUB_ID, name AS PRODUCT_NAME, category AS PARENT_ID, ''Product'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, id AS PRODUCT_ID, posId AS ATTR_1, barcode AS ATTR_2, ''growyze'' AS MICROSERVICE_NAME, id AS MICROSERVICE_ID, organizations AS LOCATION_KEY, ''-999'' AS OCC_ID, salePrice AS NET_PRICE, totalCost AS NET_COST FROM base UNION ALL SELECT DISTINCT category AS HUB_ID, category AS PRODUCT_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, category AS PRODUCT_ID, NULL AS ATTR_1, NULL AS ATTR_2, ''growyze'' AS MICROSERVICE_NAME, category AS MICROSERVICE_ID, NULL AS LOCATION_KEY, NULL AS OCC_ID, NULL AS NET_PRICE, NULL AS NET_COST FROM base WHERE category IS NOT NULL ) AS source_query;',
            1, N'Staging', 0,
            N'Stages dishes as 2-tier product hierarchy (Product/Category)',
            NULL, 3, 30,
            N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_KEY", "OCC_ID", "NET_PRICE", "NET_COST"]',
            GETDATE(), GETDATE());
GO

-- Step 7: Growyze Stock Order
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Stock Order')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_STOCKORDER',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_STOCKORDER'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_STOCKORDER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_ORDERS] ) SELECT * INTO [stage].[GRYZ_STOCKORDER] FROM ( SELECT id AS HUB_ID, MIN(placedDate) AS ORDER_DATE, MIN(expectedDeliveryDate) AS DELIVERY_DATE, MIN(CAST(totalCost AS NVARCHAR(MAX))) AS ORDER_TOTAL, NULL AS ORDER_TAX, MIN(po) AS ORDER_INFO, MIN(status) AS ORDER_STATUS, ''-999'' AS DISTRIBUTOR_KEY, MIN(supplier_id) AS SUPPLIER_KEY FROM deduped WHERE rn = 1 GROUP BY id ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages orders as stock orders with dedup and GROUP BY for one row per order',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "DISTRIBUTOR_KEY", "SUPPLIER_KEY"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Stock Order', N'GRYZ_STOCKORDER',
            N'IF OBJECT_ID(''stage.GRYZ_STOCKORDER'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_STOCKORDER]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_ORDERS] ) SELECT * INTO [stage].[GRYZ_STOCKORDER] FROM ( SELECT id AS HUB_ID, MIN(placedDate) AS ORDER_DATE, MIN(expectedDeliveryDate) AS DELIVERY_DATE, MIN(CAST(totalCost AS NVARCHAR(MAX))) AS ORDER_TOTAL, NULL AS ORDER_TAX, MIN(po) AS ORDER_INFO, MIN(status) AS ORDER_STATUS, ''-999'' AS DISTRIBUTOR_KEY, MIN(supplier_id) AS SUPPLIER_KEY FROM deduped WHERE rn = 1 GROUP BY id ) AS source_query;',
            1, N'Staging', 0,
            N'Stages orders as stock orders with dedup and GROUP BY for one row per order',
            NULL, 3, 30,
            N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "DISTRIBUTOR_KEY", "SUPPLIER_KEY"]',
            GETDATE(), GETDATE());
GO

-- Step 8: Growyze Order Items
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Order Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_ORDER_ITEMS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_ORDER_ITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_ORDER_ITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_ORDERS] ) SELECT * INTO [stage].[GRYZ_ORDER_ITEMS] FROM ( SELECT CONCAT_WS(''-'', id, items_productId) AS SRC_KEY, id AS ORDER_ID, items_productId AS ITEM_ID, items_quantity, items_price, items_estimatedCost, items_orderInCase, items_productCase_size, items_productCase_price FROM deduped WHERE rn = 1 AND items_productId IS NOT NULL ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages order line items with composite key (order+product)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "ORDER_ID", "ITEM_ID", "items_quantity", "items_price", "items_estimatedCost", "items_orderInCase", "items_productCase_size", "items_productCase_price"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Order Items', N'GRYZ_ORDER_ITEMS',
            N'IF OBJECT_ID(''stage.GRYZ_ORDER_ITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_ORDER_ITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_ORDERS] ) SELECT * INTO [stage].[GRYZ_ORDER_ITEMS] FROM ( SELECT CONCAT_WS(''-'', id, items_productId) AS SRC_KEY, id AS ORDER_ID, items_productId AS ITEM_ID, items_quantity, items_price, items_estimatedCost, items_orderInCase, items_productCase_size, items_productCase_price FROM deduped WHERE rn = 1 AND items_productId IS NOT NULL ) AS source_query;',
            1, N'Staging', 0,
            N'Stages order line items with composite key (order+product)',
            NULL, 3, 30,
            N'["SRC_KEY", "ORDER_ID", "ITEM_ID", "items_quantity", "items_price", "items_estimatedCost", "items_orderInCase", "items_productCase_size", "items_productCase_price"]',
            GETDATE(), GETDATE());
GO

-- Step 9: Growyze Line Item
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Line Item')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_LINEITEM',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_LINEITEM'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LINEITEM]; WITH dish_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY posId, organizations ORDER BY createdDate DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE posId IS NOT NULL ), dishes AS (SELECT * FROM dish_dedup WHERE rn = 1), sales_agg AS ( SELECT id, MIN([from]) AS sale_from, MIN([to]) AS sale_to, MIN(totalSales) AS totalSales, MIN(metadata_orderId) AS metadata_orderId, COUNT(*) AS detail_count FROM [int_growyze001].[DL_SALES] GROUP BY id ) SELECT * INTO [stage].[GRYZ_LINEITEM] FROM ( SELECT CONCAT_WS(''-'', sd.id, sd.items_posId) AS SRC_KEY, sd.id AS HEADER_ID, ''PROD'' AS LINEITEM_TYPE, sd.items_soldQty AS QUANTITY, sd.items_totalValue AS NET_VALUE, sd.items_totalValue AS GROSS_VALUE, s.sale_from AS ORDER_DATE, CAST(s.sale_from AS DATE) AS TRADING_DATE, d.id AS PRODUCT_KEY, sd.organizations AS LOCATION_KEY, ''-999'' AS OCC_ID, s.totalSales AS NET_SALES, s.detail_count AS ITEM_COUNT, s.sale_from AS OPEN_TIME, s.sale_to AS CLOSE_TIME, s.metadata_orderId AS EXTERNAL_REFERENCE FROM [int_growyze001].[DL_SALESDETAIL] sd LEFT JOIN dishes d ON sd.items_posId = d.posId AND sd.organizations = d.organizations LEFT JOIN sales_agg s ON sd.id = s.id ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages sales detail as line items with dish and sales header lookups',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE", "PRODUCT_KEY", "LOCATION_KEY", "OCC_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "EXTERNAL_REFERENCE"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Line Item', N'GRYZ_LINEITEM',
            N'IF OBJECT_ID(''stage.GRYZ_LINEITEM'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LINEITEM]; WITH dish_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY posId, organizations ORDER BY createdDate DESC) AS rn FROM [int_growyze001].[DL_DISHES] WHERE posId IS NOT NULL ), dishes AS (SELECT * FROM dish_dedup WHERE rn = 1), sales_agg AS ( SELECT id, MIN([from]) AS sale_from, MIN([to]) AS sale_to, MIN(totalSales) AS totalSales, MIN(metadata_orderId) AS metadata_orderId, COUNT(*) AS detail_count FROM [int_growyze001].[DL_SALES] GROUP BY id ) SELECT * INTO [stage].[GRYZ_LINEITEM] FROM ( SELECT CONCAT_WS(''-'', sd.id, sd.items_posId) AS SRC_KEY, sd.id AS HEADER_ID, ''PROD'' AS LINEITEM_TYPE, sd.items_soldQty AS QUANTITY, sd.items_totalValue AS NET_VALUE, sd.items_totalValue AS GROSS_VALUE, s.sale_from AS ORDER_DATE, CAST(s.sale_from AS DATE) AS TRADING_DATE, d.id AS PRODUCT_KEY, sd.organizations AS LOCATION_KEY, ''-999'' AS OCC_ID, s.totalSales AS NET_SALES, s.detail_count AS ITEM_COUNT, s.sale_from AS OPEN_TIME, s.sale_to AS CLOSE_TIME, s.metadata_orderId AS EXTERNAL_REFERENCE FROM [int_growyze001].[DL_SALESDETAIL] sd LEFT JOIN dishes d ON sd.items_posId = d.posId AND sd.organizations = d.organizations LEFT JOIN sales_agg s ON sd.id = s.id ) AS source_query;',
            1, N'Staging', 0,
            N'Stages sales detail as line items with dish and sales header lookups',
            NULL, 3, 30,
            N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE", "PRODUCT_KEY", "LOCATION_KEY", "OCC_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "EXTERNAL_REFERENCE"]',
            GETDATE(), GETDATE());
GO

-- Step 10: Growyze DN Events
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze DN Events')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_DN_EVENTS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_DN_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_DN_EVENTS]; WITH prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY id) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1), order_lookup AS ( SELECT DISTINCT po, id AS order_id, organizations FROM [int_growyze001].[DL_ORDERS] WHERE po IS NOT NULL ) SELECT * INTO [stage].[GRYZ_DN_EVENTS] FROM ( SELECT CONCAT_WS(''-'', dn.id, p.id) AS SRC_KEY, ''ORDER'' AS EVENT_TYPE, ''+'' AS EVENT_BEHANIOUR, dn.deliveryDate AS EVENT_TS, CONCAT_WS('' '', dn.products_size, dn.products_unit) AS PACK_DESC, dn.products_receivedQtyInCase AS PACK_QUANTITY, dn.products_measure AS UOM, dn.products_receivedQty AS UOM_QUANTITY, dn.po AS EXTERNAL_REF, dn.id AS INTERNAL_REF, p.id AS itemId, dn.organizations AS storeID, ol.order_id AS ORDER_ID FROM [int_growyze001].[DL_DELIVERYNOTES] dn INNER JOIN prods p ON dn.products_barcode = p.barcode AND dn.organizations = p.organizations LEFT JOIN order_lookup ol ON dn.po = ol.po AND dn.organizations = ol.organizations ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages delivery note events with product barcode resolution and order PO lookup',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID", "ORDER_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze DN Events', N'GRYZ_DN_EVENTS',
            N'IF OBJECT_ID(''stage.GRYZ_DN_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_DN_EVENTS]; WITH prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY id) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1), order_lookup AS ( SELECT DISTINCT po, id AS order_id, organizations FROM [int_growyze001].[DL_ORDERS] WHERE po IS NOT NULL ) SELECT * INTO [stage].[GRYZ_DN_EVENTS] FROM ( SELECT CONCAT_WS(''-'', dn.id, p.id) AS SRC_KEY, ''ORDER'' AS EVENT_TYPE, ''+'' AS EVENT_BEHANIOUR, dn.deliveryDate AS EVENT_TS, CONCAT_WS('' '', dn.products_size, dn.products_unit) AS PACK_DESC, dn.products_receivedQtyInCase AS PACK_QUANTITY, dn.products_measure AS UOM, dn.products_receivedQty AS UOM_QUANTITY, dn.po AS EXTERNAL_REF, dn.id AS INTERNAL_REF, p.id AS itemId, dn.organizations AS storeID, ol.order_id AS ORDER_ID FROM [int_growyze001].[DL_DELIVERYNOTES] dn INNER JOIN prods p ON dn.products_barcode = p.barcode AND dn.organizations = p.organizations LEFT JOIN order_lookup ol ON dn.po = ol.po AND dn.organizations = ol.organizations ) AS source_query;',
            1, N'Staging', 0,
            N'Stages delivery note events with product barcode resolution and order PO lookup',
            NULL, 3, 30,
            N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID", "ORDER_ID"]',
            GETDATE(), GETDATE());
GO

-- Step 11: Growyze Waste Events
MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Waste Events')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_WASTE_EVENTS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_WASTE_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_WASTE_EVENTS]; WITH waste_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY products_wastesPerDay_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_WASTES] ), wastes AS (SELECT * FROM waste_dedup WHERE rn = 1), prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY name, organizations ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1) SELECT * INTO [stage].[GRYZ_WASTE_EVENTS] FROM ( SELECT w.products_wastesPerDay_id AS SRC_KEY, ''WASTE'' AS EVENT_TYPE, ''-'' AS EVENT_BEHANIOUR, w.products_wastesPerDay_timeOfRecord AS EVENT_TS, CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC, CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY, COALESCE(w.products_wastesPerDay_wasteMeasure, p.measure) AS UOM, w.products_wastesPerDay_totalQty AS UOM_QUANTITY, w.products_wastesPerDay_dishName AS EXTERNAL_REF, w.id AS INTERNAL_REF, COALESCE(w.products_product_id, p.id) AS itemId, w.organizations AS storeID FROM wastes w LEFT JOIN prods p ON w.products_product_name = p.name AND w.organizations = p.organizations ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages waste events with name-based product resolution fallback',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Waste Events', N'GRYZ_WASTE_EVENTS',
            N'IF OBJECT_ID(''stage.GRYZ_WASTE_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_WASTE_EVENTS]; WITH waste_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY products_wastesPerDay_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_WASTES] ), wastes AS (SELECT * FROM waste_dedup WHERE rn = 1), prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY name, organizations ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1) SELECT * INTO [stage].[GRYZ_WASTE_EVENTS] FROM ( SELECT w.products_wastesPerDay_id AS SRC_KEY, ''WASTE'' AS EVENT_TYPE, ''-'' AS EVENT_BEHANIOUR, w.products_wastesPerDay_timeOfRecord AS EVENT_TS, CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC, CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY, COALESCE(w.products_wastesPerDay_wasteMeasure, p.measure) AS UOM, w.products_wastesPerDay_totalQty AS UOM_QUANTITY, w.products_wastesPerDay_dishName AS EXTERNAL_REF, w.id AS INTERNAL_REF, COALESCE(w.products_product_id, p.id) AS itemId, w.organizations AS storeID FROM wastes w LEFT JOIN prods p ON w.products_product_name = p.name AND w.organizations = p.organizations ) AS source_query;',
            1, N'Staging', 0,
            N'Stages waste events with name-based product resolution fallback',
            NULL, 3, 30,
            N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
            GETDATE(), GETDATE());
GO
