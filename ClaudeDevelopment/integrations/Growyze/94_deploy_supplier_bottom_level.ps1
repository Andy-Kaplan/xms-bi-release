# ============================================================================
# 94_deploy_supplier_bottom_level.ps1 - Deploy the Growyze supplier BOTTOM_LEVEL fix
# ============================================================================
# Ledger: O23 (unblocks the 9th Marge Brut card, O8)
#
# Deploys 22_supplier_bottom_level.sql to {ENV} core, regenerates the SUPPLIER
# Load step from its mapping row, then re-runs staging + DV load + presentation
# rebuild for every Growyze-mapped org so BOTTOM_LEVEL = 1 reaches SAT_SUPPLIER
# and presentation.D_SUPPLIER can finally build its Growyze rows.
#
# Modelled on 92_deploy_uom_cost_fix.ps1 (same shape of job: a Growyze staging
# change that needs a per-org reload). Gates on 23_verify's roll-up per org.
#
# Usage:
#   .\94_deploy_supplier_bottom_level.ps1 -Environment UAT -WhatIf
#   .\94_deploy_supplier_bottom_level.ps1 -Environment UAT
#   .\94_deploy_supplier_bottom_level.ps1 -Environment UAT -OnlyOrg 16
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

$scriptDir  = $PSScriptRoot
$fixScript  = Join-Path $scriptDir '22_supplier_bottom_level.sql'
$verifyFile = Join-Path $scriptDir '23_verify_supplier_bottom_level.sql'
foreach ($f in @($fixScript, $verifyFile)) {
    if (-not (Test-Path $f)) { throw "Missing script: $f" }
}
$logPath = Join-Path $scriptDir ("deploy_SUPPLIERBL_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

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

Write-Log "=== Growyze supplier BOTTOM_LEVEL fix (O23) ==="
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
    Write-Log '--- WHATIF: would deploy 22 to core, regenerate the SUPPLIER Load step, then reload + verify each org above ---'
    return
}

if (-not $Force) {
    Write-Host "This reloads the Growyze data vault for ALL $($orgs.Count) Growyze org(s)." -ForegroundColor Yellow
    if ((Read-Host "Type DEPLOY to continue") -cne 'DEPLOY') { Write-Log 'Aborted.'; return }
}

# --- 1. Control plane (shared by every Growyze org) -------------------------
Write-Log 'RUN   22_supplier_bottom_level.sql [core]'
try {
    Invoke-Sql -Database 'core' -File $fixScript | Out-Null
    Write-Log 'OK    staging step + SUPPLIER entity mapping updated'
}
catch {
    Write-Log "FAIL  control plane update: $($_.Exception.Message)"
    throw
}

# Regenerate ONLY the SUPPLIER Load step. Unscoped calls regenerate every
# Growyze entity and multi-source entities are known to collide (error 8156 /
# silent last-source-wins), so @entity is deliberately pinned.
Write-Log "RUN   UploadEntityMappings @intSchema='int_growyze001', @entity='SUPPLIER' [core]"
try {
    Invoke-Sql -Database 'core' -Query @"
EXEC [core].[UploadEntityMappings] @intSchema = N'int_growyze001', @entity = N'SUPPLIER';
"@ | Out-Null
    Write-Log 'OK    Data Vault load - SUPPLIER step regenerated'
}
catch {
    Write-Log "FAIL  UploadEntityMappings: $($_.Exception.Message)"
    throw
}

# Confirm the regenerated Load step actually carries the column, and that it did
# NOT pick up MICROSERVICE_NAME (which would collapse the chart to one bar).
$loadStepCheck = Invoke-Sql -Database 'core' -Query @"
SELECT CASE WHEN query_sql LIKE '%BOTTOM[_]LEVEL%'
             AND query_sql NOT LIKE '%MICROSERVICE[_]NAME%'
            THEN 'OK' ELSE 'BAD' END AS Verdict
FROM [core].[int_growyze001].[StagingControl]
WHERE step_name = 'Data Vault load - SUPPLIER';
"@
if (-not $loadStepCheck -or $loadStepCheck[0].Verdict -ne 'OK') {
    Write-Log 'FAIL  regenerated SUPPLIER Load step missing BOTTOM_LEVEL or carrying MICROSERVICE_NAME'
    throw 'SUPPLIER Load step did not regenerate as expected.'
}
Write-Log 'OK    Load step carries BOTTOM_LEVEL, no MICROSERVICE_NAME'

# --- 2. Per-org reload + verify --------------------------------------------
$rollupSql = @'
WITH sat AS (
    SELECT COUNT(*) AS rows_current,
           SUM(CASE WHEN BOTTOM_LEVEL = 1 THEN 1 ELSE 0 END) AS bl_set,
           SUM(CASE WHEN MICROSERVICE_NAME IS NOT NULL THEN 1 ELSE 0 END) AS ms_set
    FROM [datavault].[SAT_SUPPLIER]
    WHERE CURRENT_FLAG = 1 AND SRC = N'int_growyze001'
),
dim AS (
    SELECT SUM(CASE WHEN BOTTOM_SRC = N'int_growyze001' THEN 1 ELSE 0 END) AS growyze_rows
    FROM [presentation].[D_SUPPLIER]
),
jn AS (
    SELECT COUNT(*) AS lines,
           SUM(CASE WHEN sup.BOTTOM_HUB_ID IS NULL THEN 1 ELSE 0 END) AS unmatched
    FROM [presentation].[F_PURCHASES_DAY] p
    LEFT JOIN [presentation].[D_SUPPLIER] sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID
)
SELECT sat.rows_current, sat.bl_set, sat.ms_set,
       dim.growyze_rows, jn.lines, jn.unmatched,
       CASE WHEN sat.rows_current > 0 AND sat.bl_set = sat.rows_current
                 AND sat.ms_set = 0 AND dim.growyze_rows > 0
                 AND jn.lines > 0 AND jn.unmatched = 0
            THEN 'PASS' ELSE 'FAIL' END AS Verdict
FROM sat CROSS JOIN dim CROSS JOIN jn;
'@

$failed = @()
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

    # Verify immediately, per org, so a partial success is visible in the log
    # rather than discovered later on the dashboard.
    $r = Invoke-Sql -Database $o.DatabaseName -Query $rollupSql
    if ($r) {
        Write-Log ("      sat={0} bl_set={1} d_supplier={2} lines={3} unmatched={4} -> {5}" -f `
            $r[0].rows_current, $r[0].bl_set, $r[0].growyze_rows, $r[0].lines, $r[0].unmatched, $r[0].Verdict)
        if ($r[0].Verdict -ne 'PASS') { $failed += $o.OrganisationName }
    }
    else {
        Write-Log '      verify returned no rows'
        $failed += $o.OrganisationName
    }
}

if ($failed.Count -gt 0) {
    Write-Log "RESULT FAIL - not fixed on: $($failed -join ', ')"
    Write-Log '       If bl_set is a PARTIAL count, CDC left rows stuck (CHECKSUM-based;'
    Write-Log '       see 21_invitem_uom_cost_backfill.sql for the precedent) - a targeted'
    Write-Log '       SAT_SUPPLIER backfill is the remedy, not another reload.'
    throw "Supplier BOTTOM_LEVEL fix did not verify on $($failed.Count) org(s)."
}

Write-Log "RESULT PASS - O23 fixed on all $($orgs.Count) Growyze org(s)."
Write-Log 'Run 23_verify_supplier_bottom_level.sql per org for the full per-check detail.'
