-- =============================================================================
-- FIX: H2_purchaseitem_dedup.sql
-- Priority: HIGH (H2)
-- Date: 2026-03-04
-- =============================================================================
--
-- PROBLEM:
--   DL_INVENTORY_ITEMS_PURCHASEITEMS contains duplicate rows: 10 combinations
--   of (SupplierName, CatalogItemCode, storeId) have 2 rows each, differing
--   only in the ID column. Both MMAN_PRE_INVOICE and MMAN_PRE_ORDEREVENT join
--   to this table on (SupplierName, CatalogItemCode, storeId), causing fan-out:
--     - MMAN_PRE_INVOICE: 4 duplicate invoice rows (LEFT OUTER JOIN)
--     - MMAN_PRE_ORDEREVENT: 2 duplicate order rows (INNER JOIN)
--   The GROUP BY includes ipi.ID, so duplicates are not collapsed.
--
-- FIX:
--   Replace the direct JOIN to DL_INVENTORY_ITEMS_PURCHASEITEMS with a JOIN to
--   a deduped subquery using ROW_NUMBER() OVER (PARTITION BY SupplierName,
--   CatalogItemCode, storeId ORDER BY ID). Add AND ipi.rn = 1 to the ON clause
--   so only one purchaseitem row matches per (Supplier, CatalogItem, Store).
--
-- SCOPE:
--   Two StagingControl records updated:
--     1. 'Invoice Items' (MMAN_PRE_INVOICE) - LEFT OUTER JOIN preserved
--     2. 'Order Items'   (MMAN_PRE_ORDEREVENT) - INNER JOIN preserved
--
-- DEPLOY: Run against the core database.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Invoice Items (MMAN_PRE_INVOICE) - Fix LEFT OUTER JOIN to deduped subquery
-- -----------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Invoice Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID
    ,di.CatalogItemCode
    ,TRY_CAST(d.DocTypeID AS INT) as DocTypeID
    ,d.DocType
    ,TRY_CAST(d.DocStatusID AS INT) as DocStatusID
    ,d.DocStatusType
    ,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
    ,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
    ,TRY_CAST(d.DateUTC AS datetime2) as DocDateUTC
    ,TRY_CAST(d.DueDateUTC AS datetime2) as DueDateUTC
    ,d.VendorGuid
    ,d.BuyerGuid
    ,ipi.ID as ItemId
    ,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as ORDER_PACK_QUANTITY
    ,SUM(CAST(di.OrderQuantity AS DECIMAL(19,3))) as DOC_ORDERED_PACK_QUANTITY
    ,SUM(CAST(di.Quantity AS DECIMAL(19,3))) as DOC_PACK_QUANTITY
    ,SUM(CAST(di.ReceiveQuantity AS DECIMAL(19,3))) as DELIVERED_PACK_QUANTITY
    ,SUM(CAST(di.TaxValue AS DECIMAL(19,3))) as TaxValue
    ,SUM(CAST(di.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName
      ,di.ItemMeasureTypeName
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))
,di.CatalogItemID
,di.CatalogItemCode
,TRY_CAST(d.DocTypeID AS INT)
,d.DocType
,TRY_CAST(d.DocStatusID AS INT)
,d.DocStatusType
,TRY_CAST(o.OrderStatusUIName as nvarchar(256))
,TRY_CAST(o.DeliveryDateUTC AS datetime2)
,TRY_CAST(d.DateUTC AS datetime2)
,TRY_CAST(d.DueDateUTC AS datetime2)
,d.VendorGuid
,d.BuyerGuid
,ipi.ID
) AS source_query;',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [retry_count], [timeout_minutes],
            [staging_columns], [created_at], [updated_at])
    VALUES (N'Invoice Items', N'MMAN_PRE_INVOICE',
            N'IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID
    ,di.CatalogItemCode
    ,TRY_CAST(d.DocTypeID AS INT) as DocTypeID
    ,d.DocType
    ,TRY_CAST(d.DocStatusID AS INT) as DocStatusID
    ,d.DocStatusType
    ,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
    ,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
    ,TRY_CAST(d.DateUTC AS datetime2) as DocDateUTC
    ,TRY_CAST(d.DueDateUTC AS datetime2) as DueDateUTC
    ,d.VendorGuid
    ,d.BuyerGuid
    ,ipi.ID as ItemId
    ,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as ORDER_PACK_QUANTITY
    ,SUM(CAST(di.OrderQuantity AS DECIMAL(19,3))) as DOC_ORDERED_PACK_QUANTITY
    ,SUM(CAST(di.Quantity AS DECIMAL(19,3))) as DOC_PACK_QUANTITY
    ,SUM(CAST(di.ReceiveQuantity AS DECIMAL(19,3))) as DELIVERED_PACK_QUANTITY
    ,SUM(CAST(di.TaxValue AS DECIMAL(19,3))) as TaxValue
    ,SUM(CAST(di.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName
      ,di.ItemMeasureTypeName
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))
,di.CatalogItemID
,di.CatalogItemCode
,TRY_CAST(d.DocTypeID AS INT)
,d.DocType
,TRY_CAST(d.DocStatusID AS INT)
,d.DocStatusType
,TRY_CAST(o.OrderStatusUIName as nvarchar(256))
,TRY_CAST(o.DeliveryDateUTC AS datetime2)
,TRY_CAST(d.DateUTC AS datetime2)
,TRY_CAST(d.DueDateUTC AS datetime2)
,d.VendorGuid
,d.BuyerGuid
,ipi.ID
) AS source_query;',
            1, N'Staging', 0, 3, 30,
            N'["OrderNumber", "storeId", "EVENT_TYPE", "DOC_PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "DocTypeID", "DocType", "DocStatusID", "DocStatusType", "OrderStatusUIName", "DeliveryDateUTC", "DocDateUTC", "DueDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "ORDER_PACK_QUANTITY", "DOC_ORDERED_PACK_QUANTITY", "DOC_PACK_QUANTITY", "DELIVERED_PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
            GETDATE(), GETDATE());
GO

-- -----------------------------------------------------------------------------
-- 2. Order Items (MMAN_PRE_ORDEREVENT) - Fix INNER JOIN to deduped subquery
-- -----------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Order Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

SELECT * INTO [stage].[MMAN_PRE_ORDEREVENT]
FROM (
SELECT  od.OrderNumber
,od.StoreId
,''ORDER'' as EVENT_TYPE
,o.SentDateUTC as EVENT_TS
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
,od.ItemMeasureTypeName as UOM
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
,od.CatalogItemID
,od.CatalogItemCode
,''info'' as EVENT_BEHAVIOUR
,TRY_CAST(o.OrderStatus AS INT) as OrderStatus
,o.OrderStatusID
,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID) as ItemId
,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as PACK_QUANTITY
,SUM(CAST(od.TaxValue AS DECIMAL(19,3))) as TaxValue
,SUM(CAST(od.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY od.OrderNumber
,od.StoreId
,o.SentDateUTC
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName
,od.ItemMeasureTypeName
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))
,od.CatalogItemID
,od.CatalogItemCode
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID)
,o.OrderStatus
,o.OrderStatusID
,o.OrderStatusUIName
,o.DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
) AS source_query;',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [retry_count], [timeout_minutes],
            [staging_columns], [created_at], [updated_at])
    VALUES (N'Order Items', N'MMAN_PRE_ORDEREVENT',
            N'IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

SELECT * INTO [stage].[MMAN_PRE_ORDEREVENT]
FROM (
SELECT  od.OrderNumber
,od.StoreId
,''ORDER'' as EVENT_TYPE
,o.SentDateUTC as EVENT_TS
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
,od.ItemMeasureTypeName as UOM
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
,od.CatalogItemID
,od.CatalogItemCode
,''info'' as EVENT_BEHAVIOUR
,TRY_CAST(o.OrderStatus AS INT) as OrderStatus
,o.OrderStatusID
,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID) as ItemId
,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as PACK_QUANTITY
,SUM(CAST(od.TaxValue AS DECIMAL(19,3))) as TaxValue
,SUM(CAST(od.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY od.OrderNumber
,od.StoreId
,o.SentDateUTC
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName
,od.ItemMeasureTypeName
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))
,od.CatalogItemID
,od.CatalogItemCode
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID)
,o.OrderStatus
,o.OrderStatusID
,o.OrderStatusUIName
,o.DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
) AS source_query;',
            1, N'Staging', 0, 3, 30,
            N'["OrderNumber", "StoreId", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "EVENT_BEHAVIOUR", "OrderStatus", "OrderStatusID", "OrderStatusUIName", "DeliveryDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
            GETDATE(), GETDATE());
GO
