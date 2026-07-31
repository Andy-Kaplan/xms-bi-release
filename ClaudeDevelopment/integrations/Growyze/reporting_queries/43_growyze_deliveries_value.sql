-- ============================================================================
-- GrowyzeDeliveriesValue - Deliveries GBP in period (SingleKPICard)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task B
-- Ledger: O5
--
-- Backs the Overview "Deliveries" tile: total value of goods received in the
-- selected period, from presentation.F_PURCHASES_DAY.
--
-- *** NO `location <> 'Unknown'` GUARD - DELIBERATE, AND THE POINT OF THIS CARD ***
-- The sales cards all carry `location.[BOTTOM_LOCATION_NAME] <> 'Unknown'` and
-- rev 1 of this plan copied it here. Measured on UAT 2026-07-31, that guard
-- silently destroys the measure:
--
--   Org                     with guard        without guard     dropped
--   Padel Social (10)       GBP 45,054.80     GBP 47,394.61      109 rows / 2,339.81
--   Dirty Sixth (18)        GBP 27,554.02     GBP 68,248.39    1,160 rows / 40,694.37  (60%!)
--
-- The dropped rows are not junk: they carry the CONVERT(BINARY(32), -999)
-- location sentinel, meaning the purchase line resolved to no venue. They span
-- the full date range (Dirty Sixth 2024-12-29 to 2026-07-28) and they are real
-- money spent on real deliveries. A "Deliveries GBP" KPI that reports 40% of
-- actual spend is worse than no card, so the guard is omitted here.
--
-- The `location` alias is still LEFT JOINed so the Locations filter binds. When a
-- user filters to a named venue the sentinel rows correctly drop out - that is a
-- deliberately narrowed view, not the headline number.
--
-- >>> DATA-QUALITY FINDING (raise separately, not fixable in a vis query) <<<
-- A large share of Growyze purchase lines carry no location: Dirty Sixth 1,160 of
-- 2,141 rows (54% of rows, 60% of value), Padel 109 of 1,796, Ibis Heathrow 201 of
-- 2,335, Oak & Vine / Ibis Gloucester 271 of 2,200. Deliveries therefore cannot be
-- analysed per venue for most of Dirty Sixth's spend. Root cause is upstream of
-- presentation (the stock-order staging does not resolve a location for these
-- lines) and needs its own investigation.
--
-- *** CAST ON THE CALENDAR JOIN IS LOAD-BEARING HERE ***
-- Unlike the other facts in this pack, F_PURCHASES_DAY.ORDER_DATE carries a real
-- time on EVERY row (1,800 of 1,800 on Padel). Comparing a datetime2 directly to
-- CALENDAR's `date` column would match only midnight rows - i.e. none of them.
--
-- Scope: INV_SCOPE (invitem source). This excludes 3-4 lines per org whose invitem
-- itself is unresolved (Padel 4 rows / GBP 2.42) - immaterial, and keeping the
-- scope is what makes the card Growyze-specific.
--
-- Verified 2026-07-31 (connected to each org DB directly):
--   Padel (10) GBP 47,395 | Oak & Vine (16) GBP 22,577 | Dirty Sixth (18) GBP 68,248
--   Ibis Heathrow (20) GBP 61,826 | Ibis Gloucester (21) GBP 22,577
-- Orgs 16 and 21 are byte-identical because they share one Growyze tenant's data.
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

DECLARE @q NVARCHAR(MAX) = N'SELECT
    N''Deliveries'' AS Title,
    COALESCE(N''£'' + FORMAT(SUM(F.[LINE_TOTAL]), ''N0''), N''—'') AS Value
FROM [presentation].[F_PURCHASES_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON F.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.[BOTTOM_SRC] = ''int_growyze001''
@FilterClause;';

-- Date picker reads its columns ONLY from ParameterMappings; NULL silently
-- discards the dashboard date range. Map C.[DATE] (typed `date`), never
-- F.[ORDER_DATE] (datetime2 with a time on every row - it would drop the
-- window's last day entirely).
DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_INV - both `location` and `invitem` aliases exist above, so Locations /
-- InvItems / ProductCategories all bind.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeDeliveriesValue', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
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
    VALUES (N'GrowyzeDeliveriesValue', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task B: GrowyzeDeliveriesValue deployed.';
