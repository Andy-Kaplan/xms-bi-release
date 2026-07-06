-- ============================================================
-- Script: 23_productmargins_sort_by_cost.sql
-- Purpose: Sort ProductMargins StackedBarChartCard by cost
--          descending (highest cost first) instead of
--          alphabetical product name.
--
-- Change: Pass COST through the UNION ALL subquery and use
--         DENSE_RANK() OVER(ORDER BY COST DESC) for LabelSort
--         instead of ROW_NUMBER() OVER(ORDER BY PRODUCT_CATEGORY).
--
-- Affects: 1 VisualisationQueries record
--   - ProductMargins / StackedBarChartCard
--
-- Run against: core database
-- ============================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'ProductMargins', N'StackedBarChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'WITH Base AS
(
SELECT
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS PRODUCT_CATEGORY
    ,ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS MARGIN
    ,ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS COST
    ,100 - ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) - ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS DISCOUNTS
FROM
    [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_REVCENTER] revcenter ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_CHANNEL] channel ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DEAL] deal ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DISCOUNT] Discount ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])
)
SELECT
    PRODUCT_CATEGORY AS xAxisLabel,
    DENSE_RANK() OVER(ORDER BY COST DESC) AS LabelSort,
    [Value],
    ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
    Label AS VisId,
    Stack
FROM
(
SELECT
    PRODUCT_CATEGORY
    ,''Margin'' AS Label
    ,MARGIN AS Value
    ,''A'' AS Stack
    ,COST
FROM BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Costs'' AS Label
    ,COST AS Value
    ,''B'' AS Stack
    ,COST
FROM BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,''B'' AS Stack
    ,COST
FROM BASE
) SUB

SELECT
''Product Category'' AS XAxisLabel,
''Margin %'' AS YAxisLabel,
''Product Margins'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
        ModifiedDate = GETDATE();
GO
