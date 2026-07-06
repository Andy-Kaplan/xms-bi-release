/*
    Padel Social — Remove Three Rocks (TR) locations from presentation tables
    =========================================================================
    Target org: Padel Social (Growyze001)
    Problem:    TR test locations (Three Rocks, TR Enterprise, TR Sub 1, TR Sub 2)
                leaked into Padel Social's Growyze data and appear in dashboards.
    Scope:      Presentation layer only (facts + D_LOCATION dimension).
                DV layer left intact — will need separate cleanup if required.

    Affected tables (row counts at time of investigation):
      - F_INV_USAGE_DAY:        599 rows
      - F_INV_DAILY_DETAIL:     599 rows
      - F_PRE_INV_DAILY_DETAIL: 599 rows
      - D_LOCATION:               4 rows

    Run against the Padel Social client database.
    Facts must be deleted BEFORE the dimension rows.
*/

-- ============================================================================
-- 1. Identify TR location HUB_IDs
-- ============================================================================
DECLARE @TR_Locations TABLE (HUB_ID BINARY(32), LOCATION_NAME NVARCHAR(200));

INSERT INTO @TR_Locations (HUB_ID, LOCATION_NAME)
SELECT BOTTOM_HUB_ID, BOTTOM_LOCATION_NAME
FROM [presentation].[D_LOCATION]
WHERE BOTTOM_LOCATION_NAME IN (
    N'Three Rocks',
    N'TR Enterprise',
    N'TR Sub 1',
    N'TR Sub 2'
);

-- Sanity check — should return 4 rows
SELECT 'Locations to remove' AS [Step], COUNT(*) AS [Count] FROM @TR_Locations;

-- ============================================================================
-- 2. Delete from fact tables (join on LOCATION_HUB_ID)
-- ============================================================================

-- F_INV_USAGE_DAY
DELETE f
FROM [presentation].[F_INV_USAGE_DAY] f
INNER JOIN @TR_Locations t ON f.LOCATION_HUB_ID = t.HUB_ID;

SELECT 'F_INV_USAGE_DAY deleted' AS [Step], @@ROWCOUNT AS [Count];

-- F_INV_DAILY_DETAIL
DELETE f
FROM [presentation].[F_INV_DAILY_DETAIL] f
INNER JOIN @TR_Locations t ON f.LOCATION_HUB_ID = t.HUB_ID;

SELECT 'F_INV_DAILY_DETAIL deleted' AS [Step], @@ROWCOUNT AS [Count];

-- F_PRE_INV_DAILY_DETAIL
DELETE f
FROM [presentation].[F_PRE_INV_DAILY_DETAIL] f
INNER JOIN @TR_Locations t ON f.LOCATION_HUB_ID = t.HUB_ID;

SELECT 'F_PRE_INV_DAILY_DETAIL deleted' AS [Step], @@ROWCOUNT AS [Count];

-- Also clean any other fact tables that might have gained TR rows since investigation
DELETE f
FROM [presentation].[F_INV_COUNTS_DAY] f
INNER JOIN @TR_Locations t ON f.LOCATION_HUB_ID = t.HUB_ID;

SELECT 'F_INV_COUNTS_DAY deleted' AS [Step], @@ROWCOUNT AS [Count];

DELETE f
FROM [presentation].[F_INV_SALES_DAY] f
INNER JOIN @TR_Locations t ON f.LOCATION_HUB_ID = t.HUB_ID;

SELECT 'F_INV_SALES_DAY deleted' AS [Step], @@ROWCOUNT AS [Count];

-- ============================================================================
-- 3. Delete from D_LOCATION dimension
-- ============================================================================
DELETE d
FROM [presentation].[D_LOCATION] d
INNER JOIN @TR_Locations t ON d.BOTTOM_HUB_ID = t.HUB_ID;

SELECT 'D_LOCATION deleted' AS [Step], @@ROWCOUNT AS [Count];

-- ============================================================================
-- 4. Verify — should return only Padel Social locations
-- ============================================================================
SELECT BOTTOM_LOCATION_NAME, BOTTOM_LOCATION_ID
FROM [presentation].[D_LOCATION]
ORDER BY BOTTOM_LOCATION_NAME;
