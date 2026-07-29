-- ============================================
-- 11a_reference_margebrut_manual_all_orgs.sql
-- Creates an EMPTY reference.MARGEBRUT_MANUAL in every organisation database.
-- Run against `core`. Companion to 11_reference_margebrut_manual.sql, which
-- creates AND seeds the table for the Marge Brut target organisation.
--
-- WHY THIS EXISTS
-- core.core.PresentationControl is a GLOBAL control table: the F_MARGEBRUT_MONTH
-- step registered by 13 is executed for EVERY organisation on its presentation
-- rebuild, and its query LEFT JOINs reference.MARGEBRUT_MANUAL. No other
-- PresentationControl step references the `reference` schema, so this is the
-- first step to introduce a per-organisation object dependency.
--
-- There are two independent guards; this script is the second one:
--   1. core.sp_ExecuteQuery returns early with a PRINT'd warning when the target
--      table (presentation.F_MARGEBRUT_MONTH) does not exist, so an organisation
--      that has never had it deployed skips the step cleanly. Verified in the
--      live procedure body on UAT.
--   2. If an organisation later receives a full DeployPresentationTables run, it
--      WILL get presentation.F_MARGEBRUT_MONTH (PresentationTables is global
--      too), and guard 1 stops applying. Without this script the step would then
--      fail on `Invalid object name 'reference.MARGEBRUT_MANUAL'` -- caught per
--      step by sp_ProcessPresentation (@StopOnError = 0), so the build would
--      still finish, but every run would log a standing Failed step that masks
--      real failures.
--
-- An empty table is harmless: 13 LEFT JOINs it, so REV_PROV / NEW_PROV /
-- STAFF_MEAL come back NULL and are ISNULL'd to 0 in the build. Organisations
-- without Mews + Growyze produce no rows at all.
--
-- Idempotent: OBJECT_ID guard per database, so re-running changes nothing. Never
-- seeds data -- seeding is 11's job, for the target organisation only.
--
-- Executes in each organisation's context via the three-part sp_executesql
-- pattern (EXEC [db].sys.sp_executesql), per CLAUDE.md "Key Patterns".
-- ============================================

SET NOCOUNT ON;

DECLARE @DatabaseName   NVARCHAR(255);
DECLARE @OrganisationID INT;
DECLARE @ExecProc       NVARCHAR(400);
DECLARE @Stmt           NVARCHAR(MAX);
DECLARE @Outcome        NVARCHAR(60);

CREATE TABLE #Result (
    OrganisationID INT,
    DatabaseName   NVARCHAR(255),
    Outcome        NVARCHAR(60)
);

SET @Stmt = N'
IF SCHEMA_ID(N''reference'') IS NULL
    EXEC(N''CREATE SCHEMA [reference]'');

IF OBJECT_ID(N''[reference].[MARGEBRUT_MANUAL]'') IS NULL
    CREATE TABLE [reference].[MARGEBRUT_MANUAL](
        [GROUP_NAME]    NVARCHAR(50)  NOT NULL,
        [PERIOD_MONTH]  DATE          NOT NULL,
        [REV_PROV]      DECIMAL(18,2) NOT NULL DEFAULT 0,
        [NEW_PROV]      DECIMAL(18,2) NOT NULL DEFAULT 0,
        [STAFF_MEAL]    DECIMAL(18,2) NOT NULL DEFAULT 0,
        [COMP_COST_PCT] DECIMAL(9,4)  NOT NULL DEFAULT 0,
        CONSTRAINT [PK_MARGEBRUT_MANUAL] PRIMARY KEY ([GROUP_NAME],[PERIOD_MONTH])
    );

SELECT @OutcomeOut = CASE WHEN OBJECT_ID(N''[reference].[MARGEBRUT_MANUAL]'') IS NULL
                          THEN N''FAILED - still absent''
                          ELSE N''PRESENT''
                     END;';

DECLARE org_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT OrganisationID, DatabaseName
    FROM [core].[Organisations]
    WHERE DatabaseStatus IN (N'ACTIVE', N'FAILED')
      AND DatabaseName IS NOT NULL
    ORDER BY OrganisationID;

OPEN org_cursor;
FETCH NEXT FROM org_cursor INTO @OrganisationID, @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF DB_ID(@DatabaseName) IS NULL
    BEGIN
        INSERT INTO #Result (OrganisationID, DatabaseName, Outcome)
        VALUES (@OrganisationID, @DatabaseName, N'SKIPPED - database not on this server');
    END
    ELSE
    BEGIN
        SET @Outcome = NULL;

        BEGIN TRY
            SET @ExecProc = QUOTENAME(@DatabaseName) + N'.sys.sp_executesql';

            EXEC @ExecProc @Stmt,
                 N'@OutcomeOut NVARCHAR(60) OUTPUT',
                 @OutcomeOut = @Outcome OUTPUT;

            INSERT INTO #Result (OrganisationID, DatabaseName, Outcome)
            VALUES (@OrganisationID, @DatabaseName, ISNULL(@Outcome, N'FAILED - no outcome returned'));
        END TRY
        BEGIN CATCH
            INSERT INTO #Result (OrganisationID, DatabaseName, Outcome)
            VALUES (@OrganisationID, @DatabaseName,
                    LEFT(N'ERROR - ' + ERROR_MESSAGE(), 60));
        END CATCH
    END

    FETCH NEXT FROM org_cursor INTO @OrganisationID, @DatabaseName;
END

CLOSE org_cursor;
DEALLOCATE org_cursor;

-- Per-organisation outcome, then a PASS/FAIL roll-up.
SELECT OrganisationID, DatabaseName, Outcome
FROM #Result
ORDER BY OrganisationID;

SELECT
    COUNT(*)                                                              AS OrgsProcessed,
    SUM(CASE WHEN Outcome = N'PRESENT' THEN 1 ELSE 0 END)                 AS TablePresent,
    SUM(CASE WHEN Outcome LIKE N'SKIPPED%' THEN 1 ELSE 0 END)             AS Skipped,
    SUM(CASE WHEN Outcome LIKE N'ERROR%' OR Outcome LIKE N'FAILED%'
             THEN 1 ELSE 0 END)                                           AS Problems,
    CASE WHEN SUM(CASE WHEN Outcome LIKE N'ERROR%' OR Outcome LIKE N'FAILED%'
                       THEN 1 ELSE 0 END) = 0
         THEN N'PASS' ELSE N'FAIL' END                                    AS Verdict
FROM #Result;

DROP TABLE #Result;
