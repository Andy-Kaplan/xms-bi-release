-- ============================================================================
-- GrowyzeCategoryStockTrend - stock value change per category (CustomDataGrid)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task G
-- Ledger: O5, O33
--
-- Backs the Overview category trend callouts: per inventory category, stock value
-- at the earliest vs the latest stocktake in the period, plus the delta.
--
-- Grid contract (verified against the LIVE ProductComparison template):
--   result set 1: Column1..Column29        (unbracketed aliases)
--   result set 2: [Title], [Description], [Label1]/[Type1] .. [Label29]/[Type29]
-- Unused slots are padded NULL. Types are 'TEXT' or 'DECIMAL'.
--
-- *** VALUES ACTUAL_COUNT, NOT THEO_QTY - same O33 reason as Task F ***
-- F_INV_COUNTS_DAY re-emits count rows (ledger O33): Padel 259 duplicate groups,
-- Dirty Sixth 56. Within a duplicate group ACTUAL_COUNT and UOM_COST are always
-- identical but THEO_QTY differs (230 of 259 groups on Padel), so any THEO_QTY
-- valuation is non-deterministic. The `counts` CTE collapses the fan-out to true
-- count grain first; MAX() is safe there precisely because the valued columns are
-- identical within a group.
--
-- *** WHAT THE DELTA DOES AND DOES NOT MEAN - READ BEFORE TRUSTING IT ***
-- The change is (value at the latest stocktake) - (value at the earliest one). It
-- therefore mixes genuine stock movement with CHANGES IN WHICH ITEMS WERE COUNTED:
-- if a category's earliest stocktake covered 200 items and its latest covered 40,
-- the value falls without any stock having moved. Measured on Padel, Beverages goes
-- 15,024.40 -> 2,798.87 (-12,225.53) across 28 count dates, which is almost
-- certainly coverage rather than consumption. Column2 exposes the count-date count
-- so the reader can see how comparable the two ends are. Treat this card as a
-- directional callout, not a stock-movement measure.
--
-- *** SINGLE-STOCKTAKE CATEGORIES ARE SHOWN, NOT DROPPED ***
-- A category with one count date has no delta. It is still listed, with a NULL
-- change, so it does not silently vanish from the grid (Padel's `Other` is one).
-- Column2 = 1 is the tell.
--
-- Scope: INV_SCOPE via invitem.[BOTTOM_SRC]. Category grain is `TOP` on D_INVITEM.
--
-- Verified 2026-07-31 (connected to each org DB directly):
--   Padel (10): Retail 4,367.71 -> 5,125.06 (+757.35, 10 dates);
--               Beverages 15,024.40 -> 2,798.87 (-12,225.53, 28 dates);
--               Food 844.67 -> 511.21 (-333.47, 30 dates);
--               Other 1,000.00 (1 date, NULL change)
--   Ibis Gloucester (21): Food 8,105.14 -> 6,424.28 (-1,680.87, 2 dates);
--               Beverages 2,045.92 -> 1,702.73 (-343.19, 2 dates)
--
-- DATA-QUALITY NOTE: Padel carries a source category literally named
-- 'All INVITEMs' valued at 0.00 across 10 count dates. It is a real D_INVITEM
-- TOP_NAME, not an artefact of this query, and it will render as a zero row.
-- Belongs on the Growyze catalogue data-quality list.
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

DECLARE @q NVARCHAR(MAX) = N'WITH counts AS (
    -- Collapse the O33 fan-out to true count grain before valuing anything.
    SELECT FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID,
           CAST(FC.[COUNT_DATE] AS DATE) AS count_date,
           MAX(FC.[ACTUAL_COUNT]) AS actual_count,
           MAX(FC.[UOM_COST])     AS uom_cost,
           MAX(COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])) AS category
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1
    AND invitem.[BOTTOM_SRC] = ''int_growyze001''
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID, CAST(FC.[COUNT_DATE] AS DATE)
),
PerCatDate AS (
    SELECT category, count_date,
           SUM(ISNULL(actual_count, 0) * ISNULL(uom_cost, 0)) AS value_
    FROM counts
    GROUP BY category, count_date
),
Ranked AS (
    SELECT category, count_date, value_,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY count_date ASC)  AS rn_early,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY count_date DESC) AS rn_late,
           COUNT(*)     OVER (PARTITION BY category)                          AS dates_for_cat
    FROM PerCatDate
)
SELECT
    category AS Column1,
    MAX(dates_for_cat) AS Column2,
    ROUND(MAX(CASE WHEN rn_early = 1 THEN value_ END), 2) AS Column3,
    ROUND(MAX(CASE WHEN rn_late  = 1 THEN value_ END), 2) AS Column4,
    CASE WHEN MAX(dates_for_cat) = 1 THEN NULL
         ELSE ROUND(MAX(CASE WHEN rn_late = 1 THEN value_ END)
                  - MAX(CASE WHEN rn_early = 1 THEN value_ END), 2) END AS Column5,
    CASE WHEN MAX(dates_for_cat) = 1 THEN NULL
         WHEN ISNULL(MAX(CASE WHEN rn_early = 1 THEN value_ END), 0) = 0 THEN NULL
         ELSE ROUND((MAX(CASE WHEN rn_late = 1 THEN value_ END)
                   - MAX(CASE WHEN rn_early = 1 THEN value_ END)) * 100.0
                   / MAX(CASE WHEN rn_early = 1 THEN value_ END), 1) END AS Column6,
    NULL AS Column7,  NULL AS Column8,  NULL AS Column9,  NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM Ranked
WHERE rn_early = 1 OR rn_late = 1
GROUP BY category
ORDER BY ROUND(MAX(CASE WHEN rn_late = 1 THEN value_ END), 2) DESC;

SELECT
    N''Category Stock Trend'' AS [Title],
    N''Stock value at the earliest vs latest stocktake in the period. Counted stock at cost. The change also reflects which items were counted, not stock movement alone.'' AS [Description],
    N''Category''        AS [Label1], N''TEXT''    AS [Type1],
    N''Stocktakes''      AS [Label2], N''DECIMAL'' AS [Type2],
    N''Earliest Value''  AS [Label3], N''DECIMAL'' AS [Type3],
    N''Latest Value''    AS [Label4], N''DECIMAL'' AS [Type4],
    N''Change (£)''      AS [Label5], N''DECIMAL'' AS [Type5],
    N''Change (%)''      AS [Label6], N''DECIMAL'' AS [Type6],
    NULL AS [Label7],  NULL AS [Type7],  NULL AS [Label8],  NULL AS [Type8],
    NULL AS [Label9],  NULL AS [Type9],  NULL AS [Label10], NULL AS [Type10],
    NULL AS [Label11], NULL AS [Type11], NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13], NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15], NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17], NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19], NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21], NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23], NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25], NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27], NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29];';

DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_INV - `location` and `invitem` aliases exist in the counts CTE where
-- @FilterClause is injected, so Locations / InvItems / ProductCategories bind.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeCategoryStockTrend', N'CustomDataGrid')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate     = @q,
    ParameterMappings = @pm,
    FilterDefinitions = @fd,
    Status            = N'LIVE',
    ModifiedDate      = GETDATE(),
    ModifiedBy        = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeCategoryStockTrend', N'CustomDataGrid', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task G: GrowyzeCategoryStockTrend deployed.';
