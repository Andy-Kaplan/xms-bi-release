-- ============================================
-- Presentation Control Entries Export
-- Generated: 2026-01-19 19:51:49
-- Total Records: 22
-- ============================================

-- Note: These INSERT statements will create presentation control entries
-- You may need to use NEWID() or generate new GUIDs for the id column
-- to avoid primary key conflicts in the target environment.

-- To execute in target environment:
-- 1. Ensure the target database has the [core].[PresentationControl] table
-- 2. Review and adjust the id values if needed (currently using original IDs)
-- 3. Run this script in the target database

-- ============================================
-- Step: Channel Dimension
-- Table: D_CHANNEL (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'FE981AF0-CECA-4607-87F5-F934A26292E8',
    N'Channel Dimension',
    N'D_CHANNEL',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        CHANNEL_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        CHANNEL_ID, 

        /*  Columns set to null pending their inclusion into the tables  */
        /*  NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME, */
        MICROSERVICE_ID AS MICROSERVICE_ID, MICROSERVICE_NAME AS MICROSERVICE_NAME,  

        CHANNEL_ID as ROOT_CHANNEL_ID,

        0 as LEVEL_DEPTH,

        CAST(CHANNEL_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_CHANNEL]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.CHANNEL_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.CHANNEL_ID, 

        /*  Columns set to null pending their inclusion into the tables  */
        /* NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME,  */
        d.MICROSERVICE_ID AS MICROSERVICE_ID, d.MICROSERVICE_NAME AS MICROSERVICE_NAME,  
        h.ROOT_CHANNEL_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.CHANNEL_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_CHANNEL] d

    INNER JOIN HierarchyPath h ON d.CHANNEL_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_CHANNEL_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_CHANNEL_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CHANNEL_NAME END) as BOTTOM_CHANNEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CHANNEL_ID END) as BOTTOM_CHANNEL_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN CHANNEL_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN CHANNEL_NAME END) ,''All CHANNELs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All CHANNELs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN CHANNEL_NAME END),''All CHANNELs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All CHANNELs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_CHANNEL_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_CHANNEL_NAME", "table_column": "BOTTOM_CHANNEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_CHANNEL_ID", "table_column": "BOTTOM_CHANNEL_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Channel Dimension',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: CoOccurrence data prep
-- Table: E_COOCCUR_BASE (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'B450C018-DC78-49E7-83E7-02AEDAA1FFD5',
    N'CoOccurrence data prep',
    N'E_COOCCUR_BASE',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = DATEADD(DAY,-180, MAX([ORDER_DATE]))
FROM [datavault].[SAT_LINEITEM];

SELECT @EndDate = MAX([ORDER_DATE])
FROM [datavault].[SAT_LINEITEM];

WITH TOP100 AS
(
    SELECT TOP(100)
        SUM(CONVERT(NUMERIC, QUANTITY)) AS Product_Count
        ,P.HUB_ID AS PRODUCT_HUB_ID
    FROM
    [datavault].[SAT_LINEITEM] LI

    INNER JOIN
        [datavault].[LNK_LINEITEM_PRODUCT] LP
    ON LI.[HUB_ID] = LP.[LINEITEM_HUB_ID]

    INNER JOIN
        [datavault].[SAT_PRODUCT] P
    ON LP.PRODUCT_HUB_ID = P.HUB_ID

    WHERE 
    LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate
    AND 
    LI.[LINEITEM_TYPE] = ''PROD''

    GROUP BY 
        P.HUB_ID
    
    ORDER BY 
        1 DESC
)

SELECT DISTINCT
    LI.HEADER_ID
    ,OCC.OCCASION_HUB_ID
    ,LNKLO.LOCATION_HUB_ID
    ,LNKREV.REVCENTER_HUB_ID
    ,LNKCH.CHANNEL_HUB_ID
    ,T.PRODUCT_HUB_ID

FROM
[datavault].[SAT_LINEITEM] LI

INNER JOIN
    [datavault].[LNK_LINEITEM_PRODUCT] LP
ON LI.[HUB_ID] = LP.[LINEITEM_HUB_ID]

INNER JOIN
    [datavault].[SAT_PRODUCT] P
ON LP.PRODUCT_HUB_ID = P.HUB_ID

INNER JOIN
    TOP100 T
ON P.HUB_ID = T.PRODUCT_HUB_ID

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_OCCASION] OCC
ON
LI.[HUB_ID] = OCC.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LINEITEM] LNKCO
ON LI.[HUB_ID] = LNKCO.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[SAT_CUSTORDER] CO
ON LNKCO.[CUSTORDER_HUB_ID] = CO.[HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LOCATION] LNKLO
ON CO.[HUB_ID] = LNKLO.[CUSTORDER_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_REVCENTER] LNKREV
ON CO.[HUB_ID] = LNKREV.[CUSTORDER_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CHANNEL_CUSTORDER] LNKCH
ON CO.[HUB_ID] = LNKCH.[CUSTORDER_HUB_ID]

WHERE LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate',
    1,
    N'Dimension',
    N'[{"query_column": "HEADER_ID", "table_column": "HEADER_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}]',
    0,
    100,
    3,
    30,
    NULL,
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    NULL,
    NULL
);


-- ============================================
-- Step: Deal Dimension
-- Table: D_DEAL (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'7DF1C48F-702F-48A8-8082-F52E51808937',
    N'Deal Dimension',
    N'D_DEAL',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        DEAL_NAME, PARENT_ID,

         LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        DEAL_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        DEAL_ID as ROOT_DEAL_ID,

        0 as LEVEL_DEPTH,

        CAST(DEAL_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_DEAL]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.DEAL_NAME, d.PARENT_ID, 
         d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.DEAL_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_DEAL_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.DEAL_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_DEAL] d

    INNER JOIN HierarchyPath h ON d.DEAL_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_DEAL_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_DEAL_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN DEAL_NAME END) as BOTTOM_DEAL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN DEAL_ID END) as BOTTOM_DEAL_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN DEAL_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN DEAL_NAME END) ,''All Deals'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All Deals'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN DEAL_NAME END),''All Deals'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All Deals'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_DEAL_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DEAL_NAME", "table_column": "BOTTOM_DEAL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DEAL_ID", "table_column": "BOTTOM_DEAL_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Deal Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Discount Dimension
-- Table: D_DISCOUNT (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'80F22A38-E512-498B-8440-51A55BF7F6CF',
    N'Discount Dimension',
    N'D_DISCOUNT',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        DISCOUNT_NAME, PARENT_ID, VALUE_TYPE, [VALUE],
         LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        DISCOUNT_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        DISCOUNT_ID as ROOT_DISCOUNT_ID,

        0 as LEVEL_DEPTH,

        CAST(DISCOUNT_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_DISCOUNT]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.DISCOUNT_NAME, d.PARENT_ID, d.VALUE_TYPE, d.[VALUE],
         d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.DISCOUNT_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_DISCOUNT_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.DISCOUNT_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_DISCOUNT] d

    INNER JOIN HierarchyPath h ON d.DISCOUNT_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_DISCOUNT_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_DISCOUNT_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN DISCOUNT_NAME END) as BOTTOM_DISCOUNT_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN DISCOUNT_ID END) as BOTTOM_DISCOUNT_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN VALUE_TYPE END) as BOTTOM_VALUE_TYPE,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN [VALUE] END) as BOTTOM_VALUE,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN DISCOUNT_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN DISCOUNT_NAME END) ,''All Discounts'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All Discounts'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN DISCOUNT_NAME END),''All Discounts'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All Discounts'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_DISCOUNT_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_DISCOUNT_NAME,
    NULL AS BOTTOM_DISCOUNT_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_VALUE_TYPE,
    NULL AS BOTTOM_VALUE,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DISCOUNT_NAME", "table_column": "BOTTOM_DISCOUNT_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DISCOUNT_ID", "table_column": "BOTTOM_DISCOUNT_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_VALUE_TYPE", "table_column": "BOTTOM_VALUE_TYPE", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_VALUE", "table_column": "BOTTOM_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Discount Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Distributor Dimension
-- Table: D_DISTRIBUTOR (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'6EE44AE0-E6F8-476C-834A-5C46A2E1DE11',
    N'Distributor Dimension',
    N'D_DISTRIBUTOR',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        DISTRIBUTOR_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        DISTRIBUTOR_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        DISTRIBUTOR_ID as ROOT_DISTRIBUTOR_ID,

        0 as LEVEL_DEPTH,

        CAST(DISTRIBUTOR_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_DISTRIBUTOR]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.DISTRIBUTOR_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.DISTRIBUTOR_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_DISTRIBUTOR_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.DISTRIBUTOR_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_DISTRIBUTOR] d

    INNER JOIN HierarchyPath h ON d.DISTRIBUTOR_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_DISTRIBUTOR_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_DISTRIBUTOR_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN DISTRIBUTOR_NAME END) as BOTTOM_DISTRIBUTOR_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN DISTRIBUTOR_ID END) as BOTTOM_DISTRIBUTOR_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN DISTRIBUTOR_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN DISTRIBUTOR_NAME END) ,''All DISTRIBUTORs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All DISTRIBUTORs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN DISTRIBUTOR_NAME END),''All DISTRIBUTORs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All DISTRIBUTORs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_DISTRIBUTOR_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DISTRIBUTOR_NAME", "table_column": "BOTTOM_DISTRIBUTOR_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DISTRIBUTOR_ID", "table_column": "BOTTOM_DISTRIBUTOR_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Distributor Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: F_LINEITEM_15MIN
-- Table: F_LINEITEM_15MIN (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'131C3A84-F72D-4A12-B958-BFB519973BE0',
    N'F_LINEITEM_15MIN',
    N'F_LINEITEM_15MIN',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''LINEITEM_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''LINEITEM_END'';

SELECT
    LI.[SRC]
    ,LI.[LINEITEM_TYPE] AS LI_TYPE
    ,ISNULL(DEAL.[DEAL_HUB_ID],CONVERT(BINARY(32), -999)) AS [DEAL_HUB_ID]
    ,ISNULL(DISC.[DISCOUNT_HUB_ID],CONVERT(BINARY(32), -999)) AS [DISCOUNT_HUB_ID]
    ,ISNULL(EMP.[EMPLOYEE_HUB_ID],CONVERT(BINARY(32), -999)) AS [EMPLOYEE_HUB_ID]
    ,ISNULL(MODS.[MOD_HUB_ID],CONVERT(BINARY(32), -999)) AS [MOD_HUB_ID]
    ,ISNULL(OCC.[OCCASION_HUB_ID],CONVERT(BINARY(32), -999)) AS [OCCASION_HUB_ID]
    ,ISNULL(PROD.[PRODUCT_HUB_ID],CONVERT(BINARY(32), -999)) AS [PRODUCT_HUB_ID]
    ,ISNULL(SVC.[SVCCHARGE_HUB_ID],CONVERT(BINARY(32), -999)) AS [SVCCHARGE_HUB_ID]
    ,ISNULL(TAX.[TAX_HUB_ID],CONVERT(BINARY(32), -999)) AS [TAX_HUB_ID]
    ,ISNULL(LNKLO.[LOCATION_HUB_ID],CONVERT(BINARY(32), -999)) AS [LOCATION_HUB_ID]
    ,ISNULL(LNKREV.[REVCENTER_HUB_ID],CONVERT(BINARY(32), -999)) AS [REVCENTER_HUB_ID]
    ,ISNULL(LNKCH.[CHANNEL_HUB_ID],CONVERT(BINARY(32), -999)) AS [CHANNEL_HUB_ID]
    ,SUM(ISNULL(LI.[GROSS_VALUE],0)) AS [GROSS_VALUE]
    ,SUM(ISNULL(LI.[TAX_VALUE],0)) AS [TAX_VALUE]
    ,SUM(ISNULL(LI.[NET_VALUE],0)) AS [NET_VALUE]
    ,SUM(ISNULL(LI.[QUANTITY],0)) AS [QUANTITY]
    ,SUM(ISNULL(LI.[QUANTITY_INV],0)) AS [QUANTITY_INV]
    ,COUNT(DISTINCT LI.[HEADER_ID]) AS ORDER_COUNT
    ,DATEADD(MINUTE, 
    (DATEDIFF(MINUTE, 0, LI.[LINEITEM_TIMESTAMP]) / 15) * 15, 
    0) AS [LINEITEM_TIMESTAMP]
    ,LI.[ORDER_DATE]

FROM
    [datavault].[SAT_LINEITEM] LI

INNER JOIN
    [core].[core].[Integrations] IG
ON LI.[SRC] = IG.[SchemaName]
AND IG.[IntegrationType] = ''POS''

LEFT OUTER JOIN
    [datavault].[LNK_DEAL_LINEITEM] DEAL
ON
LI.[HUB_ID] = DEAL.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_DISCOUNT_LINEITEM] DISC
ON
LI.[HUB_ID] = DISC.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_EMPLOYEE_LINEITEM] EMP
ON
LI.[HUB_ID] = EMP.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_MOD] MODS
ON
LI.[HUB_ID] = MODS.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_OCCASION] OCC
ON
LI.[HUB_ID] = OCC.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_PRODUCT] PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_SVCCHARGE] SVC
ON
LI.[HUB_ID] = SVC.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_TAX] TAX
ON
LI.[HUB_ID] = TAX.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LINEITEM] LNKCO
ON LI.[HUB_ID] = LNKCO.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[SAT_CUSTORDER] CO
ON LNKCO.[CUSTORDER_HUB_ID] = CO.[HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LOCATION] LNKLO
ON CO.[HUB_ID] = LNKLO.[CUSTORDER_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_REVCENTER] LNKREV
ON CO.[HUB_ID] = LNKREV.[CUSTORDER_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CHANNEL_CUSTORDER] LNKCH
ON CO.[HUB_ID] = LNKCH.[CUSTORDER_HUB_ID]

WHERE LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate
AND LI.[CURRENT_FLAG] = 1
AND LI.[IS_DELETED] = 0
AND ISNULL([VOID_FLAG],0) = 0

GROUP BY
    LI.[SRC]
    ,LI.[LINEITEM_TYPE]
    ,ISNULL(DEAL.[DEAL_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(DISC.[DISCOUNT_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(EMP.[EMPLOYEE_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(MODS.[MOD_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(OCC.[OCCASION_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(PROD.[PRODUCT_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(SVC.[SVCCHARGE_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(TAX.[TAX_HUB_ID],CONVERT(BINARY(32), -999))
    --,TEND.[TENDER_HUB_ID]
    ,DATEADD(MINUTE, 
    (DATEDIFF(MINUTE, 0, [LINEITEM_TIMESTAMP]) / 15) * 15, 
    0)
    ,LI.[ORDER_DATE]
    ,ISNULL(LNKLO.[LOCATION_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(LNKREV.[REVCENTER_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(LNKCH.[CHANNEL_HUB_ID],CONVERT(BINARY(32), -999))',
    1,
    N'Fact',
    N'[{"query_column": "SRC", "table_column": "SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "LI_TYPE", "table_column": "LI_TYPE", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "DEAL_HUB_ID", "table_column": "DEAL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DISCOUNT_HUB_ID", "table_column": "DISCOUNT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "EMPLOYEE_HUB_ID", "table_column": "EMPLOYEE_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "MOD_HUB_ID", "table_column": "MOD_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "SVCCHARGE_HUB_ID", "table_column": "SVCCHARGE_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "TAX_HUB_ID", "table_column": "TAX_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "GROSS_VALUE", "table_column": "GROSS_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TAX_VALUE", "table_column": "TAX_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "NET_VALUE", "table_column": "NET_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY", "table_column": "QUANTITY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY_INV", "table_column": "QUANTITY_INV", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_COUNT", "table_column": "ORDER_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "LINEITEM_TIMESTAMP", "table_column": "LINEITEM_TIMESTAMP", "data_type": "varchar(255)", "target_data_type": "[datetime]"}, {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}]',
    0,
    100,
    3,
    30,
    N'Line item details aggregated to 15 minute segments',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'LINEITEM',
    N'ORDER_DATE'
);


-- ============================================
-- Step: Forecast Actuals Base
-- Table: FORECAST_ACTUALS_BASE (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'9DA63DF9-281C-4AC2-A63D-8B200B5710FA',
    N'Forecast Actuals Base',
    N'FORECAST_ACTUALS_BASE',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''LINEITEM_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''LINEITEM_END'';

WITH DailySales AS
(
SELECT 
    LNKLO.[LOCATION_HUB_ID] AS location_hub_id
    ,product.[MIDDLE_1_NAME] AS product_category
    ,LI.[ORDER_DATE] AS sale_date
    ,SUM(LI.QUANTITY) AS quantity
    ,SUM(LI.NET_VALUE) AS revenue
    ,COUNT(DISTINCT LI.HEADER_ID) AS transaction_count

FROM
    [datavault].[SAT_LINEITEM] LI

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_PRODUCT] PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    presentation.[D_PRODUCT] product
ON
PROD.[PRODUCT_HUB_ID] = product.[BOTTOM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LINEITEM] LNKCO
ON LI.[HUB_ID] = LNKCO.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[SAT_CUSTORDER] CO
ON LNKCO.[CUSTORDER_HUB_ID] = CO.[HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LOCATION] LNKLO
ON CO.[HUB_ID] = LNKLO.[CUSTORDER_HUB_ID]



WHERE LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate
AND LI.[CURRENT_FLAG] = 1
AND LI.[IS_DELETED] = 0
AND ISNULL([VOID_FLAG],0) = 0
AND LI.LINEITEM_TYPE = ''PROD''
AND LNKLO.[LOCATION_HUB_ID] IS NOT NULL
AND product.[MIDDLE_1_NAME] IS NOT NULL

GROUP BY 
    LNKLO.[LOCATION_HUB_ID],
    product.[MIDDLE_1_NAME],
    LI.[ORDER_DATE]
),

LocationCategories AS (
    SELECT DISTINCT 
        location_hub_id,
        product_category
    FROM DailySales
),

Calendar AS
(
SELECT
    *
FROM
    presentation.[CALENDAR]
WHERE [DATE] BETWEEN @StartDate AND @EndDate
),

CompleteData AS
(
SELECT 
    lc.location_hub_id,
    lc.product_category,
    c.[Date] as sale_date,
    c.[Year],
    c.[Month],
    c.[DayOfMonth] AS day,
    c.[DayOfWeek] AS day_of_week,
    c.[DayName] AS day_name,
    c.[Week] AS week_of_year,
    c.[IsWeekend] AS is_weekend,
    c.[IsHoliday_GB] AS is_holiday,
    -- Fill missing dates with 0 (no sales that day)
    ISNULL(ds.quantity, 0) as quantity,
    ISNULL(ds.transaction_count, 0) as transaction_count,
    ISNULL(ds.revenue, 0.0) as revenue
--INTO #CompleteData
FROM LocationCategories lc
CROSS JOIN Calendar c
LEFT JOIN DailySales ds 
    ON lc.location_hub_id = ds.location_hub_id
    AND lc.product_category = ds.product_category
    AND c.[Date] = ds.sale_date
),

FeaturesData AS
(
SELECT 
    *,
    -- QUANTITY FEATURES --
    -- Rolling averages
    AVG(quantity * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as qty_ma_7day,
    AVG(quantity * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
    ) as qty_ma_14day,
    AVG(quantity * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 27 PRECEDING AND CURRENT ROW
    ) as qty_ma_28day,
    
    -- Lag features (previous periods)
    LAG(quantity, 1) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date
    ) as qty_lag_1day,
    LAG(quantity, 7) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date
    ) as qty_lag_7day,
    LAG(quantity, 28) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date
    ) as qty_lag_28day,
    
    -- Same day last week (by day of week)
    LAG(quantity, 7) OVER (
        PARTITION BY location_hub_id, product_category, day_of_week 
        ORDER BY sale_date
    ) as qty_same_dow_last_week,
    
    -- Rolling standard deviation (volatility)
    STDEV(quantity * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 27 PRECEDING AND CURRENT ROW
    ) as qty_std_28day,
    
    -- REVENUE FEATURES --
    AVG(revenue * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as revenue_ma_7day,
    AVG(revenue * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 27 PRECEDING AND CURRENT ROW
    ) as revenue_ma_28day,
    LAG(revenue, 1) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date
    ) as revenue_lag_1day,
    LAG(revenue, 7) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date
    ) as revenue_lag_7day,
    
    -- TRANSACTION FEATURES --
    AVG(transaction_count * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as txn_ma_7day,
    AVG(transaction_count * 1.0) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date 
        ROWS BETWEEN 27 PRECEDING AND CURRENT ROW
    ) as txn_ma_28day,
    LAG(transaction_count, 1) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date
    ) as txn_lag_1day,
    LAG(transaction_count, 7) OVER (
        PARTITION BY location_hub_id, product_category 
        ORDER BY sale_date
    ) as txn_lag_7day
FROM CompleteData
),

EnrichedData AS
(
SELECT 
    fd.*,
    -- Derived metrics (useful for validation and as features)
    CASE 
        WHEN transaction_count > 0 THEN revenue / transaction_count 
        ELSE 0 
    END as avg_ticket_size,
    CASE 
        WHEN transaction_count > 0 THEN quantity * 1.0 / transaction_count 
        ELSE 0 
    END as items_per_transaction,
    CASE 
        WHEN quantity > 0 THEN revenue / quantity 
        ELSE 0 
    END as revenue_per_item
FROM FeaturesData fd
)

SELECT 
    ed.location_hub_id,
    ed.product_category,
    ed.sale_date,
    ed.year,
    ed.month,
    ed.day,
    ed.day_of_week,
    ed.day_name,
    ed.week_of_year,
    ed.is_weekend,
    
    -- TARGET VARIABLES (Three metrics to forecast)
    ed.quantity as target_quantity,
    ed.revenue as target_revenue,
    ed.transaction_count as target_transactions,
    
    -- Derived metrics (for validation)
    ed.avg_ticket_size,
    ed.items_per_transaction,
    ed.revenue_per_item,
    
    -- QUANTITY FEATURES
    ed.qty_ma_7day,
    ed.qty_ma_14day,
    ed.qty_ma_28day,
    ed.qty_lag_1day,
    ed.qty_lag_7day,
    ed.qty_lag_28day,
    ed.qty_same_dow_last_week,
    ed.qty_std_28day,
    
    -- REVENUE FEATURES
    ed.revenue_ma_7day,
    ed.revenue_ma_28day,
    ed.revenue_lag_1day,
    ed.revenue_lag_7day,
    
    -- TRANSACTION FEATURES
    ed.txn_ma_7day,
    ed.txn_ma_28day,
    ed.txn_lag_1day,
    ed.txn_lag_7day,
    
    -- HOLIDAY FEATURES
    ed.is_holiday,
    NULL AS holiday_name,
    CASE 
        WHEN DATEADD(DAY, 1, ed.sale_date) IN (SELECT [Date] FROM Calendar WHERE IsHoliday_GB = 1) THEN 1 
        ELSE 0 
    END as is_day_before_holiday,
    CASE 
        WHEN DATEADD(DAY, -1, ed.sale_date) IN (SELECT [Date] FROM Calendar WHERE IsHoliday_GB = 1) THEN 1 
        ELSE 0 
    END as is_day_after_holiday,
    
    -- WEATHER PLACEHOLDERS (for future use - will be NULL for now)
    CAST(NULL AS DECIMAL(5,2)) as temperature_avg,
    CAST(NULL AS DECIMAL(5,2)) as temperature_high,
    CAST(NULL AS DECIMAL(5,2)) as temperature_low,
    CAST(NULL AS DECIMAL(5,2)) as precipitation_cm,
    CAST(NULL AS INT) as precipitation_probability,
    CAST(NULL AS NVARCHAR(50)) as weather_condition,
    CAST(NULL AS BIT) as is_severe_weather
    
FROM EnrichedData ed',
    1,
    N'Fact',
    N'[{"query_column": "location_hub_id", "table_column": "location_hub_id", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "product_category", "table_column": "product_category", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "sale_date", "table_column": "sale_date", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "year", "table_column": "year", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "month", "table_column": "month", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day", "table_column": "day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day_of_week", "table_column": "day_of_week", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day_name", "table_column": "day_name", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "week_of_year", "table_column": "week_of_year", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_weekend", "table_column": "is_weekend", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "target_quantity", "table_column": "target_quantity", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "target_revenue", "table_column": "target_revenue", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "target_transactions", "table_column": "target_transactions", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "avg_ticket_size", "table_column": "avg_ticket_size", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "items_per_transaction", "table_column": "items_per_transaction", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_per_item", "table_column": "revenue_per_item", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_ma_7day", "table_column": "qty_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_ma_14day", "table_column": "qty_ma_14day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_ma_28day", "table_column": "qty_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_lag_1day", "table_column": "qty_lag_1day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_lag_7day", "table_column": "qty_lag_7day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_lag_28day", "table_column": "qty_lag_28day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_same_dow_last_week", "table_column": "qty_same_dow_last_week", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_std_28day", "table_column": "qty_std_28day", "data_type": "varchar(255)", "target_data_type": "[float]"}, {"query_column": "revenue_ma_7day", "table_column": "revenue_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_ma_28day", "table_column": "revenue_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_lag_1day", "table_column": "revenue_lag_1day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "revenue_lag_7day", "table_column": "revenue_lag_7day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "txn_ma_7day", "table_column": "txn_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "txn_ma_28day", "table_column": "txn_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "txn_lag_1day", "table_column": "txn_lag_1day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "txn_lag_7day", "table_column": "txn_lag_7day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_holiday", "table_column": "is_holiday", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "holiday_name", "table_column": "holiday_name", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_day_before_holiday", "table_column": "is_day_before_holiday", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_day_after_holiday", "table_column": "is_day_after_holiday", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "temperature_avg", "table_column": "temperature_avg", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "temperature_high", "table_column": "temperature_high", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "temperature_low", "table_column": "temperature_low", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "precipitation_cm", "table_column": "precipitation_cm", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "precipitation_probability", "table_column": "precipitation_probability", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "weather_condition", "table_column": "weather_condition", "data_type": "varchar(255)", "target_data_type": "[nvarchar](50)"}, {"query_column": "is_severe_weather", "table_column": "is_severe_weather", "data_type": "varchar(255)", "target_data_type": "[bit]"}]',
    0,
    100,
    3,
    30,
    N'None',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'LINEITEM',
    N'sale_date'
);


-- ============================================
-- Step: Inv Item Dimension
-- Table: D_INVITEM (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'CD036D1A-B38B-4A65-A725-74D6E6405DD1',
    N'Inv Item Dimension',
    N'D_INVITEM',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        INVITEM_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        INVITEM_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        INVITEM_ID as ROOT_INVITEM_ID,

        0 as LEVEL_DEPTH,

        CAST(INVITEM_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_INVITEM]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.INVITEM_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.INVITEM_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_INVITEM_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.INVITEM_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_INVITEM] d

    INNER JOIN HierarchyPath h ON d.INVITEM_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_INVITEM_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_INVITEM_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN INVITEM_NAME END) as BOTTOM_INVITEM_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN INVITEM_ID END) as BOTTOM_INVITEM_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN INVITEM_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN INVITEM_NAME END) ,''All INVITEMs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All INVITEMs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN INVITEM_NAME END),''All INVITEMs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All INVITEMs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_INVITEM_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_INVITEM_NAME", "table_column": "BOTTOM_INVITEM_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_INVITEM_ID", "table_column": "BOTTOM_INVITEM_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Inventory Item Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Inventory Counts by Day
-- Table: F_INV_COUNTS_DAY (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'D46543DD-5CF4-460F-B957-B44037EB84E2',
    N'Inventory Counts by Day',
    N'F_INV_COUNTS_DAY',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
DECLARE @InvItemAvgDays INT;

SET @InvItemAvgDays = 30;

SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''STOCKEVENT_END'';


WITH UOMConversion AS (
    SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor
    UNION ALL SELECT ''Kg'', ''gr'', 1000
    UNION ALL SELECT ''lb'', ''gr'', 453.59237
    UNION ALL SELECT ''oz'', ''gr'', 28.349523
    UNION ALL SELECT ''ml'', ''ml'', 1
    UNION ALL SELECT ''cl'', ''ml'', 10
    UNION ALL SELECT ''L'', ''ml'', 1000
    UNION ALL SELECT ''Imperial Pint'', ''ml'', 568.26125
    UNION ALL SELECT ''Gal'', ''ml'', 4546.09
    UNION ALL SELECT ''EA'', ''EA'', 1
),
StockEvents AS (
    SELECT
        SE.[HUB_ID]
        ,SE.[SRC]
        ,SE.[LOAD_TS]
        ,SE.[EFFECTIVEFROM]
        ,SE.[EFFECTIVETO]
        ,SE.[CURRENT_FLAG]
        ,SE.[IS_DELETED]
        ,SE.[EVENT_TYPE]
        ,CAST(SE.[EVENT_TS] AS DATE) AS [EVENT_TS]
        ,SE.[PACK_DESC]
        ,SE.[PACK_QUANTITY]
        ,SE.[UOM]
        ,SE.[UOM_QUANITY]
        ,SE.[UOM_QUANITY] * uc.conversion_factor AS [STANDARDISED_QTY]
        ,uc.base_uom AS [STANDARDISED_UOM]
        ,SE.[EXTERNAL_REF]
        ,SE.[INTERNAL_REF]
        ,SE.[EVENT_BEHAVIOUR]
        ,LSE.[LOCATION_HUB_ID]
        ,LII.[INVITEM_HUB_ID]
    FROM
        [datavault].[SAT_STOCKEVENT] SE
    INNER JOIN
        [datavault].[LNK_LOCATION_STOCKEVENT] LSE
        ON SE.[HUB_ID] = LSE.[STOCKEVENT_HUB_ID]
    INNER JOIN
        [datavault].[LNK_INVITEM_STOCKEVENT] LII
        ON SE.[HUB_ID] = LII.[STOCKEVENT_HUB_ID]
    LEFT OUTER JOIN
        UOMConversion uc
        ON SE.[UOM] = uc.[UOM]
    WHERE 1=1
    AND SE.[EVENT_TS] BETWEEN @StartDate AND @EndDate
),  

EventsWithCountGroup AS (
    SELECT 
        *,
        SUM(CASE WHEN EVENT_BEHAVIOUR = ''COUNT'' THEN 1 ELSE 0 END) 
            OVER (
                PARTITION BY INTERNAL_REF, LOCATION_HUB_ID 
                ORDER BY EVENT_TS DESC 
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS count_group
    FROM StockEvents
),

MovementsByGroup AS (
    SELECT 
        LOCATION_HUB_ID,
        INVITEM_HUB_ID,
        [STANDARDISED_UOM],
        count_group,
        SUM(CASE WHEN EVENT_TYPE = ''WASTE''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS WASTE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''TRANSFER''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS TRANSFER_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''SALE''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS SALE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''PRODUCTION''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS PRODUCTION_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''ORDER''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS ORDER_QTY, 
        SUM(
            CASE 
                WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                ELSE [STANDARDISED_QTY] 
            END
        ) AS MOVEMENT_QTY
    FROM EventsWithCountGroup
    WHERE EVENT_BEHAVIOUR IN (''+'', ''-'')
    GROUP BY INVITEM_HUB_ID, LOCATION_HUB_ID, count_group, [STANDARDISED_UOM]
),
CountsWithPrevious AS (
    SELECT 
        *,
        LAG(STANDARDISED_QTY) OVER (
            PARTITION BY INTERNAL_REF, LOCATION_HUB_ID 
            ORDER BY EVENT_TS
        ) AS prev_count_qty,
        LAG(EVENT_TS) OVER (
            PARTITION BY INTERNAL_REF, LOCATION_HUB_ID 
            ORDER BY EVENT_TS
        ) AS last_count
    FROM EventsWithCountGroup
    WHERE EVENT_BEHAVIOUR = ''COUNT''
),

InvLocCost AS
	(
    SELECT DISTINCT
		LIL.[LOCATION_HUB_ID]
		,LII.[INVITEM_HUB_ID]
		,AVG(IR.[UOM_COST] / UC.[conversion_factor]) OVER(PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]) AS UOM_COST
		,AVG(IR.[UOM_COST] / UC.[conversion_factor]) OVER(PARTITION BY LII.[INVITEM_HUB_ID]) AS UOM_COST_INV
	FROM
		[datavault].[SAT_INVREPORT] IR

	INNER JOIN
		[datavault].[LNK_INVREPORT_LOCATION] LIL
	ON IR.[HUB_ID] = LIL.[INVREPORT_HUB_ID]

	INNER JOIN
		[datavault].[LNK_INVITEM_INVREPORT] LII
	ON IR.[HUB_ID] = LII.[INVREPORT_HUB_ID]

    LEFT JOIN
        UOMConversion uc
    ON IR.[REPORTING_UOM] = uc.[UOM]

	WHERE 1=1
	AND IR.[REPORTING_DATE] BETWEEN DATEADD(DAY,-@InvItemAvgDays,@EndDate) AND @EndDate
),

InvCost AS
	(
	SELECT DISTINCT
		INV.[INVITEM_HUB_ID]
		,INV.[UOM_COST_INV] AS UOM_COST
	FROM
		InvLocCost INV
)


SELECT 
    c.[LOCATION_HUB_ID]
    ,c.[INVITEM_HUB_ID]
    ,c.[EVENT_TS] AS COUNT_DATE
    ,c.[STANDARDISED_UOM]
    ,c.prev_count_qty AS [PREVIOUS_COUNT]
    ,c.[STANDARDISED_QTY] AS [ACTUAL_COUNT]
    ,c.prev_count_qty + ISNULL(m.MOVEMENT_QTY, 0) AS [THEO_QTY]
    ,ISNULL(m.MOVEMENT_QTY, 0) AS [THEO_USAGE]
    ,c.[STANDARDISED_QTY] - c.prev_count_qty AS [ACTUAL_USAGE]
    ,c.[STANDARDISED_QTY] - (c.prev_count_qty + ISNULL(m.MOVEMENT_QTY, 0)) AS [VARIANCE]
    ,m.ORDER_QTY
    ,m.SALE_QTY
    ,m.PRODUCTION_QTY
    ,m.TRANSFER_QTY
    ,m.WASTE_QTY
    ,m.MOVEMENT_QTY
    ,COALESCE(ILC.UOM_COST, IC.UOM_COST) AS UOM_COST
    ,DATEDIFF(DAY, c.last_count, [EVENT_TS]) AS DAYS_SINCE_LAST_COUNT

FROM CountsWithPrevious c

LEFT JOIN MovementsByGroup m 
    ON c.[INVITEM_HUB_ID] = m.[INVITEM_HUB_ID]
    AND c.LOCATION_HUB_ID = m.LOCATION_HUB_ID
    AND c.count_group = m.count_group

LEFT OUTER JOIN
	InvLocCost ILC
ON c.[INVITEM_HUB_ID] = ILC.[INVITEM_HUB_ID]
AND c.[LOCATION_HUB_ID] = ILC.[LOCATION_HUB_ID]

LEFT OUTER JOIN
	InvCost IC
ON c.[INVITEM_HUB_ID] = IC.[INVITEM_HUB_ID]',
    1,
    N'Fact',
    N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](2)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_QTY", "table_column": "THEO_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}]',
    0,
    100,
    3,
    30,
    N'None',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'STOCKEVENT',
    N'COUNT_DATE'
);


-- ============================================
-- Step: Inventory Usage by Day
-- Table: F_INV_USAGE_DAY (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'FBCB305F-A7DB-4AE9-81E2-9D9DC4F22B2F',
    N'Inventory Usage by Day',
    N'F_INV_USAGE_DAY',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
DECLARE @InvItemAvgDays INT;

SET @InvItemAvgDays = 30;

SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''STOCKEVENT_END'';


WITH UOMConversion AS (
    SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor
    UNION ALL SELECT ''Kg'', ''gr'', 1000
    UNION ALL SELECT ''lb'', ''gr'', 453.59237
    UNION ALL SELECT ''oz'', ''gr'', 28.349523
    UNION ALL SELECT ''ml'', ''ml'', 1
    UNION ALL SELECT ''cl'', ''ml'', 10
    UNION ALL SELECT ''L'', ''ml'', 1000
    UNION ALL SELECT ''Imperial Pint'', ''ml'', 568.26125
    UNION ALL SELECT ''Gal'', ''ml'', 4546.09
    UNION ALL SELECT ''EA'', ''EA'', 1
),
StockEvents AS (
    SELECT
        SE.[HUB_ID]
        ,SE.[SRC]
        ,SE.[LOAD_TS]
        ,SE.[EFFECTIVEFROM]
        ,SE.[EFFECTIVETO]
        ,SE.[CURRENT_FLAG]
        ,SE.[IS_DELETED]
        ,SE.[EVENT_TYPE]
        ,CAST(SE.[EVENT_TS] AS DATE) AS [EVENT_TS]
        ,SE.[PACK_DESC]
        ,SE.[PACK_QUANTITY]
        ,SE.[UOM]
        ,SE.[UOM_QUANITY]
        ,SE.[UOM_QUANITY] * uc.conversion_factor AS [STANDARDISED_QTY]
        ,uc.base_uom AS [STANDARDISED_UOM]
        ,SE.[EXTERNAL_REF]
        ,SE.[INTERNAL_REF]
        ,SE.[EVENT_BEHAVIOUR]
        ,LSE.[LOCATION_HUB_ID]
        ,LII.[INVITEM_HUB_ID]
    FROM
        [datavault].[SAT_STOCKEVENT] SE
    INNER JOIN
        [datavault].[LNK_LOCATION_STOCKEVENT] LSE
        ON SE.[HUB_ID] = LSE.[STOCKEVENT_HUB_ID]
    INNER JOIN
        [datavault].[LNK_INVITEM_STOCKEVENT] LII
        ON SE.[HUB_ID] = LII.[STOCKEVENT_HUB_ID]
    LEFT OUTER JOIN
        UOMConversion uc
        ON SE.[UOM] = uc.[UOM]
    WHERE 1=1
    AND SE.[EVENT_TS] BETWEEN @StartDate AND @EndDate
),  

MovementsByGroup AS (
    SELECT 
        LOCATION_HUB_ID,
        INVITEM_HUB_ID,
        [STANDARDISED_UOM],
        [EVENT_TS],
        SUM(CASE WHEN EVENT_TYPE = ''WASTE''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS WASTE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''TRANSFER''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS TRANSFER_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''SALE''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS SALE_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''PRODUCTION''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS PRODUCTION_QTY,
        SUM(CASE WHEN EVENT_TYPE = ''ORDER''
            THEN
                CASE 
                    WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                    ELSE [STANDARDISED_QTY] 
                END
            ELSE 0
            END) AS ORDER_QTY, 
        SUM(
            CASE 
                WHEN EVENT_BEHAVIOUR = ''-'' THEN -1 * [STANDARDISED_QTY]
                ELSE [STANDARDISED_QTY] 
            END
        ) AS MOVEMENT_QTY
    FROM StockEvents
    WHERE EVENT_BEHAVIOUR IN (''+'', ''-'')
    GROUP BY INVITEM_HUB_ID, LOCATION_HUB_ID, [EVENT_TS], [STANDARDISED_UOM]
),

InvLocCost AS
	(
    SELECT DISTINCT
		LIL.[LOCATION_HUB_ID]
		,LII.[INVITEM_HUB_ID]
		,AVG(IR.[UOM_COST] / UC.[conversion_factor]) OVER(PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]) AS UOM_COST
		,AVG(IR.[UOM_COST] / UC.[conversion_factor]) OVER(PARTITION BY LII.[INVITEM_HUB_ID]) AS UOM_COST_INV
	FROM
		[datavault].[SAT_INVREPORT] IR

	INNER JOIN
		[datavault].[LNK_INVREPORT_LOCATION] LIL
	ON IR.[HUB_ID] = LIL.[INVREPORT_HUB_ID]

	INNER JOIN
		[datavault].[LNK_INVITEM_INVREPORT] LII
	ON IR.[HUB_ID] = LII.[INVREPORT_HUB_ID]

    LEFT JOIN
        UOMConversion uc
    ON IR.[REPORTING_UOM] = uc.[UOM]

	WHERE 1=1
	AND IR.[REPORTING_DATE] BETWEEN DATEADD(DAY,-@InvItemAvgDays,@EndDate) AND @EndDate
),

InvCost AS
	(
	SELECT DISTINCT
		INV.[INVITEM_HUB_ID]
		,INV.[UOM_COST_INV] AS UOM_COST
	FROM
		InvLocCost INV
)


SELECT 
    c.[LOCATION_HUB_ID]
    ,c.[INVITEM_HUB_ID]
    ,c.[EVENT_TS] AS COUNT_DATE
    ,c.[STANDARDISED_UOM]
    ,ISNULL(c.MOVEMENT_QTY, 0) AS [THEO_USAGE]
    ,ISNULL(c.ORDER_QTY, 0) AS ORDER_QTY
    ,ISNULL(c.SALE_QTY, 0) AS SALE_QTY
    ,ISNULL(c.PRODUCTION_QTY, 0) AS PRODUCTION_QTY
    ,ISNULL(c.TRANSFER_QTY, 0) AS TRANSFER_QTY
    ,ISNULL(c.WASTE_QTY, 0) AS WASTE_QTY
    ,COALESCE(ILC.UOM_COST, IC.UOM_COST) AS UOM_COST

FROM MovementsByGroup c

LEFT OUTER JOIN
	InvLocCost ILC
ON c.[INVITEM_HUB_ID] = ILC.[INVITEM_HUB_ID]
AND c.[LOCATION_HUB_ID] = ILC.[LOCATION_HUB_ID]

LEFT OUTER JOIN
	InvCost IC
ON c.[INVITEM_HUB_ID] = IC.[INVITEM_HUB_ID]',
    1,
    N'Fact',
    N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](2)"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
    0,
    100,
    3,
    30,
    N'None',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'STOCKEVENT',
    N'COUNT_DATE'
);


-- ============================================
-- Step: Location Dimension
-- Table: D_LOCATION (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'8BFFC93E-86C2-4C26-8BE1-9524C2FDB172',
    N'Location Dimension',
    N'D_LOCATION',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        LOCATION_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        LOCATION_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        LOCATION_ID as ROOT_LOCATION_ID,

        0 as LEVEL_DEPTH,

        CAST(LOCATION_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_LOCATION]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.LOCATION_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.LOCATION_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_LOCATION_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.LOCATION_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_LOCATION] d

    INNER JOIN HierarchyPath h ON d.LOCATION_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_LOCATION_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_LOCATION_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOCATION_NAME END) as BOTTOM_LOCATION_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOCATION_ID END) as BOTTOM_LOCATION_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LOCATION_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN LOCATION_NAME END) ,''All LOCATIONs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All LOCATIONs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LOCATION_NAME END),''All LOCATIONs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All LOCATIONs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_LOCATION_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_LOCATION_NAME", "table_column": "BOTTOM_LOCATION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOCATION_ID", "table_column": "BOTTOM_LOCATION_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Location Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Mod Dimension
-- Table: D_MOD (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'2A727427-3968-4A94-886D-05C9127707E0',
    N'Mod Dimension',
    N'D_MOD',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        MOD_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        MOD_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        MOD_ID as ROOT_MOD_ID,

        0 as LEVEL_DEPTH,

        CAST(MOD_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_MOD]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.MOD_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.MOD_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_MOD_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.MOD_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_MOD] d

    INNER JOIN HierarchyPath h ON d.MOD_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_MOD_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_MOD_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MOD_NAME END) as BOTTOM_MOD_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MOD_ID END) as BOTTOM_MOD_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MOD_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN MOD_NAME END) ,''All MODs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All MODs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MOD_NAME END),''All MODs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All MODs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_MOD_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_MOD_NAME", "table_column": "BOTTOM_MOD_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MOD_ID", "table_column": "BOTTOM_MOD_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Mod Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Occasion Dimension
-- Table: D_OCCASION (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'4B2AD418-9023-4536-930D-68999F79E547',
    N'Occasion Dimension',
    N'D_OCCASION',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        OCCASION_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        OCCASSION_ID, 

        /*  Columns set to null pending their inclusion into the tables  */
        NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME,

        OCCASSION_ID as ROOT_OCCASSION_ID,

        0 as LEVEL_DEPTH,

        CAST(OCCASSION_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_OCCASION]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.OCCASION_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.OCCASSION_ID, 

        /*  Columns set to null pending their inclusion into the tables  */
        NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME,

        h.ROOT_OCCASSION_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.OCCASSION_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_OCCASION] d

    INNER JOIN HierarchyPath h ON d.OCCASSION_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_OCCASSION_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_OCCASSION_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN OCCASION_NAME END) as BOTTOM_OCCASION_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN OCCASSION_ID END) as BOTTOM_OCCASSION_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN OCCASION_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN OCCASION_NAME END) ,''All OCCASIONs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All OCCASIONs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN OCCASION_NAME END),''All OCCASIONs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All OCCASIONs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_OCCASSION_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_OCCASION_NAME", "table_column": "BOTTOM_OCCASION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_OCCASSION_ID", "table_column": "BOTTOM_OCCASSION_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Occasion Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Product Dimension
-- Table: D_PRODUCT (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'17BE63CD-816D-4661-A5D1-9E96A2D10F27',
    N'Product Dimension',
    N'D_PRODUCT',
    N'WITH HierarchyPath AS (
    SELECT 
        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
        PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL,
        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,
        PRODUCT_ID, MICROSERVICE_ID, MICROSERVICE_NAME,
        PRODUCT_ID as ROOT_PRODUCT_ID,
        0 as LEVEL_DEPTH,
        CAST(PRODUCT_ID as VARCHAR(MAX)) as PATH
    FROM [datavault].[SAT_PRODUCT]
    WHERE BOTTOM_LEVEL = 1
      AND CURRENT_FLAG = 1
    
    UNION ALL
    
    SELECT 
        p.HUB_ID, p.SRC, p.LOAD_TS, p.EFFECTIVEFROM, p.EFFECTIVETO, p.CURRENT_FLAG, p.IS_DELETED,
        p.PRODUCT_NAME, p.PARENT_ID, p.LEVEL_NAME, p.BOTTOM_LEVEL,
        p.ATTR_1, p.ATTR_2, p.ATTR_3, p.ATTR_4, p.ATTR_5,
        p.PRODUCT_ID, p.MICROSERVICE_ID, p.MICROSERVICE_NAME,
        h.ROOT_PRODUCT_ID,
        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,
        h.PATH + ''->'' + CAST(p.PRODUCT_ID as VARCHAR(MAX)) as PATH
    FROM [datavault].[SAT_PRODUCT] p
    INNER JOIN HierarchyPath h ON p.PRODUCT_ID = h.PARENT_ID
    WHERE p.CURRENT_FLAG = 1
),

NumberedHierarchy AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ROOT_PRODUCT_ID ORDER BY LEVEL_DEPTH) as RN
    FROM HierarchyPath
),

FilteredHierarchy AS (
    SELECT *,
        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_PRODUCT_ID) as MAX_LEVEL
    FROM NumberedHierarchy
),

SelectedLevels AS (
    SELECT *
    FROM FilteredHierarchy
    WHERE 
        LEVEL_DEPTH = 0  
        OR PARENT_ID IS NULL  
        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= 2) 
)

SELECT 

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN PRODUCT_NAME END) as BOTTOM_PRODUCT_NAME,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN PRODUCT_ID END) as BOTTOM_PRODUCT_ID,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN PRODUCT_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN PRODUCT_NAME END) ,''All Products'') as MIDDLE_1_NAME,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All Products'') as MIDDLE_1_LEVEL_NAME,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN PRODUCT_NAME END),''All Products'') as TOP_NAME,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All Products'') as TOP_LEVEL_NAME,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,

    MAX(PATH) as HIERARCHY_PATH,
    MAX(MAX_LEVEL) as TOTAL_LEVELS
FROM SelectedLevels
GROUP BY ROOT_PRODUCT_ID
UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "BOTTOM_PRODUCT_NAME", "table_column": "BOTTOM_PRODUCT_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_PRODUCT_ID", "table_column": "BOTTOM_PRODUCT_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[varchar](max)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[int]"}]',
    0,
    100,
    3,
    30,
    N'Product Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Product Margins by Day
-- Table: F_PRODUCT_MARGIN_DAY (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'109353E7-685E-4D0F-8840-26A17AF70DF6',
    N'Product Margins by Day',
    N'F_PRODUCT_MARGIN_DAY',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''LINEITEM_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''LINEITEM_END'';

WITH ProductBase
AS
(
SELECT
    LI.HUB_ID AS PROD_LI_HUB_ID
    ,COALESCE(CLILI.[PARENT_HUB_ID], PLILI.[CHILD_HUB_ID]) AS PARTNER_LI_HUB_ID
    ,COALESCE(CSAT.[LABEL], PSAT.[LABEL]) AS [LABEL]
    ,COALESCE(CSAT.[VALUE], PSAT.[VALUE]) AS [VALUE]
    ,LO.[OCCASION_HUB_ID]
    ,LL.[LOCATION_HUB_ID]
    ,LNKREV.[REVCENTER_HUB_ID]
    ,LNKCH.[CHANNEL_HUB_ID]
    ,LI.*
FROM
    [datavault].[SAT_LINEITEM] LI

INNER JOIN
    [core].[core].[Integrations] IG
ON LI.[SRC] = IG.[SchemaName]
AND IG.[IntegrationType] = ''POS''

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_LINEITEM] CLILI
ON LI.[HUB_ID] = CLILI.[CHILD_HUB_ID]

LEFT OUTER JOIN
    [datavault].[SAT_LNK_LINEITEM_LINEITEM] CSAT
ON CLILI.[LNK_ID] = CSAT.[LNK_ID]

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_LINEITEM] PLILI
ON LI.[HUB_ID] = PLILI.[PARENT_HUB_ID]

LEFT OUTER JOIN
    [datavault].[SAT_LNK_LINEITEM_LINEITEM] PSAT
ON PLILI.[LNK_ID] = PSAT.[LNK_ID]

LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_OCCASION] LO
ON LI.[HUB_ID] = LO.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LINEITEM] LC
ON LI.[HUB_ID] = LC.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_LOCATION] LL
ON LC.[CUSTORDER_HUB_ID] = LL.[CUSTORDER_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CUSTORDER_REVCENTER] LNKREV
ON LC.[CUSTORDER_HUB_ID] = LNKREV.[CUSTORDER_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_CHANNEL_CUSTORDER] LNKCH
ON LC.[CUSTORDER_HUB_ID] = LNKCH.[CUSTORDER_HUB_ID]

WHERE 
LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate
AND 
LI.[LINEITEM_TYPE] = ''PROD''
),

LinkData AS (
    SELECT 
        lnk.LNK_ID,
        lnk.LOCATION_HUB_ID,
        lnk.OCCASION_HUB_ID,
        lnk.PRODUCT_HUB_ID,
        sat.NET_PRICE,
        sat.NET_COST,
        lnk.SRC,
        loc.LOCATION_ID,
        loc.LOCATION_NAME,
        loc.MICROSERVICE_NAME AS LOCATION_MICROSERVICE,
        prd.PRODUCT_ID,
        prd.PRODUCT_NAME,
        prd.MICROSERVICE_NAME AS PRODUCT_MICROSERVICE,
        occ.OCCASION_NAME,
        occ.MICROSERVICE_NAME AS OCCASION_MICROSERVICE
    FROM [datavault].[LNK_LOCATION_OCCASION_PRODUCT] lnk
    INNER JOIN [datavault].[SAT_LNK_LOCATION_OCCASION_PRODUCT] sat
        ON lnk.LNK_ID = sat.LNK_ID
    INNER JOIN [datavault].[SAT_LOCATION] loc
        ON lnk.LOCATION_HUB_ID = loc.HUB_ID
        AND loc.BOTTOM_LEVEL = 1
        AND loc.CURRENT_FLAG = 1
        AND loc.IS_DELETED = 0
    INNER JOIN [datavault].[SAT_PRODUCT] prd
        ON lnk.PRODUCT_HUB_ID = prd.HUB_ID
        AND prd.BOTTOM_LEVEL = 1
        AND prd.CURRENT_FLAG = 1
        AND prd.IS_DELETED = 0
    LEFT JOIN [datavault].[SAT_OCCASION] occ
        ON lnk.OCCASION_HUB_ID = occ.HUB_ID
        AND occ.BOTTOM_LEVEL = 1
        AND occ.CURRENT_FLAG = 1
        AND occ.IS_DELETED = 0
),

ProductPrice AS
(
SELECT DISTINCT
    ld.LNK_ID,
    ld.LOCATION_HUB_ID,
    ld.OCCASION_HUB_ID,
    ld.PRODUCT_HUB_ID,
    ld.LOCATION_NAME,
    ld.PRODUCT_NAME,
    ld.OCCASION_NAME,
    ld.LOCATION_MICROSERVICE,
    ld.LOCATION_ID,
    ld.SRC,
    -- Fill NULL prices from matching records
    COALESCE(
        ld.NET_PRICE,
        match_with_occasion.NET_PRICE,
        match_without_occasion.NET_PRICE
    ) AS NET_PRICE,
    COALESCE(
        ld.NET_COST,
        match_with_occasion.NET_COST,
        match_without_occasion.NET_COST
    ) AS NET_COST
FROM LinkData ld

-- Try to match with records that have the same occasion
LEFT JOIN LinkData match_with_occasion
    ON COALESCE(ld.LOCATION_MICROSERVICE,ld.LOCATION_NAME) = COALESCE(match_with_occasion.LOCATION_MICROSERVICE,match_with_occasion.LOCATION_NAME)
    AND ld.PRODUCT_ID = match_with_occasion.PRODUCT_ID
    AND COALESCE(ld.OCCASION_MICROSERVICE,ld.OCCASION_NAME) = COALESCE(match_with_occasion.OCCASION_MICROSERVICE, match_with_occasion.OCCASION_NAME)
    AND ld.SRC <> match_with_occasion.SRC  -- Different source
    AND ld.LNK_ID <> match_with_occasion.LNK_ID  -- Different record
    AND match_with_occasion.NET_PRICE IS NOT NULL  -- Has data to fill

 --If no occasion match or current record has null occasion, match by location+product only
LEFT JOIN LinkData match_without_occasion
    ON COALESCE(ld.LOCATION_MICROSERVICE,ld.LOCATION_NAME) = COALESCE(match_without_occasion.LOCATION_MICROSERVICE,match_without_occasion.LOCATION_NAME)
    AND ld.PRODUCT_ID = match_without_occasion.PRODUCT_ID
    AND ld.SRC <> match_without_occasion.SRC  -- Different source
    AND ld.LNK_ID <> match_without_occasion.LNK_ID  -- Different record
    AND match_without_occasion.NET_PRICE IS NOT NULL  -- Has data to fill


),

Final AS
(
SELECT
    P.[PROD_LI_HUB_ID]
    ,LP.[PRODUCT_HUB_ID]
    ,P.[OCCASION_HUB_ID]
    ,P.[LOCATION_HUB_ID]
    ,DEAL.[DEAL_HUB_ID]
    ,DISC.[DISCOUNT_HUB_ID]
    ,P.[REVCENTER_HUB_ID]
    ,P.[CHANNEL_HUB_ID]
    ,P.[ORDER_DATE]
    ,P.[LINEITEM_TIMESTAMP]
    ,P.[HEADER_ID]
    ,PROD.[PRODUCT_ID]
    ,PROD.[PRODUCT_NAME]
    ,P.[GROSS_VALUE]
    ,P.[NET_VALUE]
    ,P.[TAX_VALUE]
    ,P.[QUANTITY]
    ,P.[QUANTITY_INV]
    ,MAX(CASE WHEN LI.[LINEITEM_TYPE] = ''DISCOUNT'' THEN P.[VALUE] ELSE 0 END) AS DISCOUNT_PROD
    ,MAX(CASE WHEN LI.[LINEITEM_TYPE] = ''DISCOUNT'' THEN 1 ELSE 0 END) AS DISCOUNT_FLAG
    ,MAX(CASE WHEN LI.[LINEITEM_TYPE] = ''DEAL'' THEN 1 ELSE 0 END) AS DEAL_FLAG
    ,MAX(CASE WHEN LI.[LINEITEM_TYPE] = ''MOD'' THEN 1 ELSE 0 END) AS MOD_FLAG

FROM
    ProductBase P

INNER JOIN
    [datavault].[LNK_LINEITEM_PRODUCT] LP
ON P.[PROD_LI_HUB_ID] = LP.[LINEITEM_HUB_ID]

INNER JOIN
    [datavault].[SAT_PRODUCT] PROD
ON LP.[PRODUCT_HUB_ID] = PROD.[HUB_ID]

LEFT OUTER JOIN
    [datavault].[SAT_LINEITEM] LI
ON P.PARTNER_LI_HUB_ID = LI.[HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_DEAL_LINEITEM] DEAL
ON P.[PARTNER_LI_HUB_ID] = DEAL.[LINEITEM_HUB_ID]

LEFT OUTER JOIN
    [datavault].[LNK_DISCOUNT_LINEITEM] DISC
ON P.[PARTNER_LI_HUB_ID] = DISC.[LINEITEM_HUB_ID]

GROUP BY
    P.[PROD_LI_HUB_ID]
    ,LP.[PRODUCT_HUB_ID]
    ,P.[OCCASION_HUB_ID]
    ,P.[LOCATION_HUB_ID]
    ,DEAL.[DEAL_HUB_ID]
    ,DISC.[DISCOUNT_HUB_ID]
    ,P.[REVCENTER_HUB_ID]
    ,P.[CHANNEL_HUB_ID]
    ,P.[ORDER_DATE]
    ,P.[LINEITEM_TIMESTAMP]
    ,P.[HEADER_ID]
    ,PROD.[PRODUCT_ID]
    ,PROD.[PRODUCT_NAME]
    ,P.[GROSS_VALUE]
    ,P.[NET_VALUE]
    ,P.[TAX_VALUE]
    ,P.[QUANTITY]
    ,P.[QUANTITY_INV]

)

SELECT
    ISNULL(F.[PRODUCT_HUB_ID],CONVERT(BINARY(32), -999)) AS [PRODUCT_HUB_ID]
    ,ISNULL(F.[OCCASION_HUB_ID],CONVERT(BINARY(32), -999)) AS [OCCASION_HUB_ID]
    ,ISNULL(F.[LOCATION_HUB_ID],CONVERT(BINARY(32), -999)) AS  [LOCATION_HUB_ID]
    ,ISNULL(F.[REVCENTER_HUB_ID],CONVERT(BINARY(32), -999)) AS  [REVCENTER_HUB_ID]
    ,ISNULL(F.[CHANNEL_HUB_ID],CONVERT(BINARY(32), -999)) AS  [CHANNEL_HUB_ID]
    ,ISNULL(F.[DEAL_HUB_ID],CONVERT(BINARY(32), -999)) AS  [DEAL_HUB_ID]
    ,ISNULL(F.[DISCOUNT_HUB_ID],CONVERT(BINARY(32), -999)) AS  [DISCOUNT_HUB_ID]
    ,F.[ORDER_DATE]
    ,F.[DEAL_FLAG]
    ,SUM(F.[NET_VALUE]) AS [NET_VALUE]
    ,SUM(F.[QUANTITY]) AS [QUANTITY]
    ,AVG(PP.[NET_COST]) AS [AVG_NET_COST]
    ,AVG(F.[NET_VALUE]) AS [AVG_NET_PRICE_CHARGED]
    ,AVG(PP.[NET_PRICE]) AS [AVG_NET_PRICE]
    ,SUM(F.[NET_VALUE] - PP.[NET_COST]) AS PROFIT
    ,SUM(F.[NET_VALUE] - PP.[NET_COST] - F.[DISCOUNT_PROD]) AS PROFIT_LESS_DISCOUNT
   
FROM 
    Final F
LEFT OUTER JOIN

    ProductPrice PP
ON F.LOCATION_HUB_ID = PP.LOCATION_HUB_ID
AND F.[OCCASION_HUB_ID] = PP.[OCCASION_HUB_ID]
AND F.[PRODUCT_HUB_ID] = PP.[PRODUCT_HUB_ID]

GROUP BY
    ISNULL(F.[PRODUCT_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(F.[OCCASION_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(F.[LOCATION_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(F.[REVCENTER_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(F.[CHANNEL_HUB_ID],CONVERT(BINARY(32), -999)) 
    ,ISNULL(F.[DEAL_HUB_ID],CONVERT(BINARY(32), -999))
    ,ISNULL(F.[DISCOUNT_HUB_ID],CONVERT(BINARY(32), -999))
    ,F.[ORDER_DATE]
    ,F.[DEAL_FLAG]',
    1,
    N'Fact',
    N'[{"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DEAL_HUB_ID", "table_column": "DEAL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DISCOUNT_HUB_ID", "table_column": "DISCOUNT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "DEAL_FLAG", "table_column": "DEAL_FLAG", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "NET_VALUE", "table_column": "NET_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY", "table_column": "QUANTITY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_COST", "table_column": "AVG_NET_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_PRICE_CHARGED", "table_column": "AVG_NET_PRICE_CHARGED", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_PRICE", "table_column": "AVG_NET_PRICE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PROFIT", "table_column": "PROFIT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PROFIT_LESS_DISCOUNT", "table_column": "PROFIT_LESS_DISCOUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
    0,
    100,
    3,
    30,
    N'None',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'LINEITEM',
    N'ORDER_DATE'
);


-- ============================================
-- Step: Revenue Center Dimension
-- Table: D_REVCENTER (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'D93BF54A-3272-4B16-8F4B-C3C5FF9A0043',
    N'Revenue Center Dimension',
    N'D_REVCENTER',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        REVC_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        REVC_ID, 

        /*  Columns set to null pending their inclusion into the tables  */
        /*  NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME, */
        MICROSERVICE_ID AS MICROSERVICE_ID, MICROSERVICE_NAME AS MICROSERVICE_NAME,  

        REVC_ID as ROOT_CHANNEL_ID,

        0 as LEVEL_DEPTH,

        CAST(REVC_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_REVCENTER]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.REVC_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.REVC_ID, 

        /*  Columns set to null pending their inclusion into the tables  */
        /* NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME,  */
        d.MICROSERVICE_ID AS MICROSERVICE_ID, d.MICROSERVICE_NAME AS MICROSERVICE_NAME,  
        h.ROOT_CHANNEL_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.REVC_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_REVCENTER] d

    INNER JOIN HierarchyPath h ON d.REVC_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_CHANNEL_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_CHANNEL_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN REVC_NAME END) as BOTTOM_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN REVC_ID END) as BOTTOM_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN REVC_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN REVC_NAME END) ,''All Revenue Centers'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All Revenue Centers'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN REVC_NAME END),''All Revenue Centers'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All Revenue Centers'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_CHANNEL_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_NAME,
    NULL AS BOTTOM_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_NAME", "table_column": "BOTTOM_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ID", "table_column": "BOTTOM_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
    0,
    100,
    3,
    30,
    NULL,
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    NULL,
    NULL
);


-- ============================================
-- Step: Service Charge Dimension
-- Table: D_SERVICECHARGE (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'6E009496-3189-4EB9-B414-FFC42AE73FA6',
    N'Service Charge Dimension',
    N'D_SERVICECHARGE',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        SVCCHARGE_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        SVC_ID , NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME,

        SVC_ID as ROOT_SVC_ID,

        0 as LEVEL_DEPTH,

        CAST(SVC_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_SVCCHARGE]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.SVCCHARGE_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.SVC_ID, NULL AS MICROSERVICE_ID, NULL AS MICROSERVICE_NAME,

        h.ROOT_SVC_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.SVC_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_SVCCHARGE] d

    INNER JOIN HierarchyPath h ON d.SVC_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_SVC_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_SVC_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SVCCHARGE_NAME END) as BOTTOM_SVCCHARGE_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SVC_ID END) as BOTTOM_SVC_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN SVCCHARGE_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN SVCCHARGE_NAME END) ,''All SVCCHARGEs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All SVCCHARGEs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,

 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN SVCCHARGE_NAME END),''All SVCCHARGEs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All SVCCHARGEs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,

    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_SVC_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_SVCCHARGE_NAME", "table_column": "BOTTOM_SVCCHARGE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_SVC_ID", "table_column": "BOTTOM_SVC_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Service Charge Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Supplier Dimension
-- Table: D_SUPPLIER (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'1AE654CB-8D44-4668-BB76-62B46C9A6998',
    N'Supplier Dimension',
    N'D_SUPPLIER',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        SUPPLIER_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        SUPPLIER_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        SUPPLIER_ID as ROOT_SUPPLIER_ID,

        0 as LEVEL_DEPTH,

        CAST(SUPPLIER_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_SUPPLIER]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.SUPPLIER_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.SUPPLIER_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_SUPPLIER_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.SUPPLIER_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_SUPPLIER] d

    INNER JOIN HierarchyPath h ON d.SUPPLIER_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_SUPPLIER_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_SUPPLIER_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SUPPLIER_NAME END) as BOTTOM_SUPPLIER_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SUPPLIER_ID END) as BOTTOM_SUPPLIER_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN SUPPLIER_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN SUPPLIER_NAME END) ,''All SUPPLIERs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All SUPPLIERs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN SUPPLIER_NAME END),''All SUPPLIERs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All SUPPLIERs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_SUPPLIER_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_SUPPLIER_NAME", "table_column": "BOTTOM_SUPPLIER_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_SUPPLIER_ID", "table_column": "BOTTOM_SUPPLIER_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'supplier Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: TAX Dimension
-- Table: D_TAX (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'F4646984-16D7-42C5-A179-9202518D4BF3',
    N'TAX Dimension',
    N'D_TAX',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        TAX_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        TAX_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        TAX_ID as ROOT_TAX_ID,

        0 as LEVEL_DEPTH,

        CAST(TAX_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_TAX]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.TAX_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.TAX_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_TAX_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.TAX_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_TAX] d

    INNER JOIN HierarchyPath h ON d.TAX_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_TAX_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_TAX_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN TAX_NAME END) as BOTTOM_TAX_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN TAX_ID END) as BOTTOM_TAX_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN TAX_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN TAX_NAME END) ,''All TAXs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All TAXs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN TAX_NAME END),''All TAXs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All TAXs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_TAX_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_TAX_NAME", "table_column": "BOTTOM_TAX_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_TAX_ID", "table_column": "BOTTOM_TAX_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Tax Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Tender Dimension
-- Table: D_TENDER (Tier 1)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'C5C413F7-2F0C-42CA-BAB5-EBA249932A22',
    N'Tender Dimension',
    N'D_TENDER',
    N'-- Variable to control number of middle levels to include

DECLARE @MiddleLevels INT = 1; -- Change this value as needed
 
-- Recursive CTE to build the hierarchy path

WITH HierarchyPath AS (

    -- Anchor: Start with bottom level records

    SELECT 

        HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
 
        TENDER_NAME, PARENT_ID,

        LEVEL_NAME, BOTTOM_LEVEL,

        ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5,

        TENDER_ID, MICROSERVICE_ID, MICROSERVICE_NAME,

        TENDER_ID as ROOT_TENDER_ID,

        0 as LEVEL_DEPTH,

        CAST(TENDER_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_TENDER]

    WHERE BOTTOM_LEVEL = 1

      AND CURRENT_FLAG = 1

    UNION ALL

    -- Recursive: Traverse up the hierarchy

    SELECT 

        d.HUB_ID, d.SRC, d.LOAD_TS, d.EFFECTIVEFROM, d.EFFECTIVETO, d.CURRENT_FLAG, d.IS_DELETED,

        d.TENDER_NAME, d.PARENT_ID, 
        d.LEVEL_NAME, d.BOTTOM_LEVEL,

        d.ATTR_1, d.ATTR_2, d.ATTR_3, d.ATTR_4, d.ATTR_5,

        d.TENDER_ID, d.MICROSERVICE_ID, d.MICROSERVICE_NAME,

        h.ROOT_TENDER_ID,

        h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,

        h.PATH + ''->'' + CAST(d.TENDER_ID as VARCHAR(MAX)) as PATH

    FROM [datavault].[SAT_TENDER] d

    INNER JOIN HierarchyPath h ON d.TENDER_ID = h.PARENT_ID

    WHERE d.CURRENT_FLAG = 1

),
 
-- Number each level for pivoting

NumberedHierarchy AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY ROOT_TENDER_ID ORDER BY LEVEL_DEPTH) as RN

    FROM HierarchyPath

),
 
-- Determine max levels and filter based on middle levels parameter

FilteredHierarchy AS (

    SELECT *,

        MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_TENDER_ID) as MAX_LEVEL

    FROM NumberedHierarchy

),
 
-- Keep only bottom level, top level, and specified middle levels

SelectedLevels AS (

    SELECT *

    FROM FilteredHierarchy

    WHERE 

        LEVEL_DEPTH = 0  -- Bottom level

        OR PARENT_ID IS NULL  -- Top level

        OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1) -- Middle levels

)
 
-- Pivot the hierarchy into columns

SELECT
 
    -- Bottom level (all attributes)

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN SRC END) as BOTTOM_SRC,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LOAD_TS END) as BOTTOM_LOAD_TS,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVEFROM END) as BOTTOM_EFFECTIVEFROM,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN EFFECTIVETO END) as BOTTOM_EFFECTIVETO,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(CURRENT_FLAG as INT) END) as BOTTOM_CURRENT_FLAG,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN CAST(IS_DELETED as INT) END) as BOTTOM_IS_DELETED,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN TENDER_NAME END) as BOTTOM_TENDER_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN TENDER_ID END) as BOTTOM_TENDER_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN LEVEL_NAME END) as BOTTOM_LEVEL_NAME,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_1 END) as BOTTOM_ATTR_1,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_2 END) as BOTTOM_ATTR_2,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_3 END) as BOTTOM_ATTR_3,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_4 END) as BOTTOM_ATTR_4,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN ATTR_5 END) as BOTTOM_ATTR_5,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END) as BOTTOM_MICROSERVICE_ID,

    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) as BOTTOM_MICROSERVICE_NAME,
 
    -- Middle Level 1

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN TENDER_NAME END), MAX(CASE WHEN PARENT_ID IS NULL THEN TENDER_NAME END) ,''All TENDERs'') as MIDDLE_1_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN LEVEL_NAME END),MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END),''All TENDERs'') as MIDDLE_1_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_1 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL)  as MIDDLE_1_ATTR_1,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_2 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as MIDDLE_1_ATTR_2,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_3 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL)  as MIDDLE_1_ATTR_3,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_4 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL)  as MIDDLE_1_ATTR_4,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ATTR_5 END),MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL)  as MIDDLE_1_ATTR_5,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END)) as MIDDLE_1_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as MIDDLE_1_MICROSERVICE_NAME,
 
 
    -- Top level (PARENT_ID IS NULL)

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN TENDER_NAME END),''All TENDERs'') as TOP_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN LEVEL_NAME END), ''All TENDERs'') as TOP_LEVEL_NAME,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_1 END),NULL) as TOP_ATTR_1,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_2 END),NULL) as TOP_ATTR_2,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_3 END),NULL) as TOP_ATTR_3,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_4 END),NULL) as TOP_ATTR_4,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ATTR_5 END),NULL) as TOP_ATTR_5,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_ID END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_ID END))  as TOP_MICROSERVICE_ID,

    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN MICROSERVICE_NAME END),MAX(CASE WHEN LEVEL_DEPTH = 0 THEN MICROSERVICE_NAME END) ) as TOP_MICROSERVICE_NAME,
 
    -- Additional useful info

    MAX(PATH) as HIERARCHY_PATH,

    MAX(MAX_LEVEL) as TOTAL_LEVELS

FROM SelectedLevels

GROUP BY ROOT_TENDER_ID

UNION ALL

SELECT
    CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID,
    ''datavault'' AS BOTTOM_SRC,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_LOAD_TS,
    ''2000-01-01 00:00:00.0000000'' AS BOTTOM_EFFECTIVEFROM,
    NULL AS BOTTOM_EFFECTIVETO,
    1 AS BOTTOM_CURRENT_FLAG,
    0 AS BOTTOM_IS_DELETED,
    ''Unknown'' AS BOTTOM_CHANNEL_NAME,
    NULL AS BOTTOM_CHANNEL_ID,
    ''Unknown'' AS BOTTOM_LEVEL_NAME,
    NULL AS BOTTOM_ATTR_1,
    NULL AS BOTTOM_ATTR_2,
    NULL AS BOTTOM_ATTR_3,
    NULL AS BOTTOM_ATTR_4,
    NULL AS BOTTOM_ATTR_5,
    NULL AS BOTTOM_MICROSERVICE_ID,
    NULL AS BOTTOM_MICROSERVICE_NAME,
    ''Unknown'' AS MIDDLE_1_NAME,
    ''Unknown'' AS MIDDLE_1_LEVEL_NAME,
    NULL AS MIDDLE_1_ATTR_1,
    NULL AS MIDDLE_1_ATTR_2,
    NULL AS MIDDLE_1_ATTR_3,
    NULL AS MIDDLE_1_ATTR_4,
    NULL AS MIDDLE_1_ATTR_5,
    NULL AS MIDDLE_1_MICROSERVICE_ID,
    NULL AS MIDDLE_1_MICROSERVICE_NAME,
    ''Unknown'' AS TOP_NAME,
    ''Unknown'' AS TOP_LEVEL_NAME,
    NULL AS TOP_ATTR_1,
    NULL AS TOP_ATTR_2,
    NULL AS TOP_ATTR_3,
    NULL AS TOP_ATTR_4,
    NULL AS TOP_ATTR_5,
    NULL AS TOP_MICROSERVICE_ID,
    NULL AS TOP_MICROSERVICE_NAME,
    NULL AS HIERARCHY_PATH,
    1 AS TOTAL_LEVELS',
    1,
    N'Dimension',
    N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_TENDER_NAME", "table_column": "BOTTOM_TENDER_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_TENDER_ID", "table_column": "BOTTOM_TENDER_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
    0,
    100,
    3,
    30,
    N'Tender Dimension Build',
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'None',
    NULL
);


-- ============================================
-- Step: Inventory Sales by Day
-- Table: F_INV_SALES_DAY (Tier 2)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'F6EA7F17-10A6-422A-9276-4AB055697ACE',
    N'Inventory Sales by Day',
    N'F_INV_SALES_DAY',
    N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''STOCKEVENT_END'';

WITH UOMConversion AS 
	(
	SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor
	UNION ALL SELECT ''Kg'', ''gr'', 1000
	UNION ALL SELECT ''lb'', ''gr'', 453.59237
	UNION ALL SELECT ''oz'', ''gr'', 28.349523
	UNION ALL SELECT ''ml'', ''ml'', 1
	UNION ALL SELECT ''cl'', ''ml'', 10
	UNION ALL SELECT ''L'', ''ml'', 1000
	UNION ALL SELECT ''Imperial Pint'', ''ml'', 568.26125
	UNION ALL SELECT ''Gal'', ''ml'', 4546.09
	UNION ALL SELECT ''EA'', ''EA'', 1
),

Inventory AS
	(
	SELECT
		*
	FROM
		[presentation].[F_INV_USAGE_DAY] IR

	WHERE 1=1
	AND IR.[COUNT_DATE] BETWEEN @StartDate AND @EndDate

),

ProductSales AS
(
	SELECT
		LP.[PRODUCT_HUB_ID]
		,LL.[LOCATION_HUB_ID]
		,LO.[OCCASION_HUB_ID]
		,LI.*
	FROM
		[datavault].[SAT_LINEITEM] LI

	INNER JOIN
		[core].[core].[Integrations] IG
	ON LI.[SRC] = IG.[SchemaName]
	AND IG.[IntegrationType] = ''INVENTORY''

	LEFT OUTER JOIN
		[datavault].[LNK_LINEITEM_PRODUCT] LP
	ON LI.[HUB_ID] = LP.[LINEITEM_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[LNK_CUSTORDER_LINEITEM] LC
	ON LI.[HUB_ID] = LC.[LINEITEM_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[LNK_CUSTORDER_LOCATION] LL
	ON LC.[CUSTORDER_HUB_ID] = LL.[CUSTORDER_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[LNK_LINEITEM_OCCASION] LO
	ON LI.[HUB_ID] = LO.[LINEITEM_HUB_ID]

	WHERE 1=1
	AND LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate
	AND LI.[LINEITEM_TYPE] = ''PROD''
),


ProductInvSales AS
	(
	SELECT 
		LLOP.INVITEM_HUB_ID
		,SLLOP.[UOM]
		,SLLOP.[UOM_VALUE] * UC.[conversion_factor] AS [UOM_VALUE]
		,PS.*
	FROM
		ProductSales PS

	LEFT OUTER JOIN
		[datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT] LLOP
	ON PS.[OCCASION_HUB_ID] = LLOP.[OCCASION_HUB_ID]
	AND PS.[LOCATION_HUB_ID] = LLOP.[LOCATION_HUB_ID]
	AND PS.[PRODUCT_HUB_ID] = LLOP.[PRODUCT_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT] SLLOP
	ON LLOP.[LNK_ID] = SLLOP.[LNK_ID]

    LEFT JOIN
        UOMConversion uc
    ON SLLOP.[UOM] = uc.[UOM]
)

SELECT
	INVITEM_HUB_ID
	,LOCATION_HUB_ID
	,INV_DATE
	,AVG(UOM_COST) AS UOM_COST
	,SUM(SALES_RECIPE_COST) AS SALES_RECIPE_COST
	,SUM(NET_SALES) AS NET_SALES

FROM
(
	SELECT
		COALESCE(PIS.INVITEM_HUB_ID, INV.[INVITEM_HUB_ID]) AS [INVITEM_HUB_ID]
		,COALESCE(PIS.[LOCATION_HUB_ID], INV.  [LOCATION_HUB_ID]) AS [LOCATION_HUB_ID]
		,COALESCE(PIS.ORDER_DATE,INV.[COUNT_DATE]) AS INV_DATE
		,ISNULL(INV.UOM_COST,0) AS UOM_COST
		,ISNULL((PIS.UOM_VALUE * INV.UOM_COST),0) AS SALES_RECIPE_COST
		,ISNULL(((PIS.UOM_VALUE * INV.UOM_COST) / SUM(PIS.UOM_VALUE * INV.UOM_COST) OVER(PARTITION BY PIS.HUB_ID)) * PIS.NET_VALUE,0) AS NET_SALES
	FROM
		Inventory INV
	LEFT OUTER JOIN
		ProductInvSales PIS
	ON INV.[LOCATION_HUB_ID] = PIS.[LOCATION_HUB_ID]
	AND INV.[INVITEM_HUB_ID] = PIS.[INVITEM_HUB_ID]
	AND INV.[COUNT_DATE] = PIS.[ORDER_DATE]
	) SUB
GROUP BY 
	INVITEM_HUB_ID
	,LOCATION_HUB_ID
	,INV_DATE',
    2,
    N'Fact',
    N'[{"query_column": "DATE", "table_column": "INV_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}]',
    0,
    100,
    3,
    30,
    NULL,
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    N'STOCKEVENT',
    N'INV_DATE'
);


-- ============================================
-- Step: Product CoOccurrence Dimension
-- Table: D_COOCCURRENCE (Tier 2)
-- ============================================
INSERT INTO [core].[PresentationControl]
    (id, step_name, table_name, query_sql, tier, table_type,
     column_mappings, exclude, priority, retry_count, timeout_minutes,
     description, created_by, created_at, updated_at,
     time_series_entity, time_series_target_column)
VALUES (
    N'F2AE2DC5-C506-4383-A667-553DA535C120',
    N'Product CoOccurrence Dimension',
    N'D_COOCCURRENCE',
    N'SELECT
    TD1.PRODUCT_HUB_ID AS PRODUCT_HUB_ID
    ,TD2.PRODUCT_HUB_ID AS PRODUCT_HUB_ID_COMP
    ,TD1.OCCASION_HUB_ID AS OCCASION_HUB_ID
    ,TD1.LOCATION_HUB_ID AS LOCATION_HUB_ID
    ,TD1.REVCENTER_HUB_ID AS REVCENTER_HUB_ID
    ,TD1.CHANNEL_HUB_ID AS CHANNEL_HUB_ID
    ,COUNT(DISTINCT TD1.HEADER_ID) AS globalOccurenceCount
    ,(SELECT
        COUNT(DISTINCT HEADER_ID) FROM [presentation].[E_COOCCUR_BASE] 
        WHERE PRODUCT_HUB_ID = TD1.PRODUCT_HUB_ID
        AND OCCASION_HUB_ID = TD1.OCCASION_HUB_ID
        AND LOCATION_HUB_ID = TD1.LOCATION_HUB_ID
        AND REVCENTER_HUB_ID = TD1.REVCENTER_HUB_ID
        AND CHANNEL_HUB_ID = TD1.CHANNEL_HUB_ID) AS DistinctOrderCount
            
FROM
    [presentation].[E_COOCCUR_BASE] TD1
INNER JOIN
    [presentation].[E_COOCCUR_BASE] TD2
ON TD1.HEADER_ID = TD2.HEADER_ID
AND TD1.PRODUCT_HUB_ID != TD2.PRODUCT_HUB_ID

WHERE (SELECT
        COUNT(DISTINCT HEADER_ID) FROM [presentation].[E_COOCCUR_BASE] 
        WHERE PRODUCT_HUB_ID = TD1.PRODUCT_HUB_ID
        AND OCCASION_HUB_ID = TD1.OCCASION_HUB_ID
        AND LOCATION_HUB_ID = TD1.LOCATION_HUB_ID
        AND REVCENTER_HUB_ID = TD1.REVCENTER_HUB_ID
        AND CHANNEL_HUB_ID = TD1.CHANNEL_HUB_ID) > 0

GROUP BY
    TD1.PRODUCT_HUB_ID
    ,TD2.PRODUCT_HUB_ID
    ,TD1.OCCASION_HUB_ID
    ,TD1.LOCATION_HUB_ID
    ,TD1.REVCENTER_HUB_ID
    ,TD1.CHANNEL_HUB_ID',
    2,
    N'Dimension',
    N'[{"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID_COMP", "table_column": "PRODUCT_HUB_ID_COMP", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "globalOccurenceCount", "table_column": "globalOccurenceCount", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "DistinctOrderCount", "table_column": "DistinctOrderCount", "data_type": "varchar(255)", "target_data_type": "[int]"}]',
    0,
    100,
    3,
    30,
    NULL,
    N'PresentationControlApp',
    GETDATE(),
    GETDATE(),
    NULL,
    NULL
);


-- ============================================
-- End of Export
-- ============================================