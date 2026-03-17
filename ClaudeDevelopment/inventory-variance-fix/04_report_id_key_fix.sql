-- =============================================================================
-- Script 04: 04_report_id_key_fix.sql
-- Issue Fixed: S5 — CONCAT_WS uses CAST(REPORTING_DATE AS DATETIME2) as the
--   separator instead of an actual separator, producing malformed REPORT_ID keys
-- Target Table: [core].[int_marketman001].[StagingControl]
-- Target step_name: 'Report'
-- Date: 2026-03-12
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES ('Report')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = REPLACE(query_sql,
            N'CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID]) AS REPORT_ID',
            N'CONCAT_WS(''-'', REP.[storeId], REP.[ItemID], CAST(REP.REPORTING_DATE AS NVARCHAR(30))) AS REPORT_ID'),
        updated_at = GETDATE();
