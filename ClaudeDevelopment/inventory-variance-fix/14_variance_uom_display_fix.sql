-- =============================================================================
-- Fix #1: InvTop20Variance — Convert g→kg, ml→L for Quantity display
-- =============================================================================
-- Problem: The StackedBarChartCard shows raw VARIANCE quantities in base UOM
-- (grams/millilitres), making values like 22,300g appear as "22,300" without
-- context. Users interpret this as 22,300 individual onions rather than 22.3 kg.
--
-- Fix: Divide g/ml quantities by 1000 for display (→ kg/L). Also change the
-- TOP 20 ranking from ABS(VarianceQty) to ABS(VarianceValue) so items are
-- ranked by cost impact (£), which is on a consistent scale across all UOMs.
-- =============================================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvTop20Variance', N'StackedBarChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'WITH Inventory AS
(
SELECT TOP 20
    INVITEM
    ,ROUND(SUM(VarianceValue), 2) AS Variance
    ,ROUND(SUM(VarianceQty), 2) AS VarianceQty
FROM
    (
    SELECT
        SUM(FC.VARIANCE * ISNULL(FC.UOM_COST, 0)) AS VarianceValue
        ,CASE
            WHEN FC.STANDARDISED_UOM IN (''g'',''ml'') THEN SUM(FC.VARIANCE) / 1000.0
            ELSE SUM(FC.VARIANCE)
        END AS VarianceQty
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVITEM
        ,FC.STANDARDISED_UOM
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
    AND COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) IS NOT NULL
    AND FC.VARIANCE IS NOT NULL
    @FilterClause
    GROUP BY
        FC.LOCATION_HUB_ID
        ,FC.INVITEM_HUB_ID
        ,FC.STANDARDISED_UOM
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ) SUB
GROUP BY
    INVITEM
ORDER BY
    ABS(SUM(VarianceValue)) DESC
)

SELECT
    xAxisLabel,
    ROW_NUMBER() OVER(ORDER BY SORT) AS LabelSort,
    [Value],
    ROW_NUMBER() OVER(ORDER BY SORT) AS ValueSort,
    VisId,
    Stack
FROM
    (
    SELECT
        INVITEM AS XAxisLabel,
        Variance AS Value,
        ''Value'' AS VisId,
        ''A'' AS Stack,
        ABS(Variance) AS SORT
    FROM Inventory

    UNION ALL

    SELECT
        INVITEM AS XAxisLabel,
        VarianceQty AS Value,
        ''Quantity'' AS VisId,
        ''B'' AS Stack,
        ABS(Variance) AS SORT
    FROM Inventory
    ) sub

SELECT
    ''Inventory Item'' AS XAxisLabel,
    '''' AS YAxisLabel,
    ''Top 20 Variance Items'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
        ExecutionQuery = NULL,
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, QueryTemplate, Status)
    VALUES (N'InvTop20Variance', N'StackedBarChartCard', N'-- placeholder', N'LIVE');
