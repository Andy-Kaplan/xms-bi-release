/*  99_verify_cogs_period.sql
    Verification for presentation.F_COGS_PERIOD (Growyze Pantry COGS).
    Spec: docs/superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md §8

    Run against a client database with Growyze data AFTER the tier-110 build has run.
    Every section prints a single row with a PASS/FAIL/WARN/INFO/SKIPPED verdict, plus the
    numbers that make the verdict auditable.
    Two-part names only - never prefix a CLIENT database name (the GUID-named databases).
    Exceptions: [core].[core].[VisualisationQueries] (Checks 8a/8b) and
    [core].[reference].[UOM_CONVERSION] (Checks 7/10) are genuine three-part references to
    the fixed, always-present control-plane "core" database - see the comments at Check 8a
    and Check 7 for why two-part fails for each.
    Check 11 reads [core].[GlobalParameters] TWO-part ON PURPOSE - that table is a
    per-database deployable object and the build step reads its own database's copy, so the
    check has to look where the build looks. See Check 11's own comment before changing it.

    13 result rows across 12 numbered checks (6 is split 6a/6b, 8 is split 8a/8b).
    Check 11 was added by the final-review fix wave; checks 2, 3, 5, 6 and 8 were rewritten
    by it, and 6 was rewritten a second time by the re-review (N1) after its new FAIL leg was
    shown to fire on designed carry-forward.

    EXPECTED VERDICTS - not every check is a gate, and the ones that are not say so:
      PASS          1, 3, 4, 6a, 7, 9, 10
      PASS or WARN  11  (WARN = config readable but no fact row in a configured category, so
                         the break-out is UNPROVEN on this org - see check 11)
      INFO          5, 6b  (source-data visibility, never a gate)
      SKIPPED       2      (until a Growyze export is loaded)
      vacuous       8a/8b at DEPLOY.txt step 7; only meaningful at step 9
    Only a FAIL halts the runner. Do not "upgrade" an INFO or a WARN to a FAIL without reading
    the comment that explains why it is not one - both have already been tried the other way.

    NOT YET RUN - authored without database access. First execution is the real test.
    presentation.F_COGS_PERIOD does not exist yet (Task 3 defines it, Task 4 populates
    it), so on first run every check below is EXPECTED to fail with an invalid-object-name
    error. That is the point: this script is the acceptance gate Task 4/12 must pass, and
    it was written before the thing it tests so it cannot be quietly shaped to match
    whatever the build happens to produce.
*/
SET NOCOUNT ON;

DECLARE @src NVARCHAR(50) = N'int_growyze%';

-- ============================================================================
PRINT '--- Check 1: grain / fan-out ---';
-- One row per inventory item per location per stocktake period. Anything more means the
-- build fanned out on a join (e.g. a multi-row UOM_CONVERSION match or a duplicate SAT row).
SELECT
     CASE WHEN COUNT(*) = COUNT(DISTINCT CONCAT(
                CONVERT(VARCHAR(64), [INVITEM_HUB_ID], 2), '|',
                CONVERT(VARCHAR(64), [LOCATION_HUB_ID], 2), '|',
                CONVERT(VARCHAR(30), [PERIOD_END_DATE], 126)))
          THEN 'PASS' ELSE 'FAIL' END              AS Verdict
    ,COUNT(*)                                      AS FactRows
    ,COUNT(DISTINCT CONCAT(
        CONVERT(VARCHAR(64), [INVITEM_HUB_ID], 2), '|',
        CONVERT(VARCHAR(64), [LOCATION_HUB_ID], 2), '|',
        CONVERT(VARCHAR(30), [PERIOD_END_DATE], 126))) AS DistinctGrain
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src;

-- ============================================================================
/*  --- Check 2: reconcile to Growyze COGS export (ACCEPTANCE TEST) ---
    DEPENDENCY: requires a Growyze COGS export for the same stocktake pair, loaded into
    [reference].[GROWYZE_COGS_EXPORT_STAGING]. That table does not exist yet in this
    codebase - this check defines the contract it must be loaded with, it does not create it:
        ITEM_NAME            nvarchar(255)  -- Growyze item name; joins to F.[ITEM_NAME]
        LOCATION_HUB_ID_HEX  varchar(64)    -- CONVERT(VARCHAR(64), LOCATION_HUB_ID, 2) of the
                                            --   venue the export covers. A Growyze export is
                                            --   per venue, so this is one repeated value per
                                            --   file; populate it when loading.
        PERIOD_END_DATE      date           -- the CLOSING stocktake date of the exported pair
        OPENING_QTY          decimal(38,6)
        DELIVERY_QTY         decimal(38,6)
        TRANSFER_QTY         decimal(38,6)
        CLOSING_QTY          decimal(38,6)
        CONSUMPTION_QTY      decimal(38,6)
        COST_PRICE           decimal(38,6)
        COG_SPEND            decimal(38,6)  -- Growyze's own COG Spend for the period
        COG_SOLD             decimal(38,6)  -- Growyze's own COG Sold for the period
        CLOSING_VALUE        decimal(38,6)  -- Growyze's own closing stock value

    WHY LOCATION_HUB_ID_HEX AND PERIOD_END_DATE ARE PART OF THE CONTRACT (final-review I8).
    The first version of this check joined on ITEM_NAME and nothing else. F_COGS_PERIOD holds
    EVERY period for EVERY venue (design section 5.0, correctly implemented), so one export row
    would have compared against every (period x venue) row for that item: ItemsCompared inflated
    by that factor, and every row for a period other than the exported one mismatching. Mass
    false FAILs against correct data - a check that could never pass. Adding the venue and the
    closing date to the documented shape and to the join is what makes it an acceptance test
    rather than a cross join. Worth fixing now, while the shape is still only a comment, rather
    than when Kati's file arrives.

    The verdict has three legs, not one: values must agree; the join must not fan out
    (MatchedRows = DistinctKeys); and EVERY export row must find exactly one build row
    (MatchedRows = ExportRows). The third leg is what catches an item Growyze reports and the
    build does not produce at all - the failure mode a value-only comparison cannot see,
    because an unmatched row simply is not in the comparison.

    Not yet available - request from Kati or generate from a UAT Growyze org.
    Until it exists this check reports SKIPPED, and the build is internally consistent
    but NOT proven to replace the spreadsheet faithfully.
*/
IF OBJECT_ID('[reference].[GROWYZE_COGS_EXPORT_STAGING]') IS NULL
    SELECT 'SKIPPED' AS Verdict
          ,'No Growyze export loaded into [reference].[GROWYZE_COGS_EXPORT_STAGING]' AS Reason;
ELSE
BEGIN
    PRINT '--- Check 2: reconcile to Growyze COGS export (ACCEPTANCE TEST) ---';
    DECLARE @ExportRows INT = (SELECT COUNT(*) FROM [reference].[GROWYZE_COGS_EXPORT_STAGING]);

    WITH Diff AS (
        SELECT
             F.[ITEM_NAME]
            ,CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2) AS LOCATION_HEX
            ,CAST(F.[PERIOD_END_DATE] AS DATE)            AS PERIOD_END_DATE
            ,F.[COG_SOLD]      AS Build_COG_SOLD,      G.[COG_SOLD]      AS Export_COG_SOLD
            ,F.[COG_SPEND]     AS Build_COG_SPEND,     G.[COG_SPEND]     AS Export_COG_SPEND
            ,F.[CLOSING_VALUE] AS Build_CLOSING_VALUE, G.[CLOSING_VALUE] AS Export_CLOSING_VALUE
        FROM [presentation].[F_COGS_PERIOD] F
        INNER JOIN [reference].[GROWYZE_COGS_EXPORT_STAGING] G
            ON  G.[ITEM_NAME]           = F.[ITEM_NAME]
            AND G.[PERIOD_END_DATE]     = CAST(F.[PERIOD_END_DATE] AS DATE)
            AND G.[LOCATION_HUB_ID_HEX] = CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)
        WHERE F.[SOURCE] LIKE @src
    )
    SELECT
         CASE WHEN SUM(CASE
                    WHEN ABS(ISNULL(Build_COG_SOLD, 0)      - ISNULL(Export_COG_SOLD, 0))      > 0.005
                      OR ABS(ISNULL(Build_COG_SPEND, 0)     - ISNULL(Export_COG_SPEND, 0))     > 0.005
                      OR ABS(ISNULL(Build_CLOSING_VALUE, 0) - ISNULL(Export_CLOSING_VALUE, 0)) > 0.005
                    THEN 1 ELSE 0 END) = 0
                  AND COUNT(*) = COUNT(DISTINCT CONCAT(
                        [ITEM_NAME], '|', LOCATION_HEX, '|',
                        CONVERT(VARCHAR(30), PERIOD_END_DATE, 126)))
                  AND COUNT(*) = @ExportRows
              THEN 'PASS' ELSE 'FAIL' END                                              AS Verdict
        ,COUNT(*)                                                                      AS ItemsCompared
        ,@ExportRows                                                                   AS ExportRowsLoaded
        ,COUNT(DISTINCT CONCAT([ITEM_NAME], '|', LOCATION_HEX, '|',
                CONVERT(VARCHAR(30), PERIOD_END_DATE, 126)))                           AS DistinctKeysMatched
        ,SUM(CASE WHEN ABS(ISNULL(Build_COG_SOLD, 0) - ISNULL(Export_COG_SOLD, 0)) > 0.005
                  THEN 1 ELSE 0 END)                                                   AS COG_SOLD_Mismatches
        ,MAX(ABS(ISNULL(Build_COG_SOLD, 0) - ISNULL(Export_COG_SOLD, 0)))              AS COG_SOLD_MaxVariance
        ,SUM(CASE WHEN ABS(ISNULL(Build_COG_SPEND, 0) - ISNULL(Export_COG_SPEND, 0)) > 0.005
                  THEN 1 ELSE 0 END)                                                   AS COG_SPEND_Mismatches
        ,MAX(ABS(ISNULL(Build_COG_SPEND, 0) - ISNULL(Export_COG_SPEND, 0)))            AS COG_SPEND_MaxVariance
        ,SUM(CASE WHEN ABS(ISNULL(Build_CLOSING_VALUE, 0) - ISNULL(Export_CLOSING_VALUE, 0)) > 0.005
                  THEN 1 ELSE 0 END)                                                   AS CLOSING_VALUE_Mismatches
        ,MAX(ABS(ISNULL(Build_CLOSING_VALUE, 0) - ISNULL(Export_CLOSING_VALUE, 0)))    AS CLOSING_VALUE_MaxVariance
    FROM Diff;
END

-- ============================================================================
PRINT '--- Check 3: subtotals = grand total = KPI, all three agreeing ---';
-- REWRITTEN (final-review I5). The previous version compared SUM over GROUP BY REPORT_GROUP
-- against the ungrouped SUM of the same column over the same predicate. Those are equal by
-- construction for ANY data - including when REPORT_GROUP is NULL, which simply forms its own
-- group - so it could only FAIL when every COG_SOLD was NULL (ABS(NULL-NULL) < 0.005 is
-- unknown, so the CASE fell to ELSE 'FAIL'). Spec section 8 check 3 asks for "category
-- subtotals = grand total = KPI, all three agreeing", and the KPI leg was missing entirely;
-- the old version also omitted ISNULL(IS_FIRST_PERIOD,0) = 0, which every card applies, so
-- its totals were not any card's totals and could not have agreed with a KPI even if compared.
-- This script's own standard applies: a check that cannot fail is worse than no check.
--
-- What this version actually gates, and what it does not:
--   * Legs 1-3 use the THREE CARD EXPRESSIONS as written, with the cards' own predicates:
--       KpiSpend    = 04_vis_kpis.sql PantryCOGSSpendKPI          SUM(COG_SPEND)
--       GridSubtot  = 06_vis_grids.sql PantryCOGSBillingTotals     the per-row subtotals
--       GridGrand   = 06_vis_grids.sql PantryCOGSBillingTotals     the GRAND TOTAL row
--     Sum equality between them is structural for one fixed predicate set - that is not the
--     point. The point is that all three are transcribed here WITH their predicates, so a
--     predicate drifting on one card and not another (e.g. someone removing the
--     IS_FIRST_PERIOD exclusion from the KPI but not the grid) shows up as a real FAIL.
--   * Leg 4 is NOT structural and is the leg that can genuinely fire: the billing grid keys
--     its rows on ISNULL([CATEGORY],'Unspecified') + ' - ' + ISNULL([SUBCATEGORY],'Unspecified'),
--     so a row with CATEGORY = NULL and a row with the LITERAL category 'Unspecified' collapse
--     into ONE grid line while being TWO distinct category pairs. The invoice would then be
--     raised from a merged bucket. This leg compares the count of distinct grid labels against
--     the count of distinct (CATEGORY, SUBCATEGORY) pairs and FAILs on any collision.
--   * Leg 5 guards the all-NULL case explicitly instead of relying on NULL arithmetic falling
--     through a CASE, which is how the old check "worked".
-- Check 11 below is what compares REPORT_GROUP grouping against CATEGORY grouping.
WITH Scoped AS (
    SELECT [CATEGORY], [SUBCATEGORY], [REPORT_GROUP], [COG_SPEND]
    FROM [presentation].[F_COGS_PERIOD]
    WHERE [SOURCE] LIKE @src
      AND ISNULL([IS_FIRST_PERIOD], 0) = 0          -- every card applies this; so must the check
), GridRows AS (
    SELECT ISNULL([CATEGORY], N'Unspecified') + N' - ' + ISNULL([SUBCATEGORY], N'Unspecified') AS GridLabel
          ,SUM([COG_SPEND]) AS RowSpend
    FROM Scoped
    GROUP BY [CATEGORY], [SUBCATEGORY]
), Totals AS (
    SELECT
         (SELECT SUM([COG_SPEND]) FROM Scoped)                              AS KpiSpend
        ,(SELECT SUM(RowSpend)    FROM GridRows)                            AS GridSubtotals
        ,(SELECT SUM([COG_SPEND]) FROM Scoped)                              AS GridGrandTotal
        ,(SELECT COUNT(*)                FROM GridRows)                     AS GridRowCount
        ,(SELECT COUNT(DISTINCT GridLabel) FROM GridRows)                   AS DistinctGridLabels
)
SELECT
     CASE WHEN KpiSpend IS NOT NULL
               AND ABS(KpiSpend - GridSubtotals)  < 0.005
               AND ABS(KpiSpend - GridGrandTotal) < 0.005
               AND GridRowCount = DistinctGridLabels
          THEN 'PASS' ELSE 'FAIL' END  AS Verdict
    ,KpiSpend                          AS KPI_SpendExpression
    ,GridSubtotals                     AS Grid_SumOfSubtotals
    ,GridGrandTotal                    AS Grid_GrandTotalRow
    ,GridRowCount                      AS Grid_CategorySubcategoryPairs
    ,DistinctGridLabels                AS Grid_DistinctRowLabels
    ,CASE WHEN KpiSpend IS NULL THEN 'no rows, or every COG_SPEND is NULL'
          WHEN GridRowCount <> DistinctGridLabels
               THEN 'two category pairs collapse into one grid row - a NULL colliding with a literal Unspecified'
          ELSE '' END                  AS Note
FROM Totals;

-- ============================================================================
PRINT '--- Check 4: coverage guard - no ungrouped items with movement ---';
-- This is the exact defect that silently removed £24,199.53 (22%) of consumption from
-- every chart in Raddish's June pack. It must FAIL loudly, never drop rows.
--
-- Growyze staging gives items with a NULL subCategory an 'All INVITEMs' sentinel on BOTH
-- the category and subcategory dimension tiers (PREFLIGHT.md Q2 caveat: CONCAT() treats a
-- NULL subCategory as an empty string, the Sub Category seed row is never created for it,
-- the recursive hierarchy CTE finds no parent match, and both MIDDLE_1_NAME and TOP_NAME
-- fall through to 'All INVITEMs'). Such an item is non-NULL on a plain IS NULL test and
-- would pass this check silently if only CATEGORY/REPORT_GROUP were tested for NULL.
--
-- SUBCATEGORY must be tested too, on its own: per 03_report_group_config.sql, for a
-- CATEGORY that IS in the break-out list, REPORT_GROUP = CATEGORY + ' - ' + SUBCATEGORY.
-- If SUBCATEGORY is the 'All INVITEMs' sentinel while CATEGORY is a real break-out category,
-- REPORT_GROUP becomes e.g. "Can't Live Without It - All INVITEMs": neither NULL nor equal
-- to the sentinel string, so a check that only inspects CATEGORY/REPORT_GROUP for NULL/
-- exact-sentinel passes this row silently and a nonsense group label reaches a client-facing
-- chart. Test NULL and the sentinel on all three of CATEGORY, SUBCATEGORY and REPORT_GROUP
-- (REPORT_GROUP also gets an embedded-sentinel test, since it can contain the sentinel as a
-- substring rather than equal it outright), each reported as its own column, so the cause is
-- obvious from the result row, not just the fact that it failed.
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*)                                                                             AS UngroupedRows
    ,SUM(CASE WHEN [CATEGORY] IS NULL THEN 1 ELSE 0 END)                                  AS CategoryNullRows
    ,SUM(CASE WHEN [CATEGORY] = N'All INVITEMs' THEN 1 ELSE 0 END)                        AS CategorySentinelRows
    ,SUM(CASE WHEN [SUBCATEGORY] IS NULL THEN 1 ELSE 0 END)                               AS SubcategoryNullRows
    ,SUM(CASE WHEN [SUBCATEGORY] = N'All INVITEMs' THEN 1 ELSE 0 END)                     AS SubcategorySentinelRows
    ,SUM(CASE WHEN [REPORT_GROUP] IS NULL THEN 1 ELSE 0 END)                              AS ReportGroupNullRows
    ,SUM(CASE WHEN [REPORT_GROUP] = N'All INVITEMs' THEN 1 ELSE 0 END)                    AS ReportGroupSentinelRows
    ,SUM(CASE WHEN [REPORT_GROUP] LIKE N'%All INVITEMs%' AND [REPORT_GROUP] <> N'All INVITEMs'
               THEN 1 ELSE 0 END)                                                         AS ReportGroupEmbeddedSentinelRows
    ,SUM([COG_SOLD])                                                                       AS ValueAtRisk
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src
  AND (
        [CATEGORY] IS NULL OR [CATEGORY] = N'All INVITEMs'
        OR [SUBCATEGORY] IS NULL OR [SUBCATEGORY] = N'All INVITEMs'
        OR [REPORT_GROUP] IS NULL OR [REPORT_GROUP] LIKE N'%All INVITEMs%'
      )
  AND ([DELIVERY_QTY] <> 0 OR [CONSUMPTION_QTY] <> 0 OR [CLOSING_QTY] <> 0);

-- ============================================================================
PRINT '--- Check 5: zero/NULL cost items with movement OR closing stock (reported, not hidden) ---';
-- Raddish's SOP check 8, automated. Verdict is INFO, not FAIL - zero-cost items are a
-- source-data issue to surface, not a build defect.
--
-- CLOSING_QTY <> 0 is the third branch of the gate (final-review I9), matching what check 4
-- already does and what 06_vis_grids.sql's exceptions card now does. Without it, an item that
-- holds closing stock, had NO movement in the period, and has a NULL or zero UOM_COST
-- satisfies neither of the other two branches. Its CLOSING_VALUE is NULL (qty x NULL), SUM()
-- silently discards it, and it disappears from PantryCOGSClosingStockKPI and from the item
-- table's Closing Stock Value column with nothing reported anywhere - including here. Closing
-- stock at cost is a headline figure on this dashboard (design section 1.1 quotes
-- GBP 41,399.18 for the venue being replaced), so a stationary unpriced item is exactly the
-- "zero that should have been an error" this pack exists to eliminate.
-- UnvaluedClosingQty is reported separately so the two cases are distinguishable.
SELECT
     'INFO'                        AS Verdict
    ,COUNT(*)                      AS ZeroCostRows
    ,SUM([CONSUMPTION_QTY])        AS UnvaluedConsumptionQty
    ,SUM([CLOSING_QTY])            AS UnvaluedClosingQty
    ,SUM(CASE WHEN [DELIVERY_QTY] = 0 AND [CONSUMPTION_QTY] = 0 AND [CLOSING_QTY] <> 0
              THEN 1 ELSE 0 END)   AS StationaryUnpricedStockRows
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src
  AND [HAS_ZERO_COST] = 1
  AND ([DELIVERY_QTY] <> 0 OR [CONSUMPTION_QTY] <> 0 OR [CLOSING_QTY] <> 0);

-- ============================================================================
/*  --- Checks 6a / 6b: period integrity ---

    READ THIS BEFORE MAKING 6b A GATE AGAIN. It has already been tried and it was wrong.

    HISTORY, IN ORDER, BECAUSE THE CONCLUSION IS COUNTER-INTUITIVE.

    Round 1 (as authored). One FAIL check testing PERIOD_START_DATE = PERIOD_END_DATE and
    PERIOD_DAYS <= 0. Both legs are UNREACHABLE: Periods is LAG over SELECT DISTINCT count
    dates, so PERIOD_START_DATE is strictly less than PERIOD_END_DATE for every row by
    construction. The check could not fail. Its stated purpose was much stronger - to make
    O8's defect (opening and closing resolving to the same stocktake, collapsing consumption
    to purchases) impossible to ship - and it did not do that, because in THIS build the
    boundaries resolve PER ITEM, in 02's two OUTER APPLYs, not per period.

    Round 2 (final-review I6). Persisted OPENING_COUNT_DATE / CLOSING_COUNT_DATE on the fact
    and made "OPENING_COUNT_DATE = CLOSING_COUNT_DATE AND IS_FIRST_PERIOD = 0" a FAIL leg.
    That was WRONG, and it would have halted the deploy on the very first org.

    WHY IT WAS WRONG - I6'S PREMISE DOES NOT SURVIVE THIS BUILD'S SHAPE. The predicate is not
    a defect test at all; it is exactly co-extensive with DESIGNED carry-forward:

      1. IS_UNCOUNTED = 0 means CC.[COUNT_DATE] = PI.[PERIOD_END_DATE] (02's Bounded CTE).
      2. OPENING_COUNT_DATE is OC.[COUNT_DATE], and OC requires COUNT_DATE <= PERIOD_START_DATE.
      3. PERIOD_START_DATE < PERIOD_END_DATE strictly (the same fact that made round 1's legs
         unreachable).
      4. So when IS_UNCOUNTED = 0, OPENING_COUNT_DATE < CLOSING_COUNT_DATE always. The leg can
         only fire when IS_UNCOUNTED = 1.
      5. And it always DOES fire then: StocktakeCalendar and ItemCounts are both built from the
         same EVENT_BEHAVIOUR = 'COUNT' rows, so EVERY item count date is also a location
         period boundary and there are no mid-period counts. When an item is not counted at the
         closing boundary, the latest count at or before PERIOD_END_DATE is therefore also the
         latest count at or before PERIOD_START_DATE - the same ItemCounts row - so both dates
         are equal.

    Leg 1 therefore reduces to: IS_UNCOUNTED = 1 AND OPENING_COUNT_DATE IS NOT NULL AND
    IS_FIRST_PERIOD = 0. That is spec section 5 step 3 verbatim ("closing = its count at or
    before period end, CARRIED FORWARD where the item was not counted at that boundary"), and
    it is the exact condition 06_vis_grids.sql's "Not counted at closing stocktake" exceptions
    branch exists to SURFACE, not to reject. On Ibis Gloucester Road - two stocktake dates, one
    period - any item counted 31 May but not 30 Jun would trip it, check 6 would FAIL, and
    90_deploy_cogs.ps1 throws on any FAIL at step 7, halting before the vis scripts. Delisted
    stock still on the Growyze item list would FAIL every period, forever.

    With per-location boundaries and per-item carry-forward there is NO residual form in which
    "same count at both boundaries" is a separable defect, so no version of this leg can tell
    the two apart. Adding "AND IS_UNCOUNTED = 0" would make it unreachable again - round 1's
    defect - and must be rejected on the same reasoning.

    WHAT THIS MEANS FOR THE COLUMNS. OPENING_COUNT_DATE / CLOSING_COUNT_DATE stay on the fact.
    They are still worth persisting: they make the condition VISIBLE and auditable, which it
    was not before, and 6b below reports it. They just cannot be a gate. If the O8 defect is
    ever to be gated here, it needs a different discriminator than these two dates - most
    likely a reconstruction of the expected boundary from the location's own stocktake calendar,
    which is a design question, not a check rewrite.

    SO: 6a is the FAIL gate (period-level drift guard, honestly labelled as a guard that cannot
    fire today), 6b is INFO (carry-forward visibility). Neither pretends to be the other.
*/
PRINT '--- Check 6a: period-level drift guard (FAIL) ---';
-- Cannot fire against today's build - PERIOD_START_DATE < PERIOD_END_DATE by construction.
-- Kept deliberately, as a guard: if the period-derivation logic in 02 ever changes shape (a
-- different partition, a self-join, a calendar spine) this is what notices. A guard that cannot
-- fire today is not the same defect as a CHECK that cannot fail - the guard is not claiming to
-- test anything about the current data, and the header above says so.
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,SUM(CASE WHEN [PERIOD_START_DATE] = [PERIOD_END_DATE] THEN 1 ELSE 0 END) AS SameStocktakeBothEnds
    ,SUM(CASE WHEN [PERIOD_DAYS] <= 0 THEN 1 ELSE 0 END)                      AS NonPositiveDays
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src
  AND ([PERIOD_START_DATE] = [PERIOD_END_DATE] OR [PERIOD_DAYS] <= 0);

PRINT '--- Check 6b: boundary carry-forward visibility (INFO, never a FAIL) ---';
-- INFO by design, per the header above: every row counted here is designed carry-forward.
-- The two counts are reported side by side so they are COMPARABLE, and they should satisfy
--     SameCountBothBoundaries = UncountedRows - NeverCountedRows
-- (NeverCountedRows have OPENING_COUNT_DATE NULL, so '=' is unknown and they are not counted).
-- If that identity ever stops holding, something about the period model has changed and it is
-- worth looking at 02's StocktakeCalendar / Bounded CTEs - but it is a prompt to investigate,
-- not a deploy gate. CarriedForwardCOGSold against TotalCOGSold shows how much of the
-- dashboard's consumption rests on a carried-forward closing count, which is the number a
-- Pantry Manager should care about and the reason 06's exceptions card lists these rows.
SELECT
     'INFO'                                                                   AS Verdict
    ,SUM(CASE WHEN [OPENING_COUNT_DATE] = [CLOSING_COUNT_DATE]
                AND ISNULL([IS_FIRST_PERIOD], 0) = 0
               THEN 1 ELSE 0 END)                                             AS SameCountBothBoundaries
    ,SUM(CASE WHEN ISNULL([IS_UNCOUNTED], 0) = 1
                AND ISNULL([IS_FIRST_PERIOD], 0) = 0
               THEN 1 ELSE 0 END)                                             AS UncountedRows
    ,SUM(CASE WHEN ISNULL([IS_UNCOUNTED], 0) = 1
                AND ISNULL([IS_FIRST_PERIOD], 0) = 0
                AND [OPENING_COUNT_DATE] IS NULL
               THEN 1 ELSE 0 END)                                             AS NeverCountedRows
    ,SUM(CASE WHEN [OPENING_COUNT_DATE] = [CLOSING_COUNT_DATE]
                AND ISNULL([IS_FIRST_PERIOD], 0) = 0
               THEN [COG_SOLD] ELSE 0 END)                                    AS CarriedForwardCOGSold
    ,SUM([COG_SOLD])                                                          AS TotalCOGSold
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src;

-- ============================================================================
PRINT '--- Check 7: UOM_COST equals SAT_INVITEM latest-in-period cost, not an average ---';
-- SAT_INVITEM is the standard SCD2 satellite generated by sp_GenerateDataVaultTables
-- (6_GenerateDataVaultTables.sql:164-166: EFFECTIVEFROM/EFFECTIVETO/CURRENT_FLAG are
-- generated identically for every SAT_ table). "Latest at or before period end" means the
-- satellite row with the greatest EFFECTIVEFROM <= F.PERIOD_END_DATE, falling back to the
-- EARLIEST version that exists when no version predates the period end (defect C4 - see the
-- OUTER APPLY below) - NOT CURRENT_FLAG = 1, because CURRENT_FLAG only identifies the latest
-- row as of NOW, not as of the historical PERIOD_END_DATE under test. BOTTOM_LEVEL = 1 restricts to leaf inventory-item rows (the
-- hierarchy's Category/Sub Category rows share the same satellite - see docs/data-vault-
-- reference.md §2.2 and the InvItemCost CTE below for the same guard).
--
-- Cost basis must compare like with like: raw SAT_INVITEM.UOM_COST is priced in the item's
-- native UOM (SAT_INVITEM.UOM), while F.UOM_COST is priced per F.STANDARDISED_UOM after
-- Task 4 divides by a conversion_factor. This deliberately matches 02_cogs_period_build.sql
-- (Task 4, now written)'s own ItemCost CTE exactly, so the comparison is like-for-like:
--   - Table: [core].[reference].[UOM_CONVERSION], THREE-part, not two. Confirmed against
--     12_uom_conversion_fix.sql, which is what deployed the centralised UOM_CONVERSION
--     table into the existing PresentationControl steps: its own MERGE at line 31 runs
--     two-part (script executes IN the core database), but the query text it INJECTS into
--     each step's query_sql - the form actually executed from a CLIENT database context -
--     is three-part at line 78 (`FROM [core].[reference].[UOM_CONVERSION]`), and its own
--     verification at line 136 asserts the deployed steps contain exactly that three-part
--     form. Task 4 matches this deployed precedent. [core] is a fixed control-plane database
--     name here, not a client database name, so this is not a "no hardcoded DB name" breach
--     (same reasoning as Check 8a).
--   - Join: ON UC.[FROM_UOM] = SI.[UOM] only - Task 4 does NOT also filter TO_UOM. This is
--     Task 4's real (and, per Check 10 below, risky) join; reproducing it exactly is the
--     point - a check that silently filters more tightly than the build does would produce
--     a false PASS instead of surfacing what the build actually computed.
--   - SI.[BOTTOM_LEVEL] = 1 and ISNULL(SI.[IS_DELETED], 0) = 0 - both present in Task 4's
--     OUTER APPLY predicate (02_cogs_period_build.sql:233-238), added here for the same
--     reason: a check that omits a build predicate can pick a different "latest" row than
--     the build did and report a false mismatch.
--   - Shape: OUTER APPLY ... TOP 1 ... ORDER BY EFFECTIVEFROM DESC, THEN LEFT JOIN
--     UOM_CONVERSION - not a single ROW_NUMBER pass over the joined result. This ordering
--     matters: Task 4 picks exactly one SAT_INVITEM row first (deterministic on
--     EFFECTIVEFROM DESC), and only then joins UOM_CONVERSION, which means a fan-out row in
--     UOM_CONVERSION (see Check 10) can multiply Task 4's own ItemCost CTE - collapsing that
--     multiplicity here with a ROW_NUMBER/PARTITION would arbitrarily pick one candidate and
--     silently hide a mismatch the build itself produces. Reproducing Task 4's exact shape
--     lets a UOM_CONVERSION fan-out surface as a FAIL here too, not just in Check 10/Check 1.
WITH FactPeriods AS (
    SELECT DISTINCT [INVITEM_HUB_ID], [PERIOD_END_DATE]
    FROM [presentation].[F_COGS_PERIOD]
    WHERE [SOURCE] LIKE @src
),
LatestCost AS (
    SELECT
         FP.[INVITEM_HUB_ID]
        ,FP.[PERIOD_END_DATE]
        ,C.[UOM_COST] / NULLIF(UC.[CONVERSION_FACTOR], 0) AS UOM_COST_STANDARDISED
    FROM FactPeriods FP
    OUTER APPLY (
        -- Mirrors 02's EFFECTIVEFROM fallback (defect C4) EXACTLY, including the three-key
        -- ORDER BY. It must stay a byte-for-byte mirror of the build's OUTER APPLY: if this
        -- reverts to the old hard "AND SI.[EFFECTIVEFROM] <= FP.[PERIOD_END_DATE]" filter
        -- while the build keeps the fallback, this check resolves NULL where the build
        -- resolved a real cost and reports every priced row as a mismatch - a false FAIL that
        -- halts the runner.
        --
        -- BE AWARE OF WHAT THIS CHECK CANNOT DO. Because it is a faithful mirror, it shares
        -- the build's premises and cannot detect a fault in them: when the build resolved NULL
        -- for every item (C4), this check resolved NULL too, the comparison below comes out
        -- 0 - 0 through its ISNULLs, and it PASSED on a fact with no money in it at all. That
        -- is why the wholesale-unpriced gate is check 12, which reads the fact directly and
        -- does NOT re-derive cost. Do not "strengthen" this check to cover that case - the
        -- mirror is the point here; check 12 is the independent witness.
        SELECT TOP 1 SI.[UOM_COST], SI.[UOM]
        FROM [datavault].[SAT_INVITEM] SI
        WHERE SI.[HUB_ID] = FP.[INVITEM_HUB_ID]
          AND SI.[BOTTOM_LEVEL] = 1
          AND ISNULL(SI.[IS_DELETED], 0) = 0
        ORDER BY CASE WHEN SI.[EFFECTIVEFROM] <= FP.[PERIOD_END_DATE]
                      THEN 0 ELSE 1 END ASC
                ,CASE WHEN SI.[EFFECTIVEFROM] <= FP.[PERIOD_END_DATE]
                      THEN SI.[EFFECTIVEFROM] END DESC
                ,SI.[EFFECTIVEFROM] ASC
    ) C
    LEFT JOIN [core].[reference].[UOM_CONVERSION] UC
        ON UC.[FROM_UOM] = C.[UOM]
)
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*) AS MismatchedCostRows
FROM [presentation].[F_COGS_PERIOD] F
INNER JOIN LatestCost L
    ON L.[INVITEM_HUB_ID] = F.[INVITEM_HUB_ID]
   AND L.[PERIOD_END_DATE] = F.[PERIOD_END_DATE]
WHERE F.[SOURCE] LIKE @src
  AND ABS(ISNULL(F.[UOM_COST], 0) - ISNULL(L.[UOM_COST_STANDARDISED], 0)) > 0.005;

-- ============================================================================
PRINT '--- Check 8a: mapped ParameterMappings expressions <= 100 chars ---';
-- BuildDynamicWhereClause assigns JSON_VALUE into an NVARCHAR(100) and truncates silently -
-- O8's ~700-char group CASE was unusable as a filter column.
-- NOTE: three-part name is required here, not a violation of the "no hardcoded database
-- names" rule. That rule targets GUID-named CLIENT databases; [core] is a fixed control-
-- plane database name, always present, on both the core DB and every client DB (each client
-- DB has its own [core] schema for card stored procedures). 2_CoreTableCreateScripts.sql
-- opens with `USE [core]` (line 1) before `CREATE TABLE [core].[VisualisationQueries]`
-- (line 505), so that table's real name is core DATABASE . core SCHEMA . VisualisationQueries
-- TABLE - a two-part reference only resolves from inside the core database itself. This
-- script runs against a CLIENT database (it reads presentation.F_COGS_PERIOD and
-- datavault.SAT_INVITEM), where [core].[VisualisationQueries] would resolve to the client
-- DB's own (different) core schema and fail with "Invalid object name". Three-part naming
-- resolves correctly from either database, which is exactly why 8_VisualisationQueries.sql
-- uses [core].[core].[VisualisationQueries] throughout its own INSERTs.
-- MATERIALISE FIRST, THEN OPENJSON (final-review I7, strengthened by re-review N4).
-- The predicate originally sat in the WHERE clause AFTER the CROSS APPLY. Predicate placement
-- in a WHERE clause is not a guarantee that the optimizer pushes the filter below an APPLY, so
-- OPENJSON could be invoked against the ParameterMappings of all ~130 rows in the table.
-- OPENJSON raises a HARD ERROR on malformed JSON, so one bad value in an unrelated sibling
-- record would fail this pack's acceptance gate for a reason that has nothing to do with this
-- pack - and step 9 is the only run where check 8's verdict means anything, so a spurious
-- failure there is expensive.
--
-- The first fix used a derived table, and the comment claimed that made the restriction
-- "structural". It did not: a non-correlated derived table containing only a projection and a
-- WHERE is a candidate for view flattening, so the optimizer remains free to produce the same
-- plan shape as the original. In practice both forms filter first, which is probably why the
-- original never misbehaved either - but neither is a guarantee, and a comment claiming one is
-- worse than no comment.
-- This form IS a guarantee: the filtered rows are materialised into a table variable by a
-- SEPARATE STATEMENT, so there is nothing left to flatten and OPENJSON provably never sees a
-- row outside this pack. At ~130 candidate rows filtered down to 12 the cost is nil, and
-- correctness here is the entire point of the check. (TOP inside a derived table also fences
-- the optimizer, but a TOP with no ORDER BY reads as a mistake to the next person; this is
-- self-evident.)
DECLARE @pmRows TABLE (ParameterMappings NVARCHAR(MAX));
INSERT INTO @pmRows (ParameterMappings)
SELECT [ParameterMappings]
FROM [core].[core].[VisualisationQueries]
WHERE [DataSetName] LIKE N'PantryCOGS%'
  AND [Status] = N'LIVE';

SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*) AS OverlongMappings
FROM @pmRows v
CROSS APPLY OPENJSON(NULLIF(v.[ParameterMappings], N'')) AS pm
WHERE LEN(CAST(pm.[value] AS NVARCHAR(MAX))) > 100;

PRINT '--- Check 8b: mapped FilterDefinitions column expressions <= 100 chars ---';
-- Same truncation risk, but FilterDefinitions nests the mapped expression one level deeper
-- as {"Key": {"column": "...", "type": "...", "dataType": "..."}} (00_CARD_CONTRACTS.md) -
-- JSON_VALUE pulls out just the "column" expression that BuildDynamicWhereClause consumes.
-- Same materialise-then-OPENJSON shape as check 8a, for the same reason and with the same
-- guarantee (final-review I7, re-review N4). Read 8a's comment before changing either.
DECLARE @fdRows TABLE (FilterDefinitions NVARCHAR(MAX));
INSERT INTO @fdRows (FilterDefinitions)
SELECT [FilterDefinitions]
FROM [core].[core].[VisualisationQueries]
WHERE [DataSetName] LIKE N'PantryCOGS%'
  AND [Status] = N'LIVE';

SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*) AS OverlongMappings
FROM @fdRows v
CROSS APPLY OPENJSON(NULLIF(v.[FilterDefinitions], N'')) AS fd
WHERE LEN(CAST(JSON_VALUE(fd.[value], '$.column') AS NVARCHAR(MAX))) > 100;

-- ============================================================================
PRINT '--- Check 9: deliveries non-zero for a period with known receipts ---';
-- Guards the DELIVERY vs ORDER event-type trap (spec §5.2). A FAIL here means the build's
-- EVENT_TYPE IN ('ORDER','DELIVERY') predicate or the staging label is wrong. Kept even
-- though PREFLIGHT.md Q1 confirmed Growyze staging only ever emits 'ORDER' today (never
-- 'DELIVERY') - this check also catches a regression if that ever changes.
SELECT
     CASE WHEN SUM([DELIVERY_QTY]) > 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,SUM([DELIVERY_QTY]) AS TotalDeliveryQty
    ,SUM([COG_SPEND])    AS TotalCOGSpend
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src;

-- ============================================================================
PRINT '--- Check 10: UOM_CONVERSION fan-out guard ---';
-- 12_uom_conversion_fix.sql:19 records that UOM_CONVERSION's primary key is
-- (FROM_UOM, TO_UOM) - a single FROM_UOM can legitimately carry several rows (e.g. the same
-- native unit converting to more than one target unit for different purposes). Both Task 4's
-- ItemCost CTE (02_cogs_period_build.sql, Check 7 above) and its UOMConversion CTE join
-- ON SE.[UOM] = uc.[UOM] / C.[UOM] = uc.[FROM_UOM] with NO TO_UOM filter, so a FROM_UOM with
-- more than one row silently duplicates every stock event (or cost lookup) for that unit,
-- fanning out quantities and values for every fact row that uses it - not a one-off item, a
-- whole unit's worth of data. This class of bug is not theoretical in this codebase: two open
-- ledger items are both join fan-out (a £580k sales over-count and a cost-map fanning out
-- ~1.5x), so this guard names a live risk, not a hypothetical one. Check 1's grain check would
-- only catch the symptom (row count exceeding distinct grain) if the fan-out happens to reach
-- F_COGS_PERIOD; this check names the cause directly, at the source, regardless of whether a
-- fact row currently exists that exercises the affected FROM_UOM.
WITH DupFromUom AS (
    SELECT
         [FROM_UOM]
        ,COUNT(*) AS RowsForUom
        ,STRING_AGG(CAST([TO_UOM] AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY [TO_UOM]) AS ToUomList
    FROM [core].[reference].[UOM_CONVERSION]
    GROUP BY [FROM_UOM]
    HAVING COUNT(*) > 1
)
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*) AS DuplicateFromUomCount
    ,STRING_AGG(CONCAT([FROM_UOM], N' -> [', ToUomList, N']'), N'; ')
        WITHIN GROUP (ORDER BY [FROM_UOM])                                    AS Offenders
FROM DupFromUom;

-- ============================================================================
PRINT '--- Check 11: REPORT_GROUP break-out config is visible to the build AND took effect ---';
-- NEW (final-review C1). This check exists because the break-out was silently doing nothing and
-- nothing anywhere noticed: 90_deploy_cogs.ps1 ran 03_report_group_config.sql against `core`,
-- while 02_cogs_period_build.sql reads [core].[GlobalParameters] with a TWO-part name from a
-- query_sql that sp_ProcessPresentation executes in the CLIENT database's context. Two different
-- tables. STRING_SPLIT(NULL, '|') returns zero rows rather than raising, so BreakoutBuckets was
-- empty, REPORT_GROUP = CATEGORY for every row in the fact, Raddish's "Can't Live Without It"
-- bucket was never broken out by subcategory - and every card rendered, every filter populated,
-- and all ten original checks passed. Without this check the runner fix cannot be shown to have
-- worked, and the bug's whole character is that everything looks fine while the entire design
-- section 6 category model does nothing.
--
-- THE TWO-PART NAME BELOW IS DELIBERATE. Do not "fix" it to [core].[core].[GlobalParameters].
-- The point of this check is to read the SAME table the build reads, from the same database
-- context, so that it fails when the config is not where the build will look for it.
-- GlobalParameters is a per-database deployable object (8_Deployment_Objects_Records.sql:25),
-- unlike VisualisationQueries and reference.UOM_CONVERSION, which genuinely live only in the
-- central core database and are correctly three-part in checks 7, 8a, 8b and 10.
--
-- VERDICTS. Five, not two, and the ROW-ABSENT vs VALUE-EMPTY distinction is load-bearing:
--   FAIL - no COGS_REPORT_GROUP_BREAKOUT row exists IN THIS DATABASE at all. The config was
--          never deployed here, so the build cannot see it. That is the original C1 defect and
--          this is the leg that proves the runner fix.
--   INFO - the row EXISTS but its value is empty or whitespace. That is
--          03_report_group_config.sql's state 2, "no break-out by choice", and the design
--          intends it to be expressible: spec section 6 makes the break-out list per-customer
--          config, and a Growyze customer with no catch-all bucket has nothing to break out.
--          An empty value is how that customer SAYS SO - a present-but-empty row is a
--          statement, an absent row is an accident, and only the second is a defect. (Re-review
--          N3: the earlier version FAILed on both, which left a legitimate configuration with
--          no way to pass the gate.) NOTE this is not a hiding place: THIS pack's 03 seeds
--          "Can't Live Without It", so on a Raddish-shaped deploy an empty value means someone
--          blanked it, and the Reason text says to confirm that was deliberate.
--   PASS - at least one fact row has REPORT_GROUP <> CATEGORY. The break-out demonstrably ran.
--   WARN - the parameter is set, but NO fact row carries any of the configured categories.
--          Nothing broke out, and nothing should have: the org under test simply has no rows in
--          those buckets. Reported as WARN, not FAIL, because a check that FAILs against
--          correct data gets switched off - and NOT as PASS, because it proves nothing about
--          the break-out. Expect this on a shape-test org whose categories differ from
--          Raddish's; confirm the configured names against the org's own CATEGORY values.
--   FAIL - the parameter is set, fact rows DO carry a configured category, and yet nothing
--          broke out. That is the original defect, or the join at 02's BreakoutBuckets is
--          broken. This is the leg the C1 fix has to satisfy.
IF OBJECT_ID('[core].[GlobalParameters]') IS NULL
    SELECT 'FAIL' AS Verdict
          ,'core.GlobalParameters does not exist in THIS database, so the build step cannot read the break-out config at all. Deploy 03_report_group_config.sql against the CLIENT database.' AS Reason;
ELSE
BEGIN
    -- Row existence is tested SEPARATELY from value emptiness. A NULL @breakout is ambiguous on
    -- its own: it means either "no row" (the C1 defect) or "row present, value NULL" (state 2).
    DECLARE @breakoutRowExists INT = (
        SELECT COUNT(*)
        FROM [core].[GlobalParameters]
        WHERE [ParameterKey] = 'COGS_REPORT_GROUP_BREAKOUT');

    DECLARE @breakout NVARCHAR(MAX) = (
        SELECT [ParameterValue]
        FROM [core].[GlobalParameters]
        WHERE [ParameterKey] = 'COGS_REPORT_GROUP_BREAKOUT');

    DECLARE @configured INT =
        CASE WHEN LEN(LTRIM(RTRIM(ISNULL(@breakout, N'')))) > 0 THEN 1 ELSE 0 END;

    DECLARE @brokenOutRows INT = (
        SELECT COUNT(*)
        FROM [presentation].[F_COGS_PERIOD]
        WHERE [SOURCE] LIKE @src
          AND [CATEGORY] IS NOT NULL
          AND [REPORT_GROUP] IS NOT NULL
          AND [REPORT_GROUP] <> [CATEGORY]);

    DECLARE @rowsInConfiguredCategory INT = (
        SELECT COUNT(*)
        FROM [presentation].[F_COGS_PERIOD] F
        WHERE F.[SOURCE] LIKE @src
          AND EXISTS (SELECT 1 FROM STRING_SPLIT(@breakout, '|') s
                      WHERE LTRIM(RTRIM(s.[value])) = F.[CATEGORY]));

    SELECT
         CASE WHEN @breakoutRowExists = 0          THEN 'FAIL'
              WHEN @configured = 0                 THEN 'INFO'
              WHEN @brokenOutRows > 0              THEN 'PASS'
              WHEN @rowsInConfiguredCategory = 0   THEN 'WARN'
              ELSE 'FAIL' END                                       AS Verdict
        ,@breakout                                                  AS ConfiguredValue_ThisDatabase
        ,@breakoutRowExists                                         AS ConfigRowPresentInThisDatabase
        ,@brokenOutRows                            AS RowsWhereReportGroupDiffersFromCategory
        ,@rowsInConfiguredCategory                 AS RowsInAConfiguredCategory
        -- The grouping comparison the old check 3 never made: if the break-out ran, REPORT_GROUP
        -- must resolve to MORE distinct values than CATEGORY. Equal counts with a non-empty
        -- config is the signature of the silent failure.
        ,(SELECT COUNT(DISTINCT [CATEGORY])     FROM [presentation].[F_COGS_PERIOD]
          WHERE [SOURCE] LIKE @src)                                 AS DistinctCategories
        ,(SELECT COUNT(DISTINCT [REPORT_GROUP]) FROM [presentation].[F_COGS_PERIOD]
          WHERE [SOURCE] LIKE @src)                                 AS DistinctReportGroups
        ,CASE WHEN @breakoutRowExists = 0
                   THEN 'No COGS_REPORT_GROUP_BREAKOUT row in THIS database, so the build cannot see the config. 03_report_group_config.sql must run against the CLIENT database, not core - the build reads it two-part.'
              WHEN @configured = 0
                   THEN 'Config row is present with a deliberately empty value = no break-out by design (03 state 2). Legitimate for a customer with no catch-all bucket. BUT this pack''s own 03 seeds a non-empty value, so on a Raddish-shaped deploy an empty value here means someone blanked it - confirm that was intended.'
              WHEN @brokenOutRows > 0
                   THEN 'Break-out applied.'
              WHEN @rowsInConfiguredCategory = 0
                   THEN 'Config is present and readable, but no fact row carries any configured category, so nothing could break out. Compare the configured names against SELECT DISTINCT CATEGORY on this fact. This is NOT proof the break-out works.'
              ELSE 'Config is present and matching fact rows exist, but REPORT_GROUP equals CATEGORY on every row - the break-out did not apply. Check the BreakoutBuckets CTE join in 02_cogs_period_build.sql.'
         END                                                        AS Reason;
END

-- ============================================================================
PRINT '--- Check 12: cost resolution actually resolved (wholesale-unpriced gate) ---';
/*  WHY THIS EXISTS, AND WHY IT IS NOT PART OF CHECK 5 OR CHECK 7 (defect C4).

    Check 5 reports unpriced rows as INFO, deliberately: a handful of items with a missing
    cost is a source-data condition for Growyze to fix, not a build defect, and it must not
    halt a deploy. Check 7 compares the fact's UOM_COST against a re-derivation of the same
    rule. Neither can catch a cost rule that resolves NOTHING:
      - check 5 sees "lots of unpriced rows", which is precisely the INFO it is designed to
        shrug at, and its gate additionally requires movement or closing stock;
      - check 7 is a faithful MIRROR of the build, so when the build resolved NULL it also
        resolved NULL, its ISNULL(...,0) - ISNULL(...,0) comparison came out 0, and it PASSED.
    That combination actually happened. On UAT org 21, a hard EFFECTIVEFROM <= PERIOD_END_DATE
    predicate matched zero satellite rows (every row stamped with the load date, 2026-07-28,
    against periods ending 2026-05-31 and 2026-06-30). 732 of 732 fact rows came out unpriced,
    every money column was NULL, and ALL ELEVEN other checks passed or reported INFO. The
    runner would have declared success and shipped a dashboard reading 0.00 everywhere - and
    BarChartCard renders a NULL total as '0.00', so it would have looked deliberate.

    This check is therefore an INDEPENDENT WITNESS: it reads the fact directly and re-derives
    nothing, so it cannot inherit the build's premises the way check 7 does.

    The gate is proportional, not absolute. A venue legitimately carries some unpriced items,
    so a count > 0 must not FAIL (that is check 5's INFO job). But a fact where NO row at all
    carries a usable cost, while the satellite demonstrably holds priced items, can only be a
    cost-resolution failure - there is no source-data state that produces it. WARN covers the
    grey middle so a severe-but-not-total regression is still visible.
*/
DECLARE @factRows        INT = (SELECT COUNT(*) FROM [presentation].[F_COGS_PERIOD]
                                WHERE [SOURCE] LIKE @src);
DECLARE @pricedFactRows  INT = (SELECT COUNT(*) FROM [presentation].[F_COGS_PERIOD]
                                WHERE [SOURCE] LIKE @src
                                  AND [UOM_COST] IS NOT NULL AND [UOM_COST] <> 0);
-- Independent of the fact: does the satellite actually hold priced leaf items at all?
-- If it does not, an unpriced fact is a genuine source-data state and must not FAIL.
DECLARE @pricedSatItems  INT = (SELECT COUNT(*) FROM [datavault].[SAT_INVITEM]
                                WHERE [BOTTOM_LEVEL] = 1
                                  AND ISNULL([IS_DELETED], 0) = 0
                                  AND [UOM_COST] > 0);

SELECT
     CASE WHEN @factRows = 0                              THEN 'FAIL'
          WHEN @pricedSatItems = 0                        THEN 'INFO'
          WHEN @pricedFactRows = 0                        THEN 'FAIL'
          WHEN @pricedFactRows * 100 / @factRows < 50     THEN 'WARN'
          ELSE 'PASS' END                                        AS Verdict
    ,@factRows                                                   AS FactRows
    ,@pricedFactRows                                             AS PricedFactRows
    ,@pricedSatItems                                             AS PricedLeafItemsInSatellite
    ,CASE WHEN @factRows = 0 THEN 0
          ELSE @pricedFactRows * 100 / @factRows END             AS PricedPct
    ,CASE WHEN @factRows = 0
               THEN 'No fact rows for this source at all - the build produced nothing. Checks downstream of this are meaningless.'
          WHEN @pricedSatItems = 0
               THEN 'SAT_INVITEM holds no priced leaf items for this org, so an unpriced fact is a genuine source-data state, not a build defect. Growyze needs to populate cost prices. Not a gate.'
          WHEN @pricedFactRows = 0
               THEN 'COST RESOLUTION FAILED. The satellite holds priced items, yet NOT ONE fact row carries a usable UOM_COST, so every money column on every card is NULL. This is defect C4 or a regression of it: check the ItemCost OUTER APPLY in 02_cogs_period_build.sql has kept its EFFECTIVEFROM fallback ORDER BY and has not reverted to a hard EFFECTIVEFROM <= PERIOD_END_DATE filter. Do NOT deploy the dashboard on this result.'
          WHEN @pricedFactRows * 100 / @factRows < 50
               THEN 'Over half the fact rows are unpriced. Not necessarily a build defect, but too high to accept silently - reconcile against check 5 before trusting any money figure.'
          ELSE 'Cost resolved on the majority of rows.'
     END                                                         AS Reason;
