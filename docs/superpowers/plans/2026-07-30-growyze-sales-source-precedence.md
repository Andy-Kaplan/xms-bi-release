# Growyze Sales Source Precedence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Growyze dashboard pack's sales cards read POS sales where the organisation has a POS integration mapped, fall back to Growyze sales otherwise, and render empty when neither has data.

**Architecture:** A two-tier source resolver expressed as a CTE prepended to each sales vis query. It joins the organisation's own `sys.schemas` to `core.core.Integrations` — a provisioned `int_*` schema is that org's record of a mapped integration. The fact is then inner-joined to the resolved source set. No fact-build changes, no per-org configuration, no reload: vis queries take effect at the next card render.

**Tech Stack:** T-SQL on SQL Server Managed Instance (UAT). Idempotent `MERGE` upserts into `core.core.VisualisationQueries`. Verification by read-only MCP queries (`mcp__xms-bi-uat__query`, `database='core'`, three-part names) and `Invoke-Sqlcmd` for anything needing `EXEC`.

**Spec:** `docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md`
**Ledger:** O5. **Branch:** `worktree-growyze-dashboards-o5` (worktree `.claude/worktrees/growyze-dashboards-o5`).

## Global Constraints

- Claude may only create or edit `.sql` files inside `ClaudeDevelopment/`. All other `.sql` files are read-only.
- Saved scripts must use **two-part** table names — never hardcode a client database name. Three-part prefixes are for MCP test runs only.
- Control-table writes must be idempotent: `MERGE` on the natural key `(DataSetName, VisualizationType)`. Never a bare `INSERT`.
- **No reload or presentation rebuild is required.** Vis queries are read at card render time. Do not run `sp_DataVaultLoad` or `sp_ProcessPresentation` for this work.
- **Never filter `BOTTOM_LEVEL_NAME = 'Product'`** — it is `'Product'` for Growyze but `'BOTTOM'` for Mews/NCRAloha, so it silently drops every POS product.
- Category expression is exactly `COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])`.
- Keep `F.LI_TYPE = 'PROD'` and `F.NET_VALUE > 0` on line-item queries.
- Always `CAST(F.[ORDER_DATE] AS DATE)` when joining `CALENDAR` — `ORDER_DATE` is `datetime2` and POS sources carry times.
- Never repurpose `MICROSERVICE_NAME` to carry a category or grouping; it is the MDM display-name resolver.
- MCP `query` accepts only `SELECT`/`WITH` and rejects SQL comments — strip `--` and `/* */` from test queries.
- UAT only. Prod deployment is human-run via the PowerShell runner.
- Environment variables for `Invoke-Sqlcmd`: `XMS_BI_MANAGED_UAT_SERVER` / `_USER` / `_PASSWORD`; append `,3342` to the server, use `-TrustServerCertificate -QueryTimeout 0`.

## Organisation reference (UAT)

| Org | ID | Database |
|---|---|---|
| Padel Social | 10 | `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14` |
| The Oak & Vine | 16 | `20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87` |
| Dirty Sixth | 18 | `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A` |
| Ibis Heathrow | 20 | `20260722_XMS_7CE02464-9A7E-F111-B337-002248A1EC3D` |
| Ibis Gloucester Road | 21 | `20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D` |

## File Structure

| File | Responsibility |
|---|---|
| `ClaudeDevelopment/integrations/Growyze/reporting_queries/39_growyze_cost_kpis.sql` | **Modify.** `GrowyzeProfit` + `GrowyzeProfitPct`. Replaces the hardcoded `product.BOTTOM_SRC = 'int_growyze001'` predicate with the resolver join. |
| `ClaudeDevelopment/integrations/Growyze/reporting_queries/40_growyze_sales_by_category.sql` | **Modify.** `GrowyzeSalesByCategory`. Resolver join on `F.SRC`, category grain moved from `MIDDLE_1` to `TOP`, matching `ProductCategories` filter change. |
| `ClaudeDevelopment/integrations/Growyze/reporting_queries/41_verify_sales_precedence.sql` | **Create.** Read-only per-org verification with baselines recorded in its header. |
| `docs/outstanding/O5-growyze-default-dashboards.md` | **Modify.** Progress log + pick-up notes. |
| `ClaudeDevelopment/QUERY_STATUS.md` | **Modify.** Update entries 94/95, add entry 99 for script 41. |

**Why modify 39/40 in place rather than adding a new script:** both are idempotent `MERGE`s keyed on the dataset. A separate "precedence" script would leave 39/40 as live landmines — re-running either would silently revert precedence. One script per dataset keeps a single source of truth.

## The resolver (used verbatim throughout)

Plain form, for verification queries:

```sql
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
```

Embedded form, inside an `N'...'` string literal (every single quote doubled):

```
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
```

Expected resolution: Padel(10) and Dirty Sixth(18) → `int_growyze001`; Oak & Vine(16) → `int_ncraloha001` + `int_mews001`; Ibis Heathrow(20) and Gloucester(21) → `int_mews001`.

---

### Task 1: Confirm the resolver runs through a real card stored procedure

Proves two mechanisms in one shot before any dataset is changed: the cross-database read to `core.core.Integrations` works from inside an org database, and a leading `WITH` CTE survives the card SP's `REPLACE` + `sp_executesql` composition. Also captures the regression baselines Task 4 asserts against.

**Files:**
- Create: none (throwaway probe executed directly)

**Interfaces:**
- Consumes: nothing
- Produces: the confirmed resolver text reused verbatim in Tasks 2 and 3; baseline figures reused in Task 4.

- [ ] **Step 1: Run the resolver standalone against all 5 orgs**

MCP `query`, `database='core'`. Comments stripped. Three-part names because this is a test run:

```sql
WITH r AS (
SELECT 'Padel(10)' AS org, i.SchemaName, i.IntegrationType
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].sys.schemas s
JOIN [core].[core].[Integrations] i ON s.name = i.SchemaName
UNION ALL
SELECT 'OakVine(16)', i.SchemaName, i.IntegrationType
FROM [20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87].sys.schemas s
JOIN [core].[core].[Integrations] i ON s.name = i.SchemaName
UNION ALL
SELECT 'DirtySixth(18)', i.SchemaName, i.IntegrationType
FROM [20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A].sys.schemas s
JOIN [core].[core].[Integrations] i ON s.name = i.SchemaName
UNION ALL
SELECT 'IbisHeathrow(20)', i.SchemaName, i.IntegrationType
FROM [20260722_XMS_7CE02464-9A7E-F111-B337-002248A1EC3D].sys.schemas s
JOIN [core].[core].[Integrations] i ON s.name = i.SchemaName
UNION ALL
SELECT 'IbisGloucester(21)', i.SchemaName, i.IntegrationType
FROM [20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D].sys.schemas s
JOIN [core].[core].[Integrations] i ON s.name = i.SchemaName
)
SELECT org,
       CASE WHEN MAX(CASE WHEN IntegrationType='POS' THEN 1 ELSE 0 END) = 1
            THEN 'POS' ELSE 'int_growyze001' END AS resolved_tier,
       STRING_AGG(CASE WHEN IntegrationType='POS' THEN SchemaName END, ', ') AS pos_schemas
FROM r GROUP BY org ORDER BY org
```

Expected: Padel and Dirty Sixth `int_growyze001` with NULL pos_schemas; Oak & Vine `POS` with `int_ncraloha001, int_mews001`; both Ibis `POS` with `int_mews001`.

- [ ] **Step 2: Prove a CTE-prefixed template renders through the real card SP**

Temporarily register a throwaway dataset, execute it via `SingleKPICard`, then remove it. This must go through `Invoke-Sqlcmd` because MCP `query` cannot `EXEC`. Run from PowerShell:

```powershell
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue
$server=[Environment]::GetEnvironmentVariable('XMS_BI_MANAGED_UAT_SERVER')
if ($server -notmatch ',\d+$' -and $server -match '\.public\.') { $server="$server,3342" }
$u=[Environment]::GetEnvironmentVariable('XMS_BI_MANAGED_UAT_USER')
$p=[Environment]::GetEnvironmentVariable('XMS_BI_MANAGED_UAT_PASSWORD')
$reg = @'
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'ZZProbePrecedence', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET Status = N'LIVE'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'ZZProbePrecedence', N'SingleKPICard', 1, N'LIVE',
N'WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT N''Probe'' AS Title, STRING_AGG(SRC, N'','') AS Value
FROM sales_src
WHERE 1=1
@FilterClause;',
N'{}', GETDATE(), N'probe-o5');
'@
Invoke-Sqlcmd -ServerInstance $server -Database 'core' -Username $u -Password $p -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true -Query $reg
foreach ($db in @('20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14','20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87')) {
  Write-Host "--- $db ---"
  Invoke-Sqlcmd -ServerInstance $server -Database $db -Username $u -Password $p -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true `
    -Query "EXEC [core].[SingleKPICard] @DataSet = N'ZZProbePrecedence';" | Format-Table -AutoSize | Out-String -Width 200
}
```

Expected: Padel returns `Value = int_growyze001`; Oak & Vine returns `int_ncraloha001,int_mews001` (order may vary). **No** "could not be bound", permission, or syntax error.

**If this step fails**, stop and report — the fallback (a per-org helper view) was explicitly declined during design and needs Andy's decision. Do not improvise.

- [ ] **Step 3: Remove the probe dataset**

```powershell
Invoke-Sqlcmd -ServerInstance $server -Database 'core' -Username $u -Password $p -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true `
  -Query "DELETE FROM [core].[core].[VisualisationQueries] WHERE DataSetName = N'ZZProbePrecedence';"
```

Then confirm it is gone (MCP `query`):

```sql
SELECT COUNT(*) AS probe_rows FROM [core].[core].[VisualisationQueries] WHERE DataSetName = N'ZZProbePrecedence'
```

Expected: `0`. Leaving a probe dataset registered would put a junk entry in the dataset list.

- [ ] **Step 4: Capture the regression baselines**

MCP `query`. Record the output — Task 4 asserts these are unchanged:

```sql
SELECT 'Padel(10)' AS org,
       CAST(SUM(F.PROFIT) AS DECIMAL(18,2)) AS profit,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_value,
       CAST(SUM(F.PROFIT)*100.0/NULLIF(SUM(F.NET_VALUE),0) AS DECIMAL(6,1)) AS profit_pct,
       COUNT(*) AS rows_
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE)=C.[DATE]
LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID=location.BOTTOM_HUB_ID
LEFT JOIN [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID=product.BOTTOM_HUB_ID
WHERE F.NET_VALUE > 0 AND product.[BOTTOM_SRC]='int_growyze001' AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown'
UNION ALL
SELECT 'DirtySixth(18)',
       CAST(SUM(F.PROFIT) AS DECIMAL(18,2)), CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)),
       CAST(SUM(F.PROFIT)*100.0/NULLIF(SUM(F.NET_VALUE),0) AS DECIMAL(6,1)), COUNT(*)
FROM [20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A].[presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A].[presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE)=C.[DATE]
LEFT JOIN [20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A].[presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID=location.BOTTOM_HUB_ID
LEFT JOIN [20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A].[presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID=product.BOTTOM_HUB_ID
WHERE F.NET_VALUE > 0 AND product.[BOTTOM_SRC]='int_growyze001' AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown'
```

Expected (measured 2026-07-30): Padel £144,248.29 / £178,464.46 / 80.8% / 7,489 rows. Dirty Sixth £317,414.99 / £405,110.80 / 78.4% / 12,906 rows. If these differ, a load has run since — record the new values and use those as the baseline.

- [ ] **Step 5: Commit the confirmation**

Nothing to commit in code; record the outcome in the task notes and proceed. If you prefer a paper trail:

```bash
git commit --allow-empty -m "test(growyze): confirm CTE resolver renders through SingleKPICard cross-database (O5)"
```

---

### Task 2: Retrofit GrowyzeProfit and GrowyzeProfitPct to the resolver

**Files:**
- Modify: `ClaudeDevelopment/integrations/Growyze/reporting_queries/39_growyze_cost_kpis.sql`

**Interfaces:**
- Consumes: the embedded-form resolver confirmed in Task 1.
- Produces: `GrowyzeProfit` and `GrowyzeProfitPct` (both `SingleKPICard`) returning `Title`, `Value` — 2 columns, 1 row. Task 4 verifies them.

- [ ] **Step 1: Confirm the current (pre-change) behaviour is wrong on POS orgs**

MCP `query` — the current hardcoded form, run against Oak & Vine:

```sql
SELECT CAST(SUM(F.PROFIT) AS DECIMAL(18,2)) AS profit, COUNT(*) AS rows_
FROM [20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87].[presentation].[F_PRODUCT_MARGIN_DAY] F
LEFT JOIN [20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87].[presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID=product.BOTTOM_HUB_ID
WHERE F.NET_VALUE > 0 AND product.[BOTTOM_SRC]='int_growyze001'
```

Expected: `profit` NULL, `rows_` 0 — the defect this task fixes.

- [ ] **Step 2: Replace the hardcoded source predicate in both MERGE branches of both datasets**

In `39_growyze_cost_kpis.sql` there are **4** occurrences of this exact pair of lines (MATCHED + NOT MATCHED, for each of the two datasets):

```
WHERE 1=1 AND F.NET_VALUE > 0
AND product.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
```

Replace each with:

```
WHERE 1=1 AND F.NET_VALUE > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
```

And add the resolver join immediately after the `D_PRODUCT` join line. There are 4 occurrences of:

```
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
```

Replace each with:

```
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
```

Then prefix each of the 4 `QueryTemplate` literals with the embedded-form resolver. Each template currently starts:

```
N'SELECT
    N''Profit'' AS Title,
```

becomes:

```
N'WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT
    N''Profit'' AS Title,
```

(and identically for the two `N''Profit %''` templates).

- [ ] **Step 3: Update the script header to describe the new behaviour**

Replace the `*** SOURCE SCOPING ADDED 2026-07-30 (O5 pick-up) ***` block with:

```
-- *** SOURCE PRECEDENCE 2026-07-30 (O5) ***
-- Spec: docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md
-- Sales source is resolved per organisation, not hardcoded: every POS integration
-- mapped to the org wins; Growyze is the fallback; no match renders empty.
-- The resolver joins the org's own sys.schemas to core.core.Integrations - a
-- provisioned int_* schema IS that org's record of a mapped integration. Same
-- idiom as the LIVE `Integrations` FilterList. F_PRODUCT_MARGIN_DAY has no SRC
-- column, so precedence is applied via product.[BOTTOM_SRC].
-- Expected: Padel/Dirty Sixth unchanged (no POS mapped => Growyze); Oak & Vine
-- and the Ibis hotels switch from empty to their POS sales.
-- Baselines that must NOT move: Padel GBP 144,248.29 profit / 80.8% over 7,489
-- rows; Dirty Sixth GBP 317,414.99 / 78.4% over 12,906 rows.
```

- [ ] **Step 4: Deploy to UAT**

```powershell
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue
$server=[Environment]::GetEnvironmentVariable('XMS_BI_MANAGED_UAT_SERVER')
if ($server -notmatch ',\d+$' -and $server -match '\.public\.') { $server="$server,3342" }
$u=[Environment]::GetEnvironmentVariable('XMS_BI_MANAGED_UAT_USER')
$p=[Environment]::GetEnvironmentVariable('XMS_BI_MANAGED_UAT_PASSWORD')
Invoke-Sqlcmd -ServerInstance $server -Database 'core' -Username $u -Password $p `
  -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true `
  -InputFile "ClaudeDevelopment/integrations/Growyze/reporting_queries/39_growyze_cost_kpis.sql"
```

Expected: completes with no error and prints `Task 2: GrowyzeProfit + GrowyzeProfitPct deployed.`

- [ ] **Step 5: Verify both KPIs through the real card SP on 3 orgs**

```powershell
foreach ($db in @('20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14','20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87','20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D')) {
  foreach ($ds in @('GrowyzeProfit','GrowyzeProfitPct')) {
    Write-Host "--- $ds @ $db ---"
    Invoke-Sqlcmd -ServerInstance $server -Database $db -Username $u -Password $p `
      -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true `
      -Query "EXEC [core].[SingleKPICard] @DataSet = N'$ds';" | Format-Table -AutoSize | Out-String -Width 200
  }
}
```

Expected: Padel `£144,248` / `80.8%` (**unchanged** — the regression gate); Oak & Vine a large positive £ figure with a plausible percentage; Gloucester a positive £ figure. No errors.

- [ ] **Step 6: Commit**

```bash
git add ClaudeDevelopment/integrations/Growyze/reporting_queries/39_growyze_cost_kpis.sql
git commit -m "feat(growyze): resolve sales source per org for GrowyzeProfit/GrowyzeProfitPct (O5)"
```

---

### Task 3: Retrofit GrowyzeSalesByCategory to the resolver and TOP_NAME grain

**Files:**
- Modify: `ClaudeDevelopment/integrations/Growyze/reporting_queries/40_growyze_sales_by_category.sql`

**Interfaces:**
- Consumes: the embedded-form resolver confirmed in Task 1.
- Produces: `GrowyzeSalesByCategory` (`PieChartCard`) returning result set 1 with `Label, Value, Id, Curve, Stack, Area, StackOrder, ShowMark, LegendLabel` and result set 2 with `Title, Description, Trend, Chip, PiePrimaryText, PieSecondaryText`.

- [ ] **Step 1: Confirm the TOP_NAME grain gives sensible categories on each source**

MCP `query`:

```sql
SELECT p.BOTTOM_SRC, COALESCE(p.TOP_MICROSERVICE_NAME, p.TOP_NAME) AS category,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_sales
FROM [20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87].[presentation].[F_LINEITEM_15MIN] F
JOIN [20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87].[presentation].[D_PRODUCT] p ON F.PRODUCT_HUB_ID=p.BOTTOM_HUB_ID
WHERE F.LI_TYPE='PROD' AND F.NET_VALUE > 0
GROUP BY p.BOTTOM_SRC, COALESCE(p.TOP_MICROSERVICE_NAME, p.TOP_NAME)
ORDER BY net_sales DESC
```

Expected: NCRAloha rows under `Food` / `Drinks`; Mews rows under `Spirits`, `Wine`, `Soft Drinks`, `Hot Drinks`, `Bottled Beer`, `Breakfast`, `Food`. No individual product names.

- [ ] **Step 2: Change the category grain from MIDDLE_1 to TOP in both MERGE branches**

In `40_growyze_sales_by_category.sql`, replace **every** occurrence of

```
COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])
```

with

```
COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
```

There are 8 occurrences in the two `QueryTemplate` literals (`Label`, `Id`'s `ORDER BY`, the `<> ''Unknown''` guard, and `GROUP BY` — ×2 branches).

Also update the `ProductCategories` filter in **both** `FilterDefinitions` JSON literals so the filter matches the new grouping. Replace

```
"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"}
```

with

```
"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"}
```

- [ ] **Step 3: Add the resolver join and prefix, in both branches**

Replace both occurrences of

```
AND F.SRC = ''int_growyze001''
```

with nothing (delete the line), and replace both occurrences of

```
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
```

with

```
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
```

Then prefix both `QueryTemplate` literals with the embedded-form resolver, so each starts:

```
N'WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT
    COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS Label,
```

- [ ] **Step 4: Terminate the first statement before the header SELECT**

The template contains two statements. With a CTE now leading, add an explicit `;` so the parser cannot mis-associate them. In both branches change

```
GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])

SELECT
    ''Sales by Category'' AS Title,
```

to

```
GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]);

SELECT
    ''Sales by Category'' AS Title,
```

- [ ] **Step 5: Update the script header**

Replace the `*** TWO FIXES ADDED 2026-07-30 (O5 pick-up) ***` block with:

```
-- *** SOURCE PRECEDENCE + TOP_NAME GRAIN 2026-07-30 (O5) ***
-- Spec: docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md
-- 1. Sales source resolved per org (POS wins, Growyze falls back, else empty) via
--    the sys.schemas -> core.core.Integrations resolver. F_LINEITEM_15MIN carries
--    SRC, so the join is on F.[SRC] directly.
-- 2. Category grain moved MIDDLE_1 -> TOP. The correct level differs by source:
--    Mews MIDDLE_1 holds product families (Peroni, Pinot Grigio) while TOP holds
--    real categories (Spirits, Wine, ... 12 of them); Growyze TOP == MIDDLE_1;
--    NCRAloha TOP is coarse (Food/Drinks) - the same grain the card this replaces,
--    OakVineMenuFoodDrinksSplit, already hardcoded, so no regression.
--    ProductCategories in FilterDefinitions moved to TOP to match the grouping.
-- 3. CALENDAR join keeps CAST(ORDER_DATE AS DATE) - POS sources carry times.
-- Do NOT filter BOTTOM_LEVEL_NAME = 'Product': it is 'Product' for Growyze but
-- 'BOTTOM' for Mews/NCRAloha, and would drop every POS product.
```

- [ ] **Step 6: Deploy and verify through the real card SP**

```powershell
Invoke-Sqlcmd -ServerInstance $server -Database 'core' -Username $u -Password $p `
  -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true `
  -InputFile "ClaudeDevelopment/integrations/Growyze/reporting_queries/40_growyze_sales_by_category.sql"
foreach ($db in @('20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14','20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87','20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D')) {
  Write-Host "--- GrowyzeSalesByCategory @ $db ---"
  Invoke-Sqlcmd -ServerInstance $server -Database $db -Username $u -Password $p `
    -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true `
    -Query "EXEC [core].[PieChartCard] @DataSet = N'GrowyzeSalesByCategory';" | Format-Table -AutoSize | Out-String -Width 200
}
```

Expected: Padel shows `Beverages`, `Retail`, `Food`, `Other`, `Uncategorised`; Oak & Vine shows NCRAloha `Food`/`Drinks` plus the Mews categories; Gloucester shows Mews categories. No product names, no errors.

- [ ] **Step 7: Commit**

```bash
git add ClaudeDevelopment/integrations/Growyze/reporting_queries/40_growyze_sales_by_category.sql
git commit -m "feat(growyze): resolve sales source per org + TOP_NAME grain for GrowyzeSalesByCategory (O5)"
```

---

### Task 4: Verification script and full per-org verification

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/41_verify_sales_precedence.sql`

**Interfaces:**
- Consumes: `GrowyzeProfit`, `GrowyzeProfitPct`, `GrowyzeSalesByCategory` from Tasks 2 and 3; baselines from Task 1 Step 4.
- Produces: a re-runnable verifier for future Plan 2 cards.

- [ ] **Step 1: Write the verification script**

Create `41_verify_sales_precedence.sql`. It runs against a **target organisation database** with two-part names:

```sql
/* ============================================================================
   Growyze sales source precedence - VERIFICATION (read-only)
   Ledger: O5.  Spec: docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md
   Run against the target ORGANISATION database (two-part names throughout).

   Rule: every POS integration mapped to the org wins; Growyze is the fallback;
   no match renders empty.

   EXPECTED per org (UAT, 2026-07-30):
     Padel Social (10) ...... int_growyze001 . profit 144,248.29 / 80.8% / 7,489
     Dirty Sixth (18) ....... int_growyze001 . profit 317,414.99 / 78.4% / 12,906
     Oak & Vine (16) ........ int_ncraloha001 + int_mews001 . net 1,420,927.46
     Ibis Gloucester (21) ... int_mews001 .... net 33,144.54
     Ibis Heathrow (20) ..... int_mews001 .... 0 rows (mapped, no data) - PASS
   Padel and Dirty Sixth are the REGRESSION GATE: their figures must not move.
   ============================================================================ */

/* -- A: what the resolver picks for this org ----------------------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'A1_resolved_source' AS check_name,
       STRING_AGG(SRC, ', ') AS resolved_sources,
       CASE WHEN EXISTS (SELECT 1 FROM org_pos) THEN 'POS tier' ELSE 'Growyze fallback tier' END AS tier
FROM sales_src;

/* -- B: sales the cards will report -------------------------------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'B1_lineitem_sales' AS check_name,
       F.[SRC],
       COUNT(*) AS rows_,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_sales,
       MIN(CAST(F.ORDER_DATE AS DATE)) AS min_d,
       MAX(CAST(F.ORDER_DATE AS DATE)) AS max_d
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
WHERE F.LI_TYPE = 'PROD' AND F.NET_VALUE > 0
GROUP BY F.[SRC];

/* -- C: margin measures (GrowyzeProfit / GrowyzeProfitPct) --------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'C1_margin_kpis' AS check_name,
       CAST(SUM(F.PROFIT) AS DECIMAL(18,2)) AS profit,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_value,
       CAST(SUM(F.PROFIT)*100.0/NULLIF(SUM(F.NET_VALUE),0) AS DECIMAL(6,1)) AS profit_pct,
       COUNT(*) AS rows_
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE F.NET_VALUE > 0 AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown';

/* -- D: category set the pie will show ----------------------------------- */
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N'int_growyze001' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT 'D1_category_set' AS check_name,
       COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS category,
       CAST(SUM(F.NET_VALUE) AS DECIMAL(18,2)) AS net_sales
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
WHERE F.LI_TYPE = 'PROD' AND F.NET_VALUE > 0
  AND COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) <> 'Unknown'
  AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown'
GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
ORDER BY net_sales DESC;

/* -- E: negative check - no cross-tier leakage ---------------------------
   On a POS org, zero Growyze rows may reach the result. */
SELECT 'E1_no_tier_leak' AS check_name,
       SUM(CASE WHEN F.[SRC] = 'int_growyze001' THEN 1 ELSE 0 END) AS growyze_rows,
       CASE WHEN EXISTS (SELECT 1 FROM sys.schemas s
                         JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
                         WHERE i.[IntegrationType] = 'POS')
                 AND SUM(CASE WHEN F.[SRC] = 'int_growyze001' THEN 1 ELSE 0 END) > 0
            THEN 'FAIL - Growyze rows on a POS org'
            ELSE 'PASS' END AS verdict
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN (
    SELECT i.[SchemaName] AS SRC
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = 'POS'
    UNION ALL
    SELECT N'int_growyze001'
    WHERE NOT EXISTS (SELECT 1 FROM sys.schemas s2
                      JOIN [core].[core].[Integrations] i2 ON s2.name = i2.[SchemaName]
                      WHERE i2.[IntegrationType] = 'POS')
) ss ON ss.SRC = F.[SRC]
WHERE F.LI_TYPE = 'PROD';
```

- [ ] **Step 2: Run the verifier against all 5 orgs**

```powershell
foreach ($db in @('20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14','20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87','20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A','20260722_XMS_7CE02464-9A7E-F111-B337-002248A1EC3D','20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D')) {
  Write-Host "=== $db ==="
  Invoke-Sqlcmd -ServerInstance $server -Database $db -Username $u -Password $p `
    -TrustServerCertificate -QueryTimeout 0 -OutputSqlErrors $true `
    -InputFile "ClaudeDevelopment/integrations/Growyze/reporting_queries/41_verify_sales_precedence.sql" `
    | Format-Table -AutoSize | Out-String -Width 220
}
```

Expected, per the script header. Specifically: **Padel and Dirty Sixth C1 figures must equal the Task 1 Step 4 baselines exactly**; Oak & Vine B1 must list both POS sources; Ibis Heathrow returns no sales rows without error; every `E1_no_tier_leak` verdict is `PASS`.

- [ ] **Step 3: If the regression gate moved, stop**

If Padel or Dirty Sixth profit/net-value differ from the baseline, the retrofit changed Growyze-only orgs, which it must not. Do not proceed — diagnose first. The likeliest cause is the resolver's `NOT EXISTS` branch not firing, so check `A1_resolved_source` shows `Growyze fallback tier` on those two orgs.

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/integrations/Growyze/reporting_queries/41_verify_sales_precedence.sql
git commit -m "test(growyze): per-org verification for sales source precedence (O5)"
```

---

### Task 5: Sync documentation

**Files:**
- Modify: `docs/outstanding/O5-growyze-default-dashboards.md`
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`

**Interfaces:**
- Consumes: verification results from Task 4.
- Produces: nothing consumed downstream.

- [ ] **Step 1: Add an O5 progress-log entry**

Insert immediately before the `## Pick-up notes (resume here)` heading. Record: the precedence rule and its three tiers; that Oak & Vine's two POS sources are sequential (a migration, zero month overlap) so all POS sources are kept; the per-org outcomes actually measured in Task 4; the Padel/Dirty Sixth regression gate result; and the `BREAKFAST ADJUSTMENT` flag (£42,223.26 of £55,221.06 Oak & Vine Mews PROD sales) as an open data-quality question.

- [ ] **Step 2: Update the O5 pick-up notes**

Add: Plan 2's remaining cards must use the resolver and obey the three portability rules (no `BOTTOM_LEVEL_NAME='Product'` filter, `TOP_NAME` category grain, `CAST(ORDER_DATE AS DATE)` on `CALENDAR`). Note the earlier "Plan 3 needs a scoping decision" item is now **resolved** — precedence means the pack can go to all five orgs, with Ibis Heathrow legitimately empty until Mews data lands.

- [ ] **Step 3: Update QUERY_STATUS entries 94 and 95, and add entry 99**

Amend entries 94 (`39_growyze_cost_kpis.sql`) and 95 (`40_growyze_sales_by_category.sql`) to state they now resolve source precedence per org rather than hardcoding `int_growyze001`, with the measured per-org outcomes. Add entry **99** for `41_verify_sales_precedence.sql` describing its five sections and the regression gate.

- [ ] **Step 4: Commit**

```bash
git add docs/outstanding/O5-growyze-default-dashboards.md ClaudeDevelopment/QUERY_STATUS.md
git commit -m "docs(o5): record sales source precedence deployment and verification"
```

---

## Self-Review

**Spec coverage:**

| Spec section | Task |
|---|---|
| §3.1 resolver | Task 1 (confirm), Tasks 2–3 (apply) |
| §3.2 two join variants | Task 2 (margin, `product.BOTTOM_SRC`), Task 3 (line-item, `F.SRC`) |
| §3.3 rule 1 no `BOTTOM_LEVEL_NAME` filter | Global Constraints; Task 3 Step 5 header |
| §3.3 rule 2 `TOP_NAME` category | Task 3 Steps 1–2 |
| §3.3 rules 3–4 `PROD`/`NET_VALUE>0`/`CAST` | Preserved in Tasks 2–3; Global Constraints |
| §3.3 rules 5–6 ParameterMappings / MICROSERVICE_NAME | Global Constraints (no change needed — no date filter is added here) |
| §3.4 expected per org | Task 4 Step 2 |
| §4 retrofit all three datasets | Tasks 2–3 |
| §4 smoke test | Task 1 Step 2 |
| §5 regression + new-coverage + resolver + negative checks | Task 4 Steps 1–3 (sections A–E) |
| §6 risk 1 permission/composition | Task 1 Step 2, with an explicit stop-and-report |
| §6 risk 3 BREAKFAST ADJUSTMENT | Task 5 Step 1 (recorded, out of scope to fix) |

No spec requirement is unimplemented. §4's "apply to Plan 2's sales cards" is deliberately not a task here — those cards do not exist yet; Task 5 Step 2 records the requirement for Plan 2.

**Placeholder scan:** No TBD/TODO. Every code step carries literal SQL or PowerShell. Task 5's steps describe document content rather than quoting final prose, which is appropriate for prose whose content depends on Task 4's measured results — the required facts are enumerated explicitly.

**Type/name consistency:** The CTE names `org_pos` and `sales_src` and the alias `ss` are identical in Tasks 1, 2, 3 and 4. The join column is `ss.SRC` throughout, matched against `F.[SRC]` for `F_LINEITEM_15MIN` and `product.[BOTTOM_SRC]` for `F_PRODUCT_MARGIN_DAY`. Card SP names are `[core].[SingleKPICard]` and `[core].[PieChartCard]`, both invoked with `@DataSet`. Dataset names `GrowyzeProfit`, `GrowyzeProfitPct`, `GrowyzeSalesByCategory` match those deployed on 2026-07-30.

**One correction folded in from research:** the spec originally rated cross-database permission the highest risk. Checking established that card SPs already read `core.core.VisualisationQueries` on every render and that `core` has no least-privilege app principal, so the risk is near-zero. Task 1 Step 2 remains as confirmation rather than a gate, and the spec's §6 was amended accordingly.
