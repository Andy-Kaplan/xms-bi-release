-- ============================================================================
-- Map Growyze LINEITEM_TIMESTAMP for time-of-day enablement
-- Plan: docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md  Task 6
-- Ledger: O5
--
-- *** DEVIATION FROM PLAN (data-validated 2026-07-10) ***
-- The plan mapped LINEITEM_TIMESTAMP from OPEN_TIME (= s.sale_from). Live data
-- shows sale_from is a DAILY AGGREGATION WINDOW and is DATE-ONLY: all 693 Padel
-- DL_SALES rows sit at midnight (3 distinct values = 3 dates). Mapping from it
-- would populate the column but every line item would land in the 00:00 bucket
-- => intra-day cards still dead. We instead map from DL_SALES.createdAt, which
-- carries genuine order time-of-day (223 distinct values spread 05:00-22:00 UTC,
-- evening peak, 0 midnight, 0 unparseable). This is the source that actually
-- unblocks the hourly/heatmap cards.
--
-- Timezone: createdAt is ISO-8601 UTC (e.g. 2026-05-13T09:30:18.511Z). Converted
-- to UK local wall-time (GMT/BST DST-aware) so hour-of-day reads correctly for
-- these UK venues. SAFE re day grain: F_LINEITEM_15MIN takes the DAY from
-- ORDER_DATE and uses LINEITEM_TIMESTAMP only for the 15-min time bucket
-- (verified in the F_LINEITEM_15MIN PresentationControl step), so a midnight-
-- crossing conversion cannot move a row to the wrong day.
-- Granularity = per-ORDER creation time (all line items of an order share it).
--
-- SAT_LINEITEM.LINEITEM_TIMESTAMP already exists (consumed by the 15-min build),
-- so no DDL change is needed. Idempotent: wholesale UPDATE of staging query_sql
-- + staging_columns, and wholesale UPDATE of the LINEITEM entity mapping columns
-- (verified against live values on UAT 2026-07-10).
--
-- Deploy target: core. After deploy:
--   EXEC [core].[core].[UploadStagingControl]  @IntegrationSchema = N'int_growyze001';   -- if staging is regenerated
--   EXEC [core].[core].[UploadEntityMappings]   @IntegrationSchema = N'int_growyze001';   -- regenerate Load step to map the new column
-- then Growyze staging -> DV load -> presentation rebuild for each Growyze org.
-- ============================================================================

-- (a) Staging: add LINEITEM_TIMESTAMP (createdAt -> UK local) to GRYZ_LINEITEM.
UPDATE [core].[int_growyze001].[StagingControl]
SET updated_at = GETDATE(),
    query_sql = N'IF OBJECT_ID(''stage.GRYZ_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_LINEITEM];
WITH dish_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY posId, organizations ORDER BY createdDate DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE posId IS NOT NULL
),
dishes AS (SELECT * FROM dish_dedup WHERE rn = 1),
sales_agg AS (
    SELECT
        id,
        MIN([from]) AS sale_from,
        MIN([to]) AS sale_to,
        MIN(totalSales) AS totalSales,
        MIN(metadata_orderId) AS metadata_orderId,
        MIN(TRY_CONVERT(DATETIME2, createdAt, 127)) AS sale_created,
        COUNT(*) AS detail_count
    FROM [int_growyze001].[DL_SALES]
    GROUP BY id
)
SELECT * INTO [stage].[GRYZ_LINEITEM]
FROM (
    SELECT
        CONCAT_WS(''-'', sd.id, sd.items_posId) AS SRC_KEY,
        sd.id AS HEADER_ID,
        ''PROD'' AS LINEITEM_TYPE,
        sd.items_soldQty AS QUANTITY,
        sd.items_totalValue AS NET_VALUE,
        sd.items_totalValue AS GROSS_VALUE,
        s.sale_from AS ORDER_DATE,
        CAST(s.sale_from AS DATE) AS TRADING_DATE,
        d.id AS PRODUCT_KEY,
        sd.organizations AS LOCATION_KEY,
        ''-999'' AS OCC_ID,
        s.totalSales AS NET_SALES,
        s.detail_count AS ITEM_COUNT,
        s.sale_from AS OPEN_TIME,
        s.sale_to AS CLOSE_TIME,
        s.metadata_orderId AS EXTERNAL_REFERENCE,
        CAST(s.sale_created AT TIME ZONE ''UTC'' AT TIME ZONE ''GMT Standard Time'' AS DATETIME2(7)) AS LINEITEM_TIMESTAMP
    FROM [int_growyze001].[DL_SALESDETAIL] sd
    LEFT JOIN dishes d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
    LEFT JOIN sales_agg s ON sd.id = s.id
) AS source_query;',
    staging_columns = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE", "PRODUCT_KEY", "LOCATION_KEY", "OCC_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "EXTERNAL_REFERENCE", "LINEITEM_TIMESTAMP"]'
WHERE staging_table = N'GRYZ_LINEITEM' AND step_name = N'Growyze Line Item';

IF @@ROWCOUNT <> 1
    RAISERROR(N'Task6 abort: expected exactly 1 GRYZ_LINEITEM staging row updated.', 16, 1);

-- (b) Entity mapping: add LINEITEM_TIMESTAMP to LINEITEM source_columns + entity_columns
--     (appended last so positional alignment with the SAT column set is preserved).
UPDATE [core].[int_growyze001].[EntityMappings]
SET updated_at = GETDATE(),
    source_columns = N'[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 0}, {"name": "LINEITEM_TYPE", "hash": 0}, {"name": "QUANTITY", "hash": 0}, {"name": "NET_VALUE", "hash": 0}, {"name": "GROSS_VALUE", "hash": 0}, {"name": "ORDER_DATE", "hash": 0}, {"name": "TRADING_DATE", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}]',
    entity_columns = N'["HUB_ID", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE", "LINEITEM_TIMESTAMP"]'
WHERE entity_name = N'LINEITEM' AND source_table = N'GRYZ_LINEITEM';

IF @@ROWCOUNT <> 1
    RAISERROR(N'Task6 abort: expected exactly 1 LINEITEM entity mapping row updated.', 16, 1);

PRINT 'Task 6: LINEITEM_TIMESTAMP mapped from DL_SALES.createdAt (UK local time).';
