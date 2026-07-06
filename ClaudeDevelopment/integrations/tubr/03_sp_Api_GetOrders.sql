/*
================================================================================
sp_Api_GetOrders
--------------------------------------------------------------------------------
Returns customer orders and their line items for a single outlet, paged by
OPEN_TIME. Two result sets:

  1. ORDERS     -- one row per CUSTORDER in the requested page.
  2. LINE_ITEMS -- one row per LINEITEM where LINEITEM_TYPE IN ('PROD','MOD')
                   that belongs to one of the orders in result set 1.
                   MODs (modifiers attached to a parent PROD line) are returned
                   as separate rows; the API consumer is responsible for re-
                   parenting them via lineitem_type if a nested shape is
                   needed. Joined back to result set 1 via order_id.

Filtering:
- @LocationId  : required, scopes to one outlet.
- @StartDate   : required, inclusive lower bound on SAT_CUSTORDER.OPEN_TIME.
- @EndDate     : required, exclusive upper bound on SAT_CUSTORDER.OPEN_TIME.
- @UpdatedSince: optional, returns only orders modified since this timestamp
                 (filters on SAT_CUSTORDER.LOAD_TS) for incremental polling.

Pagination uses OFFSET/FETCH ordered by (OPEN_TIME ASC, HUB_ID ASC). Cursor-
based pagination can be added later; for now the API layer should drive
pagination via @PageNumber / @PageSize and detect the last page when row count
returned is less than @PageSize.

Order ID and line ID are stable hex representations of the SHA-256 hub keys
(prefixed with ord_ and li_), guaranteeing uniqueness and stability across
re-fetches. Designed to be invoked by an external API consumer (e.g. a
forecasting partner).

Order state derivation:
- 'voided'    if SAT_CUSTORDER.IS_DELETED = 1
- 'completed' if SAT_CUSTORDER.ORDER_STATUS IN ('CLOSED','PAID','COMPLETED')
              or PAYMENT_STATUS = 'PAID'
- otherwise   ORDER_STATUS as supplied by the source

order_mode is sourced from SAT_CHANNEL.CHANNEL_NAME via LNK_CHANNEL_CUSTORDER.
Returns NULL if no channel link exists for the order.

Author : XMS BI
Status : DRAFT - not yet deployed
================================================================================
*/

CREATE OR ALTER PROCEDURE [core].[sp_Api_GetOrders]
    @LocationId      NVARCHAR(255),
    @StartDate       DATETIME2(7),
    @EndDate         DATETIME2(7),
    @UpdatedSince    DATETIME2(7)   = NULL,
    @PageNumber      INT            = 1,
    @PageSize        INT            = 1000,
    @DefaultCurrency NVARCHAR(3)    = N'GBP'
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize  < 1 SET @PageSize  = 1000;
    IF @PageSize  > 5000 SET @PageSize = 5000;

    DECLARE @LocationHubId BINARY(32);

    SELECT TOP (1) @LocationHubId = h.HUB_ID
    FROM [datavault].[HUB_LOCATION] h
    INNER JOIN [datavault].[SAT_LOCATION] loc
        ON loc.HUB_ID = h.HUB_ID
       AND loc.CURRENT_FLAG = 1
       AND loc.IS_DELETED   = 0
    WHERE loc.LOCATION_ID = @LocationId
      AND loc.BOTTOM_LEVEL = 1;

    -- Materialise the page of order hub IDs once, reused by both result sets
    DECLARE @OrderPage TABLE (
        CUSTORDER_HUB_ID BINARY(32) NOT NULL PRIMARY KEY,
        OPEN_TIME        DATETIME2(7) NULL
    );

    IF @LocationHubId IS NOT NULL
    BEGIN
        INSERT INTO @OrderPage (CUSTORDER_HUB_ID, OPEN_TIME)
        SELECT
            sc.HUB_ID,
            sc.OPEN_TIME
        FROM [datavault].[SAT_CUSTORDER] sc
        INNER JOIN [datavault].[LNK_CUSTORDER_LOCATION] lcl
            ON lcl.CUSTORDER_HUB_ID = sc.HUB_ID
           AND lcl.LOCATION_HUB_ID  = @LocationHubId
        WHERE sc.CURRENT_FLAG = 1
          AND sc.OPEN_TIME    >= @StartDate
          AND sc.OPEN_TIME    <  @EndDate
          AND (@UpdatedSince IS NULL OR sc.LOAD_TS >= @UpdatedSince)
        ORDER BY sc.OPEN_TIME ASC, sc.HUB_ID ASC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    END;

    -- Result set 1: orders
    SELECT
        N'ord_' + LOWER(CONVERT(VARCHAR(64), sc.HUB_ID, 2))   AS id,
        @LocationId                                           AS location_id,
        sc.OPEN_TIME                                          AS opened_at,
        sc.CLOSE_TIME                                         AS closed_at,
        CASE
            WHEN sc.IS_DELETED = 1                                                  THEN N'voided'
            WHEN UPPER(ISNULL(sc.PAYMENT_STATUS, N'')) = N'PAID'                    THEN N'completed'
            WHEN UPPER(ISNULL(sc.ORDER_STATUS,   N'')) IN (N'CLOSED', N'PAID',
                                                            N'COMPLETED', N'COMPLETE') THEN N'completed'
            ELSE LOWER(NULLIF(sc.ORDER_STATUS, N''))
        END                                                   AS state,
        LOWER(NULLIF(ch.CHANNEL_NAME, N''))                   AS order_mode,
        CAST(NULL AS NVARCHAR(64))                            AS delivery_partner,
        @DefaultCurrency                                      AS currency,
        COALESCE(sc.GRAND_TOTAL, sc.GROSS_SALES)              AS total,
        ABS(sc.DISCOUNT_GROSS)                                AS discount_total,
        sc.TAX_TOTAL                                          AS tax_total,
        sc.GROSS_SALES                                        AS gross_sales,
        sc.NET_SALES                                          AS net_sales,
        sc.GUEST_COUNT                                        AS guest_count,
        sc.ITEM_COUNT                                         AS item_count,
        sc.LOAD_TS                                            AS updated_at,
        sc.EXTERNAL_REFERENCE                                 AS source_reference
    FROM @OrderPage op
    INNER JOIN [datavault].[SAT_CUSTORDER] sc
        ON sc.HUB_ID       = op.CUSTORDER_HUB_ID
       AND sc.CURRENT_FLAG = 1
    LEFT JOIN [datavault].[LNK_CHANNEL_CUSTORDER] lcc
        ON lcc.CUSTORDER_HUB_ID = sc.HUB_ID
       AND lcc.CUSTORDER_AGG    = 1
    LEFT JOIN [datavault].[SAT_CHANNEL] ch
        ON ch.HUB_ID       = lcc.CHANNEL_HUB_ID
       AND ch.CURRENT_FLAG = 1
       AND ch.IS_DELETED   = 0
    ORDER BY sc.OPEN_TIME ASC, sc.HUB_ID ASC;

    -- Result set 2: line items (PROD only) for the orders in result set 1
    SELECT
        N'li_'  + LOWER(CONVERT(VARCHAR(64), sl.HUB_ID, 2))   AS id,
        N'ord_' + LOWER(CONVERT(VARCHAR(64), sc.HUB_ID, 2))   AS order_id,
        CASE WHEN lll.PARENT_HUB_ID IS NULL THEN NULL
             ELSE N'li_' + LOWER(CONVERT(VARCHAR(64), lll.PARENT_HUB_ID, 2))
        END                                                   AS parent_lineitem_id,
        sl.LINEITEM_TYPE                                      AS lineitem_type,
        sp.PRODUCT_ID                                         AS product_id,
        sp.PRODUCT_NAME                                       AS product_name,
        sl.QUANTITY                                           AS quantity,
        CASE WHEN sl.QUANTITY IS NULL OR sl.QUANTITY = 0 THEN NULL
             ELSE sl.NET_VALUE / sl.QUANTITY END              AS unit_price,
        sl.NET_VALUE                                          AS line_total,
        sl.GROSS_VALUE                                        AS line_gross,
        sl.TAX_VALUE                                          AS tax_total,
        CAST(NULL AS DECIMAL(38,10))                          AS discount_total,
        CASE WHEN sl.VOID_FLAG = 1 THEN CAST(1 AS BIT)
             ELSE CAST(0 AS BIT) END                          AS is_void,
        sl.LINEITEM_TIMESTAMP                                 AS line_timestamp,
        sl.LINE_ORDER                                         AS line_order,
        sl.LINE_ID                                            AS source_line_id
    FROM @OrderPage op
    INNER JOIN [datavault].[LNK_CUSTORDER_LINEITEM] lcli
        ON lcli.CUSTORDER_HUB_ID = op.CUSTORDER_HUB_ID
    INNER JOIN [datavault].[SAT_CUSTORDER] sc
        ON sc.HUB_ID       = lcli.CUSTORDER_HUB_ID
       AND sc.CURRENT_FLAG = 1
    INNER JOIN [datavault].[SAT_LINEITEM] sl
        ON sl.HUB_ID       = lcli.LINEITEM_HUB_ID
       AND sl.CURRENT_FLAG = 1
       AND sl.LINEITEM_TYPE IN (N'PROD', N'MOD')
    LEFT JOIN [datavault].[LNK_LINEITEM_PRODUCT] lp
        ON lp.LINEITEM_HUB_ID = sl.HUB_ID
       AND lp.LINEITEM_AGG    = 1
    LEFT JOIN [datavault].[SAT_PRODUCT] sp
        ON sp.HUB_ID       = lp.PRODUCT_HUB_ID
       AND sp.CURRENT_FLAG = 1
    LEFT JOIN [datavault].[LNK_LINEITEM_LINEITEM] lll
        ON lll.CHILD_HUB_ID = sl.HUB_ID
       AND lll.CHILD_AGG    = 1
    ORDER BY sc.OPEN_TIME ASC, sc.HUB_ID ASC, sl.LINE_ORDER ASC;
END
GO
