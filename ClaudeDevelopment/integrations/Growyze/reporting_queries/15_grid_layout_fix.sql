/*
    15_grid_layout_fix.sql
    =======================
    Widens the InvConsumption CustomDataGrid card to full 12-column width
    on the Padel Social "Stock Activity" dashboard.

    Grid visualisations don't render well at half-width (6 columns) —
    columns get truncated and a horizontal scrollbar appears.

    Run against: report database (microservice UAT)
    Idempotent: Yes — sets to 12 regardless of current value
*/

UPDATE dbo.DashboardGridItem
SET Medium     = 12,
    Large      = 12,
    ExtraLarge = 12,
    DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridItemId = 'CCF367B8-5E1D-F111-832F-000D3AB27D87'
  AND IsDeleted = 0;
