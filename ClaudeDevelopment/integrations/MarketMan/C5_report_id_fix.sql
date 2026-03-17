-- =============================================================================
-- C5_report_id_fix.sql
-- Fix: MMAN_REPORT CONCAT_WS separator bug
-- =============================================================================
--
-- PROBLEM:
--   The MMAN_REPORT staging step constructs REPORT_ID as:
--     CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID])
--
--   CONCAT_WS uses the FIRST argument as the separator. The DATETIME2-cast date
--   is consumed as the separator between storeId and ItemID -- the date itself
--   never appears as a standalone value in REPORT_ID.
--
--   Additionally, 7 rows have NULL ItemID. CONCAT_WS skips NULLs, producing
--   6 duplicate REPORT_IDs (storeId alone with date as separator).
--
-- FIX:
--   Change CONCAT_WS to use '-' as the separator, include the date as a value,
--   and wrap ItemID in ISNULL(..., 'NO_ITEM') to prevent NULL collisions:
--     CONCAT_WS('-', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.[storeId], ISNULL(REP.[ItemID], 'NO_ITEM'))
--
-- TARGET: core.int_marketman001.StagingControl, step_name = 'Report'
-- PATTERN: MERGE upsert on step_name
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'Report')) AS src (step_name)
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        [staging_table] = N'MMAN_REPORT',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(''-'', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.[storeId], ISNULL(REP.[ItemID], ''NO_ITEM'')) AS REPORT_ID
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
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Report', N'MMAN_REPORT', N'IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(''-'', CAST(REP.REPORTING_DATE AS NVARCHAR(50)), REP.[storeId], ISNULL(REP.[ItemID], ''NO_ITEM'')) AS REPORT_ID
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
) AS source_query;',
           1, N'Staging', 0, NULL, NULL, 3, 30,
           N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]',
           GETDATE(), GETDATE());
GO
