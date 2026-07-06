/*
================================================================================
sp_Api_GetCatalog_TotalRecords
--------------------------------------------------------------------------------
Companion to sp_Api_GetCatalog. Returns a single scalar row with the total
number of PRODUCT records (result set 1) the data SP would emit for the given
outlet, so the API caller can decide when to stop or sanity-check completeness.

Categories (result set 2 of the data SP) are a denormalised lookup derived
from the product rows and are intentionally not counted here.

Mirrors the filtering of the product query in sp_Api_GetCatalog exactly:
  - Resolves @LocationId -> @LocationHubId via HUB_LOCATION + SAT_LOCATION
    (CURRENT_FLAG = 1, IS_DELETED = 0, BOTTOM_LEVEL = 1).
  - Products with a price record at the resolved location
    (LNK_LOCATION_OCCASION_PRODUCT joined to SAT_LNK_LOCATION_OCCASION_PRODUCT).
  - SAT_PRODUCT with CURRENT_FLAG = 1, BOTTOM_LEVEL = 1.
  - @UpdatedSince filter on SAT_PRODUCT.LOAD_TS (NULL => no incremental filter).

Unknown @LocationId returns TotalRecords = 0 (matches the empty-result-set
behaviour of the data SP — no error raised).

Output:
  TotalRecords BIGINT  -- one row, one column

Author : XMS BI
Status : DRAFT - not yet deployed
================================================================================
*/

CREATE OR ALTER PROCEDURE [core].[sp_Api_GetCatalog_TotalRecords]
    @LocationId   NVARCHAR(255),
    @UpdatedSince DATETIME2(7) = NULL
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
        SELECT CAST(0 AS BIGINT) AS TotalRecords;
        RETURN;
    END;

    ;WITH prod_prices AS (
        SELECT DISTINCT lnk.PRODUCT_HUB_ID
        FROM [datavault].[LNK_LOCATION_OCCASION_PRODUCT] lnk
        INNER JOIN [datavault].[SAT_LNK_LOCATION_OCCASION_PRODUCT] slop
            ON slop.LNK_ID = lnk.LNK_ID
        WHERE lnk.LOCATION_HUB_ID = @LocationHubId
    )
    SELECT COUNT_BIG(*) AS TotalRecords
    FROM prod_prices pp
    INNER JOIN [datavault].[SAT_PRODUCT] prod
        ON prod.HUB_ID       = pp.PRODUCT_HUB_ID
       AND prod.CURRENT_FLAG = 1
    WHERE prod.BOTTOM_LEVEL = 1
      AND (@UpdatedSince IS NULL OR prod.LOAD_TS >= @UpdatedSince);
END
GO
