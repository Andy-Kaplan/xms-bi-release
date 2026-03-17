-- ============================================================
-- 13_dedup_presentation_tables.sql
-- Fix: Duplicate PresentationTables records causing NOT NULL
-- constraint errors on F_INV_DAILY_DETAIL build
--
-- Problem: 4 tables have duplicate PresentationTables records.
-- DeployPresentationTables cursor processes ALL duplicates
-- (drop + recreate each), and whichever runs LAST wins.
-- F_INV_DAILY_DETAIL got an old DDL with NOT NULL constraints
-- on THEO_USAGE, ORDER_QTY, etc. — but E_INV_DAILY_DETAIL
-- legitimately has NULL values in those columns, causing:
--   "Cannot insert the value NULL into column 'THEO_USAGE'"
--
-- Fix: Delete old duplicate records, keep only the newest
-- (correct) one for each table. Then ALTER the physical
-- columns to nullable on all org databases.
--
-- Run against: core database (UAT or DEV)
-- ============================================================

USE [core];
GO

-- ============================================================
-- PHASE 1: Delete duplicate PresentationTables records
-- Keep only the newest record for each table_name
-- ============================================================

PRINT '=== Phase 1: Deduplicating PresentationTables ===';

-- F_INV_DAILY_DETAIL: 3 records → keep DD6F3767 (all columns NULL)
DELETE FROM [core].[PresentationTables]
WHERE table_name = 'F_INV_DAILY_DETAIL'
  AND id IN ('FD7287B2-708B-452C-9BF9-30AD91FB5B0B', 'F9D17ED2-E75F-4479-A965-6A78505E6960');

PRINT 'F_INV_DAILY_DETAIL: deleted 2 old records (kept DD6F3767)';

-- E_INV_DAILY_DETAIL: 2 records → keep A352864E (has [presentation]. schema prefix)
DELETE FROM [core].[PresentationTables]
WHERE table_name = 'E_INV_DAILY_DETAIL'
  AND id = 'ED9F2B09-6DCD-4DB0-8CB8-2F8B0399E03D';

PRINT 'E_INV_DAILY_DETAIL: deleted 1 old record (kept A352864E)';

-- F_PRE_INV_DAILY_DETAIL: 2 records → keep E18E20F7 (newer)
DELETE FROM [core].[PresentationTables]
WHERE table_name = 'F_PRE_INV_DAILY_DETAIL'
  AND id = '8B851701-26C0-4F0F-B0B6-9550DB78FB2C';

PRINT 'F_PRE_INV_DAILY_DETAIL: deleted 1 old record (kept E18E20F7)';

-- FORECAST_ACTUALS_BASE: 2 records (identical DDL) → keep 7B22A07B (newer)
DELETE FROM [core].[PresentationTables]
WHERE table_name = 'FORECAST_ACTUALS_BASE'
  AND id = 'A7F38367-7181-426B-98D6-5EA97F7DD166';

PRINT 'FORECAST_ACTUALS_BASE: deleted 1 old record (kept 7B22A07B)';

-- Verify: no more duplicates
SELECT table_name, COUNT(*) AS cnt
FROM [core].[PresentationTables]
GROUP BY table_name
HAVING COUNT(*) > 1;

PRINT '=== Phase 1 complete ===';
GO

-- ============================================================
-- PHASE 2: ALTER physical columns to nullable on all org DBs
-- F_INV_DAILY_DETAIL has THEO_USAGE, ORDER_QTY, SALE_QTY,
-- PRODUCTION_QTY, TRANSFER_QTY, WASTE_QTY as NOT NULL —
-- these must be nullable to match the corrected DDL.
-- ============================================================

PRINT '=== Phase 2: ALTER columns to nullable on all org databases ===';

DECLARE @dbName NVARCHAR(255);
DECLARE @sql NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
SELECT DatabaseName
FROM [core].[Organisations]
WHERE DatabaseStatus IN ('ACTIVE', 'FAILED');

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Processing: ' + @dbName;

    -- ALTER F_INV_DAILY_DETAIL columns to nullable
    SET @sql = N'
    USE [' + @dbName + N'];

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_SCHEMA = ''presentation''
               AND TABLE_NAME = ''F_INV_DAILY_DETAIL''
               AND COLUMN_NAME = ''THEO_USAGE''
               AND IS_NULLABLE = ''NO'')
    BEGIN
        ALTER TABLE [presentation].[F_INV_DAILY_DETAIL]
            ALTER COLUMN [THEO_USAGE] [decimal](38, 6) NULL;
        ALTER TABLE [presentation].[F_INV_DAILY_DETAIL]
            ALTER COLUMN [ORDER_QTY] [decimal](38, 6) NULL;
        ALTER TABLE [presentation].[F_INV_DAILY_DETAIL]
            ALTER COLUMN [SALE_QTY] [decimal](38, 6) NULL;
        ALTER TABLE [presentation].[F_INV_DAILY_DETAIL]
            ALTER COLUMN [PRODUCTION_QTY] [decimal](38, 6) NULL;
        ALTER TABLE [presentation].[F_INV_DAILY_DETAIL]
            ALTER COLUMN [TRANSFER_QTY] [decimal](38, 6) NULL;
        ALTER TABLE [presentation].[F_INV_DAILY_DETAIL]
            ALTER COLUMN [WASTE_QTY] [decimal](38, 6) NULL;
        PRINT ''  F_INV_DAILY_DETAIL: 6 columns altered to nullable'';
    END
    ELSE
        PRINT ''  F_INV_DAILY_DETAIL: already nullable (skipped)'';
    ';

    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT '  ERROR on ' + @dbName + ': ' + ERROR_MESSAGE();
    END CATCH

    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT '=== Phase 2 complete ===';
GO

-- ============================================================
-- Verification: check no NOT NULL constraints remain
-- ============================================================
PRINT '=== Verification ===';

-- Check control table deduplication
SELECT table_name, COUNT(*) AS record_count
FROM [core].[PresentationTables]
WHERE table_name IN ('F_INV_DAILY_DETAIL', 'E_INV_DAILY_DETAIL',
                     'F_PRE_INV_DAILY_DETAIL', 'FORECAST_ACTUALS_BASE')
GROUP BY table_name
ORDER BY table_name;

PRINT 'All tables should show record_count = 1';
PRINT 'After running this script, re-trigger the presentation build for affected orgs.';
GO
