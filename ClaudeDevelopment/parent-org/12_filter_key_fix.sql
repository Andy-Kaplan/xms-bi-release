/*
    12_filter_key_fix.sql
    ---------------------
    Fix: Group Overview dashboard filters have no effect on visualisations.

    Two bugs:

    1. FilterDefinitions key mismatch: DashboardGridFilter.DataSet values are
       "ParentOrganisations" and "ParentLocations", but the FilterDefinitions
       JSON keys in the 11 chart vis queries used "Organisations" and "Locations".
       The system matches by name, so filter selections were never injected into
       @FilterClause.

    2. ParentOrganisations FilterList ID column: returns ORG_CODE (a GUID) as [ID],
       but chart FilterDefinitions filter on org.[ORG_NAME] (a name string). The
       system sends the [ID] value in @FilterClause, producing:
           AND org.[ORG_NAME] IN ('5AD1BEAC-31FD-...')
       which never matches. Fix: return ORG_NAME as both [Label] and [ID].

    Affects: All 11 Parent* chart/KPI vis queries + ParentOrganisations FilterList.
    Safe to re-run (idempotent).
*/

-- Fix 1: Rename FilterDefinitions keys to match DashboardGridFilter.DataSet names
UPDATE [core].[core].[VisualisationQueries]
SET FilterDefinitions = REPLACE(
        REPLACE(FilterDefinitions,
            N'"Organisations"',  N'"ParentOrganisations"'),
            N'"Locations"',      N'"ParentLocations"')
WHERE DataSetName LIKE N'Parent%'
  AND VisualizationType <> N'FilterList'
  AND Status = N'LIVE';

-- Fix 2: ParentOrganisations FilterList — return ORG_NAME as [ID] instead of ORG_CODE
UPDATE [core].[core].[VisualisationQueries]
SET QueryTemplate = N'SELECT ORG_NAME AS [Label], ORG_NAME AS [ID], NULL AS [ParentID], 1 AS [BottomLevel]
FROM [presentation].[PD_ORGANISATION]
WHERE IS_ACTIVE = 1

SELECT ''Organisations'' AS [Title]'
WHERE DataSetName = N'ParentOrganisations'
  AND VisualizationType = N'FilterList'
  AND Status = N'LIVE';
