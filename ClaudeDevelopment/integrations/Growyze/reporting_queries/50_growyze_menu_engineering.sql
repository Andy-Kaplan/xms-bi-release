-- ============================================================================
-- GrowyzeMenuEngineering - Star/Puzzle/Workhorse/Dog quadrants (CustomDataGrid)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task I
-- Ledger: O5, O35
--
-- Classifies each product by popularity (SUM(QUANTITY)) against profitability
-- (GP%), split at the LIVE medians of both - never hardcoded thresholds, because
-- the split points move with the data. Shipped as a grid because no
-- ScatterChartCard exists (the mockup's own recommendation).
--
-- Grid contract (verified against the LIVE ProductComparison template):
--   result set 1: Column1..Column29        (unbracketed aliases)
--   result set 2: [Title], [Description], [Label1]/[Type1] .. [Label29]/[Type29]
--
-- Category column on the TOP grain (rev-2 change 2): Mews MIDDLE_1 holds 98 product
-- families vs 12 real categories at TOP, so MIDDLE_1 would fill this column with
-- individual wines on a Mews org.
--
-- *** SAME-COVERAGE RATIO (COVERAGE) ***
-- GP% divides SUM(PROFIT) - which already NULL-skips uncosted rows - by
-- SUM(NET_VALUE) restricted to costed rows, so numerator and denominator describe
-- one population. The unguarded form understated Oak & Vine as 63.7% vs 82.9%.
--
-- *** BOUNDARY BEHAVIOUR IS `>=` ON BOTH AXES, DELIBERATELY ***
-- A product exactly on a median counts as the HIGH side of that axis. This makes
-- the four quadrants mutually exclusive and exhaustive - verified on UAT that the
-- counts sum EXACTLY to the product total with zero unclassified:
--     Padel (10)        291 products = 73 Star + 73 Puzzle + 85 Workhorse + 60 Dog
--     The Oak & Vine    80 products = 22 + 18 + 18 + 22
--     Dirty Sixth (18)  387 products = 86 + 108 + 110 + 83
-- Live medians measured: Padel qty 14 / GP 81.65%; Oak & Vine qty 1714.5 / 84.71%;
-- Dirty Sixth qty 38 / 79.98%. Note how far apart those are - any hardcoded split
-- would be wrong on at least two of the three orgs.
--
-- *** CAVEAT TO CARRY ON THE CARD ***
-- Popularity is heavily right-skewed and GP% has negative outliers, so a median
-- split necessarily places about half the catalogue below each threshold. This is a
-- first-pass classification for conversation, not a verdict on a product. Revisit
-- the thresholds with Kati.
--
-- *** NO-COST STATE (NOCOST pattern (d)) ***
-- On a source with no cost path (Mews - ledger O35) the classification is
-- meaningless, so the grid returns ONE row saying so rather than an empty grid.
-- The fallback branch is gated on NOT EXISTS so it never appears alongside real
-- rows.
--
-- Scope: RESOLVER_SALES via product.[BOTTOM_SRC] (this fact has no SRC column).
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
),
prod AS (
    SELECT
        COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) AS product_name,
        COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS category,
        SUM(F.[QUANTITY])  AS qty,
        SUM(F.[NET_VALUE]) AS revenue,
        SUM(F.[PROFIT]) * 100.0
          / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END), 0) AS gp_pct
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1 AND F.[NET_VALUE] > 0
    AND F.[AVG_NET_COST] IS NOT NULL
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) <> ''Unknown''
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]),
             COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
),
med AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY qty)    OVER () AS med_qty,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gp_pct) OVER () AS med_gp
    FROM prod
)
SELECT Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8, Column9,
       Column10, Column11, Column12, Column13, Column14, Column15, Column16, Column17,
       Column18, Column19, Column20, Column21, Column22, Column23, Column24, Column25,
       Column26, Column27, Column28, Column29
FROM (
    SELECT
        p.product_name AS Column1,
        p.category AS Column2,
        ROUND(p.qty, 2) AS Column3,
        ROUND(p.revenue, 2) AS Column4,
        ROUND(p.gp_pct, 1) AS Column5,
        CASE WHEN p.qty >= m.med_qty AND p.gp_pct >= m.med_gp THEN N''Star''
             WHEN p.qty <  m.med_qty AND p.gp_pct >= m.med_gp THEN N''Puzzle''
             WHEN p.qty >= m.med_qty AND p.gp_pct <  m.med_gp THEN N''Workhorse''
             ELSE N''Dog'' END AS Column6,
        CAST(NULL AS NVARCHAR(10)) AS Column7,  CAST(NULL AS NVARCHAR(10)) AS Column8,
        CAST(NULL AS NVARCHAR(10)) AS Column9,  CAST(NULL AS NVARCHAR(10)) AS Column10,
        CAST(NULL AS NVARCHAR(10)) AS Column11, CAST(NULL AS NVARCHAR(10)) AS Column12,
        CAST(NULL AS NVARCHAR(10)) AS Column13, CAST(NULL AS NVARCHAR(10)) AS Column14,
        CAST(NULL AS NVARCHAR(10)) AS Column15, CAST(NULL AS NVARCHAR(10)) AS Column16,
        CAST(NULL AS NVARCHAR(10)) AS Column17, CAST(NULL AS NVARCHAR(10)) AS Column18,
        CAST(NULL AS NVARCHAR(10)) AS Column19, CAST(NULL AS NVARCHAR(10)) AS Column20,
        CAST(NULL AS NVARCHAR(10)) AS Column21, CAST(NULL AS NVARCHAR(10)) AS Column22,
        CAST(NULL AS NVARCHAR(10)) AS Column23, CAST(NULL AS NVARCHAR(10)) AS Column24,
        CAST(NULL AS NVARCHAR(10)) AS Column25, CAST(NULL AS NVARCHAR(10)) AS Column26,
        CAST(NULL AS NVARCHAR(10)) AS Column27, CAST(NULL AS NVARCHAR(10)) AS Column28,
        CAST(NULL AS NVARCHAR(10)) AS Column29,
        1 AS pri,
        ROW_NUMBER() OVER (ORDER BY p.revenue DESC) AS rn
    FROM prod p CROSS JOIN med m
    UNION ALL
    -- Fires only when the resolved source has no costed sales at all (O35).
    SELECT N''—'', CAST(NULL AS NVARCHAR(400)),
        CAST(NULL AS DECIMAL(18,2)), CAST(NULL AS DECIMAL(18,2)), CAST(NULL AS DECIMAL(18,2)),
        N''No cost data'',
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(10)),
        2, 1
    WHERE NOT EXISTS (SELECT 1 FROM prod)
) z
ORDER BY z.pri, z.rn;

SELECT
    N''Menu Engineering'' AS [Title],
    N''Products split at the live medians of quantity sold and GP%. A product on a median counts to the high side. First-pass classification for discussion, not a verdict.'' AS [Description],
    N''Menu Item''      AS [Label1], N''TEXT''    AS [Type1],
    N''Category''       AS [Label2], N''TEXT''    AS [Type2],
    N''Qty Sold''       AS [Label3], N''DECIMAL'' AS [Type3],
    N''Revenue''        AS [Label4], N''DECIMAL'' AS [Type4],
    N''GP %''           AS [Label5], N''DECIMAL'' AS [Type5],
    N''Classification'' AS [Label6], N''TEXT''    AS [Type6],
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

-- FD_MARGIN - ProductCategories on the TOP grain, matching Column2 / the GROUP BY.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeMenuEngineering', N'CustomDataGrid')) AS src (DataSetName, VisualizationType)
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
    VALUES (N'GrowyzeMenuEngineering', N'CustomDataGrid', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task I: GrowyzeMenuEngineering deployed.';
