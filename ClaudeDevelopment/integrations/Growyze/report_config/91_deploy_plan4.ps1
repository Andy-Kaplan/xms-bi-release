# ============================================================================
# 91_deploy_plan4.ps1 - Deploy Growyze dashboards Plan 4, REPORT-DB SIDE
# ============================================================================
# Ledger: O5.
# Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md
#
# TARGET: the microservice `report` database. MCP against `report` is READ-ONLY,
# which is why writes come through here.
#
#   1  08_grants_and_dataset_map_plan4.sql .. card-type grants THEN dataset map
#   2  07_layout_rev2.sql .................... re-lay-out all three grids
#   3  92_verify_plan4.sql .................... report-DB gate
#   4  cross-server check ..................... the one the report DB cannot do
#
# RUN THE WAREHOUSE SIDE FIRST: ..\89_deploy_plan4.ps1 -Environment UAT
# Script 07 refuses to start unless the three new datasets are already in
# VisualisationDataSetMap, and those datasets must exist on the MI (script 58) or
# the placed cards resolve to nothing.
#
# ORDER 1 -> 2 IS LOAD-BEARING, NOT COSMETIC.
# Placing a card whose org lacks the card-type grant does not error -- the
# dataset-map join finds nothing, the dataset is silently skipped, and the card
# renders blank with no clue why. Measured on UAT 2026-08-03: StaticBoxCard and
# MarkdownCard were ungranted on ALL FIVE orgs and BarChartCard was missing on
# Ibis Heathrow, so all four added cards would have failed silently. Step 1
# creates the grants and hard-gates on the full cross product before step 2
# places anything.
#
# *** WHY STEP 4 EXISTS ***
# Steps 1-3 only prove the report DB agrees with ITSELF. `DataSet` is a
# cross-system key: a name wired here that does not exist in
# core.core.VisualisationQueries on the Managed Instance passes every report-DB
# check and still renders blank. Step 4 reads the ACTUAL wired names out of
# `report` (it does not re-declare them from this file) and looks each one up on
# the MI. It is the only check that can catch a typo in a dataset name -- note
# InvUseAnalisys is a genuine live misspelling that must match exactly and must
# NOT be "corrected".
#
# Usage:
#   .\91_deploy_plan4.ps1 -Environment UAT -WhatIf
#   .\91_deploy_plan4.ps1 -Environment UAT
#   .\91_deploy_plan4.ps1 -Environment UAT -StartAt 2
#   .\91_deploy_plan4.ps1 -Environment UAT -VerifyOnly
#
# ROLLBACK (report DB): see the header of each SQL script. In short, soft-delete
# the three new dataset-map rows and the items on the three grids, then re-run
# Plan 3's 04/05/06 to restore the previous layout. Roll the MI side back FIRST
# or the still-placed cards will error instead of hiding.
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

function Get-EnvAny {
    param([Parameter(Mandatory)][string]$Name)
    foreach ($scope in @('Process','User','Machine')) {
        $v = [Environment]::GetEnvironmentVariable($Name, $scope)
        if ($v) { return $v }
    }
    return $null
}

# ---- report DB (Azure SQL) -------------------------------------------------
$reportServer = Get-EnvAny "AZURE_MICROSERVICE_${Environment}_SERVER"
$reportUser   = Get-EnvAny "AZURE_MICROSERVICE_${Environment}_USER"
$reportPwd    = Get-EnvAny "AZURE_MICROSERVICE_${Environment}_PASSWORD"
if (-not $reportServer -or -not $reportUser -or -not $reportPwd) {
    throw "Missing env vars AZURE_MICROSERVICE_${Environment}_SERVER / _USER / _PASSWORD."
}
if ($reportServer -match 'prod') { throw "Refusing to run against a server whose name contains 'prod': $reportServer" }

# ---- Managed Instance (for the cross-server check only, read-only) ---------
$miServer = Get-EnvAny "XMS_BI_MANAGED_${Environment}_SERVER"
$miUser   = Get-EnvAny "XMS_BI_MANAGED_${Environment}_USER"
$miPwd    = Get-EnvAny "XMS_BI_MANAGED_${Environment}_PASSWORD"
if (-not $miServer -or -not $miUser -or -not $miPwd) {
    throw "Missing env vars XMS_BI_MANAGED_${Environment}_SERVER / _USER / _PASSWORD (needed for the cross-server check)."
}
if ($miServer -notmatch ',\d+$' -and $miServer -match '\.public\.') { $miServer = "$miServer,3342" }
if ($miServer -match 'prod') { throw "Refusing to run against a server whose name contains 'prod': $miServer" }

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module not found. Run: Install-Module SqlServer -Scope CurrentUser -AllowClobber"
}
Import-Module SqlServer -DisableNameChecking -WarningAction SilentlyContinue

$reportCred = New-Object System.Management.Automation.PSCredential(
    $reportUser, (ConvertTo-SecureString $reportPwd -AsPlainText -Force))

$scriptDir = $PSScriptRoot
$logPath   = Join-Path $scriptDir ("deploy_PLAN4_${Environment}_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -Path $logPath -Value $line -Encoding utf8
}

function Invoke-Report {
    param([string]$File, [string]$Query)
    $splat = @{
        ServerInstance = $reportServer; Database = 'report'; Credential = $reportCred
        TrustServerCertificate = $true; QueryTimeout = 0
        ErrorAction = 'Stop'; OutputSqlErrors = $true
    }
    if ($File)  { $splat['InputFile'] = $File }
    if ($Query) { $splat['Query']     = $Query }
    Invoke-Sqlcmd @splat
}

function Invoke-MI {
    param([Parameter(Mandatory)][string]$Query)
    # -OutputSqlErrors takes an explicit boolean; passing it as a bare switch is a
    # binding error, not a no-op.
    Invoke-Sqlcmd -ServerInstance $miServer -Database 'core' -Username $miUser -Password $miPwd `
                  -TrustServerCertificate -QueryTimeout 0 -ErrorAction Stop -OutputSqlErrors $true `
                  -Query $Query
}

Write-Log '=== Growyze dashboards Plan 4 - layout, REPORT-DB side (O5) ==='
Write-Log "Environment   : $Environment"
Write-Log "report server : $reportServer  (database: report)"
Write-Log "MI server     : $miServer      (read-only, cross-server check)"
Write-Log "Log           : $logPath"
if ($WhatIf)     { Write-Log 'MODE          : -WhatIf (no changes will be made)' }
if ($VerifyOnly) { Write-Log 'MODE          : -VerifyOnly (steps 3-4 only)' }

$steps = @(
    @{ N = 1; File = '08_grants_and_dataset_map_plan4.sql'; Desc = 'card-type grants + dataset map (gated)' }
    @{ N = 2; File = '07_layout_rev2.sql';                  Desc = 're-lay-out Overview / Sales / Inventory' }
)
$verifyFile = '92_verify_plan4.sql'

foreach ($s in $steps) {
    $full = Join-Path $scriptDir $s.File
    if (-not (Test-Path $full)) { throw "Missing script: $full" }
}
if (-not (Test-Path (Join-Path $scriptDir $verifyFile))) { throw "Missing verifier: $verifyFile" }
Write-Log ("All {0} scripts plus the verifier are present." -f $steps.Count)

# ---- Steps 1-2: writes against `report` -----------------------------------
$done = 0; $skipped = 0
if (-not $VerifyOnly) {
    foreach ($s in $steps) {
        $label = "Step {0} - {1}" -f $s.N, $s.Desc
        if ($s.N -lt $StartAt) { Write-Log "$label : SKIPPED (-StartAt $StartAt)"; $skipped++; continue }
        if ($WhatIf)           { Write-Log "$label : would run $($s.File)"; continue }

        Write-Log "$label : running $($s.File)"
        try {
            $out = Invoke-Report -File (Join-Path $scriptDir $s.File)
            foreach ($r in $out) {
                foreach ($p in $r.PSObject.Properties) {
                    if ("$($p.Value)" -like '*UNWIRED*') { Write-Log ("  !! {0}: {1}" -f $p.Name, $p.Value) }
                }
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
    return
}
if (-not $VerifyOnly) { Write-Log "=== Applied $done step(s); skipped $skipped ===" }

# ---- Step 3: the report-DB gate -------------------------------------------
Write-Log "Step 3 - $verifyFile (report-DB gate)"
$rows = @(Invoke-Report -File (Join-Path $scriptDir $verifyFile))

$fail = 0; $review = 0
foreach ($r in $rows) {
    foreach ($p in $r.PSObject.Properties) {
        $v = "$($p.Value)"
        if ($v -like 'FAIL*')        { $fail++;   Write-Log ("  FAIL   {0}: {1}" -f $p.Name, $v) }
        elseif ($v -like 'REVIEW*')  { $review++; Write-Log ("  REVIEW {0}: {1}" -f $p.Name, $v) }
    }
}
Write-Log ("Report-DB gate: {0} FAIL, {1} REVIEW" -f $fail, $review)
if ($fail -gt 0) {
    Write-Log 'GATE FAILED. Do not smoke-test; fix and re-run.'
    throw "Plan 4 report-DB verification failed with $fail FAIL result(s)."
}

# ---- Step 4: cross-server check -------------------------------------------
# Reads the ACTUAL wired names out of `report` rather than re-declaring them, so
# a typo cannot hide behind a matching hardcoded list on both sides.
Write-Log 'Step 4 - cross-server check: every wired DataSet must exist on the MI'

$wiredQuery = @'
SELECT DISTINCT gi.DataSet, gi.VisualisationId, vp.ProcedureName AS CardType
FROM dbo.DashboardGridItem gi
LEFT JOIN dbo.VisualisationProcedure vp
       ON vp.VisualisationId = gi.VisualisationId AND vp.IsDeleted = 0
WHERE gi.IsDeleted = 0
  AND gi.DashboardGridId IN ('B0A1D000-0001-4A00-9E00-000000000001',
                             'B0A1D000-0002-4A00-9E00-000000000002',
                             'B0A1D000-0003-4A00-9E00-000000000003');
'@

$wired = @(Invoke-Report -Query $wiredQuery)
Write-Log ("  {0} distinct (DataSet, card type) pairs are wired across the three grids." -f $wired.Count)
if ($wired.Count -eq 0) { throw 'Cross-server check found no wired cards at all - the layout did not apply.' }

$missing = 0
foreach ($w in $wired) {
    # ProcedureName is 'core.SingleKPICard'; the MI stores 'SingleKPICard'.
    $cardType = ($w.CardType -replace '^core\.', '')
    $ds       = $w.DataSet -replace "'", "''"
    $ct       = $cardType  -replace "'", "''"

    $q = "SELECT COUNT(*) AS n FROM [core].[core].[VisualisationQueries] " +
         "WHERE DataSetName = N'$ds' AND VisualizationType = N'$ct' AND Status = N'LIVE';"
    $n = (Invoke-MI -Query $q).n

    if ($n -eq 0) {
        $missing++
        Write-Log ("  FAIL {0} / {1} - no LIVE query on the MI. This card renders blank." -f $w.DataSet, $cardType)
    }
}

if ($missing -gt 0) {
    throw "Cross-server check failed: $missing wired card(s) have no LIVE query on the Managed Instance."
}
Write-Log '  PASS - every wired card resolves to a LIVE MI query.'

Write-Log '=== Plan 4 REPORT-DB side complete and gated. ==='
Write-Log ''
Write-Log 'REMAINING, BY HAND (these cannot be asserted from SQL):'
Write-Log '  1. Confirm the heatmap has actually DISAPPEARED from Sales & Profitability.'
Write-Log '     The soft delete assumes the frontend honours DashboardGridItem.IsDeleted;'
Write-Log '     that is documented but has not been observed directly.'
Write-Log '  2. Check xl=2 / xl=3 at >=1536px. No live grid diverges md/lg/xl, so this is'
Write-Log '     unprecedented. If it reads badly, set those cards back to xl=4 / xl=6.'
Write-Log '  3. Confirm InvCountHealthAlert renders on Padel Social (Earls Court, 6 items'
Write-Log '     with no cost) and is absent on Gloucester. OverviewStockAlert is expected'
Write-Log '     to be SILENT everywhere today - that is healthy, not broken.'
