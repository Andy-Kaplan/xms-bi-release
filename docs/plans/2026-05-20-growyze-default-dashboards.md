# Growyze Default Dashboards — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and deploy Kati's three default Growyze dashboards (Overview, Sales & Profitability, Inventory Control) for Padel Social and Dirty Sixth.

**Architecture:** Three-layer deployment — (1) infra fixes in core MI to unblock Growyze sales data flow, (2) new presentation/visualisation queries on MI for the cards we don't have yet, (3) Report DB configuration (BiConfig + DashboardGrid + VisualisationConfig + DashboardGroup) on the microservice Azure SQL DB to wire the dashboards to the two orgs.

**Tech Stack:** SQL Server Managed Instance (core + per-org client DBs), Azure SQL Database (microservice `report` DB), VisualisationQueries metadata pattern, sp_DeployObjects, MERGE upserts for control tables, MCP for verification.

**Source mockup:** [`ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html`](../../ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html)

---

## JIRA Cross-Reference

### Existing open / in-progress tickets that overlap

| Ticket | Status | Type | Summary | Relevance |
|---|---|---|---|---|
| [XMSE-865](https://threerocks.atlassian.net/browse/XMSE-865) | In Progress | Story | Integrate Growyze API data into Data Vault | Parent feature — this plan extends it from staging into reporting |
| [XMSE-1099](https://threerocks.atlassian.net/browse/XMSE-1099) | More Info Required | Story | InvMargeBrut CustomGroupedDataGrid returns 500 on Growyze orgs | Must close before Sales & Profitability ships — blocks one of the cards |
| [XMSE-1378](https://threerocks.atlassian.net/browse/XMSE-1378) | Open | Bug | SAT_STOCKORDER.DELIVERY_DATE sourced from PO expectedDeliveryDate instead of actual DN deliveryDate | Affects Deliveries KPI accuracy on Overview + Inventory Control |
| [XMSE-1379](https://threerocks.atlassian.net/browse/XMSE-1379) | Open | Bug | Delivery-note attributes (DN number, status, discrepancies, per-line price) not captured in DV | Required for Deliveries (value) KPI fidelity |
| [XMSE-1380](https://threerocks.atlassian.net/browse/XMSE-1380) | Open | Bug | DN Events staging INNER JOIN on barcode silently drops 144 DN lines at Dirty Sixth (2.7%) | Materially distorts Dirty Sixth Deliveries KPI |
| [XMSE-949](https://threerocks.atlassian.net/browse/XMSE-949) | Open | Story | Refactor product cost matching into dedicated presentation table | Less critical here — Growyze has native `totalCost` in DL_DISHES, so does not need cross-integration cost matching |
| [XMSE-1096](https://threerocks.atlassian.net/browse/XMSE-1096) | Done | Story | Verify Dirty 6 dashboards working in UAT | Predecessor verification — these new dashboards replace the previous default pack |
| [XMSE-1059](https://threerocks.atlassian.net/browse/XMSE-1059) | Done | Story | Verify Padel Social data loading in UAT | Same as above |

### Tickets raised as part of this work

All created 2026-05-20 as children of Epic [XMSE-742](https://threerocks.atlassian.net/browse/XMSE-742) (Growyze Data integration), assigned to Andrew Kaplan, priority Major:

| Ticket | Type | Scope |
|---|---|---|
| [XMSE-1402](https://threerocks.atlassian.net/browse/XMSE-1402) (G1) | Bug | Auto-detect IntegrationType filter in F_LINEITEM_15MIN / F_PRODUCT_MARGIN_DAY (P1, Option D). INVENTORY LINEITEM admitted only when org has no `IsEnabled=1` POS integration |
| [XMSE-1403](https://threerocks.atlassian.net/browse/XMSE-1403) (G2) | Bug | Map LINEITEM_TIMESTAMP from sale window OPEN_TIME (P2) |
| [XMSE-1404](https://threerocks.atlassian.net/browse/XMSE-1404) (G3) | Story | Deploy F_PURCHASES_DAY presentation fact (promote scripts 05-07 to release) |
| [XMSE-1405](https://threerocks.atlassian.net/browse/XMSE-1405) (G4) | Story | Umbrella tracking story for the default dashboard pack |
| [XMSE-1406](https://threerocks.atlassian.net/browse/XMSE-1406) (G5) | Story | Assign dashboard pack to Padel Social and Dirty Sixth — Report DB wiring (UAT + Prod) |
| [XMSE-1407](https://threerocks.atlassian.net/browse/XMSE-1407) (G6) | Story | 5 new SingleKPICard datasets: ActiveStocktakes, AvgCostSpend, BestPerformingCategory, HighestVenue, LowestVenue |
| [XMSE-1408](https://threerocks.atlassian.net/browse/XMSE-1408) (G7) | Story | New MenuEngineering CustomDataGrid (quadrant classification in SQL) |
| [XMSE-1409](https://threerocks.atlassian.net/browse/XMSE-1409) (G8) | Story | New OverallMenuProfitability MultiLineChartCard (daily Margin and Cost) |

XMSE-1406 is the final delivery story for the customer-facing change.

---

## File Structure

### MI core release (delta scripts in `releases/v{X.Y}/`)

| File | Responsibility |
|---|---|
| `releases/v{X.Y}/01_g1_p1_filter_autodetect.sql` | REPLACE-and-UPDATE on `core.PresentationControl` for F_LINEITEM_15MIN + F_PRODUCT_MARGIN_DAY query_sql — admits INVENTORY LINEITEM only when org has no enabled POS integration |
| `releases/v{X.Y}/02_g2_lineitem_timestamp_mapping.sql` | MERGE updates to Growyze staging step (GRYZ_LINEITEM in `core.StagingControl`) + entity mapping #9 in `core.int_growyze001.EntityMappings` |
| `releases/v{X.Y}/03_g3_invitem_stockorder_attrs.sql` | Promotes `ClaudeDevelopment/integrations/Growyze/05_invitem_stockorder_entity_fix.sql` |
| `releases/v{X.Y}/04_g3_f_purchases_day_table.sql` | Promotes `ClaudeDevelopment/integrations/Growyze/06_purchases_presentation_table.sql` |
| `releases/v{X.Y}/05_g3_f_purchases_day_build.sql` | Promotes `ClaudeDevelopment/integrations/Growyze/07_purchases_presentation_control.sql` |
| `releases/v{X.Y}/06_g6_new_kpi_vis_queries.sql` | Five new SingleKPICard records via MERGE into `core.VisualisationQueries`: ActiveStocktakes, AvgCostSpend, BestPerformingCategory, HighestVenue, LowestVenue |
| `releases/v{X.Y}/07_g7_menu_engineering_grid.sql` | One new CustomDataGrid record for MenuEngineering |
| `releases/v{X.Y}/08_g8_overall_menu_profitability.sql` | One new MultiLineChartCard record for OverallMenuProfitability |
| `releases/v{X.Y}/DEPLOY_ORDER.txt` | Documented order: 01 → 02 → 03 → 04 → 05 → presentation rebuild → 06 → 07 → 08 |
| `releases/v{X.Y}/RELEASE_NOTES.md` | Customer-facing summary |

### Microservice Report DB scripts

| File | Responsibility |
|---|---|
| `ClaudeDevelopment/microservice-report/02_growyze_default_dashboard_pack_uat.sql` | One idempotent script that, for each of Padel Social and Dirty Sixth: ensures BiConfig row, creates 3 DashboardGrids + child DashboardItems + DashboardFilters, registers VisualisationConfig entries, wires DashboardGroupMapping rows. UAT first. |
| `ClaudeDevelopment/microservice-report/03_growyze_default_dashboard_pack_prod.sql` | Same script body, parameterised for Prod org GUIDs once UAT signs off |
| `ClaudeDevelopment/microservice-report/02_growyze_dashboard_pack_README.md` | Notes on org GUIDs, palette assignment, rollback (delete by DashboardGridId) |

### Updated mockup

| File | Responsibility |
|---|---|
| `ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html` | Already exists — referenced in tickets as the visual spec |

---

## Self-Contained Test Pattern

Each task ends with **MCP verification** instead of unit tests (the MI/Azure SQL pattern). Verification uses three-part naming from `core` (MI) or direct `report` DB connection (Azure SQL). Strip `--` comments before pasting into MCP.

---

## Task 0: JIRA tickets (already raised)

Tickets [XMSE-1402](https://threerocks.atlassian.net/browse/XMSE-1402) through [XMSE-1409](https://threerocks.atlassian.net/browse/XMSE-1409) were created on 2026-05-20 as children of [XMSE-742](https://threerocks.atlassian.net/browse/XMSE-742). See the table above for the G→XMSE mapping. Skip to Task 1.

---

## Task 1: Auto-detect IntegrationType filter (G1 / P1 — Option D)

**Files:**
- Modify (delta): `releases/v{X.Y}/01_g1_p1_filter_autodetect.sql` (create new)
- Reference only: `8_PresentationControl.sql:1258` and `8_PresentationControl.sql:3398`

**Design — auto-detect at build time:**

The presentation build steps run inside each client DB and join across to `core.*` tables. We extend the existing filter so that `INVENTORY`-source LINEITEM rows are admitted **only when this org has no enabled POS integration**. The check is a `NOT EXISTS` against `core.OrganisationIntegrations` joined to `core.Integrations`, scoped to the current DB via `DB_NAME()` → `core.Organisations.DatabaseName`. POS rows always flow through unchanged.

Behaviour matrix:

| Org composition | Result |
|---|---|
| Growyze only (today: Padel Social, Dirty Sixth) | Growyze sales flow into facts |
| Direct POS only (NCRAloha, TROAP, future Bizon/Square) | POS sales flow — no change from today |
| Growyze + active POS | POS sales flow; Growyze LINEITEM contribution auto-suppressed on next presentation rebuild — no manual cutover, no double-count window |

Deferred edge cases (out of scope for G1):
- **Historical preservation** — date-aware suppression (`ORDER_DATE >= POS_first_row_date`) only matters when an org with substantial Growyze history adds a POS. Revisit then.
- **Manual override** — adding `OverrideLineitemContribution NVARCHAR(20) NULL` to `core.OrganisationIntegrations` for `FORCE_ON` / `FORCE_OFF`. Build only when the auto-rule is wrong for a real customer.

- [ ] **Step 1:** Verify current state on UAT

Run via MCP `mcp__xms-bi-uat__query` against `core`:

```sql
SELECT step_name, CASE WHEN query_sql LIKE N'%IG.[IntegrationType] = ''POS''%' THEN 'NARROW' ELSE 'AUTO' END AS filter_state
FROM core.PresentationControl
WHERE step_name IN (N'F_LINEITEM_15MIN', N'F_PRODUCT_MARGIN_DAY')
```

Expected: both rows = `NARROW`. If already `AUTO`, skip to Step 5.

- [ ] **Step 2:** Confirm column names in `core.OrganisationIntegrations`

```sql
SELECT COLUMN_NAME FROM core.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='core' AND TABLE_NAME='OrganisationIntegrations'
  AND COLUMN_NAME IN ('IsEnabled','OrganisationID','IntegrationID')
```

Expected: all three rows present. (The plan SQL below uses `IsEnabled = 1` as the "active" check.)

- [ ] **Step 3:** Write the delta script

Create `releases/v{X.Y}/01_g1_p1_filter_autodetect.sql`:

```sql
-- G1 / P1: auto-detect filter — INVENTORY LINEITEM only flows when org has no enabled POS
-- F_LINEITEM_15MIN + F_PRODUCT_MARGIN_DAY currently exclude all INVENTORY data.
-- Option D: allow INVENTORY through ONLY for orgs with no IsEnabled=1 POS integration.
-- The NOT EXISTS subquery resolves per-org at presentation rebuild — no manual cutover
-- needed when a POS is later added to a Growyze org.
-- See docs/plans/2026-05-20-growyze-default-dashboards.md Task 1

DECLARE @replace_from NVARCHAR(MAX) = N'AND IG.[IntegrationType] = ''POS''';
DECLARE @replace_to   NVARCHAR(MAX) = N'AND (
    IG.[IntegrationType] = ''POS''
    OR (
        IG.[IntegrationType] = ''INVENTORY''
        AND NOT EXISTS (
            SELECT 1
            FROM [core].[core].[OrganisationIntegrations] OI_pos
            INNER JOIN [core].[core].[Integrations] IG_pos
                ON OI_pos.IntegrationID = IG_pos.IntegrationID
            INNER JOIN [core].[core].[Organisations] O_pos
                ON OI_pos.OrganisationID = O_pos.OrganisationID
            WHERE O_pos.DatabaseName = DB_NAME()
              AND IG_pos.IntegrationType = ''POS''
              AND OI_pos.IsEnabled = 1
        )
    )
)';

DECLARE @new_lineitem_sql NVARCHAR(MAX),
        @new_margin_sql   NVARCHAR(MAX);

SELECT @new_lineitem_sql = REPLACE(query_sql, @replace_from, @replace_to)
FROM core.PresentationControl
WHERE step_name = N'F_LINEITEM_15MIN';

SELECT @new_margin_sql = REPLACE(query_sql, @replace_from, @replace_to)
FROM core.PresentationControl
WHERE step_name = N'F_PRODUCT_MARGIN_DAY';

-- Guard: confirm the REPLACE actually matched (the source string must appear exactly once each)
IF @new_lineitem_sql IS NULL OR @new_lineitem_sql NOT LIKE N'%NOT EXISTS%'
BEGIN
    RAISERROR(N'G1 deploy aborted: REPLACE on F_LINEITEM_15MIN did not produce expected output. Inspect manually.', 16, 1);
    RETURN;
END;
IF @new_margin_sql IS NULL OR @new_margin_sql NOT LIKE N'%NOT EXISTS%'
BEGIN
    RAISERROR(N'G1 deploy aborted: REPLACE on F_PRODUCT_MARGIN_DAY did not produce expected output. Inspect manually.', 16, 1);
    RETURN;
END;

UPDATE core.PresentationControl
SET query_sql = @new_lineitem_sql, ModifiedDate = GETDATE()
WHERE step_name = N'F_LINEITEM_15MIN';

UPDATE core.PresentationControl
SET query_sql = @new_margin_sql, ModifiedDate = GETDATE()
WHERE step_name = N'F_PRODUCT_MARGIN_DAY';

PRINT 'G1 / P1 deployed (Option D — auto-detect).';
```

> **Cross-DB naming:** the subquery uses three-part names (`[core].[core].[OrganisationIntegrations]`) because these are stored as text inside `PresentationControl.query_sql` and executed inside each client DB via the framework's dynamic-SQL pattern (`USE [client_db] EXEC(...)`). The cross-DB references must be fully-qualified.

- [ ] **Step 4:** Deploy to UAT via SQL Studio / Azure Data Studio (manual run by developer — Claude does not execute writes)

- [ ] **Step 5:** Trigger presentation rebuild for Padel Social

Run on UAT the platform's presentation rebuild stored procedure for one Growyze org (Padel Social GUID `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`).

- [ ] **Step 6:** Verify Growyze-only org: rows flow

```sql
SELECT COUNT(*) AS growyze_rows
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].presentation.F_LINEITEM_15MIN
WHERE SRC = N'int_growyze001'
```

Expected: > 0 (zero before, non-zero after).

- [ ] **Step 7:** Verify mixed-org behaviour: suppression works

Pick a UAT org that has an enabled POS integration (e.g. Three Rocks Cafe — `20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4`, MarketMan + NCRAloha). Temporarily simulate "Growyze + POS" by inserting a fake `core.OrganisationIntegrations` row linking that org to the Growyze integration with `IsEnabled = 1`, then trigger a presentation rebuild for it and confirm:

```sql
-- Should be > 0 (POS rows still flow)
SELECT COUNT(*) AS pos_rows
FROM [20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4].presentation.F_LINEITEM_15MIN
WHERE SRC = N'int_ncraloha001';

-- Should remain 0 (no Growyze data was actually loaded into this org's SAT_LINEITEM,
-- but even if there were, the auto-detect filter would suppress it)
SELECT COUNT(*) AS growyze_rows
FROM [20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4].presentation.F_LINEITEM_15MIN
WHERE SRC = N'int_growyze001';
```

Better suppression test if you can stage it in a sandbox: directly insert a marker row into the test org's `SAT_LINEITEM` with `SRC = 'int_growyze001'`, run the build step manually, confirm the marker is excluded. After the test, undo the fake OrganisationIntegrations row and the marker row.

- [ ] **Step 8:** Verify the active-POS detection itself

```sql
SELECT
    (SELECT TOP 1 OrganisationID FROM core.Organisations
     WHERE DatabaseName = '20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14') AS padel_org_id,
    -- Should be 0 — Padel Social has no POS
    (SELECT COUNT(*)
     FROM core.OrganisationIntegrations OI
     INNER JOIN core.Integrations IG ON OI.IntegrationID = IG.IntegrationID
     INNER JOIN core.Organisations O  ON OI.OrganisationID = O.OrganisationID
     WHERE O.DatabaseName = '20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14'
       AND IG.IntegrationType = 'POS'
       AND OI.IsEnabled = 1) AS padel_active_pos_count;
```

Expected: `padel_active_pos_count = 0`. (Sanity-check that the auto-detect subquery returns the same answer the build step sees.)

- [ ] **Step 9:** Commit

```bash
git add releases/v{X.Y}/01_g1_p1_filter_autodetect.sql
git commit -m "feat(growyze): auto-detect IntegrationType filter — INVENTORY LINEITEM flows only when no enabled POS (G1/P1, Option D)"
```

---

## Task 2: Map LINEITEM_TIMESTAMP (G2 / P2)

**Files:**
- Create: `releases/v{X.Y}/02_g2_lineitem_timestamp_mapping.sql`
- Reference only: `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql` (GRYZ_LINEITEM step) and `04_entity_mappings.sql` (mapping #9)

- [ ] **Step 1:** Verify current staging produces NULL LINEITEM_TIMESTAMP

```sql
SELECT TOP 5 SRC_KEY, ORDER_DATE, OPEN_TIME
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].stage.GRYZ_LINEITEM
ORDER BY ORDER_DATE DESC
```

Expected: OPEN_TIME is populated (it's the column we're going to alias as LINEITEM_TIMESTAMP).

- [ ] **Step 2:** Write the delta script

The GRYZ_LINEITEM staging already produces OPEN_TIME — the fix is to **add LINEITEM_TIMESTAMP as an alias of OPEN_TIME** in (a) staging output columns + (b) entity mapping. Both records live in `core.StagingControl` and `core.int_growyze001.EntityMappings` respectively.

```sql
-- G2 / P2: map LINEITEM_TIMESTAMP from Growyze sale window OPEN_TIME
-- See docs/plans/2026-05-20-growyze-default-dashboards.md Task 2

-- (a) Update GRYZ_LINEITEM staging step: add LINEITEM_TIMESTAMP to SELECT and staging_columns
-- The SELECT list adds: ", s.sale_from AS LINEITEM_TIMESTAMP" inside the inner SELECT.
-- Use REPLACE rather than full rewrite so we preserve any future edits.
UPDATE core.StagingControl
SET query_sql = REPLACE(
        query_sql,
        N's.sale_from AS OPEN_TIME,',
        N's.sale_from AS OPEN_TIME, s.sale_from AS LINEITEM_TIMESTAMP,'),
    staging_columns = REPLACE(
        staging_columns,
        N'"OPEN_TIME",',
        N'"OPEN_TIME", "LINEITEM_TIMESTAMP",'),
    ModifiedDate = GETDATE()
WHERE staging_table = N'GRYZ_LINEITEM';

-- (b) Update LINEITEM entity mapping #9: add LINEITEM_TIMESTAMP to source_columns + entity_columns
UPDATE core.int_growyze001.EntityMappings
SET source_columns = REPLACE(
        source_columns,
        N'{"name": "TRADING_DATE", "hash": 0}',
        N'{"name": "TRADING_DATE", "hash": 0}, {"name": "LINEITEM_TIMESTAMP", "hash": 0}'),
    entity_columns = REPLACE(
        entity_columns,
        N'"TRADING_DATE"',
        N'"TRADING_DATE", "LINEITEM_TIMESTAMP"'),
    ModifiedDate = GETDATE()
WHERE entity_name = N'LINEITEM' AND source_table = N'GRYZ_LINEITEM';

PRINT 'G2 / P2 deployed.';
```

- [ ] **Step 3:** Deploy to UAT

- [ ] **Step 4:** Re-run staging + DV load + presentation rebuild for Padel Social

- [ ] **Step 5:** Verify LINEITEM_TIMESTAMP populated in F_LINEITEM_15MIN

```sql
SELECT TOP 5 SRC, LINEITEM_TIMESTAMP, ORDER_DATE
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].presentation.F_LINEITEM_15MIN
WHERE SRC = N'int_growyze001' AND LINEITEM_TIMESTAMP IS NOT NULL
ORDER BY LINEITEM_TIMESTAMP DESC
```

Expected: ≥ 1 row with a non-NULL timestamp.

- [ ] **Step 6:** Commit

```bash
git add releases/v{X.Y}/02_g2_lineitem_timestamp_mapping.sql
git commit -m "feat(growyze): map LINEITEM_TIMESTAMP from sale window OPEN_TIME (G2/P2)"
```

---

## Task 3: Promote F_PURCHASES_DAY scripts to release (G3)

**Files:**
- Create: `releases/v{X.Y}/03_g3_invitem_stockorder_attrs.sql` (copy of `ClaudeDevelopment/integrations/Growyze/05_invitem_stockorder_entity_fix.sql`)
- Create: `releases/v{X.Y}/04_g3_f_purchases_day_table.sql` (copy of `ClaudeDevelopment/integrations/Growyze/06_purchases_presentation_table.sql`)
- Create: `releases/v{X.Y}/05_g3_f_purchases_day_build.sql` (copy of `ClaudeDevelopment/integrations/Growyze/07_purchases_presentation_control.sql`)

- [ ] **Step 1:** Review each source script and confirm it follows the upsert pattern (MERGE), not bare INSERT

Open each of scripts 05/06/07 in `ClaudeDevelopment/integrations/Growyze/`. Confirm:
- Each `INSERT INTO core.DataVaultEntities` / `core.PresentationTables` / `core.PresentationControl` uses `MERGE` keyed on the table's natural key.
- No hardcoded client DB names.

- [ ] **Step 2:** Copy scripts to the release folder

```bash
cp "ClaudeDevelopment/integrations/Growyze/05_invitem_stockorder_entity_fix.sql" "releases/v{X.Y}/03_g3_invitem_stockorder_attrs.sql"
cp "ClaudeDevelopment/integrations/Growyze/06_purchases_presentation_table.sql"  "releases/v{X.Y}/04_g3_f_purchases_day_table.sql"
cp "ClaudeDevelopment/integrations/Growyze/07_purchases_presentation_control.sql" "releases/v{X.Y}/05_g3_f_purchases_day_build.sql"
```

- [ ] **Step 3:** Deploy 03 → 04 → 05 to UAT, then re-run DV load + presentation rebuild for one Growyze org

- [ ] **Step 4:** Verify F_PURCHASES_DAY populated for Padel Social

```sql
SELECT TOP 5 BUSINESS_DATE, LOCATION_HUB_ID, INVITEM_HUB_ID, DELIVERY_VALUE
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].presentation.F_PURCHASES_DAY
ORDER BY BUSINESS_DATE DESC
```

Expected: ≥ 1 row.

- [ ] **Step 5:** Note for follow-up

The Deliveries KPI accuracy depends on bugs [XMSE-1378](https://threerocks.atlassian.net/browse/XMSE-1378), [XMSE-1379](https://threerocks.atlassian.net/browse/XMSE-1379), [XMSE-1380](https://threerocks.atlassian.net/browse/XMSE-1380). These are **not blockers** for the dashboard ship — the KPI will display, just with known data-quality caveats. Reference these tickets in G5 release notes.

- [ ] **Step 6:** Commit

```bash
git add releases/v{X.Y}/03_g3_invitem_stockorder_attrs.sql releases/v{X.Y}/04_g3_f_purchases_day_table.sql releases/v{X.Y}/05_g3_f_purchases_day_build.sql
git commit -m "feat(growyze): deploy F_PURCHASES_DAY fact (G3/P3/P4)"
```

---

## Task 4: New KPI vis queries (G6) — 5 SingleKPICards

**Files:**
- Create: `releases/v{X.Y}/06_g6_new_kpi_vis_queries.sql`

Schema reminder: SingleKPICard supports columns `Title, Description, Trend, Chip, Value`. `Description` rendering is verified (used by `BkgTotalCovers`, `BkgPeakMonth`). `Trend` and `Chip` rendering is **schema-only, never populated in prod** — we will populate them and observe behaviour during UAT verification of G5 (acceptable per user instruction).

- [ ] **Step 1:** Write all 5 vis query MERGE records in one script

Create `releases/v{X.Y}/06_g6_new_kpi_vis_queries.sql`. Each block uses MERGE on `(DataSetName, VisualizationType)`. Filter clause `@FilterClause` is injected by the card SP.

```sql
-- G6: five new SingleKPICard datasets for the Growyze default dashboards
-- See docs/plans/2026-05-20-growyze-default-dashboards.md Task 4

-- 1. ActiveStocktakes: "X / Y venues counted (PP%)"
MERGE INTO core.VisualisationQueries AS tgt
USING (VALUES (N'ActiveStocktakes', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'WITH counted AS (
    SELECT COUNT(DISTINCT FC.LOCATION_HUB_ID) AS venues_with_stocktake
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1 @FilterClause
),
total AS (
    SELECT COUNT(*) AS total_venues
    FROM [presentation].[D_LOCATION]
    WHERE BOTTOM_LEVEL = 1
)
SELECT
    N''Active stocktakes'' AS Title,
    N''venues counted'' AS Description,
    CASE WHEN total_venues = 0 THEN NULL
         ELSE FORMAT(CAST(venues_with_stocktake AS DECIMAL(9,2)) / total_venues, ''P0'')
    END AS Trend,
    NULL AS Chip,
    CONCAT(venues_with_stocktake, N'' / '', total_venues) AS Value
FROM counted CROSS JOIN total;',
    Status = N'LIVE',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, CreatedDate, CreatedBy)
VALUES (N'ActiveStocktakes', N'SingleKPICard', 1, N'LIVE',
    N'-- see WHEN MATCHED branch above; same QueryTemplate', GETDATE(), N'plan-2026-05-20');

-- 2. AvgCostSpend: SUM(QUANTITY * NET_COST) / SUM(QUANTITY)
MERGE INTO core.VisualisationQueries AS tgt
USING (VALUES (N'AvgCostSpend', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    N''Avg Cost Spend'' AS Title,
    N''per item sold'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    FORMAT(
        SUM(CAST(F.QUANTITY AS DECIMAL(18,4)) * ISNULL(p.BOTTOM_NET_COST, 0))
        / NULLIF(SUM(F.QUANTITY), 0), ''N2'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] p ON F.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE F.LI_TYPE = ''PROD'' AND 1=1 @FilterClause;',
    Status = N'LIVE',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, CreatedDate, CreatedBy)
VALUES (N'AvgCostSpend', N'SingleKPICard', 1, N'LIVE',
    N'-- see WHEN MATCHED branch above', GETDATE(), N'plan-2026-05-20');

-- 3. BestPerformingCategory: TOP 1 category by GP%
MERGE INTO core.VisualisationQueries AS tgt
USING (VALUES (N'BestPerformingCategory', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT TOP 1
    N''Best Performing Category'' AS Title,
    CONCAT(N''GP% '', FORMAT(gp_pct, ''N1''), N''%'') AS Description,
    NULL AS Trend,
    NULL AS Chip,
    category_name AS Value
FROM (
    SELECT
        COALESCE(p.MIDDLE_1_MICROSERVICE_NAME, p.MIDDLE_1_PRODUCT_NAME) AS category_name,
        CASE WHEN SUM(F.NET_VALUE) = 0 THEN 0
             ELSE 100.0 * (SUM(F.NET_VALUE) - SUM(F.QUANTITY * ISNULL(p.BOTTOM_NET_COST, 0)))
                  / SUM(F.NET_VALUE)
        END AS gp_pct
    FROM [presentation].[F_LINEITEM_15MIN] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] p ON F.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE F.LI_TYPE = ''PROD'' AND 1=1 @FilterClause
    GROUP BY COALESCE(p.MIDDLE_1_MICROSERVICE_NAME, p.MIDDLE_1_PRODUCT_NAME)
) x
WHERE category_name IS NOT NULL
ORDER BY gp_pct DESC;',
    Status = N'LIVE',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, CreatedDate, CreatedBy)
VALUES (N'BestPerformingCategory', N'SingleKPICard', 1, N'LIVE',
    N'-- see WHEN MATCHED branch above', GETDATE(), N'plan-2026-05-20');

-- 4. HighestVenue: TOP 1 venue by stock value
MERGE INTO core.VisualisationQueries AS tgt
USING (VALUES (N'HighestVenue', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT TOP 1
    N''Highest Venue'' AS Title,
    FORMAT(SUM(FC.[ON_HAND_VALUE]), ''N0'') AS Description,
    NULL AS Trend,
    NULL AS Chip,
    COALESCE(location.BOTTOM_MICROSERVICE_NAME, location.BOTTOM_LOCATION_NAME) AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1 @FilterClause
GROUP BY COALESCE(location.BOTTOM_MICROSERVICE_NAME, location.BOTTOM_LOCATION_NAME)
ORDER BY SUM(FC.[ON_HAND_VALUE]) DESC;',
    Status = N'LIVE',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, CreatedDate, CreatedBy)
VALUES (N'HighestVenue', N'SingleKPICard', 1, N'LIVE',
    N'-- see WHEN MATCHED branch above', GETDATE(), N'plan-2026-05-20');

-- 5. LowestVenue: BOTTOM 1 venue by stock value
MERGE INTO core.VisualisationQueries AS tgt
USING (VALUES (N'LowestVenue', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT TOP 1
    N''Lowest Venue'' AS Title,
    FORMAT(SUM(FC.[ON_HAND_VALUE]), ''N0'') AS Description,
    NULL AS Trend,
    NULL AS Chip,
    COALESCE(location.BOTTOM_MICROSERVICE_NAME, location.BOTTOM_LOCATION_NAME) AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1 @FilterClause
GROUP BY COALESCE(location.BOTTOM_MICROSERVICE_NAME, location.BOTTOM_LOCATION_NAME)
ORDER BY SUM(FC.[ON_HAND_VALUE]) ASC;',
    Status = N'LIVE',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, CreatedDate, CreatedBy)
VALUES (N'LowestVenue', N'SingleKPICard', 1, N'LIVE',
    N'-- see WHEN MATCHED branch above', GETDATE(), N'plan-2026-05-20');

PRINT 'G6: 5 new SingleKPICard datasets deployed.';
```

> **Note:** the `WHEN NOT MATCHED` branches reference `'-- see WHEN MATCHED branch above'` as a placeholder. **Before deploying**, replace each placeholder with the actual QueryTemplate string from its matching `WHEN MATCHED` branch. (Done this way to keep the plan readable — the engineer must do the substitution.)

- [ ] **Step 2:** Deploy to UAT

- [ ] **Step 3:** Test each query template via MCP (strip comments, replace `@FilterClause` with empty string, prefix tables with Padel Social DB GUID, drop the second-result-set header query if applicable)

Example for ActiveStocktakes:

```sql
WITH counted AS (
    SELECT COUNT(DISTINCT FC.LOCATION_HUB_ID) AS venues_with_stocktake
    FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
),
total AS (
    SELECT COUNT(*) AS total_venues
    FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_LOCATION]
    WHERE BOTTOM_LEVEL = 1
)
SELECT
    N'Active stocktakes' AS Title,
    N'venues counted' AS Description,
    CASE WHEN total_venues = 0 THEN NULL
         ELSE FORMAT(CAST(venues_with_stocktake AS DECIMAL(9,2)) / total_venues, 'P0')
    END AS Trend,
    NULL AS Chip,
    CONCAT(venues_with_stocktake, N' / ', total_venues) AS Value
FROM counted CROSS JOIN total;
```

Expected: exactly one row, Title = 'Active stocktakes', Description = 'venues counted', Trend like `'78%'`, Value like `'7 / 9'`.

Repeat for the other 4 datasets, adjusting filter scope. All must return ≥ 1 row.

- [ ] **Step 4:** Commit

```bash
git add releases/v{X.Y}/06_g6_new_kpi_vis_queries.sql
git commit -m "feat(growyze): add 5 SingleKPICard datasets for default dashboard pack (G6)"
```

---

## Task 5: Menu Engineering Quadrant grid (G7)

**Files:**
- Create: `releases/v{X.Y}/07_g7_menu_engineering_grid.sql`

Ship as CustomDataGrid with a quadrant classification column. True ScatterChartCard is out of scope for this plan.

- [ ] **Step 1:** Write the MERGE record

```sql
-- G7: MenuEngineering CustomDataGrid — BCG matrix classification per product
-- See docs/plans/2026-05-20-growyze-default-dashboards.md Task 5

MERGE INTO core.VisualisationQueries AS tgt
USING (VALUES (N'MenuEngineering', N'CustomDataGrid')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'WITH product_perf AS (
    SELECT
        COALESCE(p.BOTTOM_MICROSERVICE_NAME, p.BOTTOM_PRODUCT_NAME) AS Product,
        COALESCE(p.MIDDLE_1_MICROSERVICE_NAME, p.MIDDLE_1_PRODUCT_NAME) AS Category,
        SUM(F.QUANTITY) AS QtySold,
        SUM(F.NET_VALUE) AS Revenue,
        SUM(F.QUANTITY * ISNULL(p.BOTTOM_NET_COST, 0)) AS Cost,
        CASE WHEN SUM(F.NET_VALUE) = 0 THEN 0
             ELSE 100.0 * (SUM(F.NET_VALUE) - SUM(F.QUANTITY * ISNULL(p.BOTTOM_NET_COST, 0)))
                  / SUM(F.NET_VALUE)
        END AS GPpct
    FROM [presentation].[F_LINEITEM_15MIN] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] p ON F.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE F.LI_TYPE = ''PROD'' AND 1=1 @FilterClause
    GROUP BY COALESCE(p.BOTTOM_MICROSERVICE_NAME, p.BOTTOM_PRODUCT_NAME),
             COALESCE(p.MIDDLE_1_MICROSERVICE_NAME, p.MIDDLE_1_PRODUCT_NAME)
),
medians AS (
    SELECT
        (SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY QtySold) OVER () FROM product_perf) AS med_qty,
        (SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY GPpct)   OVER () FROM product_perf) AS med_gp
)
SELECT
    pp.Product,
    pp.Category,
    pp.QtySold,
    FORMAT(pp.Revenue, ''N2'') AS Revenue,
    FORMAT(pp.GPpct,   ''N1'') AS GPpct,
    CASE
        WHEN pp.QtySold >= m.med_qty AND pp.GPpct >= m.med_gp THEN N''STAR''
        WHEN pp.QtySold <  m.med_qty AND pp.GPpct >= m.med_gp THEN N''PUZZLE''
        WHEN pp.QtySold >= m.med_qty AND pp.GPpct <  m.med_gp THEN N''WORKHORSE''
        ELSE N''DOG''
    END AS Quadrant
FROM product_perf pp CROSS JOIN medians m
ORDER BY pp.Revenue DESC;',
    Status = N'LIVE',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, CreatedDate, CreatedBy)
VALUES (N'MenuEngineering', N'CustomDataGrid', 1, N'LIVE',
    N'-- see WHEN MATCHED branch above', GETDATE(), N'plan-2026-05-20');

PRINT 'G7: MenuEngineering CustomDataGrid deployed.';
```

> **Same engineer note as Task 4:** before deploying, copy the QueryTemplate from `WHEN MATCHED` into `WHEN NOT MATCHED`.

- [ ] **Step 2:** MCP test (Padel Social)

Strip comments, prefix tables with the org DB GUID, replace `@FilterClause` with empty string. Expected: ≥ 5 rows, each with a Quadrant value in {STAR, PUZZLE, WORKHORSE, DOG}.

- [ ] **Step 3:** Commit

```bash
git add releases/v{X.Y}/07_g7_menu_engineering_grid.sql
git commit -m "feat(growyze): add MenuEngineering quadrant grid dataset (G7)"
```

---

## Task 6: Overall Menu Profitability (G8)

**Files:**
- Create: `releases/v{X.Y}/08_g8_overall_menu_profitability.sql`

Two-series daily line chart: Margin and Cost. Discount series omitted (Growyze does not break out per-line discounts) — discussed honestly in customer-facing release notes.

- [ ] **Step 1:** Write the MERGE record

```sql
-- G8: OverallMenuProfitability MultiLineChartCard — daily Margin and Cost
-- See docs/plans/2026-05-20-growyze-default-dashboards.md Task 6

MERGE INTO core.VisualisationQueries AS tgt
USING (VALUES (N'OverallMenuProfitability', N'MultiLineChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    CAST(F.[ORDER_DATE] AS DATE) AS [Date],
    SUM(F.NET_VALUE - F.QUANTITY * ISNULL(p.BOTTOM_NET_COST, 0)) AS Margin,
    SUM(F.QUANTITY * ISNULL(p.BOTTOM_NET_COST, 0)) AS Cost
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] p ON F.PRODUCT_HUB_ID = p.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE F.LI_TYPE = ''PROD'' AND 1=1 @FilterClause
GROUP BY CAST(F.[ORDER_DATE] AS DATE)
ORDER BY [Date];',
    Status = N'LIVE',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, CreatedDate, CreatedBy)
VALUES (N'OverallMenuProfitability', N'MultiLineChartCard', 1, N'LIVE',
    N'-- see WHEN MATCHED branch above', GETDATE(), N'plan-2026-05-20');

PRINT 'G8: OverallMenuProfitability MultiLineChartCard deployed.';
```

- [ ] **Step 2:** MCP test for Padel Social — expect ≥ 7 rows (one week of dates).

- [ ] **Step 3:** Commit

```bash
git add releases/v{X.Y}/08_g8_overall_menu_profitability.sql
git commit -m "feat(growyze): add OverallMenuProfitability line chart dataset (G8)"
```

---

## Task 7: Fix InvMargeBrut 500 error on Growyze (XMSE-1099)

**Files:** investigation only — actual fix file path determined by root cause.

- [ ] **Step 1:** Reproduce the 500 error

In UAT, run the InvMargeBrut CustomGroupedDataGrid card SP for Padel Social and capture the SQL error. Likely culprits: missing recipe data → NULL division, missing dimension column, or a join that assumes POS schema.

- [ ] **Step 2:** Fetch the QueryTemplate via MCP

```sql
SELECT QueryTemplate FROM core.core.VisualisationQueries
WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid' AND Status = N'LIVE';
```

- [ ] **Step 3:** Run the template against Padel Social DB with comments stripped + `@FilterClause` = empty + three-part naming

Identify the failing expression.

- [ ] **Step 4:** Create a delta script `releases/v{X.Y}/09_xmse_1099_invmargebrut_fix.sql` using MERGE on `(DataSetName, VisualizationType)`. Patch the failing expression.

- [ ] **Step 5:** Verify the patched query returns rows for Padel Social.

- [ ] **Step 6:** Move XMSE-1099 from "More Information Required" → "Resolved" with a comment linking this commit.

- [ ] **Step 7:** Commit

```bash
git add releases/v{X.Y}/09_xmse_1099_invmargebrut_fix.sql
git commit -m "fix(growyze): repair InvMargeBrut for Growyze orgs (XMSE-1099)"
```

---

## Task 8: Report DB dashboard wiring for UAT (G5 — Padel Social + Dirty Sixth)

**Files:**
- Create: `ClaudeDevelopment/microservice-report/02_growyze_default_dashboard_pack_uat.sql`
- Create: `ClaudeDevelopment/microservice-report/02_growyze_dashboard_pack_README.md`

Target UAT report DB: `xms-mssql-ne-uat`, database `report`. MCP: `mcp__microservice-uat__*`. Reference existing pattern: `ClaudeDevelopment/Deploy/growyze_report_db_dev.sql` (uses the same table set).

**Orgs and target DB GUIDs (UAT):**
- Padel Social (OrgID 10) — `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`
- Dirty Sixth (OrgID 18) — `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A`

**Dashboard structure (per org, 3 dashboards):**

| Dashboard | Filters | Card count |
|---|---|---|
| Overview | Period, Venue, Category | 7 KPIs + 1 MultiLineChartCard + 4 category callout KPIs |
| Sales & Profitability | Period, Venue, Category | 6 KPIs + 5 KPI strip (Menu Item Highlights) + 1 PieChartCard + 1 CustomDataGrid + 1 MultiLineChartCard (G8) + 1 CustomDataGrid (G7) + 1 HeatmapCard |
| Inventory Control | Period, Venue, Category | 4 KPIs + 1 StackedBarChartCard + 1 KPI cluster (4 cards) + 2 CustomGroupedDataGrids + 1 CustomDataGrid |

Reference [`ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html`](../../ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html) for exact card placement.

- [ ] **Step 1:** Read the existing `growyze_report_db_dev.sql` to confirm the row patterns

Open the file. For each table — `BiConfig`, `DashboardGrid`, `DashboardItem`, `DashboardFilter`, `VisualisationConfig`, `OrganisationDashboardConfig`, `DashboardGroupMapping` — note:
- Use `OUTPUT inserted.{PK} INTO @var` for grid IDs needed by child rows.
- Never specify `{Table}Id` PKs (`NEWSEQUENTIALID()`).
- `IsDeleted = 0` mandatory.
- `TransactionId` is IDENTITY — never include.

- [ ] **Step 2:** Write the UAT script

Skeleton (full body is ~600 lines — produce in one file, idempotent via NOT EXISTS guards):

```sql
-- G5: Growyze default dashboard pack — UAT (Padel Social + Dirty Sixth)
-- See docs/plans/2026-05-20-growyze-default-dashboards.md Task 8

DECLARE @PadelSocialOrg uniqueidentifier = '94A4B719-EB0F-421F-AD03-ABECDD888B14';
DECLARE @DirtySixthOrg  uniqueidentifier = '7B50D717-124C-4902-ADD2-439A9310326A';

-- Per-org loop variable
DECLARE @CurrentOrg uniqueidentifier;
DECLARE @CurrentDB  nvarchar(200);

DECLARE orgs CURSOR FOR
SELECT v.OrgGuid, v.OrgDB FROM (VALUES
    (@PadelSocialOrg, N'20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14'),
    (@DirtySixthOrg,  N'20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A')
) v(OrgGuid, OrgDB);

OPEN orgs;
FETCH NEXT FROM orgs INTO @CurrentOrg, @CurrentDB;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- 2a. BiConfig (idempotent)
    IF NOT EXISTS (SELECT 1 FROM dbo.BiConfig WHERE OrganisationId = @CurrentOrg)
    BEGIN
        INSERT INTO dbo.BiConfig (OrganisationId, DatabaseName, IsDeleted)
        VALUES (@CurrentOrg, @CurrentDB, 0);
    END;

    -- 2b. Overview dashboard
    DECLARE @OverviewGridId uniqueidentifier;
    IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGrid WHERE OrganisationId = @CurrentOrg AND Name = N'Overview')
    BEGIN
        INSERT INTO dbo.DashboardGrid (OrganisationId, Name, IsDeleted)
        OUTPUT inserted.DashboardGridId INTO (DECLARE @t TABLE (id uniqueidentifier))
        VALUES (@CurrentOrg, N'Overview', 0);
        SET @OverviewGridId = (SELECT TOP 1 id FROM @t);
    END
    ELSE
        SELECT @OverviewGridId = DashboardGridId FROM dbo.DashboardGrid
        WHERE OrganisationId = @CurrentOrg AND Name = N'Overview';

    -- 2c. Overview DashboardItems (cards) — one row per card with X/Y/W/H from the mockup
    -- ... [full block: 12 cards × ~7 columns]

    -- 2d. Overview DashboardFilters (Period, Venue, Category)
    -- ...

    -- 2e. VisualisationConfig (enable each card's dataset for this org)
    -- ...

    -- 2f. OrganisationDashboardConfig (link org → grid)
    -- ...

    -- 2g. DashboardGroupMapping (CRITICAL — front-end navigates via DashboardGroup_Load)
    -- ...

    -- Repeat 2b-2g for "Sales & Profitability" and "Inventory Control"

    FETCH NEXT FROM orgs INTO @CurrentOrg, @CurrentDB;
END;

CLOSE orgs; DEALLOCATE orgs;

PRINT 'G5 UAT: Growyze default dashboard pack assigned to Padel Social + Dirty Sixth.';
```

> The skeleton omits the per-card detail because each card row needs its concrete (X, Y, Width, Height, CardType, VisualisationId) tuple — assemble these from the mockup. Use OUTPUT clauses to capture each GridId, then insert children referencing those IDs. The reference file `growyze_report_db_dev.sql` shows the exact column lists in use.

- [ ] **Step 3:** Write the README

`ClaudeDevelopment/microservice-report/02_growyze_dashboard_pack_README.md`:

```markdown
# Growyze Default Dashboard Pack — UAT Deployment

## Targets
- Padel Social (OrgID 10) — `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`
- Dirty Sixth (OrgID 18) — `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A`

## Prerequisites (all must be deployed first)
1. Release `v{X.Y}` scripts 01–08 deployed to UAT MI core (G1, G2, G3, G6, G7, G8)
2. Presentation rebuild executed for both orgs
3. (Optional) XMSE-1099 patch deployed via release script 09 — required if Sales & Profitability includes InvMargeBrut

## Idempotency
NOT EXISTS guards on `BiConfig`, `DashboardGrid` (by Name + OrganisationId), `DashboardGroupMapping`. Safe to re-run.

## Rollback
DELETE child rows first (DashboardItem, DashboardFilter, VisualisationConfig, OrganisationDashboardConfig, DashboardGroupMapping) by the captured DashboardGridId, then DELETE the grid. Do not soft-delete via `IsDeleted = 1` — leaves orphan rows in `DashboardGroup_Load`.
```

- [ ] **Step 4:** Test on UAT — connect to `report` DB on `xms-mssql-ne-uat`, run the script in a transaction first (`BEGIN TRAN ... ROLLBACK`) to confirm row counts before committing.

- [ ] **Step 5:** Verify via MCP

```sql
SELECT g.Name AS Dashboard, COUNT(i.DashboardItemId) AS Cards
FROM dbo.DashboardGrid g
LEFT JOIN dbo.DashboardItem i ON g.DashboardGridId = i.DashboardGridId AND i.IsDeleted = 0
WHERE g.OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14', '7B50D717-124C-4902-ADD2-439A9310326A')
  AND g.IsDeleted = 0
GROUP BY g.OrganisationId, g.Name
ORDER BY g.OrganisationId, g.Name;
```

Expected: 6 rows (2 orgs × 3 dashboards), each with the card count matching the structure table above.

- [ ] **Step 6:** Verify `DashboardGroup_Load` exposes the new dashboards for each org — confirm the front end can navigate to them.

- [ ] **Step 7:** Open both dashboards in the UAT BI front end as a Padel Social / Dirty Sixth user. Screenshot each. Compare to the mockup.

- [ ] **Step 8:** **Verify SingleKPICard Trend slot rendering** (per user direction — observe behaviour when populated)

For ActiveStocktakes (Trend = `'78%'`), HighestVenue (Trend = `'44,000'`), etc., confirm in the UI:
- Does the front end render Trend as a coloured pill / arrow / sparkline?
- Or does it ignore the column?
- Or render it inline alongside Description?

Document the actual behaviour in `02_growyze_dashboard_pack_README.md` and screenshot.

- [ ] **Step 9:** Commit

```bash
git add ClaudeDevelopment/microservice-report/02_growyze_default_dashboard_pack_uat.sql ClaudeDevelopment/microservice-report/02_growyze_dashboard_pack_README.md
git commit -m "feat(growyze): UAT default dashboard pack for Padel Social + Dirty Sixth (G5)"
```

---

## Task 9: Sign-off + Prod cutover

**Files:**
- Create: `ClaudeDevelopment/microservice-report/03_growyze_default_dashboard_pack_prod.sql`

- [ ] **Step 1:** Demo UAT dashboards to Kati. Capture feedback. Address blocking changes via small follow-up commits before promoting.

- [ ] **Step 2:** Copy UAT script to Prod variant, swap UAT org GUIDs for Prod GUIDs (look up in Prod report DB `BiConfig` if different from UAT).

- [ ] **Step 3:** Deploy MI release `v{X.Y}` to Prod first (per release-guide.md environment progression).

- [ ] **Step 4:** Trigger presentation rebuild for Padel Social + Dirty Sixth on Prod.

- [ ] **Step 5:** Deploy Report DB Prod script.

- [ ] **Step 6:** Smoke-test the dashboards live as a Padel Social / Dirty Sixth user.

- [ ] **Step 7:** Update QUERY_STATUS.md entries for promoted scripts to "deployed".

- [ ] **Step 8:** Move XMSE-1402, 1403, 1404, 1405, 1406, 1407, 1408, 1409 to "Done". Add a comment to XMSE-865 and XMSE-742 noting the dashboard pack ship.

- [ ] **Step 9:** Commit

```bash
git add ClaudeDevelopment/microservice-report/03_growyze_default_dashboard_pack_prod.sql ClaudeDevelopment/QUERY_STATUS.md
git commit -m "feat(growyze): promote default dashboard pack to Prod (Padel Social + Dirty Sixth)"
```

---

## Out of Scope (deferred)

| Item | Why deferred |
|---|---|
| Ingredient Based Sales panel (Tuesday usage breakdown, supplier-pack conversion) | Needs Growyze recipe ingest (RECIPE_PRODUCT mapping) + new Tier-2 presentation table + 5 vis queries. Scope separately with Kati once recipe data quality is confirmed. |
| True ScatterChartCard for Menu Engineering Quadrant | New front-end card type. G7 ships a grid; revisit if Kati's stakeholders push for visual quadrant. |
| Discounts series on Overall Menu Profitability | Growyze does not break out per-line discount detail. Raise with Growyze if customers want it; could derive from `(gross − net)` at order header if good-enough. |
| "Fastest Growing Item" KPI (in Menu Item Highlights) | Needs prior-period item-level comparison. Add as G6.6 follow-up. |
| Bug fixes for Deliveries data quality ([XMSE-1378](https://threerocks.atlassian.net/browse/XMSE-1378), [XMSE-1379](https://threerocks.atlassian.net/browse/XMSE-1379), [XMSE-1380](https://threerocks.atlassian.net/browse/XMSE-1380)) | Independent bug fixes — keep moving on existing tickets. Dashboard will display Deliveries with known caveats meanwhile. |
| Apply Growyze palette to dashboards | `growyze_org_palette.sql` exists but undeployed; consider as part of Task 8 if visual consistency matters at ship. |

---

## Deployment Order Summary

```
MI core (UAT first, then Prod):
  01 (G1)  → 02 (G2)  → 03 (G3) → 04 (G3) → 05 (G3) →
  [presentation rebuild for both orgs] →
  06 (G6)  → 07 (G7)  → 08 (G8)  → 09 (XMSE-1099 fix, if available)

Report DB (UAT first, then Prod):
  02_growyze_default_dashboard_pack_uat.sql
  → screenshot + sign-off →
  03_growyze_default_dashboard_pack_prod.sql
```

## Verification Checklist

Final acceptance — must all be true before closing G5:

- [ ] Padel Social user sees Overview / Sales & Profitability / Inventory Control as default dashboards in the BI front end
- [ ] Dirty Sixth user sees the same three dashboards
- [ ] Every card on each dashboard renders without error (no 500s, no empty-state)
- [ ] KPI values reconcile sample-check against Growyze portal (totals match within rounding)
- [ ] SingleKPICard Trend slot rendering is documented in the README
- [ ] XMSE-1402, 1403, 1404, 1405, 1406, 1407, 1408, 1409 all closed; XMSE-1099 either resolved or explicitly deferred
- [ ] Release notes ship with caveats: Deliveries data quality (XMSE-1378/1379/1380), discount series omitted, time-bucketing reflects sale window
