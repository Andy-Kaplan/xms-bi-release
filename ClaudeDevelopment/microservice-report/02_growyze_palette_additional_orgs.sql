-- ============================================================================
-- 02 — Growyze organisation palette for additional UAT orgs
-- Target: microservice report database  (UAT: xms-mssql-ne-uat, database `report`)
-- ============================================================================
-- Adds the "Growyze" organisation palette to three further Growyze-fed orgs,
-- matching the palette already live for Padel Social and Dirty Sixth.
--
-- Palette: "Growyze"
-- Colours: Deep Blue #000055, Turquoise #34DBD1, Pink #FC3762, Soft Light #F3F3FF
--
-- Orgs:
--   The Oak & Vine        7ED2E768-0D22-F111-832F-000D3AB27D87   (OrgID 16, 11 dashboards)
--   Ibis Gloucester Road  67CA4E6F-9A7E-F111-B337-002248A1EC3D   (OrgID 21,  1 dashboard)
--   Ibis Heathrow         7CE02464-9A7E-F111-B337-002248A1EC3D   (OrgID 20)
--
-- NOTE ON IBIS HEATHROW: as at 2026-07-30 this org has NO BiConfig row in the
-- report DB, i.e. it is not yet onboarded to the microservice. The palette row
-- is harmless and will simply be unused until Heathrow is wired up. It is
-- included deliberately so the branding is already in place at that point.
--
-- ---------------------------------------------------------------------------
-- IDEMPOTENT. Safe to re-run.
--   The predecessor script (integrations/Growyze/growyze_org_palette.sql) was
--   NOT — it did a bare INSERT then looked the parent up by name. Because there
--   is no unique constraint on (OrganisationId, Name), re-running it silently
--   creates a SECOND identical palette and BOTH appear in the picker. This
--   script guards every insert with NOT EXISTS instead.
--
-- HOUSE RULES OBSERVED:
--   - never specify the PK ({Table}Id) — DEFAULT NEWSEQUENTIALID()
--   - never specify TransactionId — IDENTITY
--   - always set IsDeleted = 0 explicitly (no default on these two tables)
--
-- ⚠️ CACHE: the application caches report-DB configuration and a direct SQL
--   write does NOT invalidate it. After running this, the new palettes will not
--   appear in the UI until the cache is cleared (adding data via the admin
--   tools does this automatically; a SQL script does not). This is what hid the
--   Padel Social / Dirty Sixth palettes for three months. Ask the FE team to
--   clear the cache, then confirm in the picker under the "Organisation" group.
--
-- ⚠️ SCOPE: defining an organisation palette makes it SELECTABLE, not applied.
--   There is no organisation-level default — see ledger O26 / XMSE-1756. Users
--   must pick "Growyze" from the palette picker themselves until that ships.
-- ============================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Targets TABLE
(
    OrganisationId uniqueidentifier PRIMARY KEY,
    OrgName        nvarchar(100)
);

INSERT INTO @Targets (OrganisationId, OrgName) VALUES
    (N'7ED2E768-0D22-F111-832F-000D3AB27D87', N'The Oak & Vine'),
    (N'67CA4E6F-9A7E-F111-B337-002248A1EC3D', N'Ibis Gloucester Road'),
    (N'7CE02464-9A7E-F111-B337-002248A1EC3D', N'Ibis Heathrow');

DECLARE @Colours TABLE
(
    Colour    nvarchar(7),
    SortOrder int PRIMARY KEY
);

INSERT INTO @Colours (Colour, SortOrder) VALUES
    (N'#000055',  0),   -- Deep Blue
    (N'#34DBD1', 10),   -- Turquoise
    (N'#FC3762', 20),   -- Pink
    (N'#F3F3FF', 30);   -- Soft Light

BEGIN TRANSACTION;

    -- 1. Parent palette row, one per target org, only where absent.
    INSERT INTO dbo.OrganisationDashboardPalette
        (OrganisationId, Name, IsDeleted, SortOrder)
    SELECT t.OrganisationId, N'Growyze', 0, 0
    FROM @Targets AS t
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.OrganisationDashboardPalette AS p
        WHERE p.OrganisationId = t.OrganisationId
          AND p.Name           = N'Growyze'
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
    WHERE p.Name      = N'Growyze'
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
-- Verification — expect one 'Growyze' palette with exactly 4 colours per org,
-- for all five Growyze orgs (the two originals plus the three added here).
-- Any org showing palettes > 1 means a duplicate exists; investigate before
-- re-running anything.
-- ============================================================================
SELECT
      p.OrganisationId
    , p.Name                AS PaletteName
    , COUNT(c.OrganisationDashboardPaletteColourId) AS LiveColours
    , STRING_AGG(c.Colour, ' ') WITHIN GROUP (ORDER BY c.SortOrder) AS Colours
FROM dbo.OrganisationDashboardPalette AS p
LEFT JOIN dbo.OrganisationDashboardPaletteColour AS c
       ON c.OrganisationDashboardPaletteId = p.OrganisationDashboardPaletteId
      AND c.IsDeleted = 0
WHERE p.IsDeleted = 0
  AND p.Name      = N'Growyze'
GROUP BY p.OrganisationId, p.Name
ORDER BY p.OrganisationId;
