-- =============================================================================
-- Script 05: Transfer Staging Fix
-- Fixes:  S6 — BuyerFromGuid = storeId filter on TO-leg drops rows
--         S7 — Name-based cross-store matching on TO-leg is unreliable
-- Target: [core].[int_marketman001].[StagingControl], step_name = 'Transfers'
-- Date:   2026-03-12
-- =============================================================================
-- S6: The TO-leg (EVENT_BEHAVIOUR = '+') incorrectly filters on
--     BuyerFromGuid = storeId. It should filter on BuyerToGuid = storeId
--     so that it picks up DL rows fetched in the receiving store's API context.
-- S7: With the corrected filter, TEI.[ItemID] is already the TO store's item,
--     so the name-based cross-store JOIN (DL_INVENTORY_ITEMS O -> I on Name)
--     is removed entirely.
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Transfers')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = N'IF OBJECT_ID(''stage.MMAN_TRANSFERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_TRANSFERS];

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
        TEI.[ItemID]
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
    AND TE.[BuyerToGuid] = TE.[storeId]
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
) AS source_query;',
        staging_columns = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        updated_at = GETDATE();
