-- ============================================================
-- 12_widen_standardised_uom.sql
-- Fix: STANDARDISED_UOM varchar(2) too narrow for UOM_CONVERSION
--      values like 'each' (4 chars), 'percentage' (10 chars)
-- Cause: Presentation build INSERT fails with error 8152
--        "String or binary data would be truncated"
--        leaving F_INV_COUNTS_DAY and F_INV_USAGE_DAY empty
-- Scope: 5 presentation tables, PresentationTables DDL,
--        PresentationControl column_mappings, physical tables
-- Run against: core database
-- ============================================================

-- ============================================================
-- PART 1: Update PresentationTables DDL records
--         varchar(2) -> varchar(20) for STANDARDISED_UOM
-- ============================================================

UPDATE core.core.PresentationTables
SET ddl_script = REPLACE(ddl_script, N'[varchar](2)', N'[varchar](20)'),
    column_definitions = REPLACE(column_definitions, N'[varchar](2)', N'[varchar](20)'),
    updated_at = GETDATE()
WHERE table_name IN (
    'F_INV_COUNTS_DAY',
    'F_INV_USAGE_DAY',
    'E_INV_DAILY_DETAIL',
    'F_INV_DAILY_DETAIL',
    'F_PRE_INV_DAILY_DETAIL'
)
AND (ddl_script LIKE N'%[[]varchar](2)%' OR column_definitions LIKE N'%[[]varchar](2)%');

-- ============================================================
-- PART 2: Update PresentationControl column_mappings
--         "[varchar](2)" -> "[varchar](20)" in JSON
-- ============================================================

UPDATE core.core.PresentationControl
SET column_mappings = REPLACE(column_mappings, N'[varchar](2)', N'[varchar](20)'),
    updated_at = GETDATE()
WHERE table_name IN (
    'F_INV_COUNTS_DAY',
    'F_INV_USAGE_DAY',
    'E_INV_DAILY_DETAIL',
    'F_INV_DAILY_DETAIL',
    'F_PRE_INV_DAILY_DETAIL'
)
AND column_mappings LIKE N'%[[]varchar](2)%';

-- ============================================================
-- PART 3: ALTER physical tables in ALL client databases
--         Widen STANDARDISED_UOM from varchar(2) to varchar(20)
-- ============================================================

DECLARE @DatabaseName NVARCHAR(256);
DECLARE @SQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DatabaseName
    FROM core.core.Organisations
    WHERE DatabaseStatus IN ('ACTIVE', 'FAILED');

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Build ALTER statements for all 5 tables
    -- Each ALTER is wrapped in IF EXISTS to handle orgs that
    -- may not have all tables yet
    SET @SQL = N'
    USE [' + @DatabaseName + N'];

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_SCHEMA = ''presentation''
               AND TABLE_NAME = ''F_INV_COUNTS_DAY''
               AND COLUMN_NAME = ''STANDARDISED_UOM''
               AND CHARACTER_MAXIMUM_LENGTH < 20)
        ALTER TABLE [presentation].[F_INV_COUNTS_DAY]
            ALTER COLUMN [STANDARDISED_UOM] [varchar](20) NULL;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_SCHEMA = ''presentation''
               AND TABLE_NAME = ''F_INV_USAGE_DAY''
               AND COLUMN_NAME = ''STANDARDISED_UOM''
               AND CHARACTER_MAXIMUM_LENGTH < 20)
        ALTER TABLE [presentation].[F_INV_USAGE_DAY]
            ALTER COLUMN [STANDARDISED_UOM] [varchar](20) NULL;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_SCHEMA = ''presentation''
               AND TABLE_NAME = ''E_INV_DAILY_DETAIL''
               AND COLUMN_NAME = ''STANDARDISED_UOM''
               AND CHARACTER_MAXIMUM_LENGTH < 20)
        ALTER TABLE [presentation].[E_INV_DAILY_DETAIL]
            ALTER COLUMN [STANDARDISED_UOM] [varchar](20) NULL;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_SCHEMA = ''presentation''
               AND TABLE_NAME = ''F_INV_DAILY_DETAIL''
               AND COLUMN_NAME = ''STANDARDISED_UOM''
               AND CHARACTER_MAXIMUM_LENGTH < 20)
        ALTER TABLE [presentation].[F_INV_DAILY_DETAIL]
            ALTER COLUMN [STANDARDISED_UOM] [varchar](20) NULL;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_SCHEMA = ''presentation''
               AND TABLE_NAME = ''F_PRE_INV_DAILY_DETAIL''
               AND COLUMN_NAME = ''STANDARDISED_UOM''
               AND CHARACTER_MAXIMUM_LENGTH < 20)
        ALTER TABLE [presentation].[F_PRE_INV_DAILY_DETAIL]
            ALTER COLUMN [STANDARDISED_UOM] [varchar](20) NULL;
    ';

    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- ============================================================
-- POST-DEPLOY: Rebuild presentation layer for affected orgs
-- ============================================================
