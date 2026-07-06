# ============================================================================
# 90_deploy_baseline.ps1 - Execute the v1.0 baseline against a target instance
# ============================================================================
# Runs the 39 baseline scripts (TBTBookingMetrics on hold per the 2026-07-06
# ruling) in DEPLOY_ORDER.txt order against the environment named by
# -Environment. Connection comes from env vars:
#   XMS_BI_MANAGED_{ENV}_SERVER / _USER / _PASSWORD   (e.g. ..._PROD_SERVER)
#
# All baseline scripts are idempotent, so a failed run can be fixed and
# re-run from the top (or resumed with -StartAt <step>).
#
# Usage:
#   .\90_deploy_baseline.ps1 -Environment PROD -WhatIf     # preflight only
#   .\90_deploy_baseline.ps1 -Environment PROD             # deploy (prompts)
#   .\90_deploy_baseline.ps1 -Environment PROD -StartAt 15 # resume from step 15
# ============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('DEV','TEST','UAT','PROD')]
    [string]$Environment,
    [string]$BaselinePath,
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

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module missing. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

# --- baseline file list (mirrors releases/v1.0-baseline/DEPLOY_ORDER.txt) -----
if (-not $BaselinePath) {
    $BaselinePath = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'releases\v1.0-baseline'
}
# Each entry: relative file path + target database.
# TBTBookingMetrics deliberately absent (ON HOLD - 2026-07-06 ruling).
$deploySteps = @(
    @{ File = '1__DBInit.sql';                            Db = 'master' },
    @{ File = '2_CoreTableCreateScripts.sql';             Db = 'core' },
    @{ File = '3_CoreStoredProceduresAndFunctions.sql';   Db = 'core' },
    @{ File = '4_DeploymentTools.sql';                    Db = 'core' },
    @{ File = '5_CreateIntegrationTables.sql';            Db = 'core' },
    @{ File = '6_GenerateDataVaultTables.sql';            Db = 'core' },
    @{ File = '6_DeployPresentationTables.sql';           Db = 'core' },
    @{ File = '7_IntegrationTrigger.sql';                 Db = 'core' },
    @{ File = '7_Dynamic Suggestion Tables.sql';          Db = 'core' },
    @{ File = '8_DataVaultEntities.sql';                  Db = 'core' },
    @{ File = '8_Deployment_Objects_Records.sql';         Db = 'core' },
    @{ File = '8_PresentationControl.sql';                Db = 'core' },
    @{ File = '8_PresentationTables.sql';                 Db = 'core' },
    @{ File = '8_VisualisationQueries.sql';               Db = 'core' },
    @{ File = 'NCRAloha\NCRAloha001_INIT.sql';            Db = 'core' },
    @{ File = 'NCRAloha\NCRAloha001_DDL.sql';             Db = 'core' },
    @{ File = 'NCRAloha\NCRAloha001_Staging.sql';         Db = 'core' },
    @{ File = 'NCRAloha\NCRAloha001_Mapping.sql';         Db = 'core' },
    @{ File = 'NCRAloha\NCRAloha001_Final.sql';           Db = 'core' },
    @{ File = 'MarketMan\Marketman001_INIT.sql';          Db = 'core' },
    @{ File = 'MarketMan\Marketman001_DDL.sql';           Db = 'core' },
    @{ File = 'MarketMan\Marketman001_Staging.sql';       Db = 'core' },
    @{ File = 'MarketMan\Marketman001_Mapping.sql';       Db = 'core' },
    @{ File = 'MarketMan\Marketman001_Final.sql';         Db = 'core' },
    @{ File = 'Growyze\Growyze001_INIT.sql';              Db = 'core' },
    @{ File = 'Growyze\Growyze001_DDL.sql';               Db = 'core' },
    @{ File = 'Growyze\Growyze001_Staging.sql';           Db = 'core' },
    @{ File = 'Growyze\Growyze001_Mapping.sql';           Db = 'core' },
    @{ File = 'Growyze\Growyze001_Final.sql';             Db = 'core' },
    @{ File = 'SurveyHero\SurveyHero001_INIT.sql';        Db = 'core' },
    @{ File = 'SurveyHero\SurveyHero001_DDL.sql';         Db = 'core' },
    @{ File = 'SurveyHero\SurveyHero001_Staging.sql';     Db = 'core' },
    @{ File = 'SurveyHero\SurveyHero001_Mapping.sql';     Db = 'core' },
    @{ File = 'SurveyHero\SurveyHero001_Final.sql';       Db = 'core' },
    @{ File = 'TROAP\TROaP001_INIT.sql';                  Db = 'core' },
    @{ File = 'TROAP\TROaP001_DDL.sql';                   Db = 'core' },
    @{ File = 'TROAP\TROaP001_Staging.sql';               Db = 'core' },
    @{ File = 'TROAP\TROaP001_Mapping.sql';               Db = 'core' },
    @{ File = 'TROAP\TROaP001_Final.sql';                 Db = 'core' }
)

# --- preflight -----------------------------------------------------------------
$log = Join-Path $PSScriptRoot ("deploy_{0}_{1}.log" -f $Environment, (Get-Date -Format 'yyyyMMdd_HHmmss'))
function Log([string]$msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg
    Write-Host $line
    Add-Content -Path $log -Value $line
}

Log "Target environment : $Environment"
Log "Target server      : $server"
Log "Baseline path      : $BaselinePath"
Log "Steps              : $($deploySteps.Count) (TBTBookingMetrics on hold)"

$missing = $deploySteps | Where-Object { -not (Test-Path (Join-Path $BaselinePath $_.File)) }
if ($missing) { throw "Missing baseline files: $(($missing | ForEach-Object { $_.File }) -join ', ')" }
Log "All $($deploySteps.Count) baseline files present."

$connArgs = @{
    ServerInstance         = $server
    Username               = $user
    Password               = $password
    TrustServerCertificate = $true
    ErrorAction            = 'Stop'
}

$verInfo = Invoke-Sqlcmd @connArgs -Database 'master' -Query "SELECT @@SERVERNAME AS srv, SERVERPROPERTY('ProductVersion') AS ver"
Log "Connected: $($verInfo.srv) (SQL $($verInfo.ver))"

$coreExists = Invoke-Sqlcmd @connArgs -Database 'master' -Query "SELECT COUNT(*) AS n FROM sys.databases WHERE name = 'core'"
if ($coreExists.n -gt 0) {
    Log "NOTE: [core] database already exists on the target. Scripts are idempotent, but confirm this is intended (re-run/resume) and not the wrong server."
    if (-not $Force -and -not $WhatIf) {
        $ack = Read-Host "core DB already exists on $Environment. Type CONTINUE to proceed"
        if ($ack -cne 'CONTINUE') { Log 'Aborted by operator.'; return }
    }
} else {
    Log "[core] database does not exist - fresh deployment."
}

if ($WhatIf) {
    Log 'WhatIf: preflight complete, no scripts executed. Planned order:'
    $i = 0
    foreach ($s in $deploySteps) { $i++; Log ("  {0,2}. [{1}] {2}" -f $i, $s.Db, $s.File) }
    return
}

if (-not $Force) {
    $ack = Read-Host "About to deploy the v1.0 baseline to $Environment ($server). Type $Environment to confirm"
    if ($ack -cne $Environment) { Log 'Aborted by operator.'; return }
}

# --- execute -------------------------------------------------------------------
$stepNo = 0
foreach ($step in $deploySteps) {
    $stepNo++
    if ($stepNo -lt $StartAt) { continue }
    $path = Join-Path $BaselinePath $step.File
    Log ("STEP {0,2}/{1} [{2}] {3}" -f $stepNo, $deploySteps.Count, $step.Db, $step.File)
    try {
        # PRINT output arrives on the verbose stream - fold it into the log
        Invoke-Sqlcmd @connArgs -Database $step.Db -InputFile $path -QueryTimeout 1800 -Verbose 4>&1 |
            ForEach-Object { Add-Content -Path $log -Value ("    " + ($_ | Out-String).TrimEnd()) }
        Log ("STEP {0,2} OK" -f $stepNo)
    }
    catch {
        Log ("STEP {0,2} FAILED: {1}" -f $stepNo, $_.Exception.Message)
        Log "Deployment halted. Fix the issue and resume with: .\90_deploy_baseline.ps1 -Environment $Environment -StartAt $stepNo"
        throw
    }
}

Log 'Deployment complete. Next: run 91_validate_core_deployment.sql against the core DB.'
