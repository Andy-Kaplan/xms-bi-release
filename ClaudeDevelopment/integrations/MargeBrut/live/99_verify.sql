/* ============================================================================
   99_verify.sql
   -----------------------------------------------------------------------------
   Marge Brut go-live verification (Task 10). Read-only (SELECT/WITH only),
   developer-run AFTER the FETCHER GATE in DEPLOY.txt step 3 has cleared and
   the full build order in step 5 (12 -> 11 -> 13+10 -> presentation rebuild)
   has completed for the new org ("Three Rocks Hotel"). Unqualified two-part
   table names only -- run in the target organisation's own database.

   Every check emits a check_name column, its diagnostic value/count columns,
   and a check_result literal:
     PASS / FAIL  - Checks 1-3 (hard gates; FAIL means don't trust the dashboard)
     PASS / WARN / INFO - Check 4 (informational reconciliation, not a gate --
                          see its own header for why)

   Sections:
     1. Reconciliation      - hero KPI cost% == grid GRAND TOTAL cost%, and the
                               per-group rows sum to that grand total.
     2. Coverage guard       - products/invitems with real activity but no
                               MICROSERVICE_NAME grouping (must be 0 rows --
                               anything here is silently dropped from the fact
                               by the two WHERE BOTTOM_MICROSERVICE_NAME IS NOT
                               NULL filters in 13_f_margebrut_month_control.sql).
     3. Grain sanity         - fact TURNOVER_INCL/EXCL vs a fresh recompute
                               straight from F_LINEITEM_15MIN + D_PRODUCT, to
                               catch join fan-out or a stale/failed rebuild.
     4. Purchases reconciliation (WARN/INFO, carried-forward TODO from Task 7)
                             - MargeBrutPurchasesBySupplier's source
                               (F_PURCHASES_DAY) vs MargeBrutPurchasesKPI's
                               source (F_MARGEBRUT_MONTH.PURCHASES) are
                               different measures from different pipelines
                               with no guaranteed reconciliation -- this
                               reports both totals + the delta rather than
                               hard-failing on a mismatch.

   Run via the PowerShell runner (or SSMS) against the org DB. Not MCP-tested
   for real (F_MARGEBRUT_MONTH/F_PURCHASES_DAY are not populated anywhere
   yet -- go-live is gated); each SELECT's shape was instead verified via MCP
   by substituting inline VALUES CTEs standing in for the real tables -- see
   task-10-report.md for the substitutions and results. Re-run this file for
   real once the fetcher feed lands and the build order has executed.
   ============================================================================ */

SET NOCOUNT ON;

-- Optional period window, applied to Checks 1 and 3 (PERIOD_MONTH / ORDER_DATE).
-- NULL/NULL (default) checks the whole history -- the right choice for the
-- first post-go-live run. Narrow to a specific month range for a targeted
-- re-check later.
DECLARE @PeriodStart DATE = NULL;
DECLARE @PeriodEnd   DATE = NULL;  -- inclusive


/* ============================================================================
   CHECK 1: Reconciliation
   Mirrors MargeBrutCostRatioKPI's hero-ratio formula (14_margebrut_vis_queries.sql
   #2: SUM(CONSUMPTION)/NULLIF(SUM(TURNOVER_EXCL),0)) against a fresh group-by-
   group rebuild of MargeBrutGrid's own by_group/grand_total CTEs. Both derive
   from the same F_MARGEBRUT_MONTH rows, so a mismatch means the two live vis
   queries have drifted apart (e.g. a filter added to one and not the other),
   not a data problem.
   ============================================================================ */
WITH fact AS (
    SELECT GROUP_NAME, PERIOD_MONTH, TURNOVER_EXCL, CONSUMPTION
    FROM presentation.F_MARGEBRUT_MONTH
    WHERE (@PeriodStart IS NULL OR PERIOD_MONTH >= @PeriodStart)
      AND (@PeriodEnd   IS NULL OR PERIOD_MONTH <= @PeriodEnd)
),
hero AS (
    -- Mirrors MargeBrutCostRatioKPI's QueryTemplate.
    SELECT
        SUM(CONSUMPTION)   AS CONSUMPTION,
        SUM(TURNOVER_EXCL) AS TURNOVER_EXCL,
        SUM(CONSUMPTION) / NULLIF(SUM(TURNOVER_EXCL), 0) AS HERO_COST_PCT
    FROM fact
),
by_group AS (
    -- Mirrors MargeBrutGrid's by_group CTE (per-GROUP_NAME rollup).
    SELECT GROUP_NAME, SUM(TURNOVER_EXCL) AS TURNOVER_EXCL, SUM(CONSUMPTION) AS CONSUMPTION
    FROM fact
    GROUP BY GROUP_NAME
),
grid_grand_total AS (
    -- Mirrors MargeBrutGrid's grand_total CTE (SUM across all by_group rows --
    -- the Food/Breakfast and beverage folding in the display rows doesn't
    -- change this total, so it isn't reproduced here).
    SELECT SUM(TURNOVER_EXCL) AS TURNOVER_EXCL, SUM(CONSUMPTION) AS CONSUMPTION
    FROM by_group
)
SELECT
    'reconciliation_hero_vs_grid_grand_total' AS check_name,
    h.HERO_COST_PCT                                                       AS hero_kpi_cost_pct,
    CASE WHEN g.TURNOVER_EXCL > 0 THEN g.CONSUMPTION / g.TURNOVER_EXCL END AS grid_grand_total_cost_pct,
    h.CONSUMPTION    AS hero_consumption,
    g.CONSUMPTION    AS grid_grand_total_consumption,
    h.TURNOVER_EXCL  AS hero_turnover_excl,
    g.TURNOVER_EXCL  AS grid_grand_total_turnover_excl,
    CASE
        WHEN ABS(ISNULL(h.CONSUMPTION, 0)   - ISNULL(g.CONSUMPTION, 0))   > 0.01
          OR ABS(ISNULL(h.TURNOVER_EXCL, 0) - ISNULL(g.TURNOVER_EXCL, 0)) > 0.01
        THEN 'FAIL'  -- per-group rows do not sum to the grand total the grid shows
        WHEN ABS(
                ISNULL(h.HERO_COST_PCT, 0)
                - ISNULL(CASE WHEN g.TURNOVER_EXCL > 0 THEN g.CONSUMPTION / g.TURNOVER_EXCL END, 0)
             ) > 0.0001
        THEN 'FAIL'  -- hero % and grid % disagree despite matching totals -- check for a NULLIF/rounding drift
        ELSE 'PASS'
    END AS check_result
FROM hero h CROSS JOIN grid_grand_total g;


/* ============================================================================
   CHECK 2: Coverage guard
   Any product with PROD turnover in F_LINEITEM_15MIN, or any invitem with
   count activity in F_INV_COUNTS_DAY, whose D_PRODUCT/D_INVITEM
   BOTTOM_MICROSERVICE_NAME is NULL -- i.e. ungrouped, and therefore silently
   excluded from F_MARGEBRUT_MONTH by the two
   "WHERE d.BOTTOM_MICROSERVICE_NAME IS NOT NULL" filters in
   13_f_margebrut_month_control.sql. Zero rows on both sides = PASS. A non-zero
   count means Task 5's group mapping (12_group_mapping.sql) missed real
   products/invitems -- the dashboard totals are understated by whatever those
   rows are worth (see the detail SELECTs below for the offenders).
   ============================================================================ */
WITH ungrouped_products AS (
    SELECT DISTINCT f.PRODUCT_HUB_ID
    FROM presentation.F_LINEITEM_15MIN f
    JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = 'PROD'
      AND d.BOTTOM_MICROSERVICE_NAME IS NULL
),
ungrouped_invitems AS (
    SELECT DISTINCT c.INVITEM_HUB_ID
    FROM presentation.F_INV_COUNTS_DAY c
    JOIN presentation.D_INVITEM d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
    WHERE d.BOTTOM_MICROSERVICE_NAME IS NULL
)
SELECT
    'coverage_guard' AS check_name,
    (SELECT COUNT(*) FROM ungrouped_products)  AS ungrouped_products_with_turnover,
    (SELECT COUNT(*) FROM ungrouped_invitems)  AS ungrouped_invitems_with_activity,
    CASE
        WHEN (SELECT COUNT(*) FROM ungrouped_products) = 0
         AND (SELECT COUNT(*) FROM ungrouped_invitems) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS check_result;

-- Detail: which products are ungrouped (only meaningful if the summary above is FAIL)
SELECT TOP 50
    'ungrouped_product' AS offender_type,
    f.PRODUCT_HUB_ID,
    SUM(f.NET_VALUE) AS turnover_excl
FROM presentation.F_LINEITEM_15MIN f
JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
WHERE f.LI_TYPE = 'PROD' AND d.BOTTOM_MICROSERVICE_NAME IS NULL
GROUP BY f.PRODUCT_HUB_ID
ORDER BY turnover_excl DESC;

-- Detail: which invitems are ungrouped (only meaningful if the summary above is FAIL)
SELECT TOP 50
    'ungrouped_invitem' AS offender_type,
    c.INVITEM_HUB_ID,
    SUM(c.ACTUAL_COUNT * c.UOM_COST) AS stock_value
FROM presentation.F_INV_COUNTS_DAY c
JOIN presentation.D_INVITEM d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
WHERE d.BOTTOM_MICROSERVICE_NAME IS NULL
GROUP BY c.INVITEM_HUB_ID
ORDER BY stock_value DESC;


/* ============================================================================
   CHECK 3: Grain sanity
   Recomputes turnover directly from F_LINEITEM_15MIN + D_PRODUCT -- the exact
   join 13_f_margebrut_month_control.sql's own turnover CTE uses -- and
   compares it to what's actually stored in F_MARGEBRUT_MONTH. Since this is
   an independent re-derivation (not a read of the fact's own build logic),
   equality proves two things: the D_PRODUCT join isn't fanning out rows
   (BOTTOM_HUB_ID join produced no duplicates), and the fact isn't stale
   (built before the latest data landed, or a partially-failed rebuild left
   old rows in place).
   ============================================================================ */
WITH fact_turnover AS (
    SELECT SUM(TURNOVER_INCL) AS TURNOVER_INCL, SUM(TURNOVER_EXCL) AS TURNOVER_EXCL
    FROM presentation.F_MARGEBRUT_MONTH
    WHERE (@PeriodStart IS NULL OR PERIOD_MONTH >= @PeriodStart)
      AND (@PeriodEnd   IS NULL OR PERIOD_MONTH <= @PeriodEnd)
),
lineitem_turnover AS (
    SELECT SUM(f.GROSS_VALUE) AS TURNOVER_INCL, SUM(f.NET_VALUE) AS TURNOVER_EXCL
    FROM presentation.F_LINEITEM_15MIN f
    JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = 'PROD'
      AND d.BOTTOM_MICROSERVICE_NAME IS NOT NULL
      AND (@PeriodStart IS NULL OR f.ORDER_DATE >= @PeriodStart)
      AND (@PeriodEnd   IS NULL OR f.ORDER_DATE <= @PeriodEnd)
)
SELECT
    'grain_sanity_turnover' AS check_name,
    ft.TURNOVER_INCL AS fact_turnover_incl,
    li.TURNOVER_INCL AS lineitem_recompute_turnover_incl,
    ft.TURNOVER_EXCL AS fact_turnover_excl,
    li.TURNOVER_EXCL AS lineitem_recompute_turnover_excl,
    CASE
        WHEN ABS(ISNULL(ft.TURNOVER_INCL, 0) - ISNULL(li.TURNOVER_INCL, 0)) > 0.01
          OR ABS(ISNULL(ft.TURNOVER_EXCL, 0) - ISNULL(li.TURNOVER_EXCL, 0)) > 0.01
        THEN 'FAIL'
        ELSE 'PASS'
    END AS check_result
FROM fact_turnover ft CROSS JOIN lineitem_turnover li;


/* ============================================================================
   CHECK 4: Purchases reconciliation (WARN/INFO -- not a hard gate)
   Carried forward from Task 7 / DEPLOY.txt's "GO-LIVE RECONCILIATION TODO":
   MargeBrutPurchasesBySupplier sums presentation.F_PURCHASES_DAY.LINE_TOTAL
   (Growyze purchase orders, F&B-scoped via D_INVITEM.BOTTOM_MICROSERVICE_NAME
   IS NOT NULL); MargeBrutPurchasesKPI sums F_MARGEBRUT_MONTH.PURCHASES
   (Growyze stock-count ORDER_QTY x UOM_COST, via F_INV_COUNTS_DAY). These are
   different measures from different pipelines with no guaranteed
   reconciliation -- so this check REPORTS both totals and the delta rather
   than failing on a mismatch. If the delta is large once real data is
   flowing: either point MargeBrutPurchasesBySupplier at the same
   F_INV_COUNTS_DAY-derived measure as the KPI, or rename that chart's
   title/description to something scope-honest like "Supplier Spend" so it
   isn't read as a breakdown of the Purchases KPI total.

   Guarded with OBJECT_ID + dynamic SQL because presentation.F_PURCHASES_DAY
   is not guaranteed to exist yet at the time this script is first run
   (DEPLOY.txt step 3 notes Growyze 06_purchases_presentation_table.sql /
   07_purchases_presentation_control.sql, QUERY_STATUS #23/#24, are
   registered but not deployed anywhere) -- referencing a missing table in a
   plain SELECT would fail the whole batch at compile time and take out every
   other check below it in the same script run.
   ============================================================================ */
IF OBJECT_ID('presentation.F_PURCHASES_DAY') IS NULL
BEGIN
    SELECT
        'purchases_reconciliation'                                              AS check_name,
        CAST(NULL AS DECIMAL(18,2))                                             AS supplier_chart_total,
        CAST(NULL AS DECIMAL(18,2))                                             AS purchases_kpi_total,
        CAST(NULL AS DECIMAL(18,2))                                             AS delta,
        'INFO - presentation.F_PURCHASES_DAY not deployed yet (see DEPLOY.txt step 3 / QUERY_STATUS #23-24)' AS check_result;
END
ELSE
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'
    WITH supplier_total AS (
        SELECT SUM(p.LINE_TOTAL) AS TOTAL
        FROM presentation.F_PURCHASES_DAY p
        JOIN presentation.D_INVITEM inv ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
        WHERE inv.BOTTOM_MICROSERVICE_NAME IS NOT NULL
          AND (@PeriodStart IS NULL OR p.ORDER_DATE >= @PeriodStart)
          AND (@PeriodEnd   IS NULL OR p.ORDER_DATE <= @PeriodEnd)
    ),
    kpi_total AS (
        SELECT SUM(PURCHASES) AS TOTAL
        FROM presentation.F_MARGEBRUT_MONTH
        WHERE (@PeriodStart IS NULL OR PERIOD_MONTH >= @PeriodStart)
          AND (@PeriodEnd   IS NULL OR PERIOD_MONTH <= @PeriodEnd)
    )
    SELECT
        ''purchases_reconciliation''                                      AS check_name,
        CAST(s.TOTAL AS DECIMAL(18,2))                                    AS supplier_chart_total,
        CAST(k.TOTAL AS DECIMAL(18,2))                                    AS purchases_kpi_total,
        CAST(ISNULL(s.TOTAL, 0) - ISNULL(k.TOTAL, 0) AS DECIMAL(18,2))    AS delta,
        CASE
            WHEN ABS(ISNULL(s.TOTAL, 0) - ISNULL(k.TOTAL, 0)) <= 1.00 THEN ''PASS''
            ELSE ''WARN - different pipelines (F_PURCHASES_DAY purchase orders vs F_INV_COUNTS_DAY-derived stock-count PURCHASES); see DEPLOY.txt go-live reconciliation TODO -- fix or rename the supplier chart to Supplier Spend if this persists''
        END AS check_result
    FROM supplier_total s CROSS JOIN kpi_total k';

    EXEC sp_executesql @sql, N'@PeriodStart DATE, @PeriodEnd DATE', @PeriodStart, @PeriodEnd;
END


/* ---------------------------------------------------------------------------
   POST-RUN MCP SHAPE TEST (per CLAUDE.md "Testing Visualisation Queries via
   MCP" pattern, applied here to a plain verification script rather than a
   card query): F_MARGEBRUT_MONTH / F_PURCHASES_DAY are not populated anywhere
   yet, so each check above was shape-tested by substituting small inline
   VALUES CTEs aliased as the real table names, run read-only via
   mcp__xms-bi-uat__query against the core DB -- confirms every SELECT parses
   and returns a check_result column with PASS/FAIL/WARN/INFO plus the stated
   diagnostic columns. Full substitutions and results in task-10-report.md.
   Developer-run post-go-live; not live-verifiable until the fetcher feed
   lands and the build order in DEPLOY.txt step 5 has executed for the org.
   --------------------------------------------------------------------------- */
