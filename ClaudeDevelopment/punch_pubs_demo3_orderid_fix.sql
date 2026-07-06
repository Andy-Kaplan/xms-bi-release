-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: switch settlement key from Transaction_ID to ORDER_ID
-- Target: UAT MI core DB (xms-bi-uat, database = core)
-- =============================================================================
-- Background: Transaction_ID in stage.RedLion_Transactions is a category-level
-- batch, not a customer bill (only 236 distinct values across 122 days). The
-- correct unit for "one customer transaction" is ORDER_ID (8,301 distinct
-- values, ~68/day). Switching keys gives realistic per-order numbers:
--   * EftAtTable avg bill: GBP 1,153 -> GBP 116
--   * Top staff ATV (Charlotte): GBP 345 -> GBP 78
--
-- Affected queries:
--   1. RedLionStaffATV
--   2. RedLionATVByTender
--   3. RedLionTipRateByBillSize
--   4. RedLionTipIncidenceByTender
--   5. RedLionTipMatrix
--
-- All updates target QueryTemplate only - no report DB changes required.
-- =============================================================================


-- =============================================================================
-- 1. RedLionStaffATV - ORDER_ID-based ATV, min 20 orders threshold
-- =============================================================================
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH base_data AS (
    SELECT [User_Name], [ORDER_ID], [Item_Value]
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Item_ID] > 0
    @FilterClause
),
staff_atv AS (
    SELECT [User_Name],
           ROUND(SUM([Item_Value]) / NULLIF(COUNT(DISTINCT [ORDER_ID]), 0), 2) AS ATV,
           COUNT(DISTINCT [ORDER_ID]) AS Orders
    FROM base_data
    GROUP BY [User_Name]
)
SELECT
    [User_Name] AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY ATV DESC) AS BarLabelSort,
    ATV AS BarValue,
    ROW_NUMBER() OVER(ORDER BY ATV) AS BarValueSort
FROM staff_atv
WHERE Orders >= 20

SELECT
    ''Staff Member'' AS XAxisLabel,
    ''Avg Transaction Value'' AS YAxisLabel,
    ''Staff League Table - Average Transaction Value'' AS Title,
    ''Total revenue divided by distinct customer orders. Staff with fewer than 20 orders suppressed.'' AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
    [Description] = N'Staff league ranked by average transaction value (revenue / order count). ORDER_ID-based; min 20 orders.',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionStaffATV' AND [Status] = N'LIVE';

PRINT '1. RedLionStaffATV - switched to ORDER_ID, min 20 orders';


-- =============================================================================
-- 2. RedLionATVByTender - ORDER_ID-based, retain 3-sigma outlier filter
-- =============================================================================
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH sessions AS (
    SELECT [ORDER_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [ORDER_ID], [Payment_Type]
),
stats AS (
    SELECT Tender, AVG(Bill) AS Mu, STDEV(Bill) AS Sg
    FROM sessions WHERE Bill > 0
    GROUP BY Tender
),
filtered AS (
    SELECT s.Tender, s.Bill
    FROM sessions s
    JOIN stats st ON st.Tender = s.Tender
    WHERE s.Bill > 0
      AND (st.Sg IS NULL OR ABS(s.Bill - st.Mu) <= 3 * st.Sg)
)
SELECT
    Tender AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY AVG(Bill) DESC) AS BarLabelSort,
    CAST(AVG(Bill) AS DECIMAL(10,2)) AS BarValue,
    ROW_NUMBER() OVER(ORDER BY AVG(Bill)) AS BarValueSort
FROM filtered
GROUP BY Tender

SELECT
    ''Payment Type'' AS XAxisLabel,
    ''Avg Spend ('' + NCHAR(163) + '')'' AS YAxisLabel,
    ''Avg Spend per Order by Payment Type'' AS Title,
    ''Outliers > 3 standard deviations excluded per tender. ORDER_ID-based.'' AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
    [Description] = N'Average spend per (ORDER_ID, Payment_Type) settlement, with 3-sigma outlier exclusion per tender.',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionATVByTender' AND [Status] = N'LIVE';

PRINT '2. RedLionATVByTender - switched to ORDER_ID';


-- =============================================================================
-- 3. RedLionTipRateByBillSize - ORDER_ID-based, retain 3-sigma + N>=5
--    Keeps MultiLineChartCard schema (Curve=natural, Stack=Tender, ShowMark=false)
-- =============================================================================
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH sessions AS (
    SELECT [ORDER_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [ORDER_ID], [Payment_Type]
),
stats AS (
    SELECT Tender, AVG(Bill) AS Mu, STDEV(Bill) AS Sg
    FROM sessions WHERE Bill > 0
    GROUP BY Tender
),
filtered AS (
    SELECT s.Tender, s.Tip, s.Bill
    FROM sessions s
    JOIN stats st ON st.Tender = s.Tender
    WHERE s.Bill > 0
      AND (st.Sg IS NULL OR ABS(s.Bill - st.Mu) <= 3 * st.Sg)
),
bucketed AS (
    SELECT Tender, Tip, Bill,
           CASE WHEN Bill < 20  THEN 1
                WHEN Bill < 50  THEN 2
                WHEN Bill < 100 THEN 3
                WHEN Bill < 200 THEN 4
                ELSE 5 END AS BucketSort,
           CASE WHEN Bill < 20  THEN ''Under '' + NCHAR(163) + ''20''
                WHEN Bill < 50  THEN NCHAR(163) + ''20-50''
                WHEN Bill < 100 THEN NCHAR(163) + ''50-100''
                WHEN Bill < 200 THEN NCHAR(163) + ''100-200''
                ELSE NCHAR(163) + ''200+'' END AS Bucket
    FROM filtered
),
agg AS (
    SELECT Tender, Bucket, BucketSort,
           COUNT(*) AS N,
           CAST(100.0 * SUM(Tip) / NULLIF(SUM(Bill), 0) AS DECIMAL(6,2)) AS TipPct
    FROM bucketed
    GROUP BY Tender, Bucket, BucketSort
)
SELECT
    XAxisLabel,
    DENSE_RANK() OVER(ORDER BY BucketSort, VisId) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    ''natural'' AS Curve,
    Stack,
    ''false'' AS Area,
    ''ascending'' AS StackOrder,
    ''false'' AS ShowMark,
    LegendLabel
FROM (
    SELECT
        Bucket AS XAxisLabel,
        BucketSort,
        DENSE_RANK() OVER(ORDER BY Tender) AS VisId,
        Tender AS Stack,
        Tender AS LegendLabel,
        TipPct AS Value
    FROM agg
    WHERE N >= 5
) SUB

SELECT
    ''Bill Size Bucket'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Tip Rate by Bill Size (Like-for-Like)'' AS Title,
    ''ORDER_ID-based. Outliers > 3 standard deviations excluded per tender. Buckets with fewer than 5 orders suppressed.'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
    [Description] = N'Like-for-like tip rate by tender across bill-size buckets. ORDER_ID-based with 3-sigma exclusion and min 5 orders per bucket.',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionTipRateByBillSize' AND [Status] = N'LIVE';

PRINT '3. RedLionTipRateByBillSize - switched to ORDER_ID';


-- =============================================================================
-- 4. RedLionTipIncidenceByTender - ORDER_ID-based, bucketed StackedBarChartCard
-- =============================================================================
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH sessions AS (
    SELECT [ORDER_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [ORDER_ID], [Payment_Type]
),
bucketed AS (
    SELECT Tender, Tip, Bill,
           CASE WHEN Bill < 20  THEN 1
                WHEN Bill < 50  THEN 2
                WHEN Bill < 100 THEN 3
                WHEN Bill < 200 THEN 4
                ELSE 5 END AS BSort,
           CASE WHEN Bill < 20  THEN ''<'' + NCHAR(163) + ''20''
                WHEN Bill < 50  THEN NCHAR(163) + ''20-50''
                WHEN Bill < 100 THEN NCHAR(163) + ''50-100''
                WHEN Bill < 200 THEN NCHAR(163) + ''100-200''
                ELSE NCHAR(163) + ''200+'' END AS Bucket
    FROM sessions WHERE Bill > 0
),
counts AS (
    SELECT Tender, Bucket, BSort,
           ''With Gratuity'' AS TipStatus,
           SUM(CASE WHEN Tip > 0 THEN 1 ELSE 0 END) AS Cnt
    FROM bucketed
    GROUP BY Tender, Bucket, BSort
    UNION ALL
    SELECT Tender, Bucket, BSort,
           ''Without Gratuity'' AS TipStatus,
           SUM(CASE WHEN Tip = 0 THEN 1 ELSE 0 END) AS Cnt
    FROM bucketed
    GROUP BY Tender, Bucket, BSort
)
SELECT
    Tender + '' / '' + Bucket AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY Tender, BSort) AS LabelSort,
    Cnt AS Value,
    DENSE_RANK() OVER(ORDER BY Cnt) AS ValueSort,
    TipStatus AS VisId,
    ''A'' AS Stack
FROM counts

SELECT
    ''Payment Type / Bill Size'' AS XAxisLabel,
    ''Order Count'' AS YAxisLabel,
    ''Tip Incidence by Payment Type and Bill Size'' AS Title,
    ''Order counts split by tipped vs untipped, broken out by tender and bill-size bucket. ORDER_ID-based.'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
    [Description] = N'Tipped vs untipped order counts by tender and bill-size bucket. ORDER_ID-based.',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionTipIncidenceByTender' AND [Status] = N'LIVE';

PRINT '4. RedLionTipIncidenceByTender - switched to ORDER_ID';


-- =============================================================================
-- 5. RedLionTipMatrix - ORDER_ID-based CustomDataGrid
-- =============================================================================
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH sessions AS (
    SELECT [ORDER_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [ORDER_ID], [Payment_Type]
),
bucketed AS (
    SELECT Tender, Tip, Bill,
           CASE WHEN Bill < 20  THEN 1
                WHEN Bill < 50  THEN 2
                WHEN Bill < 100 THEN 3
                WHEN Bill < 200 THEN 4
                ELSE 5 END AS BSort,
           CASE WHEN Bill < 20  THEN ''<'' + NCHAR(163) + ''20''
                WHEN Bill < 50  THEN NCHAR(163) + ''20-50''
                WHEN Bill < 100 THEN NCHAR(163) + ''50-100''
                WHEN Bill < 200 THEN NCHAR(163) + ''100-200''
                ELSE NCHAR(163) + ''200+'' END AS Bucket
    FROM sessions WHERE Bill > 0
)
SELECT
    Tender AS Column1,
    Bucket AS Column2,
    COUNT(*) AS Column3,
    SUM(CASE WHEN Tip > 0 THEN 1 ELSE 0 END) AS Column4,
    SUM(CASE WHEN Tip = 0 THEN 1 ELSE 0 END) AS Column5,
    CAST(100.0 * SUM(CASE WHEN Tip > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS DECIMAL(6,2)) AS Column6,
    CAST(100.0 * SUM(Tip) / NULLIF(SUM(Bill), 0) AS DECIMAL(6,2)) AS Column7,
    CAST(SUM(Bill) AS DECIMAL(12,2)) AS Column8,
    CAST(SUM(Tip) AS DECIMAL(12,2)) AS Column9,
    NULL AS Column10, NULL AS Column11, NULL AS Column12, NULL AS Column13,
    NULL AS Column14, NULL AS Column15, NULL AS Column16, NULL AS Column17,
    NULL AS Column18, NULL AS Column19, NULL AS Column20, NULL AS Column21,
    NULL AS Column22, NULL AS Column23, NULL AS Column24, NULL AS Column25,
    NULL AS Column26, NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM bucketed
GROUP BY Tender, Bucket, BSort
ORDER BY Tender, BSort

SELECT
    ''Tip Incidence Matrix'' AS [Title],
    ''Per tender and bill-size bucket - order counts, tip incidence and tip rate. ORDER_ID-based.'' AS [Description],
    ''Tender'' AS [Label1], ''TEXT'' AS [Type1],
    ''Bill Size'' AS [Label2], ''TEXT'' AS [Type2],
    ''Total'' AS [Label3], ''INT'' AS [Type3],
    ''With Tip'' AS [Label4], ''INT'' AS [Type4],
    ''Without Tip'' AS [Label5], ''INT'' AS [Type5],
    ''Tip Incidence %'' AS [Label6], ''PERCENT'' AS [Type6],
    ''Tip Rate %'' AS [Label7], ''PERCENT'' AS [Type7],
    ''Net Revenue'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''Gratuity'' AS [Label9], ''DECIMAL'' AS [Type9],
    NULL AS [Label10], NULL AS [Type10], NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12], NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14], NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16], NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18], NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20], NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22], NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24], NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26], NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28], NULL AS [Label29], NULL AS [Type29]',
    [Description] = N'Full tip-incidence picture per tender and bill-size bucket. ORDER_ID-based.',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionTipMatrix' AND [Status] = N'LIVE';

PRINT '5. RedLionTipMatrix - switched to ORDER_ID';
