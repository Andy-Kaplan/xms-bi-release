/* =============================================================================
   06_vis_grids.sql
   -----------------------------------------------------------------------------
   Task 8 of the Pantry COGS dashboard build (.superpowers/sdd/2026-07-30-
   growyze-pantry-cogs-dashboard/). Registers the 3 grid-type visualisation
   datasets against [core].[core].[VisualisationQueries]. Read 00_CARD_CONTRACTS.md
   before touching this file - the shapes below are copied from its live
   CustomDataGrid (InvCountData) and CustomGroupedDataGrid (InvKPIGrouped)
   examples, NOT from generic assumption.

   Datasets (3):
     PantryCOGSBillingTotals  CustomDataGrid          COG Spend by Category -
                                                       Subcategory + GRAND TOTAL
                                                       row (replaces invoice
                                                       workbook SUMIF sheet)
     PantryCOGSItemTable      CustomGroupedDataGrid   Full item table grouped
                                                       by REPORT_GROUP (replaces
                                                       "Full Consumption Report"
                                                       tab)
     PantryCOGSExceptions     CustomDataGrid          Automated SOP exception
                                                       checks, one row per
                                                       exception

   Natural key for MERGE: (DataSetName, VisualizationType, Status='LIVE'),
   Version = 1 throughout. Idempotent - safe to re-run.

   Card render shapes actually used here (per 00_CARD_CONTRACTS.md, NOT the
   descriptive column names in the task brief's illustrative SQL - those show
   the measure logic to wrap, not the wire shape):
     CustomDataGrid        : RS1 = Column1..Column29 (fixed) ; RS2 = Title,
                              Description, Label1/Type1 .. Label29/Type29
     CustomGroupedDataGrid : RS1 = ParentId, Id, GroupedColumn, Column1..Column29
                              (fixed). NO RS2 - header is static JSON in
                              OutputDefinitions.additional_datasets[0].

   ParameterMappings is populated (LocationList/StartDate/EndDate) on all three
   records, byte-identical to Tasks 6-7, for pack-wide consistency - even though
   Pantry COGS has no date-range control (design doc s7.1: discrete pickers
   instead), an unmapped date slot has already shipped as a silent no-op bug
   elsewhere on this platform, so every card maps it defensively:
     LocationList -> CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)
     StartDate    -> F.[PERIOD_END_DATE]
     EndDate      -> F.[PERIOD_END_DATE]
   The actual filtering for this dashboard is done entirely via the
   FilterDefinitions 3-key block below (Venues/Periods/Categories), which is
   what @FilterClause is built from.

   FilterDefinitions (identical 3-key block on every record in this file):
     PantryCOGSVenues     -> CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)
     PantryCOGSPeriods    -> F.[PERIOD_LABEL]
     PantryCOGSCategories -> ISNULL(F.[REPORT_GROUP], N'(no category)')
                             (the ISNULL wrapper matches 07's filter list, which lists
                             uncategorised rows as '(no category)' instead of dropping them
                             - final-review M15; change one side and you must change all four)
   LOCATION_HUB_ID is binary(32); the venue FilterList (Task 9) emits its Value
   as CONVERT(VARCHAR(64), ..., 2) (a hex string, no '0x' prefix) - the filter
   column expression here must match that exactly, or the implicit binary/
   varchar comparison silently matches nothing (character bytes vs. hex digits,
   no error, zero rows).
   These names must exactly match the DataSetName values Task 9 registers as
   FilterList datasets, and the DashboardGridFilter.DataSet values Task 10 wires.

   NOTE: Claude authored this script from files only, no database access.
   Nothing in this file has been executed. A developer must run it.
   ============================================================================= */

SET NOCOUNT ON;
DECLARE @q  NVARCHAR(MAX);
DECLARE @pm NVARCHAR(MAX);
DECLARE @fd NVARCHAR(MAX);
DECLARE @od NVARCHAR(MAX);

/* Shared across all three records in this file */
SET @pm = N'{
  "LocationList": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)",
  "StartDate": "F.[PERIOD_END_DATE]",
  "EndDate": "F.[PERIOD_END_DATE]"
}';
SET @fd = N'{
  "PantryCOGSVenues": {"column": "CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSPeriods": {"column": "F.[PERIOD_LABEL]", "type": "IN", "dataType": "VARCHAR"},
  "PantryCOGSCategories": {"column": "ISNULL(F.[REPORT_GROUP], N''(no category)'')", "type": "IN", "dataType": "VARCHAR"}
}';

/* ===========================================================================
   1. PantryCOGSBillingTotals -- CustomDataGrid
   Replaces the invoice workbook's SUMIF sheet. Grain: CATEGORY - SUBCATEGORY.
   Measure: SUM(COG_SPEND). Excludes IS_FIRST_PERIOD (no opening = meaningless
   consumption/spend for that venue's first stocktake).
   GRAND TOTAL is appended as an extra row (MargeBrutGrid convention, not a T-SQL
   ROLLUP) and must equal PantryCOGSSpendKPI (Task 6) exactly - same measure,
   same exclusion, same filter scope.
   =========================================================================== */
SET @od = N'{"column_mappings": {}, "additional_datasets": []}';

SET @q = N'
WITH Scoped AS (
    SELECT
         F.[CATEGORY]
        ,F.[SUBCATEGORY]
        ,F.[COG_SPEND]
    FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
      @FilterClause
)
SELECT
     Column1, Column2,
     NULL AS Column3,  NULL AS Column4,  NULL AS Column5,  NULL AS Column6,  NULL AS Column7,
     NULL AS Column8,  NULL AS Column9,  NULL AS Column10, NULL AS Column11, NULL AS Column12,
     NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17,
     NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
     NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27,
     NULL AS Column28, NULL AS Column29
FROM (
    SELECT
         ISNULL([CATEGORY], N''Unspecified'') + N'' - '' + ISNULL([SUBCATEGORY], N''Unspecified'') AS Column1
        ,SUM([COG_SPEND])                                                                          AS Column2
        ,0                                                                                          AS SortOrder
    FROM Scoped
    GROUP BY [CATEGORY], [SUBCATEGORY]

    UNION ALL

    SELECT
         N''GRAND TOTAL'' AS Column1
        ,SUM([COG_SPEND]) AS Column2
        ,1                AS SortOrder
    FROM Scoped
) AS Grid
ORDER BY SortOrder, Column1;

SELECT
     N''Billing Totals'' AS Title
    ,N''COG Spend by Category - Subcategory, matching the invoice workbook SUMIF sheet'' AS Description
    ,N''Category - Subcategory'' AS Label1, N''TEXT''    AS Type1
    ,N''Spend''                  AS Label2, N''DECIMAL'' AS Type2
    ,NULL AS Label3,  NULL AS Type3,  NULL AS Label4,  NULL AS Type4,  NULL AS Label5,  NULL AS Type5
    ,NULL AS Label6,  NULL AS Type6,  NULL AS Label7,  NULL AS Type7,  NULL AS Label8,  NULL AS Type8
    ,NULL AS Label9,  NULL AS Type9,  NULL AS Label10, NULL AS Type10, NULL AS Label11, NULL AS Type11
    ,NULL AS Label12, NULL AS Type12, NULL AS Label13, NULL AS Type13, NULL AS Label14, NULL AS Type14
    ,NULL AS Label15, NULL AS Type15, NULL AS Label16, NULL AS Type16, NULL AS Label17, NULL AS Type17
    ,NULL AS Label18, NULL AS Type18, NULL AS Label19, NULL AS Type19, NULL AS Label20, NULL AS Type20
    ,NULL AS Label21, NULL AS Type21, NULL AS Label22, NULL AS Type22, NULL AS Label23, NULL AS Type23
    ,NULL AS Label24, NULL AS Type24, NULL AS Label25, NULL AS Type25, NULL AS Label26, NULL AS Type26
    ,NULL AS Label27, NULL AS Type27, NULL AS Label28, NULL AS Type28, NULL AS Label29, NULL AS Type29';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSBillingTotals', N'CustomDataGrid', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'COG Spend by Category - Subcategory with a GRAND TOTAL row; replaces the invoice workbook SUMIF sheet. Grand total must equal PantryCOGSSpendKPI.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSBillingTotals', N'CustomDataGrid', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'COG Spend by Category - Subcategory with a GRAND TOTAL row; replaces the invoice workbook SUMIF sheet. Grand total must equal PantryCOGSSpendKPI.',
     NULL, NULL, GETDATE(), GETDATE());
PRINT 'PantryCOGSBillingTotals merged';

/* ===========================================================================
   2. PantryCOGSItemTable -- CustomGroupedDataGrid
   Replaces the "Full Consumption Report" tab, whose columns F-J were
   mislabelled by one position - headings here state exactly what each column
   holds. PERIOD_DAYS surfaced explicitly (Column12) so a sparse-stocktake
   period is visible, not hidden, at both the item and group level.
   Excludes IS_FIRST_PERIOD. Grouped by REPORT_GROUP.

   Tree shape (2 levels, following the InvKPIGrouped ParentId/Id convention):
     Leaf (item)  : ParentId = REPORT_GROUP, Id = REPORT_GROUP|ITEM_NAME|UOM,
                    GroupedColumn = ITEM_NAME
     Root (group) : ParentId = NULL,        Id = REPORT_GROUP,
                    GroupedColumn = REPORT_GROUP
   Each leaf's ParentId equals its root's Id, and the root's ParentId is NULL -
   the exact linking rule 00_CARD_CONTRACTS.md documents for this card type.

   Column1 (Unit) and Column7 (Unit Cost) are NULL at the root/group level:
   a single unit or unit cost across a heterogeneous group of items is not a
   meaningful figure, so it is left blank there rather than showing a
   misleading MAX(). PERIOD_DAYS (Column12) uses MAX() at both levels so the
   sparse-stocktake signal survives the rollup.

   No RS2 in this record - CustomGroupedDataGrid's header is declared
   statically in OutputDefinitions.additional_datasets[0] (00_CARD_CONTRACTS.md
   confirms InvKPIGrouped has no header SELECT at all).
   =========================================================================== */
SET @od = N'{
  "column_mappings": {
    "ParentId": "ParentId", "Id": "Id", "GroupedColumn": "GroupedColumn",
    "Column1": "Column1", "Column2": "Column2", "Column3": "Column3", "Column4": "Column4",
    "Column5": "Column5", "Column6": "Column6", "Column7": "Column7", "Column8": "Column8",
    "Column9": "Column9", "Column10": "Column10", "Column11": "Column11", "Column12": "Column12",
    "Column13": "", "Column14": "", "Column15": "", "Column16": "", "Column17": "", "Column18": "",
    "Column19": "", "Column20": "", "Column21": "", "Column22": "", "Column23": "", "Column24": "",
    "Column25": "", "Column26": "", "Column27": "", "Column28": "", "Column29": ""
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": ["Title", "Description", "GroupedLabel", "GroupedType",
        "Label1", "Type1", "Label2", "Type2", "Label3", "Type3", "Label4", "Type4",
        "Label5", "Type5", "Label6", "Type6", "Label7", "Type7", "Label8", "Type8",
        "Label9", "Type9", "Label10", "Type10", "Label11", "Type11", "Label12", "Type12",
        "Label13", "Type13", "Label14", "Type14", "Label15", "Type15", "Label16", "Type16",
        "Label17", "Type17", "Label18", "Type18", "Label19", "Type19", "Label20", "Type20",
        "Label21", "Type21", "Label22", "Type22", "Label23", "Type23", "Label24", "Type24",
        "Label25", "Type25", "Label26", "Type26", "Label27", "Type27", "Label28", "Type28",
        "Label29", "Type29"],
      "values": {
        "Title": "Item Table",
        "Description": "Full consumption report, grouped by report group",
        "GroupedLabel": "Report Group / Item",
        "GroupedType": "TEXT",
        "Label1": "Unit", "Type1": "TEXT",
        "Label2": "Opening Qty", "Type2": "DECIMAL",
        "Label3": "Delivery Qty", "Type3": "DECIMAL",
        "Label4": "Transfer Qty", "Type4": "DECIMAL",
        "Label5": "Closing Qty", "Type5": "DECIMAL",
        "Label6": "Consumption Qty", "Type6": "DECIMAL",
        "Label7": "Unit Cost", "Type7": "DECIMAL",
        "Label8": "Closing Stock Value", "Type8": "DECIMAL",
        "Label9": "COG Spend", "Type9": "DECIMAL",
        "Label10": "COG Sold", "Type10": "DECIMAL",
        "Label11": "Unexplained Variance", "Type11": "DECIMAL",
        "Label12": "Period Days", "Type12": "DECIMAL"
      }
    }
  ]
}';

SET @q = N'
WITH Scoped AS (
    SELECT
         F.[REPORT_GROUP]
        ,F.[ITEM_NAME]
        ,F.[STANDARDISED_UOM]
        ,F.[OPENING_QTY]
        ,F.[DELIVERY_QTY]
        ,F.[TRANSFER_QTY]
        ,F.[CLOSING_QTY]
        ,F.[CONSUMPTION_QTY]
        ,F.[UOM_COST]
        ,F.[CLOSING_VALUE]
        ,F.[COG_SPEND]
        ,F.[COG_SOLD]
        ,F.[VARIANCE_VALUE]
        ,F.[PERIOD_DAYS]
    FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
      @FilterClause
)
SELECT
     ParentId, Id, GroupedColumn
    ,Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8, Column9, Column10, Column11, Column12
    ,NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17,
     NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
     NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26, NULL AS Column27,
     NULL AS Column28, NULL AS Column29
FROM (
    -- Leaf level: one row per (REPORT_GROUP, ITEM_NAME, STANDARDISED_UOM)
    SELECT
         [REPORT_GROUP]                                                                    AS ParentId
        ,[REPORT_GROUP] + N''|'' + [ITEM_NAME] + N''|'' + ISNULL([STANDARDISED_UOM], N'''') AS Id
        ,[ITEM_NAME]                                                                        AS GroupedColumn
        ,MAX([STANDARDISED_UOM])   AS Column1
        ,SUM([OPENING_QTY])        AS Column2
        ,SUM([DELIVERY_QTY])       AS Column3
        ,SUM([TRANSFER_QTY])       AS Column4
        ,SUM([CLOSING_QTY])        AS Column5
        ,SUM([CONSUMPTION_QTY])    AS Column6
        ,MAX([UOM_COST])           AS Column7
        ,SUM([CLOSING_VALUE])      AS Column8
        ,SUM([COG_SPEND])          AS Column9
        ,SUM([COG_SOLD])           AS Column10
        ,SUM([VARIANCE_VALUE])     AS Column11
        ,MAX([PERIOD_DAYS])        AS Column12
        ,[REPORT_GROUP]            AS SortGroup
        ,0                         AS SortLevel
    FROM Scoped
    GROUP BY [REPORT_GROUP], [ITEM_NAME], [STANDARDISED_UOM]

    UNION ALL

    -- Root level: one row per REPORT_GROUP, top of the tree (ParentId = NULL)
    SELECT
         NULL                  AS ParentId
        ,[REPORT_GROUP]        AS Id
        ,[REPORT_GROUP]        AS GroupedColumn
        ,NULL                  AS Column1   -- Unit: not meaningful across mixed-UOM items
        ,SUM([OPENING_QTY])    AS Column2
        ,SUM([DELIVERY_QTY])   AS Column3
        ,SUM([TRANSFER_QTY])   AS Column4
        ,SUM([CLOSING_QTY])    AS Column5
        ,SUM([CONSUMPTION_QTY]) AS Column6
        ,NULL                  AS Column7   -- Unit Cost: not meaningful across mixed items
        ,SUM([CLOSING_VALUE])  AS Column8
        ,SUM([COG_SPEND])      AS Column9
        ,SUM([COG_SOLD])       AS Column10
        ,SUM([VARIANCE_VALUE]) AS Column11
        ,MAX([PERIOD_DAYS])    AS Column12
        ,[REPORT_GROUP]        AS SortGroup
        ,1                     AS SortLevel
    FROM Scoped
    GROUP BY [REPORT_GROUP]
) AS Tree
-- SortLevel DESC so each group''s ROOT row arrives BEFORE its leaves (final-review M17).
-- Leaves are SortLevel 0 and roots are SortLevel 1, so plain ascending order emitted every
-- root after its own children. 00_CARD_CONTRACTS.md documents the ParentId/Id linking rule
-- for this card type but says nothing about row order, and a renderer that builds the tree
-- in a single top-down pass would not have a parent to attach those children to. Costs
-- nothing and removes the question.
ORDER BY SortGroup, SortLevel DESC, Column10 DESC';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSItemTable', N'CustomGroupedDataGrid', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Full item-level consumption report grouped by REPORT_GROUP; replaces the "Full Consumption Report" tab whose columns F-J were mislabelled by one position.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSItemTable', N'CustomGroupedDataGrid', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Full item-level consumption report grouped by REPORT_GROUP; replaces the "Full Consumption Report" tab whose columns F-J were mislabelled by one position.',
     NULL, NULL, GETDATE(), GETDATE());
PRINT 'PantryCOGSItemTable merged';

/* ===========================================================================
   3. PantryCOGSExceptions -- CustomDataGrid
   Automates the Raddish SOP manual checks. One row per exception, UNION ALL
   across 6 branches (5 from the brief + the sentinel branch below). This is
   the ONLY card in the pack that does not exclude IS_FIRST_PERIOD - a first
   period is itself an exception to surface, not noise to filter out.

   Growyze staging gives items with a NULL subcategory an 'All INVITEMs'
   sentinel on BOTH category tiers, so they read as non-NULL and would
   otherwise slip past a plain "IS NULL" check. Branch 6 tests for that
   literal sentinel value on either tier and gives it its own Reason text,
   distinct from the true-NULL branch, so whoever fixes it in Growyze knows
   which case they are looking at. This card is the only mechanism that drives
   bad source data back to a fix in Growyze (no in-warehouse adjustment path
   exists by design) - an exception this card fails to surface is one nobody
   ever fixes.

   All 6 branches project identical column counts/types: ItemName (nvarchar),
   GroupName (nvarchar), Period (varchar), Reason (fixed text), Qty
   (decimal 38,6), Value (decimal 38,6), then NULL-padded to Column29.
   =========================================================================== */
SET @od = N'{"column_mappings": {}, "additional_datasets": []}';

SET @q = N'
WITH Scoped AS (
    SELECT F.*
    FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      @FilterClause
)
SELECT
     Column1, Column2, Column3, Column4, Column5, Column6,
     NULL AS Column7,  NULL AS Column8,  NULL AS Column9,  NULL AS Column10, NULL AS Column11,
     NULL AS Column12, NULL AS Column13, NULL AS Column14, NULL AS Column15, NULL AS Column16,
     NULL AS Column17, NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21,
     NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
     NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM (
    SELECT
         [ITEM_NAME]                              AS Column1
        ,[REPORT_GROUP]                            AS Column2
        ,[PERIOD_LABEL]                            AS Column3
        ,N''Negative consumption''                 AS Column4
        ,[CONSUMPTION_QTY]                         AS Column5
        ,[COG_SOLD]                                AS Column6
        ,1 AS SortOrder
    FROM Scoped WHERE [IS_NEGATIVE_COGS] = 1

    UNION ALL

    SELECT
         [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL]
        ,N''Zero or missing cost price''
        ,[CONSUMPTION_QTY], [COG_SOLD]
        ,2
    -- CLOSING_QTY <> 0 is the third branch of the movement gate (final-review I9), matching
    -- what verify check 4 already does. Without it, an item that HOLDS closing stock, had no
    -- movement in the period, and has a NULL or zero UOM_COST satisfies neither of the other
    -- two branches: its CLOSING_VALUE is NULL (qty x NULL), SUM() silently discards it, and it
    -- vanishes from PantryCOGSClosingStockKPI and from this grid''s Closing Stock Value column
    -- with no exception raised anywhere. Closing stock at cost is a headline figure on this
    -- dashboard (design section 1.1 quotes GBP 41,399.18 for the venue being replaced), so that
    -- is a zero that should have been an error - the exact defect class this pack exists to
    -- remove. Verify check 5 carries the same third clause.
    FROM Scoped WHERE [HAS_ZERO_COST] = 1 AND ([DELIVERY_QTY] <> 0 OR [CONSUMPTION_QTY] <> 0 OR [CLOSING_QTY] <> 0)

    UNION ALL

    SELECT
         [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL]
        ,N''Not counted at closing stocktake''
        ,[CONSUMPTION_QTY], [COG_SOLD]
        ,3
    FROM Scoped WHERE [IS_UNCOUNTED] = 1

    UNION ALL

    SELECT
         [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL]
        ,N''First period - no opening stock''
        ,[CONSUMPTION_QTY], [COG_SOLD]
        ,4
    FROM Scoped WHERE [IS_FIRST_PERIOD] = 1

    UNION ALL

    SELECT
         [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL]
        ,N''Missing category or subcategory''
        ,[CONSUMPTION_QTY], [COG_SOLD]
        ,5
    FROM Scoped WHERE [CATEGORY] IS NULL OR [SUBCATEGORY] IS NULL

    UNION ALL

    SELECT
         [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL]
        ,N''Uncategorised in Growyze (All INVITEMs sentinel) - fix category/subcategory upstream''
        ,[CONSUMPTION_QTY], [COG_SOLD]
        ,6
    FROM Scoped WHERE [CATEGORY] = N''All INVITEMs'' OR [SUBCATEGORY] = N''All INVITEMs''
) AS Ex
ORDER BY SortOrder, Column6 DESC;

SELECT
     N''Exceptions'' AS Title
    ,N''Automated SOP checks - negative consumption, zero cost, not counted, first period, missing or sentinel category'' AS Description
    ,N''Item''   AS Label1, N''TEXT''    AS Type1
    ,N''Group''  AS Label2, N''TEXT''    AS Type2
    ,N''Period'' AS Label3, N''TEXT''    AS Type3
    ,N''Reason'' AS Label4, N''TEXT''    AS Type4
    ,N''Qty''    AS Label5, N''DECIMAL'' AS Type5
    ,N''Value''  AS Label6, N''DECIMAL'' AS Type6
    ,NULL AS Label7,  NULL AS Type7,  NULL AS Label8,  NULL AS Type8,  NULL AS Label9,  NULL AS Type9
    ,NULL AS Label10, NULL AS Type10, NULL AS Label11, NULL AS Type11, NULL AS Label12, NULL AS Type12
    ,NULL AS Label13, NULL AS Type13, NULL AS Label14, NULL AS Type14, NULL AS Label15, NULL AS Type15
    ,NULL AS Label16, NULL AS Type16, NULL AS Label17, NULL AS Type17, NULL AS Label18, NULL AS Type18
    ,NULL AS Label19, NULL AS Type19, NULL AS Label20, NULL AS Type20, NULL AS Label21, NULL AS Type21
    ,NULL AS Label22, NULL AS Type22, NULL AS Label23, NULL AS Type23, NULL AS Label24, NULL AS Type24
    ,NULL AS Label25, NULL AS Type25, NULL AS Label26, NULL AS Type26, NULL AS Label27, NULL AS Type27
    ,NULL AS Label28, NULL AS Type28, NULL AS Label29, NULL AS Type29';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSExceptions', N'CustomDataGrid', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Automated SOP exception checks: negative consumption, zero/missing cost, not counted at closing, first period, and missing/sentinel category. Does NOT exclude IS_FIRST_PERIOD - it is itself an exception.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSExceptions', N'CustomDataGrid', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Automated SOP exception checks: negative consumption, zero/missing cost, not counted at closing, first period, and missing/sentinel category. Does NOT exclude IS_FIRST_PERIOD - it is itself an exception.',
     NULL, NULL, GETDATE(), GETDATE());
PRINT 'PantryCOGSExceptions merged';

PRINT '=== Pantry COGS grid visualisation queries registered (3 datasets) ===';
