-- ============================================
-- Entity Mappings Export
-- Source: UAT [core].[int_marketman001].[EntityMappings]
-- Generated: 2026-06-02 10:45:23
-- Total Records: 24
-- ============================================

-- entity_name=CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LINEITEM',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_VALUE_HDR", "hash": 0}, {"name": "QUANTITY_HDR", "hash": 0}, {"name": "GROSS_VALUE_HDR", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "NET_SALES", "ITEM_COUNT", "GROSS_SALES", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 23:57:04.870',
        [updated_at] = '2026-01-28 23:08:40.200',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER', N'MMAN_LINEITEM', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_VALUE_HDR", "hash": 0}, {"name": "QUANTITY_HDR", "hash": 0}, {"name": "GROSS_VALUE_HDR", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}]', N'["HUB_ID", "NET_SALES", "ITEM_COUNT", "GROSS_SALES", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 23:57:04.870', '2026-01-28 23:08:40.200', 1);
END
GO
-- entity_name=CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LINEITEM',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 23:04:51.913',
        [updated_at] = '2026-01-28 23:08:40.253',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LINEITEM', N'MMAN_LINEITEM', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]', N'["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 23:04:51.913', '2026-01-28 23:08:40.253', 1);
END
GO
-- entity_name=CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LINEITEM',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "storeId", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 23:04:52.017',
        [updated_at] = '2026-01-28 23:08:40.287',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_LOCATION', N'MMAN_LINEITEM', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "storeId", "hash": 1}]', N'["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 23:04:52.017', '2026-01-28 23:08:40.287', 1);
END
GO
-- entity_name=CUSTORDER_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'CUSTORDER_OCCASION')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LINEITEM',
        [source_columns] = N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
        [entity_columns] = N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 23:04:52.110',
        [updated_at] = '2026-01-28 23:08:40.317',
        [is_active] = 1
    WHERE [entity_name] = N'CUSTORDER_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'CUSTORDER_OCCASION', N'MMAN_LINEITEM', N'[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]', N'["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 23:04:52.110', '2026-01-28 23:08:40.317', 1);
END
GO
-- entity_name=INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVITEM')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_INVITEMS',
        [source_columns] = N'[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "BOTTOM_LEVEL", "INVITEM_ID", "UOM_COST"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:23.927',
        [updated_at] = '2026-03-27 15:34:39.410',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM', N'MMAN_INVITEMS', N'[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]', N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "BOTTOM_LEVEL", "INVITEM_ID", "UOM_COST"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:23.927', '2026-03-27 15:34:39.410', 1);
END
GO
-- entity_name=INVITEM_INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVITEM_INVITEM')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_PREP_RECIPES',
        [source_columns] = N'[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        [entity_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.030',
        [updated_at] = '2026-01-28 23:08:40.377',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_INVITEM', N'MMAN_PREP_RECIPES', N'[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]', N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.030', '2026-01-28 23:08:40.377', 1);
END
GO
-- entity_name=INVITEM_INVREPORT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVITEM_INVREPORT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_REPORT',
        [source_columns] = N'[{"name": "ItemID", "hash": 1}, {"name": "REPORT_ID", "hash": 1}]',
        [entity_columns] = N'["INVITEM_HUB_ID", "INVREPORT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.120',
        [updated_at] = '2026-01-28 23:08:40.407',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_INVREPORT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_INVREPORT', N'MMAN_REPORT', N'[{"name": "ItemID", "hash": 1}, {"name": "REPORT_ID", "hash": 1}]', N'["INVITEM_HUB_ID", "INVREPORT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.120', '2026-01-28 23:08:40.407', 1);
END
GO
-- entity_name=INVITEM_LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVITEM_LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_PRODUCT_RECIPE',
        [source_columns] = N'[{"name": "PosCode", "hash": 1}, {"name": "INVITEM_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}, {"name": "storeId", "hash": 1}]',
        [entity_columns] = N'["PRODUCT_HUB_ID", "INVITEM_HUB_ID", "OCCASION_HUB_ID", "UOM", "UOM_VALUE", "LOCATION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.217',
        [updated_at] = '2026-03-11 01:58:56.067',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_LOCATION_OCCASION_PRODUCT', N'MMAN_PRODUCT_RECIPE', N'[{"name": "PosCode", "hash": 1}, {"name": "INVITEM_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}, {"name": "storeId", "hash": 1}]', N'["PRODUCT_HUB_ID", "INVITEM_HUB_ID", "OCCASION_HUB_ID", "UOM", "UOM_VALUE", "LOCATION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.217', '2026-03-11 01:58:56.067', 1);
END
GO
-- entity_name=INVITEM_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVITEM_STOCKEVENT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_STOCKEVENT',
        [source_columns] = N'[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.307',
        [updated_at] = '2026-01-28 23:08:40.473',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_STOCKEVENT', N'MMAN_STOCKEVENT', N'[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]', N'["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.307', '2026-01-28 23:08:40.473', 1);
END
GO
-- entity_name=INVITEM_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVITEM_STOCKORDER')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_PRE_ORDEREVENT',
        [source_columns] = N'[{"name": "OrderNumber", "hash": 1}, {"name": "ItemId", "hash": 1}]',
        [entity_columns] = N'["STOCKORDER_HUB_ID", "INVITEM_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-28 23:04:09.010',
        [updated_at] = '2026-01-28 23:08:40.503',
        [is_active] = 1
    WHERE [entity_name] = N'INVITEM_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVITEM_STOCKORDER', N'MMAN_PRE_ORDEREVENT', N'[{"name": "OrderNumber", "hash": 1}, {"name": "ItemId", "hash": 1}]', N'["STOCKORDER_HUB_ID", "INVITEM_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-28 23:04:09.010', '2026-01-28 23:08:40.503', 1);
END
GO
-- entity_name=INVREPORT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVREPORT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_REPORT_STEP2',
        [source_columns] = N'[{"name": "REPORT_ID", "hash": 1}, {"name": "TheoUsage", "hash": 0}, {"name": "TheoUsageValue", "hash": 0}, {"name": "ActualMovement", "hash": 0}, {"name": "ActualMovementValue", "hash": 0}, {"name": "Variance", "hash": 0}, {"name": "VarianceValue", "hash": 0}, {"name": "RecordedWaste", "hash": 0}, {"name": "WasteValue", "hash": 0}, {"name": "SalesUsage", "hash": 0}, {"name": "CostByBlendedAverageByReportingUOM", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "PurchaseQty", "hash": 0}, {"name": "TransferQty", "hash": 0}, {"name": "AvgDaysBetweenCounts", "hash": 0}, {"name": "DaysSinceLastCount", "hash": 0}, {"name": "VarianceIncCountDay", "hash": 0}, {"name": "VarianceValueInCountDay", "hash": 0}, {"name": "SalesValue", "hash": 0}, {"name": "PurchaseValue", "hash": 0}, {"name": "TransferValue", "hash": 0}, {"name": "RunningSalesUsage", "hash": 0}, {"name": "RunningSalesValue", "hash": 0}, {"name": "RunningPurchaseQty", "hash": 0}, {"name": "RunningPurchaseValue", "hash": 0}, {"name": "RunningWasteValue", "hash": 0}, {"name": "RunningRecordedWaste", "hash": 0}, {"name": "RunningProductionUsage", "hash": 0}, {"name": "RunningProductionValue", "hash": 0}, {"name": "RunningTransferQty", "hash": 0}, {"name": "RunningTransferValue", "hash": 0}, {"name": "ProductionUsage", "hash": 0}, {"name": "ProductionValue", "hash": 0}, {"name": "REPORTING_DATE", "hash": 0}, {"name": "LAST_COUNT", "hash": 0}, {"name": "LAST_COUNT_VALUE", "hash": 0}, {"name": "RunningCOGS", "hash": 0}, {"name": "IsCountDay", "hash": 0}, {"name": "COUNT_GROUP", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "THEO_USAGE", "THEO_COST", "ACTUAL_USAGE", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "SALES_QTY", "UOM_COST", "REPORTING_UOM", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_VALUE", "RUNNING_WASTE_QTY", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "REPORTING_DATE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS", "IS_COUNT_DAY", "COUNT_GROUP"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-02-13 15:22:29.733',
        [updated_at] = '2026-02-16 16:55:42.577',
        [is_active] = 1
    WHERE [entity_name] = N'INVREPORT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVREPORT', N'MMAN_REPORT_STEP2', N'[{"name": "REPORT_ID", "hash": 1}, {"name": "TheoUsage", "hash": 0}, {"name": "TheoUsageValue", "hash": 0}, {"name": "ActualMovement", "hash": 0}, {"name": "ActualMovementValue", "hash": 0}, {"name": "Variance", "hash": 0}, {"name": "VarianceValue", "hash": 0}, {"name": "RecordedWaste", "hash": 0}, {"name": "WasteValue", "hash": 0}, {"name": "SalesUsage", "hash": 0}, {"name": "CostByBlendedAverageByReportingUOM", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "PurchaseQty", "hash": 0}, {"name": "TransferQty", "hash": 0}, {"name": "AvgDaysBetweenCounts", "hash": 0}, {"name": "DaysSinceLastCount", "hash": 0}, {"name": "VarianceIncCountDay", "hash": 0}, {"name": "VarianceValueInCountDay", "hash": 0}, {"name": "SalesValue", "hash": 0}, {"name": "PurchaseValue", "hash": 0}, {"name": "TransferValue", "hash": 0}, {"name": "RunningSalesUsage", "hash": 0}, {"name": "RunningSalesValue", "hash": 0}, {"name": "RunningPurchaseQty", "hash": 0}, {"name": "RunningPurchaseValue", "hash": 0}, {"name": "RunningWasteValue", "hash": 0}, {"name": "RunningRecordedWaste", "hash": 0}, {"name": "RunningProductionUsage", "hash": 0}, {"name": "RunningProductionValue", "hash": 0}, {"name": "RunningTransferQty", "hash": 0}, {"name": "RunningTransferValue", "hash": 0}, {"name": "ProductionUsage", "hash": 0}, {"name": "ProductionValue", "hash": 0}, {"name": "REPORTING_DATE", "hash": 0}, {"name": "LAST_COUNT", "hash": 0}, {"name": "LAST_COUNT_VALUE", "hash": 0}, {"name": "RunningCOGS", "hash": 0}, {"name": "IsCountDay", "hash": 0}, {"name": "COUNT_GROUP", "hash": 0}]', N'["HUB_ID", "THEO_USAGE", "THEO_COST", "ACTUAL_USAGE", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "SALES_QTY", "UOM_COST", "REPORTING_UOM", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_VALUE", "RUNNING_WASTE_QTY", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "REPORTING_DATE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS", "IS_COUNT_DAY", "COUNT_GROUP"]', NULL, NULL, NULL, NULL, 0, 0, '2026-02-13 15:22:29.733', '2026-02-16 16:55:42.577', 1);
END
GO
-- entity_name=INVREPORT_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'INVREPORT_LOCATION')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_REPORT',
        [source_columns] = N'[{"name": "REPORT_ID", "hash": 1}, {"name": "storeId", "hash": 1}]',
        [entity_columns] = N'["INVREPORT_HUB_ID", "LOCATION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.463',
        [updated_at] = '2026-01-28 23:08:40.567',
        [is_active] = 1
    WHERE [entity_name] = N'INVREPORT_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'INVREPORT_LOCATION', N'MMAN_REPORT', N'[{"name": "REPORT_ID", "hash": 1}, {"name": "storeId", "hash": 1}]', N'["INVREPORT_HUB_ID", "LOCATION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.463', '2026-01-28 23:08:40.567', 1);
END
GO
-- entity_name=LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'LINEITEM')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LINEITEM',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ORDER_DATE", "ITEM_DATE", "TRADING_DATE", "NET_VALUE", "GROSS_VALUE"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 23:04:52.850',
        [updated_at] = '2026-01-28 23:08:40.603',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM', N'MMAN_LINEITEM', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}]', N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ORDER_DATE", "ITEM_DATE", "TRADING_DATE", "NET_VALUE", "GROSS_VALUE"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 23:04:52.850', '2026-01-28 23:08:40.603', 1);
END
GO
-- entity_name=LINEITEM_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_OCCASION')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LINEITEM',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 23:04:52.960',
        [updated_at] = '2026-01-28 23:08:40.630',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_OCCASION', N'MMAN_LINEITEM', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]', N'["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 23:04:52.960', '2026-01-28 23:08:40.630', 1);
END
GO
-- entity_name=LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LINEITEM',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PosCode", "hash": 1}]',
        [entity_columns] = N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 23:04:53.067',
        [updated_at] = '2026-01-28 23:08:40.670',
        [is_active] = 1
    WHERE [entity_name] = N'LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LINEITEM_PRODUCT', N'MMAN_LINEITEM', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "PosCode", "hash": 1}]', N'["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 23:04:53.067', '2026-01-28 23:08:40.670', 1);
END
GO
-- entity_name=LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'LOCATION')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_LOCATION',
        [source_columns] = N'[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "StoreName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "LOCATION_ID", "LOCATION_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.557',
        [updated_at] = '2026-01-28 23:08:40.710',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION', N'MMAN_LOCATION', N'[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "StoreName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]', N'["HUB_ID", "LOCATION_ID", "LOCATION_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.557', '2026-01-28 23:08:40.710', 1);
END
GO
-- entity_name=LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_PRODUCT',
        [source_columns] = N'[{"name": "PosCode", "hash": 0}, {"name": "storeId", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "MenuItemPrice", "hash": 0}, {"name": "RecipeIngredientsCost", "hash": 0}, {"name": "PosCode", "hash": 1}]',
        [entity_columns] = N'["PRODUCT_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "NET_PRICE", "NET_COST", "PRODUCT_HUB_ID"]',
        [type2_columns] = N'["NET_PRICE", "NET_COST"]',
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.653',
        [updated_at] = '2026-01-28 23:08:40.750',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION_OCCASION_PRODUCT', N'MMAN_PRODUCT', N'[{"name": "PosCode", "hash": 0}, {"name": "storeId", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "MenuItemPrice", "hash": 0}, {"name": "RecipeIngredientsCost", "hash": 0}, {"name": "PosCode", "hash": 1}]', N'["PRODUCT_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "NET_PRICE", "NET_COST", "PRODUCT_HUB_ID"]', N'["NET_PRICE", "NET_COST"]', NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.653', '2026-01-28 23:08:40.750', 1);
END
GO
-- entity_name=LOCATION_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'LOCATION_STOCKEVENT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_STOCKEVENT',
        [source_columns] = N'[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        [entity_columns] = N'["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.743',
        [updated_at] = '2026-01-28 23:08:40.790',
        [is_active] = 1
    WHERE [entity_name] = N'LOCATION_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'LOCATION_STOCKEVENT', N'MMAN_STOCKEVENT', N'[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]', N'["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.743', '2026-01-28 23:08:40.790', 1);
END
GO
-- entity_name=OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'OCCASION')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_OCCASION',
        [source_columns] = N'[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-03-11 01:58:55.560',
        [updated_at] = '2026-03-11 01:58:55.560',
        [is_active] = 1
    WHERE [entity_name] = N'OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'OCCASION', N'MMAN_OCCASION', N'[{"name": "OCC_ID", "hash": 1}, {"name": "OCC_ID", "hash": 0}, {"name": "OCC_NAME", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}]', N'["HUB_ID", "OCCASSION_ID", "OCCASION_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]', NULL, NULL, NULL, NULL, 0, 0, '2026-03-11 01:58:55.560', '2026-03-11 01:58:55.560', 1);
END
GO
-- entity_name=PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_PRODUCT',
        [source_columns] = N'[{"name": "PosCode", "hash": 1}, {"name": "PosCode", "hash": 0}, {"name": "MenuItemName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "PRODUCT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "PARENT_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.840',
        [updated_at] = '2026-01-28 23:08:40.823',
        [is_active] = 1
    WHERE [entity_name] = N'PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'PRODUCT', N'MMAN_PRODUCT', N'[{"name": "PosCode", "hash": 1}, {"name": "PosCode", "hash": 0}, {"name": "MenuItemName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}]', N'["HUB_ID", "PRODUCT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "PARENT_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.840', '2026-01-28 23:08:40.823', 1);
END
GO
-- entity_name=STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'STOCKEVENT')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_STOCKEVENT',
        [source_columns] = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHAVIOUR", "hash": 0}, {"name": "itemId", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "EVENT_BEHAVIOUR", "INTERNAL_REF"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:24.943',
        [updated_at] = '2026-03-12 22:00:02.230',
        [is_active] = 1
    WHERE [entity_name] = N'STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'STOCKEVENT', N'MMAN_STOCKEVENT', N'[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHAVIOUR", "hash": 0}, {"name": "itemId", "hash": 0}]', N'["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "EVENT_BEHAVIOUR", "INTERNAL_REF"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:24.943', '2026-03-12 22:00:02.230', 1);
END
GO
-- entity_name=STOCKEVENT_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'STOCKEVENT_STOCKORDER')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_PRE_ORDEREVENT',
        [source_columns] = N'[{"name": "STOCK_EVENT_SRC_KEY", "hash": 1}, {"name": "OrderNumber", "hash": 1}]',
        [entity_columns] = N'["STOCKEVENT_HUB_ID", "STOCKORDER_HUB_ID"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-29 00:15:32.947',
        [updated_at] = '2026-01-29 00:15:32.947',
        [is_active] = 1
    WHERE [entity_name] = N'STOCKEVENT_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'STOCKEVENT_STOCKORDER', N'MMAN_PRE_ORDEREVENT', N'[{"name": "STOCK_EVENT_SRC_KEY", "hash": 1}, {"name": "OrderNumber", "hash": 1}]', N'["STOCKEVENT_HUB_ID", "STOCKORDER_HUB_ID"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-29 00:15:32.947', '2026-01-29 00:15:32.947', 1);
END
GO
-- entity_name=STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'STOCKORDER')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_STOCKORDER',
        [source_columns] = N'[{"name": "ORDER_SRC_KEY", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "ORDER_SRC_KEY", "hash": 0}]',
        [entity_columns] = N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "ORDER_NUMBER"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:25.040',
        [updated_at] = '2026-01-29 01:38:18.563',
        [is_active] = 1
    WHERE [entity_name] = N'STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'STOCKORDER', N'MMAN_STOCKORDER', N'[{"name": "ORDER_SRC_KEY", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}, {"name": "ORDER_SRC_KEY", "hash": 0}]', N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "ORDER_NUMBER"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:25.040', '2026-01-29 01:38:18.563', 1);
END
GO
-- entity_name=SUPPLIER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[EntityMappings] WHERE [entity_name] = N'SUPPLIER')
BEGIN
    UPDATE [core].[int_marketman001].[EntityMappings]
    SET
        [source_table] = N'MMAN_VENDORS',
        [source_columns] = N'[{"name":"Name","hash":1},{"name":"Name","hash":0}]',
        [entity_columns] = N'["HUB_ID","SUPPLIER_NAME"]',
        [type2_columns] = NULL,
        [cdc_exclude_columns] = NULL,
        [date_filter_column] = NULL,
        [exclude_conditions] = NULL,
        [track_deletions] = 0,
        [split_by_source] = 0,
        [created_at] = '2026-01-07 10:32:25.117',
        [updated_at] = '2026-01-28 23:08:40.927',
        [is_active] = 1
    WHERE [entity_name] = N'SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[EntityMappings] ([entity_name], [source_table], [source_columns], [entity_columns], [type2_columns], [cdc_exclude_columns], [date_filter_column], [exclude_conditions], [track_deletions], [split_by_source], [created_at], [updated_at], [is_active])
    VALUES (N'SUPPLIER', N'MMAN_VENDORS', N'[{"name":"Name","hash":1},{"name":"Name","hash":0}]', N'["HUB_ID","SUPPLIER_NAME"]', NULL, NULL, NULL, NULL, 0, 0, '2026-01-07 10:32:25.117', '2026-01-28 23:08:40.927', 1);
END
GO
