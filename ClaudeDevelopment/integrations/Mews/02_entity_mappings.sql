/* ============================================================================
   Mews Integration - Entity Mappings (Hub rows)
   Target: [core].[int_mews001].[EntityMappings]

   15 hub entity mappings (#1-#15) translated by UploadEntityMappings (Task 5)
   into Data Vault Load steps. All statements use MERGE upsert pattern
   (natural key: entity_name + source_table) for idempotent re-runs.
   `id` is omitted throughout (DEFAULT NEWID()).

   Row inventory:
     #1  LOCATION    from MEWS_LOCATION
     #2  PRODUCT     from MEWS_PRODUCT
     #3  MOD         from MEWS_MOD
     #4  TAX         from MEWS_TAX
     #5  TENDER      from MEWS_TENDER
     #6  DISCOUNT    from MEWS_DISCOUNT
     #7  CHANNEL     from MEWS_CHANNEL
     #8  REVCENTER   from MEWS_REVCENTER
     #9  CUSTORDER   from MEWS_CUSTORDER
     #10 LINEITEM    from MEWS_LINEITEM
     #11 LINEITEM    from MEWS_LINEITEM_TAX
     #12 LINEITEM    from MEWS_LINEITEM_DISCOUNT
     #13 INDIVIDUAL  from MEWS_CUSTOMER
     #14 ADDRESS     from MEWS_ADDRESS
     #15 CONTACT     from MEWS_CONTACT

   Spec: .superpowers/sdd/task-4-brief.md (+ plan-preamble.md for shared
   constraints)
   Created: 2026-07-03
   ============================================================================ */

-- #1: LOCATION from MEWS_LOCATION
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LOCATION', N'MEWS_LOCATION')) AS src (entity_name, source_table)
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
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LOCATION', N'MEWS_LOCATION',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
            N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #2: PRODUCT from MEWS_PRODUCT
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'PRODUCT', N'MEWS_PRODUCT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'PRODUCT', N'MEWS_PRODUCT',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #3: MOD from MEWS_MOD
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'MOD', N'MEWS_MOD')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "MOD_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MOD_ID", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'MOD', N'MEWS_MOD',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "MOD_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MOD_ID", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #4: TAX from MEWS_TAX
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'TAX', N'MEWS_TAX')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "TAX_NAME", "hash": 0}, {"name": "TAX_ID", "hash": 0}, {"name": "TAX_MULTIPLIER", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "TAX_NAME", "TAX_ID", "TAX_MULTIPLIER", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'TAX', N'MEWS_TAX',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "TAX_NAME", "hash": 0}, {"name": "TAX_ID", "hash": 0}, {"name": "TAX_MULTIPLIER", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "TAX_NAME", "TAX_ID", "TAX_MULTIPLIER", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #5: TENDER from MEWS_TENDER
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'TENDER', N'MEWS_TENDER')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "TENDER_NAME", "hash": 0}, {"name": "TENDER_ID", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'TENDER', N'MEWS_TENDER',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "TENDER_NAME", "hash": 0}, {"name": "TENDER_ID", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #6: DISCOUNT from MEWS_DISCOUNT
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'DISCOUNT', N'MEWS_DISCOUNT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "DISCOUNT_NAME", "hash": 0}, {"name": "DISCOUNT_ID", "hash": 0}, {"name": "VALUE_TYPE", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "IS_WASTE", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "DISCOUNT_NAME", "DISCOUNT_ID", "VALUE_TYPE", "VALUE", "IS_WASTE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'DISCOUNT', N'MEWS_DISCOUNT',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "DISCOUNT_NAME", "hash": 0}, {"name": "DISCOUNT_ID", "hash": 0}, {"name": "VALUE_TYPE", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "IS_WASTE", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "DISCOUNT_NAME", "DISCOUNT_ID", "VALUE_TYPE", "VALUE", "IS_WASTE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #7: CHANNEL from MEWS_CHANNEL
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'CHANNEL', N'MEWS_CHANNEL')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "CHANNEL_NAME", "hash": 0}, {"name": "CHANNEL_ID", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'CHANNEL', N'MEWS_CHANNEL',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "CHANNEL_NAME", "hash": 0}, {"name": "CHANNEL_ID", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #8: REVCENTER from MEWS_REVCENTER
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'REVCENTER', N'MEWS_REVCENTER')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "REVC_NAME", "hash": 0}, {"name": "REVC_ID", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'REVCENTER', N'MEWS_REVCENTER',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "REVC_NAME", "hash": 0}, {"name": "REVC_ID", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            N'["HUB_ID", "REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #9: CUSTORDER from MEWS_CUSTORDER
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER', N'MEWS_CUSTORDER')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TABLE_NO", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "GRAND_TOTAL", "DISCOUNT_GROSS", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "TRADING_DATE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'CUSTORDER', N'MEWS_CUSTORDER',
            N'[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TABLE_NO", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
            N'["HUB_ID", "GRAND_TOTAL", "DISCOUNT_GROSS", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "TRADING_DATE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #10: LINEITEM from MEWS_LINEITEM
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM', N'MEWS_LINEITEM')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LINEITEM', N'MEWS_LINEITEM',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}]',
            N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #11: LINEITEM from MEWS_LINEITEM_TAX
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM', N'MEWS_LINEITEM_TAX')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LINEITEM', N'MEWS_LINEITEM_TAX',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}]',
            N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #12: LINEITEM from MEWS_LINEITEM_DISCOUNT
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM', N'MEWS_LINEITEM_DISCOUNT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LINEITEM', N'MEWS_LINEITEM_DISCOUNT',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}]',
            N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #13: INDIVIDUAL from MEWS_CUSTOMER
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'INDIVIDUAL', N'MEWS_CUSTOMER')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "FORENAME", "hash": 0}, {"name": "SURNAME", "hash": 0}, {"name": "MIDDLE_NAMES", "hash": 0}, {"name": "TITLE", "hash": 0}, {"name": "GENDER", "hash": 0}, {"name": "DOB", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "FORENAME", "SURNAME", "MIDDLE_NAMES", "TITLE", "GENDER", "DOB"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'INDIVIDUAL', N'MEWS_CUSTOMER',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "FORENAME", "hash": 0}, {"name": "SURNAME", "hash": 0}, {"name": "MIDDLE_NAMES", "hash": 0}, {"name": "TITLE", "hash": 0}, {"name": "GENDER", "hash": 0}, {"name": "DOB", "hash": 0}]',
            N'["HUB_ID", "FORENAME", "SURNAME", "MIDDLE_NAMES", "TITLE", "GENDER", "DOB"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #14: ADDRESS from MEWS_ADDRESS
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'ADDRESS', N'MEWS_ADDRESS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "ADDRESS", "hash": 0}, {"name": "POSTCODE", "hash": 0}, {"name": "REGION", "hash": 0}, {"name": "COUNTRY", "hash": 0}, {"name": "TOWN", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "ADDRESS", "POSTCODE", "REGION", "COUNTRY", "TOWN"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'ADDRESS', N'MEWS_ADDRESS',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "ADDRESS", "hash": 0}, {"name": "POSTCODE", "hash": 0}, {"name": "REGION", "hash": 0}, {"name": "COUNTRY", "hash": 0}, {"name": "TOWN", "hash": 0}]',
            N'["HUB_ID", "ADDRESS", "POSTCODE", "REGION", "COUNTRY", "TOWN"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #15: CONTACT from MEWS_CONTACT
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'CONTACT', N'MEWS_CONTACT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "CONTACT", "hash": 0}, {"name": "CONTACT_TYPE", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "CONTACT", "CONTACT_TYPE"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'CONTACT', N'MEWS_CONTACT',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "CONTACT", "hash": 0}, {"name": "CONTACT_TYPE", "hash": 0}]',
            N'["HUB_ID", "CONTACT", "CONTACT_TYPE"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO
