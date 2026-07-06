/*
    Fix: Locations FilterList — exclude locations with no transaction data
    ======================================================================
    Bug:     The Locations FilterList queries SAT_LOCATION directly with only
             CURRENT_FLAG = 1 as a filter. This includes any location loaded
             into the data vault — even test/parent-org locations that have
             no associated fact data. Users see dead locations in the dropdown
             that return empty results when selected.

    Example: Padel Social shows 7 locations but only 3 (Earls Court, O2,
             Padel Social Club) have transaction data. The other 4 (Three Rocks,
             TR Enterprise, TR Sub 1, TR Sub 2) are parent-org test locations
             that leaked into the DV.

    Fix:     Add EXISTS checks against all 5 presentation fact tables so only
             locations with actual transaction data appear:
               - Bottom-level locations (stores): must have rows in at least
                 one fact table
               - Parent-level locations (regions): must have at least one
                 bottom-level child with fact data

    Run against: core database
    Idempotent:  Yes — MERGE updates if record exists
    Affects:     All organisations (filter becomes universally stricter)
*/

MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'Locations',
    N'FilterList',
    1,
    N'LIVE'
)) AS src (DataSetName, VisualizationType, [Version], [Status])
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.[Version]         = src.[Version]
AND tgt.[Status]          = src.[Status]
WHEN MATCHED THEN
UPDATE SET
    QueryTemplate = N'SELECT DISTINCT
    COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) AS [LOCATION_NAME]
    ,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) ELSE [LOCATION_ID] END AS [LOCATION_ID]
    ,[PARENT_ID]
    ,[BOTTOM_LEVEL]
FROM [datavault].[SAT_LOCATION] sl
WHERE [CURRENT_FLAG] = 1
AND (
    ([BOTTOM_LEVEL] = 1 AND (
        EXISTS (SELECT 1 FROM [presentation].[F_INV_USAGE_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_LINEITEM_15MIN] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_INV_COUNTS_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_INV_SALES_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
    ))
    OR ([BOTTOM_LEVEL] = 0 AND EXISTS (
        SELECT 1 FROM [datavault].[SAT_LOCATION] child
        WHERE child.[CURRENT_FLAG] = 1 AND child.[BOTTOM_LEVEL] = 1
        AND child.[PARENT_ID] = sl.[LOCATION_ID]
        AND (
            EXISTS (SELECT 1 FROM [presentation].[F_INV_USAGE_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_LINEITEM_15MIN] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_INV_COUNTS_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_INV_SALES_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
        )
    ))
)',
    ExecutionQuery = N'SELECT
    [LOCATION_NAME] AS [Label]
    , [LOCATION_ID] AS [ID]
    , [PARENT_ID] AS [ParentID]
    , [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
    COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) AS [LOCATION_NAME]
    ,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) ELSE [LOCATION_ID] END AS [LOCATION_ID]
    ,[PARENT_ID]
    ,[BOTTOM_LEVEL]
FROM [datavault].[SAT_LOCATION] sl
WHERE [CURRENT_FLAG] = 1
AND (
    ([BOTTOM_LEVEL] = 1 AND (
        EXISTS (SELECT 1 FROM [presentation].[F_INV_USAGE_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_LINEITEM_15MIN] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_INV_COUNTS_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
        OR EXISTS (SELECT 1 FROM [presentation].[F_INV_SALES_DAY] f WHERE f.LOCATION_HUB_ID = sl.HUB_ID)
    ))
    OR ([BOTTOM_LEVEL] = 0 AND EXISTS (
        SELECT 1 FROM [datavault].[SAT_LOCATION] child
        WHERE child.[CURRENT_FLAG] = 1 AND child.[BOTTOM_LEVEL] = 1
        AND child.[PARENT_ID] = sl.[LOCATION_ID]
        AND (
            EXISTS (SELECT 1 FROM [presentation].[F_INV_USAGE_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_LINEITEM_15MIN] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_INV_COUNTS_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
            OR EXISTS (SELECT 1 FROM [presentation].[F_INV_SALES_DAY] f2 WHERE f2.LOCATION_HUB_ID = child.HUB_ID)
        )
    ))
)
) INPUTQUERY

SELECT
    ''Locations'' AS [Title]',
    ModifiedDate = GETDATE();
