/* ============================================================================
   Mews Integration - Entity Mappings (Hub rows)
   Target: [core].[int_mews001].[EntityMappings]

   10 hub entity mappings (#1-#15; #11/#12 retired, #13-#15 GDPR-removed)
   translated by UploadEntityMappings (Task 5)
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
     #10 LINEITEM    from MEWS_LINEITEM_ALL (tier-2 union of PROD/TAX/DISCOUNT)
     (#11/#12 retired 2026-07-03: UploadEntityMappings supports ONE mapping
      row per entity - multiple rows triple the generated column list, error
      8156. PROD/TAX/DISCOUNT now union in staging step 'Mews Line Item
      Combined' -> stage.MEWS_LINEITEM_ALL, NCRAloha precedent.)
     (#13/#14/#15 INDIVIDUAL/ADDRESS/CONTACT removed 2026-07-03 - GDPR:
      guest PII not required for current Mews reporting; purge via
      05_remove_crm_pii.sql)

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

-- #10: LINEITEM from MEWS_LINEITEM_ALL (tier-2 union of PROD/TAX/DISCOUNT)
-- Retire the three per-type mapping rows first (deployed 2026-07-03, caused
-- error 8156: UploadEntityMappings tripled the generated column list).
DELETE FROM [core].[int_mews001].[EntityMappings]
WHERE entity_name = N'LINEITEM'
  AND source_table IN (N'MEWS_LINEITEM', N'MEWS_LINEITEM_TAX', N'MEWS_LINEITEM_DISCOUNT');
GO

MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM', N'MEWS_LINEITEM_ALL')) AS src (entity_name, source_table)
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
    VALUES (N'LINEITEM', N'MEWS_LINEITEM_ALL',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "SRC_KEY", "hash": 0}]',
            N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #13/#14/#15 (INDIVIDUAL / ADDRESS / CONTACT) REMOVED 2026-07-03.
-- GDPR ruling: guest names, home addresses, and email/phone contacts are
-- personal data with no current Mews reporting need — the CRM lane is not
-- staged or loaded. 05_remove_crm_pii.sql deletes the deployed control rows
-- and purges the already-loaded rows from the org database.

/* ----------------------------------------------------------------------------
   Link entity mappings (#16-#25; #18/#19 retired, #24/#25 GDPR-removed -> 6 rows)

     #16 CUSTORDER_LOCATION  from MEWS_CUSTORDER
     #17 CUSTORDER_LINEITEM  from MEWS_LINEITEM_ALL (tier-2 union)
     (#18/#19 retired 2026-07-03 - same one-row-per-entity fix as #11/#12)
     #20 LINEITEM_PRODUCT    from MEWS_LINEITEM
     #21 LINEITEM_TAX        from MEWS_LINEITEM_TAX
     #22 DISCOUNT_LINEITEM   from MEWS_DISCOUNT_LINEITEM_LNK
     #23 CUSTORDER_REVCENTER from MEWS_CUSTORDER_REVCENTER_LNK
     (#24/#25 ADDRESS_INDIVIDUAL/CONTACT_INDIVIDUAL removed 2026-07-03 -
      GDPR CRM-lane removal)

   Spec: .superpowers/sdd/task-5-brief.md (+ plan-preamble.md for shared
   constraints)
   ---------------------------------------------------------------------------- */

-- #16: CUSTORDER_LOCATION from MEWS_CUSTORDER
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER_LOCATION', N'MEWS_CUSTORDER')) AS src (entity_name, source_table)
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
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'CUSTORDER_LOCATION', N'MEWS_CUSTORDER',
            N'[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}]',
            N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #17: CUSTORDER_LINEITEM from MEWS_LINEITEM_ALL (tier-2 union of PROD/TAX/DISCOUNT)
-- Retire the three per-type mapping rows first (same 8156 fix as #10).
DELETE FROM [core].[int_mews001].[EntityMappings]
WHERE entity_name = N'CUSTORDER_LINEITEM'
  AND source_table IN (N'MEWS_LINEITEM', N'MEWS_LINEITEM_TAX', N'MEWS_LINEITEM_DISCOUNT');
GO

MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER_LINEITEM', N'MEWS_LINEITEM_ALL')) AS src (entity_name, source_table)
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
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'CUSTORDER_LINEITEM', N'MEWS_LINEITEM_ALL',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #20: LINEITEM_PRODUCT from MEWS_LINEITEM
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM_PRODUCT', N'MEWS_LINEITEM')) AS src (entity_name, source_table)
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
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LINEITEM_PRODUCT', N'MEWS_LINEITEM',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #21: LINEITEM_TAX from MEWS_LINEITEM_TAX
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LINEITEM_TAX', N'MEWS_LINEITEM_TAX')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "TAX_KEY", "hash": 1}]',
        entity_columns      = N'["LINEITEM_HUB_ID", "TAX_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LINEITEM_TAX', N'MEWS_LINEITEM_TAX',
            N'[{"name": "SRC_KEY", "hash": 1}, {"name": "TAX_KEY", "hash": 1}]',
            N'["LINEITEM_HUB_ID", "TAX_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #22: DISCOUNT_LINEITEM from MEWS_DISCOUNT_LINEITEM_LNK
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'DISCOUNT_LINEITEM', N'MEWS_DISCOUNT_LINEITEM_LNK')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "DISCOUNT_KEY", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        entity_columns      = N'["DISCOUNT_HUB_ID", "LINEITEM_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'DISCOUNT_LINEITEM', N'MEWS_DISCOUNT_LINEITEM_LNK',
            N'[{"name": "DISCOUNT_KEY", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
            N'["DISCOUNT_HUB_ID", "LINEITEM_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #23: CUSTORDER_REVCENTER from MEWS_CUSTORDER_REVCENTER_LNK
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'CUSTORDER_REVCENTER', N'MEWS_CUSTORDER_REVCENTER_LNK')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "REVC_KEY", "hash": 1}]',
        entity_columns      = N'["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'CUSTORDER_REVCENTER', N'MEWS_CUSTORDER_REVCENTER_LNK',
            N'[{"name": "HEADER_ID", "hash": 1}, {"name": "REVC_KEY", "hash": 1}]',
            N'["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO

-- #24/#25 (ADDRESS_INDIVIDUAL / CONTACT_INDIVIDUAL) REMOVED 2026-07-03 with
-- the GDPR CRM-lane removal (see #13-#15 note). Deployed rows are deleted and
-- loaded link data purged by 05_remove_crm_pii.sql.
