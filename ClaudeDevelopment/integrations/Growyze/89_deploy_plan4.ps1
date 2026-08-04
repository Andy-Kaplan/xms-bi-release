# ============================================================================
# 89_deploy_plan4.ps1 - Deploy Growyze dashboards Plan 4 (layout & formatting)
#                       WAREHOUSE SIDE ONLY
# ============================================================================
# Ledger: O5.
# Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md
#
# Deploys the seven Plan 4 visualisation-query deltas to {ENV} core, then runs
# the verifier as a gate.
#
#   1  reporting_queries/54_currency_percent_tokens.sql ...... currency + type tokens
#   2  reporting_queries/55_invcogs_category_fixes.sql ....... InvCOGSByCategory x5 defects
#   3  reporting_queries/56_grid_header_hygiene.sql .......... sentence case + dup alias
#   4  reporting_queries/57_category_stock_trend_sentinel.sql  sentinel -> Uncategorised
#   5  reporting_queries/58_dashboard_narrative_cards.sql .... 3 NEW datasets + templates
#   6  reporting_queries/59_menu_engineering_reorder.sql ..... Classification to col 2
#   7  reporting_queries/60_invuseanalisys_column_cut.sql .... 19 -> 9 columns
#   8  88_verify_plan4.sql .................................. THE GATE
#
# *** NO RELOAD AND NO PRESENTATION REBUILD ARE NEEDED ***
# Nothing here touches staging, entity mappings or presentation build logic.
# Visualisation queries are read at CARD EXECUTION time, so every change takes
# effect on the next card render for every organisation. That is why this runner
# touches only `core` and never iterates organisations for writes. (The verifier
# DOES read each org DB, read-only, to check its data assumptions.)
#
# ORDER MATTERS ONLY IN ONE PLACE: 58 must run before the report-DB side wires
# the three new datasets. Steps 1-7 are otherwise independent of each other --
# each targets a distinct (dataset, card type) or a distinct substring - so a
# -StartAt resume is safe at any step.
#
# THIS IS HALF THE DEPLOYMENT. The layout itself lives in the report DB:
#   report_config/91_deploy_plan4.ps1   (run AFTER this script)
# Running this alone changes formatting but not layout; running the report-DB
# side alone places cards whose datasets do not exist yet (07 refuses to start).
#
# ENCODING: every script in this set is deliberately PURE ASCII, with currency
# symbols emitted as NCHAR(163). sqlcmd decodes a UTF-8 file with no BOM using
# the system ANSI codepage, which would otherwise mangle a pound sign into
# mojibake and store the mangled text in the query. Step 8 asserts NCHAR(163) is
# what landed, so this cannot regress silently.
#
# Usage:
#   .\89_deploy_plan4.ps1 -Environment UAT -WhatIf     # list steps, change nothing
#   .\89_deploy_plan4.ps1 -Environment UAT
#   .\89_deploy_plan4.ps1 -Environment UAT -StartAt 5  # resume after a failure
#   .\89_deploy_plan4.ps1 -Environment UAT -VerifyOnly # run step 8 alone
#
# Rollback: every edited query is recoverable from git (the pre-Plan-4 text is
# in the branch history); the three NEW datasets are additive - set Status =
# 'RETIRED' on them and they stop resolving. Do that BEFORE rolling back the
# report DB, or the placed cards will error rather than hide.
# ============================================================================

[CmdletBinding()]
param(
    [Parameter()][ValidateSet('DEV','TEST','UAT')]
    [string]$Environment = 'UAT',
    [int]$StartAt = 1,
    [switch]$VerifyOnly,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Read Process, then User, then Machine. A process-only read is empty in a
# non-interactive/agent shell even when the variable is set for the user, which
# produced a spurious "Missing env vars" failure in script 95.
function Get-EnvAny {
    param([Parameter(Mandatory)][string]$Name)
    foreach ($scope in @('Process','User','Machine')) {
        $v = [Environment]::GetEnvironmentVariable($Name, $scope)
        if ($v) { return $v }
    }
    return $null
}

$server   = Get-EnvAny "XMS_BI_MANAGED_${Environment}_SERVER"
$user     = Get-EnvAny "XMS_BI_MANAGED_${Environment}_USER"
$password = Get-EnvAny "XMS_BI_MANAGED_${Environment}_PASSWORD"
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
$logPath   = Join-Path $scriptDir ("deploy_PLAN4_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

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

Write-Log '=== Growyze dashboards Plan 4 - layout & formatting, WAREHOUSE side (O5) ==='
Write-Log "Environment : $Environment"
Write-Log "Server      : $server  (database: core)"
Write-Log "Log         : $logPath"
if ($WhatIf)     { Write-Log 'MODE        : -WhatIf (no changes will be made)' }
if ($VerifyOnly) { Write-Log 'MODE        : -VerifyOnly (step 8 only)' }

$steps = @(
    @{ N = 1; File = 'reporting_queries/54_currency_percent_tokens.sql';      Desc = 'currency symbols + type tokens' }
    @{ N = 2; File = 'reporting_queries/55_invcogs_category_fixes.sql';       Desc = 'InvCOGSByCategory - 5 defects, both card types' }
    @{ N = 3; File = 'reporting_queries/56_grid_header_hygiene.sql';          Desc = 'sentence case + duplicate [Type11] alias' }
    @{ N = 4; File = 'reporting_queries/57_category_stock_trend_sentinel.sql';Desc = 'D_INVITEM sentinel -> Uncategorised' }
    @{ N = 5; File = 'reporting_queries/58_dashboard_narrative_cards.sql';    Desc = '3 NEW narrative datasets + 4 templates' }
    @{ N = 6; File = 'reporting_queries/59_menu_engineering_reorder.sql';     Desc = 'Classification -> column 2' }
    @{ N = 7; File = 'reporting_queries/60_invuseanalisys_column_cut.sql';    Desc = 'InvUseAnalisys 19 -> 9 columns' }
)
$verifyFile = '88_verify_plan4.sql'

# Fail before touching anything if a script is missing.
foreach ($s in $steps) {
    $full = Join-Path $scriptDir $s.File
    if (-not (Test-Path $full)) { throw "Missing script: $full" }
}
if (-not (Test-Path (Join-Path $scriptDir $verifyFile))) { throw "Missing verifier: $verifyFile" }
Write-Log ("All {0} scripts plus the verifier are present." -f $steps.Count)

# Guard the encoding invariant BEFORE deploying, not after. A non-ASCII byte in
# any of these files means a literal symbol has crept back in and sqlcmd may
# mangle it into the stored query.
foreach ($s in $steps) {
    $full  = Join-Path $scriptDir $s.File
    $bytes = [System.IO.File]::ReadAllBytes($full)
    $bad   = @($bytes | Where-Object { $_ -gt 127 }).Count
    if ($bad -gt 0) {
        throw ("$($s.File) contains $bad non-ASCII byte(s). Plan 4 scripts must be pure ASCII " +
               "(currency via NCHAR(163)) or sqlcmd may store mojibake. Fix the file before deploying.")
    }
}
Write-Log 'Encoding guard: all step scripts are pure ASCII.'

$done = 0; $skipped = 0

if (-not $VerifyOnly) {
    foreach ($s in $steps) {
        $label = "Step {0} - {1}" -f $s.N, $s.Desc

        if ($s.N -lt $StartAt) { Write-Log "$label : SKIPPED (-StartAt $StartAt)"; $skipped++; continue }
        if ($WhatIf)           { Write-Log "$label : would run $($s.File)"; continue }

        Write-Log "$label : running $($s.File)"
        try {
            $out = Invoke-Sql -Database 'core' -File (Join-Path $scriptDir $s.File)
            # Each script emits its own PASS/FAIL assertion rows; surface any FAIL now
            # rather than leaving it to the gate, so the log shows which step caused it.
            $fails = @($out | ForEach-Object {
                $_.PSObject.Properties | Where-Object { "$($_.Value)" -like 'FAIL*' }
            })
            if ($fails.Count -gt 0) {
                foreach ($f in $fails) { Write-Log ("  !! {0}: {1}" -f $f.Name, $f.Value) }
                throw "Step $($s.N) reported $($fails.Count) FAIL assertion(s) - see above."
            }
            Write-Log "$label : OK"
            $done++
        }
        catch {
            Write-Log "$label : FAILED - $($_.Exception.Message)"
            Write-Log "Resume after fixing with: -StartAt $($s.N)"
            throw
        }
    }
}

if ($WhatIf) {
    Write-Log '=== -WhatIf complete; nothing was changed ==='
    Write-Log 'Next after a real run: report_config\91_deploy_plan4.ps1'
    return
}

if (-not $VerifyOnly) { Write-Log "=== Deployed $done step(s); skipped $skipped ===" }

# ---------------------------------------------------------------------------
# Step 8 - the gate.
# ---------------------------------------------------------------------------
Write-Log "Step 8 - $verifyFile (the gate)"
$rows = @(Invoke-Sql -Database 'core' -File (Join-Path $scriptDir $verifyFile))

$fail    = 0
$vacuous = 0
$review  = 0
foreach ($r in $rows) {
    foreach ($p in $r.PSObject.Properties) {
        $v = "$($p.Value)"
        if ($v -like 'FAIL*')    { $fail++;    Write-Log ("  FAIL    {0}: {1}" -f $p.Name, $v) }
        elseif ($v -like 'VACUOUS*') { $vacuous++; Write-Log ("  VACUOUS {0}: {1}" -f $p.Name, $v) }
        elseif ($v -like 'REVIEW*')  { $review++;  Write-Log ("  REVIEW  {0}: {1}" -f $p.Name, $v) }
    }
}

Write-Log ("Gate summary: {0} FAIL, {1} VACUOUS, {2} REVIEW" -f $fail, $vacuous, $review)

if ($fail -gt 0) {
    Write-Log 'GATE FAILED. Do not proceed to the report-DB side or the smoke test.'
    throw "Plan 4 warehouse verification failed with $fail FAIL result(s)."
}

if ($vacuous -gt 0) {
    Write-Log ('NOTE: {0} check(s) were VACUOUS - nothing to falsify on this data. Reported honestly rather than counted as a pass.' -f $vacuous)
}
if ($review -gt 0) {
    Write-Log ('NOTE: {0} check(s) need a human look (REVIEW) - a stated assumption has changed.' -f $review)
}

Write-Log '=== Plan 4 WAREHOUSE side complete and gated. ==='
Write-Log 'NEXT: report_config\91_deploy_plan4.ps1 (grants + dataset map + layout).'
