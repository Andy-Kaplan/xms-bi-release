/*
    16_filter_tr_locations.sql
    ==========================
    Filters out non-Padel Social locations from the Growyze pipeline.

    Problem:
        The Growyze API returns ALL organisations visible to the API key,
        including TR Enterprise (+ TR Sub 1, TR Sub 2) and a DEMO org
        ("Three Rocks"). These don't belong to Padel Social but appear in
        the DV and presentation layers.

    Source data (DL_ORGANIZATIONS):
        Padel Social Club  MAIN  mainOrgId=NULL    ← primary
        Earls Court        SUB   mainOrgId=68d63a92...  ← belongs to PSC
        O2                 SUB   mainOrgId=68d63a92...  ← belongs to PSC
        TR Enterprise      MAIN  mainOrgId=NULL    ← different org tree
        TR Sub 1           SUB   mainOrgId=691f0e8d...  ← belongs to TRE
        TR Sub 2           SUB   mainOrgId=691f0e8d...  ← belongs to TRE
        Three Rocks        DEMO  mainOrgId=NULL    ← demo data

    Fix (2 parts):
        Part A: Update staging SQL to only include the primary MAIN org
                and its SUBs, excluding DEMO orgs. Uses earliest LOADTS_UTC
                to identify the primary MAIN org — works for any Growyze
                account with multiple MAIN orgs.
        Part B: Clean up existing presentation data so dashboards show
                correct locations immediately without a full reload.

    Part A — Run against: core database
    Part B — Run against: Growyze client database (e.g. Padel Social)
    Idempotent: Yes
*/


-- =========================================================
-- PART A: Fix staging SQL (run against core database)
-- =========================================================

UPDATE [int_growyze001].[StagingControl]
SET query_sql = N'IF OBJECT_ID(''stage.GRYZ_LOCATION'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LOCATION]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_ORGANIZATIONS] ), primary_main AS ( SELECT TOP 1 id FROM deduped WHERE rn = 1 AND type = ''MAIN'' ORDER BY LOADTS_UTC ASC, id ASC ) SELECT * INTO [stage].[GRYZ_LOCATION] FROM ( SELECT id AS HUB_ID, companyName AS LOCATION_NAME, id AS LOCATION_ID, ''Location'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS PARENT_ID, NULL AS MICROSERVICE_NAME, id AS MICROSERVICE_ID, type AS ATTR_1 FROM deduped WHERE rn = 1 AND type != ''DEMO'' AND ( (type = ''MAIN'' AND id = (SELECT id FROM primary_main)) OR (type = ''SUB'' AND mainOrgId = (SELECT id FROM primary_main)) ) ) AS source_query;',
    updated_at = GETDATE()
WHERE step_name = 'Growyze Location'
  AND step_type = 'Staging';


-- =========================================================
-- PART B: Clean up presentation tables (run against client DB)
-- Removes TR locations + their fact rows.
-- After Part A, next pipeline run won't recreate them.
-- =========================================================

-- Delete fact rows referencing TR/DEMO locations
DELETE FU
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[D_LOCATION] dl ON FU.LOCATION_HUB_ID = dl.BOTTOM_HUB_ID
WHERE dl.BOTTOM_LOCATION_NAME IN ('Three Rocks', 'TR Enterprise', 'TR Sub 1', 'TR Sub 2');

DELETE F
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[D_LOCATION] dl ON F.LOCATION_HUB_ID = dl.BOTTOM_HUB_ID
WHERE dl.BOTTOM_LOCATION_NAME IN ('Three Rocks', 'TR Enterprise', 'TR Sub 1', 'TR Sub 2');

DELETE F
FROM [presentation].[F_INV_SALES_DAY] F
INNER JOIN [presentation].[D_LOCATION] dl ON F.LOCATION_HUB_ID = dl.BOTTOM_HUB_ID
WHERE dl.BOTTOM_LOCATION_NAME IN ('Three Rocks', 'TR Enterprise', 'TR Sub 1', 'TR Sub 2');

-- Delete the dimension rows
DELETE FROM [presentation].[D_LOCATION]
WHERE BOTTOM_LOCATION_NAME IN ('Three Rocks', 'TR Enterprise', 'TR Sub 1', 'TR Sub 2');
