-- Data Vault Entity Mappings Export
-- Schema: int_ncraloha001
-- Generated: 2026-01-12 14:26:51
-- Total Mappings: 34

-- Entity: CHANNEL
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CHANNEL')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_CHANNEL_LINK',
        source_columns = '[{"name": "CHANNEL", "hash": 1}, {"name": "CHANNEL", "hash": 0}, {"name": "CHANNEL", "hash": 0}, {"name": "LEVE_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('76C1638D-7921-4388-991E-587D3341D1DE', 'CHANNEL', 'NCR_CHANNEL_LINK',
            '[{"name": "CHANNEL", "hash": 1}, {"name": "CHANNEL", "hash": 0}, {"name": "CHANNEL", "hash": 0}, {"name": "LEVE_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CHANNEL_CUSTORDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CHANNEL_CUSTORDER')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_CHANNEL_LINK',
        source_columns = '[{"name": "HEADER_SRC_KEY", "hash": 1}, {"name": "CHANNEL", "hash": 1}]',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('B1914774-8154-47C3-B744-301B217891D9', 'CHANNEL_CUSTORDER', 'NCR_CHANNEL_LINK',
            '[{"name": "HEADER_SRC_KEY", "hash": 1}, {"name": "CHANNEL", "hash": 1}]', '["CUSTORDER_HUB_ID", "CHANNEL_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: COMP_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'COMP_LINEITEM')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'COMP_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "COMP_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'COMP_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('4448469B-075D-42BB-AF68-F2E50A113C27', 'COMP_LINEITEM', 'COMP_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "COMP_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CUSTORDER')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "NET_SALES_SRC", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "GROSS_SALES_SRC", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "SVC_CHARGE__TOTAL", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "PAYMENT", "hash": 0}]',
        entity_columns = '["HUB_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "GROSS_SALES", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "ORDER_INFO", "EXTERNAL_REFERENCE", "TRADING_DATE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('53B934B4-68DE-41D5-BF0E-92848E72EA3F', 'CUSTORDER', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "NET_SALES_SRC", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "GROSS_SALES_SRC", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "SVC_CHARGE__TOTAL", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "PAYMENT", "hash": 0}]', '["HUB_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "GROSS_SALES", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "ORDER_INFO", "EXTERNAL_REFERENCE", "TRADING_DATE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_EMPLOYEE
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CUSTORDER_EMPLOYEE')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "EMPLOYEE_SRC_KEY", "hash": 1}]',
        entity_columns = '["CUSTORDER_HUB_ID", "EMPLOYEE_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER_EMPLOYEE';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('292D4727-6AFB-459D-8EE7-5889DD63964E', 'CUSTORDER_EMPLOYEE', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "EMPLOYEE_SRC_KEY", "hash": 1}]', '["CUSTORDER_HUB_ID", "EMPLOYEE_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CUSTORDER_LINEITEM')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('F3FEBA17-DBC7-4F2C-A631-F6E88755519B', 'CUSTORDER_LINEITEM', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]', '["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_LOCATION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CUSTORDER_LOCATION')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('04DB334E-CF10-4D8E-838D-E94C13A9CFD6', 'CUSTORDER_LOCATION', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]', '["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CUSTORDER_OCCASION')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('F1EB90C2-71AA-44DA-82A2-8E7605CC1F74', 'CUSTORDER_OCCASION', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]', '["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_REVCENTER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'CUSTORDER_REVCENTER')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "REVENUE_CENTER_SRC_KEY", "hash": 1}]',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('4AE0BA1D-3660-4982-BD55-BEFB7BBA5962', 'CUSTORDER_REVCENTER', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "REVENUE_CENTER_SRC_KEY", "hash": 1}]', '["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DEAL
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'DEAL')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_DEAL',
        source_columns = '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["PARENT_ID", "HUB_ID", "DEAL_ID", "LEVEL_NAME", "DEAL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'DEAL';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('09C65B9B-7C24-4C74-92B7-DA21C350C78F', 'DEAL', 'NCR_DEAL',
            '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["PARENT_ID", "HUB_ID", "DEAL_ID", "LEVEL_NAME", "DEAL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DEAL_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'DEAL_LINEITEM')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'DEAL_LI_LNK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('97CB2BAC-A47F-453B-87FE-98345360A527', 'DEAL_LINEITEM', 'DEAL_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "DEAL_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DISCOUNT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'DISCOUNT')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_DISC',
        source_columns = '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["PARENT_ID", "HUB_ID", "DISCOUNT_ID", "LEVEL_NAME", "DISCOUNT_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'DISCOUNT';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('C0BA8F0A-AF06-46A5-8FC5-ABD6256263F0', 'DISCOUNT', 'NCR_DISC',
            '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["PARENT_ID", "HUB_ID", "DISCOUNT_ID", "LEVEL_NAME", "DISCOUNT_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: DISCOUNT_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'DISCOUNT_LINEITEM')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'DISC_LI_LNK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('2A5A3857-9287-47B1-9EC7-2BE9FB8D7461', 'DISCOUNT_LINEITEM', 'DISC_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "DISCOUNT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: EMPLOYEE
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'EMPLOYEE')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_EMP_TIME',
        source_columns = '[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "Surname", "hash": 0}, {"name": "FirstName", "hash": 0}, {"name": "MiddleNames", "hash": 0}]',
        entity_columns = '["HUB_ID", "SURNAME", "FIRST_NAME", "MIDDLE_NAME"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'EMPLOYEE';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('6E959C5B-93AC-432E-AC07-E5EA65063B51', 'EMPLOYEE', 'NCR_EMP_TIME',
            '[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "Surname", "hash": 0}, {"name": "FirstName", "hash": 0}, {"name": "MiddleNames", "hash": 0}]', '["HUB_ID", "SURNAME", "FIRST_NAME", "MIDDLE_NAME"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: EMPLOYEE_JOB_TIMECARD
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'EMPLOYEE_JOB_TIMECARD')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_EMP_TIME',
        source_columns = '[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "JOB_SRC_KEY", "hash": 1}, {"name": "TIMECARD_SRC_KEY", "hash": 1}]',
        entity_columns = '["EMPLOYEE_HUB_ID", "JOB_HUB_ID", "TIMECARD_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'EMPLOYEE_JOB_TIMECARD';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('0FC75016-C249-4FB7-8639-C14E2FBE0766', 'EMPLOYEE_JOB_TIMECARD', 'NCR_EMP_TIME',
            '[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "JOB_SRC_KEY", "hash": 1}, {"name": "TIMECARD_SRC_KEY", "hash": 1}]', '["EMPLOYEE_HUB_ID", "JOB_HUB_ID", "TIMECARD_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: EMPLOYEE_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'EMPLOYEE_LINEITEM')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "EMPLOYEE_SRC_SUB", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "EMPLOYEE_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'EMPLOYEE_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('BEAF5C52-6F08-4840-8CF8-084F6CA2080C', 'EMPLOYEE_LINEITEM', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "EMPLOYEE_SRC_SUB", "hash": 1}]', '["LINEITEM_HUB_ID", "EMPLOYEE_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: JOB
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'JOB')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_EMP_TIME',
        source_columns = '[{"name": "JOB_SRC_KEY", "hash": 1}, {"name": "job_label", "hash": 0}, {"name": "JOB_SRC_KEY", "hash": 0}]',
        entity_columns = '["HUB_ID", "JOB_NAME", "JOB_CODE"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'JOB';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('6927795E-1261-4248-9EF4-C67D5DAFE110', 'JOB', 'NCR_EMP_TIME',
            '[{"name": "JOB_SRC_KEY", "hash": 1}, {"name": "job_label", "hash": 0}, {"name": "JOB_SRC_KEY", "hash": 0}]', '["HUB_ID", "JOB_NAME", "JOB_CODE"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LINE_ITEM_DETAIL',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "QUANTITY_INV", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        entity_columns = '["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('14FE26C8-78B3-4406-89BF-F3BF173EF632', 'LINEITEM', 'NCR_LINE_ITEM_DETAIL',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "QUANTITY_INV", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]', '["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM_LINEITEM')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'LI_LI_LINK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('ABCC7720-9950-4BCE-A8C4-67A3D8FA8CEB', 'LINEITEM_LINEITEM', 'LI_LI_LINK',
            '[{"name": "PARENT_SRC_KEY", "hash": 1}, {"name": "CHILD_SRC_KEY", "hash": 1}, {"name": "LABEL", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "INFO", "hash": 0}]', '["PARENT_HUB_ID", "CHILD_HUB_ID", "LABEL", "VALUE", "INFO"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_MOD
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM_MOD')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'MOD_LI_LNK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A63B9C8C-F688-4C25-BDB5-EFF16E1E6A1B', 'LINEITEM_MOD', 'MOD_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "MOD_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM_OCCASION')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'OCC_LI_LNK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('975FFE66-C3B2-405A-801A-419E9061EBD3', 'LINEITEM_OCCASION', 'OCC_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM_PRODUCT')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'PROD_LI_LNK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('F868F59B-16E1-428A-BE1F-11117C70E5AE', 'LINEITEM_PRODUCT', 'PROD_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_SVCCHARGE
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM_SVCCHARGE')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'SVC_LI_LNK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('476038D3-6821-416B-90BD-0F716F7160AC', 'LINEITEM_SVCCHARGE', 'SVC_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "SVCCHARGE_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_TAX
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM_TAX')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'TAX_LI_LNK',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        entity_columns = '["LINEITEM_HUB_ID", "TAX_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM_TAX';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('49B4E466-2494-49AD-8781-2AE2C04456C4', 'LINEITEM_TAX', 'TAX_LI_LNK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "TAX_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_TENDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LINEITEM_TENDER')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'TEND_LI_LINK',
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
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('5DC555DF-1141-4D8A-BC4E-5D8C4E27F170', 'LINEITEM_TENDER', 'TEND_LI_LINK',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', '["LINEITEM_HUB_ID", "TENDER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LOCATION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LOCATION')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_LOCATION',
        source_columns = '[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "name", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]',
        entity_columns = '["HUB_ID", "LOCATION_ID", "LOCATION_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LOCATION';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('CB13F80A-034D-44DC-876B-F080236CCF77', 'LOCATION', 'NCR_LOCATION',
            '[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "name", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]', '["HUB_ID", "LOCATION_ID", "LOCATION_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LOCATION_OCCASION_PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'LOC_OCC_PROD_LNK',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "OCCASSION_SRC_KEY", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]',
        entity_columns = '["PRODUCT_HUB_ID", "PRODUCT_ID", "OCCASION_HUB_ID", "LOCATION_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('3CE65A7E-0B22-4D1D-94FE-8860FD920994', 'LOCATION_OCCASION_PRODUCT', 'LOC_OCC_PROD_LNK',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "OCCASSION_SRC_KEY", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]', '["PRODUCT_HUB_ID", "PRODUCT_ID", "OCCASION_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: MOD
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'MOD')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_MODS',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 0}]',
        entity_columns = '["HUB_ID", "PARENT_ID", "MOD_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "MOD_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'MOD';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('4C59AF9E-ECB3-4713-8327-09FC36581A7F', 'MOD', 'NCR_MODS',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 0}]', '["HUB_ID", "PARENT_ID", "MOD_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "MOD_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'OCCASION')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_OCCASSION',
        source_columns = '[{"name": "orderMode_id", "hash": 1}, {"name": "orderMode_id", "hash": 0}, {"name": "orderMode_label", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'OCCASION';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('680B6CE1-498F-46DB-8AEA-345FA10A7058', 'OCCASION', 'NCR_OCCASSION',
            '[{"name": "orderMode_id", "hash": 1}, {"name": "orderMode_id", "hash": 0}, {"name": "orderMode_label", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'PRODUCT')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_PROD',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]',
        entity_columns = '["HUB_ID", "PRODUCT_ID", "PARENT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'PRODUCT';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('C9757978-E131-4AC0-AB36-FEE34FBD94F0', 'PRODUCT', 'NCR_PROD',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]', '["HUB_ID", "PRODUCT_ID", "PARENT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: REVCENTER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'REVCENTER')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_REVC',
        source_columns = '[{"name": "revenueCenter_id", "hash": 1}, {"name": "revenueCenter_id", "hash": 0}, {"name": "revenueCenter_label", "hash": 0}, {"name": "Level_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["HUB_ID", "REVC_ID", "REVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'REVCENTER';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('02F53312-49F5-45AF-8452-E4F81F953CCE', 'REVCENTER', 'NCR_REVC',
            '[{"name": "revenueCenter_id", "hash": 1}, {"name": "revenueCenter_id", "hash": 0}, {"name": "revenueCenter_label", "hash": 0}, {"name": "Level_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["HUB_ID", "REVC_ID", "REVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: SVCCHARGE
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'SVCCHARGE')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_SVC',
        source_columns = '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["PARENT_ID", "HUB_ID", "SVC_ID", "LEVEL_NAME", "SVCCHARGE_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('13DD91C0-E68F-48A9-94D8-B73B7B2DA0E6', 'SVCCHARGE', 'NCR_SVC',
            '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["PARENT_ID", "HUB_ID", "SVC_ID", "LEVEL_NAME", "SVCCHARGE_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: TAX
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'TAX')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_TAX',
        source_columns = '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        entity_columns = '["PARENT_ID", "HUB_ID", "TAX_ID", "LEVEL_NAME", "TAX_NAME", "BOTTOM_LEVEL"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'TAX';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('E77B684C-12C9-4323-AB3B-B6A2863EFF3F', 'TAX', 'NCR_TAX',
            '[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', '["PARENT_ID", "HUB_ID", "TAX_ID", "LEVEL_NAME", "TAX_NAME", "BOTTOM_LEVEL"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: TIMECARD
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_ncraloha001.EntityMappings WHERE entity_name = 'TIMECARD')
BEGIN
    UPDATE core.int_ncraloha001.EntityMappings
    SET source_table = 'NCR_EMP_TIME',
        source_columns = '[{"name": "TIMECARD_SRC_KEY", "hash": 1}, {"name": "TIMECARD_DATE", "hash": 0}, {"name": "TIMECARD_START_TIMESTAMP", "hash": 0}, {"name": "TIMECARD_END_TIMESTAMP", "hash": 0}]',
        entity_columns = '["HUB_ID", "TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'TIMECARD';
END
ELSE
BEGIN
    INSERT INTO core.int_ncraloha001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('7CE8E361-5F8A-4EDB-8C50-7BAE509D01EE', 'TIMECARD', 'NCR_EMP_TIME',
            '[{"name": "TIMECARD_SRC_KEY", "hash": 1}, {"name": "TIMECARD_DATE", "hash": 0}, {"name": "TIMECARD_START_TIMESTAMP", "hash": 0}, {"name": "TIMECARD_END_TIMESTAMP", "hash": 0}]', '["HUB_ID", "TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO
