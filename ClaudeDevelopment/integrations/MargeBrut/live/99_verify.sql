/* ============================================================================
   99_verify.sql
   -----------------------------------------------------------------------------
   Marge Brut go-live verification (Task 10). Read-only (SELECT/WITH only),
   developer-run AFTER the build order in DEPLOY.txt has completed for the target
   org. Unqualified two-part table names only -- run in the org's own database.

   ** REVISED 2026-07-29 to match the deployed design. ** Checks 2, 3 and 4 were
   written against the withdrawn 12_group_mapping.sql / MICROSERVICE_NAME
   grouping and the old F_INV_COUNTS_DAY-derived PURCHASES measure. Run unchanged
   against the current build they produced FALSE FAILs (coverage_guard reported
   88 products and 174 invitems "ungrouped" and grain_sanity recomputed NULL,
   purely because nothing populates MICROSERVICE_NAME any more), and check 1a
   silently validated a hero formula the dashboard no longer uses. All four now
   mirror what 13 and 14 actually do.

   Every check emits a check_name column, its diagnostic value/count columns,
   and a check_result literal:
     PASS / FAIL  - Checks 1a/1b/3 (hard gates; FAIL means don't trust the dashboard)
     PASS / WARN / FAIL - Check 2 (value-based thresholds, see its header)
     PASS / FAIL  - Check 2b (supplier dimension prerequisite)
     PASS / WARN / INFO - Check 4 (period-scope reconciliation, not a gate)

   Sections:
     1a. Reconciliation (fact self-consistency) - the hero KPI ratio recomputed
                               from the raw fact equals the same ratio rebuilt
                               via a per-GROUP_NAME rollup of that SAME raw
                               fact. This only proves F_MARGEBRUT_MONTH's own
                               SUM = sum-of-groups arithmetic is consistent
                               (catches a broken GROUP BY or a typo'd formula
                               in either query) -- it does NOT by itself prove
                               the hero KPI and the live MargeBrutGrid agree,
                               because both sides here are grouped the same
                               way. That's what 1b checks.
     1b. Canonical-group guard (the real hero/grid divergence check) - any
                               F_MARGEBRUT_MONTH row whose GROUP_NAME is
                               outside the 6 values MargeBrutGrid's `canon`
                               CTE recognises (MargeBrutCostRatioKPI sums the
                               whole table with no such filter) must be 0 rows
                               -- otherwise the hero % and the grid's GRAND
                               TOTAL % genuinely diverge on real data.
     2. Coverage guard       - the turnover and stock VALUE that 13's grouping
                               CASE maps to NULL and therefore excludes. Some
                               exclusions are correct and permanent (Tips,
                               Service Charge, Allergies; Growyze 'Other'/
                               'Unknown'), so this is a monetary threshold, not
                               a row count. See its own header.
     2b. Supplier dimension guard - D_SUPPLIER must actually be built, or
                               MargeBrutPurchasesBySupplier renders empty. Known
                               to FAIL on Growyze orgs: SAT_SUPPLIER.BOTTOM_LEVEL
                               is never populated by the Growyze Suppliers
                               staging step, so the dimension's recursive anchor
                               matches nothing.
     3. Grain sanity         - fact TURNOVER_INCL/EXCL vs a fresh recompute
                               straight from F_LINEITEM_15MIN + D_PRODUCT, to
                               catch join fan-out or a stale/failed rebuild.
     4. Purchases reconciliation (WARN/INFO) - the Task 7 measure-mismatch TODO
                               is CLOSED (both sides now read
                               F_PURCHASES_DAY.LINE_TOTAL); what remains is a
                               deliberate PERIOD-SCOPE difference. See its header.

   Run via the PowerShell runner (or SSMS) against the org DB. Executed for real
   against Ibis Gloucester Road (UAT OrgID 21) on 2026-07-29 -- baseline results
   recorded in each check's header.
   ============================================================================ */

SET NOCOUNT ON;

-- Optional period window, applied to Checks 1a and 3 (PERIOD_MONTH / ORDER_DATE
-- -- Check 3 snaps these to full calendar-month boundaries itself, see its
-- own header). NULL/NULL (default) checks the whole history -- the right
-- choice for the first post-go-live run. Narrow to a specific month range
-- for a targeted re-check later.
DECLARE @PeriodStart DATE = NULL;
DECLARE @PeriodEnd   DATE = NULL;  -- inclusive


/* ============================================================================
   CHECK 1a: Reconciliation (fact self-consistency)
   Mirrors MargeBrutCostRatioKPI's hero-ratio formula (14_margebrut_vis_queries.sql
   #2: SUM(CONSUMPTION)/NULLIF(SUM(TURNOVER_EXCL),0)) against a fresh group-by-
   group rebuild of MargeBrutGrid's own by_group/grand_total CTEs -- but both
   sides here are grouped off the SAME raw fact.GROUP_NAME set, so this only
   proves F_MARGEBRUT_MONTH's own SUM = sum-of-groups arithmetic is internally
   consistent (catches a broken GROUP BY or a typo'd formula in either query).
   It is NOT, by itself, proof that the live hero KPI and the live grid agree
   on real data: MargeBrutGrid's `canon` CTE only ever sums 6 named groups,
   while MargeBrutCostRatioKPI sums the whole table unconditionally -- a row
   with a GROUP_NAME outside that set would make this check pass while hero
   and grid still diverge in production. CHECK 1b below is what actually
   guards against that.
   ============================================================================ */
WITH fact AS (
    -- TURNOVER_EXCL_CONS mirrors the coverage-matched denominator every live
    -- ratio uses (2026-07-29): CONSUMPTION is NULL for any month lacking both
    -- stocktake ends, so turnover for those months must be excluded from the
    -- ratio or cost % is understated. Without this the check would "pass"
    -- against a formula the dashboard no longer uses.
    SELECT GROUP_NAME, PERIOD_MONTH, TURNOVER_EXCL, CONSUMPTION,
           CASE WHEN CONSUMPTION IS NOT NULL THEN TURNOVER_EXCL END AS TURNOVER_EXCL_CONS
    FROM presentation.F_MARGEBRUT_MONTH
    WHERE (@PeriodStart IS NULL OR PERIOD_MONTH >= @PeriodStart)
      AND (@PeriodEnd   IS NULL OR PERIOD_MONTH <= @PeriodEnd)
),
hero AS (
    -- Mirrors MargeBrutCostRatioKPI's QueryTemplate.
    SELECT
        SUM(CONSUMPTION)        AS CONSUMPTION,
        SUM(TURNOVER_EXCL_CONS) AS TURNOVER_EXCL,
        SUM(CONSUMPTION) / NULLIF(SUM(TURNOVER_EXCL_CONS), 0) AS HERO_COST_PCT
    FROM fact
),
by_group AS (
    -- Mirrors MargeBrutGrid's by_group CTE (per-GROUP_NAME rollup).
    SELECT GROUP_NAME, SUM(TURNOVER_EXCL_CONS) AS TURNOVER_EXCL, SUM(CONSUMPTION) AS CONSUMPTION
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
    'reconciliation_fact_self_consistency' AS check_name,
    h.HERO_COST_PCT                                                       AS hero_formula_cost_pct,
    CASE WHEN g.TURNOVER_EXCL > 0 THEN g.CONSUMPTION / g.TURNOVER_EXCL END AS grouped_rollup_cost_pct,
    h.CONSUMPTION    AS hero_formula_consumption,
    g.CONSUMPTION    AS grouped_rollup_consumption,
    h.TURNOVER_EXCL  AS hero_formula_turnover_excl,
    g.TURNOVER_EXCL  AS grouped_rollup_turnover_excl,
    CASE
        WHEN ABS(ISNULL(h.CONSUMPTION, 0)   - ISNULL(g.CONSUMPTION, 0))   > 0.01
          OR ABS(ISNULL(h.TURNOVER_EXCL, 0) - ISNULL(g.TURNOVER_EXCL, 0)) > 0.01
        THEN 'FAIL'  -- sum-of-per-group values does not match the whole-table sum -- broken GROUP BY somewhere
        WHEN ABS(
                ISNULL(h.HERO_COST_PCT, 0)
                - ISNULL(CASE WHEN g.TURNOVER_EXCL > 0 THEN g.CONSUMPTION / g.TURNOVER_EXCL END, 0)
             ) > 0.0001
        THEN 'FAIL'  -- totals match but the two % formulas disagree -- check for a NULLIF/rounding drift
        ELSE 'PASS'
    END AS check_result
FROM hero h CROSS JOIN grid_grand_total g;


/* ============================================================================
   CHECK 1b: Canonical-group guard (the real hero/grid divergence check)
   ---------------------------------------------------------------------------
   MargeBrutGrid's `canon` CTE (14_margebrut_vis_queries.sql lines ~81-92)
   only ever sums the 6 named GROUP_NAME values below -- any F_MARGEBRUT_MONTH
   row outside that set is silently absent from the grid's by_group/GRAND
   TOTAL rollup (canon LEFT JOIN base, so an extra base row with no matching
   canon entry never appears). MargeBrutCostRatioKPI's hero ratio (14:208-216)
   has no such filter -- it sums the WHOLE table unconditionally. GROUP_NAME
   is bare NVARCHAR(50) with no CHECK constraint, so a typo'd override value
   in 12_group_mapping.sql, or a future 7th reporting category, would land
   here silently and the hero % and the grid's GRAND TOTAL % would diverge on
   real data with neither query erroring. THIS is the check that actually
   protects hero/grid alignment (1a above cannot detect this case, since it
   groups both sides off the same raw GROUP_NAME set). Must return 0 rows.
   ============================================================================ */
WITH canon AS (
    SELECT GROUP_NAME FROM (VALUES
        (N'Food'), (N'Breakfast'), (N'Wines'), (N'Bottled Beer'), (N'Soft Drinks'), (N'Spirit')
    ) AS g(GROUP_NAME)
),
non_canonical AS (
    SELECT f.GROUP_NAME, f.TURNOVER_EXCL, f.CONSUMPTION
    FROM presentation.F_MARGEBRUT_MONTH f
    WHERE NOT EXISTS (SELECT 1 FROM canon c WHERE c.GROUP_NAME = f.GROUP_NAME)
)
SELECT
    'canonical_group_guard' AS check_name,
    COUNT(*)                    AS non_canonical_row_count,
    COUNT(DISTINCT GROUP_NAME)  AS non_canonical_distinct_groups,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS check_result
FROM non_canonical;

-- Detail: which non-canonical GROUP_NAME values exist, and what they're worth
-- (only meaningful if the summary above is FAIL)
SELECT
    'non_canonical_group' AS offender_type,
    GROUP_NAME,
    COUNT(*)              AS row_count,
    SUM(TURNOVER_EXCL)     AS turnover_excl,
    SUM(CONSUMPTION)       AS consumption
FROM (
    SELECT f.GROUP_NAME, f.TURNOVER_EXCL, f.CONSUMPTION
    FROM presentation.F_MARGEBRUT_MONTH f
    WHERE NOT EXISTS (
        SELECT 1 FROM (VALUES
            (N'Food'), (N'Breakfast'), (N'Wines'), (N'Bottled Beer'), (N'Soft Drinks'), (N'Spirit')
        ) AS c(GROUP_NAME) WHERE c.GROUP_NAME = f.GROUP_NAME
    )
) nc
GROUP BY GROUP_NAME
ORDER BY turnover_excl DESC;


/* ============================================================================
   CHECK 2: Coverage guard  (REWRITTEN 2026-07-29)
   Reports the turnover and stock value that 13's grouping CASE maps to NULL and
   therefore EXCLUDES from F_MARGEBRUT_MONTH. Measures the deployed mechanism --
   D_PRODUCT.TOP_NAME and D_INVITEM.TOP_NAME/MIDDLE_1_NAME -- not the withdrawn
   BOTTOM_MICROSERVICE_NAME one (12_group_mapping.sql is superseded; nothing
   populates that column any more, so the old predicate flagged EVERY row and
   this check always FAILed).

   This is a VALUE check, not a row-count check: some exclusions are correct and
   permanent (Tips, Service Charge, Allergies, Miscellaneous and Unknown are not
   F&B revenue; Growyze TOP_NAME 'Other'/'Unknown' is not F&B stock). A row count
   would therefore never reach zero. What matters is whether anything MATERIAL is
   being dropped, so the thresholds are monetary:
     PASS  excluded turnover and excluded stock are both < 1% of their totals
     WARN  either is 1-5%      -- look at the breakdown before trusting the ratios
     FAIL  either is > 5%      -- the CASE is missing real categories
   Baseline on Ibis Gloucester Road, 2026-07-29: turnover GBP 0.04 excluded of
   GBP 33,144.54 (a single Tips line) and GBP 0.00 of GBP 18,302.55 stock -- i.e.
   the source categories cover this catalogue essentially completely.
   ============================================================================ */
WITH prod AS (
    SELECT
        CASE
            WHEN d.TOP_NAME IN ('Breakfast', 'Heartist Breakfast', 'Hot Drinks') THEN 'Breakfast'
            WHEN d.TOP_NAME IN ('Wine', 'Wines')                                 THEN 'Wines'
            WHEN d.TOP_NAME IN ('Bottled Beer', 'Draught Beer', 'Beer & Cider')   THEN 'Bottled Beer'
            WHEN d.TOP_NAME IN ('Soft Drinks', 'Water')                           THEN 'Soft Drinks'
            WHEN d.TOP_NAME IN ('Spirits', 'Spirit')                              THEN 'Spirit'
            WHEN d.TOP_NAME = 'Food'                                              THEN 'Food'
        END AS GROUP_NAME,
        d.TOP_NAME,
        f.NET_VALUE
    FROM presentation.F_LINEITEM_15MIN f
    JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = 'PROD'
      -- Source filter must mirror 13 (added 2026-07-30). Without it this check
      -- measures every POS feed on the org: on The Oak & Vine, NCRAloha's 'Drinks'
      -- (GBP 448,913.60) counts as "excluded turnover" and the check FAILs on data
      -- the dashboard was never scoped to include.
      AND d.BOTTOM_SRC LIKE 'int[_]mews%'
),
item AS (
    SELECT
        CASE
            WHEN d.TOP_NAME = 'Beverages' AND d.MIDDLE_1_NAME IN ('Soft Drinks', 'Water', 'Juices')                    THEN 'Soft Drinks'
            WHEN d.TOP_NAME = 'Beverages' AND d.MIDDLE_1_NAME IN ('Spirits', 'Spirit')                                 THEN 'Spirit'
            WHEN d.TOP_NAME = 'Beverages' AND d.MIDDLE_1_NAME IN ('Wine', 'Wines')                                     THEN 'Wines'
            WHEN d.TOP_NAME = 'Beverages' AND d.MIDDLE_1_NAME IN ('Bottled Beer', 'Beer & Cider', 'Draught Beer')       THEN 'Bottled Beer'
            WHEN d.TOP_NAME = 'Beverages' AND d.MIDDLE_1_NAME IN ('Hot Drinks', 'Coffee', 'Tea')                        THEN 'Breakfast'
            WHEN d.TOP_NAME = 'Food'      AND d.MIDDLE_1_NAME = 'Breakfast'                                             THEN 'Breakfast'
            WHEN d.TOP_NAME = 'Food'                                                                                    THEN 'Food'
        END AS GROUP_NAME,
        d.TOP_NAME, d.MIDDLE_1_NAME,
        c.ACTUAL_COUNT * c.UOM_COST AS STOCK_VALUE
    FROM presentation.F_INV_COUNTS_DAY c
    JOIN presentation.D_INVITEM d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
    -- Source filter must mirror 13: Growyze stock only, else MarketMan's counts
    -- (all under TOP_NAME 'All INVITEMs', which maps to no group) register as
    -- excluded stock.
    WHERE d.BOTTOM_SRC LIKE 'int[_]growyze%'
),
totals AS (
    SELECT
        (SELECT ISNULL(SUM(NET_VALUE), 0)   FROM prod)                          AS turnover_all,
        (SELECT ISNULL(SUM(NET_VALUE), 0)   FROM prod WHERE GROUP_NAME IS NULL) AS turnover_excluded,
        (SELECT ISNULL(SUM(STOCK_VALUE), 0) FROM item)                          AS stock_all,
        (SELECT ISNULL(SUM(STOCK_VALUE), 0) FROM item WHERE GROUP_NAME IS NULL) AS stock_excluded
)
SELECT
    'coverage_guard' AS check_name,
    CAST(turnover_excluded AS DECIMAL(18,2)) AS turnover_excluded,
    CAST(turnover_all      AS DECIMAL(18,2)) AS turnover_total,
    CAST(100.0 * turnover_excluded / NULLIF(turnover_all, 0) AS DECIMAL(9,3)) AS turnover_excluded_pct,
    CAST(stock_excluded AS DECIMAL(18,2)) AS stock_excluded,
    CAST(stock_all      AS DECIMAL(18,2)) AS stock_total,
    CAST(100.0 * stock_excluded / NULLIF(stock_all, 0) AS DECIMAL(9,3)) AS stock_excluded_pct,
    CASE
        WHEN 100.0 * turnover_excluded / NULLIF(turnover_all, 0) > 5
          OR 100.0 * stock_excluded    / NULLIF(stock_all, 0)    > 5 THEN 'FAIL'
        WHEN 100.0 * turnover_excluded / NULLIF(turnover_all, 0) > 1
          OR 100.0 * stock_excluded    / NULLIF(stock_all, 0)    > 1 THEN 'WARN'
        ELSE 'PASS'
    END AS check_result
FROM totals;

-- Detail: which source categories are being excluded, and what they are worth.
-- Read this on any WARN/FAIL -- and skim it even on PASS, since a category that
-- SHOULD be in scope appearing here at low value is an early warning.
SELECT 'excluded_product_category' AS offender_type,
       ISNULL(d.TOP_NAME, '(no dimension match)') AS category,
       COUNT(*) AS lines_, CAST(SUM(f.NET_VALUE) AS DECIMAL(18,2)) AS turnover_excl
FROM presentation.F_LINEITEM_15MIN f
JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
WHERE f.LI_TYPE = 'PROD'
  AND d.BOTTOM_SRC LIKE 'int[_]mews%'
  AND d.TOP_NAME NOT IN ('Breakfast', 'Heartist Breakfast', 'Hot Drinks', 'Wine', 'Wines',
                         'Bottled Beer', 'Draught Beer', 'Beer & Cider', 'Soft Drinks',
                         'Water', 'Spirits', 'Spirit', 'Food')
GROUP BY d.TOP_NAME
ORDER BY turnover_excl DESC;

SELECT 'excluded_invitem_category' AS offender_type,
       ISNULL(d.TOP_NAME, '(null)') + ' / ' + ISNULL(d.MIDDLE_1_NAME, '(null)') AS category,
       COUNT(*) AS count_rows, CAST(SUM(c.ACTUAL_COUNT * c.UOM_COST) AS DECIMAL(18,2)) AS stock_value
FROM presentation.F_INV_COUNTS_DAY c
JOIN presentation.D_INVITEM d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
WHERE d.BOTTOM_SRC LIKE 'int[_]growyze%'
  AND NOT (
        (d.TOP_NAME = 'Beverages' AND d.MIDDLE_1_NAME IN ('Soft Drinks', 'Water', 'Juices', 'Spirits',
                                                          'Spirit', 'Wine', 'Wines', 'Bottled Beer',
                                                          'Beer & Cider', 'Draught Beer', 'Hot Drinks',
                                                          'Coffee', 'Tea'))
     OR  d.TOP_NAME = 'Food'
      )
GROUP BY d.TOP_NAME, d.MIDDLE_1_NAME
ORDER BY stock_value DESC;

/* ---------------------------------------------------------------------------
   CHECK 2b: Supplier dimension guard  (NEW 2026-07-29)
   MargeBrutPurchasesBySupplier joins presentation.D_SUPPLIER. That dimension is
   built by the "Supplier Dimension" PresentationControl step, whose recursive
   CTE anchors on "WHERE BOTTOM_LEVEL = 1 AND CURRENT_FLAG = 1" against
   datavault.SAT_SUPPLIER -- but the Growyze "Growyze Suppliers" staging step
   does not populate BOTTOM_LEVEL (its four sibling dimension steps -- Inventory
   Items, Location, Occasion, Product -- all do). So SAT_SUPPLIER.BOTTOM_LEVEL is
   NULL, the anchor matches nothing, and D_SUPPLIER ends up holding only the
   CONVERT(BINARY(32), -999) 'Unknown' sentinel. The supplier chart then returns
   no data rows even though the purchases themselves are fine.
   Not a Marge Brut defect -- fix belongs in the Growyze staging step.
   --------------------------------------------------------------------------- */
SELECT
    'supplier_dimension_guard' AS check_name,
    (SELECT COUNT(*) FROM datavault.SAT_SUPPLIER WHERE CURRENT_FLAG = 1)                              AS sat_supplier_current,
    (SELECT COUNT(*) FROM datavault.SAT_SUPPLIER WHERE CURRENT_FLAG = 1 AND BOTTOM_LEVEL = 1)         AS sat_supplier_bottom_level_set,
    (SELECT COUNT(*) FROM presentation.D_SUPPLIER)                                                     AS d_supplier_rows,
    (SELECT COUNT(*) FROM presentation.F_PURCHASES_DAY p
      WHERE NOT EXISTS (SELECT 1 FROM presentation.D_SUPPLIER s WHERE s.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID)) AS purchase_lines_with_no_supplier_match,
    CASE
        WHEN (SELECT COUNT(*) FROM presentation.F_PURCHASES_DAY p
               WHERE NOT EXISTS (SELECT 1 FROM presentation.D_SUPPLIER s WHERE s.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID)) = 0
        THEN 'PASS'
        WHEN (SELECT COUNT(*) FROM datavault.SAT_SUPPLIER WHERE CURRENT_FLAG = 1 AND BOTTOM_LEVEL = 1) = 0
        THEN 'FAIL - SAT_SUPPLIER.BOTTOM_LEVEL never set (Growyze staging gap); D_SUPPLIER cannot build, supplier chart will be empty'
        ELSE 'FAIL - supplier keys in F_PURCHASES_DAY do not match D_SUPPLIER'
    END AS check_result;


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

   PERIOD WINDOW NOTE: F_MARGEBRUT_MONTH.PERIOD_MONTH is always the 1st of
   the month, but F_LINEITEM_15MIN.ORDER_DATE is a real calendar date -- an
   un-normalized mid-month @PeriodStart/@PeriodEnd would apply a different
   effective window to each side (e.g. @PeriodStart = the 15th would still
   include that whole month's PERIOD_MONTH row but would exclude the first
   half of the matching ORDER_DATE rows) and produce a false FAIL. So this
   check snaps both bounds out to full calendar-month boundaries before
   filtering either side -- @PeriodStartMonth/@PeriodEndMonth cover the same
   whole month(s) on both CTEs regardless of the day-of-month passed in.
   NULL/NULL (the default) is unaffected either way.
   ============================================================================ */
DECLARE @PeriodStartMonth DATE = CASE WHEN @PeriodStart IS NULL THEN NULL ELSE DATEFROMPARTS(YEAR(@PeriodStart), MONTH(@PeriodStart), 1) END;
DECLARE @PeriodEndMonth   DATE = CASE WHEN @PeriodEnd   IS NULL THEN NULL ELSE EOMONTH(@PeriodEnd) END;

WITH fact_turnover AS (
    SELECT SUM(TURNOVER_INCL) AS TURNOVER_INCL, SUM(TURNOVER_EXCL) AS TURNOVER_EXCL
    FROM presentation.F_MARGEBRUT_MONTH
    WHERE (@PeriodStartMonth IS NULL OR PERIOD_MONTH >= @PeriodStartMonth)
      AND (@PeriodEndMonth   IS NULL OR PERIOD_MONTH <= @PeriodEndMonth)
),
lineitem_turnover AS (
    SELECT SUM(f.GROSS_VALUE) AS TURNOVER_INCL, SUM(f.NET_VALUE) AS TURNOVER_EXCL
    FROM presentation.F_LINEITEM_15MIN f
    JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = 'PROD'
      -- Must mirror 13's grouping CASE exactly: in-scope iff TOP_NAME maps to a
      -- group. (Was BOTTOM_MICROSERVICE_NAME IS NOT NULL -- the withdrawn
      -- mechanism; nothing populates that column now, so this side summed to
      -- NULL and the check always FAILed.)
      AND d.BOTTOM_SRC LIKE 'int[_]mews%'
      AND d.TOP_NAME IN ('Breakfast', 'Heartist Breakfast', 'Hot Drinks', 'Wine', 'Wines',
                         'Bottled Beer', 'Draught Beer', 'Beer & Cider', 'Soft Drinks',
                         'Water', 'Spirits', 'Spirit', 'Food')
      AND (@PeriodStartMonth IS NULL OR f.ORDER_DATE >= @PeriodStartMonth)
      -- EXCLUSIVE upper bound for the same reason as Check 4: @PeriodEndMonth is
      -- EOMONTH(), i.e. the last day at MIDNIGHT, while ORDER_DATE is datetime2.
      -- Any line item timestamped after 00:00 on the month's last day would be
      -- dropped from this side only, producing a false FAIL.
      AND (@PeriodEndMonth   IS NULL OR f.ORDER_DATE < DATEADD(DAY, 1, @PeriodEndMonth))
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
   CHECK 4: Purchases reconciliation  (REWRITTEN 2026-07-29)
   The Task 7 / DEPLOY.txt "GO-LIVE RECONCILIATION TODO" is CLOSED: 13's
   PURCHASES measure was switched from F_INV_COUNTS_DAY.ORDER_QTY x UOM_COST to
   presentation.F_PURCHASES_DAY.LINE_TOTAL, so MargeBrutPurchasesKPI and
   MargeBrutPurchasesBySupplier now read ONE source and ONE measure. (The old
   ORDER_QTY measure was ~3x low -- GBP 912.29 vs GBP 2,652.84 for June 2026 on
   Gloucester -- because ORDER_QTY summarises only part of the inter-count
   movement and a feed's first count carries an unbounded backlog.)

   They still differ in PERIOD SCOPE by design, and that is what this check
   measures. F_MARGEBRUT_MONTH only holds months that have turnover or a
   stocktake, whereas the supplier chart reads F_PURCHASES_DAY directly and
   includes purchase history predating the POS feed (back to Feb 2025 on
   Gloucester). So with NO period window the supplier side is legitimately the
   LARGER of the two, and only an equal-window comparison should reconcile:
     - @PeriodStart/@PeriodEnd NULL  -> supplier >= KPI is expected; INFO
     - a period window set          -> the two must agree within GBP 1.00, else WARN
   Run this check with an explicit single-month window to actually test it.

   Guarded with OBJECT_ID + dynamic SQL so a missing F_PURCHASES_DAY cannot fail
   the whole batch at compile time and take out every other check. (As of
   2026-07-29 it IS deployed and populated -- registered in both
   PresentationTables and PresentationControl "Purchases by Day", tier 1 -- so
   the earlier "not deployed anywhere" note is stale; the guard stays for orgs
   built from an older baseline.)
   ============================================================================ */
IF OBJECT_ID('presentation.F_PURCHASES_DAY') IS NULL
BEGIN
    SELECT
        'purchases_reconciliation'                                              AS check_name,
        CAST(NULL AS DECIMAL(18,2))                                             AS supplier_chart_total,
        CAST(NULL AS DECIMAL(18,2))                                             AS purchases_kpi_total,
        CAST(NULL AS DECIMAL(18,2))                                             AS delta,
        'INFO - presentation.F_PURCHASES_DAY does not exist on this org (Growyze 06/07 not applied to its baseline)' AS check_result;
END
ELSE
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'
    WITH supplier_total AS (
        SELECT SUM(p.LINE_TOTAL) AS TOTAL
        FROM presentation.F_PURCHASES_DAY p
        JOIN presentation.D_INVITEM inv ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
        -- Must mirror the F&B scope 13 and MargeBrutPurchasesBySupplier use.
        WHERE inv.BOTTOM_SRC LIKE ''int[_]growyze%''
          AND (   (inv.TOP_NAME = ''Beverages'' AND inv.MIDDLE_1_NAME IN (''Soft Drinks'', ''Water'', ''Juices'',
                                                                         ''Spirits'', ''Spirit'', ''Wine'', ''Wines'',
                                                                         ''Bottled Beer'', ''Beer & Cider'', ''Draught Beer'',
                                                                         ''Hot Drinks'', ''Coffee'', ''Tea''))
               OR inv.TOP_NAME = ''Food'' )
          AND p.ORDER_STATUS = ''COMPLETED''
          AND (@PeriodStart IS NULL OR p.ORDER_DATE >= @PeriodStart)
          -- EXCLUSIVE upper bound: ORDER_DATE is datetime2 and DOES carry a time
          -- (Gloucester has 16 lines at 2026-06-30 09:00:00 worth GBP 129.45), so
          -- "<= @PeriodEnd" -- a DATE, i.e. midnight -- silently drops the whole
          -- last day of the window and produced a spurious WARN here.
          AND (@PeriodEnd   IS NULL OR p.ORDER_DATE < DATEADD(DAY, 1, @PeriodEnd))
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
            WHEN @PeriodStart IS NULL AND @PeriodEnd IS NULL AND ISNULL(s.TOTAL, 0) >= ISNULL(k.TOTAL, 0)
                THEN ''INFO - expected with no period window: the supplier chart reads F_PURCHASES_DAY directly (incl. purchase history predating the POS feed) while the KPI reads F_MARGEBRUT_MONTH, which only holds months with turnover or a stocktake. Re-run with a single-month window to reconcile.''
            ELSE ''WARN - same source and measure (F_PURCHASES_DAY.LINE_TOTAL) yet they disagree within an equal window -- check the F&B scope predicate and ORDER_STATUS filter on both sides''
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
