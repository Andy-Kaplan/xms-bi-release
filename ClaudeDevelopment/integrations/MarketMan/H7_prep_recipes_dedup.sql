-- =============================================================================
-- H7_prep_recipes_dedup.sql
-- Fix: MMAN_PREP_RECIPES 3x row inflation from multi-fetch without dedup
-- =============================================================================
--
-- PROBLEM:
--   MMAN_PREP_RECIPES produces 12,501 rows from 4,167 source rows (3x inflation).
--   DL_INVENTORY_PREPS_SUBITEMS has multiple INT_FETCH_DATE values for the same
--   recipe records (each API fetch appends rows). The staging query has no
--   deduplication, so every fetch duplicate flows through to the staging table.
--
-- FIX:
--   Wrap the existing SELECT in a CTE with:
--     ROW_NUMBER() OVER (
--       PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
--       ORDER BY REC.[INT_FETCH_DATE] DESC
--     ) AS rn
--   Then filter to rn = 1, keeping only the most recent fetch of each recipe
--   ingredient line.
--
-- TARGET: core.int_marketman001.StagingControl, step_name = 'MMAN_PREP_RECIPES'
-- PATTERN: MERGE upsert on step_name
-- =============================================================================

MERGE INTO [core].[int_marketman001].[StagingControl] AS tgt
USING (VALUES (N'MMAN_PREP_RECIPES')) AS src (step_name)
ON tgt.[step_name] = src.[step_name]
WHEN MATCHED THEN
    UPDATE SET
        [staging_table] = N'MMAN_PREP_RECIPES',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    PARENT_HUB_ID
    ,CHILD_HUB_ID
    ,UOM
    ,UOM_VALUE
FROM (
    SELECT
        CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
        ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
        ,UOM.[Name] AS UOM
        ,[ActualUsage] AS UOM_VALUE
        ,ROW_NUMBER() OVER (
            PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
            ORDER BY REC.[INT_FETCH_DATE] DESC
        ) AS rn
    FROM
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
) deduped
WHERE rn = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        [updated_at] = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
            [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'MMAN_PREP_RECIPES', N'MMAN_PREP_RECIPES', N'IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    PARENT_HUB_ID
    ,CHILD_HUB_ID
    ,UOM
    ,UOM_VALUE
FROM (
    SELECT
        CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
        ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
        ,UOM.[Name] AS UOM
        ,[ActualUsage] AS UOM_VALUE
        ,ROW_NUMBER() OVER (
            PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
            ORDER BY REC.[INT_FETCH_DATE] DESC
        ) AS rn
    FROM
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
) deduped
WHERE rn = 1
) AS source_query;',
           1, N'Staging', 0, NULL, NULL, 3, 30,
           N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
           GETDATE(), GETDATE());
GO
