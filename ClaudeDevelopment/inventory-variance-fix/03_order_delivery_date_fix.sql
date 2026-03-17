-- =============================================================================
-- Script 03: 03_order_delivery_date_fix.sql
-- Issue Fixed: S4 — ORDER events use SentDateUTC instead of DeliveryDateUTC
-- Target Table: [core].[int_marketman001].[StagingControl]
-- Target step_name: 'Order Items'
-- Date: 2026-03-12
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES ('Order Items')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        query_sql = REPLACE(query_sql, N',o.SentDateUTC as EVENT_TS', N',COALESCE(TRY_CAST(o.DeliveryDateUTC AS DATETIME2), o.SentDateUTC) as EVENT_TS'),
        updated_at = GETDATE();
