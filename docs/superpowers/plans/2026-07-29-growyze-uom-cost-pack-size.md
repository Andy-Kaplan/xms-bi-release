# Growyze `UOM_COST` Pack-Size Normalisation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Divide Growyze inventory cost by pack size at staging so `SAT_INVITEM.UOM_COST` becomes cost-per-`measure`-unit, removing a ~93× inflation across all Growyze cost, margin and GP% figures.

**Architecture:** A single expression change inside one `StagingControl` row's `query_sql`, delivered as an idempotent MERGE upsert script. The presentation layer is untouched — its existing `/ conversion_factor` division then correctly carries measure→standardised base unit. Staging removes the pack; presentation removes the unit scale.

**Tech Stack:** SQL Server Managed Instance (T-SQL), PowerShell `Invoke-Sqlcmd` runners, MCP `query`/`execute` for verification.

**Spec:** `docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md`

## Global Constraints

- Claude may only create or edit `.sql` files inside `ClaudeDevelopment/`. All other `.sql` files in the repo are read-only.
- Scripts must use **unqualified two-part** table names (`[datavault].[HUB_PRODUCT]`), never a hardcoded client database name. Three-part naming is for MCP test queries only.
- All control-table writes use **MERGE upsert** on the natural key — never bare `INSERT`. `StagingControl`'s key here is `step_name`.
- MCP `query` is read-only and unrestricted; MCP `execute` is enabled on DEV/TEST/UAT only and has a **15-second request cap**. Anything longer (DV loads, presentation rebuilds) must go through a PowerShell runner.
- **Prod is never reachable via MCP** and is human-run only.
- MCP rejects SQL comments (`--`, `/* */`) — strip them from any query sent via MCP.
- Target environment for this plan is **UAT**. Test and Prod are follow-on, out of scope here.
- Verification org: **Ibis Gloucester Road**, OrgID 21, DB `20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D`.
- Regression org: **Padel Social** (MarketMan-sourced; its figures must not move).

## File Structure

| File | Responsibility |
|---|---|
| `ClaudeDevelopment/integrations/Growyze/19_invitem_uom_cost_pack_size.sql` | Create. The fix: MERGE upsert of the `Growyze Inventory Items` staging step with the pack-size division. |
| `ClaudeDevelopment/integrations/Growyze/20_verify_uom_cost_pack_size.sql` | Create. Read-only verification + data-quality flag queries. Separate file so it can be re-run any time without touching control tables. |
| `ClaudeDevelopment/integrations/Growyze/92_deploy_uom_cost_fix.ps1` | Create. Runner: deploys 19, then per-org staging → DV load → presentation rebuild. |
| `ClaudeDevelopment/QUERY_STATUS.md` | Modify. Add entries for scripts 19/20 and the runner. |
| `docs/outstanding/O5-growyze-default-dashboards.md` | Modify. Record the fix under the reopened blocker. |
| `docs/outstanding/O8-marge-brut-dashboard.md` | Modify. Clear gate (c). |

---

### Task 1: Capture the pre-change baseline

Establishes the before-figures the later tasks assert against, and confirms the deployed `query_sql` still matches expectations so the MERGE reverts nothing.

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/20_verify_uom_cost_pack_size.sql`

**Interfaces:**
- Produces: the verification script used by Tasks 3 and 4. Section A = drift guard, Section B = baseline/after totals, Section C = coverage, Section D = data-quality flags.

- [ ] **Step 1: Confirm the deployed staging step has not diverged**

Run via MCP `query` against `core` (comments stripped):

```sql
SELECT LEN(query_sql) AS Len_,
       CASE WHEN query_sql LIKE '%TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST%'
            THEN 'UNPATCHED (expected)' ELSE 'DIVERGED - STOP' END AS CostExpr,
       staging_columns
FROM [core].[int_growyze001].[StagingControl]
WHERE step_name = N'Growyze Inventory Items';
```

Expected: `Len_` = 1414, `CostExpr` = `UNPATCHED (expected)`, `staging_columns` = the 13-element list ending `"UOM_COST", "INVITEM_ID"`.

**If `CostExpr` says DIVERGED, STOP.** Someone changed the step since 2026-07-29; diff the live `query_sql` against `ClaudeDevelopment/cost-path-redesign/02_growyze_invitems_uom_cost.sql` and rebase this task's script on the live text before continuing.

- [ ] **Step 2: Record the baseline totals**

Run via MCP `query` against `core`:

```sql
SELECT COUNT(*) AS CountLines,
       CAST(SUM(c.ACTUAL_COUNT * c.UOM_COST) AS DECIMAL(18,2)) AS StockValue,
       SUM(CASE WHEN c.UOM_COST IS NULL THEN 1 ELSE 0 END) AS NullCost
FROM [20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D].presentation.F_INV_COUNTS_DAY c;
```

Expected baseline: `CountLines` = 151, `StockValue` = 762277.46, `NullCost` = 0. Write these into the script header as the recorded before-state.

- [ ] **Step 3: Write the verification script**

Create `ClaudeDevelopment/integrations/Growyze/20_verify_uom_cost_pack_size.sql`:

```sql
/* ============================================================================
   Growyze UOM_COST pack-size normalisation - VERIFICATION (read-only)
   Companion to 19_invitem_uom_cost_pack_size.sql.
   Run against the target ORGANISATION database (two-part names throughout).

   Recorded baseline - Ibis Gloucester Road, COUNT_DATE 2026-06-30, pre-fix:
     count lines = 151, stock value = 762,277.46, null costs = 0
   Required after-state:
     count lines = 151, stock value =   8,157.61, null costs = 0
   ============================================================================ */

/* -- SECTION A: headline reconciliation ---------------------------------- */
SELECT 'A1_stock_value' AS check_name,
       COUNT(*) AS count_lines,
       CAST(SUM(ACTUAL_COUNT * UOM_COST) AS DECIMAL(18,2)) AS stock_value,
       SUM(CASE WHEN UOM_COST IS NULL THEN 1 ELSE 0 END) AS null_cost_lines
FROM [presentation].[F_INV_COUNTS_DAY];

/* -- SECTION B: named-item spot checks ----------------------------------- */
SELECT 'B1_spot_check' AS check_name,
       d.BOTTOM_INVITEM_NAME AS item_name,
       c.STANDARDISED_UOM,
       c.ACTUAL_COUNT,
       CAST(c.UOM_COST AS DECIMAL(18,8)) AS uom_cost,
       CAST(c.ACTUAL_COUNT * c.UOM_COST AS DECIMAL(18,2)) AS line_value
FROM [presentation].[F_INV_COUNTS_DAY] c
LEFT JOIN [presentation].[D_INVITEM] d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
WHERE d.BOTTOM_INVITEM_NAME IN (N'Hendricks', N'SALAMI SLICED MILANO 500G',
                                N'ONE WATER STILLL GLASS')
ORDER BY d.BOTTOM_INVITEM_NAME;

/* -- SECTION C: cost coverage -------------------------------------------- */
SELECT 'C1_coverage' AS check_name,
       COUNT(*) AS leaf_items,
       SUM(CASE WHEN UOM_COST IS NULL THEN 1 ELSE 0 END) AS null_cost_items,
       CAST(MIN(UOM_COST) AS DECIMAL(18,8)) AS min_cost,
       CAST(MAX(UOM_COST) AS DECIMAL(18,8)) AS max_cost
FROM [datavault].[SAT_INVITEM]
WHERE CURRENT_FLAG = 1 AND BOTTOM_LEVEL = 1 AND SRC = 'int_growyze001';

/* -- SECTION D: data-quality flag (known residual, not a failure) --------
   Items whose measure says kg but whose size looks like grams. Post-fix these
   read ~1000x too LOW. Source-catalogue errors - report, do not "fix" in SQL. */
SELECT 'D1_suspect_kg_size' AS check_name,
       BOTTOM_INVITEM_NAME AS item_name,
       BOTTOM_ATTR_3 AS pack_unit,
       BOTTOM_ATTR_4 AS pack_size,
       BOTTOM_ATTR_5 AS pack_price
FROM [presentation].[D_INVITEM]
WHERE BOTTOM_LEVEL_NAME = N'Inventory Item'
  AND TRY_CAST(BOTTOM_ATTR_4 AS DECIMAL(38,10)) >= 100
ORDER BY TRY_CAST(BOTTOM_ATTR_4 AS DECIMAL(38,10)) DESC;
```

- [ ] **Step 4: Verify the script runs clean against current (pre-fix) data**

Run each section via MCP `query` with the org-DB prefix added to every table reference and comments stripped. Expected now: A1 = 151 / 762277.46 / 0; B1 shows Hendricks line_value ≈ 27655.60; C1 shows 0 null costs; D1 returns ROCKET WILD.

This proves the script works before it is used to judge the fix.

- [ ] **Step 5: Commit**

```bash
git add "ClaudeDevelopment/integrations/Growyze/20_verify_uom_cost_pack_size.sql"
git commit -m "test(growyze): verification SELECTs for UOM_COST pack-size fix"
```

---

### Task 2: Write the fix script

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/19_invitem_uom_cost_pack_size.sql`

**Interfaces:**
- Consumes: the drift confirmation from Task 1 Step 1.
- Produces: the deployable fix used by Task 3. Modifies exactly one row of `core.int_growyze001.StagingControl` (`step_name = N'Growyze Inventory Items'`).

- [ ] **Step 1: Write the script**

The `query_sql` below is the **live deployed text** with one expression changed. Only the leaf branch changes: `TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST` becomes `TRY_CAST(price AS DECIMAL(38,10)) / COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1) AS UOM_COST`. Everything else — including `size AS ATTR_4` and `CAST(price AS NVARCHAR(MAX)) AS ATTR_5`, which the verification script's Section D depends on — is byte-identical.

**Ruling (2026-07-29, Andy):** the statement text is declared **once** into `@sql` and referenced by both MERGE branches, rather than duplicated verbatim as the older `StagingControl` scripts do. This removes the copy-divergence trap structurally. Keep the `DECLARE`s and the `MERGE` in the **same batch** — a `GO` between them would discard the variables. Only one `GO`, at the end.

Create `ClaudeDevelopment/integrations/Growyze/19_invitem_uom_cost_pack_size.sql`:

```sql
/* ============================================================================
   Growyze Integration - INVITEM UOM_COST pack-size normalisation
   File:   19_invitem_uom_cost_pack_size.sql
   Date:   2026-07-29
   Target: [core].[int_growyze001].[StagingControl]  (step 'Growyze Inventory Items')
   Spec:   docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md

   Purpose:
     DL_PRODUCTS.price is the price PER PACK (e.g. GBP 23.24 per 700 ml bottle)
     while stock quantities are stored in BASE UNITS - the deployed count step
     stores quantity * size, and 14_dn_events_size_multiplier_fix.sql applies
     the same multiplier to deliveries. Cost never received the matching
     division, so F_INV_COUNTS_DAY multiplied per-ml quantities by a per-bottle
     price: Hendricks 1,190 ml x GBP 23.24 = GBP 27,655.60 against a true
     ~GBP 39.50. Whole-stocktake value inflated ~93x (762,277.46 -> 8,157.61).

     This divides price by pack size so UOM_COST means "cost per measure unit".
     The presentation layer is deliberately NOT changed - its existing
     "/ conversion_factor" division then carries measure -> standardised base
     unit. Staging removes the pack; presentation removes the unit scale.

   Divisor:
     COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1) mirrors the
     DN-events quantity idiom. Where size is missing/zero the quantity side
     leaves the value in packs, so cost must stay per-pack too (divide by 1).
     A bare NULLIF would null the cost of those items instead.

   Scope:
     StagingControl is ENVIRONMENT-WIDE - this corrects every Growyze org
     (Padel Social, Dirty Sixth included); their cost/GP% figures will move
     down toward correct. MarketMan is unaffected (BOMPrice, separate step).

   Safe: MERGE upsert on step_name - idempotent, re-runnable.
   ============================================================================ */

DECLARE @step_name NVARCHAR(200) = N'Growyze Inventory Items';

DECLARE @desc NVARCHAR(500) = N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category). UOM_COST = price / pack size (cost per measure unit).';

DECLARE @cols NVARCHAR(MAX) = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "UOM_COST", "INVITEM_ID"]';

DECLARE @sql NVARCHAR(MAX) = N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, TRY_CAST(price AS DECIMAL(38,10)) / COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1) AS UOM_COST, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;';

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (@step_name)) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_INVITEMS',
        query_sql        = @sql,
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = @desc,
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = @cols,
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (@step_name, N'GRYZ_INVITEMS', @sql, 1, N'Staging', 0,
            @desc, NULL, 3, 30, @cols, GETDATE(), GETDATE());
GO
```

- [ ] **Step 2: Verify the statement text is defined once and used by both branches**

```bash
F="ClaudeDevelopment/integrations/Growyze/19_invitem_uom_cost_pack_size.sql"
grep -c "DECLARE @sql NVARCHAR(MAX)" "$F"
grep -c "@sql" "$F"
grep -c "^GO$" "$F"
```

Expected: `1` (declared once), then `3` (one declaration + one reference per MERGE branch), then `1` (a single terminating `GO` — more than one would split the batch and discard the variables).

- [ ] **Step 3: Verify the new expression is present and the old one is gone**

```bash
F="ClaudeDevelopment/integrations/Growyze/19_invitem_uom_cost_pack_size.sql"
grep -c "COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1)" "$F"
grep -c "TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST" "$F"
grep -c "size AS ATTR_4" "$F"
```

Expected: `1`, then `0` (the un-divided expression must not survive anywhere), then `1` (`size AS ATTR_4` preserved — the verification script's Section D reads pack size from `D_INVITEM.BOTTOM_ATTR_4`).
- [ ] **Step 4: Commit**

```bash
git add "ClaudeDevelopment/integrations/Growyze/19_invitem_uom_cost_pack_size.sql"
git commit -m "fix(growyze): divide UOM_COST by pack size at staging"
```

---

### Task 3: Deploy to UAT and reload

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/92_deploy_uom_cost_fix.ps1`

**Interfaces:**
- Consumes: `19_invitem_uom_cost_pack_size.sql` (Task 2).
- Produces: reloaded `SAT_INVITEM` / `F_INV_COUNTS_DAY` for every Growyze org, which Task 4 verifies.

- [ ] **Step 1: Write the runner**

Mirrors `Mews/91_deploy_mews_uat.ps1` and `prod-baseline/90_deploy_baseline.ps1`. Create `ClaudeDevelopment/integrations/Growyze/92_deploy_uom_cost_fix.ps1`:

```powershell
# ============================================================================
# 92_deploy_uom_cost_fix.ps1 - Deploy the Growyze UOM_COST pack-size fix
# ============================================================================
# Deploys 19_invitem_uom_cost_pack_size.sql to {ENV} core, then re-runs
# staging + DV load + presentation rebuild for every Growyze-mapped org so
# the corrected cost propagates into SAT_INVITEM and the inventory facts.
#
# Spec: docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md
#
# Usage:
#   .\92_deploy_uom_cost_fix.ps1 -Environment UAT -WhatIf
#   .\92_deploy_uom_cost_fix.ps1 -Environment UAT
#   .\92_deploy_uom_cost_fix.ps1 -Environment UAT -OnlyOrg 21
# ============================================================================

[CmdletBinding()]
param(
    [Parameter()][ValidateSet('DEV','TEST','UAT')]
    [string]$Environment = 'UAT',
    [int]$OnlyOrg = 0,
    [switch]$WhatIf,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$server   = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_SERVER")
$user     = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_USER")
$password = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_PASSWORD")
if (-not $server -or -not $user -or -not $password) {
    throw "Missing env vars XMS_BI_MANAGED_${Environment}_SERVER / _USER / _PASSWORD."
}
if ($server -notmatch ',\d+$' -and $server -match '\.public\.') { $server = "$server,3342" }
if ($server -match 'prod') { throw "Refusing to run against a server whose name contains 'prod': $server" }

Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

$scriptDir = $PSScriptRoot
$fixScript = Join-Path $scriptDir '19_invitem_uom_cost_pack_size.sql'
if (-not (Test-Path $fixScript)) { throw "Missing script: $fixScript" }
$logPath = Join-Path $scriptDir ("deploy_UOMCOST_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -Path $logPath -Value $line -Encoding utf8
}

function Invoke-Sql {
    param([Parameter(Mandatory)][string]$Database, [string]$File, [string]$Query)
    $splat = @{
        ServerInstance = $server; Database = $Database
        Username = $user; Password = $password
        TrustServerCertificate = $true; QueryTimeout = 0
        ErrorAction = 'Stop'; OutputSqlErrors = $true
    }
    if ($File)  { $splat['InputFile'] = $File }
    if ($Query) { $splat['Query']     = $Query }
    Invoke-Sqlcmd @splat
}

Write-Log "=== Growyze UOM_COST pack-size fix ==="
Write-Log "Environment : $Environment"
Write-Log "Server      : $server"

$orgSql = @'
SELECT OrganisationID, OrganisationName, DatabaseName
FROM [core].[core].[Organisations] o
WHERE o.DatabaseStatus IN ('ACTIVE','FAILED')
  AND EXISTS (SELECT 1 FROM [core].[core].[OrganisationIntegrations] oi
              JOIN [core].[core].[Integrations] i ON i.IntegrationID = oi.IntegrationID
              WHERE oi.OrganisationID = o.OrganisationID
                AND i.SchemaName = 'int_growyze001' AND oi.IsEnabled = 1)
ORDER BY o.OrganisationID;
'@

$orgs = @(Invoke-Sql -Database 'core' -Query $orgSql)
if ($OnlyOrg -gt 0) { $orgs = @($orgs | Where-Object { $_.OrganisationID -eq $OnlyOrg }) }
if ($orgs.Count -eq 0) { throw "No Growyze-mapped organisations found." }
foreach ($o in $orgs) { Write-Log ("  org {0,-3} {1,-24} {2}" -f $o.OrganisationID, $o.OrganisationName, $o.DatabaseName) }

if ($WhatIf) {
    Write-Log '--- WHATIF: would deploy 19 to core, then reload each org above ---'
    return
}

if (-not $Force) {
    Write-Host "This corrects UOM_COST for ALL $($orgs.Count) Growyze org(s) - their cost/GP% figures WILL change." -ForegroundColor Yellow
    if ((Read-Host "Type DEPLOY to continue") -cne 'DEPLOY') { Write-Log 'Aborted.'; return }
}

Write-Log 'RUN   19_invitem_uom_cost_pack_size.sql [core]'
Invoke-Sql -Database 'core' -File $fixScript | Out-Null
Write-Log 'OK    control plane updated'

foreach ($o in $orgs) {
    Write-Log "RUN   reload [$($o.DatabaseName)] ($($o.OrganisationName))"
    try {
        Invoke-Sql -Database $o.DatabaseName `
            -Query "EXEC [core].[sp_DataVaultLoad] @SchemaList = N'int_growyze001';" | Out-Null
        Write-Log "OK    reload $($o.OrganisationName)"
    }
    catch {
        Write-Log "FAIL  reload $($o.OrganisationName): $($_.Exception.Message)"
        Write-Log '      -> sp_DataVaultLoad masks errors; check [core].[LOG_DV] in that org DB.'
        throw
    }
}

Write-Log 'DONE. Run 20_verify_uom_cost_pack_size.sql against each org.'
```

- [ ] **Step 2: Preflight**

```powershell
.\ClaudeDevelopment\integrations\Growyze\92_deploy_uom_cost_fix.ps1 -Environment UAT -WhatIf
```

Expected: connects, lists every Growyze-mapped org (both Ibis hotels, Padel Social, Dirty Sixth and any others), executes nothing.

**Checkpoint — get the user's explicit go-ahead before Step 3.** This changes live figures for every Growyze org, not just the Ibis test org.

- [ ] **Step 3: Deploy**

```powershell
.\ClaudeDevelopment\integrations\Growyze\92_deploy_uom_cost_fix.ps1 -Environment UAT
```

Expected: `OK control plane updated`, then `OK reload` per org, no FAIL lines.

- [ ] **Step 4: Confirm the control plane took the change**

Via MCP `query` against `core`:

```sql
SELECT CASE WHEN query_sql LIKE '%COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1)%'
            THEN 'PATCHED' ELSE 'NOT PATCHED - investigate' END AS status
FROM [core].[int_growyze001].[StagingControl]
WHERE step_name = N'Growyze Inventory Items';
```

Expected: `PATCHED`.

- [ ] **Step 5: Commit**

```bash
git add "ClaudeDevelopment/integrations/Growyze/92_deploy_uom_cost_fix.ps1"
git commit -m "chore(growyze): runner for UOM_COST pack-size fix deployment"
```

---

### Task 4: Verify the corrected numbers

**Files:**
- Use: `ClaudeDevelopment/integrations/Growyze/20_verify_uom_cost_pack_size.sql` (Task 1)

**Interfaces:**
- Consumes: the reloaded data from Task 3.

- [ ] **Step 1: Run Section A against Ibis Gloucester Road**

Expected — this is the acceptance gate:

| Field | Required |
|---|---|
| `count_lines` | 151 (unchanged) |
| `stock_value` | **8157.61** |
| `null_cost_lines` | 0 |

A changed `count_lines` means the reload altered row population, not just cost — investigate before accepting.

- [ ] **Step 2: Run Section B spot checks**

Expected: Hendricks `line_value` ≈ **39.50** (`uom_cost` ≈ 0.03320000); SALAMI ≈ **93.24**; ONE WATER STILL GLASS ≈ **71.28**.

- [ ] **Step 3: Run Section C coverage**

Expected: `null_cost_items` = 0. Any leaf item that had a cost before and has none now is a regression — the `COALESCE(..., 1)` guard exists precisely to prevent this.

- [ ] **Step 4: Run Section D data-quality flag**

Expected: returns ROCKET WILD (`pack_size` 500, `measure` kg). This is the documented residual, **not** a failure — record it for the Growyze catalogue owner.

- [ ] **Step 5: MarketMan regression check**

Confirm a MarketMan-sourced org is untouched. Via MCP `query` against `core`, substituting Padel Social's database name:

```sql
SELECT COUNT(*) AS leaf_items,
       CAST(AVG(UOM_COST) AS DECIMAL(18,8)) AS avg_cost
FROM [<PadelSocialDB>].[datavault].[SAT_INVITEM]
WHERE CURRENT_FLAG = 1 AND BOTTOM_LEVEL = 1 AND SRC = 'int_marketman001';
```

Expected: unchanged from before the deploy. MarketMan derives `UOM_COST` from `BOMPrice` in a separate staging step, so any movement here means the blast radius was wider than designed — stop and investigate.

- [ ] **Step 6: Sanity-check the other Growyze orgs**

For Padel Social and Dirty Sixth, run Section A. Their stock values should **drop substantially** (they carry the same defect). There is no pre-computed target — record before/after so the change is auditable and the movement is explainable.

---

### Task 5: Update documentation

**Files:**
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`
- Modify: `docs/outstanding/O5-growyze-default-dashboards.md`
- Modify: `docs/outstanding/O8-marge-brut-dashboard.md`
- Modify: `docs/OUTSTANDING.md`

- [ ] **Step 1: Add QUERY_STATUS entries**

Add entries for `19_invitem_uom_cost_pack_size.sql`, `20_verify_uom_cost_pack_size.sql` and `92_deploy_uom_cost_fix.ps1` in the Growyze section, each with purpose, deploy status, and the measured before/after figures from Task 4.

- [ ] **Step 2: Update O5**

Under the reopened `UOM_COST` blocker, record the fix, the deploy date, and the measured result. Change the item's `Next action` so it no longer leads with the UOM decision.

- [ ] **Step 3: Update O8**

Clear gate (c). Note that Marge Brut cost figures are now trustworthy, leaving the stocktake-cadence item as the remaining data dependency.

- [ ] **Step 4: Update the ledger table**

Refresh the O5 and O8 rows in `docs/OUTSTANDING.md` to match.

- [ ] **Step 5: Commit**

```bash
git add ClaudeDevelopment/QUERY_STATUS.md docs/OUTSTANDING.md docs/outstanding/
git commit -m "docs: record Growyze UOM_COST pack-size fix (O5, O8)"
```

---

## Self-Review

**Spec coverage**

| Spec requirement | Task |
|---|---|
| Change the staging expression, leaf branch only | Task 2 Step 1 |
| `COALESCE(NULLIF(size,0),1)` divisor with rationale | Task 2 Step 1 (header + expression) |
| Both `query_sql` copies updated identically | Task 2 Steps 2–3 |
| `staging_columns` / EntityMappings unchanged | Task 2 Step 1 (list carried verbatim) |
| Re-confirm no divergence before MERGE | Task 1 Step 1 (with STOP condition) |
| Presentation layer untouched | No task modifies PresentationControl — deliberate |
| Deploy: staging → DV load → rebuild, per org | Task 3 Step 3 |
| Blast radius covers all Growyze orgs | Task 3 (org discovery), Task 4 Step 6 |
| Acceptance £762,277.46 → £8,157.61 | Task 4 Step 1 |
| Named spot checks | Task 4 Step 2 |
| Zero items lose an existing cost | Task 4 Step 3 |
| MarketMan regression check | Task 4 Step 5 |
| `kg` / `size >= 100` data-quality flag | Task 1 Step 3 (Section D), Task 4 Step 4 |
| Prod excluded | Global Constraints; runner refuses `prod` |

No gaps.

**Placeholder scan:** no TBD/TODO. Every SQL and PowerShell step carries complete runnable content. The one deliberate blank is Padel Social's database name in Task 4 Step 5, marked `<PadelSocialDB>` because it must be read from `core.Organisations` at execution time rather than hardcoded — consistent with the no-hardcoded-DB-names constraint.

**Type consistency:** `step_name` is `N'Growyze Inventory Items'` throughout. The divisor expression is byte-identical in Task 2 Step 1, Task 2 Step 3's grep, and Task 3 Step 4's check. Verification section labels (A1/B1/C1/D1) match between Task 1 Step 3 and Task 4. Column names (`ACTUAL_COUNT`, `UOM_COST`, `BOTTOM_HUB_ID`, `BOTTOM_INVITEM_NAME`, `BOTTOM_ATTR_3/4/5`, `SRC`, `CURRENT_FLAG`, `BOTTOM_LEVEL`) were all read from the live schema.

**One risk flagged for the executor:** Task 3 reloads *every* Growyze org. If you want to limit the first deploy to the Ibis test org, use `-OnlyOrg 21`, verify, then re-run without it. The control-plane change is global either way — only the reload is scoped.
