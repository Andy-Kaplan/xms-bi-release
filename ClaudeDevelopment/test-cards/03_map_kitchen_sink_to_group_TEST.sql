-- =============================================================================
-- TEST: Map Kitchen Sink dashboard to "Test Group" so it appears in the nav
-- Target server:   xms-mssql-ne-test (microservice TEST)
-- Target database: report
-- Idempotent:      Yes
--
-- Context: After running 02_wire_kitchen_sink_TEST.sql, the dashboard config
-- exists and is bound to Three Rocks Cafe — but the front end navigation only
-- shows dashboards that are mapped to a DashboardGroup via
-- OrganisationDashboardGroupMapping. The Kitchen Sink config has never been
-- group-mapped, so it's hidden. This script adds the missing mapping row.
-- =============================================================================

USE [report];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @KitchenSinkConfigId UNIQUEIDENTIFIER = '3DCF84E9-C805-F111-832E-00224899CB2B';  -- OrganisationDashboardConfigId for Kitchen Sink (Three Rocks Cafe)
DECLARE @TestGroupId         UNIQUEIDENTIFIER = '423A8DD6-1C08-F111-832E-00224899CB2B';  -- DashboardGroupId for "Test Group" (Three Rocks Cafe)

MERGE INTO dbo.OrganisationDashboardGroupMapping AS tgt
USING (VALUES (@TestGroupId, @KitchenSinkConfigId)) AS src (DashboardGroupId, OrganisationDashboardConfigId)
   ON tgt.DashboardGroupId               = src.DashboardGroupId
  AND tgt.OrganisationDashboardConfigId  = src.OrganisationDashboardConfigId
WHEN MATCHED AND tgt.IsDeleted = 1 THEN UPDATE SET
     IsDeleted   = 0
    ,DateUpdated = SYSUTCDATETIME()
WHEN NOT MATCHED THEN INSERT
    (DashboardGroupId, OrganisationDashboardConfigId, IsDeleted)
VALUES
    (src.DashboardGroupId, src.OrganisationDashboardConfigId, 0);
GO

-- Verification
SELECT g.Name AS GroupName,
       odc.Name AS DashboardName,
       m.IsDeleted,
       m.DateCreated,
       m.DateUpdated
FROM dbo.OrganisationDashboardGroupMapping m
JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId
JOIN dbo.OrganisationDashboardConfig odc ON odc.OrganisationDashboardConfigId = m.OrganisationDashboardConfigId
WHERE odc.OrganisationId = 'C14CF568-588D-F011-B3CD-000D3AD9E9D4'
ORDER BY g.SortOrder, odc.SortOrder, odc.Name;
GO
