/* ============================================================================
   Growyze sales source precedence - VERIFICATION (read-only)
   Ledger: O5.  Spec: docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md
   Run against the target ORGANISATION database (two-part names throughout).

   Rule: every POS integration mapped to the org wins; Growyze is the fallback;
   no match renders empty.

   EXPECTED per org (UAT, 2026-07-30):
     Padel Social (10) ...... int_growyze001 . profit 144,248.29 / 80.8% / 7,489
     Dirty Sixth (18) ....... int_growyze001 . profit 317,414.99 / 78.4% / 12,906
     Oak & Vine (16) ........ int_ncraloha001 + int_mews001 . net 1,420,927.46
                              C1 = 905,503.87 / 1,092,561.20 / 82.9% / 64,724 rows
     Ibis Gloucester (21) ... int_mews001 .... net 33,144.54 . C1 legitimately
                              returns NO ROWS (Mews populates no cost at all,
                              so the AVG_NET_COST guard filters every row -
                              expected, not a failure)
     Ibis Heathrow (20) ..... int_mews001 .... no sales rows at all; every
                              section must return cleanly with no rows
   Padel and Dirty Sixth are the REGRESSION GATE: their figures must not move.
   E1 (no_tier_leak) must report PASS on all five orgs.

   *** COVERAGE GUARD 2026-07-31 (O5 fix round 1) ***
   Section C (C1_margin_kpis) carries `AND F.AVG_NET_COST IS NOT NULL` in its
   WHERE clause, matching the deployed GrowyzeProfit / GrowyzeProfitPct cards
   (see 39_growyze_cost_kpis.sql). SUM(F.PROFIT) silently skips rows with a
   NULL cost while SUM(F.NET_VALUE) would count them regardless - without the
   guard the numerator and denominator describe different populations, giving
   a coverage-mismatched ratio (this verifier would otherwise report 63.7% for
   Oak & Vine where the live card correctly shows 82.9%). No-op on Padel/Dirty
   Sixth (zero NULL costs on Growyze-only orgs).
   ============================================================================ */

/* -- A: what the resolver picks for this org ----------------------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'A1_resolved_source' AS check_name,
       STRING_AGG(SRC, ', ') AS resolved_sources,
       CASE WHEN EXISTS (SELECT 1 FROM org_pos) THEN 'POS tier' ELSE 'Growyze fallback tier' END AS tier
FROM sales_src;

/* -- B: sales the cards will report -------------------------------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'B1_lineitem_sales' AS check_name,
       F.[SRC],
       COUNT(*) AS rows_,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_sales,
       MIN(CAST(F.ORDER_DATE AS DATE)) AS min_d,
       MAX(CAST(F.ORDER_DATE AS DATE)) AS max_d
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
WHERE F.LI_TYPE = 'PROD' AND F.NET_VALUE > 0
GROUP BY F.[SRC];

/* -- C: margin measures (GrowyzeProfit / GrowyzeProfitPct) --------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'C1_margin_kpis' AS check_name,
       CAST(SUM(F.PROFIT) AS DECIMAL(18,2)) AS profit,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_value,
       CAST(SUM(F.PROFIT)*100.0/NULLIF(SUM(F.NET_VALUE),0) AS DECIMAL(6,1)) AS profit_pct,
       COUNT(*) AS rows_
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE F.NET_VALUE > 0
  AND F.AVG_NET_COST IS NOT NULL
  AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown';

/* -- D: category set the pie will show ----------------------------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'D1_category_set' AS check_name,
       COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS category,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_sales
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
WHERE F.LI_TYPE = 'PROD' AND F.NET_VALUE > 0
  AND COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) <> 'Unknown'
  AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown'
GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
ORDER BY net_sales DESC;

/* -- E: negative check - no cross-tier leakage ---------------------------
   On a POS org, zero Growyze rows may reach the result. */
SELECT 'E1_no_tier_leak' AS check_name,
       SUM(CASE WHEN F.[SRC] = 'int_growyze001' THEN 1 ELSE 0 END) AS growyze_rows,
       CASE WHEN EXISTS (SELECT 1 FROM sys.schemas s
                         JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
                         WHERE i.[IntegrationType] = 'POS')
                 AND SUM(CASE WHEN F.[SRC] = 'int_growyze001' THEN 1 ELSE 0 END) > 0
            THEN 'FAIL - Growyze rows on a POS org'
            ELSE 'PASS' END AS verdict
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN (
    SELECT i.[SchemaName] AS SRC
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
    UNION ALL
    SELECT N'int_growyze001'
    WHERE NOT EXISTS (SELECT 1 FROM sys.schemas s2
                      JOIN [core].[core].[Integrations] i2 ON s2.name = i2.[SchemaName]
                      WHERE i2.[IntegrationType] = 'POS')
) ss ON ss.SRC = F.[SRC]
WHERE F.LI_TYPE = 'PROD';
