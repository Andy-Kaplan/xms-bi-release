/* =============================================================================
   19_margebrut_groups_filter.sql
   -----------------------------------------------------------------------------
   Target server  : xms-bi-uat   (SQL Managed Instance)
   Target database: core          (writes to core.core.VisualisationQueries)
   Ledger         : O8
   Companion      : 20_margebrut_groups_filter_report.sql (report DB widget row)
   Purpose        : Add a working F&B group filter to the Marge Brut dashboard.

   Until now the dashboard's only filter was the date picker (fixed in `18`).
   This adds the one further filter the current fact grain can honestly support:
   `F_MARGEBRUT_MONTH` is GROUP_NAME x PERIOD_MONTH, so GROUP_NAME is the only
   remaining filterable axis. Outlet, revenue centre, supplier and property all
   need a new fact column and are deliberately out of scope.

   -----------------------------------------------------------------------------
   WHY A BESPOKE FILTER AND NOT THE EXISTING `ProductCategories`
   -----------------------------------------------------------------------------
   Reusing `ProductCategories` looks free and is a trap. That widget lists
   `D_PRODUCT` category names -- `'Wine'`, not the fact's `'Wines'` -- and it is
   not source-scoped, so on The Oak & Vine it also serves NCRAloha's categories.
   Picking "Wine" would emit `GROUP_NAME IN ('Wine')` and match nothing: no
   error, no warning, just an empty dashboard. Same silent-discard failure class
   as the date filter in `18`.

   Sourcing the widget from `F_MARGEBRUT_MONTH.GROUP_NAME` itself makes the
   offered values match the filtered column BY CONSTRUCTION, and means the list
   can never offer a value that returns zero rows.

   -----------------------------------------------------------------------------
   THE NAMING CONTRACT (verified, not assumed)
   -----------------------------------------------------------------------------
   `DashboardGridFilter.DataSet` name == the `FilterDefinitions` key each card
   must declare. Confirmed against the live RedLion wiring on UAT: the bespoke
   widget datasets `RedLionLocations`, `RedLionPayments`, `RedLionStaff`,
   `RedLionRevC`, `RedLionXProd`, `RedLionYProd` each appear BOTH as a
   `DashboardGridFilter.DataSet` value in `report` AND as a per-card
   `FilterDefinitions` key on the MI. So a new filter name is legitimate; the
   platform is data-driven here, not a fixed control list.

   `core.BuildDynamicWhereClause` cursors over the keys of the `@Filters` blob
   the front end sends, and for each looks up `$.<key>.column` in the card's
   `FilterDefinitions`. A key with no matching widget is never sent (that is
   exactly why `14`'s invented `PeriodMonth` key was inert), and a key whose
   `column` is `''` is `NULLIF`d to NULL and skipped.

   -----------------------------------------------------------------------------
   *** HARD LIMIT: THE COLUMN EXPRESSION MUST BE <= 100 CHARACTERS ***
   -----------------------------------------------------------------------------
   `BuildDynamicWhereClause` declares `@FilterColumn NVARCHAR(100)` and assigns
   `JSON_VALUE(...)` straight into it. A longer expression is **silently
   truncated**, producing either a syntax error or -- worse -- a clause that
   parses and filters on something else. The same applies to
   `@StartDateColumn` / `@EndDateColumn` / `@LocationColumn`.

   This is why the group filter for the supplier card is NOT the group-mapping
   `CASE` expression: that is ~700 characters and would be sliced mid-literal.
   Section 2 restructures the query instead so the group is exposed as a short
   column reference. Section 4 asserts the <= 100 rule over every mapped
   expression on all 9 datasets, so this cannot regress unnoticed.

   -----------------------------------------------------------------------------
   WHAT EACH CARD FILTERS ON
   -----------------------------------------------------------------------------
   8 month-grain datasets -> `F.[GROUP_NAME]` (14 chars). Every one aliases the
   fact as `F` at every injection site, verified by `18` section 4.

   `MargeBrutPurchasesBySupplier` -> `inv.[GROUP_NAME]` (16 chars), which does
   not exist until section 2 creates it.

   -----------------------------------------------------------------------------
   ONE COSMETIC CONSEQUENCE ON THE GRID, ACCEPTED DELIBERATELY
   -----------------------------------------------------------------------------
   The grid builds its rows from a fixed `canon` VALUES list of the 6 groups and
   LEFT JOINs the filtered `base` CTE onto it, so that a group with no data
   still renders as a row. Under a group filter the unselected groups therefore
   remain as rows with blank figures rather than disappearing.

   The `canon` list CANNOT be filtered, and this is a property of the engine
   rather than an oversight: `BuildDynamicWhereClause` builds ONE clause string
   and the card SP `REPLACE`s it into EVERY `@FilterClause` token, so every
   injection site must satisfy every mapped column. A site over `canon` would
   receive the date predicate `EOMONTH(F.[PERIOD_MONTH]) >= ...` too, and
   `canon` has no PERIOD_MONTH column -- an immediate error.

   Blank rows were chosen over the alternative of not filtering the grid at all,
   because leaving the grid unfiltered would make its GRAND TOTAL cost % DISAGREE
   with the hero KPI whenever a group is selected. Internal consistency beats
   cosmetics -- the same principle `18` applied to the supplier card's date grain.

   -----------------------------------------------------------------------------
   Idempotent: MERGE on the vis-query natural key, `JSON_MODIFY` (which
   overwrites an existing key rather than duplicating it), and a wholesale
   `UPDATE` of one QueryTemplate. Safe to re-run.
   ============================================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @me NVARCHAR(128) = SUSER_SNAME();
DECLARE @sql NVARCHAR(MAX);

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- 1. The filter widget's own dataset.
--
--    Shape follows the minimal `ParentOrganisations` FilterList that is live on
--    UAT: the QueryTemplate emits the four canonical columns already aliased
--    (Label / ID / ParentID / BottomLevel) and a second result set carrying the
--    widget Title, with ExecutionQuery left NULL (the platform reads
--    COALESCE(ExecutionQuery, QueryTemplate)).
--
--    ID is what ends up inside the emitted IN-list, so it must be the literal
--    GROUP_NAME string.
--
--    FLAT, no hierarchy. A 2-tier Food/Beverage roll-up was considered and
--    dropped: the `Channels` precedent gives leaf nodes their NAME as ID but
--    parent nodes a hub ID, which implies the client expands parents to leaves
--    before sending -- client behaviour that cannot be verified from SQL, and if
--    wrong the roll-up nodes would match GROUP_NAME never. The grid already
--    carries TOTAL FOOD / TOTAL BEVERAGE rows, so the roll-up is on screen
--    regardless.
--
--    No ORDER BY: if a future platform change wraps the template in a derived
--    table (as the ExecutionQuery pattern does), an unbounded ORDER BY becomes
--    illegal. Ordering is the client's business.
--
--    ParameterMappings is '{}' ON PURPOSE -- the list of available groups must
--    not shrink because of the date range currently picked.
--
--    Unqualified two-part names, so it runs against any organisation database.
-- ---------------------------------------------------------------------------
SET @sql = N'SELECT DISTINCT
    GROUP_NAME AS [Label],
    GROUP_NAME AS [ID],
    NULL       AS [ParentID],
    1          AS [BottomLevel]
FROM presentation.F_MARGEBRUT_MONTH

SELECT N''F&B Group'' AS [Title]';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'MargeBrutGroups', N'FilterList', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Status            = src.Status
WHEN MATCHED THEN UPDATE SET
    Version           = 1,
    QueryTemplate     = @sql,
    ParameterMappings = N'{}',
    FilterDefinitions = N'{}',
    OutputDefinitions = N'{"column_mappings": {}, "additional_datasets": []}',
    ExecutionQuery    = NULL,
    Description       = N'Marge Brut F&B reporting-group filter. Values read from presentation.F_MARGEBRUT_MONTH.GROUP_NAME so they match the filtered column by construction.',
    ModifiedDate      = GETDATE(),
    ModifiedBy        = @me
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (src.DataSetName, src.VisualizationType, 1, src.Status, @sql,
     N'{}', N'{}', N'{"column_mappings": {}, "additional_datasets": []}', NULL,
     N'Marge Brut F&B reporting-group filter. Values read from presentation.F_MARGEBRUT_MONTH.GROUP_NAME so they match the filtered column by construction.',
     @me, @me, GETDATE(), GETDATE());

-- ---------------------------------------------------------------------------
-- 2. Restructure the supplier card so the reporting group is a SHORT column
--    reference, because the group-mapping CASE cannot survive NVARCHAR(100).
--
--    `presentation.D_INVITEM` becomes a derived table that pre-computes
--    GROUP_NAME, still aliased `inv`. Both aliases the date mapping depends on
--    (`p` for F_PURCHASES_DAY, `inv`) therefore stay in scope at both injection
--    sites, so `18`'s ParameterMappings keep working untouched.
--
--    MEASURE-NEUTRAL BY CONSTRUCTION. The old predicate was
--        (TOP_NAME='Beverages' AND MIDDLE_1_NAME IN (<13 values>)) OR TOP_NAME='Food'
--    and `inv.GROUP_NAME IS NOT NULL` is true for exactly that set: the CASE
--    covers the same 13 Beverages subcategories, and its final unqualified
--    `TOP_NAME='Food'` arm catches all Food. Section 4 states the totals that
--    must be unchanged afterwards.
--
--    Mapping mirrors 13_f_margebrut_month_control.sql. Keep the two in step.
-- ---------------------------------------------------------------------------
SET @sql = N'SELECT
  COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME) AS BarLabel,
  ROW_NUMBER() OVER (ORDER BY SUM(p.LINE_TOTAL) DESC) AS BarLabelSort,
  CAST(SUM(p.LINE_TOTAL) AS DECIMAL(18,2)) AS BarValue,
  ROW_NUMBER() OVER (ORDER BY SUM(p.LINE_TOTAL) ASC) AS BarValueSort
FROM presentation.F_PURCHASES_DAY p
JOIN presentation.D_SUPPLIER sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID
JOIN (
    SELECT d.BOTTOM_HUB_ID,
        CASE
            WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Soft Drinks'', N''Water'', N''Juices'')                THEN N''Soft Drinks''
            WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Spirits'', N''Spirit'')                                THEN N''Spirit''
            WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Wine'', N''Wines'')                                    THEN N''Wines''
            WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Bottled Beer'', N''Beer & Cider'', N''Draught Beer'')  THEN N''Bottled Beer''
            WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Hot Drinks'', N''Coffee'', N''Tea'')                   THEN N''Breakfast''
            WHEN d.TOP_NAME = N''Food''      AND d.MIDDLE_1_NAME = N''Breakfast''                                             THEN N''Breakfast''
            WHEN d.TOP_NAME = N''Food''                                                                                       THEN N''Food''
        END AS GROUP_NAME
    FROM presentation.D_INVITEM d
    WHERE d.BOTTOM_SRC LIKE N''int[_]growyze%''
) inv ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
WHERE 1=1
AND inv.GROUP_NAME IS NOT NULL
@FilterClause
GROUP BY COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME)

SELECT
  N''Supplier'' AS XAxisLabel,
  N''Purchases (GBP)'' AS YAxisLabel,
  N''Food Purchases by Supplier'' AS Title,
  N''Live'' AS Description,
  NULL AS Trend,
  (SELECT CAST(SUM(p.LINE_TOTAL) AS DECIMAL(18,2))
   FROM presentation.F_PURCHASES_DAY p
   JOIN (
       SELECT d.BOTTOM_HUB_ID,
           CASE
               WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Soft Drinks'', N''Water'', N''Juices'')                THEN N''Soft Drinks''
               WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Spirits'', N''Spirit'')                                THEN N''Spirit''
               WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Wine'', N''Wines'')                                    THEN N''Wines''
               WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Bottled Beer'', N''Beer & Cider'', N''Draught Beer'')  THEN N''Bottled Beer''
               WHEN d.TOP_NAME = N''Beverages'' AND d.MIDDLE_1_NAME IN (N''Hot Drinks'', N''Coffee'', N''Tea'')                   THEN N''Breakfast''
               WHEN d.TOP_NAME = N''Food''      AND d.MIDDLE_1_NAME = N''Breakfast''                                             THEN N''Breakfast''
               WHEN d.TOP_NAME = N''Food''                                                                                       THEN N''Food''
           END AS GROUP_NAME
       FROM presentation.D_INVITEM d
       WHERE d.BOTTOM_SRC LIKE N''int[_]growyze%''
   ) inv ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
   WHERE 1=1
   AND inv.GROUP_NAME IS NOT NULL
   @FilterClause) AS TotalValue,
  NULL AS Chip';

UPDATE [core].[core].[VisualisationQueries]
SET QueryTemplate = @sql,
    ModifiedDate  = GETDATE(),
    ModifiedBy    = @me
WHERE Status = N'LIVE' AND DataSetName = N'MargeBrutPurchasesBySupplier';

IF @@ROWCOUNT <> 1
    RAISERROR(N'(2) FAILED: expected exactly 1 MargeBrutPurchasesBySupplier row.', 16, 1);

-- ---------------------------------------------------------------------------
-- 3. Declare the `MargeBrutGroups` key on every card that should respond.
--
--    JSON_MODIFY + JSON_QUERY inserts the definition as an OBJECT (JSON_MODIFY
--    alone would store it as an escaped string, which JSON_VALUE could not then
--    read as `$.MargeBrutGroups.column`). Overwrites on re-run, so idempotent,
--    and it preserves the existing PeriodMonth key and `18`'s ParameterMappings
--    rather than rewriting the whole record.
--
--    dataType VARCHAR (not INT/DECIMAL) so the engine wraps each value in single
--    quotes -- correct for group-name strings.
-- ---------------------------------------------------------------------------
UPDATE [core].[core].[VisualisationQueries]
SET FilterDefinitions = JSON_MODIFY(FilterDefinitions, '$.MargeBrutGroups',
        JSON_QUERY(N'{"column": "F.[GROUP_NAME]", "type": "IN", "dataType": "VARCHAR"}')),
    ModifiedDate = GETDATE(),
    ModifiedBy   = @me
WHERE Status = N'LIVE'
  AND DataSetName IN (N'MargeBrutGrid', N'MargeBrutCostRatioKPI', N'MargeBrutConsumptionKPI',
                      N'MargeBrutTurnoverKPI', N'MargeBrutPurchasesKPI',
                      N'MargeBrutCostRatioByGroup', N'MargeBrutConsumptionMix',
                      N'MargeBrutCompsSplit');

IF @@ROWCOUNT <> 8
    RAISERROR(N'(3a) FAILED: expected exactly 8 month-grain MargeBrut datasets.', 16, 1);

-- The supplier card, on the column section 2 created.
UPDATE [core].[core].[VisualisationQueries]
SET FilterDefinitions = JSON_MODIFY(FilterDefinitions, '$.MargeBrutGroups',
        JSON_QUERY(N'{"column": "inv.[GROUP_NAME]", "type": "IN", "dataType": "VARCHAR"}')),
    ModifiedDate = GETDATE(),
    ModifiedBy   = @me
WHERE Status = N'LIVE'
  AND DataSetName = N'MargeBrutPurchasesBySupplier';

IF @@ROWCOUNT <> 1
    RAISERROR(N'(3b) FAILED: expected exactly 1 MargeBrutPurchasesBySupplier row.', 16, 1);

-- `MargeBrutCompsSplit` is included above even though `17` soft-deleted its
-- DashboardGridItem: the vis query is still LIVE, and re-enabling the card is a
-- single UPDATE. Leaving it out would make the filter silently not apply on the
-- day someone flips it back on.

COMMIT TRANSACTION;

-- ===========================================================================
-- 4. VERIFY
-- ===========================================================================

-- 4a. The widget dataset exists and is LIVE.
SELECT
    N'4a widget dataset' AS Check_Name,
    COUNT(*)             AS Records,
    CASE WHEN COUNT(*) = 1 THEN N'PASS' ELSE N'FAIL - MargeBrutGroups FilterList missing' END AS Verdict
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName = N'MargeBrutGroups' AND VisualizationType = N'FilterList' AND Status = N'LIVE';

-- 4b. Every card declares the key, resolved to a non-empty column expression.
SELECT
    DataSetName,
    JSON_VALUE(FilterDefinitions, '$.MargeBrutGroups.column')   AS GroupColumn,
    JSON_VALUE(FilterDefinitions, '$.MargeBrutGroups.type')     AS FilterType,
    JSON_VALUE(FilterDefinitions, '$.MargeBrutGroups.dataType') AS DataType,
    CASE WHEN NULLIF(JSON_VALUE(FilterDefinitions, '$.MargeBrutGroups.column'), '') IS NOT NULL
          AND JSON_VALUE(FilterDefinitions, '$.MargeBrutGroups.type') = 'IN'
         THEN N'PASS' ELSE N'FAIL - group filter inert on this card' END AS Verdict
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE'
  AND VisualizationType <> N'FilterList'
ORDER BY DataSetName;

-- 4c. THE TRUNCATION GUARD. Every mapped expression the engine loads into an
--     NVARCHAR(100) variable must fit. Covers the three ParameterMappings slots
--     and every FilterDefinitions column, on all 9 datasets.
SELECT
    N'4c expressions <= 100 chars' AS Check_Name,
    SUM(CASE WHEN LEN(Expr) > 100 THEN 1 ELSE 0 END) AS OverLimit,
    MAX(LEN(Expr))                                   AS LongestExpr,
    CASE WHEN SUM(CASE WHEN LEN(Expr) > 100 THEN 1 ELSE 0 END) = 0
         THEN N'PASS' ELSE N'FAIL - an expression will be silently truncated' END AS Verdict
FROM (
    SELECT NULLIF(JSON_VALUE(ParameterMappings, '$.StartDate'),    '') AS Expr
    FROM [core].[core].[VisualisationQueries] WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE'
    UNION ALL
    SELECT NULLIF(JSON_VALUE(ParameterMappings, '$.EndDate'),      '')
    FROM [core].[core].[VisualisationQueries] WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE'
    UNION ALL
    SELECT NULLIF(JSON_VALUE(ParameterMappings, '$.LocationList'), '')
    FROM [core].[core].[VisualisationQueries] WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE'
    UNION ALL
    SELECT NULLIF(JSON_VALUE(j.value, '$.column'), '')
    FROM [core].[core].[VisualisationQueries] v
    CROSS APPLY OPENJSON(v.FilterDefinitions) j
    WHERE v.DataSetName LIKE N'MargeBrut%' AND v.Status = N'LIVE'
) e
WHERE Expr IS NOT NULL;

-- 4d. Alias scope. Every `@FilterClause` site must have the mapped alias in
--     scope, so the count of injection sites must not exceed the count of
--     aliased FROM clauses. Same check shape as `18` section 4, re-pointed at
--     the supplier card's new derived table (`) inv ON`).
SELECT
    DataSetName,
    Sites,
    Aliases,
    CASE WHEN Sites = Aliases THEN N'PASS'
         ELSE N'FAIL - an injection site lacks the mapped alias' END AS Verdict
FROM (
    SELECT DataSetName,
        (LEN(q) - LEN(REPLACE(q, N'@FilterClause', N''))) / LEN(N'@FilterClause') AS Sites,
        CASE WHEN DataSetName = N'MargeBrutPurchasesBySupplier'
             THEN (LEN(q) - LEN(REPLACE(q, N') inv ON', N''))) / LEN(N') inv ON')
             ELSE (LEN(q) - LEN(REPLACE(q, N'F_MARGEBRUT_MONTH F', N''))) / LEN(N'F_MARGEBRUT_MONTH F')
        END AS Aliases
    FROM (
        SELECT DataSetName, COALESCE(ExecutionQuery, QueryTemplate) AS q
        FROM [core].[core].[VisualisationQueries]
        WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE'
          AND VisualizationType <> N'FilterList'
    ) s
) t
ORDER BY DataSetName;

/* ---------------------------------------------------------------------------
   4e. MEASURE-NEUTRALITY OF SECTION 2 -- run per organisation, unfiltered.
       Section 2 rewrote the supplier card's scope predicate into an equivalent
       form, so the totals MUST be unchanged from the pre-19 figures:

           The Oak & Vine (16) : GBP 22,544.37 over 3 suppliers
           Ibis Gloucester (21) : GBP 22,544.37 over 3 suppliers
           (identical because org 16's Growyze feed IS org 21's -- ledger O24)

       Bidfood 16,535.89 / Reynolds Catering 3,782.45 / Matthew Clark 2,226.03

       Replace the database name and run from `core`:

       SELECT COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME) AS Supplier,
              CAST(SUM(p.LINE_TOTAL) AS DECIMAL(18,2)) AS Purchases
       FROM [{orgdb}].presentation.F_PURCHASES_DAY p
       JOIN [{orgdb}].presentation.D_SUPPLIER sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID
       JOIN (SELECT d.BOTTOM_HUB_ID, CASE ... END AS GROUP_NAME
             FROM [{orgdb}].presentation.D_INVITEM d
             WHERE d.BOTTOM_SRC LIKE N'int[_]growyze%') inv
            ON inv.BOTTOM_HUB_ID = p.INVITEM_HUB_ID
       WHERE inv.GROUP_NAME IS NOT NULL
       GROUP BY COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME);

   ---------------------------------------------------------------------------
   ROLLBACK
   ---------------------------------------------------------------------------
   Retire the widget dataset and drop the key from all 9 cards. Section 2's
   restructure is measure-neutral and can be left in place; if it must also be
   reverted, re-run `14` followed by `16` and `18` in that order.

       UPDATE [core].[core].[VisualisationQueries]
       SET Status = N'RETIRED', ModifiedDate = GETDATE()
       WHERE DataSetName = N'MargeBrutGroups' AND VisualizationType = N'FilterList';

       UPDATE [core].[core].[VisualisationQueries]
       SET FilterDefinitions = JSON_MODIFY(FilterDefinitions, '$.MargeBrutGroups', NULL),
           ModifiedDate = GETDATE()
       WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE';

   Also soft-delete the widget rows -- see 20_margebrut_groups_filter_report.sql.
   --------------------------------------------------------------------------- */
