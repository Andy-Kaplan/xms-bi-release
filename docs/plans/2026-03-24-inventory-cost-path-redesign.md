# Inventory Cost Path Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the INVREPORT-dependent cost derivation path with an integration-agnostic approach using SAT_INVITEM catalogue/BOM prices, eliminating the MarketMan-only SAT_INVREPORT dependency.

**Architecture:** SAT_INVITEM gains a `UOM_COST` column populated from catalogue prices (Growyze: `DL_PRODUCTS.price`, MarketMan: `DL_INVENTORY_ITEMS.BOMPrice`). The existing InvLocCost CTE (which reads SAT_INVREPORT via two link tables) is replaced with a simple InvItemCost CTE that reads SAT_INVITEM directly. This change touches only 2 PresentationControl steps (F_INV_COUNTS_DAY and F_INV_USAGE_DAY). F_INV_SALES_DAY (Tier 2) inherits the change automatically. Vis queries are fully transparent — no changes needed.

**Tech Stack:** SQL Server Managed Instance, Data Vault 2.0 entity definitions, PresentationControl config-driven build steps

---

## Background & Motivation

The current cost path is:
```
MarketMan AVT API → SAT_INVREPORT.UOM_COST → InvLocCost CTE → F_INV_COUNTS_DAY / F_INV_USAGE_DAY → F_INV_SALES_DAY
```

**Problems:**
1. SAT_INVREPORT is MarketMan-only — Growyze has 0 rows → 100% NULL costs → all monetary vis queries return zero
2. INVREPORT was a temporary solution consuming a pre-computed blended average from MarketMan's API, not a platform-level cost concept
3. The InvLocCost CTE has a PARTITION BY bug (`INVITEM_HUB_ID` listed twice instead of `INVITEM_HUB_ID, LOCATION_HUB_ID`)

**New design:**
```
SAT_INVITEM.UOM_COST (catalogue/BOM price per item)
    → InvItemCost CTE (UOM-converted, per item)
    → F_INV_COUNTS_DAY.UOM_COST + F_INV_USAGE_DAY.UOM_COST
    → F_INV_SALES_DAY (Tier 2, automatic)
```

Every inventory integration populates SAT_INVITEM, making this fully integration-agnostic.

---

## Cost Data Sources by Integration

| Integration | Source DL Table | Column | Status |
|---|---|---|---|
| Growyze | `DL_PRODUCTS` | `price` | Available — already in ATTR_5 as NVARCHAR, not typed as cost |
| MarketMan | `DL_INVENTORY_ITEMS` | `BOMPrice` | Available — not currently staged |
| MarketMan | `DL_INVENTORY_PREPS` | `BOMPrice` | Available — not currently staged |

---

## Entity Change

| Entity | Current Version | New Version | Change |
|---|---|---|---|
| INVITEM | v3 Live | v4 Live (v3 Retired) | Add `UOM_COST DECIMAL(38,10)` |

---

## Downstream Impact Analysis

**Transparent to vis layer:** All 12 cost-consuming vis queries read `UOM_COST` as a column from fact tables — they don't reference the derivation source. No vis query changes needed.

**PresentationControl changes:** Only 2 steps change (F_INV_COUNTS_DAY and F_INV_USAGE_DAY). F_INV_SALES_DAY (Tier 2) reads UOM_COST from F_INV_USAGE_DAY and recalculates automatically. Parent org PF_INV_* tables aggregate from child org fact tables — also automatic.

**Bug fix included:** The PARTITION BY bug in InvLocCost (line 2101 and 2322 of `8_PresentationControl.sql`) is eliminated — the new CTE has no windowed average over location, just a direct per-item cost lookup.

---

## Scripts Location

All scripts go in `ClaudeDevelopment/cost-path-redesign/`. Follow the CLAUDE.md rules: unqualified two-part table names only, MERGE upsert pattern for control table records.

---

## Phase 1: Entity Definition

### Task 1: INVITEM v4 Entity Definition

**Files:**
- Create: `ClaudeDevelopment/cost-path-redesign/01_invitem_v4_entity.sql`
- Reference: `8_DataVaultEntities.sql:1440-1458` (current INVITEM v3 Live)

This script retires INVITEM v3 and inserts v4 with `UOM_COST` added.

- [ ] **Step 1: Write the entity definition script**

```sql
/* ============================================================================
   INVITEM v3 → v4: Add UOM_COST attribute

   Adds UOM_COST DECIMAL(38,10) to SAT_INVITEM for carrying catalogue/BOM
   unit prices. This replaces SAT_INVREPORT as the cost source in the
   PresentationControl layer.

   After running this script, run sp_GenerateDataVaultTables for each org
   to ALTER the physical SAT_INVITEM table.
   ============================================================================ */

-- Retire v3
UPDATE [core].[core].[DataVaultEntities]
SET RELEASE_STATE = N'Retired', UPDATED_AT = GETDATE()
WHERE ENTITY_NAME = N'INVITEM' AND VERSION = 3 AND RELEASE_STATE = N'Live';

-- Insert v4 Live
-- Attributes: same as v3 + UOM_COST at end
MERGE INTO [core].[core].[DataVaultEntities] AS tgt
USING (VALUES (N'INVITEM', 4)) AS src (ENTITY_NAME, VERSION)
ON tgt.ENTITY_NAME = src.ENTITY_NAME AND tgt.VERSION = src.VERSION
WHEN MATCHED THEN
    UPDATE SET
        RELEASE_STATE = N'Live',
        ATTRIBUTE_NAMES = N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN", "UOM_COST"]',
        ATTRIBUTE_TYPES = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Catalogue/BOM unit cost in the item native UOM."}]',
        UPDATED_AT = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
            TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
            CREATED_AT, UPDATED_AT)
    VALUES (
        N'INVITEM', 4, N'Live', N'1', NULL, 0, NULL,
        N'Inventory item dimension (v4 — adds UOM_COST for catalogue pricing)',
        N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN", "UOM_COST"]',
        N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Catalogue/BOM unit cost in the item native UOM."}]',
        GETDATE(), GETDATE()
    );
```

- [ ] **Step 2: Test via MCP** — Verify current INVITEM v3 entity exists. Query `core.core.DataVaultEntities` filtering on `ENTITY_NAME = 'INVITEM'` to confirm v3 is Live before running.

- [ ] **Step 3: Update QUERY_STATUS.md** — Add entry for this script.

---

## Phase 2: Staging Changes — Growyze

### Task 2: Growyze GRYZ_INVITEMS — Add UOM_COST Column

**Files:**
- Create: `ClaudeDevelopment/cost-path-redesign/02_growyze_invitems_uom_cost.sql`
- Reference: `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql` — Step 2 "Growyze Inventory Items" (lines 43-95)
- Reference: `ClaudeDevelopment/integrations/Growyze/04_entity_mappings.sql` — Mapping #1 INVITEM from GRYZ_INVITEMS

The current GRYZ_INVITEMS staging already extracts `price` from `DL_PRODUCTS` into `ATTR_5` as `NVARCHAR(MAX)`. This task adds a parallel `UOM_COST` column as `DECIMAL(38,10)` for the entity mapping, and updates the entity mapping to include it.

- [ ] **Step 1: Write the staging update script**

The staging query's leaf-level SELECT (first branch of UNION ALL) changes to add:
```sql
TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST
```
The sub-category and category branches add `CAST(NULL AS DECIMAL(38,10)) AS UOM_COST` (they have no price).

The `staging_columns` JSON array must add `"UOM_COST"` at the end.

**Key detail:** Only leaf items (`BOTTOM_LEVEL = 1`) carry price. Categories/sub-categories are `NULL`.

- [ ] **Step 2: Update the Growyze INVITEM entity mapping** — Add `UOM_COST` to both source_columns and entity_columns in `EntityMappings`:
  - Source column: `{"name": "UOM_COST", "hash": 0}`
  - Entity column: `"UOM_COST"`

  **Note:** `MICROSERVICE_ID_BIN` (entity attribute #14) is currently unmapped in the Growyze INVITEM mapping — it was added in v3 but the Growyze mapping predates it. This is a pre-existing gap (the engine NULL-fills unmapped attributes). Do NOT add `MICROSERVICE_ID_BIN` in this task — it requires a separate staging change. Just add `UOM_COST` to the end of the existing mapping.

- [ ] **Step 3: Test via MCP** — Run the staging query (manually, with three-part naming against Padel Social) and verify `UOM_COST` column is populated for leaf items, NULL for categories.

- [ ] **Step 4: Update QUERY_STATUS.md**

---

## Phase 3: Staging Changes — MarketMan

### Task 3: MarketMan MMAN_INVITEMS — Add BOMPrice

**Files:**
- Create: `ClaudeDevelopment/cost-path-redesign/03_marketman_invitems_uom_cost.sql`
- Reference: `MarketMan/MarketMan001_Staging.sql:9-163` (current staging)
- Reference: `MarketMan/MarketMan001_Mapping.sql` (current entity mapping)

The current MMAN_INVITEMS staging reads from `DL_INVENTORY_ITEMS` and `DL_INVENTORY_PREPS` but does NOT extract `BOMPrice`. This task adds it.

- [ ] **Step 1: Write the staging update script**

The MMAN_INVITEMS staging query has 5 UNION ALL branches:
1. Leaf items from `DL_INVENTORY_ITEMS` → add `TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST`
2. Categories from `DL_INVENTORY_ITEMS` → add `CAST(NULL AS DECIMAL(38,10)) AS UOM_COST`
3. Prep items from `DL_INVENTORY_PREPS` → add `TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST`
4. Prep categories → add `CAST(NULL AS DECIMAL(38,10)) AS UOM_COST`
5. COGS categories from `DL_ACTUAL_VS_THEO` → add `CAST(NULL AS DECIMAL(38,10)) AS UOM_COST`

Update `staging_columns` JSON to include `"UOM_COST"`.

- [ ] **Step 2: Update the MarketMan INVITEM entity mapping** — The current MarketMan INVITEM mapping (in `MarketMan/MarketMan001_Mapping.sql`) maps only 12 of v3's 14 attributes (skips MICROSERVICE_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN). This is safe — the `BuildSelectClause` engine uses **name-based** INSERT columns (`source_col AS entity_col_name`), not positional slot assignment. Unmapped attributes are NULL-filled by the load table. Add `UOM_COST` to the end of both arrays:
  - Source column: `{"name": "UOM_COST", "hash": 0}`
  - Entity column: `"UOM_COST"`

  **Important:** This mapping update goes into the new `03_marketman_invitems_uom_cost.sql` script in `ClaudeDevelopment/cost-path-redesign/` as a MERGE against `core.int_marketman001.EntityMappings`. Do NOT edit the read-only release file `MarketMan/MarketMan001_Mapping.sql`.

- [ ] **Step 3: Test via MCP** — Run the staging query against Three Rocks Cafe (MarketMan org). Verify `BOMPrice` → `UOM_COST` is populated for leaf items.

- [ ] **Step 4: Cross-validate** — Compare a sample of MarketMan `BOMPrice` values against the existing `SAT_INVREPORT.UOM_COST` for the same items. They should be in the same ballpark (order-of-magnitude check — BOMPrice is last purchase cost, INVREPORT is a blended average, so they won't be identical).

- [ ] **Step 5: Update QUERY_STATUS.md**

---

## Phase 4: PresentationControl Changes

### Task 4: Replace InvLocCost in F_INV_COUNTS_DAY

**Files:**
- Create: `ClaudeDevelopment/cost-path-redesign/04_presentation_counts_cost.sql`
- Reference: `8_PresentationControl.sql:2096-2166` (current InvLocCost + InvCost CTEs in F_INV_COUNTS_DAY)

The InvLocCost CTE currently reads from `SAT_INVREPORT` via `LNK_INVITEM_INVREPORT` and `LNK_INVREPORT_LOCATION`. Replace with a simple `InvItemCost` CTE that reads from `SAT_INVITEM` directly.

- [ ] **Step 1: Write the replacement CTE**

Replace the existing `InvLocCost` and `InvCost` CTEs with a single CTE:

```sql
InvItemCost AS (
    SELECT
        II.[HUB_ID] AS INVITEM_HUB_ID,
        II.[UOM_COST] / NULLIF(UC.[conversion_factor], 0) AS UOM_COST
    FROM [datavault].[SAT_INVITEM] II
    LEFT JOIN UOMConversion UC
        ON II.[UOM] = UC.[UOM]
    WHERE II.[CURRENT_FLAG] = 1
      AND II.[UOM_COST] IS NOT NULL
      AND II.[BOTTOM_LEVEL] = 1
)
```

Replace the two LEFT OUTER JOINs (`InvLocCost ILC` + `InvCost IC`) with a single join:
```sql
LEFT OUTER JOIN InvItemCost IIC
    ON c.[INVITEM_HUB_ID] = IIC.[INVITEM_HUB_ID]
```

Replace the COALESCE in the SELECT:
```sql
-- Old: COALESCE(ILC.UOM_COST, IC.UOM_COST) AS UOM_COST
-- New:
IIC.UOM_COST AS UOM_COST
```

**This eliminates the PARTITION BY bug** — the old CTE had `PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]` (same column twice). The new CTE has no windowed aggregate at all — just a direct per-item cost lookup.

**Note on `@InvItemAvgDays`:** This variable (declared and set to 30 at lines 1951-1953 of the existing query template) is no longer needed — INVITEM cost is not time-windowed. The DECLARE/SET can be removed or left as dead code. The `@StartDate` and `@EndDate` variables remain needed for the StockEvent date filtering in the upstream CTEs.

- [ ] **Step 2: Write the full PresentationControl MERGE** — Wrap the complete query (all CTEs including UOMConversion, StockEvents, EventsWithCountGroup, MovementsByGroup, CountsWithPrevious, plus InvItemCost) in a MERGE INTO `core.core.PresentationControl` updating the "Inventory Counts by Day" step.

- [ ] **Step 3: Verify the query compiles** — Extract the query template, manually prefix table names with a test org DB, and run via MCP to verify it produces results with non-NULL UOM_COST.

- [ ] **Step 4: Update QUERY_STATUS.md**

---

### Task 5: Replace InvLocCost in F_INV_USAGE_DAY

**Files:**
- Create: `ClaudeDevelopment/cost-path-redesign/05_presentation_usage_cost.sql`
- Reference: `8_PresentationControl.sql:2317-2375` (current InvLocCost + InvCost CTEs in F_INV_USAGE_DAY)

Identical CTE replacement as Task 4, but in the "Inventory Usage by Day" step.

- [ ] **Step 1: Write the replacement CTE** — Same `InvItemCost` CTE and single LEFT JOIN. Copy from Task 4.

- [ ] **Step 2: Write the full PresentationControl MERGE** — Wrap the complete query for F_INV_USAGE_DAY.

- [ ] **Step 3: Verify via MCP** — Same pattern as Task 4.

- [ ] **Step 4: Update QUERY_STATUS.md**

---

## Phase 5: Deploy Script & Testing

### Task 6: Deploy Order and Integration Test

**Files:**
- Create: `ClaudeDevelopment/cost-path-redesign/DEPLOY.txt`

- [ ] **Step 1: Write DEPLOY.txt**

```
=== Inventory Cost Path Redesign — Deploy Order ===

Pre-requisites:
- Growyze staging scripts (02-04) must be deployed first
- sp_GenerateDataVaultTables must be run AFTER entity definition (step 1)

Deploy order:

1. 01_invitem_v4_entity.sql             — Entity definition (core DB)
2. Run sp_GenerateDataVaultTables       — ALTERs physical SAT_INVITEM in all org DBs
3. 02_growyze_invitems_uom_cost.sql     — Growyze INVITEM staging + mapping
4. 03_marketman_invitems_uom_cost.sql   — MarketMan INVITEM staging + mapping
5. Run UploadEntityMappings:
     EXEC [core].[UploadEntityMappings] @intSchema = N'int_growyze001'
     EXEC [core].[UploadEntityMappings] @intSchema = N'int_marketman001'
6. 04_presentation_counts_cost.sql      — PresentationControl: F_INV_COUNTS_DAY
7. 05_presentation_usage_cost.sql       — PresentationControl: F_INV_USAGE_DAY

Post-deploy:
- Run a full data load (sp_DataVaultLoad) for at least one Growyze and one MarketMan org
- Verify SAT_INVITEM.UOM_COST is populated for leaf items (BOTTOM_LEVEL = 1)
- Verify F_INV_COUNTS_DAY.UOM_COST and F_INV_USAGE_DAY.UOM_COST are non-NULL
- Verify F_INV_SALES_DAY recalculates correctly (Tier 2 — automatic)
- Compare MarketMan cost values before/after for regression check
```

- [ ] **Step 2: Integration test checklist**

After deployment, verify these queries return non-NULL cost data:

| Test | Query | Expected |
|---|---|---|
| Growyze INVITEM cost | `SELECT TOP 10 UOM_COST, UOM, INVITEM_NAME FROM SAT_INVITEM WHERE UOM_COST IS NOT NULL AND BOTTOM_LEVEL = 1` | Leaf items with catalogue prices |
| MarketMan INVITEM cost | Same query on Three Rocks Cafe DB | Leaf items with BOM prices |
| F_INV_COUNTS_DAY cost (Growyze) | `SELECT COUNT(*), SUM(CASE WHEN UOM_COST IS NOT NULL THEN 1 ELSE 0 END) FROM F_INV_COUNTS_DAY` on Padel Social | Significant non-NULL % (was 0% before) |
| F_INV_USAGE_DAY cost (Growyze) | Same as above | Significant non-NULL % (was 0% before) |
| F_INV_SALES_DAY cascade | `SELECT TOP 10 SALES_RECIPE_COST, NET_SALES FROM F_INV_SALES_DAY WHERE UOM_COST > 0` | Non-zero SALES_RECIPE_COST |
| MarketMan regression | Compare `AVG(UOM_COST)` per item in F_INV_USAGE_DAY before and after | Values in same order of magnitude |

- [ ] **Step 3: Update QUERY_STATUS.md** with final status for all scripts.

---

## Phase 6: Documentation Updates

### Task 7: Update Reference Documentation

**Files:**
- Modify: `docs/data-vault-reference.md` — INVITEM entity (v4 attributes, add UOM_COST)
- Modify: `docs/presentation-and-visualisation.md` — F_INV_COUNTS_DAY and F_INV_USAGE_DAY cost derivation description
- Modify: `docs/data-pipeline.md` — Cost path description (remove INVREPORT dependency, describe INVITEM cost flow)

- [ ] **Step 1: Update data-vault-reference.md** — Add UOM_COST to INVITEM attribute table. Note version bump v3→v4.

- [ ] **Step 2: Update presentation-and-visualisation.md** — Update the cost derivation description in the PresentationControl section for the two affected steps. Remove InvLocCost/InvCost CTE references, document InvItemCost CTE.

- [ ] **Step 3: Update data-pipeline.md** — Describe the new cost source (SAT_INVITEM.UOM_COST replaces SAT_INVREPORT.UOM_COST).

- [ ] **Step 4: Update CLAUDE.md if needed** — If the architecture summary references INVREPORT as the cost source, update it.

---

## Design Decisions & Rationale

### Why INVITEM and not STOCKEVENT?
STOCKEVENT is a quantity-movement entity (ORDER, SALE, WASTE, COUNT, TRANSFER, PRODUCTION). Only ORDER events have cost data at source — the other ~80% of rows would have NULL UOM_COST. Adding a sparse cost column to a quantity entity is a design smell, requires a version bump on STOCKEVENT, and demands staging changes across both integrations for all UNION ALL branches. INVITEM is the cleaner carrier — it's a dimension entity that already describes the item, and every integration already populates it.

### Why not INVREPORT?
INVREPORT is MarketMan-specific — it consumes `CostByBlendedAverageByReportingUOM` from the MarketMan ActualVsTheo API. No other integration has this concept. Keeping it as the cost source permanently couples the platform to a MarketMan-specific data structure.

### Why a static price is sufficient
Catalogue/BOM prices change infrequently for most inventory items. The existing INVREPORT-based cost was already averaged over a 30-day window, smoothing out any purchase-price variation. A static per-item price gives the same order-of-magnitude accuracy for cost calculations, variance reporting, and GP% metrics. For use cases that need time-varying cost precision (e.g. volatile commodity pricing), a future enhancement could add delivery-based cost via the `INVITEM_STOCKORDER` link satellite (which already carries `PRICE` in the Growyze entity mapping) without modifying STOCKEVENT.

### Future enhancement path: delivery-based cost
If time-varying cost precision is needed later, the `INVITEM_STOCKORDER` link entity already has `PRICE` in the Growyze mapping (not yet deployed). A future Tier 1 PresentationControl step could compute weighted-average delivery cost from `SAT_LNK_INVITEM_STOCKORDER.PRICE` joined to `SAT_STOCKORDER.ORDER_DATE`, and the COALESCE waterfall could become: `COALESCE(delivery_cost, invitem_cost)`. This would not require modifying STOCKEVENT.

### PARTITION BY bug fix
The current InvLocCost CTE has `PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]` (INVITEM_HUB_ID listed twice). This made the "location-specific" and "item-wide" averages identical, rendering the two-level COALESCE meaningless. The new InvItemCost CTE eliminates this entirely — it's a simple per-item lookup with no windowed aggregate.

### UOM Conversion
The `UOMConversion` CTE (hardcoded in PresentationControl) converts costs to base UOM (grams for weight, ml for volume). `SAT_INVITEM.UOM_COST` is in the item's native UOM (stored in `SAT_INVITEM.UOM`). The InvItemCost CTE divides by `conversion_factor` to normalise to per-base-UOM cost — the same pattern as the existing InvLocCost.

---

## Risk Register

| Risk | Mitigation |
|---|---|
| MarketMan cost values change after switch (INVREPORT blended avg vs BOMPrice) | Cross-validate sample in Task 3 Step 4 before full deployment. BOMPrice is last purchase cost — may differ from blended average but is a legitimate cost basis. |
| Growyze DL_PRODUCTS.price is NULL for some products | UOM_COST will be NULL for those items — same as today (currently 100% NULL). Track NULL% and investigate unmapped items. |
| BOMPrice not in DL_INVENTORY_PREPS for all prep items | TRY_CAST handles NULLs gracefully. Prep items without BOMPrice get NULL UOM_COST. |
| Entity version bump requires sp_GenerateDataVaultTables | Standard procedure — adds column to existing SAT_INVITEM via ALTER TABLE. No data loss. |
| INVREPORT entity becomes orphaned | INVREPORT is not retired in this plan — it remains available but unused by the cost path. A future cleanup can retire it after validation period. |
| No location-specific cost variation | Current InvLocCost was already broken (PARTITION BY bug) — location-specific cost was never actually computed. Moving to per-item cost is no regression. Future delivery-based cost via INVITEM_STOCKORDER can restore location-awareness if needed. |
