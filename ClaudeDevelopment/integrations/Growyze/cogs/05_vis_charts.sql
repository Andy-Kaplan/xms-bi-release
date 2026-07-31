/*  Pantry COGS Dashboard - chart cards (Task 7).

    5 records into [core].[core].[VisualisationQueries] (natural key: DataSetName,
    VisualizationType, Status). Three-part naming is deliberate: 2_CoreTableCreateScripts.sql
    opens `USE [core]`, so VisualisationQueries lives in the core DATABASE, core SCHEMA.
    These scripts run from a client database context, and client DBs have their own `core`
    schema, so two-part naming silently resolves to the wrong place (Task 2 finding,
    propagated to Tasks 6-9). 8_VisualisationQueries.sql uses three-part throughout.

    Every query: scoped to `F.[SOURCE] LIKE 'int_growyze%'`, excludes
    `ISNULL(F.[IS_FIRST_PERIOD], 0) = 0` (a venue's first-ever stocktake has no opening
    baseline, so its consumption figure is meaningless), and injects `@FilterClause` after
    `WHERE 1=1` with the base fact table aliased `F` throughout - including inside every
    header-result-set subquery - so the FilterClause alias contract holds everywhere it is
    spliced in (00_CARD_CONTRACTS.md: a mismatched alias throws at render time).

    Column shapes for result set 1 follow 00_CARD_CONTRACTS.md's live examples
    (PieChartCard / BarChartCard), not the brief's placeholder Label1/Value1 names.
    No BarChartCard here ever returns NULL AS TotalValue - every header wraps its
    TotalValue subquery in ISNULL(..., 0) so an empty result set renders a real zero,
    not a silently discarded NULL that the card would still show as "0.00" but without
    it being clear the underlying query returned nothing.

    Filter keys (identical across Tasks 6-9, per the shared spec decision, with ONE
    deliberate exception documented at record 2 below - PantryCOGSPeriodComparison omits
    PantryCOGSPeriods on purpose, because it plots three months and the period predicate
    would collapse it to one; see the block comment above its @fd):
      PantryCOGSVenues     -> F.[LOCATION_HUB_ID]
      PantryCOGSPeriods    -> F.[PERIOD_LABEL]
      PantryCOGSCategories -> ISNULL(F.[REPORT_GROUP], N'(no category)')
                             (the ISNULL wrapper matches 07's filter list, which lists
                             uncategorised rows as '(no category)' instead of dropping them
                             - final-review M15; change one side and you must change all four)
    Carried in both ParameterMappings (flat, so @FilterClause substitution has real columns
    to bind to - never left as '{}', which O8 proved silently discards every filter) and
    FilterDefinitions (nested column/type/dataType shape, per the contract convention).
*/

-- ============================================================
-- 1. PantryCOGSConsumptionMix - PieChartCard
-- ============================================================
DECLARE @q NVARCHAR(MAX) = N'
SELECT
     F.[REPORT_GROUP]           AS Label
    ,SUM(F.[COG_SOLD])          AS Value
    ,F.[REPORT_GROUP]           AS Id
    ,''linear''                 AS Curve
    ,''total''                  AS Stack
    ,''true''                   AS Area
    ,''ascending''              AS StackOrder
    ,''false''                  AS ShowMark
    ,''COG Sold''               AS LegendLabel
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause
GROUP BY F.[REPORT_GROUP]
HAVING SUM(F.[COG_SOLD]) > 0

SELECT
     ''Consumption Mix''  AS Title
    ,''''                 AS Description
    ,NULL                 AS Trend
    ,NULL                 AS Chip
    -- The displayed total must cover EXACTLY the slices that are drawn (final-review I10).
    -- The slice query above ends in HAVING SUM(F.[COG_SOLD]) > 0, so any report group whose
    -- COG Sold is zero or negative is absent from the pie. This total previously summed the
    -- whole filtered scope with no HAVING, so those groups were excluded from the slices but
    -- still counted in the figure printed beside them, and the slices did not add up to it.
    -- Negative consumption is not hypothetical on this fact - it has its own column
    -- (IS_NEGATIVE_COGS), its own exceptions branch and its own spec decision (D3, flag
    -- only). This is the same numerator/denominator coverage mismatch that produced the
    -- spreadsheet''s 142.8% bar, which is why the sibling card
    -- PantryCOGSTopItemsByCategory feeds both its legs from one Scoped CTE. Repeating the
    -- GROUP BY / HAVING here is the equivalent for a pie: sum the groups, not the rows.
    ,(SELECT SUM(G.GroupSold) FROM (
        SELECT SUM(F.[COG_SOLD]) AS GroupSold
        FROM [presentation].[F_COGS_PERIOD] F
        WHERE 1=1
          AND F.[SOURCE] LIKE ''int_growyze%''
          AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
          @FilterClause
        GROUP BY F.[REPORT_GROUP]
        HAVING SUM(F.[COG_SOLD]) > 0
      ) G)              AS PiePrimaryText
    ,''Total COG Sold''   AS PieSecondaryText;
';

DECLARE @pm NVARCHAR(MAX) = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

DECLARE @fd NVARCHAR(MAX) = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

DECLARE @od NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSConsumptionMix', N'PieChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'COG Sold broken out by report-group category, for the selected venues and period.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSConsumptionMix', N'PieChartCard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'COG Sold broken out by report-group category, for the selected venues and period.',
     NULL, NULL, GETDATE(), GETDATE());
GO

-- ============================================================
-- 2. PantryCOGSPeriodComparison - BarChartCard, 3 series
--    (Explicit SeriesLabel/SeriesLabelSort added: the BarChartCard contract's only live
--    example is single-series, so a series column does not exist by default - it must be
--    added deliberately per 00_CARD_CONTRACTS.md's guidance for multi-series cards.)
--    @anchor is derived from the FILTERED set (@FilterClause applied) - not the whole fact
--    table - so a venue that stocktakes on a different cadence than whichever venue holds
--    the org-wide latest period does not get anchored on a month it has no data in and
--    rendered as a false collapse. A scalar variable (not a CTE) carries the anchor across
--    both result-set statements, since a CTE's scope does not survive past its own statement.
-- ============================================================
DECLARE @q NVARCHAR(MAX) = N'
DECLARE @anchor DATE;

SELECT @anchor = MAX(F.[PERIOD_MONTH])
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause;

SELECT
     F.[REPORT_GROUP]                                          AS BarLabel
    ,DENSE_RANK() OVER (ORDER BY F.[REPORT_GROUP])              AS BarLabelSort
    -- Label the MONTH, not a day (final-review M18). CONVERT(..., 3) rendered
    -- 2026-06-01 as ''01/06/26'', which reads as 1 June on a chart whose entire point is
    -- month-over-month comparison. FORMAT gives ''Jun 26''.
    ,FORMAT(F.[PERIOD_MONTH], ''MMM yy'')                        AS SeriesLabel
    ,DENSE_RANK() OVER (ORDER BY F.[PERIOD_MONTH])               AS SeriesLabelSort
    ,SUM(F.[COG_SOLD])                                          AS BarValue
    ,DENSE_RANK() OVER (ORDER BY SUM(F.[COG_SOLD]))              AS BarValueSort
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  AND F.[PERIOD_MONTH] >= DATEADD(MONTH, -2, @anchor)
  @FilterClause
GROUP BY F.[REPORT_GROUP], F.[PERIOD_MONTH]
ORDER BY F.[PERIOD_MONTH], F.[REPORT_GROUP]

SELECT
     ''Category''    AS XAxisLabel
    ,''COG Sold''    AS YAxisLabel
    ,''Spend Trend by Category'' AS Title
    ,''COG Sold by category, for the latest month and the two before it'' AS Description
    ,NULL            AS Trend
    ,ISNULL((SELECT SUM(F.[COG_SOLD]) FROM [presentation].[F_COGS_PERIOD] F
             WHERE 1=1
               AND F.[SOURCE] LIKE ''int_growyze%''
               AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
               AND F.[PERIOD_MONTH] >= DATEADD(MONTH, -2, @anchor)
               @FilterClause), 0) AS TotalValue
    ,NULL            AS Chip;
';

DECLARE @pm NVARCHAR(MAX) = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

-- ------------------------------------------------------------------------------------
-- THE ONE INTENTIONAL EXCEPTION TO THE PACK-WIDE IDENTICAL-FilterDefinitions RULE.
-- "PantryCOGSPeriods" is DELIBERATELY ABSENT from this card, and only this card
-- (final-review C3). Do not add it back in a consistency sweep.
--
-- Every other card carries all three filter keys. This card must not, because it
-- plots THREE months. Its data query already narrows the window itself:
--     AND F.[PERIOD_MONTH] >= DATEADD(MONTH, -2, @anchor)
-- If the period selection ALSO reached @FilterClause, the two predicates would
-- intersect: PERIOD_LABEL identifies a single stocktake pair, so exactly one
-- PERIOD_MONTH survives, and the two earlier months are removed before the window
-- can include them. That is the DEFAULT state, not an edge case - 07_vis_filters.sql
-- orders periods newest-first precisely so the frontend's default selection lands on
-- the latest period. The card would render one bar per category, titled "Spend Trend
-- by Category" and described as "the latest month and the two before it": a chart
-- asserting a trend from data that cannot show one, with no error. That is the same
-- failure as the spreadsheet tab this card replaces (a ~12% fall shown while
-- consumption rose ~14%, design section 1).
--
-- WHAT DROPPING THE KEY ACTUALLY DOES, stated precisely, because the obvious reading
-- is wrong. BuildDynamicWhereClause builds ONE @FilterClause string and every
-- @FilterClause token in this query is replaced with that same string
-- (docs/presentation-and-visualisation.md section 5.4: it iterates the keys in
-- @Filters, looks each one up in @FilterDefinitions to get a column, and appends
-- AND {column} IN (...)). A selection whose key has no FilterDefinitions entry
-- produces no clause AT ALL - so removing the key removes the period predicate from
-- all THREE injection sites, including the @anchor assignment. It is not possible to
-- have the selection reach the anchor but not the data query: there is one clause and
-- one substitution.
--
-- So this card now always shows THE LATEST THREE MONTHS within the selected venues and
-- categories, whatever period is picked. That is exactly what its Title and Description
-- claim ("the latest month and the two before it"), and it is the honest reading of a
-- fixed three-month trend card. The venue and category filters still apply to all three
-- sites, so the anchor is still derived from the FILTERED set - which is the earlier fix
-- that stops a venue on a different stocktake cadence being anchored on a month it has
-- no data in. Do not undo that.
--
-- IF the requirement later becomes "let the user choose WHICH three months", that needs a
-- different mechanism, not this key back: either drive the anchor from the
-- ParameterMappings StartDate/EndDate slots (which are separate from @Filters), or give
-- the card its own month picker. Both are design changes.
--
-- 08_report_db_config.sql's DashboardGridFilter rows are unaffected: the widget still
-- exists and still drives the other 11 cards; this one card just stops consuming the
-- key. A FilterDefinitions key with no widget is silently dead (design section 7.2 #1);
-- a widget with one fewer consumer is not.
-- ------------------------------------------------------------------------------------
DECLARE @fd NVARCHAR(MAX) = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

DECLARE @od NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSPeriodComparison', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'COG Sold by report-group category, compared across the latest month and the two before it. Reads all three months live from the fact table, so history cannot be lost the way a pasted-literal spreadsheet tab loses it.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSPeriodComparison', N'BarChartCard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'COG Sold by report-group category, compared across the latest month and the two before it. Reads all three months live from the fact table, so history cannot be lost the way a pasted-literal spreadsheet tab loses it.',
     NULL, NULL, GETDATE(), GETDATE());
GO

-- ============================================================
-- 3. PantryCOGSTopItemsByCategory - BarChartCard, 2 series
--    Replaces a tab that showed 142.8% of category spend because its numerator and
--    denominator were computed over different row sets. Here, Scoped is the single
--    filtered row set both CategoryTotals (denominator) and Ranked (numerator) derive
--    from - so numerator and denominator are always coverage-matched. Both percentage
--    expressions are NULLIF-guarded so a zero-consumption category cannot divide by zero.
--    Long/series format (one row per item per series) mirrors the shape used for
--    PantryCOGSPeriodComparison above, for consistency across the two multi-series cards.
-- ============================================================
DECLARE @q NVARCHAR(MAX) = N'
WITH Scoped AS (
    SELECT F.* FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
      @FilterClause
), CategoryTotals AS (
    SELECT [REPORT_GROUP]
          ,SUM([CONSUMPTION_QTY]) AS CatQty
          ,SUM([COG_SOLD])        AS CatSold
    FROM Scoped GROUP BY [REPORT_GROUP]
), Ranked AS (
    SELECT S.[REPORT_GROUP], S.[ITEM_NAME]
          ,SUM(S.[CONSUMPTION_QTY]) AS ItemQty
          ,SUM(S.[COG_SOLD])        AS ItemSold
          ,ROW_NUMBER() OVER (PARTITION BY S.[REPORT_GROUP] ORDER BY SUM(S.[COG_SOLD]) DESC) AS rn
    FROM Scoped S GROUP BY S.[REPORT_GROUP], S.[ITEM_NAME]
), TopItems AS (
    SELECT R.[REPORT_GROUP], R.[ITEM_NAME], R.ItemSold
          ,ISNULL(R.ItemQty  / NULLIF(CT.CatQty, 0)  * 100, 0) AS PctUnits
          ,ISNULL(R.ItemSold / NULLIF(CT.CatSold, 0) * 100, 0) AS PctSpend
    FROM Ranked R
    INNER JOIN CategoryTotals CT ON CT.[REPORT_GROUP] = R.[REPORT_GROUP]
    WHERE R.rn <= 7
)
SELECT
     [ITEM_NAME]                                                    AS BarLabel
    ,DENSE_RANK() OVER (ORDER BY [REPORT_GROUP], ItemSold DESC)      AS BarLabelSort
    ,''% of category units''                                        AS SeriesLabel
    ,1                                                               AS SeriesLabelSort
    ,PctUnits                                                        AS BarValue
    ,DENSE_RANK() OVER (ORDER BY PctUnits)                           AS BarValueSort
FROM TopItems
UNION ALL
SELECT
     [ITEM_NAME]                                                    AS BarLabel
    ,DENSE_RANK() OVER (ORDER BY [REPORT_GROUP], ItemSold DESC)      AS BarLabelSort
    ,''% of category spend''                                        AS SeriesLabel
    ,2                                                               AS SeriesLabelSort
    ,PctSpend                                                        AS BarValue
    ,DENSE_RANK() OVER (ORDER BY PctSpend)                           AS BarValueSort
FROM TopItems
ORDER BY BarLabelSort, SeriesLabelSort

SELECT
     ''Item''             AS XAxisLabel
    ,''% of Category''    AS YAxisLabel
    ,''Top Items by Category'' AS Title
    ,''Top 7 items per category by spend, showing each item''''s share of its category''''s consumption units and spend'' AS Description
    ,NULL                 AS Trend
    -- TotalValue is an ITEM COUNT on a chart whose bars are percentages (final-review M19).
    -- Deliberate, and left as-is: a sum of percentages across two series and many
    -- categories is not a number that means anything, while the never-return-NULL contract
    -- (design section 7.2 #3) forbids leaving the slot empty. The count answers "how many
    -- items are in scope", which is the useful context for a top-N chart. Anyone reading
    -- this slot as "the total of the chart" will misread it - if the platform ever gains a
    -- label for this slot, label it "Items in scope".
    ,ISNULL((SELECT COUNT(DISTINCT F.[ITEM_NAME]) FROM [presentation].[F_COGS_PERIOD] F
             WHERE 1=1
               AND F.[SOURCE] LIKE ''int_growyze%''
               AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
               @FilterClause), 0) AS TotalValue
    ,NULL                 AS Chip;
';

DECLARE @pm NVARCHAR(MAX) = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

DECLARE @fd NVARCHAR(MAX) = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

DECLARE @od NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSTopItemsByCategory', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Top 7 items per category by spend, as % of category consumption units and % of category spend. Both percentages are computed over the same filtered row set (unlike the spreadsheet tab this replaces, which mismatched numerator and denominator row sets and produced a 142.8% bar).'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSTopItemsByCategory', N'BarChartCard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Top 7 items per category by spend, as % of category consumption units and % of category spend. Both percentages are computed over the same filtered row set (unlike the spreadsheet tab this replaces, which mismatched numerator and denominator row sets and produced a 142.8% bar).',
     NULL, NULL, GETDATE(), GETDATE());
GO

-- ============================================================
-- 4. PantryCOGSSlowMovers - BarChartCard
--
--    THREE RECORDED DEVIATIONS FROM SPEC section 7 (final-review M14). Documented here
--    rather than changed, because each one is a decision about what the card should show,
--    not a defect in what it does show - and changing any of them changes the card, which
--    is Andy's call, not a fix-wave call. They were previously undocumented, which is what
--    the review actually objected to. If the card is ever revisited, start here:
--
--    1. GLOBAL bottom 10, not bottom 10 PER CATEGORY. Spec section 7 says "Bottom 10 by
--       CONSUMPTION_QTY > 0 per category". Per-category would mean 10 bars x every report
--       group - on Raddish's data (a catch-all bucket broken out by subcategory) that is
--       dozens of bars on one card, and it needs a series/grouping decision the spec does
--       not make. The global bottom 10 answers "what is not moving here at all", which is
--       the slow-mover question a Pantry Manager acts on.
--    2. MIXED UNITS in one ranking. CONSUMPTION_QTY is summed across STANDARDISED_UOM
--       values, so kg, L and each sit in the same bottom-10 ordering and 0.5 kg ranks
--       below 2 each regardless of what either is worth. A quantity ranking cannot be
--       unit-safe without either splitting the card per unit or ranking by COG_SOLD
--       (money, which IS comparable) instead of quantity. Ranking by money would no longer
--       be the spec's measure.
--    3. GROUPED BY ITEM_NAME, not INVITEM_HUB_ID. Two distinct Growyze items sharing a
--       name merge into one bar. ITEM_NAME is what the card must label, and the fact
--       carries the hub id, so this is fixable - but it changes the bar set, so it is
--       listed rather than done.
--    None of these can produce a wrong TOTAL; they change which items appear and in what
--    order. That is why all three are Minor.
-- ============================================================
DECLARE @q NVARCHAR(MAX) = N'
WITH Scoped AS (
    SELECT F.[ITEM_NAME], SUM(F.[CONSUMPTION_QTY]) AS Qty
    FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
      @FilterClause
    GROUP BY F.[ITEM_NAME]
    HAVING SUM(F.[CONSUMPTION_QTY]) > 0
)
SELECT TOP 10
     [ITEM_NAME]                          AS BarLabel
    ,ROW_NUMBER() OVER (ORDER BY Qty ASC)  AS BarLabelSort
    ,Qty                                  AS BarValue
    ,ROW_NUMBER() OVER (ORDER BY Qty ASC)  AS BarValueSort
FROM Scoped
ORDER BY Qty ASC

SELECT
     ''Item''               AS XAxisLabel
    ,''Consumption Qty''    AS YAxisLabel
    ,''Slow Movers''        AS Title
    ,''Bottom 10 items by consumption quantity, excluding zero-consumption items'' AS Description
    ,NULL                   AS Trend
    -- TotalValue here IS the sum of the ten bars drawn, but across mixed units, so it is a
    -- context figure rather than a meaningful single quantity (final-review M19; see the
    -- mixed-units deviation at point 2 in this card''s header). Left as-is: the
    -- never-return-NULL contract (design section 7.2 #3) rules out blanking the slot - a
    -- NULL renders as "0.00" and asserts a wrong number - and every alternative (a money
    -- total, an item count) is equally not "the total of the chart". Read it as
    -- "quantity across the ten slowest lines", not as a unit-consistent total.
    ,ISNULL((SELECT SUM(Qty) FROM (
        SELECT TOP 10 SUM(F.[CONSUMPTION_QTY]) AS Qty
        FROM [presentation].[F_COGS_PERIOD] F
        WHERE 1=1
          AND F.[SOURCE] LIKE ''int_growyze%''
          AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
          @FilterClause
        GROUP BY F.[ITEM_NAME]
        HAVING SUM(F.[CONSUMPTION_QTY]) > 0
        ORDER BY SUM(F.[CONSUMPTION_QTY]) ASC
     ) X), 0)               AS TotalValue
    ,NULL                   AS Chip;
';

DECLARE @pm NVARCHAR(MAX) = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

DECLARE @fd NVARCHAR(MAX) = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

DECLARE @od NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSSlowMovers', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Bottom 10 items by consumption quantity, excluding zero-consumption items.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSSlowMovers', N'BarChartCard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Bottom 10 items by consumption quantity, excluding zero-consumption items.',
     NULL, NULL, GETDATE(), GETDATE());
GO

-- ============================================================
-- 5. PantryCOGSByVenue - BarChartCard (the consolidation view)
--    D_LOCATION's native name column is [BOTTOM_LOCATION_NAME] - confirmed from the DDL
--    in 8_PresentationTables.sql:509. Deliberately NOT using
--    COALESCE(BOTTOM_MICROSERVICE_NAME, BOTTOM_LOCATION_NAME): Growyze staging hardcodes
--    the literal 'growyze' into MICROSERVICE_NAME (Task 1 finding, Q3), and doing this
--    COALESCE on a sibling dimension previously collapsed three suppliers into a single
--    bar labelled "growyze". Native name column only.
-- ============================================================
DECLARE @q NVARCHAR(MAX) = N'
SELECT
     COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'')  AS BarLabel
    ,DENSE_RANK() OVER (ORDER BY SUM(F.[COG_SOLD]) DESC)     AS BarLabelSort
    ,SUM(F.[COG_SOLD])                                      AS BarValue
    ,DENSE_RANK() OVER (ORDER BY SUM(F.[COG_SOLD]) DESC)     AS BarValueSort
FROM [presentation].[F_COGS_PERIOD] F
LEFT JOIN [presentation].[D_LOCATION] L ON L.[BOTTOM_HUB_ID] = F.[LOCATION_HUB_ID]
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause
GROUP BY COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'')
ORDER BY SUM(F.[COG_SOLD]) DESC

SELECT
     ''Venue''            AS XAxisLabel
    ,''COG Sold''         AS YAxisLabel
    ,''COG Sold by Venue'' AS Title
    ,''Consolidated COG Sold across all venues for the selected period'' AS Description
    ,NULL                 AS Trend
    ,ISNULL((SELECT SUM(F.[COG_SOLD]) FROM [presentation].[F_COGS_PERIOD] F
             WHERE 1=1
               AND F.[SOURCE] LIKE ''int_growyze%''
               AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
               @FilterClause), 0) AS TotalValue
    ,NULL                 AS Chip;
';

DECLARE @pm NVARCHAR(MAX) = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';

DECLARE @fd NVARCHAR(MAX) = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

DECLARE @od NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSByVenue', N'BarChartCard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'COG Sold consolidated across all venues for the selected period - the cross-venue view a per-venue spreadsheet tab cannot produce.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSByVenue', N'BarChartCard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'COG Sold consolidated across all venues for the selected period - the cross-venue view a per-venue spreadsheet tab cannot produce.',
     NULL, NULL, GETDATE(), GETDATE());
GO
