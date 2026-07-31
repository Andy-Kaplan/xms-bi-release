-- ============================================================================
-- GrowyzeSalesHeatmap - quantity sold by hour x day of week (HeatmapCard)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task J
-- Ledger: O5
--
-- HeatmapCard contract: exactly XAxisLabel (hour), YAxisLabel (day name),
-- Value (quantity), plus a header result set. Models the LIVE
-- OakVineMenuSalesByHour but measures SUM(QUANTITY) rather than value.
--
-- *** RESOLVER JOINS ON F.[SRC] HERE, NOT product.[BOTTOM_SRC] ***
-- Unlike F_PRODUCT_MARGIN_DAY, F_LINEITEM_15MIN DOES carry its own SRC column
-- (verified against INFORMATION_SCHEMA 2026-07-31), so precedence is applied
-- directly on the fact - one less join to get wrong.
--
-- *** CAST ON THE CALENDAR JOIN (rev-2 change 7) ***
-- Rev 1 joined F.[ORDER_DATE] = C.[DATE] with no CAST. ORDER_DATE is datetime2;
-- it happens to be midnight-only on every row today (Padel 10,890/10,890 and
-- Oak & Vine 264,628/264,628), so the uncast form works BY LUCK. One POS feed
-- landing an order time would silently empty the card.
--
-- *** THIS IS A RECENT-WINDOW VIEW ON GROWYZE ORGS - THE CARD SAYS SO ***
-- LINEITEM_TIMESTAMP can only be stamped while the sales header is still inside
-- Growyze's rolling DL_SALES window, so only ~4% of Padel's satellite rows carry
-- one (1,297 of 31,060). History is permanently NULL - its source data no longer
-- exists - and coverage grows forward with each load without ever backfilling.
-- The header Description states this rather than letting the card imply it covers
-- all time. POS-sourced orgs are unaffected: their timestamps are complete, which
-- is why the Description distinguishes the two cases instead of claiming one.
--
-- Verified 2026-07-31 (connected to each org DB directly):
--   Padel (10):      a real trading curve from 06:00 (Mon 06:00 qty 2, 07:00 qty 6,
--                    08:00 qty 18, 09:00 qty 40, ...) across 151 distinct 15-min
--                    buckets, 0 midnight rows
--   Oak & Vine (16): denser and full-history, including hour 0 (Sun 00:00 qty 51)
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

DECLARE @q NVARCHAR(MAX) = N'WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT
    CAST(DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS NVARCHAR) AS XAxisLabel,
    C.[DayName] AS YAxisLabel,
    ROUND(SUM(F.[QUANTITY]), 0) AS Value
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
WHERE 1=1
AND F.[LI_TYPE] = ''PROD''
AND F.[LINEITEM_TIMESTAMP] IS NOT NULL
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]), C.[DayName], C.[DayOfWeek]
ORDER BY C.[DayOfWeek], DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]);

SELECT
    N''Sales Heatmap'' AS Title,
    N''Quantity sold by hour and day of week. Growyze sales only carry a time while the order is still in the recent feed window, so this shows recent trading rather than full history.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value;';

DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_MARGIN - `product` and `location` aliases are present, so Products /
-- ProductCategories / Locations all bind. ProductCategories on the TOP grain.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeSalesHeatmap', N'HeatmapCard')) AS src (DataSetName, VisualizationType)
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
    VALUES (N'GrowyzeSalesHeatmap', N'HeatmapCard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task J: GrowyzeSalesHeatmap deployed.';
