-- ============================================================================
-- 04_troap_integration.sql
-- Consolidated deployment script: TROAP integration staging + entity mappings
-- Target: Core database
-- ============================================================================

-- ============================================================================
-- SECTION 1: TROAP Staging Control (20 steps)
-- Source: TROAP001_Staging.sql
-- ============================================================================
-- Staging Control Steps for TROAP Integration
-- Schema: int_troap001
-- Generated: 2026-03-03
-- Total Steps: 20

-- Step 1: Location (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_LOCATION',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_LOCATION]
FROM (
SELECT DISTINCT
    S.[StoreId] AS ITEM_SRC_KEY
    ,S.[StoreName] AS LOCATION_NAME
    ,NULL AS PARENT_ID
    ,''Location'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,S.[StorePostCode] AS ATTR_1
    ,S.[SalesAreaName] AS ATTR_2
    ,S.[BrandId] AS ATTR_3
    ,S.[IsActive] AS ATTR_4
    ,S.[POSProvider] AS ATTR_5
    ,S.[StoreId] AS LOCATION_ID
FROM [int_troap001].[DL_Store] S
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "LOCATION_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Location', N'TROAP_LOCATION', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_LOCATION]
FROM (
SELECT DISTINCT
    S.[StoreId] AS ITEM_SRC_KEY
    ,S.[StoreName] AS LOCATION_NAME
    ,NULL AS PARENT_ID
    ,''Location'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,S.[StorePostCode] AS ATTR_1
    ,S.[SalesAreaName] AS ATTR_2
    ,S.[BrandId] AS ATTR_3
    ,S.[IsActive] AS ATTR_4
    ,S.[POSProvider] AS ATTR_5
    ,S.[StoreId] AS LOCATION_ID
FROM [int_troap001].[DL_Store] S
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "LOCATION_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 2: Product (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Product')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_PRODUCT',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PRODUCT];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_PRODUCT]
FROM (
SELECT
    ITEM_SRC_KEY, PRODUCT_NAME, PARENT_ITEM_SRC_KEY, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID
FROM (
    SELECT
        P.[ProductId] AS ITEM_SRC_KEY
        ,P.[ProductName] AS PRODUCT_NAME
        ,P.[ProductCategoryId] AS PARENT_ITEM_SRC_KEY
        ,''Product'' AS LEVEL_NAME
        ,1 AS BOTTOM_LEVEL
        ,P.[ProductId] AS PRODUCT_ID
        ,ROW_NUMBER() OVER(PARTITION BY P.[ProductId] ORDER BY P.[LOADTS_UTC] DESC) AS RN
    FROM [int_troap001].[DL_Product] P
    WHERE ISNULL(P.[DELETED_FLAG], ''0'') != ''1''
    AND ISNULL(P.[ProductCategoryId], '''') != ''3''
) SUB WHERE RN = 1

UNION ALL

SELECT
    PC.[ProductCategoryId] AS ITEM_SRC_KEY
    ,PC.[ProductCategoryName] AS PRODUCT_NAME
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,''Product Category'' AS LEVEL_NAME
    ,0 AS BOTTOM_LEVEL
    ,PC.[ProductCategoryId] AS PRODUCT_ID
FROM [int_troap001].[DL_ProductCategory] PC
WHERE ISNULL(PC.[DELETED_FLAG], ''0'') != ''1''
AND PC.[ProductCategoryId] != ''3''
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "PRODUCT_NAME", "PARENT_ITEM_SRC_KEY", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Product';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Product', N'TROAP_PRODUCT', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PRODUCT];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_PRODUCT]
FROM (
SELECT
    ITEM_SRC_KEY, PRODUCT_NAME, PARENT_ITEM_SRC_KEY, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID
FROM (
    SELECT
        P.[ProductId] AS ITEM_SRC_KEY
        ,P.[ProductName] AS PRODUCT_NAME
        ,P.[ProductCategoryId] AS PARENT_ITEM_SRC_KEY
        ,''Product'' AS LEVEL_NAME
        ,1 AS BOTTOM_LEVEL
        ,P.[ProductId] AS PRODUCT_ID
        ,ROW_NUMBER() OVER(PARTITION BY P.[ProductId] ORDER BY P.[LOADTS_UTC] DESC) AS RN
    FROM [int_troap001].[DL_Product] P
    WHERE ISNULL(P.[DELETED_FLAG], ''0'') != ''1''
    AND ISNULL(P.[ProductCategoryId], '''') != ''3''
) SUB WHERE RN = 1

UNION ALL

SELECT
    PC.[ProductCategoryId] AS ITEM_SRC_KEY
    ,PC.[ProductCategoryName] AS PRODUCT_NAME
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,''Product Category'' AS LEVEL_NAME
    ,0 AS BOTTOM_LEVEL
    ,PC.[ProductCategoryId] AS PRODUCT_ID
FROM [int_troap001].[DL_ProductCategory] PC
WHERE ISNULL(PC.[DELETED_FLAG], ''0'') != ''1''
AND PC.[ProductCategoryId] != ''3''
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "PRODUCT_NAME", "PARENT_ITEM_SRC_KEY", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 3: Mod (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Mod')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_MOD',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_MOD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MOD];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_MOD]
FROM (
SELECT
    P.[ProductId] AS ITEM_SRC_KEY
    ,P.[ProductName] AS MOD_NAME
    ,NULL AS PARENT_ID
    ,''Modification'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,P.[ProductId] AS MOD_ID
FROM (
    SELECT P.*
        ,ROW_NUMBER() OVER(PARTITION BY P.[ProductId] ORDER BY P.[LOADTS_UTC] DESC) AS RN
    FROM [int_troap001].[DL_Product] P
    WHERE P.[ProductCategoryId] = ''3''
    AND ISNULL(P.[DELETED_FLAG], ''0'') != ''1''
) P WHERE P.RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Mod';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Mod', N'TROAP_MOD', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_MOD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MOD];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_MOD]
FROM (
SELECT
    P.[ProductId] AS ITEM_SRC_KEY
    ,P.[ProductName] AS MOD_NAME
    ,NULL AS PARENT_ID
    ,''Modification'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,P.[ProductId] AS MOD_ID
FROM (
    SELECT P.*
        ,ROW_NUMBER() OVER(PARTITION BY P.[ProductId] ORDER BY P.[LOADTS_UTC] DESC) AS RN
    FROM [int_troap001].[DL_Product] P
    WHERE P.[ProductCategoryId] = ''3''
    AND ISNULL(P.[DELETED_FLAG], ''0'') != ''1''
) P WHERE P.RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 4: Channel (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Channel')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_CHANNEL',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_CHANNEL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CHANNEL];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_CHANNEL]
FROM (
SELECT DISTINCT
    O.[ClientApplication] AS ITEM_SRC_KEY
    ,O.[ClientApplication] AS CHANNEL_NAME
    ,''Channel'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,O.[ClientApplication] AS CHANNEL_ID
FROM [int_troap001].[DL_Order] O
WHERE O.[ClientApplication] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "CHANNEL_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "CHANNEL_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Channel';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Channel', N'TROAP_CHANNEL', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_CHANNEL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CHANNEL];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_CHANNEL]
FROM (
SELECT DISTINCT
    O.[ClientApplication] AS ITEM_SRC_KEY
    ,O.[ClientApplication] AS CHANNEL_NAME
    ,''Channel'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,O.[ClientApplication] AS CHANNEL_ID
FROM [int_troap001].[DL_Order] O
WHERE O.[ClientApplication] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "CHANNEL_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "CHANNEL_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 5: Occasion (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Occasion')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_OCCASION',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_OCCASION];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_OCCASION]
FROM (
SELECT DISTINCT
    O.[ShipmentTypeId] AS ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASION_NAME
    ,''Occassion'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,O.[ShipmentTypeId] AS OCCASSION_ID
FROM [int_troap001].[DL_Order] O
WHERE O.[ShipmentTypeId] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "OCCASSION_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Occasion';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Occasion', N'TROAP_OCCASION', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_OCCASION];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_OCCASION]
FROM (
SELECT DISTINCT
    O.[ShipmentTypeId] AS ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASION_NAME
    ,''Occassion'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,O.[ShipmentTypeId] AS OCCASSION_ID
FROM [int_troap001].[DL_Order] O
WHERE O.[ShipmentTypeId] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "OCCASSION_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 6: Deal (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Deal')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_DEAL',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DEAL]
FROM (
SELECT DISTINCT
    P.[Id] AS ITEM_SRC_KEY
    ,P.[Name] AS DEAL_NAME
    ,NULL AS PARENT_ID
    ,''Deal'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,P.[Id] AS DEAL_ID
FROM [int_troap001].[DL_CustomerOpenCheckPromotion] P
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DEAL_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Deal';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Deal', N'TROAP_DEAL', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DEAL]
FROM (
SELECT DISTINCT
    P.[Id] AS ITEM_SRC_KEY
    ,P.[Name] AS DEAL_NAME
    ,NULL AS PARENT_ID
    ,''Deal'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,P.[Id] AS DEAL_ID
FROM [int_troap001].[DL_CustomerOpenCheckPromotion] P
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DEAL_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 7: Discount (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Discount')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_DISCOUNT',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DISCOUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISCOUNT];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DISCOUNT]
FROM (
SELECT DISTINCT
    D.[DiscountId] AS ITEM_SRC_KEY
    ,D.[Name] AS DISCOUNT_NAME
    ,NULL AS PARENT_ID
    ,''Discount'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,D.[DiscountId] AS DISCOUNT_ID
FROM [int_troap001].[DL_CustomerOpenCheckDiscount] D
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "DISCOUNT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DISCOUNT_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Discount';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Discount', N'TROAP_DISCOUNT', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DISCOUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISCOUNT];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DISCOUNT]
FROM (
SELECT DISTINCT
    D.[DiscountId] AS ITEM_SRC_KEY
    ,D.[Name] AS DISCOUNT_NAME
    ,NULL AS PARENT_ID
    ,''Discount'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,D.[DiscountId] AS DISCOUNT_ID
FROM [int_troap001].[DL_CustomerOpenCheckDiscount] D
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "DISCOUNT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DISCOUNT_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 8: Tender (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Tender')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_TENDER',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_TENDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TENDER];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_TENDER]
FROM (
SELECT DISTINCT
    OP.[PaymentMethodId] AS ITEM_SRC_KEY
    ,OP.[PaymentMethodId] AS TENDER_NAME
    ,''Tender'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,OP.[PaymentMethodId] AS TENDER_ID
FROM [int_troap001].[DL_OrderPayment] OP
WHERE OP.[PaymentMethodId] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "TENDER_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "TENDER_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Tender';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Tender', N'TROAP_TENDER', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_TENDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TENDER];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_TENDER]
FROM (
SELECT DISTINCT
    OP.[PaymentMethodId] AS ITEM_SRC_KEY
    ,OP.[PaymentMethodId] AS TENDER_NAME
    ,''Tender'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,OP.[PaymentMethodId] AS TENDER_ID
FROM [int_troap001].[DL_OrderPayment] OP
WHERE OP.[PaymentMethodId] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "TENDER_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "TENDER_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 9: Service Charge (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Service Charge')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_SVCCHARGE',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_SVCCHARGE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVCCHARGE];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_SVCCHARGE]
FROM (
SELECT DISTINCT
    C.[Name] AS ITEM_SRC_KEY
    ,C.[Name] AS SVCCHARGE_NAME
    ,''ServiceCharge'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,C.[Name] AS SVC_ID
FROM [int_troap001].[DL_CustomerOpenCheckCharge] C
WHERE C.[Name] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SVCCHARGE_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "SVC_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Service Charge';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Service Charge', N'TROAP_SVCCHARGE', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_SVCCHARGE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVCCHARGE];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_SVCCHARGE]
FROM (
SELECT DISTINCT
    C.[Name] AS ITEM_SRC_KEY
    ,C.[Name] AS SVCCHARGE_NAME
    ,''ServiceCharge'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,C.[Name] AS SVC_ID
FROM [int_troap001].[DL_CustomerOpenCheckCharge] C
WHERE C.[Name] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "SVCCHARGE_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "SVC_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 10: RevCenter (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'RevCenter')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_REVCENTER',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_REVCENTER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_REVCENTER];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_REVCENTER]
FROM (
SELECT DISTINCT
    S.[SalesAreaName] AS ITEM_SRC_KEY
    ,S.[SalesAreaName] AS REVC_NAME
    ,''RevCenter'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,S.[SalesAreaName] AS REVC_ID
FROM [int_troap001].[DL_Store] S
WHERE S.[SalesAreaName] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "REVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "REVC_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'RevCenter';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'RevCenter', N'TROAP_REVCENTER', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_REVCENTER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_REVCENTER];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_REVCENTER]
FROM (
SELECT DISTINCT
    S.[SalesAreaName] AS ITEM_SRC_KEY
    ,S.[SalesAreaName] AS REVC_NAME
    ,''RevCenter'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,S.[SalesAreaName] AS REVC_ID
FROM [int_troap001].[DL_Store] S
WHERE S.[SalesAreaName] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ITEM_SRC_KEY", "REVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL", "REVC_ID"]', GETDATE(), GETDATE());
END
GO

-- Step 11: Order (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Order')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_ORDER',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_ORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_ORDER];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_ORDER]
FROM (
SELECT
    O.[OrderId] AS HEADER_ID
    ,TRY_CAST(O.[TotalPriceTotal] AS FLOAT) AS GRAND_TOTAL_SRC
    ,NULL AS DISCOUNT_GROSS
    ,TRY_CAST(O.[TotalPriceNet] AS FLOAT) AS NET_SALES
    ,TRY_CAST(O.[TotalPriceTotal] AS FLOAT) AS GROSS_SALES
    ,TRY_CAST(O.[TotalPriceVat] AS FLOAT) AS TAX_TOTAL
    ,NULL AS SVC_CHARGE_TOTAL
    ,NULL AS ITEM_COUNT
    ,1 AS GUEST_COUNT
    ,1 AS ORDER_COUNT
    ,TRY_CAST(O.[DateCreated] AS DATETIME2) AS OPEN_TIME
    ,TRY_CAST(O.[DateUpdated] AS DATETIME2) AS CLOSE_TIME
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,O.[TableNumber] AS TABLE_NO
    ,O.[ClientApplication] AS ORDER_INFO
    ,O.[OrderId] AS EXTERNAL_REFERENCE
    ,O.[OrderStatusId] AS ORDER_STATUS
    ,O.[PaymentStatusId] AS PAYMENT_STATUS
    ,PM.TENDERED_SALES
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,O.[StoreId] AS LOCATION_ID
    ,O.[ClientApplication] AS CHANNEL
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
    ,S.[SalesAreaName] AS REVCENTER_SRC_KEY
FROM [int_troap001].[DL_Order] O
LEFT JOIN (
    SELECT StoreId, SalesAreaName,
        ROW_NUMBER() OVER(PARTITION BY StoreId ORDER BY LOADTS_UTC DESC) AS RN
    FROM [int_troap001].[DL_Store]
) S ON O.[StoreId] = S.[StoreId] AND S.RN = 1
LEFT JOIN (
    SELECT [OrderId], SUM(TRY_CAST([Amount] AS FLOAT)) AS TENDERED_SALES
    FROM [int_troap001].[DL_OrderPayment]
    GROUP BY [OrderId]
) PM ON O.[OrderId] = PM.[OrderId]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["HEADER_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES", "GROSS_SALES", "TAX_TOTAL", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES", "TRADING_DATE", "LOCATION_ID", "CHANNEL", "OCCASSION_SRC_KEY", "REVCENTER_SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Order';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Order', N'TROAP_ORDER', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_ORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_ORDER];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_ORDER]
FROM (
SELECT
    O.[OrderId] AS HEADER_ID
    ,TRY_CAST(O.[TotalPriceTotal] AS FLOAT) AS GRAND_TOTAL_SRC
    ,NULL AS DISCOUNT_GROSS
    ,TRY_CAST(O.[TotalPriceNet] AS FLOAT) AS NET_SALES
    ,TRY_CAST(O.[TotalPriceTotal] AS FLOAT) AS GROSS_SALES
    ,TRY_CAST(O.[TotalPriceVat] AS FLOAT) AS TAX_TOTAL
    ,NULL AS SVC_CHARGE_TOTAL
    ,NULL AS ITEM_COUNT
    ,1 AS GUEST_COUNT
    ,1 AS ORDER_COUNT
    ,TRY_CAST(O.[DateCreated] AS DATETIME2) AS OPEN_TIME
    ,TRY_CAST(O.[DateUpdated] AS DATETIME2) AS CLOSE_TIME
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,O.[TableNumber] AS TABLE_NO
    ,O.[ClientApplication] AS ORDER_INFO
    ,O.[OrderId] AS EXTERNAL_REFERENCE
    ,O.[OrderStatusId] AS ORDER_STATUS
    ,O.[PaymentStatusId] AS PAYMENT_STATUS
    ,PM.TENDERED_SALES
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,O.[StoreId] AS LOCATION_ID
    ,O.[ClientApplication] AS CHANNEL
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
    ,S.[SalesAreaName] AS REVCENTER_SRC_KEY
FROM [int_troap001].[DL_Order] O
LEFT JOIN (
    SELECT StoreId, SalesAreaName,
        ROW_NUMBER() OVER(PARTITION BY StoreId ORDER BY LOADTS_UTC DESC) AS RN
    FROM [int_troap001].[DL_Store]
) S ON O.[StoreId] = S.[StoreId] AND S.RN = 1
LEFT JOIN (
    SELECT [OrderId], SUM(TRY_CAST([Amount] AS FLOAT)) AS TENDERED_SALES
    FROM [int_troap001].[DL_OrderPayment]
    GROUP BY [OrderId]
) PM ON O.[OrderId] = PM.[OrderId]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["HEADER_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES", "GROSS_SALES", "TAX_TOTAL", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES", "TRADING_DATE", "LOCATION_ID", "CHANNEL", "OCCASSION_SRC_KEY", "REVCENTER_SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 12: Line Item Detail (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Line Item Detail')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_LINE_ITEM_DETAIL',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LINE_ITEM_DETAIL];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_LINE_ITEM_DETAIL]
FROM (
-- Branch A: Products (parent items)
SELECT
    CONCAT_WS(''-'', OI.[OrderId], OI.[OrderItemId], ''PROD'') AS SRC_KEY
    ,OI.[OrderId] AS HEADER_ID
    ,''PROD'' AS LINEITEM_TYPE
    ,TRY_CAST(OI.[PriceTotal] AS FLOAT) AS GROSS_VALUE
    ,TRY_CAST(OI.[PriceVat] AS FLOAT) AS TAX_VALUE
    ,TRY_CAST(OI.[PriceNet] AS FLOAT) AS NET_VALUE
    ,TRY_CAST(OI.[Quantity] AS FLOAT) AS QUANTITY
    ,OI.[ProductId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_OrderItem] OI
INNER JOIN [int_troap001].[DL_Order] O ON OI.[OrderId] = O.[OrderId]
INNER JOIN [int_troap001].[DL_Product] P ON OI.[ProductId] = P.[ProductId]
WHERE P.[ProductCategoryId] != ''3''

UNION ALL

-- Branch B: Modifiers (child items)
SELECT
    CONCAT_WS(''-'', OI.[OrderId], OI.[OrderItemId], ''MOD'') AS SRC_KEY
    ,OI.[OrderId] AS HEADER_ID
    ,''MOD'' AS LINEITEM_TYPE
    ,TRY_CAST(OI.[PriceTotal] AS FLOAT) AS GROSS_VALUE
    ,TRY_CAST(OI.[PriceVat] AS FLOAT) AS TAX_VALUE
    ,TRY_CAST(OI.[PriceNet] AS FLOAT) AS NET_VALUE
    ,TRY_CAST(OI.[Quantity] AS FLOAT) AS QUANTITY
    ,OI.[ProductId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,OI.[OrderItemParentId] AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_OrderItem] OI
INNER JOIN [int_troap001].[DL_Order] O ON OI.[OrderId] = O.[OrderId]
INNER JOIN [int_troap001].[DL_Product] P ON OI.[ProductId] = P.[ProductId]
WHERE P.[ProductCategoryId] = ''3''

UNION ALL

-- Branch C: Payments (tender)
SELECT
    CONCAT_WS(''-'', OP.[OrderId], OP.[Id], ''TENDER'') AS SRC_KEY
    ,OP.[OrderId] AS HEADER_ID
    ,''TENDER'' AS LINEITEM_TYPE
    ,TRY_CAST(OP.[Amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,OP.[PaymentMethodId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_OrderPayment] OP
INNER JOIN [int_troap001].[DL_Order] O ON OP.[OrderId] = O.[OrderId]

UNION ALL

-- Branch D: Service Charges
SELECT
    CONCAT_WS(''-'', O.[OrderId], CH.[Id], ''SVC'') AS SRC_KEY
    ,O.[OrderId] AS HEADER_ID
    ,''SVC'' AS LINEITEM_TYPE
    ,TRY_CAST(CH.[ChargeAmount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,CH.[Name] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_CustomerOpenCheckCharge] CH
INNER JOIN [int_troap001].[DL_CustomerOpenCheck] CK ON CH.[CustomerOpenCheckId] = CK.[Id]
INNER JOIN [int_troap001].[DL_Order] O ON CK.[OrderId] = O.[OrderId]
WHERE CK.[OrderId] IS NOT NULL AND CK.[OrderId] != ''''

UNION ALL

-- Branch E: Promotions (deals)
SELECT
    CONCAT_WS(''-'', O.[OrderId], PR.[Id], ''DEAL'') AS SRC_KEY
    ,O.[OrderId] AS HEADER_ID
    ,''DEAL'' AS LINEITEM_TYPE
    ,TRY_CAST(PR.[PromotionalSaving] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,PR.[Id] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_CustomerOpenCheckPromotion] PR
INNER JOIN [int_troap001].[DL_CustomerOpenCheck] CK ON PR.[CustomerOpenCheckId] = CK.[Id]
INNER JOIN [int_troap001].[DL_Order] O ON CK.[OrderId] = O.[OrderId]
WHERE CK.[OrderId] IS NOT NULL AND CK.[OrderId] != ''''

UNION ALL

-- Branch F: Discounts
SELECT
    CONCAT_WS(''-'', O.[OrderId], DI.[Id], ''DISCOUNT'') AS SRC_KEY
    ,O.[OrderId] AS HEADER_ID
    ,''DISCOUNT'' AS LINEITEM_TYPE
    ,TRY_CAST(DI.[Amount] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,DI.[DiscountId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_CustomerOpenCheckDiscount] DI
INNER JOIN [int_troap001].[DL_CustomerOpenCheck] CK ON DI.[CustomerOpenCheckId] = CK.[Id]
INNER JOIN [int_troap001].[DL_Order] O ON CK.[OrderId] = O.[OrderId]
WHERE CK.[OrderId] IS NOT NULL AND CK.[OrderId] != ''''
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "ITEM_SRC_KEY", "ORDER_DATE", "TRADING_DATE", "PARENT_ITEM_SRC_KEY", "OCCASSION_SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Line Item Detail';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Line Item Detail', N'TROAP_LINE_ITEM_DETAIL', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LINE_ITEM_DETAIL];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_LINE_ITEM_DETAIL]
FROM (
-- Branch A: Products (parent items)
SELECT
    CONCAT_WS(''-'', OI.[OrderId], OI.[OrderItemId], ''PROD'') AS SRC_KEY
    ,OI.[OrderId] AS HEADER_ID
    ,''PROD'' AS LINEITEM_TYPE
    ,TRY_CAST(OI.[PriceTotal] AS FLOAT) AS GROSS_VALUE
    ,TRY_CAST(OI.[PriceVat] AS FLOAT) AS TAX_VALUE
    ,TRY_CAST(OI.[PriceNet] AS FLOAT) AS NET_VALUE
    ,TRY_CAST(OI.[Quantity] AS FLOAT) AS QUANTITY
    ,OI.[ProductId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_OrderItem] OI
INNER JOIN [int_troap001].[DL_Order] O ON OI.[OrderId] = O.[OrderId]
INNER JOIN [int_troap001].[DL_Product] P ON OI.[ProductId] = P.[ProductId]
WHERE P.[ProductCategoryId] != ''3''

UNION ALL

-- Branch B: Modifiers (child items)
SELECT
    CONCAT_WS(''-'', OI.[OrderId], OI.[OrderItemId], ''MOD'') AS SRC_KEY
    ,OI.[OrderId] AS HEADER_ID
    ,''MOD'' AS LINEITEM_TYPE
    ,TRY_CAST(OI.[PriceTotal] AS FLOAT) AS GROSS_VALUE
    ,TRY_CAST(OI.[PriceVat] AS FLOAT) AS TAX_VALUE
    ,TRY_CAST(OI.[PriceNet] AS FLOAT) AS NET_VALUE
    ,TRY_CAST(OI.[Quantity] AS FLOAT) AS QUANTITY
    ,OI.[ProductId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,OI.[OrderItemParentId] AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_OrderItem] OI
INNER JOIN [int_troap001].[DL_Order] O ON OI.[OrderId] = O.[OrderId]
INNER JOIN [int_troap001].[DL_Product] P ON OI.[ProductId] = P.[ProductId]
WHERE P.[ProductCategoryId] = ''3''

UNION ALL

-- Branch C: Payments (tender)
SELECT
    CONCAT_WS(''-'', OP.[OrderId], OP.[Id], ''TENDER'') AS SRC_KEY
    ,OP.[OrderId] AS HEADER_ID
    ,''TENDER'' AS LINEITEM_TYPE
    ,TRY_CAST(OP.[Amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,OP.[PaymentMethodId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_OrderPayment] OP
INNER JOIN [int_troap001].[DL_Order] O ON OP.[OrderId] = O.[OrderId]

UNION ALL

-- Branch D: Service Charges
SELECT
    CONCAT_WS(''-'', O.[OrderId], CH.[Id], ''SVC'') AS SRC_KEY
    ,O.[OrderId] AS HEADER_ID
    ,''SVC'' AS LINEITEM_TYPE
    ,TRY_CAST(CH.[ChargeAmount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,CH.[Name] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_CustomerOpenCheckCharge] CH
INNER JOIN [int_troap001].[DL_CustomerOpenCheck] CK ON CH.[CustomerOpenCheckId] = CK.[Id]
INNER JOIN [int_troap001].[DL_Order] O ON CK.[OrderId] = O.[OrderId]
WHERE CK.[OrderId] IS NOT NULL AND CK.[OrderId] != ''''

UNION ALL

-- Branch E: Promotions (deals)
SELECT
    CONCAT_WS(''-'', O.[OrderId], PR.[Id], ''DEAL'') AS SRC_KEY
    ,O.[OrderId] AS HEADER_ID
    ,''DEAL'' AS LINEITEM_TYPE
    ,TRY_CAST(PR.[PromotionalSaving] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,PR.[Id] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_CustomerOpenCheckPromotion] PR
INNER JOIN [int_troap001].[DL_CustomerOpenCheck] CK ON PR.[CustomerOpenCheckId] = CK.[Id]
INNER JOIN [int_troap001].[DL_Order] O ON CK.[OrderId] = O.[OrderId]
WHERE CK.[OrderId] IS NOT NULL AND CK.[OrderId] != ''''

UNION ALL

-- Branch F: Discounts
SELECT
    CONCAT_WS(''-'', O.[OrderId], DI.[Id], ''DISCOUNT'') AS SRC_KEY
    ,O.[OrderId] AS HEADER_ID
    ,''DISCOUNT'' AS LINEITEM_TYPE
    ,TRY_CAST(DI.[Amount] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,DI.[DiscountId] AS ITEM_SRC_KEY
    ,TRY_CAST(O.[DateCreated] AS DATE) AS ORDER_DATE
    ,TRY_CAST(O.[DateCreated] AS DATE) AS TRADING_DATE
    ,NULL AS PARENT_ITEM_SRC_KEY
    ,O.[ShipmentTypeId] AS OCCASSION_SRC_KEY
FROM [int_troap001].[DL_CustomerOpenCheckDiscount] DI
INNER JOIN [int_troap001].[DL_CustomerOpenCheck] CK ON DI.[CustomerOpenCheckId] = CK.[Id]
INNER JOIN [int_troap001].[DL_Order] O ON CK.[OrderId] = O.[OrderId]
WHERE CK.[OrderId] IS NOT NULL AND CK.[OrderId] != ''''
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "ITEM_SRC_KEY", "ORDER_DATE", "TRADING_DATE", "PARENT_ITEM_SRC_KEY", "OCCASSION_SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 13: Product to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Product to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_PROD_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PROD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_PROD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Product to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Product to Line Item', N'TROAP_PROD_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PROD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_PROD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 14: Mod to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Mod to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_MOD_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MOD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_MOD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''MOD''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Mod to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Mod to Line Item', N'TROAP_MOD_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MOD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_MOD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''MOD''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 15: Deal to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Deal to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_DEAL_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DEAL_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DEAL''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Deal to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Deal to Line Item', N'TROAP_DEAL_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DEAL_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DEAL''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 16: Discount to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Discount to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_DISC_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DISC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DISCOUNT''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Discount to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Discount to Line Item', N'TROAP_DISC_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_DISC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DISCOUNT''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 17: Tender to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Tender to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_TENDER_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_TENDER_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TENDER_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_TENDER_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''TENDER''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Tender to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Tender to Line Item', N'TROAP_TENDER_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_TENDER_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TENDER_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_TENDER_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''TENDER''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 18: Service Charge to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Service Charge to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_SVC_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_SVC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''SVC''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Service Charge to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Service Charge to Line Item', N'TROAP_SVC_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_SVC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''SVC''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["ITEM_SRC_KEY", "SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 19: Occasion to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Occasion to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_OCC_LI_LNK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_OCC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_OCC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_OCC_LI_LNK]
FROM (
SELECT
    [SRC_KEY]
    ,[OCCASSION_SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''PROD'',''MOD'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["SRC_KEY", "OCCASSION_SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Occasion to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Occasion to Line Item', N'TROAP_OCC_LI_LNK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_OCC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_OCC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_OCC_LI_LNK]
FROM (
SELECT
    [SRC_KEY]
    ,[OCCASSION_SRC_KEY]
FROM
    [stage].[TROAP_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''PROD'',''MOD'')
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["SRC_KEY", "OCCASSION_SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step 20: Line Item to Line Item (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Line Item to Line Item')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET [staging_table] = N'TROAP_LI_LI_LINK',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_LI_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LI_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_LI_LI_LINK]
FROM (
SELECT
    CONCAT_WS(''-'', LI.HEADER_ID, LI.PARENT_ITEM_SRC_KEY, CASE WHEN PP.[ProductCategoryId] = ''3'' THEN ''MOD'' ELSE ''PROD'' END) AS PARENT_SRC_KEY
    ,LI.SRC_KEY AS CHILD_SRC_KEY
    ,NULL AS LABEL
    ,NULL AS VALUE
    ,NULL AS INFO
FROM [stage].[TROAP_LINE_ITEM_DETAIL] LI
INNER JOIN [int_troap001].[DL_OrderItem] POI ON LI.HEADER_ID = POI.[OrderId] AND LI.PARENT_ITEM_SRC_KEY = POI.[OrderItemId]
INNER JOIN [int_troap001].[DL_Product] PP ON POI.[ProductId] = PP.[ProductId]
WHERE LI.LINEITEM_TYPE = ''MOD''
AND LI.PARENT_ITEM_SRC_KEY IS NOT NULL
AND LI.PARENT_ITEM_SRC_KEY != ''''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_SRC_KEY", "CHILD_SRC_KEY", "LABEL", "VALUE", "INFO"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Line Item to Line Item', N'TROAP_LI_LI_LINK', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TROAP_LI_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LI_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[TROAP_LI_LI_LINK]
FROM (
SELECT
    CONCAT_WS(''-'', LI.HEADER_ID, LI.PARENT_ITEM_SRC_KEY, CASE WHEN PP.[ProductCategoryId] = ''3'' THEN ''MOD'' ELSE ''PROD'' END) AS PARENT_SRC_KEY
    ,LI.SRC_KEY AS CHILD_SRC_KEY
    ,NULL AS LABEL
    ,NULL AS VALUE
    ,NULL AS INFO
FROM [stage].[TROAP_LINE_ITEM_DETAIL] LI
INNER JOIN [int_troap001].[DL_OrderItem] POI ON LI.HEADER_ID = POI.[OrderId] AND LI.PARENT_ITEM_SRC_KEY = POI.[OrderItemId]
INNER JOIN [int_troap001].[DL_Product] PP ON POI.[ProductId] = PP.[ProductId]
WHERE LI.LINEITEM_TYPE = ''MOD''
AND LI.PARENT_ITEM_SRC_KEY IS NOT NULL
AND LI.PARENT_ITEM_SRC_KEY != ''''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, N'["PARENT_SRC_KEY", "CHILD_SRC_KEY", "LABEL", "VALUE", "INFO"]', GETDATE(), GETDATE());
END
GO

GO

-- ============================================================================
-- SECTION 2: TROAP Entity Mappings (25 mappings: 12 hub + 13 link)
-- Source: TROAP001_Mapping.sql
-- ============================================================================
-- Data Vault Entity Mappings for TROAP Integration
-- Schema: int_troap001
-- Generated: 2026-03-03
-- Total Mappings: 25

-- =============================================
-- HUB MAPPINGS (12)
-- =============================================

-- Entity: LOCATION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LOCATION')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_LOCATION',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "LOCATION_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LOCATION';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000001', 'LOCATION', 'TROAP_LOCATION',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]', '["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "LOCATION_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'PRODUCT')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_PRODUCT',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'PRODUCT';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000002', 'PRODUCT', 'TROAP_PRODUCT',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}]', '["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: MOD
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'MOD')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_MOD',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "MOD_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MOD_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'MOD';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000003', 'MOD', 'TROAP_MOD',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "MOD_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MOD_ID", "hash": 0}]', '["HUB_ID", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CHANNEL
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'CHANNEL')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_CHANNEL',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "CHANNEL_NAME", "hash": 0}, {"name": "CHANNEL_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CHANNEL';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000004', 'CHANNEL', 'TROAP_CHANNEL',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "CHANNEL_NAME", "hash": 0}, {"name": "CHANNEL_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'OCCASION')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_OCCASION',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "OCCASION_NAME", "hash": 0}, {"name": "OCCASSION_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["HUB_ID", "OCCASION_NAME", "OCCASSION_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'OCCASION';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000005', 'OCCASION', 'TROAP_OCCASION',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "OCCASION_NAME", "hash": 0}, {"name": "OCCASSION_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "OCCASION_NAME", "OCCASSION_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: REVCENTER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'REVCENTER')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_REVCENTER',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "REVC_NAME", "hash": 0}, {"name": "REVC_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["HUB_ID", "REVC_NAME", "REVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'REVCENTER';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000006', 'REVCENTER', 'TROAP_REVCENTER',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "REVC_NAME", "hash": 0}, {"name": "REVC_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "REVC_NAME", "REVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DEAL
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'DEAL')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_DEAL',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "DEAL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "DEAL_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DEAL_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'DEAL';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000007', 'DEAL', 'TROAP_DEAL',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "DEAL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "DEAL_ID", "hash": 0}]', '["HUB_ID", "DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DEAL_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DISCOUNT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'DISCOUNT')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_DISCOUNT',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "DISCOUNT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "DISCOUNT_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "DISCOUNT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DISCOUNT_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'DISCOUNT';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000008', 'DISCOUNT', 'TROAP_DISCOUNT',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "DISCOUNT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "DISCOUNT_ID", "hash": 0}]', '["HUB_ID", "DISCOUNT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "DISCOUNT_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: TENDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'TENDER')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_TENDER',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "TENDER_NAME", "hash": 0}, {"name": "TENDER_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["HUB_ID", "TENDER_NAME", "TENDER_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'TENDER';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-100000000009', 'TENDER', 'TROAP_TENDER',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "TENDER_NAME", "hash": 0}, {"name": "TENDER_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "TENDER_NAME", "TENDER_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: SVCCHARGE
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'SVCCHARGE')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_SVCCHARGE',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "SVCCHARGE_NAME", "hash": 0}, {"name": "SVC_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["HUB_ID", "SVCCHARGE_NAME", "SVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-10000000000A', 'SVCCHARGE', 'TROAP_SVCCHARGE',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "SVCCHARGE_NAME", "hash": 0}, {"name": "SVC_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "SVCCHARGE_NAME", "SVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'CUSTORDER')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_ORDER',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "SVC_CHARGE_TOTAL", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TABLE_NO", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "TENDERED_SALES", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        entity_columns = '["HUB_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES", "GROSS_SALES", "TAX_TOTAL", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES", "TRADING_DATE"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-10000000000B', 'CUSTORDER', 'TROAP_ORDER',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "SVC_CHARGE_TOTAL", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TABLE_NO", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "TENDERED_SALES", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]', '["HUB_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES", "GROSS_SALES", "TAX_TOTAL", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES", "TRADING_DATE"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LINEITEM')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_LINE_ITEM_DETAIL',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        entity_columns = '["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "ORDER_DATE", "SRC_KEY", "TRADING_DATE"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-10000000000C', 'LINEITEM', 'TROAP_LINE_ITEM_DETAIL',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]', '["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "ORDER_DATE", "SRC_KEY", "TRADING_DATE"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- =============================================
-- LINK MAPPINGS (13)
-- =============================================

-- Entity: CUSTORDER_LOCATION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'CUSTORDER_LOCATION')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_ORDER',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]',
        entity_columns = '["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000001', 'CUSTORDER_LOCATION', 'TROAP_ORDER',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]', '["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'CUSTORDER_LINEITEM')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_LINE_ITEM_DETAIL',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000002', 'CUSTORDER_LINEITEM', 'TROAP_LINE_ITEM_DETAIL',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]', '["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CHANNEL_CUSTORDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'CHANNEL_CUSTORDER')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_ORDER',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "CHANNEL", "hash": 1}]',
        entity_columns = '["CUSTORDER_HUB_ID", "CHANNEL_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CHANNEL_CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000003', 'CHANNEL_CUSTORDER', 'TROAP_ORDER',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "CHANNEL", "hash": 1}]', '["CUSTORDER_HUB_ID", "CHANNEL_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'CUSTORDER_OCCASION')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_ORDER',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]',
        entity_columns = '["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER_OCCASION';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000004', 'CUSTORDER_OCCASION', 'TROAP_ORDER',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]', '["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_REVCENTER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'CUSTORDER_REVCENTER')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_ORDER',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "REVCENTER_SRC_KEY", "hash": 1}]',
        entity_columns = '["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER_REVCENTER';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000005', 'CUSTORDER_REVCENTER', 'TROAP_ORDER',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "REVCENTER_SRC_KEY", "hash": 1}]', '["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LINEITEM_PRODUCT')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_PROD_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000006', 'LINEITEM_PRODUCT', 'TROAP_PROD_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_MOD
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LINEITEM_MOD')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_MOD_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "MOD_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM_MOD';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000007', 'LINEITEM_MOD', 'TROAP_MOD_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "MOD_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LINEITEM_OCCASION')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_OCC_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM_OCCASION';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000008', 'LINEITEM_OCCASION', 'TROAP_OCC_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_TENDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LINEITEM_TENDER')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_TENDER_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "TENDER_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM_TENDER';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-200000000009', 'LINEITEM_TENDER', 'TROAP_TENDER_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "TENDER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_SVCCHARGE
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LINEITEM_SVCCHARGE')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_SVC_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "SVCCHARGE_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM_SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-20000000000A', 'LINEITEM_SVCCHARGE', 'TROAP_SVC_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "SVCCHARGE_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DEAL_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'DEAL_LINEITEM')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_DEAL_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "DEAL_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'DEAL_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-20000000000B', 'DEAL_LINEITEM', 'TROAP_DEAL_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "DEAL_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DISCOUNT_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'DISCOUNT_LINEITEM')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_DISC_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "DISCOUNT_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'DISCOUNT_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-20000000000C', 'DISCOUNT_LINEITEM', 'TROAP_DISC_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "DISCOUNT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_LINEITEM (self-referencing link with SAT_LNK attributes)
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_troap001.EntityMappings WHERE entity_name = 'LINEITEM_LINEITEM')
BEGIN
    UPDATE core.int_troap001.EntityMappings
    SET source_table = 'TROAP_LI_LI_LINK',
        source_columns = '[{"name": "PARENT_SRC_KEY", "hash": 1}, {"name": "CHILD_SRC_KEY", "hash": 1}, {"name": "LABEL", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "INFO", "hash": 0}]',
        entity_columns = '["PARENT_HUB_ID", "CHILD_HUB_ID", "LABEL", "VALUE", "INFO"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_troap001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A1B2C3D4-E5F6-7890-ABCD-20000000000D', 'LINEITEM_LINEITEM', 'TROAP_LI_LI_LINK',
            '[{"name": "PARENT_SRC_KEY", "hash": 1}, {"name": "CHILD_SRC_KEY", "hash": 1}, {"name": "LABEL", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "INFO", "hash": 0}]', '["PARENT_HUB_ID", "CHILD_HUB_ID", "LABEL", "VALUE", "INFO"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

GO
