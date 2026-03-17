-- =============================================================================
-- Script 01: 01_sale_staging_fix.sql
-- Issue Fixed: S1 — SALE events produce 0 rows because the current query joins
--   DL_MENU_PROFITABILITY -> DL_MENU_ITEMS_SUBITEMS using mismatched ID namespaces.
--   Rewritten to use DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS as the source.
-- Target Table: [core].[int_marketman001].[StagingControl]
-- Target step_name: 'Sales'
-- Date: 2026-03-12
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES ('Sales')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = N'IF OBJECT_ID(''stage.MMAN_SALES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_SALES];

SELECT * INTO [stage].[MMAN_SALES]
FROM (
    SELECT
        CONCAT_WS(''-'', storeId, ItemID) AS ItemID
        ,''SALE''  AS EVENT_TYPE
        ,''-''     AS EVENT_BEHAVIOUR
        ,UOM
        ,UOM     AS PACK_DESC
        ,1       AS PACK_QTY
        ,SUM(UOM_VALUE) AS UOM_VALUE
        ,EVENT_ID
        ,SALE_DATE
        ,storeId
    FROM (
        SELECT
            AVT.ItemID
            ,AVT.storeId
            ,UOM.Name AS UOM
            ,TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) AS UOM_VALUE
            ,CONCAT_WS(''-'', AVT.ItemID, AVT.storeId, AVT.RequestID) AS EVENT_ID
            ,AVT.INT_FETCH_DATE AS SALE_DATE
        FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS] AVT
        INNER JOIN [int_marketman001].[DL_INVENTORY_ITEMS] II
            ON AVT.ItemID = II.ID AND AVT.storeId = II.storeId
        INNER JOIN [int_marketman001].[DL_UOM_TYPES] UOM
            ON II.UOMID = UOM.ID AND II.storeId = UOM.storeId
        WHERE TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) != 0
    ) SUB
    GROUP BY
        CONCAT_WS(''-'', storeId, ItemID), UOM, EVENT_ID, SALE_DATE, storeId
) AS source_query;',
        updated_at = GETDATE();
