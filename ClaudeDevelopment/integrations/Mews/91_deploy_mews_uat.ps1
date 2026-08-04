# ============================================================================
# 91_deploy_mews_uat.ps1 - Deploy the Mews001 staging/DV mapping to an env
# ============================================================================
# Context (2026-07-29): the Ibis orgs were provisioned on UAT (ledger O19) and
# the fetcher landed Mews DL data (Integrations O10), but the Mews staging /
# entity-mapping control rows were never deployed to UAT --
# core.int_mews001.StagingControl and .EntityMappings were both EMPTY, so
# stage.MEWS_* never materialised, HUB_LINEITEM/SAT_LINEITEM stayed at 0 and
# presentation.F_LINEITEM_15MIN was empty. That is the Turnover half of the
# Marge Brut dashboard (ledger O8). This runner closes that gap.
#
# Connection comes from env vars (same convention as 90_deploy_baseline.ps1):
#   XMS_BI_MANAGED_{ENV}_SERVER / _USER / _PASSWORD
#
# Control-plane steps target `core` and are environment-wide (one Mews
# integration config per environment). The Data Vault load runs per
# organisation database.
#
# All referenced scripts are idempotent (MERGE upserts + guarded DELETEs), so
# a failed run can be fixed and re-run from the top, or resumed with -StartAt.
#
# Usage:
#   .\91_deploy_mews_uat.ps1 -Environment UAT -WhatIf    # preflight only
#   .\91_deploy_mews_uat.ps1 -Environment UAT            # deploy (prompts)
#   .\91_deploy_mews_uat.ps1 -Environment UAT -StartAt 3 # resume from step 3
#   .\91_deploy_mews_uat.ps1 -Environment UAT -SkipLoad  # control plane only
# ============================================================================

[CmdletBinding()]
param(
    [Parameter()][ValidateSet('DEV','TEST','UAT')]
    [string]$Environment = 'UAT',
    [int]$StartAt = 1,
    [switch]$WhatIf,
    [switch]$SkipLoad,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- connection ---------------------------------------------------------------
$server   = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_SERVER")
$user     = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_USER")
$password = [Environment]::GetEnvironmentVariable("XMS_BI_MANAGED_${Environment}_PASSWORD")
if (-not $server -or -not $user -or -not $password) {
    throw "Missing env vars XMS_BI_MANAGED_${Environment}_SERVER / _USER / _PASSWORD."
}
if ($server -notmatch ',\d+$' -and $server -match '\.public\.') { $server = "$server,3342" }

# Hard safety rail: this runner is never for Prod (Prod Mews deploy is a
# separate, human-run decision - see CLAUDE.md MCP/deployment safety rules).
if ($server -match 'prod') { throw "Refusing to run against a server whose name contains 'prod': $server" }

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module missing. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

$scriptDir = $PSScriptRoot
$logPath   = Join-Path $scriptDir ("deploy_MEWS_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -Path $logPath -Value $line -Encoding utf8
}

function Invoke-Sql {
    param(
        [Parameter(Mandatory)][string]$Database,
        [string]$File,
        [string]$Query
    )
    $splat = @{
        ServerInstance         = $server
        Database               = $Database
        Username               = $user
        Password               = $password
        TrustServerCertificate = $true
        QueryTimeout           = 0
        ErrorAction            = 'Stop'
        OutputSqlErrors        = $true
        Verbose                = $true
    }
    if ($File)  { $splat['InputFile'] = $File }
    if ($Query) { $splat['Query']     = $Query }
    Invoke-Sqlcmd @splat
}

# --- Section A of 05_remove_crm_pii.sql (core half only) ----------------------
# The file mixes a core-targeted Section A with an org-DB Section B; running the
# whole file against `core` fails at B5 (unguarded SELECTs from datavault.*).
# On a fresh environment 01/02 never create the CRM rows, so this is expected to
# be a no-op - it is run for hygiene / idempotence with already-deployed envs.
$crmSectionA = @'
DELETE FROM [core].[int_mews001].[EntityMappings]
WHERE entity_name IN (N'INDIVIDUAL', N'ADDRESS', N'CONTACT',
                      N'ADDRESS_INDIVIDUAL', N'CONTACT_INDIVIDUAL');

DELETE FROM [core].[int_mews001].[StagingControl]
WHERE step_type = N'Staging'
  AND step_name IN (N'Mews Customer', N'Mews Address', N'Mews Contact');

DELETE FROM [core].[int_mews001].[StagingControl]
WHERE step_type = N'Load'
  AND step_name IN (N'Data Vault load - INDIVIDUAL',
                    N'Data Vault load - ADDRESS',
                    N'Data Vault load - CONTACT',
                    N'Data Vault load - ADDRESS_INDIVIDUAL',
                    N'Data Vault load - CONTACT_INDIVIDUAL');
'@

# --- control-plane steps (target: core) ---------------------------------------
$steps = @(
    @{ Name = '01_staging_control.sql';   File = (Join-Path $scriptDir '01_staging_control.sql');   Db = 'core' },
    @{ Name = '02_entity_mappings.sql';   File = (Join-Path $scriptDir '02_entity_mappings.sql');   Db = 'core' },
    @{ Name = '05_remove_crm_pii (A)';    Query = $crmSectionA;                                     Db = 'core' },
    @{ Name = '03_upload_load_steps.sql'; File = (Join-Path $scriptDir '03_upload_load_steps.sql'); Db = 'core' }
)

foreach ($s in $steps) {
    if ($s.ContainsKey('File') -and -not (Test-Path $s.File)) { throw "Missing script: $($s.File)" }
}

Write-Log "=== Mews001 staging/DV mapping deploy ==="
Write-Log "Environment : $Environment"
Write-Log "Server      : $server"
Write-Log "Log         : $logPath"

# --- discover target organisations -------------------------------------------
$orgSql = @'
SELECT OrganisationID, OrganisationName, DatabaseName
FROM [core].[core].[Organisations] o
WHERE o.DatabaseStatus IN ('ACTIVE','FAILED')
  AND EXISTS (
        SELECT 1
        FROM [core].[core].[OrganisationIntegrations] oi
        JOIN [core].[core].[Integrations] i ON i.IntegrationID = oi.IntegrationID
        WHERE oi.OrganisationID = o.OrganisationID
          AND i.SchemaName = 'int_mews001'
          AND oi.IsEnabled = 1)
ORDER BY o.OrganisationID;
'@

Write-Log "Discovering organisations mapped to int_mews001..."
$orgs = @(Invoke-Sql -Database 'core' -Query $orgSql)
if ($orgs.Count -eq 0) { throw "No ACTIVE organisations are mapped to int_mews001 in $Environment - nothing to load." }
foreach ($o in $orgs) { Write-Log ("  org {0,-3} {1,-24} {2}" -f $o.OrganisationID, $o.OrganisationName, $o.DatabaseName) }

# --- preflight ----------------------------------------------------------------
if ($WhatIf) {
    Write-Log ''
    Write-Log '--- WHATIF: planned steps (nothing executed) ---'
    $i = 1
    foreach ($s in $steps) {
        $what = if ($s.ContainsKey('File')) { $s.File } else { 'inline query' }
        Write-Log ("  {0}. [{1}] {2}  ->  {3}" -f $i, $s.Db, $s.Name, $what); $i++
    }
    if (-not $SkipLoad) {
        foreach ($o in $orgs) {
            Write-Log ("  {0}. [{1}] sp_DataVaultLoad @SchemaList='int_mews001'" -f $i, $o.DatabaseName); $i++
        }
    }
    Write-Log '--- end WHATIF ---'
    return
}

# --- typed confirmation -------------------------------------------------------
if (-not $Force) {
    Write-Host ''
    Write-Host "About to deploy the Mews001 control-plane config to [$Environment] core" -ForegroundColor Yellow
    if (-not $SkipLoad) {
        Write-Host "and run sp_DataVaultLoad for $($orgs.Count) organisation database(s)." -ForegroundColor Yellow
    }
    $answer = Read-Host "Type DEPLOY to continue"
    if ($answer -cne 'DEPLOY') { Write-Log 'Aborted by operator.'; return }
}

# --- execute control plane ----------------------------------------------------
$stepNo = 0
foreach ($s in $steps) {
    $stepNo++
    if ($stepNo -lt $StartAt) { Write-Log "SKIP  step $stepNo ($($s.Name)) - before -StartAt $StartAt"; continue }
    Write-Log "RUN   step $stepNo [$($s.Db)] $($s.Name)"
    try {
        if ($s.ContainsKey('File')) { $res = Invoke-Sql -Database $s.Db -File $s.File }
        else                        { $res = Invoke-Sql -Database $s.Db -Query $s.Query }
        if ($res) { $res | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Log $_ } }
        Write-Log "OK    step $stepNo $($s.Name)"
    }
    catch {
        Write-Log "FAIL  step $stepNo $($s.Name): $($_.Exception.Message)"
        throw
    }
}

# --- control-plane verification ----------------------------------------------
$verifySql = @'
SELECT 'staging_steps' AS check_name, COUNT(*) AS actual
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Staging' AND exclude = 0
UNION ALL
SELECT 'load_steps', COUNT(*)
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Load' AND exclude = 0
UNION ALL
SELECT 'entity_mappings', COUNT(*)
FROM [core].[int_mews001].[EntityMappings] WHERE is_active = 1
UNION ALL
SELECT 'crm_control_rows_remaining', COUNT(*)
FROM [core].[int_mews001].[EntityMappings]
WHERE entity_name IN (N'INDIVIDUAL', N'ADDRESS', N'CONTACT',
                      N'ADDRESS_INDIVIDUAL', N'CONTACT_INDIVIDUAL');
'@
Write-Log 'VERIFY control plane (expect staging=15, load=16, mappings=16, crm=0)'
$v = Invoke-Sql -Database 'core' -Query $verifySql
$v | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Log $_ }

# --- per-org Data Vault load --------------------------------------------------
if ($SkipLoad) { Write-Log 'SkipLoad set - control plane only. Done.'; return }

foreach ($o in $orgs) {
    $stepNo++
    if ($stepNo -lt $StartAt) { Write-Log "SKIP  step $stepNo (load $($o.OrganisationName))"; continue }
    Write-Log "RUN   step $stepNo DV load [$($o.DatabaseName)] ($($o.OrganisationName))"
    try {
        Invoke-Sql -Database $o.DatabaseName -Query "EXEC [core].[sp_DataVaultLoad] @SchemaList = N'int_mews001';" |
            Format-Table -AutoSize | Out-String | ForEach-Object { Write-Log $_ }
        Write-Log "OK    DV load $($o.OrganisationName)"
    }
    catch {
        # sp_DataVaultLoad masks the real error - re-raises with @ErrorNumber as
        # the RAISERROR severity. The genuine error text is in core.LOG_DV.
        Write-Log "FAIL  DV load $($o.OrganisationName): $($_.Exception.Message)"
        Write-Log '      -> inspect [core].[LOG_DV] in that org DB for the real error.'
        throw
    }

    $loadCheck = @'
SELECT 'HUB_LINEITEM' AS t, COUNT(*) AS rows_ FROM [datavault].[HUB_LINEITEM] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'SAT_LINEITEM', COUNT(*) FROM [datavault].[SAT_LINEITEM] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'HUB_CUSTORDER', COUNT(*) FROM [datavault].[HUB_CUSTORDER] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'LNK_CUSTORDER_LINEITEM', COUNT(*) FROM [datavault].[LNK_CUSTORDER_LINEITEM] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'HUB_PRODUCT', COUNT(*) FROM [datavault].[HUB_PRODUCT] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'HUB_LOCATION', COUNT(*) FROM [datavault].[HUB_LOCATION] WHERE SRC = 'int_mews001';
'@
    Write-Log "VERIFY DV row counts for $($o.OrganisationName)"
    $lc = Invoke-Sql -Database $o.DatabaseName -Query $loadCheck
    $lc | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Log $_ }
}

Write-Log ''
Write-Log 'DONE. Next: rebuild the presentation layer for each org so'
Write-Log 'presentation.F_LINEITEM_15MIN picks up the new LINEITEM rows,'
Write-Log 'then re-check the Marge Brut Turnover source (ledger O8).'
