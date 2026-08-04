/*==============================================================================
  88_verify_plan4.sql   -- READ-ONLY
  O5 Plan 4 verification: layout & formatting pass (warehouse side)

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md

  VERIFIER HYGIENE -- THIS PROJECT HAS BEEN BITTEN TWICE
    96_verify_plan1.sql shipped THREE checks that could never pass (one asserted
    an identity the rolling DL window makes impossible; two looked for
    BOTTOM_LEVEL_NAME='Category' rows in a table that holds only leaf rows, so
    both were vacuously 0). Script 41's negative check was a structural tautology
    whose FAIL branch was unreachable on any data. Left alone, those produce
    permanent false FAILs or permanent false PASSes.

    So, for every check below: the FAIL string states WHAT WOULD BE WRONG, and
    each check is written so that it CAN fail on some reachable data state.
    Checks with nothing to falsify report VACUOUS, not PASS. Section C reports
    observations as INFO and deliberately does not dress them up as assertions.

  SECTIONS
    A  Query-text assertions   -- did the edits land, in the LIVE column
    B  Data assumptions        -- the premises the rewrites REST on, per org
    C  Alert reachability      -- INFO: does each banner currently fire

  Run against: core. Changes nothing.
==============================================================================*/

SET NOCOUNT ON;

PRINT '=== SECTION A -- query-text assertions ===';

/*------------------------------------------------------------------------------
  A1. Currency symbols. Asserted as NCHAR(163) because that is what the scripts
      write; a literal symbol here would mean the file was mangled by sqlcmd on
      the way in, which is the failure this encoding choice exists to prevent.
      So this check ALSO detects mojibake, and CHAR(163) in a non-Unicode form
      would not match.
------------------------------------------------------------------------------*/
SELECT 'A1 currency on KPI cards' AS Check_,
    DataSetName, VisualizationType,
    CASE WHEN CHARINDEX(N'NCHAR(163)', COALESCE(ExecutionQuery, QueryTemplate)) > 0
         THEN 'PASS'
         WHEN CHARINDEX(NCHAR(163), COALESCE(ExecutionQuery, QueryTemplate)) > 0
         THEN 'FAIL - a literal symbol is stored, not NCHAR(163); file encoding was mangled or an edit bypassed script 54'
         ELSE 'FAIL - no currency symbol at all' END AS Verdict
FROM core.core.VisualisationQueries
WHERE Status = N'LIVE' AND VisualizationType = N'SingleKPICard'
  AND DataSetName IN (N'NetSales', N'InvWasteCost')
ORDER BY DataSetName;

/*------------------------------------------------------------------------------
  A2. InvCOGSByCategory -- the four fixes, on BOTH card types.
      Chk_CentreFromBase is the substantive one: it asserts the pie's centre
      total is derived from the same Base CTE as the slices, which is what makes
      "centre = sum of slices" true BY CONSTRUCTION rather than by luck.
------------------------------------------------------------------------------*/
SELECT 'A2 InvCOGSByCategory' AS Check_,
    VisualizationType,
    CASE WHEN CHARINDEX(N'CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - CALENDAR join not CAST; POS rows with a time silently vanish' END AS Chk_DateCast,
    CASE WHEN CHARINDEX(N'INNER JOIN sales_src ss', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - no source scope; blends NCRAloha/Mews/Growyze on Oak & Vine' END AS Chk_SourceScope,
    CASE WHEN CHARINDEX(N'NULLIF(F.[AVG_NET_COST],0) IS NOT NULL', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - no cost guard; COGS and GP describe different populations' END AS Chk_CostGuard,
    CASE WHEN JSON_VALUE(FilterDefinitions, '$.ProductCategories.column')
              = N'COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])'
         THEN 'PASS' ELSE 'FAIL - filter grain still diverges from the GROUP BY; picking a category can blank the card' END AS Chk_FilterGrain,
    CASE WHEN VisualizationType <> N'PieChartCard' THEN 'N/A - pie only'
         WHEN CHARINDEX(N'FROM Base WHERE CATEGORY IS NOT NULL) AS PiePrimaryText', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - centre total not derived from Base; cannot equal the slices' END AS Chk_CentreFromBase
FROM core.core.VisualisationQueries
WHERE DataSetName = N'InvCOGSByCategory' AND Status = N'LIVE'
  AND VisualizationType IN (N'PieChartCard', N'StackedBarChartCard')
ORDER BY VisualizationType;

/*------------------------------------------------------------------------------
  A3. GrowyzeCategoryStockTrend -- sentinel relabelled, NOT filtered.
      Chk_SentinelNotFiltered is deliberately a check that the row is still
      REACHABLE. The design doc's instruction was to filter it out, which would
      have hidden GBP 1,164.56 of counted stock on Dirty Sixth; if someone later
      "restores" that instruction this check fails.
------------------------------------------------------------------------------*/
SELECT 'A3 GrowyzeCategoryStockTrend' AS Check_,
    CASE WHEN CHARINDEX(N'MAX(COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])) AS category', QueryTemplate) = 0
         THEN 'PASS' ELSE 'FAIL - bare COALESCE still assigned to category; sentinel leaks as a real category' END AS Chk_SentinelRelabelled,
    CASE WHEN CHARINDEX(N'THEN N''Uncategorised''', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - no Uncategorised branch' END AS Chk_UncategorisedBucket,
    CASE WHEN CHARINDEX(N'<> N''All INVITEMs''', QueryTemplate) = 0
              AND CHARINDEX(N'<> ''All INVITEMs''', QueryTemplate) = 0
         THEN 'PASS' ELSE 'FAIL - sentinel is being FILTERED OUT, which hides real counted stock. Relabel, do not exclude.' END AS Chk_SentinelNotFiltered,
    CASE WHEN CHARINDEX(N'invitem.[BOTTOM_SRC] = ''int_growyze001''', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - source scope lost' END AS Chk_SourceScopeIntact
FROM core.core.VisualisationQueries
WHERE DataSetName = N'GrowyzeCategoryStockTrend' AND VisualizationType = N'CustomDataGrid' AND Status = N'LIVE';

/*------------------------------------------------------------------------------
  A4. GrowyzeMenuEngineering -- data and header must agree, or columns render
      under the wrong headings with no error at all.
------------------------------------------------------------------------------*/
SELECT 'A4 GrowyzeMenuEngineering' AS Check_,
    CASE WHEN CHARINDEX(N'ELSE N''Dog'' END AS Column2,', QueryTemplate) > 0
              AND CHARINDEX(N'N''Classification'' AS [Label2]', QueryTemplate) > 0
         THEN 'PASS'
         ELSE 'FAIL - data alias and header label disagree; values would appear under the wrong column names' END AS Chk_DataAndHeaderAgree,
    CASE WHEN CHARINDEX(N'N''CURRENCY'' AS [Type5]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - Revenue not CURRENCY' END AS Chk_RevenueCurrency,
    CASE WHEN CHARINDEX(N'N''PERCENT''  AS [Type6]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - GP % not PERCENT' END AS Chk_GpPercent,
    CASE WHEN CHARINDEX(N'N''No cost data''', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - O35 no-cost sentinel row lost' END AS Chk_O35SentinelIntact
FROM core.core.VisualisationQueries
WHERE DataSetName = N'GrowyzeMenuEngineering' AND VisualizationType = N'CustomDataGrid' AND Status = N'LIVE';

/*------------------------------------------------------------------------------
  A5. InvUseAnalisys -- the column cut, and the promise that nothing is derived.
------------------------------------------------------------------------------*/
SELECT 'A5 InvUseAnalisys' AS Check_,
    CASE WHEN CHARINDEX(N'PRODUCTION_QTY + TRANSFER_QTY', ExecutionQuery) = 0
         THEN 'PASS' ELSE 'FAIL - hand-rolled usage formula still present; disagrees with ACTUAL_USAGE in 88% of rows' END AS Chk_NoHandRolledUsage,
    CASE WHEN CHARINDEX(N'ROUND(VARIANCE, 2)', ExecutionQuery) > 0
         THEN 'PASS' ELSE 'FAIL - variance not read from the native column' END AS Chk_NativeVariance,
    CASE WHEN CHARINDEX(N'SALE_QTY * -1', ExecutionQuery) = 0
         THEN 'PASS' ELSE 'FAIL - variance/theoretical usage is being derived again; would contradict InvKPIGrouped on the same dashboard' END AS Chk_NothingDerived,
    CASE WHEN CHARINDEX(N'OPEN DATE', ExecutionQuery) = 0 AND CHARINDEX(N'CLOSE COUNT', ExecutionQuery) = 0
         THEN 'PASS' ELSE 'FAIL - the swapped OPEN/CLOSE headers are back' END AS Chk_SwappedHeadersGone,
    CASE WHEN ExecutionQuery = QueryTemplate
         THEN 'PASS' ELSE 'FAIL - ExecutionQuery and QueryTemplate have diverged' END AS Chk_ColumnsInSync
FROM core.core.VisualisationQueries
WHERE DataSetName = N'InvUseAnalisys' AND VisualizationType = N'CustomDataGrid' AND Status = N'LIVE';

/*------------------------------------------------------------------------------
  A6. Duplicate header alias, and the two grids' currency tokens.
      Counting occurrences rather than checking [Type21] exists: the defect is
      the DUPLICATE, and a query could contain both.
------------------------------------------------------------------------------*/
SELECT 'A6 duplicate header alias' AS Check_,
    DataSetName,
    (LEN(COALESCE(ExecutionQuery, QueryTemplate))
       - LEN(REPLACE(COALESCE(ExecutionQuery, QueryTemplate), N'[Type11]', N''))) / 8 AS Type11_Count,
    CASE WHEN (LEN(COALESCE(ExecutionQuery, QueryTemplate))
                 - LEN(REPLACE(COALESCE(ExecutionQuery, QueryTemplate), N'[Type11]', N''))) / 8 <= 1
         THEN 'PASS' ELSE 'FAIL - [Type11] still duplicated; [Type21] is missing from the header result set' END AS Verdict
FROM core.core.VisualisationQueries
WHERE Status = N'LIVE'
  AND ((DataSetName = N'InvKPIGrouped'  AND VisualizationType = N'CustomGroupedDataGrid')
    OR (DataSetName = N'InvUseAnalisys' AND VisualizationType = N'CustomDataGrid'))
ORDER BY DataSetName;

/*------------------------------------------------------------------------------
  A7. ProductComparison -- Subcategory must SURVIVE. The design doc asked for it
      to be dropped; that would degrade the multi-source orgs (Mews/NCRAloha TOP
      and MIDDLE_1 are genuinely different levels). This check exists to stop a
      future pass from "tidying" it away.
------------------------------------------------------------------------------*/
SELECT 'A7 ProductComparison' AS Check_,
    CASE WHEN CHARINDEX(N'''Subcategory'' AS [Label3]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - Subcategory was dropped; Mews/NCRAloha lose a real hierarchy level to tidy a Growyze-only duplication' END AS Chk_SubcategoryKept,
    CASE WHEN CHARINDEX(N'''CURRENCY'' AS [Type6],', QueryTemplate) > 0
              AND CHARINDEX(N'''CURRENCY'' AS [Type11],', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - money columns not typed CURRENCY' END AS Chk_CurrencyTokens,
    CASE WHEN CHARINDEX(N'''PERCENT'' AS [Type9],', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - GP% not typed PERCENT' END AS Chk_PercentToken
FROM core.core.VisualisationQueries
WHERE DataSetName = N'ProductComparison' AND VisualizationType = N'CustomDataGrid' AND Status = N'LIVE';

/*------------------------------------------------------------------------------
  A8. The three new datasets, and the templates they depend on.
      An inactive template makes a banner silently un-fireable -- indistinguishable
      from "healthy" in a smoke test, which is exactly why it is asserted here.
------------------------------------------------------------------------------*/
SELECT 'A8 new datasets' AS Check_,
    e.DataSetName, e.VisualizationType,
    CASE WHEN v.DataSetName IS NULL      THEN 'FAIL - MISSING'
         WHEN v.Status <> N'LIVE'        THEN 'FAIL - NOT LIVE: ' + v.Status
         WHEN v.ExecutionQuery IS NOT NULL THEN 'FAIL - ExecutionQuery set; QueryTemplate would be ignored'
         ELSE 'PASS' END AS Verdict
FROM (VALUES (N'OverviewStockAlert', N'StaticBoxCard'),
             (N'InvCountHealthAlert', N'StaticBoxCard'),
             (N'SPProductSectionHeader', N'MarkdownCard')) e (DataSetName, VisualizationType)
LEFT JOIN core.core.VisualisationQueries v
       ON v.DataSetName = e.DataSetName AND v.VisualizationType = e.VisualizationType
ORDER BY e.DataSetName;

SELECT 'A9 banner templates' AS Check_,
    e.TemplateName,
    CASE WHEN t.TemplateName IS NULL THEN 'FAIL - MISSING; the banner JOIN returns nothing and the alert can never fire'
         WHEN t.IsActive = 0         THEN 'FAIL - INACTIVE; alert can never fire and looks healthy'
         ELSE 'PASS' END AS Verdict
FROM (VALUES (N'OverviewStocktakeOverdueBanner'), (N'OverviewWasteSpikeBanner'),
             (N'InvLocationCountLagBanner'), (N'InvLocationNoCostBanner')) e (TemplateName)
LEFT JOIN core.core.SuggestionTemplates t ON t.TemplateName = e.TemplateName
ORDER BY e.TemplateName;

/*------------------------------------------------------------------------------
  A10. The Inventory banner must not be quantity-based. This is the one that
       stops the rejected variance design being reinstated by a later edit.
------------------------------------------------------------------------------*/
SELECT 'A10 InvCountHealthAlert re-basing' AS Check_,
    CASE WHEN CHARINDEX(N'THEO_USAGE', QueryTemplate) = 0
              AND CHARINDEX(N'[VARIANCE]', QueryTemplate) = 0
         THEN 'PASS'
         ELSE 'FAIL - reads a quantity column. The scale defect propagates straight into the threshold; this fired at 4,385% on Padel when tried.' END AS Chk_NoQuantityMetric
FROM core.core.VisualisationQueries
WHERE DataSetName = N'InvCountHealthAlert' AND VisualizationType = N'StaticBoxCard' AND Status = N'LIVE';


PRINT '=== SECTION B -- data assumptions, per organisation ===';
/*------------------------------------------------------------------------------
  These are the PREMISES the rewrites rest on, not restatements of them. Each is
  data-dependent and each can genuinely fail as data arrives, which is the whole
  point of asserting rather than trusting.

  B1  PRODUCTION_QTY / TRANSFER_QTY are zero. InvUseAnalisys DROPPED both
      columns on that basis. If Growyze starts landing production or transfer
      events, the grid's movement columns stop accounting for the change between
      Opening and Closing, and the columns must be restored.
  B2  COUNT_DATE carries no time. Scripts 60 and 55 added CAST(...) to the
      CALENDAR joins, described as a provable no-op on that basis. If times
      appear, the CAST becomes load-bearing (which is fine) -- but the claim
      "no-op" in those headers stops being true and the row counts will move.

  Dynamic SQL over the org cursor: ClaudeDevelopment scripts must not hardcode a
  client database name.
------------------------------------------------------------------------------*/
DECLARE @Results TABLE (
    OrgName NVARCHAR(200), Rows_ INT,
    ProdNonZero INT, TransNonZero INT, NonMidnight INT
);

DECLARE @db NVARCHAR(256), @org NVARCHAR(200), @sql NVARCHAR(MAX);

DECLARE orgs CURSOR LOCAL FAST_FORWARD FOR
    SELECT o.OrganisationName, o.DatabaseName
    FROM core.core.Organisations o
    WHERE o.OrganisationID IN (10, 16, 18, 20, 21)
      AND o.DatabaseStatus IN (N'ACTIVE', N'FAILED')
    ORDER BY o.OrganisationID;

OPEN orgs;
FETCH NEXT FROM orgs INTO @org, @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'
      SELECT @o, COUNT(*),
             SUM(CASE WHEN ISNULL(PRODUCTION_QTY,0) <> 0 THEN 1 ELSE 0 END),
             SUM(CASE WHEN ISNULL(TRANSFER_QTY,0)   <> 0 THEN 1 ELSE 0 END),
             SUM(CASE WHEN CAST(COUNT_DATE AS TIME) <> ''00:00:00'' THEN 1 ELSE 0 END)
      FROM ' + QUOTENAME(@db) + N'.[presentation].[F_INV_COUNTS_DAY];';

    BEGIN TRY
        INSERT INTO @Results (OrgName, Rows_, ProdNonZero, TransNonZero, NonMidnight)
        EXEC sp_executesql @sql, N'@o NVARCHAR(200)', @o = @org;
    END TRY
    BEGIN CATCH
        INSERT INTO @Results VALUES (@org + N' [UNREADABLE: ' + ERROR_MESSAGE() + N']', -1, -1, -1, -1);
    END CATCH

    FETCH NEXT FROM orgs INTO @org, @db;
END
CLOSE orgs; DEALLOCATE orgs;

SELECT 'B1/B2 data assumptions' AS Check_,
    OrgName, Rows_,
    ProdNonZero, TransNonZero, NonMidnight,
    CASE WHEN Rows_ = -1 THEN 'FAIL - could not read the fact table'
         WHEN Rows_ = 0  THEN 'VACUOUS - no stocktake rows on this org, nothing to falsify'
         WHEN ProdNonZero > 0 OR TransNonZero > 0
              THEN 'FAIL - production/transfer events have appeared. InvUseAnalisys dropped those columns; restore them or the movement columns no longer explain Opening -> Closing.'
         ELSE 'PASS' END AS Chk_ProdTransferStillZero,
    CASE WHEN Rows_ <= 0 THEN 'VACUOUS'
         WHEN NonMidnight > 0
              THEN 'REVIEW - COUNT_DATE now carries times. The CAST added in 55/60 is now load-bearing rather than a no-op; row counts on those cards will have changed.'
         ELSE 'PASS' END AS Chk_CountDateMidnight
FROM @Results
ORDER BY OrgName;


PRINT '=== SECTION C -- alert reachability (INFO, not assertions) ===';
/*------------------------------------------------------------------------------
  Whether a banner currently fires is a property of the DATA, not of the
  deployment, so none of this is PASS/FAIL -- a silent alert usually means the
  org is healthy. It is reported because "no banner on screen" during a smoke
  test is otherwise indistinguishable from "the banner is broken".

  Measured 2026-08-03 before deployment:
      InvCountHealthAlert  FIRES on Padel (Earls Court, 6 items with no cost)
                           silent on Gloucester (1 item)
      OverviewStockAlert   silent on every org -- no org is 35 days stale, and
                           Growyze waste is falling, not spiking. Its mechanism
                           was proven separately by lowering the threshold to 30
                           days, which produced the correct 34-day message on
                           Gloucester. Gloucester crosses 35 days on 2026-08-04,
                           so it should begin firing naturally.
------------------------------------------------------------------------------*/
DECLARE @Alerts TABLE (OrgName NVARCHAR(200), LocationName NVARCHAR(400),
                       DaysSinceLastCount INT, ItemsCounted INT, ItemsNoCost INT);

DECLARE orgs2 CURSOR LOCAL FAST_FORWARD FOR
    SELECT o.OrganisationName, o.DatabaseName
    FROM core.core.Organisations o
    WHERE o.OrganisationID IN (10, 16, 18, 20, 21)
      AND o.DatabaseStatus IN (N'ACTIVE', N'FAILED')
    ORDER BY o.OrganisationID;

OPEN orgs2;
FETCH NEXT FROM orgs2 INTO @org, @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'
      SELECT @o,
             COALESCE(l.[BOTTOM_MICROSERVICE_NAME], l.[BOTTOM_LOCATION_NAME]),
             DATEDIFF(DAY, MAX(CAST(FC.COUNT_DATE AS DATE)), CAST(GETDATE() AS DATE)),
             COUNT(DISTINCT FC.INVITEM_HUB_ID),
             COUNT(DISTINCT CASE WHEN ISNULL(FC.UOM_COST,0) = 0 THEN FC.INVITEM_HUB_ID END)
      FROM ' + QUOTENAME(@db) + N'.[presentation].[F_INV_COUNTS_DAY] FC
      LEFT JOIN ' + QUOTENAME(@db) + N'.[presentation].[D_LOCATION] l ON FC.LOCATION_HUB_ID = l.BOTTOM_HUB_ID
      LEFT JOIN ' + QUOTENAME(@db) + N'.[presentation].[D_INVITEM] iv ON FC.INVITEM_HUB_ID = iv.BOTTOM_HUB_ID
      WHERE iv.[BOTTOM_SRC] = ''int_growyze001''
        AND COALESCE(l.[BOTTOM_MICROSERVICE_NAME], l.[BOTTOM_LOCATION_NAME]) <> ''Unknown''
      GROUP BY COALESCE(l.[BOTTOM_MICROSERVICE_NAME], l.[BOTTOM_LOCATION_NAME]);';

    BEGIN TRY
        INSERT INTO @Alerts (OrgName, LocationName, DaysSinceLastCount, ItemsCounted, ItemsNoCost)
        EXEC sp_executesql @sql, N'@o NVARCHAR(200)', @o = @org;
    END TRY
    BEGIN CATCH
        INSERT INTO @Alerts VALUES (@org, N'[UNREADABLE]', NULL, NULL, NULL);
    END CATCH

    FETCH NEXT FROM orgs2 INTO @org, @db;
END
CLOSE orgs2; DEALLOCATE orgs2;

SELECT 'C1 alert reachability' AS Info_,
    OrgName, LocationName, DaysSinceLastCount, ItemsCounted, ItemsNoCost,
    CASE WHEN LocationName = N'[UNREADABLE]' THEN 'could not read'
         WHEN ItemsNoCost >= 5 THEN 'InvCountHealthAlert WOULD FIRE here (missing costs)'
         ELSE 'silent' END AS CountHealthBanner,
    CASE WHEN DaysSinceLastCount > 35 THEN 'OverviewStockAlert staleness WOULD FIRE (org-wide)'
         ELSE 'silent' END AS StalenessBanner
FROM @Alerts
ORDER BY OrgName, ItemsNoCost DESC;

IF NOT EXISTS (SELECT 1 FROM @Alerts WHERE LocationName <> N'[UNREADABLE]')
    SELECT 'C1' AS Info_, 'VACUOUS - no Growyze stocktake rows on any org, so neither banner had anything to evaluate' AS Note;

PRINT '=== 88_verify_plan4 complete. Any FAIL above blocks the smoke test. ===';
