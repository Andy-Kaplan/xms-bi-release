-- =============================================================================
-- Punch Pubs - Red Lion Trial: Add "Demo Dashboard 3" (blank)
-- Target: UAT report database (xms-mssql-ne-uat)
-- =============================================================================

-- 1. Create the dashboard grid (capture auto-generated PK)
DECLARE @GridId TABLE (DashboardGridId UNIQUEIDENTIFIER);

INSERT INTO dbo.DashboardGrid (Container, Spacing, [Columns], IsDeleted)
OUTPUT inserted.DashboardGridId INTO @GridId
VALUES (1, 2, 12, 0);

-- 2. Link to Punch Pubs organisation
INSERT INTO dbo.OrganisationDashboardConfig
    (DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted)
SELECT
    DashboardGridId,
    '8381A215-4601-F111-8D4C-000D3AB579E6',
    N'Demo Dashboard 3',
    N'',
    1,
    0
FROM @GridId;

DECLARE @NewGridId NVARCHAR(36);
SELECT @NewGridId = CAST(DashboardGridId AS NVARCHAR(36)) FROM @GridId;
PRINT 'Created Demo Dashboard 3 for Punch Pubs - Red Lion Trial (GridId: ' + @NewGridId + ')';
