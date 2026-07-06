-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: outlier filter + drop (Unknown) tender
-- Target: UAT MI core DB (xms-bi-uat, database = core)
-- =============================================================================
-- Issue:
--   * Avg Spend chart skewed by extreme EftAtTable settlements (max
--     GBP 7,098 vs mean GBP 1,211 / std GBP 1,313).
--   * Like-for-Like chart shows ~2,100% spike on (Unknown) at "Under GBP 20"
--     (4 sessions, GBP 27 total revenue, ~GBP 567 of tip mis-attributed).
--
-- Fix:
--   * Drop NULL Payment_Type rows from all three new charts.
--   * Apply 3-sigma per-tender Bill filter on ATV + Like-for-Like
--     (keep rows where ABS(Bill - mean) <= 3 * stddev). Tested: removes 2-4
--     extreme rows per tender; EftAtTable mean drops ~5%, max drops 30%.
--   * Daily tip-rate chart: ratio is naturally robust at day level, just drop
--     (Unknown).
-- =============================================================================


-- 1. RedLionATVByTender - 3-sigma outlier filter
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH sessions AS (
    SELECT [Transaction_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [Transaction_ID], [Payment_Type]
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
    ''Avg Spend per Transaction by Payment Type'' AS Title,
    ''Outliers > 3 standard deviations excluded per tender.'' AS Description,
    NULL AS Trend,
    NULL AS TotalValue,
    NULL AS Chip',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionATVByTender' AND [Status] = N'LIVE';

PRINT '1. RedLionATVByTender - 3-sigma outlier filter applied, (Unknown) dropped';


-- 2. RedLionTipRateByBillSize - 3-sigma outlier filter, drop tiny buckets
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH sessions AS (
    SELECT [Transaction_ID],
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS Bill
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY [Transaction_ID], [Payment_Type]
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
    Bucket AS XAxisLabel,
    BucketSort AS LabelSort,
    TipPct AS Value,
    DENSE_RANK() OVER(ORDER BY TipPct) AS ValueSort,
    1 AS VisId,
    ''line'' AS VisType,
    Tender AS LegendLabel
FROM agg
WHERE N >= 5

SELECT
    ''Bill Size Bucket'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Tip Rate by Bill Size (Like-for-Like)'' AS Title,
    ''Outliers > 3 standard deviations excluded per tender. Buckets with fewer than 5 settlements suppressed.'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionTipRateByBillSize' AND [Status] = N'LIVE';

PRINT '2. RedLionTipRateByBillSize - 3-sigma outlier filter + min sample size 5';


-- 3. RedLionTipRateByDay - drop (Unknown) tender (no outlier filter — daily ratios are naturally robust)
UPDATE [core].[core].[VisualisationQueries]
SET [QueryTemplate] = N'WITH agg AS (
    SELECT CONVERT(DATE, [Trading_Date]) AS d,
           [Payment_Type] AS Tender,
           SUM(CASE WHEN [Item_Name] = ''Gratuity'' THEN [Item_Value] ELSE 0 END) AS Tip,
           SUM(CASE WHEN [Item_Name] <> ''Gratuity'' AND [Item_ID] > 0 THEN [Item_Value] ELSE 0 END) AS NetRev
    FROM [20260202_XMS_8381A215-4601-F111-8D4C-000D3AB579E6].[stage].[RedLion_Transactions]
    WHERE [Voided] = ''FALSE'' AND [Payment_Type] IS NOT NULL
    @FilterClause
    GROUP BY CONVERT(DATE, [Trading_Date]), [Payment_Type]
)
SELECT
    CONVERT(NVARCHAR(10), d, 23) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY d) AS LabelSort,
    CAST(100.0 * Tip / NULLIF(NetRev, 0) AS DECIMAL(6,2)) AS Value,
    DENSE_RANK() OVER(ORDER BY CAST(100.0 * Tip / NULLIF(NetRev, 0) AS DECIMAL(6,2))) AS ValueSort,
    1 AS VisId,
    ''line'' AS VisType,
    Tender AS LegendLabel
FROM agg
WHERE NetRev > 0

SELECT
    ''Trading Date'' AS XAxisLabel,
    ''Tip Rate (%)'' AS YAxisLabel,
    ''Daily Tip Rate by Payment Type'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
    [ModifiedDate] = GETDATE(),
    [ModifiedBy] = SUSER_SNAME()
WHERE [DataSetName] = N'RedLionTipRateByDay' AND [Status] = N'LIVE';

PRINT '3. RedLionTipRateByDay - (Unknown) dropped';
