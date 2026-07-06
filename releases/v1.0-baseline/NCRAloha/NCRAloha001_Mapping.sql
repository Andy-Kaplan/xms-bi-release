-- ============================================
-- Entity Mappings Export
-- Source: UAT [core].[int_ncraloha001].[EntityMappings]
-- Generated: 2026-06-02 10:45:23
-- Total Records: 34
-- ============================================

-- entity_name=CHANNEL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CHANNEL')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_CHANNEL_LINK',
        [source_columns] = N'[{"name": "CHANNEL", "hash": 1}, {"name": "CHANNEL", "hash": 0}, {"name": "CHANNEL", "hash": 0}, {"name": "LEVE_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.087',
        [updated_at] = '2026-01-07 10:35:12.087',
        [is_active] = 1
    WHERE [entity_name] = N'CHANNEL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CHANNEL', N'NCR_CHANNEL_LINK', N'[{"name": "CHANNEL", "hash": 1}, {"name": "CHANNEL", "hash": 0}, {"name": "CHANNEL", "hash": 0}, {"name": "LEVE_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.087', '2026-01-07 10:35:12.087', 1);
END
GO
-- entity_name=CHANNEL_CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CHANNEL_CUSTORDER')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_CHANNEL_LINK',
        [source_columns] = N'[{"name": "HEADER_SRC_KEY", "hash": 1}, {"name": "CHANNEL", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "CHANNEL_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.190',
        [updated_at] = '2026-01-07 10:35:12.190',
        [is_active] = 1
    WHERE [entity_name] = N'CHANNEL_CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CHANNEL_CUSTORDER', N'NCR_CHANNEL_LINK', N'[{"name": "HEADER_SRC_KEY", "hash": 1}, {"name": "CHANNEL", "hash": 1}]', N'["CUSTORDER_HUB_ID", "CHANNEL_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.190', '2026-01-07 10:35:12.190', 1);
END
GO
-- entity_name=COMP_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'COMP_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'COMP_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "COMP_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.230',
        [updated_at] = '2026-01-07 10:35:12.230',
        [is_active] = 1
    WHERE [entity_name] = N'COMP_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'COMP_LINEITEM', N'COMP_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "COMP_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.230', '2026-01-07 10:35:12.230', 1);
END
GO
-- entity_name=CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "NET_SALES_SRC", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "GROSS_SALES_SRC", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "SVC_CHARGE__TOTAL", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "PAYMENT", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "GROSS_SALES", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "ORDER_INFO", "EXTERNAL_REFERENCE", "TRADING_DATE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.327',
        [updated_at] = '2026-01-07 10:35:12.327',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "GRAND_TOTAL_SRC", "hash": 0}, {"name": "DISCOUNT_GROSS", "hash": 0}, {"name": "NET_SALES_SRC", "hash": 0}, {"name": "NET_SALES", "hash": 0}, {"name": "TAX_TOTAL", "hash": 0}, {"name": "GROSS_SALES_SRC", "hash": 0}, {"name": "GROSS_SALES", "hash": 0}, {"name": "SVC_CHARGE__TOTAL", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "GUEST_COUNT", "hash": 0}, {"name": "ORDER_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "PAYMENT_STATUS", "hash": 0}, {"name": "PAYMENT", "hash": 0}]', N'["HUB_ID", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "GROSS_SALES", "SVC_CHARGE_TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "ORDER_INFO", "EXTERNAL_REFERENCE", "TRADING_DATE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.327', '2026-01-07 10:35:12.327', 1);
END
GO
-- entity_name=CUSTORDER_EMPLOYEE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_EMPLOYEE')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "EMPLOYEE_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "EMPLOYEE_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.407',
        [updated_at] = '2026-01-07 10:35:12.407',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_EMPLOYEE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_EMPLOYEE', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "EMPLOYEE_SRC_KEY", "hash": 1}]', N'["CUSTORDER_HUB_ID", "EMPLOYEE_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.407', '2026-01-07 10:35:12.407', 1);
END
GO
-- entity_name=CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.510',
        [updated_at] = '2026-01-07 10:35:12.510',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LINEITEM', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]', N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.510', '2026-01-07 10:35:12.510', 1);
END
GO
-- entity_name=CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.610',
        [updated_at] = '2026-01-07 10:35:12.610',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LOCATION', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]', N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.610', '2026-01-07 10:35:12.610', 1);
END
GO
-- entity_name=CUSTORDER_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_OCCASION')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.670',
        [updated_at] = '2026-01-07 10:35:12.670',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_OCCASION', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]', N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.670', '2026-01-07 10:35:12.670', 1);
END
GO
-- entity_name=CUSTORDER_REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_REVCENTER')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "REVENUE_CENTER_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.777',
        [updated_at] = '2026-01-07 10:35:12.777',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_REVCENTER', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "REVENUE_CENTER_SRC_KEY", "hash": 1}]', N'["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.777', '2026-01-07 10:35:12.777', 1);
END
GO
-- entity_name=DEAL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'DEAL')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_DEAL',
        [source_columns] = N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["PARENT_ID", "HUB_ID", "DEAL_ID", "LEVEL_NAME", "DEAL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.853',
        [updated_at] = '2026-01-07 10:35:12.853',
        [is_active] = 1
    WHERE [entity_name] = N'DEAL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DEAL', N'NCR_DEAL', N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["PARENT_ID", "HUB_ID", "DEAL_ID", "LEVEL_NAME", "DEAL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.853', '2026-01-07 10:35:12.853', 1);
END
GO
-- entity_name=DEAL_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'DEAL_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'DEAL_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "DEAL_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:12.947',
        [updated_at] = '2026-01-07 10:35:12.947',
        [is_active] = 1
    WHERE [entity_name] = N'DEAL_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DEAL_LINEITEM', N'DEAL_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "DEAL_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:12.947', '2026-01-07 10:35:12.947', 1);
END
GO
-- entity_name=DISCOUNT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'DISCOUNT')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_DISC',
        [source_columns] = N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["PARENT_ID", "HUB_ID", "DISCOUNT_ID", "LEVEL_NAME", "DISCOUNT_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.053',
        [updated_at] = '2026-01-07 10:35:13.053',
        [is_active] = 1
    WHERE [entity_name] = N'DISCOUNT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DISCOUNT', N'NCR_DISC', N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["PARENT_ID", "HUB_ID", "DISCOUNT_ID", "LEVEL_NAME", "DISCOUNT_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.053', '2026-01-07 10:35:13.053', 1);
END
GO
-- entity_name=DISCOUNT_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'DISCOUNT_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'DISC_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "DISCOUNT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.163',
        [updated_at] = '2026-01-07 10:35:13.163',
        [is_active] = 1
    WHERE [entity_name] = N'DISCOUNT_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DISCOUNT_LINEITEM', N'DISC_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "DISCOUNT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.163', '2026-01-07 10:35:13.163', 1);
END
GO
-- entity_name=EMPLOYEE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'EMPLOYEE')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_EMP_TIME',
        [source_columns] = N'[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "Surname", "hash": 0}, {"name": "FirstName", "hash": 0}, {"name": "MiddleNames", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "SURNAME", "FIRST_NAME", "MIDDLE_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.277',
        [updated_at] = '2026-01-07 10:35:13.277',
        [is_active] = 1
    WHERE [entity_name] = N'EMPLOYEE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'EMPLOYEE', N'NCR_EMP_TIME', N'[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "Surname", "hash": 0}, {"name": "FirstName", "hash": 0}, {"name": "MiddleNames", "hash": 0}]', N'["HUB_ID", "SURNAME", "FIRST_NAME", "MIDDLE_NAME"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.277', '2026-01-07 10:35:13.277', 1);
END
GO
-- entity_name=EMPLOYEE_JOB_TIMECARD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'EMPLOYEE_JOB_TIMECARD')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_EMP_TIME',
        [source_columns] = N'[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "JOB_SRC_KEY", "hash": 1}, {"name": "TIMECARD_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["EMPLOYEE_HUB_ID", "JOB_HUB_ID", "TIMECARD_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.380',
        [updated_at] = '2026-01-07 10:35:13.380',
        [is_active] = 1
    WHERE [entity_name] = N'EMPLOYEE_JOB_TIMECARD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'EMPLOYEE_JOB_TIMECARD', N'NCR_EMP_TIME', N'[{"name": "EMP_SRC_KEY", "hash": 1}, {"name": "JOB_SRC_KEY", "hash": 1}, {"name": "TIMECARD_SRC_KEY", "hash": 1}]', N'["EMPLOYEE_HUB_ID", "JOB_HUB_ID", "TIMECARD_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.380', '2026-01-07 10:35:13.380', 1);
END
GO
-- entity_name=EMPLOYEE_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'EMPLOYEE_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EMPLOYEE_SRC_SUB", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "EMPLOYEE_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.487',
        [updated_at] = '2026-01-07 10:35:13.487',
        [is_active] = 1
    WHERE [entity_name] = N'EMPLOYEE_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'EMPLOYEE_LINEITEM', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EMPLOYEE_SRC_SUB", "hash": 1}]', N'["LINEITEM_HUB_ID", "EMPLOYEE_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.487', '2026-01-07 10:35:13.487', 1);
END
GO
-- entity_name=JOB
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'JOB')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_EMP_TIME',
        [source_columns] = N'[{"name": "JOB_SRC_KEY", "hash": 1}, {"name": "job_label", "hash": 0}, {"name": "JOB_SRC_KEY", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "JOB_NAME", "JOB_CODE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.593',
        [updated_at] = '2026-01-07 10:35:13.593',
        [is_active] = 1
    WHERE [entity_name] = N'JOB';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'JOB', N'NCR_EMP_TIME', N'[{"name": "JOB_SRC_KEY", "hash": 1}, {"name": "job_label", "hash": 0}, {"name": "JOB_SRC_KEY", "hash": 0}]', N'["HUB_ID", "JOB_NAME", "JOB_CODE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.593', '2026-01-07 10:35:13.593', 1);
END
GO
-- entity_name=LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LINE_ITEM_DETAIL',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "QUANTITY_INV", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.703',
        [updated_at] = '2026-01-07 10:35:13.703',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM', N'NCR_LINE_ITEM_DETAIL', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "TAX_VALUE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "QUANTITY_INV", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}, {"name": "ITEM_DATE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "VOID_FLAG", "hash": 0}, {"name": "LINE_ID", "hash": 0}, {"name": "LINE_ORDER", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]', N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.703', '2026-01-07 10:35:13.703', 1);
END
GO
-- entity_name=LINEITEM_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'LI_LI_LINK',
        [source_columns] = N'[{"name": "PARENT_SRC_KEY", "hash": 1}, {"name": "CHILD_SRC_KEY", "hash": 1}, {"name": "LABEL", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "INFO", "hash": 0}]',
        [entity_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "LABEL", "VALUE", "INFO"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.810',
        [updated_at] = '2026-01-07 10:35:13.810',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_LINEITEM', N'LI_LI_LINK', N'[{"name": "PARENT_SRC_KEY", "hash": 1}, {"name": "CHILD_SRC_KEY", "hash": 1}, {"name": "LABEL", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "INFO", "hash": 0}]', N'["PARENT_HUB_ID", "CHILD_HUB_ID", "LABEL", "VALUE", "INFO"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.810', '2026-01-07 10:35:13.810', 1);
END
GO
-- entity_name=LINEITEM_MOD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_MOD')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'MOD_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "MOD_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:13.920',
        [updated_at] = '2026-01-07 10:35:13.920',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_MOD', N'MOD_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "MOD_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:13.920', '2026-01-07 10:35:13.920', 1);
END
GO
-- entity_name=LINEITEM_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_OCCASION')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'OCC_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.010',
        [updated_at] = '2026-01-07 10:35:14.010',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_OCCASION', N'OCC_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCCASSION_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.010', '2026-01-07 10:35:14.010', 1);
END
GO
-- entity_name=LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'PROD_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.107',
        [updated_at] = '2026-01-07 10:35:14.107',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_PRODUCT', N'PROD_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.107', '2026-01-07 10:35:14.107', 1);
END
GO
-- entity_name=LINEITEM_SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_SVCCHARGE')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'SVC_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "SVCCHARGE_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.203',
        [updated_at] = '2026-01-07 10:35:14.203',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_SVCCHARGE', N'SVC_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "SVCCHARGE_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.203', '2026-01-07 10:35:14.203', 1);
END
GO
-- entity_name=LINEITEM_TAX
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_TAX')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'TAX_LI_LNK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "TAX_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.297',
        [updated_at] = '2026-01-07 10:35:14.297',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_TAX';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_TAX', N'TAX_LI_LNK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "TAX_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.297', '2026-01-07 10:35:14.297', 1);
END
GO
-- entity_name=LINEITEM_TENDER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_TENDER')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'TEND_LI_LINK',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "TENDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.407',
        [updated_at] = '2026-01-07 10:35:14.407',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_TENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_TENDER', N'TEND_LI_LINK', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "TENDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.407', '2026-01-07 10:35:14.407', 1);
END
GO
-- entity_name=LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LOCATION')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_LOCATION',
        [source_columns] = N'[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "name", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "LOCATION_ID", "LOCATION_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.513',
        [updated_at] = '2026-01-07 10:35:14.513',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION', N'NCR_LOCATION', N'[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "name", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]', N'["HUB_ID", "LOCATION_ID", "LOCATION_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.513', '2026-01-07 10:35:14.513', 1);
END
GO
-- entity_name=LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'LOC_OCC_PROD_LNK',
        [source_columns] = N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "OCCASSION_SRC_KEY", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]',
        [entity_columns] = N'["PRODUCT_HUB_ID", "PRODUCT_ID", "OCCASION_HUB_ID", "LOCATION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.607',
        [updated_at] = '2026-01-07 10:35:14.607',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION_OCCASION_PRODUCT', N'LOC_OCC_PROD_LNK', N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "OCCASSION_SRC_KEY", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]', N'["PRODUCT_HUB_ID", "PRODUCT_ID", "OCCASION_HUB_ID", "LOCATION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.607', '2026-01-07 10:35:14.607', 1);
END
GO
-- entity_name=MOD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'MOD')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_MODS',
        [source_columns] = N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "PARENT_ID", "MOD_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "MOD_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.700',
        [updated_at] = '2026-01-07 10:35:14.700',
        [is_active] = 1
    WHERE [entity_name] = N'MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'MOD', N'NCR_MODS', N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 0}]', N'["HUB_ID", "PARENT_ID", "MOD_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "MOD_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.700', '2026-01-07 10:35:14.700', 1);
END
GO
-- entity_name=OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'OCCASION')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_OCCASSION',
        [source_columns] = N'[{"name": "orderMode_id", "hash": 1}, {"name": "orderMode_id", "hash": 0}, {"name": "orderMode_label", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.797',
        [updated_at] = '2026-01-07 10:35:14.797',
        [is_active] = 1
    WHERE [entity_name] = N'OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'OCCASION', N'NCR_OCCASSION', N'[{"name": "orderMode_id", "hash": 1}, {"name": "orderMode_id", "hash": 0}, {"name": "orderMode_label", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.797', '2026-01-07 10:35:14.797', 1);
END
GO
-- entity_name=PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'PRODUCT')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_PROD',
        [source_columns] = N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "PRODUCT_ID", "PARENT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:14.903',
        [updated_at] = '2026-01-07 10:35:14.903',
        [is_active] = 1
    WHERE [entity_name] = N'PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'PRODUCT', N'NCR_PROD', N'[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]', N'["HUB_ID", "PRODUCT_ID", "PARENT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:14.903', '2026-01-07 10:35:14.903', 1);
END
GO
-- entity_name=REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'REVCENTER')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_REVC',
        [source_columns] = N'[{"name": "revenueCenter_id", "hash": 1}, {"name": "revenueCenter_id", "hash": 0}, {"name": "revenueCenter_label", "hash": 0}, {"name": "Level_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "REVC_ID", "REVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:15.013',
        [updated_at] = '2026-01-07 10:35:15.013',
        [is_active] = 1
    WHERE [entity_name] = N'REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'REVCENTER', N'NCR_REVC', N'[{"name": "revenueCenter_id", "hash": 1}, {"name": "revenueCenter_id", "hash": 0}, {"name": "revenueCenter_label", "hash": 0}, {"name": "Level_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "REVC_ID", "REVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:15.013', '2026-01-07 10:35:15.013', 1);
END
GO
-- entity_name=SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'SVCCHARGE')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_SVC',
        [source_columns] = N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["PARENT_ID", "HUB_ID", "SVC_ID", "LEVEL_NAME", "SVCCHARGE_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:15.107',
        [updated_at] = '2026-01-07 10:35:15.107',
        [is_active] = 1
    WHERE [entity_name] = N'SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'SVCCHARGE', N'NCR_SVC', N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["PARENT_ID", "HUB_ID", "SVC_ID", "LEVEL_NAME", "SVCCHARGE_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:15.107', '2026-01-07 10:35:15.107', 1);
END
GO
-- entity_name=TAX
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'TAX')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_TAX',
        [source_columns] = N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["PARENT_ID", "HUB_ID", "TAX_ID", "LEVEL_NAME", "TAX_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:15.203',
        [updated_at] = '2026-01-07 10:35:15.203',
        [is_active] = 1
    WHERE [entity_name] = N'TAX';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'TAX', N'NCR_TAX', N'[{"name": "PARENT_ITEM_SRC_KEY", "hash": 0}, {"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "ITEM_SRC_KEY", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "label", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["PARENT_ID", "HUB_ID", "TAX_ID", "LEVEL_NAME", "TAX_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:15.203', '2026-01-07 10:35:15.203', 1);
END
GO
-- entity_name=TIMECARD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[EntityMappings] WHERE [entity_name] = N'TIMECARD')
BEGIN
    UPDATE [core].[int_ncraloha001].[EntityMappings]
    SET
        [source_table] = N'NCR_EMP_TIME',
        [source_columns] = N'[{"name": "TIMECARD_SRC_KEY", "hash": 1}, {"name": "TIMECARD_DATE", "hash": 0}, {"name": "TIMECARD_START_TIMESTAMP", "hash": 0}, {"name": "TIMECARD_END_TIMESTAMP", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:35:15.297',
        [updated_at] = '2026-01-07 10:35:15.297',
        [is_active] = 1
    WHERE [entity_name] = N'TIMECARD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'TIMECARD', N'NCR_EMP_TIME', N'[{"name": "TIMECARD_SRC_KEY", "hash": 1}, {"name": "TIMECARD_DATE", "hash": 0}, {"name": "TIMECARD_START_TIMESTAMP", "hash": 0}, {"name": "TIMECARD_END_TIMESTAMP", "hash": 0}]', N'["HUB_ID", "TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:35:15.297', '2026-01-07 10:35:15.297', 1);
END
GO
