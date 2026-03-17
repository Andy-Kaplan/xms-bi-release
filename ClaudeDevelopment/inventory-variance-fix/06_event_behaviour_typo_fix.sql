-- =============================================================================
-- Script 06: EVENT_BEHAVIOUR Typo Fix + Global Dedup + Load Step Fixes
-- Fixes:  S8 — EVENT_BEHANIOUR typo in staging column alias and mapping
--         S9 — Dedup (ROW_NUMBER) only on ORDER branch; extend to all branches
--         Load step typo (EVENT_BEHANIOUR) in STOCKEVENT Load step
--         Load step bug (STOCK_EVENT_SRC_KEY) in STOCKEVENT_STOCKORDER Load step
-- Target 1: [core].[int_marketman001].[StagingControl], step_name = 'Stock Event'
-- Target 2: [core].[int_marketman001].[EntityMappings], entity_name = 'STOCKEVENT'
-- Target 3: [core].[int_marketman001].[StagingControl], step_name = 'Data Vault load - STOCKEVENT'
-- Target 4: [core].[int_marketman001].[StagingControl], step_name = 'Data Vault load - STOCKEVENT_STOCKORDER'
-- Date:   2026-03-12
-- =============================================================================
-- S8: The column alias EVENT_BEHANIOUR (missing V) propagates through staging
--     into entity mappings. All references are corrected to EVENT_BEHAVIOUR.
-- S9: Previously only the ORDER branch had ROW_NUMBER dedup. The new query
--     wraps the entire UNION ALL in a single dedup layer:
--     ROW_NUMBER() OVER (PARTITION BY SRC_KEY ORDER BY EVENT_TS DESC)
-- MERGE 3: Load step for STOCKEVENT hub referenced EVENT_BEHANIOUR (typo)
-- MERGE 4: Load step for STOCKEVENT_STOCKORDER link referenced
--          STOCK_EVENT_SRC_KEY which doesn't exist in MMAN_PRE_ORDEREVENT.
--          Correct key is CONCAT_WS('-', StoreId, OrderNumber, CatalogItemID)
--          matching the SRC_KEY formula in the Stock Event staging step.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- MERGE 1: StagingControl — replace query_sql and staging_columns
-- ---------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Stock Event')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = N'IF OBJECT_ID(''stage.MMAN_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKEVENT];

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
      ,EVENT_BEHAVIOUR
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
      ,EVENT_BEHAVIOUR
      ,itemId
      ,storeID
      ,ROW_NUMBER() OVER (PARTITION BY SRC_KEY ORDER BY EVENT_TS DESC) AS RANKER
FROM
(
SELECT CONCAT_WS(''-'',[StoreId],[OrderNumber],[CatalogItemID]) AS SRC_KEY
      ,[EVENT_TYPE]
      ,[EVENT_TS]
      ,[PACK_DESC]
      ,[PACK_QUANTITY] AS PACK_QUANTITY
      ,[UOM]
      ,ISNULL([UOM_PACK_SIZE],1) * [PACK_QUANTITY] AS UOM_QUANTITY
      ,[CatalogItemCode] AS EXTERNAL_REF
      ,[CatalogItemID] AS INTERNAL_REF
      ,''+'' as [EVENT_BEHAVIOUR]
      ,[itemId]
      ,storeID
  FROM [stage].[MMAN_PRE_ORDEREVENT]
  WHERE [OrderStatusUIName] = ''Received''

UNION ALL

  SELECT CountItemId as SRC_KEY
      ,[EVENT_TYPE]
      ,CreateDateUTC as EVENT_TS
      ,[PACK_DESC]
      ,[UOM_COUNT_AMOUNT] AS PACK_QUANTITY
      ,[UOM]
      ,[UOM_COUNT_AMOUNT] AS UOM_QUANTITY
      ,NULL AS EXTERNAL_REF
      ,[ItemID] AS INTERNAL_REF
      ,''COUNT'' as [EVENT_BEHAVIOUR]
      ,[ItemID] AS itemId
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
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
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
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
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
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
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
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_TRANSFERS]
) AS sub
) SUBRANK
WHERE RANKER = 1
) AS source_query;',
        staging_columns = N'["SRC_KEY", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR", "itemId", "storeID"]',
        updated_at = GETDATE();

-- ---------------------------------------------------------------------------
-- MERGE 2: EntityMappings — fix EVENT_BEHANIOUR typo in source_columns
-- ---------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[EntityMappings] AS tgt
USING (VALUES (N'STOCKEVENT', N'MMAN_STOCKEVENT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns = REPLACE(CAST(source_columns AS NVARCHAR(MAX)), N'"EVENT_BEHANIOUR"', N'"EVENT_BEHAVIOUR"'),
        updated_at = GETDATE();

-- ---------------------------------------------------------------------------
-- MERGE 3: StagingControl Load step — fix EVENT_BEHANIOUR in the INSERT/SELECT
-- that populates load.STOCKEVENT from stage.MMAN_STOCKEVENT
-- ---------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Data Vault load - STOCKEVENT')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = REPLACE(query_sql, N'EVENT_BEHANIOUR AS EVENT_BEHAVIOUR', N'EVENT_BEHAVIOUR AS EVENT_BEHAVIOUR'),
        updated_at = GETDATE();

-- ---------------------------------------------------------------------------
-- MERGE 4: StagingControl Load step — fix STOCK_EVENT_SRC_KEY in the link
-- load for STOCKEVENT_STOCKORDER. Column doesn't exist in MMAN_PRE_ORDEREVENT;
-- must compute the STOCKEVENT business key inline using the same formula as
-- the Stock Event staging step: CONCAT_WS('-', StoreId, OrderNumber, CatalogItemID)
-- ---------------------------------------------------------------------------
MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Data Vault load - STOCKEVENT_STOCKORDER')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = REPLACE(query_sql, N'STOCK_EVENT_SRC_KEY', N'CONCAT_WS(''-'', StoreId, OrderNumber, CatalogItemID)'),
        updated_at = GETDATE();
