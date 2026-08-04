/* =============================================================================
   18_date_filter_parameter_mappings.sql
   -----------------------------------------------------------------------------
   Target server  : xms-bi-uat   (SQL Managed Instance)
   Target database: core          (writes to core.core.VisualisationQueries)
   Ledger         : O8
   Purpose        : Make the dashboard's date filter actually filter.

   SYMPTOM
   Changing the date range on the Marge Brut dashboard changes nothing. Every
   card keeps showing all months (Apr-Jul 2026 on The Oak & Vine: 24 rows,
   turnover GBP 55,221.02, cost 14.8%) regardless of what is picked.

   ROOT CAUSE -- the date filter was wired to the wrong mechanism
   The platform has TWO independent filter channels, and `14` used the one that
   cannot carry a date range:

     ParameterMappings  ->  @StartDate / @EndDate / @LocationList
                            core.BuildDynamicWhereClause reads
                              JSON_VALUE(@ParameterMappings,'$.StartDate')
                              JSON_VALUE(@ParameterMappings,'$.EndDate')
                            and only emits a date predicate when that lookup
                            returns a column:
                              IF @StartDate IS NOT NULL AND @StartDateColumn IS NOT NULL
                                  ... ' AND ' + @StartDateColumn + ' >= ...'
                            *** THIS is the dashboard date picker. ***

     FilterDefinitions  ->  the @Filters JSON blob (FilterList cards / chips),
                            keyed by filter name, IN-lists only.

   All 9 `MargeBrut*` datasets shipped with `ParameterMappings = '{}'`. So
   `@StartDateColumn` / `@EndDateColumn` come back NULL, both `IF` blocks are
   skipped, and the picked dates are **silently discarded** -- no error, no empty
   card, just an unfiltered dashboard.

   `14` instead invented a `FilterDefinitions` key called `PeriodMonth`. That key
   exists on these 9 datasets and **nowhere else in the platform** (confirmed by
   enumerating every key across all LIVE records: 35 distinct keys, and not one
   date-typed filter among the other 34). Nothing emits it, so it never matched;
   and an `IN`-list of discrete months is the wrong shape for a range picker
   anyway. It is left in place here -- inert, harmless, and not what this script
   is fixing -- but it is dead weight, not a working filter.

   THE FIX, AND WHY IT IS NOT THE OBVIOUS ONE
   `F_MARGEBRUT_MONTH.PERIOD_MONTH` is always the FIRST of the month, so mapping
   both StartDate and EndDate straight to it is wrong. The engine emits
   `>= @StartDate` and `<= @EndDate`, so a mid-month range silently drops the
   opening month -- measured on The Oak & Vine, 15 Jun -> 15 Jul:

     naive  (both = PERIOD_MONTH)      6 rows, GBP 15,078.11, cost NULL   <- June GONE
     proposed (overlap, below)        12 rows, GBP 32,216.82, cost 27.3%

   Both agree on a whole-month range (June: 6 rows / GBP 17,138.71 / 27.3%), so
   the naive version would pass a casual test and fail in the user's hands. This
   is the same normalisation bug already fixed once in `99_verify` check 3.

   A month occupies [PERIOD_MONTH, EOMONTH(PERIOD_MONTH)]. It should appear if it
   OVERLAPS the picked range, i.e. `EOMONTH(PERIOD_MONTH) >= @StartDate AND
   PERIOD_MONTH <= @EndDate`. Feeding the engine's two slots gives exactly that:

       "StartDate": "EOMONTH(F.[PERIOD_MONTH])"     -> EOMONTH(...) >= @StartDate
       "EndDate"  : "F.[PERIOD_MONTH]"              -> PERIOD_MONTH <= @EndDate

   The mapped values are EXPRESSIONS, not bare column names -- the engine
   concatenates them verbatim, so this needs no engine change.

   THE SUPPLIER CARD IS DIFFERENT (and carries a live datetime2 trap)
   `MargeBrutPurchasesBySupplier` reads `F_PURCHASES_DAY`, whose `ORDER_DATE` is
   **datetime2**, i.e. it carries a time. Mapping `EndDate` to the raw column
   would emit `ORDER_DATE <= '2026-06-30'`, which is midnight and therefore
   **drops the whole last day**. Measured for June on The Oak & Vine:

       month mapping (below)        221 lines, GBP 2,657.07   (to 30 Jun)
       raw ORDER_DATE               205 lines, GBP 2,527.62   (to 25 Jun)
                                    -> 16 lines / GBP 129.45 silently lost

   So both slots are mapped to month-derived DATE expressions, which are
   time-free by construction:

       "StartDate": "EOMONTH(p.[ORDER_DATE])"
       "EndDate"  : "DATEFROMPARTS(YEAR(p.[ORDER_DATE]),MONTH(p.[ORDER_DATE]),1)"

   This also keeps the supplier card month-aligned with the other seven, so a
   mid-month pick can't make it disagree with the Purchases KPI. On a monthly
   cost-of-sales dashboard, agreeing across cards beats day precision on one.

   LocationList is deliberately `""` (the engine `NULLIF`s it, so it stays
   inert): `F_MARGEBRUT_MONTH` is GROUP_NAME x PERIOD_MONTH with no location
   dimension, so a location filter genuinely does not apply. Stated explicitly
   so the omission reads as a decision rather than an oversight.

   ALIASES: every `@FilterClause` injection site must have the mapped alias in
   scope. Verified per dataset -- all 8 month-grain queries alias the fact as `F`
   at each site (including the header subqueries), and the supplier query aliases
   `F_PURCHASES_DAY` as `p` at both. See `feedback_filterclause_aliases`.

   Section 3 also removes the literal token `@FilterClause` from two SQL COMMENTS
   (one in `14`'s supplier header, one in `16`'s). The card SPs inject via
   `REPLACE(@SQL,'@FilterClause',@FilterClause)`, which substitutes inside
   comments too. It has been harmless only because `@FilterClause` was always ''
   on this dashboard -- this script makes it non-empty for the first time.
   `BuildDynamicWhereClause` emits a single line so it stays inside the `--`,
   but relying on that is a landmine; the tokens are cheaper to remove.

   Idempotent: wholesale UPDATE of `ParameterMappings`, and targeted REPLACEs
   that no-op once applied. Safe to re-run.
   ============================================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @me NVARCHAR(128) = SUSER_SNAME();

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- 1. The 8 month-grain datasets (everything except the supplier chart).
--    Month-overlap semantics, per the derivation above.
-- ---------------------------------------------------------------------------
UPDATE [core].[core].[VisualisationQueries]
SET ParameterMappings = N'{"LocationList": "", "StartDate": "EOMONTH(F.[PERIOD_MONTH])", "EndDate": "F.[PERIOD_MONTH]"}',
    ModifiedDate = GETDATE(),
    ModifiedBy   = @me
WHERE Status = N'LIVE'
  AND DataSetName IN (N'MargeBrutGrid', N'MargeBrutCostRatioKPI', N'MargeBrutConsumptionKPI',
                      N'MargeBrutTurnoverKPI', N'MargeBrutPurchasesKPI',
                      N'MargeBrutCostRatioByGroup', N'MargeBrutConsumptionMix',
                      N'MargeBrutCompsSplit');

IF @@ROWCOUNT <> 8
    RAISERROR(N'(1) FAILED: expected exactly 8 month-grain MargeBrut datasets.', 16, 1);

-- ---------------------------------------------------------------------------
-- 2. The supplier chart -- day-grain datetime2 source, mapped to its month.
-- ---------------------------------------------------------------------------
UPDATE [core].[core].[VisualisationQueries]
SET ParameterMappings = N'{"LocationList": "", "StartDate": "EOMONTH(p.[ORDER_DATE])", "EndDate": "DATEFROMPARTS(YEAR(p.[ORDER_DATE]),MONTH(p.[ORDER_DATE]),1)"}',
    ModifiedDate = GETDATE(),
    ModifiedBy   = @me
WHERE Status = N'LIVE'
  AND DataSetName = N'MargeBrutPurchasesBySupplier';

IF @@ROWCOUNT <> 1
    RAISERROR(N'(2) FAILED: expected exactly 1 MargeBrutPurchasesBySupplier row.', 16, 1);

-- ---------------------------------------------------------------------------
-- 3. Remove the literal '@FilterClause' from two comments so the SP's REPLACE
--    cannot inject into them. Targeted and idempotent (no-ops once applied).
-- ---------------------------------------------------------------------------
UPDATE [core].[core].[VisualisationQueries]
SET QueryTemplate = REPLACE(QueryTemplate,
        N'Alias F matches the @FilterClause column.',
        N'Alias F matches the injected filter''s column.')
WHERE Status = N'LIVE' AND DataSetName = N'MargeBrutCostRatioByGroup';

UPDATE [core].[core].[VisualisationQueries]
SET QueryTemplate = REPLACE(QueryTemplate,
        N'reuses alias ''p''/''inv'' so @FilterClause resolves in this subquery too',
        N'reuses alias ''p''/''inv'' so the injected filter resolves in this subquery too')
WHERE Status = N'LIVE' AND DataSetName = N'MargeBrutPurchasesBySupplier';

COMMIT TRANSACTION;

-- ---------------------------------------------------------------------------
-- 4. Verify. StartDate/EndDate must both resolve to a non-empty expression on
--    all 9, and no query may still hold @FilterClause in a comment (detected as
--    an injection-site count exceeding the count of aliased FROM clauses).
-- ---------------------------------------------------------------------------
SELECT
    DataSetName,
    JSON_VALUE(ParameterMappings, '$.StartDate') AS StartDateExpr,
    JSON_VALUE(ParameterMappings, '$.EndDate')   AS EndDateExpr,
    CASE WHEN NULLIF(JSON_VALUE(ParameterMappings, '$.StartDate'), '') IS NOT NULL
          AND NULLIF(JSON_VALUE(ParameterMappings, '$.EndDate'),   '') IS NOT NULL
         THEN N'PASS' ELSE N'FAIL - date filter still inert' END AS Verdict
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE'
ORDER BY DataSetName;

SELECT
    N'@FilterClause tokens outside a FROM-aliased site' AS Check_Name,
    SUM(CASE WHEN DataSetName = N'MargeBrutPurchasesBySupplier'
             THEN Sites - PAliases ELSE Sites - FAliases END) AS StrayTokens,
    CASE WHEN SUM(CASE WHEN DataSetName = N'MargeBrutPurchasesBySupplier'
                       THEN Sites - PAliases ELSE Sites - FAliases END) = 0
         THEN N'PASS' ELSE N'FAIL - a comment still holds the token' END AS Verdict
FROM (
    SELECT DataSetName,
        (LEN(q) - LEN(REPLACE(q, N'@FilterClause', N'')))              / LEN(N'@FilterClause')       AS Sites,
        (LEN(q) - LEN(REPLACE(q, N'F_MARGEBRUT_MONTH F', N'')))        / LEN(N'F_MARGEBRUT_MONTH F') AS FAliases,
        (LEN(q) - LEN(REPLACE(q, N'F_PURCHASES_DAY p', N'')))          / LEN(N'F_PURCHASES_DAY p')   AS PAliases
    FROM (
        SELECT DataSetName, COALESCE(ExecutionQuery, QueryTemplate) AS q
        FROM [core].[core].[VisualisationQueries]
        WHERE DataSetName LIKE N'MargeBrut%' AND Status = N'LIVE'
    ) s
) t;
