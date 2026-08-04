/*==============================================================================
  55_invcogs_category_fixes.sql
  O5 Plan 4 -- InvCOGSByCategory: five defects, four of them undocumented

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md 5b

  Both LIVE InvCOGSByCategory queries are replaced in full (QueryTemplate; both
  have ExecutionQuery = NULL, asserted below before any write). A wholesale
  replacement rather than targeted REPLACEs because the joins, the guards and
  the header all change together.

  WHAT WAS WRONG

  1. CENTRE TOTAL COULD NOT EQUAL THE SUM OF THE SLICES  (PieChartCard)
     The slices come from a `Base` CTE guarded by
         COALESCE(BOTTOM_MICROSERVICE_NAME, BOTTOM_PRODUCT_NAME) IS NOT NULL
       + CATEGORY IS NOT NULL
     but the PiePrimaryText subquery re-derived the total from the raw fact with
     NEITHER guard. Numerator and denominator describing different populations --
     the same defect class as the GrowyzeProfitPct ratio fixed during the
     source-precedence work, and as O8's cost-of-sales reading 0.5%.
     FIX: the header now reads SUM(COGS) from the SAME `Base` CTE with the SAME
     guard, so centre == sum of slices BY CONSTRUCTION rather than by agreement.
     This is the important one; the missing currency symbol was cosmetic.

  2. NO CAST ON THE CALENDAR JOIN  (both card types)
     `INNER JOIN CALENDAR C ON F.[ORDER_DATE] = C.[DATE]`. Portability rule 3.
     Latent on Growyze (which lands at midnight) and live on any POS source,
     whose ORDER_DATE carries a time -- those rows silently match no calendar
     row at all and vanish from the card.

  3. NO SOURCE SCOPE  (both card types)
     On The Oak & Vine this blends NCRAloha + Mews + Growyze COGS under a single
     pie. Same collision class that showed GBP 905k of NCRAloha/Mews value under
     a card labelled "Growyze", and that made O8's cost of sales read 0.5%.
     FIX: the standard resolver (org's own sys.schemas joined to
     core.core.Integrations on IntegrationType='POS', Growyze as fallback),
     keyed on product.[BOTTOM_SRC] because F_PRODUCT_MARGIN_DAY has no SRC
     column. Identical to GrowyzeProfit / GrowyzeMenuEngineering.

  4. FILTER GRAIN DIVERGED FROM THE GROUP BY  (both card types)
     FilterDefinitions.ProductCategories bound MIDDLE_1 while the GROUP BY is
     TOP. Portability rule 2 -- the ledger records this exact divergence
     blanking two KPI cards beside a populated pie. FIX: bind TOP.

  5. COGS AND GROSS PROFIT ON DIFFERENT POPULATIONS  (StackedBarChartCard only)
     Its Base guarded `NULLIF(F.[NET_VALUE],0) IS NOT NULL` while the pie guards
     `NULLIF(F.[AVG_NET_COST],0) IS NOT NULL`. So the stacked bar included
     rows that have revenue but NO COST -- contributing 0 to the COGS series and
     their full value to the GP series, overstating gross profit, while the pie
     beside it on Cost & Margins excluded them. Two cards, same dataset, two
     populations. FIX: the stacked bar now also requires a cost, so its COGS and
     GP describe one population and reconcile with the pie.

  DELIBERATELY NOT CHANGED
     The StackedBarChartCard header still returns `NULL AS Value`. The frontend
     renders that NULL as "0" instead of suppressing the tile -- a FRONTEND
     defect (the query is already doing the right thing). Tracked separately;
     do not "fix" it here by inventing a headline number.

  BLAST RADIUS  (UAT report DB, 2026-08-03)
     PieChartCard        7 cards / 5 orgs -- 5 of them the Growyze Inventory Control grid
     StackedBarChartCard 2 cards / 2 orgs -- Cost & Margins (Padel Social, Dirty Sixth)
     All inside the 5 Growyze orgs. Both are fixed together on purpose: they sit
     side by side on Cost & Margins, so fixing one and not the other would leave
     two cards visibly disagreeing.

  IDEMPOTENT: full-text assignment, guarded so a re-run is a no-op.
  Run against: core (UAT/DEV/TEST).
==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

/*------------------------------------------------------------------------------
  Pre-flight. Fail loudly rather than silently editing the wrong column.
------------------------------------------------------------------------------*/
IF EXISTS (
    SELECT 1 FROM core.core.VisualisationQueries
    WHERE DataSetName = N'InvCOGSByCategory'
      AND VisualizationType IN (N'PieChartCard', N'StackedBarChartCard')
      AND Status = N'LIVE'
      AND ExecutionQuery IS NOT NULL)
BEGIN
    THROW 51055, 'InvCOGSByCategory now has ExecutionQuery populated. This script assumes QueryTemplate is the live column (verified 2026-08-03). Re-check before running -- editing QueryTemplate alone would be a silent no-op.', 1;
END

IF (SELECT COUNT(*) FROM core.core.VisualisationQueries
    WHERE DataSetName = N'InvCOGSByCategory'
      AND VisualizationType IN (N'PieChartCard', N'StackedBarChartCard')
      AND Status = N'LIVE') <> 2
BEGIN
    THROW 51056, 'Expected exactly 2 LIVE InvCOGSByCategory rows (PieChartCard + StackedBarChartCard). Found a different number -- investigate before writing.', 1;
END


/*==============================================================================
  1. PieChartCard
==============================================================================*/
DECLARE @Pie NVARCHAR(MAX) = N'
WITH org_pos AS (
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
Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT
    CATEGORY AS Label, COGS AS Value,
    ROW_NUMBER() OVER(ORDER BY COGS DESC) AS Id,
    ''linear'' AS Curve, ''total'' AS Stack, ''true'' AS Area,
    ''ascending'' AS StackOrder, ''false'' AS ShowMark, ''COGS'' AS LegendLabel
FROM Base
WHERE CATEGORY IS NOT NULL;

WITH org_pos AS (
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
Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT
    ''COGS by Category'' AS Title,
    ''Based on recipe cost. Costed sales only.'' AS Description,
    NULL AS Trend, NULL AS Chip,
    (SELECT NCHAR(163) + FORMAT(SUM(COGS),''N0'') FROM Base WHERE CATEGORY IS NOT NULL) AS PiePrimaryText,
    ''Total COGS'' AS PieSecondaryText;';

UPDATE core.core.VisualisationQueries
SET QueryTemplate = @Pie,
    ModifiedDate  = SYSUTCDATETIME(),
    ModifiedBy    = N'O5-Plan4-55'
WHERE DataSetName = N'InvCOGSByCategory'
  AND VisualizationType = N'PieChartCard'
  AND Status = N'LIVE'
  AND QueryTemplate <> @Pie;
PRINT '  InvCOGSByCategory / PieChartCard rewritten = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (0 on a re-run)';


/*==============================================================================
  2. StackedBarChartCard
==============================================================================*/
DECLARE @Bar NVARCHAR(MAX) = N'
WITH org_pos AS (
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
Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS,
        SUM(ISNULL(F.[NET_VALUE],0)) AS REVENUE,
        SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS GP
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[NET_VALUE],0) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT CATEGORY, ''COGS'' AS Label, COGS AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
    UNION ALL
    SELECT CATEGORY, ''Gross Profit'' AS Label, GP AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
) SUB;

SELECT ''Category'' AS XAxisLabel, ''Value'' AS YAxisLabel,
    ''COGS vs Gross Profit by Category'' AS Title,
    ''Based on recipe cost. Costed sales only.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value;';

UPDATE core.core.VisualisationQueries
SET QueryTemplate = @Bar,
    ModifiedDate  = SYSUTCDATETIME(),
    ModifiedBy    = N'O5-Plan4-55'
WHERE DataSetName = N'InvCOGSByCategory'
  AND VisualizationType = N'StackedBarChartCard'
  AND Status = N'LIVE'
  AND QueryTemplate <> @Bar;
PRINT '  InvCOGSByCategory / StackedBarChartCard rewritten = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (0 on a re-run)';


/*==============================================================================
  3. Filter grain: ProductCategories must sit on the same grain as the GROUP BY
     MIDDLE_1 -> TOP, on both card types.
     JSON_MODIFY is used rather than a string REPLACE so the surrounding JSON
     cannot be corrupted by whitespace differences between the two rows.
==============================================================================*/
DECLARE @OldGrain NVARCHAR(200) = N'COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])';
DECLARE @NewGrain NVARCHAR(200) = N'COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])';

UPDATE core.core.VisualisationQueries
SET FilterDefinitions = JSON_MODIFY(FilterDefinitions, '$.ProductCategories.column', @NewGrain),
    ModifiedDate      = SYSUTCDATETIME(),
    ModifiedBy        = N'O5-Plan4-55'
WHERE DataSetName = N'InvCOGSByCategory'
  AND VisualizationType IN (N'PieChartCard', N'StackedBarChartCard')
  AND Status = N'LIVE'
  AND JSON_VALUE(FilterDefinitions, '$.ProductCategories.column') = @OldGrain;
PRINT '  ProductCategories grain MIDDLE_1 -> TOP, rows = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 2; 0 on a re-run)';


/*==============================================================================
  Post-write assertions. Each states what would make it FAIL.
==============================================================================*/
SELECT
    DataSetName,
    VisualizationType,
    CASE WHEN CHARINDEX(N'CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - CALENDAR join is not CAST' END        AS Chk_DateCast,
    CASE WHEN CHARINDEX(N'INNER JOIN sales_src ss', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - no source scope' END                  AS Chk_SourceScope,
    CASE WHEN CHARINDEX(N'NULLIF(F.[AVG_NET_COST],0) IS NOT NULL', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - cost guard absent' END                AS Chk_CostGuard,
    CASE WHEN JSON_VALUE(FilterDefinitions, '$.ProductCategories.column') = @NewGrain
         THEN 'PASS' ELSE 'FAIL - filter grain still diverges from GROUP BY' END AS Chk_FilterGrain,
    CASE WHEN VisualizationType <> N'PieChartCard' THEN 'N/A - pie only'
         WHEN CHARINDEX(N'(SELECT NCHAR(163) + FORMAT(SUM(COGS),''N0'') FROM Base', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - centre total not derived from Base' END AS Chk_CentreFromBase
FROM core.core.VisualisationQueries
WHERE DataSetName = N'InvCOGSByCategory'
  AND VisualizationType IN (N'PieChartCard', N'StackedBarChartCard')
  AND Status = N'LIVE'
ORDER BY VisualizationType;
