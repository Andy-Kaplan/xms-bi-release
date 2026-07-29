# ============================================================================
# 93_backfill_uom_cost.ps1 - Backfill stuck Growyze UOM_COST satellite rows
# ============================================================================
# CDC does not hash UOM_COST, so inventory items whose other Growyze
# attributes were byte-identical across the pack-size fix reload kept their
# old, un-divided per-pack cost. Runs 21_invitem_uom_cost_backfill.sql
# against each Growyze-mapped org's OWN database (not core - the satellite
# lives in the org DB), then re-runs sp_DataVaultLoad so the presentation
# layer (F_INV_COUNTS_DAY) picks up the corrected cost.
#
# Spec: docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md
# Companion: 92_deploy_uom_cost_fix.ps1 (the staging-side fix this backfills)
#
# Usage:
#   .\93_backfill_uom_cost.ps1 -Environment UAT -WhatIf
#   .\93_backfill_uom_cost.ps1 -Environment UAT
#   .\93_backfill_uom_cost.ps1 -Environment UAT -OnlyOrg 21
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

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module not found. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

$scriptDir = $PSScriptRoot
$backfillScript = Join-Path $scriptDir '21_invitem_uom_cost_backfill.sql'
if (-not (Test-Path $backfillScript)) { throw "Missing script: $backfillScript" }
$logPath = Join-Path $scriptDir ("backfill_UOMCOST_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

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

Write-Log "=== Growyze UOM_COST satellite backfill ==="
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
    Write-Log '--- WHATIF: would run 21_invitem_uom_cost_backfill.sql against each org above, then reload ---'
    return
}

if (-not $Force) {
    Write-Host "This corrects stuck UOM_COST satellite rows for ALL $($orgs.Count) Growyze org(s) - their cost/GP% figures WILL change." -ForegroundColor Yellow
    if ((Read-Host "Type DEPLOY to continue") -cne 'DEPLOY') { Write-Log 'Aborted.'; return }
}

foreach ($o in $orgs) {
    Write-Log "RUN   21_invitem_uom_cost_backfill.sql [$($o.DatabaseName)] ($($o.OrganisationName))"
    try {
        Invoke-Sql -Database $o.DatabaseName -File $backfillScript | Out-Null
        Write-Log "OK    backfill $($o.OrganisationName)"
    }
    catch {
        Write-Log "FAIL  backfill $($o.OrganisationName): $($_.Exception.Message)"
        throw
    }

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
