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
