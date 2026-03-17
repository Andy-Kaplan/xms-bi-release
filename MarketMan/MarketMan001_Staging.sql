-- Staging Control Steps Export
-- Schema: int_marketman001
-- Generated: 2026-01-19 18:53:41
-- Total Steps: 17

-- Step: Inventory Items (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Inventory Items')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_INVITEMS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_INVITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_INVITEMS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_INVITEMS]
FROM (
SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,[ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,[MinOrderQty]
    ,[MaxOrderQty]
    ,[DateRangeType]
    ,[IsDeleted]
    ,[CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
FROM [int_marketman001].[DL_INVENTORY_ITEMS]WHERE IsDeleted != 1

UNION ALL 

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
FROM    [int_marketman001].[DL_INVENTORY_ITEMS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1

UNION ALL 

SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,NULL AS [ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,NULL AS [MinOrderQty]
    ,NULL AS [MaxOrderQty]
    ,NULL AS [DateRangeType]
    ,[IsDeleted]
    ,NULL AS [CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
FROM [int_marketman001].[DL_INVENTORY_PREPS]WHERE IsDeleted != 1

UNION ALL 

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
FROM    [int_marketman001].[DL_INVENTORY_PREPS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1UNION ALLSELECT DISTINCT
    CONCAT_WS(''-'',[storeId],[COGSCategoryID]) as INVITEM_ID
    ,[COGSCategory] as InvItemName
    ,NULL AS PARENT_ID
    ,NULL AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Inventory Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Inventory Items', N'MMAN_INVITEMS', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_INVITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_INVITEMS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_INVITEMS]
FROM (
SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,[ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,[MinOrderQty]
    ,[MaxOrderQty]
    ,[DateRangeType]
    ,[IsDeleted]
    ,[CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
FROM [int_marketman001].[DL_INVENTORY_ITEMS]WHERE IsDeleted != 1

UNION ALL 

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
FROM    [int_marketman001].[DL_INVENTORY_ITEMS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1

UNION ALL 

SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,NULL AS [ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,NULL AS [MinOrderQty]
    ,NULL AS [MaxOrderQty]
    ,NULL AS [DateRangeType]
    ,[IsDeleted]
    ,NULL AS [CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
FROM [int_marketman001].[DL_INVENTORY_PREPS]WHERE IsDeleted != 1

UNION ALL 

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
FROM    [int_marketman001].[DL_INVENTORY_PREPS] PARENTLEFT OUTER JOIN    (    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
     FROM
	    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]    ) COGON PARENT.[CategoryID] = COG.[CategoryID]WHERE IsDeleted != 1UNION ALLSELECT DISTINCT
    CONCAT_WS(''-'',[storeId],[COGSCategoryID]) as INVITEM_ID
    ,[COGSCategory] as InvItemName
    ,NULL AS PARENT_ID
    ,NULL AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL"]', GETDATE(), GETDATE());
END
GO

-- Step: Invoice Items (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Invoice Items')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_PRE_INVOICE',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      --,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
      
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID 
    ,di.CatalogItemCode 
    --,''info'' as EVENT_BEHAVIOUR
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

--,ipi.ID as ItemId
-- SELECT * 
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId 
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId  
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN  [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS] ipi 
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId
 --WHERE LTRIM(RTRIM(d.comments)) != ''''
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
     -- ,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName 
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
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["OrderNumber", "storeId", "EVENT_TYPE", "DOC_PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "DocTypeID", "DocType", "DocStatusID", "DocStatusType", "OrderStatusUIName", "DeliveryDateUTC", "DocDateUTC", "DueDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "ORDER_PACK_QUANTITY", "DOC_ORDERED_PACK_QUANTITY", "DOC_PACK_QUANTITY", "DELIVERED_PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Invoice Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Invoice Items', N'MMAN_PRE_INVOICE', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      --,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
      
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID 
    ,di.CatalogItemCode 
    --,''info'' as EVENT_BEHAVIOUR
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

--,ipi.ID as ItemId
-- SELECT * 
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId 
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId  
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN  [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS] ipi 
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId
 --WHERE LTRIM(RTRIM(d.comments)) != ''''
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
     -- ,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName 
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
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["OrderNumber", "storeId", "EVENT_TYPE", "DOC_PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "DocTypeID", "DocType", "DocStatusID", "DocStatusType", "OrderStatusUIName", "DeliveryDateUTC", "DocDateUTC", "DueDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "ORDER_PACK_QUANTITY", "DOC_ORDERED_PACK_QUANTITY", "DOC_PACK_QUANTITY", "DELIVERED_PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]', GETDATE(), GETDATE());
END
GO

-- Step: Location (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_LOCATION',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LOCATION]
FROM (
SELECT
    [storeId]
    ,[StoreName]
    ,[LOADTS_UTC]
    ,1 AS BOTTOM_LEVEL
    ,''Location'' AS LEVEL_NAME
FROM
    [int_marketman001].[DL_STORE]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["storeId", "StoreName", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Location', N'MMAN_LOCATION', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LOCATION]
FROM (
SELECT
    [storeId]
    ,[StoreName]
    ,[LOADTS_UTC]
    ,1 AS BOTTOM_LEVEL
    ,''Location'' AS LEVEL_NAME
FROM
    [int_marketman001].[DL_STORE]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["storeId", "StoreName", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]', GETDATE(), GETDATE());
END
GO

-- Step: MMAN_PREP_RECIPES (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'MMAN_PREP_RECIPES')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_PREP_RECIPES',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
    ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
    ,UOM.[Name] AS UOM
    ,[ActualUsage] AS UOM_VALUE
FROM
    [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
INNER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.ItemMeasureTypeID = UOM.ID
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'MMAN_PREP_RECIPES';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'MMAN_PREP_RECIPES', N'MMAN_PREP_RECIPES', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
    ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
    ,UOM.[Name] AS UOM
    ,[ActualUsage] AS UOM_VALUE
FROM
    [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
INNER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.ItemMeasureTypeID = UOM.ID
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]', GETDATE(), GETDATE());
END
GO

-- Step: Order Items (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Order Items')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_PRE_ORDEREVENT',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

-- Create the staging table from the query
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
 -- SELECT o.*, od.*, ipi.*
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN  [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS] ipi 
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId
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
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["OrderNumber", "StoreId", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "EVENT_BEHAVIOUR", "OrderStatus", "OrderStatusID", "OrderStatusUIName", "DeliveryDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Order Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Order Items', N'MMAN_PRE_ORDEREVENT', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

-- Create the staging table from the query
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
 -- SELECT o.*, od.*, ipi.*
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN  [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS] ipi 
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId
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
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["OrderNumber", "StoreId", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "EVENT_BEHAVIOUR", "OrderStatus", "OrderStatusID", "OrderStatusUIName", "DeliveryDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]', GETDATE(), GETDATE());
END
GO

-- Step: Product Details (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Product Details')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_PRODUCT',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRODUCT]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,MIP.[MenuItemName]
    ,MIP.[MenuItemPrice]
    ,MIP.[RecipeIngredientsCost]
    ,MIP.[storeId]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,1 AS BOTTOM_LEVEL
    ,NULL AS PARENT_ID
    ,''Product'' AS LEVEL_NAME
    ,''-999'' AS OCC_ID
FROM    [int_marketman001].[DL_MENU_ITEMS] MILEFT OUTER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIPON MIP.[ID] = MI.[ID]
AND MIP.[storeId] = MI.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
ON MIP.[ID] = REC.[ID]
AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PosCode", "MenuItemName", "MenuItemPrice", "RecipeIngredientsCost", "storeId", "INVITEM_ID", "UOM", "UOM_VALUE", "BOTTOM_LEVEL", "PARENT_ID", "LEVEL_NAME", "OCC_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Product Details';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Product Details', N'MMAN_PRODUCT', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRODUCT]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,MIP.[MenuItemName]
    ,MIP.[MenuItemPrice]
    ,MIP.[RecipeIngredientsCost]
    ,MIP.[storeId]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,1 AS BOTTOM_LEVEL
    ,NULL AS PARENT_ID
    ,''Product'' AS LEVEL_NAME
    ,''-999'' AS OCC_ID
FROM    [int_marketman001].[DL_MENU_ITEMS] MILEFT OUTER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIPON MIP.[ID] = MI.[ID]
AND MIP.[storeId] = MI.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
ON MIP.[ID] = REC.[ID]
AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["PosCode", "MenuItemName", "MenuItemPrice", "RecipeIngredientsCost", "storeId", "INVITEM_ID", "UOM", "UOM_VALUE", "BOTTOM_LEVEL", "PARENT_ID", "LEVEL_NAME", "OCC_ID"]', GETDATE(), GETDATE());
END
GO

-- Step: production (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'production')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_PRE_PRODUCTION',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_PRODUCTION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_PRODUCTION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_PRODUCTION]
FROM (
select CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) as productionItemId
,pi.storeId
,''PRODUCTION'' as EVENT_TYPE
,pi.ItemName as PACK_DESC
,pi.UOM as UOM    
,TRY_CAST(pe.CreateDate AS datetime2) as CreateDateUTC
,TRY_CAST(pe.EventDate AS  datetime2) as EventDateUTC
,TRY_CAST(pi.UpdateDate AS datetime2) as UpdateDateUTC
,SUM(TRY_CAST(pi.Quantity AS DECIMAL(19,3)) ) AS UOM_PACK_SIZE
FROM [int_marketman001].[DL_PRODUCTION_EVENTS] pe
JOIN [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] pi 
ON PE.EventID = pi.EventID AND PE.StoreId = pi.StoreId
GROUP BY CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) 
,pi.storeId
,pi.ItemName 
,pi.UOM    
,TRY_CAST(pe.CreateDate AS datetime2) 
,TRY_CAST(pe.EventDate AS  datetime2) 
,TRY_CAST(pi.UpdateDate AS datetime2)
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["productionItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "CreateDateUTC", "EventDateUTC", "UpdateDateUTC", "UOM_PACK_SIZE"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'production';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'production', N'MMAN_PRE_PRODUCTION', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_PRODUCTION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_PRODUCTION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_PRODUCTION]
FROM (
select CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) as productionItemId
,pi.storeId
,''PRODUCTION'' as EVENT_TYPE
,pi.ItemName as PACK_DESC
,pi.UOM as UOM    
,TRY_CAST(pe.CreateDate AS datetime2) as CreateDateUTC
,TRY_CAST(pe.EventDate AS  datetime2) as EventDateUTC
,TRY_CAST(pi.UpdateDate AS datetime2) as UpdateDateUTC
,SUM(TRY_CAST(pi.Quantity AS DECIMAL(19,3)) ) AS UOM_PACK_SIZE
FROM [int_marketman001].[DL_PRODUCTION_EVENTS] pe
JOIN [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] pi 
ON PE.EventID = pi.EventID AND PE.StoreId = pi.StoreId
GROUP BY CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) 
,pi.storeId
,pi.ItemName 
,pi.UOM    
,TRY_CAST(pe.CreateDate AS datetime2) 
,TRY_CAST(pe.EventDate AS  datetime2) 
,TRY_CAST(pi.UpdateDate AS datetime2)
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["productionItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "CreateDateUTC", "EventDateUTC", "UpdateDateUTC", "UOM_PACK_SIZE"]', GETDATE(), GETDATE());
END
GO

-- Step: Production Events (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Production Events')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_PROD_EVENTS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PROD_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PROD_EVENTS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PROD_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        REC.[ItemID]
        ,PE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) * ISNULL(TRY_CAST(REC.[ActualUsage] AS NUMERIC),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    ON PEI.[ItemID] = REC.[header_item_id]
    AND PEI.[storeId] = REC.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
    AND REC.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
UNION ALL

SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        PEI.[ItemID]
        ,PE.[storeId]
        ,PEI.[UOM] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Production Events';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Production Events', N'MMAN_PROD_EVENTS', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PROD_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PROD_EVENTS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PROD_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        REC.[ItemID]
        ,PE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) * ISNULL(TRY_CAST(REC.[ActualUsage] AS NUMERIC),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    ON PEI.[ItemID] = REC.[header_item_id]
    AND PEI.[storeId] = REC.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
    AND REC.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
UNION ALL

SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        PEI.[ItemID]
        ,PE.[storeId]
        ,PEI.[UOM] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]', GETDATE(), GETDATE());
END
GO

-- Step: Report (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Report')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_REPORT',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID]) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM 
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID] 
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Report';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Report', N'MMAN_REPORT', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID]) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM 
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID] 
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]', GETDATE(), GETDATE());
END
GO

-- Step: Sales (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Sales')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_SALES',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_SALES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_SALES];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_SALES]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''SALE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,SALE_DATE
    ,storeId
FROM
    (
    SELECT 
        REC.[ItemID]
        ,MP.[storeId]
        ,UOM.[Name] AS UOM
        ,ISNULL(TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)),0) * ISNULL(TRY_CAST(REC.[ActualUsage] AS NUMERIC),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', REC.[ItemID], MP.[storeId], MP.[RequestID]) AS EVENT_ID
        ,MP.[INT_FETCH_DATE] AS SALE_DATE
    FROM
        [int_marketman001].[DL_MENU_PROFITABILITY] MP
    INNER JOIN
        [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
    ON MP.[ID] = REC.[ID]
    AND MP.[storeId] = REC.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
    AND REC.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,SALE_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "SALE_DATE", "storeId"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Sales';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Sales', N'MMAN_SALES', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_SALES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_SALES];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_SALES]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''SALE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,SALE_DATE
    ,storeId
FROM
    (
    SELECT 
        REC.[ItemID]
        ,MP.[storeId]
        ,UOM.[Name] AS UOM
        ,ISNULL(TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)),0) * ISNULL(TRY_CAST(REC.[ActualUsage] AS NUMERIC),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', REC.[ItemID], MP.[storeId], MP.[RequestID]) AS EVENT_ID
        ,MP.[INT_FETCH_DATE] AS SALE_DATE
    FROM
        [int_marketman001].[DL_MENU_PROFITABILITY] MP
    INNER JOIN
        [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
    ON MP.[ID] = REC.[ID]
    AND MP.[storeId] = REC.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
    AND REC.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,SALE_DATE
    ,storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "SALE_DATE", "storeId"]', GETDATE(), GETDATE());
END
GO

-- Step: Sales Line Item (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Sales Line Item')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_LINEITEM',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LINEITEM];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LINEITEM]
FROM (
SELECT
    *
    ,[NET_PRICE] * [QUANTITY_FINAL] AS NET_VALUE
    ,[GROSS_PRICE] * [QUANTITY_FINAL] AS GROSS_VALUE
    ,SUM([NET_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS NET_VALUE_HDR
    ,SUM([QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS QUANTITY_HDR
    ,SUM([GROSS_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS GROSS_VALUE_HDR
    ,''-999'' AS OCC_ID
FROM
    (
    SELECT
        SRC_KEY
        ,HEADER_ID
        ,LINEITEM_TYPE
        ,[storeId]
        ,[PosCode]
        ,[NET_PRICE]
        ,[GROSS_PRICE]
        ,[QUANTITY_ADJ]+([RN_SWITCH]*([QUANTITY] - SUM([QUANTITY_ADJ]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]))) AS [QUANTITY_FINAL]
        ,[SALE_DATE]
     FROM
        (
        SELECT
            CONCAT_WS(''-'',[ID], [SALE_DATE], [storeId], [PosCode]) AS SRC_KEY
            ,CONCAT_WS(''-'', [SALE_DATE], [storeId], [PosCode]) AS HEADER_ID
            ,''PROD'' AS LINEITEM_TYPE
            ,COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]) AS POS_COUNT
            ,CEILING(ROW_NUMBER() OVER(PARTITION BY [ID], [SALE_DATE], [storeId] ORDER BY [PosCode]) / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId])) AS RN_SWITCH
            ,[storeId]
            ,[PosCode]
            ,[NET_PRICE]
            ,[GROSS_PRICE]
            ,[QUANTITY]
            ,ROUND([QUANTITY] / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]),0) AS [QUANTITY_ADJ]
            ,[SALE_DATE]
            ,[ID]
        FROM
            (
            SELECT 
                MP.[ID]
                ,MP.[storeId]
                ,TRIM(value) AS [PosCode]
                ,ISNULL(TRY_CAST(MP.[NetItemPrice] AS DECIMAL(32,10)),0) AS NET_PRICE
                ,ISNULL(TRY_CAST(MP.[MenuItemPrice] AS DECIMAL(32,10)),0) AS GROSS_PRICE
                ,ISNULL(TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)),0) AS QUANTITY
                ,MP.[INT_FETCH_DATE] AS SALE_DATE
            FROM
                [int_marketman001].[DL_MENU_PROFITABILITY] MP

            CROSS APPLY STRING_SPLIT(MP.[PosCode], ''|'')

            WHERE TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)) != 0 ) SUB
        ) SUB2
    ) SUB3
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "storeId", "PosCode", "NET_PRICE", "GROSS_PRICE", "QUANTITY_FINAL", "SALE_DATE", "NET_VALUE", "GROSS_VALUE", "NET_VALUE_HDR", "QUANTITY_HDR", "GROSS_VALUE_HDR", "OCC_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Sales Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Sales Line Item', N'MMAN_LINEITEM', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LINEITEM];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LINEITEM]
FROM (
SELECT
    *
    ,[NET_PRICE] * [QUANTITY_FINAL] AS NET_VALUE
    ,[GROSS_PRICE] * [QUANTITY_FINAL] AS GROSS_VALUE
    ,SUM([NET_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS NET_VALUE_HDR
    ,SUM([QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS QUANTITY_HDR
    ,SUM([GROSS_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS GROSS_VALUE_HDR
    ,''-999'' AS OCC_ID
FROM
    (
    SELECT
        SRC_KEY
        ,HEADER_ID
        ,LINEITEM_TYPE
        ,[storeId]
        ,[PosCode]
        ,[NET_PRICE]
        ,[GROSS_PRICE]
        ,[QUANTITY_ADJ]+([RN_SWITCH]*([QUANTITY] - SUM([QUANTITY_ADJ]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]))) AS [QUANTITY_FINAL]
        ,[SALE_DATE]
     FROM
        (
        SELECT
            CONCAT_WS(''-'',[ID], [SALE_DATE], [storeId], [PosCode]) AS SRC_KEY
            ,CONCAT_WS(''-'', [SALE_DATE], [storeId], [PosCode]) AS HEADER_ID
            ,''PROD'' AS LINEITEM_TYPE
            ,COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]) AS POS_COUNT
            ,CEILING(ROW_NUMBER() OVER(PARTITION BY [ID], [SALE_DATE], [storeId] ORDER BY [PosCode]) / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId])) AS RN_SWITCH
            ,[storeId]
            ,[PosCode]
            ,[NET_PRICE]
            ,[GROSS_PRICE]
            ,[QUANTITY]
            ,ROUND([QUANTITY] / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]),0) AS [QUANTITY_ADJ]
            ,[SALE_DATE]
            ,[ID]
        FROM
            (
            SELECT 
                MP.[ID]
                ,MP.[storeId]
                ,TRIM(value) AS [PosCode]
                ,ISNULL(TRY_CAST(MP.[NetItemPrice] AS DECIMAL(32,10)),0) AS NET_PRICE
                ,ISNULL(TRY_CAST(MP.[MenuItemPrice] AS DECIMAL(32,10)),0) AS GROSS_PRICE
                ,ISNULL(TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)),0) AS QUANTITY
                ,MP.[INT_FETCH_DATE] AS SALE_DATE
            FROM
                [int_marketman001].[DL_MENU_PROFITABILITY] MP

            CROSS APPLY STRING_SPLIT(MP.[PosCode], ''|'')

            WHERE TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)) != 0 ) SUB
        ) SUB2
    ) SUB3
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "storeId", "PosCode", "NET_PRICE", "GROSS_PRICE", "QUANTITY_FINAL", "SALE_DATE", "NET_VALUE", "GROSS_VALUE", "NET_VALUE_HDR", "QUANTITY_HDR", "GROSS_VALUE_HDR", "OCC_ID"]', GETDATE(), GETDATE());
END
GO

-- Step: Stock Count (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Stock Count')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_PRE_STOCK_COUNT',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_STOCK_COUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_STOCK_COUNT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_STOCK_COUNT]
FROM (
SELECT CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId) as CountItemId
,icl.storeId
,''STOCKCOUNT'' as EVENT_TYPE
,ii.UOMName as PACK_DESC
,ii.UOMName as UOM    
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId) as ItemId
,TRY_CAST(ic.CountDateUTC AS datetime2) as CreateDateUTC
,SUM(TRY_CAST(icl.TotalCount AS DECIMAL(19,3)) ) AS UOM_COUNT_AMOUNT
,SUM(TRY_CAST(icl.TotalValue AS DECIMAL(19,3)) ) AS UOM_COUNT_VALUE
-- SELECT * 
FROM [int_marketman001].[DL_INVENTORY_COUNTS] ic
JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] icl on ic.ID = icl.ID and ic.storeId = icl.storeId
JOIN  [int_marketman001].[DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS] lcd 
on lcd.id = icl.ID and lcd.storeId = icl.storeId and lcd.Lines_id = icl.LineID

JOIN [int_marketman001].[DL_INVENTORY_ITEMS] ii on ii.ID = icl.ItemId and  ii.storeId = icl.storeId
-- where icl.TotalCount != lcd.CountDefAmount
GROUP BY CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId)
,icl.storeId
--,lcd.CountDefName 
,ii.UOMName    
,TRY_CAST(ic.CountDateUTC AS datetime2)
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId)
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["CountItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "ItemId", "CreateDateUTC", "UOM_COUNT_AMOUNT", "UOM_COUNT_VALUE"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Stock Count';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Stock Count', N'MMAN_PRE_STOCK_COUNT', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_STOCK_COUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_STOCK_COUNT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_STOCK_COUNT]
FROM (
SELECT CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId) as CountItemId
,icl.storeId
,''STOCKCOUNT'' as EVENT_TYPE
,ii.UOMName as PACK_DESC
,ii.UOMName as UOM    
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId) as ItemId
,TRY_CAST(ic.CountDateUTC AS datetime2) as CreateDateUTC
,SUM(TRY_CAST(icl.TotalCount AS DECIMAL(19,3)) ) AS UOM_COUNT_AMOUNT
,SUM(TRY_CAST(icl.TotalValue AS DECIMAL(19,3)) ) AS UOM_COUNT_VALUE
-- SELECT * 
FROM [int_marketman001].[DL_INVENTORY_COUNTS] ic
JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] icl on ic.ID = icl.ID and ic.storeId = icl.storeId
JOIN  [int_marketman001].[DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS] lcd 
on lcd.id = icl.ID and lcd.storeId = icl.storeId and lcd.Lines_id = icl.LineID

JOIN [int_marketman001].[DL_INVENTORY_ITEMS] ii on ii.ID = icl.ItemId and  ii.storeId = icl.storeId
-- where icl.TotalCount != lcd.CountDefAmount
GROUP BY CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId)
,icl.storeId
--,lcd.CountDefName 
,ii.UOMName    
,TRY_CAST(ic.CountDateUTC AS datetime2)
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId)
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["CountItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "ItemId", "CreateDateUTC", "UOM_COUNT_AMOUNT", "UOM_COUNT_VALUE"]', GETDATE(), GETDATE());
END
GO

-- Step: Stock Orders (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Stock Orders')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_STOCKORDER',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_STOCKORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKORDER];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_STOCKORDER]
FROM (
SELECT
    [OrderNumber] AS ORDER_SRC_KEY
    ,[BuyerGuid] AS EMP_SRC_KEY
    ,[OrderStatusUIName] AS ORDER_STATUS
    ,TRY_CAST([DeliveryDateUTC] AS datetime2) AS DELIVERY_DATE
    ,TRY_CAST([SentDateUTC] AS datetime2) AS ORDER_DATE
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) AS ORDER_TOTAL
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) - TRY_CAST([PriceTotalWithoutVAT] AS FLOAT) AS ORDER_TAX
    ,[Comments] AS ORDER_INFO
    ,[VendorGuid] AS DISTRIBUTOR_SRC_KEY
    ,[storeId] AS LOCATION_SRC_KEY
FROM
    [int_marketman001].[DL_ORDERS_BY_SENTDATE] O
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ORDER_SRC_KEY", "EMP_SRC_KEY", "ORDER_STATUS", "DELIVERY_DATE", "ORDER_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "DISTRIBUTOR_SRC_KEY", "LOCATION_SRC_KEY"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Stock Orders';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Stock Orders', N'MMAN_STOCKORDER', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_STOCKORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKORDER];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_STOCKORDER]
FROM (
SELECT
    [OrderNumber] AS ORDER_SRC_KEY
    ,[BuyerGuid] AS EMP_SRC_KEY
    ,[OrderStatusUIName] AS ORDER_STATUS
    ,TRY_CAST([DeliveryDateUTC] AS datetime2) AS DELIVERY_DATE
    ,TRY_CAST([SentDateUTC] AS datetime2) AS ORDER_DATE
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) AS ORDER_TOTAL
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) - TRY_CAST([PriceTotalWithoutVAT] AS FLOAT) AS ORDER_TAX
    ,[Comments] AS ORDER_INFO
    ,[VendorGuid] AS DISTRIBUTOR_SRC_KEY
    ,[storeId] AS LOCATION_SRC_KEY
FROM
    [int_marketman001].[DL_ORDERS_BY_SENTDATE] O
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ORDER_SRC_KEY", "EMP_SRC_KEY", "ORDER_STATUS", "DELIVERY_DATE", "ORDER_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "DISTRIBUTOR_SRC_KEY", "LOCATION_SRC_KEY"]', GETDATE(), GETDATE());
END
GO

-- Step: Transfers (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Transfers')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_TRANSFERS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_TRANSFERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_TRANSFERS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_TRANSFERS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        TEI.[ItemID]
        ,TE.[BuyerFromGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerFromGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
	    [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerFromGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0  
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
UNION ALL
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        I.[ID] AS [ItemID]
        ,TE.[BuyerToGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerToGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
	    [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerFromGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    INNER JOIN
        [int_marketman001].[DL_INVENTORY_ITEMS] O
    ON TE.[BuyerFromGuid] = O.[storeId]
    AND TEI.[ItemID] = O.[ID]
    AND O.[IsDeleted] = 0
    INNER JOIN
	    [int_marketman001].[DL_INVENTORY_ITEMS] I
    ON O.[Name] = I.[Name]
    AND TE.[BuyerToGuid] = I.storeId
    AND I.[IsDeleted] = 0
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0 
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Transfers';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Transfers', N'MMAN_TRANSFERS', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_TRANSFERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_TRANSFERS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_TRANSFERS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        TEI.[ItemID]
        ,TE.[BuyerFromGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerFromGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
	    [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerFromGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0  
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
UNION ALL
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        I.[ID] AS [ItemID]
        ,TE.[BuyerToGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerToGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
	    [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerFromGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    INNER JOIN
        [int_marketman001].[DL_INVENTORY_ITEMS] O
    ON TE.[BuyerFromGuid] = O.[storeId]
    AND TEI.[ItemID] = O.[ID]
    AND O.[IsDeleted] = 0
    INNER JOIN
	    [int_marketman001].[DL_INVENTORY_ITEMS] I
    ON O.[Name] = I.[Name]
    AND TE.[BuyerToGuid] = I.storeId
    AND I.[IsDeleted] = 0
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0 
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]', GETDATE(), GETDATE());
END
GO

-- Step: vendors (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'vendors')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_VENDORS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_VENDORS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_VENDORS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_VENDORS]
FROM (
SELECT DISTINCT [Name]
      ,[Guid]
      ,[TaxLevelID]
      ,[CreditAccountName]
      ,[DebitAccountName]
      ,[IncomeAccountName]
      ,[VendorIRSNumber]
      ,[EnabledForOrders]
      ,[IsSuccess]
      ,[ErrorMessage]
      ,[ErrorCode]
     -- ,[RequestID]
   --  ,[storeId]
    --  ,[LOADTS_UTC]
  FROM [int_marketman001].[DL_VENDORS]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["Name", "Guid", "TaxLevelID", "CreditAccountName", "DebitAccountName", "IncomeAccountName", "VendorIRSNumber", "EnabledForOrders", "IsSuccess", "ErrorMessage", "ErrorCode"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'vendors';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'vendors', N'MMAN_VENDORS', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_VENDORS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_VENDORS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_VENDORS]
FROM (
SELECT DISTINCT [Name]
      ,[Guid]
      ,[TaxLevelID]
      ,[CreditAccountName]
      ,[DebitAccountName]
      ,[IncomeAccountName]
      ,[VendorIRSNumber]
      ,[EnabledForOrders]
      ,[IsSuccess]
      ,[ErrorMessage]
      ,[ErrorCode]
     -- ,[RequestID]
   --  ,[storeId]
    --  ,[LOADTS_UTC]
  FROM [int_marketman001].[DL_VENDORS]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["Name", "Guid", "TaxLevelID", "CreditAccountName", "DebitAccountName", "IncomeAccountName", "VendorIRSNumber", "EnabledForOrders", "IsSuccess", "ErrorMessage", "ErrorCode"]', GETDATE(), GETDATE());
END
GO

-- Step: Waste Events (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Waste Events')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_WASTE_EVENTS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_WASTE_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''WASTE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        WEI.[ItemID]
        ,WE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', WEI.[ItemID], WE.[storeId], WE.[ID]) AS EVENT_ID
        ,CAST(WE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_WASTE_EVENTS] WE
    INNER JOIN
	    [int_marketman001].[DL_WASTE_EVENTS_LINES] WEI
    ON WE.[ID] = WEI.[ID]
    AND WE.[storeId] = WEI.[storeId]
    AND WE.[BuyerGuid] = WEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON WEI.UOMID = UOM.ID
    AND WEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Waste Events';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Waste Events', N'MMAN_WASTE_EVENTS', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_WASTE_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''WASTE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        WEI.[ItemID]
        ,WE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', WEI.[ItemID], WE.[storeId], WE.[ID]) AS EVENT_ID
        ,CAST(WE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_WASTE_EVENTS] WE
    INNER JOIN
	    [int_marketman001].[DL_WASTE_EVENTS_LINES] WEI
    ON WE.[ID] = WEI.[ID]
    AND WE.[storeId] = WEI.[storeId]
    AND WE.[BuyerGuid] = WEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON WEI.UOMID = UOM.ID
    AND WEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]', GETDATE(), GETDATE());
END
GO

-- Step: Stock Event (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Stock Event')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET [staging_table] = N'MMAN_STOCKEVENT',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKEVENT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_STOCKEVENT]
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHANIOUR
      ,itemId
      ,storeID
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHANIOUR
      ,itemId
      ,storeID
      ,ROW_NUMBER() OVER (PARTITION BY SRC_KEY,EVENT_BEHANIOUR ORDER BY priority_id) AS RANKER
FROM 
(SELECT CONCAT_WS(''-'',[StoreId],[OrderNumber],[CatalogItemID]) AS SRC_KEY
      ,[EVENT_TYPE]
      ,[EVENT_TS]
      ,[PACK_DESC]
      ,[PACK_QUANTITY] AS PACK_QUANTITY
      ,[UOM]
      ,ISNULL([UOM_PACK_SIZE],1) * [PACK_QUANTITY] AS UOM_QUANTITY
      ,[CatalogItemCode] AS EXTERNAL_REF
      ,[CatalogItemID] AS INTERNAL_REF
      ,''+'' as [EVENT_BEHANIOUR]
      ,[itemId]
      ,storeID
      ,99 as priority_id
  FROM [stage].[MMAN_PRE_ORDEREVENT]
  WHERE [OrderStatusUIName] = ''Received''

  --UNION ALL

  --SELECT CONCAT_WS(''-'',[StoreId],[OrderNumber],[CatalogItemID]) AS SRC_KEY
  --    ,[EVENT_TYPE]
  --    ,DocDateUTC as EVENT_TS
  --    ,[DOC_PACK_DESC]
  --    ,[DOC_PACK_QUANTITY] AS PACK_QUANTITY
  --    ,[UOM]
  --    ,ISNULL([UOM_PACK_SIZE],1) * [DOC_PACK_QUANTITY] AS UOM_QUANTITY
  --    ,[CatalogItemCode] AS EXTERNAL_REF
  --    ,[CatalogItemID] AS INTERNAL_REF
  --    ,''+'' AS [EVENT_BEHANIOUR]
  --    ,[itemId]
  --    ,90 as priority_id
  --    FROM [stage].[MMAN_PRE_INVOICE]

      ) AS sub
      ) SUBRANK 
      WHERE RANKER = 1

UNION ALL

  SELECT CountItemId as SRC_KEY
      ,[EVENT_TYPE]
      ,CreateDateUTC as EVENT_TS
      ,[PACK_DESC]
      ,[UOM_COUNT_AMOUNT] AS PACK_QUANTITY
      ,[UOM]
      ,[UOM_COUNT_AMOUNT] AS   UOM_QUANTITY
      ,NULL AS EXTERNAL_REF
      ,[ItemID] AS INTERNAL_REF
      ,''COUNT'' as [EVENT_BEHANIOUR]
      ,[ItemID]
       ,storeID
      FROM [stage].[MMAN_PRE_STOCK_COUNT]

UNION ALL
    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[SALE_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_SALES]

UNION ALL
    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_PROD_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_WASTE_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_TRANSFERS]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["SRC_KEY", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHANIOUR", "itemId", "storeID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Stock Event';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Stock Event', N'MMAN_STOCKEVENT', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKEVENT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_STOCKEVENT]
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHANIOUR
      ,itemId
      ,storeID
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHANIOUR
      ,itemId
      ,storeID
      ,ROW_NUMBER() OVER (PARTITION BY SRC_KEY,EVENT_BEHANIOUR ORDER BY priority_id) AS RANKER
FROM 
(SELECT CONCAT_WS(''-'',[StoreId],[OrderNumber],[CatalogItemID]) AS SRC_KEY
      ,[EVENT_TYPE]
      ,[EVENT_TS]
      ,[PACK_DESC]
      ,[PACK_QUANTITY] AS PACK_QUANTITY
      ,[UOM]
      ,ISNULL([UOM_PACK_SIZE],1) * [PACK_QUANTITY] AS UOM_QUANTITY
      ,[CatalogItemCode] AS EXTERNAL_REF
      ,[CatalogItemID] AS INTERNAL_REF
      ,''+'' as [EVENT_BEHANIOUR]
      ,[itemId]
      ,storeID
      ,99 as priority_id
  FROM [stage].[MMAN_PRE_ORDEREVENT]
  WHERE [OrderStatusUIName] = ''Received''

  --UNION ALL

  --SELECT CONCAT_WS(''-'',[StoreId],[OrderNumber],[CatalogItemID]) AS SRC_KEY
  --    ,[EVENT_TYPE]
  --    ,DocDateUTC as EVENT_TS
  --    ,[DOC_PACK_DESC]
  --    ,[DOC_PACK_QUANTITY] AS PACK_QUANTITY
  --    ,[UOM]
  --    ,ISNULL([UOM_PACK_SIZE],1) * [DOC_PACK_QUANTITY] AS UOM_QUANTITY
  --    ,[CatalogItemCode] AS EXTERNAL_REF
  --    ,[CatalogItemID] AS INTERNAL_REF
  --    ,''+'' AS [EVENT_BEHANIOUR]
  --    ,[itemId]
  --    ,90 as priority_id
  --    FROM [stage].[MMAN_PRE_INVOICE]

      ) AS sub
      ) SUBRANK 
      WHERE RANKER = 1

UNION ALL

  SELECT CountItemId as SRC_KEY
      ,[EVENT_TYPE]
      ,CreateDateUTC as EVENT_TS
      ,[PACK_DESC]
      ,[UOM_COUNT_AMOUNT] AS PACK_QUANTITY
      ,[UOM]
      ,[UOM_COUNT_AMOUNT] AS   UOM_QUANTITY
      ,NULL AS EXTERNAL_REF
      ,[ItemID] AS INTERNAL_REF
      ,''COUNT'' as [EVENT_BEHANIOUR]
      ,[ItemID]
       ,storeID
      FROM [stage].[MMAN_PRE_STOCK_COUNT]

UNION ALL
    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[SALE_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_SALES]

UNION ALL
    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_PROD_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_WASTE_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR] AS EVENT_BEHANIOUR
        ,[ItemID]
        ,storeID
    FROM [stage].[MMAN_TRANSFERS]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["SRC_KEY", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHANIOUR", "itemId", "storeID"]', GETDATE(), GETDATE());
END
GO
