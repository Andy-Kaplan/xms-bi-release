/*
    22_filter_wiring_fix.sql
    ========================
    Add Products filter to Padel Social's Cost & Margins and Period Analysis dashboards

    ISSUE:
        Cost & Margins and Period Analysis dashboards only have Locations
        + InvItems filters. 8 POS-margin queries on these dashboards
        (InvCOGSByCategory, InvMarginTrend, InvWeeklySummary, InvPeriodComp x3)
        already have Products.column wired in their FilterDefinitions, but
        no Products filter widget exists on the dashboards to trigger it.

        The InvItems filter cannot affect these queries because
        F_PRODUCT_MARGIN_DAY joins D_PRODUCT not D_INVITEM, and product
        names ("Mahou-Pint") are completely different entities from
        inventory item names ("100% Grated Mozzarella Cheese").

        The Products FilterList provides a hierarchical tree with
        expandable categories — no separate ProductCategories filter
        is needed.

    FIX:
        Add Products DashboardGridFilter (SortOrder 3) to both dashboards.
        All 8 POS queries will immediately react to the new filter.
        Inventory queries (InvMargeBrut, InvKPIGrouped, InvVarianceCategory)
        continue to react to InvItems as before.

    TARGET: report database on microservice server (xms-mssql-ne-uat)
    ORG:    Padel Social (94A4B719-EB0F-421F-AD03-ABECDD888B14)
*/

-- Cost & Margins (DashboardGridId: 7C83F241-9CD7-4326-B659-109CF4408793)
-- Existing: SortOrder 1 = Locations, SortOrder 2 = InvItems
IF NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter
    WHERE DashboardGridId = '7C83F241-9CD7-4326-B659-109CF4408793'
      AND DataSet = N'Products'
      AND IsDeleted = 0
)
INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, IsDeleted, SortOrder)
VALUES ('7C83F241-9CD7-4326-B659-109CF4408793', N'Products', 0, 3);

-- Period Analysis (DashboardGridId: D07AC385-36C4-424B-922B-406D6A00B4B3)
-- Existing: SortOrder 1 = Locations, SortOrder 2 = InvItems
IF NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter
    WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
      AND DataSet = N'Products'
      AND IsDeleted = 0
)
INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, IsDeleted, SortOrder)
VALUES ('D07AC385-36C4-424B-922B-406D6A00B4B3', N'Products', 0, 3);

-- Verify all filters for Padel Social dashboards
SELECT odc.Name AS DashboardName,
       dgf.DataSet AS FilterDataSet,
       dgf.SortOrder
FROM dbo.OrganisationDashboardConfig odc
INNER JOIN dbo.DashboardGridFilter dgf ON odc.DashboardGridId = dgf.DashboardGridId
WHERE odc.OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND odc.IsDeleted = 0
  AND dgf.IsDeleted = 0
ORDER BY odc.Name, dgf.SortOrder;
