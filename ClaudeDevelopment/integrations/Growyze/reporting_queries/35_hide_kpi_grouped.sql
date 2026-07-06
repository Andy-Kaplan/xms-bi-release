/*
    35_hide_kpi_grouped.sql
    ========================
    Soft-delete InvKPIGrouped card from the Cost & Margins
    dashboard.

    Feedback: O4 ("Inventory KPIs is confusing and too much")

    Reversible: SET IsDeleted = 0 to restore.

    WARNING: Both Padel Social and Dirty Sixth share this grid.
    This change affects both orgs.

    TARGET: report database on microservice server (xms-mssql-ne-uat)
    GRID:   Cost & Margins (7C83F241-9CD7-4326-B659-109CF4408793)
*/

UPDATE dbo.DashboardGridItem
SET IsDeleted = 1, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = '7C83F241-9CD7-4326-B659-109CF4408793'
  AND DataSet = N'InvKPIGrouped'
  AND IsDeleted = 0;

-- Verify remaining cards on Cost & Margins
SELECT DataSet, VisualisationId, SortOrder, IsDeleted
FROM dbo.DashboardGridItem
WHERE DashboardGridId = '7C83F241-9CD7-4326-B659-109CF4408793'
ORDER BY SortOrder;
