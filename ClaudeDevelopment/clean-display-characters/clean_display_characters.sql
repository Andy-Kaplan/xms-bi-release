-- ============================================================
-- Clean Display Characters — DV Load Sanitisation
-- ============================================================
-- Adds a scalar function to every client DB that replaces
-- characters which break the HTML frontend, and modifies
-- BuildSelectClause to wrap all pass-through (hash:0) columns
-- with it.
--
-- Deploy order:
--   1. Run Part 1 against the CORE database (DeploymentObjects record)
--   2. Run sp_DeployObjects for each active org (deploys the function)
--   3. Run Part 2 against the CORE database (updated BuildSelectClause)
--   4. Run UploadEntityMappings for each integration schema to
--      regenerate the load SQL in StagingControl
--
-- After deployment, the next sp_DataVaultLoad run will automatically
-- clean all pass-through attribute values as they enter the load tables.
-- ============================================================


-- ============================================================
-- PART 1: DeploymentObjects record for fnCleanForDisplay
-- Run against: core database
-- ============================================================

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'fnCleanForDisplay', N'FUNCTION')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = 24,
        Category       = N'Core Functions',
        Description    = N'Replaces characters that break HTML frontend rendering (e.g. straight apostrophe → typographic)',
        CreationScript = N'CREATE FUNCTION {SCHEMA}.[fnCleanForDisplay]
(
    @input NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @input IS NULL RETURN NULL;
    SET @input = REPLACE(@input, NCHAR(39), NCHAR(8217));
    RETURN @input;
END;',
        DropScript     = N'DROP FUNCTION IF EXISTS {SCHEMA}.[fnCleanForDisplay];',
        IsActive       = 1,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (
        N'fnCleanForDisplay',
        N'FUNCTION',
        24,
        N'Core Functions',
        N'Replaces characters that break HTML frontend rendering (e.g. straight apostrophe → typographic)',
        N'CREATE FUNCTION {SCHEMA}.[fnCleanForDisplay]
(
    @input NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @input IS NULL RETURN NULL;
    SET @input = REPLACE(@input, NCHAR(39), NCHAR(8217));
    RETURN @input;
END;',
        N'DROP FUNCTION IF EXISTS {SCHEMA}.[fnCleanForDisplay];',
        1,
        GETDATE()
    );
GO


-- ============================================================
-- PART 2: Updated BuildSelectClause
-- Run against: core database
-- ============================================================
-- Single change: hash_type 0 now wraps the column with
-- core.fnCleanForDisplay() instead of passing it through raw.
-- ============================================================

CREATE OR ALTER PROCEDURE [core].[BuildSelectClause]
    @entityName NVARCHAR(128),
    @intSchema NVARCHAR(128),
    @selectClause NVARCHAR(MAX) OUTPUT,
    @partitionExpression NVARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @isLink BIT = CASE WHEN CHARINDEX('_', @entityName, 1) > 0 THEN 1 ELSE 0 END;
    DECLARE @linkIdPart NVARCHAR(MAX) = '';
    DECLARE @columnsPart NVARCHAR(MAX);
    DECLARE @standardPart NVARCHAR(MAX);

    -- Build LINK ID hash if this is a link entity
    IF @isLink = 1
    BEGIN
        SELECT @linkIdPart =
            'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' +
            STRING_AGG(
                CASE hash_type
                    WHEN 1 THEN 'CONCAT_WS(''|'', ' + column_name + ', ''' + @intSchema + ''')'
                    WHEN 2 THEN column_name
                END, ', '
            ) WITHIN GROUP (ORDER BY ordinal) + ') AS VARBINARY(MAX))) AS LNK_ID'
        FROM #ParsedSourceColumns
        WHERE entity_name = @entityName AND hash_type > 0;

        -- Partition expression without alias
        SELECT @partitionExpression =
            'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' +
            STRING_AGG(
                CASE hash_type
                    WHEN 1 THEN 'CONCAT_WS(''|'', ' + column_name + ', ''' + @intSchema + ''')'
                    WHEN 2 THEN column_name
                END, ', '
            ) WITHIN GROUP (ORDER BY ordinal) + ') AS VARBINARY(MAX)))'
        FROM #ParsedSourceColumns
        WHERE entity_name = @entityName AND hash_type > 0;
    END
    ELSE
    BEGIN
        -- For hubs/satellites, extract the partition expression (HUB_ID without alias)
        SELECT TOP 1 @partitionExpression =
            'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' + column_name + ', ''' + @intSchema + ''') AS VARBINARY(MAX)))'
        FROM #ParsedSourceColumns
        WHERE entity_name = @entityName AND hash_type = 1
        ORDER BY ordinal;
    END;

    -- Build columns part with aliases from entity_columns
    -- hash:0 columns are wrapped with fnCleanForDisplay to sanitise
    -- display characters (e.g. straight apostrophe) at DV load time
    SELECT @columnsPart = STRING_AGG(
        CASE sc.hash_type
            WHEN 0 THEN 'core.fnCleanForDisplay(' + sc.column_name + ')'
            WHEN 1 THEN 'HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ' + sc.column_name + ', ''' + @intSchema + ''') AS VARBINARY(MAX)))'
            WHEN 2 THEN 'HASHBYTES(''SHA2_256'', CAST(' + sc.column_name + ' AS VARBINARY(MAX)))'
        END + ' AS ' + ec.column_name, ', '
    ) WITHIN GROUP (ORDER BY sc.ordinal)
    FROM #ParsedSourceColumns sc
    JOIN #ParsedEntityColumns ec ON sc.entity_name = ec.entity_name AND sc.ordinal = ec.ordinal
    WHERE sc.entity_name = @entityName;

    -- Add standard columns with aliases
    IF @isLink = 1
        SET @standardPart = ', GETDATE() AS LOAD_TS, ''' + @intSchema + ''' AS SRC';
    ELSE
        SET @standardPart = ', CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''' + @intSchema + ''' AS SRC';

    -- Build final select clause
    IF LEN(@linkIdPart) > 0
        SET @selectClause = @linkIdPart + ', ' + @columnsPart + @standardPart;
    ELSE
        SET @selectClause = @columnsPart + @standardPart;
END;
GO
