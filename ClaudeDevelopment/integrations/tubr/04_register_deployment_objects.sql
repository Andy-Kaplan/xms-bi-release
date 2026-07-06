/*
================================================================================
04_register_deployment_objects.sql
--------------------------------------------------------------------------------
Registers the external-API stored procedures (sp_Api_Get*) in
core.core.DeploymentObjects so that sp_DeployObjects can roll them out to
every client database. These SPs serve the forecasting-partner integration
(initial consumer: TUBR) but are intentionally provider-agnostic.

Two groups of SPs are registered:
  - Data SPs (ExecutionOrder 140-142): sp_Api_GetLocations / GetCatalog /
    GetOrders — return tabular result sets for each endpoint.
  - TotalRecords SPs (ExecutionOrder 143-145): sp_Api_Get*_TotalRecords —
    single-row, single-column count companions so the API caller knows
    when to stop paginating or can sanity-check completeness.

Conventions matched to existing card-procedure registrations:
- ObjectType = 'PROCEDURE'
- Schema placeholder is {SCHEMA} (replaced by [core] at deploy time)
- CreationScript contains no leading comment block and no trailing GO
- ExecutionOrder values 140-145 placed after the highest pre-existing value (133)

Idempotent — uses MERGE on (ObjectName, ObjectType). Safe to re-run; the
TotalRecords entries (143-145) were added after the initial Oak & Vine UAT
deployment of 140-142.

Run against : core database (xms-bi managed instance)
Status      : DRAFT - TotalRecords additions not yet deployed
================================================================================
*/

DECLARE @sp_GetLocations NVARCHAR(MAX) = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_Api_GetLocations]
    @DefaultCurrency NVARCHAR(3)    = N''GBP'',
    @DefaultTimezone NVARCHAR(64)   = N''Europe/London''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        loc.LOCATION_ID                                      AS id,
        loc.LOCATION_NAME                                    AS name,
        addr.ADDRESS                                         AS address_line1,
        addr.TOWN                                            AS city,
        addr.REGION                                          AS region,
        addr.POSTCODE                                        AS postal_code,
        addr.COUNTRY                                         AS country,
        @DefaultTimezone                                     AS timezone,
        @DefaultCurrency                                     AS currency,
        CASE WHEN h.IS_DELETED = 1 THEN N''inactive''
             ELSE N''active'' END                            AS status,
        loc.EFFECTIVEFROM                                    AS created_at
    FROM [datavault].[HUB_LOCATION] h
    INNER JOIN [datavault].[SAT_LOCATION] loc
        ON loc.HUB_ID = h.HUB_ID
       AND loc.CURRENT_FLAG = 1
       AND loc.IS_DELETED   = 0
    LEFT JOIN [datavault].[LNK_ADDRESS_LOCATION] lnk
        ON lnk.LOCATION_HUB_ID = h.HUB_ID
       AND lnk.LOCATION_AGG = 1
    LEFT JOIN [datavault].[SAT_ADDRESS] addr
        ON addr.HUB_ID       = lnk.ADDRESS_HUB_ID
       AND addr.CURRENT_FLAG = 1
       AND addr.IS_DELETED   = 0
    WHERE loc.BOTTOM_LEVEL = 1
    ORDER BY loc.LOCATION_NAME;
END';

DECLARE @sp_GetCatalog NVARCHAR(MAX) = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_Api_GetCatalog]
    @LocationId      NVARCHAR(255),
    @UpdatedSince    DATETIME2(7)   = NULL,
    @DefaultCurrency NVARCHAR(3)    = N''GBP''
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
END';

DECLARE @sp_GetOrders NVARCHAR(MAX) = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_Api_GetOrders]
    @LocationId      NVARCHAR(255),
    @StartDate       DATETIME2(7),
    @EndDate         DATETIME2(7),
    @UpdatedSince    DATETIME2(7)   = NULL,
    @PageNumber      INT            = 1,
    @PageSize        INT            = 1000,
    @DefaultCurrency NVARCHAR(3)    = N''GBP''
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

    SELECT
        N''ord_'' + LOWER(CONVERT(VARCHAR(64), sc.HUB_ID, 2))   AS id,
        @LocationId                                             AS location_id,
        sc.OPEN_TIME                                            AS opened_at,
        sc.CLOSE_TIME                                           AS closed_at,
        CASE
            WHEN sc.IS_DELETED = 1                                                  THEN N''voided''
            WHEN UPPER(ISNULL(sc.PAYMENT_STATUS, N'''')) = N''PAID''                THEN N''completed''
            WHEN UPPER(ISNULL(sc.ORDER_STATUS,   N'''')) IN (N''CLOSED'', N''PAID'',
                                                              N''COMPLETED'', N''COMPLETE'') THEN N''completed''
            ELSE LOWER(NULLIF(sc.ORDER_STATUS, N''''))
        END                                                     AS state,
        LOWER(NULLIF(ch.CHANNEL_NAME, N''''))                   AS order_mode,
        CAST(NULL AS NVARCHAR(64))                              AS delivery_partner,
        @DefaultCurrency                                        AS currency,
        COALESCE(sc.GRAND_TOTAL, sc.GROSS_SALES)                AS total,
        ABS(sc.DISCOUNT_GROSS)                                  AS discount_total,
        sc.TAX_TOTAL                                            AS tax_total,
        sc.GROSS_SALES                                          AS gross_sales,
        sc.NET_SALES                                            AS net_sales,
        sc.GUEST_COUNT                                          AS guest_count,
        sc.ITEM_COUNT                                           AS item_count,
        sc.LOAD_TS                                              AS updated_at,
        sc.EXTERNAL_REFERENCE                                   AS source_reference
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

    SELECT
        N''li_''  + LOWER(CONVERT(VARCHAR(64), sl.HUB_ID, 2))   AS id,
        N''ord_'' + LOWER(CONVERT(VARCHAR(64), sc.HUB_ID, 2))   AS order_id,
        CASE WHEN lll.PARENT_HUB_ID IS NULL THEN NULL
             ELSE N''li_'' + LOWER(CONVERT(VARCHAR(64), lll.PARENT_HUB_ID, 2))
        END                                                     AS parent_lineitem_id,
        sl.LINEITEM_TYPE                                        AS lineitem_type,
        sp.PRODUCT_ID                                           AS product_id,
        sp.PRODUCT_NAME                                         AS product_name,
        sl.QUANTITY                                             AS quantity,
        CASE WHEN sl.QUANTITY IS NULL OR sl.QUANTITY = 0 THEN NULL
             ELSE sl.NET_VALUE / sl.QUANTITY END                AS unit_price,
        sl.NET_VALUE                                            AS line_total,
        sl.GROSS_VALUE                                          AS line_gross,
        sl.TAX_VALUE                                            AS tax_total,
        CAST(NULL AS DECIMAL(38,10))                            AS discount_total,
        CASE WHEN sl.VOID_FLAG = 1 THEN CAST(1 AS BIT)
             ELSE CAST(0 AS BIT) END                            AS is_void,
        sl.LINEITEM_TIMESTAMP                                   AS line_timestamp,
        sl.LINE_ORDER                                           AS line_order,
        sl.LINE_ID                                              AS source_line_id
    FROM @OrderPage op
    INNER JOIN [datavault].[LNK_CUSTORDER_LINEITEM] lcli
        ON lcli.CUSTORDER_HUB_ID = op.CUSTORDER_HUB_ID
    INNER JOIN [datavault].[SAT_CUSTORDER] sc
        ON sc.HUB_ID       = lcli.CUSTORDER_HUB_ID
       AND sc.CURRENT_FLAG = 1
    INNER JOIN [datavault].[SAT_LINEITEM] sl
        ON sl.HUB_ID       = lcli.LINEITEM_HUB_ID
       AND sl.CURRENT_FLAG = 1
       AND sl.LINEITEM_TYPE IN (N''PROD'', N''MOD'')
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
END';

-- ---------------------------------------------------------------------------
-- TotalRecords companions: single-row, single-column counts so the API caller
-- can decide when to stop paginating / sanity-check completeness.
-- ---------------------------------------------------------------------------

DECLARE @sp_GetLocations_TotalRecords NVARCHAR(MAX) = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_Api_GetLocations_TotalRecords]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT_BIG(*) AS TotalRecords
    FROM [datavault].[HUB_LOCATION] h
    INNER JOIN [datavault].[SAT_LOCATION] loc
        ON loc.HUB_ID = h.HUB_ID
       AND loc.CURRENT_FLAG = 1
       AND loc.IS_DELETED   = 0
    WHERE loc.BOTTOM_LEVEL = 1;
END';

DECLARE @sp_GetCatalog_TotalRecords NVARCHAR(MAX) = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_Api_GetCatalog_TotalRecords]
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
END';

DECLARE @sp_GetOrders_TotalRecords NVARCHAR(MAX) = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_Api_GetOrders_TotalRecords]
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
END';

-- Drop scripts (idempotent — IF EXISTS)
DECLARE @drop_GetLocations              NVARCHAR(MAX) = N'IF OBJECT_ID(''{SCHEMA}.sp_Api_GetLocations'',              ''P'') IS NOT NULL DROP PROCEDURE {SCHEMA}.[sp_Api_GetLocations]';
DECLARE @drop_GetCatalog                NVARCHAR(MAX) = N'IF OBJECT_ID(''{SCHEMA}.sp_Api_GetCatalog'',                ''P'') IS NOT NULL DROP PROCEDURE {SCHEMA}.[sp_Api_GetCatalog]';
DECLARE @drop_GetOrders                 NVARCHAR(MAX) = N'IF OBJECT_ID(''{SCHEMA}.sp_Api_GetOrders'',                 ''P'') IS NOT NULL DROP PROCEDURE {SCHEMA}.[sp_Api_GetOrders]';
DECLARE @drop_GetLocations_TotalRecords NVARCHAR(MAX) = N'IF OBJECT_ID(''{SCHEMA}.sp_Api_GetLocations_TotalRecords'', ''P'') IS NOT NULL DROP PROCEDURE {SCHEMA}.[sp_Api_GetLocations_TotalRecords]';
DECLARE @drop_GetCatalog_TotalRecords   NVARCHAR(MAX) = N'IF OBJECT_ID(''{SCHEMA}.sp_Api_GetCatalog_TotalRecords'',   ''P'') IS NOT NULL DROP PROCEDURE {SCHEMA}.[sp_Api_GetCatalog_TotalRecords]';
DECLARE @drop_GetOrders_TotalRecords    NVARCHAR(MAX) = N'IF OBJECT_ID(''{SCHEMA}.sp_Api_GetOrders_TotalRecords'',    ''P'') IS NOT NULL DROP PROCEDURE {SCHEMA}.[sp_Api_GetOrders_TotalRecords]';

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (
    VALUES
        (N'sp_Api_GetLocations', 'PROCEDURE', 140, N'External API Procedures',
         N'Returns one row per active outlet for the external API GET /v1/locations endpoint.',
         @sp_GetLocations, @drop_GetLocations),
        (N'sp_Api_GetCatalog',   'PROCEDURE', 141, N'External API Procedures',
         N'Returns products and categories for a single outlet for the external API GET /v1/locations/{id}/catalog endpoint.',
         @sp_GetCatalog,   @drop_GetCatalog),
        (N'sp_Api_GetOrders',    'PROCEDURE', 142, N'External API Procedures',
         N'Returns paged orders and line items for a single outlet for the external API GET /v1/locations/{id}/orders endpoint.',
         @sp_GetOrders,    @drop_GetOrders),
        (N'sp_Api_GetLocations_TotalRecords', 'PROCEDURE', 143, N'External API Procedures',
         N'Returns the total count of records sp_Api_GetLocations would emit. Single scalar row (TotalRecords BIGINT) for pagination/completeness checks.',
         @sp_GetLocations_TotalRecords, @drop_GetLocations_TotalRecords),
        (N'sp_Api_GetCatalog_TotalRecords',   'PROCEDURE', 144, N'External API Procedures',
         N'Returns the total count of product records sp_Api_GetCatalog would emit for the given outlet. Single scalar row (TotalRecords BIGINT). Categories are not counted.',
         @sp_GetCatalog_TotalRecords,   @drop_GetCatalog_TotalRecords),
        (N'sp_Api_GetOrders_TotalRecords',    'PROCEDURE', 145, N'External API Procedures',
         N'Returns the total count of order records sp_Api_GetOrders would emit for the given outlet and date range (all pages). Single scalar row (TotalRecords BIGINT).',
         @sp_GetOrders_TotalRecords,    @drop_GetOrders_TotalRecords)
) AS src (ObjectName, ObjectType, ExecutionOrder, Category, Description, CreationScript, DropScript)
ON  tgt.ObjectName = src.ObjectName
AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = src.ExecutionOrder,
        Category       = src.Category,
        Description    = src.Description,
        CreationScript = src.CreationScript,
        DropScript     = src.DropScript,
        IsActive       = 1,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (src.ObjectName, src.ObjectType, src.ExecutionOrder, src.Category, src.Description,
            src.CreationScript, src.DropScript, 1, GETDATE());

PRINT N'Registered 6 external API procedures in core.DeploymentObjects (3 data + 3 TotalRecords).';
PRINT N'Roll out to all client databases via core.sp_DeployObjects (per-org cursor).';
GO
