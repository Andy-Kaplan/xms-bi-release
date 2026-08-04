# Growyze Pantry COGS Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `presentation.F_COGS_PERIOD` plus a 15-record "Pantry COGS" dashboard that replaces the two spreadsheets Raddish maintain by hand for every Growyze venue every month.

**Architecture:** A new tier-110 `PresentationControl` step derives an item × location × stocktake-period fact directly from `SAT_STOCKEVENT` and `SAT_INVITEM`, valuing every money column at Growyze's *latest cost price in the period*. Fifteen thin `VisualisationQueries` records read that fact for one dashboard. A `99_verify` PASS/FAIL script is authored first and is the only test harness this codebase has.

**Tech Stack:** SQL Server Managed Instance, T-SQL, Data Vault 2.0, XMS BI configuration-driven deployment (`PresentationTables` / `PresentationControl` / `VisualisationQueries` / `GlobalParameters` control tables), PowerShell `Invoke-Sqlcmd` runners, Azure SQL `report` database for dashboard wiring.

**Spec:** `docs/superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md` — read it before starting any task.

---

## Global Constraints

Every task's requirements implicitly include all of these.

- **SQL files may only be created or edited inside `ClaudeDevelopment/`.** All other `.sql` files in the repo are read-only. New scripts live in `ClaudeDevelopment/integrations/Growyze/cogs/`.
- **All control-table records use `MERGE` upserts on the table's natural key.** Never a bare `INSERT` — it breaks re-runnability with a unique-constraint violation. Natural keys: `PresentationTables` = `(table_name)`; `PresentationControl` = `(step_name, table_name)`; `VisualisationQueries` = `(DataSetName, VisualizationType, Status)`; `GlobalParameters` = `(ParameterKey)`.
- **Never hardcode a client database name.** Two-part names only: `[presentation].[F_COGS_PERIOD]`, `[datavault].[SAT_STOCKEVENT]`.
- **Omit `id`/GUID columns where the MERGE key does not need them** and rely on `DEFAULT NEWID()`. If an explicit GUID is supplied it must be hex-only (`0-9A-F`) or it throws `Msg 8169`.
- **Preserve the O5 two-step UOM contract exactly:** staging removes the pack (`price / COALESCE(NULLIF(size,0),1)`), presentation removes the unit scale (`/ conversion_factor`). Never apply both in one place and never skip one. Breaking this is how Ibis Gloucester Road read £762,277.46 instead of £8,157.61 across the same 151 lines.
- **Value every money column as `qty × UOM_COST`** where `UOM_COST` is the latest cost effective at or before `PERIOD_END_DATE`. Never an average. This is what makes the fact reconcile to Growyze's own export.
- **Category columns come from `D_INVITEM` native names only** — `TOP_NAME`, `MIDDLE_1_NAME`, `BOTTOM_INVITEM_NAME`. Never `COALESCE(*_MICROSERVICE_NAME, ...)`; Growyze staging hardcodes the literal `'growyze'` there (O23).
- **Every vis query scopes on `SOURCE`** (`SOURCE LIKE 'int_growyze%'`). O8 proved an unscoped query read cost of sales as 0.5% because NCRAloha's `TOP_NAME` is also `'Food'`.
- **Every mapped filter or parameter column expression must be ≤100 characters.** `BuildDynamicWhereClause` holds them in an `NVARCHAR(100)` and assigns `JSON_VALUE` straight in, silently truncating anything longer.
- **Never return `NULL` as `TotalValue`** from a BarChartCard query — it renders as `0.00`, asserting a wrong number instead of omitting one. Return the real coverage-matched value or omit the column.
- **`DashboardGridFilter.DataSet` must exactly equal the per-card `FilterDefinitions` key**, or the filter is never emitted and silently does nothing.
- **Vis queries return two result sets:** result 1 = data rows, result 2 = header metadata (title, axis labels).
- **The build step reads `SAT_STOCKEVENT` unbounded** — it must NOT filter on `STOCKEVENT_START`/`STOCKEVENT_END`. The fact holds all periods because the comparison card reads history from it.
- **`DeployPresentationTables` DROPs every registered table.** Deploy `F_COGS_PERIOD` individually, never through the bulk procedure.
- **No database access in the authoring session.** Every "run" step in this plan is a deploy-time step performed by Andy via the PowerShell runner. Authoring tasks verify by construction and inspection only, and must say so rather than claim a script has been tested.
- **Subagents do not commit.** Authoring agents write files only; verification and any commit happen centrally at Task 12.
- **Update `ClaudeDevelopment/QUERY_STATUS.md`** with an entry for every script created. Handled centrally in Task 12.

---

## File Structure

All under `ClaudeDevelopment/integrations/Growyze/cogs/`.

| File | Responsibility |
|---|---|
| `PREFLIGHT.md` | Findings for the three open questions that gate the build (delivery event type, two-level category integrity, `MICROSERVICE_NAME` pollution) |
| `00_CARD_CONTRACTS.md` | Exact output-column contract per card type, extracted from existing live queries. The interface every vis-query task consumes |
| `99_verify_cogs_period.sql` | 9 PASS/FAIL checks. Written first; it is the test |
| `01_cogs_period_table.sql` | `PresentationTables` MERGE — `F_COGS_PERIOD` DDL, clustered + non-clustered indexes |
| `02_cogs_period_build.sql` | `PresentationControl` MERGE — the tier-110 derivation. The heart of the work |
| `03_report_group_config.sql` | `GlobalParameters` MERGE — break-out bucket list |
| `04_vis_kpis.sql` | 4 `SingleKPICard` datasets |
| `05_vis_charts.sql` | 5 chart datasets (pie, comparison, top items, slow movers, by venue) |
| `06_vis_grids.sql` | 3 grid datasets (billing totals, item table, exceptions) |
| `07_vis_filters.sql` | 3 `FilterList` datasets |
| `08_report_db_config.sql` | Report-DB wiring — runs against `report`, not the client DB |
| `90_deploy_cogs.ps1` | PowerShell runner, `-WhatIf` preflight + typed confirmation + halt-on-error + `-StartAt` resume |
| `DEPLOY.txt` | Ordered deploy sequence |
| `README.md` | What this folder is, how it maps to the spec, current state |

Split by responsibility: the fact definition (01–03), the presentation surface grouped by card family (04–07), the external report DB (08), and the test (99). Vis queries are split by family rather than one-file-per-query because they share output contracts and are edited together.

---

## Task Dependency Order

```
Task 1  (preflight + card contracts)   ─┬─→ Task 2  (99_verify)
                                        ├─→ Task 3  (01 table)  ─→ Task 4 (02 build) ─┐
                                        └─→ Task 5  (03 config) ─────────────────────┤
                                                                                      ├─→ Task 10 (08 report DB)
Task 4 ─┬─→ Task 6  (04 vis KPIs)     ──┐                                            │
        ├─→ Task 7  (05 vis charts)    ──┤ parallel, one agent per file               │
        ├─→ Task 8  (06 vis grids)     ──┤                                            │
        └─→ Task 9  (07 vis filters)   ──┘                                            │
                                                                                      ▼
                                                          Task 11 (runner + docs) ─→ Task 12 (central verify)
```

Tasks 6–9 are mutually independent and fan out in parallel once Task 4 fixes the column contract.

---

### Task 1: Preflight findings and card output contracts

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/PREFLIGHT.md`
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/00_CARD_CONTRACTS.md`
- Read: `docs/stockevent-ruleset.md`, `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql`, `ClaudeDevelopment/integrations/Growyze/12_stocktake_staging.sql`, `ClaudeDevelopment/integrations/Growyze/14_dn_events_size_multiplier_fix.sql`, `8_PresentationTables.sql:434-500`, `8_VisualisationQueries.sql`

**Interfaces:**
- Consumes: nothing
- Produces: `00_CARD_CONTRACTS.md` — for each of `SingleKPICard`, `PieChartCard`, `BarChartCard`, `CustomDataGrid`, `CustomGroupedDataGrid`, `FilterList`: the exact output column names and types of result set 1 and result set 2, copied from a named live example. `PREFLIGHT.md` — verdicts on Q1/Q2/Q3 below.

- [ ] **Step 1: Answer Q1 — what `EVENT_TYPE` do Growyze delivery events carry?**

Read `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql` and find the `GRYZ_DN_EVENTS` staging step. Record the literal `EVENT_TYPE` value it emits and whether the pending fix to `'ORDER'` has been applied.

Write to `PREFLIGHT.md`:

```markdown
## Q1 — Delivery event type
**Source:** ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql, step `GRYZ_DN_EVENTS`, line NNN
**Emits:** EVENT_TYPE = '<literal>'
**Verdict:** <'ORDER' already | still 'DELIVERY' | both>
**Consequence:** step 9's ORDER_QTY is <populated | always zero> for Growyze orgs.
**Action for 02_cogs_period_build.sql:** read EVENT_TYPE IN ('ORDER','DELIVERY') regardless.
```

- [ ] **Step 2: Answer Q2 — do Category AND Subcategory both reach `D_INVITEM`?**

Find the `Growyze Inventory Items` staging step and the `Inventory Item Dimension` `PresentationControl` step. Determine whether Growyze's product category and subcategory populate two distinct dimension tiers (`TOP_NAME` and `MIDDLE_1_NAME`) or collapse into one.

Write to `PREFLIGHT.md`:

```markdown
## Q2 — Two-level category integrity
**TOP_NAME sourced from:** <column/expression, file:line>
**MIDDLE_1_NAME sourced from:** <column/expression, file:line>
**Verdict:** <both levels distinct | only one level populated | MIDDLE_1 falls through to TOP>
**Blocks the break-out rule:** <no | YES — staging fix required first>
```

If only one level lands, **stop and report**. The `REPORT_GROUP` break-out rule cannot work and a staging fix is a prerequisite. Do not invent a workaround.

- [ ] **Step 3: Answer Q3 — is `D_INVITEM.*_MICROSERVICE_NAME` polluted?**

O23 established Growyze staging hardcodes the literal `'growyze'` into `SUPPLIER`'s `MICROSERVICE_NAME`. Check whether the same hardcoding reaches `INVITEM`'s `EntityMappings` row and therefore `D_INVITEM`.

```markdown
## Q3 — MICROSERVICE_NAME pollution on INVITEM
**EntityMappings MICROSERVICE_NAME for INVITEM:** <expression | NULL, file:line>
**Verdict:** <clean | hardcoded literal — must not COALESCE>
```

- [ ] **Step 4: Extract the card output contracts**

For each card type below, find a live `Status = 'LIVE'` example in `8_VisualisationQueries.sql`, and record its exact result-set-1 and result-set-2 column names. Use these named examples:

| Card type | Find an example by searching for |
|---|---|
| `SingleKPICard` | `N'SingleKPICard'` |
| `PieChartCard` | `N'PieChartCard'` |
| `BarChartCard` | `N'BarChartCard'` |
| `CustomDataGrid` | `N'CustomDataGrid'` |
| `CustomGroupedDataGrid` | `N'CustomGroupedDataGrid'` |
| `FilterList` | `N'FilterList'` |

For each, write into `00_CARD_CONTRACTS.md`:

```markdown
### BarChartCard
**Example:** DataSetName = 'XXX' (8_VisualisationQueries.sql:NNNN)
**Result set 1 columns:** Label1, Value1, AxisSort1, ...
**Result set 2 columns:** Title, XAxisLabel, YAxisLabel, TotalValue, ...
**Multi-series pattern:** <how Label2/Value2 or a series column is expressed>
**ParameterMappings shape:** <verbatim JSON from the example>
**FilterDefinitions shape:** <verbatim JSON from the example>
```

Include the verbatim `ParameterMappings` and `FilterDefinitions` JSON — Tasks 6–9 must not invent these, and O8 proved that `ParameterMappings = '{}'` silently discards filters.

- [ ] **Step 5: Record the two-result-set caveat and the header-alias contract**

Add to `00_CARD_CONTRACTS.md`:

```markdown
## Contracts every query in 04–07 must honour
1. Two result sets: data, then header metadata.
2. Header-subquery aliases MUST match the data query's aliases (FilterClause alias contract) —
   `@FilterClause` is injected at every site, so a mismatched alias throws at render time.
3. `WHERE 1=1 @FilterClause` is the injection pattern.
4. Never `NULL AS TotalValue` on a BarChartCard — renders as 0.00.
5. Every mapped filter/parameter column expression ≤100 characters.
6. Scope every query: `AND F.[SOURCE] LIKE 'int_growyze%'`.
```

- [ ] **Step 6: Report findings — do not proceed past a Q2 failure**

Report Q1/Q2/Q3 verdicts. If Q2 says only one category level lands, halt the plan and escalate; every downstream task depends on `REPORT_GROUP` being expressible.

---

### Task 2: The verification script (written before the build)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/99_verify_cogs_period.sql`

**Interfaces:**
- Consumes: `PREFLIGHT.md` Q1 verdict (check 9's expected delivery figures)
- Produces: nothing consumed by later tasks; it is the acceptance gate for Task 12 and for deployment

This is the codebase's only test mechanism: a script of PASS/FAIL `SELECT`s. It is written first and is expected to fail (the table will not exist) until Task 4 is deployed.

- [ ] **Step 1: Write the script header and the harness pattern**

```sql
/*  99_verify_cogs_period.sql
    Verification for presentation.F_COGS_PERIOD (Growyze Pantry COGS).
    Spec: docs/superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md §8

    Run against a client database with Growyze data AFTER the tier-110 build has run.
    Every section prints a single row with a PASS/FAIL verdict.
    Two-part names only - never prefix a database name.

    NOT YET RUN - authored without database access. First execution is the real test.
*/
SET NOCOUNT ON;

DECLARE @src NVARCHAR(50) = N'int_growyze%';
```

- [ ] **Step 2: Check 1 — grain / no fan-out**

```sql
PRINT '--- Check 1: grain / fan-out ---';
SELECT
     CASE WHEN COUNT(*) = COUNT(DISTINCT CONCAT(
                CONVERT(VARCHAR(64), [INVITEM_HUB_ID], 2), '|',
                CONVERT(VARCHAR(64), [LOCATION_HUB_ID], 2), '|',
                CONVERT(VARCHAR(30), [PERIOD_END_DATE], 126)))
          THEN 'PASS' ELSE 'FAIL' END              AS Verdict
    ,COUNT(*)                                      AS FactRows
    ,COUNT(DISTINCT CONCAT(
        CONVERT(VARCHAR(64), [INVITEM_HUB_ID], 2), '|',
        CONVERT(VARCHAR(64), [LOCATION_HUB_ID], 2), '|',
        CONVERT(VARCHAR(30), [PERIOD_END_DATE], 126))) AS DistinctGrain
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src;
```

- [ ] **Step 3: Check 3 — internal consistency (category subtotals = grand total)**

```sql
PRINT '--- Check 3: category subtotals reconcile to grand total ---';
WITH ByGroup AS (
    SELECT [REPORT_GROUP], SUM([COG_SOLD]) AS GroupSold
    FROM [presentation].[F_COGS_PERIOD]
    WHERE [SOURCE] LIKE @src
    GROUP BY [REPORT_GROUP]
), Grand AS (
    SELECT SUM([COG_SOLD]) AS TotalSold
    FROM [presentation].[F_COGS_PERIOD]
    WHERE [SOURCE] LIKE @src
)
SELECT
     CASE WHEN ABS((SELECT SUM(GroupSold) FROM ByGroup) - (SELECT TotalSold FROM Grand)) < 0.005
          THEN 'PASS' ELSE 'FAIL' END      AS Verdict
    ,(SELECT SUM(GroupSold) FROM ByGroup)  AS SumOfGroups
    ,(SELECT TotalSold FROM Grand)         AS GrandTotal;
```

- [ ] **Step 4: Check 4 — coverage guard (the 22% defect)**

```sql
PRINT '--- Check 4: coverage guard - no ungrouped items with movement ---';
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*)                     AS UngroupedRows
    ,SUM([COG_SOLD])              AS ValueAtRisk
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src
  AND ([CATEGORY] IS NULL OR [REPORT_GROUP] IS NULL)
  AND ([DELIVERY_QTY] <> 0 OR [CONSUMPTION_QTY] <> 0 OR [CLOSING_QTY] <> 0);
```

Comment above it: *this is the exact defect that silently removed £24,199.53 (22%) of consumption from every chart in Raddish's June pack. It must FAIL loudly, never drop rows.*

- [ ] **Step 5: Check 5 — zero-cost items reported, not hidden**

```sql
PRINT '--- Check 5: zero/NULL cost items with movement (reported, not hidden) ---';
SELECT
     'INFO'                        AS Verdict
    ,COUNT(*)                      AS ZeroCostRows
    ,SUM([CONSUMPTION_QTY])        AS UnvaluedConsumptionQty
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src
  AND [HAS_ZERO_COST] = 1
  AND ([DELIVERY_QTY] <> 0 OR [CONSUMPTION_QTY] <> 0);
```

This is Raddish's SOP check 8 automated. Verdict is `INFO`, not `FAIL` — zero-cost items are a source-data issue to surface, not a build defect.

- [ ] **Step 6: Check 6 — period integrity (the O8 collapse)**

```sql
PRINT '--- Check 6: period integrity ---';
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,SUM(CASE WHEN [PERIOD_START_DATE] = [PERIOD_END_DATE] THEN 1 ELSE 0 END) AS SameStocktakeBothEnds
    ,SUM(CASE WHEN [PERIOD_DAYS] <= 0 THEN 1 ELSE 0 END)                      AS NonPositiveDays
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src
  AND ([PERIOD_START_DATE] = [PERIOD_END_DATE] OR [PERIOD_DAYS] <= 0);
```

Comment: *O8's Marge Brut had opening and closing resolving to the same month-end stocktake, collapsing consumption to purchases. This check makes that impossible to ship.*

- [ ] **Step 7: Check 7 — cost basis is latest-in-period, not an average**

```sql
PRINT '--- Check 7: UOM_COST equals SAT_INVITEM latest at or before PERIOD_END_DATE ---';
WITH LatestCost AS (
    SELECT
         LII.[INVITEM_HUB_ID]
        ,F.[PERIOD_END_DATE]
        ,SI.[UOM_COST]
        ,ROW_NUMBER() OVER (PARTITION BY LII.[INVITEM_HUB_ID], F.[PERIOD_END_DATE]
                            ORDER BY SI.[EFFECTIVEFROM] DESC) AS rn
    FROM [presentation].[F_COGS_PERIOD] F
    INNER JOIN [datavault].[SAT_INVITEM] SI
        ON SI.[HUB_ID] = F.[INVITEM_HUB_ID]
    CROSS APPLY (SELECT F.[INVITEM_HUB_ID]) AS LII([INVITEM_HUB_ID])
    WHERE F.[SOURCE] LIKE @src
      AND SI.[EFFECTIVEFROM] <= F.[PERIOD_END_DATE]
)
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*) AS MismatchedCostRows
FROM [presentation].[F_COGS_PERIOD] F
INNER JOIN LatestCost L
    ON L.[INVITEM_HUB_ID] = F.[INVITEM_HUB_ID]
   AND L.[PERIOD_END_DATE] = F.[PERIOD_END_DATE]
   AND L.rn = 1
WHERE F.[SOURCE] LIKE @src
  AND ABS(ISNULL(F.[UOM_COST],0) - ISNULL(L.[UOM_COST],0) / 1.0) > 0.005;
```

Note in a comment that the `/ conversion_factor` term must be applied to `L.[UOM_COST]` to match; the implementer resolves the exact conversion join against `02_cogs_period_build.sql` once written, and the check must compare like with like.

- [ ] **Step 8: Check 8 — filter-column length**

```sql
PRINT '--- Check 8: mapped filter/parameter expressions <= 100 chars ---';
SELECT
     CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,COUNT(*) AS OverlongMappings
FROM [core].[core].[VisualisationQueries]
CROSS APPLY OPENJSON(NULLIF([ParameterMappings], N'')) AS pm
WHERE [DataSetName] LIKE N'PantryCOGS%'
  AND [Status] = N'LIVE'
  AND LEN(CAST(pm.[value] AS NVARCHAR(MAX))) > 100;
```

Add the same test over `FilterDefinitions`. Comment: *`BuildDynamicWhereClause` assigns `JSON_VALUE` into an `NVARCHAR(100)` and truncates silently — O8's ~700-char group CASE was unusable as a filter column.*

- [ ] **Step 9: Check 9 — delivery events present**

```sql
PRINT '--- Check 9: deliveries non-zero for a period with known receipts ---';
SELECT
     CASE WHEN SUM([DELIVERY_QTY]) > 0 THEN 'PASS' ELSE 'FAIL' END AS Verdict
    ,SUM([DELIVERY_QTY]) AS TotalDeliveryQty
    ,SUM([COG_SPEND])    AS TotalCOGSpend
FROM [presentation].[F_COGS_PERIOD]
WHERE [SOURCE] LIKE @src;
```

Comment: *guards the `DELIVERY` vs `ORDER` event-type trap (spec §5.2). A FAIL here means the build's `EVENT_TYPE IN ('ORDER','DELIVERY')` predicate or the staging label is wrong.*

- [ ] **Step 10: Check 2 — reconciliation to Growyze (stub with an explicit dependency note)**

Check 2 needs a Growyze COGS export for a venue whose data we hold. Write the comparison harness against a staging table and document the dependency:

```sql
/*  --- Check 2: reconcile to Growyze COGS export (ACCEPTANCE TEST) ---
    DEPENDENCY: requires a Growyze COGS export for the same stocktake pair,
    loaded into reference.GROWYZE_COGS_EXPORT_STAGING (item name, opening, deliveries,
    transfers, closing, consumption, cost price, cost of closing, COG sold, COG spend).
    Not yet available - request from Kati or generate from a UAT Growyze org.
    Until it exists this check reports SKIPPED, and the build is internally consistent
    but NOT proven to replace the spreadsheet faithfully.
*/
IF OBJECT_ID('[reference].[GROWYZE_COGS_EXPORT_STAGING]') IS NULL
    SELECT 'SKIPPED' AS Verdict, 'No Growyze export loaded' AS Reason;
ELSE
    -- item-level diff on COG_SOLD, COG_SPEND, CLOSING_VALUE; tolerance 0.005
    SELECT ... ;
```

Write the full `ELSE` branch as a real item-level diff joining on item name, reporting count of mismatches and the largest absolute variance. Do not leave it as `...`.

- [ ] **Step 11: Self-review the script**

Confirm: no database-name prefixes anywhere; every check returns exactly one summary row; the header states the script has not been executed. Report the file path and the list of checks with their verdict types.

---

### Task 3: `PresentationTables` record for `F_COGS_PERIOD`

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/01_cogs_period_table.sql`
- Read for pattern: `8_PresentationTables.sql:1188-1250` (the `F_INV_COUNTS_DAY` record)

**Interfaces:**
- Consumes: nothing
- Produces: the exact column list and types of `presentation.F_COGS_PERIOD` — Tasks 4 and 6–9 all bind to these names. Any change here must be propagated.

- [ ] **Step 1: Write the MERGE wrapper**

`PresentationTables`'s natural key is `table_name`. Column list, copied verbatim from the master file:

```sql
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'F_COGS_PERIOD')) AS src (table_name)
    ON tgt.[table_name] = src.[table_name]
WHEN MATCHED THEN UPDATE SET
     [table_type]           = N'Fact'
    ,[schema_name]          = N'presentation'
    ,[ddl_script]           = @ddl
    ,[column_definitions]   = @cols
    ,[description]          = N'Item x location x stocktake-period COGS fact for Growyze pantry reporting. COG Spend = delivered value (billing); COG Sold = consumption value (insights). All money columns valued at latest cost price in period.'
    ,[version]              = 1
    ,[status]               = N'live'
    ,[is_system_generated]  = 0
    ,[updated_at]           = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions,
     description, business_owner, data_source, version, status,
     is_system_generated, created_by, created_at, updated_at)
VALUES
    (N'F_COGS_PERIOD', N'Fact', N'presentation', @ddl, @cols,
     N'Item x location x stocktake-period COGS fact for Growyze pantry reporting.',
     NULL, N'Growyze', 1, N'live', 0, NULL, GETDATE(), GETDATE());
```

- [ ] **Step 2: Declare the DDL exactly as specified**

```sql
DECLARE @ddl NVARCHAR(MAX) = N'CREATE TABLE [presentation].[F_COGS_PERIOD](
    [INVITEM_HUB_ID] [binary](32) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [PERIOD_START_DATE] [datetime2](7) NULL,
    [PERIOD_END_DATE] [datetime2](7) NULL,
    [PERIOD_DAYS] [int] NULL,
    [PERIOD_SEQ] [int] NULL,
    [PERIOD_MONTH] [date] NULL,
    [PERIOD_LABEL] [varchar](50) NULL,
    [SOURCE] [varchar](100) NULL,
    [STANDARDISED_UOM] [varchar](255) NULL,
    [ITEM_NAME] [nvarchar](255) NULL,
    [CATEGORY] [nvarchar](255) NULL,
    [SUBCATEGORY] [nvarchar](255) NULL,
    [REPORT_GROUP] [nvarchar](255) NULL,
    [OPENING_QTY] [decimal](38, 6) NULL,
    [DELIVERY_QTY] [decimal](38, 6) NULL,
    [TRANSFER_QTY] [decimal](38, 6) NULL,
    [CLOSING_QTY] [decimal](38, 6) NULL,
    [CONSUMPTION_QTY] [decimal](38, 6) NULL,
    [WASTE_QTY] [decimal](38, 6) NULL,
    [SALE_QTY] [decimal](38, 6) NULL,
    [THEO_CLOSING_QTY] [decimal](38, 6) NULL,
    [VARIANCE_QTY] [decimal](38, 6) NULL,
    [UOM_COST] [decimal](38, 6) NULL,
    [OPENING_VALUE] [decimal](38, 6) NULL,
    [DELIVERY_VALUE] [decimal](38, 6) NULL,
    [COG_SPEND] [decimal](38, 6) NULL,
    [COG_SOLD] [decimal](38, 6) NULL,
    [CLOSING_VALUE] [decimal](38, 6) NULL,
    [WASTE_VALUE] [decimal](38, 6) NULL,
    [VARIANCE_VALUE] [decimal](38, 6) NULL,
    [IS_NEGATIVE_COGS] [bit] NULL,
    [HAS_ZERO_COST] [bit] NULL,
    [IS_UNCOUNTED] [bit] NULL,
    [IS_FIRST_PERIOD] [bit] NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_COGS_PERIOD-CLUSTERED] ON [presentation].[F_COGS_PERIOD]
(
    [PERIOD_END_DATE] ASC,
    [LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_COGS_PERIOD-INVITEM] ON [presentation].[F_COGS_PERIOD]
(
    [INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;';
```

`ITEM_NAME` is included so the item grid does not need a `D_INVITEM` join at render time.

- [ ] **Step 3: Populate `column_definitions`**

Match the JSON/text format used by the `F_INV_COUNTS_DAY` record in `8_PresentationTables.sql` (line 1236 is truncated in listings — open the file and copy the format exactly). Every column above must appear.

- [ ] **Step 4: Add the deploy note**

```sql
/*  DEPLOY NOTE
    Deploy THIS TABLE ONLY for the target org. Do NOT run DeployPresentationTables -
    it DROPs every registered presentation table (O8).
*/
```

- [ ] **Step 5: Self-review**

Every column in spec §4 present with the specified type; no database-name prefix; MERGE not INSERT; re-runnable. Report the column count.

---

### Task 4: `PresentationControl` tier-110 build step

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/02_cogs_period_build.sql`
- Read for pattern: `8_PresentationControl.sql:1938-2180` (the `F_INV_COUNTS_DAY` step)

**Interfaces:**
- Consumes: `01_cogs_period_table.sql` column names; `03_report_group_config.sql` parameter key `COGS_REPORT_GROUP_BREAKOUT`; `PREFLIGHT.md` Q1/Q2/Q3 verdicts
- Produces: a populated `presentation.F_COGS_PERIOD`. Tasks 6–9 bind to its column names and to `SOURCE LIKE 'int_growyze%'`

This is the heart of the work. Everything else is wiring.

- [ ] **Step 1: Write the MERGE wrapper**

Natural key is `(step_name, table_name)`. Column list verbatim from the master file:

```sql
DECLARE @sql NVARCHAR(MAX) = N'<the build query, single-quotes doubled>';

MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (N'Pantry COGS by Period', N'F_COGS_PERIOD')) AS src (step_name, table_name)
    ON tgt.[step_name] = src.[step_name] AND tgt.[table_name] = src.[table_name]
WHEN MATCHED THEN UPDATE SET
     [query_sql]        = @sql
    ,[tier]             = 110
    ,[table_type]       = N'Fact'
    ,[exclude]          = 0
    ,[priority]         = 100
    ,[retry_count]      = 3
    ,[timeout_minutes]  = 30
    ,[description]      = N'Builds F_COGS_PERIOD at item x location x stocktake-period grain. Unbounded read - full refresh.'
    ,[updated_at]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (step_name, table_name, query_sql, tier, table_type, column_mappings,
     exclude, priority, retry_count, timeout_minutes, description,
     created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (N'Pantry COGS by Period', N'F_COGS_PERIOD', @sql, 110, N'Fact', NULL,
     0, 100, 3, 30, N'Builds F_COGS_PERIOD at item x location x stocktake-period grain.',
     N'PresentationControlApp', GETDATE(), GETDATE(), NULL, NULL);
```

Omit `id` and rely on `DEFAULT NEWID()`. Match `column_mappings` to whatever the `F_INV_COUNTS_DAY` step uses — inspect it; if it is a JSON map, produce the equivalent for our columns.

- [ ] **Step 2: `UOMConversion` CTE — copy verbatim, do not re-derive**

```sql
WITH UOMConversion AS (
    SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor
    UNION ALL SELECT ''Kg'', ''gr'', 1000
    UNION ALL SELECT ''lb'', ''gr'', 453.59237
    UNION ALL SELECT ''oz'', ''gr'', 28.349523
    UNION ALL SELECT ''ml'', ''ml'', 1
    UNION ALL SELECT ''cl'', ''ml'', 10
    UNION ALL SELECT ''L'', ''ml'', 1000
    UNION ALL SELECT ''Imperial Pint'', ''ml'', 568.26125
    UNION ALL SELECT ''Gal'', ''ml'', 4546.09
    UNION ALL SELECT ''EA'', ''EA'', 1
),
```

- [ ] **Step 3: `StockEvents` CTE — unbounded, Growyze-scoped**

Model on the `F_INV_COUNTS_DAY` step but **remove the date filter**:

```sql
StockEvents AS (
    SELECT
         SE.[SRC]
        ,SE.[EVENT_TYPE]
        ,SE.[EVENT_BEHAVIOUR]
        ,CAST(SE.[EVENT_TS] AS DATE)                       AS [EVENT_TS]
        ,SE.[UOM]
        ,SE.[UOM_QUANITY] * uc.conversion_factor           AS [STANDARDISED_QTY]
        ,uc.base_uom                                       AS [STANDARDISED_UOM]
        ,SE.[INTERNAL_REF]
        ,LSE.[LOCATION_HUB_ID]
        ,LII.[INVITEM_HUB_ID]
    FROM [datavault].[SAT_STOCKEVENT] SE
    INNER JOIN [datavault].[LNK_LOCATION_STOCKEVENT] LSE ON SE.[HUB_ID] = LSE.[STOCKEVENT_HUB_ID]
    INNER JOIN [datavault].[LNK_INVITEM_STOCKEVENT] LII  ON SE.[HUB_ID] = LII.[STOCKEVENT_HUB_ID]
    LEFT OUTER JOIN UOMConversion uc ON SE.[UOM] = uc.[UOM]
    WHERE 1=1
      AND SE.[CURRENT_FLAG] = 1
      AND ISNULL(SE.[IS_DELETED], 0) = 0
      AND SE.[SRC] LIKE ''int_growyze%''
),
```

Note `SE.[UOM_QUANITY]` — the column name is misspelled in the source schema. Use it as-is.

- [ ] **Step 4: `StocktakeCalendar` and `Periods` CTEs — location-level boundaries**

This is the deliberate divergence from step 9, which `LAG`s per item. Boundaries are per **location**:

```sql
StocktakeCalendar AS (
    SELECT DISTINCT [LOCATION_HUB_ID], [EVENT_TS] AS [COUNT_DATE]
    FROM StockEvents
    WHERE [EVENT_BEHAVIOUR] = ''COUNT''
),
Periods AS (
    SELECT
         [LOCATION_HUB_ID]
        ,LAG([COUNT_DATE]) OVER (PARTITION BY [LOCATION_HUB_ID] ORDER BY [COUNT_DATE]) AS [PERIOD_START_DATE]
        ,[COUNT_DATE]                                                                  AS [PERIOD_END_DATE]
        ,ROW_NUMBER() OVER (PARTITION BY [LOCATION_HUB_ID] ORDER BY [COUNT_DATE] DESC) AS [PERIOD_SEQ]
    FROM StocktakeCalendar
),
```

Rows where `PERIOD_START_DATE IS NULL` are the venue's first-ever stocktake — they become `IS_FIRST_PERIOD = 1` with `OPENING_QTY = 0`, and must not be silently dropped.

- [ ] **Step 5: `ItemCounts` CTE — per-item count at each boundary, carried forward**

For every (item, location, period) pair, resolve opening and closing as the item's most recent `COUNT` at or before each boundary:

```sql
ItemCounts AS (
    SELECT
         [LOCATION_HUB_ID], [INVITEM_HUB_ID], [EVENT_TS] AS [COUNT_DATE]
        ,[STANDARDISED_QTY], [STANDARDISED_UOM]
    FROM StockEvents
    WHERE [EVENT_BEHAVIOUR] = ''COUNT''
),
PeriodItems AS (
    SELECT DISTINCT P.[LOCATION_HUB_ID], P.[PERIOD_START_DATE], P.[PERIOD_END_DATE],
           P.[PERIOD_SEQ], I.[INVITEM_HUB_ID]
    FROM Periods P
    INNER JOIN (SELECT DISTINCT [LOCATION_HUB_ID], [INVITEM_HUB_ID] FROM StockEvents) I
        ON I.[LOCATION_HUB_ID] = P.[LOCATION_HUB_ID]
),
Bounded AS (
    SELECT
         PI.*
        ,OC.[STANDARDISED_QTY] AS [OPENING_QTY]
        ,CC.[STANDARDISED_QTY] AS [CLOSING_QTY]
        ,CASE WHEN CC.[COUNT_DATE] = PI.[PERIOD_END_DATE] THEN 0 ELSE 1 END AS [IS_UNCOUNTED]
    FROM PeriodItems PI
    OUTER APPLY (SELECT TOP 1 * FROM ItemCounts C
                 WHERE C.[LOCATION_HUB_ID] = PI.[LOCATION_HUB_ID]
                   AND C.[INVITEM_HUB_ID]  = PI.[INVITEM_HUB_ID]
                   AND C.[COUNT_DATE] <= PI.[PERIOD_START_DATE]
                 ORDER BY C.[COUNT_DATE] DESC) OC
    OUTER APPLY (SELECT TOP 1 * FROM ItemCounts C
                 WHERE C.[LOCATION_HUB_ID] = PI.[LOCATION_HUB_ID]
                   AND C.[INVITEM_HUB_ID]  = PI.[INVITEM_HUB_ID]
                   AND C.[COUNT_DATE] <= PI.[PERIOD_END_DATE]
                 ORDER BY C.[COUNT_DATE] DESC) CC
),
```

`OUTER APPLY ... TOP 1 ... ORDER BY COUNT_DATE DESC` **is** the carry-forward rule. Confirm it against a real Growyze export (spec §5.3) before trusting the numbers.

- [ ] **Step 6: `Movements` CTE — summed over `(PERIOD_START, PERIOD_END]`**

Accept both delivery labels per Q1:

```sql
Movements AS (
    SELECT
         B.[LOCATION_HUB_ID], B.[INVITEM_HUB_ID], B.[PERIOD_END_DATE]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] IN (''ORDER'',''DELIVERY'')
                  THEN CASE WHEN SE.[EVENT_BEHAVIOUR] = ''-'' THEN -SE.[STANDARDISED_QTY] ELSE SE.[STANDARDISED_QTY] END
                  ELSE 0 END) AS [DELIVERY_QTY]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] = ''TRANSFER''
                  THEN CASE WHEN SE.[EVENT_BEHAVIOUR] = ''-'' THEN -SE.[STANDARDISED_QTY] ELSE SE.[STANDARDISED_QTY] END
                  ELSE 0 END) AS [TRANSFER_QTY]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] = ''WASTE'' THEN SE.[STANDARDISED_QTY] ELSE 0 END) AS [WASTE_QTY]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] = ''SALE''  THEN SE.[STANDARDISED_QTY] ELSE 0 END) AS [SALE_QTY]
    FROM Bounded B
    LEFT JOIN StockEvents SE
        ON  SE.[LOCATION_HUB_ID] = B.[LOCATION_HUB_ID]
        AND SE.[INVITEM_HUB_ID]  = B.[INVITEM_HUB_ID]
        AND SE.[EVENT_BEHAVIOUR] IN (''+'',''-'')
        AND SE.[EVENT_TS] >  B.[PERIOD_START_DATE]
        AND SE.[EVENT_TS] <= B.[PERIOD_END_DATE]
    GROUP BY B.[LOCATION_HUB_ID], B.[INVITEM_HUB_ID], B.[PERIOD_END_DATE]
),
```

For a first period (`PERIOD_START_DATE IS NULL`) the `>` predicate must not eliminate all movements — use `ISNULL(B.[PERIOD_START_DATE], ''1900-01-01'')`.

- [ ] **Step 7: `ItemCost` CTE — latest cost at or before period end**

```sql
ItemCost AS (
    SELECT
         B.[INVITEM_HUB_ID], B.[PERIOD_END_DATE]
        ,C.[UOM_COST] / NULLIF(uc.conversion_factor, 0) AS [UOM_COST]
    FROM (SELECT DISTINCT [INVITEM_HUB_ID], [PERIOD_END_DATE] FROM Bounded) B
    OUTER APPLY (SELECT TOP 1 SI.[UOM_COST], SI.[UOM]
                 FROM [datavault].[SAT_INVITEM] SI
                 WHERE SI.[HUB_ID] = B.[INVITEM_HUB_ID]
                   AND SI.[EFFECTIVEFROM] <= B.[PERIOD_END_DATE]
                 ORDER BY SI.[EFFECTIVEFROM] DESC) C
    LEFT JOIN UOMConversion uc ON C.[UOM] = uc.[UOM]
),
```

**This is the single most important CTE for reconciliation.** `TOP 1 ... ORDER BY EFFECTIVEFROM DESC` is *latest cost in period* — Growyze's basis. Never `AVG`. Confirm `SAT_INVITEM`'s SCD2 column is `EFFECTIVEFROM` by inspecting the satellite; if it differs, use the actual name.

- [ ] **Step 8: `ReportGroup` CTE — read the break-out list from config**

```sql
BreakoutBuckets AS (
    SELECT LTRIM(RTRIM(value)) AS [CATEGORY]
    FROM STRING_SPLIT(
        (SELECT [ParameterValue] FROM [core].[GlobalParameters]
         WHERE [ParameterKey] = ''COGS_REPORT_GROUP_BREAKOUT''), ''|'')
),
```

`REPORT_GROUP` is then built in the final `SELECT`:

```sql
,CASE WHEN BB.[CATEGORY] IS NOT NULL
      THEN DI.[TOP_NAME] + '' - '' + ISNULL(DI.[MIDDLE_1_NAME], ''Unspecified'')
      ELSE DI.[TOP_NAME] END AS [REPORT_GROUP]
```

with `LEFT JOIN BreakoutBuckets BB ON BB.[CATEGORY] = DI.[TOP_NAME]`. Pipe-delimited so a bucket name containing a comma still works.

- [ ] **Step 9: Final `SELECT` — all 35 columns in the DDL's order**

Join `Bounded` → `Movements` → `ItemCost` → `[presentation].[D_INVITEM] DI ON DI.[BOTTOM_HUB_ID] = B.[INVITEM_HUB_ID]` → `BreakoutBuckets`. Emit exactly the columns from Task 3 Step 2, computing:

```sql
,ISNULL(B.[OPENING_QTY],0) + ISNULL(M.[DELIVERY_QTY],0)
   + ISNULL(M.[TRANSFER_QTY],0) - ISNULL(B.[CLOSING_QTY],0)          AS [CONSUMPTION_QTY]
,ISNULL(B.[OPENING_QTY],0) + ISNULL(M.[DELIVERY_QTY],0)
   + ISNULL(M.[TRANSFER_QTY],0) - ISNULL(M.[WASTE_QTY],0)
   - ISNULL(M.[SALE_QTY],0)                                          AS [THEO_CLOSING_QTY]
,DATEDIFF(DAY, B.[PERIOD_START_DATE], B.[PERIOD_END_DATE])           AS [PERIOD_DAYS]
,DATEFROMPARTS(YEAR(B.[PERIOD_END_DATE]), MONTH(B.[PERIOD_END_DATE]), 1) AS [PERIOD_MONTH]
,CONVERT(VARCHAR(11), B.[PERIOD_START_DATE], 106) + '' - ''
   + CONVERT(VARCHAR(11), B.[PERIOD_END_DATE], 106)                  AS [PERIOD_LABEL]
,DI.[BOTTOM_INVITEM_NAME]                                            AS [ITEM_NAME]
,DI.[TOP_NAME]                                                       AS [CATEGORY]
,DI.[MIDDLE_1_NAME]                                                  AS [SUBCATEGORY]
```

and each value column as `qty × IC.[UOM_COST]`, plus the four flags per spec §4.1.

**`ITEM_NAME`, `CATEGORY` and `SUBCATEGORY` use native `D_INVITEM` names — never `COALESCE(*_MICROSERVICE_NAME, ...)`** (Global Constraints; O23).

- [ ] **Step 10: Escape and embed**

The whole query goes into `@sql` as an `NVARCHAR(MAX)` literal with **every single quote doubled**. Verify by counting: an odd number of consecutive quotes anywhere means the escaping is wrong.

- [ ] **Step 11: Self-review**

Check every item: no date bound on `StockEvents`; boundaries are per location not per item; cost is `TOP 1 ... DESC`, never an average; `/ conversion_factor` present exactly once; native `D_INVITEM` names only; all 35 DDL columns emitted in order; single quotes doubled throughout; no database-name prefix; MERGE not INSERT. Report which spec §4.1 derivations are implemented and where.

---

### Task 5: `GlobalParameters` break-out config

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/03_report_group_config.sql`

**Interfaces:**
- Consumes: nothing
- Produces: `GlobalParameters` key `COGS_REPORT_GROUP_BREAKOUT` — a pipe-delimited list of `CATEGORY` values to break out by `SUBCATEGORY`. Task 4 Step 8 reads it.

- [ ] **Step 1: Write the MERGE**

```sql
/*  Categories to break out by subcategory in REPORT_GROUP.
    Pipe-delimited so bucket names containing commas still work.
    Raddish's catch-all bucket is "Can't Live Without It"; other Growyze
    customers will name theirs differently - this is why it is config.
    An empty or missing value means no break-out: REPORT_GROUP = CATEGORY.
*/
MERGE INTO [core].[GlobalParameters] AS tgt
USING (VALUES (N'COGS_REPORT_GROUP_BREAKOUT')) AS src (ParameterKey)
    ON tgt.[ParameterKey] = src.[ParameterKey]
WHEN MATCHED THEN UPDATE SET
     [ParameterValue] = N'Can''t Live Without It'
WHEN NOT MATCHED THEN INSERT ([ParameterKey], [ParameterValue])
VALUES (N'COGS_REPORT_GROUP_BREAKOUT', N'Can''t Live Without It');
```

- [ ] **Step 2: Match the real column list**

Open `2_CoreTableCreateScripts.sql`, find the `GlobalParameters` DDL, and align the `INSERT` column list to it exactly (it may carry `Category`, `Description`, `ModifiedDate` and similar). Do not guess.

- [ ] **Step 3: Self-review** — MERGE not INSERT; the apostrophe in the value is doubled; re-runnable.

---

### Task 6: 4 `SingleKPICard` datasets

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/04_vis_kpis.sql`
- Read first: `cogs/00_CARD_CONTRACTS.md`

**Interfaces:**
- Consumes: `F_COGS_PERIOD` columns (Task 3); `SingleKPICard` output contract and verbatim `ParameterMappings` / `FilterDefinitions` JSON from `00_CARD_CONTRACTS.md`
- Produces: `PantryCOGSSpendKPI`, `PantryCOGSSoldKPI`, `PantryCOGSClosingStockKPI`, `PantryCOGSVarianceKPI`

- [ ] **Step 1: Write the MERGE helper shape once**

Natural key is `(DataSetName, VisualizationType, Status)`:

```sql
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSSpendKPI', N'SingleKPICard', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON  tgt.[DataSetName]       = src.[DataSetName]
    AND tgt.[VisualizationType] = src.[VisualizationType]
    AND tgt.[Status]            = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate]      = @q
    ,[ParameterMappings]  = @pm
    ,[FilterDefinitions]  = @fd
    ,[OutputDefinitions]  = @od
    ,[Description]        = N'Total COG Spend (delivered value) for the selected venues and period.'
    ,[ModifiedDate]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate,
     ParameterMappings, FilterDefinitions, OutputDefinitions, ExecutionQuery,
     Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES
    (N'PantryCOGSSpendKPI', N'SingleKPICard', 1, N'LIVE', @q,
     @pm, @fd, @od, NULL,
     N'Total COG Spend (delivered value) for the selected venues and period.',
     NULL, NULL, GETDATE(), GETDATE());
```

Repeat this block per dataset with its own `@q` / `@pm` / `@fd` / `@od`. Do not attempt to loop — each record is explicit and greppable.

- [ ] **Step 2: `PantryCOGSSpendKPI` query**

```sql
SELECT
     SUM(F.[COG_SPEND]) AS TotalValue
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause;

SELECT
     ''COG Spend'' AS Title
    ,''Value delivered - what the client is billed'' AS Description;
```

`IS_FIRST_PERIOD = 0` is excluded throughout the pack: a venue's first-ever stocktake has no opening, so its consumption is meaningless.

- [ ] **Step 3: The other three KPI queries**

Identical shape, substituting:

| Dataset | Measure | Title | Description |
|---|---|---|---|
| `PantryCOGSSoldKPI` | `SUM(F.[COG_SOLD])` | `COG Sold` | `Value consumed - what was actually used` |
| `PantryCOGSClosingStockKPI` | `SUM(F.[CLOSING_VALUE])` | `Closing stock` | `Stock on hand at the closing stocktake, at cost` |
| `PantryCOGSVarianceKPI` | `SUM(F.[VARIANCE_VALUE])` | `Unexplained variance` | `Consumption not explained by declared waste or sales` |

- [ ] **Step 4: Set `ParameterMappings` and `FilterDefinitions` from the contracts doc**

Copy the JSON shape from `00_CARD_CONTRACTS.md` and populate three filter keys: `PantryCOGSVenues` → `F.[LOCATION_HUB_ID]`, `PantryCOGSPeriods` → `F.[PERIOD_LABEL]`, `PantryCOGSCategories` → `F.[REPORT_GROUP]`.

**Never leave `ParameterMappings` as `'{}'`** — O8 proved that silently discards the filter. Every mapped expression must be ≤100 characters; all three above are short by design.

- [ ] **Step 5: Self-review** — 4 records; MERGE on the 3-part natural key; `SOURCE` scoped; two result sets each; no mapping over 100 chars; single quotes doubled. Report the 4 dataset names.

---

### Task 7: 5 chart datasets

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/05_vis_charts.sql`
- Read first: `cogs/00_CARD_CONTRACTS.md`

**Interfaces:**
- Consumes: `F_COGS_PERIOD` columns; `PieChartCard` and `BarChartCard` contracts from `00_CARD_CONTRACTS.md`
- Produces: `PantryCOGSConsumptionMix`, `PantryCOGSPeriodComparison`, `PantryCOGSTopItemsByCategory`, `PantryCOGSSlowMovers`, `PantryCOGSByVenue`

Use the same MERGE block shape as Task 6 Step 1, with the appropriate `VisualizationType`.

- [ ] **Step 1: `PantryCOGSConsumptionMix` — PieChartCard**

```sql
SELECT
     F.[REPORT_GROUP]     AS Label1
    ,SUM(F.[COG_SOLD])    AS Value1
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause
GROUP BY F.[REPORT_GROUP]
HAVING SUM(F.[COG_SOLD]) > 0
ORDER BY SUM(F.[COG_SOLD]) DESC;
```

Plus the header result set. Adjust column names to the contract if the live example differs.

- [ ] **Step 2: `PantryCOGSPeriodComparison` — BarChartCard, 3 series**

Groups by `PERIOD_MONTH` (spec §7.3): the selected month and the two before it, per `REPORT_GROUP`.

```sql
DECLARE @anchor DATE = (SELECT MAX([PERIOD_MONTH]) FROM [presentation].[F_COGS_PERIOD]
                        WHERE [SOURCE] LIKE ''int_growyze%'');

SELECT
     F.[REPORT_GROUP]                                        AS Label1
    ,CONVERT(VARCHAR(8), F.[PERIOD_MONTH], 3)                AS Label2
    ,SUM(F.[COG_SOLD])                                       AS Value1
    ,DENSE_RANK() OVER (ORDER BY F.[PERIOD_MONTH])           AS AxisSort1
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  AND F.[PERIOD_MONTH] >= DATEADD(MONTH, -2, @anchor)
  @FilterClause
GROUP BY F.[REPORT_GROUP], F.[PERIOD_MONTH]
ORDER BY F.[REPORT_GROUP], F.[PERIOD_MONTH];
```

Return a **numeric** `TotalValue` in the header — never `NULL` (Global Constraints).

Replace Raddish's pasted literals: this reads all three months from the fact, so history cannot be lost with a file.

- [ ] **Step 3: `PantryCOGSTopItemsByCategory` — BarChartCard, 2 series**

Two series per item: % of its category's consumption units, and % of its category's spend. Raddish's equivalent tab had a wrong numerator on both, producing a 142.8% bar — so both denominators must be coverage-matched to the same filtered row set.

```sql
WITH Scoped AS (
    SELECT F.* FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
      @FilterClause
), CategoryTotals AS (
    SELECT [REPORT_GROUP]
          ,SUM([CONSUMPTION_QTY]) AS CatQty
          ,SUM([COG_SOLD])        AS CatSold
    FROM Scoped GROUP BY [REPORT_GROUP]
), Ranked AS (
    SELECT S.[REPORT_GROUP], S.[ITEM_NAME]
          ,SUM(S.[CONSUMPTION_QTY]) AS ItemQty
          ,SUM(S.[COG_SOLD])        AS ItemSold
          ,ROW_NUMBER() OVER (PARTITION BY S.[REPORT_GROUP] ORDER BY SUM(S.[COG_SOLD]) DESC) AS rn
    FROM Scoped S GROUP BY S.[REPORT_GROUP], S.[ITEM_NAME]
)
SELECT
     R.[ITEM_NAME]                                        AS Label1
    ,R.ItemQty  / NULLIF(CT.CatQty, 0)  * 100             AS Value1
    ,R.ItemSold / NULLIF(CT.CatSold, 0) * 100             AS Value2
FROM Ranked R
INNER JOIN CategoryTotals CT ON CT.[REPORT_GROUP] = R.[REPORT_GROUP]
WHERE R.rn <= 7
ORDER BY R.[REPORT_GROUP], R.ItemSold DESC;
```

`NULLIF(...,0)` on both denominators — a zero-consumption category must not throw.

- [ ] **Step 4: `PantryCOGSSlowMovers` — BarChartCard**

Bottom 10 by consumption quantity, excluding zero — Raddish's `SORTN(FILTER(...), 10, TRUE, ..., TRUE)`:

```sql
WITH Scoped AS (
    SELECT F.[ITEM_NAME], F.[REPORT_GROUP], SUM(F.[CONSUMPTION_QTY]) AS Qty
    FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
      @FilterClause
    GROUP BY F.[ITEM_NAME], F.[REPORT_GROUP]
    HAVING SUM(F.[CONSUMPTION_QTY]) > 0
)
SELECT TOP 10
     [ITEM_NAME] AS Label1
    ,Qty         AS Value1
FROM Scoped
ORDER BY Qty ASC;
```

- [ ] **Step 5: `PantryCOGSByVenue` — BarChartCard**

The consolidation view — the thing a per-venue spreadsheet cannot do:

```sql
SELECT
     COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'') AS Label1
    ,SUM(F.[COG_SOLD])                                    AS Value1
FROM [presentation].[F_COGS_PERIOD] F
LEFT JOIN [presentation].[D_LOCATION] L ON L.[BOTTOM_HUB_ID] = F.[LOCATION_HUB_ID]
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause
GROUP BY COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'')
ORDER BY SUM(F.[COG_SOLD]) DESC;
```

Confirm `D_LOCATION`'s name column from `8_PresentationTables.sql` before using it; the `BOTTOM_*_NAME` convention varies by dimension.

- [ ] **Step 6: Self-review** — 5 records; no `NULL AS TotalValue` on any BarChartCard; every denominator `NULLIF`-guarded; `SOURCE` scoped; two result sets each. Report the 5 dataset names.

---

### Task 8: 3 grid datasets

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/06_vis_grids.sql`
- Read first: `cogs/00_CARD_CONTRACTS.md`

**Interfaces:**
- Consumes: `F_COGS_PERIOD` columns; `CustomDataGrid` and `CustomGroupedDataGrid` contracts
- Produces: `PantryCOGSBillingTotals`, `PantryCOGSItemTable`, `PantryCOGSExceptions`

- [ ] **Step 1: `PantryCOGSBillingTotals` — CustomDataGrid with grand total**

Replaces the invoice workbook's `SUMIF` sheet. Grain is `CATEGORY - SUBCATEGORY`, measure is `COG_SPEND`:

```sql
SELECT
     F.[CATEGORY] + '' - '' + ISNULL(F.[SUBCATEGORY], ''Unspecified'') AS CategorySubcategory
    ,SUM(F.[COG_SPEND])                                               AS Spend
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause
GROUP BY F.[CATEGORY], F.[SUBCATEGORY]
ORDER BY F.[CATEGORY], F.[SUBCATEGORY];
```

Add a `GRAND TOTAL` rollup row using the grid contract's convention (check the live `CustomDataGrid` example — O8's `MargeBrutGrid` does exactly this). The grand total must equal `PantryCOGSSpendKPI` — verify check 3 covers it.

- [ ] **Step 2: `PantryCOGSItemTable` — CustomGroupedDataGrid**

Replaces the "Full Consumption Report" tab, whose columns F–J were mislabelled by one position. Emit **explicit, correct** headings:

```sql
SELECT
     F.[REPORT_GROUP]        AS GroupName
    ,F.[ITEM_NAME]           AS ItemName
    ,F.[STANDARDISED_UOM]    AS Unit
    ,SUM(F.[OPENING_QTY])    AS OpeningQty
    ,SUM(F.[DELIVERY_QTY])   AS DeliveryQty
    ,SUM(F.[TRANSFER_QTY])   AS TransferQty
    ,SUM(F.[CLOSING_QTY])    AS ClosingQty
    ,SUM(F.[CONSUMPTION_QTY])AS ConsumptionQty
    ,MAX(F.[UOM_COST])       AS UnitCost
    ,SUM(F.[CLOSING_VALUE])  AS ClosingStockValue
    ,SUM(F.[COG_SPEND])      AS COGSpend
    ,SUM(F.[COG_SOLD])       AS COGSold
    ,SUM(F.[VARIANCE_VALUE]) AS UnexplainedVariance
    ,MAX(F.[PERIOD_DAYS])    AS PeriodDays
FROM [presentation].[F_COGS_PERIOD] F
WHERE 1=1
  AND F.[SOURCE] LIKE ''int_growyze%''
  AND ISNULL(F.[IS_FIRST_PERIOD], 0) = 0
  @FilterClause
GROUP BY F.[REPORT_GROUP], F.[ITEM_NAME], F.[STANDARDISED_UOM]
ORDER BY F.[REPORT_GROUP], SUM(F.[COG_SOLD]) DESC;
```

`PeriodDays` is surfaced deliberately (spec §10 risk 5) so a sparse-stocktake period is visible rather than hidden.

- [ ] **Step 3: `PantryCOGSExceptions` — CustomDataGrid**

This card is why flag-only adjustments (D3) are workable — it is the mechanism that drives corrections back into Growyze. One row per exception with a reason:

```sql
WITH Scoped AS (
    SELECT F.* FROM [presentation].[F_COGS_PERIOD] F
    WHERE 1=1
      AND F.[SOURCE] LIKE ''int_growyze%''
      @FilterClause
)
SELECT [ITEM_NAME] AS ItemName, [REPORT_GROUP] AS GroupName, [PERIOD_LABEL] AS Period
      ,''Negative consumption'' AS Reason
      ,[CONSUMPTION_QTY] AS Qty, [COG_SOLD] AS Value
FROM Scoped WHERE [IS_NEGATIVE_COGS] = 1
UNION ALL
SELECT [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL], ''Zero or missing cost price''
      ,[CONSUMPTION_QTY], [COG_SOLD]
FROM Scoped WHERE [HAS_ZERO_COST] = 1 AND ([DELIVERY_QTY] <> 0 OR [CONSUMPTION_QTY] <> 0)
UNION ALL
SELECT [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL], ''Not counted at closing stocktake''
      ,[CONSUMPTION_QTY], [COG_SOLD]
FROM Scoped WHERE [IS_UNCOUNTED] = 1
UNION ALL
SELECT [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL], ''First period - no opening stock''
      ,[CONSUMPTION_QTY], [COG_SOLD]
FROM Scoped WHERE [IS_FIRST_PERIOD] = 1
UNION ALL
SELECT [ITEM_NAME], [REPORT_GROUP], [PERIOD_LABEL], ''Missing category or subcategory''
      ,[CONSUMPTION_QTY], [COG_SOLD]
FROM Scoped WHERE [CATEGORY] IS NULL OR [SUBCATEGORY] IS NULL
ORDER BY Reason, Value DESC;
```

Note this is the only card that does **not** exclude `IS_FIRST_PERIOD` — first periods are themselves an exception to surface.

Covers Raddish SOP checks 7 (deliveries with no spend, via zero cost), 8 (zero cost price) and 10 (blank subcategory), plus negative COG Sold.

- [ ] **Step 4: Self-review** — 3 records; all `UNION ALL` branches have matching column counts and compatible types; the exceptions card intentionally includes first periods; `SOURCE` scoped; two result sets each.

---

### Task 9: 3 `FilterList` datasets

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/07_vis_filters.sql`
- Read first: `cogs/00_CARD_CONTRACTS.md`

**Interfaces:**
- Consumes: `F_COGS_PERIOD` columns; the `FilterList` output contract
- Produces: `PantryCOGSVenues`, `PantryCOGSPeriods`, `PantryCOGSCategories` — **these three names must exactly match the `FilterDefinitions` keys used in Tasks 6–8**, or the filters are silently dead (Global Constraints)

- [ ] **Step 1: `PantryCOGSVenues`**

```sql
SELECT DISTINCT
     CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)          AS Value
    ,COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'') AS Label
FROM [presentation].[F_COGS_PERIOD] F
LEFT JOIN [presentation].[D_LOCATION] L ON L.[BOTTOM_HUB_ID] = F.[LOCATION_HUB_ID]
WHERE F.[SOURCE] LIKE ''int_growyze%''
ORDER BY Label;
```

Sourced from the **fact's own** location keys, not from `D_LOCATION` wholesale. O8's lesson: its first attempt reused `ProductCategories`, which listed `D_PRODUCT` names (`'Wine'`) that did not match the fact's values (`'Wines'`) and was not source-scoped, so any pick matched nothing.

- [ ] **Step 2: `PantryCOGSPeriods`**

```sql
SELECT DISTINCT
     F.[PERIOD_LABEL] AS Value
    ,F.[PERIOD_LABEL] AS Label
    ,MAX(F.[PERIOD_END_DATE]) AS SortValue
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
GROUP BY F.[PERIOD_LABEL]
ORDER BY SortValue DESC;
```

Newest first so the default selection is the latest period.

- [ ] **Step 3: `PantryCOGSCategories`**

```sql
SELECT DISTINCT
     F.[REPORT_GROUP] AS Value
    ,F.[REPORT_GROUP] AS Label
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
  AND F.[REPORT_GROUP] IS NOT NULL
ORDER BY F.[REPORT_GROUP];
```

- [ ] **Step 4: Cross-check the names against Tasks 6–8**

Grep `04_vis_kpis.sql`, `05_vis_charts.sql` and `06_vis_grids.sql` for each of the three names. Every `FilterDefinitions` key must appear here as a `DataSetName`, and vice versa. Report the cross-check result explicitly — this is the contract O8 verified rather than assumed.

- [ ] **Step 5: Self-review** — 3 records; sourced from the fact; `SOURCE` scoped; names match the filter keys exactly.

---

### Task 10: Report-DB wiring

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/08_report_db_config.sql`
- Read for pattern: `ClaudeDevelopment/integrations/MargeBrut/live/` report-config script; `docs/microservice-report-database.md`

**Interfaces:**
- Consumes: the 15 dataset names from Tasks 6–9
- Produces: a wired dashboard on the target org

- [ ] **Step 1: Parameterise the script**

```sql
/*  08_report_db_config.sql
    Runs against the microservice `report` database - NOT the client DB, NOT via MCP.
    Set these two before running.
*/
DECLARE @OrgId    INT           = <target org id>;
DECLARE @DbPrefix NVARCHAR(100) = N'<target db prefix>';
```

- [ ] **Step 2: Wire the chain in order**

`BiConfig` → `VisualisationConfig` → `VisualisationDataSetMap` (15 rows) → `DashboardGrid` (1, named "Pantry COGS") → `DashboardGridItem` (12 card rows) → `DashboardGridFilter` (3 rows) → `DashboardGroup` + `OrganisationDashboardGroupMapping`.

Follow the MargeBrut script's exact statement shapes. Two known traps: `OrganisationDashboardGroupMapping` is the **load-bearing** junction for visibility (not `DashboardGroupMapping`, which is unused — O13 was a misdiagnosis on exactly this); and `report`'s audit triggers on `DashboardConfig` / `StaffDashboardConfig` are broken (O22), so run `00_fix_report_audit_trigger.sql` first if writes fail.

- [ ] **Step 3: `DashboardGridFilter.DataSet` values**

Set these to **exactly** `PantryCOGSVenues`, `PantryCOGSPeriods`, `PantryCOGSCategories` — character for character equal to the `FilterDefinitions` keys in Tasks 6–8. A mismatch means the widget renders and does nothing.

- [ ] **Step 4: Map card types to `VisualisationProcedure` integers**

From the MargeBrut design: `1` = BarChartCard, `3` = CustomDataGrid, `9` = PieChartCard, `10` = SingleKPICard. Look up `CustomGroupedDataGrid` and `FilterList` in `report.dbo.VisualisationProcedure` rather than guessing, and record the values in a comment.

- [ ] **Step 5: Add a verify-or-rollback tail**

Follow the MargeBrut pattern: after wiring, `SELECT` the card count for the new grid and the group mapping, and print PASS/FAIL. Wrap in an explicit transaction with rollback on failure.

- [ ] **Step 6: Self-review** — 12 grid items + 3 filters = 15 datasets mapped; org/prefix parameterised, never hardcoded to one org in the committed script; `OrganisationDashboardGroupMapping` written; verify tail present.

---

### Task 11: Runner and folder documentation

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/90_deploy_cogs.ps1`
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/DEPLOY.txt`
- Create: `ClaudeDevelopment/integrations/Growyze/cogs/README.md`
- Read for pattern: `ClaudeDevelopment/prod-baseline/90_deploy_baseline.ps1`

**Interfaces:**
- Consumes: all script filenames from Tasks 2–10
- Produces: the deployment entry point

- [ ] **Step 1: Write the runner**

Mirror `90_deploy_baseline.ps1`: `Invoke-Sqlcmd` with `XMS_BI_MANAGED_{DEV|TEST|UAT|PROD}_*` env vars, `-WhatIf` preflight, typed confirmation, halt-on-error, `-StartAt` resume, per-run log file, and PASS/FAIL validation via `99_verify_cogs_period.sql` through the same connection.

Two safety requirements: the runner must **refuse to run `08_report_db_config.sql`** (that script targets `report`, a different server — it is run separately by hand), and it must **never** invoke `DeployPresentationTables`.

- [ ] **Step 2: Write `DEPLOY.txt`**

```
Growyze Pantry COGS - deploy order
Spec: docs/superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md
Target for first deploy: Ibis Gloucester Road (UAT org 21) - 2 count dates = 1 complete period

PREFLIGHT  Read cogs/PREFLIGHT.md. If Q2 says only one category level lands, STOP.
1  99_verify_cogs_period.sql   -- run FIRST, expect FAIL (table absent). This is the test.
2  01_cogs_period_table.sql    -- PresentationTables MERGE
3  02_cogs_period_build.sql    -- PresentationControl MERGE (tier 110)
4  03_report_group_config.sql  -- GlobalParameters MERGE
5  Deploy F_COGS_PERIOD for the org - THIS TABLE ONLY, never DeployPresentationTables
6  Presentation rebuild
7  99_verify_cogs_period.sql   -- expect PASS (check 2 SKIPPED until a Growyze export exists)
8  04_vis_kpis.sql / 05_vis_charts.sql / 06_vis_grids.sql / 07_vis_filters.sql
9  08_report_db_config.sql     -- run DIRECTLY against `report`, by hand, not via this runner
10 UI check - exercise all three filters as the target org
```

- [ ] **Step 2b: Write `README.md`**

State what the folder is, link the spec and this plan, list every script with one line each, and record the current state honestly: **authored without database access; nothing has been executed; check 2 (Growyze reconciliation) is blocked pending an export.**

- [ ] **Step 3: Self-review** — deploy order matches the task dependency graph; the runner refuses `08`; README does not claim anything has been tested.

---

### Task 12: Central verification, status log, ledger item

**Files:**
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`
- Modify: `docs/OUTSTANDING.md`
- Create: `docs/outstanding/O26-growyze-pantry-cogs-dashboard.md`

**Interfaces:**
- Consumes: every artefact from Tasks 1–11
- Produces: a reviewed, logged, ledger-tracked deliverable

Performed centrally, not by a subagent — this is the verification gate.

- [ ] **Step 1: Cross-file contract check**

Verify by grep, and report each result:
1. Every column referenced in `02`, `04`–`07` and `99` exists in `01`'s DDL.
2. The three `FilterList` dataset names in `07` match every `FilterDefinitions` key in `04`–`06`.
3. `08`'s `DashboardGridFilter.DataSet` values match those same three names.
4. No `.sql` file outside `ClaudeDevelopment/` was modified.
5. No file contains a hardcoded client database name.
6. Every control-table write is a `MERGE`, not a bare `INSERT`.
7. No `COALESCE(*_MICROSERVICE_NAME` anywhere.
8. No `AVG(` in the cost CTE.
9. No `STOCKEVENT_START` / `STOCKEVENT_END` reference in `02`.
10. No mapped filter/parameter expression over 100 characters.

- [ ] **Step 2: Update `QUERY_STATUS.md`**

One entry per script: purpose, target stack, and status `authored - NOT RUN (no DB access in authoring session)`.

- [ ] **Step 3: Raise Release ledger item O26**

Add a row to `docs/OUTSTANDING.md` (next free ID — confirm it is O26; the board currently ends at O25) and create the detail file from the `task-detail.md` template. Status `OPEN`, Area `Growyze / presentation + Report DB`, Owner Andy. Next action: run the preflight, then `DEPLOY.txt` steps 1–7 on UAT org 21.

Cross-link **both ways**: this item references Claude Nine **O25**, and O25's detail file gets a line pointing here.

- [ ] **Step 4: Report honestly**

State plainly: what was authored, that nothing was executed, that check 2 is blocked pending a Growyze COGS export, and the three preflight verdicts. Do not describe any of it as verified or working.

---

## Self-Review

**1. Spec coverage.** Spec §1 → Tasks 3/4 and the KPI/grid cards. §1.2 valuation → Task 4 Step 7 and check 7. §2 D1 → Task 8 Step 1 (billing totals). D2 → Task 4 Steps 4–5. D3 → Task 8 Step 3 (exceptions, no adjustments table anywhere). D4 → Task 12 Step 3. D5/D6 → Task 7 Step 5, Task 9 Step 1. D7 → Tasks 6–10 (12 cards, one dashboard). D8 → Task 4 reads the Data Vault, not `F_INV_COUNTS_DAY`. §4 columns → Task 3 Step 2. §4.1 derivations → Task 4 Step 9. §5.0 unbounded → Task 4 Step 3 and check 9's sibling constraint. §5.1 native names → Global Constraints, Task 4 Step 9, check in Task 12. §5.2 delivery type → Task 1 Step 1, Task 4 Step 6, check 9. §6 category/config → Tasks 4 Step 8 and 5. §7 cards → Tasks 6–9. §7.1 filters → Task 9. §7.2 contracts → Task 1 Steps 4–5 and Global Constraints. §7.3 comparison → Task 7 Step 2. §8 checks 1–9 → Task 2. §9 deployment → Task 11. §10 risks → surfaced in Task 1 (1–3), Task 8 Step 2 (5), Task 12 (7). §11 out of scope → nothing in any task builds an adjustments table, a barcode column, or cross-database rollup.

Gap found and closed: spec §4 lists `ITEM_NAME` only implicitly; Task 3 Step 2 adds it to the DDL explicitly and Task 4 Step 9 populates it, so the item grid needs no render-time join.

**2. Placeholder scan.** Two intentional `<...>` placeholders remain and both are unavoidable environment values a human must supply: `@OrgId` / `@DbPrefix` in Task 10 Step 1, and the `PREFLIGHT.md` verdict slots in Task 1, which are findings to be discovered rather than content to be invented. Task 2 Step 10's `...` is explicitly called out as something the implementer must write in full. No "TBD", no "add error handling", no "similar to Task N".

**3. Type consistency.** Column names are identical across Task 3 (DDL), Task 4 (populate), Tasks 6–9 (read) and Task 2 (verify) — `COG_SPEND`, `COG_SOLD`, `CLOSING_VALUE`, `VARIANCE_VALUE`, `CONSUMPTION_QTY`, `REPORT_GROUP`, `PERIOD_LABEL`, `PERIOD_MONTH`, `IS_FIRST_PERIOD`. Dataset names are identical across Tasks 6–10 and Task 12's cross-check. `SAT_STOCKEVENT.UOM_QUANITY` keeps the source misspelling everywhere it appears.

**Deviations from the skill's default task template, and why:**
- **No commit steps.** Subagents do not commit in this workspace; verification is central (Task 12) and any commit is Andy's.
- **Test-first, but the test cannot be run while authoring.** There is no SQL unit-test harness and this session has no database access, so Task 2 writes the PASS/FAIL script first and its first execution is at deploy step 1, where it is *expected* to fail.
- **One worked example per card family rather than 15 literal queries.** Tasks 6–9 give complete SQL for every distinct query shape; where two queries differ only in the measure (the four KPIs) the plan tabulates the substitutions instead of repeating the block.
