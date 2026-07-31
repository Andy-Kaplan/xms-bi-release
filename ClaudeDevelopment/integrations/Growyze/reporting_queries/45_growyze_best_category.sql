-- ============================================================================
-- GrowyzeBestCategory - best-performing category + GP% (SingleKPICard, label)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task D
-- Ledger: O5, O35
--
-- Ranks categories by total PROFIT and shows "<Category> · <GP%>".
--
-- *** CATEGORY GRAIN IS `TOP`, NOT `MIDDLE_1` (rev-2 change 2) ***
-- Rev 1 grouped by MIDDLE_1. Measured on UAT 2026-07-31, the correct level differs
-- per source and MIDDLE_1 is wrong for POS:
--   Mews:      TOP = 12 real categories   MIDDLE_1 = 98 product families (Peroni...)
--   NCRAloha:  TOP = 2 (Food/Drinks)      MIDDLE_1 = 8
--   Growyze:   TOP == MIDDLE_1
-- On a Mews org the MIDDLE_1 grain would have picked a single wine as the org's
-- "best category". FD_MARGIN's ProductCategories is held on the SAME grain as this
-- GROUP BY - when those two diverged previously, choosing a category blanked both
-- KPI cards beside a populated pie.
--
-- *** LABEL-KPI FALLBACK (NOCOST pattern (b)) - AND WHY ROW_NUMBER, NOT ORDER BY ***
-- A `TOP 1 ... GROUP BY` returns ZERO rows when nothing qualifies, so the card
-- would render nothing at all and COALESCE cannot help. The ranked query is
-- therefore UNION ALLed with a fallback row and the whole thing wrapped.
-- Because an ORDER BY cannot be attached to a UNION ALL branch, the profit
-- ranking is materialised as a ROW_NUMBER column so it survives as data and the
-- outer ORDER BY can use it. Verified on UAT: Padel returns Beverages 82.0% and
-- Oak & Vine returns Food 81.8%, both matching an independent baseline ranking
-- exactly - which is the proof the ordering survived the union.
--
-- The fallback distinguishes two different empty cases, so a Mews-only org and an
-- org with no sales do not tell the user the same (wrong) story:
--   sales exist but none costed -> 'No cost data'   (O35: Mews has no cost path)
--   no resolved sales at all    -> '—'
--
-- *** SAME-COVERAGE RATIO (COVERAGE) ***
-- SUM(PROFIT) already NULL-skips uncosted rows, so only the denominator needs
-- restricting to costed rows. Unrestricted it would understate GP% - the defect
-- that read Oak & Vine as 63.7% instead of 82.9%.
--
-- Scope: RESOLVER_SALES via product.[BOTTOM_SRC] (this fact has no SRC column).
--
-- Verified 2026-07-31 (connected to each org DB directly - the resolver reads
-- sys.schemas of the EXECUTING database, so verifying from `core` with three-part
-- prefixes silently returns the Growyze fallback for every org and gives a false
-- PASS):
--   Padel Social (10)          Beverages · 82.0%   (matches baseline exactly)
--   The Oak & Vine (16)        Food · 81.8%        (real TOP category, not a family)
--   Dirty Sixth (18)           Food · 79.1%
--   Ibis Heathrow (20)         '—'                 no resolved sales
--   Ibis Gloucester Road (21)  'No cost data'      703 sales rows, 0 costed
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
SELECT TOP 1 z.Title, z.Value FROM (
    SELECT
        N''Best Category'' AS Title,
        COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) + N'' · '' +
        FORMAT(SUM(F.[PROFIT]) * 100.0
             / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END), 0), ''N1'') + N''%'' AS Value,
        1 AS pri,
        ROW_NUMBER() OVER (ORDER BY SUM(F.[PROFIT]) DESC) AS rn
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1 AND F.[NET_VALUE] > 0
    AND F.[AVG_NET_COST] IS NOT NULL
    AND COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) <> ''Unknown''
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
    UNION ALL
    SELECT N''Best Category'',
        CASE WHEN EXISTS (
            SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] F2
            LEFT JOIN [presentation].[D_PRODUCT] p2 ON F2.PRODUCT_HUB_ID = p2.BOTTOM_HUB_ID
            INNER JOIN sales_src ss2 ON ss2.SRC = p2.[BOTTOM_SRC]
            WHERE F2.[NET_VALUE] > 0)
        THEN N''No cost data'' ELSE N''—'' END,
        2, 1
) z
ORDER BY z.pri, z.rn;';

DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_MARGIN - ProductCategories on the TOP grain, matching the GROUP BY above.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeBestCategory', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
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
    VALUES (N'GrowyzeBestCategory', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task D: GrowyzeBestCategory deployed.';
