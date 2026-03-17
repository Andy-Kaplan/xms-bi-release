-- Data Vault Entity Mappings Export
-- Schema: int_marketman001
-- Generated: 2026-01-28 23:07:52
-- Total Mappings: 22

-- Entity: CUSTORDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'CUSTORDER')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LINEITEM',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_VALUE_HDR", "hash": 0}, {"name": "QUANTITY_HDR", "hash": 0}, {"name": "GROSS_VALUE_HDR", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}]',
        entity_columns = '["HUB_ID", "NET_SALES", "ITEM_COUNT", "GROSS_SALES", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('B37CBFA5-9766-4A21-8AE5-8F6DAEBC8DF3', 'CUSTORDER', 'MMAN_LINEITEM',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "NET_VALUE_HDR", "hash": 0}, {"name": "QUANTITY_HDR", "hash": 0}, {"name": "GROSS_VALUE_HDR", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}]', '["HUB_ID", "NET_SALES", "ITEM_COUNT", "GROSS_SALES", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'CUSTORDER_LINEITEM')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LINEITEM',
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
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('CACAE2C6-B058-4F35-8617-EE38EFDD4ABA', 'CUSTORDER_LINEITEM', 'MMAN_LINEITEM',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]', '["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_LOCATION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'CUSTORDER_LOCATION')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LINEITEM',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "storeId", "hash": 1}]',
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
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('4C121406-6AE7-4BE2-9E68-DBC280694A74', 'CUSTORDER_LOCATION', 'MMAN_LINEITEM',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "storeId", "hash": 1}]', '["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: CUSTORDER_OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'CUSTORDER_OCCASION')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LINEITEM',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
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
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('6325DE4D-209D-4473-85C8-6ED822F4073F', 'CUSTORDER_OCCASION', 'MMAN_LINEITEM',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}]', '["CUSTORDER_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVITEM')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_INVITEMS',
        source_columns = '[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "BOTTOM_LEVEL", "INVITEM_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A9B3C1A9-1C8B-43F7-B939-D1A23DF5A337', 'INVITEM', 'MMAN_INVITEMS',
            '[{"name": "INVITEM_ID", "hash": 1}, {"name": "InvItemName", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "PARENT_NAME", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ParLevel", "hash": 0}, {"name": "MinOrderQty", "hash": 0}, {"name": "MaxOrderQty", "hash": 0}, {"name": "DateRangeType", "hash": 0}, {"name": "IsDeleted", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}]', '["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "BOTTOM_LEVEL", "INVITEM_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVITEM_INVITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVITEM_INVITEM')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_PREP_RECIPES',
        source_columns = '[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]',
        entity_columns = '["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVITEM_INVITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('FEFD164E-40B3-4C2F-A3A2-0530C3D1078D', 'INVITEM_INVITEM', 'MMAN_PREP_RECIPES',
            '[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]', '["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVITEM_INVREPORT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVITEM_INVREPORT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_REPORT',
        source_columns = '[{"name": "ItemID", "hash": 1}, {"name": "REPORT_ID", "hash": 1}]',
        entity_columns = '["INVITEM_HUB_ID", "INVREPORT_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVITEM_INVREPORT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('498B5C15-592D-4EEC-96F2-CF2300E45587', 'INVITEM_INVREPORT', 'MMAN_REPORT',
            '[{"name": "ItemID", "hash": 1}, {"name": "REPORT_ID", "hash": 1}]', '["INVITEM_HUB_ID", "INVREPORT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVITEM_LOCATION_OCCASION_PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVITEM_LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_PRODUCT',
        source_columns = '[{"name": "PosCode", "hash": 1}, {"name": "INVITEM_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}, {"name": "storeId", "hash": 1}]',
        entity_columns = '["PRODUCT_HUB_ID", "INVITEM_HUB_ID", "OCCASION_HUB_ID", "UOM", "UOM_VALUE", "LOCATION_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVITEM_LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('ABDBD083-8894-4AEE-992D-E6362B19DF0A', 'INVITEM_LOCATION_OCCASION_PRODUCT', 'MMAN_PRODUCT',
            '[{"name": "PosCode", "hash": 1}, {"name": "INVITEM_ID", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}, {"name": "storeId", "hash": 1}]', '["PRODUCT_HUB_ID", "INVITEM_HUB_ID", "OCCASION_HUB_ID", "UOM", "UOM_VALUE", "LOCATION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVITEM_STOCKEVENT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVITEM_STOCKEVENT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_STOCKEVENT',
        source_columns = '[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        entity_columns = '["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVITEM_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('F616D5D0-E8AA-4172-97CD-ACDAAEFBB486', 'INVITEM_STOCKEVENT', 'MMAN_STOCKEVENT',
            '[{"name": "itemId", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]', '["INVITEM_HUB_ID", "STOCKEVENT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVITEM_STOCKORDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVITEM_STOCKORDER')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_PRE_ORDEREVENT',
        source_columns = '[{"name": "OrderNumber", "hash": 1}, {"name": "ItemId", "hash": 1}]',
        entity_columns = '["STOCKORDER_HUB_ID", "INVITEM_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVITEM_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('03A176BA-CB2A-4EE7-B7B3-A297C42B3B2F', 'INVITEM_STOCKORDER', 'MMAN_PRE_ORDEREVENT',
            '[{"name": "OrderNumber", "hash": 1}, {"name": "ItemId", "hash": 1}]', '["STOCKORDER_HUB_ID", "INVITEM_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVREPORT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVREPORT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_REPORT',
        source_columns = '[{"name": "REPORT_ID", "hash": 1}, {"name": "TheoreticalUsageInReportingUOM", "hash": 0}, {"name": "ActualUsageInReportingUOM", "hash": 0}, {"name": "VarianceQTYInReportingUOM", "hash": 0}, {"name": "RecordedWasteInReportingUOM", "hash": 0}, {"name": "REPORTING_DATE", "hash": 0}, {"name": "ReportingUOM", "hash": 0}, {"name": "CostByBlendedAverageByReportingUOM", "hash": 0}, {"name": "SalesUsageInReportingUOM", "hash": 0}, {"name": "PurchaseQtyInReportingUOM", "hash": 0}, {"name": "TransferQtyInReportingUOM", "hash": 0}, {"name": "AvgDaysBetweenCounts", "hash": 0}, {"name": "DaysSinceLastCount", "hash": 0}]',
        entity_columns = '["HUB_ID", "THEO_USAGE", "ACTUAL_USAGE", "VARIANCE_QTY", "WASTE_QTY", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVREPORT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('8E056401-44BF-4ECC-98BA-50765521AE98', 'INVREPORT', 'MMAN_REPORT',
            '[{"name": "REPORT_ID", "hash": 1}, {"name": "TheoreticalUsageInReportingUOM", "hash": 0}, {"name": "ActualUsageInReportingUOM", "hash": 0}, {"name": "VarianceQTYInReportingUOM", "hash": 0}, {"name": "RecordedWasteInReportingUOM", "hash": 0}, {"name": "REPORTING_DATE", "hash": 0}, {"name": "ReportingUOM", "hash": 0}, {"name": "CostByBlendedAverageByReportingUOM", "hash": 0}, {"name": "SalesUsageInReportingUOM", "hash": 0}, {"name": "PurchaseQtyInReportingUOM", "hash": 0}, {"name": "TransferQtyInReportingUOM", "hash": 0}, {"name": "AvgDaysBetweenCounts", "hash": 0}, {"name": "DaysSinceLastCount", "hash": 0}]', '["HUB_ID", "THEO_USAGE", "ACTUAL_USAGE", "VARIANCE_QTY", "WASTE_QTY", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: INVREPORT_LOCATION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'INVREPORT_LOCATION')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_REPORT',
        source_columns = '[{"name": "REPORT_ID", "hash": 1}, {"name": "storeId", "hash": 1}]',
        entity_columns = '["INVREPORT_HUB_ID", "LOCATION_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'INVREPORT_LOCATION';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('029B2590-4355-4001-9593-5245BBDC05A7', 'INVREPORT_LOCATION', 'MMAN_REPORT',
            '[{"name": "REPORT_ID", "hash": 1}, {"name": "storeId", "hash": 1}]', '["INVREPORT_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'LINEITEM')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LINEITEM',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}]',
        entity_columns = '["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ORDER_DATE", "ITEM_DATE", "TRADING_DATE", "NET_VALUE", "GROSS_VALUE"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LINEITEM';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A4976B16-9132-4DE3-9602-A8F963758159', 'LINEITEM', 'MMAN_LINEITEM',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "QUANTITY_FINAL", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "SALE_DATE", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}]', '["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ORDER_DATE", "ITEM_DATE", "TRADING_DATE", "NET_VALUE", "GROSS_VALUE"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_OCCASION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'LINEITEM_OCCASION')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LINEITEM',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]',
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
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('092456AB-730B-4C66-B2FD-39A428EF2580', 'LINEITEM_OCCASION', 'MMAN_LINEITEM',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "OCC_ID", "hash": 1}]', '["LINEITEM_HUB_ID", "OCCASION_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LINEITEM_PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'LINEITEM_PRODUCT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LINEITEM',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "PosCode", "hash": 1}]',
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
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('4BB75EA6-9CF2-4F9B-981A-2610156108FF', 'LINEITEM_PRODUCT', 'MMAN_LINEITEM',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "PosCode", "hash": 1}]', '["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LOCATION
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'LOCATION')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_LOCATION',
        source_columns = '[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "StoreName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]',
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
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('C19B6517-44CB-4F7F-9D9C-93EB4B4FE9FA', 'LOCATION', 'MMAN_LOCATION',
            '[{"name": "storeId", "hash": 1}, {"name": "storeId", "hash": 0}, {"name": "StoreName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}]', '["HUB_ID", "LOCATION_ID", "LOCATION_NAME", "BOTTOM_LEVEL", "LEVEL_NAME"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LOCATION_OCCASION_PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_PRODUCT',
        source_columns = '[{"name": "PosCode", "hash": 0}, {"name": "storeId", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "MenuItemPrice", "hash": 0}, {"name": "RecipeIngredientsCost", "hash": 0}, {"name": "PosCode", "hash": 1}]',
        entity_columns = '["PRODUCT_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "NET_PRICE", "NET_COST", "PRODUCT_HUB_ID"]',
        type2_columns = '["NET_PRICE", "NET_COST"]',
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('C44D3872-58CE-4183-B681-1926B7FE4576', 'LOCATION_OCCASION_PRODUCT', 'MMAN_PRODUCT',
            '[{"name": "PosCode", "hash": 0}, {"name": "storeId", "hash": 1}, {"name": "OCC_ID", "hash": 1}, {"name": "MenuItemPrice", "hash": 0}, {"name": "RecipeIngredientsCost", "hash": 0}, {"name": "PosCode", "hash": 1}]', '["PRODUCT_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "NET_PRICE", "NET_COST", "PRODUCT_HUB_ID"]',
            '["NET_PRICE", "NET_COST"]', NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: LOCATION_STOCKEVENT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'LOCATION_STOCKEVENT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_STOCKEVENT',
        source_columns = '[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]',
        entity_columns = '["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LOCATION_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('76A59C45-DEE7-49DD-9D7D-50A2CD12CDF4', 'LOCATION_STOCKEVENT', 'MMAN_STOCKEVENT',
            '[{"name": "storeID", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]', '["LOCATION_HUB_ID", "STOCKEVENT_HUB_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: PRODUCT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'PRODUCT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_PRODUCT',
        source_columns = '[{"name": "PosCode", "hash": 1}, {"name": "PosCode", "hash": 0}, {"name": "MenuItemName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "PRODUCT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "PARENT_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'PRODUCT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('A12D03CE-299C-43AE-9492-5506B5D05AE0', 'PRODUCT', 'MMAN_PRODUCT',
            '[{"name": "PosCode", "hash": 1}, {"name": "PosCode", "hash": 0}, {"name": "MenuItemName", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}]', '["HUB_ID", "PRODUCT_ID", "PRODUCT_NAME", "BOTTOM_LEVEL", "LEVEL_NAME", "PARENT_ID"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: STOCKEVENT
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'STOCKEVENT')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_STOCKEVENT',
        source_columns = '[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHANIOUR", "hash": 0}, {"name": "itemId", "hash": 0}]',
        entity_columns = '["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "EVENT_BEHAVIOUR", "INTERNAL_REF"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('8F96EC1F-F5CD-41D3-B935-2F8BC71FCFED', 'STOCKEVENT', 'MMAN_STOCKEVENT',
            '[{"name": "SRC_KEY", "hash": 1}, {"name": "EVENT_TYPE", "hash": 0}, {"name": "EVENT_TS", "hash": 0}, {"name": "PACK_DESC", "hash": 0}, {"name": "PACK_QUANTITY", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "UOM_QUANTITY", "hash": 0}, {"name": "EXTERNAL_REF", "hash": 0}, {"name": "EVENT_BEHANIOUR", "hash": 0}, {"name": "itemId", "hash": 0}]', '["HUB_ID", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "EVENT_BEHAVIOUR", "INTERNAL_REF"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: STOCKORDER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'STOCKORDER')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_STOCKORDER',
        source_columns = '[{"name": "ORDER_SRC_KEY", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}]',
        entity_columns = '["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('03D9E667-FBCC-4BB0-A4F7-96A99290C23E', 'STOCKORDER', 'MMAN_STOCKORDER',
            '[{"name": "ORDER_SRC_KEY", "hash": 1}, {"name": "ORDER_DATE", "hash": 0}, {"name": "DELIVERY_DATE", "hash": 0}, {"name": "ORDER_TOTAL", "hash": 0}, {"name": "ORDER_TAX", "hash": 0}, {"name": "ORDER_INFO", "hash": 0}, {"name": "ORDER_STATUS", "hash": 0}]', '["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO

-- Entity: SUPPLIER
-- Check if mapping exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.int_marketman001.EntityMappings WHERE entity_name = 'SUPPLIER')
BEGIN
    UPDATE core.int_marketman001.EntityMappings
    SET source_table = 'MMAN_VENDORS',
        source_columns = '[{"name":"Name","hash":1},{"name":"Name","hash":0}]',
        entity_columns = '["HUB_ID","SUPPLIER_NAME"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO core.int_marketman001.EntityMappings
    (id, entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('F648505C-522A-4F71-B41D-3433F8DB8A67', 'SUPPLIER', 'MMAN_VENDORS',
            '[{"name":"Name","hash":1},{"name":"Name","hash":0}]', '["HUB_ID","SUPPLIER_NAME"]',
            NULL, NULL,
            NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO
