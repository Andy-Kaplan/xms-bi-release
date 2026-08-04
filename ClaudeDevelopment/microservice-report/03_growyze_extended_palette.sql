-- ============================================================================
-- 03 — "Growyze Extended" organisation palette for all Growyze UAT orgs
-- Target: microservice report database  (UAT: xms-mssql-ne-uat, database `report`)
-- ============================================================================
-- Adds a SECOND organisation palette alongside the existing 4-colour "Growyze".
-- Purpose: the original palette has only 4 colours against system palettes' 6-10,
-- so any card with more than 4 series exhausts it. "Growyze Extended" carries 9.
--
-- Palette: "Growyze Extended"   (SortOrder 10 — sits after "Growyze" at 0)
--
--   #  Name        Hex        SortOrder
--   1  Deep Blue   #000055     0
--   2  Turquoise   #34DBD1    10
--   3  Pink        #FC3762    20
--   4  Amber       #F5A524    30
--   5  Violet      #6A4BD8    40
--   6  Green       #17A673    50
--   7  Plum        #A02463    60
--   8  Azure       #2E86E0    70
--   9  Deep Teal   #0B6F6B    80
--
-- NOTE: this deliberately does NOT carry #F3F3FF (Soft Light) from the original
-- 4-colour palette. That value is a near-white neutral and would be effectively
-- invisible as a chart series. The first three colours are unchanged, so the
-- brand identity is preserved and Extended reads as a superset in practice.
--
-- Orgs (all five Growyze-fed UAT orgs):
--   Padel Social          94A4B719-EB0F-421F-AD03-ABECDD888B14   (OrgID 10)
--   Dirty Sixth           7B50D717-124C-4902-ADD2-439A9310326A   (OrgID 18)
--   The Oak & Vine        7ED2E768-0D22-F111-832F-000D3AB27D87   (OrgID 16)
--   Ibis Gloucester Road  67CA4E6F-9A7E-F111-B337-002248A1EC3D   (OrgID 21)
--   Ibis Heathrow         7CE02464-9A7E-F111-B337-002248A1EC3D   (OrgID 20)
--
-- Both palettes coexist: each org will show "Growyze" AND "Growyze Extended"
-- under the "Organisation" group in the picker. The original is left untouched.
--
-- ---------------------------------------------------------------------------
-- IDEMPOTENT. Safe to re-run. Guards every insert with NOT EXISTS, because
-- there is NO unique constraint on (OrganisationId, Name) — a bare INSERT would
-- silently create duplicate palettes and BOTH would appear in the picker.
--
-- HOUSE RULES OBSERVED:
--   - never specify the PK ({Table}Id) — DEFAULT NEWSEQUENTIALID()
--   - never specify TransactionId — IDENTITY
--   - always set IsDeleted = 0 explicitly (no default on these two tables)
--
-- ⚠️ CACHE: the app caches report-DB config and a direct SQL write does NOT
--   invalidate it. The new palette will not appear in the UI until the cache is
--   cleared (the admin tools do this automatically; a SQL script does not).
--
-- ⚠️ SCOPE: defining an org palette makes it SELECTABLE, not applied. There is
--   no organisation-level default — see ledger O26 / XMSE-1756.
-- ============================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @PaletteName nvarchar(256) = N'Growyze Extended';

DECLARE @Targets TABLE
(
    OrganisationId uniqueidentifier PRIMARY KEY,
    OrgName        nvarchar(100)
);

INSERT INTO @Targets (OrganisationId, OrgName) VALUES
    (N'94A4B719-EB0F-421F-AD03-ABECDD888B14', N'Padel Social'),
    (N'7B50D717-124C-4902-ADD2-439A9310326A', N'Dirty Sixth'),
    (N'7ED2E768-0D22-F111-832F-000D3AB27D87', N'The Oak & Vine'),
    (N'67CA4E6F-9A7E-F111-B337-002248A1EC3D', N'Ibis Gloucester Road'),
    (N'7CE02464-9A7E-F111-B337-002248A1EC3D', N'Ibis Heathrow');

DECLARE @Colours TABLE
(
    Colour     nvarchar(7),
    SortOrder  int PRIMARY KEY,
    ColourName nvarchar(50)
);

INSERT INTO @Colours (Colour, SortOrder, ColourName) VALUES
    (N'#000055',  0, N'Deep Blue'),
    (N'#34DBD1', 10, N'Turquoise'),
    (N'#FC3762', 20, N'Pink'),
    (N'#F5A524', 30, N'Amber'),
    (N'#6A4BD8', 40, N'Violet'),
    (N'#17A673', 50, N'Green'),
    (N'#A02463', 60, N'Plum'),
    (N'#2E86E0', 70, N'Azure'),
    (N'#0B6F6B', 80, N'Deep Teal');

BEGIN TRANSACTION;

    -- 1. Parent palette row, one per target org, only where absent.
    INSERT INTO dbo.OrganisationDashboardPalette
        (OrganisationId, Name, IsDeleted, SortOrder)
    SELECT t.OrganisationId, @PaletteName, 0, 10
    FROM @Targets AS t
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.OrganisationDashboardPalette AS p
        WHERE p.OrganisationId = t.OrganisationId
          AND p.Name           = @PaletteName
          AND p.IsDeleted      = 0
    );

    -- 2. Colour rows, only where absent for that palette + position.
    INSERT INTO dbo.OrganisationDashboardPaletteColour
        (OrganisationDashboardPaletteId, Colour, IsDeleted, SortOrder)
    SELECT p.OrganisationDashboardPaletteId, c.Colour, 0, c.SortOrder
    FROM dbo.OrganisationDashboardPalette AS p
    INNER JOIN @Targets AS t
        ON t.OrganisationId = p.OrganisationId
    CROSS JOIN @Colours AS c
    WHERE p.Name      = @PaletteName
      AND p.IsDeleted = 0
      AND NOT EXISTS (
        SELECT 1
        FROM dbo.OrganisationDashboardPaletteColour AS x
        WHERE x.OrganisationDashboardPaletteId = p.OrganisationDashboardPaletteId
          AND x.SortOrder                      = c.SortOrder
          AND x.IsDeleted                      = 0
    );

COMMIT TRANSACTION;

-- ============================================================================
-- Verification — expect, per org, "Growyze" with 4 colours and
-- "Growyze Extended" with 9. Any count other than 1 row per (org, name) pair
-- means a duplicate palette exists; investigate before re-running anything.
-- ============================================================================
SELECT
      p.OrganisationId
    , p.Name                AS PaletteName
    , p.SortOrder           AS PaletteSort
    , COUNT(c.OrganisationDashboardPaletteColourId) AS LiveColours
    , STRING_AGG(c.Colour, ' ') WITHIN GROUP (ORDER BY c.SortOrder) AS Colours
FROM dbo.OrganisationDashboardPalette AS p
LEFT JOIN dbo.OrganisationDashboardPaletteColour AS c
       ON c.OrganisationDashboardPaletteId = p.OrganisationDashboardPaletteId
      AND c.IsDeleted = 0
WHERE p.IsDeleted = 0
  AND p.Name IN (N'Growyze', N'Growyze Extended')
GROUP BY p.OrganisationId, p.Name, p.SortOrder
ORDER BY p.OrganisationId, p.SortOrder;
