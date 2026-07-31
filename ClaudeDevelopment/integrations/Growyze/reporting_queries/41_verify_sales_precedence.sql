/* ============================================================================
   Growyze sales source precedence - VERIFICATION (read-only)
   Ledger: O5.  Spec: docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md
   Run against the target ORGANISATION database (two-part names throughout).

   Rule: every POS integration mapped to the org wins; Growyze is the fallback;
   no match renders empty.

   EXPECTED per org (UAT, verified 2026-07-30/31, full B1/D1 baselines below):

   Padel Social (10) -- Growyze fallback tier
     B1  int_growyze001            8,342 rows  net   204,962.22  (2026-01-29 to 2026-07-30)
     C1  profit 144,248.29 / net 178,464.46 / 80.8% / 7,489 rows   <== REGRESSION GATE
     D1  Beverages 95,647.68 / Other 64,542.78 / Food 8,547.06 /
         Uncategorised 6,308.23 / Retail 3,418.71

   Dirty Sixth (18) -- Growyze fallback tier
     B1  int_growyze001           14,140 rows  net   466,632.86  (2026-01-29 to 2026-07-29)
     C1  profit 317,414.99 / net 405,110.80 / 78.4% / 12,906 rows  <== REGRESSION GATE
     D1  Food 271,266.16 / Beverages 127,144.26 / Uncategorised 5,160.38 / Other 1,540.00

   Oak & Vine (16) -- POS tier: int_ncraloha001 + int_mews001
     B1  int_ncraloha001         175,044 rows  net 1,365,706.40  (2025-10-01 to 2026-03-31)
         int_mews001               1,368 rows  net    55,221.06  (2026-04-30 to 2026-07-28)
         combined net 1,420,927.46
     C1  profit 905,503.87 / net 1,092,561.20 / 82.9% / 64,724 rows
     D1  Food 917,074.42 / Drinks 448,913.60 / Breakfast 49,230.21 / Bottled Beer 1,985.98 /
         Wine 1,335.45 / Soft Drinks 1,175.54 / Spirits 695.20 / Hot Drinks 404.01 /
         Draught Beer 113.01 / Tips 0.04

   Ibis Gloucester Road (21) -- POS tier: int_mews001
     B1  int_mews001                 875 rows  net    33,144.54  (2026-05-30 to 2026-07-28)
     C1  legitimately returns NO ROWS (Mews populates no cost at all, so the
         AVG_NET_COST guard filters every row - expected, not a failure)
     D1  Breakfast 29,489.71 / Bottled Beer 1,344.06 / Soft Drinks 809.25 / Wine 787.95 /
         Spirits 341.00 / Hot Drinks 248.71 / Food 123.82 / Tips 0.04

   Ibis Heathrow (20) -- POS tier: int_mews001
     no sales rows at all; every section must return cleanly with no rows

   Padel and Dirty Sixth are the REGRESSION GATE: their C1 figures must not move.
   E1 (no_tier_leak) must report PASS or VACUOUS on all five orgs (see the note
   above section E - a bare PASS is only meaningful once a POS org actually
   carries Growyze line items, which none of the five do today).

   NOTE (B vs D): section B does not apply the `Unknown` product/location guards
   that section D and the deployed cards apply, so B's net_sales for a SRC will
   not reconcile exactly against the sum of D's rows for that org (e.g. Oak &
   Vine's combined B1 net is 1,420,927.46 but D1's rows sum to less, since D1
   drops Unknown-categorised and Unknown-location lines). This is a real, known
   gap - deliberately left as-is (see fix-round-1 notes); not a query bug.

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
   *** HONESTY FIX 2026-07-31 (O5 fix round 1) ***
   The original version joined F to the same resolver-built `ss` used
   everywhere else and summed rows where SRC = 'int_growyze001'. On a POS org
   `ss` never contains 'int_growyze001' (Growyze is INVENTORY-type, never in
   org_pos), so those rows are excluded by the JOIN itself before the SUM ever
   runs - growyze_rows was structurally 0 and the FAIL branch was unreachable
   by construction. On a fallback-tier org the EXISTS(...POS...) half of the
   FAIL condition is false, so it was unreachable there too. The check could
   never fail and was not actually exercising anything about the join.

   This version reports the raw population alongside the resolver-joined
   count so a reader can see there was something to exclude, not just an
   absence of data:
     growyze_rows_in_fact       - Growyze PROD rows in the fact table, no
                                   resolver join at all (the population a
                                   leak could come from)
     growyze_rows_after_resolver- Growyze rows that survive the resolver join
                                   (the original measure)
   A PASS is only meaningful when growyze_rows_in_fact > 0 - i.e. Growyze data
   actually exists for this org and was genuinely excluded. Today that is
   VACUOUS on all five orgs: no POS-tier org here carries any Growyze line
   items yet, so there is nothing for the join to exclude. This becomes a real
   check the moment Growyze POS-sync is enabled on a Mews/NCRAloha org - which
   is exactly the scenario the precedence rule exists to guard against, so the
   check stays even though it is inert on today's data. Note this still can't
   catch a join-key bug in the deployed cards themselves (39/40), only in this
   verifier's own copy of the resolver - it is a self-consistency check, not
   an independent replay of the cards' SQL. */
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
),
metrics AS (
    SELECT
        (SELECT COUNT(*) FROM [presentation].[F_LINEITEM_15MIN] F
         WHERE F.LI_TYPE = 'PROD' AND F.[SRC] = 'int_growyze001') AS growyze_rows_in_fact,
        (SELECT COUNT(*) FROM [presentation].[F_LINEITEM_15MIN] F
         INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
         WHERE F.LI_TYPE = 'PROD' AND F.[SRC] = 'int_growyze001') AS growyze_rows_after_resolver,
        CASE WHEN EXISTS (SELECT 1 FROM org_pos) THEN 'POS tier' ELSE 'Growyze fallback tier' END AS org_tier
)
SELECT 'E1_no_tier_leak' AS check_name,
       m.org_tier,
       m.growyze_rows_in_fact,
       m.growyze_rows_after_resolver,
       CASE
           WHEN m.org_tier = 'Growyze fallback tier' THEN 'N/A - single-tier org'
           WHEN m.org_tier = 'POS tier' AND m.growyze_rows_in_fact = 0
               THEN 'VACUOUS - org has no Growyze sales, nothing to leak'
           WHEN m.org_tier = 'POS tier' AND m.growyze_rows_after_resolver > 0
               THEN 'FAIL - Growyze rows on a POS org'
           WHEN m.org_tier = 'POS tier'
               THEN 'PASS - leak genuinely excluded'
       END AS verdict
FROM metrics m;
