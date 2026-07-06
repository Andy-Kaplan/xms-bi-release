/*
================================================================================
sp_Api_GetOrders_TotalRecords
--------------------------------------------------------------------------------
Companion to sp_Api_GetOrders. Returns a single scalar row with the total
number of ORDER records (result set 1) the data SP would emit for the given
outlet and time window — across all pages — so the API caller knows when to
stop paginating.

Mirrors the order-page filter in sp_Api_GetOrders exactly:
  - Resolves @LocationId -> @LocationHubId via HUB_LOCATION + SAT_LOCATION
    (CURRENT_FLAG = 1, IS_DELETED = 0, BOTTOM_LEVEL = 1).
  - SAT_CUSTORDER joined to LNK_CUSTORDER_LOCATION at the resolved location.
  - CURRENT_FLAG = 1.
  - OPEN_TIME in [@StartDate, @EndDate)  (inclusive lower / exclusive upper).
  - Optional @UpdatedSince filter on SAT_CUSTORDER.LOAD_TS.
  - Pagination params (@PageNumber/@PageSize) are intentionally NOT accepted —
    the count is over the entire filtered set.

Line items (result set 2 of the data SP) are joined per order and are not
counted here; the caller paginates orders, not line items.

Unknown @LocationId returns TotalRecords = 0.

Output:
  TotalRecords BIGINT  -- one row, one column

Author : XMS BI
Status : DRAFT - not yet deployed
================================================================================
*/

CREATE OR ALTER PROCEDURE [core].[sp_Api_GetOrders_TotalRecords]
    @LocationId   NVARCHAR(255),
    @StartDate    DATETIME2(7),
    @EndDate      DATETIME2(7),
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

    SELECT COUNT_BIG(*) AS TotalRecords
    FROM [datavault].[SAT_CUSTORDER] sc
    INNER JOIN [datavault].[LNK_CUSTORDER_LOCATION] lcl
        ON lcl.CUSTORDER_HUB_ID = sc.HUB_ID
       AND lcl.LOCATION_HUB_ID  = @LocationHubId
    WHERE sc.CURRENT_FLAG = 1
      AND sc.OPEN_TIME    >= @StartDate
      AND sc.OPEN_TIME    <  @EndDate
      AND (@UpdatedSince IS NULL OR sc.LOAD_TS >= @UpdatedSince);
END
GO
