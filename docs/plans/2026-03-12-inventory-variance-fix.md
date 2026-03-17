# Inventory Variance Pipeline Fix Plan

**Date:** 2026-03-12
**Status:** APPROVED
**Scripts folder:** `ClaudeDevelopment/inventory-variance-fix/`

## Executive Summary

The XMS BI platform has two paths for calculating inventory variances from MarketMan data. An investigation by three parallel agents identified 30+ issues across both paths. This plan fixes the **StockEvent granular path (Path A)** to become the authoritative source for all inventory variance, waste, and consumption KPIs — replacing the current reliance on the MarketMan reporting endpoint path (Path B / F_INVREPORT_DAY).

Path B is retained solely for **UOM_COST derivation** via the InvLocCost CTE until a better costing mechanism exists.

## Investigation Summary

### Path A: StockEvent (Granular) — Critical Issues

| # | Issue | Impact |
|---|---|---|
| S1 | SALE events produce 0 rows — `DL_MENU_PROFITABILITY.ID` join to `DL_MENU_ITEMS_SUBITEMS.ID` uses mismatched ID namespaces; stores don't overlap | THEO_USAGE missing all sales consumption |
| S2 | PRODUCTION events produce 0 rows — Kudu has no production event data in MarketMan (EventID NULL for all 9 rows) | THEO_USAGE missing production consumption |
| S3 | `STOCKCOUNT` instead of `COUNT` as EVENT_TYPE | Non-standard value; breaks EVENT_TYPE filtering |
| S4 | ORDER events use `SentDateUTC` not `DeliveryDateUTC` | Orders attributed to wrong count period (~1 day error) |
| S5 | `CONCAT_WS` REPORT_ID uses date as separator argument | Fragile key construction in InvReport staging |
| S6 | Transfer `BuyerFromGuid = storeId` filter drops rows | 6/9 transfers excluded; transfer imbalance (239.5 units) |
| S7 | Transfer TO-leg uses name-based cross-store item matching | Wrong INVITEM_HUB_ID if items share names |
| S8 | `EVENT_BEHANIOUR` typo in staging_columns + query aliases | Maintenance hazard (DV mapping corrects it) |
| S9 | Stock Event dedup window only covers ORDER branch | Other event types could carry duplicates |

### Presentation Layer — Critical Issues

| # | Issue | Impact |
|---|---|---|
| P1 | InvLocCost `PARTITION BY INVITEM_HUB_ID, INVITEM_HUB_ID` (duplicate) | Location-specific UOM_COST = cross-location average |
| P2 | UOM conversion hardcoded CTE instead of `reference.UOM_CONVERSION` | Inconsistent with other inventory steps |
| P3 | F_INV_SALES_DAY `IntegrationType = 'INVENTORY'` filter (should be POS, conditionally) | NET_SALES = 0 for all rows |
| P4 | F_INVREPORT_DAY has no DDL or build step in release scripts | 5 vis queries broken on fresh deploy |

### Visualisation Queries — Critical Issues

| # | Issue | Impact |
|---|---|---|
| V1 | 5 vis queries reference F_INVREPORT_DAY (no release script) | Runtime failure on fresh deploy |
| V2 | InvActMargin references `REPORTING_DATE`, `THEO_USAGE`, `ACTUAL_USAGE` (non-existent columns on F_INV_SALES_DAY) + unexplained `/10` | Runtime error |
| V3 | InvTheoMargin references `REPORTING_DATE` (wrong column) | Runtime error |
| V4 | Dead F_INV_SALES_DAY joins in 3 queries | Unnecessary complexity |
| V5 | InvUseAnalisys embedded SQL comment + label typo | MCP rejection; user-visible typo |

## Strategic Direction

1. Fix Path A staging to produce correct STOCKEVENT data (SALE, ORDER date, transfers, event types)
2. Fix shared presentation layer bugs (InvLocCost partition, UOM conversion, F_INV_SALES_DAY filter)
3. Migrate 5 vis queries from F_INVREPORT_DAY to Path A tables
4. Fix remaining vis query column reference bugs

---

## Phase 1: Fix Staging Bugs

All scripts target `core.int_marketman001.StagingControl`. MERGE key: `step_name`.

### Script 01: `01_sale_staging_fix.sql`

**Fixes:** S1 (SALE events produce 0 rows)
**Target step:** `step_name = 'Sales'`, `staging_table = 'MMAN_SALES'`

**Change:** Replace the `DL_MENU_PROFITABILITY → DL_MENU_ITEMS_SUBITEMS` join with `DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS → DL_INVENTORY_ITEMS → DL_UOM_TYPES`.

**New query_sql logic:**
```sql
SELECT * INTO [stage].[MMAN_SALES]
FROM (
    SELECT
        CONCAT_WS('-', storeId, ItemID) AS ItemID
        ,'SALE'  AS EVENT_TYPE
        ,'-'     AS EVENT_BEHAVIOUR
        ,UOM
        ,UOM     AS PACK_DESC
        ,1       AS PACK_QTY
        ,SUM(UOM_VALUE) AS UOM_VALUE
        ,EVENT_ID
        ,SALE_DATE
        ,storeId
    FROM (
        SELECT
            AVT.ItemID
            ,AVT.storeId
            ,UOM.Name AS UOM
            ,TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) AS UOM_VALUE
            ,CONCAT_WS('-', AVT.ItemID, AVT.storeId, AVT.RequestID) AS EVENT_ID
            ,AVT.INT_FETCH_DATE AS SALE_DATE
        FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS] AVT
        INNER JOIN [int_marketman001].[DL_INVENTORY_ITEMS] II
            ON AVT.ItemID = II.ID AND AVT.storeId = II.storeId
        INNER JOIN [int_marketman001].[DL_UOM_TYPES] UOM
            ON II.UOMID = UOM.ID AND II.storeId = UOM.storeId
        WHERE TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) != 0
    ) SUB
    GROUP BY
        CONCAT_WS('-', storeId, ItemID), UOM, EVENT_ID, SALE_DATE, storeId
) AS source_query;
```

**staging_columns** remain unchanged: `["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "SALE_DATE", "storeId"]`

**Verified:** 337 rows on Kudu UAT (KUDU Collective, 2026-03-08).

### Script 02: `02_stockcount_event_type_fix.sql`

**Fixes:** S3 (STOCKCOUNT → COUNT)
**Target step:** `step_name = 'Stock Count'`, `staging_table = 'MMAN_PRE_STOCK_COUNT'`

**Change:** In the `query_sql`, replace all occurrences of `'STOCKCOUNT'` with `'COUNT'` in the EVENT_TYPE assignment. Use `CAST(REPLACE(CAST(query_sql AS NVARCHAR(MAX)), ...))` pattern since `query_sql` is nvarchar(MAX).

**Also update** the Stock Event tier-2 step (`step_name = 'Stock Event'`) if it hardcodes `STOCKCOUNT` anywhere in its UNION ALL branch for stock counts. (Investigation shows it reads `EVENT_TYPE` from the pre-stage table, so changing the pre-stage is sufficient.)

### Script 03: `03_order_delivery_date_fix.sql`

**Fixes:** S4 (ORDER EVENT_TS uses SentDateUTC)
**Target step:** `step_name = 'Order Items'`, `staging_table = 'MMAN_PRE_ORDEREVENT'`

**Change:** In the `query_sql`, replace:
```sql
,o.SentDateUTC as EVENT_TS
```
with:
```sql
,COALESCE(o.DeliveryDateUTC, o.SentDateUTC) as EVENT_TS
```

Falls back to SentDate when DeliveryDateUTC is NULL.

### Script 04: `04_report_id_key_fix.sql`

**Fixes:** S5 (CONCAT_WS separator bug in REPORT_ID)
**Target step:** `step_name = 'Report'`, `staging_table = 'MMAN_REPORT'`

**Change:** In the `query_sql`, replace:
```sql
CONCAT_WS(CAST(REP.REPORTING_DATE AS DATETIME2), REP.[storeId], REP.[ItemID]) AS REPORT_ID
```
with:
```sql
CONCAT_WS('-', REP.[storeId], REP.[ItemID], CAST(REP.REPORTING_DATE AS NVARCHAR(30))) AS REPORT_ID
```

**Note:** This changes the hash key for HUB_INVREPORT. Existing records will have the old key format. New records will get the new format. This is acceptable for a re-load scenario but means existing data will create new hub records rather than matching old ones. Document this as a known consequence — a full re-stage + re-load is needed after deployment.

### Script 05: `05_transfer_staging_fix.sql`

**Fixes:** S6 (BuyerFromGuid = storeId drops rows) + S7 (name-based cross-store matching)
**Target step:** `step_name = 'Transfers'`, `staging_table = 'MMAN_TRANSFERS'`

**Changes:**

**S6 fix — FROM-leg filter:** The current filter `TE.[BuyerFromGuid] = TE.[storeId]` only picks up transfers fetched in the FROM store's API context. Change to use `BuyerFromGuid` and `BuyerToGuid` explicitly:
- FROM-leg (stock out): `WHERE TE.[BuyerFromGuid] = TE.[storeId]` — keep as-is, this is correct for the sending store
- TO-leg (stock in): Change to `WHERE TE.[BuyerToGuid] = TE.[storeId]` — picks up rows fetched in the receiving store's context
- Add a third branch for rows where `BuyerFromGuid IS NULL` — these need investigation; may need to use `TransferStatus` to determine direction

**S7 fix — name-based item matching:** The TO-leg currently resolves destination item ID via `O.Name = I.Name` across stores. Improve by:
1. First attempt: match by inventory item ID directly if `BuyerToGuid = storeId` (the DL row was fetched in the TO store's context, so `ItemID` is already the TO store's item)
2. Fallback: keep name-based matching for rows fetched in the FROM store's context where `ItemID` is the FROM store's item ID

**Implementation detail:** This requires reading the current full transfer query from UAT, understanding the FROM/TO branch structure, and rewriting both branches. The exact SQL will need to be developed during implementation by examining the current query and the DL_TRANSFERS data patterns.

### Script 06: `06_event_behaviour_typo_fix.sql`

**Fixes:** S8 (EVENT_BEHANIOUR typo) + S9 (dedup only on ORDER branch)
**Target step:** `step_name = 'Stock Event'`, `staging_table = 'MMAN_STOCKEVENT'`

**Changes:**

**S8 — Typo fix:** In the tier-2 Stock Event `query_sql`:
1. Replace all `EVENT_BEHANIOUR` aliases with `EVENT_BEHAVIOUR`
2. Update `staging_columns` JSON: `"EVENT_BEHANIOUR"` → `"EVENT_BEHAVIOUR"`
3. **Also update** the EntityMappings source column reference for STOCKEVENT: the mapping currently reads `EVENT_BEHANIOUR` from the stage table and maps to `EVENT_BEHAVIOUR` in the DV. After the rename, both sides should be `EVENT_BEHAVIOUR`.

This requires a second MERGE against `core.int_marketman001.EntityMappings` on the entity mapping's natural key (EntityName + source column, or however the mapping is keyed).

**S9 — Extend dedup to all branches:** Wrap the entire UNION ALL in an outer `ROW_NUMBER() OVER (PARTITION BY SRC_KEY ORDER BY EVENT_TS DESC)` and filter to `RANKER = 1`. This deduplicates across all event types, not just orders.

---

## Phase 2: Fix Presentation Layer Bugs

All scripts target `core.core.PresentationControl`. MERGE key: `step_name`. Note: `query_sql` column is `text` type — use `CAST(REPLACE(CAST(query_sql AS NVARCHAR(MAX)), ...) AS TEXT)` pattern.

### Script 07: `07_invloccost_partition_fix.sql`

**Fixes:** P1 (InvLocCost PARTITION BY duplicate)
**Target steps:** `step_name = 'Inventory Counts by Day'` AND `step_name = 'Inventory Usage by Day'`

**Change:** In both steps' `query_sql`, replace:
```sql
PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]
```
with:
```sql
PARTITION BY LII.[INVITEM_HUB_ID], LIL.[LOCATION_HUB_ID]
```

Two MERGEs in one script (one per step).

### Script 08: `08_uom_reference_table_fix.sql`

**Fixes:** P2 (hardcoded UOM conversion CTE)
**Target steps:** `step_name = 'Inventory Counts by Day'` AND `step_name = 'Inventory Usage by Day'`

**Change:** Replace the inline `UOMConversion AS (SELECT 'gr' AS UOM, ... UNION ALL ...)` CTE in both steps with:
```sql
UOMConversion AS (
    SELECT FROM_UOM AS UOM, TO_UOM AS base_uom, conversion_factor
    FROM [core].[reference].[UOM_CONVERSION]
)
```

Consistent with the fix already deployed in `ClaudeDevelopment/12_uom_conversion_fix.sql` for the other 3 inventory PresentationControl steps.

**Can be combined with Script 07** since both target the same two steps. If combined, the MERGE updates both the PARTITION BY fix and the UOM CTE replacement in a single update per step.

### Script 09: `09_inv_sales_day_pos_filter.sql`

**Fixes:** P3 (F_INV_SALES_DAY IntegrationType filter)
**Target step:** `step_name = 'Inventory Sales by Day'`

**Change:** Add a `@HasPOS` variable declaration at the top of the query, before the CTE chain:
```sql
DECLARE @HasPOS BIT = CASE WHEN EXISTS (
    SELECT 1 FROM [core].[core].[OrganisationIntegrations] OI
    INNER JOIN [core].[core].[Integrations] I ON OI.IntegrationID = I.IntegrationID
    INNER JOIN [core].[core].[Organisations] O ON OI.OrganisationID = O.OrganisationID
    WHERE O.DatabaseName = DB_NAME()
    AND I.IntegrationType = 'POS'
) THEN 1 ELSE 0 END
```

Then in the ProductSales CTE, change:
```sql
AND IG.IntegrationType = 'INVENTORY'
```
to:
```sql
AND (@HasPOS = 0 OR IG.IntegrationType = 'POS')
```

**Behaviour:**
- Org has POS + INVENTORY: filters to POS lineitems only (no duplicates)
- Org has INVENTORY only: no filter (all lineitems flow through)

---

## Phase 3: Migrate Vis Queries from F_INVREPORT_DAY

All scripts target `core.core.VisualisationQueries`. MERGE key: `(DataSetName, VisualizationType)`.

### Script 10: `10_migrate_variance_kpis.sql`

**Fixes:** V1 (5 vis queries reference F_INVREPORT_DAY)

Contains 5 MERGEs, one per vis query:

**10a. InvPosVar (SingleKPICard)**
Replace F_INVREPORT_DAY subquery with:
```sql
SELECT
    'Positive Variance' AS Title
    ,FORMAT(ROUND(SUM(CASE WHEN FC.VARIANCE > 0
        THEN FC.VARIANCE * FC.UOM_COST ELSE 0 END), 2), 'N0') AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 @FilterClause
```

**10b. InvNegVar (SingleKPICard)**
Same pattern, `CASE WHEN FC.VARIANCE < 0`.

**10c. InvWasteCost (SingleKPICard)**
Replace with:
```sql
SELECT
    'Waste Cost' AS Title
    ,FORMAT(ROUND(SUM(ABS(ISNULL(FU.WASTE_QTY, 0)) * ISNULL(FU.UOM_COST, 0)), 2), 'N0') AS Value
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[EVENT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 @FilterClause
```

**10d. InvCountVariance (CombinedChartCard)**
Rewrite to use F_INV_COUNTS_DAY, grouped by COUNT_DATE. Data points appear only on count dates (when variance is actually measurable).

**10e. InvTop20Variance (StackedBarChartCard)**
Rewrite to use F_INV_COUNTS_DAY, `TOP 20` by `ABS(VARIANCE * UOM_COST)`, split into positive/negative stacks by invitem name.

**Implementation note:** The exact column names in F_INV_COUNTS_DAY and F_INV_USAGE_DAY (EVENT_DATE vs COUNT_DATE, etc.) must be verified against the PresentationTables DDL during implementation. The FilterDefinitions and ParameterMappings JSON should be updated to reference the correct table aliases and date columns. OutputDefinitions (header metadata for the second result set) should be preserved from the existing queries.

---

## Phase 4: Fix Broken Vis Queries

### Script 11: `11_fix_vis_query_columns.sql`

**Fixes:** V2, V3, V4, V5

Contains multiple MERGEs:

**11a. InvActMargin (PieChartCard)** — V2
- Replace `FS.[REPORTING_DATE]` with `FS.[INV_DATE]`
- Replace `FS.THEO_USAGE` and `FS.ACTUAL_USAGE` references with a JOIN to `F_INV_USAGE_DAY` for those columns (join on INVITEM_HUB_ID + LOCATION_HUB_ID + date)
- Remove the unexplained `/ 10` divisor on ACTUAL_COST

**11b. InvTheoMargin (PieChartCard)** — V3
- Replace `FS.[REPORTING_DATE]` with `FS.[INV_DATE]`

**11c. InvRecipeMargin (PieChartCard)**
- Verify and fix any similar column reference issues

**11d. Remove dead joins** — V4
- InvOrdersCost, InvProdEventCost, InvProdEventValue: remove the `LEFT OUTER JOIN [presentation].[F_INV_SALES_DAY]` that is never referenced

**11e. InvUseAnalisys cleanup** — V5
- Remove embedded SQL comment (`-- SELECT *`)
- Fix label typo: `'ACTUAL USEAGE'` → `'ACTUAL USAGE'`

---

## Script Inventory

| Script | Phase | Target | MERGE Key | Issue(s) |
|---|---|---|---|---|
| `01_sale_staging_fix.sql` | 1 | int_marketman001.StagingControl | step_name = 'Sales' | S1 |
| `02_stockcount_event_type_fix.sql` | 1 | int_marketman001.StagingControl | step_name = 'Stock Count' | S3 |
| `03_order_delivery_date_fix.sql` | 1 | int_marketman001.StagingControl | step_name = 'Order Items' | S4 |
| `04_report_id_key_fix.sql` | 1 | int_marketman001.StagingControl | step_name = 'Report' | S5 |
| `05_transfer_staging_fix.sql` | 1 | int_marketman001.StagingControl | step_name = 'Transfers' | S6, S7 |
| `06_event_behaviour_typo_fix.sql` | 1 | int_marketman001.StagingControl + EntityMappings | step_name = 'Stock Event' | S8, S9 |
| `07_invloccost_partition_fix.sql` | 2 | core.PresentationControl | step_name = 'Inventory Counts by Day' + 'Inventory Usage by Day' | P1 |
| `08_uom_reference_table_fix.sql` | 2 | core.PresentationControl | (same two steps) | P2 |
| `09_inv_sales_day_pos_filter.sql` | 2 | core.PresentationControl | step_name = 'Inventory Sales by Day' | P3 |
| `10_migrate_variance_kpis.sql` | 3 | core.VisualisationQueries | (DataSetName, VisualizationType) ×5 | V1 |
| `11_fix_vis_query_columns.sql` | 4 | core.VisualisationQueries | (DataSetName, VisualizationType) ×5+ | V2-V5 |

## Deploy Order

```
Phase 1 (staging):  01 → 02 → 03 → 04 → 05 → 06
Phase 2 (presentation): 07 → 08 → 09
Phase 3 (vis migration): 10
Phase 4 (vis fixes): 11

Post-deploy:
  1. Re-run staging pipeline for target org
  2. Re-run DV load (sp_DataVaultLoad)
  3. Re-run presentation build (sp_RunPresentationControl)
  4. Verify dashboard figures
```

Scripts 07 + 08 could be combined (same target steps). No cross-phase dependencies — phases are independent at the SQL level, but logically Phase 3 should come after Phase 2 since the migrated vis queries consume the corrected presentation tables.

## Testing Strategy

**Post-deployment verification (agent team):**
1. Run each migrated vis query via MCP against Kudu UAT
2. Compare variance/waste/sales figures to pre-fix baseline (captured during investigation)
3. Verify no runtime errors from column references
4. Check Three Rocks Cafe (POS + INVENTORY org) for duplicate-free sales attribution
5. Validate transfer in/out balance improved from current 239.5 unit gap
6. Confirm SALE events appear in SAT_STOCKEVENT (expect ~337 rows for Kudu)

**Expected baseline shifts:**
- InvPosVar / InvNegVar: Will change from F_INVREPORT_DAY values to Path A values (magnitude will differ — Path A covers fewer items initially until SALE events are flowing)
- InvWasteCost: Should remain similar (502 WASTE events already in SAT_STOCKEVENT)
- F_INV_SALES_DAY.NET_SALES: Will be non-zero for orgs with POS integration; still zero for Kudu (MarketMan only)

## Deferred Items

| Item | Reason |
|---|---|
| `UOM_QUANITY` column rename | Requires ALTER TABLE on every client DB; cosmetic only |
| PRODUCTION staging | No data in MarketMan for Kudu; join logic is correct |
| F_INVREPORT_DAY release script formalisation | No longer needed if vis queries migrate to Path A |
| Release script sync (entity definitions, tier-2 staging) | Separate workstream; out of scope for this fix |
| `STOCKEVENT_START/END` GlobalParameters investigation | Low priority; tables are populated despite NULL params |
