-- ============================================================================
-- 05_growyze_integration.sql
-- Consolidated deployment script: Full Growyze integration
-- Target: Core database
-- ============================================================================

-- ============================================================================
-- SECTION 1 of 11: Infrastructure — reference schema, UOM_CONVERSION table
-- Source: 01_infrastructure.sql
-- ============================================================================
/*
================================================================================
  Growyze Integration — Infrastructure Setup
  File:    01_infrastructure.sql
  Date:    2026-03-05
  Purpose: Creates the reference schema and UOM_CONVERSION table required by
           Growyze staging and mapping scripts. Must be run against the core
           database before any other Growyze deployment scripts.

  Contents:
    1. Create [reference] schema (IF NOT EXISTS)
    2. Create [reference].[UOM_CONVERSION] table
    3. Seed 14 UOM conversion records (MERGE upsert — re-runnable)
================================================================================
*/

-- ============================================================================
-- 1. Create [reference] schema
-- ============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reference')
BEGIN
    EXEC(N'CREATE SCHEMA [reference]');
END
GO

-- ============================================================================
-- 2. Create [reference].[UOM_CONVERSION] table
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = N'reference' AND t.name = N'UOM_CONVERSION'
)
BEGIN
    CREATE TABLE [reference].[UOM_CONVERSION] (
        FROM_UOM          NVARCHAR(50)    NOT NULL,
        TO_UOM            NVARCHAR(50)    NOT NULL,
        CONVERSION_FACTOR DECIMAL(18,10)  NOT NULL,
        UOM_CATEGORY      NVARCHAR(20)    NOT NULL,
        IS_STANDARD       BIT             NOT NULL DEFAULT 0,
        NOTES             NVARCHAR(200)   NULL,
        CONSTRAINT PK_UOM_CONVERSION PRIMARY KEY (FROM_UOM, TO_UOM)
    );
END
GO

-- ============================================================================
-- 3. Seed UOM conversion records (14 rows)
-- ============================================================================

MERGE INTO [reference].[UOM_CONVERSION] AS tgt
USING (VALUES
    (N'ml',         N'ml',         1.0000000000,  N'VOLUME',  1),
    (N'cl',         N'ml',         10.0000000000, N'VOLUME',  0),
    (N'L',          N'ml',         1000.0000000000, N'VOLUME', 0),
    (N'fl_oz_UK',   N'ml',         28.4131000000, N'VOLUME',  0),
    (N'hf_pt_UK',   N'ml',         284.1310000000, N'VOLUME', 0),
    (N'pt_UK',      N'ml',         568.2610000000, N'VOLUME', 0),
    (N'gal',        N'ml',         4546.0900000000, N'VOLUME', 0),
    (N'g',          N'g',          1.0000000000,  N'WEIGHT',  1),
    (N'kg',         N'g',          1000.0000000000, N'WEIGHT', 0),
    (N'oz',         N'g',          28.3495000000, N'WEIGHT',  0),
    (N'each',       N'each',       1.0000000000,  N'COUNT',   1),
    (N'full',       N'each',       1.0000000000,  N'COUNT',   0),
    (N'portion',    N'portion',    1.0000000000,  N'SPECIAL', 1),
    (N'percentage', N'percentage', 1.0000000000,  N'SPECIAL', 1)
) AS src (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD)
ON tgt.FROM_UOM = src.FROM_UOM AND tgt.TO_UOM = src.TO_UOM
WHEN MATCHED THEN
    UPDATE SET
        CONVERSION_FACTOR = src.CONVERSION_FACTOR,
        UOM_CATEGORY      = src.UOM_CATEGORY,
        IS_STANDARD       = src.IS_STANDARD
WHEN NOT MATCHED THEN
    INSERT (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD)
    VALUES (src.FROM_UOM, src.TO_UOM, src.CONVERSION_FACTOR, src.UOM_CATEGORY, src.IS_STANDARD);
GO

GO

-- ============================================================================
-- SECTION 2 of 11: Staging Tier 1 (11 steps)
-- Source: 02_staging_tier1.sql
-- ============================================================================
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

GO

-- ============================================================================
-- SECTION 3 of 11: Staging Tier 2-3 (3 steps)
-- Source: 03_staging_tier2_3.sql
-- ============================================================================
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

GO

-- ============================================================================
-- SECTION 4 of 11: Entity Mappings (23 mappings: 9 hub + 14 link)
-- Source: 04_entity_mappings.sql
-- ============================================================================
/*
    Growyze Integration - Entity Mappings
    Target: [core].[int_growyze001].[EntityMappings]
    Date: 2026-03-05

    23 entity mappings total:
      - 9 hub mappings  (#1-#9)
      - 14 link mappings (#10-#23, with #23 having type2_columns)

    All statements use MERGE upsert pattern for idempotent re-runs.
*/

-- ============================================================================
-- HUB MAPPINGS (9)
-- ============================================================================

-- #1: INVITEM from GRYZ_INVITEMS
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM', N'GRYZ_INVITEMS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_NAME", "MICROSERVICE_ID", "INVITEM_ID"]',
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
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}]',
            N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_NAME", "MICROSERVICE_ID", "INVITEM_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #2: LOCATION from GRYZ_LOCATION
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LOCATION', N'GRYZ_LOCATION')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0002-4A00-B002-AE0FDE100002', N'LOCATION', N'GRYZ_LOCATION',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
            N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #3: SUPPLIER from GRYZ_SUPPLIERS
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'SUPPLIER', N'GRYZ_SUPPLIERS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_NAME", "hash": 0}, {"name": "SUPPLIER_ID", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0003-4A00-B003-AE0FDE100003', N'SUPPLIER', N'GRYZ_SUPPLIERS',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_NAME", "hash": 0}, {"name": "SUPPLIER_ID", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #4: PRODUCT from GRYZ_PRODUCT
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'PRODUCT', N'GRYZ_PRODUCT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0004-4A00-B004-AE0FDE100004', N'PRODUCT', N'GRYZ_PRODUCT',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #5: OCCASION from GRYZ_OCCASION
-- Note: OCCASSION_ID has double-S — platform typo preserved intentionally
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'OCCASION', N'GRYZ_OCCASION')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0005-4A00-B005-AE0FDE100005', N'OCCASION', N'GRYZ_OCCASION',
            N'[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
            N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #6: STOCKORDER from GRYZ_STOCKORDER
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'STOCKORDER', N'GRYZ_STOCKORDER')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0006-4A00-B006-AE0FDE100006', N'STOCKORDER', N'GRYZ_STOCKORDER',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}]',
            N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #7: STOCKEVENT from GRYZ_STOCKEVENT
-- Note: UOM_QUANTITY -> UOM_QUANITY and EVENT_BEHANIOUR -> EVENT_BEHAVIOUR (platform typos preserved)
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'STOCKEVENT', N'GRYZ_STOCKEVENT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "INTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHANIOUR", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0007-4A00-B007-AE0FDE100007', N'STOCKEVENT', N'GRYZ_STOCKEVENT',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "INTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHANIOUR", "hash": 0}]',
            N'["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #8: CUSTORDER from GRYZ_LINEITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_SALES", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE", "EXTERNAL_REFERENCE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0008-4A00-B008-AE0FDE100008', N'CUSTORDER', N'GRYZ_LINEITEM',
            N'[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_SALES", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}]',
            N'["HUB_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE", "EXTERNAL_REFERENCE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #9: LINEITEM from GRYZ_LINEITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0009-4A00-B009-AE0FDE100009', N'LINEITEM', N'GRYZ_LINEITEM',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
            N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- ============================================================================
-- LINK MAPPINGS (14)
-- ============================================================================

-- #10: CUSTORDER_LINEITEM from GRYZ_LINEITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER_LINEITEM', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]',
        entity_columns      = N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0010-4A00-B010-AE0FDE100010', N'CUSTORDER_LINEITEM', N'GRYZ_LINEITEM',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #11: CUSTORDER_LOCATION from GRYZ_LINEITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER_LOCATION', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}]',
        entity_columns      = N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0011-4A00-B011-AE0FDE100011', N'CUSTORDER_LOCATION', N'GRYZ_LINEITEM',
            N'[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}]',
            N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #12: CUSTORDER_OCCASION from GRYZ_LINEITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER_OCCASION', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
        entity_columns      = N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0012-4A00-B012-AE0FDE100012', N'CUSTORDER_OCCASION', N'GRYZ_LINEITEM',
            N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
            N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #13: LINEITEM_PRODUCT from GRYZ_LINEITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM_PRODUCT', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
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
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0013-4A00-B013-AE0FDE100013', N'LINEITEM_PRODUCT', N'GRYZ_LINEITEM',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #14: LINEITEM_OCCASION from GRYZ_LINEITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM_OCCASION', N'GRYZ_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
        entity_columns      = N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0014-4A00-B014-AE0FDE100014', N'LINEITEM_OCCASION', N'GRYZ_LINEITEM',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #15: INVITEM_INVITEM from GRYZ_PREP_RECIPES
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM_INVITEM', N'GRYZ_PREP_RECIPES')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        entity_columns      = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0015-4A00-B015-AE0FDE100015', N'INVITEM_INVITEM', N'GRYZ_PREP_RECIPES',
            N'[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
            N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #16: INVITEM_STOCKEVENT from GRYZ_STOCKEVENT
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM_STOCKEVENT', N'GRYZ_STOCKEVENT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        entity_columns      = N'["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0016-4A00-B016-AE0FDE100016', N'INVITEM_STOCKEVENT', N'GRYZ_STOCKEVENT',
            N'[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
            N'["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #17: INVITEM_STOCKORDER from GRYZ_ORDER_ITEMS
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM_STOCKORDER', N'GRYZ_ORDER_ITEMS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "ITEM_ID", "hash": 1}, {"name": "ORDER_ID", "hash": 1}, {"name": "items_quantity", "hash": 0}, {"name": "items_price", "hash": 0}, {"name": "items_estimatedCost", "hash": 0}, {"name": "items_orderInCase", "hash": 0}, {"name": "items_productCase_size", "hash": 0}, {"name": "items_productCase_price", "hash": 0}]',
        entity_columns      = N'["INVITEM_HUB_ID", "STOCKORDER_HUB_ID", "QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0017-4A00-B017-AE0FDE100017', N'INVITEM_STOCKORDER', N'GRYZ_ORDER_ITEMS',
            N'[{"name": "ITEM_ID", "hash": 1}, {"name": "ORDER_ID", "hash": 1}, {"name": "items_quantity", "hash": 0}, {"name": "items_price", "hash": 0}, {"name": "items_estimatedCost", "hash": 0}, {"name": "items_orderInCase", "hash": 0}, {"name": "items_productCase_size", "hash": 0}, {"name": "items_productCase_price", "hash": 0}]',
            N'["INVITEM_HUB_ID", "STOCKORDER_HUB_ID", "QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #18: LOCATION_STOCKEVENT from GRYZ_STOCKEVENT
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LOCATION_STOCKEVENT', N'GRYZ_STOCKEVENT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        entity_columns      = N'["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0018-4A00-B018-AE0FDE100018', N'LOCATION_STOCKEVENT', N'GRYZ_STOCKEVENT',
            N'[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
            N'["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #19: STOCKEVENT_STOCKORDER from GRYZ_DN_EVENTS
-- Note: Only DELIVERY events have ORDER_ID (from PO lookup). Source is GRYZ_DN_EVENTS, not GRYZ_STOCKEVENT.
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'STOCKEVENT_STOCKORDER', N'GRYZ_DN_EVENTS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ORDER_ID", "hash": 1}]',
        entity_columns      = N'["STOCKEVENT_HUB_ID", "STOCKORDER_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0019-4A00-B019-AE0FDE100019', N'STOCKEVENT_STOCKORDER', N'GRYZ_DN_EVENTS',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ORDER_ID", "hash": 1}]',
            N'["STOCKEVENT_HUB_ID", "STOCKORDER_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #20: DISTRIBUTOR_STOCKORDER_SUPPLIER from GRYZ_STOCKORDER
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'DISTRIBUTOR_STOCKORDER_SUPPLIER', N'GRYZ_STOCKORDER')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "DISTRIBUTOR_KEY", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_KEY", "hash": 1}]',
        entity_columns      = N'["DISTRIBUTOR_HUB_ID", "STOCKORDER_HUB_ID", "SUPPLIER_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0020-4A00-B020-AE0FDE100020', N'DISTRIBUTOR_STOCKORDER_SUPPLIER', N'GRYZ_STOCKORDER',
            N'[{"name": "DISTRIBUTOR_KEY", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_KEY", "hash": 1}]',
            N'["DISTRIBUTOR_HUB_ID", "STOCKORDER_HUB_ID", "SUPPLIER_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #21: INVITEM_LOCATION_OCCASION_PRODUCT from GRYZ_PRODUCT_INVITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM_LOCATION_OCCASION_PRODUCT', N'GRYZ_PRODUCT_INVITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        entity_columns      = N'["INVITEM_HUB_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0021-4A00-B021-AE0FDE100021', N'INVITEM_LOCATION_OCCASION_PRODUCT', N'GRYZ_PRODUCT_INVITEM',
            N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
            N'["INVITEM_HUB_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #22: INVITEM_OCCASION_PRODUCT from GRYZ_PRODUCT_INVITEM
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM_OCCASION_PRODUCT', N'GRYZ_PRODUCT_INVITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        entity_columns      = N'["INVITEM_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0022-4A00-B022-AE0FDE100022', N'INVITEM_OCCASION_PRODUCT', N'GRYZ_PRODUCT_INVITEM',
            N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
            N'["INVITEM_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #23: LOCATION_OCCASION_PRODUCT from GRYZ_PRODUCT
-- Note: This is the only mapping with type2_columns (NET_PRICE, NET_COST tracked for SCD Type 2)
MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LOCATION_OCCASION_PRODUCT', N'GRYZ_PRODUCT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "LOCATION_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "NET_PRICE", "hash": 0}, {"name": "NET_COST", "hash": 0}]',
        entity_columns      = N'["LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "PRODUCT_ID", "NET_PRICE", "NET_COST"]',
        type2_columns       = N'["NET_PRICE", "NET_COST"]',
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0023-4A00-B023-AE0FDE100023', N'LOCATION_OCCASION_PRODUCT', N'GRYZ_PRODUCT',
            N'[{"name": "LOCATION_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "NET_PRICE", "hash": 0}, {"name": "NET_COST", "hash": 0}]',
            N'["LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "PRODUCT_ID", "NET_PRICE", "NET_COST"]',
            N'["NET_PRICE", "NET_COST"]', NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

GO

-- ============================================================================
-- SECTION 5 of 11: INVITEM_STOCKORDER entity fix
-- Source: 05_invitem_stockorder_entity_fix.sql
-- ============================================================================
/*
    Growyze Integration - INVITEM_STOCKORDER Entity Fix
    Target: [core].[core].[DataVaultEntities] + client database tables
    Date: 2026-03-06

    Problem: INVITEM_STOCKORDER entity definition has empty ATTRIBUTE_NAMES/ATTRIBUTE_TYPES.
    MarketMan's mapping only uses hub keys (no satellites), so the entity was created without
    attributes. Growyze mapping #17 maps 6 satellite columns (QUANTITY, PRICE, ESTIMATED_COST,
    ORDER_IN_CASE, CASE_SIZE, CASE_PRICE) which don't exist in the load/SAT_LNK tables.

    Error: LOG_DV id=191 "Process failed with error 207: Invalid column name 'QUANTITY'."

    Fix:
      Step 1 - Update DataVaultEntities to add the 6 satellite attributes
      Step 2 - Run sp_GenerateDataVaultTables to create SAT_LNK_INVITEM_STOCKORDER (new table)
      Step 3 - ALTER the existing load.INVITEM_STOCKORDER table to add missing columns
               (sp_GenerateDataVaultTables won't modify existing tables — IF NOT EXISTS guard)

    Deploy: Run Step 1 against core, then Step 2+3 against each affected org database.
*/

-- ============================================================================
-- STEP 1: Update entity definition (run against core)
-- ============================================================================

UPDATE [core].[core].[DataVaultEntities]
SET ATTRIBUTE_NAMES = N'["QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]',
    ATTRIBUTE_TYPES = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line quantity"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line price"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Estimated cost of order line"}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": "Whether item is ordered by case"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case size for case orders"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case price for case orders"}]',
    UPDATED_AT = GETDATE()
WHERE ENTITY_NAME = 'INVITEM_STOCKORDER'
  AND RELEASE_STATE = 'Live';

-- ============================================================================
-- STEP 2: Run sp_GenerateDataVaultTables for the target org
-- This creates SAT_LNK_INVITEM_STOCKORDER (new table) but won't modify existing tables
-- ============================================================================

-- EXEC [core].[core].[sp_GenerateDataVaultTables] @DatabaseName = '20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14', @SchemaName = 'datavault', @ExecuteSQL = 1;

-- ============================================================================
-- STEP 3: ALTER existing load table to add missing satellite columns
-- sp_GenerateDataVaultTables skips existing tables (IF NOT EXISTS guard),
-- so we must add columns manually.
-- Run against each affected org database.
-- ============================================================================

-- Drop and recreate the load table (it's a transient working table, safe to recreate)
-- This is simpler than 6 individual ALTER ADD statements + PK rebuild

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[load].[INVITEM_STOCKORDER]') AND type in (N'U'))
BEGIN
    DROP TABLE [load].[INVITEM_STOCKORDER];
END;

CREATE TABLE [load].[INVITEM_STOCKORDER] (
    [LNK_ID] [BINARY](32) NOT NULL,
    [SRC] [NVARCHAR](255) NOT NULL,
    [LOAD_TS] [DATETIME2](7) NOT NULL,
    [INVITEM_HUB_ID] [BINARY](32) NOT NULL,
    [STOCKORDER_HUB_ID] [BINARY](32) NOT NULL,
    [QUANTITY] DECIMAL(38,10) NULL,
    [PRICE] DECIMAL(38,10) NULL,
    [ESTIMATED_COST] DECIMAL(38,10) NULL,
    [ORDER_IN_CASE] NVARCHAR(255) NULL,
    [CASE_SIZE] DECIMAL(38,10) NULL,
    [CASE_PRICE] DECIMAL(38,10) NULL,

    CONSTRAINT [PK_LOAD_INVITEM_STOCKORDER] PRIMARY KEY CLUSTERED ([LNK_ID] ASC, [LOAD_TS] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
    ON [PRIMARY]
) ON [PRIMARY];

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[load].[INVITEM_STOCKORDER]') AND name = N'IX_LOAD_INVITEM_STOCKORDER_LOAD_TS')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LOAD_INVITEM_STOCKORDER_LOAD_TS]
    ON [load].[INVITEM_STOCKORDER] ([LOAD_TS] ASC);
END;

GO

-- ============================================================================
-- SECTION 6 of 11: F_PURCHASES_DAY presentation table DDL
-- Source: 06_purchases_presentation_table.sql
-- ============================================================================
-- F_PURCHASES_DAY Presentation Table DDL
-- Inserts the table definition into core.PresentationTables
-- Prerequisite: 05_invitem_stockorder_entity_fix.sql deployed
-- Uses MERGE upsert pattern per CLAUDE.md rules

MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'F_PURCHASES_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_PURCHASES_DAY](
    [INVITEM_HUB_ID]      [binary](32)      NOT NULL,
    [SUPPLIER_HUB_ID]     [binary](32)      NOT NULL,
    [LOCATION_HUB_ID]     [binary](32)      NOT NULL,
    [STOCKORDER_HUB_ID]   [binary](32)      NOT NULL,
    [ORDER_DATE]           [datetime2](7)    NULL,
    [DELIVERY_DATE]        [datetime2](7)    NULL,
    [ORDER_STATUS]         [nvarchar](255)   NULL,
    [UNIT_PRICE]           [decimal](38, 6)  NULL,
    [UNIT_COST]            [decimal](38, 6)  NULL,
    [ORDER_QTY]            [decimal](38, 6)  NULL,
    [LINE_TOTAL]           [decimal](38, 6)  NULL,
    [PACK_SIZE]            [decimal](38, 6)  NULL,
    [PACK_PRICE]           [decimal](38, 6)  NULL,
    [ORDER_REFERENCE]      [nvarchar](255)   NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_PURCHASES_DAY-CLUSTERED] ON [presentation].[F_PURCHASES_DAY]
(
    [ORDER_DATE] ASC,
    [LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-INVITEM] ON [presentation].[F_PURCHASES_DAY]
(
    [INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-SUPPLIER] ON [presentation].[F_PURCHASES_DAY]
(
    [SUPPLIER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
    N'[
        {"name": "INVITEM_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Inventory item hub key"},
        {"name": "SUPPLIER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Supplier hub key"},
        {"name": "LOCATION_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Location hub key (resolved via delivery event)"},
        {"name": "STOCKORDER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Stock order hub key"},
        {"name": "ORDER_DATE", "type": "datetime2(7)", "nullable": true, "description": "Order placement date"},
        {"name": "DELIVERY_DATE", "type": "datetime2(7)", "nullable": true, "description": "Expected delivery date"},
        {"name": "ORDER_STATUS", "type": "nvarchar(255)", "nullable": true, "description": "Order status"},
        {"name": "UNIT_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Unit price per item"},
        {"name": "UNIT_COST", "type": "decimal(38,6)", "nullable": true, "description": "Estimated unit cost"},
        {"name": "ORDER_QTY", "type": "decimal(38,6)", "nullable": true, "description": "Quantity ordered"},
        {"name": "LINE_TOTAL", "type": "decimal(38,6)", "nullable": true, "description": "Line total (qty * price)"},
        {"name": "PACK_SIZE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack size"},
        {"name": "PACK_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack price"},
        {"name": "ORDER_REFERENCE", "type": "nvarchar(255)", "nullable": true, "description": "PO number / order reference"}
    ]',
    N'Purchase order line items by day. One row per inventory item per stock order. Provides per-item purchase pricing, supplier spend analysis, and delivery tracking.',
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.schema_name = src.schema_name
WHEN MATCHED THEN
    UPDATE SET
        ddl_script = src.ddl_script,
        column_definitions = src.column_definitions,
        description = src.description,
        version = src.version,
        status = src.status,
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

GO

-- ============================================================================
-- SECTION 7 of 11: F_PURCHASES_DAY presentation control build
-- Source: 07_purchases_presentation_control.sql
-- ============================================================================
-- F_PURCHASES_DAY PresentationControl Build Step
-- Inserts the build query into core.PresentationControl
-- Prerequisite: 06_purchases_presentation_table.sql deployed
-- Uses MERGE upsert pattern per CLAUDE.md rules

MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'Purchases by Day',
    N'F_PURCHASES_DAY',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_END'';

WITH OrderLines AS (
    SELECT
        LIS.INVITEM_HUB_ID,
        LIS.STOCKORDER_HUB_ID,
        SL.QUANTITY,
        SL.PRICE,
        SL.ESTIMATED_COST,
        SL.CASE_SIZE,
        SL.CASE_PRICE,
        ROW_NUMBER() OVER(PARTITION BY LIS.LNK_ID ORDER BY SL.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_INVITEM_STOCKORDER] LIS
    INNER JOIN [datavault].[SAT_LNK_INVITEM_STOCKORDER] SL
        ON LIS.LNK_ID = SL.LNK_ID
),
Orders AS (
    SELECT
        SO.HUB_ID,
        SO.ORDER_DATE,
        SO.DELIVERY_DATE,
        SO.ORDER_STATUS,
        SO.ORDER_INFO
    FROM [datavault].[SAT_STOCKORDER] SO
    WHERE SO.CURRENT_FLAG = 1
      AND SO.ORDER_DATE BETWEEN @StartDate AND @EndDate
),
OrderSupplier AS (
    SELECT
        DSS.STOCKORDER_HUB_ID,
        DSS.SUPPLIER_HUB_ID
    FROM [datavault].[LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER] DSS
),
OrderLocation AS (
    SELECT
        LSESO.STOCKORDER_HUB_ID,
        LLSE.LOCATION_HUB_ID,
        ROW_NUMBER() OVER(PARTITION BY LSESO.STOCKORDER_HUB_ID
                          ORDER BY LLSE.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_STOCKEVENT_STOCKORDER] LSESO
    INNER JOIN [datavault].[LNK_LOCATION_STOCKEVENT] LLSE
        ON LSESO.STOCKEVENT_HUB_ID = LLSE.STOCKEVENT_HUB_ID
)

SELECT
    OL.INVITEM_HUB_ID,
    ISNULL(OS.SUPPLIER_HUB_ID, CONVERT(BINARY(32), -999)) AS SUPPLIER_HUB_ID,
    ISNULL(OLOC.LOCATION_HUB_ID, CONVERT(BINARY(32), -999)) AS LOCATION_HUB_ID,
    OL.STOCKORDER_HUB_ID,
    O.ORDER_DATE,
    O.DELIVERY_DATE,
    O.ORDER_STATUS,
    OL.PRICE AS UNIT_PRICE,
    OL.ESTIMATED_COST AS UNIT_COST,
    OL.QUANTITY AS ORDER_QTY,
    OL.QUANTITY * OL.PRICE AS LINE_TOTAL,
    OL.CASE_SIZE AS PACK_SIZE,
    OL.CASE_PRICE AS PACK_PRICE,
    O.ORDER_INFO AS ORDER_REFERENCE

FROM OrderLines OL
INNER JOIN Orders O
    ON OL.STOCKORDER_HUB_ID = O.HUB_ID
LEFT JOIN OrderSupplier OS
    ON OL.STOCKORDER_HUB_ID = OS.STOCKORDER_HUB_ID
LEFT JOIN OrderLocation OLOC
    ON OL.STOCKORDER_HUB_ID = OLOC.STOCKORDER_HUB_ID
    AND OLOC.rn = 1

WHERE OL.rn = 1',
    1,
    N'Fact',
    N'[
        {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "SUPPLIER_HUB_ID", "table_column": "SUPPLIER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "STOCKORDER_HUB_ID", "table_column": "STOCKORDER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "datetime2(7)"},
        {"query_column": "DELIVERY_DATE", "table_column": "DELIVERY_DATE", "data_type": "datetime2(7)"},
        {"query_column": "ORDER_STATUS", "table_column": "ORDER_STATUS", "data_type": "nvarchar(255)"},
        {"query_column": "UNIT_PRICE", "table_column": "UNIT_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "UNIT_COST", "table_column": "UNIT_COST", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "decimal(38,6)"},
        {"query_column": "LINE_TOTAL", "table_column": "LINE_TOTAL", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_SIZE", "table_column": "PACK_SIZE", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_PRICE", "table_column": "PACK_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_REFERENCE", "table_column": "ORDER_REFERENCE", "data_type": "nvarchar(255)"}
    ]',
    0,
    100,
    3,
    30,
    N'Purchase order line items. Joins INVITEM_STOCKORDER link satellite (qty, price, cost) with STOCKORDER dates/status, SUPPLIER via ternary link, and LOCATION via delivery event chain. Filtered by STOCKEVENT_START/END date range.',
    N'Claude',
    GETDATE(),
    GETDATE(),
    N'STOCKEVENT',
    N'ORDER_DATE'
)) AS src (step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.step_name = src.step_name AND tgt.table_name = src.table_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = src.query_sql,
        tier = src.tier,
        table_type = src.table_type,
        column_mappings = src.column_mappings,
        exclude = src.exclude,
        priority = src.priority,
        description = src.description,
        time_series_entity = src.time_series_entity,
        time_series_target_column = src.time_series_target_column,
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
    VALUES (src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

GO

-- ============================================================================
-- SECTION 8 of 11: Presentation filter fix (POS → POS+INVENTORY)
-- Source: 08_presentation_filter_fix.sql
-- ============================================================================
-- ============================================================
-- Growyze Reporting: P1 — Presentation Filter Fix
-- Created: 2026-03-08
--
-- CRITICAL BLOCKER: F_LINEITEM_15MIN and F_PRODUCT_MARGIN_DAY
-- build steps filter on IntegrationType = 'POS', which excludes
-- Growyze data (registered as INVENTORY type).
--
-- Fix: Change the filter to IN ('POS', 'INVENTORY') so both
-- POS and inventory-type integrations flow into these fact tables.
-- Safe because INNER JOIN on SAT_LINEITEM.SRC guards against
-- integrations that have no LINEITEM data.
--
-- Idempotent: WHERE clause checks the old pattern still exists.
-- Re-running after the fix has been applied is a no-op.
-- ============================================================

-- Fix F_LINEITEM_15MIN build step
-- step_name = 'F_LINEITEM_15MIN'
UPDATE [core].[PresentationControl]
SET query_sql = CAST(REPLACE(
        CAST(query_sql AS NVARCHAR(MAX)),
        N'IG.[IntegrationType] = ''POS''',
        N'IG.[IntegrationType] IN (''POS'', ''INVENTORY'')'
    ) AS TEXT),
    updated_at = GETDATE()
WHERE step_name = N'F_LINEITEM_15MIN'
  AND CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%[[]IntegrationType] = ''POS''%';

-- Fix F_PRODUCT_MARGIN_DAY build step
-- step_name = 'Product Margins by Day'
UPDATE [core].[PresentationControl]
SET query_sql = CAST(REPLACE(
        CAST(query_sql AS NVARCHAR(MAX)),
        N'IG.[IntegrationType] = ''POS''',
        N'IG.[IntegrationType] IN (''POS'', ''INVENTORY'')'
    ) AS TEXT),
    updated_at = GETDATE()
WHERE step_name = N'Product Margins by Day'
  AND CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%[[]IntegrationType] = ''POS''%';

GO

-- ============================================================================
-- SECTION 9 of 11: Phase 1 vis queries part 1 (8 records)
-- Source: 09_phase1_vis_queries_part1.sql
-- ============================================================================
/*
    09_phase1_vis_queries_part1.sql
    ================================
    Growyze Phase 1 Visualisation Queries — Part 1 (Datasets 1-4)

    Creates 7 VisualisationQueries records:
        1a. InvCOGSByCategory   — PieChartCard
        1b. InvCOGSByCategory   — StackedBarChartCard
        2a. InvConsumption      — BarChartCard
        2b. InvConsumption      — CustomDataGrid
        3a. InvWasteAnalysis    — BarChartCard
        3b. InvWasteAnalysis    — MultiLineChartCard
        3c. InvWasteAnalysis    — CustomDataGrid
        4.  ProductComparison   — CustomDataGrid

    Uses MERGE upsert on natural key (DataSetName, VisualizationType, Version).
    Run against: core database
    Idempotent: Yes
*/

-- =============================================================================
-- 1a. InvCOGSByCategory — PieChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvCOGSByCategory',
        N'PieChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT
    CATEGORY AS Label, COGS AS Value,
    ROW_NUMBER() OVER(ORDER BY COGS DESC) AS Id,
    ''linear'' AS Curve, ''total'' AS Stack, ''true'' AS Area,
    ''ascending'' AS StackOrder, ''false'' AS ShowMark, ''COGS'' AS LegendLabel
FROM Base
WHERE CATEGORY IS NOT NULL

SELECT
    ''COGS by Category'' AS Title,
    ''Based on recipe cost'' AS Description,
    NULL AS Trend, NULL AS Chip,
    (SELECT FORMAT(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),''N0'')
     FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
     INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     WHERE 1=1 AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL @FilterClause) AS PiePrimaryText,
    ''Total COGS'' AS PieSecondaryText',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvCOGSByCategory',
        N'PieChartCard',
        1,
        N'LIVE',
        N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT
    CATEGORY AS Label, COGS AS Value,
    ROW_NUMBER() OVER(ORDER BY COGS DESC) AS Id,
    ''linear'' AS Curve, ''total'' AS Stack, ''true'' AS Area,
    ''ascending'' AS StackOrder, ''false'' AS ShowMark, ''COGS'' AS LegendLabel
FROM Base
WHERE CATEGORY IS NOT NULL

SELECT
    ''COGS by Category'' AS Title,
    ''Based on recipe cost'' AS Description,
    NULL AS Trend, NULL AS Chip,
    (SELECT FORMAT(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),''N0'')
     FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
     INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     WHERE 1=1 AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL @FilterClause) AS PiePrimaryText,
    ''Total COGS'' AS PieSecondaryText',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 1b. InvCOGSByCategory — StackedBarChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvCOGSByCategory',
        N'StackedBarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS,
        SUM(ISNULL(F.[NET_VALUE],0)) AS REVENUE,
        SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS GP
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[NET_VALUE],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT CATEGORY, ''COGS'' AS Label, COGS AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
    UNION ALL
    SELECT CATEGORY, ''Gross Profit'' AS Label, GP AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
) SUB

SELECT ''Category'' AS XAxisLabel, ''Value'' AS YAxisLabel,
    ''COGS vs Gross Profit by Category'' AS Title,
    ''Based on recipe cost'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvCOGSByCategory',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS,
        SUM(ISNULL(F.[NET_VALUE],0)) AS REVENUE,
        SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS GP
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[NET_VALUE],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT CATEGORY, ''COGS'' AS Label, COGS AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
    UNION ALL
    SELECT CATEGORY, ''Gross Profit'' AS Label, GP AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
) SUB

SELECT ''Category'' AS XAxisLabel, ''Value'' AS YAxisLabel,
    ''COGS vs Gross Profit by Category'' AS Title,
    ''Based on recipe cost'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 2a. InvConsumption — BarChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvConsumption',
        N'BarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarLabelSort,
    TOTAL_USAGE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS TOTAL_USAGE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_USAGE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Consumption Quantity'' AS YAxisLabel,
    ''Top 20 Items by Consumption'' AS Title,
    ''Volume-based ranking (units consumed via sales)'' AS Description,
    NULL AS Trend, NULL AS TotalValue, NULL AS Chip',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvConsumption',
        N'BarChartCard',
        1,
        N'LIVE',
        N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarLabelSort,
    TOTAL_USAGE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS TOTAL_USAGE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_USAGE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Consumption Quantity'' AS YAxisLabel,
    ''Top 20 Items by Consumption'' AS Title,
    ''Volume-based ranking (units consumed via sales)'' AS Description,
    NULL AS Trend, NULL AS TotalValue, NULL AS Chip',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 2b. InvConsumption — CustomDataGrid
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvConsumption',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column4,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Column5,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column6,
    SUM(ISNULL(FU.[ORDER_QTY],0)) AS Column7,
    SUM(ABS(ISNULL(FU.[PRODUCTION_QTY],0))) AS Column8,
    SUM(ABS(ISNULL(FU.[TRANSFER_QTY],0))) AS Column9,
    MAX(FU.[STANDARDISED_UOM]) AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]),
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]),
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])

SELECT
    ''Consumption Detail'' AS [Title],
    ''Volume-based consumption tracking by item'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Subcategory'' AS [Label3], ''TEXT'' AS [Type3],
    ''Item'' AS [Label4], ''TEXT'' AS [Type4],
    ''Sales Qty'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Waste Qty'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''Order Qty'' AS [Label7], ''DECIMAL'' AS [Type7],
    ''Production Qty'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''Transfer Qty'' AS [Label9], ''DECIMAL'' AS [Type9],
    ''UOM'' AS [Label10], ''TEXT'' AS [Type10],
    NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvConsumption',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column4,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Column5,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column6,
    SUM(ISNULL(FU.[ORDER_QTY],0)) AS Column7,
    SUM(ABS(ISNULL(FU.[PRODUCTION_QTY],0))) AS Column8,
    SUM(ABS(ISNULL(FU.[TRANSFER_QTY],0))) AS Column9,
    MAX(FU.[STANDARDISED_UOM]) AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]),
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]),
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])

SELECT
    ''Consumption Detail'' AS [Title],
    ''Volume-based consumption tracking by item'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Subcategory'' AS [Label3], ''TEXT'' AS [Type3],
    ''Item'' AS [Label4], ''TEXT'' AS [Type4],
    ''Sales Qty'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Waste Qty'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''Order Qty'' AS [Label7], ''DECIMAL'' AS [Type7],
    ''Production Qty'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''Transfer Qty'' AS [Label9], ''DECIMAL'' AS [Type9],
    ''UOM'' AS [Label10], ''TEXT'' AS [Type10],
    NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 3a. InvWasteAnalysis — BarChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWasteAnalysis',
        N'BarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarLabelSort,
    TOTAL_WASTE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS TOTAL_WASTE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_WASTE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Top 20 Items by Waste'' AS Title,
    ''Volume-based waste ranking'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))),''N0'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause) AS TotalValue,
    NULL AS Chip',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvWasteAnalysis',
        N'BarChartCard',
        1,
        N'LIVE',
        N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarLabelSort,
    TOTAL_WASTE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS TOTAL_WASTE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_WASTE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Top 20 Items by Waste'' AS Title,
    ''Volume-based waste ranking'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))),''N0'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause) AS TotalValue,
    NULL AS Chip',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 3b. InvWasteAnalysis — MultiLineChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWasteAnalysis',
        N'MultiLineChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    ''line'' AS VisType,
    LegendLabel
FROM (
    SELECT
        CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Week] AS XAxisSort,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value,
        DENSE_RANK() OVER(ORDER BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])) AS VisId,
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS LegendLabel
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY
        CONCAT(''W'', C.[Week], '' '', C.[Year]),
        C.[Year] * 100 + C.[Week],
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB

SELECT ''Week'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Weekly Waste Trend by Category'' AS Title,
    ''Volume-based waste tracking over time'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvWasteAnalysis',
        N'MultiLineChartCard',
        1,
        N'LIVE',
        N'SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    ''line'' AS VisType,
    LegendLabel
FROM (
    SELECT
        CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Week] AS XAxisSort,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value,
        DENSE_RANK() OVER(ORDER BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])) AS VisId,
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS LegendLabel
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY
        CONCAT(''W'', C.[Week], '' '', C.[Year]),
        C.[Year] * 100 + C.[Week],
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB

SELECT ''Week'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Weekly Waste Trend by Category'' AS Title,
    ''Volume-based waste tracking over time'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 3c. InvWasteAnalysis — CustomDataGrid
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWasteAnalysis',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column3,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column4,
    MAX(FU.[STANDARDISED_UOM]) AS Column5,
    NULL AS Column6, NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]),
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])

SELECT
    ''Waste Detail'' AS [Title],
    ''Volume-based waste tracking'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Item'' AS [Label3], ''TEXT'' AS [Type3],
    ''Waste Qty'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''UOM'' AS [Label5], ''TEXT'' AS [Type5],
    NULL AS [Label6], NULL AS [Type6],
    NULL AS [Label7], NULL AS [Type7],
    NULL AS [Label8], NULL AS [Type8],
    NULL AS [Label9], NULL AS [Type9],
    NULL AS [Label10], NULL AS [Type10],
    NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvWasteAnalysis',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column3,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column4,
    MAX(FU.[STANDARDISED_UOM]) AS Column5,
    NULL AS Column6, NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]),
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])

SELECT
    ''Waste Detail'' AS [Title],
    ''Volume-based waste tracking'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Item'' AS [Label3], ''TEXT'' AS [Type3],
    ''Waste Qty'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''UOM'' AS [Label5], ''TEXT'' AS [Type5],
    NULL AS [Label6], NULL AS [Type6],
    NULL AS [Label7], NULL AS [Type7],
    NULL AS [Label8], NULL AS [Type8],
    NULL AS [Label9], NULL AS [Type9],
    NULL AS [Label10], NULL AS [Type10],
    NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 4. ProductComparison — CustomDataGrid
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ProductComparison',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS Column2,
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS Column4,
    SUM(F.[QUANTITY]) AS Column5,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Column6,
    ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column7,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column8,
    CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
         ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
    END AS Column9,
    MAX(F.[AVG_NET_PRICE]) AS Column10,
    MAX(F.[AVG_NET_COST]) AS Column11,
    NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
@FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]),
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]),
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])

SELECT
    ''Product Comparison'' AS [Title],
    ''Side-by-side product performance. COGS based on recipe cost.'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Subcategory'' AS [Label3], ''TEXT'' AS [Type3],
    ''Product'' AS [Label4], ''TEXT'' AS [Type4],
    ''Qty Sold'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Revenue'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''COGS'' AS [Label7], ''DECIMAL'' AS [Type7],
    ''Profit'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''GP%'' AS [Label9], ''DECIMAL'' AS [Type9],
    ''Menu Price'' AS [Label10], ''DECIMAL'' AS [Type10],
    ''Recipe Cost'' AS [Label11], ''DECIMAL'' AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ProductComparison',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS Column2,
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS Column4,
    SUM(F.[QUANTITY]) AS Column5,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Column6,
    ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column7,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column8,
    CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
         ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
    END AS Column9,
    MAX(F.[AVG_NET_PRICE]) AS Column10,
    MAX(F.[AVG_NET_COST]) AS Column11,
    NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
@FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]),
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]),
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])

SELECT
    ''Product Comparison'' AS [Title],
    ''Side-by-side product performance. COGS based on recipe cost.'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Subcategory'' AS [Label3], ''TEXT'' AS [Type3],
    ''Product'' AS [Label4], ''TEXT'' AS [Type4],
    ''Qty Sold'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Revenue'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''COGS'' AS [Label7], ''DECIMAL'' AS [Type7],
    ''Profit'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''GP%'' AS [Label9], ''DECIMAL'' AS [Type9],
    ''Menu Price'' AS [Label10], ''DECIMAL'' AS [Type10],
    ''Recipe Cost'' AS [Label11], ''DECIMAL'' AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

GO

-- ============================================================================
-- SECTION 10 of 11: Phase 1 vis queries part 2 (6 records)
-- Source: 10_phase1_vis_queries_part2.sql
-- ============================================================================
-- =============================================================================
-- Growyze Phase 1 Visualisation Queries — Part 2 (Datasets 5-8)
-- 6 records: InvMarginTrend, InvMargeBrut, InvWeeklySummary (x2),
--            InvStockActivity (x2)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 5. InvMarginTrend — MultiLineChartCard
--    Monthly GP% and COGS% over time. Two lines via UNION ALL.
-- ---------------------------------------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvMarginTrend',
        N'MultiLineChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort, Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, ''line'' AS VisType, LegendLabel FROM ( SELECT CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Month] AS XAxisSort, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Value, 1 AS VisId, ''GP%'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Month], CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) UNION ALL SELECT CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Month] AS XAxisSort, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Value, 2 AS VisId, ''COGS%'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Month], CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) ) SUB SELECT ''Month'' AS XAxisLabel, ''Percentage'' AS YAxisLabel, ''Margin Trend'' AS Title, ''Monthly GP% and COGS% over time. Based on recipe cost.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        FilterDefinitions = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvMarginTrend',
        N'MultiLineChartCard',
        1,
        N'LIVE',
        N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort, Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, ''line'' AS VisType, LegendLabel FROM ( SELECT CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Month] AS XAxisSort, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Value, 1 AS VisId, ''GP%'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Month], CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) UNION ALL SELECT CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Month] AS XAxisSort, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Value, 2 AS VisId, ''COGS%'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Month], CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) ) SUB SELECT ''Month'' AS XAxisLabel, ''Percentage'' AS YAxisLabel, ''Margin Trend'' AS Title, ''Monthly GP% and COGS% over time. Based on recipe cost.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- ---------------------------------------------------------------------------
-- 6. InvMargeBrut — CustomGroupedDataGrid
--    Two-level hierarchy: child rows (category within location), parent rows
--    (location) with turnover/recipe COGS/GP%.
-- ---------------------------------------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvMargeBrut',
        N'CustomGroupedDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Revenue AS ( SELECT F.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, SUM(ISNULL(F.[NET_VALUE],0)) AS TURNOVER, SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS RECIPE_COGS, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS GP_PERC FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY F.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) ), Usage AS ( SELECT FU.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY, SUM(ISNULL(FU.[ORDER_QTY],0)) AS PURCHASE_QTY, SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS CONSUMPTION_QTY, SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS WASTE_QTY FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY FU.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]), COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) ) SELECT U.LOCATION_NAME AS ParentId, CONCAT_WS(''-'', U.LOCATION_NAME, U.CATEGORY) AS Id, U.CATEGORY AS GroupedColumn, U.PURCHASE_QTY AS Column1, U.CONSUMPTION_QTY AS Column2, U.WASTE_QTY AS Column3, NULL AS Column4, NULL AS Column5, NULL AS Column6, NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29 FROM Usage U UNION ALL SELECT NULL AS ParentId, R.LOCATION_NAME AS Id, R.LOCATION_NAME AS GroupedColumn, R.TURNOVER AS Column1, R.RECIPE_COGS AS Column2, R.GP_PERC AS Column3, SUM(U.PURCHASE_QTY) AS Column4, SUM(U.CONSUMPTION_QTY) AS Column5, SUM(U.WASTE_QTY) AS Column6, NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29 FROM Revenue R LEFT JOIN Usage U ON R.LOCATION_HUB_ID = U.LOCATION_HUB_ID GROUP BY R.LOCATION_NAME, R.TURNOVER, R.RECIPE_COGS, R.GP_PERC SELECT ''Gross Margin Summary'' AS [Title], ''Turnover and recipe COGS at location level; purchase/waste/consumption volumes by category. Based on recipe cost.'' AS [Description], ''Purchases Qty'' AS [Label1], ''DECIMAL'' AS [Type1], ''Consumption Qty'' AS [Label2], ''DECIMAL'' AS [Type2], ''Waste Qty'' AS [Label3], ''DECIMAL'' AS [Type3], ''Turnover'' AS [Label4], ''DECIMAL'' AS [Type4], ''Recipe COGS'' AS [Label5], ''DECIMAL'' AS [Type5], ''GP%'' AS [Label6], ''DECIMAL'' AS [Type6], NULL AS [Label7], NULL AS [Type7], NULL AS [Label8], NULL AS [Type8], NULL AS [Label9], NULL AS [Type9], NULL AS [Label10], NULL AS [Type10], NULL AS [Label11], NULL AS [Type11], NULL AS [Label12], NULL AS [Type12], NULL AS [Label13], NULL AS [Type13], NULL AS [Label14], NULL AS [Type14], NULL AS [Label15], NULL AS [Type15], NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17], NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19], NULL AS [Label20], NULL AS [Type20], NULL AS [Label21], NULL AS [Type21], NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23], NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25], NULL AS [Label26], NULL AS [Type26], NULL AS [Label27], NULL AS [Type27], NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29]',
        ParameterMappings = N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        FilterDefinitions = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvMargeBrut',
        N'CustomGroupedDataGrid',
        1,
        N'LIVE',
        N'WITH Revenue AS ( SELECT F.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, SUM(ISNULL(F.[NET_VALUE],0)) AS TURNOVER, SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS RECIPE_COGS, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS GP_PERC FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY F.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) ), Usage AS ( SELECT FU.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY, SUM(ISNULL(FU.[ORDER_QTY],0)) AS PURCHASE_QTY, SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS CONSUMPTION_QTY, SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS WASTE_QTY FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY FU.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]), COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) ) SELECT U.LOCATION_NAME AS ParentId, CONCAT_WS(''-'', U.LOCATION_NAME, U.CATEGORY) AS Id, U.CATEGORY AS GroupedColumn, U.PURCHASE_QTY AS Column1, U.CONSUMPTION_QTY AS Column2, U.WASTE_QTY AS Column3, NULL AS Column4, NULL AS Column5, NULL AS Column6, NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29 FROM Usage U UNION ALL SELECT NULL AS ParentId, R.LOCATION_NAME AS Id, R.LOCATION_NAME AS GroupedColumn, R.TURNOVER AS Column1, R.RECIPE_COGS AS Column2, R.GP_PERC AS Column3, SUM(U.PURCHASE_QTY) AS Column4, SUM(U.CONSUMPTION_QTY) AS Column5, SUM(U.WASTE_QTY) AS Column6, NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29 FROM Revenue R LEFT JOIN Usage U ON R.LOCATION_HUB_ID = U.LOCATION_HUB_ID GROUP BY R.LOCATION_NAME, R.TURNOVER, R.RECIPE_COGS, R.GP_PERC SELECT ''Gross Margin Summary'' AS [Title], ''Turnover and recipe COGS at location level; purchase/waste/consumption volumes by category. Based on recipe cost.'' AS [Description], ''Purchases Qty'' AS [Label1], ''DECIMAL'' AS [Type1], ''Consumption Qty'' AS [Label2], ''DECIMAL'' AS [Type2], ''Waste Qty'' AS [Label3], ''DECIMAL'' AS [Type3], ''Turnover'' AS [Label4], ''DECIMAL'' AS [Type4], ''Recipe COGS'' AS [Label5], ''DECIMAL'' AS [Type5], ''GP%'' AS [Label6], ''DECIMAL'' AS [Type6], NULL AS [Label7], NULL AS [Type7], NULL AS [Label8], NULL AS [Type8], NULL AS [Label9], NULL AS [Type9], NULL AS [Label10], NULL AS [Type10], NULL AS [Label11], NULL AS [Type11], NULL AS [Label12], NULL AS [Type12], NULL AS [Label13], NULL AS [Type13], NULL AS [Label14], NULL AS [Type14], NULL AS [Label15], NULL AS [Type15], NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17], NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19], NULL AS [Label20], NULL AS [Type20], NULL AS [Label21], NULL AS [Type21], NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23], NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25], NULL AS [Label26], NULL AS [Type26], NULL AS [Label27], NULL AS [Type27], NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29]',
        N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- ---------------------------------------------------------------------------
-- 7a. InvWeeklySummary — CombinedChartCard
--     Weekly: Revenue (bar), Recipe COGS (bar), GP% (line).
-- ---------------------------------------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWeeklySummary',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort, Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, VisType, LegendLabel FROM ( SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Value, 1 AS VisId, ''bar'' AS VisType, ''Revenue'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Value, 2 AS VisId, ''bar'' AS VisType, ''Recipe COGS'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Value, 3 AS VisId, ''line'' AS VisType, ''GP%'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) ) SUB SELECT ''Week'' AS XAxisLabel, ''Value'' AS YAxisLabel, ''Weekly Sales & Costs'' AS Title, ''Revenue and recipe COGS by week with GP% trend. Based on recipe cost.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        FilterDefinitions = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvWeeklySummary',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort, Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, VisType, LegendLabel FROM ( SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Value, 1 AS VisId, ''bar'' AS VisType, ''Revenue'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Value, 2 AS VisId, ''bar'' AS VisType, ''Recipe COGS'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Value, 3 AS VisId, ''line'' AS VisType, ''GP%'' AS LegendLabel FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) ) SUB SELECT ''Week'' AS XAxisLabel, ''Value'' AS YAxisLabel, ''Weekly Sales & Costs'' AS Title, ''Revenue and recipe COGS by week with GP% trend. Based on recipe cost.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- ---------------------------------------------------------------------------
-- 7b. InvWeeklySummary — CustomDataGrid
--     Weekly sales and costs by location.
-- ---------------------------------------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWeeklySummary',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS Column1, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column2, SUM(ISNULL(F.[QUANTITY],0)) AS Column3, ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Column4, ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column5, ROUND(SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column6, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29 FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]), COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) ORDER BY C.[Year], C.[Week] SELECT ''Weekly Summary'' AS [Title], ''Weekly sales and costs by location. Based on recipe cost.'' AS [Description], ''Week'' AS [Label1], ''TEXT'' AS [Type1], ''Location'' AS [Label2], ''TEXT'' AS [Type2], ''Qty Sold'' AS [Label3], ''DECIMAL'' AS [Type3], ''Revenue'' AS [Label4], ''DECIMAL'' AS [Type4], ''Recipe COGS'' AS [Label5], ''DECIMAL'' AS [Type5], ''Profit'' AS [Label6], ''DECIMAL'' AS [Type6], ''GP%'' AS [Label7], ''DECIMAL'' AS [Type7], NULL AS [Label8], NULL AS [Type8], NULL AS [Label9], NULL AS [Type9], NULL AS [Label10], NULL AS [Type10], NULL AS [Label11], NULL AS [Type11], NULL AS [Label12], NULL AS [Type12], NULL AS [Label13], NULL AS [Type13], NULL AS [Label14], NULL AS [Type14], NULL AS [Label15], NULL AS [Type15], NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17], NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19], NULL AS [Label20], NULL AS [Type20], NULL AS [Label21], NULL AS [Type21], NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23], NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25], NULL AS [Label26], NULL AS [Type26], NULL AS [Label27], NULL AS [Type27], NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29]',
        ParameterMappings = N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        FilterDefinitions = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvWeeklySummary',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS Column1, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column2, SUM(ISNULL(F.[QUANTITY],0)) AS Column3, ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Column4, ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column5, ROUND(SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column6, CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0 ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1) END AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29 FROM [presentation].[F_PRODUCT_MARGIN_DAY] F INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE] LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID WHERE 1=1 AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]), COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) ORDER BY C.[Year], C.[Week] SELECT ''Weekly Summary'' AS [Title], ''Weekly sales and costs by location. Based on recipe cost.'' AS [Description], ''Week'' AS [Label1], ''TEXT'' AS [Type1], ''Location'' AS [Label2], ''TEXT'' AS [Type2], ''Qty Sold'' AS [Label3], ''DECIMAL'' AS [Type3], ''Revenue'' AS [Label4], ''DECIMAL'' AS [Type4], ''Recipe COGS'' AS [Label5], ''DECIMAL'' AS [Type5], ''Profit'' AS [Label6], ''DECIMAL'' AS [Type6], ''GP%'' AS [Label7], ''DECIMAL'' AS [Type7], NULL AS [Label8], NULL AS [Type8], NULL AS [Label9], NULL AS [Type9], NULL AS [Label10], NULL AS [Type10], NULL AS [Label11], NULL AS [Type11], NULL AS [Label12], NULL AS [Type12], NULL AS [Label13], NULL AS [Type13], NULL AS [Label14], NULL AS [Type14], NULL AS [Label15], NULL AS [Type15], NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17], NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19], NULL AS [Label20], NULL AS [Type20], NULL AS [Label21], NULL AS [Type21], NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23], NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25], NULL AS [Label26], NULL AS [Type26], NULL AS [Label27], NULL AS [Type27], NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29]',
        N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- ---------------------------------------------------------------------------
-- 8a. InvStockActivity — StackedBarChartCard
--     Orders In, Sales Out, Waste by location.
-- ---------------------------------------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvStockActivity',
        N'StackedBarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT LOCATION_NAME AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY LOCATION_NAME) AS LabelSort, Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack FROM ( SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Orders In'' AS Label, SUM(ISNULL(FU.[ORDER_QTY],0)) AS Value, ''A'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) UNION ALL SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Sales Out'' AS Label, SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Value, ''B'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) UNION ALL SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Waste'' AS Label, SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value, ''C'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) ) SUB SELECT ''Location'' AS XAxisLabel, ''Quantity'' AS YAxisLabel, ''Stock Activity by Location'' AS Title, ''Volume-based: orders in, sales out, waste by location.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        FilterDefinitions = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvStockActivity',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'SELECT LOCATION_NAME AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY LOCATION_NAME) AS LabelSort, Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack FROM ( SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Orders In'' AS Label, SUM(ISNULL(FU.[ORDER_QTY],0)) AS Value, ''A'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) UNION ALL SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Sales Out'' AS Label, SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Value, ''B'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) UNION ALL SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Waste'' AS Label, SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value, ''C'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) ) SUB SELECT ''Location'' AS XAxisLabel, ''Quantity'' AS YAxisLabel, ''Stock Activity by Location'' AS Title, ''Volume-based: orders in, sales out, waste by location.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- ---------------------------------------------------------------------------
-- 8b. InvStockActivity — MultiLineChartCard
--     Weekly volume trend: orders, sales, waste.
-- ---------------------------------------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvStockActivity',
        N'MultiLineChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort, Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, ''line'' AS VisType, LegendLabel FROM ( SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, SUM(ISNULL(FU.[ORDER_QTY],0)) AS Value, 1 AS VisId, ''Orders In'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Value, 2 AS VisId, ''Sales Out'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value, 3 AS VisId, ''Waste'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) ) SUB SELECT ''Week'' AS XAxisLabel, ''Quantity'' AS YAxisLabel, ''Stock Activity Trend'' AS Title, ''Weekly volume trend: orders, sales, waste.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        FilterDefinitions = N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvStockActivity',
        N'MultiLineChartCard',
        1,
        N'LIVE',
        N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort, Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, ''line'' AS VisType, LegendLabel FROM ( SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, SUM(ISNULL(FU.[ORDER_QTY],0)) AS Value, 1 AS VisId, ''Orders In'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Value, 2 AS VisId, ''Sales Out'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value, 3 AS VisId, ''Waste'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) ) SUB SELECT ''Week'' AS XAxisLabel, ''Quantity'' AS YAxisLabel, ''Stock Activity Trend'' AS Title, ''Weekly volume trend: orders, sales, waste.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
        N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

GO

-- ============================================================================
-- SECTION 11 of 11: Phase 2 vis queries (5 records)
-- Source: 11_phase2_vis_queries.sql
-- ============================================================================
-- ============================================
-- Phase 2 Growyze Visualisation Queries
-- 5 records across 3 datasets:
--   10a. InvPeriodCompWoW  (CombinedChartCard)
--   10b. InvPeriodCompMoM  (CombinedChartCard)
--   10c. InvPeriodCompYoY  (CombinedChartCard)
--   11.  InvVarianceCategory (StackedBarChartCard)
--   12.  InvTheoVsActualGP  (CombinedChartCard)
-- ============================================

-- --------------------------------------------
-- 10a. InvPeriodCompWoW — CombinedChartCard
-- Week-over-week revenue comparison
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvPeriodCompWoW',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(WEEK, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Week'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Week'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Week over Week'' AS Title,
    ''Current vs prior week revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvPeriodCompWoW',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(WEEK, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Week'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Week'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Week over Week'' AS Title,
    ''Current vs prior week revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 10b. InvPeriodCompMoM — CombinedChartCard
-- Month-over-month revenue comparison
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvPeriodCompMoM',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(MONTH, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Month'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Month'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Month over Month'' AS Title,
    ''Current vs prior month revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvPeriodCompMoM',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(MONTH, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Month'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Month'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Month over Month'' AS Title,
    ''Current vs prior month revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 10c. InvPeriodCompYoY — CombinedChartCard
-- Year-over-year revenue comparison
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvPeriodCompYoY',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(YEAR, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Year'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Year'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Year over Year'' AS Title,
    ''Current vs prior year revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvPeriodCompYoY',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(YEAR, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Year'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Year'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Year over Year'' AS Title,
    ''Current vs prior year revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 11. InvVarianceCategory — StackedBarChartCard
-- Variance by inventory category
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvVarianceCategory',
        N'StackedBarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Counts AS (
    SELECT
        FC.*,
        ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY ABS(Value) DESC) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Positive Variance'' AS Label,
        SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS Value,
        ''A'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])

    UNION ALL

    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Negative Variance'' AS Label,
        ABS(SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END)) AS Value,
        ''B'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB
WHERE Value > 0

SELECT ''Category'' AS XAxisLabel, ''Variance Value'' AS YAxisLabel,
    ''Inventory Variance by Category'' AS Title,
    ''Positive vs negative variance by inventory category. Requires stock count data.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvVarianceCategory',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'WITH Counts AS (
    SELECT
        FC.*,
        ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY ABS(Value) DESC) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Positive Variance'' AS Label,
        SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS Value,
        ''A'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])

    UNION ALL

    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Negative Variance'' AS Label,
        ABS(SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END)) AS Value,
        ''B'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB
WHERE Value > 0

SELECT ''Category'' AS XAxisLabel, ''Variance Value'' AS YAxisLabel,
    ''Inventory Variance by Category'' AS Title,
    ''Positive vs negative variance by inventory category. Requires stock count data.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 12. InvTheoVsActualGP — CombinedChartCard
-- Monthly recipe GP% only (bar). Actual GP% requires stock count
-- data (ACTUAL_USAGE) which is not in F_INV_SALES_DAY DDL.
-- Classified PARTIAL in implementation plan — recipe GP% only.
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvTheoVsActualGP',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Month] AS XAxisSort,
        CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
             ELSE ROUND(( SUM(ISNULL(FS.NET_SALES,0)) - SUM(ISNULL(FS.SALES_RECIPE_COST,0)) ) / SUM(ISNULL(FS.NET_SALES,0)) * 100, 1)
        END AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Recipe GP%'' AS LegendLabel
    FROM [presentation].[F_INV_SALES_DAY] FS
    INNER JOIN [presentation].[CALENDAR] C ON FS.[INV_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])
) SUB

SELECT ''Month'' AS XAxisLabel, ''GP%'' AS YAxisLabel,
    ''Recipe GP%'' AS Title,
    ''Based on recipe cost. Actual GP% requires stock count data (not yet available).'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvTheoVsActualGP',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Month] AS XAxisSort,
        CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
             ELSE ROUND(( SUM(ISNULL(FS.NET_SALES,0)) - SUM(ISNULL(FS.SALES_RECIPE_COST,0)) ) / SUM(ISNULL(FS.NET_SALES,0)) * 100, 1)
        END AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Recipe GP%'' AS LegendLabel
    FROM [presentation].[F_INV_SALES_DAY] FS
    INNER JOIN [presentation].[CALENDAR] C ON FS.[INV_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])
) SUB

SELECT ''Month'' AS XAxisLabel, ''GP%'' AS YAxisLabel,
    ''Recipe GP%'' AS Title,
    ''Based on recipe cost. Actual GP% requires stock count data (not yet available).'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
