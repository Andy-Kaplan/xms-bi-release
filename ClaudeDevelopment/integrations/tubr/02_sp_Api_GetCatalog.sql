/*
================================================================================
sp_Api_GetCatalog
--------------------------------------------------------------------------------
Returns the product catalogue for a single outlet. Two result sets:

  1. PRODUCTS  -- one row per leaf product (BOTTOM_LEVEL = 1) that has a price
                  recorded at @LocationId. Includes denormalised category_id
                  and category_name from the parent product in the hierarchy.
  2. CATEGORIES -- one row per non-leaf product (a category) that is referenced
                   as the parent of any product returned in result set 1.

Notes:
- Prices and costs are sourced from SAT_LNK_LOCATION_OCCASION_PRODUCT, which is
  keyed by (LOCATION, OCCASION, PRODUCT). When a product has multiple occasion
  prices at the same location, MAX(NET_PRICE) and MAX(NET_COST) are returned.
- @UpdatedSince filters by SAT_PRODUCT.LOAD_TS for incremental sync support.
- Currency is sourced from the @DefaultCurrency parameter (no per-org currency
  in the data model yet).

Author : XMS BI
Status : DRAFT - not yet deployed
================================================================================
*/

CREATE OR ALTER PROCEDURE [core].[sp_Api_GetCatalog]
    @LocationId      NVARCHAR(255),
    @UpdatedSince    DATETIME2(7)   = NULL,
    @DefaultCurrency NVARCHAR(3)    = N'GBP'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LocationHubId BINARY(32);

    SELECT TOP (1) @LocationHubId = h.HUB_ID
    FROM [datavault].[HUB_LOCATION] h
    INNER JOIN [datavault].[SAT_LOCATION] loc
        ON loc.HUB_ID = h.HUB_ID
       AND loc.CURRENT_FLAG = 1
       AND loc.IS_DELETED   = 0
    WHERE loc.LOCATION_ID = @LocationId
      AND loc.BOTTOM_LEVEL = 1;

    IF @LocationHubId IS NULL
    BEGIN
        -- Empty result sets - location not found
        SELECT TOP (0)
            CAST(NULL AS NVARCHAR(255))   AS id,
            CAST(NULL AS NVARCHAR(255))   AS name,
            CAST(NULL AS NVARCHAR(255))   AS category_id,
            CAST(NULL AS NVARCHAR(255))   AS category_name,
            CAST(NULL AS DECIMAL(38,10))  AS sales_price,
            CAST(NULL AS DECIMAL(38,10))  AS cost_price,
            CAST(NULL AS NVARCHAR(3))     AS currency,
            CAST(NULL AS BIT)             AS is_active,
            CAST(NULL AS DATETIME2(7))    AS updated_at;

        SELECT TOP (0)
            CAST(NULL AS NVARCHAR(255))   AS id,
            CAST(NULL AS NVARCHAR(255))   AS name,
            CAST(NULL AS NVARCHAR(255))   AS parent_category_id;

        RETURN;
    END;

    -- Result set 1: products
    WITH prod_prices AS (
        SELECT
            lnk.PRODUCT_HUB_ID,
            MAX(slop.NET_PRICE) AS sales_price,
            MAX(slop.NET_COST)  AS cost_price,
            MAX(slop.LOAD_TS)   AS price_updated_at
        FROM [datavault].[LNK_LOCATION_OCCASION_PRODUCT] lnk
        INNER JOIN [datavault].[SAT_LNK_LOCATION_OCCASION_PRODUCT] slop
            ON slop.LNK_ID = lnk.LNK_ID
        WHERE lnk.LOCATION_HUB_ID = @LocationHubId
        GROUP BY lnk.PRODUCT_HUB_ID
    )
    SELECT
        prod.PRODUCT_ID                                   AS id,
        prod.PRODUCT_NAME                                 AS name,
        cat.PRODUCT_ID                                    AS category_id,
        cat.PRODUCT_NAME                                  AS category_name,
        pp.sales_price                                    AS sales_price,
        pp.cost_price                                     AS cost_price,
        @DefaultCurrency                                  AS currency,
        CASE WHEN prod.IS_DELETED = 1 THEN CAST(0 AS BIT)
             ELSE CAST(1 AS BIT) END                      AS is_active,
        COALESCE(prod.LOAD_TS, prod.EFFECTIVEFROM)        AS updated_at
    FROM prod_prices pp
    INNER JOIN [datavault].[SAT_PRODUCT] prod
        ON prod.HUB_ID       = pp.PRODUCT_HUB_ID
       AND prod.CURRENT_FLAG = 1
    LEFT JOIN [datavault].[SAT_PRODUCT] cat
        ON cat.PRODUCT_ID    = prod.PARENT_ID
       AND cat.CURRENT_FLAG  = 1
       AND cat.IS_DELETED    = 0
    WHERE prod.BOTTOM_LEVEL = 1
      AND (@UpdatedSince IS NULL OR prod.LOAD_TS >= @UpdatedSince)
    ORDER BY prod.PRODUCT_NAME;

    -- Result set 2: categories referenced by the products returned above
    WITH prod_at_loc AS (
        SELECT DISTINCT lnk.PRODUCT_HUB_ID
        FROM [datavault].[LNK_LOCATION_OCCASION_PRODUCT] lnk
        WHERE lnk.LOCATION_HUB_ID = @LocationHubId
    ),
    referenced_parent_ids AS (
        SELECT DISTINCT prod.PARENT_ID
        FROM prod_at_loc pal
        INNER JOIN [datavault].[SAT_PRODUCT] prod
            ON prod.HUB_ID       = pal.PRODUCT_HUB_ID
           AND prod.CURRENT_FLAG = 1
        WHERE prod.PARENT_ID IS NOT NULL
    )
    SELECT
        cat.PRODUCT_ID    AS id,
        cat.PRODUCT_NAME  AS name,
        cat.PARENT_ID     AS parent_category_id
    FROM referenced_parent_ids r
    INNER JOIN [datavault].[SAT_PRODUCT] cat
        ON cat.PRODUCT_ID    = r.PARENT_ID
       AND cat.CURRENT_FLAG  = 1
       AND cat.IS_DELETED    = 0
    ORDER BY cat.PRODUCT_NAME;
END
GO
