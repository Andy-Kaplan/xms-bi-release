-- ============================================================================
-- GrowyzeHighestVenue / GrowyzeLowestVenue - stock-value extremes (SingleKPICard)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task F
-- Ledger: O5, O33
--
-- Shows the highest / lowest stock-value venue as "<Venue> · £<value>".
--
-- ############################################################################
-- PLAN DEVIATION - MEASURE CHANGED FROM THEO_QTY TO ACTUAL_COUNT
-- ############################################################################
-- The plan (and InvKPIGrouped, which it copies) values stock as
-- THEO_QTY * UOM_COST. Measured on UAT 2026-07-31, THEO_QTY is NOT SAFE to value
-- on these orgs because of the O33 fan-out, and the resulting card value is
-- NON-DETERMINISTIC. ACTUAL_COUNT * UOM_COST is used instead.
--
-- The evidence: F_INV_COUNTS_DAY is supposed to be at count grain (one row per
-- item x location x count date). It is not - the movement join re-emits count rows
-- (ledger O33). Blast radius, previously unmeasured, is:
--     Padel Social (10)   259 duplicate groups / 518 rows (up to 2 per group)
--     Dirty Sixth (18)     56 duplicate groups / 123 rows (up to 3 per group)
--
-- Crucially, the duplicated rows are NOT identical:
--     ACTUAL_COUNT   identical in ALL groups (0 of 259 / 0 of 56 differ)
--     UOM_COST       identical in ALL groups (0 of 259 / 0 of 56 differ)
--     THEO_QTY       DIFFERS in 230 of 259 (Padel) and 25 of 56 (Dirty Sixth)
--     ORDER_QTY / MOVEMENT_QTY likewise differ (THEO_QTY is derived from them)
--
-- So a ROW_NUMBER tie-break over duplicate rows picks an ARBITRARY THEO_QTY, and
-- the venue total moves between renders:
--     Padel Earls Court   THEO valuation ranges 23,266.78 .. 24,135.23  (+/- 868.45)
--     Dirty Sixth         THEO valuation ranges 17,395.52 .. 18,090.15  (+/- 694.63)
-- I observed this live: two runs of the planned query returned 17,777.76 and
-- 17,534 for the same org, same data.
--
-- ACTUAL_COUNT is provably repeated identically across fanned-out rows, so
-- deduplicating to count grain is well-defined and the value is stable. It is also
-- the more honest measure for "stock value at this venue" (what was actually
-- counted) and matches how O32's F_COGS_PERIOD and O8's Marge Brut value closing
-- stock. Deterministic results after the change:
--     Padel: Earls Court £23,269.19 (highest) / O2 £8,126.31 (lowest)
--     Dirty Sixth £16,860.51 | Ibis Gloucester £8,496.68
--
-- The MAX() in the dedup CTE is a no-op on the values it selects - it exists only
-- to collapse the fan-out, and it is safe precisely BECAUSE ACTUAL_COUNT and
-- UOM_COST are identical within each group. If O33 is ever fixed this CTE becomes
-- redundant but stays correct.
--
-- *** SNAPSHOT, NOT A CROSS-PERIOD SUM (O8 defect C5) ***
-- RN=1 per (location, item) takes each item's LATEST count. Summing every count
-- date instead overstates stock enormously - measured here: Padel Earls Court
-- £23,369 snapshot vs £221,695 naive (9.5x), O2 8.5x, Dirty Sixth 2.2x.
-- >>> Ibis Gloucester returns the IDENTICAL number either way (single period), so
-- >>> verifying this card only on org 21 would pass a 9.5x overstatement. Verify on
-- >>> Padel, which has 34 count dates.
--
-- Scope: INV_SCOPE on both the item and the location dimension.
-- Single-venue orgs correctly return the same venue for Highest and Lowest - that
-- is expected, not a bug.
--
-- Verified 2026-07-31 (connected to each org DB directly):
--   Padel (10)       Highest = Earls Court · £23,269   Lowest = O2 · £8,126
--   Dirty Sixth (18) Highest = Lowest = Dirty Sixth · £16,861   (one venue)
--   Ibis Glos (21)   Highest = Lowest = Ibis Gloucester Rd · £8,497  (one venue)
--
-- Idempotent MERGEs on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

DECLARE @base NVARCHAR(MAX) = N'WITH counts AS (
    -- Collapse the O33 fan-out to true count grain. MAX() is safe here because
    -- ACTUAL_COUNT and UOM_COST are provably identical across duplicated rows.
    SELECT FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID,
           CAST(FC.[COUNT_DATE] AS DATE) AS count_date,
           MAX(FC.[ACTUAL_COUNT]) AS actual_count,
           MAX(FC.[UOM_COST])     AS uom_cost
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1
    AND invitem.[BOTTOM_SRC] = ''int_growyze001''
    AND location.[BOTTOM_SRC] = ''int_growyze001''
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID, CAST(FC.[COUNT_DATE] AS DATE)
),
latest AS (
    -- Each item''s most recent count only - never sum across count dates.
    SELECT counts.*,
           ROW_NUMBER() OVER (PARTITION BY LOCATION_HUB_ID, INVITEM_HUB_ID
                              ORDER BY count_date DESC) AS rn
    FROM counts
),
sv AS (
    SELECT COALESCE(loc.[BOTTOM_MICROSERVICE_NAME], loc.[BOTTOM_LOCATION_NAME]) AS venue,
           SUM(ISNULL(latest.actual_count, 0) * ISNULL(latest.uom_cost, 0)) AS stock_value
    FROM latest
    LEFT JOIN [presentation].[D_LOCATION] loc ON latest.LOCATION_HUB_ID = loc.BOTTOM_HUB_ID
    WHERE latest.rn = 1
    GROUP BY COALESCE(loc.[BOTTOM_MICROSERVICE_NAME], loc.[BOTTOM_LOCATION_NAME])
)
SELECT TOP 1 z.Title, z.Value FROM (
    SELECT N''{{TITLE}}'' AS Title,
           sv.venue + N'' · £'' + FORMAT(sv.stock_value, ''N0'') AS Value,
           1 AS pri,
           ROW_NUMBER() OVER (ORDER BY sv.stock_value {{DIR}}) AS rn
    FROM sv
    UNION ALL
    SELECT N''{{TITLE}}'', N''—'', 2, 1
) z
ORDER BY z.pri, z.rn;';

DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_INV - `location` and `invitem` aliases both exist in the counts CTE, where
-- @FilterClause is injected, so Locations / InvItems / ProductCategories all bind.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

DECLARE @q NVARCHAR(MAX);

-- ---- GrowyzeHighestVenue ----------------------------------------------------
SET @q = REPLACE(REPLACE(@base, N'{{TITLE}}', N'Highest Stock Venue'), N'{{DIR}}', N'DESC');

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeHighestVenue', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, ParameterMappings = @pm, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeHighestVenue', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

-- ---- GrowyzeLowestVenue ----------------------------------------------------
SET @q = REPLACE(REPLACE(@base, N'{{TITLE}}', N'Lowest Stock Venue'), N'{{DIR}}', N'ASC');

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeLowestVenue', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, ParameterMappings = @pm, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeLowestVenue', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

IF EXISTS (SELECT 1 FROM [core].[core].[VisualisationQueries]
           WHERE DataSetName IN (N'GrowyzeHighestVenue', N'GrowyzeLowestVenue')
             AND QueryTemplate LIKE N'%{{%')
    RAISERROR(N'Task F abort: an unreplaced {{token}} remains in a deployed template.', 16, 1);

PRINT 'Task F: GrowyzeHighestVenue + GrowyzeLowestVenue deployed.';
