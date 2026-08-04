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
--   query_sql is executed as a single SELECT; the engine builds ##TempResults
--   from its result set (schema from sys.dm_exec_describe_first_result_set,
--   falling back to column_mappings) and loads the mapped columns into the
--   target itself. query_sql must NOT contain its own INSERT/TRUNCATE.
--   The query is passed straight to sp_executesql (not wrapped in a subquery),
--   so `--` comments inside it are safe.
--   Idempotent full rebuild: for table_type='Fact' with a
--   time_series_target_column, the engine computes MIN/MAX of that column over
--   the freshly-built result and DELETEs the target for that range before
--   inserting. This build recomputes ALL months every run (no date window), so
--   MIN/MAX(PERIOD_MONTH) spans the whole history -> the DELETE clears every
--   existing row and the step re-inserts it, keeping the PK
--   (GROUP_NAME, PERIOD_MONTH) collision-free on re-run.
--   GLOBAL STEP, SAFE ON OTHER ORGS: sp_ExecuteQuery returns early with a
--   PRINT'd warning when the target table does not exist, so organisations
--   that have not had presentation.F_MARGEBRUT_MONTH deployed skip this step
--   cleanly instead of failing. (reference.MARGEBRUT_MANUAL is still created
--   empty on every org by 11 as a second line of defence, for orgs that later
--   receive a full DeployPresentationTables run.)
--
-- BUILD ORDER: tier 2. All four sources (D_PRODUCT, D_INVITEM,
--   F_LINEITEM_15MIN, F_INV_COUNTS_DAY, F_PURCHASES_DAY) are built in tier 1,
--   so this step runs strictly after them (the engine cursor orders by tier,
--   priority, id).
--
-- ============================================
-- GROUPING (revised 2026-07-29 -- supersedes 12_group_mapping.sql)
-- ============================================
-- The original design carried the 6 reporting groups in MICROSERVICE_NAME on
-- SAT_PRODUCT/SAT_INVITEM, written by 12_group_mapping.sql from keyword matches
-- against product/item names. That is withdrawn for two reasons:
--
--   1. MICROSERVICE_NAME is the platform's product/item DISPLAY-NAME resolver --
--      8_VisualisationQueries.sql resolves labels as
--      COALESCE(<dim>.BOTTOM_MICROSERVICE_NAME, <dim>.BOTTOM_PRODUCT_NAME) in 82
--      places. Writing group strings there collapses every product and inventory
--      item label on the org to 6 values, and collides with the MDM/join role the
--      column is being moved toward (ledger O20).
--   2. Keyword matching is unnecessary: BOTH dimensions already carry the source
--      system's own category in their hierarchy. Verified on Ibis Gloucester Road
--      (UAT OrgID 21):
--        D_PRODUCT.TOP_NAME (Mews)      = Breakfast / Hot Drinks / Wine /
--                                         Bottled Beer / Soft Drinks / Spirits /
--                                         Food / Draught Beer, plus non-F&B nodes
--                                         (Tips, Service Charge, Allergies,
--                                         Miscellaneous, Unknown, Beverages).
--        D_INVITEM.TOP_NAME (Growyze)   = Food / Beverages / Other / Unknown,
--          with MIDDLE_1_NAME the subcategory (Breakfast, Others, Grocery,
--          Soft Drinks, Spirits, Wine, Bottled Beer, Water, Beer & Cider,
--          Dairy products, Fruit/Vegetables, Seafood, Meat & Poultry,
--          Confectionery & Snacks, Bakery).
--      Keyword matching also mis-grouped real revenue: portion sub-lines
--      ("125 ml", "50 ml", "Bottle") carry wine/spirit revenue but have no
--      keyword, and brands such as San Miguel, Portobello London Pilsner,
--      Shiraz, Gordons, Kraken, Courvoisier, Chivas Regal and Martell VS matched
--      nothing and fell to the ELSE 'Food' catch-all. Under TOP_NAME they all
--      land correctly.
--
-- So the grouping is now derived INLINE from the dimension hierarchy, and
-- nothing writes to the data vault. Consequences:
--   - grouping is always current (no "re-run 12 before every fact rebuild");
--   - unmapped categories map to NULL and are EXCLUDED rather than swept into
--     'Food' by a catch-all -- misallocation is worse than exclusion for a cost
--     ratio. 99_verify.sql reports the excluded turnover/stock so the exclusion
--     cannot hide.
--
-- ============================================
-- SOURCE SCOPING (added 2026-07-30)
-- ============================================
-- Marge Brut is Mews turnover measured against Growyze stock, so each side is
-- pinned to its own feed via BOTTOM_SRC (D_PRODUCT LIKE 'int_mews%',
-- D_INVITEM LIKE 'int_growyze%'). Without this the category names collide with
-- any other POS/inventory integration on the same organisation: The Oak & Vine
-- (UAT org 16) carries NCRAloha as well as Mews, and NCRAloha's TOP_NAME is also
-- 'Food' with GBP 916,792.80 of turnover against the Mews Food group's GBP
-- 281.62 -- so cost of sales read ~0.5%, i.e. a ~99% gross margin. This is the
-- concrete failure the original design avoided by demanding a dedicated
-- Mews+Growyze-only organisation; scoping by source removes that constraint and
-- makes the build correct on any organisation.
--
-- MEASURES
--   Turnover  : F_LINEITEM_15MIN PROD lines, grouped via D_PRODUCT.TOP_NAME,
--               restricted to the Mews feed.
--   CLOSING   : stock value at the LAST stocktake within the month.
--   OPENING   : the PREVIOUS calendar month's CLOSING. Real stocktakes happen
--               once, at month end (Gloucester: 31 May and 30 June 2026), so the
--               original MIN(COUNT_DATE)-within-month logic made OPENING and
--               CLOSING the SAME count -- they cancelled, and CONSUMPTION
--               silently collapsed to PURCHASES alone. Guarded: if the preceding
--               month has no stocktake, OPENING is NULL and CONSUMPTION/COST_PCT/
--               GP_PCT are NULL rather than wrong. The first month of any feed
--               therefore has no computable consumption, which is correct.
--   PURCHASES : F_PURCHASES_DAY.LINE_TOTAL by ORDER_DATE month
--               (ORDER_STATUS = 'COMPLETED'). NOT
--               F_INV_COUNTS_DAY.ORDER_QTY * UOM_COST, which the original used:
--               on Gloucester June 2026 the two disagree ~3x (£912.29 vs
--               £2,652.84) because ORDER_QTY only summarises part of the movement
--               between counts, and the first count of a feed carries an
--               unbounded backlog (£45,298.86 on 31 May 2026, with
--               DAYS_SINCE_LAST_COUNT NULL). Using F_PURCHASES_DAY also makes
--               MargeBrutPurchasesKPI and MargeBrutPurchasesBySupplier read the
--               same source, closing the reconciliation TODO in DEPLOY.txt.
--   Manual    : reference.MARGEBRUT_MANUAL (REV_PROV/NEW_PROV/STAFF_MEAL/
--               COMP_COST_PCT) LEFT JOINed on (GROUP_NAME, PERIOD_MONTH).
--   COMP      : explicit literal 0 today. Awaits a COMP-SPECIFIC line signal (a
--               comp/void reason code or a dedicated comp flag) - deliberately
--               NOT the generic DISCOUNT_HUB_ID link, which would inflate GP% on
--               the first non-comp discount. COMP_COST_PCT is kept in
--               reference.MARGEBRUT_MANUAL for then.
--
-- Unqualified two-part table names only (no client DB prefix) - runs against
-- any organisation database. MERGE upsert on step_name so it is re-runnable.
-- query_sql and column_mappings are held in variables so the MATCHED and
-- NOT MATCHED arms cannot drift apart.
-- ============================================

DECLARE @QuerySql NVARCHAR(MAX);
DECLARE @ColumnMappings NVARCHAR(MAX);

SET @QuerySql = N'-- F_MARGEBRUT_MONTH build: monthly F&B cost-of-sales fact per reporting group.
WITH grp_product AS (
    -- Mews product -> Marge Brut reporting group, from the product hierarchy''s
    -- top tier (the source system''s own category). NULL = not F&B revenue
    -- (Tips, Service Charge, Allergies, Miscellaneous, Unknown) or a portion
    -- sub-line node with no category of its own; excluded below.
    --
    -- SOURCE FILTER (added 2026-07-30) -- Marge Brut is defined as MEWS turnover
    -- against GROWYZE stock, so both sides must be pinned to their own feed. On an
    -- organisation carrying another POS or inventory integration the category names
    -- COLLIDE: The Oak & Vine (UAT org 16) has NCRAloha alongside Mews and its
    -- D_PRODUCT.TOP_NAME is also ''Food'', worth GBP 916,792.80 against the Mews
    -- Food group''s GBP 281.62 -- unfiltered, cost of sales read about 0.5% (a ~99%
    -- gross margin). MarketMan''s invitems currently all sit under ''All INVITEMs''
    -- so the stock side escaped by luck; one category rename would have broken it
    -- too. LIKE rather than = so a future int_mews002 / int_growyze002 still matches.
    -- This is what lets the dashboard be correct on ANY organisation, and retires
    -- the original design''s "needs a dedicated Mews+Growyze-only org" constraint.
    SELECT
        d.BOTTOM_HUB_ID AS PRODUCT_HUB_ID,
        CASE
            WHEN d.TOP_NAME IN (''Breakfast'', ''Heartist Breakfast'', ''Hot Drinks'') THEN ''Breakfast''
            WHEN d.TOP_NAME IN (''Wine'', ''Wines'')                                   THEN ''Wines''
            WHEN d.TOP_NAME IN (''Bottled Beer'', ''Draught Beer'', ''Beer & Cider'')   THEN ''Bottled Beer''
            WHEN d.TOP_NAME IN (''Soft Drinks'', ''Water'')                             THEN ''Soft Drinks''
            WHEN d.TOP_NAME IN (''Spirits'', ''Spirit'')                                THEN ''Spirit''
            WHEN d.TOP_NAME = ''Food''                                                  THEN ''Food''
        END AS GROUP_NAME
    FROM presentation.D_PRODUCT d
    WHERE d.BOTTOM_SRC LIKE ''int[_]mews%''
),
grp_invitem AS (
    -- Growyze inventory item -> Marge Brut reporting group, from the invitem
    -- hierarchy (TOP_NAME = Food/Beverages, MIDDLE_1_NAME = subcategory).
    -- Non-F&B tops (Other, Unknown) map to NULL and are excluded below.
    -- Source-filtered to the Growyze feed for the same reason as grp_product.
    SELECT
        d.BOTTOM_HUB_ID AS INVITEM_HUB_ID,
        CASE
            WHEN d.TOP_NAME = ''Beverages'' AND d.MIDDLE_1_NAME IN (''Soft Drinks'', ''Water'', ''Juices'')        THEN ''Soft Drinks''
            WHEN d.TOP_NAME = ''Beverages'' AND d.MIDDLE_1_NAME IN (''Spirits'', ''Spirit'')                       THEN ''Spirit''
            WHEN d.TOP_NAME = ''Beverages'' AND d.MIDDLE_1_NAME IN (''Wine'', ''Wines'')                           THEN ''Wines''
            WHEN d.TOP_NAME = ''Beverages'' AND d.MIDDLE_1_NAME IN (''Bottled Beer'', ''Beer & Cider'', ''Draught Beer'') THEN ''Bottled Beer''
            WHEN d.TOP_NAME = ''Beverages'' AND d.MIDDLE_1_NAME IN (''Hot Drinks'', ''Coffee'', ''Tea'')            THEN ''Breakfast''
            WHEN d.TOP_NAME = ''Food''      AND d.MIDDLE_1_NAME = ''Breakfast''                                    THEN ''Breakfast''
            WHEN d.TOP_NAME = ''Food''                                                                             THEN ''Food''
        END AS GROUP_NAME
    FROM presentation.D_INVITEM d
    WHERE d.BOTTOM_SRC LIKE ''int[_]growyze%''
),
turnover AS (
    -- Mews POS turnover per group per month (PROD lines only).
    SELECT
        g.GROUP_NAME,
        DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1) AS PERIOD_MONTH,
        SUM(f.GROSS_VALUE) AS TURNOVER_INCL,
        SUM(f.NET_VALUE)   AS TURNOVER_EXCL
    FROM presentation.F_LINEITEM_15MIN f
    JOIN grp_product g ON g.PRODUCT_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = ''PROD''
      AND g.GROUP_NAME IS NOT NULL
    GROUP BY g.GROUP_NAME, DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1)
),
stocktake AS (
    -- One stock valuation per group per stocktake date.
    SELECT
        g.GROUP_NAME,
        CONVERT(date, c.COUNT_DATE) AS COUNT_DATE,
        SUM(c.ACTUAL_COUNT * c.UOM_COST) AS STOCK_VALUE
    FROM presentation.F_INV_COUNTS_DAY c
    JOIN grp_invitem g ON g.INVITEM_HUB_ID = c.INVITEM_HUB_ID
    WHERE g.GROUP_NAME IS NOT NULL
    GROUP BY g.GROUP_NAME, CONVERT(date, c.COUNT_DATE)
),
ranked_stocktake AS (
    SELECT
        GROUP_NAME,
        DATEFROMPARTS(YEAR(COUNT_DATE), MONTH(COUNT_DATE), 1) AS PERIOD_MONTH,
        COUNT_DATE,
        STOCK_VALUE,
        ROW_NUMBER() OVER (
            PARTITION BY GROUP_NAME, DATEFROMPARTS(YEAR(COUNT_DATE), MONTH(COUNT_DATE), 1)
            ORDER BY COUNT_DATE DESC
        ) AS rn
    FROM stocktake
),
month_close AS (
    -- CLOSING = the last stocktake in the month.
    SELECT GROUP_NAME, PERIOD_MONTH, COUNT_DATE AS CLOSE_DATE, STOCK_VALUE AS CLOSING
    FROM ranked_stocktake
    WHERE rn = 1
),
month_open AS (
    -- OPENING = the PREVIOUS CALENDAR month''s CLOSING. LAG walks the months that
    -- actually have a stocktake, so the result is only accepted when that month
    -- is the immediately preceding calendar month; otherwise OPENING stays NULL
    -- and consumption is not computed for this month.
    SELECT
        GROUP_NAME,
        PERIOD_MONTH,
        CLOSING,
        CASE
            WHEN LAG(PERIOD_MONTH) OVER (PARTITION BY GROUP_NAME ORDER BY PERIOD_MONTH)
                 = DATEADD(MONTH, -1, PERIOD_MONTH)
            THEN LAG(CLOSING) OVER (PARTITION BY GROUP_NAME ORDER BY PERIOD_MONTH)
        END AS OPENING
    FROM month_close
),
purchases AS (
    -- Deliveries/purchases in the month, from the purchases fact (real order
    -- dates), not from the counts fact''s ORDER_QTY summary.
    SELECT
        g.GROUP_NAME,
        DATEFROMPARTS(YEAR(p.ORDER_DATE), MONTH(p.ORDER_DATE), 1) AS PERIOD_MONTH,
        SUM(p.LINE_TOTAL) AS PURCHASES
    FROM presentation.F_PURCHASES_DAY p
    JOIN grp_invitem g ON g.INVITEM_HUB_ID = p.INVITEM_HUB_ID
    WHERE g.GROUP_NAME IS NOT NULL
      AND p.ORDER_STATUS = ''COMPLETED''
    GROUP BY g.GROUP_NAME, DATEFROMPARTS(YEAR(p.ORDER_DATE), MONTH(p.ORDER_DATE), 1)
),
keys AS (
    -- A reportable (group, month) exists when there is turnover or a stocktake.
    -- Purchases DELIBERATELY do not create a key: F_PURCHASES_DAY carries Growyze
    -- order history far older than the POS feed (back to Feb 2025 on Gloucester vs
    -- turnover from May 2026), and because the vis queries treat an empty
    -- @FilterClause as "all periods summed", purchase-only months would inflate the
    -- Purchases KPI against a turnover/consumption base that does not cover them.
    -- Purchases still attach to every month that IS reportable, via the LEFT JOIN
    -- below.
    SELECT GROUP_NAME, PERIOD_MONTH FROM turnover
    UNION
    SELECT GROUP_NAME, PERIOD_MONTH FROM month_open
),
assembled AS (
    SELECT
        k.GROUP_NAME,
        k.PERIOD_MONTH,
        t.TURNOVER_INCL,
        t.TURNOVER_EXCL,
        o.OPENING,
        pu.PURCHASES,
        m.REV_PROV,
        m.NEW_PROV,
        -- NULL-propagating on OPENING: with no valid opening stock there is no
        -- meaningful stock-available figure, so ALL_STOCK must be NULL rather
        -- than silently reading as "opening was zero".
        CASE WHEN o.OPENING IS NOT NULL
             THEN CAST(o.OPENING + ISNULL(pu.PURCHASES,0) - ISNULL(m.REV_PROV,0) + ISNULL(m.NEW_PROV,0) AS DECIMAL(18,2))
        END AS ALL_STOCK,
        o.CLOSING,
        m.STAFF_MEAL,
        -- TODO: COMP awaits a COMP-SPECIFIC line signal (a comp/void reason code or a
        -- dedicated comp flag), NOT a generic DISCOUNT_HUB_ID link. Applying the discount
        -- link would jump COMP to (discounted retail x COMP_COST_PCT) and silently inflate
        -- GP% the instant any non-comp discount (promo/markdown) lands - guaranteed wrong
        -- on the first real discount. An explicit 0 is correct today (no comp lines) and
        -- safe. COMP_COST_PCT stays in reference.MARGEBRUT_MANUAL for when a comp signal exists.
        CAST(0 AS DECIMAL(18,2)) AS COMP
    FROM keys k
    LEFT JOIN turnover   t  ON t.GROUP_NAME  = k.GROUP_NAME AND t.PERIOD_MONTH  = k.PERIOD_MONTH
    LEFT JOIN month_open o  ON o.GROUP_NAME  = k.GROUP_NAME AND o.PERIOD_MONTH  = k.PERIOD_MONTH
    LEFT JOIN purchases  pu ON pu.GROUP_NAME = k.GROUP_NAME AND pu.PERIOD_MONTH = k.PERIOD_MONTH
    LEFT JOIN reference.MARGEBRUT_MANUAL m ON m.GROUP_NAME = k.GROUP_NAME AND m.PERIOD_MONTH = k.PERIOD_MONTH
),
computed AS (
    SELECT
        a.*,
        -- CONSUMPTION needs BOTH ends of the month''s stock movement. Either one
        -- missing (first month of a feed, a skipped stocktake, a month with no
        -- stocktake yet) leaves it NULL -- the card shows "n/a" instead of a
        -- number that reads as real.
        CASE WHEN a.ALL_STOCK IS NOT NULL AND a.CLOSING IS NOT NULL
             THEN CAST(a.ALL_STOCK - a.CLOSING - ISNULL(a.STAFF_MEAL,0) - ISNULL(a.COMP,0) AS DECIMAL(18,2))
        END AS CONSUMPTION
    FROM assembled a
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
    CONSUMPTION,
    CAST(CASE WHEN TURNOVER_EXCL > 0 AND CONSUMPTION IS NOT NULL
              THEN CONSUMPTION / TURNOVER_EXCL
         END AS DECIMAL(9,4)) AS COST_PCT,
    CAST(CASE WHEN TURNOVER_EXCL > 0 AND CONSUMPTION IS NOT NULL
              THEN 1 - (CONSUMPTION / TURNOVER_EXCL)
         END AS DECIMAL(9,4)) AS GP_PCT
FROM computed';

SET @ColumnMappings = N'[{"query_column": "GROUP_NAME", "table_column": "GROUP_NAME", "data_type": "nvarchar(50)", "target_data_type": "[nvarchar](50)"}, {"query_column": "PERIOD_MONTH", "table_column": "PERIOD_MONTH", "data_type": "date", "target_data_type": "[date]"}, {"query_column": "TURNOVER_INCL", "table_column": "TURNOVER_INCL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "TURNOVER_EXCL", "table_column": "TURNOVER_EXCL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "OPENING", "table_column": "OPENING", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "PURCHASES", "table_column": "PURCHASES", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "REV_PROV", "table_column": "REV_PROV", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "NEW_PROV", "table_column": "NEW_PROV", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "ALL_STOCK", "table_column": "ALL_STOCK", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "CLOSING", "table_column": "CLOSING", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "STAFF_MEAL", "table_column": "STAFF_MEAL", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "COMP", "table_column": "COMP", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "CONSUMPTION", "table_column": "CONSUMPTION", "data_type": "decimal(18,2)", "target_data_type": "[decimal](18,2)"}, {"query_column": "COST_PCT", "table_column": "COST_PCT", "data_type": "decimal(9,4)", "target_data_type": "[decimal](9,4)"}, {"query_column": "GP_PCT", "table_column": "GP_PCT", "data_type": "decimal(9,4)", "target_data_type": "[decimal](9,4)"}]';

MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (N'F_MARGEBRUT_MONTH')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN UPDATE SET
    table_name = N'F_MARGEBRUT_MONTH',
    query_sql = @QuerySql,
    tier = 2,
    table_type = N'Fact',
    column_mappings = @ColumnMappings,
    exclude = 0,
    priority = 200,
    retry_count = 3,
    timeout_minutes = 30,
    depends_on_steps = N'Product Dimension, Inv Item Dimension, F_LINEITEM_15MIN, Inventory Counts by Day, Purchases by Day',
    time_series_entity = N'MARGEBRUT',
    time_series_target_column = N'PERIOD_MONTH',
    description = N'Marge Brut monthly F&B cost-of-sales fact - one row per reporting group per month. Turnover from Mews POS (F_LINEITEM_15MIN PROD lines grouped by D_PRODUCT.TOP_NAME), opening/closing stock from Growyze stocktakes (F_INV_COUNTS_DAY via D_INVITEM.TOP_NAME/MIDDLE_1_NAME, opening = previous calendar month closing), purchases from F_PURCHASES_DAY, provisions/staff-meal/comp% from reference.MARGEBRUT_MANUAL. Consumption and the ratios are NULL when the month lacks both stocktake ends. Full rebuild each run (windowed DELETE spans all months).',
    updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     depends_on_steps, time_series_entity, time_series_target_column,
     description, created_by, created_at, updated_at)
VALUES (
    N'F_MARGEBRUT_MONTH',
    N'F_MARGEBRUT_MONTH',
    @QuerySql,
    2,
    N'Fact',
    @ColumnMappings,
    0,
    200,
    3,
    30,
    N'Product Dimension, Inv Item Dimension, F_LINEITEM_15MIN, Inventory Counts by Day, Purchases by Day',
    N'MARGEBRUT',
    N'PERIOD_MONTH',
    N'Marge Brut monthly F&B cost-of-sales fact - one row per reporting group per month. Turnover from Mews POS (F_LINEITEM_15MIN PROD lines grouped by D_PRODUCT.TOP_NAME), opening/closing stock from Growyze stocktakes (F_INV_COUNTS_DAY via D_INVITEM.TOP_NAME/MIDDLE_1_NAME, opening = previous calendar month closing), purchases from F_PURCHASES_DAY, provisions/staff-meal/comp% from reference.MARGEBRUT_MANUAL. Consumption and the ratios are NULL when the month lacks both stocktake ends. Full rebuild each run (windowed DELETE spans all months).',
    N'Claude (ClaudeDevelopment)',
    GETDATE(),
    GETDATE()
);
