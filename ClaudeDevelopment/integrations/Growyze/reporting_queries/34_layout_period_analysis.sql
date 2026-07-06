/*
    34_layout_period_analysis.sql
    =============================
    Expand WoW/MoM/YoY revenue comparison cards on the Period
    Analysis dashboard — they are currently 4-col (third-width)
    and look squashed.

    Feedback: O15 ("3 revenue graphs are great, but poor layout —
    should give more importance — makes it look squashed")

    Change:
      - WoW: 4 → 6 (half-width, 2 per row with MoM)
      - MoM: 4 → 6 (half-width)
      - YoY: 4 → 12 (full-width, standalone row)

    WARNING: Both Padel Social and Dirty Sixth share this grid.
    This change affects both orgs.

    TARGET: report database on microservice server (xms-mssql-ne-uat)
    GRID:   Period Analysis (D07AC385-36C4-424B-922B-406D6A00B4B3)
*/

-- WoW → half-width
UPDATE dbo.DashboardGridItem
SET Medium = 6, Large = 6, ExtraLarge = 6, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
  AND DataSet = N'InvPeriodCompWoW'
  AND IsDeleted = 0;

-- MoM → half-width
UPDATE dbo.DashboardGridItem
SET Medium = 6, Large = 6, ExtraLarge = 6, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
  AND DataSet = N'InvPeriodCompMoM'
  AND IsDeleted = 0;

-- YoY → full-width
UPDATE dbo.DashboardGridItem
SET Medium = 12, Large = 12, ExtraLarge = 12, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
  AND DataSet = N'InvPeriodCompYoY'
  AND IsDeleted = 0;

-- Verify
SELECT DataSet, SortOrder, Medium, Large, ExtraLarge
FROM dbo.DashboardGridItem
WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
  AND IsDeleted = 0
ORDER BY SortOrder;
