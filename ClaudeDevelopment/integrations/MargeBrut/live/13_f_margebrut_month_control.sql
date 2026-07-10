-- ============================================
-- 13_f_margebrut_month_control.sql
-- Registers the PresentationControl build step that populates
-- presentation.F_MARGEBRUT_MONTH (the Marge Brut monthly F&B cost-of-sales
-- fact). Part of the Marge Brut mock -> live build (Task 6).
--
-- Control-table schema verified via read-only MCP against UAT core:
--   core.core.PresentationControl columns (snake_case):
--     id (uniqueidentifier PK, DEFAULT NEWID()), step_name (NOT NULL),
--     table_name, query_sql (text, NOT NULL), tier (int, NOT NULL),
--     table_type (NOT NULL), column_mappings (nvarchar), exclude (bit, def 0),
--     priority (int, def 100), retry_count, timeout_minutes, depends_on_steps,
--     time_series_entity, time_series_target_column, description,
--     created_by, created_at (def GETDATE()), updated_at (def GETDATE()).
--   Natural key: UQ_PresentationControl_StepName UNIQUE (step_name).
--
-- HOW THE ENGINE RUNS THIS (core.sp_ProcessPresentation -> core.sp_ExecuteQuery):
--   query_sql is executed as a single SELECT; the engine builds a temp table
--   from its result set and loads the mapped columns into the target itself
--   (query_sql must NOT contain its own INSERT/TRUNCATE - every existing step
--   is a pure SELECT).
--   Idempotent full rebuild: for table_type='Fact' with a
--   time_series_target_column, the engine computes MIN/MAX of that column over
--   the freshly-built result and DELETEs the target for that range before
--   inserting. This build recomputes ALL months every run (no date window), so
--   MIN/MAX(PERIOD_MONTH) spans the whole history -> the DELETE clears every
--   existing row and the step re-inserts it. This is the same rebuild pattern
--   the other Fact steps use (F_LINEITEM_15MIN on ORDER_DATE,
--   F_INV_COUNTS_DAY on COUNT_DATE), and it keeps the PK
--   (GROUP_NAME, PERIOD_MONTH) collision-free on re-run.
--
-- BUILD ORDER: tier 2. All four sources (D_PRODUCT, D_INVITEM,
--   F_LINEITEM_15MIN, F_INV_COUNTS_DAY) are built in tier 1, so this step runs
--   strictly after them (the engine cursor orders by tier, priority, id).
--
-- MEASURES (see .superpowers/sdd/task-6-report.md for full derivation):
--   Turnover  : F_LINEITEM_15MIN PROD lines, grouped via D_PRODUCT.
--   Stock     : F_INV_COUNTS_DAY, grouped via D_INVITEM.
--   Manual    : reference.MARGEBRUT_MANUAL (REV_PROV/NEW_PROV/STAFF_MEAL/
--               COMP_COST_PCT) LEFT JOINed on (GROUP_NAME, PERIOD_MONTH).
--   COMP      : retail (GROSS) value of PROD lines carrying a real (non-sentinel)
--               DISCOUNT_HUB_ID x COMP_COST_PCT. No comp/discount lines exist in
--               the current feed (all DISCOUNT_HUB_ID are the -999 sentinel), so
--               COMP evaluates to 0 today. See the report's "COMP" concern: this
--               conflates all discounts with comps and awaits a comp-specific
--               signal before it should be trusted non-zero.
--
-- Unqualified two-part table names only (no client DB prefix) - runs against
-- any organisation database. MERGE upsert on step_name so it is re-runnable.
-- ============================================

MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (N'F_MARGEBRUT_MONTH')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN UPDATE SET
    table_name = N'F_MARGEBRUT_MONTH',
    query_sql = N'-- F_MARGEBRUT_MONTH build: monthly F&B cost-of-sales fact per reporting group.
WITH turnover AS (
    -- Mews POS turnover per group per month (PROD lines only).
    SELECT
        d.BOTTOM_MICROSERVICE_NAME AS GROUP_NAME,
        DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1) AS PERIOD_MONTH,
        SUM(f.GROSS_VALUE) AS TURNOVER_INCL,
        SUM(f.NET_VALUE)   AS TURNOVER_EXCL,
        -- Comp signal: retail (GROSS) value of PROD lines with a real discount link.
        -- DISCOUNT_HUB_ID is the -999 sentinel when no discount is linked, so a
        -- non-sentinel value flags a discounted/comped line. All lines are sentinel
        -- in the current feed, so COMP_RETAIL is 0. Treats ANY discount as a comp;
        -- a comp-specific signal is needed to separate true comps from ordinary
        -- discounts when real discount data arrives (see task-6-report.md).
        SUM(CASE WHEN f.DISCOUNT_HUB_ID <> CONVERT(BINARY(32), -999) THEN f.GROSS_VALUE ELSE 0 END) AS COMP_RETAIL
    FROM presentation.F_LINEITEM_15MIN f
    JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = ''PROD''
      AND d.BOTTOM_MICROSERVICE_NAME IS NOT NULL
    GROUP BY d.BOTTOM_MICROSERVICE_NAME, DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1)
),
stock_base AS (
    -- Growyze inventory counts joined to their reporting group.
    SELECT
        d.BOTTOM_MICROSERVICE_NAME AS GROUP_NAME,
        DATEFROMPARTS(YEAR(c.COUNT_DATE), MONTH(c.COUNT_DATE), 1) AS PERIOD_MONTH,
        c.COUNT_DATE, c.ACTUAL_COUNT, c.UOM_COST, c.ORDER_QTY
    FROM presentation.F_INV_COUNTS_DAY c
    JOIN presentation.D_INVITEM d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
    WHERE d.BOTTOM_MICROSERVICE_NAME IS NOT NULL
),
stock_bounds AS (
    -- First/last count date within each group+month (the stocktake boundaries).
    -- OPENING/CLOSING therefore assume a single stocktake per group per month
    -- (true for Marge Brut''s monthly stocktake). See report for the caveat on
    -- scattered daily counts.
    SELECT sb.*,
        MIN(sb.COUNT_DATE) OVER (PARTITION BY sb.GROUP_NAME, sb.PERIOD_MONTH) AS MIN_DT,
        MAX(sb.COUNT_DATE) OVER (PARTITION BY sb.GROUP_NAME, sb.PERIOD_MONTH) AS MAX_DT
    FROM stock_base sb
),
stock AS (
    SELECT
        GROUP_NAME,
        PERIOD_MONTH,
        SUM(ORDER_QTY * UOM_COST) AS PURCHASES,
        SUM(CASE WHEN COUNT_DATE = MIN_DT THEN ACTUAL_COUNT * UOM_COST ELSE 0 END) AS OPENING,
        SUM(CASE WHEN COUNT_DATE = MAX_DT THEN ACTUAL_COUNT * UOM_COST ELSE 0 END) AS CLOSING
    FROM stock_bounds
    GROUP BY GROUP_NAME, PERIOD_MONTH
),
keys AS (
    -- All (group, month) keys present in either turnover or stock.
    SELECT GROUP_NAME, PERIOD_MONTH FROM turnover
    UNION
    SELECT GROUP_NAME, PERIOD_MONTH FROM stock
),
assembled AS (
    SELECT
        k.GROUP_NAME,
        k.PERIOD_MONTH,
        t.TURNOVER_INCL,
        t.TURNOVER_EXCL,
        s.OPENING,
        s.PURCHASES,
        m.REV_PROV,
        m.NEW_PROV,
        CAST(ISNULL(s.OPENING,0) + ISNULL(s.PURCHASES,0) - ISNULL(m.REV_PROV,0) + ISNULL(m.NEW_PROV,0) AS DECIMAL(18,2)) AS ALL_STOCK,
        s.CLOSING,
        m.STAFF_MEAL,
        CAST(ISNULL(t.COMP_RETAIL,0) * ISNULL(m.COMP_COST_PCT,0) AS DECIMAL(18,2)) AS COMP
    FROM keys k
    LEFT JOIN turnover t ON t.GROUP_NAME = k.GROUP_NAME AND t.PERIOD_MONTH = k.PERIOD_MONTH
    LEFT JOIN stock    s ON s.GROUP_NAME = k.GROUP_NAME AND s.PERIOD_MONTH = k.PERIOD_MONTH
    LEFT JOIN reference.MARGEBRUT_MANUAL m ON m.GROUP_NAME = k.GROUP_NAME AND m.PERIOD_MONTH = k.PERIOD_MONTH
)
SELECT
    GROUP_NAME,
    PERIOD_MONTH,
    TURNOVER_INCL,
    TURNOVER_EXCL,
    OPENING,
    PURCHASES,
    REV_PROV,
    NEW_PROV,
    ALL_STOCK,
    CLOSING,
    STAFF_MEAL,
    COMP,
    CAST(ALL_STOCK - ISNULL(CLOSING,0) - ISNULL(STAFF_MEAL,0) - ISNULL(COMP,0) AS DECIMAL(18,2)) AS CONSUMPTION,
    CAST(CASE WHEN TURNOVER_EXCL > 0
              THEN (ALL_STOCK - ISNULL(CLOSING,0) - ISNULL(STAFF_MEAL,0) - ISNULL(COMP,0)) / TURNOVER_EXCL
         END AS DECIMAL(9,4)) AS COST_PCT,
    CAST(CASE WHEN TURNOVER_EXCL > 0
              THEN 1 - ((ALL_STOCK - ISNULL(CLOSING,0) - ISNULL(STAFF_MEAL,0) - ISNULL(COMP,0)) / TURNOVER_EXCL)
         END AS DECIMAL(9,4)) AS GP_PCT
FROM assembled',
    tier = 2,
    table_type = N'Fact',
    column_mappings = N'[{"query_column": "GROUP_NAME", "table_column": "GROUP_NAME", "data_type": "nvarchar(50)", "target_data_type": "[nvarchar](50)"}, {"query_column": "PERIOD_MONTH", "table_column": "PERIOD_MONTH", "data_type": "date", "target_data_type": "[date]"}, {"query_column": "TURNOVER_INCL", "table_column": "TURNOVER_INCL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "TURNOVER_EXCL", "table_column": "TURNOVER_EXCL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "OPENING", "table_column": "OPENING", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "PURCHASES", "table_column": "PURCHASES", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "REV_PROV", "table_column": "REV_PROV", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "NEW_PROV", "table_column": "NEW_PROV", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "ALL_STOCK", "table_column": "ALL_STOCK", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "CLOSING", "table_column": "CLOSING", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "STAFF_MEAL", "table_column": "STAFF_MEAL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "COMP", "table_column": "COMP", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "CONSUMPTION", "table_column": "CONSUMPTION", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "COST_PCT", "table_column": "COST_PCT", "data_type": "decimal(9,4)", "target_data_type": "[decimal](9,4)"}, {"query_column": "GP_PCT", "table_column": "GP_PCT", "data_type": "decimal(9,4)", "target_data_type": "[decimal](9,4)"}]',
    exclude = 0,
    priority = 200,
    retry_count = 3,
    timeout_minutes = 30,
    depends_on_steps = N'Product Dimension, Inv Item Dimension, F_LINEITEM_15MIN, Inventory Counts by Day',
    time_series_entity = N'MARGEBRUT',
    time_series_target_column = N'PERIOD_MONTH',
    description = N'Marge Brut monthly F&B cost-of-sales fact - one row per reporting group per month. Turnover from Mews POS (F_LINEITEM_15MIN PROD lines via D_PRODUCT), stock/purchases from Growyze inventory (F_INV_COUNTS_DAY via D_INVITEM), provisions/staff-meal/comp% from reference.MARGEBRUT_MANUAL. Full rebuild each run (windowed DELETE spans all months).',
    updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     depends_on_steps, time_series_entity, time_series_target_column,
     description, created_by, created_at, updated_at)
VALUES (
    N'F_MARGEBRUT_MONTH',
    N'F_MARGEBRUT_MONTH',
    N'-- F_MARGEBRUT_MONTH build: monthly F&B cost-of-sales fact per reporting group.
WITH turnover AS (
    -- Mews POS turnover per group per month (PROD lines only).
    SELECT
        d.BOTTOM_MICROSERVICE_NAME AS GROUP_NAME,
        DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1) AS PERIOD_MONTH,
        SUM(f.GROSS_VALUE) AS TURNOVER_INCL,
        SUM(f.NET_VALUE)   AS TURNOVER_EXCL,
        -- Comp signal: retail (GROSS) value of PROD lines with a real discount link.
        -- DISCOUNT_HUB_ID is the -999 sentinel when no discount is linked, so a
        -- non-sentinel value flags a discounted/comped line. All lines are sentinel
        -- in the current feed, so COMP_RETAIL is 0. Treats ANY discount as a comp;
        -- a comp-specific signal is needed to separate true comps from ordinary
        -- discounts when real discount data arrives (see task-6-report.md).
        SUM(CASE WHEN f.DISCOUNT_HUB_ID <> CONVERT(BINARY(32), -999) THEN f.GROSS_VALUE ELSE 0 END) AS COMP_RETAIL
    FROM presentation.F_LINEITEM_15MIN f
    JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = ''PROD''
      AND d.BOTTOM_MICROSERVICE_NAME IS NOT NULL
    GROUP BY d.BOTTOM_MICROSERVICE_NAME, DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1)
),
stock_base AS (
    -- Growyze inventory counts joined to their reporting group.
    SELECT
        d.BOTTOM_MICROSERVICE_NAME AS GROUP_NAME,
        DATEFROMPARTS(YEAR(c.COUNT_DATE), MONTH(c.COUNT_DATE), 1) AS PERIOD_MONTH,
        c.COUNT_DATE, c.ACTUAL_COUNT, c.UOM_COST, c.ORDER_QTY
    FROM presentation.F_INV_COUNTS_DAY c
    JOIN presentation.D_INVITEM d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
    WHERE d.BOTTOM_MICROSERVICE_NAME IS NOT NULL
),
stock_bounds AS (
    -- First/last count date within each group+month (the stocktake boundaries).
    -- OPENING/CLOSING therefore assume a single stocktake per group per month
    -- (true for Marge Brut''s monthly stocktake). See report for the caveat on
    -- scattered daily counts.
    SELECT sb.*,
        MIN(sb.COUNT_DATE) OVER (PARTITION BY sb.GROUP_NAME, sb.PERIOD_MONTH) AS MIN_DT,
        MAX(sb.COUNT_DATE) OVER (PARTITION BY sb.GROUP_NAME, sb.PERIOD_MONTH) AS MAX_DT
    FROM stock_base sb
),
stock AS (
    SELECT
        GROUP_NAME,
        PERIOD_MONTH,
        SUM(ORDER_QTY * UOM_COST) AS PURCHASES,
        SUM(CASE WHEN COUNT_DATE = MIN_DT THEN ACTUAL_COUNT * UOM_COST ELSE 0 END) AS OPENING,
        SUM(CASE WHEN COUNT_DATE = MAX_DT THEN ACTUAL_COUNT * UOM_COST ELSE 0 END) AS CLOSING
    FROM stock_bounds
    GROUP BY GROUP_NAME, PERIOD_MONTH
),
keys AS (
    -- All (group, month) keys present in either turnover or stock.
    SELECT GROUP_NAME, PERIOD_MONTH FROM turnover
    UNION
    SELECT GROUP_NAME, PERIOD_MONTH FROM stock
),
assembled AS (
    SELECT
        k.GROUP_NAME,
        k.PERIOD_MONTH,
        t.TURNOVER_INCL,
        t.TURNOVER_EXCL,
        s.OPENING,
        s.PURCHASES,
        m.REV_PROV,
        m.NEW_PROV,
        CAST(ISNULL(s.OPENING,0) + ISNULL(s.PURCHASES,0) - ISNULL(m.REV_PROV,0) + ISNULL(m.NEW_PROV,0) AS DECIMAL(18,2)) AS ALL_STOCK,
        s.CLOSING,
        m.STAFF_MEAL,
        CAST(ISNULL(t.COMP_RETAIL,0) * ISNULL(m.COMP_COST_PCT,0) AS DECIMAL(18,2)) AS COMP
    FROM keys k
    LEFT JOIN turnover t ON t.GROUP_NAME = k.GROUP_NAME AND t.PERIOD_MONTH = k.PERIOD_MONTH
    LEFT JOIN stock    s ON s.GROUP_NAME = k.GROUP_NAME AND s.PERIOD_MONTH = k.PERIOD_MONTH
    LEFT JOIN reference.MARGEBRUT_MANUAL m ON m.GROUP_NAME = k.GROUP_NAME AND m.PERIOD_MONTH = k.PERIOD_MONTH
)
SELECT
    GROUP_NAME,
    PERIOD_MONTH,
    TURNOVER_INCL,
    TURNOVER_EXCL,
    OPENING,
    PURCHASES,
    REV_PROV,
    NEW_PROV,
    ALL_STOCK,
    CLOSING,
    STAFF_MEAL,
    COMP,
    CAST(ALL_STOCK - ISNULL(CLOSING,0) - ISNULL(STAFF_MEAL,0) - ISNULL(COMP,0) AS DECIMAL(18,2)) AS CONSUMPTION,
    CAST(CASE WHEN TURNOVER_EXCL > 0
              THEN (ALL_STOCK - ISNULL(CLOSING,0) - ISNULL(STAFF_MEAL,0) - ISNULL(COMP,0)) / TURNOVER_EXCL
         END AS DECIMAL(9,4)) AS COST_PCT,
    CAST(CASE WHEN TURNOVER_EXCL > 0
              THEN 1 - ((ALL_STOCK - ISNULL(CLOSING,0) - ISNULL(STAFF_MEAL,0) - ISNULL(COMP,0)) / TURNOVER_EXCL)
         END AS DECIMAL(9,4)) AS GP_PCT
FROM assembled',
    2,
    N'Fact',
    N'[{"query_column": "GROUP_NAME", "table_column": "GROUP_NAME", "data_type": "nvarchar(50)", "target_data_type": "[nvarchar](50)"}, {"query_column": "PERIOD_MONTH", "table_column": "PERIOD_MONTH", "data_type": "date", "target_data_type": "[date]"}, {"query_column": "TURNOVER_INCL", "table_column": "TURNOVER_INCL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "TURNOVER_EXCL", "table_column": "TURNOVER_EXCL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "OPENING", "table_column": "OPENING", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "PURCHASES", "table_column": "PURCHASES", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "REV_PROV", "table_column": "REV_PROV", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "NEW_PROV", "table_column": "NEW_PROV", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "ALL_STOCK", "table_column": "ALL_STOCK", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "CLOSING", "table_column": "CLOSING", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "STAFF_MEAL", "table_column": "STAFF_MEAL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "COMP", "table_column": "COMP", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "CONSUMPTION", "table_column": "CONSUMPTION", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "COST_PCT", "table_column": "COST_PCT", "data_type": "decimal(9,4)", "target_data_type": "[decimal](9,4)"}, {"query_column": "GP_PCT", "table_column": "GP_PCT", "data_type": "decimal(9,4)", "target_data_type": "[decimal](9,4)"}]',
    0,
    200,
    3,
    30,
    N'Product Dimension, Inv Item Dimension, F_LINEITEM_15MIN, Inventory Counts by Day',
    N'MARGEBRUT',
    N'PERIOD_MONTH',
    N'Marge Brut monthly F&B cost-of-sales fact - one row per reporting group per month. Turnover from Mews POS (F_LINEITEM_15MIN PROD lines via D_PRODUCT), stock/purchases from Growyze inventory (F_INV_COUNTS_DAY via D_INVITEM), provisions/staff-meal/comp% from reference.MARGEBRUT_MANUAL. Full rebuild each run (windowed DELETE spans all months).',
    N'Claude (ClaudeDevelopment)',
    GETDATE(),
    GETDATE()
);
