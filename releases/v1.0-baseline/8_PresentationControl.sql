-- ============================================
-- Presentation Control Export
-- Source: UAT (xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net)
-- Generated: 2026-07-06 15:41:01
-- Total Records: 42
-- Natural Key: step_name
-- ============================================

-- step_name=Channel Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Channel Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'fe981af0-ceca-4607-87f5-f934a26292e8',
        [table_name] = N'D_CHANNEL',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_CHANNEL_NAME", "table_column": "BOTTOM_CHANNEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_CHANNEL_ID", "table_column": "BOTTOM_CHANNEL_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Channel Dimension',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.080',
        [updated_at] = '2026-01-19 19:54:09.080'
    WHERE [step_name] = N'Channel Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('fe981af0-ceca-4607-87f5-f934a26292e8', N'Channel Dimension', N'D_CHANNEL', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_CHANNEL_NAME", "table_column": "BOTTOM_CHANNEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_CHANNEL_ID", "table_column": "BOTTOM_CHANNEL_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Channel Dimension', N'PresentationControlApp', '2026-01-19 19:54:09.080', '2026-01-19 19:54:09.080');
END
GO
-- step_name=CoOccurrence data prep
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'CoOccurrence data prep')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'b450c018-dc78-49e7-83e7-02aedaa1ffd5',
        [table_name] = N'E_COOCCUR_BASE',
        [query_sql] = N'DECLARE @StartDate DATE;
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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "HEADER_ID", "table_column": "HEADER_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = NULL,
        [time_series_target_column] = NULL,
        [description] = NULL,
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.083',
        [updated_at] = '2026-01-19 19:54:09.083'
    WHERE [step_name] = N'CoOccurrence data prep';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('b450c018-dc78-49e7-83e7-02aedaa1ffd5', N'CoOccurrence data prep', N'E_COOCCUR_BASE', N'DECLARE @StartDate DATE;
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

WHERE LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate', 1, N'Dimension', N'[{"query_column": "HEADER_ID", "table_column": "HEADER_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}]', 0, 100, 3, 30, NULL, NULL, NULL, NULL, N'PresentationControlApp', '2026-01-19 19:54:09.083', '2026-01-19 19:54:09.083');
END
GO
-- step_name=Deal Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Deal Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '7df1c48f-702f-48a8-8082-f52e51808937',
        [table_name] = N'D_DEAL',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DEAL_NAME", "table_column": "BOTTOM_DEAL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DEAL_ID", "table_column": "BOTTOM_DEAL_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Deal Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.087',
        [updated_at] = '2026-01-19 19:54:09.087'
    WHERE [step_name] = N'Deal Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('7df1c48f-702f-48a8-8082-f52e51808937', N'Deal Dimension', N'D_DEAL', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DEAL_NAME", "table_column": "BOTTOM_DEAL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DEAL_ID", "table_column": "BOTTOM_DEAL_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Deal Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.087', '2026-01-19 19:54:09.087');
END
GO
-- step_name=Discount Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Discount Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '80f22a38-e512-498b-8440-51a55bf7f6cf',
        [table_name] = N'D_DISCOUNT',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DISCOUNT_NAME", "table_column": "BOTTOM_DISCOUNT_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DISCOUNT_ID", "table_column": "BOTTOM_DISCOUNT_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_VALUE_TYPE", "table_column": "BOTTOM_VALUE_TYPE", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_VALUE", "table_column": "BOTTOM_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Discount Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.090',
        [updated_at] = '2026-01-19 19:54:09.090'
    WHERE [step_name] = N'Discount Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('80f22a38-e512-498b-8440-51a55bf7f6cf', N'Discount Dimension', N'D_DISCOUNT', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DISCOUNT_NAME", "table_column": "BOTTOM_DISCOUNT_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DISCOUNT_ID", "table_column": "BOTTOM_DISCOUNT_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_VALUE_TYPE", "table_column": "BOTTOM_VALUE_TYPE", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_VALUE", "table_column": "BOTTOM_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Discount Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.090', '2026-01-19 19:54:09.090');
END
GO
-- step_name=Distributor Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Distributor Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '6ee44ae0-e6f8-476c-834a-5c46a2e1de11',
        [table_name] = N'D_DISTRIBUTOR',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DISTRIBUTOR_NAME", "table_column": "BOTTOM_DISTRIBUTOR_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DISTRIBUTOR_ID", "table_column": "BOTTOM_DISTRIBUTOR_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Distributor Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.093',
        [updated_at] = '2026-01-19 19:54:09.093'
    WHERE [step_name] = N'Distributor Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('6ee44ae0-e6f8-476c-834a-5c46a2e1de11', N'Distributor Dimension', N'D_DISTRIBUTOR', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_DISTRIBUTOR_NAME", "table_column": "BOTTOM_DISTRIBUTOR_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_DISTRIBUTOR_ID", "table_column": "BOTTOM_DISTRIBUTOR_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Distributor Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.093', '2026-01-19 19:54:09.093');
END
GO
-- step_name=E_INV_DAILY_DETAIL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'E_INV_DAILY_DETAIL')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '77ebfba8-98a2-4cd7-8441-29033dd6705a',
        [table_name] = N'E_INV_DAILY_DETAIL',
        [query_sql] = N'DECLARE @StartDate DATE;

DECLARE @EndDate DATE;

DECLARE @InvItemAvgDays INT;



SET @InvItemAvgDays = 30;



SELECT @StartDate = CAST([ParameterValue] AS DATE) 

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_START'';



SELECT @EndDate = CAST([ParameterValue] AS DATE)

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_END'';

/* TRUNCATE TABLE  [presentation].E_INV_DAILY_DETAIL */


SELECT *  FROM (
SELECT *,ROW_NUMBER() OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE] DESC) AS RN
FROM
(
SELECT [LOCATION_HUB_ID]
      ,[INVITEM_HUB_ID]
      ,[BUSINESS_DATE]
      ,LAG([BUSINESS_DATE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS PREVIOUS_DATE
      ,LAG([STOCK_HOLDING_DAYS],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS STOCK_HOLDING_DAYS

      ,LAG([THEO_STOCK_ON_HAND],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS THEO_STOCK_ON_HAND
      ,LAG([STANDARDISED_UOM],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS STANDARDISED_UOM
      ,LAG([PREVIOUS_COUNT],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS PREVIOUS_COUNT
      ,LAG([ACTUAL_COUNT],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS ACTUAL_COUNT
      ,LAG([MOVEMENT_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS MOVEMENT_QTY
      ,LAG([THEO_USAGE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS THEO_USAGE
      ,LAG([ACTUAL_USAGE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS ACTUAL_USAGE
      ,LAG([VARIANCE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS VARIANCE
      ,LAG([ORDER_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS ORDER_QTY
      ,LAG([SALE_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS SALE_QTY
      ,LAG([PRODUCTION_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS PRODUCTION_QTY
      ,LAG([TRANSFER_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS TRANSFER_QTY
      ,LAG([WASTE_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS WASTE_QTY
      ,LAG([UOM_COST],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS UOM_COST
      ,LAG([DAYS_SINCE_LAST_COUNT],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS DAYS_SINCE_LAST_COUNT
      
  FROM [presentation].[F_INV_DAILY_DETAIL]
  ) SUB 
  WHERE BUSINESS_DATE < @StartDate
  ) SUB_ROW
  WHERE RN = 1',
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BUSINESS_DATE", "table_column": "BUSINESS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "PREVIOUS_DATE", "table_column": "PREVIOUS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "STOCK_HOLDING_DAYS", "table_column": "STOCK_HOLDING_DAYS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_STOCK_ON_HAND", "table_column": "THEO_STOCK_ON_HAND", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "RN", "table_column": "RN", "data_type": "varchar(255)", "target_data_type": "[bigint]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'BUSINESS_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-02-05 01:36:20.797',
        [updated_at] = '2026-03-12 22:28:44.147'
    WHERE [step_name] = N'E_INV_DAILY_DETAIL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('77ebfba8-98a2-4cd7-8441-29033dd6705a', N'E_INV_DAILY_DETAIL', N'E_INV_DAILY_DETAIL', N'DECLARE @StartDate DATE;

DECLARE @EndDate DATE;

DECLARE @InvItemAvgDays INT;



SET @InvItemAvgDays = 30;



SELECT @StartDate = CAST([ParameterValue] AS DATE) 

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_START'';



SELECT @EndDate = CAST([ParameterValue] AS DATE)

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_END'';

/* TRUNCATE TABLE  [presentation].E_INV_DAILY_DETAIL */


SELECT *  FROM (
SELECT *,ROW_NUMBER() OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE] DESC) AS RN
FROM
(
SELECT [LOCATION_HUB_ID]
      ,[INVITEM_HUB_ID]
      ,[BUSINESS_DATE]
      ,LAG([BUSINESS_DATE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS PREVIOUS_DATE
      ,LAG([STOCK_HOLDING_DAYS],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS STOCK_HOLDING_DAYS

      ,LAG([THEO_STOCK_ON_HAND],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS THEO_STOCK_ON_HAND
      ,LAG([STANDARDISED_UOM],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS STANDARDISED_UOM
      ,LAG([PREVIOUS_COUNT],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS PREVIOUS_COUNT
      ,LAG([ACTUAL_COUNT],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS ACTUAL_COUNT
      ,LAG([MOVEMENT_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS MOVEMENT_QTY
      ,LAG([THEO_USAGE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS THEO_USAGE
      ,LAG([ACTUAL_USAGE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS ACTUAL_USAGE
      ,LAG([VARIANCE],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS VARIANCE
      ,LAG([ORDER_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS ORDER_QTY
      ,LAG([SALE_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS SALE_QTY
      ,LAG([PRODUCTION_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS PRODUCTION_QTY
      ,LAG([TRANSFER_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS TRANSFER_QTY
      ,LAG([WASTE_QTY],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS WASTE_QTY
      ,LAG([UOM_COST],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS UOM_COST
      ,LAG([DAYS_SINCE_LAST_COUNT],1,NULL) OVER(PARTITION BY [LOCATION_HUB_ID], [INVITEM_HUB_ID] ORDER BY [BUSINESS_DATE]) AS DAYS_SINCE_LAST_COUNT
      
  FROM [presentation].[F_INV_DAILY_DETAIL]
  ) SUB 
  WHERE BUSINESS_DATE < @StartDate
  ) SUB_ROW
  WHERE RN = 1', 1, N'Fact', N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BUSINESS_DATE", "table_column": "BUSINESS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "PREVIOUS_DATE", "table_column": "PREVIOUS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "STOCK_HOLDING_DAYS", "table_column": "STOCK_HOLDING_DAYS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_STOCK_ON_HAND", "table_column": "THEO_STOCK_ON_HAND", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "RN", "table_column": "RN", "data_type": "varchar(255)", "target_data_type": "[bigint]"}]', 0, 100, 3, 30, NULL, N'STOCKEVENT', N'BUSINESS_DATE', N'None', N'PresentationControlApp', '2026-02-05 01:36:20.797', '2026-03-12 22:28:44.147');
END
GO
-- step_name=F_BOOKING_METRICS_HOUR
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'F_BOOKING_METRICS_HOUR')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '3ebcf61d-5120-4a3e-b344-b46fcc3a610f',
        [table_name] = N'F_BOOKING_METRICS_HOUR',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''BOOKINGREPORT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''BOOKINGREPORT_END'';

SELECT
    H.[HUB_ID] AS [BOOKINGREPORT_HUB_ID],
    S.[BRAND_NAME],
    S.[BRAND_KEY],
    S.[METRIC_HOUR] AS [BOOKING_HOUR],
    S.[METRIC_DATE] AS [BOOKING_DATE],
    S.[TOTAL_BOOKINGS],
    S.[TOTAL_COVERS],
    S.[SESSIONS],
    S.[ACTIVE_USERS]
FROM [datavault].[HUB_BOOKINGREPORT] H
INNER JOIN [datavault].[SAT_BOOKINGREPORT] S
    ON H.[HUB_ID] = S.[HUB_ID]
INNER JOIN [core].[core].[Integrations] IG
    ON S.[SRC] = IG.[SchemaName]
    AND IG.[IntegrationType] = ''BOOKING''
WHERE S.[METRIC_DATE] BETWEEN @StartDate AND @EndDate
    AND S.[CURRENT_FLAG] = 1
    AND S.[IS_DELETED] = 0',
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "BOOKINGREPORT_HUB_ID", "table_column": "BOOKINGREPORT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "BRAND_NAME", "table_column": "BRAND_NAME", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BRAND_KEY", "table_column": "BRAND_KEY", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOOKING_HOUR", "table_column": "BOOKING_HOUR", "data_type": "datetime2(7)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOOKING_DATE", "table_column": "BOOKING_DATE", "data_type": "datetime2(7)", "target_data_type": "[datetime2](7)"}, {"query_column": "TOTAL_BOOKINGS", "table_column": "TOTAL_BOOKINGS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "TOTAL_COVERS", "table_column": "TOTAL_COVERS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "SESSIONS", "table_column": "SESSIONS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "ACTIVE_USERS", "table_column": "ACTIVE_USERS", "data_type": "int", "target_data_type": "[int]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'BOOKINGREPORT',
        [time_series_target_column] = N'BOOKING_DATE',
        [description] = N'Build F_BOOKING_METRICS_HOUR from HUB/SAT_BOOKINGREPORT',
        [created_by] = NULL,
        [created_at] = '2026-04-07 13:52:00.757',
        [updated_at] = '2026-04-07 13:52:00.757'
    WHERE [step_name] = N'F_BOOKING_METRICS_HOUR';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('3ebcf61d-5120-4a3e-b344-b46fcc3a610f', N'F_BOOKING_METRICS_HOUR', N'F_BOOKING_METRICS_HOUR', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''BOOKINGREPORT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''BOOKINGREPORT_END'';

SELECT
    H.[HUB_ID] AS [BOOKINGREPORT_HUB_ID],
    S.[BRAND_NAME],
    S.[BRAND_KEY],
    S.[METRIC_HOUR] AS [BOOKING_HOUR],
    S.[METRIC_DATE] AS [BOOKING_DATE],
    S.[TOTAL_BOOKINGS],
    S.[TOTAL_COVERS],
    S.[SESSIONS],
    S.[ACTIVE_USERS]
FROM [datavault].[HUB_BOOKINGREPORT] H
INNER JOIN [datavault].[SAT_BOOKINGREPORT] S
    ON H.[HUB_ID] = S.[HUB_ID]
INNER JOIN [core].[core].[Integrations] IG
    ON S.[SRC] = IG.[SchemaName]
    AND IG.[IntegrationType] = ''BOOKING''
WHERE S.[METRIC_DATE] BETWEEN @StartDate AND @EndDate
    AND S.[CURRENT_FLAG] = 1
    AND S.[IS_DELETED] = 0', 1, N'Fact', N'[{"query_column": "BOOKINGREPORT_HUB_ID", "table_column": "BOOKINGREPORT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "BRAND_NAME", "table_column": "BRAND_NAME", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BRAND_KEY", "table_column": "BRAND_KEY", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOOKING_HOUR", "table_column": "BOOKING_HOUR", "data_type": "datetime2(7)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOOKING_DATE", "table_column": "BOOKING_DATE", "data_type": "datetime2(7)", "target_data_type": "[datetime2](7)"}, {"query_column": "TOTAL_BOOKINGS", "table_column": "TOTAL_BOOKINGS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "TOTAL_COVERS", "table_column": "TOTAL_COVERS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "SESSIONS", "table_column": "SESSIONS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "ACTIVE_USERS", "table_column": "ACTIVE_USERS", "data_type": "int", "target_data_type": "[int]"}]', 0, 100, 3, 30, NULL, N'BOOKINGREPORT', N'BOOKING_DATE', N'Build F_BOOKING_METRICS_HOUR from HUB/SAT_BOOKINGREPORT', NULL, '2026-04-07 13:52:00.757', '2026-04-07 13:52:00.757');
END
GO
-- step_name=F_LINEITEM_15MIN
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'F_LINEITEM_15MIN')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '131c3a84-f72d-4a12-b958-bfb519973be0',
        [table_name] = N'F_LINEITEM_15MIN',
        [query_sql] = N'DECLARE @StartDate DATE;
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
--AND IG.[IntegrationType] IN (''POS'', ''INVENTORY'')

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
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "SRC", "table_column": "SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "LI_TYPE", "table_column": "LI_TYPE", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "DEAL_HUB_ID", "table_column": "DEAL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DISCOUNT_HUB_ID", "table_column": "DISCOUNT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "EMPLOYEE_HUB_ID", "table_column": "EMPLOYEE_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "MOD_HUB_ID", "table_column": "MOD_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "SVCCHARGE_HUB_ID", "table_column": "SVCCHARGE_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "TAX_HUB_ID", "table_column": "TAX_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "GROSS_VALUE", "table_column": "GROSS_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TAX_VALUE", "table_column": "TAX_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "NET_VALUE", "table_column": "NET_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY", "table_column": "QUANTITY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY_INV", "table_column": "QUANTITY_INV", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_COUNT", "table_column": "ORDER_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "LINEITEM_TIMESTAMP", "table_column": "LINEITEM_TIMESTAMP", "data_type": "varchar(255)", "target_data_type": "[datetime]"}, {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'LINEITEM',
        [time_series_target_column] = N'ORDER_DATE',
        [description] = N'Line item details aggregated to 15 minute segments',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.100',
        [updated_at] = '2026-03-11 01:59:37.367'
    WHERE [step_name] = N'F_LINEITEM_15MIN';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('131c3a84-f72d-4a12-b958-bfb519973be0', N'F_LINEITEM_15MIN', N'F_LINEITEM_15MIN', N'DECLARE @StartDate DATE;
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
--AND IG.[IntegrationType] IN (''POS'', ''INVENTORY'')

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
    ,ISNULL(LNKCH.[CHANNEL_HUB_ID],CONVERT(BINARY(32), -999))', 1, N'Fact', N'[{"query_column": "SRC", "table_column": "SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "LI_TYPE", "table_column": "LI_TYPE", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "DEAL_HUB_ID", "table_column": "DEAL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DISCOUNT_HUB_ID", "table_column": "DISCOUNT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "EMPLOYEE_HUB_ID", "table_column": "EMPLOYEE_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "MOD_HUB_ID", "table_column": "MOD_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "SVCCHARGE_HUB_ID", "table_column": "SVCCHARGE_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "TAX_HUB_ID", "table_column": "TAX_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "GROSS_VALUE", "table_column": "GROSS_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TAX_VALUE", "table_column": "TAX_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "NET_VALUE", "table_column": "NET_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY", "table_column": "QUANTITY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY_INV", "table_column": "QUANTITY_INV", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_COUNT", "table_column": "ORDER_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "LINEITEM_TIMESTAMP", "table_column": "LINEITEM_TIMESTAMP", "data_type": "varchar(255)", "target_data_type": "[datetime]"}, {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}]', 0, 100, 3, 30, NULL, N'LINEITEM', N'ORDER_DATE', N'Line item details aggregated to 15 minute segments', N'PresentationControlApp', '2026-01-19 19:54:09.100', '2026-03-11 01:59:37.367');
END
GO
-- step_name=F_PRE_INV_DAILY_DETAIL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'F_PRE_INV_DAILY_DETAIL')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '5822e678-dcbe-4cfa-998d-df1914bcfcca',
        [table_name] = N'F_PRE_INV_DAILY_DETAIL',
        [query_sql] = N'DECLARE @StartDate DATE;

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

        ) AS last_count,

        STANDARDISED_QTY AS count_qty

    FROM EventsWithCountGroup

    WHERE EVENT_BEHAVIOUR = ''COUNT''

),  



MovementsByGroup AS (

    SELECT 

        LOCATION_HUB_ID,

        INVITEM_HUB_ID,

        [STANDARDISED_UOM],

        count_group,

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

    FROM EventsWithCountGroup

    WHERE EVENT_BEHAVIOUR IN (''+'', ''-'')

    GROUP BY INVITEM_HUB_ID, LOCATION_HUB_ID, [EVENT_TS], [STANDARDISED_UOM],[count_group]

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

    ,c.[EVENT_TS] AS BUSINESS_DATE

    ,c.[STANDARDISED_UOM]

    ,CWP.prev_count_qty AS [PREVIOUS_COUNT]

    ,CWP.count_qty as [ACTUAL_COUNT]

    ,ISNULL(c.MOVEMENT_QTY, 0) AS [MOVEMENT_QTY]

    ,ISNULL(c.MOVEMENT_QTY, 0) AS [THEO_USAGE]

    ,c.[MOVEMENT_QTY] - CWP.prev_count_qty AS [ACTUAL_USAGE]

    ,c.[SALE_QTY] - (CWP.prev_count_qty + ISNULL(c.MOVEMENT_QTY, 0)) AS [VARIANCE]

    ,ISNULL(c.ORDER_QTY, 0) AS ORDER_QTY

    ,ISNULL(c.SALE_QTY, 0) AS SALE_QTY

    ,ISNULL(c.PRODUCTION_QTY, 0) AS PRODUCTION_QTY

    ,ISNULL(c.TRANSFER_QTY, 0) AS TRANSFER_QTY

    ,ISNULL(c.WASTE_QTY, 0) AS WASTE_QTY

    ,COALESCE(ILC.UOM_COST, IC.UOM_COST) AS UOM_COST

    ,DATEDIFF(DAY, CWP.last_count, c.[EVENT_TS]) AS DAYS_SINCE_LAST_COUNT


FROM MovementsByGroup c

LEFT OUTER JOIN CountsWithPrevious CWP
ON CWP.LOCATION_HUB_ID = c.LOCATION_HUB_ID
AND CWP.INVITEM_HUB_ID = c.INVITEM_HUB_ID
AND CWP.EVENT_TS = c.EVENT_TS
AND CWP.count_group = c.count_group


LEFT OUTER JOIN

	InvLocCost ILC

ON c.[INVITEM_HUB_ID] = ILC.[INVITEM_HUB_ID]

AND c.[LOCATION_HUB_ID] = ILC.[LOCATION_HUB_ID]



LEFT OUTER JOIN

	InvCost IC

ON c.[INVITEM_HUB_ID] = IC.[INVITEM_HUB_ID]


ORDER BY  c.[LOCATION_HUB_ID], c.[INVITEM_HUB_ID], c.[EVENT_TS]',
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BUSINESS_DATE", "table_column": "BUSINESS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'BUSINESS_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-02-04 03:21:38.277',
        [updated_at] = '2026-03-12 22:28:44.147'
    WHERE [step_name] = N'F_PRE_INV_DAILY_DETAIL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('5822e678-dcbe-4cfa-998d-df1914bcfcca', N'F_PRE_INV_DAILY_DETAIL', N'F_PRE_INV_DAILY_DETAIL', N'DECLARE @StartDate DATE;

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

        ) AS last_count,

        STANDARDISED_QTY AS count_qty

    FROM EventsWithCountGroup

    WHERE EVENT_BEHAVIOUR = ''COUNT''

),  



MovementsByGroup AS (

    SELECT 

        LOCATION_HUB_ID,

        INVITEM_HUB_ID,

        [STANDARDISED_UOM],

        count_group,

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

    FROM EventsWithCountGroup

    WHERE EVENT_BEHAVIOUR IN (''+'', ''-'')

    GROUP BY INVITEM_HUB_ID, LOCATION_HUB_ID, [EVENT_TS], [STANDARDISED_UOM],[count_group]

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

    ,c.[EVENT_TS] AS BUSINESS_DATE

    ,c.[STANDARDISED_UOM]

    ,CWP.prev_count_qty AS [PREVIOUS_COUNT]

    ,CWP.count_qty as [ACTUAL_COUNT]

    ,ISNULL(c.MOVEMENT_QTY, 0) AS [MOVEMENT_QTY]

    ,ISNULL(c.MOVEMENT_QTY, 0) AS [THEO_USAGE]

    ,c.[MOVEMENT_QTY] - CWP.prev_count_qty AS [ACTUAL_USAGE]

    ,c.[SALE_QTY] - (CWP.prev_count_qty + ISNULL(c.MOVEMENT_QTY, 0)) AS [VARIANCE]

    ,ISNULL(c.ORDER_QTY, 0) AS ORDER_QTY

    ,ISNULL(c.SALE_QTY, 0) AS SALE_QTY

    ,ISNULL(c.PRODUCTION_QTY, 0) AS PRODUCTION_QTY

    ,ISNULL(c.TRANSFER_QTY, 0) AS TRANSFER_QTY

    ,ISNULL(c.WASTE_QTY, 0) AS WASTE_QTY

    ,COALESCE(ILC.UOM_COST, IC.UOM_COST) AS UOM_COST

    ,DATEDIFF(DAY, CWP.last_count, c.[EVENT_TS]) AS DAYS_SINCE_LAST_COUNT


FROM MovementsByGroup c

LEFT OUTER JOIN CountsWithPrevious CWP
ON CWP.LOCATION_HUB_ID = c.LOCATION_HUB_ID
AND CWP.INVITEM_HUB_ID = c.INVITEM_HUB_ID
AND CWP.EVENT_TS = c.EVENT_TS
AND CWP.count_group = c.count_group


LEFT OUTER JOIN

	InvLocCost ILC

ON c.[INVITEM_HUB_ID] = ILC.[INVITEM_HUB_ID]

AND c.[LOCATION_HUB_ID] = ILC.[LOCATION_HUB_ID]



LEFT OUTER JOIN

	InvCost IC

ON c.[INVITEM_HUB_ID] = IC.[INVITEM_HUB_ID]


ORDER BY  c.[LOCATION_HUB_ID], c.[INVITEM_HUB_ID], c.[EVENT_TS]', 1, N'Fact', N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BUSINESS_DATE", "table_column": "BUSINESS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}]', 0, 100, 3, 30, NULL, N'STOCKEVENT', N'BUSINESS_DATE', N'None', N'PresentationControlApp', '2026-02-04 03:21:38.277', '2026-03-12 22:28:44.147');
END
GO
-- step_name=Forecast Actuals Base
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Forecast Actuals Base')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '9da63df9-281c-4ac2-a63d-8b200b5710fa',
        [table_name] = N'FORECAST_ACTUALS_BASE',
        [query_sql] = N'DECLARE @StartDate DATE;
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
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "location_hub_id", "table_column": "location_hub_id", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "product_category", "table_column": "product_category", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "sale_date", "table_column": "sale_date", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "year", "table_column": "year", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "month", "table_column": "month", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day", "table_column": "day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day_of_week", "table_column": "day_of_week", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day_name", "table_column": "day_name", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "week_of_year", "table_column": "week_of_year", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_weekend", "table_column": "is_weekend", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "target_quantity", "table_column": "target_quantity", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "target_revenue", "table_column": "target_revenue", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "target_transactions", "table_column": "target_transactions", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "avg_ticket_size", "table_column": "avg_ticket_size", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "items_per_transaction", "table_column": "items_per_transaction", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_per_item", "table_column": "revenue_per_item", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_ma_7day", "table_column": "qty_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_ma_14day", "table_column": "qty_ma_14day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_ma_28day", "table_column": "qty_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_lag_1day", "table_column": "qty_lag_1day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_lag_7day", "table_column": "qty_lag_7day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_lag_28day", "table_column": "qty_lag_28day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_same_dow_last_week", "table_column": "qty_same_dow_last_week", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_std_28day", "table_column": "qty_std_28day", "data_type": "varchar(255)", "target_data_type": "[float]"}, {"query_column": "revenue_ma_7day", "table_column": "revenue_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_ma_28day", "table_column": "revenue_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_lag_1day", "table_column": "revenue_lag_1day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "revenue_lag_7day", "table_column": "revenue_lag_7day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "txn_ma_7day", "table_column": "txn_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "txn_ma_28day", "table_column": "txn_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "txn_lag_1day", "table_column": "txn_lag_1day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "txn_lag_7day", "table_column": "txn_lag_7day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_holiday", "table_column": "is_holiday", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "holiday_name", "table_column": "holiday_name", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_day_before_holiday", "table_column": "is_day_before_holiday", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_day_after_holiday", "table_column": "is_day_after_holiday", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "temperature_avg", "table_column": "temperature_avg", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "temperature_high", "table_column": "temperature_high", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "temperature_low", "table_column": "temperature_low", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "precipitation_cm", "table_column": "precipitation_cm", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "precipitation_probability", "table_column": "precipitation_probability", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "weather_condition", "table_column": "weather_condition", "data_type": "varchar(255)", "target_data_type": "[nvarchar](50)"}, {"query_column": "is_severe_weather", "table_column": "is_severe_weather", "data_type": "varchar(255)", "target_data_type": "[bit]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'LINEITEM',
        [time_series_target_column] = N'sale_date',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.103',
        [updated_at] = '2026-01-19 19:54:09.103'
    WHERE [step_name] = N'Forecast Actuals Base';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('9da63df9-281c-4ac2-a63d-8b200b5710fa', N'Forecast Actuals Base', N'FORECAST_ACTUALS_BASE', N'DECLARE @StartDate DATE;
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
    
FROM EnrichedData ed', 1, N'Fact', N'[{"query_column": "location_hub_id", "table_column": "location_hub_id", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "product_category", "table_column": "product_category", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "sale_date", "table_column": "sale_date", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "year", "table_column": "year", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "month", "table_column": "month", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day", "table_column": "day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day_of_week", "table_column": "day_of_week", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "day_name", "table_column": "day_name", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "week_of_year", "table_column": "week_of_year", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_weekend", "table_column": "is_weekend", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "target_quantity", "table_column": "target_quantity", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "target_revenue", "table_column": "target_revenue", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "target_transactions", "table_column": "target_transactions", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "avg_ticket_size", "table_column": "avg_ticket_size", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "items_per_transaction", "table_column": "items_per_transaction", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_per_item", "table_column": "revenue_per_item", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_ma_7day", "table_column": "qty_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_ma_14day", "table_column": "qty_ma_14day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_ma_28day", "table_column": "qty_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "qty_lag_1day", "table_column": "qty_lag_1day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_lag_7day", "table_column": "qty_lag_7day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_lag_28day", "table_column": "qty_lag_28day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_same_dow_last_week", "table_column": "qty_same_dow_last_week", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "qty_std_28day", "table_column": "qty_std_28day", "data_type": "varchar(255)", "target_data_type": "[float]"}, {"query_column": "revenue_ma_7day", "table_column": "revenue_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_ma_28day", "table_column": "revenue_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "revenue_lag_1day", "table_column": "revenue_lag_1day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "revenue_lag_7day", "table_column": "revenue_lag_7day", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "txn_ma_7day", "table_column": "txn_ma_7day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "txn_ma_28day", "table_column": "txn_ma_28day", "data_type": "varchar(255)", "target_data_type": "[numeric](38,"}, {"query_column": "txn_lag_1day", "table_column": "txn_lag_1day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "txn_lag_7day", "table_column": "txn_lag_7day", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_holiday", "table_column": "is_holiday", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "holiday_name", "table_column": "holiday_name", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_day_before_holiday", "table_column": "is_day_before_holiday", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "is_day_after_holiday", "table_column": "is_day_after_holiday", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "temperature_avg", "table_column": "temperature_avg", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "temperature_high", "table_column": "temperature_high", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "temperature_low", "table_column": "temperature_low", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "precipitation_cm", "table_column": "precipitation_cm", "data_type": "varchar(255)", "target_data_type": "[decimal](5,"}, {"query_column": "precipitation_probability", "table_column": "precipitation_probability", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "weather_condition", "table_column": "weather_condition", "data_type": "varchar(255)", "target_data_type": "[nvarchar](50)"}, {"query_column": "is_severe_weather", "table_column": "is_severe_weather", "data_type": "varchar(255)", "target_data_type": "[bit]"}]', 0, 100, 3, 30, NULL, N'LINEITEM', N'sale_date', N'None', N'PresentationControlApp', '2026-01-19 19:54:09.103', '2026-01-19 19:54:09.103');
END
GO
-- step_name=Inv Item Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Inv Item Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'cd036d1a-b38b-4a65-a725-74d6e6405dd1',
        [table_name] = N'D_INVITEM',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_INVITEM_NAME", "table_column": "BOTTOM_INVITEM_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_INVITEM_ID", "table_column": "BOTTOM_INVITEM_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Inventory Item Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.107',
        [updated_at] = '2026-01-19 19:54:09.107'
    WHERE [step_name] = N'Inv Item Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('cd036d1a-b38b-4a65-a725-74d6e6405dd1', N'Inv Item Dimension', N'D_INVITEM', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_INVITEM_NAME", "table_column": "BOTTOM_INVITEM_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_INVITEM_ID", "table_column": "BOTTOM_INVITEM_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Inventory Item Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.107', '2026-01-19 19:54:09.107');
END
GO
-- step_name=Inventory Counts by Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Inventory Counts by Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd46543dd-5cf4-460f-b957-b44037eb84e2',
        [table_name] = N'F_INV_COUNTS_DAY',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

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

InvItemCost AS (
    SELECT
        II.[HUB_ID] AS INVITEM_HUB_ID,
        II.[UOM_COST] / NULLIF(CAST(UC.[CONVERSION_FACTOR] AS DECIMAL(18,6)), 0) AS UOM_COST
    FROM [datavault].[SAT_INVITEM] II
    LEFT JOIN [core].[reference].[UOM_CONVERSION] UC
        ON II.[UOM] = UC.[FROM_UOM]
    WHERE II.[CURRENT_FLAG] = 1
      AND II.[UOM_COST] IS NOT NULL
      AND II.[BOTTOM_LEVEL] = 1
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
    ,IIC.UOM_COST AS UOM_COST
    ,DATEDIFF(DAY, c.last_count, [EVENT_TS]) AS DAYS_SINCE_LAST_COUNT

FROM CountsWithPrevious c

LEFT JOIN MovementsByGroup m
    ON c.[INVITEM_HUB_ID] = m.[INVITEM_HUB_ID]
    AND c.LOCATION_HUB_ID = m.LOCATION_HUB_ID
    AND c.count_group = m.count_group

LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]',
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](2)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_QTY", "table_column": "THEO_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'COUNT_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.110',
        [updated_at] = '2026-03-27 16:51:52.307'
    WHERE [step_name] = N'Inventory Counts by Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d46543dd-5cf4-460f-b957-b44037eb84e2', N'Inventory Counts by Day', N'F_INV_COUNTS_DAY', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

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

InvItemCost AS (
    SELECT
        II.[HUB_ID] AS INVITEM_HUB_ID,
        II.[UOM_COST] / NULLIF(CAST(UC.[CONVERSION_FACTOR] AS DECIMAL(18,6)), 0) AS UOM_COST
    FROM [datavault].[SAT_INVITEM] II
    LEFT JOIN [core].[reference].[UOM_CONVERSION] UC
        ON II.[UOM] = UC.[FROM_UOM]
    WHERE II.[CURRENT_FLAG] = 1
      AND II.[UOM_COST] IS NOT NULL
      AND II.[BOTTOM_LEVEL] = 1
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
    ,IIC.UOM_COST AS UOM_COST
    ,DATEDIFF(DAY, c.last_count, [EVENT_TS]) AS DAYS_SINCE_LAST_COUNT

FROM CountsWithPrevious c

LEFT JOIN MovementsByGroup m
    ON c.[INVITEM_HUB_ID] = m.[INVITEM_HUB_ID]
    AND c.LOCATION_HUB_ID = m.LOCATION_HUB_ID
    AND c.count_group = m.count_group

LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]', 1, N'Fact', N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](2)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_QTY", "table_column": "THEO_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}]', 0, 100, 3, 30, NULL, N'STOCKEVENT', N'COUNT_DATE', N'None', N'PresentationControlApp', '2026-01-19 19:54:09.110', '2026-03-27 16:51:52.307');
END
GO
-- step_name=Inventory Source Report
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Inventory Source Report')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '41e9da5e-372b-4bcc-8575-ff926a887d4e',
        [table_name] = N'F_INVREPORT_DAY',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''INVREPORT_START'';
SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''INVREPORT_END'';

SELECT
    LL.LOCATION_HUB_ID AS LOCATION_HUB_ID
    ,LI.[INVITEM_HUB_ID] AS INVITEM_HUB_ID
    ,IR.[REPORTING_DATE] AS REPORTING_DATE
    ,IR.[SALES_QTY] AS SALES_QTY
    ,IR.[SALES_VALUE] AS SALES_VALUE
    ,IR.[ORDER_QTY] AS ORDER_QTY
    ,IR.[ORDER_VALUE] AS ORDER_VALUE
    ,IR.[WASTE_QTY] AS WASTE_QTY
    ,IR.[WASTE_VALUE] AS WASTE_VALUE
    ,IR.[PRODUCTION_QTY] AS PRODUCTION_QTY
    ,IR.[PRODUCTION_VALUE] AS PRODUCTION_VALUE
    ,IR.[TRANSFER_QTY] AS TRANSFER_QTY
    ,IR.[TRANSFER_VALUE] AS TRANSFER_VALUE
    ,IR.[RUNNING_SALES_QTY] AS RUNNING_SALES_QTY
    ,IR.[RUNNING_SALES_VALUE] AS RUNNING_SALES_VALUE
    ,IR.[RUNNING_ORDER_QTY] AS RUNNING_ORDER_QTY
    ,IR.[RUNNING_ORDER_VALUE] AS RUNNING_ORDER_VALUE
    ,IR.[RUNNING_WASTE_QTY] AS RUNNING_WASTE_QTY
    ,IR.[RUNNING_WASTE_VALUE] AS RUNNING_WASTE_VALUE
    ,IR.[RUNNING_PRODUCTION_QTY] AS RUNNING_PRODUCTION_QTY
    ,IR.[RUNNING_PRODUCTION_VALUE] AS RUNNING_PRODUCTION_VALUE
    ,IR.[RUNNING_TRANSFER_QTY] AS RUNNING_TRANSFER_QTY
    ,IR.[RUNNING_TRANSFER_VALUE] AS RUNNING_TRANSFER_VALUE
    ,IR.[LAST_COUNT_QTY] AS LAST_COUNT_QTY
    ,IR.[LAST_COUNT_VALUE] AS LAST_COUNT_VALUE
    ,IR.[VARIANCE_QTY] AS VARIANCE_QTY
    ,IR.[VARIANCE_VALUE] AS VARIANCE_VALUE
    ,IR.[VARIANCE_QTY_INC_COUNT_DAY] AS VAR_INC_COUNT_DAY_QTY
    ,IR.[VARIANCE_VALUE_INC_COUNT_DAY] AS VAR_INC_COUNT_DAY_VALUE
    ,IR.[IS_COUNT_DAY]
    ,IR.[COUNT_GROUP]

FROM
    [datavault].[SAT_INVREPORT] IR
INNER JOIN
    [datavault].[LNK_INVREPORT_LOCATION] LL
ON IR.HUB_ID = LL.INVREPORT_HUB_ID
INNER JOIN
    [datavault].[LNK_INVITEM_INVREPORT] LI
ON IR.HUB_ID = LI.INVREPORT_HUB_ID

WHERE IR.[REPORTING_DATE] BETWEEN @StartDate AND @EndDate
AND IR.[IS_DELETED] = 0
ORDER BY LL.[LOCATION_HUB_ID], LI.[INVITEM_HUB_ID], IR.[REPORTING_DATE]',
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REPORTING_DATE", "table_column": "REPORTING_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "SALES_QTY", "table_column": "SALES_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALES_VALUE", "table_column": "SALES_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_VALUE", "table_column": "ORDER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_VALUE", "table_column": "WASTE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_VALUE", "table_column": "PRODUCTION_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_VALUE", "table_column": "TRANSFER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_SALES_QTY", "table_column": "RUNNING_SALES_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_SALES_VALUE", "table_column": "RUNNING_SALES_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_ORDER_QTY", "table_column": "RUNNING_ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_ORDER_VALUE", "table_column": "RUNNING_ORDER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_WASTE_QTY", "table_column": "RUNNING_WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_WASTE_VALUE", "table_column": "RUNNING_WASTE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_PRODUCTION_QTY", "table_column": "RUNNING_PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_PRODUCTION_VALUE", "table_column": "RUNNING_PRODUCTION_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_TRANSFER_QTY", "table_column": "RUNNING_TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_TRANSFER_VALUE", "table_column": "RUNNING_TRANSFER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "LAST_COUNT_QTY", "table_column": "LAST_COUNT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "LAST_COUNT_VALUE", "table_column": "LAST_COUNT_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE_QTY", "table_column": "VARIANCE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE_VALUE", "table_column": "VARIANCE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VAR_INC_COUNT_DAY_QTY", "table_column": "VAR_INC_COUNT_DAY_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VAR_INC_COUNT_DAY_VALUE", "table_column": "VAR_INC_COUNT_DAY_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "IS_COUNT_DAY", "table_column": "IS_COUNT_DAY", "data_type": "varchar(255)", "target_data_type": "[bigint]"}, {"query_column": "COUNT_GROUP", "table_column": "COUNT_GROUP", "data_type": "varchar(255)", "target_data_type": "[bigint]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'INVREPORT',
        [time_series_target_column] = N'REPORTING_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-02-16 13:23:53.330',
        [updated_at] = '2026-02-16 17:22:43.920'
    WHERE [step_name] = N'Inventory Source Report';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('41e9da5e-372b-4bcc-8575-ff926a887d4e', N'Inventory Source Report', N'F_INVREPORT_DAY', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = CAST([ParameterValue] AS DATE) 
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''INVREPORT_START'';
SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters] 
WHERE [ParameterKey] = ''INVREPORT_END'';

SELECT
    LL.LOCATION_HUB_ID AS LOCATION_HUB_ID
    ,LI.[INVITEM_HUB_ID] AS INVITEM_HUB_ID
    ,IR.[REPORTING_DATE] AS REPORTING_DATE
    ,IR.[SALES_QTY] AS SALES_QTY
    ,IR.[SALES_VALUE] AS SALES_VALUE
    ,IR.[ORDER_QTY] AS ORDER_QTY
    ,IR.[ORDER_VALUE] AS ORDER_VALUE
    ,IR.[WASTE_QTY] AS WASTE_QTY
    ,IR.[WASTE_VALUE] AS WASTE_VALUE
    ,IR.[PRODUCTION_QTY] AS PRODUCTION_QTY
    ,IR.[PRODUCTION_VALUE] AS PRODUCTION_VALUE
    ,IR.[TRANSFER_QTY] AS TRANSFER_QTY
    ,IR.[TRANSFER_VALUE] AS TRANSFER_VALUE
    ,IR.[RUNNING_SALES_QTY] AS RUNNING_SALES_QTY
    ,IR.[RUNNING_SALES_VALUE] AS RUNNING_SALES_VALUE
    ,IR.[RUNNING_ORDER_QTY] AS RUNNING_ORDER_QTY
    ,IR.[RUNNING_ORDER_VALUE] AS RUNNING_ORDER_VALUE
    ,IR.[RUNNING_WASTE_QTY] AS RUNNING_WASTE_QTY
    ,IR.[RUNNING_WASTE_VALUE] AS RUNNING_WASTE_VALUE
    ,IR.[RUNNING_PRODUCTION_QTY] AS RUNNING_PRODUCTION_QTY
    ,IR.[RUNNING_PRODUCTION_VALUE] AS RUNNING_PRODUCTION_VALUE
    ,IR.[RUNNING_TRANSFER_QTY] AS RUNNING_TRANSFER_QTY
    ,IR.[RUNNING_TRANSFER_VALUE] AS RUNNING_TRANSFER_VALUE
    ,IR.[LAST_COUNT_QTY] AS LAST_COUNT_QTY
    ,IR.[LAST_COUNT_VALUE] AS LAST_COUNT_VALUE
    ,IR.[VARIANCE_QTY] AS VARIANCE_QTY
    ,IR.[VARIANCE_VALUE] AS VARIANCE_VALUE
    ,IR.[VARIANCE_QTY_INC_COUNT_DAY] AS VAR_INC_COUNT_DAY_QTY
    ,IR.[VARIANCE_VALUE_INC_COUNT_DAY] AS VAR_INC_COUNT_DAY_VALUE
    ,IR.[IS_COUNT_DAY]
    ,IR.[COUNT_GROUP]

FROM
    [datavault].[SAT_INVREPORT] IR
INNER JOIN
    [datavault].[LNK_INVREPORT_LOCATION] LL
ON IR.HUB_ID = LL.INVREPORT_HUB_ID
INNER JOIN
    [datavault].[LNK_INVITEM_INVREPORT] LI
ON IR.HUB_ID = LI.INVREPORT_HUB_ID

WHERE IR.[REPORTING_DATE] BETWEEN @StartDate AND @EndDate
AND IR.[IS_DELETED] = 0
ORDER BY LL.[LOCATION_HUB_ID], LI.[INVITEM_HUB_ID], IR.[REPORTING_DATE]', 1, N'Fact', N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REPORTING_DATE", "table_column": "REPORTING_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "SALES_QTY", "table_column": "SALES_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALES_VALUE", "table_column": "SALES_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_VALUE", "table_column": "ORDER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_VALUE", "table_column": "WASTE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_VALUE", "table_column": "PRODUCTION_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_VALUE", "table_column": "TRANSFER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_SALES_QTY", "table_column": "RUNNING_SALES_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_SALES_VALUE", "table_column": "RUNNING_SALES_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_ORDER_QTY", "table_column": "RUNNING_ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_ORDER_VALUE", "table_column": "RUNNING_ORDER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_WASTE_QTY", "table_column": "RUNNING_WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_WASTE_VALUE", "table_column": "RUNNING_WASTE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_PRODUCTION_QTY", "table_column": "RUNNING_PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_PRODUCTION_VALUE", "table_column": "RUNNING_PRODUCTION_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_TRANSFER_QTY", "table_column": "RUNNING_TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "RUNNING_TRANSFER_VALUE", "table_column": "RUNNING_TRANSFER_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "LAST_COUNT_QTY", "table_column": "LAST_COUNT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "LAST_COUNT_VALUE", "table_column": "LAST_COUNT_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE_QTY", "table_column": "VARIANCE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE_VALUE", "table_column": "VARIANCE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VAR_INC_COUNT_DAY_QTY", "table_column": "VAR_INC_COUNT_DAY_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VAR_INC_COUNT_DAY_VALUE", "table_column": "VAR_INC_COUNT_DAY_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "IS_COUNT_DAY", "table_column": "IS_COUNT_DAY", "data_type": "varchar(255)", "target_data_type": "[bigint]"}, {"query_column": "COUNT_GROUP", "table_column": "COUNT_GROUP", "data_type": "varchar(255)", "target_data_type": "[bigint]"}]', 0, 100, 3, 30, NULL, N'INVREPORT', N'REPORTING_DATE', N'None', N'PresentationControlApp', '2026-02-16 13:23:53.330', '2026-02-16 17:22:43.920');
END
GO
-- step_name=Inventory Usage by Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Inventory Usage by Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'fbcb305f-a7db-4ae9-81e2-9d9dc4f22b2f',
        [table_name] = N'F_INV_USAGE_DAY',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

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

InvItemCost AS (
    SELECT
        II.[HUB_ID] AS INVITEM_HUB_ID,
        II.[UOM_COST] / NULLIF(CAST(UC.[CONVERSION_FACTOR] AS DECIMAL(18,6)), 0) AS UOM_COST
    FROM [datavault].[SAT_INVITEM] II
    LEFT JOIN [core].[reference].[UOM_CONVERSION] UC
        ON II.[UOM] = UC.[FROM_UOM]
    WHERE II.[CURRENT_FLAG] = 1
      AND II.[UOM_COST] IS NOT NULL
      AND II.[BOTTOM_LEVEL] = 1
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
    ,IIC.UOM_COST AS UOM_COST

FROM MovementsByGroup c

LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]',
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'COUNT_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.113',
        [updated_at] = '2026-03-27 16:51:55.447'
    WHERE [step_name] = N'Inventory Usage by Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('fbcb305f-a7db-4ae9-81e2-9d9dc4f22b2f', N'Inventory Usage by Day', N'F_INV_USAGE_DAY', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

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

InvItemCost AS (
    SELECT
        II.[HUB_ID] AS INVITEM_HUB_ID,
        II.[UOM_COST] / NULLIF(CAST(UC.[CONVERSION_FACTOR] AS DECIMAL(18,6)), 0) AS UOM_COST
    FROM [datavault].[SAT_INVITEM] II
    LEFT JOIN [core].[reference].[UOM_CONVERSION] UC
        ON II.[UOM] = UC.[FROM_UOM]
    WHERE II.[CURRENT_FLAG] = 1
      AND II.[UOM_COST] IS NOT NULL
      AND II.[BOTTOM_LEVEL] = 1
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
    ,IIC.UOM_COST AS UOM_COST

FROM MovementsByGroup c

LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]', 1, N'Fact', N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "COUNT_DATE", "table_column": "COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]', 0, 100, 3, 30, NULL, N'STOCKEVENT', N'COUNT_DATE', N'None', N'PresentationControlApp', '2026-01-19 19:54:09.113', '2026-03-27 16:51:55.447');
END
GO
-- step_name=Location Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Location Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '8bffc93e-86c2-4c26-8be1-9524c2fdb172',
        [table_name] = N'D_LOCATION',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_LOCATION_NAME", "table_column": "BOTTOM_LOCATION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOCATION_ID", "table_column": "BOTTOM_LOCATION_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Location Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.117',
        [updated_at] = '2026-01-19 19:54:09.117'
    WHERE [step_name] = N'Location Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('8bffc93e-86c2-4c26-8be1-9524c2fdb172', N'Location Dimension', N'D_LOCATION', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_LOCATION_NAME", "table_column": "BOTTOM_LOCATION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOCATION_ID", "table_column": "BOTTOM_LOCATION_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Location Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.117', '2026-01-19 19:54:09.117');
END
GO
-- step_name=Mod Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Mod Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '2a727427-3968-4a94-886d-05c9127707e0',
        [table_name] = N'D_MOD',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_MOD_NAME", "table_column": "BOTTOM_MOD_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MOD_ID", "table_column": "BOTTOM_MOD_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Mod Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.120',
        [updated_at] = '2026-01-19 19:54:09.120'
    WHERE [step_name] = N'Mod Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('2a727427-3968-4a94-886d-05c9127707e0', N'Mod Dimension', N'D_MOD', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_MOD_NAME", "table_column": "BOTTOM_MOD_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MOD_ID", "table_column": "BOTTOM_MOD_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Mod Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.120', '2026-01-19 19:54:09.120');
END
GO
-- step_name=Occasion Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Occasion Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '4b2ad418-9023-4536-930d-68999f79e547',
        [table_name] = N'D_OCCASION',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_OCCASION_NAME", "table_column": "BOTTOM_OCCASION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_OCCASSION_ID", "table_column": "BOTTOM_OCCASSION_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Occasion Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.123',
        [updated_at] = '2026-01-19 19:54:09.123'
    WHERE [step_name] = N'Occasion Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('4b2ad418-9023-4536-930d-68999f79e547', N'Occasion Dimension', N'D_OCCASION', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_OCCASION_NAME", "table_column": "BOTTOM_OCCASION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_OCCASSION_ID", "table_column": "BOTTOM_OCCASSION_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Occasion Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.123', '2026-01-19 19:54:09.123');
END
GO
-- step_name=Product Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Product Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '17be63cd-816d-4661-a5d1-9e96a2d10f27',
        [table_name] = N'D_PRODUCT',
        [query_sql] = N'WITH HierarchyPath AS (
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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "BOTTOM_PRODUCT_NAME", "table_column": "BOTTOM_PRODUCT_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_PRODUCT_ID", "table_column": "BOTTOM_PRODUCT_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[varchar](max)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[int]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Product Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.127',
        [updated_at] = '2026-01-19 19:54:09.127'
    WHERE [step_name] = N'Product Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('17be63cd-816d-4661-a5d1-9e96a2d10f27', N'Product Dimension', N'D_PRODUCT', N'WITH HierarchyPath AS (
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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "BOTTOM_PRODUCT_NAME", "table_column": "BOTTOM_PRODUCT_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_PRODUCT_ID", "table_column": "BOTTOM_PRODUCT_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[varchar](max)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[int]"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Product Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.127', '2026-01-19 19:54:09.127');
END
GO
-- step_name=Product Margins by Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Product Margins by Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '109353e7-685e-4d0f-8840-26a17af70df6',
        [table_name] = N'F_PRODUCT_MARGIN_DAY',
        [query_sql] = N'DECLARE @StartDate DATE;
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
--AND IG.[IntegrationType] IN (''POS'', ''INVENTORY'')

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
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DEAL_HUB_ID", "table_column": "DEAL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DISCOUNT_HUB_ID", "table_column": "DISCOUNT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "DEAL_FLAG", "table_column": "DEAL_FLAG", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "NET_VALUE", "table_column": "NET_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY", "table_column": "QUANTITY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_COST", "table_column": "AVG_NET_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_PRICE_CHARGED", "table_column": "AVG_NET_PRICE_CHARGED", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_PRICE", "table_column": "AVG_NET_PRICE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PROFIT", "table_column": "PROFIT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PROFIT_LESS_DISCOUNT", "table_column": "PROFIT_LESS_DISCOUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'LINEITEM',
        [time_series_target_column] = N'ORDER_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.130',
        [updated_at] = '2026-03-11 01:59:37.370'
    WHERE [step_name] = N'Product Margins by Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('109353e7-685e-4d0f-8840-26a17af70df6', N'Product Margins by Day', N'F_PRODUCT_MARGIN_DAY', N'DECLARE @StartDate DATE;
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
--AND IG.[IntegrationType] IN (''POS'', ''INVENTORY'')

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
    ,F.[DEAL_FLAG]', 1, N'Fact', N'[{"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DEAL_HUB_ID", "table_column": "DEAL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "DISCOUNT_HUB_ID", "table_column": "DISCOUNT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "DEAL_FLAG", "table_column": "DEAL_FLAG", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "NET_VALUE", "table_column": "NET_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "QUANTITY", "table_column": "QUANTITY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_COST", "table_column": "AVG_NET_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_PRICE_CHARGED", "table_column": "AVG_NET_PRICE_CHARGED", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "AVG_NET_PRICE", "table_column": "AVG_NET_PRICE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PROFIT", "table_column": "PROFIT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PROFIT_LESS_DISCOUNT", "table_column": "PROFIT_LESS_DISCOUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]', 0, 100, 3, 30, NULL, N'LINEITEM', N'ORDER_DATE', N'None', N'PresentationControlApp', '2026-01-19 19:54:09.130', '2026-03-11 01:59:37.370');
END
GO
-- step_name=Purchases by Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Purchases by Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '4a457b05-87d2-4ead-b826-b1320be1cc3a',
        [table_name] = N'F_PURCHASES_DAY',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_END'';

WITH OrderLines AS (
    SELECT
        LIS.INVITEM_HUB_ID,
        LIS.STOCKORDER_HUB_ID,
        SL.QUANTITY,
        SL.PRICE,
        SL.ESTIMATED_COST,
        SL.CASE_SIZE,
        SL.CASE_PRICE,
        ROW_NUMBER() OVER(PARTITION BY LIS.LNK_ID ORDER BY SL.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_INVITEM_STOCKORDER] LIS
    INNER JOIN [datavault].[SAT_LNK_INVITEM_STOCKORDER] SL
        ON LIS.LNK_ID = SL.LNK_ID
),
Orders AS (
    SELECT
        SO.HUB_ID,
        SO.ORDER_DATE,
        SO.DELIVERY_DATE,
        SO.ORDER_STATUS,
        SO.ORDER_INFO
    FROM [datavault].[SAT_STOCKORDER] SO
    WHERE SO.CURRENT_FLAG = 1
      AND SO.ORDER_DATE BETWEEN @StartDate AND @EndDate
),
OrderSupplier AS (
    SELECT
        DSS.STOCKORDER_HUB_ID,
        DSS.SUPPLIER_HUB_ID
    FROM [datavault].[LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER] DSS
),
OrderLocation AS (
    SELECT
        LSESO.STOCKORDER_HUB_ID,
        LLSE.LOCATION_HUB_ID,
        ROW_NUMBER() OVER(PARTITION BY LSESO.STOCKORDER_HUB_ID
                          ORDER BY LLSE.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_STOCKEVENT_STOCKORDER] LSESO
    INNER JOIN [datavault].[LNK_LOCATION_STOCKEVENT] LLSE
        ON LSESO.STOCKEVENT_HUB_ID = LLSE.STOCKEVENT_HUB_ID
)

SELECT
    OL.INVITEM_HUB_ID,
    ISNULL(OS.SUPPLIER_HUB_ID, CONVERT(BINARY(32), -999)) AS SUPPLIER_HUB_ID,
    ISNULL(OLOC.LOCATION_HUB_ID, CONVERT(BINARY(32), -999)) AS LOCATION_HUB_ID,
    OL.STOCKORDER_HUB_ID,
    O.ORDER_DATE,
    O.DELIVERY_DATE,
    O.ORDER_STATUS,
    OL.PRICE AS UNIT_PRICE,
    OL.ESTIMATED_COST AS UNIT_COST,
    OL.QUANTITY AS ORDER_QTY,
    OL.QUANTITY * OL.PRICE AS LINE_TOTAL,
    OL.CASE_SIZE AS PACK_SIZE,
    OL.CASE_PRICE AS PACK_PRICE,
    O.ORDER_INFO AS ORDER_REFERENCE

FROM OrderLines OL
INNER JOIN Orders O
    ON OL.STOCKORDER_HUB_ID = O.HUB_ID
LEFT JOIN OrderSupplier OS
    ON OL.STOCKORDER_HUB_ID = OS.STOCKORDER_HUB_ID
LEFT JOIN OrderLocation OLOC
    ON OL.STOCKORDER_HUB_ID = OLOC.STOCKORDER_HUB_ID
    AND OLOC.rn = 1

WHERE OL.rn = 1',
        [tier] = 1,
        [table_type] = N'Fact',
        [column_mappings] = N'[
        {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "SUPPLIER_HUB_ID", "table_column": "SUPPLIER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "STOCKORDER_HUB_ID", "table_column": "STOCKORDER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "datetime2(7)"},
        {"query_column": "DELIVERY_DATE", "table_column": "DELIVERY_DATE", "data_type": "datetime2(7)"},
        {"query_column": "ORDER_STATUS", "table_column": "ORDER_STATUS", "data_type": "nvarchar(255)"},
        {"query_column": "UNIT_PRICE", "table_column": "UNIT_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "UNIT_COST", "table_column": "UNIT_COST", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "decimal(38,6)"},
        {"query_column": "LINE_TOTAL", "table_column": "LINE_TOTAL", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_SIZE", "table_column": "PACK_SIZE", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_PRICE", "table_column": "PACK_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_REFERENCE", "table_column": "ORDER_REFERENCE", "data_type": "nvarchar(255)"}
    ]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'ORDER_DATE',
        [description] = N'Purchase order line items. Joins INVITEM_STOCKORDER link satellite (qty, price, cost) with STOCKORDER dates/status, SUPPLIER via ternary link, and LOCATION via delivery event chain. Filtered by STOCKEVENT_START/END date range.',
        [created_by] = N'Claude',
        [created_at] = '2026-03-11 01:59:37.260',
        [updated_at] = '2026-03-11 01:59:37.260'
    WHERE [step_name] = N'Purchases by Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('4a457b05-87d2-4ead-b826-b1320be1cc3a', N'Purchases by Day', N'F_PURCHASES_DAY', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''STOCKEVENT_END'';

WITH OrderLines AS (
    SELECT
        LIS.INVITEM_HUB_ID,
        LIS.STOCKORDER_HUB_ID,
        SL.QUANTITY,
        SL.PRICE,
        SL.ESTIMATED_COST,
        SL.CASE_SIZE,
        SL.CASE_PRICE,
        ROW_NUMBER() OVER(PARTITION BY LIS.LNK_ID ORDER BY SL.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_INVITEM_STOCKORDER] LIS
    INNER JOIN [datavault].[SAT_LNK_INVITEM_STOCKORDER] SL
        ON LIS.LNK_ID = SL.LNK_ID
),
Orders AS (
    SELECT
        SO.HUB_ID,
        SO.ORDER_DATE,
        SO.DELIVERY_DATE,
        SO.ORDER_STATUS,
        SO.ORDER_INFO
    FROM [datavault].[SAT_STOCKORDER] SO
    WHERE SO.CURRENT_FLAG = 1
      AND SO.ORDER_DATE BETWEEN @StartDate AND @EndDate
),
OrderSupplier AS (
    SELECT
        DSS.STOCKORDER_HUB_ID,
        DSS.SUPPLIER_HUB_ID
    FROM [datavault].[LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER] DSS
),
OrderLocation AS (
    SELECT
        LSESO.STOCKORDER_HUB_ID,
        LLSE.LOCATION_HUB_ID,
        ROW_NUMBER() OVER(PARTITION BY LSESO.STOCKORDER_HUB_ID
                          ORDER BY LLSE.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_STOCKEVENT_STOCKORDER] LSESO
    INNER JOIN [datavault].[LNK_LOCATION_STOCKEVENT] LLSE
        ON LSESO.STOCKEVENT_HUB_ID = LLSE.STOCKEVENT_HUB_ID
)

SELECT
    OL.INVITEM_HUB_ID,
    ISNULL(OS.SUPPLIER_HUB_ID, CONVERT(BINARY(32), -999)) AS SUPPLIER_HUB_ID,
    ISNULL(OLOC.LOCATION_HUB_ID, CONVERT(BINARY(32), -999)) AS LOCATION_HUB_ID,
    OL.STOCKORDER_HUB_ID,
    O.ORDER_DATE,
    O.DELIVERY_DATE,
    O.ORDER_STATUS,
    OL.PRICE AS UNIT_PRICE,
    OL.ESTIMATED_COST AS UNIT_COST,
    OL.QUANTITY AS ORDER_QTY,
    OL.QUANTITY * OL.PRICE AS LINE_TOTAL,
    OL.CASE_SIZE AS PACK_SIZE,
    OL.CASE_PRICE AS PACK_PRICE,
    O.ORDER_INFO AS ORDER_REFERENCE

FROM OrderLines OL
INNER JOIN Orders O
    ON OL.STOCKORDER_HUB_ID = O.HUB_ID
LEFT JOIN OrderSupplier OS
    ON OL.STOCKORDER_HUB_ID = OS.STOCKORDER_HUB_ID
LEFT JOIN OrderLocation OLOC
    ON OL.STOCKORDER_HUB_ID = OLOC.STOCKORDER_HUB_ID
    AND OLOC.rn = 1

WHERE OL.rn = 1', 1, N'Fact', N'[
        {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "SUPPLIER_HUB_ID", "table_column": "SUPPLIER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "STOCKORDER_HUB_ID", "table_column": "STOCKORDER_HUB_ID", "data_type": "binary(32)"},
        {"query_column": "ORDER_DATE", "table_column": "ORDER_DATE", "data_type": "datetime2(7)"},
        {"query_column": "DELIVERY_DATE", "table_column": "DELIVERY_DATE", "data_type": "datetime2(7)"},
        {"query_column": "ORDER_STATUS", "table_column": "ORDER_STATUS", "data_type": "nvarchar(255)"},
        {"query_column": "UNIT_PRICE", "table_column": "UNIT_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "UNIT_COST", "table_column": "UNIT_COST", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "decimal(38,6)"},
        {"query_column": "LINE_TOTAL", "table_column": "LINE_TOTAL", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_SIZE", "table_column": "PACK_SIZE", "data_type": "decimal(38,6)"},
        {"query_column": "PACK_PRICE", "table_column": "PACK_PRICE", "data_type": "decimal(38,6)"},
        {"query_column": "ORDER_REFERENCE", "table_column": "ORDER_REFERENCE", "data_type": "nvarchar(255)"}
    ]', 0, 100, 3, 30, NULL, N'STOCKEVENT', N'ORDER_DATE', N'Purchase order line items. Joins INVITEM_STOCKORDER link satellite (qty, price, cost) with STOCKORDER dates/status, SUPPLIER via ternary link, and LOCATION via delivery event chain. Filtered by STOCKEVENT_START/END date range.', N'Claude', '2026-03-11 01:59:37.260', '2026-03-11 01:59:37.260');
END
GO
-- step_name=Question Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Question Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'a3f7c2d1-4b8e-4a2f-9c5d-6e1b3a7f8d20',
        [table_name] = N'D_QUESTION',
        [query_sql] = N'-- D_QUESTION dimension build
-- Hierarchy: BOTTOM (leaf) -> MIDDLE (scale) -> TOP (section)
-- Unparented leaves: TOP=''Other'', MIDDLE=''Unknown''
-- Direct-to-TOP leaves (e.g. ''Any extra thoughts ?''): MIDDLE=''Unknown''

SELECT
    -- Bottom level columns
    SQ_LEAF.HUB_ID                                                    AS BOTTOM_HUB_ID,
    SQ_LEAF.SRC                                                       AS BOTTOM_SRC,
    SQ_LEAF.LOAD_TS                                                    AS BOTTOM_LOAD_TS,
    SQ_LEAF.EFFECTIVEFROM                                             AS BOTTOM_EFFECTIVEFROM,
    SQ_LEAF.EFFECTIVETO                                               AS BOTTOM_EFFECTIVETO,
    CAST(SQ_LEAF.CURRENT_FLAG AS INT)                                 AS BOTTOM_CURRENT_FLAG,
    CAST(SQ_LEAF.IS_DELETED AS INT)                                   AS BOTTOM_IS_DELETED,
    SQ_LEAF.QUESTION                                                  AS BOTTOM_QUESTION_NAME,
    SQ_LEAF.QUESTION_ID                                               AS BOTTOM_QUESTION_ID,
    SQ_LEAF.LEVEL_NAME                                                AS BOTTOM_LEVEL_NAME,
    SQ_LEAF.MICROSERVICE_ID                                           AS BOTTOM_MICROSERVICE_ID,
    SQ_LEAF.MICROSERVICE_NAME                                         AS BOTTOM_MICROSERVICE_NAME,

    -- Middle level columns
    -- When parent is MIDDLE: use MIDDLE hub/name/level
    -- When parent is TOP or NULL: use sentinel/Unknown
    ISNULL(SQ_MID.HUB_ID, CONVERT(BINARY(32), -999))                  AS MIDDLE_1_HUB_ID,
    ISNULL(SQ_MID.QUESTION, N''Unknown'')                             AS MIDDLE_1_QUESTION_NAME,
    ISNULL(SQ_MID.LEVEL_NAME, N''Unknown'')                           AS MIDDLE_1_LEVEL_NAME,

    -- Top level columns
    -- When parent is MIDDLE: look up TOP via MIDDLE.PARENT_ID
    -- When parent is TOP directly: use that TOP
    -- When no parent: sentinel/Other
    ISNULL(SQ_TOP.HUB_ID, CONVERT(BINARY(32), -999))                  AS TOP_HUB_ID,
    ISNULL(SQ_TOP.QUESTION, N''Other'')                               AS TOP_QUESTION_NAME,
    ISNULL(SQ_TOP.LEVEL_NAME, N''QUESTION TOP'')                      AS TOP_LEVEL_NAME,

    -- Hierarchy path and depth
    CASE
        WHEN SQ_MID.HUB_ID IS NOT NULL
            THEN SQ_TOP.QUESTION_ID + ''->'' + SQ_MID.QUESTION_ID + ''->'' + SQ_LEAF.QUESTION_ID
        WHEN SQ_LEAF.PARENT_ID IS NOT NULL AND SQ_TOP.HUB_ID IS NOT NULL
            THEN SQ_TOP.QUESTION_ID + ''->'' + SQ_LEAF.QUESTION_ID
        ELSE SQ_LEAF.QUESTION_ID
    END                                                                AS HIERARCHY_PATH,
    CASE
        WHEN SQ_MID.HUB_ID IS NOT NULL THEN CAST(2 AS DECIMAL(38,10))
        WHEN SQ_LEAF.PARENT_ID IS NOT NULL AND SQ_TOP.HUB_ID IS NOT NULL THEN CAST(1 AS DECIMAL(38,10))
        ELSE CAST(0 AS DECIMAL(38,10))
    END                                                                AS TOTAL_LEVELS

FROM [datavault].[SAT_QUESTION] SQ_LEAF

-- Step 1: Find the direct parent (could be MIDDLE or TOP)
LEFT JOIN [datavault].[SAT_QUESTION] SQ_PAR
    ON SQ_LEAF.PARENT_ID = SQ_PAR.QUESTION_ID
    AND SQ_PAR.CURRENT_FLAG = 1

-- Step 2: If parent is MIDDLE, it IS the middle node
LEFT JOIN [datavault].[SAT_QUESTION] SQ_MID
    ON SQ_PAR.QUESTION_ID = SQ_MID.QUESTION_ID
    AND SQ_MID.LEVEL_NAME = ''QUESTION MIDDLE''
    AND SQ_MID.CURRENT_FLAG = 1

-- Step 3: Find the TOP node
-- Case A: parent was MIDDLE -> TOP is MIDDLE.PARENT_ID
-- Case B: parent was TOP directly -> TOP is the parent itself
LEFT JOIN [datavault].[SAT_QUESTION] SQ_TOP
    ON SQ_TOP.CURRENT_FLAG = 1
    AND SQ_TOP.LEVEL_NAME = ''QUESTION TOP''
    AND SQ_TOP.QUESTION_ID = CASE
        WHEN SQ_MID.QUESTION_ID IS NOT NULL THEN SQ_MID.PARENT_ID
        WHEN SQ_PAR.LEVEL_NAME = ''QUESTION TOP'' THEN SQ_PAR.QUESTION_ID
        ELSE NULL
    END

WHERE SQ_LEAF.BOTTOM_LEVEL = 1
  AND SQ_LEAF.CURRENT_FLAG = 1
  AND SQ_LEAF.IS_DELETED = 0

UNION ALL

-- Sentinel row for null-safe dimension joins
SELECT
    CONVERT(BINARY(32), -999)          AS BOTTOM_HUB_ID,
    N''datavault''                      AS BOTTOM_SRC,
    CAST(N''2000-01-01'' AS DATETIME2)  AS BOTTOM_LOAD_TS,
    CAST(N''2000-01-01'' AS DATETIME2)  AS BOTTOM_EFFECTIVEFROM,
    NULL                                AS BOTTOM_EFFECTIVETO,
    1                                   AS BOTTOM_CURRENT_FLAG,
    0                                   AS BOTTOM_IS_DELETED,
    N''Unknown''                        AS BOTTOM_QUESTION_NAME,
    NULL                                AS BOTTOM_QUESTION_ID,
    N''Unknown''                        AS BOTTOM_LEVEL_NAME,
    NULL                                AS BOTTOM_MICROSERVICE_ID,
    NULL                                AS BOTTOM_MICROSERVICE_NAME,
    CONVERT(BINARY(32), -999)          AS MIDDLE_1_HUB_ID,
    N''Unknown''                        AS MIDDLE_1_QUESTION_NAME,
    N''Unknown''                        AS MIDDLE_1_LEVEL_NAME,
    CONVERT(BINARY(32), -999)          AS TOP_HUB_ID,
    N''Unknown''                        AS TOP_QUESTION_NAME,
    N''Unknown''                        AS TOP_LEVEL_NAME,
    NULL                                AS HIERARCHY_PATH,
    CAST(1 AS DECIMAL(38,10))          AS TOTAL_LEVELS',
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_QUESTION_NAME", "table_column": "BOTTOM_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](500)"}, {"query_column": "BOTTOM_QUESTION_ID", "table_column": "BOTTOM_QUESTION_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_HUB_ID", "table_column": "MIDDLE_1_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "MIDDLE_1_QUESTION_NAME", "table_column": "MIDDLE_1_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_HUB_ID", "table_column": "TOP_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "TOP_QUESTION_NAME", "table_column": "TOP_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](MAX)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Question Dimension',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-11 01:59:53.610',
        [updated_at] = '2026-03-11 01:59:53.610'
    WHERE [step_name] = N'Question Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('a3f7c2d1-4b8e-4a2f-9c5d-6e1b3a7f8d20', N'Question Dimension', N'D_QUESTION', N'-- D_QUESTION dimension build
-- Hierarchy: BOTTOM (leaf) -> MIDDLE (scale) -> TOP (section)
-- Unparented leaves: TOP=''Other'', MIDDLE=''Unknown''
-- Direct-to-TOP leaves (e.g. ''Any extra thoughts ?''): MIDDLE=''Unknown''

SELECT
    -- Bottom level columns
    SQ_LEAF.HUB_ID                                                    AS BOTTOM_HUB_ID,
    SQ_LEAF.SRC                                                       AS BOTTOM_SRC,
    SQ_LEAF.LOAD_TS                                                    AS BOTTOM_LOAD_TS,
    SQ_LEAF.EFFECTIVEFROM                                             AS BOTTOM_EFFECTIVEFROM,
    SQ_LEAF.EFFECTIVETO                                               AS BOTTOM_EFFECTIVETO,
    CAST(SQ_LEAF.CURRENT_FLAG AS INT)                                 AS BOTTOM_CURRENT_FLAG,
    CAST(SQ_LEAF.IS_DELETED AS INT)                                   AS BOTTOM_IS_DELETED,
    SQ_LEAF.QUESTION                                                  AS BOTTOM_QUESTION_NAME,
    SQ_LEAF.QUESTION_ID                                               AS BOTTOM_QUESTION_ID,
    SQ_LEAF.LEVEL_NAME                                                AS BOTTOM_LEVEL_NAME,
    SQ_LEAF.MICROSERVICE_ID                                           AS BOTTOM_MICROSERVICE_ID,
    SQ_LEAF.MICROSERVICE_NAME                                         AS BOTTOM_MICROSERVICE_NAME,

    -- Middle level columns
    -- When parent is MIDDLE: use MIDDLE hub/name/level
    -- When parent is TOP or NULL: use sentinel/Unknown
    ISNULL(SQ_MID.HUB_ID, CONVERT(BINARY(32), -999))                  AS MIDDLE_1_HUB_ID,
    ISNULL(SQ_MID.QUESTION, N''Unknown'')                             AS MIDDLE_1_QUESTION_NAME,
    ISNULL(SQ_MID.LEVEL_NAME, N''Unknown'')                           AS MIDDLE_1_LEVEL_NAME,

    -- Top level columns
    -- When parent is MIDDLE: look up TOP via MIDDLE.PARENT_ID
    -- When parent is TOP directly: use that TOP
    -- When no parent: sentinel/Other
    ISNULL(SQ_TOP.HUB_ID, CONVERT(BINARY(32), -999))                  AS TOP_HUB_ID,
    ISNULL(SQ_TOP.QUESTION, N''Other'')                               AS TOP_QUESTION_NAME,
    ISNULL(SQ_TOP.LEVEL_NAME, N''QUESTION TOP'')                      AS TOP_LEVEL_NAME,

    -- Hierarchy path and depth
    CASE
        WHEN SQ_MID.HUB_ID IS NOT NULL
            THEN SQ_TOP.QUESTION_ID + ''->'' + SQ_MID.QUESTION_ID + ''->'' + SQ_LEAF.QUESTION_ID
        WHEN SQ_LEAF.PARENT_ID IS NOT NULL AND SQ_TOP.HUB_ID IS NOT NULL
            THEN SQ_TOP.QUESTION_ID + ''->'' + SQ_LEAF.QUESTION_ID
        ELSE SQ_LEAF.QUESTION_ID
    END                                                                AS HIERARCHY_PATH,
    CASE
        WHEN SQ_MID.HUB_ID IS NOT NULL THEN CAST(2 AS DECIMAL(38,10))
        WHEN SQ_LEAF.PARENT_ID IS NOT NULL AND SQ_TOP.HUB_ID IS NOT NULL THEN CAST(1 AS DECIMAL(38,10))
        ELSE CAST(0 AS DECIMAL(38,10))
    END                                                                AS TOTAL_LEVELS

FROM [datavault].[SAT_QUESTION] SQ_LEAF

-- Step 1: Find the direct parent (could be MIDDLE or TOP)
LEFT JOIN [datavault].[SAT_QUESTION] SQ_PAR
    ON SQ_LEAF.PARENT_ID = SQ_PAR.QUESTION_ID
    AND SQ_PAR.CURRENT_FLAG = 1

-- Step 2: If parent is MIDDLE, it IS the middle node
LEFT JOIN [datavault].[SAT_QUESTION] SQ_MID
    ON SQ_PAR.QUESTION_ID = SQ_MID.QUESTION_ID
    AND SQ_MID.LEVEL_NAME = ''QUESTION MIDDLE''
    AND SQ_MID.CURRENT_FLAG = 1

-- Step 3: Find the TOP node
-- Case A: parent was MIDDLE -> TOP is MIDDLE.PARENT_ID
-- Case B: parent was TOP directly -> TOP is the parent itself
LEFT JOIN [datavault].[SAT_QUESTION] SQ_TOP
    ON SQ_TOP.CURRENT_FLAG = 1
    AND SQ_TOP.LEVEL_NAME = ''QUESTION TOP''
    AND SQ_TOP.QUESTION_ID = CASE
        WHEN SQ_MID.QUESTION_ID IS NOT NULL THEN SQ_MID.PARENT_ID
        WHEN SQ_PAR.LEVEL_NAME = ''QUESTION TOP'' THEN SQ_PAR.QUESTION_ID
        ELSE NULL
    END

WHERE SQ_LEAF.BOTTOM_LEVEL = 1
  AND SQ_LEAF.CURRENT_FLAG = 1
  AND SQ_LEAF.IS_DELETED = 0

UNION ALL

-- Sentinel row for null-safe dimension joins
SELECT
    CONVERT(BINARY(32), -999)          AS BOTTOM_HUB_ID,
    N''datavault''                      AS BOTTOM_SRC,
    CAST(N''2000-01-01'' AS DATETIME2)  AS BOTTOM_LOAD_TS,
    CAST(N''2000-01-01'' AS DATETIME2)  AS BOTTOM_EFFECTIVEFROM,
    NULL                                AS BOTTOM_EFFECTIVETO,
    1                                   AS BOTTOM_CURRENT_FLAG,
    0                                   AS BOTTOM_IS_DELETED,
    N''Unknown''                        AS BOTTOM_QUESTION_NAME,
    NULL                                AS BOTTOM_QUESTION_ID,
    N''Unknown''                        AS BOTTOM_LEVEL_NAME,
    NULL                                AS BOTTOM_MICROSERVICE_ID,
    NULL                                AS BOTTOM_MICROSERVICE_NAME,
    CONVERT(BINARY(32), -999)          AS MIDDLE_1_HUB_ID,
    N''Unknown''                        AS MIDDLE_1_QUESTION_NAME,
    N''Unknown''                        AS MIDDLE_1_LEVEL_NAME,
    CONVERT(BINARY(32), -999)          AS TOP_HUB_ID,
    N''Unknown''                        AS TOP_QUESTION_NAME,
    N''Unknown''                        AS TOP_LEVEL_NAME,
    NULL                                AS HIERARCHY_PATH,
    CAST(1 AS DECIMAL(38,10))          AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_QUESTION_NAME", "table_column": "BOTTOM_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](500)"}, {"query_column": "BOTTOM_QUESTION_ID", "table_column": "BOTTOM_QUESTION_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_HUB_ID", "table_column": "MIDDLE_1_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "MIDDLE_1_QUESTION_NAME", "table_column": "MIDDLE_1_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_HUB_ID", "table_column": "TOP_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "TOP_QUESTION_NAME", "table_column": "TOP_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](MAX)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Question Dimension', N'PresentationControlApp', '2026-03-11 01:59:53.610', '2026-03-11 01:59:53.610');
END
GO
-- step_name=Revenue Center Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Revenue Center Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd93bf54a-3272-4b16-8f4b-c3c5ff9a0043',
        [table_name] = N'D_REVCENTER',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_NAME", "table_column": "BOTTOM_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ID", "table_column": "BOTTOM_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = NULL,
        [time_series_target_column] = NULL,
        [description] = NULL,
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.133',
        [updated_at] = '2026-01-19 19:54:09.133'
    WHERE [step_name] = N'Revenue Center Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d93bf54a-3272-4b16-8f4b-c3c5ff9a0043', N'Revenue Center Dimension', N'D_REVCENTER', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_NAME", "table_column": "BOTTOM_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ID", "table_column": "BOTTOM_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]', 0, 100, 3, 30, NULL, NULL, NULL, NULL, N'PresentationControlApp', '2026-01-19 19:54:09.133', '2026-01-19 19:54:09.133');
END
GO
-- step_name=Service Charge Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Service Charge Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '6e009496-3189-4eb9-b414-ffc42ae73fa6',
        [table_name] = N'D_SERVICECHARGE',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_SVCCHARGE_NAME", "table_column": "BOTTOM_SVCCHARGE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_SVC_ID", "table_column": "BOTTOM_SVC_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Service Charge Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.137',
        [updated_at] = '2026-01-19 19:54:09.137'
    WHERE [step_name] = N'Service Charge Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('6e009496-3189-4eb9-b414-ffc42ae73fa6', N'Service Charge Dimension', N'D_SERVICECHARGE', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_SVCCHARGE_NAME", "table_column": "BOTTOM_SVCCHARGE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_SVC_ID", "table_column": "BOTTOM_SVC_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Service Charge Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.137', '2026-01-19 19:54:09.137');
END
GO
-- step_name=Supplier Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Supplier Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '1ae654cb-8d44-4668-bb76-62b46c9a6998',
        [table_name] = N'D_SUPPLIER',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_SUPPLIER_NAME", "table_column": "BOTTOM_SUPPLIER_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_SUPPLIER_ID", "table_column": "BOTTOM_SUPPLIER_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'supplier Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.140',
        [updated_at] = '2026-01-19 19:54:09.140'
    WHERE [step_name] = N'Supplier Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('1ae654cb-8d44-4668-bb76-62b46c9a6998', N'Supplier Dimension', N'D_SUPPLIER', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_SUPPLIER_NAME", "table_column": "BOTTOM_SUPPLIER_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_SUPPLIER_ID", "table_column": "BOTTOM_SUPPLIER_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'supplier Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.140', '2026-01-19 19:54:09.140');
END
GO
-- step_name=Survey Age Bracket
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Survey Age Bracket')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'c2e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e02',
        [table_name] = N'D_SURVEY_AGE_BRACKET',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS AGE_BRACKET

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What age bracket are you in ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What age bracket are you in ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "AGE_BRACKET", "table_column": "AGE_BRACKET", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'TOUCHPOINT',
        [time_series_target_column] = NULL,
        [description] = N'Survey Age Bracket',
        [created_by] = N'ClaudeCode',
        [created_at] = '2026-03-11 01:59:53.620',
        [updated_at] = '2026-03-11 01:59:53.620'
    WHERE [step_name] = N'Survey Age Bracket';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('c2e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e02', N'Survey Age Bracket', N'D_SURVEY_AGE_BRACKET', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS AGE_BRACKET

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What age bracket are you in ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What age bracket are you in ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL', 1, N'Dimension', N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "AGE_BRACKET", "table_column": "AGE_BRACKET", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]', 0, 100, 3, 30, NULL, N'TOUCHPOINT', NULL, N'Survey Age Bracket', N'ClaudeCode', '2026-03-11 01:59:53.620', '2026-03-11 01:59:53.620');
END
GO
-- step_name=Survey Community Involvement
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Survey Community Involvement')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'c1e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e01',
        [table_name] = N'D_SURVEY_COMMUNITY_INVOLVEMENT',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS COMMUNITY_INVOLVEMENT

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''Survey Selection''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''Survey Selection''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "COMMUNITY_INVOLVEMENT", "table_column": "COMMUNITY_INVOLVEMENT", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'TOUCHPOINT',
        [time_series_target_column] = NULL,
        [description] = N'Survey Community Involvement',
        [created_by] = N'ClaudeCode',
        [created_at] = '2026-03-11 01:59:53.613',
        [updated_at] = '2026-03-11 01:59:53.613'
    WHERE [step_name] = N'Survey Community Involvement';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('c1e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e01', N'Survey Community Involvement', N'D_SURVEY_COMMUNITY_INVOLVEMENT', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS COMMUNITY_INVOLVEMENT

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''Survey Selection''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''Survey Selection''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL', 1, N'Dimension', N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "COMMUNITY_INVOLVEMENT", "table_column": "COMMUNITY_INVOLVEMENT", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]', 0, 100, 3, 30, NULL, N'TOUCHPOINT', NULL, N'Survey Community Involvement', N'ClaudeCode', '2026-03-11 01:59:53.613', '2026-03-11 01:59:53.613');
END
GO
-- step_name=Survey Gender
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Survey Gender')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'c3e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e03',
        [table_name] = N'D_SURVEY_GENDER',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS GENDER

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your gender ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your gender ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "GENDER", "table_column": "GENDER", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'TOUCHPOINT',
        [time_series_target_column] = NULL,
        [description] = N'Survey Gender',
        [created_by] = N'ClaudeCode',
        [created_at] = '2026-03-11 01:59:53.620',
        [updated_at] = '2026-03-11 01:59:53.620'
    WHERE [step_name] = N'Survey Gender';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('c3e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e03', N'Survey Gender', N'D_SURVEY_GENDER', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS GENDER

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your gender ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your gender ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL', 1, N'Dimension', N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "GENDER", "table_column": "GENDER", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]', 0, 100, 3, 30, NULL, N'TOUCHPOINT', NULL, N'Survey Gender', N'ClaudeCode', '2026-03-11 01:59:53.620', '2026-03-11 01:59:53.620');
END
GO
-- step_name=Survey Postcode
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Survey Postcode')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'c4e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e04',
        [table_name] = N'D_SURVEY_POSTCODE',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS POSTCODE

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your postcode ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your postcode ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "POSTCODE", "table_column": "POSTCODE", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'TOUCHPOINT',
        [time_series_target_column] = NULL,
        [description] = N'Survey Postcode',
        [created_by] = N'ClaudeCode',
        [created_at] = '2026-03-11 01:59:53.623',
        [updated_at] = '2026-03-11 01:59:53.623'
    WHERE [step_name] = N'Survey Postcode';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('c4e8d1a3-7c2f-4f9a-8b5e-3d6a9f1c2e04', N'Survey Postcode', N'D_SURVEY_POSTCODE', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS POSTCODE

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your postcode ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your postcode ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL', 1, N'Dimension', N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "POSTCODE", "table_column": "POSTCODE", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]', 0, 100, 3, 30, NULL, N'TOUCHPOINT', NULL, N'Survey Postcode', N'ClaudeCode', '2026-03-11 01:59:53.623', '2026-03-11 01:59:53.623');
END
GO
-- step_name=TAX Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'TAX Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'f4646984-16d7-42c5-a179-9202518d4bf3',
        [table_name] = N'D_TAX',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_TAX_NAME", "table_column": "BOTTOM_TAX_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_TAX_ID", "table_column": "BOTTOM_TAX_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Tax Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.143',
        [updated_at] = '2026-01-19 19:54:09.143'
    WHERE [step_name] = N'TAX Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('f4646984-16d7-42c5-a179-9202518d4bf3', N'TAX Dimension', N'D_TAX', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_TAX_NAME", "table_column": "BOTTOM_TAX_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_TAX_ID", "table_column": "BOTTOM_TAX_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Tax Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.143', '2026-01-19 19:54:09.143');
END
GO
-- step_name=Tender Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Tender Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'c5c413f7-2f0c-42ca-bab5-eba249932a22',
        [table_name] = N'D_TENDER',
        [query_sql] = N'-- Variable to control number of middle levels to include

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
        [tier] = 1,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_TENDER_NAME", "table_column": "BOTTOM_TENDER_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_TENDER_ID", "table_column": "BOTTOM_TENDER_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Tender Dimension Build',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.147',
        [updated_at] = '2026-01-19 19:54:09.147'
    WHERE [step_name] = N'Tender Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('c5c413f7-2f0c-42ca-bab5-eba249932a22', N'Tender Dimension', N'D_TENDER', N'-- Variable to control number of middle levels to include

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
    1 AS TOTAL_LEVELS', 1, N'Dimension', N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_TENDER_NAME", "table_column": "BOTTOM_TENDER_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_TENDER_ID", "table_column": "BOTTOM_TENDER_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_1", "table_column": "BOTTOM_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_2", "table_column": "BOTTOM_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_3", "table_column": "BOTTOM_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_4", "table_column": "BOTTOM_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_ATTR_5", "table_column": "BOTTOM_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_NAME", "table_column": "MIDDLE_1_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_1", "table_column": "MIDDLE_1_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_2", "table_column": "MIDDLE_1_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_3", "table_column": "MIDDLE_1_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_4", "table_column": "MIDDLE_1_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_ATTR_5", "table_column": "MIDDLE_1_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_MICROSERVICE_ID", "table_column": "MIDDLE_1_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "MIDDLE_1_MICROSERVICE_NAME", "table_column": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_NAME", "table_column": "TOP_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_1", "table_column": "TOP_ATTR_1", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_2", "table_column": "TOP_ATTR_2", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_3", "table_column": "TOP_ATTR_3", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_4", "table_column": "TOP_ATTR_4", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_ATTR_5", "table_column": "TOP_ATTR_5", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_MICROSERVICE_ID", "table_column": "TOP_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "uniqueidentifier"}, {"query_column": "TOP_MICROSERVICE_NAME", "table_column": "TOP_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Tender Dimension Build', N'PresentationControlApp', '2026-01-19 19:54:09.147', '2026-01-19 19:54:09.147');
END
GO
-- step_name=F_INV_DAILY_DETAIL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'F_INV_DAILY_DETAIL')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = '4bb2b1be-d776-4bb6-9d42-13eca25d4aca',
        [table_name] = N'F_INV_DAILY_DETAIL',
        [query_sql] = N'DECLARE @StartDate DATE;

DECLARE @EndDate DATE;

DECLARE @InvItemAvgDays INT;



SET @InvItemAvgDays = 30;



SELECT @StartDate = CAST([ParameterValue] AS DATE) 

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_START'';



SELECT @EndDate = CAST([ParameterValue] AS DATE)

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_END'';





WITH BaseData AS (
SELECT [LOCATION_HUB_ID]
      ,[INVITEM_HUB_ID]
      ,[BUSINESS_DATE]
      ,[STANDARDISED_UOM]
      ,[PREVIOUS_COUNT]
      ,[ACTUAL_COUNT]
      ,[MOVEMENT_QTY]
      ,[THEO_USAGE]
      ,[ACTUAL_USAGE]
      ,[VARIANCE]
      ,[ORDER_QTY]
      ,[SALE_QTY]
      ,[PRODUCTION_QTY]
      ,[TRANSFER_QTY]
      ,[WASTE_QTY]
      ,[UOM_COST]
      ,[DAYS_SINCE_LAST_COUNT]
        -- Get the last non-null actual count up to this row
       , LAST_VALUE([ACTUAL_COUNT]) IGNORE NULLS OVER (
            PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID 
            ORDER BY [BUSINESS_DATE]
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS LastActualCount,
        -- Get the date of the last actual count
        LAST_VALUE(CASE WHEN [ACTUAL_COUNT] IS NOT NULL THEN [BUSINESS_DATE] END) IGNORE NULLS OVER (
            PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID 
            ORDER BY [BUSINESS_DATE]
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS LastCountDate
  FROM [presentation].[F_PRE_INV_DAILY_DETAIL])
SELECT 
    [LOCATION_HUB_ID],
    [INVITEM_HUB_ID],
    [BUSINESS_DATE],
    [STANDARDISED_UOM],
    [PREVIOUS_COUNT],
    [ACTUAL_COUNT],
    [MOVEMENT_QTY],
    [THEO_USAGE],
    [ACTUAL_USAGE],
    [VARIANCE],
    [ORDER_QTY],
    [SALE_QTY],
    [PRODUCTION_QTY],
    [TRANSFER_QTY],
    [WASTE_QTY],
    [UOM_COST],
    [DAYS_SINCE_LAST_COUNT],

    -- Theoretical Stock on Hand: Use actual count if present, otherwise last actual count + accumulated usage (only from rows without actual counts)
    CASE 
        WHEN ACTUAL_COUNT IS NOT NULL THEN ACTUAL_COUNT
        ELSE LastActualCount + SUM(
            CASE WHEN ACTUAL_COUNT IS NULL THEN COALESCE([THEO_USAGE], 0) ELSE 0 END
        ) OVER (
            PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID, LastCountDate
            ORDER BY [BUSINESS_DATE]
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
    END AS THEO_STOCK_ON_HAND,  
    CASE WHEN [SALE_QTY] != 0 THEN
        CASE 
            WHEN ACTUAL_COUNT IS NOT NULL THEN ACTUAL_COUNT
            ELSE LastActualCount + SUM(
                CASE WHEN ACTUAL_COUNT IS NULL THEN COALESCE([THEO_USAGE], 0) ELSE 0 END
            ) OVER (
                PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID, LastCountDate
                ORDER BY [BUSINESS_DATE]
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
        END / ([SALE_QTY] * -1)
    END AS STOCK_HOLDING_DAYS
FROM ( 
SELECT
     [LOCATION_HUB_ID]
      ,[INVITEM_HUB_ID]
      ,[BUSINESS_DATE]
      ,[STANDARDISED_UOM]
      ,[PREVIOUS_COUNT]
      ,THEO_STOCK_ON_HAND AS [ACTUAL_COUNT]
      ,[MOVEMENT_QTY]
      ,[THEO_USAGE]
      ,[ACTUAL_USAGE]
      ,[VARIANCE]
      ,[ORDER_QTY]
      ,[SALE_QTY]
      ,[PRODUCTION_QTY]
      ,[TRANSFER_QTY]
      ,[WASTE_QTY]
      ,[UOM_COST]
      ,[DAYS_SINCE_LAST_COUNT]
      ,THEO_STOCK_ON_HAND AS LastActualCount
      ,[BUSINESS_DATE] AS LastCountDate
      
    FROM presentation.E_INV_DAILY_DETAIL
    UNION
    SELECT * FROM BaseData 
    ) UNISUB
ORDER BY [LOCATION_HUB_ID], INVITEM_HUB_ID, [BUSINESS_DATE]',
        [tier] = 2,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BUSINESS_DATE", "table_column": "BUSINESS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "THEO_STOCK_ON_HAND", "table_column": "THEO_STOCK_ON_HAND", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "STOCK_HOLDING_DAYS", "table_column": "STOCK_HOLDING_DAYS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'BUSINESS_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-02-05 00:08:35.827',
        [updated_at] = '2026-03-12 22:28:44.147'
    WHERE [step_name] = N'F_INV_DAILY_DETAIL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('4bb2b1be-d776-4bb6-9d42-13eca25d4aca', N'F_INV_DAILY_DETAIL', N'F_INV_DAILY_DETAIL', N'DECLARE @StartDate DATE;

DECLARE @EndDate DATE;

DECLARE @InvItemAvgDays INT;



SET @InvItemAvgDays = 30;



SELECT @StartDate = CAST([ParameterValue] AS DATE) 

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_START'';



SELECT @EndDate = CAST([ParameterValue] AS DATE)

FROM [core].[GlobalParameters] 

WHERE [ParameterKey] = ''STOCKEVENT_END'';





WITH BaseData AS (
SELECT [LOCATION_HUB_ID]
      ,[INVITEM_HUB_ID]
      ,[BUSINESS_DATE]
      ,[STANDARDISED_UOM]
      ,[PREVIOUS_COUNT]
      ,[ACTUAL_COUNT]
      ,[MOVEMENT_QTY]
      ,[THEO_USAGE]
      ,[ACTUAL_USAGE]
      ,[VARIANCE]
      ,[ORDER_QTY]
      ,[SALE_QTY]
      ,[PRODUCTION_QTY]
      ,[TRANSFER_QTY]
      ,[WASTE_QTY]
      ,[UOM_COST]
      ,[DAYS_SINCE_LAST_COUNT]
        -- Get the last non-null actual count up to this row
       , LAST_VALUE([ACTUAL_COUNT]) IGNORE NULLS OVER (
            PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID 
            ORDER BY [BUSINESS_DATE]
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS LastActualCount,
        -- Get the date of the last actual count
        LAST_VALUE(CASE WHEN [ACTUAL_COUNT] IS NOT NULL THEN [BUSINESS_DATE] END) IGNORE NULLS OVER (
            PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID 
            ORDER BY [BUSINESS_DATE]
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS LastCountDate
  FROM [presentation].[F_PRE_INV_DAILY_DETAIL])
SELECT 
    [LOCATION_HUB_ID],
    [INVITEM_HUB_ID],
    [BUSINESS_DATE],
    [STANDARDISED_UOM],
    [PREVIOUS_COUNT],
    [ACTUAL_COUNT],
    [MOVEMENT_QTY],
    [THEO_USAGE],
    [ACTUAL_USAGE],
    [VARIANCE],
    [ORDER_QTY],
    [SALE_QTY],
    [PRODUCTION_QTY],
    [TRANSFER_QTY],
    [WASTE_QTY],
    [UOM_COST],
    [DAYS_SINCE_LAST_COUNT],

    -- Theoretical Stock on Hand: Use actual count if present, otherwise last actual count + accumulated usage (only from rows without actual counts)
    CASE 
        WHEN ACTUAL_COUNT IS NOT NULL THEN ACTUAL_COUNT
        ELSE LastActualCount + SUM(
            CASE WHEN ACTUAL_COUNT IS NULL THEN COALESCE([THEO_USAGE], 0) ELSE 0 END
        ) OVER (
            PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID, LastCountDate
            ORDER BY [BUSINESS_DATE]
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
    END AS THEO_STOCK_ON_HAND,  
    CASE WHEN [SALE_QTY] != 0 THEN
        CASE 
            WHEN ACTUAL_COUNT IS NOT NULL THEN ACTUAL_COUNT
            ELSE LastActualCount + SUM(
                CASE WHEN ACTUAL_COUNT IS NULL THEN COALESCE([THEO_USAGE], 0) ELSE 0 END
            ) OVER (
                PARTITION BY [LOCATION_HUB_ID], INVITEM_HUB_ID, LastCountDate
                ORDER BY [BUSINESS_DATE]
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
        END / ([SALE_QTY] * -1)
    END AS STOCK_HOLDING_DAYS
FROM ( 
SELECT
     [LOCATION_HUB_ID]
      ,[INVITEM_HUB_ID]
      ,[BUSINESS_DATE]
      ,[STANDARDISED_UOM]
      ,[PREVIOUS_COUNT]
      ,THEO_STOCK_ON_HAND AS [ACTUAL_COUNT]
      ,[MOVEMENT_QTY]
      ,[THEO_USAGE]
      ,[ACTUAL_USAGE]
      ,[VARIANCE]
      ,[ORDER_QTY]
      ,[SALE_QTY]
      ,[PRODUCTION_QTY]
      ,[TRANSFER_QTY]
      ,[WASTE_QTY]
      ,[UOM_COST]
      ,[DAYS_SINCE_LAST_COUNT]
      ,THEO_STOCK_ON_HAND AS LastActualCount
      ,[BUSINESS_DATE] AS LastCountDate
      
    FROM presentation.E_INV_DAILY_DETAIL
    UNION
    SELECT * FROM BaseData 
    ) UNISUB
ORDER BY [LOCATION_HUB_ID], INVITEM_HUB_ID, [BUSINESS_DATE]', 2, N'Fact', N'[{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BUSINESS_DATE", "table_column": "BUSINESS_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"}, {"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](20)"}, {"query_column": "PREVIOUS_COUNT", "table_column": "PREVIOUS_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_COUNT", "table_column": "ACTUAL_COUNT", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "MOVEMENT_QTY", "table_column": "MOVEMENT_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "THEO_USAGE", "table_column": "THEO_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ACTUAL_USAGE", "table_column": "ACTUAL_USAGE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "VARIANCE", "table_column": "VARIANCE", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "ORDER_QTY", "table_column": "ORDER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "PRODUCTION_QTY", "table_column": "PRODUCTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "DAYS_SINCE_LAST_COUNT", "table_column": "DAYS_SINCE_LAST_COUNT", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "THEO_STOCK_ON_HAND", "table_column": "THEO_STOCK_ON_HAND", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "STOCK_HOLDING_DAYS", "table_column": "STOCK_HOLDING_DAYS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]', 0, 100, 3, 30, NULL, N'STOCKEVENT', N'BUSINESS_DATE', N'None', N'PresentationControlApp', '2026-02-05 00:08:35.827', '2026-03-12 22:28:44.147');
END
GO
-- step_name=Inventory Sales by Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Inventory Sales by Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'f6ea7f17-10a6-422a-9276-4ab055697ace',
        [table_name] = N'F_INV_SALES_DAY',
        [query_sql] = N'DECLARE @HasPOS BIT = CASE WHEN EXISTS (
    SELECT 1 FROM [core].[core].[OrganisationIntegrations] OI
    INNER JOIN [core].[core].[Integrations] I ON OI.IntegrationID = I.IntegrationID
    INNER JOIN [core].[core].[Organisations] O ON OI.OrganisationID = O.OrganisationID
    WHERE O.DatabaseName = DB_NAME()
    AND I.IntegrationType = ''POS''
) THEN 1 ELSE 0 END;

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''LINEITEM_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''LINEITEM_END'';

WITH UOMConversion AS
	(
	SELECT [FROM_UOM] AS UOM, [TO_UOM] AS base_uom, CAST([CONVERSION_FACTOR] AS DECIMAL(18,6)) AS conversion_factor FROM [core].[reference].[UOM_CONVERSION]
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
	AND (@HasPOS = 0 OR IG.[IntegrationType] = ''POS'')

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
		,ISNULL(((PIS.UOM_VALUE * INV.UOM_COST) / NULLIF(SUM(PIS.UOM_VALUE * INV.UOM_COST) OVER(PARTITION BY PIS.HUB_ID), 0)) * PIS.NET_VALUE,0) AS NET_SALES
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
        [tier] = 2,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INV_DATE", "table_column": "INV_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALES_RECIPE_COST", "table_column": "SALES_RECIPE_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "NET_SALES", "table_column": "NET_SALES", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'LINEITEM',
        [time_series_target_column] = N'INV_DATE',
        [description] = N'None',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.150',
        [updated_at] = '2026-03-27 16:51:59.033'
    WHERE [step_name] = N'Inventory Sales by Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('f6ea7f17-10a6-422a-9276-4ab055697ace', N'Inventory Sales by Day', N'F_INV_SALES_DAY', N'DECLARE @HasPOS BIT = CASE WHEN EXISTS (
    SELECT 1 FROM [core].[core].[OrganisationIntegrations] OI
    INNER JOIN [core].[core].[Integrations] I ON OI.IntegrationID = I.IntegrationID
    INNER JOIN [core].[core].[Organisations] O ON OI.OrganisationID = O.OrganisationID
    WHERE O.DatabaseName = DB_NAME()
    AND I.IntegrationType = ''POS''
) THEN 1 ELSE 0 END;

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''LINEITEM_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''LINEITEM_END'';

WITH UOMConversion AS
	(
	SELECT [FROM_UOM] AS UOM, [TO_UOM] AS base_uom, CAST([CONVERSION_FACTOR] AS DECIMAL(18,6)) AS conversion_factor FROM [core].[reference].[UOM_CONVERSION]
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
	AND (@HasPOS = 0 OR IG.[IntegrationType] = ''POS'')

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
		,ISNULL(((PIS.UOM_VALUE * INV.UOM_COST) / NULLIF(SUM(PIS.UOM_VALUE * INV.UOM_COST) OVER(PARTITION BY PIS.HUB_ID), 0)) * PIS.NET_VALUE,0) AS NET_SALES
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
	,INV_DATE', 2, N'Fact', N'[{"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "INV_DATE", "table_column": "INV_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "SALES_RECIPE_COST", "table_column": "SALES_RECIPE_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}, {"query_column": "NET_SALES", "table_column": "NET_SALES", "data_type": "varchar(255)", "target_data_type": "[decimal](38,"}]', 0, 100, 3, 30, NULL, N'LINEITEM', N'INV_DATE', N'None', N'PresentationControlApp', '2026-01-19 19:54:09.150', '2026-03-27 16:51:59.033');
END
GO
-- step_name=Product CoOccurrence Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Product CoOccurrence Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'f2ae2dc5-c506-4383-a667-553da535c120',
        [table_name] = N'D_COOCCURRENCE',
        [query_sql] = N'SELECT
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
        [tier] = 2,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID_COMP", "table_column": "PRODUCT_HUB_ID_COMP", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "globalOccurenceCount", "table_column": "globalOccurenceCount", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "DistinctOrderCount", "table_column": "DistinctOrderCount", "data_type": "varchar(255)", "target_data_type": "[int]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = NULL,
        [time_series_target_column] = NULL,
        [description] = NULL,
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-01-19 19:54:09.153',
        [updated_at] = '2026-01-19 19:54:09.153'
    WHERE [step_name] = N'Product CoOccurrence Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('f2ae2dc5-c506-4383-a667-553da535c120', N'Product CoOccurrence Dimension', N'D_COOCCURRENCE', N'SELECT
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
    ,TD1.CHANNEL_HUB_ID', 2, N'Dimension', N'[{"query_column": "PRODUCT_HUB_ID", "table_column": "PRODUCT_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "PRODUCT_HUB_ID_COMP", "table_column": "PRODUCT_HUB_ID_COMP", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "OCCASION_HUB_ID", "table_column": "OCCASION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "REVCENTER_HUB_ID", "table_column": "REVCENTER_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "CHANNEL_HUB_ID", "table_column": "CHANNEL_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "globalOccurenceCount", "table_column": "globalOccurenceCount", "data_type": "varchar(255)", "target_data_type": "[int]"}, {"query_column": "DistinctOrderCount", "table_column": "DistinctOrderCount", "data_type": "varchar(255)", "target_data_type": "[int]"}]', 0, 100, 3, 30, NULL, NULL, NULL, NULL, N'PresentationControlApp', '2026-01-19 19:54:09.153', '2026-01-19 19:54:09.153');
END
GO
-- step_name=Survey Response Fact
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Survey Response Fact')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'a7d3f8c2-91e4-4b56-8d7a-2e5f1c093b4a',
        [table_name] = N'F_SURVEY_RESPONSE',
        [query_sql] = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT
    ISNULL(LNK.TOUCHPOINT_HUB_ID, CONVERT(BINARY(32), -999)) AS TOUCHPOINT_HUB_ID,
    ISNULL(LNK.QUESTION_HUB_ID,   CONVERT(BINARY(32), -999)) AS QUESTION_HUB_ID,
    ISNULL(LNK.ANSWER_HUB_ID,     CONVERT(BINARY(32), -999)) AS ANSWER_HUB_ID,
    CAST(TP.TOUCHPOINT_DATETIME AS DATE)                      AS TOUCHPOINT_DATE,
    TP.TOUCHPOINT_STATUS,
    SA.ANSWER                                                 AS ANSWER_TEXT,
    TRY_CAST(SA.ANSWER AS DECIMAL(38,10))                     AS ANSWER_NUMERIC,
    d_ci.COMMUNITY_INVOLVEMENT,
    d_age.AGE_BRACKET,
    d_gen.GENDER,
    d_pc.POSTCODE

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

INNER JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.BOTTOM_LEVEL = 1

INNER JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1

LEFT JOIN [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT] d_ci
    ON LNK.TOUCHPOINT_HUB_ID = d_ci.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_AGE_BRACKET] d_age
    ON LNK.TOUCHPOINT_HUB_ID = d_age.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_GENDER] d_gen
    ON LNK.TOUCHPOINT_HUB_ID = d_gen.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_POSTCODE] d_pc
    ON LNK.TOUCHPOINT_HUB_ID = d_pc.TOUCHPOINT_HUB_ID

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate',
        [tier] = 2,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "QUESTION_HUB_ID", "table_column": "QUESTION_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "ANSWER_HUB_ID", "table_column": "ANSWER_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "TOUCHPOINT_DATE", "table_column": "TOUCHPOINT_DATE", "data_type": "date", "target_data_type": "[datetime2](7)"}, {"query_column": "TOUCHPOINT_STATUS", "table_column": "TOUCHPOINT_STATUS", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "ANSWER_TEXT", "table_column": "ANSWER_TEXT", "data_type": "nvarchar(max)", "target_data_type": "[nvarchar](MAX)"}, {"query_column": "ANSWER_NUMERIC", "table_column": "ANSWER_NUMERIC", "data_type": "decimal(38,10)", "target_data_type": "[decimal](38,10)"}, {"query_column": "COMMUNITY_INVOLVEMENT", "table_column": "COMMUNITY_INVOLVEMENT", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "AGE_BRACKET", "table_column": "AGE_BRACKET", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "GENDER", "table_column": "GENDER", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "POSTCODE", "table_column": "POSTCODE", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'TOUCHPOINT',
        [time_series_target_column] = N'TOUCHPOINT_DATE',
        [description] = N'Survey response fact at (TOUCHPOINT x leaf QUESTION x ANSWER) grain. Tier 2 — runs after 4 individual demographic sub-tables (Tier 1). Demographics (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) resolved via 4 LEFT JOINs to individual presentation dimension tables rather than 12 LEFT JOINs against the ternary link. Date-range filtered via TOUCHPOINT_START/TOUCHPOINT_END GlobalParameters.',
        [created_by] = N'ClaudeCode',
        [created_at] = '2026-03-11 01:59:53.683',
        [updated_at] = '2026-03-11 01:59:53.683'
    WHERE [step_name] = N'Survey Response Fact';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('a7d3f8c2-91e4-4b56-8d7a-2e5f1c093b4a', N'Survey Response Fact', N'F_SURVEY_RESPONSE', N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT
    ISNULL(LNK.TOUCHPOINT_HUB_ID, CONVERT(BINARY(32), -999)) AS TOUCHPOINT_HUB_ID,
    ISNULL(LNK.QUESTION_HUB_ID,   CONVERT(BINARY(32), -999)) AS QUESTION_HUB_ID,
    ISNULL(LNK.ANSWER_HUB_ID,     CONVERT(BINARY(32), -999)) AS ANSWER_HUB_ID,
    CAST(TP.TOUCHPOINT_DATETIME AS DATE)                      AS TOUCHPOINT_DATE,
    TP.TOUCHPOINT_STATUS,
    SA.ANSWER                                                 AS ANSWER_TEXT,
    TRY_CAST(SA.ANSWER AS DECIMAL(38,10))                     AS ANSWER_NUMERIC,
    d_ci.COMMUNITY_INVOLVEMENT,
    d_age.AGE_BRACKET,
    d_gen.GENDER,
    d_pc.POSTCODE

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

INNER JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.BOTTOM_LEVEL = 1

INNER JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1

LEFT JOIN [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT] d_ci
    ON LNK.TOUCHPOINT_HUB_ID = d_ci.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_AGE_BRACKET] d_age
    ON LNK.TOUCHPOINT_HUB_ID = d_age.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_GENDER] d_gen
    ON LNK.TOUCHPOINT_HUB_ID = d_gen.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_POSTCODE] d_pc
    ON LNK.TOUCHPOINT_HUB_ID = d_pc.TOUCHPOINT_HUB_ID

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate', 2, N'Fact', N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "QUESTION_HUB_ID", "table_column": "QUESTION_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "ANSWER_HUB_ID", "table_column": "ANSWER_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "TOUCHPOINT_DATE", "table_column": "TOUCHPOINT_DATE", "data_type": "date", "target_data_type": "[datetime2](7)"}, {"query_column": "TOUCHPOINT_STATUS", "table_column": "TOUCHPOINT_STATUS", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "ANSWER_TEXT", "table_column": "ANSWER_TEXT", "data_type": "nvarchar(max)", "target_data_type": "[nvarchar](MAX)"}, {"query_column": "ANSWER_NUMERIC", "table_column": "ANSWER_NUMERIC", "data_type": "decimal(38,10)", "target_data_type": "[decimal](38,10)"}, {"query_column": "COMMUNITY_INVOLVEMENT", "table_column": "COMMUNITY_INVOLVEMENT", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "AGE_BRACKET", "table_column": "AGE_BRACKET", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "GENDER", "table_column": "GENDER", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "POSTCODE", "table_column": "POSTCODE", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]', 0, 100, 3, 30, NULL, N'TOUCHPOINT', N'TOUCHPOINT_DATE', N'Survey response fact at (TOUCHPOINT x leaf QUESTION x ANSWER) grain. Tier 2 — runs after 4 individual demographic sub-tables (Tier 1). Demographics (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) resolved via 4 LEFT JOINs to individual presentation dimension tables rather than 12 LEFT JOINs against the ternary link. Date-range filtered via TOUCHPOINT_START/TOUCHPOINT_END GlobalParameters.', N'ClaudeCode', '2026-03-11 01:59:53.683', '2026-03-11 01:59:53.683');
END
GO
-- step_name=Parent Organisation Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Organisation Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd0000001-a0b1-c2d3-e4f5-a00000000001',
        [table_name] = N'PD_ORGANISATION',
        [query_sql] = N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

SELECT
    [OrganisationCode] AS ORG_CODE,
    [OrganisationName] AS ORG_NAME,
    [OrganisationPrefix] AS ORG_PREFIX,
    [DatabaseName] AS DATABASE_NAME,
    [IsActive] AS IS_ACTIVE,
    [CreatedDate] AS CREATED_DATE
FROM [core].[core].[Organisations]
WHERE [ParentOrganisationCode] = @ParentOrgCode
  AND [IsActive] = 1;',
        [tier] = 100,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORG_PREFIX","table_column":"ORG_PREFIX","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"DATABASE_NAME","table_column":"DATABASE_NAME","data_type":"nvarchar(128)","target_data_type":"[nvarchar](128)"},{"query_column":"IS_ACTIVE","table_column":"IS_ACTIVE","data_type":"bit","target_data_type":"[bit]"},{"query_column":"CREATED_DATE","table_column":"CREATED_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Parent Organisation Dimension - lists child organisations',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-13 17:26:25.740',
        [updated_at] = '2026-03-13 17:26:25.740'
    WHERE [step_name] = N'Parent Organisation Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d0000001-a0b1-c2d3-e4f5-a00000000001', N'Parent Organisation Dimension', N'PD_ORGANISATION', N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

SELECT
    [OrganisationCode] AS ORG_CODE,
    [OrganisationName] AS ORG_NAME,
    [OrganisationPrefix] AS ORG_PREFIX,
    [DatabaseName] AS DATABASE_NAME,
    [IsActive] AS IS_ACTIVE,
    [CreatedDate] AS CREATED_DATE
FROM [core].[core].[Organisations]
WHERE [ParentOrganisationCode] = @ParentOrgCode
  AND [IsActive] = 1;', 100, N'Dimension', N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORG_PREFIX","table_column":"ORG_PREFIX","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"DATABASE_NAME","table_column":"DATABASE_NAME","data_type":"nvarchar(128)","target_data_type":"[nvarchar](128)"},{"query_column":"IS_ACTIVE","table_column":"IS_ACTIVE","data_type":"bit","target_data_type":"[bit]"},{"query_column":"CREATED_DATE","table_column":"CREATED_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Parent Organisation Dimension - lists child organisations', N'PresentationControlApp', '2026-03-13 17:26:25.740', '2026-03-13 17:26:25.740');
END
GO
-- step_name=Parent Location Dimension
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Location Dimension')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd0000002-a0b1-c2d3-e4f5-a00000000002',
        [table_name] = N'PD_LOCATION',
        [query_sql] = N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = N''[presentation].[D_LOCATION]'',
    @IsRawQuery = 0,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
        [tier] = 100,
        [table_type] = N'Dimension',
        [column_mappings] = N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"varchar(36)","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_HUB_ID","table_column":"BOTTOM_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"BOTTOM_SRC","table_column":"BOTTOM_SRC","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOAD_TS","table_column":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVEFROM","table_column":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVETO","table_column":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_CURRENT_FLAG","table_column":"BOTTOM_CURRENT_FLAG","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_IS_DELETED","table_column":"BOTTOM_IS_DELETED","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_LOCATION_NAME","table_column":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOCATION_ID","table_column":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LEVEL_NAME","table_column":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_1","table_column":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_2","table_column":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_3","table_column":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_4","table_column":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_5","table_column":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_ID","table_column":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_NAME","table_column":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_NAME","table_column":"MIDDLE_1_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_LEVEL_NAME","table_column":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_1","table_column":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_2","table_column":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_3","table_column":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_4","table_column":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_5","table_column":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_ID","table_column":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_NAME","table_column":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_NAME","table_column":"TOP_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_LEVEL_NAME","table_column":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_1","table_column":"TOP_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_2","table_column":"TOP_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_3","table_column":"TOP_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_4","table_column":"TOP_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_5","table_column":"TOP_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_ID","table_column":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_NAME","table_column":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"HIERARCHY_PATH","table_column":"HIERARCHY_PATH","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOTAL_LEVELS","table_column":"TOTAL_LEVELS","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 110,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Parent Location Dimension - unions child D_LOCATION tables',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-13 17:26:25.747',
        [updated_at] = '2026-03-13 17:26:25.747'
    WHERE [step_name] = N'Parent Location Dimension';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d0000002-a0b1-c2d3-e4f5-a00000000002', N'Parent Location Dimension', N'PD_LOCATION', N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = N''[presentation].[D_LOCATION]'',
    @IsRawQuery = 0,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;', 100, N'Dimension', N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"varchar(36)","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_HUB_ID","table_column":"BOTTOM_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"BOTTOM_SRC","table_column":"BOTTOM_SRC","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOAD_TS","table_column":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVEFROM","table_column":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVETO","table_column":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_CURRENT_FLAG","table_column":"BOTTOM_CURRENT_FLAG","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_IS_DELETED","table_column":"BOTTOM_IS_DELETED","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_LOCATION_NAME","table_column":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOCATION_ID","table_column":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LEVEL_NAME","table_column":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_1","table_column":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_2","table_column":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_3","table_column":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_4","table_column":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_5","table_column":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_ID","table_column":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_NAME","table_column":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_NAME","table_column":"MIDDLE_1_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_LEVEL_NAME","table_column":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_1","table_column":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_2","table_column":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_3","table_column":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_4","table_column":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_5","table_column":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_ID","table_column":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_NAME","table_column":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_NAME","table_column":"TOP_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_LEVEL_NAME","table_column":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_1","table_column":"TOP_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_2","table_column":"TOP_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_3","table_column":"TOP_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_4","table_column":"TOP_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_5","table_column":"TOP_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_ID","table_column":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_NAME","table_column":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"HIERARCHY_PATH","table_column":"HIERARCHY_PATH","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOTAL_LEVELS","table_column":"TOTAL_LEVELS","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]', 0, 110, 3, 30, NULL, N'None', NULL, N'Parent Location Dimension - unions child D_LOCATION tables', N'PresentationControlApp', '2026-03-13 17:26:25.747', '2026-03-13 17:26:25.747');
END
GO
-- step_name=Parent Booking Metrics Hour
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Booking Metrics Hour')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'a7fd4970-12a4-4d20-95d3-a653902d5346',
        [table_name] = N'PF_BOOKING_METRICS_HOUR',
        [query_sql] = N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [BRAND_NAME],
    [BRAND_KEY],
    [BOOKING_HOUR],
    [BOOKING_DATE],
    [TOTAL_BOOKINGS],
    [TOTAL_COVERS],
    [SESSIONS],
    [ACTIVE_USERS]
FROM {DB}.[presentation].[F_BOOKING_METRICS_HOUR]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
        [tier] = 101,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column": "ORG_CODE", "table_column": "ORG_CODE", "data_type": "uniqueidentifier", "target_data_type": "[uniqueidentifier]"}, {"query_column": "ORG_NAME", "table_column":
  "ORG_NAME", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BRAND_NAME", "table_column": "BRAND_NAME", "data_type": "nvarchar(255)", "target_data_type":
  "[nvarchar](255)"}, {"query_column": "BRAND_KEY", "table_column": "BRAND_KEY", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOOKING_HOUR", "table_column":
  "BOOKING_HOUR", "data_type": "datetime2(7)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOOKING_DATE", "table_column": "BOOKING_DATE", "data_type": "datetime2(7)", "target_data_type":
  "[datetime2](7)"}, {"query_column": "TOTAL_BOOKINGS", "table_column": "TOTAL_BOOKINGS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "TOTAL_COVERS", "table_column": "TOTAL_COVERS",
  "data_type": "int", "target_data_type": "[int]"}, {"query_column": "SESSIONS", "table_column": "SESSIONS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "ACTIVE_USERS", "table_column":
  "ACTIVE_USERS", "data_type": "int", "target_data_type": "[int]"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'BOOKINGREPORT',
        [time_series_target_column] = N'BOOKING_DATE',
        [description] = N'Aggregate child F_BOOKING_METRICS_HOUR into parent PF_BOOKING_METRICS_DAY',
        [created_by] = NULL,
        [created_at] = '2026-04-07 13:52:00.960',
        [updated_at] = '2026-04-09 13:06:20.737'
    WHERE [step_name] = N'Parent Booking Metrics Hour';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('a7fd4970-12a4-4d20-95d3-a653902d5346', N'Parent Booking Metrics Hour', N'PF_BOOKING_METRICS_HOUR', N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [BRAND_NAME],
    [BRAND_KEY],
    [BOOKING_HOUR],
    [BOOKING_DATE],
    [TOTAL_BOOKINGS],
    [TOTAL_COVERS],
    [SESSIONS],
    [ACTIVE_USERS]
FROM {DB}.[presentation].[F_BOOKING_METRICS_HOUR]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;', 101, N'Fact', N'[{"query_column": "ORG_CODE", "table_column": "ORG_CODE", "data_type": "uniqueidentifier", "target_data_type": "[uniqueidentifier]"}, {"query_column": "ORG_NAME", "table_column":
  "ORG_NAME", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BRAND_NAME", "table_column": "BRAND_NAME", "data_type": "nvarchar(255)", "target_data_type":
  "[nvarchar](255)"}, {"query_column": "BRAND_KEY", "table_column": "BRAND_KEY", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOOKING_HOUR", "table_column":
  "BOOKING_HOUR", "data_type": "datetime2(7)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOOKING_DATE", "table_column": "BOOKING_DATE", "data_type": "datetime2(7)", "target_data_type":
  "[datetime2](7)"}, {"query_column": "TOTAL_BOOKINGS", "table_column": "TOTAL_BOOKINGS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "TOTAL_COVERS", "table_column": "TOTAL_COVERS",
  "data_type": "int", "target_data_type": "[int]"}, {"query_column": "SESSIONS", "table_column": "SESSIONS", "data_type": "int", "target_data_type": "[int]"}, {"query_column": "ACTIVE_USERS", "table_column":
  "ACTIVE_USERS", "data_type": "int", "target_data_type": "[int]"}]', 0, 100, 3, 30, NULL, N'BOOKINGREPORT', N'BOOKING_DATE', N'Aggregate child F_BOOKING_METRICS_HOUR into parent PF_BOOKING_METRICS_DAY', NULL, '2026-04-07 13:52:00.960', '2026-04-09 13:06:20.737');
END
GO
-- step_name=Parent Revenue Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Revenue Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd0000003-a0b1-c2d3-e4f5-a00000000003',
        [table_name] = N'PF_REVENUE_DAY',
        [query_sql] = N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    [LI_TYPE],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([GROSS_VALUE]) AS [GROSS_VALUE],
    SUM([TAX_VALUE]) AS [TAX_VALUE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([ORDER_COUNT]) AS [ORDER_COUNT],
    SUM([QUANTITY]) AS [QUANTITY]
FROM {DB}.[presentation].[F_LINEITEM_15MIN]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], [LI_TYPE], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
        [tier] = 101,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"LI_TYPE","table_column":"LI_TYPE","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"GROSS_VALUE","table_column":"GROSS_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"TAX_VALUE","table_column":"TAX_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 60,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'LINEITEM',
        [time_series_target_column] = N'ORDER_DATE',
        [description] = N'Parent Revenue Day - aggregates child F_LINEITEM_15MIN to daily grain',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-13 17:26:25.750',
        [updated_at] = '2026-03-13 17:26:25.750'
    WHERE [step_name] = N'Parent Revenue Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d0000003-a0b1-c2d3-e4f5-a00000000003', N'Parent Revenue Day', N'PF_REVENUE_DAY', N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    [LI_TYPE],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([GROSS_VALUE]) AS [GROSS_VALUE],
    SUM([TAX_VALUE]) AS [TAX_VALUE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([ORDER_COUNT]) AS [ORDER_COUNT],
    SUM([QUANTITY]) AS [QUANTITY]
FROM {DB}.[presentation].[F_LINEITEM_15MIN]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], [LI_TYPE], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;', 101, N'Fact', N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"LI_TYPE","table_column":"LI_TYPE","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"GROSS_VALUE","table_column":"GROSS_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"TAX_VALUE","table_column":"TAX_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]', 0, 100, 3, 60, NULL, N'LINEITEM', N'ORDER_DATE', N'Parent Revenue Day - aggregates child F_LINEITEM_15MIN to daily grain', N'PresentationControlApp', '2026-03-13 17:26:25.750', '2026-03-13 17:26:25.750');
END
GO
-- step_name=Parent Profit Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Profit Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd0000004-a0b1-c2d3-e4f5-a00000000004',
        [table_name] = N'PF_PROFIT_DAY',
        [query_sql] = N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([QUANTITY]) AS [QUANTITY],
    SUM([PROFIT]) AS [PROFIT],
    SUM([PROFIT_LESS_DISCOUNT]) AS [PROFIT_LESS_DISCOUNT],
    SUM([PROFIT]) - SUM([PROFIT_LESS_DISCOUNT]) AS [DISCOUNT_IMPACT]
FROM {DB}.[presentation].[F_PRODUCT_MARGIN_DAY]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
        [tier] = 101,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT","table_column":"PROFIT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT_LESS_DISCOUNT","table_column":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"DISCOUNT_IMPACT","table_column":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 110,
        [retry_count] = 3,
        [timeout_minutes] = 60,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'LINEITEM',
        [time_series_target_column] = N'ORDER_DATE',
        [description] = N'Parent Profit Day - aggregates child F_PRODUCT_MARGIN_DAY',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-13 17:26:25.753',
        [updated_at] = '2026-03-13 17:26:25.753'
    WHERE [step_name] = N'Parent Profit Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d0000004-a0b1-c2d3-e4f5-a00000000004', N'Parent Profit Day', N'PF_PROFIT_DAY', N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([QUANTITY]) AS [QUANTITY],
    SUM([PROFIT]) AS [PROFIT],
    SUM([PROFIT_LESS_DISCOUNT]) AS [PROFIT_LESS_DISCOUNT],
    SUM([PROFIT]) - SUM([PROFIT_LESS_DISCOUNT]) AS [DISCOUNT_IMPACT]
FROM {DB}.[presentation].[F_PRODUCT_MARGIN_DAY]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;', 101, N'Fact', N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT","table_column":"PROFIT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT_LESS_DISCOUNT","table_column":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"DISCOUNT_IMPACT","table_column":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]', 0, 110, 3, 60, NULL, N'LINEITEM', N'ORDER_DATE', N'Parent Profit Day - aggregates child F_PRODUCT_MARGIN_DAY', N'PresentationControlApp', '2026-03-13 17:26:25.753', '2026-03-13 17:26:25.753');
END
GO
-- step_name=Parent Food Cost Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Food Cost Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd0000005-a0b1-c2d3-e4f5-a00000000005',
        [table_name] = N'PF_FOODCOST_DAY',
        [query_sql] = N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    CAST([INV_DATE] AS datetime2(7)) AS [INV_DATE],
    SUM([UOM_COST]) AS [TOTAL_UOM_COST],
    SUM([SALES_RECIPE_COST]) AS [TOTAL_RECIPE_COST],
    SUM([NET_SALES]) AS [NET_SALES]
FROM {DB}.[presentation].[F_INV_SALES_DAY]
GROUP BY [LOCATION_HUB_ID], [INV_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
        [tier] = 101,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"INV_DATE","table_column":"INV_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"TOTAL_UOM_COST","table_column":"TOTAL_UOM_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TOTAL_RECIPE_COST","table_column":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"NET_SALES","table_column":"NET_SALES","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]',
        [exclude] = 0,
        [priority] = 120,
        [retry_count] = 3,
        [timeout_minutes] = 60,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'INV_DATE',
        [description] = N'Parent Food Cost Day - aggregates child F_INV_SALES_DAY',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-13 17:26:25.760',
        [updated_at] = '2026-03-13 17:26:25.760'
    WHERE [step_name] = N'Parent Food Cost Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d0000005-a0b1-c2d3-e4f5-a00000000005', N'Parent Food Cost Day', N'PF_FOODCOST_DAY', N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    CAST([INV_DATE] AS datetime2(7)) AS [INV_DATE],
    SUM([UOM_COST]) AS [TOTAL_UOM_COST],
    SUM([SALES_RECIPE_COST]) AS [TOTAL_RECIPE_COST],
    SUM([NET_SALES]) AS [NET_SALES]
FROM {DB}.[presentation].[F_INV_SALES_DAY]
GROUP BY [LOCATION_HUB_ID], [INV_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;', 101, N'Fact', N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"INV_DATE","table_column":"INV_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"TOTAL_UOM_COST","table_column":"TOTAL_UOM_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TOTAL_RECIPE_COST","table_column":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"NET_SALES","table_column":"NET_SALES","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]', 0, 120, 3, 60, NULL, N'STOCKEVENT', N'INV_DATE', N'Parent Food Cost Day - aggregates child F_INV_SALES_DAY', N'PresentationControlApp', '2026-03-13 17:26:25.760', '2026-03-13 17:26:25.760');
END
GO
-- step_name=Parent Inventory Efficiency Day
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Inventory Efficiency Day')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd0000006-a0b1-c2d3-e4f5-a00000000006',
        [table_name] = N'PF_INVENTORY_EFFICIENCY_DAY',
        [query_sql] = N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [COUNT_DATE],
    SUM([ACTUAL_COUNT] * [UOM_COST]) AS [INVENTORY_VALUE],
    SUM([THEO_USAGE] * [UOM_COST]) AS [THEO_USAGE_COST],
    SUM([ACTUAL_USAGE] * [UOM_COST]) AS [ACTUAL_USAGE_COST],
    SUM([VARIANCE] * [UOM_COST]) AS [VARIANCE_COST],
    SUM([WASTE_QTY] * [UOM_COST]) AS [WASTE_COST],
    SUM([TRANSFER_QTY] * [UOM_COST]) AS [TRANSFER_COST]
FROM {DB}.[presentation].[F_INV_COUNTS_DAY]
GROUP BY [LOCATION_HUB_ID], [COUNT_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
        [tier] = 101,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"COUNT_DATE","table_column":"COUNT_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"INVENTORY_VALUE","table_column":"INVENTORY_VALUE","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"THEO_USAGE_COST","table_column":"THEO_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"ACTUAL_USAGE_COST","table_column":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"VARIANCE_COST","table_column":"VARIANCE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"WASTE_COST","table_column":"WASTE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TRANSFER_COST","table_column":"TRANSFER_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]',
        [exclude] = 0,
        [priority] = 130,
        [retry_count] = 3,
        [timeout_minutes] = 60,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'STOCKEVENT',
        [time_series_target_column] = N'COUNT_DATE',
        [description] = N'Parent Inventory Efficiency Day - cost-weighted aggregates from child F_INV_COUNTS_DAY',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-13 17:26:25.760',
        [updated_at] = '2026-03-13 17:26:25.760'
    WHERE [step_name] = N'Parent Inventory Efficiency Day';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d0000006-a0b1-c2d3-e4f5-a00000000006', N'Parent Inventory Efficiency Day', N'PF_INVENTORY_EFFICIENCY_DAY', N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [COUNT_DATE],
    SUM([ACTUAL_COUNT] * [UOM_COST]) AS [INVENTORY_VALUE],
    SUM([THEO_USAGE] * [UOM_COST]) AS [THEO_USAGE_COST],
    SUM([ACTUAL_USAGE] * [UOM_COST]) AS [ACTUAL_USAGE_COST],
    SUM([VARIANCE] * [UOM_COST]) AS [VARIANCE_COST],
    SUM([WASTE_QTY] * [UOM_COST]) AS [WASTE_COST],
    SUM([TRANSFER_QTY] * [UOM_COST]) AS [TRANSFER_COST]
FROM {DB}.[presentation].[F_INV_COUNTS_DAY]
GROUP BY [LOCATION_HUB_ID], [COUNT_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;', 101, N'Fact', N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"COUNT_DATE","table_column":"COUNT_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"INVENTORY_VALUE","table_column":"INVENTORY_VALUE","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"THEO_USAGE_COST","table_column":"THEO_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"ACTUAL_USAGE_COST","table_column":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"VARIANCE_COST","table_column":"VARIANCE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"WASTE_COST","table_column":"WASTE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TRANSFER_COST","table_column":"TRANSFER_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]', 0, 130, 3, 60, NULL, N'STOCKEVENT', N'COUNT_DATE', N'Parent Inventory Efficiency Day - cost-weighted aggregates from child F_INV_COUNTS_DAY', N'PresentationControlApp', '2026-03-13 17:26:25.760', '2026-03-13 17:26:25.760');
END
GO
-- step_name=Parent Growth Period
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationControl] WHERE [step_name] = N'Parent Growth Period')
BEGIN
    UPDATE [core].[core].[PresentationControl]
    SET
        [id] = 'd0000007-a0b1-c2d3-e4f5-a00000000007',
        [table_name] = N'PF_GROWTH_PERIOD',
        [query_sql] = N'WITH PeriodBase AS (
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID,
        ''WEEK'' AS PERIOD_TYPE,
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE) AS PERIOD_START,
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE) AS PERIOD_END,
        SUM(R.NET_VALUE) AS NET_REVENUE, SUM(R.ORDER_COUNT) AS ORDER_COUNT
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''WEEK'',
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE),
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
),
GrowthCalc AS (
    SELECT cur.ORG_CODE, cur.ORG_NAME, cur.LOCATION_HUB_ID,
        cur.PERIOD_TYPE, cur.PERIOD_START, cur.PERIOD_END,
        cur.NET_REVENUE, cur.ORDER_COUNT,
        prv.NET_REVENUE AS PREV_PERIOD_REVENUE,
        yoy.NET_REVENUE AS PREV_YEAR_REVENUE
    FROM PeriodBase cur
    OUTER APPLY (
        SELECT TOP 1 p.NET_REVENUE FROM PeriodBase p
        WHERE p.ORG_CODE = cur.ORG_CODE AND p.PERIOD_TYPE = cur.PERIOD_TYPE
          AND ISNULL(p.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
          AND p.PERIOD_START < cur.PERIOD_START
        ORDER BY p.PERIOD_START DESC
    ) prv
    LEFT JOIN PeriodBase yoy
        ON yoy.ORG_CODE = cur.ORG_CODE AND yoy.PERIOD_TYPE = cur.PERIOD_TYPE
        AND ISNULL(yoy.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
        AND yoy.PERIOD_START = CASE cur.PERIOD_TYPE
            WHEN ''WEEK'' THEN DATEADD(DAY,-364,cur.PERIOD_START)
            WHEN ''MONTH'' THEN DATEADD(MONTH,-12,cur.PERIOD_START)
            WHEN ''QUARTER'' THEN DATEADD(MONTH,-12,cur.PERIOD_START) END
)
SELECT ORG_CODE, ORG_NAME, LOCATION_HUB_ID, PERIOD_TYPE, PERIOD_START, PERIOD_END,
    NET_REVENUE, ORDER_COUNT, PREV_PERIOD_REVENUE, PREV_YEAR_REVENUE,
    CASE WHEN PREV_PERIOD_REVENUE IS NULL OR PREV_PERIOD_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_PERIOD_REVENUE) / PREV_PERIOD_REVENUE * 100, 2) END AS REVENUE_GROWTH_PCT,
    CASE WHEN PREV_YEAR_REVENUE IS NULL OR PREV_YEAR_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_YEAR_REVENUE) / PREV_YEAR_REVENUE * 100, 2) END AS REVENUE_GROWTH_YOY_PCT,
    CASE WHEN ORDER_COUNT > 0 THEN NET_REVENUE / ORDER_COUNT ELSE NULL END AS AVG_ORDER_VALUE
FROM GrowthCalc',
        [tier] = 102,
        [table_type] = N'Fact',
        [column_mappings] = N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"PERIOD_TYPE","table_column":"PERIOD_TYPE","data_type":"varchar(10)","target_data_type":"[varchar](10)"},{"query_column":"PERIOD_START","table_column":"PERIOD_START","data_type":"date","target_data_type":"[date]"},{"query_column":"PERIOD_END","table_column":"PERIOD_END","data_type":"date","target_data_type":"[date]"},{"query_column":"NET_REVENUE","table_column":"NET_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_PERIOD_REVENUE","table_column":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_YEAR_REVENUE","table_column":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"REVENUE_GROWTH_PCT","table_column":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"REVENUE_GROWTH_YOY_PCT","table_column":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"AVG_ORDER_VALUE","table_column":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
        [exclude] = 0,
        [priority] = 100,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [depends_on_steps] = NULL,
        [time_series_entity] = N'None',
        [time_series_target_column] = NULL,
        [description] = N'Parent Growth Period - week/month/quarter aggregates with inline period-over-period and YoY growth from PF_REVENUE_DAY',
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-03-13 17:26:25.767',
        [updated_at] = '2026-03-13 17:26:25.767'
    WHERE [step_name] = N'Parent Growth Period';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationControl] ([id], [step_name], [table_name], [query_sql], [tier], [table_type], [column_mappings], [exclude], [priority], [retry_count], [timeout_minutes], [depends_on_steps], [time_series_entity], [time_series_target_column], [description], [created_by], [created_at], [updated_at])
    VALUES ('d0000007-a0b1-c2d3-e4f5-a00000000007', N'Parent Growth Period', N'PF_GROWTH_PERIOD', N'WITH PeriodBase AS (
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID,
        ''WEEK'' AS PERIOD_TYPE,
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE) AS PERIOD_START,
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE) AS PERIOD_END,
        SUM(R.NET_VALUE) AS NET_REVENUE, SUM(R.ORDER_COUNT) AS ORDER_COUNT
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''WEEK'',
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE),
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
),
GrowthCalc AS (
    SELECT cur.ORG_CODE, cur.ORG_NAME, cur.LOCATION_HUB_ID,
        cur.PERIOD_TYPE, cur.PERIOD_START, cur.PERIOD_END,
        cur.NET_REVENUE, cur.ORDER_COUNT,
        prv.NET_REVENUE AS PREV_PERIOD_REVENUE,
        yoy.NET_REVENUE AS PREV_YEAR_REVENUE
    FROM PeriodBase cur
    OUTER APPLY (
        SELECT TOP 1 p.NET_REVENUE FROM PeriodBase p
        WHERE p.ORG_CODE = cur.ORG_CODE AND p.PERIOD_TYPE = cur.PERIOD_TYPE
          AND ISNULL(p.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
          AND p.PERIOD_START < cur.PERIOD_START
        ORDER BY p.PERIOD_START DESC
    ) prv
    LEFT JOIN PeriodBase yoy
        ON yoy.ORG_CODE = cur.ORG_CODE AND yoy.PERIOD_TYPE = cur.PERIOD_TYPE
        AND ISNULL(yoy.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
        AND yoy.PERIOD_START = CASE cur.PERIOD_TYPE
            WHEN ''WEEK'' THEN DATEADD(DAY,-364,cur.PERIOD_START)
            WHEN ''MONTH'' THEN DATEADD(MONTH,-12,cur.PERIOD_START)
            WHEN ''QUARTER'' THEN DATEADD(MONTH,-12,cur.PERIOD_START) END
)
SELECT ORG_CODE, ORG_NAME, LOCATION_HUB_ID, PERIOD_TYPE, PERIOD_START, PERIOD_END,
    NET_REVENUE, ORDER_COUNT, PREV_PERIOD_REVENUE, PREV_YEAR_REVENUE,
    CASE WHEN PREV_PERIOD_REVENUE IS NULL OR PREV_PERIOD_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_PERIOD_REVENUE) / PREV_PERIOD_REVENUE * 100, 2) END AS REVENUE_GROWTH_PCT,
    CASE WHEN PREV_YEAR_REVENUE IS NULL OR PREV_YEAR_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_YEAR_REVENUE) / PREV_YEAR_REVENUE * 100, 2) END AS REVENUE_GROWTH_YOY_PCT,
    CASE WHEN ORDER_COUNT > 0 THEN NET_REVENUE / ORDER_COUNT ELSE NULL END AS AVG_ORDER_VALUE
FROM GrowthCalc', 102, N'Fact', N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"PERIOD_TYPE","table_column":"PERIOD_TYPE","data_type":"varchar(10)","target_data_type":"[varchar](10)"},{"query_column":"PERIOD_START","table_column":"PERIOD_START","data_type":"date","target_data_type":"[date]"},{"query_column":"PERIOD_END","table_column":"PERIOD_END","data_type":"date","target_data_type":"[date]"},{"query_column":"NET_REVENUE","table_column":"NET_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_PERIOD_REVENUE","table_column":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_YEAR_REVENUE","table_column":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"REVENUE_GROWTH_PCT","table_column":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"REVENUE_GROWTH_YOY_PCT","table_column":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"AVG_ORDER_VALUE","table_column":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]', 0, 100, 3, 30, NULL, N'None', NULL, N'Parent Growth Period - week/month/quarter aggregates with inline period-over-period and YoY growth from PF_REVENUE_DAY', N'PresentationControlApp', '2026-03-13 17:26:25.767', '2026-03-13 17:26:25.767');
END
GO
