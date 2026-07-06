-- =============================================================================
-- TEST: Wire test visualisation cards onto Kitchen Sink dashboard (XMSE-1030, XMSE-1014, XMSE-948)
-- Target server:    xms-mssql-ne-test (microservice TEST)
-- Target database:  report
-- Target dashboard: Kitchen Sink (DashboardGridId 87D8B576-BE97-F011-B3CD-000D3AD9E35E)
--                   Organisation: Three Rocks Cafe (C14CF568-588D-F011-B3CD-000D3AD9E9D4)
-- Idempotent:       Yes
--
-- Adds six dataset mappings + six DashboardGridItem rows. VisualisationConfig
-- rows for Three Rocks Cafe already exist for VisualisationId 8, 11, 16, 17;
-- this script only patches the dataset mappings + grid items.
--
-- Layout (sort orders 100-105):
--   100  StackedBarChartCard   HorizontalStackedBarTest    half-width  (XMSE-1030)
--   101  MultiLineChartCard    MultiLineNullValueTest      half-width  (XMSE-1014)
--   102  MarkdownCard          MarkdownTestEmpty           half-width  (XMSE-948 hidden)
--   103  MarkdownCard          MarkdownTestVisible         half-width  (XMSE-948 visible)
--   104  StaticBoxCard         StaticBoxTestEmpty          half-width  (XMSE-948 hidden)
--   105  StaticBoxCard         StaticBoxTestVisible        half-width  (XMSE-948 visible)
-- =============================================================================

USE [report];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Live TEST values:
--   OrganisationId  = Three Rocks Cafe
--   DashboardGridId = Kitchen Sink dashboard
DECLARE @OrgId           UNIQUEIDENTIFIER = 'C14CF568-588D-F011-B3CD-000D3AD9E9D4';
DECLARE @DashboardGridId UNIQUEIDENTIFIER = '87D8B576-BE97-F011-B3CD-000D3AD9E35E';

-- ---------------------------------------------------------------------------
-- 1. Ensure VisualisationConfig rows exist for Three Rocks Cafe.
--    (These already exist on TEST; the MERGE is here for re-runnability on
--     fresh environments and for documentation.)
-- ---------------------------------------------------------------------------
;WITH src AS (
    SELECT VisId FROM (VALUES (8), (11), (16), (17)) v(VisId)
)
MERGE INTO dbo.VisualisationConfig AS tgt
USING src
   ON tgt.OrganisationId   = @OrgId
  AND tgt.VisualisationId  = src.VisId
  AND tgt.IsDeleted        = 0
WHEN MATCHED THEN UPDATE SET
     ActiveFrom  = COALESCE(tgt.ActiveFrom, GETUTCDATE())
    ,ActiveUntil = NULL
    ,DateUpdated = SYSUTCDATETIME()
WHEN NOT MATCHED THEN INSERT
    (OrganisationId, VisualisationId, ActiveFrom, ActiveUntil, IsDeleted)
VALUES
    (@OrgId, src.VisId, GETUTCDATE(), NULL, 0);
GO

-- ---------------------------------------------------------------------------
-- 2. Ensure VisualisationDataSetMap rows exist for each new dataset.
--    Natural key: (VisualisationConfigId, DataSet).
-- ---------------------------------------------------------------------------
DECLARE @OrgId UNIQUEIDENTIFIER = 'C14CF568-588D-F011-B3CD-000D3AD9E9D4';

;WITH cfg AS (
    SELECT VisualisationId, VisualisationConfigId
    FROM dbo.VisualisationConfig
    WHERE OrganisationId = @OrgId AND IsDeleted = 0
), src AS (
    SELECT cfg.VisualisationConfigId, x.DataSet
    FROM (VALUES
        (11, N'HorizontalStackedBarTest'),
        ( 8, N'MultiLineNullValueTest'),
        (17, N'MarkdownTestEmpty'),
        (17, N'MarkdownTestVisible'),
        (16, N'StaticBoxTestEmpty'),
        (16, N'StaticBoxTestVisible')
    ) x(VisId, DataSet)
    JOIN cfg ON cfg.VisualisationId = x.VisId
)
MERGE INTO dbo.VisualisationDataSetMap AS tgt
USING src
   ON tgt.VisualisationConfigId = src.VisualisationConfigId
  AND tgt.DataSet               = src.DataSet
  AND tgt.IsDeleted             = 0
WHEN NOT MATCHED THEN INSERT
    (VisualisationConfigId, DataSet, IsDeleted)
VALUES
    (src.VisualisationConfigId, src.DataSet, 0);
GO

-- ---------------------------------------------------------------------------
-- 3. Place six DashboardGridItem rows on the Kitchen Sink dashboard.
--    Natural key: (DashboardGridId, VisualisationId, DataSet, IsDeleted=0).
-- ---------------------------------------------------------------------------
DECLARE @DashboardGridId UNIQUEIDENTIFIER = '87D8B576-BE97-F011-B3CD-000D3AD9E35E';

;WITH src AS (
    SELECT *
    FROM (VALUES
        -- VisId, DataSet,                       SortOrder, XS, S,  M, L, XL
        (11, N'HorizontalStackedBarTest',         100,      12, 12, 6, 6, 6),
        ( 8, N'MultiLineNullValueTest',           101,      12, 12, 6, 6, 6),
        (17, N'MarkdownTestEmpty',                102,      12, 12, 6, 6, 6),
        (17, N'MarkdownTestVisible',              103,      12, 12, 6, 6, 6),
        (16, N'StaticBoxTestEmpty',               104,      12, 12, 6, 6, 6),
        (16, N'StaticBoxTestVisible',             105,      12, 12, 6, 6, 6)
    ) v(VisId, DataSet, SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge)
)
MERGE INTO dbo.DashboardGridItem AS tgt
USING src
   ON tgt.DashboardGridId  = @DashboardGridId
  AND tgt.VisualisationId  = src.VisId
  AND tgt.DataSet          = src.DataSet
  AND tgt.IsDeleted        = 0
WHEN MATCHED THEN UPDATE SET
     ExtraSmall  = src.ExtraSmall
    ,Small       = src.Small
    ,Medium      = src.Medium
    ,Large       = src.Large
    ,ExtraLarge  = src.ExtraLarge
    ,SortOrder   = src.SortOrder
    ,DateUpdated = SYSUTCDATETIME()
WHEN NOT MATCHED THEN INSERT
    (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
     VisualisationId, DataSet, IsDeleted, SortOrder)
VALUES
    (@DashboardGridId, src.ExtraSmall, src.Small, src.Medium, src.Large, src.ExtraLarge,
     src.VisId, src.DataSet, 0, src.SortOrder);
GO

-- ---------------------------------------------------------------------------
-- Verification
-- ---------------------------------------------------------------------------
DECLARE @OrgId UNIQUEIDENTIFIER = 'C14CF568-588D-F011-B3CD-000D3AD9E9D4';
DECLARE @DashboardGridId UNIQUEIDENTIFIER = '87D8B576-BE97-F011-B3CD-000D3AD9E35E';

SELECT 'VisualisationConfig' AS Section, vp.ProcedureName, vc.VisualisationConfigId, vc.VisualisationId
FROM dbo.VisualisationConfig vc
JOIN dbo.VisualisationProcedure vp ON vp.VisualisationId = vc.VisualisationId AND vp.IsDeleted = 0
WHERE vc.OrganisationId = @OrgId AND vc.VisualisationId IN (8,11,16,17) AND vc.IsDeleted = 0
ORDER BY vc.VisualisationId;

SELECT 'VisualisationDataSetMap' AS Section, vp.ProcedureName, dsm.DataSet
FROM dbo.VisualisationDataSetMap dsm
JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = dsm.VisualisationConfigId AND vc.IsDeleted = 0
JOIN dbo.VisualisationProcedure vp ON vp.VisualisationId = vc.VisualisationId AND vp.IsDeleted = 0
WHERE vc.OrganisationId = @OrgId AND dsm.IsDeleted = 0
  AND dsm.DataSet IN (
        N'HorizontalStackedBarTest', N'MultiLineNullValueTest',
        N'MarkdownTestEmpty', N'MarkdownTestVisible',
        N'StaticBoxTestEmpty', N'StaticBoxTestVisible')
ORDER BY vp.ProcedureName, dsm.DataSet;

SELECT 'DashboardGridItem' AS Section, gi.SortOrder, vp.ProcedureName, gi.DataSet,
       gi.ExtraSmall, gi.Small, gi.Medium, gi.Large, gi.ExtraLarge
FROM dbo.DashboardGridItem gi
JOIN dbo.VisualisationProcedure vp ON vp.VisualisationId = gi.VisualisationId AND vp.IsDeleted = 0
WHERE gi.DashboardGridId = @DashboardGridId AND gi.IsDeleted = 0
  AND gi.DataSet IN (
        N'HorizontalStackedBarTest', N'MultiLineNullValueTest',
        N'MarkdownTestEmpty', N'MarkdownTestVisible',
        N'StaticBoxTestEmpty', N'StaticBoxTestVisible')
ORDER BY gi.SortOrder;
GO
