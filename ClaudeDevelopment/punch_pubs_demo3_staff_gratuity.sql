-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: three new gratuity-by-staff cards
-- =============================================================================
-- 1. RedLionStaffTotalTipRate            BarChartCard  Sort 5
-- 2. RedLionStaffAvgTipRateOnTippedOrders BarChartCard Sort 6
-- 3. RedLionStaffTipIncidence            BarChartCard  Sort 7
--
-- Source:  [stage].[RedLion_Transactions]  (Voided='FALSE')
-- Order:   ORDER_ID
-- Staff:   per-line User_Name (matches existing RedLionStaffATV)
-- Cutoff:  staff with < 20 distinct ORDER_IDs suppressed
--
-- Run order:
--   PART 1 -> UAT MI core DB  (xms-bi-uat, database = core)
--   PART 2 -> UAT report DB   (xms-mssql-ne-uat, database = report)
-- =============================================================================


-- =============================================================================
-- PART 1: MI core DB (database = core)
-- =============================================================================

DECLARE @ParamMap NVARCHAR(MAX) =
    N'{"LocationList": "[Location_Name]", "StartDate": "[Trading_Date]", "EndDate": "[Trading_Date]"}';
DECLARE @FilterDef NVARCHAR(MAX) =
    N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "EQUALS", "dataType": "VARCHAR"}, "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionDayOfWeek": {"column": "[Day_Of_Week]", "type": "IN", "dataType": "VARCHAR"}, "RedLionLocations": {"column": "[Location_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionPayments": {"column": "[Payment_Type]", "type": "IN", "dataType": "VARCHAR"}, "RedLionProducts": {"column": "[Item_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionRevC": {"column": "[Revenue_Center]", "type": "IN", "dataType": "VARCHAR"}, "RedLionStaff": {"column": "[User_Name]", "type": "IN", "dataType": "VARCHAR"}, "RedLionXProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RedLionYProd": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}';
DECLARE @OutDef NVARCHAR(MAX) = N'{"column_mappings": {}, "additional_datasets": []}';


-- -----------------------------------------------------------------------------
-- 1. RedLionStaffTotalTipRate (BarChartCard)
--    Pooled SUM(gratuity) / SUM(net revenue) per staff, expressed as %.
-- -----------------------------------------------------------------------------
DECLARE @QTotal NVARCHAR(MAX) = N'WITH base AS (
    SELECT [User_Name], [ORDER_ID], [Item_Name], [Item_ID], [Item_Value]
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
),
staff_agg AS (
    SELECT [User_Name],
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Gratuity,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS NetRevenue,
           COUNT(DISTINCT [ORDER_ID]) AS Orders
    FROM base
    GROUP BY [User_Name]
),
staff_rate AS (
    SELECT [User_Name],
           CAST(100.0 * Gratuity / NULLIF(NetRevenue, 0) AS DECIMAL(6,2)) AS TipRatePct
    FROM staff_agg
    WHERE Orders >= 20 AND NetRevenue > 0
)
SELECT
    [User_Name] AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY TipRatePct DESC) AS BarLabelSort,
    TipRatePct AS BarValue,
    ROW_NUMBER() OVER(ORDER BY TipRatePct) AS BarValueSort
FROM staff_rate

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Total Tip Rate by Staff'' AS Title,
    ''Total gratuity divided by total non-gratuity revenue, per staff. Min 20 orders.'' AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionStaffTotalTipRate', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'BarChartCard',
    [QueryTemplate] = @QTotal,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Pooled tip rate (gratuity / net revenue) per staff member. Min 20 orders.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionStaffTotalTipRate', N'BarChartCard', 1, N'LIVE', @QTotal,
        @ParamMap, @FilterDef,
        N'Pooled tip rate (gratuity / net revenue) per staff member. Min 20 orders.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '1. RedLionStaffTotalTipRate - upserted (BarChartCard)';


-- -----------------------------------------------------------------------------
-- 2. RedLionStaffAvgTipRateOnTippedOrders (BarChartCard)
--    Per (ORDER_ID, User_Name) sub-order: tip/bill ratio.
--    Average those ratios across sub-orders that received a tip, per staff.
--    Min-20 cutoff is on the staff's TOTAL distinct sub-orders (not just tipped).
-- -----------------------------------------------------------------------------
DECLARE @QAvg NVARCHAR(MAX) = N'WITH suborders AS (
    SELECT [User_Name], [ORDER_ID],
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
    GROUP BY [User_Name], [ORDER_ID]
),
staff_total AS (
    SELECT [User_Name], COUNT(*) AS Orders
    FROM suborders
    GROUP BY [User_Name]
),
staff_avg AS (
    SELECT [User_Name],
           AVG(CAST(100.0 * Tip / NULLIF(Bill, 0) AS DECIMAL(10,4))) AS AvgTipPct
    FROM suborders
    WHERE Tip > 0 AND Bill > 0
    GROUP BY [User_Name]
),
joined AS (
    SELECT a.[User_Name],
           CAST(a.AvgTipPct AS DECIMAL(6,2)) AS AvgTipPct
    FROM staff_avg a
    JOIN staff_total t ON t.[User_Name] = a.[User_Name]
    WHERE t.Orders >= 20
)
SELECT
    [User_Name] AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY AvgTipPct DESC) AS BarLabelSort,
    AvgTipPct AS BarValue,
    ROW_NUMBER() OVER(ORDER BY AvgTipPct) AS BarValueSort
FROM joined

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Avg Tip Rate (%)'' AS YAxisLabel,
    ''Avg Tip Rate per Tipped Order, by Staff'' AS Title,
    ''Per-order tip rate averaged over orders that received a tip, by staff. Min 20 total orders.'' AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionStaffAvgTipRateOnTippedOrders', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'BarChartCard',
    [QueryTemplate] = @QAvg,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Average per-order tip rate across tipped orders, per staff. Min 20 total orders.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionStaffAvgTipRateOnTippedOrders', N'BarChartCard', 1, N'LIVE', @QAvg,
        @ParamMap, @FilterDef,
        N'Average per-order tip rate across tipped orders, per staff. Min 20 total orders.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '2. RedLionStaffAvgTipRateOnTippedOrders - upserted (BarChartCard)';


-- -----------------------------------------------------------------------------
-- 3. RedLionStaffTipIncidence (BarChartCard)
--    % of (ORDER_ID, User_Name) sub-orders that received a tip, per staff.
-- -----------------------------------------------------------------------------
DECLARE @QInc NVARCHAR(MAX) = N'WITH suborders AS (
    SELECT [User_Name], [ORDER_ID],
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE''
    @FilterClause
    GROUP BY [User_Name], [ORDER_ID]
),
staff_inc AS (
    SELECT [User_Name],
           COUNT(*) AS Orders,
           SUM(CASE WHEN Tip > 0 THEN 1 ELSE 0 END) AS Tipped
    FROM suborders
    GROUP BY [User_Name]
),
staff_pct AS (
    SELECT [User_Name],
           CAST(100.0 * Tipped / NULLIF(Orders, 0) AS DECIMAL(6,2)) AS IncidencePct
    FROM staff_inc
    WHERE Orders >= 20
)
SELECT
    [User_Name] AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY IncidencePct DESC) AS BarLabelSort,
    IncidencePct AS BarValue,
    ROW_NUMBER() OVER(ORDER BY IncidencePct) AS BarValueSort
FROM staff_pct

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Orders With Gratuity (%)'' AS YAxisLabel,
    ''% of Orders With Gratuity, by Staff'' AS Title,
    ''Share of orders that received a gratuity, per staff. Min 20 orders.'' AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'RedLionStaffTipIncidence', N'LIVE', 1)) AS src (DataSetName, Status, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.Status = src.Status AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    [VisualizationType] = N'BarChartCard',
    [QueryTemplate] = @QInc,
    [ParameterMappings] = @ParamMap,
    [FilterDefinitions] = @FilterDef,
    [Description] = N'Share of orders that received a gratuity, per staff. Min 20 orders.',
    [OutputDefinitions] = @OutDef,
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN
INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate,
        ParameterMappings, FilterDefinitions, Description, CreatedDate,
        ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
VALUES (N'RedLionStaffTipIncidence', N'BarChartCard', 1, N'LIVE', @QInc,
        @ParamMap, @FilterDef,
        N'Share of orders that received a gratuity, per staff. Min 20 orders.',
        GETDATE(), GETDATE(), SUSER_SNAME(), SUSER_SNAME(), @OutDef, NULL);

PRINT '3. RedLionStaffTipIncidence - upserted (BarChartCard)';


-- =============================================================================
-- PART 2: Report DB (database = report on xms-mssql-ne-uat)
-- =============================================================================
--   Org:               Punch Pubs - Trial = 8381A215-4601-F111-8D4C-000D3AB579E6
--   Demo Dashboard 3:  CA832FD3-DA27-F111-9A49-000D3AB27214
--   BarChartCard cfg:  358201FC-DD27-F111-9A49-000D3AB27214 (existing for org)
-- =============================================================================

DECLARE @BarCfgId UNIQUEIDENTIFIER = '358201FC-DD27-F111-9A49-000D3AB27214';
DECLARE @GridId   UNIQUEIDENTIFIER = 'CA832FD3-DA27-F111-9A49-000D3AB27214';


-- 2a. RedLionStaffTotalTipRate -> sort 5
IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @BarCfgId
                 AND DataSet = N'RedLionStaffTotalTipRate' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@BarCfgId, N'RedLionStaffTotalTipRate', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId
                 AND DataSet = N'RedLionStaffTotalTipRate' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 12, 12, 12, 1, N'RedLionStaffTotalTipRate', 5, 0);

PRINT '2a. RedLionStaffTotalTipRate wired (full width, sort 5)';


-- 2b. RedLionStaffAvgTipRateOnTippedOrders -> sort 6
IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @BarCfgId
                 AND DataSet = N'RedLionStaffAvgTipRateOnTippedOrders' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@BarCfgId, N'RedLionStaffAvgTipRateOnTippedOrders', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId
                 AND DataSet = N'RedLionStaffAvgTipRateOnTippedOrders' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 12, 12, 12, 1, N'RedLionStaffAvgTipRateOnTippedOrders', 6, 0);

PRINT '2b. RedLionStaffAvgTipRateOnTippedOrders wired (full width, sort 6)';


-- 2c. RedLionStaffTipIncidence -> sort 7
IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
               WHERE VisualisationConfigId = @BarCfgId
                 AND DataSet = N'RedLionStaffTipIncidence' AND IsDeleted = 0)
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES (@BarCfgId, N'RedLionStaffTipIncidence', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem
               WHERE DashboardGridId = @GridId
                 AND DataSet = N'RedLionStaffTipIncidence' AND IsDeleted = 0)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES (@GridId, 12, 12, 12, 12, 12, 1, N'RedLionStaffTipIncidence', 7, 0);

PRINT '2c. RedLionStaffTipIncidence wired (full width, sort 7)';
