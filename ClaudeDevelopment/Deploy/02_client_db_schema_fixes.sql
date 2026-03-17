-- ============================================================================
-- 02_client_db_schema_fixes.sql
-- Consolidated deployment script: Client database schema changes
-- Target: Each client database with SurveyHero deployed
-- ============================================================================

-- ============================================================================
-- SECTION 1: ANSWER Entity v3 — widen existing columns to NVARCHAR(MAX)
-- Source: ANSWER_entity_v3_widen_column.sql (Part 2)
--
-- sp_GenerateDataVaultTables uses IF NOT EXISTS guards — it will NOT alter
-- existing tables. These ALTER statements are required for any database where
-- the ANSWER tables have already been deployed.
-- New databases deployed after 01_core_platform_fixes.sql will get
-- NVARCHAR(MAX) automatically from the v3 entity definition.
-- ============================================================================

-- Step 1a: Widen load.ANSWER
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'load' AND TABLE_NAME = 'ANSWER'
      AND COLUMN_NAME = 'ANSWER' AND CHARACTER_MAXIMUM_LENGTH = 255
)
BEGIN
    ALTER TABLE [load].[ANSWER] ALTER COLUMN [ANSWER] NVARCHAR(MAX) NULL;
    PRINT 'load.ANSWER.ANSWER widened to NVARCHAR(MAX)';
END
ELSE
    PRINT 'load.ANSWER.ANSWER — no change needed (already MAX or table does not exist)';

-- Step 1b: Widen datavault.SAT_ANSWER
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'datavault' AND TABLE_NAME = 'SAT_ANSWER'
      AND COLUMN_NAME = 'ANSWER' AND CHARACTER_MAXIMUM_LENGTH = 255
)
BEGIN
    ALTER TABLE [datavault].[SAT_ANSWER] ALTER COLUMN [ANSWER] NVARCHAR(MAX) NULL;
    PRINT 'datavault.SAT_ANSWER.ANSWER widened to NVARCHAR(MAX)';
END
ELSE
    PRINT 'datavault.SAT_ANSWER.ANSWER — no change needed (already MAX or table does not exist)';

GO
