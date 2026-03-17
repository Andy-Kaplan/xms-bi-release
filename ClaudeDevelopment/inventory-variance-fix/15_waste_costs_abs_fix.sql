-- =============================================================================
-- Fix #2: InvTheoMargin — ABS() waste costs for correct pie chart display
-- =============================================================================
-- Problem: WASTE_QTY is stored as negative in F_INV_COUNTS_DAY (stock OUT
-- convention). The query passes this through as-is, showing "Waste Costs: -79"
-- on the pie chart. This is semantically wrong — waste is a cost that should
-- reduce profit, not a negative number that inflates it.
--
-- Fix: Wrap WasteVal with ABS() so it displays as a positive cost segment.
-- Profit Margin = Sales - NegativeVariance - Usage - ABS(Waste), correctly
-- reducing profit by waste costs.
-- =============================================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvTheoMargin', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'WITH Sales AS
(
SELECT
    ROUND(SUM(NET_VALUE),2) AS Sales
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN
    [presentation].[D_LOCATION] location
ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
),

Inventory AS
(
SELECT
    ABS(ROUND(SUM(WasteVal),2)) AS Waste
    ,ROUND(SUM(UsageVal),2) AS Usage
    ,CASE WHEN ROUND(SUM(VarianceVal),2) < 0 THEN ABS(ROUND(SUM(VarianceVal),2)) ELSE 0 END AS NegativeVariance
FROM
    (
    SELECT
        SUM(ISNULL(FC.WASTE_QTY,0) * ISNULL(FC.UOM_COST,0)) AS WasteVal
        ,SUM(ISNULL(FC.SALE_QTY,0) * ISNULL(FC.UOM_COST,0)) AS UsageVal
        ,SUM(FC.VARIANCE * ISNULL(FC.UOM_COST,0)) AS VarianceVal
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterClause
    GROUP BY
        FC.LOCATION_HUB_ID
        ,FC.INVITEM_HUB_ID
    ) SUB
)

SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Profit Margin'' AS Label
    ,FORMAT(Sales - NegativeVariance - Usage - Waste, ''N0'') AS Value
    ,1 AS Id
FROM
    Sales
CROSS JOIN
    Inventory
UNION ALL
SELECT
    ''Recipe Costs'' AS Label
    ,FORMAT(Usage, ''N0'') AS Value
    ,2 AS Id
FROM
    Inventory
UNION ALL
SELECT
    ''Waste Costs'' AS Label
    ,FORMAT(Waste, ''N0'') AS Value
    ,3 AS Id
FROM
    Inventory
UNION ALL
SELECT
    ''Variance Costs'' AS Label
    ,FORMAT(NegativeVariance, ''N0'') AS Value
    ,4 AS Id
FROM
    Inventory
) SUB

SELECT
''Margin Analysis'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(
  SELECT
    FORMAT(ROUND(SUM(NET_VALUE),2), ''N0'') AS Sales
    FROM [presentation].[F_LINEITEM_15MIN] F
    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterClause
) AS PiePrimaryText,
''Net Sales'' AS PieSecondaryText',
        ExecutionQuery = NULL,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, QueryTemplate, Status)
    VALUES (N'InvTheoMargin', N'PieChartCard', N'-- placeholder', N'LIVE');
