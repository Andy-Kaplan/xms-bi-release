-- ============================================================
-- Products With INVITEM Recipe Mapping — Full Detail
-- ============================================================
-- Purpose  : Returns one row per ingredient line in every
--            product recipe, drawing from both recipe links:
--
--   LNK_INVITEM_OCCASION_PRODUCT
--       Standard portioning / recipe link
--       (INVITEM x OCCASION x PRODUCT)
--
--   LNK_INVITEM_LOCATION_OCCASION_PRODUCT
--       Site-specific recipe / conversion link
--       (INVITEM x LOCATION x OCCASION x PRODUCT)
--
-- RECIPE_LINK_TYPE discriminates the source link.
-- For 'Standard' rows, LOCATION_* columns are NULL.
-- For 'Site-Specific' rows, all four dimensions are populated.
--
-- Columns per row:
--   Product   — display name, source name, PRODUCT_ID, hub key
--   INVITEM   — display name, source name, INVITEM_ID, hub key,
--               base UOM, hierarchy level
--   Recipe    — UOM and quantity for this ingredient line
--   Occasion  — name of the menu period / trading occasion
--   Location  — site name and ID (site-specific rows only)
--
-- Scope     : BOTTOM_LEVEL = 1 products (sellable leaf items).
--             IS_DELETED excluded on product and INVITEM.
--             Occasion / Location use LEFT JOIN — recipe lines
--             are preserved even if dimension names are absent.
--
-- Known schema note:
--   SAT_OCCASION contains the column OCCASSION_ID (double-S)
--   — this is a baked-in typo in the entity definition.
--   OCCASION_NAME itself is correctly spelled.
--
-- SAT_LNK structure note:
--   SAT_LNK tables are append-only (loaded via sp_ProcessLink).
--   They have NO CURRENT_FLAG, EFFECTIVEFROM, or EFFECTIVETO
--   columns — only LNK_ID, SRC, LOAD_TS, and the attributes.
--   The CTEs below deduplicate to the latest row per LNK_ID
--   using ROW_NUMBER() OVER (PARTITION BY LNK_ID ORDER BY
--   LOAD_TS DESC).
--
-- Usage     : Run against a client database
--             (e.g. USE [ClientPrefix_XMS_GUID])
-- ============================================================

-- Deduplicate SAT_LNK tables to latest record per link
WITH LatestSatLnk1 AS (
    SELECT
        LNK_ID,
        UOM,
        UOM_VALUE,
        ROW_NUMBER() OVER (PARTITION BY LNK_ID ORDER BY LOAD_TS DESC) AS rn
    FROM [datavault].[SAT_LNK_INVITEM_OCCASION_PRODUCT]
),
LatestSatLnk2 AS (
    SELECT
        LNK_ID,
        UOM,
        UOM_VALUE,
        ROW_NUMBER() OVER (PARTITION BY LNK_ID ORDER BY LOAD_TS DESC) AS rn
    FROM [datavault].[SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT]
)

-- --------------------------------------------------------
-- Part 1: Standard recipe link (no location specificity)
-- --------------------------------------------------------
SELECT
    'Standard'                                              AS RECIPE_LINK_TYPE,

    -- Link identifier
    lnk1.LNK_ID                                            AS RECIPE_LINK_ID,

    -- Product
    hp.HUB_ID                                              AS PRODUCT_HUB_ID,
    COALESCE(sp.MICROSERVICE_NAME, sp.PRODUCT_NAME)        AS PRODUCT_DISPLAY_NAME,
    sp.PRODUCT_NAME,
    sp.PRODUCT_ID,
    sp.MICROSERVICE_ID                                     AS PRODUCT_MICROSERVICE_ID,

    -- Inventory item (ingredient)
    hi.HUB_ID                                              AS INVITEM_HUB_ID,
    COALESCE(si.MICROSERVICE_NAME, si.INVITEM_NAME)        AS INVITEM_DISPLAY_NAME,
    si.INVITEM_NAME,
    si.INVITEM_ID,
    si.MICROSERVICE_ID                                     AS INVITEM_MICROSERVICE_ID,
    si.UOM                                                 AS INVITEM_BASE_UOM,
    si.LEVEL_NAME                                          AS INVITEM_LEVEL_NAME,

    -- Recipe specification (from link satellite)
    sl1.UOM                                                AS RECIPE_UOM,
    sl1.UOM_VALUE                                          AS RECIPE_QTY,

    -- Occasion (menu period)
    so.OCCASION_NAME,

    -- Location (not applicable for standard link)
    CAST(NULL AS BINARY(32))                               AS LOCATION_HUB_ID,
    CAST(NULL AS NVARCHAR(255))                            AS LOCATION_NAME,
    CAST(NULL AS NVARCHAR(255))                            AS LOCATION_ID

FROM [datavault].[LNK_INVITEM_OCCASION_PRODUCT]            lnk1

-- Recipe satellite: UOM and quantity for this ingredient line (latest row)
LEFT  JOIN LatestSatLnk1                                   sl1
    ON  sl1.LNK_ID = lnk1.LNK_ID
    AND sl1.rn     = 1

-- Product (leaf-level only)
INNER JOIN [datavault].[HUB_PRODUCT]                       hp
    ON  hp.HUB_ID = lnk1.PRODUCT_HUB_ID
INNER JOIN [datavault].[SAT_PRODUCT]                       sp
    ON  sp.HUB_ID       = hp.HUB_ID
    AND sp.CURRENT_FLAG = 1
    AND sp.BOTTOM_LEVEL = 1

-- Inventory item
INNER JOIN [datavault].[HUB_INVITEM]                       hi
    ON  hi.HUB_ID = lnk1.INVITEM_HUB_ID
INNER JOIN [datavault].[SAT_INVITEM]                       si
    ON  si.HUB_ID       = hi.HUB_ID
    AND si.CURRENT_FLAG = 1

-- Occasion (preserve rows even if satellite is absent)
LEFT  JOIN [datavault].[HUB_OCCASION]                      ho
    ON  ho.HUB_ID = lnk1.OCCASION_HUB_ID
LEFT  JOIN [datavault].[SAT_OCCASION]                      so
    ON  so.HUB_ID       = ho.HUB_ID
    AND so.CURRENT_FLAG = 1

WHERE (hp.IS_DELETED IS NULL OR hp.IS_DELETED = 0)
  AND (sp.IS_DELETED IS NULL OR sp.IS_DELETED = 0)
  AND (hi.IS_DELETED IS NULL OR hi.IS_DELETED = 0)
  AND (si.IS_DELETED IS NULL OR si.IS_DELETED = 0)

UNION ALL

-- --------------------------------------------------------
-- Part 2: Site-specific recipe link (includes location)
-- --------------------------------------------------------
SELECT
    'Site-Specific'                                        AS RECIPE_LINK_TYPE,

    lnk2.LNK_ID                                           AS RECIPE_LINK_ID,

    -- Product
    hp.HUB_ID                                             AS PRODUCT_HUB_ID,
    COALESCE(sp.MICROSERVICE_NAME, sp.PRODUCT_NAME)       AS PRODUCT_DISPLAY_NAME,
    sp.PRODUCT_NAME,
    sp.PRODUCT_ID,
    sp.MICROSERVICE_ID                                    AS PRODUCT_MICROSERVICE_ID,

    -- Inventory item (ingredient)
    hi.HUB_ID                                             AS INVITEM_HUB_ID,
    COALESCE(si.MICROSERVICE_NAME, si.INVITEM_NAME)       AS INVITEM_DISPLAY_NAME,
    si.INVITEM_NAME,
    si.INVITEM_ID,
    si.MICROSERVICE_ID                                    AS INVITEM_MICROSERVICE_ID,
    si.UOM                                                AS INVITEM_BASE_UOM,
    si.LEVEL_NAME                                         AS INVITEM_LEVEL_NAME,

    -- Recipe specification
    sl2.UOM                                               AS RECIPE_UOM,
    sl2.UOM_VALUE                                         AS RECIPE_QTY,

    -- Occasion
    so.OCCASION_NAME,

    -- Location
    hl.HUB_ID                                             AS LOCATION_HUB_ID,
    sloc.LOCATION_NAME,
    sloc.LOCATION_ID

FROM [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT]  lnk2

-- Recipe satellite (latest row)
LEFT  JOIN LatestSatLnk2                                   sl2
    ON  sl2.LNK_ID = lnk2.LNK_ID
    AND sl2.rn     = 1

-- Product (leaf-level only)
INNER JOIN [datavault].[HUB_PRODUCT]                      hp
    ON  hp.HUB_ID = lnk2.PRODUCT_HUB_ID
INNER JOIN [datavault].[SAT_PRODUCT]                      sp
    ON  sp.HUB_ID       = hp.HUB_ID
    AND sp.CURRENT_FLAG = 1
    AND sp.BOTTOM_LEVEL = 1

-- Inventory item
INNER JOIN [datavault].[HUB_INVITEM]                      hi
    ON  hi.HUB_ID = lnk2.INVITEM_HUB_ID
INNER JOIN [datavault].[SAT_INVITEM]                      si
    ON  si.HUB_ID       = hi.HUB_ID
    AND si.CURRENT_FLAG = 1

-- Occasion
LEFT  JOIN [datavault].[HUB_OCCASION]                     ho
    ON  ho.HUB_ID = lnk2.OCCASION_HUB_ID
LEFT  JOIN [datavault].[SAT_OCCASION]                     so
    ON  so.HUB_ID       = ho.HUB_ID
    AND so.CURRENT_FLAG = 1

-- Location
LEFT  JOIN [datavault].[HUB_LOCATION]                     hl
    ON  hl.HUB_ID = lnk2.LOCATION_HUB_ID
LEFT  JOIN [datavault].[SAT_LOCATION]                     sloc
    ON  sloc.HUB_ID       = hl.HUB_ID
    AND sloc.CURRENT_FLAG = 1

WHERE (hp.IS_DELETED IS NULL OR hp.IS_DELETED = 0)
  AND (sp.IS_DELETED IS NULL OR sp.IS_DELETED = 0)
  AND (hi.IS_DELETED IS NULL OR hi.IS_DELETED = 0)
  AND (si.IS_DELETED IS NULL OR si.IS_DELETED = 0)

ORDER BY
    PRODUCT_DISPLAY_NAME,
    OCCASION_NAME,
    LOCATION_NAME,
    INVITEM_DISPLAY_NAME;

-- ============================================================
-- Column reference
-- ============================================================
-- RECIPE_LINK_TYPE     'Standard' | 'Site-Specific'
-- RECIPE_LINK_ID       LNK hash key (BINARY 32) — unique per line
-- PRODUCT_HUB_ID       PRODUCT hub hash key
-- PRODUCT_DISPLAY_NAME MICROSERVICE_NAME if set, else PRODUCT_NAME
-- PRODUCT_NAME         Raw product name from SAT_PRODUCT
-- PRODUCT_ID           Source system product identifier
-- INVITEM_HUB_ID       INVITEM hub hash key
-- INVITEM_DISPLAY_NAME MICROSERVICE_NAME if set, else INVITEM_NAME
-- INVITEM_NAME         Raw inventory item name from SAT_INVITEM
-- INVITEM_ID           Source system inventory item identifier
-- INVITEM_BASE_UOM     Native UOM of the inventory item
-- INVITEM_LEVEL_NAME   Hierarchy level of the INVITEM node
-- RECIPE_UOM           UOM in which this ingredient is measured
--                      (may differ from INVITEM_BASE_UOM via
--                       LNK_INVITEM_INVITEM conversion chain)
-- RECIPE_QTY           Quantity of this ingredient per portion
-- OCCASION_NAME        Menu period / trading occasion
-- LOCATION_HUB_ID      NULL for Standard rows; site hub key
-- LOCATION_NAME        NULL for Standard rows; site name
-- LOCATION_ID          NULL for Standard rows; source site ID
-- ============================================================
