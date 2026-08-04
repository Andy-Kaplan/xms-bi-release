# ============================================================================
# 90_deploy_oak_vine_mapping.ps1 - O24: map The Oak & Vine to Growyze + Mews
# ============================================================================
# Ledger: docs/outstanding/O24-oak-vine-growyze-mews-mapping.md
# Raised by Integrations ledger O10.
#
# Runs the O24 scripts in order against the environment named by -Environment.
# Connection comes from env vars:
#   XMS_BI_MANAGED_{ENV}_SERVER / _USER / _PASSWORD
#
# Why a runner and not the MCP `execute` tool: script 01's mapping fires the
# org-integration provisioning trigger, which builds 13 + 21 DL tables. The MCP
# execute tool has a 15s request cap and can cancel mid-provision, leaving a
# half-built int_* schema that a re-run will NOT repair (the trigger fires only
# on the first INSERT).
#
# UAT ONLY by design - O24's scope excludes Test/Prod. Widening it needs a
# ledger follow-on, so ValidateSet is deliberately narrow.
#
# Usage:
#   .\90_deploy_oak_vine_mapping.ps1 -Environment UAT -WhatIf   # preflight only
#   .\90_deploy_oak_vine_mapping.ps1 -Environment UAT           # run (prompts)
#   .\90_deploy_oak_vine_mapping.ps1 -Environment UAT -StartAt 2  # verify only
# ============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('UAT')]
    [string]$Environment,
    [int]$StartAt = 1,
    [switch]$WhatIf,
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
if ($server -match 'prod') { throw "Refusing to run: server '$server' looks like Prod. O24 is UAT-only." }

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module missing. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

# --- steps -------------------------------------------------------------------
$deploySteps = @(
    @{ File = '01_map_oak_vine_to_growyze_mews.sql'; Db = 'core'; Kind = 'state-changing' },
    @{ File = '02_verify_dl_provisioning.sql';       Db = 'core'; Kind = 'read-only' }
)

# --- logging -----------------------------------------------------------------
$log = Join-Path $PSScriptRoot ("deploy_O24_{0}_{1}.log" -f $Environment, (Get-Date -Format 'yyyyMMdd_HHmmss'))
function Log([string]$msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg
    Write-Host $line
    Add-Content -Path $log -Value $line
}

Log "O24 - map The Oak & Vine (org 16) to Growyze001 + Mews001"
Log "Target environment : $Environment"
Log "Target server      : $server"
Log "Script path        : $PSScriptRoot"

$missing = $deploySteps | Where-Object { -not (Test-Path (Join-Path $PSScriptRoot $_.File)) }
if ($missing) { throw "Missing script files: $(($missing | ForEach-Object { $_.File }) -join ', ')" }
Log "All $($deploySteps.Count) script files present."

$connArgs = @{
    ServerInstance         = $server
    Username               = $user
    Password               = $password
    TrustServerCertificate = $true
    ErrorAction            = 'Stop'
}

$verInfo = Invoke-Sqlcmd @connArgs -Database 'master' -Query "SELECT @@SERVERNAME AS srv, SERVERPROPERTY('ProductVersion') AS ver"
Log "Connected: $($verInfo.srv) (SQL $($verInfo.ver))"
if ($verInfo.srv -match 'prod') { throw "Refusing to run: connected server '$($verInfo.srv)' looks like Prod." }

# --- preflight (read-only): current state ------------------------------------
$preflightSql = @"
SET NOCOUNT ON;
SELECT o.OrganisationID, o.OrganisationName, o.DatabaseStatus,
       ISNULL(STUFF((SELECT ', ' + i2.IntegrationName
                     FROM core.OrganisationIntegrations oi2
                     JOIN core.Integrations i2 ON i2.IntegrationID = oi2.IntegrationID
                     WHERE oi2.OrganisationID = o.OrganisationID
                     ORDER BY i2.IntegrationID
                     FOR XML PATH('')), 1, 2, ''), '(none)') AS mapped_now
FROM core.Organisations o
WHERE o.OrganisationCode = '7ED2E768-0D22-F111-832F-000D3AB27D87';
"@
$pre = Invoke-Sqlcmd @connArgs -Database 'core' -Query $preflightSql
if (-not $pre) { throw "Oak & Vine org (code 7ED2E768-...) not found on $Environment - wrong server?" }
Log "Preflight: org $($pre.OrganisationID) '$($pre.OrganisationName)' [$($pre.DatabaseStatus)] currently mapped to: $($pre.mapped_now)"

if ($WhatIf) {
    Log 'WhatIf: preflight complete, nothing executed. Planned order:'
    $i = 0
    foreach ($s in $deploySteps) { $i++; Log ("  {0}. [{1}] {2} ({3})" -f $i, $s.Db, $s.File, $s.Kind) }
    Log 'Script 01 will EXEC MapOrganisationToIntegration twice (Growyze001, then Mews001).'
    Log 'Its INSERT trigger provisions int_growyze001 (13 DL) + int_mews001 (21 DL) in the Oak & Vine DB.'
    return
}

if (-not $Force) {
    $ack = Read-Host "About to map The Oak & Vine to Growyze001 + Mews001 on $Environment ($server). Type $Environment to confirm"
    if ($ack -cne $Environment) { Log 'Aborted by operator.'; return }
}

# --- execute -----------------------------------------------------------------
$stepNo = 0
foreach ($step in $deploySteps) {
    $stepNo++
    if ($stepNo -lt $StartAt) { continue }
    $path = Join-Path $PSScriptRoot $step.File
    Log ("STEP {0}/{1} [{2}] {3} ({4})" -f $stepNo, $deploySteps.Count, $step.Db, $step.File, $step.Kind)
    try {
        # PRINT output arrives on the verbose stream; result sets come back as rows.
        # QueryTimeout 0 = no limit: the provisioning trigger builds 34 DL tables.
        Invoke-Sqlcmd @connArgs -Database $step.Db -InputFile $path -QueryTimeout 0 -Verbose 4>&1 |
            ForEach-Object { Add-Content -Path $log -Value ("    " + ($_ | Format-Table -AutoSize | Out-String).TrimEnd()) }
        Log ("STEP {0} OK" -f $stepNo)
    }
    catch {
        Log ("STEP {0} FAILED: {1}" -f $stepNo, $_.Exception.Message)
        Log "Halted. Fix the issue and resume with: .\90_deploy_oak_vine_mapping.ps1 -Environment $Environment -StartAt $stepNo"
        throw
    }
}

Log "Complete. Review the RESULT sets above in $log"
Log "Expected: int_growyze001 = 13 DL tables, int_mews001 = 21 DL tables, mirror diff = 0 rows."
Log "Next: hand the RESULT 3 kv_prefix rows back to Integrations O10 (clone Ibis Gloucester Road's UAT secrets), then O10 fires the load."
