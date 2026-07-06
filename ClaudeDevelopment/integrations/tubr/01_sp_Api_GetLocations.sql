/*
================================================================================
sp_Api_GetLocations
--------------------------------------------------------------------------------
Returns one row per active outlet (HUB_LOCATION at BOTTOM_LEVEL = 1) for the
client database this SP is deployed in. Designed to be invoked by an external
API consumer (e.g. a forecasting partner) after it resolves OrganisationCode
-> DatabaseName from core.core.Organisations and connects to the resolved DB.

Output shape: GET /v1/locations.
Currency and timezone are not yet stored on Organisations or SAT_LOCATION;
defaults are surfaced from @DefaultCurrency / @DefaultTimezone parameters.

Author : XMS BI
Status : DRAFT - not yet deployed
================================================================================
*/

CREATE OR ALTER PROCEDURE [core].[sp_Api_GetLocations]
    @DefaultCurrency NVARCHAR(3)    = N'GBP',
    @DefaultTimezone NVARCHAR(64)   = N'Europe/London'
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
        @DefaultCurrency                                     AS timezone,
        @DefaultTimezone                                     AS currency,
        CASE WHEN h.IS_DELETED = 1 THEN N'inactive'
             ELSE N'active' END                              AS status,
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
    WHERE loc.BOTTOM_LEVEL = 1   -- leaf-level locations are individual outlets
    ORDER BY loc.LOCATION_NAME;
END
GO
