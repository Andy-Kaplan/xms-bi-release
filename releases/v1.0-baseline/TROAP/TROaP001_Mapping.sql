-- ============================================
-- Entity Mappings Export
-- Source: UAT [core].[int_troap001].[EntityMappings]
-- Generated: 2026-06-02 10:45:23
-- Total Records: 22
-- ============================================

-- entity_name=CHANNEL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'CHANNEL')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_CHANNEL_LINK',
        [source_columns] = N'[{"name": "CHANNEL_SRC_KEY", "hash": 1}, {"name": "CHANNEL_NAME", "hash": 0}, {"name": "CHANNEL_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:54.627',
        [updated_at] = '2026-03-17 16:16:54.627',
        [is_active] = 1
    WHERE [entity_name] = N'CHANNEL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CHANNEL', N'TROAP_CHANNEL_LINK', N'[{"name": "CHANNEL_SRC_KEY", "hash": 1}, {"name": "CHANNEL_NAME", "hash": 0}, {"name": "CHANNEL_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:54.627', '2026-03-17 16:16:54.627', 1);
END
GO
-- entity_name=CHANNEL_CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'CHANNEL_CUSTORDER')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_CHANNEL_CUSTORDER_LNK',
        [source_columns] = N'[{"name": "CHANNEL_SRC_KEY", "hash": 1}, {"name": "CUSTORDER_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["CHANNEL_HUB_ID", "CUSTORDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:56.130',
        [updated_at] = '2026-03-17 16:16:56.130',
        [is_active] = 1
    WHERE [entity_name] = N'CHANNEL_CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CHANNEL_CUSTORDER', N'TROAP_CHANNEL_CUSTORDER_LNK', N'[{"name": "CHANNEL_SRC_KEY", "hash": 1}, {"name": "CUSTORDER_SRC_KEY", "hash": 1}]', N'["CHANNEL_HUB_ID", "CUSTORDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:56.130', '2026-03-17 16:16:56.130', 1);
END
GO
-- entity_name=CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_ORDER',
        [source_columns] = N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "GRAND_TOTAL", "hash": 0}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "DISCOUNT_GROSS_SRC", "hash": 0}, {"name": "SVC_CHARGE_TOTAL", "hash": 0}, {"name": "SVC_CHARGE_TOTAL_SRC", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "GROSS_SALES_SRC", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "TAX_TOTAL_SRC", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "NET_SALES_SRC", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "ITEM_COUNT_SRC", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TABLE_NO", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "DISCOUNT_NET", "hash": 0}, {"name": "DISCOUNT_NET_SRC", "hash": 0}, {"name": "DISCOUNT_TAX", "hash": 0}, {"name": "DISCOUNT_TAX_SRC", "hash": 0}, {"name": "TENDERED_SALES", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:54.720',
        [updated_at] = '2026-03-17 16:16:54.720',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER', N'TROAP_ORDER', N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "GRAND_TOTAL", "hash": 0}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "DISCOUNT_GROSS_SRC", "hash": 0}, {"name": "SVC_CHARGE_TOTAL", "hash": 0}, {"name": "SVC_CHARGE_TOTAL_SRC", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "GROSS_SALES_SRC", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "TAX_TOTAL_SRC", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "NET_SALES_SRC", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "ITEM_COUNT_SRC", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TABLE_NO", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "DISCOUNT_NET", "hash": 0}, {"name": "DISCOUNT_NET_SRC", "hash": 0}, {"name": "DISCOUNT_TAX", "hash": 0}, {"name": "DISCOUNT_TAX_SRC", "hash": 0}, {"name": "TENDERED_SALES", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]', N'["HUB_ID", "GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:54.720', '2026-03-17 16:16:54.720', 1);
END
GO
-- entity_name=CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_CUSTORDER_LI_LNK',
        [source_columns] = N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "LI_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "LINEITEM_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.437',
        [updated_at] = '2026-03-17 16:16:55.437',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LINEITEM', N'TROAP_CUSTORDER_LI_LNK', N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "LI_SRC_KEY", "hash": 1}]', N'["CUSTORDER_HUB_ID", "LINEITEM_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.437', '2026-03-17 16:16:55.437', 1);
END
GO
-- entity_name=CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_LOC_CUSTORDER_LNK',
        [source_columns] = N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "LOC_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:56.193',
        [updated_at] = '2026-03-17 16:16:56.193',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LOCATION', N'TROAP_LOC_CUSTORDER_LNK', N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "LOC_SRC_KEY", "hash": 1}]', N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:56.193', '2026-03-17 16:16:56.193', 1);
END
GO
-- entity_name=CUSTORDER_REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_REVCENTER')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_REVCENTER_CUSTORDER_LNK',
        [source_columns] = N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "REVCENTER_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:56.273',
        [updated_at] = '2026-03-17 16:16:56.273',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_REVCENTER', N'TROAP_REVCENTER_CUSTORDER_LNK', N'[{"name": "CUSTORDER_SRC_KEY", "hash": 1}, {"name": "REVCENTER_SRC_KEY", "hash": 1}]', N'["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:56.273', '2026-03-17 16:16:56.273', 1);
END
GO
-- entity_name=DEAL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'DEAL')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_DEAL',
        [source_columns] = N'[{"name": "DEAL_SRC_KEY", "hash": 1}, {"name": "DEAL_NAME", "hash": 0}, {"name": "DEAL_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "DEAL_NAME", "DEAL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:54.973',
        [updated_at] = '2026-03-17 16:16:54.973',
        [is_active] = 1
    WHERE [entity_name] = N'DEAL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DEAL', N'TROAP_DEAL', N'[{"name": "DEAL_SRC_KEY", "hash": 1}, {"name": "DEAL_NAME", "hash": 0}, {"name": "DEAL_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "DEAL_NAME", "DEAL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:54.973', '2026-03-17 16:16:54.973', 1);
END
GO
-- entity_name=DEAL_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'DEAL_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_DEAL_LI_LNK',
        [source_columns] = N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "DEAL_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "DEAL_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.813',
        [updated_at] = '2026-03-17 16:16:55.813',
        [is_active] = 1
    WHERE [entity_name] = N'DEAL_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DEAL_LINEITEM', N'TROAP_DEAL_LI_LNK', N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "DEAL_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "DEAL_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.813', '2026-03-17 16:16:55.813', 1);
END
GO
-- entity_name=DISCOUNT
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'DISCOUNT')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_DISC',
        [source_columns] = N'[{"name": "DISC_SRC_KEY", "hash": 1}, {"name": "DISC_NAME", "hash": 0}, {"name": "DISC_ID_RAW", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "DISCOUNT_NAME", "DISCOUNT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.063',
        [updated_at] = '2026-03-17 16:16:55.063',
        [is_active] = 1
    WHERE [entity_name] = N'DISCOUNT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DISCOUNT', N'TROAP_DISC', N'[{"name": "DISC_SRC_KEY", "hash": 1}, {"name": "DISC_NAME", "hash": 0}, {"name": "DISC_ID_RAW", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "DISCOUNT_NAME", "DISCOUNT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.063', '2026-03-17 16:16:55.063', 1);
END
GO
-- entity_name=DISCOUNT_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'DISCOUNT_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_DISC_LI_LNK',
        [source_columns] = N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "DISC_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "DISCOUNT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.910',
        [updated_at] = '2026-03-17 16:16:55.910',
        [is_active] = 1
    WHERE [entity_name] = N'DISCOUNT_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DISCOUNT_LINEITEM', N'TROAP_DISC_LI_LNK', N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "DISC_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "DISCOUNT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.910', '2026-03-17 16:16:55.910', 1);
END
GO
-- entity_name=LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID_RAW", "hash": 0}, {"name": "ITEM_TYPE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "UNIT_PRICE", "hash": 0}, {"name": "TOTAL_PRICE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "QUANTITY_INV", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "GROSS_VALUE", "NET_VALUE", "ORDER_DATE", "TRADING_DATE", "TAX_VALUE", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.303',
        [updated_at] = '2026-03-17 16:16:55.303',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM', N'TROAP_LINE_ITEM_DETAIL', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID_RAW", "hash": 0}, {"name": "ITEM_TYPE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "UNIT_PRICE", "hash": 0}, {"name": "TOTAL_PRICE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "QUANTITY_INV", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}]', N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "GROSS_VALUE", "NET_VALUE", "ORDER_DATE", "TRADING_DATE", "TAX_VALUE", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.303', '2026-03-17 16:16:55.303', 1);
END
GO
-- entity_name=LINEITEM_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_LI_LI_LNK',
        [source_columns] = N'[{"name": "PARENT_LI_SRC_KEY", "hash": 1}, {"name": "LI_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:56.053',
        [updated_at] = '2026-03-17 16:16:56.053',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_LINEITEM', N'TROAP_LI_LI_LNK', N'[{"name": "PARENT_LI_SRC_KEY", "hash": 1}, {"name": "LI_SRC_KEY", "hash": 1}]', N'["PARENT_HUB_ID", "CHILD_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:56.053', '2026-03-17 16:16:56.053', 1);
END
GO
-- entity_name=LINEITEM_MOD
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_MOD')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_MOD_LI_LNK',
        [source_columns] = N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "MOD_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "MOD_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.630',
        [updated_at] = '2026-03-17 16:16:55.630',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_MOD', N'TROAP_MOD_LI_LNK', N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "MOD_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "MOD_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.630', '2026-03-17 16:16:55.630', 1);
END
GO
-- entity_name=LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_PROD_LI_LNK',
        [source_columns] = N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "PROD_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.537',
        [updated_at] = '2026-03-17 16:16:55.537',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_PRODUCT', N'TROAP_PROD_LI_LNK', N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "PROD_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.537', '2026-03-17 16:16:55.537', 1);
END
GO
-- entity_name=LINEITEM_SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_SVCCHARGE')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_SVC_LI_LNK',
        [source_columns] = N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "SVC_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "SVCCHARGE_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.987',
        [updated_at] = '2026-03-17 16:16:55.987',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_SVCCHARGE', N'TROAP_SVC_LI_LNK', N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "SVC_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "SVCCHARGE_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.987', '2026-03-17 16:16:55.987', 1);
END
GO
-- entity_name=LINEITEM_TENDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_TENDER')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_TEND_LI_LNK',
        [source_columns] = N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "TEND_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "TENDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.720',
        [updated_at] = '2026-03-17 16:16:55.720',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_TENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_TENDER', N'TROAP_TEND_LI_LNK', N'[{"name": "LI_SRC_KEY", "hash": 1}, {"name": "TEND_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "TENDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.720', '2026-03-17 16:16:55.720', 1);
END
GO
-- entity_name=LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'LOCATION')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_LOCATION',
        [source_columns] = N'[{"name": "LOC_SRC_KEY", "hash": 1}, {"name": "LOC_NAME", "hash": 0}, {"name": "LOC_ID", "hash": 0}, {"name": "LOC_POSTCODE", "hash": 0}, {"name": "LOC_LONGITUDE", "hash": 0}, {"name": "LOC_LATITUDE", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "ATTR_1", "ATTR_2", "ATTR_3", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:54.847',
        [updated_at] = '2026-03-17 16:16:54.847',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION', N'TROAP_LOCATION', N'[{"name": "LOC_SRC_KEY", "hash": 1}, {"name": "LOC_NAME", "hash": 0}, {"name": "LOC_ID", "hash": 0}, {"name": "LOC_POSTCODE", "hash": 0}, {"name": "LOC_LONGITUDE", "hash": 0}, {"name": "LOC_LATITUDE", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]', N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "ATTR_1", "ATTR_2", "ATTR_3", "BOTTOM_LEVEL", "LEVEL_NAME"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:54.847', '2026-03-17 16:16:54.847', 1);
END
GO
-- entity_name=MOD
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'MOD')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_MODS',
        [source_columns] = N'[{"name": "MOD_SRC_KEY", "hash": 1}, {"name": "MOD_NAME", "hash": 0}, {"name": "MOD_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "MOD_NAME", "MOD_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:54.887',
        [updated_at] = '2026-03-17 16:16:54.887',
        [is_active] = 1
    WHERE [entity_name] = N'MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'MOD', N'TROAP_MODS', N'[{"name": "MOD_SRC_KEY", "hash": 1}, {"name": "MOD_NAME", "hash": 0}, {"name": "MOD_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "MOD_NAME", "MOD_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:54.887', '2026-03-17 16:16:54.887', 1);
END
GO
-- entity_name=PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'PRODUCT')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_PROD',
        [source_columns] = N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_NAME", "hash": 0}, {"name": "PARENT_ID_RAW", "hash": 0}, {"name": "ITEM_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "PRODUCT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:54.760',
        [updated_at] = '2026-03-17 16:16:54.760',
        [is_active] = 1
    WHERE [entity_name] = N'PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'PRODUCT', N'TROAP_PROD', N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_NAME", "hash": 0}, {"name": "PARENT_ID_RAW", "hash": 0}, {"name": "ITEM_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "PRODUCT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:54.760', '2026-03-17 16:16:54.760', 1);
END
GO
-- entity_name=REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'REVCENTER')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_REVCENTER',
        [source_columns] = N'[{"name": "REVCENTER_SRC_KEY", "hash": 1}, {"name": "REVC_NAME", "hash": 0}, {"name": "REVC_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "REVC_NAME", "REVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.397',
        [updated_at] = '2026-03-17 16:16:55.397',
        [is_active] = 1
    WHERE [entity_name] = N'REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'REVCENTER', N'TROAP_REVCENTER', N'[{"name": "REVCENTER_SRC_KEY", "hash": 1}, {"name": "REVC_NAME", "hash": 0}, {"name": "REVC_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "REVC_NAME", "REVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.397', '2026-03-17 16:16:55.397', 1);
END
GO
-- entity_name=SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'SVCCHARGE')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_SVC',
        [source_columns] = N'[{"name": "SVC_SRC_KEY", "hash": 1}, {"name": "SVC_NAME", "hash": 0}, {"name": "SVC_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "SVCCHARGE_NAME", "SVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.160',
        [updated_at] = '2026-03-17 16:16:55.160',
        [is_active] = 1
    WHERE [entity_name] = N'SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'SVCCHARGE', N'TROAP_SVC', N'[{"name": "SVC_SRC_KEY", "hash": 1}, {"name": "SVC_NAME", "hash": 0}, {"name": "SVC_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "SVCCHARGE_NAME", "SVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.160', '2026-03-17 16:16:55.160', 1);
END
GO
-- entity_name=TENDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[EntityMappings] WHERE [entity_name] = N'TENDER')
BEGIN
    UPDATE [core].[int_troap001].[EntityMappings]
    SET
        [source_table] = N'TROAP_TENDER',
        [source_columns] = N'[{"name": "TEND_SRC_KEY", "hash": 1}, {"name": "TENDER_NAME", "hash": 0}, {"name": "TEND_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "TENDER_NAME", "TENDER_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-17 16:16:55.207',
        [updated_at] = '2026-03-17 16:16:55.207',
        [is_active] = 1
    WHERE [entity_name] = N'TENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'TENDER', N'TROAP_TENDER', N'[{"name": "TEND_SRC_KEY", "hash": 1}, {"name": "TENDER_NAME", "hash": 0}, {"name": "TEND_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "TENDER_NAME", "TENDER_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-17 16:16:55.207', '2026-03-17 16:16:55.207', 1);
END
GO
