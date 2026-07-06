-- ============================================================
-- Cost Path Redesign: Task 5
-- Replace InvLocCost/InvCost CTEs in "Inventory Usage by Day"
-- PresentationControl step with InvItemCost reading from
-- SAT_INVITEM.UOM_COST directly.
--
-- Target step : Inventory Usage by Day
-- Target table: F_INV_USAGE_DAY
-- Step GUID   : FBCB305F-A7DB-4AE9-81E2-9D9DC4F22B2F
--
-- Changes vs current query_sql:
--   - REMOVED: DECLARE @InvItemAvgDays INT / SET @InvItemAvgDays = 30
--   - REMOVED: InvLocCost CTE (reads SAT_INVREPORT via rolling average)
--   - REMOVED: InvCost CTE (second-level fallback from InvLocCost)
--   - ADDED  : InvItemCost CTE (reads SAT_INVITEM.UOM_COST directly,
--              converts to standardised UOM via [reference].[UOM_CONVERSION])
--   - REPLACED: two LEFT OUTER JOINs to InvLocCost + InvCost
--               with one LEFT OUTER JOIN to InvItemCost
--   - REPLACED: COALESCE(ILC.UOM_COST, IC.UOM_COST) with IIC.UOM_COST
--
-- v2 fix (2026-03-27): InvItemCost now joins to [reference].[UOM_CONVERSION]
--   instead of inline UOMConversion CTE — the inline CTE only had MarketMan
--   UOM values (EA/gr/Kg) and missed Growyze values (each/g/kg), causing
--   NULL cost for all Growyze inventory items.
-- ============================================================

MERGE INTO [core].[core].[PresentationControl] AS tgt
USING (
    SELECT
        N'FBCB305F-A7DB-4AE9-81E2-9D9DC4F22B2F' AS id,
        N'Inventory Usage by Day'                AS step_name
) AS src
ON tgt.[step_name] = src.[step_name]

WHEN MATCHED THEN UPDATE SET
    tgt.[query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_END'';


WITH UOMConversion AS (
    SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor
    UNION ALL SELECT ''Kg'', ''gr'', 1000
    UNION ALL SELECT ''lb'', ''gr'', 453.59237
    UNION ALL SELECT ''oz'', ''gr'', 28.349523
    UNION ALL SELECT ''ml'', ''ml'', 1
    UNION ALL SELECT ''cl'', ''ml'', 10
    UNION ALL SELECT ''L'', ''ml'', 1000
    UNION ALL SELECT ''Imperial Pint'', ''ml'', 568.26125
    UNION ALL SELECT ''Gal'', ''ml'', 4546.09
    UNION ALL SELECT ''EA'', ''EA'', 1
),
StockEvents AS (
    SELECT
        SE.[HUB_ID]
        ,SE.[SRC]
        ,SE.[LOAD_TS]
        ,SE.[EFFECTIVEFROM]
        ,SE.[EFFECTIVETO]
        ,SE.[CURRENT_FLAG]
        ,SE.[IS_DELETED]
        ,SE.[EVENT_TYPE]
        ,CAST(SE.[EVENT_TS] AS DATE) AS [EVENT_TS]
        ,SE.[PACK_DESC]
        ,SE.[PACK_QUANTITY]
        ,SE.[UOM]
        ,SE.[UOM_QUANITY]
        ,SE.[UOM_QUANITY] * uc.conversion_factor AS [STANDARDISED_QTY]
        ,uc.base_uom AS [STANDARDISED_UOM]
        ,SE.[EXTERNAL_REF]
        ,SE.[INTERNAL_REF]
        ,SE.[EVENT_BEHAVIOUR]
        ,LSE.[LOCATION_HUB_ID]
        ,LII.[INVITEM_HUB_ID]
    FROM
        [datavault].[SAT_STOCKEVENT] SE
    INNER JOIN
        [datavault].[LNK_LOCATION_STOCKEVENT] LSE
        ON SE.[HUB_ID] = LSE.[STOCKEVENT_HUB_ID]
    INNER JOIN
        [datavault].[LNK_INVITEM_STOCKEVENT] LII
        ON SE.[HUB_ID] = LII.[STOCKEVENT_HUB_ID]
    LEFT OUTER JOIN
        UOMConversion uc
        ON SE.[UOM] = uc.[UOM]
    WHERE 1=1
    AND SE.[EVENT_TS] BETWEEN @StartDate AND @EndDate
),

MovementsByGroup AS (
    SELECT
        LOCATION_HUB_ID,
        INVITEM_HUB_ID,
        [STANDARDISED_UOM],
        [EVENT_TS],
        SUM(CASE WHEN EVENT_TYPE = ''WASTE''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS WASTE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''TRANSFER''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS TRANSFER_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''SALE''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS SALE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''PRODUCTION''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS PRODUCTION_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''ORDER''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS ORDER_QTY,
        SUM(
            CASE
                WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                ELSE [STANDARDISED_QTY]
            END
        ) AS MOVEMENT_QTY
    FROM StockEvents
    WHERE EVENT_BEHAVIOUR IN (''+'', ''-'')
    GROUP BY INVITEM_HUB_ID, LOCATION_HUB_ID, [EVENT_TS], [STANDARDISED_UOM]
),

InvItemCost AS (
    SELECT
        II.[HUB_ID] AS INVITEM_HUB_ID,
        II.[UOM_COST] / NULLIF(CAST(UC.[CONVERSION_FACTOR] AS DECIMAL(18,6)), 0) AS UOM_COST
    FROM [datavault].[SAT_INVITEM] II
    LEFT JOIN [core].[reference].[UOM_CONVERSION] UC
        ON II.[UOM] = UC.[FROM_UOM]
    WHERE II.[CURRENT_FLAG] = 1
      AND II.[UOM_COST] IS NOT NULL
      AND II.[BOTTOM_LEVEL] = 1
)


SELECT
    c.[LOCATION_HUB_ID]
    ,c.[INVITEM_HUB_ID]
    ,c.[EVENT_TS] AS COUNT_DATE
    ,c.[STANDARDISED_UOM]
    ,ISNULL(c.MOVEMENT_QTY, 0) AS [THEO_USAGE]
    ,ISNULL(c.ORDER_QTY, 0) AS ORDER_QTY
    ,ISNULL(c.SALE_QTY, 0) AS SALE_QTY
    ,ISNULL(c.PRODUCTION_QTY, 0) AS PRODUCTION_QTY
    ,ISNULL(c.TRANSFER_QTY, 0) AS TRANSFER_QTY
    ,ISNULL(c.WASTE_QTY, 0) AS WASTE_QTY
    ,IIC.UOM_COST AS UOM_COST

FROM MovementsByGroup c

LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]',

    tgt.[updated_at] = GETDATE()

WHEN NOT MATCHED THEN INSERT (
    [id],
    [step_name],
    [table_name],
    [query_sql],
    [tier],
    [table_type],
    [column_mappings],
    [exclude],
    [priority],
    [retry_count],
    [timeout_minutes],
    [description],
    [created_by],
    [created_at],
    [updated_at],
    [time_series_entity],
    [time_series_target_column]
) VALUES (
    N'FBCB305F-A7DB-4AE9-81E2-9D9DC4F22B2F',
    N'Inventory Usage by Day',
    N'F_INV_USAGE_DAY',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_END'';


WITH UOMConversion AS (
    SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor
    UNION ALL SELECT ''Kg'', ''gr'', 1000
    UNION ALL SELECT ''lb'', ''gr'', 453.59237
    UNION ALL SELECT ''oz'', ''gr'', 28.349523
    UNION ALL SELECT ''ml'', ''ml'', 1
    UNION ALL SELECT ''cl'', ''ml'', 10
    UNION ALL SELECT ''L'', ''ml'', 1000
    UNION ALL SELECT ''Imperial Pint'', ''ml'', 568.26125
    UNION ALL SELECT ''Gal'', ''ml'', 4546.09
    UNION ALL SELECT ''EA'', ''EA'', 1
),
StockEvents AS (
    SELECT
        SE.[HUB_ID]
        ,SE.[SRC]
        ,SE.[LOAD_TS]
        ,SE.[EFFECTIVEFROM]
        ,SE.[EFFECTIVETO]
        ,SE.[CURRENT_FLAG]
        ,SE.[IS_DELETED]
        ,SE.[EVENT_TYPE]
        ,CAST(SE.[EVENT_TS] AS DATE) AS [EVENT_TS]
        ,SE.[PACK_DESC]
        ,SE.[PACK_QUANTITY]
        ,SE.[UOM]
        ,SE.[UOM_QUANITY]
        ,SE.[UOM_QUANITY] * uc.conversion_factor AS [STANDARDISED_QTY]
        ,uc.base_uom AS [STANDARDISED_UOM]
        ,SE.[EXTERNAL_REF]
        ,SE.[INTERNAL_REF]
        ,SE.[EVENT_BEHAVIOUR]
        ,LSE.[LOCATION_HUB_ID]
        ,LII.[INVITEM_HUB_ID]
    FROM
        [datavault].[SAT_STOCKEVENT] SE
    INNER JOIN
        [datavault].[LNK_LOCATION_STOCKEVENT] LSE
        ON SE.[HUB_ID] = LSE.[STOCKEVENT_HUB_ID]
    INNER JOIN
        [datavault].[LNK_INVITEM_STOCKEVENT] LII
        ON SE.[HUB_ID] = LII.[STOCKEVENT_HUB_ID]
    LEFT OUTER JOIN
        UOMConversion uc
        ON SE.[UOM] = uc.[UOM]
    WHERE 1=1
    AND SE.[EVENT_TS] BETWEEN @StartDate AND @EndDate
),

MovementsByGroup AS (
    SELECT
        LOCATION_HUB_ID,
        INVITEM_HUB_ID,
        [STANDARDISED_UOM],
        [EVENT_TS],
        SUM(CASE WHEN EVENT_TYPE = ''WASTE''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS WASTE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''TRANSFER''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS TRANSFER_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''SALE''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS SALE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''PRODUCTION''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS PRODUCTION_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''ORDER''
            THEN
                CASE
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY]
                END
            ELSE 0
            END) AS ORDER_QTY,
        SUM(
            CASE
                WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                ELSE [STANDARDISED_QTY]
            END
        ) AS MOVEMENT_QTY
    FROM StockEvents
    WHERE EVENT_BEHAVIOUR IN (''+'', ''-'')
    GROUP BY INVITEM_HUB_ID, LOCATION_HUB_ID, [EVENT_TS], [STANDARDISED_UOM]
),

InvItemCost AS (
    SELECT
        II.[HUB_ID] AS INVITEM_HUB_ID,
        II.[UOM_COST] / NULLIF(CAST(UC.[CONVERSION_FACTOR] AS DECIMAL(18,6)), 0) AS UOM_COST
    FROM [datavault].[SAT_INVITEM] II
    LEFT JOIN [core].[reference].[UOM_CONVERSION] UC
        ON II.[UOM] = UC.[FROM_UOM]
    WHERE II.[CURRENT_FLAG] = 1
      AND II.[UOM_COST] IS NOT NULL
      AND II.[BOTTOM_LEVEL] = 1
)


SELECT
    c.[LOCATION_HUB_ID]
    ,c.[INVITEM_HUB_ID]
    ,c.[EVENT_TS] AS COUNT_DATE
    ,c.[STANDARDISED_UOM]
    ,ISNULL(c.MOVEMENT_QTY, 0) AS [THEO_USAGE]
    ,ISNULL(c.ORDER_QTY, 0) AS ORDER_QTY
    ,ISNULL(c.SALE_QTY, 0) AS SALE_QTY
    ,ISNULL(c.PRODUCTION_QTY, 0) AS PRODUCTION_QTY
    ,ISNULL(c.TRANSFER_QTY, 0) AS TRANSFER_QTY
    ,ISNULL(c.WASTE_QTY, 0) AS WASTE_QTY
    ,IIC.UOM_COST AS UOM_COST

FROM MovementsByGroup c

LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]',
    1,
    N'Fact',
    N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](2)"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
    0,
    100,
    3,
    30,
    N'None',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'STOCKEVENT',
    N'COUNT_DATE'
);
