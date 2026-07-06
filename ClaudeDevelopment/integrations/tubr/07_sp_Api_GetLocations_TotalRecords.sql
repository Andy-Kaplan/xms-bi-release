/*
================================================================================
sp_Api_GetLocations_TotalRecords
--------------------------------------------------------------------------------
Companion to sp_Api_GetLocations. Returns a single scalar row with the total
number of records the data SP would emit, so the API caller can decide when
to stop or sanity-check completeness.

Mirrors the filtering of sp_Api_GetLocations exactly:
  - HUB_LOCATION joined to SAT_LOCATION with CURRENT_FLAG = 1, IS_DELETED = 0
  - BOTTOM_LEVEL = 1 (leaf-level outlets only)
  - Address join is LEFT in the data SP and does not affect cardinality;
    omitted here.

Output:
  TotalRecords BIGINT  -- one row, one column

Author : XMS BI
Status : DRAFT - not yet deployed
================================================================================
*/

CREATE OR ALTER PROCEDURE [core].[sp_Api_GetLocations_TotalRecords]
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
END
GO
