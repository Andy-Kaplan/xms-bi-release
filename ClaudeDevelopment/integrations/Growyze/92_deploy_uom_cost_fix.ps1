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
