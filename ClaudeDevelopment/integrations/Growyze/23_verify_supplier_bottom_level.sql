-- ============================================================================
-- Verify the Growyze supplier BOTTOM_LEVEL fix (22_supplier_bottom_level.sql)
-- Ledger: O23  (gates the 9th Marge Brut card, O8)
--
-- Run against EACH Growyze organisation database, AFTER 22 + UploadEntityMappings
-- + sp_DataVaultLoad. Read-only: SELECTs only, safe to run any number of times.
--
-- Unqualified two-part names throughout, so it runs against any org DB.
-- Every check emits a Verdict of PASS or FAIL plus the numbers behind it, so a
-- failure says which link in the chain broke rather than just "still empty".
--
-- Run 22 -> UploadEntityMappings -> sp_DataVaultLoad, THEN this. Running it
-- before the reload is expected to FAIL checks 1-4; that is the pre-state.
-- ============================================================================

SET NOCOUNT ON;

-- ---------------------------------------------------------------------------
-- 1. SAT_SUPPLIER: the fix's direct effect. Every current Growyze supplier row
--    must now carry BOTTOM_LEVEL = 1 (flat dimension -> all rows are bottom).
--    A partial count here means CDC updated some rows and not others -- the
--    known CHECKSUM-stuck failure mode (see 21_invitem_uom_cost_backfill.sql
--    for the precedent and the remedy shape).
-- ---------------------------------------------------------------------------
SELECT
    N'1. SAT_SUPPLIER BOTTOM_LEVEL' AS Check_Name,
    COUNT(*)                                                             AS growyze_current_rows,
    SUM(CASE WHEN BOTTOM_LEVEL = 1 THEN 1 ELSE 0 END)                    AS bottom_level_set,
    SUM(CASE WHEN BOTTOM_LEVEL IS NULL THEN 1 ELSE 0 END)                AS bottom_level_null,
    SUM(CASE WHEN LEVEL_NAME = N'Supplier' THEN 1 ELSE 0 END)            AS level_name_set,
    CASE WHEN COUNT(*) > 0
          AND SUM(CASE WHEN BOTTOM_LEVEL = 1 THEN 1 ELSE 0 END) = COUNT(*)
         THEN N'PASS' ELSE N'FAIL' END                                   AS Verdict
FROM [datavault].[SAT_SUPPLIER]
WHERE CURRENT_FLAG = 1
  AND SRC = N'int_growyze001';

-- ---------------------------------------------------------------------------
-- 2. MICROSERVICE_NAME must remain NULL. Staging hardcodes the literal
--    'growyze'; if it ever reaches the satellite, the supplier card's
--    COALESCE(BOTTOM_MICROSERVICE_NAME, BOTTOM_SUPPLIER_NAME) label collapses
--    every supplier into one bar named "growyze". This check exists so that
--    failure mode can never ship silently -- it looks like a working chart.
-- ---------------------------------------------------------------------------
SELECT
    N'2. MICROSERVICE_NAME stays NULL (MDM)' AS Check_Name,
    COUNT(*)                                                             AS growyze_current_rows,
    SUM(CASE WHEN MICROSERVICE_NAME IS NOT NULL THEN 1 ELSE 0 END)       AS populated_rows,
    CASE WHEN SUM(CASE WHEN MICROSERVICE_NAME IS NOT NULL THEN 1 ELSE 0 END) = 0
         THEN N'PASS' ELSE N'FAIL - would collapse the chart to one bar' END AS Verdict
FROM [datavault].[SAT_SUPPLIER]
WHERE CURRENT_FLAG = 1
  AND SRC = N'int_growyze001';

-- ---------------------------------------------------------------------------
-- 3. D_SUPPLIER: the dimension must now hold the Growyze suppliers. Before the
--    fix this returned 0 (the recursive CTE's WHERE BOTTOM_LEVEL = 1 anchor
--    matched nothing). Counted by BOTTOM_SRC so a co-resident inventory
--    integration's suppliers (MarketMan on The Oak & Vine) can't mask the
--    result -- that masking is exactly what made O23 present differently on
--    the two orgs.
-- ---------------------------------------------------------------------------
SELECT
    N'3. D_SUPPLIER Growyze rows' AS Check_Name,
    SUM(CASE WHEN BOTTOM_SRC = N'int_growyze001' THEN 1 ELSE 0 END)      AS growyze_rows,
    COUNT(*)                                                             AS all_rows_incl_other_sources,
    CASE WHEN SUM(CASE WHEN BOTTOM_SRC = N'int_growyze001' THEN 1 ELSE 0 END) > 0
         THEN N'PASS' ELSE N'FAIL' END                                   AS Verdict
FROM [presentation].[D_SUPPLIER];

-- ---------------------------------------------------------------------------
-- 4. The join that the card actually performs. This is the check that matters:
--    every F_PURCHASES_DAY line must resolve a supplier. Before the fix all
--    2,438 lines failed on The Oak & Vine.
-- ---------------------------------------------------------------------------
SELECT
    N'4. F_PURCHASES_DAY supplier join' AS Check_Name,
    COUNT(*)                                                             AS purchase_lines,
    COUNT(DISTINCT p.SUPPLIER_HUB_ID)                                    AS distinct_supplier_keys,
    SUM(CASE WHEN sup.BOTTOM_HUB_ID IS NULL THEN 1 ELSE 0 END)           AS lines_with_no_supplier_match,
    CAST(SUM(p.LINE_TOTAL) AS DECIMAL(18,2))                             AS total_line_value,
    CASE WHEN COUNT(*) > 0
          AND SUM(CASE WHEN sup.BOTTOM_HUB_ID IS NULL THEN 1 ELSE 0 END) = 0
         THEN N'PASS' ELSE N'FAIL' END                                   AS Verdict
FROM [presentation].[F_PURCHASES_DAY] p
LEFT JOIN [presentation].[D_SUPPLIER] sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID;

-- ---------------------------------------------------------------------------
-- 5. The card's own data query (MargeBrutPurchasesBySupplier), unfiltered, with
--    its inner JOIN and food/beverage scope intact. Reproduces what the
--    dashboard will render, so a PASS here means the card is genuinely fixed
--    rather than merely joinable. Expect one row per supplier with purchases.
-- ---------------------------------------------------------------------------
SELECT
    COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME)     AS BarLabel,
    CAST(SUM(p.LINE_TOTAL) AS DECIMAL(18,2))                             AS BarValue
FROM [presentation].[F_PURCHASES_DAY] p
JOIN [presentation].[D_SUPPLIER] sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID
JOIN [presentation].[D_INVITEM]  inv ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
WHERE inv.BOTTOM_SRC LIKE N'int[_]growyze%'
  AND (   (inv.TOP_NAME = N'Beverages' AND inv.MIDDLE_1_NAME IN (N'Soft Drinks', N'Water', N'Juices', N'Spirits', N'Spirit', N'Wine', N'Wines', N'Bottled Beer', N'Beer & Cider', N'Draught Beer', N'Hot Drinks', N'Coffee', N'Tea'))
       OR inv.TOP_NAME = N'Food' )
GROUP BY COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME)
ORDER BY BarValue DESC;

-- ---------------------------------------------------------------------------
-- 6. Roll-up: one row, PASS only if checks 1-4 all pass.
-- ---------------------------------------------------------------------------
WITH sat AS (
    SELECT COUNT(*) AS rows_current,
           SUM(CASE WHEN BOTTOM_LEVEL = 1 THEN 1 ELSE 0 END) AS bl_set,
           SUM(CASE WHEN MICROSERVICE_NAME IS NOT NULL THEN 1 ELSE 0 END) AS ms_set
    FROM [datavault].[SAT_SUPPLIER]
    WHERE CURRENT_FLAG = 1 AND SRC = N'int_growyze001'
),
dim AS (
    SELECT SUM(CASE WHEN BOTTOM_SRC = N'int_growyze001' THEN 1 ELSE 0 END) AS growyze_rows
    FROM [presentation].[D_SUPPLIER]
),
jn AS (
    SELECT COUNT(*) AS lines,
           SUM(CASE WHEN sup.BOTTOM_HUB_ID IS NULL THEN 1 ELSE 0 END) AS unmatched
    FROM [presentation].[F_PURCHASES_DAY] p
    LEFT JOIN [presentation].[D_SUPPLIER] sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID
)
SELECT
    N'O23 ROLL-UP' AS Check_Name,
    sat.rows_current, sat.bl_set, dim.growyze_rows, jn.lines, jn.unmatched,
    CASE WHEN sat.rows_current > 0
          AND sat.bl_set = sat.rows_current
          AND sat.ms_set = 0
          AND dim.growyze_rows > 0
          AND jn.lines > 0
          AND jn.unmatched = 0
         THEN N'PASS - O23 fixed' ELSE N'FAIL - see checks above' END AS Verdict
FROM sat CROSS JOIN dim CROSS JOIN jn;
