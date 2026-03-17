-- =============================================================================
-- C6_waste_events_fix.sql
-- Fix: MMAN_WASTE_EVENTS drops 81% of rows due to NULL BuyerGuid JOIN
-- =============================================================================
--
-- PROBLEM:
--   The MMAN_WASTE_EVENTS staging step JOINs DL_WASTE_EVENTS (WE) to
--   DL_WASTE_EVENTS_LINES (WEI) with three conditions:
--     ON WE.[ID] = WEI.[ID]
--     AND WE.[storeId] = WEI.[storeId]
--     AND WE.[BuyerGuid] = WEI.[storeId]
--
--   The third condition (WE.[BuyerGuid] = WEI.[storeId]) drops 81% of rows
--   because 17 out of 21 waste events have NULL BuyerGuid. NULL != anything
--   evaluates to UNKNOWN, so the JOIN fails silently for those rows.
--
-- FIX:
--   Remove the AND WE.[BuyerGuid] = WEI.[storeId] condition. The remaining
--   two conditions (ON WE.[ID] = WEI.[ID] AND WE.[storeId] = WEI.[storeId])
--   are sufficient to correctly match waste event headers to their line items.
--
-- TARGET: core.int_marketman001.StagingControl, step_name = 'Waste Events'
-- PATTERN: MERGE upsert on step_name
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Waste Events')) AS src (step_name)
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        [staging_table] = N'MMAN_WASTE_EVENTS',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

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
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Waste Events', N'MMAN_WASTE_EVENTS', N'IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

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
           1, N'Staging', 0, NULL, NULL, 3, 30,
           N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
           GETDATE(), GETDATE());
GO
