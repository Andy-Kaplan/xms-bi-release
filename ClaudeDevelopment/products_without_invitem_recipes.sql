-- ============================================================
-- Products Without INVITEM Recipe Mapping
-- ============================================================
-- Purpose  : Identifies leaf-level products that have no
--            inventory item (INVITEM) mapped to them via
--            either recipe link in the data vault.
--
-- A product is considered "set up with recipes" when at least
-- one INVITEM is connected to it through one of these links:
--
--   LNK_INVITEM_OCCASION_PRODUCT
--       Standard portioning / recipe link
--       (INVITEM x OCCASION x PRODUCT)
--
--   LNK_INVITEM_LOCATION_OCCASION_PRODUCT
--       Site-specific recipe / conversion link
--       (INVITEM x LOCATION x OCCASION x PRODUCT)
--
-- Products returned here have no entry in either link,
-- meaning they cannot be costed or theoretically tracked
-- through the inventory system.
--
-- Scope     : BOTTOM_LEVEL = 1 (leaf nodes only — the actual
--             sellable items, not category/parent products).
--             IS_DELETED is excluded.
--
-- Usage     : Run against a client database
--             (e.g. USE [ClientPrefix_XMS_GUID])
--             Replace [datavault] with the target schema if
--             the org uses a non-default schema name.
--
-- Source tables (all datavault schema):
--   HUB_PRODUCT                         (v4 live)
--   SAT_PRODUCT                         (v4 live)
--   LNK_INVITEM_OCCASION_PRODUCT        (v1 live)
--   LNK_INVITEM_LOCATION_OCCASION_PRODUCT (v1 live)
-- ============================================================

SELECT
    hp.HUB_ID                                           AS PRODUCT_HUB_ID,
    COALESCE(sp.MICROSERVICE_NAME, sp.PRODUCT_NAME)     AS DISPLAY_NAME,
    sp.PRODUCT_NAME,
    sp.PRODUCT_ID,
    sp.MICROSERVICE_ID,
    sp.MICROSERVICE_NAME,
    sp.LEVEL_NAME,
    sp.ATTR_1,
    sp.ATTR_2,
    hp.LOAD_TS                                          AS FIRST_SEEN_UTC

FROM [datavault].[HUB_PRODUCT]  hp

INNER JOIN [datavault].[SAT_PRODUCT] sp
    ON  sp.HUB_ID       = hp.HUB_ID
    AND sp.CURRENT_FLAG = 1         -- current satellite record only
    AND sp.BOTTOM_LEVEL = 1         -- leaf-level products only (not categories)

-- Exclude soft-deleted products
WHERE (hp.IS_DELETED  IS NULL OR hp.IS_DELETED  = 0)
  AND (sp.IS_DELETED  IS NULL OR sp.IS_DELETED  = 0)

-- No entry in the standard recipe link (INVITEM ↔ OCCASION ↔ PRODUCT)
  AND NOT EXISTS (
      SELECT 1
      FROM [datavault].[LNK_INVITEM_OCCASION_PRODUCT] lnk1
      WHERE lnk1.PRODUCT_HUB_ID = hp.HUB_ID
  )

-- No entry in the site-specific recipe link (INVITEM ↔ LOCATION ↔ OCCASION ↔ PRODUCT)
  AND NOT EXISTS (
      SELECT 1
      FROM [datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT] lnk2
      WHERE lnk2.PRODUCT_HUB_ID = hp.HUB_ID
  )

ORDER BY
    sp.MICROSERVICE_NAME,
    sp.PRODUCT_NAME;

-- ============================================================
-- Optional extension: narrow to products that have also been
-- sold (i.e. appear in LNK_LINEITEM_PRODUCT) — these are the
-- highest-priority items missing recipe coverage.
-- ============================================================
--
-- Add this to the WHERE clause above:
--
--   AND EXISTS (
--       SELECT 1
--       FROM [datavault].[LNK_LINEITEM_PRODUCT] llp
--       WHERE llp.PRODUCT_HUB_ID = hp.HUB_ID
--   )
--
-- ============================================================
