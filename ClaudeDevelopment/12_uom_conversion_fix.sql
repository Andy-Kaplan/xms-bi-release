/*
    12_uom_conversion_fix.sql
    =========================
    1. Adds 4 MarketMan UOM records to core.reference.UOM_CONVERSION
    2. Replaces hardcoded UOMConversion CTE in 3 PresentationControl steps
       (F_INV_USAGE_DAY, F_INV_COUNTS_DAY, F_INV_SALES_DAY) with a reference
       to the centralised UOM_CONVERSION table.

    Fixes:
    - 61.7% of Growyze F_INV_USAGE_DAY rows with NULL STANDARDISED_UOM
    - ORDER quantities understated by ~75% for Growyze
    - Future-proofs UOM handling for new integrations

    MarketMan impact:
    - Existing UOMs (Kg, L, EA, gr) match reference table rows via CI collation
    - STANDARDISED_UOM output changes: 'gr' -> 'g', 'EA' -> 'each' (cosmetic)
    - No numeric/calculation changes

    PK on UOM_CONVERSION is (FROM_UOM, TO_UOM). Collation is CI_AS, so
    MarketMan 'Kg' matches existing 'kg' row and 'Gal' matches 'gal'.
    Only genuinely distinct UOM strings need new records.

    Run against: core database
    Idempotent: Yes (MERGE + conditional UPDATE with LIKE guard)
*/

-- ============================================================================
-- PART 1: Add MarketMan UOM records to reference.UOM_CONVERSION
-- ============================================================================

MERGE INTO [reference].[UOM_CONVERSION] AS tgt
USING (VALUES
    (N'gr',            N'g',    CAST(1         AS DECIMAL(18,6)), N'WEIGHT', 0, N'MarketMan weight base (alias of g)'),
    (N'lb',            N'g',    CAST(453.59237 AS DECIMAL(18,6)), N'WEIGHT', 0, N'MarketMan imperial weight'),
    (N'EA',            N'each', CAST(1         AS DECIMAL(18,6)), N'COUNT',  0, N'MarketMan count unit'),
    (N'Imperial Pint', N'ml',   CAST(568.26125 AS DECIMAL(18,6)), N'VOLUME', 0, N'MarketMan imperial volume')
) AS src (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD, NOTES)
ON  tgt.FROM_UOM = src.FROM_UOM
AND tgt.TO_UOM   = src.TO_UOM
WHEN MATCHED THEN
    UPDATE SET
        CONVERSION_FACTOR = src.CONVERSION_FACTOR,
        UOM_CATEGORY      = src.UOM_CATEGORY,
        IS_STANDARD       = src.IS_STANDARD,
        NOTES             = src.NOTES
WHEN NOT MATCHED THEN
    INSERT (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD, NOTES)
    VALUES (src.FROM_UOM, src.TO_UOM, src.CONVERSION_FACTOR,
            src.UOM_CATEGORY, src.IS_STANDARD, src.NOTES);

-- ============================================================================
-- PART 2: Replace hardcoded UOMConversion CTE in 3 PresentationControl steps
-- ============================================================================
--
-- Strategy: dynamically extract the old CTE body from each step's query_sql
-- using known start/end markers, then REPLACE with a single-line SELECT
-- from the reference table. This avoids hardcoding whitespace/line-ending
-- assumptions.
--
-- The new CTE preserves column aliases (UOM, base_uom, conversion_factor)
-- so all downstream references in each query remain valid.
-- ============================================================================

DECLARE @step_name NVARCHAR(200);
DECLARE @sql NVARCHAR(MAX);
DECLARE @old_start INT;
DECLARE @old_end INT;
DECLARE @old_body NVARCHAR(MAX);

DECLARE @marker_start NVARCHAR(200) =
    N'SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor';
DECLARE @marker_end NVARCHAR(200) =
    N'''EA'', ''EA'', 1';

DECLARE @new_body NVARCHAR(MAX) =
    N'SELECT [FROM_UOM] AS UOM, [TO_UOM] AS base_uom, '
  + N'CAST([CONVERSION_FACTOR] AS DECIMAL(18,6)) AS conversion_factor '
  + N'FROM [core].[reference].[UOM_CONVERSION]';

-- Cursor over the 3 inventory steps that still have the hardcoded CTE
DECLARE step_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT step_name
    FROM [core].[PresentationControl]
    WHERE step_name IN (
        N'Inventory Usage by Day',
        N'Inventory Counts by Day',
        N'Inventory Sales by Day'
    )
    AND CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%SELECT ''gr'' AS UOM, ''gr'' AS base_uom%';

OPEN step_cursor;
FETCH NEXT FROM step_cursor INTO @step_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Extract the current query text
    SELECT @sql = CAST(query_sql AS NVARCHAR(MAX))
    FROM [core].[PresentationControl]
    WHERE step_name = @step_name;

    -- Locate the old CTE body: from the first SELECT to the end of 'EA', 'EA', 1
    SET @old_start = CHARINDEX(@marker_start, @sql);
    SET @old_end   = CHARINDEX(@marker_end, @sql, @old_start) + LEN(@marker_end);

    IF @old_start > 0 AND @old_end > @old_start
    BEGIN
        SET @old_body = SUBSTRING(@sql, @old_start, @old_end - @old_start);

        UPDATE [core].[PresentationControl]
        SET query_sql  = CAST(REPLACE(CAST(query_sql AS NVARCHAR(MAX)),
                                      @old_body, @new_body) AS TEXT),
            updated_at = GETDATE()
        WHERE step_name = @step_name;

        PRINT N'Updated: ' + @step_name;
    END
    ELSE
    BEGIN
        PRINT N'WARNING: Could not locate CTE markers in: ' + @step_name;
    END

    FETCH NEXT FROM step_cursor INTO @step_name;
END

CLOSE step_cursor;
DEALLOCATE step_cursor;

-- ============================================================================
-- PART 3: Verification
-- ============================================================================

-- Confirm all 3 steps now reference the UOM_CONVERSION table
SELECT
    step_name,
    CASE
        WHEN CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%[[]core].[[]reference].[[]UOM_CONVERSION]%'
        THEN 'OK - references UOM_CONVERSION table'
        WHEN CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%SELECT ''gr'' AS UOM%'
        THEN 'FAIL - still has hardcoded CTE'
        ELSE 'UNKNOWN'
    END AS status
FROM [core].[PresentationControl]
WHERE step_name IN (
    N'Inventory Usage by Day',
    N'Inventory Counts by Day',
    N'Inventory Sales by Day'
);

-- Confirm reference table now has both MarketMan and Growyze UOMs
SELECT FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, NOTES
FROM [reference].[UOM_CONVERSION]
ORDER BY UOM_CATEGORY, FROM_UOM;
