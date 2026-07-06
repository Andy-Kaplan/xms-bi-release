-- ============================================================
-- Script: 24_invmargebrut_header_fix.sql
-- Purpose: Fix InvMargeBrut CustomGroupedDataGrid HTTP 500 error
--
-- Root cause: The QueryTemplate includes a second SELECT
--   (header metadata) that produces a second result set.
--   The CustomGroupedDataGrid microservice handler does NOT
--   support dual result sets — it crashes with HTTP 500.
--   Other working CustomGroupedDataGrid queries (InvKPIGrouped,
--   SalesKPI) have NO header SELECT.
--
-- Fix: Remove the header SELECT from the QueryTemplate.
--   The CustomGroupedDataGrid card type does not use header
--   metadata from a second result set.
--
-- Affects: 1 VisualisationQueries record
--   - InvMargeBrut / CustomGroupedDataGrid
--
-- Run against: core database
-- ============================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvMargeBrut', N'CustomGroupedDataGrid')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'WITH Revenue AS (
    SELECT
        F.LOCATION_HUB_ID,
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
        SUM(ISNULL(F.[NET_VALUE],0)) AS TURNOVER,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS RECIPE_COGS,
        CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
             ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
        END AS GP_PERC
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY F.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
),
Usage AS (
    SELECT
        FU.LOCATION_HUB_ID,
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)) / 1000.0, 1) ELSE ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)), 1) END AS PURCHASE_QTY,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))), 1) END AS CONSUMPTION_QTY,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1) END AS WASTE_QTY
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause
    GROUP BY FU.LOCATION_HUB_ID,
             COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
             COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
)
SELECT
    U.LOCATION_NAME AS ParentId,
    CONCAT_WS(''-'', U.LOCATION_NAME, U.CATEGORY) AS Id,
    U.CATEGORY AS GroupedColumn,
    U.PURCHASE_QTY AS Column1,
    U.CONSUMPTION_QTY AS Column2,
    U.WASTE_QTY AS Column3,
    NULL AS Column4, NULL AS Column5, NULL AS Column6,
    NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM Usage U
UNION ALL
SELECT
    NULL AS ParentId,
    R.LOCATION_NAME AS Id,
    R.LOCATION_NAME AS GroupedColumn,
    SUM(U.PURCHASE_QTY) AS Column1,
    SUM(U.CONSUMPTION_QTY) AS Column2,
    SUM(U.WASTE_QTY) AS Column3,
    R.TURNOVER AS Column4,
    R.RECIPE_COGS AS Column5,
    R.GP_PERC AS Column6,
    NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM Revenue R
LEFT JOIN Usage U ON R.LOCATION_HUB_ID = U.LOCATION_HUB_ID
GROUP BY R.LOCATION_NAME, R.TURNOVER, R.RECIPE_COGS, R.GP_PERC',
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Status, QueryTemplate, ParameterMappings, FilterDefinitions, ModifiedDate)
    VALUES (N'InvMargeBrut', N'CustomGroupedDataGrid', N'LIVE',
            N'-- placeholder: should not reach here', NULL, NULL, GETDATE());
