# ============================================================================
# 95_deploy_plan1.ps1 - Deploy Growyze dashboards Plan 1 (data quality + enablement)
# ============================================================================
# Ledger: O5.  Plan: docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md
#
# Deploys the five Plan 1 control-plane deltas to {ENV} core, then re-runs
# staging + DV load + presentation rebuild for every Growyze-mapped org so the
# category sentinel and the new LINEITEM_TIMESTAMP propagate into the facts.
#
#   Task 1  17_product_category_sentinel.sql ....... GRYZ_PRODUCT category sentinel
#   Task 6  18_lineitem_timestamp_mapping.sql ...... LINEITEM_TIMESTAMP from createdAt
#           EXEC core.UploadEntityMappings ......... regenerate the LINEITEM Load step
#   Task 2  reporting_queries/39_growyze_cost_kpis.sql ...... GrowyzeProfit(+Pct)
#   Task 3  reporting_queries/40_growyze_sales_by_category.sql .. GrowyzeSalesByCategory
#   Task 7  08_purchases_day_padel_create.sql ...... F_PURCHASES_DAY on Padel
#
# Phase 2 (Tasks 4/5, deep inventory unit cost) is NOT here - it shipped
# separately as the UOM_COST pack-size fix (19/20/21, deployed UAT 2026-07-29).
#
# *** CORRECTIONS TO THE PLAN'S DOCUMENTED DEPLOY ORDER (verified live 2026-07-30) ***
# 1. The plan / ledger / script-18 header all say to run `UploadStagingControl`.
#    THAT PROCEDURE DOES NOT EXIST - `UploadEntityMappings` is the only Upload*
#    proc in core. It is also unnecessary: staging steps are read straight from
#    StagingControl.query_sql, which is why the UOM_COST fix (a bare UPDATE to
#    the same table) took effect with no regeneration call.
# 2. The proc's parameter is `@intSchema`, NOT `@IntegrationSchema`.
# 3. UploadEntityMappings is scoped to @entity='LINEITEM' - only that entity's
#    Load step needs regenerating, so we avoid rewriting all 23 Load steps.
# 4. THE PLAN'S "presentation rebuild" IS NOT PART OF sp_DataVaultLoad. That proc
#    never touches PresentationControl; core.sp_ProcessPresentation is separate
#    and must be called explicitly - and the Fact steps are gated by a load
#    window (LINEITEM_START/END, STOCKEVENT_START/END in the ORG's own
#    core.GlobalParameters) which rests at NULL between loads, making a naive
#    rebuild a silent no-op for Tasks 6 and 7. 97_rebuild_presentation.sql
#    handles the widening and always restores the resting state; see its header.
#
# Usage:
#   .\95_deploy_plan1.ps1 -Environment UAT -WhatIf
#   .\95_deploy_plan1.ps1 -Environment UAT
#   .\95_deploy_plan1.ps1 -Environment UAT -StartAt 6      # resume after a failure
#   .\95_deploy_plan1.ps1 -Environment UAT -OnlyOrg 10     # single org reload
# ============================================================================

[CmdletBinding()]
param(
    [Parameter()][ValidateSet('DEV','TEST','UAT')]
    [string]$Environment = 'UAT',
    [int]$OnlyOrg = 0,
    [int]$StartAt = 1,
    [switch]$SkipPadelTable,
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

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module not found. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

$scriptDir = $PSScriptRoot
$logPath   = Join-Path $scriptDir ("deploy_PLAN1_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

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

function Resolve-Script {
    param([Parameter(Mandatory)][string]$RelPath)
    $full = Join-Path $scriptDir $RelPath
    if (-not (Test-Path $full)) { throw "Missing script: $full" }
    return $full
}

Write-Log '=== Growyze dashboards Plan 1 (O5) ==='
Write-Log "Environment : $Environment"
Write-Log "Server      : $server"
Write-Log "Log         : $logPath"

# ---------------------------------------------------------------------------
# Discover Growyze-mapped organisations
# ---------------------------------------------------------------------------
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
if ($orgs.Count -eq 0) { throw "No Growyze-mapped organisations found (OnlyOrg=$OnlyOrg)." }
Write-Log "Growyze orgs ($($orgs.Count)):"
foreach ($o in $orgs) { Write-Log ("  org {0,-3} {1,-24} {2}" -f $o.OrganisationID, $o.OrganisationName, $o.DatabaseName) }

# ---------------------------------------------------------------------------
# Guard: 08 hardcodes Padel's UAT database GUID. Fail fast if that GUID is not
# an org database in THIS environment, rather than silently creating nothing.
# ---------------------------------------------------------------------------
$padelStep = Resolve-Script '08_purchases_day_padel_create.sql'
$padelDb   = $null
$m = [regex]::Match((Get-Content $padelStep -Raw), "N'(?<db>\d{8}_XMS_[0-9A-Fa-f-]+)'")
if ($m.Success) { $padelDb = $m.Groups['db'].Value }
if (-not $SkipPadelTable) {
    if (-not $padelDb) {
        throw "Could not parse the target database out of 08_purchases_day_padel_create.sql."
    }
    $allOrgs = @(Invoke-Sql -Database 'core' -Query $orgSql)
    if (-not ($allOrgs | Where-Object { $_.DatabaseName -eq $padelDb })) {
        throw @"
08_purchases_day_padel_create.sql targets database '$padelDb', which is not a
Growyze org database in $Environment. That GUID is Padel Social on UAT. Re-point
the script for this environment, or pass -SkipPadelTable to omit Task 7.
"@
    }
    Write-Log "Task 7 target   : $padelDb (verified present in $Environment)"
}
else {
    Write-Log 'Task 7          : SKIPPED (-SkipPadelTable)'
}

# ---------------------------------------------------------------------------
# Build the ordered step list
# ---------------------------------------------------------------------------
$steps = New-Object System.Collections.Generic.List[object]
$add = {
    param($Name, $Database, $File, $Query)
    $steps.Add([pscustomobject]@{
        Id = $steps.Count + 1; Name = $Name; Database = $Database; File = $File; Query = $Query
    })
}

& $add 'Task 1  category sentinel (GRYZ_PRODUCT staging)' 'core' (Resolve-Script '17_product_category_sentinel.sql') $null
& $add 'Task 6  LINEITEM_TIMESTAMP staging + entity mapping' 'core' (Resolve-Script '18_lineitem_timestamp_mapping.sql') $null
& $add 'Task 6  regenerate LINEITEM Load step' 'core' $null "EXEC [core].[UploadEntityMappings] @intSchema = N'int_growyze001', @entity = N'LINEITEM';"
& $add 'Task 2  GrowyzeProfit / GrowyzeProfitPct' 'core' (Resolve-Script 'reporting_queries/39_growyze_cost_kpis.sql') $null
& $add 'Task 3  GrowyzeSalesByCategory' 'core' (Resolve-Script 'reporting_queries/40_growyze_sales_by_category.sql') $null
if (-not $SkipPadelTable) {
    & $add 'Task 7  create F_PURCHASES_DAY on Padel' 'core' $padelStep $null
}
$rebuildScript = Resolve-Script '97_rebuild_presentation.sql'
foreach ($o in $orgs) {
    & $add ("reload  org {0} {1}" -f $o.OrganisationID, $o.OrganisationName) $o.DatabaseName $null `
        "EXEC [core].[sp_DataVaultLoad] @SchemaList = N'int_growyze001';"
    & $add ("rebuild org {0} {1}" -f $o.OrganisationID, $o.OrganisationName) $o.DatabaseName $rebuildScript $null
}

Write-Log "Steps ($($steps.Count)):"
foreach ($s in $steps) {
    $what = if ($s.File) { Split-Path $s.File -Leaf } else { 'inline T-SQL' }
    Write-Log ("  {0,2}. {1,-52} [{2}] {3}" -f $s.Id, $s.Name, $s.Database, $what)
}

if ($WhatIf) {
    Write-Log '--- WHATIF: nothing executed ---'
    return
}

if (-not $Force) {
    Write-Host ''
    Write-Host "This edits the SHARED int_growyze001 control plane and reloads $($orgs.Count) org(s)." -ForegroundColor Yellow
    Write-Host 'Product categories and (for Padel/Dirty Sixth) line-item timestamps WILL change.' -ForegroundColor Yellow
    Write-Host 'Orgs 16 and 21 serve the live Marge Brut dashboard (O8) - verify it after.' -ForegroundColor Yellow
    if ((Read-Host "Type DEPLOY to continue") -cne 'DEPLOY') { Write-Log 'Aborted by operator.'; return }
}

# ---------------------------------------------------------------------------
# Execute, halting on the first error so -StartAt can resume
# ---------------------------------------------------------------------------
foreach ($s in $steps) {
    if ($s.Id -lt $StartAt) { Write-Log ("SKIP  {0,2}. {1} (-StartAt $StartAt)" -f $s.Id, $s.Name); continue }
    Write-Log ("RUN   {0,2}. {1} [{2}]" -f $s.Id, $s.Name, $s.Database)
    try {
        if ($s.File) { $result = @(Invoke-Sql -Database $s.Database -File $s.File) }
        else         { $result = @(Invoke-Sql -Database $s.Database -Query $s.Query) }

        # Surface result rows instead of silently discarding them (was "| Out-Null").
        # This matters most for 97_rebuild_presentation.sql: it EXECs
        # core.sp_ProcessPresentation, which swallows per-step errors into its own
        # result sets (Status = 'Failed' rows) rather than raising - even with
        # @StopOnError = 1 it just stops the loop and returns normally, so T-SQL's
        # own TRY/CATCH never sees a failure. PowerShell, seeing the raw rows
        # Invoke-Sqlcmd returns, is the only place left that can catch this.
        if ($result.Count -gt 0) { Write-Log ("      -> {0} result row(s) returned" -f $result.Count) }
        $failedRows = @($result | Where-Object { $_.PSObject.Properties.Name -contains 'Status' -and $_.Status -eq 'Failed' })
        if ($failedRows.Count -gt 0) {
            # Read every column defensively. TWO different row shapes carry
            # Status = 'Failed', and only one of them has StepName:
            #   sp_ExecuteQuery's own CATCH row -> ErrorNumber, ErrorMessage,
            #     ErrorLine, Status         (NO StepName/TableName, and it is
            #     emitted mid-cursor so it arrives FIRST)
            #   #ProcessingLog rows          -> StepName, TableName, ..., Status
            # Under this file's Set-StrictMode -Version Latest, touching an
            # absent column throws PropertyNotFoundException - which would
            # replace the failed step's name with a bogus "runner bug" message,
            # destroying exactly the diagnostic this block exists to surface.
            foreach ($f in $failedRows) {
                $cols = $f.PSObject.Properties.Name
                $step = if ($cols -contains 'StepName')     { $f.StepName }     else { '(step unknown)' }
                $tbl  = if ($cols -contains 'TableName')    { $f.TableName }    else { '' }
                $msg  = if ($cols -contains 'ErrorMessage') { $f.ErrorMessage } else { '' }
                Write-Log ("      -> FAILED STEP: {0} [{1}]: {2}" -f $step, $tbl, $msg)
            }
            throw "sp_ProcessPresentation reported $($failedRows.Count) failed presentation step(s) during '$($s.Name)' - see log above."
        }
        Write-Log ("OK    {0,2}. {1}" -f $s.Id, $s.Name)
    }
    catch {
        Write-Log ("FAIL  {0,2}. {1}: {2}" -f $s.Id, $s.Name, $_.Exception.Message)
        if ($s.Query -match 'sp_DataVaultLoad') {
            Write-Log '      -> sp_DataVaultLoad masks errors behind a bogus severity;'
            Write-Log "      -> read [core].[LOG_DV] inside [$($s.Database)] for the real error."
        }
        Write-Log ("      -> resume with: .\95_deploy_plan1.ps1 -Environment $Environment -StartAt $($s.Id)")
        throw
    }
}

Write-Log 'DONE. Now run the Plan 1 verification queries (96_verify_plan1.sql).'
