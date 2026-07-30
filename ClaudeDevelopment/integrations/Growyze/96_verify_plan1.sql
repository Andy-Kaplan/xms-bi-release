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
   move revenue, row counts, or the day a row lands on.
   ============================================================================ */

/* -- SECTION A: category fall-through eliminated ------------------------- */
SELECT 'A1_fallthrough' AS check_name,
       COUNT(*) AS gryz_products,
       SUM(CASE WHEN TOP_NAME = BOTTOM_PRODUCT_NAME THEN 1 ELSE 0 END) AS fallthrough,
       COUNT(DISTINCT TOP_NAME) AS distinct_top,
       CASE WHEN SUM(CASE WHEN TOP_NAME = BOTTOM_PRODUCT_NAME THEN 1 ELSE 0 END) = 0
            THEN 'PASS' ELSE 'REVIEW' END AS verdict
FROM [presentation].[D_PRODUCT]
WHERE BOTTOM_LEVEL_NAME = N'Product' AND BOTTOM_SRC = 'int_growyze001';

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

/* Confirm the sentinel category node itself was seeded. */
SELECT 'B2_sentinel_node' AS check_name,
       COUNT(*) AS uncategorised_nodes
FROM [presentation].[D_PRODUCT]
WHERE BOTTOM_SRC = 'int_growyze001' AND BOTTOM_PRODUCT_NAME = N'Uncategorised';

/* -- SECTION C: LINEITEM_TIMESTAMP populated ----------------------------- */
SELECT 'C1_sat_timestamp' AS check_name,
       COUNT(*) AS sat_rows,
       SUM(CASE WHEN LINEITEM_TIMESTAMP IS NOT NULL THEN 1 ELSE 0 END) AS with_ts,
       MIN(LINEITEM_TIMESTAMP) AS min_ts,
       MAX(LINEITEM_TIMESTAMP) AS max_ts,
       CASE WHEN COUNT(*) = 0 THEN 'N/A - no Growyze sales on this org'
            WHEN SUM(CASE WHEN LINEITEM_TIMESTAMP IS NOT NULL THEN 1 ELSE 0 END) = COUNT(*)
            THEN 'PASS' ELSE 'REVIEW' END AS verdict
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

/* Product count must not move - the sentinel re-parents products, never drops
   or duplicates them. Category NODES increase by exactly 1 ('Uncategorised')
   on any org that had blank categories. */
SELECT 'E2_product_counts' AS check_name,
       SUM(CASE WHEN BOTTOM_LEVEL_NAME = N'Product'  THEN 1 ELSE 0 END) AS leaf_products,
       SUM(CASE WHEN BOTTOM_LEVEL_NAME = N'Category' THEN 1 ELSE 0 END) AS category_nodes
FROM [presentation].[D_PRODUCT]
WHERE BOTTOM_SRC = 'int_growyze001';

/* Cost/GP sanity for the two new KPI datasets (mirrors GrowyzeProfitPct).
   Padel measured 80.8% pre-deploy; the OakVine cards it replaces read 1,469%. */
SELECT 'E3_profit_kpis' AS check_name,
       CAST(SUM(F.PROFIT) AS DECIMAL(18,2)) AS profit,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_value,
       CAST(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0) AS DECIMAL(6,1)) AS profit_pct
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE F.NET_VALUE > 0
  AND product.[BOTTOM_SRC] = 'int_growyze001'
  AND location.[BOTTOM_LOCATION_NAME] <> N'Unknown';
