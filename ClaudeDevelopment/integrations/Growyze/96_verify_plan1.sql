/* ============================================================================
   Growyze dashboards Plan 1 - VERIFICATION (read-only)
   Ledger: O5.  Companion to 95_deploy_plan1.ps1.
   Run against the target ORGANISATION database (two-part names throughout).

   Covers Task 1 (category sentinel), Task 6 (LINEITEM_TIMESTAMP), Task 7
   (F_PURCHASES_DAY on Padel), plus regression guards proving neither change
   moved revenue or lost rows.

   Every metric is scoped to BOTTOM_SRC / SRC = 'int_growyze001'. Do NOT drop
   that scoping: Oak & Vine (16) carries 4 integrations and the Ibis orgs carry
   Mews, so an unscoped count silently mixes other systems' data. Measured:
   Oak & Vine's F_PRODUCT_MARGIN_DAY holds GBP 1,420,927.46 of non-Growyze net
   value. See memory feedback_scope_facts_by_source.

   --------------------------------------------------------------------------
   RECORDED BASELINES (UAT, measured 2026-07-30, immediately pre-deploy)

   Section A/B - D_PRODUCT Growyze leaf products:
     org                 products  fallthrough  distinct_TOP_NAME
     Padel (10)              2278          110                 46
     Oak & Vine (16)          122            1                  3
     Dirty Sixth (18)         743           34                 37
     Ibis Heathrow (20)       355            2                  5
     Ibis Gloucester (21)     122            1                  3
   Required after: fallthrough = 0 (or near it) and distinct_TOP_NAME collapses
   to the real category set + 'Uncategorised' (Padel ~5, Dirty ~4). The large
   pre-fix distinct_TOP_NAME counts ARE the defect - product names leaking in
   as categories.

   Section C - LINEITEM_TIMESTAMP (only Padel + Dirty Sixth have Growyze sales;
   the other three take sales from Mews and hold ZERO Growyze line items, so
   Task 6 is a no-op there and C returns 0 rows by design):
     org                 SAT rows  with_ts  F_15MIN rows  distinct buckets
     Padel (10)             31060        0          9796                 0
     Dirty Sixth (18)       59987        0         16278                 0
   Required after: with_ts = SAT rows, distinct buckets >> 1.

   Section D - F_PURCHASES_DAY: MISSING on Padel (10); present on 16, 18, 20, 21.
   Required after: present and populated on Padel.

   Section E - regression guards (must NOT change):
     org               F_15MIN rows   net_sales    distinct_days  range
     Padel (10)                9796  204,866.82              109  2026-01-29..07-30
     Dirty Sixth (18)         16278  466,582.61              108  2026-01-29..07-29
   Task 1 re-parents the hierarchy and Task 6 fills a time column; neither may
   move revenue or the day a row lands on. NOTE row COUNT does legitimately rise
   (Padel 9,796 -> 10,464; Dirty 16,278 -> 17,618): LINEITEM_TIMESTAMP is a
   GROUP BY key in the fact, so days that now carry real timestamps split into
   15-minute buckets instead of collapsing into a single NULL bucket. Revenue is
   conserved to the penny, which is what proves it is a re-grain and not
   duplication - assert on net_sales, never on row count.

   --------------------------------------------------------------------------
   ACHIEVED (UAT, 2026-07-30, deploy log deploy_PLAN1_UAT_20260730_125550.log)

   Task 1  fall-through 110 -> 0 (Padel), 34 -> 0 (Dirty), 2 -> 0 (Heathrow);
           distinct_TOP_NAME 46 -> 5 and 37 -> 4; Uncategorised bucket holds
           exactly 110 / 34 / 2 products, reconciling to the baselines exactly.
           Oak & Vine + Gloucester retain 1 benign name collision (see A1).
   Task 2  GrowyzeProfitPct on Padel = 80.8% (the OakVine card it replaces
           reads 1,469%).
   Task 3  GrowyzeSalesByCategory returns the real category set, no product
           names.
   Task 6  timestamps live, 151 distinct 15-min buckets on Padel (was 0), 114 on
           Dirty Sixth, 0 midnight rows. Coverage limited to the DL window - see
           the Section C note; this is a source constraint, not a defect.
   Task 7  Padel F_PURCHASES_DAY created and populated: 1,800 rows,
           GBP 47,397.03, 2025-09-29 .. 2026-07-29.
   O8 regression - none. Oak & Vine F_PRODUCT_MARGIN_DAY identical
           (96,621 rows / GBP 905,503.8738 / GBP 1,420,927.46) and Gloucester
           stocktakes still GBP 10,175.54 (31 May) and GBP 8,127.01 (30 Jun),
           0 null costs.
   ============================================================================ */

/* -- SECTION A: category fall-through eliminated -------------------------
   A1 is an INDICATOR, NOT a pass/fail gate. `TOP_NAME = BOTTOM_PRODUCT_NAME`
   cannot distinguish a true fall-through from a product whose category is
   genuinely named the same as the product. Oak & Vine (16) and Ibis Gloucester
   (21) each keep exactly 1 such row after the fix - the dish
   'Heartist Breakfast', whose DL_DISHES.category is literally
   'Heartist Breakfast'. That is real source data and correct behaviour.
   A2 is the definitive gate: after the sentinel, no staged Product row may
   carry a NULL PARENT_ID. Measured 0 on all five orgs post-deploy.
   NB [presentation].[D_PRODUCT] holds ONLY leaf 'Product' rows for Growyze -
   there are no 'Category' rows in it - so never write a check that looks for
   BOTTOM_LEVEL_NAME = 'Category'; it is vacuously empty. */
SELECT 'A1_fallthrough_indicator' AS check_name,
       COUNT(*) AS gryz_products,
       SUM(CASE WHEN TOP_NAME = BOTTOM_PRODUCT_NAME THEN 1 ELSE 0 END) AS name_collisions,
       COUNT(DISTINCT TOP_NAME) AS distinct_top
FROM [presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = N'Product' AND BOTTOM_SRC = 'int_growyze001';

/* A2 - definitive: every staged product must have resolved to a parent.
   Only meaningful immediately after a staging run (stage.* is transient). */
IF OBJECT_ID('stage.GRYZ_PRODUCT', 'U') IS NOT NULL
    EXEC sys.sp_executesql N'
SELECT ''A2_staged_orphans'' AS check_name,
       COUNT(*) AS product_rows,
       SUM(CASE WHEN PARENT_ID IS NULL THEN 1 ELSE 0 END) AS orphans,
       CASE WHEN SUM(CASE WHEN PARENT_ID IS NULL THEN 1 ELSE 0 END) = 0
            THEN ''PASS'' ELSE ''FAIL'' END AS verdict
FROM [stage].[GRYZ_PRODUCT] WHERE LEVEL_NAME = N''Product'';';

/* -- SECTION B: the resulting category set ------------------------------- */
/* Expect only real Growyze categories + 'Uncategorised'. Any product name
   appearing here means a product still failed to resolve to a category node. */
SELECT 'B1_category_set' AS check_name,
       TOP_NAME AS category,
       COUNT(*) AS products
FROM [presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = N'Product' AND BOTTOM_SRC = 'int_growyze001'
GROUP BY TOP_NAME
ORDER BY products DESC;

/* B2 - how many products landed in the sentinel bucket. This must equal the
   org's PRE-FIX fall-through count exactly: the sentinel should capture those
   products and nothing else. Verified post-deploy - Padel 110, Dirty Sixth 34,
   Ibis Heathrow 2, matching their baselines to the row.
   (Do NOT count rows named 'Uncategorised' here - the sentinel creates a
   CATEGORY node, and D_PRODUCT contains no category rows.) */
SELECT 'B2_sentinel_bucket' AS check_name,
       COUNT(*) AS products_uncategorised
FROM [presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = N'Product' AND BOTTOM_SRC = 'int_growyze001'
  AND TOP_NAME = N'Uncategorised';

/* -- SECTION C: LINEITEM_TIMESTAMP populated -----------------------------
   *** DO NOT expect with_ts = sat_rows. It never will be. ***
   Growyze's DL tables are a ROLLING RECENT WINDOW - measured 2026-07-30,
   Padel's DL_SALES held 1,177 rows covering only 2026-07-27..07-30 (674 order
   ids), while SAT_LINEITEM had 31,060 rows accumulated since 2026-01-29. Staging
   can only stamp line items whose sales header is still in DL, so historical
   satellite rows are permanently NULL - their source data no longer exists.
   Post-deploy: Padel 1,297/31,060 (4.2%), Dirty Sixth 2,268/59,987 (3.8%),
   with fact coverage spanning exactly the 4 DL days. Coverage grows forward with
   each scheduled load; it does not backfill. Retro-filling history would need
   the fetcher to re-land historical sales - a separate request, and the reason
   any intra-day card must be presented as a recent-window view.
   The real failure signals are with_ts = 0, or C4's all-midnight case. */
SELECT 'C1_sat_timestamp' AS check_name,
       COUNT(*) AS sat_rows,
       SUM(CASE WHEN LINEITEM_TIMESTAMP IS NOT NULL THEN 1 ELSE 0 END) AS with_ts,
       MIN(LINEITEM_TIMESTAMP) AS min_ts,
       MAX(LINEITEM_TIMESTAMP) AS max_ts,
       CASE WHEN COUNT(*) = 0 THEN 'N/A - no Growyze sales on this org'
            WHEN SUM(CASE WHEN LINEITEM_TIMESTAMP IS NOT NULL THEN 1 ELSE 0 END) > 0
            THEN 'PASS - see rolling-window note above'
            ELSE 'FAIL - no timestamps at all' END AS verdict
FROM [datavault].[SAT_LINEITEM]
WHERE CURRENT_FLAG = 1 AND SRC = 'int_growyze001';

SELECT 'C2_fact_buckets' AS check_name,
       COUNT(*) AS f15_rows,
       COUNT(DISTINCT LINEITEM_TIMESTAMP) AS distinct_buckets,
       CASE WHEN COUNT(*) = 0 THEN 'N/A - no Growyze sales on this org'
            WHEN COUNT(DISTINCT LINEITEM_TIMESTAMP) > 1 THEN 'PASS' ELSE 'FAIL' END AS verdict
FROM [presentation].[F_LINEITEM_15MIN]
WHERE SRC = 'int_growyze001';

/* Intra-day shape: a real trading curve, not a midnight spike. The whole point
   of sourcing createdAt instead of sale_from is that sale_from is date-only. */
SELECT 'C3_hour_curve' AS check_name,
       DATEPART(HOUR, LINEITEM_TIMESTAMP) AS trading_hour,
       COUNT(*) AS lines,
       CAST(SUM(NET_VALUE) AS DECIMAL(18,2)) AS net_sales
FROM [presentation].[F_LINEITEM_15MIN]
WHERE SRC = 'int_growyze001' AND LINEITEM_TIMESTAMP IS NOT NULL
GROUP BY DATEPART(HOUR, LINEITEM_TIMESTAMP)
ORDER BY trading_hour;

/* Guard against the failure mode the deviation exists to avoid: if every row
   sits at midnight, the timestamp source has silently reverted to sale_from. */
SELECT 'C4_midnight_guard' AS check_name,
       COUNT(*) AS rows_with_ts,
       SUM(CASE WHEN CAST(LINEITEM_TIMESTAMP AS TIME) = '00:00:00' THEN 1 ELSE 0 END) AS midnight_rows,
       CASE WHEN COUNT(*) = 0 THEN 'N/A - no Growyze sales on this org'
            WHEN SUM(CASE WHEN CAST(LINEITEM_TIMESTAMP AS TIME) = '00:00:00' THEN 1 ELSE 0 END) = COUNT(*)
            THEN 'FAIL - all midnight, timestamp source is date-only'
            ELSE 'PASS' END AS verdict
FROM [presentation].[F_LINEITEM_15MIN]
WHERE SRC = 'int_growyze001' AND LINEITEM_TIMESTAMP IS NOT NULL;

/* -- SECTION D: F_PURCHASES_DAY present and populated -------------------- */
SELECT 'D1_purchases_table' AS check_name,
       COUNT(*) AS table_exists
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = 'presentation' AND t.name = 'F_PURCHASES_DAY';

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id
           WHERE s.name = 'presentation' AND t.name = 'F_PURCHASES_DAY')
    EXEC sys.sp_executesql N'
SELECT ''D2_purchases_rows'' AS check_name,
       COUNT(*) AS rows_,
       MIN(ORDER_DATE) AS min_order_date,
       MAX(ORDER_DATE) AS max_order_date,
       CAST(SUM(LINE_TOTAL) AS DECIMAL(18,2)) AS total_value,
       CASE WHEN COUNT(*) > 0 THEN ''PASS'' ELSE ''REVIEW - table empty'' END AS verdict
FROM [presentation].[F_PURCHASES_DAY];';

/* -- SECTION E: regression guards --------------------------------------- */
/* Compare against the Section-E baseline in the header. Task 1 and Task 6 must
   leave all four of these untouched. Note ORDER_DATE is datetime2 - CAST to
   DATE before counting days, and never bound it with <= a DATE literal. */
SELECT 'E1_sales_unchanged' AS check_name,
       COUNT(*) AS f15_rows,
       CAST(SUM(NET_VALUE) AS DECIMAL(18,2)) AS net_sales,
       COUNT(DISTINCT CAST(ORDER_DATE AS DATE)) AS distinct_days,
       MIN(CAST(ORDER_DATE AS DATE)) AS min_d,
       MAX(CAST(ORDER_DATE AS DATE)) AS max_d
FROM [presentation].[F_LINEITEM_15MIN]
WHERE SRC = 'int_growyze001';

/* Product count must not move - the sentinel re-parents products, it never drops
   or duplicates them. Verified post-deploy: Padel 2,278, Oak & Vine 122, Dirty
   Sixth 743, Ibis Heathrow 355, Ibis Gloucester 122 - all unchanged from
   baseline. distinct_top should COLLAPSE (Padel 46 -> 5, Dirty 37 -> 4) because
   leaked product names stop acting as categories. */
SELECT 'E2_product_counts' AS check_name,
       COUNT(*) AS leaf_products,
       COUNT(DISTINCT TOP_NAME) AS distinct_top
FROM [presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = N'Product' AND BOTTOM_SRC = 'int_growyze001';

/* Cost/GP sanity for the two new KPI datasets. Mirrors GrowyzeProfitPct's
   coverage guard (AND F.AVG_NET_COST IS NOT NULL, added 2026-07-31 so the profit
   numerator and net_value denominator describe the same rows) - numerically a
   no-op here because E3 is hardcoded to int_growyze001, where AVG_NET_COST has
   zero NULLs, unlike Oak & Vine/Ibis where the resolver widened scope to POS
   sources. This check intentionally omits the card's CALENDAR join and
   @FilterClause/date window - it verifies the all-time Growyze figure, not a
   filtered card render. Padel measured 80.8% pre-deploy; the OakVine cards it
   replaces read 1,469%. */
SELECT 'E3_profit_kpis' AS check_name,
       CAST(SUM(F.PROFIT) AS DECIMAL(18,2)) AS profit,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_value,
       CAST(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0) AS DECIMAL(6,1)) AS profit_pct
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE F.NET_VALUE > 0
  AND F.AVG_NET_COST IS NOT NULL
  AND product.[BOTTOM_SRC] = 'int_growyze001'
  AND location.[BOTTOM_LOCATION_NAME] <> N'Unknown';
