-- ============================================================
-- Script: 04_presentation_counts_cost.sql
-- Purpose: Replace InvLocCost/InvCost CTEs in "Inventory Counts by Day"
--          PresentationControl step with a new InvItemCost CTE that
--          reads UOM_COST directly from SAT_INVITEM (CURRENT_FLAG=1,
--          BOTTOM_LEVEL=1) instead of averaging from SAT_INVREPORT.
--          Also removes the no-longer-needed @InvItemAvgDays variable.
-- Target:  core.core.PresentationControl
-- Key:     step_name = N'Inventory Counts by Day'
--
-- v2 fix (2026-03-27): InvItemCost now joins to [reference].[UOM_CONVERSION]
--   instead of inline UOMConversion CTE — the inline CTE only had MarketMan
--   UOM values (EA/gr/Kg) and missed Growyze values (each/g/kg), causing
--   NULL cost for all Growyze inventory items.
-- ============================================================

MERGE INTO [core].[core].[PresentationControl] AS tgt
USING (
    SELECT
        N'Inventory Counts by Day' AS step_name,
        N'F_INV_COUNTS_DAY'        AS table_name,
        1                          AS tier,
        N'Fact'                    AS table_type,
        0                          AS exclude,
        100                        AS priority,
        3                          AS retry_count,
        30                         AS timeout_minutes,
        N'None'                    AS description,
        N'STOCKEVENT'              AS time_series_entity,
        N'COUNT_DATE'              AS time_series_target_column,
        N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](2)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_QTY", "table_column": "THEO_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}]'
                                   AS column_mappings,
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

EventsWithCountGroup AS (
    SELECT
        *,
        SUM(CASE WHEN EVENT_BEHAVIOUR = ''COUNT'' THEN 1 ELSE 0 END)
            OVER (
                PARTITION BY INTERNAL_REF, LOCATION_HUB_ID
                ORDER BY EVENT_TS DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS count_group
    FROM StockEvents
),

MovementsByGroup AS (
    SELECT
        LOCATION_HUB_ID,
        INVITEM_HUB_ID,
        [STANDARDISED_UOM],
        count_group,
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
    FROM EventsWithCountGroup
    WHERE EVENT_BEHAVIOUR IN (''+'', ''-'')
    GROUP BY INVITEM_HUB_ID, LOCATION_HUB_ID, count_group, [STANDARDISED_UOM]
),
CountsWithPrevious AS (
    SELECT
        *,
        LAG(STANDARDISED_QTY) OVER (
            PARTITION BY INTERNAL_REF, LOCATION_HUB_ID
            ORDER BY EVENT_TS
        ) AS prev_count_qty,
        LAG(EVENT_TS) OVER (
            PARTITION BY INTERNAL_REF, LOCATION_HUB_ID
            ORDER BY EVENT_TS
        ) AS last_count
    FROM EventsWithCountGroup
    WHERE EVENT_BEHAVIOUR = ''COUNT''
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
    ,c.prev_count_qty AS [PREVIOUS_COUNT]
    ,c.[STANDARDISED_QTY] AS [ACTUAL_COUNT]
    ,c.prev_count_qty + ISNULL(m.MOVEMENT_QTY, 0) AS [THEO_QTY]
    ,ISNULL(m.MOVEMENT_QTY, 0) AS [THEO_USAGE]
    ,c.[STANDARDISED_QTY] - c.prev_count_qty AS [ACTUAL_USAGE]
    ,c.[STANDARDISED_QTY] - (c.prev_count_qty + ISNULL(m.MOVEMENT_QTY, 0)) AS [VARIANCE]
    ,m.ORDER_QTY
    ,m.SALE_QTY
    ,m.PRODUCTION_QTY
    ,m.TRANSFER_QTY
    ,m.WASTE_QTY
    ,m.MOVEMENT_QTY
    ,IIC.UOM_COST AS UOM_COST
    ,DATEDIFF(DAY, c.last_count, [EVENT_TS]) AS DAYS_SINCE_LAST_COUNT

FROM CountsWithPrevious c

LEFT JOIN MovementsByGroup m
    ON c.[INVITEM_HUB_ID] = m.[INVITEM_HUB_ID]
    AND c.LOCATION_HUB_ID = m.LOCATION_HUB_ID
    AND c.count_group = m.count_group

LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]'
                                   AS query_sql
) AS src
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        tgt.[table_name]                  = src.[table_name],
        tgt.[query_sql]                   = src.[query_sql],
        tgt.[tier]                        = src.[tier],
        tgt.[table_type]                  = src.[table_type],
        tgt.[column_mappings]             = src.[column_mappings],
        tgt.[exclude]                     = src.[exclude],
        tgt.[priority]                    = src.[priority],
        tgt.[retry_count]                 = src.[retry_count],
        tgt.[timeout_minutes]             = src.[timeout_minutes],
        tgt.[description]                 = src.[description],
        tgt.[time_series_entity]          = src.[time_series_entity],
        tgt.[time_series_target_column]   = src.[time_series_target_column],
        tgt.[updated_at]                  = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (
        step_name, table_name, query_sql, tier, table_type,
        column_mappings, exclude, priority, retry_count, timeout_minutes,
        description, time_series_entity, time_series_target_column,
        created_by, created_at, updated_at
    )
    VALUES (
        src.[step_name], src.[table_name], src.[query_sql], src.[tier], src.[table_type],
        src.[column_mappings], src.[exclude], src.[priority], src.[retry_count], src.[timeout_minutes],
        src.[description], src.[time_series_entity], src.[time_series_target_column],
        N'PresentationControlApp', GETDATE(), GETDATE()
    );
