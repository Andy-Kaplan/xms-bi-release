/*
    Seed Oak & Vine location addresses (UAT)
    ----------------------------------------
    Populates HUB_ADDRESS / SAT_ADDRESS / LNK_ADDRESS_LOCATION for the
    six bottom-level Oak & Vine outlets so that sp_TubrApi_GetLocations
    returns sensible address data.

    Source convention: matches HUB_LOCATION SRC = 'int_ncraloha001' (the
    integration that originally loaded the Oak & Vine locations).

    Hash key convention:
        HUB_ID = HASHBYTES('SHA2_256', CAST(N'<business_key>|<src>' AS VARBINARY(MAX)))
        LNK_ID = HASHBYTES('SHA2_256', ADDRESS_HUB_ID + LOCATION_HUB_ID)

    Business key for ADDRESS hub: N'ADDR_' + LOCATION_ID  (one address per outlet)

    AGG flags: set to 1 on both sides — the Tubr GetLocations query filters
    LOCATION_AGG = 1, and each location has exactly one canonical address.

    Run against the Oak & Vine UAT database:
        USE [20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87];
        :r 05_seed_oak_vine_addresses.sql

    Idempotent — uses MERGE so it can be safely re-run.
*/

SET NOCOUNT ON;

DECLARE @SRC          NVARCHAR(255) = N'int_ncraloha001';
DECLARE @LoadTs       DATETIME2     = SYSUTCDATETIME();
DECLARE @EffectiveFrom DATETIME2    = '2025-09-30T00:00:00';  -- matches existing SAT_LOCATION rows
DECLARE @EffectiveTo   DATETIME2    = '9999-12-31T23:59:59';

-- ---------------------------------------------------------------------------
-- 1. Address data, keyed by LOCATION_ID
-- ---------------------------------------------------------------------------
DECLARE @Addresses TABLE (
    LOCATION_ID NVARCHAR(50),
    ADDRESS     NVARCHAR(255),
    TOWN        NVARCHAR(255),
    COUNTY      NVARCHAR(255),
    REGION      NVARCHAR(255),
    POSTCODE    NVARCHAR(255),
    COUNTRY     NVARCHAR(255),
    LAT         NVARCHAR(255),
    LONG        NVARCHAR(255)
);

INSERT INTO @Addresses VALUES
    (N'LOC001', N'24 Dean Street',    N'London',     N'Greater London',     N'England',  N'W1D 3RY',  N'United Kingdom', N'51.5136', N'-0.1318'),
    (N'LOC002', N'42 Long Acre',      N'London',     N'Greater London',     N'England',  N'WC2E 9JY', N'United Kingdom', N'51.5125', N'-0.1247'),
    (N'LOC003', N'156 Deansgate',     N'Manchester', N'Greater Manchester', N'England',  N'M3 3WD',   N'United Kingdom', N'53.4795', N'-2.2497'),
    (N'LOC004', N'18 Oldham Street',  N'Manchester', N'Greater Manchester', N'England',  N'M1 1JN',   N'United Kingdom', N'53.4836', N'-2.2369'),
    (N'LOC005', N'87 Grassmarket',    N'Edinburgh',  N'Midlothian',         N'Scotland', N'EH1 2HJ',  N'United Kingdom', N'55.9479', N'-3.1944'),
    (N'LOC006', N'32 George Street',  N'Edinburgh',  N'Midlothian',         N'Scotland', N'EH2 2LR',  N'United Kingdom', N'55.9536', N'-3.1990');

-- ---------------------------------------------------------------------------
-- 2. Resolve LOCATION_HUB_ID + compute ADDRESS_HUB_ID for each outlet
-- ---------------------------------------------------------------------------
DECLARE @Work TABLE (
    LOCATION_ID     NVARCHAR(50),
    LOCATION_HUB_ID BINARY(32),
    ADDRESS_HUB_ID  BINARY(32),
    LNK_ID          BINARY(32),
    ADDRESS         NVARCHAR(255),
    TOWN            NVARCHAR(255),
    COUNTY          NVARCHAR(255),
    REGION          NVARCHAR(255),
    POSTCODE        NVARCHAR(255),
    COUNTRY         NVARCHAR(255),
    LAT             NVARCHAR(255),
    LONG            NVARCHAR(255)
);

INSERT INTO @Work
SELECT
    a.LOCATION_ID,
    sl.HUB_ID                                                                  AS LOCATION_HUB_ID,
    HASHBYTES('SHA2_256', CAST(N'ADDR_' + a.LOCATION_ID + N'|' + @SRC AS VARBINARY(MAX))) AS ADDRESS_HUB_ID,
    HASHBYTES('SHA2_256',
        HASHBYTES('SHA2_256', CAST(N'ADDR_' + a.LOCATION_ID + N'|' + @SRC AS VARBINARY(MAX)))
      + sl.HUB_ID
    )                                                                          AS LNK_ID,
    a.ADDRESS, a.TOWN, a.COUNTY, a.REGION, a.POSTCODE, a.COUNTRY, a.LAT, a.LONG
FROM @Addresses a
INNER JOIN [datavault].[SAT_LOCATION] sl
    ON sl.LOCATION_ID  = a.LOCATION_ID
   AND sl.CURRENT_FLAG = 1
   AND sl.IS_DELETED   = 0;

IF (SELECT COUNT(*) FROM @Work) <> 6
BEGIN
    DECLARE @found INT = (SELECT COUNT(*) FROM @Work);
    RAISERROR(N'Expected 6 Oak & Vine outlet locations, found %d. Aborting.', 16, 1, @found);
    RETURN;
END;

-- ---------------------------------------------------------------------------
-- 3. HUB_ADDRESS — upsert one row per outlet
-- ---------------------------------------------------------------------------
MERGE INTO [datavault].[HUB_ADDRESS] AS tgt
USING (SELECT DISTINCT ADDRESS_HUB_ID FROM @Work) AS src
    ON tgt.HUB_ID = src.ADDRESS_HUB_ID
WHEN NOT MATCHED THEN
    INSERT (HUB_ID, SRC, IS_DELETED, LOAD_TS)
    VALUES (src.ADDRESS_HUB_ID, @SRC, 0, @LoadTs);

-- ---------------------------------------------------------------------------
-- 4. SAT_ADDRESS — close any superseded current rows, then insert current
-- ---------------------------------------------------------------------------
UPDATE sat
SET    CURRENT_FLAG  = 0,
       EFFECTIVETO   = @EffectiveFrom
FROM   [datavault].[SAT_ADDRESS] sat
INNER  JOIN @Work w ON w.ADDRESS_HUB_ID = sat.HUB_ID
WHERE  sat.CURRENT_FLAG = 1
  AND  (
        ISNULL(sat.ADDRESS,  N'') <> w.ADDRESS  OR
        ISNULL(sat.TOWN,     N'') <> w.TOWN     OR
        ISNULL(sat.COUNTY,   N'') <> w.COUNTY   OR
        ISNULL(sat.REGION,   N'') <> w.REGION   OR
        ISNULL(sat.POSTCODE, N'') <> w.POSTCODE OR
        ISNULL(sat.COUNTRY,  N'') <> w.COUNTRY  OR
        ISNULL(sat.LAT,      N'') <> w.LAT      OR
        ISNULL(sat.[LONG],   N'') <> w.[LONG]
       );

INSERT INTO [datavault].[SAT_ADDRESS]
    (HUB_ID, SRC, LOAD_TS, EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG, IS_DELETED,
     ADDRESS, POSTCODE, REGION, COUNTRY, LAT, [LONG], TOWN, COUNTY)
SELECT
    w.ADDRESS_HUB_ID, @SRC, @LoadTs, @EffectiveFrom, @EffectiveTo, 1, 0,
    w.ADDRESS, w.POSTCODE, w.REGION, w.COUNTRY, w.LAT, w.[LONG], w.TOWN, w.COUNTY
FROM @Work w
WHERE NOT EXISTS (
    SELECT 1
    FROM   [datavault].[SAT_ADDRESS] sat
    WHERE  sat.HUB_ID       = w.ADDRESS_HUB_ID
      AND  sat.CURRENT_FLAG = 1
);

-- ---------------------------------------------------------------------------
-- 5. LNK_ADDRESS_LOCATION — one link per outlet, AGG flags = 1
-- ---------------------------------------------------------------------------
MERGE INTO [datavault].[LNK_ADDRESS_LOCATION] AS tgt
USING (
    SELECT ADDRESS_HUB_ID, LOCATION_HUB_ID, LNK_ID FROM @Work
) AS src
    ON tgt.ADDRESS_HUB_ID  = src.ADDRESS_HUB_ID
   AND tgt.LOCATION_HUB_ID = src.LOCATION_HUB_ID
WHEN NOT MATCHED THEN
    INSERT (LNK_ID, SRC, LOAD_TS, ADDRESS_HUB_ID, LOCATION_HUB_ID, ADDRESS_AGG, LOCATION_AGG)
    VALUES (src.LNK_ID, @SRC, @LoadTs, src.ADDRESS_HUB_ID, src.LOCATION_HUB_ID, 1, 1);

-- ---------------------------------------------------------------------------
-- 6. Verify — should return 6 rows with address data populated
-- ---------------------------------------------------------------------------
SELECT
    loc.LOCATION_ID                                      AS id,
    loc.LOCATION_NAME                                    AS name,
    addr.ADDRESS                                         AS address_line1,
    addr.TOWN                                            AS city,
    addr.REGION                                          AS region,
    addr.POSTCODE                                        AS postal_code,
    addr.COUNTRY                                         AS country,
    'Europe/London'                                      AS timezone,
    'GBP'                                                AS currency,
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
WHERE loc.BOTTOM_LEVEL = 1
ORDER BY loc.LOCATION_NAME;
