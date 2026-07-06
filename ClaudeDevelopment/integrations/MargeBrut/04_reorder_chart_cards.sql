/* =============================================================================
   04_reorder_chart_cards.sql
   -----------------------------------------------------------------------------
   Target server  : xms-mssql-ne-uat   (Azure SQL)
   Target database: report
   Purpose        : Reorder the Marge Brut supporting cards so row 2 = the two
                    bar charts and row 3 = the two pie charts.

   The DashboardGridItem rows already exist (created by 03), and 03's insert is
   NOT-EXISTS-guarded, so it won't change SortOrder on a re-run. This UPDATE sets
   the new order directly. Idempotent. (03's @Items has been updated to match for
   any future clean deploy.)

   New order on the grid:
     1-4  KPI strip   |  5  Marge Brut grid
     6    Cost % by Group (Bar)        7  Purchases by Supplier (Bar)   <- row 2
     8    Consumption Mix (Pie)        9  Comps & Staff Meals (Pie)     <- row 3

   DashboardGridItem's audit trigger is not affected by the *DashboardConfig
   audit-trigger regression, so this UPDATE is safe.

   Run directly against the report DB.
   ============================================================================= */

SET NOCOUNT ON;

DECLARE @OrgId  UNIQUEIDENTIFIER = '7ED2E768-0D22-F111-832F-000D3AB27D87';  -- The Oak & Vine
DECLARE @GridId UNIQUEIDENTIFIER;

SELECT @GridId = DashboardGridId
FROM dbo.OrganisationDashboardConfig
WHERE OrganisationId = @OrgId AND Name = N'Marge Brut' AND IsDeleted = 0;

IF @GridId IS NULL
BEGIN
    RAISERROR(N'Marge Brut dashboard not found for The Oak & Vine.', 16, 1);
    RETURN;
END

UPDATE dgi
SET dgi.SortOrder = v.NewSort
FROM dbo.DashboardGridItem dgi
INNER JOIN (VALUES
    (N'MargeBrutCostRatioByGroup',    6),
    (N'MargeBrutPurchasesBySupplier', 7),
    (N'MargeBrutConsumptionMix',      8),
    (N'MargeBrutCompsSplit',          9)
) AS v (DataSet, NewSort) ON v.DataSet = dgi.DataSet
WHERE dgi.DashboardGridId = @GridId
  AND dgi.IsDeleted = 0
  AND dgi.SortOrder <> v.NewSort;

PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' chart card(s) reordered (bars row 2, pies row 3).';

/* Verify the new order: */
SELECT dgi.SortOrder, dgi.VisualisationId, dgi.DataSet
FROM dbo.DashboardGridItem dgi
WHERE dgi.DashboardGridId = @GridId AND dgi.IsDeleted = 0
ORDER BY dgi.SortOrder;
