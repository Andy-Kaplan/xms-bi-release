/*
    FIX: C9 - Cross-Store Buyer Bleed in Report Staging
    ====================================================

    PROBLEM:
    The MarketMan actual_vs_theo API, when queried with a storeId, returns data
    for ALL buyers visible to that store, not just its own. For KUDU:
    - Store ed84ceb7... (KUDU-HQ) returns data for both "Kudu-Staff" AND "KUDU Collective"
    - Store 9dbec6a3... (KUDU Collective) returns only its own data

    The "Report" staging step reads ALL rows from DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS
    without filtering, so KUDU Collective's data appears twice in MMAN_REPORT:
    - Once under storeId 9dbec6a3... (correct)
    - Once under storeId ed84ceb7... (duplicate, wrong location)

    This flows through to HUB_INVREPORT (165K records, ~50% duplicates),
    F_INV_USAGE_DAY, and F_INV_SALES_DAY, inflating all inventory reporting.

    FIX:
    Add WHERE clause: storeId = BueyrGuid OR BueyrGuid IS NULL
    This ensures each store's report only contains its own buyer data.

    IMPACT:
    - MMAN_REPORT rows will drop from ~9,333 to ~6,222 (removes ~3,111 cross-store dupes)
    - MMAN_REPORT_STEP2 (reads from MMAN_REPORT) automatically fixed
    - DV load INVREPORT (reads from MMAN_REPORT_STEP2) automatically fixed
    - All downstream: LNK_INVREPORT_LOCATION, LNK_INVITEM_INVREPORT, F_INV_USAGE_DAY,
      F_INV_SALES_DAY automatically fixed

    NOTE: After deployment, existing duplicate INVREPORT records in the data vault
    will remain (DV is append-only). They will age out naturally as new data loads
    with correct figures, or can be cleaned up with a one-off delete of records
    linked to the wrong LOCATION_HUB_ID.

    TARGETS: StagingControl (Report step)
*/

MERGE INTO [int_marketman001].[StagingControl] AS tgt
USING (VALUES (
    N'Report',
    N'MMAN_REPORT',
    N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID]) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID]
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
) AS source_query;'
)) AS src (step_name, staging_table, query_sql)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = src.query_sql,
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, staging_columns, query_sql, tier)
    VALUES (src.step_name, src.staging_table, '*', src.query_sql, 1);
