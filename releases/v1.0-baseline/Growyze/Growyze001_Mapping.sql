-- ============================================
-- Entity Mappings Export
-- Source: UAT [core].[int_growyze001].[EntityMappings]
-- Generated: 2026-06-02 10:45:23
-- Total Records: 23
-- ============================================

-- entity_name=CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LINEITEM',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_SALES", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE", "EXTERNAL_REFERENCE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.110',
        [updated_at] = '2026-03-28 00:44:38.757',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER', N'GRYZ_LINEITEM', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_SALES", "hash": 0}, {"name": "ITEM_COUNT", "hash": 0}, {"name": "OPEN_TIME", "hash": 0}, {"name": "CLOSE_TIME", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "EXTERNAL_REFERENCE", "hash": 0}]', N'["HUB_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE", "EXTERNAL_REFERENCE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.110', '2026-03-28 00:44:38.757', 1);
END
GO
-- entity_name=CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LINEITEM',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.250',
        [updated_at] = '2026-03-28 00:44:38.947',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LINEITEM', N'GRYZ_LINEITEM', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]', N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.250', '2026-03-28 00:44:38.947', 1);
END
GO
-- entity_name=CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LINEITEM',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.303',
        [updated_at] = '2026-03-28 00:44:39.037',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LOCATION', N'GRYZ_LINEITEM', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}]', N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.303', '2026-03-28 00:44:39.037', 1);
END
GO
-- entity_name=CUSTORDER_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_OCCASION')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LINEITEM',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.350',
        [updated_at] = '2026-03-28 00:44:39.130',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_OCCASION', N'GRYZ_LINEITEM', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]', N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.350', '2026-03-28 00:44:39.130', 1);
END
GO
-- entity_name=DISTRIBUTOR_STOCKORDER_SUPPLIER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'DISTRIBUTOR_STOCKORDER_SUPPLIER')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_STOCKORDER',
        [source_columns] = N'[{"name": "DISTRIBUTOR_KEY", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_KEY", "hash": 1}]',
        [entity_columns] = N'["DISTRIBUTOR_HUB_ID", "STOCKORDER_HUB_ID", "SUPPLIER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.883',
        [updated_at] = '2026-03-28 00:44:39.880',
        [is_active] = 1
    WHERE [entity_name] = N'DISTRIBUTOR_STOCKORDER_SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'DISTRIBUTOR_STOCKORDER_SUPPLIER', N'GRYZ_STOCKORDER', N'[{"name": "DISTRIBUTOR_KEY", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_KEY", "hash": 1}]', N'["DISTRIBUTOR_HUB_ID", "STOCKORDER_HUB_ID", "SUPPLIER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.883', '2026-03-28 00:44:39.880', 1);
END
GO
-- entity_name=INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'INVITEM')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_INVITEMS',
        [source_columns] = N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "INVITEM_ID", "UOM_COST"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:35.700',
        [updated_at] = '2026-05-20 11:31:32.183',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM', N'GRYZ_INVITEMS', N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]', N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "INVITEM_ID", "UOM_COST"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:35.700', '2026-05-20 11:31:32.183', 1);
END
GO
-- entity_name=INVITEM_INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'INVITEM_INVITEM')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_PREP_RECIPES',
        [source_columns] = N'[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        [entity_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.590',
        [updated_at] = '2026-03-28 00:44:39.413',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_INVITEM', N'GRYZ_PREP_RECIPES', N'[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]', N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.590', '2026-03-28 00:44:39.413', 1);
END
GO
-- entity_name=INVITEM_LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'INVITEM_LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_PRODUCT_INVITEM',
        [source_columns] = N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        [entity_columns] = N'["INVITEM_HUB_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.983',
        [updated_at] = '2026-03-28 00:44:39.970',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_LOCATION_OCCASION_PRODUCT', N'GRYZ_PRODUCT_INVITEM', N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]', N'["INVITEM_HUB_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.983', '2026-03-28 00:44:39.970', 1);
END
GO
-- entity_name=INVITEM_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'INVITEM_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_PRODUCT_INVITEM',
        [source_columns] = N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        [entity_columns] = N'["INVITEM_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:37.030',
        [updated_at] = '2026-03-28 00:44:40.067',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_OCCASION_PRODUCT', N'GRYZ_PRODUCT_INVITEM', N'[{"name": "INVITEM_KEY", "hash": 1}, {"name": "OCCASION_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]', N'["INVITEM_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "UOM", "UOM_VALUE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:37.030', '2026-03-28 00:44:40.067', 1);
END
GO
-- entity_name=INVITEM_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'INVITEM_STOCKEVENT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_STOCKEVENT',
        [source_columns] = N'[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.633',
        [updated_at] = '2026-03-28 00:44:39.500',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_STOCKEVENT', N'GRYZ_STOCKEVENT', N'[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]', N'["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.633', '2026-03-28 00:44:39.500', 1);
END
GO
-- entity_name=INVITEM_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'INVITEM_STOCKORDER')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_ORDER_ITEMS',
        [source_columns] = N'[{"name": "ITEM_ID", "hash": 1}, {"name": "ORDER_ID", "hash": 1}, {"name": "items_quantity", "hash": 0}, {"name": "items_price", "hash": 0}, {"name": "items_estimatedCost", "hash": 0}, {"name": "items_orderInCase", "hash": 0}, {"name": "items_productCase_size", "hash": 0}, {"name": "items_productCase_price", "hash": 0}]',
        [entity_columns] = N'["INVITEM_HUB_ID", "STOCKORDER_HUB_ID", "QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 13:51:47.883',
        [updated_at] = '2026-03-28 00:44:39.597',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_STOCKORDER', N'GRYZ_ORDER_ITEMS', N'[{"name": "ITEM_ID", "hash": 1}, {"name": "ORDER_ID", "hash": 1}, {"name": "items_quantity", "hash": 0}, {"name": "items_price", "hash": 0}, {"name": "items_estimatedCost", "hash": 0}, {"name": "items_orderInCase", "hash": 0}, {"name": "items_productCase_size", "hash": 0}, {"name": "items_productCase_price", "hash": 0}]', N'["INVITEM_HUB_ID", "STOCKORDER_HUB_ID", "QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 13:51:47.883', '2026-03-28 00:44:39.597', 1);
END
GO
-- entity_name=LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'LINEITEM')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LINEITEM',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.203',
        [updated_at] = '2026-03-28 00:44:38.853',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM', N'GRYZ_LINEITEM', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}]', N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.203', '2026-03-28 00:44:38.853', 1);
END
GO
-- entity_name=LINEITEM_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_OCCASION')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LINEITEM',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.550',
        [updated_at] = '2026-03-28 00:44:39.317',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_OCCASION', N'GRYZ_LINEITEM', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]', N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.550', '2026-03-28 00:44:39.317', 1);
END
GO
-- entity_name=LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LINEITEM_PRODUCT',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-05-20 11:07:53.717',
        [updated_at] = '2026-05-20 11:07:53.717',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_PRODUCT', N'GRYZ_LINEITEM_PRODUCT', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]', N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-05-20 11:07:53.717', '2026-05-20 11:07:53.717', 1);
END
GO
-- entity_name=LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'LOCATION')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_LOCATION',
        [source_columns] = N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "LOCATION_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:35.753',
        [updated_at] = '2026-03-28 00:45:38.023',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION', N'GRYZ_LOCATION', N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]', N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "LOCATION_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:35.753', '2026-03-28 00:45:38.023', 1);
END
GO
-- entity_name=LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_PRODUCT',
        [source_columns] = N'[{"name": "LOCATION_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "NET_PRICE", "hash": 0}, {"name": "NET_COST", "hash": 0}]',
        [entity_columns] = N'["LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "PRODUCT_ID", "NET_PRICE", "NET_COST"]',
        [type2_columns] = N'["NET_PRICE", "NET_COST"]',
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:37.077',
        [updated_at] = '2026-03-28 00:44:40.150',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION_OCCASION_PRODUCT', N'GRYZ_PRODUCT', N'[{"name": "LOCATION_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "NET_PRICE", "hash": 0}, {"name": "NET_COST", "hash": 0}]', N'["LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID", "PRODUCT_ID", "NET_PRICE", "NET_COST"]', N'["NET_PRICE", "NET_COST"]', NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:37.077', '2026-03-28 00:44:40.150', 1);
END
GO
-- entity_name=LOCATION_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'LOCATION_STOCKEVENT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_STOCKEVENT',
        [source_columns] = N'[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.737',
        [updated_at] = '2026-03-28 00:44:39.693',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION_STOCKEVENT', N'GRYZ_STOCKEVENT', N'[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]', N'["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.737', '2026-03-28 00:44:39.693', 1);
END
GO
-- entity_name=OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'OCCASION')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_OCCASION',
        [source_columns] = N'[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:35.897',
        [updated_at] = '2026-03-28 00:44:38.447',
        [is_active] = 1
    WHERE [entity_name] = N'OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'OCCASION', N'GRYZ_OCCASION', N'[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:35.897', '2026-03-28 00:44:38.447', 1);
END
GO
-- entity_name=PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_PRODUCT',
        [source_columns] = N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:35.850',
        [updated_at] = '2026-03-28 00:45:38.120',
        [is_active] = 1
    WHERE [entity_name] = N'PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'PRODUCT', N'GRYZ_PRODUCT', N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}]', N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:35.850', '2026-03-28 00:45:38.120', 1);
END
GO
-- entity_name=STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'STOCKEVENT')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_STOCKEVENT',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "INTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHANIOUR", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.000',
        [updated_at] = '2026-03-28 00:44:38.647',
        [is_active] = 1
    WHERE [entity_name] = N'STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'STOCKEVENT', N'GRYZ_STOCKEVENT', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "INTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHANIOUR", "hash": 0}]', N'["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.000', '2026-03-28 00:44:38.647', 1);
END
GO
-- entity_name=STOCKEVENT_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'STOCKEVENT_STOCKORDER')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_DN_EVENTS',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ORDER_ID", "hash": 1}]',
        [entity_columns] = N'["STOCKEVENT_HUB_ID", "STOCKORDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:36.797',
        [updated_at] = '2026-03-28 00:44:39.783',
        [is_active] = 1
    WHERE [entity_name] = N'STOCKEVENT_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'STOCKEVENT_STOCKORDER', N'GRYZ_DN_EVENTS', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "ORDER_ID", "hash": 1}]', N'["STOCKEVENT_HUB_ID", "STOCKORDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:36.797', '2026-03-28 00:44:39.783', 1);
END
GO
-- entity_name=STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'STOCKORDER')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_STOCKORDER',
        [source_columns] = N'[{"name": "HUB_ID", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:35.953',
        [updated_at] = '2026-03-28 00:44:38.540',
        [is_active] = 1
    WHERE [entity_name] = N'STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'STOCKORDER', N'GRYZ_STOCKORDER', N'[{"name": "HUB_ID", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}]', N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:35.953', '2026-03-28 00:44:38.540', 1);
END
GO
-- entity_name=SUPPLIER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[EntityMappings] WHERE [entity_name] = N'SUPPLIER')
BEGIN
    UPDATE [core].[int_growyze001].[EntityMappings]
    SET
        [source_table] = N'GRYZ_SUPPLIERS',
        [source_columns] = N'[{"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_NAME", "hash": 0}, {"name": "SUPPLIER_ID", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:59:35.797',
        [updated_at] = '2026-03-28 00:45:38.210',
        [is_active] = 1
    WHERE [entity_name] = N'SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'SUPPLIER', N'GRYZ_SUPPLIERS', N'[{"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_NAME", "hash": 0}, {"name": "SUPPLIER_ID", "hash": 0}]', N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:59:35.797', '2026-03-28 00:45:38.210', 1);
END
GO
