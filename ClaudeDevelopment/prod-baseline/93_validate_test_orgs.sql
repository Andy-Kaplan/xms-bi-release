-- ============================================================================
-- 93_validate_test_orgs.sql - Schema parity check for the validation orgs
-- ============================================================================
-- Run against the CORE database of the newly deployed instance (SSMS),
-- after 92_provision_test_orgs.sql. SELECT-only (dynamic SQL reads sys
-- catalog views in each BaselineTest_* client DB).
--
-- Expected values are the UAT reference profile captured 2026-07-06 from an
-- ACTIVE UAT client DB + the core control tables:
--   datavault: 115 tables (35 HUB / 35 SAT / 40 LNK / 5 SAT_LNK)
--   load:       88 tables
--   core:       16 tables | procedures: 31 | functions: 5
--   presentation: 43 tables (all LIVE PresentationTables defs; NOTE - older
--     UAT orgs show fewer because DeployPresentationTables was never re-run
--     after new tables went LIVE. A FRESH org must have all 43.)
--   stage: 0 tables (stage tables are created lazily by the first staging run)
--   DL tables in the mapped integration schema:
--     NCRAloha 21 | Marketman 34 | Growyze 13 | SurveyHero 41 | TROaP 48
-- ============================================================================

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#results') IS NOT NULL DROP TABLE #results;
CREATE TABLE #results (
    OrgName      NVARCHAR(255),
    Metric       NVARCHAR(100),
    Expected     INT,
    Actual       INT
);

DECLARE @OrgName NVARCHAR(255), @DbName NVARCHAR(128), @IntSchema NVARCHAR(128), @DlExpected INT;
DECLARE @sql NVARCHAR(MAX);

DECLARE org_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT o.OrganisationName, o.DatabaseName, i.SchemaName,
           CASE i.IntegrationName
                WHEN 'NCRAloha001'   THEN 21
                WHEN 'Marketman001'  THEN 34
                WHEN 'Growyze001'    THEN 13
                WHEN 'SurveyHero001' THEN 41
                WHEN 'TROaP001'      THEN 48
                ELSE -1 END
    FROM [core].[Organisations] o
    JOIN [core].[OrganisationIntegrations] oi ON oi.OrganisationID = o.OrganisationID
    JOIN [core].[Integrations] i ON i.IntegrationID = oi.IntegrationID
    WHERE o.OrganisationName LIKE N'BaselineTest[_]%'
    ORDER BY o.OrganisationName;

OPEN org_cursor;
FETCH NEXT FROM org_cursor INTO @OrgName, @DbName, @IntSchema, @DlExpected;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF DB_ID(@DbName) IS NULL
    BEGIN
        INSERT INTO #results VALUES (@OrgName, N'client DB exists', 1, 0);
    END
    ELSE
    BEGIN
        SET @sql = N'
        INSERT INTO #results (OrgName, Metric, Expected, Actual)
        SELECT @org, m.metric, m.expected, m.actual
        FROM (
            SELECT ''datavault tables'' AS metric, 115 AS expected,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''datavault'') AS actual
            UNION ALL SELECT ''datavault HUB tables'', 35,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''datavault'' AND t.name LIKE ''HUB[_]%'')
            UNION ALL SELECT ''datavault SAT tables'', 35,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''datavault'' AND t.name LIKE ''SAT[_]%'' AND t.name NOT LIKE ''SAT[_]LNK%'')
            UNION ALL SELECT ''datavault LNK tables'', 40,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''datavault'' AND t.name LIKE ''LNK[_]%'')
            UNION ALL SELECT ''datavault SAT_LNK tables'', 5,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''datavault'' AND t.name LIKE ''SAT[_]LNK%'')
            UNION ALL SELECT ''load tables'', 88,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''load'')
            UNION ALL SELECT ''core tables'', 16,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''core'')
            UNION ALL SELECT ''presentation tables'', 43,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''presentation'')
            UNION ALL SELECT ''stage tables (lazy - 0 pre-load)'', 0,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''stage'')
            UNION ALL SELECT ''procedures'', 31,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.procedures)
            UNION ALL SELECT ''functions'', 5,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.objects WHERE type IN (''FN'',''IF'',''TF''))
            UNION ALL SELECT ''DL tables (' + @IntSchema + N')'', @dlexp,
                   (SELECT COUNT(*) FROM ' + QUOTENAME(@DbName) + N'.sys.tables t JOIN ' + QUOTENAME(@DbName) + N'.sys.schemas s ON s.schema_id = t.schema_id WHERE s.name = ''' + @IntSchema + N''' AND t.name LIKE ''DL[_]%'')
        ) m;';
        EXEC sp_executesql @sql, N'@org NVARCHAR(255), @dlexp INT', @org = @OrgName, @dlexp = @DlExpected;
    END
    FETCH NEXT FROM org_cursor INTO @OrgName, @DbName, @IntSchema, @DlExpected;
END
CLOSE org_cursor; DEALLOCATE org_cursor;

SELECT OrgName, Metric, Expected, Actual,
       CASE WHEN Expected = Actual THEN 'PASS' ELSE 'FAIL' END AS result
FROM #results
ORDER BY OrgName, Metric;
