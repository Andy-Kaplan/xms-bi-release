-- ============================================================================
-- Growyze Organisation Palette for Padel Social + Dirty Sixth
-- Target: microservice report database (UAT: xms-mssql-ne-uat, DEV: xms-mssql-ne-dev)
-- ============================================================================
-- Palette: "Growyze"
-- Colours: Deep Blue #000055, Turquoise #34DBD1, Pink #FC3762, Soft Light #F3F3FF
-- Orgs:    Padel Social  (94A4B719-EB0F-421F-AD03-ABECDD888B14)
--          Dirty Sixth   (7B50D717-124C-4902-ADD2-439A9310326A)
-- ============================================================================

-- ---- Padel Social ----

INSERT INTO dbo.OrganisationDashboardPalette
    (OrganisationId, Name, IsDeleted, SortOrder)
VALUES
    (N'94A4B719-EB0F-421F-AD03-ABECDD888B14', N'Growyze', 0, 0);

DECLARE @PadelPaletteId uniqueidentifier;
SELECT @PadelPaletteId = OrganisationDashboardPaletteId
FROM dbo.OrganisationDashboardPalette
WHERE OrganisationId = N'94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND Name = N'Growyze'
  AND IsDeleted = 0;

INSERT INTO dbo.OrganisationDashboardPaletteColour
    (OrganisationDashboardPaletteId, Colour, IsDeleted, SortOrder)
VALUES
    (@PadelPaletteId, N'#000055', 0, 0),   -- Deep Blue
    (@PadelPaletteId, N'#34DBD1', 0, 10),  -- Turquoise
    (@PadelPaletteId, N'#FC3762', 0, 20),  -- Pink
    (@PadelPaletteId, N'#F3F3FF', 0, 30);  -- Soft Light

-- ---- Dirty Sixth ----

INSERT INTO dbo.OrganisationDashboardPalette
    (OrganisationId, Name, IsDeleted, SortOrder)
VALUES
    (N'7B50D717-124C-4902-ADD2-439A9310326A', N'Growyze', 0, 0);

DECLARE @DirtySixthPaletteId uniqueidentifier;
SELECT @DirtySixthPaletteId = OrganisationDashboardPaletteId
FROM dbo.OrganisationDashboardPalette
WHERE OrganisationId = N'7B50D717-124C-4902-ADD2-439A9310326A'
  AND Name = N'Growyze'
  AND IsDeleted = 0;

INSERT INTO dbo.OrganisationDashboardPaletteColour
    (OrganisationDashboardPaletteId, Colour, IsDeleted, SortOrder)
VALUES
    (@DirtySixthPaletteId, N'#000055', 0, 0),   -- Deep Blue
    (@DirtySixthPaletteId, N'#34DBD1', 0, 10),  -- Turquoise
    (@DirtySixthPaletteId, N'#FC3762', 0, 20),  -- Pink
    (@DirtySixthPaletteId, N'#F3F3FF', 0, 30);  -- Soft Light
