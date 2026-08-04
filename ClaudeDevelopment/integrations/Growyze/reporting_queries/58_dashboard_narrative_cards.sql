/*==============================================================================
  58_dashboard_narrative_cards.sql
  O5 Plan 4 -- three new narrative cards

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md

  Creates:
    OverviewStockAlert      StaticBoxCard(16)  Overview,   sortOrder 5
    InvCountHealthAlert     StaticBoxCard(16)  Inventory,  sortOrder 5
    SPProductSectionHeader  MarkdownCard(17)   Sales,      sortOrder 90

  NOTE: the Inventory banner is NOT the design doc's "InvVarianceAlert". That
  version was built, measured and rejected as untrustworthy on this data -- see
  the long comment at section 3 before reinstating anything variance-based.

  WHY THESE EXIST
    Nothing on any of the three boards tells anyone what to DO. A venue manager
    sees "Waste Cost GBP 186" and has no idea whether that is good. The platform
    has exactly ONE conditional-visibility mechanism, and it is a happy accident
    of the query contract: StaticBoxCard and MarkdownCard render NOTHING when
    their query returns zero rows. So an alert costs nothing when all is well.
    Margin Management already uses this for a high-variance banner.

  RUN ORDER: this script FIRST (it creates the datasets), then report_config/08
  (grants + dataset map), then report_config/07 (layout). 07 refuses to run
  without 08.

  !! PROD GATE: StaticBoxCard(16) and MarkdownCard(17) are UAT-only card types.
  Both must be carried into v1.1 core (core.core.DeploymentObjects already holds
  them -- MarkdownCard at ExecutionOrder 64) and deployed per org before these
  cards reach Prod. Without the SP the card RAISES an error, it does not hide.

  DELIBERATELY UNFILTERED BY THE DATE PICKER
    Both alerts set ParameterMappings values to empty strings, exactly as the
    live InvMMHeader StaticBoxCard does. This is a design decision, not an
    oversight: an alert reports CURRENT operational state, not the state of
    whatever period the user happens to have selected. A stocktake that is 60
    days overdue is overdue regardless of the date range on screen.

    It is also a hard constraint. @FilterClause is injected into the same table
    scan, so a query cannot ask for a TRAILING window that lies outside the
    selected range while also honouring that range -- the two requirements are
    contradictory. The waste-spike trigger below therefore does its own
    unfiltered scan (it simply omits @FilterClause), which is what makes a
    period-over-period comparison possible at all.

  TEXT LIVES IN core.core.SuggestionTemplates, not in the query -- following
  InvMissingRecipesBanner / InvHighVarianceBanner. Severity is UPPERCASE
  ('WARNING' / 'ERROR' / 'INFO') to match the existing rows. TemplateID is an
  IDENTITY column and is omitted.

  IDEMPOTENT: MERGE on natural keys throughout (TemplateName; and
  DataSetName + VisualizationType).
  Run against: core (UAT/DEV/TEST).
==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

/*==============================================================================
  1. Banner text templates
==============================================================================*/
MERGE INTO core.core.SuggestionTemplates AS tgt
USING (VALUES
    (N'OverviewStocktakeOverdueBanner', N'Inventory', N'WARNING', N'Banner',
     N'No stocktake has been recorded for {days} days. Stock values and variance on this dashboard are only as current as the last count.', 50),
    (N'OverviewWasteSpikeBanner', N'Inventory', N'WARNING', N'Banner',
     N'Waste cost over the last 28 days is {pct}% above the preceding average. Review the waste breakdown beside the stock activity trend.', 60),
    (N'InvLocationCountLagBanner', N'Inventory', N'ERROR', N'Banner',
     N'{location} was last counted {count} days before your most recent stocktake elsewhere. Its stock figures on this dashboard are out of date.', 70),
    (N'InvLocationNoCostBanner', N'Inventory', N'WARNING', N'Banner',
     N'{count} counted items at {location} have no cost, so their stock value is missing from this dashboard.', 80)
) AS src (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder)
   ON tgt.TemplateName = src.TemplateName
WHEN MATCHED THEN UPDATE SET
    Category     = src.Category,
    Severity     = src.Severity,
    OutputType   = src.OutputType,
    TemplateText = src.TemplateText,
    SortOrder    = src.SortOrder,
    IsActive     = 1,
    ModifiedDate = SYSUTCDATETIME()
WHEN NOT MATCHED THEN
    INSERT (TemplateName, Category, Severity, OutputType, TemplateText, SortOrder, IsActive, CreatedDate, ModifiedDate)
    VALUES (src.TemplateName, src.Category, src.Severity, src.OutputType, src.TemplateText, src.SortOrder, 1, SYSUTCDATETIME(), SYSUTCDATETIME());

PRINT '  SuggestionTemplates upserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 4)';


/*==============================================================================
  2. OverviewStockAlert -- StaticBoxCard

  Two independent triggers, at most ONE row returned (a banner is one box):
    a) Stocktake staleness -- more than 35 days since the most recent count.
       35 days rather than 28 so a monthly count that slips by a week does not
       cry wolf.
    b) Waste spike -- waste cost in the last 28 days more than 20% above the
       mean of the preceding 84 days (three comparable 28-day blocks).

  Staleness outranks the waste spike: if counts are stale, every other inventory
  number on the board is suspect, so that is the more useful thing to say.

  Scoped to Growyze inventory via invitem.[BOTTOM_SRC]. Unlike InvUseAnalisys
  (which serves a 6th non-Growyze org) this dataset is NEW and lives only on the
  Growyze Overview grid, so hardcoding the source is safe here.

  NOT filtered by @FilterClause -- see the header note.
==============================================================================*/
DECLARE @StockAlert NVARCHAR(MAX) = N'
WITH counts AS (
    SELECT
        MAX(CAST(FC.[COUNT_DATE] AS DATE)) AS last_count_date
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE invitem.[BOTTOM_SRC] = ''int_growyze001''
),
waste AS (
    SELECT
        SUM(CASE WHEN CAST(FU.[COUNT_DATE] AS DATE) >= DATEADD(DAY, -28, CAST(GETDATE() AS DATE))
                 THEN ABS(ISNULL(FU.[WASTE_QTY],0)) * ISNULL(FU.[UOM_COST],0) END) AS recent_waste,
        SUM(CASE WHEN CAST(FU.[COUNT_DATE] AS DATE) <  DATEADD(DAY, -28,  CAST(GETDATE() AS DATE))
                  AND CAST(FU.[COUNT_DATE] AS DATE) >= DATEADD(DAY, -112, CAST(GETDATE() AS DATE))
                 THEN ABS(ISNULL(FU.[WASTE_QTY],0)) * ISNULL(FU.[UOM_COST],0) END) / 3.0 AS baseline_waste
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE invitem.[BOTTOM_SRC] = ''int_growyze001''
),
triggers AS (
    SELECT 1 AS pri, N''OverviewStocktakeOverdueBanner'' AS TemplateName,
           N''{days}'' AS Token,
           CAST(DATEDIFF(DAY, c.last_count_date, CAST(GETDATE() AS DATE)) AS NVARCHAR(20)) AS TokenValue
    FROM counts c
    WHERE c.last_count_date IS NOT NULL
      AND DATEDIFF(DAY, c.last_count_date, CAST(GETDATE() AS DATE)) > 35

    UNION ALL

    SELECT 2, N''OverviewWasteSpikeBanner'',
           N''{pct}'',
           CAST(CAST(ROUND((w.recent_waste - w.baseline_waste) * 100.0 / NULLIF(w.baseline_waste,0), 0) AS INT) AS NVARCHAR(20))
    FROM waste w
    WHERE NULLIF(w.baseline_waste, 0) IS NOT NULL
      AND w.recent_waste > w.baseline_waste * 1.2
)
SELECT TOP 1
    t.Severity AS severity,
    REPLACE(t.TemplateText, tr.Token, tr.TokenValue) AS text,
    NULL AS title,
    ''True'' AS dismissable
FROM triggers tr
JOIN [core].[core].[SuggestionTemplates] t
    ON t.TemplateName = tr.TemplateName
   AND t.IsActive = 1
ORDER BY tr.pri;';

MERGE INTO core.core.VisualisationQueries AS tgt
USING (VALUES (N'OverviewStockAlert', N'StaticBoxCard')) AS src (DataSetName, VisualizationType)
   ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate     = @StockAlert,
    ExecutionQuery    = NULL,
    ParameterMappings = N'{"LocationList":"","StartDate":"","EndDate":""}',
    FilterDefinitions = N'{}',
    Status            = N'LIVE',
    Description       = N'Conditional Overview banner: stocktake overdue, or waste cost above its trailing average. Zero rows when healthy.',
    ModifiedDate      = SYSUTCDATETIME(),
    ModifiedBy        = N'O5-Plan4-58'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
            ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
    VALUES (src.DataSetName, src.VisualizationType, 1, N'LIVE', @StockAlert,
            N'{"LocationList":"","StartDate":"","EndDate":""}', N'{}',
            N'Conditional Overview banner: stocktake overdue, or waste cost above its trailing average. Zero rows when healthy.',
            SYSUTCDATETIME(), SYSUTCDATETIME(), N'O5-Plan4-58', N'O5-Plan4-58');

PRINT '  OverviewStockAlert upserted';


/*==============================================================================
  3. InvCountHealthAlert -- StaticBoxCard

  *** THIS CARD WAS RE-BASED. READ THIS BEFORE CHANGING IT BACK. ***

  The design doc specified an "InvVarianceAlert" firing when a location's
  variance exceeds 15% of net sales. That was BUILT, TESTED AND REJECTED.
  It cannot be made trustworthy on this data today:

      SUM(ABS(VARIANCE)) / SUM(ABS(THEO_USAGE)) per location, measured 2026-08-03
          Padel Social / O2           4,385%   <-- would fire
          Padel Social / Earls Court    121%   <-- would fire
          Dirty Sixth                    13%       silent

      and the underlying magnitudes are not survivable:
          Dirty Sixth  SUM(ABS(THEO_USAGE)) = 46,654,926 across 1,334 rows
          Padel        SUM(ABS(THEO_USAGE)) = 13,581,549, THEO_USAGE zero in 87%

  46.6M units of theoretical usage across 1,334 stocktake lines at one bar is not
  a plausible quantity. This is the open "Padel/Dirty Sixth stock values remain
  implausible" sub-item and/or O33 (F_INV_COUNTS_DAY movement fan-out) surfacing
  through a different column. A banner announcing "O2 is showing 4,385% variance"
  at ERROR severity, at the top of the dashboard, on all five orgs, would report a
  DATA DEFECT as an OPERATIONAL problem and destroy trust in the whole board.

  WHY THE QUANTITY METRICS FAIL AND THE ONES BELOW DO NOT
    A variance percentage is a ratio of TWO DIFFERENT measures (VARIANCE over
    THEO_USAGE), so a unit-scale error in either does not cancel -- it propagates
    straight into the ratio. Every trigger below rests only on DATES, on IDENTITY,
    or on COST NULLITY. None reads a quantity, so none can be distorted by the
    scale problem. (Contrast OverviewStockAlert's waste trigger, which is a ratio
    of the SAME measure across two time windows -- there a constant scale error
    cancels, which is why that one is safe.)

  TWO TRIGGERS, at most one row:
    1) COUNT LAG (ERROR) -- a location last counted more than 35 days BEFORE the
       org's most recent stocktake. Deliberately relative to the org rather than
       to today, so it cannot duplicate OverviewStockAlert's org-wide staleness
       banner, and so it is correctly silent on single-venue orgs.
    2) MISSING COSTS (WARNING) -- a location with 5 or more counted items
       carrying no cost, so their stock value is silently absent. Mirrors the
       shape of the live InvMissingRecipesBanner ("{count} menu items are missing
       recipes"), which is the established precedent for a count-based banner.

  MEASURED BEHAVIOUR TODAY (2026-08-03), i.e. this card is not shipped unseen:
       Padel / Earls Court  6 items no cost of 379 counted  -> TRIGGER 2 FIRES
       Padel / O2           5 items no cost of 330 counted  -> TRIGGER 2 FIRES
       Gloucester           1 item  no cost of 174 counted  -> silent
       count lag            0 days everywhere               -> TRIGGER 1 silent
    So trigger 2 is demonstrably reachable and trigger 1 demonstrably self-hides.
    A banner that has never been observed firing is a banner that has not been
    tested.

  RENAMED from InvVarianceAlert: the dataset no longer measures variance, and it
  had not been wired anywhere yet, so the rename is free. Scripts 07 and 08 use
  the new name.
==============================================================================*/
DECLARE @CountHealth NVARCHAR(MAX) = N'
WITH per_location AS (
    SELECT
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME]) AS location_name,
        MAX(CAST(FC.[COUNT_DATE] AS DATE)) AS last_count,
        COUNT(DISTINCT FC.INVITEM_HUB_ID) AS items_counted,
        COUNT(DISTINCT CASE WHEN ISNULL(FC.[UOM_COST], 0) = 0 THEN FC.INVITEM_HUB_ID END) AS items_no_cost
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem   ON FC.INVITEM_HUB_ID  = invitem.BOTTOM_HUB_ID
    WHERE invitem.[BOTTOM_SRC] = ''int_growyze001''
      AND COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME]) <> ''Unknown''
    GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME])
),
org AS (
    SELECT MAX(last_count) AS org_last_count FROM per_location
),
triggers AS (
    SELECT 1 AS pri,
           N''InvLocationCountLagBanner'' AS TemplateName,
           pl.location_name AS Loc,
           CAST(DATEDIFF(DAY, pl.last_count, o.org_last_count) AS NVARCHAR(20)) AS Val,
           DATEDIFF(DAY, pl.last_count, o.org_last_count) AS Rank_
    FROM per_location pl
    CROSS JOIN org o
    WHERE DATEDIFF(DAY, pl.last_count, o.org_last_count) > 35

    UNION ALL

    SELECT 2,
           N''InvLocationNoCostBanner'',
           pl.location_name,
           CAST(pl.items_no_cost AS NVARCHAR(20)),
           pl.items_no_cost
    FROM per_location pl
    WHERE pl.items_no_cost >= 5
)
SELECT TOP 1
    t.Severity AS severity,
    REPLACE(REPLACE(t.TemplateText, ''{location}'', tr.Loc), ''{count}'', tr.Val) AS text,
    NULL AS title,
    ''True'' AS dismissable
FROM triggers tr
JOIN [core].[core].[SuggestionTemplates] t
    ON t.TemplateName = tr.TemplateName
   AND t.IsActive = 1
ORDER BY tr.pri, tr.Rank_ DESC;';

MERGE INTO core.core.VisualisationQueries AS tgt
USING (VALUES (N'InvCountHealthAlert', N'StaticBoxCard')) AS src (DataSetName, VisualizationType)
   ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate     = @CountHealth,
    ExecutionQuery    = NULL,
    ParameterMappings = N'{"LocationList":"","StartDate":"","EndDate":""}',
    FilterDefinitions = N'{}',
    Status            = N'LIVE',
    Description       = N'Conditional Inventory Control banner: a location lagging the org''s latest stocktake, or carrying counted items with no cost. Dates and cost nullity only - reads no quantity. Zero rows when healthy.',
    ModifiedDate      = SYSUTCDATETIME(),
    ModifiedBy        = N'O5-Plan4-58'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
            ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
    VALUES (src.DataSetName, src.VisualizationType, 1, N'LIVE', @CountHealth,
            N'{"LocationList":"","StartDate":"","EndDate":""}', N'{}',
            N'Conditional Inventory Control banner: a location lagging the org''s latest stocktake, or carrying counted items with no cost. Dates and cost nullity only - reads no quantity. Zero rows when healthy.',
            SYSUTCDATETIME(), SYSUTCDATETIME(), N'O5-Plan4-58', N'O5-Plan4-58');

PRINT '  InvCountHealthAlert upserted';


/*==============================================================================
  4. SPProductSectionHeader -- MarkdownCard

  A section divider, splitting Sales & Profitability into "how the business
  performed" (above) and "which products did it" (below). Without it, thirteen
  cards read as one undifferentiated scroll.

  Unlike the two alerts this ALWAYS returns exactly one row -- a divider that
  came and went would be worse than none. It takes no parameters and touches no
  fact table, so it cannot be affected by data state.
==============================================================================*/
DECLARE @SectionHdr NVARCHAR(MAX) = N'
SELECT N''## Product & menu detail'' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
     + N''Which products drove the figures above. Use the Products filter to narrow every card on this dashboard.'' AS markdown;';

MERGE INTO core.core.VisualisationQueries AS tgt
USING (VALUES (N'SPProductSectionHeader', N'MarkdownCard')) AS src (DataSetName, VisualizationType)
   ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate     = @SectionHdr,
    ExecutionQuery    = NULL,
    ParameterMappings = N'{}',
    FilterDefinitions = N'{}',
    Status            = N'LIVE',
    Description       = N'Static section divider on Sales & Profitability. Always returns one row.',
    ModifiedDate      = SYSUTCDATETIME(),
    ModifiedBy        = N'O5-Plan4-58'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
            ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy)
    VALUES (src.DataSetName, src.VisualizationType, 1, N'LIVE', @SectionHdr,
            N'{}', N'{}',
            N'Static section divider on Sales & Profitability. Always returns one row.',
            SYSUTCDATETIME(), SYSUTCDATETIME(), N'O5-Plan4-58', N'O5-Plan4-58');

PRINT '  SPProductSectionHeader upserted';

COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '58 ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH


/*==============================================================================
  Assertions.

  Chk_SelfHiding is the substantive one. A StaticBoxCard that can NEVER return
  zero rows is a permanent banner, which defeats the entire mechanism -- so the
  presence of a threshold predicate is asserted, not assumed. SPProductSectionHeader
  is reported N/A because it is INTENDED to always return a row.
==============================================================================*/
SELECT
    DataSetName,
    VisualizationType,
    Status,
    CASE WHEN ExecutionQuery IS NULL THEN 'PASS' ELSE 'FAIL - ExecutionQuery set; QueryTemplate would be ignored' END AS Chk_TemplateIsLive,
    CASE WHEN DataSetName = N'SPProductSectionHeader' THEN 'N/A - always-on divider'
         WHEN CHARINDEX(N'> 35', QueryTemplate) > 0 OR CHARINDEX(N'>= 5', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - no threshold predicate; banner could never self-hide' END AS Chk_SelfHiding,
    CASE WHEN DataSetName = N'SPProductSectionHeader' THEN 'N/A'
         WHEN CHARINDEX(N'int_growyze001', QueryTemplate) > 0
         THEN 'PASS' ELSE 'FAIL - not source-scoped' END AS Chk_SourceScope,
    /* The re-basing is load-bearing. This FAILS if a quantity-derived variance
       ratio has been reintroduced into the Inventory banner. */
    CASE WHEN DataSetName <> N'InvCountHealthAlert' THEN 'N/A'
         WHEN CHARINDEX(N'THEO_USAGE', QueryTemplate) = 0
              AND CHARINDEX(N'[VARIANCE]', QueryTemplate) = 0
         THEN 'PASS' ELSE 'FAIL - reads a quantity column; the scale defect propagates into the threshold' END AS Chk_NoQuantityMetric
FROM core.core.VisualisationQueries
WHERE DataSetName IN (N'OverviewStockAlert', N'InvCountHealthAlert', N'SPProductSectionHeader')
ORDER BY DataSetName;

/* Templates the queries depend on must exist and be active, or the JOIN returns
   nothing and the banner silently never fires -- a false "all is well".
   This is the failure mode a "no banner showing" smoke test cannot distinguish
   from "everything is healthy", which is why it is asserted here. */
SELECT TemplateName,
       CASE WHEN IsActive = 1 THEN 'PASS' ELSE 'FAIL - inactive; banner can never fire' END AS Chk_Active,
       Severity, OutputType
FROM core.core.SuggestionTemplates
WHERE TemplateName IN (N'OverviewStocktakeOverdueBanner', N'OverviewWasteSpikeBanner',
                       N'InvLocationCountLagBanner', N'InvLocationNoCostBanner')
ORDER BY TemplateName;
