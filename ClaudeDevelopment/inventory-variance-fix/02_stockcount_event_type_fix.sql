-- =============================================================================
-- Script 02: 02_stockcount_event_type_fix.sql
-- Issue Fixed: S3 — EVENT_TYPE is 'STOCKCOUNT' instead of 'COUNT'
-- Target Table: [core].[int_marketman001].[StagingControl]
-- Target step_name: 'Stock Count'
-- Date: 2026-03-12
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES ('Stock Count')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = REPLACE(query_sql, N'''STOCKCOUNT'' as EVENT_TYPE', N'''COUNT'' as EVENT_TYPE'),
        updated_at = GETDATE();
