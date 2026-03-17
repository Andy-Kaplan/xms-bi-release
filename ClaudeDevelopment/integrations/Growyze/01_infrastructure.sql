/*
================================================================================
  Growyze Integration — Infrastructure Setup
  File:    01_infrastructure.sql
  Date:    2026-03-05
  Purpose: Creates the reference schema and UOM_CONVERSION table required by
           Growyze staging and mapping scripts. Must be run against the core
           database before any other Growyze deployment scripts.

  Contents:
    1. Create [reference] schema (IF NOT EXISTS)
    2. Create [reference].[UOM_CONVERSION] table
    3. Seed 14 UOM conversion records (MERGE upsert — re-runnable)
================================================================================
*/

-- ============================================================================
-- 1. Create [reference] schema
-- ============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reference')
BEGIN
    EXEC(N'CREATE SCHEMA [reference]');
END
GO

-- ============================================================================
-- 2. Create [reference].[UOM_CONVERSION] table
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = N'reference' AND t.name = N'UOM_CONVERSION'
)
BEGIN
    CREATE TABLE [reference].[UOM_CONVERSION] (
        FROM_UOM          NVARCHAR(50)    NOT NULL,
        TO_UOM            NVARCHAR(50)    NOT NULL,
        CONVERSION_FACTOR DECIMAL(18,10)  NOT NULL,
        UOM_CATEGORY      NVARCHAR(20)    NOT NULL,
        IS_STANDARD       BIT             NOT NULL DEFAULT 0,
        NOTES             NVARCHAR(200)   NULL,
        CONSTRAINT PK_UOM_CONVERSION PRIMARY KEY (FROM_UOM, TO_UOM)
    );
END
GO

-- ============================================================================
-- 3. Seed UOM conversion records (14 rows)
-- ============================================================================

MERGE INTO [reference].[UOM_CONVERSION] AS tgt
USING (VALUES
    (N'ml',         N'ml',         1.0000000000,  N'VOLUME',  1),
    (N'cl',         N'ml',         10.0000000000, N'VOLUME',  0),
    (N'L',          N'ml',         1000.0000000000, N'VOLUME', 0),
    (N'fl_oz_UK',   N'ml',         28.4131000000, N'VOLUME',  0),
    (N'hf_pt_UK',   N'ml',         284.1310000000, N'VOLUME', 0),
    (N'pt_UK',      N'ml',         568.2610000000, N'VOLUME', 0),
    (N'gal',        N'ml',         4546.0900000000, N'VOLUME', 0),
    (N'g',          N'g',          1.0000000000,  N'WEIGHT',  1),
    (N'kg',         N'g',          1000.0000000000, N'WEIGHT', 0),
    (N'oz',         N'g',          28.3495000000, N'WEIGHT',  0),
    (N'each',       N'each',       1.0000000000,  N'COUNT',   1),
    (N'full',       N'each',       1.0000000000,  N'COUNT',   0),
    (N'portion',    N'portion',    1.0000000000,  N'SPECIAL', 1),
    (N'percentage', N'percentage', 1.0000000000,  N'SPECIAL', 1)
) AS src (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD)
ON tgt.FROM_UOM = src.FROM_UOM AND tgt.TO_UOM = src.TO_UOM
WHEN MATCHED THEN
    UPDATE SET
        CONVERSION_FACTOR = src.CONVERSION_FACTOR,
        UOM_CATEGORY      = src.UOM_CATEGORY,
        IS_STANDARD       = src.IS_STANDARD
WHEN NOT MATCHED THEN
    INSERT (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD)
    VALUES (src.FROM_UOM, src.TO_UOM, src.CONVERSION_FACTOR, src.UOM_CATEGORY, src.IS_STANDARD);
GO
