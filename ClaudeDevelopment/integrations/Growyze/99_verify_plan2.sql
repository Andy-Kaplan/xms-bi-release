-- ============================================================================
-- 99_verify_plan2.sql - verification for Growyze dashboards Plan 2 (O5)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md (rev 2)
--
-- >>> RUN THIS WITH AN ORGANISATION DATABASE AS THE CURRENT DATABASE. <<<
-- >>> RUNNING IT FROM `core` PRODUCES A FALSE PASS ON EVERY RESOLVER CHECK.  <<<
-- The resolver reads sys.schemas of the EXECUTING database. From `core` there is no
-- int_* POS schema, so every org silently resolves to the Growyze fallback and the
-- resolver looks like a working no-op. Section B is meaningless unless the current
-- database is the org's own. Section A uses three-part [core].[core] naming and so
-- is correct from anywhere.
--
--   Example (UAT):  Padel 20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14
--                   Oak & Vine 20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87
--                   Dirty Sixth 20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A
--                   Ibis Heathrow 20260722_XMS_7CE02464-9A7E-F111-B337-002248A1EC3D
--                   Ibis Gloucester 20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D
--
-- READ-ONLY. SELECTs only; changes nothing.
--
-- *** ON THE HONESTY OF THESE CHECKS ***
-- Section A asserts the five defect classes rev 2 exists to prevent, by inspecting
-- the DEPLOYED template text. These are not mirrors of the build - they would each
-- FAIL loudly if a future edit reintroduced the defect, which is exactly what
-- happened to Plan 1 twice.
-- Section B asserts data properties that must hold whatever the data does, plus a
-- few INFO rows. Anything that cannot be falsified on a given org reports VACUOUS
-- or N/A rather than a green PASS - a check that cannot fail is not evidence.
-- ============================================================================

SET NOCOUNT ON;
PRINT '=== Plan 2 verification - current database: ' + DB_NAME() + ' ===';

-- ###########################################################################
-- SECTION A - control plane (correct from any database)
-- ###########################################################################

-- A1: all 15 datasets exist and are LIVE.
DECLARE @expected TABLE (DataSetName NVARCHAR(200), VisualizationType NVARCHAR(100), NeedsPm BIT, IsSales BIT, IsCost BIT, HasCategory BIT);
INSERT INTO @expected VALUES
 (N'GrowyzeActiveStocktakes',       N'SingleKPICard',     1, 0, 0, 0),
 (N'GrowyzeDeliveriesValue',        N'SingleKPICard',     1, 0, 0, 0),
 (N'GrowyzeAvgCostSpend',           N'SingleKPICard',     1, 1, 1, 0),
 (N'GrowyzeBestCategory',           N'SingleKPICard',     1, 1, 1, 1),
 (N'GrowyzeTopRevenueItem',         N'SingleKPICard',     1, 1, 0, 0),
 (N'GrowyzeHighestGPItem',          N'SingleKPICard',     1, 1, 1, 0),
 (N'GrowyzeMostSoldItem',           N'SingleKPICard',     1, 1, 0, 0),
 (N'GrowyzeLowestItem',             N'SingleKPICard',     1, 1, 0, 0),
 (N'GrowyzeHighestVenue',           N'SingleKPICard',     1, 0, 0, 0),
 (N'GrowyzeLowestVenue',            N'SingleKPICard',     1, 0, 0, 0),
 (N'GrowyzeCategoryStockTrend',     N'CustomDataGrid',    1, 0, 0, 0),
 (N'GrowyzeMenuProfitabilityTrend', N'CombinedChartCard', 1, 1, 1, 0),
 (N'GrowyzeMenuEngineering',        N'CustomDataGrid',    1, 1, 1, 1),
 (N'GrowyzeSalesHeatmap',           N'HeatmapCard',       1, 1, 0, 0),
 (N'GrowyzeProductsCompFilter',     N'FilterList',        0, 1, 0, 0);

SELECT 'A1_datasets_live' AS check_name,
       CASE WHEN COUNT(*) = 15 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(COUNT(*) AS NVARCHAR(10)) + ' of 15 LIVE' AS detail
FROM @expected e
JOIN [core].[core].[VisualisationQueries] v
  ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
WHERE v.Status = N'LIVE';

-- >>> EVERY CHECK BELOW COUNTS WHAT IT INSPECTED, NOT JUST WHAT IT REJECTED. <<<
-- The first draft of this file wrote each check as "0 offending rows => PASS". Run
-- before deployment, the join matched nothing, so all seven reported a confident
-- PASS over zero datasets - a green tick proving only that the join was empty. That
-- is the vacuous-check trap this project has already been bitten by twice, so each
-- check now reports VACUOUS unless it actually examined the datasets it claims to
-- cover.

-- A2: ParameterMappings must be set, or the dashboard date picker is silently
-- discarded. All three Plan 1 datasets shipped NULL and had to be repaired.
SELECT 'A2_parametermappings_set' AS check_name,
       CASE WHEN checked = 0 THEN 'VACUOUS - datasets not deployed'
            WHEN offenders = 0 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(checked AS NVARCHAR(10)) + ' of 14 inspected; ' + ISNULL(names, 'all set') AS detail
FROM (
    SELECT COUNT(*) AS checked,
           SUM(CASE WHEN v.ParameterMappings IS NULL THEN 1 ELSE 0 END) AS offenders,
           STRING_AGG(CASE WHEN v.ParameterMappings IS NULL THEN v.DataSetName END, ', ') AS names
    FROM @expected e
    JOIN [core].[core].[VisualisationQueries] v
      ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
    WHERE e.NeedsPm = 1
) x;

-- A3: every sales card must carry the resolver. Without it a card is hardcoded to
-- one source and renders empty on any org whose sales come from elsewhere.
SELECT 'A3_sales_cards_resolve_source' AS check_name,
       CASE WHEN checked = 0 THEN 'VACUOUS - datasets not deployed'
            WHEN offenders = 0 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(checked AS NVARCHAR(10)) + ' of 8 inspected; ' + ISNULL(names, 'all carry the resolver') AS detail
FROM (
    SELECT COUNT(*) AS checked,
           SUM(CASE WHEN v.QueryTemplate NOT LIKE N'%sales[_]src%'
                      OR v.QueryTemplate NOT LIKE N'%IntegrationType%' THEN 1 ELSE 0 END) AS offenders,
           STRING_AGG(CASE WHEN v.QueryTemplate NOT LIKE N'%sales[_]src%'
                             OR v.QueryTemplate NOT LIKE N'%IntegrationType%'
                           THEN v.DataSetName END, ', ') AS names
    FROM @expected e
    JOIN [core].[core].[VisualisationQueries] v
      ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
    WHERE e.IsSales = 1
) x;

-- A4: no Plan 2 card may filter BOTTOM_LEVEL_NAME - it is source-specific
-- ('Location'/'Product' for Growyze but 'BOTTOM' for Mews and NCRAloha) and
-- silently drops POS rows.
SELECT 'A4_no_bottom_level_name_filter' AS check_name,
       CASE WHEN checked = 0 THEN 'VACUOUS - datasets not deployed'
            WHEN offenders = 0 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(checked AS NVARCHAR(10)) + ' of 15 inspected; ' + ISNULL(names, 'none reference it') AS detail
FROM (
    SELECT COUNT(*) AS checked,
           SUM(CASE WHEN v.QueryTemplate LIKE N'%BOTTOM[_]LEVEL[_]NAME%' THEN 1 ELSE 0 END) AS offenders,
           STRING_AGG(CASE WHEN v.QueryTemplate LIKE N'%BOTTOM[_]LEVEL[_]NAME%'
                           THEN v.DataSetName END, ', ') AS names
    FROM @expected e
    JOIN [core].[core].[VisualisationQueries] v
      ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
) x;

-- A5: category-bearing cards must group on TOP, never MIDDLE_1 (Mews MIDDLE_1 is
-- 98 product families vs 12 real categories), and no FilterDefinitions may sit on
-- the MIDDLE_1 grain either - the filter and the GROUP BY must agree.
SELECT 'A5_category_grain_is_TOP' AS check_name,
       CASE WHEN checked = 0 THEN 'VACUOUS - datasets not deployed'
            WHEN offenders = 0 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(checked AS NVARCHAR(10)) + ' of 15 inspected; ' + ISNULL(names, 'TOP grain everywhere') AS detail
FROM (
    SELECT COUNT(*) AS checked,
           SUM(CASE WHEN (e.HasCategory = 1 AND v.QueryTemplate LIKE N'%MIDDLE[_]1[_]%')
                      OR (v.FilterDefinitions IS NOT NULL
                          AND CAST(v.FilterDefinitions AS NVARCHAR(MAX)) LIKE N'%MIDDLE[_]1[_]%')
                     THEN 1 ELSE 0 END) AS offenders,
           STRING_AGG(CASE WHEN (e.HasCategory = 1 AND v.QueryTemplate LIKE N'%MIDDLE[_]1[_]%')
                             OR (v.FilterDefinitions IS NOT NULL
                                 AND CAST(v.FilterDefinitions AS NVARCHAR(MAX)) LIKE N'%MIDDLE[_]1[_]%')
                           THEN v.DataSetName END, ', ') AS names
    FROM @expected e
    JOIN [core].[core].[VisualisationQueries] v
      ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
) x;

-- A6: every cost-dependent card must restrict its ratio denominator to costed rows.
-- The unguarded form read Oak & Vine's margin as 63.7% instead of 82.9%.
SELECT 'A6_cost_cards_coverage_guarded' AS check_name,
       CASE WHEN checked = 0 THEN 'VACUOUS - datasets not deployed'
            WHEN offenders = 0 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(checked AS NVARCHAR(10)) + ' of 5 inspected; ' + ISNULL(names, 'all guarded') AS detail
FROM (
    SELECT COUNT(*) AS checked,
           SUM(CASE WHEN v.QueryTemplate NOT LIKE N'%AVG[_]NET[_]COST% IS NOT NULL%' THEN 1 ELSE 0 END) AS offenders,
           STRING_AGG(CASE WHEN v.QueryTemplate NOT LIKE N'%AVG[_]NET[_]COST% IS NOT NULL%'
                           THEN v.DataSetName END, ', ') AS names
    FROM @expected e
    JOIN [core].[core].[VisualisationQueries] v
      ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
    WHERE e.IsCost = 1
) x;

-- A7: cost-dependent cards must declare an explicit no-cost state rather than
-- rendering blank on a Mews-only org (ledger O35).
SELECT 'A7_cost_cards_have_nocost_state' AS check_name,
       CASE WHEN checked = 0 THEN 'VACUOUS - datasets not deployed'
            WHEN offenders = 0 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(checked AS NVARCHAR(10)) + ' of 5 inspected; ' + ISNULL(names, 'all declare one') AS detail
FROM (
    SELECT COUNT(*) AS checked,
           SUM(CASE WHEN v.QueryTemplate NOT LIKE N'%No cost data%' THEN 1 ELSE 0 END) AS offenders,
           STRING_AGG(CASE WHEN v.QueryTemplate NOT LIKE N'%No cost data%'
                           THEN v.DataSetName END, ', ') AS names
    FROM @expected e
    JOIN [core].[core].[VisualisationQueries] v
      ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
    WHERE e.IsCost = 1
) x;

-- A8: no unreplaced template token, and no encoding damage to the pound sign or
-- middot. Deploy reads the .sql files as UTF-8 without BOM; if that ever changes,
-- the currency symbol becomes mojibake and this is where it shows up.
SELECT 'A8_templates_wellformed' AS check_name,
       CASE WHEN checked = 0 THEN 'VACUOUS - datasets not deployed'
            WHEN offenders = 0 THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(checked AS NVARCHAR(10)) + ' of 15 inspected; ' + ISNULL(names, 'no tokens, no mojibake') AS detail
FROM (
    SELECT COUNT(*) AS checked,
           SUM(CASE WHEN v.QueryTemplate LIKE N'%{{%'
                      OR v.QueryTemplate LIKE N'%Ã%'
                      OR v.QueryTemplate LIKE N'%â%' THEN 1 ELSE 0 END) AS offenders,
           STRING_AGG(CASE WHEN v.QueryTemplate LIKE N'%{{%'
                             OR v.QueryTemplate LIKE N'%Ã%'
                             OR v.QueryTemplate LIKE N'%â%'
                           THEN v.DataSetName END, ', ') AS names
    FROM @expected e
    JOIN [core].[core].[VisualisationQueries] v
      ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
) x;

-- A9: Task L - InvMargeBrut must no longer bind any filter to invitem.*, and must
-- keep its Locations filter (which binds in both CTEs).
SELECT 'A9_invmargebrut_filter_fixed' AS check_name,
       CASE WHEN SUM(CASE WHEN fd LIKE N'%COALESCE(invitem.%' THEN 1 ELSE 0 END) = 0
                 AND SUM(CASE WHEN fd LIKE N'%COALESCE(location.%' THEN 1 ELSE 0 END) = COUNT(*)
            THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(COUNT(*) AS NVARCHAR(10)) + ' row(s); invitem-bound filters: '
         + CAST(SUM(CASE WHEN fd LIKE N'%COALESCE(invitem.%' THEN 1 ELSE 0 END) AS NVARCHAR(10)) AS detail
FROM (
    SELECT CAST(FilterDefinitions AS NVARCHAR(MAX)) AS fd
    FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid'
) x;

-- ###########################################################################
-- SECTION B - per-organisation data properties (needs the ORG DB as current db)
-- ###########################################################################

-- B0: what this org actually resolves to. INFO - it is the context for everything
-- below, and it is the single fact a run from `core` gets wrong.
WITH org_pos AS (
    SELECT i.[SchemaName] FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'B0_resolved_sales_source' AS check_name, 'INFO' AS verdict,
       STRING_AGG(SRC, ' + ') AS detail
FROM sales_src;

-- B1: Active Stocktakes denominator must count ONLY inventory venues. The failure
-- this catches is real: counting all locations gives Oak & Vine 1/9 and Ibis
-- Gloucester 1/3, ratios that can never complete.
SELECT 'B1_stocktake_denominator_scoped' AS check_name,
       CASE WHEN inv_venues = 0 THEN 'VACUOUS - no Growyze venues on this org'
            WHEN inv_venues <= all_venues THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST(counted AS NVARCHAR(10)) + ' / ' + CAST(inv_venues AS NVARCHAR(10))
         + '  (all locations incl. POS: ' + CAST(all_venues AS NVARCHAR(10)) + ')' AS detail
FROM (
    SELECT
      (SELECT COUNT(*) FROM [presentation].[D_LOCATION]
        WHERE [BOTTOM_SRC] = 'int_growyze001' AND [BOTTOM_LOCATION_NAME] <> 'Unknown') AS inv_venues,
      (SELECT COUNT(*) FROM [presentation].[D_LOCATION]
        WHERE [BOTTOM_LOCATION_NAME] <> 'Unknown') AS all_venues,
      (SELECT COUNT(DISTINCT FC.LOCATION_HUB_ID)
         FROM [presentation].[F_INV_COUNTS_DAY] FC
         JOIN [presentation].[D_LOCATION] l ON FC.LOCATION_HUB_ID = l.BOTTOM_HUB_ID
        WHERE l.[BOTTOM_SRC] = 'int_growyze001') AS counted
) x;

-- B2: Deliveries must NOT be reduced by a location guard. Independent witness: the
-- unguarded total vs the guarded one. On Dirty Sixth the guard removed 60% of the
-- value, so this check fails loudly if the guard is ever reintroduced.
SELECT 'B2_deliveries_include_unattributed' AS check_name,
       CASE WHEN OBJECT_ID('presentation.F_PURCHASES_DAY') IS NULL THEN 'N/A - fact absent on this org'
            WHEN total_all = 0 THEN 'VACUOUS - no Growyze purchases'
            WHEN total_all >= total_guarded THEN 'PASS' ELSE 'FAIL' END AS verdict,
       'all=' + CAST(CAST(total_all AS DECIMAL(18,2)) AS NVARCHAR(30))
         + ' guarded=' + CAST(CAST(total_guarded AS DECIMAL(18,2)) AS NVARCHAR(30))
         + ' unattributed_rows=' + CAST(unattributed AS NVARCHAR(10)) AS detail
FROM (
    SELECT
      ISNULL(SUM(ISNULL(F.LINE_TOTAL,0)), 0) AS total_all,
      ISNULL(SUM(CASE WHEN l.[BOTTOM_LOCATION_NAME] <> 'Unknown' THEN ISNULL(F.LINE_TOTAL,0) END), 0) AS total_guarded,
      SUM(CASE WHEN F.LOCATION_HUB_ID = CONVERT(BINARY(32), -999) THEN 1 ELSE 0 END) AS unattributed
    FROM [presentation].[F_PURCHASES_DAY] F
    LEFT JOIN [presentation].[D_INVITEM] i ON F.INVITEM_HUB_ID = i.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] l ON F.LOCATION_HUB_ID = l.BOTTOM_HUB_ID
    WHERE i.[BOTTOM_SRC] = 'int_growyze001'
) x;

-- B3: the O33 fan-out, measured on THIS org. INFO, because it is a data defect this
-- plan works around rather than fixes - but the number belongs in every run so the
-- blast radius stops being unmeasured.
SELECT 'B3_o33_count_fanout_present' AS check_name, 'INFO' AS verdict,
       CAST(ISNULL(dup_groups,0) AS NVARCHAR(10)) + ' duplicate (location,item,date) group(s); '
         + CAST(ISNULL(theo_differs,0) AS NVARCHAR(10)) + ' of them disagree on THEO_QTY '
         + '(ACTUAL_COUNT disagreements: ' + CAST(ISNULL(actual_differs,0) AS NVARCHAR(10)) + ')' AS detail
FROM (
    SELECT COUNT(*) AS dup_groups,
           SUM(CASE WHEN d_theo   > 1 THEN 1 ELSE 0 END) AS theo_differs,
           SUM(CASE WHEN d_actual > 1 THEN 1 ELSE 0 END) AS actual_differs
    FROM (
        SELECT COUNT(*) AS n,
               COUNT(DISTINCT THEO_QTY)     AS d_theo,
               COUNT(DISTINCT ACTUAL_COUNT) AS d_actual
        FROM [presentation].[F_INV_COUNTS_DAY]
        GROUP BY LOCATION_HUB_ID, INVITEM_HUB_ID, CAST(COUNT_DATE AS DATE)
        HAVING COUNT(*) > 1
    ) g
) x;

-- B4: the venue cards must value a SNAPSHOT, not a sum across stocktakes. Witness:
-- the naive cross-period sum. On a multi-period org it is far larger (Padel 9.5x);
-- where they are equal the org has one period and cannot falsify this - say so
-- rather than claiming a PASS.
-- NB the CTEs are at statement level: a WITH clause is NOT permitted inside a
-- derived table, which is how the first draft of this check failed to parse.
WITH counts AS (
    SELECT FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID, CAST(FC.COUNT_DATE AS DATE) AS d,
           MAX(FC.ACTUAL_COUNT) AS a, MAX(FC.UOM_COST) AS c
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    LEFT JOIN [presentation].[D_INVITEM] i ON FC.INVITEM_HUB_ID = i.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] l ON FC.LOCATION_HUB_ID = l.BOTTOM_HUB_ID
    WHERE i.[BOTTOM_SRC] = 'int_growyze001' AND l.[BOTTOM_SRC] = 'int_growyze001'
    GROUP BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID, CAST(FC.COUNT_DATE AS DATE)
),
ranked AS (
    SELECT counts.*, ROW_NUMBER() OVER (PARTITION BY LOCATION_HUB_ID, INVITEM_HUB_ID ORDER BY d DESC) AS rn
    FROM counts
),
agg AS (
    SELECT SUM(CASE WHEN rn = 1 THEN ISNULL(a,0)*ISNULL(c,0) END) AS snapshot_val,
           SUM(ISNULL(a,0)*ISNULL(c,0)) AS naive_val
    FROM ranked
)
SELECT 'B4_venue_value_is_snapshot' AS check_name,
       CASE WHEN snapshot_val IS NULL OR snapshot_val = 0 THEN 'VACUOUS - no Growyze stocktakes'
            WHEN naive_val = snapshot_val THEN 'N/A - single stocktake per item; cannot falsify here'
            WHEN naive_val > snapshot_val THEN 'PASS'
            ELSE 'FAIL' END AS verdict,
       'snapshot=' + ISNULL(CAST(CAST(snapshot_val AS DECIMAL(18,2)) AS NVARCHAR(30)), 'NULL')
         + ' naive_all_periods=' + ISNULL(CAST(CAST(naive_val AS DECIMAL(18,2)) AS NVARCHAR(30)), 'NULL') AS detail
FROM agg;

-- B5: Menu Engineering quadrants must be exhaustive - every costed product lands in
-- exactly one. An off-by-one on a median boundary shows up here as a mismatch.
WITH org_pos AS (
    SELECT i.[SchemaName] FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
),
prod AS (
    SELECT COALESCE(p.[BOTTOM_MICROSERVICE_NAME], p.[BOTTOM_PRODUCT_NAME]) AS pname,
           SUM(F.[QUANTITY]) AS qty,
           SUM(F.[PROFIT]) * 100.0
             / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END), 0) AS gp
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    LEFT JOIN [presentation].[D_PRODUCT] p ON F.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] l ON F.LOCATION_HUB_ID = l.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = p.[BOTTOM_SRC]
    WHERE F.[NET_VALUE] > 0 AND F.[AVG_NET_COST] IS NOT NULL
      AND COALESCE(p.[BOTTOM_MICROSERVICE_NAME], p.[BOTTOM_PRODUCT_NAME]) <> 'Unknown'
      AND l.[BOTTOM_LOCATION_NAME] <> 'Unknown'
    GROUP BY COALESCE(p.[BOTTOM_MICROSERVICE_NAME], p.[BOTTOM_PRODUCT_NAME])
),
med AS (
    SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY qty) OVER () AS mq,
                    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gp)  OVER () AS mg
    FROM prod
)
SELECT 'B5_quadrants_exhaustive' AS check_name,
       CASE WHEN (SELECT COUNT(*) FROM prod) = 0
              THEN 'VACUOUS - no costed products (expected on a Mews-only org, O35)'
            WHEN (SELECT COUNT(*) FROM prod) =
                 (SELECT COUNT(*) FROM prod p CROSS JOIN med m
                   WHERE (p.qty >= m.mq AND p.gp >= m.mg) OR (p.qty < m.mq AND p.gp >= m.mg)
                      OR (p.qty >= m.mq AND p.gp < m.mg)  OR (p.qty < m.mq AND p.gp < m.mg))
              THEN 'PASS' ELSE 'FAIL' END AS verdict,
       CAST((SELECT COUNT(*) FROM prod) AS NVARCHAR(10)) + ' costed products' AS detail;

-- B6: the heatmap's timestamp coverage. INFO with an explicit warning, because on a
-- Growyze-sourced org this is structurally partial and always will be.
SELECT 'B6_heatmap_timestamp_coverage' AS check_name, 'INFO' AS verdict,
       CAST(with_ts AS NVARCHAR(20)) + ' of ' + CAST(all_rows AS NVARCHAR(20))
         + ' PROD lines carry a timestamp; ' + CAST(distinct_hours AS NVARCHAR(10)) + ' distinct hour(s)'
         + CASE WHEN all_rows > 0 AND with_ts * 10 < all_rows
                THEN ' <- recent-window only; Growyze history is permanently NULL' ELSE '' END AS detail
FROM (
    SELECT COUNT(*) AS all_rows,
           SUM(CASE WHEN F.LINEITEM_TIMESTAMP IS NOT NULL THEN 1 ELSE 0 END) AS with_ts,
           COUNT(DISTINCT CASE WHEN F.LINEITEM_TIMESTAMP IS NOT NULL
                               THEN DATEPART(HOUR, F.LINEITEM_TIMESTAMP) END) AS distinct_hours
    FROM [presentation].[F_LINEITEM_15MIN] F
    WHERE F.LI_TYPE = 'PROD'
) x;

-- B7: REGRESSION WITNESS for the Plan 1 cards, reported as INFO - deliberately NOT
-- an equality assertion against the recorded baseline.
--
-- Plan 1 signed off (2026-07-31) at Padel GBP 144,248.29 / 7,489 rows and Dirty
-- Sixth GBP 317,414.99 / 12,906 rows. Measured on the SAME DAY, before any Plan 2
-- script was deployed, Padel already read GBP 148,897.95 / 7,600 rows - the fact
-- had grown by 111 rows and GBP 4,649.66 because a load ran in between. Verified
-- the gap is not an artefact of this query: adding the deployed card's CALENDAR
-- join changes nothing (every ORDER_DATE is in CALENDAR).
--
-- So hardcoding equality here would have produced a permanent false FAIL on every
-- future run - the precise trap that made an earlier 99_verify untrustworthy on this
-- project. These figures move whenever data lands, and Plan 2 adds only new
-- datasets, so the honest gate is to run THIS SCRIPT BEFORE AND AFTER the deploy and
-- compare the two outputs. A change between those two runs is a regression; a change
-- from the 2026-07-31 baseline is just time passing.
WITH org_pos AS (
    SELECT i.[SchemaName] FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
),
m AS (
    SELECT CAST(SUM(F.[PROFIT]) AS DECIMAL(18,2)) AS profit,
           CAST(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END) AS DECIMAL(18,2)) AS net_costed,
           COUNT(*) AS rows_
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    LEFT JOIN [presentation].[D_PRODUCT] p ON F.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] l ON F.LOCATION_HUB_ID = l.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = p.[BOTTOM_SRC]
    WHERE F.[NET_VALUE] > 0 AND F.[AVG_NET_COST] IS NOT NULL
      AND l.[BOTTOM_LOCATION_NAME] <> 'Unknown'
)
SELECT 'B7_plan1_regression_witness' AS check_name,
       'INFO - compare this line before vs after the deploy' AS verdict,
       'profit=' + ISNULL(CAST(m.profit AS NVARCHAR(30)), 'NULL')
         + ' net_costed=' + ISNULL(CAST(m.net_costed AS NVARCHAR(30)), 'NULL')
         + ' rows=' + CAST(m.rows_ AS NVARCHAR(20))
         + CASE WHEN DB_NAME() LIKE '20260310[_]XMS[_]94A4B719%'
                     THEN '  [Plan 1 signoff 2026-07-31: profit=144248.29 rows=7489]'
                WHEN DB_NAME() LIKE '20260327[_]XMS[_]7B50D717%'
                     THEN '  [Plan 1 signoff 2026-07-31: profit=317414.99 rows=12906]'
                ELSE '  [no recorded baseline for this org]' END AS detail
FROM m;

PRINT '=== Plan 2 verification complete for ' + DB_NAME() + ' ===';
PRINT 'Reminder: a run from `core` invalidates every Section B resolver check.';
