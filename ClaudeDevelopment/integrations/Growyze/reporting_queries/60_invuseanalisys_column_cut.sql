/*==============================================================================
  60_invuseanalisys_column_cut.sql
  O5 Plan 4 -- InvUseAnalisys: 19 columns -> 9, and four real mislabellings

  Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md 5c

  The design doc called this "the worst readability failure on any of the three
  boards" -- 19 columns crushed into md=6, every header truncated to about two
  characters. The layout change (07) promotes it to md=12; this script cuts the
  column count.

  *** WHAT THE REWRITE FOUND -- THIS IS NOT ONLY A FORMATTING FIX ***

  Reading the query to plan the cut surfaced four defects. The grid is actively
  MISLABELLING data today. None of these are in the design doc, which only
  counted columns (and counted 14; there are 19).

  D1. OPEN DATE / CLOSE DATE ARE SWAPPED.
      Column8 = COUNT_DATE, labelled 'OPEN DATE'. COUNT_DATE is the date the
      stocktake happened, i.e. the CLOSE of the period.
      Column9 = DATEADD(DAY, DAYS_SINCE_LAST_COUNT * -1, COUNT_DATE), labelled
      'CLOSE DATE'. That is the PREVIOUS count date, i.e. the OPEN.
      The two headers are the wrong way round.

  D2. OPEN COUNT / CLOSE COUNT ARE SWAPPED.
      Column10 = ACTUAL_COUNT, labelled 'OPEN COUNT'. ACTUAL_COUNT is the count
      taken AT COUNT_DATE -- the CLOSING balance.
      Column15 = PREVIOUS_COUNT, labelled 'CLOSE COUNT'. That is the OPENING
      balance. Also the wrong way round.

  D3. 'VARIANCE QTY' IS NOT A VARIANCE.
      Column18 = ACTUAL_USED -- a verbatim duplicate of Column16, which is
      already labelled 'ACTUAL USAGE'. The same number appears twice under two
      different names, one of which claims to be a variance.

  D4. 'VARIANCE VAL' IS NOT A VARIANCE VALUE.
      Column19 = ACTUAL_USED * UOM_COST -- actual usage valued at cost, not
      variance valued at cost.

  D5. THE HAND-ROLLED USAGE FORMULA CONTRADICTS THE FACT TABLE'S OWN COLUMNS.
      F_INV_COUNTS_DAY already carries ACTUAL_USAGE, THEO_USAGE and VARIANCE as
      named columns, built by the presentation layer. The query ignored all three
      and re-derived usage as
          PREVIOUS_COUNT + ORDER_QTY + PRODUCTION_QTY + TRANSFER_QTY
                         + WASTE_QTY - ACTUAL_COUNT
      Measured on Dirty Sixth (1,334 rows, 2026-08-03):
          ACTUAL_USAGE disagrees with that formula in 1,171 rows -- 88%
          THEO_USAGE  <> SALE_QTY * -1                 in   707 rows -- 53%
          SUM(VARIANCE) = 111,583  vs
          SUM(ACTUAL_USAGE - THEO_USAGE) = -39,702,597
      So the old 'ACTUAL USAGE' and 'THEO USAGE' columns were ALSO wrong, not
      merely the two variance columns.

  *** WHY THIS SCRIPT INVENTS NO FORMULA ***

  The obvious fix -- compute variance as ACTUAL_USED - (SALE_QTY * -1) -- was
  written and then REJECTED. It would have produced a THIRD answer, contradicting
  InvKPIGrouped, which sits on the SAME dashboard and reads the native VARIANCE
  column. Shipping two cards that disagree about variance is the very defect
  class this pass exists to remove.

  So every column below is a NAMED FACT COLUMN, read as-is. No arithmetic, no
  re-derivation. That makes the grid consistent with InvKPIGrouped and with
  InvMMHeader2, and it makes the numbers auditable against the fact table.

  !! THE UNDERLYING NUMBERS ARE NOT ASSERTED CORRECT BY THIS SCRIPT.
  The 88% disagreement is consistent with **O33** (F_INV_COUNTS_DAY movement
  fan-out, open at Pri 1). Note that GrowyzeCategoryStockTrend explicitly
  collapses that fan-out -- "Collapse the O33 fan-out to true count grain before
  valuing anything", via MAX() per (location, invitem, date) -- and
  InvUseAnalisys does NOT. Its RN = 1 picks one row per (location, invitem)
  ORDER BY COUNT_DATE DESC, which selects arbitrarily among fanned-out ties.
  Collapsing it here would change every number on the card, which is a data fix
  needing its own verification, not a formatting change. RAISED FOR THE BUG
  PHASE; deliberately out of scope here.

  THE NEW SHAPE -- 9 columns, all native

      1 Location          LOCATION_NAME                TEXT
      2 Inventory item    INVITEM                      TEXT
      3 Opening           PREVIOUS_COUNT               DECIMAL
      4 Received          ORDER_QTY                    DECIMAL
      5 Waste             WASTE_QTY                    DECIMAL
      6 Closing           ACTUAL_COUNT                 DECIMAL
      7 Actual usage      ACTUAL_USAGE                 DECIMAL
      8 Variance          VARIANCE                     DECIMAL
      9 Variance value    VARIANCE * UOM_COST          CURRENCY

  Column 9 is the ONE product of two columns, and it is the standard valuation
  used throughout this work (see the UOM_COST pack-size fix). It replaces the
  bogus 'VARIANCE VAL' with a figure that is at least a variance.

  UOM_COST is deliberately NOT wrapped in ISNULL. An item with no cost shows a
  BLANK variance value, not GBP 0.00 -- a missing cost is not a free item.

  WHAT WAS DROPPED, AND WHY IT IS SAFE
    TOP_LEVEL_NAME / MIDDLE_1_LEVEL_NAME / BOTTOM_LEVEL_NAME (labelled 'Type',
      'Group', 'Category') are D_INVITEM HIERARCHY LEVEL NAMES -- metadata like
      the literal string 'Category', constant on every row. They were never data.
    COUNT_FREQUENCY / COUNT_RECENCY -- operational metadata, not usage.
    OPEN DATE / CLOSE DATE -- the grid shows the LATEST count per item, so the
      dates are near-constant per location; dropped rather than un-swapped.
    PRODUCTION_QTY / TRANSFER_QTY -- MEASURED ZERO on all five Growyze orgs
      across all 29,684 rows (2026-08-03), so they would be two always-blank
      columns.
      !! THIS IS A DATA-DEPENDENT DECISION. If Growyze ever lands production or
      transfer events they must come back, or the movement columns will no longer
      account for the change between Opening and Closing. 88_verify_plan4.sql
      asserts they are still zero and FAILS if not.
    SALE_QTY / THEO_USAGE -- dropped rather than shown. THEO_USAGE is the honest
      native column but it disagrees with the old card's SALE_QTY * -1 in 53% of
      rows (D5), so showing either invites a question this pass cannot answer.
      VARIANCE already encodes the comparison. Revisit with O33.

  CALENDAR JOIN NOW CASTS. COUNT_DATE is datetime2, and an un-CAST equality join
  against CALENDAR.[DATE] silently drops any row carrying a time (portability
  rule 3). MEASURED: zero non-midnight rows on all five Growyze orgs, so this is
  a PROVABLE NO-OP today, taken as latent-defect insurance. A CAST can only ever
  widen the match, never narrow it, so it cannot regress the 6th org either.

  SOURCE SCOPE DELIBERATELY **NOT** ADDED. This dataset serves 6 orgs across 2
  grids -- the five Growyze orgs on Inventory Control plus org
  C14CF568-588D-F011-B3CD-000D3AD9E9D4 on grid C0000280-A8A5-4736-9072-845C95CA0E67.
  Hardcoding invitem.[BOTTOM_SRC] = 'int_growyze001' would empty the card on that
  sixth org. The dataset therefore remains source-blind and blends MarketMan +
  Growyze inventory on Oak & Vine -- the same class as InvWasteCost and
  InvStockActivity. Recorded as a follow-up, NOT fixed here.

  BLAST RADIUS: 6 cards / 6 orgs. Live column is ExecutionQuery (in sync with
  QueryTemplate at 3,852 chars); both are written.

  IDEMPOTENT: full-text assignment guarded on inequality.
  Run against: core (UAT/DEV/TEST).
==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF NOT EXISTS (SELECT 1 FROM core.core.VisualisationQueries
                WHERE DataSetName = N'InvUseAnalisys' AND VisualizationType = N'CustomDataGrid'
                  AND Status = N'LIVE' AND ExecutionQuery IS NOT NULL)
    THROW 51600, 'InvUseAnalisys ExecutionQuery is NULL -- this script assumes it is the live column (verified 2026-08-03). Re-check before writing.', 1;

DECLARE @Q NVARCHAR(MAX) = N'
WITH Counts AS (
    SELECT SUB.*
    FROM (
        SELECT
            FC.*,
            ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID
                              ORDER BY FC.[COUNT_DATE] DESC) AS RN,
            COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
            COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVITEM
        FROM [presentation].[F_INV_COUNTS_DAY] FC
        INNER JOIN [presentation].[CALENDAR] C ON CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]
        LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
        LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
        WHERE 1=1
        AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
        @FilterClause
    ) SUB
    WHERE RN = 1
)
SELECT
    LOCATION_NAME                     AS Column1,
    INVITEM                           AS Column2,
    ROUND(PREVIOUS_COUNT, 2)          AS Column3,
    ROUND(ORDER_QTY, 2)               AS Column4,
    ROUND(WASTE_QTY, 2)               AS Column5,
    ROUND(ACTUAL_COUNT, 2)            AS Column6,
    ROUND(ACTUAL_USAGE, 2)            AS Column7,
    ROUND(VARIANCE, 2)                AS Column8,
    ROUND(VARIANCE * UOM_COST, 2)     AS Column9,
    NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13,
    NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17,
    NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21,
    NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25,
    NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM Counts;

SELECT
    N''Inventory Usage & Variance'' AS [Title],
    N''Latest stocktake per item and location. Every figure is read straight from the stocktake fact -- none is recalculated here. A blank variance value means the item carries no cost.'' AS [Description],
    N''Location''       AS [Label1], N''TEXT''     AS [Type1],
    N''Inventory item'' AS [Label2], N''TEXT''     AS [Type2],
    N''Opening''        AS [Label3], N''DECIMAL''  AS [Type3],
    N''Received''       AS [Label4], N''DECIMAL''  AS [Type4],
    N''Waste''          AS [Label5], N''DECIMAL''  AS [Type5],
    N''Closing''        AS [Label6], N''DECIMAL''  AS [Type6],
    N''Actual usage''   AS [Label7], N''DECIMAL''  AS [Type7],
    N''Variance''       AS [Label8], N''DECIMAL''  AS [Type8],
    N''Variance value'' AS [Label9], N''CURRENCY'' AS [Type9],
    NULL AS [Label10], NULL AS [Type10], NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12], NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14], NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20], NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26], NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29];';

UPDATE core.core.VisualisationQueries
SET ExecutionQuery = @Q,
    QueryTemplate  = @Q,
    ModifiedDate   = SYSUTCDATETIME(),
    ModifiedBy     = N'O5-Plan4-60'
WHERE DataSetName = N'InvUseAnalisys'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE'
  AND (ExecutionQuery <> @Q OR QueryTemplate <> @Q);
PRINT '  InvUseAnalisys rewritten (19 -> 9 columns), rows = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (0 on a re-run)';


/*==============================================================================
  Assertions. Each states what makes it FAIL.

  Chk_NoHandRolledUsage is the substantive one: it FAILS if the hand-rolled
  usage formula is still present anywhere in the query. That formula was defect
  D5 -- it disagrees with the fact's own ACTUAL_USAGE in 88% of rows -- and its
  absence is the whole point of this rewrite. Checking merely that the word
  'VARIANCE' appears would pass even with the bad formula still in place.

  Chk_NoDerivedVariance FAILS if variance is computed rather than read. It exists
  to stop a future edit from "helpfully" re-deriving it and reintroducing the
  contradiction with InvKPIGrouped.

  The production/transfer zero assumption behind the dropped columns is asserted
  in 88_verify_plan4.sql, which has the org list -- it cannot be expressed here
  without hardcoding database names (forbidden in this folder).
==============================================================================*/
SELECT
    DataSetName,
    CASE WHEN CHARINDEX(N'ROUND(VARIANCE, 2)', ExecutionQuery) > 0
         THEN 'PASS' ELSE 'FAIL - variance is not read from the native column' END AS Chk_VarianceIsNative,
    CASE WHEN CHARINDEX(N'PRODUCTION_QTY + TRANSFER_QTY', ExecutionQuery) = 0
         THEN 'PASS' ELSE 'FAIL - hand-rolled usage formula still present (D5)' END AS Chk_NoHandRolledUsage,
    CASE WHEN CHARINDEX(N'ACTUAL_USAGE - ', ExecutionQuery) = 0
              AND CHARINDEX(N'SALE_QTY * -1', ExecutionQuery) = 0
         THEN 'PASS' ELSE 'FAIL - variance is being derived, not read; would contradict InvKPIGrouped' END AS Chk_NoDerivedVariance,
    CASE WHEN CHARINDEX(N'CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]', ExecutionQuery) > 0
         THEN 'PASS' ELSE 'FAIL - CALENDAR join is not CAST' END AS Chk_DateCast,
    CASE WHEN CHARINDEX(N'OPEN DATE', ExecutionQuery) = 0
              AND CHARINDEX(N'CLOSE COUNT', ExecutionQuery) = 0
         THEN 'PASS' ELSE 'FAIL - swapped OPEN/CLOSE headers still present (D1/D2)' END AS Chk_SwappedHeadersGone,
    CASE WHEN CHARINDEX(N'[Label10]', ExecutionQuery) > 0
              AND CHARINDEX(N'NULL AS [Label10]', ExecutionQuery) > 0
         THEN 'PASS' ELSE 'FAIL - column count not actually reduced' END AS Chk_ColumnsCut,
    CASE WHEN ExecutionQuery = QueryTemplate
         THEN 'PASS' ELSE 'FAIL - ExecutionQuery and QueryTemplate diverged' END AS Chk_ColumnsInSync
FROM core.core.VisualisationQueries
WHERE DataSetName = N'InvUseAnalisys'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE';
