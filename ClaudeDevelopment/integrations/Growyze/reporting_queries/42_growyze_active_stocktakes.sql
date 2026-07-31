-- ============================================================================
-- GrowyzeActiveStocktakes - "X / Y" venues counted (SingleKPICard)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task A
-- Ledger: O5
--
-- Backs the Overview "Active Stocktakes" tile: how many inventory venues were
-- stocktaken in the selected period, out of how many exist.
--
-- *** DENOMINATOR = INVENTORY-TRACKED VENUES (ruling 2026-07-31) ***
-- Y counts only venues belonging to the inventory source, NOT every location in
-- the organisation. Measured on UAT: The Oak & Vine has 9 locations but only 1
-- Growyze stockroom, so the rejected "all venues" reading would have rendered a
-- permanently unachievable "1 / 9" - its 8 POS locations can never receive a
-- Growyze stocktake. Scoped, it reads "1 / 1".
--
-- *** NEVER FILTER BOTTOM_LEVEL_NAME (rev-2 change 4) ***
-- The rev-1 version of this card filtered D_LOCATION.BOTTOM_LEVEL_NAME='Location'.
-- Measured on UAT: that value is 'Location' for Growyze but 'BOTTOM' for Mews and
-- NCRAloha, so on Ibis Gloucester the denominator silently counted 1 of 3 rows and
-- on Oak & Vine 1 of 9. Scope by BOTTOM_SRC instead - it is the source column and
-- it means what it says.
--
-- Scope: INV_SCOPE. Growyze is the only INVENTORY integration on all five target
-- orgs, so inventory cards scope to it explicitly rather than going through the
-- POS precedence resolver (which applies to SALES cards only).
--
-- Verified 2026-07-31 (connected to each org DB directly):
--   Padel Social (10)          2 / 3   (3 Growyze venues, 2 stocktaken)
--   The Oak & Vine (16)        1 / 1   (9 locations total, 1 of them Growyze)
--   Dirty Sixth (18)           1 / 1
--   Ibis Heathrow (20)         1 / 1
--   Ibis Gloucester Road (21)  1 / 1
-- The numerator agrees with an independently location-scoped baseline, so no
-- Growyze count row points at a non-Growyze location.
--
-- KNOWN INTERACTION (documented, not fixed): the denominator subquery is
-- deliberately NOT filtered by @FilterClause, so applying a Locations filter
-- shrinks the numerator while Y stays at the full inventory estate (e.g. "1 / 3"
-- on Padel). Making Y respect the filter would require injecting @FilterClause
-- into the subquery, whose D_LOCATION would then need the alias `location` to
-- bind - the exact multi-part-identifier trap that breaks InvMargeBrut (Task L).
-- The card reads "how much of the estate is counted", which is the stocktake
-- question the mockup asks.
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

DECLARE @q NVARCHAR(MAX) = N'SELECT
    N''Active Stocktakes'' AS Title,
    CAST(COUNT(DISTINCT FC.LOCATION_HUB_ID) AS NVARCHAR(10)) + N'' / '' +
    CAST((SELECT COUNT(*) FROM [presentation].[D_LOCATION] v
          WHERE v.[BOTTOM_SRC] = ''int_growyze001''
            AND v.[BOTTOM_LOCATION_NAME] <> ''Unknown'') AS NVARCHAR(10)) AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';

-- Date picker reads its columns ONLY from ParameterMappings. Leave this NULL and
-- the dashboard date range is silently discarded and the CALENDAR join above is
-- dead weight. C.[DATE] is typed `date`; COUNT_DATE is datetime2, so mapping the
-- fact column directly would drop the window's last day.
DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_INV - inventory FilterDefinitions (location + invitem aliases both present
-- in the query above, so Locations / InvItems / ProductCategories all bind).
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeActiveStocktakes', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
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
    VALUES (N'GrowyzeActiveStocktakes', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task A: GrowyzeActiveStocktakes deployed.';
