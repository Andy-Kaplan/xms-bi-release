# Marge Brut Live Dashboard — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Marge Brut mock (literal-`VALUES`) with a live F&B cost-of-sales dashboard on a new dedicated UAT org fed by Mews turnover + Growyze inventory.

**Architecture:** Both feeds land in one client DB → one Data Vault → one presentation layer. A new monthly presentation fact `F_MARGEBRUT_MONTH` (group × month) is the single computed source; the 9 `MargeBrut*` vis queries become thin reads. Product/inventory grouping uses the `MICROSERVICE_NAME` MDM column on **both** `SAT_PRODUCT` (Mews turnover) and `SAT_INVITEM` (Growyze stock), aligned to 6 shared group strings.

**Tech Stack:** SQL Server Managed Instance (T-SQL), Data Vault 2.0, config-driven presentation (`PresentationTables`/`PresentationControl`), `core.core.VisualisationQueries`, Azure SQL `report` DB, PowerShell `Invoke-Sqlcmd` runners.

**Spec:** `docs/superpowers/specs/2026-07-10-marge-brut-live-design.md`

## Global Constraints

- Claude edits/creates `.sql` **only** under `ClaudeDevelopment/`. New live scripts go in `ClaudeDevelopment/integrations/MargeBrut/live/`. The mock scripts (`../02`, `../03`, etc.) are left untouched.
- MCP is **read-only** (`SELECT`/`WITH` only). All shape-testing this session runs via MCP against **proxy orgs** using three-part naming; the target UAT org does not exist yet.
- All state-changing SQL is executed by the developer via **PowerShell runners** (`-WhatIf` preflight, typed confirm, `-StartAt` resume, per-run log), never by Claude and never in SSMS by hand. Ref: `docs/release-guide.md` §6.
- Control-table writes use **MERGE upsert** on the natural key (never bare INSERT). GUID `id` columns: hex only, prefer `DEFAULT NEWID()`.
- `MICROSERVICE_NAME` is **manual-only** MDM — no staging/pipeline ever writes it. The grouping script (Task 5) is its sole writer.
- ClaudeDevelopment scripts use **unqualified two-part** table names (no hardcoded client DB). Three-part naming is for MCP test runs only.
- 6 group strings (exact, verbatim everywhere): `Food` · `Breakfast` · `Wines` · `Bottled Beer` · `Soft Drinks` · `Spirit`.
- BarChartCard `TotalValue`/`BarValue` must be **numeric or NULL** (mock gotcha). KPI `Value` and pie `PiePrimaryText` are display strings.
- Proxy orgs for shape-testing: Mews = DEV org 19 `20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43`; Growyze = UAT Padel Social `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`.
- Update `ClaudeDevelopment/QUERY_STATUS.md` for every new script; update `docs/outstanding/O8-*.md` progress log as tasks land.

---

## Phase A — Buildable now (author + MCP shape-test; developer executes later)

These do not depend on the fetcher gate. Each is authored, shape-tested against a proxy org, and committed. Live execution against the new org happens in Phase B step "go-live", after the Growyze feed lands.

### Task 1: `F_MARGEBRUT_MONTH` presentation table

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/10_f_margebrut_month_table.sql`

**Interfaces:**
- Produces: presentation table `presentation.F_MARGEBRUT_MONTH` with columns
  `GROUP_NAME NVARCHAR(50)`, `PERIOD_MONTH DATE`, `TURNOVER_INCL DECIMAL(18,2)`, `TURNOVER_EXCL DECIMAL(18,2)`, `OPENING DECIMAL(18,2)`, `PURCHASES DECIMAL(18,2)`, `REV_PROV DECIMAL(18,2)`, `NEW_PROV DECIMAL(18,2)`, `ALL_STOCK DECIMAL(18,2)`, `CLOSING DECIMAL(18,2)`, `STAFF_MEAL DECIMAL(18,2)`, `COMP DECIMAL(18,2)`, `CONSUMPTION DECIMAL(18,2)`, `COST_PCT DECIMAL(9,4)`, `GP_PCT DECIMAL(9,4)`.
- Consumed by: Task 4 (build step writes it), Task 7 (vis queries read it).

- [ ] **Step 1: Write the DDL registration script.** MERGE-upsert the DDL string into `core.core.PresentationTables` on its natural key (`TableName`), matching the pattern of an existing entry (read `8_PresentationTables.sql` for the exact column set — `TableName`, `SchemaName`, `CreationScript`, tier/order columns). The `CreationScript` creates `presentation.F_MARGEBRUT_MONTH` with the columns above, PK `(GROUP_NAME, PERIOD_MONTH)`.

```sql
-- 10_f_margebrut_month_table.sql
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'F_MARGEBRUT_MONTH', N'presentation')) AS src (TableName, SchemaName)
ON tgt.TableName = src.TableName
WHEN MATCHED THEN UPDATE SET
    CreationScript = N'CREATE TABLE [presentation].[F_MARGEBRUT_MONTH](
        [GROUP_NAME] NVARCHAR(50) NOT NULL,
        [PERIOD_MONTH] DATE NOT NULL,
        [TURNOVER_INCL] DECIMAL(18,2) NULL, [TURNOVER_EXCL] DECIMAL(18,2) NULL,
        [OPENING] DECIMAL(18,2) NULL, [PURCHASES] DECIMAL(18,2) NULL,
        [REV_PROV] DECIMAL(18,2) NULL, [NEW_PROV] DECIMAL(18,2) NULL,
        [ALL_STOCK] DECIMAL(18,2) NULL, [CLOSING] DECIMAL(18,2) NULL,
        [STAFF_MEAL] DECIMAL(18,2) NULL, [COMP] DECIMAL(18,2) NULL,
        [CONSUMPTION] DECIMAL(18,2) NULL, [COST_PCT] DECIMAL(9,4) NULL, [GP_PCT] DECIMAL(9,4) NULL,
        CONSTRAINT [PK_F_MARGEBRUT_MONTH] PRIMARY KEY ([GROUP_NAME],[PERIOD_MONTH]));',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (TableName, SchemaName, CreationScript)
    VALUES (src.TableName, src.SchemaName, N'...same CreationScript...');
```

- [ ] **Step 2: Verify the MERGE key + column names against the real table.** Read `8_PresentationTables.sql` and confirm the exact `PresentationTables` column list (there may be tier/build-order columns that are NOT NULL). Adjust the MERGE column list to match. Run via MCP against `core`:

```sql
SELECT COLUMN_NAME, IS_NULLABLE FROM core.core.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='core' AND TABLE_NAME='PresentationTables' ORDER BY ORDINAL_POSITION;
```
Expected: every NOT-NULL column without a default is populated by the MERGE.

- [ ] **Step 3: Update QUERY_STATUS + commit.**

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/10_f_margebrut_month_table.sql" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): F_MARGEBRUT_MONTH presentation table DDL"
```

### Task 2: `reference.MARGEBRUT_MANUAL` table + seed

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/11_reference_margebrut_manual.sql`

**Interfaces:**
- Produces: `reference.MARGEBRUT_MANUAL (GROUP_NAME NVARCHAR(50), PERIOD_MONTH DATE, REV_PROV DECIMAL(18,2), NEW_PROV DECIMAL(18,2), STAFF_MEAL DECIMAL(18,2), COMP_COST_PCT DECIMAL(9,4))`, PK `(GROUP_NAME, PERIOD_MONTH)`.
- Consumed by: Task 4 (build step reads it for the no-feed columns).

- [ ] **Step 1: Write the create + MERGE-seed script.** `CREATE TABLE IF NOT EXISTS` equivalent (`IF OBJECT_ID(...) IS NULL CREATE TABLE ...`), then MERGE-seed the Oct-2025 sheet figures (from spec §5 / mock DESIGN.md §5) keyed by group+month, so the grid reconciles to the sheet when tested against Oct-2025. Real periods get their own rows later.

```sql
-- 11_reference_margebrut_manual.sql
IF OBJECT_ID(N'[reference].[MARGEBRUT_MANUAL]') IS NULL
CREATE TABLE [reference].[MARGEBRUT_MANUAL](
    [GROUP_NAME] NVARCHAR(50) NOT NULL, [PERIOD_MONTH] DATE NOT NULL,
    [REV_PROV] DECIMAL(18,2) NOT NULL DEFAULT 0, [NEW_PROV] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [STAFF_MEAL] DECIMAL(18,2) NOT NULL DEFAULT 0, [COMP_COST_PCT] DECIMAL(9,4) NOT NULL DEFAULT 0,
    CONSTRAINT [PK_MARGEBRUT_MANUAL] PRIMARY KEY ([GROUP_NAME],[PERIOD_MONTH]));

MERGE INTO [reference].[MARGEBRUT_MANUAL] AS tgt
USING (VALUES
    (N'Food',        '2025-10-01', 1092.60, 912.17, 306.40, 0.33),
    (N'Breakfast',   '2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Wines',       '2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Bottled Beer','2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Soft Drinks', '2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Spirit',      '2025-10-01',    0.00,   0.00,   0.00, 0.33)
) AS src (GROUP_NAME, PERIOD_MONTH, REV_PROV, NEW_PROV, STAFF_MEAL, COMP_COST_PCT)
ON tgt.GROUP_NAME = src.GROUP_NAME AND tgt.PERIOD_MONTH = src.PERIOD_MONTH
WHEN MATCHED THEN UPDATE SET REV_PROV=src.REV_PROV, NEW_PROV=src.NEW_PROV, STAFF_MEAL=src.STAFF_MEAL, COMP_COST_PCT=src.COMP_COST_PCT
WHEN NOT MATCHED THEN INSERT (GROUP_NAME, PERIOD_MONTH, REV_PROV, NEW_PROV, STAFF_MEAL, COMP_COST_PCT)
    VALUES (src.GROUP_NAME, src.PERIOD_MONTH, src.REV_PROV, src.NEW_PROV, src.STAFF_MEAL, src.COMP_COST_PCT);
```

- [ ] **Step 2: Confirm the `reference` schema exists on client DBs.** MCP against the Growyze proxy:

```sql
SELECT SCHEMA_NAME FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='reference';
```
Expected: one row. (If absent, add a `CREATE SCHEMA` guard to the script.)

- [ ] **Step 3: Commit.**

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/11_reference_margebrut_manual.sql" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): reference.MARGEBRUT_MANUAL provisions/staff-meal/comp table"
```

### Task 3: Verify turnover grouping shape (Mews → D_PRODUCT)

**Files:** none (investigation task; findings recorded in the Task 5 script header).

**Interfaces:**
- Produces: confirmation of the join `F_LINEITEM_15MIN.PRODUCT_HUB_ID → D_PRODUCT.BOTTOM_HUB_ID` and which tier's `MICROSERVICE_NAME` to read for the group.

- [ ] **Step 1: Confirm the product join + tier.** MCP against the Mews proxy (org 19). Verify PRODUCT_HUB_ID joins D_PRODUCT and inspect current MICROSERVICE_NAME (expected mostly NULL — not yet grouped):

```sql
SELECT TOP 20 f.LI_TYPE, f.PRODUCT_HUB_ID, d.BOTTOM_PRODUCT_NAME, d.TOP_NAME,
       d.BOTTOM_MICROSERVICE_NAME, d.TOP_MICROSERVICE_NAME
FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].presentation.F_LINEITEM_15MIN f
JOIN [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].presentation.D_PRODUCT d
  ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
WHERE f.LI_TYPE = 'PROD';
```
Expected: rows join; `*_MICROSERVICE_NAME` NULL. Record which tier (BOTTOM vs TOP) is the right grain to carry the group (BOTTOM = per-product; use BOTTOM so each sale line resolves directly).

- [ ] **Step 2: Confirm turnover incl/excl semantics.** Confirm `GROSS_VALUE` = incl-VAT and `NET_VALUE` = ex-VAT for LI_TYPE='PROD':

```sql
SELECT LI_TYPE, SUM(GROSS_VALUE) incl, SUM(TAX_VALUE) tax, SUM(NET_VALUE) net
FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].presentation.F_LINEITEM_15MIN
GROUP BY LI_TYPE;
```
Expected: `incl ≈ net + tax` for PROD. Record the mapping (TURNOVER_INCL=GROSS_VALUE, TURNOVER_EXCL=NET_VALUE).

- [ ] **Step 3: No commit** (investigation only; feeds Task 5).

### Task 4: Verify stock/purchases grouping shape (Growyze → D_INVITEM)

**Files:** none (investigation; findings feed Tasks 4-build and 5).

- [ ] **Step 1: Confirm the inventory join + MICROSERVICE_NAME tier on D_INVITEM.** MCP against the Growyze proxy (Padel Social). Confirm `F_INV_COUNTS_DAY.INVITEM_HUB_ID` joins `D_INVITEM` and locate its `*_MICROSERVICE_NAME` columns:

```sql
SELECT TOP 20 c.INVITEM_HUB_ID, c.COUNT_DATE, c.ACTUAL_COUNT, c.ORDER_QTY, c.UOM_COST,
       d.BOTTOM_MICROSERVICE_NAME, d.TOP_NAME
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].presentation.F_INV_COUNTS_DAY c
JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].presentation.D_INVITEM d
  ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID;
```
Expected: rows join. Record the join column names for D_INVITEM (mirror the Task 3 finding for D_PRODUCT).

- [ ] **Step 2: Confirm purchases source.** Confirm `ORDER_QTY` (stock-in) × `UOM_COST` is the purchases measure and `ACTUAL_COUNT` × `UOM_COST` is stock value. Note the O5 `UOM_COST` inflation risk in the Task-5 header as a correctness gate.

```sql
SELECT COUNT(*) rows_cnt, SUM(ORDER_QTY*UOM_COST) purchases_val, SUM(ACTUAL_COUNT*UOM_COST) stock_val
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].presentation.F_INV_COUNTS_DAY;
```
Expected: non-zero; sanity-check magnitude (flag if implausibly large → UOM_COST bug).

- [ ] **Step 3: No commit** (investigation only).

### Task 5: `MICROSERVICE_NAME` grouping script (both SATs)

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/12_group_mapping.sql`

**Interfaces:**
- Consumes: SAT table + attribute names for product and invitem grouping (confirm exact SAT table names via MCP in Step 1 — e.g. `datavault.SAT_PRODUCT`, `datavault.SAT_INVITEM`, and which column holds `MICROSERVICE_NAME`).
- Produces: populated `MICROSERVICE_NAME` on current SAT rows for both dimensions, using the 6 group strings. After this runs, a D_PRODUCT/D_INVITEM rebuild carries the group into the dimension.

- [ ] **Step 1: Locate the exact SAT tables + MICROSERVICE_NAME column.** MCP against the Mews proxy for products, Growyze proxy for invitems:

```sql
SELECT TABLE_NAME, COLUMN_NAME FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME='MICROSERVICE_NAME' AND TABLE_SCHEMA='datavault' AND TABLE_NAME LIKE 'SAT%PRODUCT%';
```
Expected: the SAT table(s) carrying `MICROSERVICE_NAME` for PRODUCT. Repeat with `LIKE 'SAT%INVITEM%'` on the Growyze proxy. Record exact names.

- [ ] **Step 2: Write the seed-by-category + override UPDATE script.** Two blocks — one UPDATE per SAT — using unqualified two-part names. Seed `MICROSERVICE_NAME` from the product/invitem's native category attribute via a `CASE`, then an explicit override `VALUES` list for exceptions the category cannot disambiguate (Food vs Breakfast, Wine vs Spirit). Only update **current** SAT rows (`CURRENT_FLAG = 1` or the SAT's equivalent — confirm in Step 1). Example (PRODUCT block; INVITEM mirrors it against `SAT_INVITEM`):

```sql
-- 12_group_mapping.sql  (MICROSERVICE_NAME is manual-only MDM; this script is its sole writer)
-- Block 1: Mews products (turnover)
UPDATE s SET MICROSERVICE_NAME =
    CASE
        WHEN s.ATTR_category LIKE '%wine%'      THEN N'Wines'
        WHEN s.ATTR_category LIKE '%beer%'      THEN N'Bottled Beer'
        WHEN s.ATTR_category LIKE '%spirit%'    THEN N'Spirit'
        WHEN s.ATTR_category LIKE '%soft%'      THEN N'Soft Drinks'
        WHEN s.ATTR_category LIKE '%breakfast%' THEN N'Breakfast'
        ELSE N'Food'
    END
FROM [datavault].[SAT_PRODUCT] s   -- exact name confirmed in Step 1
WHERE s.CURRENT_FLAG = 1;

-- Override exceptions (product IDs that the category rule mis-groups)
UPDATE s SET MICROSERVICE_NAME = ov.grp
FROM [datavault].[SAT_PRODUCT] s
JOIN (VALUES (N'<productId>', N'Breakfast')) AS ov(pid, grp) ON ov.pid = s.PRODUCT_ID
WHERE s.CURRENT_FLAG = 1;
```
(Replace `ATTR_category`/`PRODUCT_ID`/`CURRENT_FLAG` with the exact columns from Step 1. The override `VALUES` list is filled in during execution once the real product catalogue is visible.)

- [ ] **Step 3: Shape-test the CASE against the proxy (read-only rehearsal).** Run the CASE as a `SELECT` (not UPDATE) via MCP to preview the group distribution before any write:

```sql
SELECT CASE WHEN ... END AS grp, COUNT(*) FROM [<proxy>].datavault.SAT_PRODUCT WHERE CURRENT_FLAG=1 GROUP BY CASE ... END;
```
Expected: every row lands in one of the 6 groups; no NULLs; distribution plausible.

- [ ] **Step 4: Commit.**

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/12_group_mapping.sql" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): MICROSERVICE_NAME group mapping for SAT_PRODUCT + SAT_INVITEM"
```

### Task 6: `F_MARGEBRUT_MONTH` build step (`PresentationControl`)

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/13_f_margebrut_month_control.sql`

**Interfaces:**
- Consumes: `F_LINEITEM_15MIN`, `F_INV_COUNTS_DAY`, `D_PRODUCT`, `D_INVITEM`, `reference.MARGEBRUT_MANUAL`; the group tier confirmed in Tasks 3-4.
- Produces: a `PresentationControl` step that TRUNCATE+INSERTs `presentation.F_MARGEBRUT_MONTH`.

- [ ] **Step 1: Write the build query as a `PresentationControl` MERGE-upsert.** Register into `core.core.PresentationControl` (read `8_PresentationControl.sql` for the exact column set + a late build-order/tier so it runs after D_PRODUCT/D_INVITEM/F_* are built). The step body:

```sql
-- Core of the build step (INSERT ... SELECT into F_MARGEBRUT_MONTH)
WITH turnover AS (
    SELECT d.BOTTOM_MICROSERVICE_NAME AS GROUP_NAME,
           DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1) AS PERIOD_MONTH,
           SUM(f.GROSS_VALUE) AS TURNOVER_INCL, SUM(f.NET_VALUE) AS TURNOVER_EXCL
    FROM presentation.F_LINEITEM_15MIN f
    JOIN presentation.D_PRODUCT d ON d.BOTTOM_HUB_ID = f.PRODUCT_HUB_ID
    WHERE f.LI_TYPE = 'PROD' AND d.BOTTOM_MICROSERVICE_NAME IS NOT NULL
    GROUP BY d.BOTTOM_MICROSERVICE_NAME, DATEFROMPARTS(YEAR(f.ORDER_DATE), MONTH(f.ORDER_DATE), 1)
),
stock AS (   -- opening = first count in month, closing = last count in month, purchases = SUM(ORDER_QTY*UOM_COST)
    SELECT d.BOTTOM_MICROSERVICE_NAME AS GROUP_NAME,
           DATEFROMPARTS(YEAR(c.COUNT_DATE), MONTH(c.COUNT_DATE), 1) AS PERIOD_MONTH,
           SUM(c.ORDER_QTY * c.UOM_COST) AS PURCHASES,
           SUM(CASE WHEN c.COUNT_DATE = mn.min_dt THEN c.ACTUAL_COUNT * c.UOM_COST END) AS OPENING,
           SUM(CASE WHEN c.COUNT_DATE = mx.max_dt THEN c.ACTUAL_COUNT * c.UOM_COST END) AS CLOSING
    FROM presentation.F_INV_COUNTS_DAY c
    JOIN presentation.D_INVITEM d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
    -- mn/mx = per group+month min/max COUNT_DATE subqueries (fill in during execution)
    WHERE d.BOTTOM_MICROSERVICE_NAME IS NOT NULL
    GROUP BY d.BOTTOM_MICROSERVICE_NAME, DATEFROMPARTS(YEAR(c.COUNT_DATE), MONTH(c.COUNT_DATE), 1)
)
INSERT INTO presentation.F_MARGEBRUT_MONTH (GROUP_NAME, PERIOD_MONTH, TURNOVER_INCL, TURNOVER_EXCL,
    OPENING, PURCHASES, REV_PROV, NEW_PROV, ALL_STOCK, CLOSING, STAFF_MEAL, COMP, CONSUMPTION, COST_PCT, GP_PCT)
SELECT g.GROUP_NAME, g.PERIOD_MONTH,
    t.TURNOVER_INCL, t.TURNOVER_EXCL, s.OPENING, s.PURCHASES, m.REV_PROV, m.NEW_PROV,
    (ISNULL(s.OPENING,0)+ISNULL(s.PURCHASES,0)-ISNULL(m.REV_PROV,0)+ISNULL(m.NEW_PROV,0)) AS ALL_STOCK,
    s.CLOSING, m.STAFF_MEAL,
    (t.TURNOVER_INCL - t.TURNOVER_EXCL) * 0 + ISNULL(t.TURNOVER_EXCL,0) * ISNULL(m.COMP_COST_PCT,0) AS COMP,
    NULL AS CONSUMPTION, NULL AS COST_PCT, NULL AS GP_PCT   -- computed in Step 2 update
FROM (SELECT GROUP_NAME, PERIOD_MONTH FROM turnover UNION SELECT GROUP_NAME, PERIOD_MONTH FROM stock) g
LEFT JOIN turnover t ON t.GROUP_NAME=g.GROUP_NAME AND t.PERIOD_MONTH=g.PERIOD_MONTH
LEFT JOIN stock    s ON s.GROUP_NAME=g.GROUP_NAME AND s.PERIOD_MONTH=g.PERIOD_MONTH
LEFT JOIN reference.MARGEBRUT_MANUAL m ON m.GROUP_NAME=g.GROUP_NAME AND m.PERIOD_MONTH=g.PERIOD_MONTH;
```

- [ ] **Step 2: Add the consumption/ratio finalisation.** After the INSERT, an UPDATE sets `CONSUMPTION = ALL_STOCK - ISNULL(CLOSING,0) - ISNULL(STAFF_MEAL,0) - ISNULL(COMP,0)`, `COST_PCT = CASE WHEN TURNOVER_EXCL>0 THEN CONSUMPTION/TURNOVER_EXCL END`, `GP_PCT = CASE WHEN COST_PCT IS NOT NULL THEN 1-COST_PCT END`. (COMP here = staff/mgmt/rooms comp cost; refine sourcing against real comp data if Mews comps appear.)

- [ ] **Step 3: Shape-test the SELECT via MCP.** Run the CTE `SELECT` (without INSERT) against the Mews proxy (turnover half) and Growyze proxy (stock half) separately — the two proxies are different orgs, so test each half independently — confirming columns, no fan-out, plausible magnitudes. Full end-to-end (both halves in one org) is verified at go-live.

```sql
-- turnover half against org 19; expected: rows per group present after Task 5 grouping applied, or NULL groups if not yet grouped
```
Expected: turnover half returns group×month rows summing to `F_LINEITEM_15MIN` totals; stock half returns non-negative OPENING/CLOSING/PURCHASES.

- [ ] **Step 4: Commit.**

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/13_f_margebrut_month_control.sql" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): F_MARGEBRUT_MONTH PresentationControl build step"
```

### Task 7: Rewrite the 9 `MargeBrut*` vis queries to live reads

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/14_margebrut_vis_queries.sql`
- Reference (shape template, do not edit): `ClaudeDevelopment/integrations/MargeBrut/02_margebrut_vis_queries.sql`

**Interfaces:**
- Consumes: `presentation.F_MARGEBRUT_MONTH`.
- Produces: 9 `core.core.VisualisationQueries` rows (MERGE-upsert on `DataSetName, VisualizationType, Status='LIVE'`), each with the same RS1/RS2 card schema as the mock but `QueryTemplate` reading the fact + `WHERE 1=1 @FilterClause`.

- [ ] **Step 1: Copy the 9 records from the mock script** into the new file, preserving every non-`QueryTemplate` field (VisualizationType, ParameterMappings, FilterDefinitions, Version, Status) exactly — the card render schemas (RS1/RS2 column names) must not change.

- [ ] **Step 2: Replace each `QueryTemplate` body** — swap the literal `VALUES` for a `SELECT` over `presentation.F_MARGEBRUT_MONTH`, keeping identical output column names/aliases. Example for `MargeBrutCostRatioKPI` (SingleKPICard RS1 = `Title`, `Value`, `Description`):

```sql
SELECT N'Cost of Sales' AS Title,
       FORMAT(SUM(CONSUMPTION)/NULLIF(SUM(TURNOVER_EXCL),0), 'P1') AS Value,
       N'Gross Margin ' + FORMAT(1 - SUM(CONSUMPTION)/NULLIF(SUM(TURNOVER_EXCL),0), 'P1') AS Description
FROM presentation.F_MARGEBRUT_MONTH WHERE 1=1 @FilterClause;
```
Repeat for the other 8, reading the corresponding measures. BarChart `TotalValue`/`BarValue` numeric or NULL; grid Column1..Column29 map to the sheet columns as in the mock.

- [ ] **Step 3: Add a period `@FilterClause`.** Define `FilterDefinitions` JSON for a `PERIOD_MONTH` filter and ensure the RS2 header subquery uses the **same aliases** as RS1 (ref `memory/feedback_filterclause_aliases.md`). Default (empty filter) shows all periods.

- [ ] **Step 4: MCP shape-test each rewritten query.** Strip comments, replace `@FilterClause` with empty string, prefix `presentation.F_MARGEBRUT_MONTH` with a proxy DB that has the table populated (only available after go-live; until then, test against a hand-seeded temp copy or defer to go-live). At minimum, validate the SQL parses and column aliases match the card schema by running against an empty/seeded fact.

- [ ] **Step 5: Commit.**

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/14_margebrut_vis_queries.sql" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): 9 vis queries rewired to live F_MARGEBRUT_MONTH reads"
```

### Task 8: Report-DB config for the new org

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/15_report_config.sql`
- Reference (template): `ClaudeDevelopment/integrations/MargeBrut/03_margebrut_report_config.sql` + `00_fix_report_audit_trigger.sql`

**Interfaces:**
- Consumes: the new UAT org's `@OrgId`/`@DbPrefix` (from Task 9 provisioning).
- Produces: report-DB wiring (BiConfig → VisualisationConfig → VisualisationDataSetMap → DashboardGrid → DashboardGridItem → DashboardGroup + `OrganisationDashboardGroupMapping`) for the new org.

- [ ] **Step 1: Copy `03` to the new file** and re-point `@OrgId`/`@DbPrefix` to the new org (placeholder variables at top, filled at go-live once the org GUID exists). Layout/card spans unchanged from the mock.

- [ ] **Step 2: Prepend the audit-trigger fix guard** (`00_fix_report_audit_trigger.sql` logic) so the DashboardGrid inserts don't hit the NOT-NULL audit-column regression (`memory/marge-brut-dashboard.md`). Include the `OrganisationDashboardGroupMapping` insert (O13 visibility trap — without it the dashboard is invisible).

- [ ] **Step 3: Not MCP-testable** (report DB unreachable via MCP). Mark the script "developer-run, verify block must pass" in QUERY_STATUS. Commit.

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/15_report_config.sql" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): report-DB config for new UAT org"
```

---

## Phase B — Deployment & go-live (developer-executed; step B3 gated on fetcher)

### Task 9: UAT org provisioning script + deploy runbook

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/01_provision_uat_org.sql`
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/DEPLOY.txt`

**Interfaces:**
- Produces: a new UAT org "Three Rocks Hotel" mapped to Mews + Growyze; the deploy order for all scripts.

- [ ] **Step 1: Write the provisioning script** using the org/integration SPs (never direct INSERT): `AddOrganisation` (note `@OrganisationCode` is `uniqueidentifier`), then `MapOrganisationToIntegration` for Mews and Growyze (int IDs, per `memory/uat-migration.md`). The integration trigger provisions the schemas.

- [ ] **Step 2: Write `DEPLOY.txt`** capturing the full order with the fetcher gate marked:
  1. `01_provision_uat_org.sql` (UAT `core`, runner)
  2. Mews DV to UAT: `../../Mews/` 01→02→05→03 + `sp_DataVaultLoad` for the new org (ledger O14)
  3. **⛔ FETCHER GATE — Growyze feed lands for the hotel**
  4. Growyze O5/O6 data-quality fixes verified
  5. `11`, `12` (grouping) → rebuild D_PRODUCT/D_INVITEM → `10`, `13` (fact) → run presentation build
  6. `14` (vis queries, UAT `core`) → `15` (report DB, run directly)
  7. Verification (Task 10)

- [ ] **Step 3: Commit.**

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/01_provision_uat_org.sql" "ClaudeDevelopment/integrations/MargeBrut/live/DEPLOY.txt" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): UAT org provisioning + deploy runbook"
```

### Task 10: Go-live verification (post-gate)

**Files:**
- Create: `ClaudeDevelopment/integrations/MargeBrut/live/99_verify.sql` (read-only SELECTs, PASS/FAIL)

- [ ] **Step 1: Write the verification SELECTs** (spec §6): reconciliation (`SUM(CONSUMPTION)/SUM(TURNOVER_EXCL)` = hero KPI; group rows sum to grand total); coverage guard (products/invitems with activity but NULL `MICROSERVICE_NAME` must return **0 rows**); grain sanity (fact turnover = `F_LINEITEM_15MIN` for the window). Each returns a `PASS`/`FAIL` literal.

- [ ] **Step 2: (post-gate, developer)** After go-live, run `99_verify.sql` via the runner + spot-check in the UAT front end (dashboard renders, period filter switches months). Dispatch the `data-quality-tester` discipline on the first live load (UOM_COST sanity especially).

- [ ] **Step 3: Update `docs/outstanding/O8-*.md` progress log + commit.**

```bash
git add "ClaudeDevelopment/integrations/MargeBrut/live/99_verify.sql" "docs/outstanding/O8-marge-brut-dashboard.md" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(margebrut): go-live verification SELECTs + O8 progress"
```

---

## Self-review notes

- **Spec coverage:** §1–§3 → Tasks 1,6,7 (fact + flow); §4.1 fact → Tasks 1,6; §4.2 MDM (both dimensions) → Tasks 3,4,5; §4.3 manual → Task 2; §4.4 vis → Task 7; §4.5 report DB → Task 8; §5 sequencing → Task 9; §6 verification → Task 10. All covered.
- **Dual-dimension grouping** (D_PRODUCT for turnover, D_INVITEM for stock) is the key correctness point beyond the spec's single-`D_PRODUCT` wording — encoded in Tasks 4 & 5 and reflected back into the spec on approval.
- **Staff-meal/comp** have no distinct Growyze fact category → sourced from `MARGEBRUT_MANUAL` (Task 2), not the usage fact — a refinement discovered from the real `F_INV_USAGE_DAY` schema.
- **Known execution-time fill-ins** (explicitly flagged, not silent placeholders): the override product/invitem ID lists (Task 5), exact SAT column names (Task 5 Step 1), and min/max-count-date subqueries (Task 6) — all require the not-yet-existing org's real catalogue, so they are resolved during Phase B execution, not now.
- **Gated tasks:** Task 10 Step 2 and DEPLOY step 3 depend on the fetcher; everything in Phase A is authorable/testable now.
