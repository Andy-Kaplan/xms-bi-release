-- ============================================================================
-- Create presentation.F_PURCHASES_DAY on Padel Social (targeted, additive)
-- Plan: docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md  Task 7
-- Ledger: O5
--
-- State verified on UAT 2026-07-10:
--   core.core.DataVaultEntities INVITEM_STOCKORDER .... has attrs   (05 deployed)
--   core.core.PresentationTables  F_PURCHASES_DAY ......... live    (06 deployed)
--   core.core.PresentationControl "Purchases by Day" ...... tier 1  (07 deployed)
--   Padel datavault.SAT_LNK_INVITEM_STOCKORDER ............ EXISTS
--   Padel presentation.F_PURCHASES_DAY ................... MISSING  <-- this fixes
--   Dirty Sixth presentation.F_PURCHASES_DAY ............. EXISTS
--
-- So NO sp_GenerateDataVaultTables and NO 05/06/07 re-deploy are needed — only
-- the Padel presentation table. We create it additively (IF NOT EXISTS) rather
-- than via DeployPresentationTables (which drops/recreates ALL presentation
-- tables). The "Purchases by Day" build step then populates it on the next
-- DV load -> presentation rebuild for Padel.
--
-- DDL is copied verbatim from 06_purchases_presentation_table.sql (ddl_script).
-- Idempotent: IF NOT EXISTS guard + run from core against the Padel DB by name.
-- ============================================================================

DECLARE @Db NVARCHAR(128) = N'20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14';  -- Padel Social (UAT)

DECLARE @sql NVARCHAR(MAX) = N'USE ' + QUOTENAME(@Db) + N';
IF NOT EXISTS (
    SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = ''presentation'' AND t.name = ''F_PURCHASES_DAY''
)
BEGIN
    CREATE TABLE [presentation].[F_PURCHASES_DAY](
        [INVITEM_HUB_ID]      [binary](32)      NOT NULL,
        [SUPPLIER_HUB_ID]     [binary](32)      NOT NULL,
        [LOCATION_HUB_ID]     [binary](32)      NOT NULL,
        [STOCKORDER_HUB_ID]   [binary](32)      NOT NULL,
        [ORDER_DATE]          [datetime2](7)    NULL,
        [DELIVERY_DATE]       [datetime2](7)    NULL,
        [ORDER_STATUS]        [nvarchar](255)   NULL,
        [UNIT_PRICE]          [decimal](38, 6)  NULL,
        [UNIT_COST]           [decimal](38, 6)  NULL,
        [ORDER_QTY]           [decimal](38, 6)  NULL,
        [LINE_TOTAL]          [decimal](38, 6)  NULL,
        [PACK_SIZE]           [decimal](38, 6)  NULL,
        [PACK_PRICE]          [decimal](38, 6)  NULL,
        [ORDER_REFERENCE]     [nvarchar](255)   NULL
    ) ON [PRIMARY];

    CREATE CLUSTERED INDEX [F_PURCHASES_DAY-CLUSTERED] ON [presentation].[F_PURCHASES_DAY]
        ([ORDER_DATE] ASC, [LOCATION_HUB_ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

    CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-INVITEM] ON [presentation].[F_PURCHASES_DAY]
        ([INVITEM_HUB_ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

    CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-SUPPLIER] ON [presentation].[F_PURCHASES_DAY]
        ([SUPPLIER_HUB_ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

    PRINT ''Task 7: F_PURCHASES_DAY created on Padel Social.'';
END
ELSE
    PRINT ''Task 7: F_PURCHASES_DAY already exists on Padel Social — no action.'';';

EXEC sys.sp_executesql @sql;
-- Next: run DV load + presentation rebuild for Padel so the "Purchases by Day"
-- build step populates the new table.
