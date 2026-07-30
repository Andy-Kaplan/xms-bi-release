-- ============================================================================
-- Growyze GRYZ_PRODUCT category sentinel
-- Plan: docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md  Task 1
-- Ledger: O5
--
-- Problem: GRYZ_PRODUCT staging sets `category AS PARENT_ID` for products and
-- seeds category rows only `WHERE category IS NOT NULL`. Blank DL_DISHES.category
-- => PARENT_ID NULL => the D_PRODUCT recursive flatten falls back to the product's
-- own name for MIDDLE_1/TOP. Baseline (Padel, 2026-07-10): 108 fall-through products.
--
-- Fix: COALESCE blank/whitespace category -> 'Uncategorised' sentinel in BOTH the
-- product half (PARENT_ID) and the category-seed half, and drop the
-- `WHERE category IS NOT NULL` filter so the sentinel category row is seeded too.
-- Every product then resolves to a real category node.
--
-- Idempotent: wholesale UPDATE of the staging step's query_sql (re-running sets
-- the same value). Verified against live GRYZ_PRODUCT query_sql on UAT 2026-07-10 —
-- all 14 output columns preserved 1:1; only the category expressions change.
-- Deploy target: core.  After deploy: UploadStagingControl int_growyze001 (if the
-- integration regenerates staging), then Growyze staging -> DV load ->
-- presentation rebuild for each Growyze org.
-- ============================================================================

UPDATE [core].[int_growyze001].[StagingControl]
SET updated_at = GETDATE(),
    query_sql = N'IF OBJECT_ID(''stage.GRYZ_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PRODUCT];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
),
base AS (SELECT * FROM deduped WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_PRODUCT]
FROM (
    SELECT
        id AS HUB_ID,
        name AS PRODUCT_NAME,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS PARENT_ID,
        ''Product'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        id AS PRODUCT_ID,
        posId AS ATTR_1,
        barcode AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        id AS MICROSERVICE_ID,
        organizations AS LOCATION_KEY,
        ''-999'' AS OCC_ID,
        salePrice AS NET_PRICE,
        totalCost AS NET_COST
    FROM base
    UNION ALL
    SELECT DISTINCT
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS HUB_ID,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS PRODUCT_NAME,
        NULL AS PARENT_ID,
        ''Category'' AS LEVEL_NAME,
        0 AS BOTTOM_LEVEL,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS PRODUCT_ID,
        NULL AS ATTR_1,
        NULL AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        COALESCE(NULLIF(LTRIM(RTRIM(category)), ''''), ''Uncategorised'') AS MICROSERVICE_ID,
        NULL AS LOCATION_KEY,
        NULL AS OCC_ID,
        NULL AS NET_PRICE,
        NULL AS NET_COST
    FROM base
) AS source_query;'
WHERE staging_table = N'GRYZ_PRODUCT' AND step_name = N'Growyze Product';

IF @@ROWCOUNT <> 1
    RAISERROR(N'Task1 abort: expected exactly 1 GRYZ_PRODUCT staging row updated.', 16, 1);
PRINT 'Task 1: GRYZ_PRODUCT category sentinel applied.';
