-- ============================================================================
-- ANSWER Entity v3: Widen ANSWER attribute from NVARCHAR(255) to NVARCHAR(MAX)
-- ============================================================================
-- Problem: SurveyHero free-text responses exceed 255 characters (max observed: 1,071).
--          sp_DataVaultLoad fails with error 2628 (truncation) at PopulateLoadTable
--          for the ANSWER entity.
--
-- Fix:     1. Retire ANSWER v2, create ANSWER v3 with ANSWER attribute as NVARCHAR(MAX)
--          2. ALTER existing load.ANSWER and datavault.SAT_ANSWER columns
--
-- Note:    sp_GenerateDataVaultTables uses IF NOT EXISTS guards — it will NOT alter
--          existing tables. The ALTER TABLE statements below are required for any
--          database where the ANSWER tables have already been deployed.
-- ============================================================================

-- ============================================================================
-- PART 1: Core database — Entity definition update
-- Run against: core database
-- ============================================================================

-- Step 1a: Retire ANSWER v2
UPDATE [core].[core].[DataVaultEntities]
SET RELEASE_STATE = N'Retired',
    UPDATED_AT = GETDATE()
WHERE ENTITY_NAME = N'ANSWER'
  AND VERSION = 2
  AND RELEASE_STATE = N'Live';

-- Step 1b: Insert ANSWER v3 (idempotent — skips if v3 already exists)
MERGE INTO [core].[core].[DataVaultEntities] AS tgt
USING (VALUES (
    N'ANSWER',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ANSWER_ID"]',
    N'[{"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]'
)) AS src (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
           TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES)
ON tgt.ENTITY_NAME = src.ENTITY_NAME AND tgt.VERSION = src.VERSION
WHEN MATCHED THEN
    UPDATE SET
        RELEASE_STATE = src.RELEASE_STATE,
        SPLIT_MAP = src.SPLIT_MAP,
        PRIMARY_SOURCE_TYPE = src.PRIMARY_SOURCE_TYPE,
        TIME_SERIES = src.TIME_SERIES,
        TIME_SERIES_COLUMN = src.TIME_SERIES_COLUMN,
        DESCRIPTION = src.DESCRIPTION,
        ATTRIBUTE_NAMES = src.ATTRIBUTE_NAMES,
        ATTRIBUTE_TYPES = src.ATTRIBUTE_TYPES,
        UPDATED_AT = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
            TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
            CREATED_AT, UPDATED_AT)
    VALUES (src.ENTITY_NAME, src.VERSION, src.RELEASE_STATE, src.SPLIT_MAP, src.PRIMARY_SOURCE_TYPE,
            src.TIME_SERIES, src.TIME_SERIES_COLUMN, src.DESCRIPTION, src.ATTRIBUTE_NAMES, src.ATTRIBUTE_TYPES,
            GETDATE(), GETDATE());


-- ============================================================================
-- PART 2: Client database — ALTER existing tables
-- Run against: each client database that has SurveyHero deployed
--
-- sp_GenerateDataVaultTables will NOT alter existing tables (IF NOT EXISTS guard).
-- These ALTER statements are required to widen the column on already-deployed tables.
-- New databases deployed AFTER Part 1 will get NVARCHAR(MAX) automatically.
-- ============================================================================

-- Step 2a: Widen load.ANSWER
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

-- Step 2b: Widen datavault.SAT_ANSWER
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
