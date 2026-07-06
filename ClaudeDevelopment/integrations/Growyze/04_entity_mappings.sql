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
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "INVITEM_ID"]',
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
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "LOCATION_ID"]',
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
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_NAME", "hash": 0}, {"name": "SUPPLIER_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID"]',
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
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2"]',
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
