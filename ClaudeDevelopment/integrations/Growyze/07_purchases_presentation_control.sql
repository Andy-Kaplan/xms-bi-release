-- F_PURCHASES_DAY PresentationControl Build Step
-- Inserts the build query into core.PresentationControl
-- Prerequisite: 06_purchases_presentation_table.sql deployed
-- Uses MERGE upsert pattern per CLAUDE.md rules

MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'Purchases by Day',
    N'F_PURCHASES_DAY',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_END'';

WITH OrderLines AS (
    SELECT
        LIS.INVITEM_HUB_ID,
        LIS.STOCKORDER_HUB_ID,
        SL.QUANTITY,
        SL.PRICE,
        SL.ESTIMATED_COST,
        SL.CASE_SIZE,
        SL.CASE_PRICE,
        ROW_NUMBER() OVER(PARTITION BY LIS.LNK_ID ORDER BY SL.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_INVITEM_STOCKORDER] LIS
    INNER JOIN [datavault].[SAT_LNK_INVITEM_STOCKORDER] SL
        ON LIS.LNK_ID = SL.LNK_ID
),
Orders AS (
    SELECT
        SO.HUB_ID,
        SO.ORDER_DATE,
        SO.DELIVERY_DATE,
        SO.ORDER_STATUS,
        SO.ORDER_INFO
    FROM [datavault].[SAT_STOCKORDER] SO
    WHERE SO.CURRENT_FLAG = 1
      AND SO.ORDER_DATE BETWEEN @StartDate AND @EndDate
),
OrderSupplier AS (
    SELECT
        DSS.STOCKORDER_HUB_ID,
        DSS.SUPPLIER_HUB_ID
    FROM [datavault].[LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER] DSS
),
OrderLocation AS (
    SELECT
        LSESO.STOCKORDER_HUB_ID,
        LLSE.LOCATION_HUB_ID,
        ROW_NUMBER() OVER(PARTITION BY LSESO.STOCKORDER_HUB_ID
                          ORDER BY LLSE.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_STOCKEVENT_STOCKORDER] LSESO
    INNER JOIN [datavault].[LNK_LOCATION_STOCKEVENT] LLSE
        ON LSESO.STOCKEVENT_HUB_ID = LLSE.STOCKEVENT_HUB_ID
)

SELECT
    OL.INVITEM_HUB_ID,
    ISNULL(OS.SUPPLIER_HUB_ID, CONVERT(BINARY(32), -999)) AS SUPPLIER_HUB_ID,
    ISNULL(OLOC.LOCATION_HUB_ID, CONVERT(BINARY(32), -999)) AS LOCATION_HUB_ID,
    OL.STOCKORDER_HUB_ID,
    O.ORDER_DATE,
    O.DELIVERY_DATE,
    O.ORDER_STATUS,
    OL.PRICE AS UNIT_PRICE,
    OL.ESTIMATED_COST AS UNIT_COST,
    OL.QUANTITY AS ORDER_QTY,
    OL.QUANTITY * OL.PRICE AS LINE_TOTAL,
    OL.CASE_SIZE AS PACK_SIZE,
    OL.CASE_PRICE AS PACK_PRICE,
    O.ORDER_INFO AS ORDER_REFERENCE

FROM OrderLines OL
INNER JOIN Orders O
    ON OL.STOCKORDER_HUB_ID = O.HUB_ID
LEFT JOIN OrderSupplier OS
    ON OL.STOCKORDER_HUB_ID = OS.STOCKORDER_HUB_ID
LEFT JOIN OrderLocation OLOC
    ON OL.STOCKORDER_HUB_ID = OLOC.STOCKORDER_HUB_ID
    AND OLOC.rn = 1

WHERE OL.rn = 1',
    1,
    N'Fact',
    N'[
        {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "SUPPLIER_HUB_ID", "table_column": "SUPPLIER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "STOCKORDER_HUB_ID", "table_column": "STOCKORDER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "datetime2(7)"},
        {"query_column": "DELIVERY_DATE", "table_column": "DELIVERY_DATE", "data_type": "datetime2(7)"},
        {"query_column": "ORDER_STATUS", "table_column": "ORDER_STATUS", "data_type": "nvarchar(255)"},
        {"query_column": "UNIT_PRICE", "table_column": "UNIT_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "UNIT_COST", "table_column": "UNIT_COST", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "decimal(38,6)"},
        {"query_column": "LINE_TOTAL", "table_column": "LINE_TOTAL", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_SIZE", "table_column": "PACK_SIZE", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_PRICE", "table_column": "PACK_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_REFERENCE", "table_column": "ORDER_REFERENCE", "data_type": "nvarchar(255)"}
    ]',
    0,
    100,
    3,
    30,
    N'Purchase order line items. Joins INVITEM_STOCKORDER link satellite (qty, price, cost) with STOCKORDER dates/status, SUPPLIER via ternary link, and LOCATION via delivery event chain. Filtered by STOCKEVENT_START/END date range.',
    N'Claude',
    GETDATE(),
    GETDATE(),
    N'STOCKEVENT',
    N'ORDER_DATE'
)) AS src (step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.step_name = src.step_name AND tgt.table_name = src.table_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = src.query_sql,
        tier = src.tier,
        table_type = src.table_type,
        column_mappings = src.column_mappings,
        exclude = src.exclude,
        priority = src.priority,
        description = src.description,
        time_series_entity = src.time_series_entity,
        time_series_target_column = src.time_series_target_column,
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
    VALUES (src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);
